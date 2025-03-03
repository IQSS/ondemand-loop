ARG RUBY_VERSION=3.1.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# Set working directory inside the container
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install --no-install-recommends -y build-essential curl libjemalloc2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Expose port 3000 for Rails server
EXPOSE 3000

# Command to start the container for developers
CMD ["bash"]