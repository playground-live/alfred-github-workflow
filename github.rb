require 'net/http'
require 'json'
require './xml_builder'
require 'cgi'

class InvalidToken < StandardError; end

# method with github
class Github
  def initialize
    @token_file = '.auth_token'
    @base_uri = 'https://api.github.com'
    @cache_file = '.repositoriescache'
    @issue_cache_file = '.issuescache'
    @current_repo_file = '.currentrepo'
    @close_issue_cache_file = '.closeissuescache'
  end

  # stor the token write in @token_file
  def store_token(token)
    if token && token.length > 0
      File.open(@token_file, 'w') do |f|
        f.write(token)
      end
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

  # search repo from repositories cache file and github
  def search_repo(query)
    repos = load_and_cache_user_repos
    results = repos.select do |repo|
      repo['name'] =~ Regexp.new(query, 'i')
    end
    results += search_all_repos(query) if query =~ %r{\/}
    results.uniq
  end

  # search issue from repositories cache file and github
  def search_issue(query)
    issues = load_and_cache_user_issues
    results = issues.select do |issue|
      issue['name'] =~ Regexp.new(query, 'i')
    end
    results += search_all_issues(query) if query =~ %r{\/}
    results.uniq
  end

  # search closed issue from repositories cache file and github
  def search_close_issue(query)
    issues = load_and_cache_user_close_issues
    results = issues.select do |issue|
      issue['name'] =~ Regexp.new(query, 'i')
    end
    results += search_all_close_issues(query) if query =~ %r{\/}
    results.uniq
  end

  # get token which store in token file
  def load_token
    @token = File.read(@token_file).strip if File.exists?(@token_file)
  end

  # get current repositories in current repositories file
  def load_current_repo
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

  # put all repositorise data to cache file
  def cache_all_repos_for_user
    raise InvalidToken unless test_authentication
    repos = []
    repos += get_user_repos
    get_user_orgs.each do |org|
      repos += get_org_repos(org['login'])
    end
    File.open(@cache_file, 'w') do |f|
      f.write repos.to_json
    end

    repos
  end

  # get all issues data to cache file
  def load_and_cache_user_issues
    if File.exists?(@issue_cache_file)
      JSON.parse(File.read(@issue_cache_file))
    else
      cache_all_issues_for_repo
    end
  end

  # put all issues data to cache file
  def cache_all_issues_for_repo
    raise InvalidToken unless test_authentication
    issues = []
    issues += get_repo_issues
    File.open(@issue_cache_file, 'w') do |f|
      f.write issues.to_json
    end

    issues
  end

  # get all closed issues data to cache file
  def load_and_cache_user_close_issues
    if File.exists?(@close_issue_cache_file)
      JSON.parse(File.read(@close_issue_cache_file))
    else
      cache_all_close_issues_for_repo
    end
  end

  # put all closed issues data to cache file
  def cache_all_close_issues_for_repo
    raise InvalidToken unless test_authentication
    issues = []
    issues += get_repo_close_issues
    File.open(@close_issue_cache_file, 'w') do |f|
      f.write issues.to_json
    end

    issues
  end

  # create a issue in current repositories
  def create(query)
    load_token
    load_current_repo
    uri = URI.parse("https://api.github.com/repos/#{@current_repo}/issues?access_token=#{@token}")
    http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request.body = { 'title' => query }.to_json

    response = http.request(request)

    puts response.message
    puts response.code
  end

  # test the auth token
  def test_authentication
    load_token
    return false if !@token || @token.length == 0
    res = get "/"
    !res.has_key?('error')
  end

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
    File.delete(@close_issue_cache_file) if File.exists?(@close_issue_cache_file)
    cache_all_close_issues_for_repo
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

  # communicate with github to get closed issues of user
  def get_repo_close_issues
    #'state' => 'closed' is the parameters of 'get'  default is 'opend'
    res = get "/repos/#{load_current_repo}/issues", { 'state' => 'closed'}
    if res.is_a?(Array)
      res.map do |issue|
        { 'name' => issue['title'], 'url' => issue['html_url'] }
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

  # search all repositories in github
  def search_all_repos(query)
    return [] if !query || query.length == 0
    raise InvalidToken unless test_authentication

    parts = query.split('/', 2)

    if parts.length == 1 and parts[0].length > 0
      res = get '/search/repositories', { 'q' => query }

      if res.is_a?(Hash) and res.has_key?('items')
        res['items'].map do |repo|
          { 'name' => repo['full_name'], 'url' => repo['html_url'] }
        end
      else
        []
      end
    elsif parts.length == 2 and parts[0].length > 0
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
    return [] if !query || query.length == 0
    raise InvalidToken unless test_authentication

    parts = query.split('/', 2)

    if parts.length == 1 and parts[0].length > 0
      res = get "/orgs/#{load_current_repo}/issues", { 'q' => query }

      if res.is_a?(Hash) and res.has_key?('items')
        res['items'].map do |issue|
          { 'name' => issue['title'], 'url' => issue['html_url'] }
        end
      else
        []
      end
    elsif parts.length == 2 and parts[0].length > 0
      user = parts[0]
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
    return [] if !query || query.length == 0
    raise InvalidToken unless test_authentication

    parts = query.split('/', 2)

    if parts.length == 1 and parts[0].length > 0
      res = get "/orgs/#{load_current_repo}/issues", { 'state' => 'closed' }

      if res.is_a?(Hash) and res.has_key?('items')
        res['items'].map do |issue|
          { 'name' => issue['title'], 'url' => issue['html_url'] }
        end
      else
        []
      end
    elsif parts.length == 2 and parts[0].length > 0
      user = parts[0]
      user_query = parts[1]
      res = get "/users/#{load_current_repo}/issues", { 'state' => 'closed' }

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

  # communicate with github by get
  def get(path, params = {})
    params['per_page'] = 100
    qs = params.map { |k, v| "#{CGI.escape k.to_s}=#{CGI.escape v.to_s}" }.join('&')
    uri = URI("#{@base_uri}#{path}?#{qs}")

    json_all = []

    begin
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req['Accept'] = 'application/vnd.github.v3+json'
        req['Authorization'] = "token #{@token}"
        http.request(req)
      end

      json = JSON.parse(res.body)

      return { 'error' => json['message'] } unless res.kind_of? Net::HTTPSuccess

      if json.is_a?(Array)
        json_all.concat json
        uri = URI((res['link'].match /<([^>]+)>;\s*rel="next"/ )[1]) rescue nil
        break if uri.nil?
      else
        json_all = json
        break
      end
    end while true

    json_all
  end
