require_relative 'load'
# store token and current_repo
class Github
  module Cache
    module Store
      include Load
      # stor the token write in @token_file
      def store_token(token)
        if token && token.length > 0
          File.open(@token_file, 'w') do |f|
            f.write(token)
          end
          load_token
          rebuild_user_repos_cache
        end
      end

      # store current_repo write in @current_repo_file
      def store_current_repo(repo)
        if repo && repo.length > 0
          File.open(@current_repo_file, 'w') do |f|
            f.write(repo)
          end
        end
      end
    end
  end
end