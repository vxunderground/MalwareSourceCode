PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл                                                                      лл
;лл                             TWELVE                                   лл
;лл                                                                      лл
;лл      Created:   26-Apr-90                                            лл
;лл      Version:                                                        лл
;лл      Passes:    5          Analysis Options on: H                    лл
;лл                                                                      лл
;лл                                                                      лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

data_1e         equ     3366h                   ; (7415:3366=0)
data_2e         equ     7EF7h                   ; (7415:7EF7=0)
data_3e         equ     8C8Dh                   ; (7415:8C8D=0)

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

twelve          proc    far

start:
;*              jmp     $+4h                    ;*
                db      0E9h, 1, 0
                db      21h, 46h, 0B8h, 9Bh, 1Ah, 0BFh
                db      2Bh, 1, 90h, 4Bh, 0F8h, 0FCh
                db      0B9h, 71h, 5, 31h, 0Dh, 2Bh
                db      0DAh, 33h, 0D9h, 2Bh, 0D9h, 2Bh
                db      0D8h, 90h, 33h, 0D1h, 31h, 5
                db      46h, 43h, 0F8h, 40h, 90h, 47h
                db      0E2h, 0E9h, 40h, 40h, 61h, 1Fh
                db      6Eh, 3, 0C9h, 82h, 6Fh, 36h
                db      0D1h, 5Ah, 8Bh, 33h, 0C3h, 6Bh
                db      0D5h, 0D7h, 85h, 0CCh, 17h, 4Eh
                db      0E9h, 0F3h, 7Ch, 0B1h, 29h, 52h
                db      0FBh, 0FFh, 74h, 0B5h, 2Bh, 56h
                db      0F9h, 0F3h, 64h, 0A9h, 0Dh, 32h
                db      9Bh, 97h, 1Ch, 0D5h, 7Fh, 64h
                db      82h, 7Bh, 0ADh, 94h, 1Eh, 61h
                db      6Ch, 29h, 7Dh, 0F3h, 4Ah, 0F7h
                db      0F4h, 4Ah, 0FEh, 0FFh, 1, 0
                db      51h, 7Ch, 7, 47h, 0DDh, 22h
                db      0CCh, 0EFh, 0D5h, 1Bh, 0F2h, 81h
                db      0DEh, 36h, 5Fh, 0D1h, 0D3h, 63h
                db      0FAh, 1Eh, 0CCh, 23h, 0E1h, 76h
                db      0ABh, 0Bh, 39h, 5Ch, 0DEh, 0B9h
                db      3, 0F4h, 7Eh, 21h, 74h, 31h
                db      0Ch, 0EFh, 59h, 9, 0D9h, 37h
                db      12h, 44h, 92h, 18h, 30h, 12h
                db      0ABh, 16h, 14h, 4Ch, 0BAh, 6Eh
                db      2Bh, 6Fh, 0F5h, 5Bh, 4Ch, 0F3h
                db      7Dh, 0Dh, 53h, 4Ah, 0F1h, 0F7h
                db      59h, 5Dh, 98h, 2, 0Fh, 29h
                db      8Bh, 0D0h, 5Ch, 0ADh, 29h, 54h
                db      3, 52h, 13h, 76h, 0D5h, 58h
                db      13h, 4, 0D7h, 63h, 39h, 74h
                db      8Bh, 7, 0FDh, 8Ah, 0F9h, 1Ah
                db      0D1h, 0F5h, 39h, 0EDh, 0BBh, 0C9h
                db      63h, 8Dh, 0B9h, 97h, 1Eh, 6Dh
                db      0BBh, 14h, 0EBh, 67h, 14h, 50h
                db      34h, 93h, 41h, 0D3h, 0D6h, 87h
                db      0FEh, 0CBh, 0F5h, 87h, 0F9h, 55h
                db      16h, 7, 39h, 49h, 0F5h, 0F3h
                db      0B6h, 0F0h, 64h, 0A5h, 21h, 57h
                db      28h, 2Ch, 0A9h, 0DCh, 6Dh, 8Fh
                db      7Fh, 5Eh, 0ABh, 21h, 66h, 1Ch
                db      6Ch, 35h, 63h, 0F7h, 4Ch, 0F5h
                db      0FDh, 0Ch, 59h, 78h, 6, 43h
                db      0BBh, 78h, 3Bh, 6Eh, 2Fh, 0B2h
                db      15h, 0AEh, 16h, 13h, 0D0h, 3Eh
                db      0F6h, 15h, 85h, 0DBh, 0A1h, 5Ch
                db      20h, 0CEh, 9Eh, 0F0h, 1Eh, 68h
                db      39h, 78h, 79h, 8, 0FDh, 0D7h
                db      0EAh, 0CBh, 0EAh, 87h, 0, 6Eh
                db      51h, 28h, 0D5h, 0D7h, 2Dh, 0A7h
                db      38h, 5Ch, 61h, 28h, 0D5h, 0DDh
                db      0A1h, 0Dh, 66h, 91h, 1Fh, 0A5h
                db      74h, 31h, 0Ah, 0F3h, 51h, 55h
                db      0C1h, 0F3h, 80h, 0Dh, 0ABh, 4Bh
                db      0EDh, 0ACh, 66h, 45h, 14h, 55h
                db      34h, 93h, 50h, 0BEh, 14h, 0DDh
                db      63h, 2Fh, 94h, 0D0h, 6Ch, 0Eh
                db      13h, 0Ch, 7Eh, 21h, 74h, 31h
                db      5Ch, 0FFh, 30h, 0D2h, 4Dh, 0F5h
                db      0C8h, 78h, 3Bh, 6Eh, 2Fh, 72h
                db      0D5h, 1Ah, 0F4h, 0A0h, 0D9h, 36h
                db      0B5h, 0D2h, 19h, 5Ch, 0Dh, 6Bh
                db      0EDh, 0B8h, 20h, 0D2h, 7Ch, 0B9h
                db      0Dh, 7Ah, 0ABh, 5, 49h, 0CCh
                db      4Ch, 0F4h, 0F5h, 78h, 3Bh, 6Eh
                db      2Fh, 83h, 12h, 0DDh, 33h, 0D8h
                db      41h, 31h, 0, 0D8h, 0E7h, 0D8h
                db      11h, 14h, 26h, 0ADh, 0DAh, 0E2h
                db      39h, 8Fh, 35h, 0F1h, 0BFh, 33h
                db      0CCh, 7Bh, 0F5h, 0F7h, 4Fh, 0F3h
                db      0EDh, 22h, 0CCh, 0A0h, 0D6h, 3Eh
                db      0C0h, 0D2h, 11h, 55h, 4, 1Fh
                db      0Ah, 83h, 1Dh, 82h, 21h, 6Ah
                db      45h, 0F0h, 0F5h, 3Bh, 15h, 9Ah
                db      79h, 6Bh, 0FDh, 72h, 34h, 2Ah
                db      0F1h, 3Fh, 89h, 0, 13h, 5Fh
                db      0E1h, 62h, 7Ah, 3Ch, 9Eh, 53h
                db      0Fh, 88h, 98h, 23h, 0B9h, 5Eh
                db      0CCh, 0DCh, 3Ch, 3Fh, 0Bh, 80h
                db      0A3h, 3, 31h, 3Eh, 0D4h, 0D7h
                db      0F4h, 3Bh, 3Dh, 0B0h, 0ABh, 1Fh
                db      21h, 34h, 17h, 28h, 0D5h, 1Fh
                db      0F9h, 0FEh, 18h, 0D7h, 19h, 1Bh
                db      90h, 95h, 5, 23h, 6Ah, 0FDh
                db      71h, 0F0h, 0F5h, 0AAh, 31h, 0FFh
                db      7Ch, 32h, 0D2h, 0F6h, 7Ch, 7Fh
                db      0ECh, 0EFh, 21h, 83h, 6Dh, 0EDh
                db      15h, 98h, 5Bh, 0EFh, 0D1h, 2Dh
                db      0A2h, 51h, 0FFh, 9Ah, 69h, 0EBh
                db      0EDh, 3Fh, 1Ch, 95h, 0Bh, 3Fh
                db      0FEh, 7Dh, 12h, 2Eh, 0F6h, 3Bh
                db      25h, 0A8h, 33h, 6Eh, 2Eh, 0F4h
                db      0D5h, 10h, 93h, 35h, 0DAh, 0DFh
                db      35h, 0C7h, 0D4h, 5Eh, 0ABh, 3Dh
                db      6Ch, 2Ch, 0FDh, 0F3h, 39h, 0D1h
                db      14h, 0B5h, 1Bh, 7Ch, 0FDh, 3Fh
                db      0B9h, 53h, 0F4h, 0F2h, 6Ch, 2Ch
                db      0FDh, 93h, 59h, 20h, 0CAh, 6Bh
                db      9Dh, 26h, 9Fh, 93h, 1Eh, 0E1h
                db      79h, 5Fh, 17h, 94h, 2Bh, 0D6h
                db      0F5h, 4, 51h, 78h, 0BBh, 11h
                db      0D6h, 34h, 0BAh, 5Dh, 7Eh, 0BDh
                db      1, 6Eh, 4, 65h, 0D6h, 0ECh
                db      1Ah, 0A7h, 0D4h, 65h, 0DDh, 0D3h
                db      3Dh, 61h, 0D5h, 38h, 0, 23h
                db      66h, 85h, 19h, 0A1h, 7Eh, 0Dh
                db      31h, 5Eh, 0E5h, 0CAh, 0F5h, 76h
                db      33h, 0A4h, 0EDh, 23h, 0D1h, 0AEh
                db      0D3h, 18h, 16h, 99h, 0CBh, 0EDh
                db      0B8h, 4Ch, 4Fh, 0FEh, 86h, 12h
                db      0E9h, 0E9h, 0EDh, 0A3h, 0Ah, 15h
                db      39h, 1Ah, 66h, 0DCh, 0C0h, 1Fh
                db      0F1h, 3Bh, 96h, 0E5h, 0F1h, 57h
                db      0EDh, 91h, 6Ch, 0D7h, 0D5h, 69h
                db      0DDh, 0DFh, 10h, 0F2h, 0A7h, 0D8h
                db      61h, 93h, 54h, 0ECh, 0EDh, 3Fh
                db      21h, 0A8h, 23h, 72h, 3Fh, 6Ch
                db      0FDh, 3Eh, 0D4h, 7Ch, 0A3h, 9
                db      66h, 0A1h, 15h, 12h, 74h, 77h
                db      6Ah, 12h, 54h, 80h, 9Dh, 2Bh
                db      94h, 0C0h, 58h, 0B2h, 59h, 0D1h
                db      20h, 0D2h, 4Dh, 0F6h, 0B6h, 78h
                db      0B3h, 9, 76h, 25h, 74h, 35h
                db      54h, 0F3h, 20h, 0CEh, 0F3h, 58h
                db      83h, 2Bh, 5Bh, 8Dh, 23h, 6Bh
                db      0C7h, 1Eh, 0F4h, 0C8h, 8Ch, 0E0h
                db      2Dh, 0DCh, 36h, 0C0h, 27h, 0C4h
                db      3, 78h, 18h, 40h, 0FDh, 0F2h
                db      0A2h, 1Fh, 5Bh, 0F3h, 2Eh, 64h
                db      0A3h, 0E3h, 94h, 0E6h, 29h, 92h
                db      9Ch, 0DEh, 55h, 81h, 0C4h, 0DEh
                db      0C4h, 0DAh, 3Ch, 26h, 64h, 0BDh
                db      5, 76h, 14h, 0F4h, 0FDh, 0AEh
                db      0BCh, 0C0h, 35h, 0Eh, 26h, 23h
                db      0B4h, 2Ch, 0B5h, 83h, 16h, 3Fh
                db      0Ch, 2Ch, 58h, 0Fh, 0A8h, 2Ah
                db      0DEh, 7, 5Eh, 12h
