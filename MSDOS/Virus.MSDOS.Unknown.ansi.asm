; this is ripped off from pd code in RBBS-ASM (was ANSI1-7.ASM)
; has been heavily modified by M. Kimes, who isn't much of an
; asm-programmer.  Now works with C in a strange way and supports
; configurable window.  It's momma wouldn't know it now (and probably
; would claim it's the type of program she warned it about).
; I reckon it was public domain before, and still is.
;
; int  far pascal ansi      (char far *str);
; void far pascal setcoords (int topx,int topy,int botx,int boty);
; void far pascal getcoords (int far *topx,int far *topy,int far *botx,int far *boty);
; void far pascal setfastansi (int fast);
;

.model large

ANSI_PRNT SEGMENT PUBLIC 'CODE'
          ASSUME CS:ANSI_PRNT
          PUBLIC ANSI,SETCOORDS,GETCOORDS,SETFASTANSI,GETFASTANSI
          PUBLIC _atop,_atopy,_atopx,_abot,_aboty,_abotx,_fastansiout

VID_PAGE          DB 0                  ;Active video page
_atop             LABEL WORD
_atopy            DB 0                  ;top y coord
_atopx            DB 0                  ;top x coord
_abot             LABEL WORD
_aboty            DB 17h                ;bottom y coord
_abotx            DB 4Fh                ;bottom x coord
_fastansiout      DB 1                  ;fast ansi writes?


GETCOORDS PROC    FAR   ;void pascal far getcoords(int *topx,int *topy,
                        ;                          int *botx,int *boty);

; get window coordinates (0 based)

          PUSH    BP
          MOV     BP,SP
          PUSH    DS
          MOV     AH,0
          MOV     AL,_atopx
          MOV     BX,[BP]+18
          MOV     DS,[BP]+20
          MOV     [BX],AX
          MOV     AL,_atopy
          MOV     DS,[BP]+16
          MOV     BX,[BP]+14
          MOV     [BX],AX
          MOV     AL,_abotx
          MOV     DS,[BP]+12
          MOV     BX,[BP]+10
          MOV     [BX],AX
          MOV     AL,_aboty
          MOV     DS,[BP]+8
          MOV     BX,[BP]+6
          MOV     [BX],AX
          POP     DS
                  POP     BP
          RET     16

GETCOORDS ENDP

SETCOORDS PROC    FAR   ;void pascal far setcoords(int topx,int topy,
                        ;                          int botx,int boty);

; set window coordinates (0 based)

          PUSH    BP
          MOV     BP,SP
          MOV     AH,[BP]+12
          MOV     _atopx,AH
          MOV     AH,[BP]+10
          MOV     _atopy,AH
          MOV     AH,[BP]+8
          MOV     _abotx,AH
          MOV     AH,[BP]+6
          MOV     _aboty,AH
          POP     BP
          RET     8

SETCOORDS ENDP



SETFASTANSI PROC    FAR   ;void pascal far setfastansi(int fast);

; set fast ansi (0 = off, ffh = BIOS)

          PUSH    BP
          MOV     BP,SP
          MOV     AH,[BP]+6
          MOV     _fastansiout,AH
          POP     BP
          RET     2

SETFASTANSI ENDP



GETFASTANSI PROC    FAR   ;int pascal far getfastansi(void);

; get fast ansi setting (0 = off)

          XOR     AX,AX
          MOV     AH,_fastansiout
          RET

GETFASTANSI ENDP



ANSI      PROC    FAR   ;int pascal far ansi(char far *str);

; display a string through DOS' ANSI driver, respecting a window

          PUSH    BP                    ;set up stack frame
          MOV     BP,SP

          PUSH    DS                    ;save ds

          MOV     AH,15                 ;get current video state
          INT     10H
          MOV     VID_PAGE,BH           ;save it

          MOV     BX,[BP]+6             ;get string address
          MOV     DS,[BP]+8             ;set ds
          PUSH    BX                    ;save original address
          MOV     CX,BX
          XOR     AX,AX

ALOOP:
          CALL    DOCHECKPOS
          MOV     AL,[BX]               ;set al to char to print
          CMP     AL,10                 ;\n?
          JNZ     CHKCR                 ;no
          MOV     DX,AX
          MOV     AH,2
          INT     21H                   ;display it
          CALL    DOCHECKPOS
          MOV     AL,13                 ;and do cr
          JMP     NOEXIT1
CHKCR:
          CMP     AL,13                 ;\r?
          JNZ     CHKANSI               ;no
          MOV     DX,AX
          MOV     AH,2
          INT     21H                   ;display it
          CALL    DOCHECKPOS
          MOV     AL,10                 ;and do lf
          JMP     NOEXIT1
CHKANSI:
          CMP     AL,27                 ;escape?
          JNZ     GOON                  ;no, skip all this...
          CMP     BYTE PTR [BX]+1,'['   ; check for various ansi
          JNZ     GOON                  ; commands that would screw
          CMP     BYTE PTR [BX]+2,'2'   ; up our window
          JNZ     GOON1                 ; \x1b[2J
          CMP     BYTE PTR [BX]+3,'J'
          JNZ     GOON2
          ADD     BX,4
          CALL    CLEARSCRN
          JMP     SHORT ALOOP
GOON1:
          CMP     BYTE PTR [BX]+2,'K'   ; \x1b[K
          JNZ     GOON3
          ADD     BX,3
          CALL    CLEARLINE
          JMP     SHORT ALOOP
GOON3:
          CMP     BYTE PTR [BX]+2,'k'   ;\x1b[k
          JNZ     GOON
          ADD     BX,3
          CALL    CLEAREOL
          JMP     SHORT ALOOP
GOON2:
          CMP     BYTE PTR [BX]+3,'j'   ;\x1b[2j
          JNZ     GOON
          ADD     BX,4
          CALL    CLEAREOS
          JMP     ALOOP
GOON:
          CMP     AL,0              ;End of string?
          JNZ     NOEXIT1
          JMP     SHORT EXIT1
NOEXIT1:                            
          CMP     _fastansiout,0    ;fast ansi writes?
          JZ      BIOSWRITES        ;nope
          INT     29H
          JMP     SHORT SKIPSLOW
BIOSWRITES:
          CMP     _fastansiout,255  ;bios writes?
          JZ      SLOWWRITES        ;nope
          PUSH    BX
          PUSH    CX
          MOV     BH,VID_PAGE
          INT     10H
          POP     CX
          POP     BX
          JMP     SHORT SKIPSLOW
SLOWWRITES:
          MOV     DX,AX
          MOV     AH,2
          INT     21H               ;display it
SKIPSLOW:
          INC     BX
          CMP     BYTE PTR [BX],0   ;end of string?
          JZ      EXIT1             ;yep
          CMP     BX,CX             ;string too long?
          JZ      EXIT1             ;yep, it wrapped; avoid crash
          JMP     ALOOP             ;nope
EXIT1:                              ;wrap it up...
          CALL    DOCHECKPOS
          POP     AX                ;retrieve old start pos
          SUB     BX,AX             ;subtract from current pos
          MOV     AX,BX             ;return length of string printed

          POP     DS
          POP     BP
          RET     4

ANSI      ENDP



DOCHECKPOS:                         ;check cursor pos, protect window
          PUSH    AX                ;Save the registers that will be affected
          PUSH    BX
          PUSH    CX
          PUSH    DX
          CALL    WHERE_ARE_WE      ; where the cursor is.......
CHECKTOPX:
          CMP     DL,_atopx
          JGE     CHECKBOTX
          MOV     AH,2
          MOV     DL,_atopx
          MOV     BH,VID_PAGE
          INT     10H
          JMP     SHORT CHECKTOPY
CHECKBOTX:
          CMP     DL,_abotx
          JLE     CHECKTOPY
          MOV     DL,_atopx
          INC     DH
          MOV     AH,2
          MOV     BH,VID_PAGE
          INT     10H
CHECKTOPY:
          CMP     DH,_atopy
          JGE     CHECKBOTY
          MOV     AH,2
          MOV     DH,_atopy
          MOV     BH,VID_PAGE
          INT     10H
          JMP     SHORT OUTTAHERE
CHECKBOTY:
          CMP     DH,_aboty         ; Row ???
          JLE     OUTTAHERE         ; Jump if less
          CALL    SCROLLIT          ; else scroll, we're too low
          MOV     DH,_aboty         ; put cursor back in window
          MOV     BH,VID_PAGE
          INT     10H
OUTTAHERE:
          POP     DX                ;Restore registers
          POP     CX
          POP     BX
          POP     AX
          RET


WHERE_ARE_WE:                       ;Get the current cursor position
          PUSH    AX                ;Save the registers
          PUSH    BX
          PUSH    CX
          MOV     AH,03             ;SET UP FOR ROM-BIOS CALL (03H)
          MOV     BH,VID_PAGE       ;TO READ THE CURRENT CURSOR POSITION
          INT     10H               ; DH = ROW   DL = COLUMN
          POP     CX                ;Restore the registers
          POP     BX
          POP     AX
          RET                        ;And go back from wence we came


SCROLLIT: PUSH    AX                ;Save the registers that will be affected
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,2              ;Now set cursor position to ???,???
          MOV     DH,_aboty
          MOV     DL,_atopx
          MOV     BH,VID_PAGE       ;attribute
          INT     10H
          MOV     AH,8              ;Get the current character attribute
          MOV     BH,VID_PAGE
          INT     10H
          MOV     BH,AH             ;Transfer the attribute to BH for next call
          MOV     AH,6              ;Otherwise scroll ??? lines
          MOV     AL,1              ;Only blank line ???
          MOV     CH,_atopy
          MOV     CL,_atopx
          MOV     DH,_aboty
          MOV     DL,_abotx
          INT     10H               ;And do it.......
          MOV     AH,2              ;Now set cursor position to ???,???
          MOV     DH,_aboty
          MOV     DL,_atopx
          MOV     BH,VID_PAGE
          INT     10H
          POP     DX                ;Restore the stack like it was
          POP     CX
          POP     BX
          POP     AX
          RET

CLEARSCRN:                          ;Clear current window
          PUSH    AX                ;Save the registers
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,2              ;Now set cursor position to ???,???
          MOV     DH,_aboty
          MOV     DL,_atopx
          MOV     BH,VID_PAGE       ;attribute
          INT     10H
;          MOV     AH,8              ;Get the current character attribute
;          MOV     BH,VID_PAGE
;          INT     10H
;          MOV     BH,AH             ;Transfer the attribute to BH for next call
          MOV     BH,7
          MOV     AH,6              ;Otherwise scroll ??? lines
          MOV     AL,0              ;clear screen
          MOV     CH,_atopy
          MOV     CL,_atopx
          MOV     DH,_aboty
          MOV     DL,_abotx
          INT     10H               ;And do it.......
          MOV     AH,2              ;Now set cursor position to ???,???
          MOV     DH,_atopy
          MOV     DL,_atopx
          MOV     BH,VID_PAGE
          INT     10H
          POP     DX                ;Restore the stack like it was
          POP     CX
          POP     BX
          POP     AX
          RET

CLEAREOS:                           ;Clear to end of current window
          PUSH    AX                ;Save the registers
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,8              ;Get the current character attribute
          MOV     BH,VID_PAGE
          INT     10H
          MOV     BH,AH             ;Transfer the attribute to BH for next call
          MOV     AH,6              ;Otherwise scroll ??? lines
          MOV     AL,0              ;clear
          CALL    WHERE_ARE_WE
          PUSH    DX                ;save it
          MOV     CX,DX
          MOV     DH,_aboty
          MOV     DL,_abotx
          INT     10H               ;And do it.......
          MOV     AH,2
          MOV     BH,VID_PAGE
          POP     DX
          INT     10H               ;restore position
          POP     DX                ;Restore the stack like it was
          POP     CX
          POP     BX
          POP     AX
          RET

CLEARLINE:                          ;Clear current line
          PUSH    AX                ;Save the registers
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,8              ;Get the current character attribute
          MOV     BH,VID_PAGE
          INT     10H
          CALL    WHERE_ARE_WE
          PUSH    DX                ;save it
          MOV     BH,AH             ;Transfer the attribute to BH for next call
          MOV     AH,6              ;Otherwise scroll ??? lines
          MOV     AL,0              ; clear line
          MOV     CX,DX
          MOV     CL,_atopx
          MOV     DL,_abotx
          INT     10H               ; And do it.......
          MOV     AH,2              ;Now set cursor position to ???,???
          MOV     DL,_atopx
          MOV     BH,VID_PAGE
          INT     10H
          MOV     AH,2
          MOV     BH,VID_PAGE
          POP     DX
          INT     10H               ;restore position
          POP     DX                ;Restore the stack like it was
          POP     CX
          POP     BX
          POP     AX
          RET

CLEAREOL:                           ;Clear to end of current line
          PUSH    AX                ;Save the registers
          PUSH    BX
          PUSH    CX
          PUSH    DX
          MOV     AH,8              ;Get the current character attribute
          MOV     BH,VID_PAGE
          INT     10H
          CALL    WHERE_ARE_WE
          PUSH    DX                ;save it
          MOV     BH,AH             ;Transfer the attribute to BH for next call
          MOV     AH,6              ;Otherwise scroll ??? lines
          MOV     AL,0              ;clear line
          MOV     CX,DX
          MOV     DL,_abotx
          INT     10H               ;And do it.......
          MOV     AH,2
          MOV     BH,VID_PAGE
          POP     DX
          INT     10H               ;restore position
          POP     DX                ;Restore the stack like it was
          POP     CX
          POP     BX
          POP     AX
          RET

ANSI_PRNT ENDS
          END
