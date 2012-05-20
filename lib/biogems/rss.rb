
require 'yaml'
require 'rss/maker'
require 'net/http'
require 'date'

def rss_version
  "2.0" # ["0.9", "1.0", "2.0"]
end

def generate_biogems_rss_feed biogems_file, blogs_file
  blogs = YAML::load(File.new(blogs_file).read)
  blogs = blogs["blogs"]
  feeds = blogs.map { |blog| parse_feed(blog["rss_feed"], blog["gsoc_tag"], blog['remark']) }
  feeds.push(parse_biogem_data(biogems_file))
  huge_feed = merge_rss_feeds feeds
  output_feed = extract_most_recent 25, huge_feed
  output_feed.channel.title = "biogems.info"
  output_feed.channel.link = "http://biogems.info/rss.html"
  output_feed.channel.description = "Ruby for bioinformatics"
  output_feed
end

def parse_feed feed, tag, remark
  tag = tag.downcase if !tag.nil?
  body = get_xml_with_retry(feed)
  return nil if body.nil?

  output_feed = RSS::Parser.parse body, false
  if !remark.nil?
    output_feed.items.each do |item|
      if item.class == RSS::Atom::Feed::Entry
        item.title.content = item.title.content + ' (' + remark + ')'
      else
        item.title = item.title + ' (' + remark + ')'
      end
    end
  end
  if !tag.nil?
    output_feed.items.select {
      |item| item.categories.map {|category| category.content}.join.downcase.include? tag}
  end
  output_feed
end

def parse_biogem_data input_file
  RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
    $stderr.print "Loading release info from #{input_file}\n"
    spec = YAML::load(File.new(input_file).read)
    if spec
      # remove empty dates
      spec = spec.find_all { |rec| rec[1][:release_date] }
      spec.each do | rec |
        # $stderr.print rec[1][:release_date]
        rec[1][:release_date].to_s =~ /^(\d\d\d\d)\-(\d+)\-(\d+) (\d+):(\d+)/
        t = Time.new($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i)
        rec[1][:time] = t
      end

      spec.each do |rec|
        name = rec[0]
        plugin = rec[1]
        rss = m.items.new_item
        rss.title = "#{name} #{plugin[:version]} released"
        rss.link = "http://biogems.info/index.html##{name}"
        rss.date = plugin[:time]
        rss.description = plugin[:summary]
      end
    end
  end
end

def merge_rss_feeds feeds
  RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
    feeds.each do |feed|
      feed.items.each do |item|
        new_item = m.items.new_item
        if item.class == RSS::Atom::Feed::Entry
          new_item.title = item.title.content
          new_item.link = item.link.href
          new_item.date = item.updated.content
          new_item.description = item.summary.nil? ? nil : item.summary.content
        else
          new_item.title = item.title
          new_item.link = item.link
          new_item.date = item.date
          new_item.description = item.description
        end
      end
    end
  end
end

def extract_most_recent how_many, feed
  output_feed = RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
  end
  output_feed.items.concat feed.items
  output_feed.items.sort! { |a, b| b.date <=> a.date }
  while !(output_feed.items.delete_at(how_many)).nil?
  end
  output_feed
end

def get_xml_with_retry url
  if !url.start_with?("http")
    return File.new(url).read
  end

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

def set_bogus_header m
  m.channel.title = "tmp"
  m.channel.link = "tmp"
  m.channel.description = "tmp"
end

