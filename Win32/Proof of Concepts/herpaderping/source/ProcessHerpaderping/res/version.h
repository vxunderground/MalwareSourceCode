//
// Copyright (c) Johnny Shaw. All rights reserved.
// 
// File:     source/ProcessHerpaderping/res/version.h
// Author:   Johnny Shaw
// Abstract: Version Header 
//
#pragma once
#define VER_MAJOR                       1
#define VER_MINOR                       0
#define VER_PATCH                       0
#define VER_BUILD                       1

#define MKSTR(_x_) #_x_
#define MKWSTR(_x_) L##_x_
#define VER_MAKE_STR(_Major_, _Minor_, _Patch_, _Build_)\
MKSTR(_Major_) "." \
MKSTR(_Minor_) "." \
MKSTR(_Patch_) "." \
MKSTR(_Build_)
#define VER_MAKE_WSTR(_Major_, _Minor_, _Patch_, _Build_)\
MKWSTR(_Major_) L"." \
MKWSTR(_Minor_) L"." \
MKWSTR(_Patch_) L"." \
MKWSTR(_Build_)

#define WSTR_COMPANY_NAME               L"Johnny Shaw"
#define STR_COMPANY_NAME                "Johnny Shaw"
#define WSTR_COPYRIGHT                  L"Copyright (c) 2020 Johnny Shaw"
#define STR_COPYRIGHT                   "Copyright (c) 2020 Johnny Shaw"
#define WSTR_ORIGINAL_FILENAME          L"ProcessHerpaderping.exe"
#define STR_ORIGINAL_FILENAME           "ProcessHerpaderping.exe"
#define WSTR_PRODUCT_NAME               L"Process Herpaderping Tool"
#define STR_PRODUCT_NAME                "Process Herpaderping Tool"
#define WSTR_FILE_DESCRIPTION           WSTR_PRODUCT_NAME
#define STR_FILE_DESCRIPTION            STR_PRODUCT_NAME
#define WSTR_INTERNAL_NAME              L"ProcessHerpaderping"
#define STR_INTERNAL_NAME               "ProcessHerpaderping"
#define WSTR_VERSION                    VER_MAKE_WSTR(VER_MAJOR, VER_MINOR, VER_PATCH, VER_BUILD)
#define STR_VERSION                     VER_MAKE_STR(VER_MAJOR, VER_MINOR, VER_PATCH, VER_BUILD)
#define WSTR_PRODUCT_VERSION            WSTR_VERSION
#define STR_PRODUCT_VERSION             STR_VERSION
