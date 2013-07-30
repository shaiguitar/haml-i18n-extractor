require 'test_helper'

module Haml
  # misnomer, this is also testing UserAction
  class PrompterAndUserActionTest < MiniTest::Unit::TestCase

    test "asks_to_process_line_yes" do
      with_highline("y") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").replace_line?, true
      end
    end

    test "asks_to_process_line_no" do
      with_highline("n") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").no_replace?, true
      end
    end

    test "test_asks_to_process_line_tag" do
      with_highline("t") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").tag?, true
      end
    end

 end
end



