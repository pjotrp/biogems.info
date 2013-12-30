#! /usr/bin/env ruby
# Generate RSS feed
#

require 'yaml'
require_relative '../lib/biogems/rss.rb'

is_testing = ARGV.index('--test')  

# First fetch all information
feed = generate_biogems_rss_feed "./data/biogems.yaml", "./etc/blogs.yaml", 50, is_testing

site_news = []
feed.items.each do | item |
  if item.date.to_i > Time.now.to_i - 356*24*3600
    entry = { :title => item.title, :date => item.date, :link => item.link } 
    site_news << entry
  end
end

# print site_news

# write a YAML file for the site
File.open('./data/news.yaml','w') do | f |
  YAML.dump(site_news,f)
end

print feed # output RSS XML info to stdout
