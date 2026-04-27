Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
strCmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strDir & "\system_info_updater.ps1"" -UpdateInterval 1"
objShell.Run strCmd, 0, False
