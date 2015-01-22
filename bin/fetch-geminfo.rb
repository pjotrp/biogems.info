#!/usr/bin/env ruby
#
# This script fetches information of bioruby gems, first querying the gem
# tool, followed by visiting rubygems.org and github.com.

$: << "lib"

require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'biogems'
# require 'thread/pool'

include BioGemInfo
include BioGemInfo::GitHub

IS_NEW_IN_DAYS = 7*6   # 6 weeks

$stderr.print ENV['GITHUB_API_TOKEN']

$is_debug = ARGV.index('--debug')  
is_testing = ARGV.index('--test')  
is_rubygems = ARGV.index('--rubygems')
is_biogems = !is_rubygems

# We fetch all gems automatically that start with bio- (bio dash). 
# This is the list of biogems not starting with bio- (bio dash) - actually this should move to 
# /etc!
# ADD = %w{ }

$stderr.print "# testing!!\n" if is_testing
print "# testing!!\n" if is_testing
print "# rubygems!!\n" if is_rubygems
print "# Generated by #{__FILE__} #{Time.now}\n"
print "# Using Ruby ",RUBY_VERSION,"\n"

projects = Hash.new

# Set up the search using a local gem tool
$stderr.print "Querying gem list\n" if $is_debug
list = []
if is_biogems
  # We re-read the last information from the resident YAML file.
  if is_testing
    list = ['bio-logger', 'bio-table']
  else
    list = `gem list -r --no-versions bio-`.split(/\n/)
    prerelease = `gem search -r --prerelease --no-versions bio-`.split(/\n/)
    list += prerelease
    # list += ADD
    list += Dir.glob("./etc/biogems/*.yaml").map { |fn| File.basename(fn).sub(/.yaml$/,'') }
  end
end

if is_rubygems
  list = if not is_testing
           Dir.glob("./etc/rubygems/*.yaml").map { |fn| File.basename(fn).sub(/.yaml$/,'') }
         else
           [ 'sciruby' ]
         end
end

# Return the working URL, otherwise nil
def check_url url
  if url =~ /^http:\/\/github/
    url = url.sub(/^http:\/\/github\.com/,"https://github.com")
  end
  if url =~ /^http:\/\//
    $stderr.print "Checking #{url}..." if $is_debug
    begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if response.code.to_i == 200 and response.body !~ /301 Moved/
        $stderr.print "pass!\n" if $is_debug
        return url
      elsif response.code.to_i == 301
        raise LoadError
      end
    rescue LoadError
      url = response['location']
      retry
    rescue
      $stderr.print $!
    end
    $stderr.print "check_url failed!\n" if $is_debug
  end
  nil
end

def get_versions name
  url = "https://rubygems.org/api/v1/versions/#{name}.json"
  versions = JSON.parse(Http::get_https_body(url))
  versions
end

def get_downloads90 name, versions
  version_numbers = versions.map { | ver | ver['number'] }
  total = 0
  version_numbers.each do | ver |
    # curl https://rubygems.org/api/v1/versions/bio-logger-1.0.1/downloads.yaml
    url="https://rubygems.org/api/v1/versions/#{name}-#{ver}/downloads.yaml"
    text = Http::get_https_body(url)
    dated_stats = YAML::load(text)
    stats = dated_stats.map { | i | i[1] }
    ver_total90 = stats.inject {|sum, n| sum + n } 
    total += ver_total90 if ver_total90;
  end
  total
end

def get_github_commit_stats github_uri
  begin
    user,project = get_github_user_project(github_uri)
    url = "https://github.com/#{user}/#{project}/graphs/participation"
    $stderr.print url if $is_debug
    body = Http::get_https_body(url)
    if body.strip == "" || body.nil? || body == "{}"
      # try once more
      body = Http::get_https_body(url)
    end
    if body.strip == "" || body.nil?
      # data not retrieved, set safe default for JSON parsing
      body = "{}"
    end
    stats = JSON.parse(body)
  rescue
    $stderr.print "Print could not fetch ",url
    return nil
  end
  if stats.empty?
    return nil
  else
    return stats['all']
  end
end

def update_status(projects)
  for biogem in ['bio-biolinux','bio-core-ext','bio-core','bio'] do 
    $stderr.print "Getting status of #{biogem}\n" if $is_debug
    uri = URI.parse("http://rubygems.org/api/v1/gems/#{biogem}.yaml")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code.to_i==200
      # print response.body       
      biogems = YAML::load(response.body)
      biogems["dependencies"]["runtime"].each do | runtime |
        n = runtime["name"]
        if projects[n]
          projects[n][:status] = biogem
        else
          $stderr.print "Warning: can not find #{n} for #{biogem}\n" if $is_debug
        end
      end
    else
      raise Exception.new("Response code for #{name} is "+response.code)
    end
  end
