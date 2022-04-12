
// ********************************************************
// some user-mode structures

typedef struct _LDR_DATA_TABLE_ENTRY
{
    LIST_ENTRY InLoadOrderModuleList;
    LIST_ENTRY InMemoryOrderModuleList;
    LIST_ENTRY InInitializationOrderModuleList;
    PVOID DllBase;
    PVOID EntryPoint;
    ULONG SizeOfImage;
    UNICODE_STRING FullDllName;
    UNICODE_STRING BaseDllName;
    ULONG Flags;
    USHORT LoadCount;
    USHORT TlsIndex;
    LIST_ENTRY HashLinks;
    PVOID SectionPointer;
    ULONG CheckSum;
    ULONG TimeDateStamp;

} LDR_DATA_TABLE_ENTRY, 
*PLDR_DATA_TABLE_ENTRY;

typedef struct _PEB_LDR_DATA 
{
    ULONG Length;
    BOOLEAN Initialized;
    PVOID SsHandle;
    LIST_ENTRY ModuleListLoadOrder;
    LIST_ENTRY ModuleListMemoryOrder;
    LIST_ENTRY ModuleListInitOrder;

} PEB_LDR_DATA, 
*PPEB_LDR_DATA;

// ********************************************************

typedef struct SERVICE_DESCRIPTOR_ENTRY
{
    PVOID	*ServiceTableBase;
    PULONG	ServiceCounterTableBase;
    ULONG	NumberOfServices;
    PUCHAR	ParamTableBase;

} SERVICE_DESCRIPTOR_ENTRY,
*PSERVICE_DESCRIPTOR_ENTRY;

typedef struct _SERVICE_DESCRIPTOR_TABLE 
{
    SERVICE_DESCRIPTOR_ENTRY Entry[2];

} SERVICE_DESCRIPTOR_TABLE,
*PSERVICE_DESCRIPTOR_TABLE; 

typedef enum _SYSTEM_INFORMATION_CLASS 
{
    SystemBasicInformation,
    SystemProcessorInformation,             // obsolete...delete
    SystemPerformanceInformation,
    SystemTimeOfDayInformation,
    SystemPathInformation,
    SystemProcessInformation,
    SystemCallCountInformation,
    SystemDeviceInformation,
    SystemProcessorPerformanceInformation,
    SystemFlagsInformation,
    SystemCallTimeInformation,
    SystemModuleInformation,
    SystemLocksInformation,
    SystemStackTraceInformation,
    SystemPagedPoolInformation,
    SystemNonPagedPoolInformation,
    SystemHandleInformation,
    SystemObjectInformation,
    SystemPageFileInformation,
    SystemVdmInstemulInformation,
    SystemVdmBopInformation,
    SystemFileCacheInformation,
    SystemPoolTagInformation,
    SystemInterruptInformation,
    SystemDpcBehaviorInformation,
    SystemFullMemoryInformation,
    SystemLoadGdiDriverInformation,
    SystemUnloadGdiDriverInformation,
    SystemTimeAdjustmentInformation,
    SystemSummaryMemoryInformation,
    SystemMirrorMemoryInformation,
    SystemPerformanceTraceInformation,
    SystemObsolete0,
    SystemExceptionInformation,
    SystemCrashDumpStateInformation,
    SystemKernelDebuggerInformation,
    SystemContextSwitchInformation,
    SystemRegistryQuotaInformation,
    SystemExtendServiceTableInformation,
    SystemPrioritySeperation,
    SystemVerifierAddDriverInformation,
    SystemVerifierRemoveDriverInformation,
    SystemProcessorIdleInformation,
    SystemLegacyDriverInformation,
    SystemCurrentTimeZoneInformation,
    SystemLookasideInformation,
    SystemTimeSlipNotification,
    SystemSessionCreate,
    SystemSessionDetach,
    SystemSessionInformation,
    SystemRangeStartInformation,
    SystemVerifierInformation,
    SystemVerifierThunkExtend,
    SystemSessionProcessInformation,
    SystemLoadGdiDriverInSystemSpace,
    SystemNumaProcessorMap,
    SystemPrefetcherInformation,
    SystemExtendedProcessInformation,
    SystemRecommendedSharedDataAlignment,
    SystemComPlusPackage,
    SystemNumaAvailableMemory,
    SystemProcessorPowerInformation,
    SystemEmulationBasicInformation,
    SystemEmulationProcessorInformation,
    SystemExtendedHandleInformation,
    SystemLostDelayedWriteInformation,
    SystemBigPoolInformation,
    SystemSessionPoolTagInformation,
    SystemSessionMappedViewInformation,
    SystemHotpatchInformation,
    SystemObjectSecurityMode,
    SystemWatchdogTimerHandler,
    SystemWatchdogTimerInformation,
    SystemLogicalProcessorInformation,
    SystemWow64SharedInformation,
    SystemRegisterFirmwareTableInformationHandler,
    SystemFirmwareTableInformation,
    SystemModuleInformationEx,
    SystemVerifierTriageInformation,
    SystemSuperfetchInformation,
    SystemMemoryListInformation,
    SystemFileCacheInformationEx,
    MaxSystemInfoClass  // MaxSystemInfoClass should always be the last enum
    
} SYSTEM_INFORMATION_CLASS;

