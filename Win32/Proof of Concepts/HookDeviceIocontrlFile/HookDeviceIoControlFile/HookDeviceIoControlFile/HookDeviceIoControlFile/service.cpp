#include "stdafx.h"

// defined if ioctlfuzzer.cpp
extern HANDLE hDevice;
//--------------------------------------------------------------------------------------
BOOL DrvOpenDevice(PWSTR DriverName, HANDLE *lphDevice)
{
    WCHAR DeviceName[MAX_PATH];
    HANDLE hDevice = NULL;

    if ((GetVersion() & 0xFF) >= 5) 
    {
        wcscpy(DeviceName, L"\\\\.\\Global\\");
    } 
    else 
    {
        wcscpy(DeviceName, L"\\\\.\\");
    }

    wcscat(DeviceName, DriverName);

    DbgMsg(__FILE__, __LINE__, "Opening '%ws'...\n", DeviceName);

    hDevice = CreateFileW(
        DeviceName, 
        GENERIC_READ | GENERIC_WRITE, 
        0, NULL, 
        OPEN_EXISTING, 
        0, NULL
    );
    if (hDevice == INVALID_HANDLE_VALUE)
    {
        DbgMsg(__FILE__, __LINE__, "CreateFile() ERROR %d\n", GetLastError());
        return FALSE;
    }

    *lphDevice = hDevice;

    return TRUE;
}
//--------------------------------------------------------------------------------------
BOOL DrvDeviceRequest(PREQUEST_BUFFER Request, DWORD dwRequestSize)
{
    BOOL bRet = FALSE;

    if (hDevice == NULL)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__ "() ERROR: Invalid device handle\n"); 
        return FALSE;
    }

    PREQUEST_BUFFER Response = (PREQUEST_BUFFER)M_ALLOC(dwRequestSize);
    if (Response)
    {
        DWORD dwBytes = 0;
        ZeroMemory(Response, dwRequestSize);

        // send request to driver
        if (DeviceIoControl(
            hDevice, 
            IOCTL_DRV_CONTROL, 
            Request, 
            dwRequestSize, 
            Response, 
            dwRequestSize, 
            &dwBytes, NULL))
        {     

#ifdef DBG_IO
            
            DbgMsg(
                __FILE__, __LINE__, 
                __FUNCTION__ "() %d bytes returned; status 0x%.8x\n", 
                dwBytes, Response->Status
            );
#endif
            memcpy(Request, Response, dwRequestSize);

            bRet = TRUE;
        }	
        else
        {
            DbgMsg(__FILE__, __LINE__, "DeviceIoControl() ERROR %d\n", GetLastError());
        }

        M_FREE(Response);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL DrvServiceStart(char *lpszServiceName, char *lpszPath, PBOOL bAllreadyStarted)
{
    BOOL bRet = FALSE;
    SC_HANDLE hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (hScm)
    {
        DbgMsg(__FILE__, __LINE__, "Creating service...\n");

        // create service for kernel-mod driver
        SC_HANDLE hService = CreateService(
            hScm, 
            lpszServiceName, 
            lpszServiceName, 
            SERVICE_START | DELETE | SERVICE_STOP, 
            SERVICE_KERNEL_DRIVER, 
            SERVICE_DEMAND_START, 
            SERVICE_ERROR_IGNORE, 
            lpszPath, 
            NULL, NULL, NULL, NULL, NULL
        );
        if (hService == NULL)
        {
            if (GetLastError() == ERROR_SERVICE_EXISTS)
            {
                // open existing service
                if (hService = OpenService(hScm, lpszServiceName, SERVICE_START | DELETE | SERVICE_STOP))
                {
                    DbgMsg(__FILE__, __LINE__, "Allready exists\n");
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "OpenService() ERROR %d\n", GetLastError());
                }
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "CreateService() ERROR %d\n", GetLastError());
            }
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "OK\n");
        }

        if (hService)
        {                
            DbgMsg(__FILE__, __LINE__, "Starting service...\n");

            // start service
            if (StartService(hService, 0, NULL))
            {
                DbgMsg(__FILE__, __LINE__, "OK\n");                
                bRet = TRUE;
            }
            else
            {
                if (GetLastError() == ERROR_SERVICE_ALREADY_RUNNING)
                {
                    // service is allready started
                    DbgMsg(__FILE__, __LINE__, "Allready running\n");

                    if (bAllreadyStarted)
                    {
                        *bAllreadyStarted = TRUE;
                    }

                    bRet = TRUE;
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "StartService() ERROR %d\n", GetLastError());
                }                    
            }            

            CloseServiceHandle(hService);
        }

        CloseServiceHandle(hScm);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "OpenSCManager() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL DrvServiceStop(char *lpszServiceName)
{
    BOOL bRet = FALSE;

    SC_HANDLE hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (hScm)
    {
        DbgMsg(__FILE__, __LINE__, "Opening service...\n");

        // open existing service
        SC_HANDLE hService = OpenService(hScm, lpszServiceName, SERVICE_ALL_ACCESS);
        if (hService)
        {
            SERVICE_STATUS Status;

            DbgMsg(__FILE__, __LINE__, "OK\n");
            DbgMsg(__FILE__, __LINE__, "Stopping service...\n");
            
            // stop service
            if (ControlService(hService, SERVICE_CONTROL_STOP, &Status))
            {
                DbgMsg(__FILE__, __LINE__, "OK\n");
                bRet = TRUE;
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ControlService() ERROR %d\n", GetLastError());                
            }

            CloseServiceHandle(hService);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "OpenService() ERROR %d\n", GetLastError());
        }

        CloseServiceHandle(hScm);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "OpenSCManager() ERROR %d\n", GetLastError());

    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL DrvServiceRemove(char *lpszServiceName)
{
    BOOL bRet = FALSE;

    SC_HANDLE hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (hScm)
    {
        DbgMsg(__FILE__, __LINE__, "Opening service...\n");

        // open existing service
        SC_HANDLE hService = OpenService(hScm, lpszServiceName, SERVICE_ALL_ACCESS);
        if (hService)
        {
            SERVICE_STATUS Status;

            DbgMsg(__FILE__, __LINE__, "OK\n");
            DbgMsg(__FILE__, __LINE__, "Deleting service...\n");

            // delete service
            if (DeleteService(hService))
            {
                DbgMsg(__FILE__, __LINE__, "OK\n");
                bRet = TRUE;
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "DeleteService() ERROR %d\n", GetLastError());                
            }

            CloseServiceHandle(hService);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "OpenService() ERROR %d\n", GetLastError());
        }

        CloseServiceHandle(hScm);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "OpenSCManager() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
