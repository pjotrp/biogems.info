#! /usr/bin/env ruby
#
# Create a database (YAML) of (Cloud)BioLinux packages
#

$: << "lib"
require 'biogems/biolinux/biolinux'
require 'biogems/debian/debian'

is_testing = ARGV[0] == '--test'

BIOLINUX_DEBIAN_MANIFEST = 
  if is_testing
    File.read('test/data/biolinux/debian-packages.yaml')
  else
    `curl -s https://raw.github.com/chapmanb/cloudbiolinux/master/manifest/debian-packages.yaml` 
end

biolinux = BiolinuxManifest.new(BIOLINUX_DEBIAN_MANIFEST)

# Debian Tasks
tasknames = 'bio bio-dev bio-ngs bio-phylogeny cloud data epi his oncology'
biomed = []

if is_testing
  biomed << Debian::BlendTask.new(File.read('test/data/debian/bio-task.txt'))
else
  tasknames.split.each do |taskname|
    $stderr.print "Fetching ", taskname,"\n"
    biomed << Debian::BlendTask.new(`curl -s http://anonscm.debian.org/viewvc/blends/projects/med/trunk/debian-med/tasks/#{taskname}?view=co`)
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
    `curl -s https://raw.github.com/chapmanb/cloudbiolinux/master/manifest/custom-packages.yaml` 
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
