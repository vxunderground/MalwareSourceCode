#include "Reload.h"





BOOLEAN GetSystemKernelModuleInfo(WCHAR **SystemKernelModulePath,PDWORD SystemKernelModuleBase,PDWORD SystemKernelModuleSize);

BOOLEAN IoGetFileSystemVpbInfo(IN PFILE_OBJECT FileObject,PDEVICE_OBJECT *DeviceObject,PDEVICE_OBJECT *RealDevice);


BOOLEAN GetDeviceObjectFromFileFullName(WCHAR *FileFullName,PDEVICE_OBJECT *RealDevice, PDEVICE_OBJECT *DeviceObject);


BOOLEAN GetWindowsRootName(WCHAR *WindowsRootName);

NTSTATUS  KernelOpenFile(wchar_t *FileFullName, 
    PHANDLE FileHandle, 
    ACCESS_MASK DesiredAccess, 
    ULONG FileAttributes, 
    ULONG ShareAccess, 
    ULONG CreateDisposition, 
    ULONG CreateOptions);




NTSTATUS  KernelGetFileSize(HANDLE hFile, PLARGE_INTEGER FileSize);



NTSTATUS KernelReadFile(HANDLE hFile, PLARGE_INTEGER ByteOffset, ULONG Length, PVOID FileBuffer, PIO_STATUS_BLOCK IoStatusBlock);


BOOLEAN ImageFile(BYTE *FileBuffer,BYTE **ImageModuleBase);
ULONG AlignSize(ULONG nSize, ULONG nAlign);


PVOID GetKernelModuleBase(PDRIVER_OBJECT DriverObject,char *KernelModuleName);

BOOLEAN InsertOriginalFirstThunk(DWORD ImageBase,DWORD ExistImageBase,PIMAGE_THUNK_DATA FirstThunk);


PVOID
    MiFindExportedRoutine (
    IN PVOID DllBase,
    BOOLEAN ByName,
    IN char *RoutineName,
    DWORD Ordinal
    );



BOOLEAN FixImportTable(BYTE *ImageBase,DWORD ExistImageBase,PDRIVER_OBJECT DriverObject);


BOOLEAN PeLoad(
    WCHAR *FileFullPath,
    BYTE **ImageModeleBase,
    PDRIVER_OBJECT DeviceObject,
    DWORD ExistImageBase
    );


