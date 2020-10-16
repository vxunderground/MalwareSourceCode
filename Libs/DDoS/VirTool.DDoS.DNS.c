#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <math.h>
#include <stropts.h>
#include <ctype.h>
#include <errno.h>
#include <arpa/inet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

struct DNS_HEADER
{
	unsigned short id; // identification number

	unsigned char rd :1; // recursion desired
	unsigned char tc :1; // truncated message
	unsigned char aa :1; // authoritive answer
	unsigned char opcode :4; // purpose of message
	unsigned char qr :1; // query/response flag

	unsigned char rcode :4; // response code
	unsigned char cd :1; // checking disabled
	unsigned char ad :1; // authenticated data
	unsigned char z :1; // its z! reserved
	unsigned char ra :1; // recursion available

	unsigned short q_count; // number of question entries
	unsigned short ans_count; // number of answer entries
	unsigned short auth_count; // number of authority entries
	unsigned short add_count; // number of resource entries
};

struct QUESTION
{
	unsigned short qtype;
	unsigned short qclass;
};

#pragma pack(push, 1)
struct R_DATA
{
	unsigned short type;
	unsigned short _class;
	unsigned int ttl;
	unsigned short data_len;
};
#pragma pack(pop)

struct RES_RECORD
{
	unsigned char *name;
	struct R_DATA *resource;
	unsigned char *rdata;
};

typedef struct
{
	unsigned char *name;
	struct QUESTION *ques;
} QUERY;

volatile int running_threads = 0;
volatile int found_srvs = 0;
volatile unsigned long per_thread = 0;
volatile unsigned long start = 0;
volatile unsigned long scanned = 0;
volatile int sleep_between = 0;
volatile int bytes_sent = 0;
volatile unsigned long hosts_done = 0;
FILE *fd;

void ChangetoDnsNameFormat(unsigned char* dns,unsigned char* host)
{
	int lock = 0 , i;
	strcat((char*)host,".");

	for(i = 0 ; i < strlen((char*)host) ; i++)
	{
		if(host[i]=='.')
		{
			*dns++ = i-lock;
			for(;lock<i;lock++)
			{
				*dns++=host[lock];
			}
			lock++;
		}
	}
	*dns++='\0';
}

void *flood(void *par1)
{
	running_threads++;
	int thread_id = (int)par1;
	unsigned long start_ip = htonl(ntohl(start)+(per_thread*thread_id));
	unsigned long end = htonl(ntohl(start)+(per_thread*(thread_id+1)));
	unsigned long w;
	int y;
	unsigned char *host = (unsigned char *)malloc(50);
	strcpy((char *)host, ".");
	unsigned char buf[65536],*qname;
	struct DNS_HEADER *dns = NULL;
	struct QUESTION *qinfo = NULL;
	dns = (struct DNS_HEADER *)&buf;

	dns->id = (unsigned short) htons(rand());
	dns->qr = 0;
	dns->opcode = 0;
	dns->aa = 0;
	dns->tc = 0;
	dns->rd = 1;
	dns->ra = 0;
	dns->z = 0;
	dns->ad = 0;
	dns->cd = 0;
	dns->rcode = 0;
	dns->q_count = htons(1);
	dns->ans_count = 0;
	dns->auth_count = 0;
	dns->add_count = htons(1);
	qname =(unsigned char*)&buf[sizeof(struct DNS_HEADER)];

	ChangetoDnsNameFormat(qname , host);
	qinfo =(struct QUESTION*)&buf[sizeof(struct DNS_HEADER) + (strlen((const char*)qname) + 1)];

	qinfo->qtype = htons( 255 );
	qinfo->qclass = htons(1);

	void *edns = (void *)qinfo + sizeof(struct QUESTION)+1;
	memset(edns, 0x00, 1);
	memset(edns+1, 0x29, 1);
	memset(edns+2, 0xFF, 2);
	memset(edns+4, 0x00, 7);

	int sizeofpayload = sizeof(struct DNS_HEADER) + (strlen((const char *)qname)+1) + sizeof(struct QUESTION) + 11;
	int sock;
	if((sock=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))<0) {
		perror("cant open socket");
		exit(-1);
	}
	for(w=ntohl(start_ip);w<htonl(end);w++)
	{
		struct sockaddr_in servaddr;
		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		servaddr.sin_addr.s_addr=htonl(w);
		servaddr.sin_port=htons(53);
		sendto(sock,(char *)buf,sizeofpayload,0, (struct sockaddr *)&servaddr,sizeof(servaddr));
		bytes_sent+=24;
		scanned++;
		hosts_done++;
		usleep(sleep_between*1000);
	}
	close(sock);
	running_threads--;
	return;
}

