#! ruby

require 'yaml'
require "net/http"
require "uri"

is_testing = ARGV[0] == '--testing'

# list of biogems not starting with bio- (bio dash)
ADD = %w{ bio ruby-ensembl-api genfrag eutils dna_sequence_aligner }

print "# Generated by #{__FILE__} #{Time.now}\n"
print "# Using Ruby ",RUBY_VERSION,"\n"

projects = Hash.new

list = `gem list -r --no-versions bio-`.split(/\n/)
list += ADD
if is_testing
  list = ['bio-logger']
end

def check_url url
  if url =~ /^http:\/\//
    $stderr.print "Checking #{url}..."
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code.to_i == 200 and response.body !~ /301 Moved/
      $stderr.print "pass!\n"
      return url
    end
    $stderr.print "failed!\n"
  end
  nil
end

def get_downloads90 name, version
  url="http://rubygems.org/api/v1/versions/#{name}-#{version}/downloads.yaml"
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  if response.code.to_i != 200
    raise Exception.new("page not found "+url)
  end
  dated_stats = YAML::load(response.body)
  stats = dated_stats.map { | i | i[1] }
  total = stats.inject {|sum, n| sum + n } 
  total
end

list.each do | name |
  $stderr.print name,"\n"
  info = Hash.new
  fetch = `gem specification -r #{name.strip}`
  spec = YAML::load(fetch)
  # print fetch
  ivars = spec.ivars
  info[:authors] = ivars["authors"]
  info[:summary] = ivars["summary"]
  ver = ivars["version"].ivars['version']
  info[:version] = ver
  # set homepage
  info[:homepage] = check_url(ivars["homepage"])
  info[:licenses] = ivars["licenses"]
  info[:description] = ivars["description"]
  # Now query rubygems.org directly
  uri = URI.parse("http://rubygems.org/api/v1/gems/#{name}.yaml")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  if response.code.to_i==200
    # print response.body       
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
    raise Exception.new("Response code for #{name} is "+response.code)
  end
  info[:docs_uri] = "http://rubydoc.info/gems/#{name}/#{ver}/frames" if not info[:docs_uri]

  info[:downloads90] = get_downloads90(name, ver)
  projects[name] = info
end
print projects.to_yaml