end

list_in_random_order = list.uniq # .sort_by { rand }

# pool = Thread.pool(3) # fires up 3 Rubies - make sure you have the RAM :)

list_in_random_order.each do | name |
  # pool.process do
    $stderr.print name,"\n" if $is_debug
    info = Hash.new
    # Fetch the gem YAML definition of the project
    $stderr.print "bundle exec gem specification -r #{name.strip}\n" if $is_debug
    fetch = `bundle exec gem specification -r #{name.strip}`
    if fetch != ''
      spec = YAML::load(fetch)
      # print fetch
      # p spec
      # When you get undefined method `authors' for #<Syck::Object:0x000000028cf3f0> (NoMethodError) make sure you try with 'bundle exec' instead!
      info[:authors] = spec.authors
      info[:summary] = spec.summary
      info[:version] = spec.version.to_s
      info[:release_date] = spec.date
      info[:homepage] = spec.homepage
      info[:licenses] = spec.licenses.join(' ')
      info[:description] = spec.description
    else
      info[:version] = 'pre'
      info[:status]  = 'pre'
    end
    # Query rubygems.org directly
    uri = URI.parse("http://rubygems.org/api/v1/gems/#{name}.yaml")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code.to_i==200
      $stderr.print response.body if $is_debug
      biogems = YAML::load(response.body)
      info[:downloads] = biogems["downloads"]
      info[:version_downloads] = biogems["version_downloads"]
      info[:gem_uri] = biogems["gem_uri"]
      info[:homepage_uri] = check_url(biogems["homepage_uri"])
      info[:project_uri] = check_url(biogems["project_uri"])
      info[:source_code_uri] = biogems["sourcecode_uri"]
      info[:docs_uri] = check_url(biogems["documentation_uri"])
      info[:dependencies] = biogems["dependencies"]
      # query for recent downloads
    else
      $stderr.print "ERROR: Response code for #{name} is #{response.code}, skipping...\n"
      next
    end
    info[:docs_uri] = "http://rubydoc.info/gems/#{name}/#{info[:version]}/frames" if not info[:docs_uri]
    versions = get_versions(name)
    info[:downloads90] = get_downloads90(name, versions)
    $stderr.print info if $is_debug
    # if a gem is less than one month old, mark it as new
    if versions.size <= 5
      is_new = true
      versions.each do | ver |
        date = ver['built_at']
        date.to_s =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d)/
        t = Time.new($1.to_i,$2.to_i,$3.to_i)
        if Time.now - t > IS_NEW_IN_DAYS*24*3600
          is_new = false
          break
        end
      end
      info[:status] = 'new' if is_new
    end
    # Now parse etc/biogems/name.yaml
    fn = "./etc/biogems/#{name}.yaml" if is_biogems
    fn = "./etc/rubygems/#{name}.yaml" if is_rubygems
    if File.exist?(fn)
      added = YAML::load(File.new(fn).read)
      added = {} if not added 
      info = info.merge(added)
    end
    if info[:status].to_s =~ /^(delete|disable|remove)/i 
      $stderr.print info[:status]," skipping!\n" if $is_debug
      next 
    end
    # Replace http with https
    for uri in [:source_code_uri, :homepage, :homepage_uri, :project_uri] do
      if info[uri] =~ /^http:\/\/github/
        info[uri] = info[uri].sub(/^http:\/\/github\.com/,"https://github.com")
      end
    end

    # Check github stuff
    # print info
    for uri in [:source_code_uri, :homepage, :homepage_uri, :project_uri] do
      if info[uri] =~ /^https:\/\/github\.com/
        info[:num_issues] = get_github_issues(info[uri]).size
        info[:num_stargazers] = get_github_stargazers(info[uri]).size
        user,project = get_github_user_project(info[uri])
        info[:github_user] = user
        info[:github_project] = project
        info[:commit_stats] = get_github_commit_stats(info[uri])
        break
      end
    end

    $stderr.print info if $is_debug
    $stderr.print "---> Completed #{name}\n"
    projects[name] = info
  # end
end

# pool.shutdown

# Read the status of bio-core, bio-core-ext and bio-biolinux
# packages
update_status(projects) if is_biogems

print projects.to_yaml  # output to STDOUT
