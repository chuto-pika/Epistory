# Epistory MVP - GitHub Issues

## Issue一覧（依存順）

| # | タイトル | 依存 |
|---|---------|------|
| 4 | Docker開発環境のセットアップ | なし |
| 6 | Renderデプロイ設定 | #4 |
| 5 | Tailwind CSS・Hotwireの導入と基本レイアウト作成 | #6 |
| 7 | マスターテーブルのモデル・マイグレーション作成 | #4 |
| 8 | シードデータの投入 | #7 |
| 9 | messagesテーブル・message_impressionsテーブルのモデル作成 | #7 |
| 10 | メッセージ生成ロジック（テンプレートエンジン）の実装 | #8, #9 |
| 11 | ステップフォーム（Step 1〜3）の実装 | #5, #8 |
| 12 | ステップフォーム（Step 4〜6）の実装 | #10, #11 |
| 13 | メッセージ表示画面の実装 | #12 |
| 14 | メッセージ編集機能の実装 | #13 |
| 15 | クリップボードコピー機能の実装 | #13 |
| 16 | 入力バリデーションとエラー表示の実装 | #12 |
| 17 | トップページのUI実装 | #5 |
| 18 | E2Eテスト・最終動作確認 | #15, #16, #17 |

---

## Issue #4: Docker開発環境のセットアップ

### 概要
Docker ComposeでRails 7.0.8 + PostgreSQLの開発環境を構築する。全開発の基盤となるIssue。

### やること
- [x] `Dockerfile` の作成（Ruby 3.2ベース）
- [x] `docker-compose.yml` の作成（web + db サービス）
- [x] `Gemfile` / `Gemfile.lock` の作成
- [x] `rails new` でRails 7.0.8アプリを生成（`--database=postgresql --css=tailwind --skip-jbuilder`）
- [x] `database.yml` のDocker用設定
- [x] `entrypoint.sh` の作成（server.pidの削除処理）
- [x] `.env` / `.env.example` の作成
- [x] `.dockerignore` の作成
- [x] `docker compose up` でRailsのウェルカムページが表示されることを確認

### 完了条件
- `docker compose build` がエラーなく完了する
- `docker compose up` でRailsサーバーが起動し、`localhost:3000` でウェルカムページが表示される
- `docker compose exec web rails db:create` が成功する

### 依存Issue
- なし

---

## Issue #6: Renderデプロイ設定

### 概要
`rails new`直後の状態で、CSSなどが当たっていない仮のTOPページを作成し、Renderにデプロイする。早期にデプロイ環境を整え、以降の開発で継続的にデプロイ確認できるようにする。

### やること
- [x] 仮のTOPページ用コントローラー（`PagesController`）とアクション（`home`）を作成
- [x] 仮のTOPページ用ビュー（`app/views/pages/home.html.erb`）を作成（シンプルなテキストのみ表示）
- [x] ルーティング設定（`root "pages#home"`）
- [x] ローカル環境で仮のTOPページが表示されることを確認
- [x] `render.yaml`（Blueprint）の作成、またはRenderダッシュボードでの設定
- [x] `bin/render-build.sh` の作成（ビルドスクリプト）
  - `bundle install`
  - `rails assets:precompile`
  - `rails db:migrate`
- [x] 本番環境用の環境変数設定（`RAILS_MASTER_KEY`, `DATABASE_URL` 等）
- [x] `config/environments/production.rb` の確認・調整
- [x] `config/puma.rb` の本番設定確認
- [x] Render PostgreSQLデータベースの作成
- [x] 初回デプロイの実行と動作確認

### 完了条件
- ローカル環境で `localhost:3000` にアクセスすると仮のTOPページ（テキストのみ）が表示される
- Renderへのデプロイが成功する
- 本番環境でも仮のTOPページ（テキストのみ）が表示される

### 依存Issue
- #4 Docker開発環境のセットアップ

---

