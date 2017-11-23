require 'net/http'
require 'json'
require './xml_builder'
require 'cgi'
require 'sqlite3'
require_relative 'github/request'
require_relative 'github/cache'

class InvalidToken < StandardError; end

# method with github
class Github
  include Request
  include Cache

  TOKEN_FILE = '.auth_token'.freeze
  BASE_URI = 'https://api.github.com'.freeze
  CURRENT_REPO_FILE = '.currentrepo'.freeze
  USER_ACCOUNT_FILE = '.useraccountcache'.freeze

  # search repo from repositories cache file and github
  def search_repo(query, db)
    repos = load_and_cache_user_repos(db)
    results = repos.select do |repo|
      repo['name'] =~ Regexp.new(query, 'i')
    end
    results.uniq
    results
  end

  # search issue from repositories cache file and github
  def search_issue(query, db)
    issues = load_and_cache_user_issues(db)
    results = issues.select do |issue|
      issue['name'] =~ Regexp.new(query, 'i')
    end
    results.uniq
  end

  def search_assigned_issue(db)
    load_and_cache_user_assigned_issues(db)
  end

  # search closed issue from repositories cache file and github
  def search_close_issue(query, db)
    issues = load_and_cache_user_close_issues(db)
    results = issues.select do |issue|
      issue['name'] =~ Regexp.new(query, 'i')
    end
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
