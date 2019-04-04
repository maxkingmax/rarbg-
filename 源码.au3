
#Region
#AccAu3Wrapper_Icon=										 ;程序图标
#AccAu3Wrapper_UseX64=n										 ;是否编译为64位程序(y/n)
#AccAu3Wrapper_OutFile=										 ;输出的Exe名称
#AccAu3Wrapper_OutFile_x64=									 ;64位输出的Exe名称
#AccAu3Wrapper_UseUpx=n										 ;是否使用UPX压缩(y/n) 注:开启压缩极易引起误报问题
#AccAu3Wrapper_Res_Comment=									 ;程序注释
#AccAu3Wrapper_Res_Description=								 ;程序描述
#AccAu3Wrapper_Res_Fileversion=1.0.0.1						 ;文件版本
#AccAu3Wrapper_Res_FileVersion_AutoIncrement=y				 ;自动更新版本 y/n/p=自动/不自动/询问
#AccAu3Wrapper_Res_ProductVersion=1.0						 ;产品版本
#AccAu3Wrapper_Res_Language=2052							 ;资源语言, 英语=2057/中文=2052
#AccAu3Wrapper_Res_LegalCopyright=							 ;程序版权
#AccAu3Wrapper_Res_RequestedExecutionLevel=					 ;请求权限: None/asInvoker/highestAvailable/requireAdministrator
#AccAu3Wrapper_Run_Tidy=y									 ;编译前自动整理脚本(y/n)
#AccAu3Wrapper_Run_Obfuscator=y								 ;启用脚本加密(y/n)
#Obfuscator_Parameters=/cs=1 /cn=1 /cf=1 /cv=1 /sf=1 /sv=1	 ;脚本加密参数: 0/1不加密/加密, /cs字符串 /cn数字 /cf函数名 /cv变量名 /sf精简函数 /sv精简变量
#AccAu3Wrapper_DBSupport=y									 ;使字符串加密支持双字节字符(y/n) <- 可对中文字符等实现字符串加密
#AccAu3Wrapper_AntiDecompile=y								 ;是否启用防反功能(y/n) <- 简单防反, 用于应对傻瓜式反编译工具
#EndRegion

#cs ＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿

	欢迎使用 AutoIt v3 中文版 !

	IT天空:		https://www.itiankong.com/
	Au3专区:	https://www.itiankong.net/forum-au3-1.html

	Au3版本:	3.3.14.2
	脚本作者:
	脚本功能:
	更新日志:
	联系方式:

#ce ＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿脚本开始＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿

#include <Array.au3>
#include <IE.au3>
#include <File.au3>
$magfile = @ScriptDir & "\magnet.txt"
$errorfile = @ScriptDir & "\error.tmp"
If FileExists($errorfile) Then
	$iii = IniRead($errorfile, "error", "page", 1)
	$input1 = IniRead($errorfile, "error", "key", "")
Else

	$input1 = InputBox("输入关键字", "请在下框输入要搜索的关键字:", "blacked 2160p", "", 320, 150)
	If @error <> 0 Then Exit


	$iii = 1
EndIf


If StringInStr($input1, " ") Then
	$input = StringReplace($input1, " ", "+")
EndIf

$ofile = FileOpen($magfile, 1 + 8)

$v = 1
$total = 0
FileWriteLine($ofile, "<------" & $input & "------")

While 1



	Local $oIE = _IECreate("https://rarbgprx.org/torrents.php?search=" & $input & "&category=4&page=" & $iii, 1, $v, 1, 0)

	Local $oLinks = _IELinkGetCollection($oIE)

	Local $iNumLinks = @extended

;~ 	Local $sTxt = $iNumLinks & " links found" & @CRLF & @CRLF
	Local $ljsz[$iNumLinks + 1]
	$ljsz[0] = $iNumLinks
	$i = 1
	For $oLink In $oLinks
		$ljsz[$i] = $oLink.href
		$i += 1
	Next
;~ _ArrayDisplay($ljsz)
;~ _FileWriteFromArray("1.txt", $ljsz)
	$a = _ArrayToString($ljsz, @CR)
;~ _IEQuit($oIE)


;~ MsgBox(0, "", $a)


;~ 	$array = StringRegExp($a, ".+&page=[0-9]\r", 3)
	$array2 = StringRegExp($a, ".+\/torrent\/[a-z,0-9]{7}\r", 3)
;~ 	$narray = _ArrayUnique($array)
	$array2 = _ArrayUnique($array2)
;~ 	_ArrayDisplay($narray)
;~ 	_ArrayDisplay($array2)
	If $array2[0] = 8 Then
		
		_IEQuit($oIE)
		FileWriteLine($ofile, "------共 " & $total & " 条------>")
		FileClose($ofile)
		TrayTip("结果：", "共抓取到 " & $total & " 个磁力链接。", 5)
		If FileExists($errorfile) Then FileDelete($errorfile)
		Sleep(8000)
		Exit
		
		
		
		
	Else
		TraySetToolTip('正在处理第 ' & $iii & ' 页的数据。')
		For $i = 9 To $array2[0]
			Local $oIE = _IECreate($array2[$i], 1, 0, 1, 0)
			Local $sHTML = _IEBodyReadHTML($oIE)
;~ MsgBox(0,"",$sHTML)
			$mag = StringRegExp($sHTML, "magnet\:\?xt\=urn\:btih\:[0-9,a-z,A-Z]{40}", 2)
			_IEQuit($oIE)
			_FileWriteFromArray($ofile, $mag)
;~ 			_ArrayDisplay($mag)
			Sleep(1000)
			If Not IsArray($mag) Then
				TrayTip("警告！", "可能服务器开启了保护机制，请关闭程序，稍候重试！", 5)
				IniWrite($errorfile, "error", "page", $iii)
				IniWrite($errorfile, "error", "key", $input1)
				FileWriteLine($ofile, "------第 " & $iii & " 页未完------>")
				Sleep(5000)
				Exit
			EndIf
			
		Next
		$total = $total + ($array2[0] - 8)
		$iii += 1
		$v = 0
		FileWriteLine($ofile, "------第 " & $iii - 1 & " 页------>")
	EndIf
	
WEnd




