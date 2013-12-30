#! /bin/sh
#
# Create the website (partial)

# Download stats
./bin/create-biolinux-db.rb $* > ./var/biolinux.yaml

# Generate site into website/site/
staticmatic build website/