void sighandler(int sig)
{
	fclose(fd);
	printf("\n");
	exit(0);
}

void recievethread()
{
	printf("Started Listening Thread\n");
	int saddr_size, data_size, sock_raw;
	struct sockaddr_in saddr;
	struct in_addr in;

	unsigned char *buffer = (unsigned char *)malloc(65536);
	sock_raw = socket(AF_INET , SOCK_RAW , IPPROTO_UDP);
	if(sock_raw < 0)
	{
		printf("Socket Error\n");
		exit(1);
	}
	while(1)
	{
		saddr_size = sizeof saddr;
		data_size = recvfrom(sock_raw , buffer , 65536 , 0 , (struct sockaddr *)&saddr , &saddr_size);
		if(data_size <0 )
		{
			printf("Recvfrom error , failed to get packets\n");
			exit(1);
		}
		struct iphdr *iph = (struct iphdr*)buffer;
		if(iph->protocol == 17)
		{
			unsigned short iphdrlen = iph->ihl*4;
			struct udphdr *udph = (struct udphdr*)(buffer + iphdrlen);
			unsigned char* payload = buffer + iphdrlen + 8;
			if(ntohs(udph->source) == 53)
			{
				int body_length = data_size - iphdrlen - 8;
				struct DNS_HEADER *dns = (struct DNS_HEADER*) payload;
				if(dns->ra == 1)
				{
					found_srvs++;
					fprintf(fd,"%s . %d\n",inet_ntoa(saddr.sin_addr),body_length);
					fflush(fd);
				}
			}
		}

	}
	close(sock_raw);

}

int main(int argc, char *argv[ ])
{

	if(argc < 6){
		fprintf(stderr, "Invalid parameters!\n");
		fprintf(stdout, "Usage: %s <class a start> <class a end> <outfile> <threads> <scan delay in ms>\n", argv[0]);
		exit(-1);
	}
	fd = fopen(argv[3], "a");
	sleep_between = atoi(argv[5]);

	signal(SIGINT, &sighandler);

	int threads = atoi(argv[4]);
	pthread_t thread;

	pthread_t listenthread;
	pthread_create( &listenthread, NULL, &recievethread, NULL);

	char *str_start = malloc(18);
	memset(str_start, 0, 18);
	str_start = strcat(str_start,argv[1]);
	str_start = strcat(str_start,".0.0.0");
	char *str_end = malloc(18);
	memset(str_end, 0, 18);
	str_end = strcat(str_end,argv[2]);
	str_end = strcat(str_end,".255.255.255");
	start = inet_addr(str_start);
	per_thread = (ntohl(inet_addr(str_end)) - ntohl(inet_addr(str_start))) / threads;
	unsigned long toscan = (ntohl(inet_addr(str_end)) - ntohl(inet_addr(str_start)));
	int i;
	for(i = 0;i<threads;i++){
		pthread_create( &thread, NULL, &flood, (void *) i);
	}
	sleep(1);
	printf("Starting Scan...\n");
	char *temp = (char *)malloc(17);
	memset(temp, 0, 17);
	sprintf(temp, "Found");
	printf("%-16s", temp);
	memset(temp, 0, 17);
	sprintf(temp, "Host/s");
	printf("%-16s", temp);
	memset(temp, 0, 17);
	sprintf(temp, "B/s");
	printf("%-16s", temp);
	memset(temp, 0, 17);
	sprintf(temp, "Running Thrds");
	printf("%-16s", temp);
	memset(temp, 0, 17);
	sprintf(temp, "Done");
	printf("%s", temp);
	printf("\n");

	char *new;
	new = (char *)malloc(16*6);
	while (running_threads > 0)
	{
		printf("\r");
		memset(new, '\0', 16*6);
		sprintf(new, "%s|%-15lu", new, found_srvs);
		sprintf(new, "%s|%-15d", new, scanned);
		sprintf(new, "%s|%-15d", new, bytes_sent);
		sprintf(new, "%s|%-15d", new, running_threads);
		memset(temp, 0, 17);
		int percent_done=((double)(hosts_done)/(double)(toscan))*100;
		sprintf(temp, "%d%%", percent_done);
		sprintf(new, "%s|%s", new, temp);
		printf("%s", new);
		fflush(stdout);
		bytes_sent=0;
		scanned = 0;
		sleep(1);
	}
	printf("\n");
	fclose(fd);
	return 0;
}