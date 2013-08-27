module Haml
  module I18n
    class Extractor
      class ExceptionFinder

        def initialize(text)
          @text = text
        end

        LINK_TO_REGEX_DOUBLE_Q = /link_to\s*\(?\s*["](.*?)["]\s*,\s*(.*)\)?/
        LINK_TO_REGEX_SINGLE_Q = /link_to\s*\(?\s*['](.*?)[']\s*,\s*(.*)\)?/
        LINK_TO_BLOCK_FORM_SINGLE_Q = /link_to\s*\(?['](.*?)[']\)?.*\sdo\s*$/
        LINK_TO_BLOCK_FORM_DOUBLE_Q = /link_to\s*\(?["](.*?)["]\)?.*\sdo\s*$/
        LINK_TO_NO_QUOTES = /link_to\s*\(?([^'"]*?)\)?.*/

        # this class simply returns text except for anything that matches these regexes.
        # returns first match.
        EXCEPTION_MATCHES = [ LINK_TO_BLOCK_FORM_DOUBLE_Q, LINK_TO_BLOCK_FORM_SINGLE_Q,
                              LINK_TO_REGEX_DOUBLE_Q, LINK_TO_REGEX_SINGLE_Q , LINK_TO_NO_QUOTES ]

        def find
          ret = @text
          EXCEPTION_MATCHES.each do |regex|
            if @text.match(regex)
              ret = $1
              break # return whatever it finds on first try, order of above regexes matters
            end
          end
          ret
        end

      end
    end
  end
end


