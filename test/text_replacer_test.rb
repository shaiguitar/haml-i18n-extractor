require 'test_helper'

module Haml
  class TextReplacerTest < MiniTest::Unit::TestCase
    
    test "it initializes with the line it is going to replace and the match to replace" do
      Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
    end

    # some text replacement examples
    test "it can replace the body of haml with t() characters" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever")
      assert_equal replacer.replace_hash, { :modified_line => "t('.this_is_whatever')", 
                                          :keyname => "t('.this_is_whatever')", :replaced_text => "this is whatever"  }
    end

    test "it can replace the body of haml with t() characters example" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span Admin Dashboard", "Admin Dashboard")
      assert_equal replacer.replace_hash, { :modified_line => "%span t('.admin_dashboard')",
                                           :keyname => "t('.admin_dashboard')", :replaced_text => "Admin Dashboard" }
    end

    test "it won't replace already replaced t() characters" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span t('.admin_dashboard')", "t('.admin_dashboard')")
      assert_equal replacer.replace_hash, { :modified_line => "%span t('.admin_dashboard')",
                                           :keyname => "t('.admin_dashboard')", :replaced_text => "t('.admin_dashboard')" }
    end

    test "it can replace the body of haml with t() characters example for link_to and removes surrounding quotes as well" do
      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to 'Some Place', '/'}, "Some Place")
      assert_equal replacer.replace_hash, { :modified_line => %{%p#brand= link_to t('.some_place'), '/'} , 
                                            :keyname => "t('.some_place')", :replaced_text => "Some Place" }

      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to "Some Place", "/"}, "Some Place")
      assert_equal replacer.replace_hash, { :modified_line => %{%p#brand= link_to t('.some_place'), "/"} ,
                                            :keyname => "t('.some_place')", :replaced_text => "Some Place" }
    end

    # keyname restrictions
    test "it limits the characters of the t namespace it provides to LIMIT_KEY_NAME" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever" * 80, "this is whatever" * 80)
      assert_equal replacer.replace_hash[:modified_line].size, Haml::I18n::Extractor::TextReplacer::LIMIT_KEY_NAME + 6 # t('.')
    end
    
    test "it does not allow weird characters in the keyname" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this (is `ch@racter ~ madness!", "this (is `ch@racter ~ madness!")
      assert_equal replacer.replace_hash, { :modified_line => "t('.this_is_chracter_madness')", 
                                            :keyname => "t('.this_is_chracter_madness')", :replaced_text => "this (is `ch@racter ~ madness!" }
    end

  end
end
