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

token = ENV['GITHUB_API_TOKEN']
if not token or token == ''
  raise "Github token is missing"
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

h = YAML.load(ARGF.read)

h.each do | gem, info |
  print gem,"\n"
  for uri in [:source_code_uri, :homepage, :homepage_uri, :project_uri] do
     if info[uri] =~ /^http:\/\/github/
       info[uri].sub!(/^http:\/\/github\.com/,"https://github.com")
     end
  end
  for uri in [:source_code_uri, :homepage, :homepage_uri, :project_uri] do
    if info[uri] =~ /github\.com/
      project_info = get_github_project_info(info[uri])
      info[:github_issues] = project_info["open_issues"]
      info[:github_stargazers] = project_info["stargazers_count"]
      
      user,project = get_github_user_project(info[uri])
      info[:github_user] = user
      info[:github_project] = project
      weekly = get_github_commit_stats(info[uri])
      if weekly
        info[:github_7d_commits] = weekly[-1].to_i
        info[:github_90d_commits] = weekly[-13..-1].map { |x| x.to_i }.inject(:+)
      end
      break # only do one
    end
  end
end

print h.to_yaml
