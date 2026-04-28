Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' SMTC reader: persistent background EXE, writes smtc_data.json every second
strSmtc = """" & strDir & "\smtc_reader.exe"" """ & strDir & """"
objShell.Run strSmtc, 0, False

' System info updater
strCmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strDir & "\system_info_updater.ps1"" -UpdateInterval 1"
objShell.Run strCmd, 0, False
