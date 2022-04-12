//----------------------------------------------------------------------------
//
// C++ dbgeng extension framework.
//
// The framework makes it easy to write dbgeng extension
// DLLs by wrapping the inconvenient parts of the extension API.
// Boilerplate code is provided as base implementations,
// removing the need to put in empty or skeleton code.
// Error handling is done via exceptions, removing most
// error path code.
//
// The framework assumes async exception handling compilation.
//
// Copyright (C) Microsoft Corporation, 2005-2006.
//
//----------------------------------------------------------------------------

#if _MSC_VER > 1000
#pragma once
#endif

#ifndef __ENGEXTCPP_HPP__
#define __ENGEXTCPP_HPP__

#ifndef __cplusplus
#error engextcpp.hpp requires C++.
#endif

#include <windows.h>
#include <dbgeng.h>
#define KDEXT_64BIT
#include <wdbgexts.h>

#include <pshpack8.h>

#if _MSC_VER >= 800
#pragma warning(disable:4121)
#endif
      
// This will be an engine extension DLL so the wdbgexts
// APIs are not appropriate.
#undef DECLARE_API
#undef DECLARE_API32
#undef DECLARE_API64

//----------------------------------------------------------------------------
//
// Basic utilities needed later.
//
//----------------------------------------------------------------------------

#define EXT_RELEASE(_Unk) \
    ((_Unk) != NULL ? ((_Unk)->Release(), (void)((_Unk) = NULL)) : (void)NULL)

#define EXT_DIMAT(_Array, _EltType) (sizeof(_Array) / sizeof(_EltType))
#define EXT_DIMA(_Array) EXT_DIMAT(_Array, (_Array)[0])

class ExtExtension;
class ExtCommandDesc;

//----------------------------------------------------------------------------
//
// All errors from this framework are handled by exceptions.
// The exception hierarchy allows various conditions to
// be handled separately, but generally extensions should
// not need to do any exception handling.  The framework
// automatically wraps extensions with try/catch to absorb
// errors properly.
//
//----------------------------------------------------------------------------

class ExtException
{
public:
    ExtException(__in HRESULT Status,
                 __in_opt PCSTR Message)
    {
        m_Status = Status;
        m_Message = Message;
    }

    HRESULT GetStatus(void)
    {
        return m_Status;
    }
    HRESULT SetStatus(__in HRESULT Status)
    {
        m_Status = Status;
        return Status;
    }
    
    PCSTR GetMessage(void)
    {
        return m_Message;
    }
    void SetMessage(__in_opt PCSTR Message)
    {
        m_Message = Message;
    }
    
    void PrintMessageVa(__in_ecount(BufferChars) PSTR Buffer,
                        __in ULONG BufferChars,
                        __in PCSTR Format,
                        __in va_list Args);
    void WINAPIV PrintMessage(__in_ecount(BufferChars) PSTR Buffer,
                              __in ULONG BufferChars,
                              __in PCSTR Format,
                              ...);
    
protected:
    HRESULT m_Status;
    PCSTR m_Message;
};

class ExtRemoteException : public ExtException
{
public:
    ExtRemoteException(__in HRESULT Status,
                       __in PCSTR Message)
        : ExtException(Status, Message) { }
};

class ExtStatusException : public ExtException
{
public:
    ExtStatusException(__in HRESULT Status,
                       __in_opt PCSTR Message = NULL)
        : ExtException(Status, Message) { }
};

class ExtInterruptException : public ExtException
{
public:
    ExtInterruptException(void)
        : ExtException(HRESULT_FROM_NT(STATUS_CONTROL_C_EXIT),
                       "Operation interrupted by request") { }
};

class ExtCheckedPointerException : public ExtException
{
public:
    ExtCheckedPointerException(__in PCSTR Message)
        : ExtException(E_INVALIDARG, Message) { }
};

class ExtInvalidArgumentException : public ExtException
{
public:
    ExtInvalidArgumentException(__in PCSTR Message)
        : ExtException(E_INVALIDARG, Message) { }
};

//----------------------------------------------------------------------------
//
// A checked pointer ensures that its value is non-NULL.
// This kind of wrapper is used for engine interface pointers
// so that extensions can simply use whatever interface they
// prefer with soft failure against engines that don't support
// the desired interfaces.
//
//----------------------------------------------------------------------------

template<typename _T>
class ExtCheckedPointer
{
public:
    ExtCheckedPointer(__in PCSTR Message)
    {
        m_Message = Message;
        m_Ptr = NULL;
    }

    bool IsSet(void)
    {
        return m_Ptr != NULL;
    }
    void Throw(void) throw(...)
    {
        if (!m_Ptr)
        {
            throw ExtCheckedPointerException(m_Message);
        }
    }
    _T* Get(void) throw(...)
    {
        Throw();
        return m_Ptr;
    }
    void Set(__in_opt _T* Ptr)
    {
        m_Ptr = Ptr;
    }

    bool operator==(const _T* Ptr) const
    {
        return m_Ptr == Ptr;
    }
    bool operator!=(const _T* Ptr) const
    {
        return !(*this == Ptr);
    }

    operator _T*(void) throw(...)
    {
        return Get();
    }
    _T* operator->(void) throw(...)
    {
        return Get();
    }
    _T** operator&(void)
    {
        return &m_Ptr;
    }
    ExtCheckedPointer<_T>& operator=(ExtCheckedPointer<_T>& Ptr)
    {
        Set(Ptr.m_Ptr);
        return *this;
    }
    ExtCheckedPointer<_T>& operator=(__in_opt _T* Ptr)
    {
        Set(Ptr);
        return *this;
    }

protected:
    PCSTR m_Message;
    _T* m_Ptr;
};

//----------------------------------------------------------------------------
//
// An unknown holder is a safe pointer for an IUnknown.
// It automatically checks for NULL usage and calls
// Release on destruction.
//
//----------------------------------------------------------------------------

template<typename _T>
class ExtUnknownHolder
{
public:
    ExtUnknownHolder(void)
    {
        m_Unk = NULL;
    }
    ~ExtUnknownHolder(void)
    {
        EXT_RELEASE(m_Unk);
    }
    
    _T* Get(void) throw(...)
    {
        if (!m_Unk)
        {
            throw ExtStatusException(E_NOINTERFACE,
                                     "ExtUnknownHolder NULL reference");
        }
        return m_Unk;
    }
    void Set(__in_opt _T* Unk)
    {
        EXT_RELEASE(m_Unk);
        m_Unk = Unk;
    }
    void Relinquish(void)
    {
        m_Unk = NULL;
    }

    bool operator==(const _T* Unk) const
    {
        return m_Unk == Unk;
    }
    bool operator!=(const _T* Unk) const
    {
        return !(*this == Unk);
    }
    
    operator _T*(void) throw(...)
    {
        return Get();
    }
    _T* operator->(void) throw(...)
    {
        return Get();
    }
    _T** operator&(void)
    {
        if (m_Unk)
        {
            throw ExtStatusException(E_NOINTERFACE,
                                     "ExtUnknownHolder non-NULL & reference");
        }
        return &m_Unk;
    }
    ExtUnknownHolder<_T>& operator=(ExtUnknownHolder<_T>& Unk)
    {
        Set(Unk.m_Unk);
        return *this;
    }
    ExtUnknownHolder<_T>& operator=(_T* Unk)
    {
        Set(Unk);
        return *this;
    }

protected:
    _T* m_Unk;
};

//----------------------------------------------------------------------------
//
// A delete holder is a safe pointer for a dynamic object.
// It automatically checks for NULL usage and calls
// delete on destruction.
//
//----------------------------------------------------------------------------

template<typename _T>
class ExtDeleteHolder
{
public:
    ExtDeleteHolder(void)
    {
        m_Ptr = NULL;
    }
    ~ExtDeleteHolder(void)
    {
        delete m_Ptr;
    }

    _T* New(void) throw(...)
    {
        _T* Ptr = new _T;
        if (!Ptr)
        {
            throw ExtStatusException(E_OUTOFMEMORY);
        }
        Set(Ptr);
        return Ptr;
    }
    _T* New(ULONG Elts) throw(...)
    {
        if (Elts > (ULONG_PTR)-1 / sizeof(_T))
        {
            throw ExtStatusException
                (HRESULT_FROM_WIN32(ERROR_ARITHMETIC_OVERFLOW),
                 "ExtDeleteHolder::New count overflow");
        }
        _T* Ptr = new _T[Elts];
        if (!Ptr)
        {
            throw ExtStatusException(E_OUTOFMEMORY);
        }
        Set(Ptr);
        return Ptr;
    }
        
    _T* Get(void) throw(...)
    {
        if (!m_Ptr)
        {
            throw ExtStatusException(E_INVALIDARG,
                                     "ExtDeleteHolder NULL reference");
        }
        return m_Ptr;
    }
    void Set(__in_opt _T* Ptr)
    {
        delete m_Ptr;
        m_Ptr = Ptr;
    }
    void Relinquish(void)
    {
        m_Ptr = NULL;
    }

    bool operator==(const _T* Ptr) const
    {
        return m_Ptr == Ptr;
    }
    bool operator!=(const _T* Ptr) const
    {
        return !(*this == Ptr);
    }
    
