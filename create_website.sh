#! /bin/sh
#
# Create the website

# Download stats
ruby bin/list-bio.rb > ./var/bio-projects.yaml 

# RSS
ruby bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

