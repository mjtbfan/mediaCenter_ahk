#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk

retroarch(FF) {
	WinActivate, RetroArch
	Sleep, 100
	Send {Space down}
	Sleep, 50
	Send {Space up}
	If (FF = 0) {
		return 1
	}
	Else {
		return 0
	}
}

pcsx2(FF) {
	WinActivate, GSdx
	Sleep, 100
	Send {F4 down}
	Sleep, 50
	Send {F4 up}
	If (FF = 0) {
		return 1
	}
	Else {
		return 0
	}
}

dolphin(FF) {
	WinActivate, JIT64
	Sleep, 100
	If (FF = 0) {
		Send {M down}
		return 1
	}
	Else {
		Send {M up}
		return 0
	}
}

ppsspp(FF) {
	WinActivate, PPSSPP
	Sleep, 100
	If (FF = 0) {
		Send {f down}
		return 1
	}
	Else {
		Send {f up}
		return 0
	}
}

citra(FF) {
	WinActivate, Citra
	Sleep, 100
	Send {Ctrl down}
	Sleep, 50
	Send {z down}
	Sleep, 80
	Send {z up}
	Sleep, 50
	Send {Ctrl up}
	If (FF = 0) {
		return 1
	}
	Else {
		return 0
	}
}

retroarchR(RR) {
	WinActivate, RetroArch
	Sleep, 100
	If (RR = 0) {
		Send {R down}
		return 1
	}
	Else {
		Send {R up}
		return 0
	}
}

ppssppR(RR) {
	WinActivate, PPSSPP
	Sleep, 100
	If (RR = 0) {
		Send {r down}
		return 1
	}
	Else {
		Send {r up}
		return 0
	}
}

allFF(FF) {
	If (ProcessExist("retroarch.exe") || ProcessExist("DeSmuMe.exe")) {
		Return retroarch(FF)
	}
	
	Else If (ProcessExist("Dolphin.exe")) {
		Return dolphin(FF)
	}
	
	Else If (ProcessExist("PCSX2.exe")) {
		Return pcsx2(FF)
	}
	
	Else If (ProcessExist("citra-qt.exe")) {
		Return citra(FF)
	}
	
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		Return ppsspp(FF)
	}
	
	Else {
		Return FF
	}
}

allRR(RR) {
	If (ProcessExist("retroarch.exe")) {
		Return retroarchR(RR)
	}
	
	;Else If (ProcessExist("PPSSPPWindows64.exe")) {
	;	Return ppssppR(RR)
	;}
	
	Else {
		Return RR
	}
}

EmuCanPause() {
	If (ProcessExist("retroarch.exe")) {
		Return 1
	}
	Else If (ProcessExist("Dolphin.exe")) {
		WinGet, DolphinPath, ProcessPath, ahk_exe Dolphin.exe
		
		If InStr(DolphinPath, "Slippi") {
			Return 0
		}
		Else {
			Return 1
		}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		Return 1
	}
	Else If (ProcessExist("pcsx2.exe")) {
		Return 1
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		Return 1
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		Return 1
	}
	Else If (ProcessExist("Cemu.exe")) {
		Return 0
	}
	Else If (ProcessExist("rpcs3.exe")) {
		Return 0
	}
	Else If (ProcessExist("yuzu.exe")) {
		Return 0
	}
	Else If (ProcessExist("Ryujinx.exe")) {
		Return 0
	}
	Else If (ProcessExist("xenia_canary.exe")) {
		Return 0
	}
}	