loc_1:
                cmp     al,0Fh
                mov     bp,7E24h
                aas                             ; Ascii adjust
                lodsw                           ; String [si] to ax
                mov     bl,2Ah                  ; '*'
                cld                             ; Clear direction
                mov     bx,7E1Fh
                pop     es
                push    es
                push    di
                db      2Eh, 55h, 0EDh, 93h, 7Dh, 49h
                db      6Ah, 18h, 5Fh, 0BCh, 0DBh, 75h
                db      0AEh, 0D1h, 73h, 0E6h, 1Eh, 2Ch
                db      0BEh, 78h, 29h, 0A7h, 0A3h
                db      78h

locloop_2:
                mov     bh,ch
                add     dh,ds:data_2e[si]       ; (7415:7EF7=0)
                adc     word ptr [bx],41h
                esc     7,cl                    ; coprocessor escape
                pop     cx
                xchg    ax,dx
                rcr     cl,1                    ; Rotate thru carry
                rcl     byte ptr [di-68h],cl    ; Rotate thru carry
                esc     2,ds:data_3e[di]        ; (7415:8C8D=0) coprocessor escape
                sbb     al,ds:data_1e[bx+si]    ; (7415:3366=0)
loc_3:
                mov     bp,7EA5h
                adc     word ptr [bx+di],0CD5Fh
                sti                             ; Enable interrupts
                ja      loc_1                   ; Jump if above
                db      0F2h, 0D3h, 0Bh, 7Bh, 0AAh, 0E8h
                db      0B3h
                db      4Bh, 4Dh
