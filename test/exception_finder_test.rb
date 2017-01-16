require 'test_helper'

module Haml
  class ExceptionFinderTest < Minitest::Test

    MATCHES =  {
      %{TEXT} => "TEXT",
      %{"TEXT"} => "TEXT",
      %{'TEXT'} => "TEXT",
      %{(TEX'T)} => "(TEX'T)",
      %{"TEX'T"} => "TEX'T",
      %{  TEXT} => "  TEXT",
      %{t('TEXT')} => "t('TEXT')",
      %{TEXT \#{with_code}} => "TEXT \#{with_code}",
      %{link_to 'TEXT', "http://bla"} => ["TEXT", "http://bla"],
      %{link_to('TEXT', "http://bla")} => ["TEXT", "http://bla"],
      %{link_to   "TEXT", "http://bla")} => ["TEXT", "http://bla"],
      %{link_to("TEXT"), role: 'button', data: {toggle: 'dropdown'} do} => ["TEXT", "button", "dropdown"],
      %{link_to   "TEXT", role: 'button', data: {toggle: 'dropdown'} do} => ["TEXT", "button", "dropdown"],
      %{link_to pending_account_invoices_path(account) do} => "",
      %{link_to(pending_account_invoices_path(account),"http://random")} => "http://random",
      %{f.submit "Close This Month (cannot be undone)", :class => 'btn btn-primary'} => ["Close This Month (cannot be undone)", "btn btn-primary"]
    }

    def test_it_finds_text_pretty_simply
      MATCHES.each do |input, expected_result|
        assert_equal expected_result, find(input)
      end
    end

    def test_it_actually_needs_to_do_something_intellegent_with_intperolated_values
      # @FIXME
      #raise "raw text matching needs to be responsible for knowing if needed to interpolate?"
    end

    def test_it_finds_parameters
      input = "= f.input :blah, label: 'BLAH', hint: 'BLABBLOO'"
      find_results = find(input)
      assert_equal(['BLAH', 'BLABBLOO'], find_results)
    end

    private

    def find(txt)
      Haml::I18n::Extractor::ExceptionFinder.new(txt).find
    end
  end
end
