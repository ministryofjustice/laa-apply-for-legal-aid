FROM ruby:2.5.1-alpine
MAINTAINER apply for legal aid team

RUN apk --update add --virtual build-dependencies \
                                    build-base \
                                    libxml2-dev \
                                    libxslt-dev \
#                                    postgresql-dev \
                                    sqlite-dev \
                                    tzdata \
                                    && rm -rf /var/cache/apk/*

RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /usr/src/app

WORKDIR /usr/src/app

COPY . /usr/src/app

RUN gem update bundler

RUN  bundle install

ENTRYPOINT ["bundle", "exec"]

CMD ["rails", "server", "-b", "0.0.0.0"]
