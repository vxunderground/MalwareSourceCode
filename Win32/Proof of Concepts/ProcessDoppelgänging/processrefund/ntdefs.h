#pragma once
#include <Windows.h>
#include <KtmW32.h>
#include <lmerr.h>
#include <winternl.h>

#define RTL_MAX_DRIVE_LETTERS   32
#define RTL_USER_PROC_PARAMS_NORMALIZED 0x00000001

typedef struct _UNICODE_STRING_DWORD64
{
	WORD Length;
	WORD MaximumLength;
	DWORD64 Buffer;
} UNICODE_STRING64, STRING64, *PSTRING64;

struct _LIST_ENTRY_DWORD64
{
	DWORD64 Flink;
	DWORD64 Blink;
};

typedef struct _CURDIR_64
{
	UNICODE_STRING64 DosPath;
	UINT64 Handle;
} CURDIR64, *PCURDIR64;
typedef struct _RTL_DRIVE_LETTER_CURDIR_64
{
	WORD Flags;
	WORD Length;
	ULONG TimeStamp;
	STRING64 DosPath;
} RTL_DRIVE_LETTER_CURDIR64, *PRTL_DRIVE_LETTER_CURDIR64;
typedef struct _RTL_USER_PROCESS_PARAMETERS_64
{
	ULONG MaximumLength;
	ULONG Length;
	ULONG Flags;
	ULONG DebugFlags;
	UINT64 ConsoleHandle;
	ULONG ConsoleFlags;
	UINT64 StandardInput;
	UINT64 StandardOutput;
	UINT64 StandardError;
	CURDIR64 CurrentDirectory;
	UNICODE_STRING64 DllPath;
	UNICODE_STRING64 ImagePathName;
	UNICODE_STRING64 CommandLine;
	UINT64 Environment;
	ULONG StartingX;
	ULONG StartingY;
	ULONG CountX;
	ULONG CountY;
	ULONG CountCharsX;
	ULONG CountCharsY;
	ULONG FillAttribute;
	ULONG WindowFlags;
	ULONG ShowWindowFlags;
	UNICODE_STRING64 WindowTitle;
	UNICODE_STRING64 DesktopInfo;
	UNICODE_STRING64 ShellInfo;
	UNICODE_STRING64 RuntimeData;
	RTL_DRIVE_LETTER_CURDIR64 CurrentDirectores[32];
	ULONG EnvironmentSize;
} RTL_USER_PROCESS_PARAMETERS64, *PRTL_USER_PROCESS_PARAMETERS64;


typedef struct _CURDIR
{
	UNICODE_STRING DosPath;
	HANDLE Handle;
} CURDIR, *PCURDIR;
typedef struct _RTL_DRIVE_LETTER_CURDIR
{
	USHORT Flags;
	USHORT Length;
	ULONG TimeStamp;
	UNICODE_STRING DosPath;
} RTL_DRIVE_LETTER_CURDIR, *PRTL_DRIVE_LETTER_CURDIR;

typedef struct my_RTL_USER_PROCESS_PARAMETERS
{
	ULONG MaximumLength;
	ULONG Length;

	ULONG Flags;
	ULONG DebugFlags;

	HANDLE ConsoleHandle;
	ULONG ConsoleFlags;
	HANDLE StandardInput;
	HANDLE StandardOutput;
	HANDLE StandardError;

	CURDIR CurrentDirectory;
	UNICODE_STRING DllPath;
	UNICODE_STRING ImagePathName;
	UNICODE_STRING CommandLine;
	PVOID Environment;

	ULONG StartingX;
	ULONG StartingY;
	ULONG CountX;
	ULONG CountY;
	ULONG CountCharsX;
	ULONG CountCharsY;
	ULONG FillAttribute;

	ULONG WindowFlags;
	ULONG ShowWindowFlags;
	UNICODE_STRING WindowTitle;
	UNICODE_STRING DesktopInfo;
	UNICODE_STRING ShellInfo;
	UNICODE_STRING RuntimeData;
	RTL_DRIVE_LETTER_CURDIR CurrentDirectories[RTL_MAX_DRIVE_LETTERS];

	ULONG_PTR EnvironmentSize;
	ULONG_PTR EnvironmentVersion;
	PVOID PackageDependencyData;
	ULONG ProcessGroupId;
	ULONG LoaderThreads;
} my_RTL_USER_PROCESS_PARAMETERS, *my_PRTL_USER_PROCESS_PARAMETERS;

