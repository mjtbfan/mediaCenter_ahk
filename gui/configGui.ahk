#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

#SingleInstance force
SetTitleMatchMode, 2

#Include C:/AutoHotkey/helpers/tools.ahk
#Include C:/AutoHotkey/games/helpers/emuConfig.ahk

emuConfigScreen(System, VersionArray, ControlArray) {

	global
	
	MouseMove, 9999, 9999, 0
	
	GUIName := System . " Configurator"
	GUIReturnVar := 0

	Gui, -border
	Gui, Color, 000000

	Gui, Font, cFFFFFF s40 q4 bold, Roboto
	Gui, Add, Text, x20 y20, %GUIName%

	Gui, Font, cFFFFFF s30 q4 bold, Roboto
	Gui, Add, Text, x20 y110, Game Version
	Gui, Add, Text, x740 y110, Game Controls

	Gui, Font, cFFFFFF s28 q4 bold, Roboto
	Gui, Add, Text, x80 y644, Launch Game
	Gui, Add, Text, x535 y644, View Controls
	Gui, Add, Text, x965 y644, Back
	Gui, Add, Picture, x10 y630 w70 h-1, C:\Assets\Controllers\Xbox\XboxOne_Menu.png
	Gui, Add, Picture, x460 y630 w70 h-1, C:\Assets\Controllers\Xbox\XboxOne_X.png
	Gui, Add, Picture, x895 y630 w70 h-1, C:\Assets\Controllers\Xbox\XboxOne_B.png

	Gui, Font, cFFFFFF s22 q4 bold, Roboto
	
	Gui, Add, ListView, vGUIVersionSelect -Hdr BackgroundBlack x15 y170 w705 h450 , Version

	Loop % VersionArray.MaxIndex()
	{
		If (A_Index = 1) {
			LV_Add("+Select +Focus", RegExReplace(VersionArray[A_index], "[.][a-zA-Z0-9]{2,6}$"))
		}
		Else {
			LV_Add("", RegExReplace(VersionArray[A_index], "[.][a-zA-Z0-9]{2,6}$"))
		}
		
	}
	
	; Removes Horizontal Scrollbar if more than 11 versions
	If (LV_GetCount() > 11) {
		LV_ModifyCol(1,684)
	}

	Gui, Add, ListView, vGUIControlSelect -Hdr BackgroundBlack x735 y170 w330 h450, Control

	ControlArray := objStringToArr(ControlArray)
	Loop % ControlArray.MaxIndex()
	{
		If (A_Index = 1) {
			LV_Add("+Select", ControlArray[A_index])
		}
		Else {
			LV_Add("", ControlArray[A_index])
		}
		
	}

	Gui, show, w1080 h720, configurator.ahk
	
	Hotkey, Right, ConfigRight, On
	Hotkey, Left, ConfigLeft, On
	Hotkey, Enter, ConfigEnter, On
	Hotkey, Backspace, ConfigBackspace, On
	Hotkey, RShift, ConfigShift, On
	Hotkey, RShift UP, ConfigShiftU, On
	
	Gui, ListView, GUIVersionSelect
	GUIPosArray := [VersionArray.MaxIndex()]
	
	
	OGControlArray := ControlArray
	OLDReset := 0
	NEWReset := 0
	
	GUISysSelected := {}
	
	While (GUIReturnVar = 0) {
		Sleep, 50
		
		Gui, ListView, GUIVersionSelect
		GUIVersionSelected := LV_GetNext()
		GUINewSys := emuFromName(VersionArray[GUIVersionSelected])
		GUIControlToSelect := 1
		
		Gui, ListView, GUIControlSelect
		GUIControlSelected := LV_GetNext()
		If (GUINewSys) {
		
			If (OLDReset = 0) {
				GUISysSelected["default"] := GUIControlSelected
			}
			Else If (GUISysSelected[emuFromName(VersionArray[OLDReset])]) {
				GUISysSelected[emuFromName(VersionArray[OLDReset])] := GUIControlSelected
			}
			
			If (!GUISysSelected[GUINewSys]) {
				GUISysSelected[GUINewSys] := 1
			}
			
			GUIControlToSelect := GUISysSelected[GUINewSys]
			ControlArray := objStringToArr(systemInfo(GUINewSys, "controls"))
			NEWReset := GUIVersionSelected
			
		}
		Else {		
			NEWReset := 0
			GUINewSys := 0
		}
		
		If (OLDReset != NEWReset) {
			OLDReset := NEWReset
			
			If (NEWReset = 0) {
				ControlArray := OGControlArray
				GUIControlToSelect := GUISysSelected["default"]
			}
			
			Gui, ListView, GUIControlSelect
			LV_Delete()
			
			Loop % ControlArray.MaxIndex()
			{
				If (GUIControlToSelect = A_Index) {
					LV_Add("+Select +Focus", ControlArray[A_index])
				}
				Else {
					LV_Add("", ControlArray[A_index])
				}
				
			}
		}
	}
	
	Gui, destroy
	
	Hotkey, Right, ConfigRight, Off
	Hotkey, Left, ConfigLeft, Off
	Hotkey, Enter, ConfigEnter, Off
	Hotkey, Backspace, ConfigBackspace, Off
	Hotkey, RShift, ConfigShift, Off
	Hotkey, RShift UP, ConfigShiftU, Off
	
	WinActivate, master.ahk

	Return GUIReturnVar
	
	ConfigRight:
		Gui, ListView, GUIControlSelect
		GUIControlSelected := LV_GetNext()
		
		GuiControl, Focus, GUIControlSelect
		
		LV_Modify(GUIControlSelected, "+Focus")

		Return

	ConfigLeft:
		Gui, ListView, GUIVersionSelect
		GUIVersionSelected := LV_GetNext()
		
		GuiControl, Focus, GUIVersionSelect
		
		LV_Modify(GUIVersionSelected, "+Focus")

		Return
	
	ConfigShift:
		ImgControlSys := emuFromName(VersionArray[GUIVersionSelected])
		If (!ImgControlSys) {
			ImgControlSys := System
		}
		
		If (GUINewSys) {
			ImgControlCon := getSysControlImg(GUINewSys, ControlArray[GUIControlSelected])
		}
		Else {
			ImgControlCon := getSysControlImg(System, ControlArray[GUIControlSelected])
		}
		
		SplashImage, 1:%ImgControlCon%, b w1080 h720

		Return
		
	ConfigShiftU:
		SplashImage, 1:Off
		
		Return

	ConfigEnter:
		Gui, ListView, GUIVersionSelect
		GUIVersionSelected := LV_GetNext()
		
		Gui, ListView, GUIControlSelect
		GUIControlSelected := LV_GetNext()
		
		GUIReturnVar := [VersionArray[GUIVersionSelected], ControlArray[GUIControlSelected]]

		Return

	ConfigBackspace:
		ExitApp
		
		Return
}