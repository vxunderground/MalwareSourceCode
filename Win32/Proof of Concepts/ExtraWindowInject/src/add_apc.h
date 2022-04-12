#pragma once
#include <stdio.h>
#include "ntdll_undoc.h"

bool add_shellcode_to_apc(HANDLE hThread, LPVOID remote_shellcode_ptr)
{
#if defined(_WIN64)
    printf("[ERROR] 64bit version of this method is not implemented!\n");
    return false;
#else
    printf("Adding shellcode to the queue\n");
    NTSTATUS status = NULL;
    
    if ((status = NtQueueApcThread(hThread, remote_shellcode_ptr, 0, 0, 0)) != STATUS_SUCCESS)
    {
        printf("[ERROR] NtQueueApcThread failed, status : %x\n", status);
        return false;
    }
    return true;
#endif
}
