@echo off

:: SpotX launcher.
:: Runs the LOCAL, reviewed SpotX.ps1 next to this file - nothing is downloaded and executed from the web.
:: Do not run this as administrator; it doesn't need it.

:: Options, separated by spaces. See the param() block at the top of SpotX.ps1 for all of them.
::   -hardware_acceleration_off  no GPU rendering (usually less memory, slightly more CPU for animations; sound unaffected)
::   -DisableStartup             Spotify doesn't launch with Windows, so it uses no RAM until you open it
set param=-new_theme -block_update_on -hardware_acceleration_off -DisableStartup

"%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0SpotX.ps1" %param%
if errorlevel 1 pause
exit /b
