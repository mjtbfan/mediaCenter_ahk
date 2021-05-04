; Stripped down and modified version of xinput.h
XINPUT_GAMEPAD_DPAD_UP          := 0x0001
XINPUT_GAMEPAD_DPAD_DOWN        := 0x0002
XINPUT_GAMEPAD_DPAD_LEFT        := 0x0004
XINPUT_GAMEPAD_DPAD_RIGHT       := 0x0008
XINPUT_GAMEPAD_START            := 0x0010
XINPUT_GAMEPAD_BACK             := 0x0020
XINPUT_GAMEPAD_LEFT_THUMB       := 0x0040
XINPUT_GAMEPAD_RIGHT_THUMB      := 0x0080
XINPUT_GAMEPAD_LEFT_SHOULDER    := 0x0100
XINPUT_GAMEPAD_RIGHT_SHOULDER   := 0x0200
XINPUT_GAMEPAD_GUIDE            := 0x0400 ; Undocumented
XINPUT_GAMEPAD_A                := 0x1000
XINPUT_GAMEPAD_B                := 0x2000
XINPUT_GAMEPAD_X                := 0x4000
XINPUT_GAMEPAD_Y                := 0x8000

ERROR_DEVICE_NOT_CONNECTED      := 1167

XInput_Terminate(xLib) {
	return DllCall("FreeLibrary","uint",xLib)
}

XInput_Initialize(dll = "xinput1_3.dll"){
   if (!xLib := DllCall("LoadLibrary", "str", dll)){
       Msgbox ERROR: Unable to load %dll%!
       ExitApp
   }
   return xLib
}

XInput_GetState(UserIndex, xLib) {
   global ERROR_DEVICE_NOT_CONNECTED

   VarSetCapacity(XINPUT_STATE, 16, 0)
   xAddress := DllCall("GetProcAddress", "Uint", xLib, "Uint", 100)
   xResult := DllCall(xAddress, "Uint", userIndex, "Ptr", &XINPUT_STATE) ; assuming this dllcall is XInputGetStateEx

   if (xResult == ERROR_DEVICE_NOT_CONNECTED)
      return -1

   return {
    (Join,
        dwPacketNumber: NumGet(XINPUT_STATE,  0, "UInt")
        wButtons:       NumGet(XINPUT_STATE,  4, "UShort")
        bLeftTrigger:   NumGet(XINPUT_STATE,  6, "UChar")
        bRightTrigger:  NumGet(XINPUT_STATE,  7, "UChar")
        sThumbLX:       NumGet(XINPUT_STATE,  8, "Short")
        sThumbLY:       NumGet(XINPUT_STATE, 10, "Short")
        sThumbRX:       NumGet(XINPUT_STATE, 12, "Short")
        sThumbRY:       NumGet(XINPUT_STATE, 14, "Short")
    )}
}