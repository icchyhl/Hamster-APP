#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

/*
Key Mappings
> RALT changed to Apps key
> Windows + RALT for actual RALT
> ` changed to backspace
> Windows + ` for actual `
> Capslock changed to NULL key
> Windows + Capslock for actual capslock

Hot Keys
> RALT + s = snippet tool
> RALT + m = new outlook email
> RALT + g = google
> RALT + e = Excel
> RALT + n = notepad
> RALT + c = calculator
> alt + v = paste values in clipboard without copied formatting
> RALT + / = makes a window transparent
> RALT + shift + / = undo a transparent window
> RALT + . = sets a window to always be on top
> RALT + shift + . = undo "sets a window to always be on top"
> Alt + left mouse click = reposition a window without activating it and can be clicked anywhere on window
*/

RALT & F8::
{
	loop
	{
	send a
	sleep 1000
	}
RALT & F9:: pause
RALT & F10:: Reload
}
Return

RALT & m:: Run, "C:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE" /c ipm.note ;opens outlook email

$RALT::Send {AppsKey} ;change RALT to Appskey (right clicking)
$#RALT::Send #{RALT} ;windows + RALT = Actual Print Screen
$`:: Send {backspace} ;change tilde to backspace
$!`:: Send `` ;add alt+tilde to tilde
RALT & g:: Run, http://www.google.com/search?q ;% ;this runs google

!v:: 
{
Clipboard = %Clipboard% 
ClipSaved := ClipboardAll 
SendInput, ^v 
Sleep, 250 
Clipboard := ClipSaved 
}
return

RALT & s:: ;runs snipping tool
Run, "C:\Windows\System32\SnippingTool.exe"
sleep 300
WinWaitActive, Snipping Tool, , 1
if ErrorLevel
{
    sleep 10
    return
}
else
    send ^n
return
RALT & n:: ;runs note pad
Run, Notepad
return
RALT & c:: ;runs calculator
Run calc.exe
return
RALT & e:: ;runs excel
Run excel.exe /n /e /x
return

Capslock:: ;set capslock to NULL key, activate by windows + capslock
If GetKeyState("LWin")
   Send {Capslock}
else
   Send {Shift}
Return

RALT & /::
If NOT IsWindow(WinExist("A"))
   Return
If GetKeyState("shift")
   Winset, Transparent, OFF, A
else
   Winset, Transparent, 128, A
Return


RALT & .::
If NOT IsWindow(WinExist("A"))
   Return
WinGetTitle, TempText, A
If GetKeyState("shift")
{
   WinSet AlwaysOnTop, Off, A
   If (SubStr(TempText, 1, 2) = "† ")
      TempText := SubStr(TempText, 3)
}
else
{
   WinSet AlwaysOnTop, On, A
   If (SubStr(TempText, 1, 2) != "† ")
      TempText := "† " . TempText ;chr(134)
}
WinSetTitle, A, , %TempText%
Return


;This checks if a window is, in fact a window.
;As opposed to the desktop or a menu, etc.
IsWindow(hwnd) 
{
   WinGet, s, Style, ahk_id %hwnd% 
   return s & 0xC00000 ? (s & 0x80000000 ? 0 : 1) : 0
   ;WS_CAPTION AND !WS_POPUP(for tooltips etc) 
}


Alt & LButton:: ;this is to use ALT + left mouse click to move a window position
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
if EWD_WinState = 0  ; Only if the window isn't maximized 
    SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
    SetTimer, EWD_WatchMouse, off
    return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
    SetTimer, EWD_WatchMouse, off
    WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
    return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return