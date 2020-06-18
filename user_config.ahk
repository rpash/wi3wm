; ====================
; === INSTRUCTIONS ===
; ====================
; - Any lines starting with ; are ignored
; - After changing this config file run script file "desktop_switcher.ahk"
; - Every line is in the format HOTKEY::ACTION
; - Switch the modifier symbol (list below) with the one you want. Default is Windows key (#)

; === SYMBOLS ===
; !   <- Alt
; +   <- Shift
; ^   <- Ctrl
; #   <- Win
; For more, visit https://autohotkey.com/docs/Hotkeys.htm

; It is recommended to disable animations for window and virtual desktop transitions

; ===========================
; === END OF INSTRUCTIONS ===
; ===========================

#1::switchToDesktop(1)
#2::switchToDesktop(2)
#3::switchToDesktop(3)
#4::switchToDesktop(4)
#5::switchToDesktop(5)
#6::switchToDesktop(6)
#7::switchToDesktop(7)
#8::switchToDesktop(8)
#9::switchToDesktop(9)

#Numpad1::switchToDesktop(1)
#Numpad2::switchToDesktop(2)
#Numpad3::switchToDesktop(3)
#Numpad4::switchToDesktop(4)
#Numpad5::switchToDesktop(5)
#Numpad6::switchToDesktop(6)
#Numpad7::switchToDesktop(7)
#Numpad8::switchToDesktop(8)
#Numpad9::switchToDesktop(9)

#+1::moveCurrentWindowToDesktop(1)
#+2::moveCurrentWindowToDesktop(2)
#+3::moveCurrentWindowToDesktop(3)
#+4::moveCurrentWindowToDesktop(4)
#+5::moveCurrentWindowToDesktop(5)
#+6::moveCurrentWindowToDesktop(6)
#+7::moveCurrentWindowToDesktop(7)
#+8::moveCurrentWindowToDesktop(8)
#+9::moveCurrentWindowToDesktop(9)