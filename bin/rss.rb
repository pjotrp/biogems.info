#! /usr/bin/env ruby
# Generate RSS feed
#

require 'yaml'
require_relative '../lib/biogems/rss.rb'

feed = generate_biogems_rss_feed "./var/bio-projects.yaml", "./etc/blogs.yaml"

site_news = []
feed.items.each do | item |
  site_news << { :title => item.title, :date => item.date, :link => item.link }
end

# write a YAML file for the site
File.open('./var/news.yaml','w') do | f |
  YAML.dump(site_news,f)
end

print feed # output RSS to stdout
