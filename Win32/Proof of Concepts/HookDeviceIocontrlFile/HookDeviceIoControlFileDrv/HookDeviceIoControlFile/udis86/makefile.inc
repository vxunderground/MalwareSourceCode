decode.obj: src/decode.c
    $(CC) $(CFLAGS) src/decode.c

input.obj: src/input.c
    $(CC) $(CFLAGS) src/input.c

itab.obj: src/itab.c
    $(CC) $(CFLAGS) src/itab.c

syn.obj: src/syn.c
    $(CC) $(CFLAGS) src/syn.c
        
syn-att.obj: src/syn-att.c
    $(CC) $(CFLAGS) src/syn-att.c
        
syn-intel.obj: src/syn-intel.c
    $(CC) $(CFLAGS) src/syn-intel.c
 
udis86.obj: src/udis86.c
    $(CC) $(CFLAGS) src/udis86.c        

LOBJS = decode.obj input.obj itab.obj syn.obj syn-att.obj syn-intel.obj udis86.obj
