#! /usr/bin/env ruby
# Generate RSS feed
#

require 'yaml'
require_relative '../lib/biogems/rss.rb'

feed = generate_biogems_rss_feed "./var/bio-projects.yaml", "./etc/blogs.yaml", 50

site_news = []
feed.items.each do | item |
  site_news << { :title => item.title, :date => item.date, :link => item.link } if item.date.to_i > Time.now.to_i - 120*24*3600
end

# print site_news

# write a YAML file for the site
File.open('./var/news.yaml','w') do | f |
  YAML.dump(site_news,f)
end

print feed # output RSS to stdout
