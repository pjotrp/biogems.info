$: << "lib"

require 'biogems'

include BioGemInfo::GitHub

Given /^I have the biogems\.info project on github$/ do
  @uri = "https://github.com/pjotrp/biogems.info"
end

When /^I fetch JSON through the github issues API$/ do
  user, project = get_github_user_project(@uri)
  user.should == "pjotrp"
  project.should == "biogems.info"
  @list = get_github_issues(@uri)
  # github API v2 has been removed - there is a legacy API, but I can't get it to work
end

Then /^I should have fetched at least one issue$/ do
  # assuming biogems.info has one ;)
  # If the API rate has been exceeded this may fail.
  @list.size.should > 0
end

Then /^the list should contain the open cucumber test issue$/ do
end

