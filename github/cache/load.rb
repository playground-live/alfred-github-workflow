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

      def load_and_cache_user_repos
        if File.exist?(CACHE_FILE)
          JSON.parse(File.read(CACHE_FILE))
        else
          cache_all_repos_for_user
        end
      end

      def load_and_cache_user_issues
        if File.exist?(ISSUE_CACHE_FILE)
          JSON.parse(File.read(ISSUE_CACHE_FILE))
        else
          cache_all_issues_for_repo
        end
      end

      def load_and_cache_user_close_issues
        if File.exist?(ALL_ISSUE_CACHE_FILE)
          JSON.parse(File.read(ALL_ISSUE_CACHE_FILE))
        else
          cache_all_close_issues_for_repo
        end
      end

      def load_and_cache_user_assigned_issues
        if File.exist?(ASSIGNED_ISSUE_FILE)
          JSON.parse(File.read(ASSIGNED_ISSUE_FILE))
        else
          cache_all_assigned_issues_for_repo
        end
      end
    end
  end
end
