#UPDATE 2021 DEC 16TH. LOWERED TO TLP:WHITE
#Thanks to @cryptolaemus
https://twitter.com/Cryptolaemus1 and the various contributors of the Emotet Task Force/Working Group
#Emotet Innoculation Script [Quinnoculation]
# *** Must be run as Admin ****
# Purpose: Emotet V5 Loader generates a value in SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ that it uses as an infection marker.
# This value is set to the Victim's Volume Serial ID, and contains the dropped filename of V5's new filename generation algorithm.
# Emotet looks for this key at startup. If it doesn't exist, it recreates it. If it does exist, Emotet reads that key into a buffer after decrypting it. There are not proper protections in place for the buffer.
# This script overwrites that key with a new key that overflows the buffer, crashing the malware. It also generates an eventID.
# Authors: James Quinn, Binary Defense
# Grabs the VolumeSerialNumbers and sets a registry key in Explorer with type= REG_BINARY and a value too large for Emotet to handle, overwriting the destination buffer,
#Which crashes emotet.


function GenerateData{
[byte[]]$string
for ($i = 1;$i -lt 0x340;$i++){
$hexNumber = $i % 10

$string += [byte[]]$hexNumber
}
$string += [byte[]](0x51,0x75,0x69,0x6e,0x6e,0x75,0x6e,0x69,0x7a,0x65,0x64)
return $string
}
if (([IntPtr]::Size) -eq 8){
$Akey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer"
$key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\"
}
else{
$Akey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\"
$key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\"

}

$volumeSerialNumbers = Get-WmiObject Win32_logicaldisk | select-object -ExpandProperty volumeserialnumber
foreach ($x in $volumeSerialNumbers){



Remove-ItemProperty -Path $AKey -Name $x
Remove-ItemProperty -Path $key -Name $x

$data = GenerateData
# Write-Output $data
New-ItemProperty -Path $AKey -Name $x -Value ([byte[]]($data)) -PropertyType Binary
New-ItemProperty -Path $key -Name $x -Value ([byte[]]($data)) -PropertyType Binary


}
