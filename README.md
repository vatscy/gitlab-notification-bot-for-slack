# GitLab Notification for Slack

[GitLab](https://about.gitlab.com/) のWebhookを受けてSlackに通知を行います。  
現在、Merge request eventsにのみ対応しています。

当ツールは [Hubot](http://www.heroku.com) フレームワークを基に作られたSlack用botです。

## セットアップ

ここでは [Heroku](https://dashboard.heroku.com/) を利用する場合の手順を記載します。

以下を前提とします。
- Herokuアカウントを持っていること
- [Heroku Toolbelt](https://toolbelt.heroku.com/) がインストールされていること

### Herokuへデプロイ

Personal appを作成してデプロイします。

    % heroku create
    % git push heroku master

### SlackにIntegrationを追加

[Slack App Directory](https://slack.com/apps) から対象のSlackドメインに [Hubot Integration](https://slack.com/apps/A0F7XDU93-hubot) をインストールします。  
通知時のユーザーネーム、アイコンなどを設定します。

### 通知対象チャンネルにbotを招待

Integrationを追加するとbotが1ユーザーとしてSlackに参加する。  
通知を受け取るチャンネルにbotを招待します。

    /invite @<botname>

### Herokuに環境変数を設定

Integrationを追加した際に発行されたAPI Tokenを設定します。

    % heroku config:set HUBOT_SLACK_TOKEN=<api-token>

また、対象のGitLabのドメイン(例: `https://example.gitlab.com` )を設定します。

    % heroku config:set GITLAB_URL=<url>

### GitLab Webhooksの設定

対象リポジトリの Settings > Web Hooks にてWebhookの設定を行います。

URLには以下を設定します。

    https://<heroku-domain>/merge_request/<slack-channel-name>

例: チャンネル名が `#hoge` の場合: `https://example.heroku.com/merge_request/hoge`

## 通知機能

botは、マージリクエストが作成された際にSlackの当該チャンネルに以下の内容を発言します。

- 作成者名
- 作成日時
- マージリクエストURL
- タイトル
- 説明
