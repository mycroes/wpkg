#!/usr/bin/env ruby

require 'fileutils'
require 'getoptlong'
require 'pathname'

BIT_32_DIR="x86"
BIT_64_DIR="amd64"

FLASH = [
  {:url => 'http://www.adobe.com/go/full_flashplayer_win_msi',
            :file => File.join('Adobe', 'Flash', 'install_flash_player_10_active_x.msi')},
  {:url => 'http://www.adobe.com/go/full_flashplayer_win_pl_msi',
            :file => File.join('Adobe', 'Flash', 'install_flash_player_10_plugin.msi')},
  ]

IE9 = [
  {:url => 'http://download.microsoft.com/download/C/3/B/C3BF2EF4-E764-430C-BDCE-479F2142FC81/IE9-Windows7-x86-enu.exe',
            :file => File.join('Microsoft', 'IE9', BIT_32_DIR, 'IE9-Windows7-enu.exe')},
  {:url => 'http://download.microsoft.com/download/C/1/6/C167B427-722E-4665-9A40-A37BC5222B0A/IE9-Windows7-x64-enu.exe',
            :file => File.join('Microsoft', 'IE9', BIT_64_DIR, 'IE9-Windows7-enu.exe')},
  ]

INSTALLER = [
  {:url => 'http://download.microsoft.com/download/5/f/d/5fdc6240-2127-42b6-8e16-bab6171db233/WindowsXP-KB898461-x86-ENU.exe',
            :file => File.join('Microsoft', 'Windows Installer', 'WindowsXP-KB898461-x86-ENU.exe')},
  {:url => 'http://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsXP-KB942288-v3-x86.exe',
            :file => File.join('Microsoft', 'Windows Installer', 'WindowsXP-KB942288-v3-x86.exe')},
  ]

LASTPASS = [
  {:url => 'https://lastpass.com/lastpass.exe',
            :file => File.join('LastPass', BIT_32_DIR, 'lastpass.exe')},
  {:url => 'https://lastpass.com/lastpass_x64.exe',
            :file => File.join('LastPass', BIT_64_DIR, 'lastpass.exe')},
  ]

SKYPE = [
  {:url => 'http://download.skype.com/SkypeSetup.msi',
            :file => File.join('Skype', 'SkypeSetup.msi')},
  ]

TRUEVIEW = [
  {:url => 'http://download.autodesk.com/esd/dwgtrueview/2011/SetupDWGTrueView2011_32bit.exe',
            :file => File.join('Autodesk', 'DWGTureview', '2011', BIT_32_DIR, 'SetupDWGTrueView2011_32bit.exe')},
  {:url => 'http://download.autodesk.com/esd/dwgtrueview/2011/SetupDWGTrueView2011_64bit.exe',
            :file => File.join('Autodesk', 'DWGTureview', '2011', BIT_64_DIR, 'SetupDWGTrueView2011_64bit.exe')},
  ]

VC = [
  #VC6
  {:url => 'http://download.microsoft.com/download/vc60pro/update/1/w9xnt4/en-us/vc6redistsetup_enu.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_6.exe')},
  #2005
  {:url => 'http://download.microsoft.com/download/e/1/c/e1c773de-73ba-494a-a5ba-f24906ecf088/vcredist_x86.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2005sp1.exe')},
  {:url => 'http://download.microsoft.com/download/d/4/1/d41aca8a-faa5-49a7-a5f2-ea0aa4587da0/vcredist_x64.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2005sp1.exe')},
  #2008
  {:url => 'http://download.microsoft.com/download/d/d/9/dd9a82d0-52ef-40db-8dab-795376989c03/vcredist_x86.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2008sp1.exe')},
  {:url => 'http://download.microsoft.com/download/2/d/6/2d61c766-107b-409d-8fba-c39e61ca08e8/vcredist_x64.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2008sp1.exe')},
  #2010
  {:url => 'http://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2010.exe')},
  {:url => 'http://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe',
            :file => File.join('Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2010.exe')},

  ]

VJ = [
  {:url => 'http://download.microsoft.com/download/9/2/3/92338cd0-759f-4815-8981-24b437be74ef/vjredist.exe',
            :file => File.join('Microsoft', 'VisualJ', BIT_32_DIR, 'vjredist.exe')},
  {:url => 'http://download.microsoft.com/download/f/1/7/f175de5b-e7af-4231-9a65-417611bbedfe/vjredist64.exe',
            :file => File.join('Microsoft', 'VisualJ', BIT_64_DIR, 'vjredist.exe')},
  ]

VLC = [
  {:url => 'http://sourceforge.net/projects/vlc/files/1.1.8/win32/vlc-1.1.8-win32.exe/download',
            :file => File.join('VLC', 'vlc-1.1.8-win32.exe')},
  ]

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--force', '-f', GetoptLong::NO_ARGUMENT ],
  [ '--32', GetoptLong::NO_ARGUMENT ],
  [ '--64', GetoptLong::NO_ARGUMENT ],
  [ '--package', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  )

package = nil
dir = nil
overwrite = false
bits = :all

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
get_stuff.rb [OPTIONS] --package PACKAGE_NAME DIR

  -h, --help:
    show help

  --force, -f:
    Force overwriting existing files

  --package, -p PACKAGE_NAME:
    Get one of the following packages:
      all	All packages
      flash	Flash Player
      ie9	Internet Explorer 9
      installer	Windows Installer 4.5
      lastpass	LastPass
      skype	Skype Business Edition (.msi)
      trueview	DWG TrueView 2011
      vc	Visual C++ Runtime 2005, 2008, 2010
      vj	Visual J Runtime
      vlc	VLC Player

  DIR: The directory in which to store downloaded packages
EOF

    when '--force','-f'
      overwrite = true
    when '--32'
      bits = 32
    when '--64'
      bits = 64
    when '--package','-p'
      package = case arg
	when 'all'
	  [ FLASH, IE9, INSTALLER, LASTPASS, SKYPE, TRUEVIEW, VC, VJ, VLC ]
	when 'flash'
	  FLASH
	when 'ie9'
	  IE9
	when 'installer'
	  INSTALLER
	when 'lastpass'
	  LASTPASS
	when 'skype'
	  SKYPE
	when 'trueview'
	  TRUEVIEW
	when 'vc'
	  VC
	when 'vj'
	  VJ
	when 'vlc'
	  VLC
        else
	  nil
      end
  end
end

if package.nil? || ARGV.length != 1
  puts 'Missing dir argument or unknown package selected (try --help)'
  exit 1
else
  dir = ARGV.shift
  raise IOError, 'Destination directory not found' unless Dir.exists?(dir)
end

[ package ].flatten.each do |p|
  path = File.join(dir, Pathname.new(p[:file]).dirname)
  file = Pathname.new(p[:file]).basename
  fullpath = File.join(path, file)
  FileUtils.mkdir_p(path) unless Dir.exists?(path)
  if File.exists?(fullpath)
    if overwrite
      FileUtils.safe_unlink(fullpath)
      puts 'Removing existing file'
    end
  end
  system "axel #{p[:url]} -a -o #{fullpath}"
end
