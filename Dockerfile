
#######################################
# STAGE 1 — BUILD (full dependencies)
#######################################
FROM ministryofjustice/apply-base:test-yarn-bump-1.0 AS dependencies

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@justice.gov.uk)" \
      org.opencontainers.image.title="Apply for civil legal aid" \
      org.opencontainers.image.description="Web service to apply for legal aid in civil matters" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-apply-for-legal-aid"

WORKDIR /usr/src/app

# --- Environment ---
ENV RAILS_ENV=production \
    NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# --- Ruby dependencies ---
COPY .ruby-version Gemfile Gemfile.lock ./
COPY gems/moj-components ./gems/moj-components

# RUN gem update --system && \
#     bundle config set --local without 'development test' && \
#     bundle config build.nokogiri --use-system-libraries && \
#     bundle install

RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") && \
    bundler -v && \
    bundle config set frozen 'true' && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set without test:development && \
    bundle install --jobs 5 --retry 5 && \
    rm -rf /usr/local/bundle/cache

# --- Node dependencies (FULL graph, includes dev) ---
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

RUN yarn install --immutable

# cleanup to save space in the image
RUN rm -rf log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    yarn cache clean

# --- App source ---
COPY . .

# --- Precompile assets (requires dev deps like sass/esbuild) ---
RUN SECRET_KEY_BASE=dummy \
    bundle exec rails assets:precompile

# Remove node_modules to avoid copying dev deps to runtime stage
RUN rm -rf node_modules


#######################################
# STAGE 2 — PRODUCTION RUNTIME
#######################################
FROM ministryofjustice/apply-base:test-yarn-bump-1.0 AS production

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@justice.gov.uk)" \
      org.opencontainers.image.title="Apply for civil legal aid" \
      org.opencontainers.image.description="Web service to apply for legal aid in civil matters" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-apply-for-legal-aid"

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp
WORKDIR /usr/src/app

# --- Environment ---
# Tell puppeteer where to find the Chromium executable and not to attempt to download it during installation
# because we installed it in the base image.
#
ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    TZ=Europe/London

# --- Create non-root user ---
# add non-root user and group with alpine first available uid, 1000
ENV APPUID=1000
RUN addgroup -g $APPUID -S appgroup && \
    adduser -u $APPUID -S appuser -G appgroup

# # --- Ruby production gems only ---
# COPY .ruby-version Gemfile Gemfile.lock ./
# COPY gems/moj-components ./gems/moj-components

# # only install production dependencies,
# # build nokogiri using libxml2-dev, libxslt-dev
# RUN gem update --system && \
#     bundle config set --local without 'development test' && \
#     bundle config build.nokogiri --use-system-libraries && \
#     bundle install

# --- Yarn production-only install ---
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn

RUN yarn workspaces focus --all --production

# --- Copy app + compiled assets from dependencies stage ---
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --from=dependencies /usr/src/app/public /usr/src/app/public
COPY --from=dependencies /usr/src/app/app/assets/builds /usr/src/app/app/assets/builds
COPY . .

# tidy up installation - these are installed in the apply-base image
RUN apk del build-dependencies

# Cleanup to save space in the production image
RUN rm -rf log/* tmp/* && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    yarn cache clean

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

# --- Build metadata ---
# expect ping environment variables
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH

# set ping environment variables
ENV BUILD_DATE=${BUILD_DATE} \
    BUILD_TAG=${BUILD_TAG} \
    APP_BRANCH=${APP_BRANCH}

# Set timezone
RUN ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone

USER $APPUID
EXPOSE 3002

CMD ["./docker/run"]
