require 'haml'
require 'haml/parser'
module Haml
  module I18n
    class Extractor
      class TextFinder

        THINGS_THAT_ARE_NOT_POTENTIAL_TEXT = [ Haml::Parser::DIV_CLASS, Haml::Parser::DIV_ID,
            Haml::Parser::COMMENT, Haml::Parser::SANITIZE, Haml::Parser::FLAT_SCRIPT,
            Haml::Parser::FILTER, Haml::Parser::DOCTYPE, Haml::Parser::ESCAPE ]

        ## hint: Use http://rubular.com
        SIMPLE_STRING_REGEX = /["'](.*)["']/
        # = "yes"
        # = 'yes'
        LINK_TO_REGEX = /link_to\s*\(?\s*['"](.*)['"]\s*,\s*(.*)\)?/
        # = link_to "yes", "http://bla.com"
        # = link_to('yes'    , "http://bla.com")
        # = link_to(  "yes's w space", "http://bla.com")
        ELEMENT_REGEX = /%([\w.#-]+)({.+?})?(=)?(.*)/
        # %foo.bar yes
        # %foo.bar= no
        # %foo{:a => 'b'} yes
        # rubular.com against %foo#bar#cheez{:cheeze => 'hell'}= "what #{var}"

        def initialize(haml)
          @haml = haml
          @parser = Haml::Parser.new(haml, Haml::Options.new)
        end
        
        def line
          if @haml == ""
            return Haml::Parser::Line.new("", "", "", 0, @parser, false)
          end

          match = @haml.rstrip.scan(/(([ \t]+)?(.*?))(?:\Z|\r\n|\r|\n)/m)
          match.pop
          haml_line ||= match.each_with_index.map do |(full, whitespace, text), index|
            Haml::Parser::Line.new(whitespace, text.rstrip, full, index, @parser, false)
          end.first
          haml_line
        end
        
        def find
          text_match = process_by_regex.last
        end

        # returns [ line_type, text_found ]
        def process_by_regex
          case line.full[0]
          when *THINGS_THAT_ARE_NOT_POTENTIAL_TEXT
            [:not_text, ""]
          when Haml::Parser::SILENT_SCRIPT
            parse_silent_script
          when Haml::Parser::ELEMENT
            parse_element
          when Haml::Parser::SCRIPT
            parse_loud_script
          else
            [:text, line.full.strip]
          end
        end
  
        private

        def parse_silent_script
          line.full.match(/-[\s\t]*#{SIMPLE_STRING_REGEX}/)
          [:silent, $1.to_s]
        end
  
        def parse_loud_script
          line.full.match(/=[\s\t]*#{LINK_TO_REGEX}/)
          return [:loud, $1.to_s] if text = $1
          line.full.match(/=[\s\t]*#{SIMPLE_STRING_REGEX}/)
          return [:loud, $1.to_s]
        end
  
        def parse_element
          line.full.match(ELEMENT_REGEX)
          elem_with_class_and_ids = $1
          attributes_ruby_style = $2
          is_loud_script = $3
          text = $4.to_s
          if is_loud_script
            self.class.new("= #{text}").process_by_regex # treat like a loud script.
          else
            [:element, text.strip]
          end
        end
  
      end
    end
  end
end