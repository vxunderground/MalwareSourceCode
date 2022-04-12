#pragma once

#include <vector>
#include <map>
#include <Ntsecapi.h>
#include <DbgHelp.h>

#define BUFFER_SIZE 0x2000

typedef struct _RTL_DRIVE_LETTER_CURDIR {
    USHORT                  Flags;
    USHORT                  Length;
    ULONG                   TimeStamp;
    UNICODE_STRING          DosPath;
} RTL_DRIVE_LETTER_CURDIR, *PRTL_DRIVE_LETTER_CURDIR;

typedef struct _LDR_MODULE {
    LIST_ENTRY              InLoadOrderModuleList;
    LIST_ENTRY              InMemoryOrderModuleList;
    LIST_ENTRY              InInitializationOrderModuleList;
    PVOID                   BaseAddress;
    PVOID                   EntryPoint;
    ULONG                   SizeOfImage;
    UNICODE_STRING          FullDllName;
    UNICODE_STRING          BaseDllName;
    ULONG                   Flags;
    SHORT                   LoadCount;
    SHORT                   TlsIndex;
    LIST_ENTRY              HashTableEntry;
    ULONG                   TimeDateStamp;
} LDR_MODULE, *PLDR_MODULE;

typedef struct _PEB_LDR_DATA {
    ULONG                   Length;
    BOOLEAN                 Initialized;
    PVOID                   SsHandle;
    LIST_ENTRY              InLoadOrderModuleList;
    LIST_ENTRY              InMemoryOrderModuleList;
    LIST_ENTRY              InInitializationOrderModuleList;
} PEB_LDR_DATA, *PPEB_LDR_DATA;

typedef struct _RTL_USER_PROCESS_PARAMETERS {
    ULONG                   MaximumLength;
    ULONG                   Length;
    ULONG                   Flags;
    ULONG                   DebugFlags;
    PVOID                   ConsoleHandle;
    ULONG                   ConsoleFlags;
    HANDLE                  StdInputHandle;
    HANDLE                  StdOutputHandle;
    HANDLE                  StdErrorHandle;
    UNICODE_STRING          CurrentDirectoryPath;
    HANDLE                  CurrentDirectoryHandle;
    UNICODE_STRING          DllPath;
    UNICODE_STRING          ImagePathName;
    UNICODE_STRING          CommandLine;
    PVOID                   Environment;
    ULONG                   StartingPositionLeft;
    ULONG                   StartingPositionTop;
    ULONG                   Width;
    ULONG                   Height;
    ULONG                   CharWidth;
    ULONG                   CharHeight;
    ULONG                   ConsoleTextAttributes;
    ULONG                   WindowFlags;
    ULONG                   ShowWindowFlags;
    UNICODE_STRING          WindowTitle;
    UNICODE_STRING          DesktopName;
    UNICODE_STRING          ShellInfo;
    UNICODE_STRING          RuntimeData;
    RTL_DRIVE_LETTER_CURDIR DLCurrentDirectory[0x20];
} RTL_USER_PROCESS_PARAMETERS, *PRTL_USER_PROCESS_PARAMETERS;

typedef struct _PEB_FREE_BLOCK {
    _PEB_FREE_BLOCK          *Next;
    ULONG                   Size;
} PEB_FREE_BLOCK, *PPEB_FREE_BLOCK;

typedef void (*PPEBLOCKROUTINE)(
                                PVOID PebLock
                                );

typedef struct _PEB {
    BOOLEAN                 InheritedAddressSpace;
    BOOLEAN                 ReadImageFileExecOptions;
    BOOLEAN                 BeingDebugged;
    BOOLEAN                 Spare;
    HANDLE                  Mutant;
    PVOID                   ImageBaseAddress;
    PPEB_LDR_DATA           LoaderData;
    PRTL_USER_PROCESS_PARAMETERS ProcessParameters;
    PVOID                   SubSystemData;
    PVOID                   ProcessHeap;
    PVOID                   FastPebLock;
    PPEBLOCKROUTINE         FastPebLockRoutine;
    PPEBLOCKROUTINE         FastPebUnlockRoutine;
    ULONG                   EnvironmentUpdateCount;
    PVOID*                  KernelCallbackTable;
    PVOID                   EventLogSection;
    PVOID                   EventLog;
    PPEB_FREE_BLOCK         FreeList;
    ULONG                   TlsExpansionCounter;
    PVOID                   TlsBitmap;
    ULONG                   TlsBitmapBits[0x2];
    PVOID                   ReadOnlySharedMemoryBase;
    PVOID                   ReadOnlySharedMemoryHeap;
    PVOID*                  ReadOnlyStaticServerData;
    PVOID                   AnsiCodePageData;
    PVOID                   OemCodePageData;
    PVOID                   UnicodeCaseTableData;
    ULONG                   NumberOfProcessors;
    ULONG                   NtGlobalFlag;
    BYTE                    Spare2[0x4];
    LARGE_INTEGER           CriticalSectionTimeout;
    ULONG                   HeapSegmentReserve;
    ULONG                   HeapSegmentCommit;
    ULONG                   HeapDeCommitTotalFreeThreshold;
    ULONG                   HeapDeCommitFreeBlockThreshold;
    ULONG                   NumberOfHeaps;
    ULONG                   MaximumNumberOfHeaps;
    PVOID*                  *ProcessHeaps;
    PVOID                   GdiSharedHandleTable;
    PVOID                   ProcessStarterHelper;
    PVOID                   GdiDCAttributeList;
    PVOID                   LoaderLock;
    ULONG                   OSMajorVersion;
    ULONG                   OSMinorVersion;
    ULONG                   OSBuildNumber;
    ULONG                   OSPlatformId;
    ULONG                   ImageSubSystem;
    ULONG                   ImageSubSystemMajorVersion;
    ULONG                   ImageSubSystemMinorVersion;
    ULONG                   GdiHandleBuffer[0x22];
    ULONG                   PostProcessInitRoutine;
    ULONG                   TlsExpansionBitmap;
    BYTE                    TlsExpansionBitmapBits[0x80];
    ULONG                   SessionId;
} PEB, *PPEB;

