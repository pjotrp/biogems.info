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
      released = ''
      if plugin[:release_date]
        released = time_pretty(plugin[:release_date])
      end
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
        cite = 'http://dx.doi.org/'+plugin[:doi] if cite !~ /^http:/
      end
      issues = plugin[:issues]
      if not issues 
        issues = src
        issues += '/issues' if issues =~ /github/
      end
      num_issues = plugin[:num_issues]
      num_issues = '...' if num_issues == nil
      commit = plugin[:commit]
      if not commit
        commit = src
        commit += '/commits/master' if commit =~ /github/
      end
      # calc trend
      trend_direction = 0
      if rank90[name] < i - 4
        trend_direction = +1
      end
      if rank90[name] > i + 4
        trend_direction = -1
      end
      plugin[:authors] = [] if not plugin[:authors]

      test_info = {}
      user = plugin[:github_user]
      project = plugin[:github_project]
      test_info[:url]   = "http://travis-ci.org/#!/#{user}/#{project}"
      if plugin[:travis_img]
        test_info[:image] = plugin[:travis_img]
      else
        test_info[:image] = "https://secure.travis-ci.org/#{user}/#{project}.png?branch=master"
      end

      yield i+1,plugin[:downloads90],plugin[:downloads],name,plugin[:status],version,released,normalize(descr),cite,plugin[:authors].join(', '),home,docs,src,issues,num_issues,test_info,commit,trend_direction,rank90[name]
    end
  end

  def normalize s
    return '' if s == nil
    s = s.sub(/\.$/,'')
    s = s.capitalize
    s = s.gsub(/ruby/i,'Ruby')
    s = s.gsub(/bioruby/i,'BioRuby')
    s = s.gsub(/gem/i,'gem')
    s
  end

  def time_pretty s
    s.to_s =~ /^(\d\d\d\d)\-(\d\d)\-(\d\d)/
    t = Time.new($1.to_i,$2.to_i,$3.to_i)
    days = ((Time.now-t)/3600/24).to_i
    case days
      when 0 then return 'today'
      when 1 then return '1 day'
      when 2..6 then return days.to_s+' days'
      when 7..13 then return '1 week'
      when 14..84 then return (days/7).to_i.to_s+' weeks'
      when 85..730 then return (days/30).to_i.to_s+' months'
    end
    return (days/365).to_i.to_s+' years'

  end

end