CloseEmu() {

	Process, Close, GameDialog.exe
	Process, Close, DSDialog.exe

	SetTitleMatchMode, 2
	Text := ""
	If (ProcessExist("retroarch.exe")) {
		WinActivate, RetroArch
		Send, {esc down}
		Sleep, 100
		Send {esc up}
		Text := "RetroArch.exe"
	}
	If (ProcessExist("Dolphin.exe")) {
		WinActivate, ahk_exe Dolphin.exe
		Send, {esc down}
		Sleep, 100
		Send {esc up}
		Text := "Dolphin.exe"
	}
	If (ProcessExist("Cemu.exe")) {
		WinClose, Cemu
		Text := "Cemu.exe"
	}
	If (ProcessExist("citra-qt.exe")) {
		WinClose, Citra
		Text := "citra-qt.exe"
	}
	If (ProcessExist("yuzu.exe")) {
		WinClose, yuzu
		Text := "yuzu.exe"
	}
	If (ProcessExist("Ryujinx.exe")) {
		WinClose, Ryujinx
		Text := "Ryujinx.exe"
	}
	If (ProcessExist("xenia_canary.exe")) {
		WinClose, xenia
		Text := "xenia-canary.exe"
	}
	If (ProcessExist("rpcs3.exe")) {
		WinClose, RPCS3
		Text := "RCPS3.exe"
	}
	If (ProcessExist("pcsx2.exe")) {
		Process, Close, pcsx2.exe
		Text := "pcsx2.exe"
	}
	If (ProcessExist("PPSSPPWindows64.exe")) {
		WinClose, PPSSPP
		Text := "PPSSPPWindows64.exe"
	}
	If (ProcessExist("DeSmuME.exe")) {
		WinClose, ahk_exe DeSmuME.exe
		Text := "DeSmuME.exe"
	}
	
	MouseMove, 9999, 9999, 0
	ResetLoadingScreen(1)

	UpdateLoadFlag("Exiting " Text "...")
	Exist := emulatorPID()
	ExistCount := 0
	While(Exist != 0) {
		ExistCount += 1
		Exist := emulatorPID()
		If (ExistCount > 40 && Exist != 0) {
			Run, taskkill /f /pid %Exist%,, Hide
			Sleep, 1000
		}
		Sleep, 250
	}
	UpdateLoadFlag("close")
}

