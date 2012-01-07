#! /usr/bin/env ruby
# Generate RSS feed
#

require 'yaml'
require 'rss/maker'

version = "2.0" # ["0.9", "1.0", "2.0"]
destination = "rss.xml" # local file to write

content = RSS::Maker.make(version) do |m|
  m.channel.title = "biogems.info"
  m.channel.link = "http://biogems.info/rss.html"
  m.channel.description = "Ruby for bioinformatics"
  m.items.do_sort = true # sort items by date

  spec = YAML::load(File.new("./var/bio-projects.yaml").read)
  # remove empty dates
  spec = spec.find_all { |rec| rec[1][:release_date] }
  spec.each do | rec |
    rec[1][:release_date].to_s =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d)/
    t = Time.new($1.to_i,$2.to_i,$3.to_i)
    rec[1][:time] = t
  end

  sorted = spec.sort { |a, b| b[1][:time] <=> a[1][:time] }

  sorted.each_with_index do | rec, i |
    name = rec[0]
    plugin = rec[1]
    rss = m.items.new_item
    rss.title = "#{name} #{plugin[:version]}"
    rss.link = "http://biogems.info/index.html##{name}"
    # p plugin[:time]
    rss.date = plugin[:time]
    break if i > 12
  end
end

print content
