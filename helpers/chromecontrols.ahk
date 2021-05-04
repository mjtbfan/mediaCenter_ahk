#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2

SplashImage, C:\Assets\missing_texture.png, b h1080 w480 x1440 y0
Sleep, 100
WinActivate

Loop {
	Sleep, 1000
}