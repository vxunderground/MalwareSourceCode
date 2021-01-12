; Boot Record Program (C) Copyright Peter Norton 1986
; From PC Magazine ca. January 1986

boots segment 'code'

      public boot

      assume cs:boots

boot  proc   far

;  30-byte DOS info -- set up for 2-sides, 9-sector
;  change as needed for any other format

head:
      jmp    begin      ; EB 2A 90 as per normal
      db     ' DE 1.0 ' ; 8-byte system id
      dw     512        ; sector size in bytes
      db     2          ; sectors per cluster
      dw     1          ; reserved clusters
      db     2          ; number of fats
      dw     112        ; root directory entries
      dw     760        ; total sectors
      db     0FDh       ; format id
      dw     2          ; sectors per fat
      dw     9          ; sectors per track
      dw     2          ; sides
      dw     0          ; special hidden sectors

; mysterious but apparently standard 14-byte filler
      db     14 dup (0)

; carry on with the boot work

begin:
      mov    ax,07C0h   ; boot record location
      push   ax
      pop    ds
      mov    bx,message_offset  ; put offset to message into si
      mov    cx,message_length  ; message length from cx
continue:
      mov    ah,14      ; write teletype
      mov    al,[bx]
      push   ds
      push   cx
      push   bx
      int    10h
      pop    bx
      pop    cx
      pop    ds
      inc    bx
      loop   continue

      mov    ah,0       ; read next keyboard character
      int    16h

      mov    ah,15      ; get video mode
      int    10h
      mov    ah,0       ; set video mode (clears screen)
      int    10h

      int    19h        ; re-boot

beg_message:
      db     0Dh,0Ah    ; carriage return, line-feed
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     '     Start your computer with'
      db     0Dh,0Ah
      db     '     a DOS system diskette.'
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     '     This is'
      db     0Dh,0Ah
      db     '        The Norton Utilities'
      db     0Dh,0Ah
      db     '            Version 3.0'
      db     0Dh,0Ah
      db     '     from'
      db     0Dh,0Ah
      db     '         Peter Norton'
      db     0Dh,0Ah
      db     '         2210 Wilshire Blvd'
      db     0Dh,0Ah
      db     '         Santa Monica, CA 90403'
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     '           (213) 826-8092'
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     0Dh,0Ah
      db     '    Insert a DOS diskette'
      db     0Dh,0Ah
      db     '    Press any key to start DOS ... '
end_message:

; I put a copyright notice here; you do if you want to ...
tail:

message_offset equ beg_message - head
message_length equ end_message - beg_message
filler_amount  equ 512 - (tail - head) - 2

      db     filler_amount dup (0)      ; filler

      db     055h,0AAh                  ; boot id

boot  endp

boots ends

      end
