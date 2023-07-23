#pragma compile(Console, true)
If WinExists('[CLASS:AutoIt v3;TITLE:' & @ScriptName & ']') Then
	MsgBox(48, @ScriptName, 'Позволено запускать только одну копию программы!' & @CRLF & @CRLF & 'ОК ==> ВЫХОД')
	Exit
EndIf
AutoItWinSetTitle(@ScriptName)
TraySetIcon('ico/22308ladybeetle_98810.ico')
#AutoIt3Wrapper_Icon=ico/22308ladybeetle_98810.ico

$time = @YEAR & "_" & @MON & "_" & @MDAY & " " & @HOUR & "_" & @MIN & "_" & @SEC
Global $main_log_txt_file = FileOpen("NEW_BD_backup_logs\NEW_BD_backup_" & $time & ".txt", 2)
Global $main_backup_folder = "BD_backup_folder"
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")



;#RequireAdmin
#include "../libs/plink_func.au3"
#include "../libs/SFTPEx.au3"
#include <Array.au3>
#include <File.au3>
#include <Date.au3>
#include "../libs/_DateDiff_2.au3"
#include "../libs/telegram-udf-autoit-master/telegram-udf-autoit-master/src/Telegram.au3"
Local $ChatID = '1009377001' ;Your ChatID here (take this from @MyTelegramID_bot)
Local $Token = '5618230805:AAFAIcZme9nBm_TUPnmhgdG3_gTT3eLP1Bs'  ;Token here
Local $Sleep_posle_vseh_beckapov = 43200000

zapis_v_logi("! _NowDate()... " & _NowDate() & @CRLF & @CRLF)
zapis_v_logi("! Initializing bot... " & _InitBot($Token) & @CRLF & @CRLF)

Local $rows[100]
Local $server_ip_mas[100]
Local $sUsername_mas[100]
Local $sPassword_mas[100]
Local $local_disk_gde_backup_mas[100]
Local $local_disk_gde_backup_copy_mas[100]
Local $skolko_file_backup_max_mas[100]
Local $bd_user_mas[100]
Local $put_do_bd_file_na_servere_mas[100]
Local $bd_name_mas[100]
Local $bd_pass_mas[100]
Local $ssh_key_mas[100]
Local $papka_otkyda_kachat_backup_mas[100]
Local $second_command_for_backup_mas[100]
Local $ne_sravnivat_razmer_s_predidyshim_backupom_mas[100]
Local $backup_comand_mas[100]

Local $delat_restore_mas[100]
Local $restore_comand1_mas[100]
Local $restore_comand2_mas[100]
Local $restore_comand3_mas[100]


Zagryzka_settings("settings.txt")



zapis_v_logi("Number of databases to backup from a file settings.txt " & $rows[0] & @CRLF)


;While 1
$result_erorr = -1

