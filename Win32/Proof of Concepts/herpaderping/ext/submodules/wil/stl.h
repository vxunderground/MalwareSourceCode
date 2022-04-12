//*********************************************************
//
//    Copyright (c) Microsoft. All rights reserved.
//    This code is licensed under the MIT License.
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
//    ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
//    TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//    PARTICULAR PURPOSE AND NONINFRINGEMENT.
//
//*********************************************************
#ifndef __WIL_STL_INCLUDED
#define __WIL_STL_INCLUDED

#include "common.h"
#include "resource.h"
#include <memory>
#include <string>
#include <vector>

#if defined(WIL_ENABLE_EXCEPTIONS)

namespace wil
{
    /** Secure allocator for STL containers.
    The `wil::secure_allocator` allocator calls `SecureZeroMemory` before deallocating
    memory. This provides a mechanism for secure STL containers such as `wil::secure_vector`,
    `wil::secure_string`, and `wil::secure_wstring`. */
    template <typename T>
    struct secure_allocator
        : public std::allocator<T>
    {
        template<typename Other>
        struct rebind
        {
            typedef secure_allocator<Other> other;
        };

        secure_allocator()
            : std::allocator<T>()
        {
        }

        ~secure_allocator() = default;

        secure_allocator(const secure_allocator& a)
            : std::allocator<T>(a)
        {
        }

        template <class U>
        secure_allocator(const secure_allocator<U>& a)
            : std::allocator<T>(a)
        {
        }

        T* allocate(size_t n)
        {
            return std::allocator<T>::allocate(n);
        }

        void deallocate(T* p, size_t n)
        {
            SecureZeroMemory(p, sizeof(T) * n);
            std::allocator<T>::deallocate(p, n);
        }
    };

    //! `wil::secure_vector` will be securely zeroed before deallocation.
    template <typename Type>
    using secure_vector = std::vector<Type, secure_allocator<Type>>;
    //! `wil::secure_wstring` will be securely zeroed before deallocation.
    using secure_wstring = std::basic_string<wchar_t, std::char_traits<wchar_t>, wil::secure_allocator<wchar_t>>;
    //! `wil::secure_string` will be securely zeroed before deallocation.
    using secure_string = std::basic_string<char, std::char_traits<char>, wil::secure_allocator<char>>;

    /// @cond
    namespace details
    {
        template<> struct string_maker<std::wstring>
        {
            HRESULT make(_In_reads_opt_(length) PCWSTR source, size_t length) WI_NOEXCEPT try
            {
                m_value = source ? std::wstring(source, length) : std::wstring(length, L'\0');
                return S_OK;
            }
            catch (...)
            {
                return E_OUTOFMEMORY;
            }

            wchar_t* buffer() { return &m_value[0]; }

            HRESULT trim_at_existing_null(size_t length) { m_value.erase(length); return S_OK; }

            std::wstring release() { return std::wstring(std::move(m_value)); }

            static PCWSTR get(const std::wstring& value) { return value.c_str(); }

        private:
            std::wstring m_value;
        };
    }
    /// @endcond

    // str_raw_ptr is an overloaded function that retrieves a const pointer to the first character in a string's buffer.
    // This is the overload for std::wstring.  Other overloads available in resource.h.
    inline PCWSTR str_raw_ptr(const std::wstring& str)
    {
        return str.c_str();
    }

} // namespace wil

#endif // WIL_ENABLE_EXCEPTIONS

#endif // __WIL_STL_INCLUDED
