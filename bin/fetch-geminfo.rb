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

# Return the number of downloads in the last 90 days
# Also returns whether a gem is new or not
def get_downloads90 name, versions
  $stderr.print "Get downloads 90 days for #{name}\n"
  version_numbers = versions.map { |ver| ver['number'] }
  total = 0
  is_new = true
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
    is_new = false if Time.now - t > 6*7*24*3600 
    break if Time.now - t > 90*24*3600 # skip older
  end
  return total,is_new
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

nlist = {}

h.each do | gem, info |
  info = {} if not info 
  $stderr.print "Fetching rubygem.org gem info for ",gem,"\n"
  command = "gem specification -r #{gem.strip}"
  $stderr.print "RUNNING "+command+"\n"
  fetch = `#{command}`
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
    info[:downloads90],info[:recent_gem] = get_downloads90(gem, versions)
  else
    info[:version]     = 'pre'
    info[:status]      = 'pre'
    info[:downloads]   = 0
    info[:downloads90] = 0
  end
  nlist[gem] = info
end

print nlist.to_yaml

