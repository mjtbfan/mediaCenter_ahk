#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/games/helpers/gameLoop.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk
#Include C:/AutoHotkey/games/helpers/gameLoadScreen.ahk

windowsLaunch(ConfigArray) {
	Game := ConfigArray["rom"]
	
	Type := winLoadScreen(Game)
	If (Type = "kill") {
		Return
	}

	Run, %Game%

	winWaitLoop(Game, Type)

	WinGame := winGamePID()
	Process, Priority, %WinGame%, A

	winLoop(Type)

	winCloseScreen(Game, Type)
	
	Return
}


	