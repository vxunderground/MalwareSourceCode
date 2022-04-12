#pragma once
#include <psapi.h>

bool get_process_name(IN HANDLE hProcess, OUT LPWSTR nameBuf, IN SIZE_T nameMax)
{
    HMODULE hMod;
    DWORD cbNeeded;

    if (EnumProcessModules( hProcess, &hMod, sizeof(hMod), &cbNeeded)) {
        GetModuleBaseName( hProcess, hMod, nameBuf, nameMax );
        return true;
    }
    return false;
}

bool is_searched_process( DWORD processID, LPWSTR searchedName)
{
    HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID );
    if (hProcess == NULL) return false;

    WCHAR szProcessName[MAX_PATH];
    if (get_process_name(hProcess, szProcessName, MAX_PATH)) {
        if (wcsstr(szProcessName, searchedName) != NULL) {
            printf( "%S  (PID: %u)\n", szProcessName, processID );
            CloseHandle(hProcess);
            return true;   
        }
   }
    CloseHandle(hProcess);
    return false;
}

HANDLE find_running_process(LPWSTR searchedName)
{
    DWORD aProcesses[1024], cbNeeded, cProcesses;
    unsigned int i;

    if ( !EnumProcesses( aProcesses, sizeof(aProcesses), &cbNeeded)) {
        return NULL;
    }

    //calculate how many process identifiers were returned.
    cProcesses = cbNeeded / sizeof(DWORD);

    //search handle to the process of defined name
    for ( i = 0; i < cProcesses; i++ ) {
        if( aProcesses[i] != 0 ) {
            if (is_searched_process(aProcesses[i], searchedName)) {
                HANDLE hProcess = OpenProcess( PROCESS_ALL_ACCESS, FALSE, aProcesses[i]);
                return hProcess;
            }
        }
    }
    return NULL;
}
