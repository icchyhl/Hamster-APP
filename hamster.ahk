Collection of Hot Keys Used

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

/*
Key Mappings
> Printscreen changed to Apps key
> Windows + Printscreen for actual printscreen
> ` changed to backspace
> Windows + ` for actual `
> Capslock changed to NULL key
> Windows + Capslock for actual capslock

Hot Keys
> printscreen + m = new outlook email
> printscreen + g = google
> printscreen + n = notepad
> printscreen + c = calculator
> alt + v = paste values in clipboard without copied formatting
> printscreen + / = makes a window transparent
> printscreen + shift + / = undo a transparent window
> printscreen + . = sets a window to always be on top
> printscreen + shift + . = undo "sets a window to always be on top"
> Alt + left mouse click = reposition a window without activating it and can be clicked anywhere on window
*/

printscreen & F8::
{
loop
{
send a
sleep 1000
}
printscreen & F9:: pause
printscreen & F10:: Reload
}
Return

PrintScreen & m:: Run, "C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE" /c ipm.note ;opens outlook email

$PrintScreen::Send {AppsKey} ;change printscreen to Appskey (right clicking)
$#PrintScreen::Send #{PrintScreen} ;windows + printscreen = Actual Print Screen
$`:: Send {backspace} ;change tilde to backspace
$!`:: Send `` ;add alt+tilde to tilde
PrintScreen & g:: Run, http://www.google.com/search?q ;% ;this runs google

!v::
{
Clipboard = %Clipboard%
ClipSaved := ClipboardAll
SendInput, ^v
Sleep, 250
Clipboard := ClipSaved
}
return

PrintScreen & n:: ;runs note pad
Run, Notepad
return
PrintScreen & c:: ;runs calculator
Run calc.exe
return

Capslock:: ;set capslock to NULL key, activate by windows + capslock
If GetKeyState("LWin")
  Send {Capslock}
else
  Send {Shift}
Return

PrintScreen & /::
If NOT IsWindow(WinExist("A"))
  Return
If GetKeyState("shift")
  Winset, Transparent, OFF, A
else
  Winset, Transparent, 128, A
Return

PrintScreen & .::
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
CoordMode, Mouse ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin%
if EWD_WinState = 0 ; Only if the window isn't maximized
  SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U ; Button has been released, so drag is complete.
{
  SetTimer, EWD_WatchMouse, off
  return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D ; Escape has been pressed, so drag is cancelled.
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
SetWinDelay, -1 ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return
