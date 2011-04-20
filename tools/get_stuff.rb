#!/usr/bin/env ruby

=begin
Copyright 2011 Peter Hoeg <p.hoeg@northwind.sg>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

NOTES
 - OK, this is ugly. Really ugly, I know. But it was quick and dirty.

TODO
 - Add support for 32/64 bit specific downloads
 - Add a downloader class that tries axel, wget and then native ruby to download
 - Add a limit per package on number of connections (axel defaults to 4)

=end

require 'fileutils'
require 'getoptlong'
require 'pathname'
require 'pp'   # strictly not needed but helpful when developing
require 'xmlsimple'

BIT_32_DIR="x86"
BIT_64_DIR="amd64"
XMLPATH = [ '..', '.' ]

class AppError < StandardError ; end

PACKAGES = {

:sevenzip => [
  {:url => 'http://downloads.sourceforge.net/sevenzip/7z%fileversion%.msi',
  :destination => ['7Zip', BIT_32_DIR, '7z%fileversion%.msi'],
  :package_id => '7zip'},
  {:url => 'http://downloads.sourceforge.net/sevenzip/7z%fileversion%-x64.msi',
  :destination => ['7Zip', BIT_64_DIR, '7z%fileversion%.msi'],
  :package_id => '7zip'},
],

:dotnet3 => [
  {:url => 'http://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe',
  :destination => ['Microsoft', 'DotNet', 'dotnetfx35.exe']},
  {:url => 'http://download.microsoft.com/download/C/6/A/C6ADC586-2518-404B-8973-E1E22C556AF4/NDP20SP2-KB958481-x86.exe',
  :destination => ['Microsoft', 'DotNet', 'NDP20SP2-KB958481-x86.exe']},
  {:url => 'http://download.microsoft.com/download/C/6/A/C6ADC586-2518-404B-8973-E1E22C556AF4/NDP30SP2-KB958483-x86.exe',
  :destination => ['Microsoft', 'DotNet', 'NDP30SP2-KB958483-x86.exe']},
  {:url => 'http://download.microsoft.com/download/C/6/A/C6ADC586-2518-404B-8973-E1E22C556AF4/NDP35SP1-KB958484-x86.exe',
  :destination => ['Microsoft', 'DotNet', 'NDP35SP1-KB958484-x86.exe']},
],

:firefox => [
  {:url => 'ftp://ftp.mozilla.org/pub/firefox/releases/%version%/win32/%language%/Firefox Setup %version%.exe',
  :destination => ['Mozilla', 'Firefox', 'Firefox Setup %version%.exe'],
  :package_id => 'firefox',
  :language => 'en-US'},
],

:flash => [
  {:url => 'http://www.adobe.com/go/full_flashplayer_win_msi',
  :destination => ['Adobe', 'Flash', 'install_flash_player_10_active_x.msi']},
  {:url => 'http://www.adobe.com/go/full_flashplayer_win_pl_msi',
  :destination => ['Adobe', 'Flash', 'install_flash_player_10_plugin.msi']},
],

:git => [
  {:url => 'http://msysgit.googlecode.com/files/Git-%version%-preview%reldate%.exe',
  :destination => ['Git', 'Git-%version%-preview%reldate%.exe'],
  :package_id => 'git' },
],

:gs => [
  {:url => 'http://downloads.sourceforge.net/project/ghostscript/GPL%20Ghostscript/%version%/gs%fileversion%w32.exe',
  :destination => ['GhostScript', BIT_32_DIR, 'gs%fileversion%.exe'],
  :package_id => 'ghostscript' },
  {:url => 'http://downloads.sourceforge.net/project/ghostscript/GPL%20Ghostscript/%version%/gs%fileversion%w64.exe',
  :destination => ['GhostScript', BIT_64_DIR, 'gs%fileversion%.exe'],
  :package_id => 'ghostscript' },
],

:ie9 => [
  {:url => 'http://download.microsoft.com/download/C/3/B/C3BF2EF4-E764-430C-BDCE-479F2142FC81/IE9-Windows7-x86-enu.exe',
  :destination => ['Microsoft', 'IE9', BIT_32_DIR, 'IE9-Windows7-enu.exe']},
  {:url => 'http://download.microsoft.com/download/C/1/6/C167B427-722E-4665-9A40-A37BC5222B0A/IE9-Windows7-x64-enu.exe',
  :destination => ['Microsoft', 'IE9', BIT_64_DIR, 'IE9-Windows7-enu.exe']},
],

:installer => [
  {:url => 'http://download.microsoft.com/download/5/f/d/5fdc6240-2127-42b6-8e16-bab6171db233/WindowsXP-KB898461-x86-ENU.exe',
  :destination => ['Microsoft', 'Windows Installer', 'WindowsXP-KB898461-x86-ENU.exe']},
  {:url => 'http://download.microsoft.com/download/2/6/1/261fca42-22c0-4f91-9451-0e0f2e08356d/WindowsXP-KB942288-v3-x86.exe',
  :destination => ['Microsoft', 'Windows Installer', 'WindowsXP-KB942288-v3-x86.exe']},
],

:lastpass => [
  {:url => 'https://lastpass.com/lastpass.exe',
  :destination => ['LastPass', BIT_32_DIR, 'lastpass.exe']},
  {:url => 'https://lastpass.com/lastpass_x64.exe',
  :destination => ['LastPass', BIT_64_DIR, 'lastpass.exe']},
],

:npp => [
  {:url => 'http://download.tuxfamily.org/notepadplus/%version%/npp.%version%.Installer.exe',
  :destination => ['Notepad', 'npp.%version%.Installer.exe'],
  :package_id => 'notepad'},
],

:skype => [
  {:url => 'http://download.skype.com/SkypeSetup.msi',
  :destination => ['Skype', 'SkypeSetup.msi']},
],

:trueview => [
  {:url => 'http://download.autodesk.com/esd/dwgtrueview/2011/SetupDWGTrueView2011_32bit.exe',
  :destination => ['Autodesk', 'DWGTrueview', '2011', BIT_32_DIR, 'SetupDWGTrueView2011_32bit.exe']},
  {:url => 'http://download.autodesk.com/esd/dwgtrueview/2011/SetupDWGTrueView2011_64bit.exe',
  :destination => ['Autodesk', 'DWGTrueview', '2011', BIT_64_DIR, 'SetupDWGTrueView2011_64bit.exe']},
],

:vc_orig => [
  #VC6
  {:url => 'http://download.microsoft.com/download/vc60pro/update/1/w9xnt4/en-us/vc6redistsetup_enu.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_6.exe']},
  #2005
  {:url => 'http://download.microsoft.com/download/e/1/c/e1c773de-73ba-494a-a5ba-f24906ecf088/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2005sp1.exe']},
  {:url => 'http://download.microsoft.com/download/d/4/1/d41aca8a-faa5-49a7-a5f2-ea0aa4587da0/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2005sp1.exe']},
  #2008
  {:url => 'http://download.microsoft.com/download/d/d/9/dd9a82d0-52ef-40db-8dab-795376989c03/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2008sp1.exe']},
  {:url => 'http://download.microsoft.com/download/2/d/6/2d61c766-107b-409d-8fba-c39e61ca08e8/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2008sp1.exe']},
  #2010
  {:url => 'http://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2010.exe']},
  {:url => 'http://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2010.exe']},
],

