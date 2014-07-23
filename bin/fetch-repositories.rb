#! /usr/bin/env ruby

require 'yaml'

yfile = ARGV.shift

print "Fetching git repositories from #{yfile} with Ruby #{RUBY_VERSION}\n"

geminfo = YAML::load(File.read(yfile))

geminfo.each do | name, info | 
  user = info[:github_user]
  project = info[:github_project]
  p [name, user, project]
  dir = 'data/repositories/'+project
  Dir.mkdir(dir)
end
