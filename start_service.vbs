Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Check if background service is already running
Function IsRunning(procName)
    Dim colProcesses
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='" & procName & "'")
    IsRunning = (colProcesses.Count > 0)
End Function

' Background service: SMTC reader + album art extractor
If Not IsRunning("background_service.exe") Then
    strSvc = """" & strDir & "\background_service.exe"" """ & strDir & """"
    objShell.Run strSvc, 0, False
End If

' System info updater
strCmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strDir & "\system_info_updater.ps1"" -UpdateInterval 1"
objShell.Run strCmd, 0, False
