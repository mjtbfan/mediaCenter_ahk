#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/games/helpers/gameLoop.ahk
#Include C:/AutoHotkey/games/helpers/gameLoadScreen.ahk

yuzuLaunch(ConfigArray) {

	System := ConfigArray[1]
	Rom := ConfigArray[2]
	Game := ConfigArray[3]
	Config := ConfigArray[4]

	Name := "yuzu"
	
	AppPath := ""

	If InStr(Config, "Xbox Controllers"){
		AppPath := "C:\Emulators\Default\Yuzu\yuzu.lnk"
	}
	Else If InStr(COnfig, "Xbox (Alternate)") {
		AppPath := "C:\Emulators\Custom\YuzuAlt\yuzu.lnk"
	}

	emuLoadScreen(Name)

	Run, "%AppPath%" "%Rom%"

	emuWaitLoop(Name)

	Run, "C:\AutoHotkey\bin\64\EmuLoadScript.exe" "C:\AutoHotkey\games\helpers\emuLoader.ahk" "%Name%"

	Process, Priority, yuzu.exe, A

	emuLoop()

	Return
}