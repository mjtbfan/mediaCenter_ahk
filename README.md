# Media Center (Beta)

This repo is for the beta version of my "Media Center" project. This project is designed to make a Windows 10 computer usable as a "video game console" (strictly interfacable with a gamepad) through the use of specific programs (LaunchBox, Kodi, JoyToKey) and the custom scripts & config files in this repo.

This is a beta version using AutoHotKey v~1.1. I plan to redo the codebase using AutoHotKey_H v2 for features such as dynamic imports, dynamic code execution, and multithreading. 
Features of the codebase to be improved out of beta:
- Less scripts running in tandem, rather try to have as much run in a single script w/ additional threads
- Convert xinput handling to "getstate->check state during loop" rather than the current "getstateforbutton" called multiple times during loop
- dyanmic resolution handling instead of hardcoded 1920x1080
- relative paths for imports & script launching
- paths for outside programs being pulled from config files instead of hardcoded
- breaking up helper files into generic helper files & custom user-created helper files for more specific functions
- removing hardcoded emulator launching scripts to create a generic emu launcher that accepts additional code from config files