typedef struct _RTL_PROCESS_MODULE_INFORMATION 
{
    HANDLE Section;                 // Not filled in
    PVOID MappedBase;
    PVOID ImageBase;
    ULONG ImageSize;
    ULONG Flags;
    USHORT LoadOrderIndex;
    USHORT InitOrderIndex;
    USHORT LoadCount;
    USHORT OffsetToFileName;
    UCHAR  FullPathName[ 256 ];
    
} RTL_PROCESS_MODULE_INFORMATION, 
*PRTL_PROCESS_MODULE_INFORMATION;

typedef struct _RTL_PROCESS_MODULES 
{
    ULONG NumberOfModules;
    RTL_PROCESS_MODULE_INFORMATION Modules[ 1 ];
    
} RTL_PROCESS_MODULES, 
*PRTL_PROCESS_MODULES;

typedef struct _SYSTEM_HANDLE_TABLE_ENTRY_INFO 
{
    USHORT UniqueProcessId;
    USHORT CreatorBackTraceIndex;
    UCHAR ObjectTypeIndex;
    UCHAR HandleAttributes;
    USHORT HandleValue;
    PVOID Object;
    ULONG GrantedAccess;

} SYSTEM_HANDLE_TABLE_ENTRY_INFO, 
*PSYSTEM_HANDLE_TABLE_ENTRY_INFO;

typedef struct _SYSTEM_HANDLE_INFORMATION 
{
    ULONG NumberOfHandles;
    SYSTEM_HANDLE_TABLE_ENTRY_INFO Handles[ 1 ];

} SYSTEM_HANDLE_INFORMATION, 
*PSYSTEM_HANDLE_INFORMATION;

#ifndef _NTIFS_INCLUDED_

typedef struct _FILE_DIRECTORY_INFORMATION
{
    ULONG NextEntryOffset;
    ULONG FileIndex;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER LastAccessTime;
    LARGE_INTEGER LastWriteTime;
    LARGE_INTEGER ChangeTime;
    LARGE_INTEGER EndOfFile;
    LARGE_INTEGER AllocationSize;
    ULONG FileAttributes;
    ULONG FileNameLength;
    WCHAR FileName[1];

} FILE_DIRECTORY_INFORMATION, 
*PFILE_DIRECTORY_INFORMATION;

typedef struct _FILE_NAMES_INFORMATION
{
    ULONG NextEntryOffset;
    ULONG FileIndex;
    ULONG FileNameLength;
    WCHAR FileName[1];

} FILE_NAMES_INFORMATION, 
*PFILE_NAMES_INFORMATION;

