require 'net/http'
require 'json'
require './xml_builder'
require 'cgi'
require './tool.rb'
require './cache_store.rb'
require './load_cache.rb'
require './search.rb'

class InvalidToken < StandardError; end

# method with github
class Github
  include Tool
  include CacheStore
  include LoadCache
  include Search
  def initialize
    @token_file = '.auth_token'
    @base_uri = 'https://api.github.com'
    @cache_file = '.repositoriescache'
    @issue_cache_file = '.issuescache'
    @current_repo_file = '.currentrepo'
    @close_issue_cache_file = '.closeissuescache'
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

  # create a issue in current repositories
  def create(query)
    raise InvalidToken unless test_authentication
    load_token
    load_current_repo
    uri = URI.parse("https://api.github.com/repos/#{@current_repo}/issues?access_token=#{@token}")
    http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request.body = { 'title' => query }.to_json

    response = http.request(request)

    url = response.body
    JSON.parse(url)['html_url']
  end
end
