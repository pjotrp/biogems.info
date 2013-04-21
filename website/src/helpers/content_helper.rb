require 'yaml'

MAX_WORDS = 7
NUM_AUTHORS = 3

module ContentHelper
  def news_items
    news = YAML::load(File.new("./var/news.yaml").read)
    news.each do | item |
      item[:date].to_s =~ /(\d+-\d+-\d+)/
      item[:short_date] = $1
      yield item
    end
  end

  def by_popularity(type = nil)
    projects_fn = "./var/bio-projects.yaml"
    projects_fn = "./var/ruby-projects.yaml" if type == :rubygems
    spec = YAML::load(File.new(projects_fn).read)
    spec = {} if not spec
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
    c7_max, c90_max = calculate_max_heuristics(spec)
    sorted.each_with_index do | rec, i |
      name = rec[0]
      plugin = spec[name]
      descr = plugin[:summary]
      descr = plugin[:description] if !descr
      if descr
        words = descr.split(/ /)[0..MAX_WORDS]
        descr = words.join(" ");
      end
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
      stargazers = plugin[:stargazers]
      if not stargazers
        stargazers = src
        stargazers += '/stargazers' if stargazers =~ /github/
      end
      num_stargazers = plugin[:num_stargazers]
      num_stargazers = '' if num_stargazers == nil
      issues = plugin[:issues]
      if not issues 
        issues = src
        issues += '/issues' if issues =~ /github/
      end
      num_issues = plugin[:num_issues]
      num_issues = '' if num_issues == nil
      num_issues = '...' if num_issues == 0
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
      if plugin[:travis_url]
        test_info[:url] = plugin[:travis_url]
      else
        test_info[:url] = "http://travis-ci.org/#!/#{user}/#{project}"
      end
      if plugin[:travis_img]
        test_info[:image] = plugin[:travis_img]
      else
        test_info[:image] = "https://secure.travis-ci.org/#{user}/#{project}.png?branch=master"
      end

      if plugin[:commit_stats]
        c7 = count_7day_commits(plugin[:commit_stats])
        c90 = count_90day_commits(plugin[:commit_stats])
      end

      c7_color = calculate_c7_color c7, c7_max
      c90_color = calculate_c90_color c90, c90_max

      authors = plugin[:authors][0..NUM_AUTHORS-1].map{ |a| a.gsub(/ /,"&nbsp") }.join(', ')
      authors += ' <i>et al.</i>' if plugin[:authors].size > NUM_AUTHORS
      yield i+1,plugin[:downloads90],plugin[:downloads],name,plugin[:status],version,released,normalize(descr),cite,authors,home,docs,src,stargazers,num_stargazers,issues,num_issues,test_info,commit,trend_direction,rank90[name],c7,c90,c7_color,c90_color
    end
  end

  def normalize s
    return '' if s == nil
    s = s.sub(/\.$/,'')
    s = s.capitalize
    s = s.gsub(/ruby/i,'Ruby')
    s = s.gsub(/bioruby/i,'BioRuby')
    s = s.gsub(/gem/i,'gem')
    s = s.gsub(/ipod/i,'iPod')
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

  def count_7day_commits stats
    stats[-1].to_i
  end

  def count_90day_commits stats
    stats.map { |x| x.to_i }[-13..52].inject(:+)
  end

  def calculate_max_heuristics spec
    clean_stats = spec.values.map { |rec| rec[:commit_stats] }.reject { |rec| rec.nil? }

    c7_max = clean_stats.map { |rec| count_7day_commits(rec) }.max
    c90_max = clean_stats.map { |rec| count_90day_commits(rec) }.max

    return c7_max, c90_max
  end

  def calculate_c7_color c7, c7_max
    return "#FFFFFF" if c7.nil? or c7_max == 0
    color_component = sprintf("%02X", 255 - (c7*255/c7_max/2))
    return "#" + color_component + "FF" + color_component
  end

  def calculate_c90_color c90, c90_max
    return "#FFFFFF" if c90.nil? or c90_max == 0
    color_component = sprintf("%02X", 255 - (c90*255/c90_max/2))
    return "#" + color_component + "FF" + color_component
  end

end
