require_relative 'request'
class Github
  module Search
    include Request
    # search all repositories in github
    def search_all_repos(query)
      return [] if !query || query.empty?
      parts = query.split('/', 2)

      if parts.length == 1 && !parts[0].empty?
        res = get '/search/repositories', 'q' => query

        if res.is_a?(Hash) && res.key?('items')
          res['items'].map do |repo|
            { 'name' => repo['full_name'], 'url' => repo['html_url'] }
          end
        else
          []
        end
      elsif parts.length == 2 && !parts[0].empty?
        user = parts[0]
        user_query = parts[1]
        res = get "/users/#{user}/repos"

        if res.is_a?(Array)
          repos = res.select do |repo|
            repo['name'] =~ Regexp.new(user_query, 'i')
          end
          repos.map do |repo|
            { 'name' => repo['full_name'], 'url' => repo['html_url'] }
          end
        else
          []
        end
      else
        []
      end
    end

    # search all issues in github
    def search_all_issues(query)
      return [] if !query || query.empty?

      parts = query.split('/', 2)

      if parts.length == 1 && !parts[0].empty
        res = get "/orgs/#{load_current_repo}/issues", 'q' => query

        if res.is_a?(Hash) && res.key?('items')
          res['items'].map do |issue|
            { 'name' => issue['title'], 'url' => issue['html_url'] }
          end
        else
          []
        end
      elsif parts.length == 2 && !parts[0].empty?
        user_query = parts[1]
        res = get "/users/#{load_current_repo}/issues"

        if res.is_a?(Array)
          repos = res.select do |repo|
            repo['name'] =~ Regexp.new(user_query, 'i')
          end
          repos.map do |issue|
            { 'name' => issue['title'], 'url' => issue['html_url'] }
          end
        else
          []
        end
      else
        []
      end
    end

    # search all closed issues in github
    def search_all_close_issues(query)
      return [] if !query || query.empty?

      parts = query.split('/', 2)

      if parts.length == 1 && !parts[0].empty
        res = get "/orgs/#{load_current_repo}/issues", 'state' => 'closed'

        if res.is_a?(Hash) && res.key?('items')
          res['items'].map do |issue|
            { 'name' => "#{issue['title']}[closed]", 'url' => issue['html_url'] }
          end
        else
          []
        end
      elsif parts.length == 2 && !parts[0].empty?
        user_query = parts[1]
        res = get "/users/#{load_current_repo}/issues", 'state' => 'closed'

        if res.is_a?(Array)
          repos = res.select do |repo|
            repo['name'] =~ Regexp.new(user_query, 'i')
          end
          repos.map do |issue|
            { 'name' => "#{issue['title']}[closed]", 'url' => issue['html_url'] }
          end
        else
          []
        end
      else
        []
      end
    end
  end
end
