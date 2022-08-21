;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;      The ULTImate MUTation Engine .93á (c) 1993 Black Wolf Enterprises
;               pardon the title, had to think of something... }-)
;
;ULTIMUTE is a mutation engine written for security-type applications and 
;other areas where mutation of executable code is necessary.  For my personal
;use, I have implemented it in Black Wolf's File Protection Utilities 2.1s,
;using it to encrypt the code placed onto EXE's and COM's to protect them
;from simple modification and/or unauthorized use.  The encryption algorithms
;themselves are terribly simple - the main point being that they change
;each time and are difficult to trace through.  This engine is written mainly
;to keep a "hack one, hack 'em all" approach from working on protected code,
;rather than to keep the code secure by a cryptologist's point of view.
;
;Including: Better Anti-Tracing abilities, 1017 byte size, Anti-Disassembling
;           code, largely variable size for decoder.  Also includes variable
;           calling segmentation (i.e. CS<>ES<>DS, and can be called via
;           near call, far call, or interrupt, the last of which can be
;           useful as a memory-resident handler for multiple programs to
;           use).
;
;Note: Please - this program and it's source have been released as freeware,
;      but do NOT use the mutation engine in viruses!  For one thing, the
;      decryptor sequence has several repetitive sequences that can be scanned
;      for, and for another, that just isn't what it was designed for and
;      I would NOT appreciate it.  If you MUST use someone else's mutation
;      engine for such, use the TPE or MTE.  I do NOT condone such, however.
;
;Any modifications made to this program should be listed below the solid line,
;along with the name of the programmer and the date the file was changed.
;Also - they should be commented where changed.  If at all possible, report
;modifications to file to the address listed in the documentation.
;
;DISCLAIMER:  The author takes ABSOLUTELY NO RESPONSIBILITY for any damages
;resulting from the use/misuse of this program.  The user agrees to hold
;the author harmless for any consequences that may occur directly or 
;indirectly from the use of this program by utilizing this program/file
;in any manner.  Please use the engine with care.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Modifications:
;       None as of yet (original release version)

.model tiny
.radix 16
.code

        public  _ULTMUTE, _END_ULTMUTE, Get_Rand, Init_Rand

;Underscores are used so that these routines can be called from C and other
;upper level languages.  If you wish to use Get_Rand and Init_Rand in C, you
;need to add underscores in their names as well.  Also, the random number
;generations may not be sound for all purposes.  They do the job for this
;program, but they may/may not be mathematically correct.

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ENTRY:
;       CX=Code Length          BX=New_Entry_Point
;       DS:SI=Code              AX=Calling Style
;       ES:DI=Destination               1=Near Call, 2=Far Call, 3=Int Call
;
;RETURN:
;       CX=New Size             ES:DI = Same, now contains encrypted code 
;                                       w/decryptor
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_ULTMUTE:                               
        push    bp ax bx cx dx es ds si di
        call    Get_Our_Offset
  Offset_Mark:
        inc     cx
        inc     cx
        mov     word ptr cs:[bp+1+Set_Size],cx
        mov     word ptr cs:[Start_Pos+bp],bx
        call    Init_Rand
        call    Get_Base_Reg
        call    Setup_Choices
        call    Create_EncDec
        call    Copy_Decrypt_Code
        call    Encrypt_It
Ending_ULTMUTE:
        pop     di si ds es dx cx bx ax
        add     cx,cs:[Decryptor_Length+bp]
        inc     cx
        inc     cx
        pop     bp
        cmp     ax,3       ;Select Returning method, i.e. retn, retf, iret
        je      Int_Call
        cmp     ax,2
        je      Far_Call
Near_Call:
        retn
Far_Call:
        retf
