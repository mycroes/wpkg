#!/usr/bin/env ruby

require 'uri'
require 'open-uri'

BIT_32_DIR="x86"
BIT_64_DIR="amd64"

class AppPackage

end

class AppPackageGroup

  def initialize(name, directory, packages)
    [ packages ].flatten.each do |p|
    end
  end

end

class AppPackageHandler

end

FLASH = [
  { :url => "http://www.adobe.com/go/full_flashplayer_win_msi",
            :file => 'install_flash_player_10_active_x.msi'},
  {:url => "http://www.adobe.com/go/full_flashplayer_win_pl_msi",
            :file => 'install_flash_player_10_plugin.msi'},
  ]

VJ = [
  {:url => "http://download.microsoft.com/download/f/1/7/f175de5b-e7af-4231-9a65-417611bbedfe/vjredist64.exe",
            :file => "amd64/vjredist.exe"},
  {:url => "http://download.microsoft.com/download/9/2/3/92338cd0-759f-4815-8981-24b437be74ef/vjredist.exe",
            :file => "x86/vjredist.exe"}
  ]

IE9 = [
  {:url => "http://download.microsoft.com/download/C/3/B/C3BF2EF4-E764-430C-BDCE-479F2142FC81/IE9-Windows7-x86-enu.exe",
            :file => "x86/IE9-Windows7-enu.exe"},
  {:url => "http://download.microsoft.com/download/C/1/6/C167B427-722E-4665-9A40-A37BC5222B0A/IE9-Windows7-x64-enu.exe",
            :file => "amd64/IE9-Windows7-enu.exe"},
  ]

LASTPASS = [
  {:url => "https://lastpass.com/lastpass.exe",
            :file => "x86/lastpass.exe"},
  {:url => "https://lastpass.com/lastpass_x64.exe",
            :file => "amd64/lastpass.exe"},
  ]


FLASH.each do |p|
  system "axel #{p[:url]} -a -o #{p[:file]}"
end
