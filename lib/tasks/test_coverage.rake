namespace :test do
  desc 'Run test suite with SimpleCov coverage'
  task :coverage do
    ENV['COVERAGE'] = '1'
    ENV['RAILS_ENV'] ||= 'test'
    Rake::Task['test'].invoke
  end
end
