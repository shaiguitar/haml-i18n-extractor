require 'highline'
require 'highline/import'

module Haml
  module I18n
    class Extractor
      class Prompter

        include Helpers::Highline

        def initialize(orig_line, replaced_line)
          @orig_line = orig_line
          @replaced_line = replaced_line
        end

        def ask_user
          say(highlight("Replace this line:"))
          say("\n")
          say(@orig_line.inspect)
          say("\n")
          say(highlight("With this line?"))
          say("\n")
          say(@replaced_line.inspect)
          say("\n")
          answer = ask(highlight('y/n?')) do |q|
                     q.echo      = false
                     q.character = true
                     q.validate  = /\A[yn]\Z/
          end
          answer == 'y'
        end

      end
    end
  end
end


