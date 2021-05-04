#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/gui/loadingGui.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk

#SingleInstance force
SetTitleMatchMode, 2

Process, Priority,, L

; ----- MASTER FUNCTIONS -----
checkLoadScreen() {
	global quiet

	If (ProcessExist("LoadFlag.exe")) {
		SetBatchLines -1
		
		FileRead, loadingText, C:/AutoHotkey/files/loading.txt
		currentText := loadingText
		updateLoadScreen(loadingText)
		
		While(ProcessExist("LoadFlag.exe")) {
		
			FileRead, loadingText, C:/AutoHotkey/files/loading.txt
			If (currentText != loadingText) {
				updateLoadScreen(loadingText)
				currentText := loadingText
			}
			
			If (quiet = 1) {
				showLoadScreen("")
				quiet := 0
			}
			Else If (!WinShown("master.ahk")) {
				Reload
			}
			
			While (WinShown("Game Startup")) {
				WinActivate, Game Startup
			}
			
			If (SteamShown()) {
				CleanActivate("Updating ")
				SteamEULAHandler()
				SteamUpdateHandler()
			}
			Else If (ErrorMessage(1))
			{}
			Else If (ProcessExist("GameScript.exe") && checkGameLauncher()) 
			{}
			Else If (ProcessExist("MinFlag.exe"))
			{}
			Else {
				WinActivate, master.ahk
			}
		}
		
		updateLoadScreen("")
	}
}

PowerOptions(type) {
	Sleep, 1000
	SetKeyDelay, 50, 50
	
	WinActivate, Kodi
	Send \
	Sleep, 100
	
	WinActivate, master.ahk
	WinGet, Active, ProcessName, A
	While (!InStr(Active, "MasterScript.exe")) {
		Sleep, 250
		WinActivate, master.ahk
		WinGet, Active, ProcessName, A
	}
	
	ContWaitCount := 0
	While (ProcessExist("ControllerScript.exe") && ContWaitCount < 25) {
		ContWaitCount += 1
		Sleep, 500
	}
	
	CloseAllScripts()
	multiName.Close()
	
	If (ProcessExist("MultiFlag.exe")) {
		SetTitleMatchMode, 2
		CloseCount := 0
		
		CloseMultiTasking(0)
		
		If (ProcessExist("chrome.exe")) {
			updateLoadScreen("Exiting chrome.exe...")
			WinClose, Chrome
			
			While(ProcessExist("chrome.exe")) {
				CloseCount += 1
				
				If (CloseCount > 40) {
					Process, Close, chrome.exe
				}
				
				Sleep, 250
			}
		}
		
		If (ProcessExist("BigBox.exe")) {
			updateLoadScreen("Exiting BigBox.exe...")
			WinClose, Box
			
			While(ProcessExist("BigBox.exe")) {
				CloseCount += 1
				
				If (CloseCount > 60) {
					Process, Close, BigBox.exe
				}
				
				Sleep, 250
			}
		}
		Sleep, 1000
	}
	
	updateLoadScreen("Exiting kodi.exe...")
	Sleep, 250
	CoordMode, Mouse
	MouseMove, 1920, 1080
	MouseClick, Left
	Sleep, 8000
	ControlSend,, ^{End}, Kodi
	Sleep, 250
	updateLoadScreen("Exiting Steam.exe...")
	Steam("close")
	updateLoadScreen("Exiting JoyToKey.exe...")
	Joy2Key("close")
	Sleep, 250
	
	If (type = "shutdown") {
		updateLoadScreen("Shutting Down...")
	}
	Else If (type = "restart") {
		updateLoadScreen("Restarting...")
	}
	
	Count := 0
	While(ProcessExist("kodi.exe")) {
		Sleep, 500
		
		Count += 1
		If (Count > 60) {
			Process, Close, kodi.exe
		}
	}
	
	Process, Close, LoopScript.exe
	Sleep, 100
	
	If (type = "shutdown") {
		DllCall("PowrProf\SetSuspendState", "int", 1, "int", 1, "int", 1)
		updateLoadScreen("")
		Sleep, 2000
		
		Run, "C:\AutoHotkey\bin\64\MasterScript.exe" "C:\AutoHotkey\boot.ahk"
		
		Process, Close, MasterScript.exe
	}
	Else If (type = "restart") {
		Shutdown, 2
	}
}

; ----- MASTER MAIN -----

initializeGamePID()
Sleep, 250
#Include C:/AutoHotkey/helpers/gamePID.ahk

buildLoadScreen()
If InStr(A_Args[1], "q") {
	quiet := 1
}
Else {
	showLoadScreen("")
	quiet := 0
}

WinGet, OldWinPID, PID, A
crashedCount := 0
loadReset := 0
minCount := 0
multiName := FileOpen("C:/AutoHotkey/files/multi.txt", "r")

soundMute := "Off"
soundVol := -1
soundCheck := 0

