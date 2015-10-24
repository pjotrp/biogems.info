#!/usr/bin/env ruby
#
# This is the second step for generating biogems.info

# This script fetches information of bioruby gems

$: << "lib"

require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'biogems'

include BioGemInfo

def get_versions name
  url = "https://rubygems.org/api/v1/versions/#{name}.json"
  versions = JSON.parse(Http::get_https_body(url))
  versions
end

def get_downloads90 name, versions
  $stderr.print "Get downloads 90 days for #{name}\n"
  version_numbers = versions.map { |ver| ver['number'] }
  total = 0
  version_numbers.each_with_index do |version,i|
    url="https://rubygems.org/api/v1/versions/#{name}-#{version}/downloads.yaml"
    text = Http::get_https_body(url)
    dated_stats = YAML::load(text)
    stats = dated_stats.map { | i | i[1] }
    ver_total90 = stats.inject {|sum, n| sum + n } 
    total += ver_total90 if ver_total90;
    date = versions[i]["created_at"]
    date.to_s =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d)/
    t = Time.new($1.to_i,$2.to_i,$3.to_i)
    break if Time.now - t > 90*24*3600 # skip older
  end
  total
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

h = YAML.load(ARGF.read)

h.each do | gem, info |
  $stderr.print "Fetching rubygem.org gem info for ",gem,"\n"
  fetch = `gem specification -r #{gem.strip}`
  if fetch != ''
    spec = YAML::load(fetch)
    info[:authors] = spec.authors
    info[:summary] = spec.summary
    info[:version] = spec.version.to_s
    info[:release_date] = spec.date
    info[:homepage] = spec.homepage
    info[:licenses] = spec.licenses.join(' ')
    info[:description] = spec.description
    $stderr.print "Fetching download counts\n"
    downloads = YAML.load Http.get_https_body("https://rubygems.org/api/v1/downloads/#{gem}-#{spec.version}.yaml")
    info[:downloads] = downloads[:total_downloads]
    info[:version_downloads] = downloads[:version_downloads]
    versions = get_versions(gem)
    info[:downloads90] = get_downloads90(gem, versions)
  else
    info[:version] = 'pre'
    info[:status]  = 'pre'
  end
end

print h.to_yaml
exit 0

[].each do 
  info[:docs_uri] = "http://rubydoc.info/gems/#{name}/#{info[:version]}/frames" if not info[:docs_uri]
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
        project_info = get_github_project_info(info[uri])
        info[:num_issues] = project_info["open_issues"]
        info[:num_stargazers] = project_info["stargazers_count"]

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

