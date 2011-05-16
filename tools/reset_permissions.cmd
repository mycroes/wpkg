@echo off

echo Please note that subinacl should be in this directory

VER | findstr /il "5.1" > nul
IF %ERRORLEVEL% EQU 0 GOTO XP

VER | findstr /il "5.2" > nul
IF %ERRORLEVEL% EQU 0 GOTO SERVER2K3

VER | findstr /il "6.0" > nul
IF %ERRORLEVEL% EQU 0 GOTO VISTA

VER | findstr /i "6.1" > nul
IF %ERRORLEVEL% EQU 0 GOTO SEVEN

:XP
:SERVER2K3

ECHO * Detected Windows XP
secedit /configure /cfg %windir%\repair\secsetup.inf /db secsetup.sdb /verbose
GOTO COMMON

:VISTA
:SEVEN

ECHO * Detected Windows Vista/7
secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb /verbose
GOTO COMMON

:COMMON
REM cd /d "%ProgramFiles%\Windows Resource Kits\Tools"
subinacl /subkeyreg HKEY_LOCAL_MACHINE /grant=administrators=f /grant=system=f
subinacl /subkeyreg HKEY_CURRENT_USER /grant=administrators=f /grant=system=f
subinacl /subkeyreg HKEY_CLASSES_ROOT /grant=administrators=f /grant=system=f
subinacl /subdirectories %SystemDrive%\ /grant=administrators=f /grant=system=f
