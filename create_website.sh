#! /bin/sh
#
# Create the website

# Download stats
ruby bin/list-bio.rb > ./var/bio-projects.yaml 

# Generate site into website/site/
staticmatic build website/
