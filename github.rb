require 'net/http'
require 'json'
require './xml_builder'
require 'cgi'
require_relative 'github/request'
require_relative 'github/cache'
require_relative 'github/search'

class InvalidToken < StandardError; end

# method with github
class Github
  include Request
  include Cache
  include Search

  TOKEN_FILE = '.auth_token'.freeze
  BASE_URI = 'https://api.github.com'.freeze
  CACHE_FILE = '.repositoriescache'.freeze
  ISSUE_CACHE_FILE = '.issuescache'.freeze
  CURRENT_REPO_FILE = '.currentrepo'.freeze
  ALL_ISSUE_CACHE_FILE = '.allissuescache'.freeze

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
    load_token
    load_current_repo
    result = post("/repos/#{@current_repo}/issues?access_token=#{@token}", query)
    puts result
  end

  # test the auth token
  def test_authentication
    load_token
    return false if !@token || @token.empty?
    res = get '/'
    !res.key?('error')
  end
end
