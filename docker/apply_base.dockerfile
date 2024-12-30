FROM ruby:3.4.1-alpine3.21
LABEL org.opencontainers.image.authors="apply for legal aid team"

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
RUN apk add --no-cache \
        chromium \
        nss \
        freetype \
        harfbuzz \
        ca-certificates

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install latest version of Puppeteer
RUN yarn add puppeteer

# Ensure everything is executable
RUN chmod +x /usr/local/bin/*
