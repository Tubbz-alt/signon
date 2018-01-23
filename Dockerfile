FROM ruby:2.4.2

RUN apt-get update -qq && apt-get upgrade -y
RUN apt-get install -y build-essential nodejs && apt-get clean

ENV APP_HOME /app
ENV DATABASE_URL mysql2://root:root@mysql/signon
ENV GOVUK_APP_NAME signon
ENV PORT 3016
ENV RAILS_ENV development
ENV TEST_DATABASE_URL mysql2://root:root@mysql/signon_test

RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* .ruby-version $APP_HOME/
RUN bundle install

ADD . $APP_HOME

RUN GOVUK_APP_DOMAIN=www.gov.uk RAILS_ENV=production \
  DEVISE_PEPPER=`openssl rand -base64 40` \
  DEVISE_SECRET_KEY=`openssl rand -base64 40` \
  bundle exec rails assets:clean assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD bundle exec unicorn -p $PORT
