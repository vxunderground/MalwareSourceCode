;---------------------------------------------------------------------------
;KBM KeyBoard Mouse            by Dan Rollins                       5-20-85
;
; This program intercepts keyboard data and creates a bit pattern determined
; according to whether or not certain keys are currently being pressed.
;
; The bit pattern is stored in the "inter-application communication area"
;  at 0000:04f0.  It is interpreted as:
;
;  7 6 5 4 3 2 1 0   (bit number)
;  C m P H l d r u   (bit name)
;  | | | | | | | |
;  | | | | | | | +- bit 0 (01h) - set = 1 while [up arrow] is pressed
;  | | | | | | +--- bit 1 (02h) - set = 1 while [right arrow] is pressed
;  | | | | | +----- bit 2 (04h) - set = 1 while [down arrow] or [5] is pressed
;  | | | | +------- bit 3 (08h) - set = 1 while [left arrow] is pressed
;  | | | |
;  | | | +--------- bit 4 (10h) - set = 1 while [Home] is pressed
;  | | +----------- bit 5 (20h) - set = 1 while [PgUp] is pressed
;  | +------------- bit 6 (40h) - set = 1 while grey [-] is pressed
;  +--------------- bit 7 (80h) - set = 1 while [CapsLock] is pressed
;
; As soon as the key is released, the relevant bit is reset to 0.
;
; The byte at 0000:04f1 is the "pass-through/filter" mode flag.  When this
; byte is zero, all keystrokes are passed to the normal keyboard handler.
; When it's non-zero, the selected keystrokes are filtered (disabled for
; normal input).  BIOS and DOS keyboard calls will not recognize them.
;
; The Alt-NumLock keystroke toggles between pass-through and filter modes.
;
; This program is installed and remains resident.  It is a COM-format
; file, so it must be converted with EXE2BIN.
;
; Copyright (c) Ziff-Davis Publishing Co., 1986.  All rights reserved.  
;
;= equates ===============

KB_DATA_PORT  equ     60h  ;These are listed in the PC and XT
KB_CTRL_PORT  equ     61h  ; Technical Reference Manuals

KB_FLAG       equ    417h  ; the BIOS shift-key status (in segment 0)
ALT_STATE     equ      8   ;  Bit pattern while the [Alt] key is pressed
NUMLOCK_KEY   equ     69   ;  scan-code of the [NumLock] key

INT_CTL_PORT  equ     20h  ; Interrupt controller port (8259 chip)
EOI           equ     20h  ; End-Of-Interrupt code sent to 8259

RELEASE_BIT   equ     80h  ;also called the "break" bit: a key was released

KEY_BITS      equ     04f0H ;the address of the key bit flags (segment 0)
MODE_FLAG     equ     04f1H ;when 0, all keys are passed to normal kbint
INST_FLAG     equ     04f2H ; set to 1234H during installation

com_seg  segment
         assume  cs:com_seg, ds:com_seg
         org     100h                    ;must have for COM-format program
kbm      proc    far
         jmp     set_up    ;get past data and install interrupt hander

;============= program data area ========

norm_kbd_int  label dword   ;type DWORD so it can be used in a FAR jump
nki_offset    dw    0       ; This address is stored in the SET_UP proc
nki_segment   dw    0       ; It's the address of the previous kbint routine

;-----------------------------------------------------------------------------
; KBD_INT
; 1) read the keyboard
; 2) set/reset bits in mouse movement byte
; 3) execute normal keyboard interrupt
;
;          scan  bit     key         suggested  meaning
;          code  flag    name        (defined by user)
;          ---- ----     ---------  ----------------------
kbm_tbl  db  72, 1  ;    num.pad 8   go up
         db  77, 2  ;    num.pad 6   go right
         db  80, 4  ;    num.pad 2   go down
         db  75, 8  ;    num.pad 4   go left

         db  76, 4  ;    num.pad 5   go down
         db  71, 16 ;    Home        button 1
         db  73, 32 ;    PgUp        button 2
         db  74, 64 ;    grey minus  button 3
         db  58, 128;    CapsLock    "high-gear shift" for fast motion
tbl_end  label byte

;-----------------------------------------------------------------------------
; KBD_INT
; This procedure intercepts the ROM-BIOS KB_INT.
; It sets and resets bits of a kbd flag as the user presses and releases keys.
; When the byte at 0000:04F1 is 0, the keystroke is passed on to the
; original keyboard handler.

kbd_int  proc    far
         sti
         cld
         push    ax
         push    si
         push    ds

         in      al,KB_DATA_PORT ;read scan-code from keyboard into AL
         mov     ah,al           ;save original byte in AH
         and     al,7fh          ;mask off "release bit" for comparisons

         mov     si,offset kbm_tbl
k_20:
         cmp     si,offset tbl_end   ;at end of table?
         ja      k_25                ; yes, key not found. Exit to normal kbint
         cmp     al,byte ptr cs:[si] ; is this the key?
         je      k_30                ;   yes, process the keystroke
         inc     si                  ;   no, point past the scan code
         inc     si                  ;       point past the bit-mask
         jmp     k_20                ;       and loop back for the next entry

