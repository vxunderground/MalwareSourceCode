
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€								         €€
;€€			        AHADISK				         €€
;€€								         €€
;€€      Created:   29-Feb-92					         €€
;€€      Passes:    5	       Analysis Options on: none	         €€
;€€								         €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

data_1e		equ	0
data_2e		equ	1
data_3e		equ	3
data_4e		equ	94h
keybd_flags_1_	equ	417h
dsk_recal_stat_	equ	43Eh
dsk_motor_stat_	equ	43Fh
dsk_motor_tmr_	equ	440h
video_mode_	equ	449h
video_port_	equ	463h
timer_low_	equ	46Ch
hdsk0_media_st_	equ	490h
data_16e	equ	1000h			;*
data_17e	equ	0			;*
data_18e	equ	3			;*
data_234e	equ	7C3Eh			;*

;--------------------------------------------------------------	seg_a  ----

seg_a		segment	byte public
		assume cs:seg_a , ds:seg_a


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;			Program Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€


ahadisk		proc	far

start:
		jmp	loc_262
data_24		db	0, 0
data_25		dw	0
data_26		dw	0
data_27		dw	0
data_28		db	0
data_29		db	0
data_30		db	0
		db	0
data_31		dw	1
data_32		db	19h
		db	0
data_33		db	' ', 0
		db	27h, 0
		db	'.', 0
		db	' 360 K', 0
		db	' 1.2 M', 0
		db	' 720 K', 0
		db	'1.44 M', 0
data_37		db	0FFh
		db	 11h,0FFh
data_38		db	1Dh
		db	0FFh, 11h,0FFh, 23h
data_39		db	1
		db	0, 2, 0
data_40		db	23h
		db	 00h, 3Bh, 00h, 23h, 00h, 47h
		db	 00h
data_41		db	2
		db	1, 2
data_42		db	1
data_43		db	0DFh
		db	0DFh,0DFh,0AFh
data_44		db	9
		db	 0Fh, 09h, 12h
data_45		db	2Ah
		db	 1Bh, 2Ah, 1Ah
data_46		db	50h
		db	 54h, 50h, 6Ch
data_47		db	0FDh
		db	0F9h,0F9h,0F0h
data_48		db	70h
		db	0
		db	0E0h, 00h

locloop_2:
		jo	loc_3			; Jump if overflow=1
loc_3:
		loopnz	$+2			; Loop if zf=0, cx>0

		rol	byte ptr [bp+si],1	; Rotate
		db	 60h, 09h,0A0h, 05h, 40h, 0Bh
data_50		db	2
		db	0, 7, 0, 3, 0, 9
		db	0
data_51		db	62h
		db	 01h, 43h, 09h,0C9h, 02h, 1Fh
		db	 0Bh
data_52		db	6
		db	1, 4, 3
data_53		db	0
data_54		dw	0
data_55		db	0
data_56		db	0
data_57		db	2Ah
data_58		db	50h
data_59		db	0
data_60		db	0, 0
data_61		dw	0
data_62		db	0
data_63		db	0
data_64		db	0
data_65		db	0
data_66		db	0
data_67		dw	0
data_68		dw	0
data_69		db	0
data_70		db	0
data_71		db	0
data_72		db	0
data_73		db	0
data_74		db	0
data_75		db	0
data_76		db	0
data_77		db	0
data_78		db	0
data_79		db	0
data_80		db	0
data_81		dw	130Dh
data_82		dw	0
data_84		dw	0
data_85		dw	0
data_86		dw	0
data_87		dw	0
data_88		dw	0
data_89		dw	0
data_90		dw	0
data_91		dw	0
data_92		dw	0
data_93		dw	0
data_94		db	0
data_95		db	0
data_96		db	0Bh
data_97		db	0
data_98		db	0, 0
data_99		db	0
data_100	dw	0
data_101	db	0
data_102	db	0
data_103	db	0
data_104	db	0
data_105	dw	0
data_106	dw	0
data_107	db	0
data_108	db	0
data_109	db	0
data_110	db	6
data_111	db	0A0h
data_112	db	0
data_113	db	0
		db	11 dup (0)
data_115	db	0
		db	9 dup (0)

ahadisk		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	near
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+di],al
		add	[bx],cl
		add	[bx+di],al
		add	[bp+si],cl
		add	[si+0],ah
;*		call	sub_5			;*
		db	0E8h, 03h, 10h
		daa				; Decimal adjust
		mov	al,byte ptr ds:[4086h]
		inc	dx
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		ja	$+7			; Jump if above
		add	[bx+si],al
		add	[bx+si],al
		pop	dx
		xor	ax,355Ah
		pop	dx
		xor	ax,577h
		add	[bx+si],al

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		pop	dx
		xor	ax,0
		add	[bx+si],al
		add	[bx+si],al
		pop	dx
		xor	ax,0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		pop	dx
		xor	ax,577h
		pop	dx
		xor	ax,0
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	bh,dh
;*		pop	cs			; Dangerous 8088 only
		db	0Fh
;*		jo	loc_4			;*Jump if overflow=1
		db	 70h,0FFh
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[di+6Eh],al
		jz	loc_5			; Jump if zero
		jc	$+22h			; Jump if carry Set
		inc	sp
		jc	$+6Bh			; Jump if carry Set
		jbe	loc_6			; Jump if below or =
		and	[si+6Fh],dl
		and	[bp+si+65h],al
		and	[bp+6Fh],al
		jc	$+6Fh			; Jump if carry Set
		db	 61h, 74h, 20h, 3Fh, 20h, 5Bh
		db	'A'
		db	 5Dh, 00h
		db	'Enter Drive Type ? (0 - 360K, 1 '
		db	'- 1.2M)  [0]'
		db	0
		db	'Enter Drive Type ? (0 - 720K,'
loc_5:
		and	[bx+di],dh
		and	[di],ch
		and	[bx+di],dh
loc_6:
		db	'.44M) [0]'
		db	0
		db	'Number Of Diskette To Be Format '
		db	'(1-11) ['
data_182	dw	3131h
		db	 5Dh, 20h, 3Fh, 20h, 00h
		db	'Insert New Diskette Into Drive '
data_183	db	41h
		db	0
		db	'Press ENTER To Start Format Or E'
		db	'SC To Abort'
		db	0
		db	'Can', 27h, 't Release From Memor'
		db	'y, Interrupt Vector Address Been'
		db	' Changed'
		db	0
		db	'Press Any Key To Return To Main '
		db	'Menu'
		db	0
		db	'No Format Report !'
		db	 00h, 00h, 00h, 00h, 00h, 2Dh
		db	 00h, 00h, 00h, 00h, 00h
		db	 43h, 70h
data_184	db	'HpApNpGpEpEpRpRpOpRp!pFpIpNpIpSp'
		db	'Hp p p', 0
		db	'p', 0
		db	'p p pDisk Not Ready !', 0
		db	'Disk Write Protected !', 0
		db	'Seek Error !', 0
		db	'Abort or Retry ?', 0
		db	'Track 0 Bad, Diskette Unusable !'
		db	0
		db	'Program Interrupted !', 0
		db	'Ready Printer, Press ENTER When '
		db	'Ready !', 0
		db	'Printing ....', 0
		db	'I/O Error !', 0
		db	'Printer Not Ready !', 0
		db	0C9h, 01h, 4Eh,0CDh,0BBh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 13h, 20h,0ADh
		db	'aHa/nBa!Mem Resident Format '
		db	1, 3
		db	' Version 6.9'
		db	 01h, 10h, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0CCh, 01h
		db	 4Eh,0CDh,0B9h,0BAh, 01h, 4Eh
		db	 20h
		db	0BAh,0BAh, 01h, 4Eh, 20h,0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 4Eh, 20h
		db	0BAh,0BAh, 01h, 4Eh, 20h,0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 4Eh, 20h
		db	0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	4Eh
		db	 20h,0BAh,0BAh, 01h, 4Eh, 20h
		db	0BAh,0BAh, 01h, 4Eh, 20h,0BAh
		db	0BAh, 01h
		db	 4Eh, 20h
		db	0BAh,0C8h, 01h, 4Eh,0CDh,0BCh
		db	 01h, 87h,0D0h, 1Fh,0C9h, 01h
		db	 4Eh,0CDh,0BBh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 13h, 20h
		db	0ADh
		db	'aHa/nBa!Mem Resident Format '
		db	1, 3
		db	' Version 6.9'
		db	 01h, 10h, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0CCh, 01h
		db	 4Eh,0CDh,0B9h,0BAh, 01h, 1Ch
		db	 20h
		db	0DAh, 01h, 15h,0C4h,0BFh, 01h
		db	 1Bh, 20h,0BAh,0BAh, 01h, 1Ch
		db	 20h,0B3h
		db	' Print Out '
		db	0ADh
		db	'aHa/nBa! '
		db	0B3h, 01h, 1Bh, 20h,0BAh,0BAh
		db	 01h, 1Ch, 20h,0C0h, 01h, 15h
		db	0C4h,0D9h, 01h, 1Bh, 20h,0BAh
		db	0BAh, 01h, 1Ch, 20h,0DAh, 01h
		db	 15h,0C4h
		db	0BFh, 01h, 1Bh, 20h,0BAh,0BAh
		db	 01h, 1Ch, 20h,0B3h, 01h, 04h
		db	' Start format'
		db	 01h, 05h, 20h,0B3h, 01h, 1Bh
		db	 20h,0BAh,0BAh, 01h, 1Ch, 20h
		db	0C0h, 01h, 15h,0C4h,0D9h, 01h
		db	 1Bh, 20h,0BAh,0BAh, 01h, 1Ch
		db	 20h,0DAh, 01h, 15h,0C4h,0BFh
		db	 01h, 1Bh, 20h,0BAh,0BAh, 01h
		db	 1Ch, 20h,0B3h, 01h, 04h
		db	' Format report'
		db	 01h, 04h, 20h,0B3h, 01h, 1Bh
		db	 20h,0BAh,0BAh, 01h, 1Ch, 20h
		db	0C0h, 01h, 15h,0C4h,0D9h, 01h
		db	 1Bh, 20h,0BAh,0BAh, 01h, 1Ch
		db	 20h,0DAh, 01h, 15h,0C4h,0BFh
		db	 01h, 1Bh, 20h,0BAh,0BAh, 01h
		db	 1Ch, 20h,0B3h
		db	'  Track display o'
data_187	dw	206Eh
		db	 20h, 20h,0B3h, 01h, 1Bh, 20h
		db	0BAh,0BAh, 01h, 1Ch, 20h,0C0h
		db	 01h, 15h,0C4h,0D9h, 01h, 1Bh
		db	 20h,0BAh,0BAh, 01h, 1Ch, 20h
		db	0DAh, 01h, 15h,0C4h,0BFh, 01h
		db	 1Bh, 20h,0BAh,0BAh, 01h, 1Ch
		db	 20h,0B3h
		db	' Release from memory '
		db	0B3h, 01h, 1Bh, 20h,0BAh,0BAh
		db	 01h, 1Ch, 20h,0C0h, 01h, 15h
		db	0C4h,0D9h, 01h, 1Bh, 20h,0BAh
		db	0BAh, 01h, 1Ch, 20h,0DAh, 01h
		db	 15h,0C4h,0BFh, 01h, 1Bh, 20h
		db	0BAh,0BAh, 01h, 1Ch, 20h,0B3h
		db	 01h, 09h, 20h, 45h, 78h, 69h
		db	 74h, 01h, 08h, 20h,0B3h, 01h
		db	 1Bh, 20h,0BAh,0BAh, 01h, 1Ch
		db	 20h,0C0h, 01h, 15h,0C4h,0D9h
		db	 01h, 1Bh, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0C8h, 01h, 4Eh
		db	0CDh,0BCh, 01h, 87h,0D0h, 1Fh
		db	0C9h, 01h, 4Eh,0CDh,0BBh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 13h, 20h,0ADh
		db	'aHa/nBa!Mem Resident Format '
		db	1, 3
		db	' Version 6.9'
		db	 01h, 10h, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0CCh, 01h
		db	4Eh
		db	0CDh,0B9h,0BAh, 01h, 4Eh, 20h
		db	0BAh,0BAh, 01h, 4Eh, 20h,0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 4Eh, 20h
		db	0BAh,0BAh, 01h, 4Eh, 20h,0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 4Eh, 20h
		db	0BAh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 4Eh, 20h,0BAh,0CCh, 01h
		db	 17h
		db	0CDh,0D1h, 01h, 0Fh,0CDh,0D1h
		db	 01h, 10h,0CDh,0D1h, 01h, 15h
		db	0CDh,0B9h,0BAh, 01h
		db	3
		db	' Drive To Be Format  '
		db	0B3h, 01h, 03h
		db	' Drive Type  '
		db	0B3h
		db	'  Diskette No.  '
		db	0B3h
		db	'  Total Diskette(s)  '
		db	0BAh,0C7h, 01h, 17h,0C4h,0C5h
		db	 01h, 0Fh,0C4h,0C5h, 01h, 10h
		db	0C4h,0C5h, 01h, 15h,0C4h,0B6h
		db	0BAh, 01h, 0Bh
		db	20h