## Issue #5: Tailwind CSS・Hotwireの導入と基本レイアウト作成

### 概要
Tailwind CSSとHotwire（Turbo/Stimulus）を導入し、アプリケーション共通のレイアウトファイルを整備する。

### やること
- [x] Tailwind CSSの動作確認（`rails new`時に`--css=tailwind`で導入済みの場合は設定確認）
- [x] `turbo-rails`、`stimulus-rails` の動作確認
- [x] `app/views/layouts/application.html.erb` にヘッダー・フッター・メインコンテンツ領域を作成
- [x] レスポンシブ対応の基本スタイル設定
- [x] `app/assets/stylesheets/` にカスタムスタイルの基盤ファイルを作成（必要に応じて）
- [x] トップページ用の静的コントローラー（`PagesController#home`）とビューを作成
- [x] ルーティング設定（`root` を `pages#home` に設定）

### 完了条件
- Tailwind CSSのクラスがビューで適用されている
- Turbo Driveによるページ遷移が動作する
- `localhost:3000` でトップページ（ヘッダー・フッター付き）が表示される
- モバイル・デスクトップの両方でレイアウトが崩れない

### 依存Issue
- #6 Renderデプロイ設定

---

## Issue #7: マスターテーブルのモデル・マイグレーション作成

### 概要
質問フォームの選択肢となるマスターデータ（recipients, occasions, impressions, feelings）のテーブルとモデルを作成する。

### やること
- [x] `recipients` テーブルのマイグレーション作成（name:string, position:integer）
- [x] `occasions` テーブルのマイグレーション作成（name:string, position:integer）
- [x] `impressions` テーブルのマイグレーション作成（name:string, position:integer）
- [x] `feelings` テーブルのマイグレーション作成（name:string, position:integer）
- [x] 各モデルファイルの作成（`Recipient`, `Occasion`, `Impression`, `Feeling`）
- [x] バリデーション追加（name: presence, position: presence + numericality）
- [x] `default_scope { order(position: :asc) }` の設定
- [x] モデルのユニットテスト作成

### 完了条件
- `rails db:migrate` が成功する
- 各モデルのバリデーションが正しく動作する（テストで確認）
- `rails console` でレコードの作成・取得ができる

### 依存Issue
- #4 Docker開発環境のセットアップ

---

## Issue #8: シードデータの投入

### 概要
マスターテーブルにMVPで使用する選択肢データを投入する。

### やること
- [x] `db/seeds.rb` にrecipientsデータを追加（親, パートナー, 友人, 兄弟・姉妹, 祖父母, 職場の人, その他）
- [x] `db/seeds.rb` にoccasionsデータを追加（誕生日・記念日, 日頃の感謝, 最近助けてもらった, しばらく会えていない, 特別な理由はない, その他）
- [x] `db/seeds.rb` にimpressionsデータを追加（いつも支えてくれる, 一緒にいると安心する, 自分を理解してくれる, 困ったときに頼れる, 笑顔にしてくれる, 尊敬している, 刺激をもらえる）
- [x] `db/seeds.rb` にfeelingsデータを追加（ありがとう, これからもよろしく, いつも助かっている, 大切に思っている, ごめんね、そしてありがとう）
- [x] 冪等性を考慮した実装（`find_or_create_by` の使用）
- [x] `rails db:seed` の動作確認

### 完了条件
- `rails db:seed` がエラーなく完了する
- 各テーブルに正しいデータが投入されている
- `rails db:seed` を複数回実行してもデータが重複しない

### 依存Issue
- #7 マスターテーブルのモデル・マイグレーション作成

---

## Issue #9: messagesテーブル・message_impressionsテーブルのモデル作成

### 概要
ユーザーの回答結果と生成メッセージを保存するmessagesテーブル、および多対多の中間テーブル（message_impressions）を作成する。

