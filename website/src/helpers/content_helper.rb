require 'yaml'

module ContentHelper
  def by_popularity
    spec = YAML::load(File.new("./etc/bio-projects.yaml").read)
    i = 0
    dl = 0
    descr = 'unknown'
    spec.each_key do | name |
      i += 1
      plugin = spec[name]
      descr = plugin[:summary]
      descr = plugin[:description] if !descr
      yield i,plugin[:downloads],name,normalize(descr),plugin[:authors].join(', ')
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
