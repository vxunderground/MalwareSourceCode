;
; InVircible Signature File Scanner for v6.02, (c)1995 ûirogen [NuKE]
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Zvi changed his signature files a little in v6.02; although all the
; documentation says that he changed it in v6.01d, I never noticed a change
; until this new version. Anywayz, what he did was simply change his little
; verification word to one that my previous algorithm would think was a false
; positive. Namely 'MZ', 'PK', and 60EAh (which corresponds to EXE headers,
; PKZIP archives, and ARJ archives, respectively). So, since we can't just
; look at the first word of the file, else we'll have many false positives,
; we simply check the next record (42h bytes) for a valid signature. If both
; records contain a valid signature then it's almost definatly an invircible
; signature file.
;
; This utility is an example of how to detect InVircible signature files.
; It skips files larger than 16896 bytes, as it's unlikely that a signature
; file will contain more than 256 different entries and the speed increase
; is definatly of worth in a virus. To use, just run it and it'll scan all
; files in the current directory for InVircible signatures.
;
;

segment cseg
        assume  cs: cseg, ds: cseg, es: cseg, ss: cseg

max_size equ 256*66                    ; maximum size of file to scan
lf       equ 0ah
cr       equ 0dh

org     100h
start:
        lea     dx,vanity              ; credz..
        call    disp
        mov     ah,1ah
        lea     dx,ff_info
        int     21h                    ; set DTA
        xor     bp,bp
        xor     cx,cx
        lea     dx,filespec
        mov     ah,4eh
        int     21h                    ; find first
        jnc     find_loop
        jmp     exit
find_loop:
        inc     bp                     ; bp is our counter
        lea     dx,msg1                ; display 'Testing:'
        call    disp
        lea     dx,f_name
        push    dx
        call    disp                   ; display file name
        mov     ax,3d00h               ; open file
        pop     dx
        int     21h
        jnc     no_error
        lea     dx,error
        call    disp
        jmp     not_iv
no_error:
        xchg    ax,bx                  ; get handle
        xor     cx,cx
        xor     dx,dx
        mov     ax,4202h
        int     21h                    ; get file size
        cmp     dx,0
        jnz     close
        cmp     ax,max_size            ; file too big?
        jae     close
        xor     cx,cx
        xor     dx,dx
        mov     ax,4200h
        int     21h                    ; reset file pointer
        mov     ah,3fh                 ; read first 44h bytes
        mov     cx,44h
        lea     dx,buf
        int     21h
        cmp     ax,44h                 ; was there only one record?
        jz      close
        mov     ax,word ptr buf        ; if so simulate second record
        mov     word ptr buf[42h],ax
close:
        mov     ah,3eh                 ; close
        int     21h
        lea     di,buf
        call    chk_iv
        jnz     not_iv
        lea     di,buf[42h]
        call    chk_iv
        jnz     not_iv
        lea     dx,is_iv               ; display affirmatice
        call    disp
not_iv:
        mov     ah,4fh                 ; find next
        int     21h
        jc      exit
        jmp     find_loop

exit:
        cmp     bp,0                   ; find any files?
        jnz     some_done
        lea     dx,no_files            ; if not, display a msg
        call    disp
some_done:
        lea     dx,done
        call    disp
        ret

chk_iv:
        cmp     word ptr [di],0EA60h   ; check record
        jz      yea_iv
        cmp     word ptr [di],'KP'
        jz      yea_iv
        cmp     word ptr [di],'ZM'
yea_iv:
        ret

disp:                                  ; displays null terminated string via
        mov     cx,0ffh                ; DOS
        mov     di,dx
        xor     ax,ax
        repnz   scasb                  ; search for null
        dec     di
        push    di
        mov     byte ptr [di],'$'      ; replace with '$'
        mov     ah,9
        int     21h
        pop     di
        mov     byte ptr [di],0        ; reset null
        ret

vanity  db      cr,lf,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
        db      cr,lf,' InVircible v6.02 Signature File Detector, (c)1995 ûirogen [NuKE]'
        db      cr,lf,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',cr,lf,0
msg1    db      cr,lf,'Testing File: ',0
no_files db     cr,lf,' No files found!',cr,lf,0
is_iv   db      cr,lf,' ş Is an Invircible Signature File!',0
error   db      cr,lf,' ş Error Opening! Is this file in the current dir?',0
done    db      cr,lf,cr,lf,' Scan Complete.',cr,lf,0
filespec db     '*.*',0
ff_info db      30 dup(0)
f_name  db      13 dup(0)
buf     db      44h dup(0)
cseg    ends
        end     start
