require 'haml'
require 'haml/parser'
module Haml
  module I18n
    class Extractor
      class TextFinder

        THINGS_THAT_ARE_NOT_TEXT = [ Haml::Parser::DIV_CLASS, Haml::Parser::DIV_ID,
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
          create_lines(@haml)
        end
        
        def create_lines(haml)
          match = haml.rstrip.scan(/(([ \t]+)?(.*?))(?:\Z|\r\n|\r|\n)/m)
          match.pop
          match.each_with_index.map do |(full, whitespace, text), index|
            Haml::Parser::Line.new(whitespace, text.rstrip, full, index, @parser, false)
          end
        end
        
        def find
          result = []
          create_lines(@haml).each{|line|
            if txt = plain_text(line)
              result << txt
            end
           }
           result.compact.first # there should only be one match, per-line.
        end
  
        def plain_text(line)
          case line.full[0]
          when *THINGS_THAT_ARE_NOT_TEXT
            nil
          when Haml::Parser::SILENT_SCRIPT
            parse_silent_script(line)
          when Haml::Parser::ELEMENT
            parse_element(line)
          when Haml::Parser::SCRIPT
            parse_loud_script(line)
          else
            line.full.strip
          end
        end
  
        private

        def parse_silent_script(line)
          line.full.match(/-[\s\t]*#{SIMPLE_STRING_REGEX}/) && $1
        end
  
        def parse_loud_script(line)
          line.full.match(/=[\s\t]*#{LINK_TO_REGEX}/)
          return $1 if text = $1
          line.full.match(/=[\s\t]*#{SIMPLE_STRING_REGEX}/)
          return $1
        end
  
        def parse_element(line)
          line.full.match(ELEMENT_REGEX)
          elem_with_class_and_ids = $1
          attributes_ruby_style = $2
          is_loud_script = $3
          text = $4
          if is_loud_script
            parse_loud_script(create_lines("= #{text}").first) # just treat it like a loud script
          else
            text.strip
          end
        end
  
      end
    end
  end
end