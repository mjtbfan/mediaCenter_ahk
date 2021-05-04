@echo off
cd "C:\AutoHotkey\files\devices"
devcon.exe find "USB\VID_0810&PID_E501" > return.txt