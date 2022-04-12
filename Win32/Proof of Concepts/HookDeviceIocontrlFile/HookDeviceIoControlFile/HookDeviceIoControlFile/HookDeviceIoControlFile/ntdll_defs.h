typedef LONG NTSTATUS; 

typedef struct _IO_STATUS_BLOCK 
{
    union {
        NTSTATUS Status;
        PVOID Pointer;
    };
    ULONG_PTR Information;

} IO_STATUS_BLOCK, 
*PIO_STATUS_BLOCK;

#undef UNICODE_STRING

typedef struct _UNICODE_STRING 
{
    USHORT Length;
    USHORT MaximumLength;
    PWSTR Buffer;

} UNICODE_STRING, 
*PUNICODE_STRING;

#define OBJ_INHERIT                     0x00000002
#define OBJ_PERMANENT                   0x00000010
#define OBJ_EXCLUSIVE                   0x00000020
#define OBJ_CASE_INSENSITIVE            0x00000040
#define OBJ_OPENIF                      0x00000080
#define OBJ_OPENLINK                    0x00000100
#define OBJ_VALID_ATTRIBUTES            0x000001F2

typedef struct _OBJECT_ATTRIBUTES
{
    ULONG Length;
    HANDLE RootDirectory;
    PUNICODE_STRING    ObjectName;
    ULONG Attributes;
    PVOID SecurityDescriptor;
    PVOID SecurityQualityOfService;

} OBJECT_ATTRIBUTES, 
*POBJECT_ATTRIBUTES;

#define InitializeObjectAttributes( p, n, a, r, s ) {   \
    (p)->Length = sizeof( OBJECT_ATTRIBUTES );          \
    (p)->RootDirectory = r;                             \
    (p)->Attributes = a;                                \
    (p)->ObjectName = n;                                \
    (p)->SecurityDescriptor = s;                        \
    (p)->SecurityQualityOfService = NULL;               \
}

#define NT_SUCCESS(Status) ((LONG)(Status) >= 0)
#define NT_ERROR(Status) ((ULONG)(Status) >> 30 == 3)

#define NtCurrentProcess() ((HANDLE)-1)

#ifndef STATUS_BUFFER_OVERFLOW
#define STATUS_BUFFER_OVERFLOW           ((NTSTATUS)0x80000005L) 
#endif

#ifndef STATUS_NO_MORE_FILES
#define STATUS_NO_MORE_FILES             ((NTSTATUS)0x80000006L)
#endif

#ifndef STATUS_INFO_LENGTH_MISMATCH
#define STATUS_INFO_LENGTH_MISMATCH      ((NTSTATUS)0xC0000004L)
#endif

#ifndef STATUS_BUFFER_TOO_SMALL 
#define STATUS_BUFFER_TOO_SMALL          ((NTSTATUS)0xC0000023L)
#endif
