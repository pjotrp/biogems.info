$:.unshift File.join(File.dirname(__FILE__),'lib')

file "./var/bio-projects.yaml" do |t|
  target = t.name
  `./bin/list-bio.rb > #{target}`
end

file "./website/site/rss.xml" => ["./var/bio-projects.yaml", "./etc/blogs.yaml"] do |t|
  require 'biogems/rss'
  projects, blogs = t.prerequisite_tasks.map(&:name)
  File.open(t.name,'w') do |f|
    f.print generate_biogems_rss_feed(projects, blogs, 50).to_s
  end
end

file "./var/news.yaml" =>"./website/site/rss.xml" do |t|
  require 'yaml'
  require 'rss'

  feed = RSS::Parser.parse File.read(t.prerequisite_tasks[0].name), false

  site_news = feed.items.inject(Array.new) do |news, item|
    if item.date.to_i > Time.now.to_i - 356*24*3600
      entry = { :title => item.title, :date => item.date, :link => item.link } 
      news << entry
    end
    news
  end

  File.open(t.name,'w'){|f| YAML.dump(site_news,f) }
end
