#!/usr/bin/env ruby

require 'fileutils'
require 'getoptlong'
require 'pathname'

BIT_32_DIR="x86"
BIT_64_DIR="amd64"

FLASH = [
  { :url => 'http://www.adobe.com/go/full_flashplayer_win_msi',
            :file => File.join('Adobe', 'Flash', 'install_flash_player_10_active_x.msi')},
  {:url => 'http://www.adobe.com/go/full_flashplayer_win_pl_msi',
            :file => File.join('Adobe', 'Flash', 'install_flash_player_10_plugin.msi')},
  ]

VJ = [
  {:url => 'http://download.microsoft.com/download/9/2/3/92338cd0-759f-4815-8981-24b437be74ef/vjredist.exe',
            :file => File.join('Microsoft', 'VisualJ', BIT_32_DIR, 'vjredist.exe')},
  {:url => 'http://download.microsoft.com/download/f/1/7/f175de5b-e7af-4231-9a65-417611bbedfe/vjredist64.exe',
            :file => File.join('Microsoft', 'VisualJ', BIT_64_DIR, 'vjredist.exe')},
  ]

IE9 = [
  {:url => 'http://download.microsoft.com/download/C/3/B/C3BF2EF4-E764-430C-BDCE-479F2142FC81/IE9-Windows7-x86-enu.exe',
            :file => File.join('Microsoft', 'IE9', BIT_32_DIR, 'IE9-Windows7-enu.exe')},
  {:url => 'http://download.microsoft.com/download/C/1/6/C167B427-722E-4665-9A40-A37BC5222B0A/IE9-Windows7-x64-enu.exe',
            :file => File.join('Microsoft', 'IE9', BIT_64_DIR, 'IE9-Windows7-enu.exe')},
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
get_stuff.rb [OPTIONS] --package PACKAGES DIR

  -h, --help:
    show help

  --force, -f:
    Force overwriting existing files

  --package, -p PACKAGE_NAME:
    Get one of the following packages:
      all	All packages
      flash	Flash Player
      ie9	Internet Explorer 9
      lastpass	LastPass
      skype	Skype Business Edition (.msi)
      vj	Visual J Runtime

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
	  [ FLASH, IE9, LASTPASS, SKYPE, VJ ]
	when 'flash'
	  FLASH
	when 'ie9'
	  IE9
	when 'lastpass'
	  LASTPASS
	when 'skype'
	  SKYPE
	when 'vj'
	  VJ
        else
	  nil
      end
  end
end

if package.nil?
  puts 'Unknown or unsupported package selected. Please use --help to see available packages'
  exit 1
end

if ARGV.length != 1
  puts 'Missing dir argument (try --help)'
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
