in x64
1.get peb from fs:[0x60] by asm file
2.get Ldr by peb
3.get kernel32 module in the third module 
ntdll->kernelbase->kernel32

in x86
1.get peb from fs:[0x30] by inline asm
2.get Ldr by peb
3.get kernel32 module in the second module
ntdll->kernel32

the offset in the PEB is different from x64 and x86
This demo is only Test on Win7 x64
