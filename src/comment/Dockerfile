FROM alpine:latest
RUN apk update && apk add ruby-full ruby-dev build-base ruby-bundler && \
    gem install bundler --no-ri --no-rdoc

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
COPY . $APP_HOME

RUN rm -rf /var/cache/apk/*

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]


