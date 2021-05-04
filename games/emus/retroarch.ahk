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

devreoderConfig(Path, VisibleDevice) {
	configToWrite := "[visible]`r`n" . VisibleDevice
	
	file := FileOpen(Path . "devreorder.ini", "w")
	file.Write(configToWrite)
	file.Close()
}

retroarchLaunch(ConfigArray) {
	Name := "RetroArch"
	
	System := ConfigArray["system"]
	Rom := ConfigArray["rom"]
	Game := ConfigArray["game"]
	Config := ConfigArray["config"]
	Path := ConfigArray["emuDir"]
	EXE := ConfigArray["emuExe"] . ".exe"
	LNK := ConfigArray["emuExe"] . ".lnk"
	
	Core := ConfigArray["core"]
	
	; this needs some speed to not exponentiate loading times
	SetBatchLines -1
	
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\retroarchCore.txt", Path . "retroarch.cfg", "core", Core)
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\retroarchController.txt", Path . "retroarch.cfg"
	, "controller", Config)
	
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\retroarchCoreGame.txt", Path . "retroarch-core-options.cfg"
	, "game", Game)
	WriteToCFG("C:\AutoHotkey\files\cfg\emu\retroarchCoreController.txt", Path . "retroarch-core-options.cfg"
	, "controller", Config)
	
	; for some reason AVGBATCHLINES isnt recognized here? idk its hard coded now
	SetBatchLines 80
	
	Core := "cores\" . Core
	
	If InStr(Config, "Xbox Controllers") {
		devreoderConfig(Path, "Controller (Xbox One For Windows)")
	}
	Else If InStr(Config, "Xbox (Alternate)") {
		devreoderConfig(Path, "Controller (Xbox One For Windows)")
	}
	Else If InStr(Config, "GCN Adapter") {
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
		
		devreoderConfig(Path, "vJoy Device")
	}
	Else If InStr(Config, "USB N64") {
		UpdateLoadFlag("Please Attach USB N64 Controller(s)")
		Sleep, 100

		Device := WaitForDevice("findn64.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}
		
		devreoderConfig(Path, "Generic   USB  Joystick  ")
	}
	Else If InStr(Config, "USB SNES") {
		UpdateLoadFlag("Please Attach USB SNES Controller(s)")
		Sleep, 100

		Device := WaitForDevice("findsnes.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}
		
		devreoderConfig(Path, "USB,2-axis 8-button gamepad  ")
	}
	Else If InStr(Config, "USB Genesis") {
		UpdateLoadFlag("Please Attach USB Genesis Controller(s)")
		Sleep, 100

		Device := WaitForDevice("findgen.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}
		
		devreoderConfig(Path, "usb gamepad           ")
	}
	Else If InStr(Config, "PS1/PS2 Adapter") {
		UpdateLoadFlag("Please Attach PS1/PS2 Controller Adapter")
		Sleep, 100

		Device := WaitForDevice("findpsxadapter.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}
		
		devreoderConfig(Path, "Twin USB Joystick")
	}

	emuLoadScreen(Name)

	Run, "%Path%%LNK%" --config retroarch.cfg -L "%Core%" "%Rom%"

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



		