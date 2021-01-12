.286
.model  small
.code
         org     0100h

msg_addr equ     offset msg - offset proc_start- 3

         extrn   mime:near,emime:near

                      ; 以下程式，除了要注意的地方有注解，其它部份自己研究

start:
         mov     ah,09h
         mov     dx,offset dg_msg
         int     21h

         mov     ax,offset emime+000fh ; 本程式 + mime+000fh 之後的位址
                                   ; 若減 0100h 則成為本程式 + mime 的長度

         shr     ax,4
         mov     bx,cs
         add     bx,ax

         mov     es,bx                   ; 設 es 用來放解碼程式和被編碼資料
                                                ; 解碼程式最大為 1024 bytes
                                ; 若用在常駐程式時，則須注意分配的記憶體大小

         mov     cx,50
dg_l0:
         push    cx
         mov     ah,3ch
         xor     cx,cx
         mov     dx,offset file_name
         int     21h
         xchg    bx,ax

         mov     cx,offset proc_end-offset proc_start    ; 被編碼程式的長度

         mov     si,offset proc_start         ; ds:si -> 要被編碼的程式位址
         xor     di, di

         push    bx                                      ; 保存 file handle

         mov     bx, 100h                                ; com 模式

         call    mime

         pop     bx

         mov     ah,40h        ; 返回時 ds:dx = 解碼程式 + 被編碼程式的位址
         int     21h     ; cx = 解碼程式 + 被編碼程式的長度，其它暫存器不變

         mov     ah,3eh
         int     21h

         push    cs
         pop     ds                                          ; 將 ds 設回來

         mov     bx,offset file_num
         inc     byte ptr ds:[bx+0001h]
         cmp     byte ptr ds:[bx+0001h],'9'
         jbe     dg_l1
         inc     byte ptr ds:[bx]
         mov     byte ptr ds:[bx+0001h],'0'
dg_l1:
         pop     cx
         loop    dg_l0
         mov     ah,4ch
         int     21h

file_name db     '000000'
file_num db      '00.com',00h

dg_msg   db      'generates 50 mime encrypted test files.',0dh,0ah,'$'

proc_start:
         call    $+0003h
         pop     dx
         add     dx,msg_addr
         mov     ah,09h
         int     21h
         int     20h
msg      db      'This is <MIME> test file.$'
proc_end:
         end     start
