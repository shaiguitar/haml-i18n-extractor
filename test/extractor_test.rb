require 'test_helper'

module Haml
  class ExtractorTest < MiniTest::Unit::TestCase

    test "it can process the haml and replace it with other text!" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      @ex1.run
    end

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