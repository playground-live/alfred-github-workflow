require './cache_update.rb'

module CacheLoad
  include CacheUpdate
  
    # get token which store in token file
  def load_token
    @token = File.read(@token_file).strip if File.exists?(@token_file)
  end

  # get current repositories in current repositories file
  def load_current_repo
    raise InvalidToken unless test_authentication
    @current_repo = File.read(@current_repo_file) if File.exists?(@current_repo_file)
  end

  # get all repositories in cache file
  def load_and_cache_user_repos
    if File.exists?(@cache_file)
      JSON.parse(File.read(@cache_file))
    else
      cache_all_repos_for_user
    end
  end



  # get all issues data to cache file
  def load_and_cache_user_issues
    if File.exists?(@issue_cache_file)
      JSON.parse(File.read(@issue_cache_file))
    else
      cache_all_issues_for_repo
    end
  end

  # get all closed issues data to cache file
  def load_and_cache_user_close_issues
    if File.exists?(@all_issue_cache_file)
      JSON.parse(File.read(@all_issue_cache_file))
    else
      cache_all_close_issues_for_repo
    end
  end
end