Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Check PID file: only start if this directory isn't already running
strPidFile = strDir & "\cmdwallpaper.pid"
If objFSO.FileExists(strPidFile) Then
    ' PID file exists — agent may already be running for this dir
    On Error Resume Next
    Dim pid, proc
    pid = CLng(objFSO.OpenTextFile(strPidFile, 1).ReadAll())
    Set proc = GetObject("winmgmts:root/cimv2:Win32_Process.Handle='" & pid & "'")
    If Err.Number = 0 Then
        ' Process exists — check it's from this directory
        If InStr(1, proc.ExecutablePath, strDir, 1) > 0 Then
            ' Already running from this directory, nothing to do
            WScript.Quit 0
        End If
    End If
    On Error Goto 0
End If

' Start the agent
strAgent = """" & strDir & "\publish\cmdwallpaper_agent.exe"" """ & strDir & """"
objShell.Run strAgent, 0, False
