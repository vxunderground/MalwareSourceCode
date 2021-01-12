;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                   Black Wolf's File Protection Utilities 2.1s
;
;PassCOM - This program password protects the specified file by attaching
;          code from PW_COM onto the file so that it will check for passwords
;          each execution.  It utilizes ULTIMUTE .93á to protect then PW_COM
;          code from easy manipulation.
;
;LISCENSE:
;    Released As Freeware - These files may be distributed freely.
;
;Any modifications made to this program should be listed below the solid line,
;along with the name of the programmer and the date the file was changed.
;Also - they should be commented where changed.
;
;NOTE THAT MODIFICATION PRIVILEDGES APPLY ONLY TO THIS VERSION (2.1s)!  
;I'd appreciate notification of any modifications if at all possible, 
;reach me through the address listed in the documentation file (bwfpu21s.doc).
;
;DISCLAIMER:  The author takes ABSOLUTELY NO RESPONSIBILITY for any damages
;resulting from the use/misuse of this program/file.  The user agrees to hold
;the author harmless for any consequences that may occur directly or 
;indirectly from the use of this program by utilizing this program/file
;in any manner.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Modifications:
;       None as of 08/05/93 - Initial Release.

.model tiny
.radix 16
.code
       
       org 100

        extrn   _ULTMUTE:near, _END_ULTMUTE:byte

start:
        call    GetFilename
        call    Get_Passes
        call    EncryptGP
        call    Do_File
        mov     ax,4c00
        int     21
;---------------------------------------------------------------------------
GetFilename:
        mov     ah,09
        mov     dx,offset Message
        int     21

        mov     dx,offset Filename_Data
        mov     al,60
        call    gets
        ret
;---------------------------------------------------------------------------
Get_Passes:
    Clear_Out_Passes:        
        mov     di,offset Entered_Pass
        mov     cx,0ch                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb
        mov     di,offset Password
        mov     cx,0ch                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb
        
        mov     ah,09
        mov     dx,offset Req_Pass
        int     21

        mov     di,offset Entered_Pass
        mov     cx,0ch
        call    GetPass

        mov     ah,09
        mov     dx, offset Dup_Pass
        int     21

        mov     di,offset Password
        mov     cx,0ch
        call    GetPass
        
        call    Check_Passwords
        jc      Get_Passes
        
        mov     di,offset Entered_Pass
        mov     cx,0dh                   ;Clear out entered pass.
        xor     ax,ax
        repnz   stosb

Randomize_Keys:
        push    ds
        xor     ax,ax
        mov     ds,ax
        mov     ax,word ptr ds:[46c]    ;Randomizes encryption
        pop     ds
        mov     word ptr [Key1],ax
        xor     ax,1f3eh
        ror     ax,1
        mov     word ptr [Key2],ax
        


Encrypt_Password:                       ;This algorithm needs extra work...
        mov     bx,word ptr [Key1]
        mov     dx,word ptr [Key2]      ;Encrypt the password
        mov     si,offset Password
        mov     di,si
        mov     cx,6
  EncryptIt:      
        lodsw
        xor     ax,bx
        add     bx,dx
        stosw
        loop    EncryptIt
        ret
;---------------------------------------------------------------------------
Message:
        db      'PassCOM 2.0 (c) 1993 Black Wolf Enterprises.',0a,0dh
        db      'Enter Filename To Protect -> $'
;---------------------------------------------------------------------------
Req_Pass        db      0a,0dh,'Now Enter Password (up to 12 chars): $'
Dup_Pass        db      0a,0dh,'Re-Enter Password: $'
Passes_Not      db      0a,0dh,'Passwords do not match.  Try again.',0a,0dh,24
;---------------------------------------------------------------------------
Check_Passwords:
        mov     si,offset Entered_Pass
        mov     di,offset Password
        mov     cx,0c
        repz    cmpsb
        jcxz    Password_Good
        stc
        ret
Password_Good:
        clc
        ret
;---------------------------------------------------------------------------


gets:                   ;get string
        mov     ah,0a
        push    bx
        mov     bx,dx
        mov     byte ptr ds:[bx],al
        mov     byte ptr ds:[bx+1],0
        pop     bx
        int     21
        push    bx
        mov     bx,dx
        mov     al,byte ptr ds:[bx+1]
        xor     ah,ah
        add     bx,ax
        mov     byte ptr ds:[bx+2],0
        pop     bx
        ret
;---------------------------------------------------------------------------
GetPass:
  KeyHit_Loop:          ;Load in password
        push    cx
        sub     ax,ax
        int     16
        cmp     al,0dh
        je      HitReturn
        stosb
        pop     cx
        loop    KeyHit_Loop
        ret
  HitReturn:
        pop     cx
        xor     al,al
        repnz   stosb
        ret        


