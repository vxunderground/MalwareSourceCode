import pefile
import sys
import os

DUMMY_FUNC = "\x55\x8b\xec\x51\xc7\x45\xfc\xbe\xba\xad\xde\x8b\xe5\x5d\xc3"

def main():
	exe_path = sys.argv[1]
	pe = pefile.PE(exe_path)
	print "Starting!"
	output = ""
	text_section = ""
	for section in pe.sections:
		if ".text" in section.Name:
			print (section.Name, hex(section.VirtualAddress), hex(section.Misc_VirtualSize), section.SizeOfRawData )
			text_section = pe.get_data(section.VirtualAddress, section.SizeOfRawData)
			binary_shellcode = text_section[:text_section.find(DUMMY_FUNC)]
			for byte in binary_shellcode:
				output += "\\x%x" % ord(byte)
	output = "#define SHELLCODE (\"%s\")" % output
	folder, file_name = os.path.split(exe_path)
	base, _ = os.path.splitext(file_name)
	print os.path.join(folder, base+".h")
	open(os.path.join(folder, base) + ".h", "wb").write(output)
	open(os.path.join(folder, base) + ".text", "wb").write(text_section)
	open(os.path.join(folder, base) + ".shellcode", "wb").write(binary_shellcode)
	
				
	
if __name__ == "__main__":
	main()