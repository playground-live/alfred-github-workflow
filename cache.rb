require './cache_update.rb'

#cache method
module Cache 
  include CacheUpdate 

    # upadate all repositoriese cache
  def rebuild_user_repos_cache
    File.delete(@cache_file) if File.exists?(@cache_file)
    cache_all_repos_for_user
  end

  # upadate all issues cache of current repo
  def rebuild_user_issues_cache
    File.delete(@issue_cache_file) if File.exists?(@issue_cache_file)
    cache_all_issues_for_repo
  end

  # upadate all closed issues cache of current repo
  def rebuild_user_close_issues_cache
    File.delete(@all_issue_cache_file) if File.exists?(@all_issue_cache_file)
    cache_all_close_issues_for_repo
  end
end