#! /usr/bin/env ruby
#
# Create a database (YAML) of (Cloud)BioLinux packages
#

$: << "lib"
require 'biogems/biolinux/biolinux'
require 'biogems/debian/debian'

@biolinux = BiolinuxManifest.new(`curl -s https://raw.github.com/chapmanb/cloudbiolinux/master/manifest/debian-packages.yaml`)

# Debian Tasks
tasknames = 'bio bio-dev bio-ngs bio-phylogeny cloud data epi his oncology'
biomed = []

tasknames.split.each do |taskname|
  $stderr.print "Fetching ", taskname,"\n"
  biomed << Debian::BlendTask.new(`curl -s http://anonscm.debian.org/viewvc/blends/projects/med/trunk/debian-med/tasks/#{taskname}?view=co`)
end

pkgs = []
@biolinux.each do | name, pkg |
  biomed.each do |bm|
    if bm[name] == true
      pkgs << pkg
    end
  end
end

print pkgs.to_yaml

$stderr.print "\n",pkgs.size," packages found!\n"
