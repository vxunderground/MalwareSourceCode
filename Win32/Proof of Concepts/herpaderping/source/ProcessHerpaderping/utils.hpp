//
// Copyright (c) Johnny Shaw. All rights reserved.
// 
// File:     source/ProcessHerpaderping/utils.hpp
// Author:   Johnny Shaw
// Abstract: Utility functionality for herpaderping. 
//
#pragma once

namespace Log
{

    constexpr static uint32_t Success{     0x00000001ul };
    constexpr static uint32_t Information{ 0x00000002ul };
    constexpr static uint32_t Warning{     0x00000004ul };
    constexpr static uint32_t Error{       0x00000008ul };
    constexpr static uint32_t Context{     0x00000010ul };
    constexpr static uint32_t Debug{       0x80000000ul };

}

namespace Utils 
{
    /// <summary>
    /// Argument parser interface.
    /// </summary>
    class IArgumentParser
    {
    public:
        virtual ~IArgumentParser() = default;

        /// <summary>
        /// Implements functionality for parsing arguments.
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
            _In_reads_(Argc) const wchar_t* Argv[]) = 0;

        /// <summary>
        /// Implements retrieving the argument usage.
        /// </summary>
        /// <returns>
        /// Argument usage.
        /// </returns>
        virtual std::wstring_view GetUsage() const = 0;

        /// <summary>
        /// Provides the interface an opportunity to validate the parsed 
        /// arguments. If the arguments are invalid (for example, two options 
        /// are used that may not be specified together) the implementation 
        /// may return failure here to indicate the arguments are invalid.
        /// </summary>
        _Must_inspect_result_ virtual HRESULT ValidateArguments() const = 0;

    protected:
        IArgumentParser() = default;
    };

    /// <summary>
    /// Matches a parameter argument with either short or parameter.
    /// </summary>
    /// <param name="Arg">
    /// Argument to check against short or long parameter argument 
    /// must either be prefixed explicitly as long ("--") or short ("-", "/").
    /// </param>
    /// <param name="Short">
    /// Short parameter representation (e.g. "q").
    /// </param>
    /// <param name="Long">
    /// Long parameter representation (e.g. "quiet").
    /// </param>
    /// <returns>
    /// Success if the argument matches either the short to long parameter.
    /// </returns>
    _Must_inspect_result_ HRESULT MatchParameter(
        _In_ std::wstring_view Arg,
        _In_opt_ std::optional<std::wstring_view> Short,
        _In_opt_ std::optional<std::wstring_view> Long);

    /// <summary>
    /// Checks for help options in parameters.
    /// </summary>
    /// <param name="Argc">
    /// Number of command line arguments.
    /// </param>
    /// <param name="Argv">
    /// Command line arguments.
    /// </param>
    /// <returns>
    /// Success if "--help", "-h", "/h", "-?", or "/?" are found in the 
    /// command line arguments. 
    /// </returns>
    _Must_inspect_result_ HRESULT CheckForHelpOptions(
        _In_ int Argc,
        _In_reads_(Argc) const wchar_t* Argv[]);

    /// <summary>
    /// Handles command line arguments for a argument parser. If a help 
    /// option is found or the parser fails. The function prints the header 
    /// and usage text to stdout and return failure.
    /// </summary>
    /// <param name="Argc">
    /// Number of command line arguments.
    /// </param>
    /// <param name="Argv">
    /// Command line arguments.
    /// </param>
    /// <param name="Header">
    /// Header to print before usage.
    /// </param>
    /// <param name="Parser">
    /// Argument parser to use.
    /// </param>
    /// <returns>
    /// Success if the arguments were parsed successfully. Failure if the 
    /// arguments were invalid or a help option was found. 
    /// </returns>
    _Must_inspect_result_ HRESULT HandleCommandLineArgs(
        _In_ int Argc,
        _In_reads_(Argc) const wchar_t* Argv[],
        _In_opt_ std::optional<std::wstring_view> Header,
        _Inout_ IArgumentParser& Parser);

#pragma warning(push)
#pragma warning(disable : 4634)  // xmldoc: discarding XML document comment for invalid target 
    /// <summary>
    /// Removes all occurrences of a set of values from an object.
    /// </summary>
    /// <typeparam name="T">
    /// Object type to remove elements of. Must implement erase, be forward 
    /// iterate-able, and contained value type must be move assignable.
    /// </typeparam>
    /// <param name="Object">
    /// Object to erase elements from.
    /// </param>
    /// <param name="Values">
    /// Values to remove.
    /// </param>
    template <typename T>
    void EraseAll(
        _Inout_ T& Object,
        _In_ const std::initializer_list<typename T::value_type>& Values)
    {
        for (const auto& value : Values)
        {
            Object.erase(std::remove(Object.begin(),
                                     Object.end(),
                                     value),
                         Object.end());
        }
    }
