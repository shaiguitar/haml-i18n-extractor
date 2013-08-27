require 'test_helper'

module Haml
  class HamlParserTest < MiniTest::Unit::TestCase

    def setup
      @body = "- if true\n  bar"
    end

    test "it can collect metadata about lines" do
      tree = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = tree.flattened_values
      assert_equal line_metadatas.size, 2
    end

    test "it can collect metadata about lines" do
      parser = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = parser.flattened_values
      assert_equal line_metadatas.size, 2
    end

    # easy api to use index <-> lineno
    test "it is sorted by line numbers" do
      parser = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = parser.flattened_values
      assert_equal line_metadatas, line_metadatas.sort_by{|m| m[:line]}
    end


  end
end
