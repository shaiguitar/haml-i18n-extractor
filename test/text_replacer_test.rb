require 'test_helper'

module Haml
  class TextReplacerTest < MiniTest::Unit::TestCase
    
    test "it initializes with the line it is going to replace and the match to replace" do
      Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever", :plain)
    end

    test "but it raises if passed a wrong line type" do
      begin
        replacer = Haml::I18n::Extractor::TextReplacer.new("regular text", "regular text", :this_is_not_defined)
        assert false, 'should raise'
      rescue Haml::I18n::Extractor::NotDefinedLineType
        assert true, 'raised NotDefinedLineType'
      end
    end

    # some text replacement examples
    test "it can replace the body of haml with t() characters" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever", "this is whatever", :plain)
      assert_equal replacer.replace_hash, { :modified_line => "= t('.this_is_whatever')", 
                                          :keyname => "t('.this_is_whatever')", :replaced_text => "this is whatever"  }
    end

    test "it can replace the body of haml with t() characters example" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span Admin Dashboard", "Admin Dashboard", :tag)
      assert_equal replacer.replace_hash, { :modified_line => "%span= t('.admin_dashboard')",
                                           :keyname => "t('.admin_dashboard')", :replaced_text => "Admin Dashboard" }
    end

    test "it won't replace already replaced t() characters if they are not ruby evaled" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span t('.admin_dashboard')", "t('.admin_dashboard')", :tag)
      assert_equal replacer.replace_hash, { :modified_line => "%span t('.admin_dashboard')",
                                           :keyname => "t('.admin_dashboard')", :replaced_text => "t('.admin_dashboard')" }
    end

    test "it won't replace already replaced t() characters that are ruby evaled" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("%span= t('.admin_dashboard')", "t('.admin_dashboard')", :script)
      assert_equal replacer.replace_hash, { :modified_line => "%span= t('.admin_dashboard')",
                                           :keyname => "t('.admin_dashboard')", :replaced_text => "t('.admin_dashboard')" }
    end

    test "it can replace the body of haml with t() characters example for link_to and removes surrounding quotes as well" do
      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to 'Some Place', '/'}, "Some Place", :script)
      assert_equal replacer.replace_hash, { :modified_line => %{%p#brand= link_to t('.some_place'), '/'} , 
                                            :keyname => "t('.some_place')", :replaced_text => "Some Place" }

      replacer = Haml::I18n::Extractor::TextReplacer.new(%{%p#brand= link_to "Some Place", "/"}, "Some Place", :script)
      assert_equal replacer.replace_hash, { :modified_line => %{%p#brand= link_to t('.some_place'), "/"} ,
                                            :keyname => "t('.some_place')", :replaced_text => "Some Place" }
    end

    # keyname restrictions
    test "it limits the characters of the t namespace it provides to LIMIT_KEY_NAME" do
      replacer = Haml::I18n::Extractor::TextReplacer.new("this is whatever" * 80, "this is whatever" * 80, :plain)
      assert_equal replacer.replace_hash[:modified_line].size, Haml::I18n::Extractor::TextReplacer::LIMIT_KEY_NAME + 8 # = t('.')
    end

    test "it does not allow weird characters in the keyname" do
      weird_line = "thi:s = (is \"' `ch@racter ~ ma?dne{}ss!"
      replacer = Haml::I18n::Extractor::TextReplacer.new(weird_line, weird_line, :plain)
      assert_equal replacer.replace_hash, { :modified_line => "= t('.this_is_chracter_madness')", 
                                            :keyname => "t('.this_is_chracter_madness')", :replaced_text => weird_line }
    end

  end
end
