#pragma once
#include "kernel32_undoc.h"

bool create_new_process1(PROCESS_INFORMATION &pi, LPWSTR cmdLine, LPWSTR startDir = NULL)
{
    STARTUPINFO si;
    memset(&si, 0, sizeof(STARTUPINFO));
    si.cb = sizeof(STARTUPINFO);

    memset(&pi, 0, sizeof(PROCESS_INFORMATION));

    if (!CreateProcess(
            NULL,
            cmdLine,
            NULL, //lpProcessAttributes
            NULL, //lpThreadAttributes
            FALSE, //bInheritHandles
            DETACHED_PROCESS|CREATE_SUSPENDED|CREATE_NO_WINDOW, //dwCreationFlags
            NULL, //lpEnvironment 
            startDir, //lpCurrentDirectory
            &si, //lpStartupInfo
            &pi //lpProcessInformation
        ))
    {
        printf("[ERROR] CreateProcess failed, Error = %x\n", GetLastError());
        return false;
    }
    return true;
}

bool create_new_process2(PROCESS_INFORMATION &pi, LPWSTR cmdLine, LPWSTR startDir = NULL)
{
    STARTUPINFO si;
    memset(&si, 0, sizeof(STARTUPINFO));
    si.cb = sizeof(STARTUPINFO);

    memset(&pi, 0, sizeof(PROCESS_INFORMATION));

    HANDLE hToken = NULL;
    HANDLE hNewToken = NULL;
    if (!CreateProcessInternalW (hToken,
            NULL, //lpApplicationName
            (LPWSTR) cmdLine, //lpCommandLine
            NULL, //lpProcessAttributes
            NULL, //lpThreadAttributes
            FALSE, //bInheritHandles
            CREATE_SUSPENDED|DETACHED_PROCESS|CREATE_NO_WINDOW, //dwCreationFlags
            NULL, //lpEnvironment 
            startDir, //lpCurrentDirectory
            &si, //lpStartupInfo
            &pi, //lpProcessInformation
            &hNewToken
        ))
    {
        printf("[ERROR] CreateProcessInternalW failed, Error = %x\n", GetLastError());
        return false;
    }
    return true;
}
