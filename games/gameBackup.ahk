#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/xinputTools.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk
#Include C:/AutoHotkey/games/helpers/gameTools.ahk

#SingleInstance force
SetTitleMatchMode, 2

SetBatchLines %AVGBATCHLINES%
Process, Priority,, L

XInputController := XInput_Initialize()

WinGame := winGamePID()
EmuGame := emulatorPID()

FFActive := 0
RRActive := 0
HomePlayer := -1
HomeCombo := -1

While (ProcessExist(ahk_pid EmuGame)) {
	Sleep, 10

	Joy2Key("clean")
	
	If (allJOY(XInputController, 7, 8)) {
		SetTimer, EmuCloseTimer, %EXITTIME%
				
		While (allJOY(XInputController, 7,8)) {
			Sleep, 10
		}
		
		SetTimer, EmuCloseTimer, Off
	}	
	
	; Pause Screen
	Else If (allJOY(XInputController, "X") && !WinShown("Pause")) {
		HomePlayer := allJOY(XInputController, "X", "player")
		If (DialogExist()) {
			Process, Close, GameDialog.exe
			Process, Close, DSDialog.exe
		}
		
		SetTimer, HomeButtTimer, 90
		
		CheckLoop := 1
		While(oneJOY(XInputController, "X", HomePlayer)) {
			Sleep, 10
			
			If (CheckLoop) {
				If (oneJOY(XInputController, 7, HomePlayer)) {
					HomeCombo := 7
					CheckLoop := 0
				}
				Else If (oneJOY(XInputController, 8, HomePlayer)) {
					HomeCombo := 8
					CheckLoop := 0
				}
				Else If (oneJOY(XInputController, "L", HomePlayer)) {
					HomeCombo := "L"
					CheckLoop := 0
				}
				Else If (oneJOY(XInputController, "R", HomePlayer)) {
					HomeCombo := "R"
					CheckLoop := 0
				}
			}
		}
		
		HomePlayer := -1
		HomeCombo := -1
		SetTimer, HomeButtTimer, Off
	}
}

While (ProcessExist(ahk_pid WinGame)) {
	Sleep, 10
	
	If (allJOY(XInputController, 7, 8)) {
		SetTimer, WinCloseTimer, %EXITTIME%
				
		While (allJOY(XInputController, 7,8)) {
			Sleep, 10
		}
		
		SetTimer, WinCloseTimer, Off
	}
}

MouseMove, 9999, 9999, 0
ResetLoadingScreen(1)

XInput_Terminate(XInputController)
Process, Close, GameScript.exe

WinCloseTimer:
	WinClose, ahk_pid %WinGame%
	
	SetTimer, WinCloseTimer, Off
	Return
	
EmuCloseTimer:
	CloseEmu()
	
	SetTimer, EmuCloseTimer, Off
	Return

HomeButtTimer:
	If (HomeCombo = 7 || oneJOY(XInputController, 7, HomePlayer)) {
		LoadEmu()
	}
	Else If (HomeCombo = 8 || oneJOY(XInputController, 8, HomePlayer)) {
		SaveEmu()
	}
	Else If (HomeCombo = "R" || oneJOY(XInputController, "R", HomePlayer)) {
		If (RRActive) {
			RRActive := allRR(RRActive)
			Sleep, 250
		}
			
		FFActive := allFF(FFActive)
	}
	Else If (HomeCombo = "L" || oneJOY(XInputController, "L", HomePlayer)) {
		If (FFActive) {
			FFActive := allFF(FFActive)
			Sleep, 250
		}
			
		RRActive := allRR(RRActive)
	}
	Else {
		If (RRActive) {
			RRActive := allRR(RRActive)
			Sleep, 250
		}
	
		Run, "C:\AutoHotkey\bin\64\helpers\BoxPauseScript.exe" "C:\AutoHotkey\games\helpers\gamePause.ahk",, Hide
		While(!ProcessExist("BoxPauseScript.exe"))
		{}
		Sleep, 50
		
		SendLevel, 2
		Send, {F13}
	}
	
	While (oneJOY(XInputController, "X", HomePlayer)) {
		Sleep, 50
	}
	
	HomePlayer := -1
	HomeCombo := -1
	SetTimer, HomeButtTimer, Off
	Return