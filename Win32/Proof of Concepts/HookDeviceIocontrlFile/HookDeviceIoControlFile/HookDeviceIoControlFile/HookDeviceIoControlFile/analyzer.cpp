#include "stdafx.h"

typedef struct _DRVINFO
{
    PVOID Object;

    std::string ObjectName;
    std::string FilePath;

    std::string Descr;
    std::string Company;

} DRVINFO,
*PDRVINFO;

typedef enum _DEVINFO_ACCESS
{
    DevAccessOpenError = 0,
    DevAccessEveryone,
    DevAccessAuthenticated,
    DevAccessRestricted

} DEVINFO_ACCESS;

typedef struct _DEVINFO
{
    PVOID Object;
    std::string ObjectName;
    DEVINFO_ACCESS Access;

} DEVINFO,
*PDEVINFO;

typedef struct _PROCESSINFO
{
    DWORD ProcessId;
    std::string ProcessName;    

} PROCESSINFO,
*PPROCESSINFO;

#define DEVINFO_LIST std::map<PVOID, DEVINFO>
#define DRVINFO_ENTRY std::pair<DRVINFO, DEVINFO_LIST>
#define DRVINFO_LIST std::map<PVOID, DRVINFO_ENTRY>
#define CALL_STATS_LIST std::map<std::string, DWORD>
#define OPENED_LIST std::map<std::string, std::list<PROCESSINFO>>

DRVINFO_LIST m_DriversInfo;

// total number of sniffed IOCTLs for each device and driver
CALL_STATS_LIST m_DeviceCallsCount;
CALL_STATS_LIST m_DriverCallsCount;

