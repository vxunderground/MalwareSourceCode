// InjectDllBySetThreadContextx64.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"

#include <iostream>
using namespace std;
#include <windows.h>
#include "tlhelp32.h"
BYTE ShellCode[64]=
{
    0x60,
    0x9c,
    0x68,               //push
    0xaa,0xbb,0xcc,0xdd,//dll path  +3  dll最目标进程中的地址
    0xff,0x15,          //call     这里感觉有点乱，我在64下直接call 相对地址 
    0xdd,0xcc,0xbb,0xaa,//+9 LoadLibrary Addr  Addr
    0x9d,
    0x61,
    0xff,0x25,          //jmp
    0xaa,0xbb,0xcc,0xdd,// +17  jmp  eip
    0xaa,0xaa,0xaa,0xaa,// loadlibrary addr
    0xaa,0xaa,0xaa,0xaa//  jmpaddr  +25

    //  +29
}; 

/*
{
00973689 >    60                PUSHAD
0097368A      9C                PUSHFD
0097368B      68 50369700       PUSH notepad.00973650
00973690      FF15 70369700     CALL DWORD PTR DS:[973670]
00973696      9D                POPFD
00973697      61                POPAD
00973698    - FF25 30369700     JMP DWORD PTR DS:[973630]
}
*/

BYTE ShellCode64[64]=
{
    0x48,0x83,0xEC,0x28,  // sub rsp ,28h

    0x48,0x8D,0x0d,       // [+4] lea rcx,
    0xaa,0xbb,0xcc,0xdd,  // [+7] dll path offset =  TargetAddress- Current(0x48)[+4] -7 

    0x48, 0xB8,
    0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
    0xff, 0xd0,

    0x48,0x83,0xc4,0x28,  // [+16] add rsp,28h
    //0xcc, 调试时断下来的int 3 正常运行的时候非常傻逼的没有请掉...难怪一直死
    0xff,0x25,            // [+20]
    0xaa,0xbb,0xcc,0xdd,  // [+22] jmp rip offset  = TargetAddress - Current(0xff)[+20] - 6

    0xaa,0xbb,0xcc,0xdd,  //+26
    0xaa,0xbb,0xcc,0xdd   
    //+34
};

BOOL EnableDebugPriv() ;
BOOL StartHook(HANDLE hProcess,HANDLE hThread);


DWORD main_GetProcessIdByName(LPWSTR pszProcessName, PDWORD pdwProcessId)
{
    DWORD dwProcessId = 0;
    HANDLE hSnapshot = NULL;
    PROCESSENTRY32 pe = { 0 };
    DWORD eReturn = 0;

    hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (NULL == hSnapshot)
    {
        eReturn = -1;
        printf("CreateToolhelp32Snapshot error. GLE: %d.", GetLastError());
        goto lblCleanup;
    }

    pe.dwSize = sizeof(PROCESSENTRY32);
    if (FALSE == Process32First(hSnapshot, &pe))
    {
        eReturn = -1;
        printf("Process32First error. GLE: %d.", GetLastError());
        goto lblCleanup;
    }

    do
    {
        if (NULL != wcsstr(pe.szExeFile, pszProcessName))
        {
            dwProcessId = pe.th32ProcessID;
            break;
        }
    } while (Process32Next(hSnapshot, &pe));

    if (0 == dwProcessId)
    {
        printf("[*] Process '%S' could not be found.\n\n\n", pszProcessName);
        eReturn = -1;
        goto lblCleanup;
    }

    printf("[*] Found process '%S'. PID: %d (0x%X).\n\n\n", pszProcessName, dwProcessId, dwProcessId);
    *pdwProcessId = dwProcessId;
    eReturn = 0;

lblCleanup:
    if ((NULL != hSnapshot) && (INVALID_HANDLE_VALUE != hSnapshot))
    {
        CloseHandle(hSnapshot);
        hSnapshot = NULL;
    }
    return eReturn;

}

