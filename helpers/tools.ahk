#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ----- CONSTANTS -----

AVGSHLEP := 100
EXITTIME := 140
AVGBATCHLINES := 80

; ----- FUNCTIONS -----

nameFromPID(PID) {
	DetectHiddenWindows, On
	WinGet, Name, ProcessName, ahk_pid %PID%
	Return Name
}

regexClean(text) {
	RetVal := StrReplace(text, "\", "\\")
	RetVal := StrReplace(RetVal, ".", "\.")
	RetVal := StrReplace(RetVal, "*", "\*")
	RetVal := StrReplace(RetVal, "?", "\?")
	RetVal := StrReplace(RetVal, "+", "\+")
	RetVal := StrReplace(RetVal, "[", "\[")
	RetVal := StrReplace(RetVal, "{", "\{")
	RetVal := StrReplace(RetVal, "|", "\|")
	RetVal := StrReplace(RetVal, "(", "\(")
	RetVal := StrReplace(RetVal, ")", "\)")
	RetVal := StrReplace(RetVal, "^", "\^")
	RetVal := StrReplace(RetVal, "$", "\$")
	
	Return RetVal
}

gameNameClean(PID) {
	WinGetTitle, Name, ahk_pid %PID%
	If (InStr(Name, "D3DProxyWindow")) {
		If (WinExist("JIT64")) {
			return "JIT64"
		}
		Else {
			return "master.ahk"
		}
	} 
	Else {
		return Name
	}
}

pathArrayToString(Array) {
	Str := ""
	For Index, Value In Array
		Str .= "\" . Value

	Str := LTrim(Str, "\")
	Return Str
}

nameFromPath(NameIndex, Path) {
	PathArray := StrSplit(Path, "\")
	
	Return PathArray[PathArray.MaxIndex() - NameIndex]
}

emuFromName(Name) {
	RegExMatch(Name, "^\[[A-Z0-9 ]{1,7}\]", Bruh)
	Return SubStr(Bruh, 2, -1)
	
}

createGamePIDCase(text) {
	Return "Case """ . text . """:`r`nReturn gameProcess(""" . text . """)`r`n`r`n"
}

objStringToArr(Input) {
	If (!IsObject(Input)) {
		If (InStr(Input, ",")) {
			Input := StrSplit(Input, ",")
			Loop % Input.MaxIndex() {
				Input[A_Index] := Trim(Input[A_Index], " `r`n")
			}
		}
		Else {
			Input := [Input]
		}
	}
	
	Return Input
}

initializeGamePID() {
	SetupText := "`r`nfor proc in ComObjGet(""winmgmts:"").ExecQuery(""Select * from Win32_Process"") {`r`nSwitch proc.Name {`r`n"
	winText := SetupText
	emuText := SetupText

	FileRead, pidText, C:\AutoHotkey\files\cfg\pidStruct.txt

	winGameArr := ReadSimpleCFG("C:\AutoHotkey\files\games\gameList.txt", "WINDOWS")
	emuGameArr := ReadSimpleCFG("C:\AutoHotkey\files\games\gameList.txt", "EMULATORS")
	
	Loop % winGameArr.MaxIndex() {
		winText := winText . createGamePIDCase(winGameArr[A_Index])
	}

	Loop % emuGameArr.MaxIndex() {
		emuText := emuText . createGamePIDCase(emuGameArr[A_Index])
	}

	winDoneText := RegExReplace(pidText
		, "s)winGamePID\(\) \{.*\} `; WINGAME"
		, "winGamePID() {" . winText . "} `; WINGAME")

	doneText := RegExReplace(winDoneText
		, "s)emulatorPID\(\) \{.*\} `; EMUGAME"
		, "emulatorPID() {" . emuText . "} `; EMUGAME")

	file := FileOpen("C:\AutoHotkey\helpers\gamePID.ahk", "w")
	file.Write(doneText)
	file.Close()
}

ReadSimpleCFG(ToRead, Type, Deliminator := "") {
	FileRead, read, %ToRead%
	
	If (InStr(read, "`r")) {
		cfgEOL := "`r`n"
	}
	Else {
		cfgEOL := "`n"
	}
	configLines := StrSplit(read, cfgEOL)
	
	configFound := 0
	subConfig := 0
	configArr := []
	configElement := ""

	Loop % configLines.MaxIndex() {
		currLine := Trim(configLines[A_Index], " `t`r`n")
		
		If (configFound && currElement != "") {
			If (subConfig && SubStr(currLine, 1, 2) = "}$") {
				currElement .= configLines[A_Index]
				configArr.Push(currElement)
				currElement := ""
				subConfig := 0
				
				Continue
			}
			Else If (!subConfig && (InStr(currLine, Deliminator) || currLine = "}")) {
				configArr.Push(currElement)
				currElement := ""
			}
			Else {
				currElement .= configLines[A_Index]
				
				If (subConfig = 1) {
					currElement .= cfgEOL
				}
			}
		}
		
		If (configFound && currElement = "" && currLine != "}") {
			currElement := configLines[A_Index]
			
			If (SubStr(currLine, -1, 2) = "${") {
				currElement .= cfgEOL
				subConfig := 1
			}
		}
		
		If (!currLine || RegExMatch(currLine, "U)^;")) {
			Continue
		}
		Else If (RegExMatch(currLine, "U)" . regexClean(Type) . " *\{")) {
			configFound := 1
		}
		Else If (configFound && currLine = "}") {
			configFound := 0
		}
		
	}
	Loop % configArr.MaxIndex() {
		configArr[A_Index] := RTrim(configArr[A_Index], " `t`r`n")
	}
	
	RetArr := []	
	configNameArr := []
	Loop % configArr.MaxIndex() {
		If (InStr(configArr[A_Index], "${") && InStr(configArr[A_Index], "}$")) {
			configNameArr.Push(StrSplit(configArr[A_Index], "${")[1])
		}
		Else If (Deliminator != "" && InStr(configArr[A_Index], Deliminator)) {
			configNameArr.Push(StrSplit(configArr[A_Index], Deliminator)[1])
		}
	}
		
	If (configNameArr.MaxIndex() > 0) {
		Loop % configNameArr.MaxIndex() {
			configIndex := A_Index
			
			If (RetArr.MaxIndex() > 0) {
				configDuplicate := 0
				Loop % RetArr.MaxIndex() {
					If (InStr(configArr[A_Index], "${") && InStr(configArr[A_Index], "}$")) {
						retName := StrSplit(RetArr[A_Index], "${")[1]
					}
					Else {
						retName := StrSplit(RetArr[A_Index], Deliminator)[1]
					}
					
					If (retName = configNameArr[configIndex]) {
						configDuplicate := 1
						Break
					}
				}
				
				If (!configDuplicate) {
					RetArr.Push(configArr[configIndex])
				}
			}
			Else {
				RetArr.Push(configArr[configIndex])
			}
		}
	}
	Else {
		RetArr := configArr
	}
	
	Return RetArr
}

ReadCFG(ToRead, Type, Name, Deliminator := "=", PerfectMatch := 0) {
	FileRead, read, %ToRead%
	StringUpper, Type, Type
	
	If (InStr(read, "`r")) {
		cfgEOL := "`r`n"
	}
	Else {
		cfgEOL := "`n"
	}
	configLines := StrSplit(read, cfgEOL)
	
	typeFound := 0
	nameFound := 0
	configFound := 0
	subConfig := 0
	configArr := []
	currElement := ""

	Loop % configLines.MaxIndex() {
		currLine := RTrim(configLines[A_Index], " `t`r`n")
		
		If (configFound && currElement != "") {
			If (subConfig && SubStr(currLine, 1, 2) = "}$") {
				currElement .= configLines[A_Index]
				configArr.Push(currElement)
				
				currElement := ""
				subConfig := 0
				
				Continue
			}
			Else If (!subConfig && (InStr(currLine, Deliminator) || currLine = "}")) {
				configArr.Push(currElement)
				currElement := ""
			}
			Else {
				currElement .= configLines[A_Index]
				
				If (subConfig = 1) {
					currElement .= cfgEOL
				}
			}
		}
		
		If (configFound && currElement = "" && currLine != "}") {
			currElement := configLines[A_Index]
			
			If (SubStr(currLine, -1, 2) = "${") {
				currElement .= cfgEOL
				subConfig := 1
			}
		}
		
		If (!currLine || RegExMatch(currLine, "U)^;")) {
			Continue
		}
		Else If (!typeFound && RegExMatch(currLine, "U)" . regexClean(Type) . " *\{")) {
			typeFound := 1
		}
		Else If (typeFound && !nameFound && InStr(Name, currLine)) {
			If (PerfectMatch = 0) {
				nameFound := 1
			}
			Else If (PerfectMatch = 1 && Name = currLine) {
				nameFound := 1
			}
		}
		Else If (typeFound && nameFound && RegExMatch(currLine, "U) *CONFIG *\{")) {
			configFound := 1
		}
		Else If (RegExMatch(currLine, "U) *DEFAULT *\{")) {
			configFound := 1
		}
		Else If (typeFound && && !nameFound && currLine = "}") {
			typeFound := 0
		}
		Else If (configFound && currLine = "}") {
			configFound := 0
			typeFound := 0
			nameFound := 0
		}
		
	}
	
	Loop % configArr.MaxIndex() {
		configArr[A_Index] := RTrim(configArr[A_Index], " `t`r`n")
	}
	
	RetArr := []	
	configNameArr := []
	Loop % configArr.MaxIndex() {
		If (InStr(configArr[A_Index], "${") && InStr(configArr[A_Index], "}$")) {
			configNameArr.Push(StrSplit(configArr[A_Index], "${")[1])
		}
		Else If (Deliminator != "" && InStr(configArr[A_Index], Deliminator)) {
			configNameArr.Push(StrSplit(configArr[A_Index], Deliminator)[1])
		}
	}
		
	If (configNameArr.MaxIndex() > 0) {
		Loop % configNameArr.MaxIndex() {
			configIndex := A_Index
			
			If (RetArr.MaxIndex() > 0) {
				configDuplicate := 0
				Loop % RetArr.MaxIndex() {
					If (InStr(configArr[A_Index], "${") && InStr(configArr[A_Index], "}$")) {
						retName := StrSplit(RetArr[A_Index], "${")[1]
					}
					Else {
						retName := StrSplit(RetArr[A_Index], Deliminator)[1]
					}
					
					If (retName = configNameArr[configIndex]) {
						configDuplicate := 1
						Break
					}
				}
				
				If (!configDuplicate) {
					RetArr.Push(configArr[configIndex])
				}
			}
			Else {
				RetArr.Push(configArr[configIndex])
			}
		}
	}
	Else {
		RetArr := configArr
	}
	
	Return RetArr
}

WriteToCFG(ToRead, ToWrite, Type, Name, Deliminator := "=", PerfectMatch := 0, Rewrite := 0) {
	configArr := ReadCFG(ToRead, Type, Name, Deliminator, PerfectMatch)
	
	FileRead, write, %ToWrite%
	
	If (InStr(write, "`r")) {
		endOfLine := "`r`n"
		eofConfig := ""
	}
	Else {
		endOfLine := "`n"
		eofConfig := "`n"
	}
		
	Loop % configArr.MaxIndex() {
		configArr[A_Index] := configArr[A_Index] . endOfLine
		
		If (endOfLine = "`n") {
			configArr[A_Index] := StrReplace(configArr[A_Index], "`r`n", "`n")
		}
	}

	If (Rewrite = 0) {
		Loop % configArr.MaxIndex() {
			If (Deliminator != "") {
				configElement := StrSplit(configArr[A_Index], Deliminator)[1]
			}
			Else {
				configElement := configArr[A_Index]
			}
			
			If (InStr(configElement, "${") && InStr(configElement, "}$")) {
				tempArr := StrSplit(configElement, "${")
				startLine := tempArr[1] . endOfLine
				
				tempArr := StrSplit(tempArr[2], "}$")
				finishLine := tempArr[2]
				middleLine := LTrim(tempArr[1], "`r`n")
				
				write := RegExReplace(write, "msU" . eofConfig . ")^" . regexClean(startLine) . ".*" 
				. regexClean(finishLine), startLine . middleLine . finishLine)
			}
			Else {
				write := RegExReplace(write, "mU" . eofConfig . ")^"
				. regexClean(configElement) . regexClean(Deliminator) . ".*" . endOfLine, configArr[A_Index])
			}
		}
	}
	Else {
		write := ""
		Loop % configArr.MaxIndex() {			
			write .= configArr[A_Index]
		}
	}						
	
	file := FileOpen(ToWrite, "w")
	file.Write(write)
	file.Close()
}

WinShown(Name) {
	DetectHiddenWindows, Off
	return WinExist(Name)
}

WinRunning(Name) {
	WinGet, ID, List, ahk_exe  %Name%
	Temp := 0
	Loop, %ID% {
		This := ID%A_Index%
		WinGetTitle, Title, ahk_id %This%
		If ((Title = "") || InStr(Title, "Responding")) {
			continue
		}
		Else {
			Temp += 1
		}
	}
	
	If (Temp > 0) {
		return true
	}
	Else {
		return false
	}
}

ScriptExist() {
	If (ProcessExist("ChromeScript.exe") || ProcessExist("GameScript.exe") 
	|| ProcessExist("BoxScript.exe") || ProcessExist("GameCustomScript.exe")
	|| ProcessExist("JackboxScript.exe")) {
		Return True
	}
	Return False
}
	
SuspendScript(file) {
	DetectHiddenWindows, On
	PostMessage, 0x111, 65403,,, master.ahk - AutoHotkey
}

ScriptClose(name) {
	DetectHiddenWindows, On
	WinClose, %name%
}

CloseAllScripts() {
	Process, Close, ShutdownFlag.exe
	Process, Close, RestartFlag.exe
	Process, Close, ControllerScript.exe
	Process, Close, BoxScript.exe
	Process, Close, ChromeScript.exe
	Process, Close, GenericDialog.exe
	Process, Close, GameScript.exe
	Process, Close, ImgControlScript.exe
	Process, Close, JackboxScript.exe
}

ProcessExist(name) {
	Process, Exist, %name%
	return ErrorLevel
}

ProcessSuspend(name, time := 0) {
	Run, "C:\AutoHotkey\bin\64\SuspendScript.exe" "C:\AutoHotkey\helpers\suspend.ahk" "%name%" "%time%"
}

ProcessResume(name) {
	SetTitleMatchMode, 2
	WinGet, ProcessPID, PID, ahk_exe %name%
	
	h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", ProcessPID)

    If (h) {   
        DllCall("ntdll.dll\NtResumeProcess", "Int", h)

		DllCall("CloseHandle", "Int", h)
	}
}

DialogExist() {
	If (ProcessExist("GameDialog.exe") || ProcessExist("DSDialog.exe")
	|| ProcessExist("GenericDialog.exe") || ProcessExist("ChromeDialog.exe")) {
		return true
	}
	Else {
		return false
	}
}

CleanActivate(Name) {
	SetTitleMatchMode, 2
	If (!WinActive(Name)) {
		WinActivate, %Name%
	}
}

ShowLoadingScreen() {
	MouseMove, 9999, 9999, 0
	WinActivate, master.ahk
}

ForceLoadingScreen(time) {
	MouseMove, 9999, 9999, 0
	Count := 0
	Final := time / 10
	While (Count < Final) {
		Sleep, 10
		Count += 1
		WinActivate, master.ahk
	}
}

UpdateLoadFlag(text) {
	If (text = "close") {
		While (ProcessExist("LoadFlag.exe")) {
			Process, Close, LoadFlag.exe
			Sleep, 100
		}
	}
	Else {
		file := FileOpen("C:/AutoHotkey/files/loading.txt", "w")
		file.Write(text)
		file.Close()
		
		MouseMove, 9999, 9999, 0
		Run, "C:\AutoHotkey\bin\64\flags\LoadFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		WinActivate, master.ahk
		Sleep, 100
	}
}

ResetLoadingScreen(activate) {
	DetectHiddenWindows, Off
	If (!WinExist("master.ahk") || !ProcessExist("MasterScript.exe")) {
		Process, Close, MasterScript.exe
		Sleep, 100
		Run, "C:\AutoHotkey\bin\64\MasterScript.exe" "C:\AutoHotkey\master.ahk"
		Sleep, 100
	}
	If (activate) {
		WinActivate, master.ahk
	}
}

JackBoxExist() {
	If (ProcessExist("The Jackbox Party Pack.exe") || ProcessExist("The Jackbox Party Pack 2.exe") 
	|| ProcessExist("The Jackbox Party Pack 3.exe")) {
		return true
	}
	Else {
		return false
	}
}

ErrorMessage(close) {
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
			
			If (close != 0) {
				While(WinShown(Text)) {
					Send {enter}
					WinClose, %Text%
					Sleep, 250
				}
			}
			
			Return 1
		}
	}
	
	Return 0
}

GCNAdapter(option) {
	SetTitleMatchMode, 2
	If (option = "open") {
		Run, "C:\GCNadapter\GCNUSBFeeder.exe"
		WinWait, Adapter
		
		Sleep, 200
		
		WinGetPos, X, Y, W, H, Adapter
		HH := Floor(H/2)
		HW := Floor(W/2)
		WinMove, Adapter,, (960 - HW), (550 - HH)
		WinActivate, Adapter
		
		Sleep, 4000
	}
	
	If (option = "close") {
		While(ProcessExist("GCNUSBFeeder.exe")) {
			WinActivate, Adapter
			Sleep, 70
			Send, {Alt}
			Sleep, 70
			Send, {Enter}
			Sleep, 70
			Send, {down}
			Sleep, 70
			Send, {down}
			Sleep, 70
			Send, {down}
			Sleep, 70
			Send {Enter}
			Sleep, 2000
		}
	}
}

checkNonKodi(hidden) {
	SetTitleMatchMode, 2
	If (hidden) {
		DetectHiddenWindows, On
	}
	Else {
		DetectHiddenWindows, Off
	}
	
	If (ProcessExist("chrome.exe") || ProcessExist("BigBox.exe") || ProcessExist("The Jackbox Party Pack.exe")
	|| ProcessExist("The Jackbox Party Pack 2.exe") || ProcessExist("The Jackbox Party Pack 3.exe")) {
		return true
	}
	Else {
		return false
	}
}

checkGameLauncher() {
	SetTitleMatchMode, 2

	If (WinShown("Origin") || WinShown("Adapter") 
	|| WinShown("Configuration") || WinShown("Play ")
	|| ProcessExist("Launcher.exe") || WinShown("SUPERHOT LAUNCHER")
	|| ProcessExist("game_launcher.exe") || ProcessExist("SkyrimSELauncher.exe") 
	|| ProcessExist("FalloutLauncher.exe") || ProcessExist("FalloutNVLauncher.exe")
	|| ProcessExist("Fallout4Launcher.exe") || ProcessExist("OblivionLauncher.exe")
	|| ProcessExist("SA2ModManager.exe") || ProcessExist("BmLauncher.exe")) {
		Return True
	}
	Else {
		Return False
	}
}

checkFullscreen(WinTitle) {
	SetTitleMatchMode, 2
	WinGet, style, Style, %WinTitle%
    ; 0x800000 is WS_BORDER.
    ; 0x20000000 is WS_MINIMIZE.
    ; no border and not minimized
	
	Return (style & 0x20800000) ? False : True
}

KodiLoad(option, text := "") {
	If (option = "open") {
		MouseMove, 9999, 9999, 0
		SplashImage, C:\Assets\black.png, b h25 w1920 y0
		
		While (checkFullscreen("Kodi")) {
			ControlSend,, \, Kodi
			Sleep, 100
		}
		
		WinMaximize, Kodi
		Sleep, 1000
		SplashImage, Off
		
		Run, "C:\AutoHotkey\bin\64\helpers\KodiMinScript.exe" "C:\AutoHotkey\helpers\kodiMin.ahk"
		
		Sleep, 500
		UpdateLoadFlag(text)
	
		Sleep, 250
	}
	
	Else If (option = "close") {
		WinRestore, Kodi
		
		While (!checkFullscreen("Kodi")) {
			ControlSend,, \, Kodi
			Sleep, 100
		}
		
		WinActivate, Kodi
		
		Sleep, 250
	}
}

KodiAppClose(name) {
	Run, "C:\AutoHotkey\bin\64\helpers\KodiCloseScript.exe" "C:\AutoHotkey\helpers\kodiClose.ahk" "%name%"
}

Joy2Key(option) {
	If (option = "dirty") {
		If (ProcessExist("JoyToKey.exe")) {
			Process, Close, JoyToKey.exe
			Sleep, 1000
		}
		Run, "C:\JoyToKey_en\JoyToKey.exe"
		Sleep, 100
		return
	}
	
	If (option = "clean") {
		If (!ProcessExist("JoyToKey.exe")) {
			Run, "C:\JoyToKey_en\JoyToKey.exe"
			Sleep, 100
			return
		}
		return
	}
			
	If (option = "reset") {
		If (!ProcessExist("JoyToKey.exe")) {
			Run, "C:\JoyToKey_en\JoyToKey.exe"
			Sleep, 100
		}
		Else {
			Run, "C:\JoyToKey_en\JoyToKey.exe" "-r"
		}
		return
	}
	
	If (option = "close") {
		Process, Close, JoyToKey.exe
		return
	}
}

X360CE(option) {
	If (option = "open") {
		If (!ProcessExist("x360ce.exe")) {
			Run, "C:\X360CE\x360ce.lnk"
			WinWait, Controller Emulator
			Sleep, 2000
			WinMinimize, Controller Emulator
		}
		
		return
	}
	
	If (option = "close") {
		FuckXInput := 0
		While (ProcessExist("x360ce.exe")) {
			WinClose, Controller Emulator
			
			FuckXInput += 1
			If (FuckXInput = 6) {
				Process, Close, x360ce.exe
			}
			
			Sleep, 1500
		}
		
		return
	}

}

Steam(option) {
	If (option = "clean") {
		If (!ProcessExist("steam.exe")) {
			Run, "C:\Steam\steamsilent.lnk" ;"-no-browser"
			Sleep, 250
			While(!ProcessExist("steam.exe")) {
				Sleep, 250
			}
			Sleep, 5000
		}
		return
	}
	
	If (option = "dirty") {
		If (ProcessExist("steam.exe")) {
			Run, "C:\Steam\steam.exe" "-shutdown"
			Count := 0
			While (ProcessExist("steam.exe") || ProcessExist("steamerrorreporter.exe")) {
				Sleep, 250
				
				Count += 1
				If (Count > 60) {
					Process, Close, steam.exe
				}
			}
			Sleep, 1000
		}
		Run, "C:\Steam\steamsilent.lnk" ;"-no-browser"
		Sleep, 250
		While(!ProcessExist("steam.exe")) {
			Sleep, 250
		}
		Sleep, 5000
		return
	}
	
	If (option = "close") {
		If (ProcessExist("steam.exe")) {
			Run, "C:\Steam\steam.exe" "-shutdown"
			Count := 0
			While (ProcessExist("steam.exe") || ProcessExist("steamerrorreporter.exe")) {
				Sleep, 250
				
				Count += 1
				If (Count > 60) {
					Process, Close, steam.exe
				}	
			}
			Sleep, 1000
			return
		}
		return
	}
}

SteamUpdateHandler() {
	DetectHiddenWindows, Off
	SetTitleMatchMode, 2
	
	If (WinExist("Updating ")) {
		WinGetPos, X, Y, W, H, Updating
		HH := Floor(H/2)
		HW := Floor(W/2)
		If (((X + HW) != 960) || ((Y + HH) != 680)) {
			WinMove, Updating,, (960 - HW), (680 - HH), 640, H
		}
		
	}
	Else If (WinExist("Ready - ")) {
		CoordMode, Mouse
		WinActivate, Ready
		
		WinGetPos, X, Y, W, H, Ready
		; 1187, 665 this is literally the perfect pixel
		MouseX := X + W - 93
		MouseY := Y + 158
		
		Sleep, 75
		MouseMove, MouseX, MouseY
		Sleep, 75
		MouseClick, Left
		Sleep, 75
		MouseMove, 9999, 9999, 0
		
		Sleep, 1000
	}
}

SteamEULAHandler() {
	DetectHiddenWindows, Off
	SetTitleMatchMode, 2
	
	;If (WinExist(" - Steam")) {
	;	Sleep, 1000
	;	WinGetTitle, Eula,  - Steam
	;	EulaTitle := StrReplace(Eula," - Steam")
	;	SetTitleMatchMode, 3
	;	If (WinExist(EulaTitle)) {
	;		WinActivate, %EulaTitle%
	;		Sleep, 100
	;		CoordMode, Mouse
	;		MouseMove, 970, 725
	;		Sleep, 100
	;		MouseClick, Left
	;		Sleep, 100
	;		MouseMove, 1920, 1080
	;		Sleep, 1000
	;	}
	;}
	
	If (WinExist("Install - ")) {
		Sleep, 1000
		WinActivate, Install -
		Sleep, 100
		Send {Enter}
	}
}

SteamShown() {
	DetectHiddenWindows, Off
	SetTitleMatchMode, 2
	If (WinExist(" - Steam") || WinExist("Updating ") || WinExist("Ready - ")) {
		return 1
	}
	Else {
		return 0
	}
}

FileReadSeek(FObj) {
	RetString := FObj.Read()
	FObj.Seek(0)
	
	Return RetString
}

NotBackgroundTask(WinTitle) {
	If (ProcessExist("MultiFlag.exe")) {
		FileRead, BackgroundApp, C:/AutoHotkey/files/multi.txt
		
		If (InStr(BackgroundApp, WinTitle)) {
			Return False
		}
		
		Return True
	}
	
	Return True
}

CloseMultiTasking(Notif) {
	Process, Close, MultiFlag.exe
	If (Notif = 1) {
		Run, "C:\AutoHotkey\bin\64\dialogs\GenericDialog.exe" "C:\AutoHotkey\gui\dedicatedDialog.ahk" "Disabling Multitasking (Beta)..." 3000 "l" 700
	}
	file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
	file.Write("")
	file.Close()
}

MultiTasking() {	
	MouseMove, 9999, 9999, 0
	Process, Close, osk.exe
	
	If (!ProcessExist("MultiFlag.exe")) {
	
		Run, "C:\AutoHotkey\bin\64\dialogs\GenericDialog.exe" "C:\AutoHotkey\gui\dedicatedDialog.ahk" "Enabling Multitasking (Beta)..." 3000 "l" 700
		Fresh := 1
	}
	Else {
		Fresh := 0
	}
	
	FileRead, BackgroundApp, C:/AutoHotkey/files/multi.txt
	Sleep, 100
	
	If (ProcessExist("ChromeScript.exe")) {
		MultiApp := "chrome"
	}
	Else If (ProcessExist("BoxScript.exe")) {
		MultiApp := "bigbox"
	}
	Else {
		MultiApp := "kodi"
	}
	
	If (MultiApp = "chrome") {
		Process, Close, ChromeDialog.exe
		
		file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
		file.Write("chrome.exe")
		file.Close()
		
	
		Run, "C:\AutoHotkey\bin\64\flags\MultiFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		
		Process, Close, ChromeScript.exe
		WinMinimize, Chrome
		
		
		If (Fresh = 1) {
			KodiLoad("close")
		}
		Else {
			CleanActivate(BackgroundApp)
			
			If (InStr(BackgroundApp, "BigBox.exe")) {
				Run, "C:\AutoHotkey\bin\64\BoxScript.exe" "C:\AutoHotkey\programs\bigbox.ahk"
			}
		}
	}
	Else If (MultiApp = "bigbox") {
		file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
		file.Write("BigBox.exe")
		file.Close()
		
		Run, "C:\AutoHotkey\bin\64\flags\MultiFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		
		Process, Close, BoxScript.exe
		WinMinimize, Big Box
	
		
		If (Fresh = 1) {
			KodiLoad("close")
		}
		Else {
			CleanActivate(BackgroundApp)
			
			If (InStr(BackgroundApp, "chrome.exe")) {
				Run, "C:\AutoHotkey\bin\64\ChromeScript.exe" "C:\AutoHotkey\programs\chrome.ahk"
				
				CoordMode, Mouse
				MouseMove, 960, 540, 0
			}
		}
	}
	Else If (MultiApp = "kodi" && Fresh = 0) {
		file := FileOpen("C:/AutoHotkey/files/multi.txt", "w")
		file.Write("kodi.exe")
		file.Close()
		
		Run, "C:\AutoHotkey\bin\64\flags\MultiFlag.exe" "C:\AutoHotkey\helpers\flag.ahk"
		
		WinMinimize, ahk_exe kodi.exe
		
		CleanActivate(BackgroundApp)
		
		If (InStr(BackgroundApp, "chrome.exe")) {
			Run, "C:\AutoHotkey\bin\64\ChromeScript.exe" "C:\AutoHotkey\programs\chrome.ahk"
			
			CoordMode, Mouse
			MouseMove, 960, 540, 0
		}
		Else If (InStr(BackgroundApp, "BigBox.exe")) {
			Run, "C:\AutoHotkey\bin\64\BoxScript.exe" "C:\AutoHotkey\programs\bigbox.ahk"
		}
		
	}
	
	If (Fresh = 0) {
		BackgroundString := "Multitasking - " . BackgroundApp
		Run, "C:\AutoHotkey\bin\64\dialogs\GenericDialog.exe" "C:\AutoHotkey\gui\dedicatedDialog.ahk" "%BackgroundString%" 3000 "l" 700
	}
	
	;If (!InStr(BackgroundApp, "kodi.exe")) {
	;	Sleep, 250
	;	KodiMin()
	;}
}

IsInternetConnected() {
  static sz := A_IsUnicode ? 408 : 204, addrToStr := "Ws2_32\WSAAddressToString" (A_IsUnicode ? "W" : "A")
  VarSetCapacity(wsaData, 408)
  if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", &wsaData)
    return false
  if DllCall("Ws2_32\GetAddrInfoW", "wstr", "dns.msftncsi.com", "wstr", "http", "ptr", 0, "ptr*", results)
  {
    DllCall("Ws2_32\WSACleanup")
    return false
  }
  ai_family := NumGet(results+4, 0, "int")    ;address family (ipv4 or ipv6)
  ai_addr := Numget(results+16, 2*A_PtrSize, "ptr")   ;binary ip address
  ai_addrlen := Numget(results+16, 0, "ptr")   ;length of ip
  DllCall(addrToStr, "ptr", ai_addr, "uint", ai_addrlen, "ptr", 0, "str", wsaData, "uint*", 204)
  DllCall("Ws2_32\FreeAddrInfoW", "ptr", results)
  DllCall("Ws2_32\WSACleanup")
  http := ComObjCreate("WinHttp.WinHttpRequest.5.1")

  if (ai_family = 2 && wsaData = "131.107.255.255:80")
  {
    http.Open("GET", "http://www.msftncsi.com/ncsi.txt")
  }
  else if (ai_family = 23 && wsaData = "[fd3e:4f5a:5b81::1]:80")
  {
    http.Open("GET", "http://ipv6.msftncsi.com/ncsi.txt")
  }
  else
  {
    return false
  }
  http.Send()
  return (http.ResponseText = "Microsoft NCSI") ;ncsi.txt will contain exactly this text
}

WaitForInternetTimeout(time) {
	Status := IsInternetConnected()
	Timed := 0
	
	SetTimer, Timeout, %time%
	SetTimer, CheckInternet, 500
	
	While (!Status && !Timed) {
		Sleep, 100
	}
	
	SetTimer, CheckInternet, Off
	SetTimer, Timeout, Off
	
	Return Status
	
	CheckInternet:
		Status := IsInternetConnected()
		Return
	
	Timeout:
		Timed := 1
		Return
}
