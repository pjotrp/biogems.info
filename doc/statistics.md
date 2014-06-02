= Statistics =

== Introduction ==

In this document we describe how we fetch statistics relevant to the Bio* modules hosted
on http://biogems.info/. The goals are to 

* Get statistics on recent project activity
* Get statistics on recent developer activity
* Display these statistics on biogems.info
* Regularly update these statistics

== Gathering git repositories ==

Biogems.info aggregates software development modules. The primary list 
consists of bioinformatics modules. The main work for generating the 
website is through

```sh
./scripts/create_website.sh
```

which pulls current information for rubygems.org and github.com. The bulk of the work 
happens in

```sh
bundle exec ./bin/fetch-geminfo.rb $* > ./data/biogems.yaml1
bundle exec middleman build --verbose
```

We take ./data/biogems.yaml as the starting point for fetching all the git
repositories. After creating bioyems.yaml1 this will happen with

```sh
./scripts/update_statistics.sh
```

So on the machine we host the code in a git repository, e.g.,

```sh
mkdir -p ~/opt/ruby
cd ~/opt/ruby
git clone git@github.com:pjotrp/biogems.info.git
cd biogems.info
bundle
```

Probably need to install nokogiri separately with dependencies. Next create the YAML files

```sh
env GITHUB_API_TOKEN="XXXXXX" ./scripts/create_website.sh
```

So that ./data/biogems.yaml contains entries for every registered gem. The base entries are the
package names, but what interests us mostly are the entries

```ruby
  :github_user: csw
  :github_project: bioruby-maf
```

which allow us to clone and update the project source trees with

```sh
env GITHUB_API_TOKEN="XXXXXX" ./scripts/create_statistics.sh
```

