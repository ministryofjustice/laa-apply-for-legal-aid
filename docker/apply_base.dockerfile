FROM ruby:3.1.3-alpine3.17
MAINTAINER apply for legal aid team

ENV KUBECTL_VERSION=1.22.3

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
                  bash \
                  py3-pip
RUN pip3 install awscli

# Install kubectl
RUN curl -Lo /usr/local/bin/kubectl \
        --retry 3 \
        --retry-delay 3 \
        --retry-connrefused \
        https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

# Ensure everything is executable
RUN chmod +x /usr/local/bin/*
