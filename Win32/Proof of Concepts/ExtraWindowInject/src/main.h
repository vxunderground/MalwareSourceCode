#pragma once

#include "ntdll_undoc.h"
#include "kernel32_undoc.h"

#include "target_util.h"

//injection types:
#include "add_thread.h"
#include "add_apc.h"
#include "patch_ep.h"
#include "patch_context.h"
#include "window_long_inject.h"
