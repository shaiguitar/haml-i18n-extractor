require 'test_helper'

module Haml
  class ExtractorTest < MiniTest::Unit::TestCase

    # TODO: read in the file, parse it line by line, use text_finder and extract away
    # TODO: ensure if there are duplicate strings on one line, to handle that correctly? not sure if that's even a use-case?
    # for eg: find_text("%a{'href' => 'http://whatever'} whatever"), ["whatever"]
    # TODO: Do extraction, verify the haml is parsable at the end.
    # TODO: handles duplicate texts and doesn't silently let that pass somehow
    # TODO: does not fail on handling text with weird characters so t() fails weirdly ("hell's a ~@~" => t(".hell's_a_~@~"))...

    def file_path(name)
      File.dirname(__FILE__) + "/support/#{name}"
    end

    test "can not initialize if the haml is not valid syntax" do
      begin
        Haml::I18n::Extractor.new(file_path("bad.haml"))
        assert false, "should not get here"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should fail with invalid syntax"
      end
    end

    test "can initialize if the haml is valid syntax" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert true, "extractor can initialize"
    end

    test "it can process the haml and replace it with other text" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      @ex1.run
    end

    test "it can replace a string body and have expected output" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      expected_output = File.read(file_path("ex1.output.haml"))
      assert_equal @ex1.new_body, expected_output
    end

    test "it writes to an out file if valid haml output" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      FileUtils.rm_rf(@ex1.haml_writer.path)
      assert_equal File.exists?(@ex1.haml_writer.path), false
      @ex1.run
      assert_equal File.exists?(@ex1.haml_writer.path), true
    end

    test "it fails before it writes to an out file if it is not valid" do
      begin
        @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
        @ex1.stub(:assign_new_body, nil) do #nop
          @ex1.haml_writer.body = File.read(file_path("bad.haml"))
          @ex1.run
        end
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should not allow invalid output to be written"
      end
    end
    
  end
end