// information about opened devices
OPENED_LIST m_OpenedInfo;
//--------------------------------------------------------------------------------------
DWORD GetObjectTypeIndex(HANDLE hObject)
{
    DWORD Ret = 0;

    // get list of all handles in system
    PSYSTEM_HANDLE_INFORMATION Info = (PSYSTEM_HANDLE_INFORMATION)GetSysInf(SystemHandleInformation);
    if (Info)
    {        
        // find our handle in list
        for (ULONG i = 0; i < Info->NumberOfHandles; i++)
        {
            if (Info->Handles[i].UniqueProcessId == (USHORT)GetCurrentProcessId() &&
                Info->Handles[i].HandleValue == (USHORT)hObject)
            {
                // return value of object type index
                Ret = Info->Handles[i].ObjectTypeIndex;
                break;
            }
        }

        M_FREE(Info);
    }

    return Ret;
}
//--------------------------------------------------------------------------------------
DWORD GetFileObjectTypeIndex(void)
{
    DWORD Ret = 0;
    char szSelf[MAX_PATH];
    GetModuleFileNameA(GetModuleHandle(NULL), szSelf, MAX_PATH);

    HANDLE hFile = CreateFileA(
        szSelf, 
        GENERIC_READ,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL,
        OPEN_EXISTING,
        0, NULL
    );
    if (hFile == INVALID_HANDLE_VALUE)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): CreateFile() ERROR %d\n", GetLastError());
        return 0;
    }

    Ret = GetObjectTypeIndex(hFile);

    CloseHandle(hFile);

    return Ret;
}
//--------------------------------------------------------------------------------------
DWORD CollectFileHandles(void)
{
    DWORD dwRet = 0;
    DWORD dwTypeIndex = GetFileObjectTypeIndex();
    if (dwTypeIndex == 0)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't query file object type index\n");
        return 0;
    }

    // remove old entries
    m_OpenedInfo.clear();

    // get list of all handles in system
    PSYSTEM_HANDLE_INFORMATION Info = (PSYSTEM_HANDLE_INFORMATION)GetSysInf(SystemHandleInformation);
    if (Info)
    {        
        // find all processes handles
        for (ULONG i = 0; i < Info->NumberOfHandles; i++)
        {
            char szProcessName[MAX_PATH];
            DWORD dwProcessId = (DWORD)Info->Handles[i].UniqueProcessId;

            if (Info->Handles[i].ObjectTypeIndex == (USHORT)dwTypeIndex &&
                GetProcessNameById(dwProcessId, szProcessName, MAX_PATH))
            {
                HANDLE hProcess = OpenProcess(PROCESS_DUP_HANDLE, FALSE, dwProcessId);
                if (hProcess)
                {
                    // duplicate single handle
                    HANDLE hTarget = NULL;
                    if (DuplicateHandle(
                        hProcess,
                        (HANDLE)Info->Handles[i].HandleValue,
                        GetCurrentProcess(),
                        &hTarget,
                        0, FALSE,
                        DUPLICATE_SAME_ACCESS))
                    {
                        REQUEST_BUFFER Request;
                        ZeroMemory(&Request, sizeof(Request));                        

                        Request.Code = C_GET_OBJECT_NAME;
                        Request.ObjectName.hObject = hTarget;

                        // get device name by handle
                        if (DrvDeviceRequest(&Request, sizeof(Request)) && 
                            Request.Status == S_SUCCESS)
                        {
                            try
                            {
                                std::string ObjectName = std::string(Request.ObjectName.szObjectName);                            

                                if (m_OpenedInfo.find(ObjectName) != m_OpenedInfo.end())
                                {
                                    std::list<PROCESSINFO>::iterator e = m_OpenedInfo[ObjectName].begin();
                                    while (e != m_OpenedInfo[ObjectName].end())
                                    {
                                        if (e->ProcessId == dwProcessId)
                                        {
                                            // this process is allready in list
                                            goto close;
                                        }

                                        ++e;
                                    }
                                }

                                PROCESSINFO ProcessInfo;
                                ProcessInfo.ProcessId = dwProcessId;
                                ProcessInfo.ProcessName = std::string(szProcessName);
                                m_OpenedInfo[ObjectName].push_back(ProcessInfo);
                            }
                            catch (...)
                            {

                            }                            

                            DbgMsg(
                                __FILE__, __LINE__, "Process=\"%s\" PID=%d Handle=0x%.8x \"%s\"\n",
                                szProcessName, dwProcessId, (DWORD)Info->Handles[i].HandleValue,
                                Request.ObjectName.szObjectName
                            );
                        }
close:
                        CloseHandle(hTarget);
                    }
                    else
                    {
                        DbgMsg(__FILE__, __LINE__, "DuplicateHandle() ERROR %d\n", GetLastError());
                    }

                    CloseHandle(hProcess);
                } 
            }
        }

        M_FREE(Info);
    }    

    return dwRet;
}
//--------------------------------------------------------------------------------------
char *GetNormalizedDriverFilePath(char *lpszPath)
{
    char szSysDir[MAX_PATH], szSysDir_l[MAX_PATH];
    GetSystemDirectoryA(szSysDir, sizeof(szSysDir));
    strcpy(szSysDir_l, szSysDir);
    strlwr(szSysDir_l);

    char *s = NULL;
    char *lpszSysDirName_l = GetNameFromFullPath(szSysDir_l);

    size_t Path_lSize = strlen(lpszPath) + 1;
    char *lpszPath_l = (char *)M_ALLOC(Path_lSize);
    if (lpszPath_l)
    {
        // low-case duplicates of strings need only for matching
        strcpy(lpszPath_l, lpszPath);
        strlwr(lpszPath_l);

        // normalize module name
        if (!strncmp(lpszPath, "\\??\\", 4))
        {
            // '\??\C:\WINDOWS\path_to_module'
            size_t len = strlen(lpszPath) - 3;
            if (s = (char *)M_ALLOC(len))
            {
                strcpy(s, lpszPath + 4);
            }
        }
        else if (!strncmp(lpszPath_l, "\\systemroot\\", 12))
        {
            // '\SystemRoot\WINDOWS\path_to_module'
            char szPath[MAX_PATH];            
            GetEnvironmentVariableA("SystemRoot", szPath, MAX_PATH - 1);

            size_t len = strlen(szPath) + strlen(lpszPath + 11) + 1;
            if (s = (char *)M_ALLOC(len))
            {
                strcpy(s, szPath);
                strcat(s, lpszPath + 11);
            }
        }
        else if (GetNameFromFullPath(lpszPath) == lpszPath)
        {   
            // just module name
            size_t len = strlen(szSysDir) + strlen(lpszPath) + 0x20;
            if (s = (char *)M_ALLOC(len))
            {
                strcpy(s, szSysDir);
                strcat(s, "\\drivers\\");
                strcat(s, lpszPath);

                // look for this module in drivers directory
                if (!IsFileExists(s))
                {
                    M_FREE(s);
                    s = NULL;
                }                
            }                               
        }
        else if (
            szSysDir[1] == ':' &&
            !strncmp(lpszPath_l, (char *)szSysDir_l + 2, strlen(szSysDir_l) - 2))
        {
            // '\WINDOWS\system32\path_to_module'
            size_t len = strlen(lpszPath) + 3;
            if (s = (char *)M_ALLOC(len))
            {
                strncpy(s, szSysDir, 2);
                strcat(s, lpszPath);
            }
        }
        else if (
            szSysDir[1] == ':' && lpszSysDirName_l &&
            !strncmp(lpszPath_l, lpszSysDirName_l, strlen(lpszSysDirName_l)))
        {
            // 'system32\path_to_module'
            size_t len = strlen(szSysDir) + strlen(lpszPath) + 1;
            if (s = (char *)M_ALLOC(len))
            {
                strcpy(s, szSysDir);
                strcat(s, lpszPath + strlen(lpszSysDirName_l));
            }
        }
        else
        {
            // no matches, just return a copy of the source string
            size_t len = strlen(lpszPath) + 1;
            if (s = (char *)M_ALLOC(len))
            {
                strcpy(s, lpszPath);
            }
        }        

        M_FREE(lpszPath_l);
    }        

    if (s)
    {
        // expand environment variables
        char *lpszExp = NULL;
        DWORD ExpLen = ExpandEnvironmentStringsA(s, lpszExp, 0);
        if (ExpLen > 0)
        {
            ExpLen += 2;
            if (lpszExp = (char *)M_ALLOC(ExpLen))
            {
                if (ExpandEnvironmentStringsA(s, lpszExp, ExpLen) > 0)
                {
                    M_FREE(s);
                    s = lpszExp;
                }
                else
                {
                    M_FREE(lpszExp);
                }
            }
        }

        if (!IsFileExists(s))
        {
            try
            {
                std::string newstr = s;
                newstr += ".exe";

                /*
                    Some user-mode services can have 
                    image file path without extension.
                */
                if (IsFileExists((char *)newstr.c_str()))
                {
                    M_FREE(s);

                    size_t newlen = strlen(newstr.c_str()) + 1;
                    if (s = (char *)M_ALLOC(newlen))
                    {
                        strcpy(s, newstr.c_str());
                    }
                }
            }    
            catch (...)
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"() Exception\n");
            }
        }
    }

    return s;
}
//--------------------------------------------------------------------------------------
BOOL GetDescrAndCompanyInfo(char *lpszFilePath, char **lpszDescr, char **lpszCompany)
{
    DWORD dwHandle = 0;
    BOOL bRet = FALSE;

    // query size of versioin info resource
    DWORD dwSize = GetFileVersionInfoSizeA(lpszFilePath, &dwHandle);
    if (dwSize > 0)
    {
        PVOID pInfo = M_ALLOC(dwSize);
        if (pInfo)
        {
            ZeroMemory(pInfo, dwSize);

            // load version info resource from the target file
            if (GetFileVersionInfoA(lpszFilePath, dwHandle, dwSize, pInfo))
            {
                UINT uValueSize = 0;
                struct LANG_INFO 
                {
                    WORD wLanguage;
                    WORD wCodePage;

                } *LangInfo = NULL;

                // get languages table
                if (VerQueryValue(pInfo, TEXT("\\VarFileInfo\\Translation"), (PVOID *)&LangInfo, &uValueSize))
                {
                    for (int i = 0; i < uValueSize / sizeof(struct LANG_INFO); i++)
                    {
                        char SubName[MAX_PATH], *lpValue = NULL;
                        
                        sprintf(
                            SubName, "\\StringFileInfo\\%04x%04x\\FileDescription", 
                            LangInfo[i].wLanguage, LangInfo[i].wCodePage
                        );
                        
                        // query file description value
                        if (lpszDescr && 
                            VerQueryValue(pInfo, SubName, (PVOID *)&lpValue, &uValueSize) &&
                            lpValue)
                        {
                            if (*lpszDescr = (char *)M_ALLOC(strlen(lpValue) + 1))
                            {
                                lstrcpyA(*lpszDescr, lpValue);
                            }
                        }

                        sprintf(
                            SubName, "\\StringFileInfo\\%04x%04x\\CompanyName", 
                            LangInfo[i].wLanguage, LangInfo[i].wCodePage
                        );

                        // query file description value
                        lpValue = NULL;
                        if (lpszCompany && 
                            VerQueryValue(pInfo, SubName, (PVOID *)&lpValue, &uValueSize) &&
                            lpValue)
                        {
                            if (*lpszCompany = (char *)M_ALLOC(strlen(lpValue) + 1))
                            {
                                lstrcpyA(*lpszCompany, lpValue);
                            }
                        }

                        if (LangInfo[i].wCodePage == 1252)
                        {
                            // "ANSI Latin 1; Western European (Windows)" is preffered
                            break;
                        }                        
                    }

                    bRet = TRUE;
                }                                                
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): GetFileVersionInfo() ERROR %d\r\n", GetLastError());
            }

            M_FREE(pInfo);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): LocalAlloc() ERROR %d\r\n", GetLastError());
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): GetFileVersionInfo() ERROR %d\r\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL GetDeviceInfo(
    char *lpszDeviceName, 
    PVOID *pDriverObject, 
    PVOID *pDeviceObject,
    char *lpszDriverObjectName,
    char *lpszDriverFilePath)
{
    UCHAR Buff[sizeof(REQUEST_BUFFER) + MAX_PATH];
    PREQUEST_BUFFER Request = (PREQUEST_BUFFER)Buff;
    ZeroMemory(&Buff, sizeof(Buff));

    if (pDriverObject)
    {
        *pDriverObject = NULL;
    }

    if (pDeviceObject)
    {
        *pDeviceObject = NULL;
    }

    if (lpszDriverObjectName)
    {
        ZeroMemory(lpszDriverObjectName, MAX_REQUEST_STRING);
    }

    if (lpszDriverFilePath)
    {
        ZeroMemory(lpszDriverFilePath, MAX_REQUEST_STRING);
    }

    strncpy(Request->Buff, lpszDeviceName, MAX_PATH - 1);
    Request->Code = C_GET_DEVICE_INFO;    

    if (DrvDeviceRequest(Request, sizeof(Buff)) && 
        Request->Status == S_SUCCESS)
    {
        if (pDriverObject)
        {
            *pDriverObject = Request->DeviceInfo.DriverObjectAddr;
        }

        if (pDeviceObject)
        {
            *pDeviceObject = Request->DeviceInfo.DeviceObjectAddr;
        }

        if (lpszDriverObjectName)
        {
            strcpy(lpszDriverObjectName, Request->DeviceInfo.szDriverObjectName);
        }

        if (lpszDriverFilePath)
        {
            strcpy(lpszDriverFilePath, Request->DeviceInfo.szDriverFilePath);
        }
       
        return TRUE;
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOL PrintObjectPermissions(HANDLE hObject, SE_OBJECT_TYPE ObjectType)
{
    PACL pDacl = NULL;

    // get security information for the object
    DWORD Code = GetSecurityInfo(
        hObject,
        ObjectType,
        DACL_SECURITY_INFORMATION,
        NULL, NULL,
        &pDacl,
        NULL, NULL
    );
    if (Code != ERROR_SUCCESS)
    {
        return FALSE;
    }

    DWORD dwAceIndex = 0;
    PVOID pAce = NULL;

    // enumerate ACEs in ACL
    while (pDacl && GetAce(pDacl, dwAceIndex, &pAce))
    {
        PACE_HEADER pAceHeader = (PACE_HEADER)pAce;
        PSID pSid = NULL;
        ACCESS_MASK AccessMask = 0;

        dwAceIndex += 1;

        if (pAceHeader->AceType == ACCESS_ALLOWED_ACE_TYPE)
        {
            PACCESS_ALLOWED_ACE pAllowAce = (PACCESS_ALLOWED_ACE)pAce;
            pSid = (PSID)&pAllowAce->SidStart;
            AccessMask = pAllowAce->Mask;
        }
        else if (pAceHeader->AceType == ACCESS_DENIED_ACE_TYPE)
        {
            PACCESS_DENIED_ACE pDenyAce = (PACCESS_DENIED_ACE)pAce;
            pSid = (PSID)&pDenyAce->SidStart;
            AccessMask = pDenyAce->Mask;
        }
        else
        {
            // other type of the ACE
            continue;
        }

        char szName[MAX_PATH], szReferencedDomainName[MAX_PATH];
        DWORD dwNameSize = MAX_PATH, dwReferencedDomainNameSize = MAX_PATH;
        SID_NAME_USE NameUse;

        // query account name by SID
        if (LookupAccountSidA(
            NULL,
            pSid,
            szName, &dwNameSize,
            szReferencedDomainName, &dwReferencedDomainNameSize,
            &NameUse))
        {
            DbgMsg(
                __FILE__, __LINE__,
                "%8s: 0x%.8x %s\\%s\n", 
                pAceHeader->AceType == ACCESS_ALLOWED_ACE_TYPE ? "ALLOW" : "DENY", 
                AccessMask, szReferencedDomainName, szName
            );
        }   
        else
        {
            char *pSidStr = NULL;
            if (ConvertSidToStringSidA(pSid, &pSidStr))
            {
                DbgMsg(
                    __FILE__, __LINE__,
                    "%8s: 0x%.8x %s\n", 
                    pAceHeader->AceType == ACCESS_ALLOWED_ACE_TYPE ? "ALLOW" : "DENY", 
                    AccessMask, pSidStr
                );

                LocalFree(pSidStr);
            }
        }
    }    

    return TRUE;
}
//--------------------------------------------------------------------------------------
BOOL GetDesiredPermissions(HANDLE hObject, SE_OBJECT_TYPE ObjectType, PDWORD pdwEveryone, PDWORD pdwAuthenticated)
{
    PACL pDacl = NULL;

    // get security information for the object
    DWORD Code = GetSecurityInfo(
        hObject,
        ObjectType,
        DACL_SECURITY_INFORMATION,
        NULL, NULL,
        &pDacl,
        NULL, NULL
    );
    if (Code != ERROR_SUCCESS)
    {
        return FALSE;
    }

    DWORD SidSize = SECURITY_MAX_SID_SIZE;
    PSID pEveryone = (PSID)M_ALLOC(SidSize);
    if (pEveryone == NULL)
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\n", Code);
        return FALSE;
    }

    PSID pAuthenticated = (PSID)M_ALLOC(SidSize);
    if (pAuthenticated == NULL)
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\n", Code);
        M_FREE(pEveryone);
        return FALSE;
    }

    // Create a SID for the Everyone group on the local computer.
    if (!CreateWellKnownSid(WinWorldSid, NULL, pEveryone, &SidSize))
    {
        DbgMsg(__FILE__, __LINE__, "CreateWellKnownSid() ERROR %d\n", Code);
        M_FREE(pEveryone);
        M_FREE(pAuthenticated);
        return FALSE;
    }

    // Create a SID for the any authenticated users group on the local computer.
    if (!CreateWellKnownSid(WinAuthenticatedUserSid, NULL, pAuthenticated, &SidSize))
    {
        DbgMsg(__FILE__, __LINE__, "CreateWellKnownSid() ERROR %d\n", Code);
        M_FREE(pEveryone);
        M_FREE(pAuthenticated);
        return FALSE;
    }

    DWORD dwAceIndex = 0;
    PVOID pAce = NULL;

    // enumerate ACEs in ACL
    while (pDacl && GetAce(pDacl, dwAceIndex, &pAce))
    {
        PACE_HEADER pAceHeader = (PACE_HEADER)pAce;
        PSID pSid = NULL;
        ACCESS_MASK AccessMask = 0;

        dwAceIndex += 1;

        if (pAceHeader->AceType == ACCESS_ALLOWED_ACE_TYPE)
        {
            PACCESS_ALLOWED_ACE pAllowAce = (PACCESS_ALLOWED_ACE)pAce;
            pSid = (PSID)&pAllowAce->SidStart;
            AccessMask = pAllowAce->Mask;
        }
        else if (pAceHeader->AceType == ACCESS_DENIED_ACE_TYPE)
        {
            PACCESS_DENIED_ACE pDenyAce = (PACCESS_DENIED_ACE)pAce;
            pSid = (PSID)&pDenyAce->SidStart;
            AccessMask = pDenyAce->Mask;
        }
        else
        {
            // other type of the ACE
            continue;
        }

        if (pAceHeader->AceType == ACCESS_ALLOWED_ACE_TYPE)
        {
            if (EqualSid(pSid, pEveryone))
            {
                *pdwEveryone = AccessMask;
            }
            else if (EqualSid(pSid, pAuthenticated))
            {
                *pdwAuthenticated = AccessMask;
            }
        }        
    }    

    M_FREE(pEveryone);
    M_FREE(pAuthenticated);

    return TRUE;
}
//--------------------------------------------------------------------------------------
DWORD ParseIoctlsLog(char *lpszIoctlsLogPath)
{
    DWORD dwRet = 0;

    m_DeviceCallsCount.clear();
    m_DriverCallsCount.clear();

    DbgMsg(__FILE__, __LINE__, "Parsing global IOCLs log \"%s\"...\n", lpszIoctlsLogPath);

    HANDLE hFile = CreateFileA(lpszIoctlsLogPath, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (hFile == INVALID_HANDLE_VALUE)
    {
        DbgMsg(__FILE__, __LINE__, "CreateFile() ERROR %d\n", GetLastError());
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Error while opening log file \"%s\"\n", lpszIoctlsLogPath);
        return 0;
    }

    struct  
    {
        std::string Timestamp;
        std::string Device;
        std::string Driver;

    } IoctlInfo = { "", "", "" };

    #define READBUFF_SIZE 0x1000
    char szBuff[READBUFF_SIZE];
    DWORD dwReaded = 0;

    LARGE_INTEGER FileSize;
    FileSize.LowPart = GetFileSize(hFile, (LPDWORD)&FileSize.HighPart);

    while (ReadFile(hFile, szBuff, READBUFF_SIZE, &dwReaded, NULL) && dwReaded > 0)
    {
        char *lpszLine = szBuff;
        LARGE_INTEGER Position, Processed;        
        Position.QuadPart = Processed.QuadPart = 0;
        Position.LowPart = SetFilePointer(hFile, 0, &Position.HighPart, FILE_CURRENT);        
        
        for (size_t i = 0; i < dwReaded - 1; i++)
        {
            if (szBuff[i] == '\r' && szBuff[i + 1] == '\n')
            {
                // process single line
                szBuff[i] = '\0';

                #define M_TIMESTAMP "timestamp="
                #define M_DEVICE "device="
                #define M_DRIVER "driver="

                try
                {
                    if (!strncmp(lpszLine, M_TIMESTAMP, strlen(M_TIMESTAMP)))
                    {
                        // request timestamp field
                        IoctlInfo.Timestamp = std::string(lpszLine + strlen(M_TIMESTAMP));
                    }
                    else if (!strncmp(lpszLine, M_DEVICE, strlen(M_DEVICE)))
                    {
                        // device object name
                        IoctlInfo.Device = std::string(lpszLine + strlen(M_DEVICE));
                    }
                    else if (!strncmp(lpszLine, M_DRIVER, strlen(M_DRIVER)))
                    {
                        // driver object name
                        IoctlInfo.Driver = std::string(lpszLine + strlen(M_DRIVER));
                    }

                    if (IoctlInfo.Timestamp.length() > 0 &&
                        IoctlInfo.Device.length() > 0 &&
                        IoctlInfo.Driver.length() > 0)
                    {                        
                        // collect call statistics for device
                        if (m_DeviceCallsCount.find(IoctlInfo.Device) == m_DeviceCallsCount.end())
                        {
                            m_DeviceCallsCount[IoctlInfo.Device] = 1;
                        }
                        else
                        {
                            m_DeviceCallsCount[IoctlInfo.Device] += 1;
                        }

                        // collect call statistics for driver
                        if (m_DriverCallsCount.find(IoctlInfo.Driver) == m_DriverCallsCount.end())
                        {
                            m_DriverCallsCount[IoctlInfo.Driver] = 1;
                        }
                        else
                        {
                            m_DriverCallsCount[IoctlInfo.Driver] += 1;
                        }
                        
                        IoctlInfo.Timestamp = "";
                        IoctlInfo.Device = "";
                        IoctlInfo.Driver = "";

                        dwRet += 1;
                    }
                }
                catch (...)
                {
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Exception occurs\n");

                    m_DeviceCallsCount.clear();
                    m_DriverCallsCount.clear();

                    dwRet = 0;

                    goto end;
                }

                Processed.QuadPart = Position.QuadPart - dwReaded + i + 2;
                lpszLine = szBuff + i + 2;
            }
        }

        if (Position.QuadPart >= FileSize.QuadPart)
        {
            // end of the file
            break;
        }

        if (Processed.QuadPart > 0)
        {
            SetFilePointer(hFile, Processed.LowPart, &Processed.HighPart, FILE_BEGIN);
        }        
    }

    DbgMsg(__FILE__, __LINE__, "[+] %d entries readed\n", dwRet);

end:
    CloseHandle(hFile);

    return dwRet;
}
//--------------------------------------------------------------------------------------
void PrintDeviceObjectsInfo(char *lpszIoctlsLogPath)
{
    // required for enumerating file handles
    LoadPrivileges(SE_DEBUG_NAME);    

    if (lpszIoctlsLogPath)
    {
        ParseIoctlsLog(lpszIoctlsLogPath);
    }    

    // collect information about opened device handles
    CollectFileHandles();

    try
    {
        DWORD dwProcessedDrivers = 0, dwProcessedDevices = 0;
        std::map<PVOID, DRVINFO> InterestingDrivers;
        DRVINFO_LIST::iterator e_drv;

        // enumerate drivers        
        for (e_drv = m_DriversInfo.begin(); e_drv != m_DriversInfo.end(); ++e_drv)
        {
            DWORD dwCallsCount = 0;
            DRVINFO_ENTRY *DrvInfo = &e_drv->second;

            DrvInfo->first.Company = std::string("<unknown_vendor>");
            DrvInfo->first.Descr = std::string("<no_description>");

            if (m_DriverCallsCount.find(DrvInfo->first.ObjectName) != m_DriverCallsCount.end())
            {
                // IOCTLs statistic by calls count for this driver is available
                dwCallsCount = m_DriverCallsCount[DrvInfo->first.ObjectName];
            }
            else
            {
                dwCallsCount = 0;
            }

            if (lpszIoctlsLogPath)
            {
                // print calls count statistic from parsed log
                DbgMsg(
                    __FILE__, __LINE__, "DRIVER: "IFMT" \"%s\" %d total calls\n",
                    DrvInfo->first.Object, DrvInfo->first.ObjectName.c_str(), dwCallsCount
                );
            }
            else
            {
                DbgMsg(
                    __FILE__, __LINE__, "DRIVER: "IFMT" \"%s\"\n",
                    DrvInfo->first.Object, DrvInfo->first.ObjectName.c_str()
                );
            }

            if (strlen(DrvInfo->first.FilePath.c_str()) > 0)
            {
                char *lpszPath = GetNormalizedDriverFilePath((char *)DrvInfo->first.FilePath.c_str());
                if (lpszPath)
                {
                    char *lpszDescr = NULL, *lpszCompany = NULL;

                    DrvInfo->first.FilePath = std::string(lpszPath);                    
                    
                    // query file description and vendor name from resources
                    GetDescrAndCompanyInfo(lpszPath, &lpszDescr, &lpszCompany);

                    WORD c = ccol(CCOL_YELLOW);

                    if (lpszDescr)
                    {
                        DbgMsg(__FILE__, __LINE__, "Description: \"%s\"\n", lpszDescr);
                        DrvInfo->first.Descr = std::string(lpszDescr);
                        M_FREE(lpszDescr);
                    }

                    if (lpszCompany)
                    {
                        DbgMsg(__FILE__, __LINE__, "Company: \"%s\"\n", lpszCompany);
                        DrvInfo->first.Company = std::string(lpszCompany);
                        M_FREE(lpszCompany);
                    }

                    ccol(c);

                    DbgMsg(__FILE__, __LINE__, "File path: \"%s\"\n", lpszPath);                    
                    M_FREE(lpszPath);
                }                
            }            

            // enumerate devices for this driver
            DEVINFO_LIST::iterator e_dev;
            for (e_dev = DrvInfo->second.begin(); e_dev != DrvInfo->second.end(); ++e_dev)
            {                
                PDEVINFO DevInfo = &e_dev->second;
                char *lpszAccess = "";
                WORD c = 0;

                if (m_DeviceCallsCount.find(DevInfo->ObjectName) != m_DeviceCallsCount.end())
                {
                    // IOCTLSs statistic by calls count for this device is available
                    dwCallsCount = m_DeviceCallsCount[DevInfo->ObjectName];
                }
                else
                {
                    dwCallsCount = 0;
                }

                switch (DevInfo->Access)
                {
                case DevAccessOpenError:

                    lpszAccess = "Open Error";
                    c = CCOL_RED;
                    break;

                case DevAccessEveryone:

                    lpszAccess = "Everyone";
                    c = CCOL_GREEN;
                    break;

                case DevAccessAuthenticated:

                    lpszAccess = "Authenticated";
                    break;

                case DevAccessRestricted:

                    lpszAccess = "Restricted";
                    break;
                }

                if (c != 0)
                {
                    c = ccol(c);
                }

                if (lpszIoctlsLogPath)
                {
                    // print calls count statistic from parsed log
                    DbgMsg(
                        __FILE__, __LINE__, "      * "IFMT" \"%s\" Access: %s, %d calls\n",
                        DevInfo->Object, DevInfo->ObjectName.c_str(), lpszAccess, dwCallsCount
                    );
                }   
                else
                {
                    DbgMsg(
                        __FILE__, __LINE__, "      * "IFMT" \"%s\" Access: %s\n",
                        DevInfo->Object, DevInfo->ObjectName.c_str(), lpszAccess
                    );
                }                

                if (c != 0)
                {
                    ccol(c);
                }

                std::string ObjectName = DevInfo->ObjectName.c_str();
                if (m_OpenedInfo.find(ObjectName) != m_OpenedInfo.end())
                {
                    DbgMsg(__FILE__, __LINE__, "        Opened by:\n");                    

                    // enumerate processes, that uses this device
                    std::list<PROCESSINFO>::iterator e_pr = m_OpenedInfo[ObjectName].begin();

                    while (e_pr != m_OpenedInfo[ObjectName].end())
                    {
                        DbgMsg(
                            __FILE__, __LINE__, "          %.5d \"%s\"\n",
                            e_pr->ProcessId, e_pr->ProcessName.c_str()
                        );

                        ++e_pr;
                    }
                }

                if (DevInfo->Access == DevAccessEveryone &&
                    strlen(DrvInfo->first.FilePath.c_str()) > 0)
                {
                    InterestingDrivers[DrvInfo->first.Object] = DrvInfo->first;
                }

                dwProcessedDevices += 1;
            }

            dwProcessedDrivers += 1;

            DbgMsg(__FILE__, __LINE__, "\n");
        }

        DbgMsg(
            __FILE__, __LINE__, "[+] %d devices in %d drivers displayed\n", 
            dwProcessedDevices, dwProcessedDrivers
        );

        if (InterestingDrivers.size() > 0)
        {
            DbgMsg(__FILE__, __LINE__, "[+] Interesting drivers:\n\n");
            DbgMsg(__FILE__, __LINE__, "\n");

            // enumerate drivers, that have devices accessible from user mode
            std::map<PVOID, DRVINFO>::iterator e_drv;
            for (e_drv = InterestingDrivers.begin(); e_drv != InterestingDrivers.end(); ++e_drv)
            {
                DbgMsg(__FILE__, __LINE__, "%s\n", e_drv->second.FilePath.c_str());

                WORD c = ccol(CCOL_YELLOW);
                
                DbgMsg(
                    __FILE__, __LINE__, "\"%s\", \"%s\"\n", 
                    e_drv->second.Company.c_str(), e_drv->second.Descr.c_str()
                );
                
                ccol(c);

                DbgMsg(__FILE__, __LINE__, "\n");
            }

            DbgMsg(__FILE__, __LINE__, "\n");
        }
    }
    catch (...)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Exception occurs\n");
    }
}
//--------------------------------------------------------------------------------------
#ifndef DIRECTORY_QUERY
#define DIRECTORY_QUERY     0x0001
#endif

