#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

gameVersions(Name) {
	verArray := ReadSimpleCFG("C:\AutoHotkey\files\games\gameVersions.txt", Name)
	
	OG := Name
	OGReplace := ""
	OGOverwrite := ""
	OtherArray := []
	
	Loop % verArray.MaxIndex() {	
		If (SubStr(verArray[A_Index], 1, 1) = "&") {
			OGReplace := Trim(verArray[A_Index], " &`t`r`n") 
		}
		Else If (SubStr(verArray[A_Index], 1, 1) = "!") {
			OGOverwrite := Trim(verArray[A_Index], " !`t`r`n")
		}
		Else {
			OtherArray.Push(verArray[A_Index])
		}
	}
	
	RetArray := []
	If (OGOverwrite) {
		RetArray.Push(OGOverwrite)
	}
	
	If (OGReplace) {
		RetArray.Push(OGReplace)
	}
	Else {
		RetArray.Push(OG)
	}
	
	Loop % OtherArray.MaxIndex() {
		RetArray.Push(OtherArray[A_Index])
	}
	
	Return RetArray
}

gameReplace(Rom, RomDir, Game, NewGame, NameIndex, System, Exts) {
	Exts := objStringToArr(Exts)

	sysAliArr := ReadSimpleCFG("C:\AutoHotkey\files\games\gameAliases.txt", System)
	NewRom := ""
	
	Loop % sysAliArr.MaxIndex() {
		CleanName := StrReplace(NewGame, "[" . System . "] ")
		nameAliArr := StrSplit(sysAliArr[A_Index], "=")
		
		If (CleanName = Trim(nameAliArr[1], " `t`r`n")) {
			NewRom := Trim(nameAliArr[2], " `t`r`n")
			Break
		}
	}

	
	RomQuickReplace := StrReplace(Rom, Game, NewGame)
	
	If (FileExist(RomQuickReplace)) {
		Return RomQuickReplace
	}
	Else If (!RomDir && NewRom) {
		Return NewRom
	}
	Else If (RomDir && NewRom) {
		Return RomDir . NewRom
	}
	Else {
		NewRom := RegExReplace(NewGame, "U)^\[.*\] ")
		
		RetVal := RomDir . NewRom
		If (!FileExist(RetVal)) {
			Loop % Exts.MaxIndex() {
				temp := RetVal . Exts[A_Index]
				
				If (FileExist(temp)) {
					RetVal := temp
					Break
				}
			}
		}
		
		Return RetVal
	}
}
