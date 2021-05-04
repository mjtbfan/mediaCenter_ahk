#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/xinputTools.ahk

#SingleInstance force
SetTitleMatchMode, 2

XInputController := XInput_Initialize()

QBERT := 0
HEREWEGO := 0
CHEESE := 0
BOZO := 0

While (!ProcessExist("kodi.exe")) {
	Sleep, 10
	
	If (allJOY(XInputController, 6) && !QBERT) {
		Run, "C:\AutoHotkey\bin\64\helpers\Meme.exe" "C:\AutoHotkey\helpers\playSound.ahk" "C:\Assets\Audio\qbert.wav"
		QBERT := 1
	}
	Else If (allJOY(XInputController, 5) && !HEREWEGO) {
		Run, "C:\AutoHotkey\bin\64\helpers\Meme.exe" "C:\AutoHotkey\helpers\playSound.ahk" "C:\Assets\Audio\herewego.wav"
		HEREWEGO := 1
	}
	Else If (allJOY(XInputController, 7) && !CHEESE) {
		Run, "C:\AutoHotkey\bin\64\helpers\Meme.exe" "C:\AutoHotkey\helpers\playSound.ahk" "C:\Assets\Audio\cheese.wav"
		CHEESE := 1
	}
	Else If (allJOY(XInputController, 8) && !BOZO) {
		Run, "C:\AutoHotkey\bin\64\helpers\Meme.exe" "C:\AutoHotkey\helpers\playSound.ahk" "C:\Assets\Audio\bozo.wav"
		BOZO := 1
	}
	
	If (QBERT && !allJOY(XInputController, 6)) {
		QBERT := 0
	}
	If (HEREWEGO && !allJOY(XInputController, 5)) {
		HEREWEGO := 0
	}
	If (CHEESE && !allJOY(XInputController, 7)) {
		CHEESE := 0
	}
	If (BOZO && !allJOY(XInputController, 8)) {
		BOZO := 0
	}
}

XInput_Terminate(XInputController)
ExitApp