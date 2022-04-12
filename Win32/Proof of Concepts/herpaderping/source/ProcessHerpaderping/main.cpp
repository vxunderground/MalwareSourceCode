//
// Copyright (c) Johnny Shaw. All rights reserved.
// 
// File:     source/ProcessHerpaderping/main.cpp
// Author:   Johnny Shaw
// Abstract: Process Herpaderping Tool 
//
#include "pch.hpp"
#include "utils.hpp"
#include "herpaderp.hpp"

namespace Constants 
{
    constexpr static std::wstring_view ToolHeader
    {
        WSTR_FILE_DESCRIPTION L" - " WSTR_COPYRIGHT
    };

    constexpr static std::array<uint8_t, 4> Pattern{ '\x72', '\x6f', '\x66', '\x6c' };

    constexpr static size_t RandPatterLen{ 0x200 };
}

/// <summary>
/// Class for parsing and storing process herpaderping tool arguments. 
/// </summary>
class Parameters : public Utils::IArgumentParser
{
public:
    constexpr static std::wstring_view Usage
    {
WSTR_ORIGINAL_FILENAME L" SourceFile TargetFile [ReplacedWith] [Options...]\n"
L"Usage:\n"
L"  SourceFile               Source file to execute.\n"
L"  TargetFile               Target file to execute the source from.\n"
L"  ReplacedWith             File to replace the target with. Optional,\n"
L"                           default overwrites the binary with a pattern.\n"
L"  -h,--help                Prints tool usage.\n"
L"  -d,--do-not-wait         Does not wait for spawned process to exit,\n"
L"                           default waits.\n"
L"  -l,--logging-mask number Specifies the logging mask, defaults to full\n" 
L"                           logging.\n"
L"                               0x1   Successes\n"
L"                               0x2   Informational\n"
L"                               0x4   Warnings\n"
L"                               0x8   Errors\n"
L"                               0x10  Contextual\n"
L"  -q,--quiet               Runs quietly, overrides logging mask, no title.\n"
L"  -r,--random-obfuscation  Uses random bytes rather than a pattern for\n"
L"                           file obfuscation.\n"
L"  -e,--exclusive           Target file is created with exclusive access and\n"
L"                           the handle is held open as long as possible.\n"
L"                           Without this option the handle has full share\n"
L"                           access and is closed as soon as possible.\n"
L"  -u,--do-not-flush-file   Does not flush file after overwrite.\n"
L"  -c,--close-file-early    Closes file before thread creation (before the\n"
L"                           process notify callback fires in the kernel).\n"
L"                           Not valid with \"--exclusive\" option.\n"
L"  -k,--kill                Terminates the spawned process regardless of\n"
L"                           success or failure, this is useful in some\n"
L"                           automation environments. Forces \"--do-not-wait\n"
L"                           option."
    };

    Parameters() = default;

