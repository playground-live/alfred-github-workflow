require_relative 'update'
# get the data in cache
class Github
  module Cache
    # Load method
    module Load
      include Update
      # get token which store in token file
      def load_token
        @token = File.read(TOKEN_FILE).strip if File.exist?(TOKEN_FILE)
      end

      # get current repositories in current repositories file
      def load_current_repo
        @current_repo = File.read(CURRENT_REPO_FILE) if File.exist?(CURRENT_REPO_FILE)
      end

      # get all repositories in cache file
      def load_and_cache_user_repos
        if File.exist?(CACHE_FILE)
          JSON.parse(File.read(CACHE_FILE))
        else
          cache_all_repos_for_user
        end
      end

      # get all issues data to cache file
      def load_and_cache_user_issues
        if File.exist?(ISSUE_CACHE_FILE)
          JSON.parse(File.read(ISSUE_CACHE_FILE))
        else
          cache_all_issues_for_repo
        end
      end

      # get all closed issues data to cache file
      def load_and_cache_user_close_issues
        if File.exist?(ALL_ISSUE_CACHE_FILE)
          JSON.parse(File.read(ALL_ISSUE_CACHE_FILE))
        else
          cache_all_close_issues_for_repo
        end
      end
    end
  end
end
