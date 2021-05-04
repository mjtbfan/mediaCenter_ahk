#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:/AutoHotkey/bin/XInput.ahk
#Include C:/AutoHotkey/helpers/tools.ahk

xInputTranslation(xLib, ControlNum, Button) {
	State := XInput_GetState(ControlNum, xLib)
	
	If (Button = "POV") {	
	
		;POV
		If ((State.wButtons & 0x0001)) {
			Return 0
		}
		Else If ((State.wButtons & 0x0002)) {
			Return 18000
		}
		Else If ((State.wButtons & 0x0004)) {
			Return 27000
		}
		Else If ((State.wButtons & 0x0008)) {
			Return 9000
		}
		Else {
			Return -1
		}
	}
	Else {
	
		; Buttons
		If ((Button = 1) && (State.wButtons & 0x1000)) {
			Return 1
		}
		Else If ((Button = 2) && (State.wButtons & 0x2000)) {
			Return 1
		}
		Else If ((Button = 3) && (State.wButtons & 0x4000)) {
			Return 1
		}
		Else If ((Button = 4) && (State.wButtons & 0x8000)) {
			Return 1
		}
		Else If ((Button = 5) && (State.wButtons & 0x0100)) {
			Return 1
		}
		Else If ((Button = 6) && (State.wButtons & 0x0200)) {
			Return 1
		}
		Else If ((Button = 7) && (State.wButtons & 0x0020)) {
			Return 1
		}
		Else If ((Button = 8) && (State.wButtons & 0x0010)) {
			Return 1
		}
		Else If ((Button = 9) && (State.wButtons & 0x0040)) {
			Return 1
		}
		Else If ((Button = 10) && (State.wButtons & 0x0080)) {
			Return 1
		}
		Else If ((Button = "X") && (State.wButtons & 0x0400)) {
			Return 1
		}
		
		;Triggers
		Else If ((Button = "L") && (State.bLeftTrigger > 5)) {
			Return 1
		}
		Else If ((Button = "R") && (State.bRightTrigger > 5)) {
			Return 1
		}
		Else {
			Return 0
		}
	}
}

GetNumXInput(xLib) {
	Connected := 0
	If (XInput_GetState(0, xLib) != -1) {
		Connected += 1
	}	
	
	If (XInput_GetState(1, xLib) != -1) {
		Connected += 1
	}
	
	If (XInput_GetState(2, xLib) != -1) {
		Connected += 1
	}
	
	If (XInput_GetState(3, xLib) != -1) {
		Connected += 1
	}
	
	Return Connected
}

allJOY(xLib, num1, num2 := "") {
	If (num2 = "") {
		If (num1 = "POV") {
			If (xInputTranslation(xLib, 0,num1) != -1) {
				return xInputTranslation(xLib, 0,num1)
			}
			Else If (xInputTranslation(xLib, 1,num1) != -1) {
				return xInputTranslation(xLib, 1,num1)
			}
			Else If (xInputTranslation(xLib, 2,num1) != -1) {
				return xInputTranslation(xLib, 2,num1)
			}
			Else If (xInputTranslation(xLib, 3,num1) != -1) {
				return xInputTranslation(xLib, 3,num1)
			}
			Else {
				return -1
			}
		}
		Else {
			If (xInputTranslation(xLib, 0,num1)) {
				return xInputTranslation(xLib, 0,num1)
			}
			Else If (xInputTranslation(xLib, 1,num1)) {
				return xInputTranslation(xLib, 1,num1)
			}
			Else If (xInputTranslation(xLib, 2,num1)) {
				return xInputTranslation(xLib, 2,num1)
			}
			Else If (xInputTranslation(xLib, 3,num1)) {
				return xInputTranslation(xLib, 3,num1)
			}
		}
	}
	Else If (num2 = "player") {
		If (xInputTranslation(xLib, 0,num1)) {
			return 0
		}
		Else If (xInputTranslation(xLib, 1,num1)) {
			return 1
		}
		Else If (xInputTranslation(xLib, 2,num1)) {
			return 2
		}
		Else If (xInputTranslation(xLib, 3,num1)) {
			return 3
		}
		Else {
			return -1
		}
	}
	Else {
		If (xInputTranslation(xLib, 0,num1) && xInputTranslation(xLib, 0,num2)) {
			return 1
		}
		ELse If (xInputTranslation(xLib, 1,num1) && xInputTranslation(xLib, 1,num2)) {
			return 1
		}
		Else If (xInputTranslation(xLib, 2,num1) && xInputTranslation(xLib, 2,num2)) {
			return 1
		}
		Else If (xInputTranslation(xLib, 3,num1) && xInputTranslation(xLib, 3,num2)) {
			return 1
		}
	}
	return 0
}

