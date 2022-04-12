#include "stdafx.h"

#define DBG_PIPE_BUFFER_SIZE 0x1000

WCHAR m_wcDebugPipeName[MAX_PATH];
HANDLE hDbgMutex = NULL, hDbgLogfile = INVALID_HANDLE_VALUE;
//--------------------------------------------------------------------------------------
void DbgMsgLogWrite(char *lpszBuff)
{
    if (hDbgLogfile != INVALID_HANDLE_VALUE && hDbgMutex)
    {
        DWORD dwWritten = 0;
        char *s = lpszBuff; 
        size_t len = strlen(lpszBuff);

        WaitForSingleObject(hDbgMutex, INFINITE);         
        SetFilePointer(hDbgLogfile, 0, NULL, FILE_END);

        for (size_t i = 1; i < len; i++)
        {
            // divide source string by lines
            if (lpszBuff[i] == '\n')
            {
                lpszBuff[i] = '\x00';

                // write the current line
                WriteFile(hDbgLogfile, s, (DWORD)strlen(s), &dwWritten, NULL);

                if (lpszBuff[i - 1] != '\r')
                {
                    // replace single '\n' with '\r\n'
                    WriteFile(hDbgLogfile, "\r\n", 2, &dwWritten, NULL);
                }
                else
                {
                    WriteFile(hDbgLogfile, "\n", 1, &dwWritten, NULL);
                }                

                s = lpszBuff + i + 1;
            }
        }

        if (lpszBuff + len > s)
        {
            // write the rest of the string
            WriteFile(hDbgLogfile, s, (DWORD)strlen(s), &dwWritten, NULL);
        }        

        ReleaseMutex(hDbgMutex);
    }
}
//--------------------------------------------------------------------------------------
void DbgMsg(char *lpszFile, int Line, char *lpszMsg, ...)
{
    va_list mylist;
    va_start(mylist, lpszMsg);

    size_t len = _vscprintf(lpszMsg, mylist) + 0x100;
    
    char *lpszBuff = (char *)M_ALLOC(len);
    if (lpszBuff == NULL)
    {
        va_end(mylist);
        return;
    }

    char *lpszOutBuff = (char *)M_ALLOC(len);
    if (lpszOutBuff == NULL)
    {
        M_FREE(lpszBuff);
        va_end(mylist);
        return;
    }
    
    vsprintf_s(lpszBuff, len, lpszMsg, mylist);	
    va_end(mylist);

    sprintf_s(
        lpszOutBuff, len, "[%.5d] %s(%d) : %s", 
        GetCurrentProcessId(), GetNameFromFullPath(lpszFile), Line, lpszBuff
    );	

    OutputDebugString(lpszOutBuff);

    HANDLE hStd = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStd != INVALID_HANDLE_VALUE)
    {
        DWORD dwWritten = 0;
        WriteFile(hStd, lpszBuff, strlen(lpszBuff), &dwWritten, NULL);    
    }    

    sprintf_s(lpszOutBuff, len, "[%.5d] %s", GetCurrentProcessId(), lpszBuff);	       
    DbgMsgLogWrite(lpszOutBuff);

    M_FREE(lpszOutBuff);
    M_FREE(lpszBuff);
}
//--------------------------------------------------------------------------------------
DWORD WINAPI PipeInstanceThread(LPVOID lpParam)
{
    HANDLE hPipe = (HANDLE)lpParam;
    DWORD dwReaded, dwWritten, dwLen = 0;   

    // read data length from pipe
    while (ReadFile(hPipe, (PVOID)&dwLen, sizeof(dwLen), &dwReaded, NULL))
    {
        if (dwLen > 0)
        {
            // allocate memory for data
            PUCHAR Data = (PUCHAR)M_ALLOC(dwLen);
            if (Data)
            {
                PUCHAR DataPtr = Data;
                DWORD dwTotalReaded = 0, dwReadLen = dwLen;
read_again:
                if (ReadFile(hPipe, DataPtr, dwReadLen, &dwReaded, NULL))
                {
                    dwTotalReaded += dwReaded;
                    if (dwLen > dwTotalReaded)
                    {
                        DataPtr += dwReaded;
                        dwReadLen -= dwReaded;

                        // not all data was readed
                        goto read_again;
                    }                    

                    // write message into the standart output
                    HANDLE hStd = GetStdHandle(STD_OUTPUT_HANDLE);
                    if (hStd != INVALID_HANDLE_VALUE)
                    {        
                        char *s = strstr((char *)Data, " : ");
                        if (s)
                        {
                            s += 3;
                            WriteFile(hStd, s, lstrlen(s), &dwWritten, NULL);
                        }                  
                        else
                        {
                            WriteFile(hStd, Data, lstrlen((char *)Data), &dwWritten, NULL);
                        }
                    }

                    // write message into the log
                    DbgMsgLogWrite((char *)Data);
                }

                M_FREE(Data);
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "M_ALLOC() ERROR %d\n", GetLastError());
            }
        }            

        dwLen = 0;
    }

    return 0;
}
//--------------------------------------------------------------------------------------
DWORD WINAPI PipeServerThread(LPVOID lpParam)
{
    DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Listening on pipe '%ws'\n", m_wcDebugPipeName);

    while (true)
    {
        // create pipe instance
        HANDLE hPipe = CreateNamedPipeW(
            m_wcDebugPipeName, 
            PIPE_ACCESS_DUPLEX, 
            PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT, 
            PIPE_UNLIMITED_INSTANCES,  
            DBG_PIPE_BUFFER_SIZE, 
            DBG_PIPE_BUFFER_SIZE, 
            INFINITE, 
            NULL
        ); 
        if (hPipe == INVALID_HANDLE_VALUE)
        {
            DbgMsg(__FILE__, __LINE__, "CreateNamedPipe() ERROR %d\n", GetLastError());
            return 0;
        }

        BOOL bConnected = ConnectNamedPipe(hPipe, NULL) ? TRUE : (GetLastError() == ERROR_PIPE_CONNECTED); 
        if (bConnected) 
        { 
            // Create a thread for this client. 
            HANDLE hThread = CreateThread(NULL, 0, PipeInstanceThread, (LPVOID)hPipe, 0, NULL);
            if (hThread == NULL) 
            {
                DbgMsg(__FILE__, __LINE__, "CreateThread() ERROR %d\n", GetLastError());
                return 0;
            }
            else
            {
                CloseHandle(hThread); 
            }
        } 
        else 
        {
            // The client could not connect, so close the pipe. 
            CloseHandle(hPipe); 
        }
    }
}
//--------------------------------------------------------------------------------------
void DbgInit(char *lpszDebugPipeName, char *lpszLogFileName)
{
    hDbgMutex = CreateMutex(NULL, FALSE, NULL);
    if (hDbgMutex == NULL)
    {
        DbgMsg(__FILE__, __LINE__, "CreateMutex() ERROR %d\n", GetLastError());
        return;
    }
    
    if (lpszLogFileName)
    {
        // use logfile for debug messages
        char szLogFilePath[MAX_PATH];
        GetCurrentDirectory(sizeof(szLogFilePath), szLogFilePath);
        strcat_s(szLogFilePath, MAX_PATH, "\\");
        strcat_s(szLogFilePath, MAX_PATH, lpszLogFileName);

        hDbgLogfile = CreateFile(
            szLogFilePath, 
            GENERIC_WRITE, 
            FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
            NULL, 
            CREATE_ALWAYS, 
            FILE_ATTRIBUTE_NORMAL, 
            NULL
        );
        if (hDbgLogfile == INVALID_HANDLE_VALUE)
        {
            DbgMsg(__FILE__, __LINE__, "CreateFile() ERROR %d\n", GetLastError());
            return;
        }

        DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): Log file '%s' created\n", szLogFilePath);
    }        

    if (lpszDebugPipeName)
    {
        // pipe to receive messages from driver or other application
        WCHAR wcDebugPipeName[MAX_PATH];
        MultiByteToWideChar(CP_ACP, 0, lpszDebugPipeName, -1, wcDebugPipeName, MAX_PATH);
        wcscpy_s(m_wcDebugPipeName, MAX_PATH, L"\\\\.\\pipe\\");
        wcscat_s(m_wcDebugPipeName, MAX_PATH, wcDebugPipeName);

        // start pipe server for debug messages from driver
        HANDLE hThread = CreateThread(NULL, 0, PipeServerThread, NULL, 0, NULL);
        if (hThread)
        {            
            CloseHandle(hThread);
            Sleep(2000);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "CreateThread() ERROR %d\n", GetLastError());
        }
    }    
}
//--------------------------------------------------------------------------------------
WORD ccol(WORD wColor)
{    
    WORD c = 0;

    if (wColor == 0)
    {
        return 0;
    }

    if (hDbgMutex)
    {
        WaitForSingleObject(hDbgMutex, INFINITE);
    }

    HANDLE hStd = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStd != INVALID_HANDLE_VALUE)
    {
        CONSOLE_SCREEN_BUFFER_INFO Info;
        ZeroMemory(&Info, sizeof(Info));

        // get old console attributes
        if (GetConsoleScreenBufferInfo(hStd, &Info))
        {
            // set new console attributes
            SetConsoleTextAttribute(hStd, wColor);
            c = Info.wAttributes;
        }        
    }

    if (hDbgMutex)
    {
        ReleaseMutex(hDbgMutex);
    }

    return c;
}
//--------------------------------------------------------------------------------------
// EoF