end

########################################################################
########################################################################

query = ARGV[0]
github = Github.new

begin
  if query == '--update'
    github.rebuild_user_repos_cache
    github.rebuild_user_issues_cache
    github.rebuild_user_close_issues_cache
  elsif query == '--auth'
    github.store_token(ARGV[1])
  elsif query == '--repo'
    github.store_current_repo(ARGV[1])
    github.rebuild_user_issues_cache
    github.rebuild_user_close_issues_cache
  elsif query == '--create'
    github.create(ARGV[1].tr('\\', ' '))
    result = github.load_current_repo

    puts "#{result} #{ARGV[1].tr('\\', ' ')}"
  elsif query == '--searchrepos'
    results = github.search_repo(ARGV[1] || '')
    output = XmlBuilder.build do |xml|
      xml.items do
        if results.length > 0
          results.each do |repo|
            xml.item Item.new(repo['url'], repo['name'], repo['name'], repo['url'], 'yes')
          end
        else
          xml.item Item.new(
            nil, query, 'Update the repository cache and try again.', 'Rebuilds your local cache from GitHub, then searches again; gh-update to rebuild anytime.', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
          )
        end
      end
    end

    puts output
  elsif query == '--searchissues'
    results = github.search_issue(ARGV[1] || '')
    output = XmlBuilder.build do |xml|
      xml.items do
        if results.length > 0
          results.each do |repo|
            xml.item Item.new(repo['url'], repo['url'], repo['name'.gsub('<',' ')], repo['url'], 'yes')
          end
        else
          xml.item Item.new(
            nil, query, 'Update the repository cache and try again.', 'Rebuilds your local cache from GitHub, then searches again; gh-update to rebuild anytime.', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
          )
        end
      end
    end

    puts output
  elsif query == '--searchcloseissue'
    results = github.search_close_issue(ARGV[1] || '')
    output = XmlBuilder.build do |xml|
      xml.items do
        if results.length > 0
          results.each do |repo|
            xml.item Item.new(repo['url'], repo['url'], repo['name'], repo['url'], 'yes')
          end
        else
          xml.item Item.new(
            nil, query, 'Update the repository cache and try again.', 'Rebuilds your local cache from GitHub, then searches again; gh-update to rebuild anytime.', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
          )
        end
      end
    end

    puts output
  else
    result = github.load_current_repo
    output = XmlBuilder.build do |xml|
      xml.items do
        if result.length > 0
          xml.item Item.new(nil, query, 'create issue', result, 'yes')
        else
          xml.item Item.new(
            nil, query, 'Update the repository cache and try again.', 'Rebuilds your local cache from GitHub, then searches again; gh-update to rebuild anytime.', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
          )
        end
      end
    end

    puts output
  end
rescue InvalidToken
  output = XmlBuilder.build do |xml|
    xml.items do
      xml.item Item.new(
        'gh-error', 'gh-auth ', 'Missing or invalid token!', 'Please set your token with gh-auth. ↩ to go there now.', 'yes'
      )
    end
  end

  puts output
end