Int_Call:        
        iret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Get_Our_Offset:
        mov     bp,sp
        mov     bp,ss:[bp]              ;This trick finds our current offset
        sub     bp,offset Offset_Mark   ;from the compiling point, as it
        ret                             ;is usually not constant....
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Rand:
        push    ax ds
        xor     ax,ax
        mov     ds,ax
        mov     ax,ds:[46c]             ;Get seed from timer click at
        pop     ds                      ;0000:046c
        mov     cs:[rand_seed+bp],ax
        pop     ax
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Get_Rand:
        push    cx dx
        mov     ax,cs:[rand_seed+bp]
        mov     cx,0deadh
        mul     cx                      ;This probably isn't a good algorithm,
        xor     ax,0dada                ;(understatement) but it works for
        ror     ax,1                    ;our purposes in this application.
        mov     cs:[rand_seed+bp],ax
        pop     dx cx
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
rand_seed       dw      0
Base_Reg        db      0
Base_Pointer    db      0
Start_Pos       dw      0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Get_Base_Reg:
        call    Get_Rand
        and     ax,11b
        cmp     al,1                    ;Eliminate CX for loop purposes
        je      Get_Base_Reg
        mov     byte ptr cs:[bp+Base_Reg],al
   Do_Pointer_Reg:
        call    Get_Rand
        shr     al,1
        jc      Done_Base_Reg
        mov     byte ptr cs:[bp+Base_Pointer],0
        ret
    Done_Base_Reg:
        mov     byte ptr cs:[bp+Base_Pointer],1
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Setup_Choices:
        push    ds si        
        push    cs
        pop     ds
        mov     si,bp

        call    Get_Rand
        mov     word ptr [si+Xor_It+2],ax        ;Randomize Xor
        call    Get_Rand
        mov     word ptr [si+Dummy3+2],ax       ;Randomize Add/Sub
        mov     word ptr [si+Dummy7+2],ax       
        
        call    Get_Rand                        ;Randomize Add/Sub
        mov     word ptr [si+Dummy4+2],ax
        mov     word ptr [si+Dummy8+2],ax

        call    Get_Rand
        mov     byte ptr [si+Rand_Byte1],al     ;Randomize Random bytes
        mov     byte ptr [si+Rand_Byte2],ah
        call    Get_Rand 
        mov     byte ptr [si+Rand_Byte3],al
        mov     byte ptr [si+Rand_Byte4],ah
        call    Get_Rand
        mov     byte ptr [si+Rand_Byte5],al
        mov     byte ptr [si+Rand_Byte6],ah
        call    Get_Rand
        mov     byte ptr [si+Rand_Byte7],al
        mov     byte ptr [si+Rand_Byte8],ah
        call    Get_Rand
        mov     byte ptr [si+Rand_Byte9],al
        mov     byte ptr [si+Rand_Byte10],ah

        mov     al,byte ptr [si+Base_Reg]
  Set_Switcher:
        and     byte ptr [si+Switcher+1],0e6       ;Delete Register
        mov     ah,al
        shl     ah,1
        shl     ah,1
        shl     ah,1
        or      byte ptr [Switcher+1+si],ah
    Set_Switcher_Pointer:    
        push    ax
        mov     al,byte ptr [si+Base_Pointer]
        or      byte ptr [si+Switcher+1],al
    Set_Set_Pointy:
        and     byte ptr [si+Set_Pointy],0fe
        or      byte ptr [si+Set_Pointy],al
        and     byte ptr [si+Inc_Pointy],0fe
        or      byte ptr [si+Inc_Pointy],al
        and     byte ptr [si+Inc_Pointy+1],0fe
        or      byte ptr [si+Inc_Pointy+1],al
        pop     ax
  Set_Xorit:
        and     byte ptr [si+Xor_It+1],0fc
        or      byte ptr [si+Xor_It+1],al
  Set_Flip_It:
        and     byte ptr [si+Flip_It+1],0e4
        or      byte ptr [si+Flip_It+1],al
        or      byte ptr [si+Flip_It+1],ah
  Set_Rotate_It:
        and     byte ptr [si+do_rotate+1],0fc
        or      byte ptr [si+do_rotate+1],al
        and     byte ptr [si+do_rot2+1],0fc
        or      byte ptr [si+do_rot2+1],al
  Set_IncDec:
        and     byte ptr [si+inc_bx_com],0fc
        or      byte ptr [si+inc_bx_com],al
        and     byte ptr [si+dec_bx_com],0fc
        or      byte ptr [si+dec_bx_com],al

        and     byte ptr [si+Dummy5],0fc
        or      byte ptr [si+Dummy5],al
        and     byte ptr [si+Dummy6],0fc
        or      byte ptr [si+Dummy6],al

  Set_AddSub:
        and     byte ptr [si+Dummy3+1],0fc
        and     byte ptr [si+Dummy4+1],0fc
        or      byte ptr [si+Dummy3+1],al
        or      byte ptr [si+Dummy4+1],al
        
        and     byte ptr [si+Dummy7+1],0fc
        and     byte ptr [si+Dummy8+1],0fc
        or      byte ptr [si+Dummy7+1],al
        or      byte ptr [si+Dummy8+1],al
        pop     si ds
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Create_EncDec:
        push    es di cx
        push    cs
        pop     es
        lea     di,[bp+Encrypt_Sequence]
        call    Get_Rand
        and     ax,1fh
        shr     ax,1            ;Insure odd number of encryptors to prevent
        shl     ax,1            ;things like "INC AX / DEC AX" to leave prog
        inc     ax              ;unencrypted.

        mov     byte ptr cs:[bp+Encrypt_Length],al
        xchg    cx,ax
