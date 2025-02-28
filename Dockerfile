ARG RUBY_VERSION=3.1.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Set working directory inside the container
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential curl libjemalloc2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock to leverage Docker caching
COPY Gemfile Gemfile.lock ./

# Install gems (excluding production group)
RUN bundle install --without production

# Copy the application source code (use volume in development)
COPY . .

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails .
USER 1000:1000

# Expose port 3000 for Rails server
EXPOSE 3000

# Command to start the Rails server in development mode
CMD ["rails", "server", "-b", "0.0.0.0"]