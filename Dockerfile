# Use an official Ruby image as a base
FROM ruby:3.1

# Set working directory inside the container
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn

# Install Bundler
RUN gem install bundler

# Copy Gemfile and Gemfile.lock to leverage Docker caching
COPY Gemfile Gemfile.lock ./

# Install gems (excluding production group)
RUN bundle install --without production

# Copy the application source code (use volume in development)
COPY . .

# Expose port 3000 for Rails server
EXPOSE 3000

# Command to start the Rails server in development mode
CMD ["rails", "server", "-b", "0.0.0.0"]