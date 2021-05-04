#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/xinputTools.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk

#SingleInstance force
SetTitleMatchMode, 3

XInputController := XInput_Initialize()

If (!WinExist("Settings")) {
	Sleep, 2500
	Run, explorer ms-settings:
	Sleep, 500
	Run, "C:\AutoHotkey\bin\64\dialogs\GenericDialog.exe" "C:\AutoHotkey\gui\closeDialog.ahk" "s"
	MouseMove, 9999, 9999, 0
}

WinWait, Settings
WinActivate, Settings

Open := 1
Keyboard := 0
Joy2Key("clean")
Sleep, 100
Run, "C:\JoyToKey_en\JoyToKey.exe" "WinSettings"

CoordMode, Mouse
MouseMove, 1400, 700, 0

While (WinExist("Settings") && Open) {
	Sleep, 10
	
	WinGet, Maxed, MinMax, Settings
	If (Maxed != 1) {
		WinMaximize, Settings
	}
	
	If (allJOY(XInputController, 2)) {
		Send, {Esc}
		Sleep, 300
	}
	Else If (allJOY(XInputController, 7, 8)) {
		Open := 0
	}
	Else If (notJOY(XInputController, 7, 8)) {
		If (ProcessExist("osk.exe")) {
			WinClose, On-Screen Keyboard
			Run, "C:\JoyToKey_en\JoyToKey.exe" "WinSettings"
			Keyboard := 0
		}
		Else {
			Run, osk
			Keyboard := 1
		}
		
		Sleep, 300
	}
	
	If (!WinShown("On-Screen Keyboard") && Keyboard = 1) {
		WinClose, On-Screen Keyboard
		Run, "C:\JoyToKey_en\JoyToKey.exe" "WinSettings"
		Keyboard := 0
	}
}
XInput_Terminate(XInputController)
Run, "C:\JoyToKey_en\JoyToKey.exe" "Blank"

Gui, Destroy
Process, Close, osk.exe

KodiAppClose("ws")
Sleep, 250

MouseMove, 1919, 1079
MouseClick, Left
Process, Close, GenericDialog.exe
Process, Close, SettingScript.exe