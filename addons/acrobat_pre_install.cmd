@echo off
rem Zap all old Reader versions

SET MSI=/quiet /norestart

rem 8.1.2
msiexec /x{AC76BA86-7AD7-1033-7B44-A80000000002} %MSI%
rd /Q /S "%PROGRAMFILES%\Adobe\Reader 8.0"
rd /Q /S "%PROGRAMFILES%\Adobe\Reader 8.1"
rd /Q /S "%PROGRAMFILES%\Adobe\Reader 8.2"
rd /Q /S "%PROGRAMFILES(x86)%\Adobe\Reader 8.0"
rd /Q /S "%PROGRAMFILES(x86)%\Adobe\Reader 8.1"
rd /Q /S "%PROGRAMFILES(x86)%\Adobe\Reader 8.2"

rem 9.4.0
MsiExec.exe /X{AC76BA86-1033-0000-0000-000000000004}
rd /Q /S "%PROGRAMFILES%\Adobe\Reader 9.0"
rd /Q /S "%PROGRAMFILES(x86)%\Adobe\Reader 9.0"
