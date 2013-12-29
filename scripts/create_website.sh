#! /bin/bash
#
# Create the website
#
# To run with GITHUB token, first set 
#
#   export GITHUB_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxx
#   


# Helper functions

## GitHub stats
function print_github_limits {
  RATE_LIMIT_URL="https://api.github.com/rate_limit"

  if [ -z "$GITHUB_API_TOKEN" ]; then
    curl $RATE_LIMIT_URL
  else
    curl -H "Authorization: token $GITHUB_API_TOKEN" $RATE_LIMIT_URL
  fi
}


# Work starts here

echo Github token=$GITHUB_API_TOKEN
print_github_limits

# curl http://github.com/api/v2/json/issues/list/pjotrp/bioruby-affy/open
bundle exec ./bin/fetch-geminfo.rb $* > ./data/bio-projects.yaml1
sed -e 's/!!null//g' < ./data/bio-projects.yaml1 > ./data/bio-projects.yaml
# bundle exec ./bin/fetch-geminfo.rb $* --rubygems > ./data/ruby-projects.yaml1
# sed -e 's/!!null//g' < ./data/ruby-projects.yaml1 > ./data/ruby-projects.yaml

# Create RSS feed for others to use
bundle exec ./bin/rss.rb > ./source/rss.xml

# Generate site 
bundle exec middleman server

print_github_limits