;$b=$b+1
For $i = 0 To $rows[0] - 1
	$kak_zalilsa_backup = 0
	$sleep = 2000
	$prefix_dla_logov = @ComputerName & " " & @OSVersion & "  BD BACKUP"


	zamena_dla_backup_comand($backup_comand_mas[$i], $bd_user_mas[$i], $put_do_bd_file_na_servere_mas[$i], $bd_name_mas[$i])
	;$b=$b+1

	$local_papka_gde_backup = $local_disk_gde_backup_mas[$i] & ":\" & $main_backup_folder & "\" & $server_ip_mas[$i] & "_bd_" & $bd_name_mas[$i] & "\"
	zapis_v_logi("$local_papka_gde_backup=" & $local_papka_gde_backup & @CRLF & @CRLF)

	$local_papka_gde_backup_copy = $local_disk_gde_backup_copy_mas[$i] & ":\" & $main_backup_folder & "\" & $server_ip_mas[$i] & "_bd_" & $bd_name_mas[$i] & "\"
	zapis_v_logi("$local_papka_gde_backup_copy=" & $local_papka_gde_backup_copy & @CRLF & @CRLF)


	$result_erorr = Delat_backUP($server_ip_mas[$i], $sUsername_mas[$i], $sPassword_mas[$i], $prefix_dla_logov, $bd_user_mas[$i], $put_do_bd_file_na_servere_mas[$i], $bd_name_mas[$i], $ssh_key_mas[$i], $second_command_for_backup_mas[$i], $backup_comand_mas[$i])

	If $result_erorr = -1 Then
		$kak_zalilsa_backup = Skachivanie_backup_na_local_comp($prefix_dla_logov, $server_ip_mas[$i], $sUsername_mas[$i], $sPassword_mas[$i], $put_do_bd_file_na_servere_mas[$i], $local_papka_gde_backup, $skolko_file_backup_max_mas[$i], $papka_otkyda_kachat_backup_mas[$i], $bd_name_mas[$i])
	EndIf
	If $kak_zalilsa_backup = 1 Then
		proverka_sto_beckup_ne_osen_old($local_papka_gde_backup, $Sleep_posle_vseh_beckapov, $server_ip_mas[$i], $bd_name_mas[$i], $ne_sravnivat_razmer_s_predidyshim_backupom_mas[$i])
	EndIf


	If $result_erorr = -1 And $kak_zalilsa_backup = 1 And $delat_restore_mas[$i] = 1 Then
		Delat_restore($restore_comand1_mas[$i], $restore_comand2_mas[$i], $restore_comand3_mas[$i], $server_ip_mas[$i], $sUsername_mas[$i], $sPassword_mas[$i], $ssh_key_mas[$i], $prefix_dla_logov, $bd_name_mas[$i], $bd_user_mas[$i], $put_do_bd_file_na_servere_mas[$i], $second_command_for_backup_mas[$i])
	EndIf


	If $local_disk_gde_backup_copy_mas[$i] <> -1 Then
		zapis_v_logi($time & "BD BACKUP COPY START----------------------" & @CRLF & @CRLF)

		If $result_erorr = -1 Then
			$kak_zalilsa_backup = Skachivanie_backup_na_local_comp($prefix_dla_logov&" COPY", $server_ip_mas[$i], $sUsername_mas[$i], $sPassword_mas[$i], $put_do_bd_file_na_servere_mas[$i], $local_papka_gde_backup_copy, $skolko_file_backup_max_mas[$i], $papka_otkyda_kachat_backup_mas[$i], $bd_name_mas[$i])
		EndIf
		If $kak_zalilsa_backup = 1 Then
			proverka_sto_beckup_ne_osen_old($local_papka_gde_backup_copy, $Sleep_posle_vseh_beckapov, $server_ip_mas[$i], $bd_name_mas[$i], $ne_sravnivat_razmer_s_predidyshim_backupom_mas[$i])
		EndIf
		zapis_v_logi($time & "BD BACKUP COPY END----------------------" & @CRLF & @CRLF)
	EndIf




	$time = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN
	zapis_v_logi($time & " BD BACKUP END" & @CRLF & @CRLF)

Next
;zapis_v_logi("Do sleep" & @CRLF)
;Sleep($Sleep_posle_vseh_beckapov)
;zapis_v_logi("Posle sleep" & @CRLF)
;WEnd
Ydalenie_LOGOV_esli_ih_mnogo(100, "NEW_BD_backup_logs")
FileClose($main_log_txt_file)


Func Delat_restore($restore_comand1, $restore_comand2, $restore_comand3, $server_ip, $sUsername, $sPassword, $ssh_key, $prefix_dla_logov, $bd_name, $bd_user, $put_do_bd_file_na_servere, $second_command_for_backup)
	zapis_v_logi(@CRLF & "Delat_restore START--------------------------------------------------------------------------------------" & @CRLF)
	$_plinkhandle = plink_login(2000, 2000, 5, $server_ip, $sUsername, $sPassword, $prefix_dla_logov, $ssh_key)
	zapis_v_logi("$_plinkhandle=" & $_plinkhandle & @CRLF)
	$result_erorr = -1

	If $_plinkhandle <> -1 Then

		$buf_collect = _Collect_stdout($sleep)
		zapis_v_logi("log posle buf_collect=" & $buf_collect & @CRLF)
		Sleep($sleep)


		zapis_v_logi("$second_command_for_backup:" & $second_command_for_backup & @CRLF)
		If $second_command_for_backup <> -1 Then
			_SayPlus($second_command_for_backup)
			Sleep($sleep)
			$result_error = Zdat_otvet_ot_consoli_posle_comandi("$second_command_for_Restore:", $prefix_dla_logov, "Restore", $server_ip, $bd_name)
			$buf_collect = _Collect_stdout($sleep)
			zapis_v_logi("log posle second_command=" & $buf_collect & @CRLF)
		EndIf


		zapis_v_logi("$restore_comand1: " & $restore_comand1 & @CRLF)
		_SayPlus($restore_comand1)
		$buf_collect = _Collect_stdout(0)
		Sleep($sleep)

		$result_error = Zdat_otvet_ot_consoli_posle_comandi($restore_comand1, $prefix_dla_logov, "Restore", $server_ip, $bd_name)

		zapis_v_logi("$restore_comand2: " & $restore_comand2 & @CRLF)
		_SayPlus($restore_comand2)
		$buf_collect = _Collect_stdout(0)
		Sleep($sleep)
		$result_error = Zdat_otvet_ot_consoli_posle_comandi($restore_comand2, $prefix_dla_logov, "Restore", $server_ip, $bd_name)


		$restore_comand3 = zamena_dla_backup_comand($restore_comand3, $bd_user, $put_do_bd_file_na_servere, $bd_name)
		zapis_v_logi("$restore_comand3: " & $restore_comand3 & @CRLF)
		_SayPlus($restore_comand3)
		$buf_collect = _Collect_stdout(0)
		Sleep($sleep)
		$result_error = Zdat_otvet_ot_consoli_posle_comandi($restore_comand3, $prefix_dla_logov, "Restore", $server_ip, $bd_name)

	EndIf


	_Plink_close()

	zapis_v_logi("Delat_restore END--------------------------------------------------------------------------------------" & @CRLF)