notJOY(xLib, num1, num2) {
	If (xInputTranslation(xLib, 0,num1) && !xInputTranslation(xLib, 0,num2)) {
		return 1
	}
	Else If (xInputTranslation(xLib, 1,num1) && !xInputTranslation(xLib, 1,num2)) {
		return 1
	}
	Else If (xInputTranslation(xLib, 2,num1) && !xInputTranslation(xLib, 2,num2)) {
		return 1
	}
	Else If (xInputTranslation(xLib, 3,num1) && !xInputTranslation(xLib, 3,num2)) {
		return 1
	}
	return 0
}

oneJOY(xLib, num1, num2) {
	return xInputTranslation(xLib, num2,num1)
}

DeveloperMode(xLib) {
	Input := ""
	While (notJOY(xLib, 7,8)) {
		If (allJOY(xLib, "POV") = 0) {
			Input := Input . "U"
			While(allJOY(xLib, "POV") = 0) 
			{}
		}
		If (allJOY(xLib, "POV") = 18000) {
			Input := Input . "D"
			While(allJOY(xLib, "POV") = 18000) 
			{}
		}
		If (allJOY(xLib, "POV") = 27000) {
			Input := Input . "L"
			While(allJOY(xLib, "POV") = 27000) 
			{}
		}
		If (allJOY(xLib, "POV") = 9000) {
			Input := Input . "R"
			While(allJOY(xLib, "POV") = 9000) 
			{}
		}
		If (allJOY(xLib, 1)) {
			Input := Input . "A"
			While(allJOY(xLib, 1)) 
			{}
		}
		If (allJOY(xLib, 2)) {
			Input := Input . "B"
			While(allJOY(xLib, 2)) 
			{}
		}
	}
	If (InStr(Input, "UUDDLRLRBA")) {
		Return true
	}
	Else {
		Return false
	}
}

ForceRestart(xLib) {
	Input := ""
	While (notJOY(xLib, 8,7)) {
		If (allJOY(xLib, "POV") = 0) {
			Input := Input . "U"
			While(allJOY(xLib, "POV") = 0) 
			{}
		}
		If (allJOY(xLib, "POV") = 18000) {
			Input := Input . "D"
			While(allJOY(xLib, "POV") = 18000) 
			{}
		}
		If (allJOY(xLib, "POV") = 27000) {
			Input := Input . "L"
			While(allJOY(xLib, "POV") = 27000) 
			{}
		}
		If (allJOY(xLib, "POV") = 9000) {
			Input := Input . "R"
			While(allJOY(xLib, "POV") = 9000) 
			{}
		}
		If (allJOY(xLib, "1")) {
			Input := Input . "A"
			While(allJOY(xLib, "1")) 
			{}
		}
		If (allJOY(xLib, "2")) {
			Input := Input . "B"
			While(allJOY(xLib, "2")) 
			{}
		}
	}
	If (InStr(Input, "UUDDLRLRBA")) {
		Return true
	}
	Else {
		Return false
	}
}	

WaitForDevice(file) {
	Run, "C:/AutoHotkey/files/devices/%file%"
	Sleep, 500
	FileRead, Data, C:/AutoHotkey/files/devices/return.txt
	
	xLib := XInput_Initialize()

	WinActivate, master.ahk

	While(InStr(Data, "No matching devices found.")) {
		
		Count := 0 
		While (Count < 5) {
			Sleep, 100
			If (allJOY(xLib, 2) || allJOY(xLib, 7, 8)) {
			
				XInput_Terminate(xLib)
				Return 1
			}
			Count += 1
		}
		
		Run, "C:/AutoHotkey/files/devices/%file%"
		
		Count := 0 
		While (Count < 5) {
			Sleep, 100
			If (allJOY(xLib, 2) || allJOY(xLib, 7, 8)) {
			
				XInput_Terminate(xLib)
				Return 1
			}
			Count += 1
		}
		
		FileRead, Data, C:/AutoHotkey/files/devices/return.txt
	}
	
	XInput_Terminate(xLib)
	Return 0
}

ErrorMessageInput(xLib) {
	SetTitleMatchMode, 2
	Text := ""
	If (!ProcessExist("chrome.exe")) {
		If (WinShown("Error")) {
			Text := "Error"
		}
		Else If (WinShown("Message")) {
			Text := "Message"
		}
		Else If (WinShown("Runtime")) {
			Text := "Runtime"
		}
		Else If (WinShown("Warning")) {
			Text := "Warning"
		}
		Else If (WinShown("Report")) {
			Text := "Report"
		}
		
		If (Text != "") {
			CleanActivate(Text)
			
			If (allJOY(xLib, 1) || allJOY(xLib, 2)) {
				Send {enter}
				WinClose, %Text%
			}
			
			Return 1
		}
	}
	
	Return 0
}
	