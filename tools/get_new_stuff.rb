#!/usr/bin/env ruby

=begin
Copyright 2011-2012 Peter Hoeg <peter@speartail.com>

LICENSE
 - Please refer to the LICENSE file.

NOTES
 - OK, this is ugly. Really ugly, I know. But it was quick and dirty.

TODO
 - Add support for 32/64 bit specific downloads
 - Add a downloader class that tries axel, wget and then native ruby to download
 - Add a limit per package on number of connections (axel defaults to 4)

=end

$-w = true

require 'ap'          # strictly not needed but helpful when developing
require 'fileutils'
require 'logger'
require 'optparse'
require 'pathname'
require 'xmlsimple'

BIT_32_DIR = 'x86'
BIT_64_DIR = 'amd64'
XMLPATH = [ '..', '.' ]

class AppError < StandardError ; end

class ProgramCollection

  def initialize(*args)
    super

  end

  def download
  end

end

class Program
  attr_accessor :variables

  def download
  end
end

class Cli
  def self.run
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
      @logger.error "Invalid argument: #{e.message}"
      exit 1
    rescue AppError => e
      @logger.error e.message
      exit 2
    rescue IOError => e
      @logger.error "Something wicked happened: #{e.message}"
      exit 3
    end
  end
end

@logger = Logger.new STDOUT
@logger.level = Logger::INFO

PACKAGES = YAML.load(File.read('tools/packages.yml'))

options = OpenStruct.new
options.force = false
options.xml = [ XMLPATH ].flatten

OptionParser.new do|opts|
  opts.banner = "Usage: #{File.basename __FILE__} [options] -p PACKAGE DIRECTORY"

  opts.on('-p', '--packages PACKAGE,PACKAGE2', 'Name of package(s) to download' ) do |p|
    options.package = case p
      when 'all'
        PACKAGES
      else
        PACKAGES[arg.to_sym]
    end
  end

  opts.on('-l', '--language LANGUAGE', 'Name of language to download (package specific)' ) do |l|
    options.language = l
  end

  opts.on('-v', '--version VERSION', 'Version to download' ) do |v|
    options.version = v
  end

  opts.on('-x', '--xml PATH', 'Path to search for .xml files' ) do |x|
    options.xml << x if Dir.exists?(x)
    options.xml.flatten!
  end

  opts.on('-i', '--list', 'List supported packages' ) do
    raise NotImplementedError, 'not done yet!'
  end

  opts.on('-f', '--force', 'Force overwriting existing files' ) do
    options.force = true
  end

  opts.on('-d', '--debug', 'Increase debugging output' ) do
    @logger.level = Logger::DEBUG
  end

  opts.on('-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!


def replace_variables(str)
  s = str.gsub(/%version%/i, @version.to_s)
  s.gsub!('%mainversion%', @mainversion.to_s)
  s.gsub!('%shortversion%', @shortversion.to_s)
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
          @logger.info "Processing: #{xf}"
          xml = XmlSimple.xml_in(xf, {'KeyAttr' => {'package' => 'id', 'variable' => 'name'}})
          if xml['package'] && xml['package'][p[:package_id]] && xml['package'][p[:package_id]]['variable'] && @version.nil?
            # we should create a hash of found variables and automatically substitute them all
            @version = get_variable(xml, p[:package_id], 'version')
            @shortversion = get_variable(xml, p[:package_id], 'shortversion')
            @mainversion = get_variable(xml, p[:package_id], 'mainversion')
            @fileversion = get_variable(xml, p[:package_id], 'fileversion')
            @reldate = get_variable(xml, p[:package_id], 'reldate')
            @logger.info("Found version #{@version}(#{@fileversion}) in file #{xf}") if @version
          end
        end
      end
      raise AppError, "Unable to find version for package #{p[:package_id]}." if @version.nil?
    else
      @logger.warn("Ignoring language parameter for package that doesn't support it") if @language
      @logger.warn("Ignoring version parameter for package that doesn't support it") if @version || @fileversion
    end
    dest = Pathname.new(File.join(p[:destination]))
    path = replace_variables(File.join(@dir, dest.dirname))
    file = dest.basename
    fullpath = replace_variables(File.join(path, file))
    url = replace_variables(p[:url])
    raise AppError, "Unable to figure out URL: #{url}" unless url
    raise AppError, "Unable to figure out where to write local file: #{fullpath}" unless fullpath
    FileUtils.mkdir_p(path) unless Dir.exists?(path)
    if File.exists?(fullpath)
      if @overwrite && File.exist?(fullpath)
        FileUtils.safe_unlink(fullpath)
        @logger.info 'Removing existing file'
      end
    end
    system "axel '#{url}' -a -o '#{fullpath}'"
    @logger.info(p[:notice]) unless p[:notice].nil?
  end
end

Cli::run