EndFunc   ;==>Delat_restore

Func Zdat_otvet_ot_consoli_posle_comandi($comanda, $prefix_dla_logiv, $prefix_dla_logiv2, $server_ip, $bd_name)
	zapis_v_logi(@CRLF & "Zdat_otvet_ot_consoli_posle_comandi START--------------------------------------------------------------------------------------" & @CRLF)
	$result_error = -1

	$n = 0
	While 1
		$buf_collect = _Collect_stdout($sleep)
		$n = $n + 1

		If StringInStr($buf_collect, "#") = 0 Then
			zapis_v_logi($prefix_dla_logiv2 & " in progress loop iteration=" & $n & @CRLF)
			Sleep(2500)

			If $n > 100 Then
				zapis_v_logi("log posle " & $prefix_dla_logiv2 & " " & $n & "=" & $buf_collect & @CRLF & @CRLF)
				$_plinkhandle = -1
				$text_v_log = $prefix_dla_logov & " " & $prefix_dla_logiv2 & " ERORR comanda=" & $comanda & " " & $server_ip & " DB_NAME:" & $bd_name & " very long bilo 100 popitok polysit otvet # ot consoli"
				zapis_v_logi($text_v_log & @CRLF)
				$MsgID = _SendMsg($ChatID, $text_v_log)
				$result_erorr = 1
				ExitLoop
			EndIf

		Else
			zapis_v_logi("log posle " & $prefix_dla_logiv2 & " " & $n & "=" & $buf_collect & @CRLF & @CRLF)
			zapis_v_logi($prefix_dla_logiv2 & " END loop iteration=" & $n & @CRLF & @CRLF)
			_SayPlus("echo $?")
			Sleep($sleep)
			$buf_collect = _Collect_stdout($sleep)
			zapis_v_logi("Return code START=" & @CRLF & $buf_collect & @CRLF & " Return cod END " & @CRLF & @CRLF)


			$result_error = return_code_analysis($buf_collect)
			zapis_v_logi("return_code_analysis result_error=" & $result_error & @CRLF)
			If $result_error = 1 Then
				$text_v_log = $prefix_dla_logov & " ERORR comanda=" & $comanda & " " & $server_ip & " DB_NAME:" & $bd_name & " Return code 1"
				zapis_v_logi($text_v_log & @CRLF)
				$MsgID = _SendMsg($ChatID, $text_v_log)
			EndIf


			ExitLoop
		EndIf

	WEnd

	zapis_v_logi("Zdat_otvet_ot_consoli_posle_comandi END--------------------------------------------------------------------------------------" & @CRLF)

	Return $result_error

EndFunc   ;==>Zdat_otvet_ot_consoli_posle_comandi

Func zamena_dla_backup_comand($backup_comand_raw, $bd_user, $put_do_bd_file_na_servere, $bd_name)
	zapis_v_logi(@CRLF & "zamena_dla_backup_comand START--------------------------------------------------------------------------------------" & @CRLF)

	$backup_comand_raw = StringReplace($backup_comand_raw, "#bd_user#", $bd_user)
	$backup_comand_raw = StringReplace($backup_comand_raw, "#put_do_bd_file_na_servere#", $put_do_bd_file_na_servere)
	$backup_comand_raw = StringReplace($backup_comand_raw, "#bd_name#", $bd_name)
	zapis_v_logi("$backup_comand_raw=" & $backup_comand_raw & @CRLF)

	zapis_v_logi("zamena_dla_backup_comand END--------------------------------------------------------------------------------------" & @CRLF)

	Return $backup_comand_raw
