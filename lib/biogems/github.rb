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

    def github_api_helper github_uri,method
      user,project = get_github_user_project(github_uri)
      url = "https://api.github.com/repos/#{user}/#{project}/#{method}"
      # $stderr.print url,"\n"
      res = JSON.parse(Http::get_https_body(url))
      if res == nil or res == {}
        $stderr.print "WARNING: link not working! "
        $stderr.print url,"\n"
        res = []
      end
      $stderr.print "Found ",res.size, "github issues\n" if $is_debug
      res
    end
  end

end
