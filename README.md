# i3wm behavior for Windows
An AutoHotkey script for Windows that lets a user switch virtual desktops by pressing <kbd>Super</kbd> and a number row key at the sime time (e.g. <kbd>Super</kbd> + <kbd>2</kbd> to switch to Desktop 2). This is meant to mimic a (very small) subset the behavior of [i3wm](https://github.com/i3/i3), the best window manager.

By default the <kbd>Super</kbd> key is set to the <kbd>Windows</kbd> key, however this can be changed by modifying `user_config.ahk`.

## Running
[Install AutoHotkey](https://autohotkey.com/download/) v1.1 or later, then run the `wi3wm.ahk` script (open with AutoHotkey if prompted). You can disable the switching animation by opening "Adjust the appearance and performance of Windows" and then unselecting the checkmark "Animate windows when minimizing and maximizing".

### Notes about Windows 1809/1903≤ Updates
This project relies partly on [VirtualDesktopAccessor.dll](https://github.com/Ciantic/VirtualDesktopAccessor) (for moving windows to other desktops). This binary is included in this repository for convenience, and was recently updated to work with the 1809/1903≤ updates. 

If a future Windows Update breaks the DLL again and updating your files from this repository doesn't work, you could try [building the DLL yourself](https://github.com/Ciantic/VirtualDesktopAccessor) (given that it was since updated by its' creators).

## Customizing Hotkeys
To change the key mappings, modify the `user_config.ahk` script and then run `wi3wm.ahk` (program will restart if it's already running). Note, `!` corresponds to <kbd>Alt</kbd>, `+` is <kbd>Shift</kbd>, `#` is <kbd>Win</kbd>, and `^` is <kbd>Ctrl</kbd>. A more detailed description of hotkeys can be found [here](https://autohotkey.com/docs/Hotkeys.htm). The syntax of the config file is `HOTKEY::ACTION`. Here are some examples of the customization options. 

Single line of code example | Meaning
--- | ---
`!2::switchToDesktop(2)`| **Hotkey:** <kbd>Alt</kbd> + <kbd>2</kbd><br>**Action:** Switch to desktop 2
`#!3::switchToDesktop(3)` | **Hotkey:** <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>3</kbd><br>**Action:** Switch to desktop 3
`CapsLock & 4::switchToDesktop(4)` | **Hotkey:** <kbd>Capslock</kbd> + <kbd>4</kbd><br>**Action:** Switch to desktop 4<br>*(& is necessary when using a non-modifier key such as <kbd>CapsLock</kbd>)*
`#+2::moveCurrentWindowToDesktop(2)` | **Hotkey:** <kbd>Win</kbd> + <kbd>Shift</kbd> + <kbd>2</kbd><br>**Action:** Move current window to desktop 2
`^space::send, #{tab} ` | **Hotkey:** <kbd>Ctrl</kbd> + <kbd>Space</kbd><br>**Action:** Open Desktop Manager by sending <kbd>Win</kbd> + <kbd>Tab</kbd>

A more detailed description of hotkeys can be found here: [AutoHotkey docs](https://autohotkey.com/docs/Hotkeys.htm).<br>
After any changes to the configuration the program needs to be closed and opened again.

## Running on boot

You can make the script run on every boot with either of these methods.

### Simple (Non-administrator method)

1. Press <kbd>Win</kbd> + <kbd>R</kbd>, enter `shell:startup`, then click <kbd>OK</kbd>
2. Create a shortcut to the `wi3wm.ahk` file here

### Advanced (Administrator method)

Windows prevents hotkeys from working in windows that were launched with higher elevation than the AutoHotKey script (such as CMD or Powershell terminals that were launched as Administrator). As a result, the hotkeys will only work within these windows if the script itself is `Run as Administrator`, due to the way Windows is designed. 

You can do this by creating a scheduled task to invoke the script at logon. You may use 'Task Scheduler', or create the task in powershell as demonstrated.
```
# Run the following commands in an Administrator powershell prompt. 
# Be sure to specify the correct path to your wi3wm.ahk file. 

$A = New-ScheduledTaskAction -Execute "PATH\TO\wi3wm.ahk"
$T = New-ScheduledTaskTrigger -AtLogon
$P = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask Windowsi3WM -InputObject $D
```

The task is now registered and will run on the next logon, and can be viewed or modified in 'Task Scheduler'. 

## Credits

- Thanks to [Ciantic/VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor) (DLL) and [sdias/win-10-virtual-desktop-enhancer](https://github.com/sdias/win-10-virtual-desktop-enhancer) (DLL usage samples), this code can now move windows between desktops.
- Thanks to [pmb6tz/windows-desktop-switcher](https://github.com/pmb6tz/windows-desktop-switcher) for providing the AutoHotkey script to change desktops which was modified to create this script.

## Other
To see debug messages, download [SysInternals DebugView](https://technet.microsoft.com/en-us/sysinternals/debugview).

This script is intended to be lightweight in order to prioritize performance and robustness. For more advanced features (such as configuring different wallpapers on different desktops) check out https://github.com/sdias/win-10-virtual-desktop-enhancer.
