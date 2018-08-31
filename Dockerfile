FROM ruby:2.5.1-alpine
MAINTAINER apply for legal aid team

RUN apk --update add --virtual build-dependencies \
                               build-base \
                               libxml2-dev \
                               libxslt-dev \
                               postgresql-dev \
                               postgresql-client \
                               tzdata \
                               && rm -rf /var/cache/apk/*

RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /usr/src/app

WORKDIR /usr/src/app

# Copy Gemfile & Gemfile.lock separately,
# so that Docker will cache the 'bundle install'
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /usr/src/app

# Copy helper scripts
COPY ./docker/* /usr/src/app/bin/

ENV PORT 3002

EXPOSE $PORT

CMD ["bin/run"]
