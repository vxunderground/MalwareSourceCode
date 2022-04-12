#include "pe_hdrs_helper.h"

IMAGE_NT_HEADERS32* get_nt_hrds32(BYTE *pe_buffer)
{
    if (pe_buffer == NULL) return NULL;

    IMAGE_DOS_HEADER *idh = (IMAGE_DOS_HEADER*)pe_buffer;
    if (idh->e_magic != IMAGE_DOS_SIGNATURE) {
        return NULL;
    }
    const LONG kMaxOffset = 1024;
    LONG pe_offset = idh->e_lfanew;
    if (pe_offset > kMaxOffset) return NULL;

    IMAGE_NT_HEADERS32 *inh = (IMAGE_NT_HEADERS32 *)((BYTE*)pe_buffer + pe_offset);
    return inh;
}

IMAGE_DATA_DIRECTORY* get_pe_directory32(PVOID pe_buffer, DWORD dir_id)
{
    if (dir_id >= IMAGE_NUMBEROF_DIRECTORY_ENTRIES) return NULL;

    //fetch relocation table from current image:
    PIMAGE_NT_HEADERS32 nt_headers = get_nt_hrds32((BYTE*) pe_buffer);
    if (nt_headers == NULL) return NULL;

    IMAGE_DATA_DIRECTORY* peDir = &(nt_headers->OptionalHeader.DataDirectory[dir_id]);
    if (peDir->VirtualAddress == NULL) {
        return NULL;
    }
    return peDir;
}