    operator _T*(void) throw(...)
    {
        return Get();
    }
    _T* operator->(void) throw(...)
    {
        return Get();
    }
    _T** operator&(void)
    {
        if (m_Ptr)
        {
            throw ExtStatusException(E_INVALIDARG,
                                     "ExtDeleteHolder non-NULL & reference");
        }
        return &m_Ptr;
    }
    ExtDeleteHolder<_T>& operator=(ExtDeleteHolder<_T>& Ptr)
    {
        Set(Ptr.m_Ptr);
        return *this;
    }
    ExtDeleteHolder<_T>& operator=(_T* Ptr)
    {
        Set(Ptr);
        return *this;
    }

protected:
    _T* m_Ptr;
};

//----------------------------------------------------------------------------
//
// A current-thread holder is an auto-cleanup holder
// for restoring the debugger's current thread.
//
//----------------------------------------------------------------------------

class ExtCurrentThreadHolder
{
public:
    ExtCurrentThreadHolder(void)
    {
        m_ThreadId = DEBUG_ANY_ID;
    }
    ExtCurrentThreadHolder(__in ULONG Id)
    {
        m_ThreadId = Id;
    }
    ExtCurrentThreadHolder(__in bool DoRefresh)
    {
        if (DoRefresh)
        {
            Refresh();
        }
    }
    ~ExtCurrentThreadHolder(void)
    {
        Restore();
    }

    void Refresh(void) throw(...);
    void Restore(void);

    ULONG m_ThreadId;
};

//----------------------------------------------------------------------------
//
// A current-process holder is an auto-cleanup holder
// for restoring the debugger's current process.
//
//----------------------------------------------------------------------------

class ExtCurrentProcessHolder
{
public:
    ExtCurrentProcessHolder(void)
    {
        m_ProcessId = DEBUG_ANY_ID;
    }
    ExtCurrentProcessHolder(__in ULONG Id)
    {
        m_ProcessId = Id;
    }
    ExtCurrentProcessHolder(__in bool DoRefresh)
    {
        if (DoRefresh)
        {
            Refresh();
        }
    }
    ~ExtCurrentProcessHolder(void)
    {
        Restore();
    }

    void Refresh(void) throw(...);
    void Restore(void);

    ULONG m_ProcessId;
};

//----------------------------------------------------------------------------
//
// Descriptive information kept for all extension commands.
// Automatic help and parameter parsing are built on top
// of this descriptive info.
//
// The argument format is described below with EXT_COMMAND.
//
//----------------------------------------------------------------------------

typedef void (ExtExtension::*ExtCommandMethod)(void);

class ExtCommandDesc
{
public:
    ExtCommandDesc(__in PCSTR Name,
                   __in ExtCommandMethod Method,
                   __in PCSTR Desc,
                   __in_opt PCSTR Args);
    ~ExtCommandDesc(void);

    ExtExtension* m_Ext;
    ExtCommandDesc* m_Next;
    PCSTR m_Name;
    ExtCommandMethod m_Method;
    PCSTR m_Desc;
    PCSTR m_ArgDescStr;
    bool m_ArgsInitialized;

    //
    // Derived by parsing the argument description string.
    //

    struct ArgDesc
    {
        PCSTR Name;
        PCSTR DescShort;
        PCSTR DescLong;
        PCSTR Default;
        ULONG Boolean:1;
        ULONG Expression:1;
        ULONG ExpressionSigned:1;
        ULONG ExpressionDelimited:1;
        ULONG String:1;
        ULONG StringRemainder:1;
        ULONG Required:1;
        ULONG Present:1;
        ULONG DefaultSilent:1;
        ULONG ExpressionBits;
    };

    bool m_CustomArgParsing;
    PSTR m_CustomArgDescShort;
    PSTR m_CustomArgDescLong;
    PSTR m_OptionChars;
    PSTR m_ArgStrings;
    ULONG m_NumArgs;
    ULONG m_NumUnnamedArgs;
    ArgDesc* m_Args;

    void ClearArgs(void);
    void DeleteArgs(void);
    PSTR ParseDirective(__in PSTR Scan) throw(...);
    void ParseArgDesc(void) throw(...);
    void ExInitialize(__in ExtExtension* Ext) throw(...);

    ArgDesc* FindArg(__in PCSTR Name);
    ArgDesc* FindUnnamedArg(__in ULONG Index);
    
    static void Transfer(__out ExtCommandDesc** Commands,
                         __out PULONG LongestName);

    static ExtCommandDesc* s_Commands;
    static ULONG s_LongestCommandName;
};

//----------------------------------------------------------------------------
//
// Known-struct formatting support.
// In order to automatically advertise known structs for
// formatting an extension should point ExtExtension::m_KnownStructs
// at an array of descriptors.  Callbacks will then be sent
// automatically to the formatting methods when necessary.
//
// The final array entry should have TypeName == NULL.
//
//----------------------------------------------------------------------------

// Data formatting callback for known structs.
// On entry the append buffer will be set to the target buffer.
typedef void (ExtExtension::*ExtKnownStructMethod)
    (__in PCSTR TypeName,
     __in ULONG Flags,
     __in ULONG64 Offset);

struct ExtKnownStruct
{
    PCSTR TypeName;
    ExtKnownStructMethod Method;
    bool SuppressesTypeName;
};

//----------------------------------------------------------------------------
//
// Pseudo-register value provider support.
// In order to automatically advertise extended values
// an extension should point ExtExtension::m_ProvidedValues
// at an array of descriptors.  Callbacks will then be sent
// automatically to the provider methods when necessary.
//
// The final array entry should have ValueName == NULL.
//
//----------------------------------------------------------------------------

// Value retrieval callback.
typedef void (ExtExtension::*ExtProvideValueMethod)
    (__in ULONG Flags,
     __in PCWSTR ValueName,
     __out PULONG64 Value,
     __out PULONG64 TypeModBase,
     __out PULONG TypeId,
     __out PULONG TypeFlags);

struct ExtProvidedValue
{
    PCWSTR ValueName;
    ExtProvideValueMethod Method;
};

//----------------------------------------------------------------------------
//
// Base class for all extensions.  An extension DLL will
// have a single instance of a derivation of this class.
// The instance global is automatically declared by macros.
// As the instance is a global the initialization and uninitialization
// is explicit instead of driven through construction and destruction.
//
//----------------------------------------------------------------------------

class ExtExtension
{
public:
    ExtExtension(void);

    //
    // Initialization and uninitialization.
    //
    
    virtual HRESULT Initialize(void);
    virtual void Uninitialize(void);

    //
    // Notifications.
    //

    virtual void OnSessionActive(__in ULONG64 Argument);
    virtual void OnSessionInactive(__in ULONG64 Argument);
    virtual void OnSessionAccessible(__in ULONG64 Argument);
    virtual void OnSessionInaccessible(__in ULONG64 Argument);

    //
    // Overridable initialization state.
    //
    
    USHORT m_ExtMajorVersion;
    USHORT m_ExtMinorVersion;
    ULONG m_ExtInitFlags;

    ExtKnownStruct* m_KnownStructs;
    ExtProvidedValue* m_ProvidedValues;
    
    //
    // Interface and callback pointers.  These
    // interfaces are retrieved on entry to an extension.
    //

    ExtCheckedPointer<IDebugAdvanced> m_Advanced;
    ExtCheckedPointer<IDebugClient> m_Client;
    ExtCheckedPointer<IDebugControl> m_Control;
    ExtCheckedPointer<IDebugDataSpaces> m_Data;
    ExtCheckedPointer<IDebugRegisters> m_Registers;
    ExtCheckedPointer<IDebugSymbols> m_Symbols;
    ExtCheckedPointer<IDebugSystemObjects> m_System;

    // These derived interfaces may be NULL on
    // older engines which do not support them.
    // The checked pointers will automatically
    // protect access.
    ExtCheckedPointer<IDebugAdvanced2> m_Advanced2;
    ExtCheckedPointer<IDebugAdvanced3> m_Advanced3;
    ExtCheckedPointer<IDebugClient2> m_Client2;
    ExtCheckedPointer<IDebugClient3> m_Client3;
    ExtCheckedPointer<IDebugClient4> m_Client4;
    ExtCheckedPointer<IDebugClient5> m_Client5;
    ExtCheckedPointer<IDebugControl2> m_Control2;
    ExtCheckedPointer<IDebugControl3> m_Control3;
    ExtCheckedPointer<IDebugControl4> m_Control4;
    ExtCheckedPointer<IDebugDataSpaces2> m_Data2;
    ExtCheckedPointer<IDebugDataSpaces3> m_Data3;
    ExtCheckedPointer<IDebugDataSpaces4> m_Data4;
    ExtCheckedPointer<IDebugRegisters2> m_Registers2;
    ExtCheckedPointer<IDebugSymbols2> m_Symbols2;
    ExtCheckedPointer<IDebugSymbols3> m_Symbols3;
    ExtCheckedPointer<IDebugSystemObjects2> m_System2;
    ExtCheckedPointer<IDebugSystemObjects3> m_System3;
    ExtCheckedPointer<IDebugSystemObjects4> m_System4;

    //
    // Interesting information about the session.
    // These values are retrieved on entry to an extension.
    //

    ULONG m_OutputWidth;
    
    // Actual processor type.
    ULONG m_ActualMachine;

    // Current machine mode values, not actual
    // machine mode values.  Generally these are
    // the ones you want to look at.
    // If you care about mixed CPU code, such as WOW64,
    // you may need to also get the actual values.
    ULONG m_Machine;
    ULONG m_PageSize;
    ULONG m_PtrSize;
    ULONG m_NumProcessors;
    ULONG64 m_OffsetMask;

    //
    // Queries about the current debuggee information available.
    // The type and qualifier are automatically retrieved.
    //
    
