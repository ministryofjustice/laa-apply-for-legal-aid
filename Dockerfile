FROM ministryofjustice/apply-base:test-yarn-bump-1.0

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@justice.gov.uk)" \
      org.opencontainers.image.title="Apply for civil legal aid" \
      org.opencontainers.image.description="Web service to apply for legal aid in civil matters" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-apply-for-legal-aid"

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
# Copy local gem
COPY gems/moj-components ./gems/moj-components

# only install production dependencies,
# build nokogiri using libxml2-dev, libxslt-dev
RUN gem update --system \
&& bundle config --local without 'test development' \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle install

ENV NODE_ENV=production
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

# Tell puppeteer where to find the Chromium executable and not to attempt to download it during installation
# because we insstalled it in the base image.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN yarn install --immutable

####################
# DEPENDENCIES END #
####################

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
EXPOSE 3002

COPY . .

RUN bundle exec rake assets:precompile SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here

# tidy up installation - these are installed in the apply-base image
RUN apk del build-dependencies

# Cleanup to save space in the production image
RUN rm -rf log/* tmp/* && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete

RUN yarn cache clean

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

# Set timezone
ENV TZ=Europe/London
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone

USER 1000
CMD ["./docker/run"]