typedef struct BASE_RELOCATION_BLOCK {
    DWORD PageAddress;
    DWORD BlockSize;
} BASE_RELOCATION_BLOCK, *PBASE_RELOCATION_BLOCK;

typedef struct BASE_RELOCATION_ENTRY {
    USHORT Offset : 12;
    USHORT Type : 4;
} BASE_RELOCATION_ENTRY, *PBASE_RELOCATION_ENTRY;

#define CountRelocationEntries(dwBlockSize)        \
    (dwBlockSize -                                \
    sizeof(BASE_RELOCATION_BLOCK)) /            \
    sizeof(BASE_RELOCATION_ENTRY)

inline PEB* GetPEB()
{
    __asm mov eax, dword ptr fs:0x30;
}

inline PIMAGE_NT_HEADERS32 GetNTHeaders(DWORD dwImageBase)
{
    return (PIMAGE_NT_HEADERS32)(dwImageBase + 
        ((PIMAGE_DOS_HEADER)dwImageBase)->e_lfanew);
}

inline PLOADED_IMAGE GetLoadedImage(DWORD dwImageBase)
{
    PIMAGE_DOS_HEADER pDosHeader = (PIMAGE_DOS_HEADER)dwImageBase;
    PIMAGE_NT_HEADERS32 pNTHeaders = GetNTHeaders(dwImageBase);

    PLOADED_IMAGE pImage = new LOADED_IMAGE();

    pImage->FileHeader = 
        (PIMAGE_NT_HEADERS32)(dwImageBase + pDosHeader->e_lfanew);

    pImage->NumberOfSections = 
        pImage->FileHeader->FileHeader.NumberOfSections;

    pImage->Sections = 
        (PIMAGE_SECTION_HEADER)(dwImageBase + pDosHeader->e_lfanew + 
        sizeof(IMAGE_NT_HEADERS32));

    return pImage;
}

inline char* GetDLLName(DWORD dwImageBase, 
                        IMAGE_IMPORT_DESCRIPTOR ImageImportDescriptor)
{
    return (char*)(dwImageBase + ImageImportDescriptor.Name);
}

inline IMAGE_DATA_DIRECTORY GetImportDirectory(PIMAGE_NT_HEADERS32 pFileHeader)
{
    return pFileHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
}

inline PIMAGE_IMPORT_DESCRIPTOR GetImportDescriptors(PIMAGE_NT_HEADERS32 pFileHeader,
                                                     IMAGE_DATA_DIRECTORY ImportDirectory)
{
    return (PIMAGE_IMPORT_DESCRIPTOR)(pFileHeader->OptionalHeader.ImageBase + 
        ImportDirectory.VirtualAddress);
}

inline PIMAGE_THUNK_DATA32 GetILT(DWORD dwImageBase, 
                                  IMAGE_IMPORT_DESCRIPTOR ImageImportDescriptor)
{
    return (PIMAGE_THUNK_DATA32)(dwImageBase + ImageImportDescriptor.OriginalFirstThunk);
}

inline PIMAGE_THUNK_DATA32 GetIAT(DWORD dwImageBase, 
                                  IMAGE_IMPORT_DESCRIPTOR ImageImportDescriptor)
{
    return (PIMAGE_THUNK_DATA32)(dwImageBase + ImageImportDescriptor.FirstThunk);
}

inline PIMAGE_IMPORT_BY_NAME GetImportByName(DWORD dwImageBase, 
                                             IMAGE_THUNK_DATA32 itdImportLookup)
{
    return (PIMAGE_IMPORT_BY_NAME)(dwImageBase + itdImportLookup.u1.AddressOfData);
}


extern std::map<PWSTR, std::vector<DWORD>> gCodeChecksums;

void WalkLoadOrderModules(void (*pLdrModuleFunction)(PLDR_MODULE, DWORD, PVOID), PVOID pParameters);

void GenerateCodeChecksums(PLDR_MODULE pLdrModule, std::vector<DWORD>* pChecksums);

void SetInitialLdrCodeChecksums(PLDR_MODULE pLdrModule, DWORD dwIndex, PVOID pParams);

void ValidateLdrCodeChecksums(PLDR_MODULE pLdrModule, DWORD dwIndex, PVOID pParams);

typedef struct _IAT_BACKUP_INFO {
    DWORD BackupLength;
    DWORD*** IATBackup;
} IAT_BACKUP_INFO, *PIAT_BACKUP_INFO;

DWORD** BackupIAT(DWORD dwImageBase);

void RepairIAT(DWORD dwImageBase, DWORD** pIATBackup);

DWORD FindRemotePEB(HANDLE hProcess);

PEB* ReadRemotePEB(HANDLE hProcess);

PLOADED_IMAGE ReadRemoteImage(HANDLE hProcess, LPCVOID lpImageBaseAddress);