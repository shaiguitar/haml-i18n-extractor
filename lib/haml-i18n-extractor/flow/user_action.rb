module Haml
  module I18n
    class Extractor
      class UserAction
  
        class Unsupported < StandardError ; end
        # overwrite, dump, next, yes, no, tag
        SUPPORTED = %w(O D N y n t)

        def initialize(input)
          raise Unsupported, "Only #{SUPPORTED.join(",")} are allowed for user input" unless SUPPORTED.include?(input)
          @input = input
        end

        def tag?
          @input == 't'
        end

        def replace_line?
          @input == 'y'
        end

        def no_replace?
          @input == 'n'
        end

        #def overwrite?
          #@input == 'O' || @input == 'R' # cheat replace
        #end

        #def dump?
          #@input == 'D'
        #end

        def next?
          @input == 'N'
        end

      end
    end
  end
end
