#include "stdafx.h"
//--------------------------------------------------------------------------------------
BOOL LoadPrivileges(char *lpszName)
{
    HANDLE hToken = NULL;
    LUID Val;
    TOKEN_PRIVILEGES tp;
    BOOL bRet = FALSE;

    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken)) 
    {
        DbgMsg(__FILE__, __LINE__, "OpenProcessToken() fails: error %d\n", GetLastError());
        goto end;
    }

    if (!LookupPrivilegeValue(NULL, lpszName, &Val))
    {
        DbgMsg(__FILE__, __LINE__, "LookupPrivilegeValue() fails: error %d\n", GetLastError());
        goto end;
    }

    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = Val;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

    if (!AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof (tp), NULL, NULL))
    {
        DbgMsg(__FILE__, __LINE__, "AdjustTokenPrivileges() fails: error %d\n", GetLastError());
        goto end;
    }

    bRet = TRUE;

end:
    if (hToken)
        CloseHandle(hToken);

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL DumpToFile(char *lpszFileName, PVOID pData, ULONG DataSize)
{
    HANDLE hFile = CreateFileA(lpszFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
    if (hFile != INVALID_HANDLE_VALUE)
    {
        DWORD dwWritten;
        WriteFile(hFile, pData, DataSize, &dwWritten, NULL);

        CloseHandle(hFile);

        return TRUE;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "Error %d while creating '%s'\n", GetLastError(), lpszFileName);
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOL ReadFromFile(LPCTSTR lpszFileName, PVOID *pData, PDWORD lpdwDataSize)
{
    BOOL bRet = FALSE;
    HANDLE hFile = CreateFile(
        lpszFileName, 
        GENERIC_READ, 
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        NULL,
        OPEN_EXISTING, 
        0, 
        NULL
    );
    if (hFile != INVALID_HANDLE_VALUE)
    {
        if (pData == NULL || lpdwDataSize == NULL)
        {
            // just check for existing file
            bRet = TRUE;
            goto close;
        }

        *lpdwDataSize = GetFileSize(hFile, NULL);
        if (*pData = LocalAlloc(LMEM_FIXED | LMEM_ZEROINIT, *lpdwDataSize))
        {
            DWORD dwReaded = 0;
            ReadFile(hFile, *pData, *lpdwDataSize, &dwReaded, NULL);

            bRet = TRUE;
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "LocalAlloc() ERROR %d\n", GetLastError());
            *lpdwDataSize = 0;
        }

close:
        CloseHandle(hFile);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "Error %d while reading '%s'\n", GetLastError(), lpszFileName);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
char *GetNameFromFullPath(char *lpszPath)
{
    char *lpszName = lpszPath;

    for (size_t i = 0; i < strlen(lpszPath); i++)
    {
        if (lpszPath[i] == '\\' || lpszPath[i] == '/')
        {
            lpszName = lpszPath + i + 1;
        }
    }

    return lpszName;
}
//--------------------------------------------------------------------------------------
wchar_t *GetNameFromFullPathW(wchar_t *lpwcPath)
{
    wchar_t *lpwcName = lpwcPath;

    for (size_t i = 0; i < wcslen(lpwcPath); i++)
    {
        if (lpwcPath[i] == L'\\' || lpwcPath[i] == L'/')
        {
            lpwcName = lpwcPath + i + 1;
        }
    }

    return lpwcName;
}
//--------------------------------------------------------------------------------------
BOOL IsFileExists(char *lpszFileName)
{
    BOOL bRet = FALSE;
    WIN32_FIND_DATA FindData;

    // enumerate files
    HANDLE hDir = FindFirstFileA(lpszFileName, &FindData);
    if (hDir != INVALID_HANDLE_VALUE)
    {
        bRet = TRUE;
        FindClose(hDir);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
PVOID GetSysInf(SYSTEM_INFORMATION_CLASS InfoClass)
{
    NTSTATUS ns = 0;
    ULONG RetSize = 0, Size = 0x100;
    PVOID Info = NULL;

    GET_NATIVE(NtQuerySystemInformation);

    while (true) 
    {    
        // allocate memory for system information
        if ((Info = M_ALLOC(Size)) == NULL) 
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
            return NULL;
        }

        // query information
        RetSize = 0;
        ns = f_NtQuerySystemInformation(InfoClass, Info, Size, &RetSize);
        if (ns == STATUS_INFO_LENGTH_MISMATCH)
        {       
            // buffer is too small
            M_FREE(Info);
            Info = NULL;

            if (RetSize > 0)
            {
                // allocate more memory and try again
                Size = RetSize + 0x100;
            }            
            else
            {
                break;
            }
        }
        else
        {
            break;
        }
    }

    if (!NT_SUCCESS(ns))
    {
        DbgMsg(__FILE__, __LINE__, "NtQuerySystemInformation() fails; status: 0x%.8x\n", ns);

        if (Info)
        {
            M_FREE(Info);
        }

        return NULL;
    }

    return Info;
}
//--------------------------------------------------------------------------------------
BOOL GetProcessNameById(DWORD dwProcessId, char *lpszName, size_t NameLen)
{
    BOOL bRet = FALSE;

    // enumerate processes
    HANDLE hSnapProcs = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapProcs != INVALID_HANDLE_VALUE)
    {
        PROCESSENTRY32 Process = { 0 };
        Process.dwSize = sizeof(PROCESSENTRY32);

        if (Process32First(hSnapProcs, &Process))
        {
            do 
            {                
                // match process id
                if (Process.th32ProcessID == dwProcessId)
                {
                    strlwr(Process.szExeFile);
                    lstrcpy(lpszName, Process.szExeFile);

                    bRet = TRUE;

                    break;
                }
            }
            while (Process32Next(hSnapProcs, &Process));
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "Process32First() ERROR %d\n", GetLastError());
        }

        CloseHandle(hSnapProcs);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "CreateToolhelp32Snapshot() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
// EoF