;---------------------------------------------------------------------------
Time    dw      0
Date    dw      0

GetTime:
        mov     ax,5700 ;Get file date/time from handle BX
        int     21
        mov     word ptr cs:[Time],cx
        mov     word ptr cs:[Date],dx
        ret

SetTime:                ;Set file date/time for handle BX
        mov     ax,5701
        mov     cx,word ptr cs:[Time]
        mov     dx,word ptr cs:[Date]
        int     21
        ret

Do_File:        
        mov     ax,3d02
        mov     dx,offset Filename
        int     21                      ;Open file read/write
        jc      Terminate
        xchg    bx,ax

        call    GetTime                 ;Get file date/time
        call    BackupFile              ;make a copy....
        
        mov     ah,3f
        mov     cx,4
        mov     dx,offset Storage_Bytes ;Read in first four bytes for jump
        int     21

        mov     ax,4202
        xor     cx,cx
        xor     dx,dx                   ;go to the end of the file
        int     21

        sub     ax,3
        mov     word ptr [JumpBytes+1],ax ;Save Jump size
        
        push    bx        
        mov     si,offset begin_password        ;On Entry -> CS=DS=ES
        mov     di,offset _END_ULTMUTE          ;SI=Source, DI=Destination
        mov     bx,ax                           ;BX=Next Entry Point
        add     bx,103
        mov     cx,end_password-begin_password+1 ;CX=Size to Encrypt
        mov     ax,1                             ;AX=Calling Style
        
        call    _ULTMUTE                        ;Encrypt Code
                                                
                                                ;On Return -> CX=New Size
        pop     bx
        
        mov     dx,offset _END_ULTMUTE
        mov     ah,40                           ;Write encrypted code and
        int     21                              ;decryptor to end of file
        
        mov     ax,4200
        xor     dx,dx                           ;Go back to beginning of file
        xor     cx,cx
        int     21
        
        mov     ah,40
        mov     cx,4
        mov     dx,offset JumpBytes             ;Write in jump to decryptor
        int     21
        
        call    SetTime                         ;Restore file date/time

        mov     ah,3e
        int     21                              ;close file
        ret

Terminate:
        mov     ah,09
        mov     dx,offset BadFile
        int     21
        ret
BadFile db      'Error Opening File.',07,0dh,0a,24

JumpBytes       db      0e9,0,0,'á'

EncryptGP:                              ;Encrypt GoodPass routine in pw_com
        xor     ax,ax                   ;with value from password itself...
        mov     cx,0c
        mov     si,offset Password

GetValue:        
        lodsb
        add     ah,al
        ror     ah,1                    ;Get value to use for encrypt...
        loop    GetValue

        mov     si,offset Goodpass
        mov     cx,EndGoodPass-GoodPass
       
Decrypt_Restore:                ;This needs improvement....
        mov     al,[si]
        xor     al,ah
        mov     [si],al
        inc     si
        loop    Decrypt_Restore
        ret        

BackupFile:                             ;Create copy of file...
        mov     si,offset Filename
        mov     cx,80

  Find_Eofn:
        lodsb
        cmp     al,'.'          ;Find file extension
        je      FoundDot
        or      al,al
        jz      FoundZero
        loop    Find_Eofn
        jmp     Terminate
FoundZero:
        mov     byte ptr [si-1],'.'
        inc     si
FoundDot:
        mov     word ptr [si],'LO'
        mov     byte ptr [si+2],'D'     ;Change extension to 'OLD'
        mov     byte ptr [si+3],0

        
        mov     dx,offset Filename
        mov     word ptr [SourceF],bx
        mov     ah,3c
        xor     cx,cx
        int     21
        jnc     GCreate
         jmp    Terminate
GCreate:
        mov     word ptr cs:[Destf],ax
BackLoop:
        mov     ah,3f
        mov     bx,word ptr cs:[Sourcef]
        mov     cx,400
        mov     dx,offset FileBuffer            ;Copy file to backup
        int     21

        mov     cx,ax
        mov     ah,40
        mov     bx,word ptr cs:[Destf]
        mov     dx,offset Filebuffer
        int     21

        cmp     ax,400
        je      BackLoop
DoneBack:
        mov     bx,word ptr cs:[Destf]
        call    SetTime                 ;Save original date/time stamp in 
                                        ;backup
        mov     ah,3e
        mov     bx,word ptr cs:[Destf]
        int     21                      ;Close file

        mov     ax,4200
        xor     cx,cx
        xor     dx,dx
        mov     bx,word ptr cs:[Sourcef] ;Go back to the beginning of the
        int     21                       ;source file
        ret