Make_Pattern:
        call    Get_Rand   
        and     ax,7
        stosb
        loop    Make_Pattern
        pop     cx di es
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Copy_Decrypt_Code:
        push    si di bx cx ds
        push    bx di                      ;save for loop

        push    cs
        pop     ds

        lea     si,[bp+Set_Pointy]               
        movsw
        movsb
        lodsb                   ;Copy initial encryptor
        movsw
        movsb
        lodsb
        movsw

        mov     cl,byte ptr cs:[bp+Encrypt_Length]
        xor     ch,ch
        lea     si,[Encrypt_Sequence+bp]        ;didn't have bp earlier
   Dec_Set_Loop:
        push    cx
        lodsb        
        push    si                      ;Create the Decryptor from Sequence

        mov     bl,al
        xor     bh,bh
        shl     bx,1
        add     bx,bp
        add     bx,offset Command_Table
        mov     ax,cs:[bx]
        
        mov     cl,ah
        xor     ah,ah

        lea     si,[Xor_It+bp]
        add     si,ax
        repnz   movsb

        pop     si
        pop     cx
        loop    Dec_Set_Loop


        lea     si,[Switcher+bp]
        movsw
        lodsb                           ;Finish off Decryptor
        movsw
        lodsb
        
        movsw   ;Loop Setup
        movsw                

        pop     si bx
        mov     ax,di                   ;Set Loop
        sub     ax,si                   ;Do size of loop and offset from loop
        
        mov     cs:[Decryptor_Length+bp],ax
        
        push    ax                              ;Changed for Jump
        not     ax
        add     ax,5
        stosw
        pop     ax

        add     bx,ax                   ;Set initial Pointer
        mov     es:[si+1],bx
                                        
        mov     ax,di
        pop     ds cx bx di si
        push    si di bx cx
Copy_Prog:
        push    ax
        sub     ax,di
        add     ax,bx
        mov     word ptr es:[di+1],ax
        pop     ax        
        mov     di,ax
        repnz   movsb
        pop     cx bx di si
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Encrypt_It:
        push    bx cx di si
        
        call    set_seqp

        mov     ax,cs:[Decryptor_Length+bp]
        inc     ax
        inc     ax
        add     di,ax                    ;DI=start of code to be encrypted
                                         ;CX=Length of code to encrypt
        mov     si,di
        push    es
        pop     ds
Big_Enc_Loop:
        push    cx
        call    Switcher
        mov     cx,cs:[Encrypt_Length+bp]        

   Encrypt_Value:
        push    ax bx cx dx si di        
        mov     si,cs:[Save_SI+bp]
        dec     si
        mov     bl,cs:[si]              ;??
        mov     cs:[Save_SI+bp],si
        lea     si,cs:[Com_Table_2+bp]
        xor     bh,bh
        shl     bx,1
        add     si,bx
        mov     bx,cs:[si]
        add     bx,bp
        mov     word ptr cs:[Next_Command+bp],bx
        pop     di si dx cx bx ax
        call    cs:[Next_Command+bp]
        Loop    Encrypt_Value

        pop     cx
        call    Switcher
        call    Inc_Pointy
        call    set_seqp
        loop    Big_Enc_Loop
        pop     si di cx bx
        ret

Save_SI         dw      0
Next_Command    dw      0
set_seqp:        
        push    si
        lea     si,cs:[Encrypt_Sequence+bp] ;SI=Encrypt_Sequence
        add     si,cs:[Encrypt_Length+bp] ;SI=End of Encrypt Sequence
        mov     cs:[Save_SI+bp],SI
        pop     si
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Command_Table:                  ;8 commands -> 3 bits.
        db      [Xor_It-Xor_It],(Flip_It-Xor_It-1)
        db      [Flip_It-Xor_It],(Rotate_It_1-Flip_It-1)
        db      [Rotate_It_1-Xor_It],(Rotate_It_2-Rotate_It_1-1)
        db      [Rotate_It_2-Xor_It],(Dummy1-Rotate_It_2-1)
        db      [Dummy1-Xor_It],(Dummy2-Dummy1-1)
        db      [Dummy2-Xor_It],(Dummy3-Dummy2-1)
        db      [Dummy3-Xor_It],(Dummy4-Dummy3-1)
        db      [Dummy4-Xor_It],(Dummy5-Dummy4-1)
