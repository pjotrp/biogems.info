$: << "lib"

require 'biogems/rss'

Given /^I have one rss blog feed configured$/ do
  File.exists?("test/data/rss/rss.xml").should be_true
  File.exists?("test/data/rss/rss-blogs.yaml").should be_true
end

When /^I parse the rss feed$/ do
  @rss_feed = generate_biogems_rss_feed "test/data/bio-projects.yaml", "test/data/rss/rss-blogs.yaml"
end

Then /^the resulting rss feed should have the same contents as the rss feed$/ do
  titles = @rss_feed.items.map { |item| item.title }
  titles.index("RSS test title 1 (RSS blog)").should be_true
  titles.index("RSS test title 2 (RSS blog)").should be_true
end

Given /^I have one atom blog feed configured$/ do
  File.exists?("test/data/rss/atom.xml").should be_true
  File.exists?("test/data/rss/atom-blogs.yaml").should be_true
end

When /^I parse the atom feed$/ do
  @atom_feed = generate_biogems_rss_feed "test/data/bio-projects.yaml", "test/data/rss/atom-blogs.yaml"
end

Then /^the resulting rss feed should have the same contents as the atom feed$/ do
  titles = @atom_feed.items.map { |item| item.title }
  titles.index("Atom test title 1 (Atom blog)").should be_true
  titles.index("Atom test title 2 (Atom blog)").should be_true
end