EndFunc   ;==>zamena_dla_backup_comand


Func proverka_sto_beckup_ne_osen_old($local_papka_gde_backup, $Sleep_posle_vseh_beckapov, $server_ip, $bd_name, $ne_sravnivat_razmer_s_predidyshim_backupom)
	zapis_v_logi(@CRLF & "proverka_sto_beckup_ne_osen_old START---------------------------------------------------------------------" & @CRLF)
	Local $poslednia_data_mas[1000]
	$result_erorr = Poisk_samogo_poslednego_file($local_papka_gde_backup, $poslednia_data_mas, $server_ip, $bd_name, $ne_sravnivat_razmer_s_predidyshim_backupom)
	$proslo_milisekynd = -1

	If $result_erorr = -1 Then
		$curr_time_mas = StringRegExp(_DateTimeFormat(_NowCalc(), 0), "\d+", 3)
		$proslo_milisekynd = raznisa_dat_v_milesekydah($curr_time_mas, $poslednia_data_mas)
		If $proslo_milisekynd > $Sleep_posle_vseh_beckapov Then
			$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " very old backup probably the new one is not written"
			zapis_v_logi($text_v_log & @CRLF)
			$MsgID = _SendMsg($ChatID, $text_v_log)
		EndIf
	EndIf

	zapis_v_logi("$proslo_milisekynd=" & $proslo_milisekynd & @CRLF)
	zapis_v_logi("proverka_sto_beckup_ne_osen_old END---------------------------------------------------------------------" & @CRLF)
EndFunc   ;==>proverka_sto_beckup_ne_osen_old
Func raznisa_dat_v_milesekydah($d, $d2)

	$tmp = $d[2]
	$d[2] = $d[0]
	$d[0] = $tmp

	$d = _DateDiff_2($d2, $d, 1)
	$proslo_milisekynd = $d[0] * 31536000 + $d[1] * 2592000 + $d[2] * 86400 + $d[3] * 3600 + $d[4] * 60 + $d[5]



	;$proslo_milisekynd = ($d[2] * 31536000 + $d[1] * 2592000 + $d[0] * 86400 + $d[3] * 3600 + $d[4] * 60 + $d[5]) - ($d2[0] * 31536000 + $d2[1] * 2592000 + $d2[2] * 86400 + $d2[3] * 3600 + $d2[4] * 60 + $d2[5])

	$proslo_milisekynd = $proslo_milisekynd * 1000
	Return $proslo_milisekynd
EndFunc   ;==>raznisa_dat_v_milesekydah

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

		If $array[0] = 'server_ip' Then
			$i = 0
			$server_ip_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'sUsername' Then
			$i = 1
			$sUsername_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'sPassword' Then
			$i = 2
			$sPassword_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'local_disk_gde_backup' Then
			$i = 3
			$local_disk_gde_backup_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'local_disk_gde_backup_copy' Then
			$i = 4
			$local_disk_gde_backup_copy_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'skolko_file_backup_max' Then
			$i = 5
			$skolko_file_backup_max_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'bd_user' Then
			$i = 6
			$bd_user_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'put_do_bd_file_na_servere' Then
			$i = 7
			$put_do_bd_file_na_servere_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'bd_name' Then
			$i = 8
			$bd_name_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'bd_pass' Then
			$i = 9
			$bd_pass_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'ssh_key' Then
			$i = 10
			$ssh_key_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'papka_otkyda_kachat_backup' Then
			$i = 11
			$papka_otkyda_kachat_backup_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'second_command_for_backup' Then
			$i = 12
			$second_command_for_backup_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'ne_sravnivat_razmer_s_predidyshim_backupom' Then
			$i = 13
			$ne_sravnivat_razmer_s_predidyshim_backupom_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'backup_comand' Then
			$i = 14
			$backup_comand_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'delat_restore' Then
			$i = 15
			$delat_restore_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'restore_comand1' Then
			$i = 16
			$restore_comand1_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'restore_comand2' Then
			$i = 17
			$restore_comand2_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf

		If $array[0] = 'restore_comand3' Then
			$i = 18
			$restore_comand3_mas[$rows[$i]] = StringStripWS($array[1], 3)
			$rows[$i] = $rows[$i] + 1
		EndIf


	WEnd
	;zapis_v_logi("$rows[$i]=" & $rows[$i] & @CRLF)
	;_ArrayDisplay($bd_user_mas, "$avArray - заданный вручную 1D массив")
	FileClose($hFile)


	;zapis_v_logi("$main_server_ip=" & $main_server_ip & @CRLF)


