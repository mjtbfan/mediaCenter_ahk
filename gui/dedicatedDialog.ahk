#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance force
SetTitleMatchMode, 2

#Include C:/AutoHotkey/gui/infoDialog.ahk

infoDialog(A_Args[1], A_Args[2], A_Args[3], A_Args[4])

ExitApp