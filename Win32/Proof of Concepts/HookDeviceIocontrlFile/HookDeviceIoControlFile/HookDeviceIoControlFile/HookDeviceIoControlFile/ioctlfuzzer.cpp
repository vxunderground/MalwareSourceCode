#include "stdafx.h"

//unresolved external symbol __imp__StrToIntExA@12
#pragma comment(lib, "Shlwapi.lib")
//unresolved external symbol _VerQueryValueA@16
#pragma comment(lib, "version.lib")
//unresolved external symbol __imp__InitCommonControls@0
#pragma comment(lib, "comctl32.lib") 

#ifdef _AMD64_
#pragma comment(lib,"dbgsdk\\lib\\amd64\\dbghelp.lib") 
#pragma comment(lib, "lib\\amd64\\comsupp.lib")
#else
#pragma comment(lib,"dbgsdk\\lib\\i386\\dbghelp.lib") 
#pragma comment(lib, "lib\\comsupp.lib")
#endif

//

#define RESOURCE_NAME_DRIVER32 "DRIVER32"
#define RESOURCE_NAME_DRIVER64 "DRIVER64"

#define GLOBAL_MUTEX_NAME "Global\\" DRIVER_SERVICE_NAME "_Mutex"

USER_MODE_DATA m_UserModeData;
DWORD m_dwFuzzThreadId = 0;
HANDLE hDevice = NULL;

// fuzzing type and other actual options
FUZZING_TYPE m_FuzzingType = DEFAULT_FUZZING_TYPE;
DWORD m_dwOptions = 0;

// don't install any hooks (usefull for attack surface analysis feature)
BOOL m_bNoHooks = FALSE;

// TRUE if remote kernel debugger is not present
BOOL m_bDebuggerNotPresent = FALSE;

// defined in debug.cpp
extern HANDLE hDbgLogfile;

