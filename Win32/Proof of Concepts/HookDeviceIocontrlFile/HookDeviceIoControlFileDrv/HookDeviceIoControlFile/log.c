#include "stdafx.h"

// defined in handlers.cpp
extern ULONG m_FuzzOptions;

// defined in debug.cpp
extern HANDLE hDbgPipe;
extern KMUTEX DbgMutex;

#define LOG_BUFF_SIZE 0x1000

HANDLE m_hIoctlsLogFile = NULL;

WCHAR m_wcIoctlsLogFilePath[MAX_REQUEST_STRING];
UNICODE_STRING m_usIoctlsLogFilePath;
//--------------------------------------------------------------------------------------
void LogData(char *lpszFormat, ...)
{
    IO_STATUS_BLOCK IoStatusBlock;    
    va_list mylist;

    char *lpszBuff = (char *)M_ALLOC(LOG_BUFF_SIZE);
    if (lpszBuff == NULL)
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        return;
    }

    va_start(mylist, lpszFormat);
    vsprintf(lpszBuff, lpszFormat, mylist);	
    va_end(mylist);

    if (m_FuzzOptions & FUZZ_OPT_LOG_DEBUG)
    {
        // post message into debug output
        DbgPrint(lpszBuff);
    }

#ifdef DBGPIPE

    if (KeGetCurrentIrql() == PASSIVE_LEVEL)
    {
        KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

        if (hDbgPipe)
        {
            // write debug message into pipe
            IO_STATUS_BLOCK IoStatusBlock;
            ULONG Len = (ULONG)strlen(lpszBuff) + 1;

            ZwWriteFile(hDbgPipe, 0, NULL, NULL, &IoStatusBlock, (PVOID)&Len, sizeof(Len), NULL, NULL);
            ZwWriteFile(hDbgPipe, 0, NULL, NULL, &IoStatusBlock, lpszBuff, Len, NULL, NULL);
        }            

        KeReleaseMutex(&DbgMutex, FALSE);
    }

