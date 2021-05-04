#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk

SetTitleMatchMode, 2
SetKeyDelay, 50, 50
CoordMode, Mouse

Count := 0

While (Count < 25) {
	WinGetPos, X, Y, W, H, ahk_exe kodi.exe
	
	If (X != -32000) {
		Run, "C:\AutoHotkey\bin\64\flags\MinFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		Sleep, 75
		
		WinActivate, ahk_exe kodi.exe
		
		MouseMove, (X + W - 120), (Y + 15)
		Sleep, 75
		MouseClick, Left
		Sleep, 75
		MouseMove, 9999, 9999, 0
	}
	Else {
		Process, Close, MinFlag.exe
	}
	
	Sleep, 250
	Count += 1
}

Process, Close, KodiMinScript.exe