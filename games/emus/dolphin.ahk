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

dolphinLaunch(ConfigArray) {
	Name := "Dolphin"
	
	System := ConfigArray["system"]
	Rom := ConfigArray["rom"]
	Game := ConfigArray["game"]
	Config := ConfigArray["config"]
	Path := ConfigArray["emuDir"]
	EXE := ConfigArray["emuExe"] . ".exe"
	LNK := ConfigArray["emuExe"] . ".lnk"
	
	sysAliases := systemAliases(System)
	Loop % sysAliases.MaxIndex() {
		If (sysAliases[A_Index] = "Wii") {
			System := "Wii"
			Break
		}
		Else If (sysAliases[A_Index] = "GameCube") {
			System := "GameCube"
			Break
		}
	}

	If InStr(Rom, "Super Smash Bros. Slippi Online") {
		tempArray := systemInfo(System, "romDir, nameIndex, exts")

		Rom := gameReplace(Rom, tempArray["romDir"], Game, "Super Smash Bros. Melee.iso"
		, tempArray["nameIndex"], System, tempArray["exts"])
		Config := "GCN Adapter"
		Path := "C:\Emulators\Default\DolphinSlippi\"
	}
	Else {
		WriteToCFG("C:\AutoHotkey\files\cfg\emu\dolphinDolphin.txt"
		, Path . "User\Config\Dolphin.ini", "controller", Config)
		
		WriteToCFG("C:\AutoHotkey\files\cfg\emu\dolphinWiimoteNew.txt"
		, Path . "User\Config\WiimoteNew.ini", "controller", Config)
	}
	
	If InStr(Config, "GCN Adapter") {
		UpdateLoadFlag("Please Attach GCN Controller Adapter")
		Sleep, 100

		Device := WaitForDevice("findgcnadapter.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}
	}
	Else If InStr(Config, "Wiimotes") {
		UpdateLoadFlag("Please Attach WiiBar")
		Sleep, 100

		Device := WaitForDevice("findwiibar.lnk")

		If (Device = 1) {
			UpdateLoadFlag("close")
			ExitApp
		}

		UpdateLoadFlag("Waiting for Wiimotes...")
		Sleep, 100

		Run, "C:\AutoHotkey\files\devices\enablewiimotes.lnk"

		Sleep, 2000
	}

	emuLoadScreen(Name)

	Run, "%Path%%LNK%" "-b" "-e" "%Rom%"

	emuWaitLoop(Name)
	
	If InStr(Path, "Slippi") {
		Name := "DolphinOnline"
	}
	
	Run, "C:\AutoHotkey\bin\64\EmuLoadScript.exe" "C:\AutoHotkey\games\helpers\emuLoader.ahk" "%Name%"

	Process, Priority, %EXE%, A

	emuLoop()

	If InStr(Config, "Wiimotes") {
		UpdateLoadFlag("Waiting for Wiimotes...")
		Sleep, 100

		Run, "C:\AutoHotkey\files\devices\disablewiimotes.lnk"

		Sleep, 2000
		
		UpdateLoadFlag("close")
	}
	
	Return
}

	