
void DbgMsg(char *lpszFile, int Line, char *lpszMsg, ...);
void DbgInit(char *lpszDebugPipeName, char *lpszLogFileName);

#define CCOL_BLUE    (0x09)
#define CCOL_GREEN   (0x0A)
#define CCOL_CYAN    (0x0B)
#define CCOL_RED     (0x0C)
#define CCOL_PURPLE  (0x0D)
#define CCOL_YELLOW  (0x0E)
#define CCOL_WHITE   (0x0F)

WORD ccol(WORD wColor);
