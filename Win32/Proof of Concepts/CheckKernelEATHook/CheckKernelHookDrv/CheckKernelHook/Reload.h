#include "DriverEntry.h"
#include <ntimage.h>

#pragma  once
typedef unsigned long DWORD;
typedef DWORD * PDWORD;
typedef unsigned char  BYTE, *PBYTE;
typedef unsigned short WORD, *PWORD;


typedef struct _SYSTEM_MODULE_INFORMATION  // 系统模块信息
{
    ULONG  Reserved[2];  
    ULONG  Base;        
    ULONG  Size;         
    ULONG  Flags;        
    USHORT Index;       
    USHORT Unknown;     
    USHORT LoadCount;   
    USHORT ModuleNameOffset;
    CHAR   ImageName[256];   
} SYSTEM_MODULE_INFORMATION, *PSYSTEM_MODULE_INFORMATION;

typedef struct _tagSysModuleList {          //模块链结构
    ULONG ulCount;
    SYSTEM_MODULE_INFORMATION smi[1];
} MODULES, *PMODULES;

typedef enum _SYSTEM_INFORMATION_CLASS   
{   
    SystemBasicInformation,                 // 0 Y N   
    SystemProcessorInformation,             // 1 Y N   
    SystemPerformanceInformation,           // 2 Y N   
    SystemTimeOfDayInformation,             // 3 Y N   
    SystemNotImplemented1,                  // 4 Y N   
    SystemProcessesAndThreadsInformation,   // 5 Y N   
    SystemCallCounts,                       // 6 Y N   
    SystemConfigurationInformation,         // 7 Y N   
    SystemProcessorTimes,                   // 8 Y N   
    SystemGlobalFlag,                       // 9 Y Y   
    SystemNotImplemented2,                  // 10 Y N   
    SystemModuleInformation,                // 11 Y N   
    SystemLockInformation,                  // 12 Y N   
    SystemNotImplemented3,                  // 13 Y N   
    SystemNotImplemented4,                  // 14 Y N   
    SystemNotImplemented5,                  // 15 Y N   
    SystemHandleInformation,                // 16 Y N   
    SystemObjectInformation,                // 17 Y N   
    SystemPagefileInformation,              // 18 Y N   
    SystemInstructionEmulationCounts,       // 19 Y N   
    SystemInvalidInfoClass1,                // 20   
    SystemCacheInformation,                 // 21 Y Y   
    SystemPoolTagInformation,               // 22 Y N   
    SystemProcessorStatistics,              // 23 Y N   
    SystemDpcInformation,                   // 24 Y Y   
    SystemNotImplemented6,                  // 25 Y N   
    SystemLoadImage,                        // 26 N Y   
    SystemUnloadImage,                      // 27 N Y   
    SystemTimeAdjustment,                   // 28 Y Y   
    SystemNotImplemented7,                  // 29 Y N   
    SystemNotImplemented8,                  // 30 Y N   
    SystemNotImplemented9,                  // 31 Y N   
    SystemCrashDumpInformation,             // 32 Y N   
    SystemExceptionInformation,             // 33 Y N   
    SystemCrashDumpStateInformation,        // 34 Y Y/N   
    SystemKernelDebuggerInformation,        // 35 Y N   
    SystemContextSwitchInformation,         // 36 Y N   
    SystemRegistryQuotaInformation,         // 37 Y Y   
    SystemLoadAndCallImage,                 // 38 N Y   
    SystemPrioritySeparation,               // 39 N Y   
    SystemNotImplemented10,                 // 40 Y N   
    SystemNotImplemented11,                 // 41 Y N   
    SystemInvalidInfoClass2,                // 42   
    SystemInvalidInfoClass3,                // 43   
    SystemTimeZoneInformation,              // 44 Y N   
    SystemLookasideInformation,             // 45 Y N   
    SystemSetTimeSlipEvent,                 // 46 N Y   
    SystemCreateSession,                    // 47 N Y   
    SystemDeleteSession,                    // 48 N Y   
    SystemInvalidInfoClass4,                // 49   
    SystemRangeStartInformation,            // 50 Y N   
    SystemVerifierInformation,              // 51 Y Y   
    SystemAddVerifier,                      // 52 N Y   
    SystemSessionProcessesInformation       // 53 Y N   
} SYSTEM_INFORMATION_CLASS;   

#define LDRP_RELOCATION_FINAL       0x2
#define RTL_IMAGE_NT_HEADER_EX_FLAG_NO_RANGE_CHECK (0x00000001)


typedef struct _AUX_ACCESS_DATA {
    PPRIVILEGE_SET PrivilegesUsed;
    GENERIC_MAPPING GenericMapping;
    ACCESS_MASK AccessesToAudit;
    ACCESS_MASK MaximumAuditMask;
    ULONG Unknown[41];
} AUX_ACCESS_DATA, *PAUX_ACCESS_DATA;



