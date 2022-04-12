BOOL DrvOpenDevice(PWSTR DriverName, HANDLE *lphDevice);
BOOL DrvDeviceRequest(PREQUEST_BUFFER Request, DWORD dwRequestSize);
BOOL DrvServiceStart(char *lpszServiceName, char *lpszPath, PBOOL bAllreadyStarted);
BOOL DrvServiceStop(char *lpszServiceName);
BOOL DrvServiceRemove(char *lpszServiceName);
DWORD DrvServiceGetStartType(char *lpszServiceName);
BOOL DrvServiceSetStartType(char *lpszServiceName, DWORD dwStartType);
