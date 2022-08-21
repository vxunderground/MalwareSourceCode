
; NOTE : This template is for .COM files only do not use for .EXE files!!


;
;
;
;       Copyright 1986 by Dana Nowell - All rights reserved
;
; HISTORY:
;     Version     Date         Name            Description
;       1.0     11/10/86        dn      first cut
;       1.01    11/21/86        dn      Fixed memory allocation bug
;                                       Added installation message
;


title   TSR Template



        NULL            equ     00h
        BELL            equ     07h             ; bell character
        BACKSPACE       equ     08h             ; backspace character
        TAB             equ     09h             ; tab character
        LF              equ     0ah             ; line feed
        F_FEED          equ     0ch             ; form feed
        CR              equ     0dh             ; carriage return
        EOF             equ     1ah             ; ctrl z ( end of file )
        SPACE           equ     ' '             ; ascii space character
        QUOTE           equ     '"'

SIGNATURE1              equ     6144h           ; used for already
SIGNATURE2              equ     616eh           ; resident check

DOS_INT                 equ     21h      ; DOS function interrupt
DISP_CHAR               equ     02h
GET_KEY                 equ     08h
DOS_SCR_MSG             equ     09h
DOS_SET_INT             equ     25h
DOS_RESIDENT            equ     31h
DOS_GET_INT             equ     35h
DOS_TERMINATE           equ     4ch
DOS_STRING_TERM         equ     '$'

; Interrupt vectors used

HOOK_INT       equ   1ch      ; interrupt to be hooked ( timer tick now )

;------------------------------------------------------------------------------
;
;       MACRO   SECTION
;
;------------------------------------------------------------------------------

Version_msg     macro
                jmp     short copyright_end

copyright_msg   db      CR, LF
                db      'TSR Shell - Version 1.01', CR, LF
                db      'Copyright 1986, Dana Nowell  ', CR, LF, CR, LF
                db      'May be distributed without license', CR, LF, '$'
copyright_end:
                Msg     copyright_msg
                endm


Msg     macro   ptr

        push    dx
        push    ax

        lea     dx, ptr
        mov     ah, 09h
        int     21h

        pop     ax
        pop     dx

        endm





com     segment para public 'code'
        assume cs:com, ds:com, es:com

;------------------------------------------------------------------------------
;
;       note:   The PSP occurs at the beginning of the code segment
;               for all programs.  In COM files the code seg = data seg
;
;------------------------------------------------------------------------------

        org     0

psp_start       dw      ?       ; int 20h - possibly a block for unresolved
                                ; externals during link ?

mem_size        dw      ?       ; size of available memory in paragraphs
filler          db      ?       ; reserved usually zero

dos_call        db      ?       ; call
                dd      ?       ; address of dos function handler

term_vector     dd      ?       ; address of dos terminate routine
break_vector    dd      ?       ; address of dos break routine
error_vector    dd      ?       ; address of dos error routine
dos_reserved    db      2 dup(?); reserved by dos
dos_handles     db      20 dup(?) ; file handle array
environ_ptr     dw      ?       ; seg of dos environment ( offset = 0 )
dos_work        db      34 dup(?) ; dos work area

int_21h         db      ?       ; int
                db      ?       ; 21h
                db      ?       ; retf ( return far )

reserved        dw      ?       ; reserved by dos
fcb1_ext        db      7 dup(?) ; fcb # 1 extension
fcb1            db      9 dup(?) ; fcb #1
fcb2_ext        db      7 dup(?) ; fcb # 2 extension
fcb2            db      20 dup(?) ; fcb #2

;
;    disk transfer area ( dta ) and parameter block occupy the same space
;
;
;dta             db      128 dup(?) ; disk transfer area



param_len       db      ?       ; length of parameter string ( excludes CR )
parameters      db      127 dup(?) ; parameters