#endif // DBGPIPE

    M_FREE(lpszBuff);
}
//--------------------------------------------------------------------------------------
BOOLEAN LogDataIoctlsInitLogFile(void)
{
    BOOLEAN bRet = FALSE;
    UNICODE_STRING usNtdllPath;    
    OBJECT_ATTRIBUTES ObjAttr;
    HANDLE hNtdll = NULL;
    IO_STATUS_BLOCK StatusBlock;

	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    RtlInitUnicodeString(&usNtdllPath, L"\\SystemRoot\\system32\\ntdll.dll");
    InitializeObjectAttributes(&ObjAttr, &usNtdllPath, OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    // get file handle
    ns = ZwOpenFile(
        &hNtdll, 
        FILE_READ_DATA | SYNCHRONIZE, 
        &ObjAttr, 
        &StatusBlock, 
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        FILE_SYNCHRONOUS_IO_NONALERT
    );
    if (NT_SUCCESS(ns))
    {
        PFILE_OBJECT FileObject = NULL;

        // get file object by handle
        ns = ObReferenceObjectByHandle(hNtdll, 0, 0, KernelMode, (PVOID *)&FileObject, NULL);
        if (NT_SUCCESS(ns))
        {
            // get DOS path for file object
            POBJECT_NAME_INFORMATION ObjectNameInfo;
            ns = IoQueryFileDosDeviceName(FileObject, &ObjectNameInfo);
            if (NT_SUCCESS(ns))
            {                
                size_t DosDriveLen = wcslen(L"C:\\");
                RtlZeroMemory(m_wcIoctlsLogFilePath, sizeof(m_wcIoctlsLogFilePath));

                // check for valid DOS path
                if (ObjectNameInfo &&
                    ObjectNameInfo->Name.Length > (DosDriveLen * sizeof(WCHAR)) &&
                    ObjectNameInfo->Name.Buffer[1] == L':' &&
                    ObjectNameInfo->Name.Buffer[2] == L'\\')
                {
                    UNICODE_STRING usXmlPath;
                    wcscpy(m_wcIoctlsLogFilePath, L"\\??\\");
                    wcsncat(m_wcIoctlsLogFilePath, ObjectNameInfo->Name.Buffer, DosDriveLen);
                    wcscat(m_wcIoctlsLogFilePath, IOCTLS_LOG_NAME);
                    
                    RtlInitUnicodeString(&m_usIoctlsLogFilePath, m_wcIoctlsLogFilePath);
                    InitializeObjectAttributes(&ObjAttr, &m_usIoctlsLogFilePath, 
                        OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

                    // open IOCTLs log file
                    ns = ZwCreateFile(
                        &m_hIoctlsLogFile,
                        FILE_ALL_ACCESS | SYNCHRONIZE,
                        &ObjAttr,
                        &StatusBlock,
                        NULL,
                        FILE_ATTRIBUTE_NORMAL,
                        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                        FILE_OVERWRITE_IF,
                        FILE_SYNCHRONOUS_IO_NONALERT,
                        NULL, 0
                    );
                    if (NT_SUCCESS(ns))
                    {
                        DbgMsg(__FILE__, __LINE__, "[+] IOCTLs log started: \"%wZ\"\n\n", &m_usIoctlsLogFilePath);
                        bRet = TRUE;
                    }
                    else
                    {
                        DbgMsg(__FILE__, __LINE__, "ZwCreateFile() fails; status: 0x%.8x\n", ns);
                    }
                }
            }            
            else
            {
                DbgMsg(__FILE__, __LINE__, "IoQueryFileDosDeviceName() fails; status: 0x%.8x\n", ns);            
            }

            ObDereferenceObject(FileObject);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "ObReferenceObjectByHandle() fails; status: 0x%.8x\n", ns);            
        }

        ZwClose(hNtdll);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwOpenFile() fails; status: 0x%.8x\n", ns);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
void LogDataIoctls(char *lpszFormat, ...)
{
    IO_STATUS_BLOCK IoStatusBlock;
    va_list mylist;

    char *lpszBuff = (char *)M_ALLOC(LOG_BUFF_SIZE);
    if (lpszBuff == NULL)
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        return;
    }

    if (KeGetCurrentIrql() > PASSIVE_LEVEL)
    {
        // IRQL is too high
        return;
    }

    if ((m_FuzzOptions & FUZZ_OPT_LOG_IOCTL_GLOBAL) && m_hIoctlsLogFile == NULL)
    {
        // log file is not initialized, try to create it
        if (!LogDataIoctlsInitLogFile())
        {
            // ... fails
            return;
        }        
    }

    va_start(mylist, lpszFormat);
    vsprintf(lpszBuff, lpszFormat, mylist);	
    va_end(mylist);

    // write string into the log file
    ZwWriteFile(m_hIoctlsLogFile, 0, NULL, NULL, &IoStatusBlock, lpszBuff, (ULONG)strlen(lpszBuff), NULL, NULL);

    M_FREE(lpszBuff);
}
//--------------------------------------------------------------------------------------
void LogDataHexdump(PUCHAR Data, ULONG Size) 
{
    unsigned int dp = 0, p = 0;
    const char trans[] =
        "................................ !\"#$%&'()*+,-./0123456789"
        ":;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklm"
        "nopqrstuvwxyz{|}~...................................."
        "....................................................."
        "........................................";

    char szBuff[0x100], szChr[10];
    RtlZeroMemory(szBuff, sizeof(szBuff));

    for (dp = 1; dp <= Size; dp++)  
    {
        sprintf(szChr, "%02x ", Data[dp-1]);
        strcat(szBuff, szChr);

        if ((dp % 8) == 0)
        {
            strcat(szBuff, " ");
        }

        if ((dp % 16) == 0) 
        {
            strcat(szBuff, "| ");
            p = dp;

            for (dp -= 16; dp < p; dp++)
            {
                sprintf(szChr, "%c", trans[Data[dp]]);
                strcat(szBuff, szChr);
            }

            LogDataIoctls("%s\r\n", szBuff);
            RtlZeroMemory(szBuff, sizeof(szBuff));
        }
    }

    if ((Size % 16) != 0) 
    {
        p = dp = 16 - (Size % 16);

        for (dp = p; dp > 0; dp--) 
        {
            strcat(szBuff, "   ");

            if (((dp % 8) == 0) && (p != 8))
            {
                strcat(szBuff, " ");
            }
        }

        strcat(szBuff, " | ");
        for (dp = (Size - (16 - p)); dp < Size; dp++)
        {
            sprintf(szChr, "%c", trans[Data[dp]]);
            strcat(szBuff, szChr);
        }

        LogDataIoctls("%s\r\n", szBuff);
    }

    LogDataIoctls("\r\n");
}
//--------------------------------------------------------------------------------------
// EoF
