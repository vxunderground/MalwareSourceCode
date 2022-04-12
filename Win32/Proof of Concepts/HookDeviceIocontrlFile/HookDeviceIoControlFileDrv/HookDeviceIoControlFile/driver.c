#include "stdafx.h"

/**
 * Offsets for some undocummented structures
 */
ULONG m_KTHREAD_PrevMode = 0;

/**
 * System services numbers
 */ 
//extern "C" 
//{
ULONG m_SDT_NtDeviceIoControlFile = 0;
ULONG m_SDT_NtProtectVirtualMemory = 0;

#ifdef _AMD64_
// need for system services calling on x64 kernels
PVOID _KiServiceInternal = 0;
#endif

extern POBJECT_TYPE *IoDeviceObjectType;
extern POBJECT_TYPE *IoFileObjectType;

//}

// defined in handlers.cpp
extern NT_DEVICE_IO_CONTROL_FILE old_NtDeviceIoControlFile;

#ifdef _AMD64_
// stuff for function code patching
ULONG NtDeviceIoControlFile_BytesPatched = 0;
NT_DEVICE_IO_CONTROL_FILE f_NtDeviceIoControlFile = NULL;
#endif

RTL_OSVERSIONINFOW m_VersionInformation;

PDEVICE_OBJECT m_DeviceObject = NULL;
UNICODE_STRING m_usDosDeviceName, m_usDeviceName;
UNICODE_STRING m_RegistryPath;

PCOMMON_LST m_ProcessesList = NULL;
KMUTEX m_CommonMutex;

BOOLEAN m_bHooksInitialized = FALSE;

/**
 * Fuzzing settings
 * defined in handlers.cpp
 */
extern FUZZING_TYPE m_FuzzingType;
extern ULONG m_FuzzOptions;

extern HANDLE m_FuzzThreadId;
extern PEPROCESS m_FuzzProcess;
extern PUSER_MODE_DATA m_UserModeData;

PSERVICE_DESCRIPTOR_TABLE m_KeServiceDescriptorTable = NULL;
#define SYSTEM_SERVICE(_p_) m_KeServiceDescriptorTable->Entry[0].ServiceTableBase[_p_]

// defined in log.cpp
extern HANDLE m_hIoctlsLogFile;
extern UNICODE_STRING m_usIoctlsLogFilePath;

