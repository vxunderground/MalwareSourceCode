#define DEVICE_NAME L"IOCTLfuzzer"
#define DBG_PIPE_NAME L"IOCTLfuzzer"
#define DBG_PIPE_NAME_A "IOCTLfuzzer"

#define IOCTL_DRV_CONTROL CTL_CODE(FILE_DEVICE_UNKNOWN, 0x01, METHOD_BUFFERED, FILE_READ_DATA | FILE_WRITE_DATA)

#define S_ERROR             0x00
#define S_SUCCESS           0x01

#define C_ADD_DEVICE        0x01
#define C_ADD_DRIVER        0x02
#define C_ADD_IOCTL         0x03
#define C_ADD_PROCESS       0x04
#define C_SET_OPTIONS       0x05
#define C_GET_DEVICE_INFO   0x06
#define C_CHECK_HOOKS       0x07
#define C_DEL_OPTIONS       0x08
#define C_GET_OBJECT_NAME   0x09

// fuzzing options
#define FUZZ_OPT_LOG_IOCTL          0x00000001
#define FUZZ_OPT_LOG_IOCTL_BUFFERS  0x00000002
#define FUZZ_OPT_LOG_IOCTL_GLOBAL   0x00000004
#define FUZZ_OPT_LOG_EXCEPTIONS     0x00000008
#define FUZZ_OPT_LOG_DEBUG          0x00000010
#define FUZZ_OPT_FUZZ               0x00000020
#define FUZZ_OPT_FUZZ_SIZE          0x00000040
#define FUZZ_OPT_FUZZ_FAIR          0x00000080
#define FUZZ_OPT_FUZZ_BOOT          0x00000100
#define FUZZ_OPT_NO_SDT_HOOKS       0x00000200

typedef ULONG FUZZING_TYPE;

#define FuzzingType_Random  0x00000001
#define FuzzingType_Dword   0x00000002

// area to store some variables, that must located in user mode
#pragma pack(push, 1)
typedef struct _USER_MODE_DATA
{
    IO_STATUS_BLOCK IoStatus;

} USER_MODE_DATA,
*PUSER_MODE_DATA;
#pragma pack(pop)

#define MAX_REQUEST_STRING 0x100

#pragma pack(push, 1)
typedef struct _REQUEST_BUFFER
{
    // operation status (see S_* definitions)
    ULONG Status;
    
    // operation code (see C_* definitions)
    ULONG Code;

    union
    {
        struct
        {
            ULONG Options;
            ULONG FuzzThreadId;
            FUZZING_TYPE FuzzingType;
            PUSER_MODE_DATA UserModeData;
            ULONG KiDispatchException_Offset;

        } Options;

        struct
        {
            PVOID DeviceObjectAddr;
            PVOID DriverObjectAddr;
            char szDriverObjectName[MAX_REQUEST_STRING];
            char szDriverFilePath[MAX_REQUEST_STRING];

        } DeviceInfo;

        struct
        {
            // for C_ADD_IOCTL
            ULONG IoctlCode;

            // for all C_ADD_*
            BOOLEAN bAllow;

            // for C_ADD_DEVICE,  C_ADD_DRIVER and C_ADD_PROCESS
            char szObjectName[MAX_REQUEST_STRING];

            /* 
                If TRUE -- debugger command, that stored in Buff[], 
                must be executed for every IOCTL, that has been matched
                by this object.
            */
            BOOLEAN bDbgcbAction;

        } AddObject;

        struct
        {
            HANDLE hObject;
            char szObjectName[MAX_REQUEST_STRING];

        } ObjectName;

        struct
        {
            BOOLEAN bHooksInstalled;

        } CheckHooks;
    };        
    
    char Buff[1];

} REQUEST_BUFFER,
*PREQUEST_BUFFER;
#pragma pack(pop)
