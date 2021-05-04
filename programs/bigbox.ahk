#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk

#SingleInstance force
SetTitleMatchMode, 2
DetectHiddenWindows, Off

SetBatchLines %AVGBATCHLINES%
Process, Priority,, L

If (!SteamShown() && !gamePID() && !ProcessExist("BigBox.exe")) {
	KodiLoad("open", "Waiting for Steam.exe...")
	Run, "C:\Launchbox\BigBox.exe"
	Steam("clean")
	Joy2Key("dirty")
	UpdateLoadFlag("Waiting for BigBox.exe...")
	DetectHiddenWindows, Off
	Sleep, 1000
}

Else {
	Steam("clean")
}

If (ProcessExist("MultiFlag.exe") && !ProcessExist("chrome.exe")
&& InStr(A_Args[1], "l")) {
	file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
	file.Write("kodi.exe")
	file.Close()
}

WinWait, Big Box
UpdateLoadFlag("close")
Sleep, 1000

ExitCheck := 1

While (WinShown("Big Box")) {
	Sleep, 1000
	Joy2Key("clean")
}

If (gamePID()) {

	While (gamePID()) {
		Sleep, 1000
	}

	If (ProcessExist("GCNUSBFeeder.exe")) {
		WinClose, Adapter
		Sleep, 2000
		While (ProcessExist("GCNUSBFeeder.exe")) {
			Process, Close, GCNUSBFeeder.exe
			Sleep, 1000
		}
	}
	
	Run, "C:\Device Disabler\disablewiimotes.lnk"
}

Process, Close, GameScript.exe
Process, Close, ImgControlScript.exe

Sleep, 250
KodiAppClose("b")

Process, Close, BoxScript.exe

5::
	While (GetKeyState("5")) {
		Sleep, 50
		
		If GetKeyState("1") {
			If (WinActive("Big Box") && !gamePID()) {
				Send, x
				Sleep, 350
			}
		}
		Else {
			If (WinActive("Big Box") && !gamePID()) {
				Send, s
				Sleep, 350
			}
		}
	}
	
	Return

6::
	While (GetKeyState("6")) {
		Sleep, 50
		
		If GetKeyState("2") {
			If (WinActive("Big Box") && !gamePID()) {
				Send, x
				Sleep, 350
			}
		}
		Else {
			If (WinActive("Big Box") && !gamePID()) {
				Send, s
				Sleep, 350
			}
		}
	}
	
	Return

7::
	While (GetKeyState("7")) {
		Sleep, 50
		
		If GetKeyState("3") {
			If (WinActive("Big Box") && !gamePID()) {
				Send, x
				Sleep, 350
			}
		}
		Else {
			If (WinActive("Big Box") && !gamePID()) {
				Send, s
				Sleep, 350
			}
		}
	}
	
	Return

8::
	While (GetKeyState("8")) {
		Sleep, 50
		
		If GetKeyState("4") {
			If (WinActive("Big Box") && !gamePID()) {
				Send, x
				Sleep, 350
			}
		}
		Else {
			If (WinActive("Big Box") && !gamePID()) {
				Send, s
				Sleep, 350
			}
		}
	}
	
	Return


