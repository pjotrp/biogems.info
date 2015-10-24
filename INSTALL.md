# INSTALL

Biogem.info uses haml + sass to generate a website.

The site generation consists of a number of separate steps
which can easily be tested independently.

## Installation

To avoid rvm+bundler hell, the preferred route is to use GNU Guix and
set the environment with my
[ruby-guix-env](https://github.com/pjotrp/guix-notes/blob/master/scripts/ruby-guix-env)
script. E.g.

    guix install ruby rake
    . ruby-guix-env
    gem install haml sass

To run the cucumber tests

  cucumber features/

A 'quick' test run

  rake -- --test

## Generating the website

### Fetch gems from rubygems.org

The first step is to fetch relevant gems from http://rubygems.org/. This
is done with

  ./bin/fetch-gemlist.rb

## Troubleshooting

If you get an error

  ./bin/fetch-geminfo.rb:163:in `block in <main>': undefined method `authors'

run the script with 'bundle exec' prepended.

### GitHub API access limits

Without using authentication, the GitHub API allows only 60 requests
per hour from a single IP address. But during the data collection
phase of generating the biogems.info website, the script currently
needs to make around 200 requests to this API to fetch the number of
issues and stargazers for each gem.

To get around this, go to the applications tab on your GitHub
settings page and generate a new "Personal API access token". Then
copy that token (but not into the repository!), and before running the ./create_data.sh script,
set the GITHUB_API_TOKEN environment variable like this:

    export GITHUB_API_TOKEN="copy-here-the-token-string-from-github"

That lets the script make 5000 requests per hour, which should be
more then enough.