:vc => [
  #VC6
  {:url => 'http://download.microsoft.com/download/vc60pro/update/1/w9xnt4/en-us/vc6redistsetup_enu.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_6.exe']},
  #2005
  {:url => 'http://download.microsoft.com/download/3/0/5/305BF178-5F7C-489E-8F39-C3257429E832/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2005sp1.exe']},
  {:url => 'http://download.microsoft.com/download/3/0/5/305BF178-5F7C-489E-8F39-C3257429E832/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2005sp1.exe']},
  #2008
  {:url => 'http://download.microsoft.com/download/7/E/D/7ED72B8A-D457-4DF0-B455-42A85FA157FF/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2008sp1.exe']},
  {:url => 'http://download.microsoft.com/download/7/E/D/7ED72B8A-D457-4DF0-B455-42A85FA157FF/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2008sp1.exe']},
  #2010
  {:url => 'http://download.microsoft.com/download/4/D/0/4D00D6C0-09FC-446C-AE9C-C923AF2DF29A/vcredist_x86.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_32_DIR, 'vcredist_2010.exe']},
  {:url => 'http://download.microsoft.com/download/4/D/0/4D00D6C0-09FC-446C-AE9C-C923AF2DF29A/vcredist_x64.exe',
  :destination => ['Microsoft', 'VCRuntime', BIT_64_DIR, 'vcredist_2010.exe']},
],

:vj => [
  {:url => 'http://download.microsoft.com/download/9/2/3/92338cd0-759f-4815-8981-24b437be74ef/vjredist.exe',
  :destination => ['Microsoft', 'VisualJ', BIT_32_DIR, 'vjredist.exe']},
  {:url => 'http://download.microsoft.com/download/f/1/7/f175de5b-e7af-4231-9a65-417611bbedfe/vjredist64.exe',
  :destination => ['Microsoft', 'VisualJ', BIT_64_DIR, 'vjredist.exe']},
],

:vlc => [
  {:url => 'http://sourceforge.net/projects/vlc/files/%version%/win32/vlc-%version%-win32.exe/download',
  :destination => ['VLC', 'vlc-%version%-win32.exe'],
  :package_id => 'vlc'},
],

:wpkg => [
  {:url => 'http://wpkg.org/files/client/stable/WPKG%20Client%20%version%-x32.msi',
  :destination => ['WPKG', BIT_32_DIR, 'WPKG Client 1.3.14.msi'],
  :package_id => 'wpkg' },
  {:url => 'http://wpkg.org/files/client/stable/WPKG%20Client%20%version%-x64.msi',
  :destination => ['WPKG', BIT_64_DIR, 'WPKG Client 1.3.14.msi'],
  :package_id => 'wpkg' },
],

}

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--force', '-f', GetoptLong::NO_ARGUMENT],
  ['--bits', '-b', GetoptLong::REQUIRED_ARGUMENT],
  ['--language', '-l', GetoptLong::REQUIRED_ARGUMENT],
  ['--version', '-v', GetoptLong::REQUIRED_ARGUMENT],
  ['--xml', '-x', GetoptLong::REQUIRED_ARGUMENT],
  ['--package', '-p', GetoptLong::REQUIRED_ARGUMENT]
)