SourceF dw      0
DestF   dw      0

        ;This is code from PW_COM compiled converted to data bytes..
        ;If you modify PW_COM, you must compile it and convert it, then
        ;place it here.  Note that the byte 0ffh marks the beginning and
        ;end of Goodpass for simplicity....

begin_password: 
db 0e8h, 02dh, 01h, 02eh, 0c6h, 086h, 09h, 01h, 0eah, 0ebh
db 06h, 00h, 0ebh, 011h, 090h, 0adh, 0deh, 0bbh, 021h, 01h
db 03h, 0ddh, 053h, 02eh, 0c6h, 086h, 011h, 01h, 0c3h, 0ebh
db 0edh, 0ebh, 0f0h, 0fah, 050h, 01eh, 033h, 0c0h, 08eh, 0d8h
db 08dh, 086h, 01ch, 02h, 087h, 06h, 00h, 00h, 050h, 08ch
db 0c8h, 087h, 06h, 02h, 00h, 050h, 01eh, 0eh, 01fh, 02eh
db 0c7h, 086h, 044h, 01h, 090h, 090h, 033h, 0c9h, 0f7h, 0f1h
db 01fh, 058h, 087h, 06h, 02h, 00h, 058h, 087h, 06h, 00h
db 00h, 01fh, 058h, 0fbh, 0e8h, 0aah, 00h, 02eh, 080h, 086h
db 05eh, 01h, 010h, 0ebh, 03h, 090h, 0eah, 09ah, 0e8h, 081h
db 00h, 0e8h, 069h, 00h, 072h, 038h, 033h, 0c0h, 0b9h, 0ch
db 00h, 08dh, 0b6h, 04eh, 02h, 0ach, 02h, 0e0h, 0d0h, 0cch
db 0e2h, 0f9h, 08dh, 0b6h, 090h, 01h, 0b9h, 011h, 00h, 08ah
db 04h, 032h, 0c4h, 088h, 04h, 046h, 0e2h, 0f7h, 0e8h, 039h
db 00h, 0ebh, 01h, 0ffh 

GoodPass:
db 0bfh, 00h, 01h, 057h, 08dh, 0b6h
db 03eh, 02h, 0a5h, 0a5h, 033h, 0c0h, 08bh, 0f0h, 08bh, 0f8h
db 0c3h 
EndGoodPass:

db 0ffh, 0b4h, 09h, 08dh, 096h, 0afh, 01h, 0cdh, 021h
db 0b8h, 01h, 04ch, 0cdh, 021h, 0ah, 0dh, 050h, 061h, 073h
db 073h, 077h, 06fh, 072h, 064h, 020h, 049h, 06eh, 063h, 06fh
db 072h, 072h, 065h, 063h, 074h, 02eh, 07h, 024h, 090h, 0ebh
db 05h, 090h, 0eah, 0f8h, 0c3h, 09ah, 0fch, 0ebh, 0fah, 08dh
db 0b6h, 04eh, 02h, 08dh, 0beh, 042h, 02h, 0b9h, 0ch, 00h
db 0f3h, 0a6h, 0e3h, 03h, 0f9h, 0c3h, 0e9h, 0f8h, 0c3h, 00h
db 08bh, 09eh, 03ah, 02h, 08bh, 096h, 03ch, 02h, 08dh, 0b6h
db 04eh, 02h, 08bh, 0feh, 0b9h, 06h, 00h, 0adh, 033h, 0c3h
db 03h, 0dah, 0abh, 0e2h, 0f8h, 0c3h, 0eah, 0b9h, 0ch, 00h
db 08dh, 0beh, 04eh, 02h, 051h, 02bh, 0c0h, 0cdh, 016h, 03ch
db 0dh, 074h, 05h, 0aah, 059h, 0e2h, 0f3h, 0c3h, 059h, 032h
db 0c0h, 0f2h, 0aah, 0c3h, 0b4h, 09h, 08dh, 096h, 025h, 02h
db 0cdh, 021h, 0cfh, 050h, 061h, 073h, 073h, 077h, 06fh, 072h
db 064h, 02dh, 03eh, 024h, 05dh, 0ebh, 01h, 0eah, 055h, 081h
db 0edh, 03h, 01h, 0c3h
;------------------------------------------------------------------------
Key1            dw      0
Key2            dw      0
;------------------------------------------------------------------------
Storage_Bytes   db      90,90,0cdh,20
;------------------------------------------------------------------------
Password        db      'Greetings to'
Entered_Pass    db      'everyone!   '
db      0,0,0,0,0,0,0
end_password:
                dw      0
                dw      0
Filename_data   dw      0
Filename        db      80 dup(0)       ;These are stored as zeros to 
FileBuffer      db      400 dup(0)      ;keep from overwriting ultimute...
end start
