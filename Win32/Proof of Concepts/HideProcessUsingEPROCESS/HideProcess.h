#ifndef CXX_HIDEPROCESS_H
#define CXX_HIDEPROCESS_H

#include <ntifs.h>

typedef enum WIN_VERSION {
	WINDOWS_XP,
	WINDOWS_7_7600,
	WINDOWS_7_7601,
	WINDOWS_8_9200,
	WINDOWS_8_9600,
	WINDOWS_10_10240,
	WINDOWS_10_10586,
	WINDOWS_10_14393,
	WINDOWS_10_15063,
	WINDOWS_10_16299,
	WINDOWS_10_17134,
	WINDOWS_UNKNOW
} WIN_VERSION;

VOID UnloadDriver(PDRIVER_OBJECT  DriverObject);
VOID HideProcess(char* ProcessName);

WIN_VERSION GetWindowsVersion();
PVOID 
GetFunctionAddressByName(WCHAR *wzFunction);
typedef 
NTSTATUS 
(*pfnRtlGetVersion)(OUT PRTL_OSVERSIONINFOW lpVersionInformation);
#endif
