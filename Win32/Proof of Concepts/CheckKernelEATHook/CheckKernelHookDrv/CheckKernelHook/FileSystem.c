#include "FileSystem.h"




/*创建文件对象，相当于自己实现了IoCreateFile  FileObject中的IrpList循环指向自身*/
NTSTATUS
    IrpCreateFile(
    IN PUNICODE_STRING FilePath,
    IN ACCESS_MASK DesiredAccess,
    IN ULONG FileAttributes,
    IN ULONG ShareAccess,
    IN ULONG CreateDisposition,
    IN ULONG CreateOptions,
    IN PDEVICE_OBJECT DeviceObject,
    IN PDEVICE_OBJECT RealDevice,
    OUT PFILE_OBJECT *FileObject
    )
{
    NTSTATUS ntStatus;

    HANDLE hFile;
    PFILE_OBJECT  _FileObject;
    UNICODE_STRING UniDeviceNameString;
    OBJECT_ATTRIBUTES ObjectAttributes;
    IO_STATUS_BLOCK IoStatusBlock;
    WCHAR *FileNameBuffer=NULL;
    WORD FileObjectSize;


    PIRP Irp;
    KEVENT kEvent;
    PIO_STACK_LOCATION IrpSp;
    ACCESS_STATE AccessState;
    AUX_ACCESS_DATA AuxData;
    IO_SECURITY_CONTEXT SecurityContext;

    PLIST_ENTRY IrpList;

    InitializeObjectAttributes(&ObjectAttributes, NULL, OBJ_CASE_INSENSITIVE, 0, NULL);

    //in   win7 x86
    FileObjectSize=0x80;


    //创建文件对象
    ntStatus = ObCreateObject(KernelMode,
        *IoFileObjectType,
        &ObjectAttributes,
        KernelMode,
        NULL,
        FileObjectSize,
        0,
        0,
        &_FileObject);

    if(!NT_SUCCESS(ntStatus))
    {
        return ntStatus;
    }

    Irp = IoAllocateIrp(DeviceObject->StackSize, FALSE); //在Irp堆栈上申请内存空间  大小为之前查询的DeviceObject->Size
    if(Irp == NULL)
    {
        ObDereferenceObject(_FileObject);
        return STATUS_INSUFFICIENT_RESOURCES;
    }

    KeInitializeEvent(&kEvent, SynchronizationEvent, FALSE);

    RtlZeroMemory(_FileObject, FileObjectSize);
    _FileObject->Type = IO_TYPE_FILE; //文件对象类型
    _FileObject->Size = FileObjectSize; //文件对象大小
    _FileObject->DeviceObject = RealDevice;  //查询到的卷设备
    _FileObject->Flags = FO_SYNCHRONOUS_IO;
    FileNameBuffer=ExAllocatePool(NonPagedPool,FilePath->MaximumLength);
    if (FileNameBuffer==NULL)
    {
        ObDereferenceObject(_FileObject);
        return STATUS_INSUFFICIENT_RESOURCES;
    }
    RtlCopyMemory(FileNameBuffer,FilePath->Buffer,FilePath->Length);//文件对象中的文件路径  
    _FileObject->FileName.Buffer=FileNameBuffer; //
    _FileObject->FileName.Length=FilePath->Length;
    _FileObject->FileName.MaximumLength=FilePath->MaximumLength;


    IrpList=(PLIST_ENTRY)((DWORD)FileObject+0x74); //IrpList 循环指向自身
    IrpList->Flink=IrpList;
    IrpList->Blink=IrpList;

    KeInitializeEvent(&_FileObject->Lock, SynchronizationEvent, FALSE);
    KeInitializeEvent(&_FileObject->Event, NotificationEvent, FALSE);

    RtlZeroMemory(&AuxData, sizeof(AUX_ACCESS_DATA));
    ntStatus = SeCreateAccessState( &AccessState,      //访问权限
        &AuxData,
        DesiredAccess,
        IoGetFileObjectGenericMapping());

    if (!NT_SUCCESS(ntStatus))
    {
        IoFreeIrp(Irp);
        ObDereferenceObject(_FileObject);
        ExFreePool(FileNameBuffer);
        return ntStatus;
    }

    SecurityContext.SecurityQos = NULL;
    SecurityContext.AccessState = &AccessState;
    SecurityContext.DesiredAccess = DesiredAccess;
    SecurityContext.FullCreateOptions = 0;

    Irp->MdlAddress = NULL;
    Irp->AssociatedIrp.SystemBuffer = NULL;
    Irp->Flags = IRP_CREATE_OPERATION|IRP_SYNCHRONOUS_API;
    Irp->RequestorMode = KernelMode;
    Irp->UserIosb = &IoStatusBlock;
    Irp->UserEvent = &kEvent;
    Irp->PendingReturned = FALSE;
    Irp->Cancel = FALSE;
    Irp->CancelRoutine = NULL;
    Irp->Tail.Overlay.Thread = PsGetCurrentThread();
    Irp->Tail.Overlay.AuxiliaryBuffer = NULL;
    Irp->Tail.Overlay.OriginalFileObject = _FileObject;

    IrpSp = IoGetNextIrpStackLocation(Irp);
    IrpSp->MajorFunction = IRP_MJ_CREATE;
    IrpSp->DeviceObject = DeviceObject;
    IrpSp->FileObject = _FileObject;
    IrpSp->Parameters.Create.SecurityContext = &SecurityContext;
    IrpSp->Parameters.Create.Options = (CreateDisposition << 24) | CreateOptions;
    IrpSp->Parameters.Create.FileAttributes = (USHORT)FileAttributes;
    IrpSp->Parameters.Create.ShareAccess = (USHORT)ShareAccess;
    IrpSp->Parameters.Create.EaLength = 0;

    IoSetCompletionRoutine(Irp, IoCompletionRoutine, 0, TRUE, TRUE, TRUE);
    ntStatus = IoCallDriver(DeviceObject, Irp);
    if(ntStatus == STATUS_PENDING)
        KeWaitForSingleObject(&kEvent, Executive, KernelMode, TRUE, 0);

    ntStatus = IoStatusBlock.Status;

    if(!NT_SUCCESS(ntStatus))
    {
        _FileObject->DeviceObject = NULL;
        ObDereferenceObject(_FileObject);

    }
    else
    {//增加引用计数
        InterlockedIncrement(&_FileObject->DeviceObject->ReferenceCount);
        if (_FileObject->Vpb)
            InterlockedIncrement(&_FileObject->Vpb->ReferenceCount);
        *FileObject = _FileObject;
    }


    return ntStatus;
}




