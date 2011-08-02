require 'yaml'

module ContentHelper
  def by_popularity
    spec = YAML::load(File.new("./var/bio-projects.yaml").read)
    sorted = spec.sort { |a, b| b[1][:downloads] <=> a[1][:downloads] }
    # rank trend
    sorted90 = spec.sort { |a, b| b[1][:downloads90] <=> a[1][:downloads90] }
    rank90 = {}
    sorted90.each_with_index do | rec, i |
      name = rec[0]
      rank90[name] = i
    end
    # now iterate for display
    dl = 0
    descr = 'unknown'
    sorted.each_with_index do | rec, i |
      name = rec[0]
      plugin = spec[name]
      descr = plugin[:summary]
      descr = plugin[:description] if !descr
      version = plugin[:version]
      # docs - just get the most likely one
      docs = plugin[:docs_uri]   # from the biogem descr
      home = plugin[:homepage]
      home = plugin[:homepage_uri] if !home or home==''
      home = plugin[:source_code_uri] if !home or home==''
      home = plugin[:project_uri] if !home or home==''
      src = plugin[:source_code_uri]
      src = home if !src
      cite = plugin[:doi]
      if cite
        cite = 'http://dx.doi.org/'+plugin[:doi] if cite != /^http:/
      end
      issues = plugin[:issues]
      if not issues 
        issues = src
        issues += '/issues' if issues =~ /github/
      end
      # calc trend
      trend_direction = 0
      if rank90[name] < i - 2
        trend_direction = +1
      end
      if rank90[name] > i + 2
        trend_direction = -1
      end

      yield i,plugin[:downloads90],plugin[:downloads],name,plugin[:status],version,normalize(descr),cite,plugin[:authors].join(', '),home,docs,src,issues,trend_direction,rank90[name]
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
