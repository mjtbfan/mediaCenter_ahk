#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk

SetTitleMatchMode, 2
SetKeyDelay, 50, 50

If InStr(A_Args[1], "c") {
	While(ProcessExist("chrome.exe")) {
		WinActivate, Chrome
		Send, ^+w
		Sleep, 100
	}
}

Else If InStr(A_Args[1], "b") {
	UpdateLoadFlag("Exiting BigBox.exe...")
	
	While(ProcessExist("BigBox.exe")) {
		Sleep, 1000
		
		Count += 1
		If (Count > 17) {
			Process, Close, BigBox.exe
		}
	}
	
	UpdateLoadFlag("close")
	
	Sleep, 100
}

Else If InStr(A_Args[1], "j") {
	While(JackBoxExist()) {
		Sleep, 500
	}
}

Else If InStr(A_Args[1], "ws") {
	WinClose, Settings
}

KodiLoad("close")

Sleep, 250

Process, Close, KodiCloseScript.exe