typedef struct _LDR_DATA_TABLE_ENTRY
{
    LIST_ENTRY InLoadOrderLinks;
    LIST_ENTRY InMemoryOrderLinks;
    LIST_ENTRY InInitializationOrderLinks;
    PVOID DllBase;
    PVOID EntryPoint;
    ULONG SizeOfImage;
    UNICODE_STRING FullDllName;
    UNICODE_STRING BaseDllName;
    ULONG Flags;
    USHORT LoadCount;
    USHORT TlsIndex;
    union
    {
        LIST_ENTRY HashLinks;
        struct
        {
            PVOID SectionPointer;
            ULONG CheckSum;
        };
    };
    union
    {
        ULONG TimeDateStamp;
        PVOID LoadedImports;
    };
    PVOID EntryPointActivationContext;
    PVOID PatchInformation;
} LDR_DATA_TABLE_ENTRY, *PLDR_DATA_TABLE_ENTRY;
// typedef struct _IMAGE_BASE_RELOCATION {
//     DWORD   VirtualAddress;
//     DWORD   SizeOfBlock;
//     //  WORD    TypeOffset[1];
// } IMAGE_BASE_RELOCATION,*PIMAGE_BASE_RELOCATION;
// typedef IMAGE_BASE_RELOCATION UNALIGNED * PIMAGE_BASE_RELOCATION;

typedef struct _SERVICE_DESCRIPTOR_TABLE {
    /*
    * Table containing cServices elements of pointers to service handler
    * functions, indexed by service ID.
    */
    PDWORD   ServiceTable;
    /*
    * Table that counts how many times each service is used. This table
    * is only updated in checked builds.
    */
    PULONG  CounterTable;
    /*
    * Number of services contained in this table.
    */
    ULONG   TableSize;
    /*
    * Table containing the number of bytes of parameters the handler
    * function takes.
    */
    PUCHAR  ArgumentTable;
} SERVICE_DESCRIPTOR_TABLE, *PSERVICE_DESCRIPTOR_TABLE;
NTSTATUS ReLoadNtos(PDRIVER_OBJECT   DriverObject,DWORD RetAddress);



NTSTATUS
    NTAPI
    ZwQuerySystemInformation(
    IN SYSTEM_INFORMATION_CLASS SystemInfoClass,
    OUT PVOID SystemInfoBuffer,
    IN ULONG SystemInfoBufferSize,
    OUT PULONG BytesReturned OPTIONAL
    );
NTSTATUS
    NTAPI
    ObCreateObject (
    IN KPROCESSOR_MODE      ObjectAttributesAccessMode OPTIONAL,
    IN POBJECT_TYPE         ObjectType,
    IN POBJECT_ATTRIBUTES   ObjectAttributes OPTIONAL,
    IN KPROCESSOR_MODE      AccessMode,
    IN OUT PVOID            ParseContext OPTIONAL,
    IN ULONG                ObjectSize,
    IN ULONG                PagedPoolCharge OPTIONAL,
    IN ULONG                NonPagedPoolCharge OPTIONAL,
    OUT PVOID               *Object
    );


NTSTATUS
    NTAPI
    SeCreateAccessState(
    PACCESS_STATE AccessState,
    PAUX_ACCESS_DATA AuxData,
    ACCESS_MASK Access,
    PGENERIC_MAPPING GenericMapping
    );


NTSYSAPI
    PVOID
    NTAPI
    RtlImageDirectoryEntryToData (
    IN PVOID Base,
    IN BOOLEAN MappedAsImage,
    IN USHORT DirectoryEntry,
    OUT PULONG Size
    );

BOOLEAN InitSafeOperationModule(PDRIVER_OBJECT pDriverObject,WCHAR *SystemModulePath,ULONG KernelModuleBase);




typedef VOID (__stdcall *ReloadRtlInitUnicodeString)(
    __inout   PUNICODE_STRING DestinationString,
    __in_opt  PCWSTR SourceString
    );
ReloadRtlInitUnicodeString RRtlInitUnicodeString;

typedef LONG (__stdcall * ReloadRtlCompareUnicodeString)(
    __in  PCUNICODE_STRING String1,
    __in  PCUNICODE_STRING String2,
    __in  BOOLEAN CaseInSensitive
    );
ReloadRtlCompareUnicodeString RRtlCompareUnicodeString;


typedef PVOID (__stdcall *ReloadMmGetSystemRoutineAddress)(
    __in  PUNICODE_STRING SystemRoutineName
    );
ReloadMmGetSystemRoutineAddress RMmGetSystemRoutineAddress;



typedef BOOLEAN (__stdcall * ReloadMmIsAddressValid)(
    __in  PVOID VirtualAddress
    );
ReloadMmIsAddressValid RMmIsAddressValid;


typedef PEPROCESS  (__stdcall *ReloadPsGetCurrentProcess)(void);
ReloadPsGetCurrentProcess RPsGetCurrentProcess;

BOOLEAN GetOriginalKiServiceTable(BYTE *NewImageBase,DWORD ExistImageBase,DWORD *NewKiServiceTable);
VOID FixOriginalKiServiceTable(PDWORD OriginalKiServiceTable,DWORD ModuleBase,DWORD ExistImageBase);