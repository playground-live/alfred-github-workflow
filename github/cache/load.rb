require_relative 'update'
# get the data in cache
class Github
  module Cache
    module Load
      include Update
      def load_token
        @token = File.read(TOKEN_FILE).strip if File.exist?(TOKEN_FILE)
      end

      def load_current_repo
        @current_repo = File.read(CURRENT_REPO_FILE) if File.exist?(CURRENT_REPO_FILE)
      end

      def load_user_account
        @user_account = File.read(USER_ACCOUNT_FILE) if File.exist?(USER_ACCOUNT_FILE)  
      end

      def load_and_cache_user_repos(db)
        db.results_as_hash = true
        requests = db.execute('select *from repos')
        requests
      end

      def load_and_cache_user_issues(db)
        db.results_as_hash = true
        requests = db.execute("select *from issues where status = 'open' order by id desc")
        requests
      end

      def load_and_cache_user_close_issues(db)
        db.results_as_hash = true
        requests = db.execute("select *from issues where status = 'closed' order by id desc")
        requests
      end

      def load_and_cache_user_assigned_issues(db)
        db.results_as_hash = true
        requests = db.execute('select *from assigned_issues order by id desc')
        requests
      end
    end
  end
end
