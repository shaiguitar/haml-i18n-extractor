require 'test_helper'

module Haml
  class HamlParserTest < MiniTest::Unit::TestCase

    def setup
      @body = "- if true\n  bar"
    end

    def test_it_can_collect_metadata_about_lines
      tree = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = tree.flattened_values
      assert_equal line_metadatas.size, 2
    end

    def test_it_can_collect_metadata_about_lines
      parser = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = parser.flattened_values
      assert_equal line_metadatas.size, 2
    end

    # easy api to use index <-> lineno
    def test_it_is_sorted_by_line_numbers
      parser = Haml::I18n::Extractor::HamlParser.new(@body)
      line_metadatas = parser.flattened_values
      assert_equal line_metadatas, line_metadatas.sort_by{|m| m[:line]}
    end


  end
end
