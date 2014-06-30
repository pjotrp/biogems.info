#! /usr/bin/env ruby

require 'yaml'

yfile = ARGV.shift

print "Fetching git repositories from #{yfile} with Ruby #{RUBY_VERSION}\n"

geminfo = YAML::load(File.read(yfile))

geminfo.each do | name, info | 
  user = info[:github_user]
  project = info[:github_project]
  p [name, user, project, info[:source_code_uri]]
  if project
    dir = 'data/repositories/'+project
    if not File.exist?(dir)
      p dir
      Dir.mkdir(dir)
    end
  else
    $stderr.print "WARNING: no project defined for #{name}!\n"
  end
end

