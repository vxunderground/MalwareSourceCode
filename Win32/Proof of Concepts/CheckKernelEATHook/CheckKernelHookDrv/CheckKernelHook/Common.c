#include "Common.h"
#include "Reload.h"



UCHAR OpcodeFlags[256] = 
{
    OP_MODRM,                      // 00
    OP_MODRM,                      // 01
    OP_MODRM,                      // 02
    OP_MODRM,                      // 03
    OP_DATA_I8,                    // 04
    OP_DATA_PRE66_67,              // 05
    OP_NONE,                       // 06
    OP_NONE,                       // 07
    OP_MODRM,                      // 08
    OP_MODRM,                      // 09
    OP_MODRM,                      // 0A
    OP_MODRM,                      // 0B
    OP_DATA_I8,                    // 0C
    OP_DATA_PRE66_67,              // 0D
    OP_NONE,                       // 0E
    OP_NONE,                       // 0F
    OP_MODRM,                      // 10
    OP_MODRM,                      // 11
    OP_MODRM,                      // 12
    OP_MODRM,                      // 13
    OP_DATA_I8,                    // 14
    OP_DATA_PRE66_67,              // 15
    OP_NONE,                       // 16
    OP_NONE,                       // 17
    OP_MODRM,                      // 18
    OP_MODRM,                      // 19
    OP_MODRM,                      // 1A
    OP_MODRM,                      // 1B
    OP_DATA_I8,                    // 1C
    OP_DATA_PRE66_67,              // 1D
    OP_NONE,                       // 1E
    OP_NONE,                       // 1F
    OP_MODRM,                      // 20
    OP_MODRM,                      // 21
    OP_MODRM,                      // 22
    OP_MODRM,                      // 23
    OP_DATA_I8,                    // 24
    OP_DATA_PRE66_67,              // 25
    OP_NONE,                       // 26
    OP_NONE,                       // 27
    OP_MODRM,                      // 28
    OP_MODRM,                      // 29
    OP_MODRM,                      // 2A
    OP_MODRM,                      // 2B
    OP_DATA_I8,                    // 2C
    OP_DATA_PRE66_67,              // 2D
    OP_NONE,                       // 2E
    OP_NONE,                       // 2F
    OP_MODRM,                      // 30
    OP_MODRM,                      // 31
    OP_MODRM,                      // 32
    OP_MODRM,                      // 33
    OP_DATA_I8,                    // 34
    OP_DATA_PRE66_67,              // 35
    OP_NONE,                       // 36
    OP_NONE,                       // 37
    OP_MODRM,                      // 38
    OP_MODRM,                      // 39
    OP_MODRM,                      // 3A
    OP_MODRM,                      // 3B
    OP_DATA_I8,                    // 3C
    OP_DATA_PRE66_67,              // 3D
    OP_NONE,                       // 3E
    OP_NONE,                       // 3F
    OP_NONE,                       // 40
    OP_NONE,                       // 41
    OP_NONE,                       // 42
    OP_NONE,                       // 43
    OP_NONE,                       // 44
    OP_NONE,                       // 45
    OP_NONE,                       // 46
    OP_NONE,                       // 47
    OP_NONE,                       // 48
    OP_NONE,                       // 49
    OP_NONE,                       // 4A
    OP_NONE,                       // 4B
    OP_NONE,                       // 4C
    OP_NONE,                       // 4D
    OP_NONE,                       // 4E
    OP_NONE,                       // 4F
    OP_NONE,                       // 50
    OP_NONE,                       // 51
    OP_NONE,                       // 52
    OP_NONE,                       // 53
    OP_NONE,                       // 54
    OP_NONE,                       // 55
    OP_NONE,                       // 56
    OP_NONE,                       // 57
    OP_NONE,                       // 58
    OP_NONE,                       // 59
    OP_NONE,                       // 5A
    OP_NONE,                       // 5B
    OP_NONE,                       // 5C
    OP_NONE,                       // 5D
    OP_NONE,                       // 5E
    OP_NONE,                       // 5F
    OP_NONE,                       // 60
    OP_NONE,                       // 61
    OP_MODRM,                      // 62
    OP_MODRM,                      // 63
    OP_NONE,                       // 64
    OP_NONE,                       // 65
    OP_NONE,                       // 66
    OP_NONE,                       // 67
    OP_DATA_PRE66_67,              // 68
    OP_MODRM | OP_DATA_PRE66_67,   // 69
    OP_DATA_I8,                    // 6A
    OP_MODRM | OP_DATA_I8,         // 6B
    OP_NONE,                       // 6C
    OP_NONE,                       // 6D
    OP_NONE,                       // 6E
    OP_NONE,                       // 6F
    OP_DATA_I8,                    // 70
    OP_DATA_I8,                    // 71
    OP_DATA_I8,                    // 72
    OP_DATA_I8,                    // 73
    OP_DATA_I8,                    // 74
    OP_DATA_I8,                    // 75
    OP_DATA_I8,                    // 76
    OP_DATA_I8,                    // 77
    OP_DATA_I8,                    // 78
    OP_DATA_I8,                    // 79
    OP_DATA_I8,                    // 7A
    OP_DATA_I8,                    // 7B
    OP_DATA_I8,                    // 7C
    OP_DATA_I8,                    // 7D
    OP_DATA_I8,                    // 7E
    OP_DATA_I8,                    // 7F
    OP_MODRM | OP_DATA_I8,         // 80
    OP_MODRM | OP_DATA_PRE66_67,   // 81
    OP_MODRM | OP_DATA_I8,         // 82
    OP_MODRM | OP_DATA_I8,         // 83
    OP_MODRM,                      // 84
    OP_MODRM,                      // 85
    OP_MODRM,                      // 86
    OP_MODRM,                      // 87
    OP_MODRM,                      // 88
    OP_MODRM,                      // 89
    OP_MODRM,                      // 8A
    OP_MODRM,                      // 8B
    OP_MODRM,                      // 8C
    OP_MODRM,                      // 8D
    OP_MODRM,                      // 8E
    OP_MODRM,                      // 8F
    OP_NONE,                       // 90
    OP_NONE,                       // 91
    OP_NONE,                       // 92
    OP_NONE,                       // 93
    OP_NONE,                       // 94
    OP_NONE,                       // 95
    OP_NONE,                       // 96
    OP_NONE,                       // 97
    OP_NONE,                       // 98
    OP_NONE,                       // 99
    OP_DATA_I16 | OP_DATA_PRE66_67,// 9A
    OP_NONE,                       // 9B
    OP_NONE,                       // 9C
    OP_NONE,                       // 9D
    OP_NONE,                       // 9E
    OP_NONE,                       // 9F
    OP_DATA_PRE66_67,              // A0
    OP_DATA_PRE66_67,              // A1
    OP_DATA_PRE66_67,              // A2
    OP_DATA_PRE66_67,              // A3
    OP_NONE,                       // A4
    OP_NONE,                       // A5
    OP_NONE,                       // A6
    OP_NONE,                       // A7
    OP_DATA_I8,                    // A8
    OP_DATA_PRE66_67,              // A9
    OP_NONE,                       // AA
    OP_NONE,                       // AB
    OP_NONE,                       // AC
    OP_NONE,                       // AD
    OP_NONE,                       // AE
    OP_NONE,                       // AF
    OP_DATA_I8,                    // B0
    OP_DATA_I8,                    // B1
    OP_DATA_I8,                    // B2
    OP_DATA_I8,                    // B3
    OP_DATA_I8,                    // B4
    OP_DATA_I8,                    // B5
    OP_DATA_I8,                    // B6
    OP_DATA_I8,                    // B7
    OP_DATA_PRE66_67,              // B8
    OP_DATA_PRE66_67,              // B9
    OP_DATA_PRE66_67,              // BA
    OP_DATA_PRE66_67,              // BB
    OP_DATA_PRE66_67,              // BC
    OP_DATA_PRE66_67,              // BD
    OP_DATA_PRE66_67,              // BE
    OP_DATA_PRE66_67,              // BF
    OP_MODRM | OP_DATA_I8,         // C0
    OP_MODRM | OP_DATA_I8,         // C1
    OP_DATA_I16,                   // C2
    OP_NONE,                       // C3
    OP_MODRM,                      // C4
    OP_MODRM,                      // C5
    OP_MODRM   | OP_DATA_I8,       // C6
    OP_MODRM   | OP_DATA_PRE66_67, // C7
    OP_DATA_I8 | OP_DATA_I16,      // C8
    OP_NONE,                       // C9
    OP_DATA_I16,                   // CA
    OP_NONE,                       // CB
    OP_NONE,                       // CC
    OP_DATA_I8,                    // CD
    OP_NONE,                       // CE
    OP_NONE,                       // CF
    OP_MODRM,                      // D0
    OP_MODRM,                      // D1
    OP_MODRM,                      // D2
    OP_MODRM,                      // D3
    OP_DATA_I8,                    // D4
    OP_DATA_I8,                    // D5
    OP_NONE,                       // D6
    OP_NONE,                       // D7
    OP_WORD,                       // D8
    OP_WORD,                       // D9
    OP_WORD,                       // DA
    OP_WORD,                       // DB
    OP_WORD,                       // DC
    OP_WORD,                       // DD
    OP_WORD,                       // DE
    OP_WORD,                       // DF
    OP_DATA_I8,                    // E0
    OP_DATA_I8,                    // E1
    OP_DATA_I8,                    // E2
    OP_DATA_I8,                    // E3
    OP_DATA_I8,                    // E4
    OP_DATA_I8,                    // E5
    OP_DATA_I8,                    // E6
    OP_DATA_I8,                    // E7
    OP_DATA_PRE66_67 | OP_REL32,   // E8
    OP_DATA_PRE66_67 | OP_REL32,   // E9
    OP_DATA_I16 | OP_DATA_PRE66_67,// EA
    OP_DATA_I8,                    // EB
    OP_NONE,                       // EC
    OP_NONE,                       // ED
    OP_NONE,                       // EE
    OP_NONE,                       // EF
    OP_NONE,                       // F0
    OP_NONE,                       // F1
    OP_NONE,                       // F2
    OP_NONE,                       // F3
    OP_NONE,                       // F4
    OP_NONE,                       // F5
    OP_MODRM,                      // F6
    OP_MODRM,                      // F7
    OP_NONE,                       // F8
    OP_NONE,                       // F9
    OP_NONE,                       // FA
    OP_NONE,                       // FB
    OP_NONE,                       // FC
    OP_NONE,                       // FD
    OP_MODRM,                      // FE
    OP_MODRM | OP_REL32            // FF
};

