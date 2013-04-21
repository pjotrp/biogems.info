require 'biogems/biolinux/biolinux_manifest'
require 'biogems/debian/debian'

Given /^I have a Debian package description in a BioLinux Manifest$/ do
end

When /^I fetch Debian package info for "(.*?)"$/ do |arg1|
  @biolinux = BiolinuxManifest.new(File.read("test/data/biolinux/debian-packages.yaml"))
  @pkg = @biolinux[arg1]
  @pkg["name"].should == arg1
end

Then /^I should get the name "(.*?)" and description "(.*?)"$/ do |arg1, arg2|
  @pkg["name"].should == arg1
  @pkg["description"].should == arg2
end

When /^I should get the popularity count of (\d+)$/ do |arg1|
  @pkg["downloads"].should == arg1.to_i
end

When /^I check the Bio Med information$/ do
  @biomed = Debian::BlendTask.new(File.read("test/data/debian/bio-task.txt"))
end

Then /^it should check it is a Bio Med package$/ do
  @biomed[@pkg["name"]].should be_true
end

Then /^it should check it is not a Bio Med package$/ do
  @biomed[@pkg["name"]].should be_false
end

Then /^it should check it is a BioLinux package$/ do
  @biolinux.is_biolinux?(@pkg["name"]).should be_true
end

Then /^it should check it is a science package$/ do
  @biolinux.is_science?(@pkg["name"]).should be_true
end


