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

cemuLaunch(ConfigArray) {
	Name := "Cemu"
	
	System := ConfigArray["system"]
	Rom := ConfigArray["rom"]
	Game := ConfigArray["game"]
	Config := ConfigArray["config"]
	Path := ConfigArray["emuDir"]
	EXE := ConfigArray["emuExe"] . ".exe"
	LNK := ConfigArray["emuExe"] . ".lnk"
	
	; this needs some speed to not exponentiate loading times
	SetBatchLines -1
	
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\cemuController0.txt", Path . "controllerProfiles\controller0.txt"
	, "controller", Config)
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\cemuController1.txt", Path . "controllerProfiles\controller1.txt"
	, "controller", Config)
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\cemuController2.txt", Path . "controllerProfiles\controller2.txt"
	, "controller", Config)
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\cemuController3.txt", Path . "controllerProfiles\controller3.txt"
	, "controller", Config)
	
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\cemuGraphics.txt", Path . "settings.xml"
	, "game", Rom, "")
		
	; for some reason AVGBATCHLINES isnt recognized here? idk its hard coded now
	SetBatchLines 80

	If InStr(Config, "GCN Adapter") {
		UpdateLoadFlag("Please Attach GCN Controller Adapter")
		Sleep, 100

		Device := WaitForDevice("findgcnadapter.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}

		UpdateLoadFlag("Waiting for GCNUSBFeeder.exe...")
		Sleep, 1000
		GCNAdapter("open")
	}
	
	If InStr(Rom, "Super Smash Bros.") {
		Rom := systemInfo(System, "romDir") . "Super Smash Bros. for Wii U [AXFE0101]\code\cross_f.rpx"
	}

	emuLoadScreen(Name)

	Run, "%Path%%LNK%" "-f=0" "-g" "%Rom%"

	emuWaitLoop(Name)

	Run, "C:\AutoHotkey\bin\64\EmuLoadScript.exe" "C:\AutoHotkey\games\helpers\emuLoader.ahk" "%Name%"

	Process, Priority, %EXE%, A

	emuLoop()

	If InStr(Config, "GCN Adapter") {
		UpdateLoadFlag("Waiting for GCNUSBFeeder.exe...")
		Sleep, 500
		GCNAdapter("close")

		Sleep, 1000
		
		UpdateLoadFlag("close")
	}

	Return
}
	