EndFunc   ;==>Zagryzka_settings


Func Delat_backUP($server_ip, $sUsername, $sPassword, $prefix_dla_logov, $bd_user, $put_do_bd_file_na_servere, $bd_name, $ssh_key, $second_command_for_backup, $backup_comand_raw)
	zapis_v_logi(@CRLF & "Delat_backUP START--------------------------------------------------------------------------------------" & @CRLF)
	$sleep = 2000

	$_plinkhandle = plink_login(2000, 2000, 5, $server_ip, $sUsername, $sPassword, $prefix_dla_logov, $ssh_key)
	zapis_v_logi("$_plinkhandle=" & $_plinkhandle & @CRLF)
	$result_erorr = 1

	If $_plinkhandle <> -1 Then
		$result_erorr = -1
		$buf_collect = _Collect_stdout($sleep)
		zapis_v_logi("log posle buf_collect=" & $buf_collect & @CRLF)
		Sleep($sleep)


		$create_dir_command = "mkdir /home/admin/backup/"
		_SayPlus($create_dir_command)
		Sleep($sleep)


		zapis_v_logi("$second_command_for_backup:" & $second_command_for_backup & @CRLF)
		If $second_command_for_backup <> -1 Then
			_SayPlus($second_command_for_backup)
			Sleep($sleep)
			$buf_collect = _Collect_stdout($sleep)
			zapis_v_logi("log posle second_command=" & $buf_collect & @CRLF)
		EndIf

		$backup_comand = zamena_dla_backup_comand($backup_comand_raw, $bd_user, $put_do_bd_file_na_servere, $bd_name)
		;$backup_comand = "/usr/bin/pg_dump -h 127.0.0.1 -p 5432 -U " & $bd_user & " -F plain --no-owner --no-privileges --no-tablespaces --verbose --no-unlogged-table-data -f " & $put_do_bd_file_na_servere & " " & $bd_name
		zapis_v_logi("$backup_comand" & $backup_comand & @CRLF)
		_SayPlus($backup_comand)
		$buf_collect = _Collect_stdout(0)
		Sleep($sleep)



		$result_error = Zdat_otvet_ot_consoli_posle_comandi($backup_comand, $prefix_dla_logov, " Backup", $server_ip, $bd_name)

		zapis_v_logi("$put_do_bd_file_na_servere=" & $put_do_bd_file_na_servere & @CRLF & @CRLF)


	EndIf


	_Plink_close()

	zapis_v_logi("Delat_backUP END--------------------------------------------------------------------------------------" & @CRLF)

	Return $result_erorr
EndFunc   ;==>Delat_backUP

Func Skachivanie_backup_na_local_comp($prefix_dla_logov, $server_ip, $sUsername, $sPassword, $put_do_bd_file_na_servere, $local_papka_gde_backup, $skolko_file_backup_max, $papka_otkyda_kachat_backup, $bd_name)
	zapis_v_logi(@CRLF & "Skachivanie_backup_na_local_comp START---------------------------------------------------------------------" & @CRLF)
	zapis_v_logi($prefix_dla_logov & "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------" & @CRLF & @CRLF)

	If StringInStr(FileGetAttrib($local_papka_gde_backup), "D") = 0 Then
		zapis_v_logi("PAPKA SOZDANA" & @CRLF)
		DirCreate($local_papka_gde_backup)
	EndIf

	zapis_v_logi(" $server_ip=" & $server_ip & @CRLF)
	zapis_v_logi(" $sUsername=" & $sUsername & @CRLF)
	zapis_v_logi(" $sPassword=" & $sPassword & @CRLF)
	Sleep(10000)
	$hSession = _SFTP_Open('../libs/psftp.exe')

	If $hSession <> "TIME ERROR" Then


		zapis_v_logi(@error & " hSession=" & $hSession & @CRLF)
		$hSession = _SFTP_Connect($hSession, $server_ip, $sUsername, $sPassword, 22)
		zapis_v_logi(@error & " hSession=" & $hSession & @CRLF)

		$time = @YEAR & "_" & @MON & "_" & @MDAY & " " & @HOUR & "_" & @MIN
		$put_do_file_local = $local_papka_gde_backup & $server_ip & "_" & $time & ".sql"

		; $kak_zalilsa_backup =0 VSE PLOHO $kak_zalilsa_backup =1 VSE OK

		zapis_v_logi("$papka_otkyda_kachat_backup=" & $papka_otkyda_kachat_backup & @CRLF)
		zapis_v_logi($time & " $put_do_file_local=" & $put_do_file_local & @CRLF)
		$kak_zalilsa_backup = _SFTP_DirGetContents($hSession, $papka_otkyda_kachat_backup, $put_do_file_local)

		zapis_v_logi(@error & " $kak_zalilsa_backup=" & $kak_zalilsa_backup & " " & $time & @CRLF)

		;zapis_v_logi("$kak_zalilsa_backupCOPY=" & FileCopy($put_do_file_local, $local_papka_gde_backup_COPY & $Prefix_dla_backup_file & $time & ".sql", 9) & @CRLF)
		;$local_papka_gde_backup_COPY 



		_SFTP_Close($hSession)

		If $kak_zalilsa_backup = 0 Then
			$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " bekap ne scachalsa na local comp"
			zapis_v_logi($text_v_log & @CRLF)
			$MsgID = _SendMsg($ChatID, $text_v_log)
		EndIf

		If $kak_zalilsa_backup = 1 Then
			$kak_zalilsa_backup = Ydalenie_filov_esli_ih_mnogo($skolko_file_backup_max, $local_papka_gde_backup, $prefix_dla_logov, $server_ip, $bd_name)
		EndIf

	Else
		$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " _SFTP_Open TIME ERROR "
		zapis_v_logi($text_v_log & @CRLF)
		$MsgID = _SendMsg($ChatID, $text_v_log)
	EndIf


	zapis_v_logi("Skachivanie_backup_na_local_comp END---------------------------------------------------------------------" & @CRLF)

	Return $kak_zalilsa_backup
