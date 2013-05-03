#! /bin/sh
#
# Create the website

# Download stats
curl https://api.github.com/rate_limit

# curl http://github.com/api/v2/json/issues/list/pjotrp/bioruby-affy/open
bundle exec ./bin/fetch-geminfo.rb $* > ./var/bio-projects.yaml 
bundle exec ./bin/fetch-geminfo.rb --rubygems > ./var/ruby-projects.yaml
# bundle exec ./bin/fetch-geminfo.rb > ./var/bio-projects.yaml 

# Create RSS feed for others to use
bundle exec ./bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

curl https://api.github.com/rate_limit
