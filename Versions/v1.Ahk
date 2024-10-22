#SingleInstance, force
if (A_ScreenDPI*100//96 != 100) {
	Run, ms-settings:display
	msgbox, 0x1030, WARNING!!, % "Your Display Scale seems to be a value other than 100`%. This means the macro will NOT work correctly!`n`nTo change this, right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100`% -> Close and Restart Roblox before starting the macro.", 60
	ExitApp
}

GetRobloxHWND() {
    if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
        return hwnd
}

toggle := false
Control := 0.05
BarWidth := Floor(96 + (Control*326.67))

CastRod(){
    Sleep 2000
    Click, Down, 100, 400
    Sleep 2000
    Click, Up, 100, 400
    Sleep 2000
    Return
}
Shake(){
    Send \
    StartTime := A_TickCount
    Loop, {
        Send {down}{enter}
        PixelSearch,,, 246, 533, 569, 533, 0xf1f1f1, 20, FastRGB ; checks if there is a white pixel on the screen, detects if your reeling in a fish
        If (ErrorLevel = 0) { ; Error level is 0 if it finds a white pixel, 1 if it doesnt
            Break
        }
        if(A_TickCount - StartTime >= 60000){ ; cancel shaking after 60s, failsafe
            Break  
        }
        Sleep 50
    }
    return
}
Reel2(){
    PixelSearch, FishX, FishY, 246, 533, 569, 533, 0x434b5b, 3, FastRGB
    lastX := 246
    if (ErrorLevel = 0){ ; Check if the fish exists
        Loop, { ; This code is very janky and will be redone in the future, just fyi
            PixelSearch, FishX, FishY, 246, 533, 569, 533, 0x434b5b, 3, FastRGB ; Checks the screen for a "fish colored" pixel, finds the blue line
            if (ErrorLevel = 0){ ; Check if the fish exists
                PixelSearch, BarX, BarY, 246, 533, 569, 533, 0xf1f1f1, 20, FastRGB ; Checks the screen for a white pixel (the reel bar)
                if (ErrorLevel = 0){ ; Bar is visible, fish is within bar
                    lastX = BarX
                    BarWidth := Floor(96 + (Control*326.67))
                    end := BarX + (BarWidth)

                    if (FishX > (598-BarWidth)){
                        Click Down
                        tooltip right
                        Loop {
                            PixelSearch, FishX, FishY, 246, 533, 569, 533, 0x434b5b, 3, FastRGB
                            if (ErrorLevel = 0){ ; Check if the fish exists
                                PixelSearch, BarX, BarY, 246, 533, 569, 533, 0xf1f1f1, 20, FastRGB
                                if (ErrorLevel = 0){ ; Bar is visible, fish is within bar
                                    Sleep 5
                                } else {
                                    Break
                                }
                            } else {
                                Break
                            }
                        }
                        Click Up
                    } else if (FishX <= (227 + BarWidth)) {
                        tooltip left
                        Click Up
                    } else if (FishX > BarX) {
                        if (FishX >= (BarX + (BarWidth/2))){
                            Click Down
                            tooltip right
                            Distance := (FishX - BarX)
                            Sleep (Distance * 2)
                            Click Up
                        } else {
                            tooltip left
                            Click Down
                            Distance := (BarX - FishX)
                            Sleep (Distance)
                            Click Up
                        }
                    }
                } else {
                    if (FishX > 408){
                        Click Down
                        tooltip right
                    } else if (FishX > lastX){
                        Click Down
                        Sleep 10
                        tooltip right
                    } else {
                        tooltip left
                        Click Up
                        holding = False
                    }
                }
            } else {
                Break
            }
        }
    }
}
Main:
    if (toggle) {
        PixelSearch,,, 246, 533, 569, 533, 0x434b5b, 3, FastRGB
        if (ErrorLevel = 1){ ; if there is no fish icon on screen
            Tooltip Casting
            CastRod()
            Tooltip Shaking
            Shake()
            Tooltip Reeling
            Reel2()
        }
        ; Small delay to prevent overloading
        Sleep, 50
    }
return

h::
    if GetRobloxHWND() {
        x := A_ScreenWidth
        y := A_ScreenHeight
        WinActivate, ahk_exe RobloxPlayerbeta.exe
        WinMove, ahk_exe RobloxPlayerBeta.exe,, x/2-408, y/2-408, 100, 100
    } else {
        Msgbox Roblox need to be opened
        ExitApp
    }
return

n::
    if (!toggle) {
        toggle := true
        
        ; Start the loop
        SetTimer, Main, 0  ; Start a timer that runs the loop in the background
    }
    else {
        toggle := false
        SetTimer, Main, Off  ; Stop the loop timer
    }
return

esc::
    ExitApp
return
