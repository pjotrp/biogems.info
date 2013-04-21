#! /bin/sh
#
# Create the website

# Download stats
curl https://api.github.com/rate_limit

# curl http://github.com/api/v2/json/issues/list/pjotrp/bioruby-affy/open
./bin/list-bio.rb $* > ./var/bio-projects.yaml 
./bin/list-bio.rb --rubygems > ./var/ruby-projects.yaml
# bundle exec ./bin/list-bio.rb > ./var/bio-projects.yaml 

# RSS
bundle exec ./bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

curl https://api.github.com/rate_limit