data_188	db	41h
		db	 01h, 0Bh, 20h,0B3h, 01h, 05h
		db	 20h
data_189	db	31h
		db	 2Eh, 34h, 34h, 20h, 4Dh, 01h
		db	 04h, 20h,0B3h, 01h, 06h
		db	20h
data_190	dw	3120h
		db	 01h, 08h, 20h,0B3h, 01h
		db	 09h, 20h
data_191	dw	3131h
		db	1
		db	 0Ah, 20h,0BAh,0C8h, 01h
		db	 17h,0CDh,0CFh, 01h, 0Fh,0CDh
		db	0CFh, 01h, 10h,0CDh,0CFh, 01h
		db	 15h,0CDh,0BCh, 01h, 87h,0D0h
		db	 1Fh,0C9h, 01h, 4Eh,0CDh,0BBh
		db	0BAh, 01h, 4Eh, 20h,0BAh,0BAh
		db	 01h, 13h
		db	' Background Diskette Formatter S'
		db	'tatus Report'
		db	 01h, 10h, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0BAh, 01h, 4Eh
		db	 20h,0BAh,0CCh, 01h, 0Ch,0CDh
		db	0D1h
		db	 01h, 15h,0CDh,0D1h, 01h, 11h
		db	0CDh
		db	0D1h, 01h, 19h,0CDh,0B9h,0BAh
		db	'  Diskette  '
		db	0B3h, 01h, 07h, 20h, 56h, 6Fh
		db	 6Ch, 75h, 6Dh, 65h, 01h, 08h
		db	 20h,0B3h, 01h, 05h, 20h, 4Eh
		db	 6Fh, 2Eh, 20h, 4Fh, 66h, 01h
		db	 06h, 20h,0B3h, 01h, 04h
		db	' Total Disk Space'
		db	 01h, 05h, 20h,0BAh,0BAh, 01h
		db	 05h, 20h, 4Eh, 6Fh, 2Eh, 01h
		db	 04h, 20h,0B3h, 01h, 04h
		db	' Serial Number'
		db	 01h, 04h, 20h,0B3h
		db	'  Bad Cluster(s) '
		db	0B3h, 01h
		db	8, ' In Bytes'
		db	 01h, 09h, 20h,0BAh,0C7h, 01h
		db	 0Ch,0C4h,0C5h, 01h, 15h,0C4h
		db	0C5h, 01h, 11h,0C4h,0C5h, 01h
		db	 19h,0C4h,0B6h
		db	0BAh, 01h, 0Ch, 20h
		db	0B3h, 01h, 15h
		db	 20h,0B3h, 01h, 11h, 20h,0B3h
		db	 01h, 19h, 20h,0BAh,0BAh, 01h
		db	 0Ch, 20h,0B3h, 01h, 15h, 20h
		db	0B3h, 01h, 11h, 20h,0B3h, 01h
		db	 19h, 20h,0BAh,0BAh, 01h, 0Ch
		db	 20h,0B3h, 01h, 15h, 20h,0B3h
		db	 01h, 11h, 20h,0B3h, 01h, 19h
		db	 20h,0BAh,0BAh, 01h, 0Ch, 20h
		db	0B3h, 01h, 15h, 20h,0B3h, 01h
		db	 11h
		db	20h
		db	0B3h, 01h, 19h, 20h,0BAh,0BAh
		db	 01h, 0Ch, 20h,0B3h, 01h, 15h
		db	 20h,0B3h, 01h, 11h, 20h,0B3h
		db	 01h, 19h, 20h,0BAh,0BAh, 01h
		db	 0Ch, 20h,0B3h, 01h, 15h, 20h
		db	0B3h, 01h, 11h, 20h,0B3h, 01h
		db	 19h, 20h,0BAh,0BAh, 01h, 0Ch
		db	 20h,0B3h, 01h, 15h, 20h,0B3h
		db	 01h, 11h, 20h,0B3h, 01h, 19h
		db	 20h,0BAh,0BAh, 01h, 0Ch, 20h
		db	0B3h, 01h, 15h, 20h,0B3h, 01h
		db	 11h, 20h,0B3h, 01h, 19h, 20h
		db	0BAh,0BAh, 01h, 0Ch, 20h,0B3h
		db	 01h, 15h, 20h,0B3h, 01h, 11h
		db	 20h,0B3h, 01h, 19h, 20h,0BAh
		db	0BAh, 01h, 0Ch, 20h,0B3h, 01h
		db	 15h, 20h,0B3h, 01h, 11h, 20h
		db	0B3h, 01h, 19h, 20h,0BAh,0BAh
		db	 01h, 0Ch, 20h,0B3h, 01h, 15h
		db	 20h,0B3h, 01h, 11h, 20h,0B3h
		db	 01h, 19h, 20h,0BAh,0CCh, 01h
		db	 0Ch,0CDh,0CFh, 01h, 15h,0CDh
		db	0CFh, 01h, 11h,0CDh,0CFh, 01h
		db	 19h,0CDh,0B9h,0BAh, 01h, 4Eh
		db	 20h,0BAh,0BAh, 01h, 15h
		db	 20h, 50h
		db	'ress Any Key To Return To Main M'
		db	'enu'
		db	 01h, 15h, 20h,0BAh,0BAh, 01h
		db	 4Eh, 20h,0BAh,0C8h, 01h, 4Eh
		db	0CDh,0BCh, 01h, 87h,0D0h, 1Fh
		db	 0Dh, 0Ah, 0Dh, 0Ah, 20h
		db	9 dup (20h)
		db	0ADh
		db	'aHa/nBa! Application Form!      '
		db	'                          ', 0Dh
		db	0Ah, 'What file is this?', 0Dh, 0Ah
		db	'                      Where Did '
		db	'you get it from?', 0Dh, 0Ah, '  '
		db	'                  Handle:', 0Dh, 0Ah
		db	'       Phone #:', 0Dh, 0Ah, '   '
		db	'   ', 0Dh, 0Ah, '               '
		db	'               List 3 boards whe'
		db	're you could be reached at:    ', 0Dh
		db	0Ah, 0Dh, 0Ah, '                 '
		db	'                           Can y'
		db	'ou HaCK?', 0Dh, 0Ah, '          '
		db	'                       List a fe'
		db	'w thigs you', 27h, 've hacked:', 0Dh
		db	0Ah, 0Dh, 0Ah, '                 '
		db	'            Ok! Send MoneY, pft,'
		db	' and this letter to:', 0Dh, 0Ah, ' '
		db	'                     Psycho', 0Dh
		db	0Ah, '        1340 W Irving', 0Dh
		db	0Ah, ' #229', 0Dh, 0Ah, '        '
		db	'  Chicago, IL', 0Dh, 0Ah, '   60'
		db	'613', 0Dh, 0Ah, '               '
		db	'                          Ok! No'
		db	'w, write about yourself:        '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'                                '
		db	'        ', 0Ch, 0
		db	'.'
		db	 80h, 3Eh, 2Dh, 02h, 00h, 74h
		db	 08h, 2Eh,0FEh, 0Eh, 2Dh, 02h
		db	0EBh, 09h, 90h
		db	 2Eh,0F6h, 06h, 2Eh, 02h, 80h
		db	 75h, 05h
loc_32:
		jmp	dword ptr cs:[195h]
loc_33:
		mov	word ptr cs:[1EAh],ax
		mov	al,0Bh
		out	20h,al			; port 20h, 8259-1 int command
		jmp	short $+2		; delay for I/O
		in	al,20h			; port 20h, 8259-1 int IRR/ISR
		and	al,0FEh
		mov	ax,word ptr cs:[1EAh]
		jz	loc_34			; Jump if zero
		jmp	short loc_32
loc_34:
		mov	word ptr cs:[1FCh],ax
		mov	word ptr cs:[1FEh],bx
		mov	word ptr cs:[208h],sp
		mov	word ptr cs:[20Eh],ss
		mov	word ptr cs:[20Ch],ds
		mov	word ptr cs:[210h],es
		mov	word ptr cs:[20Ah],bp
		mov	word ptr cs:[204h],si
		mov	word ptr cs:[206h],di
		mov	word ptr cs:[200h],cx
		mov	word ptr cs:[202h],dx
		mov	ds,word ptr cs:[1E2h]
		mov	ss,word ptr ds:[1DAh]
		mov	sp,word ptr ds:[1DCh]
		mov	es,word ptr ds:[1E4h]
		mov	bp,word ptr ds:[1E0h]
		mov	si,word ptr ds:[1D8h]
		mov	di,word ptr ds:[1DEh]
		mov	ax,word ptr ds:[1D0h]
		mov	bx,word ptr ds:[1D2h]
		mov	cx,word ptr ds:[1D4h]
		mov	dx,word ptr ds:[1D6h]
		jmp	dword ptr cs:[195h]
		mov	word ptr cs:[1F8h],ds
		mov	word ptr cs:[1F6h],ax
		mov	word ptr cs:[1FAh],bx
		mov	ds,cs:data_25
		mov	bx,keybd_flags_1_
		mov	ah,[bx]
		and	ah,0Fh
		cmp	ah,0Bh
		jne	loc_36			; Jump if not equal
		test	byte ptr cs:[22Eh],0C0h
		jz	loc_35			; Jump if zero
		test	byte ptr cs:[22Eh],40h	; '@'
		jz	loc_36			; Jump if zero
		or	byte ptr cs:[22Eh],20h	; ' '
		jmp	short loc_36
		db	90h
loc_35:
		or	byte ptr cs:[22Eh],80h
loc_36:
		mov	ax,word ptr cs:[1F6h]
		mov	ds,word ptr cs:[1F8h]
		mov	bx,word ptr cs:[1FAh]
		jmp	dword ptr cs:[199h]
		db	 2Eh, 80h, 3Eh, 2Fh, 02h, 00h
		db	 74h, 0Dh, 2Eh,0C6h, 06h, 2Fh
		db	 02h, 00h, 50h,0B0h, 66h,0E6h
		db	 20h, 58h,0CFh
loc_37:
		jmp	dword ptr cs:[19Dh]
		test	dl,80h
		jnz	loc_38			; Jump if not zero
		test	byte ptr cs:[22Eh],40h	; '@'
		jz	loc_38			; Jump if zero
		mov	word ptr cs:[1EAh],ax
		pop	ax
		pop	ax
		pop	ax
		or	ax,1
		push	ax
		sub	sp,4
		mov	ax,word ptr cs:[1EAh]
		mov	ah,80h
		iret				; Interrupt return
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
loc_38:
		jmp	dword ptr cs:[1A1h]
		mov	byte ptr ds:[22Eh],40h	; '@'
		call	sub_28
		jnc	loc_40			; Jump if carry=0
		clc				; Clear carry flag
loc_39:
		call	sub_11
		jmp	loc_121
loc_40:
		mov	ds,data_25
		test	byte ptr ds:dsk_motor_stat_,0Fh
		push	cs
		pop	ds
		jnz	loc_39			; Jump if not zero
		call	sub_22
		call	sub_23