    /// <summary>
    /// Parses command line arguments and stores the data in the class.
    /// </summary>
    /// <param name="Argc">
    /// Number of command line arguments.
    /// </param>
    /// <param name="Argv">
    /// Command line arguments.
    /// </param>
    /// <returns>
    /// Success if arguments were parsed successfully. Failure otherwise.
    /// </returns>
    _Must_inspect_result_ virtual HRESULT ParseArguments(
        _In_ int Argc,
        _In_reads_(Argc) const wchar_t* Argv[]) override
    {
        if (Argc < 3)
        {
            return E_INVALIDARG;
        }

        m_TargetBinary = Argv[1];
        m_FileName = Argv[2];

        for (int i = 3; i < Argc; i++)
        {
            std::wstring arg = Argv[i];

            //
            // Check for optional flags.
            //
            if (SUCCEEDED(Utils::MatchParameter(arg, L"l", L"logging-mask")))
            {
                i++;
                if (i >= Argc)
                {
                    return E_INVALIDARG;
                }
                try
                {
                    m_LoggingMask = std::stoul(Argv[i], 0, 0);
                }
                catch (...)
                {
                    //
                    // Invalid number...
                    //
                    return E_INVALIDARG;
                }
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"d", L"do-not-wait")))
            {
                ClearFlag(m_HerpaderpFlags, Herpaderp::FlagWaitForProcess);
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"q", L"quiet")))
            {
                m_Quiet = true;
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"r", L"random-obfuscation")))
            {
                m_RandomObfuscation = true;
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"e", L"exclusive")))
            {
                SetFlag(m_HerpaderpFlags, Herpaderp::FlagHoldHandleExclusive);
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"u", L"do-not-flush-file")))
            {
                ClearFlag(m_HerpaderpFlags, Herpaderp::FlagFlushFile);
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"c", L"close-file-early")))
            {
                SetFlag(m_HerpaderpFlags, Herpaderp::FlagCloseFileEarly);
                continue;
            }
            if (SUCCEEDED(Utils::MatchParameter(arg, L"k", L"kill")))
            {
                SetFlag(m_HerpaderpFlags, Herpaderp::FlagKillSpawnedProcess);
                ClearFlag(m_HerpaderpFlags, Herpaderp::FlagWaitForProcess);
                continue;
            }

            //
            // Assume replace with target.
            //
            m_ReplaceWith = arg;
        }

        return S_OK;
    }

    _Must_inspect_result_ virtual HRESULT ValidateArguments() const override
    {
        if (FlagOn(m_HerpaderpFlags, Herpaderp::FlagHoldHandleExclusive) &&
            FlagOn(m_HerpaderpFlags, Herpaderp::FlagCloseFileEarly))
        {
            //
            // These options are incompatible.
            //
            return E_FAIL;
        }
        return S_OK;
    }

    /// <summary>Gets the tool usage string.</summary>
    /// <returns>Tool usage string.</returns>
    virtual std::wstring_view GetUsage() const override
    {
        return Usage;
    }

    /// <summary>Gets the target binary string.</summary>
    /// <returns>Target binary string.</returns>
    const std::wstring& TargetBinary() const
    {
        return m_TargetBinary;
    }

    /// <summary>Gets the file name string.</summary>
    /// <returns>File name string.</returns>
    const std::wstring& FileName() const
    {
        return m_FileName;
    }

    /// <summary>Gets the replace with string.</summary>
    /// <returns>Replace with string.</returns>
    const std::optional<std::wstring>& ReplaceWith() const
    {
        return m_ReplaceWith;
    }

    /// <summary>Gets the logging bit mask.</summary>
    /// <returns>Logging bit mask.</returns>
    uint32_t LoggingMask() const
    {
        return m_LoggingMask;
    }

    /// <summary>Gets the quiet boolean.</summary>
    /// <returns>Quiet boolean.</returns>
    bool Quiet() const
    {
        return m_Quiet;
    }

    /// <summary>Gets the random obfuscation boolean.</summary>
    /// <returns>Random obfuscation boolean.</returns>
    bool RandomObfuscation() const
    {
        return m_RandomObfuscation;
    }

    /// <summary>Gets herpaderp flags.</summary>
    /// <returns>Herpaderp flags.</returns>
    uint32_t HerpaderpFlags() const
    {
        return m_HerpaderpFlags;
    }
    
private:

    std::wstring m_TargetBinary;
    std::wstring m_FileName;
    std::optional<std::wstring> m_ReplaceWith{ std::nullopt };
    uint32_t m_LoggingMask
    {
        Log::Success |
        Log::Information |
        Log::Warning |
        Log::Error |
        Log::Context
    };
    bool m_Quiet{ false };
    bool m_RandomObfuscation{ false };
    uint32_t m_HerpaderpFlags
    { 
        Herpaderp::FlagWaitForProcess | 
        Herpaderp::FlagFlushFile 
    };
};

/// <summary>
/// Main entry point for Process Herpaderping Tool.
/// </summary>
/// <param name="Argc">
/// Number of command line arguments.
/// </param>
/// <param name="Argv">
/// Command line arguments.
/// </param>
/// <returns>
/// EXIT_SUCCESS on success, EXIT_FAILURE on failure or invalid parameters.
/// </returns>
int wmain(
    _In_ int Argc, 
    _In_reads_(Argc) const wchar_t* Argv[])
{
    Parameters params;
    if (FAILED(Utils::HandleCommandLineArgs(Argc,
                                            Argv,
                                            Constants::ToolHeader,
                                            params)))
    {
        return EXIT_FAILURE;
    }

    if (params.Quiet())
    {
        //
        // Run quietly, no header and override the logging mask.
        //
        Utils::SetLoggingMask(0);
    }
    else
    {
        std::wcout << Constants::ToolHeader << L'\n';
        Utils::SetLoggingMask(params.LoggingMask());
    }

    //
    // Herpaderp wants a pattern to use for obfuscation, set that up here.
    //
    HRESULT hr;
    std::span<const uint8_t> pattern = Constants::Pattern;
    std::vector<uint8_t> patternBuffer;

    if (params.RandomObfuscation())
    {
        //
        // Use a random pattern instead.
        //
        patternBuffer.resize(Constants::RandPatterLen);
        hr = Utils::FillBufferWithRandomBytes(patternBuffer);
        if (FAILED(hr))
        {
            Utils::Log(Log::Error, 
                            hr,
                            L"Failed to generate random buffer");
            return EXIT_FAILURE;
        }
        pattern = std::span<const uint8_t>(patternBuffer);
    }

    hr = Herpaderp::ExecuteProcess(params.TargetBinary(), 
                                   params.FileName(), 
                                   params.ReplaceWith(), 
                                   pattern,
                                   params.HerpaderpFlags());
    if (FAILED(hr))
    {
        Utils::Log(Log::Error, hr, L"Process Herpaderp Failed");
        return EXIT_FAILURE;
    }

    Utils::Log(Log::Success, L"Process Herpaderp Succeeded");
    return EXIT_SUCCESS;
}
