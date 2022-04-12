//----------------------------------------------------------------------------
//
// C++ dbgeng extension framework.
//
// Copyright (C) Microsoft Corporation, 2005-2006.
//
//----------------------------------------------------------------------------

#include <engextcpp.hpp>
#include <strsafe.h>
#include <dbghelp.h>

#if defined(_PREFAST_) || defined(_PREFIX_)
#define PRE_ASSUME(_Cond) __analysis_assume(_Cond)
#else
#define PRE_ASSUME(_Cond)
#endif

#define IsSpace(_Char) isspace((UCHAR)(_Char))

WINDBG_EXTENSION_APIS64 ExtensionApis;
ExtCheckedPointer<ExtExtension>
    g_Ext("g_Ext not set, used outside of a command");

//----------------------------------------------------------------------------
//
// ExtException family.
//
//----------------------------------------------------------------------------

void
ExtException::PrintMessageVa(__in_ecount(BufferChars) PSTR Buffer,
                             __in ULONG BufferChars,
                             __in PCSTR Format,
                             __in va_list Args)
{
    StringCchVPrintfA(Buffer, BufferChars, Format, Args);
    m_Message = Buffer;
}

void WINAPIV
ExtException::PrintMessage(__in_ecount(BufferChars) PSTR Buffer,
                           __in ULONG BufferChars,
                           __in PCSTR Format,
                           ...)
{
    va_list Args;

    va_start(Args, Format);
    PrintMessageVa(Buffer, BufferChars, Format, Args);
    va_end(Args);
}

//----------------------------------------------------------------------------
//
// Holders.
//
//----------------------------------------------------------------------------

void
ExtCurrentThreadHolder::Refresh(void)
{
    HRESULT Status;
    
    if ((Status = g_Ext->m_System->
         GetCurrentThreadId(&m_ThreadId)) != S_OK)
    {
        throw ExtStatusException(Status,
                                 "ExtCurrentThreadHolder::Refresh failed");
    }
}

void
ExtCurrentThreadHolder::Restore(void)
{
    if (m_ThreadId != DEBUG_ANY_ID)
    {
        PRE_ASSUME(g_Ext.IsSet());
        if (g_Ext.IsSet())
        {
            // Ensure that g_Ext-> operator will not throw exception.
            g_Ext->m_System->SetCurrentThreadId(m_ThreadId);
        }
        m_ThreadId = DEBUG_ANY_ID;
    }
}

void
ExtCurrentProcessHolder::Refresh(void)
{
    HRESULT Status;
    
    if ((Status = g_Ext->m_System->
         GetCurrentProcessId(&m_ProcessId)) != S_OK)
    {
        throw ExtStatusException(Status,
                                 "ExtCurrentProcessHolder::Refresh failed");
    }
}

void
ExtCurrentProcessHolder::Restore(void)
{
    if (m_ProcessId != DEBUG_ANY_ID)
    {
        PRE_ASSUME(g_Ext.IsSet());
        if (g_Ext.IsSet())
        {
            // Ensure that g_Ext-> operator will not throw exception.
            g_Ext->m_System->SetCurrentProcessId(m_ProcessId);
        }
        m_ProcessId = DEBUG_ANY_ID;
    }
}

//----------------------------------------------------------------------------
//
// ExtCommandDesc.
//
//----------------------------------------------------------------------------

ExtCommandDesc* ExtCommandDesc::s_Commands;
ULONG ExtCommandDesc::s_LongestCommandName;

ExtCommandDesc::ExtCommandDesc(__in PCSTR Name,
                               __in ExtCommandMethod Method,
                               __in PCSTR Desc,
                               __in_opt PCSTR Args)
{
    m_Name = Name;
    m_Method = Method;
    m_Desc = Desc;
    m_ArgDescStr = Args;

    ClearArgs();

    //
    // Add into command list sorted by name.
    //

    ExtCommandDesc* Cur, *Prev;

    Prev = NULL;
    for (Cur = s_Commands; Cur; Cur = Cur->m_Next)
    {
        if (strcmp(Name, Cur->m_Name) < 0)
        {
            break;
        }

        Prev = Cur;
    }

    if (Prev)
    {
        Prev->m_Next = this;
    }
    else
    {
        s_Commands = this;
    }
    m_Next = Cur;

    if (strlen(Name) > s_LongestCommandName)
    {
        s_LongestCommandName = strlen(Name);
    }
}

ExtCommandDesc::~ExtCommandDesc(void)
{
    DeleteArgs();
}

void
ExtCommandDesc::ClearArgs(void)
{
    m_ArgsInitialized = false;
    m_CustomArgParsing = false;
    m_CustomArgDescLong = NULL;
    m_CustomArgDescShort = NULL;
    m_OptionChars = "/-";
    m_ArgStrings = NULL;
    m_NumArgs = 0;
    m_NumUnnamedArgs = 0;
    m_Args = NULL;
}

void
ExtCommandDesc::DeleteArgs(void)
{
    free(m_ArgStrings);
    delete [] m_Args;
    ClearArgs();
}

PSTR
ExtCommandDesc::ParseDirective(__in PSTR Scan)
{
    //
    // Scan to collect the directive name.
    //

    PSTR Name = Scan;
    while (*Scan != ':' && *Scan != '}')
    {
        if (!*Scan)
        {
            m_Ext->ThrowInvalidArg("ArgDesc: Improper directive "
                                   "name termination");
        }

        Scan++;
    }

    //
    // Scan to collect the directive value.
    //

    PSTR Value = "";
    
    if (*Scan == ':')
    {
        *Scan++ = 0;
        Value = Scan;

        while (*Scan != '}' ||
               *(Scan + 1) != '}')
        {
            if (!*Scan)
            {
                m_Ext->ThrowInvalidArg("ArgDesc: Improper directive "
                                       "value termination");
            }

            Scan++;
        }
    }
    else if (*(Scan + 1) != '}')
    {
        m_Ext->ThrowInvalidArg("ArgDesc: Improper directive }} closure");
    }
    
    // Terminate name or value.
    *Scan = 0;
    Scan += 2;

    //
    // Process directive.
    //

    bool NoValue = false;
    bool NeedValue = false;

    if (!strcmp(Name, "custom"))
    {
        m_CustomArgParsing = true;
        NoValue = true;
    }
    else if (!strcmp(Name, "l"))
    {
        m_CustomArgDescLong = Value;
        NeedValue = true;
    }
    else if (!strcmp(Name, "opt"))
    {
        m_OptionChars = Value;
    }
    else if (!strcmp(Name, "s"))
    {
        m_CustomArgDescShort = Value;
        NeedValue = true;
    }
    else
    {
        m_Ext->ThrowInvalidArg("ArgDesc: Unknown directive '%s'", Name);
    }

    if (!Value[0] && NeedValue)
    {
        m_Ext->ThrowInvalidArg("ArgDesc: {{%s}} requires an argument", Name);
    }
    if (Value[0] && NoValue)
    {
        m_Ext->ThrowInvalidArg("ArgDesc: {{%s}} does not have an argument",
                               Name);
    }
    
    return Scan;
}

void
ExtCommandDesc::ParseArgDesc(void)
{
    //
    // Parse the argument description.
    //

    if (!m_ArgDescStr ||
        !m_ArgDescStr[0])
    {
        // No arguments.
        return;
    }
    
    // First copy the string so we can chop it up.
    m_ArgStrings = _strdup(m_ArgDescStr);
    if (! m_ArgStrings)
    {
        m_Ext->ThrowOutOfMemory();
    }

    // 
    // Each argument description is
    //   {<optname>;<type,flags>;<argname>;<descstr>}
    //

    ArgDesc Args[ExtExtension::s_MaxArgs];
    ArgDesc* Arg = Args - 1;
    ULONG NumUnOptArgs = 0;
    bool RemainderUsed = false;
    
    PSTR Scan = m_ArgStrings;
    
    while (*Scan)
    {
        if (*Scan != '{')
        {
            m_Ext->ThrowInvalidArg("ArgDesc: Missing { at '%s'", Scan);
        }
        Scan++;

        if (*Scan == '{')
        {
            // This is a {{directive}} and not an argument.
            Scan = ParseDirective(++Scan);
            continue;
        }
        
        if (m_NumArgs >= EXT_DIMA(Args))
        {
            m_Ext->ThrowInvalidArg("ArgDesc: Argument count "
                                   "overflow at '%s'", Scan);
        }
        m_NumArgs++;
        Arg++;
        
        //
        // Check for an argument name.
        // Arguments can be unnamed.
        //
        
        if (*Scan == '}' ||
            *Scan == ';')
        {
            Arg->Name = NULL;
            m_NumUnnamedArgs++;
            if (*Scan == ';')
            {
                Scan++;
            }
        }
        else
        {
            Arg->Name = Scan;
            while (*Scan != '}' &&
                   *Scan != ';')
            {
                if (!*Scan)
                {
                    m_Ext->ThrowInvalidArg("ArgDesc: Improper argument "
                                           "name termination for '%s'",
                                           Arg->Name);
                }
                
                Scan++;
            }
            if (*Scan != '}')
            {
                *Scan++ = 0;
            }

            if (Arg->Name[0] == '?' &&
                !Arg->Name[1])
            {
                m_Ext->ThrowInvalidArg("ArgDesc: /? is automatically "
                                       "provided by the framework");
            }
        }

        //
        // Check for a type.
        // Type defaults to string.
        //

        PCSTR TypeName = "ERROR";
        
        Arg->Boolean = false;
        Arg->Expression = false;
        Arg->String = false;
        Arg->StringRemainder = false;
        
        switch(*Scan)
        {
        case 'x':
            Arg->StringRemainder = true;
            __fallthrough;
        case 's':
            Scan++;
            __fallthrough;
        case '}':
        case ';':
        case ',':
            TypeName = "string";
            Arg->String = true;
            break;
        case 'b':
            Scan++;
            Arg->Boolean = true;
            break;
        case 'e':
            Scan++;
            TypeName = "expr";
            Arg->Expression = true;
            Arg->ExpressionBits = 64;
            Arg->ExpressionSigned = false;
            Arg->ExpressionDelimited = false;
            for (;;)
            {
                if (*Scan == 'd')
                {
                    Arg->ExpressionDelimited = true;
                }
                else if (*Scan == 's')
                {
                    Arg->ExpressionSigned = true;
                }
                else
                {
                    break;
                }

                Scan++;
            }
            if (*Scan >= '0' && *Scan <= '9')
            {
                Arg->ExpressionBits = strtoul(Scan, &Scan, 10);
                if (Arg->ExpressionBits < 1 ||
                    Arg->ExpressionBits > 64)
                {
                    m_Ext->ThrowInvalidArg("ArgDesc: "
                                           "Invalid expression bit count %u",
                                           Arg->ExpressionBits);
                }
            }
            break;
        default:
            m_Ext->ThrowInvalidArg("ArgDesc: Unknown argument type at '%s'",
                                   Scan);
            break;
        }

        //
        // Check for flags.
        //

        PSTR NeedTerm = NULL;
        
        Arg->Default = NULL;
        Arg->DefaultSilent = false;
        
        // Unnamed arguments default to
        // required as a required argument
        // tail is a very common pattern.
        Arg->Required = Arg->Name == NULL;

        while (*Scan == ',')
        {
            if (NeedTerm)
            {
                *NeedTerm = 0;
                NeedTerm = NULL;
            }
                
            Scan++;
            switch(*Scan)
            {
            case 'd':
                Scan++;
                switch(*Scan)
                {
                case '=':
                    if (Arg->Boolean)
                    {
                        m_Ext->ThrowInvalidArg("ArgDesc: boolean arguments "
                                               "cannot have defaults");
                    }

                    Arg->Default = ++Scan;
                    while (*Scan &&
                           *Scan != ',' &&
                           *Scan != ';' &&
                           *Scan != '}')
                    {
                        Scan++;
                    }
                    if (*Scan != '}')
                    {
                        NeedTerm = Scan;
                    }
                    break;
                case 's':
                    Scan++;
                    Arg->DefaultSilent = true;
                    break;
                default:
                    m_Ext->ThrowInvalidArg("ArgDesc: "
                                           "Unknown 'd' argument flag at '%s'",
                                           Scan);
                }
                break;
            case 'o':
                Scan++;
                Arg->Required = false;
                break;
            case 'r':
                Scan++;
                Arg->Required = true;
                break;
            default:
                m_Ext->ThrowInvalidArg("ArgDesc: "
                                       "Unknown argument flag at '%s'",
                                       Scan);
            }
        }
        if (*Scan == ';')
        {
            Scan++;
        }
        else if (*Scan != '}')
        {
            m_Ext->ThrowInvalidArg("ArgDesc: Improper argument "
                                   "type/flags termination at '%s'",
                                   Scan);
        }

        if (NeedTerm)
        {
            *NeedTerm = 0;
            NeedTerm = NULL;
        }
                
        if (!Arg->Name)
        {
            if (Arg->Boolean)
            {
                // Not possible to have an unnamed flag
                // since the presence/absence of the flag
                // is what a boolean is for.
                m_Ext->ThrowInvalidArg("ArgDesc: Boolean arguments "
                                       "must be named");
            }

            // Given the lack of placement identification (a name),
            // unnamed arguments are filled in the
            // order they appear in the argument string.
            // That means that a required argument cannot
            // follow an optional argument since there's
            // no way of knowing that the optional argument
            // should be skipped.
            if (!Arg->Required)
            {
                NumUnOptArgs++;
            }
            else
            {
                if (NumUnOptArgs > 0)
                {
                    m_Ext->ThrowInvalidArg("ArgDesc: "
                                           "Required unnamed arguments "
                                           "cannot follow optional "
                                           "unnamed arguments");
                }
            }
        
            if (RemainderUsed)
            {
                m_Ext->ThrowInvalidArg("ArgDesc: "
                                       "Unnamed arguments "
                                       "cannot follow remainder usage");
            }

            if (Arg->StringRemainder)
            {
                RemainderUsed = true;
            }
        }
        
        //
        // Check for a short descriptive argument name.
        //

        if (*Scan == '}' ||
            *Scan == ';')
        {
            // Use a default name so there's always
            // some short description.
            Arg->DescShort = TypeName;
            if (*Scan == ';')
            {
                Scan++;
            }
        }
        else
        {
            Arg->DescShort = Scan;
            while (*Scan != '}' &&
                   *Scan != ';')
            {
                if (!*Scan)
                {
                    m_Ext->ThrowInvalidArg("ArgDesc: "
                                           "Improper short description "
                                           "termination for '%s'",
                                           Arg->Name ?
                                           Arg->Name : "<unnamed>");
                }
                
                Scan++;
            }
            if (*Scan != '}')
            {
                *Scan++ = 0;
            }
        }

        //
        // Check for a long argument description.
        //
        
        if (*Scan == '}')
        {
            Arg->DescLong = NULL;
        }
        else
        {
            Arg->DescLong = Scan;
            while (*Scan != '}')
            {
                if (!*Scan)
                {
                    m_Ext->ThrowInvalidArg("ArgDesc: "
                                           "Improper long description "
                                           "termination for '%s'",
                                           Arg->Name ?
                                           Arg->Name : "<unnamed>");
                }
                
                Scan++;
            }
        }

        //
        // Finished.
        // Terminate whatever was the last string
        // in the description.
        //
        
        if (*Scan != '}')
        {
            m_Ext->ThrowInvalidArg("ArgDesc: Expecting } at '%s'", Scan);
        }

        *Scan++ = 0;
    }

    // Copy temporary array to permanent storage.
    if (m_NumArgs)
    {
        m_Args = new ArgDesc[m_NumArgs];
        if (! m_Args)
        {
            m_Ext->ThrowOutOfMemory();
        }
        memcpy(m_Args, Args, m_NumArgs * sizeof(m_Args[0]));
    }
    
    m_ArgsInitialized = true;
}