EndFunc   ;==>Skachivanie_backup_na_local_comp

Func Ydalenie_filov_esli_ih_mnogo($skolko_file_backup_max, $local_papka_gde_backup, $prefix_dla_logov, $server_ip, $bd_name)
	zapis_v_logi(@CRLF & "Ydalenie_filov_esli_ih_mnogo START--------------------------------------------------------------------------------------" & @CRLF)

	zapis_v_logi("$local_papka_gde_backup=" & $local_papka_gde_backup & @CRLF)

	$FileList = _FileListToArray($local_papka_gde_backup)
	$kak_zalilsa_backup = 1

	If $FileList = 0 Then
		$kak_zalilsa_backup = 0
		$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " Func Ydalenie_filov_esli_ih_mnogo Net failov v papke dla backup erorr_code=" & @error
		zapis_v_logi($text_v_log & @CRLF)
		$MsgID = _SendMsg($ChatID, $text_v_log)
		$result_erorr = 1
	Else

		$skolko_filov_nado_ydalit = $FileList[0] - $skolko_file_backup_max
		zapis_v_logi("$skolko_filov_nado_ydalit=" & $skolko_filov_nado_ydalit & @CRLF)

		For $i = 1 To $skolko_filov_nado_ydalit


			$ranniy_file = Poisk_samogo_starogo_file($local_papka_gde_backup)
			zapis_v_logi("ranniy_file=" & $ranniy_file & @CRLF)
			zapis_v_logi("FileDelete=" & FileDelete($local_papka_gde_backup & $ranniy_file) & @CRLF)


		Next
	EndIf
	zapis_v_logi("Ydalenie_filov_esli_ih_mnogo END--------------------------------------------------------------------------------------" & @CRLF)

	Return $kak_zalilsa_backup
EndFunc   ;==>Ydalenie_filov_esli_ih_mnogo

