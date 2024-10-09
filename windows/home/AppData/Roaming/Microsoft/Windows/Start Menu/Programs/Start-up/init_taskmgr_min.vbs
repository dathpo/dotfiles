Dim WShell
Set WShell = CreateObject("WScript.Shell")
WShell.Run "taskmgr.exe", 0
Set WShell = Nothing