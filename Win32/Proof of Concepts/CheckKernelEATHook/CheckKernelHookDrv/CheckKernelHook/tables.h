
/*
 * libdasm -- simple x86 disassembly library
 * (c) 2004 - 2005  jt / nologin.org
 *
 * Opcode tables for FPU, 1, 2 and 3-byte opcodes and
 * extensions.
 *
 */

#include "libdasm.h"


// lock/rep prefix name table
const char *rep_table[] = {
     "lock ", "repne ", "rep "
};

// Register name table
const char *reg_table[10][8] = {
    { "eax",  "ecx",  "edx",  "ebx",  "esp",  "ebp",  "esi",  "edi"  },
    { "ax",   "cx",   "dx",   "bx",   "sp",   "bp",   "si",   "di"   },
    { "al",   "cl",   "dl",   "bl",   "ah",   "ch",   "dh",   "bh"   },
    { "es",   "cs",   "ss",   "ds",   "fs",   "gs",   "seg6", "seg7" },
    { "dr0",  "dr1",  "dr2",  "dr3",  "dr4",  "dr5",  "dr6",  "dr7"  },
    { "cr0",  "cr1",  "cr2",  "cr3",  "cr4",  "cr5",  "cr6",  "cr7"  },
    { "tr0",  "tr1",  "tr2",  "tr3",  "tr4",  "tr5",  "tr6",  "tr7"  },
    { "xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7" },
    { "mm0",  "mm1",  "mm2",  "mm3",  "mm4",  "mm5",  "mm6",  "mm7"  },
    { "st(0)","st(1)","st(2)","st(3)","st(4)","st(5)","st(6)","st(7)"},
};

// Name table index
#define REG_GEN_DWORD 0
#define REG_GEN_WORD  1
#define REG_GEN_BYTE  2
#define REG_SEGMENT   3
#define REG_DEBUG     4
#define REG_CONTROL   5
#define REG_TEST      6
#define REG_XMM       7 
#define REG_MMX       8 
#define REG_FPU       9

// Opcode extensions for one -and two-byte opcodes
// XXX: move these to proper instruction structures ASAP!

const char * ext_name_table[16][8] = {
    { "add", "or", "adc", "sbb", "and", "sub", "xor", "cmp" },          // g1
    { "rol", "ror", "rcl", "rcr", "shl", "shr", NULL, "sar" },          // g2
    { "test", NULL, "not", "neg", "mul", "imul", "div", "idiv" },       // g3
    { "inc", "dec", NULL, NULL, NULL, NULL, NULL, NULL },               // g4
    { "inc", "dec", "call", "callf", "jmp", "jmpf", "push", NULL },     // g5
    { "sldt", "str", "lldt", "ltr", "verr", "verw", NULL, NULL },       // g6
    { "sgdt", "sidt", "lgdt", "lidt", "smsw", NULL, "lmsw", "invlpg" }, // g7
    { NULL, NULL, NULL, NULL, "bt", "bts", "btr", "btc" },              // g8
    { NULL, "cmpxch", NULL, NULL, NULL, NULL, NULL, NULL },             // g9
    { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL },                 // ga
    { "mov", NULL, NULL, NULL, NULL, NULL, NULL, NULL },                // gb
    { NULL, NULL, "psrlw", NULL, "psraw", NULL, "psllw", NULL },        // gc
    { NULL, NULL, "psrld", NULL, "psrad", NULL, "pslld", NULL },        // gd
    // XXX: if 2-byte extension, 4th and 8th are not defined..
    { NULL, NULL, "psrlq", "psrldq", NULL, NULL, "psllq", "pslldq" },   // gd
    { "fxsave", "fxrstor", "ldmxc5r", "stmxc5r", NULL, NULL, NULL, "sfence" }, // gf
    { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL },                 // g0
};

// Instruction types for extensions
// XXX: move these to proper instruction structures ASAP!

enum Instruction ext_type_table[16][8] = {
    { // g1
    INSTRUCTION_TYPE_ADD,   INSTRUCTION_TYPE_OR,
    INSTRUCTION_TYPE_ADC,   INSTRUCTION_TYPE_SBB,
    INSTRUCTION_TYPE_AND,   INSTRUCTION_TYPE_SUB,
    INSTRUCTION_TYPE_XOR,   INSTRUCTION_TYPE_CMP,
    },
    { // g2
    INSTRUCTION_TYPE_ROX,   INSTRUCTION_TYPE_ROX,
    INSTRUCTION_TYPE_ROX,   INSTRUCTION_TYPE_ROX,
    INSTRUCTION_TYPE_SHX,   INSTRUCTION_TYPE_SHX,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_SHX,
    },
    { // g3
    INSTRUCTION_TYPE_TEST,  INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_NOT,   INSTRUCTION_TYPE_NEG,
    INSTRUCTION_TYPE_MUL,   INSTRUCTION_TYPE_IMUL,
    INSTRUCTION_TYPE_DIV,   INSTRUCTION_TYPE_IDIV,
    },
    { // g4
    INSTRUCTION_TYPE_INC,   INSTRUCTION_TYPE_DEC,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    },
    { // g5
    INSTRUCTION_TYPE_INC,   INSTRUCTION_TYPE_DEC,
    INSTRUCTION_TYPE_CALL,  INSTRUCTION_TYPE_CALL,
    INSTRUCTION_TYPE_JMP,   INSTRUCTION_TYPE_JMP,
    INSTRUCTION_TYPE_PUSH,  INSTRUCTION_TYPE_OTHER,
    },
    { // g6
    INSTRUCTION_TYPE_SLDT,  INSTRUCTION_TYPE_PRIV,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    },
    { // g7
    INSTRUCTION_TYPE_SGDT,  INSTRUCTION_TYPE_SIDT,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    INSTRUCTION_TYPE_PRIV,  INSTRUCTION_TYPE_PRIV,
    },
    { // g8
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_BT,    INSTRUCTION_TYPE_BTS,
    INSTRUCTION_TYPE_BTR,   INSTRUCTION_TYPE_BTC,
    },
    { // g9
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    },
    { // ga
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    },
    { // gb
    INSTRUCTION_TYPE_MOV,   INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    },
    { // gc
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    },
    { // gd
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_OTHER,
    },
    { // ge
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_SSE,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_MMX,   INSTRUCTION_TYPE_SSE,
    },
    { // gf
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    },
    { // g0
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    INSTRUCTION_TYPE_OTHER, INSTRUCTION_TYPE_OTHER,
    }
};


