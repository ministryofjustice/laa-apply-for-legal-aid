FROM ruby:2.6.3-alpine3.10
MAINTAINER apply for legal aid team

# fail early and print all commands
RUN set -ex

# build dependencies:
# - virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - postgresql-dev for pg/activerecord gems
# - git for installing gems referred to use a git:// uri
#
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    libxml2-dev \
                    libxslt-dev \
                    postgresql-dev \
                    git \
&& apk --no-cache add \
                  postgresql-client \
                  nodejs \
                  yarn \
                  linux-headers \
                  clamav-daemon \
                  libreoffice \
                  ttf-ubuntu-font-family \
                  wkhtmltopdf

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################
# Env vars needed for dependency install and asset precompilation

COPY Gemfile* ./

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
RUN gem install bundler -v 2.0.2 \
&& bundle config --global without test:development \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

COPY package.json yarn.lock ./
RUN yarn --prod

####################
# DEPENDENCIES END #
####################

ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true
EXPOSE 3002

COPY . .

RUN bundle exec rake assets:precompile SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

# tidy up installation
RUN apk del build-dependencies

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

USER 1000
CMD "./docker/run"
