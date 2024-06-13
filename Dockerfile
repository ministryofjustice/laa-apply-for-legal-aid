FROM ministryofjustice/apply-base:latest-3.3.3
MAINTAINER apply for legal aid team

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

COPY .ruby-version Gemfile Gemfile.lock ./

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
RUN gem update --system \
&& bundle config --local without 'test development' \
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