NTSTATUS
    IoCompletionRoutine(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp,
    IN PVOID Context)
{
    *Irp->UserIosb = Irp->IoStatus;
    if (Irp->UserEvent)
        KeSetEvent(Irp->UserEvent, IO_NO_INCREMENT, 0);
    if (Irp->MdlAddress)
    {
        IoFreeMdl(Irp->MdlAddress);
        Irp->MdlAddress = NULL;
    }
    IoFreeIrp(Irp);
    return STATUS_MORE_PROCESSING_REQUIRED;
}




//查询irp堆栈信息，传入FileObject
NTSTATUS
    IrpQueryInformationFile(
    IN PFILE_OBJECT FileObject,
    IN PDEVICE_OBJECT DeviceObject,
    OUT PVOID FileInformation,
    IN ULONG Length,
    IN FILE_INFORMATION_CLASS FileInformationClass)
{
    NTSTATUS ntStatus;
    PIRP Irp;
    KEVENT kEvent;
    PIO_STACK_LOCATION IrpSp;
    IO_STATUS_BLOCK IoStatusBlock;

    //     if (FileObject->Vpb == 0 || FileObject->Vpb->DeviceObject == NULL)
    //         return STATUS_UNSUCCESSFUL;

    Irp = IoAllocateIrp(DeviceObject->StackSize, FALSE);
    if(Irp == NULL) 
        return STATUS_INSUFFICIENT_RESOURCES;

    KeInitializeEvent(&kEvent, SynchronizationEvent, FALSE);

    RtlZeroMemory(FileInformation, Length);
    Irp->AssociatedIrp.SystemBuffer = FileInformation;
    Irp->UserEvent = &kEvent;
    Irp->UserIosb = &IoStatusBlock;
    Irp->RequestorMode = KernelMode;
    Irp->Tail.Overlay.Thread = PsGetCurrentThread();
    Irp->Tail.Overlay.OriginalFileObject = FileObject;

    IrpSp = IoGetNextIrpStackLocation(Irp);
    IrpSp->MajorFunction = IRP_MJ_QUERY_INFORMATION;
    IrpSp->DeviceObject = DeviceObject;
    IrpSp->FileObject = FileObject;
    IrpSp->Parameters.QueryFile.Length = Length;
    IrpSp->Parameters.QueryFile.FileInformationClass = FileInformationClass;

    IoSetCompletionRoutine(Irp, IoCompletionRoutine, 0, TRUE, TRUE, TRUE);
    ntStatus = IoCallDriver(DeviceObject, Irp);

    if (ntStatus == STATUS_PENDING)
        KeWaitForSingleObject(&kEvent, Executive, KernelMode, TRUE, 0);

    return IoStatusBlock.Status;
}



