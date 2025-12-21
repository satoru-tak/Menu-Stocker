# Backend (Rails) Dockerfile

ARG RUBY_VERSION=3.4.8
FROM ruby:${RUBY_VERSION}-alpine AS base

ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    LANG=C.UTF-8

WORKDIR /app

# =========================
# Development stage
# =========================
FROM base AS development

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    git \
    tzdata \
    imagemagick \
    vips \
    vips-dev \
    yaml-dev \
    pkgconf \
    bash \
    curl

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# =========================
# Production stage
# =========================
FROM base AS production

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test"

# 実行時に必要なパッケージ
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    imagemagick \
    vips \
    yaml \
    curl

COPY Gemfile Gemfile.lock ./

# ビルド専用依存
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    postgresql-dev \
    vips-dev \
    yaml-dev \
    pkgconf && \
    bundle install --jobs 4 --retry 3 && \
    apk del .build-deps

COPY . .

# RUN bundle exec rails assets:precompile

RUN addgroup -g 1000 rails && \
    adduser -D -u 1000 -G rails rails && \
    chown -R rails:rails /app

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
