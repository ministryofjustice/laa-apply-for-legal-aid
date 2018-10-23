FROM ministryofjustice/ruby:2.5.1-webapp-onbuild
MAINTAINER apply for legal aid team

ENV RAILS_ENV production

#RUN apk --update add --virtual build-dependencies \
#                               build-base \
#                               libxml2-dev \
#                               libxslt-dev \
#                               postgresql-dev \
#                               postgresql-client \
#                               tzdata \
#                               && rm -rf /var/cache/apk/*
#
#RUN bundle config build.nokogiri --use-system-libraries
#
#RUN mkdir /usr/src/app
#
#WORKDIR /usr/src/app
#
## Copy Gemfile & Gemfile.lock separately,
## so that Docker will cache the 'bundle install'
#COPY Gemfile Gemfile.lock ./
#RUN bundle install
#
#COPY . /usr/src/app
#
## Copy helper scripts
#COPY ./docker/* /usr/src/app/bin/


ENV PORT 3002

RUN touch /etc/inittab

RUN apt-get update && apt-get install -y
RUN apt-get install postgresql postgresql-contrib -y

EXPOSE $PORT

RUN bundle exec rake assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# Copy helper scripts
COPY ./docker/* /usr/src/app/bin/

CMD ["bin/run"]