void
ExtCommandDesc::ExInitialize(__in ExtExtension* Ext)
{
    m_Ext = Ext;
    
    if (!m_ArgsInitialized)
    {
        try
        {
            ParseArgDesc();
        }
        catch(...)
        {
            DeleteArgs();
            throw;
        }
    }
}

ExtCommandDesc::ArgDesc*
ExtCommandDesc::FindArg(__in PCSTR Name)
{
    ArgDesc* Check = m_Args;
    for (ULONG i = 0; i < m_NumArgs; i++, Check++)
    {
        if (Check->Name &&
            !strcmp(Name, Check->Name))
        {
            return Check;
        }
    }
    return NULL;
}
    
ExtCommandDesc::ArgDesc*
ExtCommandDesc::FindUnnamedArg(__in ULONG Index)
{
    ArgDesc* Check = m_Args;
    for (ULONG i = 0; i < m_NumArgs; i++, Check++)
    {
        if (!Check->Name &&
            Index-- == 0)
        {
            return Check;
        }
    }
    return NULL;
}

void
ExtCommandDesc::Transfer(__out ExtCommandDesc** Commands,
                         __out PULONG LongestName)
{
    *Commands = s_Commands;
    s_Commands = NULL;
    *LongestName = ExtCommandDesc::s_LongestCommandName;
    s_LongestCommandName = 0;
}

//----------------------------------------------------------------------------
//
// ExtExtension.
//
//----------------------------------------------------------------------------

HMODULE ExtExtension::s_Module;
char ExtExtension::s_String[2000];
char ExtExtension::s_CircleStringBuffer[2000];
char* ExtExtension::s_CircleString = s_CircleStringBuffer;

ExtExtension::ExtExtension(void)
    : m_Advanced("The extension did not initialize properly."),
      m_Client("The extension did not initialize properly."),
      m_Control("The extension did not initialize properly."),
      m_Data("The extension did not initialize properly."),
      m_Registers("The extension did not initialize properly."),
      m_Symbols("The extension did not initialize properly."),
      m_System("The extension did not initialize properly."),
      m_Advanced2("The extension requires IDebugAdvanced2."),
      m_Advanced3("The extension requires IDebugAdvanced3."),
      m_Client2("The extension requires IDebugClient2."),
      m_Client3("The extension requires IDebugClient3."),
      m_Client4("The extension requires IDebugClient4."),
      m_Client5("The extension requires IDebugClient5."),
      m_Control2("The extension requires IDebugControl2."),
      m_Control3("The extension requires IDebugControl3."),
      m_Control4("The extension requires IDebugControl4."),
      m_Data2("The extension requires IDebugDataSpaces2."),
      m_Data3("The extension requires IDebugDataSpaces3."),
      m_Data4("The extension requires IDebugDataSpaces4."),
      m_Registers2("The extension requires IDebugRegisters2."),
      m_Symbols2("The extension requires IDebugSymbols2."),
      m_Symbols3("The extension requires IDebugSymbols3."),
      m_System2("The extension requires IDebugSystemObjects2."),
      m_System3("The extension requires IDebugSystemObjects3."),
      m_System4("The extension requires IDebugSystemObjects4.")
{
    m_ExtMajorVersion = 1;
    m_ExtMinorVersion = 0;
    m_ExtInitFlags = DEBUG_EXTINIT_HAS_COMMAND_HELP;

    m_KnownStructs = NULL;
    m_ProvidedValues = NULL;
    
    m_ExInitialized = false;
    m_OutMask = DEBUG_OUTPUT_NORMAL;
    m_CurChar = 0;
    m_LeftIndent = 0;
    m_AllowWrap = true;
    m_TestWrap = 0;

    m_CurCommand = NULL;
    
    m_AppendBuffer = NULL;
    m_AppendBufferChars = 0;
    m_AppendAt = NULL;
}

HRESULT
ExtExtension::Initialize(void)
{
    return S_OK;
}

void
ExtExtension::Uninitialize(void)
{
    // Empty.
}

void
ExtExtension::OnSessionActive(__in ULONG64 Argument)
{
    UNREFERENCED_PARAMETER(Argument);
    // Empty.
}

void
ExtExtension::OnSessionInactive(__in ULONG64 Argument)
{
    UNREFERENCED_PARAMETER(Argument);
    // Empty.
}

void
ExtExtension::OnSessionAccessible(__in ULONG64 Argument)
{
    UNREFERENCED_PARAMETER(Argument);
    // Empty.
}

void
ExtExtension::OnSessionInaccessible(__in ULONG64 Argument)
{
    UNREFERENCED_PARAMETER(Argument);
    // Empty.
}

