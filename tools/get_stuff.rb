#!/usr/bin/env ruby

FLASH = [
    Hash.new (:url => "http://www.adobe.com/go/full_flashplayer_win_msi", :file => 'install_flash_player_10_active_x.msi'),
    Hash.new (:url => "http://www.adobe.com/go/full_flashplayer_win_pl_msi", :file => 'install_flash_player_10_plugin.msi'),
  ]

VJ = [
  Hash.new (:url => "http://www.microsoft.com/downloads/info.aspx?na=41&SrcFamilyId=42C46554-5313-4348-BF81-9BB133518945&SrcDisplayLang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2ff%2f1%2f7%2ff175de5b-e7af-4231-9a65-417611bbedfe%2fvjredist64.exe", :file => "amd64/vjredist.exe"),
  Hash.new (:url => "http://www.microsoft.com/downloads/info.aspx?na=41&SrcFamilyId=E9D87F37-2ADC-4C32-95B3-B5E3A21BAB2C&SrcDisplayLang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2f9%2f2%2f3%2f92338cd0-759f-4815-8981-24b437be74ef%2fvjredist.exe", :file => "x86/vjredist.exe")
  ]

