#include "DriverEntry.h"

BOOLEAN KernelHookCheck(PINLINEHOOKINFO InlineHookInfo);

VOID FillInlineHookInfo(PUCHAR ulTemp,PINLINEHOOKINFO InlineHookInfo,CHAR*   szFunctionName,ULONG ulOldAddress,ULONG HookType);
VOID CheckFuncByOpcode(PVOID ulReloadAddress,PINLINEHOOKINFO InlineHookInfo,CHAR*   szFunctionName,PVOID ulOldAddress);

ULONG GetNextFunctionAddress(ULONG ulNtDllModuleBase,ULONG ulOldAddress,char *functionName,PINLINEHOOKINFO InlineHookInfo);
BOOLEAN ReSetEatHook(CHAR *lpszFunction,ULONG ulReloadKernelModule,ULONG ulKernelModule);
ULONG GetEatHook(ULONG ulOldAddress,int x,ULONG ulSystemKernelModuleBase,ULONG ulSystemKernelModuleSize);
BOOLEAN IsFunctionInExportTable(ULONG ulModuleBase,ULONG ulFunctionAddress);