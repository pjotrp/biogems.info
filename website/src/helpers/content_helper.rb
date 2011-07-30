require 'yaml'

module ContentHelper
  def by_popularity
    spec = YAML::load(File.new("./etc/bio-projects.yaml").read)
    sorted = spec.sort { |a, b| b[1][:downloads] <=> a[1][:downloads] }
    i = 0
    dl = 0
    descr = 'unknown'
    sorted.each do | rec |
      name = rec[0]
      i += 1
      plugin = spec[name]
      descr = plugin[:summary]
      descr = plugin[:description] if !descr
      # docs
      docs = plugin[:homepage]   # from the biogem descr
      docs = plugin[:homepage_uri] if !docs
      docs = plugin[:project_uri] if !docs
      docs = plugin[:source_code_uri] if !docs
      yield i,plugin[:downloads].to_i,name,normalize(descr),plugin[:authors].join(', '),docs
    end
  end

  def normalize s
    s = s.sub(/\.$/,'')
    s = s.capitalize
    s = s.gsub(/ruby/i,'Ruby')
    s = s.gsub(/bioruby/i,'BioRuby')
    s = s.gsub(/gem/i,'gem')
    s
  end
end