loc_5:
                esc     3,[bp+si+4E0Eh]         ; coprocessor escape
                movsb                           ; Mov [si] to es:[di]
                push    ds
                adc     [bp+0Bh],al
                popf                            ; Pop flags
                push    si
                add     al,dl
                db      6Fh, 0F3h, 0Fh, 54h, 0F9h, 0F3h
                db      76h, 0B9h, 11h, 0DEh, 90h, 0F7h
                db      56h, 0F7h, 0EDh
loc_6:
                loopz   locloop_2               ; Loop if zf=1, cx>0

;*              jo      loc_4                   ;*Jump if overflow=1
                db      70h, 0D3h
                xlat [bx]                       ; al=[al+[bx]] table
                jbe     loc_5                   ; Jump if below or =
                esc     5,[si]                  ; coprocessor escape
                test    cx,sp
                dec     ax
                adc     al,49h                  ; 'I'
                int     0BDh
                push    di
                in      ax,dx                   ; port 0, DMA-1 bas&add ch 0
                rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
                call    $-4A7Fh
                sbb     ax,5E05h
                push    bp
                jl      loc_3                   ; Jump if <
                das                             ; Decimal adjust
                dec     si
;*              jmp     short loc_7             ;*(04BD)
                db      0EBh, 0EDh
                db      18h, 0D3h, 49h, 36h, 95h, 9Dh
                db      14h, 0DBh, 71h, 36h, 99h, 95h
                db      68h, 0B5h, 0F0h, 70h, 30h, 4Ah
                db      0DCh, 0F4h, 4Bh, 66h, 0E5h, 44h
                db      82h, 0F0h, 0Fh, 9, 0B5h, 0A6h
                db      7Fh, 0DCh, 0D6h, 0E4h, 0DAh, 0E6h
                db      2, 0EEh, 6, 0F6h, 0Bh, 0FEh
                db      0Eh, 0FEh
                db      9
