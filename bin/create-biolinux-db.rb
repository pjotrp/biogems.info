#! /usr/bin/env ruby
# encoding: utf-8
#
# Create a database (YAML) of (Cloud)BioLinux packages
#

$: << "lib"
require 'biogems/biolinux/biolinux'
require 'biogems/debian/debian'

Encoding.default_external = Encoding::UTF_8

is_testing = ARGV[0] == '--test'

BIOLINUX_DEBIAN_MANIFEST = 
  if is_testing
    File.read('test/data/biolinux/debian-packages.yaml')
  else
    `curl -s https://raw.githubusercontent.com/chapmanb/cloudbiolinux/master/manifest/debian-packages.yaml` 
end

biolinux = BiolinuxManifest.new(BIOLINUX_DEBIAN_MANIFEST)

# Debian Tasks listed on https://anonscm.debian.org/cgit/blends/projects/med.git/tree/tasks
tasknames = 'bio bio-dev bio-ngs bio-phylogeny cloud data epi his oncology research'
biomed = []

if is_testing
  biomed << Debian::BlendTask.new(File.read('test/data/debian/bio-task.txt'))
else
  tasknames.split.each do |taskname|
    url = "https://anonscm.debian.org/cgit/blends/projects/med.git/plain/tasks/"+taskname
    $stderr.print "Fetching ", taskname," from #{url}\n"
    biomed << Debian::BlendTask.new(`curl -s #{url}`)
  end
end
pkgs = {}
biolinux.each do | name, pkg |
  $stderr.print "- ",name
  biomed.each do |bm|
    if bm[name] == true
      pkg[:tab] = :biolinux
      pkg[:biomed] = true
      pkgs[name] = pkg
      $stderr.print " biomed"
    elsif biolinux.is_biolinux?(name)
      pkg[:tab] = :biolinux
      pkg[:biomed] = false
      pkg[:biolinux] = true
      pkgs[name] = pkg
      $stderr.print " biolinux"
    end
  end
  $stderr.print "\n"
end

BIOLINUX_CUSTOM_MANIFEST = 
  if is_testing
    File.read('test/data/biolinux/custom-packages.yaml')
  else
    `curl -s https://raw.githubusercontent.com/chapmanb/cloudbiolinux/master/manifest/custom-packages.yaml` 
end

custom = BiolinuxManifest.new(BIOLINUX_CUSTOM_MANIFEST)
custom.each do | name, pkg |
  if not pkgs[name]
    $stderr.print "- ",name," custom\n"
    pkg[:tab] = :biolinux
    pkg[:biomed] = false
    pkg[:biolinux] = true
    pkg[:custom] = true
    pkgs[name] = pkg
  end
end

pkgs.each do | k, v |
  v["downloads"]=0 if not v["downloads"]
end

print pkgs.to_yaml

$stderr.print "\n",pkgs.size," packages found!\n"
