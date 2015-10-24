#!/usr/bin/env ruby
#
# This is the first step for generating the website.
#
# This script fetches the main biogem list using the gem tool and
# enriches that with information from the YAML files in ./etc/biogem


$: << "lib"

require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'biogems'

$is_debug = ARGV.index('--debug')  
is_testing = ARGV.index('--test')  

$stderr.print "Get all rubygems starting with bio- (bio dash)\n"
if is_testing
  list = ['bio','bio-blastxmlparser','bio-publisci']
else
  list = `gem search bio-`.split(/\n/)
  list = list.map { |item| item.split(" ")[0] }
end

h = {}
list.each { |n| h[n] = nil }
                             
$stderr.print "Get information from YAML files in ./etc/biogems/\n"
list2 = Dir.glob("./etc/biogems/*.yaml")
list2.each do | yamlfn |
  gem = File.basename(yamlfn,".yaml")
  # p gem
  info = YAML.load(File.read(yamlfn))
  if info[:status] == 'disabled'
    h.delete(gem)
  else
    h[gem] = info
  end
end

raise "gem should not be there" if h['bio-publisci']

if is_testing
  h2 = {}
  h.keys.first(4).each { | k |
    h2[k] = h[k]
  }
  h = h2
end

$stderr.print "Output YAML\n"
print h.to_yaml  # output to STDOUT
