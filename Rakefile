$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "bundler/setup"
load "tasks/otr-activerecord.rake"

namespace :db do
  # Some db tasks require your app code to be loaded; they'll expect to find it here
  task :environment do
    require 'active_record'

    Bundler.require :default
    require 'aloha/db'
  end
end

require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList['tests/**/*_test.rb']
  t.warning = false
end
desc "Run tests"
