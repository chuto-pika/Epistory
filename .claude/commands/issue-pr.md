以下の手順を実行してください：

1. 現在のGitブランチ名からIssue番号を抽出する（`feature/issue-<番号>-...` の形式）
2. `docs/issues.md` を読み、該当Issueのセクションを探す
3. チェックボックスの完了状況を確認し、未完了のタスクがあれば警告する
4. **完了条件に手動確認項目がある場合は、PR作成前に実施して結果を確認する**
5. **`docs/issues.md` の該当Issueの「やること」チェックボックスを全て `[x]` に更新する**
6. **以下のチェックを実行し、全てパスすることを確認する：**
   - `docker compose exec web bundle exec rubocop` (lint)
   - `docker compose exec web bundle exec brakeman -q` (セキュリティ)
   - `docker compose exec web bundle exec bundle-audit check --update` (依存関係の脆弱性)
   - `docker compose exec web rails test` (ユニットテスト)
7. Issueの概要・やること・完了条件をもとに、PRのタイトルと本文を日本語で生成する
8. **PRの本文には必ず `Closes #<Issue番号>` を含める**（マージ時にIssueが自動クローズされる）
9. **テスト計画の項目は全てチェック済み `[x]` の状態にする**
10. 変更をプッシュし、`gh pr create` でPRを作成する（ベースブランチ: main）

## チェック結果の許容基準

- **RuboCop**: 違反0件であること
- **Brakeman**: High/Medium の脆弱性がないこと（Unmaintained Dependency の警告は許容）
- **bundler-audit**: Rails 7.0 関連の既知の警告は許容（後でアップグレード予定）
- **rails test**: 全テストがパスすること

## PR本文のテンプレート

```markdown
## 概要
〇〇を実装しました。

Closes #<Issue番号>

## やったこと
- ...

## テスト結果
- RuboCop: 違反0件
- Brakeman: High/Medium脆弱性なし
- bundler-audit: （既知の警告のみ）
- rails test: X runs, X assertions, 0 failures

## テスト計画
- [x] 項目1
- [x] 項目2（手動確認含む）

## 依存Issue
- #X（完了済み）
```
