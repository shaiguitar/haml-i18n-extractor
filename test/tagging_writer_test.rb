require 'test_helper'
require 'fileutils'

module Haml
  class TaggingWriterTest < Minitest::Test

    FILE = Haml::I18n::Extractor::TaggingWriter::DB

    def teardown
      FileUtils.rm_rf(FILE)
    end

    def test_it_uses_a_file_which_it_uses_to_keep_track_of_user_tagged_lines
      TestHelper.hax_shit
      assert ! File.exist?(FILE), "no tagging file should exist"
      Haml::I18n::Extractor::TaggingWriter.new
      assert File.exist?(FILE), "tagging file should be created on init"
    end

    def test_it_can_write_in_a_format
      tag_tool = Haml::I18n::Extractor::TaggingWriter.new
      tag_tool.write("/foo/bar/baz.txt", 49)
      assert File.readlines(FILE).include?("/foo/bar/baz.txt:49\n"), "should write info"
    end

  end
end
