#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/helpers/xinputTools.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk
#Include C:/AutoHotkey/helpers/gamePID.ahk

#SingleInstance force
SetTitleMatchMode, 2
SetBatchLines, %AVGBATCHLINES% - 20

XInputController := XInput_Initialize()

MultiCount := 0
CheckActive := 0
NumControllers := GetNumXInput(XInputController)
NumControlLoop := 0
HomePlayer := -1

While (ProcessExist("MasterScript.exe") 
	&& !ProcessExist("ShutdownFlag.exe") && !ProcessExist("RestartFlag.exe")) {

	If (allJOY(XInputController, "X")  && (CheckActive = 0)) {
		HomePlayer := allJOY(XInputController, "X", "player")
		SetTimer, MultiTimer, 1000
			
		MultiCount += 1
		CheckActive := 1
			
		If (MultiCount >= 2) {
			If ((!gamePID() && !JackBoxExist() && !ProcessExist("LoadFlag.exe") && !ProcessExist("SettingScript.exe"))
			&& (ProcessExist("chrome.exe") || ProcessExist("BigBox.exe"))) {
				MultiTasking()
				Sleep, 2000
			}
			MultiCount := 0
			CheckActive := 0
			HomePlayer := -1
			
			SetTimer, MultiTimer, Off
		}
	}
		
	Else If ((CheckActive = 1) && !oneJOY(XInputController, "X", HomePlayer)) {
		CheckActive := 0
	}
	
	Else If (allJOY(XInputController, 7,8)) {
		SetTimer, CloseTimer, 4000
		
		While (allJOY(XInputController, 7,8)) {
			Sleep, 10
		}
		
		SetTimer, CloseTimer, Off
	}
	
	Else If (notJOY(XInputController, 7,8)) {	
		If (DeveloperMode(XInputController)) {
			SuspendScript("master.ahk")
			Sleep, 100
			
			dedicatedDialog("GenericDialog.exe", "MasterScript.exe Suspended", 5000, "r")

			While(!DeveloperMode(XInputController)) {
				Sleep, 250
				If (!ProcessExist("MasterScript.exe")) {
					Process, Close, ControllerScript.exe
				}
			}
			SuspendScript("master.ahk")
			
			dedicatedDialog("GenericDialog.exe", "MasterScript.exe Resumed", 5000, "r")
		}
	}
	
	Else If (notJOY(XInputController, 8,7)) {
		If (ForceRestart(XInputController)) {
			Run %comspec% /c "shutdown.exe /r /t 0"
		}
	}
	
	;check if error pop-up on screen
	If (ProcessExist("ErrorFlag.exe")) {
		While(ErrorMessageInput(XInputController))
		{}
		
		Process, Close, ErrorFlag.exe
	}
	
	If (NumControlLoop > 40) {
		If (NumControllers != GetNumXInput(XInputController)) {
			Joy2Key("reset")
			NumControllers := GetNumXInput(XInputController)
		}
		
		NumControlLoop := 0
	}
	Else {
		NumControlLoop += 1
	}
}

XInput_Terminate(XInputController)
Process, Close, ControllerScript.exe

MultiTimer:
	MultiCount := 0
	CheckActive := 0
	HomePlayer := -1

	SetTimer, MultiTimer, Off
	Return

CloseTimer:
	Process, Close, GenericDialog.exe
	Process, Close, LoadFlag.exe
	Sleep, 250
	
	KodiClose := 0
	Exist := gamePID()
	
	If (Exist = 0) {
		Exist := ProcessExist("The Jackbox Party Pack.exe")
	}
	If (Exist = 0) {
		Exist := ProcessExist("The Jackbox Party Pack 2.exe")
	}
	If (Exist = 0) {
		Exist := ProcessExist("The Jackbox Party Pack 3.exe")
	}
	
	If (Exist = 0) {
		If (ProcessExist("MultiFlag.exe")) {
			If ((Exist = 0) && NotBackgroundTask("chrome.exe")) {
				Exist := ProcessExist("chrome.exe")
			}
			If ((Exist = 0) && NotBackgroundTask("BigBox.exe")) {
				Exist := ProcessExist("BigBox.exe")
			}
		}
		Else {
			If (Exist = 0) {
				Exist := ProcessExist("chrome.exe")
			}
			If (Exist = 0) {
				Exist := ProcessExist("BigBox.exe")
			}
		}
	}
	
	If (Exist = 0) {
		Exist := ProcessExist("kodi.exe")
	}
	
	If ((Exist = 0) && ProcessExist("LoadFlag.exe")) {
		UpdateLoadFlag("close")
		Sleep, 2000
		
		If (Exist = 0) {
			Exist := ProcessExist("GameScript.exe")
		}
		If (Exist = 0) {
			Exist := ProcessExist("GameCustomScript.exe")
		}
		If (Exist = 0) {
			Exist := ProcessExist("JackboxScript.exe")
			KodiClose := 1
		}
		If (Exist = 0) {
			Exist := ProcessExist("ChromeScript.exe")
			KodiClose := 1
		}
		If (Exist = 0) {
			Exist := ProcessExist("BoxScript.exe")
			KodiClose := 1
		}
	}	
	
	If (Exist != 0) { 
		ExistName := nameFromPID(Exist)
		CloseString := "Force Exiting " . ExistName . "..."
		
		Run, taskkill /t /f /pid %Exist%,, Hide
		Sleep, 100
			
		Process, Close, MasterScript.exe

		dedicatedDialog("GenericDialog.exe", CloseString, 5000, "l")
		SetTimer, CloseTimer, Off
		Sleep, 1000
		
		If (KodiClose) {
			KodiLoad("close")
		}
		
		Sleep, 2000
	}

	SetTimer, CloseTimer, Off
	Return
	