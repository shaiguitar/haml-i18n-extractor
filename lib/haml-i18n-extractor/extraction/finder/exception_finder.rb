module Haml
  module I18n
    class Extractor
      class ExceptionFinder

        LINK_TO_REGEX_DOUBLE_Q = /link_to\s*\(?\s*["](.*?)["]\s*,\s*(.*)\)?/
        LINK_TO_REGEX_SINGLE_Q = /link_to\s*\(?\s*['](.*?)[']\s*,\s*(.*)\)?/
        LINK_TO_BLOCK_FORM_SINGLE_Q = /link_to\s*\(?['](.*?)[']\)?.*\sdo\s*$/
        LINK_TO_BLOCK_FORM_DOUBLE_Q = /link_to\s*\(?["](.*?)["]\)?.*\sdo\s*$/
        LINK_TO_NO_QUOTES = /link_to\s*\(?([^'"]*?)\)?.*/

        FORM_SUBMIT_BUTTON_SINGLE_Q = /[a-z]\.submit\s?['](.*?)['].*$/
        FORM_SUBMIT_BUTTON_DOUBLE_Q = /[a-z]\.submit\s?["](.*?)["].*$/

        # this class simply returns text except for anything that matches these regexes.
        # returns first match.
        EXCEPTION_MATCHES = [ LINK_TO_BLOCK_FORM_DOUBLE_Q, LINK_TO_BLOCK_FORM_SINGLE_Q,
                              LINK_TO_REGEX_DOUBLE_Q, LINK_TO_REGEX_SINGLE_Q , LINK_TO_NO_QUOTES,
                              FORM_SUBMIT_BUTTON_SINGLE_Q, FORM_SUBMIT_BUTTON_DOUBLE_Q]


        def initialize(text)
          @text = text
        end

        def self.could_match_script?(txt)
          # want to match:
          # = 'foo'
          # = "foo"
          # = link_to 'bla'
          #
          # but not match:
          # = ruby_var = 2
          scanner = StringScanner.new(txt)
          scanner.scan(/\s+/)
          scanner.scan(/['"]/) || EXCEPTION_MATCHES.any? {|regex| txt.match(regex) }
        end

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


