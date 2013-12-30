#! /bin/bash
#
# Create the website
#
# To run with GITHUB token, first set 
#
#   export GITHUB_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxx
#
# run the small test with
#
#   ./scripts/create_website.sh --test
#   
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
mkdir -p ./data

echo Github token=$GITHUB_API_TOKEN
print_github_limits
[ $? -ne 0 ] && exit 1

# curl http://github.com/api/v2/json/issues/list/pjotrp/bioruby-affy/open
echo "Fetching data/biogems.yaml"
bundle exec ./bin/fetch-geminfo.rb $* > ./data/biogems.yaml1
[ $? -ne 0 ] && exit 1
sed -e 's/!!null//g' < ./data/biogems.yaml1 > ./data/biogems.yaml
[ $? -ne 0 ] && exit 1
echo "Fetching data/ruby-projects.yaml"
# bundle exec ./bin/fetch-geminfo.rb $* --rubygems > ./data/ruby-projects.yaml1
# sed -e 's/!!null//g' < ./data/ruby-projects.yaml1 > ./data/ruby-projects.yaml

# Create RSS feed for others to use
echo "Fetching data/rss.xml"
bundle exec ./bin/rss.rb $* > ./source/rss.xml
[ $? -ne 0 ] && exit 1

# Generate site 
bundle exec middleman build --verbose
[ $? -ne 0 ] && exit 1

print_github_limits

