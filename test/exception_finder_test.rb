require 'test_helper'

module Haml
  class ExceptionFinderTest < MiniTest::Unit::TestCase

    MATCHES =  {
      %{TEXT} => "TEXT",
      %{"TEXT"} => "\"TEXT\"",
      %{'TEXT'} => "'TEXT'",
      %{(TEX'T)} => "(TEX'T)",
      %{"TEX'T"} => "\"TEX'T\"",
      %{  TEXT} => "  TEXT",

      %{TEXT \#{with_code}} => "TEXT \#{with_code}",

      %{link_to 'TEXT', "http://bla"} => "TEXT",
      %{link_to('TEXT', "http://bla")} => "TEXT",
      %{link_to   "TEXT", "http://bla")} => "TEXT",
      %{link_to("TEXT"), role: 'button', data: {toggle: 'dropdown'} do} => "TEXT",
      %{link_to   "TEXT", role: 'button', data: {toggle: 'dropdown'} do} => "TEXT",
      %{link_to pending_account_invoices_path(account) do} => "",
      %{link_to(pending_account_invoices_path(account),"http://random")} => "",
      %{f.submit "Close This Month (cannot be undone)", :class => 'btn btn-primary'} => "Close This Month (cannot be undone)"
    }

    def test_it_finds_text_pretty_simply
      MATCHES.each do |k,v|
        #puts "handling #{k}"
        assert_equal find(k), v
      end
    end

    def test_it_actually_needs_to_do_something_intellegent_with_intperolated_values
      # @FIXME
      #raise "raw text matching needs to be responsible for knowing if needed to interpolate?"
    end

    private

    def find(txt)
      Haml::I18n::Extractor::ExceptionFinder.new(txt).find
    end
  end
end