Func Poisk_samogo_poslednego_file($papka, ByRef $poslednia_data_mas, $server_ip, $bd_name, $ne_sravnivat_razmer_s_predidyshim_backupom)
	zapis_v_logi(@CRLF & "Poisk_samogo_poslednego_file START--------------------------------------------------------------------------------------" & @CRLF)

	zapis_v_logi("$papka=" & $papka & @CRLF)
	$FileList = _FileListToArray($papka)
	$result_eror = -1


	If $FileList = 0 Then
		$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " Func Poisk_samogo_poslednego_file Net failov v papke dla backup erorr_code=" & @error
		zapis_v_logi($text_v_log & @CRLF)
		$MsgID = _SendMsg($ChatID, $text_v_log)
		$result_erorr = 1
	Else


		$posledniy_file_id = 1
		$poslednia_data = FileGetTime($papka & $FileList[1], 1, 1)

		$posledniy_file_id2 = 1
		$poslednia_data2 = FileGetTime($papka & $FileList[1], 1, 1)


		For $i = 1 To $FileList[0]


			$t1 = FileGetTime($papka & $FileList[$i], 1, 1)

			If Int($t1) > Int($poslednia_data) Then
				zapis_v_logi($t1 & " " & $FileList[$i] & " ranse chem " & $poslednia_data & " " & $FileList[$posledniy_file_id] & @CRLF)

				$posledniy_file_id2 = $posledniy_file_id
				$poslednia_data2 = $poslednia_data

				$posledniy_file_id = $i
				$poslednia_data = $t1
			EndIf


			;If Int($t1) < Int($poslednia_data) and Int($t1) > Int($poslednia_data2) Then
			;	$posledniy_file_id2 = $i
			;	$poslednia_data2 = $t1
			;EndIf
		Next

		$poslednia_data_mas = FileGetTime($papka & $FileList[$posledniy_file_id], 1)
		$poslednia_data_ma2 = FileGetTime($papka & $FileList[$posledniy_file_id2], 1)
		$iSize = FileGetSize($papka & $FileList[$posledniy_file_id])
		$iSize2 = FileGetSize($papka & $FileList[$posledniy_file_id2])

		zapis_v_logi("posledniy_file=" & $FileList[$posledniy_file_id] & @CRLF)
		zapis_v_logi("posledniy_file2=" & $FileList[$posledniy_file_id2] & @CRLF)
		zapis_v_logi("$iSize=" & $iSize & @CRLF)
		zapis_v_logi("$iSize2=" & $iSize2 & @CRLF)
		zapis_v_logi("$ne_sravnivat_razmer_s_predidyshim_backupom=" & $ne_sravnivat_razmer_s_predidyshim_backupom & @CRLF)

		If ($iSize < $iSize2 And $ne_sravnivat_razmer_s_predidyshim_backupom = -1) Or $iSize = 0 Then
			$text_v_log = $prefix_dla_logov & " ERORR " & $server_ip & " DB_NAME:" & $bd_name & " razmer new backup file " & $papka & $FileList[$posledniy_file_id] & " mense sem predidusiy " & $FileList[$posledniy_file_id] & " ili raven nuly"
			zapis_v_logi($text_v_log & @CRLF)
			$MsgID = _SendMsg($ChatID, $text_v_log)
			$result_erorr = 1
		EndIf



	EndIf


	zapis_v_logi("Poisk_samogo_poslednego_file END--------------------------------------------------------------------------------------" & @CRLF)

	Return $result_erorr
EndFunc   ;==>Poisk_samogo_poslednego_file

Func Poisk_samogo_starogo_file($papka)
	zapis_v_logi(@CRLF & "Poisk_samogo_starogo_file START--------------------------------------------------------------------------------------" & @CRLF)


	$FileList = _FileListToArray($papka)
	;_ArrayDisplay($FileList,"$FileList")

	$rannia_data = FileGetTime($papka & $FileList[1], 1, 1)
	$ranniy_file = 1
	zapis_v_logi("$rannia_data=" & $rannia_data & @CRLF)

	For $i = 1 To $FileList[0]


		$t1 = FileGetTime($papka & $FileList[$i], 1, 1)

		If Int($t1) < Int($rannia_data) Then

			zapis_v_logi($t1 & " " & $FileList[$i] & " ranse chem " & $rannia_data & " " & $FileList[$ranniy_file] & @CRLF)
			$ranniy_file = $i
			$rannia_data = $t1

		EndIf


	Next
	;zapis_v_logi("ranniy_file=" & $FileList[$ranniy_file] & @CRLF)
	zapis_v_logi("$rannia_data=" & Int($rannia_data) & @CRLF)
	zapis_v_logi("Poisk_samogo_starogo_file END--------------------------------------------------------------------------------------" & @CRLF)

	Return $FileList[$ranniy_file]
EndFunc   ;==>Poisk_samogo_starogo_file

Func plink_login($sleep_posle_error, $sleep, $max_popitok_logina, $ip, $login, $password, $prefix_dla_logov, $ssh_key = "")
	$popitok_logina = 0
	While 1
		$_plinkhandle = _Start_plink2("..\libs\plink.exe", $ip, $login, $password, "ssh", "22", $ssh_key)
		zapis_v_logi("$popitok_logina=" & $popitok_logina & " $_plinkhandle=" & $_plinkhandle & " " & @CRLF)
		Sleep($sleep)
		_SayPlus("y")
		Sleep($sleep)

		$buf_collect = _Collect_stdout($sleep)
		zapis_v_logi("log posle =" & $buf_collect & @CRLF & @CRLF)
		;StringInStr($buf_collect, "Last login", 1) or StringInStr($buf_collect, "Using username", 1) or
		If ((StringInStr($buf_collect, "root@", 1) Or StringInStr($buf_collect, "bash", 1)) And StringInStr($buf_collect, "password:", 1) = 0) Then
			ExitLoop
		Else

			If $popitok_logina > $max_popitok_logina Then
				$_plinkhandle = -1
				$text_v_log = $prefix_dla_logov & " ERORR " & $ip & " bilo " & $popitok_logina & " neydasnih popitok logina po SSH"
				zapis_v_logi($text_v_log & @CRLF)
				$MsgID = _SendMsg($ChatID, $text_v_log)
				ExitLoop
			EndIf

			$popitok_logina += 1
			Sleep($sleep_posle_error)
		EndIf

	WEnd

	Return $_plinkhandle

