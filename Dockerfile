FROM ruby:2.6.3-slim
LABEL George Asfour <archmage09@gmail.com>

# Timezones fix
RUN rm -f /etc/localtime
RUN ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Install system deps
RUN apt-get -y update && apt-get -y install curl bash build-essential
RUN apt-get -y update && apt-get -y install patch ruby-dev libpq-dev

WORKDIR /app

RUN gem install bundler -v '1.17.3'

# Install app deps
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY ./ .

CMD rake db:migrate && rackup