typedef struct _PROCESS_BASIC_INFORMATION64 {
	NTSTATUS ExitStatus;
	UINT32 Reserved0;
	UINT64 PebBaseAddress;
	UINT64 AffinityMask;
	UINT32 BasePriority;
	UINT32 Reserved1;
	UINT64 UniqueProcessId;
	UINT64 InheritedFromUniqueProcessId;
} PROCESS_BASIC_INFORMATION64;
typedef struct _PEB64
{

	union
	{
		struct
		{
			BYTE InheritedAddressSpace;
			BYTE ReadImageFileExecOptions;
			BYTE BeingDebugged;
			BYTE BitField;
		};
		DWORD64 dummy01;
	};
	DWORD64 Mutant;
	 DWORD64 ImageBaseAddress;
	 DWORD64 Ldr;
	 DWORD64 ProcessParameters;
	 DWORD64 SubSystemData;
	 DWORD64 ProcessHeap;
	 DWORD64 FastPebLock;
	 DWORD64 AtlThunkSListPtr;
	 DWORD64 IFEOKey;
	 DWORD64 CrossProcessFlags;
	 DWORD64 UserSharedInfoPtr;
	DWORD SystemReserved;
	DWORD AtlThunkSListPtr32;
	 DWORD64 ApiSetMap;
	 DWORD64 TlsExpansionCounter;
	 DWORD64 TlsBitmap;
	DWORD TlsBitmapBits[2];
	 DWORD64 ReadOnlySharedMemoryBase;
	 DWORD64 HotpatchInformation;
	 DWORD64 ReadOnlyStaticServerData;
	 DWORD64 AnsiCodePageData;
	 DWORD64 OemCodePageData;
	 DWORD64 UnicodeCaseTableData;
	DWORD NumberOfProcessors;
	union
	{
		DWORD NtGlobalFlag;
		DWORD dummy02;
	};
	LARGE_INTEGER CriticalSectionTimeout;
	 DWORD64 HeapSegmentReserve;
	 DWORD64 HeapSegmentCommit;
	 DWORD64 HeapDeCommitTotalFreeThreshold;
	 DWORD64 HeapDeCommitFreeBlockThreshold;
	DWORD NumberOfHeaps;
	DWORD MaximumNumberOfHeaps;
	 DWORD64 ProcessHeaps;
	 DWORD64 GdiSharedHandleTable;
	 DWORD64 ProcessStarterHelper;
	 DWORD64 GdiDCAttributeList;
	 DWORD64 LoaderLock;
	DWORD OSMajorVersion;
	DWORD OSMinorVersion;
	WORD OSBuildNumber;
	WORD OSCSDVersion;
	DWORD OSPlatformId;
	DWORD ImageSubsystem;
	DWORD ImageSubsystemMajorVersion;
	 DWORD64 ImageSubsystemMinorVersion;
	 DWORD64 ActiveProcessAffinityMask;
	 DWORD64 GdiHandleBuffer[30];
	 DWORD64 PostProcessInitRoutine;
	 DWORD64 TlsExpansionBitmap;
	DWORD TlsExpansionBitmapBits[32];
	 DWORD64 SessionId;
	ULARGE_INTEGER AppCompatFlags;
	ULARGE_INTEGER AppCompatFlagsUser;
	 DWORD64 pShimData;
	 DWORD64 AppCompatInfo;
	 struct _UNICODE_STRING_DWORD64 CSDVersion;
	 DWORD64 ActivationContextData;
	 DWORD64 ProcessAssemblyStorageMap;
	 DWORD64 SystemDefaultActivationContextData;
	 DWORD64 SystemAssemblyStorageMap;
	 DWORD64 MinimumStackCommit;
	 DWORD64 FlsCallback;
	 struct _LIST_ENTRY_DWORD64 FlsListHead;
	 DWORD64 FlsBitmap;
	DWORD FlsBitmapBits[4];
	 DWORD64 FlsHighIndex;
	 DWORD64 WerRegistrationData;
	 DWORD64 WerShipAssertPtr;
	 DWORD64 pContextData;
	 DWORD64 pImageHeaderHash;
	 DWORD64 TracingFlags;
	 DWORD64 CsrServerReadOnlySharedMemoryBase;
} PEB64;






typedef
NTSTATUS(WINAPI *pfnNtWow64QueryInformationProcess64)
(HANDLE ProcessHandle, UINT32 ProcessInformationClass,
	PVOID ProcessInformation, UINT32 ProcessInformationLength,
	UINT32* ReturnLength);

typedef
NTSTATUS(WINAPI *pfnNtWow64ReadVirtualMemory64)
(HANDLE ProcessHandle, PVOID64 BaseAddress,
	PVOID BufferData, UINT64 BufferLength,
	PUINT64 ReturnLength);

