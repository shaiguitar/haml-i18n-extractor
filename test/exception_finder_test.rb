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
      %{link_to(pending_account_invoices_path(account),"http://random")} => ""
    }

    test "it finds text pretty simply" do
      MATCHES.each do |k,v|
        #puts "handling #{k}"
        assert_equal find(k), v
      end
    end

    test "it actually needs to do something intellegent with intperolated values..." do
      # @FIXME
      #raise "raw text matching needs to be responsible for knowing if needed to interpolate?"
    end

    private

    def find(txt)
      Haml::I18n::Extractor::ExceptionFinder.new(txt).find
    end
  end
end



