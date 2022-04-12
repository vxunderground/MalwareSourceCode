
/**
* Structures and defines for IOCTL filtering
*/
#define FLT_DEVICE_NAME     1
#define FLT_DRIVER_NAME     2
#define FLT_IOCTL_CODE      3
#define FLT_PROCESS_PATH    4

typedef struct _IOCTL_FILTER
{
    LIST_ENTRY List;
    ULONG ReferenceCount;
    ULONG Type;

    UNICODE_STRING usName;
    ULONG IoctlCode;

    BOOLEAN bDbgcbAction;
    char szKdCommand[1];

} IOCTL_FILTER, *PIOCTL_FILTER;

typedef struct _IOCTL_FILTER_SERIALIZED
{
    ULONG Type;
    ULONG IoctlCode;
    ULONG NameLen;
    WCHAR Name[];

} IOCTL_FILTER_SERIALIZED,
*PIOCTL_FILTER_SERIALIZED;

PIOCTL_FILTER FltAdd(PIOCTL_FILTER f, PLIST_ENTRY ListEntry, ULONG KdCommandLength);

BOOLEAN FltIsMatchedRequest(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName
);

char *FltGetKdCommand(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName
);

BOOLEAN SaveRules(PLIST_ENTRY ListEntryHead, HANDLE hKey, PUNICODE_STRING usValueName);
BOOLEAN LoadRules(PLIST_ENTRY ListEntryHead, HANDLE hKey, PUNICODE_STRING usValueName);

/**
* Macro defines for allow/deny lists of IOCTL filtering
*/

// #define FltAllowMatch(_drv_, _dev_, _c_, _p_) FltMatch(&f_allow_head, (_drv_), (_dev_), (_c_), (_p_))
// 

// #define FltDenyMatch(_drv_, _dev_, _c_, _p_) FltMatch(&f_deny_head, (_drv_), (_dev_), (_c_), (_p_))
// 


NTSTATUS FltInitRuleList();
VOID FltUnInitRuleList();
PIOCTL_FILTER FltAddDbgcbRule(PIOCTL_FILTER f, ULONG KdCommandLength);
PIOCTL_FILTER FltAddDenyRule(PIOCTL_FILTER f, ULONG KdCommandLength);
PIOCTL_FILTER FltAddAllowRule(PIOCTL_FILTER f, ULONG KdCommandLength);

void FltFlushAllList();

BOOLEAN FltMatchAllow(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName);
BOOLEAN FltMatchDeny(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName);

BOOLEAN SaveDenyRules(HANDLE hKey, PUNICODE_STRING usValueName);
BOOLEAN SaveAllowRules(HANDLE hKey, PUNICODE_STRING usValueName);
BOOLEAN LoadDenyRules(HANDLE hKey, PUNICODE_STRING usValueName);
BOOLEAN LoadAllowRules(HANDLE hKey, PUNICODE_STRING usValueName);

VOID DeferenceRuleCount(PIOCTL_FILTER Item);