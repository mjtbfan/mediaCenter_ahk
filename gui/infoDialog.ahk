#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2

infoDialog(text, time, direction := "r", width := 700) {
	Gui, info: -border
	Gui, info: Color, 000000
	Gui, info: +AlwaysOnTop
	
	Gui, info: Font, cFFFFFF s30 q4 bold, Roboto
	Gui, info: Add, Text, x20 y10, %text%
	
	If (direction = "r") {
		offset := 1900 - width
	}
	Else If (direction = "l") {
		offset := 20
	}
	
	Gui, info: show, x%offset% y950 w%width% h70
	Sleep, %time%
	
	Gui, info: Destroy
}

dedicatedDialog(exe, text, time, direction := "r", width := 700) {
	ScriptDir := "C:\AutoHotkey\bin\64\dialogs\" . exe
	Run, "%ScriptDir%" "C:\AutoHotkey\gui\dedicatedDialog.ahk" "%text%" "%time%" "%direction%" %width%
}
