#SingleInstance Force ; The script will Reload if launched while already running
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases
#KeyHistory 0 ; Ensures user privacy when debugging is not needed
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability

; Globals
MAX_DESKTOP_COUNT := 9
desktop_count := 3
curr_desktop := 1
last_desktop := 1

; DLL
virtual_desktop_accessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\VirtualDesktopAccessor.dll", "Ptr")
global is_window_on_curr_desktop := DllCall("GetProcAddress", Ptr, virtual_desktop_accessor, AStr, "IsWindowOnDesktopNumber", "Ptr")
global move_window_to_desktop := DllCall("GetProcAddress", Ptr, virtual_desktop_accessor, AStr, "MoveWindowToDesktopNumber", "Ptr")

; Main
SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %desktop_count% current: %curr_desktop%

#Include %A_ScriptDir%\user_config.ahk
return

;
; This function examines the registry to build an accurate list of the current virtual desktops and which one we're currently on.
; Current desktop UUID appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops
; List of desktops appears to be in HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops
;
mapDesktopsFromRegistry() 
{
    global curr_desktop, desktop_count, MAX_DESKTOP_COUNT

    ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    id_length := 32
    session_id := getSessionId()
    if (session_id) {
        RegRead, curr_desktop_id, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%session_id%\VirtualDesktops, CurrentVirtualDesktop
        if (curr_desktop_id) {
            id_length := StrLen(curr_desktop_id)
        } else {
            OutputDebug, Error getting desktop ID; assuming ID length is %id_length%
        }
    }

    ; Get a list of the UUIDs for all virtual desktops on the system
    RegRead, desktop_list, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
    if (desktop_list) {
        desktop_list_length := StrLen(desktop_list)
        ; Figure out how many virtual desktops there are
        desktop_count := floor(desktop_list_length / id_length)
    }
    else {
        desktop_count := 1
    }

    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
    i := 0
    while (curr_desktop_id and i < desktop_count) {
        start_pos := (i * id_length) + 1
        desktop_id_iter := SubStr(desktop_list, start_pos, id_length)
        OutputDebug, The iterator is pointing at %desktop_id_iter% and count is %i%.

        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (desktop_id_iter = curr_desktop_id) {
            curr_desktop := i + 1
            OutputDebug, Current desktop number is %curr_desktop% with an ID of %desktop_id_iter%.
            break
        }
        i++
    }

    ; Ensure there are always max number of virtual desktops available
    while (desktop_count < MAX_DESKTOP_COUNT) {
        Send, #^d
        desktop_count++
        OutputDebug, [create] desktops: %desktop_count% current: %curr_desktop%
    }
}

;
; This functions finds out ID of current session.
;
getSessionId()
{
    process_id := DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process ID: %ErrorLevel%
        return
    }
    OutputDebug, Current Process Id: %process_id%

    DllCall("ProcessIdToSessionId", "UInt", process_id, "UInt*", session_id)
    if ErrorLevel {
        OutputDebug, Error getting session ID: %ErrorLevel%
        return
    }
    OutputDebug, Current Session ID: %session_id%
    return session_id
}

switchToDesktop(target_desktop)
{
    global curr_desktop, desktop_count, last_desktop
    mapDesktopsFromRegistry()

    ; Don't attempt to switch to an invalid desktop
    if (target_desktop > desktop_count || target_desktop < 1) {
        OutputDebug, [invalid] target: %target_desktop% current: %curr_desktop%
        return
    } 
    
    ; Toggle between current and last desktop by repeating desktop number
    if (target_desktop == curr_desktop && curr_desktop != last_desktop) {
        target_desktop := last_desktop
    }

    last_desktop := curr_desktop

    ; Fixes the issue of active windows in intermediate desktops capturing the switch shortcut and therefore delaying or stopping the switching sequence. This also fixes the flashing window button after switching in the taskbar. More info: https://github.com/pmb6tz/windows-desktop-switcher/pull/19
    WinActivate, ahk_class Shell_TrayWnd

    ; Go right until we reach the desktop we want
    while(curr_desktop < target_desktop) {
        Send {LWin down}{LCtrl down}{Right down}{LWin up}{LCtrl up}{Right up}
        curr_desktop++
        OutputDebug, [right] target: %target_desktop% current: %curr_desktop%
    }

    ; Go left until we reach the desktop we want
    while(curr_desktop > target_desktop) {
        Send {LWin down}{LCtrl down}{Left down}{Lwin up}{LCtrl up}{Left up}
        curr_desktop--
        OutputDebug, [left] target: %target_desktop% current: %curr_desktop%
    }

    ; Makes the WinActivate fix less intrusive
    Sleep, 50
    focusTheForemostWindow(target_desktop)
}

focusTheForemostWindow(target_desktop) {
    foremost_window_id := getForemostWindowId(target_desktop)
    if isWindowNonMinimized(foremost_window_id) {
        WinActivate, ahk_id %foremost_window_id%
    }
}

isWindowNonMinimized(window_id) {
    WinGet MMX, MinMax, ahk_id %window_id%
    return MMX != -1
}

getForemostWindowId(n)
{
    n := n - 1 ; Desktops start at 0, while in script it's 1 to match keys

    ; win_id_list contains a list of windows IDs ordered from the top to the bottom for each desktop.
    WinGet win_id_list, list
    Loop % win_id_list {
        window_id := % win_id_list%A_Index%
        is_window_on_desktop := DllCall(is_window_on_curr_desktop, UInt, window_id, UInt, n)
        ; Select the first (and foremost) window which is in the specified desktop.
        if (is_window_on_desktop == 1) {
            return window_id
        }
    }
}

moveCurrentWindowToDesktop(target_desktop) {
    WinGet, active_hwnd, ID, A
    DllCall(move_window_to_desktop, UInt, active_hwnd, UInt, target_desktop - 1)
    switchToDesktop(target_desktop)
}