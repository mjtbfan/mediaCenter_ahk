@echo off
cd "C:\AutoHotkey\files\devices"
devcon.exe find "USB\VID_0810&PID_0001" > return.txt