void WINAPIV
ExtExtension::Out(__in PCSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->OutputVaList(m_OutMask, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Warn(__in PCSTR Format,
                   ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->OutputVaList(DEBUG_OUTPUT_WARNING, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Err(__in PCSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->OutputVaList(DEBUG_OUTPUT_ERROR, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Verb(__in PCSTR Format,
                   ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->OutputVaList(DEBUG_OUTPUT_VERBOSE, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Out(__in PCWSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->OutputVaListWide(m_OutMask, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Warn(__in PCWSTR Format,
                   ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->OutputVaListWide(DEBUG_OUTPUT_WARNING, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Err(__in PCWSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->OutputVaListWide(DEBUG_OUTPUT_ERROR, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Verb(__in PCWSTR Format,
                   ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->OutputVaListWide(DEBUG_OUTPUT_VERBOSE, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Dml(__in PCSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->ControlledOutputVaList(DEBUG_OUTCTL_AMBIENT_DML,
                                      m_OutMask, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlWarn(__in PCSTR Format,
                      ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->ControlledOutputVaList(DEBUG_OUTCTL_AMBIENT_DML,
                                      DEBUG_OUTPUT_WARNING, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlErr(__in PCSTR Format,
                     ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->ControlledOutputVaList(DEBUG_OUTCTL_AMBIENT_DML,
                                      DEBUG_OUTPUT_ERROR, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlVerb(__in PCSTR Format,
                      ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control->ControlledOutputVaList(DEBUG_OUTCTL_AMBIENT_DML,
                                      DEBUG_OUTPUT_VERBOSE, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::Dml(__in PCWSTR Format,
                  ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->ControlledOutputVaListWide(DEBUG_OUTCTL_AMBIENT_DML,
                                           m_OutMask,
                                           Format,
                                           Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlWarn(__in PCWSTR Format,
                      ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->ControlledOutputVaListWide(DEBUG_OUTCTL_AMBIENT_DML,
                                           DEBUG_OUTPUT_WARNING,
                                           Format,
                                           Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlErr(__in PCWSTR Format,
                     ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->ControlledOutputVaListWide(DEBUG_OUTCTL_AMBIENT_DML,
                                           DEBUG_OUTPUT_ERROR,
                                           Format,
                                           Args);
    va_end(Args);
}

void WINAPIV
ExtExtension::DmlVerb(__in PCWSTR Format,
                      ...)
{
    va_list Args;

    va_start(Args, Format);
    m_Control4->ControlledOutputVaListWide(DEBUG_OUTCTL_AMBIENT_DML,
                                           DEBUG_OUTPUT_VERBOSE,
                                           Format,
                                           Args);
    va_end(Args);
}

void
ExtExtension::WrapLine(void)
{
    if (m_LeftIndent)
    {
        m_Control->Output(m_OutMask, "\n%*c", m_LeftIndent, ' ');
    }
    else
    {
        m_Control->Output(m_OutMask, "\n");
    }
    m_CurChar = m_LeftIndent;
}

void
ExtExtension::OutWrapStr(__in PCSTR String)
{
    if (m_TestWrap)
    {
        m_TestWrapChars += strlen(String);
        return;
    }
    
    while (*String)
    {
        //
        // Collect characters until the end or
        // until we run out of output width.
        //

        PCSTR Scan = String;
        PCSTR LastSpace = NULL;
        while (*Scan &&
               *Scan != '\n' &&
               (!m_AllowWrap ||
                !LastSpace ||
                m_CurChar < m_OutputWidth))
        {
            if (*Scan == ' ')
            {
                LastSpace = Scan;
            }
            
            m_CurChar++;
            Scan++;
        }

        if (m_AllowWrap &&
            LastSpace &&
            ((*Scan && *Scan != '\n') ||
             m_CurChar >= m_OutputWidth))
        {
            // We ran out of room, so dump output up
            // to the last space.
            Scan = LastSpace;
        }

        m_Control->Output(m_OutMask, "%.*s", (int)(Scan - String), String);

        if (!*Scan)
        {
            break;
        }

        //
        // Wrap to the next line.
        //
        
        WrapLine();
        String = Scan + 1;
        while (*String == ' ')
        {
            String++;
        }
    }
}

void WINAPIV
ExtExtension::OutWrapVa(__in PCSTR Format,
                        __in va_list Args)
{
    StringCbVPrintf(s_String, sizeof(s_String), Format, Args);
    OutWrapStr(s_String);
}

void WINAPIV
ExtExtension::OutWrap(__in PCSTR Format,
                      ...)
{
    va_list Args;
    
    va_start(Args, Format);
    OutWrapVa(Format, Args);
    va_end(Args);
}

PSTR
ExtExtension::RequestCircleString(__in ULONG Chars)
{
    if (Chars > EXT_DIMA(s_CircleStringBuffer))
    {
        ThrowInvalidArg("Circle string buffer overflow, %u chars", Chars);
    }

    if ((ULONG_PTR)(s_CircleString - s_CircleStringBuffer) >
        EXT_DIMA(s_CircleStringBuffer) - Chars)
    {
        // String is too long to fit in the remainder, wrap around.
        s_CircleString = s_CircleStringBuffer;
    }

    PSTR Str = s_CircleString;
    s_CircleString += Chars;
    return Str;
}

PSTR
ExtExtension::CopyCircleString(__in PCSTR Str)
{
    PSTR Buf;
    ULONG Chars;
    
    Chars = strlen(Str) + 1;
    Buf = RequestCircleString(Chars);
    memcpy(Buf, Str, Chars * sizeof(*Str));
    return Buf;
}

PSTR
ExtExtension::PrintCircleStringVa(__in PCSTR Format,
                                  __in va_list Args)
{
    StringCbVPrintf(s_String, sizeof(s_String), Format, Args);
    return CopyCircleString(s_String);
}

PSTR WINAPIV
ExtExtension::PrintCircleString(__in PCSTR Format,
                                ...)
{
    PSTR Str;
    va_list Args;

    va_start(Args, Format);
    Str = PrintCircleStringVa(Format, Args);
    va_end(Args);
    return Str;
}
    
void
ExtExtension::SetAppendBuffer(__in_ecount(BufferChars) PSTR Buffer,
                              __in ULONG BufferChars)
{
    m_AppendBuffer = Buffer;
    m_AppendBufferChars = BufferChars;
    m_AppendAt = Buffer;
}

void
ExtExtension::AppendBufferString(__in PCSTR Str)
{
    ULONG Chars;
    
    Chars = strlen(Str) + 1;
    if (Chars > m_AppendBufferChars ||
        (ULONG_PTR)(m_AppendAt - m_AppendBuffer) > m_AppendBufferChars - Chars)
    {
        ThrowStatus(HRESULT_FROM_WIN32(ERROR_BUFFER_OVERFLOW),
                    "Append string overflowed");
    }

    memcpy(m_AppendAt, Str, Chars * sizeof(*Str));
    // Position next append where it will overwrite the terminator
    // to continue the existing string.
    m_AppendAt += Chars - 1;
}

void
ExtExtension::AppendStringVa(__in PCSTR Format,
                             __in va_list Args)
{
    if (m_AppendBuffer >= s_String &&
        m_AppendBuffer <= s_String + (EXT_DIMA(s_String) - 1))
    {
        ThrowInvalidArg("Append string buffer cannot use s_String");
    }
    
    StringCbVPrintf(s_String, sizeof(s_String), Format, Args);
    AppendBufferString(s_String);
}

void WINAPIV
ExtExtension::AppendString(__in PCSTR Format,
                           ...)
{
    va_list Args;

    va_start(Args, Format);
    AppendStringVa(Format, Args);
    va_end(Args);
}
    
void
ExtExtension::SetCallStatus(__in HRESULT Status)
{
    // If an error has already been saved don't override it.
    if (!FAILED(m_CallStatus))
    {
        m_CallStatus = Status;
    }
}

ULONG
ExtExtension::GetCachedSymbolTypeId(__inout PULONG64 Cookie,
                                    __in PCSTR Symbol,
                                    __out PULONG64 ModBase)
{
    HRESULT Status;
    DEBUG_CACHED_SYMBOL_INFO Info;

    //
    // Check for an existing cache entry.
    //
        
    if ((Status = m_Advanced2->
         Request(DEBUG_REQUEST_GET_CACHED_SYMBOL_INFO,
                 Cookie,
                 sizeof(*Cookie),
                 &Info,
                 sizeof(Info),
                 NULL)) == S_OK)
    {
        *ModBase = Info.ModBase;
        return Info.Id;
    }

    //
    // No entry in cache, find the data the hard way.
    //

    ZeroMemory(&Info, sizeof(Info));
    
    if ((Status = m_Symbols->
         GetSymbolTypeId(Symbol, 
                         &Info.Id,
                         &Info.ModBase)) != S_OK)
    {
        ThrowStatus(Status, "Unable to get type ID of '%s'",
                    Symbol);
    }

    *ModBase = Info.ModBase;
    
    //
    // Add recovered info to cache.
    // We don't care if this fails as
    // cache addition is not required,
    // we just zero the cookie.
    //

    if (m_Advanced2->
        Request(DEBUG_REQUEST_ADD_CACHED_SYMBOL_INFO,
                &Info,
                sizeof(Info),
                Cookie,
                sizeof(*Cookie),
                NULL) != S_OK)
    {
        *Cookie = 0;
    }

    return Info.Id;
}

ULONG
ExtExtension::GetCachedFieldOffset(__inout PULONG64 Cookie,
                                   __in PCSTR Type,
                                   __in PCSTR Field,
                                   __out_opt PULONG64 TypeModBase,
                                   __out_opt PULONG TypeId)
{
    HRESULT Status;
    DEBUG_CACHED_SYMBOL_INFO Info;

    //
    // Check for an existing cache entry.
    //
        
    if ((Status = m_Advanced2->
         Request(DEBUG_REQUEST_GET_CACHED_SYMBOL_INFO,
                 Cookie,
                 sizeof(*Cookie),
                 &Info,
                 sizeof(Info),
                 NULL)) == S_OK)
    {
        if (TypeModBase)
        {
            *TypeModBase = Info.ModBase;
        }
        if (TypeId)
        {
            *TypeId = Info.Id;
        }
        return Info.Arg3;
    }

    //
    // No entry in cache, find the data the hard way.
    //

    ZeroMemory(&Info, sizeof(Info));
    
    if ((Status = m_Symbols->
         GetSymbolTypeId(Type, 
                         &Info.Id,
                         &Info.ModBase)) != S_OK)
    {
        ThrowStatus(Status, "Unable to get type ID of '%s'",
                    Type);
    }
    if ((Status = m_Symbols->
         GetFieldOffset(Info.ModBase,
                        Info.Id,
                        Field,
                        &Info.Arg3)) != S_OK)
    {
        ThrowStatus(Status, "Unable to get field '%s.%s'",
                    Type, Field);
    }
    
    if (TypeModBase)
    {
        *TypeModBase = Info.ModBase;
    }
    if (TypeId)
    {
        *TypeId = Info.Id;
    }

    //
    // Add recovered info to cache.
    // We don't care if this fails as
    // cache addition is not required,
    // we just zero the cookie.
    //

    if (m_Advanced2->
        Request(DEBUG_REQUEST_ADD_CACHED_SYMBOL_INFO,
                &Info,
                sizeof(Info),
                Cookie,
                sizeof(*Cookie),
                NULL) != S_OK)
    {
        *Cookie = 0;
    }

    return Info.Arg3;
}

bool
ExtExtension::GetCachedSymbolInfo(__in ULONG64 Cookie,
                                  __out PDEBUG_CACHED_SYMBOL_INFO Info)
{
    HRESULT Status;
    
    if ((Status = m_Advanced2->
         Request(DEBUG_REQUEST_GET_CACHED_SYMBOL_INFO,
                 &Cookie,
                 sizeof(Cookie),
                 Info,
                 sizeof(*Info),
                 NULL)) == S_OK)
    {
        return true;
    }
    
    return false;
}

bool
ExtExtension::AddCachedSymbolInfo(__in PDEBUG_CACHED_SYMBOL_INFO Info,
                                  __in bool ThrowFailure,
                                  __out PULONG64 Cookie)
{
    HRESULT Status;
    
    if ((Status = m_Advanced2->
         Request(DEBUG_REQUEST_ADD_CACHED_SYMBOL_INFO,
                 Info,
                 sizeof(*Info),
                 Cookie,
                 sizeof(*Cookie),
                 NULL)) == S_OK)
    {
        return true;
    }
    
    if (ThrowFailure)
    {
        ThrowStatus(Status, "Unable to cache symbol info");
    }

    return false;
}

void
ExtExtension::GetModuleImagehlpInfo(__in ULONG64 ModBase,
                                    __out struct _IMAGEHLP_MODULEW64* Info)
{
    HRESULT Status;

    ZeroMemory(Info, sizeof(*Info));
    Info->SizeOfStruct = sizeof(*Info);
    
    if ((Status = m_Advanced2->
         GetSymbolInformation(DEBUG_SYMINFO_IMAGEHLP_MODULEW64,
                              ModBase,
                              0,
                              Info,
                              Info->SizeOfStruct,
                              NULL,
                              NULL,
                              0,
                              NULL)) != S_OK)
    {
        ThrowStatus(Status, "Unable to retrieve module info");
    }
}

bool
ExtExtension::ModuleHasGlobalSymbols(__in ULONG64 ModBase)
{
    IMAGEHLP_MODULEW64 Info;

    GetModuleImagehlpInfo(ModBase, &Info);
    return Info.GlobalSymbols != FALSE;
}

bool
ExtExtension::ModuleHasTypeInfo(__in ULONG64 ModBase)
{
    IMAGEHLP_MODULEW64 Info;
    
    GetModuleImagehlpInfo(ModBase, &Info);
    return Info.TypeInfo != FALSE;
}

PCSTR
ExtExtension::GetUnnamedArgStr(__in ULONG Index)
{
    if (Index >= m_NumUnnamedArgs)
    {
        ThrowInvalidArg("Invalid unnamed argument index %u, only given %u",
                        Index + 1, m_NumUnnamedArgs);
    }
    if (!m_Args[Index].StrVal)
    {
        ThrowInvalidArg("Unnamed argument index %u is not a string",
                        Index + 1);
    }

    return m_Args[Index].StrVal;
}

ULONG64
ExtExtension::GetUnnamedArgU64(__in ULONG Index)
{
    if (Index >= m_NumUnnamedArgs)
    {
        ThrowInvalidArg("Invalid unnamed argument index %u, only given %u",
                        Index + 1, m_NumUnnamedArgs);
    }
    if (m_Args[Index].StrVal)
    {
        ThrowInvalidArg("Unnamed argument index %u is not a number",
                        Index + 1);
    }

    return m_Args[Index].NumVal;
}

PCSTR
ExtExtension::GetArgStr(__in PCSTR Name,
                        __in bool Required)
{
    ArgVal* Arg = FindArg(Name, Required);
    if (!Arg)
    {
        return NULL;
    }
    if (!Arg->StrVal)
    {
        ThrowInvalidArg("Argument /%s is not a string",
                        Name);
    }
    return Arg->StrVal;
}

ULONG64
ExtExtension::GetArgU64(__in PCSTR Name,
                        __in bool Required)
{
    ArgVal* Arg = FindArg(Name, Required);
    if (!Arg)
    {
        return 0;
    }
    if (Arg->StrVal)
    {
        ThrowInvalidArg("Argument /%s is not a number",
                        Name);
    }
    return Arg->NumVal;
}

bool
ExtExtension::SetUnnamedArg(__in ULONG Index,
                            __in_opt PCSTR StrArg,
                            __in ULONG64 NumArg,
                            __in bool OnlyIfUnset)
{
    ExtCommandDesc::ArgDesc* Check = m_CurCommand->FindUnnamedArg(Index);
    if (!Check)
    {
        ThrowInvalidArg("Unnamed argument index %u too large", Index);
    }

    ArgVal* Val = NULL;
    
    if (HasUnnamedArg(Index))
    {
        if (OnlyIfUnset)
        {
            return false;
        }

        Val = &m_Args[Index];
    }

    SetRawArgVal(Check, Val, true, StrArg, false, NumArg);
    return true;
}

bool
ExtExtension::SetArg(__in PCSTR Name,
                     __in_opt PCSTR StrArg,
                     __in ULONG64 NumArg,
                     __in bool OnlyIfUnset)
{
    ExtCommandDesc::ArgDesc* Check = m_CurCommand->FindArg(Name);
    if (!Check)
    {
        ThrowInvalidArg("No argument named '%s'", Name);
    }

    ArgVal* Val = FindArg(Name, false);

    if (Val)
    {
        if (OnlyIfUnset)
        {
            return false;
        }
    }

    SetRawArgVal(Check, Val, true, StrArg, false, NumArg);
    return true;
}

PCSTR
ExtExtension::GetExpr64(__in PCSTR Str,
                        __in bool Signed,
                        __in ULONG64 Limit,
                        __out PULONG64 Val)
{
    HRESULT Status;
    DEBUG_VALUE FullVal;
    ULONG EndIdx;

    if ((Status = m_Control->
         Evaluate(Str, DEBUG_VALUE_INT64, &FullVal, &EndIdx)) != S_OK)
    {
        ExtStatusException Ex(Status);

        Ex.PrintMessage(s_String, EXT_DIMA(s_String),
                        "Unable to evaluate expression '%s'", Str);
        throw Ex;
    }
    if ((!Signed &&
         FullVal.I64 > Limit) ||
        (Signed &&
         ((LONG64)FullVal.I64 < -(LONG64)Limit ||
          (LONG64)FullVal.I64 > (LONG64)Limit)))
    {
        ThrowInvalidArg("Result overflow in expression '%s'", Str);
    }

    *Val = FullVal.I64;
    Str += EndIdx;

    while (IsSpace(*Str))
    {
        Str++;
    }

    return Str;
}

void WINAPIV
ExtExtension::ThrowInvalidArg(__in PCSTR Format,
                              ...)
{
    ExtInvalidArgumentException Ex("");
    va_list Args;

    va_start(Args, Format);
    Ex.PrintMessageVa(s_String, EXT_DIMA(s_String),
                      Format, Args);
    va_end(Args);
    throw Ex;
}

void WINAPIV
ExtExtension::ThrowRemote(__in HRESULT Status,
                          __in PCSTR Format,
                          ...)
{
    ExtRemoteException Ex(Status, "");
    va_list Args;

    va_start(Args, Format);
    Ex.PrintMessageVa(s_String, EXT_DIMA(s_String),
                      Format, Args);
    va_end(Args);
    throw Ex;
}

void WINAPIV
ExtExtension::ThrowStatus(__in HRESULT Status,
                          __in PCSTR Format,
                          ...)
{
    ExtStatusException Ex(Status);
    va_list Args;

    va_start(Args, Format);
    Ex.PrintMessageVa(s_String, EXT_DIMA(s_String),
                      Format, Args);
    va_end(Args);
    throw Ex;
}

void
ExtExtension::ExInitialize(void)
{
    if (m_ExInitialized)
    {
        return;
    }

    m_ExInitialized = true;

    //
    // Special initialization pass that
    // is done when output can be produced
    // and exceptions thrown.
    // This pass allows verbose feedback on
    // errors, as opposed to the DLL-load Initialize().
    //
}

#define REQ_IF(_If, _Member) \
    if ((Status = Start->QueryInterface(__uuidof(_If), \
                                        (PVOID*)&_Member)) != S_OK) \
    { \
        goto Exit; \
    }
#define OPT_IF(_If, _Member) \
    if ((Status = Start->QueryInterface(__uuidof(_If), \
                                        (PVOID*)&_Member)) != S_OK) \
    { \
        _Member.Set(NULL); \
    }

HRESULT
ExtExtension::Query(__in PDEBUG_CLIENT Start)
{
    HRESULT Status;

    // We don't support nested queries.
    if (*&m_Advanced != NULL)
    {
        return E_UNEXPECTED;
    }

    m_ArgCopy = NULL;
    
    REQ_IF(IDebugAdvanced, m_Advanced);
    REQ_IF(IDebugClient, m_Client);
    REQ_IF(IDebugControl, m_Control);
    REQ_IF(IDebugDataSpaces, m_Data);
    REQ_IF(IDebugRegisters, m_Registers);
    REQ_IF(IDebugSymbols, m_Symbols);
    REQ_IF(IDebugSystemObjects, m_System);
    
    OPT_IF(IDebugAdvanced2, m_Advanced2);
    OPT_IF(IDebugAdvanced3, m_Advanced3);
    OPT_IF(IDebugClient2, m_Client2);
    OPT_IF(IDebugClient3, m_Client3);
    OPT_IF(IDebugClient4, m_Client4);
    OPT_IF(IDebugClient5, m_Client5);
    OPT_IF(IDebugControl2, m_Control2);
    OPT_IF(IDebugControl3, m_Control3);
    OPT_IF(IDebugControl4, m_Control4);
    OPT_IF(IDebugDataSpaces2, m_Data2);
    OPT_IF(IDebugDataSpaces3, m_Data3);
    OPT_IF(IDebugDataSpaces4, m_Data4);
    OPT_IF(IDebugRegisters2, m_Registers2);
    OPT_IF(IDebugSymbols2, m_Symbols2);
    OPT_IF(IDebugSymbols3, m_Symbols3);
    OPT_IF(IDebugSystemObjects2, m_System2);
    OPT_IF(IDebugSystemObjects3, m_System3);
    OPT_IF(IDebugSystemObjects4, m_System4);

    // If this isn't a dump target GetDumpFormatFlags
    // will fail, so just zero the flags.  People
    // checking should check the class and qualifier
    // first so having them zeroed is not a problem.
    if (!m_Control2.IsSet() ||
        m_Control2->GetDumpFormatFlags(&m_DumpFormatFlags) != S_OK)
    {
        m_DumpFormatFlags = 0;
    }
    
    if ((Status = m_Control->
         GetDebuggeeType(&m_DebuggeeClass,
                         &m_DebuggeeQual)) != S_OK ||
        (Status = m_Client->
         GetOutputWidth(&m_OutputWidth)) != S_OK ||
        (Status = m_Control->
         GetActualProcessorType(&m_ActualMachine)) != S_OK ||
        (Status = m_Control->
         GetEffectiveProcessorType(&m_Machine)) != S_OK ||
        (Status = m_Control->
         GetPageSize(&m_PageSize)) != S_OK ||
        // IsPointer64Bit check must be last as Status
        // is used to compute the pointer size below.
        FAILED(Status = m_Control->
               IsPointer64Bit()))
    {
        goto Exit;
    }
    if (Status == S_OK)
    {
        m_PtrSize = 8;
        m_OffsetMask = 0xffffffffffffffffUI64;
    }
    else
    {
        m_PtrSize = 4;
        m_OffsetMask = 0xffffffffUI64;
    }

    // User targets may fail a processor count request.
    if (m_Control->GetNumberProcessors(&m_NumProcessors) != S_OK)
    {
        m_NumProcessors = 0;
    }
        
    ExtensionApis.nSize = sizeof(ExtensionApis);
    Status = m_Control->GetWindbgExtensionApis64(&ExtensionApis);
    if (Status == RPC_E_CALL_REJECTED)
    {
        // GetWindbgExtensionApis64 is not remotable,
        // and this particular failure means we
        // are running remotely.  Go on without any
        // wdbgexts support.
        ZeroMemory(&ExtensionApis, sizeof(ExtensionApis));
        m_IsRemote = true;
        Status = S_OK;
    }
    else
    {
        m_IsRemote = false;
    }

    RefreshOutputCallbackFlags();

 Exit:
    if (Status != S_OK)
    {
        if (*&m_Control != NULL)
        {
            m_Control->Output(DEBUG_OUTPUT_ERROR,
                              "ERROR: Unable to query interfaces, 0x%08x\n",
                              Status);
        }
        Release();
    }
    return Status;
}

void
ExtExtension::Release(void)
{
    EXT_RELEASE(m_Advanced);
    EXT_RELEASE(m_Client);
    EXT_RELEASE(m_Control);
    EXT_RELEASE(m_Data);
    EXT_RELEASE(m_Registers);
    EXT_RELEASE(m_Symbols);
    EXT_RELEASE(m_System);
    EXT_RELEASE(m_Advanced2);
    EXT_RELEASE(m_Advanced3);
    EXT_RELEASE(m_Client2);
    EXT_RELEASE(m_Client3);
    EXT_RELEASE(m_Client4);
    EXT_RELEASE(m_Client5);
    EXT_RELEASE(m_Control2);
    EXT_RELEASE(m_Control3);
    EXT_RELEASE(m_Control4);
    EXT_RELEASE(m_Data2);
    EXT_RELEASE(m_Data3);
    EXT_RELEASE(m_Data4);
    EXT_RELEASE(m_Registers2);
    EXT_RELEASE(m_Symbols2);
    EXT_RELEASE(m_Symbols3);
    EXT_RELEASE(m_System2);
    EXT_RELEASE(m_System3);
    EXT_RELEASE(m_System4);
    ZeroMemory(&ExtensionApis, sizeof(ExtensionApis));
    free(m_ArgCopy);
    m_ArgCopy = NULL;
    m_CurCommand = NULL;
}

HRESULT
ExtExtension::CallCommandMethod(__in ExtCommandDesc* Desc,
                                __in_opt PCSTR Args)
{
    HRESULT Status;
    
    try
    {
        ExInitialize();
        Desc->ExInitialize(this);
        
        ParseArgs(Desc, Args);
        
        m_CallStatus = S_OK;
        // Release NULLs this out.
        m_CurCommand = Desc;

        (this->*Desc->m_Method)();

        Status = m_CallStatus;
    }
    catch(ExtInterruptException Ex)
    {
        m_Control->Output(DEBUG_OUTPUT_ERROR, "!%s: %s.\n",
                          Desc->m_Name, Ex.GetMessage());
        Status = Ex.GetStatus();
    }
    catch(ExtException Ex)
    {
        if (Ex.GetMessage())
        {
            if (FAILED(Ex.GetStatus()))
            {
                m_Control->
                    Output(DEBUG_OUTPUT_ERROR,
                           "ERROR: !%s: extension exception "
                           "0x%08x.\n    \"%s\"\n",
                           Desc->m_Name, Ex.GetStatus(), Ex.GetMessage());
            }
            else
            {
                m_Control->Output(DEBUG_OUTPUT_NORMAL, "!%s: %s\n",
                                  Desc->m_Name, Ex.GetMessage());
            }
        }
        else if (Ex.GetStatus() != DEBUG_EXTENSION_CONTINUE_SEARCH &&
                 Ex.GetStatus() != DEBUG_EXTENSION_RELOAD_EXTENSION &&
                 FAILED(Ex.GetStatus()))
        {
            m_Control->
                Output(DEBUG_OUTPUT_ERROR,
                       "ERROR: !%s: extension exception 0x%08x.\n",
                       Desc->m_Name, Ex.GetStatus());
        }
        Status = Ex.GetStatus();
    }

    return Status;
}

HRESULT
ExtExtension::CallCommand(__in ExtCommandDesc* Desc,
                          __in PDEBUG_CLIENT Client,
                          __in_opt PCSTR Args)
{
    HRESULT Status = Query(Client);
    if (Status != S_OK)
    {
        return Status;
    }

    // Use a hard SEH try/finally to guarantee that
    // Release always occurs.
    __try
    {
        Status = CallCommandMethod(Desc, Args);
    }
    __finally
    {
        Release();
    }

    return Status;
}

HRESULT
ExtExtension::CallKnownStructMethod(__in ExtKnownStruct* Struct,
                                    __in ULONG Flags,
                                    __in ULONG64 Offset,
                                    __out_ecount(*BufferChars) PSTR Buffer,
                                    __inout PULONG BufferChars)
{
    HRESULT Status;
    
    try
    {
        ExInitialize();
        SetAppendBuffer(Buffer, *BufferChars);
        
        m_CallStatus = S_OK;

        (this->*Struct->Method)(Struct->TypeName, Flags, Offset);

        Status = m_CallStatus;
    }
    catch(ExtException Ex)
    {
        Status = Ex.GetStatus();
    }

    return Status;
}

HRESULT
ExtExtension::CallKnownStruct(__in PDEBUG_CLIENT Client,
                              __in ExtKnownStruct* Struct,
                              __in ULONG Flags,
                              __in ULONG64 Offset,
                              __out_ecount(*BufferChars) PSTR Buffer,
                              __inout PULONG BufferChars)
{
    HRESULT Status = Query(Client);
    if (Status != S_OK)
    {
        return Status;
    }

    // Use a hard SEH try/finally to guarantee that
    // Release always occurs.
    __try
    {
        Status = CallKnownStructMethod(Struct, Flags, Offset,
                                       Buffer, BufferChars);
    }
    __finally
    {
        Release();
    }

    return Status;
}

HRESULT
ExtExtension::HandleKnownStruct(__in PDEBUG_CLIENT Client,
                                __in ULONG Flags,
                                __in ULONG64 Offset,
                                __in_opt PCSTR TypeName,
                                __out_ecount_opt(*BufferChars) PSTR Buffer,
                                __inout_opt PULONG BufferChars)
{
    HRESULT Status;
    ExtKnownStruct* Struct = m_KnownStructs;
    
    if (Flags == DEBUG_KNOWN_STRUCT_GET_NAMES &&
        Buffer != NULL &&
        *BufferChars > 0)
    {
        ULONG CharsNeeded;
        
        //
        // Return names of known structs packed in
        // the output buffer.
        //

        // Save a character for the double terminator.
        (*BufferChars)--;
        CharsNeeded = 1;

        Status = S_OK;
        while (Struct && Struct->TypeName)
        {
            ULONG Chars = strlen(Struct->TypeName) + 1;
            CharsNeeded += Chars;
            
            if (Status != S_OK || *BufferChars < Chars)
            {
                Status = S_FALSE;
            }
            else
            {
                memcpy(Buffer, Struct->TypeName, Chars * sizeof(*Buffer));
                Buffer += Chars;
                (*BufferChars) -= Chars;
            }
            
            Struct++;
        }

        *Buffer = 0;
        *BufferChars = CharsNeeded;
    }
    else if (Flags == DEBUG_KNOWN_STRUCT_GET_SINGLE_LINE_OUTPUT &&
             Buffer != NULL &&
             BufferChars > 0)
    {
        //
        // Dispatch request to method.
        //

        Status = E_NOINTERFACE;
        while (Struct && Struct->TypeName)
        {
            if (!strcmp(TypeName, Struct->TypeName))
            {
                Status = CallKnownStruct(Client, Struct, Flags, Offset,
                                         Buffer, BufferChars);
                break;
            }

            Struct++;
        }
    }
    else if (Flags == DEBUG_KNOWN_STRUCT_SUPPRESS_TYPE_NAME)
    {
        //
        // Determine if formatting method suppresses the type name.
        //

        Status = E_NOINTERFACE;
        while (Struct && Struct->TypeName)
        {
            if (!strcmp(TypeName, Struct->TypeName))
            {
                Status = Struct->SuppressesTypeName ? S_OK : S_FALSE;
                break;
            }

            Struct++;
        }
    }
    else
    {
        Status = E_INVALIDARG;
    }

    return Status;
}

HRESULT
ExtExtension::HandleQueryValueNames(__in PDEBUG_CLIENT Client,
                                    __in ULONG Flags,
                                    __out_ecount(BufferChars) PWSTR Buffer,
                                    __in ULONG BufferChars,
                                    __out PULONG BufferNeeded)
{
    HRESULT Status;

    UNREFERENCED_PARAMETER(Client);
    UNREFERENCED_PARAMETER(Flags);

    if (Buffer == NULL ||
        BufferChars < 1)
    {
        return E_INVALIDARG;
    }
    
    ExtProvidedValue* ExtVal = m_ProvidedValues;
    ULONG CharsNeeded;
        
    //
    // Return names of values packed in
    // the output buffer.
    //

    // Save a character for the double terminator.
    BufferChars--;
    CharsNeeded = 1;

    Status = S_OK;
    while (ExtVal && ExtVal->ValueName)
    {
        ULONG Chars = wcslen(ExtVal->ValueName) + 1;
        CharsNeeded += Chars;
            
        if (Status != S_OK || BufferChars < Chars)
        {
            Status = S_FALSE;
        }
        else
        {
            memcpy(Buffer, ExtVal->ValueName, Chars * sizeof(*Buffer));
            Buffer += Chars;
            BufferChars -= Chars;
        }
            
        ExtVal++;
    }

    *Buffer = 0;
    *BufferNeeded = CharsNeeded;

    return Status;
}

HRESULT
ExtExtension::CallProvideValueMethod(__in ExtProvidedValue* ExtVal,
                                     __in ULONG Flags,
                                     __out PULONG64 Value,
                                     __out PULONG64 TypeModBase,
                                     __out PULONG TypeId,
                                     __out PULONG TypeFlags)
{
    HRESULT Status;
    
    try
    {
        ExInitialize();
        
        m_CallStatus = S_OK;

        (this->*ExtVal->Method)(Flags, ExtVal->ValueName,
                                Value, TypeModBase, TypeId, TypeFlags);

        Status = m_CallStatus;
    }
    catch(ExtException Ex)
    {
        Status = Ex.GetStatus();
    }

    return Status;
}

HRESULT
ExtExtension::HandleProvideValue(__in PDEBUG_CLIENT Client,
                                 __in ULONG Flags,
                                 __in PCWSTR Name,
                                 __out PULONG64 Value,
                                 __out PULONG64 TypeModBase,
                                 __out PULONG TypeId,
                                 __out PULONG TypeFlags)
{
    HRESULT Status = Query(Client);
    if (Status != S_OK)
    {
        return Status;
    }

    // Use a hard SEH try/finally to guarantee that
    // Release always occurs.
    __try
    {
        ExtProvidedValue* ExtVal = m_ProvidedValues;
        while (ExtVal && ExtVal->ValueName)
        {
            if (wcscmp(Name, ExtVal->ValueName) == 0)
            {
                break;
            }

            ExtVal++;
        }
        if (!ExtVal)
        {
            Status = E_UNEXPECTED;
        }
        else
        {
            Status = CallProvideValueMethod(ExtVal, Flags,
                                            Value, TypeModBase,
                                            TypeId, TypeFlags);
        }
    }
    __finally
    {
        Release();
    }

    return Status;
}

ExtExtension::ArgVal*
ExtExtension::FindArg(__in PCSTR Name,
                      __in bool Required)
{
    ULONG i;

    for (i = m_FirstNamedArg; i < m_FirstNamedArg + m_NumNamedArgs; i++)
    {
        if (!strcmp(Name, m_Args[i].Name))
        {
            return &m_Args[i];
        }
    }

    if (Required)
    {
        ThrowInvalidArg("No argument /%s was provided", Name);
    }
    
    return NULL;
}

PCSTR
ExtExtension::SetRawArgVal(__in ExtCommandDesc::ArgDesc* Check,
                           __in_opt ArgVal* Val,
                           __in bool ExplicitVal,
                           __in_opt PCSTR StrVal,
                           __in bool StrWritable,
                           __in ULONG64 NumVal)
{
    if (!Val)
    {
        if (Check->Name)
        {
            if (m_NumNamedArgs + m_FirstNamedArg >= EXT_DIMA(m_Args))
            {
                ThrowInvalidArg("Argument overflow on '%s'",
                                Check->Name);
            }

            Val = &m_Args[m_NumNamedArgs + m_FirstNamedArg];
            m_NumArgs++;
            m_NumNamedArgs++;
        }
        else
        {
            Val = &m_Args[m_NumUnnamedArgs];
            m_NumArgs++;
            m_NumUnnamedArgs++;
        }
    }

    Check->Present = true;
    Val->Name = Check->Name;
    Val->StrVal = NULL;
    Val->NumVal = 0;

    if (Check->Boolean)
    {
        return StrVal;
    }

    if (StrVal)
    {
        while (IsSpace(*StrVal))
        {
            StrVal++;
        }
        if (!*StrVal &&
            !ExplicitVal)
        {
            ThrowInvalidArg("Missing value for argument '%s'",
                            Check->Name);
        }

        if (Check->String)
        {
            Val->StrVal = StrVal;
            if (Check->StringRemainder)
            {
                StrVal += strlen(StrVal);
            }
            else
            {
                while (*StrVal && !IsSpace(*StrVal))
                {
                    StrVal++;
                }
            }
        }
        else if (Check->Expression)
        {
            PSTR StrEnd = NULL;
            char StrEndChar = 0;
            
            if (Check->ExpressionDelimited)
            {
                StrEnd = (PSTR)StrVal;
                while (*StrEnd && !IsSpace(*StrEnd))
                {
                    StrEnd++;
                }
                if (IsSpace(*StrEnd))
                {
                    //
                    // We found some trailing text so we need
                    // to force a terminator to delimit the
                    // expression.  We can only do this if
                    // we make a copy of the string or have
                    // a writable string.  As any case where a
                    // non-writable string is passed in involves
                    // a caller setting an argument explicitly they
                    // can provide a properly-terminated expression,
                    // so don't support copying.
                    //
                    
                    if (!StrWritable)
                    {
                        ThrowInvalidArg("Delimited expressions can "
                                        "only be parsed from extension "
                                        "command arguments");
                    }

                    StrEndChar = *StrEnd;
                    *StrEnd = 0;
                }
                else
                {
                    // No trailing text so no need to force
                    // termination.
                    StrEnd = NULL;
                }
            }
            
            StrVal = GetExpr64(StrVal,
                               Check->ExpressionSigned != 0,
                               (0xffffffffffffffffUI64 >>
                                (64 - Check->ExpressionBits)),
                               &Val->NumVal);

            if (StrEnd)
            {
                *StrEnd = StrEndChar;
            }
        }
    }
    else if (Check->String)
    {
        ThrowInvalidArg("Missing value for argument '%s'",
                        Check->Name);
    }
    else
    {
        Val->NumVal = NumVal;
    }

    return StrVal;
}

void
ExtExtension::ParseArgs(__in ExtCommandDesc* Desc,
                        __in_opt PCSTR Args)
{
    if (!Args)
    {
        Args = "";
    }

    m_RawArgStr = Args;
    m_NumArgs = 0;
    m_NumNamedArgs = 0;
    m_NumUnnamedArgs = 0;
    m_FirstNamedArg = Desc->m_NumUnnamedArgs;

    //
    // First make a copy of the argument string as
    // we will need to chop it up when parsing.
    // Release() automatically cleans this up.
    //

    m_ArgCopy = _strdup(Args);
    if (!m_ArgCopy)
    {
        ThrowOutOfMemory();
    }

    if (Desc->m_CustomArgParsing)
    {
        return;
    }
    
    PSTR Scan = m_ArgCopy;
    bool ImplicitNamedArg = false;
    ULONG i;
    ExtCommandDesc::ArgDesc* Check;
    
    Check = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Check++)
    {
        Check->Present = false;
    }

    for (;;)
    {
        while (IsSpace(*Scan))
        {
            ImplicitNamedArg = false;
            Scan++;
        }
        if (!*Scan)
        {
            break;
        }

        if (ImplicitNamedArg ||
            strchr(Desc->m_OptionChars, *Scan) != NULL)
        {
            //
            // Named argument.  Collect name and
            // see if this is a valid argument.
            //

            if (!ImplicitNamedArg)
            {
                Scan++;

                // If /? is given at any point immediately
                // go help for the command and exit.
                if (*Scan == '?' &&
                    (!*(Scan + 1) || IsSpace(*(Scan + 1))))
                {
                    HelpCommand(Desc);
                    throw ExtStatusException(S_OK);
                }
            }
            
            PSTR Start = Scan++;
            while (*Scan && !IsSpace(*Scan))
            {
                Scan++;
            }
            char Save = *Scan;
            *Scan = 0;

            //
            // First check for a full name match.
            //

            if (!ImplicitNamedArg)
            {
                Check = Desc->m_Args;
                for (i = 0; i < Desc->m_NumArgs; i++, Check++)
                {
                    if (!Check->Name)
                    {
                        continue;
                    }
                
                    if (!strcmp(Start, Check->Name))
                    {
                        break;
                    }
                }
            }
            else
            {
                i = Desc->m_NumArgs;
            }
            if (i >= Desc->m_NumArgs)
            {
                //
                // Didn't find it with a full name match,
                // so check for a single-character match.
                // This is only allowed for single-character
                // boolean options.
                //

                ImplicitNamedArg = false;

                Check = Desc->m_Args;
                for (i = 0; i < Desc->m_NumArgs; i++, Check++)
                {
                    if (!Check->Name ||
                        !Check->Boolean)
                    {
                        continue;
                    }
                
                    if (*Start == Check->Name[0] &&
                        !Check->Name[1])
                    {
                        // Multiple single-character options
                        // can be combined with a single slash,
                        // so the next character should be
                        // checked as a named option.
                        ImplicitNamedArg = true;
                        break;
                    }
                }
            }
            if (i >= Desc->m_NumArgs)
            {
                ThrowInvalidArg("Unrecognized argument '%s'",
                                Start);
            }

            //
            // Found the argument.  Validate it.
            //

            if (Check->Present)
            {
                ThrowInvalidArg("Duplicate argument '%s'",
                                Start);
            }
            
            //
            // Argument is valid, fix up the scan string
            // and move to value processing.
            //
            
            *Scan = Save;
            if (ImplicitNamedArg)
            {
                Scan = Start + 1;
            }
        }
        else
        {
            //
            // Unnamed argument.
            // Find the n'th unnamed argument description
            // and use it.
            //

            Check = Desc->FindUnnamedArg(m_NumUnnamedArgs);
            if (! Check)
            {
                ThrowInvalidArg("Extra unnamed argument at '%s'",
                                Scan);
            }
        }

        //
        // We have an argument description, so
        // look for any appropriate value.
        //

        Scan = (PSTR)SetRawArgVal(Check, NULL, false, Scan, true, 0);
        if (Check->String && *Scan)
        {
            *Scan++ = 0;
        }
    }

    //
    // Fill in default values where needed.
    //
    
    Check = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Check++)
    {
        if (!Check->Present &&
            Check->Default)
        {
            SetRawArgVal(Check, NULL, true, Check->Default, false, 0);
        }
    }

    //
    // Verify that all required arguments are present.
    //

    ULONG NumUnPresent = 0;
    Check = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Check++)
    {
        if (!Check->Name)
        {
            NumUnPresent++;
        }
        
        if (Check->Required &&
            !Check->Present)
        {
            if (Check->Name)
            {
                ThrowInvalidArg("Missing required argument '%s'",
                                Check->Name);
            }
            else if (Check->DescShort)
            {
                ThrowInvalidArg("Missing required argument '<%s>'",
                                Check->DescShort);
            }
            else
            {
                ThrowInvalidArg("Missing unnamed argument %u",
                                NumUnPresent);
            }
        }
    }
}

void
ExtExtension::OutCommandArg(__in ExtCommandDesc::ArgDesc* Arg,
                            __in bool Separate)
{
    if (Arg->Name)
    {
        if (Separate)
        {
            OutWrapStr("/");
        }
        
        OutWrapStr(Arg->Name);

        if (!Arg->Boolean)
        {
            OutWrapStr(" ");
        }
    }

    if (!Arg->Boolean)
    {
        OutWrap("<%s>", Arg->DescShort);
    }
}

void
ExtExtension::HelpCommandArgsSummary(__in ExtCommandDesc* Desc)
{
    ULONG i;
    ExtCommandDesc::ArgDesc* Arg;
    bool Hit;

    if (Desc->m_CustomArgDescShort)
    {
        OutWrapStr(Desc->m_CustomArgDescShort);
        return;
    }
    
    //
    // In order to try and make things pretty we make
    // several passes over the arguments.
    //

    //
    // Display all optional single-char booleans as a collection.
    //

    Hit = false;
    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (Arg->Boolean && !Arg->Required && !Arg->Name[1])
        {
            if (!Hit)
            {
                OutWrapStr(" [/");
                Hit = true;
                AllowWrap(false);
            }

            OutWrapStr(Arg->Name);
        }
    }
    if (Hit)
    {
        OutWrapStr("]");
        AllowWrap(true);
    }
    
    //
    // Display all optional multi-char booleans.
    //

    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (Arg->Boolean && !Arg->Required && Arg->Name[1])
        {
            OutWrap(" [/%s]", Arg->Name);
        }
    }
    
    //
    // Display all required single-char booleans as a collection.
    //

    Hit = false;
    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (Arg->Boolean && Arg->Required && !Arg->Name[1])
        {
            if (!Hit)
            {
                OutWrapStr(" /");
                Hit = true;
                AllowWrap(false);
            }

            OutWrapStr(Arg->Name);
        }
    }
    AllowWrap(true);

    //
    // Display all required multi-char booleans.
    //

    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (Arg->Boolean && Arg->Required && Arg->Name[1])
        {
            OutWrap(" /%s", Arg->Name);
        }
    }

    //
    // Display all optional named non-booleans.
    //

    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (!Arg->Boolean && !Arg->Required && Arg->Name)
        {
            TestWrap(true);
            OutCommandArg(Arg, true);
            TestWrap(false);
            if (!DemandWrap(m_TestWrapChars + 3))
            {
                OutWrapStr(" ");
            }
            OutWrapStr("[");
            AllowWrap(false);
            OutCommandArg(Arg, true);
            OutWrapStr("]");
            AllowWrap(true);
        }
    }

    //
    // Display all required named non-booleans.
    //

    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (!Arg->Boolean && Arg->Required && Arg->Name)
        {
            TestWrap(true);
            OutCommandArg(Arg, true);
            TestWrap(false);
            if (!DemandWrap(m_TestWrapChars + 1))
            {
                OutWrapStr(" ");
            }
            AllowWrap(false);
            OutCommandArg(Arg, true);
            AllowWrap(true);
        }
    }

    //
    // Display all unnamed arguments.  As any optional
    // unnamed argument must be last we can handle both
    // optional and required in a single pass.
    //

    Arg = Desc->m_Args;
    for (i = 0; i < Desc->m_NumArgs; i++, Arg++)
    {
        if (!Arg->Boolean && !Arg->Name)
        {
            TestWrap(true);
            OutCommandArg(Arg, true);
            TestWrap(false);
            if (!Arg->Required)
            {
                m_TestWrapChars += 2;
            }
            if (!DemandWrap(m_TestWrapChars + 1))
            {
                OutWrapStr(" ");
            }
            if (!Arg->Required)
            {
                OutWrapStr("[");
            }
            AllowWrap(false);
            OutCommandArg(Arg, true);
            if (!Arg->Required)
            {
                OutWrapStr("]");
            }
            AllowWrap(true);
        }
    }
}

void
ExtExtension::HelpCommand(__in ExtCommandDesc* Desc)
{
    ULONG i;

    Desc->ExInitialize(this);
    
    m_CurChar = 0;
    OutWrap("!%s", Desc->m_Name);
    m_LeftIndent = m_CurChar + 1;
    HelpCommandArgsSummary(Desc);
    m_LeftIndent = 0;
    OutWrapStr("\n");

    if (Desc->m_CustomArgDescLong)
    {
        OutWrapStr("  ");
        m_LeftIndent = m_CurChar;
        OutWrapStr(Desc->m_CustomArgDescLong);
        m_LeftIndent = 0;
        OutWrapStr("\n");
    }
    else
    {
        ExtCommandDesc::ArgDesc* Arg = Desc->m_Args;
        for (i = 0; i < Desc->m_NumArgs; i++)
        {
            OutWrapStr("  ");
            OutCommandArg(Arg, true);
            
            if (Arg->DescLong)
            {
                OutWrapStr(" - ");
                m_LeftIndent = m_CurChar;
                
                OutWrapStr(Arg->DescLong);
                
                if (Arg->Default &&
                    !Arg->DefaultSilent)
                {
                    OutWrapStr(" (defaults to ");
                    OutWrapStr(Arg->Default);
                    OutWrapStr(")");
                }
            }
            else if (Arg->Default &&
                     !Arg->DefaultSilent)
            {
                OutWrapStr(" - ");
                m_LeftIndent = m_CurChar;
                OutWrapStr("defaults to ");
                OutWrapStr(Arg->Default);
            }
            
            m_LeftIndent = 0;
            OutWrapStr("\n");
            Arg++;
        }
    }
    
    OutWrapStr(Desc->m_Desc);
    Out("\n");
}

void
ExtExtension::HelpCommandName(__in PCSTR Name)
{
    ExtCommandDesc* Desc = m_Commands;
    while (Desc)
    {
        if (!strcmp(Name, Desc->m_Name))
        {
            break;
        }

        Desc = Desc->m_Next;
    }
    if (!Desc)
    {
        ThrowInvalidArg("No command named '%s'", Name);
    }

    HelpCommand(Desc);
}

void
ExtExtension::HelpAll(void)
{
    char ModName[2 * MAX_PATH];

    if (!GetModuleFileName(s_Module, ModName, EXT_DIMA(ModName)))
    {
        StringCbCopyA(ModName, sizeof(ModName),
                      "<Unable to get DLL name>");
    }

    Out("Commands for %s:\n", ModName);
    m_CurChar = 0;
    
    ExtCommandDesc* Desc = m_Commands;
    while (Desc)
    {
        ULONG NameLen = strlen(Desc->m_Name);
        OutWrap("  !%s%*c- ",
                Desc->m_Name,
                m_LongestCommandName - NameLen + 1, ' ');
        m_LeftIndent = m_CurChar;
        OutWrapStr(Desc->m_Desc);
        m_LeftIndent = 0;

        OutWrapStr("\n");

        Desc = Desc->m_Next;
    }

    Out("!help <cmd> will give more information for a particular command\n");
}

EXT_CLASS_COMMAND(ExtExtension,
                  help,
                  "Displays information on available extension commands",
                  "{;s,o;command;Command to get information on}")
{
    if (HasUnnamedArg(0))
    {
        HelpCommandName(GetUnnamedArgStr(0));
    }
    else
    {
        HelpAll();
        SetCallStatus(DEBUG_EXTENSION_CONTINUE_SEARCH);
    }
}

//----------------------------------------------------------------------------
//
// Global forwarders for common methods.
//
//----------------------------------------------------------------------------

void WINAPIV
ExtOut(__in PCSTR Format, ...)
{
    g_Ext.Throw();

    va_list Args;

    va_start(Args, Format);
    g_Ext->m_Control->
        OutputVaList(DEBUG_OUTPUT_NORMAL, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtWarn(__in PCSTR Format, ...)
{
    g_Ext.Throw();

    va_list Args;

    va_start(Args, Format);
    g_Ext->m_Control->
        OutputVaList(DEBUG_OUTPUT_WARNING, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtErr(__in PCSTR Format, ...)
{
    g_Ext.Throw();

    va_list Args;

    va_start(Args, Format);
    g_Ext->m_Control->
        OutputVaList(DEBUG_OUTPUT_ERROR, Format, Args);
    va_end(Args);
}

void WINAPIV
ExtVerb(__in PCSTR Format, ...)
{
    g_Ext.Throw();

    va_list Args;

    va_start(Args, Format);
    g_Ext->m_Control->
        OutputVaList(DEBUG_OUTPUT_VERBOSE, Format, Args);
    va_end(Args);
}

//----------------------------------------------------------------------------
//
// ExtRemoteData.
//
//----------------------------------------------------------------------------

void
ExtRemoteData::Set(__in const DEBUG_TYPED_DATA* Typed)
{
    m_Offset = Typed->Offset;
    m_ValidOffset = (Typed->Flags & DEBUG_TYPED_DATA_IS_IN_MEMORY) != 0;
    m_Bytes = Typed->Size;
    m_Data = Typed->Data;
    m_ValidData = Typed->Size > 0 && Typed->Size <= sizeof(m_Data);
}

void
ExtRemoteData::Read(void)
{
    g_Ext->ThrowInterrupt();
    
    // Zero data so that unread bytes have a known state.
    ULONG64 NewData = 0;

#pragma prefast(suppress:__WARNING_REDUNDANTTEST, "valid redundancy")
    if (m_Bytes > sizeof(m_Data) ||
        m_Bytes > sizeof(NewData))
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData::Read too large");
    }

    ReadBuffer(&NewData, m_Bytes);
    m_Data = NewData;
    m_ValidData = true;
}

void
ExtRemoteData::Write(void)
{
    g_Ext->ThrowInterrupt();
    
    if (m_Bytes > sizeof(m_Data))
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData::Write too large");
    }
    if (!m_ValidData)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have valid data");
    }

    WriteBuffer(&m_Data, m_Bytes);
}

ULONG64
ExtRemoteData::GetData(__in ULONG Request)
{
    g_Ext->ThrowInterrupt();
    
    if (m_Bytes != Request)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "Invalid ExtRemoteData size");
    }
    if (!m_ValidData)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have valid data");
    }

    return m_Data;
}

ULONG
ExtRemoteData::ReadBuffer(__out_bcount(Bytes) PVOID Buffer,
                          __in ULONG Bytes,
                          __in bool MustReadAll)
{
    HRESULT Status;
    ULONG Done;

    g_Ext->ThrowInterrupt();
    
    if (!Bytes)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "Zero-sized ExtRemoteData");
    }
    if (!m_ValidOffset)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have a valid address");
    }

    if (m_Physical)
    {
        Status = g_Ext->m_Data4->
            ReadPhysical2(m_Offset, m_SpaceFlags, Buffer, Bytes, &Done);
    }
    else
    {
        Status = g_Ext->m_Data->
            ReadVirtual(m_Offset, Buffer, Bytes, &Done);
    }
    if (Status == S_OK && Done != Bytes && MustReadAll)
    {
        Status = HRESULT_FROM_WIN32(ERROR_READ_FAULT);
    }
    if (Status != S_OK)
    {
        if (m_Name)
        {
            g_Ext->ThrowRemote(Status, "Unable to read %s at %p",
                               m_Name, m_Offset);
        }
        else
        {
            g_Ext->ThrowRemote(Status, "Unable to read 0x%x bytes at %p",
                               Bytes, m_Offset);
        }
    }

    return Done;
}

ULONG
ExtRemoteData::WriteBuffer(__in_bcount(Bytes) PVOID Buffer,
                           __in ULONG Bytes,
                           __in bool MustReadAll)
{
    HRESULT Status;
    ULONG Done;

    UNREFERENCED_PARAMETER(Buffer);

    g_Ext->ThrowInterrupt();

    if (!Bytes)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "Zero-sized ExtRemoteData");
    }
    if (!m_ValidOffset)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have a valid address");
    }

    if (m_Physical)
    {
        Status = g_Ext->m_Data4->
            WritePhysical2(m_Offset, m_SpaceFlags, &m_Data, Bytes, &Done);
    }
    else
    {
        Status = g_Ext->m_Data->
            WriteVirtual(m_Offset, &m_Data, Bytes, &Done);
    }
    if (Status == S_OK && Done != Bytes && MustReadAll)
    {
        Status = HRESULT_FROM_WIN32(ERROR_WRITE_FAULT);
    }
    if (Status != S_OK)
    {
        if (m_Name)
        {
            g_Ext->ThrowRemote(Status, "Unable to write %s at %p",
                               m_Name, m_Offset);
        }
        else
        {
            g_Ext->ThrowRemote(Status, "Unable to write 0x%x bytes at %p",
                               Bytes, m_Offset);
        }
    }

    return Done;
}

PSTR
ExtRemoteData::GetString(__out_ecount(BufferChars) PSTR Buffer,
                         __in ULONG BufferChars,
                         __in ULONG MaxChars,
                         __in bool MustFit)
{
    HRESULT Status;
    
    g_Ext->ThrowInterrupt();
    
    if (!m_ValidOffset)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have a valid address");
    }
    if (m_Physical)
    {
        g_Ext->ThrowRemote(E_NOTIMPL,
                           "ExtRemoteData cannot read strings "
                           "from physical memory");
    }

    ULONG Need;
    
    if (FAILED(Status = g_Ext->m_Data4->
               ReadMultiByteStringVirtual(m_Offset, MaxChars * sizeof(*Buffer),
                                          Buffer, BufferChars, &Need)))
    {
        g_Ext->ThrowRemote(Status, "Unable to read string at %p",
                           m_Offset);
    }
    if (Status != S_OK && MustFit)
    {
        g_Ext->ThrowRemote(HRESULT_FROM_WIN32(ERROR_BUFFER_OVERFLOW),
                           "String at %p overflows buffer, need 0x%x chars",
                           m_Offset, Need);
    }

    return Buffer;
}

PWSTR
ExtRemoteData::GetString(__out_ecount(BufferChars) PWSTR Buffer,
                         __in ULONG BufferChars,
                         __in ULONG MaxChars,
                         __in bool MustFit)
{
    HRESULT Status;
    
    g_Ext->ThrowInterrupt();
    
    if (!m_ValidOffset)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "ExtRemoteData does not have a valid address");
    }
    if (m_Physical)
    {
        g_Ext->ThrowRemote(E_NOTIMPL,
                           "ExtRemoteData cannot read strings "
                           "from physical memory");
    }

    ULONG Need;
    
    if (FAILED(Status = g_Ext->m_Data4->
               ReadUnicodeStringVirtualWide(m_Offset,
                                            MaxChars * sizeof(*Buffer),
                                            Buffer, BufferChars, &Need)))
    {
        g_Ext->ThrowRemote(Status, "Unable to read string at %p",
                           m_Offset);
    }
    if (Status != S_OK && MustFit)
    {
        g_Ext->ThrowRemote(HRESULT_FROM_WIN32(ERROR_BUFFER_OVERFLOW),
                           "String at %p overflows buffer, need 0x%x chars",
                           m_Offset, Need);
    }

    return Buffer;
}

//----------------------------------------------------------------------------
//
// ExtRemoteTyped.
//
//----------------------------------------------------------------------------

void
ExtRemoteTyped::Copy(__in const DEBUG_TYPED_DATA* Source)
{
    m_Typed = *Source;
    ErtIoctl("Copy", EXT_TDOP_COPY, ErtUncheckedIn | ErtOut);
}

void
ExtRemoteTyped::Set(__in PCSTR Expr)
{
    EXT_TDOP Op;
    ULONG Flags = ErtOut;
    
    // If we have a valid value let it be used
    // in the expression if desired.
    if (m_Release)
    {
        Op = EXT_TDOP_EVALUATE;
        Flags |= ErtIn;
    }
    else
    {
        Op = EXT_TDOP_SET_FROM_EXPR;
    }

    PSTR Msg = g_Ext->
        PrintCircleString("Set: unable to evaluate '%s'", Expr);
    ErtIoctl(Msg, Op, Flags, Expr);
}

void
ExtRemoteTyped::Set(__in PCSTR Expr,
                    __in ULONG64 Offset)
{
    m_Typed.Offset = Offset;
    PSTR Msg = g_Ext->
        PrintCircleString("Set: unable to evaluate '%s' for 0x%I64x",
                          Expr, Offset);
    ErtIoctl(Msg, EXT_TDOP_SET_FROM_U64_EXPR, ErtUncheckedIn | ErtOut, Expr);
}

void
ExtRemoteTyped::Set(__in bool PtrTo,
                    __in ULONG64 TypeModBase,
                    __in ULONG TypeId,
                    __in ULONG64 Offset)
{
    HRESULT Status;
    EXT_TYPED_DATA ExtData;

    g_Ext->ThrowInterrupt();

    ZeroMemory(&ExtData, sizeof(ExtData));
    ExtData.Operation = PtrTo ?
        EXT_TDOP_SET_PTR_FROM_TYPE_ID_AND_U64 :
        EXT_TDOP_SET_FROM_TYPE_ID_AND_U64;
    if (m_Physical)
    {
        ExtData.Flags |= (m_SpaceFlags + 1) << 1;
    }
    ExtData.InData.ModBase = TypeModBase;
    ExtData.InData.TypeId = TypeId;
    ExtData.InData.Offset = Offset;
    
    Status = g_Ext->m_Advanced2->
        Request(DEBUG_REQUEST_EXT_TYPED_DATA_ANSI,
                &ExtData, sizeof(ExtData),
                &ExtData, sizeof(ExtData),
                NULL);
    if (SUCCEEDED(Status))
    {
        Status = ExtData.Status;
    }

    if (FAILED(Status))
    {
        g_Ext->ThrowRemote(Status,
                           "ExtRemoteTyped::Set from type and offset");
    }

    Release();
    m_Typed = ExtData.OutData;
    ExtRemoteData::Set(&m_Typed);
    m_Release = true;
}

void
ExtRemoteTyped::Set(__in PCSTR Type,
                    __in ULONG64 Offset,
                    __in bool PtrTo,
                    __inout_opt PULONG64 CacheCookie,
                    __in_opt PCSTR LinkField)
{
    HRESULT Status;
    ULONG64 TypeModBase;
    ULONG TypeId;
    
    if (!CacheCookie)
    {
        if ((Status = g_Ext->m_Symbols->
             GetSymbolTypeId(Type, 
                             &TypeId,
                             &TypeModBase)) != S_OK)
        {
            g_Ext->ThrowStatus(Status, "Unable to get type ID of '%s'",
                               Type);
        }
    }
    else
    {
        if (LinkField)
        {
            // We don't really need the field offset
            // here but it allows us to use cache
            // entries that were created for list
            // usage and so do have it.
            g_Ext->GetCachedFieldOffset(CacheCookie,
                                        Type,
                                        LinkField,
                                        &TypeModBase,
                                        &TypeId);
        }
        else
        {
            TypeId = g_Ext->GetCachedSymbolTypeId(CacheCookie,
                                                  Type,
                                                  &TypeModBase);
        }
    }
        
    Set(PtrTo, TypeModBase, TypeId, Offset);
}

void WINAPIV
ExtRemoteTyped::SetPrint(__in PCSTR Format,
                         ...)
{
    HRESULT Status;
    va_list Args;
    
    va_start(Args, Format);
    Status = StringCbVPrintfA(g_Ext->s_String, sizeof(g_Ext->s_String),
                              Format, Args);
    va_end(Args);
    if (Status != S_OK)
    {
        g_Ext->ThrowRemote(Status,
                           "ExtRemoteTyped::SetPrint: overflow on '%s'",
                           Format);
    }
    Set(g_Ext->CopyCircleString(g_Ext->s_String));
}

ULONG
ExtRemoteTyped::GetFieldOffset(__in PCSTR Field) throw(...)
{
    ULONG Offset;
    PSTR Msg = g_Ext->
        PrintCircleString("GetFieldOffset: no field '%s'",
                          Field);
    ErtIoctl(Msg, EXT_TDOP_GET_FIELD_OFFSET, ErtIn, Field, 0, NULL,
             NULL, 0, &Offset);
    return Offset;
}

ExtRemoteTyped
ExtRemoteTyped::Field(__in PCSTR Field)
{
    ExtRemoteTyped Ret;
    
    PSTR Msg = g_Ext->
        PrintCircleString("Field: unable to retrieve field '%s' at %I64x",
                          Field, m_Offset);
    ErtIoctl(Msg, EXT_TDOP_GET_FIELD, ErtIn | ErtOut, Field, 0, &Ret);
    return Ret;
}

ExtRemoteTyped
ExtRemoteTyped::ArrayElement(__in LONG64 Index)
{
    ExtRemoteTyped Ret;

    PSTR Msg = g_Ext->
        PrintCircleString("ArrayElement: unable to retrieve element %I64d",
                          Index);
    ErtIoctl(Msg, EXT_TDOP_GET_ARRAY_ELEMENT,
             ErtIn | ErtOut, NULL, Index, &Ret);
    return Ret;
}

ExtRemoteTyped
ExtRemoteTyped::Dereference(void)
{
    ExtRemoteTyped Ret;

    ErtIoctl("Dereference", EXT_TDOP_GET_DEREFERENCE,
             ErtIn | ErtOut, NULL, 0, &Ret);
    return Ret;
}

ExtRemoteTyped
ExtRemoteTyped::GetPointerTo(void)
{
    ExtRemoteTyped Ret;

    ErtIoctl("GetPointerTo", EXT_TDOP_GET_POINTER_TO,
             ErtIn | ErtOut, NULL, 0, &Ret);
    return Ret;
}

ExtRemoteTyped
ExtRemoteTyped::Eval(__in PCSTR Expr)
{
    ExtRemoteTyped Ret;
    
    PSTR Msg = g_Ext->
        PrintCircleString("Eval: unable to evaluate '%s'",
                          Expr);
    ErtIoctl(Msg, EXT_TDOP_EVALUATE, ErtIn | ErtOut, Expr, 0, &Ret);
    return Ret;
}

PSTR
ExtRemoteTyped::GetTypeName(void)
{
    ErtIoctl("GetTypeName", EXT_TDOP_GET_TYPE_NAME, ErtIn, NULL, 0, NULL,
             g_Ext->s_String, EXT_DIMA(g_Ext->s_String));
    return g_Ext->CopyCircleString(g_Ext->s_String);
}

ULONG
ExtRemoteTyped::GetTypeFieldOffset(__in PCSTR Type,
                                   __in PCSTR Field)
{
    HRESULT Status;
    DEBUG_VALUE Data;
    PSTR Expr;

    Expr = g_Ext->PrintCircleString("@@c++(#FIELD_OFFSET(%s, %s))",
                                    Type, Field);
    if (FAILED(Status = g_Ext->m_Control->
               Evaluate(Expr, DEBUG_VALUE_INT64, &Data, NULL)))
    {
        g_Ext->ThrowRemote(Status,
                           "Could not find type field %s.%s",
                           Type, Field);
    }

    return (ULONG)Data.I64;
}

HRESULT
ExtRemoteTyped::ErtIoctl(__in PCSTR Message,
                         __in EXT_TDOP Op,
                         __in ULONG Flags,
                         __in_opt PCSTR InStr,
                         __in ULONG64 In64,
                         __out_opt ExtRemoteTyped* Ret,
                         __out_ecount_opt(StrBufferChars) PSTR StrBuffer,
                         __in ULONG StrBufferChars,
                         __out_opt PULONG Out32)
{
    HRESULT Status;
    ULONG64 StackExtData[(sizeof(EXT_TYPED_DATA) + 11 * sizeof(ULONG64) - 1) /
                        sizeof(ULONG64)];
    EXT_TYPED_DATA* ExtData;
    ULONG ExtDataBytes;
    PBYTE ExtraData;

    C_ASSERT(EXT_TDF_PHYSICAL_MEMORY == DEBUG_TYPED_DATA_PHYSICAL_MEMORY);
    
    g_Ext->ThrowInterrupt();

    ExtDataBytes = sizeof(*ExtData) +
        StrBufferChars * sizeof(*StrBuffer);
    if (InStr)
    {
        ExtDataBytes += (strlen(InStr) + 1) * sizeof(*InStr);
    }

    if (ExtDataBytes > sizeof(StackExtData))
    {
        ExtData = (EXT_TYPED_DATA*)malloc(ExtDataBytes);
        if (!ExtData)
        {
            return E_OUTOFMEMORY;
        }
    }
    else
    {
        ExtData = (EXT_TYPED_DATA*)&StackExtData;
    }
    ExtraData = (PBYTE)(ExtData + 1);
    
    ZeroMemory(ExtData, sizeof(*ExtData));
    ExtData->Operation = Op;
    if (m_Physical)
    {
        ExtData->Flags |= (m_SpaceFlags + 1) << 1;
    }
    if (InStr)
    {
        ExtData->InStrIndex = (ULONG)(ExtraData - (PBYTE)ExtData);
        memcpy(ExtraData, InStr,
               (strlen(InStr) + 1) * sizeof(*InStr));
        ExtraData += (strlen(InStr) + 1) * sizeof(*InStr);
    }
    ExtData->In64 = In64;
    if (StrBuffer)
    {
        ExtData->StrBufferIndex = (ULONG)(ExtraData - (PBYTE)ExtData);
        ExtData->StrBufferChars = StrBufferChars;
        ExtraData += StrBufferChars * sizeof(*StrBuffer);
    }
    
    if ((Flags & (ErtIn | ErtUncheckedIn)) != 0)
    {
        if ((Flags & ErtIn) != 0 && !m_Release)
        {
            g_Ext->ThrowRemote(E_INVALIDARG,
                               "ExtRemoteTyped::%s", Message);
        }

        ExtData->InData = m_Typed;
    }

    Status = g_Ext->m_Advanced2->
        Request(DEBUG_REQUEST_EXT_TYPED_DATA_ANSI,
                ExtData, ExtDataBytes,
                ExtData, ExtDataBytes,
                NULL);
    if (SUCCEEDED(Status))
    {
        Status = ExtData->Status;
    }

    if ((Flags & ErtIgnoreError) == 0 &&
        FAILED(Status))
    {
        g_Ext->ThrowRemote(Status,
                           "ExtRemoteTyped::%s", Message);
    }

    if ((Flags & ErtOut) != 0)
    {
        if (!Ret)
        {
            Ret = this;
        }

        Ret->Release();
        Ret->m_Typed = ExtData->OutData;
        Ret->ExtRemoteData::Set(&Ret->m_Typed);
        Ret->m_Release = true;
    }

    if (StrBuffer)
    {
        memcpy(StrBuffer, (PBYTE)ExtData + ExtData->StrBufferIndex,
               StrBufferChars * sizeof(*StrBuffer));
    }
    
    if (Out32)
    {
        *Out32 = ExtData->Out32;
    }

    if ((PULONG64)ExtData != StackExtData)
    {
        free(ExtData);
    }
    
    return Status;
}

void
ExtRemoteTyped::Clear(void)
{
    ZeroMemory(&m_Typed, sizeof(m_Typed));
    m_Release = false;
    ExtRemoteData::Clear();
}

//----------------------------------------------------------------------------
//
// Helpers for handling well-known NT data and types.
//
//----------------------------------------------------------------------------

ULONG64 ExtNtOsInformation::s_KernelLoadedModuleBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_KernelProcessBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_KernelThreadBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_KernelProcessThreadListFieldCookie;
ULONG64 ExtNtOsInformation::s_UserOsLoadedModuleBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_UserAltLoadedModuleBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_OsPebBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_AltPebBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_OsTebBaseInfoCookie;
ULONG64 ExtNtOsInformation::s_AltTebBaseInfoCookie;

ULONG64
ExtNtOsInformation::GetKernelLoadedModuleListHead(void)
{
    return GetNtDebuggerData(DEBUG_DATA_PsLoadedModuleListAddr,
                             "nt!PsLoadedModuleList",
                             0);
}

ExtRemoteTypedList
ExtNtOsInformation::GetKernelLoadedModuleList(void)
{
    ExtRemoteTypedList List(GetKernelLoadedModuleListHead(),
                            "nt!_KLDR_DATA_TABLE_ENTRY",
                            "InLoadOrderLinks",
                            0,
                            0,
                            &s_KernelLoadedModuleBaseInfoCookie,
                            true);
    List.m_MaxIter = 1000;
    return List;
}
    
ExtRemoteTyped
ExtNtOsInformation::GetKernelLoadedModule(__in ULONG64 Offset)
{
    // We are caching both type and link information
    // so provide a link field here to keep the
    // cache properly filled out.
    return ExtRemoteTyped("nt!_KLDR_DATA_TABLE_ENTRY",
                          Offset,
                          true,
                          &s_KernelLoadedModuleBaseInfoCookie,
                          "InLoadOrderLinks");
}

ULONG64
ExtNtOsInformation::GetKernelProcessListHead(void)
{
    return GetNtDebuggerData(DEBUG_DATA_PsActiveProcessHeadAddr,
                             "nt!PsActiveProcessHead",
                             0);
}

ExtRemoteTypedList
ExtNtOsInformation::GetKernelProcessList(void)
{
    ExtRemoteTypedList List(GetKernelProcessListHead(),
                            "nt!_EPROCESS",
                            "ActiveProcessLinks",
                            0,
                            0,
                            &s_KernelProcessBaseInfoCookie,
                            true);
    List.m_MaxIter = 4000;
    return List;
}

ExtRemoteTyped
ExtNtOsInformation::GetKernelProcess(__in ULONG64 Offset)
{
    // We are caching both type and link information
    // so provide a link field here to keep the
    // cache properly filled out.
    return ExtRemoteTyped("nt!_EPROCESS",
                          Offset,
                          true,
                          &s_KernelProcessBaseInfoCookie,
                          "ActiveProcessLinks");
}

ULONG64
ExtNtOsInformation::GetKernelProcessThreadListHead(__in ULONG64 Process)
{
    return Process +
        g_Ext->GetCachedFieldOffset(&s_KernelProcessThreadListFieldCookie,
                                    "nt!_EPROCESS",
                                    "Pcb.ThreadListHead");
}

ExtRemoteTypedList
ExtNtOsInformation::GetKernelProcessThreadList(__in ULONG64 Process)
{
    ExtRemoteTypedList List(GetKernelProcessThreadListHead(Process),
                            "nt!_ETHREAD",
                            "Tcb.ThreadListEntry",
                            0,
                            0,
                            &s_KernelThreadBaseInfoCookie,
                            true);
    List.m_MaxIter = 15000;
    return List;
}

ExtRemoteTyped
ExtNtOsInformation::GetKernelThread(__in ULONG64 Offset)
{
    // We are caching both type and link information
    // so provide a link field here to keep the
    // cache properly filled out.
    return ExtRemoteTyped("nt!_ETHREAD",
                          Offset,
                          true,
                          &s_KernelThreadBaseInfoCookie,
                          "Tcb.ThreadListEntry");
}

ULONG64
ExtNtOsInformation::GetUserLoadedModuleListHead(__in bool NativeOnly)
{
    HRESULT Status;

    if (NativeOnly ||
        !g_Ext->Is32On64())
    {
        DEBUG_VALUE Data;
    
        if (FAILED(Status = g_Ext->m_Control->
                   Evaluate("@@c++(&@$peb->Ldr->InLoadOrderModuleList)",
                            DEBUG_VALUE_INT64, &Data, NULL)))
        {
            g_Ext->ThrowRemote(Status,
                               "Unable to get loader list head from PEB");
        }

        return Data.I64;
    }
    else
    {
        // We're looking at a 32-bit structure so only
        // pull out a 32-bit pointer value.  We do
        // not sign-extend as this is a UM pointer and
        // should not get sign-extended.
        return GetAltPeb().
            Eval("&@$extin->Ldr->InLoadOrderModuleList").GetUlong();
    }
}

ExtRemoteTypedList
ExtNtOsInformation::GetUserLoadedModuleList(__in bool NativeOnly)
{
    if (NativeOnly ||
        !g_Ext->Is32On64())
    {
        ExtRemoteTypedList List(GetUserLoadedModuleListHead(NativeOnly),
                                "${$ntnsym}!_LDR_DATA_TABLE_ENTRY",
                                "InLoadOrderLinks",
                                0,
                                0,
                                &s_UserOsLoadedModuleBaseInfoCookie,
                                true);
        List.m_MaxIter = 1000;
        return List;
    }
    else
    {
        ExtRemoteTypedList List(GetUserLoadedModuleListHead(NativeOnly),
                                "${$ntwsym}!_LDR_DATA_TABLE_ENTRY",
                                "InLoadOrderLinks",
                                0,
                                0,
                                &s_UserAltLoadedModuleBaseInfoCookie,
                                true);
        List.m_MaxIter = 1000;
        return List;
    }
}

ExtRemoteTyped
ExtNtOsInformation::GetUserLoadedModule(__in ULONG64 Offset,
                                        __in bool NativeOnly)
{
    // We are caching both type and link information
    // so provide a link field here to keep the
    // cache properly filled out.
    if (NativeOnly ||
        !g_Ext->Is32On64())
    {
        return ExtRemoteTyped("${$ntnsym}!_LDR_DATA_TABLE_ENTRY",
                              Offset,
                              true,
                              &s_UserOsLoadedModuleBaseInfoCookie,
                              "InLoadOrderLinks");
    }
    else
    {
        return ExtRemoteTyped("${$ntwsym}!_LDR_DATA_TABLE_ENTRY",
                              Offset,
                              true,
                              &s_UserAltLoadedModuleBaseInfoCookie,
                              "InLoadOrderLinks");
    }
}

ULONG64
ExtNtOsInformation::GetOsPebPtr(void)
{
    HRESULT Status;
    ULONG64 Offset;

    if ((Status = g_Ext->m_System->
         GetCurrentProcessPeb(&Offset)) != S_OK)
    {
        g_Ext->ThrowRemote(Status,
                           "Unable to get OS PEB pointer");
    }

    return Offset;
}

ExtRemoteTyped
ExtNtOsInformation::GetOsPeb(__in ULONG64 Offset)
{
    return ExtRemoteTyped("${$ntnsym}!_PEB",
                          Offset,
                          true,
                          &s_OsPebBaseInfoCookie);
}

ULONG64
ExtNtOsInformation::GetOsTebPtr(void)
{
    HRESULT Status;
    ULONG64 Offset;

    if ((Status = g_Ext->m_System->
         GetCurrentThreadTeb(&Offset)) != S_OK)
    {
        g_Ext->ThrowRemote(Status,
                           "Unable to get OS TEB pointer");
    }

    return Offset;
}

ExtRemoteTyped
ExtNtOsInformation::GetOsTeb(__in ULONG64 Offset)
{
    return ExtRemoteTyped("${$ntnsym}!_TEB",
                          Offset,
                          true,
                          &s_OsTebBaseInfoCookie);
}

ULONG64
ExtNtOsInformation::GetAltPebPtr(void)
{
    ExtRemoteTyped AltTeb = GetAltTeb();
    return AltTeb.Field("ProcessEnvironmentBlock").GetUlong();
}

ExtRemoteTyped
ExtNtOsInformation::GetAltPeb(__in ULONG64 Offset)
{
    return ExtRemoteTyped("${$ntwsym}!_PEB",
                          Offset,
                          true,
                          &s_AltPebBaseInfoCookie);
}

ULONG64
ExtNtOsInformation::GetAltTebPtr(void)
{
    // If this is a 32-bit machine there's no
    // WOW64 TEB.
    if (!g_Ext->IsMachine64(g_Ext->m_ActualMachine))
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "No alternate TEB available");
    }

    //
    // The pointer to the WOW64 TEB is the first pointer of
    // the 64-bit TEB.
    //

    ExtRemoteData OsTeb(GetOsTebPtr(), sizeof(ULONG64));
    return OsTeb.GetUlong64();
}

ExtRemoteTyped
ExtNtOsInformation::GetAltTeb(__in ULONG64 Offset)
{
    return ExtRemoteTyped("${$ntwsym}!_TEB",
                          Offset,
                          true,
                          &s_AltTebBaseInfoCookie);
}

ULONG64
ExtNtOsInformation::GetCurPebPtr(void)
{
    return g_Ext->Is32On64() ?
        GetAltPebPtr() : GetOsPebPtr();
}

ExtRemoteTyped
ExtNtOsInformation::GetCurPeb(__in ULONG64 Offset)
{
    return g_Ext->Is32On64() ?
        GetAltPeb(Offset) : GetOsPeb(Offset);
}

ULONG64
ExtNtOsInformation::GetCurTebPtr(void)
{
    return g_Ext->Is32On64() ?
        GetAltTebPtr() : GetOsTebPtr();
}

ExtRemoteTyped
ExtNtOsInformation::GetCurTeb(__in ULONG64 Offset)
{
    return g_Ext->Is32On64() ?
        GetAltTeb(Offset) : GetOsTeb(Offset);
}
    
ULONG64
ExtNtOsInformation::GetNtDebuggerData(__in ULONG DataOffset,
                                      __in PCSTR Symbol,
                                      __in ULONG Flags)
{
    ULONG64 Data;

    UNREFERENCED_PARAMETER(Flags);

    //
    // First check the kernel's data block.
    //
    
    if (g_Ext->m_Data->
        ReadDebuggerData(DataOffset, &Data, sizeof(Data), NULL) == S_OK)
    {
        return Data;
    }

    //
    // Fall back on symbols.
    //

    if (g_Ext->m_Symbols->
        GetOffsetByName(Symbol, &Data) != S_OK)
    {
        g_Ext->ThrowRemote(E_INVALIDARG,
                           "Unable to find '%s', check your NT kernel symbols",
                           Symbol);
    }

    return Data;
}

//----------------------------------------------------------------------------
//
// Number-to-string helpers for things like #define translations.
//
//----------------------------------------------------------------------------

ExtDefine*
ExtDefineMap::Map(__in ULONG64 Value)
{
    if ((m_Flags & Bitwise) != 0)
    {
        for (ExtDefine* Define = m_Defines; Define->Name; Define++)
        {
            if ((Define->Value & Value) == Define->Value)
            {
                return Define;
            }
        }
    }
    else
    {
        for (ExtDefine* Define = m_Defines; Define->Name; Define++)
        {
            if (Define->Value == Value)
            {
                return Define;
            }
        }
    }

    return NULL;
}

PCSTR
ExtDefineMap::MapStr(__in ULONG64 Value,
                     __in_opt PCSTR InvalidStr)
{
    ExtDefine* Define = Map(Value);
    if (Define)
    {
        return Define->Name;
    }
    if (InvalidStr)
    {
        return InvalidStr;
    }
    else
    {
        return g_Ext->PrintCircleString("<0x%I64x>", Value);
    }
}

void
ExtDefineMap::Out(__in ULONG64 Value,
                  __in ULONG Flags,
                  __in_opt PCSTR InvalidStr)
{
    ULONG OldIndent = g_Ext->m_LeftIndent;
    g_Ext->m_LeftIndent = g_Ext->m_CurChar;

    if ((Flags & OutValue) != 0)
    {
        g_Ext->OutWrap("%I64x", Value);
    }
    else if ((Flags & OutValue32) != 0)
    {
        g_Ext->OutWrap("%08I64x", Value);
    }
    else if ((Flags & OutValue64) != 0)
    {
        g_Ext->OutWrap("%016I64x", Value);
    }
    
    if ((m_Flags & Bitwise) != 0)
    {
        if (!Value)
        {
            if ((Flags & ValueAny) == 0)
            {
                g_Ext->OutWrapStr("<zero>");
            }
        }
        else
        {
            bool First = true;
            
            while (Value)
            {
                ExtDefine* Define = Map(Value);

                if (!Define &&
                    (Flags & ValueAny) != 0 &&
                    !InvalidStr)
                {
                    // Value already displayed.
                    break;
                }
                    
                if (!First)
                {
                    g_Ext->OutWrapStr(" | ");
                }
                else
                {
                    if ((Flags & OutValueAny) != 0)
                    {
                        g_Ext->OutWrapStr(" ");
                    }
                    
                    First = false;
                }
                
                if (Define)
                {
                    g_Ext->OutWrapStr(Define->Name);
                    Value &= ~Define->Value;
                }
                else
                {
                    if (InvalidStr)
                    {
                        g_Ext->OutWrapStr(InvalidStr);
                    }
                    else
                    {
                        g_Ext->OutWrap("<0x%I64x>", Value);
                    }
                    break;
                }
            }
        }
    }
    else
    {
        if ((Flags & ValueAny) == 0 ||
            InvalidStr)
        {
            if ((Flags & OutValueAny) != 0)
            {
                g_Ext->OutWrapStr(" ");
            }
            
            g_Ext->OutWrapStr(MapStr(Value, InvalidStr));
        }
        else
        {
            ExtDefine* Define = Map(Value);
            if (Define)
            {
                InvalidStr = Define->Name;
            }
            if (InvalidStr)
            {
                if ((Flags & OutValueAny) != 0)
                {
                    g_Ext->OutWrapStr(" ");
                }
                
                g_Ext->OutWrapStr(InvalidStr);
            }
        }
    }

    g_Ext->m_LeftIndent = OldIndent;
}

//----------------------------------------------------------------------------
//
// Extension DLL exports.
//
//----------------------------------------------------------------------------

EXTERN_C BOOL WINAPI
DllMain(HANDLE Instance, ULONG Reason, PVOID Reserved)
{
    UNREFERENCED_PARAMETER(Reserved);

    switch(Reason)
    {
    case DLL_PROCESS_ATTACH:
        ExtExtension::s_Module = (HMODULE)Instance;
        break;
    }

    return TRUE;
}

EXTERN_C HRESULT CALLBACK
DebugExtensionInitialize(__out PULONG Version,
                         __out PULONG Flags)
{
    HRESULT Status;

    // Pick up our global state.
    g_Ext = g_ExtInstancePtr;
    ExtExtension* Inst = g_Ext;
    
    // Pass registered commands to the extension
    // so that further references are confined to
    // extension class data.
    ExtCommandDesc::Transfer(&Inst->m_Commands,
                             &Inst->m_LongestCommandName);
    
    if ((Status = Inst->Initialize()) != S_OK)
    {
        return Status;
    }

    *Version = DEBUG_EXTENSION_VERSION(Inst->m_ExtMajorVersion,
                                       Inst->m_ExtMinorVersion);
    *Flags = Inst->m_ExtInitFlags;
    return S_OK;
}

EXTERN_C void CALLBACK
DebugExtensionUninitialize(void)
{
    if (!g_Ext.IsSet())
    {
        return;
    }

    g_Ext->Uninitialize();
}

EXTERN_C void CALLBACK
DebugExtensionNotify(__in ULONG Notify,
                     __in ULONG64 Argument)
{
    if (!g_Ext.IsSet())
    {
        return;
    }

    ExtExtension* Inst = g_Ext;

    switch(Notify)
    {
    case DEBUG_NOTIFY_SESSION_ACTIVE:
        Inst->OnSessionActive(Argument);
        break;
    case DEBUG_NOTIFY_SESSION_INACTIVE:
        Inst->OnSessionInactive(Argument);
        break;
    case DEBUG_NOTIFY_SESSION_ACCESSIBLE:
        Inst->OnSessionAccessible(Argument);
        break;
    case DEBUG_NOTIFY_SESSION_INACCESSIBLE:
        Inst->OnSessionInaccessible(Argument);
        break;
    }
}

EXTERN_C HRESULT CALLBACK
KnownStructOutputEx(__in PDEBUG_CLIENT Client,
                    __in ULONG Flags,
                    __in ULONG64 Offset,
                    __in_opt PCSTR TypeName,
                    __out_ecount_opt(*BufferChars) PSTR Buffer,
                    __inout_opt PULONG BufferChars)
{
    if (!g_Ext.IsSet())
    {
        return E_UNEXPECTED;
    }

    return g_Ext->HandleKnownStruct(Client, Flags, Offset, TypeName,
                                    Buffer, BufferChars);
}

EXTERN_C HRESULT CALLBACK
DebugExtensionQueryValueNames(__in PDEBUG_CLIENT Client,
                              __in ULONG Flags,
                              __out_ecount(BufferChars) PWSTR Buffer,
                              __in ULONG BufferChars,
                              __out PULONG BufferNeeded)
{
    if (!g_Ext.IsSet())
    {
        return E_UNEXPECTED;
    }

    return g_Ext->HandleQueryValueNames(Client, Flags,
                                        Buffer, BufferChars, BufferNeeded);
}

EXTERN_C HRESULT CALLBACK
DebugExtensionProvideValue(__in PDEBUG_CLIENT Client,
                           __in ULONG Flags,
                           __in PCWSTR Name,
                           __out PULONG64 Value,
                           __out PULONG64 TypeModBase,
                           __out PULONG TypeId,
                           __out PULONG TypeFlags)
{
    if (!g_Ext.IsSet())
    {
        return E_UNEXPECTED;
    }

    return g_Ext->HandleProvideValue(Client, Flags, Name,
                                     Value, TypeModBase, TypeId, TypeFlags);
}
