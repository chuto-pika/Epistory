#!/usr/bin/env bash
# Render.comのビルド時に実行されるスクリプト
# bundle install → アセットコンパイル → DBマイグレーションを順に実行する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
