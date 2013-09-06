#######################################################################
##    copied over from haml for this to just work. TODO Cleanup.     ##
##                      mini  test stuff                             ##
#######################################################################

require 'rubygems'
gem "minitest"
require 'bundler/setup'
require 'minitest/autorun'
require 'action_pack'
require 'action_controller'
require 'action_view'
require 'nokogiri'
require 'rails'
require 'fileutils'
require 'pry'

module Declarative
  def test(name, &block)
    define_method("test #{name}", &block)
  end
end

class MiniTest::Unit::TestCase

  extend Declarative

  def render(text, options = {}, base = nil, &block)
    scope  = options.delete(:scope)  || Object.new
    locals = options.delete(:locals) || {}
    engine = Haml::Engine.new(text, options)
    return engine.to_html(base) if base
    engine.to_html(scope, locals, &block)
  end
  
  def assert_warning(message)
    the_real_stderr, $stderr = $stderr, StringIO.new
    yield
  
    if message.is_a?(Regexp)
      assert_match message, $stderr.string.strip
    else
      assert_equal message.strip, $stderr.string.strip
    end
  ensure
    $stderr = the_real_stderr
  end
  
  def silence_warnings(&block)
    Haml::Util.silence_warnings(&block)
  end
  
  def rails_form_opener
    '<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>'
  end
  
  def assert_raises_message(klass, message)
    yield
  rescue Exception => e
    assert_instance_of(klass, e)
    assert_equal(message, e.message)
  else
    flunk "Expected exception #{klass}, none raised"
  end
  
  def self.error(*args)
    Haml::Error.message(*args)
  end

end

##############################
## project specific helpers ##
##############################

require File.dirname(__FILE__) + "/../lib/" + 'haml-i18n-extractor'

def file_path(name)
  File.dirname(__FILE__) + "/support/#{name}"
end

def with_highline(input = nil, &blk)
  old_terminal = $terminal
  @input     = input ? StringIO.new(input) : StringIO.new
  @output    = StringIO.new
  $terminal = HighLine.new(@input, @output)
  yield
ensure
  $terminal = old_terminal
end

module TestHelper

  TMPDIR = File.join(File.dirname(__FILE__) +  "/tmp/")
  PROJECT_DIR = File.join(TMPDIR, "workflow/")

  def self.mock_full_project_user_interaction!
    automate_user_interaction = ""
    6.times do                            # should be number of files we're testing on
      automate_user_interaction << "O"    # overwrite file
      50.times do                         # should be number of lines in file,
        # this should do right now.
        automate_user_interaction << "y"  # replace line
      end
    end
    @workflow = Haml::I18n::Extractor::Workflow.new(TestHelper::PROJECT_DIR)
    with_highline(automate_user_interaction) do
      @workflow.run
    end
    @workflow
  end


  def self.hax_shit
    Dir.glob("*yml").map {|p| FileUtils.rm(p) } # HAX, TODO: handle with yaml files correctly (config/en.yml)
    Dir.glob("config/locales/*yml").map {|p| FileUtils.rm(p) } # HAX, TODO: handle with yaml files correctly (config/en.yml)
    if File.exists?(Haml::I18n::Extractor::TaggingWriter::DB)
      FileUtils.rm_rf(Haml::I18n::Extractor::TaggingWriter::DB) # HAX, TODO: setup/teardown
    end
  end

  def self.setup_project_directory!
    # mimic a rails app.
    view1 = File.join(PROJECT_DIR, "app", "views", "view1")
    view2 = File.join(PROJECT_DIR, "app", "views", "view2")
    view3 = File.join(PROJECT_DIR, "app", "views", "namespace", "view3")
    [ view1, view2, view3 ].map do |dir|
      FileUtils.mkdir_p(dir)
      ["thing.haml", "thang.haml", "_partial.html.haml"].map do |fn|
        haml_text=<<EOH
%h1 Notifications

.nav= will_paginate(@consumer_notifications)
%table.themed{cellspacing: 0}
  %thead
    %tr
      %th.first Type #{fn}_#{dir}
      %th Identifier #{fn}_#{dir}
      %th Data #{fn}_#{dir}
      %th Success #{fn}_#{dir}
      %th Reported To #{fn}_#{dir}
      %th.last &nbsp; #{fn}_#{dir}
  - @consumer_notifications.each do |cn|
    %tr
      %td.type= cn.notification.type
      %td.identifier= cn.notification.identifier
      %td.data= cn.notification.data
      %td.success= cn.success
      %td.reported_to= cn.reported_to
.nav= will_paginate(@consumer_notifications)
EOH
      File.open(File.join(dir, fn), "w") do |f|
        f.write haml_text
      end
      end
    end
    # config dir
    FileUtils.mkdir_p(File.join(PROJECT_DIR, "config/locales"))
    # for testing we're only working on .haml files.
    File.open(File.join(view1, "not_haml.rb"), "w") do |f|
      f.write "puts :not_haml"
    end
  end

  def self.teardown_project_directory!
    FileUtils.rm_rf(PROJECT_DIR)
  end
  
end
