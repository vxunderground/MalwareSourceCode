#include "stdafx.h"
//--------------------------------------------------------------------------------------
BOOL GetNormalizedSymbolName(char *lpszName, char *lpszNormalizedName, int NameLen)
{
    int StrLen;
    char *lpszStr = lpszName;

    if (!strncmp(lpszName, "??", min(lstrlen(lpszName), 2)) ||
        !strncmp(lpszName, "__imp__", min(lstrlen(lpszName), 7)))
    {
        if (NameLen > lstrlen(lpszName))
        {
            strcpy(lpszNormalizedName, lpszName);
            return TRUE;
        }

        return FALSE;
    }

    if (*lpszStr == '_' || *lpszStr == '@')
    {
        lpszStr++;
    }

    for (StrLen = 0; StrLen < lstrlen(lpszStr); StrLen++)
    {
        if (lpszStr[StrLen] == '@')
        {
            break;
        }
    }

    if (NameLen > StrLen)
    {
        strncpy(lpszNormalizedName, lpszStr, StrLen);
        lpszNormalizedName[StrLen] = 0;
        return TRUE;
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
typedef struct _ENUM_SYM_PARAM
{
    ULONGLONG Address;
    char    *lpszName;

} ENUM_SYM_PARAM,
*PENUM_SYM_PARAM;

BOOL CALLBACK EnumSymbolsProc(
    PSYMBOL_INFO pSymInfo,
    ULONG SymbolSize,
    PVOID UserContext)
{
    PENUM_SYM_PARAM Param = (PENUM_SYM_PARAM)UserContext;
    char szName[0x100];

    if (GetNormalizedSymbolName(pSymInfo->Name, szName, sizeof(szName)))
    {
        if (!lstrcmp(szName, Param->lpszName))
        {
            Param->Address = (ULONGLONG)pSymInfo->Address;
            return FALSE;
        }        
    }
    
    return TRUE;
}
//--------------------------------------------------------------------------------------
ULONGLONG GetSymbolByName(char *lpszModuleName, HMODULE hModule, char *lpszName)
{
    ULONGLONG Ret = 0;

    // try to load debug symbols for module
    if (SymLoadModuleEx(GetCurrentProcess(), NULL, lpszModuleName, NULL, (DWORD64)hModule, 0, NULL, 0))
    {
        ENUM_SYM_PARAM Param;

        Param.Address = NULL;
        Param.lpszName = lpszName;

        // get specified symbol address by name
        if (!SymEnumSymbols(
            GetCurrentProcess(),
            (DWORD64)hModule,
            NULL,
            EnumSymbolsProc,
            &Param))
        {                    
            DbgMsg(__FILE__, __LINE__, "SymEnumSymbols() ERROR %d\n", GetLastError());
        }

        if (Param.Address == NULL)
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't locate symbol\n");
        }
        else
        {
            Ret = Param.Address;
        }

        // unload symbols
        SymUnloadModule64(GetCurrentProcess(), (DWORD64)hModule);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "SymLoadModuleEx() ERROR %d\n", GetLastError());
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
DWORD GetKernelSymbolOffset(char *lpszSymbolName)
{
    DWORD Ret = 0;

    // get system modules information
    PRTL_PROCESS_MODULES Info = (PRTL_PROCESS_MODULES)GetSysInf(SystemModuleInformation);
    if (Info)
    {
        char *lpszKernelName = (char *)Info->Modules[0].FullPathName + Info->Modules[0].OffsetToFileName;
        char szKernelPath[MAX_PATH];

        // get full kernel image path
        GetSystemDirectory(szKernelPath, MAX_PATH);
        lstrcat(szKernelPath, "\\");
        lstrcat(szKernelPath, lpszKernelName);

        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Using kernel binary '%s'\r\n", szKernelPath);

        // load kernel module
        HMODULE hModule = LoadLibraryEx(szKernelPath, NULL, DONT_RESOLVE_DLL_REFERENCES);
        if (hModule)
        {
            // get symbol offset
            LARGE_INTEGER Addr;
            Addr.QuadPart = GetSymbolByName(szKernelPath, hModule, lpszSymbolName);
            if (Addr.QuadPart > 0)
            {
                Addr.QuadPart -= (ULONGLONG)hModule;
                Ret = Addr.LowPart;
            }                       

            FreeLibrary(hModule);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "LoadLibraryEx() ERROR %d\r\n", GetLastError());
        }

        M_FREE(Info);
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
// EoF
