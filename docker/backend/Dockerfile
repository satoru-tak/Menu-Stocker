# Backend (Rails) Dockerfile

ARG RUBY_VERSION=3.3.0
FROM ruby:${RUBY_VERSION}-alpine AS base

# 環境変数の設定
ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT='' \
    LANG=C.UTF-8

# 作業ディレクトリの設定
WORKDIR /app

# 開発ステージ
FROM base AS development

# 必要なパッケージのインストール
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    git \
    tzdata \
    imagemagick \
    vips \
    vips-dev \
    bash \
    curl

# Bundlerのインストール
RUN gem install bundler

# Gemfileをコピーして依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーションのコピー
COPY . .

# ポートの公開
EXPOSE 3000

# 起動コマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# 本番ステージ
FROM base AS production

# 本番環境用のパッケージのインストール
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    imagemagick \
    vips

# Gemfileをコピーして本番用の依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# アプリケーションのコピー
COPY . .

# アセットのプリコンパイル（必要に応じて）
# RUN bundle exec rails assets:precompile

# 非rootユーザーの作成
RUN addgroup -g 1000 rails && \
    adduser -D -u 1000 -G rails rails && \
    chown -R rails:rails /app

USER rails

# ポートの公開
EXPOSE 3000

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# 起動コマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
