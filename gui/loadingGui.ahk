#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk

#SingleInstance force 

buildLoadScreen() {
	global
	; VARS
	wheelGif = file:///C:\Assets\loading-compressed.gif

	; FORMAT
	Gui, loadscreen: -border
	Gui, loadscreen: Color, 000000

	; ELEMENTS
	Gui, loadscreen: Add, ActiveX, x928 y894 w62 h62 vWB, shell explorer

	Gui, loadscreen: Font, cFFFFFF s20 q4 bold, Roboto
	Gui, loadscreen: Add, Text, vMain +Center x515 y975, WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW

	; WHEEL
	wb.Navigate("about:blank")
	html :=
	(RTRIM
	"<!DOCTYPE html>
		<meta http-equiv=""X-UA-Compatible"" content=""IE-edge""/>
		<html>
			<head>
				<style>
					body {
						background-color: #000000;
					}
					img {
						position:absolute; 
						top: -2px;
						left: -2px;
					}
				</style>
			</head>
			<body>
				<img src=""" wheelGif """ alt=""Picture"" style=""width:65px;height:65px;"" />
			</body>
		</html>"
	)
	wb.document.write(html)
}

showLoadScreen(maintext) {
	global
	
	MouseMove, 9999, 9999, 0
	
	mainDefault = Now Loading...
	
	Gui, loadscreen: show, w1930 h1090
	
	If (maintext = "") {
		GuiControl, loadscreen: , Main, %mainDefault%
	}
	Else {
		GuiControl, loadscreen: , Main, %maintext%
	}
	
	MouseMove, 9999, 9999, 0
}

updateLoadScreen(maintext) { ; THIS MIGHT BE BUGGY
	global
	
	mainDefault = Now Loading...
	
	If (maintext = "") {
		GuiControl, loadscreen: , Main, %mainDefault%
	}
	Else {
		GuiControl, loadscreen: , Main, %maintext%
	}
}

hideLoadScreen() {
	MouseMove, 9999, 9999, 0
	Gui, loadscreen: hide
}

getLoadID() {
	DetectHiddenWindows, Off
	Gui, loadscreen: +LastFound
	loadID := WinExist()
	Return loadID
}