#endif

typedef struct _FILE_FULL_DIRECTORY_INFORMATION
{
    ULONG NextEntryOffset;
    ULONG FileIndex;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER LastAccessTime;
    LARGE_INTEGER LastWriteTime;
    LARGE_INTEGER ChangeTime;
    LARGE_INTEGER EndOfFile;
    LARGE_INTEGER AllocationSize;
    ULONG FileAttributes;
    ULONG FileNameLength;
    ULONG EaSize;
    WCHAR FileName[1];

} FILE_FULL_DIRECTORY_INFORMATION, 
*PFILE_FULL_DIRECTORY_INFORMATION;

typedef struct _FILE_BOTH_DIRECTORY_INFORMATION 
{
    ULONG NextEntryOffset;
    ULONG Unknown;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER LastAccessTime;
    LARGE_INTEGER LastWriteTime;
    LARGE_INTEGER ChangeTime;
    LARGE_INTEGER EndOfFile;
    LARGE_INTEGER AllocationSize;
    ULONG FileAttributes;
    ULONG FileNameLength;
    ULONG EaInformationLength;
    UCHAR AlternateNameLength;
    WCHAR AlternateName[12];
    WCHAR FileName[1];

} FILE_BOTH_DIRECTORY_INFORMATION, 
*PFILE_BOTH_DIRECTORY_INFORMATION; 

typedef struct _FILE_ID_BOTH_DIRECTORY_INFORMATION 
{
    ULONG NextEntryOffset;
    ULONG FileIndex;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER LastAccessTime;
    LARGE_INTEGER LastWriteTime;
    LARGE_INTEGER ChangeTime;
    LARGE_INTEGER EndOfFile;
    LARGE_INTEGER AllocationSize;
    ULONG FileAttributes;
    ULONG FileNameLength;
    ULONG EaSize;
    CCHAR ShortNameLength;
    WCHAR ShortName[12];
    LARGE_INTEGER FileId;
    WCHAR FileName[1];

} FILE_ID_BOTH_DIRECTORY_INFORMATION, 
*PFILE_ID_BOTH_DIRECTORY_INFORMATION;

typedef struct _FILE_ID_FULL_DIRECTORY_INFORMATION 
{
    ULONG NextEntryOffset;
    ULONG FileIndex;
    LARGE_INTEGER CreationTime;
    LARGE_INTEGER LastAccessTime;
    LARGE_INTEGER LastWriteTime;
    LARGE_INTEGER ChangeTime;
    LARGE_INTEGER EndOfFile;
    LARGE_INTEGER AllocationSize;
    ULONG FileAttributes;
    ULONG FileNameLength;
    ULONG EaSize;
    LARGE_INTEGER FileId;
    WCHAR FileName[1];

} FILE_ID_FULL_DIRECTORY_INFORMATION, 
*PFILE_ID_FULL_DIRECTORY_INFORMATION; 

typedef struct _SYSTEM_OBJECT_TYPE_INFORMATION 
{
    ULONG NextEntryOffset;
    ULONG ObjectCount;
    ULONG HandleCount;
    ULONG TypeNumber;
    ULONG InvalidAttributes;
    GENERIC_MAPPING GenericMapping;
    ACCESS_MASK ValidAccessMask;
    POOL_TYPE PoolType;
    UCHAR Unknown;
    UNICODE_STRING Name;

} SYSTEM_OBJECT_TYPE_INFORMATION, 
*PSYSTEM_OBJECT_TYPE_INFORMATION; 

