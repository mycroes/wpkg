This project has WPKG package configuration files.

A lot of it is inspired by (and copied from) the WPKG wiki so much gratitude is owed.

The following criteria must be fulfilled before the recipe is included here:

1) 32-bit and 64-bit safe

2) Uses "msiexec /x package_file.msi" for uninstallations whenever possible to avoid knowing CLSIDs that change


NOTES
=====

a) All revisions should be written out without dots. Examples:
  4.65 -> 465
  9.2.0.61 -> 92061

b) All revision should have an additional identifier, this gives us 10 tries to get a new version right and allow overriding the central version. Examples:
  4.65-0 -> 4650
  9.2.0.61-0 -> 920610

c) Priorities are set as follows
   10 - most normal applications
   50 - system applications (IE8 and others)
  100 - critical install first apps (Windows Installer 4.5)

d) Rebooting - all should have their reboot priority set to "false" and only reboot (postponed) in case of 3010 or similar return codes.
