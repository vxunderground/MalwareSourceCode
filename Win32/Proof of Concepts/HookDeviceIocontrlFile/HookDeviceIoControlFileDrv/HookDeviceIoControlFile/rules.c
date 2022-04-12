#include "stdafx.h"

// defined in driver.cpp
extern UNICODE_STRING m_RegistryPath;
extern KMUTEX m_CommonMutex;

BOOLEAN g_RuleInited = FALSE;
ERESOURCE   g_RuleResource;
LIST_ENTRY g_DenyRuleList;
LIST_ENTRY g_AllowRuleList;
LIST_ENTRY g_DbgcbRuleList;

FORCEINLINE
VOID
RuleLock(
    __in BOOLEAN Exclusive
    )
{
    KeEnterCriticalRegion();
    if (Exclusive)
        ExAcquireResourceExclusiveLite(&g_RuleResource, TRUE);
    else
        ExAcquireResourceSharedLite(&g_RuleResource, TRUE);
}

FORCEINLINE
VOID
RuleUnlock()
{
    ExReleaseResourceLite(&g_RuleResource);
    KeLeaveCriticalRegion();
}

NTSTATUS FltInitRuleList()
{
    NTSTATUS Status = 0;

    InitializeListHead( &g_DenyRuleList );
    InitializeListHead( &g_AllowRuleList );
    InitializeListHead( &g_DbgcbRuleList );

    Status = ExInitializeResourceLite( &g_RuleResource );
    if(!NT_SUCCESS(Status))
        return Status;

    g_RuleInited = TRUE;

    return STATUS_SUCCESS;
}

VOID FltUnInitRuleList()
{
    if(!g_RuleInited)
        return;

    FltFlushAllList();

    g_RuleInited = FALSE;

    ExDeleteResourceLite(&g_RuleResource); 
}
//--------------------------------------------------------------------------------------
wchar_t xchrlower_w(wchar_t chr)
{
    if ((chr >= 'A') && (chr <= 'Z')) 
    {
        return chr + ('a'-'A');
    }

    return chr;
}
//--------------------------------------------------------------------------------------
BOOLEAN EqualUnicodeString_r(PUNICODE_STRING Str1, PUNICODE_STRING Str2, BOOLEAN CaseInSensitive)
{
    USHORT CmpLen = min(Str1->Length, Str2->Length) / sizeof(WCHAR);
    USHORT i = 0;
    for ( i = 1; i < CmpLen; i++)
    {
        WCHAR Chr1 = Str1->Buffer[Str1->Length / sizeof(WCHAR) - i], 
            Chr2 = Str2->Buffer[Str2->Length / sizeof(WCHAR) - i];

        if (CaseInSensitive)
        {
            Chr1 = xchrlower_w(Chr1);
            Chr2 = xchrlower_w(Chr2);
        }

        if (Chr1 != Chr2)
        {
            return FALSE;
        }
    }

    return TRUE;
}

PIOCTL_FILTER FltAdd(PIOCTL_FILTER f, PLIST_ENTRY ListEntry, ULONG KdCommandLength)
{
    ULONG Length  = 0;
    PIOCTL_FILTER f_entry = NULL;

    if(!g_RuleInited || !ListEntry || !f)
        return NULL;

    Length = KdCommandLength + sizeof(IOCTL_FILTER);
    f_entry = (PIOCTL_FILTER)ExAllocatePool(NonPagedPool, Length);
    if (f_entry)
    {
        RtlZeroMemory(f_entry, Length);
        RtlCopyMemory(f_entry, f, sizeof(IOCTL_FILTER));

        InsertHeadList(ListEntry, &f_entry->List);

        return f_entry;        
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "ExAllocatePool() fails\n");
    }

    return NULL;
}

VOID DeferenceRuleCount(PIOCTL_FILTER Item)
{
    if(!g_RuleInited)
        return;

    RuleLock(TRUE);
    Item->ReferenceCount--;
    RuleUnlock();
}

PIOCTL_FILTER FltAddDenyRule(PIOCTL_FILTER f, ULONG KdCommandLength)
{
    PIOCTL_FILTER Item = NULL;

    if(!g_RuleInited)
        return NULL;

    RuleLock(TRUE);
    Item = FltAdd(f, &g_DenyRuleList, KdCommandLength);
    Item->ReferenceCount +=1 ;
    RuleUnlock();

    return Item;
}

PIOCTL_FILTER FltAddAllowRule(PIOCTL_FILTER f, ULONG KdCommandLength)
{
    PIOCTL_FILTER Item = NULL;

    if(!g_RuleInited)
        return NULL;

    RuleLock(TRUE);
    Item = FltAdd(f, &g_AllowRuleList, KdCommandLength);
    Item->ReferenceCount +=1 ;
    RuleUnlock();

    return Item;
}

