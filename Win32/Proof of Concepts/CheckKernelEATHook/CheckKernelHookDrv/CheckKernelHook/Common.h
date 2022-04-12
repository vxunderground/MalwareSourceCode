#include "DriverEntry.h"
#include <ntimage.h>

typedef unsigned long DWORD;
typedef void *HANDLE;
typedef unsigned char  BOOL, *PBOOL;
#define SEC_IMAGE    0x01000000

NTSYSAPI
    PIMAGE_NT_HEADERS
    NTAPI
    RtlImageNtHeader(PVOID Base);

NTSTATUS 
    MapFileInUserSpace(WCHAR* wzFilePath,IN HANDLE hProcess OPTIONAL,
    OUT PVOID *BaseAddress,
    OUT PSIZE_T ViewSize OPTIONAL);

    LONG GetSSDTApiFunctionIndexFromNtdll(char* szFindFunctionName);
    BOOL IsAddressInSystem(ULONG ulDriverBase,ULONG *ulSysModuleBase,ULONG *ulSize,char *lpszSysModuleImage);
#define OP_NONE 0x00
#define OP_MODRM 0x01
#define OP_DATA_I8 0x02
#define OP_DATA_I16 0x04
#define OP_DATA_I32 0x08
#define OP_DATA_PRE66_67 0x10
#define OP_WORD 0x20
#define OP_REL32 0x40

unsigned long __fastcall GetFunctionCodeSize(void *Proc);
    unsigned long __fastcall SizeOfCode(void *Code, unsigned char **pOpcode);
