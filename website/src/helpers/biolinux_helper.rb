require 'ostruct'

module BiolinuxHelper
  def news_items
    news = YAML::load(File.new("./var/news.yaml").read)
    news.each do | item |
      item[:date].to_s =~ /(\d+-\d+-\d+)/
      item[:short_date] = $1
      yield item
    end
  end

  def biolinux_by_popularity(type = nil)
    projects_fn = "./var/biolinux-packages.yaml"
    packages = YAML::load(File.new(projects_fn).read)
    packages = {} if not packages
    # packages.each do |name,pkg|   
    #   $stderr.print name,"\n"
    # end
    sorted = packages.sort { |a, b| b[1]["downloads"] <=> a[1]["downloads"] }
    # now iterate for display
    i = 0
    sorted.each do | name, rec |
      # - description: Basic Local Alignment Search Tool
      #   downloads: 64
      #   homepage_uri: http://www.ncbi.nih.gov/BLAST/
      #   name: blast2
      #   section: science
      #   version: 1:2.2.25.20110713-3ubuntu2
      #   :tab: :biolinux
      #   :biomed: true
      $stderr.print rec
      pkg = OpenStruct.new
      pkg.name = rec["name"]
      pkg.descr = rec["description"]
      pkg.downloads = rec["downloads"]
      if pkg.descr
        words = pkg.descr.split(/ /)[0..MAX_WORDS]
        pkg.descr = words.join(" ");
      end
      pkg.version = rec["version"]
      pkg.is_biomed = rec[:biomed]
      pkg.is_biolinux = rec[:biolinux]
      pkg.is_custom = rec[:custom]
      pkg.home = rec["homepage_uri"] 
      if pkg.is_biomed 
        pkg.origin = "Debian"
        pkg.url = "http://packages.debian.org/"+pkg.name
        pkg.version_url = "https://launchpad.net/+search?field.text="+pkg.name
      elsif pkg.is_biolinux and not pkg.is_custom
        pkg.origin = "BioLinux"
        pkg.url = "http://nebc.nerc.ac.uk/tools/bio-linux/other-bl-docs/package-repository"
        pkg.home = pkg.url if pkg.home == ""
      elsif pkg.is_custom
        pkg.origin = "CloudBiolinx "
        pkg.url = "https://github.com/chapmanb/cloudbiolinux/tree/master/cloudbio/custom"
      else
        pkg.url = pkg.home
      end
   
      # docs - just get the most likely one
      if false
        docs = rec[:docs_uri]   # from the biogem descr
        home = rec[:homepage]
        home = rec[:source_code_uri] if !home or home==''
        home = rec[:project_uri] if !home or home==''
        src = rec[:source_code_uri]
        src = home if !src
        cite = rec[:doi]
        if cite
          cite = 'http://dx.doi.org/'+rec[:doi] if cite !~ /^http:/
        end
        issues = rec[:issues]
        if not issues 
          issues = src
          issues += '/issues' if issues =~ /github/
        end
        num_issues = rec[:num_issues]
        num_issues = '' if num_issues == nil
        num_issues = '...' if num_issues == 0
        commit = rec[:commit]
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
        rec[:authors] = [] if not rec[:authors]

        test_info = {}
        user = rec[:github_user]
        project = rec[:github_project]
        if rec[:travis_url]
          test_info[:url] = rec[:travis_url]
        else
          test_info[:url] = "http://travis-ci.org/#!/#{user}/#{project}"
        end
        if rec[:travis_img]
          test_info[:image] = rec[:travis_img]
        else
          test_info[:image] = "https://secure.travis-ci.org/#{user}/#{project}.png?branch=master"
        end

        authors = rec[:authors][0..NUM_AUTHORS-1].map{ |a| a.gsub(/ /,"&nbsp") }.join(', ')
        authors += ' <i>et al.</i>' if rec[:authors].size > NUM_AUTHORS
      end
      yield i+1,pkg
      i += 1
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

end