//Irp请求，将文件读入缓冲区中
NTSTATUS
    IrpReadFile(
    IN PFILE_OBJECT FileObject,
    IN PDEVICE_OBJECT DeviceObject,
    OUT PIO_STATUS_BLOCK IoStatusBlock,
    OUT PVOID Buffer,
    IN ULONG Length,
    IN PLARGE_INTEGER ByteOffset OPTIONAL)
{
    NTSTATUS ntStatus;
    PIRP Irp;
    KEVENT kEvent;
    PIO_STACK_LOCATION IrpSp;
    // 


    if(ByteOffset == NULL)
    {
        if(!(FileObject->Flags & FO_SYNCHRONOUS_IO))
            return STATUS_INVALID_PARAMETER;
        ByteOffset = &FileObject->CurrentByteOffset;
    }

    Irp = IoAllocateIrp(DeviceObject->StackSize, FALSE);
    if(Irp == NULL) return STATUS_INSUFFICIENT_RESOURCES;

    RtlZeroMemory(Buffer, Length);
    if(FileObject->DeviceObject->Flags & DO_BUFFERED_IO) //缓冲方式
    {
        Irp->AssociatedIrp.SystemBuffer = Buffer;
    }
    else if(FileObject->DeviceObject->Flags & DO_DIRECT_IO)  //直接方式
    {
        Irp->MdlAddress = IoAllocateMdl(Buffer, Length, 0, 0, 0);
        if (Irp->MdlAddress == NULL)
        {
            IoFreeIrp(Irp);
            return STATUS_INSUFFICIENT_RESOURCES;
        }
        MmBuildMdlForNonPagedPool(Irp->MdlAddress);
    }
    else   //其他方式
    {
        Irp->UserBuffer = Buffer;
    }

    KeInitializeEvent(&kEvent, SynchronizationEvent, FALSE);

    Irp->UserEvent = &kEvent;
    Irp->UserIosb = IoStatusBlock;
    Irp->RequestorMode = KernelMode;
    Irp->Flags = IRP_READ_OPERATION;
    Irp->Tail.Overlay.Thread = PsGetCurrentThread();
    Irp->Tail.Overlay.OriginalFileObject = FileObject;

    IrpSp = IoGetNextIrpStackLocation(Irp);
    IrpSp->MajorFunction = IRP_MJ_READ;
    IrpSp->MinorFunction = IRP_MN_NORMAL;
    IrpSp->DeviceObject = DeviceObject;
    IrpSp->FileObject = FileObject;
    IrpSp->Parameters.Read.Length = Length;
    IrpSp->Parameters.Read.ByteOffset = *ByteOffset;

    IoSetCompletionRoutine(Irp, IoCompletionRoutine, 0, TRUE, TRUE, TRUE);
    ntStatus = IoCallDriver(DeviceObject, Irp);
    if (ntStatus == STATUS_PENDING)
        KeWaitForSingleObject(&kEvent, Executive, KernelMode, TRUE, 0);

    return IoStatusBlock->Status;
}
