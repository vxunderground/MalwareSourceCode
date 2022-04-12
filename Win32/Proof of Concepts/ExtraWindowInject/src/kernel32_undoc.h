#pragma once

#include <Windows.h>

//don't forget to load functiond before use:
//load_kernel32_functions();
//

BOOL 
(WINAPI *CreateProcessInternalW)(HANDLE hToken, 
    LPCWSTR lpApplicationName, 
    LPWSTR lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL bInheritHandles,
    DWORD dwCreationFlags, 
    LPVOID lpEnvironment, 
    LPCWSTR lpCurrentDirectory, 
    LPSTARTUPINFOW lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation,
    PHANDLE hNewToken
    );


BOOL load_kernel32_functions()
{
    HMODULE hKernel32 = GetModuleHandleA("kernel32");
    CreateProcessInternalW = (BOOL (WINAPI *)(HANDLE, LPCWSTR, LPWSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES,BOOL, DWORD, LPVOID, LPCWSTR, LPSTARTUPINFOW, LPPROCESS_INFORMATION, PHANDLE)) GetProcAddress(hKernel32,"CreateProcessInternalW");
    if (CreateProcessInternalW == NULL) return FALSE;

    return TRUE;
}
