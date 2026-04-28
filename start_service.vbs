Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
strAgent = strDir & "\publish\cmdwallpaper_agent.exe"

' Agent exe not found — nothing to do
If Not objFSO.FileExists(strAgent) Then
    WScript.Quit 1
End If

' ── Simplified PID check: only skip if the SAME exe is already running ──
strPidFile = strDir & "\cmdwallpaper.pid"
bSkip = False
If objFSO.FileExists(strPidFile) Then
    On Error Resume Next
    pid = CLng(Trim(objFSO.OpenTextFile(strPidFile, 1).ReadAll()))
    If Err.Number = 0 Then
        Set proc = GetObject("winmgmts:root/cimv2:Win32_Process.Handle='" & pid & "'")
        If Err.Number = 0 Then
            exePath = LCase(proc.ExecutablePath)
            If InStr(exePath, LCase(strAgent)) > 0 Then
                bSkip = True ' Same exe is already running
            End If
        End If
    End If
    On Error Goto 0
End If

If bSkip Then
    WScript.Quit 0
End If

' ── Start agent with correct working directory ──
objShell.CurrentDirectory = strDir
cmd = """" & strAgent & """ ."
objShell.Run cmd, 0, False
