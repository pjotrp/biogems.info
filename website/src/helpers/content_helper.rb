require 'yaml'

module ContentHelper
  def by_popularity
    spec = YAML::load(File.new("./var/bio-projects.yaml").read)
    sorted = spec.sort { |a, b| b[1][:downloads90] <=> a[1][:downloads90] }
    i = 0
    dl = 0
    descr = 'unknown'
    sorted.each do | rec |
      name = rec[0]
      i += 1
      plugin = spec[name]
      descr = plugin[:summary]
      descr = plugin[:description] if !descr
      version = plugin[:version]
      # docs - just get the most likely one
      docs = plugin[:docs_uri]   # from the biogem descr
      home = plugin[:homepage]
      home = plugin[:homepage_uri] if !home
      home = plugin[:source_code_uri] if !home
      home = plugin[:project_uri] if !home
      yield i,plugin[:downloads90],plugin[:downloads],name,version,normalize(descr),plugin[:authors].join(', '),home,docs
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
