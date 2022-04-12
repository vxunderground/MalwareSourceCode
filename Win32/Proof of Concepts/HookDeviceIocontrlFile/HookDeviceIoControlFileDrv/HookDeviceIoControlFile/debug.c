#include "stdafx.h"

#define DBGMSG_BUFF_SIZE 0x1000

HANDLE hDbgPipe = NULL, hDbgLogFile = NULL;
KMUTEX DbgMutex;
//--------------------------------------------------------------------------------------
char *GetNameFromFullPath(char *lpszPath)
{
    char *lpszName = lpszPath;

	size_t i = 0;
    for (i = 0; i < strlen(lpszPath); i++)
    {
        if (lpszPath[i] == '\\' || lpszPath[i] == '/')
        {
            lpszName = lpszPath + i + 1;
        }
    }

    return lpszName;
}
//--------------------------------------------------------------------------------------
#ifdef DBGMSG_FULL
//--------------------------------------------------------------------------------------
void DbgMsg(char *lpszFile, int Line, char *lpszMsg, ...)
{
    va_list mylist;

	char *lpszOutBuff  = NULL;
    char *lpszBuff = (char *)M_ALLOC(DBGMSG_BUFF_SIZE);
    if (lpszBuff == NULL)
    {
        return;
    }

    lpszOutBuff = (char *)M_ALLOC(DBGMSG_BUFF_SIZE);
    if (lpszOutBuff == NULL)
    {
        M_FREE(lpszBuff);
        return;
    }

    va_start(mylist, lpszMsg);
    vsprintf(lpszBuff, lpszMsg, mylist);	
    va_end(mylist);

    sprintf(lpszOutBuff, "%s(%d) : %s", GetNameFromFullPath(lpszFile), Line, lpszBuff);	

#ifdef DBGMSG

    DbgPrint(lpszOutBuff);

#endif

#if defined(DBGPIPE) || defined(DBGLOGFILE)

    if (KeGetCurrentIrql() == PASSIVE_LEVEL)
    {
        KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

        if (hDbgPipe)
        {
            // write debug message into pipe
            IO_STATUS_BLOCK IoStatusBlock;
            ULONG Len = (ULONG)strlen(lpszOutBuff) + 1;

            ZwWriteFile(hDbgPipe, 0, NULL, NULL, &IoStatusBlock, (PVOID)&Len, sizeof(Len), NULL, NULL);
            ZwWriteFile(hDbgPipe, 0, NULL, NULL, &IoStatusBlock, lpszOutBuff, Len, NULL, NULL);
        }

        if (hDbgLogFile)
        {
            // write debug message into logfile
            IO_STATUS_BLOCK IoStatusBlock;
            ULONG Len = (ULONG)strlen(lpszOutBuff);

            ZwWriteFile(hDbgLogFile, 0, NULL, NULL, &IoStatusBlock, lpszOutBuff, Len, NULL, NULL);
        }

        KeReleaseMutex(&DbgMutex, FALSE);
    } 

#endif // DBGPIPE/DBGLOGFILE

    M_FREE(lpszBuff);
    M_FREE(lpszOutBuff);
}
//--------------------------------------------------------------------------------------
#ifdef DBGPIPE
//--------------------------------------------------------------------------------------
void DbgOpenPipe(void)
{
    OBJECT_ATTRIBUTES ObjAttr; 
    IO_STATUS_BLOCK IoStatusBlock;
    UNICODE_STRING usPipeName;

	NTSTATUS status = STATUS_UNSUCCESSFUL;

    RtlInitUnicodeString(&usPipeName, L"\\Device\\NamedPipe\\" DBG_PIPE_NAME);

    InitializeObjectAttributes(&ObjAttr, &usPipeName, 
        OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

    KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

    // open data pipe by name
    status = ZwCreateFile(
        &hDbgPipe, 
        FILE_WRITE_DATA | SYNCHRONIZE, 
        &ObjAttr, 
        &IoStatusBlock,
        0, 
        FILE_ATTRIBUTE_NORMAL, 
        0, 
        FILE_OPEN, 
        FILE_SYNCHRONOUS_IO_NONALERT, 
        NULL, 
        0
    );
    if (!NT_SUCCESS(status))
    {
        DbgMsg(__FILE__, __LINE__, "ZwCreateFile() fails; status: 0x%.8x\n", status);
    }

    KeReleaseMutex(&DbgMutex, FALSE);
}
//--------------------------------------------------------------------------------------
void DbgClosePipe(void)
{
    KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

	if (hDbgPipe)
    {
        ZwClose(hDbgPipe);
        hDbgPipe = NULL;
    }

    KeReleaseMutex(&DbgMutex, FALSE);
}
//--------------------------------------------------------------------------------------
#endif // DBGPIPE
//--------------------------------------------------------------------------------------
#ifdef DBGLOGFILE
//--------------------------------------------------------------------------------------
void DbgOpenLogFile(void)
{
    OBJECT_ATTRIBUTES ObjAttr;
    IO_STATUS_BLOCK StatusBlock;
    UNICODE_STRING usFileName;

    RtlInitUnicodeString(&usFileName, DBG_LOGFILE_NAME);

    InitializeObjectAttributes(&ObjAttr, &usFileName, 
        OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

    NTSTATUS status = ZwCreateFile(
        &hDbgLogFile,
        FILE_ALL_ACCESS | SYNCHRONIZE,
        &ObjAttr,
        &StatusBlock,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        0,
        FILE_OVERWRITE_IF,
        FILE_SYNCHRONOUS_IO_NONALERT,
        NULL,
        0
    );
    if (!NT_SUCCESS(status))
    {
        DbgMsg(__FILE__, __LINE__, "ZwCreateFile() fails; status: 0x%.8x\n", status);
    }

    KeReleaseMutex(&DbgMutex, FALSE);
}
//--------------------------------------------------------------------------------------
#endif // DBGLOGFILE
//--------------------------------------------------------------------------------------
void DbgClose(void)
{
    KeWaitForMutexObject(&DbgMutex, Executive, KernelMode, FALSE, NULL);

    if (hDbgPipe)
    {
        ZwClose(hDbgPipe);
        hDbgPipe = NULL;
    }

    if (hDbgLogFile)
    {
        ZwClose(hDbgLogFile);
        hDbgLogFile = NULL;
    }

    KeReleaseMutex(&DbgMutex, FALSE);
}
//--------------------------------------------------------------------------------------
void DbgInit(void)
{

#if defined(DBGPIPE) || defined(DBGLOGFILE)

    KeInitializeMutex(&DbgMutex, NULL);

#endif // DBGPIPE/DBGLOGFILE

}
//--------------------------------------------------------------------------------------
#endif // DBGMSG_FULL
//--------------------------------------------------------------------------------------
void DbgHexdump(PUCHAR Data, ULONG Length)
{
    ULONG dp = 0, p = 0;
    const char trans[] =
        "................................ !\"#$%&'()*+,-./0123456789"
        ":;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklm"
        "nopqrstuvwxyz{|}~...................................."
        "....................................................."
        "........................................";

    char szBuff[0x100], szChar[10];
    RtlZeroMemory(szBuff, sizeof(szBuff));

    for (dp = 1; dp <= Length; dp++)  
    {
        sprintf(szChar, "%02x ", Data[dp-1]);
        strcat(szBuff, szChar);

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
                sprintf(szChar, "%c", trans[Data[dp]]);
                strcat(szBuff, szChar);
            }

            DbgMsg(__FILE__, __LINE__, "%.8x: %s\r\n", dp - 16, szBuff);
            RtlZeroMemory(szBuff, sizeof(szBuff));
        }
    }

    if ((Length % 16) != 0) 
    {
        p = dp = 16 - (Length % 16);

        for (dp = p; dp > 0; dp--) 
        {
            strcat(szBuff, "   ");

            if (((dp % 8) == 0) && (p != 8))
            {
                strcat(szBuff, " ");
            }
        }

        strcat(szBuff, " | ");
        for (dp = (Length - (16 - p)); dp < Length; dp++)
        {
            sprintf(szChar, "%c", trans[Data[dp]]);
            strcat(szBuff, szChar);
        }

        DbgMsg(__FILE__, __LINE__, "%.8x: %s\r\n", Length - (Length % 16), szBuff);
    }
}
//--------------------------------------------------------------------------------------
// EoF
