$:.unshift File.join(File.dirname(__FILE__),'lib')

BIOGEMS = './data/biogems.yaml'
RUBYGEMS = './data/rubygems.yaml'
GENERATE_DATA_FILES = [ 
  BIOGEMS,
  RUBYGEMS,
  './data/news.yaml'
]

file BIOGEMS => [ :biogems ]

file RUBYGEMS => [ :biogems ]

file "./source/rss.xml" => ["./data/biogems.yaml", "./etc/blogs.yaml"] do |t|
  require 'biogems/rss'
  projects, blogs = t.prerequisite_tasks.map(&:name)
  File.open(t.name,'w') do |f|
    f.print generate_biogems_rss_feed(projects, blogs, 50).to_s
  end
end

file "./data/news.yaml" =>"./source/rss.xml" do |t|
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

task :rss => [ "./source/rss.xml" ]

desc "Fetch gem info and write to data directory (optionally use -- --test)"
task :biogems do |t|
  %x{./bin/fetch-geminfo.rb #{ARGV.join(' ')} 1>&2}
end

task :default => [ :biogems ] do
  `middleman build`
end