#ifndef SYMBOLIC_LINK_QUERY
#define SYMBOLIC_LINK_QUERY 0x0001
#endif

void CollectDeviceObjectsInfo(LPWSTR lpRoot)
{
    UNICODE_STRING usDirName;
    OBJECT_ATTRIBUTES ObjAttr;
    HANDLE hDir = NULL;

    if (!wcscmp(lpRoot, L"//"))
    {
        m_DriversInfo.clear();
    }

    UNICODE_FROM_WCHAR(&usDirName, lpRoot);
    InitializeObjectAttributes(&ObjAttr, &usDirName, OBJ_CASE_INSENSITIVE, NULL, NULL);

    GET_NATIVE(NtOpenDirectoryObject);
    GET_NATIVE(NtQueryDirectoryObject);
    GET_NATIVE(NtOpenSymbolicLinkObject);
    GET_NATIVE(NtQuerySymbolicLinkObject);

    // target open objects directory
    NTSTATUS ns = f_NtOpenDirectoryObject(
        &hDir,
        DIRECTORY_QUERY,
        &ObjAttr
    );
    if (NT_SUCCESS(ns))
    {
        ULONG ResultLen = 0, Context = 0;
        PDIRECTORY_BASIC_INFORMATION DirInfo = NULL;

enum_obj:

        ResultLen = 0;
        DirInfo = NULL;
        
        // get required buffer size
        ns = f_NtQueryDirectoryObject(
            hDir,
            &DirInfo,
            ResultLen,
            TRUE,
            FALSE,
            &Context,
            &ResultLen
        );
        if ((ns == STATUS_BUFFER_TOO_SMALL || ns == STATUS_BUFFER_OVERFLOW) && ResultLen > 0)
        {
            // allocate memory for information
            if (DirInfo = (PDIRECTORY_BASIC_INFORMATION)M_ALLOC(ResultLen))
            {
                ZeroMemory(DirInfo, ResultLen);

                // query directory entry information
                ns = f_NtQueryDirectoryObject(
                    hDir,
                    DirInfo,
                    ResultLen,
                    TRUE,
                    FALSE,
                    &Context,
                    NULL
                );
                if (NT_SUCCESS(ns))
                {
                    // allocate memory for strings
                    DWORD dwNameLen = DirInfo->ObjectName.Length;
                    dwNameLen += ((DWORD)wcslen(usDirName.Buffer) + 2) * sizeof(WCHAR);

                    PWSTR lpwcName = (PWSTR)M_ALLOC(dwNameLen);
                    if (lpwcName)
                    {
                        ZeroMemory(lpwcName, dwNameLen);                        
                        wcscpy(lpwcName, usDirName.Buffer);

                        if (lpwcName[wcslen(lpwcName) - 1] != L'\\')
                        {
                            wcscat(lpwcName, L"\\");
                        }

                        memcpy(
                            lpwcName + wcslen(lpwcName), 
                            DirInfo->ObjectName.Buffer, 
                            DirInfo->ObjectName.Length
                        );

                        DWORD dwTypeNameLen = DirInfo->ObjectTypeName.Length + sizeof(WCHAR);
                        PWSTR lpwcTypeName = (PWSTR)M_ALLOC(dwTypeNameLen);
                        if (lpwcTypeName)
                        {
                            ZeroMemory(lpwcTypeName, dwTypeNameLen);                            
                            memcpy(lpwcTypeName, DirInfo->ObjectTypeName.Buffer, dwTypeNameLen - sizeof(WCHAR));                            

                            PVOID DriverObject = NULL, DeviceObject = NULL;
                            char szDriverObjectName[MAX_REQUEST_STRING], szDeviceObjectName[MAX_PATH];
                            char szDriverFilePath[MAX_REQUEST_STRING];

                            ZeroMemory(szDeviceObjectName, sizeof(szDeviceObjectName));
                            WideCharToMultiByte(CP_ACP, 0, lpwcName, -1, szDeviceObjectName, MAX_PATH - 1, NULL, NULL); 

                            // process devices
                            if (!wcscmp(lpwcTypeName, L"Device") && wcscmp(GetNameFromFullPathW(lpwcName), DEVICE_NAME) &&
                                GetDeviceInfo(szDeviceObjectName, 
                                &DriverObject, &DeviceObject, 
                                szDriverObjectName, szDriverFilePath))
                            {  
                                DEVINFO DevInfo;
                                DEVINFO_LIST *DevInfoList = NULL;

                                try
                                {
                                    // insert driver object info into the global list
                                    DRVINFO_LIST::iterator e = m_DriversInfo.find(DriverObject);
                                    if (e == m_DriversInfo.end())
                                    {                                    
                                        DRVINFO_ENTRY DrvInfo;

                                        DrvInfo.first.Object = DriverObject;
                                        DrvInfo.first.ObjectName = std::string(szDriverObjectName);
                                        DrvInfo.first.FilePath = std::string(szDriverFilePath);

                                        m_DriversInfo[DriverObject] = DrvInfo;
                                        DevInfoList = &m_DriversInfo[DriverObject].second;
                                    }
                                    else
                                    {
                                        // driver is allready in list
                                        DevInfoList = &e->second.second;
                                    }

                                    DevInfo.Access = DevAccessOpenError;
                                    DevInfo.Object = DeviceObject;
                                    DevInfo.ObjectName = std::string(szDeviceObjectName);
                                }   
                                catch (...)
                                {
                                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Exception occurs\n");
                                    goto skip_device;
                                }                                                               

                                GET_NATIVE(NtOpenFile);

                                IO_STATUS_BLOCK StatusBlock;
                                OBJECT_ATTRIBUTES ObjAttr;
                                UNICODE_STRING usName;
                                HANDLE hDevice = NULL;

                                UNICODE_FROM_WCHAR(&usName, lpwcName);
                                InitializeObjectAttributes(&ObjAttr, &usName, OBJ_CASE_INSENSITIVE, NULL, NULL);

                                // try to open device
                                ns = f_NtOpenFile(
                                    &hDevice,
                                    GENERIC_READ | GENERIC_WRITE | ACCESS_SYSTEM_SECURITY, 
                                    &ObjAttr,
                                    &StatusBlock,
                                    FILE_SHARE_READ | FILE_SHARE_WRITE,
                                    0 
                                );
                                if (NT_SUCCESS(ns))
                                {
                                    DWORD dwEveryone = 0, dwAuthenticated = 0;

                                    // query security permissions for device
                                    if (GetDesiredPermissions(
                                        hDevice, SE_FILE_OBJECT, 
                                        &dwEveryone, &dwAuthenticated) &&
                                        (dwEveryone != 0 || dwAuthenticated != 0))
                                    {
                                        if (dwEveryone & READ_CONTROL)
                                        {
                                            DevInfo.Access = DevAccessEveryone;
                                        }
                                        else if (dwAuthenticated & READ_CONTROL)
                                        {
                                            DevInfo.Access = DevAccessAuthenticated;
                                        }
                                    }
                                    else
                                    {                                     
                                        DevInfo.Access = DevAccessRestricted;
                                    }                                    

                                    CloseHandle(hDevice);
                                }
            
                                try
                                {
                                    (*DevInfoList)[DeviceObject] = DevInfo;
                                }
                                catch (...)
                                {
                                	DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Exception occurs\n");
                                }
                            }
                            else if (!wcscmp(lpwcTypeName, L"Directory"))
                            {
                                // recursive scanning of the next level directory
                                CollectDeviceObjectsInfo(lpwcName);
                            }
skip_device:
                            M_FREE(lpwcTypeName);
                        }
                        else
                        {
                            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
                            M_FREE(lpwcName);
                            M_FREE(DirInfo);
                            goto end;
                        }

                        M_FREE(lpwcName);
                    }
                    else
                    {
                        DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
                        M_FREE(DirInfo);
                        goto end;
                    }
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "NtQueryDirectoryObject() fails; status: 0x%.8x\n", ns);
                    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Error while requesting device objects info\n");

                    M_FREE(DirInfo);
                    goto end;
                }

                M_FREE(DirInfo);
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
                goto end;
            }
            
            goto enum_obj;
        }

end:
        CloseHandle(hDir);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "NtOpenDirectoryObject() fails; status: 0x%.8x\n", ns);
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Error while opening directory \"%ws\"\n", lpRoot);
    }
}
//--------------------------------------------------------------------------------------
// EoF
