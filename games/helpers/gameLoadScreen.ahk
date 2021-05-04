#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/gui/infoDialog.ahk

emuLoadScreen(Name) {
	SetTitleMatchMode, 2
	
	ResetLoadingScreen(1)
	
	If (Name = "PPSSPP") {
		UpdateLoadFlag("Waiting for PPSSPPWindows64.exe...")
	}
	Else If (Name = "Citra") {
		UpdateLoadFlag("Waiting for citra-qt.exe...")
	}
	Else If (Name = "EE:") {
		UpdateLoadFlag("Waiting for pcsx2.exe...")
	}
	Else {
		UpdateLoadFlag("Waiting for " Name ".exe...")
	}
}

emuWaitLoop(Name) {
	SetTitleMatchMode, 2

	DetectHiddenWindows, Off
	ExistCount := 0
	Exist := WinExist(Name)
	While (!Exist) {
		Sleep, 10
		Exist := WinExist(Name)
		ResetLoadingScreen(0)
		ExistCount += 1
		
		If ((ExistCount > 2500) && !Exist) {
			UpdateLoadFlag("close")
			Process, Close, GameScript.exe
			Process, Close, EmuLoadScript.exe
		}
	}
}

winLoadScreen(Name) {
	SetTitleMatchMode, 2
	GameType := ""
	
	ResetLoadingScreen(1)
	
	If (InStr(Name, "steam://") || InStr(Name, "twitch") || InStr(Name, "\Origin\")) {
		UpdateLoadFlag("Waiting for Internet Connection...")
		If (!WaitForInternetTimeout(10000)) {
			UpdateLoadFlag("close")
			dedicatedDialog("GenericDialog.exe", "This title requires a working internet connection", 5000, "r", 950)
			Return "kill"
		}
	}
	
	If (InStr(Name, "steam://")) {
		UpdateLoadFlag("Waiting for Steam.exe...")
		If (!ProcessExist("Steam.exe")) {
			Steam("clean")
			Sleep, 5000
		}
		GameType := GameType . "steam"
	}
	Else If (InStr(Name, "twitch")) {
		UpdateLoadFlag("Waiting for Twitch.exe...")
		Run, "twitch://"
		While(!ProcessExist("TwitchAgent.exe"))
		{}
		GameType := GameType . "twitch"
		Sleep, 3000
	}
	Else If (InStr(Name, "\Origin\")) {
		UpdateLoadFlag("Waiting for Origin.exe...")
		GameType := GameType . "origin"
	}
	Else If (InStr(Name, "shell:") 
	|| Name = "D:\Games\Kingdom Hearts 1.5+2.5\Run Game.lnk" 
	|| Name = "D:\Games\Kingdom Hearts 2.8\Run Game.lnk") {
		GameType := GameType . "windows"
	}
	Else {
		UpdateLoadFlag("Now Loading...")
	}
	
	If (Name = "steam://rungameid/235460") {
		Run, "D:\Steam\steamapps\common\METAL GEAR RISING REVENGEANCE\ForceFix.exe"
		WinWait, ForceFix
	}
	Else If (Name = "steam://rungameid/12120" || Name = "steam://rungameid/12110" 
	|| Name = "steam://rungameid/12100" || Name = "steam://rungameid/12082227475992543232") {
		GameType := GameType . "enter"
	}
	Else If (Name = "steam://rungameid/12140" || Name = "steam://rungameid/12150") {
		GameType := GameType . "enter1"
	}
	Else If (Name = "D:\Games\Final Fight LNS\Final Fight LNS Ultimate.lnk") {
		Joy2Key("dirty")
	}
	Else If (Name = "steam://rungameid/12837919107638624256") {
		X360CE("open")
		GameType := GameType . "x360ce"
	}
	Else {
		Joy2Key("clean")
	}
	
	If (Name = "steam://rungameid/15336638291977961472") {
		GameType := GameType . "ff7"
	}
	
	Sleep, 250

	Return GameType
}

winWaitLoop(Name, Type) {
	SetTitleMatchMode, 2
	WinGame := winGamePID()
	Count := 0
	
	While(WinGame = 0) {
		ResetLoadingScreen(0)
		
		If (Mod(Count, 8) = 0) {
			checkWinGames(Name)
		}
		
		If (!WinExist("Updating ") && !WinExist("Ready - ")
		&& !WinShown("ahk_exe Origin.exe") && !WinShown("ahk_exe Twitch.exe")) {
			Count += 1
			If (Count > 100) {
				If (InStr(Type, "steam")) {
					UpdateLoadFlag("Reseting Steam.exe...")
					Steam("dirty")
					UpdateLoadFlag("Waiting for Steam.exe...")
					Sleep, 3000
				}
				
				Run, %Name%
				Sleep, 1000
				
				Count := 0
			}
				
		} 
		Else If (WinShown("Updating ")) {
			If (allJOY(XInputController, 2)) {
				WinClose, Updating
				Steam("close")
				UpdateLoadFlag("close")
				
				Process, Close, GameScript.exe
			}
		}
		Sleep, 250
		WinGame := winGamePID()
	}
	
	UpdateLoadFlag("close")
	
	ResetLoadingScreen(0)

	If (!InStr(Type, "windows")) {
		While(!WinShown("ahk_pid" . WinGame)) {
			Sleep, 250
			
			WinGame := winGamePID()
		}
	}
	If (Name = "D:\Games\Melty Blood\MBAA.lnk") {
		WinWait, Startup
		While (WinShown("Startup Menu")) {
			WinActivate, Startup
			Sleep, 100
			Send {Enter}
		}
	}
	Else If (Name = "D:\Games\Boshy\I Wanna Be The Boshy.lnk") {
		WinActivate, Boshy
		Sleep, 100
		WinMove, Boshy,, 320, 50
		WinSet, Style, -0xC40000, Boshy
	}
	Else If (Name = "steam://rungameid/296470") {
		WinActivate, Mount
		Sleep, 100
		WinMove, Mount,, 0, 0, 1920, 1080
		WinSet, Style, -0xC40000, Mount
	}
	
}

winCloseScreen(Name, Type) {
	SetTitleMatchMode, 2
	DetectHiddenWindows, On
	MouseMove, 9999, 9999, 0
	ResetLoadingScreen(1)

	UpdateLoadFlag("Now Loading...")
	Sleep, 750
	
	If (Name = "steam://rungameid/235460") {
		WinClose, ForceFix
	}
	Else If (Name = "D:\Games\SORR\SorRFS.lnk") {
		Process, Close, SorRFS.exe
	}
	Else If ("D:\Games\Grand Theft Auto V\PlayGTAV.lnk") {
		WinClose, Rockstar
	}
	
	If (InStr(Type, "borderless"))  {
		WinClose, Borderless
	}
	
	If (InStr(Type, "x360ce"))  {
		X360CE("close")
	}

	If (InStr(Type, "twitch")) {
		Sleep, 500
		WinClose, Twitch
		Sleep, 500
	}
	
	If (InStr(Type, "ff7")) {
		Sleep, 2000
		While(ProcessExist("7th Heaven.exe")) {
			WinClose, 7th Heaven
			Sleep, 1000
		}
	}

	If (InStr(Type, "origin")) {
		FuckOrigin := 0
		While (ProcessExist("Origin.exe")) {
			If (WinShown("Origin")) {
				WinActivate, Origin
				Sleep, 50
				Send {alt down}
				Sleep, 50
				Send o
				Sleep, 50
				Send {alt up}
				Sleep, 50
				Send {up}
				Sleep, 100
				Send {enter}
				Sleep, 500
			}
			
			FuckOrigin += 1
			If (FuckOrigin > 25) {
				Process, Close, Origin.exe
			}
			Sleep, 500
		}
	}
	
	UpdateLoadFlag("close")
	Sleep, 1000
}