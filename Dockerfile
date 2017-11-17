FROM ruby:2.4.2-alpine3.6

ENV APP_HOME /app
ENV PATH $APP_HOME/bin:$PATH

# Configure main application and working directory
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Copy Gemfile and lock separately to cache dependencies unless they change
COPY Gemfile Gemfile.lock ./

# Install Yarn
ENV PATH /root/.yarn/bin:$PATH
RUN apk add --no-cache --virtual .yarn-deps curl gnupg && \
  curl -o- -L https://yarnpkg.com/install.sh | sh && \
  apk del .yarn-deps

# Install dependencies
RUN apk --update add --virtual build-dependencies build-base ruby-dev \
      libressl libxml2-dev libxslt-dev postgresql-dev libc-dev \
      linux-headers nodejs tzdata && \
      gem install bundler && \
      gem update --system && \
      bundle config build.nokogiri --use-system-libraries && \
      bundle install --jobs 10 --without development test && \
      yarn install

# Set Rails to production mode
ENV RAILS_ENV production
ENV NODE_ENV production

# Copy the rest of the application
COPY . ./

# Precompile assets and expose server port
RUN bundle exec rake assets:precompile
EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "s"]
