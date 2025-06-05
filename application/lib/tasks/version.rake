# frozen_string_literal: true

namespace :version do
  VERSION_FILE = Rails.root.join('VERSION')

  def current_version
    File.read(VERSION_FILE).strip
  end

  def base_version(version)
    version.split('+').first
  end

  def write_version(base)
    build = Time.now.strftime('%Y-%m-%d')
    full_version = "#{base}+#{build}"
    File.write(VERSION_FILE, "#{full_version}\n")
    puts "New version: #{full_version}"
  end

  def bump(type)
    major, minor, patch = base_version(current_version).split('.').map(&:to_i)

    case type
    when 'major'
      major += 1
      minor = 0
      patch = 0
    when 'minor'
      minor += 1
      patch = 0
    when 'patch'
      patch += 1
    else
      raise ArgumentError, "Unknown bump type: #{type}"
    end

    "#{major}.#{minor}.#{patch}"
  end

  desc 'Show current app version'
  task :show do
    puts "Current version: #{current_version}"
  end

  desc 'Bump patch version and add current date as build metadata'
  task :patch do
    write_version(bump('patch'))
  end

  desc 'Bump minor version and add current date as build metadata'
  task :minor do
    write_version(bump('minor'))
  end

  desc 'Bump major version and add current date as build metadata'
  task :major do
    write_version(bump('major'))
  end
end