UCHAR OpcodeFlagsExt[256] =
{
    OP_MODRM,                      // 00
    OP_MODRM,                      // 01
    OP_MODRM,                      // 02
    OP_MODRM,                      // 03
    OP_NONE,                       // 04
    OP_NONE,                       // 05
    OP_NONE,                       // 06
    OP_NONE,                       // 07
    OP_NONE,                       // 08
    OP_NONE,                       // 09
    OP_NONE,                       // 0A
    OP_NONE,                       // 0B
    OP_NONE,                       // 0C
    OP_MODRM,                      // 0D
    OP_NONE,                       // 0E
    OP_MODRM | OP_DATA_I8,         // 0F
    OP_MODRM,                      // 10
    OP_MODRM,                      // 11
    OP_MODRM,                      // 12
    OP_MODRM,                      // 13
    OP_MODRM,                      // 14
    OP_MODRM,                      // 15
    OP_MODRM,                      // 16
    OP_MODRM,                      // 17
    OP_MODRM,                      // 18
    OP_NONE,                       // 19
    OP_NONE,                       // 1A
    OP_NONE,                       // 1B
    OP_NONE,                       // 1C
    OP_NONE,                       // 1D
    OP_NONE,                       // 1E
    OP_NONE,                       // 1F
    OP_MODRM,                      // 20
    OP_MODRM,                      // 21
    OP_MODRM,                      // 22
    OP_MODRM,                      // 23
    OP_MODRM,                      // 24
    OP_NONE,                       // 25
    OP_MODRM,                      // 26
    OP_NONE,                       // 27
    OP_MODRM,                      // 28
    OP_MODRM,                      // 29
    OP_MODRM,                      // 2A
    OP_MODRM,                      // 2B
    OP_MODRM,                      // 2C
    OP_MODRM,                      // 2D
    OP_MODRM,                      // 2E
    OP_MODRM,                      // 2F
    OP_NONE,                       // 30
    OP_NONE,                       // 31
    OP_NONE,                       // 32
    OP_NONE,                       // 33
    OP_NONE,                       // 34
    OP_NONE,                       // 35
    OP_NONE,                       // 36
    OP_NONE,                       // 37
    OP_NONE,                       // 38
    OP_NONE,                       // 39
    OP_NONE,                       // 3A
    OP_NONE,                       // 3B
    OP_NONE,                       // 3C
    OP_NONE,                       // 3D
    OP_NONE,                       // 3E
    OP_NONE,                       // 3F
    OP_MODRM,                      // 40
    OP_MODRM,                      // 41
    OP_MODRM,                      // 42
    OP_MODRM,                      // 43
    OP_MODRM,                      // 44
    OP_MODRM,                      // 45
    OP_MODRM,                      // 46
    OP_MODRM,                      // 47
    OP_MODRM,                      // 48
    OP_MODRM,                      // 49
    OP_MODRM,                      // 4A
    OP_MODRM,                      // 4B
    OP_MODRM,                      // 4C
    OP_MODRM,                      // 4D
    OP_MODRM,                      // 4E
    OP_MODRM,                      // 4F
    OP_MODRM,                      // 50
    OP_MODRM,                      // 51
    OP_MODRM,                      // 52
    OP_MODRM,                      // 53
    OP_MODRM,                      // 54
    OP_MODRM,                      // 55
    OP_MODRM,                      // 56
    OP_MODRM,                      // 57
    OP_MODRM,                      // 58
    OP_MODRM,                      // 59
    OP_MODRM,                      // 5A
    OP_MODRM,                      // 5B
    OP_MODRM,                      // 5C
    OP_MODRM,                      // 5D
    OP_MODRM,                      // 5E
    OP_MODRM,                      // 5F
    OP_MODRM,                      // 60
    OP_MODRM,                      // 61
    OP_MODRM,                      // 62
    OP_MODRM,                      // 63
    OP_MODRM,                      // 64
    OP_MODRM,                      // 65
    OP_MODRM,                      // 66
    OP_MODRM,                      // 67
    OP_MODRM,                      // 68
    OP_MODRM,                      // 69
    OP_MODRM,                      // 6A
    OP_MODRM,                      // 6B
    OP_MODRM,                      // 6C
    OP_MODRM,                      // 6D
    OP_MODRM,                      // 6E
    OP_MODRM,                      // 6F
    OP_MODRM | OP_DATA_I8,         // 70
    OP_MODRM | OP_DATA_I8,         // 71
    OP_MODRM | OP_DATA_I8,         // 72
    OP_MODRM | OP_DATA_I8,         // 73
    OP_MODRM,                      // 74
    OP_MODRM,                      // 75
    OP_MODRM,                      // 76
    OP_NONE,                       // 77
    OP_NONE,                       // 78
    OP_NONE,                       // 79
    OP_NONE,                       // 7A
    OP_NONE,                       // 7B
    OP_MODRM,                      // 7C
    OP_MODRM,                      // 7D
    OP_MODRM,                      // 7E
    OP_MODRM,                      // 7F
    OP_DATA_PRE66_67 | OP_REL32,   // 80
    OP_DATA_PRE66_67 | OP_REL32,   // 81
    OP_DATA_PRE66_67 | OP_REL32,   // 82
    OP_DATA_PRE66_67 | OP_REL32,   // 83
    OP_DATA_PRE66_67 | OP_REL32,   // 84
    OP_DATA_PRE66_67 | OP_REL32,   // 85
    OP_DATA_PRE66_67 | OP_REL32,   // 86
    OP_DATA_PRE66_67 | OP_REL32,   // 87
    OP_DATA_PRE66_67 | OP_REL32,   // 88
    OP_DATA_PRE66_67 | OP_REL32,   // 89
    OP_DATA_PRE66_67 | OP_REL32,   // 8A
    OP_DATA_PRE66_67 | OP_REL32,   // 8B
    OP_DATA_PRE66_67 | OP_REL32,   // 8C
    OP_DATA_PRE66_67 | OP_REL32,   // 8D
    OP_DATA_PRE66_67 | OP_REL32,   // 8E
    OP_DATA_PRE66_67 | OP_REL32,   // 8F
    OP_MODRM,                      // 90
    OP_MODRM,                      // 91
    OP_MODRM,                      // 92
    OP_MODRM,                      // 93
    OP_MODRM,                      // 94
    OP_MODRM,                      // 95
    OP_MODRM,                      // 96
    OP_MODRM,                      // 97
    OP_MODRM,                      // 98
    OP_MODRM,                      // 99
    OP_MODRM,                      // 9A
    OP_MODRM,                      // 9B
    OP_MODRM,                      // 9C
    OP_MODRM,                      // 9D
    OP_MODRM,                      // 9E
    OP_MODRM,                      // 9F
    OP_NONE,                       // A0
    OP_NONE,                       // A1
    OP_NONE,                       // A2
    OP_MODRM,                      // A3
    OP_MODRM | OP_DATA_I8,         // A4
    OP_MODRM,                      // A5
    OP_NONE,                       // A6
    OP_NONE,                       // A7
    OP_NONE,                       // A8
    OP_NONE,                       // A9
    OP_NONE,                       // AA
    OP_MODRM,                      // AB
    OP_MODRM | OP_DATA_I8,         // AC
    OP_MODRM,                      // AD
    OP_MODRM,                      // AE
    OP_MODRM,                      // AF
    OP_MODRM,                      // B0
    OP_MODRM,                      // B1
    OP_MODRM,                      // B2
    OP_MODRM,                      // B3
    OP_MODRM,                      // B4
    OP_MODRM,                      // B5
    OP_MODRM,                      // B6
    OP_MODRM,                      // B7
    OP_NONE,                       // B8
    OP_NONE,                       // B9
    OP_MODRM | OP_DATA_I8,         // BA
    OP_MODRM,                      // BB
    OP_MODRM,                      // BC
    OP_MODRM,                      // BD
    OP_MODRM,                      // BE
    OP_MODRM,                      // BF
    OP_MODRM,                      // C0
    OP_MODRM,                      // C1
    OP_MODRM | OP_DATA_I8,         // C2
    OP_MODRM,                      // C3
    OP_MODRM | OP_DATA_I8,         // C4
    OP_MODRM | OP_DATA_I8,         // C5
    OP_MODRM | OP_DATA_I8,         // C6 
    OP_MODRM,                      // C7
    OP_NONE,                       // C8
    OP_NONE,                       // C9
    OP_NONE,                       // CA
    OP_NONE,                       // CB
    OP_NONE,                       // CC
    OP_NONE,                       // CD
    OP_NONE,                       // CE
    OP_NONE,                       // CF
    OP_MODRM,                      // D0
    OP_MODRM,                      // D1
    OP_MODRM,                      // D2
    OP_MODRM,                      // D3
    OP_MODRM,                      // D4
    OP_MODRM,                      // D5
    OP_MODRM,                      // D6
    OP_MODRM,                      // D7
    OP_MODRM,                      // D8
    OP_MODRM,                      // D9
    OP_MODRM,                      // DA
    OP_MODRM,                      // DB
    OP_MODRM,                      // DC
    OP_MODRM,                      // DD
    OP_MODRM,                      // DE
    OP_MODRM,                      // DF
    OP_MODRM,                      // E0
    OP_MODRM,                      // E1
    OP_MODRM,                      // E2
    OP_MODRM,                      // E3
    OP_MODRM,                      // E4
    OP_MODRM,                      // E5
    OP_MODRM,                      // E6
    OP_MODRM,                      // E7
    OP_MODRM,                      // E8
    OP_MODRM,                      // E9
    OP_MODRM,                      // EA
    OP_MODRM,                      // EB
    OP_MODRM,                      // EC
    OP_MODRM,                      // ED
    OP_MODRM,                      // EE
    OP_MODRM,                      // EF
    OP_MODRM,                      // F0
    OP_MODRM,                      // F1
    OP_MODRM,                      // F2
    OP_MODRM,                      // F3
    OP_MODRM,                      // F4
    OP_MODRM,                      // F5
    OP_MODRM,                      // F6
    OP_MODRM,                      // F7 
    OP_MODRM,                      // F8
    OP_MODRM,                      // F9
    OP_MODRM,                      // FA
    OP_MODRM,                      // FB
    OP_MODRM,                      // FC
    OP_MODRM,                      // FD
    OP_MODRM,                      // FE
    OP_NONE                        // FF
};


