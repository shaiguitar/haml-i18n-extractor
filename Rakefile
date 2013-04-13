#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

def with_each_gemfile
  old_env = ENV['BUNDLE_GEMFILE']
  gemfiles.each do |gemfile|
    puts "Using gemfile: #{gemfile}"
    ENV['BUNDLE_GEMFILE'] = gemfile
    yield
  end
ensure
  ENV['BUNDLE_GEMFILE'] = old_env
end

def silence_warnings
  the_real_stderr, $stderr = $stderr, StringIO.new
  yield
ensure
  $stderr = the_real_stderr
end

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.test_files = Dir["test/**/*_test.rb"]
end

task :default => :test
namespace :test do
  namespace :bundles do
    desc "Install all dependencies necessary to test."
    task :install do
      with_each_gemfile {sh "bundle"}
    end

    desc "Update all dependencies for testing."
    task :update do
      with_each_gemfile {sh "bundle update"}
    end
  end

  desc "Test all supported versions of rails. This takes a while."
  task :rails_compatibility => 'test:bundles:install' do
    with_each_gemfile {sh "bundle exec rake test"}
  end
  task :rc => :rails_compatibility
end

# FIXME, jsut run this
task :force_build_and_install do
  %{ gem uninstall -x haml-i18n-extractor; rm *gem; gem build *gemspec; gem install --local *gem }
end
