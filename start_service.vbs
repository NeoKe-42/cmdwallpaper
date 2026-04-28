Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Helper: check if a process is already running
Function IsRunning(procName)
    Dim colProcesses, objProcess
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='" & procName & "'")
    IsRunning = (colProcesses.Count > 0)
End Function

' SMTC service: writes smtc_data.json every second
If Not IsRunning("smtc_service.exe") Then
    strSmtc = """" & strDir & "\smtc_service\publish\smtc_service.exe"" """ & strDir & """"
    objShell.Run strSmtc, 0, False
End If

' Album art extractor
If Not IsRunning("art_extractor.exe") Then
    strArt = """" & strDir & "\art_extractor\publish\art_extractor.exe"" """ & strDir & """"
    objShell.Run strArt, 0, False
End If

' System info updater (always restart to pick up DLL changes)
strCmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strDir & "\system_info_updater.ps1"" -UpdateInterval 1"
objShell.Run strCmd, 0, False