//extern "C" PUSHORT NtBuildNumber;
//extern "C" NTSTATUS NTAPI DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath);
//--------------------------------------------------------------------------------------
ULONG GetPrevModeOffset(void)
{
    ULONG Ret = 0;

    PVOID KernelBase = KernelGetModuleBase("ntoskrnl.exe");
    if (KernelBase)
    {
        // get address of nt!ExGetPreviousMode()
        ULONG Func_RVA = KernelGetExportAddress(KernelBase, "ExGetPreviousMode");
        if (Func_RVA > 0)
        {
            PUCHAR Func = (PUCHAR)RVATOVA(KernelBase, Func_RVA);

#ifdef _X86_

            /*
                nt!ExGetPreviousMode:
                8052b334 64a124010000    mov     eax,dword ptr fs:[00000124h]
                8052b33a 8a8040010000    mov     al,byte ptr [eax+140h]
                8052b340 c3              ret
            */

            // check for mov instruction
            if (*(PUSHORT)(Func + 6) == 0x808a)
            {
                // get offset value from second operand
                Ret = *(PULONG)(Func + 8);
            }

#elif _AMD64_
    
            /*
                nt!ExGetPreviousMode:
                fffff800`02691d50 65488b042588010000 mov     rax,qword ptr gs:[188h]
                fffff800`02691d59 8a80f6010000       mov     al,byte ptr [rax+1F6h]
                fffff800`02691d5f c3                 ret
            */

            // check for mov instruction
            if (*(PUSHORT)(Func + 9) == 0x808a)
            {
                // get offset value from second operand
                Ret = *(PULONG)(Func + 11);
            }
#endif

        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Symbol nt!KeServiceDescriptorTable is not found\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Unable to locate kernel base\n");
    }

    if (Ret)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): KTHREAD::PreviousMode offset is 0x%.4x\n", Ret);
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
PVOID GetKeSDT(void)
{
    PVOID Ret = NULL;

#ifdef _X86_

    PVOID KernelBase = KernelGetModuleBase("ntoskrnl.exe");
    if (KernelBase)
    {
        ULONG KeSDT_RVA = KernelGetExportAddress(KernelBase, "KeServiceDescriptorTable");
        if (KeSDT_RVA > 0)
        {
            Ret = RVATOVA(KernelBase, KeSDT_RVA);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Symbol nt!KeServiceDescriptorTable is not found\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Unable to locate kernel base\n");
    }

#elif _AMD64_

    #define MAX_INST_LEN 24

    PVOID KernelBase = KernelGetModuleBase("ntoskrnl.exe");
    if (KernelBase)
    {
        ULONG Func_RVA = KernelGetExportAddress(KernelBase, "KeAddSystemServiceTable");
        if (Func_RVA > 0)
        {
			UCHAR ud_mode = 64;
			ULONG i = 0;


            // initialize disassembler engine
            ud_t ud_obj;
            ud_init(&ud_obj);

            

            // set mode, syntax and vendor
            ud_set_mode(&ud_obj, ud_mode);
            ud_set_syntax(&ud_obj, UD_SYN_INTEL);
            ud_set_vendor(&ud_obj, UD_VENDOR_INTEL);

            for (i = 0; i < 0x40;)
            {
				ULONG InstLen = 0;
                PUCHAR Inst = (PUCHAR)RVATOVA(KernelBase, Func_RVA + i);
                if (!MmIsAddressValid(Inst))
                {
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Invalid memory at "IFMT"\n", Inst);
                    break;
                }
                            
                ud_set_input_buffer(&ud_obj, Inst, MAX_INST_LEN);

                // get length of the instruction
                InstLen = ud_disassemble(&ud_obj);
                if (InstLen == 0)
                {
                    // error while disassembling instruction
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't disassemble instruction at "IFMT"\n", Inst);
                    break;
                }

                /*
                    Check for the following code

                    nt!KeAddSystemServiceTable:
                    fffff800`012471c0 448b542428         mov     r10d,dword ptr [rsp+28h]
                    fffff800`012471c5 4183fa01           cmp     r10d,1
                    fffff800`012471c9 0f871ab70c00       ja      nt!KeAddSystemServiceTable+0x78
                    fffff800`012471cf 498bc2             mov     rax,r10
                    fffff800`012471d2 4c8d1d278edbff     lea     r11,0xfffff800`01000000
                    fffff800`012471d9 48c1e005           shl     rax,5
                    fffff800`012471dd 4a83bc1880bb170000 cmp     qword ptr [rax+r11+17BB80h],0
                    fffff800`012471e6 0f85fdb60c00       jne     nt!KeAddSystemServiceTable+0x78
                */

                if ((*(PULONG)Inst & 0x00ffffff) == 0x1d8d4c &&
                    (*(PUSHORT)(Inst + 0x0b) == 0x834b || *(PUSHORT)(Inst + 0x0b) == 0x834a))
                {
                    // clculate nt!KeServiceDescriptorTableAddress
                    LARGE_INTEGER Addr;
                    Addr.QuadPart = (ULONGLONG)Inst + InstLen;
                    Addr.LowPart += *(PULONG)(Inst + 0x03) + *(PULONG)(Inst + 0x0f);

                    Ret = (PVOID)Addr.QuadPart;

                    break;
                }

                i += InstLen;
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Symbol nt!KeServiceDescriptorTable is not found\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Unable to locate kernel base\n");
    }

#endif

    if (Ret)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): nt!KeServiceDescriptorTable is at "IFMT"\n", Ret);
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
ULONG LoadSyscallNumber(char *lpszName)
{    
    ULONG Ret = -1;
    UNICODE_STRING usName;    
    ANSI_STRING asName;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    RtlInitAnsiString(&asName, lpszName);    
    ns = RtlAnsiStringToUnicodeString(&usName, &asName, TRUE);
    if (NT_SUCCESS(ns))
    {
        HANDLE hKey = NULL;
        OBJECT_ATTRIBUTES ObjAttr;
        InitializeObjectAttributes(&ObjAttr, &m_RegistryPath, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

        // open service key
        ns = ZwOpenKey(&hKey, KEY_ALL_ACCESS, &ObjAttr);
        if (NT_SUCCESS(ns))        
        {
            PVOID Val = NULL;
            ULONG ValSize = 0;
            WCHAR wcValueName[0x100];
            swprintf(wcValueName, L"%wZ", &usName);

            if (RegQueryValueKey(hKey, wcValueName, REG_DWORD, &Val, &ValSize))
            {
                if (ValSize == sizeof(ULONG))
                {
                    Ret = *(PULONG)Val;
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"() WARNING: Invalid size for '%ws' value\n", wcValueName);
                }

                M_FREE(Val);
            }

            if (Ret == -1)
            {
                Ret = GetSyscallNumber(lpszName);
                if (Ret != -1)
                {
                    RegSetValueKey(hKey, wcValueName, REG_DWORD, (PVOID)&Ret, sizeof(ULONG));
                }
            }

            ZwClose(hKey);        
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "ZwOpenKey() fails; status: 0x%.8x\n", ns);
        }

        RtlFreeUnicodeString(&usName);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "RtlAnsiStringToUnicodeString() fails; status: 0x%.8x\n", ns);
    }    

    return Ret;
}
//--------------------------------------------------------------------------------------
BOOLEAN InitSdtNumbers(void)
{
	PVOID KernelBase = NULL;
    m_SDT_NtDeviceIoControlFile = LoadSyscallNumber("NtDeviceIoControlFile");
    m_SDT_NtProtectVirtualMemory = LoadSyscallNumber("NtProtectVirtualMemory");
    
    DbgMsg(__FILE__, __LINE__, "SDT number of NtDeviceIoControlFile:  0x%.8x\n", m_SDT_NtDeviceIoControlFile);
    DbgMsg(__FILE__, __LINE__, "SDT number of NtProtectVirtualMemory: 0x%.8x\n", m_SDT_NtProtectVirtualMemory);
    
#ifdef _AMD64_

    // get nt!KiServiceInternal address
    KernelBase = KernelGetModuleBase("ntoskrnl.exe");
    if (KernelBase)
    {
        // get address of nt!ZwCreateFile()
        ULONG FuncOffset = KernelGetExportAddress(KernelBase, "ZwCreateFile");
        if (FuncOffset > 0)
        {
            PUCHAR FuncAddr = (PUCHAR)RVATOVA(KernelBase, FuncOffset);
/*
            nt!ZwCreateFile:
            fffff800`0169c800 488bc4          mov     rax,rsp
            fffff800`0169c803 fa              cli
            fffff800`0169c804 4883ec10        sub     rsp,10h
            fffff800`0169c808 50              push    rax
            fffff800`0169c809 9c              pushfq
            fffff800`0169c80a 6a10            push    10h
            fffff800`0169c80c 488d052d4b0000  lea     rax,[nt!KiServiceLinkage (fffff800`016a1340)]
            fffff800`0169c813 50              push    rax
            fffff800`0169c814 b852000000      mov     eax,52h
            fffff800`0169c819 e962430000      jmp     nt!KiServiceInternal (fffff800`016a0b80)
*/
            PUCHAR JmpAddr = FuncAddr + 25;
            if (*JmpAddr == 0xE9)
            {
                _KiServiceInternal = (PVOID)((PCHAR)JmpAddr + *(PLONG)(JmpAddr + 1) + 5);
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): nt!KiServiceInternal is at "IFMT"\n", _KiServiceInternal);
            }             
            else
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't find nt!KiServiceInternal\n");
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't get address of nt!ZwCreateFile\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't get kernel base address\n");
    } 

#endif // _AMD64_
    
    if (m_SDT_NtDeviceIoControlFile > 0 && m_SDT_NtProtectVirtualMemory > 0)
    {
        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: GetSyscallNumber() fails for one or more function\n");
    }
    
    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN SetUpHooks(void)
{
    if (m_bHooksInitialized)
    {
        // hooks is allready initialized
        return TRUE;
    }

    // lookup for SDT indexes
    if (!InitSdtNumbers())
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: InitSdtNumbers() fails\n");
        return FALSE;
    }

    if (m_KeServiceDescriptorTable = (PSERVICE_DESCRIPTOR_TABLE)GetKeSDT())
    {
		PULONG KiST = NULL;
		LARGE_INTEGER Addr;
        // disable memory write protection
        ForEachProcessor(ClearWp, NULL);                

#ifdef _X86_        

        // set up hook
        old_NtDeviceIoControlFile = (NT_DEVICE_IO_CONTROL_FILE)InterlockedExchange(
            (PLONG)&SYSTEM_SERVICE(m_SDT_NtDeviceIoControlFile), 
            (LONG)new_NtDeviceIoControlFile
        );

//         DbgMsg(
//             __FILE__, __LINE__, 
//             "Hooking nt!NtDeviceIoControlFile(): "IFMT" -> "IFMT"\n",
//             old_NtDeviceIoControlFile, new_NtDeviceIoControlFile
//         );

#elif _AMD64_

        KiST = (PULONG)m_KeServiceDescriptorTable->Entry[0].ServiceTableBase;
               
        
        /*
            Calculate address of nt!NtDeviceIoControlFile() by offset
            from the begining of nt!KiServiceTable.
            Low 15 bits stores number of in-memory arguments.
        */
        Addr.QuadPart = (LONGLONG)KiST;

        if (m_VersionInformation.dwMajorVersion >= 6)
        {
            // Vista and newer
            ULONG Val = *(KiST + m_SDT_NtDeviceIoControlFile);
            Val -= *(KiST + m_SDT_NtDeviceIoControlFile) & 15;
            Addr.LowPart += Val >> 4;
        }
        else
        {
            // Server 2003
            Addr.LowPart += *(KiST + m_SDT_NtDeviceIoControlFile);
            Addr.LowPart -= *(KiST + m_SDT_NtDeviceIoControlFile) & 15;
        }        

        f_NtDeviceIoControlFile = (NT_DEVICE_IO_CONTROL_FILE)Addr.QuadPart;

        DbgMsg(
            __FILE__, __LINE__, 
            __FUNCTION__"(): nt!NtDeviceIoControlFile() is at "IFMT"\n",
            Addr.QuadPart
        );

//         DbgMsg(
//             __FILE__, __LINE__, 
//             "Hooking nt!NtDeviceIoControlFile(): "IFMT" -> "IFMT"\n",
//             f_NtDeviceIoControlFile, new_NtDeviceIoControlFile
//         );

        old_NtDeviceIoControlFile = (NT_DEVICE_IO_CONTROL_FILE)Hook(
            f_NtDeviceIoControlFile,
            new_NtDeviceIoControlFile,
            &NtDeviceIoControlFile_BytesPatched
        );

#endif

        // enable memory write protection
        ForEachProcessor(SetWp, NULL);        

        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: GetKeSDT() fails\n");
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN RemoveHooks(void)
{
    if (m_SDT_NtDeviceIoControlFile == 0)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: m_SDT_NtDeviceIoControlFile is not initialized\n");
        return FALSE;
    }

    if (m_KeServiceDescriptorTable == NULL)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: m_KeServiceDescriptorTable is not initialized\n");
        return FALSE;
    }

    if (old_NtDeviceIoControlFile)
    {
        ForEachProcessor(ClearWp, NULL);

#ifdef _X86_

        // restore changed address in nt!KiServiceTable
        InterlockedExchange(
            (PLONG)&SYSTEM_SERVICE(m_SDT_NtDeviceIoControlFile), 
            (LONG)old_NtDeviceIoControlFile
        );

#elif _AMD64_

        // restore patched function code
        memcpy(f_NtDeviceIoControlFile, old_NtDeviceIoControlFile, NtDeviceIoControlFile_BytesPatched);

#endif

        ForEachProcessor(SetWp, NULL);
    }

    m_bHooksInitialized = FALSE;

    return TRUE;
}
//--------------------------------------------------------------------------------------
void SetPreviousMode(KPROCESSOR_MODE Mode)
{
    PRKTHREAD CurrentThread = KeGetCurrentThread();
    *((PUCHAR)CurrentThread + m_KTHREAD_PrevMode) = (UCHAR)Mode;
}
//--------------------------------------------------------------------------------------
BOOLEAN SaveFuzzerOptions(void)
{
    HANDLE hKey = NULL;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    OBJECT_ATTRIBUTES ObjAttr;
    InitializeObjectAttributes(&ObjAttr, &m_RegistryPath, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

    // open service key
    ns = ZwOpenKey(&hKey, KEY_ALL_ACCESS, &ObjAttr);
    if (NT_SUCCESS(ns))
    {
        UNICODE_STRING usAllowRules, usDenyRules;
        RtlInitUnicodeString(&usAllowRules, L"_allow_rules");
        RtlInitUnicodeString(&usDenyRules, L"_deny_rules");

        // save allow rules
        SaveAllowRules(hKey, &usAllowRules);

        // save deny rules
        SaveDenyRules(hKey, &usDenyRules);

        // save options
        RegSetValueKey(hKey, L"_options", REG_DWORD, (PVOID)&m_FuzzOptions, sizeof(ULONG));

        // save fuzzing type
        RegSetValueKey(hKey, L"_fuzzing_type", REG_DWORD, (PVOID)&m_FuzzingType, sizeof(ULONG));

        ZwClose(hKey);
        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwOpenKey() fails; status: 0x%.8x\n", ns);
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN DeleteSavedFuzzerOptions(void)
{
    HANDLE hKey = NULL;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    OBJECT_ATTRIBUTES ObjAttr;
    InitializeObjectAttributes(&ObjAttr, &m_RegistryPath, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

    // open service key
    ns = ZwOpenKey(&hKey, KEY_ALL_ACCESS, &ObjAttr);
    if (NT_SUCCESS(ns))
    {
        UNICODE_STRING usAllowRules, usDenyRules, usOptions, usFuzzingType;
        RtlInitUnicodeString(&usAllowRules, L"_allow_rules");
        RtlInitUnicodeString(&usDenyRules, L"_deny_rules");
        RtlInitUnicodeString(&usOptions, L"_options");
        RtlInitUnicodeString(&usFuzzingType, L"_fuzzing_type");

        // remove saved options
        ZwDeleteValueKey(hKey, &usAllowRules);
        ZwDeleteValueKey(hKey, &usDenyRules);
        ZwDeleteValueKey(hKey, &usOptions);
        ZwDeleteValueKey(hKey, &usFuzzingType);

        ZwClose(hKey);
        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwOpenKey() fails; status: 0x%.8x\n", ns);
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN LoadFuzzerOptions(void)
{
    HANDLE hKey = NULL;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    OBJECT_ATTRIBUTES ObjAttr;
    InitializeObjectAttributes(&ObjAttr, &m_RegistryPath, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

    // open service key
    ns = ZwOpenKey(&hKey, KEY_ALL_ACCESS, &ObjAttr);
    if (NT_SUCCESS(ns))
    {
		PVOID Val = NULL;
		ULONG ValSize = 0;
        BOOLEAN bBootFuzzingEnabled = FALSE;
        UNICODE_STRING usAllowRules, usDenyRules;
        RtlInitUnicodeString(&usAllowRules, L"_allow_rules");
        RtlInitUnicodeString(&usDenyRules, L"_deny_rules");

        // try to load options
        
        if (RegQueryValueKey(hKey, L"_options", REG_DWORD, &Val, &ValSize))
        {
            if (ValSize == sizeof(ULONG))
            {
                m_FuzzOptions = *(PULONG)Val;
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): m_FuzzOptions has been set to 0x%.8x\n", m_FuzzOptions);

                if (m_FuzzOptions & FUZZ_OPT_FUZZ_BOOT)
                {
                     bBootFuzzingEnabled = TRUE;
                }
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"() WARNING: Invalid size for '_options' value\n");
            }

            M_FREE(Val);
        }

        if (bBootFuzzingEnabled)
        {
            if (RegQueryValueKey(hKey, L"_fuzzing_type", REG_DWORD, &Val, &ValSize))
            {
                if (ValSize == sizeof(ULONG))
                {
                    m_FuzzingType = *(PULONG)Val;
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): m_FuzzingType has been set to 0x%.8x\n", m_FuzzingType);
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"() WARNING: Invalid size for '_fuzzing_type' value\n");
                }

                M_FREE(Val);
            }

            // load allow rules
            LoadAllowRules(hKey, &usAllowRules);

            // load deny rules
            LoadDenyRules(hKey, &usDenyRules);
        }        

        ZwClose(hKey);
        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwOpenKey() fails; status: 0x%.8x\n", ns);
    }  

    return FALSE;
}
//--------------------------------------------------------------------------------------
PFILE_OBJECT GetDeviceObjectPointer(PUNICODE_STRING usDeviceName)
{
    PFILE_OBJECT pObject = NULL;
    HANDLE hDevice = NULL;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    OBJECT_ATTRIBUTES ObjAttr;
    IO_STATUS_BLOCK StatusBlock;

    InitializeObjectAttributes(&ObjAttr, usDeviceName, OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    ns = ZwOpenFile(
        &hDevice, 
        FILE_READ_DATA | FILE_WRITE_DATA | SYNCHRONIZE, 
        &ObjAttr, 
        &StatusBlock, 
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        FILE_SYNCHRONOUS_IO_NONALERT
    );
    if (NT_SUCCESS(ns))
    {
        ns = ObReferenceObjectByHandle(hDevice, 0, *IoFileObjectType, KernelMode, (PVOID *)&pObject, NULL);
        if (!NT_SUCCESS(ns))
        {
            DbgMsg(__FILE__, __LINE__, "ObReferenceObjectByHandle() fails; status: 0x%.8x\n", ns);
        } 

        ZwClose(hDevice);
    }
    else
    {
        DbgMsg(
            __FILE__, __LINE__, "Error while opening \"%wZ\"; status: 0x%.8x\n", 
            usDeviceName, ns
        );
    }

    return pObject;
}
//--------------------------------------------------------------------------------------
NTSTATUS DriverDispatch(PDEVICE_OBJECT DeviceObject, PIRP Irp)
{
    PIO_STACK_LOCATION stack;
    NTSTATUS ns = STATUS_SUCCESS;

    Irp->IoStatus.Status = ns;
    Irp->IoStatus.Information = 0;

    stack = IoGetCurrentIrpStackLocation(Irp);

    if (stack->MajorFunction == IRP_MJ_DEVICE_CONTROL) 
    {
        ULONG Code = stack->Parameters.DeviceIoControl.IoControlCode;        
        ULONG Size = stack->Parameters.DeviceIoControl.InputBufferLength;
        PREQUEST_BUFFER Buff = (PREQUEST_BUFFER)Irp->AssociatedIrp.SystemBuffer;

#ifdef DBG_IO

        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): IRP_MJ_DEVICE_CONTROL 0x%.8x\n", Code);
#endif
        Irp->IoStatus.Information = Size;

        switch (Code)
        {
        case IOCTL_DRV_CONTROL:
            {
                Buff->Status = S_ERROR;

                if (Size >= sizeof(REQUEST_BUFFER))
                {
                    ULONG KdCommandLength = 0;
                    IOCTL_FILTER Flt;                    
                    RtlZeroMemory(&Flt, sizeof(Flt));

                    if (Buff->AddObject.bDbgcbAction && Size > sizeof(REQUEST_BUFFER))
                    {
                        // check for zero byte at the end of the string
                        if (Buff->Buff[Size - sizeof(REQUEST_BUFFER) - 1] != 0)
                        {          
                            goto _bad_addobj_request;
                        }

                        // debugger command available
                        KdCommandLength = strlen(Buff->Buff) + 1;
                    }

                    switch (Buff->Code)
                    {
                    case C_ADD_DRIVER:
                    case C_ADD_DEVICE:
                    case C_ADD_PROCESS:
                    case C_ADD_IOCTL:
                        {
                            // check for zero byte at the end of the string
                            if (Buff->AddObject.szObjectName[MAX_REQUEST_STRING - 1] != 0)
                            {          
                                goto _bad_addobj_request;
                            }

                            if (Buff->Code == C_ADD_IOCTL)
                            {
                                Flt.IoctlCode = Buff->AddObject.IoctlCode;
                            }
                            else
                            {
                                ANSI_STRING asName;

                                RtlInitAnsiString(
                                    &asName,
                                    Buff->AddObject.szObjectName
                                );

                                ns = RtlAnsiStringToUnicodeString(&Flt.usName, &asName, TRUE);
                                if (!NT_SUCCESS(ns))
                                {
                                    DbgMsg(__FILE__, __LINE__, "RtlAnsiStringToUnicodeString() fails; status: 0x%.8x\n", ns);
                                    goto _bad_addobj_request;
                                }
                            }                            
                                    
                            switch (Buff->Code)
                            {
                            case C_ADD_DRIVER:

                                // filter by driver file name/path
                                Flt.Type = FLT_DRIVER_NAME;
                                break;

                            case C_ADD_DEVICE:

                                // filter by device name
                                Flt.Type = FLT_DEVICE_NAME;
                                break;

                            case C_ADD_PROCESS:

                                // filter by caller process executable file name/path
                                Flt.Type = FLT_PROCESS_PATH;
                                break;

                            case C_ADD_IOCTL:

                                // filter by IOCTL control code value
                                Flt.Type = FLT_IOCTL_CODE;
                                break;
                            }   

                            KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, NULL); 

                            __try
                            {
                                PIOCTL_FILTER f_entry = NULL;

                                if (Buff->AddObject.bAllow)
                                {
                                    // add filter rule into the ALLOW list
                                    if (f_entry = FltAddAllowRule(&Flt, KdCommandLength))
                                    {
                                        Buff->Status = S_SUCCESS;
                                    }
                                }    
                                else
                                {
                                    // add filter rule into the DENY list
                                    if (f_entry = FltAddDenyRule(&Flt, KdCommandLength))
                                    {
                                        Buff->Status = S_SUCCESS;
                                    }
                                }

                                if (f_entry)
                                {
                                    f_entry->bDbgcbAction = Buff->AddObject.bDbgcbAction;
                                    if (KdCommandLength > 0)
                                    {
                                        strcpy(f_entry->szKdCommand, Buff->Buff);

                                        if (Buff->Code == C_ADD_IOCTL)
                                        {
                                            DbgPrint(
                                                "<?dml?>" __FUNCTION__ "(): ControlCode=0x%.8x KdCommand=<exec cmd=\"%s\">%s</exec>\n",
                                                f_entry->IoctlCode, f_entry->szKdCommand, f_entry->szKdCommand
                                            );
                                        }
                                        else
                                        {
                                            DbgPrint(
                                                "<?dml?>" __FUNCTION__ "(): Object=\"%wZ\" KdCommand=<exec cmd=\"%s\">%s</exec>\n",
                                                &f_entry->usName, f_entry->szKdCommand, f_entry->szKdCommand
                                            );
                                        }

                                        // 减少引用计数
                                        DeferenceRuleCount(f_entry);
                                    }
                                }
                            }    
                            __finally
                            {
                                KeReleaseMutex(&m_CommonMutex, FALSE);
                            }    

                            if (Buff->Status != S_SUCCESS &&
                                Buff->Code != C_ADD_IOCTL)
                            {
                                RtlFreeUnicodeString(&Flt.usName);
                            }
_bad_addobj_request:
                            break;
                        }

                    case C_DEL_OPTIONS:
                        {
                            DeleteSavedFuzzerOptions();
                            break;
                        }                    

                    case C_SET_OPTIONS:
                        {
							PLARGE_INTEGER FuzzThreadId = NULL;
                            KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, NULL);   

                            __try
                            {
                                m_FuzzOptions = Buff->Options.Options;

                                if (!(m_FuzzOptions & FUZZ_OPT_NO_SDT_HOOKS))
                                {
                                    // hook nt!NtDeviceIoControlFile() syscall
                                    m_bHooksInitialized = SetUpHooks();
                                }

                                if (!(m_FuzzOptions & FUZZ_OPT_LOG_IOCTL_GLOBAL) && m_hIoctlsLogFile)
                                {
                                    ZwClose(m_hIoctlsLogFile);
                                    m_hIoctlsLogFile = NULL;

                                    DbgMsg(__FILE__, __LINE__, "[+] IOCTLs log closed \"%wZ\"\n", &m_usIoctlsLogFilePath);
                                }
                                
                                m_FuzzingType = Buff->Options.FuzzingType;
                                m_UserModeData = Buff->Options.UserModeData;
#ifdef _X86_
                                m_FuzzThreadId = (HANDLE)Buff->Options.FuzzThreadId;
#elif _AMD64_
                                FuzzThreadId = (PLARGE_INTEGER)&m_FuzzThreadId;
                                FuzzThreadId->HighPart = 0;
                                FuzzThreadId->LowPart = Buff->Options.FuzzThreadId;
#endif                                 
                                if (m_FuzzOptions & FUZZ_OPT_FUZZ_BOOT)
                                {
                                    // boot fuzzing mode has been enabled
                                    SaveFuzzerOptions();
                                    m_FuzzOptions = 0;
                                }
                                else
                                {
                                    DeleteSavedFuzzerOptions();
                                }

                                Buff->Status = S_SUCCESS;
                            }                           
                            __finally
                            {
                                KeReleaseMutex(&m_CommonMutex, FALSE);
                            }                            

                            break;
                        }

                    case C_GET_DEVICE_INFO:
                        {
                            // check for zero byte at the end of the string
                            if (Size > sizeof(REQUEST_BUFFER) &&
                                Buff->Buff[Size - sizeof(REQUEST_BUFFER) - 1] == 0)
                            {          
                                ANSI_STRING asDeviceName;
                                UNICODE_STRING usDeviceName;

                                RtlInitAnsiString(
                                    &asDeviceName,
                                    Buff->Buff
                                );

                                ns = RtlAnsiStringToUnicodeString(&usDeviceName, &asDeviceName, TRUE);
                                if (NT_SUCCESS(ns))
                                {
                                    // open disk device object
                                    PDEVICE_OBJECT TargetDeviceObject = NULL;
                                    PFILE_OBJECT TargetFileObject = NULL;
#ifdef USE_IoGetDeviceObjectPointer
                                    ns = IoGetDeviceObjectPointer(
                                        &usDeviceName, 
                                        GENERIC_READ | GENERIC_WRITE | SYNCHRONIZE,
                                        &TargetFileObject, 
                                        &TargetDeviceObject
                                    );
                                    if (NT_SUCCESS(ns))     
#else
                                    if (TargetFileObject = GetDeviceObjectPointer(&usDeviceName))
                                    {
                                        TargetDeviceObject = TargetFileObject->DeviceObject;
                                    }

                                    if (TargetFileObject)
#endif
                                    {
                                        // pass device object information to the caller
                                        Buff->DeviceInfo.DeviceObjectAddr = TargetDeviceObject;
                                        if (TargetDeviceObject->DriverObject)
                                        {
											PLDR_DATA_TABLE_ENTRY pModuleEntry = NULL;
											POBJECT_NAME_INFORMATION NameInfo = NULL;
                                            Buff->DeviceInfo.DriverObjectAddr = TargetDeviceObject->DriverObject;

                                            // get driver object name by pointer
                                            NameInfo = GetObjectName(TargetDeviceObject->DriverObject);
                                            if (NameInfo)
                                            {
                                                ANSI_STRING asDriverName;
                                                ns = RtlUnicodeStringToAnsiString(&asDriverName, &NameInfo->Name, TRUE);
                                                if (NT_SUCCESS(ns))
                                                {
                                                    strncpy(
                                                        Buff->DeviceInfo.szDriverObjectName,
                                                        asDriverName.Buffer,
                                                        min(MAX_REQUEST_STRING - 1, asDriverName.Length)
                                                    );

                                                    RtlFreeAnsiString(&asDriverName);
                                                }
                                                else
                                                {
                                                    DbgMsg(__FILE__, __LINE__, "RtlUnicodeStringToAnsiString() fails; status: 0x%.8x\n", ns);                                                
                                                }

                                                ExFreePool(NameInfo);
                                            }

                                            // get loader information entry for the driver
                                            pModuleEntry = (PLDR_DATA_TABLE_ENTRY)
                                                TargetDeviceObject->DriverObject->DriverSection;

                                            if (pModuleEntry && 
                                                MmIsAddressValid(pModuleEntry) && 
                                                ValidateUnicodeString(&pModuleEntry->FullDllName))
                                            {
                                                ANSI_STRING asDllName;
                                                ns = RtlUnicodeStringToAnsiString(&asDllName, &pModuleEntry->FullDllName, TRUE);
                                                if (NT_SUCCESS(ns))
                                                {
                                                    strncpy(
                                                        Buff->DeviceInfo.szDriverFilePath,
                                                        asDllName.Buffer,
                                                        min(MAX_REQUEST_STRING - 1, asDllName.Length)
                                                    );

                                                    RtlFreeAnsiString(&asDllName);
                                                }
                                                else
                                                {
                                                    DbgMsg(__FILE__, __LINE__, "RtlUnicodeStringToAnsiString() fails; status: 0x%.8x\n", ns);                                                
                                                }
                                            }

                                            Buff->Status = S_SUCCESS;
                                        }                                 

                                        ObDereferenceObject(TargetFileObject);
                                    }
#ifdef USE_IoGetDeviceObjectPointer
                                    else
                                    {
                                        DbgMsg(
                                            __FILE__, __LINE__, 
                                            "IoGetDeviceObjectPointer() fails for \"%wZ\", status: 0x%.8x\n", 
                                            &usDeviceName, ns
                                        );                                                
                                    }
#endif
                                    RtlFreeUnicodeString(&usDeviceName);          
                                }
                                else
                                {
                                    DbgMsg(__FILE__, __LINE__, "RtlAnsiStringToUnicodeString() fails; status: 0x%.8x\n", ns);
                                }
                            }

                            break;
                        }

                    case C_GET_OBJECT_NAME:
                        {
                            PFILE_OBJECT pFileObject = NULL;
                            ns = ObReferenceObjectByHandle(
                                Buff->ObjectName.hObject, 
                                0, 
                                *IoFileObjectType, 
                                KernelMode, 
                                (PVOID *)&pFileObject, 
                                NULL
                            );
                            if (NT_SUCCESS(ns))
                            {
                                if (pFileObject->DeviceObject)
                                {
                                    // get name of the object
                                    POBJECT_NAME_INFORMATION NameInfo = GetObjectName(pFileObject->DeviceObject);
                                    if (NameInfo)
                                    {                        
                                        ANSI_STRING asName;
                                        ns = RtlUnicodeStringToAnsiString(&asName, &NameInfo->Name, TRUE);
                                        if (NT_SUCCESS(ns))
                                        {
                                            strncpy(
                                                Buff->ObjectName.szObjectName,
                                                asName.Buffer,
                                                min(MAX_REQUEST_STRING - 1, asName.Length)
                                            );

                                            Buff->Status = S_SUCCESS;

                                            RtlFreeAnsiString(&asName);
                                        }
                                        else
                                        {
                                            DbgMsg(__FILE__, __LINE__, "RtlUnicodeStringToAnsiString() fails; status: 0x%.8x\n", ns);
                                        }

                                        M_FREE(NameInfo);
                                    }
                                }

                                ObDereferenceObject(pFileObject);
                            } 
                            else
                            {
                                DbgMsg(__FILE__, __LINE__, "ObReferenceObjectByHandle() fails; status: 0x%.8x\n", ns);
                            }                 

                            break;
                        }

                    case C_CHECK_HOOKS:
                        {
                            if (m_bHooksInitialized)
                            {
                                Buff->CheckHooks.bHooksInstalled = TRUE;
                            }
                            else
                            {
                                Buff->CheckHooks.bHooksInstalled = FALSE;
                            }

                            break;
                        }
                    }
                }

                break;
            }            

        default:
            {
                ns = STATUS_INVALID_DEVICE_REQUEST;
                Irp->IoStatus.Information = 0;
                break;
            }            
        }
    }
    else if (stack->MajorFunction == IRP_MJ_CREATE) 
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): IRP_MJ_CREATE\n");

#ifdef DBGPIPE

        DbgOpenPipe();
#endif
        KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, NULL);

        __try
        {
            // delete all filter rules
            FltFlushAllList();

            m_FuzzProcess = PsGetCurrentProcess();
            ObReferenceObject(m_FuzzProcess);
        }        
        __finally
        {
            KeReleaseMutex(&m_CommonMutex, FALSE);
        }        
    }
    else if (stack->MajorFunction == IRP_MJ_CLOSE) 
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): IRP_MJ_CLOSE\n");        

        KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, NULL);   

        __try
        {
            // delete all filter rules
            FltFlushAllList();

            m_FuzzOptions = 0;

            if (m_FuzzProcess)
            {
                ObDereferenceObject(m_FuzzProcess);
                m_FuzzProcess = NULL;
            }
        }
        __finally
        {
            KeReleaseMutex(&m_CommonMutex, FALSE);
        }                

