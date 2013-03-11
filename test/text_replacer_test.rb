require 'test_helper'

module Haml
  class TextReplacerTest < MiniTest::Unit::TestCase
    
    test "it initializes with the line it is going to replace and the match to replace" do
      Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
    end

    # some text replacement examples
    test "it can replace the body of haml with t() characters" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
      assert_equal replacer.replace_hash, { :replace_with => "t('.this_is_whatever')"  }
    end

    test "it can replace the body of haml with t() characters example" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span Admin Dashboard", "Admin Dashboard")
      assert_equal replacer.replace_hash, { :replace_with => "%span t('.admin_dashboard')" }
    end

    test "it can replace the body of haml with t() characters example for link_to and removes surrounding quotes as well" do
      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to 'Some Place', '/'}, "Some Place")
      assert_equal replacer.replace_hash, { :replace_with => %{%p#brand= link_to t('.some_place'), '/'} }

      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to "Some Place", "/"}, "Some Place")
      assert_equal replacer.replace_hash, { :replace_with => %{%p#brand= link_to t('.some_place'), "/"} }
    end

    # keyname restrictions
    test "it limits the characters of the t namespace it provides to LIMIT_KEY_NAME" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever" * 80, "this is whatever" * 80)
      assert_equal replacer.replace_hash[:replace_with].size, Haml::I18n::Extractor::TextReplacer::LIMIT_KEY_NAME + 6 # t('.')
    end
    
    test "it does not allow weird characters in the keyname" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this (is `ch@racter ~ madness!", "this (is `ch@racter ~ madness!")
      assert_equal replacer.replace_hash, { :replace_with => "t('.this_is_chracter_madness')" }
    end

  end
end
