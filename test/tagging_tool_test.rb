require 'test_helper'
require 'fileutils'

module Haml
  class TaggingToolTest < MiniTest::Unit::TestCase

    FILE = Haml::I18n::Extractor::TaggingTool::DB

    def teardown
      FileUtils.rm_rf(FILE)
    end

    test "It uses a file which it uses to keep track of user tagged lines" do
      assert ! File.exists?(FILE), "no tagging file should exist"
      Haml::I18n::Extractor::TaggingTool.new
      assert File.exists?(FILE), "tagging file should be created on init"
    end

    test "It can write in a format" do
      tag_tool = Haml::I18n::Extractor::TaggingTool.new
      tag_tool.write("/foo/bar/baz.txt", 49)
      assert File.readlines(FILE).include?("/foo/bar/baz.txt:49\n"), "should write info"
    end

  end
end
