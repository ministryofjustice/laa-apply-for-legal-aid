
##############################################################################
# STAGE 1 — BUILD (full dependencies)
##############################################################################
FROM ministryofjustice/apply-base:chromium-v1.0 AS dependencies

WORKDIR /usr/src/app

# --- Environment ---
# Tell puppeteer where to find the Chromium executable and not to attempt to download it during installation
# because we installed it in the base image.
#
ENV RAILS_ENV=production \
    NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# --- Ruby dependencies ---
COPY .ruby-version Gemfile Gemfile.lock ./
COPY gems/moj-components ./gems/moj-components

RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") && \
    bundler -v && \
    bundle config set frozen 'true' && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle config set without test:development && \
    bundle install --jobs 5 --retry 5 && \
    rm -rf /usr/local/bundle/cache

# --- Node dependencies (FULL graph, includes devDependencies) ---
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

# --- Cleanup to save space in the image ---
RUN rm -rf log/* tmp/* /tmp && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf .env && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    find /usr/local/bundle/gems -name "*.html" -delete && \
    yarn cache clean

##############################################################################
# STAGE 2 — BUILD (production only dependencies)
##############################################################################
FROM dependencies AS builder

WORKDIR /usr/src/app

# --- App source ---
COPY . .

# --- Precompile assets (requires dev dependencies like sass/esbuild) ---
RUN SECRET_KEY_BASE=dummy \
    bundle exec rails assets:precompile

# --- Prune dev dependencies ---
RUN yarn workspaces focus --all --production

#######################################
# STAGE 3 — PRODUCTION RUNTIME
#######################################
FROM ministryofjustice/apply-base:chromium-v1.0 AS production

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@justice.gov.uk)" \
      org.opencontainers.image.title="Apply for civil legal aid" \
      org.opencontainers.image.description="Web service to apply for legal aid in civil matters" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-apply-for-legal-aid"

# --- Directories ---
# create some required directories in conventional alpine location
RUN mkdir -p /usr/src/app && \
    mkdir -p /usr/src/app/log && \
    mkdir -p /usr/src/app/tmp && \
    mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

# --- Environment ---
# Tell puppeteer-core where to find the Chromium executable
ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    TZ=Europe/London

# --- Create non-root user ---
# add non-root user and group with alpine first available uid, 1000
ENV APPUID=1000
RUN addgroup -g $APPUID -S appgroup && \
    adduser -u $APPUID -S appuser -G appgroup

# --- Copy app + compiled assets from dependencies stage ---
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY --from=builder /usr/src/app/public /usr/src/app/public
COPY --from=builder /usr/src/app/app/assets/builds /usr/src/app/app/assets/builds
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
