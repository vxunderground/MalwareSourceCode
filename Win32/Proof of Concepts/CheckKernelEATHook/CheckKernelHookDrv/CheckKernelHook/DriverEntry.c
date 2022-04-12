

#include "DriverEntry.h"
#include "KernelHookCheck.h"
#include "Reload.h"


NTSTATUS DriverEntry(IN PDRIVER_OBJECT DriverObject, IN PUNICODE_STRING RegisterPath)
{
    ULONG ImageBase = 0;
    NTSTATUS        Status = STATUS_SUCCESS;
    UNICODE_STRING   uniDeviceName;
    UNICODE_STRING   uniLinkName;
    PDEVICE_OBJECT   DeviceObject = NULL;
    ULONG_PTR        i  = 0;

    RtlInitUnicodeString(&uniDeviceName,DEVICE_NAME);
    RtlInitUnicodeString(&uniLinkName,LINK_NAME);

    for (i=0;i<IRP_MJ_MAXIMUM_FUNCTION;i++)
    {
        DriverObject->MajorFunction[i] = DefaultPassThrough;
    }

    DriverObject->DriverUnload = UnloadDriver;
    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = ControlPassThrough;

    //创建设备对象
    Status = IoCreateDevice(DriverObject,0,&uniDeviceName,FILE_DEVICE_UNKNOWN,0,FALSE,&DeviceObject);
    if (!NT_SUCCESS(Status))
    {
        return Status;
    }

    Status = IoCreateSymbolicLink(&uniLinkName,&uniDeviceName);
    if (!NT_SUCCESS(Status))
    {
        IoDeleteDevice(DeviceObject);
        return Status;
    }

    //PINLINEHOOKINFO InlineHookInfo ;
    //InlineHookInfo = ExAllocatePool(1,sizeof(INLINEHOOKINFO)+0x1000*sizeof(INLINEHOOKINFO_INFORMATION));
    //memset(InlineHookInfo,0,sizeof(INLINEHOOKINFO)+0x1000*sizeof(INLINEHOOKINFO_INFORMATION));
    //DriverObject->DriverUnload = UnloadDriver;

    ReLoadNtos(DriverObject,ImageBase);
    //KernelHookCheck(InlineHookInfo);
    return STATUS_SUCCESS;
}


NTSTATUS
    ControlPassThrough(PDEVICE_OBJECT  DeviceObject,PIRP Irp)
{
    NTSTATUS  Status = STATUS_SUCCESS;
    PIO_STACK_LOCATION   IrpSp;
    PVOID     InputBuffer  = NULL;
    PVOID     OutputBuffer = NULL;
    ULONG_PTR InputSize  = 0;
    ULONG_PTR OutputSize = 0;
    ULONG_PTR IoControlCode = 0;
    IrpSp = IoGetCurrentIrpStackLocation(Irp);
    InputBuffer = IrpSp->Parameters.DeviceIoControl.Type3InputBuffer;
    OutputBuffer = Irp->UserBuffer;
    InputSize = IrpSp->Parameters.DeviceIoControl.InputBufferLength;
    OutputSize  = IrpSp->Parameters.DeviceIoControl.OutputBufferLength;
    IoControlCode = IrpSp->Parameters.DeviceIoControl.IoControlCode;

    switch(IoControlCode)
    {
    case CTL_CHECKKERNELMODULE:
        {
            if (!MmIsAddressValid(OutputBuffer))
            {
                Irp->IoStatus.Status = STATUS_UNSUCCESSFUL;
                Irp->IoStatus.Information = 0;
                break;
            }
            __try
            {
                ProbeForWrite(OutputBuffer,OutputSize,sizeof(PVOID));
                Status = KernelHookCheck((PINLINEHOOKINFO)OutputBuffer);
                Irp->IoStatus.Information = 0;    
                Status = Irp->IoStatus.Status = Status;
            }
            __except(EXCEPTION_EXECUTE_HANDLER)
            {
                Irp->IoStatus.Information = 0;
                Status = Irp->IoStatus.Status = STATUS_UNSUCCESSFUL;
            }
            Irp->IoStatus.Information = 0;
            Status = Irp->IoStatus.Status = Status;
            break;
        }
    default:
        {
            Irp->IoStatus.Status = STATUS_UNSUCCESSFUL;
            Irp->IoStatus.Information = 0;
            break;
        }
    }
    IoCompleteRequest(Irp,IO_NO_INCREMENT);
    return Status;
}


NTSTATUS
    DefaultPassThrough(PDEVICE_OBJECT  DeviceObject,PIRP Irp)
{
    Irp->IoStatus.Information = 0;
    Irp->IoStatus.Status = STATUS_SUCCESS;
    IoCompleteRequest(Irp,IO_NO_INCREMENT);
    return STATUS_SUCCESS;
}

VOID UnloadDriver(PDRIVER_OBJECT  DriverObject)
{
    UNICODE_STRING  uniLinkName;
    PDEVICE_OBJECT  CurrentDeviceObject;
    PDEVICE_OBJECT  NextDeviceObject;
    RtlInitUnicodeString(&uniLinkName,LINK_NAME);
    IoDeleteSymbolicLink(&uniLinkName);
    if (DriverObject->DeviceObject!=NULL)
    {
        CurrentDeviceObject = DriverObject->DeviceObject;
        while(CurrentDeviceObject!=NULL)
        {
            NextDeviceObject  = CurrentDeviceObject->NextDevice;
            IoDeleteDevice(CurrentDeviceObject);
            CurrentDeviceObject = NextDeviceObject;
        }
    }
    DbgPrint("UnloadDriver\r\n");
}

