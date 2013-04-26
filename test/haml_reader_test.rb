require 'test_helper'
require 'fileutils'

module Haml
  class HamlReaderTest < MiniTest::Unit::TestCase

    TEMP_FILE_PATH = "/tmp/foo_haml_extractor_test"

    def setup
      FileUtils.rm_rf(TEMP_FILE_PATH)
      10.times do |index|
        File.open(TEMP_FILE_PATH, "a+") do |f|
          f.puts "line #{index}"
        end
      end
      @reader = Haml::I18n::Extractor::HamlReader.new(TEMP_FILE_PATH)
    end

    test "has a body and a path" do
      assert_equal @reader.path, TEMP_FILE_PATH
      assert_equal @reader.body, File.read(TEMP_FILE_PATH)
    end

    test "has an array of lines in that file" do
      assert_equal @reader.lines.size, 10
    end

  end
end