PIOCTL_FILTER FltAddDbgcbRule(PIOCTL_FILTER f, ULONG KdCommandLength)
{
    PIOCTL_FILTER Item = NULL;

    if(!g_RuleInited)
        return NULL;

    RuleLock(TRUE);
    Item = FltAdd(f, &g_DbgcbRuleList, KdCommandLength);
    Item->ReferenceCount +=1 ;
    RuleUnlock();

    return Item;
}

//--------------------------------------------------------------------------------------
void FltFlushList(PLIST_ENTRY ListEntryHead)
{
    PLIST_ENTRY	ListEntry = NULL;
    PLIST_ENTRY ListRemove = NULL;
    PIOCTL_FILTER RuleItem = NULL;

    if(!g_RuleInited || !ListEntryHead)
        return;

    ListEntry = ListEntryHead->Flink;
    while(ListEntry != ListEntryHead)
    {
        RuleItem = CONTAINING_RECORD(ListEntry, IOCTL_FILTER, List);

        if(RuleItem->ReferenceCount != 0)
        {
            ListEntry = ListEntry->Flink;
            continue;
        }

        if (RuleItem->Type == FLT_DEVICE_NAME ||
            RuleItem->Type == FLT_DRIVER_NAME ||
            RuleItem->Type == FLT_PROCESS_PATH)
        {
            RtlFreeUnicodeString(&RuleItem->usName);
        }

        ListRemove = ListEntry;
        ListEntry = ListEntry->Flink;
        RemoveEntryList(ListRemove);

        ExFreePool(RuleItem);      
    }
}

void FltFlushAllList()
{
    if(!g_RuleInited)
        return ;

    RuleLock(TRUE);
    FltFlushList(&g_DenyRuleList);
    FltFlushList(&g_AllowRuleList);
    FltFlushList(&g_DbgcbRuleList);
    RuleUnlock();
}
//--------------------------------------------------------------------------------------
PIOCTL_FILTER FltMatch(
    PLIST_ENTRY ListEntryHead,
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName)
{
    PIOCTL_FILTER ret = NULL;
    PIOCTL_FILTER RuleItem = NULL; 
    PLIST_ENTRY	ListEntry = NULL;

    if(!ListEntryHead)
        return NULL;

    // match parameters by filter list
    ListEntry = ListEntryHead->Flink;
    while (ListEntry != ListEntryHead)
    {
        RuleItem = CONTAINING_RECORD(ListEntry, IOCTL_FILTER, List);

        if (RuleItem->bDbgcbAction)
        {
            // skip entries with debugger commands
            goto next;
        }

        if (RuleItem->Type == FLT_DEVICE_NAME)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fDeviceName, TRUE))
            {
                ret = RuleItem;
                break;
            }
        }
        else if (RuleItem->Type == FLT_DRIVER_NAME)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fDriverName, TRUE))
            {
                ret = RuleItem;
                break;
            }
        }
        else if (RuleItem->Type == FLT_IOCTL_CODE)
        {
            if (RuleItem->IoctlCode == IoControlCode)
            {
                ret = RuleItem;
                break;
            }
        }
        else if (RuleItem->Type == FLT_PROCESS_PATH)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fProcessName, TRUE))
            {
                ret = RuleItem;
                break;
            }
        }

next:
        ListEntry = ListEntry->Flink;
    }

    return ret;
}

BOOLEAN FltMatchDeny(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName)
{
    PIOCTL_FILTER Rule = NULL;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(FALSE);
    Rule = FltMatch(&g_DenyRuleList, fDeviceName, fDriverName, IoControlCode, fProcessName);
    RuleUnlock();

    if(Rule)
        return TRUE;
    else
        return FALSE;
}

BOOLEAN FltMatchAllow(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName)
{
    PIOCTL_FILTER Rule = NULL;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(FALSE);

    if(IsListEmpty(&g_AllowRuleList))
        return TRUE;

    Rule = FltMatch(&g_AllowRuleList, fDeviceName, fDriverName, IoControlCode, fProcessName);
    RuleUnlock();

    if(Rule)
        return TRUE;
    else
        return FALSE;
}
//--------------------------------------------------------------------------------------
char *FltGetKdCommand(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName)
{
    char *lpszCmd = NULL;
    PLIST_ENTRY ListEntry = NULL;
    PIOCTL_FILTER RuleItem = NULL;

    if(!g_RuleInited)
        return NULL;

    RuleLock(FALSE);
    // match parameters by filter list
    ListEntry = g_DbgcbRuleList.Flink;
    while (ListEntry != &g_DbgcbRuleList)
    {
        RuleItem = CONTAINING_RECORD(ListEntry, IOCTL_FILTER, List);
        if (!RuleItem->bDbgcbAction)
        {
            // skip entries with debugger commands
            goto next;
        }

        if (RuleItem->Type == FLT_DEVICE_NAME)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fDeviceName, TRUE))
            {
                lpszCmd = RuleItem->szKdCommand;
                break;
            }
        }
        else if (RuleItem->Type == FLT_DRIVER_NAME)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fDriverName, TRUE))
            {
                lpszCmd = RuleItem->szKdCommand;
                break;
            }
        }
        else if (RuleItem->Type == FLT_IOCTL_CODE)
        {
            if (RuleItem->IoctlCode == IoControlCode)
            {
                lpszCmd = RuleItem->szKdCommand;
                break;
            }
        }
        else if (RuleItem->Type == FLT_PROCESS_PATH)
        {
            if (EqualUnicodeString_r(&RuleItem->usName, fProcessName, TRUE))
            {
                lpszCmd = RuleItem->szKdCommand;
                break;
            }
        }

