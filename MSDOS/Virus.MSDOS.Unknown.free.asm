          title  FREE.ASM
          page,132

cseg      segment para 'code'
          assume cs:cseg
main      proc   far
          org    100h
start:
          jmp    begin

banner    db     0ah,'FREE Vers 1.0 - Sept. 1985 - by Art Merrill',0dh,0ah,'$'
          db     'Copyright (C) 1985',0dh,0ah,'$'
          db     'Ziff-Davis Publishing Company',0dh,0ah,'$'
total:    db     0ah,8 dup(0),' bytes total disk space',0dh,0ah
diff:     db     8 dup(0),' bytes allocated',0dh,0ah
bytes:    db     8 dup(0),' bytes available on disk',0dh,0ah,0ah,'$'
hltotal:  dw     0,0
hlbytes:  dw     0,0

begin:
          mov    dx,offset banner
          mov    ah,9
          int    21h

          mov    si,5ch                ;address of selected drive
          mov    dl,[si]
          mov    ah,36h                ;get disk free space
          int    21h

          push   ax                    ;save for total bytes
          push   cx                    ;save for total bytes
          push   dx                    ;save for total bytes

          mul    bx                    ;get total clusters
          mul    cx                    ;get total bytes

          std
          mov    di,offset hlbytes+2
          xchg   ax,dx
          stosw
          xchg   ax,dx
          stosw

          mov    di,offset bytes+7     ;storage for ascii printout
          call   ascii

          pop    dx                    ;get back total clusters
          pop    cx                    ;get back bytes per sector
          pop    ax                    ;get back sectors per cluster

          mul    dx                    ;total clusters
          mul    cx                    ;bytes per sector

          mov    di,offset hltotal+2   ;same routine as above to get
          xchg   ax,dx                 ;  total bytes
          stosw
          xchg   ax,dx
          stosw

          mov    di,offset total+8     ;storage for ascii printout
          call   ascii

          mov    ax,word ptr hltotal+2 ;calculate difference between
          sub    ax,word ptr hlbytes+2 ;  total bytes and bytes allocated
          xchg   ax,dx                 ;  to get total bytes remaining
          mov    ax,word ptr hltotal
          sub    ax,word ptr hlbytes
          jnc    skip
          dec    dx                    ;adjust total for carry
skip:
          mov    di,offset diff+7      ;storage for ascii printout
          call   ascii

          mov    dx,offset total       ;print results
          mov    ah,9
          int    21h

          int    20h                   ;exit

main      endp

ascii     proc   near
          xchg   bp,dx                 ;save high word
          mov    bx,0ah                ;divisor
          mov    cl,30h                ;conversion for ascii
rpt1:
          cmp    bp,0                  ;are we done with high words
          jz     rpt2                  ;yes
          xchg   ax,bp                 ;no-get high word
          xor    dx,dx                 ;clear dx
          div    bx
          xchg   bp,ax                 ;this will be the new high word
          div    bx                    ;divide low word + remainder
          or     dl,cl                 ;convert hex value to ascii
          mov    [di],dl               ;quotient into storage
          dec    di                    ;step back one byte
          jmp    rpt1                  ;go again
rpt2:
          xor    dx,dx                 ;clear dx
          div    bx
          or     dl,cl                 ;convert hex value to ascii
          mov    [di],dl               ;quotient into storage
          dec    di                    ;step back one byte
          cmp    ax,0                  ;are we done?
          jnz    rpt2                  ;no

          ret                          ;yes
ascii     endp

cseg      ends
          end    start
