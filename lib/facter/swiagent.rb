#!/usr/bin/ruby

# Custom fact script for Facter, intended to export swiagent configuration
# variables to Puppet...

cfgfile = '/opt/SolarWinds/Agent/bin/swiagent.cfg'

if File.exist?(cfgfile)
  require 'rubygems'
  require 'facter'

  begin
    require 'nokogiri'
  rescue Exception => ex
    Puppet.warning "Nokogiri is required for the swiagent module to function: " + ex.message
  end

  # Parse XML file, and step over the configuration elements...
  facts = Hash.new
  begin
    xml = File.open(cfgfile) { |f| Nokogiri::XML(f) }
    xml.xpath('//certificate/*|//executer/*|//target/*|//httpproxy/*').each do |node|
      # Create a new hash for this element, if we haven't already...
      if not facts.key?(node.parent.name)
        facts[node.parent.name] = Hash.new
      end

      # Store the fact under a hash key identical to the name of the XML
      # element...
      facts[node.parent.name][node.name] = node.content
    end
  rescue Exception => ex
    Puppet.warning "Unable to parse " + cfgfile + ": " + ex.message
  end

  # Export discovered facts into Facter...
  Facter.add(:swiagent) do
    setcode do
      facts
    end
  end
end