Loop {	
	SetBatchLines 2
	checkLoadScreen()
	
	GameExist := gamePID()
	GameName := nameFromPID(GameExist)
	
	; check for sibling scripts
	If (!ProcessExist("ControllerScript.exe")) {
		Run, "C:\AutoHotkey\bin\64\ControllerScript.exe" "C:\AutoHotkey\controller.ahk",, Hide
	}
	
	If (!ProcessExist("LoopScript.exe")) {
		Run, "C:\AutoHotkey\bin\64\LoopScript.exe" "C:\AutoHotkey\looper.ahk"
	}
		
	;Close MultiTasking
	If (ProcessExist("MultiFlag.exe") && !ScriptExist()
	&& !ProcessExist("chrome.exe") && !ProcessExist("BigBox.exe")) {
		CloseMultiTasking(1)
	}
	
	; if error message
	If (ErrorMessage(0)) {
		If (!ProcessExist("ErrorFlag.exe")) {
			Run, "C:\AutoHotkey\bin\64\flags\ErrorFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		}
	}
	
	; Firewall?
	Else If (WinShown("Windows Security Alert")) {
		WinActivate, Windows Security Alert
		Sleep, 50
		Send, {Enter}
	}
	
	; Windows Settings
	While (ProcessExist("SettingScript.exe")) {
		Sleep, 100
	}
	
	checkLoadScreen()

	If (((!ProcessExist("MultiFlag.exe") && !ProcessExist("chrome.exe") && !ProcessExist("BigBox.exe")) 
	|| (ProcessExist("MultiFlag.exe") && !InStr(FileReadSeek(multiName), "kodi.exe") 
	&& !(ProcessExist("chrome.exe") && ProcessExist("BigBox.exe")))) 
	&& !GameExist && !JackBoxExist()) {
		If (ProcessExist("kodi.exe") && !ProcessExist("LoadFlag.exe")) {
			If (!ScriptExist()) {
				CleanActivate("Kodi")
			}
		}
		Else {
			updateLoadScreen("Waiting for Kodi.exe...")
			WinActivate, master.ahk
			While(!ProcessExist("kodi.exe")) {
				Run, "C:\Kodi\kodi.lnk"
				Sleep, 5000
			}
			WinWait, Kodi
			updateLoadScreen("")
			CleanActivate("Kodi")
		}
		
	}
	Else {
		checkLoadScreen()
	
		minCount += 1
	
		; Check for nonKodi Apps
		If (ProcessExist("BigBox.exe") || GameExist) {
		
			If (GameExist && !ProcessExist("GameScript.exe")) {
				Run, "C:\AutoHotkey\bin\64\GameScript.exe" "C:\AutoHotkey\games\gameBackup.ahk",, Hide
			}
			
			If (GameExist && !WinShown("Pause") && !DialogExist()) {
				GameTitle := gameNameClean(GameExist)
				CleanActivate("ahk_pid" GameExist)
			}
			
			Else If (DialogExist()) {
				WinActivate, Dialog.ahk
			}
			
			Else If (WinShown("Pause Screen")) {
				Sleep, 2000
				WinActivate, Pause
			}
			
			Else If (WinShown("configurator.ahk")) {
				CleanActivate("ahk_exe GameScript.exe")
			}
			
			Else If ((!ProcessExist("MultiFlag.exe")
			|| (ProcessExist("MultiFlag.exe") && !InStr(FileReadSeek(multiName), "BigBox.exe"))) && !ProcessExist("GameScript.exe")) {
				CleanActivate("Big Box")
			}
			
			If ((!ProcessExist("MultiFlag.exe")
			|| (ProcessExist("MultiFlag.exe") && !InStr(FileReadSeek(multiName), "BigBox.exe"))) && !ProcessExist("BoxScript.exe")) {
				If (!ProcessExist("KodiCloseScript.exe")) {
					Run, "C:\AutoHotkey\bin\64\BoxScript.exe" "C:\AutoHotkey\programs\bigbox.ahk"
				}
			}
		}
		
		If ((!ProcessExist("MultiFlag.exe")
		|| (ProcessExist("MultiFlag.exe") && !InStr(FileReadSeek(multiName), "chrome.exe"))) && ProcessExist("chrome.exe")) {
			If (ProcessExist("osk.exe")) {
				If (!WinActive("On-Screen Keyboard")) {
					CleanActivate(" - Google Chrome")
				}
			}
			Else {
				CleanActivate(" - Google Chrome")
			}
			
			;Check script running
			If (!ProcessExist("ChromeScript.exe")) {
				If (!ProcessExist("KodiCloseScript.exe")) {
					Run, "C:\AutoHotkey\bin\64\ChromeScript.exe" "C:\AutoHotkey\programs\chrome.ahk"
				}
			}
		}
		Else If (JackBoxExist()) {
			If (!SteamShown()) {
				CleanActivate("Jackbox")
			}
			
			If (!ProcessExist("JackboxScript.exe")) {
				If (!ProcessExist("KodiCloseScript.exe")) {
					Run, "C:\AutoHotkey\bin\64\JackboxScript.exe" "C:\AutoHotkey\programs\jackbox.ahk"
				}
			}
		} 
	}
	
	; sound check
	If (soundCheck < 20) {
		soundCheck += 1
	}
	Else {
		SoundGet, soundVol
		SoundGet, soundMute,,MUTE

		If (soundVol != 100 || soundMute = "On") {
			SoundSet, 0,,MUTE
			SoundSet, 100
		}

		soundCheck := 0
	}
	
	; shutdown
	If (ProcessExist("ShutdownFlag.exe")) {
		PowerOptions("shutdown")
	}
	Else If (ProcessExist("RestartFlag.exe")) {
		PowerOptions("restart")
	}

}

Process, Close, MasterScript.exe
