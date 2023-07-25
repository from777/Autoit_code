#include "../libs/telegram-udf-autoit-master/telegram-udf-autoit-master/src/Telegram.au3"

$proga_pri_zakritii_kotoroi_ety_toze_zakrivat = "Main_backup"

If WinExists('[CLASS:AutoIt v3;TITLE:' & @ScriptName & ']') Or WinExists(@ScriptName & ".exe") Then
	;MsgBox(48, @ScriptName, 'Позволено запускать только одну копию программы!' & @CRLF & @CRLF & 'ОК ==> ВЫХОД')
	ConsoleWrite("Позволено запускать только одну копию программы!" & @CRLF & @CRLF)
	Exit
EndIf
AutoItWinSetTitle(@ScriptName)
TraySetToolTip(@ScriptName & " v2")

$prefix_dla_logov = "BD BACKUP"
Global $ChatID
Global $Token
Zagryzka_settings("c:\postgres_backup_settings.txt")
ConsoleWrite("! Initializing bot... " & _InitBot($Token) & @CRLF & @CRLF)

TraySetIcon('ico/22308ladybeetle_98810.ico')
#AutoIt3Wrapper_Icon=ico/22308ladybeetle_98810.ico

$n = 0
While 1
	
	If WinExists('[CLASS:AutoIt v3;TITLE:' & $proga_pri_zakritii_kotoroi_ety_toze_zakrivat & '.au3]') = 0 And WinExists($proga_pri_zakritii_kotoroi_ety_toze_zakrivat & ".exe") = 0 Then
		ConsoleWrite("Nety MAIN progi zakritie etoi " & @CRLF & @CRLF)
		$tg_Text = $prefix_dla_logov &" "& @ComputerName& " "& @OSVersion&" "& @IPAddress1&" "& @IPAddress2& " Autoit_errror.au3 ili .exe govorit sto Nety MAIN progi " &  $proga_pri_zakritii_kotoroi_ety_toze_zakrivat
		$MsgID = _SendMsg($ChatID, $tg_Text)
		Exit
	EndIf

	$n = $n + 1
	Sleep(60000)      ;задержка 60 секунд
	If WinExists("AutoIt Error") Then
		;если окно есть, действуем по плану один

		$hwnd = WinActivate("AutoIt Error")
		$time = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
		If $n < 500 Then
			$hFile = FileOpen("AutoIt_Error_log.txt", 1)
		Else
			$hFile = FileOpen("AutoIt_Error_log.txt", 2)
			$n = 0
		EndIf

		$Text = ControlGetText($hwnd, "", "[CLASS:Static; INSTANCE:2]")

		$tg_Text = $prefix_dla_logov & " Autoit_errror.au3 " & $Text
		$MsgID = _SendMsg($ChatID, $tg_Text)

		FileWrite($hFile, $time & " " & $Text & @CRLF & @CRLF & "=======================================================" & @CRLF)
		FileClose($hFile)
		ConsoleWrite($time & " $Text=" & $Text & @CRLF & @CRLF)
		Sleep(100)

		ControlClick($hwnd, "", "[CLASS:Button; INSTANCE:1]", "left", 1, 39, 7)

	EndIf
WEnd


Func Zagryzka_settings($file_name)

	$hFile = FileOpen($file_name, 0)

	; Проверяет, является ли файл открытым, перед тем как использовать функции чтения/записи в файл
	If $hFile = -1 Then
		MsgBox(4096, "Ошибка", "Невозможно открыть файл " & $file_name)
		Exit
	EndIf


	For $i = 0 To 99
		$rows[$i] = 0
	Next

	; Читает построчно текст, пока не будет достигнут конец файла EOF
	While 1

		$sLine = FileReadLine($hFile)
		If @error = -1 Then ExitLoop
		;zapis_v_logi("$sLine=" & $sLine & @CRLF)

		$array = _StringExplode($sLine, "=", 1)


		
		If $array[0] = 'ChatID' Then
			$ChatID = StringStripWS($array[1], 3)
		

		EndIf
		If $array[0] = 'Token' Then
			$Token = StringStripWS($array[1], 3)

		EndIf



	WEnd
	;zapis_v_logi("$rows[$i]=" & $rows[$i] & @CRLF)
	;_ArrayDisplay($bd_user_mas, "$avArray - заданный вручную 1D массив")
	FileClose($hFile)


	;zapis_v_logi("$main_server_ip=" & $main_server_ip & @CRLF)


EndFunc