#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

#Include C:/AutoHotkey/helpers/tools.ahk

If (!SteamShown() && !JackBoxExist()) {
	KodiLoad("open", "Waiting for Steam.exe...")
	Steam("clean")
	If InStr(A_Args[1], "1") {
		Run steam://rungameid/331670
	}
	Else If InStr(A_Args[1], "2") {
		Run steam://rungameid/397460
	}
	Else If InStr(A_Args[1], "3") {
		Run steam://rungameid/434170
	}
	DetectHiddenWindows, Off
	WinWait, Steam
	UpdateLoadFlag("Waiting for JackBox Party Pack " A_Args[1] ".exe...")
	WinWaitClose
	Sleep, 1500
}

WinWait, Jackbox
UpdateLoadFlag("close")
WinWaitClose

Sleep, 250

KodiAppClose("j")

Process, Close, JackboxScript.exe