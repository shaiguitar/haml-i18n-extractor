require 'test_helper'

module Haml
  class CLITest < MiniTest::Unit::TestCase

    test "it needs an explicit interactive or non-interactive option" do
      opts = {:non_interactive => nil, :interactive => nil}
      with_highline do
        begin
          Haml::I18n::Extractor::CLI.new(opts).start
        rescue Haml::I18n::Extractor::CLI::CliError
          assert @output.string.match(/--help/), "passing interactive or not"
        end
      end
    end

    test "with a interactive option it needs a path" do
      opts = {:non_interactive => nil, :path => nil}
       with_highline do
         begin
           Haml::I18n::Extractor::CLI.new(opts).start
         rescue Haml::I18n::Extractor::CLI::CliError
           assert @output.string.match(/--help/), "passing interactive or not needs path"
         end
      end
   end

  end
end


