$: << "lib"

require 'biogems'
require 'github'

include BioGemInfo::GitHub

Given /^I have the biogems\.info project on github$/ do
  @uri = "https://github.com/pjotrp/biogems.info"
end

When /^I fetch JSON through the github issues API$/ do
  user, project = get_github_user_project(@uri)
  user.should == "pjotrp"
  project.should == "biogems.info"
  list = get_github_issues(@uri)
  # proves github API v2 has been removed
end

Then /^I should have fetched at least one issue$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the list should contain the open cucumber test issue$/ do
  pending # express the regexp above with the code you wish you had
end