    ULONG m_DebuggeeClass;
    ULONG m_DebuggeeQual;
    ULONG m_DumpFormatFlags;

    bool m_IsRemote;
    bool m_OutCallbacksDmlAware;
    
    bool IsUserMode(void)
    {
        return m_DebuggeeClass == DEBUG_CLASS_USER_WINDOWS;
    }
    bool IsKernelMode(void)
    {
        return m_DebuggeeClass == DEBUG_CLASS_KERNEL;
    }
    bool IsLiveLocalUser(void)
    {
        return
            m_DebuggeeClass == DEBUG_CLASS_USER_WINDOWS &&
            m_DebuggeeQual == DEBUG_USER_WINDOWS_PROCESS;
    }
    bool IsMachine32(__in ULONG Machine)
    {
        return
            Machine == IMAGE_FILE_MACHINE_I386 ||
            Machine == IMAGE_FILE_MACHINE_ARM;
    }
    bool IsCurMachine32(void)
    {
        return IsMachine32(m_Machine);
    }
    bool IsMachine64(__in ULONG Machine)
    {
        return
            Machine == IMAGE_FILE_MACHINE_AMD64 ||
            Machine == IMAGE_FILE_MACHINE_IA64;
    }
    bool IsCurMachine64(void)
    {
        return IsMachine64(m_Machine);
    }
    bool Is32On64(void)
    {
        return IsCurMachine32() && IsMachine64(m_ActualMachine);
    }
    bool CanQueryVirtual(void)
    {
        return
            m_DebuggeeClass == DEBUG_CLASS_USER_WINDOWS ||
            m_DebuggeeClass == DEBUG_CLASS_IMAGE_FILE;
    }
    bool HasFullMemBasic(void)
    {
        return
            m_DebuggeeClass == DEBUG_CLASS_USER_WINDOWS &&
            (m_DebuggeeQual == DEBUG_USER_WINDOWS_PROCESS ||
             m_DebuggeeQual == DEBUG_USER_WINDOWS_PROCESS_SERVER ||
             m_DebuggeeQual == DEBUG_USER_WINDOWS_DUMP ||
             (m_DebuggeeQual == DEBUG_USER_WINDOWS_SMALL_DUMP &&
              (m_DumpFormatFlags &
               DEBUG_FORMAT_USER_SMALL_FULL_MEMORY_INFO) != 0));
    }
    bool IsExtensionRemote(void)
    {
        return m_IsRemote;
    }
    bool AreOutputCallbacksDmlAware(void)
    {
        // Applies to callbacks present in client
        // at the start of the extension command.
        // If the extension changes the output callbacks
        // the value does not automatically update.
        // RefreshOutputCallbackFlags can be used
        // to update this flag after unknown output
        // callbacks are installed.
        return m_OutCallbacksDmlAware;
    }

    //
    // Common mode checks which throw on mismatches.
    //

    void RequireUserMode(void)
    {
        if (!IsUserMode())
        {
            throw ExtStatusException(S_OK, "user-mode only");
        }
    }
    void RequireKernelMode(void)
    {
        if (!IsKernelMode())
        {
            throw ExtStatusException(S_OK, "kernel-mode only");
        }
    }
    
    //
    // Output through m_Control.
    //

    // Defaults to DEBUG_OUTPUT_NORMAL, but can
    // be overridden to produce different output.
    // Warn, Err and Verb are convenience routines for
    // the warning, error and verbose cases.
    ULONG m_OutMask;
    
    void WINAPIV Out(__in PCSTR Format,
                     ...);
    void WINAPIV Warn(__in PCSTR Format,
                      ...);
    void WINAPIV Err(__in PCSTR Format,
                     ...);
    void WINAPIV Verb(__in PCSTR Format,
                      ...);
    void WINAPIV Out(__in PCWSTR Format,
                     ...);
    void WINAPIV Warn(__in PCWSTR Format,
                      ...);
    void WINAPIV Err(__in PCWSTR Format,
                     ...);
    void WINAPIV Verb(__in PCWSTR Format,
                      ...);

    void WINAPIV Dml(__in PCSTR Format,
                     ...);
    void WINAPIV DmlWarn(__in PCSTR Format,
                         ...);
    void WINAPIV DmlErr(__in PCSTR Format,
                        ...);
    void WINAPIV DmlVerb(__in PCSTR Format,
                         ...);
    void WINAPIV Dml(__in PCWSTR Format,
                     ...);
    void WINAPIV DmlWarn(__in PCWSTR Format,
                         ...);
    void WINAPIV DmlErr(__in PCWSTR Format,
                        ...);
    void WINAPIV DmlVerb(__in PCWSTR Format,
                         ...);

    void DmlCmdLink(__in PCSTR Text,
                    __in PCSTR Cmd)
    {
        Dml("<link cmd=\"%s\">%s</link>", Cmd, Text);
    }
    void DmlCmdExec(__in PCSTR Text,
                    __in PCSTR Cmd)
    {
        Dml("<exec cmd=\"%s\">%s</exec>", Cmd, Text);
    }

    void RefreshOutputCallbackFlags(void)
    {
        m_OutCallbacksDmlAware = false;
        if (m_Advanced2.IsSet() &&
            m_Advanced2->
            Request(DEBUG_REQUEST_CURRENT_OUTPUT_CALLBACKS_ARE_DML_AWARE,
                    NULL, 0, NULL, 0, NULL) == S_OK)
        {
            m_OutCallbacksDmlAware = true;
        }
    }

    //
    // Wrapped text output support.
    //

    ULONG m_CurChar;
    ULONG m_LeftIndent;
    bool m_AllowWrap;
    bool m_TestWrap;
    ULONG m_TestWrapChars;
    // m_OutputWidth is also used.
    
    // OutWrap takes the given string and displays it
    // wrapped in the appropriate space.  It doesn't
    // account for tabs, backspaces, internal returns, etc.
    // Uses all wrapping state and updates m_CurChar.
    void WrapLine(void);
    void OutWrapStr(__in PCSTR String);
    void WINAPIV OutWrapVa(__in PCSTR Format,
                           __in va_list Args);
    void WINAPIV OutWrap(__in PCSTR Format,
                         ...);

    // Wraps if the given number of characters wouldn't
    // fit on the current line.
    bool DemandWrap(__in ULONG Chars)
    {
        if (m_CurChar + Chars >= m_OutputWidth)
        {
            WrapLine();
            return true;
        }

        return false;
    }
    
    // Wrapping can be suppressed to allow blocks of
    // output to be unsplit but to still get cur char
    // tracking.
    void AllowWrap(__in bool Allow)
    {
        m_AllowWrap = Allow;
    }

    // Output can be suppressed, allowing collection
    // of character counts as a way to pre-test whether
    // a set of output will wrap.
    void TestWrap(__in bool Test)
    {
        m_TestWrap = Test;
        if (Test)
        {
            m_TestWrapChars = 0;
        }
    }

    //
    // A circular string buffer is available for
    // handing out multiple static strings.
    //

    PSTR RequestCircleString(__in ULONG Chars) throw(...);
    PSTR CopyCircleString(__in PCSTR Str) throw(...);
    PSTR PrintCircleStringVa(__in PCSTR Format,
                             __in va_list Args) throw(...);
    PSTR WINAPIV PrintCircleString(__in PCSTR Format,
                                   ...) throw(...);

    //
    // String buffer with append support.
    // Throws on buffer overflow.
    //

    PSTR m_AppendBuffer;
    ULONG m_AppendBufferChars;
    PSTR m_AppendAt;
    
    void SetAppendBuffer(__in_ecount(BufferChars) PSTR Buffer,
                         __in ULONG BufferChars);
    void AppendBufferString(__in PCSTR Str) throw(...);
    void AppendStringVa(__in PCSTR Format,
                        __in va_list Args) throw(...);
    void WINAPIV AppendString(__in PCSTR Format,
                              ...) throw(...);

    bool IsAppendStart(void)
    {
        return m_AppendAt == m_AppendBuffer;
    }
    
    //
    // Set the return status for an extension call
    // if a specific non-S_OK status needs to be returned.
    //

    void SetCallStatus(__in HRESULT Status);

    //
    // Cached symbol info.  The cache is
    // automatically flushed when the backing
    // symbol info changes.
    //

    ULONG GetCachedSymbolTypeId(__inout PULONG64 Cookie,
                                __in PCSTR Symbol,
                                __out PULONG64 ModBase);
    ULONG GetCachedFieldOffset(__inout PULONG64 Cookie,
                               __in PCSTR Type,
                               __in PCSTR Field,
                               __out_opt PULONG64 ModBase = NULL,
                               __out_opt PULONG TypeId = NULL);
    bool GetCachedSymbolInfo(__in ULONG64 Cookie,
                             __out PDEBUG_CACHED_SYMBOL_INFO Info);
    bool AddCachedSymbolInfo(__in PDEBUG_CACHED_SYMBOL_INFO Info,
                             __in bool ThrowFailure,
                             __out PULONG64 Cookie);

    //
    // Module information helpers.
    //

    void GetModuleImagehlpInfo(__in ULONG64 ModBase,
                               __out struct _IMAGEHLP_MODULEW64* Info);
    bool ModuleHasGlobalSymbols(__in ULONG64 ModBase);
    bool ModuleHasTypeInfo(__in ULONG64 ModBase);
    
    //
    // Incoming argument parsing results.
    // Results are guaranteed to obey the form
    // of the argument description for a command.
    // Mismatched usage, such as a string retrieval
    // for a numeric argument, will result in an exception.
    //

