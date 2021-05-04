#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/xinputTools.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

SetBatchLines %AVGBATCHLINES%
Process, Priority,, L

XInputController := XInput_Initialize()

If (!ProcessExist("chrome.exe")) {
	KodiLoad("open", "Waiting for chrome.exe...")
	If InStr(A_Args[1], "c") {
		Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --profile-directory="Default" ;"--start-fullscreen"
	}
	If InStr(A_Args[1], "p") {
		Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --profile-directory="Profile 3" "--start-fullscreen"
	}
	If InStr(A_Args[1], "s") {
		Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --profile-directory="Profile 2" "--start-fullscreen"
	}
	WinWait, Chrome
	Sleep, 500
	UpdateLoadFlag("close")
	Sleep, 200
	If InStr(A_Args[1], "c") {
		WinMaximize, Chrome
	}
	MouseMove, 960, 540
	Run, "C:\AutoHotkey\bin\64\dialogs\ChromeDialog.exe" "C:\AutoHotkey\gui\closeDialog.ahk" "cr"
}

If (ProcessExist("MultiFlag.exe") && !ProcessExist("BigBox.exe")
 && (InStr(A_Args[1], "c") || InStr(A_Args[1], "p") || InStr(A_Args[1], "s"))) {
	file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
	file.Write("kodi.exe")
	file.Close()
	
	MouseMove, 960, 540
}

Joy2Key("dirty")
Sleep, 1000

HomePlayer := -1

While(ProcessExist("chrome.exe")) {

	Joy2Key("clean")
	
	If (allJOY(XInputController, "X")) {
		HomePlayer := allJOY(XInputController, "X", "player")
		
		
		If (HomePlayer = 0) {
			Process, Close, ChromeDialog.exe
			
			Run, "C:\AutoHotkey\bin\64\dialogs\ChromeDialog.exe" "C:\AutoHotkey\helpers\chromecontrols.ahk"
			
			While (oneJOY(XInputController, "X", HomePlayer)) {
				Sleep, 10
			}
			
			Process, Close, ChromeDialog.exe
		}
		Else If (!ProcessExist("ChromeDialog.exe")) {
			dedicatedDialog("ChromeDialog.exe", "Use Player 1 Controller", 2000, "r")
		}
	}
	
	Else If (oneJOY(XInputController, 8, 0) && !oneJOY(XInputController, 7, 0) && InStr(A_Args[1], "c")) {
		SetTimer, StartTimer, 50
		
		While (oneJOY(XInputController, 8, 0) && !oneJOY(XInputController, 7, 0)) {
			Sleep, 10
		}
		
		SetTimer, StartTimer, Off
	}
	
	Else If (!oneJOY(XInputController, 8, 0) && oneJOY(XInputController, 7, 0) && !InStr(A_Args[1], "s")) {
		SetTimer, SelectTimer, 50
		
		While (!oneJOY(XInputController, 8, 0) && oneJOY(XInputController, 7, 0)) {
			Sleep, 10
		}
		
		SetTimer, SelectTimer, Off
	}
	
	Else If (allJOY(XInputController, 7, 8)) {
		SetTimer, CloseTimer, %EXITTIME%
				
		While (allJOY(XInputController, 7,8)) {
			Sleep, 10
		}
		
		SetTimer, CloseTimer, Off
	}
	
	If (ProcessExist("MicrosoftEdge.exe")) {
		Process, Close, MicrosoftEdge.exe
	}
}

MouseMove, 9999, 9999, 0
If (ProcessExist("osk.exe")) {
	WinClose, On-Screen Keyboard
}

XInput_Terminate(XInputController)
KodiAppClose("c")

Process, Close, ChromeScript.exe

F14::
	If InStr(A_Args[1], "c") {
		Send, ^{-}
	}
	
	Return
	
F15::
	If InStr(A_Args[1], "c") {
		Send, ^{=}
	}
	
	Return
	
F16::
	If InStr(A_Args[1], "c") {
		Send, ^+{Tab}
	}
	
	Return

F17::
	If InStr(A_Args[1], "c") {
		Send, ^{Tab}
	}
	
	Return

LWin Up:: Return
RWin Up:: Return

CloseTimer:
	MouseMove, 9999, 9999, 0
	If (ProcessExist("osk.exe")) {
		WinClose, On-Screen Keyboard
	}
	
	XInput_Terminate(XInputController)
	KodiAppClose("c")
	
	SetTimer, CloseTimer, Off
	Process, Close, ChromeDialog.exe
	Process, Close, ChromeScript.exe
	Return

StartTimer:
	Send, ^{t}
	
	SetTimer, StartTimer, Off
	Return

SelectTimer:
	If (ProcessExist("osk.exe")) {
		WinClose, On-Screen Keyboard
	}
	Else {
		Run, osk
	}
	
	SetTimer, SelectTimer, Off
	Return

