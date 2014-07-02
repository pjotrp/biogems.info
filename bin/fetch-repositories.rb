#! /usr/bin/env ruby

require 'yaml'

yfile = ARGV.shift

print "Fetching git repositories from #{yfile} with Ruby #{RUBY_VERSION}\n"

geminfo = YAML::load(File.read(yfile))

cwd = Dir.pwd
geminfo.each do | name, info | 
  user = info[:github_user]
  project = info[:github_project]
  git_url = info[:source_code_uri]
  git_url += '.git' if git_url and git_url == /^http/
  p [name, user, project, info[:source_code_uri]]
  if project
    dir = 'data/repositories/'+project
    if not File.exist?(dir)
      p dir
      Dir.mkdir(dir)
    end
    if git_url and not File.exist?(File.basename(git_url,'.git'))
      Dir.chdir(dir)
      p `git clone #{git_url}`
      Dir.chdir(cwd)
    end
  else
    $stderr.print "WARNING: no project defined for #{name}!\n"
  end
end