;------------------------------------------------------------------------------
;
; Note on standard fcb structure :
;
;       The standard FCB is larger than the size reserved in the PSP if you
; intend to use to FCB data from the PSP move it to a different location.
;
;
;               STANDARD STRUCTURE OF A FILE CONTROL BLOCK
;
;
;    extension :
;            offset  length             description
;              -7       1       extension active flag ( 0ffh = active )
;              -6       5       normally unused should be zeros
;              -1       1       file attribute when extension is active
;                                      1  . . . . . . . 1   read-only
;                                      2  . . . . . . 1 .   hidden
;                                      4  . . . . . 1 . .   system
;                                      8  . . . . 1 . . .   volume label
;                                     16  . . . 1 . . . .   subdirectory
;                                     32  . . 1 . . . . .   archive
;                                     64  . 1 . . . . . .   unused
;                                    128  1 . . . . . . .   unused
;
;    fcb :
;            offset  length             description
;               0       1       special drive number ( 1 byte )
;                               0 = default
;                               1 = a:
;                               2 = b:       etc
;               1       8       filename or device name
;               9       3       filename extension
;              12       2       current block number
;              14       2       record size
;              16       4       file size in bytes ( dos dir entry at open )
;              20       2       file date ( bit coded as in dir )
;              22      10       dos work area
;              32       1       current record number ( 0 - 127 )
;              33       4       random record number
;
;------------------------------------------------------------------------------



        org     100h    ; required for COM file ( skips PSP )


start:
        jmp     install                 ; install the demon

;-------------------------------------------------------------------
;
;               resident data structures go here
;
;-------------------------------------------------------------------

        old_int         dd      0       ; original value of hooked interrupt
        resident1       dw      SIGNATURE1
        resident2       dw      SIGNATURE2


;-------------------------------------------------------------------
;
;               new interrupt starts here
;
;-------------------------------------------------------------------

new_int:
        pushf

        sti             ; must turn INT on if we're going to use them

;-------------------------------------------------------------------
;
;               be well behaved and pass control to original int
;
;-------------------------------------------------------------------

        popf
        pushf
        call   dword ptr cs:old_int     ; do old interrupt

        iret                            ; bye bye

;------------------------------------------------------------------------------
;
;       INSTALLATION DATA STRUCTURES AND CODE GO HERE
;
; WARNING WARNING WARNING - this area does not exist after installation
;
;------------------------------------------------------------------------------

last_resident_byte      db      0       ; last resident byte
resident_flag           dw      0       ; am I already resident ? ( 0 = NO )

install_msg             db      CR, LF, 'Installation Complete', CR, LF, '$'

already_installed_msg   db      CR, LF
                        db      'Already Installed - Installation Aborted'
                        db      CR, LF, '$'

install proc    near

        Version_msg


         mov   al, HOOK_INT           ; int to hook
         mov   ah, DOS_GET_INT        ; get int(AL) vector ==> ES+BX
         int   DOS_INT                ; do the int
         lea   si, old_int            ; where to put old timer interrupt vector
         mov   [si], bx               ; save the offset and segment
         mov   2[si], es              ; ( es also used in check resident )

         call   check_resident        ; am I already resident ?

         cmp    resident_flag, 0
         je     not_resident

         Msg    already_installed_msg

         mov     ah, DOS_TERMINATE    ; terminate & stay resident
         mov     al, 1                ; return value is 1 (already installed)
         int     DOS_INT              ; bye-bye

not_resident:
         mov   dx, offset new_int     ; offset of new timer interrupt
         mov   al, HOOK_INT           ; timer tick
         mov   ah, DOS_SET_INT        ; set int(AL) vector from DS+DX
         int   DOS_INT                ; do the int

; program terminate and stay resident

         Msg     install_msg          ; Display the installation message

         mov     dx, offset last_resident_byte

         mov     cl, 4                ; convert to paragraphs required to
         shr     dx, cl               ; remain resident ( divide by 16 )
         inc     dx                   ; allow for any remainder of division

         mov     ah, DOS_RESIDENT     ; terminate & stay resident
         mov     al, 0                ; return value is 0 (good return)
         int     DOS_INT              ; bye-bye

install endp


;
;       Check resident procedure
;               requires es register to contain the segment address of
;               the current location for the interrupt being hooked.
;               use the DOS function 35h to obtain this information.
;

check_resident  proc    near

         cmp    es:resident1, SIGNATURE1
         jne    not_res
         cmp    es:resident2, SIGNATURE2
         jne    not_res

         mov    resident_flag, 1

not_res:
        ret

check_resident  endp

com     ends
        end     start
