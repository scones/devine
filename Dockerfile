ARG RUBY_VERSION=3.0.1
ARG GEM_RUBY_VERSION=3.0.0


###############################
### fetch all needed gems
###############################
FROM ruby:${RUBY_VERSION}-slim AS bundler
ARG GEM_RUBY_VERSION

RUN apt-get update -y \
  && apt-get install -y \
  build-essential \
  libxml2-dev \
  libxslt-dev \
  libmariadbclient-dev \
  && apt-get clean -y \
  && mkdir -p /bundler \
  && bundle config --global frozen 1

WORKDIR /bundler

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

ENV GEM_HOME="/bundler/vendor/bundle"

RUN apt-get install -y libsqlite3-dev
RUN GEM_HOME="/bundler/vendor/bundle" bundle install --without development test -j4 --retry 3 --path ./vendor/bundle
RUN rm -rf ./vendor/bundle/cache/*.gem
RUN ls -l /bundler/vendor/bundle/ruby/
RUN echo "${GEM_FOLDER_VERSION}"
RUN ls -l "/bundler/vendor/bundle/ruby/${GEM_RUBY_VERSION}/gems"
RUN find ./vendor/bundle/ -type f  \( \
      -name "*.c" \
      -name "*.o" \
      -name "*.h" \
    \) -exec rm {} \;





###############################
### run gulp for production
###############################
# FROM node:12-alpine AS gulper
#
# WORKDIR /build
# COPY gulpfile.js gulpfile.js
# COPY package.json package.json
# COPY yarn.lock yarn.lock
# COPY app/molecules app/molecules
# RUN yarn
# RUN ./node_modules/.bin/gulp build
# RUN rm -rf node_modules tmp/cache app/assets vendor/assets lib/assets spec Gulpfile yarn.lock





###############################
### run the app
###############################
FROM ruby:${RUBY_VERSION}-slim AS runner
ARG GEM_RUBY_VERSION

RUN mkdir -p /application/log && mkdir -p /application/storage
WORKDIR /application

COPY /config.ru /Rakefile /application/
COPY /bin /application/bin
COPY /public /application/public
COPY /config /application/config
COPY Gemfile Gemfile.lock /application/
COPY /db /application/db
COPY /lib /application/lib
COPY /app /application/app

COPY --from=bundler /bundler/vendor/bundle /application/vendor/bundle

RUN apt-get update
RUN apt-get install -y libsqlite3-dev
RUN bundle install --without development test -j4 --retry 3 --path /application/vendor/bundle
RUN ls -l /application/vendor/bundle/ruby/${GEM_RUBY_VERSION}
RUN rm -rf /application/vendor/bundle/ruby/${GEM_RUBY_VERSION}/cache/*.gem
RUN find /application/vendor/bundle/ruby/${GEM_RUBY_VERSION}/gems/ -type f  \( \
      -name "*.c" \
      -name "*.o" \
      -name "*.h" \
    \) -exec rm {} \;

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=1
ENV PATH="/application/bin:$PATH"

# COPY --from=gulper /build/public/assets public/assets
# COPY --from=gulper /build/public/manifests public/manifests
# COPY --from=gulper /build/config/locales/de.yml config/locales/de.yml

CMD ["rails", "s", "--early-hints"]
