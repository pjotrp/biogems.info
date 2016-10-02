# INSTALL

Biogem.info uses haml + sass to generate a website.

The site generation consists of a number of separate steps
which can easily be tested independently.

## Installation

The static website is generated with middleman. It takes SASS, HAML
and YAML files as inputs. I may take out the middleman at some point,
but now it is convenient enough.

To avoid rvm+bundler hell, the preferred route is to use GNU Guix and
set the environment with my
[ruby-guix-env](https://github.com/pjotrp/guix-notes/blob/master/scripts/ruby-guix-env)
script. E.g.

```sh
    guix install ruby rake ruby-nokogiri 
    . ruby-guix-env
    gem install bundler
    cd biogems.info # source dir
    bundle
```

You need to install bundler which is needed for middleman.

A 'quick' test run

  rake -- --test

## Generating the website

### Fetch biogems from rubygems.org

The first step is to fetch relevant gems from http://rubygems.org/. This
is done with

```sh
./bin/fetch-gemlist.rb
```
  
run a quicker test with

```sh
./bin/fetch-gemlist.rb --test > data/gemlist_biogems.yaml
```

To fetch rubygems (non-bio)

```sh
./bin/fetch-gemlist.rb --rubygems > data/gemlist_rubygems.yaml
```

### Expand rubygems info

In the second step use the YAML output from the first step to expand package information

```sh
   ./bin/fetch-geminfo.rb < list.yaml
```
   
or

```sh
   ./bin/fetch-geminfo.rb < data/gemlist_biogems.yaml >data/geminfo_biogems.yaml
```

### Fetch github info

In the third step fetch github information and run with the GITHUB TOKEN

```sh
env GITHUB_API_TOKEN="3b3955c1b672d0c4a7" ./bin/fetch-githubinfo.rb < data/geminfo_biogems.yaml > data/biogems.yaml
```

## Fetch biolinux and Debian bio-med info

```sh
    ./scripts/create_biolinux_tab.sh > data/biolinux.yaml
```

## Test the website

Simple run middleman to build and view the website

```sh
bundle exec middleman build
bundle exec middleman
```

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