    ULONG GetNumUnnamedArgs(void)
    {
        return m_NumUnnamedArgs;
    }
    
    PCSTR GetUnnamedArgStr(__in ULONG Index) throw(...);
    ULONG64 GetUnnamedArgU64(__in ULONG Index) throw(...);
    bool HasUnnamedArg(__in ULONG Index)
    {
        return Index < m_NumUnnamedArgs;
    }

    PCSTR GetArgStr(__in PCSTR Name,
                    __in bool Required = true) throw(...);
    ULONG64 GetArgU64(__in PCSTR Name,
                      __in bool Required = true) throw(...);
    bool HasArg(__in PCSTR Name)
    {
        return FindArg(Name, false) != NULL;
    }
    bool HasCharArg(__in CHAR Name)
    {
        CHAR NameStr[2] = {Name, 0};
        return FindArg(NameStr, false) != NULL;
    }

    bool SetUnnamedArg(__in ULONG Index,
                       __in_opt PCSTR StrArg,
                       __in ULONG64 NumArg,
                       __in bool OnlyIfUnset = false) throw(...);
    bool SetUnnamedArgStr(__in ULONG Index,
                          __in PCSTR Arg,
                          __in bool OnlyIfUnset = false) throw(...)
    {
        return SetUnnamedArg(Index, Arg, 0, OnlyIfUnset);
    }
    bool SetUnnamedArgU64(__in ULONG Index,
                          __in ULONG64 Arg,
                          __in bool OnlyIfUnset = false) throw(...)
    {
        return SetUnnamedArg(Index, NULL, Arg, OnlyIfUnset);
    }

    bool SetArg(__in PCSTR Name,
                __in_opt PCSTR StrArg,
                __in ULONG64 NumArg,
                __in bool OnlyIfUnset = false) throw(...);
    bool SetArgStr(__in PCSTR Name,
                   __in PCSTR Arg,
                   __in bool OnlyIfUnset = false) throw(...)
    {
        return SetArg(Name, Arg, 0, OnlyIfUnset);
    }
    bool SetArgU64(__in PCSTR Name,
                   __in ULONG64 Arg,
                   __in bool OnlyIfUnset = false) throw(...)
    {
        return SetArg(Name, NULL, Arg, OnlyIfUnset);
    }

    PCSTR GetRawArgStr(void)
    {
        return m_RawArgStr;
    }
    PSTR GetRawArgCopy(void)
    {
        // This string may be chopped up if
        // the default argument parsing occurred.
        return m_ArgCopy;
    }
    
    PCSTR GetExpr64(__in PCSTR Str,
                    __in bool Signed,
                    __in ULONG64 Limit,
                    __out PULONG64 Val) throw(...);
    PCSTR GetExprU64(__in PCSTR Str,
                     __in ULONG64 Limit,
                     __out PULONG64 Val) throw(...)
    {
        return GetExpr64(Str, false, Limit, Val);
    }
    PCSTR GetExprS64(__in PCSTR Str,
                     __in LONG64 Limit,
                     __out PLONG64 Val) throw(...)
    {
        return GetExpr64(Str, true, (ULONG64)Limit, (PULONG64)Val);
    }

    void DECLSPEC_NORETURN ThrowCommandHelp(void) throw(...)
    {
        if (m_CurCommand)
        {
            HelpCommand(m_CurCommand);
        }
        throw ExtStatusException(E_INVALIDARG);
    }
    void ThrowInterrupt(void) throw(...)
    {
        if (m_Control->GetInterrupt() == S_OK)
        {
            throw ExtInterruptException();
        }
    }
    void DECLSPEC_NORETURN ThrowOutOfMemory(void) throw(...)
    {
        throw ExtStatusException(E_OUTOFMEMORY);
    }
    void DECLSPEC_NORETURN ThrowContinueSearch(void) throw(...)
    {
        throw ExtStatusException(DEBUG_EXTENSION_CONTINUE_SEARCH);
    }
    void DECLSPEC_NORETURN ThrowReloadExtension(void) throw(...)
    {
        throw ExtStatusException(DEBUG_EXTENSION_RELOAD_EXTENSION);
    }
    void DECLSPEC_NORETURN WINAPIV ThrowInvalidArg(__in PCSTR Format,
                                                    ...) throw(...);
    void DECLSPEC_NORETURN WINAPIV ThrowRemote(__in HRESULT Status,
                                               __in PCSTR Format,
                                               ...) throw(...);
    void DECLSPEC_NORETURN WINAPIV ThrowStatus(__in HRESULT Status,
                                               __in PCSTR Format,
                                               ...) throw(...);
    void DECLSPEC_NORETURN WINAPIV
        ThrowLastError(__in PCSTR Message = NULL) throw(...)
        {
            ExtStatusException Ex(HRESULT_FROM_WIN32(GetLastError()),
                                  Message);
            throw Ex;
        }

    //
    // Internal data.
    //

    static HMODULE s_Module;
    static char s_String[2000];
    static char s_CircleStringBuffer[2000];
    static char* s_CircleString;
    
    ExtCommandDesc* m_Commands;
    ULONG m_LongestCommandName;
    HRESULT m_CallStatus;
    HRESULT m_MacroStatus;

    struct ArgVal
    {
        PCSTR Name;
        PCSTR StrVal;
        ULONG64 NumVal;
    };
    static const ULONG s_MaxArgs = 64;

    ExtCommandDesc* m_CurCommand;
    PCSTR m_RawArgStr;
    PSTR m_ArgCopy;
    ULONG m_NumArgs;
    ULONG m_NumNamedArgs;
    ULONG m_NumUnnamedArgs;
    ULONG m_FirstNamedArg;
    // Unnamed args are packed in the front.
    ArgVal m_Args[s_MaxArgs];

    bool m_ExInitialized;
    
    void ExInitialize(void) throw(...);
    
    HRESULT Query(__in PDEBUG_CLIENT Start);
    void Release(void);

    HRESULT CallCommandMethod(__in ExtCommandDesc* Desc,
                              __in_opt PCSTR Args);
    HRESULT CallCommand(__in ExtCommandDesc* Desc,
                        __in PDEBUG_CLIENT Client,
                        __in_opt PCSTR Args);
    
    HRESULT CallKnownStructMethod(__in ExtKnownStruct* Struct,
                                  __in ULONG Flags,
                                  __in ULONG64 Offset,
                                  __out_ecount(*BufferChars) PSTR Buffer,
                                  __inout PULONG BufferChars);
    HRESULT CallKnownStruct(__in PDEBUG_CLIENT Client,
                            __in ExtKnownStruct* Struct,
                            __in ULONG Flags,
                            __in ULONG64 Offset,
                            __out_ecount(*BufferChars) PSTR Buffer,
                            __inout PULONG BufferChars);
    HRESULT HandleKnownStruct(__in PDEBUG_CLIENT Client,
                              __in ULONG Flags,
                              __in ULONG64 Offset,
                              __in_opt PCSTR TypeName,
                              __out_ecount(*BufferChars) PSTR Buffer,
                              __inout PULONG BufferChars);

    HRESULT HandleQueryValueNames(__in PDEBUG_CLIENT Client,
                                  __in ULONG Flags,
                                  __out_ecount(BufferChars) PWSTR Buffer,
                                  __in ULONG BufferChars,
                                  __out PULONG BufferNeeded);
    HRESULT CallProvideValueMethod(__in ExtProvidedValue* ExtVal,
                                   __in ULONG Flags,
                                   __out PULONG64 Value,
                                   __out PULONG64 TypeModBase,
                                   __out PULONG TypeId,
                                   __out PULONG TypeFlags);
    HRESULT HandleProvideValue(__in PDEBUG_CLIENT Client,
                               __in ULONG Flags,
                               __in PCWSTR Name,
                               __out PULONG64 Value,
                               __out PULONG64 TypeModBase,
                               __out PULONG TypeId,
                               __out PULONG TypeFlags);

    ArgVal* FindArg(__in PCSTR Name,
                    __in bool Required) throw(...);
    PCSTR SetRawArgVal(__in ExtCommandDesc::ArgDesc* Check,
                       __in_opt ArgVal* Val,
                       __in bool ExplicitVal,
                       __in_opt PCSTR StrVal,
                       __in bool StrWritable,
                       __in ULONG64 NumVal) throw(...);
    void ParseArgs(__in ExtCommandDesc* Desc,
                   __in_opt PCSTR Args) throw(...);

    void OutCommandArg(__in ExtCommandDesc::ArgDesc* Arg,
                       __in bool Separate);
    void HelpCommandArgsSummary(__in ExtCommandDesc* Desc);
    void HelpCommand(__in ExtCommandDesc* Desc);
    void HelpCommandName(__in PCSTR Name);
    void HelpAll(void);
    void help(void);
};

//----------------------------------------------------------------------------
//
// Global forwarders for common methods.
//
//----------------------------------------------------------------------------

#if !defined(EXT_NO_OUTPUT_FUNCTIONS)

void WINAPIV ExtOut(__in PCSTR Format, ...);
void WINAPIV ExtWarn(__in PCSTR Format, ...);
void WINAPIV ExtErr(__in PCSTR Format, ...);
void WINAPIV ExtVerb(__in PCSTR Format, ...);

#endif // #if !defined(EXT_NO_OUTPUT_FUNCTIONS)

//----------------------------------------------------------------------------
//
// Supporting macros and utilities.
//
//----------------------------------------------------------------------------