next:
        ListEntry = ListEntry->Flink;
    }
    RuleUnlock();

    return lpszCmd;
}
//--------------------------------------------------------------------------------------
BOOLEAN FltIsMatchedRequest(
    PUNICODE_STRING fDeviceName, 
    PUNICODE_STRING fDriverName,
    ULONG IoControlCode,
    PUNICODE_STRING fProcessName)
{
    if(!g_RuleInited)
        return FALSE;

    // match process by allow/deny list
    if (FltMatchAllow(fDeviceName, fDriverName, IoControlCode, fProcessName) && 
        FltMatchDeny(fDeviceName, fDriverName, IoControlCode, fProcessName) == FALSE)
    {
        return TRUE;
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
BOOLEAN SaveRules(PLIST_ENTRY ListEntryHead, HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;
    ULONG BuffSize = 0, RulesToSerialize = 0;
    PLIST_ENTRY ListEntry = NULL;
    PIOCTL_FILTER RuleItem = NULL;

    if(!ListEntryHead)
        return FALSE;

    // calculate reqired buffer size
    ListEntry = ListEntryHead->Flink;
    while (ListEntry != ListEntryHead)
    {
        RuleItem = CONTAINING_RECORD(ListEntry, IOCTL_FILTER, List);
        if (!RuleItem->bDbgcbAction)
        {
            BuffSize += sizeof(IOCTL_FILTER_SERIALIZED);

            if (RuleItem->Type == FLT_DEVICE_NAME ||
                RuleItem->Type == FLT_DRIVER_NAME ||
                RuleItem->Type == FLT_PROCESS_PATH)
            {
                // we an have object name
                BuffSize += RuleItem->usName.Length;
            }

            RulesToSerialize++;
        }        
        
        ListEntry = ListEntry->Flink;
    }

    if (BuffSize > 0)
    {
        // allocate memory for serialized rules
        PUCHAR Buff = (PUCHAR)M_ALLOC(BuffSize);
        if (Buff)
        {
			NTSTATUS ns = STATUS_UNSUCCESSFUL;
			PIOCTL_FILTER_SERIALIZED f_s = NULL;
            RtlZeroMemory(Buff, BuffSize);            
            f_s = (PIOCTL_FILTER_SERIALIZED)Buff;

            // serialize available entries
            ListEntry = ListEntryHead->Flink;
            while (ListEntry != ListEntryHead)
            {
                RuleItem = CONTAINING_RECORD(ListEntry, IOCTL_FILTER, List);
                if (!RuleItem->bDbgcbAction)
                {
                    ULONG NextEntryOffset = sizeof(IOCTL_FILTER_SERIALIZED);

                    f_s->Type = RuleItem->Type;
                    f_s->IoctlCode = RuleItem->IoctlCode;

                    if (RuleItem->Type == FLT_DEVICE_NAME ||
                        RuleItem->Type == FLT_DRIVER_NAME ||
                        RuleItem->Type == FLT_PROCESS_PATH)
                    {
                        // we have an object name
                        f_s->NameLen = RuleItem->usName.Length;
                        NextEntryOffset += f_s->NameLen;
                        memcpy(&f_s->Name, RuleItem->usName.Buffer, f_s->NameLen);
                    }

                    // go to the next serialized entry
                    f_s = (PIOCTL_FILTER_SERIALIZED)((PUCHAR)f_s + NextEntryOffset);
                }

                ListEntry = ListEntry->Flink;               
            }
            
            ns = ZwSetValueKey(hKey, usValueName, 0, REG_BINARY, Buff, BuffSize);
            if (NT_SUCCESS(ns))
            {
                bRet = TRUE;

                DbgMsg(
                    __FILE__, __LINE__, 
                    __FUNCTION__"(): %d rules (%d bytes) saved in '%wZ'\n", 
                    RulesToSerialize, BuffSize, usValueName
                );
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ZwSetValueKey() fails; status: 0x%.8x\n", ns);
            }                                    
            
            M_FREE(Buff);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        }
    }      

    return bRet;
}

BOOLEAN SaveDenyRules(HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(FALSE);
    bRet = SaveRules(&g_DenyRuleList, hKey, usValueName);
    RuleUnlock();

    return bRet;
}

BOOLEAN SaveAllowRules(HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(FALSE);
    bRet = SaveRules(&g_AllowRuleList, hKey, usValueName);
    RuleUnlock();

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOLEAN LoadRules(PLIST_ENTRY ListEntryHead, HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;             
    PKEY_VALUE_FULL_INFORMATION KeyInfo = NULL;
    ULONG Length = 0, RulesLoaded = 0; 
    NTSTATUS ns = 0;

    if(!ListEntryHead)
        return FALSE;

    // query buffer size
    ns = ZwQueryValueKey(
        hKey, 
        usValueName,  
        KeyValueFullInformation, 
        KeyInfo, 
        0, 
        &Length
    );
    if (ns == STATUS_BUFFER_OVERFLOW || 
        ns == STATUS_BUFFER_TOO_SMALL)
    {            
        // allocate buffer
        PKEY_VALUE_FULL_INFORMATION KeyInfo = (PKEY_VALUE_FULL_INFORMATION)M_ALLOC(Length);
        if (KeyInfo)
        {
            // query value
            ns = ZwQueryValueKey(
                hKey, 
                usValueName,  
                KeyValueFullInformation, 
                KeyInfo, 
                Length, 
                &Length
            );
            if (NT_SUCCESS(ns))
            {
                if (KeyInfo->DataLength > 0)
                {
                    // deserialize rules
                    PUCHAR Buff = (PUCHAR)KeyInfo + KeyInfo->DataOffset;
                    PIOCTL_FILTER_SERIALIZED f_s = (PIOCTL_FILTER_SERIALIZED)Buff;

                    while ((ULONG)((PUCHAR)f_s - Buff) < KeyInfo->DataLength)
                    {
                        // add rule into list
                        IOCTL_FILTER Flt;
                        RtlZeroMemory(&Flt, sizeof(Flt));

                        Flt.Type = f_s->Type;
                        Flt.IoctlCode = f_s->IoctlCode;

                        if ((f_s->Type == FLT_DEVICE_NAME ||
                             f_s->Type == FLT_DRIVER_NAME ||
                             f_s->Type == FLT_PROCESS_PATH) &&
                             f_s->NameLen > 0)
                        {
                            // we have an object name
                            if (AllocUnicodeString(&Flt.usName, (USHORT)f_s->NameLen))
                            {
                                Flt.usName.Length = (USHORT)f_s->NameLen;
                                memcpy(Flt.usName.Buffer, &f_s->Name, f_s->NameLen);
                                DbgMsg(__FILE__, __LINE__, __FUNCTION__"(): '%wZ'\n", &Flt.usName);
                            }
                            else
                            {
                                goto err;
                            }
                        }

                        if (!FltAdd(&Flt, ListEntryHead, 0))
                        {
                            if (Flt.usName.Buffer)
                            {
                                RtlFreeUnicodeString(&Flt.usName);
                            }                            
                        }
                        else
                        {
                            RulesLoaded++;
                        }
err:
                        // go to the next serialized entry
                        f_s = (PIOCTL_FILTER_SERIALIZED)((PUCHAR)f_s + 
                            sizeof(IOCTL_FILTER_SERIALIZED) + f_s->NameLen);
                    }                        
                }

                DbgMsg(
                    __FILE__, __LINE__, 
                    __FUNCTION__"(): %d rules loaded from '%wZ'\n", 
                    RulesLoaded, usValueName
                );

                bRet = TRUE;
            }
            else
            {
                DbgMsg(__FILE__, __LINE__, "ZwQueryValueKey() fails; status: 0x%.8x\n", ns);
            }

            M_FREE(KeyInfo);
        }
        else
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        }
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() WARNING: '%wZ' value is not set\n", usValueName);
    }      

    return bRet;
}

BOOLEAN LoadDenyRules(HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(TRUE);
    bRet = LoadRules(&g_DenyRuleList, hKey, usValueName);
    RuleUnlock();

    return bRet;
}

BOOLEAN LoadAllowRules(HANDLE hKey, PUNICODE_STRING usValueName)
{
    BOOLEAN bRet = FALSE;

    if(!g_RuleInited)
        return FALSE;

    RuleLock(TRUE);
    bRet = LoadRules(&g_AllowRuleList, hKey, usValueName);
    RuleUnlock();

    return bRet;
}
//--------------------------------------------------------------------------------------
