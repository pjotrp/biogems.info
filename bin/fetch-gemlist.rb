#!/usr/bin/env ruby
#
# This script fetches information from the gem
# tool

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
  list = ['bio','bio-blastxmlparser']
else
  list = `gem search bio-`.split(/\n/)
  list = list.map { |item| item.split(" ")[0] }
end



print list.to_json  # output to STDOUT
