;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;                                                                                                   
;                                                                                                        ;
;                                                                                                        ;
;      xxxxxxxxxxx      xxxxxxxx     xxxx    xxxx     xxxxxxxxxx          xxxxxxxx      xxxxxxxxx        ;  
;      xxxxxxxxxxxx    xxxx  xxxx    xxxx    xxxx    xxxxxxxxxxx         xxxxxxxxxx    xxxxxxxxxxx       ; 
;      xxxx    xxxx   xxxx    xxxx   xxxxx   xxxx   xxxx    xxxx         xxx    xxxx   xxx    xxxx       ;    
;      xxxx    xxxx   xxxx    xxxx   xxxxxx  xxxx   xxxx                        xxxx          xxxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxxxxx xxxx   xxxx                   xxxxxxxx     xxxxxxxxxx       ;   
;      xxxxxxxxxxx    xxxx xx xxxx   xxxx xxxxxxx   xxxx                   xxxxxxxx    xxxxxxxxxx        ;  
;      xxxxxxxxxxxx   xxxx xx xxxx   xxxx  xxxxxx   xxxx   xxxxx                xxxx   xxxx              ;     
;      xxxx    xxxx   xxxx    xxxx   xxxx   xxxxx   xxxx    xxxx                xxxx   xxxx    xxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxx    xxxx    xxxxxxxxxxx         xxxxxxxxxx    xxxxxxxxxxx       ;   
;      xxxx    xxxx   xxxx    xxxx   xxxx    xxxx     xxxxxxxxxx         xxxxxxxxx     xxxxxxxxxxx       ;   
;                                                                                                        ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                               RAndom Numbers Generator                                                 ; 
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                       :)!                                                              ;
;                                                                                                        ; 
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                   функция RANG32                                                       ;
;                             ГЕНЕРАТОР СЛУЧАЙНЫХ ЧИСЕЛ (ГСЧ)                                            ;
;                                                                                                        ;
;                                                                                                        ;
;ВХОД:                                                                                                   ;
;1 параметр - число (N). Будет произведен поиск случайного числа в диапазоне [0..N-1]                    ;
;--------------------------------------------------------------------------------------------------------;
;ВЫХОД:                                                                                                  ;
;EAX - слуяайное число в диапазоне [0..N-1]                                                              ;
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;         
;                                                                                                        ;
;                                       y0p!                                                             ;
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                                                                                        ;
;                                       ФИЧИ                                                             ;
;                                                                                                        ;
;(+) базонезависимость                                                                                   ;
;(+) прост в использовании                                                                               ;
;(+) не использует WinApi'шек                                                                            ;
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
;                                                                                                        ;
;                                   ИСПОЛЬЗОВАНИЕ:                                                       ;
;                                                                                                        ;
;1) Подключение:                                                                                         ;
;       rang32.asm                                                                                       ;
;2) Вызов (пример stdcall):                                                                              ;
;       push 5                  ;кладем в стэк число                                                     ;
;       call RANG32             ;вызываем ГСЧ -> в EAX после вызова будет значение [0..5-1]              ;
;                                                                                                        ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
                                                                                                       



                                                    ;m1x
                                                ;pr0mix@mail.ru
                                            ;EOF 
                                                                                                                                                                                          
                                                                                   

                                                                                                                                                                                                          
RANG32:                                                                            
    pushad                                      ;сохраняем регистры                                                                     
    mov     ecx,dword ptr [esp+24h]             ;ecx=число, что передали в стэке
    db      0fh,31h                                      
    imul    eax,eax,1664525                     ;идут разные вычисления для получения                                                   
    add     eax,1013904223                      ;более случайного числа 
    add     eax,edx
    adc     eax,esp 
    rcr     eax,16                                  
    imul    eax,[esp+32] 
    xor     edx,edx     
    mul     ecx                                 ;mul действует как div 
    mov     dword ptr [esp+1ch],edx                                            
    popad                                                                      
    ret     04
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;конец функции RANG32                                                                                          
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 