int _tmain(int argc, _TCHAR* argv[])
{
    EnableDebugPriv() ;

    DWORD ProcessId = 0;
#ifdef _WIN64
    main_GetProcessIdByName(L"targetx64.exe", &ProcessId);
#else
    main_GetProcessIdByName(L"target.exe", &ProcessId);
#endif
    

    HANDLE Process = OpenProcess(PROCESS_ALL_ACCESS,NULL,ProcessId);
    if(Process == NULL)
    {
        printf("OpenProcess Fail LastError [%d]\n", GetLastError());
        getchar();
        return 0;
    }
    printf("Open Process [%d] OK.\n", ProcessId);

    THREADENTRY32 te32 = {sizeof(THREADENTRY32)} ;  
    HANDLE hThreadSnap = CreateToolhelp32Snapshot (TH32CS_SNAPTHREAD, 0) ;  
    if ( hThreadSnap == INVALID_HANDLE_VALUE )  
    {
        printf("CreateToolhelp32Snapshot fail LastError [%d]\n", GetLastError());
        getchar();
        return FALSE;  
    }

    if (Thread32First(hThreadSnap, &te32))  
    {  
        do{  
            if(te32.th32OwnerProcessID == ProcessId)
            {
                HANDLE Thread = OpenThread(THREAD_ALL_ACCESS,NULL,te32.th32ThreadID);
                if(Thread == NULL)
                {
                    printf("OpenThread Failed LastError [%d]\n", GetLastError());
                    break;
                }
                SuspendThread(Thread);

                printf("start Hook.\n");
                if (!StartHook(Process,Thread))
                {
                    printf("失败\n");
                    getchar();
                }
                else
                {
                    CloseHandle(Thread);
                    break;
                }
                CloseHandle(Thread);
            }        
        }while(Thread32Next(hThreadSnap, &te32));  
    }  
    CloseHandle(Process);
    CloseHandle(hThreadSnap);  

    getchar();
}

