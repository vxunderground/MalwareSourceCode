// SetWindowsHookEx.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <Windows.h>
#include <iostream>
using namespace std;
#include "tlhelp32.h"

HHOOK Handle = NULL;
LRESULT CALLBACK HookProc
	(
	int nCode,
	WPARAM wParam,
	LPARAM lParam
	);
BOOL InstallSetWindowsHookEx(ULONG ProcessId,BOOL Hook)
{
	if(Hook)
	{
		HMODULE hModule = LoadLibrary(L"DllTestx64.dll");
		if(hModule==NULL)
		{
			cout<<"Loadlibrary Fail"<<endl;
			getchar();
			return FALSE;
		}
		HOOKPROC TestAddress = (HOOKPROC)GetProcAddress(hModule,"Test");
		if(TestAddress==NULL)
		{
			cout<<"Get HookProc Failed"<<endl;
			getchar();
			return FALSE;
		}
	//  全局钩子
	//	Handle = SetWindowsHookEx(WH_KEYBOARD,TestAddress,hModule,0);
		// 定义线程信息结构  
		
		THREADENTRY32 te32 = {sizeof(THREADENTRY32)} ;  
		//创建系统线程快照  
		HANDLE hThreadSnap = CreateToolhelp32Snapshot ( TH32CS_SNAPTHREAD, 0 ) ;  
		if ( hThreadSnap == INVALID_HANDLE_VALUE )  
			return FALSE ;  
		// 循环枚举线程信息  
		if ( Thread32First ( hThreadSnap, &te32 ) )  
		{  
			do{  
				if(te32.th32OwnerProcessID == ProcessId)
				{
					Handle = SetWindowsHookEx(WH_KEYBOARD,TestAddress,hModule,te32.th32ThreadID);
					if(Handle == NULL)
					{
						printf("The KeyBoard could not be hooked LastError [%d]\n", GetLastError());
						getchar();
						return FALSE;
					}
				}
			}while (Thread32Next(hThreadSnap, &te32));  
		}  	
		CloseHandle (hThreadSnap);	
	}
	else
	{
		UnhookWindowsHookEx(Handle);  
	}	
}


int _tmain(int argc, _TCHAR* argv[])
{
	int a = 0;
	int b = 0;
	cout<<"Please input ProcessId:\r\n";
	cin>>a;
	InstallSetWindowsHookEx(a,TRUE);
	cin>>b;
	if(b==20)
	{
		InstallSetWindowsHookEx(a,FALSE);
	}
	return 0;
}


LRESULT CALLBACK HookProc
	(
	int nCode,
	WPARAM wParam,
	LPARAM lParam
	)
{
	MessageBox(NULL,L"Suu",L"Suu",1);
	return 0;
}