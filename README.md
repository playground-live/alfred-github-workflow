# Create issue

簡単にissueを作成できるalfred workflow

# 使い方

ダウンロードしてください

<a href="./Create issue.alfredworkflow?raw=true">ダウンロード</a>

## 認証
```
gh-auth
```

![open github page](images/open_auth.png)

repo権限のみをつけたtokenを発行して、取得したtokenをコピーする

![get auth token](images/get_token.png)

```
gh-auth 取得したtoken
```

![register your auth token](images/input_access_token.png)

## Repositoryを登録

どのRepositoryにIssueを作るか登録します
```
repo issueを作りたいRepository
```

![select your repo](images/select_repo.jpg)

## issue検索
```
issue 名前
```
![search issue](images/search_issue.png)

## closed issue検索
```
close-issue 名前
```

![search issue](images/search_closed_issue.png)

## issue作成

```
create-issue issueの名前
```

![create issue](images/create_issue.png)

issueが作成できました

![issue page](images/github_issue.png)

## cacheのupdate

```
update-cache
```

![update cache](images/update_cache.png)

***
### 参考リンク
- Github API: https://developer.github.com/v3/issues/
- Alfred.GithubRepos: https://github.com/edgarjs/alfred-github-repos
- Ruby HTTP 通信: https://docs.ruby-lang.org/ja/latest/library/net=2fhttp.html
- HTTP context type: https://altarf.net/computer/ruby/2890
***
### 開発

1. 修正
1. alfredでexport
1. exportしてできた.alfredworkflowファイルをこのディレクトリに移動(上書き)
1. push
