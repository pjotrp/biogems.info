#! /bin/sh
#
# Create the website

# Download stats
./bin/list-bio.rb > ./var/bio-projects.yaml 
# bundle exec ./bin/list-bio.rb > ./var/bio-projects.yaml 

# RSS
bundle exec ./bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

