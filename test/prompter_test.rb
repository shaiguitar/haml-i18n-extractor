require 'test_helper'

module Haml
  class PrompterTest < MiniTest::Unit::TestCase

    def test_asks_to_process_line_yes
      with_highline("y") do
        assert_equal Haml::I18n::Extractor::Prompter.new("orig", "replace").ask_user, true
      end
    end

    def test_asks_to_process_line_no
      with_highline("n") do
        assert_equal Haml::I18n::Extractor::Prompter.new("orig", "replace").ask_user, false
      end
    end

 end
end