PauseEmu() {

	If (ProcessExist("retroarch.exe")) {
		WinActivate, RetroArch
		Send {p down}
		Sleep, 80
		Send {p up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
		WinActivate, JIT64
		While (checkFullscreen("JIT64")) {
		  Send {f down}
		  Sleep, 50
		  Send {f up}
		  Sleep, 150
		}
		Send {F10 down}
		Sleep, 80
		Send {F10 up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		WinActivate, Citra
		While (checkFullscreen("Citra")) {
		  Send {F11 down}
		  Sleep, 50
		  Send {F11 up}
		  Sleep, 150
		}
		Send {F4 down}
		Sleep, 80
		Send {F4 up}
	}
	Else If (ProcessExist("pcsx2.exe")) {
		WinActivate, Slot:
		While (!checkFullscreen("Slot:")) {
			Send {Alt down}
			Sleep, 100
			Send {Enter}
			Sleep, 100
			Send {Alt up}
			Sleep, 150
		}
		WinClose, Slot:
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		WinActivate, PPSSPP
		While (checkFullscreen("PPSSPP")) {
			Sleep, 50
			Send {Alt down}
			Sleep, 50
			Send {Enter}
			Sleep, 50
			Send {Alt up}
			Sleep, 150
		}
		
		Send {p down}
		Sleep, 80
		Send {p up}
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		WinActivate, ahk_exe DeSmuME.exe
		While (checkFullscreen("ahk_exe DeSmuME.exe")) {
			Send {Alt down}
			Sleep, 50
			Send {Enter}
			Sleep, 50
			Send {Alt up}
			Sleep, 150
		}
		Send {p down}
		Sleep, 80
		Send {p up}
	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("yuzu.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
}

ResumeEmu() {

	If (ProcessExist("retroarch.exe")) {
		WinActivate, RetroArch
		Send {p down}
		Sleep, 80
		Send {p up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
		WinActivate, JIT64
		While (!checkFullscreen("JIT64")) {
		  Send {f down}
		  Sleep, 50
		  Send {f up}
		  Sleep, 150
		}
		Send {F10 down}
		Sleep, 80
		Send {F10 up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		WinActivate, Citra
		While (!checkFullscreen("Citra")) {
		  Send {F11 down}
		  Sleep, 50
		  Send {F11 up}
		  Sleep, 150
		}
		Send {F4 down}
		Sleep, 80
		Send {F4 up}
	}
	Else If (ProcessExist("pcsx2.exe")) {
		WinActivate, PCSX2
		SetKeyDelay, 100, 50
		Send {Alt}
		Send {Enter}
		Send {Down}
		Send {Enter}
		Sleep, 400
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		WinActivate, PPSSPP
		Send {esc down}
		Sleep, 80
		Send {esc up}
		Sleep, 300
		While (!checkFullscreen("PPSSPP")) {
			Sleep, 50
			Send {Alt down}
			Sleep, 50
			Send {Enter}
			Sleep, 50
			Send {Alt up}
			Sleep, 150
		}
		
		Sleep, 250
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		WinActivate, ahk_exe DeSmuME.exe
		While (!checkFullscreen("ahk_exe DeSmuME.exe")) {
			Send {Alt down}
			Sleep, 50
			Send {Enter}
			Sleep, 50
			Send {Alt up}
			Sleep, 150
		}
		Send {p down}
		Sleep, 80
		Send {p up}
	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("yuzu.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
}

ResetEmu() {

	If (ProcessExist("retroarch.exe")) {
		Send {h down}
		Sleep 80
		Send {h up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
		Send {r down}
		Sleep 80
		Send {r up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		Send {F6 down}
		Sleep 80
		Send {F6 up}
	}
	Else If (ProcessExist("pcsx2.exe")) {
		WinActivate, PCSX2
		SetKeyDelay, 50, 50
		Send {Alt}
		Send {Enter}
		Sleep, 50
		Send {Enter}
		Sleep, 100
		Send {Down}
		Send {Enter}
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		Send {Ctrl down}
		Sleep, 50
		Send {b down}
		Sleep, 80
		Send {b up}
		Sleep, 50
		Send {Ctrl up}
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		Send {m down}
		Sleep, 80
		Send {m up}
	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("yuzu.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
}

SaveEmu() {

	If (ProcessExist("retroarch.exe")) {
		Send {F2 down}
		Sleep 80
		Send {F2 up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
		Send {Shift down}
		Sleep 50
		Send {F1 down}
		Sleep 80
		Send {F1 up}
		Sleep 50
		Send {Shift up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		Send {c down}
		Sleep 80
		Send {c up}
	}
	Else If (ProcessExist("pcsx2.exe")) {
		Send {F1 down}
		Sleep, 100
		Send {F1 up}
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		Send {k down}
		Sleep, 80
		Send {k up}
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		Send {Shift down}
		Sleep 50
		Send {F1 down}
		Sleep 80
		Send {F1 up}
		Sleep 50
		Send {Shift up}
	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("yuzu.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
}

LoadEmu() {

	If (ProcessExist("retroarch.exe")) {
		Send {F4 down}
		Sleep 80
		Send {F4 up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
		Send {F1 down}
		Sleep 80
		Send {F1 up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		Send {v down}
		Sleep 80
		Send {v up}
	}
	Else If (ProcessExist("pcsx2.exe")) {
		Send {F3 down}
		Sleep, 100
		Send {F3 up}
	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {
		Send {l down}
		Sleep, 80
		Send {l up}
	}
	Else If (ProcessExist("DeSmuME.exe")) {
		Send {F1 down}
		Sleep 80
		Send {F1 up}
	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("yuzu.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
}

SwapDiscEmu() {

	If (ProcessExist("retroarch.exe")) {
		Send {d down}
		Sleep 80
		Send {d up}
	}
	Else If (ProcessExist("Dolphin.exe")) {
	}
	Else If (ProcessExist("pcsx2.exe")) {

	}
	Else If (ProcessExist("PPSSPPWindows64.exe")) {

	}
	Else If (ProcessExist("Cemu.exe")) {

	}
	Else If (ProcessExist("rpcs3.exe")) {

	}
	Else If (ProcessExist("xenia_canary.exe")) {

	}
	Else If (ProcessExist("DeSmuME.exe")) {
		Send {End down}
		Sleep 80
		Send {End up}
	}
	Else If (ProcessExist("citra-qt.exe")) {
		Send {F10 down}
		Sleep 80
		Send {F10 up}
	}
}

clustertruck() {
	WinWait, Configuration
	Sleep, 100
	WinActivate, Configuration
	Sleep, 100
	Send {Enter}
}

gtafour() {
	WinWait, Play Grand
	Sleep, 100
	WinActivate, Play Grand
	Sleep, 100
	Send {Enter}
}

hitman() {
	WinWait, HIT
	Sleep, 100
	WinActivate, HIT
	Sleep, 100
	Send {Enter}
}

superhot(version) {
	CoordMode, Mouse
	WinWait, SUPERHOT LAUNCHER
	Sleep, 100
	WinActivate, SUPERHOT LAUNCHER
	Sleep, 1000
	If (version = "steam://rungameid/322500") {
		MouseMove, 590, 450, 0
	}
	Else If (version = "steam://rungameid/690040") {
		MouseMove, 950, 450, 0
	}
	Sleep, 100
	MouseClick, Left
	Sleep, 1500
	MouseMove, 800, 830, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

saintsrow3() {
	CoordMode, Mouse
	WinWait, The Launcher
	Sleep, 100
	WinActivate, The Launcher
	MouseMove, 800, 500, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

falloutold() {
	CoordMode, Mouse
	While (!ProcessExist("FalloutLauncher.exe") && !ProcessExist("FalloutNVLauncher.exe"))
	{}
	Sleep, 500
	WinWait, Fallout
	Sleep, 100
	WinActivate, Fallout
	MouseMove, 1275, 450, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

fallout4() {
	CoordMode, Mouse
	While (!ProcessExist("Fallout4Launcher.exe"))
	{}
	Sleep, 500
	WinWait, Fallout
	Sleep, 100
	WinActivate, Fallout
	MouseMove, 1315, 385, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

skyrim() {
	CoordMode, Mouse
	While (!ProcessExist("SkyrimSELauncher.exe"))
	{}
	Sleep, 500
	WinWait, Skyrim
	Sleep, 100
	WinActivate, Skyrim
	MouseMove, 1315, 385, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

oblivion() {
	CoordMode, Mouse
	While (!ProcessExist("OblivionLauncher.exe"))
	{}
	Sleep, 500
	WinWait, Oblivion
	Sleep, 100
	WinActivate, Oblivion
	MouseMove, 1055, 420, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

batman() {
	CoordMode, Mouse
	WinWait, Launcher
	Sleep, 100
	WinActivate, Launcher
	MouseMove, 960, 620, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

witcher2() {
	CoordMode, Mouse
	WinWait, Launcher
	Sleep, 100
	WinActivate, Launcher
	MouseMove, 990, 648, 0
	Sleep, 100
	MouseClick, Left
	Sleep, 100
	MouseMove, 1920, 1080, 0
}

checkWinGames(WinLaunch) {
	If (WinLaunch = "steam://rungameid/397950") {
		clustertruck()
		Return 0
	}
	Else If ((WinLaunch = "steam://rungameid/322500") || (WinLaunch = "steam://rungameid/690040")) {
		superhot(WinLaunch)
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/55230") {
		saintsrow3()
		Return 0
	}
	Else If ((WinLaunch = "steam://rungameid/22370") || (WinLaunch = "steam://rungameid/22380")) {
		falloutold()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/377160") {
		fallout4()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/489830") {
		skyrim()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/22330") {
		oblivion()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/35140") {
		batman()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/236870") {
		hitman()
		Return 0
	}
	Else If (WinLaunch = "steam://rungameid/20920") {
		witcher2()
		Return 0
	}
}