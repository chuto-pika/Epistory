# 開発環境ガイド

## Dockerでのファイル権限問題

Dockerコンテナ内で作成されたファイルは`root`所有になることがあります。
これにより以下のようなエラーが発生する場合があります：

```
error: unable to unlink old 'path/to/file': Permission denied
```

### 解決方法

```bash
# プロジェクトディレクトリで実行
sudo chown -R $USER:$USER .
```

### 推奨ワークフロー

Dockerでファイルを生成した後（`rails g`コマンドなど）は、上記コマンドを実行してからgit操作を行ってください。

```bash
# 例: Dockerでマイグレーション作成後
docker compose exec web rails g migration AddColumnToUsers name:string
sudo chown -R $USER:$USER .
git add .
git commit -m "Add name column to users"
```

---

## PR作成時のルール

### Issueの自動クローズ

PRの本文には必ず `Closes #<Issue番号>` を含めること。
これによりPRがマージされた際にIssueが自動的にクローズされる。

```markdown
## 概要
〇〇を実装しました。

Closes #4
```

### テスト計画の完全実施

PRの「テスト計画」に記載した項目は、PR作成前に全て実施すること。
手動確認が必要な項目（例: `rails console` での動作確認）も忘れずに行う。

```markdown
## テスト計画
- [x] `rails db:migrate` がエラーなく完了する
- [x] 各モデルのバリデーションが正しく動作する（テストで確認）
- [x] `rails console` でレコードの作成・取得ができる  ← 手動確認も忘れずに
```