k_25:
;------- check for mode-toggle by user
         cmp     ah,NUMLOCK_KEY                  ;is this a press of [NumLock]?
         jne     k_27                            ;  no, go
         sub     si,si                           ;  yes, look to BIOS data area
         mov     ds,si
         test    byte ptr ds:[KB_FLAG],ALT_STATE ;  is [Alt] pressed?
         jz      k_27                            ;    no, pass the key on

         xor     byte ptr ds:[MODE_FLAG],1       ;    yes, toggle the mode and
         jmp    short k_exit                     ;         exit w/o processing

;------- the keystroke is to be processed by the normal keyboard interrupt
k_27:
         pop     ds
         pop     si
         pop     ax
         jmp     cs:[norm_kbd_int]       ;continue at normal keyboard handler

k_30:
;------- process the scan code into a bit-pattern
         mov     al,cs:[si+1]     ;get bit-flag mask

         sub     si,si
         mov     ds,si            ;point to segment of KEY_BITS

         test    ah,RELEASE_BIT   ;is this key being released?
         jz      k_40             ; no, go

;------- process key release
         not     al                           ;flip-flop mask bits
         and     byte ptr ds:[KEY_BITS],al    ;mask off released key bit
         jmp     k_50
k_40:
;------- process key press
         or      byte ptr ds:[KEY_BITS],al    ;set the bit for pressed key

;------- determine whether key should be passed on to normal keyboard handler
k_50:
         cmp     byte ptr ds:[MODE_FLAG],0    ;should key be processed further?
         je      k_27                         ; yes, continue at normal kb int

;------- the keystroke is to be ignored by the rest of the system.
;------- wrap up this keyboard interrupt.

k_exit:
         in      al,KB_CTRL_PORT ;get current value of keyboard control lines
         mov     ah,al           ; save it
         or      al,80h          ;set the "enable kbd" bit
         out     KB_CTRL_PORT,al ; and write it out the control port
         xchg    ah,al           ;fetch the original control port value
         out     KB_CTRL_PORT,al ; and write it back

         pop     ds
         pop     si

         cli
         mov     al,EOI           ;send End-Of-Interrupt signal
         out     INT_CTL_PORT,al  ; to the 8259 Interrupt Controller
         pop     ax
         iret                     ;exit to interrupted program
kbd_int  endp

LAST_BYTE equ   offset $+1  ;This is the address passed to INT 27H
                            ;Notice that the code of the SET_UP
                            ;  procedure is not preserved in memory

;-----------------------------------------------------------------------------
; SET_UP
; This routine is executed only once, when the program is installed.

inst_msg db 'KBM  KeyBoard Mouse driver',0dh,0ah
         db 'Copyright (c) 1986 Ziff-Davis Publishing Co.,',0dh,0ah,'$'

err_msg1 db 07,'Already installed',0dh,0ah,'$'
err_msg2 db 'Wrong DOS version.',0dh,0ah,'$'

set_up   proc    near

;------- make sure this is DOS 2.0 or later
         mov     ah,30h
         int     21h
         cmp     al,2
         jae     su_10
         mov     dx,offset err_msg2
         jmp     msg_exit
su_10:

;------- see if KBM has already been installed
         mov     ax,0
         mov     es,ax
         cmp     es:[INST_FLAG],1234H  ;already installed?
         jne     su_20                 ;  no, continue
         mov     dx,offset err_msg1    ;  yes, exit with message
         jmp     msg_exit
su_20:
         mov     word ptr es:[INST_FLAG],1234h  ; flag says KBM is installed

;------- save the old kbint vector and set up the new one
         mov     al,9
         mov     ah,35h         ;DOS GET_VECTOR service
         int     21h            ; for interrupt 9 (KBINT)

         mov     al,9           ;get address of the current kb int handler
         mov     ah,35h         ;DOS GET_VECTOR service
         int     21h
         mov     nki_segment,es ;save old address
         mov     nki_offset,bx

         mov     dx,offset kbd_int  ;set INT 9 to local keyboard interceptor
         mov     al,9               ;set vector for INT 9 to DS:DX
         mov     ah,25h             ;DOS SET_VECTOR service
         int     21h

         mov     ax,0
         mov     es,ax                          ;initialize variables:
         mov     byte ptr es:[MODE_FLAG],0      ; process all keystrokes
         mov     byte ptr es:[KEY_BITS],0       ; no keys are pressed

;------- display message to indicate install`tion complete
         mov     dx,offset inst_msg
         mov     ah,9
         int     21h

;------- exit to DOS, leaving the interrupt handler resident
         mov     dx,LAST_BYTE
         int     27h

msg_exit:
         mov     ah,9
         int     21h
         int     20h
set_up   endp
kbm      endp
com_seg  ends
         end     kbm

          