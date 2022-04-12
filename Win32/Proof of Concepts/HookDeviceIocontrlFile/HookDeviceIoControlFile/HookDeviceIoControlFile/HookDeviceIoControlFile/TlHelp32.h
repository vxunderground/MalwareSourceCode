/*****************************************************************************\
*                                                                             *
* tlhelp32.h -  WIN32 tool help functions, types, and definitions             *
*                                                                             *
* Version 1.0                                                                 *
*                                                                             *
* NOTE: windows.h/winbase.h must be #included first                           *
*                                                                             *
* Copyright (c) Microsoft Corp.  All rights reserved.                         *
*                                                                             *
\*****************************************************************************/

#ifndef _INC_TOOLHELP32
#define _INC_TOOLHELP32

#if _MSC_VER > 1000
#pragma once
#endif

#ifdef __cplusplus
extern "C" {            /* Assume C declarations for C++ */
#endif  /* __cplusplus */

#define MAX_MODULE_NAME32 255

/****** Shapshot function **********************************************/

HANDLE
WINAPI
CreateToolhelp32Snapshot(
    DWORD dwFlags,
    DWORD th32ProcessID
    );

//
// The th32ProcessID argument is only used if TH32CS_SNAPHEAPLIST or
// TH32CS_SNAPMODULE is specified. th32ProcessID == 0 means the current
// process.
//
// NOTE that all of the snapshots are global except for the heap and module
//      lists which are process specific. To enumerate the heap or module
//      state for all WIN32 processes call with TH32CS_SNAPALL and the
//      current process. Then for each process in the TH32CS_SNAPPROCESS
//      list that isn't the current process, do a call with just
//      TH32CS_SNAPHEAPLIST and/or TH32CS_SNAPMODULE.
//
// dwFlags
//
#define TH32CS_SNAPHEAPLIST 0x00000001
#define TH32CS_SNAPPROCESS  0x00000002
#define TH32CS_SNAPTHREAD   0x00000004
#define TH32CS_SNAPMODULE   0x00000008
#define TH32CS_SNAPMODULE32 0x00000010
#define TH32CS_SNAPALL      (TH32CS_SNAPHEAPLIST | TH32CS_SNAPPROCESS | TH32CS_SNAPTHREAD | TH32CS_SNAPMODULE)
#define TH32CS_INHERIT      0x80000000
//
// Use CloseHandle to destroy the snapshot
//

/****** heap walking ***************************************************/

typedef struct tagHEAPLIST32
{
    SIZE_T dwSize;
    DWORD  th32ProcessID;   // owning process
    ULONG_PTR  th32HeapID;      // heap (in owning process's context!)
    DWORD  dwFlags;
} HEAPLIST32;
typedef HEAPLIST32 *  PHEAPLIST32;
typedef HEAPLIST32 *  LPHEAPLIST32;
//
// dwFlags
//
#define HF32_DEFAULT      1  // process's default heap
#define HF32_SHARED       2  // is shared heap

BOOL
WINAPI
Heap32ListFirst(
    HANDLE hSnapshot,
    LPHEAPLIST32 lphl
    );

BOOL
WINAPI
Heap32ListNext(
    HANDLE hSnapshot,
    LPHEAPLIST32 lphl
    );

typedef struct tagHEAPENTRY32
{
    SIZE_T dwSize;
    HANDLE hHandle;     // Handle of this heap block
    ULONG_PTR dwAddress;   // Linear address of start of block
    SIZE_T dwBlockSize; // Size of block in bytes
    DWORD  dwFlags;
    DWORD  dwLockCount;
    DWORD  dwResvd;
    DWORD  th32ProcessID;   // owning process
    ULONG_PTR  th32HeapID;      // heap block is in
} HEAPENTRY32;
typedef HEAPENTRY32 *  PHEAPENTRY32;
typedef HEAPENTRY32 *  LPHEAPENTRY32;
//
// dwFlags
//
#define LF32_FIXED    0x00000001
#define LF32_FREE     0x00000002
#define LF32_MOVEABLE 0x00000004

BOOL
WINAPI
Heap32First(
    LPHEAPENTRY32 lphe,
    DWORD th32ProcessID,
    ULONG_PTR th32HeapID
    );

BOOL
WINAPI
Heap32Next(
    LPHEAPENTRY32 lphe
    );

BOOL
WINAPI
Toolhelp32ReadProcessMemory(
    DWORD   th32ProcessID,
    LPCVOID lpBaseAddress,
    LPVOID  lpBuffer,
    SIZE_T  cbRead,
    SIZE_T *lpNumberOfBytesRead
    );

/***** Process walking *************************************************/

typedef struct tagPROCESSENTRY32W
{
    DWORD   dwSize;
    DWORD   cntUsage;
    DWORD   th32ProcessID;          // this process
    ULONG_PTR th32DefaultHeapID;
    DWORD   th32ModuleID;           // associated exe
    DWORD   cntThreads;
    DWORD   th32ParentProcessID;    // this process's parent process
    LONG    pcPriClassBase;         // Base priority of process's threads
    DWORD   dwFlags;
    WCHAR   szExeFile[MAX_PATH];    // Path
} PROCESSENTRY32W;
typedef PROCESSENTRY32W *  PPROCESSENTRY32W;
typedef PROCESSENTRY32W *  LPPROCESSENTRY32W;

BOOL
WINAPI
Process32FirstW(
    HANDLE hSnapshot,
    LPPROCESSENTRY32W lppe
    );

BOOL
WINAPI
Process32NextW(
    HANDLE hSnapshot,
    LPPROCESSENTRY32W lppe
    );

typedef struct tagPROCESSENTRY32
{
    DWORD   dwSize;
    DWORD   cntUsage;
    DWORD   th32ProcessID;          // this process
    ULONG_PTR th32DefaultHeapID;
    DWORD   th32ModuleID;           // associated exe
    DWORD   cntThreads;
    DWORD   th32ParentProcessID;    // this process's parent process
    LONG    pcPriClassBase;         // Base priority of process's threads
    DWORD   dwFlags;
    CHAR    szExeFile[MAX_PATH];    // Path
} PROCESSENTRY32;
typedef PROCESSENTRY32 *  PPROCESSENTRY32;
typedef PROCESSENTRY32 *  LPPROCESSENTRY32;

BOOL
WINAPI
Process32First(
    HANDLE hSnapshot,
    LPPROCESSENTRY32 lppe
    );

BOOL
WINAPI
Process32Next(
    HANDLE hSnapshot,
    LPPROCESSENTRY32 lppe
    );

#ifdef UNICODE
#define Process32First Process32FirstW
#define Process32Next Process32NextW
#define PROCESSENTRY32 PROCESSENTRY32W
#define PPROCESSENTRY32 PPROCESSENTRY32W
#define LPPROCESSENTRY32 LPPROCESSENTRY32W
#endif  // !UNICODE

/***** Thread walking **************************************************/

typedef struct tagTHREADENTRY32
{
    DWORD   dwSize;
    DWORD   cntUsage;
    DWORD   th32ThreadID;       // this thread
    DWORD   th32OwnerProcessID; // Process this thread is associated with
    LONG    tpBasePri;
    LONG    tpDeltaPri;
    DWORD   dwFlags;
} THREADENTRY32;
typedef THREADENTRY32 *  PTHREADENTRY32;
typedef THREADENTRY32 *  LPTHREADENTRY32;

BOOL
WINAPI
Thread32First(
    HANDLE hSnapshot,
    LPTHREADENTRY32 lpte
    );

BOOL
WINAPI
Thread32Next(
    HANDLE hSnapshot,
    LPTHREADENTRY32 lpte
    );

/***** Module walking *************************************************/

typedef struct tagMODULEENTRY32W
{
    DWORD   dwSize;
    DWORD   th32ModuleID;       // This module
    DWORD   th32ProcessID;      // owning process
    DWORD   GlblcntUsage;       // Global usage count on the module
    DWORD   ProccntUsage;       // Module usage count in th32ProcessID's context
    BYTE  * modBaseAddr;        // Base address of module in th32ProcessID's context
    DWORD   modBaseSize;        // Size in bytes of module starting at modBaseAddr
    HMODULE hModule;            // The hModule of this module in th32ProcessID's context
    WCHAR   szModule[MAX_MODULE_NAME32 + 1];
    WCHAR   szExePath[MAX_PATH];
} MODULEENTRY32W;
typedef MODULEENTRY32W *  PMODULEENTRY32W;
typedef MODULEENTRY32W *  LPMODULEENTRY32W;

BOOL
WINAPI
Module32FirstW(
    HANDLE hSnapshot,
    LPMODULEENTRY32W lpme
    );

BOOL
WINAPI
Module32NextW(
    HANDLE hSnapshot,
    LPMODULEENTRY32W lpme
    );


typedef struct tagMODULEENTRY32
{
    DWORD   dwSize;
    DWORD   th32ModuleID;       // This module
    DWORD   th32ProcessID;      // owning process
    DWORD   GlblcntUsage;       // Global usage count on the module
    DWORD   ProccntUsage;       // Module usage count in th32ProcessID's context
    BYTE  * modBaseAddr;        // Base address of module in th32ProcessID's context
    DWORD   modBaseSize;        // Size in bytes of module starting at modBaseAddr
    HMODULE hModule;            // The hModule of this module in th32ProcessID's context
    char    szModule[MAX_MODULE_NAME32 + 1];
    char    szExePath[MAX_PATH];
} MODULEENTRY32;
typedef MODULEENTRY32 *  PMODULEENTRY32;
typedef MODULEENTRY32 *  LPMODULEENTRY32;

//
// NOTE CAREFULLY that the modBaseAddr and hModule fields are valid ONLY
// in th32ProcessID's process context.
//

BOOL
WINAPI
Module32First(
    HANDLE hSnapshot,
    LPMODULEENTRY32 lpme
    );

BOOL
WINAPI
Module32Next(
    HANDLE hSnapshot,
    LPMODULEENTRY32 lpme
    );

#ifdef UNICODE
#define Module32First Module32FirstW
#define Module32Next Module32NextW
#define MODULEENTRY32 MODULEENTRY32W
#define PMODULEENTRY32 PMODULEENTRY32W
#define LPMODULEENTRY32 LPMODULEENTRY32W
#endif  // !UNICODE


#ifdef __cplusplus
}
#endif

#endif // _INC_TOOLHELP32