Com_Table_2:
        dw      [offset Xor_It]
        dw      [offset Flip_It]
        dw      [offset Rotate_It_2]
        dw      [offset Rotate_It_1]
        dw      [offset Dummy5]
        dw      [offset Dummy6]
        dw      [offset Dummy7]
        dw      [offset Dummy8]
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Set_Pointy:
        mov     di,1234 ;Pointer to Code
        ret
Set_Size:        
        mov     cx,1234 ;Size
        ret
Switcher:
        xchg    bx,[di]
        ret
Inc_Pointy:
        inc     di
        inc     di
        ret

Loop_Mut:       
        dec     cx
        jz      End_Loop_Mut
    loop_set:
        jmp     _ULTMUTE
    End_Loop_Mut:
        ret
Xor_It: 
        xor     bx,1234
        ret
Flip_It:
        xchg    bh,bl
        ret

Rotate_It_1:
        jmp     before_rot
do_rotate:
        ror     bx,1
        jmp     after_rot
before_rot:  
        push    ax
        call    Ports1
        pop     ax
        jmp     do_rotate
Ports1:
        in      al,21
        or      al,02
        out     21,al
        ret

Ports2:        
        in      al,21
        xor     al,02
        out     21,al
        ret
after_rot:        
        push    ax
        call    ports2
        pop     ax
        ret

Rotate_It_2:
        cli
        jmp     confuzzled1
do_rot2:        
        rol     bx,1
        call    Switch_Int_1_3
        jmp     donerot2
        
confuzzled1:
        call    Switch_Int_1_3
        jmp     do_rot2

Switch_Int_1_3:        
        push    ax ds
        xor     ax,ax
        mov     ds,ax
        jmp     short exch1
        db      0eah
exch1:
        xchg    ax,word ptr ds:[4]
        jmp     short exch2
        db      9ah
exch2:
        xchg    ax,word ptr ds:[0c]
        xchg    ax,word ptr ds:[4]
        pop     ds ax
        ret
donerot2:
        ret

Dummy1:
        jmp     short inc_bx_com              ;Kill Disassemblers
        db      0ea
   Rand_Byte1:        
        db      0ea
   inc_bx_com:
        inc     bx
        ret
Dummy2:
        jmp     short Kill_1
  Rand_Byte2:        
        db      0ea
  Cont_Kill1:
        cli
        xchg    ax,ds:[84]
        xchg    ax,ds:[84]
        sti
        pop     ds ax
   dec_bx_com:        
        dec     bx
        jmp     short quit_Kill1
     Kill_1:
        push    ax ds
        xor     ax,ax
        mov     ds,ax                   ;Anti-Debugger (Kills Int 21)
        jmp     short Cont_Kill1
     Rand_Byte3:
        db      0e8
   quit_Kill1:
        ret
Dummy3:
        add     bx,1234
        push    bx
        call    throw_debugger
   Rand_Byte4:
        db      0e8                             ;Prefetch Trick
   into_throw:
        sub     bx,offset Rand_Byte4
        add     byte ptr [bx+trick_em+1],0ba
   trick_em:        
        jmp     short done_trick
   Rand_Byte5:
        db      0ea
   throw_debugger:
        pop     bx
        jmp     short into_throw
   Rand_Byte6:
        db      0ea
   done_trick:
        sub     byte ptr [bx+trick_em+1],0ba
        pop     bx
        ret
Dummy4:
        sub     bx,1234
        jmp     short Get_IRQ
Rand_Byte7   db      0e8
Kill_IRQ:        
        out   21,al
        xor   al,2
        jmp   short Restore_IRQ
Rand_Byte8   db      0e8        
Rand_Byte9   db      0e8                ;This will kill the keyboard
   Get_IRQ:                             ;IRQ
        push    ax
        in    al,21
        xor   al,2
        jmp    short  Kill_IRQ
Rand_Byte10  db      0e8
Restore_IRQ:        
        out   21,al
        pop     ax
        ret

;The following are used for the encryption algorithm to reverse commands that
;include anti-tracing.
Dummy5: 
        dec     bx
        ret
Dummy6:
        inc     bx
        ret
Dummy7:
        sub     bx,1234
        ret
Dummy8:
        add     bx,1234
        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Decryptor_Length        dw      0
Encrypt_Length          dw      0
Encrypt_Sequence        db      30 dup(0)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
_END_ULTMUTE:
end _ULTMUTE
