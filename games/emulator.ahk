#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk
#Include C:/AutoHotkey/gui/configGui.ahk
#Include C:/AutoHotkey/games/helpers/emuConfig.ahk
#Include C:/AutoHotkey/games/helpers/emuReplace.ahk
#Include C:/AutoHotkey/games/emus/dolphin.ahk
#Include C:/AutoHotkey/games/emus/retroarch.ahk
#Include C:/AutoHotkey/games/emus/citra.ahk
#Include C:/AutoHotkey/games/emus/desmume.ahk
#Include C:/AutoHotkey/games/emus/cemu.ahk
#Include C:/AutoHotkey/games/emus/pcsx2.ahk
#Include C:/AutoHotkey/games/emus/rpcs3.ahk
#Include C:/AutoHotkey/games/emus/ppsspp.ahk
#Include C:/AutoHotkey/games/emus/yuzu.ahk
#Include C:/AutoHotkey/games/emus/xenia.ahk
#Include C:/AutoHotkey/games/emus/ryujinx.ahk
#Include C:/AutoHotkey/games/emus/windows.ahk

Process, Priority,, L
SetBatchLines -1

If (A_Args[1] = "config") {

	If (InStr(A_Args[3], "GameScript.exe")) {
		dedicatedDialog("GenericDialog.exe", "This title does not support 'Launch With'", 4000, "r")
		Process, Close, GameScript.exe
	}

	
	System := A_Args[2]
	Rom := A_Args[3]
}
Else {

	If (InStr(A_Args[2], "GameScript.exe")) {
		dedicatedDialog("GenericDialog.exe", "This title does not support 'Launch With'", 4000, "r")
		Process, Close, GameScript.exe
	}

	System := A_Args[1]
	Rom := A_Args[2]
}

systemObj := systemInfo(System)

If (!InStr(Rom, systemObj["romDir"])) {
	System := systemCheckFromRom(Rom)
	systemObj := systemInfo(System)
}

Game := nameFromPath(systemObj["nameIndex"], Rom)
GameVersions := gameVersions(Game)

If (A_Args[1] = "config") {
	tempArray := emuConfigScreen(System, GameVersions, objStringToArr(systemObj["controls"]))
	
	NewGame := tempArray[1]
	Controls := tempArray[2]
}
Else {
	NewGame := GameVersions[1]
	Controls := "Default"
}

UpdateLoadFlag("Now Loading...")

If (NewGame != Game) {
	GUINameSys := emuFromName(NewGame)
	If (GUINameSys) {
		System := GUINameSys
		systemObj := systemInfo(System)
	}
	
	Rom := gameReplace(Rom, systemObj["romDir"], Game, NewGame, systemObj["nameIndex"], System, systemObj["exts"])
}

If (Controls = "Default") {
	Controls := defaultOverride(System, Game, Rom, systemObj)
}
	
setSysControlImg(System, Controls)

systemObj["config"] := Controls
systemObj["game"] := Game
systemObj["rom"] := Rom
systemObj["system"] := System
emu := systemObj["emu"]

SetBatchLines %AVGBATCHLINES%

%emu%Launch(systemObj)

Process, Close, GameScript.exe