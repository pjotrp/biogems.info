#! /usr/bin/env ruby
# Generate RSS feed
#

require 'yaml'
require 'rss/maker'
require 'net/http'
require 'nokogiri'
require 'date'

version = "2.0" # ["0.9", "1.0", "2.0"]
destination = "rss.xml" # local file to write

def build_blog_data
  blogs = YAML::load(File.new("./etc/blogs.yaml").read)
  blogs = blogs["blogs"]
  articles = blogs.map { |blog| get_rss_data(blog["rss_feed"], blog["gsoc_tag"], blog['remark']) }
  articles.delete_if { |item| item.nil? }
  articles = articles.inject([]) {|total, one_blog| total.concat one_blog }
  return articles
end

def get_rss_data rss_feed, tag, remark
  tag = tag.downcase
  body = get_xml_with_retry(rss_feed)
  return nil if body.nil?
  doc = Nokogiri::XML(body)
  items = doc.xpath("//item")
  items = items.map do |item|
    # print item.to_s
    new_item = {}
    new_item[:title] = item.xpath(".//title").first.content
    new_item[:remark] = remark
    new_item[:time] = DateTime.parse(item.xpath(".//pubDate").first.content).to_time
    new_item[:tags] = item.xpath(".//category").map { |category| category.content.downcase }
    new_item[:link] = item.xpath(".//link").first.content
    new_item[:description] = item.xpath(".//description").first.content
    new_item
  end
  items.select { |item| item[:tags].join(" ").include?(tag) }
  items
end

def get_xml_with_retry url
  body = nil
  # will try 5 times to get a complete xml document
  5.times do
    begin 
      $stderr.print "Fetching "+url+"\n"
      body = Net::HTTP.get(URI(url)) if body.nil?
      if !body.nil?
        # protection from incomplete xml file
        if !Nokogiri::XML(body).validate.nil?
          body = nil
          next
        end
        break
      end
    rescue
      # probably the connection was reset, retry
    end
  end
  return body
end


content = RSS::Maker.make(version) do |m|
  m.channel.title = "biogems.info"
  m.channel.link = "http://biogems.info/rss.html"
  m.channel.description = "Ruby for bioinformatics"
  m.items.do_sort = true # sort items by date

  $stderr.print "Loading release info from ./var/bio-projects.yaml\n"
  spec = YAML::load(File.new("./var/bio-projects.yaml").read)
  # remove empty dates
  spec = spec.find_all { |rec| rec[1][:release_date] }
  spec.each do | rec |
    # $stderr.print rec[1][:release_date]
    rec[1][:release_date].to_s =~ /^(\d\d\d\d)\-(\d+)\-(\d+) (\d+):(\d+)/
    t = Time.new($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i)
    rec[1][:time] = t
  end

  build_blog_data().each { |item| spec.push([:blog, item]) }

  sorted = spec.sort { |a, b| b[1][:time] <=> a[1][:time] }

  sorted.each_with_index do | rec, i |
    if rec[0] != :blog
      name = rec[0]
      plugin = rec[1]
      rss = m.items.new_item
      rss.title = "#{name} #{plugin[:version]} released"
      rss.link = "http://biogems.info/index.html##{name}"
      rss.date = plugin[:time]
      rss.description = plugin[:summary]
    else
      # fetch blog entry
      item = rec[1]
      if item
        rss = m.items.new_item
        rss.title = item[:title]+' ('+item[:remark]+')'
        rss.link = item[:link]
        rss.date = item[:time]
        rss.description = item[:description]
      end
    end
    break if i > 25
  end
end

site_news = []
content.items.each do | item |
  site_news << { :title => item.title, :date => item.date, :link => item.link }
end

# write a YAML file for the site
File.open('./var/news.yaml','w') do | f |
  YAML.dump(site_news,f)
end

print content # output RSS to stdout
