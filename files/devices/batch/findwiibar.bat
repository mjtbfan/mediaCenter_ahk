@echo off
cd "C:\AutoHotkey\files\devices"
devcon.exe find "USB\VID_057E&PID_0306&REV_0100" > return.txt