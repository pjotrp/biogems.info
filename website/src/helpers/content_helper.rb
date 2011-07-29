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
      yield i,plugin[:downloads],name,descr,plugin[:authors].join(', ')
    end
  end
end
