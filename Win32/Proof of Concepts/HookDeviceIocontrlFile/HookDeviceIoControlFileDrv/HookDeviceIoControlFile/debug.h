#include <ntifs.h>
#ifdef DBGMSG_FULL

void DbgMsg(char *lpszFile, int Line, char *lpszMsg, ...);
void DbgClose(void);
void DbgInit(void);

#else // DBGMSG_FULL

#define DbgMsg
#define DbgClose
#define DbgInit

#endif // DBGMSG_FULL

#ifdef DBGPIPE
void DbgOpenPipe(void);
void DbgClosePipe(void);
#endif

#ifdef DBGLOGFILE
void DbgOpenLogFile(void);
#endif

void DbgHexdump(PUCHAR Data, ULONG Length);
