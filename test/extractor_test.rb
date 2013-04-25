require 'test_helper'

module Haml
  class ExtractorTest < MiniTest::Unit::TestCase

    def setup
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
    end

    test "it can process the haml and replace it with other text" do
      @ex1.run
    end
    
    test "it can initialize with a type of overwrite or dump which creates an overwrite type haml writer" do
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :type => :overwrite)
      assert_equal h.haml_writer.overwrite?, true
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal h.haml_writer.overwrite?, false
    end

    test "it can initialize with a prompt_per_line option which prompts the user-per line" do
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"), :prompt_per_line => true)
      assert_equal h.prompt_per_line?, true
      h = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal h.prompt_per_line?, false
   end
    
    test "can not initialize if the haml is not valid syntax" do
      begin
        Haml::I18n::Extractor.new(file_path("bad.haml"))
        assert false, "should not get here"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should fail with invalid syntax"
      end
    end

    test "it can replace a string body and have expected output" do
      expected_output = File.read(file_path("ex1.output.haml"))
      assert_equal @ex1.new_body, expected_output
    end

    test "it writes the haml to an out file if valid haml output" do
      FileUtils.rm_rf(@ex1.haml_writer.path)
      assert_equal File.exists?(@ex1.haml_writer.path), false
      @ex1.run
      assert_equal File.exists?(@ex1.haml_writer.path), true
    end
    
    test "it writes the locale info to an out file when run" do
      assert_equal File.exists?(@ex1.yaml_tool.locale_file), false
      @ex1.run
      assert_equal File.exists?(@ex1.yaml_tool.locale_file), true
      assert_equal YAML.load(File.read(@ex1.yaml_tool.locale_file)), @ex1.yaml_tool.yaml_hash
    end

    test "it raises if there is nothing to translate" do
      begin
        @nothing_to_translate = Haml::I18n::Extractor.new(file_path("nothing_to_translate.haml"))
        assert_equal @ex1.yaml_tool.locale_hash, nil
        @nothing_to_translate.run
        assert false, "should raise"
      rescue Haml::I18n::Extractor::NothingToTranslate
        assert true, "NothingToTranslate raised"
      end
    end

    test "sends a hash over of replacement info to its yaml tool when run" do
      @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
      assert_equal @ex1.yaml_tool.locale_hash, nil
      @ex1.run
      assert @ex1.yaml_tool.locale_hash.is_a?(Hash), "its is hash of info about the files lines"
      assert_equal @ex1.yaml_tool.locale_hash.size, @ex1.haml_reader.lines.size
    end

    test "it fails before it writes to an out file if it is not valid" do
      begin
        @ex1 = Haml::I18n::Extractor.new(file_path("ex1.haml"))
        @ex1.stub(:assign_new_body, nil) do #nop
          @ex1.haml_writer.body = File.read(file_path("bad.haml"))
          @ex1.run
        end
        assert false, "should raise"
      rescue Haml::I18n::Extractor::InvalidSyntax
        assert true, "it should not allow invalid output to be written"
      end
    end
    
  end
end
