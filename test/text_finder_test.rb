require 'test_helper'

module Haml
  class StringFinderTest < MiniTest::Unit::TestCase

    # empty line
    test "empty line does not explode" do
      assert_equal find_text(""), ""
      assert_equal find_type(""), :text
    end

    # regular text mode
    test "regular text without whitespaces" do
      assert_equal find_text("iphone"), "iphone"
      assert_equal find_type("iphone"), :text
    end

    test "regular text with whitespaces" do
      assert_equal find_text("  iphone4"), "iphone4"
      assert_equal find_type("  iphone4"), :text
    end

    # silent script mode
    test "silent scripts with strings" do
      assert_equal find_text("- 'jessica'"), "jessica"
      assert_equal find_type("- 'jessica'"), :silent
    end

    test "silent scripts with no strings" do
      assert_equal find_text("- if true"), ""
      assert_equal find_type("- if true"), :silent
    end

    # html element mode
    test "%tag Text is an element" do
      assert_equal find_text("%span Text to find"), "Text to find"
      assert_equal find_type("%span Text to find"), :element
    end

    test "%tag Text with class is an element" do
      assert_equal find_text("%span.whatever-with-thing Text to find"), "Text to find"
      assert_equal find_type("%span.whatever-with-thing Text to find"), :element
    end

    test "%tag Text with ruby eval code is a loud script" do
      assert_equal find_text("%span= ruby_eval_code"), ""
      assert_equal find_type("%span= ruby_eval_code"), :loud
    end

    test "%tag Text with ruby eval code and class is a loud script" do
      assert_equal find_text( "%span#whatever-with-thing= ruby_eval_code"), ""
      assert_equal find_type( "%span#whatever-with-thing= ruby_eval_code"), :loud
    end
    
    test "Ruby style tags %a{'href' => 'http://whatever'} whatever" do
      assert_equal find_text("%a{'href' => 'http://whatever'} whatever"), "whatever"
      assert_equal find_type("%a{'href' => 'http://whatever'} whatever"), :element
    end
    
    # loud scripts / ruby eval mode
    test "loud scripts with strings" do
      assert_equal find_text('= "bob"'), "bob"
      assert_equal find_text("= 'bob'"), "bob"
      assert_equal find_type("= 'bob'"), :loud
    end

    test "loud scripts does not interpolate ruby vars in strings" do
      assert_equal find_text('= "ruby can #{var}"'), "ruby can \#{var}"
      assert_equal find_type('= "ruby can #{var}"'), :loud
    end
    
    # special loud scripts exceptions
    test "it finds link_to texts as an exception to the rule" do
      assert_equal find_text('= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_type('= link_to "This should be found", "/"'), :loud
    end
    
    test "it finds link_to texts as an exception to the rule and does not interpolate" do
      assert_equal find_text('= "Statistics for #{@name}"'), "Statistics for \#{@name}"
      assert_equal find_type('= "Statistics for #{@name}"'), :loud
    end

    # html element mode with ruby evaling
    test "html element with ruby eval with strings" do
      assert_equal find_text('%p= "bob"'), "bob"
      assert_equal find_text("%p.what= 'bob'"), "bob"
      assert_equal find_text("%p.what{:attr => :val}= 'bob'"), "bob"
      assert_equal find_type("%p.what{:attr => :val}= 'bob'"), :loud
    end
    
    test "html element loud scripts does not interpolate ruby vars in strings" do
      assert_equal find_text('%p= "ruby can #{var}"'), "ruby can \#{var}"
      assert_equal find_text('%p.what= "ruby can #{var}"'), "ruby can \#{var}"
      assert_equal find_text('%p.what{:attr => :val}= "ruby can #{var}"'), "ruby can \#{var}"
      assert_equal find_type('%p.what{:attr => :val}= "ruby can #{var}"'), :loud
    end
    
    test "html element it finds link_to texts as an exception to the rule" do
      assert_equal find_text('%p= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_text('%p.what= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_text('%p.what{:attr => :val}= link_to "This should be found", "/"'), "This should be found"
      assert_equal find_type('%p.what{:attr => :val}= link_to "This should be found", "/"'), :loud
    end
    
    test "html element it finds link_to texts as an exception to the rule and does not interpolate" do
      assert_equal find_text('%p= "Statistics for #{@name}"'), "Statistics for \#{@name}"
      assert_equal find_text('%p.what= "Statistics for #{@name}"'), "Statistics for \#{@name}"
      assert_equal find_text('%p.what{:attr => :val}= "Statistics for #{@name}"'), "Statistics for \#{@name}"
      assert_equal find_type('%p.what{:attr => :val}= "Statistics for #{@name}"'), :loud
    end

    private

    def process_haml(haml)
      text_finder = Haml::I18n::Extractor::TextFinder.new(haml)
      text_finder.process_by_regex
    end

    def find_type(haml)
      type, text = process_haml(haml)
      type
    end

    def find_text(haml)
      type, text = process_haml(haml)
      text
    end

  end
end