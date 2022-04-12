
typedef struct _LST_PROCESS_INFO
{
    PEPROCESS Process;
    HANDLE ProcessId;
    UNICODE_STRING usImagePath;

} LST_PROCESS_INFO,
*PLST_PROCESS_INFO;

void FreeProcessInfo(void);
void NTAPI ProcessNotifyRoutine(HANDLE ParentId, HANDLE ProcessId, BOOLEAN Create);
PUNICODE_STRING LookupProcessName(PEPROCESS TargetProcess);

typedef NTSTATUS (NTAPI * NT_DEVICE_IO_CONTROL_FILE)(
    HANDLE FileHandle,
    HANDLE Event,
    PIO_APC_ROUTINE ApcRoutine,
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock,
    ULONG IoControlCode,
    PVOID InputBuffer,
    ULONG InputBufferLength,
    PVOID OutputBuffer,
    ULONG OutputBufferLength
);

NTSTATUS NTAPI new_NtDeviceIoControlFile(
    HANDLE FileHandle,
    HANDLE Event,
    PIO_APC_ROUTINE ApcRoutine,
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock,
    ULONG IoControlCode,
    PVOID InputBuffer,
    ULONG InputBufferLength,
    PVOID OutputBuffer,
    ULONG OutputBufferLength
);

BOOLEAN ValidateUnicodeString(PUNICODE_STRING usStr);

VOID WaitHookRemoveComplete();