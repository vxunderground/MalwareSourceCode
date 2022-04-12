#pragma once
#include <Windows.h>

IMAGE_NT_HEADERS32* get_nt_hrds32(BYTE *pe_buffer);
IMAGE_DATA_DIRECTORY* get_pe_directory32(PVOID pe_buffer, DWORD dir_id);