// If you wish to override the class name that is used
// as the derivation from ExtExtension define it
// before including this file.  Otherwise the class
// will be named 'Extension'.
#ifndef EXT_CLASS
#define EXT_CLASS Extension
#endif

extern ExtCheckedPointer<ExtExtension> g_Ext;
extern ExtExtension* g_ExtInstancePtr;

// Put a single use of this macro in one source file.
#define EXT_DECLARE_GLOBALS() \
EXT_CLASS g_ExtInstance; \
ExtExtension* g_ExtInstancePtr = &g_ExtInstance

// Use this macro to forward-declare a command method in your class
// declaration.
#define EXT_COMMAND_METHOD(_Name) \
void _Name(void)

//----------------------------------------------------------------------------
//
// Use this macro to declare an extension command implementation.  It
// will declare the base function that will be exported and
// will start a method on your class for the command
// implementation.
//
// The description string given will automatically be wrapped to
// fit the space it is being displayed in.  Newlines can be embedded
// to force a new line but are not necessary for formatting.
//
// The argument string describes the arguments expected by the
// command.  It is a sequence of the following two major components.
//
// Directives: {{<directive>}}
//
// Indicates a special non-argument directive.  Directives are:
//   custom - Extension does its own argument parsing.
//            Default parsing is disabled.
//   l:<str> - Custom long argument description.  The
//             long argument description is a full description
//             for each argument.
//   opt:<str> - Defines the option prefix characters for
//               commands that don't want to use the default
//               / and -.
//   s:<str> - Custom short argument description.  The
//             short argument description is the argument summary
//             shown with the command name.
//
// Examples:
//
//   {{custom}}{{s:<arg1> <arg2>}}{{l:arg1 - Argument 1\narg2 - Argument 2}}
//
// This defines an extension command that parses its own arguments.
// Such a command should give custom help strings so that the automatic
// !help support has something to display, such as the short and
// long descriptions given here.
//
//   {{opt:+:}}
//
// This changes the argument option prefix characters to + and :,
// so that +arg and :arg can be used instead of /arg and -arg.
//
// Arguments: {[<optname>];[<type>[,<flags>]];[<argname>];[<argdesc>]}
//
// Defines an argument for the extension.  An argument
// has several parts.
//
//   <optname> - Gives the argument's option name that is given
//               in an argument string to pass the argument.
//               Arguments can be unnamed if they are going
//               to be handed positionally.  Unnamed arguments
//               are processed in the order given.
//
//   <type> - Indicates the type of the argument.  The possibilities are:
//            b - Boolean (present/not-present) argument, for flags.
//            e[d][s][<bits>] - Expression argument for getting numeric values.
//                d - Indicates that the expression should be limited
//                    to the next space-delimited subset of the overall
//                    argument string.  This prevents accidental evaluation
//                    of other data following the expression and so
//                    can avoid otherwise unnecessary symbol resolution.
//                s - Indicates the value is signed and a
//                    bit-size limit can be given for values
//                    that are less than 64-bit.
//            s - Space-delimited string argument.
//            x - String-to-end-of-args string argument.
//
//   <flags> - Modifies argument behavior.
//             d=<expr> - Sets default value for argument.
//             ds - Indicates that the default value should not be
//                  displayed in an argument description.
//             o - Argument is optional (default for named arguments).
//             r - Argument is required (default for unnamed arguments).
//
//   <argname> - Argument name to show for the value in help output.
//               This is separate from the option name for non-boolean
//               arguments since they can have both a name and a value.
//               For boolean arguments the argument name is not used.
//
//   <argdesc> - Long argument description to show in help output.
//
// Examples:
//
//   {;e32,o,d=0x100;flags;Flags to control command}
//
// This defines a command with a single optional expression argument.  The
// argument value must fit in 32 bits.  If the argument isn't specified
// the default value of 0x100 will be used.
//
//   {v;b;;Verbose mode}{;s;name;Name of object}
//
// This defines a command with an optional boolean /v and a required
// unnamed string argument.
//
//   {oname;e;expr;Address of object}{eol;x;str;Commands to use}
//
// This defines a command which has an optional expression argument
// /oname <expr> and an optional end-of-string argument /eol <str>.
// If /eol is present it will get the remainder of the command string
// and no further arguments will be parsed.
// 
// /? is automatically provided for all commands unless custom
// argument parsing is indicated.
//
// A NULL or empty argument string indicates no arguments.
// Commands are currently limited to a maximum of 64 arguments.
//
//----------------------------------------------------------------------------

#define EXT_CLASS_COMMAND(_Class, _Name, _Desc, _Args)                        \
ExtCommandDesc g_##_Name##Desc(#_Name,                                        \
                               (ExtCommandMethod)&_Class::_Name,              \
                               _Desc,                                         \
                               _Args);                                        \