typedef struct _SYSTEM_OBJECT_INFORMATION 
{
    ULONG NextEntryOffset;
    PVOID Object;
    ULONG CreatorProcessId;
    USHORT Unknown;
    USHORT Flags;
    ULONG PointerCount;
    ULONG HandleCount;
    ULONG PagedPoolUsage;
    ULONG NonPagedPoolUsage;
    ULONG ExclusiveProcessId;
    PSECURITY_DESCRIPTOR SecurityDescriptor;
    UNICODE_STRING Name;

} SYSTEM_OBJECT_INFORMATION, 
*PSYSTEM_OBJECT_INFORMATION;

NTSYSAPI 
NTSTATUS 
NTAPI 
ZwQueryDirectoryFile(
    HANDLE FileHandle, 
    HANDLE Event, 
    PIO_APC_ROUTINE ApcRoutine, 
    PVOID ApcContext,
    PIO_STATUS_BLOCK IoStatusBlock, 
    PVOID FileInformation, 
    ULONG FileInformationLength, 
    FILE_INFORMATION_CLASS FileInformationClass,
    BOOLEAN ReturnSingleEntry, 
    PUNICODE_STRING FileName, 
    BOOLEAN RestartScan
);

typedef struct _SYSTEM_PROCESS_INFORMATION {
    ULONG NextEntryOffset;
    ULONG NumberOfThreads;
    LARGE_INTEGER SpareLi1;
    LARGE_INTEGER SpareLi2;
    LARGE_INTEGER SpareLi3;
    LARGE_INTEGER CreateTime;
    LARGE_INTEGER UserTime;
    LARGE_INTEGER KernelTime;
    UNICODE_STRING ImageName;
    KPRIORITY BasePriority;
    HANDLE UniqueProcessId;
    HANDLE InheritedFromUniqueProcessId;
    ULONG HandleCount;
    ULONG SessionId;
    ULONG_PTR PageDirectoryBase;
    SIZE_T PeakVirtualSize;
    SIZE_T VirtualSize;
    ULONG PageFaultCount;
    SIZE_T PeakWorkingSetSize;
    SIZE_T WorkingSetSize;
    SIZE_T QuotaPeakPagedPoolUsage;
    SIZE_T QuotaPagedPoolUsage;
    SIZE_T QuotaPeakNonPagedPoolUsage;
    SIZE_T QuotaNonPagedPoolUsage;
    SIZE_T PagefileUsage;
    SIZE_T PeakPagefileUsage;
    SIZE_T PrivatePageCount;
    LARGE_INTEGER ReadOperationCount;
    LARGE_INTEGER WriteOperationCount;
    LARGE_INTEGER OtherOperationCount;
    LARGE_INTEGER ReadTransferCount;
    LARGE_INTEGER WriteTransferCount;
    LARGE_INTEGER OtherTransferCount;
} SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;


typedef struct THREAD_BASIC_INFORMATION
{
    NTSTATUS ExitStatus;
    PVOID TebBaseAddress;
    CLIENT_ID ClientId;
    KAFFINITY AffinityMask;
    KPRIORITY Priority;
    KPRIORITY BasePriority;

} THREAD_BASIC_INFORMATION,
*PTHREAD_BASIC_INFORMATION;

NTSYSAPI 
NTSTATUS 
NTAPI 
ZwQuerySystemInformation(
    SYSTEM_INFORMATION_CLASS SystemInformationClass,
    PVOID SystemInformation,
    ULONG SystemInformationLength,
    PULONG ReturnLength
);

NTSYSAPI
NTSTATUS
NTAPI
ZwQueryInformationProcess(
    HANDLE ProcessHandle,
    PROCESSINFOCLASS ProcessInformationClass,
    PVOID ProcessInformation,
    ULONG ProcessInformationLength,
    PULONG ReturnLength
);

NTSYSAPI 
NTSTATUS 
NTAPI 
ZwOpenThread(
    PHANDLE ThreadHandle,
    ACCESS_MASK DesiredAccess,
    POBJECT_ATTRIBUTES ObjectAttributes,
    PCLIENT_ID ClientId
);

