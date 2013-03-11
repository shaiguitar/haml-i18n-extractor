require 'test_helper'

module Haml
  class TextReplacerTest < MiniTest::Unit::TestCase
    
    test "it initializes with the line it is going to replace and the match to replace" do
      Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
    end

    test "it can replace the body of haml with t() characters" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
      assert_equal replacer.replace!, { :replace_with => "t(.this_is_whatever)", :replace_this => "this is whatever" }
    end

    test "it limits the characters of the t namespace it provides to LIMIT_KEY_NAME" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever" * 80, "this is whatever" * 80)
      assert_equal replacer.replace![:replace_with].size, Haml::I18n::Extractor::TextReplacer::LIMIT_KEY_NAME + 4 # t(.)
    end
    
    test "it does not allow weird characters in the keyname" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this (is `ch@racter ~ madness!", "this (is `ch@racter ~ madness!")
      assert_equal replacer.replace!, { :replace_with => "t(.this_is_chracter_madness)", :replace_this => "this (is `ch@racter ~ madness!" }
    end

  end
end