DWORD DrvServiceGetStartType(char *lpszServiceName)
{
    DWORD dwRet = (DWORD)-1;

    SC_HANDLE hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (hScm)
    {
        // open existing service
        SC_HANDLE hService = OpenService(hScm, lpszServiceName, SERVICE_ALL_ACCESS);
        if (hService)
        {
            DWORD dwBytesNeeded = 0;
            char szBuff[0x1000];
            ZeroMemory(&szBuff, sizeof(szBuff));

            LPQUERY_SERVICE_CONFIG Config = (LPQUERY_SERVICE_CONFIG)&szBuff;            

            // query service configuration
            if (QueryServiceConfig(hService, Config, sizeof(szBuff), &dwBytesNeeded)) 
            {
                dwRet = Config->dwStartType;
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "QueryServiceConfig() ERROR %d\n", GetLastError());
            }

            CloseServiceHandle(hService);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "OpenService() ERROR %d\n", GetLastError());
        }

        CloseServiceHandle(hScm);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "OpenSCManager() ERROR %d\n", GetLastError());

    }

    return dwRet;
}
//--------------------------------------------------------------------------------------
BOOL DrvServiceSetStartType(char *lpszServiceName, DWORD dwStartType)
{
    BOOL bRet = FALSE;

    SC_HANDLE hScm = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (hScm)
    {
        // open existing service
        SC_HANDLE hService = OpenService(hScm, lpszServiceName, SERVICE_ALL_ACCESS);
        if (hService)
        {            
            // set new service configuration
            bRet = ChangeServiceConfig(
                hService,
                SERVICE_NO_CHANGE,
                dwStartType,
                SERVICE_NO_CHANGE,
                NULL, 
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL
            );
            if (!bRet)
            {
                DbgMsg(__FILE__, __LINE__, "ChangeServiceConfig() ERROR %d\n", GetLastError());
            }         

            CloseServiceHandle(hService);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "OpenService() ERROR %d\n", GetLastError());
        }

        CloseServiceHandle(hScm);
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "OpenSCManager() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
// EoF