loc_8:
                jge     loc_6                   ; Jump if > or =
                stosb                           ; Store al to es:[di]
                mov     al,0B3h
                mov     ch,0Dh
                mov     ax,1D6Dh
                sbb     dh,al
                cmc                             ; Complement carry
                hlt                             ; Halt processor
                div     al                      ; al, ah rem = ax/reg
                jmp     short loc_8             ; (04FD)
                db      0E4h, 12h, 1Fh, 16h, 1Eh, 12h
                db      11h, 1Eh, 10h, 11h, 1Bh, 15h
                db      5, 11h, 0FFh, 0EDh, 0F9h, 0F1h
                db      0E3h, 0F5h, 0EDh, 0F1h, 0E7h, 0FEh
                db      0E1h, 0F2h, 0E8h, 0F6h, 0EBh, 0F2h
                db      0F2h, 0EEh, 0CDh, 0D2h, 0F4h, 0D6h
                db      0F7h, 0D2h, 0FEh, 0DEh, 0F9h, 58h
                db      9Bh, 3Fh, 5Eh, 95h, 7, 64h
                db      13h, 72h, 1Ah, 41h, 0F6h, 1Bh
                db      0DCh, 0FFh, 49h, 0B3h, 4Ch, 1Bh
                db      0F1h, 78h, 3Bh, 6Eh, 7, 4Eh
                db      96h, 5Ah, 0B4h, 0Fh, 0CDh, 14h
                db      0D3h, 7Bh, 1Eh, 0D1h, 7Fh, 18h
                db      13h, 6Eh, 2, 45h, 0F6h, 1Fh
                db      0F6h, 0F3h, 0A5h, 62h, 3Eh, 0C2h
                db      0F0h, 0C6h, 0F8h, 0B3h, 0AAh, 0Dh
                db      15h, 10h, 61h, 0D7h, 18h, 3Ah
                db      0DCh, 0DFh, 0F7h, 0FDh, 96h, 98h
                db      98h, 0D3h, 0BDh, 0AEh, 0B9h, 0BBh
                db      0C8h, 0B6h, 0B2h, 0B2h, 0AFh, 0D1h
                db      0BEh, 0BCh, 0B8h, 0F7h, 0F5h, 0BEh
                db      0EDh, 0EFh, 0EDh, 13h, 14h, 16h
                db      14h, 12h, 1Ch, 1Eh, 1Ch, 12h
                db      14h, 16h, 14h, 12h, 0ECh, 0EFh
                db      0EDh, 0F3h, 0F5h, 0F7h, 0F5h, 0F3h
                db      0FDh, 0FFh, 0FDh, 0F3h, 0F5h, 0F7h
                db      0F5h, 0F3h, 0EDh, 0EFh, 0EDh, 0D3h
                db      0D5h, 0D7h, 0D5h, 0D3h, 0DDh, 0DFh
                db      0DDh, 0D3h, 0D5h, 0D7h, 0D5h, 0D3h
                db      0EDh, 0EFh, 0EDh, 0F3h, 0F5h, 0F4h
                db      0CAh, 0CCh, 0C2h, 0C0h, 0C2h, 0CCh
                db      0CAh, 0C8h, 0B6h, 0BCh, 0A0h, 0ECh
                db      0E3h, 93h, 95h, 97h, 29h, 5Fh
                db      0B6h, 9Fh, 0BDh, 58h, 0Fh, 0Dh
                db      81h, 97h, 0EDh, 0EFh, 0EDh, 0B2h
                db      0B2h, 0B6h, 0A7h, 0DDh, 0BEh, 0B0h
                db      0B0h, 0F3h, 0F5h, 0BAh, 0F5h, 0F3h
                db      0EDh, 0EFh, 0EDh

twelve          endp

seg_a           ends



                end     start
