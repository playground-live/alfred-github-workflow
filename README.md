# Create issue

簡単にissueを作成できるalfred workflow

# 使い方

## 認証
```
gh-auth
```

![open github page]('./images/open_auth.png')

repo権限のみをつけたtokenを発行して、取得したtokenをコピーする

![get auth token]('./images/get_token.png')

```
gh-auth 取得したtoken
```

![register your auth token]('./images/input_access_token.png')

## Repositoryを登録

どのRepositoryにIssueを作るか登録します
```
repo issueを作りたいRepository
```

![select your repo]('./images/select_repo.png')

## issue作成

```
create-issue issueの名前
```

![create issue]('./images/create_issue.png')

issueが作成できました

![create issue]('./images/github_issue.png')
