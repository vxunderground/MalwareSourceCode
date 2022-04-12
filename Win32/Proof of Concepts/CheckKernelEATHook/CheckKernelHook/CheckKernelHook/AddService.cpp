#include "AddService.h"
#include "stdafx.h"
#include "CheckKernelHookDlg.h"
#include <Winsvc.h>
#pragma once


BOOL Release(){
	// 	HRSRC res = FindResource(NULL,MAKEINTRESOURCE(IDR_SYS),TEXT("BINARY"));
	// 	if(!res)
	// 		return FALSE;
	// 	HGLOBAL resGlobal = LoadResource(NULL,res);
	// 	if(!resGlobal)
	// 		return FALSE;
	// 	DWORD size=SizeofResource(NULL,res);
	// 	BYTE* ptr=(BYTE*)LockResource(resGlobal);
	// 	if(!ptr)
	// 		return FALSE;
	HANDLE hFile=CreateFile(TEXT("ReloadKernel.sys"), GENERIC_WRITE,
		0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hFile==INVALID_HANDLE_VALUE)
		return FALSE;
	DWORD dw;
	// 	if(!WriteFile(hFile,ptr,size,&dw,NULL)){
	// 		CloseHandle(hFile);
	// 		return FALSE;
	// 	}
	CloseHandle(hFile);
	return TRUE;
}




BOOL UnloadDrv(TCHAR* DriverName){
	SC_HANDLE      hSCManager;
	SC_HANDLE      hService;
	SERVICE_STATUS ss;


	hSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
	if (!hSCManager){
		return FALSE;
	}


	hService = OpenService( hSCManager,DriverName,SERVICE_ALL_ACCESS);
	if( !hService ) {
		CloseServiceHandle(hSCManager);
		return FALSE;
	}

	ControlService(hService, SERVICE_CONTROL_STOP, &ss);
	DeleteService(hService);
	CloseServiceHandle(hService);
	CloseServiceHandle(hSCManager);
	return TRUE;
}



BOOL LoadDrv(TCHAR* DriverName){
	TCHAR DrvFullPathName[MAX_PATH];
	SC_HANDLE schSCManager;
	SC_HANDLE schService;
	UnloadDrv(L"CheckKernelHook");
	// 	if(!Release())
	// 		return FALSE;
	GetFullPathName(TEXT("CheckKernelHook.sys"), MAX_PATH, DrvFullPathName, NULL);
	schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
	if (!schSCManager)
		return FALSE;


	schService = CreateService( 
		schSCManager,DriverName,DriverName,
		SERVICE_ALL_ACCESS,
		SERVICE_KERNEL_DRIVER,
		SERVICE_DEMAND_START,
		SERVICE_ERROR_NORMAL,
		DrvFullPathName,
		NULL,NULL,NULL,NULL,NULL
		);


	if (!schService){
		if (GetLastError() == ERROR_SERVICE_EXISTS){
			schService = OpenService(schSCManager,DriverName,SERVICE_ALL_ACCESS);
			if (!schService){
				CloseServiceHandle(schSCManager);
				return FALSE;
			}
		}else{
			CloseServiceHandle(schSCManager);
			return FALSE;
		}
	}


	if (!StartService(schService,0,NULL)){
		if ( !(GetLastError()==ERROR_SERVICE_ALREADY_RUNNING ) ){
			CloseServiceHandle(schService);
			CloseServiceHandle(schSCManager);
			return FALSE;
		}
	}


	CloseServiceHandle(schService);
	CloseServiceHandle(schSCManager);
	return TRUE;
}


