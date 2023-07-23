#pragma compile(Console, true)
If WinExists('[CLASS:AutoIt v3;TITLE:' & @ScriptName & ']') Or WinExists(@ScriptName & ".exe") Then
	;MsgBox(48, @ScriptName, 'Позволено запускать только одну копию программы!' & @CRLF & @CRLF & 'ОК ==> ВЫХОД')
	Exit
EndIf
AutoItWinSetTitle(@ScriptName)
TraySetToolTip(@ScriptName & " v3")
TraySetIcon('ico/22308ladybeetle_98810.ico')
#AutoIt3Wrapper_Icon=ico/22308ladybeetle_98810.ico


#include <Array.au3>
#include <Constants.au3>
Local $Sleep_posle_vseh_beckapov = 43200000

$sOut = '' ; Переменная для хранения вывода StdoutRead.

$file_name_dla_zapuska = "NEW_BD_backup.au3"
$file_name_dla_zapuska = "NEW_BD_backup.exe"
$k=0
While 1
	;For $i = 0 To 2
	ConsoleWrite("Try to start Autoit_errror.exe" &  @CRLF)
	$iPID1 = Run("Autoit_errror.exe")
	;$iPID = Run(FileGetShortName(@AutoItExe) & " /AutoIt3ExecuteScript " & FileGetShortName($file_name_dla_zapuska), @WorkingDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	;$iPID = Run($file_name_dla_zapuska, @WorkingDir, @SW_SHOW, $STDERR_CHILD + $STDOUT_CHILD)
	ConsoleWrite("Try to start " & $file_name_dla_zapuska & @CRLF)
	$iPID = Run($file_name_dla_zapuska)
	Sleep(100)
	ConsoleWrite("WinExists('Autoit_errror.exe')=" & WinExists('Autoit_errror.exe')&" WinExists('"&$file_name_dla_zapuska&"')=" & WinExists($file_name_dla_zapuska) & @CRLF)	
	;$iPID = Run(@ComSpec & ' /U /C DIR "' & $sPath & '\' & $sFileMask & '" /B /S /A-D', @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	;ConsoleWrite("$i =" & $i & @CRLF)
	$log_count = 0
	$n = 0
	While 1
		$n = $n + 1
		;$sOut &= StdoutRead($iPID, False)
		$time = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
		ConsoleWrite($time&" 1log posle =" & $n & " " & @error & @CRLF)
		;ConsoleWrite("log posle =" & $sOut & @CRLF)
		Sleep(15000)
		If WinExists('[CLASS:AutoIt v3;TITLE:' & $file_name_dla_zapuska & ']') = 0 Then
			Sleep(1000)
			$sOut &= StdoutRead($iPID, False)
			Sleep(5000)
			
			$time = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
			ConsoleWrite($time&" Console_logs_from_NEW_BD_backup START-----------------------------------------------" & $sOut & @CRLF)
			ConsoleWrite($time&" Console_logs_from_NEW_BD_backup END-------------------------------------------------" & @CRLF)

			;If $log_count < 500 Then
			;	$hFile = FileOpen("Console_logs_from_NEW_BD_backup.txt", 1)
			;Else
			;	$hFile = FileOpen("Console_logs_from_NEW_BD_backup.txt", 2)
			;	$log_count = 0
			;EndIf		
			;FileWrite($hFile, $time & @CRLF & $sOut & @CRLF & @CRLF & "=====================================================================================================================================================================" & @CRLF)
			;FileClose($hFile)
			ExitLoop
		EndIf
	WEnd
	$k=$k+1
	$time = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	ConsoleWrite("Vsego zapuskov backup:"&$k&" "&$time&" Sleep_posle_vseh_beckapov start =" & $Sleep_posle_vseh_beckapov&" milliseconds" & @CRLF& @CRLF)
	Sleep($Sleep_posle_vseh_beckapov)
WEnd
;Next
