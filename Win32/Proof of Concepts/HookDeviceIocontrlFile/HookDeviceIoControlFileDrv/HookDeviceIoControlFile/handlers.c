#include "stdafx.h"

NT_DEVICE_IO_CONTROL_FILE old_NtDeviceIoControlFile = NULL;

/**
 * Fuzzing settings
 */
ULONG m_FuzzOptions = 0;
FUZZING_TYPE m_FuzzingType = FuzzingType_Random;
/**
 * Exported variables for acessing to the 
 * last IOCTL request information from the kernel debugger.
 */
PDEVICE_OBJECT currentDeviceObject = NULL;
PDRIVER_OBJECT currentDriverObject = NULL;
ULONG currentIoControlCode = 0;
PVOID currentInputBuffer = NULL;
ULONG currentInputBufferLength = 0;
PVOID currentOutputBuffer = NULL;
ULONG currentOutputBufferLength = 0;

/**
 * Handle and objetc pointer of the fuzzer's process (uses for fair fuzzing mode)
 */
HANDLE m_FuzzThreadId = 0;
PEPROCESS m_FuzzProcess = NULL;
PUSER_MODE_DATA m_UserModeData = NULL;

/**
* Some fuzzing parameters
*/
#define RANDOM_FUZZING_ITERATIONS   10
#define BUFFERED_FUZZING_ITERATIONS 5
#define DWORD_FUZZING_MAX_LENGTH    0x2000
#define DWORD_FUZZING_DELTA         4

ULONG  g_newDeviceIoControlFileCallCount = 0;

#ifdef _X86_

// pointer values for invalid kernel and user buffers
#define KERNEL_BUFFER_ADDRESS (PVOID)(0xFFFF0000)
#define USER_BUFFER_ADDRESS   (PVOID)(0x00001000)

#elif _AMD64_

#define KERNEL_BUFFER_ADDRESS (PVOID)(0xFFFFFFFFFFFF0000)
#define USER_BUFFER_ADDRESS   (PVOID)(0x0000000000001000)

#endif

// constants for dword fuzzing
ULONG m_DwordFuzzingConstants[] =
{
    0x00000000,
    0x00001000,
    0xFFFF0000,
    0xFFFFFFFF
};

