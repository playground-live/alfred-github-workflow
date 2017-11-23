class Github
  module Cache
    module Update
      # upadate all repositoriese cache
      def rebuild_user_repos_cache(db)
        sql = <<-SQL
          create table if not exists repos(
            id integer PRIMARY KEY,
            name varchar(200),
            url varchar(100)
          );
        SQL
        db.execute(sql)
        db.execute('delete from repos')
        cache_all_repos_for_user(db)
      end

      # update user account
      def rebuild_user_account
        File.delete(USER_ACCOUNT_FILE) if File.exist?(USER_ACCOUNT_FILE)
        cache_user_account
      end

      # upadate all issues cache of current repo
      def rebuild_user_issues_cache(db)
        sql = <<-SQL
        create table if not exists issues(
          id integer PRIMARY KEY,
          name varchar(200),
          url varchar(100),
          status varchar(20)
        );
        SQL
        db.execute(sql)
        db.execute('delete from issues')

        cache_all_issues_for_repo(db)
      end

      def rebuild_user_assigned_issues_cache(db)
        sql = <<-SQL
        create table if not exists assigned_issues(
          id integer PRIMARY KEY,
          name varchar(200),
          url varchar(100)
        );
        SQL
        db.execute(sql)
        db.execute('delete from assigned_issues')
        cache_all_assigned_issues_for_repo(db)
      end

      # put all repositorise data to cache file
      def cache_all_repos_for_user(db)
        repos = get_user_repos
        get_user_orgs.each do |org|
          repos += get_org_repos(org['login'])
        end

        sql = 'insert or replace into repos values (?, ?, ?)'
        repos.each do |repo|
          db.execute(sql, repo['id'], repo['name'], repo['url'])
        end
      end

      def cache_user_account
        res = get '/user'
        user_account = res['login']
        File.open(USER_ACCOUNT_FILE, 'w') do |f|
          f.write user_account
        end
      end

      # communicate with github to get repositories of user
      def get_user_repos
        res = get '/user/repos'
        if res.is_a?(Array)
          res.map do |repo|
            { 'id' => repo['id'], 'name' => repo['full_name'], 'url' => repo['html_url'] }
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
      def cache_all_issues_for_repo(db)
        issues = get_repo_issues

        sql = 'insert or replace into issues values (?, ?, ?, ?)'
        issues.each do |issue|
          db.execute(sql, issue['id'], issue['name'], issue['url'], issue['state'])
        end

        issues
      end

      # communicate with github to get issues of user
      def get_repo_issues
        res = get "/repos/#{load_current_repo}/issues", 'state' => 'all'
        if res.is_a?(Array)
          res.map do |issue|
            { 'id' => issue['id'], 'name' => issue['title'], 'url' => issue['html_url'] , 'state' => issue['state'] }
          end
        else
          []
        end
      end

      def cache_all_assigned_issues_for_repo(db)
        issues = get_repo_assigned_issues
        sql = 'insert or replace into assigned_issues values (?, ?, ?)'
        issues.each do |issue|
          db.execute(sql, issue['id'], issue['name'], issue['url'])
        end

      end

      def get_repo_assigned_issues
        json_result = []
        res = get "/repos/#{load_current_repo}/issues"

        results = res.reject do |result|
          result['assignee'].nil?
        end

        results.each do |assignees|
          assignees['assignees'].each do |assigned|
            if assigned['login'] == load_user_account
              json_result << assignees
            else
              []
            end
          end
        end

        json_result.map do |issue|
          { 'id' => issue['id'], 'name' => "#{issue['title']}[assigned]", 'url' => issue['html_url'] }
        end
      end

    end
  end
end
