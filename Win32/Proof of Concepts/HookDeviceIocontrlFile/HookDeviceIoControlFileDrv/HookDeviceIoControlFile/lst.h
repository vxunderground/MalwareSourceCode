/*
    Common linked lists structures
*/

typedef struct _COMMON_LST_ENTRY
{
    UNICODE_STRING ObjectName;    
    ULONG ObjectType;

    PVOID Data;
    ULONG DataSize;

    struct _COMMON_LST_ENTRY *next, *prev;

} COMMON_LST_ENTRY,
*PCOMMON_LST_ENTRY;

typedef struct _COMMON_LST
{
    KSPIN_LOCK ListLock;
    PCOMMON_LST_ENTRY list_head, list_end;

} COMMON_LST,
*PCOMMON_LST;

/*
    Common linked lists routines
*/

PCOMMON_LST_ENTRY LstFindEntry(
    PCOMMON_LST list, 
    PUNICODE_STRING ObjectName
);

PCOMMON_LST_ENTRY LstAddEntry(
    PCOMMON_LST list,  
    PUNICODE_STRING ObjectName,
    PVOID Data,
    ULONG DataSize
);

void LstFlush(PCOMMON_LST list);
void LstDelEntry(PCOMMON_LST list, PCOMMON_LST_ENTRY e);
PCOMMON_LST LstInit(void);
void LstFree(PCOMMON_LST list);
