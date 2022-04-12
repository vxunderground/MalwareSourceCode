#include "stdafx.h"
//--------------------------------------------------------------------------------------
#ifndef _NTIFS_INCLUDED_

typedef struct _ACE_HEADER 
{
    UCHAR  AceType;
    UCHAR  AceFlags;
    USHORT AceSize;

} ACE_HEADER;
typedef ACE_HEADER *PACE_HEADER;

typedef struct _ACCESS_ALLOWED_ACE 
{
    ACE_HEADER Header;
    ACCESS_MASK Mask;
    ULONG SidStart;

} ACCESS_ALLOWED_ACE;

typedef struct _SID 
{
    UCHAR  Revision;
    UCHAR  SubAuthorityCount;
    SID_IDENTIFIER_AUTHORITY IdentifierAuthority;

    ULONG SubAuthority[ANYSIZE_ARRAY];

} SID, *PISID;

#endif

BOOLEAN SetObjectSecurityWorld(HANDLE hObject, ACCESS_MASK AccessMask)
{
    BOOLEAN bRet = FALSE;
	PSECURITY_DESCRIPTOR Descr = NULL;

    ULONG SdLength = 0;
    // query security descriptor length
    NTSTATUS ns = ZwQuerySecurityObject(hObject, DACL_SECURITY_INFORMATION, NULL, 0, &SdLength); 
    if (ns != STATUS_BUFFER_TOO_SMALL) 
    { 
        DbgMsg(__FILE__, __LINE__, "ZwQuerySecurityObject() fails; status: 0x%.8x\n", ns);
        return FALSE; 
    } 

    // allocate memory for security descriptor
    Descr = (PSECURITY_DESCRIPTOR)M_ALLOC(SdLength);
    if (Descr)
    {
        // query security descriptor
        ns = ZwQuerySecurityObject(hObject, DACL_SECURITY_INFORMATION, Descr, SdLength, &SdLength); 
        if (NT_SUCCESS(ns)) 
        {
            BOOLEAN DaclPresent = FALSE, DaclDefaulted = FALSE;
            PACL OldDacl = NULL;

            // get descriptor's DACL
            ns = RtlGetDaclSecurityDescriptor(
                Descr, 
                &DaclPresent, 
                &OldDacl, 
                &DaclDefaulted
            ); 
            if (NT_SUCCESS(ns)) 
            { 
                #define SID_REVISION (1)    // Current revision level

                #define SECURITY_WORLD_SID_AUTHORITY {0,0,0,0,0,1}
                #define SECURITY_WORLD_RID (0x00000000L)

                SID Sid;
                SID_IDENTIFIER_AUTHORITY SidAuth = SECURITY_WORLD_SID_AUTHORITY;  
    
                RtlZeroMemory(&Sid, sizeof(Sid));
                
                // initialize SID
                Sid.Revision = SID_REVISION;
                Sid.SubAuthorityCount = 1;
                Sid.IdentifierAuthority = SidAuth;
                Sid.SubAuthority[0] = SECURITY_WORLD_RID;
                
                if (RtlValidSid(&Sid)) 
                {
					PACL NewDacl  = NULL;
                    // calculate new DACL size
                    ULONG NewDaclSize = sizeof(ACCESS_ALLOWED_ACE) + RtlLengthSid(&Sid);  
                    if (DaclPresent && OldDacl)
                    {
                        NewDaclSize += OldDacl->AclSize;
                    }

                    // allocate new DACL
                    NewDacl = (PACL)M_ALLOC(NewDaclSize);
                    if (NewDacl)
                    {
                        // copy current DACL
                        RtlCopyMemory(NewDacl, OldDacl, OldDacl->AclSize); 
                        NewDacl->AclSize = (USHORT)NewDaclSize; 

                        ns = RtlAddAccessAllowedAce(NewDacl, ACL_REVISION, AccessMask, &Sid); 
                        if (NT_SUCCESS(ns))
                        {
                            ns = RtlSelfRelativeToAbsoluteSD2(Descr, &SdLength); 
                            if (NT_SUCCESS(ns)) 
                            { 
                                // update descriptor's DACL
                                ns = RtlSetDaclSecurityDescriptor(Descr, TRUE, NewDacl, DaclDefaulted); 
                                if (NT_SUCCESS(ns)) 
                                { 
                                    // set new security descriptor
                                    ns = ZwSetSecurityObject(hObject, DACL_SECURITY_INFORMATION, Descr); 
                                    if (NT_SUCCESS(ns)) 
                                    { 
                                        bRet = TRUE;
                                    } 
                                    else
                                    {
                                        DbgMsg(__FILE__, __LINE__, "ZwSetSecurityObject() fails; status: 0x%.8x\n", ns);
                                    }
                                } 
                                else
                                {
                                    DbgMsg(__FILE__, __LINE__, "RtlSetDaclSecurityDescriptor() fails; status: 0x%.8x\n", ns);
                                }   
                            }
                            else
                            {
                                DbgMsg(__FILE__, __LINE__, "RtlSelfRelativeToAbsoluteSD2() fails; status: 0x%.8x\n", ns);
                            }                            
                        }
                        else
                        {
                            DbgMsg(__FILE__, __LINE__, "RtlAddAccessAllowedAce() fails; status: 0x%.8x\n", ns);
                        }

                        M_FREE(NewDacl);
                    }
                    else
                    {
                        DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
                    }
                } 
            } 
            else
            {
                DbgMsg(__FILE__, __LINE__, "RtlGetDaclSecurityDescriptor() fails; status: 0x%.8x\n", ns);
            }
        }
        else
        { 
            DbgMsg(__FILE__, __LINE__, "ZwQuerySecurityObject() fails; status: 0x%.8x\n", ns);
        } 

        M_FREE(Descr);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
PVOID KernelGetModuleBase(char *ModuleName)
{
    PVOID pModuleBase = NULL;

	wchar_t *wcHalNames[] = 
	{
		L"hal.dll",      // Non-ACPI PIC HAL 
		L"halacpi.dll",  // ACPI PIC HAL
		L"halapic.dll",  // Non-ACPI APIC UP HAL
		L"halmps.dll",   // Non-ACPI APIC MP HAL
		L"halaacpi.dll", // ACPI APIC UP HAL
		L"halmacpi.dll"  // ACPI APIC MP HAL
	};


#define HAL_NAMES_NUM 6


#define NT_NAMES_NUM 4
	wchar_t *wcNtNames[] = 
	{
		L"ntoskrnl.exe", // UP
		L"ntkrnlpa.exe", // UP PAE
		L"ntkrnlmp.exe", // MP
		L"ntkrpamp.exe"  // MP PAE
	};



    UNICODE_STRING usCommonHalName, usCommonNtName;

	PRTL_PROCESS_MODULES Info = NULL;

    RtlInitUnicodeString(&usCommonHalName, L"hal.dll");
    RtlInitUnicodeString(&usCommonNtName, L"ntoskrnl.exe");


    Info = (PRTL_PROCESS_MODULES)GetSysInf(SystemModuleInformation);
    if (Info)
    {
		NTSTATUS ns = STATUS_UNSUCCESSFUL;
        ANSI_STRING asModuleName;
        UNICODE_STRING usModuleName;

        RtlInitAnsiString(&asModuleName, ModuleName);

        ns = RtlAnsiStringToUnicodeString(&usModuleName, &asModuleName, TRUE);
        if (NT_SUCCESS(ns))
        {
			ULONG i = 0;
            for (i = 0; i < Info->NumberOfModules; i++)
            {
				NTSTATUS ns = STATUS_UNSUCCESSFUL;
                ANSI_STRING asEnumModuleName;
                UNICODE_STRING usEnumModuleName;

                RtlInitAnsiString(
                    &asEnumModuleName, 
                    (char *)Info->Modules[i].FullPathName + Info->Modules[i].OffsetToFileName
                );

                ns = RtlAnsiStringToUnicodeString(&usEnumModuleName, &asEnumModuleName, TRUE);
                if (NT_SUCCESS(ns))
                {                    
                    if (RtlEqualUnicodeString(&usModuleName, &usCommonHalName, TRUE))
                    {
						int i_m = 0;
                        // hal.dll passed as module name
                        for (i_m = 0; i_m < HAL_NAMES_NUM; i_m++)
                        {
                            UNICODE_STRING usHalName;
                            RtlInitUnicodeString(&usHalName, wcHalNames[i_m]);

                            // compare module name from list with known HAL module name
                            if (RtlEqualUnicodeString(&usEnumModuleName, &usHalName, TRUE))
                            {
                                pModuleBase = (PVOID)Info->Modules[i].ImageBase;
                                break;
                            }
                        }
                    }
                    else if (RtlEqualUnicodeString(&usModuleName, &usCommonNtName, TRUE))
                    {
						int i_m = 0;
                        // ntoskrnl.exe passed as module name
                        for (i_m = 0; i_m < NT_NAMES_NUM; i_m++)
                        {
                            UNICODE_STRING usNtName;
                            RtlInitUnicodeString(&usNtName, wcNtNames[i_m]);

                            // compare module name from list with known kernel module name
                            if (RtlEqualUnicodeString(&usEnumModuleName, &usNtName, TRUE))
                            {
                                pModuleBase = (PVOID)Info->Modules[i].ImageBase;
                                break;
                            }
                        }
                    }
                    else if (RtlEqualUnicodeString(&usModuleName, &usEnumModuleName, TRUE))
                    {
                        pModuleBase = (PVOID)Info->Modules[i].ImageBase;
                    }

                    RtlFreeUnicodeString(&usEnumModuleName);

                    if (pModuleBase)
                    {
                        // module is found
                        break;
                    }
                }                    
            }                     

            RtlFreeUnicodeString(&usModuleName);
        }        

        ExFreePool(Info);
    }

    return pModuleBase;
}
//--------------------------------------------------------------------------------------
ULONG KernelGetExportAddress(PVOID Image, char *lpszFunctionName)
{
    __try
    {
        PIMAGE_EXPORT_DIRECTORY pExport = NULL;

        PIMAGE_NT_HEADERS32 pHeaders32 = (PIMAGE_NT_HEADERS32)
            ((PUCHAR)Image + ((PIMAGE_DOS_HEADER)Image)->e_lfanew);

        if (pHeaders32->FileHeader.Machine == IMAGE_FILE_MACHINE_I386)
        {
            // 32-bit image
            if (pHeaders32->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress)
            {
                pExport = (PIMAGE_EXPORT_DIRECTORY)RVATOVA(
                    Image,
                    pHeaders32->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress
                );
            }                        
        }        
        else if (pHeaders32->FileHeader.Machine == IMAGE_FILE_MACHINE_AMD64)
        {
            // 64-bit image
            PIMAGE_NT_HEADERS64 pHeaders64 = (PIMAGE_NT_HEADERS64)
                ((PUCHAR)Image + ((PIMAGE_DOS_HEADER)Image)->e_lfanew);

            if (pHeaders64->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress)
            {
                pExport = (PIMAGE_EXPORT_DIRECTORY)RVATOVA(
                    Image,
                    pHeaders64->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress
                );
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Unkown machine type\n");
            return 0;
        }

        if (pExport)
        {
            PULONG AddressOfFunctions = (PULONG)RVATOVA(Image, pExport->AddressOfFunctions);
            PSHORT AddrOfOrdinals = (PSHORT)RVATOVA(Image, pExport->AddressOfNameOrdinals);
            PULONG AddressOfNames = (PULONG)RVATOVA(Image, pExport->AddressOfNames);

			ULONG i = 0;
            for (i = 0; i < pExport->NumberOfFunctions; i++)
            {
                if (!strcmp((char *)RVATOVA(Image, AddressOfNames[i]), lpszFunctionName))
                {
                    return AddressOfFunctions[AddrOfOrdinals[i]];
                }
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "WARNING: Export directory not found\n");
        }
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() EXCEPTION\n");
    }

    return 0;
}
//--------------------------------------------------------------------------------------
POBJECT_NAME_INFORMATION GetObjectName(PVOID pObject)
{
    ULONG BuffSize = 0x100;
    POBJECT_NAME_INFORMATION ObjNameInfo;
    NTSTATUS ns = STATUS_UNSUCCESSFUL;

    while (TRUE)
    {
        if ((ObjNameInfo = (POBJECT_NAME_INFORMATION)ExAllocatePool(NonPagedPool, BuffSize)) == NULL)
            return FALSE;

        ns = ObQueryNameString(pObject, ObjNameInfo, BuffSize, &BuffSize);

        if (ns == STATUS_INFO_LENGTH_MISMATCH)
        {               
            ExFreePool(ObjNameInfo);
            BuffSize += 0x100;
        }
        else
            break;
    }

    if (NT_SUCCESS(ns))
    {
        return ObjNameInfo;
    } 

    if (ObjNameInfo)
        ExFreePool(ObjNameInfo);

    return NULL;    
}
//--------------------------------------------------------------------------------------
// get object name by its handle
POBJECT_NAME_INFORMATION GetObjectNameByHandle(HANDLE hObject)
{
    PVOID pObject;
    NTSTATUS ns;
    POBJECT_NAME_INFORMATION ObjNameInfo = NULL;

    ns = ObReferenceObjectByHandle(hObject, 0, 0, KernelMode, &pObject, NULL);
    if (NT_SUCCESS(ns))
    {
        ObjNameInfo = GetObjectName(pObject);
        ObDereferenceObject(pObject);
    } 
    else
        DbgMsg(__FILE__, __LINE__, "ObReferenceObjectByHandle() fails; status: 0x%.8x\n", ns);

    return ObjNameInfo;
}
//--------------------------------------------------------------------------------------
POBJECT_NAME_INFORMATION GetFullNtPath(PUNICODE_STRING Name)
{
    NTSTATUS ns;
    OBJECT_ATTRIBUTES ObjAttr;
    HANDLE hFile;
    IO_STATUS_BLOCK StatusBlock;
    POBJECT_NAME_INFORMATION ObjNameInf;

    InitializeObjectAttributes(&ObjAttr, Name, OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    ns = ZwOpenFile(
        &hFile, 
        FILE_READ_DATA | SYNCHRONIZE, 
        &ObjAttr, 
        &StatusBlock, 
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        FILE_SYNCHRONOUS_IO_NONALERT
    );
    if (!NT_SUCCESS(ns))
    {
        return NULL;
    }

    ObjNameInf = GetObjectNameByHandle(hFile);

    ZwClose(hFile);

    return ObjNameInf;
}
//--------------------------------------------------------------------------------------
BOOLEAN GetNormalizedModulePath(PANSI_STRING asPath, PANSI_STRING asNormalizedPath)
{
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    BOOLEAN bRet = FALSE;
    ANSI_STRING asFullPath;
    UNICODE_STRING usPath;
    char *lpszWnd = "\\WINDOWS\\", *lpszNt = "\\WINNT\\", *lpszLetter = "\\SystemRoot\\";
    char *lpszDrivers = "system32\\drivers\\";

    if (!strncmp(asPath->Buffer, lpszWnd, min(strlen(lpszWnd), asPath->Length)) ||
        !strncmp(asPath->Buffer, lpszNt, min(strlen(lpszNt), asPath->Length)))
    {        
        ULONG Ptr = 0;
		ULONG FullPathLen = 0;
		char *lpszFullPath = NULL;
        if (!strncmp(asPath->Buffer, lpszWnd, strlen(lpszWnd)))
        {
            Ptr = (ULONG)strlen(lpszWnd);
        }
        else if (!strncmp(asPath->Buffer, lpszNt, strlen(lpszNt)))
        {
            Ptr = (ULONG)strlen(lpszNt);
        }

        FullPathLen = asPath->Length - Ptr + strlen(lpszLetter) + 1;
        lpszFullPath = (char *)ExAllocatePool(NonPagedPool, FullPathLen);
        if (lpszFullPath)
        {
            RtlZeroMemory(lpszFullPath, FullPathLen);

            strcpy(lpszFullPath, lpszLetter);
            strncat(lpszFullPath, asPath->Buffer + Ptr, asPath->Length);            

            RtlInitAnsiString(&asFullPath, lpszFullPath);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
            return FALSE;
        }
    }    
    else
    {
        asFullPath.Buffer = asPath->Buffer;
        asFullPath.Length = asPath->Length;
        asFullPath.MaximumLength = asPath->MaximumLength;
    }

    ns = RtlAnsiStringToUnicodeString(&usPath, &asFullPath, TRUE);
    if (NT_SUCCESS(ns))
    {
        POBJECT_NAME_INFORMATION ObjName = GetFullNtPath(&usPath);
        if (ObjName)
        {
            NTSTATUS ns = RtlUnicodeStringToAnsiString(asNormalizedPath, &ObjName->Name, TRUE);
            if (NT_SUCCESS(ns))
            {
                bRet = TRUE;     
            }   
            else
            {
                DbgMsg(__FILE__, __LINE__, "RtlUnicodeStringToAnsiString() fails; status: 0x%.8x\n", ns);
            }

            ExFreePool(ObjName);
        }        

        RtlFreeUnicodeString(&usPath);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "RtlAnsiStringToUnicodeString() fails; status: 0x%.8x\n", ns);
    }

    if (!bRet)
    {
        ULONG Offset = 0;

		ULONG i = 0;
        for (i = 0; i < asFullPath.Length; i++)
        {
            if (asFullPath.Buffer[i] == '\\')
            {
                Offset = i + 1;
            }
        }

        if (Offset == 0)
        {
            ULONG FullPathLen = asFullPath.Length + strlen(lpszLetter) + strlen(lpszDrivers) + 1;
            char *lpszFullPath = (char *)ExAllocatePool(NonPagedPool, FullPathLen);
            if (lpszFullPath)
            {
                RtlZeroMemory(lpszFullPath, FullPathLen);

                strcpy(lpszFullPath, lpszLetter);
                strcat(lpszFullPath, lpszDrivers);
                strncat(lpszFullPath, asFullPath.Buffer, asFullPath.Length);            

                if (asFullPath.Buffer != asPath->Buffer)
                {
                    RtlFreeAnsiString(&asFullPath);
                }

                RtlInitAnsiString(&asFullPath, lpszFullPath);

                ns = RtlAnsiStringToUnicodeString(&usPath, &asFullPath, TRUE);
                if (NT_SUCCESS(ns))
                {
                    POBJECT_NAME_INFORMATION ObjName = GetFullNtPath(&usPath);
                    if (ObjName)
                    {
                        ns = RtlUnicodeStringToAnsiString(asNormalizedPath, &ObjName->Name, TRUE);
                        if (NT_SUCCESS(ns))
                        {
                            bRet = TRUE;     
                        }   
                        else
                        {
                            DbgMsg(__FILE__, __LINE__, "RtlUnicodeStringToAnsiString() fails; status: 0x%.8x\n", ns);
                        }

                        ExFreePool(ObjName);
                    }        

                    RtlFreeUnicodeString(&usPath);
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "RtlAnsiStringToUnicodeString() fails; status: 0x%.8x\n", ns);
                }
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
            }
        }
    }

    if (asFullPath.Buffer != asPath->Buffer)
    {
        RtlFreeAnsiString(&asFullPath);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
PVOID GetSysInf(SYSTEM_INFORMATION_CLASS InfoClass)
{
    NTSTATUS ns;
    ULONG RetSize, Size = 0x100;
    PVOID Info;

    while (TRUE) 
    {    
        if ((Info = ExAllocatePool(NonPagedPool, Size)) == NULL) 
        {
            DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
            return NULL;
        }

        RetSize = 0;
        ns = ZwQuerySystemInformation(InfoClass, Info, Size, &RetSize);
        if (ns == STATUS_INFO_LENGTH_MISMATCH)
        {       
            ExFreePool(Info);
            Info = NULL;

            if (RetSize > 0)
            {
                Size = RetSize + 0x100;
            }            
            else
                break;
        }
        else
            break;    
    }

    if (!NT_SUCCESS(ns))
    {
        DbgMsg(__FILE__, __LINE__, "ZwQuerySystemInformation() fails; status: 0x%.8x\n", ns);

        if (Info)
            ExFreePool(Info);

        return NULL;
    }

    return Info;
}
//--------------------------------------------------------------------------------------
BOOLEAN AllocUnicodeString(PUNICODE_STRING us, USHORT MaximumLength)
{
    ULONG ulMaximumLength = MaximumLength;

    if (MaximumLength > 0)
    {
        if ((us->Buffer = (PWSTR)ExAllocatePool(NonPagedPool, ulMaximumLength)) == NULL)
            return FALSE;

        RtlZeroMemory(us->Buffer, ulMaximumLength);

        us->Length = 0;
        us->MaximumLength = MaximumLength;

        return TRUE;
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN AppendUnicodeToString(PUNICODE_STRING Dest, PCWSTR Source, USHORT Len)
{
    ULONG ulLen = Len;

    if (Dest->MaximumLength >= Dest->Length + Len)
    {
        RtlCopyMemory((PUCHAR)Dest->Buffer + Dest->Length, Source, ulLen);
        Dest->Length += Len;

        return TRUE;
    }

    return FALSE;
} 
//--------------------------------------------------------------------------------------
ULONG GetFileSize(HANDLE hFile, PULONG FileSizeHigh)
{
    FILE_STANDARD_INFORMATION FileStandard;
    IO_STATUS_BLOCK IoStatusBlock;

    NTSTATUS ns = ZwQueryInformationFile(
        hFile,
        &IoStatusBlock,
        &FileStandard,
        sizeof(FILE_STANDARD_INFORMATION),
        FileStandardInformation
    );
    if (!NT_SUCCESS(ns))
    {
        DbgMsg(__FILE__, __LINE__, "ZwQueryInformationFile() fails; status: 0x%.8x\n", ns);
        return -1;        
    }

    if (FileSizeHigh != NULL)
        *FileSizeHigh = FileStandard.EndOfFile.u.HighPart;

    return FileStandard.EndOfFile.u.LowPart;
} 
//--------------------------------------------------------------------------------------
BOOLEAN ReadFromFile(PUNICODE_STRING FileName, PVOID *Data, PULONG DataSize)
{
    BOOLEAN bRet = FALSE;
    NTSTATUS ns;
    OBJECT_ATTRIBUTES ObjAttr;
    HANDLE hFile;
    IO_STATUS_BLOCK StatusBlock;

    *Data = NULL;
    *DataSize = 0;

    InitializeObjectAttributes(&ObjAttr, FileName, 
        OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    ns = ZwOpenFile(
        &hFile, 
        FILE_READ_DATA | SYNCHRONIZE, 
        &ObjAttr, 
        &StatusBlock, 
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
        FILE_SYNCHRONOUS_IO_NONALERT
    );
    if (NT_SUCCESS(ns))
    {
        ULONG FileSize = GetFileSize(hFile, NULL);
        if (FileSize > 0)
        {
            PVOID FileData = ExAllocatePool(NonPagedPool, FileSize);
            if (FileData)
            {
                RtlZeroMemory(FileData, FileSize);

                ns = ZwReadFile(hFile, 0, NULL, NULL, &StatusBlock, FileData, FileSize, 0, NULL);
                if (NT_SUCCESS(ns))
                {
                    bRet = TRUE;
                    *Data = FileData;
                    *DataSize = FileSize;
                } 
                else 
                {
                    DbgMsg(__FILE__, __LINE__, "ZwReadFile() fails; status: 0x%.8x\n", ns);
                    ExFreePool(FileData);
                }
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
            }
        }

        ZwClose(hFile);
    }  

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN DumpToFile(PUNICODE_STRING FileName, PVOID Data, ULONG DataSize)
{
    BOOLEAN bRet = FALSE;
    NTSTATUS ns;
    OBJECT_ATTRIBUTES ObjAttr;
    HANDLE hFile;
    IO_STATUS_BLOCK StatusBlock;

    InitializeObjectAttributes(&ObjAttr, FileName, 
        OBJ_KERNEL_HANDLE | OBJ_CASE_INSENSITIVE , NULL, NULL);

    ns = ZwCreateFile(
        &hFile,
        FILE_ALL_ACCESS | SYNCHRONIZE,
        &ObjAttr,
        &StatusBlock,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        0,
        FILE_OVERWRITE_IF,
        FILE_SYNCHRONOUS_IO_NONALERT,
        NULL,
        0
    );
    if (NT_SUCCESS(ns))
    {
        ns = ZwWriteFile(hFile, NULL, NULL, NULL, &StatusBlock, Data, DataSize, NULL, NULL);
        if (NT_SUCCESS(ns))
        {
            bRet = TRUE;         
        } 
        else 
        {
            DbgMsg(__FILE__, __LINE__, "ZwWriteFile() fails; status: 0x%.8x\n", ns);
        }        

        ZwClose(hFile);
    }   

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN DeleteFile(PUNICODE_STRING usFileName)
{
    BOOLEAN bRet = FALSE;    
    OBJECT_ATTRIBUTES ObjAttr;
    IO_STATUS_BLOCK IoStatusBlock;
    HANDLE FileHandle;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): '%wZ'\n", usFileName);

    InitializeObjectAttributes(&ObjAttr, usFileName, OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE, NULL, NULL);

    // open file
    ns = ZwCreateFile(
        &FileHandle,
        DELETE,
        &ObjAttr,
        &IoStatusBlock,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        FILE_OPEN,
        FILE_NON_DIRECTORY_FILE,
        NULL,
        0
    );    
    if (NT_SUCCESS(ns))
    {
        FILE_BASIC_INFORMATION FileBsicInfo;
        FILE_DISPOSITION_INFORMATION FileDispInfo;

        ns = ZwQueryInformationFile(
            FileHandle, 
            &IoStatusBlock,
            &FileBsicInfo,
            sizeof(FileBsicInfo),
            FileBasicInformation
        );
        if (NT_SUCCESS(ns))
        {
            // chenge file attributes to normal
            FileBsicInfo.FileAttributes = FILE_ATTRIBUTE_NORMAL;
            
            ns = ZwSetInformationFile(
                FileHandle,
                &IoStatusBlock,
                &FileBsicInfo,
                sizeof(FileBsicInfo),
                FileBasicInformation
            );
            if (!NT_SUCCESS(ns))
            {
                DbgMsg(__FILE__, __LINE__, "ZwSetInformationFile() fails; status: 0x%.8x\n", ns);    
            }
        }     
        else
        {
            DbgMsg(__FILE__, __LINE__, "ZwQueryInformationFile() fails; status: 0x%.8x\n", ns);    
        }

        
        FileDispInfo.DeleteFile = TRUE;    

        // ... and delete it
        ns = ZwSetInformationFile(
            FileHandle,
            &IoStatusBlock,
            &FileDispInfo,
            sizeof(FILE_DISPOSITION_INFORMATION),
            FileDispositionInformation
        );
        if (!NT_SUCCESS(ns))
        {
            DbgMsg(__FILE__, __LINE__, "ZwSetInformationFile() fails; status: 0x%.8x\n", ns);    
        }
        else
            bRet = TRUE;

        ZwClose(FileHandle);
    }        
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwCreateFile() fails; status: 0x%.8x\n", ns);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN LoadImageAsDataFile(PUNICODE_STRING usName, PVOID *Image, PULONG MappedImageSize)
{    
    PVOID Data = NULL;
    ULONG DataSize = 0;

    if (ReadFromFile(usName, &Data, &DataSize))
    {
        PIMAGE_NT_HEADERS32 pHeaders32 = (PIMAGE_NT_HEADERS32)
            ((PUCHAR)Data + ((PIMAGE_DOS_HEADER)Data)->e_lfanew);

        PIMAGE_SECTION_HEADER pSection = NULL;

        ULONG ImageSize = 0, HeadersSize = 0, NumberOfSections = 0;

        if (pHeaders32->FileHeader.Machine == IMAGE_FILE_MACHINE_I386)
        {
            // 32-bit image
            pSection = (PIMAGE_SECTION_HEADER)
                (pHeaders32->FileHeader.SizeOfOptionalHeader + 
                (PUCHAR)&pHeaders32->OptionalHeader);

            ImageSize = pHeaders32->OptionalHeader.SizeOfImage;
            HeadersSize = pHeaders32->OptionalHeader.SizeOfHeaders;
            NumberOfSections = pHeaders32->FileHeader.NumberOfSections;           
        }        
        else if (pHeaders32->FileHeader.Machine == IMAGE_FILE_MACHINE_AMD64)
        {
            // 64-bit image
            PIMAGE_NT_HEADERS64 pHeaders64 = (PIMAGE_NT_HEADERS64)
                ((PUCHAR)Data + ((PIMAGE_DOS_HEADER)Data)->e_lfanew);

            pSection = (PIMAGE_SECTION_HEADER)
                (pHeaders64->FileHeader.SizeOfOptionalHeader + 
                (PUCHAR)&pHeaders64->OptionalHeader);

            ImageSize = pHeaders64->OptionalHeader.SizeOfImage;
            HeadersSize = pHeaders64->OptionalHeader.SizeOfHeaders;
            NumberOfSections = pHeaders64->FileHeader.NumberOfSections;
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Unkown machine type\n");
            ExFreePool(Data);
            return FALSE;
        }

        if (*Image = ExAllocatePool(NonPagedPool, ImageSize))
        {
			ULONG i = 0;
            // copy headers
            RtlCopyMemory(*Image, Data, HeadersSize);

            // copy sections        
            for (i = 0; i < NumberOfSections; i++)
            {            
                RtlCopyMemory(
                    (PUCHAR)*Image + pSection->VirtualAddress, 
                    (PUCHAR)Data + pSection->PointerToRawData,
                    min(pSection->SizeOfRawData, pSection->Misc.VirtualSize)
                );

                pSection++;
            }

            *MappedImageSize = ImageSize;

            return TRUE;
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "ExAllocatePool() ERROR\n");
        }

        ExFreePool(Data);
    }

    return FALSE;
}

VOID WPOFFx64()
{
	UINT64 cr0 = __readcr0();
	cr0 &= 0xfffffffffffeffff;
	__writecr0(cr0);
}

VOID WPONx64()
{
	UINT64 cr0 = __readcr0();
	cr0 |= 0x10000;
	__writecr0(cr0);
}

//--------------------------------------------------------------------------------------
#ifdef WP_STUFF
void __stdcall ClearWp(PVOID Param)
{
#ifdef _X86_
    __asm
    {              
        mov     eax,cr0             
        and     eax,not 000010000h
        mov     cr0,eax
    }
#else
    // clear wp-bit in cr0 register
    WPOFFx64();
#endif // _X_86_
}
//--------------------------------------------------------------------------------------
void __stdcall SetWp(PVOID Param)
{
#ifdef _X86_
    __asm
    {
        mov     eax,cr0
        or      eax,000010000h
        mov     cr0,eax
    }
#else
    // set wp-bit in cr0 register
    //_set_wp();
	WPONx64();
#endif // _X_86_
}
#endif // WP_STUFF
//--------------------------------------------------------------------------------------
typedef struct _PROCESSOR_THREAD_PARAM
{
    KAFFINITY Mask;
    PKSTART_ROUTINE Routine;
    PVOID Param;

} PROCESSOR_THREAD_PARAM,
*PPROCESSOR_THREAD_PARAM;

void NTAPI ProcessorThread(PVOID Param)
{
    PPROCESSOR_THREAD_PARAM ThreadParam = (PPROCESSOR_THREAD_PARAM)Param;
    
    // bind thread to specific processor
    KeSetSystemAffinityThread(ThreadParam->Mask);
    
    // execute payload on this processor
    ThreadParam->Routine(ThreadParam->Param);
}

void ForEachProcessor(PKSTART_ROUTINE Routine, PVOID Param)
{
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
	KAFFINITY ActiveProcessors = 0;
	KAFFINITY i = 0;
    if (KeGetCurrentIrql() > PASSIVE_LEVEL)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Invalid IRQL (Must be =PASSIVE_LEVEL)\n");
        return;
    }

    // get bitmask of active processors
    ActiveProcessors = KeQueryActiveProcessors();    

    for (i = 0; i < sizeof(KAFFINITY) * 8; i++)
    {
        KAFFINITY Mask = (KAFFINITY)(1 << i);
        // check if this processor bit present in mask
        if (ActiveProcessors & Mask)
        {
            HANDLE hThread;
            PROCESSOR_THREAD_PARAM ThreadParam;
            
            ThreadParam.Mask    = Mask;
            ThreadParam.Param   = Param;
            ThreadParam.Routine = Routine;
            
            // create thread for this processor
            ns = PsCreateSystemThread(
                &hThread, 
                THREAD_ALL_ACCESS, 
                NULL, NULL, NULL, 
                ProcessorThread, 
                &ThreadParam
            );
            if (NT_SUCCESS(ns))
            {
                PVOID Thread;                
                // get pointer to thread object
                ns = ObReferenceObjectByHandle(
                    hThread,
                    THREAD_ALL_ACCESS,
                    NULL,
                    KernelMode,
                    &Thread,
                    NULL
                );
                if (NT_SUCCESS(ns))
                {
                    // waiting for thread termination
                    KeWaitForSingleObject(Thread, Executive, KernelMode, FALSE, NULL);
                    ObDereferenceObject(Thread);
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "ObReferenceObjectByHandle() fails; status: 0x%.8x\n", ns);
                }                

                ZwClose(hThread);
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "PsCreateSystemThread() fails; status: 0x%.8x\n", ns);
            }
        }
    }
}
//--------------------------------------------------------------------------------------
ULONG GetSyscallNumber(char *lpszName)
{
    // get base address of ntdll.dll, that mapped into the system process
    PVOID NtdllBase = KernelGetModuleBase("ntdll.dll");
    if (NtdllBase)
    {
        // get function addres by name hash
        ULONG FuncRva = KernelGetExportAddress(NtdllBase, lpszName);
        if (FuncRva)
        {
            PUCHAR Func = (PUCHAR)NtdllBase + FuncRva;
#ifdef _X86_
            // check for mov eax,imm32
            if (*Func == 0xB8)
            {
                // return imm32 argument (syscall numbr)
                return *(PULONG)((PUCHAR)Func + 1);
            }
#elif _AMD64_
            // check for mov eax,imm32
            if (*(Func + 3) == 0xB8)
            {
                // return imm32 argument (syscall numbr)
                return *(PULONG)(Func + 4);
            }
#endif
        }   
    }    

    return -1;
}
//--------------------------------------------------------------------------------------
BOOLEAN RegQueryValueKey(HANDLE hKey, PWSTR lpwcName, ULONG Type, PVOID *Data, PULONG DataSize)
{
    BOOLEAN bRet = FALSE;
    PKEY_VALUE_FULL_INFORMATION ValueInformation = NULL;
    ULONG ResultLen = 0;
    UNICODE_STRING usValueName;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    RtlInitUnicodeString(&usValueName, lpwcName);

    if (Data && DataSize)
    {
        *Data = NULL;
        *DataSize = 0;
    }

    // get required buffer size
    ns = ZwQueryValueKey(
        hKey, 
        &usValueName, 
        KeyValueFullInformation, 
        &ValueInformation, 
        0, 
        &ResultLen
    );
    if ((ns == STATUS_BUFFER_TOO_SMALL || 
         ns == STATUS_BUFFER_OVERFLOW) && ResultLen > 0)
    {
        // allocate memory for key information
        ValueInformation = (PKEY_VALUE_FULL_INFORMATION)M_ALLOC(ResultLen);
        if (ValueInformation)
        {
            memset(ValueInformation, 0, ResultLen);

            // query key information
            ns = ZwQueryValueKey(
                hKey,  
                &usValueName, 
                KeyValueFullInformation, 
                ValueInformation, 
                ResultLen, 
                &ResultLen
            );
            if (NT_SUCCESS(ns))
            {
                if (Type == REG_NONE || Type == ValueInformation->Type)
                {
                    if (Data && DataSize)
                    {
                        // allocate memory for value data
                        if (*Data = M_ALLOC(ValueInformation->DataLength))
                        {
                            RtlCopyMemory(
                                *Data,
                                (PUCHAR)ValueInformation + ValueInformation->DataOffset,
                                ValueInformation->DataLength
                            );

                            *DataSize = ValueInformation->DataLength;
                            bRet = TRUE;
                        }
                        else
                        {
                            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
                        }
                    }
                    else
                    {
                        // just say about value existance
                        bRet = TRUE;
                    }                    
                }                
                else
                {
                    DbgMsg(
                        __FILE__, __LINE__, 
                        __FUNCTION__"() ERROR: Bad value type (%d)\n",
                        ValueInformation->Type
                    );
                }
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ZwQueryValueKey() fails; status: 0x%.8x\n", ns);
            }       

            M_FREE(ValueInformation);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ZwQueryValueKey() fails; status: 0x%.8x\n", ns);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN RegSetValueKey(HANDLE hKey, PWSTR lpwcName, ULONG Type, PVOID Data, ULONG DataSize)
{
	NTSTATUS ns = STATUS_UNSUCCESSFUL;
    UNICODE_STRING usValueName;
    RtlInitUnicodeString(&usValueName, lpwcName);

    ns = ZwSetValueKey(hKey, &usValueName, 0, Type, Data, DataSize);
    if (!NT_SUCCESS(ns))
    {
        DbgMsg(__FILE__, __LINE__, "ZwSetValueKey() fails; status: 0x%.8x\n", ns);
        return FALSE;
    }

    return TRUE;
}
//--------------------------------------------------------------------------------------
#ifdef _X86_
#define PEB_PROCESS_PARAMS_OFFSET           0x10
#define PROCESS_PARAMS_FLAGS_OFFSET         0x08
#define PROCESS_PARAMS_IMAGE_NAME_OFFSET    0x38
#elif _AMD64_
#define PEB_PROCESS_PARAMS_OFFSET           0x20
#define PROCESS_PARAMS_FLAGS_OFFSET         0x08
#define PROCESS_PARAMS_IMAGE_NAME_OFFSET    0x60
#endif

#define	PROCESS_PARAMETERS_NORMALIZED	1	// pointers are absolute (not self-relative)

BOOLEAN GetProcessFullImagePath(PEPROCESS Process, PUNICODE_STRING ImagePath)
{
    BOOLEAN bRet = FALSE;
    HANDLE hProcess = NULL;
    
    // get handle to target process
    NTSTATUS ns = ObOpenObjectByPointer(
        Process,
        OBJ_KERNEL_HANDLE,
        NULL,
        0,
        NULL,
        KernelMode,
        &hProcess
    );
    if (NT_SUCCESS(ns))
    {
        PROCESS_BASIC_INFORMATION ProcessInfo;    

        // get address of PEB
        ns = ZwQueryInformationProcess(
            hProcess,
            ProcessBasicInformation,
            &ProcessInfo,
            sizeof(ProcessInfo),
            NULL
        );
        if (NT_SUCCESS(ns))
        {
            KAPC_STATE ApcState;

            // change context to target process
            KeStackAttachProcess(Process, &ApcState);

            __try
            {
                PUCHAR Peb = (PUCHAR)ProcessInfo.PebBaseAddress;
                if (Peb)
                {
                    // get pointer to RTL_USER_PROCESS_PARAMETERS
                    PUCHAR ProcessParams = *(PUCHAR *)(Peb + PEB_PROCESS_PARAMS_OFFSET);
                    if (ProcessParams)
                    {
                        // get image path
                        PUNICODE_STRING ImagePathName = (PUNICODE_STRING)
                            (ProcessParams + PROCESS_PARAMS_IMAGE_NAME_OFFSET);

                        if (ImagePathName->Buffer && ImagePathName->Length > 0)
                        {
                            // allocate string
                            if (AllocUnicodeString(ImagePath, ImagePathName->Length))
                            {
                                PWSTR lpwcName = NULL;
                                ULONG Flags = *(PULONG)(ProcessParams + PROCESS_PARAMS_FLAGS_OFFSET);

                                if (Flags & PROCESS_PARAMETERS_NORMALIZED)
                                {
                                    // pointer to buffer is absolute address
                                    lpwcName = ImagePathName->Buffer;
                                }
                                else
                                {
                                    // pointer to buffer is relative address
                                    lpwcName = (PWSTR)(ProcessParams + (ULONGLONG)ImagePathName->Buffer);
                                }

                                if (AppendUnicodeToString(ImagePath, lpwcName, ImagePathName->Length))
                                {
                                    bRet = TRUE;
                                }
                                else
                                {
                                    DbgMsg(__FILE__, __LINE__, "AppendUnicodeToString() ERROR\n");
                                }
                            }
                            else
                            {
                                DbgMsg(__FILE__, __LINE__, "AllocUnicodeString() ERROR\n");
                            }
                        }
                    }
                }
            }
            __except (EXCEPTION_EXECUTE_HANDLER)
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"() EXCEPTION\n");
            }
            
            KeUnstackDetachProcess(&ApcState);
        }
        else
        {
            // Can't query information about process, probably 'System' or rootkit activity
        }        

        ZwClose(hProcess);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ObOpenObjectByPointer() fails; status: 0x%.8x\n", ns);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN AllocateUserMemory(ULONG Size, PMAPPED_MDL MdlInfo)
{
	PVOID Buffer = NULL;
    MdlInfo->Mdl = NULL;
    MdlInfo->Buffer = NULL;
    MdlInfo->MappedBuffer = NULL;

    // allocate kernel-mode buffer in non-paged pool
    Buffer = M_ALLOC(Size);
    if (Buffer)
    {
        // allocate memory descriptor
        PMDL Mdl = IoAllocateMdl(Buffer, Size, FALSE, FALSE, NULL);
        if (Mdl)
        {
			PVOID MappedBuffer = NULL;
            __try
            {
                // lock allocated pages
                MmProbeAndLockPages(Mdl, KernelMode, IoWriteAccess);
            }
            __except (EXCEPTION_EXECUTE_HANDLER)
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): MmProbeAndLockPages() EXCEPTION\n");
                
                IoFreeMdl(Mdl);
                M_FREE(Buffer);
                
                return FALSE;
            }

            // map allocated pages into the user space
            MappedBuffer = MmMapLockedPagesSpecifyCache(
                Mdl, 
                UserMode, 
                MmCached, 
                NULL, 
                FALSE, 
                NormalPagePriority
            );
            if (MappedBuffer)
            {
                MdlInfo->Mdl = Mdl;
                MdlInfo->Buffer = Buffer;
                MdlInfo->MappedBuffer = MappedBuffer;

                return TRUE;   
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): MmMapLockedPagesSpecifyCache() fails\n");
            }

            MmUnlockPages(Mdl);
            IoFreeMdl(Mdl);
        } 
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): IoAllocateMdl() fails\n");
        }

        M_FREE(Buffer);
    }    
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): M_ALLOC() fails\n");
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
void FreeUserMemory(PMAPPED_MDL MdlInfo)
{
    // unmap user-mode address
    MmUnmapLockedPages(MdlInfo->MappedBuffer, MdlInfo->Mdl);

    // unlock pages
    MmUnlockPages(MdlInfo->Mdl);

    // free memory descriptor
    IoFreeMdl(MdlInfo->Mdl);

    // free buffer
    M_FREE(MdlInfo->Buffer);
}
//--------------------------------------------------------------------------------------
BOOLEAN IsWow64Process(PEPROCESS Process, BOOLEAN *bIsWow64)
{
    HANDLE hProcess = NULL;
	NTSTATUS ns = STATUS_UNSUCCESSFUL;

    *bIsWow64 = FALSE;
    
    // get handle to target process
    ns = ObOpenObjectByPointer(
        Process,
        OBJ_KERNEL_HANDLE,
        NULL,
        0,
        NULL,
        KernelMode,
        &hProcess
    );
    if (NT_SUCCESS(ns))
    {
        ULONG_PTR Wow64Info = 0;
        
        ns = ZwQueryInformationProcess(
            hProcess,
            ProcessWow64Information,
            &Wow64Info,
            sizeof(Wow64Info),
            NULL
        );
        if (NT_SUCCESS(ns))
        {
            if (Wow64Info)
            {
                // this is wow64 process
                *bIsWow64 = TRUE;
            }
        }
        else 
        {
            DbgMsg(__FILE__, __LINE__, "ZwQueryInformationProcess() fails; status: 0x%.8x\n", ns);
        }

        ZwClose(hProcess);
        return TRUE;
    }
    else 
    {
        DbgMsg(__FILE__, __LINE__, "ObOpenObjectByPointer() fails; status: 0x%.8x\n", ns);
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
// EoF
