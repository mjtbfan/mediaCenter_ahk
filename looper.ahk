#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

Loop {
	If (!ProcessExist("MasterScript.exe")) {
		If (gamePID()) {
			Run, "C:\AutoHotkey\bin\64\MasterScript.exe" "C:\AutoHotkey\master.ahk" "q",, Min
		}
		Else {
			Run, "C:\AutoHotkey\bin\64\MasterScript.exe" "C:\AutoHotkey\master.ahk"
		}
	}
	
	Sleep, 1000
}

Process, Close, LoopScript.exe