NTSTATUS 
    MapFileInUserSpace(WCHAR* wzFilePath,IN HANDLE hProcess OPTIONAL,
    OUT PVOID *BaseAddress,
    OUT PSIZE_T ViewSize OPTIONAL)
{
    NTSTATUS Status = STATUS_INVALID_PARAMETER;
    HANDLE   hFile = NULL;
    HANDLE   hSection = NULL;
    OBJECT_ATTRIBUTES oa;
    SIZE_T MapViewSize = 0;
    IO_STATUS_BLOCK Iosb;
    UNICODE_STRING uniFilePath;
    if (!wzFilePath || !BaseAddress){
        return Status;
    }
    RtlInitUnicodeString(&uniFilePath, wzFilePath);
    InitializeObjectAttributes(&oa,
        &uniFilePath,
        OBJ_CASE_INSENSITIVE | OBJ_KERNEL_HANDLE,
        NULL,
        NULL
        );
    Status = IoCreateFile(&hFile,
        GENERIC_READ | SYNCHRONIZE,
        &oa,
        &Iosb,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        FILE_SHARE_READ,
        FILE_OPEN,
        FILE_SYNCHRONOUS_IO_NONALERT,
        NULL,
        0,
        CreateFileTypeNone,
        NULL,
        IO_NO_PARAMETER_CHECKING
        );
    if (!NT_SUCCESS(Status))
    {
        return Status;
    }
    oa.ObjectName = NULL;
    Status = ZwCreateSection(&hSection,
        SECTION_QUERY | SECTION_MAP_READ,
        &oa,
        NULL,
        PAGE_WRITECOPY,
        SEC_IMAGE,
        hFile
        );
    ZwClose(hFile);
    if (!NT_SUCCESS(Status))
    {
        return Status;
    }
    if (!hProcess){
        hProcess = NtCurrentProcess();
    }
    Status = ZwMapViewOfSection(hSection, 
        hProcess, 
        BaseAddress, 
        0, 
        0, 
        0, 
        ViewSize ? ViewSize : &MapViewSize, 
        ViewUnmap, 
        0, 
        PAGE_WRITECOPY
        );
    ZwClose(hSection);
    if (!NT_SUCCESS(Status))
    {
        return Status;
    }
    return Status;
}