NTSYSAPI 
NTSTATUS 
NTAPI 
ZwDeviceIoControlFile(
    HANDLE  FileHandle,
    HANDLE  Event,
    PIO_APC_ROUTINE  ApcRoutine,
    PVOID  ApcContext,
    PIO_STATUS_BLOCK  IoStatusBlock,
    ULONG  IoControlCode,
    PVOID  InputBuffer,
    ULONG  InputBufferLength,
    PVOID  OutputBuffer,
    ULONG  OutputBufferLength
); 

NTSYSAPI 
NTSTATUS 
NTAPI
ZwFsControlFile(
    HANDLE  FileHandle,
    HANDLE  Event OPTIONAL,
    PIO_APC_ROUTINE  ApcRoutine OPTIONAL,
    PVOID  ApcContext OPTIONAL,
    PIO_STATUS_BLOCK  IoStatusBlock,
    ULONG  FsControlCode,
    PVOID  InputBuffer OPTIONAL,
    ULONG  InputBufferLength,
    PVOID  OutputBuffer OPTIONAL,
    ULONG  OutputBufferLength
);

NTSYSAPI 
NTSTATUS
NTAPI
ZwSaveKey(
    HANDLE  KeyHandle,
    HANDLE  FileHandle
); 

NTSYSAPI 
NTSTATUS
NTAPI
ZwQueryVolumeInformationFile(
    HANDLE FileHandle,
    PIO_STATUS_BLOCK IoStatusBlock,
    PVOID FsInformation,
    ULONG Length,
    FS_INFORMATION_CLASS FsInformationClass
); 

NTSYSAPI 
NTSTATUS
NTAPI
ZwQuerySecurityObject(
    HANDLE  Handle,
    SECURITY_INFORMATION  SecurityInformation,
    PSECURITY_DESCRIPTOR  SecurityDescriptor,
    ULONG  Length,
    PULONG  LengthNeeded
);

NTSYSAPI 
NTSTATUS
NTAPI
ZwSetSecurityObject(
    HANDLE  Handle,
    SECURITY_INFORMATION  SecurityInformation,
    PSECURITY_DESCRIPTOR  SecurityDescriptor
); 


NTSYSAPI 
NTSTATUS
NTAPI
ZwDuplicateObject(
    HANDLE SourceProcessHandle,
    HANDLE SourceHandle,
    HANDLE TargetProcessHandle,
    PHANDLE TargetHandle,
    ACCESS_MASK DesiredAccess,
    ULONG HandleAttributes,
    ULONG Options
);

NTSYSAPI 
NTSTATUS
NTAPI
RtlGetDaclSecurityDescriptor(
    PSECURITY_DESCRIPTOR  SecurityDescriptor,
    PBOOLEAN  DaclPresent,
    PACL  *Dacl,
    PBOOLEAN  DaclDefaulted
);

#ifndef _NTIFS_INCLUDED_

typedef struct _SID_IDENTIFIER_AUTHORITY
{
    UCHAR Value[ 6 ];

} SID_IDENTIFIER_AUTHORITY;

typedef struct _SID_IDENTIFIER_AUTHORITY *PSID_IDENTIFIER_AUTHORITY;

#endif

NTSYSAPI 
NTSTATUS
NTAPI
RtlInitializeSid(
    PSID  Sid,
    PSID_IDENTIFIER_AUTHORITY  IdentifierAuthority,
    UCHAR  SubAuthorityCount
); 

NTSYSAPI 
ULONG
NTAPI
RtlLengthSid(
    PSID  Sid
); 

NTSYSAPI 
NTSTATUS
NTAPI
RtlAddAccessAllowedAce(
    PACL  Acl,
    ULONG  AceRevision,
    ACCESS_MASK  AccessMask,
    PSID  Sid
);

