#include "Reload.h"
#include "KernelReload.h"

WCHAR* SystemKernelFilePath = NULL;
ULONG_PTR SystemKernelModuleBase = 0;
ULONG_PTR SystemKernelModuleSize = 0;
ULONG_PTR ImageModuleBase;

PVOID OriginalKiServiceTable;
extern PSERVICE_DESCRIPTOR_TABLE    KeServiceDescriptorTable;
PSERVICE_DESCRIPTOR_TABLE OriginalServiceDescriptorTable;
PSERVICE_DESCRIPTOR_TABLE Safe_ServiceDescriptorTable;


/*
输入FuncName  、 原来Ntos地址  、自己重载 Ntos地址
//第一次都是通过  系统的原来偏移 + NewBase 获得函数地址  
//然后通过自己的RMmGetSystemRoutineAddress获得 偏移+NewBase 获得函数地址
还不能找到则遍历导出表
*/
ULONG ReLoadNtosCALL(WCHAR *lpwzFuncTion,ULONG ulOldNtosBase,ULONG ulReloadNtosBase)
{
    UNICODE_STRING UnicodeFunctionName;
    ULONG ulOldFunctionAddress;
    PUCHAR ulReloadFunctionAddress = NULL;
    int index=0;
    PIMAGE_DOS_HEADER pDosHeader;
    PIMAGE_NT_HEADERS NtDllHeader;

    IMAGE_OPTIONAL_HEADER opthdr;
    DWORD* arrayOfFunctionAddresses;
    DWORD* arrayOfFunctionNames;
    WORD* arrayOfFunctionOrdinals;
    DWORD functionOrdinal;
    DWORD Base, x, functionAddress,position;
    char* functionName;
    IMAGE_EXPORT_DIRECTORY *pExportTable;
    ULONG ulNtDllModuleBase;

    UNICODE_STRING UnicodeFunction;
    UNICODE_STRING UnicodeExportTableFunction;
    ANSI_STRING ExportTableFunction;
    //第一次都是通过  系统的原来偏移 + NewBase 获得函数地址  
    //然后通过自己的RMmGetSystemRoutineAddress获得 偏移+NewBase 获得函数地址
    __try
    {
        if (RRtlInitUnicodeString &&
            RRtlCompareUnicodeString &&
            RMmGetSystemRoutineAddress &&
            RMmIsAddressValid)
        {
            RRtlInitUnicodeString(&UnicodeFunctionName,lpwzFuncTion);
            ulOldFunctionAddress = (DWORD)RMmGetSystemRoutineAddress(&UnicodeFunctionName);
            ulReloadFunctionAddress = (PUCHAR)(ulOldFunctionAddress - ulOldNtosBase + ulReloadNtosBase); //获得重载的FuncAddr
            if (RMmIsAddressValid(ulReloadFunctionAddress)) //如果无效就从 导出表  获取？  应该不会无效
            {
                return (ULONG)ulReloadFunctionAddress;
            }
            //从导出表里获取
            ulNtDllModuleBase = ulReloadNtosBase;
            pDosHeader = (PIMAGE_DOS_HEADER)ulReloadNtosBase;
            if (pDosHeader->e_magic!=IMAGE_DOS_SIGNATURE)
            {
                KdPrint(("failed to find NtHeader\r\n"));
                return 0;
            }
            NtDllHeader=(PIMAGE_NT_HEADERS)(ULONG)((ULONG)pDosHeader+pDosHeader->e_lfanew);
            if (NtDllHeader->Signature!=IMAGE_NT_SIGNATURE)
            {
                KdPrint(("failed to find NtHeader\r\n"));
                return 0;
            }
            opthdr = NtDllHeader->OptionalHeader;
            pExportTable =(IMAGE_EXPORT_DIRECTORY*)((BYTE*)ulNtDllModuleBase + opthdr.DataDirectory[ IMAGE_DIRECTORY_ENTRY_EXPORT]. VirtualAddress); //得到导出表
            arrayOfFunctionAddresses = (DWORD*)( (BYTE*)ulNtDllModuleBase + pExportTable->AddressOfFunctions);  //地址表
            arrayOfFunctionNames = (DWORD*)((BYTE*)ulNtDllModuleBase + pExportTable->AddressOfNames);         //函数名表
            arrayOfFunctionOrdinals = (WORD*)((BYTE*)ulNtDllModuleBase + pExportTable->AddressOfNameOrdinals);

            Base = pExportTable->Base;

            for(x = 0; x < pExportTable->NumberOfFunctions; x++) //在整个导出表里扫描
            {
                functionName = (char*)( (BYTE*)ulNtDllModuleBase + arrayOfFunctionNames[x]);
                functionOrdinal = arrayOfFunctionOrdinals[x] + Base - 1; 
                functionAddress = (DWORD)((BYTE*)ulNtDllModuleBase + arrayOfFunctionAddresses[functionOrdinal]);
                RtlInitAnsiString(&ExportTableFunction,functionName);
                RtlAnsiStringToUnicodeString(&UnicodeExportTableFunction,&ExportTableFunction,TRUE);

                RRtlInitUnicodeString(&UnicodeFunction,lpwzFuncTion);
                if (RRtlCompareUnicodeString(&UnicodeExportTableFunction,&UnicodeFunction,TRUE) == 0)
                {
                    RtlFreeUnicodeString(&UnicodeExportTableFunction);
                    return functionAddress;
                }
                RtlFreeUnicodeString(&UnicodeExportTableFunction);
            }
            return 0;
        }
        RtlInitUnicodeString(&UnicodeFunctionName,lpwzFuncTion);
        ulOldFunctionAddress = (DWORD)MmGetSystemRoutineAddress(&UnicodeFunctionName);
        ulReloadFunctionAddress = (PUCHAR)(ulOldFunctionAddress - ulOldNtosBase + ulReloadNtosBase);

        //KdPrint(("%ws:%08x:%08x",lpwzFuncTion,ulOldFunctionAddress,ulReloadFunctionAddress));

        if (MmIsAddressValid(ulReloadFunctionAddress))
        {
            return (ULONG)ulReloadFunctionAddress;
        }
        //         

    }__except(EXCEPTION_EXECUTE_HANDLER){
        KdPrint(("EXCEPTION_EXECUTE_HANDLER"));
    }
    return 0;
}


