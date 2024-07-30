FROM ruby:3.3.4-alpine3.20
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
                    curl \
&& apk --no-cache add \
                  postgresql-client \
                  nodejs \
                  yarn \
                  jq \
                  linux-headers \
                  clamav-daemon \
                  libreoffice \
                  ttf-dejavu \
                  ttf-droid \
                  ttf-freefont \
                  ttf-liberation \
                  bash

# Install Chromium and Puppeteer for PDF generation
# Installs latest Chromium package available on Alpine (Chromium 108)
RUN apk update
RUN apk add --no-cache \
        nss \
        freetype \
        harfbuzz \
        ca-certificates

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
#
## Install latest version of Puppeteer
#RUN yarn add puppeteer

# Ensure everything is executable
RUN chmod +x /usr/local/bin/*

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp && mkdir -p /usr/src/app/.cache/puppeteer/chrome
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################
# Env vars needed for dependency install and asset precompilation

COPY .ruby-version Gemfile Gemfile.lock ./

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
RUN gem update --system \
&& bundle config --local without 'test development' \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

COPY package.json yarn.lock ./
RUN yarn --prod
RUN yarn puppeteer browsers install chrome@126
RUN mv /root/.cache/puppeteer .cache/
RUN chown -R appuser:appgroup .cache
RUN chmod 777 .cache

####################
# DEPENDENCIES END #
####################

ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true
EXPOSE 3002

COPY . .

RUN NODE_OPTIONS=--openssl-legacy-provider bundle exec rake assets:precompile SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

# tidy up installation - these are installed in the apply-base image
RUN apk del build-dependencies

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

# expect ping environment variablesARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH
# set ping environment variables
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}

USER 1000
CMD "./docker/run"
