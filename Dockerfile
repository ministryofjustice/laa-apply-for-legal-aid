# Stage 1: Base image with build dependencies
FROM ruby:3.3.6-alpine3.21 AS base

LABEL org.opencontainers.image.authors="apply for legal aid team"

# fail early and print all commands
RUN set -ex

# Install build dependencies
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    libxml2-dev \
                    libxslt-dev \
                    postgresql-dev \
                    git \
                    curl \
                    yaml-dev

# Install runtime dependencies
RUN apk --no-cache add \
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

# Clean up build dependencies
RUN apk del build-dependencies

# Stage 2: Build application dependencies
FROM base AS builder

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# Install Git in the builder stage
RUN apk add --no-cache git

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

# Env vars needed for dependency install and asset precompilation
COPY .ruby-version Gemfile Gemfile.lock ./

# Update RubyGems system software
RUN gem update --system

# Configure bundler to exclude test and development groups
RUN bundle config --local without 'test development'

# Build nokogiri using system libraries
RUN bundle config build.nokogiri --use-system-libraries

# Ensure Git is available for Bundler
RUN git --version

# Install gems with verbose output
RUN bundle install --verbose

COPY package.json yarn.lock ./
RUN yarn --prod

# Copy application code
COPY . .

# Precompile assets
RUN NODE_OPTIONS=--openssl-legacy-provider bundle exec rake assets:precompile SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

# Stage 3: Final runtime image
FROM base

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

# Copy runtime dependencies and application code from builder stage
COPY --from=builder /usr/src/app /usr/src/app

# Set environment variables
ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true

# Expose port
EXPOSE 3002

# Set ownership for non-root user
RUN chown -R appuser:appgroup log tmp db

# expect ping environment variables
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH

# set ping environment variables
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}

USER 1000
CMD ["./docker/run"]
