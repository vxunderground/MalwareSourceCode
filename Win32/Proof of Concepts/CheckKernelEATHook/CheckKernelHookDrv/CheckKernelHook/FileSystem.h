#include "Reload.h"




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
    );
NTSTATUS
    IoCompletionRoutine(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp,
    IN PVOID Context);


NTSTATUS
    IrpQueryInformationFile(
    IN PFILE_OBJECT FileObject,
    IN PDEVICE_OBJECT DeviceObject,
    OUT PVOID FileInformation,
    IN ULONG Length,
    IN FILE_INFORMATION_CLASS FileInformationClass);


//Irp请求，将文件读入缓冲区中
NTSTATUS
    IrpReadFile(
    IN PFILE_OBJECT FileObject,
    IN PDEVICE_OBJECT DeviceObject,
    OUT PIO_STATUS_BLOCK IoStatusBlock,
    OUT PVOID Buffer,
    IN ULONG Length,
    IN PLARGE_INTEGER ByteOffset OPTIONAL);