### やること
- [x] `messages` テーブルのマイグレーション作成
  - user_id: bigint（nullable、外部キー）
  - recipient_id: bigint（外部キー、NOT NULL）
  - occasion_id: bigint（外部キー、NOT NULL）
  - feeling_id: bigint（外部キー、NOT NULL）
  - episode: text
  - additional_message: text（nullable）
  - generated_content: text
  - edited_content: text（nullable）
  - timestamps
- [x] `message_impressions` テーブルのマイグレーション作成（message_id, impression_id）
- [x] `Message` モデルの作成（アソシエーション・バリデーション）
- [x] `MessageImpression` モデルの作成
- [x] `has_many :message_impressions` / `has_many :impressions, through: :message_impressions` の設定
- [x] マスターモデル側に `has_many :messages` を追加
- [x] モデルのユニットテスト作成

### 完了条件
- `rails db:migrate` が成功する
- `Message` に必要なアソシエーションが正しく設定されている
- `message.impressions` で関連するimpressionsを取得できる
- バリデーションテストが通る（recipient_id, occasion_id, feeling_id の必須チェック）

### 依存Issue
- #7 マスターテーブルのモデル・マイグレーション作成

---

## Issue #10: メッセージ生成ロジック（テンプレートエンジン）の実装

### 概要
ユーザーの回答に基づいてメッセージを生成するサービスクラスを実装する。条件分岐によるテンプレートベースの文章生成ロジック。

### やること
- [x] `app/services/message_generator.rb` の作成
- [x] recipient（相手）に応じた呼称・敬称の分岐ロジック
- [x] occasion（きっかけ）に応じた導入文のテンプレート
- [x] impressions（印象・複数）を文章に組み込むロジック
- [x] episode（エピソード）を自然に挿入するロジック
- [x] feeling（気持ち）に応じた締めくくり文のテンプレート
- [x] additional_message（追加メッセージ）がある場合の挿入ロジック
- [x] 各条件分岐の組み合わせテスト
- [x] サービスクラスのユニットテスト作成（主要パターンを網羅）

### 完了条件
- `MessageGenerator.new(message).generate` で文章が生成される
- recipientとoccasionの組み合わせに応じて導入文が変化する
- impressionsが複数選択された場合に自然な文章になる
- episodeが文中に適切に組み込まれる
- feelingに応じた締めくくりが生成される
- additional_messageが任意で文末に追加される
- ユニットテストが全て通る

### 依存Issue
- #8 シードデータの投入
- #9 messagesテーブル・message_impressionsテーブルのモデル作成

---

## Issue #11: ステップフォーム（Step 1〜3）の実装 - 選択式質問

### 概要
メッセージ作成の前半3ステップ（相手選択・きっかけ選択・印象選択）のフォームUIをTurbo Framesを使って実装する。

### やること
- [x] `MessagesController` の作成（`new` / `step1` / `step2` / `step3` アクション）
- [x] ルーティング設定（ステップ遷移用）
- [x] Step 1: 相手を選ぶ画面（ラジオボタン形式）
- [x] Step 2: きっかけを選ぶ画面（ラジオボタン形式）
- [x] Step 3: 印象を選ぶ画面（チェックボックス形式・複数選択）
- [x] Turbo Framesによるステップ遷移の実装
- [x] 進捗バー（プログレスインジケーター）の表示
- [x] セッションまたはhidden fieldsによる回答の一時保持
- [x] 「戻る」ボタンによる前ステップへの遷移
- [x] Tailwind CSSによるスタイリング（カード形式の選択UI）

### 完了条件
- Step 1で相手を選択してStep 2に遷移できる
- Step 2できっかけを選択してStep 3に遷移できる
- Step 3で印象を複数選択できる
- 各ステップで「戻る」操作ができ、以前の選択が保持されている
- プログレスバーが現在のステップを反映している
- レスポンシブ対応されている

