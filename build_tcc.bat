@echo off
mkdir .build 2>nul
tcc -nostdlib -DWinMainCRTStartup=_start -o .build/game.exe platform/main_windows.c -lkernel32 -Wl,-subsystem,windows
