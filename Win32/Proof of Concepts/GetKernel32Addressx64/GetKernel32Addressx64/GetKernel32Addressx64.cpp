// GetKernel32Addressx64.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "GetKernel32Addressx64.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// 唯一的应用程序对象

CWinApp theApp;

using namespace std;

#include<windows.h>
extern "C" PVOID64 _cdecl GetPeb();


typedef struct _UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWSTR  Buffer;
}UNICODE_STRING, *PUNICODE_STRING;

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
    PVOID64 Peb = NULL;
    PVOID64 LDR_DATA_Addr = NULL;
    UNICODE_STRING* FullName; 
    HMODULE hKernel32 = NULL;
    LIST_ENTRY* pNode = NULL;

    // For win7 x64 TEST
    Peb = GetPeb();
    if(Peb == NULL)
        return 0;

    LDR_DATA_Addr = *(PVOID64**)((BYTE*)Peb+0x018);
    if(LDR_DATA_Addr == NULL)
        return 0;

    pNode =(LIST_ENTRY*)(*(PVOID64**)((BYTE*)LDR_DATA_Addr+0x30));
    while(true)
    {
        FullName = (UNICODE_STRING*)((BYTE*)pNode+0x38);
        if(*(FullName->Buffer + 12) == '\0')
        {
            hKernel32 = (HMODULE)(*((ULONG64*)((BYTE*)pNode+0x10)));
            break;
        }
        pNode = pNode->Flink;
    }
    printf("%S : %p",FullName->Buffer,hKernel32);
    
    return 0;
}
