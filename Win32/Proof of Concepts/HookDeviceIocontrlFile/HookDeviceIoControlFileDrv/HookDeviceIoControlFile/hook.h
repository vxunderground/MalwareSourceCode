#ifdef _X86_

#define MAX_INST_LEN    16
#define UD_MODE         32

#elif _AMD64_

#define MAX_INST_LEN    24
#define UD_MODE         64

#endif

PVOID Hook(PVOID Function, PVOID Handler, PULONG pBytesPatched);