//通过指令获得函数大小
unsigned long __fastcall GetFunctionCodeSize(void *Proc)
{
    ULONG  Length;
    PUCHAR pOpcode;
    ULONG  Result = 0;
    ULONG CCINT3Count=0;
    do
    {
        Length = SizeOfCode(Proc, &pOpcode);
        Result += Length;
        if ((Length == 1) && (*pOpcode == 0xCC||*pOpcode==0x90)) CCINT3Count++;
        if (CCINT3Count>1 ||
            *pOpcode == 0x00)
        {
            break;  //判断退出指令
        }
        Proc = (PVOID)((ULONG)Proc + Length);
    } while (Length);
    return Result;
}

unsigned long __fastcall SizeOfCode(void *Code, unsigned char **pOpcode)
{
    PUCHAR cPtr;
    UCHAR Flags;
    BOOLEAN PFX66, PFX67;
    BOOLEAN SibPresent;
    UCHAR iMod, iRM, iReg;
    UCHAR OffsetSize, Add;
    UCHAR Opcode;

    OffsetSize = 0;
    PFX66 = FALSE;
    PFX67 = FALSE;
    cPtr = (PUCHAR)Code;

    while ((*cPtr == 0x2E) || (*cPtr == 0x3E) || (*cPtr == 0x36) ||
        (*cPtr == 0x26) || (*cPtr == 0x64) || (*cPtr == 0x65) || 
        (*cPtr == 0xF0) || (*cPtr == 0xF2) || (*cPtr == 0xF3) ||
        (*cPtr == 0x66) || (*cPtr == 0x67)) 
    {
        if (*cPtr == 0x66) PFX66 = TRUE;
        if (*cPtr == 0x67) PFX67 = TRUE;
        cPtr++;
        if (cPtr > (PUCHAR)Code + 16) return 0; 
    }
    Opcode = *cPtr;
    if (pOpcode) *pOpcode = cPtr; 
    if (*cPtr == 0x0F)
    {
        cPtr++;
        Flags = OpcodeFlagsExt[*cPtr];
    } else 
    {
        Flags = OpcodeFlags[Opcode];
        if (Opcode >= 0xA0 && Opcode <= 0xA3) PFX66 = PFX67;
    }
    cPtr++;
    if (Flags & OP_WORD) cPtr++;    
    if (Flags & OP_MODRM)
    {
        iMod = *cPtr >> 6;
        iReg = (*cPtr & 0x38) >> 3;  
        iRM  = *cPtr &  7;
        cPtr++;

        if ((Opcode == 0xF6) && !iReg) Flags |= OP_DATA_I8;    
        if ((Opcode == 0xF7) && !iReg) Flags |= OP_DATA_PRE66_67; 

        SibPresent = !PFX67 & (iRM == 4);
        switch (iMod)
        {
        case 0: 
            if ( PFX67 && (iRM == 6)) OffsetSize = 2;
            if (!PFX67 && (iRM == 5)) OffsetSize = 4; 
            break;
        case 1: OffsetSize = 1;
            break; 
        case 2: if (PFX67) OffsetSize = 2; else OffsetSize = 4;
            break;
        case 3: SibPresent = FALSE;
        }
        if (SibPresent)
        {
            if (((*cPtr & 7) == 5) && ( (!iMod) || (iMod == 2) )) OffsetSize = 4;
            cPtr++;
        }
        cPtr = (PUCHAR)(ULONG)cPtr + OffsetSize;
    }

    if (Flags & OP_DATA_I8) cPtr ++;
    if (Flags & OP_DATA_I16) cPtr += 2;
    if (Flags & OP_DATA_I32) cPtr += 4;
    if (PFX66) Add = 2;
    else Add = 4;
    if (Flags & OP_DATA_PRE66_67) cPtr += Add;
    return (ULONG)cPtr - (ULONG)Code;
}