### 依存Issue
- #5 Tailwind CSS・Hotwireの導入と基本レイアウト作成
- #8 シードデータの投入

---

## Issue #12: ステップフォーム（Step 4〜6）の実装 - テキスト入力・確認

### 概要
メッセージ作成の後半3ステップ（エピソード入力・気持ち選択・追加メッセージ入力）とメッセージ生成処理を実装する。

### やること
- [x] `MessagesController` に `step4` / `step5` / `step6` / `create` アクションを追加
- [x] Step 4: エピソード入力画面（テキストエリア + ヒント例の表示）
- [x] Step 5: 気持ちを選ぶ画面（ラジオボタン形式）
- [x] Step 6: 追加メッセージ入力画面（テキストエリア + スキップボタン）
- [x] `create` アクションでの `Message` レコード保存処理
- [x] `MessageGenerator` を呼び出し `generated_content` に保存
- [x] 生成完了後の結果画面へのリダイレクト
- [x] Tailwind CSSによるスタイリング

### 完了条件
- Step 4でエピソードを自由記述できる（ヒント例が表示される）
- Step 5で気持ちを選択できる
- Step 6で追加メッセージを入力またはスキップできる
- 全ステップ完了後に `Message` レコードが正しく保存される
- `generated_content` にテンプレートベースで生成されたメッセージが保存される
- 生成完了後に結果画面に遷移する

### 依存Issue
- #10 メッセージ生成ロジック（テンプレートエンジン）の実装
- #11 ステップフォーム（Step 1〜3）の実装

---

## Issue #13: メッセージ表示画面の実装

### 概要
生成されたメッセージを表示する画面を実装する。ここからメッセージの編集やコピーへ遷移できる。

### やること
- [x] `MessagesController#show` アクションの実装
- [x] メッセージ表示ビュー（`app/views/messages/show.html.erb`）の作成
- [x] 生成されたメッセージの表示（`edited_content` があればそちらを優先表示）
- [x] 「編集する」ボタンの配置
- [x] 「コピーする」ボタンの配置
- [x] 「新しいメッセージを作る」リンクの配置
- [x] メッセージの表示フォーマット整備（改行の反映など）
- [x] Tailwind CSSによるスタイリング（手紙風デザイン等）

### 完了条件
- `/messages/:id` でメッセージが正しく表示される
- `edited_content` が存在する場合はそちらが優先表示される
- 「編集する」「コピーする」「新しいメッセージを作る」のボタン/リンクが表示される
- メッセージ内の改行が正しく反映される

### 依存Issue
- #12 ステップフォーム（Step 4〜6）の実装

---

## Issue #14: メッセージ編集機能の実装

### 概要
生成されたメッセージをユーザーが自由に編集できる機能を実装する。編集内容は `edited_content` カラムに保存する。

### やること
- [x] `MessagesController#edit` アクションの実装
- [x] `MessagesController#update` アクションの実装
- [x] 編集フォームビュー（`app/views/messages/edit.html.erb`）の作成
- [x] テキストエリアに現在のメッセージ内容をプリセット（`edited_content || generated_content`）
- [x] 「元に戻す」ボタン（`generated_content` に戻す機能）
- [x] 保存成功時にshow画面へリダイレクト
- [x] Tailwind CSSによるスタイリング

### 完了条件
- 編集画面でメッセージを自由に変更できる
- 保存後に `edited_content` が更新される
- 「元に戻す」で `generated_content` の内容に復元できる
- 保存後にshow画面にリダイレクトされ、更新された内容が表示される

### 依存Issue
- #13 メッセージ表示画面の実装

---

## Issue #15: クリップボードコピー機能の実装

### 概要
メッセージをクリップボードにコピーする機能をStimulus Controllerで実装する。

