/************************************************************************
 * 
 * 1）当EXE里某个线程执行到SleepEx()或者WaitForSingleObjectEx()时，系统就会产生一个软中断。
 * 2）当线程再次被唤醒时，此线程会首先执行APC队列中的被注册的函数。
 * 3）利用QueueUserAPC()这个API可以在软中断时向线程的APC队列插入一个函数指针
 *    如果我们插入的是Loadlibrary()执行函数的话，就能达到注入DLL的目的。
 * 4) 线程有个可提醒状态，如果为FALSE，则不会调用用户APC队列
*************************************************************************/
#include "stdafx.h"
#include "UserAPC.h"

#include <windows.h>
#include <TlHelp32.h>

#include <iostream>
#include <string>
using namespace std;

#define DEF_BUF_SIZE 1024
BOOL AdjustPrivilege();
BOOL InjectModuleToProcessById(DWORD dwProcessId);
// 用于存储注入模块DLL的路径全名
char szDllPath[DEF_BUF_SIZE] = {0} ;


int _tmain(int argc, _TCHAR* argv[])
{
    // 取得当前工作目录路径
    GetCurrentDirectoryA(DEF_BUF_SIZE, szDllPath);

    // 生成注入模块DLL的路径全名
#ifdef _WIN64
    strcat ( szDllPath, "\\Dllx64.dll" ) ;
#else
    strcat ( szDllPath, "\\Dllx86.dll" ) ;
#endif
    
    DWORD dwProcessId = 0 ;
    // 接收用户输入的目标进程ID
    while( cout << "请输入目标进程ID：" && cin >> dwProcessId && dwProcessId > 0 ) 
    {
        BOOL bRet = InjectModuleToProcessById(dwProcessId);
        cout << (bRet ? "注入成功":"注入失败") << endl ;
    }
    return 0;
}



// 使用APC机制向指定ID的进程注入模块
BOOL InjectModuleToProcessById(DWORD dwProcessId)
{
    SIZE_T dwRet = 0;
    BOOL    bStatus = FALSE ;
    LPVOID    lpData = NULL ;
    UINT    uLen = strlen(szDllPath) + 1;

    AdjustPrivilege(); //

    // 打开目标进程
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessId);
    if(hProcess)
    {
        // 分配空间
        lpData = VirtualAllocEx ( hProcess, NULL, uLen, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
        if ( lpData )
        {
            // 写入需要注入的模块路径全名
            bStatus = WriteProcessMemory(hProcess, lpData, szDllPath, uLen, (SIZE_T*)(&dwRet));
        }
        CloseHandle(hProcess);
    }

    if (bStatus == FALSE)
        return FALSE ;

    // 创建线程快照
    THREADENTRY32 te32 = { sizeof(THREADENTRY32) };
    HANDLE hThreadSnap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if(hThreadSnap == INVALID_HANDLE_VALUE) 
        return FALSE ; 

    bStatus = FALSE ;
    // 枚举所有线程
    if(Thread32First(hThreadSnap, &te32))
    {
        do{
            // 判断是否目标进程中的线程
            if(te32.th32OwnerProcessID == dwProcessId)
            {
                // 打开线程
                HANDLE hThread = OpenThread(THREAD_ALL_ACCESS, FALSE, te32.th32ThreadID);
                if ( hThread )
                {
                    // 向指定线程添加APC
                    DWORD dwRet1 = QueueUserAPC((PAPCFUNC)LoadLibraryA, hThread, (ULONG_PTR)lpData);
                    if ( dwRet1 > 0 )
                    {
                        bStatus = TRUE ;
                    }
                    CloseHandle(hThread);
                }
            } 
        }while(Thread32Next ( hThreadSnap, &te32));
    }

    CloseHandle(hThreadSnap);
    return bStatus;
}


BOOL AdjustPrivilege()
{
    HANDLE hToken;
    TOKEN_PRIVILEGES pTP;
    LUID uID;
    if (!OpenProcessToken(GetCurrentProcess(),
        TOKEN_ADJUST_PRIVILEGES|TOKEN_QUERY,&hToken))   
    {
        printf("OpenProcessToken is Error\n");
        return false;
    }
    if (!LookupPrivilegeValue(NULL,SE_DEBUG_NAME,&uID))   //调式
    {
        printf("LookupPrivilegeValue is Error\n");
        return false;
    }
    pTP.PrivilegeCount = 1;
    pTP.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    pTP.Privileges[0].Luid = uID;
    //在这里我们进行调整权限
    if (!AdjustTokenPrivileges(hToken,false,&pTP,sizeof(TOKEN_PRIVILEGES),NULL,NULL))
    {
        printf("AdjuestTokenPrivileges is Error\n");
        return  false;
    }
    return true;
}
