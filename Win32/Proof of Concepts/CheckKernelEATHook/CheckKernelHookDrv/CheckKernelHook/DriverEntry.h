#include <ntifs.h>
#include <devioctl.h>
#pragma  once


#define DEVICE_NAME   L"\\Device\\CheckKernelHookDeviceName"
#define LINK_NAME       L"\\DosDevices\\CheckKernelHookLinkName"
#define CTL_CHECKKERNELMODULE \
    CTL_CODE(FILE_DEVICE_UNKNOWN,0x830,METHOD_NEITHER,FILE_ANY_ACCESS)


NTSTATUS
    DriverEntry(IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegisterPath);
VOID UnloadDriver(PDRIVER_OBJECT  DriverObject);
NTSTATUS
    DefaultPassThrough(PDEVICE_OBJECT  DeviceObject,PIRP Irp);
NTSTATUS
    ControlPassThrough(PDEVICE_OBJECT  DeviceObject,PIRP Irp);

typedef struct _INLINEHOOKINFO_INFORMATION {          //INLINEHOOKINFO_INFORMATION
    ULONG ulHookType;
    ULONG ulMemoryFunctionBase;    //原始地址
    ULONG ulMemoryHookBase;        //HOOK 地址
    CHAR lpszFunction[256];
    CHAR lpszHookModuleImage[256];
    ULONG ulHookModuleBase;
    ULONG ulHookModuleSize;

} INLINEHOOKINFO_INFORMATION, *PINLINEHOOKINFO_INFORMATION;

typedef struct _INLINEHOOKINFO {          //InlineHook
    ULONG ulCount;
    INLINEHOOKINFO_INFORMATION InlineHook[1];
} INLINEHOOKINFO, *PINLINEHOOKINFO;