### やること
- [x] `app/javascript/controllers/clipboard_controller.js` の作成
- [x] Clipboard API（`navigator.clipboard.writeText`）を使用したコピー処理
- [x] コピー成功時のフィードバックUI（トースト通知 or ボタンテキスト変更）
- [x] Clipboard API非対応ブラウザのフォールバック処理（`document.execCommand('copy')`）
- [x] show画面のコピーボタンにStimulus Controllerを接続
- [x] コピー対象テキストの取得ロジック（`edited_content || generated_content`）

### 完了条件
- 「コピーする」ボタンをクリックするとメッセージがクリップボードにコピーされる
- コピー成功時にフィードバック（「コピーしました！」等）が表示される
- フィードバックが一定時間後に元に戻る
- コピー内容がペースト時に正しく反映される

### 依存Issue
- #13 メッセージ表示画面の実装

---

## Issue #16: 入力バリデーションとエラー表示の実装

### 概要
各ステップのフォームにクライアントサイド・サーバーサイド両方のバリデーションを追加し、エラーメッセージをユーザーフレンドリーに表示する。

### やること
- [x] Messageモデルのバリデーション強化（エラーメッセージの日本語化）
- [x] `config/locales/ja.yml` の作成（ActiveRecordエラーメッセージの日本語化）
- [x] `config/application.rb` でデフォルトロケールを `:ja` に設定
- [x] Step 1〜3: 未選択時のエラーメッセージ表示
- [x] Step 3: 最低1つ選択必須のバリデーション
- [x] Step 4: エピソード未入力時のエラーメッセージ表示
- [x] Step 4: エピソードの文字数制限（上限設定）
- [x] Step 6: additional_messageの文字数制限（上限設定、任意入力）
- [x] Stimulus Controllerによるリアルタイムバリデーション（文字数カウンター等）
- [x] エラー表示のスタイリング（赤文字・ボーダー変更等）

### 完了条件
- 必須項目が未入力の場合、次のステップに進めずエラーメッセージが表示される
- エラーメッセージが日本語で表示される
- 文字数カウンターがリアルタイムで更新される
- 文字数超過時に警告が表示される
- サーバーサイドバリデーションもエラー時に適切なメッセージを返す

### 依存Issue
- #12 ステップフォーム（Step 4〜6）の実装

---

## Issue #17: トップページのUI実装

### 概要
サービスの概要とメッセージ作成開始ボタンを配置したトップページを作成する。

### やること
- [x] トップページのヒーローセクション（キャッチコピー + CTA）
- [x] サービス説明セクション（使い方3ステップ等）
- [x] 「メッセージを作る」ボタン（メッセージ作成フォームへのリンク）
- [x] レスポンシブ対応
- [x] Tailwind CSSによるスタイリング

### 完了条件
- トップページにサービスの概要が分かりやすく表示される
- 「メッセージを作る」ボタンからStep 1に遷移できる
- モバイル・デスクトップの両方で見やすいレイアウトになっている

### 依存Issue
- #5 Tailwind CSS・Hotwireの導入と基本レイアウト作成

---

## Issue #18: E2Eテスト・最終動作確認

### 概要
MVP機能全体のシステムテスト（E2E）を作成し、本番環境での最終動作確認を行う。

### やること
- [ ] System Test用のセットアップ（Capybara + Selenium/Cuprite）
- [ ] メッセージ作成フロー全体のE2Eテスト（Step 1〜6 + 生成）
- [ ] メッセージ編集フローのE2Eテスト
- [ ] バリデーションエラー表示のテスト
- [ ] 本番環境での手動動作確認チェックリスト実施
- [ ] パフォーマンス確認（ページ読み込み速度）
- [ ] ブラウザ互換性確認（Chrome, Safari, Firefox）
- [ ] モバイル表示確認

### 完了条件
- 全てのシステムテストがパスする
- 本番環境でメッセージ作成→表示→編集→コピーの一連フローが動作する
- 主要ブラウザで表示崩れがない
- モバイルでの操作に支障がない

