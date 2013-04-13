require 'test_helper'
require 'fileutils'

module Haml
  class HamlWriterTest < MiniTest::Unit::TestCase

    ORIG_TEMP_FILE_PATH = File.join(TestHelper::TMPDIR, "foo_haml_extractor_test.haml")

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

    test "it can dump the file and that is the default" do
      @writer = Haml::I18n::Extractor::HamlWriter.new(ORIG_TEMP_FILE_PATH)
      @writer.body = "This is what it is"
      @writer.write_file
      assert_equal @writer.path, "#{TestHelper::TMPDIR}foo_haml_extractor_test.i18n-extractor.haml"
      assert_equal File.read(@writer.path), "This is what it is\n"
    end

    test "it can overwrite the file" do
      @writer = Haml::I18n::Extractor::HamlWriter.new(ORIG_TEMP_FILE_PATH, {:type => :overwrite})
      @writer.body = "This is what it is"
      @writer.write_file
      assert_equal @writer.path, ORIG_TEMP_FILE_PATH # we ovewrote the original one.
      assert_equal File.read(@writer.path), "This is what it is\n"
    end

  end
end
