@echo off

rem The following is courtesy of http://wpkg.org/7-Zip
rem I added >NUL to all commands to avoid causing problems with WPKG

SET SC=HKLM\Software\Classes
SET Extn=001-9 7z-0 arj-4 bz2-2 bzip2-2 cab-7 cpio-7 deb-11 dmg-17 gz-14 fat-21 gz-14 gzip-14 hfs-18 iso-8 lha-6 lzh-6 lzma-16 ntfs-22 rar-3 rpm-10 split-9 squashfs-24 swm-15 tar-13 taz-5 tbz-2 tbz2-2 tgz-14 tpz-14 txz-23 vhd-20 wim-15 xar-19 xz-23 z-5 zip-1001-9 7z-0 arj-4 bz2-2 bzip2-2 cab-7 cpio-7 deb-11 dmg-17 gz-14 fat-21 gz-14 gzip-14 hfs-18 iso-8 lha-6 lzh-6 lzma-16 ntfs-22 rar-3 rpm-10 split-9 squashfs-24 swm-15 tar-13 taz-5 tbz-2 tbz2-2 tgz-14 tpz-14 txz-23 vhd-20 wim-15 xar-19 xz-23 z-5 zip-1
 
FOR %%j IN (%Extn%) DO (
  FOR /F "tokens=1,2 delims=-" %%A IN ("%%j") DO (
    REG ADD %SC%\.%%A /VE /D "7-Zip.%%A" /F >NUL
    REG ADD %SC%\7-Zip.%%A /VE /D "%%A Archive" /F >NUL
    REG ADD %SC%\7-Zip.%%A\DefaultIcon /VE /D "%PROGRAMFILES%\7-Zip\7z.dll,%%B" /F >NUL
    REG ADD %SC%\7-Zip.%%A\shell\open\command /VE /D "\"%PROGRAMFILES%\7-Zip\7zFM.exe\" \"%%1\"" /F >NUL
  )
)