typedef
NTSTATUS(WINAPI *pfnNtQueryInformationProcess)
(HANDLE ProcessHandle, ULONG ProcessInformationClass,
	PVOID ProcessInformation, UINT32 ProcessInformationLength,
	UINT32* ReturnLength);
typedef  NTSTATUS(NTAPI *NtResumeThread)(
	_In_ HANDLE               ThreadHandle,
	_Out_opt_ PULONG              SuspendCount
	);

typedef NTSTATUS(NTAPI *my_NtQueryInformationProcess)(
	IN HANDLE ProcessHandle,
	IN PROCESSINFOCLASS ProcessInformationClass,
	OUT PVOID ProcessInformation,
	IN ULONG ProcessInformationLength,
	OUT PULONG ReturnLength OPTIONAL
	);
typedef NTSTATUS(NTAPI *my_NtWow64QueryInformationProcess64)
(
	IN  HANDLE ProcessHandle,
	IN  ULONG  ProcessInformationClass,
	OUT PVOID  ProcessInformation64,
	IN  ULONG  Length,
	OUT PULONG ReturnLength OPTIONAL
	);

typedef NTSTATUS(NTAPI *RtlCreateProcessParametersEx)(
	_Out_ my_PRTL_USER_PROCESS_PARAMETERS *pProcessParameters,
	_In_ PUNICODE_STRING ImagePathName,
	_In_opt_ PUNICODE_STRING DllPath,
	_In_opt_ PUNICODE_STRING CurrentDirectory,
	_In_opt_ PUNICODE_STRING CommandLine,
	_In_opt_ PVOID Environment,
	_In_opt_ PUNICODE_STRING WindowTitle,
	_In_opt_ PUNICODE_STRING DesktopInfo,
	_In_opt_ PUNICODE_STRING ShellInfo,
	_In_opt_ PUNICODE_STRING RuntimeData,
	_In_ ULONG Flags // pass RTL_USER_PROC_PARAMS_NORMALIZED to keep parameters normalized
	);

typedef NTSTATUS(NTAPI *NtCreateThreadEx)(
	OUT PHANDLE hThread,
	IN ACCESS_MASK DesiredAccess,
	IN LPVOID ObjectAttributes,
	IN HANDLE ProcessHandle,
	IN LPTHREAD_START_ROUTINE lpStartAddress,
	IN LPVOID lpParameter,
	IN BOOL CreateSuspended,
	IN DWORD StackZeroBits,
	IN DWORD SizeOfStackCommit,
	IN DWORD SizeOfStackReserve,
	OUT LPVOID lpBytesBuffer
	);


typedef NTSTATUS(NTAPI *NtCreateSection)(
	_Out_    PHANDLE            SectionHandle,
	_In_     ACCESS_MASK        DesiredAccess,
	_In_opt_ POBJECT_ATTRIBUTES ObjectAttributes,
	_In_opt_ PLARGE_INTEGER     MaximumSize,
	_In_     ULONG              SectionPageProtection,
	_In_     ULONG              AllocationAttributes,
	_In_opt_ HANDLE             FileHandle
	);


typedef NTSTATUS(NTAPI *NtCreateProcessEx)
(
	OUT PHANDLE     ProcessHandle,
	IN ACCESS_MASK  DesiredAccess,
	IN POBJECT_ATTRIBUTES ObjectAttributes  OPTIONAL,
	IN HANDLE   ParentProcess,
	IN ULONG    Flags,
	IN HANDLE SectionHandle     OPTIONAL,
	IN HANDLE DebugPort     OPTIONAL,
	IN HANDLE ExceptionPort     OPTIONAL,
	IN BOOLEAN  InJob
	);
typedef VOID (NTAPI *my_RtlInitUnicodeString)(
	_Out_    PUNICODE_STRING DestinationString,
	_In_opt_ PCWSTR          SourceString
);
typedef POBJECT_ATTRIBUTES(NTAPI *BaseFormatObjectAttributes)(OUT POBJECT_ATTRIBUTES ObjectAttributes,
	IN PSECURITY_ATTRIBUTES SecurityAttributes OPTIONAL,
	IN PUNICODE_STRING ObjectName,
	OUT PDWORD NumberOfBytes);

//
// NtCreateProcessEx flags
//
#define PS_REQUEST_BREAKAWAY                     1
#define PS_NO_DEBUG_INHERIT                     2
#define PS_INHERIT_HANDLES                      4
#define PS_UNKNOWN_VALUE                        8
#define PS_ALL_FLAGS PS_REQUEST_BREAKAWAY |PS_NO_DEBUG_INHERIT |PS_INHERIT_HANDLES | PS_UNKNOWN_VALUE

