//
// Copyright (c) Johnny Shaw. All rights reserved.
// 
// File:     source/ProcessHerpaderping/herpaderp.hpp
// Author:   Johnny Shaw
// Abstract: Herpaderping Functionality
//
#pragma once

namespace Herpaderp
{
#pragma warning(push)
#pragma warning(disable : 4634)  // xmldoc: discarding XML document comment for invalid target 
    /// <summary>
    /// Waits for process to exit before returning.
    /// </summary>
    constexpr static uint32_t FlagWaitForProcess = 0x00000001ul;

    /// <summary>
    /// Opens and hold the target file handle exclusive for as long as 
    /// reasonable. This flag is incompatible with FlagCloseFileEarly.
    /// </summary>
    constexpr static uint32_t FlagHoldHandleExclusive = 0x00000002ul;

    /// <summary>
    /// Flushes file buffers of target file.
    /// </summary>
    constexpr static uint32_t FlagFlushFile = 0x00000004ul;

    /// <summary>
    /// Closes the file handle early, before creating the initial thread 
    /// (before process notification would fire in the kernel). This flag is 
    /// not compatible with FlagHoldHandleExclusive.
    /// </summary>
    constexpr static uint32_t FlagCloseFileEarly = 0x00000008ul;

    /// <summary>
    /// Terminates the spawned process on success, this can be useful in some 
    /// automation environments. Not compatible with FlagWaitForProcess.
    /// </summary>
    constexpr static uint32_t FlagKillSpawnedProcess = 0x00000010ul;
#pragma warning(pop)

    /// <summary>
    /// Executes process herpaderping.
    /// </summary>
    /// <param name="SourceFileName">
    /// Source binary to execute.
    /// </param>
    /// <param name="TargetFileName">
    /// File name to copy source to and obfuscate.
    /// </param>
    /// <param name="ReplaceWithFileName">
    /// Optional, if provided the file is replaced with the content of this 
    /// file. If not provided the file is overwritten with a pattern.
    /// </param>
    /// <param name="Pattern">
    /// Pattern used for obfuscation.
    /// </param>
    /// <param name="Flags">
    /// Flags controlling behavior of herpaderping (Herpaderp::FlagXxx).
    /// </param>
    /// <returns>
    /// Success if the herpaderping executed. Failure otherwise.
    /// </returns>
    _Must_inspect_result_ HRESULT ExecuteProcess(
        _In_ const std::wstring& SourceFileName,
        _In_ const std::wstring& TargetFileName,
        _In_opt_ const std::optional<std::wstring>& ReplaceWithFileName,
        _In_ std::span<const uint8_t> Pattern, 
        _In_ uint32_t Flags);

}
