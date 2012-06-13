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
      user,project = get_github_user_project(github_uri)
      url = "http://github.com/legacy/issues/search/#{user}/#{project}/open/number"
      $stderr.print url,"\n"
      issues = JSON.parse(Http::get_http_body(url))
      if issues == nil or issues == {}
        $stderr.print "\nWARNING: issues link not working!\n"
        issues = {"issues"=>[]} 
      end
      $stderr.print issues['issues'].size, "\n" 
      issues['issues']
    end
 

  end

end
