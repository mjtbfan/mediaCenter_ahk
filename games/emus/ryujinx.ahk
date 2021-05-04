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

ryujinxLaunch(ConfigArray) {
	Name := "Ryujinx"
	
	System := ConfigArray["system"]
	Rom := ConfigArray["rom"]
	Game := ConfigArray["game"]
	Config := ConfigArray["config"]
	Path := ConfigArray["emuDir"]
	EXE := ConfigArray["emuExe"] . ".exe"
	LNK := ConfigArray["emuExe"] . ".lnk"

	emuLoadScreen(Name)

	Run, "%Path%%LNK%" "%Rom%"

	emuWaitLoop(Name)

	Run, "C:\AutoHotkey\bin\64\EmuLoadScript.exe" "C:\AutoHotkey\games\helpers\emuLoader.ahk" "%Name%"

	Process, Priority, %EXE%, A

	emuLoop()

	Return
}