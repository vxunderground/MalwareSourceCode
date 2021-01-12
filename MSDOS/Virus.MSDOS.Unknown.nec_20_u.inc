;[Death Virii Crew] Presents
;CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997

brkem macro inter
db 0fh,0ffh,inter
endm brkem

retem macro
db 0edh,0fdh
endm retem

int86 macro  oper8
db 0edh,0edh
db oper8
endm

int21h macro _ax,_cx,_dx

_lxi_b _ax
_push_b
_lxi_b _cx
_push_b
_lxi_b _dx
_push_b
int86 88h

endm

;						(c) by Reminder [DVC]

