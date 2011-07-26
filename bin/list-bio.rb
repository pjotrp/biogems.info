#! ruby

require 'yaml'
require "net/http"
require "uri"


print "Using Ruby ",RUBY_VERSION,"\n"

projects = Hash.new

list = `gem list -r --no-versions bio`.split(/\n/)
list = ['bio-logger']
list.each do | name |
  info = Hash.new
  # fetch = `gem specification -r #{name.strip}`
  fetch = `gem specification #{name.strip}`
  spec = YAML::load(fetch)
  print fetch
  ivars = spec.ivars
  info[:authors] = ivars["authors"]
  info[:summary] = ivars["summary"]
  info[:homepage] = ivars["homepage"]
  info[:licenses] = ivars["licenses"]
  info[:description] = ivars["description"]
  ver = ivars["version"].ivars['version']
  info[:version] = ver
  # Now query rubygems.org directly
  uri = URI.parse("http://rubygems.org/api/v1/gems/#{name}.yaml")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  if response.code.to_i==200
    print response.body       
    biogems = YAML::load(response.body)
    info[:downloads] = biogems["downloads"]
    info[:version_downloads] = biogems["version_downloads"]
    info[:gem_uri] = biogems["gem_uri"]
    info[:dependencies] = biogems["dependencies"]
  else
    raise Exception.new("Response code for #{name} is "+response.code)
  end
  projects[name] = info
end
print projects.to_yaml
