#pragma once

#include <Windows.h>
#include "ntddk.h"

//undocumented functions from ntdll.dll
//
//don't forget to load functions before use:
//load_ntdll_functions();

NTSTATUS (NTAPI *NtQueueApcThread)(
    IN  HANDLE ThreadHandle,
    IN  PVOID ApcRoutine,
    IN  PVOID ApcRoutineContext OPTIONAL,
    IN  PVOID ApcStatusBlock OPTIONAL,
    IN  ULONG ApcReserved OPTIONAL
);

NTSTATUS (NTAPI *ZwSetInformationThread) (
    IN  HANDLE ThreadHandle,
    IN  THREADINFOCLASS ThreadInformationClass,
    IN  PVOID ThreadInformation,
    IN  ULONG ThreadInformationLength
);

NTSTATUS (NTAPI *ZwCreateThreadEx) (
    OUT  PHANDLE ThreadHandle, 
    IN  ACCESS_MASK DesiredAccess, 
    IN  POBJECT_ATTRIBUTES ObjectAttributes OPTIONAL, 
    IN  HANDLE ProcessHandle,
    IN  PVOID StartRoutine,
    IN  PVOID Argument OPTIONAL,
    IN  ULONG CreateFlags,
    IN  ULONG_PTR ZeroBits, 
    IN  SIZE_T StackSize OPTIONAL,
    IN  SIZE_T MaximumStackSize OPTIONAL, 
    IN  PVOID AttributeList OPTIONAL
);

NTSTATUS (NTAPI  *RtlCreateUserThread) (
  IN  HANDLE ProcessHandle,
  IN  PSECURITY_DESCRIPTOR SecurityDescriptor OPTIONAL,
  IN  BOOLEAN CreateSuspended,
  IN  ULONG StackZeroBits,
  IN OUT  PULONG StackReserved,
  IN OUT  PULONG StackCommit,
  IN  PVOID StartAddress,
  IN  PVOID StartParameter OPTIONAL,
  OUT  PHANDLE ThreadHandle,
  OUT  PCLIENT_ID ClientID
);


BOOL load_ntdll_functions()
{
    HMODULE hNtdll = GetModuleHandleA("ntdll");
    if (hNtdll == NULL) return FALSE;

    NtQueueApcThread = (NTSTATUS (NTAPI *)(HANDLE, PVOID, PVOID, PVOID, ULONG)) GetProcAddress(hNtdll,"NtQueueApcThread");
    if (NtQueueApcThread == NULL) return FALSE;
    
    ZwSetInformationThread = (NTSTATUS (NTAPI *)(HANDLE, THREADINFOCLASS, PVOID, ULONG)) GetProcAddress(hNtdll,"ZwSetInformationThread");
    if (ZwSetInformationThread == NULL) return FALSE;
    
    ZwCreateThreadEx = (NTSTATUS (NTAPI *) (PHANDLE, ACCESS_MASK, POBJECT_ATTRIBUTES, HANDLE, PVOID, PVOID, ULONG, ULONG_PTR, SIZE_T, SIZE_T, PVOID)) GetProcAddress(hNtdll,"ZwCreateThreadEx");
    if (ZwCreateThreadEx == NULL) return FALSE;
    
    RtlCreateUserThread = (NTSTATUS (NTAPI *) (HANDLE, PSECURITY_DESCRIPTOR, BOOLEAN,ULONG, PULONG, PULONG, PVOID, PVOID, PHANDLE, PCLIENT_ID)) GetProcAddress(hNtdll,"RtlCreateUserThread");
    if (RtlCreateUserThread == NULL) return FALSE;

    return TRUE;
}
