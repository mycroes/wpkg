#!/usr/bin/env ruby

require 'pp'
require 'xmlsimple'

data = XmlSimple.xml_in('../thinkpad.xml', {'KeyAttr' => { 'package' => 'id', 'variable' => 'name'}, 'KeyToSymbol' => false})

vers = data['package']['tp_airbag']['variable']['version']

data['package']['tp_airbag']['install'].each do |k,v|
  puts k['cmd'] if k['type'] == 'main'
end