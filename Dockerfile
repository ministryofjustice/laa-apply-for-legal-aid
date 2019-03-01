FROM ministryofjustice/ruby:2.5.3-webapp-onbuild
MAINTAINER apply for legal aid team

ENV RAILS_ENV production

ENV PORT 3002

RUN touch /etc/inittab

RUN apt-get update && apt-get install -y
RUN apt-get install postgresql postgresql-contrib -y
RUN apt-get install clamav-daemon -y
RUN apt-get install libreoffice -y
RUN gem install foreman

EXPOSE $PORT

RUN bundle exec rake assets:precompile SECRET_KEY_BASE=required_but_does_not_matter_for_assets

# Copy helper scripts
COPY ./docker/* /usr/src/app/bin/

CMD ["bin/run"]
