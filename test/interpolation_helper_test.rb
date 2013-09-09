require 'test_helper'

module Haml
  class InterpolationHelperTest < MiniTest::Unit::TestCase

    def test_it_takes_text_and_returns_interpolations
      replace = "this may \#{be} the \#{dup}"
      t_name = "this_may_be_the_dup"
      helper = Haml::I18n::Extractor::InterpolationHelper.new(replace, t_name)
      assert helper.interpolations == ["be", "dup"], "can catch the interpolations"
    end


    def test_it_takes_text_and_custom_keynames
      replace = "this may \#{be} the \#{dup}"
      t_name = "this_may_be_the_dup"
      helper = Haml::I18n::Extractor::InterpolationHelper.new(replace, t_name)
      assert helper.keyname_with_vars == "t('.this_may_be_the_dup', :be => (be), :dup => (dup))",
        "returns custom t() with vars"
    end

    def test_it_takes_text_and_returns_for_str_with_no_quotes
      replace = "\\\#{is_this_hard?} what"
      t_name = "is_this_hard_what"
      helper = Haml::I18n::Extractor::InterpolationHelper.new(replace, t_name)
      assert helper.interpolations == ["is_this_hard?"], "can catch the interpolations"
      x = helper.keyname_with_vars
      #puts x.inspect
      assert x == "t('.is_this_hard_what', :is_this_hard => (is_this_hard?))",
        "returns custom t() with vars"
    end

    # FIXME these don't work?
    #%p \#{is_this_hard?} what
    #%span I don't know if this \#{is_also} what
    #%p= t('.what', :is_this_hard => is_this_hard?)
    #%span= t('.i_dont_know_if_this_what', :is_also => is_also)

  end
end