loc_41:
		mov	ax,55Ch
		mov	cs:data_93,ax
		call	sub_21
		mov	data_112,70h		; 'p'
		call	sub_27
		call	sub_13
loc_42:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		je	loc_48			; Jump if equal
		cmp	al,0Dh
		je	loc_49			; Jump if equal
		cmp	ah,48h			; 'H'
		je	loc_50			; Jump if equal
		cmp	ah,50h			; 'P'
		je	loc_53			; Jump if equal
		and	al,0DFh
		cmp	al,50h			; 'P'
		je	loc_43			; Jump if equal
		cmp	al,52h			; 'R'
		je	loc_47			; Jump if equal
		cmp	al,45h			; 'E'
		je	loc_48			; Jump if equal
		cmp	al,53h			; 'S'
		je	loc_44			; Jump if equal
		cmp	al,46h			; 'F'
		je	loc_45			; Jump if equal
		cmp	al,54h			; 'T'
		je	loc_46			; Jump if equal
		call	sub_11
		jmp	short loc_42
loc_43:
		jmp	loc_137
loc_44:
		jmp	short loc_55
		db	90h
loc_45:
		jmp	loc_145
loc_46:
		jmp	loc_149
loc_47:
		jmp	loc_151
loc_48:
		jmp	loc_154
loc_49:
		mov	al,3
		mul	data_107		; ax = data * al
		add	ax,offset loc_43
		jmp	ax			;*Register jump
loc_50:
		mov	data_112,1Fh
		call	sub_27
		cmp	data_107,0
		je	loc_52			; Jump if equal
		dec	data_107
		sub	data_110,3
loc_51:
		mov	data_112,70h		; 'p'
		call	sub_27
		jmp	short loc_42
loc_52:
		mov	data_107,5
		mov	data_110,15h
		jmp	short loc_51
loc_53:
		mov	data_112,1Fh
		call	sub_27
		cmp	data_107,5
		je	loc_54			; Jump if equal
		inc	data_107
		add	data_110,3
		jmp	short loc_51
loc_54:
		mov	data_107,0
		mov	data_110,6
		jmp	short loc_51
loc_55:
		call	sub_19
		mov	data_190,3120h
		cmp	data_28,1
		jne	loc_56			; Jump if not equal
		mov	data_29,0
		jmp	short loc_60
		db	90h
loc_56:
		mov	dh,0Dh
		mov	dl,18h
		mov	si,232h
		call	sub_14
		call	sub_13
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		jne	loc_57			; Jump if not equal
		jmp	loc_41
loc_57:
		cmp	al,0Dh
		je	loc_60			; Jump if equal
		and	al,0DFh
		sub	al,41h			; 'A'
		jge	loc_59			; Jump if > or =
loc_58:
		call	sub_11
		jmp	short loc_55
loc_59:
		cmp	al,data_28
		jge	loc_58			; Jump if > or =
		mov	data_29,al
		add	al,41h			; 'A'
		mov	byte ptr ds:[24Eh],al	; ('A')
		mov	data_183,al
		mov	data_188,al
loc_60:
		call	sub_19
		call	sub_37
		test	byte ptr [bx],1
		jz	loc_63			; Jump if zero
		mov	dh,10h
		mov	dl,14h
		test	byte ptr [bx],2
		jnz	loc_61			; Jump if not zero
		mov	si,251h
		jmp	short loc_62
		db	90h
loc_61:
		mov	si,27Eh
loc_62:
		call	sub_14
		call	sub_13
		mov	al,31h			; '1'
		mov	data_102,al
		mov	al,[si-3]
		mov	data_103,al
		mov	data_89,1331h
		call	sub_16
		and	byte ptr [si-3],0FEh
		or	[si-3],al
		xor	al,1
		xor	data_31,ax
loc_63:
		mov	ax,data_31
		call	sub_39
loc_64:
		call	sub_20
		mov	dh,0Bh
		mov	dl,14h
		mov	si,2ABh
		call	sub_14
		call	sub_38
		cmp	data_101,0
		je	loc_69			; Jump if equal
		mov	ax,word ptr ds:[137h]
		mov	bx,ax
		cmp	data_101,1
		jne	loc_65			; Jump if not equal
		xchg	bh,bl
		xor	bl,bl			; Zero register
		sub	al,30h			; '0'
		jmp	short loc_67
		db	90h
