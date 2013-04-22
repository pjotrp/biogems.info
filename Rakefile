$:.unshift File.join(File.dirname(__FILE__),'lib')

BIOGEMS = './var/bio-projects.yaml'
RUBYGEMS = './var/ruby-projects.yaml'
GENERATE_DATA_FILES = [ 
  BIOGEMS,
  RUBYGEMS,
  './var/news.yaml'
]

file RUBYGEMS do |t|
  require 'biogems/fetch'
  File.open(t.name,'w'){|f| f.print fetch('--rubygems') }
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

task :rss => BIOGEMS 

desc "Fetch gem info and write YAML to stdout (optionally use -- --test)"
task :biogems => [ BIOGEMS ] do |t|
  load 'bin/fetch-geminfo.rb'
end

task :default => [ :biogems ] do
  `staticmatic build website/`
end


