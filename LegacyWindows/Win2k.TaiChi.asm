
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Description.TXT]ÄÄÄ
Win2k.TaiChi by Ratter/29A release #1

This virus has some special features which I would like to list here:
	- getting kenel base from PEB
	- infecting winlogon via which it disables SFP, captures admins
	  passwords and later uses them when logged in as normal user to
	  impersonate admin and working under admin privileges
	- once runned as admin adds needed privileges to Everyone
	- disables auditing, clears security event log
	- uses its own routines for infecting PE exe files on NTFS volumes
	  (ie it accesses NTFS structures to locate and access the file, 
	  bypassing security and via this you can even modify files that are
	  normally unmodifiable)
		- for this it uses emulation of memory mapped files using SEH
		- because a proof of concept virus it infects one file in directory
	- everything prepared for using procedure encryption and running length
	  encryption using SEH (routine seh_decode) however not used in this version
	- it has a payload: installs own bootvid.dll which disables security (via
	  SeAccessCheck patching) via patching the NT kernel runtime and displays
	  29A logo while booting Windows

Todo:
	- emulation engine
	- add procedure encryption and running line encryption
	- more heavily testing under WinXP and possibly adapting
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Description.TXT]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Editor]ÄÄÄ
Due the complexity of the source, it has been placed in Binaries folder.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Editor]ÄÄÄ