// 1-byte opcodes
INST inst_table1[256] = {
    { INSTRUCTION_TYPE_ADD,   "add",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADD,   "add",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_ADD,   "add",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADD,   "add",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADD,   "add",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_ADD,   "add",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_ES|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_ES|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OR,    "or",       AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OR,    "or",       AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_OR,    "or",       AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OR,    "or",       AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OR,    "or",       AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OR,    "or",       AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_CS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    // Escape to 2-byte opcode table
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_ADC,   "adc",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_SS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_SS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SBB,   "sbb",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_DS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_DS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_AND,   "and",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_AND,   "and",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_AND,   "and",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_AND,   "and",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_AND,   "and",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_AND,   "and",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    // seg ES override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DCL,   "daa",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SUB,   "sub",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    // seg CS override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DCL,   "das",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XOR,   "xor",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    // seg SS override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_ASC,   "aaa",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CMP,   "cmp",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    // seg DS override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_ASC,   "aas",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_EAX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_ECX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_EDX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_EBX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_ESP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_EBP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_ESI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INC,   "inc",      AM_REG|REG_EDI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_EAX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_ECX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_EDX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_EBX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_ESP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_EBP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_ESI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_DEC,   "dec",      AM_REG|REG_EDI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_EAX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_ECX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_EDX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_EBX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_ESP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_EBP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_ESI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_EDI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_EAX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_ECX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_EDX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_EBX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_ESP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_EBP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_ESI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_EDI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH , "pusha",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "popa",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "bound",    AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_PRIV,  "arpl",     AM_E|OT_w,              AM_G|OT_w,            FLAGS_NONE,  1 },
    // seg FS override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    // seg GS override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // operand size override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // address size override
    { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_I|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_EIMUL, "imul",     AM_G|OT_v,              AM_E|OT_v,            AM_I|OT_v ,  1 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_I|OT_b|F_s,          FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_EIMUL, "imul",     AM_G|OT_v,              AM_E|OT_v,            AM_I|OT_b|F_s,  1 },
    { INSTRUCTION_TYPE_PRIV,  "insb",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "insv",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "outsb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "outsv",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jo",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jno",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jb",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnb",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jz",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnz",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jbe",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnbe",     AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "js",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jns",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jp",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnp",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jl",       AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnl",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jle",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnle",     AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "g1",       AM_E|OT_b,              AM_I|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g1",       AM_E|OT_v,              AM_I|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g1",       AM_E|OT_b,              AM_I|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g1",       AM_E|OT_v,              AM_I|OT_b|F_s,        FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_TEST,  "test",     AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_TEST,  "test",     AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_G|OT_b,              AM_E|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOVSR, "mov",      AM_E|OT_w,              AM_S|OT_w,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_LEA,   "lea",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOVSR, "mov",      AM_S|OT_w,              AM_E|OT_w,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "nop",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_ECX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_EDX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_EBX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_ESP|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_EBP|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_ESI|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_XCHG,  "xchg",     AM_REG|REG_EAX|OT_v,    AM_REG|REG_EDI|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "cbw",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "cwd",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CALL,  "callf",    AM_A|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "wait",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "pushf",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "popf",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "sahf",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "lahf",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EAX|OT_b,    AM_O|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EAX|OT_v,    AM_O|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_O|OT_v,              AM_REG|REG_EAX|OT_b,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_O|OT_v,              AM_REG|REG_EAX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOVS,  "movsb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOVS,  "movsd",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CMPS,  "cmpsb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CMPS,  "cmpsd",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_TEST,  "test",     AM_REG|REG_EAX|OT_b,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_TEST,  "test",     AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_STOS,  "stosb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_STOS,  "stosd",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LODS,  "lodsb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LODS,  "lodsd",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SCAS,  "scasb",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_SCAS,  "scasd",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_AL|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_CL|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_DL|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_BL|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_AH|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_CH|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_DH|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_BH|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EAX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_ECX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EDX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EBX|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_ESP|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EBP|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_ESI|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_REG|REG_EDI|OT_v,    AM_I|OT_v,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_b,              AM_I|OT_b,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_v,              AM_I|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_RET,   "retn",     AM_I|OT_w,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_RET,   "ret",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LFP,   "les",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_LFP,   "lds",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
    // XXX: prepare for group 11
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_E|OT_b,              AM_I|OT_b,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_MOV,   "mov",      AM_E|OT_v,              AM_I|OT_v,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "enter",    AM_I|OT_w,              AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "leave",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_RET,   "retf",     AM_I|OT_w,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "retf",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INT,   "int3",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_INT,   "int",      AM_I|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "into",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "iret",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_b,              AM_I1|OT_b,           FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_v,              AM_I1|OT_b,           FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_b,              AM_REG|REG_CL|OT_b,   FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_OTHER, "g2",       AM_E|OT_v,              AM_REG|REG_CL|OT_b,   FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_ASC,   "aam",      AM_I|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_ASC,   "aad",      AM_I|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    // XXX: undocumened?
    { INSTRUCTION_TYPE_OTHER, "salc",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "xlat",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "esc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LOOP,  "loopn",    AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LOOP,  "loope",    AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_LOOP,  "loop",     AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jcxz",     AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "in",       AM_REG|REG_AL|OT_b,     AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "in",       AM_REG|REG_EAX|OT_v,    AM_I|OT_b,            FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "out",      AM_I|OT_b,              AM_REG|REG_AL|OT_b,   FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "out",      AM_I|OT_b,              AM_REG|REG_EAX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_CALL,  "call",     AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMP,   "jmp",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMP,   "jmpf",     AM_A|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMP,   "jmp",      AM_J|OT_b,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "in",       AM_REG|REG_EAX|OT_b,    AM_REG|REG_EDX|OT_w,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "in",       AM_REG|REG_EAX|OT_v,    AM_REG|REG_EDX|OT_w,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "out",      AM_REG|REG_EDX|OT_w,    AM_REG|REG_EAX|OT_b,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "out",      AM_REG|REG_EDX|OT_w,    AM_REG|REG_EAX|OT_v,  FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "ext",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "int1",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "ext",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "ext",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PRIV,  "hlt",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "cmc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "g3",       AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_OTHER, "g3",       AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_OTHER, "clc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "stc",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "cli",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "sti",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "cld",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "std",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_OTHER, "g4",       AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
    // XXX: far call/jmp syntax in 16-bit mode
    { INSTRUCTION_TYPE_OTHER, "g5",       AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
};


// 2-byte instructions

INST inst_table2[256] = {
        { INSTRUCTION_TYPE_OTHER, "g6",       AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 },
    // XXX: smsw and lmsw in grp 7 use addressing mode E !!!
        { INSTRUCTION_TYPE_OTHER, "g7",       AM_M|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "lar",      AM_G|OT_v,              AM_E|OT_w,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "lsl",      AM_G|OT_v,              AM_E|OT_w,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // XXX: undocumented?
        { INSTRUCTION_TYPE_OTHER, "loadall286",FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "clts",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // XXX: undocumented?
        { INSTRUCTION_TYPE_OTHER, "loadall",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_PRIV,  "invd",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "wbinvd",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "ud2",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_SSE,   "movups",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movups",   AM_W|OT_ps,             AM_V|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movlps",   AM_V|OT_q,              AM_M|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movlps",   AM_M|OT_q,              AM_V|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "unpcklps", AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "unpcklps", AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movhps",   AM_V|OT_q,              AM_M|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movhps",   AM_M|OT_q,              AM_V|OT_ps,           FLAGS_NONE,  1 },
    // XXX: grp 16 (prefetch)
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_R|OT_d,              AM_C|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_R|OT_d,              AM_D|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_C|OT_d,              AM_R|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_D|OT_d,              AM_R|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_R|OT_d,              AM_T|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_PRIV,  "mov",      AM_T|OT_d,              AM_R|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_SSE,   "movaps",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movaps",   AM_W|OT_ps,             AM_V|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cvtpi2ps", AM_V|OT_ps,             AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movntps",  AM_M|OT_ps,             AM_V|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cvttps2pi",AM_P|OT_q,              AM_W|OT_q,          FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cvtps2pi", AM_P|OT_q,              AM_W|OT_q,          FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "ucomiss",  AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "comiss",   AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, "wrmsr",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "rdtsc",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_PRIV,  "rdmsr",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "rdpmc",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "sysenter", FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_PRIV,  "sysexit",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MOVC,  "cmovo",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovno",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovb",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovae",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmove",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovne",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovbe",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmova",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovs",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovns",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovp",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovnp",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovl",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovge",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovle",   AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVC,  "cmovg",    AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "movmskps", AM_G|OT_d,              AM_V|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "sqrtps",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "rsqrtps",  AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "rcpps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "andps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "andnps",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "orps",     AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "xorps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "addps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "mulps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cvtps2pd", AM_V|OT_pd,             AM_W|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cvtdq2ps", AM_V|OT_ps,             AM_W|OT_dq,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "subps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "minps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "divps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "maxps",    AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punpcklbw",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punpcklwd",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punockldq",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "packusdw", AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpgtb",  AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpgtw",  AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpgtd",  AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "packsswb", AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punpckhbw",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punpckhbd",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "punpckhdq",AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "packssdw", AM_P|OT_q,              AM_Q|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "movd",     AM_P|OT_d,              AM_E|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "movq",     AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pshufw",   AM_P|OT_q,              AM_Q|OT_q,            AM_I|OT_b,   1 },
    // groups 12-14
        { INSTRUCTION_TYPE_MMX,   "g12",      AM_P|OT_q,              AM_I|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "g13",      AM_P|OT_q,              AM_I|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "g14",      AM_P|OT_q,              AM_I|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpeqb",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpeqw",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pcmpeqd",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "emms",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "movd",     AM_E|OT_d,              AM_P|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "movq",     AM_Q|OT_q,              AM_P|OT_q,            FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_JMPC,  "jo",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jno",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jb",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnb",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jz",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnz",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jbe",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnbe",     AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "js",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jns",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jp",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnp",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jl",       AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnl",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jle",      AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_JMPC,  "jnle",     AM_J|OT_v,              FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_SETC,  "seto",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setno",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setb",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnb",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setz",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnz",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setbe",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnbe",   AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "sets",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setns",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setp",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnp",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setl",     AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnl",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setle",    AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SETC,  "setnle",   AM_E|OT_b,              FLAGS_NONE,           FLAGS_NONE,  1 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_FS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_FS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "cpuid",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BT,    "bt",       AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, "shld",     AM_E|OT_v,              AM_G|OT_v,            AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_OTHER, "shld",     AM_E|OT_v,              AM_G|OT_v,   AM_REG|REG_ECX|OT_b,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // XXX: ibts: undocumented? 
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_PUSH,  "push",     AM_REG|REG_GS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
    { INSTRUCTION_TYPE_POP,   "pop",      AM_REG|REG_GS|F_r,      FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "rsm",      FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BTS,   "bts",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, "shrd",     AM_E|OT_v,              AM_G|OT_v,            AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_OTHER, "shrd",     AM_E|OT_v,              AM_G|OT_v,  AM_REG|REG_ECX|OT_b,   1 },
    // XXX: check addressing mode, Intel manual is a little bit confusing...
        { INSTRUCTION_TYPE_OTHER, "grp15",    AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_EIMUL, "imul",     AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, "cmpxchg",  AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, "cmpxchg",  AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_LFP,   "lss",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_BTR,   "btr",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_LFP,   "lfs",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_LFP,   "lgs",      AM_G|OT_v,              AM_M|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVZX, "movzx",    AM_G|OT_v,              AM_E|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVZX, "movzx",    AM_G|OT_v,              AM_E|OT_w,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
    // XXX: group 10 / invalid opcode?
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, "g8",       AM_E|OT_v,              AM_I|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_BTC,   "btc",      AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_BSF,   "bsf",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_BSR,   "bsr",      AM_G|OT_v,              AM_E|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVSX, "movsx",    AM_G|OT_v,              AM_E|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MOVSX, "movsx",    AM_G|OT_v,              AM_E|OT_w,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_XADD,  "xadd",     AM_E|OT_b,              AM_G|OT_b,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_XADD,  "xadd",     AM_E|OT_v,              AM_G|OT_v,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "cmpps",    AM_V|OT_ps,             AM_W|OT_ps,           AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_OTHER, "movnti",   AM_M|OT_d,              AM_G|OT_d,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_SSE,   "pinsrw",   AM_P|OT_w,              AM_E|OT_w,            AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_SSE,   "pextrv",   AM_G|OT_w,              AM_P|OT_w,            AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_SSE,   "shufps",   AM_V|OT_ps,             AM_W|OT_ps,           AM_I|OT_b,   1 },
        { INSTRUCTION_TYPE_OTHER, "g9",       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_EAX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_ECX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_EDX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_EBX|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_ESP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_EBP|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_ESI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_BSWAP, "bswap",    AM_REG|REG_EDI|OT_v,    FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "psrlw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psrld",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psrlq",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddq",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmullw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "pmovmskb", AM_G|OT_q,              AM_P|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubusb",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubusw",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pminub",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pand",     AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddusb",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddusw",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmaxsw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pandn",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pavgb",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psraw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psrad",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pavgw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmulhuw",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmulhw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "movntq",   AM_M|OT_q,              AM_V|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubsb",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubsw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pminsw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "por",      AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddsb",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddsw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmaxsw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pxor",     AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
        { INSTRUCTION_TYPE_MMX,   "psllw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pslld",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psllq",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmuludq",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "pmaddwd",  AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psadbw",   AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
    // XXX: check operand types
        { INSTRUCTION_TYPE_MMX,   "maskmovq", AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubb",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubd",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "psubq",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddb",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddw",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_MMX,   "paddd",    AM_P|OT_q,              AM_Q|OT_q,            FLAGS_NONE,  1 },
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 },
};

// 3-byte instructions, prefix 0x66

// Yeah, I know, it's waste to use a full 256-instruction table but now
// I'm prepared for future Intel extensions ;-)

INST inst_table3_66[256] = {
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf
        { INSTRUCTION_TYPE_SSE,   "movupd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x10
        { INSTRUCTION_TYPE_SSE,   "movupd",   AM_W|OT_pd,             AM_V|OT_pd,           FLAGS_NONE,  1 }, // 0x11
        { INSTRUCTION_TYPE_SSE,   "movlpd",   AM_V|OT_q,              AM_M|OT_q,            FLAGS_NONE,  1 }, // 0x12
        { INSTRUCTION_TYPE_SSE,   "movlpd",   AM_M|OT_q,              AM_V|OT_q,            FLAGS_NONE,  1 }, // 0x13
        { INSTRUCTION_TYPE_SSE,   "unpcklpd", AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x14
        { INSTRUCTION_TYPE_SSE,   "unpcklpd", AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x15
        { INSTRUCTION_TYPE_SSE,   "movhpd",   AM_V|OT_q,              AM_M|OT_q,            FLAGS_NONE,  1 }, // 0x16
        { INSTRUCTION_TYPE_SSE,   "movhpd",   AM_M|OT_q,              AM_V|OT_pd,           FLAGS_NONE,  1 }, // 0x17
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x18
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x19
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x20
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x21
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x22
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x23
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x24
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x25
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x26
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x27
        { INSTRUCTION_TYPE_SSE,   "movapd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x28
        { INSTRUCTION_TYPE_SSE,   "movapd",   AM_W|OT_pd,             AM_V|OT_pd,           FLAGS_NONE,  1 }, // 0x29
        { INSTRUCTION_TYPE_SSE,   "cvtpi2pd", AM_V|OT_pd,             AM_Q|OT_q,            FLAGS_NONE,  1 }, // 0x2a
        { INSTRUCTION_TYPE_SSE,   "movntpd",  AM_M|OT_pd,             AM_V|OT_pd,           FLAGS_NONE,  1 }, // 0x2b
        { INSTRUCTION_TYPE_SSE,   "cvttpd2pi",AM_P|OT_q,              AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x2c
        { INSTRUCTION_TYPE_SSE,   "cvtpd2pi", AM_P|OT_q,              AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x2d
        { INSTRUCTION_TYPE_SSE,   "ucomisd",  AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x2e
        { INSTRUCTION_TYPE_SSE,   "comisd",   AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x2f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x30
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x31
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x32
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x33
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x34
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x35
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x36
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x37
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x38
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x39
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x40
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x41
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x42
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x43
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x44
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x45
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x46
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x47
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x48
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x49
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4f
        { INSTRUCTION_TYPE_SSE,   "movmskpd", AM_G|OT_d,              AM_V|OT_pd,           FLAGS_NONE,  1 }, // 0x50
        { INSTRUCTION_TYPE_SSE,   "sqrtpd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x51
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x52
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x53
        { INSTRUCTION_TYPE_SSE,   "andpd",    AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x54
        { INSTRUCTION_TYPE_SSE,   "andnpd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x55
        { INSTRUCTION_TYPE_SSE,   "orpd",     AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x56
        { INSTRUCTION_TYPE_SSE,   "xorpd",    AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x57
        { INSTRUCTION_TYPE_SSE,   "addpd",    AM_V|OT_pd,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x58
        { INSTRUCTION_TYPE_SSE,   "mulpd",    AM_V|OT_pd,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x59
        { INSTRUCTION_TYPE_SSE,   "cvtpd2ps", AM_V|OT_pd,             AM_W|OT_pd,            FLAGS_NONE,  1 }, // 0x5a
        { INSTRUCTION_TYPE_SSE,   "cvtps2dq", AM_V|OT_pd,             AM_W|OT_ps,            FLAGS_NONE,  1 }, // 0x5b
        { INSTRUCTION_TYPE_SSE,   "subpd",    AM_V|OT_pd,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x5c
        { INSTRUCTION_TYPE_SSE,   "minpd",    AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x5d
        { INSTRUCTION_TYPE_SSE,   "divpd",    AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x5e
        { INSTRUCTION_TYPE_SSE,   "maxpd",    AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x5f
        { INSTRUCTION_TYPE_SSE,   "punpcklbw",AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x60
        { INSTRUCTION_TYPE_SSE,   "punpcklwd",AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x61
        { INSTRUCTION_TYPE_SSE,   "punockldq",AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x62
        { INSTRUCTION_TYPE_SSE,   "packusdw", AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x63
        { INSTRUCTION_TYPE_SSE,   "pcmpgtb",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x64
        { INSTRUCTION_TYPE_SSE,   "pcmpgtw",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x65
        { INSTRUCTION_TYPE_SSE,   "pcmpgtd",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x66
        { INSTRUCTION_TYPE_SSE,   "packsswb", AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x67
        { INSTRUCTION_TYPE_SSE,   "punpckhbw",AM_V|OT_dq,             AM_Q|OT_dq,           FLAGS_NONE,  1 }, // 0x68
        { INSTRUCTION_TYPE_SSE,   "punpckhbd",AM_V|OT_dq,             AM_Q|OT_dq,           FLAGS_NONE,  1 }, // 0x69
        { INSTRUCTION_TYPE_SSE,   "punpckhdq",AM_V|OT_dq,             AM_Q|OT_dq,           FLAGS_NONE,  1 }, // 0x6a
        { INSTRUCTION_TYPE_SSE,   "packssdw", AM_V|OT_dq,             AM_Q|OT_dq,           FLAGS_NONE,  1 }, // 0x6b
        { INSTRUCTION_TYPE_SSE,   "punpcklqdq",AM_V|OT_dq,            AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x6c
        { INSTRUCTION_TYPE_SSE,   "punpckhqd",AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x6d
        { INSTRUCTION_TYPE_SSE,   "movd",     AM_V|OT_d,              AM_E|OT_dq,           FLAGS_NONE,  1 }, // 0x6e
        { INSTRUCTION_TYPE_SSE,   "movdqa",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x6f
        { INSTRUCTION_TYPE_SSE,   "pshufd",   AM_V|OT_dq,             AM_W|OT_dq,           AM_I|OT_b,   1 }, // 0x70
    // groups 12-14
        { INSTRUCTION_TYPE_SSE,   "g12",      AM_P|OT_dq,             AM_I|OT_b,            FLAGS_NONE,  1 }, // 0x71
        { INSTRUCTION_TYPE_SSE,   "g13",      AM_W|OT_dq,             AM_I|OT_b,            FLAGS_NONE,  1 }, // 0x72
        { INSTRUCTION_TYPE_SSE,   "g14",      AM_W|OT_dq,             AM_I|OT_b,            FLAGS_NONE,  1 }, // 0x73
        { INSTRUCTION_TYPE_SSE,   "pcmpeqb",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x74
        { INSTRUCTION_TYPE_SSE,   "pcmpeqw",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x75
        { INSTRUCTION_TYPE_SSE,   "pcmpeqd",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x76
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x77
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x78
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x79
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7a
        { INSTRUCTION_TYPE_MMX,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7b
        { INSTRUCTION_TYPE_SSE,   "haddpd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x7c
        { INSTRUCTION_TYPE_SSE,   "hsubpd",   AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0x7d
        { INSTRUCTION_TYPE_SSE,   "movd",     AM_E|OT_d,              AM_V|OT_d,            FLAGS_NONE,  1 }, // 0x7e
        { INSTRUCTION_TYPE_SSE,   "movdqa",   AM_W|OT_dq,             AM_V|OT_dq,           FLAGS_NONE,  1 }, // 0x7f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x80
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x81
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x82
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x83
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x84
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x85
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x86
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x87
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x88
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x89
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x90
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x91
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x92
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x93
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x94
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x95
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x96
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x97
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x98
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x99
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xab
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xac
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xad
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xae
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xba
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc1
        { INSTRUCTION_TYPE_SSE,   "cmppd",    AM_V|OT_pd,             AM_W|OT_pd,           AM_I|OT_b,   1 }, // 0xc2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc3
        { INSTRUCTION_TYPE_SSE,   "pinsrw",   AM_V|OT_w,              AM_E|OT_w,            AM_I|OT_b,   1 }, // 0xc4
        { INSTRUCTION_TYPE_SSE,   "pextrv",   AM_G|OT_w,              AM_V|OT_w,            AM_I|OT_b,   1 }, // 0xc5
        { INSTRUCTION_TYPE_SSE,   "shufpd",   AM_V|OT_pd,             AM_W|OT_pd,           AM_I|OT_b,   1 }, // 0xc6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xca
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xce
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcf
        { INSTRUCTION_TYPE_SSE,   "addsubpd", AM_V|OT_pd,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0xd0
        { INSTRUCTION_TYPE_SSE,   "psrlw",    AM_V|OT_dq,             AM_Q|OT_dq,           FLAGS_NONE,  1 }, // 0xd1
        { INSTRUCTION_TYPE_SSE,   "psrld",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd2
        { INSTRUCTION_TYPE_SSE,   "psrlq",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd3
        { INSTRUCTION_TYPE_SSE,   "paddq",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd4
        { INSTRUCTION_TYPE_SSE,   "pmullw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd5
        { INSTRUCTION_TYPE_SSE,   "movq",     AM_W|OT_q,              AM_V|OT_q,            FLAGS_NONE,  1 }, // 0xd6
        { INSTRUCTION_TYPE_SSE,   "pmovmskb", AM_G|OT_d,              AM_V|OT_dq,           FLAGS_NONE,  1 }, // 0xd7
        { INSTRUCTION_TYPE_SSE,   "psubusb",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd8
        { INSTRUCTION_TYPE_SSE,   "psubusw",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xd9
        { INSTRUCTION_TYPE_SSE,   "pminub",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xda
        { INSTRUCTION_TYPE_SSE,   "pand",     AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xdb
        { INSTRUCTION_TYPE_SSE,   "paddusb",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xdc
        { INSTRUCTION_TYPE_SSE,   "paddusw",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xdd
        { INSTRUCTION_TYPE_SSE,   "pmaxsw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xde
        { INSTRUCTION_TYPE_SSE,   "pandn",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xdf
        { INSTRUCTION_TYPE_SSE,   "pavgb",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe0
        { INSTRUCTION_TYPE_SSE,   "psraw",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe1
        { INSTRUCTION_TYPE_SSE,   "psrad",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe2
        { INSTRUCTION_TYPE_SSE,   "pavgw",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe3
        { INSTRUCTION_TYPE_SSE,   "pmulhuw",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe4
        { INSTRUCTION_TYPE_SSE,   "pmulhw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe5
        { INSTRUCTION_TYPE_SSE,   "cvttpd2dq",AM_V|OT_dq,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0xe6
        { INSTRUCTION_TYPE_SSE,   "movntq",   AM_M|OT_dq,             AM_V|OT_dq,           FLAGS_NONE,  1 }, // 0xe7
        { INSTRUCTION_TYPE_SSE,   "psubsb",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe8
        { INSTRUCTION_TYPE_SSE,   "psubsw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xe9
        { INSTRUCTION_TYPE_SSE,   "pminsw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xea
        { INSTRUCTION_TYPE_SSE,   "por",      AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xeb
        { INSTRUCTION_TYPE_SSE,   "paddsb",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xec
        { INSTRUCTION_TYPE_SSE,   "paddsw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xed
        { INSTRUCTION_TYPE_SSE,   "pmaxsw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xee
        { INSTRUCTION_TYPE_SSE,   "pxor",     AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xef
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf0
        { INSTRUCTION_TYPE_SSE,   "psllw",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf1
        { INSTRUCTION_TYPE_SSE,   "pslld",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf2
        { INSTRUCTION_TYPE_SSE,   "psllq",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf3
        { INSTRUCTION_TYPE_SSE,   "pmuludq",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf4
        { INSTRUCTION_TYPE_SSE,   "pmaddwd",  AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf5
        { INSTRUCTION_TYPE_SSE,   "psadbw",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf6
        { INSTRUCTION_TYPE_SSE,   "maskmovdqu",AM_V|OT_dq,            AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf7
        { INSTRUCTION_TYPE_SSE,   "psubb",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf8
        { INSTRUCTION_TYPE_SSE,   "psubw",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xf9
        { INSTRUCTION_TYPE_SSE,   "psubd",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xfa
        { INSTRUCTION_TYPE_SSE,   "psubq",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xfb
        { INSTRUCTION_TYPE_SSE,   "paddb",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xfc
        { INSTRUCTION_TYPE_SSE,   "paddw",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xfd
        { INSTRUCTION_TYPE_SSE,   "paddd",    AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0xfe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xff
}; 

// 3-byte instructions, prefix 0xf2

INST inst_table3_f2[256] = {
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf
        { INSTRUCTION_TYPE_SSE,   "movsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x10
        { INSTRUCTION_TYPE_SSE,   "movsd",    AM_W|OT_sd,             AM_V|OT_sd,           FLAGS_NONE,  1 }, // 0x11
        { INSTRUCTION_TYPE_SSE,   "movddup",  AM_V|OT_q,              AM_W|OT_q,            FLAGS_NONE,  1 }, // 0x12
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x13
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x14
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x15
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x16
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x17
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x18
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x19
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x20
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x21
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x22
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x23
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x24
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x25
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x26
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x27
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x28
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x29
        { INSTRUCTION_TYPE_SSE,   "cvtsi2sd", AM_V|OT_sd,             AM_E|OT_d,            FLAGS_NONE,  1 }, // 0x2a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2b
        { INSTRUCTION_TYPE_SSE,   "cvttsd2si",AM_G|OT_d,              AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x2c
        { INSTRUCTION_TYPE_SSE,   "cvtsd2si", AM_G|OT_d,              AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x2d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x30
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x31
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x32
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x33
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x34
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x35
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x36
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x37
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x38
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x39
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x40
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x41
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x42
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x43
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x44
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x45
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x46
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x47
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x48
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x49
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x50
        { INSTRUCTION_TYPE_SSE,   "sqrtsd",   AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x51
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x52
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x53
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x54
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x55
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x56
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x57
        { INSTRUCTION_TYPE_SSE,   "addsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x58
        { INSTRUCTION_TYPE_SSE,   "mulsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x59
        { INSTRUCTION_TYPE_SSE,   "cvtsd2ss", AM_V|OT_ss,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x5a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x5b
        { INSTRUCTION_TYPE_SSE,   "subsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x5c
        { INSTRUCTION_TYPE_SSE,   "minsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x5d
        { INSTRUCTION_TYPE_SSE,   "divsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x5e
        { INSTRUCTION_TYPE_SSE,   "maxsd",    AM_V|OT_sd,             AM_W|OT_sd,           FLAGS_NONE,  1 }, // 0x5f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x60
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x61
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x62
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x63
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x64
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x65
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x66
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x67
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x68
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x69
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6f
        { INSTRUCTION_TYPE_SSE,   "pshuflw",  AM_V|OT_dq,             AM_W|OT_dq,           AM_I|OT_b,   1 }, // 0x70
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x71
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x72
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x73
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x74
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x75
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x76
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x77
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x78
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x79
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7b
        { INSTRUCTION_TYPE_SSE,   "haddps",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x7c
        { INSTRUCTION_TYPE_SSE,   "hsubps",   AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x7d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x80
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x81
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x82
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x83
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x84
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x85
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x86
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x87
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x88
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x89
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x90
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x91
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x92
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x93
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x94
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x95
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x96
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x97
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x98
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x99
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xab
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xac
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xad
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xae
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xba
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc1
        { INSTRUCTION_TYPE_SSE,   "cmpsd",    AM_V|OT_sd,             AM_W|OT_sd,           AM_I|OT_b,   1 }, // 0xc2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xca
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xce
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcf
        { INSTRUCTION_TYPE_SSE,   "addsubpd", AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0xd0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd5
        { INSTRUCTION_TYPE_SSE,   "movdq2q",  AM_P|OT_q,              AM_V|OT_q,            FLAGS_NONE,  1 }, // 0xd6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xda
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xde
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe5
        { INSTRUCTION_TYPE_SSE,   "cvtpd2dq", AM_V|OT_dq,             AM_W|OT_pd,           FLAGS_NONE,  1 }, // 0xe6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xea
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xeb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xec
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xed
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xee
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xef
        { INSTRUCTION_TYPE_SSE,   "lddqu",    AM_V|OT_dq,             AM_M|OT_dq,           FLAGS_NONE,  1 }, // 0xf0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xff
}; 

// 3-byte instructions, prefix 0xf3

INST inst_table3_f3[256] = {
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf
        { INSTRUCTION_TYPE_SSE,   "movss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x10
        { INSTRUCTION_TYPE_SSE,   "movss",    AM_W|OT_ss,             AM_V|OT_ss,           FLAGS_NONE,  1 }, // 0x11
        { INSTRUCTION_TYPE_SSE,   "movsldup", AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x12
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x13
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x14
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x15
        { INSTRUCTION_TYPE_SSE,   "movshdup", AM_V|OT_ps,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x16
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x17
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x18
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x19
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x1f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x20
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x21
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x22
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x23
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x24
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x25
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x26
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x27
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x28
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x29
        { INSTRUCTION_TYPE_SSE,   "cvtsi2ss", AM_V|OT_ss,             AM_E|OT_d,            FLAGS_NONE,  1 }, // 0x2a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2b
        { INSTRUCTION_TYPE_SSE,   "cvttss2si",AM_G|OT_d,              AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x2c
        { INSTRUCTION_TYPE_SSE,   "cvtss2si", AM_G|OT_d,              AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x2d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x2f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x30
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x31
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x32
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x33
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x34
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x35
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x36
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x37
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x38
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x39
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x3f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x40
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x41
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x42
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x43
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x44
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x45
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x46
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x47
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x48
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x49
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x4f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x50
        { INSTRUCTION_TYPE_SSE,   "sqrtss",   AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x51
        { INSTRUCTION_TYPE_SSE,   "rsqrtss",  AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x52
        { INSTRUCTION_TYPE_SSE,   "rcpss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x53
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x54
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x55
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x56
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x57
        { INSTRUCTION_TYPE_SSE,   "addss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x58
        { INSTRUCTION_TYPE_SSE,   "mulss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x59
        { INSTRUCTION_TYPE_SSE,   "cvtsd2sd", AM_V|OT_sd,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x5a
        { INSTRUCTION_TYPE_SSE,   "cvttps2dq",AM_V|OT_dq,             AM_W|OT_ps,           FLAGS_NONE,  1 }, // 0x5b
        { INSTRUCTION_TYPE_SSE,   "subss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x5c
        { INSTRUCTION_TYPE_SSE,   "minss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x5d
        { INSTRUCTION_TYPE_SSE,   "divss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x5e
        { INSTRUCTION_TYPE_SSE,   "maxss",    AM_V|OT_ss,             AM_W|OT_ss,           FLAGS_NONE,  1 }, // 0x5f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x60
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x61
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x62
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x63
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x64
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x65
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x66
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x67
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x68
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x69
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x6e
        { INSTRUCTION_TYPE_SSE,   "movdqu",   AM_V|OT_dq,             AM_W|OT_dq,           AM_I|OT_b,   1 }, // 0x6f
        { INSTRUCTION_TYPE_SSE,   "pshufhw",  AM_V|OT_dq,             AM_W|OT_dq,           AM_I|OT_b,   1 }, // 0x70
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x71
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x72
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x73
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x74
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x75
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x76
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x77
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x78
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x79
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x7d
        { INSTRUCTION_TYPE_SSE,   "movq",     AM_V|OT_q,              AM_W|OT_q,            FLAGS_NONE,  1 }, // 0x7e
        { INSTRUCTION_TYPE_SSE,   "movdqu",   AM_V|OT_dq,             AM_W|OT_dq,           FLAGS_NONE,  1 }, // 0x7f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x80
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x81
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x82
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x83
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x84
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x85
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x86
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x87
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x88
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x89
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x8f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x90
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x91
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x92
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x93
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x94
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x95
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x96
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x97
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x98
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x99
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9a
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9b
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9c
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9d
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9e
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0x9f
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xa9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xab
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xac
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xad
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xae
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xaf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xb9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xba
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xbf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc1
        { INSTRUCTION_TYPE_SSE,   "cmpss",    AM_V|OT_ss,             AM_W|OT_ss,           AM_I|OT_b,   1 }, // 0xc2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xc9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xca
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xce
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xcf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd5
        { INSTRUCTION_TYPE_SSE,   "movq2dq",  AM_V|OT_dq,             AM_Q|OT_q,            FLAGS_NONE,  1 }, // 0xd6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xd9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xda
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xde
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xdf
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe5
        { INSTRUCTION_TYPE_SSE,   "cvtdq2pd", AM_V|OT_pd,             AM_W|OT_q,            FLAGS_NONE,  1 }, // 0xe6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xe9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xea
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xeb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xec
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xed
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xee
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xef
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf0
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf1
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf2
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf3
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf4
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf5
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf6
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf7
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf8
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xf9
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfa
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfb
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfc
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfd
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xfe
        { INSTRUCTION_TYPE_OTHER, NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, // 0xff
}; 


// Just a lame hack to provide additional arguments to group 3 "test"

INST inst_table_test[2] = {
    { INSTRUCTION_TYPE_TEST,  "test",     AM_E|OT_b,              AM_I|OT_b,            FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_TEST,  "test",     AM_E|OT_v,              AM_I|OT_v,            FLAGS_NONE,  1 }, 
};

// FPU instruction tables

/*
 * Tables are composed in two parts:
 *
 * - 1st part (index 0-7) are identified by the reg field of MODRM byte
 *   if the MODRM is < 0xc0. reg field can be used directly as an index to table.
 *
 * - 2nd part (8 - 0x47) are identified by the MODRM byte itself. In that case,
 *   the index can be calculated by "index = MODRM - 0xb8"
 *
 */
INST inst_table_fpu_d8[72] = {
    { INSTRUCTION_TYPE_FADD,  "fadds",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmuls",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcoms",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomps",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsubs",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubrs",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdivs",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivrs",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcom",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcomp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
};
INST inst_table_fpu_d9[72] = {
    { INSTRUCTION_TYPE_FLD,   "flds",     AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    // XXX: operand type is not correct
    { INSTRUCTION_TYPE_FPU,   "fldenv",   AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   "fldcw",    AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   "fstenv",   AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   "fstcw",    AM_E|OT_v,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fld",      AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FXCH,  "fxch",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fnop",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fchs",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fabs",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "ftst",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fxam",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fld1",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldl2t",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldl2e",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldpi",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldlg2",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldln2",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fldz",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "f2xm1",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fyl2x",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fptan",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fpatan",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fxtract",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fprem1",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fdecstp",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fincstp",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fprem",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fyl2xp1",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fsqrt",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fsincos",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "frndint",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fscale",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fsin",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fcos",     FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
};
INST inst_table_fpu_da[72] = {
    { INSTRUCTION_TYPE_FIADD, "fiaddl",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIMUL, "fimull",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FICOM, "ficoml",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FICOMP,"ficompl",  AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISUB, "fisubl",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISUBR,"fisubrl",  AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIDIV, "fidivl",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIDIVR,"fidivrl",  AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovb",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmove",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovbe",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovu",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucompp",  FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
};

// XXX: fsetpm??
INST inst_table_fpu_db[72] = {
    { INSTRUCTION_TYPE_FILD,  "fildl",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISTTP,"fisttp",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIST,  "fistl",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISTP, "fistp",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FLD,   "fldt",     AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstpl",    AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnb",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovne",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnbe", AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCMOVC,"fcmovnu",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fclex",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "finit",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMI,"fucomi",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMI, "fcomi",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
};
INST inst_table_fpu_dc[72] = {
    { INSTRUCTION_TYPE_FADD,  "faddl",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmull",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCOM,  "fcoml",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FCOMP, "fcompl",   AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsubl",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubrl",   AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdivl",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivrl",   AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADD,  "fadd",     AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMUL,  "fmul",     AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBR, "fsubr",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUB,  "fsub",     AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVR, "fdivr",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIV,  "fdiv",     AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
};
INST inst_table_fpu_dd[72] = {
    { INSTRUCTION_TYPE_FLD,   "fldl",     AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISTTP,"fisttp",   AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FST,   "fstl",     AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstpl",    AM_E|OT_q,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    // XXX: operand type is not exactly right..
    { INSTRUCTION_TYPE_FPU,   "frstor",   AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    // XXX: operand type is not exactly right..
    { INSTRUCTION_TYPE_FPU,   "fsave",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    // XXX: operand type is not exactly right..
    { INSTRUCTION_TYPE_FPU,   "fstsw",    AM_E|OT_d,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST0|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST1|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST2|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST3|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST4|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST5|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST6|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREE, "ffree",    AM_REG|REG_ST7|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST0|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST1|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST2|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST3|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST4|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST5|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST6|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FST,   "fst",      AM_REG|REG_ST7|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST0|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST1|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST2|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST3|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST4|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST5|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST6|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSTP,  "fstp",     AM_REG|REG_ST7|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOM, "fucom",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST0|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST1|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST2|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST3|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST4|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST5|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST6|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMP,"fucomp",   AM_REG|REG_ST7|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
};
INST inst_table_fpu_de[72] = {
    { INSTRUCTION_TYPE_FIADD, "fiadd",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIMUL, "fimul",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FICOM, "ficom",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FICOMP,"ficomp",   AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISUB, "fisub",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISUBR,"fisubr",   AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIDIV, "fidiv",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIDIVR,"fidivr",   AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FADDP, "faddp",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FMULP, "fmulp",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMPP,"fcompp",   FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBRP,"fsubrp",   AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FSUBP, "fsubp",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVRP,"fdivrp",   AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST1|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST2|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST3|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST4|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST5|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST6|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FDIVP, "fdivp",    AM_REG|REG_ST7|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
};

INST inst_table_fpu_df[72] = {
    { INSTRUCTION_TYPE_FILD,  "fild",     AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    // fisttp: IA-32 2004
    { INSTRUCTION_TYPE_FISTTP,"fisttp",   AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FIST,  "fist",     AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISTP, "fistp",    AM_E|OT_w,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   "fbld",     AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FILD,  "fild",     AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FPU,   "fbstp",    AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    { INSTRUCTION_TYPE_FISTP, "fistp",    AM_E|OT_t,              FLAGS_NONE,           FLAGS_NONE,  1 }, 
    // ffreep undocumented!!
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST0|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST1|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST2|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST3|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST4|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST5|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST6|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FFREEP,"ffreep",   AM_REG|REG_ST7|F_f,     FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   "fstsw",    FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FUCOMIP,"fucomip",  AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST0|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST1|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST2|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST3|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST4|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST5|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST6|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FCOMIP,"fcomip",   AM_REG|REG_ST0|F_f,     AM_REG|REG_ST7|F_f,   FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
    { INSTRUCTION_TYPE_FPU,   NULL,       FLAGS_NONE,             FLAGS_NONE,           FLAGS_NONE,  0 }, 
};

// Table of FPU instruction tables

/*
 * These tables are accessed by the following way:
 *
 * INST *fpuinst = inst_table4[opcode - 0xd8][index];
 * where index is determined by the MODRM byte.
 *
 */
INST * inst_table4[8] = {
    inst_table_fpu_d8,
    inst_table_fpu_d9,
    inst_table_fpu_da,
    inst_table_fpu_db,
    inst_table_fpu_dc,
    inst_table_fpu_dd,
    inst_table_fpu_de,
    inst_table_fpu_df,
};

