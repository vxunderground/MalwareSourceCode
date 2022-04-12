//
// Copyright (c) Johnny Shaw. All rights reserved.
// 
// File:     pch.hpp 
// Author:   Johnny Shaw
// Abstract: Pre-compiled Header 
//
#pragma once

//
// Windows
//
#define WIN32_LEAN_AND_MEAN
#define WIN32_NO_STATUS
#include <Windows.h>
#undef WIN32_NO_STATUS
#include <ntstatus.h>
#include <strsafe.h>
#include <winioctl.h>
#include <bcrypt.h>

//
// STL
//
#include <cstdint>
#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
#include <array>
#include <vector>
#include <algorithm>
#include <functional>
#include <optional>
#include <span>

//
// Third Party
//
#pragma warning(push)
#pragma warning(disable : 6387)  // prefast: does not adhere to the specification for the function
#pragma warning(disable : 6001)  // prefast: using uninitialized memory 
#pragma warning(disable : 6388)  // prefast: data may not be value 
#pragma warning(disable : 4634)  // xmldoc: discarding XML document comment for invalid target 
#pragma warning(disable : 4635)  // xmldoc: badly-formatted XML 
#include <wil/common.h>
#include <wil/stl.h>
#include <wil/result.h>
#include <wil/resource.h>
#pragma warning(pop)
#pragma warning(push)
#pragma warning(disable : 4201)  // nameless struct/union
#pragma warning(disable : 4324)  // structure was padded due to __declspec(align())
#pragma warning(disable : 4471)  // a forward declaration of an unscoped enumeration
#pragma warning(disable : 28253) // prefast: Inconsistent annotation
#define PHNT_VERSION PHNT_THRESHOLD
#include <phnt/phnt_windows.h>
#include <phnt/phnt.h>
#include <phnt/ntpsapi.h>
#include <phnt/ntrtl.h>
#include <phnt/ntpebteb.h>
#pragma warning(pop)

//
// Common Macros/Defines/Usings
//
#define SCAST(_X_) static_cast<_X_>
#define RCAST(_X_) reinterpret_cast<_X_>
#define CCAST(_X_) const_cast<_X_>
#define DCAST(_X_) dynamic_cast<_X_>
#define Add2Ptr(_P_, _X_) RCAST(void*)(RCAST(uintptr_t)(_P_) + _X_)
#ifndef FlagOn
#define FlagOn(_F_, _X_) ((_F_) & (_X_))
#endif
#ifndef SetFlag
#define SetFlag(_F_, _X_) ((_F_) |= (_X_))
#endif
#ifndef ClearFlag
#define ClearFlag(_F_, _X_) ((_F_) &= ~(_X_))
#endif
using handle_t = HANDLE;

//
// wil extensions
//
namespace wil 
{
    using unique_user_process_parameters = unique_any<
        PRTL_USER_PROCESS_PARAMETERS,
        decltype(&RtlDestroyProcessParameters),
        RtlDestroyProcessParameters>;
}
#define RETURN_LAST_ERROR_SET(win32err) SetLastError(win32err); RETURN_LAST_ERROR()

//
// prefast suppression
//
#pragma warning(disable : 6319)  // prefast: use of the comma-operator in a tested expression

//
// Internal
//
#include "res/version.h"