// defined in driver.cpp
extern PDEVICE_OBJECT m_DeviceObject;
extern KMUTEX m_CommonMutex;
extern PCOMMON_LST m_ProcessesList;
//--------------------------------------------------------------------------------------
PCOMMON_LST_ENTRY LookupProcessInfo(PEPROCESS Process)
{
    PCOMMON_LST_ENTRY process_entry = NULL;
    KIRQL OldIrql;
    KeAcquireSpinLock(&m_ProcessesList->ListLock, &OldIrql);

    __try
    {
        PCOMMON_LST_ENTRY e = m_ProcessesList->list_head;

        // enumerate all processes
        while (e)
        {
            if (e->Data && e->DataSize == sizeof(LST_PROCESS_INFO))
            {                
                PLST_PROCESS_INFO Info = (PLST_PROCESS_INFO)e->Data;
                if (Info->Process == Process)
                {
                    process_entry = e;
                    break;
                }
            }

            e = e->next;
        }
    }    
    __finally
    {
        KeReleaseSpinLock(&m_ProcessesList->ListLock, OldIrql);
    }

    return process_entry;
}
//--------------------------------------------------------------------------------------
void FreeProcessInfo(void)
{
    KIRQL OldIrql;
    KeAcquireSpinLock(&m_ProcessesList->ListLock, &OldIrql);

    __try
    {
        PCOMMON_LST_ENTRY e = m_ProcessesList->list_head;

        // enumerate all processes
        while (e)
        {
            if (e->Data && e->DataSize == sizeof(LST_PROCESS_INFO))
            {                
                PLST_PROCESS_INFO Info = (PLST_PROCESS_INFO)e->Data;
                if (Info->usImagePath.Buffer)
                {
                    // free process image path
                    RtlFreeUnicodeString(&Info->usImagePath);
                }
            }

            e = e->next;
        }
    }    
    __finally
    {
        KeReleaseSpinLock(&m_ProcessesList->ListLock, OldIrql);
    }
}
//--------------------------------------------------------------------------------------
void NTAPI ProcessNotifyRoutine(HANDLE ParentId, HANDLE ProcessId, BOOLEAN Create)
{
    PEPROCESS Process;
    NTSTATUS ns = PsLookupProcessByProcessId(ProcessId, &Process);
    if (NT_SUCCESS(ns))
    {
        KeWaitForMutexObject(&m_CommonMutex, UserRequest, KernelMode, FALSE, NULL);

        __try
        {
            if (Create)
            {                        
                // process has been created
                UNICODE_STRING ImagePath;

                // get full image path for this process
                if (GetProcessFullImagePath(Process, &ImagePath))
                {
                    WCHAR wcProcess[0x200];
                    UNICODE_STRING usProcess;
					LST_PROCESS_INFO Info;

                    LogData("Process "IFMT" started: '%wZ' (PID: %d)\r\n\r\n", Process, &ImagePath, ProcessId);

                    swprintf(wcProcess, L"'%wZ' (" IFMT_W L")", &ImagePath, Process);
                    RtlInitUnicodeString(&usProcess, wcProcess);                               

                    
                    Info.Process = Process;
                    Info.ProcessId = ProcessId;

                    Info.usImagePath.Buffer = ImagePath.Buffer;
                    Info.usImagePath.Length = ImagePath.Length;
                    Info.usImagePath.MaximumLength = ImagePath.MaximumLength;

                    // add process information into the list
                    if (LstAddEntry(m_ProcessesList, &usProcess, &Info, sizeof(Info)) == NULL)
                    {
                        RtlFreeUnicodeString(&ImagePath);
                    }                                
                }                                    
            }
            else
            {
				PCOMMON_LST_ENTRY process_entry = NULL;
                LogData("Process "IFMT" terminated\r\n\r\n", Process);

                // process terminating
                process_entry = LookupProcessInfo(Process);            
                if (process_entry)
                {
                    if (process_entry->Data && 
                        process_entry->DataSize == sizeof(LST_PROCESS_INFO))
                    {                
                        PLST_PROCESS_INFO Info = (PLST_PROCESS_INFO)process_entry->Data;
                        if (Info->usImagePath.Buffer)
                        {
                            // free process image path
                            RtlFreeUnicodeString(&Info->usImagePath);
                        }
                    }

                    // delete information about this process from list
                    LstDelEntry(m_ProcessesList, process_entry);
                }
            }
        }
        __finally
        {
            KeReleaseMutex(&m_CommonMutex, FALSE);
        }        
        
        ObDereferenceObject(Process);
    } 
    else 
    {
        DbgMsg(__FILE__, __LINE__, "PsLookupProcessByProcessId() fails; status: 0x%.8x\n", ns);
    }
}
//--------------------------------------------------------------------------------------
PUNICODE_STRING LookupProcessName(PEPROCESS TargetProcess)
{
    PEPROCESS Process = TargetProcess;
	PCOMMON_LST_ENTRY process_entry = NULL;
	HANDLE ProcessId = NULL;
	UNICODE_STRING ImagePath;
    PUNICODE_STRING Ret = NULL;

    if (Process == NULL)
    {
        // lookup current process information entry
        Process = PsGetCurrentProcess();
    }
    
    process_entry = LookupProcessInfo(Process);
    if (process_entry)
    {
        if (process_entry->Data && 
            process_entry->DataSize == sizeof(LST_PROCESS_INFO))
        {                
            PLST_PROCESS_INFO Info = (PLST_PROCESS_INFO)process_entry->Data;
            if (Info->usImagePath.Buffer)
            {
                // return process image path
                return &Info->usImagePath;
            }
        }

        return NULL;
    }

    // information entry for current process is not found, allocate it
    ProcessId = PsGetCurrentProcessId();
    

    // get full image path for this process
    if (GetProcessFullImagePath(Process, &ImagePath))
    {
        WCHAR wcProcess[0x200];
        UNICODE_STRING usProcess;
		LST_PROCESS_INFO Info;

        swprintf(wcProcess, L"'%wZ' (" IFMT_W L")", &ImagePath, Process);
        RtlInitUnicodeString(&usProcess, wcProcess);

        
        Info.Process = Process;
        Info.ProcessId = ProcessId;

        Info.usImagePath.Buffer = ImagePath.Buffer;
        Info.usImagePath.Length = ImagePath.Length;
        Info.usImagePath.MaximumLength = ImagePath.MaximumLength;

        // add process information into the list
        if (process_entry = LstAddEntry(m_ProcessesList, &usProcess, &Info, sizeof(Info)))
        {
            PLST_PROCESS_INFO pInfo = (PLST_PROCESS_INFO)process_entry->Data;
            Ret = &pInfo->usImagePath;
        }
        else
        {
            RtlFreeUnicodeString(&ImagePath);
        }                
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
BOOLEAN ValidateUnicodeString(PUNICODE_STRING usStr)
{
	ULONG i = 0;
    if (!MmIsAddressValid(usStr))
    {
        return FALSE;
    }

    if (usStr->Buffer == NULL || usStr->Length == 0)
    {
        return FALSE;
    }

    for (i = 0; i < usStr->Length; i++)
    {
        if (!MmIsAddressValid((PUCHAR)usStr->Buffer + i))
        {
            return FALSE;
        }
    }

    return TRUE;
}


//--------------------------------------------------------------------------------------
NTSTATUS NTAPI new_NtDeviceIoControlFile(
    HANDLE FileHandle,
    HANDLE Event,
    PIO_APC_ROUTINE ApcRoutine,
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock,
    ULONG IoControlCode,
    PVOID InputBuffer,
    ULONG InputBufferLength,
    PVOID OutputBuffer,
    ULONG OutputBufferLength)
{    
    KPROCESSOR_MODE PrevMode = ExGetPreviousMode();
    BOOLEAN bLogOutputBuffer = FALSE;
	NTSTATUS status = STATUS_UNSUCCESSFUL;

    POBJECT_NAME_INFORMATION DeviceObjectName = NULL, DriverObjectName = NULL;    
    PFILE_OBJECT pFileObject = NULL;
    NTSTATUS ns = 0;

    BOOLEAN bProcessEvent = FALSE;

    LARGE_INTEGER Timeout;

    PVOID pDeviceObject = NULL;
    PLDR_DATA_TABLE_ENTRY pModuleEntry = NULL;

    PEPROCESS Process;
    HANDLE ProcessId;

    _InterlockedIncrement(&g_newDeviceIoControlFileCallCount);
     // get device object by handle
     ns = ObReferenceObjectByHandle(
        FileHandle, 
        0, 0, 
        KernelMode, 
        (PVOID *)&pFileObject, 
        NULL
        );
    if(!NT_SUCCESS(ns))
        goto end;

    // validate pointer to device object
    if (MmIsAddressValid(pFileObject->DeviceObject))
    {
        pDeviceObject = pFileObject->DeviceObject;
    }
    else
    {
        goto end;
    }

    if (pDeviceObject == m_DeviceObject)
    {
        // don't handle requests to our driver
        goto end;
    }

    // validate pointer to driver object
    if (!MmIsAddressValid(pFileObject->DeviceObject->DriverObject))
    {
        goto end;
    }

    // get loader information entry for the driver module
    pModuleEntry = (PLDR_DATA_TABLE_ENTRY)
        pFileObject->DeviceObject->DriverObject->DriverSection;

    if (pModuleEntry == NULL)
    {
        goto end;
    }

    // validate pointer to loader's table and data from it
    if (!MmIsAddressValid(pModuleEntry) ||
        !ValidateUnicodeString(&pModuleEntry->FullDllName))
    {
        goto end;
    }

    // get device name by poinet
    DeviceObjectName = GetObjectName(pDeviceObject);
    if(!DeviceObjectName)
        goto end;

    DriverObjectName = GetObjectName(pFileObject->DeviceObject->DriverObject);
    if(!DriverObjectName)
        goto end;

    Process = PsGetCurrentProcess();
    ProcessId = PsGetCurrentProcessId();

    Timeout.QuadPart = RELATIVE(SECONDS(5));
    ns = KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, &Timeout);
    if (ns == STATUS_TIMEOUT)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Wait timeout\n");
        goto end;
    }

    __try
    {
        PWSTR Methods[] = 
        {
            L"METHOD_BUFFERED",
            L"METHOD_IN_DIRECT",
            L"METHOD_OUT_DIRECT",
            L"METHOD_NEITHER"
        };

        PWSTR lpwcMethod = Methods[IoControlCode & 3];


        char *lpszKdCommand = NULL;

        LARGE_INTEGER Time;

        // get process image path
        PUNICODE_STRING ProcessImagePath = LookupProcessName(NULL);     
        if(!ProcessImagePath)
            __leave;
  
        KeQuerySystemTime(&Time);

        // get text name of the method
        currentDeviceObject = pFileObject->DeviceObject;
        currentDriverObject = pFileObject->DeviceObject->DriverObject;
        currentIoControlCode = IoControlCode;
        currentInputBuffer = InputBuffer;
        currentInputBufferLength = InputBufferLength;
        currentOutputBuffer = OutputBuffer;
        currentOutputBufferLength = OutputBufferLength;

//         if (m_FuzzOptions & FUZZ_OPT_LOG_IOCTL_GLOBAL)
//         {
//             // log IOCTL information into the global log
//             LogDataIoctls("timestamp=0x%.8x%.8x\r\n", Time.HighPart, Time.LowPart);
//             LogDataIoctls("process_id=%d\r\n", ProcessId);
//             LogDataIoctls("process_path=%wZ\r\n", ProcessImagePath);
//             LogDataIoctls("device=%wZ\r\n", &DeviceObjectName->Name);
//             LogDataIoctls("driver=%wZ\r\n", &DriverObjectName->Name);
//             LogDataIoctls("image_file=%wZ\r\n", &pModuleEntry->FullDllName);
//             LogDataIoctls("code=0x%.8x\r\n", IoControlCode);
//             LogDataIoctls("method=%ws\r\n", lpwcMethod);
//             LogDataIoctls("in_size=%d\r\n", InputBufferLength);
//             LogDataIoctls("out_size=%d\r\n", OutputBufferLength);
//             LogDataIoctls("\r\n");
//         }

        // get debugger command, that can be associated with this IOCTL
        lpszKdCommand = FltGetKdCommand(
            &DeviceObjectName->Name,
            &DriverObjectName->Name/*pModuleEntry->FullDllName*/,
            IoControlCode,
            ProcessImagePath
            );

        bProcessEvent = FltIsMatchedRequest(
            &DeviceObjectName->Name,
            &pModuleEntry->FullDllName,
            IoControlCode,
            ProcessImagePath
            );

        if ((bProcessEvent || lpszKdCommand) &&
            (m_FuzzOptions & FUZZ_OPT_LOG_IOCTL))
        {
            LogDataIoctls(
                "timestamp=0x%.8x%.8x\r\n \
                process_id=%d\r\n \
                process_path=%wZ\r\n \
                device=%wZ\r\n \
                driver=%wZ\r\n \
                image_file=%wZ\r\n \
                code=0x%.8x\r\n \
                method=%ws\r\n \
                in_size=%d\r\n \
                out_size=%d\r\n \
                \r\n",
                Time.HighPart, Time.LowPart,
                ProcessId,
                ProcessImagePath,
                &DeviceObjectName->Name,
                &DriverObjectName->Name,
                &pModuleEntry->FullDllName,
                IoControlCode,
                lpwcMethod,
                InputBufferLength,
                OutputBufferLength);

            if (m_FuzzOptions & FUZZ_OPT_LOG_IOCTL_BUFFERS)
            {
                // log output buffer information
                LogDataIoctls("   OutBuff: "IFMT", OutSize: 0x%.8x\r\n",
                    OutputBuffer,
                    OutputBufferLength);

                // log input buffer information
                LogDataIoctls("    InBuff: "IFMT",  InSize: 0x%.8x\r\n",
                    InputBuffer,
                    InputBufferLength);

                // print input buffer contents
                LogDataIoctls("--------------------------------------------------------------------\r\n");
                LogDataHexdump((PUCHAR)InputBuffer, min(InputBufferLength, MAX_IOCTL_BUFFER_LEGTH));
                LogDataIoctls("\r\n");
            }
        } 
    }
    __finally
    {
        KeReleaseMutex(&m_CommonMutex, FALSE);
    }
end: 
    if(pFileObject)
        ObDereferenceObject(pFileObject);

    if(DriverObjectName)
        ExFreePool(DriverObjectName);

    if(DeviceObjectName)
        ExFreePool(DeviceObjectName);

    // restore KTHREAD::PreviousMode
    SetPreviousMode(PrevMode);        
    // call original function
    status = old_NtDeviceIoControlFile(
        FileHandle, 
        Event, 
        ApcRoutine, 
        ApcContext, 
        IoStatusBlock, 
        IoControlCode, 
        InputBuffer, 
        InputBufferLength, 
        OutputBuffer, 
        OutputBufferLength
    );    

    _InterlockedDecrement( &g_newDeviceIoControlFileCallCount );

    return status;
}

VOID WaitHookRemoveComplete()
{
    LONG    Count = 0;
    const   LARGE_INTEGER WaitTime = {(ULONG)(-50 * 1000 * 10), -1};

    do
    {
        KeDelayExecutionThread( KernelMode , FALSE , (PLARGE_INTEGER)&WaitTime );
        _InterlockedExchange( &Count , g_newDeviceIoControlFileCallCount );
    } while (Count != 0 );

    return;
}
//--------------------------------------------------------------------------------------
// EoF
