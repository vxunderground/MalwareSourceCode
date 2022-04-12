#include "stdafx.h"
//--------------------------------------------------------------------------------------
PCOMMON_LST_ENTRY LstFindEntry(
    PCOMMON_LST list, 
    PUNICODE_STRING ObjectName)
{
    PCOMMON_LST_ENTRY ret = NULL;
    KIRQL OldIrql;
    KeAcquireSpinLock(&list->ListLock, &OldIrql);

    __try
    {
        PCOMMON_LST_ENTRY e = list->list_head;

        while (e)
        {
            // for empty object name - just return first entry
            if (ObjectName == NULL ||
                RtlEqualUnicodeString(&e->ObjectName, ObjectName, TRUE))
            {                
                ret = e;
                break;
            }

            e = e->next;
        }
    }    
    __finally
    {
        KeReleaseSpinLock(&list->ListLock, OldIrql);
    }

    return ret;
}
//--------------------------------------------------------------------------------------
PCOMMON_LST_ENTRY LstAddEntry(
    PCOMMON_LST list,  
    PUNICODE_STRING ObjectName,
    PVOID Data,
    ULONG DataSize)
{
    PCOMMON_LST_ENTRY ret = NULL;
    KIRQL OldIrql;
    KeAcquireSpinLock(&list->ListLock, &OldIrql);

    __try
    {
        // allocate single list entry
        PCOMMON_LST_ENTRY e = (PCOMMON_LST_ENTRY)M_ALLOC(sizeof(COMMON_LST_ENTRY));
        if (e)
        {
            RtlZeroMemory(e, sizeof(COMMON_LST_ENTRY));

            if (Data && DataSize > 0)
            {
                // allocate memory for custom data
                if (e->Data = M_ALLOC(DataSize))
                {
                    e->DataSize = DataSize;
                    RtlCopyMemory(e->Data, Data, DataSize);
                }
                else
                {
                    DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
                    M_FREE(e);                
                    return NULL;
                }
            }

            // allocate and copy string name
            if (AllocUnicodeString(&e->ObjectName, ObjectName->MaximumLength))
            {
                RtlCopyUnicodeString(&e->ObjectName, ObjectName);
            }
            else
            {
                if (e->Data)
                {
                    M_FREE(e->Data);
                }

                M_FREE(e);                
                return NULL;
            }

            // add it to list
            if (list->list_end)
            {
                list->list_end->next = e;
                e->prev = list->list_end;
                list->list_end = e;
            } 
            else 
            {
                list->list_end = list->list_head = e;    
            }

            ret = e;
        }   
        else
        {
            DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
        }
    }    
    __finally
    {
        KeReleaseSpinLock(&list->ListLock, OldIrql);
    }    

    return ret;
}
//--------------------------------------------------------------------------------------
void LstFlush(PCOMMON_LST list)
{
    KIRQL OldIrql;
    KeAcquireSpinLock(&list->ListLock, &OldIrql);

    __try
    {
        // delete all entries from list
        PCOMMON_LST_ENTRY e = list->list_head;
        while (e)
        {
            PCOMMON_LST_ENTRY e_tmp = e->next;

            // delete single entry from list
            if (e->prev)
                e->prev->next = e->next;

            if (e->next)
                e->next->prev = e->prev;

            if (list->list_head == e)
                list->list_head = e->next;

            if (list->list_end == e)
                list->list_end = e->prev;

            if (e->Data)
            {
                // delete data, if present
                M_FREE(e->Data);
            }

            // free name string
            RtlFreeUnicodeString(&e->ObjectName);
            M_FREE(e);

            e = e_tmp;
        }        

        list->list_head = NULL;
        list->list_end = NULL;
    }    
    __finally
    {
        KeReleaseSpinLock(&list->ListLock, OldIrql);
    }    
}
//--------------------------------------------------------------------------------------
void LstDelEntry(PCOMMON_LST list, PCOMMON_LST_ENTRY e)
{
    KIRQL OldIrql;
    KeAcquireSpinLock(&list->ListLock, &OldIrql);

    __try
    {
        // delete single entry from list
        if (e->prev)
            e->prev->next = e->next;

        if (e->next)
            e->next->prev = e->prev;

        if (list->list_head == e)
            list->list_head = e->next;

        if (list->list_end == e)
            list->list_end = e->prev;

        if (e->Data)
        {
            // delete data, if present
            M_FREE(e->Data);
        }

        // free name string
        RtlFreeUnicodeString(&e->ObjectName);
        M_FREE(e);
    }    
    __finally
    {
        KeReleaseSpinLock(&list->ListLock, OldIrql);
    }     
}
//--------------------------------------------------------------------------------------
PCOMMON_LST LstInit(void)
{
    // allocate new list
    PCOMMON_LST ret = (PCOMMON_LST)M_ALLOC(sizeof(COMMON_LST));
    if (ret)
    {
        ret->list_head = ret->list_end = NULL;
        KeInitializeSpinLock(&ret->ListLock);
        return ret;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
    }

    return NULL;
}
//--------------------------------------------------------------------------------------
void LstFree(PCOMMON_LST list)
{
    // flust list and free list descriptor
    LstFlush(list);
    M_FREE(list);
}
//--------------------------------------------------------------------------------------
// EoF
