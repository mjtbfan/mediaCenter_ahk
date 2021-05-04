#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force

#Include C:/AutoHotkey/helpers/tools.ahk

SetTitleMatchMode, 2

Name := A_Args[1]

If (Name = "RetroArch") {
	WinGetTitle, RetroReal, RetroArch
	While(RetroReal = "RetroArch") {
		WinGetTitle, RetroReal, RetroArch
		Sleep, 100
	}
}

If (Name = "RPCS3") {
	While (!WinExist("Compiling") && !WinExist("Building")) {
		Sleep 100 
		
		If (WinShown("FPS:")) {
			Break
		}
	}
}

If (WinShown("Wiimote")) {
	WinGet, GamePID, ProcessName, Wiimote
}
Else {
	WinGet, GamePID, ProcessName, %Name%
}

UpdateLoadFlag("close")

; AFTER LOADING

If (Name = "DeSmuME") {
	While (!checkFullscreen("DeSmuME")) {
		WinActivate, DeSmuME
		Sleep, 50
		Send !{Enter}
		Sleep, 750
	}
	
	CoordMode, Mouse
	MouseMove, 1440, 540
}

If (Name = "Citra") {
	While (!checkFullscreen("Citra")) {
	  Send {F11 down}
	  Sleep, 50
	  Send {F11 up}
	  Sleep, 150
	}
	CoordMode, Mouse
	MouseMove, 1500, 540
}

If (Name = "yuzu") {
	While (!checkFullscreen("yuzu")) {
	  Send {F11 down}
	  Sleep, 50
	  Send {F11 up}
	  Sleep, 150
	}
}

If (Name = "xenia-canary") {
	While (!checkFullscreen("xenia-canary")) {
	  Send {F11 down}
	  Sleep, 50
	  Send {F11 up}
	  Sleep, 150
	}
}

If (Name = "PPSSPP") {
	While (!checkFullscreen("PPSSPP")) {
		Sleep, 50
		Send {Alt down}
		Sleep, 50
		Send {Enter}
		Sleep, 50
		Send {Alt up}
		Sleep, 150
	}
}

If (Name = "Cemu") {
	WinActivate, Cemu
	WinMaximize, Cemu
	SplashImage, 1:C:\Assets\black.png, b h55 w1920 y0
	SplashImage, 2:C:\Assets\black.png, b h35 w1920 y1045
}

If (Name = "EE:") {
	WinWait, EE:
	WinActivate, EE:
	WinMaximize, EE:
	SplashImage, 1:C:\Assets\black.png, b h25 w1920 y0
}

If ((Name = "Dolphin") || (Name = "DolphinOnline")) {
	If (WinShown("Operation in progress")) {
		WinMaximize, Dolphin
		WinMove, Operation in,, 800, 440
	}
	Else {
		WinActivate, ahk_exe Dolphin.exe
		WinMaximize, ahk_exe Dolphin.exe
	}
	
	SplashImage, 1:C:\Assets\black.png, b h25 w1920 y0
}

If (Name = "RPCS3") {
	If (WinExist("FPS:")) {
		WinActivate, FPS:
	}
	Else If (WinExist("Building")) {
		WinActivate, master.ahk
		Sleep, 50
		WinActivate, Building
	}
	Else If (WinExist("Compiling")) {
		WinActivate, master.ahk
		Sleep, 50
		WinActivate, Compiling
	}
}

Count := 0
While(ProcessExist(GamePID)) {
	Sleep, 100
	Count += 1
	If (Count > 20) {
		Break
	}
}
If ((Name = "Cemu") || (Name = "RPCS3") || (Name = "DolphinOnline") 
|| (Name = "yuzu") || (Name = "xenia-canary") || (Name = "Ryujinx")) {
	Run, "C:\AutoHotkey\bin\64\dialogs\GameDialog.exe" "C:\AutoHotkey\gui\closeDialog.ahk" "x" %GamePID%
}
Else If (Name = "DeSmuME" || Name = "Citra") {
	Run, "C:\AutoHotkey\bin\64\dialogs\DSDialog.exe" "C:\AutoHotkey\gui\closeDialog.ahk" "g" %GamePID%
}
Else {
	Run, "C:\AutoHotkey\bin\64\dialogs\GameDialog.exe" "C:\AutoHotkey\gui\closeDialog.ahk" "g" %GamePID%
}

If (Name = "Cemu") {
	While (ProcessExist("GameDialog.exe"))
	{}
	
	SplashImage, 1:Off
	SplashImage, 2:Off
	
	SetKeyDelay, 50, 50
	While (!checkFullscreen("Cemu")) {
		WinActivate, Cemu
		Sleep, 250
		Send, !{Enter}
		Sleep, 750
	}
}

If (Name = "EE:") {
	While (ProcessExist("GameDialog.exe"))
	{}
	
	SplashImage, 1:Off
	
	While (!checkFullscreen("EE:")) {
		WinActivate, EE:
		Sleep, 250
		Send {Alt down}
		Sleep, 100
		Send {Enter}
		Sleep, 100
		Send {Alt up}
		Sleep, 250
	}
} 

If ((Name = "Dolphin") || (Name = "DolphinOnline")) {
	While (ProcessExist("GameDialog.exe"))
	{}
	
	SplashImage, 1:Off
	

	While (!checkFullscreen("ahk_exe Dolphin.exe")) {
		WinActivate, ahk_exe Dolphin.exe
		Sleep, 250
		Send {f down}
		Sleep, 100
		Send {f up}
		Sleep, 750
	}
}

Process, Close, EmuLoadScript.exe