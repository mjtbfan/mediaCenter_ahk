#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/games/helpers/gameTools.ahk

#SingleInstance force

SetTitleMatchMode, 2

Sleep, 500

Loop {
	Sleep, 50
	If (!WinShown("Pause Screen")) {
		Sleep, 500
		ExitApp
	}
}

F13::
	PauseEmu()
	Sleep, 50
	Send, {= down}
	Sleep, 100
	Send, {= up}
	Return

F14::
	ResumeEmu()
	ExitApp

F15::
	If (!ProcessExist("pcsx2.exe")) {
		ResumeEmu()
		Sleep, 50
	}
	
	ResetEmu()
	ExitApp

F16::
	ResumeEmu()
	Sleep, 50
	
	SaveEmu()
	ExitApp
	
F17::
	ResumeEmu()
	Sleep, 50
	
	LoadEmu()
	ExitApp

F18::
	ResumeEmu()
	Sleep, 50
	
	CloseEmu()
	ExitApp

F19::
	ResumeEmu()
	Sleep, 50
	
	SwapDiscEmu()
	ExitApp
	