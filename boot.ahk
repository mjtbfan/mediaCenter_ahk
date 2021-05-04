#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/gui/loadingGui.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk
#Include C:/AutoHotkey/helpers/tools.ahk

#SingleInstance force
SetTitleMatchMode, 2

IntTimeout := 30

buildLoadScreen()
showLoadScreen("")

Run, "C:\AutoHotkey\bin\64\helpers\Meme.exe" "C:\AutoHotkey\helpers\bootMeme.ahk"

If (!ProcessExist("explorer.exe")) {
	Run, explorer.exe
	Sleep, 3500
}

updateLoadScreen("Waiting for Internet Connection... " . IntTimeout)
SetTimer, IntTimer, 1000
If (!WaitForInternetTimeout(IntTimeout * 1000)) {
	dedicatedDialog("GenericDialog.exe", "No Internet Connection", 5000, "r", 500)
}
SetTimer, IntTimer, Off

Run, "C:\AutoHotkey\files\devices\disablewiimotes.lnk"
Sleep, 500

CloseMultiTasking(0)
Process, Close, osk.exe

updateLoadScreen("Waiting for Steam.exe...")
Steam("dirty")
Sleep, 1000

If (!ProcessExist("Taskbar Magic.exe")) {
	Run, "C:\Taskbar\Taskbar Magic.lnk"
}

Run, "C:\JoyToKey_en\JoyToKey.exe" "Blank"
updateLoadScreen("Waiting for JoyToKey.exe...")
While(!ProcessExist("JoyToKey.exe")) 
{}
Sleep, 500

Run, "C:\Kodi\kodi.lnk"
updateLoadScreen("Waiting for Kodi.exe...")
While(!WinShown("Kodi")) 
{}

updateLoadScreen("")
Run, "C:\AutoHotkey\bin\64\LoopScript.exe" "C:\AutoHotkey\looper.ahk"
ExitApp

IntTimer:
	IntTimeout -= 1
	updateLoadScreen("Waiting for Internet Connection... " . IntTimeout)
	
	Return



