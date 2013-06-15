module Haml
  module I18n
    class Extractor
      class UserAction

        def initialize(input)
          @input = input
        end

        def edit?
          @input == 'e'
        end

        def replace_line?
          @input == 'y' || @input == 'e'
        end

        def no_replace?
          @input == 'n'
        end


      end
    end
  end
end


