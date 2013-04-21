$:.unshift File.join(File.dirname(__FILE__),'lib')

file "./var/bio-projects.yaml" do |t|
  target = t.name
  `./bin/list-bio.rb > #{target}`
end

file "./website/site/rss.xml" => "./var/bio-projects.yaml" do |t|
  require 'yaml'
  require 'biogems/rss'

  # First generate the YAML file
  feed = generate_biogems_rss_feed "./var/bio-projects.yaml", "./etc/blogs.yaml", 50

  site_news = []
  feed.items.each do | item |
    if item.date.to_i > Time.now.to_i - 356*24*3600
      entry = { :title => item.title, :date => item.date, :link => item.link } 
      site_news << entry
    end
  end

  # print site_news

  # write a YAML file for the site
  File.open('./var/news.yaml','w') do | f |
    YAML.dump(site_news,f)
  end


  target = t.dependencies.first

  File.open(target,'w'){|out| out.puts feed}
end
