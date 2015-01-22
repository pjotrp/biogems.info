# Github support. Test methods by hand with
#
# curl -H "Authorization: token XXXXXXXX" "https://api.github.com/repos/pjotrp/bigbio/stats/participation"

module BioGemInfo

  module GitHub

    # Split out the account and project name from a github URI
    def get_github_user_project github_uri
      tokens = github_uri.split(/\//).reverse
      project = tokens[0]
      user = tokens[1]
      return user, project
    end

    # Pass in a project URI, and return the issue list
    def get_github_issues github_uri
      github_api_helper github_uri,'issues'
    end

    # Pass in a project URI, and return the stargazer list
    def get_github_stargazers github_uri
      github_api_helper github_uri,'stargazers'
    end

    def valid_github_url user, project
      check_url("http//github.com/#{user}/#{project}")
    end

    def get_github_commit_stats github_uri
      begin
        user,project = get_github_user_project(github_uri)
        # url = "https://github.com/#{user}/#{project}/stats/participation"
        url = "https://api.github.com/repos/#{user}/#{project}/stats/participation"
        $stderr.print url if $is_debug
        body = Http::get_https_body(url)
        if body.strip == "" || body.nil? || body == "{}"
          # try once more
          body = Http::get_https_body(url)
        end
        if body.strip == "" || body.nil?
          # data not retrieved, set safe default for JSON parsing
          body = "{}"
        end
        stats = JSON.parse(body)
      rescue
        $stderr.print "Print could not fetch ",url,"\n"
        return nil
      end
      if stats.empty?
        return nil
      else
        return stats['all']
      end
    end

    def github_api_helper github_uri, method
      user,project = get_github_user_project(github_uri)
      url = "https://api.github.com/repos/#{user}/#{project}/#{method}"
      # $stderr.print url,"\n"
      res = JSON.parse(Http::get_https_body(url, auth_header))
      if res == nil or res == {}
        $stderr.print "WARNING: link not working! "
        $stderr.print url,"\n"
        res = []
      end
      $stderr.print "Found ",res.size, "github issues\n" if $is_debug
      res
    end

    def auth_header
      if ENV['GITHUB_API_TOKEN']
        { 'Authorization' => "token #{ENV['GITHUB_API_TOKEN']}" }
      else
        $stderr.print "No GITHUP_API_TOKEN defined\n"
        {}
      end
    end
  end

end
