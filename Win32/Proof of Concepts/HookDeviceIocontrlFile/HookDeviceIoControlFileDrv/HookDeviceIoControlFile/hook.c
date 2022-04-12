#include "stdafx.h"
//--------------------------------------------------------------------------------------
PVOID Hook(PVOID Function, PVOID Handler, PULONG pBytesPatched)
{  
#ifdef _X86_

#define SIZEOFJUMP 6

#elif _AMD64_

#define SIZEOFJUMP 14

#endif

    ULONG Size = 0, CollectedSpace = 0;
    PUCHAR pInst = (PUCHAR)Function;
    ud_t ud_obj;
	PVOID CallGate = NULL;
	ULONG CallGateSize = 0;

    if (pBytesPatched)
    {
        *pBytesPatched = 0;
    }

    // initialize disassembler engine
    
    ud_init(&ud_obj);

    // set mode, syntax and vendor
    ud_set_mode(&ud_obj, UD_MODE);
    ud_set_syntax(&ud_obj, UD_SYN_INTEL);
    ud_set_vendor(&ud_obj, UD_VENDOR_INTEL);

    while (CollectedSpace < SIZEOFJUMP)
    {
		ULONG dwInstLen = 0;
		int i = 0;
        ud_set_input_buffer(&ud_obj, pInst, MAX_INST_LEN);

        // get length of instruction
        dwInstLen = ud_disassemble(&ud_obj);
        if (dwInstLen == 0)
        {
            // error while disassembling instruction
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't disassemble instruction at "IFMT"\n", pInst);
            return NULL;
        }

        if (ud_obj.mnemonic == UD_Ijmp ||
            ud_obj.mnemonic == UD_Icall)
        {
            // call/jmp with relative address
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() call/jmp/jxx instruction at "IFMT"\n", pInst);
            return NULL;
        }

        for (i = 0; i < 3; i++)
        {
            if (ud_obj.operand[i].type == UD_OP_JIMM)
            {
                // jxx with relative address
                DbgMsg(__FILE__, __LINE__, __FUNCTION__"() jxx instruction at "IFMT"\n", pInst);
                return NULL;
            }
        }

        pInst += dwInstLen;
        CollectedSpace += dwInstLen;

        if (ud_obj.mnemonic == UD_Iret  ||
            ud_obj.mnemonic == UD_Iretf ||
            ud_obj.mnemonic == UD_Iiretw   ||
            ud_obj.mnemonic == UD_Iiretq   ||
            ud_obj.mnemonic == UD_Iiretd)
        {
            // end of the function thunk?
            DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ret/retn/iret instruction at "IFMT"\n", pInst);
            break;
        }
    }

    if (SIZEOFJUMP > CollectedSpace)
    {
        DbgMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: not enough memory for jump\n");
        return NULL;
    }

    CallGateSize = CollectedSpace + SIZEOFJUMP;

    // allocate memory for callgate
    CallGate = M_ALLOC(CallGateSize);
    if (CallGate)
    {
        // generate callgate
        memset(CallGate, 0x90, CallGateSize);    

        // save begining of the function
        memcpy(CallGate, Function, CollectedSpace);        
        
#ifdef _X86_

        // jump from callgate to function body
        // push imm32
        *(PUCHAR)((PUCHAR)CallGate + CollectedSpace) = 0x68;
        *(PUCHAR *)((PUCHAR)CallGate + CollectedSpace + 1) = (PUCHAR)Function + SIZEOFJUMP;
        // ret
        *(PUCHAR)((PUCHAR)CallGate + CollectedSpace + 5) = 0xC3;                            

#elif _AMD64_

        // jmp qword [addr]
        *(PUSHORT)((PUCHAR)CallGate + CollectedSpace) = 0x25FF;
        *(PULONG)((PUCHAR)CallGate + CollectedSpace + 2) = 0;
        // addr dq XXXh
        *(PULONGLONG)((PUCHAR)CallGate + CollectedSpace + 6) = (ULONGLONG)Function + SIZEOFJUMP;

#endif
       
        // jump from the function to callgate
        memset(Function, 0x90, CollectedSpace);        

#ifdef _X86_

        // push imm32
        *(PUCHAR)Function = 0x68;
        *(PUCHAR *)((PUCHAR)Function + 1) = (PUCHAR)Handler;
        // ret
        *(PUCHAR)((PUCHAR)Function + 5) = 0xC3;                            

#elif _AMD64_

        // jmp qword [addr]
        *(PUSHORT)Function = 0x25FF;
        *(PULONG)((PUCHAR)Function + 2) = 0;
        // addr dq XXXh
        *(PULONGLONG)((PUCHAR)Function + 6) = (ULONGLONG)Handler;

#endif            
        *pBytesPatched = CollectedSpace;

        return CallGate;
    }
    else
    {
        DbgMsg(__FILE__, __LINE__, "M_ALLOC() fails\n");
    }

    return NULL;
}
//--------------------------------------------------------------------------------------
// EoF
