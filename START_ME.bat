@echo off
cd C:\Users\jqisr\anaconda3\condabin
call activate.bat WM_env
echo.
echo Starting up base wavemeter program...
start "" "C:\Program Files (x86)\HighFinesse\Wavelength Meter WS7 1053\wlm_ws7.exe" 
timeout /t 15
echo.
echo on
cd "C:\Program Files\Wavemeter\WavemeterDashboard"
echo Starting up wavemeter feedback controller...
start pythonw main.py
timeout /t 2
echo.