EXTERN_C HRESULT CALLBACK                                                     \
_Name(__in PDEBUG_CLIENT Client,                                              \
      __in_opt PCSTR Args)                                                    \
{                                                                             \
    if (!g_Ext.IsSet())                                                       \
    {                                                                         \
        return E_UNEXPECTED;                                                  \
    }                                                                         \
    return g_Ext->CallCommand(&g_##_Name##Desc, Client, Args);                \
}                                                                             \
void _Class::_Name(void)
#define EXT_COMMAND(_Name, _Desc, _Args) \
    EXT_CLASS_COMMAND(EXT_CLASS, _Name, _Desc, _Args)

// Checks for success and throws an exception for failure.
#define EXT_STATUS(_Expr)                                                     \
    if (FAILED(m_MacroStatus = (_Expr)))                                      \
    {                                                                         \
        throw ExtStatusException(m_MacroStatus);                              \
    } else 0
#define EXT_STATUS_MSG(_Expr, _Msg)                                           \
    if (FAILED(m_MacroStatus = (_Expr)))                                      \
    {                                                                         \
        throw ExtStatusException(m_MacroStatus, _Msg);                        \
    } else 0
#define EXT_STATUS_EMSG(_Expr)                                                \
    if (FAILED(m_MacroStatus = (_Expr)))                                      \
    {                                                                         \
        throw ExtStatusException(m_MacroStatus, #_Expr);                      \
    } else 0

//----------------------------------------------------------------------------
//
// ExtRemoteData is a simple wrapper for a piece of debuggee memory.
// It automatically retrieves small data items and wraps
// other common requests with throwing methods.
//
// Data can be named for more meaningful error messages.
//
//----------------------------------------------------------------------------

class ExtRemoteData
{
public:
    ExtRemoteData(void)
    {
        Clear();
    }
    ExtRemoteData(__in ULONG64 Offset,
                  __in ULONG Bytes) throw(...)
    {
        Clear();
        Set(Offset, Bytes);
    }
    ExtRemoteData(__in_opt PCSTR Name,
                  __in ULONG64 Offset,
                  __in ULONG Bytes) throw(...)
    {
        Clear();
        m_Name = Name;
        Set(Offset, Bytes);
    }
    
    void Set(__in ULONG64 Offset,
             __in ULONG Bytes) throw(...)
    {
        m_Offset = Offset;
        m_ValidOffset = true;
        m_Bytes = Bytes;
        if (Bytes <= sizeof(m_Data))
        {
            Read();
        }
        else
        {
            m_ValidData = false;
            m_Data = 0;
        }
    }
    void Set(__in const DEBUG_TYPED_DATA* Typed);

    void Read(void) throw(...);
    void Write(void) throw(...);

    ULONG64 GetData(__in ULONG Request) throw(...);

    //
    // Fixed-size primitive type queries.
    // Queries are validated against the known data size.
    //
    
    CHAR GetChar(void) throw(...)
    {
        return (CHAR)GetData(sizeof(CHAR));
    }
    UCHAR GetUchar(void) throw(...)
    {
        return (UCHAR)GetData(sizeof(UCHAR));
    }
    BOOLEAN GetBoolean(void) throw(...)
    {
        return (BOOLEAN)GetData(sizeof(BOOLEAN));
    }
    bool GetStdBool(void) throw(...)
    {
        return GetData(sizeof(bool)) != 0;
    }
    BOOL GetW32Bool(void) throw(...)
    {
        return (BOOL)GetData(sizeof(BOOL));
    }
    SHORT GetShort(void) throw(...)
    {
        return (SHORT)GetData(sizeof(SHORT));
    }
    USHORT GetUshort(void) throw(...)
    {
        return (USHORT)GetData(sizeof(USHORT));
    }
    LONG GetLong(void) throw(...)
    {
        return (LONG)GetData(sizeof(LONG));
    }
    ULONG GetUlong(void) throw(...)
    {
        return (ULONG)GetData(sizeof(ULONG));
    }
    LONG64 GetLong64(void) throw(...)
    {
        return (LONG64)GetData(sizeof(LONG64));
    }
    ULONG64 GetUlong64(void) throw(...)
    {
        return (ULONG64)GetData(sizeof(ULONG64));
    }
    float GetFloat(void) throw(...)
    {
        GetData(sizeof(float));
        return *(float *)&m_Data;
    }
    double GetDouble(void) throw(...)
    {
        GetData(sizeof(double));
        return *(double *)&m_Data;
    }
    
    //
    // Pointer-size primitive type queries.
    // The data is always promoted to the largest size.
    // Queries are validated against the known data size.
    //
    
    LONG64 GetLongPtr(void) throw(...)
    {
        return g_Ext->m_PtrSize == 8 ?
            (LONG64)GetData(g_Ext->m_PtrSize) :
            (LONG)GetData(g_Ext->m_PtrSize);
    }
    ULONG64 GetUlongPtr(void) throw(...)
    {
        return (ULONG64)GetData(g_Ext->m_PtrSize);
    }

    //
    // Pointer data read, with automatic sign extension.
    //
    
    ULONG64 GetPtr(void) throw(...)
    {
        return g_Ext->m_PtrSize == 8 ?
            GetData(g_Ext->m_PtrSize) :
            (LONG)GetData(g_Ext->m_PtrSize);
    }

    //
    // Buffer reads for larger data.
    //

    ULONG ReadBuffer(__out_bcount(Bytes) PVOID Buffer,
                     __in ULONG Bytes,
                     __in bool MustReadAll = true) throw(...);
    ULONG WriteBuffer(__in_bcount(Bytes) PVOID Buffer,
                      __in ULONG Bytes,
                      __in bool MustReadAll = true) throw(...);
    
    //
    // String reads.
    //

    PSTR GetString(__out_ecount(BufferChars) PSTR Buffer,
                   __in ULONG BufferChars,
                   __in ULONG MaxChars = 1024,
                   __in bool MustFit = false) throw(...);
    PWSTR GetString(__out_ecount(BufferChars) PWSTR Buffer,
                    __in ULONG BufferChars,
                    __in ULONG MaxChars = 1024,
                    __in bool MustFit = false) throw(...);
    
    PCSTR m_Name;
    ULONG64 m_Offset;
    bool m_ValidOffset;
    ULONG m_Bytes;
    ULONG64 m_Data;
    bool m_ValidData;
    bool m_Physical;
    ULONG m_SpaceFlags;

protected:
    void Clear(void)
    {
        m_Name = NULL;
        m_Offset = 0;
        m_ValidOffset = false;
        m_Bytes = 0;
        m_Data = 0;
        m_ValidData = false;
        m_Physical = false;
        m_SpaceFlags = 0;
    }
};

//----------------------------------------------------------------------------
//
// ExtRemoteTyped is an enhanced remote data object that understands
// data typed with type information from symbols.  It is initialized
// to a particular object by symbol or cast, after which it can
// be used like an object of the given type.
//
// All expressions are C++ syntax by default.
//
//----------------------------------------------------------------------------

class ExtRemoteTyped : public ExtRemoteData
{
public:
    ExtRemoteTyped(void)
    {
        Clear();
    }
    ExtRemoteTyped(__in PCSTR Expr) throw(...)
    {
        m_Release = false;
        Set(Expr);
    }
    ExtRemoteTyped(__in const DEBUG_TYPED_DATA* Typed) throw(...)
    {
        m_Release = false;
        Copy(Typed);
    }
    ExtRemoteTyped(__in const ExtRemoteTyped& Typed) throw(...)
    {
        m_Release = false;
        Copy(Typed);
    }
    ExtRemoteTyped(__in PCSTR Expr,
                   __in ULONG64 Offset) throw(...)
    {
        m_Release = false;
        Set(Expr, Offset);
    }
    ExtRemoteTyped(__in PCSTR Type,
                   __in ULONG64 Offset,
                   __in bool PtrTo,
                   __inout_opt PULONG64 CacheCookie = NULL,
                   __in_opt PCSTR LinkField = NULL) throw(...)
    {
        m_Release = false;
        Set(Type, Offset, PtrTo, CacheCookie, LinkField);
    }
    ~ExtRemoteTyped(void)
    {
        Release();
    }

    ExtRemoteTyped& operator=(__in const DEBUG_TYPED_DATA* Typed) throw(...)
    {
        Copy(Typed);
        return *this;
    }
    ExtRemoteTyped& operator=(__in const ExtRemoteTyped& Typed) throw(...)
    {
        Copy(Typed);
        return *this;
    }
    
    void Copy(__in const DEBUG_TYPED_DATA* Typed) throw(...);
    void Copy(__in const ExtRemoteTyped& Typed) throw(...)
    {
        if (Typed.m_Release)
        {
            Copy(&Typed.m_Typed);
        }
        else
        {
            Clear();
        }
    }
    
    void Set(__in PCSTR Expr) throw(...);
    void Set(__in PCSTR Expr,
             __in ULONG64 Offset) throw(...);
    void Set(__in bool PtrTo,
             __in ULONG64 TypeModBase,
             __in ULONG TypeId,
             __in ULONG64 Offset) throw(...);
    void Set(__in PCSTR Type,
             __in ULONG64 Offset,
             __in bool PtrTo,
             __inout_opt PULONG64 CacheCookie = NULL,
             __in_opt PCSTR LinkField = NULL) throw(...);

    // Uses a circle string.
    void WINAPIV SetPrint(__in PCSTR Format,
                          ...) throw(...);

    bool HasField(__in PCSTR Field)
    {
        return ErtIoctl("HasField",
                        EXT_TDOP_HAS_FIELD,
                        ErtIn | ErtIgnoreError,
                        Field) == S_OK;
    }

    ULONG GetTypeSize(void) throw(...)
    {
        ULONG Size;
        
        ErtIoctl("GetTypeSize", EXT_TDOP_GET_TYPE_SIZE, ErtIn,
                 NULL, 0, NULL, NULL, 0, &Size);
        return Size;
    }
    
    ULONG GetFieldOffset(__in PCSTR Field) throw(...);
    
    ExtRemoteTyped Field(__in PCSTR Field) throw(...);
    ExtRemoteTyped ArrayElement(__in LONG64 Index) throw(...);
    ExtRemoteTyped Dereference(void) throw(...);
    ExtRemoteTyped GetPointerTo(void) throw(...);
    ExtRemoteTyped Eval(__in PCSTR Expr) throw(...);

    ExtRemoteTyped operator[](__in LONG Index)
    {
        return ArrayElement(Index);
    }
    ExtRemoteTyped operator[](__in ULONG Index)
    {
        return ArrayElement((LONG64)Index);
    }
    ExtRemoteTyped operator[](__in LONG64 Index)
    {
        return ArrayElement(Index);
    }
    ExtRemoteTyped operator[](__in ULONG64 Index)
    {
        if (Index > 0x7fffffffffffffffUI64)
        {
            g_Ext->ThrowRemote
                (HRESULT_FROM_WIN32(ERROR_ARITHMETIC_OVERFLOW),
                 "Array index too large");
        }
        return ArrayElement((LONG64)Index);
    }
    ExtRemoteTyped operator*(void)
    {
        return Dereference();
    }
    
    // Uses the circular string buffer.
    PSTR GetTypeName(void) throw(...);
    
    void OutTypeName(void) throw(...)
    {
        ErtIoctl("OutTypeName", EXT_TDOP_OUTPUT_TYPE_NAME, ErtIn);
    }
    void OutSimpleValue(void) throw(...)
    {
        ErtIoctl("OutSimpleValue", EXT_TDOP_OUTPUT_SIMPLE_VALUE, ErtIn);
    }
    void OutFullValue(void) throw(...)
    {
        ErtIoctl("OutFullValue", EXT_TDOP_OUTPUT_FULL_VALUE, ErtIn);
    }
    void OutTypeDefinition(void) throw(...)
    {
        ErtIoctl("OutTypeDefinition", EXT_TDOP_OUTPUT_TYPE_DEFINITION, ErtIn);
    }
    
    void Release(void)
    {
        if (m_Release)
        {
            ErtIoctl("Release", EXT_TDOP_RELEASE, ErtIn | ErtIgnoreError);
            Clear();
        }
    }

    static ULONG GetTypeFieldOffset(__in PCSTR Type,
                                    __in PCSTR Field) throw(...);
                                    
    DEBUG_TYPED_DATA m_Typed;
    bool m_Release;

protected:
    static const ULONG ErtIn          = 0x00000001;
    static const ULONG ErtOut         = 0x00000002;
    static const ULONG ErtUncheckedIn = 0x00000004;
    static const ULONG ErtIgnoreError = 0x00000008;
    
    HRESULT ErtIoctl(__in PCSTR Message,
                     __in EXT_TDOP Op,
                     __in ULONG Flags,
                     __in_opt PCSTR InStr = NULL,
                     __in ULONG64 In64 = 0,
                     __out_opt ExtRemoteTyped* Ret = NULL,
                     __out_ecount_opt(StrBufferChars) PSTR StrBuffer = NULL,
                     __in ULONG StrBufferChars = 0,
                     __out_opt PULONG Out32 = NULL);
    void Clear(void);
};

//----------------------------------------------------------------------------
//
// ExtRemoteList wraps a basic singly- or double-linked list.
// It can iterate over the list and retrieve nodes both
// forwards and backwards.  It handles both NULL-terminated
// and lists that are circular through a head pointer (NT-style).
//
// When doubly-linked it is assumed that the previous
// pointer immediately follows the next pointer.
//
//----------------------------------------------------------------------------

class ExtRemoteList
{
public:
    ExtRemoteList(__in ULONG64 Head,
                  __in ULONG LinkOffset,
                  __in bool Double = false)
    {
        m_Head = Head;
        m_LinkOffset = LinkOffset;
        m_Double = Double;
        m_MaxIter = 65536;
    }
    ExtRemoteList(__in ExtRemoteData& Head,
                  __in ULONG LinkOffset,
                  __in bool Double = false)
    {
        m_Head = Head.m_Offset;
        m_LinkOffset = LinkOffset;
        m_Double = Double;
        m_MaxIter = 65536;
    }

    void StartHead(void)
    {
        m_Node.Set(m_Head, g_Ext->m_PtrSize);
        m_CurIter = 0;
    }
    void StartTail(void)
    {
        if (!m_Double)
        {
            g_Ext->ThrowRemote(E_INVALIDARG,
                               "ExtRemoteList is singly-linked");
        }
        
        m_Node.Set(m_Head + g_Ext->m_PtrSize, g_Ext->m_PtrSize);
        m_CurIter = 0;
    }
    bool HasNode(void)
    {
        g_Ext->ThrowInterrupt();
        ULONG64 NodeOffs = m_Node.GetPtr();
        return NodeOffs != 0 && NodeOffs != m_Head;
    }
    ULONG64 GetNodeOffset(void)
    {
        return m_Node.GetPtr() - m_LinkOffset;
    }
    void Next(void)
    {
        if (++m_CurIter > m_MaxIter)
        {
            g_Ext->ThrowRemote(E_INVALIDARG,
                               "List iteration count exceeded, loop assumed");
        }
        
        m_Node.Set(m_Node.GetPtr(), g_Ext->m_PtrSize);
    }
    void Prev(void)
    {
        g_Ext->ThrowInterrupt();

        if (!m_Double)
        {
            g_Ext->ThrowRemote(E_INVALIDARG,
                               "ExtRemoteList is singly-linked");
        }
        
        if (++m_CurIter > m_MaxIter)
        {
            g_Ext->ThrowRemote(E_INVALIDARG,
                               "List iteration count exceeded, loop assumed");
        }
        
        m_Node.Set(m_Node.GetPtr() + g_Ext->m_PtrSize, g_Ext->m_PtrSize);
    }
    
    ULONG64 m_Head;
    ULONG m_LinkOffset;
    bool m_Double;
    ULONG m_MaxIter;
    ExtRemoteData m_Node;
    ULONG m_CurIter;
};

//----------------------------------------------------------------------------
//
// ExtRemoteTypedList enhances the basic ExtRemoteList to
// understand the type of the nodes in the list and to
// automatically determine link offsets from type information.
//
//----------------------------------------------------------------------------

class ExtRemoteTypedList : public ExtRemoteList
{
public:
    ExtRemoteTypedList(__in ULONG64 Head,
                       __in PCSTR Type,
                       __in PCSTR LinkField,
                       __in ULONG64 TypeModBase = 0,
                       __in ULONG TypeId = 0,
                       __inout PULONG64 CacheCookie = NULL,
                       __in bool Double = false) throw(...)
        : ExtRemoteList(Head, 0, Double)
    {
        SetTypeAndLink(Type, LinkField, TypeModBase, TypeId, CacheCookie);
    }
    ExtRemoteTypedList(__in ExtRemoteData& Head,
                       __in PCSTR Type,
                       __in PCSTR LinkField,
                       __in ULONG64 TypeModBase = 0,
                       __in ULONG TypeId = 0,
                       __inout_opt PULONG64 CacheCookie = NULL,
                       __in bool Double = false) throw(...)
        : ExtRemoteList(Head, 0, Double)
    {
        SetTypeAndLink(Type, LinkField, TypeModBase, TypeId, CacheCookie);
    }

    void SetTypeAndLink(__in PCSTR Type,
                        __in PCSTR LinkField,
                        __in ULONG64 TypeModBase = 0,
                        __in ULONG TypeId = 0,
                        __inout_opt PULONG64 CacheCookie = NULL) throw(...)
    {
        m_Type = Type;
        m_TypeModBase = TypeModBase;
        m_TypeId = TypeId;
        if (CacheCookie)
        {
            m_LinkOffset = g_Ext->GetCachedFieldOffset(CacheCookie,
                                                       Type,
                                                       LinkField,
                                                       &m_TypeModBase,
                                                       &m_TypeId);
        }
        else
        {
            m_LinkOffset = ExtRemoteTyped::GetTypeFieldOffset(Type, LinkField);
        }
    }

    ExtRemoteTyped GetTypedNodePtr(void) throw(...)
    {
        ExtRemoteTyped Typed;

        if (m_TypeId)
        {
            Typed.Set(true, m_TypeModBase, m_TypeId,
                      m_Node.GetPtr() - m_LinkOffset);
        }
        else
        {
            Typed.SetPrint("(%s*)0x%I64x",
                           m_Type, m_Node.GetPtr() - m_LinkOffset);

            // Save the type info so that future nodes
            // can be resolved without needing
            // expression evaluation.
            ExtRemoteTyped Deref = Typed.Dereference();
            m_TypeModBase = Deref.m_Typed.ModBase;
            m_TypeId = Deref.m_Typed.TypeId;
        }
        return Typed;
    }
    ExtRemoteTyped GetTypedNode(void) throw(...)
    {
        ExtRemoteTyped Typed;
        
        if (m_TypeId)
        {
            Typed.Set(false, m_TypeModBase, m_TypeId,
                      m_Node.GetPtr() - m_LinkOffset);
        }
        else
        {
            Typed.SetPrint("*(%s*)0x%I64x",
                           m_Type, m_Node.GetPtr() - m_LinkOffset);

            // Save the type info so that future nodes
            // can be resolved without needing
            // expression evaluation.
            m_TypeModBase = Typed.m_Typed.ModBase;
            m_TypeId = Typed.m_Typed.TypeId;
        }
        return Typed;
    }

    PCSTR m_Type;
    ULONG64 m_TypeModBase;
    ULONG m_TypeId;
};

//----------------------------------------------------------------------------
//
// Helpers for handling well-known NT data and types.
//
//----------------------------------------------------------------------------

class ExtNtOsInformation
{
public:
    //
    // Kernel mode.
    //
    
    static ULONG64 GetKernelLoadedModuleListHead(void);
    static ExtRemoteTypedList GetKernelLoadedModuleList(void);
    static ExtRemoteTyped GetKernelLoadedModule(__in ULONG64 Offset);
    
    static ULONG64 GetKernelProcessListHead(void);
    static ExtRemoteTypedList GetKernelProcessList(void);
    static ExtRemoteTyped GetKernelProcess(__in ULONG64 Offset);

    static ULONG64 GetKernelProcessThreadListHead(__in ULONG64 Process);
    static ExtRemoteTypedList GetKernelProcessThreadList(__in ULONG64 Process);
    static ExtRemoteTyped GetKernelThread(__in ULONG64 Offset);
    
    //
    // User mode.
    //

    static ULONG64 GetUserLoadedModuleListHead(__in bool NativeOnly = false);
    static ExtRemoteTypedList
        GetUserLoadedModuleList(__in bool NativeOnly = false);
    static ExtRemoteTyped GetUserLoadedModule(__in ULONG64 Offset,
                                              __in bool NativeOnly = false);

    //
    // PEB and TEB.
    //
    // The alternate PEB and TEB are secondary PEB and TEB
    // data, such as the 32-bit PEB and TEB in a WOW64
    // debugging session.  They may or may not be defined
    // depending on the session.
    //

    static ULONG64 GetOsPebPtr(void);
    static ExtRemoteTyped GetOsPeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetOsPeb(void)
    {
        return GetOsPeb(GetOsPebPtr());
    }
    
    static ULONG64 GetOsTebPtr(void);
    static ExtRemoteTyped GetOsTeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetOsTeb(void)
    {
        return GetOsTeb(GetOsTebPtr());
    }
    
    static ULONG64 GetAltPebPtr(void);
    static ExtRemoteTyped GetAltPeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetAltPeb(void)
    {
        return GetAltPeb(GetAltPebPtr());
    }
    
    static ULONG64 GetAltTebPtr(void);
    static ExtRemoteTyped GetAltTeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetAltTeb(void)
    {
        return GetAltTeb(GetAltTebPtr());
    }
    
    static ULONG64 GetCurPebPtr(void);
    static ExtRemoteTyped GetCurPeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetCurPeb(void)
    {
        return GetCurPeb(GetCurPebPtr());
    }
    
    static ULONG64 GetCurTebPtr(void);
    static ExtRemoteTyped GetCurTeb(__in ULONG64 Offset);
    static ExtRemoteTyped GetCurTeb(void)
    {
        return GetCurTeb(GetCurTebPtr());
    }
    
    //
    // Utilities.
    //

    static ULONG64 GetNtDebuggerData(__in ULONG DataOffset,
                                     __in PCSTR Symbol,
                                     __in ULONG Flags);

protected:
    static ULONG64 s_KernelLoadedModuleBaseInfoCookie;
    static ULONG64 s_KernelProcessBaseInfoCookie;
    static ULONG64 s_KernelThreadBaseInfoCookie;
    static ULONG64 s_KernelProcessThreadListFieldCookie;
    static ULONG64 s_UserOsLoadedModuleBaseInfoCookie;
    static ULONG64 s_UserAltLoadedModuleBaseInfoCookie;
    static ULONG64 s_OsPebBaseInfoCookie;
    static ULONG64 s_AltPebBaseInfoCookie;
    static ULONG64 s_OsTebBaseInfoCookie;
    static ULONG64 s_AltTebBaseInfoCookie;
};

//----------------------------------------------------------------------------
//
// Number-to-string helpers for things like #define translations.
//
//----------------------------------------------------------------------------

//
// Convenience macros for filling define declarations.
//

#define EXT_DEFINE_DECL(_Def) \
    { #_Def, _Def },
#define EXT_DEFINE_END { NULL, 0 }

// In order to avoid #define replacement on the names
// these macros cannot be nested macros.
#define EXT_DEFINE_DECL2(_Def1, _Def2) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }
#define EXT_DEFINE_DECL3(_Def1, _Def2, _Def3) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 }
#define EXT_DEFINE_DECL4(_Def1, _Def2, _Def3, _Def4) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 }, { #_Def4, _Def4 }
#define EXT_DEFINE_DECL5(_Def1, _Def2, _Def3, _Def4, _Def5) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }
#define EXT_DEFINE_DECL6(_Def1, _Def2, _Def3, _Def4, _Def5, _Def6) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }, { #_Def6, _Def6 }
#define EXT_DEFINE_DECL7(_Def1, _Def2, _Def3, _Def4, _Def5, _Def6, _Def7) \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }, { #_Def6, _Def6 }, { #_Def7, _Def7 }

//
// Convenience macros for declaring global maps.
//

#define EXT_DEFINE_MAP_DECL(_Name, _Flags) \
ExtDefineMap g_##_Name##DefineMap(g_##_Name##Defines, _Flags)

#define EXT_DEFINE_MAP1(_Name, _Flags, _Def1) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP2(_Name, _Flags, _Def1, _Def2) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP3(_Name, _Flags, _Def1, _Def2, _Def3) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP4(_Name, _Flags, _Def1, _Def2, _Def3, _Def4) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP5(_Name, _Flags, _Def1, _Def2, _Def3, _Def4, _Def5) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }, EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP6(_Name, _Flags, _Def1, _Def2, _Def3, _Def4, _Def5, _Def6) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }, { #_Def6, _Def6 },\
    EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)
#define EXT_DEFINE_MAP7(_Name, _Flags, _Def1, _Def2, _Def3, _Def4, _Def5, _Def6, _Def7) \
ExtDefine g_##_Name##Defines[] = { \
    { #_Def1, _Def1 }, { #_Def2, _Def2 }, { #_Def3, _Def3 },\
    { #_Def4, _Def4 }, { #_Def5, _Def5 }, { #_Def6, _Def6 },\
    { #_Def7, _Def7 }, EXT_DEFINE_END \
}; EXT_DEFINE_MAP_DECL(_Name, _Flags)

struct ExtDefine
{
    PCSTR Name;
    ULONG64 Value;
};

class ExtDefineMap
{
public:
    ExtDefineMap(__in ExtDefine* Defines,
                 __in ULONG Flags)
    {
        m_Defines = Defines;
        m_Flags = Flags;
    };

    static const ULONG Bitwise         = 0x00000001;
    static const ULONG OutValue        = 0x00000002;
    static const ULONG OutValue32      = 0x00000004;
    static const ULONG OutValue64      = 0x00000008;
    static const ULONG OutValueAny     = OutValue | OutValue32 | OutValue64;
    static const ULONG OutValueAlready = 0x00000010;
    static const ULONG ValueAny        = OutValueAny | OutValueAlready;
    
    // Defines are searched in the order given for
    // defines where the full value of the define is
    // included in the argument value.  Multi-bit
    // defines should come before single-bit defines
    // so that they take priority for bitwise maps.
    ExtDefine* Map(__in ULONG64 Value);
    PCSTR MapStr(__in ULONG64 Value,
                 __in_opt PCSTR InvalidStr = NULL);

    // For a bitwise map, outputs all defines
    // that can be found in the value.
    // For non-bitwise, outputs the matching define.
    // Uses wrapped output.
    void Out(__in ULONG64 Value,
             __in ULONG Flags = 0,
             __in_opt PCSTR InvalidStr = NULL);
    
    ExtDefine* m_Defines;
    ULONG m_Flags;
};

//----------------------------------------------------------------------------
//
// Output capture helper class.
//
//----------------------------------------------------------------------------

template<typename _CharType, typename _BaseClass>
class ExtCaptureOutput : public _BaseClass
{
public:
    ExtCaptureOutput(void)
    {
        m_Started = false;
        m_Text = NULL;
        Delete();
    }
    ~ExtCaptureOutput(void)
    {
        Delete();
    }
    
    // IUnknown.
    STDMETHOD(QueryInterface)(
        THIS_
        __in REFIID InterfaceId,
        __out PVOID* Interface
        )
    {
        *Interface = NULL;

        if (IsEqualIID(InterfaceId, __uuidof(IUnknown)) ||
            IsEqualIID(InterfaceId, __uuidof(_BaseClass)))
        {
            *Interface = (_BaseClass *)this;
            AddRef();
            return S_OK;
        }
        else
        {
            return E_NOINTERFACE;
        }
    }
    STDMETHOD_(ULONG, AddRef)(
        THIS
        )
    {
        // This class is designed to be non-dynamic so
        // there's no true refcount.
        return 1;
    }
    STDMETHOD_(ULONG, Release)(
        THIS
        )
    {
        // This class is designed to be non-dynamic so
        // there's no true refcount.
        return 0;
    }
    
    // IDebugOutputCallbacks*.
    STDMETHOD(Output)(
        THIS_
        __in ULONG Mask,
        __in const _CharType* Text
        )
    {
        ULONG Chars;
        
        if (sizeof(_CharType) == sizeof(char))
        {
            Chars = strlen((PSTR)Text) + 1;
        }
        else
        {
            Chars = wcslen((PWSTR)Text) + 1;
        }
        if (Chars < 2)
        {
            return S_OK;
        }

        if (0xffffffff / sizeof(_CharType) - m_UsedChars < Chars)
        {
            return HRESULT_FROM_WIN32(ERROR_ARITHMETIC_OVERFLOW);
        }

        if (m_UsedChars + Chars > m_AllocChars)
        {
            ULONG NewBytes;

            // Overallocate when growing to prevent
            // continuous allocation.
            if (0xffffffff / sizeof(_CharType) - m_UsedChars - Chars > 256)
            {
                NewBytes = (m_UsedChars + Chars + 256) * sizeof(_CharType);
            }
            else
            {
                NewBytes = (m_UsedChars + Chars) * sizeof(_CharType);
            }
            PVOID NewMem = realloc(m_Text, NewBytes);
            if (!NewMem)
            {
                return E_OUTOFMEMORY;
            }

            m_Text = (_CharType*)NewMem;
            m_AllocChars = NewBytes / sizeof(_CharType);
        }

        memcpy(m_Text + m_UsedChars, Text,
               Chars * sizeof(_CharType));
        // Advance up to but not past the terminator
        // so that it gets overwritten by the next text.
        m_UsedChars += Chars - 1;
        return S_OK;
    }

    void Start(void)
    {
        HRESULT Status;
        
        if (sizeof(_CharType) == sizeof(char))
        {
            if ((Status = g_Ext->m_Client->
                 GetOutputCallbacks((IDebugOutputCallbacks**)
                                    &m_OldOutCb)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to get previous output callback");
            }
            if ((Status = g_Ext->m_Client->
                 SetOutputCallbacks((IDebugOutputCallbacks*)
                                    this)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to set capture output callback");
            }
        }
        else
        {
            if ((Status = g_Ext->m_Client5->
                 GetOutputCallbacksWide((IDebugOutputCallbacksWide**)
                                        &m_OldOutCb)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to get previous output callback");
            }
            if ((Status = g_Ext->m_Client5->
                 SetOutputCallbacksWide((IDebugOutputCallbacksWide*)
                                        this)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to set capture output callback");
            }
        }
            
        m_UsedChars = 0;
        m_Started = true;
    }
    
    void Stop(void)
    {
        HRESULT Status;
        
        m_Started = false;

        if (sizeof(_CharType) == sizeof(char))
        {
            if ((Status = g_Ext->m_Client->
                 SetOutputCallbacks((IDebugOutputCallbacks*)
                                    m_OldOutCb)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to restore output callback");
            }
        }
        else
        {
            if ((Status = g_Ext->m_Client5->
                 SetOutputCallbacksWide((IDebugOutputCallbacksWide*)
                                        m_OldOutCb)) != S_OK)
            {
                g_Ext->ThrowStatus(Status,
                                   "Unable to restore output callback");
            }
        }

        m_OldOutCb = NULL;
    }

    void Delete(void)
    {
        if (m_Started)
        {
            Stop();
        }

        free(m_Text);
        m_Text = NULL;
        m_AllocChars = 0;
        m_UsedChars = 0;
    }

    void Execute(__in PCSTR Command)
    {
        Start();
        
        // Hide all output from the execution
        // and don't save the command.
        g_Ext->m_Control->Execute(DEBUG_OUTCTL_THIS_CLIENT |
                                  DEBUG_OUTCTL_OVERRIDE_MASK |
                                  DEBUG_OUTCTL_NOT_LOGGED,
                                  Command,
                                  DEBUG_EXECUTE_NOT_LOGGED |
                                  DEBUG_EXECUTE_NO_REPEAT);

        Stop();
    }
    
    const _CharType* GetTextNonNull(void)
    {
        if (sizeof(_CharType) == sizeof(char))
        {
            return m_Text ? (PCSTR)m_Text : "";
        }
        else
        {
            return m_Text ? (PCWSTR)m_Text : L"";
        }
    }
    
    bool m_Started;
    ULONG m_AllocChars;
    ULONG m_UsedChars;
    _CharType* m_Text;

    _BaseClass* m_OldOutCb;
};
    
typedef ExtCaptureOutput<char, IDebugOutputCallbacks> ExtCaptureOutputA;
typedef ExtCaptureOutput<WCHAR, IDebugOutputCallbacksWide> ExtCaptureOutputW;

#if _MSC_VER >= 800
#pragma warning(default:4121)
#endif
      
#include <poppack.h>

#endif // #ifndef __ENGEXTCPP_HPP__
