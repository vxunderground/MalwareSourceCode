
/**
 * Program information, copyright, etc.
 */
#define PROGRAM_NAME "IOCTL Fuzzer"
#define PROGRAM_AUTHOR "by Oleksiuk Dmytro (aka Cr4sh) :: dmitry@esagelab.com"
#define PROGRAM_COPYRIGHT "(c) 2011 Esage Lab :: http://www.esagelab.com/"

/**
 * Log file name to store all IOCTLs requests information.
 */
#define IOCTLS_LOG_NAME L"ioctls.log"

/**
 * Main application log file name.
 */
#define IOCTLFUZZER_LOG_FILE "ioctlfuzzer.log"

/**
 * File and service name for the kernel driver.
 */
#define DRIVER_SERVICE_NAME "IOCTL_fuzzer"
#define DRIVER_FILE_NAME "IOCTL_fuzzer.sys"

/**
 * Directory name to store downloaded debug symbols.
 */
#define SYMBOLS_DIR_NAME "Symbols"

/**
 * Default value for fuzzing type option.
 */
#define DEFAULT_FUZZING_TYPE FuzzingType_Random

/**
 * IOCTL buffer length limit for dumping into the
 * application log or debugger output.
 */
#define MAX_IOCTL_BUFFER_LEGTH 0x1000

/**
 * Maximum number of lines in console window.
 */
#define CONSOLE_BUFFER_HEIGHT 0x1000