#pragma warning(pop)

    /// <summary>
    /// Formats an error code as a string.
    /// </summary>
    /// <param name="Error">
    /// Error code to format as a string.
    /// </param>
    /// <returns>
    /// Human readable string for the error code if the error is unknown a 
    /// string is returned formatted as "[number] - Unknown Error".
    /// </returns>
    std::wstring FormatError(_In_ uint32_t Error);

    /// <summary>
    /// Sets the logging mask.
    /// </summary>
    /// <param name="Level">
    /// Logging mask to set.
    /// </param>
    void SetLoggingMask(_In_ uint32_t Level);

    /// <summary>
    /// Logs a string.
    /// </summary>
    /// <param name="Level">
    /// Logging level: Log::Success, Log::Information, Log::Warning, Log:Error.
    /// </param>
    /// <param name="Format">
    /// Format for log string.
    /// </param>
    /// <param name="...">
    /// Variadic arguments for formatting.
    /// </param>
    void Log(
        _In_ uint32_t Level, 
        _Printf_format_string_ const wchar_t* Format, 
        ...);

    /// <summary>
    /// Logs a string with a specified error code appended to the formatted 
    /// string. 
    /// </summary>
    /// <param name="Level">
    /// Logging level: Log::Success, Log::Information, Log::Warning, Log:Error.
    /// </param>
    /// <param name="Error">
    /// Error code.
    /// </param>
    /// <param name="Format">
    /// Format for log string.
    /// </param>
    /// <param name="...">
    /// Variadic arguments for formatting.
    /// </param>
    /// <returns>
    /// Supplied Error
    /// </returns>
    uint32_t Log(
        _In_ uint32_t Level, 
        _In_ uint32_t Error, 
        _Printf_format_string_ const wchar_t* Format, 
        ...);

    /// <summary>
    /// Generates a buffer of a given length containing a supplied pattern.
    /// </summary>
    /// <param name="Buffer">
    /// Buffer to fill with the patter, must not be empty.
    /// </param>
    /// <param name="Pattern">
    /// Pattern to write into the buffer.
    /// </param>
    /// <returns>
    /// Success when the buffer is filled with the pattern. Failure if Buffer 
    /// is empty.
    /// </returns>
    _Must_inspect_result_ HRESULT FillBufferWithPattern(
        _Inout_ std::vector<uint8_t>& Buffer,
        _In_ std::span<const uint8_t> Pattern);

    /// <summary>
    /// Generates a buffer of random bytes of a given length.
    /// </summary>
    /// <param name="Buffer">
    /// Buffer to assign the bytes to, must not be empty.
    /// </param>
    /// <returns>
    /// Success if the buffer is filled with random bytes.
    /// </returns>
    _Must_inspect_result_ HRESULT FillBufferWithRandomBytes(
        _Inout_ std::vector<uint8_t>& Buffer);

    /// <summary>
    /// Gets a file size.
    /// </summary>
    /// <param name="FileHandle">
    /// File to get the size of.
    /// </param>
    /// <param name="FileSize">
    /// Set to the size of the file on success.
    /// </param>
    /// <returns>
    /// Success if the file size of retrieved.
    /// </returns>
    _Must_inspect_result_ HRESULT GetFileSize(
        _In_ handle_t FileHandle, 
        _Out_ uint64_t& FileSize);

    /// <summary>
    /// Sets a file pointer.
    /// </summary>
    /// <param name="FileHandle">
    /// File to set the pointer of.
    /// </param>
    /// <param name="DistanceToMove">
    /// Distance to move the file pointer.
    /// </param>
    /// <param name="MoveMethod">
    /// Move method to use (FILE_BEGIN, FILE_CURRENT, FILE_END).
    /// </param>
    /// <returns>
    /// Success if the file pointer was set (or was already set).
    /// </returns>
    _Must_inspect_result_ HRESULT SetFilePointer(
        _In_ handle_t FileHandle,
        _In_ int64_t DistanceToMove,
        _In_ uint32_t MoveMethod);

    /// <summary>
    /// Copies the contents for a source file to the target by handle.
    /// </summary>
    /// <param name="SourceHandle">
    /// Source file handle.
    /// </param>
    /// <param name="TargetHandle">
    /// Target file handle.
    /// </param>
    /// <param name="FlushFile">
    /// Flushes file buffers after copy, optional, defaults to true.
    /// </param>
    /// <returns>
    /// Success if the source file has been copied to the target.
    /// </returns>
    _Must_inspect_result_ HRESULT CopyFileByHandle(
        _In_ handle_t SourceHandle, 
        _In_ handle_t TargetHandle,
        _In_ bool FlushFile = true);

    /// <summary>
    /// Overwrites the contents of a file with a pattern.
    /// </summary>
    /// <param name="FileHandle">
    /// Target file to overwrite.
    /// </param>
    /// <param name="Pattern">
    /// Pattern write over the file content.
    /// </param>
    /// <param name="PatternLength">
    /// Length of Pattern buffer.
    /// </param>
    /// <param name="FlushFile">
    /// Flushes file buffers after overwrite, optional, defaults to true.
    /// </param>
    /// <returns>
    /// Success if the file content was overwritten.
    /// </returns>
    _Must_inspect_result_ HRESULT OverwriteFileContentsWithPattern(
        _In_ handle_t FileHandle,
        _In_ std::span<const uint8_t> Pattern,
        _In_ bool FlushFile = true);

    /// <summary>
    /// Extends file to meet a new size writes a pattern to the extension.
    /// </summary>
    /// <param name="FileHandle">
    /// Target file to extend.
    /// </param>
    /// <param name="NewFileSize">
    /// New size of the file.
    /// </param>
    /// <param name="Pattern">
    /// Pattern to use to extend the target file with.
    /// </param>
    /// <param name="AppendedBytes">
    /// Number of bytes appended.
    /// </param>
    /// <param name="FlushFile">
    /// Flushes file buffers after extension, optional, defaults to true.
    /// </param>
    /// <returns>
    /// Success if the file was extended.
    /// </returns>
    _Must_inspect_result_ HRESULT ExtendFileWithPattern(
        _In_ handle_t FileHandle,
        _In_ uint64_t NewFileSize,
        _In_ std::span<const uint8_t> Pattern,
        _Out_ uint32_t& AppendedBytes,
        _In_ bool FlushFile = true);

    /// <summary>
    /// Overwrites a file from a given offset with a pattern.
    /// </summary>
    /// <param name="FileHandle">
    /// Target file to overwrite.
    /// </param>
    /// <param name="FileOffset">
    /// Offset to begin writing from.
    /// </param>
    /// <param name="Pattern">
    /// Pattern to use to extend the target file with.
    /// </param>
    /// <param name="WrittenBytes">
    /// Number of bytes written.
    /// </param>
    /// <param name="FlushFile">
    /// Flushes file buffers after overwrite, optional, defaults to true.
    /// </param>
    /// <returns>
    /// Success if the file was overwritten.
    /// </returns>
    _Must_inspect_result_ HRESULT OverwriteFileAfterWithPattern(
        _In_ handle_t FileHandle,
        _In_ uint64_t FileOffset,
        _In_ std::span<const uint8_t> Pattern,
        _Out_ uint32_t& WrittenBytes,
        _In_ bool FlushFile = true);
    
    /// <summary>
    /// Extends a PE file security directory by a number of bytes.
    /// </summary>
    /// <param name="FileHandle">
    /// Target file handle.
    /// </param>
    /// <param name="ExtendedBy">
    /// Number of bytes to extend the security directory by.
    /// </param>
    /// <param name="FlushFile">
    /// Flushes file buffers after extension, optional, defaults to true.
    /// </param>
    /// <returns>
    /// Success if the security directory was extended. Failure if the file is 
    /// not a PE file or does not have a security directory.
    /// </returns>
    _Must_inspect_result_ HRESULT ExtendFileSecurityDirectory(
        _In_ handle_t FileHandle,
        _In_ uint32_t ExtendedBy,
        _In_ bool FlushFile = true);

    /// <summary>
    /// Retrieves the image entry point RVA from a file.
    /// </summary>
    /// <param name="FileHandle">
    /// File to parse for the entry point RVA.
    /// </param>
    /// <param name="EntryPointRva">
    /// Set to the entry point RVA on success.
    /// </param>
    /// <returns>
    /// Success if the PE image entry RVA is located.
    /// </returns>
    _Must_inspect_result_ HRESULT GetImageEntryPointRva(
        _In_ handle_t FileHandle,
        _Out_ uint32_t& EntryPointRva);

    /// <summary>
    /// Writes remote process parameters into target process.
    /// </summary>
    /// <param name="ProcessHandle">
    /// Process to write parameters into.
    /// </param>
    /// <param name="DllPath">
    /// Dll path to write into the parameters, optional.
    /// </param>
    /// <param name="ImageFileName">
    /// Image file name to write into the parameters.
    /// </param>
    /// <param name="CurrentDirectory">
    /// Current directory to write into the parameters, optional.
    /// </param>
    /// <param name="CommandLine">
    /// Command line to write into the parameters, optional.
    /// </param>
    /// <param name="EnvironmentBlock">
    /// Environment block to write into the parameters, optional.
    /// </param>
    /// <param name="WindowTitle">
    /// Window title to write into the parameters, optional.
    /// </param>
    /// <param name="DesktopInfo">
    /// Desktop info to write into the parameters, optional.
    /// </param>
    /// <param name="ShellInfo">
    /// ShellInfo to write into the parameters, optional.
    /// </param>
    /// <param name="RuntimeData">
    /// Runtime data to write into the parameters, optional.
    /// </param>
    /// <returns>
    /// Success if the remote process parameters are written.
    /// </returns>
    _Must_inspect_result_ HRESULT WriteRemoteProcessParameters(
        _In_ handle_t ProcessHandle,
        _In_ const std::wstring ImageFileName,
        _In_opt_ const std::optional<std::wstring>& DllPath,
        _In_opt_ const std::optional<std::wstring>& CurrentDirectory,
        _In_opt_ const std::optional<std::wstring>& CommandLine,
        _In_opt_ void* EnvironmentBlock,
        _In_opt_ const std::optional<std::wstring>& WindowTitle,
        _In_opt_ const std::optional<std::wstring>& DesktopInfo,
        _In_opt_ const std::optional<std::wstring>& ShellInfo,
        _In_opt_ const std::optional<std::wstring>& RuntimeData);

}
