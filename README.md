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

![select your repo](images/select_repo.png)

## issue検索
```
issue 名前
```
![search issue](images/search_issue.png)

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

### 開発

1. 修正
1. alfredでexport
1. exportしてできた.alfredworkflowファイルをこのディレクトリに移動(上書き)
1. push
