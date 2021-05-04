#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk

#SingleInstance force
SetTitleMatchMode, 2

Mode := 0
Text = If you see this, I suck
WinGetTitle, CurrentWin
WinGet, ActiveWinPID, PID, A

If InStr(A_Args[1], "c") {
	Mode := 1
	Text := "Is " . namefromPID(ActiveWinPID) . " Crashed?"
}

If InStr(A_Args[1], "g") {
	Mode := 2
	Text := "Press          for Game Menu"
}

If InStr(A_Args[1], "cr") {
	Mode := 3
	Text := "Hold          for Controls"
}

If InStr(A_Args[1], "x") {
	Mode := 4
}

If InStr(A_Args[1], "s") {
	Mode := 5
}

Gui, closing: -border
Gui, closing: Color, 000000
Gui, closing: +AlwaysOnTop

Gui, closing: Font, cFFFFFF s30 q4 bold, Roboto
If (Mode = 4 || Mode = 5) {
	Gui, closing: Add, Text, x20 y20, Hold         +         to Exit
	
	Gui, closing: Add, Picture, x120 y7 w80 h-1, C:\Assets\Controllers\Xbox\XboxOne_Windows.png
	Gui, closing: Add, Picture, x240 y7 w80 h-1, C:\Assets\Controllers\Xbox\XboxOne_Menu.png

	Gui, closing: show, x1300 y920 w600 h100
}

Else {
	Gui, closing: Add, Text, x20 y20, %Text%
	Gui, closing: Add, Text, x20 y100, Hold         +         to Exit


	If (Mode = 2) {
		Gui, closing: Add, Picture, x152 y17 w60 h-1, C:\Assets\Controllers\Xbox\XboxOne_Home.png
	}
	Else If (Mode = 3) {
		Gui, closing: Add, Picture, x135 y17 w60 h-1, C:\Assets\Controllers\Xbox\XboxOne_Home.png
	}
	Gui, closing: Add, Picture, x120 y82 w80 h-1, C:\Assets\Controllers\Xbox\XboxOne_Windows.png
	Gui, closing: Add, Picture, x240 y82 w80 h-1, C:\Assets\Controllers\Xbox\XboxOne_Menu.png

	Gui, closing: show, x1300 y840 w600 h180
}

If (Mode = 1) {
	Count := 0
	While (Count < 150) {
		Count += 1
		Sleep, 100
	}
}

If ((Mode = 4) ||(Mode = 2)) {
	Count := 0
	GameProcess := A_Args[2]
	While (Count < 70) {
		Count += 1
		Sleep, 100
		
		If (!ProcessExist(GameProcess) || WinExist("Pause")) {
			Process, Close, GameDialog.exe
			Process, Close, DSDialog.exe
			Process, Close, GenericDialog.exe
			Process, Close, ChromeDialog.exe
		}
		
		If (WinExist("loading...") || WinExist("Compiling") || WinExist("Building") || WinExist("Operation in progress")) {
			Count := 0
		}
	}
}

If (Mode = 3) {
	Count := 0
	While (Count < 70) {
		Count += 1
		Sleep, 100
	}
}

If (Mode = 5) {
	Sleep, 5000
}

If (Mode = 0) {
	Sleep, 2000
}

Gui, closing: Destroy

Process, Close, GameDialog.exe
Process, Close, DSDialog.exe
Process, Close, GenericDialog.exe
Process, Close, ChromeDialog.exe