NTSYSAPI 
NTSTATUS
NTAPI
RtlSetDaclSecurityDescriptor(
    OUT PSECURITY_DESCRIPTOR  SecurityDescriptor,
    BOOLEAN  DaclPresent,
    PACL  Dacl,
    BOOLEAN  DaclDefaulted
);

NTSYSAPI 
NTSTATUS
NTAPI
RtlSelfRelativeToAbsoluteSD2(
    PSECURITY_DESCRIPTOR pSelfRelativeSecurityDescriptor,
    PULONG pBufferSize
); 

NTSYSAPI 
BOOLEAN
NTAPI
RtlValidSid(
    PSID Sid
); 

#ifndef _NTIFS_INCLUDED_

typedef struct _KAPC_STATE 
{
    LIST_ENTRY ApcListHead[2];
    PVOID Process;
    BOOLEAN KernelApcInProgress;
    BOOLEAN KernelApcPending;
    BOOLEAN UserApcPending;

} KAPC_STATE, 
*PKAPC_STATE;

#endif

NTSYSAPI
VOID
NTAPI 
KeStackAttachProcess(
    PEPROCESS Process,
    PKAPC_STATE ApcState
);

NTSYSAPI
VOID
NTAPI
KeUnstackDetachProcess(
    PKAPC_STATE ApcState
);

NTSYSAPI
NTSTATUS
NTAPI
PsLookupProcessByProcessId(
    HANDLE ProcessId,
    PEPROCESS *Process
);

NTSYSAPI
NTSTATUS
NTAPI
PsLookupThreadByThreadId(
  HANDLE ThreadId,
  PETHREAD *Thread
);


NTSYSAPI
NTSTATUS
NTAPI
ObOpenObjectByPointer(
    PVOID Object,
    ULONG HandleAttributes,
    PACCESS_STATE PassedAccessState,
    ACCESS_MASK DesiredAccess,
    POBJECT_TYPE ObjectType,
    KPROCESSOR_MODE AccessMode,
    PHANDLE Handle
);

NTSYSAPI
NTSTATUS
NTAPI
ObOpenObjectByName(
    POBJECT_ATTRIBUTES ObjectAttributes,
    POBJECT_TYPE ObjectType, 
    KPROCESSOR_MODE AccessMode,
    PACCESS_STATE AccessState, 
    ACCESS_MASK DesiredAccess,
    PVOID ParseContext, 
    PHANDLE Handle
);

NTSYSAPI
NTSTATUS
NTAPI
ObReferenceObjectByName(
    PUNICODE_STRING ObjectPath,
    ULONG Attributes,
    PACCESS_STATE PassedAccessState,
    ACCESS_MASK DesiredAccess,
    POBJECT_TYPE ObjectType,
    KPROCESSOR_MODE AccessMode,
    PVOID ParseContext,
    PVOID *ObjectPtr
);

NTKERNELAPI 
NTSTATUS 
ObQueryNameString(
    PVOID Object,
    POBJECT_NAME_INFORMATION ObjectNameInfo,
    ULONG Length,
    PULONG ReturnLength
);

NTKERNELAPI
VOID
KeSetSystemAffinityThread(
    KAFFINITY Affinity
);

typedef enum
{
    OriginalApcEnvironment,
    AttachedApcEnvironment,
    CurrentApcEnvironment

} KAPC_ENVIRONMENT;

NTKERNELAPI
VOID
KeInitializeApc(
    PRKAPC Apc,
    PRKTHREAD Thread,
    KAPC_ENVIRONMENT Environment,
    PKKERNEL_ROUTINE KernelRoutine,
    PKRUNDOWN_ROUTINE RundownRoutine,
    PKNORMAL_ROUTINE NormalRoutine,
    KPROCESSOR_MODE ApcMode,
    PVOID NormalContext
);

NTKERNELAPI
BOOLEAN
KeInsertQueueApc(
    PKAPC Apc,
    PVOID SystemArgument1,
    PVOID SystemArgument2,
    KPRIORITY Increment
);
