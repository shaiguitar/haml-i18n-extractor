require 'test_helper'

module Haml
  class StringFinderTest < MiniTest::Unit::TestCase

    # empty line
    def test_empty_lines_filters_matches_with_nometadata
      assert_equal find_text(""), nil
      assert_equal find_type(""), nil
    end

    # regular text mode
    def test_regular_text_without_whitespaces
      assert_equal find_text("iphone"), "iphone"
      assert_equal find_type("iphone"), :plain
    end

    def test_regular_text_with_whitespaces
      assert_equal find_text("iphone4  "), "iphone4"
      assert_equal find_type("iphone4  "), :plain
    end

    def test_scripts_with_strings
      assert_equal find_text("= 'jessica'"), " 'jessica'"
      assert_equal find_type("= 'jessica'"), :script
    end

    def test_scripts_with_no_strings
      assert_equal find_text("= true"), ""
      assert_equal find_type("= true"), :script
    end

    # html tag mode
    def test_tag_text_is_an_tag
      assert_equal find_text("%span Text to find"), "Text to find"
      assert_equal find_type("%span Text to find"), :tag
    end

    def test_tag_text_with_class_is_an_tag
      assert_equal find_text("%span.whatever-with-thing Text to find"), "Text to find"
      assert_equal find_type("%span.whatever-with-thing Text to find"), :tag
    end

    def test_tag_text_with_ruby_eval_code_is_a_script_script
      assert_equal find_text("%span= ruby_eval_code"), ""
      assert_equal find_type("%span= ruby_eval_code"), :tag
    end

    def test_tag_text_with_ruby_eval_code_and_class_is_a_script_script
      assert_equal find_text( "%span#whatever-with-thing= ruby_eval_code"), ""
      assert_equal find_type( "%span#whatever-with-thing= ruby_eval_code"), :tag
    end

    def test_ruby_style_tags_ahref__httpwhatever_whatever
      assert_equal find_text("%a{'href' => 'http://whatever'} whatever"), "whatever"
      assert_equal find_type("%a{'href' => 'http://whatever'} whatever"), :tag
    end

    # script scripts / ruby eval mode
    def test_script_scripts_with_strings
      assert_equal find_text('= "bob"'), " \"bob\""
      assert_equal find_text("= 'bob'"), " 'bob'"
      assert_equal find_type("= 'bob'"), :script
    end

    def test_script_scripts_does_not_interpolate_ruby_vars_in_strings
      assert_equal find_text('= "ruby can #{var}"'), " \"ruby can \#{var}\""
      assert_equal find_type('= "ruby can #{var}"'), :script
    end

    # special script scripts exceptions
    def test_it_finds_link_to_texts_as_an_exception_to_the_rule
      assert_equal find_text('= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_type('= link_to "This should be found", "/"'), :script
    end

    def test_it_finds_link_to_texts_as_an_exception_to_the_rule_and_does_not_interpolate
      assert_equal find_text('= "Statistics for #{@name}"'), " \"Statistics for \#{@name}\""
      assert_equal find_type('= "Statistics for #{@name}"'), :script
    end

    # html tag mode with ruby evaling
    def test_html_tag_with_ruby_eval_with_strings
      assert_equal find_text('%p= "bob"'), "\"bob\""
      assert_equal find_text("%p.what= 'bob'"), "'bob'"
      assert_equal find_text("%p.what{:attr => :val}= 'bob'"), "'bob'"
      assert_equal find_type("%p.what{:attr => :val}= 'bob'"), :tag
    end

    def test_html_tag_script_scripts_does_not_interpolate_ruby_vars_in_strings
      assert_equal find_text('%p= "ruby can #{var}"'), "\"ruby can \#{var}\""
      assert_equal find_text('%p.what= "ruby can #{var}"'), "\"ruby can \#{var}\""
      assert_equal find_text('%p.what{:attr => :val}= "ruby can #{var}"'), "\"ruby can \#{var}\""
      assert_equal find_type('%p.what{:attr => :val}= "ruby can #{var}"'), :tag
    end

    def test_html_tag_it_finds_link_to_texts_as_an_exception_to_the_rule
      assert_equal find_text('%p= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_text('%p.what= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_text('%p.what{:attr => :val}= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_type('%p.what{:attr => :val}= link_to "This should be found", "/"'), :tag
    end

    def test_html_tag_it_finds_link_to_texts_as_an_exception_to_the_rule_and_does_not_interpolate
      assert_equal find_text('%p= "Statistics for #{@name}"'), "\"Statistics for \#{@name}\""
      assert_equal find_text('%p.what= "Statistics for #{@name}"'), "\"Statistics for \#{@name}\""
      assert_equal find_text('%p.what{:attr => :val}= "Statistics for #{@name}"'), "\"Statistics for \#{@name}\""
      assert_equal find_type('%p.what{:attr => :val}= "Statistics for #{@name}"'), :tag
    end

    private

    def process_haml(haml)
      metadata = Haml::I18n::Extractor::HamlParser.new(haml).metadata.first
      text_finder = Haml::I18n::Extractor::TextFinder.new(haml,metadata)
      text_finder.process_by_regex
    end

    def find_type(haml)
      result = process_haml(haml)
      type, text =  [result.type, result.match]
      type
    end

    def find_text(haml)
      result = process_haml(haml)
      type, text =  [result.type, result.match]
      text
    end

  end
end
