#! /bin/sh
#
# Create the website

# Download stats
./bin/list-bio.rb > ./var/bio-projects.yaml 

# RSS
./bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

