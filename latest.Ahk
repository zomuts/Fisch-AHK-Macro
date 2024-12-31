; Change the Control value to whatever your rod's Control value is 
Control := 0.15

; Don't edit anything beyond this point
barWidth := Floor(96 + (Control*326.67))

toggle := false
mouseDown := False
barStart := 247 ; LEFT pixel of the FULL reel bar
barEnd := 570 ; RIGHT pixel of the FULL reel bar
lastPos := 409 - (barWidth/2) ; Last position of the bar, middle of the reel bar

f::  ; When "F" key is pressed
    toggle := !toggle  ; Toggle the state
    if (toggle) {
        ; Start the loop in a separate thread
        SetTimer, Main, 0
    } else {
        ; Stop the loop by setting the timer off
        SetTimer, Main, Off
    }
return

Main:
    global goingRight, barWidth, barStart, barEnd, lastPos, mouseDown, mouseDown
    if (toggle) {
        PixelSearch, FishX, FishY, 246, 533, 569, 533, 0x434b5b, 3, FastRGB
        if (ErrorLevel = 0){ ; ErrorLevel = 0 if fish is detected
            ; If fish is within the bounds of the bar on the left side of the screen
            if (FishX <= (barStart + (barWidth-40))){
                if (mouseDown) {
                    Click Up
                    mouseDown := False ; Update the variable to indicate mouse is not down
                }
                tooltip ALL THE WAY LEFT
            } else if (FishX >= (barEnd - (barWidth - 40))){
                ; Fish is on the right side of the bar, go right
                if (!mouseDown){ 
                    Click Down
                    mouseDown := True
                }
                tooltip ALL THE WAY RIGHT
            } else {
                ; Fish is not at either ends, do special behavior
                ; Detect where the white reel bar is
                PixelSearch, BarX, BarY, 246, 533, 569, 533, 0xf1f1f1, 20, FastRGB ; Checks the screen for a white pixel (the reel bar)
                if (ErrorLevel = 0){
                    ; Bar is visible, fish is in the bar
                    ; This code will try to keep the fish centered
                    lastPos := BarX
                    centerOfBar := BarX + (BarWidth/2)
                    if (FishX >= centerOfBar){ 
                        ; Fish is on the right of the bar, go right to center it
                        tooltip Centering Right
                        ; if (!mouseDown) {
                        
                        Click Down
                        Sleep, 25 + ((FishX - centerOfBar) * 2) ; 25ms of lmb doesnt move the bar
                        Click Up
                        mouseDown := False ; Mouse is down
                        ; }
                    } else if (FishX < centerOfBar){ 
                        ; Fish is on the left of the bar, go left to center it
                        tooltip Centering Left
                        ; if (mouseDown) {
                            Click Up
                            Sleep, 25 + ((centerOfBar - FishX) * 2)
                            Click Down
                            Sleep, 15
                            Click Up
                            mouseDown := False ; Mouse is up
                        ; }
                    }
                } else {
                    ; Bar is not visible, get the fish in the bar
                    if (FishX <= lastPos){ 
                        ; Fish is on the left of the last known pos, go left
                        if (mouseDown) {
                            Click Up
                            mouseDown := False ; Mouse is up
                        }
                        tooltip Lost Bar left
                    } else { 
                        ; Fish is on the right of the last known pos, go right
                        if (!mouseDown) {
                            Click Down
                            mouseDown := True ; Mouse is down
                        }
                        tooltip Lost Bar right
                    }
                }
            }
        } else {
            ; Fish is not on line, cast rod
            Tooltip Casting
            Sleep 1000
            Click, Down, 100, 400
            Sleep 2000
            Click, Up, 100, 400
            Sleep 2000
            ; Begin shaking the line
            Tooltip Shaking
            Send \
            StartTime := A_TickCount
            Loop, {
                Send {down}{enter}
                ; check if there is a white pixel on the screen, detects if your reeling in a fish
                PixelSearch,,, 246, 533, 569, 533, 0xf1f1f1, 20, FastRGB 
                If (ErrorLevel = 0) { 
                    ; 0 if it finds a white pixel, 1 if it doesnt
                    Break
                }
                if (!toggle){
                    Break
                }
                if(A_TickCount - StartTime >= 60000){ ; cancel shaking after 60s, failsafe
                    Break  
                }
                Sleep 50
            }
            ; Fish is on line, restart loop
        }
    }
return

; Press H to resize the roblox window, from Cream's macro
h::
    hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")
    if (hwnd){
        x := A_ScreenWidth
        y := A_ScreenHeight
        WinActivate, ahk_exe RobloxPlayerbeta.exe
        WinMove, ahk_exe RobloxPlayerBeta.exe,, x/2-408, y/2-408, 100, 100
    } else {
        Msgbox Roblox need to be opened
        ExitApp
    }
return


esc::
    ExitApp
return