/*重载Ntos*/
NTSTATUS ReLoadNtos(PDRIVER_OBJECT   DriverObject,DWORD RetAddress)
{
    NTSTATUS status = STATUS_UNSUCCESSFUL;
    ULONG ulKeAddSystemServiceTable;
    PULONG p;


    if (!GetSystemKernelModuleInfo(
        &SystemKernelFilePath,
        &SystemKernelModuleBase,
        &SystemKernelModuleSize
        ))
    {
        KdPrint(("Get System Kernel Module failed"));
        return status;
    }


    if (InitSafeOperationModule(
        DriverObject,
        SystemKernelFilePath,
        SystemKernelModuleBase
        ))
    {
        KdPrint(("Init Ntos module success\r\n"));


        RRtlInitUnicodeString = NULL;
        RMmGetSystemRoutineAddress = NULL;
        RMmIsAddressValid = NULL;
        RRtlCompareUnicodeString = NULL;
        RPsGetCurrentProcess = NULL;
    
        status = STATUS_UNSUCCESSFUL;
    
        //第一次都是通过  系统的原来偏移 + NewBase 获得函数地址  
        //然后通过自己的RMmGetSystemRoutineAddress获得 偏移+NewBase 获得函数地址
        RRtlInitUnicodeString = (ReloadRtlInitUnicodeString)ReLoadNtosCALL(L"RtlInitUnicodeString",SystemKernelModuleBase,ImageModuleBase);
        RRtlCompareUnicodeString = (ReloadRtlCompareUnicodeString)ReLoadNtosCALL(L"RtlCompareUnicodeString",SystemKernelModuleBase,ImageModuleBase);
        RMmGetSystemRoutineAddress = (ReloadMmGetSystemRoutineAddress)ReLoadNtosCALL(L"MmGetSystemRoutineAddress",SystemKernelModuleBase,ImageModuleBase);
        RMmIsAddressValid = (ReloadMmIsAddressValid)ReLoadNtosCALL(L"MmIsAddressValid",SystemKernelModuleBase,ImageModuleBase);
        RPsGetCurrentProcess = (ReloadPsGetCurrentProcess)ReLoadNtosCALL(L"PsGetCurrentProcess",SystemKernelModuleBase,ImageModuleBase);
        if (!RRtlInitUnicodeString ||
            !RRtlCompareUnicodeString ||
            !RMmGetSystemRoutineAddress ||
            !RMmIsAddressValid ||
            !RPsGetCurrentProcess)
        {
            KdPrint(("Init NtosCALL failed"));
            return status;
        }
    }
    return status;
}