BYTE *DllPath;
BOOL StartHook(HANDLE hProcess,HANDLE hThread)
{
#ifdef _WIN64 
    CONTEXT ctx;
    ctx.ContextFlags=CONTEXT_ALL;
    if (!GetThreadContext(hThread,&ctx))
    {
        printf("GetThreadContext Error LastError [%d]\n", GetLastError());
        return FALSE;
    }

    printf("getThreadContext OK.\n");
    LPVOID LpAddr=VirtualAllocEx(hProcess,NULL,64,MEM_COMMIT,PAGE_EXECUTE_READWRITE);
    if (LpAddr==NULL)
    {
        printf("VirtualAlloc Error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    DWORD64 LoadDllAAddr=(DWORD64)GetProcAddress(GetModuleHandle(L"kernel32.dll"),"LoadLibraryA");
    if (LoadDllAAddr==NULL)
    {
        printf("LoadDllAddr error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    /*

    0x48,0x83,0xEC,0x28,  //sub rsp ,28h

    0x48,0x8D,0x0d,       // [+4] lea rcx,
    0xaa,0xbb,0xcc,0xdd,  // [+7] dll path offset =  TargetAddress- Current(0x48)[+4] -7 

    0x48, 0xB8,           // [+11]mov rax,  ptr
    0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
    0xff, 0xd0,           // [+21] call rax

    0x48,0x83,0xc4,0x28,  // [+23] add rsp,28h

    0xff,0x25,            // [+27]
    0xaa,0xbb,0xcc,0xdd,  // [+29] jmp rip offset  = TargetAddress - Current(0xff)[+20] - 6

    0xaa,0xbb,0xcc,0xdd,  //+33
    0xaa,0xbb,0xcc,0xdd   
    //+41
    */
    DllPath=ShellCode64+41;
    strcpy((char*)DllPath,"Dllx64.dll");//这里是要注入的DLL名字
    DWORD DllNameOffset = 30;// ((BYTE*)LpAddr+34) -((BYTE*)LpAddr+4) -7 这个指令7个字节
    *(DWORD*)(ShellCode64+7)=(DWORD)DllNameOffset;
    ////////////////
    DWORD64 LoadDllAddroffset = (DWORD64)LoadDllAAddr;// - ((BYTE*)LpAddr + 11) -5;  //这个指令5个字节e8 + 4addroffset
    *(DWORD64*)(ShellCode64+13)=LoadDllAddroffset;
    //////////////////////////////////
    
    
    *(DWORD64*)(ShellCode64+33)=ctx.Rip; //64下为rip
    *(DWORD*)(ShellCode64+29)= (DWORD)0; //我将地址放在+26的地方，相对offset为0
    
//  这里因为这样写跳转不到目标地址，故x64 应该要中转一次  相对寻址
//     DWORD Ds = (DWORD)ctx.SegDs;
//     DWORD RipOffset = (BYTE*)ctx.Rip - ((BYTE*)LpAddr+20) -6;
//     *(DWORD*)(ShellCode64+22)=(DWORD)ctx.Rip;

    ////////////////////////////////////
    if (!WriteProcessMemory(hProcess,LpAddr,ShellCode64,64,NULL))
    {
        printf("write Process Error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    ctx.Rip=(DWORD64)LpAddr;
    if (!SetThreadContext(hThread,&ctx))
    {
        printf("set thread context error LastError [%d]\n", GetLastError());
        return FALSE;
    }

    printf("SetThreadContext OK.\n");
    ResumeThread(hThread);
    return TRUE;
    
#else
    CONTEXT ctx = {0};
    ctx.ContextFlags=CONTEXT_ALL;
    if (!GetThreadContext(hThread,&ctx))
    {
        printf("GetThreadContext Error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    printf("GetThreaxContext OK.\n");
    LPVOID LpAddr=VirtualAllocEx(hProcess,NULL,64,MEM_COMMIT,PAGE_EXECUTE_READWRITE);
    if (LpAddr==NULL)
    {
        printf("VirtualAlloc Error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    DWORD LoadDllAAddr=(DWORD)GetProcAddress(GetModuleHandle(L"kernel32.dll"),"LoadLibraryA");
    if (LoadDllAAddr==NULL)
    {
        printf("LoadDllAddr error LastError [%d]\n", GetLastError());
        return FALSE;
    }

    /////////////
    /*
    0x60,              PUSHAD
    0x9c,              PUSHFD
    0x68,              PUSH 
    0xaa,0xbb,0xcc,0xdd,//dll path  address  
    0xff,0x15,            CALL
    0xdd,0xcc,0xbb,0xaa,  offset  
    0x9d,                  POPFD
    0x61,                  POPAD
    0xff,0x25,             JMP 
    0xaa,0xbb,0xcc,0xdd,//  [xxxxx]
    0xaa,0xaa,0xaa,0xaa,// LoadLibrary Address
    0xaa,0xaa,0xaa,0xaa//  恢复的EIP  Address  
                         // +29  Dll名字
    */
    _asm mov esp,esp
    DllPath=ShellCode+29;
    strcpy((char*)DllPath,"Dllx86.dll");//这里是要注入的DLL名字
    *(DWORD*)(ShellCode+3)=(DWORD)LpAddr+29;
    ////////////////
    *(DWORD*)(ShellCode+21)=LoadDllAAddr;   //loadlibrary地址放入shellcode中
    *(DWORD*)(ShellCode+9)=(DWORD)LpAddr+21;//修改call 之后的地址 为目标空间存放 loaddlladdr的地址
    //////////////////////////////////
    *(DWORD*)(ShellCode+25)=ctx.Eip;
    *(DWORD*)(ShellCode+17)=(DWORD)LpAddr+25;//修改jmp 之后为原来eip的地址
    ////////////////////////////////////
    if (!WriteProcessMemory(hProcess,LpAddr,ShellCode,64,NULL))
    {
        printf("write Process Error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    ctx.Eip=(DWORD)LpAddr;
    if (!SetThreadContext(hThread,&ctx))
    {
        printf("set thread context error LastError [%d]\n", GetLastError());
        return FALSE;
    }
    printf("SetThreadContext OK.\n");
    ResumeThread(hThread);
    return TRUE;
#endif
    
};

BOOL EnableDebugPriv() 
{
    HANDLE   hToken; 
    LUID   sedebugnameValue; 
    TOKEN_PRIVILEGES   tkp;
    if(!OpenProcessToken(GetCurrentProcess(),TOKEN_ADJUST_PRIVILEGES|TOKEN_QUERY,&hToken)) 
    { 
        return FALSE; 
    } 

    if(!LookupPrivilegeValue(NULL,SE_DEBUG_NAME,&sedebugnameValue)) 
    { 
        CloseHandle(hToken); 
        return FALSE; 
    } 
    tkp.PrivilegeCount = 1; 
    tkp.Privileges[0].Luid = sedebugnameValue; 
    tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED; 

    if(!AdjustTokenPrivileges(hToken,FALSE,&tkp,sizeof(tkp),NULL,NULL)) 
    { 
        return FALSE; 
    }   
    CloseHandle(hToken); 
    return TRUE;
} 


