# inject_shellcode
Small compendium of injection techniques commonly used in malware demonstrated on metasploit-generated shellcode<br/>

Various objects of injection:<br/>
+ existing process (found by name)
+ newly created process

Demonstrated methods:<br/>
+ Running shellcode in a new thread
+ Adding shellcode into existing thread (using NtQueueApcThread)
+ Patching Entry Point of the process
+ Patching context of the process
+ Injecting into Tray Window (using SetWindowLong)