#ifdef DBGPIPE

        DbgClosePipe();
#endif

        if (m_hIoctlsLogFile)
        {
            ZwClose(m_hIoctlsLogFile);
            m_hIoctlsLogFile = NULL;

            DbgMsg(__FILE__, __LINE__, "[+] IOCTLs log closed \"%wZ\"\n", &m_usIoctlsLogFilePath);
        }
    }

    if (ns != STATUS_PENDING)
    {        
        Irp->IoStatus.Status = ns;
        IoCompleteRequest(Irp, IO_NO_INCREMENT);
    }

    return ns;
}
//--------------------------------------------------------------------------------------
void DriverUnload(PDRIVER_OBJECT DriverObject)
{   
	LARGE_INTEGER Timeout = { 0 };
    DbgMsg(__FILE__, __LINE__, "DriverUnload()\n");

    PsSetCreateProcessNotifyRoutine(ProcessNotifyRoutine, TRUE);    

    // delete device
    IoDeleteSymbolicLink(&m_usDosDeviceName);
    IoDeleteDevice(m_DeviceObject);

    KeWaitForMutexObject(&m_CommonMutex, Executive, KernelMode, FALSE, NULL);   

    // unhook NtDeviceIoControlFile() system service
    RemoveHooks();

    WaitHookRemoveComplete(); 

    __try
    {
        // delete all filter rules
        FltUnInitRuleList();
    }    
    __finally
    {
        KeReleaseMutex(&m_CommonMutex, FALSE);
    } 
 
    FreeProcessInfo();
    LstFree(m_ProcessesList);  

    Timeout.QuadPart = RELATIVE(SECONDS(1));
    KeDelayExecutionThread(KernelMode, FALSE, &Timeout);
}
//--------------------------------------------------------------------------------------
NTSTATUS NTAPI DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath)
{    
	LARGE_INTEGER TickCount;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    //DbgInit();
    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): '%wZ' "IFMT"\n", RegistryPath, KernelGetModuleBase("ioctlfuzzer.exe"));    

    DriverObject->DriverUnload = DriverUnload;

    RtlGetVersion(&m_VersionInformation);

    ns = FltInitRuleList();
    if(!NT_SUCCESS(ns))
        return ns;

    // initialize random number generator
    
    KeQueryTickCount(&TickCount);
    init_genrand(TickCount.LowPart);

    // Get offset of KTHREAD::PreviousMode field
    m_KTHREAD_PrevMode = GetPrevModeOffset();
    if (m_KTHREAD_PrevMode == 0)
    {
        DbgMsg(__FILE__, __LINE__, "Error while obtaining KTHREAD::PreviousMode offset\n");
        return STATUS_UNSUCCESSFUL;
    }

    m_ProcessesList = LstInit();
    if (m_ProcessesList == NULL)
    {
        return STATUS_UNSUCCESSFUL;
    }

    if (AllocUnicodeString(&m_RegistryPath, RegistryPath->MaximumLength))
    {
        RtlCopyUnicodeString(&m_RegistryPath, RegistryPath);
    }
    else
    {
        return STATUS_UNSUCCESSFUL;
    }

    KeInitializeMutex(&m_CommonMutex, 0);

    RtlInitUnicodeString(&m_usDeviceName, L"\\Device\\" DEVICE_NAME);
    RtlInitUnicodeString(&m_usDosDeviceName, L"\\DosDevices\\" DEVICE_NAME);    

    // create driver communication device
    ns = IoCreateDevice(
        DriverObject, 
        0, 
        &m_usDeviceName, 
        FILE_DEVICE_UNKNOWN, 
        FILE_DEVICE_SECURE_OPEN, 
        FALSE, 
        &m_DeviceObject
    );
    if (NT_SUCCESS(ns))
    {
        DriverObject->MajorFunction[IRP_MJ_CREATE]         = 
        DriverObject->MajorFunction[IRP_MJ_CLOSE]          = 
        DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DriverDispatch;

        ns = IoCreateSymbolicLink(&m_usDosDeviceName, &m_usDeviceName);
        if (NT_SUCCESS(ns))
        {
            ns = PsSetCreateProcessNotifyRoutine(ProcessNotifyRoutine, FALSE);
            if (NT_SUCCESS(ns))
            {
                // load options for boot fuzzing (if available)
                LoadFuzzerOptions();

                if (m_FuzzOptions & FUZZ_OPT_FUZZ_BOOT)
                {
                    // hook nt!NtDeviceIoControlFile() syscall
                    m_bHooksInitialized = SetUpHooks();
                }

                return STATUS_SUCCESS;
            }            
            else
            {
                DbgMsg(__FILE__, __LINE__, "PsSetCreateProcessNotifyRoutine() fails: 0x%.8x\n", ns);
            }

            IoDeleteSymbolicLink(&m_usDosDeviceName);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "IoCreateSymbolicLink() fails: 0x%.8x\n", ns);
        }

        IoDeleteDevice(m_DeviceObject);
    } 
    else 
    {
        DbgMsg(__FILE__, __LINE__, "IoCreateDevice() fails: 0x%.8x\n", ns);
    }

    return STATUS_UNSUCCESSFUL;
}
//--------------------------------------------------------------------------------------
// EoF
