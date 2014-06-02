#! /usr/bin/env ruby

require 'yaml'

yfile = ARGV.shift

print "Fetching git repositories from #{yfile} with Ruby #{RUBY_VERSION}\n"

geminfo = YAML::load(yfile)

p geminfo[0]
