
Given(/^I have the biogems\.info project$/) do
end

When(/^I fetch JSON through the rubygems API$/) do
  name = 'bio-logger'
  url = "https://rubygems.org/api/v1/versions/#{name}.json"
  versions = JSON.parse(BioGemInfo::Http::get_https_body(url))
  versions[0]["authors"].should == 'Pjotr Prins'
end