BOOL m_bBoot = FALSE;
/**
* kernel32!Get[Set]ConsoleScreenBufferInfoEx() functions prsent
* only on NT 6.x
*/
typedef BOOL (WINAPI * GET_SET_CONSOLE_SCREEN_BUFFER_INFO_EX)(
    HANDLE hConsoleOutput,
    PCONSOLE_SCREEN_BUFFER_INFOEX lpConsoleScreenBufferInfoEx
);
//--------------------------------------------------------------------------------------
BOOL GetOption(IXMLDOMNode *pIDOMNode, PWSTR lpwcName, PBOOL pbVal)
{
    BOOL bRet = FALSE;
    char *lpszVal = NULL;

    if (ConfAllocGetTextByNameA(pIDOMNode, lpwcName, &lpszVal))
    {
        bRet = TRUE;

        if (!strcmp(strlwr(lpszVal), "true"))
        {
            *pbVal = TRUE;
        }
        else if (!strcmp(strlwr(lpszVal), "false"))
        {
            *pbVal = FALSE;
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "WARNING: invalid value for option '%ws'\r\n", lpwcName);
            bRet = FALSE;
        }

        M_FREE(lpszVal);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
void ParseAllowDenySection(IXMLDOMNode *pIDOMNode, BOOL bAllow, BOOL bDbgcbAction)
{
    struct  
    {
        LPCWSTR lpNodeName;
        LPCWSTR lpObjectName;
        ULONG Code;

    } Objects[] = {

        { L"drivers",   L"driver",      C_ADD_DRIVER    },
        { L"devices",   L"device",      C_ADD_DEVICE    },
        { L"ioctls",    L"ioctl",       C_ADD_IOCTL     },
        { L"processes", L"process",     C_ADD_PROCESS   },
        { NULL,         NULL,           0               }
    };

    /*
        Old-style allow/deny lists parsing:
        --------------------------------------

        <objects>
          <object>SomeName_1</object>
          <object>SomeName_2</object>
          ...
          <object>SomeName_N</object>
        </objects>
    */
    for (int ob = 0; Objects[ob].lpNodeName != NULL; ob++)
    {
        // get objects list node
        IXMLDOMNode *pIDOMObjectsNode = ConfGetNodeByName((BSTR)Objects[ob].lpNodeName, pIDOMNode);
        if (pIDOMObjectsNode)                
        {
            IXMLDOMNodeList *pIDOMNodeList = NULL;

            // enumerate available object names
            HRESULT hr = pIDOMObjectsNode->get_childNodes(&pIDOMNodeList);
            if (SUCCEEDED(hr))
            {
                LONG len = 0;
                pIDOMNodeList->get_length(&len);

                DbgMsg(__FILE__, __LINE__, "\"%ws\":\r\n", Objects[ob].lpNodeName);

                for (int i = 0; i < len; i++)
                { 
                    IXMLDOMNode *pIDOMChildNode = NULL;

                    // get single object name
                    hr = pIDOMNodeList->get_item(i, &pIDOMChildNode);
                    if (SUCCEEDED(hr))
                    {
                        char *lpszObjectName = NULL;
                        if (ConfGetNodeTextA(pIDOMChildNode, &lpszObjectName))
                        {
                            REQUEST_BUFFER Buff;
                            ZeroMemory(&Buff, sizeof(Buff));
                            Buff.Code = Objects[ob].Code;
                            Buff.AddObject.bAllow = bAllow;

                            if (Objects[ob].Code == C_ADD_IOCTL)
                            {
                                DWORD dwIoctlCode = 0;

                                // parse hexadecimal IOCTL code value
                                if (StrToIntEx(lpszObjectName, STIF_SUPPORT_HEX, (int *)&dwIoctlCode))
                                {
                                    DbgMsg(__FILE__, __LINE__, " - 0x%.8x\r\n", dwIoctlCode);                                        

                                    Buff.AddObject.IoctlCode = dwIoctlCode;
                                    DrvDeviceRequest(&Buff, sizeof(Buff));
                                }                                    
                                else
                                {
                                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): StrToIntEx() ERROR %d\n", GetLastError());
                                }
                            }
                            else
                            {
                                DbgMsg(__FILE__, __LINE__, " - \"%s\"\r\n", lpszObjectName);

                                // object name is a string value (process/driver/device name)
                                lstrcpy(Buff.AddObject.szObjectName, lpszObjectName);
                                DrvDeviceRequest(&Buff, sizeof(Buff));
                            }                                

                            M_FREE(lpszObjectName);
                        }

                        pIDOMChildNode->Release();                                
                    }
                }                        

                pIDOMNodeList->Release();
            }

            pIDOMObjectsNode->Release();
        }
    } 

    /*
        New allow/deny lists parsing:
        --------------------------------------

        <object_type val="SomeName_1" />
        <object_type val="SomeName_2" />          
        ...
        <object_type val="SomeName_N" />
    */    

    // enumerate available objects
    IXMLDOMNodeList *pIDOMNodeList = NULL;
    HRESULT hr = pIDOMNode->get_childNodes(&pIDOMNodeList);
    if (SUCCEEDED(hr))
    {
        LONG len = 0;
        pIDOMNodeList->get_length(&len);

        for (int i = 0; i < len; i++)
        { 
            IXMLDOMNode *pIDOMChildNode = NULL;

            // get single object node
            hr = pIDOMNodeList->get_item(i, &pIDOMChildNode);
            if (SUCCEEDED(hr))
            {
                // get node name (object type)
                BSTR ChildNodeName = NULL;
                hr = pIDOMChildNode->get_nodeName(&ChildNodeName);
                if (SUCCEEDED(hr))
                {
                    // lookup object type by name
                    for (int ob = 0; Objects[ob].lpObjectName != NULL; ob++)
                    {
                        if (!wcscmp(Objects[ob].lpObjectName, ChildNodeName))
                        {
                            DWORD dwOptionalBuffLen = 0;
                            char *lpszObjectName = NULL, *lpszOptionalBuff = NULL;

                            /*
                                Query node value: for dbgcb objects list it contains
                                debugger command, that must be executet for each IOCTL, 
                                matched by this object.
                            */
                            if (bDbgcbAction &&
                                ConfGetNodeTextA(pIDOMChildNode, &lpszOptionalBuff) && 
                                lpszOptionalBuff)
                            {
                                dwOptionalBuffLen = (DWORD)strlen(lpszOptionalBuff) + 1;
                            }

                            if (ConfGetNodeAttributeA(pIDOMChildNode, L"val", &lpszObjectName))
                            {
                                DWORD dwBuffSize = sizeof(REQUEST_BUFFER) + dwOptionalBuffLen;
                                PREQUEST_BUFFER Buff = (PREQUEST_BUFFER)M_ALLOC(dwBuffSize);
                                if (Buff)
                                {
                                    ZeroMemory(Buff, dwBuffSize);
                                    Buff->Code = Objects[ob].Code;
                                    Buff->AddObject.bAllow = bAllow;
                                    Buff->AddObject.bDbgcbAction = bDbgcbAction;

                                    if (lpszOptionalBuff)
                                    {
                                        lstrcpy(Buff->Buff, lpszOptionalBuff);
                                    }

                                    if (Objects[ob].Code == C_ADD_IOCTL)
                                    {
                                        DWORD dwIoctlCode = 0;

                                        // parse hexadecimal IOCTL code value
                                        if (StrToIntEx(lpszObjectName, STIF_SUPPORT_HEX, (int *)&dwIoctlCode))
                                        {
                                            if (bDbgcbAction)
                                            {
                                                DbgMsg(
                                                    __FILE__, __LINE__, "Object=\"%ws\" Value=0x%.8x KdCommand=\"%s\"\r\n",
                                                    Objects[ob].lpObjectName, dwIoctlCode,
                                                    lpszOptionalBuff ? lpszOptionalBuff : "<BREAK>"
                                                );
                                            }
                                            else
                                            {
                                                DbgMsg(
                                                    __FILE__, __LINE__, "Object=\"%ws\" Value=0x%.8x\r\n",
                                                    Objects[ob].lpObjectName, dwIoctlCode
                                                );
                                            }                                            

                                            Buff->AddObject.IoctlCode = dwIoctlCode;
                                            DrvDeviceRequest(Buff, dwBuffSize);
                                        }                                    
                                        else
                                        {
                                            DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): StrToIntEx() ERROR %d\n", GetLastError());
                                        }
                                    }
                                    else
                                    {
                                        if (bDbgcbAction)
                                        {
                                            DbgMsg(
                                                __FILE__, __LINE__, "Object=\"%ws\" Value=\"%s\" KdCommand=\"%s\"\r\n", 
                                                Objects[ob].lpObjectName, lpszObjectName,
                                                lpszOptionalBuff ? lpszOptionalBuff : "<BREAK>"
                                            );
                                        }
                                        else
                                        {
                                            DbgMsg(
                                                __FILE__, __LINE__, "Object=\"%ws\" Value=\"%s\"\r\n", 
                                                Objects[ob].lpObjectName, lpszObjectName
                                            );
                                        }                                        

                                        // object name is a string value (process/driver/device name)
                                        lstrcpy(Buff->AddObject.szObjectName, lpszObjectName);
                                        DrvDeviceRequest(Buff, dwBuffSize);
                                    }                                

                                    M_FREE(Buff);
                                }
                                else
                                {
                                    DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\r\n", GetLastError());
                                }

                                M_FREE(lpszObjectName);
                            }

                            if (lpszOptionalBuff)
                            {
                                M_FREE(lpszOptionalBuff);
                            }

                            break;
                        }
                    }
                }                

                if (ChildNodeName)
                {
                    SysFreeString(ChildNodeName);
                }

                pIDOMChildNode->Release();                                
            }
        }                        

        pIDOMNodeList->Release();
    }
}
//--------------------------------------------------------------------------------------
BOOL SetOptions(DWORD dwOptions, FUZZING_TYPE FuzzingType)
{
    REQUEST_BUFFER Buff;
    ZeroMemory(&Buff, sizeof(Buff));

    Buff.Code = C_SET_OPTIONS;
    Buff.Options.Options = dwOptions;
    Buff.Options.FuzzingType = FuzzingType;
    Buff.Options.UserModeData = &m_UserModeData;
    Buff.Options.FuzzThreadId = m_dwFuzzThreadId;

    m_dwOptions = dwOptions;
    m_FuzzingType = FuzzingType;

    // send options to the driver
    return DrvDeviceRequest(&Buff, sizeof(REQUEST_BUFFER));
}
//--------------------------------------------------------------------------------------
BOOL SetDefaultOptions(void)
{
    DWORD dwOptions = FUZZ_OPT_LOG_DEBUG;

    dwOptions |= FUZZ_OPT_LOG_IOCTL;
    dwOptions |= FUZZ_OPT_LOG_IOCTL_GLOBAL;

    if (m_bNoHooks)
    {
        dwOptions |= FUZZ_OPT_NO_SDT_HOOKS;
    }

    // send options to the driver
    return SetOptions(dwOptions, DEFAULT_FUZZING_TYPE);
}
//--------------------------------------------------------------------------------------
BOOL ParseConfig(char *lpszCfgFileName)
{
    PVOID Data = NULL;
    DWORD dwDataSize = 0;
    BOOL bRet = FALSE;

    // read config file
    if (ReadFromFile(lpszCfgFileName, &Data, &dwDataSize))
    {
        PWSTR lpwcData = (PWSTR)M_ALLOC((dwDataSize + 1) * sizeof(WCHAR));
        if (lpwcData)
        {
            MultiByteToWideChar(CP_ACP, 0, (char *)Data, dwDataSize, lpwcData, dwDataSize);            
                        
            IXMLDOMNode *pIDOMRootNode = NULL;
            IXMLDOMDocument *pXMLDoc = NULL;

            // load xml document
            if (XmlLoad(lpwcData, &pXMLDoc, &pIDOMRootNode, L"cfg"))
            {
                // create logfile, if option is set
                char *lpszLogFilePath = NULL;
                if (ConfAllocGetTextByNameA(pIDOMRootNode, L"log_file", &lpszLogFilePath))
                {
                    HANDLE hNewLogfile = CreateFile(
                        lpszLogFilePath, 
                        GENERIC_READ | GENERIC_WRITE, 
                        FILE_SHARE_READ | FILE_SHARE_WRITE, 
                        NULL, 
                        OPEN_ALWAYS, 
                        FILE_ATTRIBUTE_NORMAL, 
                        NULL
                    );
                    if (hNewLogfile != INVALID_HANDLE_VALUE)
                    {
                        SetFilePointer(hNewLogfile, 0, NULL, FILE_END);

                        if (hDbgLogfile != INVALID_HANDLE_VALUE)
                        {   
                            // close old debug log
                            CloseHandle(hDbgLogfile);
                            hDbgLogfile = hNewLogfile;
                        }
                    }
                    else
                    {
                        DbgMsg(__FILE__, __LINE__, "CreateFile() ERROR %d\r\n", GetLastError());
                        DbgMsg(__FILE__, __LINE__, "Error while creating/opening logfile at '%s'.\r\n", lpszLogFilePath);
                    }

                    M_FREE(lpszLogFilePath);
                }

                // parse allowed objects list
                IXMLDOMNode *pIDOMAllowNode = ConfGetNodeByName(L"allow", pIDOMRootNode);
                if (pIDOMAllowNode)                
                {
                    ParseAllowDenySection(pIDOMAllowNode, TRUE, FALSE);
                    pIDOMAllowNode->Release();
                }

                // parse denied objects list
                IXMLDOMNode *pIDOMDenyNode = ConfGetNodeByName(L"deny", pIDOMRootNode);
                if (pIDOMDenyNode)                
                {
                    ParseAllowDenySection(pIDOMDenyNode, FALSE, FALSE);
                    pIDOMDenyNode->Release();
                }

                if (!m_bDebuggerNotPresent)
                {
                    // parse debugger communication engine options
                    IXMLDOMNode *pIDOMDbgcbNode = ConfGetNodeByName(L"dbgcb", pIDOMRootNode);
                    if (pIDOMDbgcbNode)                
                    {
                        ParseAllowDenySection(pIDOMDbgcbNode, FALSE, TRUE);
                        pIDOMDbgcbNode->Release();
                    }
                }                

                // parse options
                BOOL bLogRequests = TRUE, bDebugLogRequests = TRUE;               
                BOOL bHexDump = FALSE;
                DWORD dwOptions = FUZZ_OPT_LOG_IOCTL_GLOBAL;
                FUZZING_TYPE FuzzingType = DEFAULT_FUZZING_TYPE;  

                GetOption(pIDOMRootNode, L"hex_dump", &bHexDump);
                GetOption(pIDOMRootNode, L"log_requests", &bLogRequests);
                GetOption(pIDOMRootNode, L"debug_log_requests", &bDebugLogRequests);
                GetOption(pIDOMRootNode, L"boot_log", &m_bBoot);

                DbgMsg(__FILE__, __LINE__, "PROGRAM OPTIONS:\r\n");

                #define STROPT(_x_) ((_x_) ? "Yes" : "No")

                DbgMsg(__FILE__, __LINE__, "           'hex_dump': %s\r\n", STROPT(bHexDump));
                DbgMsg(__FILE__, __LINE__, "       'log_requests': %s\r\n", STROPT(bLogRequests));
                DbgMsg(__FILE__, __LINE__, " 'debug_log_requests': %s\r\n", STROPT(bDebugLogRequests));
                DbgMsg(__FILE__, __LINE__, "              'bBoot': %s\r\n", STROPT(m_bBoot));

                if (bHexDump)
                {
                    dwOptions |= FUZZ_OPT_LOG_IOCTL_BUFFERS;
                }

                if (bLogRequests)
                {
                    dwOptions |= FUZZ_OPT_LOG_IOCTL;
                }

                if (bDebugLogRequests)
                {
                    dwOptions |= FUZZ_OPT_LOG_DEBUG;
                }

                if (m_bBoot)
                {
                    dwOptions |= FUZZ_OPT_FUZZ_BOOT;
                }

                // send options to the driver
                bRet = SetOptions(dwOptions, FuzzingType);

                pIDOMRootNode->Release();
                pXMLDoc->Release();
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\r\n", GetLastError());
        }

        M_FREE(Data);
    }

    if (!bRet)
    {
        SetDefaultOptions();
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
DWORD WINAPI ApcThread(LPVOID lpParam)
{
    while (true)
    {
        SleepEx(INFINITE, TRUE);
    }

    return 0;
}
//--------------------------------------------------------------------------------------
BOOL WINAPI CtrlHandler(DWORD fdwCtrlType) 
{ 
    if (fdwCtrlType == CTRL_C_EVENT || 
        fdwCtrlType == CTRL_CLOSE_EVENT) 
    { 
        // Handle the CTRL-C signal. 
        DbgMsg(__FILE__, __LINE__, "Stopping application, please wait...\r\n");

        ExitProcess(0);

        return TRUE;
    } 

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOL GetResPayload(HMODULE hModule, char *lpszResourceName, PVOID *Data, DWORD *dwDataSize)
{
    HRSRC hRc = FindResource(hModule, lpszResourceName, "BINRES");
    if (hRc)
    {
        HGLOBAL hResData = LoadResource(hModule, hRc);
        if (hResData)
        {
            PVOID ResData = LockResource(hResData);
            if (ResData)
            {
                *dwDataSize = SizeofResource(hModule, hRc);
                if (*Data = M_ALLOC(*dwDataSize))
                {
                    memcpy(*Data, ResData, *dwDataSize);
                    return TRUE;
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\r\n", GetLastError());
                }                
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "LockResource() fails\r\n");
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "LoadResource() fails\r\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "FindResource() fails\r\n");
    }

    return FALSE;
} 
//--------------------------------------------------------------------------------------
#define CHECK_SET(_item_) SendMessage(GetDlgItem(hDlg, (_item_)), BM_SETCHECK, BST_CHECKED, 0)
#define CHECK_UNSET(_item_) SendMessage(GetDlgItem(hDlg, (_item_)), BM_SETCHECK, BST_UNCHECKED, 0)
#define CHECK_GET(_item_) (SendMessage(GetDlgItem(hDlg, (_item_)), BM_GETCHECK, BST_CHECKED, 0) == BST_CHECKED)

LRESULT CALLBACK MainDlg(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    DWORD dwOptions = FUZZ_OPT_LOG_IOCTL_GLOBAL;
    FUZZING_TYPE FuzzingType = DEFAULT_FUZZING_TYPE;

    switch (message)
    {

    case WM_INITDIALOG:
        {
            /**
             * Initialize chekboxes for fuzzing options.
             */
            if (m_dwOptions & FUZZ_OPT_LOG_IOCTL)
            {
                CHECK_SET(IDC_LOG_CONSOLE);
            }

            if (m_dwOptions & FUZZ_OPT_LOG_DEBUG)
            {
                CHECK_SET(IDC_LOG_DEBUGGER);
            }

            if (m_dwOptions & FUZZ_OPT_LOG_IOCTL_BUFFERS)
            {
                CHECK_SET(IDC_LOG_BUFFERS);
            }
            break;
        }

    case WM_COMMAND:
        {
            switch (wParam)
            {
            case IDC_HIDE:

                ShowWindow(hDlg, SW_HIDE);
                break;

            case IDC_TERMINATE:

                DestroyWindow(hDlg);
                break;

            case IDC_LOG_CONSOLE:
            case IDC_LOG_DEBUGGER:
            case IDC_LOG_BUFFERS:
                /**
                 * Get controls state.
                 */

                if (CHECK_GET(IDC_LOG_CONSOLE))
                {
                    dwOptions |= FUZZ_OPT_LOG_IOCTL;
                }

                if (CHECK_GET(IDC_LOG_DEBUGGER))
                {
                    dwOptions |= FUZZ_OPT_LOG_DEBUG;
                }

                if (CHECK_GET(IDC_LOG_BUFFERS))
                {
                    dwOptions |= FUZZ_OPT_LOG_IOCTL_BUFFERS;
                }

                // update fuzzing type and settings
                SetOptions(dwOptions, FuzzingType);
                
                break;
            }

            break;
        }

    case WM_CLOSE:
        {
            DestroyWindow(hDlg);
            break;
        }
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
int _tmain(int argc, _TCHAR* argv[])
{
    char szDriverFileName[MAX_PATH] = {0};
    char szServiceFileName[MAX_PATH] = {0};
   
    BOOL bUninstall = FALSE, bShowExceptions = FALSE, bPrintDevices = FALSE;

    InitCommonControls();

    GetSystemDirectory(szDriverFileName, sizeof(szDriverFileName));
    lstrcat(szDriverFileName, "\\drivers\\" DRIVER_FILE_NAME);
    lstrcpy(szServiceFileName, "system32\\drivers\\" DRIVER_FILE_NAME);

    HANDLE hGlobalMutex = CreateMutex(NULL, FALSE, GLOBAL_MUTEX_NAME);

    char lpszConfigPath[MAX_PATH] = {0};
    GetCurrentDirectory(sizeof(lpszConfigPath), lpszConfigPath);
    lstrcat(lpszConfigPath, "\\ioctlfuzzer.xml");

    // check for allready running application
    if (GetLastError() == ERROR_ALREADY_EXISTS)
    {
        MessageBox(
            0, 
            "One copy of program is allready running.\n",
            "ERROR",
            MB_ICONERROR
        );

        ExitProcess(0);
    }

#if defined(_X86_)

    BOOL bIs64 = FALSE;

    typedef BOOL (WINAPI * func_IsWow64Process)(
        HANDLE hProcess,
        PBOOL Wow64Process
    );

    func_IsWow64Process f_IsWow64Process = (func_IsWow64Process)GetProcAddress(
        GetModuleHandleA("kernel32.dll"), 
        "IsWow64Process"
    );
    if (f_IsWow64Process)
    {
        // check for WoW64 environment
        if (f_IsWow64Process(GetCurrentProcess(), &bIs64) && bIs64)
        {
            MessageBoxA(
                0, 
                "You should use x64 version of program on Windows x64.\n"
                "<OK> to exit.",
                "ERROR", MB_ICONWARNING
            );

            ExitProcess(0);
        }
    }

#endif // _X86_

    DbgInit(DBG_PIPE_NAME_A, IOCTLFUZZER_LOG_FILE);

    PSYSTEM_KERNEL_DEBUGGER_INFORMATION DebuggerInfo = (PSYSTEM_KERNEL_DEBUGGER_INFORMATION)
        GetSysInf(SystemKernelDebuggerInformation);
    if (DebuggerInfo)
    {
        // check for remote kernel debugger
        if (!DebuggerInfo->DebuggerEnabled ||
            DebuggerInfo->DebuggerNotPresent)
        {
            if (MessageBox(
                0,
                "Warning!\r\n"
                "Kernel debugger is not present, IOCTL Fuzzer may cause a BSoD.\r\n"
                "Continue execution?",
                "Warning", MB_YESNO | MB_ICONWARNING | MB_TOPMOST) == IDNO)
            {
                ExitProcess(0);
            }
        }

        M_FREE(DebuggerInfo);
    }

    GET_SET_CONSOLE_SCREEN_BUFFER_INFO_EX f_GetConsoleScreenBufferInfoEx = 
        (GET_SET_CONSOLE_SCREEN_BUFFER_INFO_EX)GetProcAddress(
        GetModuleHandle("kernel32.dll"), 
        "GetConsoleScreenBufferInfoEx"
    );

    GET_SET_CONSOLE_SCREEN_BUFFER_INFO_EX f_SetConsoleScreenBufferInfoEx = 
        (GET_SET_CONSOLE_SCREEN_BUFFER_INFO_EX)GetProcAddress(
        GetModuleHandle("kernel32.dll"), 
        "SetConsoleScreenBufferInfoEx"
    );

    if (f_GetConsoleScreenBufferInfoEx &&
        f_SetConsoleScreenBufferInfoEx)
    {
        HANDLE hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
        CONSOLE_SCREEN_BUFFER_INFOEX ConsoleInfo;
        ConsoleInfo.cbSize = sizeof(ConsoleInfo);

        if (f_GetConsoleScreenBufferInfoEx(hConsoleOutput, &ConsoleInfo))
        {
            DbgMsg(
                __FILE__, __LINE__, "[+] Changing console screen buffer height from %d to %d lines\n",
                ConsoleInfo.dwSize.Y, CONSOLE_BUFFER_HEIGHT
            );
            
            ConsoleInfo.dwSize.Y = CONSOLE_BUFFER_HEIGHT;

            // we don't need horizontal scroll bar
            ConsoleInfo.dwSize.X -= 1;

            if (!f_SetConsoleScreenBufferInfoEx(hConsoleOutput, &ConsoleInfo))
            {
                DbgMsg(__FILE__, __LINE__, "SetConsoleScreenBufferInfoEx() ERROR %d\n", GetLastError());
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "GetConsoleScreenBufferInfoEx() ERROR %d\n", GetLastError());
        }
    } 

    if (!LoadPrivileges(SE_LOAD_DRIVER_NAME))
    {
        DbgMsg(__FILE__, __LINE__, "Error while loading 'SeLoadDriverPrivilege'\r\n");
        goto end;
    }


    PVOID DriverData = NULL;
    DWORD dwDriverDataSize = 0;

    // extract kernel driver from resources
#if defined(_X86_)
    if (GetResPayload(GetModuleHandle(NULL), RESOURCE_NAME_DRIVER32, &DriverData, &dwDriverDataSize))
#else
    if (GetResPayload(GetModuleHandle(NULL), RESOURCE_NAME_DRIVER64, &DriverData, &dwDriverDataSize))
#endif
    {
        // ... and dump it to the disk
        if (!DumpToFile(szDriverFileName, DriverData, dwDriverDataSize))
        {
            DbgMsg(__FILE__, __LINE__, "Error while creating kernel driver file.\r\n");
            goto end;
        }

        M_FREE(DriverData);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "Error while extracting kernel driver from resources.\r\n");
        goto end;
    }

    if (!DrvServiceStart(DRIVER_SERVICE_NAME, szDriverFileName, NULL))
    {
        DbgMsg(__FILE__, __LINE__, "Error while creating/starting system service for kernel driver.\r\n");
        goto end;
    }

    if (m_bBoot)
    {
        if (!DrvServiceSetStartType(DRIVER_SERVICE_NAME, SERVICE_BOOT_START))
        {
            DbgMsg(__FILE__, __LINE__, "Error while changing service startup type.\r\n");
            goto end;
        }

        DbgMsg(__FILE__, __LINE__, "Service startup type has been set to the SERVICE_BOOT_START.\r\n");
    }
    else
    {
        if (!DrvServiceSetStartType(DRIVER_SERVICE_NAME, SERVICE_DEMAND_START))
        {
            DbgMsg(__FILE__, __LINE__, "Error while changing service startup type.\r\n");
            goto end;
        }
    }

    // create thread for kernel mode APC's
    HANDLE hThread = CreateThread(NULL, 0, ApcThread, NULL, 0, &m_dwFuzzThreadId);
    if (hThread)
    {
        DbgMsg(__FILE__, __LINE__, "Thread for kernel mode APC's created (ID: %x)\r\n", m_dwFuzzThreadId);
        CloseHandle(hThread);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "CreateThread() ERROR %d\r\n", GetLastError());
    }    

    if (DrvOpenDevice(DEVICE_NAME, &hDevice))
    {
        /**
         * Fuzzing or monitoring mode
         */
        REQUEST_BUFFER Buff;
        ZeroMemory(&Buff, sizeof(Buff));
        Buff.Code = C_DEL_OPTIONS;

        // delete previously saved fuzing/minitoring options
        DrvDeviceRequest(&Buff, sizeof(REQUEST_BUFFER));

        if (lpszConfigPath)
        {
            ParseConfig(lpszConfigPath);            
        }
        else
        {
            SetDefaultOptions();
        }

        SetConsoleCtrlHandler(CtrlHandler, TRUE);
            
        DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_DIALOG), NULL, (DLGPROC)MainDlg);      

        BOOL bStopService = TRUE;
        ZeroMemory(&Buff, sizeof(Buff));
        Buff.Code = C_CHECK_HOOKS;

        // check for installed hooks
        if (DrvDeviceRequest(&Buff, sizeof(REQUEST_BUFFER)) &&
            Buff.CheckHooks.bHooksInstalled)
        {
            bStopService = FALSE;

            if (MessageBox(
                0,
                "Warning!\r\n"
                "Unloading of a kernel driver may be unsafe.\r\n"
                "Press <YES> to unload it, or <NO> for just a program termination.",
                "Exit from program", MB_YESNO | MB_ICONWARNING | MB_TOPMOST) == IDYES)
            {
                bStopService = TRUE;                
            }
        }

        CloseHandle(hDevice);

        if (bStopService)
        {
            DrvServiceStop(DRIVER_SERVICE_NAME);
        }

        if (bPrintDevices)
        {
            goto end;
        }

        ExitProcess(0);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "Error while opening kernel driver communication device\r\n");
    }   

    DrvServiceStop(DRIVER_SERVICE_NAME);    

end:
    printf("Press any key to quit...\r\n");
    getch();

    return 0;
}
//--------------------------------------------------------------------------------------
// EoF
