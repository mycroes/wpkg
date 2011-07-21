' This script takes one argument, the name of a running process.
' This script will terminate when all of the processes with that name terminate.
' It is useful in WPKG deployments where a setup program calls a second copy
' of itself and then stops because it keeps WPKG from stopping too early.
' It was posted to the WPKG mailing list by  Tobias Baumgartner
' (totalbillig @ gmx dot de)

Set objDictionary = CreateObject("Scripting.Dictionary")

If WScript.Arguments.Count <> 1 Then
	WScript.Quit
End If

strProcess = WScript.Arguments.Item(0)
strComputer = "."

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Do
    WScript.Sleep 1000
    Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where name = '" & strProcess & "'")
Loop Until colProcesses.Count = 0