EndFunc   ;==>plink_login

Func MyErrFunc()
	zapis_v_logi("Мы перехватили COM ошибку !" & @CRLF & @CRLF & _
			"err.description is: " & @TAB & $oMyError.description & @CRLF & _
			"err.windescription:" & @TAB & $oMyError.windescription & @CRLF & _
			"err.number is: " & @TAB & Hex($oMyError.number, 8) & @CRLF & _
			"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
			"err.scriptline is: " & @TAB & $oMyError.scriptline & @CRLF & _
			"err.source is: " & @TAB & $oMyError.source & @CRLF & _
			"err.helpfile is: " & @TAB & $oMyError.helpfile & @CRLF & _
			"err.helpcontext is: " & @TAB & $oMyError.helpcontext _
			)

	;$MyErrFunc_count = $MyErrFunc_count + 1
EndFunc   ;==>MyErrFunc
Func return_code_analysis($buf_collect)
	zapis_v_logi(@CRLF & "return_code_analysis START--------------------------------------------------------------------------------------" & @CRLF)
	zapis_v_logi("$buf_collect=" & $buf_collect & @CRLF)
	$result_error = -1


	$aArray = StringRegExp($buf_collect, '(?m).+', 3)

	zapis_v_logi("$aArray[0]=" & $aArray[0] & @CRLF)
	zapis_v_logi("$aArray[1]=" & $aArray[1] & @CRLF)
	zapis_v_logi("$aArray[2]=" & $aArray[2] & @CRLF)


	If (Number($aArray[1]) = 1) Then
		zapis_v_logi("!!!!$aArray[1] 1" & @CRLF)
	EndIf

	If (Number($aArray[2]) = 1) Then
		zapis_v_logi("!!!!$aArray[2] 1" & @CRLF)
	EndIf

	$result_error = 1
	If ($aArray[1] = 0 Or $aArray[2] = 0) Then
		zapis_v_logi("Tyt 0" & @CRLF)
		$result_error = -1
	EndIf

	;If (Number($aArray[1]) = 1 Or Number($aArray[2]) = 1) Then
	;	zapis_v_logi("Tyt 1" & @CRLF)
	;	$result_error = 1
	;EndIf


	zapis_v_logi("return_code_analysis END--------------------------------------------------------------------------------------" & @CRLF)
	Return $result_error

EndFunc   ;==>return_code_analysis
Func zapis_v_logi($text)
	ConsoleWrite($text)
	FileWrite($main_log_txt_file, $text)
EndFunc   ;==>zapis_v_logi
Func Ydalenie_LOGOV_esli_ih_mnogo($skolko_file_logov_max, $papka_gde_logi)
	zapis_v_logi(@CRLF & "Ydalenie_LOGOV_esli_ih_mnogo START--------------------------------------------------------------------------------------" & @CRLF)

	zapis_v_logi("$papka_gde_logi=" & $papka_gde_logi & @CRLF)

	$FileList = _FileListToArray($papka_gde_logi)


	If $FileList = 0 Then

	Else

		$skolko_filov_nado_ydalit = $FileList[0] - $skolko_file_logov_max
		zapis_v_logi("$skolko_filov_nado_ydalit=" & $skolko_filov_nado_ydalit & @CRLF)

		For $i = 1 To $skolko_filov_nado_ydalit


			$ranniy_file = Poisk_samogo_starogo_file($papka_gde_logi)
			zapis_v_logi("ranniy_file=" & $ranniy_file & @CRLF)
			zapis_v_logi("FileDelete=" & FileDelete($papka_gde_logi & "\" & $ranniy_file) & @CRLF)


		Next
	EndIf
	zapis_v_logi("Ydalenie_LOGOV_esli_ih_mnogo END--------------------------------------------------------------------------------------" & @CRLF)

EndFunc   ;==>Ydalenie_LOGOV_esli_ih_mnogo
