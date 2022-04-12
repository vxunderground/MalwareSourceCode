#pragma once
#include <windows.h>

#define PAGE_SIZE 0x1000

bool is_compiled_32b();
bool is_wow64();
bool is_system32b();
bool is_target_32bit(HANDLE hProcess, LPVOID ImageBase);
