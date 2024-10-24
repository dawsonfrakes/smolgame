@echo off
mkdir .build 2>nul
where /q cl || call vcvars64.bat
cl -Fe.build\game.exe -nologo -W4 -WX -Z7 -Oi -J -EHa- -GR- -GS- -Gs0x10000000^
 platform\main_windows.c kernel32.lib^
 -link -incremental:no -nodefaultlib -subsystem:windows^
 -stack:0x100000,0x100000 -heap:0,0
del *.obj 2>nul
