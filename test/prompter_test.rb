require 'test_helper'

module Haml
  # misnomer, this is also testing UserAction
  class PrompterAndUserActionTest < MiniTest::Unit::TestCase

    def test_asks_to_process_line_yes
      with_highline("y") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").replace_line?, true
      end
    end

    def test_asks_to_process_line_no
      with_highline("n") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").no_replace?, true
      end
    end

    def test_asks_to_process_line_edit
      with_highline("e") do
        assert_equal Haml::I18n::Extractor::Prompter.new.ask_user("orig", "replace").edit?, true
      end
    end

    def test_get_replacement_line
      with_highline("This is some user input") do
        assert_equal Haml::I18n::Extractor::Prompter.new.get_replacement_line, "This is some user input"
      end
    end


 end
end



