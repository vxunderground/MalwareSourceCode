#pragma once
#include "sysutil.h"

#include <windows.h>
#include <stdio.h>

#include "pe_hdrs_helper.h"

typedef BOOL(WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);

bool is_compiled_32b()
{
    if (sizeof(LPVOID) == sizeof(DWORD)) {
        return true;
    }
    return false;
}

bool is_wow64()
{
    LPFN_ISWOW64PROCESS fnIsWow64Process;
    BOOL bIsWow64 = false;

    //IsWow64Process is not available on all supported versions of Windows.
    //Use GetModuleHandle to get a handle to the DLL that contains the function
    //and GetProcAddress to get a pointer to the function if available.

    fnIsWow64Process = (LPFN_ISWOW64PROCESS)GetProcAddress(GetModuleHandleA("kernel32"), "IsWow64Process");
    if (fnIsWow64Process == NULL) {
        return false;
    }
    if (!fnIsWow64Process(GetCurrentProcess(), &bIsWow64)) {
        return false;
	}
    if (bIsWow64 == TRUE) {
        return  true; //64 bit
    }
	return false; //32 bit
}

bool is_system32b()
{
    //is the current application 32 bit?
    if (!is_compiled_32b()) {
        return false;
    }
	//check if it is running under WoW
    if (is_wow64()) {
        return false;
    }
    return true;
}