BOOLEAN InitSafeOperationModule(PDRIVER_OBJECT pDriverObject,WCHAR *SystemModulePath,ULONG KernelModuleBase)
{
    UNICODE_STRING FileName;
    HANDLE hSection;
    PDWORD FixdOriginalKiServiceTable;
    PDWORD CsRootkitOriginalKiServiceTable;
    ULONG i = 0;


    //自己peload 一个ntos*，这样就解决了跟其他安全软件的冲突啦~
    if (!PeLoad(SystemModulePath,(BYTE**)&ImageModuleBase,pDriverObject,KernelModuleBase))
    {
        return FALSE;
    }

    OriginalKiServiceTable = ExAllocatePool(NonPagedPool,KeServiceDescriptorTable->TableSize*sizeof(DWORD));
    if (!OriginalKiServiceTable)
    {
        return FALSE;
    }
    //获得SSDT基址，通过重定位表比较得到
    if(!GetOriginalKiServiceTable((BYTE*)ImageModuleBase,KernelModuleBase,(DWORD*)&OriginalKiServiceTable))
    {
        ExFreePool(OriginalKiServiceTable);

        return FALSE;
    }

    //修复SSDT函数地址  都是自己Reload的函数地址  干净的
    FixOriginalKiServiceTable((PDWORD)OriginalKiServiceTable,(DWORD)ImageModuleBase,KernelModuleBase);

    OriginalServiceDescriptorTable = (PSERVICE_DESCRIPTOR_TABLE)ExAllocatePool(NonPagedPool,sizeof(SERVICE_DESCRIPTOR_TABLE)*4);
    if (OriginalServiceDescriptorTable == NULL)
    {
        ExFreePool(OriginalKiServiceTable);
        return FALSE;
    }
    RtlZeroMemory(OriginalServiceDescriptorTable,sizeof(SERVICE_DESCRIPTOR_TABLE)*4);

    //修复SERVICE_DESCRIPTOR_TABLE 结构  
    OriginalServiceDescriptorTable->ServiceTable = (PDWORD)OriginalKiServiceTable;
    OriginalServiceDescriptorTable->CounterTable = KeServiceDescriptorTable->CounterTable;
    OriginalServiceDescriptorTable->TableSize    = KeServiceDescriptorTable->TableSize;
    OriginalServiceDescriptorTable->ArgumentTable = KeServiceDescriptorTable->ArgumentTable;

    CsRootkitOriginalKiServiceTable = (PDWORD)ExAllocatePool(NonPagedPool,KeServiceDescriptorTable->TableSize*sizeof(DWORD));
    if (CsRootkitOriginalKiServiceTable==NULL)
    {
        ExFreePool(OriginalServiceDescriptorTable);
        ExFreePool(OriginalKiServiceTable);
        return FALSE;
    }
    RtlZeroMemory(CsRootkitOriginalKiServiceTable,KeServiceDescriptorTable->TableSize*sizeof(DWORD));

    Safe_ServiceDescriptorTable = (PSERVICE_DESCRIPTOR_TABLE)ExAllocatePool(NonPagedPool,sizeof(SERVICE_DESCRIPTOR_TABLE)*4);
    if (Safe_ServiceDescriptorTable == NULL)
    {
        ExFreePool(OriginalServiceDescriptorTable);
        ExFreePool(CsRootkitOriginalKiServiceTable);
        ExFreePool(OriginalKiServiceTable);
        return FALSE;
    }
    //这是一个干净的原始表，每个表里所对应的SSDT函数的地址都是原始函数
    RtlZeroMemory(Safe_ServiceDescriptorTable,sizeof(SERVICE_DESCRIPTOR_TABLE)*4);

    //填充原始函数地址
    for (i = 0; i < KeServiceDescriptorTable->TableSize; i++)
    {
        CsRootkitOriginalKiServiceTable[i] = OriginalServiceDescriptorTable->ServiceTable[i];
    }
    Safe_ServiceDescriptorTable->ServiceTable = (PDWORD)CsRootkitOriginalKiServiceTable;
    Safe_ServiceDescriptorTable->CounterTable = KeServiceDescriptorTable->CounterTable;
    Safe_ServiceDescriptorTable->TableSize = KeServiceDescriptorTable->TableSize;
    Safe_ServiceDescriptorTable->ArgumentTable = KeServiceDescriptorTable->ArgumentTable;

    //释放就会bsod
    //ExFreePool(OriginalKiServiceTable);
    
    return TRUE;
}


