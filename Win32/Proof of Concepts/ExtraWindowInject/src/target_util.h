#pragma once
#include <wchar.h>

void replace_param(LPWSTR cmdBuf, SIZE_T cmdBufSize, LPWSTR paramVal)
{
  wchar_t * pwc;
  printf("--\n");
  pwc = wcsstr (cmdBuf, L"%1");
  if (pwc == NULL) return; //param not found

  SIZE_T paramLen = wcslen(paramVal);
  SIZE_T offset = pwc - cmdBuf;
  if (offset + paramLen + 1 >= cmdBufSize) return; //no space in buffer

  wcsncpy (pwc, paramVal, paramLen);
 
  cmdBuf[offset + paramLen + 1] = NULL;
  if (offset == 0) return;

  if (cmdBuf[offset-1] == '\"' || cmdBuf[offset-1] == '\'') {
      cmdBuf[offset + paramLen] = cmdBuf[0];
      cmdBuf[offset + paramLen + 1] = NULL;
  }
}

void remove_params(LPWSTR cmdLine, SIZE_T cmdLineLen)
{
  wchar_t * pwc;
  printf("--\n");

  WCHAR extension[] = L".exe";
  SIZE_T extensionLen = wcslen(extension);
  pwc = wcsstr (cmdLine, extension);
  if (pwc == NULL) return;

  SIZE_T offset = pwc - cmdLine;
  cmdLine[offset + extensionLen] = NULL;
  if (cmdLine[0] == '\"' || cmdLine[0] == '\'') {
      cmdLine[offset + extensionLen] = cmdLine[0];
      cmdLine[offset + extensionLen + 1] = NULL;
  }
}

bool get_dir(LPWSTR cmdLine, OUT LPWSTR dirBuf, SIZE_T dirBufLen = MAX_PATH)
{
    wchar_t * pwc;
    pwc = wcsrchr (cmdLine, L'\\');
    if (pwc == NULL) {
        pwc = wcsrchr (cmdLine, L'/');
    }
    if (pwc == NULL) return false;
  
    SIZE_T offset = pwc - cmdLine + 1;
    if (offset >= dirBufLen) return false;

    if (cmdLine[offset] != '\"' && cmdLine[offset] != '\'') {
        return false;
    }
    if (cmdLine[0] == '\"' || cmdLine[0] == '\'') {
        wcsncpy(dirBuf, cmdLine+1, offset-1);
        dirBuf[offset-1] = NULL;
    } else {
        wcsncpy(dirBuf, cmdLine, offset);
        dirBuf[offset + 1] = NULL;
    }
    printf("Dir: %S\n", dirBuf);
    return true;
}

bool get_default_browser(LPWSTR lpwOutPath, DWORD szOutPath)
{
    HKEY phkResult;
    DWORD iMaxLen = szOutPath;

    LSTATUS res = RegOpenKeyEx(HKEY_CLASSES_ROOT, L"HTTP\\shell\\open\\command", 0, 1u, &phkResult);
    if (res != ERROR_SUCCESS) {
        printf("[ERROR] Failed with value = %x\n", res);
        return false;
    }

    res = RegQueryValueEx(phkResult, NULL, NULL, NULL, (LPBYTE) lpwOutPath, (LPDWORD) &iMaxLen);
    if (res != ERROR_SUCCESS) {
        printf("[ERROR] Failed with value = %x\n", res);
        return false;
    }
    replace_param(lpwOutPath, szOutPath, L"www.google.com");
    return true;
}

bool get_calc_path(LPWSTR lpwOutPath, DWORD szOutPath)
{
#if defined(_WIN64)
    ExpandEnvironmentStrings(L"%SystemRoot%\\SysWoW64\\calc.exe", lpwOutPath, szOutPath);
#else
    ExpandEnvironmentStrings(L"%SystemRoot%\\system32\\calc.exe", lpwOutPath, szOutPath);
#endif
    printf("%S\n", lpwOutPath);
    return true;
}

bool get_svchost_path(LPWSTR lpwOutPath, DWORD szOutPath)
{
#if defined(_WIN64)
    ExpandEnvironmentStrings(L"%SystemRoot%\\SysWoW64\\svchost.exe", lpwOutPath, szOutPath);
#else
    ExpandEnvironmentStrings(L"%SystemRoot%\\system32\\svchost.exe", lpwOutPath, szOutPath);
#endif
    printf("%S\n", lpwOutPath);
    return true;
}

bool get_explorer_path(LPWSTR lpwOutPath, DWORD szOutPath)
{
    ExpandEnvironmentStrings(L"%windir%\\explorer.exe", lpwOutPath, szOutPath);
    printf("%S\n", lpwOutPath );
    return true;
}
