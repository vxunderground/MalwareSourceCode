#include "Reload.h"




BOOLEAN
    FixBaseRelocTable (
    PVOID NewImageBase,
    DWORD ExistImageBase
    );

PIMAGE_BASE_RELOCATION
    LdrProcessRelocationBlockLongLong(
    IN ULONG_PTR VA,
    IN ULONG SizeOfBlock,
    IN PUSHORT NextOffset,
    IN LONGLONG Diff
    );

NTSTATUS
    NTAPI
    RtlImageNtHeaderEx(
    ULONG Flags,
    PVOID Base,
    ULONG64 Size,
    OUT PIMAGE_NT_HEADERS * OutHeaders
    );

PIMAGE_NT_HEADERS
    NTAPI
    RtlImageNtHeader(
    PVOID Base
    );