BOOL IsAddressInSystem(ULONG ulDriverBase,ULONG *ulSysModuleBase,ULONG *ulSize,char *lpszSysModuleImage)
{
    NTSTATUS status;
    ULONG NeededSize,i;
    PMODULES pModuleList;
    BOOL bRet = FALSE;
    BOOL bInit = FALSE;

    if (ZwQuerySystemInformation &&
        ExAllocatePool &&
        ExFreePool)
    {
        bInit = TRUE;
    }
    if (!bInit)
        return FALSE;

    __try
    {
        status=ZwQuerySystemInformation(
            SystemModuleInformation,
            NULL,
            0,
            &NeededSize);
        if (status!=STATUS_INFO_LENGTH_MISMATCH)
        {
            //KdPrint(("ZwQuerySystemInformation failed:%d",RtlNtStatusToDosError(status)));
            return bRet;
        }
        pModuleList=(PMODULES)ExAllocatePool(NonPagedPool,NeededSize);
        if (pModuleList)
        {
            status=ZwQuerySystemInformation(
                SystemModuleInformation,
                pModuleList,
                NeededSize,
                &NeededSize);

            if (NT_SUCCESS(status))
            {
                for (i=0;i<pModuleList->ulCount;i++)
                {
                    if (ulDriverBase > pModuleList->smi[i].Base && ulDriverBase < pModuleList->smi[i].Base + pModuleList->smi[i].Size)
                    {
                        bRet = TRUE;
                        __try
                        {
                            *ulSysModuleBase = pModuleList->smi[i].Base;
                            *ulSize = pModuleList->smi[i].Size;
                            memset(lpszSysModuleImage,0,sizeof(lpszSysModuleImage));
                            strcat(lpszSysModuleImage,pModuleList->smi[i].ImageName);

                        }__except(EXCEPTION_EXECUTE_HANDLER){

                        }
                        break;
                    }
                }
            }
            //else
            //    KdPrint(("@@ZwQuerySystemInformation failed:%d",RtlNtStatusToDosError(status)));

            ExFreePool(pModuleList);
            pModuleList = NULL;
        }
        //else
        //    KdPrint(("ExAllocatePool failed"));
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
    }
    if (pModuleList)
        ExFreePool(pModuleList);

    return bRet;
}