loc_65:
		sub	al,27h			; '''
		cmp	al,0Ah
		jg	loc_64			; Jump if >
		jz	loc_66			; Jump if zero
		xor	al,al			; Zero register
loc_66:
		sub	ah,30h			; '0'
		add	al,ah
		cmp	al,0Bh
		jg	loc_64			; Jump if >
loc_67:
		cmp	al,0
		je	loc_64			; Jump if equal
		mov	data_96,al
		or	bl,20h			; ' '
		cmp	bl,30h			; '0'
		jne	loc_68			; Jump if not equal
		mov	bl,20h			; ' '
loc_68:
		mov	data_191,bx
		mov	data_182,bx
loc_69:
		mov	data_100,0F5h
		mov	data_95,0
		mov	data_99,0
		call	sub_20
		mov	dh,0Ah
		mov	dl,18h
		mov	si,2DAh
		call	sub_14
		mov	dh,0Ch
		mov	dl,13h
		mov	si,2FBh
		call	sub_14
		call	sub_13
loc_70:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,0Dh
		je	loc_72			; Jump if equal
		cmp	al,1Bh
		jne	loc_71			; Jump if not equal
		jmp	loc_41
loc_71:
		call	sub_11
		jmp	short loc_70
loc_72:
		mov	data_82,1525h
		cli				; Disable interrupts
		pushf				; Push flags
		push	cs
		mov	ax,201h
		mov	bx,28E9h
		mov	cx,1
		mov	dl,data_29
		xor	dh,dh			; Zero register
		call	sub_6
		jnc	loc_78			; Jump if carry=0
		clc				; Clear carry flag
		test	ah,80h
		jz	loc_78			; Jump if zero
		call	sub_11
		xor	cx,cx			; Zero register

locloop_73:
		loop	locloop_73		; Loop if cx > 0

		call	sub_11
		call	sub_56
		call	sub_20
		mov	dh,0Ah
		mov	dl,20h			; ' '
		mov	si,3DAh
		call	sub_14
loc_74:
		mov	dh,0Eh
		mov	dl,20h			; ' '
		mov	si,40Fh
		call	sub_14
		call	sub_13
loc_75:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		je	loc_77			; Jump if equal
		and	al,0DFh
		cmp	al,52h			; 'R'
		jne	loc_76			; Jump if not equal
		jmp	data_82
loc_76:
		cmp	al,41h			; 'A'
		je	loc_77			; Jump if equal
		call	sub_11
		jmp	short loc_75
loc_77:
		jmp	loc_135
loc_78:
		call	sub_24
		call	sub_61
		or	byte ptr ds:[22Eh],80h
		cli				; Disable interrupts
		call	sub_7
loc_79:
		call	sub_52
		call	sub_60
		mov	data_82,1596h
		call	sub_64
		test	data_73,0C0h
		jz	loc_80			; Jump if zero
		call	sub_64
		test	data_73,0C0h
		jz	loc_80			; Jump if zero
		jmp	loc_123
loc_80:
		call	sub_74
		test	data_73,0C0h
		jz	loc_81			; Jump if zero
		jmp	short loc_83
		db	90h
loc_81:
		cmp	byte ptr ds:[230h],0
		je	loc_82			; Jump if equal
		mov	ax,word ptr ds:[243Dh]
		cmp	data_218,ax
		jne	loc_82			; Jump if not equal
		mov	ax,word ptr ds:[243Fh]
		cmp	data_219,ax
		jne	loc_82			; Jump if not equal
		jmp	loc_117
loc_82:
		cmp	byte ptr data_214,0EBh
		jne	loc_83			; Jump if not equal
		cmp	data_217,200h
		jne	loc_83			; Jump if not equal
		mov	data_84,1626h
		jmp	short loc_84
		db	90h
loc_83:
		mov	data_84,1623h
loc_84:
		call	sub_77
		jnc	loc_85			; Jump if carry=0
		jmp	loc_123
loc_85:
		test	al,40h			; '@'
		jz	loc_87			; Jump if zero
loc_86:
		mov	data_62,3
		jmp	loc_125
loc_87:
		mov	byte ptr ds:[230h],0
loc_88:
		mov	data_82,161Fh
loc_89:
		jmp	data_84
		call	sub_78
		mov	data_68,28E9h
		mov	ax,word ptr data_60
		mov	data_67,ax
		mov	data_69,42h		; 'B'
		mov	data_70,0E6h
		mov	data_85,27F1h
		call	sub_75
		test	data_73,0C0h
		jz	loc_95			; Jump if zero
		test	data_74,20h		; ' '
		jz	loc_90			; Jump if zero
		cmp	data_94,2
		je	loc_93			; Jump if equal
		inc	data_94
		jmp	short loc_91
		db	90h
loc_90:
		mov	data_94,0
loc_91:
		call	sub_65
		test	data_73,0C0h
		jz	loc_92			; Jump if zero
		jmp	loc_123
loc_92:
		mov	data_84,1623h
		jmp	short loc_88
loc_93:
		mov	data_94,0
		cmp	data_65,0
		jne	loc_94			; Jump if not equal
		jmp	loc_105
loc_94:
		call	sub_51
loc_95:
		cmp	data_64,0
		jne	loc_97			; Jump if not equal
		mov	data_64,1
loc_96:
		jmp	short loc_89
loc_97:
		call	sub_9
		mov	data_82,161Fh
		mov	data_64,0
		inc	data_65
		inc	data_63
		cmp	data_31,0
		jne	loc_98			; Jump if not equal
		inc	data_63
loc_98:
		call	sub_46
		cmp	data_63,50h		; 'P'
		jge	loc_99			; Jump if > or =
		call	sub_63
		test	data_73,0C0h
		jz	loc_96			; Jump if zero
		call	sub_65
		test	data_73,0C0h
		jz	loc_96			; Jump if zero
		jmp	short loc_100
		db	90h
loc_99:
		mov	data_65,0
		mov	data_63,0
		mov	data_66,1
		mov	data_64,0
		mov	data_59,0
		call	sub_63
		test	data_73,0C0h
		jz	loc_101			; Jump if zero
		call	sub_65
		test	data_73,0C0h
		jz	loc_101			; Jump if zero
loc_100:
		mov	data_62,40h		; '@'
		jmp	loc_125
loc_101:
		mov	data_82,1712h
		call	sub_78
		cmp	data_64,1
		je	loc_102			; Jump if equal
		mov	data_64,1
		jmp	short loc_101
loc_102:
		call	sub_52
		mov	ds,data_25
		mov	ax,word ptr ds:timer_low_+1
		push	cs
		pop	ds
		mov	word ptr ds:[243Dh],ax
loc_103:
		mov	data_82,1738h
		mov	data_64,0
		mov	data_68,2416h
		mov	data_67,1FFh
		mov	data_69,4Ah		; 'J'
		mov	data_70,0C5h
		mov	data_85,27F1h
		call	sub_75
		test	data_73,0C0h
		jz	loc_106			; Jump if zero
		test	data_74,2
		jz	loc_104			; Jump if zero
		jmp	loc_86
loc_104:
		cmp	data_94,0
		jne	loc_105			; Jump if not equal
		inc	data_94
		call	sub_65
		test	data_73,0C0h
		jz	loc_103			; Jump if zero
		jmp	loc_123
loc_105:
		mov	data_62,20h		; ' '
		jmp	loc_125
loc_106:
		call	sub_53
		mov	byte ptr ds:[21Ah],2
		mov	al,byte ptr ds:[242Bh]
		mov	data_214,al
		mov	data_215,0FFFFh
		mov	word ptr ds:[223h],0
		mov	word ptr ds:[21Fh],0
		mov	word ptr ds:[212h],139h
loc_107:
		mov	cx,80h
		mov	si,word ptr ds:[212h]
loc_108:
		mov	word ptr ds:[218h],cx
		mov	word ptr ds:[214h],si
		call	sub_55
		sub	ax,word ptr ds:[21Fh]
		test	cx,[si]
		jz	loc_113			; Jump if zero
		cmp	ax,200h
		jl	loc_109			; Jump if <
		mov	word ptr ds:[21Bh],ax
		call	sub_49
		call	sub_53
		call	sub_50
		mov	ax,word ptr ds:[21Bh]
		sub	ax,200h
loc_109:
		mov	di,offset data_214
		add	di,ax
		mov	al,data_56
		cbw				; Convrt byte to word
		cmp	al,9
		jne	loc_110			; Jump if not equal
		clc				; Clear carry flag
		rcr	ax,1			; Rotate thru carry
		adc	ax,0
loc_110:
		mov	cx,ax
		mov	si,word ptr ds:[229h]
loc_111:
		mov	bx,225h
		mov	ax,[bx+si]
		mov	bx,[di]
		or	ax,bx
		cld				; Clear direction
		stosw				; Store ax to es:[di]
		xor	si,2
		nop				;*ASM fixup - sign extn byte
		jz	loc_112			; Jump if zero
		dec	di
loc_112:
		dec	cx
		jnz	loc_111			; Jump if not zero
		mov	word ptr ds:[21Dh],di
		jmp	short loc_114
		db	90h
loc_113:
		cmp	ax,200h
		jl	loc_114			; Jump if <
		call	sub_49
		call	sub_53
		call	sub_50
loc_114:
		mov	word ptr ds:[21Bh],ax
		mov	al,data_56
		cbw				; Convrt byte to word
		add	word ptr ds:[223h],ax
		mov	ax,word ptr ds:[21Bh]
		mov	cx,word ptr ds:[218h]
		mov	si,word ptr ds:[214h]
		shr	cx,1			; Shift w/zeros fill
		jz	loc_115			; Jump if zero
		jmp	loc_108
loc_115:
		inc	word ptr ds:[212h]
		mov	ax,word ptr ds:[212h]
		cmp	ax,word ptr ds:[216h]
		je	loc_116			; Jump if equal
		jmp	loc_107
loc_116:
		call	sub_49
		call	sub_54
		mov	di,data_100
		mov	ax,word ptr ds:[243Fh]
		xchg	ah,al
		cld				; Clear direction
		stosw				; Store ax to es:[di]
		mov	ax,word ptr ds:[243Dh]
		xchg	ah,al
		stosw				; Store ax to es:[di]
		mov	ax,word ptr data_98
		stosw				; Store ax to es:[di]
		mov	data_100,di
		inc	data_95
		inc	data_99
		call	sub_12
		mov	al,data_96
		cmp	data_95,al
		je	loc_119			; Jump if equal
loc_117:
		mov	byte ptr ds:[230h],1
		mov	ds,data_25
		mov	byte ptr ds:dsk_motor_tmr_,2
		push	cs
		pop	ds
		mov	data_92,3AAh
		call	sub_45
		mov	cx,88h

locloop_118:
		call	sub_7
		call	sub_9
		mov	cx,word ptr ds:[22Bh]
		mov	data_82,1596h
		loop	locloop_118		; Loop if cx > 0

		jmp	loc_79
loc_119:
		mov	data_92,3C2h
		call	sub_45
		mov	data_107,2
		mov	data_110,0Ch
loc_120:
		mov	data_81,130Dh
		mov	byte ptr ds:[230h],0
		call	sub_8
loc_121:
		and	byte ptr ds:[22Eh],0
		mov	sp,2B84h
		mov	ax,202h
		push	ax
		push	cs
		mov	ax,data_81
		push	ax
		mov	word ptr cs:[1DCh],sp
loc_122:
		mov	ss,word ptr ds:[20Eh]
		mov	sp,word ptr ds:[208h]
		mov	es,word ptr ds:[210h]
		mov	bp,word ptr ds:[20Ah]
		mov	si,word ptr ds:[204h]
		mov	di,word ptr ds:[206h]
		mov	ax,word ptr ds:[1FCh]
		mov	bx,word ptr ds:[1FEh]
		mov	cx,word ptr ds:[200h]
		mov	dx,word ptr ds:[202h]
		mov	ds,word ptr ds:[20Ch]
		iret				; Interrupt return
loc_123:
		mov	byte ptr ds:[22Fh],0
		mov	dx,3F2h
		mov	al,8
		out	dx,al			; port 3F2h, dsk0 contrl output
		cmp	byte ptr ds:[230h],0
		je	loc_124			; Jump if equal
		jmp	loc_117
loc_124:
		mov	data_62,80h
loc_125:
		mov	data_92,3B6h
		call	sub_45
		call	sub_12
		mov	byte ptr ds:[22Dh],6
		call	sub_7
		call	sub_12
		call	sub_8
		mov	data_81,195Dh
		jmp	short loc_121
sub_6		endp

loc_126:
		and	byte ptr cs:[22Eh],7Fh
		call	sub_28
		jnc	loc_128			; Jump if carry=0
		clc				; Clear carry flag
		call	sub_11
		test	byte ptr ds:[22Eh],20h	; ' '
		jnz	loc_127			; Jump if not zero
		jmp	loc_121
loc_127:
		jmp	loc_120
loc_128:
		call	sub_22
		call	sub_23
		call	sub_56
		call	sub_20
		cmp	data_62,80h
		je	loc_129			; Jump if equal
		cmp	data_62,3
		je	loc_132			; Jump if equal
		cmp	data_62,40h		; '@'
		je	loc_131			; Jump if equal
		cmp	data_62,20h		; ' '
		je	loc_130			; Jump if equal
		mov	dh,0Ah
		mov	dl,1Eh
		mov	si,441h
		call	sub_14
		jmp	short loc_133
		db	90h
loc_129:
		mov	dh,0Ah
		mov	dl,20h			; ' '
		mov	si,3DAh
		call	sub_14
		jmp	short loc_133
		db	90h
loc_130:
		mov	dh,0Ah
		mov	dl,18h
		mov	si,420h
		call	sub_14
		jmp	short loc_133
		db	90h
loc_131:
		mov	dh,0Ah
		mov	dl,22h			; '"'
		mov	si,402h
		call	sub_14
		jmp	short loc_133
		db	90h
loc_132:
		mov	dh,0Ah
		mov	dl,1Dh
		mov	si,3EBh
		call	sub_14
loc_133:
		mov	dh,0Eh
		mov	dl,20h			; ' '
		mov	data_62,0
		mov	si,40Fh
		call	sub_14
		call	sub_13
loc_134:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		je	loc_135			; Jump if equal
		and	al,0DFh
		cmp	al,52h			; 'R'
		je	loc_136			; Jump if equal
		cmp	al,41h			; 'A'
		je	loc_135			; Jump if equal
		call	sub_11
		jmp	short loc_134
loc_135:
		call	sub_24
		mov	data_107,0
		mov	data_110,6
		jmp	loc_120
loc_136:
		call	sub_24
		cli				; Disable interrupts
		mov	byte ptr ds:[22Eh],0C0h
		call	sub_7
		call	sub_65
		mov	cx,5
		jmp	data_82
loc_137:
		call	sub_19
		mov	dh,0Dh
		mov	dl,15h
		mov	si,457h
		call	sub_14
		call	sub_13
loc_138:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		je	loc_144			; Jump if equal
		cmp	al,0Dh
		je	loc_139			; Jump if equal
		call	sub_11
		jmp	short loc_138
loc_139:
		call	sub_19
		mov	dh,0Dh
		mov	dl,21h			; '!'
		mov	si,47Fh
		call	sub_14
		call	sub_13
		mov	bp,0A2Bh
loc_140:
		mov	ah,2
		xor	dx,dx			; Zero register
		int	17h			; Printer  dx=prn1, ah=func 02h
						;  read status, ah=return status
		test	ah,10h
		jz	loc_143			; Jump if zero
		mov	al,[bp]
		cmp	al,0
		je	loc_144			; Jump if equal
		xor	ah,ah			; Zero register
		xor	dx,dx			; Zero register
		int	17h			; Printer  dx=prn1, ah=func 00h
						;  print char al, get status ah
		test	ah,29h			; ')'
		jnz	loc_141			; Jump if not zero
		inc	bp
		jmp	short loc_140
loc_141:
		call	sub_19
		mov	dh,0Ch
		mov	dl,23h			; '#'
		mov	si,48Dh
loc_142:
		call	sub_14
		mov	data_82,1A2Eh
		jmp	loc_74
loc_143:
		call	sub_19
		mov	dh,0Ch
		mov	dl,1Eh
		mov	si,499h
		jmp	short loc_142
loc_144:
		jmp	loc_41
loc_145:
		cmp	data_95,0
		jne	loc_147			; Jump if not equal
		call	sub_19
		mov	dh,0Dh
		mov	dl,20h			; ' '
		mov	si,38Dh
		call	sub_14
loc_146:
		mov	dh,0Fh
		mov	dl,16h
		mov	si,368h
		call	sub_14
		call	sub_13
		jmp	short loc_148
		db	90h
loc_147:
		mov	ax,838h
		mov	cs:data_93,ax
		call	sub_21
		call	sub_31
loc_148:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		mov	data_107,5
		mov	data_110,15h
		jmp	loc_41
loc_149:
		cmp	data_187,6666h
		je	loc_150			; Jump if equal
		mov	data_187,6666h
		jmp	loc_41
loc_150:
		mov	data_187,206Eh
		jmp	loc_41
loc_151:
		mov	ax,11E0h
		mov	di,20h			; (' ')
		call	sub_30
		jc	loc_152			; Jump if carry Set
		mov	ax,12E6h
		mov	di,offset data_42
		call	sub_30
		jc	loc_152			; Jump if carry Set
		mov	ax,12CCh
		mov	di,offset data_38
		call	sub_30
		jc	loc_152			; Jump if carry Set
		mov	ax,127Ah
		mov	di,24h			; (' ')
		call	sub_30
		jnc	loc_153			; Jump if carry=0
loc_152:
		clc				; Clear carry flag
		call	sub_19
		mov	dh,0Ch
		mov	dl,8
		mov	si,327h
		call	sub_14
		jmp	loc_146
loc_153:
		xor	ax,ax			; Zero register
		mov	word ptr data_24,ax
		mov	si,offset 195h
		mov	di,20h			; (' ')
		call	sub_29
		mov	si,offset 199h
		mov	di,24h			; (' ')
		call	sub_29
		mov	si,offset 19Dh
		mov	di,offset data_38
		call	sub_29
		mov	si,offset 1A1h
		mov	di,offset data_42
		call	sub_29
		mov	es,data_26
		mov	di,data_2e
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		mov	es,data_27
		mov	di,data_2e
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		push	cs
		pop	es
		call	sub_24
		call	sub_7
loc_154:
		mov	data_107,0
		mov	data_110,6
		call	sub_24
		jmp	loc_121

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
		add	byte ptr ds:[22Dh],1
		cli				; Disable interrupts
		mov	word ptr ds:[1D0h],ax
		pop	ax
		pushf				; Push flags
		push	cs
		push	ax
		mov	word ptr ds:[1DCh],sp
		mov	word ptr ds:[1D2h],bx
		mov	word ptr ds:[1DAh],ss
		mov	word ptr ds:[1E2h],ds
		mov	word ptr ds:[1E4h],es
		mov	word ptr ds:[1E0h],bp
		mov	word ptr ds:[1D8h],si
		mov	word ptr ds:[1DEh],di
		mov	word ptr ds:[1D4h],cx
		mov	word ptr ds:[1D6h],dx
		jmp	loc_122
sub_7		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	al,data_29
		cbw				; Convrt byte to word
		mov	di,ax
		mov	ds,data_25
		and	byte ptr ds:hdsk0_media_st_[di],0EFh
		mov	byte ptr ds:dsk_motor_tmr_,2
		mov	byte ptr ds:dsk_recal_stat_,0
		push	cs
		pop	ds
		retn
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		mov	word ptr ds:[22Bh],cx
		test	byte ptr ds:[22Eh],20h	; ' '
		jz	loc_ret_155		; Jump if zero
		pop	ax
		mov	data_82,ax
		jmp	loc_126

loc_ret_155:
		retn
sub_9		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		mov	ah,0Eh
		mov	bh,0
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_11		proc	near
		push	ax
		push	bx
		mov	al,7
		call	sub_10
		pop	bx
		pop	ax
		retn
sub_11		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		call	sub_7
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 wrt timr mode
		mov	ax,180h
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,ah
		out	42h,al			; port 42h, 8253 timer 2 spkr
		in	al,61h			; port 61h, 8255 port B, read
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		call	sub_7
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FCh
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, disable parity
		retn
sub_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		mov	ah,2
		mov	dx,2000h
		mov	bh,data_104
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		retn
sub_13		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_14		proc	near
		mov	ah,2
		mov	bh,0
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		call	sub_15
		retn
sub_14		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_15		proc	near
loc_156:
		cld				; Clear direction
		lodsb				; String [si] to al
		cmp	al,0
		je	loc_ret_157		; Jump if equal
		mov	ah,0Eh
		mov	bh,0
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_156

loc_ret_157:
		retn
sub_15		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_16		proc	near
loc_158:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,1Bh
		jne	loc_159			; Jump if not equal
		pop	ax
		jmp	data_89
loc_159:
		cmp	al,0Dh
		jne	loc_160			; Jump if not equal
		mov	al,data_103
		jmp	short loc_161
		db	90h
loc_160:
		cmp	al,30h			; '0'
		jl	loc_162			; Jump if <
		cmp	al,data_102
		jg	loc_162			; Jump if >
loc_161:
		and	ax,7
		retn
loc_162:
		call	sub_11
		jmp	short loc_158
sub_16		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17		proc	near
		mov	cx,0FA0h
		shr	cx,1			; Shift w/zeros fill
		cld				; Clear direction
		lodsb				; String [si] to al
		inc	si
		xchg	ah,al
loc_163:
		lodsb				; String [si] to al
		dec	cx
		jz	loc_165			; Jump if zero
		inc	si
		cmp	ah,al
		jne	loc_164			; Jump if not equal
		inc	bx
		jmp	short loc_163
loc_164:
		call	sub_26
		jmp	short loc_163
loc_165:
		call	sub_26
		retn
sub_17		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_18		proc	near
		push	ds
		push	es
		mov	si,data_1e
		mov	di,data_16e
		mov	bx,0
		mov	ds,cs:data_91
		mov	es,cs:data_91
		call	sub_17
		mov	si,data_2e
		mov	bx,0
		call	sub_17
		pop	es
		pop	ds
		retn
sub_18		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_19		proc	near
		mov	ax,4ADh
		mov	data_93,ax
		call	sub_21
		retn
sub_19		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_20		proc	near
		mov	ax,6F7h
		mov	data_93,ax
		call	sub_21
		retn
sub_20		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_21		proc	near
		push	cx
		push	dx
		push	si
		push	di
		push	ax
		xor	di,di			; Zero register
		mov	si,cs:data_93
loc_166:
		lodsb				; String [si] to al
		cmp	al,1
		jne	loc_169			; Jump if not equal
		lodsw				; String [si] to ax
		mov	cx,ax
		test	cl,80h
		jz	loc_167			; Jump if zero
		xchg	ch,cl
		and	cx,7FFFh
		lodsb				; String [si] to al
		jmp	short locloop_168
		db	90h
loc_167:
		xchg	al,ah
		and	cx,7Fh

locloop_168:
		call	sub_25
		loop	locloop_168		; Loop if cx > 0

		jmp	short loc_170
		db	90h
loc_169:
		call	sub_25
loc_170:
		cmp	di,0FA0h
		jl	loc_166			; Jump if <
		jnz	loc_171			; Jump if not zero
		mov	di,1
		jmp	short loc_166
loc_171:
		pop	ax
		pop	di
		pop	si
		pop	dx
		pop	cx
		retn
sub_21		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_22		proc	near
		push	ds
		mov	ds,data_91
		mov	si,data_4e
		mov	di,offset data_115
		mov	cx,7
		cld				; Clear direction
		repe	cmpsw			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		pop	ds
		cmp	cx,0
		jne	loc_ret_172		; Jump if not equal
		mov	data_92,0D5h
		call	sub_44

loc_ret_172:
		retn
sub_22		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_23		proc	near
		mov	ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		mov	ah,3
		int	10h			; Video display   ah=functn 03h
						;  get cursor loc in dx, mode cx
		mov	data_104,bh
		mov	data_105,cx
		mov	data_106,dx
		call	sub_18
		retn
sub_23		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_24		proc	near
		mov	data_93,1000h
		mov	ax,data_91
		push	ds
		mov	ds,ax
		call	sub_21
		pop	ds
		mov	bh,data_104
		mov	dx,data_106
		mov	ah,2
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		mov	ah,1
		mov	cx,data_105
		int	10h			; Video display   ah=functn 01h
						;  set cursor mode in cx
		retn
sub_24		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_25		proc	near
		push	es
		mov	es,cs:data_91
		mov	dx,cs:data_90
		cli				; Disable interrupts
		push	ax
loc_173:
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		test	al,1
		jnz	loc_173			; Jump if not zero
loc_174:
		in	al,dx			; port 0, DMA-1 bas&add ch 0
		test	al,1
		jz	loc_174			; Jump if zero
		pop	ax
		mov	es:[di],al
		sti				; Enable interrupts
		inc	di
		inc	di
		pop	es
		retn
sub_25		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_26		proc	near
		cmp	ah,1
		je	loc_175			; Jump if equal
		cmp	bx,0
		je	loc_178			; Jump if equal
		cmp	bx,1
		jne	loc_175			; Jump if not equal
		xor	bx,bx			; Zero register
		xchg	ah,al
		stosb				; Store al to es:[di]
		jmp	short loc_179
		db	90h
loc_175:
		push	ax
		inc	bx
		mov	al,1
		stosb				; Store al to es:[di]
		mov	ax,bx
		and	bx,0FF80h
		nop				;*ASM fixup - sign extn byte
		jz	loc_176			; Jump if zero
		or	ax,8000h
		xchg	ah,al
		stosw				; Store ax to es:[di]
		jmp	short loc_177
		db	90h
loc_176:
		stosb				; Store al to es:[di]
loc_177:
		xor	bx,bx			; Zero register
		pop	ax
loc_178:
		xchg	ah,al
loc_179:
		stosb				; Store al to es:[di]
		retn
sub_26		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_27		proc	near
		mov	al,data_110
		mul	data_111		; ax = data * al
		add	ax,3Dh
		mov	di,ax
		mov	al,data_112
		mov	cl,15h
loc_180:
		call	sub_25
		dec	cl
		cmp	cl,0
		jne	loc_180			; Jump if not equal
		retn
sub_27		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_28		proc	near
		mov	ds,data_25
		cmp	byte ptr ds:video_mode_,7
		je	loc_183			; Jump if equal
		cmp	byte ptr ds:video_mode_,2
		je	loc_182			; Jump if equal
		cmp	byte ptr ds:video_mode_,3
		je	loc_182			; Jump if equal
loc_181:
		push	cs
		pop	ds
		stc				; Set carry flag
		retn
loc_182:
		push	cs
		pop	ds
		clc				; Clear carry flag
		retn
loc_183:
		mov	ds,cs:data_91
		xor	si,si			; Zero register
		mov	cx,50h
		xor	bx,bx			; Zero register
		cld				; Clear direction

locloop_184:
		lodsw				; String [si] to ax
		cmp	ah,al
		jne	loc_185			; Jump if not equal
		inc	bx
loc_185:
		loop	locloop_184		; Loop if cx > 0

		cmp	bx,0Ah
		jg	loc_181			; Jump if >
		jmp	short loc_182
sub_28		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_29		proc	near
		mov	cx,2
		mov	es,data_25
		cld				; Clear direction
		cli				; Disable interrupts
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		sti				; Enable interrupts
		retn
sub_29		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_30		proc	near
		clc				; Clear carry flag
		mov	word ptr ds:[1F0h],es
		mov	es,data_25
		cmp	ax,es:[di]
		jne	loc_186			; Jump if not equal
		push	cs
		pop	ax
		cmp	ax,es:[di+2]
		je	loc_187			; Jump if equal
loc_186:
		stc				; Set carry flag
loc_187:
		mov	es,word ptr ds:[1F0h]
		retn
sub_30		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_31		proc	near
		mov	data_100,0F5h
		mov	data_97,9
		mov	data_95,1
loc_188:
		mov	al,data_95
		cbw				; Convrt byte to word
		mov	word ptr ds:[1A9h],0
		mov	word ptr ds:[1ABh],ax
		call	sub_32
		mov	dh,byte ptr ds:[1AFh]
		mov	dl,7
		sub	dl,dh
		mov	dh,data_97
		mov	si,0EDh
		call	sub_14
		mov	si,data_100
		mov	di,3A0h
		cld				; Clear direction
		call	sub_35
		inc	di
		call	sub_35
		mov	data_100,si
		mov	dh,data_97
		mov	dl,14h
		mov	si,3A0h
		call	sub_14
		mov	si,data_100
		lodsw				; String [si] to ax
		mov	word ptr data_98,ax
		mov	data_100,si
		mov	word ptr ds:[1A9h],0
		mov	word ptr ds:[1ABh],ax
		call	sub_32
		mov	dh,byte ptr ds:[1AFh]
		mov	dl,2Dh			; '-'
		sub	dl,dh
		mov	dh,data_97
		mov	si,0EDh
		call	sub_14
		mov	bl,50h			; 'P'
		xor	bh,bh			; Zero register
		cmp	data_31,0
		jne	loc_189			; Jump if not equal
		shr	bx,1			; Shift w/zeros fill
loc_189:
		dec	bx
		mov	ax,2
		mul	bx			; dx:ax = reg * ax
		mov	bl,data_56
		xor	bh,bh			; Zero register
		mul	bx			; dx:ax = reg * ax
		mov	bl,data_53
		add	ax,bx
		mov	bx,word ptr data_98
		cmp	byte ptr ds:[2423h],1
		je	loc_190			; Jump if equal
		shl	bx,1			; Shift w/zeros fill
loc_190:
		sub	ax,bx
		mov	bx,200h
		mul	bx			; dx:ax = reg * ax
		mov	word ptr ds:[1A9h],dx
		mov	word ptr ds:[1ABh],ax
		call	sub_32
		mov	dh,byte ptr ds:[1AFh]
		mov	dl,44h			; 'D'
		sub	dl,dh
		mov	dh,data_97
		mov	si,0EDh
		call	sub_14
		mov	al,data_99
		cmp	data_95,al
		jne	loc_191			; Jump if not equal
		call	sub_13
		retn
loc_191:
		inc	data_95
		inc	data_97
		jmp	loc_188
sub_31		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_32		proc	near
		mov	di,0EDh
		call	sub_33
		mov	word ptr ds:[1ADh],bx
		mov	byte ptr ds:[1AFh],bl
		jz	loc_195			; Jump if zero
loc_192:
		cld				; Clear direction
		or	al,30h			; '0'
		stosb				; Store al to es:[di]
		mov	word ptr ds:[1A5h],0
		mov	word ptr ds:[1A7h],0
		push	di
		mov	di,word ptr ds:[1B0h]
		add	di,word ptr ds:[1B2h]
		call	sub_34
		pop	di
		mov	ax,word ptr ds:[1A7h]
		sub	word ptr ds:[1ABh],ax
		jnc	loc_193			; Jump if carry=0
		dec	word ptr ds:[1A9h]
loc_193:
		mov	ax,word ptr ds:[1A5h]
		sub	word ptr ds:[1A9h],ax
		dec	word ptr ds:[1ADh]
		cmp	word ptr ds:[1ADh],0
		je	loc_195			; Jump if equal
		call	sub_33
loc_194:
		cmp	bx,word ptr ds:[1ADh]
		je	loc_192			; Jump if equal
		push	ax
		mov	al,30h			; '0'
		stosb				; Store al to es:[di]
		pop	ax
		dec	word ptr ds:[1ADh]
		cmp	word ptr ds:[1ADh],0
		jne	loc_194			; Jump if not equal
loc_195:
		mov	ax,word ptr ds:[1ABh]
		or	al,30h			; '0'
		cld				; Clear direction
		stosb				; Store al to es:[di]
		mov	al,0
		stosb				; Store al to es:[di]
		retn
sub_32		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_33		proc	near
		mov	dx,word ptr ds:[1A9h]
		mov	ax,word ptr ds:[1ABh]
		mov	word ptr ds:[1B0h],0
		mov	word ptr ds:[1B2h],0
		cmp	dx,0
		jne	loc_196			; Jump if not equal
		cmp	ax,2710h
		jb	loc_197			; Jump if below
loc_196:
		mov	bx,2710h
		mov	word ptr ds:[1B0h],8
		div	bx			; ax,dx rem=dx:ax/reg
loc_197:
		cmp	ax,0Ah
		jb	loc_200			; Jump if below
		mov	word ptr ds:[1B2h],6
		xor	dx,dx			; Zero register
		mov	bx,offset 1C8h
loc_198:
		cmp	ax,[bx]
		jge	loc_199			; Jump if > or =
		sub	word ptr ds:[1B2h],2
		sub	bx,2
		jmp	short loc_198
loc_199:
		mov	bx,[bx]
		div	bx			; ax,dx rem=dx:ax/reg
loc_200:
		mov	bx,word ptr ds:[1B0h]
		add	bx,word ptr ds:[1B2h]
		shr	bx,1			; Shift w/zeros fill
		retn
sub_33		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_34		proc	near
		and	al,0Fh
		cbw				; Convrt byte to word
		push	ax
		mov	bx,offset 1C2h
		mov	bx,[bx+di]
		mul	bx			; dx:ax = reg * ax
		add	word ptr ds:[1A7h],ax
		jnc	loc_201			; Jump if carry=0
		inc	dx
loc_201:
		add	word ptr ds:[1A5h],dx
		mov	bx,offset 1B4h
		pop	ax
		mov	bx,[bx+di]
		mul	bx			; dx:ax = reg * ax
		add	word ptr ds:[1A5h],ax
		retn
sub_34		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_35		proc	near
		lodsb				; String [si] to al
		call	sub_36
		stosw				; Store ax to es:[di]
		lodsb				; String [si] to al
		call	sub_36
		stosw				; Store ax to es:[di]
		retn
sub_35		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_36		proc	near
		mov	ah,al
		and	ah,0Fh
		mov	cl,4
		shr	al,cl			; Shift w/zeros fill
		and	al,0Fh
		cmp	al,0Ah
		jge	loc_202			; Jump if > or =
		add	al,30h			; '0'
		jmp	short loc_203
		db	90h
loc_202:
		add	al,37h			; '7'
loc_203:
		cmp	ah,0Ah
		jge	loc_204			; Jump if > or =
		add	ah,30h			; '0'
		jmp	short loc_ret_205
		db	90h
loc_204:
		add	ah,37h			; '7'

loc_ret_205:
		retn
sub_36		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_37		proc	near
		mov	al,data_29
		mov	bx,offset data_30
		cbw				; Convrt byte to word
		add	bx,ax
		mov	al,[bx]
		mov	data_31,ax
		retn
sub_37		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_38		proc	near
		mov	ah,1
		mov	cx,7
		int	10h			; Video display   ah=functn 01h
						;  set cursor mode in cx
		mov	ah,3
		mov	bh,data_104
		int	10h			; Video display   ah=functn 03h
						;  get cursor loc in dx, mode cx
		mov	data_108,dh
		mov	data_109,dl
		mov	di,137h
		mov	data_101,0
loc_206:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,0Dh
		jne	loc_207			; Jump if not equal
		retn
loc_207:
		cmp	al,1Bh
		jne	loc_208			; Jump if not equal
		pop	ax
		jmp	loc_41
loc_208:
		cmp	al,10h
		je	loc_209			; Jump if equal
		cmp	ax,5300h
		jne	loc_210			; Jump if not equal
loc_209:
		call	sub_41
		call	sub_41
		jmp	short loc_206
loc_210:
		cmp	ax,4B00h
		je	loc_211			; Jump if equal
		cmp	al,8
		jne	loc_212			; Jump if not equal
loc_211:
		call	sub_41
		jmp	short loc_206
loc_212:
		cmp	al,30h			; '0'
		jb	loc_213			; Jump if below
		cmp	al,39h			; '9'
		jg	loc_213			; Jump if >
		cmp	data_101,2
		je	loc_213			; Jump if equal
		cld				; Clear direction
		stosb				; Store al to es:[di]
		inc	data_101
		inc	data_109
		call	sub_10
		jmp	short loc_206
loc_213:
		call	sub_11
		jmp	short loc_206
sub_38		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_39		proc	near
		mov	si,offset data_33+6	; (' ')
loc_214:
		cmp	al,0
		je	loc_215			; Jump if equal
		add	si,7
		dec	al
		jmp	short loc_214
loc_215:
		mov	di,offset data_189
loc_216:
		lodsb				; String [si] to al
		cmp	al,0
		jne	loc_217			; Jump if not equal
		retn
loc_217:
		stosb				; Store al to es:[di]
sub_39		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_40		proc	near
		jmp	short loc_216
sub_40		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_41		proc	near
		cmp	data_101,0
		je	loc_ret_218		; Jump if equal
		dec	di
		dec	data_101
		dec	data_109
		call	sub_42
		mov	al,20h			; ' '
		call	sub_10
		call	sub_42

loc_ret_218:
		retn
sub_41		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_42		proc	near
		mov	ah,2
		mov	bh,data_104
		mov	dh,data_108
		mov	dl,data_109
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
		retn
sub_42		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_43		proc	near
		push	ds
		mov	ds,data_91
		mov	si,data_4e
		mov	di,offset data_115
		mov	cx,7
		cld				; Clear direction
		repe	cmpsw			; Rep zf=1+cx >0 Cmp [si] to es:[di]
		cmp	cx,0
		je	loc_219			; Jump if equal
		mov	di,offset data_113
		mov	si,data_4e
		mov	cx,6
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
loc_219:
		pop	ds
		call	sub_44
		mov	di,offset data_115
		mov	si,data_92
		mov	cx,6
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		retn
sub_43		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_44		proc	near
		push	es
		mov	si,data_92
		mov	es,data_91
		mov	di,data_4e
		mov	cx,6
		rep	movsw			; Rep when cx >0 Mov [si] to es:[di]
		pop	es
		retn
sub_44		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_45		proc	near
		call	sub_28
		jnc	loc_220			; Jump if carry=0
		retn
loc_220:
		call	sub_43
		retn
sub_45		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_46		proc	near
		call	sub_28
		jnc	loc_221			; Jump if carry=0
		clc				; Clear carry flag
		retn
loc_221:
		cmp	data_187,6666h
		je	loc_222			; Jump if equal
		mov	data_92,3CEh
		mov	ah,data_65
		call	sub_47
		mov	byte ptr data_184+26h,al	; ('')
		mov	byte ptr data_184+28h,ah	; ('')
		call	sub_43
		retn
loc_222:
		cmp	data_92,3AAh
		jne	loc_ret_223		; Jump if not equal
		mov	data_92,0D5h
		call	sub_44

loc_ret_223:
		retn
sub_46		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_47		proc	near
		cmp	ah,0Ah
		jl	loc_226			; Jump if <
		mov	al,31h			; '1'
loc_224:
		sub	ah,0Ah
		cmp	ah,0Ah
		jl	loc_225			; Jump if <
		add	al,1
		jmp	short loc_224
loc_225:
		or	ah,30h			; '0'
		retn
loc_226:
		or	ah,30h			; '0'
		mov	al,20h			; ' '
		retn
sub_47		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_48		proc	near
		cld				; Clear direction
		mov	di,offset 14Dh
loc_227:
		mov	al,data_65
		stosb				; Store al to es:[di]
		mov	al,data_64
		stosb				; Store al to es:[di]
		mov	al,data_66
		stosb				; Store al to es:[di]
		mov	al,2
		stosb				; Store al to es:[di]
		inc	data_66
		mov	al,data_66
		cmp	al,data_56
		jle	loc_227			; Jump if < or =
		mov	data_66,1
		retn
sub_48		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_49		proc	near
		pop	ax
		mov	word ptr ds:[221h],ax
		mov	data_82,21E2h
		mov	al,byte ptr ds:[21Ah]
		mov	data_66,al
		mov	data_68,28E9h
		mov	data_67,1FFh
		mov	data_69,4Ah		; 'J'
		mov	data_70,0C5h
		mov	data_85,27F1h
		call	sub_75
		mov	data_82,220Dh
		mov	ax,word ptr ds:[242Ch]
		mov	cl,byte ptr ds:[21Ah]
		add	cl,al
		cmp	cl,data_56
		jle	loc_228			; Jump if < or =
		inc	data_64
		sub	cl,data_56
loc_228:
		mov	data_66,cl
		call	sub_75
		inc	byte ptr ds:[21Ah]
		jmp	word ptr ds:[221h]

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_50:
		mov	si,offset data_220
		mov	cx,word ptr ds:[21Dh]
		inc	cx
		sub	cx,si
		jbe	loc_229			; Jump if below or =
		mov	di,offset data_214
		cld				; Clear direction
		repne	movsb			; Rep zf=0+cx >0 Mov [si] to es:[di]
		xor	al,al			; Zero register
		mov	cx,1Bh
		mov	di,offset data_220
		repne	stosb			; Rep zf=0+cx >0 Store al to es:[di]
loc_229:
		add	word ptr ds:[21Fh],200h
		mov	word ptr ds:[21Dh],0
		retn
sub_49		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_51		proc	near
		mov	al,data_65
		dec	al
		cbw				; Convrt byte to word
		mov	bl,4
		div	bl			; al, ah rem = ax/reg
		mov	cl,ah
		cbw				; Convrt byte to word
		mov	di,ax
		rol	cl,1			; Rotate
		add	cl,data_64
		mov	al,80h
		ror	al,cl			; Rotate
		or	byte ptr ds:[139h][di],al
		retn
sub_51		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_52		proc	near
		mov	data_65,0
		mov	data_64,0
		mov	data_66,1
		mov	data_94,0
		mov	data_63,0
		mov	data_59,0F6h
		retn
sub_52		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_53		proc	near
		xor	al,al			; Zero register
		mov	cx,200h
		mov	di,offset data_214
		cld				; Clear direction
		repne	stosb			; Rep zf=0+cx >0 Store al to es:[di]
		retn
sub_53		endp

		mov	di,data_100
		mov	ax,0D1BAh
		cld				; Clear direction
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		mov	ax,data_54
		stosw				; Store ax to es:[di]
		mov	data_100,di
		inc	data_95
		inc	data_99
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_54		proc	near
		mov	word ptr data_98,0
		mov	si,offset 139h
		cld				; Clear direction
loc_230:
		lodsb				; String [si] to al
		mov	cl,4
loc_231:
		mov	ah,al
		and	ah,3
		cmp	ah,3
		je	loc_232			; Jump if equal
		cmp	ah,0
		je	loc_233			; Jump if equal
		mov	bl,data_56
		call	sub_57
		jmp	short loc_233
		db	90h
loc_232:
		mov	bl,data_56
		shl	bl,1			; Shift w/zeros fill
		call	sub_57
loc_233:
		dec	cl
		jz	loc_234			; Jump if zero
		shr	al,1			; Shift w/zeros fill
		shr	al,1			; Shift w/zeros fill
		jmp	short loc_231
loc_234:
		cmp	si,14Dh
		jl	loc_230			; Jump if <
		retn
sub_54		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_55		proc	near
		push	cx
		mov	al,byte ptr ds:[2423h]
		cbw				; Convrt byte to word
		mov	bx,ax
		mov	al,data_53
		cbw				; Convrt byte to word
		add	ax,word ptr ds:[223h]
		xor	dx,dx			; Zero register
		div	bx			; ax,dx rem=dx:ax/reg
		call	sub_59
		xor	dx,dx			; Zero register
		mov	bx,2
		div	bx			; ax,dx rem=dx:ax/reg
		call	sub_58
		mov	bx,3
		mul	bx			; dx:ax = reg * ax
		add	ax,3
		add	ax,cx
		pop	cx
		retn
sub_55		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_56		proc	near
		mov	ah,data_95
		inc	ah
		call	sub_47
		mov	data_190,ax
		retn
sub_56		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_57		proc	near
		xor	bh,bh			; Zero register
		cmp	data_56,9
		jne	loc_235			; Jump if not equal
		clc				; Clear carry flag
		rcr	bx,1			; Rotate thru carry
		adc	bx,0
loc_235:
		add	word ptr data_98,bx
		retn
sub_57		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_58		proc	near
		cmp	dx,0
		je	loc_236			; Jump if equal
		mov	cx,1
		retn
loc_236:
		mov	cx,dx
		retn
sub_58		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_59		proc	near
		test	al,1
		jz	loc_237			; Jump if zero
		mov	word ptr ds:[229h],2
		retn
loc_237:
		mov	word ptr ds:[229h],0
		retn
sub_59		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_60		proc	near
		mov	di,offset 139h
		xor	al,al			; Zero register
		mov	cx,14h
		cld				; Clear direction
		repne	stosb			; Rep zf=0+cx >0 Store al to es:[di]
		retn
sub_60		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_61		proc	near
		mov	si,data_31
		mov	bx,offset data_41
		mov	al,[bx+si]
		mov	byte ptr ds:[2423h],al
		mov	bx,offset data_47
		mov	al,[bx+si]
		mov	byte ptr ds:[242Bh],al
		mov	bx,offset data_39
		mov	al,[bx+si]
		mov	data_71,al
		mov	bx,offset data_43
		mov	al,[bx+si]
		mov	data_55,al
		mov	bx,offset data_44
		mov	al,[bx+si]
		mov	data_56,al
		and	ax,0FFh
		mov	word ptr ds:[242Eh],ax
		mov	bx,offset data_45
		mov	al,[bx+si]
		mov	data_57,al
		mov	bx,offset data_46
		mov	al,[bx+si]
		mov	data_58,al
		mov	bx,offset data_52
		mov	al,[bx+si]
		mov	data_53,al
		shl	si,1			; Shift w/zeros fill
		mov	bx,offset data_48
		mov	ax,[bx+si]
		mov	word ptr ds:[2427h],ax
		mov	bx,offset data_40
		mov	ax,[bx+si]
		mov	data_61,ax
		mov	bx,offset data_37
		mov	ax,[bx+si]
		mov	word ptr data_60,ax
		mov	bx,69h
		mov	ax,[bx+si]
		mov	word ptr ds:[2429h],ax
		mov	bx,offset data_50
		mov	ax,[bx+si]
		mov	word ptr ds:[242Ch],ax
		mov	bx,offset data_51
		mov	ax,[bx+si]
		mov	data_54,ax
		mov	ah,4
		int	1Ah			; Real time clock   ah=func 04h
						;  get date  cx=year, dx=mon/day
		mov	word ptr ds:[243Fh],dx
		cmp	data_31,0
		jne	loc_238			; Jump if not equal
		mov	word ptr ds:[216h],143h
		retn
loc_238:
		mov	word ptr ds:[216h],14Dh
		retn
sub_61		endp

		jmp	short loc_239
		nop
		inc	dx
		inc	si
		dec	di
		push	dx
		dec	bp
		inc	cx
		push	sp
		and	[bx+si],al
		add	al,[bx+si]
		add	[bx+si],ax
		add	al,[bx+si]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	al,[bx+si]
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		add	[bx+si],al
		sub	[bx+si],ax
		add	[bx+si],al
		add	[bp+4Fh],cl
		db	' NAME    FAT12   ', 0Dh, 0Ah, ' '
		db	'Non-System Disk ...', 0Dh, 0Ah, ' '
		db	'Replace And Press Any Key When R'
		db	'eady...', 0Dh, 0Ah, 0
loc_239:
		xor	ax,ax			; Zero register
		cli				; Disable interrupts
		mov	ss,ax
		mov	sp,7C00h
		sti				; Enable interrupts
		push	cs
		pop	ds
		mov	si,data_234e
		cld				; Clear direction
loc_240:
		lodsb				; String [si] to al
		test	al,al
		jz	loc_241			; Jump if zero
		mov	ah,0Eh
		xor	bx,bx			; Zero register
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		jmp	short loc_240
loc_241:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		int	19h			; Bootstrap loader
		db	347 dup (0)
		db	 55h,0AAh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_62		proc	near
		mov	byte ptr ds:[22Fh],1
		mov	ds,data_25
		mov	al,0FFh
		mov	ds:dsk_motor_tmr_,al
		mov	al,ds:dsk_motor_stat_
		and	al,0Fh
		push	cs
		pop	ds
		cmp	al,0
		je	loc_242			; Jump if equal
		retn
loc_242:
		mov	cl,data_29
		mov	al,10h
		shl	al,cl			; Shift w/zeros fill
		mov	ah,al
		or	al,cl
		or	al,0Ch
		mov	dx,3F2h
		out	dx,al			; port 3F2h, dsk0 contrl output
		mov	cl,4
		rol	ah,cl			; Rotate
		mov	ds,data_25
		mov	ds:dsk_motor_stat_,ah
		push	cs
		pop	ds
		mov	byte ptr ds:[22Dh],2
		call	sub_7
		retn
sub_62		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_63		proc	near
		pop	ax
		mov	data_86,ax
		call	sub_62
		call	sub_67
		jmp	short loc_243
		db	90h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_64:
		pop	ax
		mov	data_86,ax
		mov	data_63,0
		call	sub_62
		call	sub_66
loc_243:
		call	sub_79
		call	sub_68
		jc	loc_244			; Jump if carry Set
		jmp	data_86
loc_244:
		clc				; Clear carry flag
		jmp	loc_123
sub_63		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_65		proc	near
		pop	ax
		mov	data_88,ax
		call	sub_64
		test	data_73,0C0h
		jz	loc_245			; Jump if zero
		call	sub_64
		test	data_73,0C0h
		jz	loc_245			; Jump if zero
		jmp	loc_123
loc_245:
		mov	al,data_65
		cmp	data_31,0
		jne	loc_246			; Jump if not equal
		shl	al,1			; Shift w/zeros fill
loc_246:
		mov	data_63,al
		call	sub_63
		jmp	data_88

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_66:
		mov	ah,7
		call	sub_71
		mov	ah,data_29
		call	sub_71
		retn
sub_65		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_67		proc	near
		mov	ah,0Fh
		call	sub_71
		mov	ah,data_29
		call	sub_71
		mov	ah,data_63
		call	sub_71
		retn
sub_67		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_68		proc	near
		mov	ah,8
		call	sub_71
		call	sub_70
		mov	data_73,al
		call	sub_70
		mov	data_72,al
		retn
sub_68		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_69		proc	near
		call	sub_70
		mov	data_73,al
		call	sub_70
		mov	data_74,al
		call	sub_70
		mov	data_75,al
		call	sub_70
		mov	data_77,al
		call	sub_70
		mov	data_78,al
		call	sub_70
		mov	data_79,al
		call	sub_70
		mov	data_80,al
		retn
sub_69		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_70		proc	near
		mov	dx,3F4h
		xor	cx,cx			; Zero register

locloop_247:
		in	al,dx			; port 3F4h, dsk0 cntrlr status
		and	al,0C0h
		cmp	al,0C0h
		je	loc_248			; Jump if equal
		loop	locloop_247		; Loop if cx > 0

		pop	ax
		stc				; Set carry flag
		retn
loc_248:
		inc	dx
		in	al,dx			; port 3F5h, dsk0 controlr data
		clc				; Clear carry flag
		retn
sub_70		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_71		proc	near
		mov	dx,3F4h
		xor	cx,cx			; Zero register

locloop_249:
		in	al,dx			; port 3F4h, dsk0 cntrlr status
		and	al,0C0h
		cmp	al,80h
		je	loc_250			; Jump if equal
		loop	locloop_249		; Loop if cx > 0

		pop	ax
		stc				; Set carry flag
		retn
loc_250:
		mov	al,ah
		inc	dx
		out	dx,al			; port 3F5h, dsk0 controlr data
		clc				; Clear carry flag
		retn
sub_71		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_72		proc	near
		mov	dx,3F7h
		mov	al,data_71
		out	dx,al			; port 3F7h ??I/O Non-standard
		retn
sub_72		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_73		proc	near
		mov	al,2
		out	0Ch,al			; port 0Ch, DMA-1 clr byte ptr
		jmp	short $+2		; delay for I/O
		mov	al,ah
		out	0Bh,al			; port 0Bh, DMA-1 mode reg
		mov	bx,data_68
		push	cs
		pop	ax
		mov	cl,4
		rol	ax,cl			; Rotate
		mov	ch,al
		and	al,0F0h
		add	ax,bx
		jnc	loc_251			; Jump if carry=0
		inc	ch
loc_251:
		out	4,al			; port 4, DMA-1 bas&add ch 2
		jmp	short $+2		; delay for I/O
		mov	al,ah
		out	4,al			; port 4, DMA-1 bas&add ch 2
		jmp	short $+2		; delay for I/O
		mov	al,ch
		and	al,0Fh
		out	81h,al			; port 81h, DMA page reg ch 2
		mov	ax,data_67
		out	5,al			; port 5, DMA-1 bas&cnt ch 2
		jmp	short $+2		; delay for I/O
		mov	al,ah
		out	5,al			; port 5, DMA-1 bas&cnt ch 2
		jmp	short $+2		; delay for I/O
		mov	al,2
		out	0Ah,al			; port 0Ah, DMA-1 mask reg bit
		retn
sub_73		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_74		proc	near
		pop	ax
		mov	data_86,ax
		mov	data_68,28E9h
		mov	data_67,1FFh
		mov	data_69,46h		; 'F'
		mov	data_70,0E6h
		call	sub_62
		call	sub_72
		mov	ah,data_69
		call	sub_73
		call	sub_76
		jc	loc_252			; Jump if carry Set
		call	sub_79
		call	sub_69
		jc	loc_252			; Jump if carry Set
		jmp	data_86
loc_252:
		clc				; Clear carry flag
		call	sub_7
		jmp	loc_123
sub_74		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_75		proc	near
		pop	ax
		mov	data_86,ax
		call	sub_62
		call	sub_72
		mov	ah,data_69
		call	sub_73
		call	data_85
		jc	loc_253			; Jump if carry Set
		call	sub_79
		call	sub_69
		jc	loc_253			; Jump if carry Set
		jmp	data_86
loc_253:
		clc				; Clear carry flag
		call	sub_7
		jmp	loc_123
sub_75		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_76		proc	near
		mov	ah,data_70
		call	sub_71
		mov	ah,data_29
		cmp	data_64,0
		je	loc_254			; Jump if equal
		or	ah,4
loc_254:
		call	sub_71
		mov	ah,data_65
		call	sub_71
		mov	ah,data_64
		call	sub_71
		mov	ah,data_66
		call	sub_71
		mov	ah,2
		call	sub_71
		mov	ah,data_56
		call	sub_71
		mov	ah,data_57
		call	sub_71
		mov	ah,0FFh
		call	sub_71
		retn
sub_76		endp

		mov	ah,4Dh			; 'M'
		call	sub_71
		mov	ah,data_29
		cmp	data_64,0
		je	loc_255			; Jump if equal
		or	ah,4
loc_255:
		call	sub_71
		mov	ah,2
		call	sub_71
		mov	ah,data_56
		call	sub_71
		mov	ah,data_58
		call	sub_71
		mov	ah,data_59
		call	sub_71
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_77		proc	near
		mov	ah,4
		call	sub_71
		mov	ah,data_29
		call	sub_71
		call	sub_70
		mov	data_76,al
		retn
sub_77		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_78		proc	near
		pop	ax
		mov	data_87,ax
		call	sub_48
		mov	ax,data_61
		mov	data_67,ax
		mov	data_68,14Dh
		mov	data_69,4Ah		; 'J'
		mov	data_85,2837h
		call	sub_75
		test	data_73,0C0h
		jnz	loc_256			; Jump if not zero
		jmp	data_87
loc_256:
		test	data_74,2
		jz	loc_257			; Jump if zero
		jmp	loc_86
loc_257:
		cmp	data_94,2
		jne	loc_258			; Jump if not equal
		mov	data_94,0
		jmp	loc_93
loc_258:
		inc	data_94
		call	sub_65
		test	data_73,0C0h
		jnz	loc_259			; Jump if not zero
		jmp	data_82
loc_259:
		jmp	loc_123
sub_78		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_79		proc	near
		mov	cx,18h

locloop_260:
		call	sub_7
		cmp	byte ptr ds:[22Fh],0
		jne	loc_261			; Jump if not equal
		retn
loc_261:
		loop	locloop_260		; Loop if cx > 0

		pop	ax
		jmp	loc_123
sub_79		endp

data_214	db	0
data_215	dw	0
		db	8 dup (0)
data_217	dw	0
		db	26 dup (0)
data_218	dw	0
data_219	dw	0
		db	469 dup (0)
data_220	db	0
		db	154 dup (0)
data_221	db	0Dh, 0Ah, ' Mem Resident Format A'
		db	'lready Installed', 0Dh, 0Ah, 'Al'
		db	't + Left Shift + Right Shift Wil'
		db	'l Activate', 0Dh, 0Ah, '$'
data_222	db	0Dh, 0Ah, 'Background Formatter I'
		db	's Installed', 0Dh, 0Ah, 'Alt + L'
		db	'eft Shift + Right Shift Will Act'
		db	'ivate', 0Dh, 0Ah, '$'
data_223	db	0Dh, 0Ah, 'No Diskette Drive Conn'
		db	'ect', 0Dh, 0Ah, 'Program Termina'
		db	'ted !', 0Dh, 0Ah, '$'
		db	'There Are '
data_224	db	0
		db	' Diskette Drives Connected'
		db	0
data_225	db	0
		db	 20h,0C4h
		db	14 dup (0C4h)
data_227	db	' ', 0
		db	'Is This Configuration Correct ? '
		db	'[Y]', 0
		db	'How Many Diskette Drives ( Not I'
		db	'nclude Fixed Disk ) ?', 0
		db	'DRIVE ', 0
		db	' ( 0 - 360K, 1 - 1.2M, 2 - 720K,'
		db	' 3 - 1.44M ) ?', 0
loc_262:
		push	cs
		pop	ds
		push	cs
		pop	es
		call	sub_86
		mov	word ptr ds:[1E2h],cs
		mov	word ptr ds:[1E4h],cs
		mov	word ptr ds:[1DAh],cs
		mov	word ptr ds:[1E0h],cs
		mov	word ptr data_24,0EBFEh
		cli				; Disable interrupts
		mov	word ptr ds:[1E6h],ss
		mov	word ptr ds:[1E8h],sp
		push	cs
		pop	ss
		mov	sp,2B84h
		mov	ax,202h
		push	ax
		push	cs
		mov	ax,data_81
		push	ax
		mov	word ptr ds:[1DCh],sp
		mov	ss,word ptr ds:[1E6h]
		mov	sp,word ptr ds:[1E8h]
		sti				; Enable interrupts
		call	sub_80
		call	sub_23
		call	sub_88
		call	sub_24
		mov	al,0Eh
		mov	si,19Dh
		mov	dx,12CCh
		call	sub_87
		mov	al,13h
		mov	si,1A1h
		mov	dx,12E6h
		call	sub_87
		mov	al,9
		mov	si,199h
		mov	dx,127Ah
		call	sub_87
		mov	al,8
		mov	si,195h
		mov	dx,11E0h
		call	sub_87
		mov	dx,offset data_222	; ('')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		mov	al,0
		mov	dx,2B84h
		mov	cl,4
		shr	dx,cl			; Shift w/zeros fill
		add	dx,11h
		mov	ah,31h			; '1'
		int	21h			; DOS Services  ah=function 31h
						;  terminate & stay resident
						;   al=return code,dx=paragraphs

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_80		proc	near
		push	es
		mov	es,cs:data_25
		mov	dx,es:video_port_
		add	dx,6
		mov	cs:data_90,dx
		pop	es
		int	11h			; Put equipment bits in ax
		mov	bh,al
		and	bh,30h			; '0'
		mov	data_91,0B800h
		cmp	bh,30h			; '0'
		jne	loc_263			; Jump if not equal
		mov	data_91,0B000h
loc_263:
		mov	bh,al
		and	bh,1
		and	ax,0C0h
		shl	ax,1			; Shift w/zeros fill
		shl	ax,1			; Shift w/zeros fill
		add	ah,bh
		cmp	ah,0
		jne	loc_264			; Jump if not equal
		mov	dx,offset data_223	; ('')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		jmp	loc_277
loc_264:
		mov	al,ah
		cmp	al,3
		jl	loc_265			; Jump if <
		mov	al,2
loc_265:
		mov	data_28,al
		or	al,30h			; '0'
		mov	data_224,al
		call	sub_81
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_81:
		push	ax
		push	es
		push	di
		mov	bx,0Dh
		mov	dx,0
loc_266:
		mov	si,dx
		push	ax
		push	bx
		push	dx
		mov	ah,8
		int	13h			; Disk  dl=drive a  ah=func 08h
						;  get drive parameters, bl=type
						;   cx=cylinders, dh=max heads
						;   es:di= ptr to drive table
		jc	loc_267			; Jump if carry Set
		mov	al,bl
		dec	al
		pop	dx
		pop	bx
		mov	[bx+si],al
		pop	ax
		dec	ah
		jz	loc_268			; Jump if zero
		inc	dx
		jmp	short loc_266
loc_267:
		add	sp,6
loc_268:
		pop	di
		pop	es
		pop	ax
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_82:
		mov	al,41h			; 'A'
		mov	dx,0C1Dh
		mov	di,0
		call	sub_85
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_83:
		call	sub_82
		call	sub_84
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_84:
		mov	al,42h			; 'B'
		mov	dx,0E1Dh
		mov	di,1
		call	sub_85
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_85:
		mov	data_225,al
		mov	si,2C8Bh
		call	sub_14
		mov	al,[di+0Dh]
		nop				;*ASM fixup - displacement
		cbw				; Convrt byte to word
		add	ax,ax
		mov	si,ax
		mov	bx,offset data_32
		mov	si,[bx+si]
		call	sub_15
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_86:
		mov	ah,51h			; 'Q'
		int	21h			; DOS Services  ah=function 51h
						;  get active PSP segment in bx
						;*  undocumented function
		mov	data_231,bx
		mov	ax,300Eh
		mov	data_232,ax
		xor	ax,ax			; Zero register
loc_269:
		mov	ds,ax
		xor	si,si			; Zero register
		cld				; Clear direction
		lodsb				; String [si] to al
		cmp	al,4Dh			; 'M'
		je	loc_271			; Jump if equal
loc_270:
		push	ds
		pop	ax
		inc	ax
		jmp	short loc_269
loc_271:
		push	ds
		mov	si,data_3e
		lodsw				; String [si] to ax
		pop	bx
		add	bx,ax
		inc	bx
		jc	loc_270			; Jump if carry Set
		cmp	cs:data_231,bx
		jb	loc_270			; Jump if below
		push	ds
		mov	ds,bx
		cmp	byte ptr ds:data_17e,4Dh	; 'M'
		nop				;*ASM fixup - sign extn byte
		je	loc_272			; Jump if equal
		pop	ds
		jmp	short loc_270
loc_272:
		mov	di,cs:data_232
		push	cs
		pop	es
		mov	bx,ds
		pop	ds
		mov	ax,ds
		stosw				; Store ax to es:[di]
		mov	ax,bx
		stosw				; Store ax to es:[di]
		mov	ds,bx
loc_273:
		push	ds
		mov	si,data_3e
		lodsw				; String [si] to ax
		pop	bx
		add	bx,ax
		inc	bx
		mov	ax,bx
		stosw				; Store ax to es:[di]
		mov	ds,bx
		xor	si,si			; Zero register
		lodsb				; String [si] to al
		cmp	al,5Ah			; 'Z'
		jne	loc_273			; Jump if not equal
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		push	cs
		pop	ds
		mov	si,di
		sub	si,6
		lodsw				; String [si] to ax
		mov	data_26,ax
		lodsw				; String [si] to ax
		mov	data_27,ax
		mov	si,offset data_233
loc_274:
		mov	ax,[si]
		cmp	ax,0
		je	loc_275			; Jump if equal
		mov	es,ax
		mov	ax,es:data_2e
		add	ax,10h
		mov	es,ax
		mov	di,data_18e
		cmp	word ptr es:[di],0EBFEh
		je	loc_276			; Jump if equal
		add	si,2
		jmp	short loc_274
loc_275:
		push	cs
		pop	es
		retn
loc_276:
		mov	dx,offset data_221	; ('')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
loc_277:
		call	sub_11
		mov	ax,4C00h
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
sub_80		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_87		proc	near
		push	es
		push	ax
		push	si
		push	dx
		mov	ah,35h			; '5'
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		pop	dx
		pop	si
		pop	ax
		mov	[si],bx
		mov	[si+2],es
		mov	ah,25h			; '%'
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	es
		retn
sub_87		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_88		proc	near
loc_278:
		call	sub_19
		mov	dh,8
		mov	dl,17h
		mov	si,2C65h
		call	sub_14
		mov	al,data_28
		cbw				; Convrt byte to word
		dec	al
		mov	di,ax
		add	di,di
		mov	bx,offset data_229
		call	word ptr [bx+di]	;*
		mov	dh,12h
		mov	dl,18h
		mov	si,2C9Eh
		call	sub_14
		call	sub_13
loc_279:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,0Dh
		je	loc_ret_282		; Jump if equal
		cmp	al,1Bh
		jne	loc_280			; Jump if not equal
		jmp	short loc_ret_282
		db	90h
loc_280:
		and	al,0DFh
		cmp	al,59h			; 'Y'
		je	loc_ret_282		; Jump if equal
		cmp	al,4Eh			; 'N'
		je	loc_281			; Jump if equal
		call	sub_11
		jmp	short loc_279
loc_281:
		call	sub_89

loc_ret_282:
		retn
sub_88		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_89		proc	near
		call	sub_19
		mov	dh,12h
		mov	dl,0Eh
		mov	si,2CC2h
		call	sub_14
		call	sub_13
loc_283:
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		cmp	al,31h			; '1'
		jge	loc_285			; Jump if > or =
loc_284:
		call	sub_11
		jmp	short loc_283
loc_285:
		cmp	al,32h			; '2'
		jg	loc_284			; Jump if >
		mov	data_224,al
		and	al,0Fh
		mov	data_28,al
		cbw				; Convrt byte to word
		push	ax
		mov	dh,8
		mov	dl,17h
		mov	si,2C65h
		call	sub_14
		mov	al,41h			; 'A'
		mov	byte ptr data_227+62h,al	; ('')
		xor	di,di			; Zero register
		mov	bx,0Dh
loc_286:
		mov	dh,12h
		mov	dl,0Eh
		mov	si,2CF8h
		call	sub_14
		call	sub_13
		mov	al,33h			; '3'
		mov	data_102,al
		mov	data_89,2FCDh
		call	sub_16
		mov	[bx+di],al
		push	bx
		push	di
		shl	di,1			; Shift w/zeros fill
		mov	bx,offset data_229
		call	word ptr [bx+di]	;*
		pop	di
		pop	bx
		inc	di
		pop	ax
		cmp	di,ax
		je	loc_287			; Jump if equal
		push	ax
		inc	byte ptr data_227+62h	; ('')
		jmp	short loc_286
loc_287:
		pop	ax
		jmp	loc_278
sub_89		endp

data_229	dw	offset sub_82
data_230	dw	offset sub_83
data_231	dw	0
data_232	dw	0
data_233	dw	100 dup (0)

seg_a		ends



		end	start
