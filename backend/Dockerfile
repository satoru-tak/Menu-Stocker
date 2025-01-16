FROM ruby:3.4.1

ENV LANG=C.UTF-8 \
  TZ=Asia/Tokyo

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y postgresql-client \
  curl apt-transport-https wget nodejs

WORKDIR /api

COPY Gemfile /api/Gemfile
COPY Gemfile.lock /api/Gemfile.lock

RUN gem install solargraph
RUN gem update --system && gem install bundler
RUN bundle install

COPY . /api

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]