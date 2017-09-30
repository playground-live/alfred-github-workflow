require './github.rb'

query = ARGV[0]
github = Github.new

begin
  if query == '--auth'
    github.store_token(ARGV[1])
  else
    raise InvalidToken unless github.test_authentication
    if query == '--update'
      github.rebuild_user_repos_cache
      github.rebuild_user_issues_cache
      github.rebuild_user_close_issues_cache
    elsif query == '--repo'
      github.store_current_repo(ARGV[1])
      github.rebuild_user_issues_cache
      github.rebuild_user_close_issues_cache
    elsif query == '--create'
      result = github.create(ARGV[1].tr('\\', ' '))
    elsif query == '--updateissues'
      github.rebuild_user_issues_cache
      github.rebuild_user_close_issues_cache
    elsif query == '--searchrepos'
      results = github.search_repo(ARGV[1] || '')
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
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
          if !results.empty?
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
    elsif query == '--searchallissue'
      results = github.search_close_issue(ARGV[1] || '')
      results += github.search_issue(ARGV[1] || '')
      output = XmlBuilder.build do |xml|
        xml.items do
          if !results.empty?
            results.each do |repo|
              xml.item Item.new(repo['url'], repo['url'], repo['name'], repo['url'], 'yes')
            end
          else
            xml.item Item.new(
              nil, query, 'the current repo is empty!', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
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
              nil, query, 'the current repo is empty!', 'Please input gi-repo and set the repo where the issue want to create', 'yes', 'FE3390F7-206C-45C4-94BB-5DD14DE23A1B.png'
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
        'gh-error', 'gh-auth ', 'Missing or invalid token!', 'Please set your token with gh-auth. ↩ to go there now.', 'yes'
      )
    end
  end

  puts output
end
