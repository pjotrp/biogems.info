require 'yaml'
require 'rss/maker'
require 'net/http'
require 'date'
require 'nokogiri'

def rss_version
  "2.0" # ["0.9", "1.0", "2.0"]
end

# This method puts together all the different feeds
def generate_biogems_rss_feed biogems_file, blogs_file, max_entries = 25, is_testing=false
  blogs = YAML::load(File.new(blogs_file).read)
  blogs = blogs["blogs"]
  feeds = []
  if not is_testing
    feeds = blogs.map { |blog| 
      parse_feed(blog["rss_feed"], blog["gsoc_tag"], blog['remark']) 
    }.compact
  else
    feeds = [ parse_feed('http://sciruby.com/atom.xml', 'test_tag', 'test_remark') ]
  end
  biogem_releases = parse_biogem_data(biogems_file)
  feeds.push biogem_releases
  huge_feed = merge_rss_feeds(feeds)
  parsed_feed = extract_most_recent(max_entries, huge_feed)
  parsed_feed.channel.title = "biogems.info"
  parsed_feed.channel.link = "http://biogems.info/rss.html"
  parsed_feed.channel.description = "Ruby for bioinformatics"
  parsed_feed
end

# Parse existing RSS feeds
def parse_feed feed, tag, remark
  $stderr.print "Parsing ",feed,"\n"
  tag = tag.downcase if !tag.nil?
  body = get_xml_with_retry(feed)
  if body.nil? or body == ""
    $stderr.puts "WARNING: Received empty body for feed "+feed
    return nil 
  end
  begin
    parsed_feed = RSS::Parser.parse body, false
  rescue RSS::NotWellFormedError => e
    $stderr.puts "Could not parse RSS feed at #{feed}. RSS is not well formed."
    return nil
  end
  if !remark.nil? and parsed_feed and parsed_feed.items
    parsed_feed.items.each do |item|
      if item.class == RSS::Atom::Feed::Entry
        item.title.content = item.title.content + ' (' + remark + ')'
      else
        item.title = item.title + ' (' + remark + ')'
      end
    end
  end
  # if !tag.nil?
  #   parsed_feed.items.select {
  #      |item| item.categories.map {|category| category.content}.join.downcase.include? tag}
  # end
  parsed_feed
end

# Parse the biogem release info and return RSS object
def parse_biogem_data input_file
  RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
    $stderr.print "Loading release info from #{input_file}\n"
    spec = YAML::load(File.new(input_file).read)
    if spec
      # remove empty dates
      spec = spec.find_all { |rec| rec[1][:release_date] }
      spec.each do | rec |
        $stderr.print rec[1][:release_date]
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

# Pass in an array of RSS feeds (list of list) and merge them into one list
def merge_rss_feeds feeds
  RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
    feeds.each do |feed|
      # next if not feed or not feed.items
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
  parsed_feed = RSS::Maker.make(rss_version) do |m|
    set_bogus_header m
  end
  parsed_feed.items.concat feed.items
  parsed_feed.items.sort! { |a, b| b.date <=> a.date }
  while !(parsed_feed.items.delete_at(how_many)).nil?
  end
  parsed_feed
end

def fetch(uri_str, limit = 5)
  # You should choose better exception.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  url = URI.parse(uri_str)
  # req = Net::HTTP::Get.new(url.path, { 'User-Agent' => ua })
  req = Net::HTTP::Get.new(url.path)
  response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
  case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  else
    response.error!
  end
end


def get_xml_with_retry url
  if !url.start_with?("http")
    return File.new(url).read
  end

  body = nil
  # will try 5 times to get a complete xml document
  count = 0
  begin 
    count += 1
    $stderr.print "Fetching "+url+" #{count}\n" if $is_debug
    # body = Net::HTTP.get(URI(url)) if body.nil?
    body = fetch(url).body
    if body.nil? or body.strip == ""
      raise "Empty body"
    end
    # retry on incomplete xml file
    # if not Nokogiri::XML(body).validate
    #   $stderr.print "Incomplete body {",body,"}\n"
    #   raise "XML incomplete"
    # end
  rescue Exception => e
    $stderr.print e.message
    if count < 3
      $stderr.print " Retry (#{count})\n"
      sleep 1
      retry 
    end
    raise e
  end
  body
end

def set_bogus_header m
  m.channel.title = "tmp"
  m.channel.link = "tmp"
  m.channel.description = "tmp"
end

