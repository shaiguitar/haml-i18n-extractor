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

def without_rails_mode
  Object.send(:remove_const, :Rails) if defined?(Rails)
  yield
end

def with_rails_mode
  create_klass=<<EOR
  module Rails
    def self.root
      "/data/current/name"
    end
  end
EOR
  eval create_klass
  yield
end

