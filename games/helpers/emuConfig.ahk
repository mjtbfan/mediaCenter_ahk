#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

systemInfo(System, InfoTypes := "") {
	consoleInfo := ReadCFG("C:\AutoHotkey\files\cfg\consoles.txt", "console", System,, 1)
	RetObj := {}
	RetOneObj := ""
	
	If (InfoTypes != "") {
		InfoTypes := objStringToArr(InfoTypes)
		
		If (InfoTypes.MaxIndex() = 1) {
			RetOneObj := InfoTypes[1]
		}
		
		Loop % InfoTypes.MaxIndex() {
			currInfo := InfoTypes[A_Index]

			Loop % consoleInfo.MaxIndex() {
				currLineArr := StrSplit(consoleInfo[A_Index], "=")
				detailName := Trim(currLineArr[1], " `r`n")
				If (detailName = currInfo) {
					RetObj[currInfo] := Trim(currLineArr[2], " `r`n")
				}
			}
		}
	}
	Else {
		Loop % consoleInfo.MaxIndex() {
			currLineArr := StrSplit(consoleInfo[A_Index], "=")
			detailName := Trim(currLineArr[1], " `r`n")
			
			RetObj[detailName] := Trim(currLineArr[2], " `r`n")
		}
	}	
	
	; bonus code
	If (RetObj["controls"]) {
		RetObj["controls"] := "Default, " . RetObj["controls"]
	}
	
	For key, value in RetObj {
		If (InStr(value, "`r")) {
			eol := "`r`n"
		}
		Else {
			eol := "`n"
		}
		
		If (value != "" && SubStr(key, -2, 3) = "Dir" && SubStr(value, 0, 1) != "\") {
			RetObj[key] .= "\"
		}
		Else If (value != "" && SubStr(key, -2, 3) = "Cmd") {
			RetObj[key] := StrReplace(RetObj[key], "${" . eol)
			RetObj[key] := StrReplace(RetObj[key], eol . "}$")
		}
	}
	
	If (RetOneObj) {
		Return RetObj[RetOneObj]
	}
	Else {
		Return RetObj
	}
}

systemAliases(System) {
	FileRead, consoles, C:\AutoHotkey\files\cfg\consoles.txt
	consolesLines := StrSplit(consoles, "`r`n")
	
	RetArr := []
	tempArr := []
	inConsole := 0
	foundConsole := 0
	Loop % consolesLines.MaxIndex() {
		currLine := Trim(consolesLines[A_Index], " `r`n")
		
		If (!inConsole && RegExMatch(currLine, "U) *CONSOLE *\{")) {
			inConsole := 1
		}
		Else If (inConsole && currLine != "}") {
			tempArr.Push(currLine)
		}
		Else If (inConsole && currLine = "}") {
			inConsole := 0
			
			Loop % tempArr.MaxIndex() {
				If (tempArr[A_Index] = System) {
					foundConsole := 1
					Break
				}
			}
			
			If (foundConsole) {
				RetArr := tempArr
				Break
			}
			Else {
				tempArr := []
			}
		}
		
	}
	
	Return RetArr
}		

systemCheckFromRom(Rom) {
	FileRead, consoles, C:\AutoHotkey\files\cfg\consoles.txt	
	consolesLines := StrSplit(consoles, "`r`n")
	
	regexRomDir := "romDir *= *"
	romParts := StrSplit(Rom, "\")
	
	consoleFound := 0
	configFound := 0
	Loop % consolesLines.MaxIndex() {
		currLine := Trim(consolesLines[A_Index], " `r`n")
		
		If (consoleFound = 0) {
			Loop % romParts.MaxIndex() {

				If (romParts[A_Index] != "" && currLine = romParts[A_Index]) {
					consoleFound := 1
					RetVal := romParts[A_Index]
				}
			}
		}
		Else {
			If (RegExMatch(currLine, "U) *CONFIG *\{")) {
				configFound := 1
			}
			Else If (configFound = 1 && RegExMatch(currLine, "U)^" . regexRomDir)) {
				romDir := Trim(StrSplit(currLine, "=")[2], " `r`n")
				If (InStr(Rom, romDir)) {
					Break
				}
				Else {
					consoleFound := 0
					configFound := 0
				}
			}
		}
	}


	Return RetVal
}

defaultOverride(System, Game, Rom, SystemObj) {
	sysAliases := systemAliases(System)
	
	RomDir := SystemObj["romDir"]
	NameIndex := SystemObj["nameIndex"]
	ControlArr := objStringToArr(SystemObj["controls"])
	If (!FileExist(RomDir . Game)) {
		Game := nameFromPath(NameIndex, Rom)
	}
	
	Loop % sysAliases.MaxIndex() {
		foundConfig := ReadCFG("C:\AutoHotkey\files\cfg\defaultOverride.txt", sysAliases[A_Index], Game, "")[1]
		If (foundConfig) {
			foundConfig := Trim(foundConfig, " `r`n")
			
			checkConfig := 0
			Loop % ControlArr.MaxIndex() {
				If (foundConfig = ControlArr[A_Index]) {
					checkConfig := 1
					Break
				}	
			}
			
			If (checkConfig != 1) {
				MsgBox, johnny johnny making up controller configs?
			}
			
			Break
		}
	}
	
	If (checkConfig) {
		Return foundConfig
	}
	Else {
		Return ControlArr[2]
	}
}

getSysControlImg(System, Control) {
	Return systemInfo(System, "controlImgDir") . Control . ".png"
}


setSysControlImg(System, Control) {
	FileRead, PauseXAML, C:\Launchbox\PauseThemes\Custom\Default.xaml
	
	ControlImg := getSysControlImg(System, Control)
	
	RegExMatch(PauseXAML
		, "U)<!-- Controls --> *\t*\r\n *\t*<Image .* Source="".*"""
		, BaseString)
	
	ReplaceString := RegExReplace(BaseString, "Source="".*""", "Source=""" . ControlImg . """")
		
	NewXAML := StrReplace(PauseXAML, BaseString, ReplaceString)

	file := FileOpen("C:\Launchbox\PauseThemes\Custom\Default.xaml", "w")
	file.Write(NewXAML)
	file.Close()
}