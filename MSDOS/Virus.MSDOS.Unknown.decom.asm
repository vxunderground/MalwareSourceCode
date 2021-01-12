;DECOM - has few safety features right now, be careful =)

.model tiny
.radix 16
.code
	org 100
	include wolf.lib

start:
	printf  intro, ds
Release_Memory:
	mov         bx,(end_unmte-start+10f)/10     ;Release all but what
	changealloc bx,es                               ;our prog needs.

Allocate_Block_For_MTE_Prog:                    ;Allocate memory for
	mov     bx,1000                         ;MTE-inf prog.
	alloc   bx
	jnc     Memory_Good
	jmp     exit
Memory_Good:
	push    ax

Get_Filenames:
	printf  Enter_FN, ds
	gets    filename_buf, ds, 30
	printf  Enter_DN, ds
	gets    unenc_buf, ds, 30

Open_Prog:
	fopen   0, filename, cs
	jnc     Load_Prog
	printf  Bad_File, ds
	jmp     Get_Filenames

Load_Prog:
	pop     ax
	sub     ax,10
	mov     ds,ax                 ;Convert Seg:0 to Seg:100
	fread   bx, 0ffff, 100, ax
	mov     cs:[MTE_Size],ax
	mov     cs:[MTE_Segment],ds

Close_Prog:
	fclose  bx

Setup_Trace:
	push    ds ds

	mov     byte ptr cs:[Success],1
	
	push    cs
	pop     ds
	get_int  1
	mov     word ptr [IP_01],bx
	mov     word ptr [CS_01],es
	set_int  1, Int_01_Handler, ds
	
	pop     ds es           ;restore segment regs to MTE prog
	
	cli        
	mov     ax,ds
	mov     ss,ax           ;setup new stack
	mov     sp,0fffe
	sti

	xor     ax,ax
	mov     bx,ax
	mov     cx,ax
	mov     dx,ax           ;Zero all registers
	mov     si,ax
	mov     di,ax
	mov     bp,ax

	
	pushf                   ;Setup stack for IRET to code
	pop     ax
	or      ax,100
	push    ax              ;Set flag on IRET

	push    ds
	mov     ax,100
	push    ax
	
	xor     ax,ax

	iret                    ;Jump to MTE prog with trap set.

Done_Trace:
	push    cs cs
	pop     es ds           ;restore seg regs
	
	cli
	mov     ax,ds
	mov     ss,ax           ;reset stack
	mov     sp,0fffe
	sti

Restore_Int_01:
	mov     dx, word ptr cs:[CS_01]
	mov     ds,dx
	mov     dx, word ptr cs:[IP_01]
	set_int  1, dx, ds
	push    cs 
	pop     ds

	cmp     byte ptr cs:[Success],0
	jne     Save_It
	

	printf  halted, ds
	jmp     Exit

Save_It:
	mov     ah,3c
	xor     cx,cx
	mov     dx,offset Unencrypted
	int     21

	xchg    bx,ax

	mov     ah,40
	mov     dx,word ptr cs:[MTE_Segment]
	mov     ds,dx
	mov     dx,100
	mov     cx,word ptr cs:[MTE_Size]
	int     21

	mov     ah,3e
	int     21
Exit:
	terminate

Int_01_Handler:
	push    bp
	mov     bp,sp
	push    ax bx cx dx es ds si di
	mov     bx, word ptr ss:[bp+4]  ;CS
	mov     ds,bx
	mov     bx,word ptr ss:[bp+2]   ;IP
	mov     ax,word ptr ss:[bp+6]   ;flags
	and     ax,40

	cmp     byte ptr ds:[bx],0cdh   ;Interrupt call
	je      Stop_Execution
	cmp     byte ptr ds:[bx],9a     ;Far Call
	je      Stop_Execution
	cmp     byte ptr ds:[bx],9c     ;Pushf
	je      Stop_Execution

ES_DS_CHeck:        
	push    bx
	mov     bx,ds
	cmp     word ptr ds:[bp-0c],bx  ;CS != DS
	jne     Done_Check
	cmp     word ptr ds:[bp-0a],bx  ;CS != ES
Done_Check:
	pop     bx
	jne     Stop_Execution

	
Check_For_Encryption_Loop:        
	cmp     byte ptr ds:[bx],75     ;Check if JNZ (end of MTE decrypt)
	je      Is_JNZ
	cmp     byte ptr ds:[bx],74     ;Check for other loop jumps..
	je      Is_JZ
	cmp     byte ptr ds:[bx],0e0    
	je      Is_LOOPNZ
	cmp     byte ptr ds:[bx],0e1
	je      Is_LOOPZ
	cmp     byte ptr ds:[bx],0e2
	je      Is_LOOP
Continue_Decrypt:
Done_Int_01_Handler:
	pop     di si ds es dx cx bx ax
	pop     bp
	iret

Stop_Execution:
	mov     byte ptr cs:[Success],0
	jmp     Done_Trace


Is_LOOPNZ:
Is_JNZ:
	or      ax,ax
	jz      Jump_True
	jmp     Jump_False

Is_LOOPZ:       
Is_JZ:
	or      ax,ax
	jz      Jump_False
	jmp     Jump_True

Is_LOOP:
	dec     cx
	jz      Jump_False
	jmp     Jump_True

Jump_False:
	cmp     byte ptr ds:[bx+1], 80
	jae     Done_Decrypt
	jmp     Continue_Decrypt

Jump_True:
	cmp     byte ptr ds:[bx+1],80
	;jae     Continue_Decrypt
	jmp     Continue_Decrypt        ;MTE only... change later
Done_Decrypt:        
	jmp     Done_Trace


IP_01   dw      0
CS_01   dw      0

MTE_Segment     dw      0
MTE_Size        dw      0

Success         db      0

halted          db      0a,0dh,'Sorry, cannot decrypt file safely.',0
intro           db      'DECOM 0.9á, COM (MTE) File Decryptor (c) 1993 Black Wolf.',0a,0dh
		db      'Beta-Test Version, Use At Your Own Risk.',0
Enter_FN        db      0a,0dh,'Please Enter Source Filename: ',0
Enter_DN        db      0a,0dh,'Now Enter The Destination Filename: ',0
Bad_File        db      0a,0dh,'Sorry, file not found.',0

filename_buf    db      ?,?
filename        db      30 dup(?)

unenc_buf       db      ?,?
unencrypted     db      30 dup(?)

end_unmte:
end start
