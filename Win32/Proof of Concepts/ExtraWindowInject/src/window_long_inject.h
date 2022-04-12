#pragma once

#include <Windows.h>
#include "ntddk.h"

bool inject_into_tray(LPBYTE shellcode, SIZE_T shellcodeSize);
