title   DOORS.ASM - Switch Color/Mono Screens On Keyboard Request
;
VECTORS         segment at 0h           ; 8088 / 80286 Interrupt Vector Area
        org     9h*4                    ; IBM PC Keyboard is Int 9H
KB_INT_VECTOR   label   dword           ; Double word label
;
VECTORS         ends
;
ROM_BIOS_DATA   segment at 40h          ; Low Memory "BIOS" Parameters
;
        org     10h                     ; Location of EQUIP_FLAG
EQUIP_FLAG      dw      ?               ; Contains video settings
                                        ; in bits 4 and 5
;
        org     17h                     ; Location of KB_FLAG
KB_FLAG         db      ?               ; Contains Alt (bit 3) &
                                        ; Right Shift (bit 0) States
ROM_BIOS_DATA   ends
;
; Initialization Routine
;
CODE_SEG        segment
        assume  cs:CODE_SEG
        org     100h                    ; COM program format
BEGIN:  jmp     SWAP_VECTORS            ; Initialize vectors and attach to DOS
;
ROM_KB_INT      dd      0               ; Double word to save address of
                                        ; ROM-BIOS keyboard interrupt
; DOORS_INT intercepts the keyboard interrupt and switches
;      screens if [Alt]-[Right Shift] combination is pressed
;
DOORS_INT       proc    near
        assume  ds:nothing
        push    ds                      ; Push all affected registers
        push    es
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
;
        pushf                           ; Push Flags for fake interrupt call
        call    ROM_KB_INT              ; to BIOS program to read keyboard
;
        assume  ds:ROM_BIOS_DATA        ; Define data segment to read
        mov     ax,ROM_BIOS_DATA        ; keyboard flag & equipment flag
        mov     ds,ax
        mov     al,KB_FLAG              ; Get keyboard flag
        and     al,09h                  ; Isolate [Alt] + [Right Shift]
        cmp     al,09h                  ; Are they pressed?
        jne     RETURN                  ; No, quit
;
; [Alt] + [Right Shift] are pressed -- Continue processing
; Check on video mode - quit if not monochrome, color 80x25 or BW 80x25
;
        mov     ah,15                   ; Call Func 15 of Int 10h to
        int     10h                     ; get video state of the PC
        cmp     al,7                    ; Is screen monochrome?
        je      SCREEN_OKAY             ; Yes, go switch screens
        cmp     al,3                    ; Is screen color text?
        jbe     CHECK_40_OR_80          ; Yes, go check for 80 or 40 char
        jmp     RETURN                  ; Screen is in graphics mode, quit
CHECK_40_or_80:
        cmp     al,1                    ; Is screen 40-character?
        jbe     RETURN                  ; Yes, quit
;
SCREEN_OKAY:
;
; Save the current cursor position
;
        mov     ah,3                    ; Call Func 3 of Int 10H
        mov     bh,0                    ; to read cursor position
        int     10h                     ; (page zero for color screen)
;
; Screen switch routine - Establish calling argument (AL) for Int 10h
;
        mov     bx,EQUIP_FLAG           ; Current equipment flag to BX
        mov     cx,bx                   ; Make a copy of it in CX
        and     cx,30h                  ; Extract screen information
        xor     bx,cx                   ; Erase current screen information in BX
        or      bx,20h                  ; Set BX to color 80x25
        mov     al,3                    ; Set AL for color 80x25 in Int 10h
        cmp     cx,30h                  ; Is current mono?
        je      SET_MODE                ; Yes, switch to color
        or      bx,30h                  ; No, set BX for monochrome
        mov     al,7                    ; Set AL for monochrome in Int 10h
SET_MODE:
        mov     EQUIP_FLAG,bx           ; Write BX to equipment flag
        xor     ah,ah                   ; Use Func 0 of Int 10h to
        int     10h                     ; change screen parameters
;
; Restore Cursor
;
        mov     ah,2                    ; Use Func 2 of Int 10h to restore
        mov     bh,0                    ; cursor on new screen (position in DX)
        int     10h
;
; After screens are switched, set DS and ES registers to move screen data
;
        mov     ax,0b000h               ; Load ES with Mono Segment
        mov     es,ax
        mov     ax,0b800h               ; Load DS with Color Segment
        mov     ds,ax
        cmp     cx,30h                  ; Did we switch from mono?
        jne     COPY_THE_SCREEN         ; Yes, move data from mono to color
        push    ds                      ; No, swap ES and DS to move data
        push    es                      ; from color to mono
        pop     ds
        pop     es
COPY_THE_SCREEN:
        xor     di,di                   ; Start at zero offsets
        xor     si,si
        mov     cx,2000                 ; 2000 chars + attrs per screen
        cld                             ; Make sure move is 'forward'
rep     movsw                           ; Move Words with string instruction
;
RETURN:
        pop     di                      ; Restore saved registers
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     es
        pop     ds
        iret                            ; Return to system

DOORS_INT       endp
;
; This procedure initializes the new keyboard interupt vectors
;
SWAP_VECTORS    proc    near
        assume  ds:VECTORS
        mov     ax,VECTORS                      ; Set up the data
        mov     ds,ax                           ; segment for vectors
        cli                                     ; Disable interrupts
        mov     ax,word ptr KB_INT_VECTOR       ; Store addresses
        mov     word ptr ROM_KB_INT,ax          ; of BIOS program
        mov     ax,word ptr KB_INT_VECTOR[2]
        mov     word ptr ROM_KB_INT[2],ax
        mov     word ptr KB_INT_VECTOR, offset DOORS_INT ; Substitute Our
        mov     word ptr KB_INT_VECTOR[2],cs             ; Program
        sti                                     ; Enable interrupts
        mov     dx,offset SWAP_VECTORS          ; End of new resident
                                                ; program
        int     27h                             ; Terminate resident
SWAP_VECTORS    endp
CODE_SEG        ends
        end     BEGIN
;