### 依存Issue
- #15 クリップボードコピー機能の実装
- #16 入力バリデーションとエラー表示の実装
- #17 トップページのUI実装

---

## MVP後の改善項目

### 現在の問題点：生成メッセージの内容が薄い

現状の `MessageGenerator`（テンプレートエンジン）には以下の問題がある。

#### 問題点

1. **テンプレートが1パターン固定** — 同じ選択をすると毎回まったく同じ文章が生成される
2. **印象の列挙が機械的** — `「〇〇、△△、そして□□。そんな存在です。」` と単語を並べるだけで具体的な描写がない
3. **エピソードが文脈から孤立** — ユーザーが入力したエピソードが前後の文章と繋がりなくそのまま挿入される
4. **文章に具体性がない** — 誰に書いても同じ内容になり、パーソナルな手紙に感じられない
5. **感情の深掘りがない** — 締めの一文が短く、なぜ・どう感謝しているかが伝わらない

#### 改善案（優先度順）

| 優先度 | 施策 | 内容 | 影響範囲 |
|--------|------|------|----------|
| 1 | エピソード接続文の追加 | エピソード前後に導入文・まとめ文を加え、文脈に統合する | `MessageGenerator` のみ |
| 2 | 印象の描写文化 | 印象ごとに1〜2文の描写テンプレートを用意し、単語列挙をやめる | `MessageGenerator` のみ |
| 3 | テンプレート複数パターン化 | 各カテゴリに複数パターンのテンプレートを用意し、バリエーションを出す | `MessageGenerator` のみ |
| 4 | LLM（Claude API）による生成 | ユーザー入力をプロンプトに組み込み、自然な手紙文を生成する | Service層 + API設定 |

### Devise認証機能の導入

#### 概要

Deviseによるユーザー認証を導入し、「初回はログインなしで手紙を作成できるが、2回目以降や保存機能はログイン必須」とする段階的な認証フローを実装する。

#### 現在の状態

- `messages.user_id` はnullableで設計済み（未ログインでの作成に対応可能）
- 現状は認証なしで何度でも作成できる

#### 仕様

- **未ログインユーザー:** 手紙作成1回目は自由。コピーも制限なし。2通目以降の作成・保存・手紙一覧の閲覧にはログインが必要
- **ログイン済みユーザー:** 何通でも作成可能。過去の手紙一覧を閲覧・編集できる

#### やること

- [ ] Devise gemの導入・Userモデルの生成
- [ ] ログイン・会員登録・パスワードリセット画面の作成
- [ ] Devise画面のTailwind CSSスタイリング
- [ ] セッションによる初回作成の管理（`session[:message_created]`）
- [ ] 2回目以降の作成時にログインを促すリダイレクト処理
- [ ] ログイン後に直前の手紙を `user_id` に紐付ける処理
- [ ] マイページ（手紙一覧）の実装
- [ ] テストの作成

---

## 依存関係図

```
#4 Docker環境
├── #6 デプロイ設定（仮TOPページ作成＋デプロイ）
│   └── #5 Tailwind/Hotwire/レイアウト
│       ├── #11 ステップフォーム(1-3)
│       │   └── #12 ステップフォーム(4-6)
│       │       ├── #13 メッセージ表示
│       │       │   ├── #14 メッセージ編集
│       │       │   └── #15 コピー機能
│       │       └── #16 バリデーション
│       └── #17 トップページUI
├── #7 マスターテーブル
│   ├── #8 シードデータ
│   │   ├── #10 メッセージ生成ロジック
│   │   └── #11 ステップフォーム(1-3)
│   └── #9 messages/message_impressions
│       └── #10 メッセージ生成ロジック
#18 E2Eテスト ← #15, #16, #17
```

## 並行作業可能な組み合わせ
- #6 と #7（#4完了後）
- #5 と #8（#6と#7が完了後）
- #14 と #15（#13完了後）
- #16 と #17（それぞれの依存元完了後）
