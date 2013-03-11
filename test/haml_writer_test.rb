require 'test_helper'
require 'fileutils'

module Haml
  class HamlWriterTest < MiniTest::Unit::TestCase

    ORIG_TEMP_FILE_PATH = "/tmp/foo_haml_extractor_test.haml"

    def setup
      File.open(ORIG_TEMP_FILE_PATH, "w") do |f|
        10.times do |i|
          f.puts "line #{i}"
        end
      end
    end

    def teardown
      FileUtils.rm_rf(ORIG_TEMP_FILE_PATH)
    end

    test "is initialized with an array of lines, an original path and constructs a body and path with it" do
      @writer = Haml::I18n::Extractor::HamlWriter.new(ORIG_TEMP_FILE_PATH)
      assert_equal @writer.path, "/tmp/foo_haml_extractor_test.i18n-extractor.haml"
    end
    
    test "it can write the file" do
      @writer = Haml::I18n::Extractor::HamlWriter.new(ORIG_TEMP_FILE_PATH)
      @writer.body = "This is what it is"
      @writer.write_file
      assert_equal File.read(@writer.path), "This is what it is\n"
    end

  end
end
