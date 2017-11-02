require_relative 'load'
# store token and current_repo
class Github
  module Cache
    # Store date method
    module Store
      include Load
      # stor the token write in TOKEN_FILE
      def store_token(token)
        return unless token && !token.empty?
        File.open(TOKEN_FILE, 'w') do |f|
          f.write(token)
        end
        load_token
        rebuild_user_repos_cache
      end

      # store current_repo write in CURRENT_REPO_FILE
      def store_current_repo(repo)
        return unless repo && !repo.empty?
        File.open(CURRENT_REPO_FILE, 'w') do |f|
          f.write(repo)
        end
      end
    end
  end
end