VOID FixOriginalKiServiceTable(PDWORD OriginalKiServiceTable,DWORD ModuleBase,DWORD ExistImageBase)
{
    DWORD FuctionCount;
    DWORD Index;
    FuctionCount=KeServiceDescriptorTable->TableSize; //函数个数
    
    KdPrint(("ssdt funcion count:%X---KiServiceTable:%X\n",FuctionCount,KeServiceDescriptorTable->ServiceTable));    
    for (Index=0;Index<FuctionCount;Index++)
    {
        OriginalKiServiceTable[Index]=OriginalKiServiceTable[Index]-ExistImageBase+ModuleBase; //修复SSDT函数地址
    }
}

//通过KeServiceDescriptorTable的RVA与重定位表项解析的地址RVA比较，一致则取出其中的SSDT表地址
BOOLEAN GetOriginalKiServiceTable(BYTE *NewImageBase,DWORD ExistImageBase,DWORD *NewKiServiceTable)
{
    PIMAGE_DOS_HEADER ImageDosHeader;
    PIMAGE_NT_HEADERS ImageNtHeaders;
    DWORD KeServiceDescriptorTableRva;
    PIMAGE_BASE_RELOCATION ImageBaseReloc=NULL;
    DWORD RelocSize;
    int ItemCount,Index;
    int Type;
    PDWORD RelocAddress;
    DWORD RvaData;
    DWORD count=0;
    WORD *TypeOffset;


    ImageDosHeader=(PIMAGE_DOS_HEADER)NewImageBase;
    if (ImageDosHeader->e_magic!=IMAGE_DOS_SIGNATURE)
    {
        return FALSE;
    }
    ImageNtHeaders=(PIMAGE_NT_HEADERS)(NewImageBase+ImageDosHeader->e_lfanew);
    if (ImageNtHeaders->Signature!=IMAGE_NT_SIGNATURE)
    {
        return FALSE;
    }
    KeServiceDescriptorTableRva=(DWORD)MiFindExportedRoutine(NewImageBase,TRUE,"KeServiceDescriptorTable",0);
    if (KeServiceDescriptorTableRva==0)
    {
        return FALSE;
    }

    KeServiceDescriptorTableRva=KeServiceDescriptorTableRva-(DWORD)NewImageBase;
    ImageBaseReloc=RtlImageDirectoryEntryToData(NewImageBase,TRUE,IMAGE_DIRECTORY_ENTRY_BASERELOC,&RelocSize);
    if (ImageBaseReloc==NULL)
    {
        return FALSE;
    }

    while (ImageBaseReloc->SizeOfBlock)
    {  
        count++;
        ItemCount=(ImageBaseReloc->SizeOfBlock - sizeof(IMAGE_BASE_RELOCATION))/2;
        TypeOffset=(WORD*)((DWORD)ImageBaseReloc+sizeof(IMAGE_BASE_RELOCATION));
        for (Index=0;Index<ItemCount;Index++)
        {
            Type=TypeOffset[Index]>>12;  //高4位是类型   低12位位页内偏移 4k  
            if (Type==3)
            {
                //Base + Virtual 定位到页   + 低12位  = RelocAddress 需要修复的地址
                RelocAddress=(PDWORD)((DWORD)(TypeOffset[Index]&0x0fff)+ImageBaseReloc->VirtualAddress+(DWORD)NewImageBase);
                RvaData=*RelocAddress-ExistImageBase;
                
                if (RvaData==KeServiceDescriptorTableRva)  //重定位表中的rva 是 KeServiceDescriptorTable 表项的
                {
                    if(*(USHORT*)((DWORD)RelocAddress-2)==0x05c7)
                    {
                        /*
                    1: kd> dd 0x89651c12   RelocAddress - 2
                    89651c12       79c005c7 bd9c83f8 

                    1: kd> dd KeServiceDescriptorTable           
                    83f879c0       83e9bd9c 00000000 00000191 83e9c3e4
                    83f879d0       00000000 00000000 00000000 00000000
                
                    1: kd> dd 0x89651c14        RelocAddress
                    89651c14       83f879c0 83e9bd9c 79c41589 c8a383f8
                    89651c24       c783f879 f879cc05 e9c3e483 d8158983
                        */
                        //RelocAddress 里面存放着 KeServiceDesriptorTable地址  
                        //RelocAddress + 4 存放着 KeServiceDesriptorTable第一成员也就是SSDT基址
                        *NewKiServiceTable=*(DWORD*)((DWORD)RelocAddress+4)-ExistImageBase+(DWORD)NewImageBase;
                        return TRUE;
                    }
                }

            }

        }
        ImageBaseReloc=(PIMAGE_BASE_RELOCATION)((DWORD)ImageBaseReloc+ImageBaseReloc->SizeOfBlock);
    }

    return FALSE;
}
