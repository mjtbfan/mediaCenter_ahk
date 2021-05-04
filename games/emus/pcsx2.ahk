#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/games/helpers/gameLoop.ahk
#Include C:/AutoHotkey/games/helpers/emuConfig.ahk
#Include C:/AutoHotkey/games/helpers/gameLoadScreen.ahk

pcsx2INIs(Game) {
	FileRead, inis, C:\AutoHotkey\files\cfg\emu\pcsx2.txt
	
	iniLines := StrSplit(inis, "`r`n")
	
	cfgPath := ""
	Loop % iniLines.MaxIndex() {
		currLine := Trim(iniLines[A_Index], " `r`n")
		
		If (!cfgPath && RegExMatch(currLine, "U)^cfgPath *= *.*")) {
			cfgPath := Trim(RegExReplace(currLine, "U)^cfgPath *= *"), " `r`n")
		}
		Else If (RegExMatch(currLine, "U)^\[" . regexClean(Game) . "\] *")) {
			gameINI := cfgPath . Trim(RegExReplace(currLine, "U)^\[" . regexClean(Game) . "\] *"), " `r`n")
			Return gameINI
		}
	}
}

pcsx2Launch(ConfigArray) {
	Name := "EE:"
	
	System := ConfigArray["system"]
	Rom := ConfigArray["rom"]
	Game := ConfigArray["game"]
	Config := ConfigArray["config"]
	Path := ConfigArray["emuDir"]
	EXE := ConfigArray["emuExe"] . ".exe"
	LNK := ConfigArray["emuExe"] . ".lnk"

	INI := pcsx2INIs(Game)

	emuLoadScreen(Name)

	Run, "%Path%%LNK%" "--fullboot" "--cfgpath=%INI%" "%Rom%"

	emuWaitLoop(Name)

	Run, "C:\AutoHotkey\bin\64\EmuLoadScript.exe" "C:\AutoHotkey\games\helpers\emuLoader.ahk" "%Name%"

	Process, Priority, %EXE%, A

	emuLoop()

	Return
}
	