@package = nil
@dir = nil
@overwrite = false
@language = nil
@version = nil
@fileversion = nil
@reldate = nil
@xmlpath = XMLPATH
@bits = :all

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
get_stuff.rb [OPTIONS] --package PACKAGE_NAME DIR

  -h, --help:
    show help

  --force, -f:
    Force overwriting existing files

  --bits, -b 32|64:
    Only download 32 or 64 bit packages

  --language, -l LANGUAGE:
    Specify a specific language

  --xml, -x PATH
    Set the XML search path. If empty will default to '..'

  --version, -v VERSION
    Download a specific version instead of the newest. This is not supported by all packages.

  --package, -p PACKAGE_NAME:
    Get one of the following packages:
      all       All packages
      sevenzip  7Zip **
      dotnet3   .NET 3.5
      flash     Flash Player
      gs       	GhostScript **
      ie9       Internet Explorer 9
      installer	Windows Installer 4.5
      npp       Notepad++ **
      lastpass	LastPass
      skype     Skype Business Edition (.msi)
      trueview  DWG TrueView 2011
      vc        Visual C++ Runtime 2005, 2008, 2010
      vj        Visual J Runtime
      vlc       VLC Player **
      wpkg	WPKG **

      Packages marked with ** support version specific downloads

  DIR: The directory in which to store downloaded packages
      EOF

    when '--force', '-f'
      @overwrite = true
    when '--bits','-b'
      @bits = arg
    when '--language','-l'
      @language = arg
    when '--version', '-v'
      @version = arg
    when '--xml', '-x'
      @xmlpath << arg if Dir.exist?(arg)
    when '--package', '-p'
      @package = case arg
        when 'all'
          PACKAGES
        else
          PACKAGES[arg.to_sym]
      end
  end
end

def replace_variables(str)
  s = str.gsub('%version%', @version.to_s)
  s.gsub!('%fileversion%', @fileversion.to_s)
  s.gsub!('%language%', @language.to_s)
  s.gsub!('%reldate%', @reldate.to_s)
  return s
end

def get_variable(xml, package, variable)
  return xml['package'][package]['variable'][variable]['value'] if xml['package'][package]['variable'][variable]
end

def download(package_def)
  package_def.each do |p|
    @language = p[:language] if p[:language] && @language.nil?
    if p[:package_id]
      [ @xmlpath ].flatten.each do |xp|
        Dir.glob(File.join(xp, '*.xml')).sort.each do |xf|
	  # puts "Processing: #{xf}"
          xml = XmlSimple.xml_in(xf, {'KeyAttr' => {'package' => 'id', 'variable' => 'name'}})
          if xml['package'] && xml['package'][p[:package_id]] && xml['package'][p[:package_id]]['variable'] && @version.nil?
	    # we should create a hash of found variables and automatically substitute them all
            @version = get_variable(xml, p[:package_id], 'version')
            @fileversion = get_variable(xml, p[:package_id], 'fileversion')
            @reldate = get_variable(xml, p[:package_id], 'reldate')
            puts "INFO: Found version #{@version}(#{@fileversion}) in file #{xf}" if @version
          end
        end
      end
      raise AppError, "Unable to find version for package #{p[:package_id]}." if @version.nil?
    else
      puts "WARNING: Ignoring language parameter for package that doesn't support it" if @language
      puts "WARNING: Ignoring version parameter for package that doesn't support it" if @version || @fileversion
    end
    dest = Pathname.new(File.join(p[:destination]))
    path = File.join(@dir, dest.dirname)
    file = dest.basename
    fullpath = replace_variables(File.join(path, file))
    url = replace_variables(p[:url])
    raise AppError, "Unable to figure out URL: #{url}" unless url
    raise AppError, "Unable to figure out where to write local file: #{fullpath}" unless fullpath
    FileUtils.mkdir_p(path) unless Dir.exists?(path)
    if File.exists?(fullpath)
      if @overwrite
        FileUtils.safe_unlink(fullpath)
        puts 'INFO: Removing existing file'
      end
    end
    system "axel '#{url}' -a -o '#{fullpath}'"
  end
end

begin
  raise ArgumentError, 'Unknown package' if @package.nil?
  raise ArgumentError, 'Missing dir argument' if ARGV.length != 1
  @dir = ARGV.shift
  FileUtils.mkdir_p(@dir) unless Dir.exists?(@dir)
  if @package.is_a? Hash
    @package.each_value do |v|
      download(v)
    end
  else
    download(@package)
  end
rescue ArgumentError => e
  puts "ERROR: Invalid argument - try running the program with --help"
  puts "ERROR: #{e.message}"
  exit 1
rescue AppError => e
  puts "ERROR: #{e.message}"
  exit 2
rescue IOError => e
  puts "ERROR: Something wicked happened: #{e.message}"
  exit 3
end
