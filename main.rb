require './github.rb'
require 'sqlite3'

query = ARGV[0]
github = Github.new

begin
  db = SQLite3::Database.new('github.sqlite')
  if query == '--auth'
    github.store_token(ARGV[1])
    github.rebuild_user_account
  else
    raise InvalidToken unless github.test_authentication
    if query == '--update'
      github.rebuild_user_repos_cache(db)
      github.rebuild_user_issues_cache(db)
      github.rebuild_user_assigned_issues_cache(db)
    elsif query == '--repo'
      github.store_current_repo(ARGV[1])
      github.rebuild_user_issues_cache(db)
      github.rebuild_user_assigned_issues_cache(db)
    elsif query == '--create'
      result = github.create(ARGV[1].tr('\\', ' '))
    elsif query == '--updateissues'
      github.cache_all_issues_for_repo(db)
      github.cache_all_assigned_issues_for_repo(db)
    elsif query == '--searchrepos'
      results = github.search_repo(ARGV[1] || '', db)
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
            results.each do |repo|
              xml.item Item.new(repo['url'], repo['name'], repo['name'], repo['url'], 'yes')
            end
          else
            xml.item Item.new(
              nil, query, 'Update the repository cache and try again.', 'Rebuilds your local cache from GitHub, then searches again; gh-update to rebuild anytime.', 'yes', 'error.png'
            )
          end
        end
      end

      puts output
    elsif query == '--searchissues'
      results = github.search_issue(ARGV[1] || '', db)
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
            results.each do |issue|
              xml.item Item.new(issue['url'], issue['url'], issue['name'.gsub('<',' ')], issue['url'], 'yes')
            end
          elsif github.load_current_repo.empty?
            xml.item Item.new(
              nil, query, 'the current repo is empty ', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          else
            xml.item Item.new(
              nil, query, 'there is no opened issue in this repo', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          end
        end
      end

      puts output

    elsif query == '--searchassignedissues'
      results = github.search_assigned_issue(db)
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
            results.each do |repo|
              xml.item Item.new(repo['url'], repo['url'], repo['name'], repo['url'], 'yes')
            end
          elsif github.load_current_repo.empty?
            xml.item Item.new(
              nil, query, 'the current repo is empty ', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          else
            xml.item Item.new(
              nil, query, 'there is no issue you have been assigned in this repo', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          end
        end
      end

      puts output
    elsif query == '--searchallissue'
      results = github.search_close_issue(ARGV[1] || '', db)
      results.each do |issue|
        issue['name'] = "#{issue['name']}[closed]"
      end
      results += github.search_issue(ARGV[1] || '', db)
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
            results.each do |issue|
              xml.item Item.new(issue['url'], issue['url'], issue['name'], issue['url'], 'yes')
            end
          elsif github.load_current_repo.empty?
            xml.item Item.new(
              nil, query, 'the current repo is empty ', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          else
            xml.item Item.new(
              nil, query, 'there is no issue in this repo', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          end
        end
      end
      puts output
    else
      result = github.load_current_repo
      output = XmlBuilder.build do |xml|
        xml.items do
          if !result.empty?
            xml.item Item.new(
              nil, query, 'the current repo is empty!', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'error.png'
            )
          else
            xml.item Item.new(nil, query, 'create issue', result, 'yes')
          end
        end
      end

      puts output
    end
  end
rescue InvalidToken
  output = XmlBuilder.build do |xml|
    xml.items do
      xml.item Item.new(
        'gh-error', 'gh-auth ', 'Missing or invalid token!', 'Please set your token with gh-auth. ↩ to go there now.', 'yes','error.png'
      )
    end
  end

  puts output
ensure
  db.close
end
