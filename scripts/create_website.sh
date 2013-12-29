#! /bin/bash
#
# Create the website


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
bundle exec ./bin/fetch-geminfo.rb $* > ./var/bio-projects.yaml1
sed -e 's/!!null//g' < ./var/bio-projects.yaml1 > ./var/bio-projects.yaml
bundle exec ./bin/fetch-geminfo.rb --rubygems > ./var/ruby-projects.yaml1
sed -e 's/!!null//g' < ./var/ruby-projects.yaml1 > ./var/ruby-projects.yaml
# bundle exec ./bin/fetch-geminfo.rb > ./var/bio-projects.yaml 

# Create RSS feed for others to use
bundle exec ./bin/rss.rb > website/site/rss.xml

# Generate site into website/site/
staticmatic build website/

print_github_limits

