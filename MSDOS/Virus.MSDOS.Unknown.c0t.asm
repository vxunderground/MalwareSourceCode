;  'Extra-Tiny' memory model startup code for Turbo C 2.0
;
;  This makes smaller executable images from C programs, by
;  removing code to get command line arguments and the like.
;  Compile with Tiny model flag, do not use any standard I/O
;  library functions, such as puts() or int86().
;
;  This code courtesey PC Magazine, December 26, 1989.
;  But nobody really needs to know that.


_text           segment byte public 'code'
_text           ends
_data           segment word public 'data'
_data           ends
_bss            segment word public 'bss'
_bss            ends

dgroup          group           _text, _data, _bss

_text           segment
                org 100h
begin:
_text           ends

                end     begin
