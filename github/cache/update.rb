class Github
  module Cache
    # update cache method
    module Update
      # upadate all repositoriese cache
      def rebuild_user_repos_cache
        File.delete(CACHE_FILE) if File.exist?(CACHE_FILE)
        cache_all_repos_for_user
      end

      # update user account
      def rebuild_user_account
        File.delete(USER_ACCOUNT_FILE)  if File.exist?(USER_ACCOUNT_FILE)
        cache_user_account
      end
      # upadate all issues cache of current repo
      def rebuild_user_issues_cache
        File.delete(ISSUE_CACHE_FILE) if File.exist?(ISSUE_CACHE_FILE)
        cache_all_issues_for_repo
      end

      # upadate all closed issues cache of current repo
      def rebuild_user_close_issues_cache
        File.delete(ALL_ISSUE_CACHE_FILE) if File.exist?(ALL_ISSUE_CACHE_FILE)
        cache_all_close_issues_for_repo
      end

      def rebuild_user_assgined_issues_cache
        File.delete(ASSIGNED_ISSUE_FILE) if File.exist?(ASSIGNED_ISSUE_FILE)
        cache_all_assigned_issues_for_repo
      end

      # put all repositorise data to cache file
      def cache_all_repos_for_user
        repos = get_user_repos
        get_user_orgs.each do |org|
          repos += get_org_repos(org['login'])
        end
        File.open(CACHE_FILE, 'w') do |f|
          f.write repos.to_json
        end

        repos
      end

      def cache_user_account
        res = get '/user'
        user_account = res['login']
        File.open(USER_ACCOUNT_FILE, 'w') do |f|
          f.write user_account.to_json  
        end
      end

      # communicate with github to get repositories of user
      def get_user_repos
        res = get '/user/repos'
        if res.is_a?(Array)
          res.map do |repo|
            { 'name' => repo['full_name'], 'url' => repo['html_url'] }
          end
        else
          []
        end
      end

      # communicate with github to get login of organization
      def get_user_orgs
        res = get '/user/orgs'
        if res.is_a?(Array)
          res.map do |org|
            { 'login' => org['login'] }
          end
        else
          []
        end
      end

      # communicate with github to get repositories of organization
      def get_org_repos(org)
        res = get "/orgs/#{org}/repos"
        if res.is_a?(Array)
          res.map do |repo|
            { 'name' => repo['full_name'], 'url' => repo['html_url'] }
          end
        else
          []
        end
      end

      # put all issues data to cache file
      def cache_all_issues_for_repo
        issues = get_repo_issues
        File.open(ISSUE_CACHE_FILE, 'w') do |f|
          f.write issues.to_json
        end

        issues
      end


      # communicate with github to get issues of user
      def get_repo_issues
        res = get "/repos/#{load_current_repo}/issues"
        if res.is_a?(Array)
          res.map do |issue|
            { 'name' => issue['title'], 'url' => issue['html_url'] }
          end
        else
          []
        end
      end

      # put all closed issues data to cache file
      def cache_all_close_issues_for_repo
        issues = get_repo_close_issues
        File.open(ALL_ISSUE_CACHE_FILE, 'w') do |f|
          f.write issues.to_json
        end

        issues
      end

      def cache_all_assigned_issues_for_repo
        issues = get_repo_assigned_issues
        File.open(ASSIGNED_ISSUE_FILE, 'w') do |f|
          f.write issues.to_json
        end
        issues
      end

      def get_repo_assigned_issues
        json_result = []
        res = get "/repos/#{load_current_repo}/issues"

        results = res.reject do |result|
          result['assignee'].nil?
        end

        results.each do |assignees|
          assignees['assignees'].each do |assigned|
            if assigned['login'] == "akias"
              json_result << assignees
            else
              []
            end
          end
        end

        json_result.map do |issue|
          { 'name' => "#{issue['title']}[assigned]", 'url' => issue['html_url'] }
        end
      end

      # communicate with github to get closed issues of user
      def get_repo_close_issues
        # 'state' => 'closed' is the parameters of 'get'  default is 'opend'
        res = get "/repos/#{load_current_repo}/issues", 'state' => 'closed'
        if res.is_a?(Array)
          res.map do |issue|
            { 'name' => "#{issue['title']}[closed]", 'url' => issue['html_url'] }
          end
        else
          []
        end
      end
    end
  end
end
