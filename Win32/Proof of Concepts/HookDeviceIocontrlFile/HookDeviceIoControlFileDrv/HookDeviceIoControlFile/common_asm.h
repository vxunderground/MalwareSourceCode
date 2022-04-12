#ifdef __cplusplus
extern "C" 
{
#endif

void __stdcall _clear_wp(void);
void __stdcall _set_wp(void);

NTSTATUS 
NTAPI 
_ZwProtectVirtualMemory(
    HANDLE  ProcessHandle,
    PVOID   *BaseAddress,
    PSIZE_T NumberOfBytesToProtect,
    ULONG   NewAccessProtection,
    PULONG  OldAccessProtection 
);

#ifdef __cplusplus
}
#endif 
