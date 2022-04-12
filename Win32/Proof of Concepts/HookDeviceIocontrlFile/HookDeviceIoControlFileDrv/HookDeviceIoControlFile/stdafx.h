

//extern "C"
//{
#include <ntifs.h>
#include <stdio.h>
#include <stdarg.h>
#include <ntimage.h>
#include "undocnt.h"
//}

#define WP_STUFF

#include "debug.h"
#include "common.h"
#include "lst.h"

#include "options.h"

#include "common_asm.h"
#include "drvcomm.h"
#include "rng.h"
#include "driver.h"
#include "handlers.h"
#include "hook.h"
#include "log.h"
#include "rules.h"

// udis86 disasm engine
#include "udis86/extern.h"

// kernel debugger communication engine (dbgcb) client
//#include "../../dbgcb/common/dbgcb_api.h"

#ifdef _X86_
#pragma comment(lib,"../udis86/udis86_i386.lib")
#elif _AMD64_
#pragma comment(lib,"../udis86/udis86_amd64.lib")
#endif
